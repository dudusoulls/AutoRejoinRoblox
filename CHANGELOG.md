# Novidades do Auto Reconnect Roblox

## v1.5.28
- Configurações reorganizada: versão com botões à direita (sem sobrepor), licença menor, as 3 opções de atualização juntas num cartão e novidades embaixo.

## v1.5.27
- "O que mostrar no painel" foi para Configurações (nova subaba Exibir).
- OCR: com o Modo AA ligado ele lê sempre (antes só lia se algum painel estivesse ligado) e tenta de novo mais rápido enquanto não achar nada.
- Nome do modo: limpa símbolos e letras trocadas e corrige pelo nome mais parecido (ex.: "Rain Village Infinite Mode").

## v1.5.26
- Bot oficial conectado: o app já aponta para o servidor do bot (aba Bot → Bot oficial).

## v1.5.25
- O botão "Convidar o bot" agora abre o convite do bot oficial.

## v1.5.24
- Leitura e Avançado foram para Configurações (subabas ao lado de Configurações). Aparência ficou só com temas e HUD.

## v1.5.23
- A busca de atualização a cada 30 s agora vem **desligada** por padrão (Sobre → atualização rápida). O app continua procurando ao abrir e a cada 6 horas.

## v1.5.22
- Corrige o layout da aba Bot: as páginas Bot oficial e Bot e comandos usavam a largura estreita da lista lateral e ficavam deslocadas, com textos sobrepostos. Agora ocupam a largura toda; o título da aba é só "Bot".

## v1.5.21
- Botão "Convidar o bot" também na aba Bot → Bot oficial.

## v1.5.20
- O Bot ganhou uma aba própria em EXTRAS, com "Bot oficial" (vínculo) e "Bot" (seu próprio bot). Sai de dentro de Discord.

## v1.5.19
- Com o Modo AA desligado, nada do jogo vai pro Discord: moedas, guilda, farm e leitura saem do painel, do status, do resumo diário e dos comandos.

## v1.5.18
- Painel fixo (1 embed que se atualiza sozinho) redesenhado com mais recursos do Discord: títulos, seções (Farm, Moedas, PC), blocos coloridos com barras de CPU/RAM, link do jogo clicável e valores em negrito.
- A aba Painel agora aparece também com o Modo AA desligado.

## v1.5.17
- **Bot oficial v2** (pasta `bot-worker/`, Cloudflare Worker, sem PC ligado): aba Discord → Bot oficial com código de vínculo. O usuário usa `/vincular` e depois `/roblox comando:...` no próprio servidor, controlando só o próprio Roblox; o webhook é criado e preenchido sozinho. Substitui o bot Python simples.

## v1.5.16
- Temas refeitos: 15 paletas bem diferentes entre si (Aero Glass, Obsidian, Aurora, Ember, Nebula, Crimson, Lagoon, Mocha, Lime, Neon, Void, Gold, Pearl, Sakura, Mint). Quem usava um tema removido volta pro Aero Glass.
- Texto mais nítido (ClearType) em toda a interface.
- Ferramentas: cartões "Convidar o bot" e "ID do app" (preparação pra vincular o app a um bot oficial).

## v1.5.15
- Nova aba **Ferramentas** (EXTRAS): backup e restauração das configurações, pasta de dados, log de erros, copiar diagnóstico, limpar logs/cache, fechar todos os Roblox e reiniciar o app, em cartões grandes.
- Barra lateral em degraus: nomes maiores primeiro em cada seção (ROBLOX, EXTRAS, APP). A linha de ferramentas saiu do Início.

## v1.5.14
- Nova aba **Rotina** (Automação): pausar o monitoramento por 15 min / 30 min / 1 h / 2 h, reinício preventivo do Roblox a cada X horas e aviso quando a internet cair.
- Áreas de leitura: âncora automática (esquerda/centro/direita e topo/meio/baixo) ao mudar o tamanho da janela, então a barra de moedas embaixo acompanha.
- Lembrete: guilda, moedas e leitura só funcionam com o **Modo AA** ligado (Automação → Opções).

