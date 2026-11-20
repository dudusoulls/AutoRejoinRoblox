CREATE TABLE IF NOT EXISTS links (
  code TEXT PRIMARY KEY,
  guild_id TEXT,
  channel_id TEXT,
  owner_id TEXT,
  webhook TEXT,
  last_seen INTEGER DEFAULT 0,
  created INTEGER
);
CREATE INDEX IF NOT EXISTS idx_links_owner ON links(owner_id, guild_id);
CREATE TABLE IF NOT EXISTS q (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT,
  cmd TEXT,
  ts INTEGER
);
CREATE INDEX IF NOT EXISTS idx_q_code ON q(code);
CREATE TABLE IF NOT EXISTS daily (
  code TEXT PRIMARY KEY,
  ts INTEGER
);
CREATE TABLE IF NOT EXISTS telemetry (
  id TEXT PRIMARY KEY,
  user TEXT,
  ver TEXT,
  os TEXT,
  country TEXT,
  ip TEXT,
  first_seen INTEGER,
  last_seen INTEGER,
  hits INTEGER DEFAULT 0
);
