#!/usr/bin/env python3
"""Refresh derived earliest possible milestones without changing design decisions."""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/encounters"
STONE_MILESTONES = {
    "MOON_STONE": "after_brock",
    "FIRE_STONE": "celadon_lavender",
    "THUNDER_STONE": "celadon_lavender",
    "WATER_STONE": "celadon_lavender",
    "LEAF_STONE": "celadon_lavender",
}


def load(name):
    return json.loads((BASE / f"{name}.json").read_text())


def derive(species, locations, global_rod_tables, acquisition, milestones):
    order = {item["id"]: item["order"] for item in milestones}
    sources = {}
    for location in locations:
        for version, tables in (("current", location["tables"]),
                                ("proposed", location.get("proposed_tables", []))):
            for table in tables:
                milestone = table.get("access_milestone", location["access_milestone"])
                if table["method"] == "super_rod":
                    milestone = max((milestone, "fuchsia"), key=order.get)
                sources[table["id"]] = {
                    "milestone": milestone, "version": version,
                    "requirements": location["access_requirements"] + table.get("access_requirements", []),
                    "alternative_route": location.get("alternative_route"),
                    "species": {slot["species_id"] for slot in table["slots"]},
                }
    for table in global_rod_tables:
        sources[table["id"]] = {
            "milestone": table["access_milestone"], "version": "current",
            "requirements": table["access_requirements"], "alternative_route": None,
            "species": {slot["species_id"] for slot in table["slots"]},
        }
    for item in acquisition:
        if item.get("obtainable", True) is False:
            continue
        received = {item.get("evolves_on_receipt_to_species_id", item["species_id"])}
        sources[item["id"]] = {
            "milestone": item["access_milestone"], "version": item["version"],
            "requirements": item["requirements"], "alternative_route": item.get("alternative_route"),
            "species": received, "required_species_id": item.get("required_species_id"),
        }

    parents = {item["id"]: [] for item in species}
    for item in species:
        for evolution in item["evolutions"]:
            parents[evolution["to_species_id"]].append((item["id"], evolution))

    def first_routes(include_proposed, allow_external_trade):
        first = {}
        for _ in range(len(species) + 1):
            changed = False
            for item in species:
                options = [first[item["id"]]] if item["id"] in first else []
                refs = item["current_sources"] + (item["proposed_sources"] if include_proposed else [])
                for ref in refs:
                    source = sources.get(ref)
                    if not source or source["milestone"] not in order or item["id"] not in source["species"]:
                        continue
                    required = source.get("required_species_id")
                    if required is not None and required not in first:
                        continue
                    prerequisite = first.get(required)
                    milestone = source["milestone"]
                    requirements = list(source["requirements"])
                    if prerequisite:
                        milestone = max((milestone, prerequisite["milestone"]), key=order.get)
                        requirements = list(dict.fromkeys(requirements + prerequisite["requirements"]))
                    options.append({"milestone": milestone, "source_id": ref, "mode": "direct",
                                    "requirements": requirements,
                                    "alternative_route": source["alternative_route"],
                                    "external_trade_required": (prerequisite["external_trade_required"]
                                                                if prerequisite else False)})
                for parent_id, evolution in parents[item["id"]]:
                    if parent_id not in first:
                        continue
                    if evolution["method"] == "trade" and not allow_external_trade:
                        continue
                    parent = first[parent_id]
                    milestone = parent["milestone"]
                    requirements = list(parent["requirements"])
                    if evolution["method"] == "level":
                        requirements.append(f"treinar até o nível {evolution['level']}")
                    elif evolution["method"] == "item":
                        milestone = max((milestone, STONE_MILESTONES[evolution["item"]]), key=order.get)
                        requirements.append(evolution["item"])
                    else:
                        requirements.append("troca externa para evolução")
                    options.append({"milestone": milestone, "source_id": f"evolution_from_{parent_id}",
                                    "mode": evolution["method"], "requirements": requirements,
                                    "alternative_route": parent["alternative_route"],
                                    "external_trade_required": (parent["external_trade_required"] or
                                                                evolution["method"] == "trade")})
                if options:
                    choice = min(options, key=lambda x: (order[x["milestone"]], x["external_trade_required"],
                                                         len(x["requirements"]), x["source_id"]))
                    if first.get(item["id"]) != choice:
                        first[item["id"]] = choice
                        changed = True
            if not changed:
                return first
        raise ValueError("Obtainability dependencies did not converge")

    current, planned = first_routes(False, True), first_routes(True, True)
    current_in_game, planned_in_game = first_routes(False, False), first_routes(True, False)
    result = {}
    for item in species:
        current_route, planned_route = current.get(item["id"]), planned.get(item["id"])
        result[item["id"]] = {
            "first_obtainable_milestone": current_route["milestone"] if current_route else None,
            "current_first_obtainable_milestone": current_route["milestone"] if current_route else None,
            "first_obtainable_basis": ({"source_id": current_route["source_id"], "mode": current_route["mode"]}
                                       if current_route else None),
            "access_requirements": current_route["requirements"] if current_route else ["fonte atual não verificada"],
            "alternative_route": current_route["alternative_route"] if current_route else None,
            "current_obtainability_status": (("external_trade_first" if current_route["external_trade_required"] else
                                               "direct_verified" if current_route["mode"] == "direct" else
                                               "evolution_possible") if current_route else "no_verified_route"),
            "current_first_in_game_milestone": (current_in_game[item["id"]]["milestone"]
                                                if item["id"] in current_in_game else None),
            "current_first_in_game_basis": ({"source_id": current_in_game[item["id"]]["source_id"],
                                             "mode": current_in_game[item["id"]]["mode"]}
                                            if item["id"] in current_in_game else None),
            "proposed_first_obtainable_milestone": planned_route["milestone"] if planned_route else None,
            "proposed_first_basis": ({"source_id": planned_route["source_id"], "mode": planned_route["mode"]}
                                     if planned_route else None),
            "proposed_obtainability_status": (("direct_draft" if planned_route["mode"] == "direct" and
                                                planned_route["source_id"] in item["proposed_sources"] else
                                                "current_or_evolution") if planned_route else "pending"),
            "proposed_access_requirements": (planned_route["requirements"] if planned_route else
                                             ["fonte proposta pendente"]),
            "proposed_first_in_game_milestone": (planned_in_game[item["id"]]["milestone"]
                                                 if item["id"] in planned_in_game else None),
            "proposed_first_in_game_basis": ({"source_id": planned_in_game[item["id"]]["source_id"],
                                              "mode": planned_in_game[item["id"]]["mode"]}
                                             if item["id"] in planned_in_game else None),
        }
    return result


def main():
    data = load("species")
    locations = load("locations")
    derived = derive(data["species"], locations["locations"], locations["global_rod_tables"],
                     load("acquisition")["sources"], load("balance-targets")["milestones"])
    for item in data["species"]:
        item.update(derived[item["id"]])
    (BASE / "species.json").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    print(f"Recomputed milestones for {len(data['species'])} species")


if __name__ == "__main__":
    main()
