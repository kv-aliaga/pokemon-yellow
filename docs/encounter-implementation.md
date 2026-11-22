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

Articuno, Zapdos, Moltres, and Mewtwo keep their existing fixed levels and locations. After a complete Elite Four victory, each defeated encounter is re-enabled only when its Pokédex entry is still unowned. Mew now uses the dock's approved hidden-event targets and a scripted wild battle, with no overworld Mew object.

The Vermilion Dock layout draws the truck as background art. The map has zero object events and zero background events; the two existing warps and S.S. Anne script remain. All four approved hidden-event targets call the same dock-local handler. The upper truck cells accept adjacent approaches; the two lower targets accept only north-facing A from `(20, 2)` and `(21, 2)`, preventing side-facing interaction with ground outside the truck. The handler checks availability and party count, displays the Mew text and cry through the normal text interpreter, then sets `wCurEnemyLevel` and `wCurOpponent = MEW`. Yellow's wild-battle path starts the battle. The map and `SHIP_PORT` collision data were not changed.

**Approved truck targeting baseline (user confirmation, 2026-11-22):** the four hidden-event targets remain exactly as approved: upper truck cells `(20, 0)` and `(21, 0)` can be selected from reachable adjacent approaches, including the upper sides; lower truck cells `(20, 1)` and `(21, 1)` respond only to north-facing A from standing cells `(20, 2)` and `(21, 2)`. The lower side ground at `(19, 1)` and `(22, 1)` does not trigger. The earlier Trello wording that limited Mew to two front targets and rejected all side approaches was superseded by this confirmation. Source inspection and the user's earlier `TODO` observation support the targeting decision; the new battle flow still needs gameplay verification.

`EVENT_BEAT_MEW` retains its existing bit `$9E1` for save compatibility. It begins clear on a new save. The dock checks both this flag and Mew's Pokédex owned bit before any text; the empty-party branch displays a fallback without setting the flag. The highest current party level is scanned before each battle, excluding boxed Pokémon, and Mew receives `min(100, highest party level + 5)`. The flag is set when the valid encounter commits to battle, so capture, defeat, running, and player blackout leave Mew unavailable even after saving and resetting. Only the completed Hall of Fame script resets the flag, and only if Mew's Pokédex owned bit is clear; there is no Mew toggleable object to show. The owned-bit guard also blocks a recapture on older saves whose event flag is clear.

The earlier SameBoy report of cry without battle, a warp, and Pikachu changes remains historical context. The old trainer-object path is absent and this implementation does not touch warp or follower code. The exact cause of the earlier symptoms was not proven in runtime; the new behavior still needs in-game regression checks.

## Verification record

- JSON syntax checks passed for `locations.json` and `acquisition.json`.
- A source comparison matched the species and levels for all 20 planned tables.
- `git diff --check` passed.
- An earlier V1 candidate built both ROMs with RGBDS 1.0.4. That build included the Mew encounter and is superseded by the removal below.
- The earlier SameBoy attempt used copies of the ROM and SRAM but exposed only a black display; it did not verify in-game behavior.

On 2026-11-22, the truck `TODO` interaction was built from dirty worktree `master` based on HEAD `5b7044f09f245d25cd0b5e18c573f1b4a39ef8d1` using RGBDS 1.0.4:

- `pokeyellow.gbc`: build succeeded; SHA-256 `d29db021e9ff5d279fbff8d89841794c75f8dcdc782cea154842acc52624318d`.
- `pokeyellow_debug.gbc`: build succeeded; SHA-256 `f75738e36d7c16e74f0a5a289142b49b7ffb2123f3ce215bfe3a6fa2d9d11dfb`.
- The map renderer reported a 14×6 `SHIP_PORT` layout with zero object events, zero background events, two warps, and no warnings. The four hidden-event coordinates were inspected separately in Yellow source; the renderer does not overlay them.

No emulator or hardware gameplay check was performed on these ROMs. To verify in-game: use a copy of SRAM, reach Vermilion Dock, press A facing north from `(20, 2)` and `(21, 2)`, then press A facing the upper truck cells from reachable side cells. Each truck interaction should show `TODO` once with no Mew cry or battle. Press A sideways toward the lower-row ground from `(19, 1)` and `(22, 1)` and confirm no text; also check unrelated cells. Confirm the two warps and S.S. Anne travel still function. The original SRAM was not used for this build or map inspection.

