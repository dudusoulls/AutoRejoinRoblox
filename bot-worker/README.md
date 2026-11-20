# Bot oficial (Cloudflare Worker)

Sem servidor, sem PC ligado, grátis. Cada usuário só controla o **próprio** Roblox.

## Fluxo
1. Usuário convida o bot (botão no app: Ferramentas → Convidar o bot).
2. No app: aba **Discord → Bot oficial**, liga a chave e copia o código.
3. No servidor dele: `/vincular codigo:<código>` (o bot cria um webhook no canal e o app preenche sozinho).
4. `/roblox comando:status` etc. O comando entra numa fila; o app busca a fila a cada ~8 s e responde no canal.

## Instalar (uma vez)
1. https://discord.com/developers/applications → New Application. Copie **Application ID** e **Public Key**; em *Bot*, crie o token.
2. Instale o Node.js, depois no PowerShell dentro desta pasta:
   ```
   npm i -g wrangler
   wrangler login
   wrangler d1 create auto-reconnect        (copie o database_id para wrangler.toml)
   wrangler d1 execute auto-reconnect --remote --file=schema.sql
   wrangler secret put DISCORD_PUBLIC_KEY
   wrangler secret put DISCORD_BOT_TOKEN
   wrangler deploy
   ```
3. No Developer Portal → *General Information* → **Interactions Endpoint URL** = a URL do Worker (`https://auto-reconnect-bot.<sua-conta>.workers.dev`).
4. Registrar os comandos:
   ```
   set DISCORD_APP_ID=SEU_ID
   set DISCORD_BOT_TOKEN=SEU_TOKEN
   node register.mjs
   ```
5. No app (`roblox_autorejoin.ahk`): `BOT_CLIENT_ID` = Application ID e `BOT_API` = URL do Worker.

O token fica só nos *secrets* do Cloudflare — nunca no app nem no GitHub.

## Mensagem de boas-vindas e lembrete diário
- **Ao adicionar o bot:** Developer Portal → *Webhooks* → **Events URL** = `https://SEU-WORKER.workers.dev/events` (salve; o Discord testa) → ative o evento **Application Authorized**. O bot manda a mensagem de ajuda + QR de Pix no canal de sistema do servidor.
- **Todo dia:** um *cron* do Cloudflare (`wrangler.toml`) posta um lembrete curto com o QR no canal vinculado, só para quem usou o app nos últimos 3 dias.
- Depois de atualizar: `wrangler d1 execute auto-reconnect --remote --file=schema.sql` e `wrangler deploy`.
