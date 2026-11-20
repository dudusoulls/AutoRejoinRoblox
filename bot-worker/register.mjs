// Registra os comandos do bot no Discord. Uso:
//   set DISCORD_APP_ID=...   set DISCORD_BOT_TOKEN=...   node register.mjs
const id = process.env.DISCORD_APP_ID, token = process.env.DISCORD_BOT_TOKEN;
if (!id || !token) { console.error("Defina DISCORD_APP_ID e DISCORD_BOT_TOKEN"); process.exit(1); }
const choices = ["status","print","iniciar","parar","reiniciar","moedas","resumo","pc","historico","logs","painel","grafico","ajuda"].map((n) => ({ name: n, value: n }));
const commands = [
  { name: "vincular", description: "Liga o seu app Auto Reconnect a este canal", options: [{ type: 3, name: "codigo", description: "Código mostrado no app (Discord → Bot oficial)", required: true }] },
  { name: "desvincular", description: "Remove o vínculo do seu app neste servidor" },
  { name: "roblox", description: "Controla o SEU Roblox", options: [{ type: 3, name: "comando", description: "O que fazer", required: true, choices }] },
];
const r = await fetch(`https://discord.com/api/v10/applications/${id}/commands`, {
  method: "PUT", headers: { Authorization: `Bot ${token}`, "Content-Type": "application/json" }, body: JSON.stringify(commands) });
console.log(r.status, await r.text());
