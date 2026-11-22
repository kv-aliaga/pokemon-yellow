# Decisions to make — segunda rodada de encontros

Este arquivo reúne propostas do agente para revisão antes da rodada de implementação. As direções das quatro trocas são aprovadas pelo plano V1. Os locais foram definidos pelo usuário; as chaves semânticas, níveis e apelidos são propostas do agente, não conteúdo existente no jogo.

## Trocas NPC

| Ordem | Troca aprovada | `npc_id` semântico proposto | Local definido pelo usuário | Pokémon recebido: nível e apelido propostos | Referência da decisão aprovada |
|---|---|---|---|---|---|
| 1 | Machoke → Haunter | `PROPOSED_TRADE_MACHOKE_HAUNTER` | Lavender Town | Haunter, nível 40, “Sombra” | `v1-wild-encounter-plan.md:5,52` |
| 2 | Graveler → Kadabra | `PROPOSED_TRADE_GRAVELER_KADABRA` | Saffron City | Kadabra, nível 40, “Oraculo” | `v1-wild-encounter-plan.md:5,39` |
| 3 | Kadabra → Machoke | `PROPOSED_TRADE_KADABRA_MACHOKE` | Celadon City | Machoke, nível 40, “Atlas” | `v1-wild-encounter-plan.md:5,40` |
| 4 | Haunter → Graveler | `PROPOSED_TRADE_HAUNTER_GRAVELER` | Diglett's Cave | Graveler, nível 40, “Granito” | `v1-wild-encounter-plan.md:5,43` |

O ciclo e o marco “antes de Koga” vêm do plano. Os locais foram definidos pelo usuário. Chaves, nível 40 e apelidos são propostas do agente para revisão; o plano não especifica local, nível ou apelido. Cada troca foi mantida na ordem expressa no documento, e a troca Cubone → Machoke ficou excluída.

## Identificadores encontrados no código atual

A busca encontrou os identificadores `TRADE_FOR_GURIO`, `TRADE_FOR_MILES`, `TRADE_FOR_STINGER`, `TRADE_FOR_STICKY`, `TRADE_FOR_BART`, `TRADE_FOR_SPIKE`, `TRADE_FOR_MARTY`, `TRADE_FOR_BUFFY`, `TRADE_FOR_CEZANNE` e `TRADE_FOR_RICKY` em `constants/script_constants.asm`. Nenhum identifica uma das quatro trocas aprovadas. Três entradas estão marcadas como não usadas (`STINGER`, `BART`, `MARTY`); as demais apontam para trocas diferentes em `data/events/trades.asm`. `RICKY` corresponde à troca Cubone → Machoke excluída pelo plano.

Por isso, os valores `PROPOSED_TRADE_*` são chaves semânticas propostas para os dados de planejamento, não identificadores que já existam no código. Como caminho candidato para a segunda rodada, considerar reaproveitar `TRADE_FOR_STINGER`, `TRADE_FOR_BART` e `TRADE_FOR_MARTY` para três trocas e criar uma quarta constante; essas constantes existentes são índices da tabela de trocas, não IDs de objetos de mapa, e seus registros atuais teriam de ser atualizados. A escolha é uma proposta de implementação, não uma decisão aprovada. Nenhuma implementação ou alteração do código foi feita nesta rodada.

## Resolução de implementação do catálogo V1

No código, as quatro trocas usam níveis 25 (Lavender, Saffron e Celadon) e 20 (Diglett's Cave). O nível 20 corresponde ao Q3 observado na caminhada de Diglett's Cave (Q1–Q3 17–20); os níveis 25 seguem a progressão de treinadores antes de Koga. Os apelidos usam a codificação inglesa suportada pelo jogo: SHADE, ORACLE, ATLAS e GRANITE. Veja `docs/encounter-implementation.md` para a justificativa e o registro de verificação.
