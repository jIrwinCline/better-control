# Betta — Claude Code Skills

Skills (slash commands) for agents working inside a Betta session.

## Setup

```bash
chmod +x mc
./mc start          # initializes DB and starts server on :3737
```

The startup URL and token are printed to the terminal.

---

## Skills

### `/mc-add`
Add a new task to the board.

```
/mc-add <subject> [description] [priority 0-9]
```

Example:
```
/mc-add "Fix login bug" "JWT expiry not handled" 5
```

---

### `/mc-ls`
List all open (non-done) tasks.

```
/mc-ls
```

---

### `/mc-claim`
Claim a task and mark it `in_progress`.

```
/mc-claim <task_id> [agent_name]
```

---

### `/mc-done`
Mark a task as done, with an optional note.

```
/mc-done <task_id> [note]
```

---

### `/mc-board`
Open the live board in a browser (prints the URL with auth token).

```
/mc-board
```

---

## Agent heartbeat

Agents should POST a heartbeat every 30 s to stay visible on the board:

```bash
curl -s -X POST "http://localhost:3737/api/agent/heartbeat?token=$MC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"my-agent","role":"coder","status":"busy"}'
```

Set `MC_TOKEN` to the value printed at server startup, or export it from your
session hook so all agents share it automatically.
