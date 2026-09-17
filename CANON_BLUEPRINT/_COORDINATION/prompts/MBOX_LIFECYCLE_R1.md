# MBOX_LIFECYCLE_R1 — check mailbox after every stop

Mailbox is a **file drop**. It does **not** open or resume a stopped Cursor chat.
A HIGH ping to inbox is invisible until a live session reads the files.

## Mandatory agent cycle

```
START  → python _COORDINATION/mailbox_cycle.py AGENT_X start
WORK   → do the task
STOP   → python _COORDINATION/mailbox_cycle.py AGENT_X stop
```

`stop` exit codes:

- `0` = STOP_CLEAN (no unread, no open ACTION/CRITICAL patches)
- `2` = STOP_DIRTY — drain / ACK, then run `stop` again. Do not claim idle.

`start` is what `CHECK MAILBOX` means. It does **not** mark mail read.

After processing: `python _COORDINATION/mailbox.py AGENT_X mark-read-all`

## Stopped chat (owner)

If the agent process/chat is already stopped:

1. Open the roster chat (`_COORDINATION/agent_chat_roster.json`)
2. Paste exactly: `CHECK MAILBOX`
3. Agent runs `mailbox_cycle.py AGENT_X start`, then work, then `stop`

```
python _COORDINATION/owner_wake.py AGENT_B
```

## Do not

- Spam extra HIGH mail to wake a dead chat
- Treat `check` as mark-read
- Treat registry `STALE` as “has not read” — STALE means no heartbeat
