# Especificação do projeto: hack de Pokémon Yellow

## 1. Objetivo

Criar uma hack ROM de Pokémon Yellow a partir deste disassembly, aprofundando a rivalidade, a Equipe Rocket e a jornada do Pikachu, elevando o desafio, ampliando a exploração e a coleção e acrescentando conteúdo pós-Liga.

Todo o escopo discutido pertence ao objetivo final. **MVP, V1, V2 e versões seguintes indicam ordem de entrega, não itens descartados.** Ideias introduzidas como “talvez” continuam no plano como itens a decidir em detalhe.

## 2. Princípios e limites

- Não criar Pokémon originais (fakemon).
- Priorizar mapas, personagens, tiles, animações e sprites que já existem no projeto.
- A meta de coleção inclui os 151 Pokémon originais e as evoluções de espécies da primeira geração introduzidas em gerações posteriores.
- Ho-Oh, Lugia e Celebi são candidatos para o conteúdo pós-Liga; a forma de incluí-los ainda será definida.
- A inclusão de espécies ausentes em Yellow precisa de recursos gráficos compatíveis. A preferência é não desenhar sprites do zero. Reutilizar/adaptar sprites existentes de outros jogos é uma possibilidade, sujeita à decisão sobre o que conta como “criar sprites novos”.
- Priorizar mudanças que funcionem dentro da estrutura e dos recursos do jogo; registrar quando uma ideia exigir mudança de motor, interface, dados salvos ou recursos gráficos.

## 3. Critério de dificuldade técnica

Esta escala mede a profundidade das mudanças no jogo, não o volume de escrita, balanceamento ou edição manual.

| Nível | Tipo de trabalho | Exemplos deste projeto |
|---|---|---|
| **T1 — Dados** | Alteração de tabelas e conteúdo já suportado pelo jogo. | Atributos e golpes, encontros selvagens, níveis e equipes de treinadores. |
| **T2 — Eventos** | Alteração de scripts, diálogos, flags e eventos de mapas existentes. | Rival, Equipe Rocket, missões, eventos do Pikachu, easter egg e encontros especiais. |
| **T3 — Sistemas** | Mudança de lógica de progressão, interface, armazenamento ou regras do jogo. | Rematches condicionais, bolsa com organização nova, métodos alternativos de evolução ou captura. |
| **T4 — Expansão de espécies/recursos** | Fazer Yellow reconhecer conteúdo que não existe como espécie jogável no jogo original e integrar seus recursos. | Evoluções posteriores, Ho-Oh, Lugia e Celebi, caso sejam capturáveis como Pokémon reais. |

O nível pode mudar conforme a solução escolhida. Por exemplo, uma missão em mapa existente tende a ser T2; uma missão que dependa de uma espécie nova tende a envolver T4 também. Correções de bugs variam caso a caso. O esforço de conteúdo e o risco de regressão serão acompanhados separadamente da escala técnica.

## 4. Escopo funcional

### 4.1 Campanha principal

- **Rivalidade:** dar mais presença e progressão à rivalidade ao longo da aventura, incluindo equipes revistas para as batalhas importantes. A lógica exata das equipes e dos encontros será detalhada no design.
- **Equipe Rocket: Ascensão:** ampliar o papel da Equipe Rocket na história, com confrontos e eventos adicionais. Usar personagens e recursos existentes sempre que possível.
- **Desafios de ginásio:** criar equipes e batalhas de ginásio mais desafiadoras e coerentes com a progressão do jogador.
- **Jornada do Pikachu:** dar mais destaque ao vínculo com Pikachu, aproveitando os sistemas próprios de acompanhamento e felicidade existentes em Yellow antes de propor mecânicas novas.
- **Missões opcionais:** criar objetivos opcionais distribuídos por Kanto, com eventos, diálogos e recompensas.

### 4.2 Balanceamento e variedade

- Reequilibrar Pokémon pouco usados por meio de atributos, golpes e disponibilidade.
- Mudar onde e quando Pokémon aparecem para ampliar as opções de equipe durante a campanha.
- Rever as equipes de treinadores, incluindo rival, líderes de ginásio e confrontos importantes.
- Manter uma progressão de níveis deliberada; aumentar a dificuldade não deve significar apenas elevar níveis indiscriminadamente.

### 4.3 Pós-Liga e coleção

- Criar conteúdo jogável depois da Liga, com objetivos e encontros próprios.
- Permitir rematches contra líderes de ginásio depois de vencer a Elite dos 4.
- Permitir obter os 151 Pokémon originais no jogo.
- Incluir, como escopo de expansão, as evoluções posteriores das espécies da primeira geração.
- Avaliar a inclusão de Ho-Oh, Lugia e Celebi como capturas especiais do pós-jogo.

### 4.4 Interface, correções e segredo

