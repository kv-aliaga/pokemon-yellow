# Goal prompt — concluir o JSON de encontros antes de alterar a ROM

Conclua `docs/encounters/locations.json` como especificação revisável dos encontros. O JSON aprovado será a entrada de um goal posterior que implementará as tabelas no código real.

**Este goal termina no planejamento.** Não altere código, tabelas ASM, mapas, scripts de eventos, mecânicas, build da ROM ou arquivos que não sejam `docs/encounters/locations.json`. Não inicie nem simule a implementação. Depois da aprovação final do JSON, a implementação será solicitada em outro goal.

## Fontes a consultar

Leia:

- `agents/PROJECT_SPEC.md`
- `docs/encounter-planning-design.md`
- `docs/encounters/agent-faq.md`
- `docs/encounters/locations.json`
- `docs/encounters/level-insights.json`
- `docs/v1-wild-encounter-plan.md`
- `docs/legendary-encounters.md`, somente para uma proposta selvagem lendária que afete `locations.json`

Consulte no código os arquivos citados por `game_source` e as tabelas/mecânicas pertinentes em `data/wild/` e `engine/items/`. Para confirmar os encontros originais de Yellow, consulte Bulbapedia, Serebii e RotomLabs nas páginas do jogo Yellow.

Use o V1 e as decisões finais como autoridade para **intenção de design**; use o código como autoridade para **comportamento da ROM atual**. Use `game_encounters` como base factual, `level-insights.json` como resumo estatístico e a FAQ como método para resolver escolhas. Registre as fontes de intenção e de fatos separadamente. Não dependa de README, catálogo, schemas ou relatórios que não estejam presentes no repositório.

## Fronteira entre dados atuais e proposta

`locations.json` contém duas camadas distintas, mas a camada planejada ainda está incompleta:

- `game_encounters`: inventário factual dos encontros da ROM atual. Preserve seus valores e sua apresentação. Corrija um dado somente quando o código provar uma divergência factual; cite a fonte e execute o validador factual. Nunca faça normalização global de capitalização/formatação para satisfazer um validador. Se houver diferença apenas de apresentação, corrija o validador para comparar nomes sem diferenciar maiúsculas/minúsculas.
- `tables`: hoje seus slots, espécies, níveis, pesos e chances refletem os encontros reais atuais; são somente uma linha de base provisória, não as odds esperadas pelo planejamento. Substitua a distribuição desta camada para representar os alvos do V1 e as decisões da FAQ. Preserve em `game_encounters` o retrato factual original. Não copie as chances reais atuais como se fossem a proposta aprovada nem apresente a proposta como comportamento já implementado.

Trabalhe somente nas locations e métodos necessários para representar as intenções de encontro selvagem do V1. Confira cada intenção selvagem do V1 contra `tables`: ela deve estar representada ou ter uma nota fundamentada explicando por que será preservada por uma fonte existente em vez de receber uma nova tabela. Não crie fontes de aquisição não selvagens neste arquivo.

## Ciclo de trabalho: uma location por retomada

Trate este prompt como um único goal retomável. Em cada rodada, conclua **uma location física** por vez, incluindo todos os métodos/subáreas propostos para aquela location. Use a ordem de locations do `v1-wild-encounter-plan.md` para escolher a próxima ainda não concluída. Guarde o ponto de retomada no contexto do goal; não crie outro arquivo de acompanhamento.

Para a location atual:

1. Leia a intenção do V1 e as decisões finais relevantes. Encontre sua entrada factual em `game_encounters`, seu `level-insights` por método e as tabelas atuais no código.
2. Resolva alternativas de rota, companhia, alocação de slots/pesos, método de pesca e níveis ausentes pelas regras de `docs/encounters/agent-faq.md`. Essas lacunas metodológicas não são motivo para parar e perguntar ao usuário. Registre a opção e a justificativa em `notes`.
3. Complete todas as tabelas planejadas dessa location. Preencha `proposed_targets` com os alvos da fonte; atribua cada alvo a slots reais da proposta e calcule `pokemon_chances` pela soma dos pesos de seus slots. Trate os slots/chances atuais em `tables` apenas como baseline para espécies e níveis. Aplique os alvos de frequência do V1; redistribua o peso restante entre as espécies atuais que devem permanecer, sem conservar automaticamente suas odds absolutas. Preserve cada combinação atual de espécie e nível sempre que a quantidade de slots permitir; isso é recomendado, não obrigatório. Se não couberem todos os pares junto dos alvos, priorize manter as espécies disponíveis, use níveis coerentes com `level-insights.json` e registre em `notes` quais pares foram alterados. Não deixe a alocação de espécie, nível ou peso como `pendente`.
4. Inclua em cada tabela `source_ref` para a decisão de design e `game_source` para o arquivo do código que serviu de base. Preserve o identificador e os campos já existentes sempre que possível.
5. Faça a revisão local abaixo e rode os validadores indicados. Corrija problemas comprovados antes de pausar.
6. Apresente a location concluída, as escolhas feitas, as evidências de nível, as chances calculadas e o resultado das verificações. Pause o goal com `update_goal(status="paused")` e aguarde a revisão manual. Após a retomada do usuário, aplique eventuais correções nessa location e só então avance.

