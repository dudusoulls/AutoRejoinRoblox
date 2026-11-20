# Bot do Auto Reconnect Roblox

Comando único: **/vincular** — cria um webhook no canal e entrega o link (só pra quem usou) pra colar no app.

## Instalar (uma vez)
1. https://discord.com/developers/applications → **New Application**.
2. Aba **Bot** → **Reset Token** → copie. (Intents privilegiados: deixe tudo desligado.)
3. Instale o Python 3.10+ (marque "Add to PATH").
4. Copie `.env.example` para `.env` e cole o token.
5. Dê dois cliques em `iniciar.bat` (na primeira vez instala as dependências).
6. Opcional: `instalar_inicio_automatico.bat` para iniciar com o Windows.

## Convite
No app, em `BOT_CLIENT_ID` (roblox_autorejoin.ahk) coloque o **Application ID**
(aba General Information). O botão "Convidar o bot" já usa as permissões certas.

## Uso
No servidor, no canal desejado: `/vincular` → copie o link → cole no campo Webhook do app.
