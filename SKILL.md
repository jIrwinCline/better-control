# Betta — Claude Code Skills

Skills (slash commands) for agents working inside a Betta session.

## Setup

```bash
chmod +x bc
./bc start          # initializes DB and starts server on :3737
```

The startup URL and token are printed to the terminal.

---

## Skills

### `/bc-add`
Add a new task to the board.

```
/bc-add <subject> [description] [priority 0-9]
```

Example:
```
/bc-add "Fix login bug" "JWT expiry not handled" 5
```

---

### `/bc-ls`
List all open (non-done) tasks.

```
/bc-ls
```

---

### `/bc-claim`
Claim a task and mark it `in_progress`.

```
/bc-claim <task_id> [agent_name]
```

---

### `/bc-done`
Mark a task as done, with an optional note.

```
/bc-done <task_id> [note]
```

---

### `/bc-board`
Open the live board in a browser (prints the URL with auth token).

```
/bc-board
```

---

## Agent heartbeat

Agents should POST a heartbeat every 30 s to stay visible on the board:

```bash
curl -s -X POST "http://localhost:3737/api/agent/heartbeat?token=$BC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"my-agent","role":"coder","status":"busy"}'
```

Set `BC_TOKEN` to the value printed at server startup, or export it from your
session hook so all agents share it automatically.
