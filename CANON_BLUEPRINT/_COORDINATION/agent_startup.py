"""
Native AI CANON_BLUEPRINT — Agent Startup Script

Run this at the beginning of every agent session to:
1. Register in the agent registry
2. Check inbox for pending messages
3. Check resource locks for conflicts
4. Print document ownership summary
5. Show recent changelog entries

Usage:
    python agent_startup.py --agent-id AGENT_A --role "Architecture Lead"

No external dependencies — stdlib only.
"""

import json
import sys
import argparse
from datetime import datetime, timezone
from pathlib import Path

from coord_util import (
    atomic_write_json,
    configure_stdio,
    resolve_coordination_dir,
    safe_agent_id,
    safe_print,
)
from mailbox import Mailbox, auto_apply_planned_restart
from patch_store import PatchStore
from resource_lock import ResourceLock

configure_stdio()

# Worktree copies must follow coordination_root.json → package root.
COORDINATION_DIR = resolve_coordination_dir(Path(__file__).parent)
REGISTRY_PATH = COORDINATION_DIR / "registry.json"
SCHEMA_LOCK_PATH = COORDINATION_DIR / "schema_lock.json"
CHANGELOG_PATH = COORDINATION_DIR / "changelog.md"


def load_registry() -> dict:
    if REGISTRY_PATH.exists():
        try:
            with open(REGISTRY_PATH, "r", encoding="utf-8") as f:
                text = f.read()
            data, _ = json.JSONDecoder().raw_decode(text.lstrip())
            if isinstance(data, dict):
                if not isinstance(data.get("agents"), dict):
                    data["agents"] = {}
                return data
        except (json.JSONDecodeError, OSError, TypeError, ValueError):
            pass
    return {"agents": {}, "last_updated": None}


def save_registry(registry: dict) -> None:
    registry["last_updated"] = datetime.now(timezone.utc).isoformat()
    atomic_write_json(REGISTRY_PATH, registry)


def register_agent(agent_id: str, role: str) -> None:
    """Register agent in the registry without wiping live task/lock state."""
    agent_id = safe_agent_id(agent_id)
    registry = load_registry()
    existing = registry["agents"].get(agent_id)
    if not isinstance(existing, dict):
        existing = {}
    now = datetime.now(timezone.utc).isoformat()
    held = existing.get("resources_held")
    if not isinstance(held, list):
        held = []
    registry["agents"][agent_id] = {
        "role": role,
        "status": "active",
        "current_task": existing.get("current_task"),
        "resources_held": held,
        "registered_at": existing.get("registered_at") or now,
        "last_seen": now,
    }
    save_registry(registry)
    safe_print(f"OK Registered as {agent_id} ({role})")


def check_inbox(agent_id: str) -> None:
    """Check for unread messages. Surface PATCH/CRITICAL first."""
    mb = Mailbox(str(COORDINATION_DIR), agent_id)
    messages = mb.check_inbox()
    count = len(messages)

    if count == 0:
        safe_print("OK Inbox: empty")
        return

    def _rank(m):
        msg = m.get("message") if isinstance(m, dict) else {}
        if not isinstance(msg, dict):
            return (9, "")
        subj = str(msg.get("subject") or "")
        pri = str(msg.get("priority") or "NORMAL")
        if subj.startswith("PATCH "):
            return (0, subj)
        pri_order = {"CRITICAL": 1, "HIGH": 2, "NORMAL": 3, "LOW": 4}
        return (pri_order.get(pri, 5), subj)

    messages = sorted(messages, key=_rank)
    patches = [m for m in messages if str((m.get("message") or {}).get("subject") or "").startswith("PATCH ")]
    safe_print(f"WARN Inbox: {count} unread ({len(patches)} PATCH):")
    for m in messages[:20]:
        msg = m.get("message") if isinstance(m, dict) else {}
        if not isinstance(msg, dict):
            continue
        safe_print(
            f"  [{msg.get('priority', '?')}] From: {msg.get('sender')} — {msg.get('subject')}"
        )
        body_preview = str(msg.get("body", ""))[:80]
        if body_preview:
            safe_print(f"    {body_preview}")
    if len(messages) > 20:
        safe_print(f"  ... +{len(messages) - 20} more")
    if patches:
        _emit_received_for_unseen_patches(agent_id, mb, patches)
        safe_print(
            "\nACK hint: python mailbox.py "
            f"{agent_id} ack-patch <PATCH_ID> APPLIED"
        )
    # Always: PLANNED_RESTART operational apply once session has started.
    _auto_apply_planned_restart(agent_id, mb)


