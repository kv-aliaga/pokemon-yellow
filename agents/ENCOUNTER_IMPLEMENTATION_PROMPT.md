# Goal prompt — implementar o catálogo V1 de encontros

Implemente no código do jogo as mudanças de encontros e aquisições aprovadas para `[EPIC][V1] Redistribute wild Pokémon encounters`. Use o card do Trello e os documentos abaixo como especificação. Este goal altera a ROM; não reabra decisões de design já resolvidas nem pare para pedir ao usuário que retransmita decisões entre documentos.

Ao iniciar este goal por solicitação do usuário, considere autorizada a implementação do catálogo atual. Entradas marcadas como propostas para revisão em campos auxiliares de aquisição ainda exigem uma escolha de implementação: resolva-as com as regras abaixo e com os padrões já existentes no jogo, documentando a decisão. Só interrompa a parte realmente bloqueada por um conflito explícito que não possa ser resolvido pelos documentos nem pelo código; avance com as partes independentes.

## Autoridade e referências

Leia integralmente:

- Card Trello: https://trello.com/c/mwB9YBmf/4-epicv1-redistribute-wild-pok%C3%A9mon-encounters — escopo, critérios de aceite e Definition of Done.
- `agents/PROJECT_SPEC.md` — limites técnicos e de conteúdo do projeto.
- `docs/v1-wild-encounter-plan.md` — intenções e decisões aprovadas para encontros e aquisições.
- `docs/legendary-encounters.md` — comportamento dos lendários e de Mew.
- `docs/encounters/locations.json` — tabelas finais de encontros selvagens, métodos, níveis, pesos e chances.
- `docs/encounters/acquisition.json` — trocas, presentes/eventos, fósseis e encontros estáticos planejados.
- `docs/encounters/agent-faq.md` — decisões metodológicas para slots, probabilidades e níveis.
- `docs/encounters/level-insights.json` — evidência de progressão de níveis, quando necessária para conteúdo que não tenha nível aprovado.
- `docs/decisions-to-make.md` — locais escolhidos pelo usuário para as quatro trocas e notas de implementação propostas.

Use a ordem de autoridade: decisões explícitas do usuário e critérios do card; decisões aprovadas nos documentos de design; `locations.json` e `acquisition.json` para valores de conteúdo; código atual para mecânica, compatibilidade e convenções. Quando o código e a proposta diferirem, preserve a mecânica existente e implemente a proposta com a menor mudança compatível com a intenção. Registre a divergência no resumo final.

`docs/encounter-planning-design.md` explica a separação entre fatos atuais e proposta. `agents/ENCOUNTER_CATALOG_COMPLETION_PROMPT.md` é contexto histórico do goal de planejamento, não uma instrução para continuar editando o catálogo.

Se `docs/legendary-encounters.md` apontar para `docs/encounters/proposals.json`, trate esse link como referência obsoleta: o arquivo não existe no estado atual. Use `docs/encounters/acquisition.json` junto das decisões de `docs/legendary-encounters.md`.

## Decisões de implementação já fechadas

- Caminhada e Surf usam os dez slots de cada tabela em `locations.json`, com os pesos/chances ali definidos. Espécie e nível pertencem ao mesmo slot; mantenha-os associados.
- Hitmonlee e Hitmonchan precisam ter a mesma chance em Victory Road: 13/256 (5,078125%) cada.
- Tangela em Pallet Town e Seel em Route 17 permanecem na Super Rod local. Mantenha os limiares do seletor atual. O último resultado efetivamente tem 27/256 (10,546875%), não 10% exatos.
- Route 6 e Route 19 têm água e mantêm as propostas de Surf. Não crie tabelas locais de Old Rod ou Good Rod: o código não seleciona essas varas por mapa e essas propostas foram retiradas.
- Preserve todos os encontros e aquisições atuais que os documentos mandam manter, inclusive presentes, fósseis originais, estáticos, opções do Fighting Dojo e fontes existentes de espécies.
- Não adicione espécies fora do escopo canônico nem sprites novos. Não recrie os scripts Python de validação removidos.
- A disponibilidade de Mew não deve depender de derrotar a Liga. A confirmação do usuário permite o evento em qualquer momento do save em que o jogador consiga alcançar fisicamente o caminhão e interagir com ele.

