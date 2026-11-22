# Plano simples para encontros

Este documento define como organizar o planejamento de encontros de Pokémon Yellow. O objetivo é registrar propostas por local, permitir revisar a variedade de tipos e calcular a chance de cada Pokémon **dentro de cada tabela e método**, sem criar um catálogo ou processo maior que o necessário.

## Fontes e autoridade

Use cada fonte para o tipo de afirmação que ela pode sustentar:

- [`v1-wild-encounter-plan.md`](v1-wild-encounter-plan.md) e [`legendary-encounters.md`](legendary-encounters.md) definem as intenções e decisões de design: quais espécies/linhas adicionar, manter ou redistribuir e em que região ou etapa da campanha.
- `locations.json` em `game_encounters`, o código atual da ROM e as páginas de Pokémon Yellow da Bulbapedia, Serebii e RotomLabs documentam fatos dos encontros existentes. O código é autoridade para o comportamento desta ROM; as páginas externas ajudam a conferir a localização e a tabela original.
- [`encounters/level-insights.json`](encounters/level-insights.json) resume níveis observados por location e método. É evidência para escolher níveis, não uma proposta aprovada nem um sorteio.
- [`encounters/agent-faq.md`](encounters/agent-faq.md) define como resolver lacunas de alocação sem interromper o trabalho.

Não use fatos externos para criar uma intenção de design ausente do V1. Não use o V1 para afirmar como a ROM atual funciona. Registre separadamente a referência de design e a fonte factual que sustenta cada proposta.

## Inventário transitório dos encontros atuais

Quando a tarefa for inventariar o jogo atual para depois substituir os encontros pelo planejamento, consulte o código da ROM e cruze os dados com Bulbapedia, Serebii, RotomLabs e do próprio código do jogo nas páginas de Pokémon Yellow. Registre os fatos atuais somente em `game_encounters` de `locations.json`; mantenha `tables` como a área das propostas de planejamento. Para cada método, registre a espécie e o nível de cada slot, a chance condicional do slot, a taxa de encontro do mapa quando existir, e a origem consultada. As fontes externas ajudam a confirmar nomes e faixas de nível; o código é a referência decisiva para os dados desta ROM.

Compare níveis por espécie dentro da mesma location e método. Preserve os níveis individuais dos slots do jogo; uma faixa como `2–7` é apenas uma síntese desses slots, nunca substitui os níveis de cada slot. Se fontes divergirem, a página for ambígua ou os dados do código não puderem ser associados com segurança a uma location, pare nessa location e pergunte ao usuário, apresentando as fontes e as opções. Use `pendente` para um campo isolado sem confirmação, sem preencher por analogia.

Trabalhe em uma location por rodada. Depois de preencher uma location, valide a sintaxe com `python -m json.tool docs/encounters/locations.json > /dev/null` e confira manualmente espécies, níveis, chances e tabelas contra o código. Apresente o resumo, fontes e eventuais pendências, pause a meta e aguarde a revisão manual do usuário. Só continue para outra location após o usuário retomar/liberar a próxima etapa. A validação JSON e a conferência do código não substituem a revisão das fontes externas nem aprovam decisões de balanceamento.

Se uma informação estiver ausente, registrar `pendente` e explicar o que falta. Se os dois documentos parecerem se contradizer, conferir as decisões finais e as notas de resolução nos próprios documentos. Se ainda houver mais de uma interpretação possível, não escolher silenciosamente: apresentar ao usuário as opções concretas e pedir que decida.

## Arquivos JSON

Usar apenas estes dois arquivos:

| Arquivo | Conteúdo |
|---|---|
| `docs/encounters/locations.json` | Propostas de encontros selvagens organizadas por local, subárea e método. Inclui também os critérios simples de balanceamento usados na revisão. |
| `docs/encounters/acquisition.json` | Fontes não selvagens propostas: presentes, trocas, fósseis, prêmios, encontros estáticos e eventos, incluindo os lendários. |

