# Prompt — inventariar encontros atuais por location

Preencha `docs/encounters/locations.json` com os encontros reais da ROM atual, para que esses dados possam ser substituídos depois pelo planejamento aprovado. Trabalhe **uma location por rodada** e encerre cada rodada para revisão manual.

## Leia antes de começar

- `agents/PROJECT_SPEC.md`
- `docs/encounter-planning-design.md`, especialmente “Inventário transitório dos encontros atuais”
- `docs/encounters/locations.json`
- os arquivos de código da location e método que estiverem sendo inventariados

Use o código da ROM e cruze os encontros de Pokémon Yellow com as fontes Bulbapedia, Serebii e RotomLabs. O código desta ROM determina os slots, níveis e taxas implementados; as páginas externas servem para confirmar a interpretação e apontar discrepâncias.

## Execução por rodada

1. Selecione uma única location com encontros atuais ainda não inventariados. Não edite outras locations nesta rodada.
2. Identifique cada método separado: caminhada/grama, Surf e cada vara de pesca. Não combine métodos ou subáreas.
3. Para cada slot, registre Pokémon, nível individual e chance condicional ao encontro naquela tabela. Registre também a taxa de encontro do mapa se o código a definir.
4. Cruze espécie e nível com as fontes de Yellow para a mesma location e método. Preserve os níveis de cada slot do código; uma faixa de nível pode ser apresentada como resumo, sem substituir os slots.
5. Registre, junto à tabela, referências verificáveis: caminho do arquivo e seção/linha do código, mais URL e título/seção da fonte externa usada. Se fontes discordarem, descreva a divergência.
6. Edite somente a entrada da location escolhida em `game_encounters`. Preserve as propostas já contidas em `tables` e os dados das demais locations. Não normalize globalmente capitalização, grafia, ordem, espaçamento ou formato dos nomes já armazenados; só corrija um fato da location atual se o código provar a divergência.
7. Valide a sintaxe com `python -m json.tool docs/encounters/locations.json > /dev/null` e confira manualmente a entrada alterada contra os arquivos de código citados. Corrija apenas divergências factuais comprovadas da location atual.
8. Apresente o que foi registrado, as referências, o resultado da validação JSON e qualquer pendência. Marque a meta atual como pausada e aguarde a revisão manual do usuário; não avance para outra location até o usuário retomar/liberar a meta.

## Dúvidas e conclusão

Se não conseguir determinar com segurança qual location, método, faixa ou chance corresponde aos dados, pare antes de editar e pergunte ao usuário com as evidências e alternativas. Não escolha silenciosamente, não complete por analogia e não transforme uma discrepância de fonte em dado confirmado. Use `pendente` apenas para o campo sem confirmação e explique a lacuna.

Esta rodada termina quando: (a) apenas uma location foi alterada, (b) seus encontros e níveis foram cruzados com as fontes, (c) o JSON é válido e os fatos foram conferidos contra o código e (d) a meta está pausada após o usuário receber o resumo para revisão manual. Não faça análise nem ajuste de balanceamento nesta etapa.