On 2026-11-22, the first Mew battle implementation was built from the same dirty `master` worktree (HEAD `5b7044f09f245d25cd0b5e18c573f1b4a39ef8d1`) with RGBDS 1.0.4. Both ROMs assembled, linked, and passed `rgbfix`; its hashes are recorded below. This build predates the transformed-capture fix described next. The `TODO` ROM hashes above refer only to the older placeholder build. The Yellow-specific source trace covered `home/hidden_events.asm`, `engine/overworld/hidden_events.asm`, `home/overworld.asm`, `scripts/Route12.asm`, `engine/battle/init_battle.asm`, `engine/battle/end_of_battle.asm`, the dock script, and the Hall of Fame script. The map was rendered again from the `SHIP_PORT` chain: 14×6 blocks, zero objects, zero background events, two warps, no renderer warnings. This is static and build evidence, not proof of gameplay success.

- `pokeyellow.gbc`: build succeeded; SHA-256 `f931ac957e822ebd04b4b3b4c6368f057ae082a8fe78ee4138feff369dd4406d`.
- `pokeyellow_debug.gbc`: build succeeded; SHA-256 `bcf6c60a1aa97a005157a34c8126c04c3691890996655f87d8442480818eeb61`.

The user then supplied screenshots showing a level-11 **MEW** battle but a level-11 **DITTO** after capture. This is observed gameplay evidence for the preceding build. Yellow's `data/pokemon/evos_moves.asm` gives Mew `TRANSFORM` at level 10. The capture path in `engine/items/item_effects.asm` previously replaced `wEnemyMonSpecies2` with `DITTO` whenever the enemy was transformed. `engine/battle/move_effects/transform.asm` changes `wEnemyMonSpecies` but leaves `wEnemyMonSpecies2` holding the original species. The capture path now reloads that original species without forcing Ditto, while retaining the existing original-DV handling. This correction also preserves genuine transformed Ditto captures as Ditto. The four dock targets, truck art, collision, and save files were not changed by this correction.

Both corrected ROMs were rebuilt from the dirty `master` worktree at the same HEAD with RGBDS 1.0.4. During PR review, `EVENT_BEAT_MEW` was restored to its existing saved-game bit `$9E1` instead of using a newly allocated S.S. Anne bit. The immediately preceding capture-fix ROM hashes (`2b516e91…` and `de933a9b…`) are superseded. These ROMs were later superseded by the save/reset lock revision; capture behavior in them was not observed in gameplay:

- `pokeyellow.gbc`: build succeeded; SHA-256 `084ad8943fa16c2a958d35ab31f2c4aaa9a149e57d953fa22adf43545d684179`.
- `pokeyellow_debug.gbc`: build succeeded; SHA-256 `73254f015540124c27f6e6d9c63e1b02e3e0f446d6b32251ea4f91bfbab4ae04`.

On 2026-11-22, the reported save/reset recapture issue prompted a dock-local lock revision on branch `codex/mew-truck-interaction`, based on commit `f531eca281ccf2b5f5918368f3f52e72e88632e4`. The four targets and collision were unchanged. The handler now checks Mew's Pokédex owned bit as well as `EVENT_BEAT_MEW`, and sets the event flag before handing off to the wild battle rather than waiting for a later map-script callback. Both builds used RGBDS 1.0.4; these hashes were superseded by the dock-resume guard below:

- `pokeyellow.gbc`: build succeeded; SHA-256 `0355a8389f5b8a30bda8c72bfd8a697478cb86229d78f5957ee32efbb99272bc`.
- `pokeyellow_debug.gbc`: build succeeded; SHA-256 `f923436355391e323e19cdcfe3b56506ec6bc3824bb255e73950d44a6cdecb20`.

