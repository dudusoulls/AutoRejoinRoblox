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
VERSION     := "1.3.8"
GITHUB_REPO := "dudusoulls/AutoRejoinRoblox"
GITHUB_BRANCH := "main"
EXE_NAME := "AutoReconnectRoblox.exe"   ; nome do .exe que você sobe na Release (tem que ser EXATAMENTE esse)

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

; ---------------- Relatório de erro (webhook secreto, só pra você) ----------------
; Cole AQUI o seu webhook escondido. O que o usuário mandar na aba "Suporte"
; (mensagem + print, se marcado) cai nesse webhook. Nunca vai IP nem dado pessoal.
; Dica: compile pra .exe pra esse link não ficar à vista no código.
REPORT_WEBHOOK  := ReportUrl()   ; link montado em runtime (escondido) - veja ReportUrl()
netDown         := 0
reportImg       := ""
reactReady      := false
reactBusy       := 0
PANEL_EMO       := [["%E2%96%B6%EF%B8%8F", "play"], ["%E2%8F%B9%EF%B8%8F", "stop"], ["%F0%9F%94%84", "restart"], ["%F0%9F%93%B8", "print"]]

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
    {name: "Rose", BG: "141014", SIDE: "0E0B0E", CARD: "1D171D", INPUT: "282028", TEXT: "F6EDF0", MUTED: "A99AA2", DIM: "6A5D64", ACC: "F2B8C6", ACCH: "E29CAE", BTN: "2D242C", BTNH: "382D37", NAVA: "281F27", NAVH: "1B151B", SWOFF: "352B33"},
    {name: "Marble", BG: "F6F6F8", SIDE: "ECECEF", CARD: "FFFFFF", INPUT: "F0F0F3", TEXT: "1B1B20", MUTED: "63636C", DIM: "9C9CA5", ACC: "2A2A30", ACCH: "45454D", BTN: "E8E8ED", BTNH: "DCDCE2", NAVA: "DEDEE4", NAVH: "E4E4EA", SWOFF: "D4D4DA"},
    {name: "Sakura", BG: "FBF4F6", SIDE: "F3E6EB", CARD: "FFFFFF", INPUT: "FBEEF2", TEXT: "2A1A20", MUTED: "8A6670", DIM: "B89AA2", ACC: "E86A94", ACCH: "D4517E", BTN: "F6E2E9", BTNH: "F0D4DE", NAVA: "F2DCE4", NAVH: "F6E6EC", SWOFF: "EBCCD6"},
    {name: "Mint", BG: "F1F8F4", SIDE: "E2F0E8", CARD: "FFFFFF", INPUT: "ECF6F0", TEXT: "14241C", MUTED: "5E7A6C", DIM: "97B3A5", ACC: "1FA971", ACCH: "16905E", BTN: "DFF0E7", BTNH: "D2E8DB", NAVA: "DAEDE3", NAVH: "E4F3EB", SWOFF: "CCE4D7"},
    {name: "Sky", BG: "F0F5FB", SIDE: "E1EBF5", CARD: "FFFFFF", INPUT: "EBF2FA", TEXT: "151C28", MUTED: "5C6A7E", DIM: "97A6BC", ACC: "2F7FE6", ACCH: "2168C6", BTN: "DEEAF7", BTNH: "D0E0F2", NAVA: "D8E6F5", NAVH: "E3EEFA", SWOFF: "CADCF0"},
    {name: "Sunset", BG: "170F14", SIDE: "100A0E", CARD: "22141D", INPUT: "301C28", TEXT: "FBEDF2", MUTED: "BB8EA0", DIM: "74505E", ACC: "FF6B8A", ACCH: "E84F70", BTN: "3A212D", BTNH: "482A38", NAVA: "331B27", NAVH: "22121B", SWOFF: "44262F"},
    {name: "Grape", BG: "100A1C", SIDE: "0A0613", CARD: "1A1030", INPUT: "251640", TEXT: "EFE9FA", MUTED: "9D8FC2", DIM: "605380", ACC: "9D5CFF", ACCH: "8343E8", BTN: "2B1E4A", BTNH: "36275A", NAVA: "261A42", NAVH: "18102E", SWOFF: "342554"},
    {name: "Carbon", BG: "0A0A0A", SIDE: "050505", CARD: "141414", INPUT: "1E1E1E", TEXT: "F0F0F0", MUTED: "8A8A8A", DIM: "565656", ACC: "E0E0E0", ACCH: "C2C2C2", BTN: "222222", BTNH: "2D2D2D", NAVA: "1A1A1A", NAVH: "111111", SWOFF: "2B2B2B"},
    {name: "Gold", BG: "121008", SIDE: "0C0B05", CARD: "1C1810", INPUT: "282218", TEXT: "F7F2E4", MUTED: "B0A682", DIM: "6E6646", ACC: "E5B84B", ACCH: "CC9F30", BTN: "2E2718", BTNH: "3A3120", NAVA: "272015", NAVH: "18140C", SWOFF: "38301E"},
    {name: "Ocean", BG: "081018", SIDE: "050B11", CARD: "0F1C2A", INPUT: "16283A", TEXT: "E4F0FA", MUTED: "84A0BC", DIM: "4F6880", ACC: "3BA0E6", ACCH: "2B86C6", BTN: "172E42", BTNH: "1F3C54", NAVA: "14293C", NAVH: "0D1B28", SWOFF: "21394F"},
    {name: "Cyber", BG: "0A0812", SIDE: "06040C", CARD: "130F20", INPUT: "1D172F", TEXT: "EAF6FF", MUTED: "8894B8", DIM: "505874", ACC: "22E0D0", ACCH: "14C0B2", BTN: "22203A", BTNH: "2C2948", NAVA: "1C1930", NAVH: "110E1E", SWOFF: "2A2742"}
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
hudBar := 0, hudPan := 0, hudFrame := 0, hudBarDot := 0, hudBarL := 0, hudBarR := 0, hudPanDot := 0, hudPanT := 0, hudPanL := 0
hudLastPos := "", hudLastHw := 0, hudN := 0, hudUserHidden := false, hudShown := false, hudFrameCol := ""
hudSide := 0, hudSideDot := 0, hudSideT := 0, hudSideL := 0
donateGui := 0
donateThenTour := false
asyncReqs := []
botBusy := 0
cpuLast := 0
dayDate := ""
curPage := ""
cover := 0, coverT0 := 0
lastCoinSig := "", lastCoinChange := 0, lastCoinRead := 0
panelLast := 0
botBad := false, farmMode := "", farmWave := "", farmMiss := 0, farmPearls := "", farmPrev := "", farmModeCol := "", farmPearlCol := "", farmDbgT := 0, farmBest := 1, hudColCache := Map()
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
sliderList := [], sliderAct := 0, sliderWas := false
hudLogs := []
hoverCur := 0
bgCtrls  := []
roundQ   := []

DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")

