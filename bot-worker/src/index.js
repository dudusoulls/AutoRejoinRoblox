// Bot oficial do Auto Reconnect — Cloudflare Worker (sem servidor, sem PC ligado).
// Slash commands chegam aqui (Interactions Endpoint), ficam numa fila (D1) e o app de cada
// usuário busca a fila a cada ~8 s. As respostas voltam pelo webhook que o próprio bot criou.

const API = "https://discord.com/api/v10";
const CMDS = ["status", "print", "iniciar", "parar", "reiniciar", "moedas", "resumo", "pc", "historico", "logs", "painel", "grafico", "ajuda"];
const QR_URL = "https://raw.githubusercontent.com/dudusoulls/AutoRejoinRoblox/main/donate_qr.png";
const REPO = "https://github.com/dudusoulls/AutoRejoinRoblox/releases/latest";

// Mensagem de boas-vindas (ao adicionar o bot) e lembrete diário (no canal vinculado)
function welcomeEmbed(full) {
  const how =
    "### ✅ Tudo pronto!\n" +
    "Este canal agora recebe os avisos do **seu** app e você controla o **seu** Roblox por aqui com `/roblox comando:...`\n\n" +
    "### 🎮 Comandos\n" +
    "```\nstatus  print  iniciar  parar  reiniciar\nmoedas  resumo  pc  historico  logs\npainel  grafico  ajuda\n```\n" +
    "### 📌 Webhook no app\n" +
    "**1.** Abra o app → **EXTRAS → Webhook**\n" +
    "**2.** Cole o link do webhook (o bot te mandou numa mensagem só sua, no momento do `/vincular`)\n" +
    "**3.** Ative os avisos que quiser\n" +
    "-# Com **Bot oficial** ligado (EXTRAS → Bot) o app já pega o webhook sozinho.\n";
  const thanks =
    "### 💜 Obrigado por usar o Auto Reconnect!\n" +
    "O app é **grátis** e feito por uma pessoa só. Se ele está te ajudando a farmar, qualquer **Pix** ajuda a manter o projeto vivo — é só escanear o QR abaixo. 🙏\n";
  return {
    author: { name: "Auto Reconnect Roblox" },
    title: full ? "👋  Bem-vindo ao Auto Reconnect!" : "☀️  Bom dia!",
    description: (full ? how + "\n" : "-# Seu lembrete diário. Comandos: `/roblox`, `/vincular`, `/desvincular`\n\n") + thanks + "\n[⬇ Baixar a versão mais recente](" + REPO + ")",
    color: 0x6ea8ff,
    image: { url: QR_URL },
    footer: { text: "Pix · escaneie o QR  •  obrigado pelo apoio" },
  };
}

const enc = new TextEncoder();
const hex = (h) => Uint8Array.from(h.match(/.{2}/g).map((b) => parseInt(b, 16)));
const CODE_RE = /^[a-f0-9]{32}$/i;

async function verify(req, body, env) {
  const sig = req.headers.get("X-Signature-Ed25519");
  const ts = req.headers.get("X-Signature-Timestamp");
  if (!sig || !ts) return false;
  try {
    const key = await crypto.subtle.importKey("raw", hex(env.DISCORD_PUBLIC_KEY), { name: "NODE-ED25519", namedCurve: "NODE-ED25519" }, false, ["verify"]);
    return await crypto.subtle.verify("NODE-ED25519", key, hex(sig), enc.encode(ts + body));
  } catch { return false; }
}

const reply = (content) => Response.json({ type: 4, data: { content, flags: 64 } });
const optVal = (i, name) => (i.data.options || []).find((o) => o.name === name)?.value;

