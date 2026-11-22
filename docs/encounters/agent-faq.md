# FAQ de decisões autônomas para encontros

Use estas regras para resolver escolhas incompletas durante o planejamento. Elas autorizam decisões metodológicas sem pedir confirmação ao usuário. Registre a decisão e o motivo em `notes` ou no campo de justificativa disponível. Preserve `game_encounters` como retrato factual do jogo atual; `tables` contém a proposta nova.

### A fonte permite Route Y ou Route Z. Qual escolher?

Escolha apenas uma das opções explicitamente permitidas. Aplique estes critérios em ordem:

1. Respeite a intenção de progressão descrita para a espécie; prefira a opção que a torna acessível no marco indicado sem antecipar conteúdo de forma incoerente.
2. Entre opções igualmente válidas, escolha a tabela que ganha mais variedade de tipo/linha evolutiva e fica menos concentrada em espécies do mesmo tipo.
3. Se ainda houver empate, escolha o local com menos espécies novas propostas na tabela. Persistindo o empate, use a primeira location na ordem em que aparece na fonte.

Registre o conjunto de opções original em `source_ref` e explique em `notes` por que escolheu uma. Não distribua a espécie pelas duas locations, a menos que a fonte peça explicitamente ambas.

### O plano não diz quais espécies e níveis ocupam os slots/pesos. O que fazer?

Complete a tabela como proposta, sem deixar slots pendentes, seguindo esta ordem:

1. Mantenha o modelo de 10 slots e o conjunto de pesos V1 para caminhada/Surf; a soma deve ser 256. Para pesca, siga primeiro a mecânica real da vara no código. Use a convenção de 10 slots/256 somente quando a proposta especificar uma mudança de sistema que crie essa tabela.
2. Preserve a disponibilidade das espécies quando a fonte disser para manter as fontes ou não mandar removê-las. Preserve também cada combinação atual de espécie e nível sempre que a quantidade de slots permitir; isso é recomendado, não obrigatório. Se não couberem todos os pares junto dos alvos, priorize a presença das espécies e escolha novos níveis pela regra de progressão abaixo. Registre quais pares mudaram. Isso não significa preservar as chances reais atuais: os pesos/chances de `tables` são baseline, e a distribuição final precisa refletir os alvos do planejamento.
3. Para cada chance aproximada, use como alvo o valor exato ou o ponto médio do intervalo citado. Escolha a combinação de pesos disponíveis cuja soma fique mais próxima do alvo. Garanta que cada slot seja atribuído a apenas uma espécie. Em empate, prefira menos slots, depois a combinação que preserve mais espécies atuais e, por fim, os índices de slot menores.
4. Depois de reservar os pesos dos novos alvos, distribua os slots de peso restante entre as espécies atuais que devem permanecer, proporcionalmente às chances relativas que elas tinham na tabela baseline. Para arredondar, calcule a cota ideal de cada espécie; atribua cada slot indivisível à espécie com maior déficit em relação à cota. Em empate, use a ordem original da tabela. Assim, preserve a disponibilidade sem carregar automaticamente as odds antigas para o plano.
5. Se várias espécies disputarem slots insuficientes, escolha a alocação conjunta que minimize a soma das diferenças entre chances-alvo e chances resultantes. Priorize alvos explícitos com menor chance e espécies com menos locais alternativos. Preserve o total de peso 256 e registre qualquer desvio do alvo; não crie mecânicas de subslot ou sorteio secundário.
6. Para espécie sem nível proposto, consulte `docs/encounters/level-insights.json` na location e no método escolhidos. Use `by_method` antes de `overall`; `overall` agrega métodos com peso igual e serve apenas se não houver estatística para o método. Cruze a mediana e os quartis da location com os níveis da mesma espécie nas tabelas atuais de Yellow e com o marco de progressão do plano. Escolha nível(ns) determinísticos dentro da faixa apropriada, evitando extremos sem justificativa. Registre a âncora e o raciocínio. Nunca sorteie nem escolha um nível por palpite.

Se não existir combinação exata de pesos, use a mais próxima pela regra acima e explique a diferença. Não pare para perguntar só porque o plano não enumerou cada slot.

### Pokémon X aparece “junto de” Pokémon Y, mas Y não é uma proposta nova. O que fazer?

Interprete “junto de” como instrução de composição da tabela, não como autorização para criar uma segunda alteração. Se Y já aparece na tabela atual, preserve sua presença e níveis, mas reavalie seus slots e sua frequência após alocar o alvo de X. Se Y não aparece na tabela atual, mas a fonte explicitamente pede X junto de Y, inclua ambos: X recebe a chance-alvo declarada; Y recebe a menor combinação de pesos disponível que mantenha a intenção de ser acompanhante. Registre essa frequência como decisão do agente. Não transforme uma simples menção contextual a Y em novo encontro.