; ---------------- Config ----------------
savedLink     := IniRead(iniFile, "cfg", "link", "")
savedRbxVer   := IniRead(iniFile, "cfg", "rbxVer", "")
savedInterval := IniRead(iniFile, "cfg", "interval", "15")
savedWait     := IniRead(iniFile, "cfg", "wait", "90")
savedHook     := IniRead(iniFile, "cfg", "webhook", "")
savedShrink   := IniRead(iniFile, "cfg", "shrink", "1")
savedMin      := IniRead(iniFile, "cfg", "minBrowser", "1")
savedErr      := IniRead(iniFile, "cfg", "restartOnError", "1")
savedErrSec   := IniRead(iniFile, "cfg", "errSec", "60")
savedZombie   := IniRead(iniFile, "cfg", "killZombie", "1")
noWinSince    := 0
savedRep      := IniRead(iniFile, "cfg", "report", "1")
savedRepMin   := IniRead(iniFile, "cfg", "reportMin", "60")
savedCompact  := IniRead(iniFile, "cfg", "compact", "0")
savedAutoUpd  := IniRead(iniFile, "cfg", "autoUpdate", "0")
savedFastUpd  := IniRead(iniFile, "cfg", "updFast", "1")
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
savedWhReopen := IniRead(iniFile, "cfg", "whReopen", "0")
savedWhDrop   := IniRead(iniFile, "cfg", "whDrop", "1")
savedWhError  := IniRead(iniFile, "cfg", "whError", "1")
savedWhUpdate := IniRead(iniFile, "cfg", "whUpdate", "1")
savedDonate   := IniRead(iniFile, "cfg", "showDonate", "1")
savedLowGfx   := IniRead(iniFile, "cfg", "lowGfx", "1")
savedMute     := IniRead(iniFile, "cfg", "mute", "1")
savedLowPrio  := IniRead(iniFile, "cfg", "lowPrio", "1")
savedBot      := IniRead(iniFile, "cfg", "bot", "0")
savedBotChan  := IniRead(iniFile, "cfg", "botChan", "")
savedPanel    := IniRead(iniFile, "cfg", "panel", "1")
savedPanelMin := IniRead(iniFile, "cfg", "panelMin", "2")
panelMsg      := IniRead(iniFile, "cfg", "panelMsg", "")
panelVia      := IniRead(iniFile, "cfg", "panelVia", "bot")
afkAccum      := Integer(IniRead(iniFile, "afk", "ms", "0"))   ; tempo AFK guardado (só zera quando cai)
savedStuck    := IniRead(iniFile, "cfg", "stuck", "1")
savedStuckMin := IniRead(iniFile, "cfg", "stuckMin", "15")
stuckAct      := Integer(IniRead(iniFile, "cfg", "stuckAct", "0"))
hudMode       := Integer(IniRead(iniFile, "cfg", "hudMode", "1"))      ; 0 desligado, 1 barra, 2 painel
savedFrame    := IniRead(iniFile, "cfg", "frame", "1")
savedHudComp  := IniRead(iniFile, "cfg", "hudCompact", "1")
ANON_ID := IniRead(iniFile, "cfg", "anonId", "")
if (ANON_ID = "") {
    Loop 8
        ANON_ID .= SubStr("0123456789ABCDEF", Random(1, 16), 1)
    IniWrite(ANON_ID, iniFile, "cfg", "anonId")
}
; ---------------- Idiomas (gerado) ----------------
LANG_CODES := ["pt", "en", "es", "fr", "de", "ru", "tr", "id"]
LANG_NAMES := ["Português", "English", "Español", "Français", "Deutsch", "Русский", "Türkçe", "Bahasa Indonesia"]
I18N := Map()
I18N["pt"] := Map(
    "nav_home", "Início",
    "nav_game", "Jogo",
    "nav_window", "Janela",
    "nav_hook", "Conexão",
    "nav_coins", "Moedas",
    "nav_logs", "Logs",
    "nav_about", "Configurações",
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
    "nav_bot", "Bot e comandos",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Painel ao vivo",
    "nav_statusrep", "Relatório",
    "nav_stuck", "Travamento",
    "nav_qol", "QoL",
    "f_reading", "Lendo o modo…",
    "f_prevround", "Rodada anterior",
    "bot_401", "Token inválido (HTTP 401): gere de novo em Bot > Reset Token e cole aqui",
    "f_mode", "Modo de farm",
    "sw_fastupd", "Procurar atualização a cada 30 segundos",
    "sw_fastupd_sub", "Checagem leve: só lê o começo do arquivo",
    "ph_search", "Buscar",
    "hud_panel", "Painel de farm (Status, Moedas e Logs)",
    "hud_welcome", "Bem-vindo, {1}",
    "hud_box_status", "Status",
    "hud_newupd", "Nova atualização disponível",
    "pg_livepanel_sub", "Mensagem que se atualiza sozinha no Discord",
    "pg_statusrep_sub", "Resumo periódico com print da tela",
    "pg_stuck_sub", "Avisa ou reinicia quando as moedas param de mudar",
    "nav_look", "Aparência",
    "pg_look_sub", "Escolha o tema do programa",
    "sec_theme", "TEMA",
    "sec_hud", "HUD NO ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Desligado",
    "hud_bar", "Barra grudada embaixo",
    "hud_overlay", "Painel no canto do jogo",
    "sw_frame", "Moldura colorida em volta do Roblox",
    "sw_frame_sub", "Verde no jogo, amarelo com desconexão, vermelho fechado",
    "sw_hudcompact", "Modo compacto esconde o programa e deixa só o HUD",
    "hud_hint", "Atalhos: Ctrl+Alt+H mostra/esconde o HUD · Ctrl+Alt+S inicia/para · Ctrl+Alt+R reinicia o Roblox · Ctrl+Alt+P manda o status. Clique na barra pra abrir o programa.",
    "nav_report", "Apoie",
    "pg_report_sub", "Apoie o projeto ou me relate um erro",
    "sec_report", "RELATAR PROBLEMA",
    "lbl_report", "Descreva o que aconteceu",
    "sw_report_shot", "Anexar um print do Roblox",
    "btn_report_send", "Enviar relatório",
    "report_sending", "Enviando…",
    "report_sent", "Relatório enviado. Valeu!",
    "report_need_text", "Escreva uma mensagem antes de enviar.",
    "report_nodest", "Envio de relatórios indisponível.",
    "report_fail", "Falha ao enviar ({1}).",
    "report_hint", "Vai junto: versão do app, Windows, nome do PC e seu ID de instalação. Nada de IP ou dados pessoais.",
    "lbl_report_id", "SEU ID DE INSTALAÇÃO",
    "ev_report", "Novo relatório",
    "f_report_user", "Usuário",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "Sistema",
    "f_report_lang", "Idioma",
    "f_report_lic", "Licença",
    "st_net", "Sem internet",
    "st_net_sub", "Esperando a conexão voltar pra reconectar",
    "ev_neterr", "Internet caiu",
    "ev_netok", "Internet voltou",
    "d_net_wait", "Sem conexão — esperando voltar pra reconectar o Roblox.",
    "d_net_back", "Conexão voltou depois de {1}.",
    "log_net_down", "Internet caiu — pausando reconexão.",
    "log_net_back", "Internet voltou — retomando.",
    "ev_chart", "Gráfico (7 dias)",
    "chart_none", "Ainda não tenho histórico pra montar o gráfico.",
    "cmd_chart", "gráfico das moedas/online nos últimos 7 dias",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox não está aberto na tela.",
    "gif_desc", "{1} prints seguidos do jogo.",
    "cmd_gif", "manda vários prints seguidos do jogo",
    "sw_zombie", "Fechar Roblox travado (sem janela) e reabrir",
    "sw_zombie_sub", "O processo fica aberto mas o jogo some — comum em PC fraco",
    "st_zombie", "Roblox travado",
    "st_zombie_sub", "Processo aberto sem janela — fechando e reabrindo",
    "r_zombie", "Roblox travado sem janela (processo fantasma)",
    "lbl_rammin", "RAM mín. (MB)",
    "st_zombie_ram", "RAM baixa — travado",
    "r_zombie_ram", "Roblox com RAM muito baixa ({1} MB) — travado",
    "hud_side", "Painel lateral no Roblox (stats)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Painel grudado na janela do Roblox com os stats",
    "btn_report_img", "Anexar imagem",
    "report_noimg", "Nenhuma imagem anexada",
    "report_img_set", "Imagem: {1}",
    "cmd_panel", "liga e manda o painel ao vivo fixado",
    "btn_killall", "Matar todos os Roblox",
    "log_killed", "Roblox fechado(s) à força.",
    "lbl_rbxver", "Fixar versão do Roblox (vazio = mais nova)",
    "btn_rbxlist", "Ver versões",
    "nav_notif", "O que enviar",
    "pg_notif_sub", "Escolha o que chega no seu webhook",
    "sec_whevents", "O QUE ENVIAR AO WEBHOOK",
    "sw_wh_reopen", "Aberturas e reconexões",
    "sw_wh_reopen_sub", "Avisa quando inicia, para ou reabre o Roblox (a parte que mais enche)",
    "sw_wh_drop", "Quedas",
    "sw_wh_drop_sub", "Avisa quando o Roblox cai ou trava",
    "sw_wh_error", "Erros",
    "sw_wh_error_sub", "Avisa erros de abrir, licença e internet",
    "sw_wh_update", "Atualizações do app",
    "don_title", "Apoie o dev 💜",
    "don_msg", "Esse app é grátis e feito por uma pessoa só. Se ele tá te ajudando a farmar, qualquer Pix ajuda demais a manter o projeto vivo! 🙏",
    "don_pix", "Pix · escaneie o QR acima",
    "don_close", "Fechar",
    "don_never", "Não mostrar mais",
    "sw_donate", "Mostrar apoio ao dev",
    "sw_donate_sub", "Mostra o QR de Pix toda vez que o app abre"
)
I18N["en"] := Map(
    "nav_home", "Home",
    "nav_game", "Game",
    "nav_window", "Window",
    "nav_hook", "Connection",
    "nav_coins", "Currency",
    "nav_logs", "Logs",
    "nav_about", "Settings",
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
    "nav_bot", "Bot and commands",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Live panel",
    "nav_statusrep", "Report",
    "nav_stuck", "Stuck check",
    "nav_qol", "QoL",
    "f_reading", "Reading the mode…",
    "f_prevround", "Previous round",
    "bot_401", "Invalid token (HTTP 401): generate a new one in Bot > Reset Token and paste it here",
    "f_mode", "Farm mode",
    "sw_fastupd", "Check for updates every 30 seconds",
    "sw_fastupd_sub", "Lightweight check: reads only the start of the file",
    "ph_search", "Search",
    "hud_panel", "Farm panel (Status, Coins and Logs)",
    "hud_welcome", "Welcome {1}",
    "hud_box_status", "Status",
    "hud_newupd", "New update available",
    "pg_livepanel_sub", "A message that updates itself on Discord",
    "pg_statusrep_sub", "Periodic summary with a screenshot",
    "pg_stuck_sub", "Alerts or restarts when your coins stop changing",
    "nav_look", "Appearance",
    "pg_look_sub", "Choose the app theme",
    "sec_theme", "THEME",
    "sec_hud", "ROBLOX HUD",
    "hud_mode", "HUD",
    "hud_off", "Off",
    "hud_bar", "Bar docked below",
    "hud_overlay", "Panel in the game corner",
    "sw_frame", "Colored frame around Roblox",
    "sw_frame_sub", "Green in game, yellow on disconnect, red when closed",
    "sw_hudcompact", "Compact mode hides the app and keeps only the HUD",
    "hud_hint", "Shortcuts: Ctrl+Alt+H show/hide HUD · Ctrl+Alt+S start/stop · Ctrl+Alt+R restart Roblox · Ctrl+Alt+P send status. Click the bar to open the app.",
    "nav_report", "Support",
    "pg_report_sub", "Support the project or report a bug to me",
    "sec_report", "REPORT A PROBLEM",
    "lbl_report", "Describe what happened",
    "sw_report_shot", "Attach a Roblox screenshot",
    "btn_report_send", "Send report",
    "report_sending", "Sending…",
    "report_sent", "Report sent. Thanks!",
    "report_need_text", "Write a message before sending.",
    "report_nodest", "Report sending is unavailable.",
    "report_fail", "Failed to send ({1}).",
    "report_hint", "Includes: app version, Windows, PC name and your install ID. No IP or personal data.",
    "lbl_report_id", "YOUR INSTALL ID",
    "ev_report", "New report",
    "f_report_user", "User",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "System",
    "f_report_lang", "Language",
    "f_report_lic", "License",
    "st_net", "No internet",
    "st_net_sub", "Waiting for the connection to come back",
    "ev_neterr", "Internet down",
    "ev_netok", "Internet back",
    "d_net_wait", "No connection — waiting to reconnect Roblox.",
    "d_net_back", "Connection came back after {1}.",
    "log_net_down", "Internet down — pausing reconnect.",
    "log_net_back", "Internet back — resuming.",
    "ev_chart", "Chart (7 days)",
    "chart_none", "No history yet to build the chart.",
    "cmd_chart", "chart of currency/online over the last 7 days",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox isn't open on screen.",
    "gif_desc", "{1} sequential game screenshots.",
    "cmd_gif", "sends several sequential game screenshots",
    "sw_zombie", "Close stuck Roblox (no window) and reopen",
    "sw_zombie_sub", "The process stays open but the game is gone — common on weak PCs",
    "st_zombie", "Roblox stuck",
    "st_zombie_sub", "Process open with no window — closing and reopening",
    "r_zombie", "Roblox stuck with no window (ghost process)",
    "lbl_rammin", "Min RAM (MB)",
    "st_zombie_ram", "Low RAM — stuck",
    "r_zombie_ram", "Roblox with very low RAM ({1} MB) — stuck",
    "hud_side", "Side panel on Roblox (stats)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Panel docked to the Roblox window with stats",
    "btn_report_img", "Attach image",
    "report_noimg", "No image attached",
    "report_img_set", "Image: {1}",
    "cmd_panel", "turns on and posts the pinned live panel",
    "btn_killall", "Kill all Roblox",
    "log_killed", "Roblox force-closed.",
    "lbl_rbxver", "Pin Roblox version (empty = newest)",
    "btn_rbxlist", "List versions",
    "nav_notif", "What to send",
    "pg_notif_sub", "Choose what reaches your webhook",
    "sec_whevents", "WHAT TO SEND TO THE WEBHOOK",
    "sw_wh_reopen", "Starts and reconnects",
    "sw_wh_reopen_sub", "Notifies when it starts, stops or reopens Roblox (the chattiest part)",
    "sw_wh_drop", "Drops",
    "sw_wh_drop_sub", "Notifies when Roblox drops or freezes",
    "sw_wh_error", "Errors",
    "sw_wh_error_sub", "Notifies launch, license and internet errors",
    "sw_wh_update", "App updates",
    "don_title", "Support the dev 💜",
    "don_msg", "This app is free and made by one person. If it's helping you farm, any tip helps keep the project alive! 🙏",
    "don_pix", "Scan the QR above",
    "don_close", "Close",
    "don_never", "Don't show again",
    "sw_donate", "Show support-the-dev",
    "sw_donate_sub", "Shows the Pix QR every time the app opens"
)
I18N["es"] := Map(
    "nav_home", "Inicio",
    "nav_game", "Juego",
    "nav_window", "Ventana",
    "nav_hook", "Conexión",
    "nav_coins", "Monedas",
    "nav_logs", "Registros",
    "nav_about", "Ajustes",
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
    "nav_bot", "Bot y comandos",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Panel en vivo",
    "nav_statusrep", "Informe",
    "nav_stuck", "Detección de bloqueo",
    "nav_qol", "QoL",
    "f_reading", "Leyendo el modo…",
    "f_prevround", "Ronda anterior",
    "bot_401", "Token inválido (HTTP 401): genera otro en Bot > Reset Token y pégalo aquí",
    "f_mode", "Modo de farmeo",
    "sw_fastupd", "Buscar actualizaciones cada 30 segundos",
    "sw_fastupd_sub", "Chequeo ligero: solo lee el inicio del archivo",
    "ph_search", "Buscar",
    "hud_panel", "Panel de farmeo (Estado, Monedas y Logs)",
    "hud_welcome", "Bienvenido, {1}",
    "hud_box_status", "Estado",
    "hud_newupd", "Nueva actualización disponible",
    "pg_livepanel_sub", "Un mensaje que se actualiza solo en Discord",
    "pg_statusrep_sub", "Resumen periódico con captura",
    "pg_stuck_sub", "Avisa o reinicia cuando las monedas dejan de cambiar",
    "nav_look", "Apariencia",
    "pg_look_sub", "Elige el tema del programa",
    "sec_theme", "TEMA",
    "sec_hud", "HUD EN ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Apagado",
    "hud_bar", "Barra pegada abajo",
    "hud_overlay", "Panel en la esquina del juego",
    "sw_frame", "Marco de color alrededor de Roblox",
    "sw_frame_sub", "Verde en el juego, amarillo con desconexión, rojo cerrado",
    "sw_hudcompact", "El modo compacto oculta el programa y deja solo el HUD",
    "hud_hint", "Atajos: Ctrl+Alt+H muestra/oculta el HUD · Ctrl+Alt+S inicia/detiene · Ctrl+Alt+R reinicia Roblox · Ctrl+Alt+P envía el estado. Clic en la barra para abrir el programa.",
    "nav_report", "Soporte",
    "pg_report_sub", "Apoya el proyecto o repórtame un error",
    "sec_report", "REPORTAR PROBLEMA",
    "lbl_report", "Describe lo que pasó",
    "sw_report_shot", "Adjuntar una captura de Roblox",
    "btn_report_send", "Enviar reporte",
    "report_sending", "Enviando…",
    "report_sent", "¡Reporte enviado. Gracias!",
    "report_need_text", "Escribe un mensaje antes de enviar.",
    "report_nodest", "Envío de reportes no disponible.",
    "report_fail", "Error al enviar ({1}).",
    "report_hint", "Incluye: versión de la app, Windows, nombre del PC y tu ID de instalación. Sin IP ni datos personales.",
    "lbl_report_id", "TU ID DE INSTALACIÓN",
    "ev_report", "Nuevo reporte",
    "f_report_user", "Usuario",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "Sistema",
    "f_report_lang", "Idioma",
    "f_report_lic", "Licencia",
    "st_net", "Sin internet",
    "st_net_sub", "Esperando que vuelva la conexión",
    "ev_neterr", "Internet caído",
    "ev_netok", "Internet restablecido",
    "d_net_wait", "Sin conexión — esperando para reconectar Roblox.",
    "d_net_back", "La conexión volvió tras {1}.",
    "log_net_down", "Internet caído — pausando reconexión.",
    "log_net_back", "Internet restablecido — reanudando.",
    "ev_chart", "Gráfico (7 días)",
    "chart_none", "Aún no hay historial para el gráfico.",
    "cmd_chart", "gráfico de monedas/online de los últimos 7 días",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox no está abierto en pantalla.",
    "gif_desc", "{1} capturas seguidas del juego.",
    "cmd_gif", "envía varias capturas seguidas del juego",
    "sw_zombie", "Cerrar Roblox atascado (sin ventana) y reabrir",
    "sw_zombie_sub", "El proceso queda abierto pero el juego desaparece — común en PC débil",
    "st_zombie", "Roblox atascado",
    "st_zombie_sub", "Proceso abierto sin ventana — cerrando y reabriendo",
    "r_zombie", "Roblox atascado sin ventana (proceso fantasma)",
    "lbl_rammin", "RAM mín. (MB)",
    "st_zombie_ram", "RAM baja — atascado",
    "r_zombie_ram", "Roblox con RAM muy baja ({1} MB) — atascado",
    "hud_side", "Panel lateral en Roblox (stats)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Panel pegado a la ventana de Roblox con stats",
    "btn_report_img", "Adjuntar imagen",
    "report_noimg", "Sin imagen adjunta",
    "report_img_set", "Imagen: {1}",
    "cmd_panel", "activa y envía el panel en vivo fijado",
    "btn_killall", "Cerrar todos los Roblox",
    "log_killed", "Roblox cerrado(s) a la fuerza.",
    "lbl_rbxver", "Fijar versión de Roblox (vacío = más nueva)",
    "btn_rbxlist", "Ver versiones",
    "nav_notif", "Qué enviar",
    "pg_notif_sub", "Elige qué llega a tu webhook",
    "sec_whevents", "QUÉ ENVIAR AL WEBHOOK",
    "sw_wh_reopen", "Aperturas y reconexiones",
    "sw_wh_reopen_sub", "Avisa cuando inicia, para o reabre Roblox (lo que más satura)",
    "sw_wh_drop", "Caídas",
    "sw_wh_drop_sub", "Avisa cuando Roblox se cae o se traba",
    "sw_wh_error", "Errores",
    "sw_wh_error_sub", "Avisa errores de apertura, licencia e internet",
    "sw_wh_update", "Actualizaciones de la app",
    "don_title", "Apoya al dev 💜",
    "don_msg", "Esta app es gratis y hecha por una sola persona. Si te ayuda, cualquier aporte mantiene vivo el proyecto. 🙏",
    "don_pix", "Pix · escanea el QR de arriba",
    "don_close", "Cerrar",
    "don_never", "No mostrar más",
    "sw_donate", "Mostrar apoyo al dev",
    "sw_donate_sub", "Muestra el QR de Pix cada vez que abres la app"
)
I18N["fr"] := Map(
    "nav_home", "Accueil",
    "nav_game", "Jeu",
    "nav_window", "Fenêtre",
    "nav_hook", "Connexion",
    "nav_coins", "Monnaies",
    "nav_logs", "Journal",
    "nav_about", "Paramètres",
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
    "nav_bot", "Bot et commandes",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Panneau en direct",
    "nav_statusrep", "Rapport",
    "nav_stuck", "Blocage",
    "nav_qol", "QoL",
    "f_reading", "Lecture du mode…",
    "f_prevround", "Manche précédente",
    "bot_401", "Token invalide (HTTP 401) : régénère-le dans Bot > Reset Token et colle-le ici",
    "f_mode", "Mode de farm",
    "sw_fastupd", "Chercher une mise à jour toutes les 30 secondes",
    "sw_fastupd_sub", "Vérification légère : lit seulement le début du fichier",
    "ph_search", "Rechercher",
    "hud_panel", "Panneau de farm (Statut, Pièces et Logs)",
    "hud_welcome", "Bienvenue, {1}",
    "hud_box_status", "Statut",
    "hud_newupd", "Nouvelle mise à jour disponible",
    "pg_livepanel_sub", "Un message qui se met à jour seul sur Discord",
    "pg_statusrep_sub", "Résumé périodique avec capture",
    "pg_stuck_sub", "Alerte ou redémarre quand les pièces ne bougent plus",
    "nav_look", "Apparence",
    "pg_look_sub", "Choisissez le thème",
    "sec_theme", "THÈME",
    "sec_hud", "HUD SUR ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Désactivé",
    "hud_bar", "Barre collée en bas",
    "hud_overlay", "Panneau dans le coin du jeu",
    "sw_frame", "Cadre coloré autour de Roblox",
    "sw_frame_sub", "Vert en jeu, jaune en cas de déconnexion, rouge fermé",
    "sw_hudcompact", "Le mode compact masque l'appli et garde seulement le HUD",
    "hud_hint", "Raccourcis : Ctrl+Alt+H afficher/masquer le HUD · Ctrl+Alt+S démarrer/arrêter · Ctrl+Alt+R redémarrer Roblox · Ctrl+Alt+P envoyer le statut. Cliquez sur la barre pour ouvrir l'appli.",
    "nav_report", "Support",
    "pg_report_sub", "Soutiens le projet ou signale-moi un bug",
    "sec_report", "SIGNALER UN PROBLÈME",
    "lbl_report", "Décrivez ce qui s'est passé",
    "sw_report_shot", "Joindre une capture de Roblox",
    "btn_report_send", "Envoyer le rapport",
    "report_sending", "Envoi…",
    "report_sent", "Rapport envoyé. Merci !",
    "report_need_text", "Écrivez un message avant d'envoyer.",
    "report_nodest", "Envoi de rapports indisponible.",
    "report_fail", "Échec de l'envoi ({1}).",
    "report_hint", "Inclut : version de l'appli, Windows, nom du PC et votre ID d'installation. Pas d'IP ni de données personnelles.",
    "lbl_report_id", "VOTRE ID D'INSTALLATION",
    "ev_report", "Nouveau rapport",
    "f_report_user", "Utilisateur",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "Système",
    "f_report_lang", "Langue",
    "f_report_lic", "Licence",
    "st_net", "Pas d'internet",
    "st_net_sub", "En attente du retour de la connexion",
    "ev_neterr", "Internet coupé",
    "ev_netok", "Internet rétabli",
    "d_net_wait", "Pas de connexion — en attente pour reconnecter Roblox.",
    "d_net_back", "La connexion est revenue après {1}.",
    "log_net_down", "Internet coupé — pause de la reconnexion.",
    "log_net_back", "Internet rétabli — reprise.",
    "ev_chart", "Graphique (7 jours)",
    "chart_none", "Pas encore d'historique pour le graphique.",
    "cmd_chart", "graphique monnaies/en ligne sur 7 jours",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox n'est pas ouvert à l'écran.",
    "gif_desc", "{1} captures du jeu à la suite.",
    "cmd_gif", "envoie plusieurs captures du jeu",
    "sw_zombie", "Fermer Roblox bloqué (sans fenêtre) et rouvrir",
    "sw_zombie_sub", "Le processus reste ouvert mais le jeu a disparu — fréquent sur PC faible",
    "st_zombie", "Roblox bloqué",
    "st_zombie_sub", "Processus ouvert sans fenêtre — fermeture et réouverture",
    "r_zombie", "Roblox bloqué sans fenêtre (processus fantôme)",
    "lbl_rammin", "RAM min (Mo)",
    "st_zombie_ram", "RAM basse — bloqué",
    "r_zombie_ram", "Roblox avec très peu de RAM ({1} Mo) — bloqué",
    "hud_side", "Panneau latéral sur Roblox (stats)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Panneau collé à la fenêtre Roblox avec les stats",
    "btn_report_img", "Joindre une image",
    "report_noimg", "Aucune image jointe",
    "report_img_set", "Image : {1}",
    "cmd_panel", "active et envoie le panneau en direct épinglé",
    "btn_killall", "Tuer tous les Roblox",
    "log_killed", "Roblox fermé(s) de force.",
    "lbl_rbxver", "Fixer la version Roblox (vide = la plus récente)",
    "btn_rbxlist", "Voir les versions",
    "nav_notif", "Quoi envoyer",
    "pg_notif_sub", "Choisissez ce qui arrive sur votre webhook",
    "sec_whevents", "QUOI ENVOYER AU WEBHOOK",
    "sw_wh_reopen", "Démarrages et reconnexions",
    "sw_wh_reopen_sub", "Prévient au démarrage, arrêt ou réouverture (le plus bavard)",
    "sw_wh_drop", "Déconnexions",
    "sw_wh_drop_sub", "Prévient quand Roblox déconnecte ou gèle",
    "sw_wh_error", "Erreurs",
    "sw_wh_error_sub", "Prévient les erreurs de lancement, licence et internet",
    "sw_wh_update", "Mises à jour de l'app",
    "don_title", "Soutiens le dev 💜",
    "don_msg", "Cette appli est gratuite et faite par une seule personne. Si elle t'aide, chaque don garde le projet en vie ! 🙏",
    "don_pix", "Scanne le QR ci-dessus",
    "don_close", "Fermer",
    "don_never", "Ne plus afficher",
    "sw_donate", "Afficher le soutien au dev",
    "sw_donate_sub", "Affiche le QR Pix à chaque ouverture"
)
I18N["de"] := Map(
    "nav_home", "Start",
    "nav_game", "Spiel",
    "nav_window", "Fenster",
    "nav_hook", "Verbindung",
    "nav_coins", "Währungen",
    "nav_logs", "Protokoll",
    "nav_about", "Einstellungen",
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
    "nav_bot", "Bot und Befehle",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Live-Panel",
    "nav_statusrep", "Bericht",
    "nav_stuck", "Hänger",
    "nav_qol", "QoL",
    "f_reading", "Modus wird gelesen…",
    "f_prevround", "Vorherige Runde",
    "bot_401", "Ungültiger Token (HTTP 401): in Bot > Reset Token neu erzeugen und hier einfügen",
    "f_mode", "Farm-Modus",
    "sw_fastupd", "Alle 30 Sekunden nach Updates suchen",
    "sw_fastupd_sub", "Leichte Prüfung: liest nur den Dateianfang",
    "ph_search", "Suchen",
    "hud_panel", "Farm-Panel (Status, Münzen und Logs)",
    "hud_welcome", "Willkommen, {1}",
    "hud_box_status", "Status",
    "hud_newupd", "Neues Update verfügbar",
    "pg_livepanel_sub", "Eine Nachricht, die sich selbst auf Discord aktualisiert",
    "pg_statusrep_sub", "Regelmäßige Zusammenfassung mit Screenshot",
    "pg_stuck_sub", "Warnt oder startet neu, wenn sich die Münzen nicht mehr ändern",
    "nav_look", "Darstellung",
    "pg_look_sub", "Wähle das Design",
    "sec_theme", "DESIGN",
    "sec_hud", "HUD IN ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Aus",
    "hud_bar", "Leiste unten angedockt",
    "hud_overlay", "Panel in der Spielecke",
    "sw_frame", "Farbiger Rahmen um Roblox",
    "sw_frame_sub", "Grün im Spiel, gelb bei Abbruch, rot wenn geschlossen",
    "sw_hudcompact", "Kompaktmodus blendet das Programm aus und lässt nur das HUD",
    "hud_hint", "Kürzel: Strg+Alt+H HUD ein/aus · Strg+Alt+S Start/Stopp · Strg+Alt+R Roblox neu starten · Strg+Alt+P Status senden. Klick auf die Leiste öffnet das Programm.",
    "nav_report", "Support",
    "pg_report_sub", "Unterstütze das Projekt oder melde einen Fehler",
    "sec_report", "PROBLEM MELDEN",
    "lbl_report", "Beschreibe, was passiert ist",
    "sw_report_shot", "Roblox-Screenshot anhängen",
    "btn_report_send", "Bericht senden",
    "report_sending", "Senden…",
    "report_sent", "Bericht gesendet. Danke!",
    "report_need_text", "Schreibe eine Nachricht vor dem Senden.",
    "report_nodest", "Berichtversand nicht verfügbar.",
    "report_fail", "Senden fehlgeschlagen ({1}).",
    "report_hint", "Enthält: App-Version, Windows, PC-Name und deine Installations-ID. Keine IP oder persönlichen Daten.",
    "lbl_report_id", "DEINE INSTALLATIONS-ID",
    "ev_report", "Neuer Bericht",
    "f_report_user", "Benutzer",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "System",
    "f_report_lang", "Sprache",
    "f_report_lic", "Lizenz",
    "st_net", "Kein Internet",
    "st_net_sub", "Warte auf die Rückkehr der Verbindung",
    "ev_neterr", "Internet weg",
    "ev_netok", "Internet zurück",
    "d_net_wait", "Keine Verbindung — warte, um Roblox neu zu verbinden.",
    "d_net_back", "Verbindung nach {1} zurück.",
    "log_net_down", "Internet weg — Reconnect pausiert.",
    "log_net_back", "Internet zurück — fortsetzen.",
    "ev_chart", "Diagramm (7 Tage)",
    "chart_none", "Noch kein Verlauf für das Diagramm.",
    "cmd_chart", "Diagramm Währung/Online der letzten 7 Tage",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox ist nicht am Bildschirm offen.",
    "gif_desc", "{1} aufeinanderfolgende Spiel-Screenshots.",
    "cmd_gif", "sendet mehrere Spiel-Screenshots",
    "sw_zombie", "Hängendes Roblox (ohne Fenster) schließen und neu öffnen",
    "sw_zombie_sub", "Der Prozess bleibt offen, aber das Spiel ist weg — häufig auf schwachen PCs",
    "st_zombie", "Roblox hängt",
    "st_zombie_sub", "Prozess offen ohne Fenster — schließen und neu öffnen",
    "r_zombie", "Roblox hängt ohne Fenster (Geisterprozess)",
    "lbl_rammin", "Min. RAM (MB)",
    "st_zombie_ram", "Wenig RAM — hängt",
    "r_zombie_ram", "Roblox mit sehr wenig RAM ({1} MB) — hängt",
    "hud_side", "Seitenpanel an Roblox (Stats)",
    "nav_hud", "HUD",
    "pg_hud_sub", "An das Roblox-Fenster angedocktes Panel mit Stats",
    "btn_report_img", "Bild anhängen",
    "report_noimg", "Kein Bild angehängt",
    "report_img_set", "Bild: {1}",
    "cmd_panel", "aktiviert und sendet das angepinnte Live-Panel",
    "btn_killall", "Alle Roblox beenden",
    "log_killed", "Roblox zwangsweise geschlossen.",
    "lbl_rbxver", "Roblox-Version festlegen (leer = neueste)",
    "btn_rbxlist", "Versionen anzeigen",
    "nav_notif", "Was senden",
    "pg_notif_sub", "Wähle, was deinen Webhook erreicht",
    "sec_whevents", "WAS AN DEN WEBHOOK SENDEN",
    "sw_wh_reopen", "Starts und Reconnects",
    "sw_wh_reopen_sub", "Meldet Start, Stopp oder Neuöffnen (am gesprächigsten)",
    "sw_wh_drop", "Abstürze",
    "sw_wh_drop_sub", "Meldet, wenn Roblox abstürzt oder hängt",
    "sw_wh_error", "Fehler",
    "sw_wh_error_sub", "Meldet Start-, Lizenz- und Internetfehler",
    "sw_wh_update", "App-Updates",
    "don_title", "Unterstütze den Dev 💜",
    "don_msg", "Diese App ist kostenlos und von einer Person. Wenn sie dir hilft, hält jede Spende das Projekt am Leben! 🙏",
    "don_pix", "Scanne den QR oben",
    "don_close", "Schließen",
    "don_never", "Nicht mehr zeigen",
    "sw_donate", "Dev-Unterstützung zeigen",
    "sw_donate_sub", "Zeigt den Pix-QR bei jedem Öffnen"
)
I18N["ru"] := Map(
    "nav_home", "Главная",
    "nav_game", "Игра",
    "nav_window", "Окно",
    "nav_hook", "Подключение",
    "nav_coins", "Валюта",
    "nav_logs", "Журнал",
    "nav_about", "Настройки",
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
    "nav_bot", "Бот и команды",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Живая панель",
    "nav_statusrep", "Отчёт",
    "nav_stuck", "Зависание",
    "nav_qol", "QoL",
    "f_reading", "Чтение режима…",
    "f_prevround", "Прошлый раунд",
    "bot_401", "Неверный токен (HTTP 401): создай новый в Bot > Reset Token и вставь сюда",
    "f_mode", "Режим фарма",
    "sw_fastupd", "Проверять обновления каждые 30 секунд",
    "sw_fastupd_sub", "Лёгкая проверка: читает только начало файла",
    "ph_search", "Поиск",
    "hud_panel", "Панель фарма (статус, монеты, логи)",
    "hud_welcome", "Привет, {1}",
    "hud_box_status", "Статус",
    "hud_newupd", "Доступно обновление",
    "pg_livepanel_sub", "Сообщение в Discord, которое обновляется само",
    "pg_statusrep_sub", "Периодическая сводка со скриншотом",
    "pg_stuck_sub", "Предупреждает или перезапускает, когда монеты не меняются",
    "nav_look", "Оформление",
    "pg_look_sub", "Выберите тему",
    "sec_theme", "ТЕМА",
    "sec_hud", "HUD В ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Выключен",
    "hud_bar", "Панель снизу окна",
    "hud_overlay", "Панель в углу игры",
    "sw_frame", "Цветная рамка вокруг Roblox",
    "sw_frame_sub", "Зелёная в игре, жёлтая при отключении, красная если закрыт",
    "sw_hudcompact", "Компактный режим прячет программу и оставляет только HUD",
    "hud_hint", "Горячие клавиши: Ctrl+Alt+H HUD · Ctrl+Alt+S старт/стоп · Ctrl+Alt+R перезапуск Roblox · Ctrl+Alt+P отправить статус. Клик по панели открывает программу.",
    "nav_report", "Поддержка",
    "pg_report_sub", "Поддержите проект или сообщите об ошибке",
    "sec_report", "СООБЩИТЬ О ПРОБЛЕМЕ",
    "lbl_report", "Опишите, что произошло",
    "sw_report_shot", "Приложить скриншот Roblox",
    "btn_report_send", "Отправить отчёт",
    "report_sending", "Отправка…",
    "report_sent", "Отчёт отправлен. Спасибо!",
    "report_need_text", "Напишите сообщение перед отправкой.",
    "report_nodest", "Отправка отчётов недоступна.",
    "report_fail", "Не удалось отправить ({1}).",
    "report_hint", "Включает: версию приложения, Windows, имя ПК и ваш ID установки. Без IP и личных данных.",
    "lbl_report_id", "ВАШ ID УСТАНОВКИ",
    "ev_report", "Новый отчёт",
    "f_report_user", "Пользователь",
    "f_report_pc", "ПК",
    "f_report_id", "ID",
    "f_report_os", "Система",
    "f_report_lang", "Язык",
    "f_report_lic", "Лицензия",
    "st_net", "Нет интернета",
    "st_net_sub", "Ожидание восстановления соединения",
    "ev_neterr", "Интернет пропал",
    "ev_netok", "Интернет вернулся",
    "d_net_wait", "Нет соединения — ждём, чтобы переподключить Roblox.",
    "d_net_back", "Соединение восстановилось через {1}.",
    "log_net_down", "Интернет пропал — пауза переподключения.",
    "log_net_back", "Интернет вернулся — продолжаем.",
    "ev_chart", "График (7 дней)",
    "chart_none", "Пока нет истории для графика.",
    "cmd_chart", "график валюты/онлайна за 7 дней",
    "ev_gif", "Таймлапс",
    "gif_none", "Roblox не открыт на экране.",
    "gif_desc", "{1} последовательных скриншота игры.",
    "cmd_gif", "отправляет несколько скриншотов игры",
    "sw_zombie", "Закрыть зависший Roblox (без окна) и открыть заново",
    "sw_zombie_sub", "Процесс остаётся, но игра пропала — часто на слабых ПК",
    "st_zombie", "Roblox завис",
    "st_zombie_sub", "Процесс без окна — закрываем и открываем",
    "r_zombie", "Roblox завис без окна (процесс-призрак)",
    "lbl_rammin", "Мин. ОЗУ (МБ)",
    "st_zombie_ram", "Мало ОЗУ — завис",
    "r_zombie_ram", "Roblox с очень малым ОЗУ ({1} МБ) — завис",
    "hud_side", "Боковая панель на Roblox (статы)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Панель у окна Roblox со статами",
    "btn_report_img", "Прикрепить изображение",
    "report_noimg", "Изображение не прикреплено",
    "report_img_set", "Изображение: {1}",
    "cmd_panel", "включает и отправляет закреплённую живую панель",
    "btn_killall", "Закрыть все Roblox",
    "log_killed", "Roblox принудительно закрыт.",
    "lbl_rbxver", "Закрепить версию Roblox (пусто = новейшая)",
    "btn_rbxlist", "Список версий",
    "nav_notif", "Что отправлять",
    "pg_notif_sub", "Выберите, что приходит в вебхук",
    "sec_whevents", "ЧТО ОТПРАВЛЯТЬ В ВЕБХУК",
    "sw_wh_reopen", "Запуски и переподключения",
    "sw_wh_reopen_sub", "Сообщает о запуске, остановке и переоткрытии (самое частое)",
    "sw_wh_drop", "Разрывы",
    "sw_wh_drop_sub", "Сообщает о вылете или зависании Roblox",
    "sw_wh_error", "Ошибки",
    "sw_wh_error_sub", "Сообщает об ошибках запуска, лицензии и интернета",
    "sw_wh_update", "Обновления приложения",
    "don_title", "Поддержи разработчика 💜",
    "don_msg", "Это приложение бесплатное и сделано одним человеком. Любая поддержка помогает проекту жить! 🙏",
    "don_pix", "Отсканируйте QR выше",
    "don_close", "Закрыть",
    "don_never", "Больше не показывать",
    "sw_donate", "Показывать поддержку разработчика",
    "sw_donate_sub", "Показывает QR Pix при каждом запуске"
)
I18N["tr"] := Map(
    "nav_home", "Ana Sayfa",
    "nav_game", "Oyun",
    "nav_window", "Pencere",
    "nav_hook", "Bağlantı",
    "nav_coins", "Paralar",
    "nav_logs", "Kayıtlar",
    "nav_about", "Ayarlar",
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
    "nav_bot", "Bot ve komutlar",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Canlı panel",
    "nav_statusrep", "Rapor",
    "nav_stuck", "Takılma",
    "nav_qol", "QoL",
    "f_reading", "Mod okunuyor…",
    "f_prevround", "Önceki tur",
    "bot_401", "Geçersiz token (HTTP 401): Bot > Reset Token ile yenisini al ve buraya yapıştır",
    "f_mode", "Farm modu",
    "sw_fastupd", "30 saniyede bir güncelleme ara",
    "sw_fastupd_sub", "Hafif kontrol: dosyanın sadece başını okur",
    "ph_search", "Ara",
    "hud_panel", "Farm paneli (Durum, Paralar, Loglar)",
    "hud_welcome", "Hoş geldin, {1}",
    "hud_box_status", "Durum",
    "hud_newupd", "Yeni güncelleme mevcut",
    "pg_livepanel_sub", "Discord'da kendini güncelleyen bir mesaj",
    "pg_statusrep_sub", "Ekran görüntülü periyodik özet",
    "pg_stuck_sub", "Paralar değişmeyince uyarır veya yeniden başlatır",
    "nav_look", "Görünüm",
    "pg_look_sub", "Uygulama temasını seç",
    "sec_theme", "TEMA",
    "sec_hud", "ROBLOX HUD",
    "hud_mode", "HUD",
    "hud_off", "Kapalı",
    "hud_bar", "Altta yapışık çubuk",
    "hud_overlay", "Oyun köşesinde panel",
    "sw_frame", "Roblox etrafında renkli çerçeve",
    "sw_frame_sub", "Oyundayken yeşil, kopunca sarı, kapalıyken kırmızı",
    "sw_hudcompact", "Kompakt mod programı gizler, sadece HUD kalır",
    "hud_hint", "Kısayollar: Ctrl+Alt+H HUD aç/kapa · Ctrl+Alt+S başlat/durdur · Ctrl+Alt+R Roblox'u yeniden başlat · Ctrl+Alt+P durumu gönder. Programı açmak için çubuğa tıkla.",
    "nav_report", "Destek",
    "pg_report_sub", "Projeyi destekle ya da bana bir hata bildir",
    "sec_report", "SORUN BİLDİR",
    "lbl_report", "Ne olduğunu anlat",
    "sw_report_shot", "Roblox ekran görüntüsü ekle",
    "btn_report_send", "Raporu gönder",
    "report_sending", "Gönderiliyor…",
    "report_sent", "Rapor gönderildi. Teşekkürler!",
    "report_need_text", "Göndermeden önce bir mesaj yaz.",
    "report_nodest", "Rapor gönderimi kullanılamıyor.",
    "report_fail", "Gönderilemedi ({1}).",
    "report_hint", "İçerir: uygulama sürümü, Windows, PC adı ve kurulum kimliğin. IP veya kişisel veri yok.",
    "lbl_report_id", "KURULUM KİMLİĞİN",
    "ev_report", "Yeni rapor",
    "f_report_user", "Kullanıcı",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "Sistem",
    "f_report_lang", "Dil",
    "f_report_lic", "Lisans",
    "st_net", "İnternet yok",
    "st_net_sub", "Bağlantının geri gelmesi bekleniyor",
    "ev_neterr", "İnternet gitti",
    "ev_netok", "İnternet geldi",
    "d_net_wait", "Bağlantı yok — Roblox'u yeniden bağlamak için bekleniyor.",
    "d_net_back", "Bağlantı {1} sonra geldi.",
    "log_net_down", "İnternet gitti — yeniden bağlanma duraklatıldı.",
    "log_net_back", "İnternet geldi — devam ediliyor.",
    "ev_chart", "Grafik (7 gün)",
    "chart_none", "Grafik için henüz geçmiş yok.",
    "cmd_chart", "son 7 günün para/çevrimiçi grafiği",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox ekranda açık değil.",
    "gif_desc", "{1} ardışık oyun ekran görüntüsü.",
    "cmd_gif", "oyundan ardışık birkaç ekran görüntüsü yollar",
    "sw_zombie", "Takılan Roblox'u (penceresiz) kapat ve yeniden aç",
    "sw_zombie_sub", "İşlem açık kalır ama oyun kaybolur — zayıf PC'lerde yaygın",
    "st_zombie", "Roblox takıldı",
    "st_zombie_sub", "Penceresiz işlem — kapatılıp yeniden açılıyor",
    "r_zombie", "Roblox penceresiz takıldı (hayalet işlem)",
    "lbl_rammin", "Min RAM (MB)",
    "st_zombie_ram", "Düşük RAM — takıldı",
    "r_zombie_ram", "Roblox çok düşük RAM ({1} MB) — takıldı",
    "hud_side", "Roblox'ta yan panel (istatistik)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Roblox penceresine yapışık istatistik paneli",
    "btn_report_img", "Resim ekle",
    "report_noimg", "Resim eklenmedi",
    "report_img_set", "Resim: {1}",
    "cmd_panel", "sabit canlı paneli açar ve gönderir",
    "btn_killall", "Tüm Roblox'u kapat",
    "log_killed", "Roblox zorla kapatıldı.",
    "lbl_rbxver", "Roblox sürümünü sabitle (boş = en yeni)",
    "btn_rbxlist", "Sürümleri gör",
    "nav_notif", "Ne gönderilsin",
    "pg_notif_sub", "Webhook'una ne geleceğini seç",
    "sec_whevents", "WEBHOOK'A NE GÖNDERİLSİN",
    "sw_wh_reopen", "Başlatma ve yeniden bağlanma",
    "sw_wh_reopen_sub", "Başlatma, durdurma veya yeniden açmada bildirir (en çok konuşan)",
    "sw_wh_drop", "Düşüşler",
    "sw_wh_drop_sub", "Roblox düşerse veya donarsa bildirir",
    "sw_wh_error", "Hatalar",
    "sw_wh_error_sub", "Açılış, lisans ve internet hatalarını bildirir",
    "sw_wh_update", "Uygulama güncellemeleri",
    "don_title", "Geliştiriciye destek 💜",
    "don_msg", "Bu uygulama ücretsiz ve tek kişi tarafından yapıldı. Yardımcı oluyorsa her bağış projeyi yaşatır! 🙏",
    "don_pix", "Yukarıdaki QR'ı tara",
    "don_close", "Kapat",
    "don_never", "Bir daha gösterme",
    "sw_donate", "Geliştirici desteğini göster",
    "sw_donate_sub", "Uygulama her açıldığında Pix QR'ını gösterir"
)
I18N["id"] := Map(
    "nav_home", "Beranda",
    "nav_game", "Game",
    "nav_window", "Jendela",
    "nav_hook", "Koneksi",
    "nav_coins", "Mata Uang",
    "nav_logs", "Log",
    "nav_about", "Pengaturan",
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
    "nav_bot", "Bot dan perintah",
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
    "nav_discord", "Webhook",
    "nav_livepanel", "Panel langsung",
    "nav_statusrep", "Laporan",
    "nav_stuck", "Macet",
    "nav_qol", "QoL",
    "f_reading", "Membaca mode…",
    "f_prevround", "Ronde sebelumnya",
    "bot_401", "Token tidak valid (HTTP 401): buat ulang di Bot > Reset Token lalu tempel di sini",
    "f_mode", "Mode farm",
    "sw_fastupd", "Cek pembaruan setiap 30 detik",
    "sw_fastupd_sub", "Cek ringan: hanya membaca awal file",
    "ph_search", "Cari",
    "hud_panel", "Panel farm (Status, Koin, Log)",
    "hud_welcome", "Selamat datang, {1}",
    "hud_box_status", "Status",
    "hud_newupd", "Pembaruan baru tersedia",
    "pg_livepanel_sub", "Pesan yang memperbarui diri sendiri di Discord",
    "pg_statusrep_sub", "Ringkasan berkala dengan tangkapan layar",
    "pg_stuck_sub", "Peringatkan atau mulai ulang saat koin berhenti berubah",
    "nav_look", "Tampilan",
    "pg_look_sub", "Pilih tema aplikasi",
    "sec_theme", "TEMA",
    "sec_hud", "HUD DI ROBLOX",
    "hud_mode", "HUD",
    "hud_off", "Mati",
    "hud_bar", "Bar menempel di bawah",
    "hud_overlay", "Panel di pojok game",
    "sw_frame", "Bingkai warna di sekitar Roblox",
    "sw_frame_sub", "Hijau di game, kuning saat putus, merah saat tertutup",
    "sw_hudcompact", "Mode ringkas menyembunyikan aplikasi dan hanya menyisakan HUD",
    "hud_hint", "Pintasan: Ctrl+Alt+H tampil/sembunyi HUD · Ctrl+Alt+S mulai/berhenti · Ctrl+Alt+R mulai ulang Roblox · Ctrl+Alt+P kirim status. Klik bar untuk membuka aplikasi.",
    "nav_report", "Dukungan",
    "pg_report_sub", "Dukung proyek atau laporkan bug ke saya",
    "sec_report", "LAPORKAN MASALAH",
    "lbl_report", "Jelaskan apa yang terjadi",
    "sw_report_shot", "Lampirkan tangkapan layar Roblox",
    "btn_report_send", "Kirim laporan",
    "report_sending", "Mengirim…",
    "report_sent", "Laporan terkirim. Terima kasih!",
    "report_need_text", "Tulis pesan sebelum mengirim.",
    "report_nodest", "Pengiriman laporan tidak tersedia.",
    "report_fail", "Gagal mengirim ({1}).",
    "report_hint", "Termasuk: versi aplikasi, Windows, nama PC, dan ID instalasimu. Tanpa IP atau data pribadi.",
    "lbl_report_id", "ID INSTALASI ANDA",
    "ev_report", "Laporan baru",
    "f_report_user", "Pengguna",
    "f_report_pc", "PC",
    "f_report_id", "ID",
    "f_report_os", "Sistem",
    "f_report_lang", "Bahasa",
    "f_report_lic", "Lisensi",
    "st_net", "Tidak ada internet",
    "st_net_sub", "Menunggu koneksi kembali",
    "ev_neterr", "Internet putus",
    "ev_netok", "Internet kembali",
    "d_net_wait", "Tidak ada koneksi — menunggu untuk menyambungkan Roblox lagi.",
    "d_net_back", "Koneksi kembali setelah {1}.",
    "log_net_down", "Internet putus — jeda penyambungan ulang.",
    "log_net_back", "Internet kembali — melanjutkan.",
    "ev_chart", "Grafik (7 hari)",
    "chart_none", "Belum ada riwayat untuk grafik.",
    "cmd_chart", "grafik mata uang/online 7 hari terakhir",
    "ev_gif", "Timelapse",
    "gif_none", "Roblox tidak terbuka di layar.",
    "gif_desc", "{1} tangkapan layar game berurutan.",
    "cmd_gif", "mengirim beberapa tangkapan layar game",
    "sw_zombie", "Tutup Roblox macet (tanpa jendela) dan buka ulang",
    "sw_zombie_sub", "Prosesnya tetap terbuka tapi game hilang — umum di PC lemah",
    "st_zombie", "Roblox macet",
    "st_zombie_sub", "Proses tanpa jendela — menutup dan membuka ulang",
    "r_zombie", "Roblox macet tanpa jendela (proses hantu)",
    "lbl_rammin", "RAM min (MB)",
    "st_zombie_ram", "RAM rendah — macet",
    "r_zombie_ram", "Roblox dengan RAM sangat rendah ({1} MB) — macet",
    "hud_side", "Panel samping di Roblox (statistik)",
    "nav_hud", "HUD",
    "pg_hud_sub", "Panel menempel di jendela Roblox dengan statistik",
    "btn_report_img", "Lampirkan gambar",
    "report_noimg", "Tidak ada gambar",
    "report_img_set", "Gambar: {1}",
    "cmd_panel", "menyalakan dan mengirim panel langsung yang disematkan",
    "btn_killall", "Tutup semua Roblox",
    "log_killed", "Roblox ditutup paksa.",
    "lbl_rbxver", "Kunci versi Roblox (kosong = terbaru)",
    "btn_rbxlist", "Lihat versi",
    "nav_notif", "Apa yang dikirim",
    "pg_notif_sub", "Pilih apa yang masuk ke webhook-mu",
    "sec_whevents", "APA YANG DIKIRIM KE WEBHOOK",
    "sw_wh_reopen", "Pembukaan dan sambung ulang",
    "sw_wh_reopen_sub", "Memberi tahu saat mulai, berhenti, atau buka ulang (paling berisik)",
    "sw_wh_drop", "Terputus",
    "sw_wh_drop_sub", "Memberi tahu saat Roblox putus atau macet",
    "sw_wh_error", "Error",
    "sw_wh_error_sub", "Memberi tahu error buka, lisensi, dan internet",
    "sw_wh_update", "Pembaruan aplikasi",
    "don_title", "Dukung dev 💜",
    "don_msg", "Aplikasi ini gratis dan dibuat satu orang. Kalau membantu, donasi apa pun menjaga proyek tetap hidup! 🙏",
    "don_pix", "Pindai QR di atas",
    "don_close", "Tutup",
    "don_never", "Jangan tampilkan lagi",
    "sw_donate", "Tampilkan dukungan dev",
    "sw_donate_sub", "Tampilkan QR Pix setiap app dibuka"
)
LANG := SystemLang()
for c in LANG_CODES
    if (c = savedLang)
        LANG := c
