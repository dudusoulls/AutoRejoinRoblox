#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================================
;  Roblox Auto-Rejoin  v2  (tema Obsidian)
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
VERSION     := "1.0.1"
GITHUB_REPO := "dudusoulls/AutoRejoinRoblox"
GITHUB_BRANCH := "main"

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
running  := false
lastLaunch := 0
launches := 0

wasOpen  := false
downTick := 0
discCount := 0
lastDisc  := "nenhuma"
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
pendingUpd := ""   ; arquivo da atualização já baixado
pendingVer := ""
changelogTxt := ""
launchToken := 0
launchIdx := Integer(IniRead(A_ScriptDir "\config.ini", "cfg", "launchMethod2", "0"))
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
W := 760, H := 490, SIDE := 184
CX := SIDE + 28          ; x do conteúdo
CW := W - CX - 28        ; largura do conteúdo

g := Gui("-Caption +MinimizeBox", "Roblox Auto-Rejoin")
g.BackColor := C_BG
g.MarginX := 0, g.MarginY := 0

; ---- barra lateral ----
sideBg := g.Add("Text", Format("x0 y0 w{} h{} +0x4000000 Background{}", SIDE, H, C_SIDE))
Bg(sideBg)

FontUI(g, "s13 w700")
g.Add("Text", Format("x24 y24 w140 c{} Background{}", C_TEXT, C_SIDE), "Auto-Rejoin")
FontUI(g, "s7 w700")
g.Add("Text", Format("x25 y+1 w140 c{} Background{}", C_DIM, C_SIDE), "ROBLOX  MONITOR")

AddNav("Início",  Chr(0xE80F), 96)
AddNav("Jogo",    Chr(0xE7FC), 138)
AddNav("Janela",  Chr(0xE7F4), 180)
AddNav("Webhook", Chr(0xE71B), 222)
AddNav("Moedas",  Chr(0xE8C7), 264)
AddNav("Logs",    Chr(0xE81C), 306)
AddNav("Sobre",   Chr(0xE946), 348)

FontUI(g, "s10")
sideDot := g.Add("Text", Format("x24 y{} w14 c{} Background{}", H - 62, C_DIM, C_SIDE), "●")
FontUI(g, "s9 w600")
sideStat := g.Add("Text", Format("x42 y{} w130 c{} Background{}", H - 61, C_TEXT, C_SIDE), "Parado")
FontUI(g, "s8")
g.Add("Text", Format("x24 y+4 w150 c{} Background{}", C_DIM, C_SIDE), A_ComputerName "  ·  v" VERSION)

; ---- botões da janela (topo direito) ----
MakeBtn(g, W - 46,  0, 46, 34, Chr(0xE8BB), (*) => ExitApp(), "close", true, "s9", 0, C_BG)
MakeBtn(g, W - 92,  0, 46, 34, Chr(0xE921), (*) => g.Minimize(), "ghost", true, "s9", 0, C_BG)
MakeBtn(g, W - 138, 0, 46, 34, Chr(0xE73F), (*) => SetCompact(true), "ghost", true, "s9", 0, C_BG)

; ---- selo "nova versão" (fica escondido até achar atualização) ----
updBadge := MakeBtn(g, W - 138 - 196, 6, 188, 24, "", (*) => ShowPage("Sobre"), "primary", false, "s8 w700", 24)
updBadge.Visible := false

; ---- título da página ----
FontUI(g, "s17 w700")
pageTitle := g.Add("Text", Format("x{} y26 w190 c{} Background{}", CX, C_TEXT, C_BG), "")
FontUI(g, "s9")
pageSub := g.Add("Text", Format("x{} y+2 w{} c{} Background{}", CX, CW, C_MUTED, C_BG), "")

; ---------------- Página: Início ----------------
BeginPage("Início", "Início", "Visão geral do monitoramento")
y := 92
Card(CX, y, CW, 96)
dashDot   := Lbl(CX + 22, y + 26, 30, "●", "s20", C_DIM)
dashTitle := Lbl(CX + 58, y + 22, 290, "Parado", "s16 w700")
dashSub   := Lbl(CX + 59, y + 56, 300, "Clique em Iniciar para monitorar", "s9", C_MUTED)
btnStart  := Btn(CX + CW - 152, y + 29, 132, 38, "Iniciar", Toggle, "primary")

y := 200, sw := (CW - 36) // 4
stVals := []
for i, lab in ["TEMPO ATIVO", "REABERTURAS", "QUEDAS", "ÚLTIMA QUEDA"] {
    sx := CX + (i - 1) * (sw + 12)
    Card(sx, y, sw, 84)
    Lbl(sx + 18, y + 16, sw - 30, lab, "s7 w700", C_DIM)
    stVals.Push(Lbl(sx + 18, y + 38, sw - 26, "—", (i = 4) ? "s11 w600" : "s15 w700"))
}

