#Requires AutoHotkey v2.0
#SingleInstance Force
;  ───────────────────────────────────────────────────────────
;  Atualizar / Reparar  —  Auto Reconnect Roblox
;  Deixe este .ahk na MESMA pasta do AutoReconnectRoblox.exe.
;  Rode ele quando o app nao abrir ou pra forcar a ultima versao.
;  Ele baixa o exe mais novo do GitHub e troca no lugar.
;  ───────────────────────────────────────────────────────────

REPO     := "dudusoulls/AutoRejoinRoblox"
EXE_NAME := "AutoReconnectRoblox.exe"
URL      := "https://github.com/" REPO "/releases/latest/download/" EXE_NAME

pasta    := A_ScriptDir
alvo     := pasta "\" EXE_NAME
tmp      := pasta "\" EXE_NAME ".new"

; ── GUI simples de status ──
g := Gui("+AlwaysOnTop -MinimizeBox", "Atualizar — Auto Reconnect Roblox")
g.BackColor := "1b1b1b"
g.SetFont("s10", "Segoe UI")
g.MarginX := 18, g.MarginY := 16
st := g.AddText("w380 cWhite", "Pronto para baixar a ultima versao.")
g.AddText("w380 cGray s8", "Pasta: " pasta)
bar := g.AddProgress("w380 h10 -Smooth Range0-100")
bOk := g.AddButton("w120 Default", "Atualizar agora")
bClose := g.AddButton("x+16 w120", "Fechar")
bOk.OnEvent("Click", (*) => Atualizar())
bClose.OnEvent("Click", (*) => ExitApp())
g.OnEvent("Close", (*) => ExitApp())
g.Show()

Status(txt, pct := -1) {
    st.Value := txt
    if (pct >= 0)
        bar.Value := pct
}

Atualizar(*) {
    bOk.Enabled := false, bClose.Enabled := false

    ; 1) fecha o app se estiver aberto (senao o arquivo fica travado)
    if ProcessExist(EXE_NAME) {
        Status("Fechando o app aberto...", 10)
        try RunWait('taskkill /f /im "' EXE_NAME '"', , "Hide")
        Sleep 800
    }

    ; 2) baixa pra um arquivo temporario
    Status("Baixando a ultima versao do GitHub...", 30)
    try FileDelete(tmp)
    try {
        Download(URL, tmp)
    } catch as e {
        Falhou("Nao consegui baixar.`nVerifique a internet e tente de novo.`n`n(" e.Message ")")
        return
    }

    ; 3) confere se veio um exe de verdade (nao uma pagina de erro)
    Status("Verificando o arquivo...", 70)
    if !FileExist(tmp) || FileGetSize(tmp) < 200000 {
        try FileDelete(tmp)
        Falhou("O download veio incompleto ou vazio. Tente novamente.")
        return
    }

    ; 4) troca no lugar
    Status("Instalando...", 85)
    try FileDelete(alvo)
    Sleep 200
    try {
        FileMove(tmp, alvo, true)
    } catch as e {
        Falhou("Nao consegui substituir o exe.`nFeche qualquer janela do app e tente de novo.`n`n(" e.Message ")")
        return
    }

    Status("Pronto! Versao atualizada.", 100)
    r := MsgBox("Atualizado com sucesso!`n`nAbrir o app agora?", "Concluido", "YesNo Iconi")
    if (r = "Yes") {
        try Run('"' alvo '"')
    }
    ExitApp()
}

Falhou(msg) {
    bar.Value := 0
    Status("Falhou. " StrReplace(msg, "`n", " "))
    MsgBox(msg, "Erro ao atualizar", "Iconx")
    bOk.Enabled := true, bClose.Enabled := true
}