USER_NAME  := UserDisplayName()
USER_FIRST := StrSplit(Trim(USER_NAME), " ")[1]
NAVK := Map("Início", "nav_home", "Jogo", "nav_game", "Janela", "nav_window", "Webhook", "nav_hook", "Notif", "nav_notif"
    , "Moedas", "nav_coins", "Logs", "nav_logs", "Sobre", "nav_about", "Contas", "nav_accounts", "Opções", "nav_opts", "Automação", "nav_auto", "Bot", "nav_bot", "Histórico", "nav_hist", "Discord", "nav_discord", "Painel", "nav_livepanel", "Relat", "nav_statusrep", "Travou", "nav_stuck", "QoL", "nav_qol", "Aparência", "nav_look", "Suporte", "nav_report", "HUD", "nav_hud")
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
W := 760, H := 600, SIDE := 184, SUBW := 140
CX := SIDE + 28          ; x do conteúdo
CW := W - CX - 28        ; largura do conteúdo

; ---------------- Logo (embutida no script) ----------------
LOGO_SIDE_B64 := "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"
    . "fY0zAuVbmSkon4tP23XXXW07vm/btq355L333jvo27dv1tl+HGPq1Knma6+//vrgkEMOCRYuXGjX4BP3PGfOHPt94sSJwdNPP20/45MrKyrshe9kdiPH1MxBrqNDhw7B4MGDg6OOOiro0aOHXaPwgPCBtu/UqVNQU1OzzTXr/ocNGxacfPLJwerVq4vmh4tuoiHMkRYoydayQoiBJCPdmDn5Sghzijmmg6O2rs6NHjXKrWxc6Q4TqrIfHYwkIy688EILj0Cyk0491TpB0O76oMFQLtNKKHrgeyH8J41xV1x5pbv6qqvch+vXZ+YfEybRU6WiCNeGD+V4hFpoLO+4Bt+1yFRD0ftGq0miYJXYjgigGD64aBoMKoTWrl0bjB49OoMk4zQ4ipK1De+tWrUKzjzzzOCyyy4zjeK7icdPDDZv2hTccccdNmdY83qnT58eLFiwILjwwgsz50dL4+b4duzYMdi8ebNtx/sll1xiqBk677zzTINBu6BraNGiRYayZVn233//4Pzzz7dtuUbQtzQz15xiXS/XTlQxe/ZsOwcWr9AWtWg+WCCELBLABImPIuM4qZa0E0eyL7ljui/Rxi9+8YvWu3XKyae4ww4/zPbHV+MfSSuS+ADIEcOSckSzfvSjH1l8On3adNetezeLQ5lOgqWg4qTZBoAdvkMTiYPx46omsQ+WAd+NvweZg5DBEyBxYmgfuachrl3lQhr1aB1mfACBhaTCHi2GGCzljXOl5ARUQK8wDLPL7AAhX5rzSCtiKjHjCADZIvVWIVSALsCSVpqFCaQrjz3u2MzVAfamTp1q5hHwxnnJUgntwmQYyPHYBlNKUUAtPtqO/UDXJFKUEs2HlPPmXopVNiw6g4kJ0QwGXqgzejNRTWZ7mIQ2EiuyPUia7fifl0/SQsW+bI92oPW3zpxpaBu0rHCEtCnhFJmks88+O7Pau6yHwhXOx+CL+WKISGgZASQmJ9vl35vuK455EmbwA7E4VgJLVGgkXbRctAYJjWOANIE7OgDqv1J1R6ZOGsiNK5erHLIqTxpwHcMHM3yHWX1+4UJrZ1XHJN8zgxFzfv3115uFUVrTD3l85ug8MqtiLMRnhAfhVaLE3zcJOGl82B9wBojkOIWOhYvGYN0k6JCEg79ulRihXmbepV0wAJPITavoHhUKbevH0j4pAUEPFfEx/k2Co9ovuIDYPM2Mv7jz6DtqzGTVwAL4Zl/IchHHQJC5XnVrFpqKxmCRGK1B9/+X1qpVFsbhM5FkzCpmFMn2Q480JDBHuERoRRaL73xN/8pXvtLEEuRDApCYVl40uWMJ8O1yE2lIDIa5vDTprpBUNAarTAgAQrrVEC4JF3M16DCZG4TBgBYYgt8lhqadht9U4M9FOhedI8xi8NeQVGWH62L2AxktvtPiLmlIWse+xNloMD3UADLfh0rLkwCU74exJAh22OwfPiCkEFQ0BkPcmN/gLRTt+13/c2VlOD1FphtGMXhXX321+XIhXr8pQP7RryVzTro2AXhoKtvLz8pU8x3rX5I/1sJqOlZS2VJtuxyfbgyKD6RD2Z40JgRQkt9NKndGCTBJ8mXVqncsF66xKwQVlcEyx+SP1TTOQPO9GPkRg3nOEcxlCiarydZkGvHopkBbaH/FFPomXf7b9+fkln/605/aHCG2jaJ0/U9ow3ERIIohPhaQ9vHuWxm2Yd0u2nFpnIPZbKMZFSz7z6wKmXFR9BogASpcCduvW7fWrV1LZaxwnZZFD5Mgkg5UgBQGcDNIrZ5bFGpVyFymqrBonBrR0BQYQAxKKpHEAmES5pXjcVyOR7oPf02MzKDTOUEsndTQJheC4CEQmHMQO6aW61WfNEzgWvGRaCzVIsI4ihmgZoE0UDlLMXFNdInSXBjHVJ+ExkH7FB4+/HCd69Klc0FTlkXLZElCuQk6DJnFwKDSfIYWasqmzCEM1uxA0DPmubaWmQZ11kMMIobYl4GGmZg1NAcmaDkGUDNxLsTgy8/5Jtr/DdJvgCQyZQAn/CndFrzzO/EqQkbTvKyRhId7oGqFIJAgoc2WfQUOk0AiGINrJ16nzZZkClN6BApzCUgaKqoG6wLRJDSDkAIgwQ2BblV8h8rKwumfPkiprKxy69d/6ObNe8zKagw2CROKBLySSCALgZKJjSYQlBJUbM3vpCF5QRwDIWQ7f9qoftOxOb4eyIVgICDh/WR/9A7MJTZnO/VlMSayCIUqPJTEB2PKACHEiWpGxzyriC//KWY0jXPLDUnzm8IIBsFvq4222Mr0sQ+djMxFFsATQ2m+p/1VpLywgBSMZcBhLvv4LbzCEbI+xOzqnJTP94FaXOaO7REqXAwEMkcR+L6QVFQGQ9wcg0TDGr6N3K2ayg1olYegK5T6cCahGM7n1q3bumeemW8mT0zQNj7A0mffLDLwEIzEJwv4gMjROt5B2v4+0kwhYDHHP75I27CWNeZZIVhSWCRS/IvboUca4Sf/zv5hqLRteXF7qSQMZnAwd7TG7L///pbAgMk234gEROMyDAr/GCANaE0NRYV3bUETCUwuEgKmXotpJ0fMAOIiVH2iiEGlSmFcvv6Oa0RAMa/33nuvXVLaPLLOhbuhGR4Gw1yOpxVv872eJCo6g0Wa9Ex6ENNHaKDpmqo2NXiPeJUpDaW5hU251MM5cmmISIupYXaZLgpA0hxi5bO3dyK2smX0NtMTJqCWD2N0DIQP4Ab6JgGTNn5OQ0VnsG4YCWVwAVskL2pa1bitdbXWYVHXEM77lf/7qGrDd3WubdvW1tdMyCRUnIYYKIEW/0GVSlvmc6woyUrQ6aHMli+U2UgCilVDODSXGYyCHy4UwIKKzmCZVS6eEACTRkgxZPAQk/pwWf5wGqgYrAEIJTkMddA4WmTFqDQkM8p5AGgCb35hY3uYLAbQJABYkw9Pa1nkigi7uGe6NEHUWmEoHyuQi4oaJvkk3wKwIJxgOSN1SVRXh4ussNiKZvSHgvHRi6wTyQNaY6kEqccrjj6Krcvt2UYwgdgYE4iGICQcj4FkkGG4Qqs0gyuMQLkRsMaxeE9DMLENc57WrrXYHTfCe5jBC59EXkgqGYMFQABZoE4W6iQhQC449JU85hWDovWxQiQZakdYCULKmaOLiTeQ5j25WySkDPHEFtKVcZrFoJKtwudhGdRWm0sLYQBgiHYfslpECGhyrrgXClf9KnN9evdxG1552RB83779XIcOndzSpa+5UaOOyIRzhaKSMVimEEBBmw03x2wDZsZLe8JpmOEKOuHqOo2T0xrnLsFUtJHWHfqz0ES/h0nMwaedd955NpMPgokU/RWH0z9NXzOr3uBDedHCc8YZZ1jMLsGKEtfB+QivfvjDH1oYRnozDVk+mzDQOUt7cq0kbniRfSPBQohU6PadkjHYHH7jo1uZeYfUEyYw+FruQP6ahc8AIMTI4fKCW936DRsy9WJCC9bBIn8bmuoKr8AWmBkk00USgSZ1TDDvnJ94lRdCwDaKewmhQNk0+8Vpsb5DCKlQ4TeVCo3bPqrRnKd9u3auqqrahKK6ZVgWraqqdAcfPNwNHDig4N0cUEkZbGaqsZJEGw9pPUw1s/rUOoOWbNkSpgiR9qoKFvYMJ4NrwROyYV/72tdMm8PsFlM0wxV3gsbHztFrhYZxHjRdfVkcB59JxgiNBtmjRQqXksw+hKB84xvfsIKHsmlpSMyuqq424apqWWXnA0FDxPr8r8Xg0uCAtFQSFB1HSDSxMRUYTKbm8EgIrOZL6NQQPptXDOB7mArY+ta3vmXbWzzZaMYhoXGKHF/4whfMQgCwMIOAKtwEn2E2aVB+J1OmuNQnvxMEy0F5UR2f2Rjha7WEBubimoYfNNwEOlyfZDcT3LQgLV8quQaLBLpA1ZqZYCalRQuDIg2u3tXW17ma1q0yc3WlCfK9ZKhgthbcLmtcHU8DD1Jndj6om/OQKkVYGHDMJL6QWjN+D4TOQ0CUs5bgoLVoOzMgmIvM7/jgNKDKJ5jJOXEB9JwhcAgb7ocqEi6EjNZO1xedi7hZzKTQr60F7crc1sanajNNBcSr7kql9NSlQagCOOExeNJeMRHARAYM7QSt00ct5oOgATfUltEgsEAccwnp6A5B46kAcb1JzNWxgYYsmCohRoDYD4sBwGSdEkAfIRyuRNYEN0K7cCFph2kwgwGT8INaO4sBhpkbNmx0dZjiqkq3dfPmzOo1mmnAPki8YmFCIbSKhgCVIVWYQHDQDLXURAkmAHaUQZI5ZX9mY1CLZmU+YvZszIUy8Xcjc2GsFj/jvrhuBJXZ/TCaKawQOQI0V09R/UT4YGWZkGY0C0JDevbq5dq1b+fatG1jAKtldUtX07LGVVdWGYiqr6s3X6ZBUFxKtYgGODROjQNsI+QeV16UhinFKCuCRjNvmFDqc5/7nFkCPgsfyIqoNIjFgaqrqtx+Q4cZXhg6dJiZZT2xXC09mGhCMpoWAJhYEo4jbFFI5kI7BGRpIJFmVryj6Q0CReKb1qxebZIvBjBglqJ0Za62rjaz9L4GA+YxSJg8li8CPeOb/cfgJZUWm2heebmZc+rHVKIAgKotE9ZBXJeuDa00FM96I+Vltg/uorKi0kw03aDqFoWB3C8PuCZ8AyRqDUtZjVxJlu2hkjNY/oubnTHjVrd8+Ztun30G2EBiAmHq5i1bDHh1697DdezU2dW0auXKK1o4FjMMQdi2pTkxmUljgCoK/aom+TMhwvx2uKKPPlsSonElXKpcaBaxulpyuGZCMtC+TCnlRsAR2t6+XXvXtVMXsx5vvPWm67N7H7ds+TIrj6Kxyp+TxWPVWjJgWAX8cFJGrlBUcgYTDsAE/A+FeKaRTJ58WmbVVuWsYfCAffd1I0aOdHv2758pzHfo2DEzDUUZLpGYDJPwczTTQX7niJjpFxzw5yyDBMNB3mqdgbFshybSr8XxCXNgHM11YAeSIzTKrflgja0gBFrfuGmTVc04LiEY98T39JGRhWO5CMAVApO2hry9VFKQxQACPEj8YwpBsaQrkfzHH59nyxrh6zB1mNlWrVpbrzStqG+/vcqEwn+KWByaFbomGULqkeURKOxzLq0BjQ+n6QBtJKOFAJCLBmj5sTAMxQrAXEw0CRESJ0zFgVEQFmXJ0qVmknv27GXbUNuFqeSrEWBy57TYItw015FmZX2RqIAWg0rKYBiiBjYWx+ZFjPnYY/MMpcJokKZM2vLly9w777ztunfvZtvi81joTFkvVV6iwATGUZrE5LPqHS8RTCTFScM662YRiyqJIm1SuKQiPvEy5yK1iWW4Z+5c99KLL1oqlZo2VNWypevZq6dhAMw7BRXmISMgtPKqpefKK680VK4UabGppAz2AY0GE4ln8TK0BO3GfPFOKhItZvI3IRDN82qWZ+ABZGizQgufADE8Tg7NZH1Jjsn5MKv4QVpbQa8i5ZQhhAWECwPYH00nDMNso7nkrF9YtMg0lJJfWxYcLwsBFr8TjjGhm30xyQA2rhchAkmzdAQmHoRdbPNsFqbYEhRHQotoL6k/EvdIupAumoqGMdsAASDUwF/DYLX5SIvZR4t38x3CgW9DawlxQK1x5NeTpbFiNH4TE8qxOT9mHIbAeC0ZTIwMtW7TxkyyYnOYq7WxcBMQwkRCBeuFkNHDxQNCEJK43HchqaQM9hEsEo6PYmYeg43ZBFmjlfhKLQSqhIhMnLRM+WY0A2CE5tCYh59DWGCM+o0hmUTFxjK/siq+P8R047uZ1I1AaZYD7zASkIhwcizcgJY3VNKEc6kRQJPNsUKsD80sDY1DoWPeOCoZivYHFuaSSABgEffyYGZuWjMVaMxDW1gdTzEz+2vWoR8vIhCkEjGHCApMJeWHrwb9otG89Eg7SP1f8uF+4oL9uTZSnH6iBPQMACQnzbk07Sasfm3JXJPwA8fkegi5EGSmuuDvcRdaV7MUVNSpKz6RZmSAQM/cMCU3ECaAY9as293s2XfZfKMFC56zDshjjz3GiuoAL/KzmEYGFuai"
    . "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"
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
LOGO_CARD_B64 := "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9967xGoITZA8mN8ZCCLW+JW/eXk1WIAeODIJ0ruJkHig48ILaTR8itfF3HpmJhGZVokpR0YmyxubdA6kIY1inUmFU8vC92y7kZzgoQ6K6UqgLYS0aJVFXc0T0GT99M40S/p2uVFXe00vI9pvEFIA9bcp0Ai89XtwHh4grRgvjTbBd8JF8CSBwywUhZMweUAEGIlMu6b/+86xzpslhH0HbEyqv4E0hDjF+v4PLNdcc03hR0ycz7SNUIP4mGvReNHOEymTBqA8LGCceeaZhYvgERKGtIHGueSSS8rITOoimqbWRKneezSAumDCg4gRnWk+Op62Y5LM4jCpT8rAIgzMGhBLYIqIS+biLwKKcctjUgHR/XG7abEEOnWuAWFguFedD1hMnmcDfEBKzg9wANk0pdyjc/it+wMcVYk0lDgQ8IqGi9C7d4DXfn9yADKS2HE84elPf3pR30ayz/EOC1fqwNj4tq2PVimah9XyjjgvikpX89g1fc7JTTZadSZtBkDAyRToKN6OER2e415oBybDb7P6B7DQJswKswYINAAwuY7Ozjnk726++abm//2/t5VnpBk333yz5swzz2rWXnudwpv23nuvomXcDy0nHMCbU+nomkw40AAdL9XfzCOOJsj68Y9/vJjKyZBJ00AaWseLvxitsswf+tCHCnB8Z9RLa8RLi3mqtU/+XiK9sahrqvJZjnFOXpOO95nON+pxr9T06Cid53MdSCPqWB4Q0+VegYOpxWkCEucK/9HhNIrjAJJZ9Pdll32v2WSTzZqFC69s9tnn6c2tt97WzJ49p5ybNsR1brzxpmbdddcp96ryQAqDuG8BRebcAqGvetWrijYDKKBl8o877rhiJid6tbNJI9FJXXho5FCMRIPpAN8xJzySxE10esxQ+z1gSWTZewh1/tbZQImYAwYXG5+w0JOMuuswp46jEYFX7VEKyWgg92D0u19A03lAFy5UczDmzbHAyJP79Kc/VUyNz4H2hBPeUKLOr3zlcUXLubboOw3kuZktZN//aUumyvmQ+7e+9a3lGKACXGAH4smQSQFQtILGVOejE374gx+UxkiMJpHZNhgCEhohQGqDJd+FEyTJaWV5nYKbMCcaHRC8RyPSGjpHZyfyDHiIcMhvTBnug2gj/PW+GoAFhIAjr+b/ouq//vWvitZA2K+44kcFuOJciRFlsXOendc/"
    . "/dM/DbWVSDbC7T6tamZSAV7GvBIcLg7ERMqkAsjoMqpkl6nnu++8q/nd3fc0Dy9eTzDuaYhy3mvu0/6u/f+YHnwK8cS5mCXah3usM1NKAbTMqaDmtttuW/4GFlrSd4AeQgv8SKxOl2pJZNv1AI0T8OUvf7l09rHHHttcdtl3S5L4+ut/1dxww2+at771Lc0553ykueiii8qgoeEAyX1F2/EIRbSTKtFeruP/n/3sZws/FKnGv9wPzVoch1a4YzxlUgCUPBVtYBTjCQ8/8kgZ/YuqnXQClDTKSECqGy4uPj4CCDiLTmUC9tlnn6JlgAfXyPn93v+BmnngbQFezCetoHN1HMIPHCnd8DlTQxNFGzHLvErCZAIvL4zmcR2dLmAqcApsyLn7BhBAcc7nPOc5j0pTaId4r4DOpJo/Zs+PaNKJkkkj0YRqX3WVVUuwTqa8G9X94/53AUQbSG3p9X3MFy6lUa0jxCMCAslOHKeuq4nJlAtj1vxOWoMp8nujmwZi2pgmZg+hpT0AQ+fTPoDJ3NAWBogVWd/+9rcX4o2spwAt8R5aUM4P0caJTFJ0TlWY3hFs5qqekUFLeQHx8573vJJnu/DCC8v1E4WfKJkUDUSMMgC6/PuXl5G4zrrrNHfcdadk0ZDrHf5Ta55aW7TjQjWQCI0ADDrS6LTaBe1gtNIO+EjyUElPMCMqAL2LNGfWa7QP7YG30QA0mLTCvvvuW46V/zrqqKPKCmMASvNxtxMLEjKog6Gu7fyA7Jyf+MQninZzL/ig47n5YjwkKRteGdPpt+9+97tLxt653A+QTuT8sUnTQNEu1sPRUJmkV0sAQtrZ5l7aKbJEhLppipdke6bEg2iidEhGrM4x6o10LrWRTWukWhGYaUjxIp0HIEBmeT2aiWkSrdbxtJj/ey6AMDGARjNQUooaDRnN5Z6dk0byHV7jnuTA5Otom7QB4KSMw/EJh9Dk4lITqYUmBUAaCDk1kpBInZbCrF5gaX9WA6sNuGgoouGteqozeCyuV5dSaOhoBOpf1tu7pCqzkOs6zv3xuGgL2shKsMpP+kk2VEHAgUDnM0eKxGpJZDqCowlnMJnuxTPUbdPmeQYe7YXrARUHIPc+ETIpANIhAPTf//3fxSRkYYJaC9VlDxl5Gq+90mrEaGUSmajsIiiyy8SIk9jeKSkSo1nAMlOHiI7mtuM2am6y8GWuTevwfLjsphpzn8VmmI1rr7m2ufHGG5o777izWWe9dUtkmulBlGkxA4T24lEJAIoDJWFaP5tncG80GrB7XjNxkXrSriNK3AngmDncC3ATOwvPGk+ZFABFxC6iTQKMfpJSVJ6UBg438XniJgCoY4xan8kdARAzwdwACaJK03gBrtpj7rgifqQZCRb8q7Pb/gYg71aDZTYQaADhOa680srNd7797eaW225tFq63XnPzLbcM8TdEGAcTkAQ85FdEG0BqzQpIeFWWsQnfcd2sodh2z/N/PI959Pt6LYEJEZvuTuTrkUceKde77bbbOgsXLuzMnDmzM21atwTee17Tp0/vzJgxo7wcM2vWrM78+fM766yzTvm/470vWLCgfD579uzO7rvv3llxxRXLbxa7cz3fHX/ooYd2rrrqqs5FF13UOfzwwzsHHHBA58orr+z0k8997nOds88+uxy3ySabdN7znvd0rr322s7NN9/cefGLXlzue87s2Z2ZM2Z2FqyyoNx/7jN/b7rppp0NN9ywc9hhh3We9KQndVZeeeWh583zOzZt4DPPte666/Z9nrTd0572tM7222/fueSSS8ojTFSfTrgGivmS8aZyM7+rTZLbkmhzyk3jsjJPIY1GatR3WeF0UadorNtuv618nnlWRj+uYCcfGXD8wWr2TBctsWDllZsVV5w3VAh/+x23Fw2CMDNJuFCK5D/4oQ82519wfjF/zlkWn+oWXheTSuPRcMyY52VGXd93ApCew2fIOpPa1jI0bVz/WmOREHHvSDoTxxGINzpSmy4VmSik5jo00MMPP9w57rjjyugx4traJ59HA3n3Ge1iFM+ZM2foNxmlRurQ37O6fz/3sOd0zjnnnDLSa43k/5///Oc7RxxxROe73/1uGbF33313Z4sttijXWGne/M4qKy/obLXFlp1tt922s+qqq3ZWWGGFzmabbVbunzz44IOda665prPddtt1vvrVr3a+9KUvFe1SX4eWuf766zv77bdfZ6211irPUGtH595pp52Kptp3332X0EjRLG1NWmvptJt3mnmDDTbovOxlLyv399BDD02IFppQAKXxb7rpps6ee+45ZJ76AQi48mo3aA2qN77xjZ1LL720c/rpp5dzTZ82rfOq417ZeeiBB0tjnnjiiZ1tt+kCQUcee+yx5fPXve51nTPPPHPovt73vvcN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"
    . "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"
    . "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"
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
LOGO_ICO_B64 := "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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AACSs0lEQVR4Xu3dB5ikVZU38HciQ84IRkQQUQQDuhgW18yaRdxdw7qGXbOiGFFBVFQWXXPEAKjILviJLgaQNSwGzBER3VVWFBQwkISZYWbqe36351/ceanqqurpnunuqdNPPVVd9Yb73nvPOf8T7rkL1qxZ02nGNKYxbZK0cJN86jGNaUyFxgJgTGPahGnxJvzs8546nU55LViwoFmzZk35jPyfzwsXLiz/5/sxbVo0FgDziDB1GB1jL1q0qPt0/h9Eq1at6goG50YwjGn+0lgAzDGKRkfR4qtXr+4yfM3oGPraa69tLr300uY3v/lN+XzZZZc1l1xySbNkyZLmNre5TbP77rs322yzTbPzzjs322+//Tq9EYFQo4QaURAQeY1pbtKCcRRgbhJN74WRQ7/97W+bH/3oR815553X/OAHP2h+/vOfN1dddVVz+eWXN1dffXXPB6Xply1b1tzkJjdp7nrXuzb77LNPs9deezUPfOADy3ehlStXlo9Lly69kZCokcaY5haNBcAcokD8xYtvAG6//vWvm6997WvNCSecUJj+T3/6U19Gd35bm9dmQ2izzTYrQuABD3hA8+AHP7ighNvd7nbl569+9avNEUcc0Wy55ZbNC1/4wubggw/uIpAxzT0aC4BZTIH40fbRvmD8Oeec03z9619v/u///q/53//936L1t9pqqwLJr7vuuu5ThcFRbT6g2hnoc4QDk8I9EUbfcccdC9M/5jGPaY499thmiy22aE466aRyzmGHHdYcfvjhzfXXX981B5yb67mm6+V+Y7/C7KKxAJjFFMaJxv/lL3/ZnHLKKc0Pf/jDoqFB77/9279tPvvZzzaf+9znmu222675xS9+0fzud78rjJcoQJtqJoyQaVPtS9h6662bgw46qPgObnrTmzY77bRTYfjly5c3f/nLX5p///d/bzbffPPSnvo8gmDFihXlNxRfRYRRhMKYNh6NBcAspDbU/9a3vtV85jOfKdr+Xve6V/O4xz2u2XbbbQv8Z/O/733vK8cE/g9i8EG/hxwX+x5j8wnc7GY3K/dlFvALMBPud7/7NQ960IOaK664ovnDH/7QfOlLXyoCiWPx5je/eREad77zncur7TgkFMaOxI1HYwEwC6j2rNeOPcz9jW98ozDJfvvt1xxwwAEFfjvmjDPOaN797nc3//Vf/7VOTB8Fvk8XxVSICYLxmRu0+93vfvfmuOOOK1r+aU97WnPxxRcXE+WNb3xjEVRQSQSOY3yGHpgtrnHrW996nTaPTYQNS2MBMEsoDjoE4n/gAx8o2vNhD3tYc8c73rHbyi984QvN6173uuL4C4SmpWMu1PB6pij3IxBEEKCSP/7xj8VEuc997tO87W1vK0gBahBKFIYUrSAMIkQc//nPf74IE+bFHnvs0U1YGiZnYUzTQ2MBMAuIxjbpQeiPf/zj5f0hD3lIc6c73anLFGxtUP/oo48u8fwwUu2wC/Wz69eXau1cZw8GxssnEC24293u1vz0pz9trrnmmvJsBAMBQNvf8pa3bG5xi1sUwQY9CFNecMEFBd1oN9NmbBZsOBoLgI1ImCPaFEP9z//8T7Hzhd4QRiAMePzZ1Dzv4DOnYDztzveZpp2MhrX7Qzl+GGGSNoyKPqCEF73oRc2TnvSkEmn4xCc+0eyyyy4FEcQPksjEMO0Y0+g0FgAbiWrI357sycCj6d/5znc23/zmN4vT7ZOf/GRJ6gnzx0nnf4JhYwmAmuo8gwiE+DgSmQjFbBFVeMITntD8wz/8Q4k0XHjhhc0//uM/NjvssEM3JXksAGaGxgJgA5NJn7Dez372s+ZWt7pV1zkWRvb7V77ylQKHOcvAfoxBIISpamZKuG8yJplJBDAstU0Iz+CVLEO+hL//+79v/vznP5eowoEHHlh+q7MdxzS9NHiFyJimjTAo5hY/x/xsYwKhZmBZeLGB2dG/+tWvSkpvUnlrJo93Pow0FQ96v3z+fjkEU6FeYT7X95yQi/Z7blGPE088sXzHHBJR4OsIuul1nTGtH40RwAaiMK5JLW1XAg9nWRggwoHmP/PMM4tdvOeeexY4fI973KP4AmqtH095HIi9Unpr6ocA+n0/nTRIMIWx8wyiHvrHM/7VX/1V86hHPao0R1+NVylOL40FwAai2PwY2oRn07P1kyoL5p511lnNd7/73eYpT3lKSZ5B//3f/93c//73vxG8r5nG53q9f02j2M4bWhjUbYtww+D6RXjx7/7u78pn4dCXv/zlZbUik6CdcTimqdPYBJhBqmF04LpQWJjfRI6D7P/9v//XnH/++c2LX/ziwvySbEx+OQHtFXiozvHvx/xzifIM8ZEwk0477bTmsY99bMkuJASlPCczcT4882ygsQCYIYrGbye1ZGFPvk8Y"
    . "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"
    . "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"
    . "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/ShwH0ObqOzuIIHakcaZl//rnXQf85jHFO1q0hNIIHQ9ybUt0Dfno0xWsF/YSXVbQo1ND+qbkHYywkDJ3edQs44AWki2X5yOvbR/hAMPv3tw0BGgvOiEkyiA/z0DlIHkCNCIZ539hebiiy+ZSKRa02l+eeFEpCVOt1QDCuU5wWqfoRTCRzuZLEKGMh4hDs/sN8fV/orJqG2K+T8moD4adQ64r7E3bvwhhJNEoHr15ZwlCGA+va6//vryPOeee25ns8026yxatKi8FixYMPC1cOHC7ivnLV68uPtasmRJZ+nSpeWYtRnE67y7h9+22GKLcpz/ne9azn3Tm97Uuc1tblOOyW9+r9vmunV7/b/TTjt17nznO3fb4btdd92189znPrfz+c9/voNWrVrV+fOf/9x5+ctf3tltt906BxxwQOdxj3tc55e//GX5feXKleV99erV5bOXc3KuPrv44os7V155ZTnm6U9/evfZXvGKV3Suuuqqciy65pprOl/84hc7v/rVrzoPeMADynELtdtzrX33jPvss0/n1rvvPvH72mfecccdu9fNs/t9u+2262y55Zbd31784hd3DjzwwM4jHvGIzj3vec91rpF+HnZcXX/ZsmWdgw46qJzba+wm+859/O78I444oozvySef3PnDH/7QWbFixZzmn3knADLRDz/88DJo9STLIPcTBr0EQARBLUgw8+1vf/vO/vvv37npTW9arptrRjhkkubd9zvvvHM5nmAqDOE8bVy4qLN0yZJynR2236H8lknnO/fbaqutut/7f/PNN+/ssccenaOPPrrzqU99qjBzGPoTn/hEYTTX2XvvvTu/+MUvCuOuuG55p7Omy8flM2ZH1157bTmfAMB07rv99tt3Pv7xj3eFxPLly0v/ErLomGOOKcfd/GY37zz20EO7gi6MWT9Hvttvv/06f/M3f1OEg++Mj+MwaISrz7Uw+Ku/+qvOfe5zn3KcZ/eqx7Lu//bY1se5Zlt495sL7bkSIfXEJz6xfCYgv/a1r5U+04dzVYnOSx8AbznvsgVAnFdZLFND0F7ULwoQiq3Mv8AG5Mlmv7KT27AyjkjEDgchsyQVpC127eqJVYibbba0uW7FiuaVR7yixNRf+7rXFsga06Vud57l8MMPL5CUo1NuP1gu3MYBxt61gEgUAAwX+tOeP1x2ebc4qvvsfdvbNttuv11xIop1O44HHjRnivCs8wckoSf3Zvqo4c8XIX2X41JbHvTgBzerV63qmhMxOTxHvPKiMnwEUoqVaEe1xz/n8I14cQzqO8/H3OIfcAz/B8dqlkJPltaN4hdo+wf6mQPtkCry/KC/8WbmyWTUrrZfZU7RXJVcvdodDXj66ad3Dj300Bs0bQv2rQ8CoEForX4mQBvOb7311gUyBgZ3UcaChROaf/GENrvbAQd0Vixf0fn85z7f2WuvvYqWDIKJJo0p4fszzjijaOFnPetZncc+9rGdSy65pKudQXR01FFHda/Rq70777hT52ZrEUx+z72ggIIaVqwo/aq/Y1798Y9/LNAfCvr2t79djmNqHHzwwZ1//Md/7PaRfqLVaWxtp4Evuuiizl/+8peCHpgxNbx3TO6fMfN+//vfv/OoRz2qc8ghh3S1/0Me8pDOC1/4wmI6QAz9UEAv1Ff3xbAIIIjs+c9/fnlu1zjrrLO65tVc5aN5tRiINCeNaTQJJjRG0jn7Sfp+FG1fv7u2/5PSmrh+vc68dgbKjaclaVEOtOc85znd8NaiRRNdv3jJkubOd7pT8553v6doyYPuc1DxLLtmnG0h9xUy49gTAnQv16W9JdJkRR0E4DcoKEtWly5e0my2ZGmz+WbLuhWQLv/jH5qLL7mkIJRsgxaHl5r80Zx17Nz93/72t5eIioQheQKyBeUaSJDRRo4yjj8vxznH97ZlE5kQVoSgFAHRJ5yAQUlBA77Tf55DWPNFL3pRyYVIXr+8gSzXNc71+NZj1kZvbe9/r3Guj8nvIfNK25BwKHLMoHDlbKV5lQdgEiQ+DWbzkpt8SacdJfQziDLgmXgRDoGY4KtqO+CyJbkmuM88/1JVFy9a3Gy59RbN6495ffOUpzx5QpgsWljOO+6448omlZhFrFyYMJt6iJtbkivMyLzhpQeHs2V3CnEk8UfdvrIl+NKlzYqVK8tj7brLTcp9Fi1e1Fx73XXdElcEiL7i3c4+f/VqN4JA/4LhlgyDwoSPcBiho81ChkyjVBOS8+9/qwH1R8hiIS9hNW1J1SHX9qzOF4mQkajPZOIxN2T1FcG5ePEGZbzAfFGdLAKSdJSqU34nGKZzjm0ImjcCIOE/E9QLIyYXva4uM50UZjf4Jm22G0eSRUxi2XTaJpQmv17YrCzEWbOyWbRiUfOzn53ffOnLX2722++O"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
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
LOGO_DONATE_B64 := "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "djabDYVCWK5ut/uDDz6A+lZ5r3xqidwZPMCJ4ye6urrw8IjuLVy4sK6uLhqNWiyWSCRiMplAgjcq3MWjrDjosSorK5csWTJx4sRYLAYgxm9/+1v0QDYYDAAmjB8//qtf/SreCpoVgmNBq9W2tLR8/PHHra2tVGhAglGTJMntdl9yySWTJk3CFaKxqMvpqqqsQhAEKbqDBw++8sorhw4dgpq3WCzTp09funRpZWUljHP+tBFFMRaLmc3m+vr6HB5sYL2WUko3ZcqUVatWxWIxl8uVzWa3b9/+3HPPIZ8HJUWvAGvLYrG0t7fjymeX2oTiM5vNixcvbmxsxNjqdLru7u633367s7MTexUlMEuXLr366qsxMrwiI9hbf3//9u3bX3/9dcBAyNDDXXACX3zxxcgm4Hg0m81r1qxBuBQNRIooPmqmW1lZedNNN4FxB3VABw4caG1thX6Ht3j06NE//OEPTqcTYJPC0SWB2Rt4nUwm43Q4Fy9ZbLPZiiuOpUuXVldVM7iUQc+IozWsPTidH4IgLFmypL6+Hp41ErRbtmx5/vnnkQoBFubOO+9sampiKbPsGbqellNlZeXFF188YcIEHI3ZbLaioqKuro7HMZWVlV1yySUzZ86ElSEIQldX1x//+EcUwhNEjdQEb+/gZyiOcDgM4lIEYkwmE3JqKHcCLdiECRP+hyoOmlqbzTZlypTJkycTp+PmzZvx0EDX4JBZvnw5aNf4oSQbPplMnjp1CpVyVFSOW1D9T1NT0/3333/ppZfmKK0l1tGXUXWgmY3IzslTp059+OGH1EbI7XZ7PJ76+vr58+ejRp73WgdXp6yRMgzzns++XWRj1NbW1tTUkFW/Y8eOTZs2Yd0MFR6GelIV1A1r8/OCTT5x4sTGxka8kcFgOHLkyJNPPrlt2zao1GQyOWnSpC9+8YuXX355/lsTOeOBAwfWr1+/adMmHteEhyHCzqVLly5btgxQWpvNxjoGHThAK3IohwJCf/V6vRdddNF5550HxQ0/i8IomM1gMLhz587iF6TLYsPYbLZKb+VQUE7a0lOmTJk0cdIZPA8KDzhdbdKkSRMmTIALAKzzli1bNm3aBF8YimzmzJnJZLIgEhqXMplM9fX1yIDSlXmHV5YZw8uMGTPIldbpdHv27Pn2t78NqlTU1PH0rkOeLgMNq6FADQbDokWLLrjgAvo6P/ilDGlx+VwsDko4I2ZGtHSqRwE6syAIHV+JRqNEaT3UeMHYQ5QEFJ7Ml5EZwAlODaJKg7xhynKPxWJURkU6i/DmeE7WsiDDmI1VBB/FBx2xdyrBpl7WxadBRUpGZH/0LSrVwZsie696Et5uQhQJNjYxO8BdwsdUzjMOeUR2CAKnil7zvazpIviBjJfSVyRY1/jsFV+3Tnt4pFZYLBbD0V18wEFHLGrOcB5VfDF4NrJ2E4kEDjxqTwMTkucf47tJ5McaSPjHI++DxhCtPCWJcVZRqKuUcYAHiugVFPEols+o5HNRHDw0jVZzfmAGcXWdTgeLA6Y7EbRhOSLWiPOQuCdV7wAcak49Ke6uLCn1JgruA814bTYbtapHKSrVuTGuJIW3RlA6CtLFmULJFYiMWGj/5OcXcLqSlQGHuSBtDx8vQFCZPobehUMRI2GoCcvAc3zxRx9+puJdeBnBYJAieao8TpG0zrDJpnxBI1uCwwJyTklrSgOVMvQ4G+Dbo1HDsM+j8PXljhayBVREChCevw8Di7AIkFpYS6r0Ex/p55vXkyrh1SvZGvgkxgEfGJYgRiVwh4mRiJpml67NS5fPRXHAMOabgxc8lJia0OkFMYfbx/rmg3Y2m83lciFXQixveDecihipfHYDBMwwXqjywOGJr8AMpvxWDmA6HOnuiISmCu1mABshAkSeN7A41hv+C/n89Ayq7GzBAzb/jCp4/lDsk3r/UPWK6rKD+2GA0YdUyVnUUFEtT44YjYv5U5O3IqqKFzwYFf6XMlMYCtUQkRec409X1ARvkFLhWXEWEn6jlpLIwGdIcfBEZGchsJLIho3FYiBPHV35XBQHhWq6uroikQha2pEbTLNFRhoNGWCX4XC4trZWluVt27b19fVRrWcmk3G73VOnTnW5XGSAOByOPXv2tLW1IagRi8XKy8sXLFhAEF1+Z/JOLM0uM+1kqaO948jhI52dnXq9HlVtQ+npYc1gvkw2Go1eccUVVqsVlqfRaGxpafnss8+QRcbhUFlZOW/ePPTjQMvrzs7O7du345/oxlxfX19ZWQmItyRJVVVVDQ0NMLXgo8Xj8YMHD3Z2dhJBaSgUmjlzZt24OqaaBTErsSKIkydPvv766wSrNxgMTU1NEyZMgN5EsfacuXMiEVabA4OZUtqI1TEtnEn/+c9/FgQBkW+Hw0ENukuxqIcV2Epms7murm7ixImoEOeTCDi60a/z+PHjJ06cCIfDQ83XiIQ6Yxw5cuTkyZOAgSEju3fvXlyK1NnJkyfXrVuHtLFWy+LKDQ0Nzc3NwCuN9Cii53c4HJdeemlfX5/T6SRi2hLfIpchliSTyYRMIlKEaBB3/vnnV1dX/0+sVaHsQDAY/OSTT958802fz4dGRygNUBtgyoBQ9WEgEHjmmWc6OjomTpyYyWROnz59/PhxAG+RpvZ4PDfccENTUxMdDt3d3evWrWttbUV2MxgMTpgwobKyksf2q9J4qrgjM3GT6YMHDq5evXrHjh3gjyJY59kJACZarXbRokWrVq1CyyU4Ta+//jp0KCmOurq6VatWud1uFBRUVlbu2bPn0KFDFOFzOp0XXHDBsmXLvF4vsG02m622tpZouLGHN2zYsHnz5mAwiFRRRUUFq9mZzArz2JmmNHBZt27d6tWrYVqnUimv13vPPfdMmDABOR2DwVBTU3P5ZZfPnzcf5dv0+mT7JBKJDz744Oc//zkxUHg8nmPHjqk21bkIDnydTjdjxow777yztrYW0G8+NykIgsvlCgQCa9euXbNmTSAQOAvFkf8VrCIcWli9mUwGiIFDhw7l2JIHmFz27t371FNPQZlms9nu7u4VK1acf/754N0aqeKg4CWop0KhELWhKf3VsJVMJlM4HP7LX/5y9OhR/NPv91ut1u985ztQHIRnOWsZZYuDzM5YLHb8+PEPP/wwHA5jHAkpVORQikaj+/bt6+7uPnXqFJQ9z5OOUqhp06ZdeOGFCDrCkHnmmWfAZIeDt7+/n8qKijsCJMB6HD9+/MCBA9BTJRrJQwnacGk0rMS2ubkZcRyXy6XVag8dOqT6FjLKdrs9HAobTayBAxBB9DGLxTJx4sTFzYura6pxBMGwp6JhuPft7e27du0CL74kSY2NjQ8//PCi5kVQYQaD4eDBg88+++yHH35IAM2ZM2cSAS+igE6n0+lwSnIOQ8U/ajweB833Rx999OGHH1JBN/oPkWN41muRBJo9k2Hm5AUXXAAeClVzbHhYPp+vtbUVlDb4FoUMSnmMIkbloUOHNm7cCGIhpGPxDOTqajSaEydOnD59Gj4XlisKMrEzVYGPYYUexm63X3jhhbB9SlcZEDjvRqOxr6/vRz/60fbt28HQAc3Ll9sN+zzFZZQVBz/3iDYjEc1jk/MfiA8m4ZOgEuDhLhCE4hlzjyCyshGRIfxgnPOBQ4TWYS7Ctgc+jy7Ch2Ah4FJHMGWkQal8IaIHILhBnYAHYNwKSik0qqHhRaPbCzgj+FQUBJvEaGAdw/jWHip+AFAl0zgAZEFfgb1D7D6U3qbf5NhhBRaQ1os5Yn5etBoWuuZtJaLMQRKHdm/+cifCt+LLESOD/YnYE/qkUTKIF4qSEBicskUIbBExiupbVJXD/x4hEnwrnU4z7pyBqlYiH1EZEQRLJ2w0BaQgWPmqijuogyIaAVm5kaoM/o5Eg0YN1bG8R8WRhHwuioNikNgY1Dg+X1SjA4gRlXuo8qMIcVssFj4Upzew/YYTGBkKq9XK2hEMqAmbzabTs8poAiaFQiEieqWdCQg8Ldkiz1yKgDCGal4YWfEAY3AsFmM9PgYEWpI2JFVeqTJ2rDhKqR9RrV3+Y+iZQqkBeOZEOWU0GonkivhywfiAsSpCkgJtnkgmUCJE0VM+WVhKEWPxzSBJUjQapWmioRgK6Uht6/n3CofDiEoUeR0IhSGohyt1HkE7e1ABEZWhKj/CC7E3EV6L1lXBsDHl1PLX0lBEk8QFMdQYEn6SgkFQE3x3kf8LFAdSrdR3FwNEvbZV40VjIUksOKIiClRtIRXexmZleHZS6nDU0Sodwk57g5HnHE2lUoFAQLXQYd4T23CRVVKK0Ndz/aIUIUMXy5GsMARK2dYdqMSz2+38HOv1eqfT6S4ffClal/zD8JQQuVoepVstYTRoeEkCgUApVWS5idPkVi1xr47UoSve4E+SJGqGgsyCTqfL76HDC9jMeQsRdm4pbgLSDThsVAB8jYZV+phMJipj4WnWVWg9XihGS8WcQ60WPnrK64Khog9EMcenxvBFVcwOGWKHwwEnFB3F8BjnTp5CMsoWB8UsKysrV65caTabo9EoinZ27ty5ffv2gtQp5L7W1NQ8+uijRKV54sQJOO20QFtbW5955pnGxkbANLQaxhJ26tQpvrdFKBR64YUXJk+ejIwAykZvueWWXNurbNZsNk+fPn3cuHEqi4a0T3GmnxKF4MC0b3F2zZ0795FHHsGuQGjAZrP96le/IsYQgI4p2qfVavv6+t59993+/n5kZwC6nTlz5sSJE1VqFBqKh05TBzxZkisqKu66667zzz8f6C/AkA8fOfzUU09hVfGpR+RQJElauXIlgOE6MVfecskll4AIFn5ivtlIyUUC4LSeaN2zZ09vb6+qe+Mgi6osVVZWrlq16sSJE4gxsYo7p/NXv/oVwVLYp2XWuAxYGGzmcDh81VVXXXzxxbT/HQ7Hu+++u3nzZjiqvF+gExVTTqtZtGgRGDrw/KlUateuXaBuQyftbdu2kb+pOkUwcbIsz549+6KLLuLjaLNnz8aSQza0u7v74MGDR44cwV1kWfZ6vTNmzEBGTLXh6Z/d3d3vvPNOJBKhga2srFy2bJnb7SZrghYhkTn09vbu3r37+PHjwA2nUqmrr756xYoVqL0GexbV45xF4FYttElGS6gvnkp+/OMf494EK77lllvwmXg8XvDuGzZsWLFiBWzO4m5hETGZTHfeeeeRI0fyb4GQrSzLsVjs5ZdfBoy6oAM8UqEd+OijjyK1yZszKlm/fn2+/Un0iwXnuKam5rHHHkNkDl5VZ2fnQw89VFdXR+GAyZMno402i2IkUwX7XR89evTOO+8s/nbPP/88HvhcOhW/8/Y7Fy+92GhgzTpxu5UrV37yySfUhpIpqewZnZMjkcgvf/nL4haH0Wi88847+Z7SkiT9/ve/X7hwYfGX+sUvfsGvvXA4/OCDDxb5CjkCCBXhkw899FDBdUsm8NatW++55x5+BmfOnPnrX//a5/PxTTNwEfIpdu7cqWIwnzVrFnodqBo10F5LpVIfffQR+hZBbDbbrl27RmtT58toWhwU1i6IdKC9UXofeQQdMBC8VTaUFCTFhrIvaLvyw8HfRXVuk+Rv71IwHbwULJPjWQVIihfUIYbPm0jDqDatmjMCoiquLyiDuBtlz5dS6ZcvOr0ylQqol39HZhUqOXlmm5xJvaHXsYhP8UA1ktOqUiM6zIsIH48nJ7r45/l1i5UwLOyNpwKBULpAdS/eyFVx3POcT8WfkPccKYn5OcloKg6VqwZ1SEVugDNRrDR/k1PjH1SdybLc398PTDoZjdRsAsOBCyKLjqVAuobnekqn0z09PZWVlagswJmcc2sxgzK7O+kLCL2OapFBeEzBiOYGTQCwOPAM4XDY5XIBHkbkMXyYjXrEUIfByspKm52B6IkOLz+aS6uWAjcYKPwTI+z3+4nFFw4CBWIsFgur1lGyQnhB1qBXYoSvyGFRVAgMbxhAyoZSuSp2V19fH1pS0LxTUhlEOOzVpGw6kc5KDMEhS3IgEECn"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
    . "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"
