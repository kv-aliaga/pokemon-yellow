#!/usr/bin/env python3
"""Extract factual Yellow encounter data without changing the game."""

import json
import re
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/encounters/facts"
WALK_WEIGHTS = [51, 51, 39, 25, 25, 25, 13, 13, 11, 3]


def read(path):
    return (ROOT / path).read_text()


def write(name, value):
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def parse_species():
    dex = re.findall(r"^\s*const DEX_(\w+)\s*;\s*(\d+)", read("constants/pokedex_constants.asm"), re.M)
    assert len(dex) == 151
    constants = dict(re.findall(r"^\s*const (\w+)\s*;\s*\$([\dA-F]{2})", read("constants/pokemon_constants.asm"), re.M))
    names = re.findall(r'^\s*dname "([^"]+)"', read("data/pokemon/names.asm"), re.M)
    ordered = re.findall(r"^\s*db (DEX_\w+|0)\b", read("data/pokemon/dex_order.asm"), re.M)
    assert len(ordered) == len(names)
    name_by_dex = {token[4:]: names[i] for i, token in enumerate(ordered) if token != "0"}
    evo_text = read("data/pokemon/evos_moves.asm")
    evo_sections = dict(re.findall(r"^(\w+)EvosMoves:\n(.*?)(?=^\w+EvosMoves:|\Z)", evo_text, re.M | re.S))
    species = []
    for constant, number in dex:
        number = int(number)
        path = f"data/pokemon/base_stats/{constant.lower().replace('_', '')}.asm"
        stat = read(path)
        types = re.search(r"^\s*db (\w+), (\w+) ; type", stat, re.M)
        assert types, path
        label = "".join(word.capitalize() for word in constant.lower().split("_"))
        if constant == "MR_MIME": label = "MrMime"
        if constant == "FARFETCHD": label = "Farfetchd"
        if constant == "NIDORAN_F": label = "NidoranF"
        if constant == "NIDORAN_M": label = "NidoranM"
        section = evo_sections[label].split("; Learnset", 1)[0]
        evolutions = []
        for kind, rest in re.findall(r"^\s*db EVOLVE_(LEVEL|ITEM|TRADE), (.+)$", section, re.M):
            parts = [part.strip() for part in rest.split(",")]
            target = parts[-1]
            evolution = {"to_species_id": next(int(n) for c, n in dex if c == target), "method": kind.lower()}
            if kind == "LEVEL": evolution["level"] = int(parts[0])
            if kind == "ITEM":
                evolution["item"] = parts[0]
                evolution["minimum_level"] = int(parts[1])
            if kind == "TRADE": evolution["minimum_level"] = int(parts[0])
            evolutions.append(evolution)
        species.append({
            "id": number, "constant": constant, "internal_id": int(constants[constant], 16),
            "name": name_by_dex[constant], "types": list(dict.fromkeys(types.groups())),
            "evolutions": evolutions, "evolution_line_ids": [],
            "current_sources": [], "proposed_sources": [],
            "first_obtainable_milestone": None, "access_requirements": [],
            "alternative_route": None, "decision": "pending", "rationale": None,
            "review_status": "factual_inventory", "source_notes": [
                "constants/pokedex_constants.asm", "constants/pokemon_constants.asm",
                path, "data/pokemon/evos_moves.asm"
            ]
        })
    adjacency = {entry["id"]: set() for entry in species}
    for entry in species:
        for evolution in entry["evolutions"]:
            target = evolution["to_species_id"]
            adjacency[entry["id"]].add(target)
            adjacency[target].add(entry["id"])
    for entry in species:
        seen, pending = set(), [entry["id"]]
        while pending:
            current = pending.pop()
            if current in seen: continue
            seen.add(current)
            pending.extend(adjacency[current] - seen)
        entry["evolution_line_ids"] = sorted(seen)
    return species


def location(locations, constant):
    key = constant.lower()
    if key not in locations:
        locations[key] = {"id": key, "map_constant": constant, "access_milestone": None,
                          "access_requirements": [], "environment": None, "tables": []}
    return locations[key]


def add_table(locations, sources, map_constant, method, rate, slots, source_file, denominator, notes=None):
    loc = location(locations, map_constant)
    table_id = f"{loc['id']}.{method}"
    table = {"id": table_id, "method": method, "encounter_rate": rate,
             "conditional_denominator": denominator, "slots": slots,
             "source_notes": [source_file] + (notes or [])}
    loc["tables"].append(table)
    for species_id in sorted({slot["species_id"] for slot in slots}):
        sources[species_id].add(table_id)