Read-only inspection of the local `pokeyellow.sav` found the Mew owned bit and `EVENT_BEAT_MEW` both set, and the starter Pikachu at 0 HP. Yellow's `IsStarterPikachuAliveInOurParty` rejects a fainted starter, explaining the missing follower in that save; the user confirmed this explanation. This SRAM snapshot does not reproduce the reported repeat encounter or establish how an earlier reset reached Mew again. The original SRAM was not changed.

The user also reported being unable to move after saving and resetting on the truck-side ground, with the save apparently lost. The inspected local SRAM has a valid main checksum, points to Vermilion Dock at `(19, 0)`, and stores destination warp ID `1` despite the player no longer standing on the ship's dock warp `(14, 2)`. The dock's existing S.S. Anne exit script used the saved warp ID alone to trigger three forced northward steps and block input after HM01. This is a plausible lockup route if HM01 is set; the inspected SRAM has HM01 clear, so it does **not** reproduce that route or prove the reported save loss. The dock script now requires both warp ID `1` and position `(14, 2)` before starting ship-exit movement. The four Mew targets, collision, generic warp code, and save data layout were unchanged. Both ROMs built with RGBDS 1.0.4 after this guard; these are the current hashes:

- `pokeyellow.gbc`: build succeeded; SHA-256 `741f7536df0017520468b0cfcf39770969e6798510a1dc4cb4f6a13673a0906e`.
- `pokeyellow_debug.gbc`: build succeeded; SHA-256 `e046a67ddb07cd5133b528b95273ac5f6c97013a7ce120e3003874c3ace39acc`.

The `/computer-use` skill was unavailable in this environment, and no Emulicious or SameBoy gameplay was performed by the implementer on these ROMs. After the dock-resume and Mew-lock revision, the user reported that the game loaded again and that Mew could no longer be captured indefinitely. This is user-observed gameplay for those two symptoms; the exact ROM hash and SRAM used in that test were not supplied. The remaining targeting, level, party-empty, Transform, and Hall of Fame cases still require in-game checks. The local SRAM was only read, not rewritten.

SameBoy 1.0.2 was launched by the implementer with a copy of `pokeyellow.gbc` and a copied SRAM; it reached the title screen, but no dock gameplay was completed in that session. The user advised that SameBoy cannot be played by the implementer in this environment. Our test commands did not write the original SRAM files. `pokeyellow.sav` changed concurrently after the copy was made (copied SRAM SHA-256 `b3d29bbb87eb23b1b8e7ea4af9637f0b0c1184e6965a7d88f05673b9d489cc93`; original later SHA-256 `1d34cc5563ad115bd1b903ebf6389badd694e355d1d16242ac6d7f3dbc573fc5`), apparently from a separate SameBoy session; it was not restored or overwritten. The user's screenshots establish that the previous ROM reached a visible Mew battle and caught Ditto. They do not verify the corrected ROM or the remaining gameplay matrix.

## Manual acceptance checklist (not executed)

### Repel replacement on expiry (Trello card #27)

The replacement prompt is attached to the final-counter path in `engine/battle/wild_encounters.asm`. It follows the existing expiry notice, checks for at least one of the three Repel items, and resolves the strongest current Bag item after Yes. The selected item's existing duration is used (Repel 100, Super Repel 200, Max Repel 250); removal uses `RemoveItemByID` so a one-item stack is shifted safely. No and no-item paths leave the counter at zero and return through the existing encounter-suppression path. This is source inspection only; gameplay acceptance is pending.

Use a copied save at normal speed in an encounter area with a controlled Bag and an active Repel at one remaining step. Test separate saves with only Repel, only Super Repel, and only Max Repel; choose Yes and verify the matching stack drops by one and its normal duration begins. Use combinations to verify Max Repel, then Super Repel, then Repel priority. Choose No and verify no item is consumed and the next step does not prompt again. Repeat with no Repel in the Bag and verify only the existing expiry notice appears. Test each selected stack at quantity 1 and quantity greater than 1, including that following Bag entries remain intact. Observe that the expiry step still suppresses a battle, then verify later encounters and the leading-Pokémon level filter. Regress no-active-Repel walking, non-encounter movement, doors, warps, ledges, and map edges. None of these gameplay scenarios is verified until observed in Emulicious or on hardware; SameBoy checks remain for the human.