def _emit_received_for_unseen_patches(agent_id: str, mb: Mailbox, patches: list) -> None:
    """When startup displays a PATCH, ACK RECEIVED if still NOT_SEEN/OFFLINE.

    Does not claim APPLIED — only that the agent session has seen the mail.
    """
    store = PatchStore(COORDINATION_DIR)
    for m in patches:
        msg = m.get("message") if isinstance(m, dict) else {}
        if not isinstance(msg, dict):
            continue
        subject = str(msg.get("subject") or "")
        if not subject.startswith("PATCH "):
            continue
        patch_id = subject[6:].strip()
        rec = store.load(patch_id)
        if not rec or rec.get("STATUS") != "ACTIVE":
            continue
        state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id, "NOT_SEEN")
        if state not in {"NOT_SEEN", "OFFLINE"}:
            continue
        try:
            path = mb.send_patch_ack(patch_id, "RECEIVED", "seen at agent_startup")
            safe_print(f"  ACK RECEIVED -> CHANGEBOT for {patch_id} ({path})")
        except (OSError, ValueError) as e:
            safe_print(f"  WARN could not ACK RECEIVED for {patch_id}: {e}")


def _auto_apply_planned_restart(agent_id: str, mb: Mailbox) -> None:
    """APPLIED for PLANNED_RESTART patches once the agent session has started."""
    auto_apply_planned_restart(COORDINATION_DIR, agent_id, mb)


def check_locks() -> None:
    """Check resource lock status."""
    rl = ResourceLock(str(COORDINATION_DIR))
    status = rl.status()

    safe_print("\nResource Locks:")
    has_conflict = False
    for resource, info in status.items():
        holders = info.get("holders") or []
        lock_type = info.get("lock_type", "?")
        if holders:
            holder_str = ", ".join(str(h.get("agent_id", "?")) for h in holders if isinstance(h, dict))
            safe_print(f"  [{lock_type}] {resource}: HELD by {holder_str}")
            has_conflict = True
        else:
            safe_print(f"  [{lock_type}] {resource}: available")

    stale = rl.check_stale()
    if stale:
        safe_print("\n  WARN Stale locks (past expected release time):")
        for resource, holder in stale:
            safe_print(
                f"    {resource} held by {holder.get('agent_id')} since {holder.get('timestamp')}"
            )

    if not has_conflict:
        safe_print("  OK All resources available")


def show_ownership(agent_id: str) -> None:
    """Show document ownership for this agent."""
    if not SCHEMA_LOCK_PATH.exists():
        safe_print("\nWARN schema_lock.json not found — cannot show ownership")
        return

    try:
        with open(SCHEMA_LOCK_PATH, "r", encoding="utf-8") as f:
            schema = json.load(f)
    except (json.JSONDecodeError, OSError, TypeError) as e:
        safe_print(f"\nWARN schema_lock.json unreadable: {e}")
        return

    if not isinstance(schema, dict):
        safe_print("\nWARN schema_lock.json is not an object")
        return

    docs = schema.get("documents", {})
    if not isinstance(docs, dict):
        safe_print("\nWARN schema_lock.json documents is not an object")
        return

    owned = []
    readonly = []

    for doc_name, info in sorted(docs.items()):
        if not isinstance(info, dict):
            readonly.append((doc_name, "?"))
            continue
        if info.get("owner") == agent_id:
            owned.append(doc_name)
        else:
            readonly.append((doc_name, info.get("owner", "?")))

    safe_print(f"\nDocument Ownership for {agent_id}:")
    safe_print(f"  OWNED (read-write): {len(owned)} documents")
    for d in owned:
        safe_print(f"    RW  {d}")

    safe_print(f"  READ-ONLY: {len(readonly)} documents")
    for d, owner in readonly:
        safe_print(f"    RO  {d} (owner: {owner})")