async function interaction(i, env, ctx) {
  if (i.type === 1) return Response.json({ type: 1 });
  if (i.type !== 2) return reply("?");
  const user = i.member?.user?.id || i.user?.id;
  const guild = i.guild_id || "dm";
  const now = Math.floor(Date.now() / 1000);

  if (i.data.name === "vincular") {
    const code = String(optVal(i, "codigo") || "").trim().toLowerCase();
    if (!CODE_RE.test(code)) return reply("❌ Código inválido. Copie o código inteiro que aparece no app (aba Discord → Bot oficial).");
    if (guild === "dm") return reply("❌ Use o comando dentro de um servidor, no canal onde quer receber os avisos.");
    const old = await env.DB.prepare("SELECT owner_id FROM links WHERE code=?").bind(code).first();
    if (old && old.owner_id !== user) return reply("❌ Esse código já está vinculado a outra pessoa.");
    const r = await fetch(`${API}/channels/${i.channel_id}/webhooks`, {
      method: "POST",
      headers: { Authorization: `Bot ${env.DISCORD_BOT_TOKEN}`, "Content-Type": "application/json" },
      body: JSON.stringify({ name: "Auto Reconnect" }),
    });
    if (!r.ok) return reply("❌ Não consegui criar o webhook aqui. Dê ao bot a permissão **Gerenciar Webhooks** neste canal e tente de novo.");
    const w = await r.json();
    const url = `https://discord.com/api/webhooks/${w.id}/${w.token}`;
    await env.DB.prepare("INSERT OR REPLACE INTO links(code,guild_id,channel_id,owner_id,webhook,last_seen,created) VALUES(?,?,?,?,?,0,?)")
      .bind(code, guild, i.channel_id, user, url, now).run();
    // boas-vindas + agradecimento + QR no canal vinculado (só na primeira vez)
    if (!old)
      ctx.waitUntil(fetch(url, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ username: "Auto Reconnect", embeds: [welcomeEmbed(true)] }) }));
    // o webhook criado + como colocar no app (só você vê esta mensagem)
    return reply(
      "✅ **Vinculado!** Criei um webhook neste canal. Só você vê esta mensagem.\n\n" +
      "**Seu webhook** (é secreto — não compartilhe):\n```\n" + url + "\n```\n" +
      "### 📌 Como colocar no app\n" +
      "**1.** Abra o app → **EXTRAS → Webhook**\n" +
      "**2.** Cole o link acima em **URL do webhook** e salve\n" +
      "**3.** Ative as notificações que quiser (queda, volta, painel ao vivo…)\n\n" +
      "-# Com **Bot oficial** ligado o app já recebe esse webhook sozinho. Colar à mão só serve se quiser usar o webhook sem o bot."
    );
  }

  if (i.data.name === "desvincular") {
    await env.DB.prepare("DELETE FROM links WHERE owner_id=? AND guild_id=?").bind(user, guild).run();
    return reply("🗑️ Vínculo removido.");
  }

  if (i.data.name === "roblox") {
    const cmd = String(optVal(i, "comando") || "");
    if (!CMDS.includes(cmd)) return reply("❌ Comando desconhecido.");
    const row = await env.DB.prepare("SELECT code,last_seen FROM links WHERE owner_id=? AND guild_id=? ORDER BY created DESC LIMIT 1").bind(user, guild).first();
    if (!row) return reply("🔗 Você ainda não vinculou. Use `/vincular` com o código do seu app.");
    await env.DB.prepare("INSERT INTO q(code,cmd,ts) VALUES(?,?,?)").bind(row.code, "!" + cmd, now).run();
    const off = now - (row.last_seen || 0) > 60;
    return reply(off ? "⚠️ Comando guardado, mas seu app parece fechado ou sem internet. Ele executa assim que voltar (até 10 min)." : "📨 Enviado ao seu PC. A resposta chega neste canal em instantes.");
  }
  return reply("?");
}

// lembrete diário: só pra quem usou o app nos últimos 3 dias, no canal vinculado (webhook)
async function dailyReminders(env) {
  const now = Math.floor(Date.now() / 1000);
  const { results } = await env.DB.prepare(
    "SELECT l.code, l.webhook FROM links l LEFT JOIN daily d ON d.code=l.code " +
    "WHERE l.last_seen > ? AND l.created < ? AND (d.ts IS NULL OR d.ts < ?) LIMIT 100"
  ).bind(now - 3 * 86400, now - 20 * 3600, now - 20 * 3600).all();
  const body = JSON.stringify({ username: "Auto Reconnect", embeds: [welcomeEmbed(false)] });
  for (const r of results) {
    const res = await fetch(r.webhook, { method: "POST", headers: { "Content-Type": "application/json" }, body });
    if (res.ok || res.status === 404 || res.status === 401)
      await env.DB.prepare("INSERT OR REPLACE INTO daily(code,ts) VALUES(?,?)").bind(r.code, now).run();
  }
}

async function poll(url, env) {
  const code = (url.searchParams.get("code") || "").toLowerCase();
  if (!CODE_RE.test(code)) return new Response("BAD", { status: 400 });
  const row = await env.DB.prepare("SELECT webhook FROM links WHERE code=?").bind(code).first();
  if (!row) return new Response("NOLINK", { status: 404 });
  const now = Math.floor(Date.now() / 1000);
  await env.DB.prepare("UPDATE links SET last_seen=? WHERE code=?").bind(now, code).run();
  await env.DB.prepare("DELETE FROM q WHERE ts<?").bind(now - 600).run();
  const { results } = await env.DB.prepare("SELECT id,cmd FROM q WHERE code=? ORDER BY id LIMIT 5").bind(code).all();
  let out = `W|${row.webhook}\n`;
  for (const r of results) {
    out += `C|${r.cmd}\n`;
    await env.DB.prepare("DELETE FROM q WHERE id=?").bind(r.id).run();
  }
  return new Response(out, { headers: { "Content-Type": "text/plain" } });
}

export default {
  async scheduled(event, env, ctx) {
    ctx.waitUntil(dailyReminders(env));
  },
  async fetch(req, env, ctx) {
    const url = new URL(req.url);
    if (req.method === "GET" && url.pathname === "/poll") return poll(url, env);
    if (req.method === "POST" && url.pathname === "/events") {          // Webhook Events do Discord (bot adicionado a um servidor)
      const body = await req.text();
      if (!(await verify(req, body, env))) return new Response("bad signature", { status: 401 });
      const j = JSON.parse(body);
      return new Response(null, { status: 204 });
    }
    if (req.method === "POST") {
      const body = await req.text();
      if (!(await verify(req, body, env))) return new Response("bad signature", { status: 401 });
      return interaction(JSON.parse(body), env, ctx);
    }
    return new Response("Auto Reconnect bot");
  },
};