- **Bolsa:** melhorar a organização dos itens. O formato da melhoria — reorganização simples, categorias, abas ou outra solução — está em aberto; a escolha define o nível técnico.
- **Bugs:** corrigir bugs selecionados do Pokémon Yellow e registrar o que foi corrigido. O catálogo local já aponta quatro candidatos iniciais: estado do controle ao abrir o menu de opções, transições de batalhas roteirizadas, estouro do buffer de comandos do Pikachu (Pikawalk) e dano inesperado de Counter. A prioridade de cada correção ainda será definida.
- **Easter egg:** acrescentar uma referência secreta ao desenvolvedor, usando conteúdo gráfico já disponível.

## 5. Plano de versões

### MVP — Base jogável para validar direção e balanceamento

**Objetivo:** produzir uma build jogável para validar o tom, a dificuldade e as mudanças de dados antes de expandir a história.

- Estabelecer a primeira passada de balanceamento de atributos e golpes.
- Atualizar encontros e equipes de treinadores como base da progressão.
- Introduzir a rivalidade revista em pontos iniciais da campanha.
- Incluir os primeiros momentos adicionais do Pikachu e da Equipe Rocket.
- Adicionar o easter egg.
- Corrigir um conjunto inicial de bugs priorizados.

**Predomínio técnico:** T1, com eventos T2 pontuais. O MVP não cancela nem substitui as partes planejadas para versões seguintes.

### V1 — Campanha principal completa

**Objetivo:** entregar a aventura principal com os arcos e desafios revistos.

- Completar a rivalidade ao longo da campanha.
- Completar o arco “Equipe Rocket: Ascensão”.
- Completar a jornada ampliada do Pikachu.
- Rever todos os desafios e equipes de ginásio e os treinadores principais.
- Completar os ajustes de encontros para sustentar a variedade de times.
- Incluir o conjunto planejado de missões opcionais da campanha.
- Continuar a correção de bugs priorizados.

**Predomínio técnico:** T1–T2.

### V2 — Pós-Liga e coleção completa da primeira geração

**Objetivo:** estender a progressão depois da Liga e fechar a meta de obtenção dos 151 Pokémon originais.

- Criar a campanha pós-Liga.
- Liberar rematches de ginásio após vencer a Elite dos 4.
- Completar as missões opcionais planejadas para o pós-jogo.
- Tornar os 151 Pokémon originais obtíveis em um único save, sem depender de trocas externas com outro jogo ou jogador. Trocas com NPCs dentro do jogo podem ser usadas como método de obtenção.
- Implementar a melhoria de bolsa acordada, dimensionando-a conforme a solução de interface escolhida.
- Continuar a correção de bugs priorizados.

**Predomínio técnico:** T2–T3.

### V3 ou posterior — Expansão de espécies e lendários

**Objetivo:** adicionar capturas de espécies ausentes em Yellow, caso o custo técnico e os recursos gráficos sejam compatíveis com as restrições do projeto.

- Incluir as evoluções posteriores de espécies da primeira geração.
- Avaliar e, se aprovado no design, incluir Ho-Oh, Lugia e Celebi como capturas pós-Liga.
- Integrar os dados de cada espécie aos sistemas de batalha, evolução, Pokédex e encontro/captura aplicáveis.
- Fornecer sprites compatíveis. A opção preferida é adaptar recursos existentes, sem desenhar sprites originais do zero.

**Predomínio técnico:** T4, com possíveis mudanças T3 dependendo da implementação. Esta fase tem a maior dependência de recursos gráficos e de compatibilidade com os limites do jogo.

## 6. Decisões de design em aberto

Estas decisões não retiram itens do escopo; elas definem a implementação:

1. **Sprites de espécies posteriores:** é aceitável adaptar sprites de jogos oficiais ou a restrição também proíbe importar/adaptar sprites que ainda não estão em Yellow?
2. **Pokémon pós-geração I:** quais evoluções posteriores entram na meta final e quais lendários, se algum, serão capturáveis?
3. **Métodos de obtenção dos 151:** quais espécies entram por encontros, presentes, trocas com NPCs ou prêmios, mantendo a conclusão possível sem trocas externas?
4. **Pós-Liga:** qual é a premissa narrativa e que papel Ho-Oh, Lugia ou Celebi teriam?
5. **Bolsa:** qual melhoria concreta é desejada: organização visual, categorias, capacidade, acesso a itens-chave ou outra?
6. **Dificuldade:** qual perfil desejado — mais estratégica, mais difícil em geral ou configurável?
7. **Bugs:** quais problemas do jogo original são prioridade? O catálogo local já lista falhas de opções, transição de batalha, buffer do Pikachu e Counter; algumas correções ainda estão em aberto.

## 7. Referências locais para implementação futura

- O disassembly separa código e dados por áreas como `engine/`, `data/`, `maps/` e `gfx/`, permitindo avaliar as mudanças por sistema.
- A bolsa e os sistemas do Pikachu já têm código e dados próprios; antes de desenhar uma solução, a implementação deve ser examinada no ponto correspondente.
- O catálogo de bugs original está em [`docs/bugs_and_glitches.md`](../docs/bugs_and_glitches.md).

Esta especificação registra o escopo acordado. Ela não afirma que as fases já foram implementadas nem fixa decisões que permanecem em aberto.