def show_pending_patches(agent_id: str) -> None:
    """Surface open ACTION/CRITICAL patches from the shared patch store."""
    try:
        from changebot import ChangeBot
    except ImportError:
        return
    try:
        bot = ChangeBot(str(COORDINATION_DIR.parent), str(COORDINATION_DIR))
        bot.refresh_agent_presence()
        rows = bot.pending_for_agent(agent_id)
    except Exception as e:
        safe_print(f"\nWARN pending-patch check failed: {e}")
        return
    if not rows:
        safe_print("\nOK Pending ACTION/CRITICAL patches: none")
        return
    safe_print(f"\nWARN Pending ACTION/CRITICAL patches: {len(rows)}")
    for r in rows[:12]:
        safe_print(f"  [{r['PRIORITY']}] {r['PATCH_ID']} state={r['STATE']}")
        safe_print(f"    {r['SUMMARY']}")
        safe_print(
            f"    ACK: python mailbox.py {agent_id} ack-patch {r['PATCH_ID']} APPLIED"
        )
    if len(rows) > 12:
        safe_print(f"  ... +{len(rows) - 12} more")


def show_changelog(lines: int = 10) -> None:
    """Show recent changelog entries."""
    if not CHANGELOG_PATH.exists():
        safe_print("\nChangelog: no entries yet")
        return

    try:
        with open(CHANGELOG_PATH, "r", encoding="utf-8") as f:
            all_lines = [l.rstrip() for l in f.readlines() if l.strip().startswith("-")]
    except OSError as e:
        safe_print(f"\nChangelog unreadable: {e}")
        return

    recent = all_lines[-lines:] if all_lines else []

    safe_print(f"\nRecent Changes ({len(recent)} of {len(all_lines)}):")
    if recent:
        for line in recent:
            safe_print(f"  {line}")
    else:
        safe_print("  (none)")


def show_other_agents(agent_id: str) -> None:
    """Show other registered agents."""
    registry = load_registry()
    others = {
        k: v for k, v in registry.get("agents", {}).items()
        if k != agent_id and isinstance(v, dict)
    }

    if others:
        safe_print("\nOther Registered Agents:")
        for aid, info in others.items():
            status = info.get("status", "unknown")
            role = info.get("role", "unknown")
            last_seen = info.get("last_seen", "?")
            safe_print(f"  {aid} ({role}) — {status} — last seen {last_seen}")
    else:
        safe_print("\nNo other agents registered yet")


def show_priority_apply_gate(agent_id: str) -> None:
    """Surface R1 (and similar) RECEIVED→APPLIED gates before other inbox noise."""
    store = PatchStore(COORDINATION_DIR)
    gates = []
    for rec in store.active_action_patches():
        if agent_id not in (rec.get("TARGET_AGENTS") or []):
            continue
        state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id, "NOT_SEEN")
        if state != "RECEIVED":
            continue
        if rec.get("REQUIRED_STATE") != "APPLIED":
            continue
        gates.append(rec)
    if not gates:
        return
    # R1 first, then oldest.
    gates.sort(
        key=lambda r: (
            0 if r.get("PATCH_ID") == "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1" else 1,
            str(r.get("CREATED_AT") or ""),
        )
    )
    safe_print("\n*** APPLY GATE (RECEIVED → APPLIED required) ***")
    for rec in gates[:5]:
        pid = rec["PATCH_ID"]
        safe_print(f"  [{rec.get('PRIORITY')}] {pid}")
        safe_print(f"    {(rec.get('SUMMARY') or '')[:140]}")
        safe_print(
            f"    RUN: python mailbox.py {agent_id} ack-patch {pid} APPLIED"
        )
    safe_print("*** end APPLY GATE ***\n")