## Escopo de conteúdo

### Encontros selvagens

Implemente uma vez cada uma das 20 tabelas de `locations.json`, mapeando `game_source` e a location/subárea para os dados e rotinas reais do jogo:

`route-24-walk`, `route-3-walk`, `route-6-walk`, `viridian-forest-walk`, `route-7-walk`, `route-5-walk`, `route-8-walk`, `route-10-walk`, `golduck-surf`, `rock-tunnel-b1f-walk`, `victory-road-walk`, `seafoam-b3f-walk`, `seafoam-b4f-walk`, `power-plant-walk`, `route-17-walk`, `pokemon-mansion-b1f-walk`, `route-2-walk`, `route-19-surf`, `route-17-super-rod` e `pallet-town-any-rod`.

Use os dados atuais da ROM como base estrutural, mas substitua os encontros conforme as tabelas propostas. Preserve taxas de encontro por mapa e outros métodos que não tenham sido alterados. Surf é uma tabela distinta de caminhada. A Super Rod usa quatro resultados locais por mapa e o seletor existente; Old Rod e Good Rod permanecem globais como hoje.

### Aquisições e eventos

Implemente as entradas aprovadas de `acquisition.json` e as decisões do V1:

- quatro trocas NPC, nos locais definidos em `docs/decisions-to-make.md`, com as direções Machoke→Haunter, Graveler→Kadabra, Kadabra→Machoke e Haunter→Graveler; mantenha o ciclo e o marco anterior a Koga;
- encontro estático de Ditto após Giovanni no Rocket Hideout B4F;
- revanche com o Super Nerd no Museu de Pewter, recompensa do fóssil oposto ao fóssil escolhido em Mt. Moon, e revivificação de fósseis em Pewter; preserve o ponto atual de Cinnabar;
- reaparecimento de Articuno, Zapdos, Moltres e Mewtwo depois de uma vitória completa sobre a Elite dos Quatro, somente se ainda não foram capturados;
- encontro de Mew sob o caminhão, sem bloqueio de história/Liga. Calcule o nível ao iniciar cada encontro como `min(100, maior nível da party + 5)`. Derrotado sem captura, Mew reaparece após uma vitória completa sobre a Elite dos Quatro; capturado, não reaparece.

### Valores sem decisão explícita

`acquisition.json` identifica nível 40 e apelidos das entregas das trocas como propostas para revisão, não como decisões aprovadas. Não copie esses valores cegamente. Para cada troca, escolha um nível coerente com o marco “antes de Koga”, usando equipes de treinadores próximas, níveis do conteúdo da região e convenções das trocas existentes. Para apelidos, siga o padrão mais próximo das trocas atuais e a codificação suportada pelo jogo. Para Ditto e outros eventos sem nível explícito, use o nível do encontro equivalente/local na progressão; registre a âncora. Anote cada escolha de implementação no resumo final. Faça escolhas determinísticas e mantenha o ciclo funcional; não pare apenas porque esses campos foram deixados como proposta.

## Etapas de trabalho

### 1. Reconhecer o estado e localizar os pontos de edição

Verifique `git status` e preserve alterações preexistentes. Leia os arquivos e símbolos apontados pelas referências, depois trace os fluxos de encontro, pesca, eventos de mapa, trocas, fósseis, captura e vitória da Elite dos Quatro. Identifique flags disponíveis, limites de objetos por mapa, IDs e convenções do assembler antes de editar.

**Concluído quando:** existe um mapa de cada tabela/evento do escopo para seus dados e rotinas de implementação, e os arquivos já modificados pelo usuário estão identificados.

### 2. Implementar tabelas selvagens

Atualize os dados de caminhada, Surf e Super Rod para corresponder a cada slot, nível e chance efetiva do JSON. Use os macros e o seletor real da ROM; não reimplemente uma segunda mecânica de probabilidade. Mantenha separadas as tabelas de andar/subárea e método. Preserve os encontros removidos em `game_encounters` como fatos documentais, sem mantê-los ativos na ROM quando a tabela aprovada os substitui.