## v1.5.13
- Vigia de recursos gráficos: registra nos Logs quando o uso de objetos GDI está alto e reinicia o app antes de os controles ficarem pretos.

## v1.5.12
- Posição da janela: agora é usada já na abertura e salva a cada 2 s (não se perde se o app fechar de repente).
- Barra de baixo sem status duplicado (fica só o da lateral esquerda).
- Modo normal: Avançado mostra só Efeitos; Início ganha Ferramentas (backup das configurações, pasta de dados, log de erros).

## v1.5.11
- O interruptor do Modo AA agora fica no topo de Automação → Opções (antes estava no fim da página, escondido).

## v1.5.10
- Barra lateral com separadores: ROBLOX (Jogo, Automação), INTEGRAÇÕES (Discord, QoL) e APP (Aparência, Logs, Sobre, Suporte).

## v1.5.9
- A janela lembra onde estava da última vez (posição salva ao fechar/esconder; se o monitor mudou, abre centralizada).

## v1.5.8
- Novo **Modo AA** (Opções), desligado por padrão: guilda, moedas, painel ao vivo, HUD e áreas de leitura só aparecem e funcionam com ele ligado. Desligado, o app é só o Auto Reconnect e suas funções. O app reinicia ao alternar.

## v1.5.7
- Barra de moedas: reconhece cada moeda pela cor do ícone (gold amarelo, gem arco-íris, pearl rosa) em vez da ordem, lê números azulados/lilás (gems) e corrige 8↔0 votando entre várias leituras.

## v1.5.6
- Leituras de OCR agora num agendador único: nunca se sobrepõem e se adaptam ao tempo gasto (poupa CPU/FPS). Intervalo ajustável em `[cfg] ocrSec` no ini (padrão 15s, mínimo 2s).

## v1.5.5
- Moedas: lê os números da barra de moedas (sem nomes) pela área "Moedas": ampliação, isolamento do texto claro e ordem esquerda→direita (Gems, Gold, Pearls)
- Webhook com visual novo: painel ao vivo com cabeçalho grande, modo/wave em destaque, moedas em bloco colorido e cartões compactos; avisos com horário em texto pequeno e conteúdo em citação

## v1.5.4
- Rank da guilda lê texto minúsculo (sem zoom): a área é ampliada até ~8x e só o branco do texto é isolado (preto no branco) antes do OCR, com votação entre 3 limiares

## v1.5.3
- Se existir um Roblox mais novo que o instalado, o app não abre mais a versão antiga direto: abre pelo launcher oficial, que atualiza antes
- O card de versão mostra o código da build (6 letras) em uso e o da mais recente, e só marca "atualizado" se a mais nova instalada for a atual

## v1.5.2
- Corrige a GUI quebrada (cards cinza cobrindo os textos): o contorno dos cards ficava por cima
- Logo animado reescrito para usar um controle de imagem de verdade

## v1.5.1
- Som de clique em botões, abas e chaves (liga/desliga em Aparência > Avançado > Efeitos)
- Logo animado: o anel de tinta agora anima no canto da barra lateral (também dá para desligar)

## v1.5.0
- Relatório de erro em 1 clique: quando o app tem um erro interno, ele continua rodando e abre uma janela com "Enviar relatório" (abre uma Issue do GitHub já preenchida com erro, versões e últimas linhas do log, sem webhook/token)
- Botão "Reportar problema" na aba Logs; erros também ficam salvos em erros.log

## v1.4.9
- OCR mais preciso em números pequenos: área mínima automática, várias ampliações com votação do número mais repetido e correção de letras parecidas com dígitos (O→0, l→1, S→5...)