def apply_r1_planned_restart(agent_id: str) -> bool:
    """Explicit opt-in: mark R1 PLANNED_RESTART classification APPLIED for this agent."""
    patch_id = "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1"
    store = PatchStore(COORDINATION_DIR)
    rec = store.load(patch_id)
    if not rec or rec.get("STATUS") != "ACTIVE":
        safe_print(f"WARN {patch_id} not active — nothing to apply")
        return False
    state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id)
    if state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
        safe_print(f"OK {patch_id} already {state} for {agent_id}")
        return True
    mb = Mailbox(str(COORDINATION_DIR), agent_id)
    note = (
        "operational model updated: classification=PLANNED_RESTART, "
        "old_process_status=INTENTIONAL_TERMINATION, replacement_status=HEALTHY"
    )
    path = mb.send_patch_ack(patch_id, "APPLIED", note)
    updated = store.set_agent_state(patch_id, agent_id, "APPLIED", note)
    safe_print(f"OK APPLIED {patch_id} for {agent_id} ({path})")
    if updated:
        safe_print(f"   store states={updated.get('CURRENT_AGENT_STATES')}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Native AI Agent Startup")
    parser.add_argument("--agent-id", required=True, help="Agent identifier (e.g., AGENT_A)")
    parser.add_argument("--role", required=True, help="Agent role description")
    parser.add_argument(
        "--apply-r1",
        action="store_true",
        help="Explicitly ACK CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 as APPLIED",
    )
    args = parser.parse_args()

    try:
        agent_id = safe_agent_id(args.agent_id)
    except ValueError as e:
        safe_print(f"Error: {e}")
        sys.exit(1)
    role = args.role

    safe_print("=" * 60)
    safe_print("  NATIVE AI — Agent Startup")
    safe_print(f"  {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    safe_print(f"  Coordination root: {COORDINATION_DIR}")
    safe_print("=" * 60)
    safe_print()

    register_agent(agent_id, role)
    try:
        from mbox_lifecycle import show_wake_banner

        show_wake_banner(COORDINATION_DIR, agent_id)
    except Exception:
        pass
    # Soft unread banner (from ChangeBot cue) — natural breakpoint only.
    hint = Path(__file__).resolve().parent.parent / "INBOX_HINT.txt"
    if not hint.exists():
        hint = COORDINATION_DIR / "mailbox" / agent_id / "INBOX_HINT.txt"
    if hint.exists():
        try:
            text = hint.read_text(encoding="utf-8").strip()
            if text and "inbox clear" not in text.lower():
                safe_print("\n*** INBOX HINT (non-urgent — finish current task first) ***")
                for line in text.splitlines()[:16]:
                    safe_print(f"  {line}")
                safe_print("*** end INBOX HINT ***\n")
        except OSError:
            pass
    if args.apply_r1:
        apply_r1_planned_restart(agent_id)
    show_priority_apply_gate(agent_id)
    check_inbox(agent_id)
    show_pending_patches(agent_id)
    check_locks()
    show_ownership(agent_id)
    show_changelog()
    show_other_agents(agent_id)

    safe_print()
    safe_print("=" * 60)
    safe_print("  Startup complete. Begin work on your owned documents.")
    safe_print("  Shared mailbox: _COORDINATION/mailbox (junction to package).")
    safe_print("  Pending patches: python _COORDINATION/changebot.py --pending " + agent_id)
    store = PatchStore(COORDINATION_DIR)
    r1 = store.load("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
    r1_state = (r1.get("CURRENT_AGENT_STATES") or {}).get(agent_id) if r1 else None
    if r1_state and r1_state not in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
        safe_print(
            "  R1 APPLY: python agent_startup.py "
            f"--agent-id {agent_id} --role \"{role}\" --apply-r1"
        )
        safe_print(
            "  OR: python mailbox.py "
            f"{agent_id} ack-patch CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED"
        )
    safe_print("=" * 60)


if __name__ == "__main__":
    configure_stdio()
    main()