y := 296, bw := (CW - 40 - 24) // 3
Card(CX, y, CW, 104)
Lbl(CX + 20, y + 16, 300, "AÇÕES RÁPIDAS", "s7 w700", C_DIM)
Btn(CX + 20,                y + 46, bw, 38, "Abrir jogo agora",  (*) => LaunchGame(true))
Btn(CX + 20 + (bw + 12),    y + 46, bw, 38, "Posicionar janela", (*) => ForcePlace())
Btn(CX + 20 + (bw + 12) * 2, y + 46, bw, 38, "Modo compacto",    (*) => SetCompact(true))

; ---------------- Página: Jogo ----------------
BeginPage("Jogo", "Jogo", "Servidor, intervalo de checagem e recuperação de erros")
y := 92
Card(CX, y, CW, 108)
Lbl(CX + 20, y + 16, 300, "SERVIDOR", "s7 w700", C_DIM)
edLink := Input(CX + 20, y + 38, CW - 40, savedLink)
Lbl(CX + 20, y + 78, CW - 40, "Link do jogo, link de servidor privado (PV) ou só o Place ID.", "s8", C_MUTED)

y := 212, half := (CW - 40) // 2
Card(CX, y, CW, 110)
Lbl(CX + 20, y + 16, 300, "MONITORAMENTO", "s7 w700", C_DIM)
Lbl(CX + 20, y + 40, half, "Checar a cada (segundos)", "s9", C_MUTED)
edInterval := Input(CX + 20, y + 62, 120, savedInterval, "Number")
Lbl(CX + 20 + half, y + 40, half, "Esperar após abrir (segundos)", "s9", C_MUTED)
edWait := Input(CX + 20 + half, y + 62, 120, savedWait, "Number")

y := 334
Card(CX, y, CW, 132)
Lbl(CX + 20, y + 16, 300, "RECUPERAÇÃO", "s7 w700", C_DIM)
chkErr := ToggleSwitch(CX + 20, y + 40, CW - 40, "Reiniciar se der erro, desconexão ou travar", savedErr
    , "Desconexão no log, kick, teleport que falhou ou janela sem responder")
Lbl(CX + 20, y + 96, 200, "Tolerância (segundos)", "s9", C_MUTED)
edErrSec := Input(CX + 170, y + 89, 90, savedErrSec, "Number")

; ---------------- Página: Janela ----------------
BeginPage("Janela", "Janela", "Posição da janela do Roblox e guia do navegador")
y := 92
Card(CX, y, CW, 142)
Lbl(CX + 20, y + 16, 300, "POSIÇÃO", "s7 w700", C_DIM)
chkShrink := ToggleSwitch(CX + 20, y + 40, CW - 40, "Posicionar no canto superior direito", savedShrink
    , "Mantém a janela do Roblox fixa e totalmente visível")
Lbl(CX + 20, y + 98, 60, "Largura", "s9", C_MUTED)
edW := Input(CX + 78, y + 91, 80, winW, "Number")
Lbl(CX + 178, y + 98, 50, "Altura", "s9", C_MUTED)
edH := Input(CX + 228, y + 91, 80, winH, "Number")
Btn(CX + CW - 170, y + 91, 150, 32, "Posicionar agora", (*) => ForcePlace())
edW.OnEvent("Change", (*) => (winW := Integer(edW.Value || 800)))
edH.OnEvent("Change", (*) => (winH := Integer(edH.Value || 630)))

y := 246
Card(CX, y, CW, 96)
Lbl(CX + 20, y + 16, 300, "NAVEGADOR", "s7 w700", C_DIM)
chkMin := ToggleSwitch(CX + 20, y + 40, CW - 40, "Fechar a guia do navegador após entrar", savedMin
    , "Fecha a guia com 'Roblox' no título e minimiza o navegador")

; ---------------- Página: Webhook ----------------
BeginPage("Webhook", "Webhook", "Avisos e status no Discord")
y := 92
Card(CX, y, CW, 112)
Lbl(CX + 20, y + 16, 300, "DISCORD", "s7 w700", C_DIM)
edHook := Input(CX + 20, y + 38, CW - 40 - 132, savedHook)
Btn(CX + CW - 140, y + 38, 120, 32, "Testar", (*) => SendWebhook(":white_check_mark: Teste de webhook - PC: " A_ComputerName, true))
Lbl(CX + 20, y + 80, CW - 40, "Avisos automáticos: queda, tentativa de reabrir, volta e erros (com horário).", "s8", C_MUTED)

y := 216
Card(CX, y, CW, 140)
Lbl(CX + 20, y + 16, 300, "STATUS PERIÓDICO", "s7 w700", C_DIM)
chkRep := ToggleSwitch(CX + 20, y + 40, CW - 40, "Enviar status com print", savedRep
    , "Embed com o estado da conta + print só da janela do Roblox")
chkRep.onChange := ApplyReportTimer
Lbl(CX + 20, y + 98, 120, "Intervalo (minutos)", "s9", C_MUTED)
edRepMin := Input(CX + 150, y + 91, 80, savedRepMin, "Number")
Btn(CX + CW - 160, y + 91, 140, 32, "Enviar agora", (*) => SendStatusReport(true))

