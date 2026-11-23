# Handoff: Repel ao expirar (card #27)

Leia este handoff junto com `docs/licoes-aprendidas.md`, `docs/encounter-implementation.md` e `AGENTS.md` antes de retomar o card.

## Objetivo e mudanças de escopo

Card: [#27 — Reuse Repel when its effect expires](https://trello.com/c/Q9hpeucy/27-task-reuse-repel-when-its-effect-expires).

O requisito original pede reposição de Repel no passo elegível em que o contador expira, com prioridade Max Repel → Super Repel → Repel, uma unidade consumida, duração normal do item, sem repetir após recusa, sem prompt se não houver Repel e preservando o passo de expiração e o filtro pelo nível do líder.

Durante o chat, o usuário depois acrescentou instruções explícitas: simplificar o texto para `Use another REPEL?`; sem item na mochila, apenas avisar que o efeito acabou; e fazer Repel impedir qualquer Pokémon selvagem de aparecer. A última instrução altera o critério inicial de filtro pelo nível do líder. Atualize ou anote o card para que a aceitação reflita essa substituição antes de avaliar conclusão. “Qualquer Pokémon selvagem” não especificou claramente se inclui encontros de vara de pesca; confirme nos critérios do card ou com o usuário antes de ampliar esse caso.

O usuário também relatou travamento quando o Repel usado pela mochila expira, popup invisível e duas confirmações. Depois que a interação foi movida para fora da inicialização da batalha, o usuário disse que o travamento deixou de ocorrer. O histórico não provou a causa interna do travamento. Os detalhes de texto e confirmação estão em `docs/licoes-aprendidas.md`.

Durante a implementação, a busca inicial de item pela mochila não reconheceu o Repel relatado pelo usuário; a implementação passou a percorrer os slots da bolsa diretamente. O histórico não isolou por que a consulta anterior falhou. Trate isso como um ponto a validar, não como uma causa corrigida comprovada. A matriz deve verificar cada tipo isolado, combinações e pilhas de quantidade 1 e maior que 1, conferindo também que o item seguinte permanece intacto.

## Worktrees e estado local

Este handoff foi escrito no worktree:

- Caminho: `/home/davialiaga/.codex/worktrees/repel-implementer/pokemon-yellow`
- Branch: `codex/repel-implementation`
- HEAD observado antes destas alterações documentais: `4d33fcab62896b2fa5699c926cb320398ad001a8`
- Estado anterior: `git status --short` sem alterações neste worktree.

Há outro worktree ativo para integração. **Preserve todos os arquivos locais ali; não limpe, restaure ou sobrescreva o worktree.** No momento do registro:

- Caminho: `/home/davialiaga/.codex/worktrees/repel-integration/pokemon-yellow`
- Branch: `codex/repel-integration`
- HEAD: `0cf2bfd740688d291e339e252cf98c45224b5ead`
- Alterações locais: `M engine/battle/wild_encounters.asm` e `?? pokeyellow.cht`.
- O diff de `wild_encounters.asm` contém instrumentação `_DEBUG` que espelha a caixa de pergunta no topo da tela e termina as duas strings Repel com `@`. O arquivo `pokeyellow.cht` é não rastreado e pertence ao usuário.

Antes de retomar, execute `git status --short`, branch e HEAD em cada worktree que pretende usar. Não assuma que o commit `4d33fcab` contém a correção posterior de `@`; a correção está no diff local do worktree de integração no estado registrado acima. Revise e integre somente depois de preservar os arquivos existentes.

## Evidências e builds registradas

- O teste instrumentado foi executado pelo usuário em uma ROM debug anterior à correção dos terminadores. A caixa inferior e o espelho mostraram a mesma corrupção. O jogador relatou que escolher Sim/Não fechou a interface sem uma segunda confirmação.
- `PlaceString` em `home/text.asm` espera `@`; `text_end` em `macros/scripts/text.asm` é o comando externo `TX_END`. Esta é a causa confirmada da leitura de bytes seguintes como caracteres.
- Depois de acrescentar `@`, as builds normal e debug foram concluídas com RGBDS 1.0.4. ROM normal: SHA-256 `7b73d2988374495bf38d958cab7d5b9aef2716a04c550989573038a367baf09b`. ROM debug com espelho temporário: SHA-256 `9e1fb77ecc6cfbdbd8e4686940d7534b981051f2d9d9ca30256a63bc13e5ead5`.
- Save de teste usado como cópia: `/tmp/repel-text-diagnostic/pokeyellow_debug.sav`, SHA-256 `fb18de764f6e717ddb6f5ee80453f28153d3085780517e721ac29fb0a113efb5`. O save original não deve ser substituído.
- **Não há gameplay observado após a correção `@`.** Os hashes acima provam quais arquivos foram compilados, não que a mensagem corrigida foi exibida corretamente.

## Próximos passos

1. Inspecione os dois worktrees e preserve o diff local de diagnóstico e o arquivo `pokeyellow.cht`.
2. Peça ao jogador uma nova captura com a ROM debug corrigida e a cópia de save controlada. Confirme que o espelho contém somente `Use another / REPEL?` e que a caixa inferior corresponde.
3. Recompile ambos os ROMs depois de qualquer integração e registre os hashes resultantes. Remova o espelho `_DEBUG` da versão final depois de guardar evidência suficiente e de forma que nenhuma alteração do usuário seja descartada.
4. Complete a matriz manual em `docs/encounter-implementation.md`: tipos isolados, prioridade combinada, Sim/Não, mochila vazia, pilhas 1 e maiores, ausência de prompt repetido, expiração e encontros posteriores, regressão de nível conforme o critério atualizado, movimento sem encontro, portas, warps, bordas e mapas sem encontros.
5. Use Emulicious pela skill `/computer-use` se a sessão controlável estiver disponível. SameBoy é reservado ao teste humano, conforme `AGENTS.md`. Se gameplay continuar inacessível, registre cada cenário como pendente e mantenha o card em andamento.

## Estado do issue tracker

O card foi mantido em andamento enquanto a aceitação de gameplay estava pendente. Não marque como concluído até os critérios atualizados e a Definition of Done terem evidência observável. Registre no card qualquer novo commit, build, hash, revisão ou limitação de teste.
