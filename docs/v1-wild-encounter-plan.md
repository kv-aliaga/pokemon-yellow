# V1 — Redistribuição de encontros de Pokémon

Plano aprovado para `[EPIC][V1] Redistribute wild Pokémon encounters`. A aprovação cobre as decisões registradas neste documento e nos JSONs referenciados; ainda não representa implementação no jogo.

**Decisão final do catálogo:** tabelas de caminhada/Surf alocadas foram aprovadas no formato original; candidatos sem local inequívoco e pedidos de novos encontros por vara foram rejeitados nesta versão. Ditto estático foi fixado no Rocket Hideout B4F após Giovanni. Mew fica sob o caminhão disponível em qualquer momento do save. Um lendário derrotado sem captura desaparece e pode reaparecer após uma vitória completa sobre a Elite dos Quatro enquanto ainda não tiver sido capturado. As trocas NPC para obter Alakazam, Golem, Machamp e Gengar formarão um ciclo: o NPC 1 recebe Machoke e entrega Haunter; o NPC 2 recebe Graveler e entrega Kadabra; o NPC 3 recebe Kadabra e entrega Machoke; o NPC 4 recebe Haunter e entrega Graveler. As quatro trocas e o reaparecimento de lendários não capturados estão aprovados como conteúdo de evento para implementação no MVP. As revivificações adicionais em Pewter foram aprovadas; o fluxo atual de Cinnabar permanece, ou seja, terão dois pontos de revivamento. Um em Pewter e outro em Cinnabar.

**Critério:** uma linha é considerada disponível quando o jogador pode obter pelo menos um integrante dela antes de desafiar Koga, o quinto ginásio. A coluna “Disponibilidade até Koga” contém uma avaliação provisória e subjetiva de acesso, não uma probabilidade de captura nem uma métrica calculada; os valores precisam ser reavaliados quando os marcos de campanha e seus requisitos forem definidos. As chances citadas nas propostas também são alvos aproximados, condicionais a já ter começado um encontro. Se a distribuição original de 10 slots for mantida, as chances finais precisam ser convertidas em somas dos pesos suportados (19,9%, 19,9%, 15,2%, 9,8%, 9,8%, 9,8%, 5,1%, 5,1%, 4,3% e 1,2%); por exemplo, “8%” não é um slot disponível e não deve ser copiado como chance exata. A taxa do mapa reduz a frequência de encontros por passo, não a chance condicional do slot. Os locais/fontes atuais são do Pokémon Yellow; quando a proposta adiciona algo, as fontes atuais permanecem, salvo mudança explícita indicada nesta tabela.