; ---------------- Página: Moedas ----------------
BeginPage("Moedas", "Moedas", "Lê suas moedas na tela do Roblox e manda no webhook")
y := 92
Card(CX, y, CW, 166)
Lbl(CX + 20, y + 16, 300, "LEITURA DA TELA (OCR)", "s7 w700", C_DIM)
chkOcr := ToggleSwitch(CX + 20, y + 40, CW - 40, "Mandar moedas no embed de status", savedOcr
    , "Lê os valores que estiverem aparecendo na janela do Roblox")
Lbl(CX + 20, y + 94, CW - 40, "Moedas (separe com | ). Emoji opcional: Gems=<:gems:123456>", "s9", C_MUTED)
edCur := Input(CX + 20, y + 116, CW - 40, savedCur)

y := 270
Card(CX, y, CW, 150)
Lbl(CX + 20, y + 16, 300, "ÚLTIMA LEITURA", "s7 w700", C_DIM)
Btn(CX + CW - 160, y + 12, 140, 32, "Testar leitura", (*) => TestCurrencies())
FontMono(g, "s9")
curView := P(g.Add("Text", Format("x{} y{} w{} h{} c{} Background{}", CX + 20, y + 52, CW - 40, 84, C_TEXT, C_CARD)
    , "Nenhuma leitura ainda."))

; ---------------- Página: Sobre ----------------
BeginPage("Sobre", "Sobre", "Versão, atualizações e novidades")
y := 92
Card(CX, y, CW, 104)
Lbl(CX + 20, y + 16, 300, "VERSÃO INSTALADA", "s7 w700", C_DIM)
Lbl(CX + 20, y + 36, 200, "v" VERSION, "s20 w700")
updStatus := Lbl(CX + 20, y + 76, CW - 210, "Ainda não verifiquei.", "s9", C_MUTED)
btnUpd := Btn(CX + CW - 180, y + 34, 160, 38, "Procurar atualização", (*) => (pendingUpd != "" ? ApplyUpdate() : CheckUpdate(true)))

y := 208
Card(CX, y, CW, 80)
chkAutoUpd := ToggleSwitch(CX + 20, y + 18, CW - 40, "Atualizar sozinho", savedAutoUpd
    , "Atualiza assim que sair versão nova e volta a monitorar sozinho")

y := 300
Card(CX, y, CW, 172)
Lbl(CX + 20, y + 16, 300, "NOVIDADES", "s7 w700", C_DIM)
FontUI(g, "s9")
changeBox := P(g.Add("Edit", Format("x{} y{} w{} h{} ReadOnly +Multi +VScroll -E0x200 c{} Background{}"
    , CX + 20, y + 38, CW - 40, 120, C_TEXT, C_CARD), "As novidades aparecem aqui depois de verificar."))
DllCall("uxtheme\SetWindowTheme", "Ptr", changeBox.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)

; ---------------- Página: Logs ----------------
BeginPage("Logs", "Logs", "Histórico desta sessão")
y := 92
Card(CX, y, CW, 324)
FontMono(g, "s9")
logBox := P(g.Add("Edit", Format("x{} y{} w{} h{} ReadOnly -Wrap +Multi +VScroll -E0x200 c{} Background{}"
    , CX + 16, y + 14, CW - 32, 296, "C9C9CF", C_CARD)))
DllCall("uxtheme\SetWindowTheme", "Ptr", logBox.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
Btn(CX + CW - 110, y + 336, 110, 32, "Limpar", (*) => (logBox.Value := ""))

curBuild := ""

; ==========================================================
;  GUI compacta
; ==========================================================
gm := Gui("-Caption +AlwaysOnTop +ToolWindow", "Auto-Rejoin")
gm.BackColor := C_CARD
gm.MarginX := 0, gm.MarginY := 0
FontUI(gm, "s12")
mDot := gm.Add("Text", Format("x14 y13 w16 c{} Background{}", C_DIM, C_CARD), "●")
FontUI(gm, "s9 w700")
mStat := gm.Add("Text", Format("x34 y9 w128 c{} Background{}", C_TEXT, C_CARD), "Parado")
FontUI(gm, "s8")
mSub := gm.Add("Text", Format("x34 y+0 w128 c{} Background{}", C_MUTED, C_CARD), "reab 0 · quedas 0")
mBtn := MakeBtn(gm, 166, 11, 70, 30, "Iniciar", Toggle, "primary", false, "s9 w600", 10)
MakeBtn(gm, 242, 11, 30, 30, Chr(0xE740), (*) => SetCompact(false), "sec", true, "s9", 10)

; ---- acabamento ----
FinishGui()
OnMessage(0x201, OnLButtonDown)
OnMessage(0x200, OnMouseMove)

ShowPage("Início")
if (savedCompact = "1")
    SetCompact(true)
else
    g.Show(Format("w{} h{}", W, H))

SetTimer(Cleanup, 2000)
SetTimer(WatchError, 3000)
SetTimer(UpdateStats, 1000)
SetTimer(() => CheckUpdate(false), -8000)        ; procura atualização 8s depois de abrir
SetTimer(() => CheckUpdate(false), 6 * 3600000)  ; e a cada 6 horas
; voltou de uma atualização automática com o monitoramento ligado -> liga de novo
if (IniRead(iniFile, "cfg", "resume", "0") = "1") {
    IniDelete(iniFile, "cfg", "resume")
    SetTimer(() => (running ? 0 : Toggle()), -1500)
}
OnExit(OnQuit)

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
    b.Opt("Background" (hoverCur = o ? c[2] : c[1]))
    b.SetFont("c" c[3])
    b.Redraw()
}

