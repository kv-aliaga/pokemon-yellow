# V1 encounter implementation notes

This note records how the approved catalog maps to the ROM source and which proposed acquisition fields were resolved during implementation. It does not mark the Trello card complete.

## Wild encounter tables

All 20 entries in `docs/encounters/locations.json` are represented in the ROM. The 18 walking and Surf tables use their planned species and levels in the existing ten slots. The two local Super Rod tables update only the four results already selected by the map-based fishing routine. The routine's 40/30/20/10 result thresholds and global Old Rod/Good Rod behavior remain unchanged.

Affected data files are `data/wild/maps/Route24.asm`, `Route3.asm`, `Route6.asm`, `ViridianForest.asm`, `Route7.asm`, `Route5.asm`, `Route8.asm`, `Route10.asm`, `RockTunnelB1F.asm`, `VictoryRoad2F.asm`, `SeafoamIslandsB3F.asm`, `SeafoamIslandsB4F.asm`, `PowerPlant.asm`, `Route17.asm`, `PokemonMansionB1F.asm`, `Route2.asm`, and `Route19.asm`, plus `data/wild/super_rod.asm`.

### Progression map

| Progression point | Tables and access condition |
| --- | --- |
| Early campaign, before Koga | `viridian-forest-walk` (Viridian Forest); `route-2-walk` (Route 2, after Cut opens the return path); `route-3-walk` (Route 3); `route-24-walk` (Route 24); `route-5-walk` (Route 5); `route-6-walk` (Route 6); `route-7-walk` (Route 7); `route-8-walk` (Route 8); `route-10-walk` (Route 10); `route-17-walk` (Route 17, Bicycle); `rock-tunnel-b1f-walk` (Rock Tunnel, reached from Route 9 after Lt. Surge). |
| After Surf is usable (Soul Badge) | `golduck-surf` (Route 6); `route-19-surf` (Route 19); `power-plant-walk` (Power Plant, Surf access); `seafoam-b3f-walk` and `seafoam-b4f-walk` (Seafoam Islands, Surf and Strength); `pokemon-mansion-b1f-walk` (Pokémon Mansion, Surf to Cinnabar). These tables are available in the campaign and do not require the Elite Four. |
| Super Rod access | `route-17-super-rod` (Route 17) and `pallet-town-any-rod` (Pallet Town) use the existing local Super Rod selector. The rod itself comes from the Fuchsia Fisherman; Fuchsia is reachable by Cycling Road before the League. |
| Late campaign | `victory-road-walk` (Victory Road, after all eight badges and Strength). The rare Hitmonlee and Hitmonchan slots each have weight 13/256. |

The table is about map/method access, not a guarantee that every player will choose the same route. Field Surf remains gated by the existing Soul Badge requirement.

## Acquisition choices

### NPC trades

The four approved exchanges are implemented as a cycle at the user-selected locations:

| Location | Give | Receive | Level | Nickname |
| --- | --- | --- | ---: | --- |
| Lavender Town | Machoke | Haunter | 25 | SHADE |
| Saffron City | Graveler | Kadabra | 25 | ORACLE |
| Celadon City | Kadabra | Machoke | 25 | ATLAS |
| Diglett's Cave | Haunter | Graveler | 20 | GRANITE |

The three city trades use level 25, consistent with the pre-Koga trainer progression around those locations. Diglett's Cave uses level 20, its observed walking Q3 and the upper end of its local typical range (Q1–Q3 17–20 in `level-insights.json`). The names use the game's supported uppercase English character set. The normal NPC trade level inheritance remains in effect for all existing trades; only these four receive fixed levels.

### Ditto and fossils