Para cada location, compare a tabela resultante com os dez slots planejados ou os quatro resultados de Super Rod. Confirme espécie, nível e distribuição efetiva no runtime, incluindo chances agregadas de espécies repetidas. Mantenha intactos Old Rod e Good Rod globais.

**Concluído quando:** as 20 tabelas planejadas estão representadas no código, nenhuma tabela incompatível de Old/Good Rod por mapa foi criada e os pesos/chances resultantes correspondem ao catálogo.

### 3. Implementar trocas e eventos de aquisição

Adicione NPCs, scripts e textos nos mapas indicados. Verifique espaço de objetos, IDs, condições de progressão e tabelas de trocas. Faça as quatro trocas completarem o ciclo sem permitir perda involuntária do Pokémon oferecido ou recebimento duplicado indevido.

Implemente Ditto, a revanche e os fósseis usando flags persistentes e condições coerentes com os eventos atuais. A vitória sobre o Super Nerd deve entregar somente o fóssil oposto ao escolhido pelo jogador. Os dois locais de revivificação devem reconhecer Helix, Dome e Old Amber conforme as regras aprovadas, preservando Cinnabar.

Implemente o reaparecimento dos lendários com estado independente por espécie: vitória completa sobre a Elite dos Quatro reativa apenas os lendários não capturados; perder ou sair da Liga não os reativa. Use a estrutura de save existente e reserve flags livres, sem deslocar dados salvos sem necessidade.

**Concluído quando:** cada evento pode ser alcançado na progressão indicada, seus pré-requisitos e recompensas são determinísticos e os estados sobrevivem a salvar/carregar conforme a mecânica do jogo.

### 4. Revisar disponibilidade e fontes únicas

Cruze cada espécie/linha e cada aquisição alterada com o plano V1. Confirme que escolhas do jogador e itens únicos continuam disponíveis, que as quatro trocas são alcançáveis antes de Koga e que eventos de pós-jogo respeitam os requisitos. Confirme que a obtenção do Pokémon não escolhido no Fighting Dojo continua sendo a proposta de Victory Road, e que a escolha garantida do Dojo permanece.

Distinga obtenção do Pokémon e uso de Surf no mapa: uma tabela aquática pode estar implementada antes de o jogador obter o Soul Badge, mas não torne o uso de Surf como movimento de campo possível antes do requisito normal do jogo.

**Concluído quando:** todos os critérios de aceite do card estão associados a uma mudança concreta ou a um teste manual reproduzível, e nenhuma fonte única obrigatória foi removida.

### 5. Verificar e relatar

Use verificações já disponíveis no repositório e a build RGBDS definida por `Makefile`/`README.md`. Execute a build apropriada (`make` e, se suportado pelo ambiente, a build debug) e inspeções focadas para as tabelas e flags alteradas. `python -m json.tool` pode confirmar a sintaxe dos JSONs de referência; ele não valida a ROM. Não use `make compare` como critério de igualdade com a ROM original depois de alterar o jogo.

Se houver emulador/test harness disponível, teste ao menos: cada tabela selvagem/método alterado; as quatro trocas; Ditto após Giovanni; recompensa/revivificação dos fósseis; cada estático lendário derrotado sem captura, capturado e reativado após vitória completa; Mew com nível abaixo e acima do limite de 100 e reativação pós-Liga. Se algum caso não puder ser automatizado, descreva passos manuais exatos e não alegue que foi testado.

Não crie scripts de teste Python ad hoc. Não apague nem reverta alterações preexistentes. Não marque o card como concluído nem altere o Trello: entregue as evidências para revisão do usuário.

**Concluído quando:** a build aplicável passa; cada critério de aceite tem resultado ou limitação explícita; o resumo lista arquivos alterados, escolhas de implementação, verificações executadas e qualquer bloqueio remanescente.

## Saída final

Informe:

1. tabelas de encontro e eventos implementados, com os principais arquivos;
2. decisões concretas para os campos antes propostos das trocas e níveis estáticos;
3. resultado da build e dos testes/inspeções, separando o que foi executado do que não foi;
4. qualquer limite de engine ou critério do card ainda não atendido.

Não declare o card concluído nem a implementação verificada se algum critério não tiver evidência.
