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
- A lógica de Mew e a fórmula de nível estão implementadas no cais de Vermilion. O caminhão está desenhado nos eventos (20, 0) e (21, 0) do bloco 3 no mapa `VermilionDock`; Mew não tem sprite visível. Os `bg_event`s ficam sobre esses tiles do caminhão e usam um objeto treinador invisível (`SPRITE_NONE`) para os dados do encontro. Como a faixa de colisão logo abaixo não é transitável, o jogador fica nos eventos (20, 2) ou (21, 2), olha para cima e pressiona A; o handler do mapa direciona a interação para o caminhão e inicia a batalha após a mensagem.
- A vitória sobre a Elite dos Quatro rearma os encontros não capturados no script de conclusão completa, não ao entrar na Liga nem ao perder uma batalha.
- A regra depende de permitir novas vitórias completas sobre a Elite dos Quatro depois da primeira conclusão.

## Resolução do catálogo

O plano aprova o reaparecimento das quatro aves e de Mewtwo quando ainda não tiverem sido capturados e o jogador vencer a Elite dos Quatro. Mew fica aprovado como encontro especial sob o caminhão sempre que o jogador puder alcançá-lo fisicamente, sem bloqueio de Liga e sem sprite visível no mapa. O jogador pressiona A olhando para os tiles do caminhão para exibir a mensagem do encontro e iniciar a batalha. Seu nível é `min(100, maior nível da party + 5)`, recalculado a cada encontro. As regras de captura, reaparecimento e nível estão implementadas; os eventos de fundo estão posicionados sobre o caminhão, e o objeto treinador de apoio é invisível.
