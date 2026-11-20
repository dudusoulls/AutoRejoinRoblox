# Muda a foto (GIF) e a descrição do bot oficial. Rode: powershell -File perfil.ps1
$tok = Read-Host "Token do bot"
$h = @{ Authorization = "Bot $tok"; "User-Agent" = "DiscordBot (autoreconnect, 1.0)" }
$gif = "$env:TEMP\avatar.gif"
Invoke-WebRequest "https://raw.githubusercontent.com/dudusoulls/AutoRejoinRoblox/main/bot-worker/avatar.gif" -OutFile $gif
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($gif))
$body = @{ avatar = "data:image/gif;base64,$b64" } | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri "https://discord.com/api/v10/users/@me" -Headers $h -ContentType "application/json" -Body $body | Out-Null
Write-Host "Foto atualizada."
$body = @{ description = "made by dudu and claude.ai" } | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri "https://discord.com/api/v10/applications/@me" -Headers $h -ContentType "application/json" -Body $body | Out-Null
Write-Host "Descrição atualizada."
