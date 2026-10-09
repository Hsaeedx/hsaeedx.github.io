CREATE TABLE IF NOT EXISTS visits (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  time     TEXT NOT NULL,
  ip       TEXT,
  org      TEXT,
  asn      INTEGER,
  city     TEXT,
  region   TEXT,
  country  TEXT,
  path     TEXT,
  referrer TEXT,
  ua       TEXT
);

CREATE INDEX IF NOT EXISTS visits_time ON visits (time);