try Base64ToFile(LOGO_SIDE_B64, ASSET_DIR "\side.png")
try Base64ToFile(LOGO_CARD_B64, ASSET_DIR "\card.png")
try Base64ToFile(LOGO_ICO_B64, ASSET_DIR "\app.ico")
try Base64ToFile(LOGO_DONATE_B64, ASSET_DIR "\donate.png")
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
    , "Discord", ["Webhook", "Notif", "Painel", "Bot", "Relat"], "QoL", ["Moedas", "Travou", "Histórico"], "Aparência", ["Aparência", "HUD"]
    , "Logs", ["Logs"], "Sobre", ["Sobre"], "Suporte", ["Suporte"])
VGROUPS := Map("Discord", 1, "QoL", 1)   ; grupos com lista lateral em vez de sub-abas no topo
GROUP_OF := Map()
for gk, subs in GROUPS
    for sb in subs
        GROUP_OF[sb] := gk
AddNav("Início",    Chr(0xE80F), 92)
AddNav("Jogo",      Chr(0xE7FC), 134)
AddNav("Automação", Chr(0xE916), 176)
AddNav("Discord",   Chr(0xE8F2), 218)
AddNav("QoL",       Chr(0xE8C7), 260)
AddNav("Aparência", Chr(0xE790), 302)
AddNav("Logs",      Chr(0xE81C), 344)
AddNav("Sobre",     Chr(0xE713), 386)
AddNav("Suporte",   Chr(0xE897), 428)
navBar := g.Add("Text", Format("x8 y{} w3 h18 Background{}", 102, C_ACC))