AddNav(name, icon, y) {
    global g, navs, hoverMap, SIDE, C_SIDE, C_MUTED, C_NAVH, C_ACC
    bar := g.Add("Text", Format("x8 y{} w3 h18 Background{}", y + 10, C_ACC))
    FontIcon(g, "s11")
    ic := g.Add("Text", Format("x14 y{} w42 h38 Center +0x200 Background{} c{}", y, C_SIDE, C_MUTED), icon)
    FontUI(g, "s10 w600")
    lb := g.Add("Text", Format("x56 y{} w{} h38 +0x200 Background{} c{}", y, SIDE - 70, C_SIDE, C_MUTED), name)
    o := {ctrls: [ic, lb], bg: C_SIDE, hov: C_NAVH, bar: bar}
    for c in o.ctrls {
        hoverMap[c.Hwnd] := o
        c.OnEvent("Click", (*) => ShowPage(name))
    }
    navs[name] := o
}

ShowPage(name) {
    global pages, pageInfo, navs, pageTitle, pageSub, C_NAVA, C_SIDE, C_NAVH, C_TEXT, C_MUTED
    for n, list in pages
        if (n != name)
            for c in list
                c.Visible := false
    for c in pages[name]
        c.Visible := true
    for n, o in navs {
        act := (n = name)
        o.bg  := act ? C_NAVA : C_SIDE
        o.hov := act ? C_NAVA : C_NAVH
        for c in o.ctrls {
            c.Opt("Background" o.bg)
            c.SetFont("c" (act ? C_TEXT : C_MUTED))
            c.Redraw()
        }
        o.bar.Visible := act
    }
    pageTitle.Value := pageInfo[name][1]
    pageSub.Value := pageInfo[name][2]
}

; arredonda controles, joga os fundos pro fundo da pilha e arredonda as janelas
FinishGui() {
    global g, gm, bgCtrls, roundQ
    k := A_ScreenDPI / 96
    for item in roundQ {
        rc := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", item[1].Hwnd, "Ptr", rc)
        r := Round(item[2] * k)
        rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", NumGet(rc, 8, "Int") + 1
            , "Int", NumGet(rc, 12, "Int") + 1, "Int", r, "Int", r, "Ptr")
        DllCall("SetWindowRgn", "Ptr", item[1].Hwnd, "Ptr", rgn, "Int", 1)
    }
    Loop bgCtrls.Length {
        c := bgCtrls[bgCtrls.Length - A_Index + 1]
        DllCall("SetWindowPos", "Ptr", c.Hwnd, "Ptr", 1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
    for hw in [g.Hwnd, gm.Hwnd] {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hw, "UInt", 33, "Int*", 2, "UInt", 4)          ; cantos arredondados (Win11)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hw, "UInt", 34, "UInt*", 0x00332E2E, "UInt", 4) ; borda sutil
    }
}

; arrastar a janela clicando em qualquer área vazia
OnLButtonDown(wParam, lParam, msg, hwnd) {
    global g, gm
    if (hwnd = g.Hwnd || hwnd = gm.Hwnd)
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
    for c in o.ctrls {
        c.Opt("Background" (on ? o.hov : o.bg))
        c.Redraw()
    }
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
        this.pill.Opt("Background" (this.val ? C_ACC : C_SWOFF))
        this.pill.SetFont("c" (this.val ? C_BG : C_MUTED))
        this.pill.Text := this.val ? "ON" : "OFF"
        this.pill.Redraw()
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
    col := Map("on", C_ON, "off", C_OFF, "wait", C_ACC, "warn", C_WARN, "idle", C_DIM)[state]
    for d in [dashDot, sideDot, mDot]
        d.SetFont("c" col)
    SetIf(dashTitle, title)
    SetIf(dashSub, sub)
    SetIf(sideStat, title)
    SetIf(mStat, title)
}

UpdateStats() {
    global stVals, mSub, running, monStart, launches, discCount, lastDiscShort
    SetIf(stVals[1], running ? DurStr(A_TickCount - monStart) : "—")
    SetIf(stVals[2], launches)
    SetIf(stVals[3], discCount)
    SetIf(stVals[4], lastDiscShort)
    SetIf(mSub, "reab " launches " · quedas " discCount)
}

