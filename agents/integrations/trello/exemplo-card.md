# Exemplo fictício de card

Todos os dados, nomes e links deste exemplo são inventados. As labels são propostas pela documentação e sua configuração no quadro Trello permanece **a confirmar**.

```markdown
## Objetivo
Permitir que a pessoa identifique rapidamente o estado de cada check no painel.

## Contexto
Hipótese fictícia: quando o estado não fica visível na lista, a pessoa precisa abrir cada check para localizar uma falha. Ainda precisa ser validada com usuários.

## Escopo
- Incluído: exibir o estado atual (Saudável ou Falha) junto ao nome de cada check.
- Excluído: histórico, filtros e alteração manual do estado.

## História de usuário (opcional)
Como pessoa que acompanha os checks, quero ver o estado ao lado de cada serviço, para localizar falhas sem abrir cada item.

## Critérios de aceite
- [ ] Dado um check com resultado saudável, quando o painel exibe a lista, então mostra o rótulo “Saudável” junto ao nome do check.
- [ ] Dado um check com falha, quando o painel exibe a lista, então mostra o rótulo “Falha” e preserva o acesso aos detalhes do erro.
- [ ] Dado que ainda não há resultado, quando o painel exibe a lista, então apresenta um estado identificável como “Aguardando primeira verificação”.

## Definition of Done
- [ ] Critérios de aceite verificados nos estados saudável, falha e aguardando.
- [ ] Alteração revisada conforme o fluxo da equipe.
- [ ] Texto de estado tem contraste e legibilidade adequados no layout implementado.
- [ ] Evidência da verificação registrada neste card.

## Responsável
Pessoa fictícia: Alex (design e implementação a definir pela equipe real).

## Classificação (opcional)
- Eisenhower: não se aplica.
- MoSCoW: `MoSCoW: Must have` — MVP do painel local (classificação fictícia).
- Prioridade: `P2` — fila normal de planejamento (classificação fictícia).

## Estimativa (opcional)
3 story points (estimativa ilustrativa; usar somente se a equipe adotar story points).

## Dependências (opcional)
- Modelo comum de resultado com o campo de status disponível.

## Referências (opcional)
- Figma/artefato: a criar; nenhum link real neste exemplo.
- Roadmap: a definir para o projeto fictício.

## Verificação
- Status: Pendente.
- Evidência: a registrar após implementar e verificar os três estados.
```

O exemplo usa MoSCoW e P2 por decisão fictícia. Não deriva P2 de “Must have”; as duas labels representam dimensões independentes.