FontUI(g, "s10")
sideDot := g.Add("Text", Format("x24 y{} w14 c{} Background{}", H - 62, C_DIM, C_SIDE), "●")
FontUI(g, "s9 w600")
sideStat := g.Add("Text", Format("x42 y{} w130 c{} Background{}", H - 61, C_TEXT, C_SIDE), TT("idle"))
FontUI(g, "s8")
g.Add("Text", Format("x24 y+4 w160 c{} Background{}", C_DIM, C_SIDE), USER_NAME "  ·  v" VERSION "  ·  BETA")
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
FontUI(g, "s14 w700")
pageTitleV := g.Add("Text", Format("x{} y26 w{} c{} Background{}", CX + SUBW + 16, CW - SUBW - 16, C_TEXT, C_BG), "")
FontUI(g, "s9")
pageSubV := g.Add("Text", Format("x{} y+2 w{} c{} Background{}", CX + SUBW + 16, CW - SUBW - 16, C_MUTED, C_BG), "")

; ---- barra de status embaixo ----
sbBg := g.Add("Text", Format("x{} y{} w{} h28 +0x4000000 Background{}", SIDE, H - 28, W - SIDE, C_SIDE))
Bg(sbBg)
sbLine := g.Add("Text", Format("x{} y{} w{} h1 Background{}", SIDE, H - 28, W - SIDE, C_NAVA))
FontUI(g, "s9")
sbDot := g.Add("Text", Format("x{} y{} w16 h28 +0x200 c{} Background{}", CX, H - 28, C_DIM, C_SIDE), "●")
FontUI(g, "s8")
sbTxt := g.Add("Text", Format("x{} y{} w{} h28 +0x200 c{} Background{}", CX + 20, H - 28, 460, C_MUTED, C_SIDE), TT("idle") "  ·  v" VERSION "  ·  BETA")

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
Card(CX, y, CW, 150)
Lbl(CX + 20, y + 16, 300, TT("sec_server"), "s7 w700", C_DIM)
edLink := Input(CX + 20, y + 38, CW - 40, savedLink)
Lbl(CX + 20, y + 74, CW - 40, TT("hint_link"), "s8", C_MUTED)
Lbl(CX + 20, y + 98, 300, TT("lbl_rbxver"), "s9", C_MUTED)
Btn(CX + CW - 150, y + 94, 130, 26, TT("btn_rbxlist"), ListRbxVersions)
edRbxVer := Input(CX + 20, y + 120, CW - 40, savedRbxVer)

y := 262, half := (CW - 40) // 2
Card(CX, y, CW, 110)
Lbl(CX + 20, y + 16, 300, TT("sec_monitor"), "s7 w700", C_DIM)
Lbl(CX + 20, y + 40, half, TT("lbl_check"), "s9", C_MUTED)
edInterval := Input(CX + 20, y + 62, 120, savedInterval, "Number")
Lbl(CX + 20 + half, y + 40, half, TT("lbl_wait"), "s9", C_MUTED)
edWait := Input(CX + 20 + half, y + 62, 120, savedWait, "Number")

y := 384
Card(CX, y, CW, 178)
Lbl(CX + 20, y + 16, 300, TT("sec_recovery"), "s7 w700", C_DIM)
Btn(CX + CW - 210, y + 11, 190, 30, TT("btn_killall"), KillRobloxManual)
chkErr := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_err"), savedErr, TT("sw_err_sub"))
chkZombie := ToggleSwitch(CX + 20, y + 96, CW - 40, TT("sw_zombie"), savedZombie, TT("sw_zombie_sub"))
Lbl(CX + 20, y + 152, 200, TT("lbl_tol"), "s9", C_MUTED)
edErrSec := Input(CX + 170, y + 145, 90, savedErrSec, "Number")

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
; ---- grupos com lista lateral (Webhook e QoL): o conteúdo começa depois da lista ----
CX0 := CX, CW0 := CW
CX := CX0 + SUBW + 16, CW := CW0 - SUBW - 16

; ---------------- Webhook: Conexão ----------------
BeginPage("Webhook", TT("nav_hook"), TT("pg_hook_sub"))
y := 92
Card(CX, y, CW, 164)
Lbl(CX + 20, y + 16, 300, "WEBHOOK", "s7 w700", C_DIM)
edHook := Input(CX + 20, y + 38, CW - 40, savedHook)
Lbl(CX + 20, y + 80, CW - 40, TT("hint_hook"), "s8", C_MUTED)
btnHookTest := Btn(CX + 20, y + 120, 130, 32, TT("btn_test"), (*) => SendEvent("test", [TT("d_test")], true))

y := 268
Card(CX, y, CW, 184)
Lbl(CX + 20, y + 16, 300, TT("sec_mention"), "s7 w700", C_DIM)
chkMention := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_mention"), savedMention, TT("sw_mention_sub"))
Divider(CX + 20, y + 100, CW - 40)
Lbl(CX + 20, y + 114, CW - 40, TT("lbl_discord_id"), "s9", C_MUTED)
edDiscId := Input(CX + 20, y + 136, CW - 40 - 118, savedDiscId, "Number")
Btn(CX + CW - 128, y + 136, 108, 32, TT("btn_how"), (*) => (ToolTip(TT("hint_discord_id")), SetTimer(() => ToolTip(), -9000)))

; ---------------- Webhook: O que enviar ----------------
BeginPage("Notif", TT("nav_notif"), TT("pg_notif_sub"))
y := 92
Card(CX, y, CW, 300)
Lbl(CX + 20, y + 16, 300, TT("sec_whevents"), "s7 w700", C_DIM)
chkWhReopen := ToggleSwitch(CX + 20, y + 44, CW - 40, TT("sw_wh_reopen"), savedWhReopen, TT("sw_wh_reopen_sub"))
Divider(CX + 20, y + 104, CW - 40)
chkWhDrop := ToggleSwitch(CX + 20, y + 118, CW - 40, TT("sw_wh_drop"), savedWhDrop, TT("sw_wh_drop_sub"))
Divider(CX + 20, y + 178, CW - 40)
chkWhError := ToggleSwitch(CX + 20, y + 192, CW - 40, TT("sw_wh_error"), savedWhError, TT("sw_wh_error_sub"))
Divider(CX + 20, y + 252, CW - 40)
chkWhUpdate := ToggleSwitch(CX + 20, y + 266, CW - 40, TT("sw_wh_update"), savedWhUpdate)

; ---------------- Webhook: Painel ao vivo ----------------
BeginPage("Painel", TT("nav_livepanel"), TT("pg_livepanel_sub"))
y := 92
Card(CX, y, CW, 236)
Lbl(CX + 20, y + 16, 300, TT("sec_panel"), "s7 w700", C_DIM)
chkPanel := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_panel"), savedPanel, TT("sw_panel_sub"))
chkPanel.onChange := (*) => SetTimer(() => PanelUpdate(true), -500)
Divider(CX + 20, y + 106, CW - 40)
Lbl(CX + 20, y + 120, CW - 40, TT("lbl_panel_min"), "s9", C_MUTED)
edPanelMin := Input(CX + CW - 20 - 64, y + 142, 64, savedPanelMin, "Number")
SliderBar(CX + 20, y + 147, CW - 40 - 64 - 16, edPanelMin, 1, 30)
Btn(CX + 20, y + 188, 150, 32, TT("btn_send_now"), (*) => PanelUpdate(true))

; ---------------- Webhook: Bot e comandos ----------------
BeginPage("Bot", TT("nav_bot"), TT("pg_bot_sub"))
y := 92
Card(CX, y, CW, 336)
Lbl(CX + 20, y + 16, 300, TT("sec_bot"), "s7 w700", C_DIM)
chkBot := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_bot"), savedBot, TT("sw_bot_sub"))
Divider(CX + 20, y + 100, CW - 40)
Lbl(CX + 20, y + 114, CW - 40, TT("lbl_token"), "s9", C_MUTED)
edToken := Input(CX + 20, y + 134, CW - 40, DpapiUnprotect(IniRead(iniFile, "cfg", "botToken", "")), "Password")
Lbl(CX + 20, y + 178, CW - 40, TT("lbl_channel"), "s9", C_MUTED)
edChan := Input(CX + 20, y + 198, CW - 40, savedBotChan, "Number")
botStatus := Lbl(CX + 20, y + 246, CW - 40, TT("bot_off"), "s9 w600", C_TEXT)
Lbl(CX + 20, y + 268, CW - 40, TT("bot_setup"), "s8", C_MUTED)

y := 440
Card(CX, y, CW, 84)
Lbl(CX + 20, y + 14, CW - 40, TT("bot_hint_help"), "s9", C_MUTED)

; ---------------- Webhook: Relatório ----------------
BeginPage("Relat", TT("nav_statusrep"), TT("pg_statusrep_sub"))
y := 92
Card(CX, y, CW, 236)
Lbl(CX + 20, y + 16, 300, TT("sec_status"), "s7 w700", C_DIM)
chkRep := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_rep"), savedRep, TT("sw_rep_sub"))
chkRep.onChange := ApplyReportTimer
Divider(CX + 20, y + 106, CW - 40)
Lbl(CX + 20, y + 120, CW - 40, TT("lbl_interval"), "s9", C_MUTED)
edRepMin := Input(CX + CW - 20 - 64, y + 142, 64, savedRepMin, "Number")
SliderBar(CX + 20, y + 147, CW - 40 - 64 - 16, edRepMin, 5, 240)
Btn(CX + 20, y + 188, 160, 32, TT("btn_send_now"), (*) => SendStatusReport(true))

; ---------------- QoL: Moedas ----------------
BeginPage("Moedas", TT("nav_coins"), TT("pg_coins_sub"))
y := 92
Card(CX, y, CW, 196)
Lbl(CX + 20, y + 16, 300, TT("sec_ocr"), "s7 w700", C_DIM)
chkOcr := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_ocr"), savedOcr, TT("sw_ocr_sub"))
Divider(CX + 20, y + 100, CW - 40)
Lbl(CX + 20, y + 112, CW - 40, TT("lbl_coins"), "s9", C_MUTED)
edCur := Input(CX + 20, y + 148, CW - 40, savedCur)

y := 300
Card(CX, y, CW, 186)
Lbl(CX + 20, y + 20, 160, TT("sec_lastread"), "s7 w700", C_DIM)
Btn(CX + CW - 150, y + 12, 130, 32, TT("btn_testread"), (*) => TestCurrencies())
FontMono(g, "s9")
curView := P(g.Add("Text", Format("x{} y{} w{} h{} c{} Background{}", CX + 20, y + 56, CW - 40, 114, C_TEXT, C_CARD)
    , TT("no_read")))

; ---------------- QoL: Travamento ----------------
BeginPage("Travou", TT("nav_stuck"), TT("pg_stuck_sub"))
y := 92
Card(CX, y, CW, 268)
Lbl(CX + 20, y + 16, 300, TT("sec_stuck"), "s7 w700", C_DIM)
chkStuck := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_stuck"), savedStuck, TT("sw_stuck_sub"))
Divider(CX + 20, y + 112, CW - 40)
Lbl(CX + 20, y + 126, CW - 40, TT("lbl_stuck_min"), "s9", C_MUTED)
edStuckMin := Input(CX + CW - 20 - 64, y + 148, 64, savedStuckMin, "Number")
SliderBar(CX + 20, y + 153, CW - 40 - 64 - 16, edStuckMin, 3, 120)
Divider(CX + 20, y + 200, CW - 40)
btnStuckAct := Btn(CX + 20, y + 216, CW - 40, 34, StuckActName(stuckAct), (*) => 0)
btnStuckAct.OnEvent("Click", CycleStuckAct.Bind(btnStuckAct))

; ---------------- QoL: Histórico ----------------
BeginPage("Histórico", TT("nav_hist"), TT("pg_hist_sub"))
y := 92
Card(CX, y, CW, 430)
histBtns := Map()
hbw := (CW - 40 - 8) // 2
histBtns["online"]  := Btn(CX + 20, y + 16, hbw, 30, TT("hist_online"), SetHistMetric.Bind("online"), "primary")
histBtns["drops"]   := Btn(CX + 28 + hbw, y + 16, hbw, 30, TT("f_drops"), SetHistMetric.Bind("drops"))
histBtns["reopens"] := Btn(CX + 20, y + 54, hbw, 30, TT("f_reopens"), SetHistMetric.Bind("reopens"))
histBtns["coin"]    := Btn(CX + 28 + hbw, y + 54, hbw, 30, TT("hist_coin", "…"), SetHistMetric.Bind("coin"))
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

CX := CX0, CW := CW0

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
Card(CX, y, CW, 188)
Lbl(CX + 20, y + 16, 300, TT("sec_eco"), "s7 w700", C_DIM)
chkEco := ToggleSwitch(CX + 20, y + 40, CW - 40, TT("sw_eco"), savedEco, TT("sw_eco_sub"))
chkLowGfx := ToggleSwitch(CX + 20, y + 92, CW - 40, TT("sw_lowgfx"), savedLowGfx)
chkMute := ToggleSwitch(CX + 20, y + 122, CW - 40, TT("sw_mute"), savedMute)
chkLowPrio := ToggleSwitch(CX + 20, y + 152, CW - 40, TT("sw_lowprio"), savedLowPrio)

; ---------------- Página: Bot do Discord ----------------
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
Lbl(CX + 20, y + 36, 280, "v" VERSION "  BETA", "s20 w700")
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

y := 484
Card(CX, y, CW, 70)
chkFastUpd := ToggleSwitch(CX + 20, y + 22, CW - 40, TT("sw_fastupd"), savedFastUpd, TT("sw_fastupd_sub"))


; ---------------- Página: Apoie + Suporte ----------------
BeginPage("Suporte", TT("nav_report"), TT("pg_report_sub"))
; --- Apoie o dev (QR sempre à mão) ---
y := 92
Card(CX, y, CW, 160)
try P(g.Add("Picture", Format("x{} y{} w120 h120", CX + 20, y + 20), ASSET_DIR "\donate.png"))
Lbl(CX + 156, y + 22, CW - 176, TT("don_title"), "s13 w700")
Lbl(CX + 156, y + 52, CW - 176, TT("don_msg"), "s9", C_MUTED)
chkDonate := ToggleSwitch(CX + 156, y + 118, CW - 176, TT("sw_donate"), savedDonate, TT("sw_donate_sub"))
chkDonate.onChange := (*) => IniWrite(chkDonate.Value, iniFile, "cfg", "showDonate")

; --- Relatar erro ---
y := 268
Card(CX, y, CW, 284)
Lbl(CX + 20, y + 14, 300, TT("sec_report"), "s7 w700", C_DIM)
Lbl(CX + 20, y + 36, CW - 40, TT("lbl_report"), "s9", C_MUTED)
rbox := g.Add("Text", Format("x{} y{} w{} h92 +0x4000000 Background{}", CX + 20, y + 58, CW - 40, C_INPUT))
Bg(rbox, 10)
P(rbox)
FontUI(g, "s10")
edReport := P(g.Add("Edit", Format("x{} y{} w{} h78 -E0x200 +Multi +Wrap c{} Background{}", CX + 30, y + 66, CW - 60, C_TEXT, C_INPUT)))
chkReportShot := ToggleSwitch(CX + 20, y + 160, CW - 40, TT("sw_report_shot"), "1")
btnPickImg := Btn(CX + 20, y + 196, 150, 30, TT("btn_report_img"), PickReportImg)
repImgLbl := Lbl(CX + 180, y + 203, CW - 360, TT("report_noimg"), "s9", C_MUTED)
btnReport := Btn(CX + CW - 180, y + 194, 160, 40, TT("btn_report_send"), (*) => SendReport(), "primary")
repStatus := Lbl(CX + 20, y + 238, CW - 40, "", "s9 w600", C_TEXT)
Lbl(CX + 20, y + 260, CW - 40, TT("lbl_report_id") ": " ANON_ID, "s8", C_MUTED)

