# Betta — Task Coordination for Multi-Agent Claude Sessions

A lightweight task board and coordination server for multi-agent Claude Code (OpenClaw) workflows. Agents create tasks, claim them, post heartbeats, and mark them done — all visible in a live web dashboard.

---

## What's in the repo

| File | Purpose |
|---|---|
| `bc` | CLI launcher — start the server, add/list/complete tasks |
| `bc-server.py` | Flask server — REST API + SSE live board |
| `schema.sql` | SQLite schema (tasks, agents, messages) |
| `index.html` | Desktop web dashboard |
| `mobile/` | Mobile-friendly dashboard variant |
| `SKILL.md` | Slash-command skills for agents running inside a session |

---

## Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip sqlite3
pip3 install flask
```

---

## Quick start

```bash
git clone https://github.com/jIrwinCline/better-control.git
cd better-control
chmod +x bc
./bc start
```

On first run it creates `~/.better-control/better-control.db` from `schema.sql`, then starts the server on port **3737** and prints:

```
  Local:   http://localhost:3737/?token=<token>
  Network: http://<your-ip>:3737/?token=<token>

  Token: <token>
```

Open the printed URL in a browser to see the live board.

---

## CLI reference

```bash
./bc start                          # init DB (if needed) and start server
./bc init                           # init DB only, don't start server
./bc add "subject" ["desc"] [0-9]  # add a task (priority 0–9, default 0)
./bc ls                             # list open tasks
./bc done <id>                      # mark a task done
./bc reset                          # drop and recreate all tables (prompts first)
```

---

## Persistent token (recommended for OpenClaw)

By default the token is random and regenerates on every restart, which breaks agents that cached it. Fix: set `BC_TOKEN` before starting.

```bash
export BC_TOKEN="your-chosen-secret"
./bc start
```

Add this to your systemd service `Environment=` line or your shell profile so all agents share the same token across restarts.

---

## REST API

All `/api` routes require `?token=<BC_TOKEN>` as a query parameter.

| Method | Path | Body | Description |
|---|---|---|---|
| GET | `/api/board` | — | Full board state (tasks + agents) |
| GET | `/api/task/<id>` | — | Task detail + messages |
| POST | `/api/task/<id>/claim` | `{"agent":"name"}` | Claim a task → `in_progress` |
| POST | `/api/task/<id>/complete` | `{"note":"optional"}` | Mark done |
| GET | `/api/heartbeat` | — | SSE stream — fires on any task update |
| POST | `/api/agent/heartbeat` | `{"name":"…","role":"…","status":"…"}` | Agent keepalive |

### Agent heartbeat

Agents should POST every ~30 s to remain visible on the board:

```bash
curl -s -X POST "http://localhost:3737/api/agent/heartbeat?token=$BC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"threads-scheduler","role":"poster","status":"busy"}'
```

Valid status values: `idle`, `busy`, `offline`.

---

## Survive reboots (systemd)

```bash
sudo tee /etc/systemd/system/better-control.service >/dev/null <<'EOF'
[Unit]
Description=Better Control task board
After=network.target

[Service]
Type=simple
User=main
WorkingDirectory=/home/main/better-control
ExecStart=/home/main/better-control/bc start
Restart=always
RestartSec=2
Environment=PYTHONUNBUFFERED=1
Environment=BC_TOKEN=your-chosen-secret

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now better-control
```

---

## Security

- Do **not** expose port 3737 publicly. Use an SSH tunnel or restrict access to your tailnet.
- SSH tunnel from your local machine: `ssh -N -L 3737:127.0.0.1:3737 user@your-vps`
- Then open `http://127.0.0.1:3737/?token=<BC_TOKEN>` locally.

---

## OpenClaw multi-agent pattern

```
Main agent          → ./bc add "Draft 7 Threads posts for topic X"  5
threads_trends      → claims task, heartbeats "busy", returns packages
Main agent          → ./bc add "Post approved thread T02"  4
threads_scheduler   → claims task, heartbeats "busy", posts, marks done
```

The board becomes the single source of truth for what every agent is doing.

For slash-command skills usable inside a Claude Code session, see [SKILL.md](./SKILL.md).
