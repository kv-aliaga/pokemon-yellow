# Depuração com Emulicious neste repositório

Este arquivo descreve o fluxo de depuração de Pokémon Yellow com Emulicious e RGBDS. Use o código e o `Makefile` deste checkout como fonte para os comandos e artefatos do projeto; use as fontes listadas no fim para recursos e práticas gerais do emulador.

## Artefatos do build

- `make yellow_debug` monta `pokeyellow_debug.gbc`. O link também grava `pokeyellow_debug.sym` e `pokeyellow_debug.map` ao lado da ROM, pois a regra `%.gbc` do `Makefile` passa `-n $*.sym` e `-m $*.map` a `rgblink`.
- `pokeyellow_debug.gbc` é montada com `_DEBUG` definido e preenchimento `0xff`. Isso é diferente da variável `DEBUG=1` do Makefile.
- `make DEBUG=1 yellow_debug` acrescenta `-E` a `rgbasm`. Em RGBDS, `-E` exporta todos os labels, inclusive labels locais e não referenciados; não significa, por si só, que foi produzido um arquivo separado de debug por linha de fonte.
- O `.sym` associa labels a banco/endereço e é o arquivo principal para navegar por nomes no debugger. O `.map` registra a disposição das seções; consulte-o quando precisar confirmar em que banco uma rotina foi colocada.
- Os `.sym` e `.map` são artefatos ignorados pelo Git neste checkout. Depois de alterar código, reconstrua a ROM e use os sidecars do mesmo build. Não reutilize símbolos antigos com uma ROM nova.

Comandos de referência, executados da raiz:

```bash
make yellow_debug
```

Se uma rotina local não aparecer na tabela de símbolos, force a recompilação: o `make` não percebe sozinho que o valor da variável `DEBUG` mudou entre builds.

```bash
make -B DEBUG=1 yellow_debug
```

O `make` padrão constrói as ROMs normal e debug. Para investigar o build ou o uso de RGBDS, consulte também `Makefile` e `INSTALL.md`.

## Fluxo no Emulicious

1. Reconstrua `pokeyellow_debug.gbc` após a alteração que deseja investigar.
2. Abra essa ROM no Emulicious e confira se o debugger reconhece labels como `Start`, `ReadJoypad` ou `OverworldLoop`. Emulicious pode carregar automaticamente um `.sym` com o mesmo nome-base da ROM quando o arquivo está ao lado dela. Se os nomes não aparecerem, confira as opções de carregamento/recarga automática de símbolos e confirme que o `.sym` é o correspondente ao build aberto.
3. Abra o debugger pelo menu **Tools → Debugger**. Coloque um breakpoint em um label conhecido ou em uma instrução próxima do comportamento suspeito. O tutorial RGBDS da comunidade demonstra usar a aba **Variables** para examinar registradores de I/O; a interface do Emulicious também oferece execução passo a passo e visualização de estado.
4. Reproduza a situação no jogo. Ao parar, confira PC, registradores, stack/call stack e banco ROM atual. Em endereços da região banked, o valor de endereço sozinho pode não identificar a rotina: use o banco mostrado no debugger e confira a colocação da seção no `.map`.
5. Para bugs de dados ou estado, adicione watchpoints apenas à região/endereço relevante e, quando necessário, condicione a parada. Eles podem disparar repetidamente; restrinja o intervalo e remova-os depois da investigação.
6. Para problemas visuais, use **Tools → Tile Viewer**, **Tilemap Viewer**, **Palette Viewer** e **Sprite Viewer**. Compare os dados carregados em VRAM, o mapa, os atributos/paletas e o resultado na tela; a imagem final sozinha não indica qual dessas etapas falhou. O tutorial GBDev demonstra inspecionar registradores de paleta na aba **Variables** e usar o Palette Viewer para entender o resultado; uma escrita manual no registrador serve como experimento, não como correção do código.
7. Use o Trace Logger para registrar a sequência de execução e o Profiler/Coverage Analyzer para localizar rotinas executadas ou caminhos ainda não exercitados. O step-back ajuda a rever o estado imediatamente anterior a uma alteração.
8. Após um novo build, recarregue a ROM e os símbolos como um par. Para reproduzir um defeito, anote o estado inicial, os passos no jogo, o label/banco onde parou e os registradores ou endereços observados.

