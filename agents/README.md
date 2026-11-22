# Agent references

Use this index to choose a project brief. For current decisions and implementation state, follow the project documents and source code named by the brief rather than treating an old prompt as current state.

| File | Open when | Scope |
|---|---|---|
| [`PROJECT_SPEC.md`](PROJECT_SPEC.md) | A task may change project scope, add species, or use graphics/sprites. | Project goals, technical limits, and unresolved design decisions. |
| [`POPULATE_CURRENT_GAME_ENCOUNTERS_PROMPT.md`](POPULATE_CURRENT_GAME_ENCOUNTERS_PROMPT.md) | Asked to inventory what the current ROM encounters by location. | Records factual current-game data in `game_encounters`, one location per review round. |
| [`ENCOUNTER_CATALOG_COMPLETION_PROMPT.md`](ENCOUNTER_CATALOG_COMPLETION_PROMPT.md) | Asked to plan or revise the wild encounter proposal JSON. | Planning workflow only; it explicitly does not implement ROM changes. |
| [`ENCOUNTER_IMPLEMENTATION_PROMPT.md`](ENCOUNTER_IMPLEMENTATION_PROMPT.md) | Asked to implement the approved V1 encounter and acquisition catalog. | Implementation brief; use the linked design documents and current code for authoritative values and behavior. |

For V1 design decisions, catalog values, and implementation evidence, follow the on-demand references in the repository-root [`AGENTS.md`](../AGENTS.md). The planning and implementation prompts describe different tasks; select the one that matches the request.