## v1.4.8
- Visual novo "Aero Glass" (azul vidro) como tema padrão, com contorno luminoso nos cards (dá pra trocar em Aparência)
- Nova animação de abertura: tela com logo e barra de progresso que some em fade e dá lugar à janela principal

## v1.4.7
- Tela Início reorganizada: tudo cabe na janela, cards mais compactos com detalhes coloridos, versão do Roblox logo abaixo das estatísticas

## v1.4.6
- Tela Início: card com a versão do Roblox em uso e a mais recente, com aviso de atualizado/desatualizado

## v1.4.5
- Rank da guilda: o painel vertical mostra mesmo sem ler o modo; leitura aceita número sem o # e tenta várias escalas; primeira leitura aparece na hora; log mais detalhado

## v1.4.4
- Seguir a resolução mais preciso em janelas de outras proporções (escala pelo menor lado + pequena folga nas áreas)

## v1.4.3
- Tela Início: nova linha com o Rank da guilda e o Modo de farm (liga/desliga em Discord > Guilda > Mostrar na tela Início)
- O rank da guilda agora é lido mesmo quando o modo/wave/pearls não são lidos, e também sem o HUD Painel de farm nem o painel do Discord ligados

## v1.4.2
- A barra Salvar/Padrão/Cancelar do ajuste de área agora pode ser arrastada (clique e segure no título ou no texto dela)

## v1.4.1
- Corrigido o erro "Too many parameters passed to function: AreaEdit" ao clicar em Ajustar área / Padrão
- Testar leitura e Ler agora escondem a janela do programa por um instante se ela estiver por cima do Roblox (a leitura é feita olhando a tela)

## v1.4.0
- Nova aba Aparência > Avançado, pra qualquer monitor ou resolução:
  - as áreas de leitura acompanham o tamanho da janela do Roblox (cresce ou diminui junto)
  - o programa lembra o tamanho da janela quando você redimensiona (não volta ao antigo)
  - opção de mostrar na tela, com contornos coloridos, onde ele está lendo
- Nova aba Discord > Guilda: rank atual, botão Ler agora, rank no painel e no relatório, aviso no webhook quando o rank mudar
- O relatório de status do Discord agora inclui modo, wave, pearls e rank da guilda

## v1.3.15
- Aba Leitura: agora cada coisa tem a sua própria área (Modo, Wave, Pearls do evento, Moedas e Rank da guilda)
- Corrigido: depois de mover a área, os botões Salvar/Padrão/Cancelar ficavam inclicáveis

## v1.3.14
- Nova aba Aparência > Leitura: você escolhe onde o programa lê na tela, igual ao recorte de tela do Windows (desenha a área, move e puxa as bordas)
- Áreas separadas para Modo/Wave/Pearls e para o Rank da guilda, com botão Padrão e botão Testar leitura

## v1.3.13
- Depois de atualizar, abre uma janelinha com as novidades da versão (dá pra desligar em Configurações, e tem o botão "Ver agora")
- Aba HUD: nova opção para mostrar ou esconder o Rank da guilda (desligado também não gasta leitura de tela)

## v1.3.12
- Rank da guilda só muda quando a mesma leitura se repete 2 vezes seguidas (menos erro de OCR)

## v1.3.11
- Rank da guilda: leitura focada no lugar onde a tag aparece em cima do personagem, bem mais ampliada, e com aviso nos Logs se não achar

