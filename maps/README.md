# Map layout reference

Files in this directory are binary map layouts. Each layout uses block IDs; the map's dimensions and tileset are defined elsewhere in the source tree.

## Render a preview

Use the standard-library-only renderer from the repository root. It writes a PNG and emits a JSON report for agent inspection:

```sh
python3 tools/render_map.py VermilionDock --output /tmp/VermilionDock.png --grid --events
```

Use either the map label (`VermilionDock`) or constant (`VERMILION_DOCK`). The report lists the resolved header, layout, blockset, tileset image, declared and actual layout dimensions, parsed events, and warnings. If a block used by the map has no corresponding tile in the source PNG, it appears as a magenta checker and its ID is reported. `--grid` shows event-coordinate subdivisions and block edges; `--events` overlays object, warp, and background event positions, plus candidate approach cells for stationary objects with a literal facing direction. Candidate cells are green; they are not a reachability verdict. The renderer is a visual aid: it does not simulate collision, movement, or event scripts.

## Trace a map to its graphics

1. Find the map's width and height in `constants/map_constants.asm`.
2. Open its header in `data/maps/headers/` to identify the tileset.
3. Read the corresponding `.blk` file here using the declared map dimensions to locate block IDs.
4. Look up that tileset in `data/tilesets/tileset_headers.asm`. The tileset entry connects collision data, a blockset, and graphics.
5. Follow the blockset and graphics includes in `gfx/tilesets.asm` to `gfx/blocksets/` and `gfx/tilesets/`. Inspect or render the selected blocks against the tileset image to see the composed map art.

Several map labels can share one `.blk`: follow the matching `*_Blocks` label in `maps.asm` to its `INCBIN` instead of assuming the layout filename matches the map name. For example, `MrPsychicsHouse` uses `maps/ViridianNicknameHouse.blk`.

For example, `VermilionDock` has its dimensions in `constants/map_constants.asm`, uses `SHIP_PORT` in `data/maps/headers/VermilionDock.asm`, and its layout is `maps/VermilionDock.blk`. The `ShipPort` tileset entry and includes lead to `gfx/blocksets/ship_port.bst` and `gfx/tilesets/ship_port.2bpp`.

## Check interaction and collision separately

- Map object positions, warps, and background events are in `data/maps/objects/`; map behavior is in the matching file under `scripts/`.
- `map_const` dimensions and `.blk` coordinates count blocks. One block contains a 4×4 arrangement of 8×8 tiles, so it renders as 32×32 pixels. `object_event`, `warp_event`, and `bg_event` coordinates use a grid with two positions per block on each axis; the rendered event grid is twice the block width and height. For event cell `(x, y)`, the block is `(x // 2, y // 2)` and its 2×2 graphics-tile area starts at local tile offset `(2 * (x % 2), 2 * (y % 2))`. For example, `(21, 2)` maps to block `(10, 1)`, local tile offset `(2, 0)`, and pixel origin `(336, 32)`. `object_event` adds four to each coordinate when encoding the object into the padded runtime map buffer; use the unshifted source coordinates for map previews. `warp_event` and `bg_event` are written directly in their source coordinates.
- Use `layout_dimensions_blocks` in the renderer report for the bytes actually present in `.blk`. Some source maps intentionally differ from `map_const`; `constants/map_constants.asm` documents `UndergroundPathNorthSouth` as a 4×23 layout although its map constant is 4×24. Treat the source comment and file length as evidence for this exception.
- For a stationary object, the facing direction identifies its front interaction square: `UP` means stand one event cell above it, `DOWN` one below, and `LEFT`/`RIGHT` one cell to the corresponding side. The renderer reports this approach coordinate when the object uses `STAY` with a literal direction.
- Project-specific example: Vermilion Dock's truck is visible map artwork. Mew has no visible sprite; a `bg_event` in `data/maps/objects/VermilionDock.asm` at `(21, 1)` handles interaction on the truck, while an invisible `SPRITE_NONE` trainer object at the same coordinate stores encounter data. The reachable approach cell is `(21, 2)`. Verify both the background layout for the truck art and the object/script events for the interaction. Seeing the truck alone does not establish that the trigger works, and searching only for a truck sprite/object can miss the background artwork.
- To check reachability, start at a real warp or map entrance and trace every step to the candidate approach square. For each event cell `(x, y)`, the `.blk` block is `(x // 2, y // 2)`; select that block ID, then use the corresponding 16-byte blockset entry. The four 8×8 graphics tile IDs for the event cell begin at local tile offset `(2 * (x % 2), 2 * (y % 2))`. Check the engine's collision result for each destination cell and the elevation-sensitive pair between each source/destination step. The passable tile lists are in `data/tilesets/collision_tile_ids.asm`, and pair restrictions are in `data/tilesets/pair_collision_tile_ids.asm`; relevant engine paths include `engine/gfx/sprite_oam.asm` (`IsTilePassable`) and `home/overworld.asm` (`CollisionCheckOnLand`, `CheckForJumpingAndTilePairCollisions`). Also account for sprite collisions, ledges, water/Surf requirements, warps, and script conditions. Confirm the player can stand on the exact approach square, face the object, and trigger its interaction in an emulator or on hardware when runtime verification matters. A rendered image, a green candidate marker, or a passable destination tile alone does not prove the route is reachable.
- A visible map feature can be made from background blocks without a named sprite or object event. For the evidence standard and general asset-presence checks, see the repository-root [`AGENTS.md`](../AGENTS.md).
