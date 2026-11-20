// Bot oficial do Auto Reconnect — Cloudflare Worker (sem servidor, sem PC ligado).
// Slash commands chegam aqui (Interactions Endpoint), ficam numa fila (D1) e o app de cada
// usuário busca a fila a cada ~8 s. As respostas voltam pelo webhook que o próprio bot criou.

const API = "https://discord.com/api/v10";
const CMDS = ["status", "print", "iniciar", "parar", "reiniciar", "moedas", "resumo", "pc", "historico", "logs", "painel", "grafico", "ajuda"];
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

async function interaction(i, env) {
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
    return reply("✅ Vinculado! Deixe o app aberto com **Bot oficial** ligado. Os avisos virão neste canal e você controla seu Roblox com `/roblox`.");
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
  async fetch(req, env) {
    const url = new URL(req.url);
    if (req.method === "GET" && url.pathname === "/poll") return poll(url, env);
    if (req.method === "POST") {
      const body = await req.text();
      if (!(await verify(req, body, env))) return new Response("bad signature", { status: 401 });
      return interaction(JSON.parse(body), env);
    }
    return new Response("Auto Reconnect bot");
  },
};
