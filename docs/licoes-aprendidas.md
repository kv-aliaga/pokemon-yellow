# Lições aprendidas: texto e prompts do Repel (#27)

Este documento registra três falhas observadas durante o trabalho do card [#27 — Reuse Repel when its effect expires](https://trello.com/c/Q9hpeucy/27-task-reuse-repel-when-its-effect-expires). O objetivo é servir como FAQ para futuras alterações de texto, menus e fluxo de encontros em Pokémon Yellow. As conclusões abaixo se limitam ao código Yellow deste repositório e às observações registradas neste chat.

## FAQ: por que a caixa mostrou caracteres incorretos?

### Sintoma observado

Depois da expiração do Repel, a caixa inferior deveria perguntar `Use another REPEL?`. A captura do jogador mostrou o aviso e a pergunta misturados, com texto residual e caracteres gráficos no lugar de letras. A primeira tentativa de simplificar o texto não corrigiu o problema. Uma tentativa de limpar a caixa também não identificou a origem.

Foi criada uma instrumentação temporária para copiar a região de tilemap da caixa para o canto superior da tela. No teste conduzido pelo jogador, o espelho e a caixa apresentaram a mesma corrupção. Isso localizou o defeito no conteúdo já escrito no tilemap, antes de a resposta Sim/Não ser escolhida; portanto, o menu não era a origem primária dos caracteres inválidos.

### Causa confirmada no interpretador Yellow

`PlaceString` em `home/text.asm` percorre os bytes da string até encontrar o caractere literal `@`. Esse caractere encerra o conteúdo que está sendo desenhado. Já `text_end`, definido em `macros/scripts/text.asm`, emite o comando externo `TX_END` (`$50`): ele encerra o script interpretado, não substitui o terminador da string consumida por `PlaceString`.

As mensagens locais foram escritas em formato de script com `text`, `line` e `text_end`, mas sem o `@` no final do último segmento. Como consequência, `PlaceString` continuou lendo os bytes seguintes na ROM como se fossem caracteres. O mesmo mecanismo explica tanto a mistura com texto vizinho quanto os símbolos corrompidos. A montagem e a linkedição aceitam esses bytes; uma build bem-sucedida não valida esse contrato semântico.

### Correção e evidência disponível

O terminador literal foi acrescentado ao fim das duas strings locais de Repel: `REPEL?@` e `wore off.@`. A build normal e a build debug foram concluídas após a alteração. A build debug continha um espelho de tilemap temporário para diagnóstico.

O defeito foi observado antes da correção e a implementação do terminador foi compilada depois dela. **Não há observação de gameplay posterior à correção neste registro.** Assim, a causa do defeito anterior está confirmada por código e captura instrumentada, mas o desaparecimento do sintoma na versão corrigida ainda precisa ser confirmado no jogo. Remova a instrumentação de diagnóstico somente depois de preservar as alterações locais e verificar o estado do worktree correspondente.

### Prevenção recomendada

- Ao criar um script `text` próprio, verifique onde `PlaceString` termina a string e inclua `@` no fim do último segmento exibido.
- Trate `@`, `done` e `text_end` como mecanismos diferentes. `done` representa o comando de término/pausa da caixa no interpretador de texto; `text_end` encerra o script externo; `@` encerra a string desenhada por `PlaceString`.
- Acrescente uma checagem automatizada para scripts de texto locais que terminem em `text_end` sem que a string anterior termine em `@`, ou crie um teste de regressão que valide o conteúdo renderizado. A checagem precisa reconhecer os macros e casos válidos do projeto para evitar falsos positivos.
- Não considere compilação ou revisão visual do diff como prova de que o conteúdo de texto termina corretamente. Use um teste que passe pelo interpretador real ou um verificador que conheça a codificação de texto.

## FAQ: onde deve ser aberto o menu de reposição?

### Sintoma observado

O jogador relatou que, após usar Repel pela mochila, o jogo travava quando o efeito terminava. A primeira implementação de reposição colocou a interação em uma parte do fluxo de inicialização/avaliação de encontro. A interação foi então movida para depois do retorno de `InitBattle`, fora da avaliação que decide se aquele passo inicia um encontro. Depois dessa mudança, o jogador informou que o fluxo voltou a funcionar, mas observou que a pergunta podia ficar invisível. O histórico não contém uma captura do travamento original nem instrumentação que prove a causa interna exata.

### O que foi inferido e o que foi observado

O código mostra que a rotina de encontro controla tanto o passo que consome o último contador quanto a supressão do encontro naquele passo. Abrir um menu interativo nesse meio exige preservar o estado de retorno da batalha, o contador e a ordem de apresentação do texto. A escolha de adiar o menu para depois de `InitBattle` foi uma inferência estrutural, feita para não deixar a rotina de encontro suspensa enquanto uma pergunta aguarda entrada.

A remoção do sintoma de travamento foi relatada pelo jogador após a alteração. Isso é evidência de que a mudança melhorou o comportamento observado, mas não identifica por si só qual estado ou chamada causava o travamento. A visibilidade da pergunta também não foi garantida apenas por estar no local correto de execução: rotinas de exibição podem fechar a caixa antes de a pergunta ser apresentada.

### Prevenção recomendada

- Antes de inserir menus em rotinas de encontro, siga o fluxo completo: movimento → avaliação do encontro → inicialização/retorno da batalha → exibição de texto → pergunta → continuação do passo. Confirme onde o fluxo preserva o resultado “sem batalha” do passo de expiração.
- Use um exemplo existente de pergunta Sim/Não que seja acionada a partir de um fluxo semelhante. Registre junto à rotina o contrato de ordem entre `DisplayTextID`, fechamento da caixa, `PrintText` e `YesNoChoice` quando esse contrato for específico daquele ponto de entrada.
- Faça uma verificação de gameplay em velocidade normal para confirmar que a pergunta está visível, recebe entrada e fecha sem bloquear movimento. Um build não cobre estado de janela, espera de botão ou retorno do fluxo de movimento.
- Quando não houver ambiente de jogo acessível, mantenha o resultado de gameplay como pendente e forneça uma reprodução em save copiado. Se for instrumentar a ROM, marque e remova a instrumentação temporária de forma explícita.

## FAQ: por que o jogador precisou confirmar duas vezes?

### Sintoma observado

O jogador relatou precisar pressionar confirmar duas vezes para atravessar o aviso de expiração e a pergunta de reposição. A intenção corrigida foi que uma escolha Sim/Não encerrasse o popup completo, sem uma confirmação adicional para limpar um aviso separado.

### Causa no fluxo de interação

O aviso e a pergunta são etapas distintas. Se a implementação emitir duas caixas com rotinas que aguardam confirmação, cada caixa consome sua própria entrada. Isso pode ser comportamento normal do interpretador e não necessariamente um problema no menu Sim/Não. O fluxo desejado precisa ser comparado com um popup existente que combina informação e escolha sem criar duas pausas independentes.

No diagnóstico da ROM instrumentada, o jogador informou que uma seleção Sim/Não fechou a interface sem uma segunda confirmação. Esse resultado se refere à versão e ao estado exibidos naquela sessão; ele não prova que a versão posterior com os terminadores `@` foi testada integralmente.

### Prevenção recomendada

- Antes de encadear `PrintText`, `done`, `YesNoChoice` ou rotinas de fechamento de janela, determine qual chamada espera entrada e quantas entradas o jogador deverá fornecer.
- Reutilize o padrão de um popup existente que já conclui a interação com uma escolha, em vez de compor mensagens bloqueantes sem testar a sequência.
- Inclua no teste manual a contagem de confirmações: uma escolha deve aceitar Sim/Não e fechar o fluxo conforme esperado; confirme também que o cancelamento/No não consome item e não repete o prompt.

## Limites da verificação registrada

O repositório possui builds de ROM normal e debug no CI, mas esses builds não executam o interpretador de texto nem a interface do jogo. Para este card, a matriz de gameplay e os passos de reprodução permanecem em `docs/encounter-implementation.md`. Nenhum cenário deve ser marcado como aprovado sem observação no jogo. Preserve saves originais; use cópias com inventário controlado.

## FAQ: por que um popup de transição apareceu sem moldura?

### Sintoma observado

Ao ativar ou desativar a bicicleta por SELECT, o texto apareceu no meio da tela sem a caixa. Uma tentativa anterior mostrou uma caixa vazia antes da caixa com a mensagem esperada.

### Causa observada no fluxo da bicicleta

`DisplayTextIDInit` desenha uma caixa padrão para um ID de texto comum antes de chamar o handler. O handler especial de SELECT chama `ItemUseBicycle`; tanto montar quanto desmontar passam por `ItemUseReloadOverworldData`, que recarrega a visão do mapa e redesenha o tilemap. Essa recarga pode apagar a moldura que o dispatch abriu.

`PrintText_NoCreatingTextBox` escreve supondo que a janela existente ainda está desenhada. Depois da recarga, isso deixou o texto sem moldura. Trocar para `PrintText` sem evitar a caixa inicial causou duas etapas de janela: a caixa desenhada pelo dispatch podia ficar vazia, seguida da caixa criada por `PrintText`. A correção específica foi pular a moldura inicial apenas para `TEXT_BICYCLE_TOGGLE` e usar `PrintText` depois da recarga, para que a mensagem desenhe sua própria caixa no tilemap atualizado.

### Prevenção recomendada

- Ao adicionar popup a uma ação que recarrega mapa, sprites ou tilemap, siga o fluxo inteiro desde o chamador: inicialização de `DisplayTextID`, handler, efeitos colaterais da ação, rotina que imprime o texto e rotina que fecha a janela. Não presuma que uma janela aberta antes da ação continuará visível depois dela.
- Use `PrintText_NoCreatingTextBox` somente quando o caminho de execução garantir que a moldura continua ativa naquele ponto. Se a ação redesenha a tela antes da mensagem, desenhe a caixa depois da transição.
- Evite combinar uma caixa criada pelo dispatch com uma segunda chamada que cria sua própria caixa. Verifique se a primeira janela contém texto ou se é uma caixa vazia antes da mensagem final.
- Em gameplay, confirme montagem e desmontagem, texto dentro de uma única caixa, ausência de popup vazio e restauração correta de sprite/música. Teste também a entrada logo após fechar a mensagem e junto a água; houve relato de interação inesperada com Surf, mas sua causa não foi confirmada neste registro.
- Uma build bem-sucedida não verifica o conteúdo do tilemap nem a visibilidade da moldura. Se a sessão de jogo não estiver disponível, deixe esses resultados pendentes e forneça passos de reprodução.

### Evidência e limites

A sequência de chamadas e a correção foram inspecionadas no código; as builds normal e debug passaram após a correção. Não há confirmação visual em gameplay neste registro. Portanto, a correção compilada não deve ser descrita como comportamento visual validado.

## FAQ: como verificar uma mudança na velocidade da bicicleta?

### Sintoma e mudança observados

O jogador relatou que a bicicleta era mais lenta que correr segurando B. O avanço de animação da bicicleta foi aumentado de três para quatro chamadas por quadro. Esse número foi escolhido como ajuste de implementação; não veio de uma medição da velocidade percebida ou de um valor de referência documentado.

### Prevenção recomendada

- Primeiro confirme que a mudança de velocidade está no escopo vigente; no card #44 original, mudar a velocidade da bicicleta estava explicitamente fora do escopo, e a solicitação posterior do jogador alterou essa direção.
- Antes de escolher um número de avanços por quadro, identifique como a rotina afeta deslocamento em tiles, limites de `wWalkCounter`, conexões de mapa e movimento especial. Mais chamadas de animação não devem ser tratadas automaticamente como uma velocidade final comprovada.
- Compare bicicleta e corrida com B em um trecho plano e controlado, usando a mesma distância e condições. Verifique também colisões, bordas, NPCs e transições de mapa para detectar efeitos colaterais.
- Registre o que foi medido e observado. Builds normal e debug confirmam montagem/linkedição, não velocidade jogável; sem execução em jogo, mantenha a comparação como pendente.

### Evidência e limites

A alteração para quatro avanços compilou nas builds normal e debug. Não foi feita medição comparativa em gameplay nesta sessão; portanto, não há evidência de que a bicicleta tenha alcançado ou superado a velocidade de corrida com B.

## FAQ: por que as opções curtas deixaram letras de INSTANT na tela?

### Sintoma e causa confirmada

Ao alternar de `INSTANT` para uma opção mais curta, o jogador viu `SLOWANT`, `MID ANT` e `FASTANT`. `PlaceString` para de escrever quando encontra `@`, mas não apaga os tiles seguintes que já estavam na tela. As strings anteriores ocupavam menos caracteres que `INSTANT`, então o sufixo antigo permaneceu no tilemap. A build não detecta esse tipo de resíduo visual.

### Inferências de layout

A caixa de Options tem 20 colunas e a coluna de valor do Text Speed começa em x=12; assim, há sete células úteis (x=12–18) para o maior rótulo, antes da borda em x=19. Como não havia um contrato documentado para largura/limpeza desse campo nem uma decisão de layout para `INSTANT`, o valor foi movido para x=12 e o cabeçalho da linha foi encurtado para `SPEED:`. A primeira implementação criou `INSTANT@`, mas deixou `FAST`, `MID` e `SLOW` terminando logo após o texto visível. O erro foi a ausência de preenchimento/limpeza, não a codificação da opção.

### Correção e prevenção

As quatro strings agora ocupam sete células: `FAST   @`, `MID    @`, `SLOW   @` e `INSTANT@`. Para futuros rótulos dinâmicos com `PlaceString`, defina a largura do campo e preencha o restante com espaços ou limpe explicitamente todo o campo antes de desenhar. Verifique as transições do rótulo mais longo para cada rótulo curto e de volta; testar apenas a exibição isolada de cada string não revela tiles residuais.

### Outro erro de fluxo encontrado na revisão: retorno Instant com registradores empilhados

A primeira versão do retorno imediato para Instant ficou depois de `push hl`, `push de` e `push bc`. Esse caminho teria retornado sem restaurar a pilha, corrompendo o retorno ao chamador. A revisão de Spec encontrou o problema antes da conclusão; ele foi corrigido movendo os `push` para depois do guard e mantendo-os fora do loop de espera. Não há relato de execução dessa versão defeituosa no jogo.

Ao adicionar retorno antecipado a `PrintLetterDelay` ou rotina semelhante, confirme a posição de cada `push` em relação a todos os retornos. Retorne antes de empilhar ou restaure os mesmos registradores em cada saída. Builds não verificam o balanceamento da pilha em caminhos que não executaram; a revisão deve conferir os caminhos de saída e um teste no debugger pode comparar SP/call stack ao imprimir várias letras com Instant.

### Limite observado no build debug

O primeiro link de `pokeyellow_debug.gbc` excedeu a seção fixa `Home` em 3 bytes (depois, em 1 byte ao simplificar o guard). A causa foi o espaço ROM0 apertado, que só ficou claro ao compilar o alvo debug. A checagem dos dois alvos deve ocorrer durante a implementação, não apenas ao final; em Pokémon Yellow, um build normal bem-sucedido não garante que o debug ROM ainda cabe. A sequência de teste e correção terminou com builds normal e debug bem-sucedidos.

### Evidência e limites

O relato do jogador e a implementação de `PlaceString` confirmam a causa dos sufixos. A correção com strings de largura fixa compilou nas duas ROMs, mas não foi observada em gameplay nesta sessão. Reabra Options, alterne repetidamente `INSTANT` ↔ `FAST`, `MID` e `SLOW`, e confira também as voltas esquerda/direita para validar visualmente o tilemap.

## FAQ: por que Instant digitava texto de batalha com EXP Share ligado?

### Sintoma e causa confirmada

Com `INSTANT` selecionado e EXP Share ligado, textos de batalha apareciam um caractere por vez. `PrintLetterDelay` lia `wOptions` com `and $f` para decidir a espera. A velocidade usa apenas `TEXT_DELAY_MASK` (`%000111`), mas `BIT_EXP_SHARE` ocupa o bit 3. Assim, Instant mais EXP Share produzia `$08`; a rotina interpretava esse bit alheio à velocidade como uma espera de oito quadros por caractere.

### Correção e prevenção

`PrintLetterDelay` agora aplica `TEXT_DELAY_MASK` ao valor de `wOptions`. A rotina comum é chamada por `PlaceString` e pela impressão de números, então a correção vale para os textos animados em batalha e fora dela. Ao acrescentar opções a `wOptions`, mantenha cada leitura de velocidade limitada ao `TEXT_DELAY_MASK`; não use a máscara de nibble `$f`, que inclui o bit do EXP Share.

### Evidência e limites

O contrato de máscara foi verificado antes e depois: com Instant e EXP Share, `$f` resultava em 8, enquanto `TEXT_DELAY_MASK` resulta em 0. As builds release e debug foram concluídas depois da correção. Não houve observação posterior em gameplay nesta sessão; compilação e checagem estática não comprovam a apresentação visual.