### A chance é aproximada ou não corresponde a um único slot. Qual valor usar?

Calcule a chance da espécie pela soma dos pesos de todos os seus slots dividida por 256. Para alvos aproximados ou intervalos, aplique a regra de combinação da pergunta sobre slots. Guarde no JSON a chance calculada a partir dos pesos escolhidos e identifique-a como proposta; mantenha o alvo textual original em `proposed_targets` ou `notes`.

### A fonte não indica subárea, método ou vara com precisão. Como resolver?

Use a localização e o método mais específicos que a fonte efetivamente permite. Se houver alternativas explícitas de método, escolha a que já existe no local e preserva a progressão, evitando exigir uma mecânica nova. Se não houver método existente que cumpra a intenção, use a primeira opção explicitamente permitida pela fonte. Registre a alternativa escolhida e a razão; não invente uma nova subárea.

### A proposta de pesca por local não corresponde às varas do código. O que fazer?

Separe inventário factual de plano: no `game_encounters`, registre a implementação real — Old Rod produz Magikarp Lv. 5; Good Rod sorteia entre seus dois resultados globais; Super Rod usa a tabela de quatro resultados codificada para cada mapa, com distribuição 40/30/20/10. Em `tables`, prefira uma vara e uma location que o plano autorize e que o código já suporte. Se nenhum método suportado atender à intenção, mantenha a intenção como proposta e registre explicitamente a menor mudança de sistema necessária; não descreva a tabela como compatível com o jogo atual. Escolha a alternativa que exige menos mudança e preserva melhor o marco de progressão. Não pare para pedir escolha ao usuário.

### A tabela atual tem espécies que não aparecem como alvos no plano. Devo removê-las?

Não. `game_encounters` é o retrato do jogo atual; `proposed_targets` registra o que o plano quer adicionar ou alterar; `tables` deve ser a distribuição planejada. Preserve a disponibilidade das espécies que a fonte manda manter, mas reprojete suas frequências. Preserve as combinações atuais de espécie e nível quando os slots permitirem; se não permitirem, mantenha as espécies e justifique os níveis escolhidos. Use as odds atuais só como baseline para distribuir o peso residual, não como resultado final automático. Não confunda “não é uma proposta nova” com “deve ser removido”.

### Um tipo ou nível não aparece escrito no plano. Deixo `pendente`?

Tipo é um fato da espécie: derive-o dos dados locais do Pokémon e inclua-o em `type_range`, mesmo que o plano não nomeie o tipo. Para níveis, aplique a hierarquia da pergunta sobre slots e consulte `level-insights.json`. Use `pendente` para fatos não verificáveis, não para decisões de alocação que este FAQ já orienta.

### Como escolher um nível que não está especificado sem torná-lo aleatório ou fora da progressão?

Consulte `docs/encounters/level-insights.json` antes de atribuir qualquer nível. Use as estatísticas da mesma location e do mesmo método em `by_method`; considere `min`, `max`, `q1`, `median`, `q3` e `level_distribution`. O próprio arquivo informa que são estatísticas observadas, não níveis recomendados: use-as como evidência para a decisão, não como regra automática.

Depois cruze essa faixa com os níveis da mesma espécie em outras locations do jogo atual e com o marco de campanha pretendido. Como padrão, use a mediana local do método como referência central e mantenha o nível proposto dentro do intervalo interquartil (`q1`–`q3`) quando houver dados suficientes. Se a espécie já tiver uma faixa própria em Yellow, prefira a interseção entre essa faixa e a faixa típica local; se a interseção for vazia, use o valor mais próximo da faixa típica e explique o ajuste. Só saia do intervalo típico por uma razão explícita de progressão e registre-a.

Para vários slots da mesma espécie, não role níveis: distribua níveis observados na `level_distribution` local de forma determinística, usando os mais frequentes nos slots de maior peso e os menos frequentes nos slots de menor peso. Sem dados do método, use a estatística `overall` como fallback; sem dados da location, use a location anterior/seguinte da mesma progressão e documente essa âncora. Nunca escolha o nível ao acaso, nem adote automaticamente o nível máximo, mínimo, média ou moda sem cruzá-lo com espécie e progressão.

### Quando devo parar e pedir ajuda ao usuário?

Não pergunte sobre as escolhas cobertas por este FAQ. Pergunte somente quando duas decisões explícitas e aprovadas se contradisserem e nenhuma regra de prioridade resolver o conflito, ou quando um fato indispensável não puder ser confirmado nas fontes permitidas. Ao perguntar, apresente a evidência e as alternativas mínimas; mantenha a edição limitada ao que pode ser concluído com segurança.