- The Rocket Hideout B4F Ditto is level 24, anchored to the planned level 24 Ditto encounter in Pokémon Mansion B1F. Its interaction is enabled after Giovanni is defeated.
- The Pewter Museum Super Nerd rematch unlocks after Lt. Surge. If the player chose Helix Fossil, the opposing team includes Kabuto and the reward is Dome Fossil. If the player chose Dome Fossil, the team includes Omanyte and the reward is Helix Fossil. The two fossil team members are level 25, matching the post-Surge progression.
- The new Pewter revival station uses the existing level 30 fossil revival flow and shares its save state with Cinnabar. Old Amber can be processed in Pewter after the player obtains HM01/Cut. Cinnabar remains available as before.

### Legendary Pokémon and Mew

Articuno, Zapdos, Moltres, and Mewtwo keep their existing fixed levels and locations. After a complete Elite Four victory, each defeated encounter is re-enabled only when its Pokédex entry is still unowned. Mew follows the same capture check and reactivation rule, and its level is recalculated from the party as `min(100, highest party level + 5)`.

The Vermilion Dock map already draws the truck using block 3 at block coordinate (10, 0). The Mew object is placed at map coordinate (21, 2), the reachable ground immediately below the truck, using the existing Mew sprite. It is available as soon as the player can reach the dock and has no League prerequisite.

## Verification record

- JSON syntax checks passed for `locations.json` and `acquisition.json`.
- A source comparison matched the species and levels for all 20 planned tables.
- `git diff --check` passed.
- The official RGBDS v1.0.4 Linux toolchain was unpacked under `/tmp` and used to build both `pokeyellow.gbc` and `pokeyellow_debug.gbc` successfully. Assembly caught and led to fixes for packed trainer-event bit positions, toggle-object table alignment, and table-width placement.
- No emulator or test harness is installed in the environment, so in-game event behavior has not been exercised.

The card's verification status remains pending until gameplay verification is available. Mew is positioned beneath the truck already drawn in the Vermilion Dock map; gameplay interaction still needs manual verification in an emulator.

## Manual acceptance checklist (not executed)

These steps are for a later emulator or hardware run. They are test instructions, not evidence that the behaviors have passed.

1. **Wild tables:** from a save that can reach each map, walk/Surf or use the Super Rod in the locations listed above. In a debugger, inspect the selected encounter species and level against the ten slots in `locations.json`; for Route 17 and Pallet Town, sweep/test the existing selector's four result ranges (102, 76, 51, 27 outcomes per 256) and confirm only the local four results change. Confirm Route 6 and Route 19 Surf works only after the normal Soul Badge unlock, and Old/Good Rod outputs remain their global tables.
2. **Four trades:** at Lavender, Saffron, Celadon, and Diglett's Cave before Koga, try with no party Pokémon, with a wrong species, and with the required species. Confirm the offered Pokémon is not removed on a rejected/failed trade, then verify the requested receive species, chosen level, nickname, and the four-step cycle.
3. **Ditto:** defeat Giovanni, enter Rocket Hideout B4F, and interact with Ditto. Confirm it is absent before Giovanni, appears once afterward, and does not return after capture or defeat until the specified reactivation rule applies (Ditto has no reactivation requirement in this plan).
4. **Museum and fossils:** on separate saves, choose Helix and Dome in Mt. Moon; after Lt. Surge, rematch the Museum Super Nerd and verify the opposing Omanyte/Kabuto choice and opposite fossil reward. Fill the bag before the reward to verify retry behavior. Hand each fossil to Pewter and retrieve the revived level-30 Pokémon there; repeat the handoff and retrieval across Pewter/Cinnabar. Verify Old Amber revival at Pewter only after Cut and confirm Cinnabar remains functional.
5. **Four original legendaries:** for Articuno, Zapdos, Moltres, and Mewtwo, test separate saves where each is defeated without capture and where it is captured. Confirm defeat removes it, partial League progress/loss does not restore it, a complete Elite Four victory restores only unowned species, and captured species stay absent.
6. **Mew:** reach Vermilion Dock before the Elite Four and interact with Mew under the existing truck. Start the encounter with a low-level party and with a highest-level party above 95, and confirm the level is `highest + 5` then capped at 100. Test capture versus defeat, no reappearance before a complete Elite Four victory after defeat, and reappearance afterward only when unowned.
