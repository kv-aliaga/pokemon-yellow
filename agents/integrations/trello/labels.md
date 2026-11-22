# Labels de priorização

Este arquivo propõe nomes e critérios para labels. Ele não confirma que essas labels ou cores já estejam configuradas no quadro Trello. Antes de aplicar uma label, confira o quadro e trate diferenças de nome ou configuração como **a confirmar**.

Eisenhower, MoSCoW e P0–P4 são classificações distintas. Use somente as que ajudam a tomar a decisão do card; não derive uma classificação automaticamente da outra.

## Matriz de Eisenhower

Use Eisenhower para decidir quando uma atividade merece atenção, considerando separadamente **importância** (contribuição para resultados e necessidades) e **urgência** (prazo ou consequência de esperar). Um item pode ser importante sem ser urgente, e urgente sem ser importante.

| Nome sugerido da label | Significado | Regra prática | Exemplo |
|---|---|---|---|
| `Eisenhower: Importante e urgente` | Tem impacto relevante e esperar causa dano ou perda imediata. | Atribua quando houver consequência concreta de atraso e o trabalho contribuir diretamente para um resultado importante. | Corrigir uma falha que impede a pessoa de acessar o painel durante uma demonstração hoje. |
| `Eisenhower: Importante e não urgente` | Contribui para resultado relevante, mas pode ser planejado. | Atribua quando o valor for alto e não houver prazo próximo que torne a ação urgente. | Melhorar a explicação de erros para reduzir dúvidas recorrentes, sem incidente ativo. |
| `Eisenhower: Não importante e urgente` | Existe pressão de tempo, mas o impacto no resultado principal é baixo. | Atribua quando a data limite é real, mas a atividade pode ser delegada, simplificada ou renegociada. | Ajustar um detalhe visual para uma apresentação interna de amanhã. |
| `Eisenhower: Não importante e não urgente` | Não há impacto relevante nem prazo próximo. | Atribua quando o trabalho pode ser adiado ou removido sem prejuízo significativo. | Explorar uma animação decorativa sem necessidade identificada. |

## MoSCoW

Use MoSCoW para negociar o escopo de uma entrega definida. Registre a entrega ou período para que “Won’t have” seja interpretável. A classificação expressa compromisso de escopo, não gravidade ou ordem de atendimento.

| Nome sugerido da label | Significado | Regra de decisão | Exemplo |
|---|---|---|---|
| `MoSCoW: Must have` | Indispensável para cumprir o objetivo ou considerar a entrega viável. | Se removido, a entrega falha em seu propósito, requisito obrigatório ou critério de aceitação essencial. | Exibir o estado atual do check na entrega do painel inicial. |
| `MoSCoW: Should have` | Importante, com alternativa temporária aceitável. | A entrega continua útil sem o item, mas há impacto claro ou custo de adiamento. | Mostrar horário da última verificação; inicialmente a pessoa pode consultar detalhes do check. |
| `MoSCoW: Could have` | Melhoria desejável de menor impacto. | Inclua se houver capacidade depois dos itens essenciais, sem comprometer prazo ou qualidade. | Permitir ordenar a lista de checks por latência. |
| `MoSCoW: Won’t have (nesta entrega)` | Fora do escopo da entrega ou período nomeado. | Registre o nome da entrega/período e o motivo de exclusão quando conhecido. | Exportação CSV fora do MVP inicial; reavaliar após feedback do MVP. |

## Prioridade P0–P4

Os níveis abaixo são uma **proposta inicial**, pois não foi encontrada convenção P0–P4 nos arquivos Markdown, YAML, JSON pesquisados no repositório. Confirme-os com a equipe antes de tratá-los como padrão do quadro. Expectativas de resposta são orientativas e precisam ser acordadas pela equipe; não constituem SLA.

| Label sugerida | Impacto e expectativa inicial | Exemplo | Quando subir ou reduzir |
|---|---|---|---|
| `P0` | Incidente crítico, risco de segurança ou bloqueio total do fluxo essencial. Avaliar e atuar imediatamente, interrompendo trabalho planejado se necessário. | Segredo exposto em logs ou serviço principal indisponível para todos. | Suba se o impacto for generalizado, houver risco ativo ou não existir alternativa. Reduza após contenção e reclassifique o trabalho restante pelo impacto atual. |
| `P1` | Impacto muito alto em função central ou grupo relevante, sem alternativa aceitável. Avaliar no mesmo dia útil. | Check de banco falha sempre por regressão e deixa o diagnóstico principal inutilizável. | Suba se se tornar bloqueio geral ou risco ativo. Reduza se houver contorno seguro ou o impacto se limitar a caso raro. |
| `P2` | Trabalho normal com valor claro, planejado no ciclo ou fila atual. Avaliar durante o planejamento regular. | Ajustar mensagem de erro que dificulta entender uma falha, mas permite recuperar o diagnóstico. | Suba se dados mostrarem impacto maior ou prazo real. Reduza se benefício, frequência ou alcance forem menores que o esperado. |
| `P3` | Impacto baixo, melhoria local ou problema com alternativa simples. Tratar quando houver capacidade. | Melhorar alinhamento de um elemento secundário da UI. | Suba se a frequência ou o custo para usuários aumentar. Reduza se houver solução simples ou benefício pouco demonstrado. |
| `P4` | Ideia futura, exploração ou trabalho sem compromisso de execução. Sem prazo de resposta. | Avaliar suporte a um driver adicional ainda sem demanda confirmada. | Suba quando evidência, demanda ou compromisso de entrega aparecer. Remova ou arquive se a hipótese perder relevância. |

P0–P4 não representa story points, urgência de Eisenhower nem categoria MoSCoW. Reavalie a prioridade quando mudarem o impacto, o alcance, a existência de alternativa, o risco ou o prazo acordado.