### Regras locais para tabelas

- Caminhada e Surf: 10 slots na ordem de pesos V1 `[51, 51, 39, 25, 25, 25, 13, 13, 11, 3]`, total 256. Cada slot contém uma espécie e um nível inteiro entre 1 e 100. Preserve a disponibilidade das espécies que o V1 manda manter; reprojete sua frequência junto com os novos alvos, em vez de manter a porcentagem original automaticamente.
- Pesca: use o comportamento real por vara descrito no código. Old Rod, Good Rod e Super Rod não são tabelas intercambiáveis. Se uma intenção exigir tabela local incompatível com a mecânica atual, especifique na proposta a menor mudança de sistema necessária e sinalize que ela ainda não está implementada. Não descreva uma distribuição abstrata como compatível com a ROM atual.
- Níveis: consulte `level-insights.json` por location e método; cruze `median`, `q1`, `q3` e `level_distribution` com os níveis da espécie no jogo atual e com o marco de campanha. Escolha os níveis de forma determinística, dentro da faixa apropriada para a progressão, e cite a âncora. Não sorteie níveis nem use extremos sem justificativa.
- Chances aproximadas: escolha a combinação de pesos que mais se aproxime do alvo, seguindo a FAQ. Registre a chance resultante dos pesos; mantenha o alvo original como aproximação da fonte.
- Tipos: derive os tipos de cada espécie dos dados locais do jogo, não apenas das palavras citadas no V1.
- Se duas decisões explicitamente aprovadas realmente se contradisserem, aplique a prioridade das fontes definida em `encounter-planning-design.md`. Só pergunte se esse conflito factual continuar insolúvel. Não pergunte sobre os casos cobertos pela FAQ.

### Critério para pausar uma location

A location está pronta para revisão quando:

- todas as propostas do V1 aplicáveis a ela aparecem nas tabelas ou têm uma justificativa explícita de preservação;
- todos os slots têm espécie, nível e peso válidos, e as chances por Pokémon correspondem aos pesos;
- os níveis foram cruzados com `level-insights.json`, os níveis atuais da espécie e o marco de progressão;
- as fontes e decisões autônomas estão registradas nas notas;
- o JSON continua válido e a camada factual continua aprovada pelo script.

Não avance para a próxima location sem a retomada do usuário após a revisão manual.

## Auditoria global após a última location

Só depois de todas as locations terem passado pela revisão manual:

1. Releia o V1 integralmente e confirme a cobertura de todas as propostas de encontro selvagem.
2. Revise todas as tabelas quanto a IDs únicos, locais/métodos, slots, níveis, pesos, somas e chances agregadas.
3. Gere um resumo qualitativo de cobertura por tipo e linha evolutiva, raridade por tabela, concentração por local e compatibilidade com níveis/marcos da campanha. Identifique lacunas e concentrações; não invente limites numéricos de aprovação nem mude metas silenciosamente.
4. Execute:

   ```sh
   python -m json.tool docs/encounters/locations.json > /dev/null
   ```

   Confira `game_encounters` diretamente contra o código atual. Audite também a camada `tables` por inteiro: 10 slots e pesos V1 para caminhada/Surf, níveis válidos, soma de pesos 256, `chance_percent` por slot e `pokemon_chances` agregadas coerentes, todas as intenções mapeadas e nenhum campo de planejamento pendente.

5. Apresente a auditoria global e pause o goal para aprovação final do JSON. Após aprovação, encerre este goal e aguarde um pedido separado para implementar o JSON no código real.

## Saída de cada rodada

Informe somente a location trabalhada, decisões e justificativas, referências verificadas, resultados dos validadores e a pendência de revisão manual. Na auditoria final, inclua cobertura global e as limitações restantes. Não afirme que a ROM foi alterada ou que o balanceamento foi aprovado sem essas etapas.
