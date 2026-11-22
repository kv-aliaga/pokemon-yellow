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
- For map or event changes, record reproducible in-game steps for behavior that could not be tested in an emulator or on hardware.

## Read on demand

- For encounter or acquisition design and implementation, read `docs/v1-wild-encounter-plan.md`, `docs/encounter-planning-design.md`, and `docs/encounters/agent-faq.md`; use `docs/encounters/locations.json` and `docs/encounters/acquisition.json` for catalog values. The code remains the authority for current ROM mechanics.
- Before extending V1 implementation work, read `docs/encounter-implementation.md` for resolved implementation choices and the verification record. Read `docs/legendary-encounters.md` when changing legendary or Mew behavior.
- Read `agents/PROJECT_SPEC.md` when a task touches project scope, species availability, or graphics/sprite constraints.
- Read [`agents/README.md`](agents/README.md) when choosing or resuming one of the project briefs in `agents/`.
- After changing encounter or acquisition behavior, review the relevant design and implementation notes for contradictions. State which facts were inspected, built, and tested in-game; do not describe an unexecuted check as passed.