O `.sym` permite breakpoints por label mesmo quando o disassembly é a vista principal. Carregar os arquivos `.asm` como fonte pode facilitar a navegação; contudo, este checkout ainda não tem uma configuração Emulicious/VS Code própria nem um passo de build que gere um mapa de linhas dedicado. Portanto, confirme no debugger que a linha exibida corresponde ao código montado antes de depender de breakpoints por linha. `DEBUG=1` amplia os labels exportados; não deve ser descrito como geração de line-debug data.

## VS Code (opcional)

A extensão oficial do debugger Emulicious permite iniciar ou anexar a uma sessão remota, navegar pelo código-fonte e inspecionar estado no VS Code. Para usá-la, habilite **Tools → Remote Debugging** no Emulicious e configure o caminho do Emulicious na extensão. Para breakpoints de fonte em assembly, instale também uma extensão de linguagem RGBDS compatível. A extensão recomenda uma configuração de launch com `preLaunchTask` para fazer build e iniciar a depuração em uma ação.

Esse fluxo é opcional e não está configurado neste repositório: antes de adicionar `.vscode/launch.json` ou uma tarefa de build, confirme os comandos que a equipe quer executar e a extensão RGBDS instalada. Não presuma que a extensão está funcionando só porque o emulador iniciou.

## Cuidados e verificação

- O debug ROM é um instrumento de investigação. Confirme o comportamento final na ROM que será distribuída e em outro emulador ou hardware quando o defeito puder depender de precisão de hardware. O autor do tutorial RGBDS recomenda escolher emuladores tanto por ferramentas de debug quanto por fidelidade ao hardware.
- Emulicious mostra o estado da emulação; não prova que o comportamento foi validado em hardware. Registre separadamente build, inspeção no debugger e teste em emulador/hardware.
- Em Fedora, Emulicious requer Java com suporte gráfico. Se surgir `java.awt.HeadlessException`, o runtime padrão pode ser apenas o pacote `-headless`; use um runtime Java gráfico disponível ou instale o pacote OpenJDK não-headless. Não tente resolver isso definindo endereços de display ao acaso.

## Evidência local consultada

Checkout `https://github.com/kv-aliaga/pokemon-yellow`, revisão `f531eca281ccf2b5f5918368f3f52e72e88632e4`. Foram inspecionados `Makefile`, `INSTALL.md`, `README.md`, `.gitignore` e os sidecars locais `pokeyellow_debug.sym` e `pokeyellow_debug.map`. Os sidecars existentes são artefatos locais; o procedimento acima manda reconstruí-los após alterações.

## Fontes e dicas de desenvolvedores

- [RGBDS `rgblink` manual](https://rgbds.gbdev.io/man/rgblink): especifica as saídas de símbolos (`-n`) e mapa (`-m`).
- [RGBDS `rgbasm` manual](https://rgbds.gbdev.io/man/rgbasm): define `-E`/`--export-all`; a opção exporta labels locais e não referenciados.
- [Emulicious — recursos](https://emulicious.net/): documentação do autor sobre disassembler, execução reversa, breakpoints/watchpoints condicionais, trace, profiler e visualizadores.
- [Emulicious debugger extension — README do autor](https://github.com/Calindro/emulicious-debugger/blob/master/README.md): fonte, símbolos `.sym`/`.lst`, VS Code, remote debugging e `preLaunchTask`.
- [GBDev Assembly Tutorial — setup](https://github.com/gbdev/gb-asm-tutorial/blob/master/src/part1/setup.md): o autor explica que, para desenvolver, o emulador precisa oferecer debug e boa precisão; usa Emulicious no tutorial.
- [GBDev Assembly Tutorial — palettes](https://github.com/gbdev/gb-asm-tutorial/blob/master/src/part1/palettes.md) e [objects/Tile Viewer](https://github.com/gbdev/gb-asm-tutorial/blob/master/src/part2/objects.md): exemplos práticos de observar registradores de I/O, paletas, tiles e atributos no Emulicious.
- [Confirmação do autor do Emulicious sobre sidecar `.sym`](https://www.smspower.org/forums/17564-ANewVersionOfEmuliciousIsAvailable): o autor confirma que um arquivo `.sym` com o mesmo nome-base ao lado da ROM é carregado automaticamente.

As dicas do tutorial descrevem um projeto homebrew didático. A adaptação para Pokémon Yellow acima é uma recomendação operacional baseada nos artefatos reais deste checkout, não uma afirmação de que o tutorial cobre as rotinas do jogo.
