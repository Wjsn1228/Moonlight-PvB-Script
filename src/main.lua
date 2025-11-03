import express from "express";
import session from "express-session";
import fetch from "node-fetch";
import dotenv from "dotenv";

dotenv.config();
const app = express();
app.use(express.static("public"));
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: true }));

// Discord OAuth2 登入
app.get("/auth/discord", (req, res) => {
  const redirect = `https://discord.com/oauth2/authorize?client_id=${process.env.CLIENT_ID}&redirect_uri=${encodeURIComponent(process.env.REDIRECT_URI)}&response_type=code&scope=identify%20guilds.members.read`;
  res.redirect(redirect);
});

// 回調處理
app.get("/auth/discord/callback", async (req, res) => {
  const { code } = req.query;
  if (!code) return res.redirect("/");

  const params = new URLSearchParams({
    client_id: process.env.CLIENT_ID,
    client_secret: process.env.CLIENT_SECRET,
    grant_type: "authorization_code",
    code,
    redirect_uri: process.env.REDIRECT_URI
  });

  const tokenData = await fetch("https://discord.com/api/oauth2/token", {
    method: "POST",
    body: params,
    headers: { "Content-Type": "application/x-www-form-urlencoded" }
  }).then(r => r.json());

  const user = await fetch("https://discord.com/api/users/@me", {
    headers: { Authorization: `Bearer ${tokenData.access_token}` }
  }).then(r => r.json());

  const guilds = await fetch("https://discord.com/api/users/@me/guilds", {
    headers: { Authorization: `Bearer ${tokenData.access_token}` }
  }).then(r => r.json());

  const inGuild = guilds.some(g => g.id === process.env.GUILD_ID);

  if (!inGuild) return res.send("<h2>🚫 請先加入 Discord 群組再回來！</h2><a href='https://discord.gg/sNNYXKZ9MJ'>加入群組</a>");

  const key = `FREE_${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
  req.session.key = key;
  res.redirect(`/key`);
});

// 顯示密鑰
app.get("/key", (req, res) => {
  if (!req.session.key) return res.redirect("/");
  res.send(`
    <html><body style="background:black;color:white;text-align:center;font-family:sans-serif;">
    <h2>✅ 你的應用程式密碼</h2>
    <div style="font-size:22px;margin:20px;">${req.session.key}</div>
    <button onclick="navigator.clipboard.writeText('${req.session.key}')">📋 複製密鑰</button>
    </body></html>
  `);
});

app.listen(3000, () => console.log("✅ Server running on http://localhost:3000"));