## v1.3.10
- Lê o rank da guilda (o #número logo abaixo da foto da guilda) e mostra no HUD e na embed do Discord

## v1.3.9
- Aba HUD: escolha o que aparece no painel (Status, Modo de farm, Moedas, Logs); o painel encolhe sozinho se tirar os Logs
- Desligar "Moedas" também tira as moedas dos outros modos de HUD

## v1.3.8
- Leitura de Wave e Pearls mais tolerante (aceita o ícone colado no número, wave na mesma linha) e tenta outros modos de captura quando falta algo
- Se faltar wave ou pearls, escreve nos Logs o que o OCR enxergou

## v1.3.7
- O tempo AFK agora é salvo: fechar o programa ou parar o monitoramento não zera; só zera quando detecta que o Roblox caiu

## v1.3.6
- Removida a linha colorida do topo do painel lateral (a cor de status fica só na moldura do Roblox)

## v1.3.5
- HUD Painel de farm redesenhado: cantos arredondados, faixa de cor do status, cartão de Modo de farm, número de Pearls grande
- O nome do modo e as Pearls aparecem na mesma cor que têm no jogo
- Leitura do modo mais robusta (tenta mais jeitos de ler a tela) e, se falhar, escreve nos Logs o que enxergou
- O painel não pisca mais e o clique nele abre o programa

## v1.3.4
- Lê também o contador de Pearls que sobe durante o modo (HUD Painel de farm e embed do Discord) e guarda o total da rodada anterior

## v1.3.3
- O programa lê o nome do modo/mapa que aparece em cima da vida da base no Roblox e mostra no HUD (Painel de farm) e no embed do Discord
- "Painel fixo no canal" agora funciona só com o Webhook: uma única mensagem que se atualiza sozinha, sem floodar e sem precisar do Bot
- Se o Bot der erro de token (HTTP 401), o painel passa a usar o Webhook sozinho e o aviso explica como gerar outro token
- O token do Bot aceita colar com "Bot " na frente, aspas ou espaços

## v1.3.2
- Aba HUD: agora os 5 modos aparecem numa lista, é só clicar no que quiser (inclui o novo Painel de farm)

## v1.3.1
- O programa agora sempre abre no modo completo (nunca no compacto)

## v1.3.0
- Barras deslizantes corrigidas: agora é só clicar e arrastar
- Animação de entrada ao abrir o programa
- Visual novo nas abas com lista lateral: busca, bolinhas e título da seção
- Barra de status embaixo da janela
- Novo HUD: painel de farm do lado do Roblox (Status, Moedas e Logs)
- Opção de procurar atualização a cada 30 segundos
- Aba "Sobre" agora se chama "Configurações"

## v1.2.0 (BETA)
- **Visual novo** inspirado em executores: lista de seções ao lado e linhas com divisória em vez de caixas soltas.
- A aba **Discord** virou **Webhook**, com tudo junto: Conexão, O que enviar, Painel ao vivo, Bot e comandos e Relatório.
- Nova aba **QoL**: Moedas, Travamento e Histórico (só leitura da tela, nada de script).
- **Barras deslizantes** nos campos de minutos (relatório, painel ao vivo e detecção de travamento).

## v1.0.7 (BETA)
- A telinha de apoio agora aparece **antes do tutorial**. Na primeira vez, o tutorial começa assim que a pessoa fecha o apoio.


## v1.0.6 (BETA)
- **Apoie o dev**: uma telinha com QR Pix aparece quando o app abre, com uma mensagem simpática. Tem botão "Não mostrar mais" e aparece no máximo 1x por dia (nunca na primeira vez de alguém, pra não atropelar o tutorial).
- Dá pra ligar/desligar em Sobre › "Mostrar apoio ao dev".


## v1.0.5 (BETA)
- **Logo nova** no app (lateral/ícone) e nos embeds do Discord.
- **Webhook reformulado — menos spam**: nova aba **Discord › Notificações** com toggles do que é enviado ao webhook: Aberturas/reconexões, Quedas, Erros, Atualizações. As "reconexões" (que mais enchiam) vêm **desligadas** por padrão; o resto ligado. Respostas de comando no Discord continuam normais.
- **Removida a opção de RAM mín. (zombie)** do card Recuperação.
- **Removido o FPS boost** (limite de FPS) do Modo Econômico — o resto do eco (gráficos mínimos, som, prioridade) continua.


## v1.0.4 (BETA)
- **Corrige erro ao compilar em 32-bit** ("Call to nonexistent function" no SetWindowLongPtr). Agora o código usa a função certa em 32 ou 64 bits, então o .exe funciona compilado de qualquer jeito (mesmo assim, 64-bit é o recomendado).


## v1.0.3 (BETA)
- **Preparado pra virar .exe com auto-update**: quando rodar como .exe, o atualizador baixa o .exe novo da Release do GitHub e se troca sozinho (via um .bat ajudante), sem precisar de AutoHotkey instalado. Como .ahk, continua igual.


## v1.0.2 (BETA)
- **10 temas novos** (total 25): claros no estilo da referência (Marble, Sakura, Mint, Sky) e escuros variados (Sunset, Grape, Carbon, Gold, Ocean, Cyber).
- Grade de temas reorganizada pra 5 por linha (miniaturas menores) pra caber todos.


## v1.0.1 (BETA)
- **Fixar versão do Roblox** (aba Jogo): novo campo onde você cola a versão que o seu executor aceita (ex.: version-4ea8e85481e34f46). O app passa a abrir SEMPRE essa versão, em vez da mais nova. Deixe vazio pra abrir a mais nova (pra quem não usa executor).
- Botão **"Ver versões"** lista no Logs todas as versões do Roblox instaladas, pra você saber qual colar.


## v1.0.0 (BETA)
Recomeço da numeração: daqui pra frente as versões são mais pra melhorar do que adicionar. O app está marcado como BETA.
- **Abre sempre a versão mais recente do Roblox**: procura o RobloxPlayerBeta.exe da versão instalada mais nova (pela data de instalação da pasta) e abre essa primeiro. Mostra no Logs qual escolheu ("Versão do Roblox escolhida: version-...").
- **Mata o Roblox-fantasma antes de abrir** (processo preso sem janela), que era o que causava o "fecha antes da janela aparecer".
- **Atualizador agora volta versão também**: troca pela versão que está no GitHub sempre que for diferente da sua (pra frente ou pra trás).
- Selo **BETA** na lateral e na aba Sobre; versão reiniciada em 1.0.0.
- Tudo que havia antes continua: aba Suporte (com anexar imagem), !statsaovivo, botão "Matar todos os Roblox", painel ao vivo leve, e as correções de abertura (sem o bloqueio de internet furado, sem matar o Roblox enquanto carrega).
- Boas-vindas na primeira vez: o passo a passo já cumprimenta a pessoa pelo nome do Windows ao abrir pela primeira vez.


## v2.6.1c
- A detecção da "versão mais nova" agora usa a **data de criação da pasta** (quando a versão foi instalada), não a data do arquivo (que mudava ao abrir uma versão antiga).
- Agora ele **mostra no Logs qual pasta de versão escolheu** ("Versão do Roblox escolhida: version-..."), pra ajudar a confirmar se pegou a certa.


## v2.6.1b
- **Abre a versão mais nova do Roblox**: o app seguia o "atalho" do Windows, que às vezes aponta pra uma versão antiga instalada (daí o "fecha antes de abrir", porque o servidor recusa cliente velho). Agora ele procura o RobloxPlayerBeta.exe da versão **mais recente** instalada e abre essa primeiro — os métodos antigos ficam de reserva, caso não ache.


## Atualizador agora também volta versão (17/11)
- O botão/comando de atualizar passou a baixar a versão que está no GitHub sempre que ela for **diferente** da sua — antes só ia pra frente. Agora dá pra **voltar** pra uma versão anterior também: é só colocar a versão desejada no GitHub e mandar atualizar. (Base: código da v2.6.0.)


## Revertido para a v2.6.0 (17/11)
- A pedido, o app voltou para o código da v2.6.0. As versões 2.6.1 a 2.7.5 continuam no histórico do Git e podem ser recuperadas a qualquer momento.


## v2.7.5
- **Conserto da abertura**: a checagem de RAM (250MB) estava matando o Roblox enquanto ele carregava pelo link (na tela de loading ele usa pouca RAM), entrando num loop de abrir-e-matar. Agora o app só fecha o Roblox "fantasma" quando ele está SEM janela de verdade — RAM baixa com janela é tratada como loading normal.
- Aumentei a margem pra 60s sem janela antes de considerar travado.
- **Novo botão "Matar todos os Roblox"** na aba Jogo (card Recuperação), pra você fechar qualquer Roblox preso na hora.


## v2.7.4
- **Conserto do travamento**: o painel ao vivo fazia leituras pesadas (WMI/OCR) que podiam congelar o app inteiro — e app congelado não fecha nem reabre o Roblox. Agora o painel usa só dados leves (moedas já lidas, CPU/RAM rápidos), sem nada que trave.
- Junto com a v2.7.3 (que tirou o bloqueio de internet), o app volta a abrir o Roblox normal e a janela responde de novo.


## v2.7.3
- **Correção importante**: o app tinha parado de reabrir o Roblox em alguns PCs. A checagem de internet que eu tinha adicionado dava "sem internet" errado (a função do Windows é furada) e travava a reabertura. Removi esse bloqueio — o app volta a abrir o Roblox normalmente.


## v2.7.1
- **Conserta o painel ao vivo**: ele travava ao enviar porque mandava o print junto (anexo) pelo bot. Agora manda só os stats em texto/embed (igual aos comandos, que sempre funcionaram). O painel passa a aparecer e se atualizar normal.
- O painel mantém status, tempo de sessão, online hoje, RAM do Roblox, reaberturas, quedas, última queda e as moedas — só não leva mais o print (o print continua no !print e no status automático).


## v2.7.0
- Novo comando **!statsaovivo** (ou !painel / !stats / !live): liga o painel ao vivo e manda ele fixado no canal na hora, direto pelo Discord — sem precisar mexer no app.


## v2.6.2
- Painel ao vivo: agora **mostra o erro no Logs** quando não consegue enviar (antes falhava calado), e **se recria sozinho** se a mensagem fixada antiga tiver sumido ou travado.


## v2.6.1
- Aba Suporte agora deixa **anexar uma imagem qualquer** (botão "Anexar imagem" — PNG, JPG ou GIF), não só o print do Roblox. Antes, se o Roblox estivesse fechado/minimizado, não ia imagem nenhuma.
- A imagem escolhida tem prioridade; se não escolher nenhuma e o print do Roblox estiver ligado, vai o print como antes.


## v2.6.0
- **HUD virou sub-aba dentro de Aparência** (Aparência › HUD), separado dos temas — fica mais limpo que ter o HUD junto da aba Jogo.
- Webhook de suporte já vem configurado e **escondido no código** (montado em tempo de execução, não aparece como link), pra não ser encontrado por bots que varrem o GitHub.


## v2.5.2
- A aba **Suporte** agora aparece na barra lateral (o grupo tinha sido criado mas faltava o botão no menu).


## v2.5.1
- Corrige erro ao abrir com o painel lateral ("value of type Integer has no property named Hwnd"): faltava declarar as variáveis do painel lateral dentro da função que monta o HUD.


## v2.5.0
- **Novo 3º tipo de HUD: painel lateral**. Gruda na direita da janela do Roblox e mostra tudo que vai pro webhook: status, tempo de sessão, reaberturas, quedas, tempo online hoje, cada moeda, CPU, RAM e a RAM do Roblox. Clique nele abre o programa.
- Ele encosta do lado de fora da janela quando tem espaço; se não tiver, fica por cima da borda direita meio transparente, acompanhando o Roblox.
- Troque entre os modos no mesmo botão da aba Janela › HUD (Desligado › Barra › Painel no canto › Painel lateral).


## v2.4.0
- **Limite de RAM pro Roblox travado**: além de detectar o processo sem janela, agora o app também pega o Roblox fantasma pela RAM. Um jogo de verdade usa bem mais de 250MB; quando o processo fica abaixo do limite, o app entende que travou e **fecha todos e reabre**.
- O limite vem em **250 MB** por padrão e dá pra ajustar na aba Jogo › Recuperação ("RAM mín. (MB)"). Coloque 0 pra desligar só essa checagem.
- Espera a mesma margem (abertura + 45s) antes de agir, pra não fechar um Roblox que só está carregando.


## v2.3.0
- **Conserto do "Roblox fantasma"**: em PC fraco o Roblox às vezes trava e deixa o processo aberto sem janela nenhuma. O app achava que estava tudo certo e não reabria. Agora ele detecta o processo travado sem janela, **mata todos os Roblox e reabre sozinho** — ligado por padrão (aba Jogo › Recuperação).
- Espera uma margem (a espera pós-abrir + 45s) antes de dar como travado, pra não fechar um Roblox que só está demorando a carregar no PC fraco.


## v2.2.0
- Nova aba **Suporte**: o usuário escreve o problema e manda (com print do Roblox, se quiser) direto pro seu webhook secreto. Vai junto versão do app, Windows, nome do PC e um ID de instalação anônimo — **sem IP e sem dado pessoal**.
- **Botões no painel do Discord**: reações ▶️ (iniciar), ⏹️ (parar), 🔄 (reiniciar) e 📸 (print) no painel fixado. Toca pelo celular e o app obedece.
- **!grafico**: manda um gráfico dos últimos 7 dias (moedas ou tempo online) no Discord.
- **!gif**: manda vários prints seguidos do jogo (timelapse) numa mensagem só.
- **Espera a internet voltar**: se a conexão cair, o app pausa as tentativas de reabrir o Roblox, avisa, e retoma sozinho quando a net volta (em vez de ficar falhando à toa).


## v2.1.0
- HUD grudado na janela do Roblox: barra fina embaixo da janela (ou painel transparente no canto), com status, tempo de sessão, reaberturas, quedas, moedas, CPU e RAM.
- Moldura colorida em volta da janela do Roblox que muda de cor conforme o status (verde = farmando, amarelo = reconectando, vermelho = erro).
- Modo compacto agora pode virar o HUD: o app some e só o HUD fica na tela.
- Atalhos globais: Ctrl+Alt+H mostra/esconde o HUD, Ctrl+Alt+S inicia/para, Ctrl+Alt+R reinicia o Roblox, Ctrl+Alt+P manda status no Discord.
- HUD leve: posição atualizada 4x/s, texto 1x/s, só redesenha quando algo muda.


## v2.0.1
- Mais rápido: Discord, webhook e painel agora usam a internet em segundo plano (a janela não trava mais esperando)
- Leitura de tela (OCR) mais leve: lembra o jeito que funciona no seu PC e checa a tela de erro com menos frequência
- Log da janela não fica mais lento depois de horas aberto
- Medição de CPU sem pausar o programa; menos leituras do config.ini

## v2.0.0
- 15 temas na nova aba Aparência (Obsidian, Medium, Pearl, Aurora, Ember, Silk, Nebula, Lava Lamp, Lagoon, Borealis, Glass, Classic, Midnight, Slate e Rose)
- Barra lateral reorganizada em 8 itens, com sub-abas no topo (Jogo, Automação, Discord e Moedas)
- Troca de aba com fade suave e risquinho deslizando embaixo da sub-aba

## v1.9.0
- Painel ao vivo no Discord: uma mensagem fixa do bot com status, moedas, PC e print, que se atualiza sozinha
- Farm travado: avisa (com print) se as moedas pararem de subir por X minutos, e pode reiniciar sozinho
- Aviso de erro agora vem com o print da tela do erro antes de fechar o Roblox

## v1.8.0
- Respostas do bot mais completas: sessão, reaberturas, quedas, última queda e link em campos
- Comandos novos: !print, !moedas, !pc, !contas, !historico, !logs, !ping, !link, !atualizar, !desligar e !cancelar
- !reiniciar avisa quando o Roblox voltou pro jogo e quanto tempo levou
- !ajuda organizado por categoria

## v1.7.2
- Cada comando do Discord responde com um embed (como resposta à sua mensagem)
- !status e !resumo respondem pelo próprio bot, mesmo sem webhook
- !reiniciar abre direto pelo Roblox, igual ao botão "Abrir jogo agora"
- Parar o monitoramento também avisa no Discord

## v1.7.1
- Correção: erro ao mandar o segundo aviso seguido (ex: !reiniciar)
- Manda o status com print no Discord assim que o programa abre

## v1.7.0
- Bot do Discord: comandos !status, !iniciar, !parar, !reiniciar, !resumo e !ajuda (só obedece o seu ID)
- Link diferente pra cada conta no modo de várias contas (duplo clique na conta)
- Aba Histórico com gráfico dos últimos 14 dias (tempo online, quedas, reaberturas e moedas)
- Agendamento: monitorar só em um horário, parar depois de X horas e fechar o Roblox ou desligar o PC no fim
- Modo econômico: limite de FPS, gráficos no mínimo, som desligado e prioridade baixa pro Roblox

## v1.6.0
- Várias contas ao mesmo tempo (aba Contas, experimental)
- Marcar você no Discord quando cair ou der erro (só o seu ID, nunca @everyone)
- Iniciar junto com o Windows e começar a monitorar sozinho
- Resumo diário no Discord (tempo online, quedas, reaberturas e moedas ganhas)
- Notificação do Windows quando cair, voltar ou der erro
- Menu no ícone da bandeja e opção de minimizar pra bandeja
- Correção: o X da tela de key fechava o programa
- Correção: depois de atualizar sozinho o script não abria de novo

## v1.5.0
- Animações suaves: janelas aparecem/somem com fade, botões mudam de cor devagar
- Barrinha da barra lateral desliza até a aba escolhida
- Interruptores ON/OFF com transição
- Bolinha de status pulsando quando está online

## v1.4.0
- Logo nova na janela, na tela de key, no ícone da barra de tarefas e da bandeja
- Avisos do Discord com a logo como foto do webhook

## v1.3.1
- Tutorial não trava mais ao clicar fora: acompanha a janela, some se ela for minimizada e volta junto
- Tecla Esc fecha o tutorial

## v1.3.0
- Tutorial passo a passo na primeira vez que abre (marca cada item com seta e explicação)
- Botão "Ver tutorial" na aba Sobre pra rever quando quiser
- Correção: erro ao detectar a janela do Roblox na v1.2.0

## v1.2.0
- Novo nome: Auto Reconnect Roblox
- 8 idiomas (Português, English, Español, Français, Deutsch, Русский, Türkçe, Bahasa Indonesia), seguindo o idioma do Windows
- Botão de idioma no topo da janela
- Mostra o seu nome do Windows na tela
- Todos os avisos do Discord agora são embeds

## v1.1.0
- Sistema de licença com key travada por HWID (KeyAuth)
- Tela de ativação com HWID e botão de copiar
- Aba Sobre mostra a validade da key
- Atualizações podem vir pelo KeyAuth (só quem tem key baixa)

## v1.0.2
- Abertura sempre na ordem: direto pelo Roblox > link roblox:// > navegador
- Não fica mais preso no último jeito que funcionou

## v1.0.1
- Teste do sistema de atualização automática

## v1.0.0
- Abre o servidor direto pelo Roblox, sem precisar do navegador
- Detecta bem mais rápido quando o Roblox abriu e quando entrou no jogo
- Detecta a tela de "Disconnected" e reinicia sozinho
- Lê suas moedas na tela e manda no webhook com os emojis do servidor
- Aba "Sobre" com aviso de atualização e esta lista de novidades