Não criar arquivos de fatos extraídos, catálogo por espécie, propostas duplicadas, relatórios, schemas ou arquivos separados só para metas. Não presumir que outros JSONs ou ferramentas existem. Só criar esses dois arquivos quando for solicitado preencher o planejamento.

## Conteúdo de `locations.json`

Organizar o arquivo por tabelas. Cada tabela representa exatamente um local/subárea e um método, por exemplo caminhada, Surf ou uma vara de pesca. Registrar:

- `location`: nome usado no Markdown;
- `area`: subárea, andar ou trecho, quando indicado;
- `method`: método do encontro;
- `source`: documento e linha evolutiva/seção que motivam a tabela;
- `type_range`: tipos representados pelos Pokémon propostos naquela tabela, derivados das espécies nela listadas;
- `slots`: espécies e níveis/faixas de nível, com chance por slot ou peso;
- `pokemon_chances`: chance total por Pokémon **nesta tabela e método**, calculada pela soma dos slots da mesma espécie;
- `notes`: decisão ou pendência curta, se necessária.

No estado atual, os slots e as odds em `tables` foram copiados dos encontros reais da ROM; eles são uma linha de base, ainda não a distribuição esperada pelo planejamento. Ao concluir o plano, reprojete `tables` para cumprir os alvos de frequência do V1. Preserve o inventário original em `game_encounters`. Mantenha a presença das espécies que devem continuar disponíveis, mas redistribua seu peso restante em vez de conservar automaticamente as porcentagens atuais.

Não combinar métodos diferentes nem somar chances entre locais. Toda porcentagem deve deixar claro que é condicional a iniciar um encontro naquela tabela. Para caminhada e Surf, respeitar o modelo de 10 slots e os pesos descritos no plano V1 quando aplicável. Para manter o planejamento simples, usar também 10 slots com total 256 nas tabelas de pesca; isso é uma convenção de planejamento, não uma afirmação sobre compatibilidade com o jogo. Não converter estimativas vagas do Markdown em valores exatos sem distingui-las como proposta.

### Exemplo de `locations.json`

Este exemplo é parcial e serve somente para mostrar o formato. A proposta de Lapras em Surf nas Routes 19–20 e o alvo aproximado de 1–2% vêm do plano V1. O peso 3 corresponde a aproximadamente 1,2%; os outros 253 pontos de peso e o nível ainda ficam pendentes. Não tratar este fragmento como tabela concluída.

```json
{
  "balance": {
    "review_checks": [
      "tipos representados por tabela",
      "raridade por especie em cada tabela",
      "concentracao de especies por local"
    ]
  },
  "tables": [
    {
      "id": "routes_19_20.surf",
      "location": "Routes 19–20",
      "area": null,
      "method": "surf",
      "source": {
        "document": "v1-wild-encounter-plan.md",
        "reference": "Lapras"
      },
      "status": "partial_example",
      "type_range": "pendente",
      "expected_total_weight_256": 256,
      "unassigned_weight_256": 253,
      "slots": [
        {
          "pokemon": "Lapras",
          "level": "pendente",
          "weight_256": 3
        }
      ],
      "pokemon_chances": [
        {
          "pokemon": "Lapras",
          "weight_256": 3,
          "chance_percent": 1.171875
        }
      ],
      "notes": "Exemplo parcial; faltam nivel e demais slots."
    }
  ]
}
```

### Pesca

O planejamento dos métodos de pesca fica a cargo do agente. Mantenha cada vara como método separado e identifique decisões de distribuição como propostas, não como fatos do jogo. Para tabelas abstratas do plano, aplique a convenção de 10 slots/256; se a distribuição não for compatível com a mecânica atual da vara, registre a mudança de sistema necessária. Resolva alternativas e lacunas pelas regras da [FAQ de decisões autônomas](encounters/agent-faq.md). Só interrompa se duas decisões explícitas e aprovadas entrarem em conflito sem resolução pela prioridade das fontes.

## Balanceamento simples

O campo `balance` dentro de `locations.json` registra os critérios de revisão, sem arquivo adicional. A revisão deve responder, usando apenas as tabelas propostas:

- quais tipos aparecem em cada local e quais tipos têm poucas opções ao longo das tabelas;
- quais Pokémon são comuns, raros ou muito raros em cada tabela, a partir da chance calculada naquela tabela;
- se um local concentra muitos Pokémon do mesmo tipo ou repete espécies sem uma razão indicada no Markdown;
- se as intenções por linha evolutiva presentes no plano V1 receberam uma proposta ou foram explicitamente deixadas pendentes.

Esses itens são verificações qualitativas. Não declarar que o balanceamento está “aprovado” com base em limites numéricos inventados. Se forem desejados limites numéricos, pedir que o usuário os defina antes de aplicá-los.

## Conteúdo de `acquisition.json`

Cada registro representa uma fonte não selvagem proposta e contém apenas o necessário para entender a decisão:

- `id` e `type`: identificador do registro e tipo de aquisição;
- `location` ou `event`: local/evento, ou `pendente` se não estiver especificado;
- `player_gives` e `player_receives`: Pokémon entregado e recebido pelo jogador, quando for troca;
- `requirements`: condições explicitamente descritas no Markdown;
- `source_document` e `source_reference`: documento e decisão/linha que sustentam o registro;
- `status` e `notes`: se a decisão está aprovada, é proposta ou está pendente, conforme o texto de origem.

Não copiar para cá fontes atuais apenas para inventariá-las. Registrar somente fontes propostas no escopo dos dois documentos. Para lendários, preservar as decisões e condições descritas em `legendary-encounters.md`; para fontes não selvagens do plano V1, registrar somente as propostas descritas em `v1-wild-encounter-plan.md`.

### Exemplo de `acquisition.json`

Este exemplo mostra a segunda troca do ciclo aprovado no plano V1. A localização do NPC não está especificada no texto, por isso permanece pendente.

```json
{
  "acquisitions": [
    {
      "id": "npc_trade_2",
      "type": "npc_trade",
      "location": "pendente",
      "player_gives": "Graveler",
      "player_receives": "Kadabra",
      "requirements": "Disponível antes de Koga",
      "source_document": "v1-wild-encounter-plan.md",
      "source_reference": "Decisão final do catálogo; linha Abra → Kadabra → Alakazam",
      "status": "approved_in_source",
      "notes": "NPC 2 do ciclo de trocas."
    }
  ]
}
```

## Proteções contra invenções

Antes de adicionar qualquer registro, o agente deve:

1. localizar a decisão ou intenção correspondente em um dos dois documentos permitidos;
2. registrar a referência de origem no próprio JSON;
3. separar claramente o que o texto aprova do que o agente está propondo;
4. deixar fatos não verificáveis como `pendente`; resolver escolhas de distribuição usando a FAQ, identificando-as como propostas do agente;
5. reler os dois documentos para procurar contradições antes de concluir;
6. perguntar ao usuário somente diante de conflito factual ou de decisões aprovadas que permaneça sem solução depois de aplicar a FAQ e a prioridade das fontes.

Adicionar somente conteúdo solicitado pelos documentos. Não transformar “ou”, intervalos aproximados ou estimativas subjetivas em fatos: selecione uma alternativa segundo a FAQ e marque a alocação como proposta. Não declarar que arquivos foram criados, dados foram aprovados ou balanceamento foi verificado sem que isso tenha ocorrido.

## Ordem de trabalho

1. Ler integralmente os dois documentos permitidos.
2. Separar as propostas selvagens das fontes não selvagens.
3. Preencher as tabelas em `locations.json` e as fontes em `acquisition.json`, mantendo as referências de origem.
4. Calcular as chances por Pokémon dentro de cada tabela e método.
5. Revisar tipos, raridade e concentração conforme os critérios acima.
6. Apresentar pendências e contradições ao usuário antes de tratar o planejamento como concluído.

Este plano organiza propostas. Ele não autoriza alterar encontros no jogo nem aplicar mudanças ao código.
