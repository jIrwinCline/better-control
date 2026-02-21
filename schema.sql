-- Betta schema — run once to initialize ~/.openclaw/mission-control.db

CREATE TABLE IF NOT EXISTS tasks (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    subject      TEXT    NOT NULL,
    description  TEXT,
    status       TEXT    NOT NULL DEFAULT 'pending'
                         CHECK(status IN ('pending','claimed','in_progress','blocked','review','done')),
    owner        TEXT,
    priority     INTEGER NOT NULL DEFAULT 0,
    created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    claimed_at   TEXT,
    completed_at TEXT
);

CREATE TABLE IF NOT EXISTS agents (
    name      TEXT PRIMARY KEY,
    role      TEXT,
    status    TEXT NOT NULL DEFAULT 'idle'
                   CHECK(status IN ('idle','busy','offline')),
    last_seen TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS messages (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    from_agent TEXT NOT NULL,
    task_id    INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
    body       TEXT NOT NULL,
    msg_type   TEXT NOT NULL DEFAULT 'note'
                    CHECK(msg_type IN ('note','status','error')),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_tasks_status   ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_messages_task  ON messages(task_id);
