# Repository guidance

## Before changing files

- Run `git status --short` first. Treat every existing modification and untracked file as user-owned; keep edits scoped to the request and preserve that state.

## Source and asset evidence

- This checkout is the Pokémon Yellow disassembly. Use `pret/pokeyellow` and Yellow-specific source paths for claims about Yellow behavior or assets. Record the repository and revision when comparing external source. Files from Red/Blue or FireRed/LeafGreen do not establish what this Yellow source contains.
- Before concluding that a visual asset is absent, follow [`maps/README.md`](maps/README.md) and inspect or render the relevant map/block/tileset chain. Searching names, scripts, or sprite constants alone does not prove absence.
- When an interaction is tied to map art, check the event coordinates against the rendered map and reachable collision tiles. Keep visual placement, interaction position, and runtime behavior distinct in notes.
- When a task depends on an external specification, consult that source before implementation. If it cannot be reached, report the source, attempt, and error; continue only with requirements verified from available evidence, and leave inaccessible criteria unresolved instead of inferring them.

## Build and verification evidence

- Consult `INSTALL.md` for the supported toolchain and `Makefile` for build targets. If a build tool is missing, check executable resolution (including `rgbasm`, `rgbfix`, `rgbgfx`, and `rgblink`) and follow the documented installation path before concluding the build is blocked.
- Report the exact build target and whether each requested ROM completed. Distinguish source inspection and static checks from assembly/link success and from emulator or hardware tests; a successful build does not prove runtime behavior.
- When a requested verification requires interacting with Emulicious (loading a ROM or symbols, using the debugger, reproducing gameplay, or inspecting rendered output), use the `/computer-use` skill to operate the GUI and observe the result. Report only behavior actually observed; if the skill or graphical session is unavailable, state that limitation and provide reproducible in-game steps instead.
- Leave SameBoy ROM testing to the human. Provide reproducible in-game steps for the human to verify behavior that the agent cannot test in SameBoy.
- For map or event changes, record reproducible in-game steps for behavior that could not be tested in an emulator or on hardware.

## Read on demand

- For popup text, follow the existing Surf and Repel flows before adding a new one: inspect `ItemUseSurfboard` and its `Surfing*Text` scripts in `engine/items/item_effects.asm` for ordinary popups; inspect the `TEXT_REPEL_WORE_OFF` dispatch in `home/text_script.asm` and `DisplayRepelExpiryFlow` in `engine/battle/wild_encounters.asm` for a popup/menu that must stay inside an active text window. Read `docs/licoes-aprendidas.md` for the known failure modes: `PlaceString` needs a literal `@` string terminator (distinct from `text_end`), and calling a display routine after the text window closes can make otherwise valid text invisible. Match the entry point's window lifecycle and confirm visibility in gameplay; a successful build alone does not verify popup text.
- For text-speed regressions, read `docs/licoes-aprendidas.md` and trace `PrintLetterDelay`: mask `wOptions` with `TEXT_DELAY_MASK`, because unrelated option bits such as `BIT_EXP_SHARE` must not become frame delays.
- For Repel expiry prompts or related text-box debugging, read [`docs/licoes-aprendidas.md`](docs/licoes-aprendidas.md), an FAQ-style record of the Repel #27 failure modes and the evidence that diagnosed them. To resume card #27, also read [`docs/repel-card-27-handoff.md`](docs/repel-card-27-handoff.md) for the current branch/worktree split, unresolved scope changes, and verification status.
- For encounter or acquisition design and implementation, read `docs/v1-wild-encounter-plan.md`, `docs/encounter-planning-design.md`, and `docs/encounters/agent-faq.md`; use `docs/encounters/locations.json` and `docs/encounters/acquisition.json` for catalog values. The code remains the authority for current ROM mechanics.
- Before extending V1 implementation work, read `docs/encounter-implementation.md` for resolved implementation choices and the verification record. Read `docs/legendary-encounters.md` when changing legendary or Mew behavior.
- Read `agents/PROJECT_SPEC.md` when a task touches project scope, species availability, or graphics/sprite constraints.
- Read [`agents/README.md`](agents/README.md) when choosing or resuming one of the project briefs in `agents/`.
- After changing encounter or acquisition behavior, review the relevant design and implementation notes for contradictions. State which facts were inspected, built, and tested in-game; do not describe an unexecuted check as passed.
