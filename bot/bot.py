"""Bot oficial do Auto Reconnect Roblox.

Faz uma coisa só: /vincular cria um webhook no canal onde o comando foi usado
e entrega o link (só pra quem usou) pra colar no app. Leve: fica parado e só
acorda quando alguém usa o comando.
"""
import os
import discord
from discord import app_commands
from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv("DISCORD_TOKEN", "").strip()
if not TOKEN:
    raise SystemExit("Faltou DISCORD_TOKEN no arquivo .env (veja .env.example).")

intents = discord.Intents.none()          # não precisa ler mensagens
bot = discord.Client(intents=intents)
tree = app_commands.CommandTree(bot)


@tree.command(name="vincular", description="Cria o webhook deste canal para o Auto Reconnect Roblox")
@app_commands.guild_only()
@app_commands.default_permissions(manage_webhooks=True)
async def vincular(inter: discord.Interaction):
    ch = inter.channel
    if not isinstance(ch, (discord.TextChannel, discord.Thread)):
        await inter.response.send_message("Use em um canal de texto.", ephemeral=True)
        return
    base = ch.parent if isinstance(ch, discord.Thread) else ch
    await inter.response.defer(ephemeral=True)
    try:
        hook = await base.create_webhook(name="Auto Reconnect", reason=f"/vincular por {inter.user}")
    except discord.Forbidden:
        await inter.followup.send(
            "Não tenho permissão de **Gerenciar webhooks** neste canal. "
            "Dê essa permissão ao bot e tente de novo.", ephemeral=True)
        return
    except discord.HTTPException as e:
        await inter.followup.send(f"Não consegui criar o webhook ({e.status}). Tente de novo.", ephemeral=True)
        return
    emb = discord.Embed(
        title="Pronto! Webhook criado",
        description=("Copie o link abaixo e cole em **Webhook** no app "
                     "(Discord → Webhook → campo do link). Não compartilhe com ninguém."),
        color=0x6EA8FF)
    emb.add_field(name="Link", value=f"||{hook.url}||", inline=False)
    emb.set_footer(text="Auto Reconnect Roblox")
    await inter.followup.send(embed=emb, ephemeral=True)


@bot.event
async def on_ready():
    await tree.sync()
    await bot.change_presence(activity=discord.Game("/vincular"))
    print(f"Online como {bot.user} (ID {bot.user.id})")


bot.run(TOKEN, log_handler=None)