These steps are for a later emulator or hardware run. They are test instructions, not evidence that the behaviors have passed.

1. **Wild tables:** from a save that can reach each map, walk/Surf or use the Super Rod in the locations listed above. In a debugger, inspect the selected encounter species and level against the ten slots in `locations.json`; for Route 17 and Pallet Town, sweep/test the existing selector's four result ranges (102, 76, 51, 27 outcomes per 256) and confirm only the local four results change. Confirm Route 6 and Route 19 Surf works only after the normal Soul Badge unlock, and Old/Good Rod outputs remain their global tables.
2. **Four trades:** at Lavender, Saffron, Celadon, and Diglett's Cave before Koga, try with no party Pokémon, with a wrong species, and with the required species. Confirm the offered Pokémon is not removed on a rejected/failed trade, then verify the requested receive species, chosen level, nickname, and the four-step cycle.
3. **Ditto:** defeat Giovanni, enter Rocket Hideout B4F, and interact with Ditto. Confirm it is absent before Giovanni, appears once afterward, and does not return after capture or defeat until the specified reactivation rule applies (Ditto has no reactivation requirement in this plan).
4. **Museum and fossils:** on separate saves, choose Helix and Dome in Mt. Moon; after Lt. Surge, rematch the Museum Super Nerd and verify the opposing Omanyte/Kabuto choice and opposite fossil reward. Fill the bag before the reward to verify retry behavior. Hand each fossil to Pewter and retrieve the revived level-30 Pokémon there; repeat the handoff and retrieval across Pewter/Cinnabar. Verify Old Amber revival at Pewter only after Cut and confirm Cinnabar remains functional.
5. **Four original legendaries:** for Articuno, Zapdos, Moltres, and Mewtwo, test separate saves where each is defeated without capture and where it is captured. Confirm defeat removes it, partial League progress/loss does not restore it, a complete Elite Four victory restores only unowned species, and captured species stay absent.
6. **Mew targeting and presentation:** with a copy of SRAM at normal speed, use A while facing north from `(20, 2)` and `(21, 2)`, then face each upper truck target from a reachable upper-side approach. Confirm one text, one cry, and an actual Mew battle from every valid approach. Try A toward lower-side ground from `(19, 1)` and `(22, 1)`, from behind, facing away, and at unrelated tiles; confirm no text or blank box, cry, battle, warp, or Pikachu change. Try walking into reachable truck sides to confirm collision. Confirm no visible Mew sprite, the two warps, and normal movement/A interaction on another map. **Not verified in game.**
7. **Mew level and empty party:** on controlled copied saves, use highest party levels 94, 95, and 96 and check that Mew is level 99, 100, and 100, respectively. Put a higher-level Pokémon in the PC and confirm it is ignored. With an empty party, confirm the fallback message appears and no battle or availability change occurs. **Not verified in game.**
8. **Mew lifecycle, save/reset lock, and transformed capture:** the user reported that the game loaded again and Mew could no longer be captured indefinitely after the revision; the exact ROM hash was not provided. For a full regression run on a copy of SRAM, capture Mew, save from the dock, reset, and press A on all four valid targets; confirm no text, cry, or battle. Confirm the player can move normally after reloading at `(19, 0)` and at the two front approach cells. With HM01 obtained, repeat a truck-side save/reload and confirm there is no forced movement or input lock; then enter the dock from the S.S. Anne warp and confirm the normal ship-exit sequence still runs. Repeat the encounter after defeat and running on separate copied saves. On an older copied save with Mew owned but `EVENT_BEAT_MEW` clear, confirm the owned-bit guard still blocks the encounter. Capture Mew after it uses Transform and before it uses Transform; confirm the captured species and Pokédex owned entry are Mew in both cases. Capture a genuine transformed Ditto as a regression check. Check that League entry, partial Elite Four progress, and a failed run do not restore Mew. Complete the Elite Four with Mew unowned and confirm it returns with a level recalculated from the current party; complete it with Mew owned and confirm it stays absent. Check a new save before the League. The user's screenshots verify that a previous ROM caught Ditto after a Mew battle; they do not show the Transform turn or verify the current ROM. **Remaining cases not verified in game.**
