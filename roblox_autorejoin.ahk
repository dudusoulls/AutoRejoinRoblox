#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================================
;  Auto Reconnect Roblox  (tema Obsidian)
;  - Reabre o Roblox no jogo/PV se ele fechar
;  - Posiciona a janela do Roblox no canto superior direito
;  - Fecha a guia nova do navegador depois que entrar no jogo
;  - Webhook: avisos de queda + status periódico (embed + print)
;  - Modo compacto
;  - Atualização automática pela nuvem
; ==========================================================

; ---------------- Versão / atualização ----------------
; Pra lançar uma atualização:
;   1) aumente o VERSION aqui embaixo (ex: 2.4.0 -> 2.4.1)
;   2) escreva o que mudou no topo do CHANGELOG.md
;   3) suba os dois arquivos no GitHub
; Quem usa o script vê o aviso "Nova versão" com as novidades e atualiza com 1 clique.
VERSION     := "2.0.1"
GITHUB_REPO := "dudusoulls/AutoRejoinRoblox"
GITHUB_BRANCH := "main"

; ---------------- Licença (KeyAuth - keyauth.cc) ----------------
; Pegue esses dados em keyauth.cc > sua aplicação. Com KEYAUTH_OWNERID vazio a key fica DESLIGADA.
; Com a key ligada, as atualizações também passam a vir do KeyAuth (só quem tem key baixa):
;   variáveis da aplicação:  versao = "1.1.1"   arquivo = ID do arquivo enviado em Files   novidades = texto
KEYAUTH_NAME    := ""            ; nome da aplicação
KEYAUTH_OWNERID := ""            ; Owner ID (10 caracteres)
KEYAUTH_VER     := "1.0"         ; versão da aplicação no painel do KeyAuth (deixe sempre 1.0)
KEYAUTH_URL     := "https://keyauth.win/api/1.3/"
BUY_URL         := ""            ; link pra comprar key (Discord, loja...). Vazio = esconde o botão
APP_NAME        := "Auto Reconnect Roblox"

; ---------------- Tema ----------------
C_BG    := "0E0E11"   ; fundo do conteúdo
C_SIDE  := "09090B"   ; barra lateral
C_CARD  := "16161A"   ; cards
C_INPUT := "212127"   ; campos de texto
C_TEXT  := "EDEDF0"
C_MUTED := "8B8B94"
C_DIM   := "55555D"
C_ACC   := "F2F2F4"   ; botão principal (branco)
C_ACCH  := "D4D4D9"
C_BTN   := "25252C"
C_BTNH  := "303039"
C_NAVA  := "1A1A1F"
C_NAVH  := "131316"
C_SWOFF := "2C2C33"
C_ON    := "3DDC84"
C_OFF   := "FF5C5C"
C_WARN  := "F5C542"

; ---------------- Estado ----------------
iniFile  := A_ScriptDir "\config.ini"
; temas (Aparência): troca as cores acima antes de montar a janela
THEMES := [
    {name: "Obsidian", BG: "0E0E11", SIDE: "09090B", CARD: "16161A", INPUT: "212127", TEXT: "EDEDF0", MUTED: "8B8B94", DIM: "55555D", ACC: "F2F2F4", ACCH: "D4D4D9", BTN: "25252C", BTNH: "303039", NAVA: "1A1A1F", NAVH: "131316", SWOFF: "2C2C33"},
    {name: "Medium", BG: "151517", SIDE: "0F0F11", CARD: "1C1C20", INPUT: "26262C", TEXT: "EDEDF0", MUTED: "8E8E97", DIM: "5A5A62", ACC: "F2F2F4", ACCH: "D4D4D9", BTN: "2A2A31", BTNH: "35353D", NAVA: "222228", NAVH: "18181B", SWOFF: "32323A"},
    {name: "Pearl", BG: "F4F4F6", SIDE: "E9E9EE", CARD: "FFFFFF", INPUT: "EFEFF3", TEXT: "18181C", MUTED: "5F5F68", DIM: "9A9AA3", ACC: "18181C", ACCH: "3A3A42", BTN: "E6E6EB", BTNH: "DADAE0", NAVA: "DCDCE3", NAVH: "E2E2E8", SWOFF: "D6D6DC"},
    {name: "Aurora", BG: "0B1418", SIDE: "071013", CARD: "102027", INPUT: "173039", TEXT: "E6F6F4", MUTED: "86A9A6", DIM: "4F6E6C", ACC: "3DDCA8", ACCH: "2FB98C", BTN: "18323B", BTNH: "214350", NAVA: "15303A", NAVH: "0F2228", SWOFF: "21404A"},
    {name: "Ember", BG: "140C08", SIDE: "0E0805", CARD: "1E130D", INPUT: "2A1B12", TEXT: "F7ECE4", MUTED: "B09382", DIM: "6E5546", ACC: "FF7A2E", ACCH: "E2611A", BTN: "33211A", BTNH: "402A20", NAVA: "2C1C14", NAVH: "1C120C", SWOFF: "3A271C"},
    {name: "Silk", BG: "120F1A", SIDE: "0C0A12", CARD: "1B1726", INPUT: "251F33", TEXT: "F0ECF8", MUTED: "9E95B5", DIM: "625A78", ACC: "E9A8E0", ACCH: "D18BC7", BTN: "2B2440", BTNH: "362D4F", NAVA: "262036", NAVH: "1A1626", SWOFF: "342C48"},
    {name: "Nebula", BG: "120A18", SIDE: "0C0611", CARD: "1D1026", INPUT: "2A1736", TEXT: "F5EAF8", MUTED: "AD8FBA", DIM: "6C5277", ACC: "FF5CA8", ACCH: "E2438E", BTN: "34203F", BTNH: "42294F", NAVA: "2E1B38", NAVH: "1E1127", SWOFF: "3C2648"},
    {name: "Lava Lamp", BG: "160A0E", SIDE: "0F0609", CARD: "22101A", INPUT: "2F1622", TEXT: "FBEDEF", MUTED: "B98E98", DIM: "75525A", ACC: "FF9A3C", ACCH: "F07F1E", BTN: "3A1E28", BTNH: "482532", NAVA: "331A24", NAVH: "22111A", SWOFF: "44242E"},
    {name: "Lagoon", BG: "081416", SIDE: "050E10", CARD: "0E2124", INPUT: "142D31", TEXT: "E3F7F7", MUTED: "7FAFAF", DIM: "4A6E6F", ACC: "2FD6C9", ACCH: "1FB8AC", BTN: "163639", BTNH: "1E4549", NAVA: "133034", NAVH: "0C2023", SWOFF: "1F3F43"},
    {name: "Borealis", BG: "0D0F1C", SIDE: "080A14", CARD: "141830", INPUT: "1C2240", TEXT: "EAF2F0", MUTED: "8FA3B4", DIM: "56637A", ACC: "4CE38D", ACCH: "36C676", BTN: "1F2747", BTNH: "293258", NAVA: "1C2340", NAVH: "131830", SWOFF: "26304F"},
    {name: "Glass", BG: "0B0E1A", SIDE: "080A13", CARD: "121729", INPUT: "1A2036", TEXT: "E8ECF7", MUTED: "8C95B2", DIM: "545C78", ACC: "8FB4FF", ACCH: "6F9BF5", BTN: "1D2440", BTNH: "262F50", NAVA: "1A2038", NAVH: "121729", SWOFF: "252D49"},
    {name: "Classic", BG: "121212", SIDE: "0C0C0C", CARD: "1A1A1A", INPUT: "242424", TEXT: "EEEEEE", MUTED: "909090", DIM: "5C5C5C", ACC: "FFFFFF", ACCH: "DDDDDD", BTN: "2A2A2A", BTNH: "353535", NAVA: "222222", NAVH: "181818", SWOFF: "333333"},
    {name: "Midnight", BG: "0B0F17", SIDE: "070A10", CARD: "111723", INPUT: "18202F", TEXT: "E6ECF5", MUTED: "8A96AA", DIM: "535E72", ACC: "3B82F6", ACCH: "2F6DD6", BTN: "1B2333", BTNH: "243044", NAVA: "182030", NAVH: "101622", SWOFF: "222C3E"},
    {name: "Slate", BG: "1E232B", SIDE: "181C23", CARD: "262C36", INPUT: "2F3642", TEXT: "E8EDF3", MUTED: "98A3B3", DIM: "66707E", ACC: "7CC4D8", ACCH: "5FB0C6", BTN: "333B48", BTNH: "3D4656", NAVA: "2E3542", NAVH: "232932", SWOFF: "3A4250"},
    {name: "Rose", BG: "141014", SIDE: "0E0B0E", CARD: "1D171D", INPUT: "282028", TEXT: "F6EDF0", MUTED: "A99AA2", DIM: "6A5D64", ACC: "F2B8C6", ACCH: "E29CAE", BTN: "2D242C", BTNH: "382D37", NAVA: "281F27", NAVH: "1B151B", SWOFF: "352B33"}
]
curTheme := IniRead(iniFile, "cfg", "theme", "Obsidian")
for th in THEMES
    if (th.name = curTheme) {
        C_BG := th.BG, C_SIDE := th.SIDE, C_CARD := th.CARD, C_INPUT := th.INPUT, C_TEXT := th.TEXT
        C_MUTED := th.MUTED, C_DIM := th.DIM, C_ACC := th.ACC, C_ACCH := th.ACCH, C_BTN := th.BTN
        C_BTNH := th.BTNH, C_NAVA := th.NAVA, C_NAVH := th.NAVH, C_SWOFF := th.SWOFF
    }
running  := false
lastLaunch := 0
launches := 0

wasOpen  := false
downTick := 0
discCount := 0
lastDisc  := ""
lastDiscShort := "—"
lastDiscUnix := 0
monStart  := 0

curLog    := ""
logPos    := 0
logCarry  := ""
discTick  := 0
hungSince := 0

curHwnd     := 0
detectTick  := 0
tabDone     := false
fsTries     := 0
placedLogged := false

miniShown := false
asyncReqs := []
botBusy := 0
cpuLast := 0
dayDate := ""
curPage := ""
cover := 0, coverT0 := 0
lastCoinSig := "", lastCoinChange := 0, lastCoinRead := 0
panelLast := 0
restartReply := 0
scriptT0 := A_TickCount
botCtx := 0
schedPaused := false
botLast := ""
histMetric := "online", histCoinIdx := 1, histTarget := [], histT0 := 0
multiActive := false
ACCS := []
multiHandles := []
pendingAcc := 0
multiN := 0
shareCache := Map()
dayOnline := 0
animSet := Map()
slideFrom := 0, slideTo := 0, slideT0 := 0
curState := "idle", curStateCol := "55555D", pulseLast := ""
tourOn := false
tourIdx := 0
tourWins := []
tourPos := ""
tourHidden := false
appStarted := false
licensed := false
kaSession := ""
licExpiry := 0
licFailSince := 0
pendingFileId := ""
pendingUpd := ""   ; arquivo da atualização já baixado
pendingVer := ""
changelogTxt := ""
launchToken := 0
joinedTick := 0   ; quando o log disse que entrou no jogo (após abrir)
logSeenTick := 0  ; quando apareceu um log novo do Roblox
launchStart := 0
openedTick := 0
pendingJoin := 0   ; quando apareceu "entrando no jogo" depois de uma desconexão
dlgSeen := 0       ; quantas checagens seguidas a tela "Disconnected" apareceu
watchN := 0
lastOcrText := ""
browserLaunch := 0   ; quando o script abriu o link pelo navegador
prevCur := Map()   ; última leitura de cada moeda (pra mostrar a diferença)

; infraestrutura da GUI
pages    := Map()
pageInfo := Map()
navs     := Map()
curBuild := ""
hoverMap := Map()
hoverCur := 0
bgCtrls  := []
roundQ   := []

DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")

; ---------------- Config ----------------
savedLink     := IniRead(iniFile, "cfg", "link", "")
savedInterval := IniRead(iniFile, "cfg", "interval", "15")
savedWait     := IniRead(iniFile, "cfg", "wait", "90")
savedHook     := IniRead(iniFile, "cfg", "webhook", "")
savedShrink   := IniRead(iniFile, "cfg", "shrink", "1")
savedMin      := IniRead(iniFile, "cfg", "minBrowser", "1")
savedErr      := IniRead(iniFile, "cfg", "restartOnError", "1")
savedErrSec   := IniRead(iniFile, "cfg", "errSec", "60")
savedRep      := IniRead(iniFile, "cfg", "report", "1")
savedRepMin   := IniRead(iniFile, "cfg", "reportMin", "60")
savedCompact  := IniRead(iniFile, "cfg", "compact", "0")
savedAutoUpd  := IniRead(iniFile, "cfg", "autoUpdate", "0")
savedLang     := IniRead(iniFile, "cfg", "lang", "auto")
savedStartWin := IniRead(iniFile, "cfg", "startWin", "0")
savedAutoMon  := IniRead(iniFile, "cfg", "autoMon", "0")
savedToast    := IniRead(iniFile, "cfg", "toast", "1")
savedTray     := IniRead(iniFile, "cfg", "tray", "0")
savedDaily    := IniRead(iniFile, "cfg", "daily", "1")
savedDailyAt  := IniRead(iniFile, "cfg", "dailyAt", "23:55")
savedMention  := IniRead(iniFile, "cfg", "mention", "0")
savedDiscId   := IniRead(iniFile, "cfg", "discordId", "")
savedMulti    := IniRead(iniFile, "cfg", "multi", "0")
savedSched    := IniRead(iniFile, "cfg", "sched", "0")
savedFrom     := IniRead(iniFile, "cfg", "schedFrom", "08:00")
savedTo       := IniRead(iniFile, "cfg", "schedTo", "23:00")
savedMaxH     := IniRead(iniFile, "cfg", "maxHours", "0")
endAct        := Integer(IniRead(iniFile, "cfg", "endAct", "0"))
savedEco      := IniRead(iniFile, "cfg", "eco", "0")
ecoFps        := Integer(IniRead(iniFile, "cfg", "ecoFps", "30"))
savedLowGfx   := IniRead(iniFile, "cfg", "lowGfx", "1")
savedMute     := IniRead(iniFile, "cfg", "mute", "1")
savedLowPrio  := IniRead(iniFile, "cfg", "lowPrio", "1")
savedBot      := IniRead(iniFile, "cfg", "bot", "0")
savedBotChan  := IniRead(iniFile, "cfg", "botChan", "")
savedPanel    := IniRead(iniFile, "cfg", "panel", "1")
savedPanelMin := IniRead(iniFile, "cfg", "panelMin", "2")
panelMsg      := IniRead(iniFile, "cfg", "panelMsg", "")
savedStuck    := IniRead(iniFile, "cfg", "stuck", "1")
savedStuckMin := IniRead(iniFile, "cfg", "stuckMin", "15")
stuckAct      := Integer(IniRead(iniFile, "cfg", "stuckAct", "0"))
; ---------------- Idiomas (gerado) ----------------
LANG_CODES := ["pt", "en", "es", "fr", "de", "ru", "tr", "id"]
LANG_NAMES := ["Português", "English", "Español", "Français", "Deutsch", "Русский", "Türkçe", "Bahasa Indonesia"]
I18N := Map()
I18N["pt"] := Map(
    "nav_home", "Início",
    "nav_game", "Jogo",
    "nav_window", "Janela",
    "nav_hook", "Webhook",
    "nav_coins", "Moedas",
    "nav_logs", "Logs",
    "nav_about", "Sobre",
    "pg_home_sub", "Olá, {1}! Visão geral do monitoramento",
    "pg_game_sub", "Servidor, intervalo de checagem e recuperação de erros",
    "pg_win_sub", "Posição da janela do Roblox e guia do navegador",
    "pg_hook_sub", "Avisos e status no Discord",
    "pg_coins_sub", "Lê suas moedas na tela do Roblox e manda no webhook",
    "pg_about_sub", "Licença, versão e novidades",
    "pg_logs_sub", "Histórico desta sessão",
    "idle", "Parado",
    "click_start", "Clique em Iniciar para monitorar",
    "btn_start", "Iniciar",
    "btn_stop", "Parar",
    "st_uptime", "TEMPO ATIVO",
    "st_reopens", "REABERTURAS",
    "st_drops", "QUEDAS",
    "st_lastdrop", "ÚLTIMA QUEDA",
    "quick", "AÇÕES RÁPIDAS",
    "btn_open_now", "Abrir jogo agora",
    "btn_place", "Posicionar janela",
    "btn_compact", "Modo compacto",
    "sec_server", "SERVIDOR",
    "hint_link", "Link do jogo, link de servidor privado (PV) ou só o Place ID.",
    "sec_monitor", "MONITORAMENTO",
    "lbl_check", "Checar a cada (segundos)",
    "lbl_wait", "Esperar após abrir (segundos)",
    "sec_recovery", "RECUPERAÇÃO",
    "sw_err", "Reiniciar se der erro, desconexão ou travar",
    "sw_err_sub", "Desconexão no log, kick, teleport que falhou ou janela sem responder",
    "lbl_tol", "Tolerância (segundos)",
    "sec_pos", "POSIÇÃO",
    "sw_place", "Posicionar no canto superior direito",
    "sw_place_sub", "Mantém a janela do Roblox fixa e totalmente visível",
    "lbl_width", "Largura",
    "lbl_height", "Altura",
    "btn_place_now", "Posicionar agora",
    "sec_browser", "NAVEGADOR",
    "sw_tab", "Fechar a guia do navegador após entrar",
    "sw_tab_sub", "Fecha a guia com 'Roblox' no título e minimiza o navegador",
    "btn_test", "Testar",
    "hint_hook", "Avisos automáticos: queda, tentativa de reabrir, volta e erros (com horário).",
    "sec_status", "STATUS PERIÓDICO",
    "sw_rep", "Enviar status com print",
    "sw_rep_sub", "Embed com o estado da conta + print só da janela do Roblox",
    "lbl_interval", "Intervalo (minutos)",
    "btn_send_now", "Enviar agora",
    "sec_ocr", "LEITURA DA TELA (OCR)",
    "sw_ocr", "Mandar moedas no embed de status",
    "sw_ocr_sub", "Lê os valores que estiverem aparecendo na janela do Roblox",
    "lbl_coins", "Moedas (separe com | ). Emoji opcional: Gems=<:gems:123456>",
    "sec_lastread", "ÚLTIMA LEITURA",
    "btn_testread", "Testar leitura",
    "no_read", "Nenhuma leitura ainda.",
    "not_found", "não encontrado",
    "nothing_read", "Nada lido.",
    "ocr_open", "Abra o Roblox (sem minimizar) e deixe as moedas aparecendo.",
    "ocr_names", "Coloque os nomes das moedas acima.",
    "log_ocr_tested", "Leitura de moedas testada ({1}/{2} encontradas).",
    "ocr_err", "Erro no OCR: {1}",
    "log_ocr_saw", "Texto que o OCR viu:",
    "log_coin_err", "Erro ao ler moedas: {1}",
    "sec_version", "VERSÃO INSTALADA",
    "upd_never", "Ainda não verifiquei.",
    "btn_checkupd", "Procurar atualização",
    "sec_license", "LICENÇA",
    "btn_changekey", "Trocar key",
    "paste_new_key", "Cole a nova key.",
    "sw_autoupd", "Atualizar sozinho",
    "sec_news", "NOVIDADES",
    "news_ph", "As novidades aparecem aqui depois de verificar.",
    "btn_clear", "Limpar",
    "upd_not_cfg", "Atualização não configurada.",
    "upd_searching", "Procurando atualização...",
    "upd_noconn", "Não consegui verificar agora.",
    "upd_badfile", "O arquivo baixado não parece ser o script.",
    "upd_latest", "Você está na versão mais nova.",
    "upd_avail", "Nova versão v{1} disponível! Veja as novidades abaixo.",
    "btn_upd_to", "Atualizar para v{1}",
    "badge_new", "Nova versão v{1}",
    "log_upd_avail", "Atualização disponível: v{1}.",
    "log_upd_dlfail", "Falha ao baixar atualização: {1}",
    "log_upd_fail", "Falha ao atualizar: {1}",
    "log_updated", "Atualizado para v{1}! Reiniciando...",
    "lang_menu", "Idioma",
    "lang_auto", "Automático (sistema)",
    "mini_sub", "reab {1} · quedas {2}",
    "key_title", "Ativar licença",
    "key_sub", "Cole sua key pra liberar o Auto Reconnect Roblox.",
    "btn_activate", "Ativar",
    "your_hwid", "SEU HWID",
    "btn_copy", "Copiar",
    "hwid_copied", "HWID copiado.",
    "btn_buy", "Comprar key",
    "checking_lic", "Verificando licença...",
    "ka_app_nf", "Aplicação não encontrada no KeyAuth (confira nome/Owner ID).",
    "ka_badver", "Versão do KeyAuth diferente (deixe KEYAUTH_VER igual ao painel).",
    "key_nf", "Key não existe.",
    "key_invalid", "Key inválida.",
    "key_hwid", "Essa key já está ativada em outro PC (HWID diferente).",
    "key_expired", "Sua key expirou.",
    "hwid_banned", "Este PC foi banido.",
    "key_banned", "Essa key foi banida.",
    "session_exp", "Sessão expirou, tente de novo.",
    "key_fail", "Não consegui validar a key.",
    "paste_key_first", "Cole sua key primeiro.",
    "checking", "Verificando...",
    "connecting", "Conectando ao servidor de licenças...",
    "no_conn", "Sem conexão com o servidor de licenças. Confira sua internet.",
    "lic_lifetime", "Vitalícia",
    "side_lifetime", "LICENÇA VITALÍCIA",
    "lic_expires", "Expira em {1}  ({2} dias)",
    "side_days", "LICENÇA: {1} DIAS",
    "lic_active", "Ativa",
    "side_active", "LICENÇA ATIVA",
    "lic_offline", "Fiquei mais de 2h sem conseguir validar a licença.",
    "log_lic_bad", "Licença inválida: {1}",
    "activate_to_use", "Ative sua key pra usar.",
    "hook_need_url", "Coloque a URL do webhook primeiro.",
    "hook_sent", "Webhook enviado (HTTP {1}).",
    "hook_fail", "Falha no webhook: {1}",
    "log_status_sent", "Status enviado (HTTP {1}).",
    "log_status_fail", "Falha ao enviar status: {1}",
    "why_closed", "Roblox fechado",
    "why_min", "janela minimizada",
    "why_fail", "falha ao capturar",
    "emb_offline", "Offline",
    "emb_warn", "Online · desconexão no log",
    "emb_online", "Online no jogo",
    "up_stopped", "parado",
    "none", "Nenhuma",
    "next_status", "próximo status em {1} min",
    "no_shot", "sem print ({1})",
    "f_uptime", "Tempo ativo",
    "f_reopens", "Reaberturas",
    "f_drops", "Quedas",
    "f_lastdrop", "Última queda",
    "m_exe", "direto pelo Roblox",
    "m_uri", "link roblox://",
    "m_web", "navegador",
    "roblox_not_reg", "Roblox não encontrado no registro",
    "paste_link_first", "Cole o link do jogo primeiro.",
    "log_all_failed", "Nenhum jeito de abrir funcionou. Tento de novo na próxima checagem.",
    "log_method_failed", "Jeito {1}/{2} ({3}) falhou: {4}",
    "log_opening", "Abrindo ({1})",
    "log_reopening", "Reabrindo ({1})",
    "log_opened", "Roblox abriu ({1}s). Entrando no jogo...",
    "st_joining", "Entrando no jogo...",
    "st_joining_sub", "Roblox aberto, carregando o servidor",
    "log_joined", "Entrou no jogo ({1}s).",
    "log_not_open25", "O Roblox não abriu em 25s, tentando outro jeito...",
    "log_not_join60", "O Roblox abriu mas não entrou no jogo em 60s, tentando outro jeito...",
    "log_not_open", "O Roblox não está aberto.",
    "log_placed", "Janela do Roblox posicionada.",
    "log_detected", "Janela do Roblox detectada.",
    "log_placed_right", "Janela do Roblox posicionada no canto direito.",
    "log_tab_closed", "Guia do Roblox fechada no navegador.",
    "log_tab_nf", "Não achei a guia do Roblox. Títulos abertos:",
    "none_lc", "nenhum",
    "log_disc_log", "Desconexão no log. Aguardando reentrar...",
    "log_err_restart", "Erro detectado: {1}. Reiniciando o Roblox...",
    "log_disc_screen", "Tela de Disconnected na janela.",
    "log_disc_screen_c", "Tela de Disconnected na janela (código {1}).",
    "r_disc_screen", "tela de Disconnected",
    "r_disc_screen_c", "tela de Disconnected - código {1}",
    "log_rejoined", "Reentrou no jogo/teleport normal, ok.",
    "r_no_rejoin", "desconexão/erro sem reentrar no jogo",
    "r_hung", "janela travada (não respondendo)",
    "log_back", "Roblox voltou (fora por {1}).",
    "log_down", "Roblox fechou/desconectou.",
    "st_loading", "Carregando...",
    "st_loading_sub", "Aguardando o jogo abrir e entrar no servidor",
    "st_on_warn_sub", "Desconexão no log, aguardando reentrar",
    "st_on_sub", "No jogo · monitorando",
    "st_off_sub", "Fechado, reabrindo agora",
    "st_nolink", "Sem link",
    "st_nolink_sub", "Cole o link do jogo na aba Jogo",
    "st_monitoring", "Monitorando...",
    "st_monitoring_sub", "Verificando o Roblox",
    "log_mon_start", "Monitoramento iniciado (a cada {1}s).",
    "log_mon_stop", "Monitoramento parado.",
    "ev_start", "Monitoramento iniciado",
    "ev_reopen", "Reabrindo o Roblox",
    "ev_fail", "Não consegui abrir o Roblox",
    "ev_error", "Erro detectado",
    "ev_back", "Roblox voltou",
    "ev_down", "Roblox fechou/desconectou",
    "ev_lic", "Licença inválida",
    "ev_updated", "Atualizado para v{1}",
    "ev_test", "Webhook funcionando!",
    "d_time", "Horário",
    "d_away", "Ficou fora por",
    "d_reason", "Motivo",
    "d_restart", "Reiniciando o Roblox...",
    "d_stopped", "Monitoramento parado.",
    "d_retry", "Vou tentar de novo na próxima checagem.",
    "d_test", "Os avisos vão chegar aqui.",
    "d_method", "Jeito",
    "d_interval", "Checagem a cada",
    "d_user", "Usuário",
    "tour_welcome_t", "Bem-vindo, {1}!",
    "tour_welcome", "Vou te mostrar o básico em menos de 1 minuto. Dá pra pular quando quiser.",
    "tour_link_t", "1. Link do jogo",
    "tour_link", "Cole aqui o link do jogo, do servidor privado ou só o Place ID. É pra lá que o script te leva de volta.",
    "tour_hook_t", "2. Avisos no Discord",
    "tour_hook", "Opcional: cole o webhook de um canal do Discord pra receber avisos quando cair, voltar ou der erro.",
    "tour_test_t", "Testar webhook",
    "tour_test", "Clique aqui pra conferir se os avisos estão chegando no Discord.",
    "tour_win_t", "3. Posição da janela",
    "tour_win", "Com isso ligado, a janela do Roblox fica fixa no canto superior direito da tela.",
    "tour_coins_t", "4. Moedas (opcional)",
    "tour_coins", "Coloque os nomes das moedas que aparecem na tela pra elas irem junto no status do Discord.",
    "tour_start_t", "5. Começar!",
    "tour_start", "Quando estiver tudo certo, clique em Iniciar. O script vigia o Roblox e reabre sozinho se cair.",
    "tour_compact_t", "Modo compacto",
    "tour_compact", "Deixa só uma barrinha pequena na tela, ocupando menos espaço.",
    "tour_lang_t", "Idioma",
    "tour_lang", "Troque o idioma aqui. Por padrão ele segue o idioma do Windows.",
    "tour_upd_t", "Atualizações",
    "tour_upd", "Quando sair versão nova, aparece um aviso no topo e você atualiza por aqui com 1 clique.",
    "tour_done_t", "Tudo pronto!",
    "tour_done", "Dá pra rever este tutorial quando quiser em Sobre → Ver tutorial.",
    "btn_next", "Próximo",
    "btn_back", "Voltar",
    "btn_skip", "Pular",
    "btn_finish", "Concluir",
    "btn_tour", "Ver tutorial",
    "tour_step", "{1} de {2}",
    "nav_opts", "Opções",
    "nav_accounts", "Contas",
    "pg_opts_sub", "Inicialização, notificações e resumo diário",
    "pg_acc_sub", "Várias contas ao mesmo tempo (experimental)",
    "sec_startup", "INICIALIZAÇÃO",
    "sw_startwin", "Iniciar junto com o Windows",
    "sw_startwin_sub", "Abre o script quando o PC liga",
    "sw_automon", "Começar a monitorar sozinho ao abrir",
    "sw_automon_sub", "Já clica em Iniciar quando o script abre",
    "sec_notify", "NOTIFICAÇÕES",
    "sw_toast", "Notificação do Windows",
    "sw_toast_sub", "Aviso no canto da tela quando cair, voltar ou der erro",
    "sw_tray", "Minimizar pra bandeja",
    "sw_tray_sub", "Ao minimizar, fica só no ícone perto do relógio",
    "sec_daily", "RESUMO DIÁRIO",
    "sw_daily", "Mandar resumo do dia no Discord",
    "lbl_daily_time", "Horário (HH:MM)",
    "sec_mention", "MARCAR VOCÊ",
    "sw_mention", "Me marcar quando cair ou der erro",
    "sw_mention_sub", "Marca só você, nunca @everyone",
    "lbl_discord_id", "Seu ID do Discord",
    "btn_how", "Como achar?",
    "hint_discord_id", "Discord > Configurações > Avançado > ative o Modo desenvolvedor. Depois clique com o botão direito no seu nome > Copiar ID do usuário.",
    "sw_multi", "Usar várias contas",
    "sw_multi_sub", "Feche o Roblox antes de iniciar. Todas usam o link da aba Jogo.",
    "col_account", "Conta",
    "col_status", "Status",
    "btn_add_acc", "Adicionar conta",
    "btn_rem_acc", "Remover",
    "btn_tile", "Organizar janelas",
    "acc_cookie", "Cookie .ROBLOSECURITY da conta",
    "acc_cookie_hint", "No navegador logado na conta: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Fica salvo criptografado neste PC. Nunca mande pra ninguém.",
    "btn_save", "Salvar",
    "btn_cancel", "Cancelar",
    "acc_checking", "Verificando a conta...",
    "acc_invalid", "Cookie inválido ou expirado.",
    "acc_added", "Conta {1} adicionada.",
    "acc_st_off", "Fechada",
    "acc_st_opening", "Abrindo...",
    "acc_st_on", "No jogo",
    "acc_st_down", "Caiu, reabrindo",
    "acc_st_err", "Erro: {1}",
    "multi_close", "Feche todos os Roblox antes de iniciar o modo de várias contas.",
    "acc_need", "Adicione pelo menos uma conta na aba Contas.",
    "log_acc_launch", "[{1}] abrindo...",
    "log_acc_down", "[{1}] caiu.",
    "log_acc_dlg", "[{1}] tela de Disconnected, reiniciando.",
    "log_acc_fail", "[{1}] não consegui abrir: {2}",
    "d_account", "Conta",
    "tray_open", "Abrir",
    "tray_toggle", "Iniciar / Parar",
    "tray_exit", "Sair",
    "ev_daily", "Resumo do dia",
    "f_online_today", "Online hoje",
    "f_drops_today", "Quedas hoje",
    "f_reopens_today", "Reaberturas hoje",
    "d_earned", "Ganhos de hoje",
    "nav_auto", "Automação",
    "nav_bot", "Bot",
    "nav_hist", "Histórico",
    "pg_auto_sub", "Horários e modo econômico",
    "pg_bot_sub", "Controle o script pelo Discord",
    "pg_hist_sub", "Seus últimos 14 dias",
    "sec_sched", "AGENDAMENTO",
    "sw_sched", "Só monitorar num horário",
    "sw_sched_sub", "Fora do horário pausa e depois volta sozinho",
    "lbl_from", "Das",
    "lbl_to", "até",
    "lbl_maxh", "Parar depois de (horas, 0 = nunca)",
    "lbl_onend", "Ao terminar",
    "act_none", "Não fazer nada",
    "act_close", "Fechar o Roblox",
    "act_shutdown", "Desligar o PC",
    "sec_eco", "MODO ECONÔMICO",
    "sw_eco", "Ativar modo econômico",
    "sw_eco_sub", "Vale na próxima vez que o Roblox abrir",
    "lbl_fps", "Limite de FPS",
    "fps_none", "Sem limite",
    "sw_lowgfx", "Gráficos no mínimo",
    "sw_mute", "Som desligado",
    "sw_lowprio", "Prioridade baixa pro Roblox",
    "sec_bot", "BOT DO DISCORD",
    "sw_bot", "Controlar pelo Discord",
    "sw_bot_sub", "Só obedece o seu ID (aba Webhook)",
    "lbl_token", "Token do bot",
    "lbl_channel", "ID do canal",
    "bot_off", "Desligado",
    "bot_ok", "Conectado, ouvindo comandos",
    "bot_err", "Erro: {1}",
    "bot_need_id", "Coloque seu ID do Discord na aba Webhook.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Ative 'Message Content Intent', convide o bot pro servidor e copie o ID do canal (botão direito no canal).",
    "sec_cmds", "COMANDOS",
    "cmd_status", "mostra o status com print",
    "cmd_start", "começa a monitorar",
    "cmd_stop", "para de monitorar",
    "cmd_restart", "fecha e abre o Roblox de novo",
    "cmd_summary", "manda o resumo do dia",
    "cmd_help", "lista os comandos",
    "log_bot_cmd", "Comando do Discord: {1}",
    "hist_online", "Tempo online",
    "hist_coin", "Moeda: {1}",
    "hist_empty", "Sem dados ainda. O histórico enche conforme os dias passam.",
    "acc_edit", "Editar conta",
    "acc_link", "Link desta conta (opcional)",
    "acc_ck_keep", "Deixe vazio pra manter o cookie atual.",
    "col_link", "Link",
    "link_default", "padrão",
    "acc_dbl_hint", "Clique duas vezes numa conta pra editar o link.",
    "log_sched_pause", "Fora do horário, monitoramento pausado.",
    "log_sched_resume", "Dentro do horário, monitoramento retomado.",
    "log_maxh", "Tempo máximo atingido, parando.",
    "ev_sched", "Monitoramento encerrado",
    "d_shutdown", "O PC vai desligar em 60 segundos.",
    "ev_stop", "Monitoramento parado",
    "ev_restart", "Reiniciando o Roblox",
    "ev_already", "Já está monitorando",
    "ev_notrunning", "O monitoramento já está parado",
    "ev_unknown", "Comando desconhecido",
    "d_unknown", "Use !ajuda pra ver os comandos.",
    "d_restart_how", "Fechando e abrindo de novo direto pelo Roblox.",
    "d_running_for", "Ativo há",
    "d_cmd", "Comando",
    "cmd_print", "manda só o print do Roblox",
    "cmd_coins", "mostra suas moedas agora",
    "cmd_pc", "uso de CPU e memória do PC",
    "cmd_accounts", "status de cada conta",
    "cmd_hist", "gráfico dos últimos 7 dias",
    "cmd_logs", "últimas linhas do log",
    "cmd_ping", "testa se o bot está respondendo",
    "cmd_link", "troca o link do jogo",
    "cmd_update", "procura e instala atualização",
    "cmd_shutdown", "desliga o PC (!desligar confirmar)",
    "cmd_cancel", "cancela o desligamento",
    "grp_control", "Controle",
    "grp_info", "Informações",
    "grp_config", "Configuração",
    "f_session", "Sessão",
    "f_link", "Link",
    "f_version", "Versão",
    "f_cpu", "CPU",
    "f_ram", "Memória",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC ligado há",
    "f_script_up", "Script aberto há",
    "f_latency", "Latência",
    "f_windows", "Janelas do Roblox",
    "ev_pong", "Pong!",
    "ev_pc", "Saúde do PC",
    "ev_coins", "Suas moedas",
    "ev_accounts", "Contas",
    "ev_hist", "Últimos 7 dias",
    "ev_logs", "Últimos logs",
    "ev_link", "Link alterado",
    "d_link_next", "Vale na próxima abertura. Mande !reiniciar pra aplicar agora.",
    "ev_linkbad", "Link inválido",
    "d_link_usage", "Use: !link <link do jogo, do servidor ou Place ID>",
    "ev_updnone", "Já está na versão mais nova",
    "ev_updating", "Atualizando para v{1}",
    "ev_shutdown", "Desligando o PC",
    "ev_shutconf", "Confirme o desligamento",
    "d_shutconf", "Mande !desligar confirmar pra desligar em 60 segundos.",
    "ev_cancel", "Desligamento cancelado",
    "d_back_in", "Voltou pro jogo em {1}s",
    "ev_print", "Print do Roblox",
    "no_accounts", "Nenhuma conta adicionada.",
    "no_coins", "Não consegui ler as moedas (deixe o painel aparecendo na janela).",
    "sec_panel", "PAINEL AO VIVO",
    "sw_panel", "Painel fixo no canal",
    "sw_panel_sub", "Uma mensagem só, com status e print, que se atualiza sozinha",
    "lbl_panel_min", "Atualizar a cada (min)",
    "ev_panel", "Painel ao vivo",
    "d_updated", "Atualizado",
    "bot_hint_help", "Mande !ajuda no canal pra ver todos os comandos.",
    "sec_stuck", "FARM TRAVADO",
    "sw_stuck", "Avisar se as moedas pararem de subir",
    "sw_stuck_sub", "Lê as moedas a cada minuto pra saber se o farm está andando",
    "lbl_stuck_min", "Tempo sem mudar (min)",
    "stuck_alert", "Só avisar",
    "stuck_restart", "Avisar e reiniciar",
    "ev_stuck", "Farm parado",
    "d_stuck", "As moedas não mudam há {1} min.",
    "r_stuck", "farm parado (moedas sem mudar)",
    "log_stuck", "Farm parado há {1} min.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Aparência",
    "pg_look_sub", "Escolha o tema do programa",
    "sec_theme", "TEMA"
)
I18N["en"] := Map(
    "nav_home", "Home",
    "nav_game", "Game",
    "nav_window", "Window",
    "nav_hook", "Webhook",
    "nav_coins", "Currency",
    "nav_logs", "Logs",
    "nav_about", "About",
    "pg_home_sub", "Hi, {1}! Monitoring overview",
    "pg_game_sub", "Server, check interval and error recovery",
    "pg_win_sub", "Roblox window position and browser tab",
    "pg_hook_sub", "Alerts and status on Discord",
    "pg_coins_sub", "Reads your currency on the Roblox screen and sends it to the webhook",
    "pg_about_sub", "License, version and what's new",
    "pg_logs_sub", "History of this session",
    "idle", "Stopped",
    "click_start", "Click Start to begin monitoring",
    "btn_start", "Start",
    "btn_stop", "Stop",
    "st_uptime", "UPTIME",
    "st_reopens", "REOPENS",
    "st_drops", "DROPS",
    "st_lastdrop", "LAST DROP",
    "quick", "QUICK ACTIONS",
    "btn_open_now", "Open game now",
    "btn_place", "Place window",
    "btn_compact", "Compact mode",
    "sec_server", "SERVER",
    "hint_link", "Game link, private server link or just the Place ID.",
    "sec_monitor", "MONITORING",
    "lbl_check", "Check every (seconds)",
    "lbl_wait", "Wait after opening (seconds)",
    "sec_recovery", "RECOVERY",
    "sw_err", "Restart on error, disconnect or freeze",
    "sw_err_sub", "Disconnect in the log, kick, failed teleport or window not responding",
    "lbl_tol", "Tolerance (seconds)",
    "sec_pos", "POSITION",
    "sw_place", "Place in the top-right corner",
    "sw_place_sub", "Keeps the Roblox window fixed and fully visible",
    "lbl_width", "Width",
    "lbl_height", "Height",
    "btn_place_now", "Place now",
    "sec_browser", "BROWSER",
    "sw_tab", "Close the browser tab after joining",
    "sw_tab_sub", "Closes the tab with 'Roblox' in the title and minimizes the browser",
    "btn_test", "Test",
    "hint_hook", "Automatic alerts: drop, reopen attempt, back online and errors (with time).",
    "sec_status", "PERIODIC STATUS",
    "sw_rep", "Send status with screenshot",
    "sw_rep_sub", "Embed with the account status + screenshot of the Roblox window only",
    "lbl_interval", "Interval (minutes)",
    "btn_send_now", "Send now",
    "sec_ocr", "SCREEN READING (OCR)",
    "sw_ocr", "Send currency in the status embed",
    "sw_ocr_sub", "Reads the values shown in the Roblox window",
    "lbl_coins", "Currencies (separate with | ). Optional emoji: Gems=<:gems:123456>",
    "sec_lastread", "LAST READING",
    "btn_testread", "Test reading",
    "no_read", "No reading yet.",
    "not_found", "not found",
    "nothing_read", "Nothing read.",
    "ocr_open", "Open Roblox (not minimized) with the currency visible.",
    "ocr_names", "Enter the currency names above.",
    "log_ocr_tested", "Currency reading tested ({1}/{2} found).",
    "ocr_err", "OCR error: {1}",
    "log_ocr_saw", "Text the OCR saw:",
    "log_coin_err", "Error reading currency: {1}",
    "sec_version", "INSTALLED VERSION",
    "upd_never", "Not checked yet.",
    "btn_checkupd", "Check for updates",
    "sec_license", "LICENSE",
    "btn_changekey", "Change key",
    "paste_new_key", "Paste the new key.",
    "sw_autoupd", "Update automatically",
    "sec_news", "WHAT'S NEW",
    "news_ph", "What's new shows up here after checking.",
    "btn_clear", "Clear",
    "upd_not_cfg", "Updates are not set up.",
    "upd_searching", "Checking for updates...",
    "upd_noconn", "Couldn't check right now.",
    "upd_badfile", "The downloaded file doesn't look like the script.",
    "upd_latest", "You're on the latest version.",
    "upd_avail", "New version v{1} available! See what's new below.",
    "btn_upd_to", "Update to v{1}",
    "badge_new", "New version v{1}",
    "log_upd_avail", "Update available: v{1}.",
    "log_upd_dlfail", "Failed to download update: {1}",
    "log_upd_fail", "Update failed: {1}",
    "log_updated", "Updated to v{1}! Restarting...",
    "lang_menu", "Language",
    "lang_auto", "Automatic (system)",
    "mini_sub", "reopens {1} · drops {2}",
    "key_title", "Activate license",
    "key_sub", "Paste your key to unlock Auto Reconnect Roblox.",
    "btn_activate", "Activate",
    "your_hwid", "YOUR HWID",
    "btn_copy", "Copy",
    "hwid_copied", "HWID copied.",
    "btn_buy", "Buy key",
    "checking_lic", "Checking license...",
    "ka_app_nf", "Application not found on KeyAuth (check name/Owner ID).",
    "ka_badver", "KeyAuth version mismatch (set KEYAUTH_VER to match the panel).",
    "key_nf", "Key doesn't exist.",
    "key_invalid", "Invalid key.",
    "key_hwid", "This key is already activated on another PC (different HWID).",
    "key_expired", "Your key has expired.",
    "hwid_banned", "This PC has been banned.",
    "key_banned", "This key has been banned.",
    "session_exp", "Session expired, try again.",
    "key_fail", "Couldn't validate the key.",
    "paste_key_first", "Paste your key first.",
    "checking", "Checking...",
    "connecting", "Connecting to the license server...",
    "no_conn", "Can't reach the license server. Check your internet.",
    "lic_lifetime", "Lifetime",
    "side_lifetime", "LIFETIME LICENSE",
    "lic_expires", "Expires on {1}  ({2} days)",
    "side_days", "LICENSE: {1} DAYS",
    "lic_active", "Active",
    "side_active", "LICENSE ACTIVE",
    "lic_offline", "Couldn't validate the license for over 2 hours.",
    "log_lic_bad", "Invalid license: {1}",
    "activate_to_use", "Activate your key to use it.",
    "hook_need_url", "Enter the webhook URL first.",
    "hook_sent", "Webhook sent (HTTP {1}).",
    "hook_fail", "Webhook failed: {1}",
    "log_status_sent", "Status sent (HTTP {1}).",
    "log_status_fail", "Failed to send status: {1}",
    "why_closed", "Roblox closed",
    "why_min", "window minimized",
    "why_fail", "capture failed",
    "emb_offline", "Offline",
    "emb_warn", "Online · disconnect in the log",
    "emb_online", "Online in game",
    "up_stopped", "stopped",
    "none", "None",
    "next_status", "next status in {1} min",
    "no_shot", "no screenshot ({1})",
    "f_uptime", "Uptime",
    "f_reopens", "Reopens",
    "f_drops", "Drops",
    "f_lastdrop", "Last drop",
    "m_exe", "directly via Roblox",
    "m_uri", "roblox:// link",
    "m_web", "browser",
    "roblox_not_reg", "Roblox not found in the registry",
    "paste_link_first", "Paste the game link first.",
    "log_all_failed", "No launch method worked. Retrying on the next check.",
    "log_method_failed", "Method {1}/{2} ({3}) failed: {4}",
    "log_opening", "Opening ({1})",
    "log_reopening", "Reopening ({1})",
    "log_opened", "Roblox opened ({1}s). Joining the game...",
    "st_joining", "Joining the game...",
    "st_joining_sub", "Roblox open, loading the server",
    "log_joined", "Joined the game ({1}s).",
    "log_not_open25", "Roblox didn't open in 25s, trying another method...",
    "log_not_join60", "Roblox opened but didn't join the game in 60s, trying another method...",
    "log_not_open", "Roblox isn't open.",
    "log_placed", "Roblox window placed.",
    "log_detected", "Roblox window detected.",
    "log_placed_right", "Roblox window moved to the right corner.",
    "log_tab_closed", "Roblox tab closed in the browser.",
    "log_tab_nf", "Couldn't find the Roblox tab. Open titles:",
    "none_lc", "none",
    "log_disc_log", "Disconnect in the log. Waiting to rejoin...",
    "log_err_restart", "Error detected: {1}. Restarting Roblox...",
    "log_disc_screen", "Disconnected screen in the window.",
    "log_disc_screen_c", "Disconnected screen in the window (code {1}).",
    "r_disc_screen", "Disconnected screen",
    "r_disc_screen_c", "Disconnected screen - code {1}",
    "log_rejoined", "Rejoined / normal teleport, ok.",
    "r_no_rejoin", "disconnect/error without rejoining",
    "r_hung", "window frozen (not responding)",
    "log_back", "Roblox is back (down for {1}).",
    "log_down", "Roblox closed/disconnected.",
    "st_loading", "Loading...",
    "st_loading_sub", "Waiting for the game to open and join the server",
    "st_on_warn_sub", "Disconnect in the log, waiting to rejoin",
    "st_on_sub", "In game · monitoring",
    "st_off_sub", "Closed, reopening now",
    "st_nolink", "No link",
    "st_nolink_sub", "Paste the game link in the Game tab",
    "st_monitoring", "Monitoring...",
    "st_monitoring_sub", "Checking Roblox",
    "log_mon_start", "Monitoring started (every {1}s).",
    "log_mon_stop", "Monitoring stopped.",
    "ev_start", "Monitoring started",
    "ev_reopen", "Reopening Roblox",
    "ev_fail", "Couldn't open Roblox",
    "ev_error", "Error detected",
    "ev_back", "Roblox is back",
    "ev_down", "Roblox closed/disconnected",
    "ev_lic", "Invalid license",
    "ev_updated", "Updated to v{1}",
    "ev_test", "Webhook is working!",
    "d_time", "Time",
    "d_away", "Was down for",
    "d_reason", "Reason",
    "d_restart", "Restarting Roblox...",
    "d_stopped", "Monitoring stopped.",
    "d_retry", "I'll try again on the next check.",
    "d_test", "Alerts will show up here.",
    "d_method", "Method",
    "d_interval", "Checking every",
    "d_user", "User",
    "tour_welcome_t", "Welcome, {1}!",
    "tour_welcome", "I'll show you the basics in under a minute. You can skip anytime.",
    "tour_link_t", "1. Game link",
    "tour_link", "Paste the game link, private server link or just the Place ID here. That's where the script takes you back to.",
    "tour_hook_t", "2. Discord alerts",
    "tour_hook", "Optional: paste a Discord channel webhook to get alerts when you drop, come back or hit an error.",
    "tour_test_t", "Test webhook",
    "tour_test", "Click here to check that alerts are reaching Discord.",
    "tour_win_t", "3. Window position",
    "tour_win", "With this on, the Roblox window stays fixed in the top-right corner of the screen.",
    "tour_coins_t", "4. Currency (optional)",
    "tour_coins", "Enter the names of the currencies shown on screen so they're included in the Discord status.",
    "tour_start_t", "5. Start!",
    "tour_start", "When everything is set, click Start. The script watches Roblox and reopens it if you drop.",
    "tour_compact_t", "Compact mode",
    "tour_compact", "Shrinks everything into a small bar so it takes less space.",
    "tour_lang_t", "Language",
    "tour_lang", "Change the language here. By default it follows your Windows language.",
    "tour_upd_t", "Updates",
    "tour_upd", "When a new version is out, a notice shows at the top and you update here with one click.",
    "tour_done_t", "All set!",
    "tour_done", "You can replay this tutorial anytime in About → Show tutorial.",
    "btn_next", "Next",
    "btn_back", "Back",
    "btn_skip", "Skip",
    "btn_finish", "Finish",
    "btn_tour", "Show tutorial",
    "tour_step", "{1} of {2}",
    "nav_opts", "Options",
    "nav_accounts", "Accounts",
    "pg_opts_sub", "Startup, notifications and daily summary",
    "pg_acc_sub", "Several accounts at once (experimental)",
    "sec_startup", "STARTUP",
    "sw_startwin", "Start with Windows",
    "sw_startwin_sub", "Opens the script when the PC turns on",
    "sw_automon", "Start monitoring automatically on open",
    "sw_automon_sub", "Clicks Start for you when the script opens",
    "sec_notify", "NOTIFICATIONS",
    "sw_toast", "Windows notification",
    "sw_toast_sub", "Pop-up in the corner when you drop, come back or hit an error",
    "sw_tray", "Minimize to tray",
    "sw_tray_sub", "When minimized, it stays only as an icon near the clock",
    "sec_daily", "DAILY SUMMARY",
    "sw_daily", "Send a daily summary to Discord",
    "lbl_daily_time", "Time (HH:MM)",
    "sec_mention", "MENTION YOU",
    "sw_mention", "Mention me when I drop or hit an error",
    "sw_mention_sub", "Only mentions you, never @everyone",
    "lbl_discord_id", "Your Discord ID",
    "btn_how", "How to find?",
    "hint_discord_id", "Discord > Settings > Advanced > turn on Developer Mode. Then right-click your name > Copy User ID.",
    "sw_multi", "Use multiple accounts",
    "sw_multi_sub", "Close Roblox before starting. All use the link from the Game tab.",
    "col_account", "Account",
    "col_status", "Status",
    "btn_add_acc", "Add account",
    "btn_rem_acc", "Remove",
    "btn_tile", "Arrange windows",
    "acc_cookie", "The account's .ROBLOSECURITY cookie",
    "acc_cookie_hint", "In a browser logged into the account: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Saved encrypted on this PC. Never share it.",
    "btn_save", "Save",
    "btn_cancel", "Cancel",
    "acc_checking", "Checking the account...",
    "acc_invalid", "Invalid or expired cookie.",
    "acc_added", "Account {1} added.",
    "acc_st_off", "Closed",
    "acc_st_opening", "Opening...",
    "acc_st_on", "In game",
    "acc_st_down", "Dropped, reopening",
    "acc_st_err", "Error: {1}",
    "multi_close", "Close every Roblox before starting multi-account mode.",
    "acc_need", "Add at least one account in the Accounts tab.",
    "log_acc_launch", "[{1}] opening...",
    "log_acc_down", "[{1}] dropped.",
    "log_acc_dlg", "[{1}] Disconnected screen, restarting.",
    "log_acc_fail", "[{1}] couldn't open: {2}",
    "d_account", "Account",
    "tray_open", "Open",
    "tray_toggle", "Start / Stop",
    "tray_exit", "Exit",
    "ev_daily", "Daily summary",
    "f_online_today", "Online today",
    "f_drops_today", "Drops today",
    "f_reopens_today", "Reopens today",
    "d_earned", "Earned today",
    "nav_auto", "Automation",
    "nav_bot", "Bot",
    "nav_hist", "History",
    "pg_auto_sub", "Schedule and eco mode",
    "pg_bot_sub", "Control the script from Discord",
    "pg_hist_sub", "Your last 14 days",
    "sec_sched", "SCHEDULE",
    "sw_sched", "Only monitor during set hours",
    "sw_sched_sub", "Pauses outside the hours and resumes on its own",
    "lbl_from", "From",
    "lbl_to", "to",
    "lbl_maxh", "Stop after (hours, 0 = never)",
    "lbl_onend", "When done",
    "act_none", "Do nothing",
    "act_close", "Close Roblox",
    "act_shutdown", "Shut down the PC",
    "sec_eco", "ECO MODE",
    "sw_eco", "Turn on eco mode",
    "sw_eco_sub", "Applies the next time Roblox opens",
    "lbl_fps", "FPS limit",
    "fps_none", "No limit",
    "sw_lowgfx", "Lowest graphics",
    "sw_mute", "Sound off",
    "sw_lowprio", "Low priority for Roblox",
    "sec_bot", "DISCORD BOT",
    "sw_bot", "Control from Discord",
    "sw_bot_sub", "Only obeys your ID (Webhook tab)",
    "lbl_token", "Bot token",
    "lbl_channel", "Channel ID",
    "bot_off", "Off",
    "bot_ok", "Connected, listening for commands",
    "bot_err", "Error: {1}",
    "bot_need_id", "Enter your Discord ID in the Webhook tab.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Turn on 'Message Content Intent', invite the bot to your server and copy the channel ID (right-click the channel).",
    "sec_cmds", "COMMANDS",
    "cmd_status", "shows the status with a screenshot",
    "cmd_start", "starts monitoring",
    "cmd_stop", "stops monitoring",
    "cmd_restart", "closes and reopens Roblox",
    "cmd_summary", "sends today's summary",
    "cmd_help", "lists the commands",
    "log_bot_cmd", "Discord command: {1}",
    "hist_online", "Time online",
    "hist_coin", "Currency: {1}",
    "hist_empty", "No data yet. History fills up as the days go by.",
    "acc_edit", "Edit account",
    "acc_link", "Link for this account (optional)",
    "acc_ck_keep", "Leave empty to keep the current cookie.",
    "col_link", "Link",
    "link_default", "default",
    "acc_dbl_hint", "Double-click an account to edit its link.",
    "log_sched_pause", "Outside scheduled hours, monitoring paused.",
    "log_sched_resume", "Within scheduled hours, monitoring resumed.",
    "log_maxh", "Maximum time reached, stopping.",
    "ev_sched", "Monitoring finished",
    "d_shutdown", "The PC will shut down in 60 seconds.",
    "ev_stop", "Monitoring stopped",
    "ev_restart", "Restarting Roblox",
    "ev_already", "Already monitoring",
    "ev_notrunning", "Monitoring is already stopped",
    "ev_unknown", "Unknown command",
    "d_unknown", "Use !help to see the commands.",
    "d_restart_how", "Closing and reopening directly through Roblox.",
    "d_running_for", "Running for",
    "d_cmd", "Command",
    "cmd_print", "sends just a Roblox screenshot",
    "cmd_coins", "shows your currency right now",
    "cmd_pc", "PC CPU and memory usage",
    "cmd_accounts", "status of each account",
    "cmd_hist", "chart of the last 7 days",
    "cmd_logs", "latest log lines",
    "cmd_ping", "checks that the bot is responding",
    "cmd_link", "changes the game link",
    "cmd_update", "checks for and installs updates",
    "cmd_shutdown", "shuts down the PC (!shutdown confirm)",
    "cmd_cancel", "cancels the shutdown",
    "grp_control", "Control",
    "grp_info", "Info",
    "grp_config", "Settings",
    "f_session", "Session",
    "f_link", "Link",
    "f_version", "Version",
    "f_cpu", "CPU",
    "f_ram", "Memory",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC on for",
    "f_script_up", "Script open for",
    "f_latency", "Latency",
    "f_windows", "Roblox windows",
    "ev_pong", "Pong!",
    "ev_pc", "PC health",
    "ev_coins", "Your currency",
    "ev_accounts", "Accounts",
    "ev_hist", "Last 7 days",
    "ev_logs", "Latest logs",
    "ev_link", "Link changed",
    "d_link_next", "Applies on the next launch. Send !restart to apply now.",
    "ev_linkbad", "Invalid link",
    "d_link_usage", "Use: !link <game link, server link or Place ID>",
    "ev_updnone", "Already on the latest version",
    "ev_updating", "Updating to v{1}",
    "ev_shutdown", "Shutting down the PC",
    "ev_shutconf", "Confirm the shutdown",
    "d_shutconf", "Send !shutdown confirm to shut down in 60 seconds.",
    "ev_cancel", "Shutdown cancelled",
    "d_back_in", "Back in game after {1}s",
    "ev_print", "Roblox screenshot",
    "no_accounts", "No accounts added.",
    "no_coins", "Couldn't read the currency (keep the panel visible in the window).",
    "sec_panel", "LIVE PANEL",
    "sw_panel", "Pinned panel in the channel",
    "sw_panel_sub", "A single message with status and screenshot that updates itself",
    "lbl_panel_min", "Update every (min)",
    "ev_panel", "Live panel",
    "d_updated", "Updated",
    "bot_hint_help", "Send !help in the channel to see every command.",
    "sec_stuck", "STUCK FARM",
    "sw_stuck", "Alert if the currency stops going up",
    "sw_stuck_sub", "Reads the currency every minute to know if the farm is moving",
    "lbl_stuck_min", "Time without change (min)",
    "stuck_alert", "Just alert",
    "stuck_restart", "Alert and restart",
    "ev_stuck", "Farm stopped",
    "d_stuck", "The currency hasn't changed for {1} min.",
    "r_stuck", "farm stopped (currency not changing)",
    "log_stuck", "Farm stopped for {1} min.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Appearance",
    "pg_look_sub", "Choose the app theme",
    "sec_theme", "THEME"
)
I18N["es"] := Map(
    "nav_home", "Inicio",
    "nav_game", "Juego",
    "nav_window", "Ventana",
    "nav_hook", "Webhook",
    "nav_coins", "Monedas",
    "nav_logs", "Registros",
    "nav_about", "Acerca de",
    "pg_home_sub", "¡Hola, {1}! Resumen del monitoreo",
    "pg_game_sub", "Servidor, intervalo de revisión y recuperación de errores",
    "pg_win_sub", "Posición de la ventana de Roblox y pestaña del navegador",
    "pg_hook_sub", "Avisos y estado en Discord",
    "pg_coins_sub", "Lee tus monedas en la pantalla de Roblox y las envía al webhook",
    "pg_about_sub", "Licencia, versión y novedades",
    "pg_logs_sub", "Historial de esta sesión",
    "idle", "Detenido",
    "click_start", "Haz clic en Iniciar para monitorear",
    "btn_start", "Iniciar",
    "btn_stop", "Detener",
    "st_uptime", "TIEMPO ACTIVO",
    "st_reopens", "REAPERTURAS",
    "st_drops", "CAÍDAS",
    "st_lastdrop", "ÚLTIMA CAÍDA",
    "quick", "ACCIONES RÁPIDAS",
    "btn_open_now", "Abrir juego ahora",
    "btn_place", "Colocar ventana",
    "btn_compact", "Modo compacto",
    "sec_server", "SERVIDOR",
    "hint_link", "Enlace del juego, enlace de servidor privado o solo el Place ID.",
    "sec_monitor", "MONITOREO",
    "lbl_check", "Revisar cada (segundos)",
    "lbl_wait", "Esperar al abrir (segundos)",
    "sec_recovery", "RECUPERACIÓN",
    "sw_err", "Reiniciar si hay error, desconexión o congelamiento",
    "sw_err_sub", "Desconexión en el registro, expulsión, teletransporte fallido o ventana sin respuesta",
    "lbl_tol", "Tolerancia (segundos)",
    "sec_pos", "POSICIÓN",
    "sw_place", "Colocar en la esquina superior derecha",
    "sw_place_sub", "Mantiene la ventana de Roblox fija y totalmente visible",
    "lbl_width", "Ancho",
    "lbl_height", "Alto",
    "btn_place_now", "Colocar ahora",
    "sec_browser", "NAVEGADOR",
    "sw_tab", "Cerrar la pestaña del navegador al entrar",
    "sw_tab_sub", "Cierra la pestaña con 'Roblox' en el título y minimiza el navegador",
    "btn_test", "Probar",
    "hint_hook", "Avisos automáticos: caída, intento de reabrir, regreso y errores (con hora).",
    "sec_status", "ESTADO PERIÓDICO",
    "sw_rep", "Enviar estado con captura",
    "sw_rep_sub", "Embed con el estado de la cuenta + captura solo de la ventana de Roblox",
    "lbl_interval", "Intervalo (minutos)",
    "btn_send_now", "Enviar ahora",
    "sec_ocr", "LECTURA DE PANTALLA (OCR)",
    "sw_ocr", "Enviar monedas en el embed de estado",
    "sw_ocr_sub", "Lee los valores que aparecen en la ventana de Roblox",
    "lbl_coins", "Monedas (separa con | ). Emoji opcional: Gems=<:gems:123456>",
    "sec_lastread", "ÚLTIMA LECTURA",
    "btn_testread", "Probar lectura",
    "no_read", "Sin lecturas aún.",
    "not_found", "no encontrado",
    "nothing_read", "Nada leído.",
    "ocr_open", "Abre Roblox (sin minimizar) con las monedas visibles.",
    "ocr_names", "Escribe los nombres de las monedas arriba.",
    "log_ocr_tested", "Lectura de monedas probada ({1}/{2} encontradas).",
    "ocr_err", "Error de OCR: {1}",
    "log_ocr_saw", "Texto que vio el OCR:",
    "log_coin_err", "Error al leer monedas: {1}",
    "sec_version", "VERSIÓN INSTALADA",
    "upd_never", "Aún no verificado.",
    "btn_checkupd", "Buscar actualización",
    "sec_license", "LICENCIA",
    "btn_changekey", "Cambiar key",
    "paste_new_key", "Pega la nueva key.",
    "sw_autoupd", "Actualizar automáticamente",
    "sec_news", "NOVEDADES",
    "news_ph", "Las novedades aparecen aquí tras verificar.",
    "btn_clear", "Limpiar",
    "upd_not_cfg", "Actualizaciones no configuradas.",
    "upd_searching", "Buscando actualización...",
    "upd_noconn", "No se pudo verificar ahora.",
    "upd_badfile", "El archivo descargado no parece ser el script.",
    "upd_latest", "Tienes la versión más reciente.",
    "upd_avail", "¡Nueva versión v{1} disponible! Mira las novedades abajo.",
    "btn_upd_to", "Actualizar a v{1}",
    "badge_new", "Nueva versión v{1}",
    "log_upd_avail", "Actualización disponible: v{1}.",
    "log_upd_dlfail", "Error al descargar la actualización: {1}",
    "log_upd_fail", "Error al actualizar: {1}",
    "log_updated", "¡Actualizado a v{1}! Reiniciando...",
    "lang_menu", "Idioma",
    "lang_auto", "Automático (sistema)",
    "mini_sub", "reap. {1} · caídas {2}",
    "key_title", "Activar licencia",
    "key_sub", "Pega tu key para desbloquear Auto Reconnect Roblox.",
    "btn_activate", "Activar",
    "your_hwid", "TU HWID",
    "btn_copy", "Copiar",
    "hwid_copied", "HWID copiado.",
    "btn_buy", "Comprar key",
    "checking_lic", "Verificando licencia...",
    "ka_app_nf", "Aplicación no encontrada en KeyAuth (revisa nombre/Owner ID).",
    "ka_badver", "Versión de KeyAuth distinta (iguala KEYAUTH_VER al panel).",
    "key_nf", "La key no existe.",
    "key_invalid", "Key inválida.",
    "key_hwid", "Esta key ya está activada en otra PC (HWID distinto).",
    "key_expired", "Tu key expiró.",
    "hwid_banned", "Esta PC fue baneada.",
    "key_banned", "Esta key fue baneada.",
    "session_exp", "La sesión expiró, intenta de nuevo.",
    "key_fail", "No se pudo validar la key.",
    "paste_key_first", "Pega tu key primero.",
    "checking", "Verificando...",
    "connecting", "Conectando al servidor de licencias...",
    "no_conn", "Sin conexión con el servidor de licencias. Revisa tu internet.",
    "lic_lifetime", "De por vida",
    "side_lifetime", "LICENCIA DE POR VIDA",
    "lic_expires", "Expira el {1}  ({2} días)",
    "side_days", "LICENCIA: {1} DÍAS",
    "lic_active", "Activa",
    "side_active", "LICENCIA ACTIVA",
    "lic_offline", "Más de 2 h sin poder validar la licencia.",
    "log_lic_bad", "Licencia inválida: {1}",
    "activate_to_use", "Activa tu key para usarlo.",
    "hook_need_url", "Pon la URL del webhook primero.",
    "hook_sent", "Webhook enviado (HTTP {1}).",
    "hook_fail", "Fallo del webhook: {1}",
    "log_status_sent", "Estado enviado (HTTP {1}).",
    "log_status_fail", "Error al enviar estado: {1}",
    "why_closed", "Roblox cerrado",
    "why_min", "ventana minimizada",
    "why_fail", "fallo al capturar",
    "emb_offline", "Desconectado",
    "emb_warn", "En línea · desconexión en el registro",
    "emb_online", "En línea en el juego",
    "up_stopped", "detenido",
    "none", "Ninguna",
    "next_status", "próximo estado en {1} min",
    "no_shot", "sin captura ({1})",
    "f_uptime", "Tiempo activo",
    "f_reopens", "Reaperturas",
    "f_drops", "Caídas",
    "f_lastdrop", "Última caída",
    "m_exe", "directo por Roblox",
    "m_uri", "enlace roblox://",
    "m_web", "navegador",
    "roblox_not_reg", "Roblox no encontrado en el registro",
    "paste_link_first", "Pega el enlace del juego primero.",
    "log_all_failed", "Ningún método funcionó. Reintento en la próxima revisión.",
    "log_method_failed", "Método {1}/{2} ({3}) falló: {4}",
    "log_opening", "Abriendo ({1})",
    "log_reopening", "Reabriendo ({1})",
    "log_opened", "Roblox abrió ({1}s). Entrando al juego...",
    "st_joining", "Entrando al juego...",
    "st_joining_sub", "Roblox abierto, cargando el servidor",
    "log_joined", "Entró al juego ({1}s).",
    "log_not_open25", "Roblox no abrió en 25 s, probando otro método...",
    "log_not_join60", "Roblox abrió pero no entró al juego en 60 s, probando otro método...",
    "log_not_open", "Roblox no está abierto.",
    "log_placed", "Ventana de Roblox colocada.",
    "log_detected", "Ventana de Roblox detectada.",
    "log_placed_right", "Ventana de Roblox colocada en la esquina derecha.",
    "log_tab_closed", "Pestaña de Roblox cerrada en el navegador.",
    "log_tab_nf", "No encontré la pestaña de Roblox. Títulos abiertos:",
    "none_lc", "ninguno",
    "log_disc_log", "Desconexión en el registro. Esperando reingreso...",
    "log_err_restart", "Error detectado: {1}. Reiniciando Roblox...",
    "log_disc_screen", "Pantalla de Disconnected en la ventana.",
    "log_disc_screen_c", "Pantalla de Disconnected en la ventana (código {1}).",
    "r_disc_screen", "pantalla de Disconnected",
    "r_disc_screen_c", "pantalla de Disconnected - código {1}",
    "log_rejoined", "Reingresó / teletransporte normal, ok.",
    "r_no_rejoin", "desconexión/error sin reingresar",
    "r_hung", "ventana congelada (sin respuesta)",
    "log_back", "Roblox volvió (fuera por {1}).",
    "log_down", "Roblox se cerró/desconectó.",
    "st_loading", "Cargando...",
    "st_loading_sub", "Esperando que el juego abra y entre al servidor",
    "st_on_warn_sub", "Desconexión en el registro, esperando reingreso",
    "st_on_sub", "En el juego · monitoreando",
    "st_off_sub", "Cerrado, reabriendo ahora",
    "st_nolink", "Sin enlace",
    "st_nolink_sub", "Pega el enlace en la pestaña Juego",
    "st_monitoring", "Monitoreando...",
    "st_monitoring_sub", "Revisando Roblox",
    "log_mon_start", "Monitoreo iniciado (cada {1}s).",
    "log_mon_stop", "Monitoreo detenido.",
    "ev_start", "Monitoreo iniciado",
    "ev_reopen", "Reabriendo Roblox",
    "ev_fail", "No se pudo abrir Roblox",
    "ev_error", "Error detectado",
    "ev_back", "Roblox volvió",
    "ev_down", "Roblox se cerró/desconectó",
    "ev_lic", "Licencia inválida",
    "ev_updated", "Actualizado a v{1}",
    "ev_test", "¡El webhook funciona!",
    "d_time", "Hora",
    "d_away", "Estuvo fuera",
    "d_reason", "Motivo",
    "d_restart", "Reiniciando Roblox...",
    "d_stopped", "Monitoreo detenido.",
    "d_retry", "Lo intentaré de nuevo en la próxima revisión.",
    "d_test", "Los avisos llegarán aquí.",
    "d_method", "Método",
    "d_interval", "Revisión cada",
    "d_user", "Usuario",
    "tour_welcome_t", "¡Bienvenido, {1}!",
    "tour_welcome", "Te muestro lo básico en menos de un minuto. Puedes saltarlo cuando quieras.",
    "tour_link_t", "1. Enlace del juego",
    "tour_link", "Pega aquí el enlace del juego, del servidor privado o solo el Place ID. Ahí es donde el script te devuelve.",
    "tour_hook_t", "2. Avisos en Discord",
    "tour_hook", "Opcional: pega el webhook de un canal de Discord para recibir avisos cuando caigas, vuelvas o haya un error.",
    "tour_test_t", "Probar webhook",
    "tour_test", "Haz clic aquí para comprobar que los avisos llegan a Discord.",
    "tour_win_t", "3. Posición de la ventana",
    "tour_win", "Con esto activado, la ventana de Roblox queda fija en la esquina superior derecha.",
    "tour_coins_t", "4. Monedas (opcional)",
    "tour_coins", "Escribe los nombres de las monedas que aparecen en pantalla para incluirlas en el estado de Discord.",
    "tour_start_t", "5. ¡Empezar!",
    "tour_start", "Cuando todo esté listo, haz clic en Iniciar. El script vigila Roblox y lo reabre si caes.",
    "tour_compact_t", "Modo compacto",
    "tour_compact", "Deja solo una barra pequeña en pantalla para ocupar menos espacio.",
    "tour_lang_t", "Idioma",
    "tour_lang", "Cambia el idioma aquí. Por defecto sigue el idioma de Windows.",
    "tour_upd_t", "Actualizaciones",
    "tour_upd", "Cuando salga una versión nueva, aparece un aviso arriba y actualizas aquí con un clic.",
    "tour_done_t", "¡Todo listo!",
    "tour_done", "Puedes volver a ver este tutorial en Acerca de → Ver tutorial.",
    "btn_next", "Siguiente",
    "btn_back", "Atrás",
    "btn_skip", "Saltar",
    "btn_finish", "Terminar",
    "btn_tour", "Ver tutorial",
    "tour_step", "{1} de {2}",
    "nav_opts", "Opciones",
    "nav_accounts", "Cuentas",
    "pg_opts_sub", "Inicio, notificaciones y resumen diario",
    "pg_acc_sub", "Varias cuentas a la vez (experimental)",
    "sec_startup", "INICIO",
    "sw_startwin", "Iniciar con Windows",
    "sw_startwin_sub", "Abre el script al encender la PC",
    "sw_automon", "Empezar a monitorear al abrir",
    "sw_automon_sub", "Pulsa Iniciar por ti al abrir el script",
    "sec_notify", "NOTIFICACIONES",
    "sw_toast", "Notificación de Windows",
    "sw_toast_sub", "Aviso en la esquina al caer, volver o haber error",
    "sw_tray", "Minimizar a la bandeja",
    "sw_tray_sub", "Al minimizar, queda solo el icono junto al reloj",
    "sec_daily", "RESUMEN DIARIO",
    "sw_daily", "Enviar resumen del día a Discord",
    "lbl_daily_time", "Hora (HH:MM)",
    "sec_mention", "MENCIONARTE",
    "sw_mention", "Mencionarme si caigo o hay error",
    "sw_mention_sub", "Solo te menciona a ti, nunca @everyone",
    "lbl_discord_id", "Tu ID de Discord",
    "btn_how", "¿Cómo encontrarlo?",
    "hint_discord_id", "Discord > Ajustes > Avanzado > activa el Modo desarrollador. Luego clic derecho en tu nombre > Copiar ID de usuario.",
    "sw_multi", "Usar varias cuentas",
    "sw_multi_sub", "Cierra Roblox antes de iniciar. Todas usan el enlace de la pestaña Juego.",
    "col_account", "Cuenta",
    "col_status", "Estado",
    "btn_add_acc", "Añadir cuenta",
    "btn_rem_acc", "Quitar",
    "btn_tile", "Ordenar ventanas",
    "acc_cookie", "Cookie .ROBLOSECURITY de la cuenta",
    "acc_cookie_hint", "En el navegador con la cuenta: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Se guarda cifrado en este PC. Nunca lo compartas.",
    "btn_save", "Guardar",
    "btn_cancel", "Cancelar",
    "acc_checking", "Verificando la cuenta...",
    "acc_invalid", "Cookie inválido o vencido.",
    "acc_added", "Cuenta {1} añadida.",
    "acc_st_off", "Cerrada",
    "acc_st_opening", "Abriendo...",
    "acc_st_on", "En el juego",
    "acc_st_down", "Cayó, reabriendo",
    "acc_st_err", "Error: {1}",
    "multi_close", "Cierra todos los Roblox antes de iniciar el modo de varias cuentas.",
    "acc_need", "Añade al menos una cuenta en la pestaña Cuentas.",
    "log_acc_launch", "[{1}] abriendo...",
    "log_acc_down", "[{1}] se cayó.",
    "log_acc_dlg", "[{1}] pantalla de Disconnected, reiniciando.",
    "log_acc_fail", "[{1}] no se pudo abrir: {2}",
    "d_account", "Cuenta",
    "tray_open", "Abrir",
    "tray_toggle", "Iniciar / Detener",
    "tray_exit", "Salir",
    "ev_daily", "Resumen del día",
    "f_online_today", "En línea hoy",
    "f_drops_today", "Caídas hoy",
    "f_reopens_today", "Reaperturas hoy",
    "d_earned", "Ganado hoy",
    "nav_auto", "Automatización",
    "nav_bot", "Bot",
    "nav_hist", "Historial",
    "pg_auto_sub", "Horarios y modo económico",
    "pg_bot_sub", "Controla el script desde Discord",
    "pg_hist_sub", "Tus últimos 14 días",
    "sec_sched", "HORARIO",
    "sw_sched", "Monitorear solo en un horario",
    "sw_sched_sub", "Fuera del horario se pausa y luego vuelve solo",
    "lbl_from", "Desde",
    "lbl_to", "hasta",
    "lbl_maxh", "Detener tras (horas, 0 = nunca)",
    "lbl_onend", "Al terminar",
    "act_none", "No hacer nada",
    "act_close", "Cerrar Roblox",
    "act_shutdown", "Apagar la PC",
    "sec_eco", "MODO ECONÓMICO",
    "sw_eco", "Activar modo económico",
    "sw_eco_sub", "Se aplica la próxima vez que abra Roblox",
    "lbl_fps", "Límite de FPS",
    "fps_none", "Sin límite",
    "sw_lowgfx", "Gráficos al mínimo",
    "sw_mute", "Sonido apagado",
    "sw_lowprio", "Prioridad baja para Roblox",
    "sec_bot", "BOT DE DISCORD",
    "sw_bot", "Controlar desde Discord",
    "sw_bot_sub", "Solo obedece a tu ID (pestaña Webhook)",
    "lbl_token", "Token del bot",
    "lbl_channel", "ID del canal",
    "bot_off", "Apagado",
    "bot_ok", "Conectado, escuchando comandos",
    "bot_err", "Error: {1}",
    "bot_need_id", "Pon tu ID de Discord en la pestaña Webhook.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Activa 'Message Content Intent', invita el bot al servidor y copia el ID del canal (clic derecho en el canal).",
    "sec_cmds", "COMANDOS",
    "cmd_status", "muestra el estado con captura",
    "cmd_start", "empieza a monitorear",
    "cmd_stop", "deja de monitorear",
    "cmd_restart", "cierra y vuelve a abrir Roblox",
    "cmd_summary", "envía el resumen del día",
    "cmd_help", "lista los comandos",
    "log_bot_cmd", "Comando de Discord: {1}",
    "hist_online", "Tiempo en línea",
    "hist_coin", "Moneda: {1}",
    "hist_empty", "Sin datos aún. El historial se llena con los días.",
    "acc_edit", "Editar cuenta",
    "acc_link", "Enlace de esta cuenta (opcional)",
    "acc_ck_keep", "Déjalo vacío para mantener la cookie actual.",
    "col_link", "Enlace",
    "link_default", "por defecto",
    "acc_dbl_hint", "Haz doble clic en una cuenta para editar su enlace.",
    "log_sched_pause", "Fuera del horario, monitoreo en pausa.",
    "log_sched_resume", "Dentro del horario, monitoreo reanudado.",
    "log_maxh", "Tiempo máximo alcanzado, deteniendo.",
    "ev_sched", "Monitoreo terminado",
    "d_shutdown", "La PC se apagará en 60 segundos.",
    "ev_stop", "Monitoreo detenido",
    "ev_restart", "Reiniciando Roblox",
    "ev_already", "Ya está monitoreando",
    "ev_notrunning", "El monitoreo ya está detenido",
    "ev_unknown", "Comando desconocido",
    "d_unknown", "Usa !ajuda para ver los comandos.",
    "d_restart_how", "Cerrando y abriendo de nuevo directo por Roblox.",
    "d_running_for", "Activo desde hace",
    "d_cmd", "Comando",
    "cmd_print", "envía solo la captura de Roblox",
    "cmd_coins", "muestra tus monedas ahora",
    "cmd_pc", "uso de CPU y memoria de la PC",
    "cmd_accounts", "estado de cada cuenta",
    "cmd_hist", "gráfico de los últimos 7 días",
    "cmd_logs", "últimas líneas del registro",
    "cmd_ping", "comprueba que el bot responde",
    "cmd_link", "cambia el enlace del juego",
    "cmd_update", "busca e instala actualizaciones",
    "cmd_shutdown", "apaga la PC (!desligar confirmar)",
    "cmd_cancel", "cancela el apagado",
    "grp_control", "Control",
    "grp_info", "Información",
    "grp_config", "Configuración",
    "f_session", "Sesión",
    "f_link", "Enlace",
    "f_version", "Versión",
    "f_cpu", "CPU",
    "f_ram", "Memoria",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC encendida hace",
    "f_script_up", "Script abierto hace",
    "f_latency", "Latencia",
    "f_windows", "Ventanas de Roblox",
    "ev_pong", "¡Pong!",
    "ev_pc", "Estado de la PC",
    "ev_coins", "Tus monedas",
    "ev_accounts", "Cuentas",
    "ev_hist", "Últimos 7 días",
    "ev_logs", "Últimos registros",
    "ev_link", "Enlace cambiado",
    "d_link_next", "Se aplica en la próxima apertura. Manda !reiniciar para aplicarlo ya.",
    "ev_linkbad", "Enlace inválido",
    "d_link_usage", "Usa: !link <enlace del juego, del servidor o Place ID>",
    "ev_updnone", "Ya tienes la versión más reciente",
    "ev_updating", "Actualizando a v{1}",
    "ev_shutdown", "Apagando la PC",
    "ev_shutconf", "Confirma el apagado",
    "d_shutconf", "Manda !desligar confirmar para apagar en 60 segundos.",
    "ev_cancel", "Apagado cancelado",
    "d_back_in", "Volvió al juego en {1}s",
    "ev_print", "Captura de Roblox",
    "no_accounts", "No hay cuentas añadidas.",
    "no_coins", "No pude leer las monedas (deja el panel visible en la ventana).",
    "sec_panel", "PANEL EN VIVO",
    "sw_panel", "Panel fijo en el canal",
    "sw_panel_sub", "Un solo mensaje con estado y captura que se actualiza solo",
    "lbl_panel_min", "Actualizar cada (min)",
    "ev_panel", "Panel en vivo",
    "d_updated", "Actualizado",
    "bot_hint_help", "Manda !ajuda en el canal para ver todos los comandos.",
    "sec_stuck", "FARM ATASCADO",
    "sw_stuck", "Avisar si las monedas dejan de subir",
    "sw_stuck_sub", "Lee las monedas cada minuto para saber si el farm avanza",
    "lbl_stuck_min", "Tiempo sin cambios (min)",
    "stuck_alert", "Solo avisar",
    "stuck_restart", "Avisar y reiniciar",
    "ev_stuck", "Farm detenido",
    "d_stuck", "Las monedas no cambian desde hace {1} min.",
    "r_stuck", "farm detenido (monedas sin cambios)",
    "log_stuck", "Farm detenido hace {1} min.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Apariencia",
    "pg_look_sub", "Elige el tema del programa",
    "sec_theme", "TEMA"
)
I18N["fr"] := Map(
    "nav_home", "Accueil",
    "nav_game", "Jeu",
    "nav_window", "Fenêtre",
    "nav_hook", "Webhook",
    "nav_coins", "Monnaies",
    "nav_logs", "Journal",
    "nav_about", "À propos",
    "pg_home_sub", "Salut, {1} ! Vue d'ensemble de la surveillance",
    "pg_game_sub", "Serveur, intervalle de vérification et récupération d'erreurs",
    "pg_win_sub", "Position de la fenêtre Roblox et onglet du navigateur",
    "pg_hook_sub", "Alertes et statut sur Discord",
    "pg_coins_sub", "Lit vos monnaies à l'écran de Roblox et les envoie au webhook",
    "pg_about_sub", "Licence, version et nouveautés",
    "pg_logs_sub", "Historique de cette session",
    "idle", "Arrêté",
    "click_start", "Cliquez sur Démarrer pour surveiller",
    "btn_start", "Démarrer",
    "btn_stop", "Arrêter",
    "st_uptime", "TEMPS ACTIF",
    "st_reopens", "RÉOUVERTURES",
    "st_drops", "COUPURES",
    "st_lastdrop", "DERNIÈRE COUPURE",
    "quick", "ACTIONS RAPIDES",
    "btn_open_now", "Ouvrir le jeu",
    "btn_place", "Placer la fenêtre",
    "btn_compact", "Mode compact",
    "sec_server", "SERVEUR",
    "hint_link", "Lien du jeu, lien de serveur privé ou juste le Place ID.",
    "sec_monitor", "SURVEILLANCE",
    "lbl_check", "Vérifier toutes les (secondes)",
    "lbl_wait", "Attendre après ouverture (s)",
    "sec_recovery", "RÉCUPÉRATION",
    "sw_err", "Redémarrer en cas d'erreur, déconnexion ou gel",
    "sw_err_sub", "Déconnexion dans le journal, expulsion, téléportation échouée ou fenêtre figée",
    "lbl_tol", "Tolérance (secondes)",
    "sec_pos", "POSITION",
    "sw_place", "Placer dans le coin supérieur droit",
    "sw_place_sub", "Garde la fenêtre Roblox fixe et entièrement visible",
    "lbl_width", "Largeur",
    "lbl_height", "Hauteur",
    "btn_place_now", "Placer maintenant",
    "sec_browser", "NAVIGATEUR",
    "sw_tab", "Fermer l'onglet du navigateur après connexion",
    "sw_tab_sub", "Ferme l'onglet avec 'Roblox' dans le titre et réduit le navigateur",
    "btn_test", "Tester",
    "hint_hook", "Alertes automatiques : coupure, réouverture, retour et erreurs (avec l'heure).",
    "sec_status", "STATUT PÉRIODIQUE",
    "sw_rep", "Envoyer le statut avec capture",
    "sw_rep_sub", "Embed avec l'état du compte + capture de la fenêtre Roblox uniquement",
    "lbl_interval", "Intervalle (minutes)",
    "btn_send_now", "Envoyer",
    "sec_ocr", "LECTURE D'ÉCRAN (OCR)",
    "sw_ocr", "Envoyer les monnaies dans l'embed de statut",
    "sw_ocr_sub", "Lit les valeurs affichées dans la fenêtre Roblox",
    "lbl_coins", "Monnaies (séparez avec | ). Emoji facultatif : Gems=<:gems:123456>",
    "sec_lastread", "DERNIÈRE LECTURE",
    "btn_testread", "Tester la lecture",
    "no_read", "Aucune lecture pour l'instant.",
    "not_found", "introuvable",
    "nothing_read", "Rien lu.",
    "ocr_open", "Ouvrez Roblox (non réduit) avec les monnaies visibles.",
    "ocr_names", "Saisissez les noms des monnaies ci-dessus.",
    "log_ocr_tested", "Lecture des monnaies testée ({1}/{2} trouvées).",
    "ocr_err", "Erreur OCR : {1}",
    "log_ocr_saw", "Texte vu par l'OCR :",
    "log_coin_err", "Erreur de lecture des monnaies : {1}",
    "sec_version", "VERSION INSTALLÉE",
    "upd_never", "Pas encore vérifié.",
    "btn_checkupd", "Rechercher une mise à jour",
    "sec_license", "LICENCE",
    "btn_changekey", "Changer de clé",
    "paste_new_key", "Collez la nouvelle clé.",
    "sw_autoupd", "Mise à jour automatique",
    "sec_news", "NOUVEAUTÉS",
    "news_ph", "Les nouveautés s'affichent ici après vérification.",
    "btn_clear", "Effacer",
    "upd_not_cfg", "Mises à jour non configurées.",
    "upd_searching", "Recherche de mise à jour...",
    "upd_noconn", "Impossible de vérifier pour le moment.",
    "upd_badfile", "Le fichier téléchargé ne semble pas être le script.",
    "upd_latest", "Vous avez la dernière version.",
    "upd_avail", "Nouvelle version v{1} disponible ! Voir les nouveautés ci-dessous.",
    "btn_upd_to", "Mettre à jour v{1}",
    "badge_new", "Nouvelle version v{1}",
    "log_upd_avail", "Mise à jour disponible : v{1}.",
    "log_upd_dlfail", "Échec du téléchargement de la mise à jour : {1}",
    "log_upd_fail", "Échec de la mise à jour : {1}",
    "log_updated", "Mis à jour en v{1} ! Redémarrage...",
    "lang_menu", "Langue",
    "lang_auto", "Automatique (système)",
    "mini_sub", "réouv. {1} · coupures {2}",
    "key_title", "Activer la licence",
    "key_sub", "Collez votre clé pour débloquer Auto Reconnect Roblox.",
    "btn_activate", "Activer",
    "your_hwid", "VOTRE HWID",
    "btn_copy", "Copier",
    "hwid_copied", "HWID copié.",
    "btn_buy", "Acheter une clé",
    "checking_lic", "Vérification de la licence...",
    "ka_app_nf", "Application introuvable sur KeyAuth (vérifiez nom/Owner ID).",
    "ka_badver", "Version KeyAuth différente (alignez KEYAUTH_VER sur le panneau).",
    "key_nf", "Cette clé n'existe pas.",
    "key_invalid", "Clé invalide.",
    "key_hwid", "Cette clé est déjà activée sur un autre PC (HWID différent).",
    "key_expired", "Votre clé a expiré.",
    "hwid_banned", "Ce PC a été banni.",
    "key_banned", "Cette clé a été bannie.",
    "session_exp", "Session expirée, réessayez.",
    "key_fail", "Impossible de valider la clé.",
    "paste_key_first", "Collez d'abord votre clé.",
    "checking", "Vérification...",
    "connecting", "Connexion au serveur de licences...",
    "no_conn", "Serveur de licences injoignable. Vérifiez votre connexion.",
    "lic_lifetime", "À vie",
    "side_lifetime", "LICENCE À VIE",
    "lic_expires", "Expire le {1}  ({2} jours)",
    "side_days", "LICENCE : {1} JOURS",
    "lic_active", "Active",
    "side_active", "LICENCE ACTIVE",
    "lic_offline", "Licence non vérifiée depuis plus de 2 h.",
    "log_lic_bad", "Licence invalide : {1}",
    "activate_to_use", "Activez votre clé pour l'utiliser.",
    "hook_need_url", "Saisissez d'abord l'URL du webhook.",
    "hook_sent", "Webhook envoyé (HTTP {1}).",
    "hook_fail", "Échec du webhook : {1}",
    "log_status_sent", "Statut envoyé (HTTP {1}).",
    "log_status_fail", "Échec d'envoi du statut : {1}",
    "why_closed", "Roblox fermé",
    "why_min", "fenêtre réduite",
    "why_fail", "échec de la capture",
    "emb_offline", "Hors ligne",
    "emb_warn", "En ligne · déconnexion dans le journal",
    "emb_online", "En ligne en jeu",
    "up_stopped", "arrêté",
    "none", "Aucune",
    "next_status", "prochain statut dans {1} min",
    "no_shot", "sans capture ({1})",
    "f_uptime", "Temps actif",
    "f_reopens", "Réouvertures",
    "f_drops", "Coupures",
    "f_lastdrop", "Dernière coupure",
    "m_exe", "directement via Roblox",
    "m_uri", "lien roblox://",
    "m_web", "navigateur",
    "roblox_not_reg", "Roblox introuvable dans le registre",
    "paste_link_first", "Collez d'abord le lien du jeu.",
    "log_all_failed", "Aucune méthode n'a fonctionné. Nouvel essai à la prochaine vérification.",
    "log_method_failed", "Méthode {1}/{2} ({3}) échouée : {4}",
    "log_opening", "Ouverture ({1})",
    "log_reopening", "Réouverture ({1})",
    "log_opened", "Roblox ouvert ({1}s). Connexion au jeu...",
    "st_joining", "Connexion au jeu...",
    "st_joining_sub", "Roblox ouvert, chargement du serveur",
    "log_joined", "Connecté au jeu ({1}s).",
    "log_not_open25", "Roblox ne s'est pas ouvert en 25 s, autre méthode...",
    "log_not_join60", "Roblox ouvert mais pas de connexion au jeu en 60 s, autre méthode...",
    "log_not_open", "Roblox n'est pas ouvert.",
    "log_placed", "Fenêtre Roblox placée.",
    "log_detected", "Fenêtre Roblox détectée.",
    "log_placed_right", "Fenêtre Roblox placée dans le coin droit.",
    "log_tab_closed", "Onglet Roblox fermé dans le navigateur.",
    "log_tab_nf", "Onglet Roblox introuvable. Titres ouverts :",
    "none_lc", "aucun",
    "log_disc_log", "Déconnexion dans le journal. En attente de reconnexion...",
    "log_err_restart", "Erreur détectée : {1}. Redémarrage de Roblox...",
    "log_disc_screen", "Écran Disconnected dans la fenêtre.",
    "log_disc_screen_c", "Écran Disconnected dans la fenêtre (code {1}).",
    "r_disc_screen", "écran Disconnected",
    "r_disc_screen_c", "écran Disconnected - code {1}",
    "log_rejoined", "Reconnecté / téléportation normale, ok.",
    "r_no_rejoin", "déconnexion/erreur sans reconnexion",
    "r_hung", "fenêtre figée (ne répond pas)",
    "log_back", "Roblox est revenu (absent {1}).",
    "log_down", "Roblox fermé/déconnecté.",
    "st_loading", "Chargement...",
    "st_loading_sub", "En attente de l'ouverture du jeu et de la connexion",
    "st_on_warn_sub", "Déconnexion dans le journal, attente de reconnexion",
    "st_on_sub", "En jeu · surveillance",
    "st_off_sub", "Fermé, réouverture en cours",
    "st_nolink", "Pas de lien",
    "st_nolink_sub", "Collez le lien dans l'onglet Jeu",
    "st_monitoring", "Surveillance...",
    "st_monitoring_sub", "Vérification de Roblox",
    "log_mon_start", "Surveillance démarrée (toutes les {1}s).",
    "log_mon_stop", "Surveillance arrêtée.",
    "ev_start", "Surveillance démarrée",
    "ev_reopen", "Réouverture de Roblox",
    "ev_fail", "Impossible d'ouvrir Roblox",
    "ev_error", "Erreur détectée",
    "ev_back", "Roblox est revenu",
    "ev_down", "Roblox fermé/déconnecté",
    "ev_lic", "Licence invalide",
    "ev_updated", "Mis à jour en v{1}",
    "ev_test", "Le webhook fonctionne !",
    "d_time", "Heure",
    "d_away", "Absent pendant",
    "d_reason", "Raison",
    "d_restart", "Redémarrage de Roblox...",
    "d_stopped", "Surveillance arrêtée.",
    "d_retry", "Nouvel essai à la prochaine vérification.",
    "d_test", "Les alertes arriveront ici.",
    "d_method", "Méthode",
    "d_interval", "Vérification toutes les",
    "d_user", "Utilisateur",
    "tour_welcome_t", "Bienvenue, {1} !",
    "tour_welcome", "Je vous montre l'essentiel en moins d'une minute. Vous pouvez passer à tout moment.",
    "tour_link_t", "1. Lien du jeu",
    "tour_link", "Collez ici le lien du jeu, du serveur privé ou juste le Place ID. C'est là que le script vous ramène.",
    "tour_hook_t", "2. Alertes Discord",
    "tour_hook", "Facultatif : collez le webhook d'un salon Discord pour être alerté en cas de coupure, de retour ou d'erreur.",
    "tour_test_t", "Tester le webhook",
    "tour_test", "Cliquez ici pour vérifier que les alertes arrivent sur Discord.",
    "tour_win_t", "3. Position de la fenêtre",
    "tour_win", "Activé, la fenêtre Roblox reste fixée dans le coin supérieur droit de l'écran.",
    "tour_coins_t", "4. Monnaies (facultatif)",
    "tour_coins", "Saisissez les noms des monnaies affichées pour les inclure dans le statut Discord.",
    "tour_start_t", "5. C'est parti !",
    "tour_start", "Quand tout est prêt, cliquez sur Démarrer. Le script surveille Roblox et le rouvre en cas de coupure.",
    "tour_compact_t", "Mode compact",
    "tour_compact", "Réduit tout en une petite barre pour prendre moins de place.",
    "tour_lang_t", "Langue",
    "tour_lang", "Changez de langue ici. Par défaut, celle de Windows est utilisée.",
    "tour_upd_t", "Mises à jour",
    "tour_upd", "Quand une nouvelle version sort, un avis apparaît en haut et vous mettez à jour ici en un clic.",
    "tour_done_t", "C'est prêt !",
    "tour_done", "Revoyez ce tutoriel quand vous voulez dans À propos → Voir le tutoriel.",
    "btn_next", "Suivant",
    "btn_back", "Retour",
    "btn_skip", "Passer",
    "btn_finish", "Terminer",
    "btn_tour", "Voir le tutoriel",
    "tour_step", "{1} sur {2}",
    "nav_opts", "Options",
    "nav_accounts", "Comptes",
    "pg_opts_sub", "Démarrage, notifications et résumé quotidien",
    "pg_acc_sub", "Plusieurs comptes en même temps (expérimental)",
    "sec_startup", "DÉMARRAGE",
    "sw_startwin", "Lancer avec Windows",
    "sw_startwin_sub", "Ouvre le script au démarrage du PC",
    "sw_automon", "Démarrer la surveillance à l'ouverture",
    "sw_automon_sub", "Clique sur Démarrer pour vous à l'ouverture",
    "sec_notify", "NOTIFICATIONS",
    "sw_toast", "Notification Windows",
    "sw_toast_sub", "Alerte dans le coin en cas de coupure, retour ou erreur",
    "sw_tray", "Réduire dans la barre d'état",
    "sw_tray_sub", "Une fois réduit, seule l'icône près de l'horloge reste",
    "sec_daily", "RÉSUMÉ QUOTIDIEN",
    "sw_daily", "Envoyer un résumé quotidien sur Discord",
    "lbl_daily_time", "Heure (HH:MM)",
    "sec_mention", "VOUS MENTIONNER",
    "sw_mention", "Me mentionner en cas de coupure ou d'erreur",
    "sw_mention_sub", "Ne mentionne que vous, jamais @everyone",
    "lbl_discord_id", "Votre ID Discord",
    "btn_how", "Comment le trouver ?",
    "hint_discord_id", "Discord > Paramètres > Avancés > activez le Mode développeur. Puis clic droit sur votre nom > Copier l'identifiant.",
    "sw_multi", "Utiliser plusieurs comptes",
    "sw_multi_sub", "Fermez Roblox avant de démarrer. Tous utilisent le lien de l'onglet Jeu.",
    "col_account", "Compte",
    "col_status", "Statut",
    "btn_add_acc", "Ajouter un compte",
    "btn_rem_acc", "Supprimer",
    "btn_tile", "Organiser les fenêtres",
    "acc_cookie", "Cookie .ROBLOSECURITY du compte",
    "acc_cookie_hint", "Dans un navigateur connecté au compte : F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Enregistré chiffré sur ce PC. Ne le partagez jamais.",
    "btn_save", "Enregistrer",
    "btn_cancel", "Annuler",
    "acc_checking", "Vérification du compte...",
    "acc_invalid", "Cookie invalide ou expiré.",
    "acc_added", "Compte {1} ajouté.",
    "acc_st_off", "Fermé",
    "acc_st_opening", "Ouverture...",
    "acc_st_on", "En jeu",
    "acc_st_down", "Coupé, réouverture",
    "acc_st_err", "Erreur : {1}",
    "multi_close", "Fermez tous les Roblox avant de lancer le mode multi-comptes.",
    "acc_need", "Ajoutez au moins un compte dans l'onglet Comptes.",
    "log_acc_launch", "[{1}] ouverture...",
    "log_acc_down", "[{1}] coupé.",
    "log_acc_dlg", "[{1}] écran Disconnected, redémarrage.",
    "log_acc_fail", "[{1}] ouverture impossible : {2}",
    "d_account", "Compte",
    "tray_open", "Ouvrir",
    "tray_toggle", "Démarrer / Arrêter",
    "tray_exit", "Quitter",
    "ev_daily", "Résumé du jour",
    "f_online_today", "En ligne aujourd'hui",
    "f_drops_today", "Coupures aujourd'hui",
    "f_reopens_today", "Réouvertures aujourd'hui",
    "d_earned", "Gagné aujourd'hui",
    "nav_auto", "Automatisation",
    "nav_bot", "Bot",
    "nav_hist", "Historique",
    "pg_auto_sub", "Horaires et mode éco",
    "pg_bot_sub", "Contrôlez le script depuis Discord",
    "pg_hist_sub", "Vos 14 derniers jours",
    "sec_sched", "PLANIFICATION",
    "sw_sched", "Surveiller seulement à certaines heures",
    "sw_sched_sub", "Se met en pause hors horaires puis reprend seul",
    "lbl_from", "De",
    "lbl_to", "à",
    "lbl_maxh", "Arrêter après (heures, 0 = jamais)",
    "lbl_onend", "À la fin",
    "act_none", "Ne rien faire",
    "act_close", "Fermer Roblox",
    "act_shutdown", "Éteindre le PC",
    "sec_eco", "MODE ÉCO",
    "sw_eco", "Activer le mode éco",
    "sw_eco_sub", "S'applique au prochain lancement de Roblox",
    "lbl_fps", "Limite de FPS",
    "fps_none", "Sans limite",
    "sw_lowgfx", "Graphismes au minimum",
    "sw_mute", "Son coupé",
    "sw_lowprio", "Priorité basse pour Roblox",
    "sec_bot", "BOT DISCORD",
    "sw_bot", "Contrôler depuis Discord",
    "sw_bot_sub", "N'obéit qu'à votre ID (onglet Webhook)",
    "lbl_token", "Jeton du bot",
    "lbl_channel", "ID du salon",
    "bot_off", "Désactivé",
    "bot_ok", "Connecté, en écoute des commandes",
    "bot_err", "Erreur : {1}",
    "bot_need_id", "Saisissez votre ID Discord dans l'onglet Webhook.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Activez 'Message Content Intent', invitez le bot sur le serveur et copiez l'ID du salon (clic droit sur le salon).",
    "sec_cmds", "COMMANDES",
    "cmd_status", "affiche le statut avec capture",
    "cmd_start", "démarre la surveillance",
    "cmd_stop", "arrête la surveillance",
    "cmd_restart", "ferme et rouvre Roblox",
    "cmd_summary", "envoie le résumé du jour",
    "cmd_help", "liste les commandes",
    "log_bot_cmd", "Commande Discord : {1}",
    "hist_online", "Temps en ligne",
    "hist_coin", "Monnaie : {1}",
    "hist_empty", "Pas encore de données. L'historique se remplit au fil des jours.",
    "acc_edit", "Modifier le compte",
    "acc_link", "Lien de ce compte (facultatif)",
    "acc_ck_keep", "Laissez vide pour garder le cookie actuel.",
    "col_link", "Lien",
    "link_default", "par défaut",
    "acc_dbl_hint", "Double-cliquez sur un compte pour modifier son lien.",
    "log_sched_pause", "Hors horaires, surveillance en pause.",
    "log_sched_resume", "Dans les horaires, surveillance reprise.",
    "log_maxh", "Durée maximale atteinte, arrêt.",
    "ev_sched", "Surveillance terminée",
    "d_shutdown", "Le PC va s'éteindre dans 60 secondes.",
    "ev_stop", "Surveillance arrêtée",
    "ev_restart", "Redémarrage de Roblox",
    "ev_already", "Surveillance déjà en cours",
    "ev_notrunning", "La surveillance est déjà arrêtée",
    "ev_unknown", "Commande inconnue",
    "d_unknown", "Utilisez !help pour voir les commandes.",
    "d_restart_how", "Fermeture puis réouverture directement via Roblox.",
    "d_running_for", "Actif depuis",
    "d_cmd", "Commande",
    "cmd_print", "envoie juste une capture de Roblox",
    "cmd_coins", "affiche vos monnaies maintenant",
    "cmd_pc", "utilisation CPU et mémoire du PC",
    "cmd_accounts", "statut de chaque compte",
    "cmd_hist", "graphique des 7 derniers jours",
    "cmd_logs", "dernières lignes du journal",
    "cmd_ping", "vérifie que le bot répond",
    "cmd_link", "change le lien du jeu",
    "cmd_update", "cherche et installe les mises à jour",
    "cmd_shutdown", "éteint le PC (!shutdown confirm)",
    "cmd_cancel", "annule l'extinction",
    "grp_control", "Contrôle",
    "grp_info", "Infos",
    "grp_config", "Réglages",
    "f_session", "Session",
    "f_link", "Lien",
    "f_version", "Version",
    "f_cpu", "CPU",
    "f_ram", "Mémoire",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC allumé depuis",
    "f_script_up", "Script ouvert depuis",
    "f_latency", "Latence",
    "f_windows", "Fenêtres Roblox",
    "ev_pong", "Pong !",
    "ev_pc", "Santé du PC",
    "ev_coins", "Vos monnaies",
    "ev_accounts", "Comptes",
    "ev_hist", "7 derniers jours",
    "ev_logs", "Derniers journaux",
    "ev_link", "Lien modifié",
    "d_link_next", "S'applique au prochain lancement. Envoyez !restart pour l'appliquer maintenant.",
    "ev_linkbad", "Lien invalide",
    "d_link_usage", "Utilisez : !link <lien du jeu, du serveur ou Place ID>",
    "ev_updnone", "Déjà sur la dernière version",
    "ev_updating", "Mise à jour vers v{1}",
    "ev_shutdown", "Extinction du PC",
    "ev_shutconf", "Confirmez l'extinction",
    "d_shutconf", "Envoyez !shutdown confirm pour éteindre dans 60 secondes.",
    "ev_cancel", "Extinction annulée",
    "d_back_in", "De retour en jeu après {1}s",
    "ev_print", "Capture de Roblox",
    "no_accounts", "Aucun compte ajouté.",
    "no_coins", "Impossible de lire les monnaies (laissez le panneau visible).",
    "sec_panel", "PANNEAU EN DIRECT",
    "sw_panel", "Panneau fixe dans le salon",
    "sw_panel_sub", "Un seul message avec statut et capture, mis à jour tout seul",
    "lbl_panel_min", "Mettre à jour toutes les (min)",
    "ev_panel", "Panneau en direct",
    "d_updated", "Mis à jour",
    "bot_hint_help", "Envoyez !help dans le salon pour voir toutes les commandes.",
    "sec_stuck", "FARM BLOQUÉ",
    "sw_stuck", "Alerter si les monnaies n'augmentent plus",
    "sw_stuck_sub", "Lit les monnaies chaque minute pour savoir si le farm avance",
    "lbl_stuck_min", "Temps sans changement (min)",
    "stuck_alert", "Juste alerter",
    "stuck_restart", "Alerter et redémarrer",
    "ev_stuck", "Farm à l'arrêt",
    "d_stuck", "Les monnaies n'ont pas changé depuis {1} min.",
    "r_stuck", "farm à l'arrêt (monnaies inchangées)",
    "log_stuck", "Farm à l'arrêt depuis {1} min.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Apparence",
    "pg_look_sub", "Choisissez le thème",
    "sec_theme", "THÈME"
)
I18N["de"] := Map(
    "nav_home", "Start",
    "nav_game", "Spiel",
    "nav_window", "Fenster",
    "nav_hook", "Webhook",
    "nav_coins", "Währungen",
    "nav_logs", "Protokoll",
    "nav_about", "Info",
    "pg_home_sub", "Hallo, {1}! Überwachungsübersicht",
    "pg_game_sub", "Server, Prüfintervall und Fehlerbehebung",
    "pg_win_sub", "Position des Roblox-Fensters und Browser-Tab",
    "pg_hook_sub", "Benachrichtigungen und Status auf Discord",
    "pg_coins_sub", "Liest deine Währungen im Roblox-Fenster und sendet sie an den Webhook",
    "pg_about_sub", "Lizenz, Version und Neuigkeiten",
    "pg_logs_sub", "Verlauf dieser Sitzung",
    "idle", "Gestoppt",
    "click_start", "Klicke auf Starten, um zu überwachen",
    "btn_start", "Starten",
    "btn_stop", "Stoppen",
    "st_uptime", "LAUFZEIT",
    "st_reopens", "NEUSTARTS",
    "st_drops", "ABBRÜCHE",
    "st_lastdrop", "LETZTER ABBRUCH",
    "quick", "SCHNELLAKTIONEN",
    "btn_open_now", "Spiel jetzt öffnen",
    "btn_place", "Fenster platzieren",
    "btn_compact", "Kompaktmodus",
    "sec_server", "SERVER",
    "hint_link", "Spiel-Link, Link zum privaten Server oder nur die Place-ID.",
    "sec_monitor", "ÜBERWACHUNG",
    "lbl_check", "Prüfen alle (Sekunden)",
    "lbl_wait", "Warten nach dem Öffnen (Sek.)",
    "sec_recovery", "WIEDERHERSTELLUNG",
    "sw_err", "Neustart bei Fehler, Verbindungsabbruch oder Hänger",
    "sw_err_sub", "Abbruch im Log, Kick, fehlgeschlagener Teleport oder Fenster reagiert nicht",
    "lbl_tol", "Toleranz (Sekunden)",
    "sec_pos", "POSITION",
    "sw_place", "Oben rechts platzieren",
    "sw_place_sub", "Hält das Roblox-Fenster fest und vollständig sichtbar",
    "lbl_width", "Breite",
    "lbl_height", "Höhe",
    "btn_place_now", "Jetzt platzieren",
    "sec_browser", "BROWSER",
    "sw_tab", "Browser-Tab nach dem Beitreten schließen",
    "sw_tab_sub", "Schließt den Tab mit 'Roblox' im Titel und minimiert den Browser",
    "btn_test", "Testen",
    "hint_hook", "Automatische Meldungen: Abbruch, Neustartversuch, wieder online und Fehler (mit Uhrzeit).",
    "sec_status", "REGELMÄSSIGER STATUS",
    "sw_rep", "Status mit Screenshot senden",
    "sw_rep_sub", "Embed mit Kontostatus + Screenshot nur vom Roblox-Fenster",
    "lbl_interval", "Intervall (Minuten)",
    "btn_send_now", "Jetzt senden",
    "sec_ocr", "BILDSCHIRM LESEN (OCR)",
    "sw_ocr", "Währungen im Status-Embed senden",
    "sw_ocr_sub", "Liest die im Roblox-Fenster angezeigten Werte",
    "lbl_coins", "Währungen (mit | trennen). Emoji optional: Gems=<:gems:123456>",
    "sec_lastread", "LETZTE LESUNG",
    "btn_testread", "Lesen testen",
    "no_read", "Noch keine Lesung.",
    "not_found", "nicht gefunden",
    "nothing_read", "Nichts gelesen.",
    "ocr_open", "Öffne Roblox (nicht minimiert) mit sichtbaren Währungen.",
    "ocr_names", "Gib oben die Namen der Währungen ein.",
    "log_ocr_tested", "Währungslesung getestet ({1}/{2} gefunden).",
    "ocr_err", "OCR-Fehler: {1}",
    "log_ocr_saw", "Vom OCR erkannter Text:",
    "log_coin_err", "Fehler beim Lesen der Währungen: {1}",
    "sec_version", "INSTALLIERTE VERSION",
    "upd_never", "Noch nicht geprüft.",
    "btn_checkupd", "Nach Updates suchen",
    "sec_license", "LIZENZ",
    "btn_changekey", "Key ändern",
    "paste_new_key", "Füge den neuen Key ein.",
    "sw_autoupd", "Automatisch aktualisieren",
    "sec_news", "NEUIGKEITEN",
    "news_ph", "Neuigkeiten erscheinen hier nach der Prüfung.",
    "btn_clear", "Leeren",
    "upd_not_cfg", "Updates nicht eingerichtet.",
    "upd_searching", "Suche nach Updates...",
    "upd_noconn", "Konnte gerade nicht prüfen.",
    "upd_badfile", "Die heruntergeladene Datei scheint nicht das Skript zu sein.",
    "upd_latest", "Du hast die neueste Version.",
    "upd_avail", "Neue Version v{1} verfügbar! Neuigkeiten siehe unten.",
    "btn_upd_to", "Auf v{1} aktualisieren",
    "badge_new", "Neue Version v{1}",
    "log_upd_avail", "Update verfügbar: v{1}.",
    "log_upd_dlfail", "Update-Download fehlgeschlagen: {1}",
    "log_upd_fail", "Aktualisierung fehlgeschlagen: {1}",
    "log_updated", "Auf v{1} aktualisiert! Neustart...",
    "lang_menu", "Sprache",
    "lang_auto", "Automatisch (System)",
    "mini_sub", "Neustarts {1} · Abbrüche {2}",
    "key_title", "Lizenz aktivieren",
    "key_sub", "Füge deinen Key ein, um Auto Reconnect Roblox freizuschalten.",
    "btn_activate", "Aktivieren",
    "your_hwid", "DEINE HWID",
    "btn_copy", "Kopieren",
    "hwid_copied", "HWID kopiert.",
    "btn_buy", "Key kaufen",
    "checking_lic", "Lizenz wird geprüft...",
    "ka_app_nf", "Anwendung bei KeyAuth nicht gefunden (Name/Owner ID prüfen).",
    "ka_badver", "KeyAuth-Version passt nicht (KEYAUTH_VER wie im Panel setzen).",
    "key_nf", "Key existiert nicht.",
    "key_invalid", "Ungültiger Key.",
    "key_hwid", "Dieser Key ist bereits auf einem anderen PC aktiviert (andere HWID).",
    "key_expired", "Dein Key ist abgelaufen.",
    "hwid_banned", "Dieser PC wurde gesperrt.",
    "key_banned", "Dieser Key wurde gesperrt.",
    "session_exp", "Sitzung abgelaufen, versuche es erneut.",
    "key_fail", "Key konnte nicht geprüft werden.",
    "paste_key_first", "Füge zuerst deinen Key ein.",
    "checking", "Prüfe...",
    "connecting", "Verbinde mit dem Lizenzserver...",
    "no_conn", "Lizenzserver nicht erreichbar. Prüfe deine Internetverbindung.",
    "lic_lifetime", "Lebenslang",
    "side_lifetime", "LEBENSLANGE LIZENZ",
    "lic_expires", "Läuft ab am {1}  ({2} Tage)",
    "side_days", "LIZENZ: {1} TAGE",
    "lic_active", "Aktiv",
    "side_active", "LIZENZ AKTIV",
    "lic_offline", "Lizenz seit über 2 Std. nicht prüfbar.",
    "log_lic_bad", "Ungültige Lizenz: {1}",
    "activate_to_use", "Aktiviere deinen Key, um es zu nutzen.",
    "hook_need_url", "Gib zuerst die Webhook-URL ein.",
    "hook_sent", "Webhook gesendet (HTTP {1}).",
    "hook_fail", "Webhook fehlgeschlagen: {1}",
    "log_status_sent", "Status gesendet (HTTP {1}).",
    "log_status_fail", "Status konnte nicht gesendet werden: {1}",
    "why_closed", "Roblox geschlossen",
    "why_min", "Fenster minimiert",
    "why_fail", "Aufnahme fehlgeschlagen",
    "emb_offline", "Offline",
    "emb_warn", "Online · Abbruch im Log",
    "emb_online", "Online im Spiel",
    "up_stopped", "gestoppt",
    "none", "Keiner",
    "next_status", "nächster Status in {1} Min.",
    "no_shot", "kein Screenshot ({1})",
    "f_uptime", "Laufzeit",
    "f_reopens", "Neustarts",
    "f_drops", "Abbrüche",
    "f_lastdrop", "Letzter Abbruch",
    "m_exe", "direkt über Roblox",
    "m_uri", "roblox://-Link",
    "m_web", "Browser",
    "roblox_not_reg", "Roblox nicht in der Registry gefunden",
    "paste_link_first", "Füge zuerst den Spiel-Link ein.",
    "log_all_failed", "Keine Startmethode hat funktioniert. Neuer Versuch bei der nächsten Prüfung.",
    "log_method_failed", "Methode {1}/{2} ({3}) fehlgeschlagen: {4}",
    "log_opening", "Öffne ({1})",
    "log_reopening", "Starte neu ({1})",
    "log_opened", "Roblox geöffnet ({1}s). Trete dem Spiel bei...",
    "st_joining", "Trete dem Spiel bei...",
    "st_joining_sub", "Roblox offen, Server wird geladen",
    "log_joined", "Spiel beigetreten ({1}s).",
    "log_not_open25", "Roblox hat sich in 25 s nicht geöffnet, versuche andere Methode...",
    "log_not_join60", "Roblox offen, aber in 60 s nicht beigetreten, versuche andere Methode...",
    "log_not_open", "Roblox ist nicht geöffnet.",
    "log_placed", "Roblox-Fenster platziert.",
    "log_detected", "Roblox-Fenster erkannt.",
    "log_placed_right", "Roblox-Fenster in die rechte Ecke verschoben.",
    "log_tab_closed", "Roblox-Tab im Browser geschlossen.",
    "log_tab_nf", "Roblox-Tab nicht gefunden. Offene Titel:",
    "none_lc", "keine",
    "log_disc_log", "Abbruch im Log. Warte auf Wiederbeitritt...",
    "log_err_restart", "Fehler erkannt: {1}. Roblox wird neu gestartet...",
    "log_disc_screen", "Disconnected-Bildschirm im Fenster.",
    "log_disc_screen_c", "Disconnected-Bildschirm im Fenster (Code {1}).",
    "r_disc_screen", "Disconnected-Bildschirm",
    "r_disc_screen_c", "Disconnected-Bildschirm - Code {1}",
    "log_rejoined", "Wieder beigetreten / normaler Teleport, ok.",
    "r_no_rejoin", "Abbruch/Fehler ohne Wiederbeitritt",
    "r_hung", "Fenster hängt (reagiert nicht)",
    "log_back", "Roblox ist zurück (weg für {1}).",
    "log_down", "Roblox geschlossen/getrennt.",
    "st_loading", "Lädt...",
    "st_loading_sub", "Warte, bis das Spiel öffnet und dem Server beitritt",
    "st_on_warn_sub", "Abbruch im Log, warte auf Wiederbeitritt",
    "st_on_sub", "Im Spiel · überwache",
    "st_off_sub", "Geschlossen, starte jetzt neu",
    "st_nolink", "Kein Link",
    "st_nolink_sub", "Füge den Link im Tab Spiel ein",
    "st_monitoring", "Überwache...",
    "st_monitoring_sub", "Prüfe Roblox",
    "log_mon_start", "Überwachung gestartet (alle {1}s).",
    "log_mon_stop", "Überwachung gestoppt.",
    "ev_start", "Überwachung gestartet",
    "ev_reopen", "Roblox wird neu gestartet",
    "ev_fail", "Roblox konnte nicht geöffnet werden",
    "ev_error", "Fehler erkannt",
    "ev_back", "Roblox ist zurück",
    "ev_down", "Roblox geschlossen/getrennt",
    "ev_lic", "Ungültige Lizenz",
    "ev_updated", "Auf v{1} aktualisiert",
    "ev_test", "Webhook funktioniert!",
    "d_time", "Uhrzeit",
    "d_away", "Weg für",
    "d_reason", "Grund",
    "d_restart", "Roblox wird neu gestartet...",
    "d_stopped", "Überwachung gestoppt.",
    "d_retry", "Neuer Versuch bei der nächsten Prüfung.",
    "d_test", "Benachrichtigungen kommen hier an.",
    "d_method", "Methode",
    "d_interval", "Prüfung alle",
    "d_user", "Benutzer",
    "tour_welcome_t", "Willkommen, {1}!",
    "tour_welcome", "Ich zeige dir die Grundlagen in unter einer Minute. Du kannst jederzeit überspringen.",
    "tour_link_t", "1. Spiel-Link",
    "tour_link", "Füge hier den Spiel-Link, den Link zum privaten Server oder nur die Place-ID ein. Dorthin bringt dich das Skript zurück.",
    "tour_hook_t", "2. Discord-Benachrichtigungen",
    "tour_hook", "Optional: Füge den Webhook eines Discord-Kanals ein, um bei Abbruch, Rückkehr oder Fehlern benachrichtigt zu werden.",
    "tour_test_t", "Webhook testen",
    "tour_test", "Klicke hier, um zu prüfen, ob die Meldungen in Discord ankommen.",
    "tour_win_t", "3. Fensterposition",
    "tour_win", "Wenn aktiv, bleibt das Roblox-Fenster oben rechts auf dem Bildschirm.",
    "tour_coins_t", "4. Währungen (optional)",
    "tour_coins", "Gib die Namen der angezeigten Währungen ein, damit sie im Discord-Status erscheinen.",
    "tour_start_t", "5. Los geht's!",
    "tour_start", "Wenn alles passt, klicke auf Starten. Das Skript überwacht Roblox und startet es bei Abbruch neu.",
    "tour_compact_t", "Kompaktmodus",
    "tour_compact", "Verkleinert alles auf eine kleine Leiste, die weniger Platz braucht.",
    "tour_lang_t", "Sprache",
    "tour_lang", "Ändere hier die Sprache. Standardmäßig wird die Windows-Sprache verwendet.",
    "tour_upd_t", "Updates",
    "tour_upd", "Bei einer neuen Version erscheint oben ein Hinweis und du aktualisierst hier mit einem Klick.",
    "tour_done_t", "Alles bereit!",
    "tour_done", "Du kannst das Tutorial jederzeit unter Info → Tutorial ansehen erneut starten.",
    "btn_next", "Weiter",
    "btn_back", "Zurück",
    "btn_skip", "Überspringen",
    "btn_finish", "Fertig",
    "btn_tour", "Tutorial ansehen",
    "tour_step", "{1} von {2}",
    "nav_opts", "Optionen",
    "nav_accounts", "Konten",
    "pg_opts_sub", "Autostart, Benachrichtigungen und Tageszusammenfassung",
    "pg_acc_sub", "Mehrere Konten gleichzeitig (experimentell)",
    "sec_startup", "AUTOSTART",
    "sw_startwin", "Mit Windows starten",
    "sw_startwin_sub", "Öffnet das Skript beim Hochfahren",
    "sw_automon", "Überwachung beim Öffnen automatisch starten",
    "sw_automon_sub", "Klickt beim Öffnen für dich auf Starten",
    "sec_notify", "BENACHRICHTIGUNGEN",
    "sw_toast", "Windows-Benachrichtigung",
    "sw_toast_sub", "Hinweis in der Ecke bei Abbruch, Rückkehr oder Fehler",
    "sw_tray", "In den Infobereich minimieren",
    "sw_tray_sub", "Beim Minimieren bleibt nur das Symbol neben der Uhr",
    "sec_daily", "TAGESZUSAMMENFASSUNG",
    "sw_daily", "Tageszusammenfassung an Discord senden",
    "lbl_daily_time", "Uhrzeit (HH:MM)",
    "sec_mention", "DICH ERWÄHNEN",
    "sw_mention", "Mich bei Abbruch oder Fehler erwähnen",
    "sw_mention_sub", "Erwähnt nur dich, nie @everyone",
    "lbl_discord_id", "Deine Discord-ID",
    "btn_how", "Wo finde ich sie?",
    "hint_discord_id", "Discord > Einstellungen > Erweitert > Entwicklermodus aktivieren. Dann Rechtsklick auf deinen Namen > Benutzer-ID kopieren.",
    "sw_multi", "Mehrere Konten verwenden",
    "sw_multi_sub", "Schließe Roblox vor dem Start. Alle nutzen den Link aus dem Tab Spiel.",
    "col_account", "Konto",
    "col_status", "Status",
    "btn_add_acc", "Konto hinzufügen",
    "btn_rem_acc", "Entfernen",
    "btn_tile", "Fenster anordnen",
    "acc_cookie", ".ROBLOSECURITY-Cookie des Kontos",
    "acc_cookie_hint", "Im eingeloggten Browser: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Wird verschlüsselt auf diesem PC gespeichert. Niemals teilen.",
    "btn_save", "Speichern",
    "btn_cancel", "Abbrechen",
    "acc_checking", "Konto wird geprüft...",
    "acc_invalid", "Ungültiges oder abgelaufenes Cookie.",
    "acc_added", "Konto {1} hinzugefügt.",
    "acc_st_off", "Geschlossen",
    "acc_st_opening", "Öffnet...",
    "acc_st_on", "Im Spiel",
    "acc_st_down", "Abgebrochen, starte neu",
    "acc_st_err", "Fehler: {1}",
    "multi_close", "Schließe alle Roblox-Fenster, bevor du den Mehrkontenmodus startest.",
    "acc_need", "Füge im Tab Konten mindestens ein Konto hinzu.",
    "log_acc_launch", "[{1}] öffnet...",
    "log_acc_down", "[{1}] abgebrochen.",
    "log_acc_dlg", "[{1}] Disconnected-Bildschirm, Neustart.",
    "log_acc_fail", "[{1}] konnte nicht öffnen: {2}",
    "d_account", "Konto",
    "tray_open", "Öffnen",
    "tray_toggle", "Starten / Stoppen",
    "tray_exit", "Beenden",
    "ev_daily", "Tageszusammenfassung",
    "f_online_today", "Heute online",
    "f_drops_today", "Abbrüche heute",
    "f_reopens_today", "Neustarts heute",
    "d_earned", "Heute verdient",
    "nav_auto", "Automatisierung",
    "nav_bot", "Bot",
    "nav_hist", "Verlauf",
    "pg_auto_sub", "Zeitplan und Sparmodus",
    "pg_bot_sub", "Steuere das Skript über Discord",
    "pg_hist_sub", "Deine letzten 14 Tage",
    "sec_sched", "ZEITPLAN",
    "sw_sched", "Nur zu bestimmten Zeiten überwachen",
    "sw_sched_sub", "Pausiert außerhalb der Zeit und läuft dann von selbst weiter",
    "lbl_from", "Von",
    "lbl_to", "bis",
    "lbl_maxh", "Stoppen nach (Stunden, 0 = nie)",
    "lbl_onend", "Danach",
    "act_none", "Nichts tun",
    "act_close", "Roblox schließen",
    "act_shutdown", "PC herunterfahren",
    "sec_eco", "SPARMODUS",
    "sw_eco", "Sparmodus aktivieren",
    "sw_eco_sub", "Gilt beim nächsten Start von Roblox",
    "lbl_fps", "FPS-Limit",
    "fps_none", "Kein Limit",
    "sw_lowgfx", "Niedrigste Grafik",
    "sw_mute", "Ton aus",
    "sw_lowprio", "Niedrige Priorität für Roblox",
    "sec_bot", "DISCORD-BOT",
    "sw_bot", "Über Discord steuern",
    "sw_bot_sub", "Gehorcht nur deiner ID (Tab Webhook)",
    "lbl_token", "Bot-Token",
    "lbl_channel", "Kanal-ID",
    "bot_off", "Aus",
    "bot_ok", "Verbunden, wartet auf Befehle",
    "bot_err", "Fehler: {1}",
    "bot_need_id", "Gib deine Discord-ID im Tab Webhook ein.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. 'Message Content Intent' aktivieren, Bot auf den Server einladen und Kanal-ID kopieren (Rechtsklick auf den Kanal).",
    "sec_cmds", "BEFEHLE",
    "cmd_status", "zeigt den Status mit Screenshot",
    "cmd_start", "startet die Überwachung",
    "cmd_stop", "stoppt die Überwachung",
    "cmd_restart", "schließt und öffnet Roblox neu",
    "cmd_summary", "sendet die Tageszusammenfassung",
    "cmd_help", "listet die Befehle",
    "log_bot_cmd", "Discord-Befehl: {1}",
    "hist_online", "Online-Zeit",
    "hist_coin", "Währung: {1}",
    "hist_empty", "Noch keine Daten. Der Verlauf füllt sich mit der Zeit.",
    "acc_edit", "Konto bearbeiten",
    "acc_link", "Link für dieses Konto (optional)",
    "acc_ck_keep", "Leer lassen, um das aktuelle Cookie zu behalten.",
    "col_link", "Link",
    "link_default", "Standard",
    "acc_dbl_hint", "Doppelklicke auf ein Konto, um den Link zu ändern.",
    "log_sched_pause", "Außerhalb der Zeit, Überwachung pausiert.",
    "log_sched_resume", "Innerhalb der Zeit, Überwachung fortgesetzt.",
    "log_maxh", "Maximale Zeit erreicht, stoppe.",
    "ev_sched", "Überwachung beendet",
    "d_shutdown", "Der PC fährt in 60 Sekunden herunter.",
    "ev_stop", "Überwachung gestoppt",
    "ev_restart", "Roblox wird neu gestartet",
    "ev_already", "Überwachung läuft bereits",
    "ev_notrunning", "Überwachung ist bereits gestoppt",
    "ev_unknown", "Unbekannter Befehl",
    "d_unknown", "Nutze !help, um die Befehle zu sehen.",
    "d_restart_how", "Wird geschlossen und direkt über Roblox neu geöffnet.",
    "d_running_for", "Läuft seit",
    "d_cmd", "Befehl",
    "cmd_print", "sendet nur einen Roblox-Screenshot",
    "cmd_coins", "zeigt deine Währungen jetzt",
    "cmd_pc", "CPU- und RAM-Auslastung des PCs",
    "cmd_accounts", "Status jedes Kontos",
    "cmd_hist", "Diagramm der letzten 7 Tage",
    "cmd_logs", "letzte Protokollzeilen",
    "cmd_ping", "prüft, ob der Bot antwortet",
    "cmd_link", "ändert den Spiel-Link",
    "cmd_update", "sucht und installiert Updates",
    "cmd_shutdown", "fährt den PC herunter (!shutdown confirm)",
    "cmd_cancel", "bricht das Herunterfahren ab",
    "grp_control", "Steuerung",
    "grp_info", "Infos",
    "grp_config", "Einstellungen",
    "f_session", "Sitzung",
    "f_link", "Link",
    "f_version", "Version",
    "f_cpu", "CPU",
    "f_ram", "Arbeitsspeicher",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC an seit",
    "f_script_up", "Skript offen seit",
    "f_latency", "Latenz",
    "f_windows", "Roblox-Fenster",
    "ev_pong", "Pong!",
    "ev_pc", "PC-Zustand",
    "ev_coins", "Deine Währungen",
    "ev_accounts", "Konten",
    "ev_hist", "Letzte 7 Tage",
    "ev_logs", "Letzte Logs",
    "ev_link", "Link geändert",
    "d_link_next", "Gilt beim nächsten Start. Sende !restart, um es sofort anzuwenden.",
    "ev_linkbad", "Ungültiger Link",
    "d_link_usage", "Nutze: !link <Spiel-Link, Server-Link oder Place-ID>",
    "ev_updnone", "Bereits auf der neuesten Version",
    "ev_updating", "Aktualisiere auf v{1}",
    "ev_shutdown", "PC wird heruntergefahren",
    "ev_shutconf", "Herunterfahren bestätigen",
    "d_shutconf", "Sende !shutdown confirm, um in 60 Sekunden herunterzufahren.",
    "ev_cancel", "Herunterfahren abgebrochen",
    "d_back_in", "Nach {1}s wieder im Spiel",
    "ev_print", "Roblox-Screenshot",
    "no_accounts", "Keine Konten hinzugefügt.",
    "no_coins", "Konnte die Währungen nicht lesen (Panel sichtbar lassen).",
    "sec_panel", "LIVE-PANEL",
    "sw_panel", "Festes Panel im Kanal",
    "sw_panel_sub", "Eine einzige Nachricht mit Status und Screenshot, die sich selbst aktualisiert",
    "lbl_panel_min", "Aktualisieren alle (Min.)",
    "ev_panel", "Live-Panel",
    "d_updated", "Aktualisiert",
    "bot_hint_help", "Sende !help im Kanal, um alle Befehle zu sehen.",
    "sec_stuck", "FARM HÄNGT",
    "sw_stuck", "Warnen, wenn die Währungen nicht mehr steigen",
    "sw_stuck_sub", "Liest die Währungen jede Minute, um zu sehen, ob der Farm läuft",
    "lbl_stuck_min", "Zeit ohne Änderung (Min.)",
    "stuck_alert", "Nur warnen",
    "stuck_restart", "Warnen und neu starten",
    "ev_stuck", "Farm steht still",
    "d_stuck", "Die Währungen haben sich seit {1} Min. nicht verändert.",
    "r_stuck", "Farm steht (Währungen unverändert)",
    "log_stuck", "Farm steht seit {1} Min.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Darstellung",
    "pg_look_sub", "Wähle das Design",
    "sec_theme", "DESIGN"
)
I18N["ru"] := Map(
    "nav_home", "Главная",
    "nav_game", "Игра",
    "nav_window", "Окно",
    "nav_hook", "Вебхук",
    "nav_coins", "Валюта",
    "nav_logs", "Журнал",
    "nav_about", "О программе",
    "pg_home_sub", "Привет, {1}! Обзор мониторинга",
    "pg_game_sub", "Сервер, интервал проверки и восстановление после ошибок",
    "pg_win_sub", "Положение окна Roblox и вкладка браузера",
    "pg_hook_sub", "Уведомления и статус в Discord",
    "pg_coins_sub", "Считывает валюту с экрана Roblox и отправляет в вебхук",
    "pg_about_sub", "Лицензия, версия и новое",
    "pg_logs_sub", "История этой сессии",
    "idle", "Остановлено",
    "click_start", "Нажмите «Старт», чтобы начать",
    "btn_start", "Старт",
    "btn_stop", "Стоп",
    "st_uptime", "ВРЕМЯ РАБОТЫ",
    "st_reopens", "ПЕРЕЗАПУСКИ",
    "st_drops", "ВЫЛЕТЫ",
    "st_lastdrop", "ПОСЛЕДНИЙ ВЫЛЕТ",
    "quick", "БЫСТРЫЕ ДЕЙСТВИЯ",
    "btn_open_now", "Открыть игру",
    "btn_place", "Разместить окно",
    "btn_compact", "Компактный режим",
    "sec_server", "СЕРВЕР",
    "hint_link", "Ссылка на игру, на приватный сервер или просто Place ID.",
    "sec_monitor", "МОНИТОРИНГ",
    "lbl_check", "Проверять каждые (сек)",
    "lbl_wait", "Ждать после запуска (сек)",
    "sec_recovery", "ВОССТАНОВЛЕНИЕ",
    "sw_err", "Перезапуск при ошибке, отключении или зависании",
    "sw_err_sub", "Отключение в логе, кик, неудачный телепорт или зависшее окно",
    "lbl_tol", "Допуск (сек)",
    "sec_pos", "ПОЛОЖЕНИЕ",
    "sw_place", "Разместить в правом верхнем углу",
    "sw_place_sub", "Окно Roblox остаётся на месте и полностью видно",
    "lbl_width", "Ширина",
    "lbl_height", "Высота",
    "btn_place_now", "Разместить",
    "sec_browser", "БРАУЗЕР",
    "sw_tab", "Закрывать вкладку браузера после входа",
    "sw_tab_sub", "Закрывает вкладку с 'Roblox' в заголовке и сворачивает браузер",
    "btn_test", "Тест",
    "hint_hook", "Автоуведомления: вылет, попытка перезапуска, возвращение и ошибки (со временем).",
    "sec_status", "ПЕРИОДИЧЕСКИЙ СТАТУС",
    "sw_rep", "Отправлять статус со скриншотом",
    "sw_rep_sub", "Embed со статусом аккаунта + скриншот только окна Roblox",
    "lbl_interval", "Интервал (мин)",
    "btn_send_now", "Отправить",
    "sec_ocr", "ЧТЕНИЕ ЭКРАНА (OCR)",
    "sw_ocr", "Отправлять валюту в статусе",
    "sw_ocr_sub", "Считывает значения, видимые в окне Roblox",
    "lbl_coins", "Валюты (через | ). Эмодзи по желанию: Gems=<:gems:123456>",
    "sec_lastread", "ПОСЛЕДНЕЕ ЧТЕНИЕ",
    "btn_testread", "Проверить",
    "no_read", "Пока нет данных.",
    "not_found", "не найдено",
    "nothing_read", "Ничего не считано.",
    "ocr_open", "Откройте Roblox (не свёрнутым), чтобы валюта была видна.",
    "ocr_names", "Введите названия валют выше.",
    "log_ocr_tested", "Чтение валюты проверено (найдено {1}/{2}).",
    "ocr_err", "Ошибка OCR: {1}",
    "log_ocr_saw", "Текст, который увидел OCR:",
    "log_coin_err", "Ошибка чтения валюты: {1}",
    "sec_version", "УСТАНОВЛЕННАЯ ВЕРСИЯ",
    "upd_never", "Ещё не проверено.",
    "btn_checkupd", "Проверить обновления",
    "sec_license", "ЛИЦЕНЗИЯ",
    "btn_changekey", "Сменить ключ",
    "paste_new_key", "Вставьте новый ключ.",
    "sw_autoupd", "Обновлять автоматически",
    "sec_news", "ЧТО НОВОГО",
    "news_ph", "Новое появится здесь после проверки.",
    "btn_clear", "Очистить",
    "upd_not_cfg", "Обновления не настроены.",
    "upd_searching", "Поиск обновлений...",
    "upd_noconn", "Не удалось проверить.",
    "upd_badfile", "Скачанный файл не похож на скрипт.",
    "upd_latest", "У вас последняя версия.",
    "upd_avail", "Доступна новая версия v{1}! Что нового — ниже.",
    "btn_upd_to", "Обновить до v{1}",
    "badge_new", "Новая версия v{1}",
    "log_upd_avail", "Доступно обновление: v{1}.",
    "log_upd_dlfail", "Не удалось скачать обновление: {1}",
    "log_upd_fail", "Ошибка обновления: {1}",
    "log_updated", "Обновлено до v{1}! Перезапуск...",
    "lang_menu", "Язык",
    "lang_auto", "Автоматически (система)",
    "mini_sub", "перезап. {1} · вылеты {2}",
    "key_title", "Активация лицензии",
    "key_sub", "Вставьте ключ, чтобы открыть Auto Reconnect Roblox.",
    "btn_activate", "Активировать",
    "your_hwid", "ВАШ HWID",
    "btn_copy", "Копировать",
    "hwid_copied", "HWID скопирован.",
    "btn_buy", "Купить ключ",
    "checking_lic", "Проверка лицензии...",
    "ka_app_nf", "Приложение не найдено в KeyAuth (проверьте имя/Owner ID).",
    "ka_badver", "Версия KeyAuth не совпадает (KEYAUTH_VER как в панели).",
    "key_nf", "Ключ не существует.",
    "key_invalid", "Неверный ключ.",
    "key_hwid", "Ключ уже активирован на другом ПК (другой HWID).",
    "key_expired", "Срок действия ключа истёк.",
    "hwid_banned", "Этот ПК заблокирован.",
    "key_banned", "Этот ключ заблокирован.",
    "session_exp", "Сессия истекла, попробуйте снова.",
    "key_fail", "Не удалось проверить ключ.",
    "paste_key_first", "Сначала вставьте ключ.",
    "checking", "Проверка...",
    "connecting", "Подключение к серверу лицензий...",
    "no_conn", "Нет связи с сервером лицензий. Проверьте интернет.",
    "lic_lifetime", "Бессрочная",
    "side_lifetime", "БЕССРОЧНАЯ ЛИЦЕНЗИЯ",
    "lic_expires", "Истекает {1}  ({2} дн.)",
    "side_days", "ЛИЦЕНЗИЯ: {1} ДН.",
    "lic_active", "Активна",
    "side_active", "ЛИЦЕНЗИЯ АКТИВНА",
    "lic_offline", "Не удаётся проверить лицензию более 2 ч.",
    "log_lic_bad", "Лицензия недействительна: {1}",
    "activate_to_use", "Активируйте ключ, чтобы пользоваться.",
    "hook_need_url", "Сначала укажите URL вебхука.",
    "hook_sent", "Вебхук отправлен (HTTP {1}).",
    "hook_fail", "Ошибка вебхука: {1}",
    "log_status_sent", "Статус отправлен (HTTP {1}).",
    "log_status_fail", "Не удалось отправить статус: {1}",
    "why_closed", "Roblox закрыт",
    "why_min", "окно свёрнуто",
    "why_fail", "не удалось сделать снимок",
    "emb_offline", "Не в сети",
    "emb_warn", "В сети · отключение в логе",
    "emb_online", "В игре",
    "up_stopped", "остановлен",
    "none", "Нет",
    "next_status", "следующий статус через {1} мин",
    "no_shot", "без скриншота ({1})",
    "f_uptime", "Время работы",
    "f_reopens", "Перезапуски",
    "f_drops", "Вылеты",
    "f_lastdrop", "Последний вылет",
    "m_exe", "напрямую через Roblox",
    "m_uri", "ссылка roblox://",
    "m_web", "браузер",
    "roblox_not_reg", "Roblox не найден в реестре",
    "paste_link_first", "Сначала вставьте ссылку на игру.",
    "log_all_failed", "Ни один способ не сработал. Повтор при следующей проверке.",
    "log_method_failed", "Способ {1}/{2} ({3}) не сработал: {4}",
    "log_opening", "Запуск ({1})",
    "log_reopening", "Перезапуск ({1})",
    "log_opened", "Roblox запущен ({1}с). Вход в игру...",
    "st_joining", "Вход в игру...",
    "st_joining_sub", "Roblox открыт, загрузка сервера",
    "log_joined", "Вошёл в игру ({1}с).",
    "log_not_open25", "Roblox не открылся за 25 с, пробую другой способ...",
    "log_not_join60", "Roblox открыт, но не вошёл в игру за 60 с, пробую другой способ...",
    "log_not_open", "Roblox не запущен.",
    "log_placed", "Окно Roblox размещено.",
    "log_detected", "Окно Roblox обнаружено.",
    "log_placed_right", "Окно Roblox перемещено в правый угол.",
    "log_tab_closed", "Вкладка Roblox закрыта в браузере.",
    "log_tab_nf", "Вкладка Roblox не найдена. Открытые заголовки:",
    "none_lc", "нет",
    "log_disc_log", "Отключение в логе. Жду повторного входа...",
    "log_err_restart", "Обнаружена ошибка: {1}. Перезапуск Roblox...",
    "log_disc_screen", "Экран Disconnected в окне.",
    "log_disc_screen_c", "Экран Disconnected в окне (код {1}).",
    "r_disc_screen", "экран Disconnected",
    "r_disc_screen_c", "экран Disconnected - код {1}",
    "log_rejoined", "Повторный вход / обычный телепорт, ок.",
    "r_no_rejoin", "отключение/ошибка без повторного входа",
    "r_hung", "окно зависло (не отвечает)",
    "log_back", "Roblox вернулся (не было {1}).",
    "log_down", "Roblox закрылся/отключился.",
    "st_loading", "Загрузка...",
    "st_loading_sub", "Ждём запуска игры и входа на сервер",
    "st_on_warn_sub", "Отключение в логе, жду повторного входа",
    "st_on_sub", "В игре · мониторинг",
    "st_off_sub", "Закрыт, перезапускаю",
    "st_nolink", "Нет ссылки",
    "st_nolink_sub", "Вставьте ссылку во вкладке «Игра»",
    "st_monitoring", "Мониторинг...",
    "st_monitoring_sub", "Проверка Roblox",
    "log_mon_start", "Мониторинг запущен (каждые {1}с).",
    "log_mon_stop", "Мониторинг остановлен.",
    "ev_start", "Мониторинг запущен",
    "ev_reopen", "Перезапуск Roblox",
    "ev_fail", "Не удалось открыть Roblox",
    "ev_error", "Обнаружена ошибка",
    "ev_back", "Roblox вернулся",
    "ev_down", "Roblox закрылся/отключился",
    "ev_lic", "Лицензия недействительна",
    "ev_updated", "Обновлено до v{1}",
    "ev_test", "Вебхук работает!",
    "d_time", "Время",
    "d_away", "Не было",
    "d_reason", "Причина",
    "d_restart", "Перезапуск Roblox...",
    "d_stopped", "Мониторинг остановлен.",
    "d_retry", "Попробую снова при следующей проверке.",
    "d_test", "Уведомления будут приходить сюда.",
    "d_method", "Способ",
    "d_interval", "Проверка каждые",
    "d_user", "Пользователь",
    "tour_welcome_t", "Добро пожаловать, {1}!",
    "tour_welcome", "Покажу основное меньше чем за минуту. Можно пропустить в любой момент.",
    "tour_link_t", "1. Ссылка на игру",
    "tour_link", "Вставьте сюда ссылку на игру, на приватный сервер или просто Place ID. Туда скрипт будет возвращать вас.",
    "tour_hook_t", "2. Уведомления в Discord",
    "tour_hook", "Необязательно: вставьте вебхук канала Discord, чтобы получать уведомления о вылетах, возвращении и ошибках.",
    "tour_test_t", "Проверка вебхука",
    "tour_test", "Нажмите здесь, чтобы проверить, что уведомления приходят в Discord.",
    "tour_win_t", "3. Положение окна",
    "tour_win", "Если включено, окно Roblox закреплено в правом верхнем углу экрана.",
    "tour_coins_t", "4. Валюта (необязательно)",
    "tour_coins", "Введите названия валют с экрана, чтобы они попадали в статус в Discord.",
    "tour_start_t", "5. Старт!",
    "tour_start", "Когда всё готово, нажмите «Старт». Скрипт следит за Roblox и перезапускает его при вылете.",
    "tour_compact_t", "Компактный режим",
    "tour_compact", "Сворачивает всё в маленькую панель, чтобы занимать меньше места.",
    "tour_lang_t", "Язык",
    "tour_lang", "Смените язык здесь. По умолчанию используется язык Windows.",
    "tour_upd_t", "Обновления",
    "tour_upd", "Когда выходит новая версия, сверху появляется уведомление, а обновиться можно здесь в один клик.",
    "tour_done_t", "Всё готово!",
    "tour_done", "Пройти обучение снова можно в разделе «О программе» → «Обучение».",
    "btn_next", "Далее",
    "btn_back", "Назад",
    "btn_skip", "Пропустить",
    "btn_finish", "Готово",
    "btn_tour", "Обучение",
    "tour_step", "{1} из {2}",
    "nav_opts", "Настройки",
    "nav_accounts", "Аккаунты",
    "pg_opts_sub", "Автозапуск, уведомления и сводка за день",
    "pg_acc_sub", "Несколько аккаунтов одновременно (экспериментально)",
    "sec_startup", "АВТОЗАПУСК",
    "sw_startwin", "Запускать вместе с Windows",
    "sw_startwin_sub", "Открывает скрипт при включении ПК",
    "sw_automon", "Сразу начинать мониторинг при запуске",
    "sw_automon_sub", "Нажимает «Старт» за вас при запуске",
    "sec_notify", "УВЕДОМЛЕНИЯ",
    "sw_toast", "Уведомление Windows",
    "sw_toast_sub", "Всплывающее окно при вылете, возвращении или ошибке",
    "sw_tray", "Сворачивать в трей",
    "sw_tray_sub", "При сворачивании остаётся только значок у часов",
    "sec_daily", "СВОДКА ЗА ДЕНЬ",
    "sw_daily", "Отправлять сводку за день в Discord",
    "lbl_daily_time", "Время (ЧЧ:ММ)",
    "sec_mention", "УПОМИНАНИЕ",
    "sw_mention", "Упоминать меня при вылете или ошибке",
    "sw_mention_sub", "Упоминает только вас, никогда @everyone",
    "lbl_discord_id", "Ваш ID в Discord",
    "btn_how", "Где найти?",
    "hint_discord_id", "Discord > Настройки > Расширенные > включите Режим разработчика. Затем ПКМ по своему имени > Копировать ID.",
    "sw_multi", "Использовать несколько аккаунтов",
    "sw_multi_sub", "Закройте Roblox перед стартом. Все используют ссылку из вкладки «Игра».",
    "col_account", "Аккаунт",
    "col_status", "Статус",
    "btn_add_acc", "Добавить аккаунт",
    "btn_rem_acc", "Удалить",
    "btn_tile", "Упорядочить окна",
    "acc_cookie", "Cookie .ROBLOSECURITY аккаунта",
    "acc_cookie_hint", "В браузере с входом в аккаунт: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Хранится зашифрованным на этом ПК. Никому не передавайте.",
    "btn_save", "Сохранить",
    "btn_cancel", "Отмена",
    "acc_checking", "Проверка аккаунта...",
    "acc_invalid", "Неверный или устаревший cookie.",
    "acc_added", "Аккаунт {1} добавлен.",
    "acc_st_off", "Закрыт",
    "acc_st_opening", "Запуск...",
    "acc_st_on", "В игре",
    "acc_st_down", "Вылетел, перезапуск",
    "acc_st_err", "Ошибка: {1}",
    "multi_close", "Закройте все Roblox перед запуском режима нескольких аккаунтов.",
    "acc_need", "Добавьте хотя бы один аккаунт во вкладке «Аккаунты».",
    "log_acc_launch", "[{1}] запуск...",
    "log_acc_down", "[{1}] вылетел.",
    "log_acc_dlg", "[{1}] экран Disconnected, перезапуск.",
    "log_acc_fail", "[{1}] не удалось открыть: {2}",
    "d_account", "Аккаунт",
    "tray_open", "Открыть",
    "tray_toggle", "Старт / Стоп",
    "tray_exit", "Выход",
    "ev_daily", "Сводка за день",
    "f_online_today", "В сети сегодня",
    "f_drops_today", "Вылетов сегодня",
    "f_reopens_today", "Перезапусков сегодня",
    "d_earned", "Заработано сегодня",
    "nav_auto", "Автоматизация",
    "nav_bot", "Бот",
    "nav_hist", "История",
    "pg_auto_sub", "Расписание и эко-режим",
    "pg_bot_sub", "Управляйте скриптом из Discord",
    "pg_hist_sub", "Последние 14 дней",
    "sec_sched", "РАСПИСАНИЕ",
    "sw_sched", "Мониторинг только в заданные часы",
    "sw_sched_sub", "Вне расписания ставится на паузу и потом продолжает сам",
    "lbl_from", "С",
    "lbl_to", "до",
    "lbl_maxh", "Остановить через (часов, 0 = никогда)",
    "lbl_onend", "По окончании",
    "act_none", "Ничего не делать",
    "act_close", "Закрыть Roblox",
    "act_shutdown", "Выключить ПК",
    "sec_eco", "ЭКО-РЕЖИМ",
    "sw_eco", "Включить эко-режим",
    "sw_eco_sub", "Применяется при следующем запуске Roblox",
    "lbl_fps", "Лимит FPS",
    "fps_none", "Без лимита",
    "sw_lowgfx", "Минимальная графика",
    "sw_mute", "Звук выключен",
    "sw_lowprio", "Низкий приоритет для Roblox",
    "sec_bot", "БОТ DISCORD",
    "sw_bot", "Управлять из Discord",
    "sw_bot_sub", "Слушается только вашего ID (вкладка «Вебхук»)",
    "lbl_token", "Токен бота",
    "lbl_channel", "ID канала",
    "bot_off", "Выключен",
    "bot_ok", "Подключён, жду команды",
    "bot_err", "Ошибка: {1}",
    "bot_need_id", "Укажите свой ID Discord во вкладке «Вебхук».",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Включите 'Message Content Intent', пригласите бота на сервер и скопируйте ID канала (ПКМ по каналу).",
    "sec_cmds", "КОМАНДЫ",
    "cmd_status", "статус со скриншотом",
    "cmd_start", "запускает мониторинг",
    "cmd_stop", "останавливает мониторинг",
    "cmd_restart", "закрывает и снова открывает Roblox",
    "cmd_summary", "отправляет сводку за день",
    "cmd_help", "список команд",
    "log_bot_cmd", "Команда из Discord: {1}",
    "hist_online", "Время в сети",
    "hist_coin", "Валюта: {1}",
    "hist_empty", "Данных пока нет. История заполнится со временем.",
    "acc_edit", "Изменить аккаунт",
    "acc_link", "Ссылка для этого аккаунта (необязательно)",
    "acc_ck_keep", "Оставьте пустым, чтобы сохранить текущий cookie.",
    "col_link", "Ссылка",
    "link_default", "по умолчанию",
    "acc_dbl_hint", "Дважды щёлкните аккаунт, чтобы изменить ссылку.",
    "log_sched_pause", "Вне расписания, мониторинг на паузе.",
    "log_sched_resume", "По расписанию, мониторинг возобновлён.",
    "log_maxh", "Достигнуто максимальное время, остановка.",
    "ev_sched", "Мониторинг завершён",
    "d_shutdown", "ПК выключится через 60 секунд.",
    "ev_stop", "Мониторинг остановлен",
    "ev_restart", "Перезапуск Roblox",
    "ev_already", "Мониторинг уже идёт",
    "ev_notrunning", "Мониторинг уже остановлен",
    "ev_unknown", "Неизвестная команда",
    "d_unknown", "Напишите !help, чтобы увидеть команды.",
    "d_restart_how", "Закрываю и снова открываю напрямую через Roblox.",
    "d_running_for", "Работает уже",
    "d_cmd", "Команда",
    "cmd_print", "только скриншот Roblox",
    "cmd_coins", "показывает валюту сейчас",
    "cmd_pc", "загрузка CPU и памяти ПК",
    "cmd_accounts", "статус каждого аккаунта",
    "cmd_hist", "график за 7 дней",
    "cmd_logs", "последние строки журнала",
    "cmd_ping", "проверяет, отвечает ли бот",
    "cmd_link", "меняет ссылку на игру",
    "cmd_update", "ищет и ставит обновления",
    "cmd_shutdown", "выключает ПК (!shutdown confirm)",
    "cmd_cancel", "отменяет выключение",
    "grp_control", "Управление",
    "grp_info", "Информация",
    "grp_config", "Настройки",
    "f_session", "Сессия",
    "f_link", "Ссылка",
    "f_version", "Версия",
    "f_cpu", "CPU",
    "f_ram", "Память",
    "f_roblox_ram", "Roblox (ОЗУ)",
    "f_pc_up", "ПК включён",
    "f_script_up", "Скрипт открыт",
    "f_latency", "Задержка",
    "f_windows", "Окна Roblox",
    "ev_pong", "Понг!",
    "ev_pc", "Состояние ПК",
    "ev_coins", "Ваша валюта",
    "ev_accounts", "Аккаунты",
    "ev_hist", "Последние 7 дней",
    "ev_logs", "Последние записи",
    "ev_link", "Ссылка изменена",
    "d_link_next", "Применится при следующем запуске. Отправьте !restart, чтобы применить сейчас.",
    "ev_linkbad", "Неверная ссылка",
    "d_link_usage", "Формат: !link <ссылка на игру, сервер или Place ID>",
    "ev_updnone", "Уже последняя версия",
    "ev_updating", "Обновление до v{1}",
    "ev_shutdown", "Выключение ПК",
    "ev_shutconf", "Подтвердите выключение",
    "d_shutconf", "Отправьте !shutdown confirm, чтобы выключить через 60 секунд.",
    "ev_cancel", "Выключение отменено",
    "d_back_in", "Снова в игре через {1}с",
    "ev_print", "Скриншот Roblox",
    "no_accounts", "Аккаунты не добавлены.",
    "no_coins", "Не удалось прочитать валюту (держите панель видимой).",
    "sec_panel", "ЖИВАЯ ПАНЕЛЬ",
    "sw_panel", "Закреплённая панель в канале",
    "sw_panel_sub", "Одно сообщение со статусом и скриншотом, обновляется само",
    "lbl_panel_min", "Обновлять каждые (мин)",
    "ev_panel", "Живая панель",
    "d_updated", "Обновлено",
    "bot_hint_help", "Отправьте !help в канал, чтобы увидеть все команды.",
    "sec_stuck", "ФАРМ ЗАВИС",
    "sw_stuck", "Предупреждать, если валюта перестала расти",
    "sw_stuck_sub", "Считывает валюту каждую минуту, чтобы понять, идёт ли фарм",
    "lbl_stuck_min", "Время без изменений (мин)",
    "stuck_alert", "Только уведомить",
    "stuck_restart", "Уведомить и перезапустить",
    "ev_stuck", "Фарм остановился",
    "d_stuck", "Валюта не меняется уже {1} мин.",
    "r_stuck", "фарм остановился (валюта не меняется)",
    "log_stuck", "Фарм стоит уже {1} мин.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Оформление",
    "pg_look_sub", "Выберите тему",
    "sec_theme", "ТЕМА"
)
I18N["tr"] := Map(
    "nav_home", "Ana Sayfa",
    "nav_game", "Oyun",
    "nav_window", "Pencere",
    "nav_hook", "Webhook",
    "nav_coins", "Paralar",
    "nav_logs", "Kayıtlar",
    "nav_about", "Hakkında",
    "pg_home_sub", "Merhaba, {1}! İzleme özeti",
    "pg_game_sub", "Sunucu, kontrol aralığı ve hata kurtarma",
    "pg_win_sub", "Roblox pencere konumu ve tarayıcı sekmesi",
    "pg_hook_sub", "Discord'da uyarılar ve durum",
    "pg_coins_sub", "Roblox ekranındaki paralarını okur ve webhook'a gönderir",
    "pg_about_sub", "Lisans, sürüm ve yenilikler",
    "pg_logs_sub", "Bu oturumun geçmişi",
    "idle", "Durduruldu",
    "click_start", "İzlemek için Başlat'a tıkla",
    "btn_start", "Başlat",
    "btn_stop", "Durdur",
    "st_uptime", "ÇALIŞMA SÜRESİ",
    "st_reopens", "YENİDEN AÇMA",
    "st_drops", "DÜŞMELER",
    "st_lastdrop", "SON DÜŞME",
    "quick", "HIZLI İŞLEMLER",
    "btn_open_now", "Oyunu şimdi aç",
    "btn_place", "Pencereyi yerleştir",
    "btn_compact", "Kompakt mod",
    "sec_server", "SUNUCU",
    "hint_link", "Oyun linki, özel sunucu linki veya sadece Place ID.",
    "sec_monitor", "İZLEME",
    "lbl_check", "Kontrol aralığı (saniye)",
    "lbl_wait", "Açıldıktan sonra bekle (sn)",
    "sec_recovery", "KURTARMA",
    "sw_err", "Hata, bağlantı kopması veya donmada yeniden başlat",
    "sw_err_sub", "Logda bağlantı kopması, atılma, başarısız ışınlanma veya yanıt vermeyen pencere",
    "lbl_tol", "Tolerans (saniye)",
    "sec_pos", "KONUM",
    "sw_place", "Sağ üst köşeye yerleştir",
    "sw_place_sub", "Roblox penceresini sabit ve tamamen görünür tutar",
    "lbl_width", "Genişlik",
    "lbl_height", "Yükseklik",
    "btn_place_now", "Şimdi yerleştir",
    "sec_browser", "TARAYICI",
    "sw_tab", "Girdikten sonra tarayıcı sekmesini kapat",
    "sw_tab_sub", "Başlığında 'Roblox' olan sekmeyi kapatır ve tarayıcıyı küçültür",
    "btn_test", "Test et",
    "hint_hook", "Otomatik uyarılar: düşme, yeniden açma denemesi, geri dönüş ve hatalar (saatli).",
    "sec_status", "PERİYODİK DURUM",
    "sw_rep", "Ekran görüntüsüyle durum gönder",
    "sw_rep_sub", "Hesap durumu + sadece Roblox penceresinin görüntüsü",
    "lbl_interval", "Aralık (dakika)",
    "btn_send_now", "Şimdi gönder",
    "sec_ocr", "EKRAN OKUMA (OCR)",
    "sw_ocr", "Paraları durum embed'inde gönder",
    "sw_ocr_sub", "Roblox penceresinde görünen değerleri okur",
    "lbl_coins", "Paralar ( | ile ayır). İsteğe bağlı emoji: Gems=<:gems:123456>",
    "sec_lastread", "SON OKUMA",
    "btn_testread", "Okumayı test et",
    "no_read", "Henüz okuma yok.",
    "not_found", "bulunamadı",
    "nothing_read", "Hiçbir şey okunmadı.",
    "ocr_open", "Roblox'u (küçültmeden) paralar görünür şekilde aç.",
    "ocr_names", "Para adlarını yukarıya yaz.",
    "log_ocr_tested", "Para okuma test edildi ({1}/{2} bulundu).",
    "ocr_err", "OCR hatası: {1}",
    "log_ocr_saw", "OCR'ın gördüğü metin:",
    "log_coin_err", "Para okuma hatası: {1}",
    "sec_version", "YÜKLÜ SÜRÜM",
    "upd_never", "Henüz kontrol edilmedi.",
    "btn_checkupd", "Güncelleme ara",
    "sec_license", "LİSANS",
    "btn_changekey", "Anahtarı değiştir",
    "paste_new_key", "Yeni anahtarı yapıştır.",
    "sw_autoupd", "Otomatik güncelle",
    "sec_news", "YENİLİKLER",
    "news_ph", "Yenilikler kontrol ettikten sonra burada görünür.",
    "btn_clear", "Temizle",
    "upd_not_cfg", "Güncelleme ayarlanmadı.",
    "upd_searching", "Güncelleme aranıyor...",
    "upd_noconn", "Şu an kontrol edilemedi.",
    "upd_badfile", "İndirilen dosya betik gibi görünmüyor.",
    "upd_latest", "En yeni sürümdesin.",
    "upd_avail", "Yeni sürüm v{1} mevcut! Yenilikler aşağıda.",
    "btn_upd_to", "v{1} sürümüne güncelle",
    "badge_new", "Yeni sürüm v{1}",
    "log_upd_avail", "Güncelleme mevcut: v{1}.",
    "log_upd_dlfail", "Güncelleme indirilemedi: {1}",
    "log_upd_fail", "Güncelleme başarısız: {1}",
    "log_updated", "v{1} sürümüne güncellendi! Yeniden başlatılıyor...",
    "lang_menu", "Dil",
    "lang_auto", "Otomatik (sistem)",
    "mini_sub", "yen. açma {1} · düşme {2}",
    "key_title", "Lisansı etkinleştir",
    "key_sub", "Auto Reconnect Roblox'u açmak için anahtarını yapıştır.",
    "btn_activate", "Etkinleştir",
    "your_hwid", "HWID'İN",
    "btn_copy", "Kopyala",
    "hwid_copied", "HWID kopyalandı.",
    "btn_buy", "Anahtar satın al",
    "checking_lic", "Lisans kontrol ediliyor...",
    "ka_app_nf", "KeyAuth'ta uygulama bulunamadı (ad/Owner ID kontrol et).",
    "ka_badver", "KeyAuth sürümü farklı (KEYAUTH_VER panelle aynı olmalı).",
    "key_nf", "Anahtar mevcut değil.",
    "key_invalid", "Geçersiz anahtar.",
    "key_hwid", "Bu anahtar başka bir PC'de etkin (farklı HWID).",
    "key_expired", "Anahtarının süresi doldu.",
    "hwid_banned", "Bu PC yasaklandı.",
    "key_banned", "Bu anahtar yasaklandı.",
    "session_exp", "Oturum sona erdi, tekrar dene.",
    "key_fail", "Anahtar doğrulanamadı.",
    "paste_key_first", "Önce anahtarını yapıştır.",
    "checking", "Kontrol ediliyor...",
    "connecting", "Lisans sunucusuna bağlanılıyor...",
    "no_conn", "Lisans sunucusuna ulaşılamıyor. İnternetini kontrol et.",
    "lic_lifetime", "Ömür boyu",
    "side_lifetime", "ÖMÜR BOYU LİSANS",
    "lic_expires", "Bitiş: {1}  ({2} gün)",
    "side_days", "LİSANS: {1} GÜN",
    "lic_active", "Etkin",
    "side_active", "LİSANS ETKİN",
    "lic_offline", "2 saatten fazla lisans doğrulanamadı.",
    "log_lic_bad", "Geçersiz lisans: {1}",
    "activate_to_use", "Kullanmak için anahtarını etkinleştir.",
    "hook_need_url", "Önce webhook URL'sini gir.",
    "hook_sent", "Webhook gönderildi (HTTP {1}).",
    "hook_fail", "Webhook başarısız: {1}",
    "log_status_sent", "Durum gönderildi (HTTP {1}).",
    "log_status_fail", "Durum gönderilemedi: {1}",
    "why_closed", "Roblox kapalı",
    "why_min", "pencere küçültülmüş",
    "why_fail", "yakalama başarısız",
    "emb_offline", "Çevrimdışı",
    "emb_warn", "Çevrimiçi · logda kopma",
    "emb_online", "Oyunda çevrimiçi",
    "up_stopped", "durduruldu",
    "none", "Yok",
    "next_status", "sonraki durum {1} dk sonra",
    "no_shot", "görüntü yok ({1})",
    "f_uptime", "Çalışma süresi",
    "f_reopens", "Yeniden açma",
    "f_drops", "Düşmeler",
    "f_lastdrop", "Son düşme",
    "m_exe", "doğrudan Roblox ile",
    "m_uri", "roblox:// linki",
    "m_web", "tarayıcı",
    "roblox_not_reg", "Roblox kayıt defterinde bulunamadı",
    "paste_link_first", "Önce oyun linkini yapıştır.",
    "log_all_failed", "Hiçbir açma yöntemi işe yaramadı. Sonraki kontrolde tekrar denenecek.",
    "log_method_failed", "Yöntem {1}/{2} ({3}) başarısız: {4}",
    "log_opening", "Açılıyor ({1})",
    "log_reopening", "Yeniden açılıyor ({1})",
    "log_opened", "Roblox açıldı ({1}sn). Oyuna giriliyor...",
    "st_joining", "Oyuna giriliyor...",
    "st_joining_sub", "Roblox açık, sunucu yükleniyor",
    "log_joined", "Oyuna girildi ({1}sn).",
    "log_not_open25", "Roblox 25 sn'de açılmadı, başka yöntem deneniyor...",
    "log_not_join60", "Roblox açıldı ama 60 sn'de oyuna girmedi, başka yöntem deneniyor...",
    "log_not_open", "Roblox açık değil.",
    "log_placed", "Roblox penceresi yerleştirildi.",
    "log_detected", "Roblox penceresi algılandı.",
    "log_placed_right", "Roblox penceresi sağ köşeye yerleştirildi.",
    "log_tab_closed", "Tarayıcıdaki Roblox sekmesi kapatıldı.",
    "log_tab_nf", "Roblox sekmesi bulunamadı. Açık başlıklar:",
    "none_lc", "yok",
    "log_disc_log", "Logda bağlantı koptu. Yeniden giriş bekleniyor...",
    "log_err_restart", "Hata algılandı: {1}. Roblox yeniden başlatılıyor...",
    "log_disc_screen", "Pencerede Disconnected ekranı.",
    "log_disc_screen_c", "Pencerede Disconnected ekranı (kod {1}).",
    "r_disc_screen", "Disconnected ekranı",
    "r_disc_screen_c", "Disconnected ekranı - kod {1}",
    "log_rejoined", "Yeniden girildi / normal ışınlanma, tamam.",
    "r_no_rejoin", "yeniden girmeden kopma/hata",
    "r_hung", "pencere dondu (yanıt vermiyor)",
    "log_back", "Roblox geri döndü ({1} boyunca kapalı).",
    "log_down", "Roblox kapandı/bağlantı koptu.",
    "st_loading", "Yükleniyor...",
    "st_loading_sub", "Oyunun açılıp sunucuya girmesi bekleniyor",
    "st_on_warn_sub", "Logda kopma, yeniden giriş bekleniyor",
    "st_on_sub", "Oyunda · izleniyor",
    "st_off_sub", "Kapalı, şimdi yeniden açılıyor",
    "st_nolink", "Link yok",
    "st_nolink_sub", "Oyun linkini Oyun sekmesine yapıştır",
    "st_monitoring", "İzleniyor...",
    "st_monitoring_sub", "Roblox kontrol ediliyor",
    "log_mon_start", "İzleme başladı (her {1}sn).",
    "log_mon_stop", "İzleme durduruldu.",
    "ev_start", "İzleme başladı",
    "ev_reopen", "Roblox yeniden açılıyor",
    "ev_fail", "Roblox açılamadı",
    "ev_error", "Hata algılandı",
    "ev_back", "Roblox geri döndü",
    "ev_down", "Roblox kapandı/bağlantı koptu",
    "ev_lic", "Geçersiz lisans",
    "ev_updated", "v{1} sürümüne güncellendi",
    "ev_test", "Webhook çalışıyor!",
    "d_time", "Saat",
    "d_away", "Kapalı kaldığı süre",
    "d_reason", "Sebep",
    "d_restart", "Roblox yeniden başlatılıyor...",
    "d_stopped", "İzleme durduruldu.",
    "d_retry", "Sonraki kontrolde tekrar deneyeceğim.",
    "d_test", "Uyarılar buraya gelecek.",
    "d_method", "Yöntem",
    "d_interval", "Kontrol aralığı",
    "d_user", "Kullanıcı",
    "tour_welcome_t", "Hoş geldin, {1}!",
    "tour_welcome", "Temel şeyleri bir dakikadan kısa sürede göstereceğim. İstediğin zaman geçebilirsin.",
    "tour_link_t", "1. Oyun linki",
    "tour_link", "Oyun linkini, özel sunucu linkini ya da sadece Place ID'yi buraya yapıştır. Betik seni oraya geri götürür.",
    "tour_hook_t", "2. Discord uyarıları",
    "tour_hook", "İsteğe bağlı: düştüğünde, geri döndüğünde veya hata olduğunda uyarı almak için bir Discord kanal webhook'u yapıştır.",
    "tour_test_t", "Webhook'u test et",
    "tour_test", "Uyarıların Discord'a ulaştığını kontrol etmek için buraya tıkla.",
    "tour_win_t", "3. Pencere konumu",
    "tour_win", "Bu açıkken Roblox penceresi ekranın sağ üst köşesinde sabit kalır.",
    "tour_coins_t", "4. Paralar (isteğe bağlı)",
    "tour_coins", "Ekranda görünen para adlarını yaz, Discord durumunda da görünsünler.",
    "tour_start_t", "5. Başla!",
    "tour_start", "Her şey hazır olunca Başlat'a tıkla. Betik Roblox'u izler ve düşersen yeniden açar.",
    "tour_compact_t", "Kompakt mod",
    "tour_compact", "Her şeyi küçük bir çubuğa indirir, daha az yer kaplar.",
    "tour_lang_t", "Dil",
    "tour_lang", "Dili buradan değiştir. Varsayılan olarak Windows dilini kullanır.",
    "tour_upd_t", "Güncellemeler",
    "tour_upd", "Yeni sürüm çıkınca üstte bir uyarı çıkar ve buradan tek tıkla güncellersin.",
    "tour_done_t", "Her şey hazır!",
    "tour_done", "Bu öğreticiyi istediğin zaman Hakkında → Öğreticiyi göster'den tekrar izleyebilirsin.",
    "btn_next", "İleri",
    "btn_back", "Geri",
    "btn_skip", "Geç",
    "btn_finish", "Bitir",
    "btn_tour", "Öğreticiyi göster",
    "tour_step", "{1} / {2}",
    "nav_opts", "Seçenekler",
    "nav_accounts", "Hesaplar",
    "pg_opts_sub", "Başlangıç, bildirimler ve günlük özet",
    "pg_acc_sub", "Aynı anda birden fazla hesap (deneysel)",
    "sec_startup", "BAŞLANGIÇ",
    "sw_startwin", "Windows ile başlat",
    "sw_startwin_sub", "PC açılınca betiği açar",
    "sw_automon", "Açılınca izlemeye otomatik başla",
    "sw_automon_sub", "Betik açılınca senin yerine Başlat'a basar",
    "sec_notify", "BİLDİRİMLER",
    "sw_toast", "Windows bildirimi",
    "sw_toast_sub", "Düşünce, geri dönünce veya hata olunca köşede uyarı",
    "sw_tray", "Tepsiye küçült",
    "sw_tray_sub", "Küçültünce saatin yanında sadece simge kalır",
    "sec_daily", "GÜNLÜK ÖZET",
    "sw_daily", "Discord'a günlük özet gönder",
    "lbl_daily_time", "Saat (SS:DD)",
    "sec_mention", "SENİ ETİKETLE",
    "sw_mention", "Düşünce veya hata olunca beni etiketle",
    "sw_mention_sub", "Sadece seni etiketler, asla @everyone",
    "lbl_discord_id", "Discord ID'n",
    "btn_how", "Nasıl bulunur?",
    "hint_discord_id", "Discord > Ayarlar > Gelişmiş > Geliştirici Modu'nu aç. Sonra adına sağ tıkla > Kullanıcı ID'sini kopyala.",
    "sw_multi", "Birden fazla hesap kullan",
    "sw_multi_sub", "Başlamadan önce Roblox'u kapat. Hepsi Oyun sekmesindeki linki kullanır.",
    "col_account", "Hesap",
    "col_status", "Durum",
    "btn_add_acc", "Hesap ekle",
    "btn_rem_acc", "Kaldır",
    "btn_tile", "Pencereleri düzenle",
    "acc_cookie", "Hesabın .ROBLOSECURITY çerezi",
    "acc_cookie_hint", "Hesaba girili tarayıcıda: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Bu PC'de şifreli saklanır. Asla kimseyle paylaşma.",
    "btn_save", "Kaydet",
    "btn_cancel", "İptal",
    "acc_checking", "Hesap kontrol ediliyor...",
    "acc_invalid", "Geçersiz veya süresi dolmuş çerez.",
    "acc_added", "{1} hesabı eklendi.",
    "acc_st_off", "Kapalı",
    "acc_st_opening", "Açılıyor...",
    "acc_st_on", "Oyunda",
    "acc_st_down", "Düştü, yeniden açılıyor",
    "acc_st_err", "Hata: {1}",
    "multi_close", "Çoklu hesap modunu başlatmadan önce tüm Roblox'ları kapat.",
    "acc_need", "Hesaplar sekmesinde en az bir hesap ekle.",
    "log_acc_launch", "[{1}] açılıyor...",
    "log_acc_down", "[{1}] düştü.",
    "log_acc_dlg", "[{1}] Disconnected ekranı, yeniden başlatılıyor.",
    "log_acc_fail", "[{1}] açılamadı: {2}",
    "d_account", "Hesap",
    "tray_open", "Aç",
    "tray_toggle", "Başlat / Durdur",
    "tray_exit", "Çıkış",
    "ev_daily", "Günün özeti",
    "f_online_today", "Bugün çevrimiçi",
    "f_drops_today", "Bugünkü düşmeler",
    "f_reopens_today", "Bugünkü yeniden açmalar",
    "d_earned", "Bugün kazanılan",
    "nav_auto", "Otomasyon",
    "nav_bot", "Bot",
    "nav_hist", "Geçmiş",
    "pg_auto_sub", "Zamanlama ve tasarruf modu",
    "pg_bot_sub", "Betiği Discord'dan kontrol et",
    "pg_hist_sub", "Son 14 günün",
    "sec_sched", "ZAMANLAMA",
    "sw_sched", "Sadece belirli saatlerde izle",
    "sw_sched_sub", "Saat dışında durur, sonra kendiliğinden devam eder",
    "lbl_from", "Başlangıç",
    "lbl_to", "bitiş",
    "lbl_maxh", "Şu kadar sonra dur (saat, 0 = asla)",
    "lbl_onend", "Bitince",
    "act_none", "Hiçbir şey yapma",
    "act_close", "Roblox'u kapat",
    "act_shutdown", "PC'yi kapat",
    "sec_eco", "TASARRUF MODU",
    "sw_eco", "Tasarruf modunu aç",
    "sw_eco_sub", "Roblox bir sonraki açılışta geçerli olur",
    "lbl_fps", "FPS sınırı",
    "fps_none", "Sınırsız",
    "sw_lowgfx", "En düşük grafik",
    "sw_mute", "Ses kapalı",
    "sw_lowprio", "Roblox için düşük öncelik",
    "sec_bot", "DISCORD BOTU",
    "sw_bot", "Discord'dan kontrol et",
    "sw_bot_sub", "Sadece ID'ne uyar (Webhook sekmesi)",
    "lbl_token", "Bot token'ı",
    "lbl_channel", "Kanal ID'si",
    "bot_off", "Kapalı",
    "bot_ok", "Bağlandı, komutlar dinleniyor",
    "bot_err", "Hata: {1}",
    "bot_need_id", "Discord ID'ni Webhook sekmesine yaz.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. 'Message Content Intent'i aç, botu sunucuna davet et ve kanal ID'sini kopyala (kanala sağ tıkla).",
    "sec_cmds", "KOMUTLAR",
    "cmd_status", "ekran görüntüsüyle durumu gösterir",
    "cmd_start", "izlemeyi başlatır",
    "cmd_stop", "izlemeyi durdurur",
    "cmd_restart", "Roblox'u kapatıp yeniden açar",
    "cmd_summary", "günün özetini gönderir",
    "cmd_help", "komutları listeler",
    "log_bot_cmd", "Discord komutu: {1}",
    "hist_online", "Çevrimiçi süre",
    "hist_coin", "Para: {1}",
    "hist_empty", "Henüz veri yok. Geçmiş günler geçtikçe dolar.",
    "acc_edit", "Hesabı düzenle",
    "acc_link", "Bu hesabın linki (isteğe bağlı)",
    "acc_ck_keep", "Mevcut çerezi korumak için boş bırak.",
    "col_link", "Link",
    "link_default", "varsayılan",
    "acc_dbl_hint", "Linkini düzenlemek için hesaba çift tıkla.",
    "log_sched_pause", "Saat dışında, izleme duraklatıldı.",
    "log_sched_resume", "Saat içinde, izleme devam ediyor.",
    "log_maxh", "Azami süreye ulaşıldı, duruluyor.",
    "ev_sched", "İzleme bitti",
    "d_shutdown", "PC 60 saniye içinde kapanacak.",
    "ev_stop", "İzleme durduruldu",
    "ev_restart", "Roblox yeniden başlatılıyor",
    "ev_already", "Zaten izleniyor",
    "ev_notrunning", "İzleme zaten durdurulmuş",
    "ev_unknown", "Bilinmeyen komut",
    "d_unknown", "Komutları görmek için !help yaz.",
    "d_restart_how", "Kapatılıp doğrudan Roblox ile yeniden açılıyor.",
    "d_running_for", "Çalışma süresi",
    "d_cmd", "Komut",
    "cmd_print", "sadece Roblox ekran görüntüsü",
    "cmd_coins", "paralarını şimdi gösterir",
    "cmd_pc", "PC'nin CPU ve bellek kullanımı",
    "cmd_accounts", "her hesabın durumu",
    "cmd_hist", "son 7 günün grafiği",
    "cmd_logs", "son log satırları",
    "cmd_ping", "botun yanıt verdiğini test eder",
    "cmd_link", "oyun linkini değiştirir",
    "cmd_update", "güncelleme arar ve kurar",
    "cmd_shutdown", "PC'yi kapatır (!shutdown confirm)",
    "cmd_cancel", "kapatmayı iptal eder",
    "grp_control", "Kontrol",
    "grp_info", "Bilgi",
    "grp_config", "Ayarlar",
    "f_session", "Oturum",
    "f_link", "Link",
    "f_version", "Sürüm",
    "f_cpu", "CPU",
    "f_ram", "Bellek",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC açık kalma süresi",
    "f_script_up", "Betik açık kalma süresi",
    "f_latency", "Gecikme",
    "f_windows", "Roblox pencereleri",
    "ev_pong", "Pong!",
    "ev_pc", "PC durumu",
    "ev_coins", "Paraların",
    "ev_accounts", "Hesaplar",
    "ev_hist", "Son 7 gün",
    "ev_logs", "Son loglar",
    "ev_link", "Link değiştirildi",
    "d_link_next", "Bir sonraki açılışta geçerli. Hemen uygulamak için !restart gönder.",
    "ev_linkbad", "Geçersiz link",
    "d_link_usage", "Kullanım: !link <oyun linki, sunucu linki veya Place ID>",
    "ev_updnone", "Zaten en yeni sürüm",
    "ev_updating", "v{1} sürümüne güncelleniyor",
    "ev_shutdown", "PC kapatılıyor",
    "ev_shutconf", "Kapatmayı onayla",
    "d_shutconf", "60 saniyede kapatmak için !shutdown confirm gönder.",
    "ev_cancel", "Kapatma iptal edildi",
    "d_back_in", "{1} sn sonra oyuna döndü",
    "ev_print", "Roblox ekran görüntüsü",
    "no_accounts", "Eklenmiş hesap yok.",
    "no_coins", "Paralar okunamadı (paneli pencerede görünür bırak).",
    "sec_panel", "CANLI PANEL",
    "sw_panel", "Kanalda sabit panel",
    "sw_panel_sub", "Durum ve görüntü içeren, kendini güncelleyen tek mesaj",
    "lbl_panel_min", "Güncelleme aralığı (dk)",
    "ev_panel", "Canlı panel",
    "d_updated", "Güncellendi",
    "bot_hint_help", "Tüm komutları görmek için kanala !help yaz.",
    "sec_stuck", "TAKILAN FARM",
    "sw_stuck", "Paralar artmayı bırakırsa uyar",
    "sw_stuck_sub", "Farmın ilerleyip ilerlemediğini anlamak için paraları her dakika okur",
    "lbl_stuck_min", "Değişmeden geçen süre (dk)",
    "stuck_alert", "Sadece uyar",
    "stuck_restart", "Uyar ve yeniden başlat",
    "ev_stuck", "Farm durdu",
    "d_stuck", "Paralar {1} dakikadır değişmiyor.",
    "r_stuck", "farm durdu (paralar değişmiyor)",
    "log_stuck", "Farm {1} dakikadır duruyor.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Görünüm",
    "pg_look_sub", "Uygulama temasını seç",
    "sec_theme", "TEMA"
)
I18N["id"] := Map(
    "nav_home", "Beranda",
    "nav_game", "Game",
    "nav_window", "Jendela",
    "nav_hook", "Webhook",
    "nav_coins", "Mata Uang",
    "nav_logs", "Log",
    "nav_about", "Tentang",
    "pg_home_sub", "Halo, {1}! Ringkasan pemantauan",
    "pg_game_sub", "Server, interval pengecekan dan pemulihan error",
    "pg_win_sub", "Posisi jendela Roblox dan tab browser",
    "pg_hook_sub", "Notifikasi dan status di Discord",
    "pg_coins_sub", "Membaca mata uangmu di layar Roblox dan mengirim ke webhook",
    "pg_about_sub", "Lisensi, versi dan yang baru",
    "pg_logs_sub", "Riwayat sesi ini",
    "idle", "Berhenti",
    "click_start", "Klik Mulai untuk memantau",
    "btn_start", "Mulai",
    "btn_stop", "Berhenti",
    "st_uptime", "WAKTU AKTIF",
    "st_reopens", "BUKA ULANG",
    "st_drops", "PUTUS",
    "st_lastdrop", "PUTUS TERAKHIR",
    "quick", "AKSI CEPAT",
    "btn_open_now", "Buka game sekarang",
    "btn_place", "Atur jendela",
    "btn_compact", "Mode ringkas",
    "sec_server", "SERVER",
    "hint_link", "Link game, link server privat, atau cukup Place ID.",
    "sec_monitor", "PEMANTAUAN",
    "lbl_check", "Cek setiap (detik)",
    "lbl_wait", "Tunggu setelah dibuka (detik)",
    "sec_recovery", "PEMULIHAN",
    "sw_err", "Mulai ulang saat error, terputus, atau macet",
    "sw_err_sub", "Terputus di log, kick, teleport gagal, atau jendela tidak merespons",
    "lbl_tol", "Toleransi (detik)",
    "sec_pos", "POSISI",
    "sw_place", "Letakkan di pojok kanan atas",
    "sw_place_sub", "Menjaga jendela Roblox tetap dan terlihat penuh",
    "lbl_width", "Lebar",
    "lbl_height", "Tinggi",
    "btn_place_now", "Atur sekarang",
    "sec_browser", "BROWSER",
    "sw_tab", "Tutup tab browser setelah masuk",
    "sw_tab_sub", "Menutup tab berjudul 'Roblox' dan meminimalkan browser",
    "btn_test", "Tes",
    "hint_hook", "Notifikasi otomatis: putus, coba buka ulang, kembali online, dan error (dengan jam).",
    "sec_status", "STATUS BERKALA",
    "sw_rep", "Kirim status dengan tangkapan layar",
    "sw_rep_sub", "Embed status akun + tangkapan jendela Roblox saja",
    "lbl_interval", "Interval (menit)",
    "btn_send_now", "Kirim sekarang",
    "sec_ocr", "BACA LAYAR (OCR)",
    "sw_ocr", "Kirim mata uang di embed status",
    "sw_ocr_sub", "Membaca nilai yang tampil di jendela Roblox",
    "lbl_coins", "Mata uang (pisahkan dengan | ). Emoji opsional: Gems=<:gems:123456>",
    "sec_lastread", "BACAAN TERAKHIR",
    "btn_testread", "Tes baca",
    "no_read", "Belum ada bacaan.",
    "not_found", "tidak ditemukan",
    "nothing_read", "Tidak ada yang terbaca.",
    "ocr_open", "Buka Roblox (jangan diminimalkan) dengan mata uang terlihat.",
    "ocr_names", "Masukkan nama mata uang di atas.",
    "log_ocr_tested", "Baca mata uang dites ({1}/{2} ditemukan).",
    "ocr_err", "Error OCR: {1}",
    "log_ocr_saw", "Teks yang dilihat OCR:",
    "log_coin_err", "Gagal membaca mata uang: {1}",
    "sec_version", "VERSI TERPASANG",
    "upd_never", "Belum dicek.",
    "btn_checkupd", "Cek pembaruan",
    "sec_license", "LISENSI",
    "btn_changekey", "Ganti key",
    "paste_new_key", "Tempel key baru.",
    "sw_autoupd", "Perbarui otomatis",
    "sec_news", "YANG BARU",
    "news_ph", "Yang baru muncul di sini setelah dicek.",
    "btn_clear", "Bersihkan",
    "upd_not_cfg", "Pembaruan belum diatur.",
    "upd_searching", "Mencari pembaruan...",
    "upd_noconn", "Tidak bisa cek sekarang.",
    "upd_badfile", "File yang diunduh sepertinya bukan skrip.",
    "upd_latest", "Kamu memakai versi terbaru.",
    "upd_avail", "Versi baru v{1} tersedia! Lihat yang baru di bawah.",
    "btn_upd_to", "Perbarui ke v{1}",
    "badge_new", "Versi baru v{1}",
    "log_upd_avail", "Pembaruan tersedia: v{1}.",
    "log_upd_dlfail", "Gagal mengunduh pembaruan: {1}",
    "log_upd_fail", "Pembaruan gagal: {1}",
    "log_updated", "Diperbarui ke v{1}! Memulai ulang...",
    "lang_menu", "Bahasa",
    "lang_auto", "Otomatis (sistem)",
    "mini_sub", "buka ulang {1} · putus {2}",
    "key_title", "Aktifkan lisensi",
    "key_sub", "Tempel key untuk membuka Auto Reconnect Roblox.",
    "btn_activate", "Aktifkan",
    "your_hwid", "HWID KAMU",
    "btn_copy", "Salin",
    "hwid_copied", "HWID disalin.",
    "btn_buy", "Beli key",
    "checking_lic", "Memeriksa lisensi...",
    "ka_app_nf", "Aplikasi tidak ditemukan di KeyAuth (cek nama/Owner ID).",
    "ka_badver", "Versi KeyAuth berbeda (samakan KEYAUTH_VER dengan panel).",
    "key_nf", "Key tidak ada.",
    "key_invalid", "Key tidak valid.",
    "key_hwid", "Key ini sudah aktif di PC lain (HWID berbeda).",
    "key_expired", "Key kamu sudah kedaluwarsa.",
    "hwid_banned", "PC ini telah diblokir.",
    "key_banned", "Key ini telah diblokir.",
    "session_exp", "Sesi kedaluwarsa, coba lagi.",
    "key_fail", "Tidak bisa memvalidasi key.",
    "paste_key_first", "Tempel key dulu.",
    "checking", "Memeriksa...",
    "connecting", "Menghubungkan ke server lisensi...",
    "no_conn", "Tidak bisa terhubung ke server lisensi. Cek internetmu.",
    "lic_lifetime", "Seumur hidup",
    "side_lifetime", "LISENSI SEUMUR HIDUP",
    "lic_expires", "Berakhir {1}  ({2} hari)",
    "side_days", "LISENSI: {1} HARI",
    "lic_active", "Aktif",
    "side_active", "LISENSI AKTIF",
    "lic_offline", "Lebih dari 2 jam lisensi tidak bisa divalidasi.",
    "log_lic_bad", "Lisensi tidak valid: {1}",
    "activate_to_use", "Aktifkan key untuk memakai.",
    "hook_need_url", "Masukkan URL webhook dulu.",
    "hook_sent", "Webhook terkirim (HTTP {1}).",
    "hook_fail", "Webhook gagal: {1}",
    "log_status_sent", "Status terkirim (HTTP {1}).",
    "log_status_fail", "Gagal mengirim status: {1}",
    "why_closed", "Roblox tertutup",
    "why_min", "jendela diminimalkan",
    "why_fail", "gagal menangkap",
    "emb_offline", "Offline",
    "emb_warn", "Online · terputus di log",
    "emb_online", "Online di game",
    "up_stopped", "berhenti",
    "none", "Tidak ada",
    "next_status", "status berikutnya {1} menit lagi",
    "no_shot", "tanpa tangkapan ({1})",
    "f_uptime", "Waktu aktif",
    "f_reopens", "Buka ulang",
    "f_drops", "Putus",
    "f_lastdrop", "Putus terakhir",
    "m_exe", "langsung lewat Roblox",
    "m_uri", "link roblox://",
    "m_web", "browser",
    "roblox_not_reg", "Roblox tidak ditemukan di registry",
    "paste_link_first", "Tempel link game dulu.",
    "log_all_failed", "Tidak ada cara yang berhasil. Coba lagi di pengecekan berikutnya.",
    "log_method_failed", "Cara {1}/{2} ({3}) gagal: {4}",
    "log_opening", "Membuka ({1})",
    "log_reopening", "Membuka ulang ({1})",
    "log_opened", "Roblox terbuka ({1}d). Masuk ke game...",
    "st_joining", "Masuk ke game...",
    "st_joining_sub", "Roblox terbuka, memuat server",
    "log_joined", "Masuk ke game ({1}d).",
    "log_not_open25", "Roblox tidak terbuka dalam 25 d, mencoba cara lain...",
    "log_not_join60", "Roblox terbuka tapi tidak masuk game dalam 60 d, mencoba cara lain...",
    "log_not_open", "Roblox tidak terbuka.",
    "log_placed", "Jendela Roblox diatur.",
    "log_detected", "Jendela Roblox terdeteksi.",
    "log_placed_right", "Jendela Roblox dipindah ke pojok kanan.",
    "log_tab_closed", "Tab Roblox di browser ditutup.",
    "log_tab_nf", "Tab Roblox tidak ditemukan. Judul yang terbuka:",
    "none_lc", "tidak ada",
    "log_disc_log", "Terputus di log. Menunggu masuk ulang...",
    "log_err_restart", "Error terdeteksi: {1}. Memulai ulang Roblox...",
    "log_disc_screen", "Layar Disconnected di jendela.",
    "log_disc_screen_c", "Layar Disconnected di jendela (kode {1}).",
    "r_disc_screen", "layar Disconnected",
    "r_disc_screen_c", "layar Disconnected - kode {1}",
    "log_rejoined", "Masuk ulang / teleport normal, ok.",
    "r_no_rejoin", "terputus/error tanpa masuk ulang",
    "r_hung", "jendela macet (tidak merespons)",
    "log_back", "Roblox kembali (mati selama {1}).",
    "log_down", "Roblox tertutup/terputus.",
    "st_loading", "Memuat...",
    "st_loading_sub", "Menunggu game terbuka dan masuk server",
    "st_on_warn_sub", "Terputus di log, menunggu masuk ulang",
    "st_on_sub", "Di game · memantau",
    "st_off_sub", "Tertutup, membuka ulang sekarang",
    "st_nolink", "Tidak ada link",
    "st_nolink_sub", "Tempel link di tab Game",
    "st_monitoring", "Memantau...",
    "st_monitoring_sub", "Memeriksa Roblox",
    "log_mon_start", "Pemantauan dimulai (setiap {1}d).",
    "log_mon_stop", "Pemantauan dihentikan.",
    "ev_start", "Pemantauan dimulai",
    "ev_reopen", "Membuka ulang Roblox",
    "ev_fail", "Tidak bisa membuka Roblox",
    "ev_error", "Error terdeteksi",
    "ev_back", "Roblox kembali",
    "ev_down", "Roblox tertutup/terputus",
    "ev_lic", "Lisensi tidak valid",
    "ev_updated", "Diperbarui ke v{1}",
    "ev_test", "Webhook berfungsi!",
    "d_time", "Waktu",
    "d_away", "Mati selama",
    "d_reason", "Alasan",
    "d_restart", "Memulai ulang Roblox...",
    "d_stopped", "Pemantauan dihentikan.",
    "d_retry", "Akan dicoba lagi di pengecekan berikutnya.",
    "d_test", "Notifikasi akan muncul di sini.",
    "d_method", "Cara",
    "d_interval", "Cek setiap",
    "d_user", "Pengguna",
    "tour_welcome_t", "Selamat datang, {1}!",
    "tour_welcome", "Aku tunjukkan dasar-dasarnya dalam kurang dari semenit. Bisa dilewati kapan saja.",
    "tour_link_t", "1. Link game",
    "tour_link", "Tempel link game, link server privat, atau cukup Place ID di sini. Ke sanalah skrip membawamu kembali.",
    "tour_hook_t", "2. Notifikasi Discord",
    "tour_hook", "Opsional: tempel webhook channel Discord untuk dapat notifikasi saat putus, kembali, atau error.",
    "tour_test_t", "Tes webhook",
    "tour_test", "Klik di sini untuk cek apakah notifikasi sampai ke Discord.",
    "tour_win_t", "3. Posisi jendela",
    "tour_win", "Jika aktif, jendela Roblox tetap di pojok kanan atas layar.",
    "tour_coins_t", "4. Mata uang (opsional)",
    "tour_coins", "Masukkan nama mata uang di layar agar ikut tampil di status Discord.",
    "tour_start_t", "5. Mulai!",
    "tour_start", "Kalau semua sudah siap, klik Mulai. Skrip mengawasi Roblox dan membukanya lagi jika putus.",
    "tour_compact_t", "Mode ringkas",
    "tour_compact", "Mengecilkan semuanya jadi bar kecil agar hemat tempat.",
    "tour_lang_t", "Bahasa",
    "tour_lang", "Ganti bahasa di sini. Secara bawaan mengikuti bahasa Windows.",
    "tour_upd_t", "Pembaruan",
    "tour_upd", "Saat ada versi baru, muncul pemberitahuan di atas dan kamu bisa memperbarui di sini dengan sekali klik.",
    "tour_done_t", "Semua siap!",
    "tour_done", "Kamu bisa mengulang tutorial ini kapan saja di Tentang → Lihat tutorial.",
    "btn_next", "Lanjut",
    "btn_back", "Kembali",
    "btn_skip", "Lewati",
    "btn_finish", "Selesai",
    "btn_tour", "Lihat tutorial",
    "tour_step", "{1} dari {2}",
    "nav_opts", "Opsi",
    "nav_accounts", "Akun",
    "pg_opts_sub", "Startup, notifikasi dan ringkasan harian",
    "pg_acc_sub", "Beberapa akun sekaligus (eksperimental)",
    "sec_startup", "STARTUP",
    "sw_startwin", "Mulai bersama Windows",
    "sw_startwin_sub", "Membuka skrip saat PC menyala",
    "sw_automon", "Mulai memantau otomatis saat dibuka",
    "sw_automon_sub", "Menekan Mulai untukmu saat skrip dibuka",
    "sec_notify", "NOTIFIKASI",
    "sw_toast", "Notifikasi Windows",
    "sw_toast_sub", "Pemberitahuan di pojok saat putus, kembali, atau error",
    "sw_tray", "Minimalkan ke tray",
    "sw_tray_sub", "Saat diminimalkan, hanya ikon di dekat jam",
    "sec_daily", "RINGKASAN HARIAN",
    "sw_daily", "Kirim ringkasan harian ke Discord",
    "lbl_daily_time", "Jam (HH:MM)",
    "sec_mention", "TANDAI KAMU",
    "sw_mention", "Tandai aku saat putus atau error",
    "sw_mention_sub", "Hanya menandai kamu, tidak pernah @everyone",
    "lbl_discord_id", "ID Discord kamu",
    "btn_how", "Cara mencari?",
    "hint_discord_id", "Discord > Pengaturan > Lanjutan > aktifkan Mode Pengembang. Lalu klik kanan namamu > Salin ID Pengguna.",
    "sw_multi", "Pakai beberapa akun",
    "sw_multi_sub", "Tutup Roblox sebelum mulai. Semua memakai link dari tab Game.",
    "col_account", "Akun",
    "col_status", "Status",
    "btn_add_acc", "Tambah akun",
    "btn_rem_acc", "Hapus",
    "btn_tile", "Atur jendela",
    "acc_cookie", "Cookie .ROBLOSECURITY akun",
    "acc_cookie_hint", "Di browser yang login ke akun: F12 > Application > Cookies > roblox.com > .ROBLOSECURITY. Disimpan terenkripsi di PC ini. Jangan pernah dibagikan.",
    "btn_save", "Simpan",
    "btn_cancel", "Batal",
    "acc_checking", "Memeriksa akun...",
    "acc_invalid", "Cookie tidak valid atau kedaluwarsa.",
    "acc_added", "Akun {1} ditambahkan.",
    "acc_st_off", "Tertutup",
    "acc_st_opening", "Membuka...",
    "acc_st_on", "Di game",
    "acc_st_down", "Putus, membuka ulang",
    "acc_st_err", "Error: {1}",
    "multi_close", "Tutup semua Roblox sebelum memulai mode multi-akun.",
    "acc_need", "Tambahkan minimal satu akun di tab Akun.",
    "log_acc_launch", "[{1}] membuka...",
    "log_acc_down", "[{1}] putus.",
    "log_acc_dlg", "[{1}] layar Disconnected, memulai ulang.",
    "log_acc_fail", "[{1}] gagal dibuka: {2}",
    "d_account", "Akun",
    "tray_open", "Buka",
    "tray_toggle", "Mulai / Berhenti",
    "tray_exit", "Keluar",
    "ev_daily", "Ringkasan hari ini",
    "f_online_today", "Online hari ini",
    "f_drops_today", "Putus hari ini",
    "f_reopens_today", "Buka ulang hari ini",
    "d_earned", "Didapat hari ini",
    "nav_auto", "Otomasi",
    "nav_bot", "Bot",
    "nav_hist", "Riwayat",
    "pg_auto_sub", "Jadwal dan mode hemat",
    "pg_bot_sub", "Kendalikan skrip dari Discord",
    "pg_hist_sub", "14 hari terakhirmu",
    "sec_sched", "JADWAL",
    "sw_sched", "Pantau hanya di jam tertentu",
    "sw_sched_sub", "Di luar jam berhenti, lalu lanjut sendiri",
    "lbl_from", "Dari",
    "lbl_to", "sampai",
    "lbl_maxh", "Berhenti setelah (jam, 0 = tidak pernah)",
    "lbl_onend", "Setelah selesai",
    "act_none", "Tidak melakukan apa-apa",
    "act_close", "Tutup Roblox",
    "act_shutdown", "Matikan PC",
    "sec_eco", "MODE HEMAT",
    "sw_eco", "Aktifkan mode hemat",
    "sw_eco_sub", "Berlaku saat Roblox dibuka berikutnya",
    "lbl_fps", "Batas FPS",
    "fps_none", "Tanpa batas",
    "sw_lowgfx", "Grafik paling rendah",
    "sw_mute", "Suara mati",
    "sw_lowprio", "Prioritas rendah untuk Roblox",
    "sec_bot", "BOT DISCORD",
    "sw_bot", "Kendalikan dari Discord",
    "sw_bot_sub", "Hanya menuruti ID kamu (tab Webhook)",
    "lbl_token", "Token bot",
    "lbl_channel", "ID channel",
    "bot_off", "Mati",
    "bot_ok", "Terhubung, menunggu perintah",
    "bot_err", "Error: {1}",
    "bot_need_id", "Masukkan ID Discord kamu di tab Webhook.",
    "bot_setup", "discord.com/developers > New Application > Bot > Reset Token. Aktifkan 'Message Content Intent', undang bot ke server, lalu salin ID channel (klik kanan channel).",
    "sec_cmds", "PERINTAH",
    "cmd_status", "menampilkan status dengan tangkapan layar",
    "cmd_start", "mulai memantau",
    "cmd_stop", "berhenti memantau",
    "cmd_restart", "menutup lalu membuka ulang Roblox",
    "cmd_summary", "mengirim ringkasan hari ini",
    "cmd_help", "menampilkan daftar perintah",
    "log_bot_cmd", "Perintah Discord: {1}",
    "hist_online", "Waktu online",
    "hist_coin", "Mata uang: {1}",
    "hist_empty", "Belum ada data. Riwayat terisi seiring hari berlalu.",
    "acc_edit", "Edit akun",
    "acc_link", "Link akun ini (opsional)",
    "acc_ck_keep", "Biarkan kosong untuk memakai cookie yang sekarang.",
    "col_link", "Link",
    "link_default", "bawaan",
    "acc_dbl_hint", "Klik dua kali akun untuk mengubah link-nya.",
    "log_sched_pause", "Di luar jam, pemantauan dijeda.",
    "log_sched_resume", "Di dalam jam, pemantauan dilanjutkan.",
    "log_maxh", "Waktu maksimal tercapai, berhenti.",
    "ev_sched", "Pemantauan selesai",
    "d_shutdown", "PC akan mati dalam 60 detik.",
    "ev_stop", "Pemantauan dihentikan",
    "ev_restart", "Memulai ulang Roblox",
    "ev_already", "Sudah memantau",
    "ev_notrunning", "Pemantauan sudah berhenti",
    "ev_unknown", "Perintah tidak dikenal",
    "d_unknown", "Ketik !help untuk melihat perintah.",
    "d_restart_how", "Menutup lalu membuka ulang langsung lewat Roblox.",
    "d_running_for", "Aktif selama",
    "d_cmd", "Perintah",
    "cmd_print", "kirim tangkapan layar Roblox saja",
    "cmd_coins", "menampilkan mata uangmu sekarang",
    "cmd_pc", "pemakaian CPU dan memori PC",
    "cmd_accounts", "status setiap akun",
    "cmd_hist", "grafik 7 hari terakhir",
    "cmd_logs", "baris log terakhir",
    "cmd_ping", "cek apakah bot merespons",
    "cmd_link", "mengganti link game",
    "cmd_update", "cek dan pasang pembaruan",
    "cmd_shutdown", "mematikan PC (!shutdown confirm)",
    "cmd_cancel", "membatalkan mematikan PC",
    "grp_control", "Kontrol",
    "grp_info", "Info",
    "grp_config", "Pengaturan",
    "f_session", "Sesi",
    "f_link", "Link",
    "f_version", "Versi",
    "f_cpu", "CPU",
    "f_ram", "Memori",
    "f_roblox_ram", "Roblox (RAM)",
    "f_pc_up", "PC menyala selama",
    "f_script_up", "Skrip terbuka selama",
    "f_latency", "Latensi",
    "f_windows", "Jendela Roblox",
    "ev_pong", "Pong!",
    "ev_pc", "Kondisi PC",
    "ev_coins", "Mata uangmu",
    "ev_accounts", "Akun",
    "ev_hist", "7 hari terakhir",
    "ev_logs", "Log terakhir",
    "ev_link", "Link diganti",
    "d_link_next", "Berlaku di pembukaan berikutnya. Kirim !restart untuk menerapkan sekarang.",
    "ev_linkbad", "Link tidak valid",
    "d_link_usage", "Format: !link <link game, link server, atau Place ID>",
    "ev_updnone", "Sudah versi terbaru",
    "ev_updating", "Memperbarui ke v{1}",
    "ev_shutdown", "Mematikan PC",
    "ev_shutconf", "Konfirmasi mematikan PC",
    "d_shutconf", "Kirim !shutdown confirm untuk mematikan dalam 60 detik.",
    "ev_cancel", "Mematikan PC dibatalkan",
    "d_back_in", "Kembali ke game setelah {1}d",
    "ev_print", "Tangkapan layar Roblox",
    "no_accounts", "Belum ada akun.",
    "no_coins", "Gagal membaca mata uang (biarkan panel terlihat di jendela).",
    "sec_panel", "PANEL LANGSUNG",
    "sw_panel", "Panel tetap di channel",
    "sw_panel_sub", "Satu pesan berisi status dan tangkapan layar yang memperbarui sendiri",
    "lbl_panel_min", "Perbarui setiap (menit)",
    "ev_panel", "Panel langsung",
    "d_updated", "Diperbarui",
    "bot_hint_help", "Kirim !help di channel untuk melihat semua perintah.",
    "sec_stuck", "FARM MACET",
    "sw_stuck", "Beri tahu jika mata uang berhenti naik",
    "sw_stuck_sub", "Membaca mata uang tiap menit untuk tahu farm berjalan atau tidak",
    "lbl_stuck_min", "Waktu tanpa perubahan (menit)",
    "stuck_alert", "Hanya beri tahu",
    "stuck_restart", "Beri tahu dan mulai ulang",
    "ev_stuck", "Farm berhenti",
    "d_stuck", "Mata uang tidak berubah selama {1} menit.",
    "r_stuck", "farm berhenti (mata uang tidak berubah)",
    "log_stuck", "Farm berhenti selama {1} menit.",
    "f_state", "Roblox",
    "nav_discord", "Discord",
    "nav_look", "Tampilan",
    "pg_look_sub", "Pilih tema aplikasi",
    "sec_theme", "TEMA"
)
LANG := SystemLang()
for c in LANG_CODES
    if (c = savedLang)
        LANG := c
USER_NAME  := UserDisplayName()
USER_FIRST := StrSplit(Trim(USER_NAME), " ")[1]
NAVK := Map("Início", "nav_home", "Jogo", "nav_game", "Janela", "nav_window", "Webhook", "nav_hook"
    , "Moedas", "nav_coins", "Logs", "nav_logs", "Sobre", "nav_about", "Contas", "nav_accounts", "Opções", "nav_opts", "Automação", "nav_auto", "Bot", "nav_bot", "Histórico", "nav_hist", "Discord", "nav_discord", "Aparência", "nav_look")
updBase       := (GITHUB_REPO = "") ? "" : "https://raw.githubusercontent.com/" GITHUB_REPO "/" GITHUB_BRANCH "/"
savedOcr      := IniRead(iniFile, "cfg", "ocr", "1")
defaultCur    := "Gems=<:gem:1571984310137913505>|Gold=<:gold:1571984476525957120>|Summer Pearls=<:pearl:1571984541059387432>|Legacy Gems"
savedCur      := IniRead(iniFile, "cfg", "currencies", defaultCur)
; config antiga sem emoji -> troca pela nova
if (savedCur = "Gems|Gold|Legacy Gems|Summer Pearls")
    savedCur := defaultCur
errPat  := IniRead(iniFile, "cfg", "errPatterns", "Disconnection Notification|Client has been disconnected|Connection lost|Lost connection|Sending disconnect with reason|Reconnect was unsuccessful|ID_CONNECTION_LOST")
joinPat := IniRead(iniFile, "cfg", "joinPatterns", "Joining game|game_join_loadtime|Connection accepted")
winW := Integer(IniRead(iniFile, "cfg", "winW", "800"))
winH := Integer(IniRead(iniFile, "cfg", "winH", "630"))

; ==========================================================
;  GUI principal
; ==========================================================
W := 760, H := 600, SIDE := 184
CX := SIDE + 28          ; x do conteúdo
CW := W - CX - 28        ; largura do conteúdo

; ---------------- Logo (embutida no script) ----------------
LOGO_SIDE_B64 := "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAIAAABt+uBvAAA0y0lEQVR42tW9d5iV1bU/vtbebzlteqMIDINSBUYEsUSRYo0oWLDEaCwxam5i1Kg37SZGc29yvdaoCWqMvSu2RJSoKIhSBKQLwwxthunDqW/be6/vH/vM4XBmxJh487u/9/HBd87znresd5XP+qy118FwOAr/2o1zrpQMgoCIlJIAQEREVHAYIiIiADDGEdE0Tca4lPJffLfGv0woQeALIYiUFodhGKWlZSNHjmSMDR48uLZ2eBAEWiJKKdO0du5samlpkVJu27a1p6cnk0ljdmOGYZimlS8sxli/Uv6/LiDOuee5UkqlFAANGTKkvv6IiRPrDz98/JAhQwYMGFReXsY5Z4wbBi9QICGEUlJK2dPTs3dvy+7duzdsWL9+/bpNmzZu27bN8zzGmGlZpmH2nl/rpvp6xYT/GybGGVckPc+VUjGGU6YcdeKJ0084Ydr48RPKyso450EQCCGECAC0ETHTtHotC/QDBoGvH5uITNM0DMM0TSllPL7vs88+++CDxR9++MGqVSuFkJZlTjpyyob167VOfb1i+poFxDkPhB/4vlJq8ODBc+eeM2/e+ePHT7Bt2/M813UBwLbtUChEBErJzs5OIUQymWhsbNT2lduGD68rLi7mnFdWVjLGEcF1Xc/zACAUCtl2yHXd9evXvfLKiy+++OIxxx79Hz//xb33/P6ll18ORKDv5GtxWF+bgBhjQorA95RSRx019Vvf+vZZZ82prq52HMd1Xdu2w+EwEXV1dX3++ZZVq1bt2NH4+eefNzQ0OE7Gdd1MJlNwwlisyDB4LFZUVzdi9OjRtbXDJ0+ePGrU6IqKCkR0HMfzvFAoFA6H29vbn3vumTPO/Oa4MWPXrV37+/sffP6FF4QQX4tj+noEhIium1FKnThjxg//7brp02eapplIxBljxcXFvu9v2rTp009XvfPO22vXrtm9e1e/qpfTIP1IpmlWVlbu2bMn/7AhQ4bW1x9x8smnHHnk5LFjx1qWlUgkiKioqCiRSCCD6soKxtny5ctv/fVti99f/M+r0j8rIET0fVcIMXr0mBtvvOmCCy4kong8Hg5HioqKGhu3v/fe31566cUlS5YIEeS+YhjZ4FDgLPL3TdOcM2fOggULiICxbHQTQmSDi2Ecf/y0c889d8aMWXV1dalUynEcREakDINXV1ciwosvPH/zLT9ta2tDxH9Yj/4pASGC42QYYzfeeNMNN9wUi8W6u7ui0WgkEl21auULLzz3/PPPtre35x44XyK5Oy5QnJzBSilPO+20pUuXJpNJxhkQAAA3uN4RQujja2pqzjvv/PPPv3Dy5Cme56ZSKcYYAHheZtiQQ1rbW2+++Scvv/zKP+5Vc+HjqyqOUtJ1nUmTjnz88acvu+zydDolRFBRUbF+/fpf/OJnt9zy448/XpZOpw3D0IiPiHRU0rLIySV/hzEGCAjIARmymkED"
    . "WtvafN9jnIcsCxACP7BtQwmFBMzgnPNEIrFixfJnnnmqoWFbbe3wQw89VEophODcSqXTCNCwdeuKVSsZ47mrfzXf+g/5Y3Rdx/Pcq6++9u23/3bUUVNaW/eWlZUlEsmf/ewn06cf//TTT/q+b5qmVgQpZYGCa53PD1s6lpeUlhARISggQARFDAAJQCrf96++8sqj6idKL+AGF0iKlJSSMWaapud5Tz/91InTj//Zz3/a09NTVlYOQMg4oLG7eW8ymXCcDOfsXyEgRMxk0rFY9NFHH7/33vt933cct6qq6ulnnjph2rF33nlHEARaNDl/0VdZ8vfzjW7kYSM554CoAELhUCaVTscTYcOoHzd2yMCBpeHoqy+9PGHsWCElMzgg6m/pgGUahgiCO//nv0844bhnnnmqrKzMNAwieuiRPz366OPRaCSdzlrf/6KJaaczduy4Z5994bTTTm9paS4rK4/H9119zVX//bv/SqVSpmkqpXIAL5dP5STS1/XoHUSUSp17zjkbNm70XBcAysrKUt3xM049edyY0WeeMXv2qaeOHDWy/thjOdBrb/6FISIdIGuSigFYprUvvu/111/bvHnTtBOnV1RUtLW1HnvsN6ZNm75ixSctLc2mZcFX8tfhcPTv/C8SiQJAfX19U9PuZNLZsWOP64qFCxcNr6sDAMM0Gefaj2AuazpwP//P/M+5ZRqWGQ6HF7yyYNghQxCAmxwRZ049eveWLc89/hh5fpBOC8/x3czepqapEybqQHbAOZm+HuOM6Sg5vK5u4cJFrit27Nijb3jixHoACEejf/9T/70ahAiZTLq+/ogFC94oLi5JJBLV1TUPPnj/ZZdd0t3dbZqmkrJfUyrIzgvCrT6SI4pA1FRV/ea2X5Pwjz/+uK6uTieR/OP99w+tHVZWXVVeVR0QKcZM0ywqK0/39Cx8713Geb4uEENAACCliEiZptHV1fXcc8+WlJRMnz6zq6srFiuaO/fsxYvf37N7t2lZuRT3awjzedJ5vaSkJJPJlJaW/du/XfPYY49qgFcQILRxGYaRC8b9xnIAYJxLISaPHTP37LmVNdWXXHqpkDJWWvb2W2/tadxx+eVXCCUVQGdPT2dX17aG7WvXrq4dOHjo0KGzzz3b93wERNbry7J+XSEgY8gYMwyulPK84Dvfufz++x/ct29fOBxJJOJz5565du0aOxRmyL4UIn25gBDRcdITJ07UuuM4mdLSsmuuuerJJx83DIN6t3ytUUqVlpb6vp/JZLRfVEr1VSsdgAYPGvQfN9184UUXAeInS5cefeI0Mg2RcZUfRIuKhBQtba07d+1etnzlCy++IHyvs72jvKwsFIlYlrl3b8uuXbsAABBUzruRznizL4ZzHgTi4ou/PX/+I/v29YRC4WQyecYZp3V0tA0ePHTz5s2MsYMggC8xMcbQcdKjR4958823tHTKyrLSsW07B+ELFIQxFgSB7/s5J10gwV4kpSZOnHjevHkN23c0"
    . "Ne6MhYtef+WNQ0eNKq2qCDIuB+S2pYiamnb++Ykn/rJw4datW02Du76/a89uz/ct00yn047jhEIhEQjKGTgAQO4vDSCsNWvW7Nq169xz56VSyZKSkhkzZp50wrSf3vzvr7z+Wk9Pz0Fs7WAC0mlEcXHxs8++UFdXl0gkysrKr7nmu08++YRlWVLKnH7m7+h9IsrF1AJYmDsmFAqNHj36821bl69dPmnshO6Ozh07ttXXT6gZPCjZ1eP5fqy06IOPlt15zz1LPvywvbXVcdL7eroz6bRp8lQy2d7ebphGJBLxfV9KCUQMEPYHSQRAvaOUMk1zzZrVe/bsOffcefF4vLyiorp6QGJXy6RRY15e+Jd/EAcpJYUQd955z9SpU7u6uqqra6699ntPPvmEaZpCCI1f8oN3TiL5Hxb4oPyttLR069at6z5b29nd2dXV9fpbb4aioXQ6CQCO47R3dgDyu++5Z1vDNsu2EomeWDTywAO/f/TRPwER58wOhZLJpJTS9z0i0i46T2chP2gqpSKRyBNPPHbddd+vqKhwMmkjZO9yEg17d579zdP79QBfIiBEcF3nqqu+d/HFlzQ3Nw8YMPD3v7/niSce07rT7zMXpJ39Ug35n7iu293V7TguBeqNhX/Z2dpihkO+DADAC/wlSz9KJlOffrqyuXm35zkaLl988cU11VVBIECqIQMHTBg7tru7mzFkTIuD5TPclLcppVzXNU3zkUcefvD++6qqajKp1FFHTd3d3b3446V2yP5CN9Rv8I9GixBxwoSJnZ3xPXtak0n3rbcWMcYMw+Ccs7ytAO/kf5hvUP0eYxiGYRjImBU2GeBps8/87hWXrVnxkSKR3Ndz9ZVXP/zwn6PFsVhp0Zyz5+h3duOPbxg0aGDIsg6pGXDHbb/e3dR4xumnAoBlm6Zp8jwglrtK/nU55wbnBuLCtxYlk25LS3tbW9eRU6ZEokXFxaX9iqJ/AVmWZdv2u+8ujsfTra2djY27hw2rBQBuGIBoWVYoZHPO92O0LxZQgSgLjuecc84BobpmwLnf+taFF16wp7FBkU+kFv5l4bixE0KRUNYei4tGHjZiwoTx88479zsXXrjuk+UkBYkg8Nyf/PQW2zIBwLJMwzAYw/yr5SNJxphhGog4rLa2qWl3a2tnPJ5evHhpaVlFeXllOBwNh2NfLiCNmG+66RbPUzt3Nmcy/py5cwEgHI2EIuFwJBSJhEyTIwLn/cDivvrV7zF5VR1mmvYRR02dNnPWNVde46UyQeB6bkZJ8fGypfPOnTt5/LjXn3t2zfKPuzvbln/yceC5HS0tXiLhpdNeJh24DhF9uPj9ww4dAQC2bRlG9uwFGqSvrCtIADB79pmOE+zc2ex58pZbfmJZdmlp+ZdrUDRaxDkbMWJEW1tXc3NbJuP/+c+Pc9MoLS+LFReFoxHTMhCh1+zxICLoV0BaIgWfRGOxMYePH15bd9dv7yAi10kHvutkUkQkXWfFkiW7G7bJ"
    . "wPV8Jwh8J5MWvus6ac/NeE4m8Nx0Mk5EjY0N48aMAQDL4F8goP2bltH8+Y9kMkFzc1t7e9eRR06pqKiMxYq/VIMi+puplNfa2tmwrWnAgAGIyAwOmMUYiMAYIOp0Gvp6on63gjC/X5UYM2yztKR46MBBK5cuI6VcN+O5Gc91nEzKz2SIqK2lpbOtzYkn3WTCdzO+6/iu42TSge96nuO5mUw6SURbN24cccgQgzHD4AdJADUPyxirqqratm1Ha2tnKuXNn/8IAn6JBsVixYjsuOO+kUy6u3a1uK780XXXA4BhmcgZMASGgMAQDyKgft1NgWgK81iTAcAp06Z5mTRJ0dPT5WbSge8Gvus4TtpxAiH8RKZnZ0vXzt1ud09Pa2tPWzsR+b7rOGnXzXi+m0rFiej1p5+zOOdfJqCcEv3oR9e7rty1qyWVco877nhEVqBEBwgoFIpwzl9++dVEItPVFV+2bLllWZxzxntdBsJBtCQnIC21g2h4ge/klsEZu++//5uIPt+0sbWl2fM9x037bsb3XM93Pc9xU6nMvniQdgLXddOpDatXrfrk40w66WbSvpMJXCfjpjOpJAXivDPPAgBucsaQMc4YLxBTzgNwzm3bWrZseVdXPJHIvPzyq5zzcDiSLxNWUAWdMGHizJmz4vF4NBq79967fd9njJHS4IWAslW9fmFVDn0UIOy+GXx+isiQSSHGjxtbWVW9+uNPDMYrKyqECIAAFAERKIVE3DLMiE2cSQTgOGrsmG1btrz91kLbDgERAnDOgSMx/PdbbomFw5TFfgigr0U53cndLWPM8/x77707Go3G4/GZM2dNnFjvui7nvB+gqJQiUt/5zuWmaUYikRUrlr/66oIDayZYkD3kKLF8uJyfuxb8m5+I5PImRSoUCjHO9ra0DBs+vG7ECCGEgcx3XaV6T6u/pUgpxRAZMlB0wrQT29vbm/fsNm1bEZFQFjcDz5009aiTZ81SkjjjkE09kOgAZK//lVJyzhe8+srKlSsikYhhGJdddjmR6h9Je54zYMCAs86aE4/HY7GiZ5992vM8znm/uULumQtgaw77aPCq4Wm+k6a+7DSAEML1vO9+73slJSV+4DPGUMimrQ2SlGYziEAphQx7y8pKKfnRso/Kyyu6u7uBcQQwELUYgPMLL7qIA4BUQEAAOekU3AMRcc59z3/mmadjsaJEIjF79lkDBw5ynEyhgDjnUqq5c8+prq5hjDU2bn/xxRcQUfbSYAW1mpya5EfugjvQ6lYg2QJWGBENwxS+mHfeeQbivq4uhkwEYsO69R+8v1gK0autgIhKksG4bYdM09qza9fqVavGjBkdCoWgt2NExw4pgxkzptcNPkQoqQtqOXa2b+ojhUTEl156obFxO2Osurpm7tyztWYdICDf90zTuOCCCx0nU1xcsmjRO52dHQVdAPmKkG9oBal8X2WhAzdtrMQ4MkMRQ2RFscg555yzft26WCS2+K2/7d6+44nnntu8"
    . "fXs4HAMCRAQCBLRMq2FLw9/eXoTMaG/vLCkqGTxgcFVVjQgkmhYxDKRAzkQQlFfXHD/zRAXAGaKS/Rp7L82mmME6OjoWLXpb8znnn3+BZZm+7x0gICFEff0R48dPdF3X9/2XXnqhX/bjIJlnviz6fmW/MeZhWlLK4Oh57pyzz/alXLt50z333//syy++s/j9Pz/xuGJg2KZUMhs9OUunU7f/5ra9ra0AMOKwUaedMdv1vUgkIqUkWUBpwkknn5Td668pq3Af8IWXnvd933Xd8eMn1tcfsb+Em+sXOfHE6eFwSCm5ceP6Zcs+0jxbv/aVrz65JLhf7jL/E30Vhsg4l0oqqRhjoFQ0Epl3/vl/eOihxobG1pbWyqrKTzevj8fjo0aNBgCplL4TwzT37eupHT7szLlnBkFQXlFRWV2d8V1FpKtvgCqPb1Hjx4+PhmzX9XB/YOnnjQKCUhIYfrxs2caNG0aNGhUOh044YdqKFSt0gGIAIETAOTvhhGme54bDkZUrVwghtBEWeJacxeVThUSkeYaDbPkUmlJKSQlEiBBI8W/XXvvyiy+99sqrn61Zl0im13y2btOmTSHLPvEbx2ufpd+TEKK0vOzGm28Ih8MKQBHzpDRtm5scGQtFwqFwVBfjGGdSBMOH1Y4YUScBGOak1p8Goa5oMynkipXLw+GI67onnjidc6abCbICqqmpmTix3nFcInr77YW5l18gEY2vDrgAA2RAJPvlU/KRqz6nlFIqpRGDUnTqqadsbWh47LHH06lUJpOM93R5TjpwvUmTjpgwcYLwPETkhsEASJFpmaFIWEmJpBAUKuU7DmM8lYg/+vDD77//ruv74UhMBkoGKlJcMmH84bqdK1+DCpWIAAERGAC8885CInJdd8KECTU1NVkBac2fNGlyWVkZInZ2dnz22dq+fRd9i6LZizEgBoCFBxRQsQfUC4kAUCmybbuhYfuCV19FhkL4QvjpTIKBAoB5F8wzLIukICBSCgkBiBAJ0OAclESQdsiOxYoC3/veVd+94qqrTjvtm6ecetqSjz4yLMv3BSCbNGFCgTX1Y/4EpEBJBQDrPvuss7MDEcvKyidNmqyUMgwjS8HV19dzzm3b/vzzLa2trflQ8ov8y5fWQr7oW4ioSTfXdRsaGkzTBCIplVIKkfmBsG1rRF0dABCAzQxUpDQOVllMAwA8FP501Yrf/Ob2mTOmv7jg1XDIBoBlSz+65pqrRRBEwmEgGjf+cAaghNRJI/YXN7SINCBqbW39/PMttm0zzuvr6xEZIhpKSSIaM2ZsEAjbtleuXKmU0rxqweNpX5B7cm3AlF+7QwCCg/vs/K4vfSodL3Q3o1avuhF1AECkhJTxzu6KmmoJqheDA5EyTGvDZ2u/ecbstvYOALAtww8CImCcbW/YvnL5iroRhw4cNGDEYSMrSmKd8RQyTkAMWV/uWWMILaAgCFauXHn88ScEgRgzZqyUwvNcJoSw7VBtbW0QBADQ1NSY"
    . "E0ffMlYh01wgAYIviqkF3rqgS6iXP0EpVV1d7eBBgwzTRGTbGxpadu1hhkGIOpzlouevfvnLtvaOaDQCAJ4vpFQAoIikkhd+66L77rtPkBw4cOAhgw4hAIaIgLnX0zcW5x5KP34ggqFDhp51ztnTT57FlFLFxUUDBw6SUgghP/98i05SvshwCrMKhUxli76AB5R9CpoX+iX2c+5Tp0vFxSVDhtZ29fSMHz+xcfv2xx5/MlZWQqSklApBkASSoVBo6+efv7f4Q9M00unMN75x3MKFb40ZM5qIwqFQ4PnD6+qu+9F1nuuGY8XDhw0HAELKv+e+j5MLPvsyCSml53l1dXWvPv/SGaecxpSSI0YcVlZWDgBdXZ07djT2qz79dmsQkTbtLDwGPIjn6ls7zNcypci2Q7W1w7ds3hKNRD3fO++8ec0tLQOHDNFVfwbYe2Ns4cK3e+L7AKC0tOThhx8mgng8zk3DyTjFpaW/uu22QYMH6f6gCeMnZCN8HyfdT63cND9dsbKzs8MyDGDso3cWhR2XZQv/jCFiEATJZCJ3wrwHKOQu8tWkoDpWkNkXeJ8CHdSN96ZpRKOR8oryPXv2tLburaquvuw7l61es3rmrFmR4iJJZHCOADybuaoPPlisUcKIEYfedtvtp512WkvLXuEHRx937HvvvzfzxBMzToZxDgD1RxxxQMDqvdu+jUJBEEghhOdrCoExRrYRTycBEefNuyCd9jo6elavXldUFEOEg3Nd+VWUAuJOnzq/NHSQ9pfcVWKxSCwWiUSiiJwbZnFpCQDMmjkrlUh5ruN7Gc/NBL7ruZnAz+zZvWPQwAEAwLmBzAAAw7AmTZp8//0POI5DRKl0OvC8VCappNy2fkNJLFpAhOueAH2TBfiupKRkzZr13d2J5ua29u7u3S0tBhHV1tZyzk3T2r69IZlMGQaTkvpNtQ4e+wvS1H5tKufNNZmFAESkASoRIDDGWGJffHjd8PkPzQ9HQr7vGoZBQEopIYJItHj9+vUte1tnnDjjvLPP2b694bPNmy699JLp004cNHBAMpEAIW3DAKU441IGQ4YOrRs+fM36DQV3q/P1XLjQTIlhGPF4vKFh24gRI4qLih59/LGmnU2GRtL5XATR/nDda1/Ui0T3yyF36r5yOUg2mzUxVARAQLog2uvLCBkEvjds+LDXX3+9rm6442SYfrDs+hezs7PjjjvuOv7Ybzz/3POVFZU9rS12RUkkHPWSyZY9u8vKy02TEykCYAAkpV1cdPTUqWvWb0DGkEgplUvn9f0bBg+FQ4l4EgBsM0xK6VZGqVRxLCrctKZs2MGz9lysyRH1/aLBAla8b//d/txtPyzYDxp02jVmzJi333778HGHZzIZg3PdaUdEhmnecceddXWHlpVX3HXPXbHikOeliqorGGImmcwkksXFJZqHx9671CeeOXMWAACpLOua5xxN00TGbNueMmXy4IGDHc+RSsuNbNveuGnjG2/8xfjSJLOP"
    . "aAiR5Xvf/J18efVtGjrANWr7UvpIlXMNv/vdb0cdNiqdThoGZ4DENDwE3/Nisdgvb73txut/qNugiYEEYowBylhxMbMMItJdQsiY0phSiGOOObqmoqK9u4sxVLDfW2uMaodt3w9a97Ze+Z3LKkrLH3v2ccsyCUBKWTVgQCbw2Zf6mvx2BsS/N9Xoy0DmhMWQwQEpdRaCMsZmzJw5ffp0z3NMw8hqTu6LiD+47gc3Xv/DVCadcRwAkyFniEDALRNtM0c2cc4JCBlyzgLfGzR02MyZM4iA8f2lvdw7yziOkIHrOH944MHSoqJP3l08qf6IdDptcB74wZAhQ4xcDzwgfFFGnr9Kqd+OlvxPcolIAXufC+1SyRxPSJBlcwYPPqS6uuaaq66OxYqcTMo0TEBSBEopXb9HpXzPI1Im5wjIGBAhKYHICEApybItQShIIWrsSlIIQDz8sJH6zYAoZMuQMJ1yPO6XlZR8/8c/ipSXnH7G7J54Ih5PXHbppefPO4ch4o6djVLIwPdHjDg0FovJvHbMPBnhwSNaAZl/ED+dNS/a/xpHjh5z+PgJp59yypmzZ3upjGEYihQREGYlq3Mozpgu0TGGQJJI6pIOy7boIyHI/Tk66fBNQCQUAJCi/M7hbERSpLmOfck4MfjtXXd1dveYphmIoLKiLBq2GSLu2LFTSElEsVjMMHhBK3MvSqeDG1S/FY5+kUE+COKc26GQHQnVDh3ys5/8e09Hhw4iiKj64E/VS7nlzo69DFz2K1Ix3Q+MBKgkSQRCCXua9+wnmPMa2BljxSXFlmUJIRDQcZxUMimE0JHBZLxx23YGAMiyMc80zVisqG+Vop+8ND+Q9QlSfVOTgkqZZs5CoZBhGK7jjB8z+r677+pqbeMmVzz3hhGyZ2C5RuisE8D91FIuhc61BJIuN5IUFHDLSLa2Ll7yISCgUhwOiME67NcdduhRU6dqykX2rjLL8iMaD2/btrWnpxsAKioqa2uHHwQHZh+YQOsqISgiBf00z+cD8b7qFo1GTzppVnl5uZTyrrvuevqpZ7Zv2gIAkeKYUKrf7rQD/qI+GWJWbFnOR4cwBmBYoXvvvmvzzp2GaZBmEHptUGtmKpWKFsWu+d7Vf3nt9fHjxhUXF1dVVWliAzn/dO0axhhLJVJ7W1o4NwyDjxo9ulA6CMC0SJTmrBiiAcAICAkYEqI68JH6tTW9Y1lWOBw59dRTPNft7Oh44N57vn3RRX995TXF+eARdUoCRwRUBISEqLTZakTaWyTtxXgHODjU+SxThEqSVMoKR0Jm+J7f/Odtd91pcC4DJQkEEgIgQ47IEe1ImHHu+v6QQYNmTZ/1ztsLf3zLTa7rMsY4YwDQ2tLKDMPwPG/nrp06lg2vretbLD6AtCQlSQUmA5NbihsKuCL84khf4LCllAD02muvfbhkaUVl+e69La+//tro8eNGHz7W81xtf8A0qtb9vFl712qf82K9+DvL2Ok8RUnBFYUi4XAk"
    . "tvLjT+bMnn39z3/GLYvytE6/54BkIKWTSo8eM8b1vbbOTuH7ldVVc8+a62kinDEVBKtWfWroZfubNm2cM2eu63pTpkzhnGc75BE0z5TLPSSAZZmWbScTKQESAExuGEYWWeVKFwX1oty+Tn9831dE55x79q23/vqQQYNKSst660Io/IAhKlI6smjOuyA+qqzu9N6TZq0VGRxC4QiQ+uTDD+fP/+PzL7zoCGGapi/U/hp/9gyqrKJi1qyZyz/6+PONG2efc87mTZvgrLMEqUQ8xZBJKYtLiru7u7d8vtXQ31mzdo3upx01avSAAQOam5v3V+Vz9k+AiEqoad+YMv34GesbGj9Y+XHTju3g+dkaG+cqr1JWwH7kCtlEYJvGnh07H3v4kWOmTh00cCACdXZ2cGRHTKivGTrY12yuAkSkXMhCxF7al0DTh9nCnGVbjJkqlfzb26/9Yf78txe9kw4k52jYZiCUIZEhUG9cR0AGGAmHj5t6zPVXXvPGX/66uWn7kJqB3a0dZUMGKEX6Hdhhe/36Hfv29Rh6TdrqNZ/29PSYpllZWTVhwsTm5uaComAudgSgPlm+4rIzzrvhiZ+nXWf9lg0NDQ3bt21/8403Vn2ygnOOB3b2F+RrGu8GgVi+6tPlqz4FABORiCYdPn7eOedazCyqLDcjNikFyHv5YmBokBQaPBGiAmCKOOeGaQNA267d7yxa9PSTT3y4dKkvZaQoanPhBwFJyQgZgmJMklK9xVIAaN6955FH/mR/79of33BjPBmPd3dzBsqXOqliCIzhhg2bhJDcNC3OWDwRnz59Rl3doTrlX7jwLcZYPgOf1U9AZnLX91evWhmVNGzIkNFjxkw4fMKJx59w3NRj3lm0qLu7uyD89V3q0tuIxbhhIGMSgJlG0nG2NTUdevi4+iOPNAA544BECMQUAAPiwAiVZJIb3LAsy+BmMpFYvWr54w898sB9Dzzx9NOfbdkkGNrhkCLSy+sRkHOmgKSUoaKiiZMmHTHpyOEjRpRWlAFjjQ0N2xp31tUNnVQ/sWbQACsc8iQFUupkKBaL3H77bxsatmnCyXRcd8mSD2fOPCmTSU+ZchTnhlJqvw/aHywIhGKMbe1sv+Knt9T85+21w4ZW1dRY4UjznuaOva3IkBTlmtsPQg8QESilcbAIREVp2W2/uvWcC8/3fU9pElmvymMKgCGAwQ1mhYDAiSe2bd26Yf36NRvX7m5ttrntMZVw09w0AMDzvBzHLHwhpAAGs2affu33rpk6eUpZtAgZehTs3rl79aer//r6X3sScbIMV4hoNJLcl2aAUsmS4lhXZ/fqNZ9ma/NCSsbYypUrXNfxPG/cuHHHHHPM0qVLDMPIr5NkBUUkAJAzRtieSrZt3AgbNx5Q+cg2ohWG/ALQmFvjyw0+6rDDjp00hQnlJzIBCDCQAZrIDMMyTQbAZEZ0tO3duatx6+dbGxsaU8lkUWnJ4IEDh9YOi6fTn6xclclkQpGwHuLB"
    . "OZeBUCArikunTTvhjLlzzv/WBRErrKQgIQjAMOzDx449fOy4c8+am8qkLNsybTPjeEJI7YAi0fCKFcvb2loZY1m6wzCt1WtWb9m8eeSoUZZlz5t3wdKlS/LTzv1vHoERcAkCFXDGEXg2+kOuFFtASBeWjzjjjHPOTdO0LAsQWSxUNLj6iOOPsYoj+5fW+H5XW9ueXTuaGnZ0dexT0gMV2IZ19GFjo7GoK0VbvHtXR+v6jRtb97ZahoGISkrOuRRi/KT6Ky79znHjJ42qOzRWWR5I5aSS2WweAIUSQslAhmw7FLZ94XPGhVDay2oW+Z1Fi/T7zgrIssz4vviCV1+79dZfJRLxk046ubqyqqOrExgqOhDmEChSWSytSPVikF6JHJBY5BoWCIiQAIkhk0pKIQGAhGScjxo35gdXffeUWSe56cwnixfv2bN7e1Pjrp27At+vKC8vKSmtrRw4cdCQ4ljMtEyQIp3OtCa6m+NdOxOdO/c2t7a1pVKpcCiEjEslDYakaPYpZ1z3w+tUxvM9XyFxRG4YUhFnnHqpMzCYJKEUGIwroQJfIIKUsrg42tPT9dyzz2tmNhvmpZBTp53w1pLF329vtyyrbsSIc8477w9/eNDghshz/lmQDaDysvv98mMMDsTNuUoGAgIHIFCKqquqxo4ZWze0tqaqas26dY7wX3jplceeeMpgXPi+HYuVVFcNHDBg7PDhhxxySN3AgUVoGL4iIl+KwHPJZqEIq66I1oQPO9x37/jtHUopZAwZWpapzda2bCmlr4QVsZVSQIQMGEelJDIGvYSfguy79X2hem0lFov+5c3329rbdPuLkRtzUBGNzZo742/Llsw7/cxUKnXRRRc/+uifhBAMsov5DsB+BT0B2SxR9a187wdEiixuDho8oKKiIt6zzz7MLo4WXTTv/JPPOB24SYChkB0OhW1zP+soAUgKTookKSDgDBQhIuMMCYAbLXt3+a6nL6dXaOkv2r1LSbQKS5C5llrItkH0OkQEIPC0RhOEbFNKcd8DDxzQo6jx25IlS+ecdOrQ2tp4MuG6zpQpU+fMmSulNJjRb86ZF7Oxbx21IH0HhgxRSplOpqYfe/wZZ53JQ/aQ4cNmnXpqeUVlSSxWHI1EwiFiynG9IOP6GcdLOyKdUSLwlfRBClBKKgIWEHlCeL5QMvAzjl5DLpXqXVa3/60pAtmbmFMvJUr7YV329hwvCIRERClFSUnRxo0bli1dpmHt/hY83Xr00D33Hj5y5PqNG0J2yHEyP/zh9ZZl5RT4iyixAvKoX+pDVwgBobu7591Fiy457/zf33ffRZdcXDmgSklhEFkMUQQ8EAYDMhQYhIZCgxCQFCEgR8aIQEoGyJERKQZgcEMGAQAoKTStoAsQCrKj0RhyrVW6mzNXm1dKkVK6Bdx1hdZ30+SGad57z/0aPB/Qo6jZoxdffGnrxg2dHR2MsWQyeeSRk6+95vtCSTS46vU1dGAq+/fw2VnOiECCQtPY"
    . "vG3bFeefv2PNGlJS+Z6BjDgRI2AADJSSAAwIOXIOXGVpeVBEiiEwPbdCIgPgqDAL7aQIsgJSAABKawxDAGKEpAgIGKKSUpNK2deplOv4WlOkVKWlxZs3b3plwYL8Zb4HNIZ7nvfwQ49EY9H33n+vuLg4Ht/3/R9cV1VVpQKRI9DwC7L2gxQXe4uCgIBCCc+gFVs3/+iGH6dbOm1uCxlQr/btvy3GAHRza85Ac3aBmp4nAimziahO9XM5e+/SQyASwATuTwp6+SPGEEFI6XpBr/owy7Lu+J+7dDa/vxiVX2xExDfffHPBqwt++atfOBlHCDF40ODbf/NfpBTbPwkC+naO99vvcuDnwDkDBd/4xvE1AwYU19Rs3rnz2muvje+LW7adq8NoZcnvHEYCJCAptYZpeijnQJUijRg09s5xm7oBTDdPoi6HFaxdJwAAxwn0G5FSlpeVLP/kk1defqVglTgr0AXf91964YUN69bddff/VFZWdXS0X/LtS8848ywRCIMbf2eNqG8TCBEoAlIkM86f/ji/OFYydspkrCn/9e23tu9qPnAuC2bzdd0ioBVGU04E+Yt0EUAIFQQiq9m0n2/WCxAZQyBU0tAtkQdWWcj1hOcLhqAURSO2YZo///kv9FL2AyYZ9VtysCzr3nvvXrLkw9LS0ng8/vt77x82rFbztQXOuO8qjbyXT7qVlRmMcWYQWIgbPls3uLLmlZdeSjmZIcNqT5gx64P3P3CTDmNcETBinLKFCkCUQApRcSSDCSBiiFmSSq9fQyl8P9Ad30qX+bWjjEWjOjAAA2CkgBQp0J6+t3/UcQLMBjVVWlb6/HPPfrTs477zvPpv3zVNOwiCG264Ts/zq6ys+uMfH+5LMB5k9E2uqE9EjKEUMiCFJnd8f/v27eMPH/fnhx8ujkSbGpuOPGqqVIoU9DoX1ksTgvY8qIgRMkRUCkGPn9CuBz3fC4Sff0OaII9GdEcHKpLAKN8rAJFSlEi62o6klOXlJXv3ttx080/6jTnsC1bMq1A4sm7dZz/5yS1VVdWdnR3Tp8/43e/uEEJoBjK/ZbGA3Mg5ZgVAAIyhDNS06dOi5SUCqaikuKenh4gqykpv+fGNp59+aiqdNEMWKcWytWjijEPvxCoUiklgigyFQCBIKa1figDIdT0pJEJeqyQRABQXFx/wFgkYIgBIUgohnXGFkIyhUhQOW5Zl33D9jZ2dnf3OqPjiBnCCUCj88MPzn3rqicGDB7e27v3BD6675JJLg8DXw2fyyfN+m10IdeWPKaVG1NVddeVVTLGikmJgqJFvxkmPHD1y4qR6zg2DcSaVHq0kpciRiMSQGCgGAjQc4lofdEhLJOJBECBjueY2JRUaRmVlZb5e6zFWerWL6wvPEwxRKWCoyspK7733ntdef8MwjH4bD42DDu7ghmHceOOPRo4cVV9f397e/uCDDymlnnrqScMwpQzyGYx+7I4RKRBS2pb16J/+XFdXWxSL1lRWlZWV"
    . "A5FSkptm4LpIQIxrv6N6nW2uYZYYUi9mYZxpG0ECVAQA8Xg8CGQO/mm+ORYrqaysBMrrlSAABG7wTMbLZPxsx4gSAwbVfPLJsp///JcHGSXIDl4vte1QPB6/6qrLu7q6otFYPN4zf/4jF1/8bSECw7D6diEe8K8CIOCG4fk+IDY27YjHEzuadjRu3oKKIrFiVBAQBQwQFTElmJJKaPWi3uoYKCRJIIEBJ6knuyBjqG2qraWNAJABoUKmm4KgqqqivLxM+j4qYgQgSQIhR9cJtHS066msKuvq7Lz88u+q3LX+gRlmSlEkEtuyZcucOWckEvFQKNLTo2V0SRD4ueFBBW0L+ZZPUo0/4oihdXVAoBATyeQvbv3lN6ed+M5LCwyiSCTKDRQiUNpnMZQFA/JwP/g7oB2HMQBobGrKi6HZLtIBNQOKYkVZpoWIMeScOW6QSrs571laEk0mU2edNXfHjp19SeGvNuRNKRWJRNeuXTt37pmJRDwcjvT09Pzxjw9ddtnlesCxniJUiK0pO1BSKfWLn/3842XLLrv6asu2PSGUafz1oyWnnHf2SbNmLnjySYpnItFiy+AkAqVEb+DrbYkGzKI+RXpZig5kDJFE0NTUtL/kpbIAenjdCH1dpRE3gOP4qdR+6cRidiQavfaaa1evWaOP/BpmmOlxDBMn1jc17e7qSuze3eI44s4779FjjvU4sd71M6hL2szkwOCkU07uaO9UiiTR4hWfnPvtb/NoDAByix0mjxl7329/19zQoPU88DKZdNJx0q6Tdp2077p60bPnuJ7juG7G913fzSjf6+loHz9mNABwrmETmpYNAA/Mf4SInGRCuI5wMz1dPXv3dra2dra2djY3tyWTCSL63lVXhcPRoqKSL33wrzDkTc+qmjixvqlpzwFD3obXZWXEGSAayAzGkKERtSsGVX20dAkRZVLJtJNUpBTRBytXnn/l5Vau+RQAAAZXVX7/0kvffeWVZHtbFmiKwHWdZCqVTmfS6YzjeJ7ne44TeJ6bSZOUn61eVVFSxPXMFwaMMcaNUCy6et16Rcp30q6T6ers2bu3o7W1c+/ezubmVs91v5J0vrKAIpEoIo4bd/iSJR97nmpq2p1Muo2Nu84++5xsULQsDqgL27Gi6B2/+y8vlQoyac93fM8JnEx24ATRJ5+t/bcbri8fUK2thvca/OEjD7328u+89swze7Y1SN/dP9/G8wPXcZ20k0kl4j2K6PFHHwIAyzKAAxjADQMRphx3TNp1Pc9NJZNtbV056bS0tAWB39nZccEFF/790vnKAgqHo5FIDBFLSkr+/OcnPE82N7e2tXVlMv7DDz86cOBA7TLtUMi0zGLLXr7oXZIUOBnHyzhuxvMc33XcTNpNJYgkEW3aveu2e+8Ze9Tk3Kou/T8OMKi05PjJR/7oyiuefPAPn37wQeeOHWLfPlIiJ7K5Z5ymBYQMkbNwJAIAP7v1P4iooz0rmtbWzpaWjtbWNiLq6Gg7"
    . "5phjv5J0wuHoPzLsljF0HEcpefXV195++3+aprlv376qqqrm5ub58/9w3/33+q5nWmbUtG78/g++eepp446o57ZJDAUphsgBJYOAJEmKhWMAkHCcjz9e9sKCV9/529/2NGwDUQhJIgBVNTXVlZWHDq8bMmRIeVnZ2k8/XbDobR/0nAwjCASAqqiuXPjWO4eNGJlOZzhneqZ3OGyVlZUuW7rkqquvbWxs0rP5/tenAWuC0vPcKVOm/O53dxx33Al6lXRpaenqNZ/+4Y9/eOapJ0vKS9av+ay1cSdTVDustqiijGwutY4QIjIiKVVAAJwblhUmgNZ0ctWnq9997/0VHy9r2Lylo7kF1BeOgrYtUyil6Q7LtOZdcMF1190wvLZWx1YiIiUrK0tNy7737nt+8R+/FLoo9BVnS/9z45IZOJkM4+yG63984403xWJFelxyLBZbunRp087t3774Issw4x2dPR2dIStUOagGTUMoyRiD3mVy2dG2BKgoZJhgWpqu39PatmHrtuXLl3289MOmpqaO1vZEMg6BAICS0nIvlXE9BwCqqqovuOCCefMunDx5ius6rusCopQybBt68cfNN9/86quv5/qw/+UDtxl6niuFGDNmzI033nT++RcpUol4PBqNWpadSiVMg0fCtgGQiieA83AkhKaRbUEEyNIaOu8FAKkEkFLC4JybYc45AvgA8WSyu6erta09kYgX2eFH5j/0/LPPTp8+Y87cubmB25lMhnFOikwDqqsrAdkLzz1/y09+2tbW9s/8DMDXPLJ9xsyZ1137w2kzZzLG4/F9pmnq2zI4MzgXgReyLcs0ucmpdxhkrn8PlGIEgCRBIjCQgAQBETcMw+DcMHPp6Ouvv1lVXT1+/ATTNPXI9lisyPe9wPdrKsvBYMuXf/LrX//m/fff//9+ZPsBQ/+VCDyPlDr66KO/e8V35134rZ59+4zeYfW6s0TXpmzLBIacM4MzxrKlGMwOQpSATKFJSiIFSoEiCIQUQgpFQkilVDQak1Loof+RSKStre2NN14bNnTo7DPP2LRu/T2/v/+555//vzX0P396gBCB73tKqfl33nnVDTe0tLQpBYxh/kLh/CK+BsGcs+wsRM3wMy6V1PSz7vLI/eYG59yyLMuyPM9bv37diy8+//LLL7e0NM+YNq2isuqdRX/zg/+TPxtRKCYlwXMfuPvuy3/wAwDIpDOJZEoq7ZexYFV1fl0/S+z0ZZcIlJKWbbuZzLp1n3245MPFi99ftWqllIpzZtuhnKL8n/7hkb6Pfe2VV86ec+bEIyaWlVdqTXAyTiqZ7l1Wg5Btj8O+REJvQ5oeewUVFRUfvffut6+4Yvee3ZqH55zbdiinKf+/+emaPovEYeDAgZMnTz751JNGjR458tDDymJFpmmBYSgpGOeu63qeD5Ct0Gg7sywzHLKhdxWElP6+fcmbvv/9J156ORSOMADxL/mlqP9dDUIArpmHPABSWVk1buzo+gkTqgfU"
    . "TD1qimlbNTWVhxwyNPADhgZjKClgyFv27m1rawuCYMWKVe3tHWvWrN64cXNnZyf8a7f/BxDj2gnDf/oaAAAAAElFTkSuQmCC"
LOGO_CARD_B64 := "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAIAAABt+uBvAAA1YklEQVR42tV9d7hV1dH+zFq7nHZ7o0i7SG8XBFERqXZUsIAxRmNibEk0scQvvxRjyxfjp7Eraozd2GiaCJIoAhakg3S41AuX20/fZa01vz/WuYfDuRfS/PLk2/rwbDbn7L32rFkz77wzaw5WVnaDf+/BGPN9z3UdpZTve0SklFJKdvgYZ4whomlajDHbDpimpZT6N4/W+HcJBR3Hcd20EEJKoZQyDKO4uKR//xGMse7du/fu3cf3fUQEAKWUaVp79+4+ePCglHLHju2tra2JRIwxxrlhGIZtBwOBgFKUK3QiIqL/YwJiDBOJuOe5WlN69OhRUzNyxIiaoUOH9ejRo2vX7iUlxZxzxrhh8KO/ikIIpaSUsq2t7eDBuv3793/11caNGzds3rxpx44dWrMCwVAoGFKKtGZxzpVSX6+Y8H9jiXHGPd9NJGKe5yLimDEnT5w46YwzJgwbNrykpIRz7vu+EEIIHwD1/JumlRkQgn5B3/f0axORaZqGYZimKaWMRqPr16/75JMlS5d+smrVSillMBg65dRxWzZvkVJ+7WL6mgXEGEs7yWQiIYTfvXv3GTMumTlz1rBhw23bdl3XcRwAsG07EAgQgVKyqalJCBGPx2pra/X6yh59+lQXFhZyzsvLyxnjiOA4juu6ABAIBGw74DjOxo0b5sx5++233z71tFN+ddddTz/57Lz5C4QUWkxaXv8pAmIM0046mYgJIU4+eeyVV1510UXTKyoq0um04zi2bQeDQSJqbm7etm3rqlWr9uyp3bZt286dO9PplOM4qVQq74aRSIFh8EikoLq678CBA3v37jN69OgBAwaWlZUhYjqddl03EAgEg8HGxsY33nht2oXnDxk0+KsNG2c/+/ycuXOFkF+LYfp6BKSUjEZbfd+bOHnyzT+4ZdKkKaZpxmJRxlhhYaHneZs3b169etWHHy5at27t/v37OlmVnGc1SL+SaZrl5eUHDhzI/ViPHj1rakaeddbZJ500evDgwZZlxWIxIiooKIjFYoxhRXkp42zVylW/+e2Dy5Yu/9dV6V8XEMViUcdJDRw46Lbb7rj88m8QUTQaDQZDBQUFtbW7PvroL++88/ayZcuE8NutDBqG0S7Zo4xF7rlpmtOnT587dy4RMJbxbkKIjHMxjPHjJ1x66aWTJ0+trq5OJBLpdBqRESnDMCoryxBh3pw5v7jrnoaGRkT8p/XoXxKQEH5bWwsi3HbbHbfeekckEmlpaQ6Hw6FQeNWqlW+99cc333yjoaEh+8K5EsmOOE9xsrZMSnnuuecuX748Ho8zzoAAALjB9YkQQn++qqrqsstmzZr1jdGjx7iuk0gkGGMA4LqpXj1OONzY8Mtf3j1//nv/vOn4J+WKmEolWloaa2pqFi786733/lpKkUjEKysrt27deu2110yZMuHxxx9taGgwDINzzhhKKbNvRUR5Jlnf"
    . "kzGGDBGRERiMJ1JJYAgIyFjAtg2D+55vGAhKcUDt1w4fPvzEE49NnTrx2mu/vWnTpvLycsuyiMiyQvUNzaSgS0W5lH5WZ/89AqKWlsZEInbDDTctWvSXk08eU19/qKSkJBaL/+xnP500afxrr73ieZ5pmloRpJR5Cq51PldG2pcXFRcRESEoIEAERQwACUAqz/NuuPbak2tGSNfnBhdIipSUkjFmmqbruq+99urESeN/9vP/19raWlJSCkCADNDYX3eoubmxubmhw4z87whIKdXUdDgYDLzwwkuPPvqE53nptFNRUfHa66+eMeG0hx560Pd9LZqsvcgKIlci2fPcRde/X3/OOSAqgEAwkEokk9FY0DBqhgzu0bVrcTA87513hw8eLKRkBgdE/S0hBGPMNAzh+w/9z2/POGPc66+/WlJSYhoGET37/O9feOGlQMBubKz/JywRD4cL/iGj09LSNHjw4DfeeOvcc887eLCupKQ0Gm274cbrfvvAfycSCdM0lVJZgIeIedLpaHr0CSJKpS695JKvNm1yHQcASkpKEi3RaeecNWTQwAunXXDBOef0H9C/5rTTOND89//EEJGOkjVJxQAs02qLti1YMH/Lls0TJk4qKys7fLj+tNNOnzBh0pdffrF37x47ENBG6us30kJ4LS1NNTU1c+e+V15e3tzc3KVLlyVLPr7xput319YapqmUIqVyXUbeeZ4lzl5HgyOAyY3XX3v9RzffvO/AfmZyJdTkk8e++NKLn674YtblVwjho8EUUfOhw9Mvmr5iw3rDMLIzAaAxOSIBIiBjQog+1dVPPzV74sRJ9fX1ZWVlzc3NF100bf36dSVl5Sa3vmYNapfOyLlz3yssLIrFYpWVVU899cQ111zV0tJimqaSstOldJQgOrhb/UmOKHxRVVFx/733kPDGjx/X3NyUjsWfeeKJnr17lVRWlFZU+kSKMdM0C0pKk62tCz/6K+MZj5axYgwBAYCUIiJlmkZzc/Mf//hGUVHRpElTmpubI5GCGTMuXrLk4z27ay3b5oxrJPk1aJCUfnNzY03NyLlzFxQVFaVSqeLikh/84MYXX3xBA7w8FkIvLsMwsm6rU18OAIxzKcTowYNmXDyjvKryqquvFlJGiksWffDBgdo93/nOd4WSCqCptbWpuXnHzl3r1q3p3bV7z549L7j0Ys/1EBBZuy3L2HWFgIwhY8wwuFLKdf1vf/s7TzzxVFtbWzAYisWiM2ZcuG7d2uKSMsu0/yZE+tsCUko1NzeMGDFc6046nSouLrnxxuteeeUlwzCo/cjVGqVUcXGx53mpVEoveKVUR7XSDqh7t26/vOMn37jiCkD8YvnyUyZOINMQKUd5frigQEhx8HD93n37P1ux8q233xKe29TQWFpSEgiFLMs8dOjgvn379PpS2bVMOuLNTAzn3PfFlVd+a/bs59vaWgOBYDwenzbt3KamhhNPHLh9+w7G2HFopr+5xKipqWHgwIHvv/+B"
    . "lk5JSUY6tm1nIXyegjDGfN/3PC9rpDsCH613I0aMuGzmzJ279uyu3RsJFiyY896JAwYUV5T5KYcDcttSRLt37/3Dyy//aeHC7du3mwZ3PG/fgf2u51mmmUwm0+l0IBAQvqDsAgcAyP5NAwhr7dq1+/btu/TSmYlEvKioaMqUqVPHn3HHrbe/9+c/t7W1HWetHU9AiNjW1lxQEHnjjbeqq6tjsVhJSemNN37vlVdetixLSpnVz9wTfU5EWWeRKx1sP4goEAgMHDhw247tK9atGDV4eEtj0549O2pqhld17xZvbnU9L1Jc8Mmnnz30yCPLli5tqK9Pp5NtrS2pZNI0eSIeb2hoMEwjFAp5nielBCIGCEdcAgKgPlFKmaa5du2aAwcOXHrpzGg0WlpWVlnVNba3bkS/fgv+uvifxEHpdMLz3IceemTs2LHNzc2VlVU33XT9K6+8bJqmEELjl1zflJVI7sU8G5R7FBcXb9++fcP6dU0tTc3NzQs+eD8QDiSTcQBIp9MNTY2A/HePPLJj5w7LtmKx1kg49OSTj7/wwu+BiHNmBwLxeFxK6XkuEWHGjWV1FjRjqw+lVCgUevnlF2+55ftlZWXpVNKwrX3p2LYDtedNndSpBfgbApLSj8Wi1113/ZVXXlVXV9elS9fHH3/k5Zdf1LrT6TvnhZ2dUg25VxzHaWluSacd8tV7C/+0t/6gGQx40gcA1/eWLf80Hk+sXr2yrm6/66Y1XL7yyiurKit8X4BUPbp2GT54cEtLC2PImBYHyz46dwya9nYcxzTN559/7qknHquoqEolEiefPHZ/S+viTz7ixjHNUOdLDBGbmxuGDRv+8suvx2LR0tKypUs/ueaaqzRZ1/GFO6LBjsFERxAghBBCSKUYx8bDTSPHnmwabNy4U6q6d7Ms65VX32iJxua/N0+ROn3cuM2bNislPd//9a//23e9qvKK719/3f2//vWOHdu2bN1umAYA5rqL3MflDpIz9pcPF5027vT+AwbGYtHTTx8/b8H8urqDoWCoUxl1LqBEIoqIr7zyWo8ePZRS0Wj0sstmtLW1ImNSKdM0DYMrRQB0nGAi1+LkedNcOSKi8EVFVZd+gwZKz5t+wYUFJYV2IGQa5j333Nvc0piKp7Zu2VpcWNCzZ499+/aPGjly5NChTzzy6IzLZxUWFs6cOUso/4vPPvd83zQNRCRSWd72qCEhAAByJhUtW7505sxZlmUFg8Hhw0a8/fZbWZuVL4vKym55/5eXVwHAHXfc6bpq7966VMqbPmMGAATDoUAoGAwFQqGAaXJE4BzzDnb0gZ0duf/U7uztkSePnTBl6o3X3ugmUr7vuE5KSfH5Z8tnXjpj9LAhC/74xtoVn7c0HV7xxee+6zQePOjGYm4y6aaSvpMmoqVLPu53Yl8AsG3LMDJ310/JGQZrzyOZAHDBBRem0/7evXWuK++886eWZXft2qOjNPIFVFXV3TTNvn37Hj7cXFd3OJXy/vCH"
    . "l7hpFJeWRAoLguGQaRmI0L7s8Tgi6FRAWiJ5V8KRyKChw/r0rn74Nw8SkZNO+p6TTiWISDrpL5ct279zh/Qd10v7vpdOJYXnOOmk66TcdMp3nWQ8SkS1tTuHDBoEAJbBjyGgI4eW0ezZz6dSfl3d4YaG5pNOGlNRUdWlywl5Ask30p7n+L7/k5/8NByOcM4P1tX99Kd3KiFjsVgiHk+nUr4nssYnDyLmoqGOFjr74dzoTL+H67uH9u+VrjP+9HFABIhKKca4k05KRWNOP90KhVtboiotpONwhkoRQ6YUMc4UkGGa6VSiT5++c995p+8JPfT1Y7FO+rpSijH285//tK6ujnMeCkWuu+76psYGz3OO58UYY7FYdNy406+44sqWlubi4pInnnisvr6emwaRjgIR9H/H5dI6/jUvss/aTi1mpWRbNDaof7/ho0YAqXQ6TYoYQ8MwJGLKcUorKwuDBU5bPNkSVSk32RZNRuOBYIg0WwLATTOZjPUbPPh3DzzIjsT5xwsPOOeNjY1PPvlocXFJS0vzN7955WnjTo9G2/Ji/aP+4jhpALr11tuJVDgcXrNm1VNPP8k5V1KCIiQAIv14oiMwrFNf3lEcx5YoIDLO2Pnnn28FQ9u3bXPTDhqGUJKU4gwNjkr6iim7KFxYXs5DwWBBpK5u3+oVXwjfRwJGwBQxw0gnExfMvPSi86dJIZnBtDfLamquHiCilJJz/vTTT65ZsyocDiulbr31NgBy3XTnAuKcJxLR4cNHTJkyNRqNhsORRx/9ned5jDHKJHkJKOMdjqW6uT7+KDU5dljPkEkhhg0ZXF5RuebzLwzGy8vKhPCBABQBESiFRNwyzJBNnEkE4Dhg8KAdW7cu+mChbQf0dHHOgSMx/K8774wEg5TBfqjdP0C++9dY33W9Rx/9XTgcjkajU6ZMHTGiJh6Pcs47EZDneUKIb3/7O6ZphkKhL79cMW/e3KNzJpgXPWQ1JRdodAQj2T9zA5Gs51WkAoEA4+zQwYO9+vSp7ttXCGEg8xxHZ98REfS3FCmlGCJDBorOmDCxoaGh7sB+07YVEQllcdN3nVFjTz5r6lQliTPeDkRQW8w8fK+VaO68OStXfhkKhQzDuOaa72h01omA4vFoly5dpk+fEY1GI5GCN954zXVdznmnsUL2nfNga5Z7b6/ZULnwvxPCDBEBhBCO637v+uuLioo832OMoZC7t++UpDSbQQRKKWTYnlZWSslPP/u0tLSspaUFGEcADYGACDj/xhVXcACQCggIICudvDEQEefcc73XX38tEimIxWIXXji9a9dusVhrvoAYQ993Z8y4pKKikjFWW7tLYyfZToPl5WqyapLrufNGoNUtT7J5JhARDcMUnph52WUGYltzM0MmfPHVho2ffLxECtGurYCISpLBuK6DObBv35pVqwYNGhgIBIBUZjyMAaKU/uTJk6q7nyCU1Am1rNXuaC6lkIj4zjtv1dbuYoxVVFTOmHGx57ms"
    . "nWZiWgmTyYRhGJdf/o10OlVYWLR48YdNTY15VQB5pi7XGOeG8h2VhY4+9GIlxpEZihgiK4iELrnkko0bNkRCkSUf/GX/rj0v//GPW3btCgYjQICIQICAlmnt3LrzL4sWIzMaGpqKCoq6d+leUVElfImmRQx9KZAz4fullVXjp0xUAJwhKtnpYm+n2RQzWGNj4+LFizSfM2vW5aZpJpOJDE+pwbXrOjU1I4cNG+E4jud577zz1t/0351OSJ5JzguINFbIYlpSyuDous70iy/2pFy3ZfMjTzzxxrtvf7jk4z+8/JJiYNimVBIRAYFxlkwm7rv/3kP19QDQt9+Ac6dd4HhuKBSSUpLMixDhzLPOzJx18A+dnAO+9c6bnuc5jjNs2IiampGuqwERGu3ry5s4cVIwGFBKbtq08bPPPtU8W6frK1d9sgHesfx9rpfMmFjOpZJKKsYYKBUOhWbOmvX0s8/W7qytP1hfXlG+esvGaDQ6YMBAAJBK6ZEYptnW1tq7T68LZ1zo+35pWVl5ZWXKcxSRzr4Bqhy+RQ0bNiwcsB3HxSOOpZMZBQSlJDD8/LPPNm36asCAAcFg4IwzJqxc+SXTiBQAXNdljJ1xxgTXdYLB0MqVXwohtKvLsyzZFZdLFRKR5hmOx0vmUGhKKSUlECGCL8UPbrrp3bffmT9n3vq1G2Lx5Nr1GzZv3hyw7Imnj9c2S8+TEKK4tOS2n9waDAYVgCLmSmnaNjc5MhYIBQPBsE7GMc6k8Pv06t23b7UEYJiVWmcahDqjzaSQX65cEQyGHMeZOHESY0yX2jAAcJxUVVXViBE16bRDRIsWLcxOfp5EdIR11AMYIAMi2SlXkB1QVppSSqmURgxK0TnnnL19584XX3wpmUikUvFoa7ObTvqOO2rUyOEjhgvXRURuGAyAFJmWGQgFlZRICkGhUl46zRhPxKIvPPfcxx//1fG8YCgifSV9FSosGj5sqC7nytWgfCUiQEAEBgAffriQiBzHGT58eFVVleOkdFqBC+GPGjW6pKQEEZuaGtevX9ex7qIjLM48jGXsWMcwIvfkqOwYEQAqRbZt79y5a+68echQCE8IL5mKMVAAMPPymYZlkRQ6EkFCACJEAjQ4ByURpB2wI5EC33Ovv+57373uunPPPf/sc85d9umnhmV5ngBko4YPz1tNnSx/AlKgpAKADevXNzU1ImJJSemoUaOF8A3DYHpWa2pqOOe2bW/btrW+vj4XSh7LvvzN6oZjfQsROWeMMcdxdu7caZomEEmplFKIzPOFbVt9q6sBgABsZqAipXGwymAaAOCB4OpVX95//31TJk96e+68YMAGgM+Wf3rjjTcI3w8Fg0A0ZNhQBqCEhPago1MiTSsW57y+vn7btq22bTPOa2pq9NgNXQo4aNBg3xe2ba9cuVIppXnVvNfTtiD75noBU27uDrMM2jFtdm7VV4YtEwIApFQaSxFBdd9qACBSQspoU0tZVaUE1Y7BgUgZpvXV"
    . "+nXnT7vgcEMjANiW4fk+ETDOdu3ctXLFl9V9T+zarUvffv3LiiJN0QQyTqAJANUJ4qUMYvR9f+XKlePHn+H7YtCgwUL4qVSSeZ5r24HevXv7vg8Au3fXZsXRMY2Vz2PkSYDgWD41z1rnVQkhAmOAiFKq6ure3bt1M0wTke3aufPgvgPMMAhRu7Os9/zVXXcdbmgMh0MA4HpCSgUAikgq+Y1vXvHYY48Jkl27dj2h2wkEwBARMDs9HX1x9qX06/vC79mj50WXXHzG1ElMSlFYWNCtW3cphRBy27atOkg5DpVxVFShkKlM0hfwqLRPx5i+I7GfNZ86XCosLOrRs3dza+uwYSNqd+168aVXIiVFREpKqRAESSAZCAS2b9v20ZKlpmkkk6nTTx+3cOEHgwYNJKJgIOC7Xp/q6lt+dIvrOMFIYZ9efQCAkHLH3PF1ss6nLRWTUrqu27dv33lvvjPtrLOZ7/t9+/YrLi4BgObmpj17ajtVn06rNYhIL+326gE8juU6VtFUe/E42Xagd+8+W7dsDYfCrudedtnMuoMHu/boobP+DLB9YGzhwkWt0TYAKC4ueu6554ggGo1y00in0oXFxb+6995u3bsBEDI+fNjwjIcHOA6LlcmVm+bqL1c2NTVahkGIn3642IqnWAZQM4aIvu/H47HsDXNeIJ+7yFWTvOxYXmSfZ33ydJBIEZFpGuFwqLSs9MCBA/X1hyoqK6/59jVr1q6ZMnVqqLBAEhmcIwDPRK7qk0+WaJTQt++J995737nnnnvw4CHh+aeMO+2jjz+aMnFiKp1inANAzciRRzms9tF2rIDxfV8KIVxPUwiMMbKNtlQMGOMzZ16eTLqNja1r1mwoKIggwnHY3Fzimbez9lkGWt+aay91NC3dkaXOPiUSCUUioVAojMi5YRYWFwHA1ClTE7GE66Q9N+U6Kd9zXCfle6kD+/d069oFADg3kBkAYBjWqFGjn3jiyXQ6TUSJZNJ33UQqrqTcsfGrokg4jwjXNQF6kHn4rqioaO3ajS0tsbq6ww0tLXWH6g2lZO/evTnnpmnt2rUzHk8YBpOSOg21ju/788LUY1HC2pprMgsBiEgDVCJAYIyxWFu0T3Wf2c/ODoYCnucYhkFASikh/FC4cOPGjQcP1U+eOPmyiy/ZtWvn+i2br776qkkTJnbr2iUei4GQtmGAUpxxKf0ePXtW9+mzduNXeaPVTFDWXWimxDCMaDS6c+eOvn37FhYUvPDSi7v37jZ03VguF0GERye8MvkvytCJmbfO3rqjXI4TzWaWGOqkGumEaLstI2Tge26vPr0WLFhQXd0nnU4x/WJERGQYZlNT44MPPjz+tNPf/OOb5WXlrfUH7bKiUDDsxuMHD+wvKS01TU6kSNMUUtqFBaeMHbt241fIGBIppbLhvB6/YfBAMBCLxgHANoOkFOdMx4CFkbBwkpqyYceP2rO+RtP2x0KDuXRHHvWRl/DAI7DgCGjQYdegQYMWLVo0"
    . "dMjQVCplcI4ZCpwM03zwwYeqq08sKS17+JGHI4UB100UVJYxxFQ8norFCwuLdDIH20epbzxlylQAAFIZ1jXHOJqmiYzZtj1mzOjuXbun3bRUWm5k2/amzZvee+9Pxt8MMjuIhhBZrvXNy0HnXskrGjrKNOr1pfQnVdY0PPDAbwb0G5BMxg2DM0BiGh6C57qRSOSuu++97cc36zJoYiCBGGOAMlJYyCyDiHSVEDKmNKYU4tRTT6kqK2toaWYMFRyx1hqj2kHb8/z6Q/XXfvuasuLSF994ybJMApBSVnTpkvI99jdtTY6+wN9fSduRgcwKiyGDo0LqDARljE2eMmXSpEmumzYNI6M52S8i/vCWH97245sTqWQqnQYwGXKGCATcMtE2s2QT55yAkCHnzPfcbj17TZkymQgY53m5ZaVUKp0W0nfS6aeffKq4oOCLvy4ZVTMymUwanPue36NHDyNbAw8Ix4rIc3cpdVrRknslG4jksfdZ1y6VzPKEBBk2p3v3Eyorq2687oZIpCCdSpiGCUiKMgkszjkq5bkukTI5R0DGgAhJCURGAEpJlikJQkEKUWNXkkIA4tB+/fXMgMhny5AwmUi73CspKvr+7T8KlRadN+2C1mgsGo1dc/XVs2Zewhjje/bWSiF9z+vb98RIJCJzyjFzZPR3JQvzUivHUk88UukESqn+AwcNHTb8vLPPvvCCC9xEyjAMRYoICDOS1TEUZ4wzzhAZQyBJJHVKh2lcg0gI8kiMTtp9ExAJBQCkU3s5Vf2Zi8AAoC0eJQa/efjhppZW0zR94ZeXlURCQcY537Nnr5CSiCKRiGHwjoW7Okg8/oLqNMPRKTLIBUGcczsQsEOB3j17/Oyn/9Xa2KidCCKqDvhTtVNu2btjOwOX+YpUDBF1DTUqSRKBUMKBugNHUhQ5BeyMscKiQsuyhBAImE6nE/G4EEJ7BpPxPTtrGQAgy/g80zQjkYKOWYpO4tJcR9bBSXUMTfIyZZpjCQQChmE46fSwQQMf+93DzfWHuckVz84wQuYO7XAuy/DiEWopG0JnSwJJpxtJCvK5ZcTr65csWwoIqBSHo3ywdvvV/U48eexYTblIITKIXz+FITNNc8eO7W1trQBQVlbeu3ef4+DAzAsTaF0lBEWkOqsSygXiHdUtHA6feebU0tJSKeXDDz/82quv79q8FQBChRGh1DFqHzqfrcw0ZMSW4Xy0C2MAhhV49HcPb9m71zAN0gxC+xrUmplIJMIFkRuvv+FP8xcMGzKksLCwoqJCby9Gztdu2Mg4NxKxxMG6Os4Nw+ADBg7Mlw4CMC0SpTkrhmgAMAJCAoaEqI5+pU7Xmj6xLCsYDJ1zztmu4zQ1Nj756CPfuuKKP8+Zrzjv3rdaSeCIgIqAkBCVXrYakbYnSdsx3lEGDnU8yxShkiSVsoKhgBl85P5f3/vwQwbn0leSQCAhADLkiBzRDgUZ547n9ejWbeqkqR8uWnj7nXc4jsMY44wBQEP9"
    . "YWZZtuu6e/ft1b6sT+/qjsnio0hLUpKUbzIwuaW4oYArwmN7+jyDLaUEoPnz5y9dtrysvHT/oYMLFswfOGzIwKGDXdfR6w+YRtW6njez3rXaZ61YO/7OMHY6TlFScEWBUDAYiqz8/IvpF1zw45//jFsW5WidnmefpC9lOpEcOGiQ47mHm5qE55VXVsy4aIbrupnl7Ptr1qwz9Lb9zZs3TZ8+w3HcMWPGcM4zFfIImmfKxh4SwLJMy7bjsYQACQAmNwwjg6yyqYu8fFH2XIc/nucpoksuvfjuu+85oVu3ouKS9rwQCs9niIqU9iya887zjyqjO+1j0qy1IoNDIBgCUl8sXTp79jNvvvV2WgjTND2hjuT4M3dQJWVlU6dOWfHp59s2bbrgkku2bN4MF10kSMWiCYZMSllYVNja2rpj5y5Du5K169bqetoBAwZ26dJFlxVlXi+7/gkQUQk14fQxk8ZP3riz9pOVn+/eswtcL7NNknOVkynLYz+yiWwisE3jwJ69Lz73/Kljx3br2hWBmpoaObKRw2uqenb3NJurABEp67IQsZ32JdD0YSYxZ9kWY6ZKxP+yaP7Ts2cvWvxh0peco2GbvlCGRIZA7X4dARlgKBgcN/bUH19743t/+vOW3bt6VHVtqW8s6dFFKdJzYAftzZv3RaNthpTSMMw1a1e3traaplleXjF8+Ii6urq8pGDWd/igvljx5TXTLrv15Z8nnfTGrV/t3Llz145d77/33qovvuSc49GV/Xnxmsa7vi9WrFq9YtVqADARiWjU0GEzL7nUYmZBeakZskkpQN7OFwNDg6TQ4IkQFQBTxDk3TBsADu/b/+Hixa+98vLS5cs9KUMFYZsLz/dJSkbIEBRjkpTKqdmo23/g+ed/b19/0+233haNR6MtLZyB8qQOqjTU2rxlmxCSh8MFnLHm5sZJkyZXV5+oQ/6FCz9gjOUy8Bn9BGQmdzxvzaqVYUm9evQYOGjQ8KHDJ44/Y9zYUz9cvLilpaVjQWseQM+kkhnjhoGMSQBmGvF0esfu3ScOHVJz0kkGIGcckAiBmAJgQBwYoZJMcoMblmUZ3IzHYmtWrXjp2eeffOzJl197bf3WzYKhHQwoIp3zQ0DOmQKSUgYKCkaMGjVy1El9+vYtLisBxmp37txRu7e6uueomhFV3bpYwYAryZdSo5xIJPTgb39XW7vL0Dv9SdGyZUunTDkzlUqOGXMy54ZS6ogNOuIsCIRijG1vavju/7uz6tf39e7Vs6KqygqG6g7UNR6qR4akKFvcfhx6gIhAKY2DhS/Kikvu/dXdl3xjlue5SpPIei8YUwAMAQxuMCsABOlobMf27V9t3Lh207r99XU2t12mYk6Sm4bOEmc5ZuEJIQUwmHrBeTddf+PY0WNKwgXI0CV//979a1av+fOCP7fGomQZjhDhcCjelmSAUsmiwkhLc+v6DesyvTukItO0Vq780nHSrusOGTLk1FNPXb58md6xdjQIBCAS"
    . "AMgZI2xIxA9v2gSbNh2V+cgUouW7/DzQqAMIvZF5QL9+p40aw4TyYikfBBjIAE1khmGZJgNgMiUaDx/au692+7bttTtrE/F4QXFR965de/buFU0mv1i5KpVKBUJBKaWO3aQvFMiywuIJE86YNmP6rG9eHrKCSgoSggAMwx46ePDQwUMuvWhGIpWwbMu0zVTaFUJqAxcKB1evXt3Q0MAYMzS9ZwdCa9au2bplS/8BAyzLnjnz8uXLl+WGnUdmHoERcAkCFXDGEXjG+0M2FXuszYXte8QYZ5xzbpqmZVmAyCKBgu6VI8efahWGrJySt+bDhw/s27N7557mxjYlXVC+bVin9BscjoQdKQ5HW/Y11m/ctKn+UL1lGIiopOScSyGGjar57tXfHjds1IDqEyPlpb5U6UQ8E80DoFBCKOnLgG0HgrYnPM64EEpbWc0if/Txx7qsw9BXw+HQ4fqDc+fNv/vuX8Vi0TPPPKuyvKKxuQkYKjoa5hAoUhksrUi1Y5B2iRwVWGQLFgiIkACJIZNKSiEBgIRknA8YMuiH133v7KlnOsnUF0uWHDiwf9fu2n179/meV1ZaWlRU3Lu864huPQojEdMyQYpkMlUfa6mLNu+NNe09VFd/+HAikQgGAsi4VNJgSIouOHvaLTffolKu53oKiSNyw5CKOOPUTp2BwSQJpcBgXAnlewIRpJSFheHW1pZ335mj05lGe5hHp02e/MGyJT9obDRNs7pv30suu+zpp58yuJFbsJcB2QAqJ7o/Ij/G4GjcnM1kICBwAAKlqLKiYvCgwdU9e1dVVKzdsCEtvLfemfPiy68ajAvPsyORosqKrl26DO7T54QTTqju2rUADcNTRORJ4bsO2SwQYpVl4apgv6Ge8+BvHlRKIWPI0LJMvWxty5ZSekpYIVspBUTIgHFUSiJj0E74KcjMreeJbGwciYQXLVzW0Nio6zONbJuDLsVlEy88ZfGnS2eed2EikbjiiitfeOH3QggGmc18R2G/vJqATJSoOma+jwAiRRY3u3XvUlZWFm1ts/vZheGCK2bOOmvaecBNAgwE7GAgaJtHWEcJQFJwUiRJAQFnoAgRGWdIANw4eGif57j6cXqHlv6iHbB1NwOtwhJktqQWMmUQ7QYRAQhcrdEEtmVIKZ559vmjahQ1fvv88y8uPuu8nr17R+Mxx0mPGTN2+vQZUkqDGZ3GnDk+GzvmUfN33TBkiFLKZDwx6bTx0y66kAfsHn16TT3nnNKy8qJIpDAcCgUDxFTacf2U46XSbjItkiklfE9JD6QApaQiYD6RK4TrCSV9L5XWe8ilUu3b6o7MmiKQ7YE5tVOidATWZYaXdn1fSESUUhQVFWzZsmXFF19qWJtbxMmEEC8+9fTQ/v03bvoqYAfS6dTNN//YsqysAh+LEutYUd9JOZ5mixFaWlr/unjxVZfNevyxx6646sryLhVKCoPIYojC574wGJChwCA0FBqEgKQIATkyRgRSMkCOjEgx"
    . "AIMb0vcBQEmhaQWdgFAgMxYQudYqXZSZzc3rHey6BNxxhNZ30zQM03zmqWd1Q4ejqlw1ezR37vydWzY3NTYyxuLx+Eknjb7pxu8LJdHgqt3W0NGh7N/DZ2c4IwIJCk1jy44d3501a8/ataSk8lwDGXEiRsAAGCglARgQcuQcuMrQ8qCIFENgum+FRAbAUWEG2knhZwSkAACU1hiGAMQISREQMEQlpSaVMtOplJP2tKZIqYqLC7Zt2zr/vfdzt/keVRjued5LL74SjoQ/+vijwsLCaLTt+z+8paKiQvkiS6DhMaL24yQX25OCgIBCCdegL7dv+dGttycPNtncFtKndu07MizGAHRxa3aBZtcFanqeCKTMBKLtWyOylAhrT+QJYAKPBAXt/BFjiCCkdFy/XX24ZVmPPv6k3ot8JBmVm2xExIULFy1YsOCuX/0inUoLIbp3637f/f9NSuXuEOlYOd5pvcvR14FzBgpOP318VZcuhVVVW/buvemmm6JtUcu2s3kYrSy5lcNIgAQkpdYwTQ9lDahSpBGDxt5ZblMXgOniSdTpsLy966Q35fp6RqSUpSWFq1auXDDvvbxd4ixPF3zff2/Be19t2PDw7/6nvLyisbHhqm9dPe3Ci4QvDG78nTmijkUgRKAISJFMpX//zOzCSNHgMaOxqvSe++5u2FfHOcv7tvaUjLGMwmjKiSB3ky4CCKF8X2Q0m47wzbZlZuwOoZKGLok8OstCjitcTzAEpSgcsg3TvOee+zWXeFQno46vZ3AjFAo/+ujvli1bWlxcHI1GH3/0iV69emu+Ns8Yd9ylkTP5pEtZmcEYZwaBhfjV+g3dy6vmvPNOIp3q0av3GZOnfvLxJ048zRhXBIwYp0yiAhAlkEJUHMlgon2nEertQQYHRCk8z3e1FdVpfm0oI+GwdgzAABgpIEUKtKVvrx9Np309E4xRcUnxu++8s+LLlR37eXVevltQUCyEuPXWW3Q/v/Lyimeeea4jwXic1jfZpD4RMYZSSJ8Umjztebt27Ro2dMgfnnuuMBTeXbv7pJPHSqVIQbtxYe00IWjLg4oYIUNEpRB0+wltetD1XF94uQPSBHk4pCs6UJEERrlWAYiUoljc0etISllSUlhfX/+LX97Tqc9hx0rjFJeUbdiw/qc/vbOiorKpqXHSpMkPPPCgEIIxnu2X2elu3axhVgAEwBhKX02YNCFcWiSQCooKW1tbiaispPjO228777xzEsm4GbBIKZbJRRNnHDBjs1EoJoEpMhQCgSCltH4pAiDHcaWQCDmlkkQAUFhYeNQsEujNY5KUQkimHCGkrhMPhWzLsn/6Xz9rbm7utEfFMQvADW4WFhY999zsV199uXv37vX1h374w1uuuupq3/d0u6tc8rzTYhdCnfljSqm+1dXXXXsdU6ygqBAYauSbSif7D+w/YlQN54bBOJNKt1aSUmRJRGJIDBQDARoOca0P2qXFYlHf95GxbHGbkgoNo7y8PFev"
    . "dRsrvdvF8YTrCoaoFHBGxcVFTz319J8/WGgYRqeFh8crXggGI47j3Hbbj/r3H1BTU9PQ0PDUU88qpV599RXDMKX0cxmMTtYdI1IgpLQt64Xf/6G6undBJFxVXlFSUqq3YXLT9B0HCYhxbXdUu7HNFswSQ2rHLIwzvUaQABUBQDQa9X2ZhX+ab45EisrLy4FyaiUIAIEbPJVyUykv4wRIVnapXLlyxX33/fdxWgmy4+dLi4tLo9HYddd9p7m5ORyORKOts2c/f+WV3xLCNwyrYxXiUX8qAAJuGK7nAWLt7j3RaGzP7j21W7aiolCkEBX4RD4DREVMCaakElq9qD07BgpJEkhgwEnqzi7IGOo1dfjgYQJABoQKWWbvUkVFWWlpifQ8VMQIQJIEQo5O2tfS0aanrLy4pbn5pptuUdln/VM9zLC8vGrr1m3Tp0+LxaKBQKi1VcvoKt/3ss2D8soWclc+STVs5Mie1dVAoBBj8fgv7r7r/AkTP3xnrkEUCoW5gUL4StsshjJvGzUeAX9HleMwBgC1u3fn+NBMFWmXqi4FkYIM00LEGHLO0o6fSDpZ61lcFE4kkpdffuW+ffs7ksL/WJM3RCwrK1+3bt2MGRfGYtFgMNTa2vrMM89ec813NGrQXYTysTVlGkoqpX7xs59//tln19xwg2XbrhDKNP786bKzL7v4zKlT5r7yCkVToXChZXASvlKi3fG1l0QDZlCfIr0tRTsyhkjC371795GUl8oA6D7VffVzlUbcAOm0l0gckU4kYofC4R//6Lb1GzZk+3z9S13wGDNKS8vXrVs7ffoF7TJqeeqpZx966BFE0FuDsstN221kSJx5wp961pmTzpjQtaLy+aefXrTko0u/9S1pBgCAc/jo8y8uvuqq08ef8fgDvz24Z38gXBgMFnBEIYRoz7LlVCpQpik3ok6xRdvaanftyjxRh4jIAWDcuPGZ6BIREWJJJ5nysyuroCBQUFD4o1t+/MHCRbpH1tfW5M33vdbWphEjaubNe7+8vOxIk7cbr9+9u1bXrChFBiAgSCAetIqKChe8Nee0caenkwniEAyEAXDZqlVPzX567h/f9BJJxhgpRQDdK8qnn3f+xRdddPLp4yIVlXq3pCuEL6RWHMY4YwhKMsakFLYd2LB+7eRJk9riCQVEAAwYILOC9meffVEzbIhw0gowmXQ9XwfroJQoLyu2bPtHt/z4jT++9fdI5x9rE8g5t+3A3r17Fi9eNHr0yQMHDjp06ODAgYMuvfSy/fv3bdq0iYgMyyIpAVEpCgUCP//JnTMuvIikQJNzZOQL3/f69up98YUXnT3t/EAouKN2VzqRRIBkKrVi/fpX33xzwfx5m9atlal0JBQpKimyA0HTNE3T5EoBSQVKKen7vhUIfrjwT6+/9a5pGpIUMGDISYmRY0bffuutoKTvy3jCFe2pSgBVUVEST8S///2b58yd/3dK55/p5aqUamlpKCgoeOSRx6+44ptNTY2G"
    . "YRYUFLz22qu//OXPDh06hIiWbSslg8AW/+nPJ0+eLLy0YDrnjkiglAIl7XAYgG05sP/dOXPeeO3VzavXgFR6zSsADlBVXNT3xBNPqqk5adTowUMG9+rVq7i4mBdGADM7kS6+4Ly5739gWYYvJCAG7EA6lfrZ3b+875d3NzW2CKmyNfycU2VlRXNz46xZ39y4cdPfL51/utkttbY2+753ww033Xffr03TbGtrq6ioqKurmz376ceeeNRzXNMyw6Z12/d/eP455w4ZWcNtkxgKUgyRA0oGPkmSFAlGACCWTn/++WdvzZ334V/+cmDnDhD5kCQEUFFVVVlefmKf6h49epSWlKxbvXru4kUe6Cyo4fsCQJVVli/84MN+ffsnkynOme7pHQxaJSXFKz7/7OYf3b5nz95/SDr/fDdgREwm44lEbMyYMQ888OC4cWfoXdLFxcVr1q5++pmnX3/1laLSoo1r19fX7mWKevfqXVBWQjaX2i8QIjIiKZVPAJwblhUkgPpkfNXqNX/96OMvP/9s55atjXUHQR2zFbRtmUIpTXdYpjXz8stvueXWPr17H4nISZWVFZmW/dSTT91//2+ETgr9g72l/7V2ydJva21BBrf++PbbbrsjEinQ7ZIjkcjy5ct37931rSuvsAwz2tjU2tgUsALl3arQNISSjDFo3yaXaW1LgIoChgmmpen6A/WHv9q+Y8WKzz5fvnT37t2N9Q2xeBR8AQBFxaVuIuW4aQCoqKi8/PLLZ878xujRYxwn7TgOIEopg7ZRWlZ68GDdL35x1/vvf5Ctw/63N9xGikXbHCc9aNCg2267Y9asKxSpWDQaDocty04kYqbBQ0HbAEhEY8B5MBRA08iUIAJkaA0d9wKAVAJIKWFwzs0g5xwBPIBoPN7S2lx/uCEWixbYwednP/vmG29MmjR5+owZ2YbbqVSKcU6KTAMrK8sA2Zx359z1q3saGhr/lZ8B+Jpbtk+eMuWWm26eMGUKYzwabTNNUw/L4MzgXPhuwLYs0+Qmp/ZmkNn6PVCKEQCSBInAQAIS+ETcMAyDc8PMhqMLFrxfUVk5bNhw0zR1y/ZIpMDzXN/3q8pKwGCrVq184IGHli5d9p/Qsj2n6b/rJONRKcQpp5zyve9+b+Y3vtna1ma0N6vXlSU6N2VbJjDknBmcMZZJxWCmEaIEZApNUhLJVwoUgS+kEFIoEkIqpcLhiJRCN/0PhUINDQ3vvTe/Z48eF1w4betXm5+a/ey7c+b8ZzX9zy1ecJx0IhETwp/90EPX3XrroUMNSgEi5G4Uzk3i6+3snLNML0TN8DMuldT0s67yyP7mBufcsizLslzX3bhxw9tvv/nuu+8ePFg3ddKkrt16fPTxEl/8R/5sRB6kdD3XS8Qe+58Hr/nBDwAglUzFE0khlY4n83ZV5+b1M8ROR3aJQClp2baTSm3YsH7psqVLlny8apXegmxHIoWcG7ktHv5Df3iko2363tVXnzftvCHDh5aU"
    . "lmlNSKfSiXhSF69q7dAlwx2+m6FKGUPGEIDKyso+/eiv3/rud/cf2K9/usay7EikIPsjP/9nfrqmwyZxqKqqGjVq5OSpk07s37dfdd/icMQ0LTAMJQXj3HEc1/UAMhkavc4sywwGbGjfBSGlF40m7vzhD1+bOy8cKTQ5l4rgf//439UgBOCaecgBIGVl5QMH9Bs+dEhFZeXo0aNMy6ysLOvW/QTf8xkajKEknyGvr69vaGj0hb969drGxub169dv3bq9ubkZ/r3H/wclYiUgwlJGtwAAAABJRU5ErkJggg=="
LOGO_ICO_B64 := "AAABAAUAEBAAAAAAIACZAwAAVgAAABgYAAAAACAAoAYAAO8DAAAgIAAAAAAgABoKAACPCgAAMDAAAAAAIAAcEwAAqRQAAEBAAAAAACAA/x4AAMUnAACJUE5HDQoaCgAAAA1JSERSAAAAEAAAABAIBgAAAB/z/2EAAANgSURBVHheVVNNTFxVFP7ufT/zxzA4D+lM3Wi3tki0dLCkFlqxGavQQqIhacGQyOgCSEOCFFzRNilkqiUpEgGDrY0m3ZmqxAWkkjA4MOCChTYGSuOMA8pISGfgDe/nmPdKTb13cW/OPd895zvnOwyPF+Ock2maCIfDladOvdnKOT+uqupznHMYhpHyeNw/NTa+O6IoysyejTHGiD0Fdl69OnBNlh2t8fjP4sJCAslUErIk4WioAs8UF6O5qVkPBIMjZWWlnYwxlYgYiEgA4Lz+6eBkd3cPOZ1OE4AOwKw5cZLGR0fpxvXB/2xdXR/R2NgXk/TggXMPC/RdujJ08WIvAchbVGRZJiu90+Ewzc3OUs0bNfRhJEIej9v26eu7TF/f/mbIJl9b2xCKRj8xJUnSBUEwrQ9EUbQcqer4a7Sr7tDmxt9EpkHjY6PEGTcFQdD7B6JmQ0NDiB87drRtdjbGNE0D44wRkUULgiCgwFOAmZkYBElCZiOD91pacOCF55lhGEjMz7HDh8vbuCiKVYuLi2CMcasLYIB1ioKA7ycmEIvF4C304dKVy2hrb8eRI+W2byIxj0BgfxVX1Xwgk9mwojLOOJi1GYOm63YmXl8h/lpP45+NDM6cOYtDh0rttmcfZeH1FgTEPR3YS9et4sNO3wLX1dYiEokgl32EW7dvAeDgpmG/uT1uKIoCLknSmt/vt1KmstKX4HK7bApFRUV4v6UFsuyA1+fDdm4bP078gPYLFyCKEn3QGsGrFRVrvMBbeO/lV8phmIbJOSBywaag6xq+vfsdVpaXkfz1d3w2OIi36+rQdL4ZiUTc7OjogGGY97CSTofGv/zKZIzZ4hG4QFYr6946Tetr65ROp0jbUWnk82HaFwgQEZlEpGezOTO3tRXiB4LB+J+p1HBXV7elSI1xZlN48eBBlOwrsSoN0emAJEoAEfLqjmaVKa+qwx6fL84tOfb2dncGg/uneno+lq3o586fMxwuFw0P3cAvCwls53KUmJ8zlGeLyeF0yZubW1N+xd955w4J/xumgYHoNQCtTY2NohIoweTUJO7/dh+7+V0sr6zgbH29/vrJEyPT09Od1dXVj4fpqXG2r+/U11cmV5M3c9mdVUMnjYi0hw//WO3vj95cWlqqfAJ4Av4XoqGfzHn/NBsAAAAASUVORK5CYIKJUE5HDQoaCgAAAA1JSERSAAAAGAAAABgIBgAAAOB3PfgAAAZnSURBVHhedVZtcJTVFX7e993sB8luIHbzLSFqko18DFihYiWE6qoEQ8tH4iCl0KFOlWpq/9CxTB1IE2h1pj9QK0UddZwhEjRjxxnCkISNkm0R"
    . "RaBJSz7AtEogZJPN7rLZfXffj9M5d5NtYNoz887dO/fe55z7nHOeuxJus7q6OqWtrc0wDINXFnm93roHHvj+I3l5eeUOhz2HCFDVeHBiIjjY3e3r9Pm6jgHo48189tixY+LgjEmzJ7M2lG3fvuOlmpqajVlZrjlDQ0MYGOjH2NgNWK02uN1uFBYVw1NRgdzc3NjKlSvarl650njnPfcMtbaSUl8v3eJEWGtrq8Jjdnb2jnfeeS/S0XGKNmzYSBkZGToAPmACoOnPLC7IM+x2u75uXS198cVXNDIyGnG73TsYg1pJYKVt9erVFp6Ul5fv7uzspqam/Qyk8V5JkshqtbIj2rxxI+386XY6/vHH1N/bR6UlJTMOtRdf3EOdnT6qXLhwN2PNYApaFEXha2/jDc88s4uBDUVRBLCsyMJJbl4u/fHAH4jiCWo50kJlFR5yuVzCgSXDwqOxc+fT2qV/DtB7f35rmyRJqZsQEeeh9PDht6eamvYzFYYAllPA/LEzHpevWE7/unyZ1qypprrNm+jNQ29Qfd0m4cRutwsnjY1NxtGjH04x5jQ28OSTW450dXUzqMbRzAZnYIsiIqR1a9cSkUmR0CQlp6bEb7bNGzaIdZvNJqg9efIU/fipbUdmcuBpaWlVa2vXcxJNi8WSjnzmBsw/A7y8v5n0RILCoUnSNY3O+nsoGgnTwD/6yGa1Ep9lDMZiTAAeuaqqeqvT6bSdONFuyrIsman6/28dSxJ0XUdOTg6Gv/kWu37xHGRFxsjVqyi9uxyZTifK712IpUuWiH2KokjtJ9pNxqyqqtoqr1r1kHdwcACapkmcbEgSIHMgtxvhjUOHAImQleVCfkE+gqEg1teuxwctH6CqapU4YLVaoWuaNDg4iIdWVXnl/PzCsv7+fl5LN50k8s6+JC4CMQaDk7Db7YjcjGLkm3/DarNjy5YtON7ejgu9F7F48eJbLn7h4nn8/GdPl8kOh2Pu+Pi4wCMyBSAX1gy4aBwQMqwZUFUVNrsN7vwCfPqpD7XrnsDxTz7B7/cfQIXHA1lO0WmxKJKe1JjSuaLBZjEugGVZhmlyzlMmSxK0pIb7v3s/3nrzsLjqggWl2Pu7NWI9EZ/CfUuX4a7SBbh8ZVisFxUWwuVyQY7HYyG3+zsiUAZnYI6CR56nPhn3LVuGoy0tkCVZOJt/ZzHUeBSaloDNkYmvLw8hHAqLFOYVFFBhURGWLVkckq9fvz7k8VQKB0zR0kWLsLamBpmZmek8sD344EqMj92AaRqwOeyALMNmd2D02nU079uLpctXIDARhN0xBz95aiu90NCAYCg0ZDlz5kxHQ8Mvv8e1zpEHAgGUVZTD4XAgFosJcJbu117/E0zdQFllJaKhEKLjQfQNXELTKy/j77198P7gYTz/qxdgt1pROr+ENMPgiurAHSUlnrNfXVAfe+xx0WizFDPd0aULSqhx717q6TlNp3t66NL5izTSe4n8vlPkmuuiysp7RUdPm6mq"
    . "qjk5GVaJyCM47ujsPsJCx20+o5wsF4qc0qD5RYXU++W51HlDJ9PUxc9IeJKcWZlUVlFBCVWleCxKU9GIpusmRcIRIRWyaZqS95HqPcPDw7HGxiY5mUxyR4u2kGQJiiLj4UcfxbWJCYSDk1ATKhKxOMjQEY1GkUgkYc3I4NKERVFMk2Q5Ho/HnC7nHiF2s+W6q7M7LdesK6yijjlzaNOPfkiJWCzNQTKhkmHodGVogBRFpuo11eJu4VBY03Xivdumqyb18Mx+cFhVm5sPCLq4kf1+P+1rbhYS/dKe39Dfej6jYGBcOPvM1yVE8NlduzSeq6pGsWhUPDg+n0/0WFoe+Mmsr683+Mk8+OrrB+fNy3F+/tce/PbXuw1bdrZ0bfSa9OFHbdLZz8+C5XpedjYNfz1Mc+9wKwdffQ1FBXk3k1q8ISsr+10iUiTpf7zLTNd08/Kj/77/tH8qqWoUCUUomUymKRq9EaBz5y/SR21/oY6TXVOGpr0fDofLbqHl/xk7sVhSCuIpLl6kJRL7Ijej/uDEZGBsbNy4MRowEgktcP7Lc36v17uP/9rMYHHkt+P+B6BZlLQzhGDFAAAAAElFTkSuQmCCiVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAJ4UlEQVR4XoVXC3BU1Rn+z7272U12Ny8IISYBKUtISMLb0mBICRgeCSIEUghoGRyqFJRhlIelaniItAVntIiKlLEzgBlpK0wRE0KsY2GgIpAE8iC8SdC4cfPax93NvXfv3/nP7l0iBD0zZ/buPf/9v//85/sfh8HDByspKRE+/fTTQCAQIKkkAJiVljayIDs7e2xKSmpydHS0jRZcLpf77t3Wb+vrG2qbm5tOAkAlALTRGiKKwJjGALA/KPYQfEEQBE3TNFrOGjJkyItLlz4zr6Bg5qCUlBSQJAk6Opzgdrv55zabDQYOTACrxQItrS3wecXx9l/nTTlaVFS0mzFWH8IQAIAr/LkhiqJIMlGRkZE7t23b3tt6tw3Pnj2Ha9e+FMjMzFKNRiMpokm7wpjYGM1gMGq/GG5XX3ppXeDUqTMY0JBGr7O9fef58+ejDAYDlJSUcMU/NUQSBICRublTLtbXN+K5cxdwxoxZSl9AAhVFEc1mMzJBwLi4OIyPicaJY0bzNZKdOjVfqTrxBbeipOQ3F0mn0Wj8SSN08AmLF5c6enrcuGXLNlkHJkCj0YgGg4FPApo+LR8nTXoMFz75JF5vbEDXDz9g2vDhuhHIGNM2bHhF7ujowtLSJQ4AmBDa/QOeEEJuH7Fo0eJ2SZKxuHgh7ZoDR0RE8F/GGAqCgAJjmJebi6eqqrGtpRUVrxdPVJ3EwqI5mJ2djVarFSNMJv4N6Vi4sETp7vbghg0b26+fvTiCMQZlZWXECT7Y4cOHyaLInJzJdS6XD+fPL+bgBMwBBYGD06T35Hp7mh1XPLMMHXdasbKiEs1RUZieno5WqwVNpgguR54iHfQ8"
    . "d+5TCh3Hh7vfryOsECbjZyIIAlit0bsaG5txc9DtaDabwjvWwfVffWdT8/PR6+7BVzZuxEkTJ+Crr27CI598gicqjmNqSkqYK7oRmza9KtddasDExKRd5AVOSkSkUEx/7bXNysWaS6ogiprBaEBBCO64v2kIHcczS5aipmkoed3o7upE7JURAyon3rXmK5iSlMS9ZxDDvNFqai6pW7dtJw+nh7ABkpNT9929+z3m50/jrifXPQyc3usk3LFtazDW/BLKfh8GZBlv37iG16408vd797wbOoogeUl3fv50hbBSU4fu0zmQuG7dho4zZ87x8NHJ1p8BfflgjIjAr0+fxqsNjXi5thYDqoLdnV144X9nsb62FhVFRqejDZMSEjiwIAr60WmUU9av39gBAInExMLCwqL48vJDGmOMER8eNhCRUiRfnjhhPHz40d/hqQULwK/IIIgGuHXrJgyzp0HmmDFgMBhhwKDB8MtJj3F5+o4mYXxcflCbPbswXhCEQrDb7eXNzTe19PQMVXc/Z73AEEQey/fCLxQNRKqkpCS+s+zsLO5u2SehqvSiqqq49/33cM6cOehwOPAvb27ncpRDdPIS1tXmm9qgwYPLYeHCkqaamsskwFOrDsJ/xXsk7BuK9KzLrlr1e7xz40aQhIi4cf06HDQo6PZVq1ZhdWVFOCS5jmB4a4T5/p73mmDNmrWu6uovwyHT1wCBBXPA/bkgSEQRbTYbDhk6FD/6235E1FCS3PjI4CQcP348zpg5E+suX8Ib165ihNHIvyEP6MYfP34Cnd85XIbo6BirXtUoNjWNSi/j582z1H3PVD810Ph50ncFMwtg0ZJSUGQFyss/gc1lZTAqKxPGZGeDNSYG/D4JRtjt0NDUxPWbI81cp+T1wLHqKqvhRwWZY/64QuuG0EASQABBFECWFcjIGAUHDxwAc4QRvF4v/CpnMozKyOCyil8Cye2CSKsNZhQ8wQ0go30+H4zLHA1ZmVlQc7kODC5Xt8dGBT0EQFYSaKgqQqgZuecR8pKqQVxcHOx9dw+YTWbo9fvAbDbDqIx06PVLXJZPBlyfkQUjh/oLi8UGdY2X4dad21C6qMQDCxbcT0IqOMGcr89wERIENJlMaLcPx2NHjnLS+fwenoQoGfkkD/p9XpRlH1+jUfHvo5g4cCBPRBQJicmP4JF//ktrafkWvW5Pk1BbV1NrsVhw+HB7uFuJsVph9YrnYH5xMcTGxfJd8MNhDGRZBpvFCjdv34KKo0d5W0KWigYDmCOjwGSOAqVXgarjx2FuUSHMnjsPHE4nqKoKMXFxsHTBIhiTmaWlpj5CTqolvcv/88VXuGbNWmJfqAIyLMjLw/Uvv4zDHh32QFHSPbNj6xvBHCB5sNPpxGsNDVj12TFcs3pVWCYuNhZXrl6NJ05W4Qd7P8Czp06j5PYEPG4foorLaWuJW7bvaMyfkhefl/c4hQqjs+pLPiIP/88AjBFGiLXFwthxY+HFF14ARVXB"
    . "JIqQYIgCxeMGp+yFPYcOwMmqasjIyIDKo8cg1T4snFwpZbvcPiaKrDM62jaKL/zjs8/2+WUNcx/PDRcjvQPS84IYyoLJSYPx8MFD+P13bdjS2orftbWhy+VChXggSdwjy377NPdATs5k/l/yeHjFJI64XD2Komjo90u8GBE9mc1geOtkVaX6pz/vIo+Qy/nB0rnpniCN9L7b5YKa8+chIWEgJCcNhsSEARBligANkOcHHoIK7QMgoGkQUFQQRQFEgwi0CVnWmCz7VZMp8i0qxwL1/rNmzbpSumTxO/HxceLrZVtUUkAfECCfRDIxWExyc3LAkpgIp778ChgTQFFU0BCB4kbPIHJv0AA6LtJD+UNkAnglWY2PjyU73mGMXQk5ABi/PIRaMrf7XktGIaenYVEUMMoSiSXF87lb3d096HN70S95g/2Aj8LQy9cKZ83gR1D05JxQv+BFV0+P4vH40eeT6hCRt2ThhoQsudeUloaa0gXhppT4QHE8ZepUTEhIwDdffx27nc5wrKuKjJJXQq/Xg72SFyeMG8u/eX7lSi7T1dHJm1K5t7cdEUfwpIf4QN1/sC3fvDXclheHdl5RfRLzpk/DR4cMweefXY7VlZ9jVx9jXJ1OHBAfyz2wb/9+TZFVmcAVWXHIsszb8pDH+x0/vpg0NOGFCzWYNzVf2b1zl6ZK9zLc6a/P4oqVKzFr9GgcmZaGU3Jy8HfPLsfZT0znndX0JwqU6zducw8osnwR0T+yP/D+7oZ0NaMLaVSkxbLlj3/YtObpp5dFWCwW0PySZo6KRKPZKERGWXly1FCF+qareO6bb6Dlzh3N0+1i8+YVC3lTJlMUyYIIfxWE9jLGkilGRcYYv+n+3KDLqS6TlZmevrfmmwsORUUkknZ3u9Hp7ELH9z9gp7MTJa8/tFMNT/33DN0hHVs3b92LiFm6kv7O/OcGXc/1I4FNa59LQsTlfr//Y3ePu9HV4+rp6urWujq7tc7Orh6fz9e4++23P6bUHrrK80G77sv2+8f/AZ30Qdem3kjRAAAAAElFTkSuQmCCiVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAS40lEQVR4Xq1aCXhUVZY+b6ktlQ0SIcgeVsPiEKBFMUCrKAQIEkBEcGnanhnHRlpE+hNtQvs5n00r4wooDaItgiJou7AIA4gQWdQAEiAsJiQkIZVaUqntvVdvOfOd+6qKyoJI95x8L6+Wd+8959zzn+0WB9dPPABwPM/rPM+Dpmk0wwAAGA0AowRBGJyVldUzLS29Y0pKih0AIRKR5GAw6PN6PdW6rpcDwGEAKAWAs4IggK7rgIgCACDHccb1sCRex8McAPDEOMdxtGhXwzBm2Gy24mHD8oePHn27c8SIkTBgwEDIycmB1NRUsFgsbHpVVe2hUOjGhoaGG8+erbi1rOyH3x08eCB8/PixHyRJ+mT16tVbOI6ro2djghgcx+Ev4Y2Y+iXEA3CGIPDE"
    . "eC4APDlw4MC5s2Y9kDlz5n0waBBtABgeTxOeO3eOq6z8iWtocHGhUIhYYsJ06tQZ+/TpiwMG9Mfs7A5MGWfOnIf1774DAwf088+bN28DyPIrnMNRGWOIdvq6duNqJJCpAIAVAJ7t36+//403V2EwKCEiqsePl2slJc8bBQVjMCsri7TW7pWRkcE+z87OxjFjxiGNOXGiXKM5AsEIqqqBkiT5o3LkWUS0kmnNnDmTzOpfIpEmAoAhgiAcWbhwEfp8Acb4p59+bowffzdaLJYWDPM8j6IootVqZd/R68z0DMwbPKiNYPT93XffgzRXc3NY9TeHUVM13L1r1xFaUxSZhV+PmbegOPMze/XqHdy+/SvGeOm3R4y77hrfghlikpgRBIEJQJfA80zbosWC6enp2CUnBy08j/dOmIizi6cRWJEXhMQ8EyZMxG++KTVojX37vsHevXODADAzpsDrFkKMST9/1KhbsbKyhpjXli5dhjabjS0a1zTdiZn4xT6P7cq4ceOwa9cb2fMPTp+Bm//+HtZXVWFjdTVmZ3ZgY2inSHB6xm6347Jlz7O1aE1aGwDmkzMoKSn5xULENf/7O++8C5ubg5rX26xPnjwlwXhc27Qw02RM63EhiJlhgwfjlk0fYOk3+/Dx//h3vHj6DCIa+FNVFR777ju8v3i6KawgIkd3q4WNp7FFRUXo9fp1Wju227+P2cY1hRB4ntn8jFtuGYV+f0Crq2swRowYySZO1lbcvltrn97n5+fjp5s247EDhzHgb0ZUdUTdwG1fbsORo25Dq9WOuX36Yr/+/dmOkgDAm4qwWk1M0ZqXLzca9fWN2lN/WIhNl+pnEGObN2++KrDJx9MzeT169AxVVlbrHo9PjzPPFoqZStxsks2HXtPCaalpODDvJhw/fjwufuwJPH/yFEpNASw9eBAH5g3ClBQnzpgxHQXRNBuHw84wlDwXKYq+IyU2uLx6VNb0nVs/C6176aU8ikElJSWM0WTiyGWVlJRYrVZr2bZtO5kdTpxYyCYi5lszm6z5hOlwsWcFHh1OB06fNg1dddX4/eGjOKXoXrTYrZiRkY5PP70IM1JTccHj/4Xdu5kYIaaT54wLMalwMspyVNu+cxd27dq1LC8vzxpzry1imBBD+5IFC55k3mbp0j+ziZ3OFBRF09aTd6A1eNl3vPkMjeuQnYUPzHkQg34fNjY2Mq2P/tVIXLb0OXzhhedx/67dtA6erTiN48aOYWMsotiuEH/60zLG06JFf6R1l8QsJWFKPCJydru9R+/evYMEnm+/PWI4U51osVljzFOOwvKUNmbUeid4jmfgtjscOP+xxxmTqqqgHlWwsbaWvY+TIkcYsBVZwqIJE5gQcccQdw70nnaDePJ6m/SbbhocJF6JZ4rmZEZx7a98/fWVbL2xY8eZk4kiklmYzLcUoD0TYotyPPPvFAe2btyIkXAYg6FmjCoyqpqKzY0eDHubsOHSJWx0XUZZCqOmqeiurcOu"
    . "OTlsDoE8U0xZhA/ihXgi3l597U16v1IwnY1AyKUXObm5fQLNzSHjk08+p/yjhSauymxSDEgGNo3PyemEe7bvwHAwyDStRMLsHlUkVBQFlUgId2/fhn6PmwlBtPyFF0xTspDDMONLPN7Q58RbIBAy+vXrFyCeife455k1Z87ctPR0p/7GG68ycBDar0WIyJ5LfpbjePa+S04O3DpqFKQ4nXD62I8QiURoq4EDDqxWK/j9TeDz+UA3DLAIAhi6DrNmz4JMpxM0LZpYmtaIE/GWlubUZ8+ekwYAs2gtRjab7UB5eYVBiRn59/aCU7ugTcJEPDUQLKYLfP75ZXhwz15c/eobOO+R32AoEEDDUNHnceO2z7/EmqoqPHrwW4zKCkbCIQyHKMcy8J677mTjyXRau23RIiLxSLzabI4DxDuJ0G/o0JuH5+UN4LZu/ZhXVRVE0cIkT5Y++XV7RNsp8BzoahSGDB4E1Zdq4TePPQ6LS56DiCKDMy0NNFVjxcuN3bpA9569YMjwYWCxWcGR4mQ7ZSDAbbfdyqan+RI7iwCiRWTjt2zdzBOvQ4cOHU68kwBjCwrGODgOjL179zC7QTQSphGfBDlkV4vgETMzupOAmqbTbpIBwnvr10NN9U8QbG6G+4qL2TBd0yCzQyb827CbQYsqYLfb4VBpKTz04FzYsfMr4DkOhg/LZ88ahpFQGtIfSQcA+/bupeWMgoICh8ViGUufrd20aTM2NjZpmZkdEvlOMihZlBWAXa23NdncWBYaS8wE3owHGRlpWFFxGlHXUQ7FAK3I6Pd58JGHHyJfaMaNjh3wbMVZrDxXgal2O4GrLQ8AmJmZiW53k/bBBx/SuLUErENlZT/iwYOHdHogGf0tApfAJwJVe6lEAg+JxI68iQXHjB2D5eUnsXTvPlRlCUNhVk/gKytWMMYLCycmMtZFTy1CWYrgwNzcFjhIThZpzNf7S/VLNfX4t7feOsR37NixJ9WwVAaaQcFEdhubRzKMa3smiGHHYrGC05nKzOqppxZBfaMLRJudzWsYGmzctImZUG5uH3B7vDB5ahEsfuaPYLM7WF0d94TJKzIvxnFwsaqSy8rOhluG3tyTT0tL70A1q8vl+ln3GQd13N7j98RCSW6XXvM8B5IkwbelpWC32+De6cUgSWFIdaZDVeVP4GpogLG3j4EjR47CurVr4R9btkJGKnlHgBEjR15xozFAkyQGmrjwejycqmlQUV/fQXQ6U+xUMJgFuEkmL+SF2Lt2PVC7XokMmkPgkGOap5ZL4eRCpm3D0EEURDh16hS8/PLLsGrVapg0eRJomgoicKAoMgMD2GxwewF1aIB5rLg1CDwPnTp3Bp/XB26Pm4oW+HjzR/Y2aak5wLzao/YYZ5/Fn+fMIEjM53TpAu+sXQcpdjugpgEvCICow+NPzIdJUyaDHJWZZ5IVGQRBZCaiqQpQe6Zfbm/miTiBZ3cDEaKKArOnzYB7pxRBOBIBJl6fvn2kQCCC"
    . "L71kgkoULW0qrNYVV+v3bQIaz2PHrCxct2YdA2wkEsSoLMWSN519RmClJC6eXtD3dElhSvAQJ919VwLI5npm/ZCZno5f7dyNgYCEdXV1Eu8PBJrIfDp3zonp0Axg7Wk6nja0/j4RKxBZHCCNLZg/H2bPnA5RWWKaZabFmaaiyBGGEZZ5x2II+XpN14AXOUBJgqqqiwnzIYu22W3Qo1dv8AcCcOGnSnQ67ZDVIbNJ9Ht91Q0NDV1yTdfF0eImECgR5cAwEAQCpUVkrylnuYKVlvjo3r07yLIEj86bB/PmPgQaIlCuyGo1ZlsU+ukfxyyOeTVE0HUKnDw4UlLZ1P/93HNw+vwFZudkOsSTFInAA7Nnw635+ZDZuQvqmk6htZqebxPIqNzjBEBaJyXFzrYu+WovOyWfb7fbcMaMYqy8cB4NNYqoa6goYZaBRiXJvLMrwjJQKRLCaFRO1AcH9u3DosKJsYw01leyWLBP3754Q+fO+NtHf8eedXuaNDkSRT0aXUtV/uEjR4/89v77Z3KDBg2C0tKDTDMc8mAAQmZqGrz9l1fAbShw7HgZ7Nm9BxouX2bmwEAWc5/kMTRVhZrKi7B8+V8hxSLC2NEFUFg81XSB1CU0zEhCYLbZqdEHEPT7YdfXO+Dtt1bDzt3/Cyplp6IVVPVKRuqw2+FPi59hzsB9qQ5U0cZZMkTgOeMwCbD/yOFDEiI47rjjTiwtPcjFmaLcpL7RDeveXw9zHn4YZk6dBt4GN2yvq2N2HXdxcSLGjpaVsYtowE2DgRMswKEBFqsVgBMB0IBQMAQ1Feeg/PSPsHvHLlj33ntsi3lRYN1QVYvCnYUToXjKVBZY9+/fD9V1dbC0ZAk0eSmrRV6OKlJKin0/8/hpzrQDR45+PzqqRo2RI/OFZP9LYCMbTabWYI6/Z/jhAByOFCiaMhnWrloDqR3SoNnng2BTE3hcTdDkcYGrthaam5vBEw3Dzn1fw6HSQyzbpCg8dWIh3DdtOhROnwqxFg8jv9cHthQbhEKKnpqaSplNqd3hKBBpcYvTseXTbV/evuTphVhQMAb27t1DrTlmFgRckReYPybAMSDHIiKDJitozMQ8Iz0D+vXOBWuKA/KH58NHH38ILq+XgbZ3t26Qm5YNOfZ06NJ3ILilIFR466H2Ui0rcChq3z56DPx94wcMcaocgaihm16KlJyRCoqighrV0OGwcrqubkl4SkTMeWfz5oCr0WdQo7W9kpIlcK3aiPFMlLoRmRnp+PCDc/GVl1fgmZOn8GJNDVZW16DH58ewpKCq62hoKqqKjJFIhNXHXncD9uzRHS2xZtaEewpR03WMBEMoUxlKgKd7rBR1u31GY6PPkKUIZYQ5cRtmxnzm7PmVP548g2oU1V//+g4ziFjMhtO1Ale8SXXf5CkoB5qZpzBUFdHQUVMVVJUIKuR1GDMUvCQ0dA0b6mvwxi6dE62YeyZMZGOlkPlcNHol0IXDIaytc6mxLsfKGP5Y6slc"
    . "cnpqyvJ3310Xcrld/IsvLkerzcqKCJa0xYJbazLBzgHqBnS8oSNs3bkdlixcDHIoDCpqoCgSaCxucMz/k6ZoBBVMtCzVKLqWFDQTBZJBs15JTxAhFJLRZrXy0agcEkXr8lhbBfnYmRTfrVu3mv9Z8fKLL/11OX/LLSP0xU8/wzDAgNQqL7pSyFOg4liw6WB3wmuvvQ7n/V7Y8cWXwBkc8JzAGDfjWOzO4EK44ZlwlDPF03Sr1TySopYP9XGIKImTZBVUVdezszN5geNe5DiuhqZJPk+7SmtxEjOleNsv2ZQYJqjtaLdi1x5d0SLyeKKsDKuqa/DAnq9RDoZRVaKoyjKqUZnZsipFWFFD5kQF/IULFZie6mQ9JFpn9pw5Zu4UDjIMqIqE4VAIa2tdmiQpZFJldHpD52ixHWhBP9vctVjM3mWL6oinJhSPw/KHYa9ePbCivNxM1EIhVMLEsGLacgyMLGFTJJRifaATx35Aq0VkLUUS4A8LF7Lx4VAQNUVi3Yr6erfu9fh1XVdDiJgXs/1EFp2cThuGYdB52OmamupHZs+exVNr47PPvqBWN4uM8VPHeD+IBjucqXDiZDlcvFgD77y9Btx19WBzOpkr1QwVdF0zC3RWV9Ce8YlEsdHVCFGV0mzTXLp362aaDUfBzIDmgMQU1DErgzcM/RGO406T9q91FPuzBxy0CxbRPPsirS159lk8caocJxSZByAOUcTFTyzAc6fM3TDJwKgsYyQcwXAojIGAHzVNw1VvvM7G2GzUS+Jw2w7WFceA34+XL7t1l8tLh4CoaVF2wIGI1zzgiFOLI6aqqvaPmH41aiT6vJ4Em/sPH8KiGdMTid+EcWPx3TVv48VzZ1GNRpMEMuk/H52XOFfLzM7ChsZGDIXCWFvboLndTewZLRqdf73MJ4SI5TttDvnoZJEU8sC0YtaolcIhllnG6WTFGXz62SXYpWfPhDB9e3THB4qL8S8lJfiPDzfhF5s/wi6db0h8/8STT2IoJBvVNfVqJKJQwzeIqM38Z5lvLcQQi8ViHrN6zWPW99/faGzYsAHd1TXorb6EUSnCwEnAw1jVFYnKePC77/DFFSvwnqIizOrUqU1aTsr45JPPDI/Hr7pcPqYDXdeOICpD/lXm49TyoLt/f//KN1dhOKQgeUm326c1XnYZzR4vKqxMNC9JCqGRlOsTBWUJK2tq8PvjJ/DtNeuMH344zg66NY2VDhhVFD+ixg6645G2TfRsRb+g0cOICkCDT/qpwYj8/LmbNmzM7Nm3P/h8TRT0DN50q5zA8xwvUDJOLUEDdAMpWiPH+v48pmekc6IIfEXFBVi/fh14vW7/mlWrNvBW4xWOM39qgJgIsv9vRMKy3YidIXd9bM6cBZos749EIqGoptFZFgaaw+j1+LGhwUuehF302uP1o785RA4J1675G50Bh1IcKfsBYAEAdI1zebUgdTX6pTuQTImf28TrZ0RkP7fRVGWUrmqDOUHoaRhGR0Sw"
    . "s9yHA1kQeB8AV2212spHDsk7/H35mcTPbSiu6Lr+T/3c5v8A1LRZkrbVE08AAAAASUVORK5CYIKJUE5HDQoaCgAAAA1JSERSAAAAQAAAAEAIBgAAAKppcd4AAB7GSURBVHhetVsJfFTV1T9vmT0zIQkRQtgChJCAIiAuIIiCFrFKUXEBtLXuVeteqy2Ctl9rPzfUuoBWK1TrUiy48KkVQRa1giwREsIWEggh62T2eev5fue89yaTELDV9uY3v5nMvHfvPef8z7n/c+59AP+5JgCATN0JggCyLAMi0ncVAHAVADwBAP8HALsAoFUQBMXtdiO96DN9Z/9G19C1dE8F9SFLMvdJbcGCBbLd73+kWb1+v0Z9iABgiKIIhmGIgiBMBICLAGBqMBgcMXToMF9FRQUMGTIUBgwYCPn5+RAKhcDj8fDIiqJANBqF9vZ2OHiwHvbv3wfV1dVQV3cg1d7eTgpbDQDvIuJGQRBMugcRJQAwBUHA7zf979doEiCJEvj9/r4AcC8AbO/Xrx/OnXsV/ulPf8Zt23ZgOBw3EFFHRHo37Vf35nzP14bDMaOysgpffvlVnDfvKuzfvz8Juv255567FxFpLG62Ir5z+64IIIujKIpYWFh4QlNT0+0AcP3kyWcVzpkzF6ZOnYbDhpUYhAzTBKG5uVWoqzsA+/fvZws3Nh6GaDQG6XSKJ+71+iAYDELfvn1h0KDBMGTIEH4vLOyNkgQkuLl/f5307rsrBU1T4c47f94iy+4XIR5/SggGm22XEBx0/LcbW90e9BYAOHzOOVNx+fIVGIkk2MqKYmJVVQ0uWfISW6+8vBy9Xi8JcsxXIOBHl8vFv/v9fqyoGInz5l6Fixe/xH1Rn9T34cPN+pGmFkaPrmmHEZHmwIacPXs2z+2/1WgQiYJRIBAYBQBrhg8fjsuWvYaxWEojWIfDMXzvvVU4d+48QsZRwkqShLIsc+AjYZ3P9F5WNhwrRo7kawhZ2cqivqhP6jsSSdB45sGDR7T2cAQTiQTpYg0ijqIYZCvhuyL7mI0DHQ0AAD8BgOjNN9+CBw82aoaBZjSaZAQQErInToI5gpJQFLDoRZ/pRb+JksT3FBUV4ZBhQ/mzz+fD/sX90CUL6PW4u/RJY6xY+R4mEgq2tHSY9fWHteamFjxv2rQozY1WHzso/8eUQB0JksToejQ/Px+XLn0NFcXQCZabNm3Biy++JDNJEowEdwR2hHXeHSXQ++DBg9Ef8PNvgwYNwsKCfAx4PVh8QiE+/8QTeNnMi7hf2UZMNjIuvvhS3Lq1EtNpHcktyFUKCgro+kftufK8v687sMnXrFlDan2jrKwMN23aqqkqmgTFJxc9jaHcXJ6kA2/Hwtnv2VanzzJZXhTx0ktnY15eHt+f4w/gVRdfgo/95mH8x7vv4pHaWvz6843otVHiuIYsu1ASLdTk5ubiokVPYzyeRk1Dk+ZWVjaCfnvDnrODhu/UGPZ2R8tPO+103L+/XlUUA+vr"
    . "D+MVV1yZsTpD2fbbbAv3ZHWRJi9YwXDJC8/jr+/7BY4oG4YnDi/F+upqbG5s4ABnmrQaIs610UWo4r5FAUESUXbJmfFpLjQnmtv+/XXqqaeeRr8tR0R5wYIFZMR/Gwkc8GwovUkdHjp0RCW47dhRjaecMp4HJ8Edy9Dk6H+b2XVxAUcpkq2kcyZMwOV/WYb7qnYwJdj5zXbctH4Dom5ge2sLfvnlP3H+goX4wH2/xFtuuhnz8vJ5ZbAUILICSImSJKLXa8UImhPNjeZIc7WV8KZtevLff0sJsh3wHiNIkeVTKR0rK3diaelwHpAEzfZvmhx9l7GUHfCyAx/dd/oZZ+D8+3+FlV9txRXL3sRDdfVoaDpqsSSipuPHH32MF1z4IwzlFaDs8qDPn4NjxozlIEn9k8JBtIKp9aK5WGgYNqyU56iqJm7d9o3624UPodIef4yUQBT6X/UDXupEUbya/HPTpi0aQWvHjl1dhO8J6g45OpbwOTk5OHHiRCwpG4IP3vsA3n39z7C2ehfGWjswGY7g2s/W4YRJk9Hj8WEoFMIxY05Gt8fiBsFQiH0+E1u6KMFSPl1HBqqu3oPRWAo72qLatrWfY836z68WQIC33nrrW3kCB72CgoIRABBbuvQ1gwLewYONOHbs2AzsHQFpwO4BLnu56259Eirg96M3x4vjTh6DP77iCqzfU4OHag9g5ddb8bbbb8c+/YowEAjgJZdcjFu2bOYx8kJB7Ne3D3/2eAgFnatM9hiOEsaOG4cNh44QBTfffW+VceaEM2KjRo0imY4bFNnvEZGUsOGGG27ipY6i/aWzL7MH93RZ4rqv63ZicpRrZF9HLkL+W1RcjD+99hqs3VuNiUQMf7PgtzioZAjmhALs2/2Ki3DixDOwtGQIvvL8C/jNtq04evSJXWJPTyuOo4TZsy/DWCyN8biiX3/DTShKrg22bMeMBxL5vSiKNw8dOowCCUP/ySeftuhpwI8+nwddLtJ+tg92EpuerJ8tvDNhWspOPmU8XvOTazHS1sYRv2rnTrzowgvwtDEn47NPPoHLlv4ZV654B2sqK2lJ4BUh0hHGn918kx2DaDnsOg+nf7fLcofHH1+EqoqEBm3kyBOJYN1sp9VHuQKThqKiot4A0ETQJ969afNW7F3YGz0+L3p8Hh5QFMjCFvR78vXjKcG53h8I4Al9++B9d1Nih5hOEZ010VQVrKupQV1JZWWKBiYTMUwlYqipaf7+tw8ttJDgLI09BFyaRzAYIt6ChoHGa6+9YbhcnqZx48aRjEeRJGfJ+93kyWcxt4/FUnjhhTMtkkNrrkBCZ796Xuq6T8aJE5lYIYgoyiJVSnDtRx+z9aPRDlTSSVTSKdQMHSNtYQwfbMREWzuGm5tRTafQMHVWRJKVhXjtlXMyBKwnvsGuBoAXXTST5MFoNKlNmnQWffc7St/J3Z1VgQNf3759CwVBaPvb3/7OeTlxe6ahpGUiHz1Y/FgocGLBsX6nfseP"
    . "GYO1u2rw0IEDGE/EbAUkMa2kUE0lMR2NoZpKYzTchl98thaPHD6EuqpgMhlHTdfw4P79eEJBPs/NCorSUSsTL5kAnKeQTCQbyUiyZgdE2SY890yYMJFTWsrqCAkZBWQJ/20Qz7ZGz0xQREmW8IfTp+O2rzZhMkbCpzAZj6KaTlovNY1qOo3JZJJrKNWV23Hl8r+hqWuMhmQyxij4xV13WfHARWW1oxXgoIBkCXfEWLZJkybRPffYPEfmUtZzzz3nAoBr5s27GkMhv7B+/Wewfv068gsqcXXhD4h0f2fr6X/6zqnhUcv+zH3qBpSVj4DRp4wDr88DqUgU9lbXgEh1RPI10+B7fD4foKFDfV0diJIEmqKASPVGEAHRhDlzrgS/7AJd19mrs+dCn2nuNB7Jsn7dOiDZ5sy5igS45rrrnieZrYEAYGKfPn1w9+79pqLoeMUVln8Rtc1eao6FhO6oOOp/prASCpLMcM0J+HHdp6ux+cBBrNu1B19+fjH+cdFTmYBIwS4ZjeOO7TswHunA5598Evfv3oNKKoWaojBKCDW6puKZp51qxwI7V8hKuemzU2ShfIFkIxn79u1L90xkwmfDf+bUqefC0KElxt69++Cjjz5ky2VbP9uK3du3oUIQRRBEAWSREKXD9PNnQEtHGB76/e/gsaeegj8sehxMBiOAaRgguzywYcN6ykLBlxOE8394IeTl5wOBT9N10E2D+5FkF5x19tl8n2RXjbs3wzQYHR99/CGQbKWlJcY550yjy2aS7LKmaUR9p02dOg2IBhBcwuF2cLlcYJomC9ddQGpo4remF6Q050WQJagOKC6GISUlcP8Dv4ZoJA66qUNHWytMPP2MjLsYugZlI4bDmPFjgSrr/QeXQFpTwO12gyBZikol4/w+fvw4az5ZbufMmY2GALJLgnB7mF2homK4SLK+/vpfpmna67wSjAgGg8lt275BXUdzzpy5Gehk09xM4iNYlR2gYmUPfOB4QZBY2tlTpmBBfj73EczJYfhOnHAG6qqKaQqA9ipgGCpqmoJKKom6orB77Nq5E2+/7Tb8+4q/Y5pcQNVx365qDAV8ZA2O+j1xApfbcmWSjWQkWUlmkp0UMO/kk8dw6bqxsQWp6OEUOI6rAIpX0tGEqKfSl6MUispOZHa5pEwW98AD96NpmqikEqilaCVIsTLoRZG/qeEQvvzyn3BkORc7+PXoo4+yUhKRDjx5ZHmPK5ajDGc5pMyWZCRZSWaSnfA0try8HHr1CuCBA7Vw4MABhk427B1XsDBKUf0oV8vAt3skdhr1Sf1QXBFFAQzDBFXTIRjMofI3/97W2AS8zSFa3kVLVTyRgIsvvRR++tNrYWf1LpBlib9/5ZVX4IP33gd/KATlI8oy4/e0+jhzsuSrZVnLKypAcrnGkgLKhw4dxqLV1tbyLg0NkC2I06nznSCIQFxO4J2vzub4YfYkHH8k4bOu5O9zAkHoP2AAlJQMgW8qK2Hr1u0geTyg"
    . "GyYHOpfLA6tWrYKNX3wJOcEA3HXXndC3bxH3X1VVBTV7drNFhpdaiZ6zQHdXAo1FxVKSreFwA6TTmvDAL34JlV9/XU4KKBkwYAAroL6+LqPJ4zVWBCnALrI4ge54jVHVOUVwudyQn18AsVgc9tfWwtVX/xiKBhQDiKTUDNLh/fc/4LX8/OnTYfTo0dDc3MwouvWO2+HOu+7iIU86abSlgC5K7tocpdTV1dHqIVCQb67ZXUJXtb799jtMFe+4487M+v+vZnY9VX97SpM5nghWvd/jcWFubgjdLg/2ysvjuDB3zlz2aSWdYFqsKknsCLdiv6Iivie3l1U8perQW2+/zdcmU0nOEXbv2IF+e+PFmY9TpOX/oZMP3HPPvVxArarejdu3b2ul0lcwGAwxAmiD0mldXQCBlJtt6e68wIF/T0tmpk+Bqlki6LrBW2OiKEFHOAynn3E6PPvcs6BpCjNB4gI+fw58+v4H4JLd8Pbrb8LePbthcNkwuGD6+ZATCICSTPLaT0vmoMGDYdjQIVC5s8pCmmm5mDNf0UVj6jyNSCQKpJO2tjZY+d6KIOUBbq/X2qVNp9MWlGy6awlJXKAz8HUXsHOd7xy0R97AxqfFigKsAJJkTWryWZPhnXfegZycAGiqFX/IPR555A/wj3/8A/786iswhckO3S9ApLkFEoDg93nBQARd08EXyIEzJ57JCuAdaqLSRKkR+X9/jh+KTiiCmt010NR0hIMwCfXl5xvdFqvI0Pujg9px3CqzWnSP/NlBs1OZFg6sOIAsfK9evWDx4hegIL8A1HQKXLJ1DoA2QPsPKIYXlixh4ROJGKSVNCTjUfAF/OD1esE0CCudbcaMGbw6mWjwKmIiodYicpqugdfthofvnw9zLrscUimVZ7G3rh5kwzDUtKq4qSuPjQRHgOPR32MlO8dijkAulPVHbnfjjTfBiLJySKUS4JJdYNBWskDokGDe3Hmgmxqj0u3yAqIOkttt2cpeKqlAIUkyoGHAuLHjoDCvFzS3dzBbJEVTXxQwlZQKVbuq2WWWXn4ZpBUVivv1g2cWLVJF0zRjMcv3qWh5VCDvKcJ3Xxa7t55cQCCzIAV5AfJ694YfzZoFd976c9BVlSFpOgix/U1JJ8HUdJAlgrLlv+xCXGFhfXYuFrwP35mBEpfgkg8pSJYZLZRDfF25Hd5Yvhy8Hg/m5fWCS2fNipELtLa3t3HnRX37dZHFsWYXgeyJOgM4pCnb8tkIcn4nOPr9ftANA0aMGA4P3ncfBLweME2DA2N2f9Zn2zuzglmX+XCeAaBqKdq4hD1VVdAa7gDZzhWc9JjG7z9wAAwePJhlyw0F+Z0MkU7EW2mzoLb+YD1RKRw4cCCL111gx9cIwhTLDPIx68IMF8hYyKaJ2b5PJGTcuLFwsP4gTJs6FZ7430dBpg5cEnANmuDqkCorf7G+Owbl5JVCNzgI5gTzIBmJwIMPLQTDRHDLkhUEqW4gimx5t88LLz79DGxY"
    . "vw4GDy6h+INej0dwucVaGr563759PGJJSQmf2yG/4cHZFFbQIhpDPqqhCWQvtyhzetsT/B3hLYsB93mooYEzwksumQWRaBQK+vcDf06QlUhjsAKc1SeriNK1L2sONCOfP8DR/4t1a+G8c8+FT//5JUd8jQo4zKMFUHWdY4HkdoHX7YH5Dz8MZ06eDLF4nOoEIBpYTQjYsqu6GiIdCYG0Q1CpqanhQESwpWjqrBIDiotAcnvhQG0tQ9lpDnV24M6+aluPfksmkwz1Z595BqZPPx8KT+gDiUgYUtEO8Ob4wchiiJaTcwdE7bgvJ5rLLhd4ZDeAocO6Tz6BZ599FpavXAEGAvMFkwKlJFvwFwAum30ZRNvCcKilmRngeOVU5hiUaogSGVjaQgrYvHffntSBulrfqFGjcNy4U4Tdu3dnhOEgyGwAQNBNePXxJyB3xFD4dONa2F29Cz7+8CM4sG9/l/whG7pOUQUNE375i/vguT8+C36fD4b0HwCXzroYps28AARZsiZNkpv2eIYOKIggyRK4SWgA6GhthbVr1sBLixfD6s/WQFo3QZRFcEtuAJ0SLevltN27auCx/3mEjRjyeSEdpwxYoPRY1FQ95fK4NhPECMdbXnrpFT6D88ILL1rpsF1zz1Bd2aqwnjK8DF9b8iJWb92CDXV1+OsHfpVJn7NpcU8V4WySX1zUD5f++VVMp1KoJhOoJBOYSscwrSho6HTUyGrJSAy3bN6Ez//xKZwz6xL0uj0WnfZ50e31oEg7xfZ6UHbSiXjHPffggw89hDfdeguWjxyF5513PrY2NqKeSmFbSzs2NDQb6bSGmmpsIdllWZYJy59sWL9uzDXX/MScNGmymJeXz1Uhxw04QBgmp6Kbd9fA3BuutyKpsySLIsO0OwHqTp0dNHl9PvjB2VPh0pmzwO1x2/dZ2DdUHdpb2+BwQx3s2bUHDtXVQyQRBV0EaIy0g6pr4PP7OLMzbWufVF4Bl189D2648UbonZefQUAykYDtW7YByiIHbgqalJV7PDJN+BNBEAzZTlNXrl675t4DtfXSsGFDYfoPpsNf33ida3nZVJDWU5cogUlrM8UAWnttynnMIoHN/miyVBckAnTaxNPh8h/PBXAJ0NrSDK1NzRBpa4dIuB1iLRGQdQTTUMAnuqCssAgac/xQVV8LFKzZKBRcTYTRY8bA44/8AcaUlkP+oP5gGiqkEnFrKgKCx+WGMyZNBENXmf1Rmi0KgkTxyDDMlTQ3Pna6GTd/deGwK6s+XrO6/KbrrjGvnDNXfOPNv3LEzW7kozoFRasKTaGkM8WlSdkXZyzPjATB43bD8KGlMHTwEGhsbobSwUNg29db4NMPP4JIIgGmLEH/4mIYWTYCRpSWQr43wMQonUrCwfZmCOZ6wNPeBC3NzVwXpLVYQYQTK06CqeedC1oyDWoqSdMBF51lIjPTXE0DtFSClaYqGinN7JUfEtA0qlwu91d8DHfNmjXSeHG8tmFH5Stb"
    . "vt76aMOhJnPKlCkwadJkWLfuM17Du+8N2GH+mJmfxeasy7wuD5w2bhzk5veG0RUnwn0zzod+QwZDKqXwcVk6IOn3ujPBH3QVNN3gKE746o/IByk973oglUqDPxDIQJ8azc1Aw2J8YNqGsXyTNz8EAE0zQNUt5uLxekRDU14RBIGO9snylClTaCsMJlSMetUP0v07d1XlTT37bLzjjrsEUoCzpB0rzXWYmtOcpdBCiACpdBqUeAoe+P29UDRoIPQpPIE5BO+y8hKngZZOZvoxqVYv0D69AKYoctWYxkgnKYKTwLpV6rYAaFmXN0oEdjH+3omKdjZI8KeaY06OT9R1tT2VVl+152vSwWZSAJXGW3J93sWmYQgtrW3Geef9AC66cCZnbaJNLx1o95QIdWeAzGnIhSQBvti6BZ7+/e+huFceU1VFV0DXVdC1tEVsRCsBYnprK44YIgFZJKsypG1OoOsWN+OT0o6LWkTN4j+dyKRYkE5roGnUBxihUI4giuLiUChER01JZtMi3Jw9olBSUvLE0mVLm99/710xEPCY8x9cCMFQiCM88fXurCzb6j19Jvlzc3Jg4NDB8ObHH8E9P78bkrEEuDxEWky7/EVvlCgRG7RWFrt0kCm9UdMtCNtiWk0QbCaKJKDFEDNIZUWAlfqiaQZz/KKuqc2JhPyEfcyXO2QF2Gu2KAhi619fW7bwkT/8TmxoaDKp1rZw4cPscw4KjlfxyVYCWc0lS5BOpOHuW26Dy+fOg5qOFvjbW29BvCPKPkuObqVBdqpsT5rdioswtB9v9aoomvUhqxDr8dD2niUG0ZlMzsJuJEAyqTIxEkXRzAkGRN3QF4ZCAj2XQMhnHDkIYBQQ/0HExfv27t348MMLaYbGdddeD7NnXw6apnFAzG6OSzDnd+gvWYPsJNI2lgGKpkE8EoU/LnoKzpt2LshuHySjCR6a+L81abRiApfc6QSG9W325BTFigHZjwcE/AFbfhNQ6KTtlPeTwhRVB9NEo3fvPFlXlY1er3+x85yBI0f2GIwg8ouCgoLrlix5If7mm28IPp8fn3j8SRgzZmyPSrARxFGXFUHOZiL07dMXpk4/lwVqC7dDr9wQ3HLj9TBp0gQIUN3BXmLp+gyXIFczESQyBSU+rBvL4RMJUpqFFafl9cqz1MdZqV0hEgAUTYd4QiHrYyDgpepB3EC4zj5O75xfOErJNgpAoqc0RFG85fbbbxW3b99qnNCnDyxb9joMG1bKSrA3VDODW0qw/6fMThQgEu4AJZ5kwYv7F/OPqWQCBg4cAL6ADwSTdtYEjgWZ2EKMUhJAFxDQqerYAa893JGR32Ec/foVdRrA3iAlyMfiClkeXC7JyM0Nioah3eL1enc5gS+jwW4ocxqdDyKsLw2Hw4/PmzdHbmho0GjzZPnyFVBaOpxXBkons4Oi0ygw845OMgUbNmzkuv+61Wth744qCAZzQXC7QDVV0FAHA3Qrajs3Uy7EpTPJLjh0ZpWN"
    . "hw7bCujcrC0utgo4FDQJyrpJwqetoC0KWmFhvmzq6uMej38pyUTUN1v44zWyZ+ao7Pjxpx73qGznGQIxcxz2ucVL8MbbbrOOtQJgr4Afb73+OqzcRATMaoqa5CNyqWScD0rRqRA1raCaUlBJp3l/QKPzQaqCkydO4H5clJQJ1gny7ZXf8AkyjRKpeBybmtt47+/IkVaV+tc0lY/KkuW/y4NWvKyuWcNoWE5nb7/tsDRlkDTeD2ZMR123DjuvXr8OZ9HBapeVTXpFGa+YNQs/XLkCk+H2jDIMXcV0KonJeBIT8QQmSahkAg1NwZbGwziofzHfL3NWKmBZxUiMJ5JoqGmMRaIkNB4+3Cm8Yeh8WJrOBn4X4Z1mH5dnJbxBu6tdjss/+TQfX6WJuekYuyRhydAS/KZyO5qGjvF4JCPgZ199iVdfey36QtaWOL1Gl5biL++6E1ev+gBbDx9G07CU5jTTYEPiV19sRJdEp8sEPq5H91538438W2sLWb2V0lyzubmN6C0ahpY5Lm8fjvxejXOrzgcmCviBiXRa7/GBiYljx2HL/np6cAgVlQ40xTGdjGeE+mbPHpz/299gxUmju9QHigrycfpZZ+Gv7rwT//ryy/jP1auxfncNNh9qwJt/+hNWLu3zO8p7b9UqTCTSeOhQEzYcbtbDYUvZhqE9asNe+D6W797YHbIfmbn11tu6PDKzcuX7SKfMLvrhBbhj02Y8sH0nKh0RVJU0H3pIEbxZEZaVO5Jx/HDdWrx7/nwcP3kS+kOhLgrhxEUQsE9ury7fn3PONHzv/VXY1hYh4c3GxhbNMAzUdS2qKwo9zsNW/1eF71xUv73ZVFsw/H7/qEQi8czw4cOnzJ+/AGb+6GI9mOOVmpvbhUg0AoMGFkO0pRVMRYVehQUgEGNjnkCM3ipsul1u3v6mptFJsMYm2F61EzZ9+Tns3b0H6g7Wg6aqcGD3PpAEEaZPnw5XXHElnHnmJLIExuNxI5jjl4OhHKo3rtWTqds8wSA9gPBff6DyqMfm6DnBvy9fgdFoSm9rixqHDh5hC7U2t2FrUzOmYjE+9UFI0NU0nwJTVasUlk4QSuKI9hMimRVC1zGeSOHHH33CD19q7N1oRCJJvSNsnRM0dPWwruuZx+a+y0OU/w4CuvMHrgFmPzg588ILC19a8icQPR5MJVMGpV5EuqnR7g9tiEp0Ykyy2J/1LAtaOR/l9XwCzGQuQByDDlX3LmQXMPftq5M+WPW+8PXmr+DBB37VMrRs+IvxePyp4Pd8cPK7KsBphAaDDjEOKOvft66q7qrrLr983jMvvnSSN5gD6bQK8USSdnC5ikV+SS87h8gam/cP6HdLI0hPgbiEcHu7uPHzjfDp6k9gzdpPoaGhoRIA/jJjxoxlq1atOuKs8f8OwflvNCZN1LG9Uoib126YhGg8qmnqlqSSShpooqHSMVcV43E6+BDB1tZ2bGmxXq2tYaQonkgkUVMtrKejUTypooIyoC30"
    . "KBwATKLgllV3+E7kpqfo/p9qrAhRFHXnPBBZWwGl3APyODWVHiNJcjmIQgkC9qYUHU3BbVVxUAVBiImC2AqItZLLXV23d+/WwaWlXyNiNZ32pNKXTb2J3BhOOvt92/8DNc/dhzdOYVcAAAAASUVORK5CYII="
ASSET_DIR := A_Temp "\AutoReconnectRoblox"
try DirCreate(ASSET_DIR)
try Base64ToFile(LOGO_SIDE_B64, ASSET_DIR "\side.png")
try Base64ToFile(LOGO_CARD_B64, ASSET_DIR "\card.png")
try Base64ToFile(LOGO_ICO_B64, ASSET_DIR "\app.ico")
try TraySetIcon(ASSET_DIR "\app.ico")
LOGO_URL := "https://raw.githubusercontent.com/" GITHUB_REPO "/" GITHUB_BRANCH "/logo.png"

g := Gui("-Caption +MinimizeBox", APP_NAME)
g.BackColor := C_BG
g.MarginX := 0, g.MarginY := 0

; ---- barra lateral ----
sideBg := g.Add("Text", Format("x0 y0 w{} h{} +0x4000000 Background{}", SIDE, H, C_SIDE))
Bg(sideBg)

try g.Add("Picture", "x20 y22 w40 h40", ASSET_DIR "\side.png")
FontUI(g, "s11 w700")
g.Add("Text", Format("x68 y24 w116 c{} Background{}", C_TEXT, C_SIDE), "Auto Reconnect")
FontUI(g, "s7 w700")
g.Add("Text", Format("x69 y+1 w100 c{} Background{}", C_DIM, C_SIDE), "ROBLOX")

; abas agrupadas: cada item da barra lateral pode ter sub-abas no topo
GROUPS := Map("Início", ["Início"], "Jogo", ["Jogo", "Janela", "Contas"], "Automação", ["Automação", "Opções"]
    , "Discord", ["Webhook", "Bot"], "Moedas", ["Moedas", "Histórico"], "Aparência", ["Aparência"]
    , "Logs", ["Logs"], "Sobre", ["Sobre"])
GROUP_OF := Map()
for gk, subs in GROUPS
    for sb in subs
        GROUP_OF[sb] := gk
AddNav("Início",    Chr(0xE80F), 92)
AddNav("Jogo",      Chr(0xE7FC), 134)
AddNav("Automação", Chr(0xE916), 176)
AddNav("Discord",   Chr(0xE8F2), 218)
AddNav("Moedas",    Chr(0xE8C7), 260)
AddNav("Aparência", Chr(0xE790), 302)
AddNav("Logs",      Chr(0xE81C), 344)
AddNav("Sobre",     Chr(0xE946), 386)
navBar := g.Add("Text", Format("x8 y{} w3 h18 Background{}", 102, C_ACC))

FontUI(g, "s10")
sideDot := g.Add("Text", Format("x24 y{} w14 c{} Background{}", H - 62, C_DIM, C_SIDE), "●")
FontUI(g, "s9 w600")
sideStat := g.Add("Text", Format("x42 y{} w130 c{} Background{}", H - 61, C_TEXT, C_SIDE), TT("idle"))
FontUI(g, "s8")
g.Add("Text", Format("x24 y+4 w150 c{} Background{}", C_DIM, C_SIDE), USER_NAME "  ·  v" VERSION)
FontUI(g, "s7 w700")
sideLic := g.Add("Text", Format("x24 y+2 w150 c{} Background{}", C_DIM, C_SIDE), "")

; ---- botões da janela (topo direito) ----
MakeBtn(g, W - 46,  0, 46, 34, Chr(0xE8BB), (*) => (FadeHide(g), ExitApp()), "close", true, "s9", 0, C_BG)
MakeBtn(g, W - 92,  0, 46, 34, Chr(0xE921), (*) => (chkTray.Value ? FadeHide(g) : FadeMin(g)), "ghost", true, "s9", 0, C_BG)
hbCompact := MakeBtn(g, W - 138, 0, 46, 34, Chr(0xE73F), (*) => SetCompact(true), "ghost", true, "s9", 0, C_BG)
hbLang := MakeBtn(g, W - 184, 0, 46, 34, Chr(0xE774), (*) => LangMenu(), "ghost", true, "s9", 0, C_BG)

; ---- selo "nova versão" (fica escondido até achar atualização) ----
updBadge := MakeBtn(g, W - 184 - 196, 6, 188, 24, "", (*) => ShowPage("Sobre"), "primary", false, "s8 w700", 24)
updBadge.Visible := false

; ---- título da página ----
FontUI(g, "s17 w700")
pageTitle := g.Add("Text", Format("x{} y26 w190 c{} Background{}", CX, C_TEXT, C_BG), "")
FontUI(g, "s9")
pageSub := g.Add("Text", Format("x{} y+2 w{} c{} Background{}", CX, CW, C_MUTED, C_BG), "")

; ---------------- Página: Início ----------------
BeginPage("Início", TT("nav_home"), TT("pg_home_sub", USER_FIRST))
y := 92
Card(CX, y, CW, 96)
dashDot   := Lbl(CX + 22, y + 26, 30, "●", "s20", C_DIM)
dashTitle := Lbl(CX + 58, y + 22, 290, TT("idle"), "s16 w700")
dashSub   := Lbl(CX + 59, y + 56, 300, TT("click_start"), "s9", C_MUTED)
btnStart  := Btn(CX + CW - 152, y + 29, 132, 38, TT("btn_start"), Toggle, "primary")

y := 200, sw := (CW - 36) // 4
stVals := []
for i, lab in [TT("st_uptime"), TT("st_reopens"), TT("st_drops"), TT("st_lastdrop")] {
    sx := CX + (i - 1) * (sw + 12)
    Card(sx, y, sw, 84)
    Lbl(sx + 18, y + 16, sw - 30, lab, "s7 w700", C_DIM)
    stVals.Push(Lbl(sx + 18, y + 38, sw - 26, "—", (i = 4) ? "s11 w600" : "s15 w700"))
}

y := 296, bw := (CW - 40 - 24) // 3
Card(CX, y, CW, 104)
Lbl(CX + 20, y + 16, 300, TT("quick"), "s7 w700", C_DIM)
Btn(CX + 20,                y + 46, bw, 38, TT("btn_open_now"),  (*) => LaunchGame(true))
Btn(CX + 20 + (bw + 12),    y + 46, bw, 38, TT("btn_place"), (*) => ForcePlace())
Btn(CX + 20 + (bw + 12) * 2, y + 46, bw, 38, TT("btn_compact"),    (*) => SetCompact(true))

; ---------------- Página: Jogo ----------------
BeginPage("Jogo", TT("nav_game"), TT("pg_game_sub"))
y := 92
Card(CX, y, CW, 108)
Lbl(CX + 20, y + 16, 300, TT("sec_server"), "s7 w700", C_DIM)
edLink := Input(CX + 20, y + 38, CW - 40, savedLink)
Lbl(CX + 20, y + 78, CW - 40, TT("hint_link"), "s8", C_MUTED)

y := 212, half := (CW - 40) // 2
Card(CX, y, CW, 110)
Lbl(CX + 20, y + 16, 300, TT("sec_monitor"), "s7 w700", C_DIM)
Lbl(CX + 20, y + 40, half, TT("lbl_check"), "s9", C_MUTED)
edInterval := Input(CX + 20, y + 62, 120, savedInterval, "Number")
Lbl(CX + 20 + half, y + 40, half, TT("lbl_wait"), "s9", C_MUTED)
edWait := Input(CX + 20 + half, y + 62, 120, savedWait, "Number")

y := 334
Card(CX, y, CW, 132)
Lbl(CX + 20, y + 16, 300, TT("sec_recovery"), "s7 w700", C_DIM)
chkErr := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_err"), savedErr, TT("sw_err_sub"))
Lbl(CX + 20, y + 96, 200, TT("lbl_tol"), "s9", C_MUTED)
edErrSec := Input(CX + 170, y + 89, 90, savedErrSec, "Number")

; ---------------- Página: Janela ----------------
BeginPage("Janela", TT("nav_window"), TT("pg_win_sub"))
y := 92
Card(CX, y, CW, 142)
Lbl(CX + 20, y + 16, 300, TT("sec_pos"), "s7 w700", C_DIM)
chkShrink := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_place"), savedShrink, TT("sw_place_sub"))
Lbl(CX + 20, y + 98, 60, TT("lbl_width"), "s9", C_MUTED)
edW := Input(CX + 78, y + 91, 80, winW, "Number")
Lbl(CX + 178, y + 98, 50, TT("lbl_height"), "s9", C_MUTED)
edH := Input(CX + 228, y + 91, 80, winH, "Number")
Btn(CX + CW - 170, y + 91, 150, 32, TT("btn_place_now"), (*) => ForcePlace())
edW.OnEvent("Change", (*) => (winW := Integer(edW.Value || 800)))
edH.OnEvent("Change", (*) => (winH := Integer(edH.Value || 630)))

y := 246
Card(CX, y, CW, 96)
Lbl(CX + 20, y + 16, 300, TT("sec_browser"), "s7 w700", C_DIM)
chkMin := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_tab"), savedMin, TT("sw_tab_sub"))

; ---------------- Página: Webhook ----------------
BeginPage("Webhook", TT("nav_hook"), TT("pg_hook_sub"))
y := 92
Card(CX, y, CW, 100)
Lbl(CX + 20, y + 16, 300, "DISCORD", "s7 w700", C_DIM)
edHook := Input(CX + 20, y + 38, CW - 40 - 132, savedHook)
btnHookTest := Btn(CX + CW - 140, y + 38, 120, 32, TT("btn_test"), (*) => SendEvent("test", [TT("d_test")], true))
Lbl(CX + 20, y + 76, CW - 40, TT("hint_hook"), "s8", C_MUTED)

y := 204
Card(CX, y, CW, 126)
Lbl(CX + 20, y + 16, 300, TT("sec_mention"), "s7 w700", C_DIM)
chkMention := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_mention"), savedMention, TT("sw_mention_sub"))
Lbl(CX + 20, y + 94, 150, TT("lbl_discord_id"), "s9", C_MUTED)
edDiscId := Input(CX + 170, y + 87, 210, savedDiscId, "Number")
Btn(CX + CW - 130, y + 87, 110, 32, TT("btn_how"), (*) => (ToolTip(TT("hint_discord_id")), SetTimer(() => ToolTip(), -9000)))

y := 342
Card(CX, y, CW, 140)
Lbl(CX + 20, y + 16, 300, TT("sec_status"), "s7 w700", C_DIM)
chkRep := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_rep"), savedRep, TT("sw_rep_sub"))
chkRep.onChange := ApplyReportTimer
Lbl(CX + 20, y + 98, 120, TT("lbl_interval"), "s9", C_MUTED)
edRepMin := Input(CX + 150, y + 91, 80, savedRepMin, "Number")
Btn(CX + CW - 160, y + 91, 140, 32, TT("btn_send_now"), (*) => SendStatusReport(true))

; ---------------- Página: Moedas ----------------
BeginPage("Moedas", TT("nav_coins"), TT("pg_coins_sub"))
y := 92
Card(CX, y, CW, 166)
Lbl(CX + 20, y + 16, 300, TT("sec_ocr"), "s7 w700", C_DIM)
chkOcr := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_ocr"), savedOcr, TT("sw_ocr_sub"))
Lbl(CX + 20, y + 94, CW - 40, TT("lbl_coins"), "s9", C_MUTED)
edCur := Input(CX + 20, y + 116, CW - 40, savedCur)

y := 270
Card(CX, y, CW, 150)
Lbl(CX + 20, y + 16, 300, TT("sec_lastread"), "s7 w700", C_DIM)
Btn(CX + CW - 160, y + 12, 140, 32, TT("btn_testread"), (*) => TestCurrencies())
FontMono(g, "s9")
curView := P(g.Add("Text", Format("x{} y{} w{} h{} c{} Background{}", CX + 20, y + 52, CW - 40, 84, C_TEXT, C_CARD)
    , TT("no_read")))

y := 432
Card(CX, y, CW, 136)
Lbl(CX + 20, y + 16, 300, TT("sec_stuck"), "s7 w700", C_DIM)
chkStuck := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_stuck"), savedStuck, TT("sw_stuck_sub"))
Lbl(CX + 20, y + 98, 170, TT("lbl_stuck_min"), "s9", C_MUTED)
edStuckMin := Input(CX + 190, y + 91, 70, savedStuckMin, "Number")
btnStuckAct := Btn(CX + CW - 200, y + 91, 180, 32, StuckActName(stuckAct), (*) => 0)
btnStuckAct.OnEvent("Click", CycleStuckAct.Bind(btnStuckAct))

; ---------------- Página: Contas (várias contas) ----------------
BeginPage("Contas", TT("nav_accounts"), TT("pg_acc_sub"))
y := 92
Card(CX, y, CW, 86)
chkMulti := ToggleSwitch(CX + 20, y + 22, CW - 40, TT("sw_multi"), savedMulti, TT("sw_multi_sub"))

y := 190
Card(CX, y, CW, 290)
FontUI(g, "s9")
lvAcc := P(g.Add("ListView", Format("x{} y{} w{} h{} -E0x200 -Multi +LV0x10000 Background{} c{}"
    , CX + 16, y + 14, CW - 32, 190, C_CARD, C_TEXT), [TT("col_account"), TT("col_status"), TT("f_reopens"), TT("col_link")]))
lvAcc.ModifyCol(1, 140), lvAcc.ModifyCol(2, 150), lvAcc.ModifyCol(3, 80), lvAcc.ModifyCol(4, 110)
lvAcc.OnEvent("DoubleClick", (lv, row) => (row ? ShowAddAccount(row) : 0))
Lbl(CX + 16, y + 210, CW - 32, TT("acc_dbl_hint"), "s8", C_DIM)
DllCall("uxtheme\SetWindowTheme", "Ptr", lvAcc.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
try DllCall("uxtheme\SetWindowTheme", "Ptr", SendMessage(0x101F, 0, 0, lvAcc), "Str", "DarkMode_ItemsView", "Ptr", 0)
Btn(CX + 16, y + 240, 160, 36, TT("btn_add_acc"), (*) => ShowAddAccount(), "primary")
Btn(CX + 186, y + 240, 110, 36, TT("btn_rem_acc"), (*) => RemoveAccount())
Btn(CX + CW - 186, y + 240, 170, 36, TT("btn_tile"), (*) => TileWindows())

; ---------------- Página: Automação ----------------
BeginPage("Automação", TT("nav_auto"), TT("pg_auto_sub"))
y := 92
Card(CX, y, CW, 186)
Lbl(CX + 20, y + 16, 300, TT("sec_sched"), "s7 w700", C_DIM)
chkSched := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_sched"), savedSched, TT("sw_sched_sub"))
Lbl(CX + 20, y + 96, 40, TT("lbl_from"), "s9", C_MUTED)
edFrom := Input(CX + 70, y + 89, 80, savedFrom)
Lbl(CX + 164, y + 96, 40, TT("lbl_to"), "s9", C_MUTED)
edTo := Input(CX + 210, y + 89, 80, savedTo)
btnAct := Btn(CX + CW - 220, y + 89, 200, 32, TT("lbl_onend") ": " ActName(endAct), (*) => 0)
btnAct.OnEvent("Click", CycleAction.Bind(btnAct))
Lbl(CX + 20, y + 144, 280, TT("lbl_maxh"), "s9", C_MUTED)
edMaxH := Input(CX + 300, y + 137, 70, savedMaxH, "Number")

y := 290
Card(CX, y, CW, 232)
Lbl(CX + 20, y + 16, 300, TT("sec_eco"), "s7 w700", C_DIM)
chkEco := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_eco"), savedEco, TT("sw_eco_sub"))
btnFps := Btn(CX + 20, y + 92, 200, 32, FpsName(ecoFps), (*) => 0)
btnFps.OnEvent("Click", CycleFps.Bind(btnFps))
chkLowGfx := ToggleSwitch(CX + 20, y + 136, CW - 40, TT("sw_lowgfx"), savedLowGfx)
chkMute := ToggleSwitch(CX + 20, y + 166, CW - 40, TT("sw_mute"), savedMute)
chkLowPrio := ToggleSwitch(CX + 20, y + 196, CW - 40, TT("sw_lowprio"), savedLowPrio)

; ---------------- Página: Bot do Discord ----------------
BeginPage("Bot", TT("nav_bot"), TT("pg_bot_sub"))
y := 92
Card(CX, y, CW, 252)
Lbl(CX + 20, y + 16, 300, TT("sec_bot"), "s7 w700", C_DIM)
chkBot := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_bot"), savedBot, TT("sw_bot_sub"))
Lbl(CX + 20, y + 96, 120, TT("lbl_token"), "s9", C_MUTED)
edToken := Input(CX + 140, y + 89, CW - 160, DpapiUnprotect(IniRead(iniFile, "cfg", "botToken", "")), "Password")
Lbl(CX + 20, y + 140, 120, TT("lbl_channel"), "s9", C_MUTED)
edChan := Input(CX + 140, y + 133, 220, savedBotChan, "Number")
botStatus := Lbl(CX + 20, y + 180, CW - 40, TT("bot_off"), "s9 w600", C_TEXT)
Lbl(CX + 20, y + 202, CW - 40, TT("bot_setup"), "s8", C_MUTED)

y := 356
Card(CX, y, CW, 132)
Lbl(CX + 20, y + 16, 300, TT("sec_panel"), "s7 w700", C_DIM)
chkPanel := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_panel"), savedPanel, TT("sw_panel_sub"))
chkPanel.onChange := (*) => SetTimer(() => PanelUpdate(true), -500)
Lbl(CX + 20, y + 98, 200, TT("lbl_panel_min"), "s9", C_MUTED)
edPanelMin := Input(CX + 220, y + 91, 70, savedPanelMin, "Number")
Btn(CX + CW - 160, y + 91, 140, 32, TT("btn_send_now"), (*) => PanelUpdate(true))

y := 500
Card(CX, y, CW, 56)
Lbl(CX + 20, y + 19, CW - 40, TT("bot_hint_help"), "s9", C_MUTED)

; ---------------- Página: Histórico ----------------
BeginPage("Histórico", TT("nav_hist"), TT("pg_hist_sub"))
y := 92
Card(CX, y, CW, 430)
histBtns := Map()
histBtns["online"]  := Btn(CX + 20, y + 16, 120, 32, TT("hist_online"), SetHistMetric.Bind("online"), "primary")
histBtns["drops"]   := Btn(CX + 148, y + 16, 100, 32, TT("f_drops"), SetHistMetric.Bind("drops"))
histBtns["reopens"] := Btn(CX + 256, y + 16, 110, 32, TT("f_reopens"), SetHistMetric.Bind("reopens"))
histBtns["coin"]    := Btn(CX + 374, y + 16, CW - 394, 32, TT("hist_coin", "…"), SetHistMetric.Bind("coin"))
histBase := y + 390
histBars := [], histVals := [], histDays := []
slotW := (CW - 40) // 14
Loop 14 {
    bx := CX + 20 + (A_Index - 1) * slotW
    histBars.Push(P(g.Add("Text", Format("x{} y{} w{} h2 Background{}", bx + (slotW - 20) // 2, histBase - 2, 20, A_Index = 14 ? C_ACC : C_DIM))))
    FontUI(g, "s7 w600")
    histVals.Push(P(g.Add("Text", Format("x{} y{} w{} Center c{} Background{}", bx, histBase - 20, slotW, C_MUTED, C_CARD), "")))
    FontUI(g, "s7")
    histDays.Push(P(g.Add("Text", Format("x{} y{} w{} Center c{} Background{}", bx, histBase + 8, slotW, C_DIM, C_CARD), "")))
}
histEmpty := Lbl(CX + 20, y + 200, CW - 40, TT("hist_empty"), "s9", C_MUTED)
histEmpty.Opt("+Center")

; ---------------- Página: Opções ----------------
BeginPage("Opções", TT("nav_opts"), TT("pg_opts_sub"))
y := 92
Card(CX, y, CW, 132)
Lbl(CX + 20, y + 16, 300, TT("sec_startup"), "s7 w700", C_DIM)
chkStartWin := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_startwin"), savedStartWin, TT("sw_startwin_sub"))
chkStartWin.onChange := (*) => SetStartup(chkStartWin.Value)
chkAutoMon := ToggleSwitch(CX + 20, y + 86, CW - 40, TT("sw_automon"), savedAutoMon, TT("sw_automon_sub"))

y := 236
Card(CX, y, CW, 132)
Lbl(CX + 20, y + 16, 300, TT("sec_notify"), "s7 w700", C_DIM)
chkToast := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_toast"), savedToast, TT("sw_toast_sub"))
chkTray := ToggleSwitch(CX + 20, y + 86, CW - 40, TT("sw_tray"), savedTray, TT("sw_tray_sub"))

y := 380
Card(CX, y, CW, 120)
Lbl(CX + 20, y + 16, 300, TT("sec_daily"), "s7 w700", C_DIM)
chkDaily := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_daily"), savedDaily)
Lbl(CX + 20, y + 84, 140, TT("lbl_daily_time"), "s9", C_MUTED)
edDailyAt := Input(CX + 170, y + 77, 90, savedDailyAt)
Btn(CX + CW - 160, y + 77, 140, 32, TT("btn_send_now"), (*) => SendDailySummary(true))

; ---------------- Página: Sobre ----------------
BeginPage("Sobre", TT("nav_about"), TT("pg_about_sub"))
y := 92
Card(CX, y, CW, 104)
Lbl(CX + 20, y + 16, 300, TT("sec_version"), "s7 w700", C_DIM)
Lbl(CX + 20, y + 36, 140, "v" VERSION, "s20 w700")
Btn(CX + CW - 340, y + 34, 150, 38, TT("btn_tour"), (*) => StartTour())
updStatus := Lbl(CX + 20, y + 76, CW - 210, TT("upd_never"), "s9", C_MUTED)
btnUpd := Btn(CX + CW - 180, y + 34, 160, 38, TT("btn_checkupd"), (*) => (pendingUpd != "" ? ApplyUpdate() : CheckUpdate(true)))

y := 208
Card(CX, y, CW, 80)
Lbl(CX + 20, y + 16, 300, TT("sec_license"), "s7 w700", C_DIM)
licInfo := Lbl(CX + 20, y + 38, CW - 200, "—", "s10 w600")
licSub  := Lbl(CX + 20, y + 58, CW - 200, "", "s8", C_MUTED)
if KaEnabled()
    Btn(CX + CW - 150, y + 24, 130, 32, TT("btn_changekey"), (*) => ShowKeyScreen(TT("paste_new_key")))

y := 300
Card(CX, y, CW, 172)
chkAutoUpd := ToggleSwitch(CX + 20, y + 14, CW - 40, TT("sw_autoupd"), savedAutoUpd)
Lbl(CX + 20, y + 52, 300, TT("sec_news"), "s7 w700", C_DIM)
FontUI(g, "s9")
changeBox := P(g.Add("Edit", Format("x{} y{} w{} h{} ReadOnly +Multi +VScroll -E0x200 c{} Background{}"
    , CX + 20, y + 72, CW - 40, 88, C_TEXT, C_CARD), TT("news_ph")))
DllCall("uxtheme\SetWindowTheme", "Ptr", changeBox.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)

; ---------------- Página: Aparência ----------------
BeginPage("Aparência", TT("nav_look"), TT("pg_look_sub"))
y := 92
Card(CX, y, CW, 470)
Lbl(CX + 20, y + 16, 300, TT("sec_theme"), "s7 w700", C_DIM)
tw := (CW - 40 - 36) // 4, thh := 66
for i, th in THEMES
    ThemeTile(CX + 20 + Mod(i - 1, 4) * (tw + 12), y + 44 + ((i - 1) // 4) * (thh + 34), tw, thh, th)

; ---------------- Página: Logs ----------------
BeginPage("Logs", TT("nav_logs"), TT("pg_logs_sub"))
y := 92
Card(CX, y, CW, 324)
FontMono(g, "s9")
logBox := P(g.Add("Edit", Format("x{} y{} w{} h{} ReadOnly -Wrap +Multi +VScroll -E0x200 c{} Background{}"
    , CX + 16, y + 14, CW - 32, 296, C_TEXT, C_CARD)))
DllCall("uxtheme\SetWindowTheme", "Ptr", logBox.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
Btn(CX + CW - 110, y + 336, 110, 32, TT("btn_clear"), (*) => (logBox.Value := ""))

curBuild := ""

; ==========================================================
;  GUI compacta
; ==========================================================
gm := Gui("-Caption +AlwaysOnTop +ToolWindow", APP_NAME)
gm.BackColor := C_CARD
gm.MarginX := 0, gm.MarginY := 0
FontUI(gm, "s12")
mDot := gm.Add("Text", Format("x14 y13 w16 c{} Background{}", C_DIM, C_CARD), "●")
FontUI(gm, "s9 w700")
mStat := gm.Add("Text", Format("x34 y9 w128 c{} Background{}", C_TEXT, C_CARD), TT("idle"))
FontUI(gm, "s8")
mSub := gm.Add("Text", Format("x34 y+0 w128 c{} Background{}", C_MUTED, C_CARD), TT("mini_sub", 0, 0))
mBtn := MakeBtn(gm, 166, 11, 70, 30, TT("btn_start"), Toggle, "primary", false, "s9 w600", 10)
MakeBtn(gm, 242, 11, 30, 30, Chr(0xE740), (*) => SetCompact(false), "sec", true, "s9", 10)

; ==========================================================
;  Tela de licença
; ==========================================================
gk := Gui("-Caption +MinimizeBox", APP_NAME)
gk.BackColor := C_CARD
gk.MarginX := 0, gk.MarginY := 0
KW := 420, KH := 330
MakeBtn(gk, KW - 46, 0, 46, 34, Chr(0xE8BB), (*) => KeyClose(), "close", true, "s9", 0, C_CARD)
try gk.Add("Picture", "x32 y30 w48 h48", ASSET_DIR "\card.png")
FontUI(gk, "s16 w700")
gk.Add("Text", Format("x92 y30 w290 c{} Background{}", C_TEXT, C_CARD), TT("key_title"))
FontUI(gk, "s9")
gk.Add("Text", Format("x92 y+2 w296 c{} Background{}", C_MUTED, C_CARD), TT("key_sub"))
kBox := gk.Add("Text", Format("x32 y104 w356 h38 +0x4000000 Background{}", C_INPUT))
Bg(kBox, 10)
FontMono(gk, "s10")
edKey := gk.Add("Edit", Format("x44 y113 w332 h22 -E0x200 c{} Background{}", C_TEXT, C_INPUT), IniRead(iniFile, "cfg", "key", ""))
btnKey := MakeBtn(gk, 32, 156, 356, 40, TT("btn_activate"), (*) => ActivateKey(), "primary", false, "s10 w700", 10)
FontUI(gk, "s9")
kStatus := gk.Add("Text", Format("x32 y208 w356 h36 c{} Background{}", C_MUTED, C_CARD), "")
FontUI(gk, "s7 w700")
gk.Add("Text", Format("x32 y256 w200 c{} Background{}", C_DIM, C_CARD), TT("your_hwid"))
FontMono(gk, "s8")
kHwid := gk.Add("Text", Format("x32 y+3 w250 c{} Background{}", C_MUTED, C_CARD), "")
MakeBtn(gk, 296, 258, 92, 28, TT("btn_copy"), (*) => (A_Clipboard := GetHWID(), kStatus.Value := TT("hwid_copied")), "sec", false, "s9 w600", 8)
if (BUY_URL != "")
    MakeBtn(gk, 32, 296, 120, 22, TT("btn_buy"), (*) => Run(BUY_URL), "ghost", false, "s8 w600", 0, C_CARD)
gk.OnEvent("Close", (*) => KeyClose())

; ---- sub-abas no topo das abas agrupadas ----
segs := Map()
FontUI(g, "s9 w600")
for gk, subs in GROUPS {
    if (subs.Length < 2)
        continue
    segs[gk] := []
    sx := CX
    for sb in subs {
        sc := g.Add("Text", Format("x{} y60 h26 +0x200 Center Background{} c{}", sx, C_BG, C_MUTED), "  " TT(NAVK[sb]) "  ")
        sc.GetPos(, , &sw)
        sc.Move(, , sw + 16)
        sc.OnEvent("Click", ShowPage.Bind(sb))
        hoverMap[sc.Hwnd] := {ctrls: [sc], bg: C_BG, hov: C_NAVH}
        roundQ.Push([sc, 8])
        segs[gk].Push({ctrl: sc, sub: sb})
        sc.Visible := false
        sx += sw + 16 + 6
    }
}
segLine := g.Add("Text", Format("x{} y88 w40 h2 Background{}", CX, C_ACC))
segLine.Visible := false
segFrom := [0, 0], segTo := [0, 0], segT0 := 0

; ---- acabamento ----
FinishGui()
for gg in [g, gm, gk]
    SetWinIcon(gg)
SetupTray()
LoadAccounts()
DayRoll()
HotIf((*) => tourOn)
Hotkey("Esc", (*) => EndTour())
HotIf()
OnMessage(0x201, OnLButtonDown)
OnMessage(0x200, OnMouseMove)

ShowPage("Início")
OnExit(OnQuit)
kHwid.Value := ShortHWID()

if !KaEnabled()
    StartApp()                                   ; key desligada (KEYAUTH_OWNERID vazio)
else if (Trim(edKey.Value) != "") {
    ShowKeyScreen(TT("checking_lic"))
    SetTimer(() => ActivateKey(true), -300)      ; tenta entrar sozinho com a key salva
} else
    ShowKeyScreen("")

; abre o programa de verdade (depois da licença ok)
StartApp() {
    global g, gk, W, H, savedCompact, iniFile, running, appStarted, chkAutoMon, APP_NAME
    FadeHide(gk)
    if appStarted {
        FadeShow(g)
        return
    }
    appStarted := true
    firstRun := IniRead(iniFile, "cfg", "tourDone", "0") != "1" && IniRead(iniFile, "cfg", "resume", "0") != "1"
    if (savedCompact = "1")
        SetCompact(true)
    else
        FadeShow(g, Format("w{} h{}", W, H))
    SetTimer(PulseTick, 110)
    SetTimer(CpuSample, 2000)
    SetTimer(Cleanup, 2000)
    SetTimer(WatchError, 3000)
    SetTimer(UpdateStats, 1000)
    SetTimer(() => CheckUpdate(false), -8000)        ; procura atualização 8s depois de abrir
    SetTimer(() => CheckUpdate(false), 6 * 3600000)  ; e a cada 6 horas
    if KaEnabled()
        SetTimer(LicenseRecheck, 30 * 60000)         ; confere a licença a cada 30 min
    ; voltou de uma atualização automática com o monitoramento ligado -> liga de novo
    if (IniRead(iniFile, "cfg", "resume", "0") = "1") {
        IniDelete(iniFile, "cfg", "resume")
        SetTimer(() => (running ? 0 : Toggle()), -1500)
    }
    if firstRun
        SetTimer(StartTour, -800)    ; primeira vez abrindo: mostra o passo a passo
    else if (chkAutoMon.Value && !running)
        SetTimer(() => (running ? 0 : Toggle()), -2500)
    SetTimer(() => SendStatusReport(), -7000)   ; manda o status com print assim que abre
    SetTimer(DailyTick, 30000)
    SetTimer(ScheduleTick, 30000)
    SetTimer(BotTick, 6000)
    SetTimer(PanelTick, 30000)
    SetTimer(StuckTick, 60000)
    upd := IniRead(iniFile, "cfg", "justUpdated", "")
    if (upd != "") {
        IniDelete(iniFile, "cfg", "justUpdated")
        Notify(TT("ev_updated", upd), APP_NAME)
    }
}

; ==========================================================
;  Helpers da GUI
; ==========================================================
FontUI(gui, opts) {
    gui.SetFont("norm " opts, "Segoe UI")
    gui.SetFont(, "Segoe UI Variable Text")   ; Win11 (se não existir, fica Segoe UI)
}
FontIcon(gui, opts) {
    gui.SetFont("norm " opts, "Segoe MDL2 Assets")
    gui.SetFont(, "Segoe Fluent Icons")
}
FontMono(gui, opts) {
    gui.SetFont("norm " opts, "Consolas")
    gui.SetFont(, "Cascadia Mono")
}

BeginPage(name, title, sub) {
    global pages, pageInfo, curBuild
    pages[name] := []
    pageInfo[name] := [title, sub]
    curBuild := name
}

P(ctrl) {
    global pages, curBuild
    if (curBuild != "")
        pages[curBuild].Push(ctrl)
    return ctrl
}

Bg(ctrl, r := 0) {
    global bgCtrls, roundQ
    bgCtrls.Push(ctrl)
    if r
        roundQ.Push([ctrl, r])
}

Card(x, y, w, h) {
    global g, C_CARD
    c := g.Add("Text", Format("x{} y{} w{} h{} +0x4000000 Background{}", x, y, w, h, C_CARD))
    Bg(c, 18)
    return P(c)
}

Lbl(x, y, w, text, font := "s10", color := "", bg := "") {
    global g, C_TEXT, C_CARD
    FontUI(g, font)
    return P(g.Add("Text", Format("x{} y{} w{} c{} Background{}", x, y, w
        , color = "" ? C_TEXT : color, bg = "" ? C_CARD : bg), text))
}

Input(x, y, w, val, extra := "") {
    global g, C_INPUT, C_TEXT
    box := g.Add("Text", Format("x{} y{} w{} h32 +0x4000000 Background{}", x, y, w, C_INPUT))
    Bg(box, 10)
    P(box)
    FontUI(g, "s10")
    return P(g.Add("Edit", Format("x{} y{} w{} h20 -E0x200 c{} Background{} {}", x + 10, y + 7, w - 20, C_TEXT, C_INPUT, extra), val))
}

BtnColors(style, base) {
    global C_ACC, C_ACCH, C_BG, C_BTN, C_BTNH, C_TEXT, C_MUTED
    switch style {
        case "primary": return [C_ACC, C_ACCH, C_BG]
        case "ghost":   return [base, C_BTN, C_MUTED]
        case "close":   return [base, "C42B1C", C_MUTED]
        default:        return [C_BTN, C_BTNH, C_TEXT]
    }
}

MakeBtn(gui, x, y, w, h, text, fn, style := "sec", icon := false, fs := "s10 w600", r := 10, base := "") {
    global hoverMap, roundQ
    c := BtnColors(style, base)
    icon ? FontIcon(gui, fs) : FontUI(gui, fs)
    b := gui.Add("Text", Format("x{} y{} w{} h{} Center +0x200 Background{} c{}", x, y, w, h, c[1], c[3]), text)
    b.OnEvent("Click", fn)
    hoverMap[b.Hwnd] := {ctrls: [b], bg: c[1], hov: c[2]}
    if r
        roundQ.Push([b, r])
    return b
}

Btn(x, y, w, h, text, fn, style := "sec") {
    global g
    return P(MakeBtn(g, x, y, w, h, text, fn, style))
}

SetBtnStyle(b, style) {
    global hoverMap, hoverCur
    c := BtnColors(style, "")
    o := hoverMap[b.Hwnd]
    o.bg := c[1], o.hov := c[2]
    b.SetFont("c" c[3])
    AnimColor(o, hoverCur = o ? c[2] : c[1], 160)
}

AddNav(name, icon, y) {
    global g, navs, hoverMap, SIDE, C_SIDE, C_MUTED, C_NAVH, C_ACC, NAVK, GROUPS
    FontIcon(g, "s11")
    ic := g.Add("Text", Format("x14 y{} w42 h38 Center +0x200 Background{} c{}", y, C_SIDE, C_MUTED), icon)
    FontUI(g, "s10 w600")
    lb := g.Add("Text", Format("x56 y{} w{} h38 +0x200 Background{} c{}", y, SIDE - 70, C_SIDE, C_MUTED), TT(NAVK[name]))
    o := {ctrls: [ic, lb], bg: C_SIDE, hov: C_NAVH, y: y}
    for c in o.ctrls {
        hoverMap[c.Hwnd] := o
        c.OnEvent("Click", (*) => ShowPage(GROUPS[name][1]))
    }
    navs[name] := o
}

ShowPage(name, *) {
    global pages, pageInfo, navs, pageTitle, pageSub, C_NAVA, C_SIDE, C_NAVH, C_TEXT, C_MUTED, hoverCur
    global GROUP_OF, segs, segLine, NAVK, appStarted, curPage
    grp := GROUP_OF.Has(name) ? GROUP_OF[name] : name
    first := (curPage = "")
    changed := (curPage != name)
    curPage := name
    if (changed && !first && appStarted)
        PageFade()
    for n, list in pages
        if (n != name)
            for c in list
                c.Visible := false
    for c in pages[name]
        c.Visible := true
    ; sub-abas do grupo
    for gk, list in segs
        for sg in list {
            sg.ctrl.Visible := (gk = grp)
            if (gk = grp)
                sg.ctrl.SetFont("c" (sg.sub = name ? C_TEXT : C_MUTED))
        }
    if segs.Has(grp) {
        for sg in segs[grp]
            if (sg.sub = name) {
                sg.ctrl.GetPos(&sx, , &sw)
                SlideSeg(sx + 12, sw - 24, first)
            }
        segLine.Visible := true
    } else
        segLine.Visible := false
    for n, o in navs {
        act := (n = grp)
        o.bg  := act ? C_NAVA : C_SIDE
        o.hov := act ? C_NAVA : C_NAVH
        for c in o.ctrls
            c.SetFont("c" (act ? C_TEXT : C_MUTED))
        AnimColor(o, hoverCur = o ? o.hov : o.bg, 180)
        if act
            SlideNav(o.y + 10)
    }
    if (name = "Histórico")
        SetTimer(HistDraw, -50)
    pageTitle.Value := TT(NAVK[grp])
    pageSub.Value := pageInfo[name][2]
    pageSub.Visible := !segs.Has(grp)
}

; risquinho embaixo da sub-aba ativa deslizando
SlideSeg(x, w, now := false) {
    global segLine, segFrom, segTo, segT0
    segLine.GetPos(&cx, , &cw)
    segFrom := now ? [x, w] : [cx, cw], segTo := [x, w], segT0 := A_TickCount
    SetTimer(SegTick, 15)
}

SegTick() {
    global segLine, segFrom, segTo, segT0
    pr := Min(1, (A_TickCount - segT0) / 220)
    e := EaseOut(pr)
    segLine.Move(Round(segFrom[1] + (segTo[1] - segFrom[1]) * e), , Round(segFrom[2] + (segTo[2] - segFrom[2]) * e))
    segLine.Redraw()
    if (pr >= 1)
        SetTimer(SegTick, 0)
}

; troca de aba suave: cobre o conteúdo com a cor de fundo e vai sumindo
PageFade() {
    global g, cover, coverT0, SIDE, C_BG
    if !DllCall("IsWindowVisible", "Ptr", g.Hwnd)
        return
    k := A_ScreenDPI / 96
    WinGetClientPos(&cx, &cy, &cw, &ch, g.Hwnd)
    if !IsObject(cover) {
        cover := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +E0x20 +Owner" g.Hwnd)
        cover.BackColor := C_BG
    }
    try WinSetTransparent(255, cover.Hwnd)
    cover.Show(Format("NA x{} y{} w{} h{}", cx + Round(SIDE * k), cy + Round(44 * k), cw - Round(SIDE * k), ch - Round(44 * k)))
    coverT0 := A_TickCount
    SetTimer(CoverTick, 15)
}

CoverTick() {
    global cover, coverT0
    pr := Min(1, (A_TickCount - coverT0) / 200)
    try WinSetTransparent(Round(255 * (1 - EaseOut(pr))), cover.Hwnd)
    if (pr >= 1) {
        SetTimer(CoverTick, 0)
        cover.Hide()
    }
}

; quadradinho de prévia de um tema
ThemeTile(x, y, w, h, th) {
    global g, curTheme, C_ACC, C_TEXT, C_MUTED, C_CARD
    sel := (th.name = curTheme)
    if sel {
        ring := g.Add("Text", Format("x{} y{} w{} h{} +0x4000000 Background{}", x - 2, y - 2, w + 4, h + 4, C_ACC))
        Bg(ring, 14), P(ring)
    }
    base := g.Add("Text", Format("x{} y{} w{} h{} +0x4000000 Background{}", x, y, w, h, th.CARD))
    Bg(base, 12), P(base)
    base.OnEvent("Click", SetTheme.Bind(th.name))
    side := P(g.Add("Text", Format("x{} y{} w{} h{} Background{}", x + 7, y + 8, 10, h - 16, th.SIDE)))
    roundQ.Push([side, 6])
    P(g.Add("Text", Format("x{} y{} w{} h4 Background{}", x + 24, y + 12, 34, th.TEXT)))
    P(g.Add("Text", Format("x{} y{} w{} h4 Background{}", x + 24, y + 22, w - 44, th.MUTED)))
    P(g.Add("Text", Format("x{} y{} w{} h4 Background{}", x + 24, y + 32, w - 60, th.DIM)))
    pill := P(g.Add("Text", Format("x{} y{} w26 h10 Background{}", x + w - 34, y + h - 18, th.ACC)))
    roundQ.Push([pill, 10])
    Lbl(x, y + h + 6, w, th.name (sel ? "  ✓" : ""), sel ? "s8 w700" : "s8", sel ? C_TEXT : C_MUTED)
}

SetTheme(name, *) {
    global iniFile, running, curTheme
    if (name = curTheme)
        return
    IniWrite(name, iniFile, "cfg", "theme")
    SaveConfig()
    if running
        IniWrite(1, iniFile, "cfg", "resume")
    Relaunch()
}

RoundCtrl(ctrl, radius) {
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", ctrl.Hwnd, "Ptr", rc)
    r := Round(radius * A_ScreenDPI / 96)
    rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", NumGet(rc, 8, "Int") + 1
        , "Int", NumGet(rc, 12, "Int") + 1, "Int", r, "Int", r, "Ptr")
    DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", rgn, "Int", 1)
}

; ==========================================================
;  Tutorial passo a passo (escurece a tela, marca o item, seta + balão)
; ==========================================================
TourSteps() {
    global edLink, edHook, btnHookTest, chkShrink, edCur, btnStart, hbCompact, hbLang, btnUpd
    return [
        {page: "Início",  t: "tour_welcome_t", d: "tour_welcome", targets: [],                          pad: 0},
        {page: "Jogo",    t: "tour_link_t",    d: "tour_link",    targets: [edLink],                    pad: 10},
        {page: "Webhook", t: "tour_hook_t",    d: "tour_hook",    targets: [edHook],                    pad: 10},
        {page: "Webhook", t: "tour_test_t",    d: "tour_test",    targets: [btnHookTest],               pad: 4},
        {page: "Janela",  t: "tour_win_t",     d: "tour_win",     targets: [chkShrink.lbl, chkShrink.pill], pad: 8},
        {page: "Moedas",  t: "tour_coins_t",   d: "tour_coins",   targets: [edCur],                     pad: 10},
        {page: "Início",  t: "tour_start_t",   d: "tour_start",   targets: [btnStart],                  pad: 4},
        {page: "",        t: "tour_compact_t", d: "tour_compact", targets: [hbCompact],                 pad: 2},
        {page: "",        t: "tour_lang_t",    d: "tour_lang",    targets: [hbLang],                    pad: 2},
        {page: "Sobre",   t: "tour_upd_t",     d: "tour_upd",     targets: [btnUpd],                    pad: 4},
        {page: "Início",  t: "tour_done_t",    d: "tour_done",    targets: [],                          pad: 0}
    ]
}

StartTour(*) {
    global tourOn, tourIdx, gm, g
    if DllCall("IsWindowVisible", "Ptr", gm.Hwnd)
        SetCompact(false)
    tourOn := true, tourIdx := 1
    WinActivate(g.Hwnd)
    ShowTourStep()
    SetTimer(TourWatch, 250)
}

; acompanha a janela principal durante o tutorial:
; minimizou/escondeu -> esconde o tutorial; voltou ou mudou de lugar -> desenha de novo
TourWatch() {
    global g, gm, tourOn, tourWins, tourPos, tourHidden
    if !tourOn {
        SetTimer(TourWatch, 0)
        return
    }
    if DllCall("IsWindowVisible", "Ptr", gm.Hwnd)     ; foi pro modo compacto -> encerra
        return EndTour()
    if (!DllCall("IsWindowVisible", "Ptr", g.Hwnd) || DllCall("IsIconic", "Ptr", g.Hwnd)) {
        if !tourHidden {
            for w in tourWins
                try w.Hide()
            tourHidden := true
        }
        return
    }
    WinGetPos(&x, &y, &w, &h, g.Hwnd)
    if (tourHidden || (x "," y "," w "," h) != tourPos) {
        tourHidden := false
        ShowTourStep()
    }
}

EndTour(*) {
    global tourOn, iniFile
    SetTimer(TourWatch, 0)
    TourClear()
    tourOn := false
    IniWrite(1, iniFile, "cfg", "tourDone")
    ShowPage("Início")
}

TourGo(delta, *) {
    global tourIdx
    n := TourSteps().Length
    if (tourIdx + delta > n)
        return EndTour()
    tourIdx := Max(1, tourIdx + delta)
    ShowTourStep()
}

TourClear() {
    global tourWins, hoverCur
    hoverCur := 0
    for w in tourWins
        try w.Destroy()
    tourWins := []
}

Clamp(v, lo, hi) {
    return Max(lo, Min(v, hi))
}

ShowTourStep() {
    global g, tourIdx, tourWins, tourPos, USER_FIRST, C_CARD, C_TEXT, C_MUTED, C_DIM, C_ACC
    TourClear()
    steps := TourSteps(), st := steps[tourIdx], last := (tourIdx = steps.Length)
    if (st.page != "")
        ShowPage(st.page)
    Sleep(60)
    k := A_ScreenDPI / 96
    WinGetPos(&gx, &gy, &gw, &gh, g.Hwnd)
    tourPos := gx "," gy "," gw "," gh

    ; área do item marcado (coordenadas de tela)
    has := st.targets.Length > 0
    if has {
        L := 99999, Tp := 99999, R := -99999, B := -99999
        for c in st.targets {
            WinGetPos(&cx, &cy, &cw, &ch, c.Hwnd)
            L := Min(L, cx), Tp := Min(Tp, cy), R := Max(R, cx + cw), B := Max(B, cy + ch)
        }
        pad := Round(st.pad * k)
        L -= pad, Tp -= pad, R += pad, B += pad
    }
    rr := Round(14 * k)

    ; 1) fundo escuro com um "buraco" no item
    ov := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +Owner" g.Hwnd)
    ov.BackColor := "000000"
    ov.Show(Format("NA x{} y{} w{} h{}", gx, gy, gw, gh))
    WinSetTransparent(170, ov)
    rgn := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", gw, "Int", gh, "Ptr")
    if has {
        hole := DllCall("CreateRoundRectRgn", "Int", L - gx, "Int", Tp - gy, "Int", R - gx + 1, "Int", B - gy + 1, "Int", rr, "Int", rr, "Ptr")
        DllCall("CombineRgn", "Ptr", rgn, "Ptr", rgn, "Ptr", hole, "Int", 4)   ; RGN_DIFF
        DllCall("DeleteObject", "Ptr", hole)
    }
    DllCall("SetWindowRgn", "Ptr", ov.Hwnd, "Ptr", rgn, "Int", 1)
    tourWins.Push(ov)

    ; 2) moldura branca em volta do item
    if has {
        bd := Max(2, Round(2 * k)), fw := R - L + 2 * bd, fh := B - Tp + 2 * bd
        fr := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +Owner" g.Hwnd)
        fr.BackColor := C_ACC
        fr.Show(Format("NA x{} y{} w{} h{}", L - bd, Tp - bd, fw, fh))
        outer := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", fw + 1, "Int", fh + 1, "Int", rr + 2 * bd, "Int", rr + 2 * bd, "Ptr")
        inner := DllCall("CreateRoundRectRgn", "Int", bd, "Int", bd, "Int", fw - bd + 1, "Int", fh - bd + 1, "Int", rr, "Int", rr, "Ptr")
        DllCall("CombineRgn", "Ptr", outer, "Ptr", outer, "Ptr", inner, "Int", 4)
        DllCall("DeleteObject", "Ptr", inner)
        DllCall("SetWindowRgn", "Ptr", fr.Hwnd, "Ptr", outer, "Int", 1)
        tourWins.Push(fr)
    }

    ; 3) balão com o texto e os botões
    BW := 330
    bu := Gui("-Caption +ToolWindow +Owner" g.Hwnd)
    bu.BackColor := C_CARD
    bu.MarginX := 0, bu.MarginY := 0
    FontUI(bu, "s8 w700")
    bu.Add("Text", Format("x20 y16 w290 c{} Background{}", C_DIM, C_CARD), TT("tour_step", tourIdx, steps.Length))
    FontUI(bu, "s12 w700")
    bu.Add("Text", Format("x20 y+6 w290 c{} Background{}", C_TEXT, C_CARD), TT(st.t, USER_FIRST))
    FontUI(bu, "s9")
    txt := bu.Add("Text", Format("x20 y+6 w290 c{} Background{}", C_MUTED, C_CARD), TT(st.d))
    txt.GetPos(, &ty, , &th)
    by0 := ty + th + 16
    nb := MakeBtn(bu, BW - 20 - 104, by0, 104, 32, TT(last ? "btn_finish" : "btn_next"), TourGo.Bind(1), "primary", false, "s9 w700", 10)
    RoundCtrl(nb, 10)
    if (tourIdx > 1) {
        bb := MakeBtn(bu, BW - 20 - 104 - 8 - 84, by0, 84, 32, TT("btn_back"), TourGo.Bind(-1), "sec", false, "s9 w600", 10)
        RoundCtrl(bb, 10)
    }
    if !last
        MakeBtn(bu, 12, by0, 84, 32, TT("btn_skip"), EndTour, "ghost", false, "s9 w600", 0, C_CARD)
    bu.Show(Format("Hide w{} h{}", BW, by0 + 32 + 18))
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", bu.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", bu.Hwnd, "UInt", 34, "UInt*", 0x00444040, "UInt", 4)
    WinGetPos(, , &bwp, &bhp, bu.Hwnd)

    gap := Round(14 * k)
    if has {
        ; embaixo do item se couber, senão em cima; seta apontando pro item
        cxm := (L + R) // 2
        bx := Clamp(cxm - bwp // 2, 8, A_ScreenWidth - bwp - 8)
        down := (B + gap + bhp < A_ScreenHeight - 8)
        by := down ? B + gap : Tp - gap - bhp
        aw := Round(20 * k), ah := Round(10 * k)
        ax := Clamp(cxm - aw // 2, bx + 14, bx + bwp - aw - 14)
        ay := down ? by - ah + 1 : by + bhp - 1
        ar := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +Owner" g.Hwnd)
        ar.BackColor := C_CARD
        ar.Show(Format("NA x{} y{} w{} h{}", ax, ay, aw, ah))
        pts := Buffer(24, 0)
        for i, xy in (down ? [[0, ah], [aw // 2, 0], [aw, ah]] : [[0, 0], [aw // 2, ah], [aw, 0]])
            NumPut("Int", xy[1], "Int", xy[2], pts, (i - 1) * 8)
        DllCall("SetWindowRgn", "Ptr", ar.Hwnd, "Ptr", DllCall("CreatePolygonRgn", "Ptr", pts, "Int", 3, "Int", 1, "Ptr"), "Int", 1)
        tourWins.Push(ar)
    } else {
        bx := gx + (gw - bwp) // 2, by := gy + (gh - bhp) // 2
    }
    tourWins.Push(bu)
    FadeShow(bu, Format("x{} y{}", bx, by))
}

; ==========================================================
;  Bandeja, inicialização, notificações e resumo diário
; ==========================================================
SetupTray() {
    global APP_NAME
    tm := A_TrayMenu
    tm.Delete()
    tm.Add(TT("tray_open"), (*) => ShowMain())
    tm.Add(TT("tray_toggle"), (*) => Toggle())
    tm.Add(TT("btn_compact"), (*) => SetCompact(true))
    tm.Add()
    tm.Add(TT("tray_exit"), (*) => ExitApp())
    tm.Default := TT("tray_open")
    tm.ClickCount := 1
    A_IconTip := APP_NAME
}

ShowMain() {
    global g, gm, gk
    if DllCall("IsWindowVisible", "Ptr", gk.Hwnd)
        return WinActivate(gk.Hwnd)
    if DllCall("IsWindowVisible", "Ptr", gm.Hwnd)
        return SetCompact(false)
    if DllCall("IsIconic", "Ptr", g.Hwnd)
        WinRestore(g.Hwnd)
    if !DllCall("IsWindowVisible", "Ptr", g.Hwnd)
        FadeShow(g)
    WinActivate(g.Hwnd)
}

; atalho na pasta Inicializar do Windows
SetStartup(on) {
    global APP_NAME, ASSET_DIR
    lnk := A_Startup "\" APP_NAME ".lnk"
    if on {
        try FileCreateShortcut(A_AhkPath, lnk, A_ScriptDir, '"' A_ScriptFullPath '"', APP_NAME, ASSET_DIR "\app.ico")
    } else
        try FileDelete(lnk)
}

; balão de notificação do Windows
Notify(title, text, icon := "Iconi") {
    global chkToast
    if !chkToast.Value
        return
    try TrayTip(text, title, icon)
}

; fecha o processo atual e abre o script de novo (usado depois de atualizar)
Relaunch() {
    Run(A_ComSpec ' /c ping 127.0.0.1 -n 3 >nul & start "" "' A_AhkPath '" "' A_ScriptFullPath '"', , "Hide")
    ExitApp()
}

; tela de key: o X volta pro programa se ele já estiver liberado; senão fecha
KeyClose() {
    global appStarted, licensed, gk, g
    if (appStarted && (!KaEnabled() || licensed)) {
        FadeHide(gk)
        FadeShow(g)
    } else
        ExitApp()
}

; ---- contadores do dia (ficam no config.ini, seção [day]) ----
DayRoll() {
    global iniFile, dayOnline, dayDate
    today := FormatTime(, "yyyyMMdd")
    if (today = dayDate)
        return
    dayDate := today
    old := IniRead(iniFile, "day", "date", "")
    if (old != today) {
        if (old != "")
            HistSave(old)
        IniDelete(iniFile, "day")
        IniWrite(today, iniFile, "day", "date")
        dayOnline := 0
    } else
        dayOnline := Integer(IniRead(iniFile, "day", "online", "0"))
}

DayAdd(key) {
    global iniFile
    DayRoll()
    IniWrite(Integer(IniRead(iniFile, "day", key, "0")) + 1, iniFile, "day", key)
}

; guarda o valor da primeira leitura do dia de cada moeda
DayCoin(name, n) {
    global iniFile
    DayRoll()
    k := RegExReplace(name, "\W", "_")
    if (IniRead(iniFile, "day", "start_" k, "") = "")
        IniWrite(n, iniFile, "day", "start_" k)
    IniWrite(n, iniFile, "day", "last_" k)
}

DailyTick() {
    global chkDaily, edDailyAt, iniFile
    if !chkDaily.Value
        return
    if !RegExMatch(Trim(edDailyAt.Value), "^(\d{1,2}):(\d{2})$", &m)
        return
    if (A_Hour * 60 + A_Min < m[1] * 60 + m[2])
        return
    today := FormatTime(, "yyyyMMdd")
    if (IniRead(iniFile, "cfg", "dailySent", "") = today)
        return
    IniWrite(today, iniFile, "cfg", "dailySent")
    SendDailySummary()
}

SendDailySummary(manual := false) {
    global iniFile, dayOnline, chkOcr
    DayRoll()
    IniWrite(dayOnline, iniFile, "day", "online")
    lines := ["**" TT("f_online_today") ":** ``" DurStr(dayOnline * 1000) "``"
        , "**" TT("f_drops_today") ":** ``" IniRead(iniFile, "day", "drops", "0") "``"
        , "**" TT("f_reopens_today") ":** ``" IniRead(iniFile, "day", "reopens", "0") "``"]
    ; moedas: valor agora - primeira leitura do dia
    hw := FindGameWindow()
    if (chkOcr.Value && hw && WinGetMinMax(hw) != -1) {
        try {
            cur := ReadCurrencies(hw)
            earned := ""
            for c in CurrencySpec() {
                if !cur[2].Has(c.name)
                    continue
                n := ParseNum(cur[2][c.name])
                st := IniRead(iniFile, "day", "start_" RegExReplace(c.name, "\W", "_"), "")
                if (n = "")
                    continue
                if (st = "") {
                    DayCoin(c.name, n)
                    st := n
                }
                d := n - Integer(st)
                earned .= c.emoji "  **" (d >= 0 ? "+" : "") FmtNum(d) "**  ·  " c.name "  (" FmtNum(n) ")`n"
            }
            if (earned != "")
                lines.Push("", "### " TT("d_earned"), RTrim(earned, "`n"))
        }
    }
    SendEvent("daily", lines, manual)
}

; ==========================================================
;  Várias contas (multi-launcher) - experimental
; ==========================================================
; cookie salvo criptografado com a proteção do Windows (só esse usuário desse PC consegue ler)
DpapiProtect(str) {
    buf := Buffer(StrPut(str, "UTF-8")), StrPut(str, buf, "UTF-8")
    inB := Buffer(A_PtrSize * 2, 0), NumPut("UInt", buf.Size - 1, inB, 0), NumPut("Ptr", buf.Ptr, inB, A_PtrSize)
    outB := Buffer(A_PtrSize * 2, 0)
    if !DllCall("crypt32\CryptProtectData", "Ptr", inB, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "Ptr", outB)
        return ""
    n := NumGet(outB, 0, "UInt"), pd := NumGet(outB, A_PtrSize, "Ptr")
    DllCall("crypt32\CryptBinaryToStringW", "Ptr", pd, "UInt", n, "UInt", 0x40000001, "Ptr", 0, "UInt*", &len := 0)
    sb := Buffer(len * 2)
    DllCall("crypt32\CryptBinaryToStringW", "Ptr", pd, "UInt", n, "UInt", 0x40000001, "Ptr", sb, "UInt*", &len)
    DllCall("LocalFree", "Ptr", pd)
    return StrGet(sb, len, "UTF-16")
}

DpapiUnprotect(b64) {
    if (b64 = "")
        return ""
    DllCall("crypt32\CryptStringToBinaryW", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", 0, "UInt*", &n := 0, "Ptr", 0, "Ptr", 0)
    buf := Buffer(n)
    DllCall("crypt32\CryptStringToBinaryW", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", buf, "UInt*", &n, "Ptr", 0, "Ptr", 0)
    inB := Buffer(A_PtrSize * 2, 0), NumPut("UInt", n, inB, 0), NumPut("Ptr", buf.Ptr, inB, A_PtrSize)
    outB := Buffer(A_PtrSize * 2, 0)
    if !DllCall("crypt32\CryptUnprotectData", "Ptr", inB, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "Ptr", outB)
        return ""
    pd := NumGet(outB, A_PtrSize, "Ptr")
    s := StrGet(pd, NumGet(outB, 0, "UInt"), "UTF-8")
    DllCall("LocalFree", "Ptr", pd)
    return s
}

; pedido pra API do Roblox com o cookie da conta (pega o token CSRF sozinho)
RbxCall(method, url, ck, body := "") {
    static csrf := ""
    Loop 2 {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.SetTimeouts(5000, 5000, 15000, 15000)
        http.Open(method, url, false)
        http.SetRequestHeader("Cookie", ".ROBLOSECURITY=" ck)
        http.SetRequestHeader("Referer", "https://www.roblox.com/")
        http.SetRequestHeader("Origin", "https://www.roblox.com")
        http.SetRequestHeader("Content-Type", "application/json")
        if (csrf != "")
            http.SetRequestHeader("X-CSRF-TOKEN", csrf)
        http.Send(body)
        if (http.Status = 403) {
            t := ""
            try t := http.GetResponseHeader("x-csrf-token")
            if (t != "" && t != csrf) {
                csrf := t
                continue
            }
        }
        return http
    }
    return http
}

; confere o cookie e devolve {id, name} da conta (ou 0)
RbxWhoAmI(ck) {
    try {
        r := RbxCall("GET", "https://users.roblox.com/v1/users/authenticated", ck).ResponseText
        if RegExMatch(r, '"id"\s*:\s*(\d+)', &m)
            return {id: m[1], name: JStr(r, "name")}
    }
    return 0
}

; link da aba Jogo -> endereço do PlaceLauncher (resolve link de compartilhamento com o cookie)
PlaceLauncherUrl(ck, bt, link := "") {
    global edLink, shareCache
    link := Trim(link) != "" ? Trim(link) : Trim(edLink.Value), place := "", code := ""
    if RegExMatch(link, "^\d+$")
        place := link
    else if RegExMatch(link, "i)(?:placeId=|games/)(\d+)", &m) {
        place := m[1]
        if RegExMatch(link, "i)(?:privateServerLinkCode|linkCode)=([\w\-]+)", &c)
            code := c[1]
    } else if RegExMatch(link, "i)share(?:_links|-links)?\?.*?code=([\w\-]+)", &c) {
        if !shareCache.Has(c[1]) {
            r := RbxCall("POST", "https://apis.roblox.com/sharelinks/v1/resolve-link", ck
                , '{"linkId":"' c[1] '","linkType":"Server"}').ResponseText
            if !(RegExMatch(r, '"placeId"\s*:\s*(\d+)', &pm) && (lc := JStr(r, "linkCode")) != "")
                throw Error("share link")
            shareCache[c[1]] := [pm[1], lc]
        }
        place := shareCache[c[1]][1], code := shareCache[c[1]][2]
    }
    if (place = "")
        throw Error("link")
    base := "https://assetgame.roblox.com/game/PlaceLauncher.ashx?browserTrackerId=" bt "&placeId=" place "&isPlayTogetherGame=false"
    return code != "" ? base "&request=RequestPrivateGame&linkCode=" code : base "&request=RequestGame"
}

LaunchAccount(acc) {
    ApplyEco()
    ck := DpapiUnprotect(acc.ck)
    bt := Random(100000000000, 999999999999)
    try {
        url := PlaceLauncherUrl(ck, bt, acc.link)
        ticket := RbxCall("POST", "https://auth.roblox.com/v1/authentication-ticket", ck).GetResponseHeader("rbx-authentication-ticket")
        if (ticket = "")
            throw Error("ticket")
        ms := DateDiff(A_NowUTC, "19700101000000", "Seconds") * 1000
        uri := "roblox-player:1+launchmode:play+gameinfo:" ticket "+launchtime:" ms "+placelauncherurl:" UrlEnc(url)
            . "+browsertrackerid:" bt "+robloxLocale:en_us+gameLocale:en_us+channel:+LaunchExp:InApp"
        if (PlayerCommand() != "")
            RunMethod({kind: "exe", target: uri})
        else
            Run(uri)
    } catch as e {
        acc.status := TT("acc_st_err", e.Message)
        Log(TT("log_acc_fail", acc.name, e.Message))
        return false
    }
    acc.lastLaunch := A_TickCount, acc.status := TT("acc_st_opening"), acc.launches++
    Log(TT("log_acc_launch", acc.name))
    return true
}

; segura o "trava" do Roblox pra deixar abrir várias janelas
MultiLock() {
    global multiHandles
    MultiUnlock()
    multiHandles.Push(DllCall("CreateMutexW", "Ptr", 0, "Int", 1, "Str", "ROBLOX_singletonMutex", "Ptr"))
    multiHandles.Push(DllCall("CreateEventW", "Ptr", 0, "Int", 1, "Int", 0, "Str", "ROBLOX_singletonEvent", "Ptr"))
}

MultiUnlock() {
    global multiHandles
    for h in multiHandles
        if h
            DllCall("CloseHandle", "Ptr", h)
    multiHandles := []
}

RobloxPids() {
    m := Map()
    try {
        for pr in ComObjGet("winmgmts:").ExecQuery("Select ProcessId from Win32_Process where Name='RobloxPlayerBeta.exe'")
            m[pr.ProcessId] := true
    }
    return m
}

MultiCheck() {
    global ACCS, pendingAcc, multiN, running
    if !running
        return
    multiN++
    ; 1) conta que acabou de abrir: descobre qual processo novo é dela
    if pendingAcc {
        owned := Map()
        for a in ACCS
            if a.pid
                owned[a.pid] := true
        for pid in RobloxPids()
            if !owned.Has(pid) {
                pendingAcc.pid := pid
                pendingAcc := 0
                SetTimer(TileWindows, -8000)
                break
            }
        if (pendingAcc && A_TickCount - pendingAcc.lastLaunch > 45000) {
            pendingAcc.status := TT("acc_st_err", "timeout")
            pendingAcc := 0
        }
    }
    ; 2) contas que caíram / tela de Disconnected
    for a in ACCS {
        if (a.pid && !ProcessExist(a.pid)) {
            a.pid := 0, a.status := TT("acc_st_down")
            Log(TT("log_acc_down", a.name))
            MarkDisconnect()
            SendEvent("down", ["**" TT("d_account") ":** " a.name])
            continue
        }
        if a.pid {
            hw := WinExist("ahk_pid " a.pid " ahk_exe RobloxPlayerBeta.exe")
            if hw
                a.status := TT("acc_st_on")
            LowPrio(a.pid)
            if (hw && Mod(multiN, 3) = 0 && WinGetMinMax(hw) != -1) {
                if (FindDisconnectDialog(hw) != "") {
                    if (++a.dlg >= 2) {
                        a.dlg := 0
                        Log(TT("log_acc_dlg", a.name))
                        SendEvent("error", ["**" TT("d_account") ":** " a.name, "**" TT("d_reason") ":** " TT("r_disc_screen")])
                        try ProcessClose(a.pid)
                    }
                } else
                    a.dlg := 0
            }
        }
    }
    ; 3) abre uma conta por vez (pra saber qual janela é de quem)
    if !pendingAcc {
        for a in ACCS
            if (!a.pid && A_TickCount - a.lastLaunch > 20000) {
                if LaunchAccount(a)
                    pendingAcc := a
                break
            }
    }
    LvRefresh()
}

; organiza as janelas do Roblox lado a lado
TileWindows(*) {
    hws := []
    for h in WinGetList("ahk_exe RobloxPlayerBeta.exe")
        if (WinGetTitle(h) != "")
            hws.Push(h)
    n := hws.Length
    if !n
        return
    MonitorGetWorkArea(MonitorGetPrimary(), &l, &t, &r, &b)
    cols := Ceil(Sqrt(n)), rows := Ceil(n / cols)
    w := (r - l) // cols, h := (b - t) // rows
    for i, hw in hws {
        try {
            if (WinGetMinMax(hw) != 0)
                WinRestore(hw)
            WinMove(l + Mod(i - 1, cols) * w, t + ((i - 1) // cols) * h, w, h, hw)
        }
    }
}

LoadAccounts() {
    global ACCS, iniFile
    ACCS := []
    Loop Integer(IniRead(iniFile, "accounts", "n", "0"))
        ACCS.Push({name: IniRead(iniFile, "accounts", "name" A_Index, "?"), uid: IniRead(iniFile, "accounts", "uid" A_Index, "")
            , ck: IniRead(iniFile, "accounts", "ck" A_Index, ""), link: IniRead(iniFile, "accounts", "link" A_Index, ""), pid: 0, status: TT("acc_st_off"), launches: 0, lastLaunch: 0, dlg: 0})
    LvRefresh()
}

SaveAccounts() {
    global ACCS, iniFile
    try IniDelete(iniFile, "accounts")
    IniWrite(ACCS.Length, iniFile, "accounts", "n")
    for i, a in ACCS {
        IniWrite(a.name, iniFile, "accounts", "name" i)
        IniWrite(a.uid, iniFile, "accounts", "uid" i)
        IniWrite(a.ck, iniFile, "accounts", "ck" i)
        IniWrite(a.link, iniFile, "accounts", "link" i)
    }
}

LvRefresh() {
    global lvAcc, ACCS
    lvAcc.Opt("-Redraw")
    lvAcc.Delete()
    for a in ACCS
        lvAcc.Add(, a.name, a.status, a.launches, a.link = "" ? TT("link_default") : a.link)
    lvAcc.Opt("+Redraw")
}

RemoveAccount() {
    global lvAcc, ACCS
    r := lvAcc.GetNext()
    if !r
        return
    ACCS.RemoveAt(r)
    SaveAccounts()
    LvRefresh()
}

ShowAddAccount(row := 0) {
    global g, ga, gaCk, gaLink, gaMsg, gaRow, ACCS, C_CARD, C_TEXT, C_MUTED, C_INPUT, C_DIM
    try ga.Destroy()
    gaRow := row
    ga := Gui("-Caption +ToolWindow +Owner" g.Hwnd)
    ga.BackColor := C_CARD
    ga.MarginX := 0, ga.MarginY := 0
    FontUI(ga, "s14 w700")
    ga.Add("Text", Format("x24 y20 w360 c{} Background{}", C_TEXT, C_CARD), row ? TT("acc_edit") ": " ACCS[row].name : TT("btn_add_acc"))
    FontUI(ga, "s7 w700")
    ga.Add("Text", Format("x24 y62 w360 c{} Background{}", C_DIM, C_CARD), TT("acc_cookie"))
    box := ga.Add("Text", Format("x24 y80 w372 h34 Background{}", C_INPUT))
    RoundCtrl(box, 10)
    FontMono(ga, "s9")
    gaCk := ga.Add("Edit", Format("x34 y88 w352 h20 -E0x200 Password c{} Background{}", C_TEXT, C_INPUT))
    FontUI(ga, "s8")
    ga.Add("Text", Format("x24 y122 w372 c{} Background{}", C_MUTED, C_CARD), row ? TT("acc_ck_keep") : TT("acc_cookie_hint"))
    FontUI(ga, "s7 w700")
    ga.Add("Text", Format("x24 y184 w360 c{} Background{}", C_DIM, C_CARD), TT("acc_link"))
    box2 := ga.Add("Text", Format("x24 y202 w372 h34 Background{}", C_INPUT))
    RoundCtrl(box2, 10)
    FontUI(ga, "s9")
    gaLink := ga.Add("Edit", Format("x34 y210 w352 h20 -E0x200 c{} Background{}", C_TEXT, C_INPUT), row ? ACCS[row].link : "")
    gaMsg := ga.Add("Text", Format("x24 y246 w372 h18 c{} Background{}", C_MUTED, C_CARD), "")
    RoundCtrl(MakeBtn(ga, 256, 272, 140, 34, TT("btn_save"), (*) => SaveNewAccount(), "primary", false, "s9 w700", 10), 10)
    RoundCtrl(MakeBtn(ga, 140, 272, 106, 34, TT("btn_cancel"), (*) => ga.Destroy(), "sec", false, "s9 w600", 10), 10)
    ga.Show("Hide w420 h326")
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", ga.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", ga.Hwnd, "UInt", 34, "UInt*", 0x00444040, "UInt", 4)
    WinGetPos(&gx, &gy, &gw, &gh, g.Hwnd)
    WinGetPos(, , &aw, &ah, ga.Hwnd)
    FadeShow(ga, Format("x{} y{}", gx + (gw - aw) // 2, gy + (gh - ah) // 2))
}

SaveNewAccount() {
    global ga, gaCk, gaLink, gaMsg, gaRow, ACCS, C_OFF
    ck := RegExReplace(Trim(gaCk.Value), "^\.ROBLOSECURITY=")
    link := Trim(gaLink.Value)
    ; editando e sem cookie novo: só troca o link
    if (gaRow && ck = "") {
        ACCS[gaRow].link := link
        SaveAccounts(), LvRefresh(), ga.Destroy()
        return
    }
    gaMsg.Value := TT("acc_checking")
    who := RbxWhoAmI(ck)
    if !who {
        gaMsg.SetFont("c" C_OFF)
        gaMsg.Value := TT("acc_invalid")
        return
    }
    for a in ACCS
        if (a.uid = who.id) {
            a.ck := DpapiProtect(ck), a.link := link, a.name := who.name
            SaveAccounts(), LvRefresh(), ga.Destroy()
            return
        }
    ACCS.Push({name: who.name, uid: who.id, ck: DpapiProtect(ck), link: link, pid: 0, status: TT("acc_st_off"), launches: 0, lastLaunch: 0, dlg: 0})
    SaveAccounts()
    LvRefresh()
    Log(TT("acc_added", who.name))
    ga.Destroy()
}

; ==========================================================
;  Agendamento
; ==========================================================
InTimeWindow(a, b) {
    if !(RegExMatch(Trim(a), "^(\d{1,2}):(\d{2})$", &x) && RegExMatch(Trim(b), "^(\d{1,2}):(\d{2})$", &y))
        return true
    now := A_Hour * 60 + A_Min, st := x[1] * 60 + x[2], en := y[1] * 60 + y[2]
    return st <= en ? (now >= st && now < en) : (now >= st || now < en)
}

ScheduleTick() {
    global chkSched, edFrom, edTo, edMaxH, running, monStart, schedPaused
    if chkSched.Value {
        inWin := InTimeWindow(edFrom.Value, edTo.Value)
        if (running && !inWin) {
            Log(TT("log_sched_pause"))
            schedPaused := true
            Toggle()
            EndAction()
            return
        } else if (!running && inWin && schedPaused) {
            schedPaused := false
            Log(TT("log_sched_resume"))
            Toggle()
            return
        }
    }
    hrs := Number(Trim(edMaxH.Value) || 0)
    if (running && hrs > 0 && A_TickCount - monStart > hrs * 3600000) {
        Log(TT("log_maxh"))
        schedPaused := false
        Toggle()
        EndAction()
    }
}

EndAction() {
    global endAct
    lines := []
    if (endAct = 1) {
        KillRoblox()
        lines.Push(TT("act_close"))
    } else if (endAct = 2) {
        lines.Push(TT("d_shutdown"))
        Run("shutdown /s /t 60", , "Hide")
    }
    SendEvent("sched", lines)
}

ActName(i) {
    return TT(["act_none", "act_close", "act_shutdown"][i + 1])
}

CycleAction(bt, *) {
    global endAct
    endAct := Mod(endAct + 1, 3)
    bt.Text := TT("lbl_onend") ": " ActName(endAct)
}

; ==========================================================
;  Modo econômico (configurações do Roblox + prioridade)
; ==========================================================
FpsName(v) {
    return TT("lbl_fps") ": " (v ? v : TT("fps_none"))
}

CycleFps(bt, *) {
    global ecoFps
    opts := [15, 30, 60, 0]
    for i, v in opts
        if (v = ecoFps) {
            ecoFps := opts[Mod(i, opts.Length) + 1]
            break
        }
    bt.Text := FpsName(ecoFps)
}

XmlSet(x, kind, name, val) {
    pat := '<' kind ' name="' name '">[^<]*</' kind '>'
    nw := '<' kind ' name="' name '">' val '</' kind '>'
    if RegExMatch(x, pat)
        return RegExReplace(x, pat, nw, , 1)
    return RegExReplace(x, "(<Properties>)", "$1`n`t`t`t" nw, , 1)
}

; mexe no arquivo de configurações do Roblox antes de abrir (FPS, gráficos, som)
ApplyEco() {
    global chkEco, ecoFps, chkLowGfx, chkMute
    if !chkEco.Value
        return
    f := EnvGet("LOCALAPPDATA") "\Roblox\GlobalBasicSettings_13.xml"
    if !FileExist(f)
        return
    try {
        x := FileRead(f, "UTF-8")
        x := XmlSet(x, "int", "FramerateCap", ecoFps ? ecoFps : -1)
        if chkLowGfx.Value {
            x := XmlSet(x, "int", "GraphicsQualityLevel", 1)
            x := XmlSet(x, "token", "SavedQualityLevel", 1)
        }
        if chkMute.Value
            x := XmlSet(x, "float", "MasterVolume", 0)
        fo := FileOpen(f, "w", "UTF-8-RAW")
        fo.Write(x)
        fo.Close()
    }
}

; deixa o Roblox com prioridade baixa (uma vez por processo)
LowPrio(pid) {
    global chkEco, chkLowPrio
    static done := Map()
    if (!pid || !chkEco.Value || !chkLowPrio.Value || done.Has(pid))
        return
    try ProcessSetPriority("BelowNormal", pid)
    done[pid] := true
}

; ==========================================================
;  Bot do Discord (lê comandos do canal e responde)
; ==========================================================
DiscordApi(method, url, tok, body := "") {
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.SetTimeouts(5000, 5000, 10000, 10000)
    http.Open(method, url, false)
    http.SetRequestHeader("Authorization", "Bot " tok)
    http.SetRequestHeader("User-Agent", "DiscordBot (https://github.com/dudusoulls/AutoRejoinRoblox, 1.0)")
    if (body != "")
        http.SetRequestHeader("Content-Type", "application/json")
    http.Send(body)
    return http
}

; JSON da lista de mensagens -> "id\x01autor\x01texto\x02..." (usa o JavaScript do Windows)
JsFlatMessages(json) {
    static doc := 0
    if !doc {
        doc := ComObject("htmlfile")
        doc.write('<meta http-equiv="X-UA-Compatible" content="IE=9">')
    }
    return doc.parentWindow.eval("(function(a){var o=[];for(var i=0;i<a.length;i++){o.push(a[i].id+'\u0001'+a[i].author.id+'\u0001'+(a[i].content||''))}return o.join('\u0002')})(" json ")")
}

SnowGreater(a, b) {
    if (b = "")
        return true
    return StrLen(a) != StrLen(b) ? StrLen(a) > StrLen(b) : StrCompare(a, b) > 0
}

BotTick() {
    global chkBot, edToken, edChan, edDiscId, botLast, botStatus, botBusy
    if !chkBot.Value {
        SetIf(botStatus, TT("bot_off"))
        return
    }
    tok := Trim(edToken.Value), ch := Trim(edChan.Value), me := Trim(edDiscId.Value)
    if (tok = "" || ch = "")
        return
    if (me = "") {
        SetIf(botStatus, TT("bot_need_id"))
        return
    }
    if (botBusy && A_TickCount - botBusy < 30000)
        return
    botBusy := A_TickCount
    url := "https://discord.com/api/v10/channels/" ch "/messages?limit=" (botLast = "" ? "1" : "10&after=" botLast)
    try AsyncReq("GET", url, "", "", "Bot " tok, BotGotMessages.Bind(ch, tok, me))
    catch as e {
        botBusy := 0
        SetIf(botStatus, TT("bot_err", e.Message))
    }
}

BotGotMessages(ch, tok, me, http) {
    global botLast, botStatus, botBusy
    botBusy := 0
    try {
        if (HttpStatus(http) != 200)
            throw Error("HTTP " HttpStatus(http))
        flat := JsFlatMessages(http.ResponseText)
    } catch as e {
        SetIf(botStatus, TT("bot_err", e.Message))
        return
    }
    SetIf(botStatus, TT("bot_ok"))
    first := (botLast = "")
    msgs := (flat = "") ? [] : StrSplit(flat, Chr(2))
    Loop msgs.Length {                       ; da mais antiga pra mais nova
        f := StrSplit(msgs[msgs.Length - A_Index + 1], Chr(1), , 3)
        if (f.Length < 3)
            continue
        if SnowGreater(f[1], botLast)
            botLast := f[1]
        if (first || f[2] != me)
            continue
        BotCommand(Trim(f[3]), ch, f[1], tok)
    }
}

BotCommand(cmd, ch, mid, tok) {
    global running, multiActive, monStart, botCtx, edLink, pendingUpd, pendingVer, restartReply
    parts := StrSplit(Trim(cmd), " ", , 2)
    c := StrLower(parts[1]), arg := parts.Length > 1 ? Trim(parts[2]) : ""
    if (SubStr(c, 1, 1) != "!")
        return
    botCtx := {ch: ch, mid: mid, tok: tok}        ; respostas vão como resposta à mensagem do comando
    known := true
    try {
        switch c {
            case "!status":
                SendStatusReport(true)
            case "!print":
                SendPrint()
            case "!iniciar", "!start":
                if running
                    SendEvent("already", [], false, "", SessionFields(), true)
                else
                    Toggle()
            case "!parar", "!stop":
                if running
                    Toggle()
                else
                    SendEvent("notrunning", [], false, "", SessionFields(), true)
            case "!reiniciar", "!restart":
                SendEvent("restart", [TT("d_restart_how")], false, "", SessionFields(), true)
                restartReply := {ch: ch, mid: mid, tok: tok, t0: A_TickCount}
                botCtx := 0
                BotRestart()
            case "!resumo", "!summary":
                SendDailySummary(true)
            case "!moedas", "!coins":
                BotCoins()
            case "!pc":
                SendEvent("pc", [], false, "", PcFields(), true)
            case "!contas", "!accounts":
                BotAccounts()
            case "!historico", "!histórico", "!history":
                BotHistory()
            case "!logs":
                BotLogs()
            case "!ping":
                lat := DateDiff(A_NowUTC, "19700101000000", "Seconds") * 1000 + A_MSec - ((Integer(mid) >> 22) + 1420070400000)
                SendEvent("pong", [], false, "", [[TT("f_latency"), Max(0, lat) " ms", true]
                    , [TT("f_script_up"), DurStr(A_TickCount - scriptT0), true], [TT("f_version"), "v" VERSION, true]], true)
            case "!link":
                if (arg = "" || !(RegExMatch(arg, "^\d+$") || InStr(arg, "roblox")))
                    SendEvent("linkbad", [TT("d_link_usage")], false, "", [], true)
                else {
                    edLink.Value := arg
                    SaveConfig()
                    SendEvent("link", ["``" SubStr(arg, 1, 90) "``", TT("d_link_next")], false, "", [], true)
                }
            case "!atualizar", "!update":
                CheckUpdate(true)
                if (pendingUpd != "") {
                    SendEvent("updating", [], false, pendingVer, [], true)
                    botCtx := 0
                    ApplyUpdate()
                } else
                    SendEvent("updnone", [], false, "", [[TT("f_version"), "v" VERSION, true]], true)
            case "!desligar", "!shutdown":
                if (StrLower(arg) = "confirmar" || StrLower(arg) = "confirm") {
                    SendEvent("shutdown", [TT("d_shutdown")], false, "", [], true)
                    Run("shutdown /s /t 60", , "Hide")
                } else
                    SendEvent("shutconf", [TT("d_shutconf")], false, "", [], true)
            case "!cancelar", "!cancel":
                Run("shutdown /a", , "Hide")
                SendEvent("cancel", [], false, "", [], true)
            case "!ajuda", "!help":
                SendEvent("help", [], false, "", HelpFields(), true)
            default:
                known := false
                SendEvent("unknown", ["**" TT("d_cmd") ":** ``" c "``", TT("d_unknown")], false, "", [], true)
        }
    } finally
        botCtx := 0
    if known {
        Log(TT("log_bot_cmd", c))
        try AsyncReq("PUT", "https://discord.com/api/v10/channels/" ch "/messages/" mid "/reactions/%E2%9C%85/@me", "", "", "Bot " tok)
    }
}

; ---- informações usadas nos embeds dos comandos ----
SessionFields() {
    global running, monStart, launches, discCount, lastDiscUnix, edLink
    lk := Trim(edLink.Value)
    return [[TT("f_session"), running ? DurStr(A_TickCount - monStart) : TT("up_stopped"), true]
        , [TT("f_reopens"), launches, true], [TT("f_drops"), discCount, true]
        , [TT("f_lastdrop"), lastDiscUnix ? "<t:" lastDiscUnix ":R>" : TT("none"), true]
        , [TT("f_link"), lk = "" ? "—" : "``" SubStr(lk, 1, 60) (StrLen(lk) > 60 ? "…" : "") "``", false]]
}

Bar(v, mx, n := 10) {
    f := mx > 0 ? Round(v / mx * n) : 0
    out := ""
    Loop n
        out .= A_Index <= f ? "█" : "░"
    return out
}

PcFields() {
    ms := Buffer(64, 0), NumPut("UInt", 64, ms)
    DllCall("GlobalMemoryStatusEx", "Ptr", ms)
    load := NumGet(ms, 4, "UInt"), total := NumGet(ms, 8, "Int64"), avail := NumGet(ms, 16, "Int64")
    used := Round((total - avail) / 1073741824, 1), tot := Round(total / 1073741824, 1)
    cpu := CpuLoad()
    rram := 0, nwin := 0
    try {
        for pr in ComObjGet("winmgmts:").ExecQuery("Select WorkingSetSize from Win32_Process where Name='RobloxPlayerBeta.exe'")
            rram += pr.WorkingSetSize, nwin++
    }
    return [[TT("f_cpu"), Bar(cpu, 100) "  " cpu "%", false]
        , [TT("f_ram"), Bar(load, 100) "  " used " / " tot " GB", false]
        , [TT("f_roblox_ram"), Round(rram / 1073741824, 2) " GB", true]
        , [TT("f_windows"), nwin, true]
        , [TT("f_pc_up"), DurStr(A_TickCount), true]]
}

; uso de CPU (mede por meio segundo)
CpuLoad() {
    global cpuLast
    return cpuLast
}

; mede a CPU a cada 2s comparando com a medida anterior
CpuSample() {
    global cpuLast
    static pi := 0, pk := 0, pu := 0
    i := Buffer(8), k := Buffer(8), u := Buffer(8)
    DllCall("GetSystemTimes", "Ptr", i, "Ptr", k, "Ptr", u)
    ci := NumGet(i, "UInt64"), ck := NumGet(k, "UInt64"), cu := NumGet(u, "UInt64")
    if pk {
        idle := ci - pi, sys := (ck - pk) + (cu - pu)
        cpuLast := sys > 0 ? Round((sys - idle) / sys * 100) : 0
    }
    pi := ci, pk := ck, pu := cu
}

HelpFields() {
    return [[TT("grp_control"), "``!iniciar`` " TT("cmd_start") "`n``!parar`` " TT("cmd_stop") "`n``!reiniciar`` " TT("cmd_restart"), false]
        , [TT("grp_info"), "``!status`` " TT("cmd_status") "`n``!print`` " TT("cmd_print") "`n``!moedas`` " TT("cmd_coins")
            . "`n``!resumo`` " TT("cmd_summary") "`n``!historico`` " TT("cmd_hist") "`n``!pc`` " TT("cmd_pc")
            . "`n``!contas`` " TT("cmd_accounts") "`n``!logs`` " TT("cmd_logs") "`n``!ping`` " TT("cmd_ping"), false]
        , [TT("grp_config"), "``!link`` " TT("cmd_link") "`n``!atualizar`` " TT("cmd_update")
            . "`n``!desligar`` " TT("cmd_shutdown") "`n``!cancelar`` " TT("cmd_cancel"), false]]
}

; só o print da janela do Roblox
SendPrint() {
    global APP_NAME, LOGO_URL, USER_NAME, VERSION
    hw := FindGameWindow()
    png := A_Temp "\roblox_status.png"
    why := !hw ? TT("why_closed") : WinGetMinMax(hw) = -1 ? TT("why_min") : ""
    if (why = "") {
        try ok := CaptureWindowPng(hw, png)
        if !(IsSet(ok) && ok)
            why := TT("why_fail")
    }
    if (why != "")
        return SendEvent("unknown", [TT("no_shot", why)], false, "", [], true)
    if !DiscordDest(&url, &auth, &head)
        return
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    e := '{' head '"allowed_mentions":{"parse":[]},"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc("📸  " TT("ev_print")) '","color":' 0x5B8CFF ','
       . '"image":{"url":"attachment://roblox.png"},'
       . '"footer":{"text":"' JsonEsc(USER_NAME "  •  " A_ComputerName "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
       . '"timestamp":"' ts '"}]}'
    try SendWebhookImage(url, e, png, auth)
}

BotCoins() {
    global prevCur
    hw := FindGameWindow()
    if !(hw && WinGetMinMax(hw) != -1)
        return SendEvent("coins", [TT("no_coins")], false, "", [], true)
    try blk := CurrencyBlock(ReadCurrencies(hw))
    if !(IsSet(blk) && blk != "")
        return SendEvent("coins", [TT("no_coins")], false, "", [], true)
    SendEvent("coins", [StrReplace(blk, "### Player Stats`n")], false, "", [], true)
}

BotAccounts() {
    global ACCS
    if !ACCS.Length
        return SendEvent("accounts", [TT("no_accounts")], false, "", [], true)
    lines := []
    for a in ACCS
        lines.Push((a.pid ? "🟢" : "⚫") "  **" a.name "**  ·  " a.status "  ·  " TT("f_reopens") ": " a.launches)
    SendEvent("accounts", lines, false, "", [], true)
}

BotHistory() {
    days := [], mx := 0
    Loop 7 {
        d := FormatTime(DateAdd(A_Now, -(7 - A_Index), "Days"), "yyyyMMdd")
        r := HistGet(d)
        days.Push([d, r])
        mx := Max(mx, r.online)
    }
    out := ""
    for x in days
        out .= SubStr(x[1], 7, 2) "/" SubStr(x[1], 5, 2) "  " Bar(x[2].online, mx, 12) "  " Format("{:4.1f}", x[2].online / 3600) "h  ·  " x[2].drops "↓`n"
    SendEvent("hist", ["``````" RTrim(out, "`n") "``````"], false, "", [], true)
}

BotLogs() {
    global logBox
    ls := StrSplit(RTrim(logBox.Value, "`r`n"), "`n", "`r")
    out := ""
    st := Max(1, ls.Length - 11)
    Loop ls.Length - st + 1
        out .= ls[st + A_Index - 1] "`n"
    if (StrLen(out) > 1800)
        out := SubStr(out, -1800)
    SendEvent("logs", ["``````" (out = "" ? "-" : RTrim(out, "`n")) "``````"], false, "", [], true)
}

BotRestart() {
    global multiActive, wasOpen, downTick
    if multiActive
        return KillRoblox()                       ; o modo de várias contas reabre sozinho
    Log(TT("ev_restart"))
    wasOpen := false, downTick := 0
    KillRoblox()
    Sleep(3000)
    LaunchGame(true, 1)
}

; ==========================================================
;  Histórico (gráfico dos últimos 14 dias)
; ==========================================================
; salva o dia que acabou no [history] do config.ini
HistSave(date) {
    global iniFile
    try sec := IniRead(iniFile, "day")
    catch
        return
    vals := Map()
    for line in StrSplit(sec, "`n", "`r") {
        kv := StrSplit(line, "=", , 2)
        if (kv.Length = 2)
            vals[kv[1]] := kv[2]
    }
    coins := ""
    for k, v in vals
        if (SubStr(k, 1, 6) = "start_" && vals.Has("last_" SubStr(k, 7)))
            coins .= SubStr(k, 7) "=" (Integer(vals["last_" SubStr(k, 7)]) - Integer(v)) ";"
    IniWrite((vals.Has("online") ? vals["online"] : 0) "|" (vals.Has("drops") ? vals["drops"] : 0) "|"
        . (vals.Has("reopens") ? vals["reopens"] : 0) "|" RTrim(coins, ";"), iniFile, "history", date)
}

HistGet(date) {
    global iniFile, dayOnline
    r := {online: 0, drops: 0, reopens: 0, coins: Map(), has: false}
    if (date = FormatTime(, "yyyyMMdd")) {
        DayRoll()
        r.online := dayOnline, r.drops := Integer(IniRead(iniFile, "day", "drops", "0"))
        r.reopens := Integer(IniRead(iniFile, "day", "reopens", "0")), r.has := true
        for c in CurrencySpec() {
            k := RegExReplace(c.name, "\W", "_")
            st := IniRead(iniFile, "day", "start_" k, ""), la := IniRead(iniFile, "day", "last_" k, "")
            if (st != "" && la != "")
                r.coins[k] := Integer(la) - Integer(st)
        }
        return r
    }
    v := IniRead(iniFile, "history", date, "")
    if (v = "")
        return r
    f := StrSplit(v, "|")
    r.online := Integer(f[1]), r.drops := Integer(f[2]), r.reopens := Integer(f[3]), r.has := true
    if (f.Length >= 4)
        for pair in StrSplit(f[4], ";")
            if (kv := StrSplit(pair, "=")).Length = 2
                r.coins[kv[1]] := Integer(kv[2])
    return r
}

Compact(n) {
    a := Abs(n)
    return a >= 1000000 ? Round(n / 1000000, 1) "M" : a >= 1000 ? Round(n / 1000, 1) "k" : n
}

SetHistMetric(m, *) {
    global histMetric, histCoinIdx, histBtns
    specs := CurrencySpec()
    if (m = "coin") {
        if (histMetric = "coin")
            histCoinIdx := Mod(histCoinIdx, Max(specs.Length, 1)) + 1
        if specs.Length
            histBtns["coin"].Text := TT("hist_coin", specs[Min(histCoinIdx, specs.Length)].name)
    }
    histMetric := m
    for k, b in histBtns
        SetBtnStyle(b, k = m ? "primary" : "sec")
    HistDraw()
}

HistDraw() {
    global histMetric, histCoinIdx, histBars, histVals, histDays, histEmpty, histTarget, histT0, C_ACC
    specs := CurrencySpec()
    ck := (specs.Length && histMetric = "coin") ? RegExReplace(specs[Min(histCoinIdx, specs.Length)].name, "\W", "_") : ""
    vals := [], any := false
    Loop 14 {
        d := FormatTime(DateAdd(A_Now, -(14 - A_Index), "Days"), "yyyyMMdd")
        r := HistGet(d)
        any := any || r.has
        v := histMetric = "online" ? r.online : histMetric = "drops" ? r.drops : histMetric = "reopens" ? r.reopens
            : (r.coins.Has(ck) ? r.coins[ck] : 0)
        vals.Push(v)
        histDays[A_Index].Value := SubStr(d, 7, 2) "/" SubStr(d, 5, 2)
        histVals[A_Index].Value := !r.has ? "" : histMetric = "online" ? Round(v / 3600, 1) "h" : Compact(v)
    }
    mx := 0
    for v in vals
        mx := Max(mx, v)
    histTarget := []
    for v in vals
        histTarget.Push(mx > 0 ? Max(Round(v / mx * 260), v > 0 ? 3 : 0) : 0)
    histEmpty.Visible := !any
    histT0 := A_TickCount
    SetTimer(HistAnim, 15)
}

; barras crescendo
HistAnim() {
    global histBars, histVals, histTarget, histT0, histBase
    pr := Min(1, (A_TickCount - histT0) / 380)
    e := EaseOut(pr)
    for i, b in histBars {
        hh := Max(2, Round(histTarget[i] * e))
        b.GetPos(&bx)
        b.Move(bx, histBase - hh, , hh)
        histVals[i].Move(, histBase - hh - 18)
    }
    if (pr >= 1)
        SetTimer(HistAnim, 0)
}

; ==========================================================
;  Farm travado (moedas sem mudar)
; ==========================================================
StuckActName(i) {
    return TT(i ? "stuck_restart" : "stuck_alert")
}

CycleStuckAct(bt, *) {
    global stuckAct
    stuckAct := !stuckAct
    bt.Text := StuckActName(stuckAct)
}

; guarda quando as moedas mudaram pela última vez
CoinsObserved(found) {
    global lastCoinSig, lastCoinChange, lastCoinRead
    if !found.Count
        return
    sig := ""
    for k, v in found
        sig .= k "=" v ";"
    lastCoinRead := A_TickCount
    if (sig != lastCoinSig)
        lastCoinSig := sig, lastCoinChange := A_TickCount
}

StuckTick() {
    global running, chkStuck, edStuckMin, stuckAct, multiActive, lastLaunch, lastCoinSig, lastCoinChange, lastCoinRead
    if (!running || !chkStuck.Value || multiActive || lastLaunch) {
        lastCoinChange := A_TickCount
        return
    }
    hw := FindGameWindow()
    if !(hw && WinGetMinMax(hw) != -1)
        return
    if (A_TickCount - lastCoinRead > 50000) {
        try CoinsObserved(ReadCurrencies(hw)[2])
    }
    if (lastCoinSig = "")
        return
    mins := (A_TickCount - lastCoinChange) / 60000
    lim := Integer(Trim(edStuckMin.Value) || 15)
    if (mins < Max(lim, 2))
        return
    lastCoinChange := A_TickCount                ; não fica repetindo o aviso
    Log(TT("log_stuck", Round(mins)))
    shot := ""
    try {
        if CaptureWindowPng(hw, A_Temp "\roblox_stuck.png")
            shot := A_Temp "\roblox_stuck.png"
    }
    lines := [TT("d_stuck", Round(mins))]
    if stuckAct
        lines.Push(TT("d_restart"))
    SendEvent("stuck", lines, false, "", SessionFields(), true, shot)
    if stuckAct
        RecoverRoblox(TT("r_stuck"))
}

; ==========================================================
;  Painel ao vivo (uma mensagem do bot que se atualiza)
; ==========================================================
HttpReq(method, url, body, ctype, auth := "") {
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.SetTimeouts(5000, 5000, 15000, 20000)
    http.Open(method, url, false)
    if (ctype != "")
        http.SetRequestHeader("Content-Type", ctype)
    if (auth != "") {
        http.SetRequestHeader("Authorization", auth)
        http.SetRequestHeader("User-Agent", "DiscordBot (https://github.com/dudusoulls/AutoRejoinRoblox, 1.0)")
    }
    http.Send(body)
    return http
}

; corpo multipart (json + imagem) pra mandar/editar mensagem com print
MultipartBody(payload, pngPath, &ctype) {
    bnd := "----AHKPanel" A_TickCount
    head := "--" bnd "`r`nContent-Disposition: form-data; name=`"payload_json`"`r`nContent-Type: application/json`r`n`r`n" payload "`r`n"
    tail := "`r`n--" bnd "--`r`n"
    hasImg := (pngPath != "" && FileExist(pngPath))
    if hasImg
        head .= "--" bnd "`r`nContent-Disposition: form-data; name=`"files[0]`"; filename=`"roblox.png`"`r`nContent-Type: image/png`r`n`r`n"
    img := hasImg ? FileRead(pngPath, "RAW") : Buffer(0)
    if !hasImg
        tail := "--" bnd "--`r`n"
    hb := Buffer(StrPut(head, "UTF-8")), StrPut(head, hb, "UTF-8"), hn := hb.Size - 1
    tb := Buffer(StrPut(tail, "UTF-8")), StrPut(tail, tb, "UTF-8"), tn := tb.Size - 1
    arr := ComObjArray(0x11, hn + img.Size + tn)
    psa := ComObjValue(arr)
    DllCall("oleaut32\SafeArrayAccessData", "Ptr", psa, "Ptr*", &pt := 0)
    DllCall("RtlMoveMemory", "Ptr", pt, "Ptr", hb, "UPtr", hn)
    if img.Size
        DllCall("RtlMoveMemory", "Ptr", pt + hn, "Ptr", img, "UPtr", img.Size)
    DllCall("RtlMoveMemory", "Ptr", pt + hn + img.Size, "Ptr", tb, "UPtr", tn)
    DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", psa)
    ctype := "multipart/form-data; boundary=" bnd
    return arr
}

JsonPick(json, expr) {
    static doc := 0
    if !doc {
        doc := ComObject("htmlfile")
        doc.write('<meta http-equiv="X-UA-Compatible" content="IE=9">')
    }
    return doc.parentWindow.eval("(function(a){return String(" expr ")})(" json ")")
}

PanelTick() {
    global chkPanel, edPanelMin, panelLast
    if !chkPanel.Value
        return
    mins := Max(1, Integer(Trim(edPanelMin.Value) || 2))
    if (A_TickCount - panelLast >= mins * 60000 - 5000)
        PanelUpdate()
}

PanelUpdate(force := false) {
    global chkPanel, chkBot, edToken, edChan, panelMsg, panelLast, iniFile, running, monStart, launches, discCount
    global lastDiscUnix, discTick, dayOnline, chkOcr, APP_NAME, USER_NAME, LOGO_URL, VERSION, curState
    if !(chkPanel.Value && chkBot.Value)
        return
    tok := Trim(edToken.Value), ch := Trim(edChan.Value)
    if (tok = "" || ch = "")
        return
    if (!force && A_TickCount - panelLast < 20000)
        return
    panelLast := A_TickCount

    open := IsRobloxOpen()
    if !open
        title := "🔴  Offline", color := 0xFF5C5C
    else if discTick
        title := "🟡  " TT("emb_warn"), color := 0xF5C542
    else
        title := "🟢  " TT("emb_online"), color := 0x3DDC84
    if !running
        title .= "  ·  " TT("up_stopped"), color := 0x8B8B94

    ; print + moedas
    hw := FindGameWindow(), shot := "", coins := ""
    if (hw && WinGetMinMax(hw) != -1) {
        try {
            if CaptureWindowPng(hw, A_Temp "\roblox_panel.png")
                shot := A_Temp "\roblox_panel.png"
        }
        if chkOcr.Value {
            try {
                cur := ReadCurrencies(hw)
                CoinsObserved(cur[2])
                for c in CurrencySpec()
                    if cur[2].Has(c.name)
                        coins .= c.emoji "  **" cur[2][c.name] "**  ·  " c.name "`n"
            }
        }
    }
    DayRoll()
    pcf := PcFields()
    now := DateDiff(A_NowUTC, "19700101000000", "Seconds")
    desc := (coins != "" ? "### Player Stats`n" coins "`n" : "")
        . "**" pcf[1][1] "**  " pcf[1][2] "`n**" pcf[2][1] "**  " pcf[2][2]
        . "`n`n🔄 " TT("d_updated") " <t:" now ":R>"
    fields := [[TT("f_session"), running ? DurStr(A_TickCount - monStart) : TT("up_stopped"), true]
        , [TT("f_online_today"), DurStr(dayOnline * 1000), true]
        , [TT("f_roblox_ram"), pcf[3][2], true]
        , [TT("f_reopens"), launches, true], [TT("f_drops"), discCount, true]
        , [TT("f_lastdrop"), lastDiscUnix ? "<t:" lastDiscUnix ":R>" : TT("none"), true]]
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    payload := '{"allowed_mentions":{"parse":[]},"embeds":[{'
        . '"author":{"name":"' JsonEsc(APP_NAME "  ·  " TT("ev_panel")) '","icon_url":"' LOGO_URL '"},'
        . '"title":"' JsonEsc(title) '","color":' color ','
        . '"description":"' JsonEsc(desc) '",' FieldsJson(fields)
        . '"thumbnail":{"url":"' LOGO_URL '"},'
        . (shot != "" ? '"image":{"url":"attachment://roblox.png"},' : '')
        . '"footer":{"text":"' JsonEsc(USER_NAME "  •  " A_ComputerName "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
        . '"timestamp":"' ts '"}],'
        . '"attachments":' (shot != "" ? '[{"id":0,"filename":"roblox.png"}]' : '[]') '}'
    base := "https://discord.com/api/v10/channels/" ch "/messages"
    try {
        body := MultipartBody(payload, shot, &ct)
        if (panelMsg != "")
            AsyncReq("PATCH", base "/" panelMsg, body, ct, "Bot " tok, PanelPatched.Bind(base, payload, shot, tok, ch))
        else
            PanelCreate(base, payload, shot, tok, ch)
    }
}

PanelPatched(base, payload, shot, tok, ch, http) {
    global panelMsg
    if (HttpStatus(http) = 404) {             ; mensagem apagada: cria outra
        panelMsg := ""
        PanelCreate(base, payload, shot, tok, ch)
    }
}

PanelCreate(base, payload, shot, tok, ch) {
    body := MultipartBody(payload, shot, &ct)
    AsyncReq("POST", base, body, ct, "Bot " tok, PanelCreated.Bind(tok, ch))
}

PanelCreated(tok, ch, http) {
    global panelMsg, iniFile
    if (HttpStatus(http) != 200)
        return
    try {
        panelMsg := JsonPick(http.ResponseText, "a.id")
        IniWrite(panelMsg, iniFile, "cfg", "panelMsg")
        AsyncReq("PUT", "https://discord.com/api/v10/channels/" ch "/pins/" panelMsg, "", "", "Bot " tok)
    }
}

; arredonda controles, joga os fundos pro fundo da pilha e arredonda as janelas
FinishGui() {
    global g, gm, gk, bgCtrls, roundQ
    k := A_ScreenDPI / 96
    for item in roundQ
        RoundCtrl(item[1], item[2])
    Loop bgCtrls.Length {
        c := bgCtrls[bgCtrls.Length - A_Index + 1]
        DllCall("SetWindowPos", "Ptr", c.Hwnd, "Ptr", 1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
    for hw in [g.Hwnd, gm.Hwnd, gk.Hwnd] {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hw, "UInt", 33, "Int*", 2, "UInt", 4)          ; cantos arredondados (Win11)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hw, "UInt", 34, "UInt*", 0x00332E2E, "UInt", 4) ; borda sutil
    }
}

; arrastar a janela clicando em qualquer área vazia
OnLButtonDown(wParam, lParam, msg, hwnd) {
    global g, gm, gk, tourOn
    if tourOn {
        if (hwnd != g.Hwnd)
            try WinActivate(g.Hwnd)
        return
    }
    if (hwnd = g.Hwnd || hwnd = gm.Hwnd || hwnd = gk.Hwnd)
        PostMessage(0xA1, 2, 0, , "ahk_id " hwnd)
}

OnMouseMove(wParam, lParam, msg, hwnd) {
    global hoverMap, hoverCur
    o := hoverMap.Has(hwnd) ? hoverMap[hwnd] : 0
    if (o = hoverCur)
        return
    if hoverCur
        PaintHover(hoverCur, false)
    hoverCur := o
    if o {
        PaintHover(o, true)
        SetTimer(HoverCheck, 80)
    }
}

HoverCheck() {
    global hoverMap, hoverCur
    MouseGetPos(, , , &ctl, 2)
    if !hoverCur || !(hoverMap.Has(ctl) && hoverMap[ctl] = hoverCur) {
        if hoverCur
            PaintHover(hoverCur, false)
        hoverCur := 0
        SetTimer(HoverCheck, 0)
    }
}

PaintHover(o, on) {
    AnimColor(o, on ? o.hov : o.bg, 110)
}

; ==========================================================
;  Animações (cores suaves, fade de janela, barrinha deslizando, bolinha pulsando)
; ==========================================================
EaseOut(p) {
    return 1 - (1 - p) ** 3
}

LerpHex(a, b, t) {
    x := Integer("0x" a), y := Integer("0x" b)
    r := Round(((x >> 16) & 255) + ((((y >> 16) & 255) - ((x >> 16) & 255)) * t))
    gr := Round(((x >> 8) & 255) + ((((y >> 8) & 255) - ((x >> 8) & 255)) * t))
    bl := Round((x & 255) + (((y & 255) - (x & 255)) * t))
    return Format("{:02X}{:02X}{:02X}", r, gr, bl)
}

; muda a cor de fundo de um grupo de controles aos poucos
AnimColor(o, to, dur := 140) {
    global animSet
    from := o.HasOwnProp("cur") ? o.cur : o.bg
    if (from = to && !animSet.Has(ObjPtr(o)))
        return
    o.from := from, o.to := to, o.t0 := A_TickCount, o.dur := dur
    animSet[ObjPtr(o)] := o
    SetTimer(AnimTick, 15)
}

AnimTick() {
    global animSet
    done := []
    for k, o in animSet {
        pr := Min(1, (A_TickCount - o.t0) / o.dur)
        c := LerpHex(o.from, o.to, EaseOut(pr))
        o.cur := c
        for ctl in o.ctrls
            try ctl.Opt("Background" c), ctl.Redraw()
        if (pr >= 1)
            done.Push(k)
    }
    for k in done
        animSet.Delete(k)
    if !animSet.Count
        SetTimer(AnimTick, 0)
}

; troca a cor na hora (sem animação)
SetColorNow(o, c) {
    global animSet
    if animSet.Has(ObjPtr(o))
        animSet.Delete(ObjPtr(o))
    o.cur := c
    for ctl in o.ctrls
        try ctl.Opt("Background" c), ctl.Redraw()
}

; janela aparecendo/sumindo suave
FadeShow(gui, opts := "") {
    try WinSetTransparent(0, gui.Hwnd)
    gui.Show(opts)
    Loop 8 {
        try WinSetTransparent(Round(255 * EaseOut(A_Index / 8)), gui.Hwnd)
        Sleep(14)
    }
    try WinSetTransparent("Off", gui.Hwnd)
}

FadeHide(gui) {
    if DllCall("IsWindowVisible", "Ptr", gui.Hwnd) {
        Loop 6 {
            try WinSetTransparent(Round(255 * (1 - A_Index / 6)), gui.Hwnd)
            Sleep(12)
        }
    }
    gui.Hide()
    try WinSetTransparent("Off", gui.Hwnd)
}

FadeMin(gui) {
    Loop 6 {
        try WinSetTransparent(Round(255 * (1 - A_Index / 6)), gui.Hwnd)
        Sleep(12)
    }
    gui.Minimize()
    try WinSetTransparent("Off", gui.Hwnd)
}

; barrinha branca da barra lateral deslizando até a aba escolhida
SlideNav(ty) {
    global navBar, slideFrom, slideTo, slideT0
    navBar.GetPos(, &cy)
    slideFrom := cy, slideTo := ty, slideT0 := A_TickCount
    SetTimer(SlideTick, 15)
}

SlideTick() {
    global navBar, slideFrom, slideTo, slideT0
    pr := Min(1, (A_TickCount - slideT0) / 220)
    e := EaseOut(pr)
    ; estica um pouco no meio do caminho e volta ao tamanho normal no fim
    hh := 18 + Round(10 * Sin(pr * 3.14159))
    navBar.Move(, Round(slideFrom + (slideTo - slideFrom) * e) - (hh - 18) // 2, , hh)
    navBar.Redraw()
    if (pr >= 1)
        SetTimer(SlideTick, 0)
}

; bolinha de status "respirando" quando está online/carregando
PulseTick() {
    global curState, curStateCol, dashDot, sideDot, mDot, C_CARD, pulseLast, g, gm
    vis := (DllCall("IsWindowVisible", "Ptr", g.Hwnd) && !DllCall("IsIconic", "Ptr", g.Hwnd)) || DllCall("IsWindowVisible", "Ptr", gm.Hwnd)
    if (!vis && pulseLast = curStateCol)
        return
    if (vis && (curState = "on" || curState = "wait")) {
        f := (Sin(Mod(A_TickCount, 1800) / 1800 * 6.28318) + 1) / 2
        c := LerpHex(curStateCol, C_CARD, f * 0.6)
    } else
        c := curStateCol
    if (c = pulseLast)
        return
    pulseLast := c
    for d in [dashDot, sideDot, mDot]
        try d.SetFont("c" c)
}

; Interruptor ON/OFF
class ToggleSwitch {
    __New(x, y, w, label, val, sub := "") {
        global g, C_CARD, C_TEXT, C_MUTED, roundQ
        FontUI(g, "s10")
        this.lbl := P(g.Add("Text", Format("x{} y{} w{} c{} Background{}", x, y, w - 76, C_TEXT, C_CARD), label))
        if (sub != "") {
            FontUI(g, "s8")
            this.sub := P(g.Add("Text", Format("x{} y+2 w{} c{} Background{}", x, w - 76, C_MUTED, C_CARD), sub))
        }
        FontUI(g, "s8 w700")
        this.pill := P(g.Add("Text", Format("x{} y{} w52 h26 Center +0x200", x + w - 52, y + 4), ""))
        roundQ.Push([this.pill, 26])
        this.val := !!val
        this.onChange := 0
        for c in [this.pill, this.lbl] {
            c.OnEvent("Click", (*) => this.Flip())
            c.OnEvent("DoubleClick", (*) => this.Flip())
        }
        this.Paint()
    }
    Value {
        get => this.val
        set {
            this.val := !!value
            this.Paint()
        }
    }
    Flip() {
        this.Value := !this.val
        if this.onChange
            this.onChange.Call()
    }
    Paint() {
        global C_ACC, C_BG, C_SWOFF, C_MUTED
        col := this.val ? C_ACC : C_SWOFF
        if !this.HasOwnProp("anim")
            this.anim := {ctrls: [this.pill], bg: col}
        this.pill.SetFont("c" (this.val ? C_BG : C_MUTED))
        this.pill.Text := this.val ? "ON" : "OFF"
        if this.HasOwnProp("shown")
            AnimColor(this.anim, col, 170)
        else {
            SetColorNow(this.anim, col)
            this.shown := true
        }
    }
}

SetIf(ctrl, v) {
    if (ctrl.Value != v)
        ctrl.Value := v
}

; estado visual: on / off / wait / warn / idle
SetState(state, title, sub) {
    global dashDot, dashTitle, dashSub, sideDot, sideStat, mDot, mStat
    global C_ON, C_OFF, C_WARN, C_DIM, C_ACC
    global curState, curStateCol
    col := Map("on", C_ON, "off", C_OFF, "wait", C_ACC, "warn", C_WARN, "idle", C_DIM)[state]
    if (curState != state)
        SetTimer(() => PanelUpdate(), -3000)
    curState := state, curStateCol := col
    PulseTick()
    SetIf(dashTitle, title)
    SetIf(dashSub, sub)
    SetIf(sideStat, title)
    SetIf(mStat, title)
}

UpdateStats() {
    global stVals, mSub, running, monStart, launches, discCount, lastDiscShort, dayOnline, iniFile
    SetIf(stVals[1], running ? DurStr(A_TickCount - monStart) : "—")
    SetIf(stVals[2], launches)
    SetIf(stVals[3], discCount)
    SetIf(stVals[4], lastDiscShort)
    SetIf(mSub, TT("mini_sub", launches, discCount))
    ; tempo online de hoje (pro resumo diário)
    static n := 0
    if (running && IsRobloxOpen()) {
        DayRoll()
        dayOnline++
        if (Mod(++n, 60) = 0)
            IniWrite(dayOnline, iniFile, "day", "online")
    }
}

SetCompact(on) {
    global g, gm, miniShown, iniFile, winW, W, H
    IniWrite(on ? 1 : 0, iniFile, "cfg", "compact")
    if on {
        FadeHide(g)
        if !miniShown {
            miniShown := true
            x := A_ScreenWidth - winW - 300
            FadeShow(gm, "NoActivate w284 h52 x" (x > 0 ? x : 0) " y8")
        } else
            FadeShow(gm, "NoActivate")
    } else {
        FadeHide(gm)
        FadeShow(g, Format("w{} h{}", W, H))
    }
}

OnQuit(*) {
    try SaveConfig()
    try FileDelete(A_Temp "\roblox_status.png")
}

; ==========================================================
;  Funções gerais
; ==========================================================
Log(msg) {
    global logBox
    line := FormatTime(, "HH:mm:ss") "  " msg "`r`n"
    n := DllCall("GetWindowTextLength", "Ptr", logBox.Hwnd)
    if (n > 60000) {                          ; guarda só a parte mais recente
        logBox.Value := SubStr(logBox.Value, -30000)
        n := DllCall("GetWindowTextLength", "Ptr", logBox.Hwnd)
    }
    SendMessage(0xB1, n, n, logBox.Hwnd)                  ; EM_SETSEL no fim
    SendMessage(0xC2, 0, StrPtr(line), logBox.Hwnd)       ; EM_REPLACESEL
}

SaveConfig() {
    global iniFile, edLink, edHook, edInterval, edWait, chkShrink, chkMin, chkErr, edErrSec, chkRep, edRepMin, winW, winH, chkOcr, edCur, chkAutoUpd, chkStartWin, chkAutoMon, chkToast, chkTray, chkDaily, edDailyAt, chkMention, edDiscId, chkMulti, chkSched, edFrom, edTo, edMaxH, endAct, chkEco, ecoFps, chkLowGfx, chkMute, chkLowPrio, chkBot, edToken, edChan, chkPanel, edPanelMin, chkStuck, edStuckMin, stuckAct
    IniWrite(Trim(edLink.Value), iniFile, "cfg", "link")
    IniWrite(Trim(edHook.Value), iniFile, "cfg", "webhook")
    IniWrite(edInterval.Value, iniFile, "cfg", "interval")
    IniWrite(edWait.Value, iniFile, "cfg", "wait")
    IniWrite(chkShrink.Value, iniFile, "cfg", "shrink")
    IniWrite(chkMin.Value, iniFile, "cfg", "minBrowser")
    IniWrite(chkErr.Value, iniFile, "cfg", "restartOnError")
    IniWrite(edErrSec.Value, iniFile, "cfg", "errSec")
    IniWrite(chkRep.Value, iniFile, "cfg", "report")
    IniWrite(edRepMin.Value, iniFile, "cfg", "reportMin")
    IniWrite(chkOcr.Value, iniFile, "cfg", "ocr")
    IniWrite(Trim(edCur.Value), iniFile, "cfg", "currencies")
    IniWrite(chkAutoUpd.Value, iniFile, "cfg", "autoUpdate")
    IniWrite(chkStartWin.Value, iniFile, "cfg", "startWin")
    IniWrite(chkAutoMon.Value, iniFile, "cfg", "autoMon")
    IniWrite(chkToast.Value, iniFile, "cfg", "toast")
    IniWrite(chkTray.Value, iniFile, "cfg", "tray")
    IniWrite(chkDaily.Value, iniFile, "cfg", "daily")
    IniWrite(Trim(edDailyAt.Value), iniFile, "cfg", "dailyAt")
    IniWrite(chkMention.Value, iniFile, "cfg", "mention")
    IniWrite(Trim(edDiscId.Value), iniFile, "cfg", "discordId")
    IniWrite(chkMulti.Value, iniFile, "cfg", "multi")
    IniWrite(chkSched.Value, iniFile, "cfg", "sched")
    IniWrite(Trim(edFrom.Value), iniFile, "cfg", "schedFrom")
    IniWrite(Trim(edTo.Value), iniFile, "cfg", "schedTo")
    IniWrite(Trim(edMaxH.Value), iniFile, "cfg", "maxHours")
    IniWrite(endAct, iniFile, "cfg", "endAct")
    IniWrite(chkEco.Value, iniFile, "cfg", "eco")
    IniWrite(ecoFps, iniFile, "cfg", "ecoFps")
    IniWrite(chkLowGfx.Value, iniFile, "cfg", "lowGfx")
    IniWrite(chkMute.Value, iniFile, "cfg", "mute")
    IniWrite(chkLowPrio.Value, iniFile, "cfg", "lowPrio")
    IniWrite(chkBot.Value, iniFile, "cfg", "bot")
    IniWrite(Trim(edToken.Value) = "" ? "" : DpapiProtect(Trim(edToken.Value)), iniFile, "cfg", "botToken")
    IniWrite(Trim(edChan.Value), iniFile, "cfg", "botChan")
    IniWrite(chkPanel.Value, iniFile, "cfg", "panel")
    IniWrite(Trim(edPanelMin.Value), iniFile, "cfg", "panelMin")
    IniWrite(chkStuck.Value, iniFile, "cfg", "stuck")
    IniWrite(Trim(edStuckMin.Value), iniFile, "cfg", "stuckMin")
    IniWrite(stuckAct, iniFile, "cfg", "stuckAct")
    IniWrite(winW, iniFile, "cfg", "winW")
    IniWrite(winH, iniFile, "cfg", "winH")
}

NowStr() {
    return FormatTime(, "dd/MM/yyyy HH:mm:ss")
}

DurStr(ms) {
    secs := ms // 1000
    if (secs >= 3600)
        return (secs // 3600) "h " Mod(secs // 60, 60) "m"
    return (secs // 60) "m " Mod(secs, 60) "s"
}

MarkDisconnect() {
    global discCount, lastDisc, lastDiscShort, lastDiscUnix
    lastDiscUnix := DateDiff(A_NowUTC, "19700101000000", "Seconds")
    discCount++
    DayAdd("drops")
    lastDisc := NowStr()
    lastDiscShort := FormatTime(, "dd/MM HH:mm")
}

; ---------------- Logo / ícone ----------------
Base64ToFile(b64, path) {
    DllCall("crypt32\CryptStringToBinaryW", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", 0, "UInt*", &n := 0, "Ptr", 0, "Ptr", 0)
    buf := Buffer(n)
    DllCall("crypt32\CryptStringToBinaryW", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", buf, "UInt*", &n, "Ptr", 0, "Ptr", 0)
    f := FileOpen(path, "w"), f.RawWrite(buf, n), f.Close()
}

SetWinIcon(gui) {
    global ASSET_DIR
    try {
        big := LoadPicture(ASSET_DIR "\app.ico", "Icon1 w32 h32", &t1)
        small := LoadPicture(ASSET_DIR "\app.ico", "Icon1 w16 h16", &t2)
        SendMessage(0x80, 1, big, gui.Hwnd)    ; WM_SETICON grande
        SendMessage(0x80, 0, small, gui.Hwnd)  ; WM_SETICON pequeno
    }
}

; ---------------- Idioma ----------------
; texto traduzido (tabela I18N lá em cima)
TT(id, args*) {
    global LANG, I18N
    s := I18N[LANG].Has(id) ? I18N[LANG][id] : (I18N["en"].Has(id) ? I18N["en"][id] : id)
    return args.Length ? Format(s, args*) : s
}

; idioma do Windows -> um dos idiomas do script (inglês se não tiver)
SystemLang() {
    static m := Map(0x16, "pt", 0x09, "en", 0x0A, "es", 0x0C, "fr", 0x07, "de", 0x19, "ru", 0x1F, "tr", 0x21, "id")
    try {
        lcid := DllCall("GetUserDefaultUILanguage", "UShort")
        if m.Has(lcid & 0x3FF)
            return m[lcid & 0x3FF]
    }
    try {
        p := Integer("0x" A_Language) & 0x3FF
        if m.Has(p)
            return m[p]
    }
    return "en"
}

LangMenu() {
    global LANG_CODES, LANG_NAMES, savedLang
    mn := Menu()
    mn.Add(TT("lang_auto"), (*) => SetLang("auto"))
    if (savedLang = "auto")
        mn.Check(TT("lang_auto"))
    mn.Add()
    for i, c in LANG_CODES {
        name := LANG_NAMES[i]
        mn.Add(name, SetLang.Bind(c))
        if (savedLang = c)
            mn.Check(name)
    }
    mn.Show()
}

SetLang(code, *) {
    global iniFile, running
    IniWrite(code, iniFile, "cfg", "lang")
    SaveConfig()
    if running
        IniWrite(1, iniFile, "cfg", "resume")
    Relaunch()
}

; nome do usuário do Windows (nome de exibição se tiver, senão o login)
UserDisplayName() {
    buf := Buffer(1024, 0), n := 512
    try {
        if DllCall("secur32\GetUserNameExW", "Int", 3, "Ptr", buf, "UInt*", &n) {
            name := Trim(StrGet(buf))
            if (name != "")
                return name
        }
    }
    return A_UserName
}

; ---------------- Licença (KeyAuth) ----------------
KaEnabled() {
    global KEYAUTH_OWNERID
    return KEYAUTH_OWNERID != ""
}

; HWID = MachineGuid do Windows (muda só se formatar o PC)
GetHWID() {
    static id := ""
    if (id != "")
        return id
    try id := RegRead("HKLM\SOFTWARE\Microsoft\Cryptography", "MachineGuid")
    if (id = "") {
        try id := RegRead("HKLM64\SOFTWARE\Microsoft\Cryptography", "MachineGuid")
    }
    if (id = "")
        id := A_ComputerName "-" DriveGetSerial("C:\")
    return id
}

ShortHWID() {
    h := GetHWID()
    return StrLen(h) > 24 ? SubStr(h, 1, 13) "…" SubStr(h, -8) : h
}

UrlEnc(s) {
    buf := Buffer(StrPut(s, "UTF-8")), StrPut(s, buf, "UTF-8")
    out := ""
    Loop buf.Size - 1 {
        b := NumGet(buf, A_Index - 1, "UChar")
        out .= (b >= 48 && b <= 57 || b >= 65 && b <= 90 || b >= 97 && b <= 122 || b = 45 || b = 46 || b = 95 || b = 126)
            ? Chr(b) : Format("%{:02X}", b)
    }
    return out
}

; manda um pedido pro KeyAuth e devolve o texto da resposta (JSON)
KaPost(fields) {
    global KEYAUTH_URL, KEYAUTH_NAME, KEYAUTH_OWNERID
    fields["name"] := KEYAUTH_NAME
    fields["ownerid"] := KEYAUTH_OWNERID
    body := ""
    for k, v in fields
        body .= (body = "" ? "" : "&") k "=" UrlEnc(v)
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.SetTimeouts(5000, 5000, 15000, 30000)
    http.Open("POST", KEYAUTH_URL, false)
    http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    http.Send(body)
    ; lê como UTF-8
    st := ComObject("ADODB.Stream")
    st.Type := 1, st.Open(), st.Write(http.ResponseBody), st.Position := 0
    st.Type := 2, st.Charset := "utf-8"
    txt := st.ReadText(), st.Close()
    return txt
}

JStr(txt, key) {
    if !RegExMatch(txt, '"' key '"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
        return ""
    v := m[1]
    v := StrReplace(v, "\n", "`n"), v := StrReplace(v, "\r", ""), v := StrReplace(v, "\t", "`t")
    v := StrReplace(v, '\"', '"'), v := StrReplace(v, "\/", "/")
    while RegExMatch(v, "\\u([0-9a-fA-F]{4})", &u)
        v := StrReplace(v, u[0], Chr(Integer("0x" u[1])))
    return StrReplace(v, "\\", "\")
}

JOk(txt) {
    return RegExMatch(txt, '"success"\s*:\s*true')
}

; abre uma sessão no KeyAuth. Retorna "" se ok, ou a mensagem de erro.
KaInit() {
    global kaSession, KEYAUTH_VER
    r := KaPost(Map("type", "init", "ver", KEYAUTH_VER))
    if (r = "KeyAuth_Invalid")
        return TT("ka_app_nf")
    if !JOk(r) {
        m := JStr(r, "message")
        return (m = "invalidver") ? TT("ka_badver") : m
    }
    kaSession := JStr(r, "sessionid")
    return ""
}

; valida a key + HWID. Retorna "" se ok, ou a mensagem de erro.
KaLicense(key) {
    global kaSession, licExpiry
    r := KaPost(Map("type", "license", "key", key, "hwid", GetHWID(), "sessionid", kaSession))
    if !JOk(r)
        return TranslateKa(JStr(r, "message"))
    licExpiry := RegExMatch(r, '"expiry"\s*:\s*"?(\d+)', &e) ? Integer(e[1]) : 0
    return ""
}

KaVar(id) {
    global kaSession
    r := KaPost(Map("type", "var", "varid", id, "sessionid", kaSession))
    return JOk(r) ? JStr(r, "message") : ""
}

; baixa um arquivo enviado em Files no KeyAuth
KaFile(fileid, dest) {
    global kaSession
    r := KaPost(Map("type", "file", "fileid", fileid, "sessionid", kaSession))
    if !JOk(r)
        throw Error(JStr(r, "message"))
    hex := JStr(r, "contents")
    DllCall("crypt32\CryptStringToBinaryW", "Str", hex, "UInt", 0, "UInt", 0xC, "Ptr", 0, "UInt*", &n := 0, "Ptr", 0, "Ptr", 0)
    buf := Buffer(n)
    DllCall("crypt32\CryptStringToBinaryW", "Str", hex, "UInt", 0, "UInt", 0xC, "Ptr", buf, "UInt*", &n, "Ptr", 0, "Ptr", 0)
    f := FileOpen(dest, "w"), f.RawWrite(buf, n), f.Close()
}

; mensagens do KeyAuth em português
TranslateKa(m) {
    static t := Map(
        "Key not found", "key_nf",
        "Invalid license key", "key_invalid",
        "HWID doesn't match", "key_hwid",
        "HWID Doesn't match", "key_hwid",
        "Subscription expired", "key_expired",
        "No active subscriptions found.", "key_expired",
        "Your HWID is blacklisted", "hwid_banned",
        "User is banned", "key_banned",
        "Your license is banned", "key_banned",
        "Invalid session", "session_exp")
    for k, v in t
        if InStr(m, k)
            return TT(v)
    return m != "" ? m : TT("key_fail")
}

ShowKeyScreen(msg := "") {
    global g, gm, gk, kStatus, KW, KH, C_MUTED, C_OFF
    FadeHide(g), FadeHide(gm)
    kStatus.SetFont("c" C_MUTED)
    kStatus.Value := msg
    if DllCall("IsWindowVisible", "Ptr", gk.Hwnd)
        gk.Show()
    else
        FadeShow(gk, Format("w{} h{} Center", KW, KH))
}

KeyMsg(msg, isErr := false) {
    global kStatus, C_MUTED, C_OFF, C_ON
    kStatus.SetFont("c" (isErr ? C_OFF : C_MUTED))
    kStatus.Value := msg
}

ActivateKey(auto := false) {
    global edKey, btnKey, iniFile, licensed, licFailSince
    key := Trim(edKey.Value)
    if (key = "") {
        KeyMsg(TT("paste_key_first"), true)
        return
    }
    btnKey.Text := TT("checking")
    KeyMsg(TT("connecting"))
    try {
        err := KaInit()
        if (err = "")
            err := KaLicense(key)
    } catch as e {
        err := TT("no_conn")
    }
    btnKey.Text := TT("btn_activate")
    if (err != "") {
        licensed := false
        KeyMsg(err, true)
        return
    }
    licensed := true, licFailSince := 0
    IniWrite(key, iniFile, "cfg", "key")
    UpdateLicenseInfo()
    StartApp()
}

UpdateLicenseInfo() {
    global licInfo, licSub, sideLic, licExpiry, edKey
    k := Trim(edKey.Value)
    masked := StrLen(k) > 8 ? SubStr(k, 1, 4) "••••" SubStr(k, -4) : k
    if (licExpiry > 0) {
        exp := DateAdd("19700101000000", licExpiry, "Seconds")
        exp := DateAdd(exp, DateDiff(A_Now, A_NowUTC, "Seconds"), "Seconds")   ; UTC -> horário do PC
        dias := DateDiff(exp, A_Now, "Days")
        if (dias > 3650) {
            licInfo.Value := TT("lic_lifetime"), sideLic.Value := TT("side_lifetime")
        } else {
            licInfo.Value := TT("lic_expires", FormatTime(exp, "ShortDate") " " FormatTime(exp, "HH:mm"), Max(dias, 0))
            sideLic.Value := TT("side_days", Max(dias, 0))
        }
    } else
        licInfo.Value := TT("lic_active"), sideLic.Value := TT("side_active")
    licSub.Value := "Key " masked "  ·  HWID " ShortHWID()
}

; confere de novo a cada 30 min. Queda de internet não derruba (tolera 2h);
; key expirada/banida para o monitoramento e pede a key.
LicenseRecheck() {
    global edKey, licensed, licFailSince, running
    try {
        err := KaInit()
        if (err = "")
            err := KaLicense(Trim(edKey.Value))
    } catch {
        if !licFailSince
            licFailSince := A_TickCount
        if (A_TickCount - licFailSince < 2 * 3600000)
            return
        err := TT("lic_offline")
    }
    if (err = "") {
        licFailSince := 0
        UpdateLicenseInfo()
        return
    }
    licensed := false
    Log(TT("log_lic_bad", err))
    SendEvent("lic", ["**" TT("d_reason") ":** " err, TT("d_stopped")])
    if running
        Toggle()
    ShowKeyScreen(err)
}

; ---------------- Atualização pela nuvem ----------------
; Baixa o script do link, lê a VERSION de dentro dele e, se for mais nova, troca o arquivo e reinicia.
; Endereço dos arquivos no commit mais recente (evita o cache de ~5 min do GitHub).
; Se a API não responder, usa o endereço normal da branch.
UpdBaseNow() {
    global updBase, GITHUB_REPO, GITHUB_BRANCH
    try {
        tmp := A_Temp "\autorejoin_sha.json"
        Download("https://api.github.com/repos/" GITHUB_REPO "/commits/" GITHUB_BRANCH, tmp)
        if RegExMatch(FileRead(tmp, "UTF-8"), '"sha"\s*:\s*"([0-9a-f]{40})"', &m)
            return "https://raw.githubusercontent.com/" GITHUB_REPO "/" m[1] "/"
    }
    return updBase
}

CheckUpdate(manual := false) {
    global updBase, VERSION, updStatus, btnUpd, chkAutoUpd, pendingUpd, pendingVer, updBadge, mSub
    if KaEnabled()
        return KaCheckUpdate(manual)
    if (updBase = "") {
        if manual
            updStatus.Value := TT("upd_not_cfg")
        return
    }
    updStatus.Value := TT("upd_searching")
    base := UpdBaseNow()
    LoadChangelog(base)
    tmp := A_Temp "\autorejoin_update.ahk"
    try {
        Download(base "roblox_autorejoin.ahk?t=" A_Now, tmp)
        txt := FileRead(tmp, "UTF-8")
    } catch as e {
        updStatus.Value := TT("upd_noconn")
        if manual
            Log(TT("upd_noconn") " " e.Message)
        return
    }
    if !(InStr(txt, "#Requires AutoHotkey v2") && RegExMatch(txt, 'm)^VERSION\s*:=\s*"([^"]+)"', &v)) {
        updStatus.Value := TT("upd_badfile")
        return
    }
    if (VerCompare(v[1], VERSION) <= 0) {
        updStatus.Value := TT("upd_latest")
        pendingUpd := ""
        updBadge.Visible := false
        return
    }
    pendingUpd := tmp, pendingVer := v[1]
    updStatus.Value := TT("upd_avail", v[1])
    btnUpd.Text := TT("btn_upd_to", v[1])
    SetBtnStyle(btnUpd, "primary")
    updBadge.Text := Chr(0x2B06) "  " TT("badge_new", v[1])
    updBadge.Visible := true
    Log(TT("log_upd_avail", v[1]))
    if chkAutoUpd.Value
        ApplyUpdate()
}

; baixa o CHANGELOG.md do GitHub e mostra na aba Sobre
LoadChangelog(base) {
    global changeBox, changelogTxt
    tmp := A_Temp "\autorejoin_changelog.md"
    try {
        Download(base "CHANGELOG.md?t=" A_Now, tmp)
        changelogTxt := FileRead(tmp, "UTF-8")
    } catch
        return
    t := RegExReplace(changelogTxt, "m)^#\s.*\R*")             ; tira o título principal
    t := RegExReplace(t, "m)^##\s*", "")                     ; "## v2.4.1" -> "v2.4.1"
    t := RegExReplace(t, "m)^\s*[-*]\s+", "    • ")
    t := StrReplace(StrReplace(t, "`r`n", "`n"), "`n", "`r`n")
    changeBox.Value := Trim(SubStr(t, 1, 6000), "`r`n ")
}

; novidades de uma versão específica (pro aviso no Discord)
ChangelogFor(ver) {
    global changelogTxt
    if RegExMatch(changelogTxt, "s)##\s*v?\Q" ver "\E[^\n]*\n(.*?)(?=\n##\s|$)", &m)
        return Trim(m[1], "`r`n ")
    return ""
}

; atualização vinda do KeyAuth (só quem tem key consegue baixar)
KaCheckUpdate(manual) {
    global VERSION, updStatus, btnUpd, chkAutoUpd, pendingUpd, pendingVer, pendingFileId, updBadge, changeBox, licensed, iniFile
    if !licensed
        return
    updStatus.Value := TT("upd_searching")
    try {
        if (KaInit() != "" || KaLicense(IniRead(iniFile, "cfg", "key", "")) != "")
            throw Error("licença")
        ver := Trim(KaVar("versao")), fid := Trim(KaVar("arquivo")), notas := KaVar("novidades")
    } catch {
        updStatus.Value := TT("upd_noconn")
        return
    }
    if (notas != "")
        changeBox.Value := StrReplace(StrReplace(notas, "`r`n", "`n"), "`n", "`r`n")
    if (ver = "" || fid = "" || VerCompare(ver, VERSION) <= 0) {
        updStatus.Value := TT("upd_latest")
        updBadge.Visible := false, pendingFileId := ""
        return
    }
    pendingVer := ver, pendingFileId := fid, pendingUpd := "keyauth"
    updStatus.Value := TT("upd_avail", ver)
    btnUpd.Text := TT("btn_upd_to", ver)
    SetBtnStyle(btnUpd, "primary")
    updBadge.Text := Chr(0x2B06) "  " TT("badge_new", ver)
    updBadge.Visible := true
    Log(TT("log_upd_avail", ver))
    if chkAutoUpd.Value
        ApplyUpdate()
}

ApplyUpdate() {
    global pendingUpd, pendingVer, pendingFileId, running, iniFile, changelogTxt, changeBox
    if (pendingUpd = "keyauth") {
        tmp := A_Temp "\autorejoin_update.ahk"
        try {
            KaFile(pendingFileId, tmp)
            if !InStr(FileRead(tmp, "UTF-8"), "#Requires AutoHotkey v2")
                throw Error(TT("upd_badfile"))
        } catch as e {
            Log(TT("log_upd_dlfail", e.Message))
            return
        }
        pendingUpd := tmp
    }
    if (pendingUpd = "" || !FileExist(pendingUpd))
        return CheckUpdate(true)
    try {
        FileCopy(A_ScriptFullPath, A_ScriptFullPath ".bak", 1)   ; backup da versão atual
        FileCopy(pendingUpd, A_ScriptFullPath, 1)
    } catch as e {
        Log(TT("log_upd_fail", e.Message))
        return
    }
    SaveConfig()
    if running
        IniWrite(1, iniFile, "cfg", "resume")
    notas := ChangelogFor(pendingVer)
    IniWrite(pendingVer, iniFile, "cfg", "justUpdated")
    Log(TT("log_updated", pendingVer))
    SendEvent("updated", notas != "" ? [notas] : [], false, pendingVer)
    Sleep(500)
    Relaunch()
}

; ---------------- Webhook ----------------
JsonEsc(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`r`n", "\n")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", "\t")
    out := ""
    for ch in StrSplit(s) {
        code := Ord(ch)
        if (code > 0xFFFF) {
            code -= 0x10000
            out .= Format("\u{:04x}\u{:04x}", 0xD800 + (code >> 10), 0xDC00 + (code & 0x3FF))
        } else
            out .= (code > 126) ? Format("\u{:04x}", code) : ch
    }
    return out
}

; ---- rede em segundo plano: manda o pedido e continua; a resposta chega depois (cb) ----
AsyncReq(method, url, body := "", ctype := "", auth := "", cb := 0) {
    global asyncReqs
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.SetTimeouts(5000, 5000, 15000, 25000)
    http.Open(method, url, true)
    if (ctype != "")
        http.SetRequestHeader("Content-Type", ctype)
    if (auth != "") {
        http.SetRequestHeader("Authorization", auth)
        http.SetRequestHeader("User-Agent", "DiscordBot (https://github.com/dudusoulls/AutoRejoinRoblox, 1.0)")
    }
    http.Send(body)
    asyncReqs.Push({h: http, cb: cb, t0: A_TickCount})
    SetTimer(AsyncPump, 40)
    return http
}

AsyncPump() {
    global asyncReqs
    i := asyncReqs.Length
    while (i >= 1) {
        r := asyncReqs[i]
        done := false
        try done := r.h.WaitForResponse(0)
        catch
            done := true
        if (done || A_TickCount - r.t0 > 35000) {
            asyncReqs.RemoveAt(i)
            if r.cb
                try r.cb.Call(r.h)
        }
        i--
    }
    if !asyncReqs.Length
        SetTimer(AsyncPump, 0)
}

HttpStatus(h) {
    try return h.Status
    return 0
}

; callback padrão dos avisos: só registra no log se falhar (ou sempre, se feedback)
HookCb(feedback := false, okMsg := "hook_sent") {
    return (h) => (st := HttpStatus(h), (st >= 200 && st < 300) ? (feedback ? Log(TT(okMsg, st)) : 0) : Log(TT("hook_fail", "HTTP " st)))
}

HttpPost(url, body, contentType, auth := "", cb := 0) {
    AsyncReq("POST", url, body, contentType, auth, cb ? cb : HookCb())
    return "…"
}

; [[nome, valor, inline], ...] -> "fields":[...],
FieldsJson(fields) {
    if !fields.Length
        return ""
    out := ""
    for f in fields
        out .= (out = "" ? "" : ",") '{"name":"' JsonEsc(f[1]) '","value":"' JsonEsc(f[2] = "" ? "—" : f[2]) '","inline":' (f.Length >= 3 && f[3] ? "true" : "false") '}'
    return '"fields":[' out '],'
}

; Pra onde vai a mensagem: resposta do bot (quando veio de um comando do Discord) ou o webhook
DiscordDest(&url, &auth, &head) {
    global botCtx, edHook, LOGO_URL
    if IsObject(botCtx) {
        url := "https://discord.com/api/v10/channels/" botCtx.ch "/messages"
        auth := "Bot " botCtx.tok
        head := '"message_reference":{"message_id":"' botCtx.mid '","fail_if_not_exists":false},'
    } else {
        url := Trim(edHook.Value), auth := ""
        head := '"username":"Auto Reconnect","avatar_url":"' LOGO_URL '",'
    }
    return url != ""
}

; Avisos do webhook, sempre como embed: kind = tipo (emoji, título, cor), lines = linhas extras
EV := Map(
    "start",   ["✅", "ev_start",   0x3DDC84],
    "reopen",  ["🔄", "ev_reopen",  0x5B8CFF],
    "fail",    ["❌", "ev_fail",    0xFF5C5C],
    "error",   ["⚠️", "ev_error",   0xF5A142],
    "back",    ["🟢", "ev_back",    0x3DDC84],
    "down",    ["🔴", "ev_down",    0xFF5C5C],
    "lic",     ["🔒", "ev_lic",     0xFF5C5C],
    "updated", ["✨", "ev_updated", 0xA78BFA],
    "test",    ["🔔", "ev_test",    0x5B8CFF],
    "daily",   ["📊", "ev_daily",   0x5B8CFF],
    "sched",   ["⏹️", "ev_sched",   0x8B8B94],
    "stop",    ["⏹️", "ev_stop",    0x8B8B94],
    "restart", ["🔄", "ev_restart", 0x5B8CFF],
    "already", ["ℹ️", "ev_already", 0x5B8CFF],
    "notrunning", ["ℹ️", "ev_notrunning", 0x8B8B94],
    "unknown", ["❓", "ev_unknown", 0xF5C542],
    "help",    ["📖", "sec_cmds",   0x5B8CFF],
    "pong",    ["🏓", "ev_pong",    0x3DDC84],
    "pc",      ["🖥️", "ev_pc",      0x5B8CFF],
    "coins",   ["💰", "ev_coins",   0xF5C542],
    "accounts", ["👥", "ev_accounts", 0x5B8CFF],
    "hist",    ["📈", "ev_hist",    0xA78BFA],
    "logs",    ["📜", "ev_logs",    0x8B8B94],
    "link",    ["🔗", "ev_link",    0x3DDC84],
    "linkbad", ["⚠️", "ev_linkbad", 0xF5C542],
    "updnone", ["✨", "ev_updnone", 0x3DDC84],
    "updating", ["✨", "ev_updating", 0xA78BFA],
    "shutdown", ["🔌", "ev_shutdown", 0xFF5C5C],
    "shutconf", ["🔌", "ev_shutconf", 0xF5C542],
    "cancel",  ["✅", "ev_cancel",  0x3DDC84],
    "backin",  ["🟢", "ev_back",    0x3DDC84],
    "stuck",   ["🧊", "ev_stuck",   0xF5C542])

SendEvent(kind, lines := [], feedback := false, arg := "", fields := [], thumb := false, img := "") {
    global edHook, EV, APP_NAME, USER_NAME, LOGO_URL, chkMention, edDiscId, VERSION
    evt := EV[kind]
    ; notificação do Windows nos avisos importantes
    if (kind = "down" || kind = "back" || kind = "error" || kind = "fail" || kind = "lic") {
        plain := ""
        for l in lines
            plain .= StrReplace(l, "**") "`n"
        Notify(TT(evt[2], arg), plain != "" ? RTrim(plain, "`n") : APP_NAME, kind = "back" ? "Iconi" : "Icon!")
    }
    if !DiscordDest(&url, &auth, &head) {
        if feedback
            Log(TT("hook_need_url"))
        return
    }
    now := DateDiff(A_NowUTC, "19700101000000", "Seconds")
    ; marca só o seu ID (nunca @everyone / @here)
    id := Trim(edDiscId.Value)
    ping := (chkMention.Value && RegExMatch(id, "^\d{15,21}$") && (kind = "down" || kind = "error" || kind = "fail" || kind = "lic"))
    desc := ""
    for l in lines
        desc .= l "`n"
    desc .= "**" TT("d_time") ":** <t:" now ":T>  ·  <t:" now ":R>"
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    e := '{' head
       . (ping ? '"content":"<@' id '>","allowed_mentions":{"users":["' id '"]},' : '"allowed_mentions":{"parse":[]},')
       . '"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc(evt[1] "  " TT(evt[2], arg)) '",'
       . '"color":' evt[3] ','
       . '"description":"' JsonEsc(desc) '",'
       . FieldsJson(fields)
       . (thumb ? '"thumbnail":{"url":"' LOGO_URL '"},' : '')
       . (img != "" ? '"image":{"url":"attachment://roblox.png"},' : '')
       . '"footer":{"text":"' JsonEsc(USER_NAME "  •  " A_ComputerName "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
       . '"timestamp":"' ts '"'
       . '}]}'
    try {
        cb := HookCb(feedback)
        if (img != "" && FileExist(img))
            SendWebhookImage(url, e, img, auth, cb)
        else
            HttpPost(url, e, "application/json", auth, cb)
    } catch as err {
        Log(TT("hook_fail", err.Message))
    }
}

; Texto simples pro webhook (não usado pelos avisos)
SendWebhook(msg, feedback := false) {
    global edHook
    url := Trim(edHook.Value)
    if (url = "") {
        if feedback
            Log(TT("hook_need_url"))
        return
    }
    try {
        st := HttpPost(url, '{"content":"' JsonEsc(msg) '"}', "application/json")
        if feedback
            Log(TT("hook_sent", st))
    } catch as e {
        Log(TT("hook_fail", e.Message))
    }
}

SendWebhookImage(url, payload, pngPath, auth := "", cb := 0) {
    bnd := "----AHKRejoin" A_TickCount
    head := "--" bnd "`r`n"
        . 'Content-Disposition: form-data; name="payload_json"' "`r`n"
        . "Content-Type: application/json`r`n`r`n"
        . payload "`r`n"
        . "--" bnd "`r`n"
        . 'Content-Disposition: form-data; name="files[0]"; filename="roblox.png"' "`r`n"
        . "Content-Type: image/png`r`n`r`n"
    tail := "`r`n--" bnd "--`r`n"

    img := FileRead(pngPath, "RAW")
    hb := Buffer(StrPut(head, "UTF-8")), StrPut(head, hb, "UTF-8"), hn := hb.Size - 1
    tb := Buffer(StrPut(tail, "UTF-8")), StrPut(tail, tb, "UTF-8"), tn := tb.Size - 1
    total := hn + img.Size + tn

    arr := ComObjArray(0x11, total)
    psa := ComObjValue(arr)
    DllCall("oleaut32\SafeArrayAccessData", "Ptr", psa, "Ptr*", &p := 0)
    DllCall("RtlMoveMemory", "Ptr", p, "Ptr", hb, "UPtr", hn)
    DllCall("RtlMoveMemory", "Ptr", p + hn, "Ptr", img, "UPtr", img.Size)
    DllCall("RtlMoveMemory", "Ptr", p + hn + img.Size, "Ptr", tb, "UPtr", tn)
    DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", psa)

    return HttpPost(url, arr, "multipart/form-data; boundary=" bnd, auth, cb)
}

; ---------------- Print só da janela do Roblox ----------------
; PrintWindow pega o conteúdo da janela mesmo se tiver outra coisa por cima.
; Se vier preto (alguns drivers), cai pro método de copiar da tela.
CaptureWindowPng(hwnd, file) {
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", hwnd, "Ptr", rc)
    w := NumGet(rc, 8, "Int"), h := NumGet(rc, 12, "Int")
    if (w < 10 || h < 10)
        return false

    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    mDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
    hBM := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", w, "Int", h, "Ptr")
    obm := DllCall("SelectObject", "Ptr", mDC, "Ptr", hBM, "Ptr")

    ok := DllCall("PrintWindow", "Ptr", hwnd, "Ptr", mDC, "UInt", 3)   ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
    if (!ok || IsBlackDC(mDC, w, h)) {
        pt := Buffer(8, 0)
        DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", pt)
        DllCall("BitBlt", "Ptr", mDC, "Int", 0, "Int", 0, "Int", w, "Int", h
            , "Ptr", hDC, "Int", NumGet(pt, 0, "Int"), "Int", NumGet(pt, 4, "Int"), "UInt", 0x00CC0020)
    }

    DllCall("SelectObject", "Ptr", mDC, "Ptr", obm)
    DllCall("DeleteDC", "Ptr", mDC)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    r := SaveHBitmapPng(hBM, file)
    DllCall("DeleteObject", "Ptr", hBM)
    return r
}

IsBlackDC(dc, w, h) {
    Loop 5 {
        i := A_Index
        Loop 5
            if DllCall("GetPixel", "Ptr", dc, "Int", w * i // 6, "Int", h * A_Index // 6, "UInt")
                return false
    }
    return true
}

SaveHBitmapPng(hBM, file) {
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &token := 0, "Ptr", si, "Ptr", 0)
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBM, "Ptr", 0, "Ptr*", &pBmp := 0)
    clsid := Buffer(16)
    DllCall("ole32\CLSIDFromString", "Str", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid)
    r := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBmp, "WStr", file, "Ptr", clsid, "Ptr", 0)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBmp)
    DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
    return r = 0
}

SendStatusReport(manual := false) {
    global edHook, running, launches, discCount, lastDisc, lastDiscUnix, monStart, discTick, chkOcr, chkRep, edRepMin, USER_NAME, APP_NAME, LOGO_URL
    if !DiscordDest(&url, &auth, &head) {
        if manual
            Log(TT("hook_need_url"))
        return
    }
    open := IsRobloxOpen()
    hw := FindGameWindow()

    png := A_Temp "\roblox_status.png"
    shot := false, why := ""
    if !hw
        why := TT("why_closed")
    else if (WinGetMinMax(hw) = -1)
        why := TT("why_min")
    else {
        try shot := CaptureWindowPng(hw, png)
        if !shot
            why := TT("why_fail")
    }

    stats := ""
    if (shot && chkOcr.Value) {
        try stats := CurrencyBlock(ReadCurrencies(hw))
        catch as err
            Log(TT("log_coin_err", err.Message))
    }

    if !open
        title := "🔴  " TT("emb_offline"), color := 0xFF5C5C
    else if discTick
        title := "🟡  " TT("emb_warn"), color := 0xF5C542
    else
        title := "🟢  " TT("emb_online"), color := 0x3DDC84

    up := running ? DurStr(A_TickCount - monStart) : TT("up_stopped")
    queda := lastDiscUnix ? "<t:" lastDiscUnix ":t>  ·  <t:" lastDiscUnix ":R>" : TT("none")
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    foot := USER_NAME "  •  " A_ComputerName (running && chkRep.Value ? "  •  " TT("next_status", Integer(edRepMin.Value || 60)) : "")
    if !shot
        foot .= "  •  " TT("no_shot", why)

    e := '{' head '"allowed_mentions":{"parse":[]},"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc(title) '",'
       . '"color":' color ','
       . (stats != "" ? '"description":"' JsonEsc(stats) '",' : '')
       . '"fields":['
       . '{"name":"' JsonEsc("⏱️ " TT("f_uptime")) '","value":"``' JsonEsc(up) '``","inline":true},'
       . '{"name":"' JsonEsc("🔁 " TT("f_reopens")) '","value":"``' launches '``","inline":true},'
       . '{"name":"' JsonEsc("📉 " TT("f_drops")) '","value":"``' discCount '``","inline":true},'
       . '{"name":"' JsonEsc("🕒 " TT("f_lastdrop")) '","value":"' JsonEsc(queda) '","inline":false}'
       . '],'
       . (shot ? '"image":{"url":"attachment://roblox.png"},' : '')
       . '"footer":{"text":"' JsonEsc(foot) '"},'
       . '"timestamp":"' ts '"'
       . '}]}'

    try {
        cb := HookCb(true, "log_status_sent")
        if shot
            SendWebhookImage(url, e, png, auth, cb)
        else
            HttpPost(url, e, "application/json", auth, cb)
        if !shot
            Log(TT("no_shot", why))
    } catch as err {
        Log(TT("log_status_fail", err.Message))
    }
}

; ---------------- Moedas (OCR) ----------------
NormTok(s) {
    return StrLower(RegExReplace(s, "[^\p{L}\p{N}]"))
}

ParseNum(s) {
    if RegExMatch(s, "i)[kmb]$")
        return ""
    d := RegExReplace(s, "\D")
    return (d = "") ? "" : Integer(d)
}

FmtNum(n) {
    sign := (n < 0) ? "-" : ""
    return sign RegExReplace(Abs(n), "\G\d+?(?=(\d{3})+$)", "$0,")
}

; Lê as moedas na janela do Roblox. Retorna Map(nome -> texto do valor) na ordem dos nomes.
; Procura cada nome na tela e pega o número logo acima (ou do lado) dele.
ReadCurrencies(hw) {
    global edCur, lastOcrText
    labels := []
    for c in CurrencySpec()
        labels.Push(c.name)
    found := Map()
    if !labels.Length
        return [labels, found]

    ; tenta jeitos diferentes de capturar até achar pelo menos um nome
    ; mode 4 = PrintWindow (funciona com janela coberta), 0 = copia da tela
    lastOcrText := ""
    ; começa pelo jeito que funcionou da última vez; os outros só de vez em quando
    static opts := [{scale: 3, mode: 0}, {scale: 3, mode: 4}, {scale: 3, mode: 0, grayscale: 1, invertcolors: 1}]
    static best := 1, lastFull := 0
    f := MatchCurrencies(labels, OcrWords(hw, opts[best]))
    if f.Count
        return [labels, f]
    if (A_TickCount - lastFull < 180000 && lastFull)
        return [labels, Map()]
    lastFull := A_TickCount
    for i, opt in opts {
        if (i = best)
            continue
        f := MatchCurrencies(labels, OcrWords(hw, opt))
        if f.Count {
            best := i
            return [labels, f]
        }
    }
    return [labels, Map()]
}

; maior zoom possível sem passar do limite de tamanho do OCR do Windows
OcrScale(hw, want) {
    try WinGetClientPos(, , &w, &h, hw)
    catch
        return 1
    big := Max(w, h, 1)
    lim := OCR.MaxImageDimension ? OCR.MaxImageDimension : 2600
    return Max(0.5, Min(want, Floor((lim - 20) / big * 10) / 10))
}

OcrWords(hw, opt) {
    global lastOcrText
    words := []
    opt := opt.Clone()
    opt.scale := OcrScale(hw, opt.scale)
    try {
        res := OCR.FromWindow("ahk_id " hw, opt)
    } catch as e {
        lastOcrText .= "[erro mode " opt.mode ": " e.Message "]`n"
        return words
    }
    lastOcrText .= "[mode " opt.mode "] " SubStr(RegExReplace(res.Text, "\s+", " "), 1, 300) "`n"
    for line in res.Lines {
        li := A_Index
        for wd in line.Words
            words.Push({t: NormTok(wd.Text), raw: wd.Text, x: wd.x, y: wd.y, w: wd.w, h: wd.h, line: li, used: false})
    }
    return words
}

; distância de edição (aceita 1 letra errada do OCR, ex: "Gerns" = "Gems")
Lev(a, b) {
    la := StrLen(a), lb := StrLen(b)
    if !la
        return lb
    if !lb
        return la
    prev := []
    Loop lb + 1
        prev.Push(A_Index - 1)
    Loop la {
        i := A_Index, cur := [i], ca := SubStr(a, i, 1)
        Loop lb {
            j := A_Index
            cost := (ca = SubStr(b, j, 1)) ? 0 : 1
            cur.Push(Min(prev[j + 1] + 1, cur[j] + 1, prev[j] + cost))
        }
        prev := cur
    }
    return prev[lb + 1]
}

TokEq(a, b) {
    if (a = b)
        return true
    return StrLen(b) >= 4 && Lev(a, b) <= 1
}

MatchCurrencies(labels, words) {
    found := Map()

    ; nomes com mais palavras primeiro ("Legacy Gems" antes de "Gems")
    order := []
    Loop 6 {
        n := 7 - A_Index
        for lab in labels
            if (StrSplit(Trim(RegExReplace(lab, "\s+", " ")), " ").Length = n)
                order.Push(lab)
    }

    for lab in order {
        toks := []
        for tk in StrSplit(Trim(RegExReplace(lab, "\s+", " ")), " ")
            toks.Push(NormTok(tk))
        best := 0, bestScore := 1e9, bestLab := 0
        Loop Max(0, words.Length - toks.Length + 1) {
            i := A_Index, ok := true
            for k, tk in toks {
                wd := words[i + k - 1]
                if (wd.used || !TokEq(wd.t, tk) || wd.line != words[i].line) {
                    ok := false
                    break
                }
            }
            if !ok
                continue
            ; retângulo do nome
            L := words[i], R := words[i + toks.Length - 1]
            lx := L.x, ly := Min(L.y, R.y), lw := R.x + R.w - L.x, lh := Max(L.h, R.h)
            ; número mais próximo
            for j, wd in words {
                if (wd.used || j >= i && j < i + toks.Length)
                    continue
                num := RegExReplace(wd.raw, "[^\d.,kKmMbB]+$")
                if !RegExMatch(num, "^\d[\d.,]*[kKmMbB]?$")
                    continue
                dy := ly - (wd.y + wd.h)
                if (dy >= -3 && dy <= lh * 3 && wd.x < lx + lw && wd.x + wd.w > lx - lh * 3)
                    sc := dy + Abs(wd.x - lx) * 0.5
                else if (wd.line = L.line && wd.x + wd.w <= lx)
                    sc := 1000 + (lx - wd.x - wd.w)
                else if (wd.line = L.line && wd.x >= lx + lw)
                    sc := 2000 + (wd.x - lx - lw)
                else
                    continue
                if (sc < bestScore)
                    bestScore := sc, best := j, bestLab := i
            }
        }
        if best {
            found[lab] := RegExReplace(words[best].raw, "[^\d.,kKmMbB]+$")
            words[best].used := true
            Loop toks.Length
                words[bestLab + A_Index - 1].used := true
        }
    }
    return found
}

; monta os campos do embed e atualiza a tela de "Última leitura"
; lê o campo "Gems=<:gems:123>|Gold|..." -> [{name, emoji}]
CurrencySpec() {
    global edCur
    out := []
    for part in StrSplit(edCur.Value, "|") {
        kv := StrSplit(part, "=", , 2)
        name := Trim(kv[1])
        if (name = "")
            continue
        emo := (kv.Length > 1) ? Trim(kv[2]) : ""
        out.Push({name: name, emoji: emo != "" ? emo : DefaultEmoji(name)})
    }
    return out
}

DefaultEmoji(name) {
    n := StrLower(name)
    if InStr(n, "legacy")
        return "💠"
    if InStr(n, "gem")
        return "💎"
    if InStr(n, "gold") || InStr(n, "coin")
        return "🪙"
    if InStr(n, "pearl")
        return "🫧"
    return "🔸"
}

; monta o bloco "Player Stats" do embed e atualiza a tela de "Última leitura"
CurrencyBlock(cur) {
    global prevCur, curView
    found := cur[2]
    out := "", view := ""
    for c in CurrencySpec() {
        lab := c.name
        if !found.Has(lab) {
            view .= lab ": " TT("not_found") "`n"
            continue
        }
        val := found[lab], delta := "", vdelta := ""
        n := ParseNum(val)
        if (n != "")
            val := FmtNum(n)
        if (n != "" && prevCur.Has(lab) && prevCur[lab] != "") {
            d := n - prevCur[lab]
            if d {
                delta := "  ``" (d > 0 ? "▲ +" : "▼ ") FmtNum(d) "``"
                vdelta := " (" (d > 0 ? "+" : "") FmtNum(d) ")"
            }
        }
        prevCur[lab] := n
        if (n != "")
            DayCoin(lab, n)
        out .= c.emoji "  **" val "**" delta "  ·  " lab "`n"
        view .= lab ": " val vdelta "`n"
    }
    curView.Value := view = "" ? TT("nothing_read") : RTrim(view, "`n")
    CoinsObserved(found)
    return out = "" ? "" : "### Player Stats`n" out
}

TestCurrencies() {
    global curView, lastOcrText
    hw := FindGameWindow()
    if !hw || WinGetMinMax(hw) = -1 {
        curView.Value := TT("ocr_open")
        return
    }
    try {
        cur := ReadCurrencies(hw)
        found := cur[2]
        view := ""
        for lab in cur[1]
            view .= lab ": " (found.Has(lab) ? found[lab] : TT("not_found")) "`n"
        curView.Value := view = "" ? TT("ocr_names") : RTrim(view, "`n")
        Log(TT("log_ocr_tested", found.Count, cur[1].Length))
        if (found.Count < cur[1].Length)
            Log(TT("log_ocr_saw") "`r`n" StrReplace(RTrim(lastOcrText, "`n"), "`n", "`r`n"))
    } catch as e {
        curView.Value := TT("ocr_err", e.Message)
        Log(TT("ocr_err", e.Message))
    }
}

ReportTick() {
    global running, chkRep
    if running && chkRep.Value
        SendStatusReport()
}

ApplyReportTimer() {
    global running, chkRep, edRepMin
    if (running && chkRep.Value) {
        m := Integer(edRepMin.Value || 60)
        if (m < 1)
            m := 1
        SetTimer(ReportTick, m * 60000)
    } else
        SetTimer(ReportTick, 0)
}

; ---------------- Roblox ----------------
; Lista de jeitos de abrir o jogo, do melhor pro reserva.
;   uri = abre o link roblox:// pelo Windows
;   exe = passa o link roblox:// direto pro executável do Roblox (não precisa do navegador
;         nem do roblox:// registrado no Windows)
;   web = abre pelo navegador (reserva)
; O script tenta um por um até o Roblox abrir de verdade e lembra qual funcionou.
LaunchMethods(link) {
    link := Trim(link), deep := [], web := ""
    if RegExMatch(link, "i)^roblox(-player)?:") {
        deep.Push(link)
    } else if RegExMatch(link, "^\d+$") {
        deep.Push("roblox://experiences/start?placeId=" link)
        deep.Push("roblox://placeId=" link)
        web := "https://www.roblox.com/games/" link
    } else if RegExMatch(link, "i)roblox\.com/(?:[a-z\-]+/)?games/(\d+)", &m) {
        lc := RegExMatch(link, "i)privateServerLinkCode=([\w\-]+)", &c) ? "&linkCode=" c[1] : ""
        deep.Push("roblox://experiences/start?placeId=" m[1] lc)
        deep.Push("roblox://placeId=" m[1] lc)
        web := link
    } else if RegExMatch(link, "i)roblox\.com/share(?:-links)?\?.*?code=([\w\-]+)", &c) {
        t := RegExMatch(link, "i)type=(\w+)", &tp) ? tp[1] : "Server"
        deep.Push("roblox://navigation/share_links?code=" c[1] "&type=" t)
        web := link
    } else
        web := link

    list := []
    for d in deep
        list.Push({kind: "exe", target: d})
    for d in deep
        list.Push({kind: "uri", target: d})
    if (web != "")
        list.Push({kind: "web", target: web})
    return list
}

; comando que o Windows usa pra abrir o Roblox (registrado pelo Roblox/Bloxstrap/Fishstrap)
PlayerCommand() {
    for key in ["HKCU\Software\Classes\roblox-player\shell\open\command"
              , "HKCR\roblox-player\shell\open\command"
              , "HKCU\Software\Classes\roblox\shell\open\command"
              , "HKCR\roblox\shell\open\command"] {
        try {
            cmd := RegRead(key)
            if (cmd != "" && InStr(cmd, "%1"))
                return cmd
        }
    }
    return ""
}

RunMethod(m) {
    if (m.kind = "exe") {
        cmd := PlayerCommand()
        if (cmd = "")
            throw Error(TT("roblox_not_reg"))
        cmd := StrReplace(cmd, '"%1"', '"' m.target '"')
        cmd := StrReplace(cmd, "%1", '"' m.target '"')
        Run(cmd)
    } else
        Run(m.target)
}

MethodName(m) {
    return TT(Map("exe", "m_exe", "uri", "m_uri", "web", "m_web")[m.kind])
}

IsRobloxOpen() {
    return ProcessExist("RobloxPlayerBeta.exe") || ProcessExist("Windows10Universal.exe")
}

FindGameWindow() {
    h := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")
    if !h
        h := WinExist("ahk_exe RobloxPlayerBeta.exe")
    if !h
        h := WinExist("Roblox ahk_exe Windows10Universal.exe")
    return h
}

; Abre o jogo. Se um jeito falhar (erro ou o Roblox não aparecer em 25s), tenta o próximo.
LaunchGame(manual := false, idx := 0, tries := 0) {
    global edLink, lastLaunch, launches, browserLaunch, launchToken, iniFile, joinedTick, openedTick, launchStart
    link := Trim(edLink.Value)
    if (link = "") {
        Log(TT("paste_link_first"))
        return
    }
    list := LaunchMethods(link)
    if (idx > list.Length || tries >= list.Length) {
        Log(TT("log_all_failed"))
        static lastFail := 0
        if (!lastFail || A_TickCount - lastFail > 600000) {   ; avisa no máximo a cada 10 min
            lastFail := A_TickCount
            SendEvent("fail", [TT("d_retry")])
        }
        return
    }
    if !idx
        idx := 1   ; sempre começa pelo primeiro: direto > link roblox:// > navegador
    m := list[idx]
    nextIdx := idx + 1

    if !tries
        ApplyEco()
    try {
        RunMethod(m)
    } catch as err {
        Log(TT("log_method_failed", idx, list.Length, MethodName(m), err.Message))
        return LaunchGame(manual, nextIdx, tries + 1)
    }
    browserLaunch := (m.kind = "web") ? A_TickCount : 0
    lastLaunch := A_TickCount
    launchStart := A_TickCount
    joinedTick := 0, openedTick := 0
    if !tries
        launches++
    if (!tries && !manual)
        DayAdd("reopens")
    Log(TT(manual ? "log_opening" : "log_reopening", MethodName(m)))
    SetTimer(LaunchPoll, 1000)
    if (!manual && !tries)
        SendEvent("reopen", ["**" TT("d_method") ":** " MethodName(m)])

    ; confere se abriu de verdade
    token := ++launchToken
    SetTimer(() => VerifyLaunch(token, manual, idx, nextIdx, tries), -25000)
}

; Roda a cada 1s logo depois de abrir: avisa quando o processo abriu e quando entrou no jogo,
; sem esperar o tempo fixo de "Esperar após abrir".
LaunchPoll() {
    global lastLaunch, joinedTick, openedTick, edWait, restartReply, botCtx
    if !lastLaunch {
        SetTimer(LaunchPoll, 0)
        return
    }
    el := A_TickCount - lastLaunch
    if (el > Integer(edWait.Value || 90) * 1000) {
        SetTimer(LaunchPoll, 0)
        return
    }
    ReadNewLogLines()
    if (!openedTick && IsRobloxOpen()) {
        openedTick := A_TickCount
        Log(TT("log_opened", Round(el / 1000)))
        SetState("wait", TT("st_joining"), TT("st_joining_sub"))
    }
    if (openedTick && joinedTick && FindGameWindow()) {
        Log(TT("log_joined", Round((A_TickCount - lastLaunch) / 1000)))
        if IsObject(restartReply) {
            botCtx := restartReply
            try SendEvent("backin", [TT("d_back_in", Round((A_TickCount - restartReply.t0) / 1000))], false, "", [], true)
            botCtx := 0, restartReply := 0
        }
        lastLaunch := 0
        SetTimer(LaunchPoll, 0)
        Check()
    }
}

; Confere em 2 etapas se o jeito de abrir funcionou:
;   25s: o Roblox tem que estar aberto
;   60s: tem que ter entrado no jogo (pelo log). Se o Roblox abriu mas ficou na tela inicial,
;        fecha e tenta o próximo jeito.
VerifyLaunch(token, manual, idx, nextIdx, tries, stage := 1) {
    global launchToken, iniFile, joinedTick, logSeenTick, launchStart
    if (token != launchToken)      ; já teve outra abertura depois dessa
        return
    if (stage = 1) {
        if !IsRobloxOpen() {
            Log(TT("log_not_open25"))
            return LaunchGame(manual, nextIdx, tries + 1)
        }
        SetTimer(() => VerifyLaunch(token, manual, idx, nextIdx, tries, 2), -35000)
        return
    }
    if joinedTick {
        return
    }
    ; só troca de jeito se o log do Roblox estiver funcionando (log novo apareceu)
    if (logSeenTick >= launchStart && IsRobloxOpen()) {
        Log(TT("log_not_join60"))
        KillRoblox()
        Sleep(2000)
        LaunchGame(manual, nextIdx, tries + 1)
    }
}

KillRoblox() {
    for exe in ["RobloxPlayerBeta.exe", "Windows10Universal.exe", "RobloxPlayerLauncher.exe", "RobloxCrashHandler.exe"] {
        Loop 10 {
            if !ProcessExist(exe)
                break
            ProcessClose(exe)
            Sleep(300)
        }
    }
}

; Borda visível da janela (sem a borda invisível/sombra do Windows)
; Retorna [left, top, right, bottom] em coordenadas de tela
VisibleRect(hwnd) {
    rc := Buffer(16, 0)
    if DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rc, "UInt", 16) != 0 {
        WinGetPos(&x, &y, &w, &h, hwnd)
        return [x, y, x + w, y + h]
    }
    return [NumGet(rc, 0, "Int"), NumGet(rc, 4, "Int"), NumGet(rc, 8, "Int"), NumGet(rc, 12, "Int")]
}

; Gruda a janela no canto superior direito (borda visível encostada na tela).
; winW/winH = tamanho visível. Retorna true se já estava no lugar.
PlaceRoblox(hwnd) {
    global winW, winH, fsTries
    mm := WinGetMinMax(hwnd)
    WinGetPos(&x, &y, &w, &h, hwnd)
    v := VisibleRect(hwnd)

    if (mm = 0 && Abs(v[3] - A_ScreenWidth) <= 1 && Abs(v[2]) <= 1
        && Abs((v[3] - v[1]) - winW) <= 2 && Abs((v[4] - v[2]) - winH) <= 2)
        return true

    ; tela cheia -> sai com F11 (no máximo 2 vezes por janela)
    if (mm = 0 && w >= A_ScreenWidth - 20 && h >= A_ScreenHeight - 20 && fsTries < 2) {
        fsTries++
        WinActivate(hwnd)
        Sleep(300)
        Send("{F11}")
        Sleep(1200)
    }
    if (WinGetMinMax(hwnd) != 0) {
        WinRestore(hwnd)
        Sleep(200)
    }

    ; mede a borda invisível de cada lado e compensa
    WinGetPos(&x, &y, &w, &h, hwnd)
    v := VisibleRect(hwnd)
    offL := v[1] - x, offT := v[2] - y
    offR := (x + w) - v[3], offB := (y + h) - v[4]

    WinMove(A_ScreenWidth - winW - offL, -offT, winW + offL + offR, winH + offT + offB, hwnd)
    return false
}

ForcePlace() {
    global fsTries
    h := FindGameWindow()
    if !h {
        Log(TT("log_not_open"))
        return
    }
    fsTries := 0
    PlaceRoblox(h)
    Log(TT("log_placed"))
}

; título da guia ativa, sem o nome do navegador no final
TabTitle(hwnd) {
    t := WinGetTitle(hwnd)
    t := RegExReplace(t, "\s+[-–—]\s+(Brave|Google Chrome|Mozilla Firefox|Opera|Opera GX|Microsoft\W+Edge)$")
    t := RegExReplace(t, "\s+-\s+(Pessoal|Personal|Trabalho|Work|Perfil \d+|Profile \d+)$")
    return Trim(t)
}

; é a página do Roblox? ("Roblox" ou "Nome do jogo - Roblox")
IsRobloxTab(hwnd) {
    t := TabTitle(hwnd)
    return RegExMatch(t, "i)(^|\s[-–|]\s)Roblox$") || RegExMatch(t, "i)roblox\.com/(share|games)")
}

; Fecha só a guia do Roblox que o script abriu (se a guia ativa for outra, não mexe)
CloseBrowserTab() {
    n := 0
    for exe in ["brave.exe", "chrome.exe", "msedge.exe", "firefox.exe", "opera.exe"] {
        for hwnd in WinGetList("ahk_exe " exe) {
            if !IsRobloxTab(hwnd)
                continue
            try {
                WinActivate(hwnd)
                if WinWaitActive(hwnd, , 2) && IsRobloxTab(hwnd) {
                    Send("^w")
                    Sleep(600)
                    n++
                }
            }
        }
    }
    for hwnd in WinGetList("ahk_exe RobloxPlayerLauncher.exe") {
        try WinClose(hwnd)
        n++
    }
    return n
}

Cleanup() {
    global curHwnd, detectTick, tabDone, fsTries, placedLogged, chkShrink, chkMin, browserLaunch, multiActive
    if multiActive
        return
    h := FindGameWindow()
    if !h {
        curHwnd := 0
        return
    }
    try LowPrio(WinGetPID(h))
    if (h != curHwnd) {
        curHwnd := h
        detectTick := A_TickCount
        tabDone := false
        fsTries := 0
        placedLogged := false
        Log(TT("log_detected"))
    }
    since := A_TickCount - detectTick

    if (chkShrink.Value && since > 3000 && since < 90000) {
        try {
            if !PlaceRoblox(h) && !placedLogged {
                placedLogged := true
                Log(TT("log_placed_right"))
            }
        }
    }

    if (chkMin.Value && !tabDone && since > 10000) {
        tabDone := true
        if (browserLaunch && A_TickCount - browserLaunch < 180000) {
            browserLaunch := 0
            n := CloseBrowserTab()
            if n
                Log(TT("log_tab_closed"))
            else {
                t := ""
                for exe in ["brave.exe", "chrome.exe", "msedge.exe", "firefox.exe", "opera.exe"]
                    for hw in WinGetList("ahk_exe " exe)
                        if ((wt := WinGetTitle(hw)) != "")
                            t .= "`r`n    • " wt
                Log(TT("log_tab_nf") (t = "" ? " " TT("none_lc") : t))
            }
        }
    }
}

; ---------------- Detecção de erro ----------------
LatestRobloxLog() {
    global lastLaunch
    static cache := "", t := 0
    ; logo depois de abrir o Roblox procura sempre (log novo); no resto, a cada 20s
    if (cache != "" && A_TickCount - t < ((lastLaunch && A_TickCount - lastLaunch < 120000) ? 2500 : 20000) && FileExist(cache))
        return cache
    t := A_TickCount
    cache := LatestRobloxLogScan()
    return cache
}

LatestRobloxLogScan() {
    pattern := EnvGet("LOCALAPPDATA") "\Roblox\logs\*_Player_*.log"
    best := ""
    bestT := 0
    Loop Files pattern {
        if (A_LoopFileTimeModified > bestT) {
            bestT := A_LoopFileTimeModified
            best := A_LoopFileFullPath
        }
    }
    return best
}

ReadNewLogLines() {
    global curLog, logPos, logCarry, discTick, errPat, joinPat, pendingJoin, lastLaunch, joinedTick, logSeenTick
    f := LatestRobloxLog()
    if (f = "")
        return
    try {
        fo := FileOpen(f, "r", "UTF-8")
    } catch {
        return
    }
    size := fo.Length
    if (f != curLog) {
        ; primeiro log ao iniciar o script: ignora o passado. Log novo depois disso: lê tudo.
        logPos := (curLog = "") ? size : 0
        if (curLog != "")
            logSeenTick := A_TickCount
        curLog := f
        logCarry := ""
    } else if (size < logPos) {
        logPos := 0
    }
    chunk := ""
    if (size > logPos) {
        fo.Pos := logPos
        chunk := fo.Read()
        logPos := fo.Pos
    }
    fo.Close()
    if (chunk = "")
        return

    lines := StrSplit(logCarry chunk, "`n", "`r")
    logCarry := lines.Pop()
    for line in lines {
        if RegExMatch(line, "i)" joinPat) {
            if lastLaunch
                joinedTick := A_TickCount
            if discTick
                pendingJoin := A_TickCount   ; confirma só se não cair de novo em 20s
        } else if RegExMatch(line, "i)" errPat) {
            pendingJoin := 0
            if !discTick {
                discTick := A_TickCount
                Log(TT("log_disc_log"))
            }
        }
    }
}

RecoverRoblox(reason) {
    global wasOpen, downTick
    Log(TT("log_err_restart", reason))
    shot := ""
    hw := FindGameWindow()
    if (hw && WinGetMinMax(hw) != -1) {
        try {
            if CaptureWindowPng(hw, A_Temp "\roblox_err.png")
                shot := A_Temp "\roblox_err.png"
        }
    }
    SendEvent("error", ["**" TT("d_reason") ":** " reason, TT("d_restart")], false, "", [], false, shot)
    MarkDisconnect()
    wasOpen := false
    downTick := A_TickCount
    KillRoblox()
    Sleep(3000)
    LaunchGame()
}

; Procura a tela "Disconnected / Error Code" na janela do Roblox (OCR).
; Retorna o código do erro, "?" se achou a tela sem código, ou "" se não achou.
FindDisconnectDialog(hw) {
    static mode := 4                           ; lembra o jeito de capturar que funciona nesse PC
    Loop 2 {
        t := ""
        try t := OCR.FromWindow("ahk_id " hw, {scale: OcrScale(hw, 1), mode: mode}).Text
        if (Trim(t) = "") {                    ; captura veio vazia/preta: troca o jeito e tenta 1x
            mode := (mode = 4) ? 0 : 4
            continue
        }
        if RegExMatch(t, "i)Error\s*Code\W*(\d{3})", &m)
            return m[1]
        if RegExMatch(t, "i)Disconnected|Reconnect was unsuccessful|You were kicked|Connection lost")
            return "?"
        return ""
    }
    return ""
}

WatchError() {
    global running, chkErr, edErrSec, edWait, lastLaunch, discTick, hungSince, pendingJoin, dlgSeen, watchN, multiActive
    if !running || !chkErr.Value || multiActive
        return
    ReadNewLogLines()

    if !IsRobloxOpen() || (lastLaunch && (A_TickCount - lastLaunch) < Integer(edWait.Value || 90) * 1000) {
        discTick := 0, pendingJoin := 0, hungSince := 0, dlgSeen := 0
        return
    }
    tol := Integer(edErrSec.Value || 60) * 1000
    h := FindGameWindow()

    ; 1) tela "Disconnected" na janela (checa a cada ~9s). Vista 2x seguidas -> reinicia.
    if (h && WinGetMinMax(h) != -1 && Mod(++watchN, 5) = 0) {
        code := FindDisconnectDialog(h)
        if (code != "") {
            dlgSeen++
            if (dlgSeen = 1) {
                Log(code != "?" ? TT("log_disc_screen_c", code) : TT("log_disc_screen"))
                if !discTick
                    discTick := A_TickCount
            } else {
                dlgSeen := 0, discTick := 0, pendingJoin := 0
                RecoverRoblox(code != "?" ? TT("r_disc_screen_c", code) : TT("r_disc_screen"))
                return
            }
        } else
            dlgSeen := 0
    }

    ; 2) entrou de novo e ficou estável 20s -> foi teleport/reconexão normal
    if (discTick && pendingJoin && A_TickCount - pendingJoin > 20000) {
        discTick := 0, pendingJoin := 0
        Log(TT("log_rejoined"))
    }

    ; 3) desconectou e não voltou dentro da tolerância
    ;    (se estiver no meio de uma tentativa de entrar, espera até 2x a tolerância)
    if (discTick) {
        el := A_TickCount - discTick
        if ((el > tol && !pendingJoin) || el > tol * 2) {
            discTick := 0, pendingJoin := 0
            RecoverRoblox(TT("r_no_rejoin"))
            return
        }
    }

    ; 4) janela "Não respondendo" por mais de 30s
    if (h && DllCall("IsHungAppWindow", "Ptr", h)) {
        if !hungSince
            hungSince := A_TickCount
        else if (A_TickCount - hungSince > 30000) {
            hungSince := 0
            RecoverRoblox(TT("r_hung"))
        }
    } else {
        hungSince := 0
    }
}

Check() {
    global running, lastLaunch, edWait, wasOpen, downTick, discTick
    if !running
        return
    open := IsRobloxOpen()

    if open {
        if (!wasOpen && downTick) {
            SendEvent("back", ["**" TT("d_away") ":** " DurStr(A_TickCount - downTick)])
            Log(TT("log_back", DurStr(A_TickCount - downTick)))
            downTick := 0
        }
        wasOpen := true
    } else if wasOpen {
        wasOpen := false
        downTick := A_TickCount
        MarkDisconnect()
        Log(TT("log_down"))
        SendEvent("down")
    }

    if (lastLaunch && (A_TickCount - lastLaunch) < Integer(edWait.Value || 90) * 1000) {
        SetState("wait", TT("st_loading"), TT("st_loading_sub"))
        return
    }
    if open {
        if discTick
            SetState("warn", "Roblox ON", TT("st_on_warn_sub"))
        else
            SetState("on", "Roblox ON", TT("st_on_sub"))
    } else {
        SetState("off", "Roblox OFF", TT("st_off_sub"))
        LaunchGame()
    }
}

Toggle(*) {
    global running, btnStart, mBtn, edInterval, edLink, wasOpen, downTick, monStart, gm, licensed, chkMulti, ACCS, multiActive
    if (!running && KaEnabled() && !licensed) {
        ShowKeyScreen(TT("activate_to_use"))
        return
    }
    if !running {
        if (Trim(edLink.Value) = "") {
            Log(TT("paste_link_first"))
            SetState("warn", TT("st_nolink"), TT("st_nolink_sub"))
            if WinExist("ahk_id " gm.Hwnd) && DllCall("IsWindowVisible", "Ptr", gm.Hwnd)
                SetCompact(false)
            ShowPage("Jogo")
            return
        }
        iv := Integer(edInterval.Value || 15)
        if (iv < 5)
            iv := 5
        if chkMulti.Value {
            if !ACCS.Length {
                Log(TT("acc_need"))
                SetState("warn", TT("st_nolink"), TT("acc_need"))
                ShowPage("Contas")
                return
            }
            if IsRobloxOpen() {
                Log(TT("multi_close"))
                SetState("warn", "Roblox", TT("multi_close"))
                return
            }
        }
        SaveConfig()
        wasOpen := IsRobloxOpen()
        downTick := 0
        monStart := A_TickCount
        running := true
        SendEvent("start", ["**" TT("d_interval") ":** " iv "s"], false, "", SessionFields(), true)
        for b in [btnStart, mBtn] {
            b.Text := TT("btn_stop")
            SetBtnStyle(b, "sec")
        }
        SetState("wait", TT("st_monitoring"), TT("st_monitoring_sub"))
        Log(TT("log_mon_start", iv))
        if chkMulti.Value {
            multiActive := true
            MultiLock()
            SetTimer(MultiCheck, iv * 1000)
            MultiCheck()
        } else {
            SetTimer(Check, iv * 1000)
            Check()
        }
        ApplyReportTimer()
    } else {
        running := false
        SetTimer(Check, 0)
        if multiActive {
            SetTimer(MultiCheck, 0)
            MultiUnlock()
            multiActive := false
        }
        ApplyReportTimer()
        for b in [btnStart, mBtn] {
            b.Text := TT("btn_start")
            SetBtnStyle(b, "primary")
        }
        SetState("idle", TT("idle"), TT("click_start"))
        Log(TT("log_mon_stop"))
        SendEvent("stop", [], false, "", SessionFields(), true)
    }
}

; ==========================================================
;  Biblioteca OCR (Windows.Media.Ocr) - Descolada, licença MIT
;  https://github.com/Descolada/OCR
; ==========================================================

/**
 * OCR library: a wrapper for the the UWP Windows.Media.Ocr library.
 * Based on the UWP OCR function for AHK v1 by malcev.
 * 
 * Ways of initiating OCR:
 * OCR(RandomAccessStreamOrSoftwareBitmap, Options?)
 * OCR.FromDesktop(Options?)
 * OCR.FromMonitor(Monitor?, Options?)
 * OCR.FromRect(X, Y, W, H, Options?)
 * OCR.FromWindow(WinTitle:="", Options?, WinText:="", ExcludeTitle:="", ExcludeText:="")
 *      Note: the result object coordinates will be in CoordMode "Pixel"
 * OCR.FromFile(FileName, Options?)
 * OCR.FromBitmap(bitmap, Options?, hDC?)
 * OCR.FromPDF(FileName, Options?, Start:=1, End?, Password:="") => returns an array of results for each PDF page
 * OCR.FromPDFPage(FileName, page, Options?)
 *   Helper functions for PDF OCR:
 *      OCR.GetPdfPageCount(FileName, Password:="")
 *      OCR.GetPdfPageProperties(FileName, Page, Password:="")
 * 
 * Options can be an object containing none or all of these elements:
 * {
 *      lang: OCR language. Default is first from available languages. This can also be a function which evaluates to a language string.
 *      scale: a Float scale factor to zoom the image in or out, which might improve detection. 
 *             The resulting coordinates will be adjusted to scale. Default is 1.
 *      grayscale: Boolean 0 | 1 whether to convert the image to black-and-white. Default is 0.
 *      monochrome: 0-255, converts all pixels with luminosity less than the threshold to black, otherwise to white. Default is 0 (no conversion).
 *      invertcolors: Boolean 0 | 1, whether to invert the colors of the image. Default is 0.
 *      rotate: 0 | 90 | 180 | 270, can be used to rotate the image clock-wise by degrees. Default is 0.
 *      flip: 0 | "x" | "y", can be used to flip the image on the x- or y-axis. Default is 0.
 *      x, y, w, h: can be used to crop the image. This is applied before scaling. Default is no cropping.
 *      decoder: gif | ico | jpeg | jpegxr | png | tiff | bmp. Optional bitmap codec name to decode RandomAccessStream. Default is automatic detection. 
 * }
 * 
 * Note: Options also accepts any optional parameters after it like named parameters.
 * Eg. OCR.FromMonitor({lang:"en-us", monitor:2})
 * 
 * Additional methods:
 * OCR.GetAvailableLanguages()
 * OCR.LoadLanguage(lang:="FirstFromAvailableLanguages")
 * OCR.WaitText(needle, timeout:=-1, func?, casesense:=False, comparefunc?)
 *      Calls a func (the provided OCR method) until a string is found
 * OCR.WordsBoundingRect(words*)
 *      Returns the bounding rectangle for multiple words
 * OCR.ClearAllHighlights()
 *      Removes all highlights created by Result.Highlight
 * OCR.Cluster(objs, eps_x:=-1, eps_y:=-1, minPts:=1, compareFunc?, &noise?)
 *      Clusters objects (by default based on distance from eachother). Can be used to create more
 *      accurate "Line" results.
 * OCR.SortArray(arr, optionsOrCallback:="N", key?)
 *      Sorts an array in-place, optionally by object keys or using a callback function.
 * OCR.ReverseArray(arr)
 *      Reverses an array in-place.
 * OCR.UniqueArray(arr)
 *      Returns an array with unique values.
 * OCR.FlattenArray(arr)
 *      Returns a one-dimensional array from a multi-dimensional array
 * 
 * Properties:
 * OCR.MaxImageDimension
 * MinImageDimension is not documented, but appears to be 40 pixels (source: user FanaticGuru in AutoHotkey forums)
 * OCR.PerformanceMode
 *      Increases speed of OCR acquisition by about 20-50ms if set to 1, but also increases CPU usage. Default is 0.
 * OCR.DisplayImage
 *      If set to True then the captured image is displayed on the screen before proceeding to OCR-ing the image.
 * 
 * OCR returns an OCR.Result object:
 * Result.Text         => All recognized text
 * Result.TextAngle    => Clockwise rotation of the recognized text 
 * Result.Lines        => Array of all OCR.Line objects
 * Result.Words        => Array of all OCR.Word objects
 * Result.ImageWidth   => Used image width
 * Result.ImageHeight  => Used image height
 * 
 * Result.FindString(Needle, Options?)
 *      Finds a string in the result. Possible options (see descriptions at the function definition): 
 *      {CaseSense: False, IgnoreLinebreaks: False, AllowOverlap: false, i: 1, x, y, w, h, SearchFunc}
 * Result.FindStrings(Needle, Options?)
 *      Finds all strings in the result. 
 * Result.Filter(callback)
 *      Returns a filtered result object that contains only words that satisfy the callback function
 * Result.Crop(x1, y1, x2, y2)
 *      Crops the result object to contain only results from an area defined by points (x1,y1) and (x2,y2). 
 * 
 * OCR.Line object:
 * Line.Text         => Recognized text of the line
 * Line.Words        => Array of Word objects for the Line
 * Line.x,y,w,h      => Size and location of the Line. 
 * 
 * OCR.Word object:
 * Word.Text         => Recognized text of the word
 * Word.x,y,w,h      => Size and location of the Word. 
 * Word.BoundingRect => Bounding rectangle of the Word in format {x,y,w,h}. 
 * 
 * OCR.Result, OCR.Line, and OCR.Word also all have some common methods:
 * 
 * Result.Click(WhichButton?, ClickCount?, DownOrUp?)
 *      Clicks an object (Word, FindString result etc)
 * Result.ControlClick(WinTitle?, WinText?, WhichButton?, ClickCount?, Options?, ExcludeTitle?, ExcludeText?)
 *      ControlClicks an object (Word, FindString result etc)
 * Result.Highlight(showTime?, color:="Red", d:=2)
 *      Highlights a Word, Line, or object with {x,y,w,h} properties on the screen (default: 2 seconds), or removes the highlighting
 * 
 * Additional notes:
 * Languages are recognized in BCP-47 language tags. Eg. OCR.FromFile("myfile.bmp", {lang: "en-AU"})
 * Languages can be installed for example with PowerShell (run as admin): Install-Language <language-tag>
 *      or from Language settings in Settings.
 * Not all language packs support OCR though. A list of supported language can be gotten from 
 * Powershell (run as admin) with the following command: Get-WindowsCapability -Online | Where-Object { $_.Name -Like 'Language.OCR*' } 
 */
class OCR {
    static Version => "2.0.0"
    static IID_IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
         , IID_IPicture            := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"
         , IID_IAsyncInfo          := "{00000036-0000-0000-C000-000000000046}"
         , IID_IAsyncOperation_OcrResult        := "{c7d7118e-ae36-59c0-ac76-7badee711c8b}"
         , IID_IAsyncOperation_SoftwareBitmap   := "{c4a10980-714b-5501-8da2-dbdacce70f73}"
         , IID_IAsyncOperation_BitmapDecoder    := "{aa94d8e9-caef-53f6-823d-91b6e8340510}"
         , IID_IAsyncOperationCompletedHandler_OcrResult        := "{989c1371-444a-5e7e-b197-9eaaf9d2829a}"
         , IID_IAsyncOperationCompletedHandler_SoftwareBitmap   := "{b699b653-33ed-5e2d-a75f-02bf90e32619}"
         , IID_IAsyncOperationCompletedHandler_BitmapDecoder    := "{bb6514f2-3cfb-566f-82bc-60aabd302d53}"
         , IID_IPdfDocumentStatics := "{433A0B5F-C007-4788-90F2-08143D922599}"
         , Vtbl_GetDecoder := {bmp:6, jpg:7, jpeg:7, png:8, tiff:9, gif:10, jpegxr:11, ico:12}
         , PerformanceMode := 0
         , DisplayImage := 0

    class IBase {
        __OCR := OCR
        __New(ptr?) {
            if IsSet(ptr) {
                if !ptr
                    throw ValueError('Invalid IUnknown interface pointer', -2, this.__Class)
                else if IsObject(ptr) {
                    if ptr.HasProp("Relative")
                        this.DefineProp("Relative", {value: ptr.Relative})
                    ptr := 0
                }
            }
            this.DefineProp("ptr", {Value:ptr ?? 0})
        }
        __Delete() => this.ptr ? ObjRelease(this.ptr) : 0
    }

    static __New() {
        this.LanguageFactory := this.CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}")
        this.SoftwareBitmapFactory := this.CreateClass("Windows.Graphics.Imaging.SoftwareBitmap", "{c99feb69-2d62-4d47-a6b3-4fdb6a07fdf8}")
        this.BitmapTransform := this.CreateClass("Windows.Graphics.Imaging.BitmapTransform")
        this.BitmapDecoderStatics := this.CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}")
        this.BitmapEncoderStatics := this.CreateClass("Windows.Graphics.Imaging.BitmapEncoder", IBitmapDecoderStatics := "{a74356a7-a4e4-4eb9-8e40-564de7e1ccb2}")
        this.SoftwareBitmapStatics := this.CreateClass("Windows.Graphics.Imaging.SoftwareBitmap", ISoftwareBitmapStatics := "{df0385db-672f-4a9d-806e-c2442f343e86}")
        this.OcrEngineStatics := this.CreateClass("Windows.Media.Ocr.OcrEngine", IOcrEngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}")
        ComCall(6, this.OcrEngineStatics, "uint*", &MaxImageDimension:=0)   ; MaxImageDimension
        this.MaxImageDimension := MaxImageDimension
        DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", &compositionEnabled:=0)
        this.CAPTUREBLT := compositionEnabled ? 0 : 0x40000000
        /*  // Based on code by AHK forums user Xtra
            unsigned int Convert_GrayScale(unsigned int bitmap[], unsigned int w, unsigned int h, unsigned int Stride)
            {
                unsigned int a, r, g, b, gray, ARGB;
                unsigned int x, y, offset = Stride/4;
                for (y = 0; y < h * offset; y += offset) {
                    for (x = 0; x < w; ++x) {
                        ARGB = bitmap[x+y];
                        a = ARGB & 0xFF000000;
                        r = (ARGB & 0x00FF0000) >> 16;
                        g = (ARGB & 0x0000FF00) >> 8;
                        b = (ARGB & 0x000000FF);
                        gray = ((300 * r) + (590 * g) + (110 * b)) >> 10;
                        bitmap[x+y] = (gray << 16) | (gray << 8) | gray | a;
                    }
                }
                return 0;
            }
         */
        this.GrayScaleMCode := this.MCode((A_PtrSize = 4) 
        ? "2,x86:VVdWU4PsCIt8JCiLdCQki0QkIMHvAg+v94k0JIX2dH+FwHR7jTS9AAAAAIl0JASLdCQcjRyGMfaNtCYAAAAAkItEJByNDLCNtCYAAAAAZpCLEYPBBInQD7buwegQae1OAgAAD7bAacAsAQAAAegPtuqB4gAAAP9r7W4B6MHoConFCcLB4AjB5RAJ6gnQiUH8Odl1vAH+A1wkBDs0JHKhg8QIMcBbXl9dww==" 
        : "2,x64:V1ZTQcHpAkSJxkiJy0GJ00EPr/GF9nRnRTHAhdJ0YJBEicEPH0QAAInIg8EBTI0Ug0GLEonQD7b+wegQaf9OAgAAD7bAacAsAQAAAfgPtvqB4gAAAP9r/24B+MHoConHCcLB4AjB5xAJ+gnCQYkSRDnZdbRFAchFActBOfByoTHAW15fww==")
        /*
            unsigned int Invert_Colors(unsigned int bitmap[], unsigned int w, unsigned int h, unsigned int Stride)
            {
                unsigned int a, r, g, b, gray, ARGB;
                unsigned int x, y, offset = Stride/4;
                for (y = 0; y < h * offset; y += offset) {
                    for (x = 0; x < w; ++x) {
                        ARGB = bitmap[x+y];
                        a = ARGB & 0xFF000000;
                        r = (ARGB & 0x00FF0000) >> 16;
                        g = (ARGB & 0x0000FF00) >> 8;
                        b = (ARGB & 0x000000FF);
                        bitmap[x+y] = ((255-r) << 16) | ((255-g) << 8) | (255-b) | a;
                    }
                }
                return 0;
            }
        */
        this.InvertColorsMCode := this.MCode((A_PtrSize = 4)
        ? "2,x86:VVdWU4PsCItsJCiLfCQki0QkIMHtAg+v/Yk8JIX/dGeFwHRjjTytAAAAAIl8JASLfCQcjTSHMf+NtCYAAAAAkItEJByNDLiNtCYAAAAAZpCLEYPBBInQidOB4v8AAP/30PfTgPL/JQAA/wCB4wD/AAAJ2AnQiUH8OfF11AHvA3QkBDs8JHK5g8QIMcBbXl9dww=="
        : "2,x64:V1ZTQcHpAkSJx0iJzonTQQ+v+YX/dFNFMcCF0nRMZpBEicEPH0QAAInIg8EBTI0chkGLE4nQQYnSgeL/AAD/99BB99KA8v8lAAD/AEGB4gD/AABECdAJ0EGJAznLdclFAchEActBOfhytjHAW15fww==")
        /*
            unsigned int Convert_Monochrome(unsigned int bitmap[], unsigned int w, unsigned int h, unsigned int Stride, unsigned int threshold)
            {
                unsigned int a, r, g, b, ARGB;
                unsigned int x, y, offset = Stride / 4;
                for (y = 0; y < h * offset; y += offset) {
                    for (x = 0; x < w; ++x) {
                        ARGB = bitmap[x + y];
                        a = ARGB & 0xFF000000;
                        r = (ARGB & 0x00FF0000) >> 16;
                        g = (ARGB & 0x0000FF00) >> 8;
                        b = (ARGB & 0x000000FF);
                        unsigned int luminance = (77 * r + 150 * g + 29 * b) >> 8;
                        bitmap[x + y] = (luminance > threshold) ? 0xFFFFFFFF : 0xFF000000;
                    }
                }
                return 0;
            }
        */
        this.MonochromeMCode := this.MCode((A_PtrSize = 4)
        ? "2,x86:VVdWU4PsDIt0JCyLTCQoi0QkJIt8JDDB7gIPr86JNCSJTCQEhcl0aYXAdGXB5gIx7Yl0JAiLdCQgjTSGjXQmAItEJCCNDKiNtCYAAAAAZpCLEYnTD7bGD7bSwesQacCWAAAAD7bba9Ida9tNAdgB0MHoCDn4dinHAf////+DwQQ58XXMAywkA3QkCDlsJAR3r4PEDDHAW15fXcONdCYAkMcBAAAA/4PBBDnxdaMDLCQDdCQIOWwkBHeG69U="
        : "2,x64:VVdWU4t0JEhBwekCRInHSInLQYnTQQ+v+YX/dFyF0nRYRTHADx9AAESJwQ8fRAAAichMjRSDQYsSidUPtsYPttLB7RBpwJYAAABAD7bta9Ida+1NAegB0MHoCDnwdiGDwQFBxwL/////QTnLdcJFAchFActEOcd3rzHAW15fXcODwQFBxwIAAAD/RDnZdaFFAchFActEOcd3juvd")
    }

    /**
     * Returns an OCR results object for an IRandomAccessStream.
     * Images of other types should be first converted to this format (eg from file, from bitmap).
     * @param RandomAccessStreamOrSoftwareBitmap Pointer or an object containing a ptr to a RandomAccessStream or SoftwareBitmap
     * @param {String} lang OCR language. Default is first from available languages.
     * @param {Integer|Object} transform Either a scale factor number, or an object {scale:Float, grayscale:Boolean, invertcolors:Boolean, monochrome:0-255, rotate: 0 | 90 | 180 | 270, flip: 0 | "x" | "y"}
     * @param {String} decoder Optional bitmap codec name to decode RandomAccessStream. Default is automatic detection.
     *  Possible values are gif, ico, jpeg, jpegxr, png, tiff, bmp.
     * @returns {OCR.Result} 
     */
    static Call(RandomAccessStreamOrSoftwareBitmap, Options:=0) {
        local SoftwareBitmap := 0, RandomAccessStream := 0, lang:="FirstFromAvailableLanguages", width, height, x := 0, y := 0, w := 0, h := 0, scale, grayscale, invertcolors, monochrome, OcrResult := this.Result(), Result, transform := 0, decoder := 0
        this.__ExtractTransformParameters(Options, &transform)
        scale := transform.scale, grayscale := transform.grayscale, invertcolors := transform.invertcolors, monochrome := transform.monochrome, rotate := transform.rotate, flip := transform.flip
        this.__ExtractNamedParameters(Options, "x", &x, "y", &y, "w", &w, "h", &h, "language", &lang, "lang", &lang, "decoder", &decoder)
        this.LoadLanguage(lang)
        local customRegion := x || y || w || h

        try SoftwareBitmap := ComObjQuery(RandomAccessStreamOrSoftwareBitmap, "{689e0708-7eef-483f-963f-da938818e073}") ; ISoftwareBitmap
        if SoftwareBitmap {
            ComCall(8, SoftwareBitmap, "uint*", &width:=0)   ; get_PixelWidth
            ComCall(9, SoftwareBitmap, "uint*", &height:=0)   ; get_PixelHeight
            this.ImageWidth := width, this.ImageHeight := height
            if (Floor(width*scale) > this.MaxImageDimension) or (Floor(height*scale) > this.MaxImageDimension)
               throw ValueError("Image is too big - " width "x" height ".`nIt should be maximum - " this.MaxImageDimension " pixels (with scale applied)")
            if scale != 1 || customRegion || rotate || flip
                SoftwareBitmap := this.TransformSoftwareBitmap(SoftwareBitmap, &width, &height, scale, rotate, flip, x?, y?, w?, h?)
            goto SoftwareBitmapCommon
        }
        RandomAccessStream := RandomAccessStreamOrSoftwareBitmap

        if decoder {
            ComCall(this.Vtbl_GetDecoder.%decoder%, this.BitmapDecoderStatics, "ptr", DecoderGUID:=Buffer(16))
            ComCall(15, this.BitmapDecoderStatics, "ptr", DecoderGUID, "ptr", RandomAccessStream, "ptr*", BitmapDecoder:=ComValue(13,0))   ; CreateAsync
        } else
            ComCall(14, this.BitmapDecoderStatics, "ptr", RandomAccessStream, "ptr*", BitmapDecoder:=ComValue(13,0))   ; CreateAsync
            this.WaitForAsync(&BitmapDecoder)

        BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
        ComCall(12, BitmapFrame, "uint*", &width:=0)   ; get_PixelWidth
        ComCall(13, BitmapFrame, "uint*", &height:=0)   ; get_PixelHeight
        if (width > this.MaxImageDimension) or (height > this.MaxImageDimension)
           throw ValueError("Image is too big - " width "x" height ".`nIt should be maximum - " this.MaxImageDimension " pixels")

        BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
        OcrResult.ImageWidth := width, OcrResult.ImageHeight := height
        if !(customRegion || rotate || flip) && (width < 40 || height < 40 || scale != 1) {
            scale := scale = 1 ? 40.0 / Min(width, height) : scale
            ComCall(7, this.BitmapTransform, "int", width := Floor(width*scale)) ; put_ScaledWidth
            ComCall(9, this.BitmapTransform, "int", height := Floor(height*scale)) ; put_ScaledHeight
            ComCall(8, BitmapFrame, "uint*", &BitmapPixelFormat:=0) ; get_BitmapPixelFormat
            ComCall(9, BitmapFrame, "uint*", &BitmapAlphaMode:=0) ; get_BitmapAlphaMode
            ComCall(8, BitmapFrameWithSoftwareBitmap, "uint", BitmapPixelFormat, "uint", BitmapAlphaMode, "ptr", this.BitmapTransform, "uint", IgnoreExifOrientation := 0, "uint", DoNotColorManage := 0, "ptr*", SoftwareBitmap:=this.IBase()) ; GetSoftwareBitmapAsync
        } else {
            ComCall(6, BitmapFrameWithSoftwareBitmap, "ptr*", SoftwareBitmap:=this.IBase())   ; GetSoftwareBitmapAsync
        }
        this.WaitForAsync(&SoftwareBitmap)
        if customRegion || rotate || flip || scale != 1
            SoftwareBitmap := this.TransformSoftwareBitmap(SoftwareBitmap, &width, &height, scale, rotate, flip, x?, y?, w?, h?)

        SoftwareBitmapCommon:

        if (grayscale || invertcolors || monochrome || this.DisplayImage) {
            ComCall(15, SoftwareBitmap, "int", 2, "ptr*", &BitmapBuffer := 0) ; LockBuffer
            MemoryBuffer := ComObjQuery(BitmapBuffer, "{fbc4dd2a-245b-11e4-af98-689423260cf8}")
            ComCall(6, MemoryBuffer, "ptr*", &MemoryBufferReference := 0) ; CreateReference
            BufferByteAccess := ComObjQuery(MemoryBufferReference, "{5b0d3235-4dba-4d44-865e-8f1d0e4fd04d}")
            ComCall(3, BufferByteAccess, "ptr*", &SoftwareBitmapByteBuffer:=0, "uint*", &BufferSize:=0) ; GetBuffer
           
            if grayscale
                DllCall(this.GrayScaleMCode, "ptr", SoftwareBitmapByteBuffer, "uint", width, "uint", height, "uint", (width*4+3) // 4 * 4, "cdecl uint")

            if monochrome
                DllCall(this.MonochromeMCode, "ptr", SoftwareBitmapByteBuffer, "uint", width, "uint", height, "uint", (width*4+3) // 4 * 4, "uint", monochrome, "cdecl uint")
            
            if invertcolors
                DllCall(this.InvertColorsMCode, "ptr", SoftwareBitmapByteBuffer, "uint", width, "uint", height, "uint", (width*4+3) // 4 * 4, "cdecl uint")
    
            if this.DisplayImage {
                local hdc := DllCall("GetDC", "ptr", 0, "ptr"), bi := Buffer(40, 0), hbm
                NumPut("uint", 40, "int", width, "int", -height, "ushort", 1, "ushort", 32, bi)
                hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", bi, "uint", 0, "ptr*", &ppvBits:=0, "ptr", 0, "uint", 0, "ptr")
                DllCall("ntdll\memcpy", "ptr", ppvBits, "ptr", SoftwareBitmapByteBuffer, "uint", BufferSize, "cdecl")
                DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc, "Int")
                this.DisplayHBitmap(hbm)
            }
            
            BufferByteAccess := "", ObjRelease(MemoryBufferReference), MemoryBuffer := "", ObjRelease(BitmapBuffer) ; Release in correct order
        }

        ComCall(6, this.OcrEngine, "ptr", SoftwareBitmap, "ptr*", Result:=ComValue(13,0))   ; RecognizeAsync
        this.WaitForAsync(&Result)
        OcrResult.Ptr := Result.Ptr, ObjAddRef(OcrResult.ptr)

        ; Cleanup
        if RandomAccessStream is this.IBase
            this.CloseIClosable(RandomAccessStream)
        if SoftwareBitmap is this.IBase
            this.CloseIClosable(SoftwareBitmap)

        if scale != 1 || x != 0 || y != 0
            this.NormalizeCoordinates(OcrResult, scale, x, y)

        return OcrResult
    }

    static ClearAllHighlights() => this.Result.Prototype.Highlight("clearall")

    class Result extends OCR.Common {
        ; Gets the recognized text.
        Text {
            get {
                ComCall(8, this, "ptr*", &hAllText:=0)   ; get_Text
                buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hAllText, "uint*", &length:=0, "ptr")
                this.DefineProp("Text", {Value:StrGet(buf, "UTF-16")})
                this.__OCR.DeleteHString(hAllText)
                return this.Text
            }
        }

        ; Gets the clockwise rotation of the recognized text, in degrees, around the center of the image.
        TextAngle {
            get => (ComCall(7, this, "double*", &value:=0), value)
        }

        ; Returns all Line objects for the result.
        Lines {
            get {
                ComCall(6, this, "ptr*", LinesList:=ComValue(13, 0)) ; get_Lines
                ComCall(7, LinesList, "int*", &count:=0) ; count
                lines := []
                loop count {
                    ComCall(6, LinesList, "int", A_Index-1, "ptr*", Line:=this.__OCR.Line(this)) 
                    lines.Push(Line)
                }
                this.DefineProp("Lines", {Value:lines})
                return lines
            }
        }

        ; Returns all Word objects for the result. Equivalent to looping over all the Lines and getting the Words.
        Words {
            get {
                local words := [], line, word
                for line in this.Lines
                    for word in line.Words
                        words.Push(word)
                this.DefineProp("Words", {Value:words})
                return words
            }
        }

        BoundingRect {
            get => this.DefineProp("BoundingRect", {Value:this.__OCR.WordsBoundingRect(this.Words*)}).BoundingRect
        }

        /**
         * Finds a string in the search results, and returns a new Result object.
         * If the match is partial then the result will contain the whole word: in "hello world" searching "wo" will return "world".
         * To force a full word search instead of a partial search, use IgnoreLinebreaks:True 
         *  and add a space to the beginning and end: " hello "
         * To search multi-line matches, set IgnoreLinebreaks:True and use a linebreak in the needle: "hello`nworld"
         * @param Needle The string to find. 
         * @param Options Extra search options object, which can contain the following properties:
         *  CaseSense: False (this is ignored if a custom SearchFunc is used)
         *  IgnoreLinebreaks: False (if this is True, then linebreaks are converted to whitespaces, otherwise remain `n)
         *  AllowOverlap: False (if True then the needle can overlap itself)
         *  i: 1 (which occurrence of the needle to find)
         *  x, y, w, h: defines the search area inside the result object
         *  SearchFunc: default is InStr, but if a custom function is provided then it needs to return
         *      the needle location in the haystack, and accept arguments (Haystack, Needle, &FoundMatch)
         *      This can used for example to perform a RegEx search by providing RegExMatch
         * @returns {Object} 
         */
        FindString(Needle, Options := "") => this.__FindString(Needle, Options, 0)

        /**
         * Finds all strings matching the needle in the search results. Returns an array of Result objects.
         * @param Needle The string to find. 
         * @param Options See Result.FindString. {CaseSense: False, IgnoreLinebreaks: False, AllowOverlap: false, i: 1, x, y, w, h, SearchFunc}
         *  If i is specified then the result object will contains matches starting from i.
         * @returns {Array} 
         */
        FindStrings(Needle, Options := "") => this.__FindString(Needle, Options, true)

        __FindString(Needle, Options, All) {
            local CaseSense := false, IgnoreLinebreaks := false, AllowOverlap := false, i := 1, SearchFunc, x, y, w, h
            local currentHaystack, fullHaystackLinebreaks := "`n", offset := 0, line, counter := 0, x1, y1, x2, y2, result, results := [], word

            if !(Needle is String)
                throw TypeError("Needle is required to be a string, not type " Type(Needle), -1)
            if Trim(Needle, " `t`n`r") == ""
                throw ValueError("Needle cannot be an empty string", -1)

            this.__OCR.__ExtractNamedParameters(Options, "CaseSense", &CaseSense, "IgnoreLinebreaks", &IgnoreLinebreaks, "AllowOverlap", &AllowOverlap, "i", &i, "SearchFunc", &SearchFunc, "x", &x, "y", &y, "w", &w, "h", &h)

            if !IsSet(SearchFunc)
                SearchFunc := (haystack, needle, &foundstr) => (pos := InStr(haystack, needle, casesense), foundstr := SubStr(haystack, pos, StrLen(needle)), pos)

            if (IsSet(x) || IsSet(y) || IsSet(w) || IsSet(h)) {
                x1 := x ?? -100000, y1 := y ?? -100000, x2 := IsSet(w) ? x + w : 100000, y2 := IsSet(h) ? y + h : 100000 
            }

            tokenizedHaystack := [IgnoreLinebreaks ? " " : "`n"]
            for Line in this.Lines {
                fullHaystackLinebreaks .= line.Text "`n"
                for Word in Line.Words
                    tokenizedHaystack.Push(Word, " ")
                tokenizedHaystack.Pop()
                tokenizedHaystack.Push(IgnoreLinebreaks ? " " : "`n")
            }

            fullHaystackNoLinebreaks := StrReplace(fullHaystackLinebreaks, "`n", " ") ; Make sure the words are in the same order as the tokenized version
            fullHaystack := IgnoreLinebreaks ? fullHaystackNoLinebreaks : fullHaystackLinebreaks

            Needle := RegExReplace(StrReplace(Needle, "`t", " "), " +", " ")

            fullFirst := SubStr(Needle, 1, 1) ~= "[ \n]", fullLast := SubStr(Needle, -1, 1) ~= "[ \n]"

            currentHaystack := fullHaystack
            Loop {
                if !(loc := SearchFunc(currentHaystack, Needle, &foundNeedle))
                    break

                if IsObject(foundNeedle)
                    foundNeedle := foundNeedle[]

                foundLen := AllowOverlap ? 1 : StrLen(foundNeedle)
                currentHaystack := SubStr(currentHaystack, loc + foundLen) ; Remove the match from the haystack, allowing overlap
                offset += loc + foundLen - 1

                if ++counter < i
                    continue

                tokenizedNeedle := []
                ; Tokenize the needle
                for wsNeedle in wsSplit := StrSplit(foundNeedle, " ") {
                    for lbNeedle in lbSplit := StrSplit(wsNeedle, "`n") {
                        tokenizedNeedle.Push(lbNeedle, "`n")
                    }
                    if lbSplit.Length
                        tokenizedNeedle.Pop()
                    tokenizedNeedle.Push(" ")
                }
                tokenizedNeedle.Pop()
                
                preceding := SubStr(fullHaystackNoLinebreaks, 1, offset - foundLen)
                ; Find first Word location
                StrReplace(preceding, " ",,, &startingWord:=0)
                startingWord := startingWord*2 + fullFirst - 1 ; Substracted 1 to allow subsequent loop to just add A_Index

                foundNeedle := "", foundWords := [], foundLines := [], line := this.__OCR.Line(this), line.DefineProp("Words", {value:[]}), line.DefineProp("Text", {value:""})
                Loop tokenizedNeedle.Length {
                    word := tokenizedHaystack[startingWord + A_Index]
                    if (word == "`n") {
                        foundNeedle .= line.Text
                        line.Text := RTrim(line.Text), foundLines.Push(line)
                        line := this.__OCR.Line(this), line.DefineProp("Words", {value:[]}), line.DefineProp("Text", {value:""})
                    }
                    if !IsObject(word)
                        continue
                    If IsSet(x1) && (word.x < x1 || word.y < y1 || word.x+word.w > x2 || word.y+word.h > y2) {
                        counter--
                        continue 2
                    }
                    line.Words.Push(word), line.Text .= word.Text " "
                    foundWords.Push(word)
                }
                if line.Text {
                    foundNeedle .= line.Text
                    line.Text := RTrim(line.Text), foundLines.Push(line)
                }

                result := this.Clone(), ObjAddRef(this.ptr)
                result.DefineProp("BoundingRect", {value: this.__OCR.WordsBoundingRect(foundWords*)})
                result.DefineProp("Lines", {value: foundLines})
                result.DefineProp("Words", {value: foundWords})
                result.DefineProp("Text", {value: foundNeedle})
                if All {
                    results.Push(result)
                } else
                    return result
            }
            if All
                return results

            throw TargetError('The target string "' Needle '" was not found', -1)
        }
    
        /**
         * Filters out all the words that do not satisfy the callback function and returns a new OCR.Result object
         * @param {Object} callback The callback function that accepts a OCR.Word object.
         * If the callback returns 0 then the word is filtered out (rejected), otherwise is kept.
         * @returns {OCR.Result}
         */
        Filter(callback) {
            if !HasMethod(callback)
                throw ValueError("Filter callback must be a function", -1)
            local result := this.Clone(), line, croppedLines := [], croppedText := "", croppedWords := [], lineText := "", word
            ObjAddRef(result.ptr)
            for line in result.Lines {
                croppedWords := [], lineText := ""
                for word in line.Words {
                    if callback(word)
                        croppedWords.Push(word), lineText .= word.Text " "
                }
                if croppedWords.Length {
                    line := this.__OCR.Line()
                    line.DefineProp("Text", {value:Trim(lineText)})
                    line.DefineProp("Words", {value:croppedWords})
                    croppedLines.Push(line)
                    croppedText .= lineText
                }
            }
            result.DefineProp("Lines", {Value:croppedLines})
            result.DefineProp("Text", {Value:Trim(croppedText)})
            result.DefineProp("Words", this.__OCR.Result.Prototype.GetOwnPropDesc("Words"))
            return result
        }
    
        /**
         * Crops the result object to contain only results from an area defined by points (x1,y1) and (x2,y2).
         * Note that these coordinates are relative to the result object, not to the screen.
         * @param {Integer} x1 x coordinate of the top left corner of the search area
         * @param {Integer} y1 y coordinate of the top left corner of the search area
         * @param {Integer} x2 x coordinate of the bottom right corner of the search area
         * @param {Integer} y2 y coordinate of the bottom right corner of the search area
         * @returns {OCR.Result}
         */
        Crop(x1:=-100000, y1:=-100000, x2:=100000, y2:=100000) => this.Filter((word) => word.x >= x1 && word.y >= y1 && (word.x+word.w) <= x2 && (word.y+word.h) <= y2)
    }
    class Line extends OCR.Common {
        ; Gets the recognized text for the line.
        Text {
            get {
                ComCall(7, this, "ptr*", &hText:=0)   ; get_Text
                buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
                text := StrGet(buf, "UTF-16")
                this.__OCR.DeleteHString(hText)
                this.DefineProp("Text", {Value:text})
                return text
            }
        }

        ; Gets the Word objects for the line
        Words {
            get {
                ComCall(6, this, "ptr*", WordsList:=ComValue(13, 0))   ; get_Words
                ComCall(7, WordsList, "int*", &WordsCount:=0)   ; Words count
                words := []
                loop WordsCount {
                   ComCall(6, WordsList, "int", A_Index-1, "ptr*", Word:=this.__OCR.Word(this))
                   words.Push(Word)
                }
                this.DefineProp("Words", {Value:words})
                return words
            }
        }

        BoundingRect {
            get => this.DefineProp("BoundingRect", {Value:this.__OCR.WordsBoundingRect(this.Words*)}).BoundingRect
        }
    }

    class Word extends OCR.Common {
        ; Gets the recognized text for the word
        Text {
            get {
                ComCall(7, this, "ptr*", &hText:=0)   ; get_Text
                buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
                text := StrGet(buf, "UTF-16")
                this.__OCR.DeleteHString(hText)
                this.DefineProp("Text", {Value:text})
                return text
            }
        }

        /**
         * Gets the bounding rectangle of the text in {x,y,w,h} format. 
         * The bounding rectangles coordinate system will be dependant on the image capture method.
         * For example, if the image was captured as a rectangle from the screen, then the coordinates
         * will be relative to the left top corner of the screen.
         */
        BoundingRect {
            get {
                ComCall(6, this, "ptr", RECT := Buffer(16, 0))   ; get_BoundingRect
                this.DefineProp("x", {Value:Integer(NumGet(RECT, 0, "float"))})
                , this.DefineProp("y", {Value:Integer(NumGet(RECT, 4, "float"))})
                , this.DefineProp("w", {Value:Integer(NumGet(RECT, 8, "float"))})
                , this.DefineProp("h", {Value:Integer(NumGet(RECT, 12, "float"))})
                return this.DefineProp("BoundingRect", {Value:{x:this.x, y:this.y, w:this.w, h:this.h}}).BoundingRect
            }
        }
    }

    class Common extends OCR.IBase {
        x {
            get => this.BoundingRect.x
        } 
        y {
            get => this.BoundingRect.y
        }
        w {
            get => this.BoundingRect.w
        }
        h {
            get => this.BoundingRect.h
        }
    
        /**
         * Highlights the object on the screen with a red box
         * @param {number} showTime Default is 2 seconds.
         * * Unset - if highlighting exists then removes the highlighting, otherwise pauses for 2 seconds
         * * 0 - Indefinite highlighting
         * * Positive integer (eg 2000) - will highlight and pause for the specified amount of time in ms
         * * Negative integer - will highlight for the specified amount of time in ms, but script execution will continue
         * * "clear" - removes the highlighting unconditionally
         * * "clearall" - remove highlightings from all OCR objects
         * @param {string} color The color of the highlighting. Default is red.
         * @param {number} d The border thickness of the highlighting in pixels. Default is 2.
         * @returns {OCR.Result}
         */
        Highlight(showTime?, color:="Red", d:=2) {
            static Guis := Map()
            local x, y, w, h, key, oObj, GuiObj, iw, ih
            ; showTime unset => either highlights for 2s, or removes highlight
            ; showTime clear => removes highlight
            if IsSet(showTime) {
                if showTime = "clearall" {
                    for key, oObj in Guis { ; enum all OCR result objects
                        try oObj.GuiObj.Destroy()
                        SetTimer(oObj.TimerObj, 0)
                    }
                    Guis := Map()
                    return this
                } else if showTime = "clear" {
                    if Guis.Has(this) {
                        try Guis[this].GuiObj.Destroy()
                        SetTimer(Guis[this].TimerObj, 0)
                        Guis.Delete(this)
                    }
                    return this
                }
            }
    
            if !IsSet(showTime) {
                if Guis.Has(this) {
                    try Guis[this].GuiObj.Destroy()
                    SetTimer(Guis[this].TimerObj, 0)
                    Guis.Delete(this)
                    return this
                } else
                    showTime := 2000
            }
    
            x := this.x, y := this.y, w := this.w, h := this.h
            if this.HasProp("Relative") {
                if this.Relative.HasProp("CoordMode") {
                    if this.Relative.CoordMode = "Client"
                        WinGetClientPos(&rX, &rY,,, this.Relative.hWnd), x += rX, y += rY
                    else if this.Relative.CoordMode = "Window"
                        WinGetPos(&rX, &rY,,, this.Relative.hWnd), x += rX, y += rY
                }
                x += this.Relative.HasProp("x") ? this.Relative.x : 0
                y += this.Relative.HasProp("y") ? this.Relative.y : 0
            }
    
            if !Guis.Has(this) {
                Guis[this] := {}
                Guis[this].GuiObj := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
                Guis[this].TimerObj := ObjBindMethod(this, "Highlight", "clear")
            }
            GuiObj := Guis[this].GuiObj
            GuiObj.BackColor := color
            iw:= w+d, ih:= h+d, w:=w+d*2, h:=h+d*2, x:=x-d, y:=y-d
            WinSetRegion("0-0 " w "-0 " w "-" h " 0-" h " 0-0 " d "-" d " " iw "-" d " " iw "-" ih " " d "-" ih " " d "-" d, GuiObj.Hwnd)
            GuiObj.Show("NA x" . x . " y" . y . " w" . w . " h" . h)
    
            if showTime > 0 {
                Sleep(showTime)
                this.Highlight()
            } else if showTime < 0
                SetTimer(Guis[this].TimerObj, -Abs(showTime))
            return this
        }
        ClearHighlight() => this.Highlight("clear")
    
        /**
         * Clicks an object
         * If this object (the one Click is called from) contains a "Relative" property (this is
         * added by default with OCR.FromWindow) containing a hWnd property, then that window will be activated,
         * otherwise the Relative objects x/y properties values will be added to the x and y coordinates as offsets.
         */
        Click(WhichButton?, ClickCount?, DownOrUp?) {
            local x := this.x, y := this.y, w := this.w, h := this.h, mode := "Screen", hwnd
            if this.HasProp("Relative") {
                if this.Relative.HasProp("CoordMode") {
                    if this.Relative.CoordMode = "Window"
                        mode := "Window", hwnd := this.Relative.Hwnd
                    else if this.Relative.CoordMode = "Client"
                        mode := "Client", hwnd := this.Relative.Hwnd
                    if IsSet(hwnd) && !WinActive(hwnd) {
                        WinActivate(hwnd)
                        WinWaitActive(hwnd,,1)
                    }
                }
                x += this.Relative.HasProp("x") ? this.Relative.x : 0
                y += this.Relative.HasProp("y") ? this.Relative.y : 0
            }
            oldCoordMode := A_CoordModeMouse
            CoordMode "Mouse", mode
            Click(x+w//2, y+h//2, WhichButton?, ClickCount?, DownOrUp?)
            CoordMode "Mouse", oldCoordMode
        }
    
        /**
         * ControlClicks an object.
         * If the result object originates from OCR.FromWindow which captured only the client area,
         * then the result object will contain correct coordinates for the ControlClick. 
         * Coordinates will be adjusted to Client area from the CoordMode that the OCR happened in.
         * Otherwise, if additionally a WinTitle is provided then the coordinates are treated as Screen 
         * coordinates and converted to Client coordinates.
         * @param WinTitle If WinTitle is set, then the coordinates stored in Obj will be converted to
         * client coordinates and ControlClicked.
         */
        ControlClick(WinTitle?, WinText?, WhichButton?, ClickCount?, Options?, ExcludeTitle?, ExcludeText?) {
            local x := this.x, y := this.y, w := this.w, h := this.h, hWnd
            if this.HasProp("Relative") {
                x += this.Relative.HasProp("x") ? this.Relative.x : 0
                y += this.Relative.HasProp("y") ? this.Relative.y : 0
            }
            if this.HasProp("Relative") && this.Relative.HasProp("CoordMode") && (this.Relative.CoordMode = "Client" || this.Relative.CoordMode = "Window") {
                mode := this.Relative.CoordMode, hWnd := this.Relative.hWnd
                if mode = "Window" {
                    ; Window -> Client
                    RECT := Buffer(16, 0), pt := Buffer(8, 0)
                    DllCall("user32\GetWindowRect", "Ptr", hWnd, "Ptr", RECT)
                    winX := NumGet(RECT, 0, "Int"), winY := NumGet(RECT, 4, "Int")
                    NumPut("int", winX+x, "int", winY+y, pt)
                    DllCall("user32\ScreenToClient", "Ptr", hWnd, "Ptr", pt)
                    x := NumGet(pt,0,"int"), y := NumGet(pt,4,"int")
                }
            } else if IsSet(WinTitle) {
                hWnd := WinExist(WinTitle, WinText?, ExcludeTitle?, ExcludeText?)
                pt := Buffer(8), NumPut("int",x,pt), NumPut("int", y,pt,4)
                DllCall("ScreenToClient", "Int", Hwnd, "Ptr", pt)
                x := NumGet(pt,0,"int"), y := NumGet(pt,4,"int")
            } else
                throw TargetError("ControlClick needs to be called either after a OCR.FromWindow result or with a WinTitle argument")
                
            ControlClick("X" (x+w//2) " Y" (y+h//2), hWnd,, WhichButton?, ClickCount?, Options?)
        }
    
        OffsetCoordinates(offsetX?, offsetY?) {
            if !IsSet(offsetX) || !IsSet(offsetY) {
                if this.HasOwnProp("Relative") {
                    offsetX := this.Relative.HasProp("x") ? this.Relative.X : 0
                    offsetY := this.Relative.HasProp("y") ? this.Relative.Y : 0
                } else
                    throw Error("No Relative property found",, -1)
            }
            if offsetX = 0 && offsetY = 0
                return this
            local word
            for word in this.Words
                word.x += offsetX, word.y += offsetY, word.BoundingRect := {X:word.x, Y:word.y, W:word.w, H:word.h}
            return this
        }
    }

    /**
     * Returns an OCR results object for an image file. Locations of the words will be relative to
     * the top left corner of the image.
     * @param FileName Either full or relative (to A_WorkingDir) path to the file.
     * @param lang OCR language. Default is first from available languages.
     * @param transform Either a scale factor number, or an object {scale:Float, grayscale:Boolean, invertcolors:Boolean, monochrome:0-255, rotate: 0 | 90 | 180 | 270, flip: 0 | "x" | "y"}
     * @returns {OCR.Result} 
     */
    static FromFile(FileName, Options:=0) {
        if !(fe := FileExist(FileName)) or InStr(fe, "D")
            throw TargetError("File `"" FileName "`" doesn't exist", -1)
        GUID := this.CLSIDFromString(this.IID_IRandomAccessStream)
        DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", FileName, "uint", Read := 0, "ptr", GUID, "ptr*", IRandomAccessStream:=this.IBase())
        if IsObject(Options) && !Options.HasProp("Decoder")
            Options.Decoder := this.Vtbl_GetDecoder.HasOwnProp(ext := StrSplit(FileName, ".")[-1]) ? ext : ""
        return this(IRandomAccessStream, Options)
    }

    /**
     * Returns an array of OCR results objects for a PDF file. Locations of the words will be relative to
     * the top left corner of the PDF page.
     * @param FileName Either full or relative (to A_WorkingDir) path to the file.
     * @param Options Optional: OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * @param Start Optional: Page number to start from. Default is first page.
     * @param End Optional: Page number to end with (included). Default is last page.
     * @param Password Optional: PDF password.
     * @returns {OCR.Result} 
     */
    static FromPDF(FileName, Options:=0, Start:=1, End?, Password:="") {
        this.__ExtractNamedParameters(Options, "lang", &lang, "start", &Start, "end", &End, "password", &Password)
        if !(fe := FileExist(FileName)) or InStr(fe, "D")
            throw TargetError("File `"" FileName "`" doesn't exist", -1)

        DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", FileName, "uint", Read := 0, "ptr", GUID := this.CLSIDFromString(this.IID_IRandomAccessStream), "ptr*", IRandomAccessStream:=ComValue(13,0))
        PdfDocument := this.__OpenPdfDocument(IRandomAccessStream, Password)
        this.CloseIClosable(IRandomAccessStream)
        if !IsSet(End) {
            ComCall(7, PdfDocument, "uint*", &End:=0) ; GetPageCount
            if !End
                throw Error("Unable to get PDF page count", -1)
        }
        local results := []
        Loop (End+1-Start)
            results.Push(this.FromPDFPage(PdfDocument, Start+(A_Index-1), Options))
        return results
    }

    static GetPdfPageCount(FileName, Password:="") {
        DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", FileName, "uint", Read := 0, "ptr", GUID := this.CLSIDFromString(this.IID_IRandomAccessStream), "ptr*", IRandomAccessStream:=ComValue(13,0))
        PdfDocument := this.__OpenPdfDocument(IRandomAccessStream, Password)
        this.CloseIClosable(IRandomAccessStream)
        ComCall(7, PdfDocument, "uint*", &PageCount:=0) ; GetPageCount
        if !PageCount
            throw Error("Unable to get PDF page count", -1)
        
        return PageCount
    }

    ; Returns {Width, Height, Rotation, PreferredZoom}
    static GetPdfPageProperties(FileName, Page, Password:="") {
        DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", FileName, "uint", Read := 0, "ptr", GUID := this.CLSIDFromString(this.IID_IRandomAccessStream), "ptr*", IRandomAccessStream:=ComValue(13,0))
        PdfDocument := this.__OpenPdfDocument(IRandomAccessStream, Password)
        this.CloseIClosable(IRandomAccessStream)
        ComCall(6, PdfDocument, "uint", Page-1, "ptr*", PdfPage:=ComValue(13, 0)) ; GetPage
        ComCall(10, PdfPage, "ptr*", Size:=Buffer(8, 0)) ; Size
        ComCall(12, PdfPage, "uint*", &Rotation:=0)
        ComCall(12, PdfPage, "float*", &PreferredZoom:=0)
        return {Width: NumGet(Size, 0, "float"), Height: NumGet(size, 4, "float"), Rotation: Rotation*90, PreferredZoom:PreferredZoom}
    }

    /**
     * Returns an OCR result object for a PDF page. Locations of the words will be relative to
     * the top left corner of the PDF page.
     * @param FileName Either full or relative (to A_WorkingDir) path to the file.
     * @param Page The page number to OCR.
     * @param Options Optional: OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * @param Password Optional: PDF password.
     * @returns {OCR.Result} 
     */
    static FromPDFPage(FileName, Page, Options:=0, Password:="") {
        local scale := 1, x := 0, y := 0, w := 0, h := 0
        if IsObject(Options)
            Options := Options.Clone()
        this.__ExtractNamedParameters(Options, "Password", &Password, "scale", &scale, "x", &x, "y", &y, "w", &w, "h", &h)
        if FileName is String {
            if !(fe := FileExist(FileName)) or InStr(fe, "D")
                throw TargetError("File `"" FileName "`" doesn't exist", -1)
            GUID := this.CLSIDFromString(this.IID_IRandomAccessStream)
            DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", FileName, "uint", Read := 0, "ptr", GUID, "ptr*", IRandomAccessStream:=ComValue(13, 0))
            PdfDocument := this.__OpenPdfDocument(IRandomAccessStream, Password)
        } else
            PdfDocument := FileName
        ComCall(6, PdfDocument, "uint", Page-1, "ptr*", PdfPage:=ComValue(13, 0)) ; GetPage
        InMemoryRandomAccessStream := this.CreateClass("Windows.Storage.Streams.InMemoryRandomAccessStream")
        PdfPageRenderOptions := this.CreateClass("Windows.Data.Pdf.PdfPageRenderOptions")
        ComCall(15, PdfPageRenderOptions, "uint", true) ; IsIgnoringHighContrast
        if x || y || w || h {
            rect := Buffer(16, 0), NumPut("float", x, "float", y, "float", w, "float", h, rect)
            ComCall(7, PdfPageRenderOptions, "ptr", rect) ; put_SourceRect
            Options.w := Options.w*scale, Options.h := Options.h*scale
            Options.DeleteProp("x"), Options.DeleteProp("y"), Options.DeleteProp("w"), Options.DeleteProp("h")
        }
        if (scale != 1) {
            ComCall(10, PdfPage, "ptr", Size:=Buffer(8, 0)) ; get_Size
            ComCall(9, PdfPageRenderOptions, "uint", Floor((w || NumGet(size, 0, "float"))*scale)) ; put_DestinationWidth
            ComCall(11, PdfPageRenderOptions, "uint", Floor((h || NumGet(size, 4, "float"))*scale)) ; put_DestinationHeight
            Options.DeleteProp("scale")
        }
        ComCall(7, PdfPage, "ptr", InMemoryRandomAccessStream, "ptr", PdfPageRenderOptions, "ptr*", asyncInfo:=ComValue(13, 0)) ; RenderWithOptionsToStreamAsync
        this.WaitForAsync(&asyncInfo)
        if FileName is String
            this.CloseIClosable(IRandomAccessStream)
        PdfPage := "", PdfDocument := "", IRandomAccessStream := ""
        OcrResult := this(InMemoryRandomAccessStream, Options)
        if scale != 1
            this.NormalizeCoordinates(OcrResult, scale)
        return OcrResult
    }

    /**
     * Returns an OCR results object for a given window. Locations of the words will be relative
     * using the CoordMode from A_CoordModePixel (default is Client). 
     * The window from where the image was captured is stored in Result.Relative.hWnd
     * Additionally, Result.Relative.CoordMode is stored (the A_CoordModePixel at the time of OCR).
     * @param WinTitle A window title or other criteria identifying the target window.
     * @param Options Optional: OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * Additionally for FromWindow the options may include:
     *      mode:  Different methods of capturing the window. 
     *        0 = uses GetDC with BitBlt
     *        1 = same as 0 but window transparency is turned off beforehand with WinSetTransparent
     *        2 = uses PrintWindow. 
     *        3 = same as 1 but window transparency is turned off beforehand with WinSetTransparent
     *        4 = uses PrintWindow with undocumented PW_RENDERFULLCONTENT flag, allowing capture of hardware-accelerated windows
     *        5 = uses Direct3D11 from UWP Windows.Graphics.Capture (slowest option, but may work with games) 
     *             This may draw a yellow border around the target window in older Windows versions.
     * @param WinText Additional window criteria.
     * @param ExcludeTitle Additional window criteria.
     * @param ExcludeText Additional window criteria.
     * @returns {OCR.Result} 
     */
    static FromWindow(WinTitle:="", Options:=0, WinText:="", ExcludeTitle:="", ExcludeText:="") {
        local result, coordsmode := A_CoordModePixel, onlyClientArea := coordsMode = "Client", mode := 4, X := 0, Y := 0, W := 0, H := 0, sX, sY, hBitMap, hwnd, customRect := 0, transform := 0
        if !Options && Type(WinTitle) = "Object"
            Options := WinTitle, WinTitle := ""
        if IsObject(Options)
            Options := Options.Clone()
        this.__ExtractTransformParameters(Options, &transform)
        this.__ExtractNamedParameters(Options, "x", &x, "y", &y, "w", &w, "width", &w, "h", &h, "height", &h, "mode", &mode, "WinTitle", &WinTitle, "WinText", &WinText, "ExcludeTitle", &ExcludeTitle, "ExcludeText", &ExcludeText)
        this.__DeleteProps(Options, "x", "y", "w", "width", "h", "height", "scale", "mode")
        if (x !=0 || y != 0 || w != 0 || h != 0)
            customRect := 1
        if !(hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
            throw TargetError("Target window not found", -1)
        if DllCall("IsIconic", "uptr", hwnd)
            DllCall("ShowWindow", "uptr", hwnd, "int", 4)
        if mode < 4 && mode&1 {
            oldStyle := WinGetExStyle(hwnd), i := 0
            WinSetTransparent(255, hwnd)
            While (WinGetTransparent(hwnd) != 255 && ++i < 30)
                Sleep 100
        }

        WinGetPos(&wX, &wY, &wW, &wH, hWnd)
        If onlyClientArea {
            WinGetClientPos(&cX, &cY, &cW, &cH, hWnd)
            W := W || cW, H := H || cH, sX := X + cX, sY := Y + cY  ; Calculate final X and Y screen coordinates
        } else {
            W := W || wW, H := H || wH, sX := X + wX, sY := Y + wY
        }

        if mode = 5 {
            /*
                If we are capturing the whole window, then WinGetPos/MouseGetPos might include hidden borders.
                Eg (0,0) might be (-11, -11) for Direct3D, meaning (11,11) by WinGetPos is (0,0) for Direct3D.
                These offsets are calculated and stored in offsetX, offsetY, and if only the window
                area is captured then the result object coordinates are adjusted accordingly.

                If the SoftwareBitmap needs to be transformed in any way (eg scale or custom rect is
                provided) then we need to offset coordinates and possibly width/height as well.

            */
            SoftwareBitmap := this.CreateDirect3DSoftwareBitmapFromWindow(hWnd)

            local sbW := SoftwareBitmap.W, sbH := SoftwareBitmap.H, sbX := SoftwareBitmap.X, sbY := SoftwareBitmap.Y
            local offsetX := 0, offsetY := 0

            if transform.scale != 1 || transform.rotate || transform.flip || customRect || onlyClientArea {
                ; The bounds need to fit inside the SoftwareBitmap bounds, so possibly X,Y need to be adjusted along with W,H
                local tX := X, tY := Y, tW := W, tH := H
                if onlyClientArea
                    tX -= SoftwareBitmap.X-cX, tY -= SoftwareBitmap.Y-cY
                else
                    tX -= SoftwareBitmap.X-wX, tY -= SoftwareBitmap.Y-wY
                if tX < 0 ; If resulting coordinates are negative then adjust width and height accordingly 
                    tW += tX, offsetX := -tX, tX := 0
                if tY < 0
                    tH += tY, offsetY := -tY, tY := 0
                tW := Min(sbW-tX, tW), tH := Min(sbH-tY, tH)

                SoftwareBitmap := this.TransformSoftwareBitmap(SoftwareBitmap, &sbW, &sbH, transform.scale, transform.rotate, transform.flip, tX, tY, tW, tH)
                this.__DeleteProps(Options, "scale", "rotate", "flip")
            } else
                offsetX := sbX-wX, offsetY := sbY-wY
            result := this(SoftwareBitmap, Options)
        } else {
            hBitMap := this.CreateHBitmap(X, Y, W, H, {hWnd:hWnd, onlyClientArea:onlyClientArea, mode:(mode//2)}, transform.scale)
            if mode&1
                WinSetExStyle(oldStyle, hwnd)
            SoftwareBitmap := this.HBitmapToSoftwareBitmap(hBitMap,, transform)
            this.__DeleteProps(Options, "invertcolors", "grayscale", "monochrome")
            result := this(SoftwareBitmap, Options)
        }

        result.Relative := {CoordMode:coordsmode, hWnd:hWnd}
        if coordsmode = "Screen"
            x += sX, y += sY
        this.NormalizeCoordinates(result, transform.scale, x, y)
        if mode = 5 && !onlyClientArea
            result.OffsetCoordinates(offsetX, offsetY)
        return result
    }

    /**
     * Returns an OCR results object for the specified monitor. Locations of the words will be relative to
     * the primary screen (CoordMode "Screen"), even if a secondary monitor is being captured.
     * @param Monitor Optional: The monitor from which to get the desktop area. Default is primary monitor.
     *   If screen scaling between monitors differs, then use DllCall("SetThreadDpiAwarenessContext", "ptr", -3)
     * @param Options Optional: OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * @returns {OCR.Result} 
     */
    static FromMonitor(Monitor?, Options:=0) {
        if !Options && IsSet(Monitor) && IsObject(Monitor)
            Options := Monitor, Monitor := unset
        this.__ExtractNamedParameters(Options, "Monitor", &Monitor)
        MonitorGet(monitor?, &Left, &Top, &Right, &Bottom)
        return this.FromRect(Left, Top, Right-Left, Bottom-Top, Options)
    }

    /**
     * Returns an OCR results object for the whole virtual screen. Locations of the words will be relative to
     * the primary screen (CoordMode "Screen").
     * @param Options Optional: OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     *   If screen scaling between monitors differs, then use DllCall("SetThreadDpiAwarenessContext", "ptr", -3)
     * @returns {OCR.Result}
     */
    static FromDesktop(Options:=0) => this.FromRect(SysGet(76), SysGet(77), SysGet(78), SysGet(79), Options)

    /**
     * Returns an OCR results object for a region of the screen. Locations of the words will be relative
     * to the screen.
     * @param x Screen x coordinate
     * @param y Screen y coordinate
     * @param w Region width. Maximum is OCR.MaxImageDimension; minimum is 40 pixels (source: user FanaticGuru in AutoHotkey forums), smaller images will be scaled to at least 40 pixels.
     * @param h Region height. Maximum is OCR.MaxImageDimension; minimum is 40 pixels, smaller images will be scaled accordingly.
     * @param Options OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * @returns {OCR.Result} 
     */
    static FromRect(x, y, w, h, Options:=0) {
        local transform := 0, result
        if IsObject(Options)
            Options := Options.Clone()
        this.__ExtractTransformParameters(Options, &transform)
        this.__DeleteProps(Options, "scale", "invertcolors", "grayscale")
        local scale := transform.scale
            , hBitmap := this.CreateHBitmap(X, Y, W, H,, scale)
            , SoftwareBitmap := this.HBitmapToSoftwareBitmap(hBitmap,, transform)
            , result := this(SoftwareBitmap, Options)
        return this.NormalizeCoordinates(result, scale, x, y)
    }

    /**
     * Returns an OCR results object from a bitmap. Locations of the words will be relative
     * to the top left corner of the bitmap.
     * @param Bitmap A pointer to a GDIP Bitmap object, or HBITMAP, or an object with a ptr property
     *  set to one of the two.
     * @param Options OCR options {lang, scale, grayscale, invertcolors, rotate, flip, x, y, w, h, decoder}. 
     * @param hDC Optional: a device context for the bitmap. If omitted then the screen DC is used.
     * @returns {OCR.Result} 
     */
    static FromBitmap(Bitmap, Options:=0, hDC?) {
        local result, pDC, hBitmap, hBM2, oBM, oBM2, pBitmapInfo := Buffer(32, 0), W, H, scale, transform := 0
        if IsObject(Options)
            Options := Options.Clone()
        this.__ExtractTransformParameters(Options, &transform)
        scale := transform.scale
        this.__ExtractNamedParameters(Options, "hDC", &hDC)
        this.__DeleteProps(Options, "scale", "invertcolors", "grayscale")
        if !DllCall("GetObject", "ptr", Bitmap, "int", pBitmapInfo.Size, "ptr", pBitmapInfo) {
            DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", Bitmap, "UPtr*", &hBitmap:=0, "Int", 0xffffffff)
            DllCall("GetObject", "ptr", hBitmap, "int", pBitmapInfo.Size, "ptr", pBitmapInfo)
            Bitmap := 0 ; Marks hBitmap to be deleted afterwards
        } else
            hBitmap := Bitmap

        W := NumGet(pBitmapInfo, 4, "int"), H := NumGet(pBitmapInfo, 8, "int")

        if scale != 1 || (W && H && (W < 40 || H < 40)) {
            sW := Ceil(W * scale), sH := Ceil(H * scale)

            hDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
            , oBM := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBitmap, "Ptr")
            , pDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
            , hBM2 := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", Max(40, sW), "Int", Max(40, sH), "Ptr")
            , oBM2 := DllCall("SelectObject", "Ptr", pDC, "Ptr", hBM2, "Ptr")
            if sW < 40 || sH < 40 ; Fills the bitmap so it's at least 40x40, which seems to improve recognition
                DllCall("StretchBlt", "Ptr", pDC, "Int", 0, "Int", 0, "Int", Max(40,sW), "Int", Max(40,sH), "Ptr", hDC, "Int", 0, "Int", 0, "Int", 1, "Int", 1, "UInt", 0x00CC0020 | this.CAPTUREBLT) ; SRCCOPY. 
            PrevStretchBltMode := DllCall("SetStretchBltMode", "Ptr", PDC, "Int", 3, "Int") ; COLORONCOLOR
            , DllCall("StretchBlt", "Ptr", pDC, "Int", 0, "Int", 0, "Int", sW, "Int", sH, "Ptr", hDC, "Int", 0, "Int", 0, "Int", W, "Int", H, "UInt", 0x00CC0020 | this.CAPTUREBLT) ; SRCCOPY
            , DllCall("SetStretchBltMode", "Ptr", PDC, "Int", PrevStretchBltMode)
            , DllCall("SelectObject", "Ptr", pDC, "Ptr", oBM2)
            , DllCall("SelectObject", "Ptr", hDC, "Ptr", oBM)
            , DllCall("DeleteDC", "Ptr", hDC)
            SoftwareBitmap := this.HBitmapToSoftwareBitmap(hBM2, pDC, transform)
            result := this(SoftwareBitmap, Options)
            this.NormalizeCoordinates(result, scale)
            DllCall("DeleteDC", "Ptr", pDC)
            , DllCall("DeleteObject", "UPtr", hBM2)
            goto End
        }
        result := this(this.HBitmapToSoftwareBitmap(hBitmap, hDC?, transform), Options)
        End:
        if !Bitmap
            DllCall("DeleteObject", "UPtr", hBitmap)
        return result
    } 

    /**
     * Returns all available languages as a string, where the languages are separated by newlines.
     * @returns {String} 
     */
    static GetAvailableLanguages() {
        ComCall(7, this.OcrEngineStatics, "ptr*", &LanguageList := 0)   ; AvailableRecognizerLanguages
        ComCall(7, LanguageList, "int*", &count := 0)   ; count
        Loop count {
            ComCall(6, LanguageList, "int", A_Index - 1, "ptr*", &Language := 0)   ; get_Item
            ComCall(6, Language, "ptr*", &hText := 0)
            buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length := 0, "ptr")
            text .= StrGet(buf, "UTF-16") "`n"
            this.DeleteHString(hText)
            ObjRelease(Language)
        }
        ObjRelease(LanguageList)
        return text
    }

    /**
     * Loads a new language which will be used with subsequent OCR calls.
     * @param {string} lang OCR language. Default is first from available languages.
     * @returns {void} 
     */
    static LoadLanguage(lang:="FirstFromAvailableLanguages") {
        local hString, Language:=ComValue(13, 0), OcrEngine:=ComValue(13, 0)
        if this.HasOwnProp("CurrentLanguage") && this.HasOwnProp("OcrEngine") && this.CurrentLanguage = lang
            return
        if HasMethod(lang)
            lang := lang()
        if (lang = "FirstFromAvailableLanguages")
            ComCall(10, this.OcrEngineStatics, "ptr*", OcrEngine)   ; TryCreateFromUserProfileLanguages
        else {
            hString := this.CreateHString(lang)
            , ComCall(6, this.LanguageFactory, "ptr", hString, "ptr*", Language)   ; CreateLanguage
            , this.DeleteHString(hString)
            , ComCall(9, this.OcrEngineStatics, "ptr", Language, "ptr*", OcrEngine)   ; TryCreateFromLanguage
        }
        if (OcrEngine.ptr = 0)
            Throw Error(lang = "FirstFromAvailableLanguages" ? "Failed to use FirstFromAvailableLanguages for OCR:`nmake sure the primary language pack has OCR capabilities installed.`n`nAlternatively try `"en-us`" as the language." : "Can not use language `"" lang "`" for OCR, please install language pack.")
        this.OcrEngine := OcrEngine, this.CurrentLanguage := lang
    }

    /**
     * Returns a bounding rectangle {x,y,w,h} for the provided Word objects
     * @param words Word object arguments (at least 1)
     * @returns {Object}
     */
    static WordsBoundingRect(words*) {
        if !words.Length
            throw ValueError("This function requires at least one argument", -1)
        local X1 := 100000000, Y1 := 100000000, X2 := -100000000, Y2 := -100000000, word
        for word in words {
            X1 := Min(word.x, X1), Y1 := Min(word.y, Y1), X2 := Max(word.x+word.w, X2), Y2 := Max(word.y+word.h, Y2)
        }
        return {X:X1, Y:Y1, W:X2-X1, H:Y2-Y1, X2:X2, Y2:Y2}
    }
    
    /**
     * Waits text to appear on screen. If the method is successful, then Func's return value is returned.
     * Otherwise nothing is returned.
     * @param needle The searched text
     * @param {number} timeout Timeout in milliseconds. Less than 0 is indefinite wait (default)
     * @param func The function to be called for the OCR. Default is OCR.FromDesktop
     * @param casesense Text comparison case-sensitivity
     * @param comparefunc A custom string compare/search function, that accepts two arguments: haystack and needle.
     *      Default is InStr. If a custom function is used, then casesense is ignored.
     * @returns {OCR.Result} 
     */
    static WaitText(needle, timeout:=-1, func?, casesense:=False, comparefunc?) {
        local endTime := A_TickCount+timeout, result, line, total
        if !IsSet(func)
            func := this.FromDesktop
        if !IsSet(comparefunc)
            comparefunc := InStr.Bind(,,casesense)
        While timeout > 0 ? (A_TickCount < endTime) : 1 {
            result := func(), total := ""
            for line in result.Lines
                total .= line.Text "`n"
            if comparefunc(Trim(total, "`n"), needle)
                return result
        }
        return
    }

    /**
     * Returns word clusters using a two-dimensional DBSCAN algorithm
     * @param objs An array of objects (Words, Lines etc) to cluster. Must have x, y, w, h and Text properties.
     * @param eps_x Optional epsilon value for x-axis. Default is infinite.
     * This is unused if compareFunc is provided.
     * @param eps_y Optional epsilon value for y-axis. Default is median height of objects divided by two.
     * This is unused if compareFunc is provided.
     * @param minPts Optional minimum cluster size.
     * @param compareFunc Optional comparison function to judge the minimum distance between objects
     * to consider it a cluster. Must accept two objects to compare.
     * Default comparison function determines whether the difference of middle y-coordinates of 
     * the objects are less than epsilon-y, and whether objects are less than eps_x apart on the x-axis.
     * 
     * Eg `(p1, p2) => ((Abs(p1.y+p1.h-p2.y) < 5 || Abs(p2.y+p2.h-p1.y) < 5) && ((p1.x >= p2.x && p1.x <= (p2.x+p2.w)) || ((p1.x+p1.w) >= p2.x && (p1.x+p1.w) <= (p2.x+p2.w))))`
     * will cluster objects if they are located on top of eachother on the x-axis, and less than 5 pixels
     * apart in the y-axis.
     * @param noise If provided, then will be set to an array of clusters that didn't satisfy minPts
     * @returns {Array} Array of objects with {x,y,w,h,Text,Words} properties
     */
    static Cluster(objs, eps_x:=-1, eps_y:=-1, minPts:=1, compareFunc?, &noise?) {
        local clusters := [], start := 0, cluster, word
        visited := Map(), clustered := Map(), C := [], c_n := 0, sum := 0, noise := IsSet(noise) && (noise is Array) ? noise : []
        if !IsObject(objs) || !(objs is Array)
            throw ValueError("objs argument must be an Array", -1)
        if !objs.Length
            return []
        if IsSet(compareFunc) && !HasMethod(compareFunc)
            throw ValueError("compareFunc must be a valid function", -1)

        if !IsSet(compareFunc) {
            if (eps_y < 0) {
                for point in objs
                    sum += point.h
                eps_y := (sum // objs.Length) // 2
            }
            compareFunc := (p1, p2) => Abs(p1.y+p1.h//2-p2.y-p2.h//2)<eps_y && (eps_x < 0 || (Abs(p1.x+p1.w-p2.x)<eps_x || Abs(p1.x-p2.x-p2.w)<eps_x))
        }

        ; DBSCAN adapted from https://github.com/ninopereira/DBSCAN_1D
        for point in objs {
            visited[point] := 1, neighbourPts := [], RegionQuery(point)
            if !clustered.Has(point) {
                C.Push([]), c_n += 1, C[c_n].Push(point), clustered[point] := 1
                ExpandCluster(point)
            }
            if C[c_n].Length < minPts
                noise.Push(C[c_n]), C.RemoveAt(c_n), c_n--
        }

        ; Sort clusters by x-coordinate, get cluster bounding rects, and concatenate word texts
        for cluster in C {
            this.SortArray(cluster,,"x")
            br := this.Common(), br.DefineProp("BoundingRect", {value:this.WordsBoundingRect(cluster*)}), br.DefineProp("Words", {value:cluster}), br.DefineProp("Text", {value: ""})
            for word in cluster
                br.Text .= word.Text " "
            br.Text := RTrim(br.Text)
            clusters.Push(br)
        }
        ; Sort clusters/lines by y-coordinate
        this.SortArray(clusters,,"y")
        return clusters

        ExpandCluster(P) {
            local point
            for point in neighbourPts {
                if !visited.Has(point) {
                    visited[point] := 1, RegionQuery(point)
                    if !clustered.Has(point)
                        C[c_n].Push(point), clustered[point] := 1
                }
            }
        }

        RegionQuery(P) {
            local point
            for point in objs
                if !visited.Has(point)
                    if compareFunc(P, point)
                        neighbourPts.Push(point)
        }
    }

    /**
     * Sorts an array in-place, optionally by object keys or using a callback function.
     * @param arr The array to be sorted
     * @param OptionsOrCallback Optional: either a callback function, or one of the following:
     * 
     *     N => array is considered to consist of only numeric values. This is the default option.
     *     C, C1 or COn => case-sensitive sort of strings
     *     C0 or COff => case-insensitive sort of strings
     * 
     *     The callback function should accept two parameters elem1 and elem2 and return an integer:
     *     Return integer < 0 if elem1 less than elem2
     *     Return 0 is elem1 is equal to elem2
     *     Return > 0 if elem1 greater than elem2
     * @param Key Optional: Omit it if you want to sort a array of primitive values (strings, numbers etc).
     *     If you have an array of objects, specify here the key by which contents the object will be sorted.
     * @returns {Array}
     */
    static SortArray(arr, optionsOrCallback:="N", key?) {
        if (arr.Length < 2)
            return this
        if HasMethod(optionsOrCallback)
            compareFunc := optionsOrCallback, optionsOrCallback := ""
        else {
            if InStr(optionsOrCallback, "N")
                compareFunc := IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare
            if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
                compareFunc := IsSet(key) ? StringCompareKey.Bind(key,,True) : StringCompare.Bind(,,True)
            if RegExMatch(optionsOrCallback, "i)C0|COff")
                compareFunc := IsSet(key) ? StringCompareKey.Bind(key) : StringCompare
            if InStr(optionsOrCallback, "Random") {
                len := arr.Length
                Loop len-1 {
                    i := len + 1 - A_Index
                    j := Random(1, i)
                    if (j != i)
                        tmp := arr[i], arr[i] := arr[j], arr[j] := tmp
                }
                return arr
            }
            if !IsSet(compareFunc)
                throw ValueError("No valid options provided!", -1)
        }
        QuickSort(1, arr.Length)
        if RegExMatch(optionsOrCallback, "i)R(?!a)")
            this.ReverseArray(arr)
        if InStr(optionsOrCallback, "U")
            arr := this.UniqueArray(arr)
        return arr

        NumericCompare(left, right) => (left > right) - (left < right)
        NumericCompareKey(key, left, right) => ((f1 := left.HasProp("__Item") ? left[key] : left.%key%), (f2 := right.HasProp("__Item") ? right[key] : right.%key%), (f1 > f2) - (f1 < f2))
        StringCompare(left, right, casesense := False) => StrCompare(left "", right "", casesense)
        StringCompareKey(key, left, right, casesense := False) => StrCompare((left.HasProp("__Item") ? left[key] : left.%key%) "", (right.HasProp("__Item") ? right[key] : right.%key%) "", casesense)

        ; In-place quicksort (Hoare-style partition with middle pivot)
        QuickSort(left, right) {
            i := left
            j := right
            pivot := arr[(left + right) // 2]

            while (i <= j) {
                while (compareFunc(arr[i], pivot) < 0)
                    i++
                while (compareFunc(arr[j], pivot) > 0)
                    j--
                if (i <= j) {
                    temp := arr[i], arr[i] := arr[j], arr[j] := temp
                    i++, j--
                }
            }
            if (left < j)
                QuickSort(left, j)
            if (i < right)
                QuickSort(i, right)
        }
    }
    ; Reverses the array in-place
    static ReverseArray(arr) {
        local len := arr.Length + 1, max := (len // 2), i := 0
        while ++i <= max
            temp := arr[len - i], arr[len - i] := arr[i], arr[i] := temp
        return arr
    }
    ; Returns a new array with only unique values
    static UniqueArray(arr) {
        local unique := Map()
        for v in arr
            unique[v] := 1
        return [unique*]
    }

    ; Returns a one-dimensional array from a multi-dimensional array
    static FlattenArray(arr) {
        local r := []
        for v in arr {
            if v is Array
                r.Push(this.FlattenArray(v)*)
            else
                r.Push(v)
        }
        return r
    }

    ;; Only internal methods ahead

    ; Scales and optionally crops a SoftwareBitmap. Crop parameters need to not be scale-adjusted.
    ; Rotation can be clockwise 0, 90, 180, or 270 degrees
    ; Flip: 0 = no flip, 1 = around y-axis, 2 = around x-axis
    static TransformSoftwareBitmap(SoftwareBitmap, &sbW, &sbH, scale:=1, rotate:=0, flip:=0, X?, Y?, W?, H?) {
        InMemoryRandomAccessStream := this.SoftwareBitmapToRandomAccessStream(SoftwareBitmap)

        ComCall(this.Vtbl_GetDecoder.png, this.BitmapDecoderStatics, "ptr", DecoderGUID:=Buffer(16))
        ComCall(15, this.BitmapDecoderStatics, "ptr", DecoderGUID, "ptr", InMemoryRandomAccessStream, "ptr*", BitmapDecoder:=ComValue(13,0))   ; CreateAsync
        this.WaitForAsync(&BitmapDecoder)

        BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
        BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")

        BitmapTransform := this.CreateClass("Windows.Graphics.Imaging.BitmapTransform")

        if IsSet(W) && W
            sbW := Min(sbW, W)
        if IsSet(H) && H
            sbH := Min(sbH, H)
        local sW := Floor(sbW*scale), sH := Floor(sbH*scale), intermediate
        if scale != 1 {
            ; First the bitmap is scaled, then cropped
            ComCall(7, BitmapTransform, "uint", sW) ; put_ScaledWidth
            ComCall(9, BitmapTransform, "uint", sH) ; put_ScaledHeight
        }
        if rotate {
            ComCall(15, BitmapTransform, "uint", rotate//90) ; put_Rotation
            if rotate = 90 || rotate = 270
                intermediate := sW, sW := sH, sH := intermediate
        }
        if flip
            ComCall(13, BitmapTransform, "uint", flip) ; put_Flip

        if (IsSet(X) && X != 0) || (IsSet(Y) && Y != 0) || IsSet(W) || IsSet(H)  {
            bounds := Buffer(16,0), NumPut("int", Floor(X*scale), "int", Floor(Y*scale), "int", Floor(sbW*scale), "int", Floor(sbH*scale), bounds)
            ComCall(17, BitmapTransform, "ptr", bounds) ; put_Bounds
        }
        ComCall(8, BitmapFrame, "uint*", &BitmapPixelFormat:=0) ; get_BitmapPixelFormat
        ComCall(9, BitmapFrame, "uint*", &BitmapAlphaMode:=0) ; get_BitmapAlphaMode
        ComCall(8, BitmapFrameWithSoftwareBitmap, "uint", BitmapPixelFormat, "uint", BitmapAlphaMode, "ptr", BitmapTransform, "uint", IgnoreExifOrientation := 0, "uint", DoNotColorManage := 0, "ptr*", SoftwareBitmap:=ComValue(13,0)) ; GetSoftwareBitmapTransformedAsync

        this.WaitForAsync(&SoftwareBitmap)
        ; this.CloseIClosable(BitmapFrameWithSoftwareBitmap) ; Implemented, but is it necessary?
        this.CloseIClosable(InMemoryRandomAccessStream)
        sbW := sW, sbH := sH
        return SoftwareBitmap
    }

    static CreateDIBSection(w, h, hdc?, bpp:=32, &ppvBits:=0) {
        local hdc2 := IsSet(hdc) ? hdc : DllCall("GetDC", "Ptr", 0, "UPtr")
        , bi := Buffer(40, 0), hbm
        NumPut("int", 40, "int", w, "int", h, "ushort", 1, "ushort", bpp, "int", 0, bi)
        hbm := DllCall("CreateDIBSection", "uint", hdc2, "ptr" , bi, "uint" , 0, "uint*", &ppvBits:=0, "uint" , 0, "uint" , 0)
        if !IsSet(hdc)
            DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc2)
        return hbm
    }

    /**
     * Creates an hBitmap of a region of the screen or a specific window
     * @param X Captured rectangle X coordinate. This is relative to the screen unless hWnd is specified,
     *  in which case it may be relative to the window/client
     * @param Y Captured rectangle Y coordinate.
     * @param W Captured rectangle width.
     * @param H Captured rectangle height.
     * @param {Integer|Object} hWnd Window handle which to capture. Coordinates will be relative to the window. 
     *  hWnd may also be an object {hWnd, onlyClientArea, mode} where onlyClientArea:1 means the client area will be captured instead of the whole window (and X, Y will also be relative to client)
     *  mode 0 uses GetDC + StretchBlt, mode 1 uses PrintWindow, mode 2 uses PrintWindow with undocumented PW_RENDERFULLCONTENT flag. 
     *  Default is mode 2.
     * @param {Integer} scale 
     * @returns {OCR.IBase} 
     */
    static CreateHBitmap(X, Y, W, H, hWnd:=0, scale:=1) {
        local sW := Ceil(W*scale), sH := Ceil(H*scale), onlyClientArea := 0, mode := 2, HDC, obm, hbm, pdc, hbm2
        if hWnd {
            if IsObject(hWnd)
                onlyClientArea := hWnd.HasOwnProp("onlyClientArea") ? hWnd.onlyClientArea : onlyClientArea, mode := hWnd.HasOwnProp("mode") ? hWnd.mode : mode, hWnd := hWnd.hWnd
            HDC := DllCall("GetDCEx", "Ptr", hWnd, "Ptr", 0, "Int", 2|!onlyClientArea, "Ptr")
            if mode > 0 {
                PDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
                HBM := DllCall("CreateCompatibleBitmap", "Ptr", HDC, "Int", Max(40,X+W), "Int", Max(40,Y+H), "Ptr")
                , OBM := DllCall("SelectObject", "Ptr", PDC, "Ptr", HBM, "Ptr")
                , DllCall("PrintWindow", "Ptr", hWnd, "Ptr", PDC, "UInt", (mode=2?2:0)|!!onlyClientArea)
                if scale != 1 || X != 0 || Y != 0 {
                    PDC2 := DllCall("CreateCompatibleDC", "Ptr", PDC, "Ptr")
                    , HBM2 := DllCall("CreateCompatibleBitmap", "Ptr", PDC, "Int", Max(40,sW), "Int", Max(40,sH), "Ptr")
                    , OBM2 := DllCall("SelectObject", "Ptr", PDC2, "Ptr", HBM2, "Ptr")
                    , PrevStretchBltMode := DllCall("SetStretchBltMode", "Ptr", PDC, "Int", 3, "Int") ; COLORONCOLOR
                    , DllCall("StretchBlt", "Ptr", PDC2, "Int", 0, "Int", 0, "Int", sW, "Int", sH, "Ptr", PDC, "Int", X, "Int", Y, "Int", W, "Int", H, "UInt", 0x00CC0020 | this.CAPTUREBLT) ; SRCCOPY
                    , DllCall("SetStretchBltMode", "Ptr", PDC, "Int", PrevStretchBltMode)
                    , DllCall("SelectObject", "Ptr", PDC2, "Ptr", obm2)
                    , DllCall("DeleteDC", "Ptr", PDC)
                    , DllCall("DeleteObject", "UPtr", HBM)
                    , hbm := hbm2, pdc := pdc2
                }
                DllCall("SelectObject", "Ptr", PDC, "Ptr", OBM)
                , DllCall("DeleteDC", "Ptr", HDC)
                , oHBM := this.IBase(HBM), oHBM.DC := PDC
                return oHBM.DefineProp("__Delete", {call:(this, *)=>(DllCall("DeleteObject", "Ptr", this), DllCall("DeleteDC", "Ptr", this.DC))})
            }
        } else {
            HDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        }
        PDC := DllCall("CreateCompatibleDC", "Ptr", HDC, "Ptr")
        , HBM := DllCall("CreateCompatibleBitmap", "Ptr", HDC, "Int", Max(40,sW), "Int", Max(40,sH), "Ptr")
        , OBM := DllCall("SelectObject", "Ptr", PDC, "Ptr", HBM, "Ptr")
        if sW < 40 || sH < 40 ; Fills the bitmap so it's at least 40x40, which seems to improve recognition
            DllCall("StretchBlt", "Ptr", PDC, "Int", 0, "Int", 0, "Int", Max(40,sW), "Int", Max(40,sH), "Ptr", HDC, "Int", X, "Int", Y, "Int", 1, "Int", 1, "UInt", 0x00CC0020 | this.CAPTUREBLT) ; SRCCOPY. 
        PrevStretchBltMode := DllCall("SetStretchBltMode", "Ptr", PDC, "Int", 3, "Int") ; COLORONCOLOR
        , DllCall("StretchBlt", "Ptr", PDC, "Int", 0, "Int", 0, "Int", sW, "Int", sH, "Ptr", HDC, "Int", X, "Int", Y, "Int", W, "Int", H, "UInt", 0x00CC0020 | this.CAPTUREBLT) ; SRCCOPY
        , DllCall("SetStretchBltMode", "Ptr", PDC, "Int", PrevStretchBltMode)
        , DllCall("SelectObject", "Ptr", PDC, "Ptr", OBM)
        , DllCall("DeleteDC", "Ptr", HDC)
        , oHBM := this.IBase(HBM), oHBM.DC := PDC
        return oHBM.DefineProp("__Delete", {call:(this, *)=>(DllCall("DeleteObject", "Ptr", this), DllCall("DeleteDC", "Ptr", this.DC))})
    }

    static CreateDirect3DSoftwareBitmapFromWindow(hWnd) {
        static init := 0, DXGIDevice, Direct3DDevice, Direct3D11CaptureFramePoolStatics, GraphicsCaptureItemInterop, GraphicsCaptureItemGUID, D3D_Device, D3D_Context
        local x, y, w, h, rect
        if !init {
            DllCall("LoadLibrary","str","DXGI")
            DllCall("LoadLibrary","str","D3D11")
            DllCall("LoadLibrary","str","Dwmapi")
            DllCall("D3D11\D3D11CreateDevice", "ptr", 0, "int", D3D_DRIVER_TYPE_HARDWARE := 1, "ptr", 0, "uint", D3D11_CREATE_DEVICE_BGRA_SUPPORT := 0x20, "ptr", 0, "uint", 0, "uint", D3D11_SDK_VERSION := 7, "ptr*", D3D_Device:=ComValue(13, 0), "ptr*", 0, "ptr*", D3D_Context:=ComValue(13, 0))
            DXGIDevice := ComObjQuery(D3D_Device, IID_IDXGIDevice := "{54ec77fa-1377-44e6-8c32-88fd5f44c84c}")
            DllCall("D3D11\CreateDirect3D11DeviceFromDXGIDevice", "ptr", DXGIDevice, "ptr*", GraphicsDevice:=ComValue(13, 0))
            Direct3DDevice := ComObjQuery(GraphicsDevice, IDirect3DDevice := "{A37624AB-8D5F-4650-9D3E-9EAE3D9BC670}")
            Direct3D11CaptureFramePoolStatics := this.CreateClass("Windows.Graphics.Capture.Direct3D11CaptureFramePool", IDirect3D11CaptureFramePoolStatics := "{7784056a-67aa-4d53-ae54-1088d5a8ca21}")
            GraphicsCaptureItemStatics := this.CreateClass("Windows.Graphics.Capture.GraphicsCaptureItem", IGraphicsCaptureItemStatics := "{A87EBEA5-457C-5788-AB47-0CF1D3637E74}")
            GraphicsCaptureItemInterop := ComObjQuery(GraphicsCaptureItemStatics, IGraphicsCaptureItemInterop := "{3628E81B-3CAC-4C60-B7F4-23CE0E0C3356}")
            GraphicsCaptureItemGUID := Buffer(16,0)
            DllCall("ole32\CLSIDFromString", "wstr", IGraphicsCaptureItem := "{79c3f95b-31f7-4ec2-a464-632ef5d30760}", "ptr", GraphicsCaptureItemGUID)
            init := 1
        }
        ; INIT done

        DllCall("Dwmapi.dll\DwmGetWindowAttribute", "ptr", hWnd, "uint", DWMWA_EXTENDED_FRAME_BOUNDS := 9, "ptr", rect := Buffer(16,0), "uint", 16)
        x := NumGet(rect, 0, "int"), y := NumGet(rect, 4, "int"), w := NumGet(rect, 8, "int") - x, h := NumGet(rect, 12, "int") - y
        ComCall(6, Direct3D11CaptureFramePoolStatics, "ptr", Direct3DDevice, "int", B8G8R8A8UIntNormalized := 87, "int", numberOfBuffers := 2, "int64", (h << 32) | w, "ptr*", Direct3D11CaptureFramePool:=ComValue(13, 0))   ; Direct3D11CaptureFramePool.Create
        if ComCall(3, GraphicsCaptureItemInterop, "ptr", hWnd, "ptr", GraphicsCaptureItemGUID, "ptr*", GraphicsCaptureItem:=ComValue(13, 0), "uint") {   ; IGraphicsCaptureItemInterop::CreateForWindow
            this.CloseIClosable(Direct3D11CaptureFramePool)
            throw Error("Failed to capture GraphicsItem of window",, -1)
        }
        ComCall(10, Direct3D11CaptureFramePool, "ptr", GraphicsCaptureItem, "ptr*", GraphicsCaptureSession:=ComValue(13, 0))   ; Direct3D11CaptureFramePool.CreateCaptureSession

        GraphicsCaptureSession2 := ComObjQuery(GraphicsCaptureSession, IGraphicsCaptureSession2 := "{2c39ae40-7d2e-5044-804e-8b6799d4cf9e}")
        ComCall(7, GraphicsCaptureSession2, "int", 0)   ; GraphicsCaptureSession.IsCursorCaptureEnabled put

        if (Integer(StrSplit(A_OSVersion, ".")[3]) >= 20348) { ; hide border
            GraphicsCaptureSession3 := ComObjQuery(GraphicsCaptureSession, IGraphicsCaptureSession3 := "{f2cdd966-22ae-5ea1-9596-3a289344c3be}")
            ComCall(7, GraphicsCaptureSession3, "int", 0)   ; GraphicsCaptureSession.IsBorderRequired put
        }
        ComCall(6, GraphicsCaptureSession)   ; GraphicsCaptureSession.StartCapture
        Loop {
            ComCall(7, Direct3D11CaptureFramePool, "ptr*", Direct3D11CaptureFrame:=ComValue(13, 0))   ; Direct3D11CaptureFramePool.TryGetNextFrame
            if (Direct3D11CaptureFrame.ptr != 0)
                break
        }
        ComCall(6, Direct3D11CaptureFrame, "ptr*", Direct3DSurface:=ComValue(13, 0))   ; Direct3D11CaptureFrame.Surface

        ComCall(11, this.SoftwareBitmapStatics, "ptr", Direct3DSurface, "ptr*", SoftwareBitmap:=ComValue(13, 0)) ; SoftwareBitmap::CreateCopyFromSurfaceAsync
        this.WaitForAsync(&SoftwareBitmap)

        this.CloseIClosable(Direct3D11CaptureFramePool)
        this.CloseIClosable(GraphicsCaptureSession)
        if GraphicsCaptureSession2 {
            this.CloseIClosable(GraphicsCaptureSession2)
        }
        if IsSet(GraphicsCaptureSession3) {
            this.CloseIClosable(GraphicsCaptureSession3)
        }
        this.CloseIClosable(Direct3D11CaptureFrame)
        this.CloseIClosable(Direct3DSurface)

        SoftwareBitmap.x := x, SoftwareBitmap.y := y, SoftwareBitmap.w := w, SoftwareBitmap.h := h
        return SoftwareBitmap
    }

    static HBitmapToRandomAccessStream(hBitmap) {
        static PICTYPE_BITMAP := 1
             , BSOS_DEFAULT   := 0
             , sz := 8 + A_PtrSize*2
        local PICTDESC, riid, size, pIRandomAccessStream
             
        DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "Ptr*", pIStream:=ComValue(13,0), "UInt")
        , PICTDESC := Buffer(sz, 0)
        , NumPut("uint", sz, "uint", PICTYPE_BITMAP, "ptr", IsInteger(hBitmap) ? hBitmap : hBitmap.ptr, PICTDESC)
        , riid := this.CLSIDFromString(this.IID_IPicture)
        , DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", PICTDESC, "Ptr", riid, "UInt", 0, "Ptr*", pIPicture:=ComValue(13,0), "UInt")
        , ComCall(15, pIPicture, "Ptr", pIStream, "UInt", true, "uint*", &size:=0, "UInt") ; IPicture::SaveAsFile
        , riid := this.CLSIDFromString(this.IID_IRandomAccessStream)
        , DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", pIStream, "UInt", BSOS_DEFAULT, "Ptr", riid, "Ptr*", pIRandomAccessStream:=ComValue(13, 0), "UInt")
        Return pIRandomAccessStream
    }

    ; Converts HBITMAP to SoftwareBitmap. NOTE: SetStretchBltMode HALFTONE breaks this
    ; The optional transform parameter may contain {grayscale, invertcolors}
    static HBitmapToSoftwareBitmap(hBitmap, hDC?, transform?) {
        local bi := Buffer(40, 0), W, H, BitmapBuffer, MemoryBuffer, MemoryBufferReference, BufferByteAccess, BufferSize
        hDC := (hBitmap is OCR.IBase ? hBitmap.DC : (hDC ?? dhDC := DllCall("GetDC", "Ptr", 0, "UPtr")))

        NumPut("uint", 40, bi, 0)
        DllCall("GetDIBits", "ptr", hDC, "ptr", hBitmap, "uint", 0, "uint", 0, "ptr", 0, "ptr", bi, "uint", 0)
        W := NumGet(bi, 4, "int"), H := NumGet(bi, 8, "int")

        ComCall(7, this.SoftwareBitmapFactory, "int", 87, "int", W, "int", H, "int", 0, "ptr*", SoftwareBitmap := ComValue(13,0)) ; CreateWithAlpha: Bgra8 & Premultiplied
        ComCall(15, SoftwareBitmap, "int", 2, "ptr*", &BitmapBuffer := 0) ; LockBuffer
        MemoryBuffer := ComObjQuery(BitmapBuffer, "{fbc4dd2a-245b-11e4-af98-689423260cf8}")
        ComCall(6, MemoryBuffer, "ptr*", &MemoryBufferReference := 0) ; CreateReference
        BufferByteAccess := ComObjQuery(MemoryBufferReference, "{5b0d3235-4dba-4d44-865e-8f1d0e4fd04d}")
        ComCall(3, BufferByteAccess, "ptr*", &SoftwareBitmapByteBuffer:=0, "uint*", &BufferSize:=0) ; GetBuffer

        NumPut("short", 32, "short", 0, bi, 14), NumPut("int", -H, bi, 8) ; Negative height to get correctly oriented image
        DllCall("GetDIBits", "ptr", hDC, "ptr", hBitmap, "uint", 0, "uint", H, "ptr", SoftwareBitmapByteBuffer, "ptr", bi, "uint", 0)
        if IsSet(transform) {
            if (transform.HasProp("grayscale") && transform.grayscale)
                DllCall(this.GrayScaleMCode, "ptr", SoftwareBitmapByteBuffer, "uint", w, "uint", h, "uint", (w*4+3) // 4 * 4, "cdecl uint")
            if (transform.HasProp("monochrome") && transform.monochrome)
                DllCall(this.MonochromeMCode, "ptr", SoftwareBitmapByteBuffer, "uint", w, "uint", h, "uint", (w*4+3) // 4 * 4, "uint", transform.monochrome, "cdecl uint")
            if (transform.HasProp("invertcolors") && transform.invertcolors)
                DllCall(this.InvertColorsMCode, "ptr", SoftwareBitmapByteBuffer, "uint", w, "uint", h, "uint", (w*4+3) // 4 * 4, "cdecl uint")
        }
        
        if IsSet(dhDC)
            DllCall("DeleteDC", "ptr", dhDC)
        if BufferByteAccess.HasMethod("Dispose")
            BufferByteAccess.Dispose()
        if MemoryBuffer.HasMethod("Dispose")
            MemoryBuffer.Dispose()
        BufferByteAccess := "", ObjRelease(MemoryBufferReference), MemoryBuffer := "", ObjRelease(BitmapBuffer) ; Release in correct order

        return SoftwareBitmap
    }

    static MCode(mcode) {
        static e := Map('1', 4, '2', 1), c := (A_PtrSize=8) ? "x64" : "x86"
        if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", &m))
          return
        if (!DllCall("crypt32\CryptStringToBinary", "str", m.3, "uint", 0, "uint", e[m.1], "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0))
          return
        p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
        if (c="x64")
          DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", &op := 0)
        if (DllCall("crypt32\CryptStringToBinary", "str", m.3, "uint", 0, "uint", e[m.1], "ptr", p, "uint*", &s, "ptr", 0, "ptr", 0))
          return p
        DllCall("GlobalFree", "ptr", p)
      }

    static DisplayHBitmap(hBitmap) {
        local gImage := Gui("-DPIScale"), W, H
        , hPic := gImage.Add("Text", "0xE w640 h640")
        SendMessage(0x172, 0, hBitmap,, hPic.hWnd)
        hPic.GetPos(,,&W, &H)
        gImage.Show("w" (W+20) " H" (H+20))
        WinWaitClose gImage
    }

    static SoftwareBitmapToRandomAccessStream(SoftwareBitmap) {
        InMemoryRandomAccessStream := this.CreateClass("Windows.Storage.Streams.InMemoryRandomAccessStream")
        ComCall(8, this.BitmapEncoderStatics, "ptr", encoderId := Buffer(16, 0)) ; IBitmapEncoderStatics::PngEncoderId
        ComCall(13, this.BitmapEncoderStatics, "ptr", encoderId, "ptr", InMemoryRandomAccessStream, "ptr*", BitmapEncoder:=ComValue(13,0)) ; IBitmapEncoderStatics::CreateAsync
        this.WaitForAsync(&BitmapEncoder)
        BitmapEncoderWithSoftwareBitmap := ComObjQuery(BitmapEncoder, "{686cd241-4330-4c77-ace4-0334968b1768}")
        ComCall(6, BitmapEncoderWithSoftwareBitmap, "ptr", SoftwareBitmap) ; SetSoftwareBitmap
        ComCall(19, BitmapEncoder, "ptr*", asyncAction:=ComValue(13,0)) ; FlushAsync
        this.WaitForAsync(&asyncAction)
        ComCall(11, InMemoryRandomAccessStream, "int64", 0) ; Seek to beginning
        return InMemoryRandomAccessStream
    }

    static CreateClass(str, interface?) {
        local hString := this.CreateHString(str), result
        if !IsSet(interface) {
            result := DllCall("Combase.dll\RoActivateInstance", "ptr", hString, "ptr*", cls:=ComValue(13, 0), "uint")
        } else {
            GUID := this.CLSIDFromString(interface)
            result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", GUID, "ptr*", cls:=ComValue(13, 0), "uint")
        }
        if (result != 0) {
            if (result = 0x80004002)
                throw Error("No such interface supported", -1, interface)
            else if (result = 0x80040154)
                throw Error("Class not registered", -1)
            else
                throw Error(result)
        }
        this.DeleteHString(hString)
        return cls
    }
    
    static CreateHString(str) => (DllCall("Combase.dll\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hString:=0), hString)
    
    static DeleteHString(hString) => DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
    
    static WaitForAsync(&obj) {
        local AsyncInfo := ComObjQuery(obj, this.IID_IAsyncInfo), status, ErrorCode
        Loop {
            ComCall(7, AsyncInfo, "uint*", &status:=0)   ; IAsyncInfo.Status
            if (status != 0) {
                if (status != 1) {
                    ComCall(8, ASyncInfo, "uint*", &ErrorCode:=0)   ; IAsyncInfo.ErrorCode
                    throw Error("AsyncInfo failed with status error " ErrorCode, -1)
                }
                break
            }
            Sleep this.PerformanceMode ? -1 : 0
        }
        ComCall(8, obj, "ptr*", ObjectResult:=this.IBase())   ; GetResults
        obj := ObjectResult
    }

    static CloseIClosable(pClosable) {
        static IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}"
        local Close := ComObjQuery(pClosable, IClosable)
        ComCall(6, Close)   ; Close
    }

    static CLSIDFromString(IID) {
        local CLSID := Buffer(16), res
        if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
           throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
        Return CLSID
    }

    static NormalizeCoordinates(result, scale, x:=0, y:=0) {
        local word
        if (scale == 1 && x == 0 && y == 0)
            return result
        for word in result.Words
            word.x := Integer(word.x / scale)+x, word.y := Integer(word.y / scale)+y, word.w := Integer(word.w / scale), word.h := Integer(word.h / scale), word.BoundingRect := {X:word.x, Y:word.y, W:word.w, H:word.h}
        return result
    }
    
    static __OpenPdfDocument(IRandomAccessStream, Password:="") {
        PdfDocumentStatics := this.CreateClass("Windows.Data.Pdf.PdfDocument", this.IID_IPdfDocumentStatics)
        ComCall(8, PdfDocumentStatics, "ptr", IRandomAccessStream, "ptr*", PdfDocument:=ComValue(13, 0)) ; LoadFromStreamAsync
        this.WaitForAsync(&PdfDocument)
        return PdfDocument
    }

    static __ExtractNamedParameters(obj, params*) {
        local i := 0
        if !IsObject(obj) || Type(obj) != "Object"
            return 0
        Loop params.Length // 2 {
            name := params[++i], value := params[++i]
            if obj.HasProp(name)
                %value% := obj.%name%
        }
        return 1
    }

    static __ExtractTransformParameters(obj, &transform) {
        local scale := 1, grayscale := 0, invertcolors := 0, monochrome := 0, rotate := 0, flip := 0
        if IsObject(obj)
            this.__ExtractNamedParameters(obj, "scale", &scale, "grayscale", &grayscale, "invertcolors", &invertcolors, "monochrome", &monochrome, "rotate", &rotate, "flip", &flip, "transform", &transform)

        if IsSet(transform) && IsObject(transform) {
            for prop in ["scale", "grayscale", "invertcolors", "monochrome", "rotate", "flip"]
                if !transform.HasProp(prop)
                    transform.%prop% := %prop%
        } else
            transform := {scale:scale, grayscale:grayscale, invertcolors:invertcolors, monochrome:monochrome, rotate:rotate, flip:flip}
    
        transform.flip := transform.flip = "y" ? 1 : transform.flip = "x" ? 2 : transform.flip
    }

    static __DeleteProps(obj, props*) {
        if IsObject(obj)
            for prop in props
                obj.DeleteProp(prop)
    }

    /**
     * Converts coordinates between screen, window and client.
     * @param X X-coordinate to convert
     * @param Y Y-coordinate to convert
     * @param outX Variable where to store the converted X-coordinate
     * @param outY Variable where to store the converted Y-coordinate
     * @param relativeFrom CoordMode where to convert from. Default is A_CoordModeMouse.
     * @param relativeTo CoordMode where to convert to. Default is Screen.
     * @param winTitle A window title or other criteria identifying the target window. 
     * @param winText If present, this parameter must be a substring from a single text element of the target window.
     * @param excludeTitle Windows whose titles include this value will not be considered.
     * @param excludeText Windows whose text include this value will not be considered.
     */
    static ConvertWinPos(X, Y, &outX, &outY, relativeFrom:="", relativeTo:="screen", winTitle?, winText?, excludeTitle?, excludeText?) {
        relativeFrom := relativeFrom || A_CoordModeMouse
        if relativeFrom = relativeTo {
            outX := X, outY := Y
            return
        }
        local hWnd := WinExist(winTitle?, winText?, excludeTitle?, excludeText?)

        switch relativeFrom, 0 {
            case "screen", "s":
                if relativeTo = "window" || relativeTo = "w" {
                    DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
                    outX := X-NumGet(RECT, 0, "Int"), outY := Y-NumGet(RECT, 4, "Int")
                } else { 
                    ; screen to client
                    pt := Buffer(8), NumPut("int",X,pt), NumPut("int",Y,pt,4)
                    DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
                    outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
                }
            case "window", "w":
                ; window to screen
                WinGetPos(&outX, &outY,,,hWnd)
                outX += X, outY += Y
                if relativeTo = "client" || relativeTo = "c" {
                    ; screen to client
                    pt := Buffer(8), NumPut("int",outX,pt), NumPut("int",outY,pt,4)
                    DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
                    outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
                }
            case "client", "c":
                ; client to screen
                pt := Buffer(8), NumPut("int",X,pt), NumPut("int",Y,pt,4)
                DllCall("ClientToScreen", "Int", hWnd, "Ptr", pt)
                outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
                if relativeTo = "window" || relativeTo = "w" { ; screen to window
                    DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
                    outX -= NumGet(RECT, 0, "Int"), outY -= NumGet(RECT, 4, "Int")
                }
        }
    }
}