def parse_wild(locations, sources, ids):
    map_constants = re.findall(r"^\s*map_const ([A-Z0-9_]+),", read("constants/map_constants.asm"), re.M)
    by_compact_name = {name.replace("_", ""): name for name in map_constants}
    for path in sorted((ROOT / "data/wild/maps").glob("*.asm")):
        if path.stem == "nothing": continue
        text = path.read_text()
        constant = by_compact_name[path.stem.upper()]
        for method, start, end in (("walk", "grass", "grass"), ("surf", "water", "water")):
            match = re.search(rf"def_{start}_wildmons (\d+)(.*?)(?:end_{end}_wildmons)", text, re.S)
            assert match, path
            rate = int(match.group(1))
            entries = re.findall(r"^\s*db\s+(\d+),\s*(\w+)", match.group(2), re.M)
            if rate == 0:
                assert not entries, path
                continue
            assert len(entries) == 10, (path, method, entries)
            slots = [{"slot": i, "species_id": ids[name], "level": int(level), "weight_256": WALK_WEIGHTS[i]}
                     for i, (level, name) in enumerate(entries)]
            add_table(locations, sources, constant, method, rate, slots,
                      str(path.relative_to(ROOT)), 256, ["data/wild/probabilities.asm"])


def parse_rods(locations, sources, ids):
    # The Old Rod always produces level 5 Magikarp after FishingInit succeeds.
    # No map list is encoded for Old/Good Rod; those methods are represented as global templates.
    rods = []
    rods.append({"id": "old_rod.global", "method": "old_rod", "scope": "any_fishable_water",
                 "conditional_denominator": 1, "slots": [{"slot": 0, "species_id": ids["MAGIKARP"], "level": 5, "weight": 1}],
                 "bite_chance": {"numerator": 1, "denominator": 1},
                 "source_notes": ["engine/items/item_effects.asm"]})
    good_entries = re.findall(r"^\s*db (\d+), (\w+)", read("data/wild/good_rod.asm"), re.M)
    assert len(good_entries) == 2
    rods.append({"id": "good_rod.global", "method": "good_rod", "scope": "any_fishable_water",
                 "conditional_denominator": 2,
                 "slots": [{"slot": i, "species_id": ids[name], "level": int(level), "weight": 1}
                           for i, (level, name) in enumerate(good_entries)],
                 "bite_chance": {"numerator": 1, "denominator": 3},
                 "source_notes": ["data/wild/good_rod.asm", "engine/items/item_effects.asm"],
                 "source_warning": "Good Rod retries half of even random outcomes; 1/3 bite chance assumes uniform independent Random results."})
    for rod in rods:
        for slot in rod["slots"]: sources[slot["species_id"]].add(rod["id"])

    text = read("data/wild/super_rod.asm")
    for line in re.findall(r"^\s*db ([A-Z_0-9]+, .+)$", text, re.M):
        parts = [part.strip() for part in line.split(",")]
        if len(parts) != 9: continue
        map_constant = parts[0]
        # percent macro expands to * $ff / 100; random bytes span 0..255.
        thresholds = [40 * 255 // 100, 70 * 255 // 100, 90 * 255 // 100, 256]
        weights = [thresholds[0], thresholds[1]-thresholds[0], thresholds[2]-thresholds[1], 256-thresholds[2]]
        slots = [{"slot": i, "species_id": ids[parts[1 + 2*i]], "level": int(parts[2 + 2*i]), "weight_256": weights[i]}
                 for i in range(4)]
        add_table(locations, sources, map_constant, "super_rod", None, slots,
                  "data/wild/super_rod.asm", 256,
                  ["engine/items/super_rod.asm", "macros/data.asm"])
        locations[map_constant.lower()]["tables"][-1]["bite_chance"] = {"numerator": 1, "denominator": 2}
    return rods


def main():
    species = parse_species()
    ids = {entry["constant"]: entry["id"] for entry in species}
    locations, sources = {}, defaultdict(set)
    parse_wild(locations, sources, ids)
    rods = parse_rods(locations, sources, ids)
    for entry in species:
        entry["current_sources"] = sorted(sources[entry["id"]])
    write("species.json", {"species": species})
    write("locations.json", {"locations": sorted(locations.values(), key=lambda item: item["id"]),
                             "global_rod_tables": rods})
    print(f"Extracted {len(species)} species, {len(locations)} locations, "
          f"{sum(len(loc['tables']) for loc in locations.values())} local tables")


if __name__ == "__main__":
    main()
