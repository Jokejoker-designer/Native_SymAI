"""Mailbox lifecycle law: START check, STOP check, durable WAKE cue.

Mailbox is a file drop. A stopped Cursor chat does not poll it.
This module does not open chats. It writes cues the next live session
must consume, and prints the owner one-liner for a stopped chat.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from coord_util import (
    atomic_write_json,
    configure_stdio,
    resolve_coordination_dir,
    safe_agent_id,
    safe_print,
)
from mailbox import Mailbox
from patch_store import PatchStore

configure_stdio()

WORKTREE_ROOTS = [Path(r"d:\FPGA\NATIVE_AI\worktrees")]
DEFAULT_ROSTER_NAME = "agent_chat_roster.json"
WAKE_NAME = "WAKE_REQUIRED.txt"
SHUTDOWN_NAME = "last_shutdown.json"
OWNER_PASTE = "CHECK MAILBOX"
DONE_STATES = {"APPLIED", "VERIFIED", "NOT_REQUIRED"}
ROLES = {
    "AGENT_A": "Architecture Lead",
    "AGENT_B": "Verification Lead",
    "AGENT_C": "Learning Lead",
    "AGENT_D": "Implementation Lead",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_roster(coord_dir: Path) -> dict[str, Any]:
    path = Path(coord_dir) / DEFAULT_ROSTER_NAME
    if not path.exists():
        return {"agents": {}, "owner_paste": OWNER_PASTE}
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError, TypeError):
        return {"agents": {}, "owner_paste": OWNER_PASTE}
    if not isinstance(data, dict):
        return {"agents": {}, "owner_paste": OWNER_PASTE}
    if not isinstance(data.get("agents"), dict):
        data["agents"] = {}
    return data


def roster_entry(coord_dir: Path, agent_id: str) -> dict[str, Any]:
    agent_id = safe_agent_id(agent_id)
    roster = load_roster(coord_dir)
    entry = roster.get("agents", {}).get(agent_id) or {}
    if not isinstance(entry, dict):
        entry = {}
    return {
        "agent_id": agent_id,
        "role": entry.get("role") or ROLES.get(agent_id, ""),
        "chat_id": entry.get("chat_id") or "",
        "chat_title": entry.get("chat_title") or agent_id,
        "worktree": entry.get("worktree") or "",
        "owner_paste": roster.get("owner_paste") or OWNER_PASTE,
    }


def _is_canonical_coord(coord_dir: Path) -> bool:
    try:
        canon = resolve_coordination_dir(Path(__file__).resolve().parent)
        return Path(coord_dir).resolve() == Path(canon).resolve()
    except OSError:
        return False


def cue_paths(coord_dir: Path, agent_id: str) -> list[Path]:
    agent_id = safe_agent_id(agent_id)
    paths = [
        Path(coord_dir) / "mailbox" / agent_id / WAKE_NAME,
        Path(coord_dir) / "mailbox" / agent_id / SHUTDOWN_NAME,
    ]
    entry = roster_entry(coord_dir, agent_id)
    extra_roots = []
    if entry.get("worktree"):
        extra_roots.append(Path(entry["worktree"]))
    # Live worktrees only when operating on the package coordination root.
    if _is_canonical_coord(coord_dir):
        for root in WORKTREE_ROOTS:
            extra_roots.append(root / agent_id)
    seen: set[str] = set()
    out: list[Path] = []
    for p in paths:
        key = str(p).lower()
        if key not in seen:
            seen.add(key)
            out.append(p)
    for root in extra_roots:
        if not root:
            continue
        for p in (root / WAKE_NAME, root / "_COORDINATION" / WAKE_NAME):
            key = str(p).lower()
            if key in seen:
                continue
            seen.add(key)
            out.append(p)
    return out


def wake_text_paths(coord_dir: Path, agent_id: str) -> list[Path]:
    return [p for p in cue_paths(coord_dir, agent_id) if p.name == WAKE_NAME]


def pending_action_for_agent(coord_dir: Path, agent_id: str) -> list[dict[str, Any]]:
    agent_id = safe_agent_id(agent_id)
    store = PatchStore(coord_dir)
    out: list[dict[str, Any]] = []
    try:
        recs = store.active_action_patches()
    except Exception:
        return out
    for rec in recs:
        if agent_id not in (rec.get("TARGET_AGENTS") or []):
            continue
        state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id, "NOT_SEEN")
        if state in DONE_STATES:
            continue
        out.append(
            {
                "PATCH_ID": rec.get("PATCH_ID"),
                "PRIORITY": rec.get("PRIORITY"),
                "STATE": state,
            }
        )
    return out


def inbox_summary(coord_dir: Path, agent_id: str) -> dict[str, Any]:
    agent_id = safe_agent_id(agent_id)
    mb = Mailbox(str(coord_dir), agent_id)
    messages = mb.check_inbox()
    pending = pending_action_for_agent(coord_dir, agent_id)
    high = 0
    for item in messages:
        msg = item.get("message") if isinstance(item, dict) else {}
        if not isinstance(msg, dict):
            continue
        if str(msg.get("priority") or "").upper() in {"HIGH", "CRITICAL"}:
            high += 1
    return {
        "agent_id": agent_id,
        "unread": len(messages),
        "high_or_critical": high,
        "pending_patches": pending,
        "pending_count": len(pending),
        "messages": messages,
    }


def _write_text(path: Path, body: str) -> bool:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8", newline="\n")
        return True
    except OSError:
        return False


def _unlink(path: Path) -> None:
    try:
        if path.exists():
            path.unlink()
    except OSError:
        pass


def render_wake(
    coord_dir: Path,
    agent_id: str,
    *,
    unread: int,
    pending: list[dict[str, Any]],
    reason: str,
) -> str:
    info = roster_entry(coord_dir, agent_id)
    lines = [
        "WAKE_REQUIRED",
        f"agent={agent_id}",
        f"reason={reason}",
        f"unread={unread}",
        f"pending={len(pending)}",
        f"chat_id={info.get('chat_id')}",
        f"chat_title={info.get('chat_title')}",
        f"owner_paste={info.get('owner_paste') or OWNER_PASTE}",
        f"updated={utc_now()}",
        "",
        "Mailbox cannot resume a stopped chat.",
        "If this agent is stopped, owner opens the roster chat and pastes:",
        f"  {info.get('owner_paste') or OWNER_PASTE}",
        "",
        "Agent MUST run before claiming idle/done:",
        f"  python _COORDINATION/mailbox_cycle.py {agent_id} start",
        f"  python _COORDINATION/mailbox.py {agent_id} check",
        f"  python _COORDINATION/changebot.py --pending {agent_id}",
        f"  python _COORDINATION/mailbox_cycle.py {agent_id} stop",
        "",
    ]
    if pending:
        lines.append("Open ACTION/CRITICAL patches:")
        for row in pending[:8]:
            lines.append(
                f"  [{row.get('PRIORITY')}] {row.get('PATCH_ID')} state={row.get('STATE')}"
            )
        lines.append("")
    return "\n".join(lines)


def write_wake(
    coord_dir: Path,
    agent_id: str,
    *,
    unread: int,
    pending: list[dict[str, Any]],
    reason: str,
) -> list[str]:
    body = render_wake(
        coord_dir, agent_id, unread=unread, pending=pending, reason=reason
    )
    written: list[str] = []
    for path in wake_text_paths(coord_dir, agent_id):
        if _write_text(path, body):
            written.append(str(path))
    return written


def clear_wake(coord_dir: Path, agent_id: str) -> None:
    for path in wake_text_paths(coord_dir, agent_id):
        _unlink(path)


def wake_exists(coord_dir: Path, agent_id: str) -> bool:
    for path in wake_text_paths(coord_dir, agent_id):
        if path.exists():
            return True
    return False


def write_shutdown_snapshot(coord_dir: Path, agent_id: str, snapshot: dict[str, Any]) -> None:
    path = Path(coord_dir) / "mailbox" / safe_agent_id(agent_id) / SHUTDOWN_NAME
    try:
        atomic_write_json(path, snapshot)
    except OSError:
        pass
    info = roster_entry(coord_dir, agent_id)
    wt = info.get("worktree")
    if wt:
        try:
            atomic_write_json(Path(wt) / SHUTDOWN_NAME, snapshot)
        except OSError:
            pass


def mark_registry_idle(coord_dir: Path, agent_id: str, snapshot: dict[str, Any]) -> None:
    registry_path = Path(coord_dir) / "registry.json"
    if not registry_path.exists():
        return
    try:
        with open(registry_path, "r", encoding="utf-8") as f:
            text = f.read()
        data, _ = json.JSONDecoder().raw_decode(text.lstrip())
    except (OSError, json.JSONDecodeError, TypeError, ValueError):
        return
    if not isinstance(data, dict):
        return
    agents = data.setdefault("agents", {})
    if not isinstance(agents, dict):
        return
    agent_id = safe_agent_id(agent_id)
    existing = agents.get(agent_id)
    if not isinstance(existing, dict):
        existing = {}
    existing["status"] = "idle"
    existing["last_seen"] = utc_now()
    existing["stopped_at"] = snapshot.get("at")
    existing["mbox_stop"] = {
        "unread": snapshot.get("unread"),
        "pending_count": snapshot.get("pending_count"),
        "clean": snapshot.get("clean"),
    }
    agents[agent_id] = existing
    data["last_updated"] = utc_now()
    try:
        atomic_write_json(registry_path, data)
    except OSError:
        pass


def show_wake_banner(coord_dir: Path, agent_id: str) -> bool:
    for path in wake_text_paths(coord_dir, agent_id):
        if not path.exists():
            continue
        try:
            text = path.read_text(encoding="utf-8").strip()
        except OSError:
            continue
        if not text:
            continue
        safe_print("\n*** WAKE_REQUIRED — treat as first work, do not skip ***")
        for line in text.splitlines()[:24]:
            safe_print(f"  {line}")
        safe_print("*** end WAKE_REQUIRED ***\n")
        return True
    return False


def print_owner_wake_card(coord_dir: Path, agent_id: str, summary: dict[str, Any]) -> None:
    info = roster_entry(coord_dir, agent_id)
    paste = info.get("owner_paste") or OWNER_PASTE
    safe_print("=" * 60)
    safe_print(f"  OWNER WAKE  {agent_id}")
    safe_print("=" * 60)
    safe_print(f"  OPEN CHAT : {info.get('chat_title')}")
    safe_print(f"  CHAT ID   : {info.get('chat_id')}")
    safe_print(f"  PASTE     : {paste}")
    safe_print(f"  unread    : {summary.get('unread')}")
    safe_print(f"  pending   : {summary.get('pending_count')}")
    safe_print("  Mailbox cannot open this chat. Paste the line above.")
    safe_print("=" * 60)


def stop_cycle(coord_dir: Path, agent_id: str) -> int:
    """Mandatory end-of-session mailbox check. Exit 2 if work remains."""
    agent_id = safe_agent_id(agent_id)
    summary = inbox_summary(coord_dir, agent_id)
    clean = summary["unread"] == 0 and summary["pending_count"] == 0
    snapshot = {
        "agent_id": agent_id,
        "at": utc_now(),
        "unread": summary["unread"],
        "high_or_critical": summary["high_or_critical"],
        "pending_count": summary["pending_count"],
        "pending_patches": summary["pending_patches"],
        "clean": clean,
        "phase": "stop",
    }
    write_shutdown_snapshot(coord_dir, agent_id, snapshot)
    mark_registry_idle(coord_dir, agent_id, snapshot)
    safe_print(f"[{agent_id}] MBOX_STOP_CHECK unread={summary['unread']} pending={summary['pending_count']}")
    if summary["unread"]:
        for item in summary["messages"][:12]:
            msg = item.get("message") or {}
            safe_print(
                f"  [{msg.get('priority', '?')}] {msg.get('sender')} | {msg.get('subject')}"
            )
        safe_print("  NOTE: stop-check does NOT mark read.")
    if summary["pending_patches"]:
        for row in summary["pending_patches"]:
            safe_print(
                f"  PATCH {row.get('PATCH_ID')} state={row.get('STATE')} pri={row.get('PRIORITY')}"
            )
    if clean:
        clear_wake(coord_dir, agent_id)
        safe_print(f"[{agent_id}] STOP_CLEAN inbox empty, no open ACTION patches.")
        return 0
    written = write_wake(
        coord_dir,
        agent_id,
        unread=summary["unread"],
        pending=summary["pending_patches"],
        reason="SHUTDOWN_UNREAD",
    )
    safe_print(f"[{agent_id}] STOP_DIRTY wrote WAKE_REQUIRED ({len(written)} path(s)).")
    safe_print(f"[{agent_id}] Do not claim session done. Drain, ACK, then stop-check again.")
    return 2


def start_cycle(coord_dir: Path, agent_id: str) -> int:
    """Resume/check path used by CHECK MAILBOX. Exit 2 if work remains."""
    agent_id = safe_agent_id(agent_id)
    show_wake_banner(coord_dir, agent_id)
    summary = inbox_summary(coord_dir, agent_id)
    safe_print(
        f"[{agent_id}] MBOX_START_CHECK unread={summary['unread']} "
        f"pending={summary['pending_count']}"
    )
    if summary["unread"]:
        for item in summary["messages"][:12]:
            msg = item.get("message") or {}
            safe_print(
                f"  [{msg.get('priority', '?')}] {msg.get('sender')} | {msg.get('subject')}"
            )
        safe_print(
            f"NOTE: check does NOT mark read. After processing:\n"
            f"  python mailbox.py {agent_id} mark-read-all"
        )
    if summary["pending_patches"]:
        for row in summary["pending_patches"]:
            safe_print(
                f"  ACK: python mailbox.py {agent_id} ack-patch "
                f"{row.get('PATCH_ID')} APPLIED"
            )
    if summary["unread"] == 0 and summary["pending_count"] == 0:
        clear_wake(coord_dir, agent_id)
        safe_print(f"[{agent_id}] START_CLEAN")
        return 0
    write_wake(
        coord_dir,
        agent_id,
        unread=summary["unread"],
        pending=summary["pending_patches"],
        reason="START_UNREAD",
    )
    return 2


def owner_wake(coord_dir: Path, agent_id: str, *, send_mail: bool = False) -> dict[str, Any]:
    """Write WAKE cue + print owner card. Does not open the Cursor chat."""
    agent_id = safe_agent_id(agent_id)
    summary = inbox_summary(coord_dir, agent_id)
    written = write_wake(
        coord_dir,
        agent_id,
        unread=summary["unread"],
        pending=summary["pending_patches"],
        reason="OWNER_WAKE",
    )
    print_owner_wake_card(coord_dir, agent_id, summary)
    mail_path = ""
    if send_mail:
        mb = Mailbox(str(coord_dir), "CHANGEBOT")
        info = roster_entry(coord_dir, agent_id)
        mail_path = mb.send(
            agent_id,
            "OWNER_WAKE CHECK MAILBOX",
            (
                f"OWNER_WAKE {utc_now()}\n"
                f"Run: python _COORDINATION/mailbox_cycle.py {agent_id} start\n"
                f"Then stop-check before ending the session.\n"
                f"chat_id={info.get('chat_id')}\n"
            ),
            priority="HIGH",
        )
        safe_print(f"  mail {mail_path}")
    return {
        "agent_id": agent_id,
        "unread": summary["unread"],
        "pending_count": summary["pending_count"],
        "wake_paths": written,
        "mail": mail_path,
        "chat_id": roster_entry(coord_dir, agent_id).get("chat_id"),
        "owner_paste": OWNER_PASTE,
    }