; ---------------- Página: Aparência ----------------
BeginPage("Aparência", TT("nav_look"), TT("pg_look_sub"))
y := 92
Card(CX, y, CW, 470)
Lbl(CX + 20, y + 16, 300, TT("sec_theme"), "s7 w700", C_DIM)
tw := (CW - 40 - 48) // 5, thh := 52
for i, th in THEMES
    ThemeTile(CX + 20 + Mod(i - 1, 5) * (tw + 12), y + 44 + ((i - 1) // 5) * (thh + 26), tw, thh, th)

; ---------------- Página: HUD (sub-aba de Aparência) ----------------
BeginPage("HUD", TT("nav_hud"), TT("pg_hud_sub"))
y := 92
Card(CX, y, CW, 232)
Lbl(CX + 20, y + 16, 300, TT("sec_hud"), "s7 w700", C_DIM)
hudBtns := []
for hi, hk in ["hud_off", "hud_bar", "hud_overlay", "hud_side", "hud_panel"]
    hudBtns.Push(Btn(CX + 20, y + 38 + (hi - 1) * 36, CW - 40, 30, TT(hk), SetHudMode.Bind(hi - 1), (hi - 1 = hudMode) ? "primary" : "sec"))
y += 244
Card(CX, y, CW, 180)
chkFrame := ToggleSwitch(CX + 20, y + 16, CW - 40, TT("sw_frame"), savedFrame, TT("sw_frame_sub"))
chkFrame.onChange := (*) => HudApply()
chkHudComp := ToggleSwitch(CX + 20, y + 62, CW - 40, TT("sw_hudcompact"), savedHudComp)
Lbl(CX + 20, y + 108, CW - 40, TT("hud_hint"), "s8", C_MUTED)

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
vsegs := Map()
vsearch := Map()
for vgk, vsubs in GROUPS {
    if !VGROUPS.Has(vgk)
        continue
    vsegs[vgk] := []
    sbox := g.Add("Text", Format("x{} y96 w{} h32 +0x4000000 Background{}", CX, SUBW, C_INPUT))
    Bg(sbox, 10)
    FontUI(g, "s9")
    sed := g.Add("Edit", Format("x{} y104 w{} h18 -E0x200 c{} Background{}", CX + 12, SUBW - 24, C_TEXT, C_INPUT))
    DllCall("SendMessage", "Ptr", sed.Hwnd, "UInt", 0x1501, "Ptr", 1, "Str", TT("ph_search"))
    sbox.Visible := false, sed.Visible := false
    sed.OnEvent("Change", VFilter.Bind(vgk))
    vsearch[vgk] := {box: sbox, edit: sed}
    for vi, vsb in vsubs {
        FontUI(g, "s10 w600")
        vc := g.Add("Text", Format("x{} y{} w{} h32 +0x200 Background{} c{}", CX, 140 + (vi - 1) * 36, SUBW, C_BG, C_MUTED), "   " TT(NAVK[vsb]))
        FontUI(g, "s8")
        vd := g.Add("Text", Format("x{} y{} w14 h14 +0x200 Center c{} Background{}", CX + SUBW - 22, 140 + (vi - 1) * 36 + 9, C_DIM, C_BG), "●")
        vo := {ctrls: [vc, vd], bg: C_BG, hov: C_NAVH}
        vc.OnEvent("Click", ShowPage.Bind(vsb))
        vd.OnEvent("Click", ShowPage.Bind(vsb))
        hoverMap[vc.Hwnd] := vo
        hoverMap[vd.Hwnd] := vo
        roundQ.Push([vc, 9])
        vsegs[vgk].Push({ctrl: vc, dot: vd, sub: vsb, o: vo, hid: false})
        vc.Visible := false, vd.Visible := false
    }
}
segs := Map()
FontUI(g, "s9 w600")
for gk, subs in GROUPS {
    if (subs.Length < 2 || VGROUPS.Has(gk))
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
; atalhos globais
try Hotkey("^!h", HudToggleUser)
try Hotkey("^!s", (*) => Toggle())
try Hotkey("^!r", (*) => BotRestart())
try Hotkey("^!p", (*) => SendStatusReport(true))
OnMessage(0x201, OnLButtonDown)
SetTimer(SliderPoll, 20)
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
    global g, gk, W, H, savedCompact, iniFile, running, appStarted, chkAutoMon, APP_NAME, donateThenTour
    FadeHide(gk)
    if appStarted {
        FadeShow(g)
        return
    }
    appStarted := true
    firstRun := IniRead(iniFile, "cfg", "tourDone", "0") != "1" && IniRead(iniFile, "cfg", "resume", "0") != "1"
    IniWrite(0, iniFile, "cfg", "compact")          ; sempre abre no modo completo
    IntroShow(g, Format("w{} h{}", W, H))
    SetTimer(PulseTick, 110)
    SetTimer(CpuSample, 2000)
    HudApply()
    SetTimer(Cleanup, 2000)
    SetTimer(WatchError, 3000)
    SetTimer(UpdateStats, 1000)
    SetTimer(() => CheckUpdate(false), -8000)        ; procura atualização 8s depois de abrir
    SetTimer(() => CheckUpdate(false), 6 * 3600000)  ; e a cada 6 horas
    SetTimer(FarmModeTick, 15000)
    SetTimer(() => FarmModeTick(), -6000)
    SetTimer(UpdPoll, 30000)                         ; e uma checagem leve a cada 30s (se ligada)
    if KaEnabled()
        SetTimer(LicenseRecheck, 30 * 60000)         ; confere a licença a cada 30 min
    ; voltou de uma atualização automática com o monitoramento ligado -> liga de novo
    if (IniRead(iniFile, "cfg", "resume", "0") = "1") {
        IniDelete(iniFile, "cfg", "resume")
        SetTimer(() => (running ? 0 : Toggle()), -1500)
    }
    donateNow := (IniRead(iniFile, "cfg", "showDonate", "1") = "1")
    donateThenTour := firstRun && donateNow
    if donateNow
        SetTimer(ShowDonate, -1200)                 ; apoio aparece primeiro
    if (firstRun && !donateNow)
        SetTimer(StartTour, -800)                   ; sem apoio: tutorial direto
    else if (!firstRun && chkAutoMon.Value && !running)
        SetTimer(() => (running ? 0 : Toggle()), -2500)
    SetTimer(() => SendStatusReport(), -7000)   ; manda o status com print assim que abre
    SetTimer(DailyTick, 30000)
    SetTimer(ScheduleTick, 30000)
    SetTimer(BotTick, 6000)
    SetTimer(PanelTick, 30000)
    SetTimer(StuckTick, 60000)
    SetTimer(ReactTick, 9000)
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

Divider(x, y, w) {
    global g
    return P(g.Add("Text", Format("x{} y{} w{} h1 Background{}", x, y, w, "26262D")))
}

; barra deslizante ligada a um campo numérico (o campo continua sendo a fonte do valor)
class SliderBar {
    __New(x, y, w, edit, lo, hi) {
        global g, C_SWOFF, C_ACC, roundQ, sliderList
        this.x := x, this.y := y, this.w := w, this.edit := edit, this.lo := lo, this.hi := hi
        this.track := P(g.Add("Text", Format("x{} y{} w{} h10 +0x100 Background{}", x, y + 6, w, C_SWOFF)))
        this.fill  := P(g.Add("Text", Format("x{} y{} w10 h10 +0x100 Background{}", x, y + 6, C_ACC)))
        this.knob  := P(g.Add("Text", Format("x{} y{} w16 h16 +0x100 Background{}", x, y + 3, C_ACC)))
        roundQ.Push([this.track, 10])
        roundQ.Push([this.fill, 10])
        roundQ.Push([this.knob, 16])
        sliderList.Push(this)
        edit.OnEvent("Change", (*) => this.Sync())
        this.Sync()
    }
    Cur() {
        v := Trim(this.edit.Value)
        return v = "" ? this.lo : Integer(v)
    }
    Sync() {
        this.Draw(this.Cur())
    }
    Draw(v) {
        v := Max(this.lo, Min(this.hi, v))
        px := Round((v - this.lo) / (this.hi - this.lo) * this.w)
        this.fill.Move(, , Max(10, px))
        this.knob.Move(this.x + Max(0, Min(this.w - 16, px - 8)))
        try RoundCtrl(this.fill, 10)
        this.fill.Redraw()
        this.knob.Redraw()
    }
    Drag() {
        global g
        pt := Buffer(8)
        DllCall("GetCursorPos", "Ptr", pt)
        DllCall("ScreenToClient", "Ptr", g.Hwnd, "Ptr", pt)
        mx := NumGet(pt, 0, "Int") / (A_ScreenDPI / 96)
        f := Max(0, Min(1, (mx - this.x) / this.w))
        v := this.lo + Round(f * (this.hi - this.lo))
        if (v != this.Cur())
            this.edit.Value := v
    }
}

; vigia o mouse: clicou em cima de uma barra visível = arrasta até soltar
SliderPoll() {
    global g, sliderList, sliderAct, sliderWas
    down := GetKeyState("LButton", "P")
    if (down && !sliderWas) {
        sliderAct := 0
        MouseGetPos(, , &win)
        if (win = g.Hwnd) {
            pt := Buffer(8)
            DllCall("GetCursorPos", "Ptr", pt)
            DllCall("ScreenToClient", "Ptr", g.Hwnd, "Ptr", pt)
            k := A_ScreenDPI / 96
            mx := NumGet(pt, 0, "Int") / k, my := NumGet(pt, 4, "Int") / k
            for sl in sliderList
                if (sl.track.Visible && mx >= sl.x - 8 && mx <= sl.x + sl.w + 8 && my >= sl.y - 6 && my <= sl.y + 28) {
                    sliderAct := sl
                    break
                }
        }
    }
    if (down && IsObject(sliderAct))
        sliderAct.Drag()
    if !down
        sliderAct := 0
    sliderWas := down
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
    global GROUP_OF, segs, segLine, NAVK, appStarted, curPage, vsegs, vsearch, pageTitleV, pageSubV, C_BG
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
    inV := vsegs.Has(grp)
    for vgk, vlist in vsegs {
        von := (vgk = grp)
        vsearch[vgk].box.Visible := von
        vsearch[vgk].edit.Visible := von
        for sg in vlist {
            sg.ctrl.Visible := von && !sg.hid
            sg.dot.Visible := von && !sg.hid
            if von {
                vact := (sg.sub = name)
                sg.o.bg  := vact ? C_NAVA : C_BG
                sg.o.hov := vact ? C_NAVA : C_NAVH
                sg.ctrl.SetFont("c" (vact ? C_TEXT : C_MUTED))
                sg.dot.SetFont("c" (vact ? C_TEXT : C_DIM))
                AnimColor(sg.o, hoverCur = sg.o ? sg.o.hov : sg.o.bg, 150)
            }
        }
    }
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
    pageSub.Visible := !segs.Has(grp) && !inV
    pageTitleV.Visible := inV
    pageSubV.Visible := inV
    if inV {
        pageTitleV.Value := TT(NAVK[name])
        pageSubV.Value := pageInfo[name][2]
    }
}

; busca na lista lateral: mostra só as seções que têm o texto digitado
VFilter(vgk, *) {
    global vsegs, vsearch, pages
    q := Trim(vsearch[vgk].edit.Value)
    row := 0
    for sg in vsegs[vgk] {
        ok := (q = "")
        if !ok {
            if InStr(TT(NAVK[sg.sub]), q)
                ok := true
            else
                for c in pages[sg.sub] {
                    try {
                        if (c.Type = "Text" && c.Text != "" && InStr(c.Text, q)) {
                            ok := true
                            break
                        }
                    }
                }
        }
        sg.hid := !ok
        sg.ctrl.Visible := ok
        sg.dot.Visible := ok
        if ok {
            ty := 140 + row * 36
            sg.ctrl.Move(, ty)
            sg.dot.Move(, ty + 9)
            row++
        }
    }
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
; decide se um evento automático vai pro webhook (controlado pelos toggles da aba Notificações)
WhAllowed(kind) {
    global chkWhReopen, chkWhDrop, chkWhError, chkWhUpdate
    if !IsSet(chkWhReopen)
        return true
    reopen := ",start,stop,reopen,restart,back,backin,cancel,"
    drop := ",down,stuck,"
    err := ",fail,error,lic,neterr,netok,"
    upd := ",updated,updnone,updating,"
    k := "," kind ","
    if InStr(reopen, k)
        return chkWhReopen.Value
    if InStr(drop, k)
        return chkWhDrop.Value
    if InStr(err, k)
        return chkWhError.Value
    if InStr(upd, k)
        return chkWhUpdate.Value
    return true
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
    global chkEco, chkLowGfx, chkMute
    if !chkEco.Value
        return
    f := EnvGet("LOCALAPPDATA") "\Roblox\GlobalBasicSettings_13.xml"
    if !FileExist(f)
        return
    try {
        x := FileRead(f, "UTF-8")
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

TokClean() {
    global edToken, botBad
    static lastTok := ""
    t := Trim(edToken.Value)
    t := RegExReplace(t, "i)^Bot\s+", "")
    t := Trim(t, ' "`t`r`n' "'")
    if (t != lastTok)
        lastTok := t, botBad := false
    return t
}

BotTick() {
    global chkBot, edToken, edChan, edDiscId, botLast, botStatus, botBusy
    if !chkBot.Value {
        SetIf(botStatus, TT("bot_off"))
        return
    }
    tok := TokClean(), ch := Trim(edChan.Value), me := Trim(edDiscId.Value)
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
    global botLast, botStatus, botBusy, botBad
    botBusy := 0
    try {
        if (HttpStatus(http) = 401) {
            botBad := true
            SetIf(botStatus, TT("bot_401"))
            return
        }
        if (HttpStatus(http) != 200)
            throw Error("HTTP " HttpStatus(http))
        flat := JsFlatMessages(http.ResponseText)
    } catch as e {
        SetIf(botStatus, TT("bot_err", e.Message))
        return
    }
    botBad := false
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
    global running, multiActive, monStart, botCtx, edLink, pendingUpd, pendingVer, restartReply, chkPanel
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
            case "!statsaovivo", "!painel", "!stats", "!live":
                chkPanel.Value := 1
                SaveConfig()
                botCtx := 0
                SetTimer(() => PanelUpdate(true), -600)
            case "!grafico", "!gráfico", "!chart":
                BotChart()
            case "!gif", "!timelapse":
                BotGif()
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
    return [[TT("f_session"), AfkStr(), true]
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
            . "`n``!contas`` " TT("cmd_accounts") "`n``!logs`` " TT("cmd_logs") "`n``!statsaovivo`` " TT("cmd_panel") "`n``!grafico`` " TT("cmd_chart") "`n``!gif`` " TT("cmd_gif") "`n``!ping`` " TT("cmd_ping"), false]
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

; log de diagnóstico da leitura do modo (no máximo 1x a cada 2 min)
FarmDbg(msg) {
    global farmDbgT
    if (A_TickCount - farmDbgT < 120000)
        return
    farmDbgT := A_TickCount
    Log("Modo · " msg)
}

; cor "de verdade" do texto na tela: pega a cor viva mais comum dentro do retângulo (coords do cliente do Roblox)
SampleTextColor(hw, rx, ry, rw, rh) {
    pt := Buffer(8, 0)
    NumPut("Int", rx, pt, 0), NumPut("Int", ry, pt, 4)
    DllCall("ClientToScreen", "Ptr", hw, "Ptr", pt)
    sx := NumGet(pt, 0, "Int"), sy := NumGet(pt, 4, "Int")
    dc := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !dc
        return ""
    cnt := Map(), sum := Map()
    sxp := Max(1, rw // 50), syp := Max(1, rh // 10)
    yy := 0
    while (yy < rh) {
        xx := 0
        while (xx < rw) {
            c := DllCall("GetPixel", "Ptr", dc, "Int", sx + xx, "Int", sy + yy, "UInt")
            if (c != 0xFFFFFFFF) {
                r := c & 0xFF, g := (c >> 8) & 0xFF, b := (c >> 16) & 0xFF
                mx := Max(r, g, b), mn := Min(r, g, b)
                if (mx >= 140 && mx - mn >= 60) {
                    key := (r // 40) "," (g // 40) "," (b // 40)
                    if !cnt.Has(key)
                        cnt[key] := 0, sum[key] := [0, 0, 0]
                    cnt[key]++
                    sum[key][1] += r, sum[key][2] += g, sum[key][3] += b
                }
            }
            xx += sxp
        }
        yy += syp
    }
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", dc)
    bk := "", bn := 0
    for key, n in cnt
        if (n > bn)
            bn := n, bk := key
    if (bk = "" || bn < 3)
        return ""
    sm := sum[bk]
    return Format("{:02X}{:02X}{:02X}", sm[1] // bn, sm[2] // bn, sm[3] // bn)
}

LineRect(line) {
    x1 := 99999, y1 := 99999, x2 := 0, y2 := 0
    for wd in line.Words {
        x1 := Min(x1, wd.x), y1 := Min(y1, wd.y)
        x2 := Max(x2, wd.x + wd.w), y2 := Max(y2, wd.y + wd.h)
    }
    return [x1, y1, x2 - x1, y2 - y1]
}

; lê (só olhando a tela) o nome do modo/mapa, o contador de pearls e as cores deles, em cima da vida da base
FarmModeTick() {
    global farmMode, farmWave, farmMiss, hudMode, chkPanel, farmPearls, farmPrev, farmModeCol, farmPearlCol, farmBest
    if !(hudMode = 4 || chkPanel.Value)
        return
    hw := FindGameWindow()
    if !(hw && WinGetMinMax(hw) != -1 && DllCall("IsWindowVisible", "Ptr", hw)) {
        farmMode := "", farmWave := ""
        return
    }
    static variants := [{mode: 0}, {mode: 4}, {mode: 4, gray: 1}, {mode: 0, gray: 1}]
    mode := "", wave := "", pearls := "", mRect := 0, pRect := 0, seen := "", err := ""
    try {
        WinGetClientPos(, , &cw, &chh, hw)
        ox := Round(cw * 0.08), oy := Round(chh * 0.01), ow := Round(cw * 0.72), oh := Round(chh * 0.22)
        lim := OCR.MaxImageDimension ? OCR.MaxImageDimension : 2600
        sc := Max(0.5, Min(3, Floor((lim - 20) / Max(ow, oh) * 10) / 10))
        Loop variants.Length {
            vi := Mod(farmBest - 1 + A_Index - 1, variants.Length) + 1
            v := variants[vi]
            o := {x: ox, y: oy, w: ow, h: oh, scale: sc, mode: v.mode}
            if v.HasOwnProp("gray")
                o.grayscale := 1, o.invertcolors := 1
            res := ""
            try res := OCR.FromWindow("ahk_id " hw, o)
            catch as e1 {
                err := e1.Message
                continue
            }
            seen := SubStr(RegExReplace(res.Text, "\s+", " "), 1, 110)
            for line in res.Lines {
                t := Trim(RegExReplace(line.Text, "\s+", " "))
                hasW := false, hasP := false
                if RegExMatch(t, "i)wave\s*([0-9OolI]{1,4})", &m) {
                    hasW := true
                    if (wave = "")
                        wave := StrReplace(StrReplace(StrReplace(m[1], "O", "0"), "o", "0"), "l", "1")
                    wave := StrReplace(wave, "I", "1")
                }
                if RegExMatch(t, "\+\s*(\d[\d.,]*[kKmMbB]?)", &pm) {
                    hasP := true
                    if (pearls = "") {
                        pearls := pm[1], pRect := LineRect(line)
                        for wd in line.Words
                            if InStr(wd.Text, pm[1]) {
                                pRect := [wd.x, wd.y, wd.w, wd.h]
                                break
                            }
                    }
                }
                if (!hasW && !hasP && mode = "" && RegExMatch(t, "[A-Za-z]{4}") && !RegExMatch(t, "\d{3,}\s*/\s*\d{3,}")) {
                    mode := RegExReplace(t, "\)(?=[A-Za-z])", ") ")
                    mRect := LineRect(line)
                    farmBest := vi
                }
            }
            if (mode != "" && wave != "" && pearls != "")
                break
        }
    } catch as e {
        FarmDbg("erro na leitura: " e.Message)
        return
    }
    if (mode = "" && wave = "") {
        FarmDbg("OCR não achou o modo. Leu: [" seen "]" (err != "" ? " erro: " err : ""))
        if (++farmMiss >= 3)
            farmMode := "", farmWave := ""
        return
    }
    if (wave = "" || pearls = "")
        FarmDbg("modo lido, mas faltou " (wave = "" ? "wave " : "") (pearls = "" ? "pearls " : "") ". Leu: [" seen "]")
    if (mode != "") {
        mode := SubStr(mode, 1, 50)
        if (farmPearls != "" && (mode != farmMode || (pearls != "" && ParseNum(pearls) != "" && ParseNum(farmPearls) != "" && ParseNum(pearls) < ParseNum(farmPearls) * 0.5)))
            farmPrev := farmPearls
        farmMode := mode
        if IsObject(mRect) {
            cc := SampleTextColor(hw, mRect[1], mRect[2], mRect[3], mRect[4])
            if (cc != "")
                farmModeCol := cc
        }
    }
    if (pearls != "") {
        farmPearls := pearls
        if IsObject(pRect) {
            cc := SampleTextColor(hw, pRect[1], pRect[2], pRect[3], pRect[4])
            if (cc != "")
                farmPearlCol := cc
        }
    }
    farmWave := wave != "" ? wave : farmWave, farmMiss := 0
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
    global lastDiscUnix, discTick, dayOnline, chkOcr, APP_NAME, USER_NAME, LOGO_URL, VERSION, curState, prevCur
    global botBad, edHook, panelVia, farmMode, farmWave, farmPearls, farmPrev
    if !chkPanel.Value {
        if force
            Log("Painel · ligue o toggle 'Painel fixo no canal'")
        return
    }
    tok := TokClean(), ch := Trim(edChan.Value), hook := RegExReplace(Trim(edHook.Value), "\?.*$")
    useBot := chkBot.Value && tok != "" && ch != "" && !botBad
    if (!useBot && hook = "") {
        if force
            Log("Painel · configure o Bot (token + canal) ou o link do Webhook")
        return
    }
    via := useBot ? "bot" : "hook"
    if (via != panelVia) {                    ; trocou de bot pra webhook (ou o contrário): recria a mensagem
        panelMsg := "", panelVia := via
        IniWrite(via, iniFile, "cfg", "panelVia")
    }
    if (!force && A_TickCount - panelLast < 20000)
        return
    if force
        Log("Painel · montando embed…")
    panelLast := A_TickCount

    try {
    open := IsRobloxOpen()
    if !open
        title := "🔴  Offline", color := 0xFF5C5C
    else if discTick
        title := "🟡  " TT("emb_warn"), color := 0xF5C542
    else
        title := "🟢  " TT("emb_online"), color := 0x3DDC84
    if !running
        title .= "  ·  " TT("up_stopped"), color := 0x8B8B94

    ; painel leve: usa as moedas já lidas (prevCur) e dados rápidos — nada de OCR/WMI que trava
    shot := "", coins := ""
    for c in CurrencySpec()
        if (prevCur.Has(c.name) && prevCur[c.name] != "")
            coins .= c.emoji "  **" prevCur[c.name] "**  ·  " c.name "`n"
    DayRoll()
    ms := Buffer(64, 0), NumPut("UInt", 64, ms), DllCall("GlobalMemoryStatusEx", "Ptr", ms)
    cpu := CpuLoad(), ramPct := NumGet(ms, 4, "UInt")
    now := DateDiff(A_NowUTC, "19700101000000", "Seconds")
    desc := (coins != "" ? "### Player Stats`n" coins "`n" : "")
        . "**" TT("f_cpu") "**  " cpu "%`n**" TT("f_ram") "**  " ramPct "%"
        . "`n`n🔄 " TT("d_updated") " <t:" now ":R>"
    fields := []
    if (farmMode != "")
        fields.Push([TT("f_mode"), farmMode (farmWave != "" ? "  ·  Wave " farmWave : ""), false])
    if (farmMode != "" && farmPearls != "")
        fields.Push(["🦪 Pearls", "+" farmPearls, true])
    if (farmPrev != "")
        fields.Push([TT("f_prevround"), "+" farmPrev, true])
    for f in [[TT("f_session"), AfkStr(), true]
        , [TT("f_online_today"), DurStr(dayOnline * 1000), true]
        , [TT("f_reopens"), launches, true], [TT("f_drops"), discCount, true]
        , [TT("f_lastdrop"), lastDiscUnix ? "<t:" lastDiscUnix ":R>" : TT("none"), true]]
        fields.Push(f)
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    pbody := '"embeds":[{'
        . '"author":{"name":"' JsonEsc(APP_NAME "  ·  " TT("ev_panel")) '","icon_url":"' LOGO_URL '"},'
        . '"title":"' JsonEsc(title) '","color":' color ','
        . '"description":"' JsonEsc(desc) '",' FieldsJson(fields)
        . '"thumbnail":{"url":"' LOGO_URL '"},'
        . (shot != "" ? '"image":{"url":"attachment://roblox.png"},' : '')
        . '"footer":{"text":"' JsonEsc(USER_NAME "  •  " A_ComputerName "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
        . '"timestamp":"' ts '"}],'
        . '"attachments":' (shot != "" ? '[{"id":0,"filename":"roblox.png"}]' : '[]') '}'
    payload := '{"allowed_mentions":{"parse":[]},' pbody
    base := "https://discord.com/api/v10/channels/" ch "/messages"
    if force
        Log("Painel · enviando ao Discord…")
    if !useBot {
        payloadC := '{"username":"Auto Reconnect","avatar_url":"' LOGO_URL '","allowed_mentions":{"parse":[]},' pbody
        try {
            if (panelMsg != "")
                AsyncReq("PATCH", hook "/messages/" panelMsg, payload, "application/json", "", PanelPatchedH.Bind(hook, payloadC))
            else
                AsyncReq("POST", hook "?wait=true", payloadC, "application/json", "", PanelCreatedH)
        } catch as e
            Log("Painel · " TT("hook_fail", e.Message))
        return
    }
    try {
        if (panelMsg != "")
            AsyncReq("PATCH", base "/" panelMsg, payload, "application/json", "Bot " tok, PanelPatched.Bind(base, payload, "", tok, ch))
        else
            PanelCreate(base, payload, "", tok, ch)
    } catch as e
        Log("Painel · " TT("hook_fail", e.Message))
    } catch as e2
        Log("Painel · ERRO montando: " e2.Message " [linha " e2.Line "]")
}

PanelPatchedH(hook, payloadC, http) {
    global panelMsg
    st := HttpStatus(http)
    if (st >= 200 && st < 300)
        return
    panelMsg := ""
    Log("Painel · " TT("hook_fail", "edit HTTP " st " → recriando"))
    AsyncReq("POST", hook "?wait=true", payloadC, "application/json", "", PanelCreatedH)
}

PanelCreatedH(http) {
    global panelMsg, iniFile
    st := HttpStatus(http)
    if (st < 200 || st >= 300) {
        rt := ""
        try rt := http.ResponseText
        Log("Painel · " TT("hook_fail", "HTTP " st "  " SubStr(rt, 1, 150)))
        return
    }
    try {
        panelMsg := JsonPick(http.ResponseText, "a.id")
        IniWrite(panelMsg, iniFile, "cfg", "panelMsg")
        Log("Painel · " TT("hook_sent", st))
    }
}

PanelPatched(base, payload, shot, tok, ch, http) {
    global panelMsg
    st := HttpStatus(http)
    if (st >= 200 && st < 300)
        return
    panelMsg := ""                            ; qualquer falha (apagada/antiga): recria do zero
    Log("Painel · " TT("hook_fail", "edit HTTP " st " → recriando"))
    PanelCreate(base, payload, shot, tok, ch)
}

PanelCreate(base, payload, shot, tok, ch) {
    AsyncReq("POST", base, payload, "application/json", "Bot " tok, PanelCreated.Bind(tok, ch))
}

PanelCreated(tok, ch, http) {
    global panelMsg, iniFile, reactReady
    st := HttpStatus(http)
    if (st < 200 || st >= 300) {
        rt := ""
        try rt := http.ResponseText
        Log("Painel · " TT("hook_fail", "HTTP " st "  " SubStr(rt, 1, 150)))
        return
    }
    try {
        panelMsg := JsonPick(http.ResponseText, "a.id")
        IniWrite(panelMsg, iniFile, "cfg", "panelMsg")
        IniWrite("bot", iniFile, "cfg", "panelVia")
        reactReady := false
        AsyncReq("PUT", "https://discord.com/api/v10/channels/" ch "/pins/" panelMsg, "", "", "Bot " tok)
        Log("Painel · " TT("hook_sent", st))
    }
}

; ==========================================================
;  HUD grudado na janela do Roblox (barra embaixo ou painel no canto) + moldura de status
;  Fica "dono" da janela do Roblox: anda junto, some quando ela minimiza e não fica por cima de outros apps.
; ==========================================================
HudToggleUser(*) {
    global hudUserHidden
    hudUserHidden := !hudUserHidden
    HudTick(true)
}

HudModeName(m) {
    return TT("hud_mode") ": " TT(["hud_off", "hud_bar", "hud_overlay", "hud_side", "hud_panel"][m + 1])
}

SetHudMode(m, *) {
    global hudMode, hudBtns
    hudMode := m
    if (m = 4)
        SetTimer(() => FarmModeTick(), -400)
    for i, bt in hudBtns
        SetBtnStyle(bt, (i - 1 = m) ? "primary" : "sec")
    HudApply()
}

HudBuild() {
    global hudBar, hudBarDot, hudBarL, hudBarR, hudPan, hudPanDot, hudPanT, hudPanL, hudFrame, hudSide, hudSideDot, hudSideT, hudSideL, C_CARD, C_TEXT, C_MUTED, C_DIM
    k := A_ScreenDPI / 96
    ; barra (clicável: abre o programa)
    hudBar := Gui("-Caption +ToolWindow -DPIScale +E0x08000000")
    hudBar.BackColor := C_CARD
    hudBar.MarginX := 0, hudBar.MarginY := 0
    FontUI(hudBar, "s" Round(9) " w700")
    hudBarDot := hudBar.Add("Text", Format("x{} y0 w{} h{} +0x200 c{} Background{}", Round(10 * k), Round(16 * k), Round(28 * k), C_DIM, C_CARD), "●")
    FontUI(hudBar, "s9")
    hudBarL := hudBar.Add("Text", Format("x{} y0 w{} h{} +0x200 c{} Background{}", Round(28 * k), Round(600 * k), Round(28 * k), C_TEXT, C_CARD), "")
    hudBarR := hudBar.Add("Text", Format("x0 y0 w{} h{} +0x200 Right c{} Background{}", Round(150 * k), Round(28 * k), C_MUTED, C_CARD), "")
    for c in [hudBarDot, hudBarL, hudBarR]
        c.OnEvent("Click", (*) => ShowMain())
    ; painel no canto (clique passa direto pro jogo)
    hudPan := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +E0x20")
    hudPan.BackColor := C_CARD
    hudPan.MarginX := 0, hudPan.MarginY := 0
    FontUI(hudPan, "s10")
    hudPanDot := hudPan.Add("Text", Format("x{} y{} w{} c{} Background{}", Round(12 * k), Round(8 * k), Round(16 * k), C_DIM, C_CARD), "●")
    FontUI(hudPan, "s10 w700")
    hudPanT := hudPan.Add("Text", Format("x{} y{} w{} c{} Background{}", Round(30 * k), Round(8 * k), Round(200 * k), C_TEXT, C_CARD), "")
    FontUI(hudPan, "s8")
    hudPanL := hudPan.Add("Text", Format("x{} y{} w{} h{} c{} Background{}", Round(12 * k), Round(30 * k), Round(220 * k), Round(62 * k), C_MUTED, C_CARD), "")
    ; painel lateral direito (clicável: abre o programa) com stats completos
    hudSide := Gui("-Caption +ToolWindow -DPIScale +E0x08000000")
    hudSide.BackColor := C_CARD
    hudSide.MarginX := 0, hudSide.MarginY := 0
    FontUI(hudSide, "s9 w700")
    hudSideDot := hudSide.Add("Text", Format("x{} y{} w{} c{} Background{}", Round(14 * k), Round(12 * k), Round(16 * k), C_DIM, C_CARD), "●")
    hudSideT := hudSide.Add("Text", Format("x{} y{} w{} c{} Background{}", Round(32 * k), Round(12 * k), Round(188 * k), C_TEXT, C_CARD), "")
    FontUI(hudSide, "s9")
    hudSideL := hudSide.Add("Text", Format("x{} y{} w{} h{} c{} Background{}", Round(14 * k), Round(42 * k), Round(210 * k), Round(270 * k), C_MUTED, C_CARD), "")
    for c in [hudSideDot, hudSideT, hudSideL]
        c.OnEvent("Click", (*) => ShowMain())
    ; moldura
    hudFrame := Gui("-Caption +ToolWindow -DPIScale +E0x08000000 +E0x20")
    hudFrame.BackColor := C_DIM
    HudBuildPanel()
}

; painel de farm: fica do lado esquerdo do Roblox (Status, Modo de farm, Moedas e Logs)
HudBuildPanel() {
    global hudPnl, hudPnlW, hudPnlLogN, VERSION, C_BG, C_CARD, C_TEXT, C_MUTED, C_DIM, C_ACC, C_NAVA
    hudPnlLogN := 6
    hudPnl := Gui("-Caption +ToolWindow -DPIScale +E0x08000000")
    hudPnl.BackColor := C_BG
    hudPnl.MarginX := 0, hudPnl.MarginY := 0
    hudPnlW := Map()
    AddT := (nm, fnt, fg, bg, opt, txt := "") => (FontUI(hudPnl, fnt), hudPnlW[nm] := hudPnl.Add("Text", "x0 y0 w10 h10 +0x100 " opt " c" fg " Background" bg, txt))
    AddT("title", "s10 w700", C_TEXT, C_BG, "+0x200", "Auto Reconnect")
    AddT("dot", "s10", C_DIM, C_BG, "+0x200 Right", "●")
    AddT("hello", "s8", C_MUTED, C_BG, "+0x200")
    for n in ["st", "md", "co", "lg"] {
        hudPnlW[n "F"] := hudPnl.Add("Text", "x0 y0 w10 h10 +0x100 Background" C_NAVA)
        hudPnlW[n "I"] := hudPnl.Add("Text", "x0 y0 w10 h10 +0x100 Background" C_CARD)
    }
    AddT("stT", "s9 w700", C_TEXT, C_CARD, "+0x200")
    AddT("stS", "s8", C_MUTED, C_CARD, "+0x200")
    AddT("mdN", "s10 w700", C_TEXT, C_CARD, "")
    AddT("mdW", "s8", C_MUTED, C_CARD, "+0x200")
    AddT("mdP", "s14 w700", C_TEXT, C_CARD, "+0x200")
    AddT("mdA", "s8", C_DIM, C_CARD, "+0x200")
    AddT("coT", "s8", C_TEXT, C_CARD, "")
    AddT("lgT", "s8", C_MUTED, C_CARD, "")
    for n, ky in Map("st", "hud_box_status", "md", "f_mode", "co", "nav_coins", "lg", "nav_logs")
        AddT(n "H", "s7 w700", C_ACC, C_BG, "+0x200 Center", StrUpper(TT(ky)))
    AddT("role", "s8", C_DIM, C_BG, "+0x200", "BETA  ·  v" VERSION)
    AddT("upd", "s8 w700", C_BG, C_ACC, "+0x200 Center", TT("hud_newupd"))
    hudPnlW["upd"].Visible := false
    for n, c in hudPnlW
        c.OnEvent("Click", (*) => ShowMain())
}

HudBox(n, x, y, w, h, k) {
    global hudPnlW
    hudPnlW[n "F"].Move(x, y, w, h)
    hudPnlW[n "I"].Move(x + 1, y + 1, w - 2, h - 2)
    RoundCtrl(hudPnlW[n "F"], 10)
    RoundCtrl(hudPnlW[n "I"], 9)
    tw := Round(90 * k)
    hudPnlW[n "H"].Move(x + Round(12 * k), y - Round(8 * k), tw, Round(16 * k))
}

HudPanelLayout(pw, ph, k) {
    global hudPnlW, hudPnlLogN
    m := Round(10 * k), bw := pw - 2 * m, pad := Round(12 * k), tw := bw - 2 * pad
    hudPnlW["title"].Move(Round(14 * k), Round(11 * k), pw - Round(60 * k), Round(20 * k))
    hudPnlW["dot"].Move(pw - Round(40 * k), Round(11 * k), Round(26 * k), Round(20 * k))
    hudPnlW["hello"].Move(Round(14 * k), Round(31 * k), pw - Round(28 * k), Round(16 * k))
    y := Round(62 * k)
    h := Round(62 * k)
    HudBox("st", m, y, bw, h, k)
    hudPnlW["stT"].Move(m + pad, y + Round(14 * k), tw, Round(20 * k))
    hudPnlW["stS"].Move(m + pad, y + Round(36 * k), tw, Round(18 * k))
    y += h + Round(18 * k), h := Round(116 * k)
    HudBox("md", m, y, bw, h, k)
    hudPnlW["mdN"].Move(m + pad, y + Round(14 * k), tw, Round(36 * k))
    hudPnlW["mdW"].Move(m + pad, y + Round(52 * k), tw, Round(16 * k))
    hudPnlW["mdP"].Move(m + pad, y + Round(68 * k), tw, Round(28 * k))
    hudPnlW["mdA"].Move(m + pad, y + Round(96 * k), tw, Round(16 * k))
    y += h + Round(18 * k), h := Round(70 * k)
    HudBox("co", m, y, bw, h, k)
    hudPnlW["coT"].Move(m + pad, y + Round(14 * k), tw, h - Round(18 * k))
    y += h + Round(18 * k)
    h := Max(Round(70 * k), ph - y - Round(40 * k))
    HudBox("lg", m, y, bw, h, k)
    hudPnlW["lgT"].Move(m + pad, y + Round(14 * k), tw, h - Round(18 * k))
    hudPnlLogN := Max(3, (h - Round(22 * k)) // Round(15 * k))
    hudPnlW["role"].Move(m + Round(4 * k), ph - Round(28 * k), Round(120 * k), Round(20 * k))
    hudPnlW["upd"].Move(pw - m - Round(150 * k), ph - Round(30 * k), Round(150 * k), Round(22 * k))
    RoundCtrl(hudPnlW["upd"], 11)
}

; troca a cor de um controle só quando mudou (evita piscar)
HudCol(nm, col) {
    global hudPnlW, hudColCache
    if (col = "" || (hudColCache.Has(nm) && hudColCache[nm] = col))
        return
    hudColCache[nm] := col
    hudPnlW[nm].SetFont("c" col)
}

HudPanelText() {
    global hudPnlW, hudLogs, hudPnlLogN, USER_FIRST, running, monStart, launches, discCount, prevCur, dashTitle, pendingUpd
    global farmMode, farmWave, farmPearls, farmPrev, farmModeCol, farmPearlCol, curStateCol, C_TEXT, C_MUTED
    SetIf(hudPnlW["hello"], TT("hud_welcome", USER_FIRST))
    HudCol("dot", curStateCol)
    SetIf(hudPnlW["stT"], dashTitle.Value)
    SetIf(hudPnlW["stS"], "⏱ " (AfkStr()) "    🔁 " launches "    📉 " discCount)
    if (farmMode != "") {
        SetIf(hudPnlW["mdN"], farmMode)
        HudCol("mdN", farmModeCol != "" ? farmModeCol : C_TEXT)
        SetIf(hudPnlW["mdW"], farmWave != "" ? "Wave " farmWave : "")
        SetIf(hudPnlW["mdP"], farmPearls != "" ? "🦪 +" farmPearls : "")
        HudCol("mdP", farmPearlCol != "" ? farmPearlCol : C_TEXT)
        SetIf(hudPnlW["mdA"], farmPrev != "" ? TT("f_prevround") ": +" farmPrev : "")
    } else {
        SetIf(hudPnlW["mdN"], TT("f_reading"))
        HudCol("mdN", C_MUTED)
        SetIf(hudPnlW["mdW"], "")
        SetIf(hudPnlW["mdP"], "")
        SetIf(hudPnlW["mdA"], "")
    }
    co := ""
    for c in CurrencySpec()
        if (prevCur.Has(c.name) && prevCur[c.name] != "")
            co .= DefaultEmoji(c.name) " " c.name ": " Compact(prevCur[c.name]) "`n"
    SetIf(hudPnlW["coT"], co = "" ? "—" : RTrim(co, "`n"))
    lg := ""
    i := Max(1, hudLogs.Length - hudPnlLogN + 1)
    while (i <= hudLogs.Length) {
        lg .= hudLogs[i] "`n"
        i++
    }
    SetIf(hudPnlW["lgT"], RTrim(lg, "`n"))
    hudPnlW["upd"].Visible := (pendingUpd != "")
}

HudPanelPos(v, k, h) {
    global hudMode, hudPnl
    static lastKey := ""
    if (hudMode != 4) {
        try hudPnl.Hide()
        lastKey := ""
        return
    }
    pw := Round(244 * k), ph := Max(Round(470 * k), h)
    MonitorGetWorkArea(MonitorGetPrimary(), &wl)
    px := (v[1] - pw >= wl) ? v[1] - pw : v[1]
    key := px "," v[2] "," pw "," ph
    if (key = lastKey && DllCall("IsWindowVisible", "Ptr", hudPnl.Hwnd))
        return
    lastKey := key
    HudPanelLayout(pw, ph, k)
    hudPnl.Show(Format("NA x{} y{} w{} h{}", px, v[2], pw, ph))
    try WinSetTransparent((px < v[1]) ? "Off" : 235, hudPnl.Hwnd)
    DllCall("SetWindowRgn", "Ptr", hudPnl.Hwnd, "Ptr", DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", pw + 1, "Int", ph + 1, "Int", Round(16 * k), "Int", Round(16 * k), "Ptr"), "Int", 1)
}

HudApply() {
    global hudMode, chkFrame, hudBar
    if !IsObject(hudBar)
        HudBuild()
    if (hudMode || chkFrame.Value)
        SetTimer(HudTick, 250)
    else
        SetTimer(HudTick, 0)
    HudTick(true)
}

HudHideAll() {
    global hudBar, hudPan, hudFrame, hudSide, hudShown, hudPnl
    for w in [hudBar, hudPan, hudFrame, hudSide, hudPnl]
        try w.Hide()
    hudShown := false
}

; dono = janela do Roblox (o HUD acompanha ela)
HudOwn(gui, hw) {
    DllCall(A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong", "Ptr", gui.Hwnd, "Int", -8, "Ptr", hw)
}

HudTick(force := false) {
    global hudPnl
    global hudMode, chkFrame, hudBar, hudBarDot, hudBarL, hudBarR, hudPan, hudPanDot, hudPanT, hudPanL, hudFrame, hudSide, hudSideDot, hudSideT, hudSideL
    global hudLastPos, hudLastHw, hudN, hudUserHidden, hudShown, hudFrameCol
    global curState, curStateCol, running, monStart, launches, discCount, prevCur, dashTitle, dayOnline
    if !IsObject(hudBar)
        return
    hw := FindGameWindow()
    if (hudUserHidden || !hw || DllCall("IsIconic", "Ptr", hw) || !DllCall("IsWindowVisible", "Ptr", hw)
        || (!hudMode && !chkFrame.Value)) {
        if hudShown
            HudHideAll()
        hudLastPos := ""
        return
    }
    k := A_ScreenDPI / 96
    v := VisibleRect(hw)
    pos := v[1] "," v[2] "," v[3] "," v[4] "," hudMode "," chkFrame.Value
    moved := force || pos != hudLastPos || hw != hudLastHw
    if (hw != hudLastHw) {
        for w in [hudBar, hudPan, hudFrame, hudSide, hudPnl]
            HudOwn(w, hw)
        hudLastHw := hw
    }
    ; ---- texto (1x por segundo) ----
    if (force || moved || Mod(++hudN, 4) = 0) {
        col := curStateCol
        stats := (running ? "⏱ " DurStr(A_TickCount - monStart) : TT("up_stopped")) "   🔁 " launches "   📉 " discCount
        coins := ""
        for c in CurrencySpec()
            if (prevCur.Has(c.name) && prevCur[c.name] != "")
                coins .= "   " DefaultEmoji(c.name) " " Compact(prevCur[c.name])
        ms := Buffer(64, 0), NumPut("UInt", 64, ms), DllCall("GlobalMemoryStatusEx", "Ptr", ms)
        pc := "CPU " CpuLoad() "%  ·  RAM " NumGet(ms, 4, "UInt") "%"
        if (hudMode = 1) {
            hudBarDot.SetFont("c" col)
            SetIf(hudBarL, dashTitle.Value "   " stats coins)
            SetIf(hudBarR, pc)
        } else if (hudMode = 2) {
            hudPanDot.SetFont("c" col)
            SetIf(hudPanT, dashTitle.Value)
            SetIf(hudPanL, stats (coins != "" ? "`n" LTrim(coins) : "") "`n" pc)
        } else if (hudMode = 3) {
            hudSideDot.SetFont("c" col)
            SetIf(hudSideT, dashTitle.Value)
            ln := "⏱ " (AfkStr())
            ln .= "`n🔁 " TT("f_reopens") ": " launches "    📉 " TT("f_drops") ": " discCount
            ln .= "`n🟢 " TT("f_online_today") ": " DurStr(dayOnline * 1000)
            for c in CurrencySpec()
                if (prevCur.Has(c.name) && prevCur[c.name] != "")
                    ln .= "`n" DefaultEmoji(c.name) " " c.name ": " Compact(prevCur[c.name])
            ln .= "`n`n🖥 CPU " CpuLoad() "%   ·   RAM " NumGet(ms, 4, "UInt") "%"
            rram := RobloxMaxRamMB()
            if (rram >= 0)
                ln .= "`n🎮 Roblox: " (rram >= 1024 ? Round(rram / 1024, 2) " GB" : rram " MB")
            SetIf(hudSideL, ln)
        } else if (hudMode = 4)
            HudPanelText()
        if (chkFrame.Value && col != hudFrameCol) {
            hudFrame.BackColor := col
            hudFrameCol := col
        }
    }
    if !moved {
        if !hudShown
            moved := true
        else
            return
    }
    hudLastPos := pos
    ; ---- posição ----
    w := v[3] - v[1], h := v[4] - v[2]
    if (hudMode = 1) {
        bh := Round(28 * k)
        MonitorGetWorkArea(MonitorGetPrimary(), , , , &wb)
        by := (v[4] + bh <= wb) ? v[4] : v[4] - bh       ; embaixo da janela; se não couber, por dentro
        hudBarL.Move(, , w - Round(190 * k))
        hudBarR.Move(w - Round(160 * k), , Round(150 * k))
        hudBar.Show(Format("NA x{} y{} w{} h{}", v[1], by, w, bh))
        DllCall("SetWindowRgn", "Ptr", hudBar.Hwnd, "Ptr", DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w + 1, "Int", bh + 1, "Int", Round(10 * k), "Int", Round(10 * k), "Ptr"), "Int", 1)
    } else
        try hudBar.Hide()
    if (hudMode = 2) {
        WinGetClientPos(&cx, &cy, , , hw)
        pw := Round(244 * k), ph := Round(98 * k)
        hudPan.Show(Format("NA x{} y{} w{} h{}", cx + Round(12 * k), cy + Round(60 * k), pw, ph))
        WinSetTransparent(225, hudPan.Hwnd)
        DllCall("SetWindowRgn", "Ptr", hudPan.Hwnd, "Ptr", DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", pw + 1, "Int", ph + 1, "Int", Round(14 * k), "Int", Round(14 * k), "Ptr"), "Int", 1)
    } else
        try hudPan.Hide()
    if (hudMode = 3) {
        sw := Round(234 * k), sh := Round(326 * k)
        MonitorGetWorkArea(MonitorGetPrimary(), , , &wr)
        sx := (v[3] + sw <= wr) ? v[3] : v[3] - sw      ; à direita da janela; se não couber, por dentro
        hudSide.Show(Format("NA x{} y{} w{} h{}", sx, v[2], sw, sh))
        WinSetTransparent((sx < v[3]) ? 235 : "Off", hudSide.Hwnd)
        DllCall("SetWindowRgn", "Ptr", hudSide.Hwnd, "Ptr", DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", sw + 1, "Int", sh + 1, "Int", Round(14 * k), "Int", Round(14 * k), "Ptr"), "Int", 1)
    } else
        try hudSide.Hide()
    HudPanelPos(v, k, h)
    if chkFrame.Value {
        t := Max(2, Round(3 * k))
        hudFrame.Show(Format("NA x{} y{} w{} h{}", v[1], v[2], w, h))
        outer := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr")
        inner := DllCall("CreateRectRgn", "Int", t, "Int", t, "Int", w - t, "Int", h - t, "Ptr")
        DllCall("CombineRgn", "Ptr", outer, "Ptr", outer, "Ptr", inner, "Int", 4)
        DllCall("DeleteObject", "Ptr", inner)
        DllCall("SetWindowRgn", "Ptr", hudFrame.Hwnd, "Ptr", outer, "Int", 1)
    } else
        try hudFrame.Hide()
    hudShown := true
}

; arredonda controles, joga os fundos pro fundo da pilha e arredonda as janelas
; ==========================================================
;  Suporte: relatório de erro -> webhook secreto (sem IP, sem dado pessoal)
; ==========================================================
SendReport() {
    global edReport, chkReportShot, repStatus, REPORT_WEBHOOK, APP_NAME, USER_NAME, VERSION, LOGO_URL, iniFile, ANON_ID, LANG, reportImg
    txt := Trim(edReport.Value)
    if (txt = "") {
        repStatus.Value := TT("report_need_text")
        return
    }
    if (Trim(REPORT_WEBHOOK) = "") {
        repStatus.Value := TT("report_nodest")
        return
    }
    repStatus.Value := TT("report_sending")
    shot := "", fname := "roblox.png"
    if (reportImg != "" && FileExist(reportImg)) {        ; imagem escolhida pelo usuário tem prioridade
        shot := reportImg
        SplitPath(reportImg, , , &ext)
        fname := "report." StrLower(ext)
    } else if chkReportShot.Value {
        hw := FindGameWindow()
        if (hw && WinGetMinMax(hw) != -1) {
            try if CaptureWindowPng(hw, A_Temp "\roblox_report.png")
                shot := A_Temp "\roblox_report.png"
        }
    }
    key := IniRead(iniFile, "cfg", "key", "")
    fields := [[TT("f_report_user"), USER_NAME, true]
        , [TT("f_report_pc"), A_ComputerName, true]
        , [TT("f_report_id"), ANON_ID, true]
        , [TT("f_version"), "v" VERSION, true]
        , [TT("f_report_os"), "Windows " A_OSVersion "  ·  " (A_Is64bitOS ? "x64" : "x86"), true]
        , [TT("f_report_lang"), LANG, true]]
    if (Trim(key) != "")
        fields.Push([TT("f_report_lic"), "``" SubStr(key, 1, 40) "``", false])
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    e := '{"username":"' JsonEsc(APP_NAME " Report") '","avatar_url":"' LOGO_URL '","allowed_mentions":{"parse":[]},"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc("🐞  " TT("ev_report")) '","color":' 0xF5A142 ','
       . '"description":"' JsonEsc(txt) '",' FieldsJson(fields)
       . (shot != "" ? '"image":{"url":"attachment://' fname '"},' : '')
       . '"footer":{"text":"' JsonEsc(APP_NAME "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
       . '"timestamp":"' ts '"}]}'
    try {
        if (shot != "" && FileExist(shot))
            SendWebhookImage(REPORT_WEBHOOK, e, shot, "", ReportCb, fname)
        else
            HttpPost(REPORT_WEBHOOK, e, "application/json", "", ReportCb)
    } catch as err {
        repStatus.Value := TT("report_fail", err.Message)
    }
}

ReportCb(h) {
    global repStatus, edReport, reportImg, repImgLbl
    st := HttpStatus(h)
    if (st >= 200 && st < 300) {
        repStatus.Value := TT("report_sent")
        edReport.Value := ""
        reportImg := ""
        try repImgLbl.Value := TT("report_noimg")
    } else
        repStatus.Value := TT("report_fail", "HTTP " st)
}

PickReportImg(*) {
    global reportImg, repImgLbl
    f := FileSelect(3, , TT("btn_report_img"), "Imagens (*.png; *.jpg; *.jpeg; *.gif)")
    if (f = "")
        return
    reportImg := f
    SplitPath(f, &nm)
    repImgLbl.Value := TT("report_img_set", nm)
}

; ==========================================================
;  Esperar a internet voltar
; ==========================================================
InternetUp() {
    flags := 0
    try return DllCall("Wininet\InternetGetConnectedState", "UInt*", &flags, "UInt", 0) ? true : false
    return true
}

; ==========================================================
;  Botões no painel do Discord (reações ▶️ ⏹️ 🔄 📸)
; ==========================================================
ReactTick() {
    global chkBot, chkPanel, panelMsg, edToken, edChan, edDiscId, PANEL_EMO, reactReady, reactBusy
    if !(chkBot.Value && chkPanel.Value) || panelMsg = ""
        return
    tok := TokClean(), ch := Trim(edChan.Value), me := Trim(edDiscId.Value)
    if (tok = "" || ch = "" || me = "")
        return
    base := "https://discord.com/api/v10/channels/" ch "/messages/" panelMsg
    if !reactReady {
        reactReady := true
        for e in PANEL_EMO
            try AsyncReq("PUT", base "/reactions/" e[1] "/@me", "", "", "Bot " tok)
        return
    }
    if (reactBusy && A_TickCount - reactBusy < 20000)
        return
    reactBusy := A_TickCount
    for e in PANEL_EMO
        try AsyncReq("GET", base "/reactions/" e[1] "?limit=20", "", "", "Bot " tok, ReactGot.Bind(tok, me, e[1], e[2], base))
    SetTimer(() => SetReactFree(), -4000)
}

SetReactFree() {
    global reactBusy
    reactBusy := 0
}

ReactGot(tok, me, emo, act, base, http) {
    if (HttpStatus(http) != 200)
        return
    ids := ""
    try ids := JsonPick(http.ResponseText, "a.map(function(u){return u.id}).join(',')")
    if !InStr("," ids ",", "," me ",")
        return
    try AsyncReq("DELETE", base "/reactions/" emo "/" me, "", "", "Bot " tok)
    parts := StrSplit(base, "/")
    ch := parts[parts.Length - 2]
    ReactDo(act, ch, tok)
}

ReactDo(act, ch, tok) {
    global running, botCtx, panelMsg
    botCtx := {ch: ch, mid: panelMsg, tok: tok}
    try {
        switch act {
            case "play":
                running ? SendEvent("already", [], false, "", SessionFields(), true) : Toggle()
            case "stop":
                running ? Toggle() : SendEvent("notrunning", [], false, "", SessionFields(), true)
            case "restart":
                SendEvent("restart", [TT("d_restart_how")], false, "", SessionFields(), true)
                botCtx := 0
                BotRestart()
            case "print":
                SendPrint()
        }
    }
    botCtx := 0
    SetTimer(() => PanelUpdate(true), -1500)
}

; ==========================================================
;  !grafico -> imagem do QuickChart (dados do histórico, só seus)
; ==========================================================
UriEncode(str) {
    static safe := "-_.!~*'()"
    out := "", b := Buffer(StrPut(str, "UTF-8")), StrPut(str, b, "UTF-8")
    Loop b.Size - 1 {
        c := NumGet(b, A_Index - 1, "UChar"), ch := Chr(c)
        if ((c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || InStr(safe, ch))
            out .= ch
        else
            out .= "%" Format("{:02X}", c)
    }
    return out
}

ChartTxt(x) {
    return StrReplace(StrReplace(x, "\", ""), '"', "'")
}

BotChart() {
    global APP_NAME, LOGO_URL, USER_NAME, VERSION
    specs := CurrencySpec()
    useCoin := specs.Length > 0
    ck := useCoin ? RegExReplace(specs[1].name, "\W", "_") : ""
    labels := "", data := "", any := false
    Loop 7 {
        d := FormatTime(DateAdd(A_Now, -(7 - A_Index), "Days"), "yyyyMMdd")
        rec := HistGet(d)
        v := useCoin ? (rec.coins.Has(ck) ? rec.coins[ck] : 0) : Round(rec.online / 60)
        if (rec.has && v)
            any := true
        labels .= (labels = "" ? "" : ",") '"' FormatTime(d, "dd/MM") '"'
        data .= (data = "" ? "" : ",") v
    }
    if !any
        return SendEvent("chart", [TT("chart_none")], false, "", [], true)
    title := useCoin ? specs[1].name : TT("hist_online")
    cfg := '{type:"bar",data:{labels:[' labels '],datasets:[{data:[' data '],backgroundColor:"#5B8CFF",borderRadius:6}]},options:{plugins:{legend:{display:false},title:{display:true,text:"' ChartTxt(title) '",color:"#EDEDF0",font:{size:16}}},scales:{y:{beginAtZero:true,ticks:{color:"#9A9AA6"},grid:{color:"#2A2A30"}},x:{ticks:{color:"#9A9AA6"},grid:{display:false}}}}}'
    url := "https://quickchart.io/chart?bkg=%2316161A&w=640&h=360&c=" UriEncode(cfg)
    if !DiscordDest(&durl, &auth, &head)
        return
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    e := '{' head '"allowed_mentions":{"parse":[]},"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc("📈  " TT("ev_chart")) '","color":' 0xA78BFA ','
       . '"image":{"url":"' url '"},'
       . '"footer":{"text":"' JsonEsc(USER_NAME "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
       . '"timestamp":"' ts '"}]}'
    try HttpPost(durl, e, "application/json", auth, HookCb())
}

; ==========================================================
;  !gif -> vários prints seguidos (timelapse) num anexo só
; ==========================================================
BotGif() {
    global APP_NAME, LOGO_URL, USER_NAME, VERSION
    hw := FindGameWindow()
    if (!hw || WinGetMinMax(hw) = -1)
        return SendEvent("gif", [TT("gif_none")], false, "", [], true)
    frames := []
    Loop 4 {
        f := A_Temp "\rbx_tl" A_Index ".png"
        try if CaptureWindowPng(hw, f)
            frames.Push(f)
        if (A_Index < 4)
            Sleep 1000
    }
    if !frames.Length
        return SendEvent("gif", [TT("gif_none")], false, "", [], true)
    if !DiscordDest(&url, &auth, &head)
        return
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    atts := ""
    for i, f in frames
        atts .= (atts = "" ? "" : ",") '{"id":' (i - 1) ',"filename":"frame' i '.png"}'
    e := '{' head '"allowed_mentions":{"parse":[]},"embeds":[{'
       . '"author":{"name":"' JsonEsc(APP_NAME) '","icon_url":"' LOGO_URL '"},'
       . '"title":"' JsonEsc("🎞️  " TT("ev_gif")) '","color":' 0x3DDC84 ','
       . '"description":"' JsonEsc(TT("gif_desc", frames.Length)) '",'
       . '"footer":{"text":"' JsonEsc(USER_NAME "  •  v" VERSION) '","icon_url":"' LOGO_URL '"},'
       . '"timestamp":"' ts '"}],"attachments":[' atts ']}'
    try SendWebhookImages(url, e, frames, auth, HookCb())
}

SendWebhookImages(url, payload, paths, auth := "", cb := 0) {
    bnd := "----AHKMulti" A_TickCount
    head := "--" bnd "`r`nContent-Disposition: form-data; name=`"payload_json`"`r`nContent-Type: application/json`r`n`r`n" payload "`r`n"
    hb := Buffer(StrPut(head, "UTF-8")), StrPut(head, hb, "UTF-8"), hn := hb.Size - 1
    total := hn
    imgs := []
    for i, pth in paths {
        ph := "--" bnd "`r`nContent-Disposition: form-data; name=`"files[" (i - 1) "]`"; filename=`"frame" i ".png`"`r`nContent-Type: image/png`r`n`r`n"
        pb := Buffer(StrPut(ph, "UTF-8")), StrPut(ph, pb, "UTF-8"), pn := pb.Size - 1
        img := FileRead(pth, "RAW")
        imgs.Push({hb: pb, hn: pn, img: img})
        total += pn + img.Size + 2
    }
    tail := "--" bnd "--`r`n"
    tb := Buffer(StrPut(tail, "UTF-8")), StrPut(tail, tb, "UTF-8"), tn := tb.Size - 1
    total += tn
    arr := ComObjArray(0x11, total)
    psa := ComObjValue(arr)
    DllCall("oleaut32\SafeArrayAccessData", "Ptr", psa, "Ptr*", &pp := 0)
    off := 0
    DllCall("RtlMoveMemory", "Ptr", pp + off, "Ptr", hb, "UPtr", hn), off += hn
    crlf := Buffer(2), NumPut("UChar", 13, crlf, 0), NumPut("UChar", 10, crlf, 1)
    for seg in imgs {
        DllCall("RtlMoveMemory", "Ptr", pp + off, "Ptr", seg.hb, "UPtr", seg.hn), off += seg.hn
        if seg.img.Size
            DllCall("RtlMoveMemory", "Ptr", pp + off, "Ptr", seg.img, "UPtr", seg.img.Size)
        off += seg.img.Size
        DllCall("RtlMoveMemory", "Ptr", pp + off, "Ptr", crlf, "UPtr", 2), off += 2
    }
    DllCall("RtlMoveMemory", "Ptr", pp + off, "Ptr", tb, "UPtr", tn)
    DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", psa)
    return HttpPost(url, arr, "multipart/form-data; boundary=" bnd, auth, cb)
}

RobloxMaxRamMB() {
    mx := -1
    try {
        for pr in ComObjGet("winmgmts:").ExecQuery("Select WorkingSetSize from Win32_Process where Name='RobloxPlayerBeta.exe'")
            mx := Max(mx, Round(pr.WorkingSetSize / 1048576))
    }
    return mx
}

; webhook de suporte montado em runtime (não aparece como link no código)
ReportUrl() {
    a := [    104, 116, 116, 112, 115, 58, 47, 47, 100, 105, 115, 99, 111, 114, 100, 46
    , 99, 111, 109, 47, 97, 112, 105, 47, 119, 101, 98, 104, 111, 111, 107, 115
    , 47, 49, 53, 55, 50, 48, 56, 51, 50, 51, 50, 52, 51, 54, 57, 49
    , 54, 50, 51, 52, 47, 88, 105, 114, 72, 53, 98, 100, 107, 99, 78, 119
    , 72, 57, 98, 52, 114, 75, 105, 69, 72, 68, 75, 115, 95, 51, 81, 68
    , 65, 106, 119, 56, 48, 53, 81, 111, 54, 76, 70, 85, 51, 55, 71, 79
    , 84, 75, 84, 70, 73, 67, 111, 114, 52, 55, 76, 104, 100, 122, 103, 65
    , 51, 83, 52, 106, 45, 77, 48, 113, 56]
    s := ""
    for n in a
        s .= Chr(n)
    return s
}

; ==========================================================
;  Apoie o dev — telinha de Pix (aparece sempre até desativar)
; ==========================================================
ShowDonate(*) {
    global g, C_CARD, C_TEXT, C_MUTED, C_ACC, ASSET_DIR, iniFile, donateGui
    try donateGui.Destroy()
    k := A_ScreenDPI / 96
    DW := Round(360 * k), DH := Round(486 * k), qrw := Round(240 * k)
    d := Gui("-Caption +ToolWindow +AlwaysOnTop +Owner" g.Hwnd)
    d.BackColor := C_CARD
    donateGui := d
    FontUI(d, "s14 w700")
    d.Add("Text", Format("x0 y{} w{} +0x1 c{} Background{}", Round(22 * k), DW, C_TEXT, C_CARD), TT("don_title"))
    FontUI(d, "s9")
    d.Add("Text", Format("x{} y{} w{} h{} +0x1 c{} Background{}", Round(28 * k), Round(52 * k), DW - Round(56 * k), Round(66 * k), C_MUTED, C_CARD), TT("don_msg"))
    try d.Add("Picture", Format("x{} y{} w{} h{}", (DW - qrw) // 2, Round(128 * k), qrw, qrw), ASSET_DIR "\donate.png")
    FontUI(d, "s8 w600")
    d.Add("Text", Format("x0 y{} w{} +0x1 c{} Background{}", Round(128 * k) + qrw + Round(8 * k), DW, C_MUTED, C_CARD), TT("don_pix"))
    bw := Round(158 * k), bh := Round(38 * k), by := DH - bh - Round(20 * k)
    MakeBtn(d, DW // 2 - bw - Round(6 * k), by, bw, bh, TT("don_close"), (*) => DonateClose(), "primary", false, "s9 w700", 10, C_CARD)
    MakeBtn(d, DW // 2 + Round(6 * k), by, bw, bh, TT("don_never"), DonateNever, "ghost", false, "s9 w600", 10, C_CARD)
    d.Show(Format("w{} h{} Center", DW, DH))
}

DonateNever(*) {
    global chkDonate, iniFile
    IniWrite(0, iniFile, "cfg", "showDonate")
    try chkDonate.Value := 0
    DonateClose()
}

DonateClose() {
    global donateGui, donateThenTour
    try donateGui.Destroy()
    if donateThenTour {
        donateThenTour := false
        SetTimer(StartTour, -300)
    }
}

FinishGui() {
    global g, gk, bgCtrls, roundQ
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
; entrada da janela: aparece subindo uns pixels com fade
IntroShow(gui, opts := "") {
    try WinSetTransparent(0, gui.Hwnd)
    gui.Show(opts)
    WinGetPos(&x, &y, , , gui.Hwnd)
    t0 := A_TickCount
    Loop {
        pr := Min(1, (A_TickCount - t0) / 380)
        e := EaseOut(pr)
        try WinSetTransparent(Round(255 * e), gui.Hwnd)
        try WinMove(x, y + Round(28 * (1 - e)), , , gui.Hwnd)
        if (pr >= 1)
            break
        Sleep(10)
    }
    try WinMove(x, y, , , gui.Hwnd)
    try WinSetTransparent("Off", gui.Hwnd)
}

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
    global dashDot, dashTitle, dashSub, sideDot, sideStat, mDot, mStat, sbDot, sbTxt, VERSION
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
    try sbDot.SetFont("c" col)
    SetIf(sbTxt, title "  ·  v" VERSION "  ·  BETA")
}

UpdateStats() {
    global stVals, mSub, running, monStart, launches, discCount, lastDiscShort, dayOnline, iniFile
    SetIf(stVals[1], AfkStr("—"))
    static sv := 0
    if (running && Mod(++sv, 30) = 0)
        AfkSave()
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
    global g, gm, miniShown, iniFile, winW, W, H, hudMode, chkHudComp
    IniWrite(on ? 1 : 0, iniFile, "cfg", "compact")
    if (on && hudMode && chkHudComp.Value) {   ; o HUD grudado no Roblox faz o papel do modo compacto
        FadeHide(g)
        FadeHide(gm)
        HudApply()
        return
    }
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
    try AfkSave()
    try SaveConfig()
    try FileDelete(A_Temp "\roblox_status.png")
}

; ==========================================================
;  Funções gerais
; ==========================================================
Log(msg) {
    global logBox, hudLogs
    line := FormatTime(, "HH:mm:ss") "  " msg "`r`n"
    hudLogs.Push(FormatTime(, "HH:mm") "  " SubStr(RegExReplace(msg, "\s+", " "), 1, 38))
    if (hudLogs.Length > 60)
        hudLogs.RemoveAt(1)
    n := DllCall("GetWindowTextLength", "Ptr", logBox.Hwnd)
    if (n > 60000) {                          ; guarda só a parte mais recente
        logBox.Value := SubStr(logBox.Value, -30000)
        n := DllCall("GetWindowTextLength", "Ptr", logBox.Hwnd)
    }
    SendMessage(0xB1, n, n, logBox.Hwnd)                  ; EM_SETSEL no fim
    SendMessage(0xC2, 0, StrPtr(line), logBox.Hwnd)       ; EM_REPLACESEL
}

SaveConfig() {
    global iniFile, edLink, edRbxVer, edHook, edInterval, edWait, chkShrink, chkMin, chkErr, edErrSec, chkZombie, chkRep, edRepMin, winW, winH, chkOcr, edCur, chkAutoUpd, chkStartWin, chkAutoMon, chkToast, chkTray, chkDaily, edDailyAt, chkMention, edDiscId, chkMulti, chkSched, edFrom, edTo, edMaxH, endAct, chkEco, chkLowGfx, chkMute, chkLowPrio, chkBot, edToken, edChan, chkPanel, edPanelMin, chkStuck, edStuckMin, stuckAct, hudMode, chkFrame, chkHudComp, chkWhReopen, chkWhDrop, chkWhError, chkWhUpdate
    IniWrite(Trim(edLink.Value), iniFile, "cfg", "link")
    IniWrite(Trim(edRbxVer.Value), iniFile, "cfg", "rbxVer")
    IniWrite(Trim(edHook.Value), iniFile, "cfg", "webhook")
    IniWrite(edInterval.Value, iniFile, "cfg", "interval")
    IniWrite(edWait.Value, iniFile, "cfg", "wait")
    IniWrite(chkShrink.Value, iniFile, "cfg", "shrink")
    IniWrite(chkMin.Value, iniFile, "cfg", "minBrowser")
    IniWrite(chkErr.Value, iniFile, "cfg", "restartOnError")
    IniWrite(edErrSec.Value, iniFile, "cfg", "errSec")
    IniWrite(chkZombie.Value, iniFile, "cfg", "killZombie")
    IniWrite(chkRep.Value, iniFile, "cfg", "report")
    IniWrite(edRepMin.Value, iniFile, "cfg", "reportMin")
    IniWrite(chkOcr.Value, iniFile, "cfg", "ocr")
    IniWrite(Trim(edCur.Value), iniFile, "cfg", "currencies")
    IniWrite(chkAutoUpd.Value, iniFile, "cfg", "autoUpdate")
    IniWrite(FastUpdOn(), iniFile, "cfg", "updFast")
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
    IniWrite(chkWhReopen.Value, iniFile, "cfg", "whReopen")
    IniWrite(chkWhDrop.Value, iniFile, "cfg", "whDrop")
    IniWrite(chkWhError.Value, iniFile, "cfg", "whError")
    IniWrite(chkWhUpdate.Value, iniFile, "cfg", "whUpdate")
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
    IniWrite(hudMode, iniFile, "cfg", "hudMode")
    IniWrite(chkFrame.Value, iniFile, "cfg", "frame")
    IniWrite(chkHudComp.Value, iniFile, "cfg", "hudCompact")
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

; tempo AFK: soma o que já foi guardado + a sessão atual; só zera quando detecta queda
AfkMs() {
    global afkAccum, running, monStart
    return afkAccum + (running ? A_TickCount - monStart : 0)
}

AfkStr(dflt := "") {
    global afkAccum, running
    if running
        return DurStr(AfkMs())
    if (afkAccum > 0)
        return DurStr(afkAccum) " ⏸"
    return dflt != "" ? dflt : TT("up_stopped")
}

AfkSave() {
    global iniFile
    IniWrite(AfkMs(), iniFile, "afk", "ms")
}

MarkDisconnect() {
    global discCount, lastDisc, lastDiscShort, lastDiscUnix, afkAccum, monStart
    afkAccum := 0, monStart := A_TickCount
    IniWrite(0, iniFile, "afk", "ms")
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

FastUpdOn() {
    global chkFastUpd
    return chkFastUpd.Value
}

; lê só o começo do script no GitHub (uns 6 KB) e compara a versão
QuickVersion() {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.SetTimeouts(4000, 4000, 6000, 8000)
        http.Open("GET", UpdBaseNow() "roblox_autorejoin.ahk?t=" A_TickCount, false)
        http.SetRequestHeader("Range", "bytes=0-6143")
        http.Send()
        if RegExMatch(http.ResponseText, 'm)^VERSION\s*:=\s*"([^"]+)"', &m)
            return m[1]
    }
    return ""
}

UpdPoll() {
    global VERSION, pendingUpd, chkFastUpd, updBase
    if (!chkFastUpd.Value || pendingUpd != "" || updBase = "" || KaEnabled())
        return
    v := QuickVersion()
    if (v != "" && v != VERSION)
        CheckUpdate(false)
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
    if (v[1] = VERSION) {                      ; mesma versão do GitHub = nada a fazer (serve pra frente E pra trás)
        updStatus.Value := TT("upd_latest")
        pendingUpd := ""
        updBadge.Visible := false
        return
    }
    pendingUpd := A_IsCompiled ? "exe" : tmp
    pendingVer := v[1]
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

ApplyExeUpdate() {
    global pendingVer, running, iniFile, EXE_NAME, GITHUB_REPO
    url := "https://github.com/" GITHUB_REPO "/releases/latest/download/" EXE_NAME
    tmp := A_Temp "\arr_update.exe"
    try FileDelete(tmp)
    try {
        Download(url, tmp)
    } catch as e {
        Log(TT("log_upd_dlfail", e.Message))
        return
    }
    if (!FileExist(tmp) || FileGetSize(tmp) < 200000) {   ; exe real tem MB; menos que isso = erro/página
        Log(TT("log_upd_dlfail", "exe invalido"))
        return
    }
    SaveConfig()
    if running
        IniWrite(1, iniFile, "cfg", "resume")
    IniWrite(pendingVer, iniFile, "cfg", "justUpdated")
    Log(TT("log_updated", pendingVer))
    cur := A_ScriptFullPath
    bat := A_Temp "\arr_swap.bat"
    txt := "@echo off`r`n"
         . "ping 127.0.0.1 -n 3 >nul`r`n"
         . ":retry`r`n"
         . "copy /y `"" tmp "`" `"" cur "`" >nul`r`n"
         . "if errorlevel 1 (ping 127.0.0.1 -n 2 >nul & goto retry)`r`n"
         . "start `"`" `"" cur "`"`r`n"
         . "del `"" tmp "`" >nul`r`n"
         . "del `"%~f0`" >nul`r`n"
    try FileDelete(bat)
    FileAppend(txt, bat)
    Run(A_ComSpec ' /c "' bat '"', , "Hide")
    Sleep 300
    ExitApp()
}

ApplyUpdate() {
    global pendingUpd, pendingVer, pendingFileId, running, iniFile, changelogTxt, changeBox
    if (A_IsCompiled && pendingUpd = "exe") {
        ApplyExeUpdate()
        return
    }
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
    "stuck",   ["🧊", "ev_stuck",   0xF5C542],
    "neterr",  ["📴", "ev_neterr",  0xF5A142],
    "netok",   ["🛜", "ev_netok",   0x3DDC84],
    "chart",   ["📈", "ev_chart",   0xA78BFA],
    "gif",     ["🎞️", "ev_gif",     0x3DDC84])

SendEvent(kind, lines := [], feedback := false, arg := "", fields := [], thumb := false, img := "") {
    global edHook, EV, APP_NAME, USER_NAME, LOGO_URL, chkMention, edDiscId, VERSION, botCtx
    if (botCtx = 0 && !WhAllowed(kind))
        return
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

SendWebhookImage(url, payload, pngPath, auth := "", cb := 0, fname := "roblox.png") {
    ct := "image/png"
    if RegExMatch(fname, "i)\.jpe?g$")
        ct := "image/jpeg"
    else if RegExMatch(fname, "i)\.gif$")
        ct := "image/gif"
    bnd := "----AHKRejoin" A_TickCount
    head := "--" bnd "`r`n"
        . 'Content-Disposition: form-data; name="payload_json"' "`r`n"
        . "Content-Type: application/json`r`n`r`n"
        . payload "`r`n"
        . "--" bnd "`r`n"
        . 'Content-Disposition: form-data; name="files[0]"; filename="' fname '"' "`r`n"
        . "Content-Type: " ct "`r`n`r`n"
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

    up := AfkStr()
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
        list.Push({kind: "newest", target: d})   ; SEMPRE tenta a versão MAIS NOVA instalada primeiro
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
    if (m.kind = "newest") {
        exe := ChosenRobloxExe()
        if (exe = "")
            throw Error("nenhuma instalacao do Roblox encontrada")
        cmd := PlayerCommand()
        if (cmd != "" && RegExMatch(cmd, 'i)^"[^"]+RobloxPlayerBeta\.exe"')) {
            cmd := RegExReplace(cmd, 'i)^"[^"]+RobloxPlayerBeta\.exe"', '"' exe '"')
            cmd := StrReplace(cmd, '"%1"', '"' m.target '"')
            cmd := StrReplace(cmd, "%1", '"' m.target '"')
            Run(cmd)
        } else
            Run('"' exe '" "' m.target '"')
        return
    }
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
    if (m.kind = "newest")
        return "Roblox (mais recente)"
    return TT(Map("exe", "m_exe", "uri", "m_uri", "web", "m_web")[m.kind])
}

; retorna o exe da versão FIXADA pelo usuário (se houver e existir), senão o da mais nova
ChosenRobloxExe() {
    global edRbxVer
    pin := Trim(edRbxVer.Value)
    if (pin != "") {
        folder := InStr(pin, "version-") ? pin : "version-" pin
        for v in ["LOCALAPPDATA", "ProgramFiles(x86)", "ProgramFiles"] {
            base := EnvGet(v)
            if (base = "")
                continue
            exe := base "\Roblox\Versions\" folder "\RobloxPlayerBeta.exe"
            if FileExist(exe) {
                Log("Versão do Roblox (fixada): " folder)
                return exe
            }
        }
        Log("Versão fixada não encontrada (" folder ") — abrindo a mais nova")
    }
    return NewestRobloxExe()
}

ListRbxVersions(*) {
    found := false
    Log("--- Versões do Roblox instaladas ---")
    for v in ["LOCALAPPDATA", "ProgramFiles(x86)", "ProgramFiles"] {
        base := EnvGet(v)
        if (base = "")
            continue
        root := base "\Roblox\Versions"
        if !DirExist(root)
            continue
        Loop Files, root "\*", "D" {
            if FileExist(A_LoopFilePath "\RobloxPlayerBeta.exe") {
                Log("• " A_LoopFileName)
                found := true
            }
        }
    }
    if !found
        Log("Nenhuma versão do Roblox encontrada.")
}

; acha o RobloxPlayerBeta.exe da versão MAIS RECENTE instalada (pela data de CRIAÇÃO da pasta = quando foi instalada)
NewestRobloxExe() {
    best := "", bestT := 0, bestDir := ""
    roots := []
    for v in ["LOCALAPPDATA", "ProgramFiles(x86)", "ProgramFiles"] {
        base := EnvGet(v)
        if (base != "")
            roots.Push(base "\Roblox\Versions")
    }
    for root in roots {
        if !DirExist(root)
            continue
        Loop Files, root "\*", "D" {
            exe := A_LoopFilePath "\RobloxPlayerBeta.exe"
            if FileExist(exe) {
                t := Integer(FileGetTime(A_LoopFilePath, "C"))
                if (t > bestT)
                    bestT := t, best := exe, bestDir := A_LoopFileName
            }
        }
    }
    if (best != "")
        Log("Versão do Roblox escolhida: " bestDir)
    return best
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
    if (manual && ProcessExist("RobloxPlayerBeta.exe") && !FindGameWindow()) {   ; limpa fantasma antes de abrir (senão a trava do Roblox fecha a nova janela)
        KillRoblox()
        Sleep 400
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

KillRobloxManual(*) {
    KillRoblox()
    Log(TT("log_killed"))
    try SetState("off", "Roblox OFF", TT("st_off_sub"))
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
    global running, lastLaunch, edWait, wasOpen, downTick, discTick, netDown, chkZombie, noWinSince
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
        gw := FindGameWindow()
        if (chkZombie.Value && !gw) {                      ; processo SEM janela = fantasma de verdade (RAM baixa com janela é só loading, não mata)
            if !noWinSince
                noWinSince := A_TickCount
            else if (A_TickCount - noWinSince > 60000) {    ; 60s sem janela (além da espera) -> fecha e reabre
                noWinSince := 0
                RecoverRoblox(TT("r_zombie"))
                return
            }
            SetState("wait", TT("st_zombie"), TT("st_zombie_sub"))
            return
        }
        noWinSince := 0
        if discTick
            SetState("warn", "Roblox ON", TT("st_on_warn_sub"))
        else
            SetState("on", "Roblox ON", TT("st_on_sub"))
    } else {
        noWinSince := 0
        SetState("off", "Roblox OFF", TT("st_off_sub"))
        LaunchGame()
    }
}

Toggle(*) {
    global afkAccum, running, btnStart, mBtn, edInterval, edLink, wasOpen, downTick, monStart, gm, licensed, chkMulti, ACCS, multiActive
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
        afkAccum += A_TickCount - monStart
        AfkSave()
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