A base de locais foi conferida no [índice do RotomLabs para Yellow](https://rotomlabs.net/locations/yellow), incluindo [Route 4 e suas tabelas de pesca](https://rotomlabs.net/locations/yellow/route-4), [Viridian Forest](https://rotomlabs.net/locations/yellow/viridian-forest) e [Safari Zone](https://rotomlabs.net/locations/yellow/safari-zone-kanto). No jogo atual o Old Rod dá Magikarp, e o Good Rod alterna entre Poliwag e Goldeen; a proposta abaixo amplia os encontros sem retirar essas fontes.

| linha evolutiva | fonte atual | proposta de fonte até o Koga | impacto esperado na variedade de times | disponibilidade até Koga |
|---|---|---|---|---:|
| Bulbasaur → Ivysaur → Venusaur | Presente em Cerulean | Adicionar encontro a pé médio (8%) na Route 24; manter o presente | Opção Grass de status e resistência antes de Erika | 100% |
| Charmander → Charmeleon → Charizard | Presente na Route 24 | Adicionar encontro a pé médio (8%) na Route 3 ou 4; manter o presente | Opção Fire anterior a Celadon | 100% |
| Squirtle → Wartortle → Blastoise | Presente em Vermilion | Adicionar encontro a pé médio (8%) na Route 6; manter o presente | Opção Water antes de Koga | 100% |
| Caterpie → Metapod → Butterfree | Viridian Forest | Manter todas as fontes atuais | Opção Bug de evolução rápida no início | 100% |
| Weedle → Kakuna → Beedrill | Sem encontro capturável; aparece em equipes de treinadores | Adicionar encontro a pé comum (20%) em Viridian Forest, junto de Caterpie | Alternativa Bug/Poison logo no começo | 90% |
| Pidgey → Pidgeotto → Pidgeot | Routes 1–2, 5–8 e Viridian Forest | Manter todas as fontes atuais | Opção Flying acessível sem desvio | 100% |
| Rattata → Raticate | Routes 1–2, 5–11 e outras | Manter todas as fontes atuais | Atacante Normal simples e acessível | 100% |
| Spearow → Fearow | Routes 3–4 e 16–18 | Manter todas as fontes atuais | Alternativa Flying com progressão simples | 100% |
| Ekans → Arbok | Sem encontro capturável; aparece em equipes de treinadores | Adicionar encontro a pé médio (8%) em Routes 3–4, junto de Sandshrew | Mais uma opção Poison antes de Misty | 75% |
| Pikachu → Raichu | Pikachu recebido no laboratório do Oak; sem encontro a pé | Adicionar encontro a pé médio (8%) em Viridian Forest; manter o inicial | Permite obter a linha sem depender do inicial | 100% |
| Sandshrew → Sandslash | Routes 3–4 e Mt. Moon | Manter todas as fontes atuais | Opção Ground antes de Mt. Moon | 100% |
| Nidoran♂ → Nidorino → Nidoking | Routes 2 e 22; Safari Zone | Manter todas as fontes atuais | Linha versátil de Poison/Ground | 100% |
| Nidoran♀ → Nidorina → Nidoqueen | Routes 2 e 22; Safari Zone | Manter todas as fontes atuais | Segunda opção Poison/Ground com perfil próprio | 100% |
| Clefairy → Clefable | Mt. Moon | Manter todas as fontes atuais | Opção resistente com evolução por pedra | 80% |
| Vulpix → Ninetales | Prêmio do Game Corner em Celadon | Adicionar encontro a pé comum (10%) em Route 7; manter o prêmio | Fire acessível por exploração e por moedas | 90% |
| Jigglypuff → Wigglytuff | Routes 5–8; Wigglytuff também no Game Corner | Manter todas as fontes atuais | Opção Normal com acesso a evolução por pedra | 100% |
| Zubat → Golbat | Mt. Moon, Rock Tunnel e outras cavernas | Manter todas as fontes atuais | Opção Poison/Flying de caverna | 100% |
| Oddish → Gloom → Vileplume | Routes 12–15 e 24–25 | Manter todas as fontes atuais | Grass/Poison após Misty | 100% |
| Paras → Parasect | Mt. Moon e Safari Zone | Manter todas as fontes atuais | Opção Bug/Grass acessível cedo | 90% |
| Venonat → Venomoth | Routes 14–15 e 24–25 | Manter todas as fontes atuais | Alternativa Bug/Poison no meio inicial | 100% |
| Diglett → Dugtrio | Diglett’s Cave | Manter todas as fontes atuais | Ground rápido após Surge | 100% |
| Meowth → Persian | Sem fonte local identificada | Adicionar encontro a pé comum (10%) em Route 5, junto de Rattata | Amplia opções Normal sem concentrar tudo em Route 1 | 90% |
| Psyduck → Golduck | Psyduck a pé na Route 6; Golduck via evolução | Adicionar Psyduck à pesca de água doce na Route 6 (comum, 15%) e Golduck ao Surf (médio, 6%); manter a fonte a pé e evolução | Opções Water para quem prefere pesca ou Surf | 100% |
| Mankey → Primeape | Routes 3–4 e 22 | Manter todas as fontes atuais | Opção Fighting antes de Misty | 100% |
| Growlithe → Arcanine | Pokémon Mansion | Adicionar encontro a pé médio (8%) em Route 7 ou 8; manter a Pokémon Mansion | Traz opção Fire para a campanha intermediária | 80% |
| Poliwag → Poliwhirl → Poliwrath | Good Rod; Super Rod em algumas rotas | Manter todas as fontes atuais; adicionar ao Old Rod de água doce (médio, 8–10%) | Mais opções Water/Fighting sem exigir Surf | 80% |
| Abra → Kadabra → Alakazam | Routes 5–8 e Game Corner; Alakazam requer troca externa | Manter todas as fontes atuais; NPC 2 recebe Graveler e entrega Kadabra antes de Koga | Acesso Psychic cedo e evolução final sem troca externa | 100% |
| Machop → Machoke → Machamp | Route 10 e Rock Tunnel; Machamp requer troca externa | Manter todas as fontes atuais; NPC 3 recebe Kadabra e entrega Machoke antes de Koga | Opção Fighting com evolução final no próprio jogo | 100% |
| Bellsprout → Weepinbell → Victreebel | Routes 12–15 e 24–25 | Manter todas as fontes atuais | Alternativa Grass/Poison a Oddish | 100% |
| Tentacool → Tentacruel | Surf em rotas costeiras; Super Rod em algumas rotas | Manter todas as fontes atuais; adicionar Tentacool ao Old Rod costeiro (médio, 8–10%) | Opção Water/Poison antes de liberar Surf | 80% |
| Geodude → Graveler → Golem | Mt. Moon e Rock Tunnel; Golem requer troca externa | Manter todas as fontes atuais; NPC 4 recebe Haunter e entrega Graveler antes de Koga | Opção Rock/Ground com evolução final no próprio jogo | 100% |
| Ponyta → Rapidash | Route 17 e Pokémon Mansion | Manter todas as fontes atuais | Opção Fire disponível antes de Koga pela Cycling Road | 85% |
| Slowpoke → Slowbro | Routes 12–13 e rods | Manter todas as fontes atuais | Water/Psychic defensivo antes de Koga | 80% |
| Magnemite → Magneton | Route 10 e Power Plant | Manter todas as fontes atuais | Opção Electric antes de Erika | 85% |
| Farfetch’d | Routes 12–13 a pé | Manter todas as fontes atuais | Opção Flying/Normal com perfil incomum | 80% |
| Doduo → Dodrio | Routes 16–18 | Manter todas as fontes atuais | Outra opção Flying antes de Koga | 80% |
| Seel → Dewgong | Seafoam Islands | Manter todas as fontes atuais; adicionar Seel à pesca média (6–8%) nas águas de Routes 17–18 | Opção Water/Ice antes de Koga | 75% |
| Grimer → Muk | Power Plant e Pokémon Mansion | Manter todas as fontes atuais; adicionar encontro a pé médio (6–8%) em Route 10 | Opção Poison antes de Koga | 75% |
| Shellder → Cloyster | Super Rod em áreas costeiras | Manter todas as fontes atuais; adicionar Shellder ao Old Rod costeiro (médio, 6–8%) | Opção Water/Ice antecipada | 75% |
| Gastly → Haunter → Gengar | Pokémon Tower; Gengar requer troca externa | Manter todas as fontes atuais; NPC 1 recebe Machoke e entrega Haunter antes de Koga | Opção Ghost e evolução final sem troca externa | 90% |
| Onix | Rock Tunnel e Victory Road | Manter todas as fontes atuais | Opção Rock/Ground antes de Erika | 80% |
| Drowzee → Hypno | Route 11 | Manter todas as fontes atuais | Opção Psychic sem depender do Game Corner | 85% |
| Krabby → Kingler | Super Rod em Routes 10 e 25, entre outras | Manter todas as fontes atuais; adicionar Krabby ao Good/Super Rod na Route 10 (médio, 6–8%) | Alternativa Water física antes de Koga | 75% |
| Voltorb → Electrode | Power Plant | Manter a Power Plant; adicionar encontro a pé médio (6–8%) em Route 10 | Opção Electric antes de Koga sem concentrar tudo na Power Plant | 75% |
| Exeggcute → Exeggutor | Safari Zone | Manter todas as fontes atuais | Opção Grass/Psychic durante a campanha intermediária | 60% |
| Cubone → Marowak | Pokémon Tower e Safari Zone | Manter todas as fontes atuais | Opção Ground acessível antes de Koga | 90% |
| Hitmonlee | Presente no Fighting Dojo; escolha entre ele e Hitmonchan | Manter a escolha no Dojo; adicionar Hitmonlee e Hitmonchan no slot raro atual (1,2%) em Victory Road | O escolhido fica garantido; o outro continua obtível no pós-jogo | 50% |
| Hitmonchan | Presente no Fighting Dojo; escolha entre ele e Hitmonlee | Manter a escolha no Dojo; adicionar Hitmonlee e Hitmonchan no slot raro atual (1,2%) em Victory Road | O escolhido fica garantido; o outro continua obtível no pós-jogo | 50% |
| Lickitung | Cerulean Cave, pós-Liga | Adicionar encontro a pé raro (4,3%) no B1F de Rock Tunnel; manter Cerulean Cave. Não adicionar fontes fora de cavernas | Linha Normal resistente disponível na exploração de cavernas antes e depois da Liga | 75% |
| Koffing → Weezing | Sem fonte local identificada | Adicionar encontro a pé médio (6–8%) em Route 8, junto de Grimer quando este for redistribuído; não retirar as fontes atuais de Grimer | Expande Poison com estilos de combate diferentes | 75% |
| Rhyhorn → Rhydon | Safari Zone | Manter todas as fontes atuais | Opção Ground/Rock antes de Koga | 60% |
| Chansey | Safari Zone | Manter todas as fontes atuais | Opção defensiva e de suporte | 60% |
| Tangela | Safari Zone | Manter Safari Zone; adicionar Tangela à tabela de **qualquer rod** em Pallet Town (médio, 6–8%) | A linha fica acessível por pesca, sem depender da Safari | 80% |
| Kangaskhan | Safari Zone | Manter todas as fontes atuais | Atacante Normal robusto de meio de jogo | 60% |
| Horsea → Seadra | Super Rod em Routes 10–13 e outras | Manter todas as fontes atuais; adicionar chance média (6–8%) no Good Rod costeiro | Expande Water e variedade de evoluções | 80% |
| Goldeen → Seaking | Good Rod e Super Rod | Manter todas as fontes atuais; adicionar ao Old Rod de água doce (comum, 10–15%) | Opção Water antes de Koga | 90% |
| Staryu → Starmie | Super Rod em Pallet e áreas costeiras | Manter todas as fontes atuais; adicionar chance média (6–8%) no Good Rod costeiro | Opção Water/Psychic com acesso anterior | 80% |
| Mr. Mime | Troca de Clefairy na Route 2 | Manter a troca; adicionar encontro a pé médio (6–8%) em Route 2 | Psychic acessível sem depender de Clefairy para troca | 85% |
| Scyther | Safari Zone e Game Corner | Manter todas as fontes atuais | Opção Bug/Flying disponível antes de Koga | 60% |
| Jynx | Sem fonte local identificada | Adicionar encontro a pé raro (4,3%) na Route 8 antes de Koga e manter outro encontro raro (4,3%) nos andares profundos de Seafoam Islands, B3F/B4F | Opção Ice/Psychic rara já na campanha principal, com retorno temático nas Seafoam | 70% |
| Electabuzz | Sem fonte local identificada | Adicionar encontro a pé raro (4,3%) na Route 10 antes de Koga e manter outro encontro raro (4,3%) na Power Plant | Opção Electric ofensiva disponível antes de Koga e reforçada na Power Plant | 75% |
| Magmar | Sem fonte local identificada | Adicionar encontro a pé raro (4,3%) na Route 17 antes de Koga e manter outro encontro raro (4,3%) na Pokémon Mansion, de preferência no B1F | Opção Fire rara na Cycling Road, com retorno temático na Mansion | 70% |
| Pinsir | Safari Zone e Game Corner | Manter todas as fontes atuais | Opção Bug física antes de Koga | 60% |
| Tauros | Safari Zone | Manter todas as fontes atuais | Atacante Normal forte como opção de meio de jogo | 60% |
| Magikarp → Gyarados | Old Rod 100%; presente comprado no Mt. Moon Pokémon Center | Manter o Old Rod com Magikarp comum; transformar a tabela em encontros por local para abrir espaço a outros aquáticos | Preserva a linha clássica e diversifica a pesca | 100% |
| Lapras | Presente em Silph Co. | Manter o presente de Silph Co.; adicionar encontro por Surf muito raro (1–2%) em Routes 19–20 | O presente garante a linha; Surf oferece uma captura excepcional | 90% |
| Ditto | Pokémon Mansion e Cerulean Cave | Manter todas as fontes atuais; adicionar encontro estático na Rocket Hideout após Giovanni | Dá acesso a Transform durante a campanha principal | 90% |
| Eevee → Vaporeon / Jolteon / Flareon | Presente na mansão de Celadon | Adicionar encontro a pé médio (6–8%) na Route 5; manter o presente | Permite escolher evolução e equipe antes de Erika | 100% |
| Porygon | Prêmio caro do Game Corner em Celadon | Manter o prêmio com custo reduzido; adicionar encontro a pé médio (6–8%) em Route 7 | Opção Normal singular sem depender de grind de moedas | 85% |
| Omanyte → Omastar | Fóssil Helix em Mt. Moon; revivido em Cinnabar | Após Surge, fazer o jogador reencontrar no Museu de Pewter o mesmo Super Nerd da B2F de Mt. Moon. Na revanche, usar equipe mais forte incluindo Kabuto, o fóssil oposto ao Helix escolhido pelo jogador; ao vencer, ele entrega o Dome Fossil. Permitir revivificar fósseis tanto no Museu de Pewter quanto em Cinnabar | Linha Water/Rock obtível antes de Koga; recompensa depende de vencer a revanche | 90% |
| Kabuto → Kabutops | Fóssil Dome em Mt. Moon; revivido em Cinnabar | Após Surge, fazer o jogador reencontrar no Museu de Pewter o mesmo Super Nerd da B2F de Mt. Moon. Na revanche, usar equipe mais forte incluindo Omanyte, o fóssil oposto ao Dome escolhido pelo jogador; ao vencer, ele entrega o Helix Fossil. Permitir revivificar fósseis tanto no Museu de Pewter quanto em Cinnabar | Linha Water/Rock obtível antes de Koga; recompensa depende de vencer a revanche | 90% |
| Aerodactyl | Old Amber no Museu de Pewter; revivido em Cinnabar | Manter o fluxo de Cinnabar; permitir também revivificar o Old Amber no Museu de Pewter após Cut | Linha Rock/Flying disponível na campanha principal | 90% |
| Snorlax | Encontro estático nas Routes 12 e 16, após obter Poké Flute | Manter os dois encontros estáticos atuais | Opção Normal robusta e garantida na progressão | 90% |
| Dratini → Dragonair → Dragonite | Super Rod na Safari Zone | Manter todas as fontes atuais | Opção Dragon rara, mas acessível durante a campanha | 60% |
