#!/usr/bin/env python3
"""Render a Pokémon Yellow map layout to a PNG for non-interactive inspection."""

from __future__ import annotations

import argparse
import binascii
import json
import re
import struct
import sys
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TILE_SIZE = 8
TILES_PER_BLOCK = 4
BLOCK_SIZE = TILE_SIZE * TILES_PER_BLOCK
EVENTS_PER_BLOCK = 2
EVENT_SIZE = BLOCK_SIZE // EVENTS_PER_BLOCK


def parse_png_2bit_grayscale(path: Path) -> tuple[int, int, list[bytearray]]:
    """Read the repository's 2-bit grayscale tileset PNGs without Pillow."""
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError(f"not a PNG file: {path}")

    width = height = bit_depth = color_type = None
    compressed = bytearray()
    offset = 8
    while offset + 12 <= len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        kind = data[offset + 4 : offset + 8]
        start = offset + 8
        end = start + length
        if end + 4 > len(data):
            raise ValueError(f"truncated PNG chunk in {path}")
        payload = data[start:end]
        if kind == b"IHDR":
            width, height, bit_depth, color_type, compression, filtering, interlace = struct.unpack(
                ">IIBBBBB", payload
            )
            if compression or filtering or interlace:
                raise ValueError(f"unsupported PNG encoding in {path}")
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            break
        offset = end + 4

    if width is None or height is None or bit_depth != 2 or color_type != 0:
        raise ValueError(
            f"expected a 2-bit grayscale tileset PNG, got bit depth {bit_depth}, "
            f"color type {color_type}: {path}"
        )
    if width % TILE_SIZE or height % TILE_SIZE:
        raise ValueError(f"tileset image dimensions must be multiples of 8: {path}")

    packed_stride = (width * bit_depth + 7) // 8
    raw = zlib.decompress(compressed)
    expected = height * (packed_stride + 1)
    if len(raw) != expected:
        raise ValueError(f"unexpected decompressed PNG size in {path}: {len(raw)} != {expected}")

    rows: list[bytearray] = []
    previous = bytearray(packed_stride)
    cursor = 0
    for _ in range(height):
        filter_type = raw[cursor]
        cursor += 1
        row = bytearray(raw[cursor : cursor + packed_stride])
        cursor += packed_stride
        for i in range(packed_stride):
            left = row[i - 1] if i else 0
            above = previous[i]
            upper_left = previous[i - 1] if i else 0
            if filter_type == 1:
                row[i] = (row[i] + left) & 0xFF
            elif filter_type == 2:
                row[i] = (row[i] + above) & 0xFF
            elif filter_type == 3:
                row[i] = (row[i] + ((left + above) // 2)) & 0xFF
            elif filter_type == 4:
                p = left + above - upper_left
                pa = abs(p - left)
                pb = abs(p - above)
                pc = abs(p - upper_left)
                predictor = left if pa <= pb and pa <= pc else above if pb <= pc else upper_left
                row[i] = (row[i] + predictor) & 0xFF
            elif filter_type != 0:
                raise ValueError(f"unsupported PNG filter {filter_type} in {path}")

        unpacked = bytearray(width)
        for x in range(width):
            shift = 6 - (x % 4) * 2
            unpacked[x] = (row[x // 4] >> shift) & 0x03
        rows.append(unpacked)
        previous = row
    return width, height, rows


def parse_map_constants() -> dict[str, tuple[int, int]]:
    source = (ROOT / "constants/map_constants.asm").read_text()
    pattern = re.compile(r"^\s*map_const\s+([A-Za-z0-9_]+),\s*(\d+),\s*(\d+)", re.M)
    return {name: (int(width), int(height)) for name, width, height in pattern.findall(source)}


def parse_tileset_names() -> dict[str, str]:
    constants = re.findall(
        r"^\s*const\s+([A-Z0-9_]+)\b",
        (ROOT / "constants/tileset_constants.asm").read_text(),
        re.M,
    )
    names = re.findall(
        r"^\s*tileset\s+([A-Za-z0-9_]+)\s*,",
        (ROOT / "data/tilesets/tileset_headers.asm").read_text(),
        re.M,
    )
    if len(constants) != len(names):
        raise ValueError(f"tileset constants/table length mismatch: {len(constants)} != {len(names)}")
    return dict(zip(constants, names))


def parse_graphics_includes(suffix: str, extension: str) -> dict[str, str]:
    """Map tileset labels in gfx/tilesets.asm to their INCBIN source paths."""
    result: dict[str, str] = {}
    pending: list[str] = []
    label_pattern = re.compile(r"([A-Za-z0-9_]+)_" + re.escape(suffix) + r"::")
    include_pattern = re.compile(r'INCBIN\s+"([^"]+\.' + re.escape(extension) + r')"')
    for line in (ROOT / "gfx/tilesets.asm").read_text().splitlines():
        pending.extend(label_pattern.findall(line))
        include = include_pattern.search(line)
        if include:
            for label in pending:
                result[label] = include.group(1)
            pending.clear()
    return result


def parse_layout_sources() -> dict[str, str]:
    """Map map labels to the layout INCBIN, including consecutive shared labels."""
    result: dict[str, str] = {}
    pending: list[str] = []
    label_pattern = re.compile(r"^\s*([A-Za-z0-9_]+)_Blocks:\s*(.*)$")
    include_pattern = re.compile(r'INCBIN\s+"(maps/[^\"]+\.blk)"')
    for line in (ROOT / "maps.asm").read_text().splitlines():
        label = label_pattern.match(line)
        if label:
            pending.append(label.group(1))
            include = include_pattern.search(label.group(2))
        else:
            include = include_pattern.search(line) if pending else None
        if include:
            for name in pending:
                result[name] = include.group(1)
            pending.clear()
        elif line.startswith("SECTION"):
            pending.clear()
    return result


def read_map_catalog() -> list[dict[str, object]]:
    dimensions = parse_map_constants()
    tilesets = parse_tileset_names()
    gfx = parse_graphics_includes("GFX", "2bpp")
    blocksets = parse_graphics_includes("Block", "bst")
    layouts = parse_layout_sources()
    maps = []
    for path in sorted((ROOT / "data/maps/headers").glob("*.asm")):
        match = re.search(
            r"^\s*map_header\s+([A-Za-z0-9_]+),\s*([A-Za-z0-9_]+),\s*([A-Za-z0-9_]+)",
            path.read_text(),
            re.M,
        )
        if not match:
            continue
        label, map_constant, tileset_constant = match.groups()
        if map_constant not in dimensions:
            continue
        tileset_name = tilesets.get(tileset_constant)
        if not tileset_name:
            continue
        maps.append(
            {
                "label": label,
                "constant": map_constant,
                "tileset_constant": tileset_constant,
                "tileset_name": tileset_name,
                "width_blocks": dimensions[map_constant][0],
                "height_blocks": dimensions[map_constant][1],
                "header": path.relative_to(ROOT).as_posix(),
                "layout": layouts.get(label),
                "graphics": str(Path(gfx[tileset_name]).with_suffix(".png")) if tileset_name in gfx else None,
                "blockset": blocksets.get(tileset_name),
                "objects": f"data/maps/objects/{label}.asm",
            }
        )
    return maps


def normalize_name(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def parse_rgbds_number(value: str) -> int | None:
    value = value.strip()
    try:
        if value.startswith("$"):
            return int(value[1:], 16)
        if value.startswith("%"):
            return int(value[1:], 2)
        return int(value, 0)
    except ValueError:
        return None


def read_events(path: Path) -> tuple[dict[str, list[dict[str, object]]], list[str]]:
    result: dict[str, list[dict[str, object]]] = {"objects": [], "warps": [], "backgrounds": []}
    skipped: list[str] = []
    if not path.exists():
        return result, skipped
    key_for = {"object_event": "objects", "warp_event": "warps", "bg_event": "backgrounds"}
    for line_number, original in enumerate(path.read_text().splitlines(), 1):
        line = original.split(";", 1)[0].strip()
        match = re.match(r"(object_event|warp_event|bg_event)\s+(.+)$", line)
        if not match:
            continue
        kind, arg_text = match.groups()
        args = [arg.strip() for arg in arg_text.split(",")]
        if len(args) < 2:
            skipped.append(f"{path.relative_to(ROOT)}:{line_number}: malformed {kind}")
            continue
        x, y = parse_rgbds_number(args[0]), parse_rgbds_number(args[1])
        if x is None or y is None:
            skipped.append(f"{path.relative_to(ROOT)}:{line_number}: non-literal coordinates in {kind}")
            continue
        event: dict[str, object] = {"x": x, "y": y, "source_line": line_number}
        if kind == "object_event" and len(args) >= 5:
            event["movement"] = args[3]
            event["facing"] = args[4]
            if args[3] == "STAY":
                dx, dy = {"UP": (0, -1), "DOWN": (0, 1), "LEFT": (-1, 0), "RIGHT": (1, 0)}.get(
                    args[4], (0, 0)
                )
                if dx or dy:
                    event["approach_coordinate"] = [x + dx, y + dy]
        result[key_for[kind]].append(event)
    return result, skipped


def blend_pixel(image: bytearray, width: int, x: int, y: int, color: tuple[int, int, int], alpha: int = 190) -> None:
    if x < 0 or y < 0 or x >= width:
        return
    offset = (y * width + x) * 4
    inverse = 255 - alpha
    for channel in range(3):
        image[offset + channel] = (image[offset + channel] * inverse + color[channel] * alpha) // 255
    image[offset + 3] = 255


def draw_line(image: bytearray, width: int, height: int, x0: int, y0: int, x1: int, y1: int,
              color: tuple[int, int, int], alpha: int) -> None:
    if x0 == x1:
        if 0 <= x0 < width:
            for y in range(max(0, y0), min(height, y1)):
                blend_pixel(image, width, x0, y, color, alpha)
    elif y0 == y1 and 0 <= y0 < height:
        for x in range(max(0, x0), min(width, x1)):
            blend_pixel(image, width, x, y0, color, alpha)


def draw_overlays(image: bytearray, width: int, height: int, grid: bool,
                  events: dict[str, list[dict[str, object]]]) -> None:
    if grid:
        for x in range(0, width, EVENT_SIZE):
            block_edge = x % BLOCK_SIZE == 0
            draw_line(image, width, height, x, 0, x, height, (30, 110, 255) if block_edge else (60, 170, 255),
                      130 if block_edge else 65)
        for y in range(0, height, EVENT_SIZE):
            block_edge = y % BLOCK_SIZE == 0
            draw_line(image, width, height, 0, y, width, y, (30, 110, 255) if block_edge else (60, 170, 255),
                      130 if block_edge else 65)

    colors = {"objects": (255, 30, 80), "warps": (0, 220, 255), "backgrounds": (255, 220, 0)}
    for kind, records in events.items():
        for event in records:
            cx = int(event["x"]) * EVENT_SIZE + EVENT_SIZE // 2
            cy = int(event["y"]) * EVENT_SIZE + EVENT_SIZE // 2
            color = colors[kind]
            for delta in range(-4, 5):
                blend_pixel(image, width, cx + delta, cy, color)
                if 0 <= cy + delta < height:
                    blend_pixel(image, width, cx, cy + delta, color)

    for event in events["objects"]:
        approach = event.get("approach_coordinate")
        if not approach:
            continue
        cx = int(approach[0]) * EVENT_SIZE + EVENT_SIZE // 2
        cy = int(approach[1]) * EVENT_SIZE + EVENT_SIZE // 2
        for delta in range(-3, 4):
            blend_pixel(image, width, cx + delta, cy, (0, 255, 80))
            if 0 <= cy + delta < height:
                blend_pixel(image, width, cx, cy + delta, (0, 255, 80))


def upscale_rgba(image: bytearray, width: int, height: int, scale: int) -> tuple[bytearray, int, int]:
    if scale == 1:
        return image, width, height
    out_width = width * scale
    out = bytearray(out_width * height * scale * 4)
    out_row_bytes = out_width * 4
    for y in range(height):
        row = image[y * width * 4 : (y + 1) * width * 4]
        expanded = bytearray(out_row_bytes)
        cursor = 0
        for x in range(width):
            pixel = row[x * 4 : x * 4 + 4]
            expanded[cursor : cursor + 4 * scale] = pixel * scale
            cursor += 4 * scale
        for repeat in range(scale):
            start = ((y * scale + repeat) * out_width) * 4
            out[start : start + out_row_bytes] = expanded
    return out, out_width, height * scale


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", binascii.crc32(kind + payload) & 0xFFFFFFFF)


def write_png(path: Path, image: bytearray, width: int, height: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    compressor = zlib.compressobj(level=6)
    compressed = bytearray()
    stride = width * 4
    for y in range(height):
        compressed.extend(compressor.compress(b"\0" + image[y * stride : (y + 1) * stride]))
    compressed.extend(compressor.flush())
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", header)
        + png_chunk(b"IDAT", bytes(compressed))
        + png_chunk(b"IEND", b"")
    )


def render_map(map_info: dict[str, object], output: Path, scale: int, grid: bool, show_events: bool) -> dict[str, object]:
    missing = [key for key in ("layout", "graphics", "blockset") if not map_info.get(key)]
    if missing:
        raise ValueError(f"could not resolve {', '.join(missing)} for map {map_info['label']}")

    layout_path = ROOT / str(map_info["layout"])
    graphics_path = ROOT / str(map_info["graphics"])
    blockset_path = ROOT / str(map_info["blockset"])
    width_blocks, height_blocks = int(map_info["width_blocks"]), int(map_info["height_blocks"])
    layout = layout_path.read_bytes()
    if width_blocks <= 0 or len(layout) % width_blocks:
        raise ValueError(f"{layout_path.relative_to(ROOT)} size cannot be divided into rows of {width_blocks} blocks")
    layout_height = len(layout) // width_blocks
    warnings: list[str] = []
    if layout_height != height_blocks:
        warnings.append(
            f"layout has {width_blocks}x{layout_height} blocks; map_const declares "
            f"{width_blocks}x{height_blocks}"
        )
    blockset = blockset_path.read_bytes()
    if len(blockset) % 16:
        raise ValueError(f"{blockset_path.relative_to(ROOT)} size is not a multiple of 16 bytes")
    block_count = len(blockset) // 16  # each map block is a 4x4 array of tile IDs
    if any(block >= block_count for block in layout):
        bad = max(layout)
        raise ValueError(f"map uses block {bad}, but the blockset contains only {block_count} blocks")

    atlas_width, atlas_height, atlas_rows = parse_png_2bit_grayscale(graphics_path)
    atlas_columns = atlas_width // TILE_SIZE
    atlas_tile_count = atlas_columns * (atlas_height // TILE_SIZE)
    used_blocks = {block * 16 + i for block in layout for i in range(16)}
    used_tiles = {blockset[index] & 0x7F for index in used_blocks}
    missing_tiles = sorted(tile_id for tile_id in used_tiles if tile_id >= atlas_tile_count)
    if missing_tiles:
        warnings.append(
            "used block data references tile indices absent from the source PNG; "
            "those tiles are rendered as a magenta checker: "
            + ", ".join(f"0x{tile:02x}" for tile in missing_tiles)
        )

    pixel_width = width_blocks * BLOCK_SIZE
    pixel_height = layout_height * BLOCK_SIZE
    image = bytearray(pixel_width * pixel_height * 4)
    shades = [(v * 85, v * 85, v * 85, 255) for v in range(4)]
    for block_y in range(layout_height):
        for block_x in range(width_blocks):
            block_id = layout[block_y * width_blocks + block_x]
            block_offset = block_id * 16
            for local_tile_y in range(4):
                for local_tile_x in range(4):
                    # The top bit is the Game Boy's signed tile-address selector;
                    # the source PNG atlas index is the low seven bits.
                    tile_id = blockset[block_offset + local_tile_y * 4 + local_tile_x] & 0x7F
                    dest_x = block_x * BLOCK_SIZE + local_tile_x * TILE_SIZE
                    dest_y = block_y * BLOCK_SIZE + local_tile_y * TILE_SIZE
                    if tile_id in missing_tiles:
                        for py in range(TILE_SIZE):
                            for px in range(TILE_SIZE):
                                color = (255, 0, 255, 255) if (px // 2 + py // 2) % 2 else (24, 0, 24, 255)
                                pos = ((dest_y + py) * pixel_width + dest_x + px) * 4
                                image[pos : pos + 4] = bytes(color)
                    else:
                        tile_x = (tile_id % atlas_columns) * TILE_SIZE
                        tile_y = (tile_id // atlas_columns) * TILE_SIZE
                        for py in range(TILE_SIZE):
                            dest_row = ((dest_y + py) * pixel_width + dest_x) * 4
                            src_row = atlas_rows[tile_y + py]
                            for px in range(TILE_SIZE):
                                shade = shades[src_row[tile_x + px]]
                                pos = dest_row + px * 4
                                image[pos : pos + 4] = bytes(shade)

    events: dict[str, list[dict[str, object]]] = {"objects": [], "warps": [], "backgrounds": []}
    skipped_events: list[str] = []
    if show_events:
        events, skipped_events = read_events(ROOT / str(map_info["objects"]))
        draw_overlays(image, pixel_width, pixel_height, grid, events)
    elif grid:
        draw_overlays(image, pixel_width, pixel_height, True, events)

    image, out_width, out_height = upscale_rgba(image, pixel_width, pixel_height, scale)
    write_png(output, image, out_width, out_height)

    return {
        "map": map_info["label"],
        "map_constant": map_info["constant"],
        "tileset": map_info["tileset_constant"],
        "dimensions_blocks": [width_blocks, height_blocks],
        "layout_dimensions_blocks": [width_blocks, layout_height],
        "dimensions_pixels": [pixel_width, pixel_height],
        "event_grid_dimensions": [width_blocks * EVENTS_PER_BLOCK, layout_height * EVENTS_PER_BLOCK],
        "block_size_pixels": BLOCK_SIZE,
        "event_coordinate_size_pixels": EVENT_SIZE,
        "files": {
            "header": map_info["header"],
            "layout": str(map_info["layout"]),
            "blockset": str(map_info["blockset"]),
            "tileset_image": str(map_info["graphics"]),
            "object_events": map_info["objects"] if show_events else None,
        },
        "event_markers": events if show_events else None,
        "unparsed_events": skipped_events,
        "warnings": warnings,
        "output": str(output.resolve()),
        "scale": scale,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("map", help="map label (for example VermilionDock) or map constant (VERMILION_DOCK)")
    parser.add_argument("--output", required=True, type=Path, help="destination PNG path")
    parser.add_argument("--scale", type=int, default=2, choices=range(1, 9), help="nearest-neighbor scale, 1-8 (default: 2)")
    parser.add_argument("--grid", action="store_true", help="overlay event-coordinate and block-coordinate grids")
    parser.add_argument("--events", action="store_true", help="overlay object, warp, and background event positions")
    args = parser.parse_args()

    try:
        maps = read_map_catalog()
        key = normalize_name(args.map)
        found = [m for m in maps if normalize_name(str(m["label"])) == key or normalize_name(str(m["constant"])) == key]
        if len(found) != 1:
            available = ", ".join(str(m["label"]) for m in maps)
            raise ValueError(f"map '{args.map}' resolved to {len(found)} entries; available labels: {available}")
        report = render_map(found[0], args.output, args.scale, args.grid, args.events)
    except (OSError, ValueError, zlib.error) as exc:
        print(f"render_map: {exc}", file=sys.stderr)
        return 2

    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