SetCompact(on) {
    global g, gm, miniShown, iniFile, winW, W, H
    IniWrite(on ? 1 : 0, iniFile, "cfg", "compact")
    if on {
        g.Hide()
        if !miniShown {
            miniShown := true
            x := A_ScreenWidth - winW - 300
            gm.Show("NoActivate w284 h52 x" (x > 0 ? x : 0) " y8")
        } else
            gm.Show("NoActivate")
    } else {
        gm.Hide()
        g.Show(Format("w{} h{}", W, H))
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
    logBox.Value .= FormatTime(, "HH:mm:ss") "  " msg "`r`n"
    SendMessage(0x115, 7, 0, logBox.Hwnd)
}

SaveConfig() {
    global iniFile, edLink, edHook, edInterval, edWait, chkShrink, chkMin, chkErr, edErrSec, chkRep, edRepMin, winW, winH, chkOcr, edCur, chkAutoUpd
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
    lastDisc := NowStr()
    lastDiscShort := FormatTime(, "dd/MM HH:mm")
}

; ---------------- Atualização pela nuvem ----------------
; Baixa o script do link, lê a VERSION de dentro dele e, se for mais nova, troca o arquivo e reinicia.
CheckUpdate(manual := false) {
    global updBase, VERSION, updStatus, btnUpd, chkAutoUpd, pendingUpd, pendingVer, updBadge, mSub
    if (updBase = "") {
        if manual
            updStatus.Value := "Atualização não configurada (GITHUB_REPO vazio)."
        return
    }
    updStatus.Value := "Procurando atualização..."
    LoadChangelog()
    tmp := A_Temp "\autorejoin_update.ahk"
    try {
        Download(updBase "roblox_autorejoin.ahk?t=" A_Now, tmp)
        txt := FileRead(tmp, "UTF-8")
    } catch as e {
        updStatus.Value := "Não consegui verificar (sem internet?)."
        if manual
            Log("Erro ao procurar atualização: " e.Message)
        return
    }
    if !(InStr(txt, "#Requires AutoHotkey v2") && RegExMatch(txt, 'm)^VERSION\s*:=\s*"([^"]+)"', &v)) {
        updStatus.Value := "O arquivo no GitHub não parece ser o script."
        return
    }
    if (VerCompare(v[1], VERSION) <= 0) {
        updStatus.Value := "Você está na versão mais nova."
        pendingUpd := ""
        updBadge.Visible := false
        return
    }
    pendingUpd := tmp, pendingVer := v[1]
    updStatus.Value := "Nova versão v" v[1] " disponível! Veja as novidades abaixo."
    btnUpd.Text := "Atualizar para v" v[1]
    SetBtnStyle(btnUpd, "primary")
    updBadge.Text := Chr(0x2B06) "  Nova versão v" v[1]
    updBadge.Visible := true
    Log("Atualização disponível: v" v[1] ".")
    if chkAutoUpd.Value
        ApplyUpdate()
}

; baixa o CHANGELOG.md do GitHub e mostra na aba Sobre
LoadChangelog() {
    global updBase, changeBox, changelogTxt
    tmp := A_Temp "\autorejoin_changelog.md"
    try {
        Download(updBase "CHANGELOG.md?t=" A_Now, tmp)
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

ApplyUpdate() {
    global pendingUpd, pendingVer, running, iniFile
    if (pendingUpd = "" || !FileExist(pendingUpd))
        return CheckUpdate(true)
    try {
        FileCopy(A_ScriptFullPath, A_ScriptFullPath ".bak", 1)   ; backup da versão atual
        FileCopy(pendingUpd, A_ScriptFullPath, 1)
    } catch as e {
        Log("Falha ao atualizar: " e.Message)
        return
    }
    SaveConfig()
    if running
        IniWrite(1, iniFile, "cfg", "resume")
    notas := ChangelogFor(pendingVer)
    Log("Atualizado para v" pendingVer "! Reiniciando o script...")
    SendWebhook(":sparkles: **Auto-Rejoin atualizado para v" pendingVer "** - PC: " A_ComputerName (notas != "" ? "`n" notas : ""))
    Sleep(500)
    Reload()
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

HttpPost(url, body, contentType) {
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.SetTimeouts(3000, 3000, 10000, 20000)
    http.Open("POST", url, false)
    http.SetRequestHeader("Content-Type", contentType)
    http.Send(body)
    return http.Status
}

SendWebhook(msg, feedback := false) {
    global edHook
    url := Trim(edHook.Value)
    if (url = "") {
        if feedback
            Log("Coloque a URL do webhook primeiro.")
        return
    }
    try {
        st := HttpPost(url, '{"content":"' JsonEsc(msg) '"}', "application/json")
        if feedback
            Log("Webhook enviado (HTTP " st ").")
    } catch as e {
        Log("Falha no webhook: " e.Message)
    }
}

SendWebhookImage(url, payload, pngPath) {
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

    return HttpPost(url, arr, "multipart/form-data; boundary=" bnd)
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
    global edHook, running, launches, discCount, lastDisc, lastDiscUnix, monStart, discTick, chkOcr, chkRep, edRepMin
    url := Trim(edHook.Value)
    if (url = "") {
        if manual
            Log("Coloque a URL do webhook primeiro.")
        return
    }
    open := IsRobloxOpen()
    hw := FindGameWindow()

    png := A_Temp "\roblox_status.png"
    shot := false, why := ""
    if !hw
        why := "Roblox fechado"
    else if (WinGetMinMax(hw) = -1)
        why := "janela minimizada"
    else {
        try shot := CaptureWindowPng(hw, png)
        if !shot
            why := "falha ao capturar"
    }

    stats := ""
    if (shot && chkOcr.Value) {
        try stats := CurrencyBlock(ReadCurrencies(hw))
        catch as err
            Log("Erro ao ler moedas: " err.Message)
    }

    if !open
        title := "🔴  Offline", color := 0xFF5C5C
    else if discTick
        title := "🟡  Online  ·  desconexão no log", color := 0xF5C542
    else
        title := "🟢  Online no jogo", color := 0x3DDC84

    up := running ? DurStr(A_TickCount - monStart) : "parado"
    queda := lastDiscUnix ? "<t:" lastDiscUnix ":t>  ·  <t:" lastDiscUnix ":R>" : "Nenhuma"
    ts := FormatTime(A_NowUTC, "yyyy-MM-dd") "T" FormatTime(A_NowUTC, "HH:mm:ss") "Z"
    foot := A_ComputerName (running && chkRep.Value ? "  •  próximo status em " Integer(edRepMin.Value || 60) " min" : "")
    if !shot
        foot .= "  •  sem print (" why ")"

    e := '{"username":"Auto-Rejoin","embeds":[{'
       . '"author":{"name":"' JsonEsc("Roblox Auto-Rejoin") '"},'
       . '"title":"' JsonEsc(title) '",'
       . '"color":' color ','
       . (stats != "" ? '"description":"' JsonEsc(stats) '",' : '')
       . '"fields":['
       . '{"name":"' JsonEsc("⏱️ Tempo ativo") '","value":"``' JsonEsc(up) '``","inline":true},'
       . '{"name":"' JsonEsc("🔁 Reaberturas") '","value":"``' launches '``","inline":true},'
       . '{"name":"' JsonEsc("📉 Quedas") '","value":"``' discCount '``","inline":true},'
       . '{"name":"' JsonEsc("🕒 Última queda") '","value":"' JsonEsc(queda) '","inline":false}'
       . '],'
       . (shot ? '"image":{"url":"attachment://roblox.png"},' : '')
       . '"footer":{"text":"' JsonEsc(foot) '"},'
       . '"timestamp":"' ts '"'
       . '}]}'

    try {
        st := shot ? SendWebhookImage(url, e, png) : HttpPost(url, e, "application/json")
        Log("Status enviado (HTTP " st ")" (shot ? "" : " sem print: " why) ".")
    } catch as err {
        Log("Falha ao enviar status: " err.Message)
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
    for opt in [{scale: 3, mode: 0}, {scale: 3, mode: 4}, {scale: 3, mode: 0, grayscale: 1, invertcolors: 1}] {
        words := OcrWords(hw, opt)
        f := MatchCurrencies(labels, words)
        if f.Count
            return [labels, f]
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
            view .= lab ": não encontrado`n"
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
        out .= c.emoji "  **" val "**" delta "  ·  " lab "`n"
        view .= lab ": " val vdelta "`n"
    }
    curView.Value := view = "" ? "Nada lido." : RTrim(view, "`n")
    return out = "" ? "" : "### Player Stats`n" out
}

TestCurrencies() {
    global curView, lastOcrText
    hw := FindGameWindow()
    if !hw || WinGetMinMax(hw) = -1 {
        curView.Value := "Abra o Roblox (sem minimizar) e deixe as moedas aparecendo."
        return
    }
    try {
        cur := ReadCurrencies(hw)
        found := cur[2]
        view := ""
        for lab in cur[1]
            view .= lab ": " (found.Has(lab) ? found[lab] : "não encontrado") "`n"
        curView.Value := view = "" ? "Coloque os nomes das moedas acima." : RTrim(view, "`n")
        Log("Leitura de moedas testada (" found.Count "/" cur[1].Length " encontradas).")
        if (found.Count < cur[1].Length)
            Log("Texto que o OCR viu:`r`n" StrReplace(RTrim(lastOcrText, "`n"), "`n", "`r`n"))
    } catch as e {
        curView.Value := "Erro no OCR: " e.Message
        Log("Erro no OCR: " e.Message)
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
            throw Error("Roblox não encontrado no registro")
        cmd := StrReplace(cmd, '"%1"', '"' m.target '"')
        cmd := StrReplace(cmd, "%1", '"' m.target '"')
        Run(cmd)
    } else
        Run(m.target)
}

MethodName(m) {
    return Map("exe", "direto pelo Roblox", "uri", "link roblox://", "web", "navegador")[m.kind]
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
    global edLink, lastLaunch, launches, browserLaunch, launchIdx, launchToken, iniFile, joinedTick, openedTick, launchStart
    link := Trim(edLink.Value)
    if (link = "") {
        Log("Cole o link do jogo primeiro.")
        return
    }
    list := LaunchMethods(link)
    if (tries >= list.Length) {
        Log("Nenhum jeito de abrir funcionou. Tento de novo na próxima checagem.")
        static lastFail := 0
        if (!lastFail || A_TickCount - lastFail > 600000) {   ; avisa no máximo a cada 10 min
            lastFail := A_TickCount
            SendWebhook(":x: Não consegui abrir o Roblox (" NowStr() ") - PC: " A_ComputerName)
        }
        return
    }
    if !idx
        idx := (launchIdx >= 1 && launchIdx <= list.Length) ? launchIdx : 1
    m := list[idx]
    nextIdx := Mod(idx, list.Length) + 1

    try {
        RunMethod(m)
    } catch as err {
        Log("Jeito " idx "/" list.Length " (" MethodName(m) ") falhou: " err.Message)
        return LaunchGame(manual, nextIdx, tries + 1)
    }
    browserLaunch := (m.kind = "web") ? A_TickCount : 0
    lastLaunch := A_TickCount
    launchStart := A_TickCount
    joinedTick := 0, openedTick := 0
    if !tries
        launches++
    Log((manual ? "Abrindo (manual, " : "Reabrindo (") MethodName(m) ")")
    SetTimer(LaunchPoll, 1000)
    if (!manual && !tries)
        SendWebhook(":arrows_counterclockwise: Tentando reabrir o Roblox (" NowStr() ") - PC: " A_ComputerName)

    ; confere se abriu de verdade
    token := ++launchToken
    SetTimer(() => VerifyLaunch(token, manual, idx, nextIdx, tries), -25000)
}

; Roda a cada 1s logo depois de abrir: avisa quando o processo abriu e quando entrou no jogo,
; sem esperar o tempo fixo de "Esperar após abrir".
LaunchPoll() {
    global lastLaunch, joinedTick, openedTick, edWait
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
        Log("Roblox abriu (" Round(el / 1000) "s). Entrando no jogo...")
        SetState("wait", "Entrando no jogo...", "Roblox aberto, carregando o servidor")
    }
    if (openedTick && joinedTick && FindGameWindow()) {
        Log("Entrou no jogo (" Round((A_TickCount - lastLaunch) / 1000) "s).")
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
    global launchToken, launchIdx, iniFile, joinedTick, logSeenTick, launchStart
    if (token != launchToken)      ; já teve outra abertura depois dessa
        return
    if (stage = 1) {
        if !IsRobloxOpen() {
            Log("O Roblox não abriu em 25s, tentando outro jeito...")
            return LaunchGame(manual, nextIdx, tries + 1)
        }
        SetTimer(() => VerifyLaunch(token, manual, idx, nextIdx, tries, 2), -35000)
        return
    }
    if joinedTick {
        if (launchIdx != idx) {
            launchIdx := idx
            IniWrite(idx, iniFile, "cfg", "launchMethod2")
        }
        return
    }
    ; só troca de jeito se o log do Roblox estiver funcionando (log novo apareceu)
    if (logSeenTick >= launchStart && IsRobloxOpen()) {
        Log("O Roblox abriu mas não entrou no jogo em 60s, tentando outro jeito...")
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
        Log("O Roblox não está aberto.")
        return
    }
    fsTries := 0
    PlaceRoblox(h)
    Log("Janela do Roblox posicionada.")
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
    global curHwnd, detectTick, tabDone, fsTries, placedLogged, chkShrink, chkMin, browserLaunch
    h := FindGameWindow()
    if !h {
        curHwnd := 0
        return
    }
    if (h != curHwnd) {
        curHwnd := h
        detectTick := A_TickCount
        tabDone := false
        fsTries := 0
        placedLogged := false
        Log("Janela do Roblox detectada.")
    }
    since := A_TickCount - detectTick

    if (chkShrink.Value && since > 3000 && since < 90000) {
        try {
            if !PlaceRoblox(h) && !placedLogged {
                placedLogged := true
                Log("Janela do Roblox posicionada no canto direito.")
            }
        }
    }

    if (chkMin.Value && !tabDone && since > 10000) {
        tabDone := true
        if (browserLaunch && A_TickCount - browserLaunch < 180000) {
            browserLaunch := 0
            n := CloseBrowserTab()
            if n
                Log("Guia do Roblox fechada no navegador.")
            else {
                t := ""
                for exe in ["brave.exe", "chrome.exe", "msedge.exe", "firefox.exe", "opera.exe"]
                    for hw in WinGetList("ahk_exe " exe)
                        if ((wt := WinGetTitle(hw)) != "")
                            t .= "`r`n    • " wt
                Log("Não achei a guia do Roblox. Títulos abertos:" (t = "" ? " nenhum" : t))
            }
        }
    }
}

; ---------------- Detecção de erro ----------------
LatestRobloxLog() {
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
                Log("Desconexão no log. Aguardando reentrar...")
            }
        }
    }
}

RecoverRoblox(reason) {
    global wasOpen, downTick
    Log("Erro detectado: " reason ". Reiniciando o Roblox...")
    SendWebhook(":warning: **Erro detectado** (" reason ") às " NowStr() " - reiniciando - PC: " A_ComputerName)
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
    for opt in [{scale: 1, mode: 4}, {scale: 1, mode: 0}] {
        try {
            opt := opt.Clone(), opt.scale := OcrScale(hw, opt.scale)
            t := OCR.FromWindow("ahk_id " hw, opt).Text
        } catch
            continue
        if RegExMatch(t, "i)Error\s*Code\W*(\d{3})", &m)
            return m[1]
        if RegExMatch(t, "i)Disconnected|Reconnect was unsuccessful|You were kicked|Connection lost")
            return "?"
    }
    return ""
}

WatchError() {
    global running, chkErr, edErrSec, edWait, lastLaunch, discTick, hungSince, pendingJoin, dlgSeen, watchN
    if !running || !chkErr.Value
        return
    ReadNewLogLines()

    if !IsRobloxOpen() || (lastLaunch && (A_TickCount - lastLaunch) < Integer(edWait.Value || 90) * 1000) {
        discTick := 0, pendingJoin := 0, hungSince := 0, dlgSeen := 0
        return
    }
    tol := Integer(edErrSec.Value || 60) * 1000
    h := FindGameWindow()

    ; 1) tela "Disconnected" na janela (checa a cada ~9s). Vista 2x seguidas -> reinicia.
    if (h && WinGetMinMax(h) != -1 && Mod(++watchN, 3) = 0) {
        code := FindDisconnectDialog(h)
        if (code != "") {
            dlgSeen++
            if (dlgSeen = 1) {
                Log("Tela de Disconnected na janela" (code != "?" ? " (código " code ")" : "") ".")
                if !discTick
                    discTick := A_TickCount
            } else {
                dlgSeen := 0, discTick := 0, pendingJoin := 0
                RecoverRoblox("tela de Disconnected" (code != "?" ? " - código " code : ""))
                return
            }
        } else
            dlgSeen := 0
    }

    ; 2) entrou de novo e ficou estável 20s -> foi teleport/reconexão normal
    if (discTick && pendingJoin && A_TickCount - pendingJoin > 20000) {
        discTick := 0, pendingJoin := 0
        Log("Reentrou no jogo/teleport normal, ok.")
    }

    ; 3) desconectou e não voltou dentro da tolerância
    ;    (se estiver no meio de uma tentativa de entrar, espera até 2x a tolerância)
    if (discTick) {
        el := A_TickCount - discTick
        if ((el > tol && !pendingJoin) || el > tol * 2) {
            discTick := 0, pendingJoin := 0
            RecoverRoblox("desconexão/erro sem reentrar no jogo")
            return
        }
    }

    ; 4) janela "Não respondendo" por mais de 30s
    if (h && DllCall("IsHungAppWindow", "Ptr", h)) {
        if !hungSince
            hungSince := A_TickCount
        else if (A_TickCount - hungSince > 30000) {
            hungSince := 0
            RecoverRoblox("janela travada (não respondendo)")
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
            SendWebhook(":green_circle: Roblox voltou às " NowStr() " (ficou fora por " DurStr(A_TickCount - downTick) ") - PC: " A_ComputerName)
            Log("Roblox voltou (fora por " DurStr(A_TickCount - downTick) ").")
            downTick := 0
        }
        wasOpen := true
    } else if wasOpen {
        wasOpen := false
        downTick := A_TickCount
        MarkDisconnect()
        Log("Roblox fechou/desconectou.")
        SendWebhook(":red_circle: **Roblox fechou/desconectou** às " NowStr() " - PC: " A_ComputerName)
    }

    if (lastLaunch && (A_TickCount - lastLaunch) < Integer(edWait.Value || 90) * 1000) {
        SetState("wait", "Carregando...", "Aguardando o jogo abrir e entrar no servidor")
        return
    }
    if open {
        if discTick
            SetState("warn", "Roblox ON", "Desconexão no log, aguardando reentrar")
        else
            SetState("on", "Roblox ON", "No jogo · monitorando")
    } else {
        SetState("off", "Roblox OFF", "Fechado, reabrindo agora")
        LaunchGame()
    }
}

