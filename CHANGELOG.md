# Novidades do Auto Reconnect Roblox

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
