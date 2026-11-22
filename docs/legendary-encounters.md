# Planejamento — encontros lendários

Este documento reúne as decisões aprovadas para os encontros lendários de Pokémon Yellow no escopo da redistribuição V1. As três aves e Mewtwo mantêm seus encontros estáticos; Mew recebe um encontro especial sob o caminhão assim que o jogador consegue alcançá-lo fisicamente, sem requisito de Liga (confirmação do usuário em 2026-11-21). Um lendário derrotado sem ser capturado pode reaparecer após uma vitória completa sobre a Elite dos Quatro.

As cinco intenções estão ligadas por espécie a [`encounters/acquisition.json`](encounters/acquisition.json). O link antigo para `encounters/proposals.json` não corresponde a um arquivo existente. Os quatro estáticos originais são fatos do código; o reaparecimento dos lendários não capturados e o encontro de Mew sob o caminhão são eventos aprovados para implementação.

## Mapeamento

| Linha evolutiva | Fonte atual | Proposta de fonte | Impacto esperado na variedade de times |
|---|---|---|---|
| Articuno (sem evolução) | Encontro estático no B4F das Seafoam Islands, nível 50. [RotomLabs](https://rotomlabs.net/locations/yellow/seafoam-islands) | Manter nas Seafoam Islands. Se derrotado sem captura, reaparece após uma vitória completa sobre a Elite dos Quatro. | Opção Ice/Flying de exploração avançada; mais relevante para novas equipes de endgame. |
| Zapdos (sem evolução) | Encontro estático na sala dos fundos da Power Plant, nível 50. [RotomLabs](https://rotomlabs.net/locations/yellow/power-plant) | Manter na Power Plant. Se derrotado sem captura, reaparece após uma vitória completa sobre a Elite dos Quatro. | Opção Electric/Flying disponível antes da reta final se o jogador explorar a usina. |
| Moltres (sem evolução) | Encontro estático no 2F de Victory Road, nível 50. [RotomLabs](https://rotomlabs.net/locations/yellow/victory-road-1-kanto) | Manter em Victory Road. Se derrotado sem captura, reaparece após uma vitória completa sobre a Elite dos Quatro. | Opção Fire/Flying tardia, útil para equipes de endgame e novas tentativas da Liga. |
| Mewtwo (sem evolução) | Encontro estático no B1F de Cerulean Cave, nível 70. [RotomLabs](https://rotomlabs.net/locations/yellow/cerulean-cave) | Manter em Cerulean Cave. Se derrotado sem captura, reaparece após uma vitória completa sobre a Elite dos Quatro. | Opção Psychic muito forte para o endgame; pode dominar equipes se obtida cedo. |
| Mew (sem evolução; mítico) | Sem encontro normal documentado nas tabelas de locais. | Encontro especial sob o caminhão quando ele puder ser alcançado fisicamente; não depende da Liga. Se derrotado sem captura, reaparece após uma vitória completa sobre a Elite dos Quatro. | Captura especial para coleção e equipes de endgame. |

## Regras acordadas

- Quando um lendário é derrotado sem ser capturado, ele desaparece.
- Após cada vitória completa sobre a Elite dos Quatro, os lendários que ainda não foram capturados ficam disponíveis novamente. Lendários capturados não reaparecem.
- A vitória precisa ser completa; entrar na Liga ou perder antes de vencê-la não reativa os encontros.
- Mew usa o nível do Pokémon de nível mais alto na party no instante em que o jogador inicia o encontro, mais cinco níveis:

  `nível de Mew = min(100, maior nível da party + 5)`

- O nível de Mew é recalculado em cada novo encontro. O nível dos outros quatro lendários continua fixo, salvo decisão futura de balanceamento.
- Para a fórmula de Mew, considera-se a party atual, não os Pokémon guardados no PC.

## Notas de implementação e compatibilidade

- Os quatro lendários originais são encontros estáticos de mapa com flags individuais. A implementação V1 reativa cada um após vitória completa quando não está marcado como capturado no Pokédex.
- A versão intermediária que mostrava `TODO` foi substituída por texto de Mew, cry e batalha selvagem iniciada pelo evento oculto. Não há objeto ou sprite de Mew na seleção comum do cais; o caminhão continua como arte de fundo do tileset `SHIP_PORT`, com a colisão original.
- A geometria do `TODO`, aprovada pelo usuário em 2026-11-22, foi preservada: quatro alvos ocultos `(20, 0)`, `(21, 0)`, `(20, 1)` e `(21, 1)`. Os dois alvos superiores aceitam A a partir de aproximações adjacentes alcançáveis, inclusive pelos lados superiores do caminhão. Os inferiores aceitam apenas A olhando para norte de `(20, 2)` e `(21, 2)`. O chão lateral inferior em `(19, 1)` e `(22, 1)` não aciona o encontro. A instrução anterior de rejeitar todas as aproximações laterais e usar somente dois alvos frontais foi substituída por esta decisão.
- O código consulta `EVENT_BEAT_MEW` antes de mostrar texto. Com party vazia, mostra um fallback e não inicia batalha. Com party válida, calcula `min(100, maior nível atual da party + 5)`, inicia Mew e marca o evento após captura, derrota, fuga ou blackout. A vitória completa na Liga reativa apenas Mew não capturado; entrada, progresso parcial e derrota na Liga não o fazem.
- Os dois ROMs compilaram após a implementação. O renderer confirmou zero objetos e zero eventos de fundo no cais. As capturas de tela do usuário mostram que o primeiro ROM chegou à batalha de Mew, mas expõem a falha de captura descrita abaixo. O fluxo completo, o ROM corrigido e os relatos antigos de cry sem batalha, teleporte e mudança no Pikachu ainda não foram verificados em gameplay; consulte o registro em [`encounter-implementation.md`](encounter-implementation.md).
- Falha de captura ligada a Transform: a captura de Mew no nível 11 foi observada como Ditto no primeiro ROM com batalha. As imagens não mostram o turno de Transform, mas Mew aprende esse golpe no nível 10 e a rotina original forçava `DITTO` quando o inimigo o usava. O código agora conserva a espécie original guardada em `wEnemyMonSpecies2`; os dois ROMs foram recompilados, mas essa correção ainda não foi testada em jogo. Os hashes anteriores identificam o ROM com a falha; os atuais estão em [`encounter-implementation.md`](encounter-implementation.md).

## Resolução do catálogo

O plano aprova o reaparecimento das quatro aves, de Mewtwo e de Mew quando ainda não tiverem sido capturados e o jogador vencer a Elite dos Quatro. O código atual implementa Mew sob o caminhão com os quatro alvos aprovados. A verificação em jogo permanece pendente e está registrada em [`encounter-implementation.md`](encounter-implementation.md).