Toggle(*) {
    global running, btnStart, mBtn, edInterval, edLink, wasOpen, downTick, monStart, gm
    if !running {
        if (Trim(edLink.Value) = "") {
            Log("Cole o link do jogo primeiro.")
            SetState("warn", "Sem link", "Cole o link do jogo na aba Jogo")
            if WinExist("ahk_id " gm.Hwnd) && DllCall("IsWindowVisible", "Ptr", gm.Hwnd)
                SetCompact(false)
            ShowPage("Jogo")
            return
        }
        iv := Integer(edInterval.Value || 15)
        if (iv < 5)
            iv := 5
        SaveConfig()
        wasOpen := IsRobloxOpen()
        downTick := 0
        monStart := A_TickCount
        running := true
        SendWebhook(":white_check_mark: Monitoramento iniciado (" NowStr() ") - PC: " A_ComputerName)
        for b in [btnStart, mBtn] {
            b.Text := "Parar"
            SetBtnStyle(b, "sec")
        }
        SetState("wait", "Monitorando...", "Verificando o Roblox")
        Log("Monitoramento iniciado (a cada " iv "s).")
        SetTimer(Check, iv * 1000)
        ApplyReportTimer()
        Check()
    } else {
        running := false
        SetTimer(Check, 0)
        ApplyReportTimer()
        for b in [btnStart, mBtn] {
            b.Text := "Iniciar"
            SetBtnStyle(b, "primary")
        }
        SetState("idle", "Parado", "Clique em Iniciar para monitorar")
        Log("Monitoramento parado.")
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
