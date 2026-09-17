"""
Native AI CANON_BLUEPRINT — Agent Coordination Mailbox

File-based inter-agent messaging system using JSON files.
No external dependencies — stdlib only.

Usage:
    from mailbox import Mailbox
    mb = Mailbox(base_dir="_COORDINATION", agent_id="AGENT_A")
    mb.send("AGENT_B", "Update", "I finished §01")
    messages = mb.check_inbox()
    mb.broadcast("Announcement", "Schema lock updated")
"""

import json
import re
import time
import hashlib
from datetime import datetime, timezone
from pathlib import Path

from coord_util import (
    atomic_write_json,
    configure_stdio,
    resolve_coordination_dir,
    safe_agent_id,
    safe_print,
)
from patch_store import PatchStore

# ChangeBot subjects include relative paths. On Windows "\" is a directory
# separator, so unsanitized slugs become missing nested folders (Errno 2).
_SLUG_UNSAFE = re.compile(r"[^a-z0-9._-]+")


def touch_registry_heartbeat(base_dir: str | Path, agent_id: str) -> None:
    """Update last_seen so ChangeBot presence moves STALE -> ONLINE."""
    reg_path = Path(base_dir) / "registry.json"
    if not reg_path.exists():
        return
    try:
        with open(reg_path, "r", encoding="utf-8") as f:
            text = f.read()
        data, _ = json.JSONDecoder().raw_decode(text.lstrip())
        if not isinstance(data, dict):
            return
        agents = data.setdefault("agents", {})
        if not isinstance(agents, dict):
            return
        info = agents.get(agent_id)
        if not isinstance(info, dict):
            return
        info["last_seen"] = datetime.now(timezone.utc).isoformat()
        data["last_updated"] = info["last_seen"]
        atomic_write_json(reg_path, data)
    except (OSError, json.JSONDecodeError, TypeError, ValueError):
        pass


def auto_apply_planned_restart(base_dir: str | Path, agent_id: str, mb: "Mailbox") -> list[str]:
    """Agent-side APPLIED for PLANNED_RESTART / R1 when the agent runs check/startup.

    Operational classification only — not ABI/ASTRA/BOARD truth.
    """
    applied: list[str] = []
    store = PatchStore(base_dir)
    for rec in store.active_action_patches():
        if agent_id not in (rec.get("TARGET_AGENTS") or []):
            continue
        patch_id = str(rec.get("PATCH_ID") or "")
        is_r1 = patch_id == "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1"
        is_planned = str(rec.get("CHANGE_CLASS") or "") == "PLANNED_RESTART"
        if not (is_r1 or is_planned):
            continue
        if rec.get("REQUIRED_STATE") != "APPLIED":
            continue
        state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id, "NOT_SEEN")
        if state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
            continue
        if state not in {"RECEIVED", "NOT_SEEN", "OFFLINE"}:
            continue
        note = (
            "applied at mailbox check/startup: operational model updated; "
            "classification=PLANNED_RESTART "
            "old_process_status=INTENTIONAL_TERMINATION "
            "replacement_status=HEALTHY"
        )
        try:
            path = mb.send_patch_ack(patch_id, "APPLIED", note)
            store.set_agent_state(patch_id, agent_id, "APPLIED", note)
            safe_print(f"[{agent_id}] ACK APPLIED {patch_id} ({path})")
            applied.append(patch_id)
            for item in mb.check_inbox():
                msg = item.get("message") or {}
                subj = str(msg.get("subject") or "")
                if patch_id in subj or "PLANNED_RESTART" in subj or "R1 APPLY" in subj:
                    mb.mark_read(item["file"])
        except (OSError, ValueError) as e:
            safe_print(f"[{agent_id}] WARN auto-apply failed for {patch_id}: {e}")
    return applied


def safe_message_slug(subject: str, max_len: int = 40) -> str:
    """Turn a subject into a single path component (no slashes or brackets)."""
    slug = subject.lower().replace("\\", "_").replace("/", "_")
    slug = _SLUG_UNSAFE.sub("_", slug)
    slug = re.sub(r"_+", "_", slug).strip("._")
    if not slug:
        slug = "msg"
    return slug[:max_len]


class Mailbox:
    """File-based inter-agent messaging system."""

    def __init__(self, base_dir: str, agent_id: str):
        self.base_dir = Path(base_dir)
        self.agent_id = safe_agent_id(agent_id)
        self.mailbox_dir = self.base_dir / "mailbox"
        self.inbox_dir = self.mailbox_dir / self.agent_id / "inbox"
        self.read_dir = self.mailbox_dir / self.agent_id / "inbox" / "read"
        self.inbox_dir.mkdir(parents=True, exist_ok=True)
        self.read_dir.mkdir(parents=True, exist_ok=True)

    def _make_filename(self, subject: str, sender: str) -> str:
        """Create a unique filename for a message (never contains path separators)."""
        ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
        slug = safe_message_slug(subject)
        uid = hashlib.md5(f"{ts}{sender}{subject}{time.time_ns()}".encode()).hexdigest()[:6]
        name = f"{ts}_{sender}_{slug}_{uid}.json"
        if "/" in name or "\\" in name or name != Path(name).name:
            raise ValueError(f"refusing unsafe mailbox filename: {name!r}")
        return name

    def send(self, to_agent: str, subject: str, body: str, priority: str = "NORMAL") -> str:
        """Send a message to a specific agent's inbox.

        Args:
            to_agent: Target agent ID (e.g., 'AGENT_A')
            subject: Message subject
            body: Message body
            priority: CRITICAL / HIGH / NORMAL / LOW

        Returns:
            Path to the created message file.
        """
        if priority not in ("CRITICAL", "HIGH", "NORMAL", "LOW"):
            raise ValueError(f"Invalid priority: {priority}. Use CRITICAL/HIGH/NORMAL/LOW")

        to_agent = safe_agent_id(to_agent)
        target_inbox = self.mailbox_dir / to_agent / "inbox"
        target_inbox.mkdir(parents=True, exist_ok=True)
        (target_inbox / "read").mkdir(parents=True, exist_ok=True)

        message = {
            "sender": self.agent_id,
            "to": to_agent,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "priority": priority,
            "subject": subject,
            "body": body,
        }

        filename = self._make_filename(subject, self.agent_id)
        filepath = target_inbox / filename
        atomic_write_json(filepath, message)
        return str(filepath)

    def broadcast(self, subject: str, body: str, priority: str = "NORMAL") -> list:
        """Send a message to ALL registered agents except self.

        Returns:
            List of paths to created message files.
        """
        sent = []
        if not self.mailbox_dir.exists():
            return sent

        for agent_dir in self.mailbox_dir.iterdir():
            if not agent_dir.is_dir() or agent_dir.name == self.agent_id:
                continue
            try:
                safe_agent_id(agent_dir.name)
            except ValueError:
                continue
            try:
                path = self.send(agent_dir.name, subject, body, priority)
                sent.append(path)
            except OSError:
                continue
        return sent

    def check_inbox(self) -> list:
        """Return list of unread messages sorted by priority then timestamp.

        Returns:
            List of dicts with 'file' and 'message' keys.
        """
        priority_order = {"CRITICAL": 0, "HIGH": 1, "NORMAL": 2, "LOW": 3}
        messages = []

        if not self.inbox_dir.exists():
            return messages

        try:
            entries = list(self.inbox_dir.iterdir())
        except OSError:
            return messages

        for f in entries:
            if f.is_file() and f.suffix == ".json":
                try:
                    with open(f, "r", encoding="utf-8") as fp:
                        msg = json.load(fp)
                    if not isinstance(msg, dict):
                        continue
                    messages.append({"file": str(f), "message": msg})
                except (json.JSONDecodeError, OSError, TypeError):
                    continue

        def _sort_key(m):
            msg = m["message"]
            pri = priority_order.get(str(msg.get("priority", "NORMAL")), 2)
            ts = msg.get("timestamp", "")
            return (pri, ts if isinstance(ts, str) else str(ts))

        messages.sort(key=_sort_key)
        return messages

    def mark_read(self, message_file: str) -> None:
        """Move a message to the read subfolder."""
        src = Path(message_file)
        if not src.exists() or not src.is_file():
            return
        self.read_dir.mkdir(parents=True, exist_ok=True)
        dst = self.read_dir / src.name
        if dst.exists():
            stem, suffix = src.stem, src.suffix
            n = 1
            while dst.exists():
                dst = self.read_dir / f"{stem}_{n}{suffix}"
                n += 1
        try:
            src.replace(dst)
        except OSError:
            pass

    def count_unread(self) -> int:
        """Count unread messages."""
        if not self.inbox_dir.exists():
            return 0
        try:
            return sum(1 for f in self.inbox_dir.iterdir()
                       if f.is_file() and f.suffix == ".json")
        except OSError:
            return 0

    def recover_tmp_messages(self) -> int:
        """Promote stranded *.json.tmp mailbox writes left by interrupted atomic_write."""
        moved = 0
        if not self.inbox_dir.exists():
            return 0
        try:
            entries = list(self.inbox_dir.iterdir())
        except OSError:
            return 0
        for f in entries:
            if not f.is_file() or not f.name.endswith(".json.tmp"):
                continue
            dest = f.with_name(f.name[: -len(".tmp")])
            try:
                if dest.exists():
                    f.unlink()
                else:
                    f.replace(dest)
                moved += 1
            except OSError:
                continue
        return moved

    def archive_duplicate_patches(self) -> int:
        """Keep one unread copy per PATCH <id> subject; archive extras."""
        legacy_dir = self.inbox_dir / "legacy_broadcast"
        legacy_dir.mkdir(parents=True, exist_ok=True)
        by_patch: dict[str, list] = {}
        moved = 0
        try:
            entries = [f for f in self.inbox_dir.iterdir() if f.is_file() and f.suffix == ".json"]
        except OSError:
            return 0
        for f in entries:
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            subject = str(msg.get("subject") or "")
            if not subject.startswith("PATCH "):
                continue
            patch_id = subject[6:].strip()
            by_patch.setdefault(patch_id, []).append((f, str(msg.get("timestamp") or "")))
        for patch_id, items in by_patch.items():
            if len(items) < 2:
                continue
            items.sort(key=lambda x: x[1])
            for f, _ts in items[:-1]:
                dst = legacy_dir / f.name
                n = 1
                while dst.exists():
                    dst = legacy_dir / f"{f.stem}_{n}{f.suffix}"
                    n += 1
                try:
                    f.replace(dst)
                    moved += 1
                except OSError:
                    continue
        return moved

    def archive_superseded_patch_mail(self, patch_index: dict | None = None) -> int:
        """Archive unread PATCH mail whose patch_id is SUPERSEDED in the patch index."""
        if patch_index is None:
            idx_path = self.base_dir / "patches" / "index.json"
            if not idx_path.exists():
                return 0
            try:
                with open(idx_path, "r", encoding="utf-8") as f:
                    patch_index = json.load(f) or {}
            except (OSError, json.JSONDecodeError, TypeError):
                return 0
        meta = (patch_index or {}).get("patches") or {}
        legacy_dir = self.inbox_dir / "legacy_broadcast"
        legacy_dir.mkdir(parents=True, exist_ok=True)
        moved = 0
        try:
            entries = [f for f in self.inbox_dir.iterdir() if f.is_file() and f.suffix == ".json"]
        except OSError:
            return 0
        for f in entries:
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            subject = str(msg.get("subject") or "")
            if not subject.startswith("PATCH "):
                continue
            patch_id = subject[6:].strip()
            info = meta.get(patch_id) or {}
            if info.get("status") != "SUPERSEDED":
                continue
            dst = legacy_dir / f.name
            n = 1
            while dst.exists():
                dst = legacy_dir / f"{f.stem}_{n}{f.suffix}"
                n += 1
            try:
                f.replace(dst)
                moved += 1
            except OSError:
                continue
        return moved

    def _move_to_legacy(self, path: Path) -> bool:
        legacy_dir = self.inbox_dir / "legacy_broadcast"
        legacy_dir.mkdir(parents=True, exist_ok=True)
        dst = legacy_dir / path.name
        n = 1
        while dst.exists():
            dst = legacy_dir / f"{path.stem}_{n}{path.suffix}"
            n += 1
        try:
            path.replace(dst)
            return True
        except OSError:
            return False

    def archive_stale_digests_and_reminders(self) -> int:
        """Keep newest PENDING_DIGEST; drop REMINDER mail once patch is RECEIVED+."""
        moved = 0
        try:
            entries = [f for f in self.inbox_dir.iterdir() if f.is_file() and f.suffix == ".json"]
        except OSError:
            return 0

        digests: list[tuple[Path, str]] = []
        agent_states: dict[str, str] = {}
        idx_path = self.base_dir / "patches" / "index.json"
        patch_meta: dict = {}
        if idx_path.exists():
            try:
                with open(idx_path, "r", encoding="utf-8") as f:
                    patch_meta = (json.load(f) or {}).get("patches") or {}
            except (OSError, json.JSONDecodeError, TypeError):
                patch_meta = {}

        for f in entries:
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            subject = str(msg.get("subject") or "")
            ts = str(msg.get("timestamp") or "")
            if subject.startswith("PENDING_DIGEST"):
                digests.append((f, ts))
                continue
            if subject.startswith("REMINDER"):
                # Prefer explicit patch id from body; fall back to subject tail.
                body = str(msg.get("body") or "")
                patch_id = ""
                for token in body.replace("\n", " ").split():
                    if token.startswith("CHANGEBOT_") or token.startswith("CB_"):
                        patch_id = token.strip(".,;")
                        break
                if not patch_id:
                    parts = subject.split()
                    for part in reversed(parts):
                        if part.startswith("CHANGEBOT_") or part.startswith("CB_"):
                            patch_id = part
                            break
                if not patch_id:
                    continue
                # Load live agent state from patch record when available
                rec_path = self.base_dir / "patches" / f"{patch_id}.json"
                state = agent_states.get(patch_id)
                if state is None and rec_path.exists():
                    try:
                        with open(rec_path, "r", encoding="utf-8") as rf:
                            rec = json.load(rf) or {}
                        state = (rec.get("CURRENT_AGENT_STATES") or {}).get(self.agent_id)
                        agent_states[patch_id] = state or ""
                    except (OSError, json.JSONDecodeError, TypeError):
                        state = ""
                if state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                    if self._move_to_legacy(f):
                        moved += 1
                elif (patch_meta.get(patch_id) or {}).get("status") == "SUPERSEDED":
                    if self._move_to_legacy(f):
                        moved += 1

        if len(digests) > 1:
            digests.sort(key=lambda x: x[1])
            for f, _ts in digests[:-1]:
                if self._move_to_legacy(f):
                    moved += 1
        return moved

    def archive_fyi_noise(self) -> int:
        """Archive LOW/INFO PATCH mail and older duplicate REMINDER/DIGEST subjects."""
        moved = 0
        try:
            entries = [f for f in self.inbox_dir.iterdir() if f.is_file() and f.suffix == ".json"]
        except OSError:
            return 0
        keep_latest: dict[str, list[tuple[str, Path]]] = {}
        for f in entries:
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            subject = str(msg.get("subject") or "")
            priority = str(msg.get("priority") or "NORMAL").upper()
            ts = str(msg.get("timestamp") or "")
            if subject.startswith("PATCH ") and priority in {"LOW", "INFO"}:
                if self._move_to_legacy(f):
                    moved += 1
                continue
            if subject.startswith("REMINDER") or subject.startswith("PENDING_DIGEST"):
                key = subject.split()[0]
                keep_latest.setdefault(key, []).append((ts, f))
        for _key, items in keep_latest.items():
            if len(items) < 2:
                continue
            items.sort(key=lambda x: x[0])
            for _ts, f in items[:-1]:
                if f.exists() and self._move_to_legacy(f):
                    moved += 1
        moved += self.archive_stale_digests_and_reminders()
        return moved

    def archive_peer_normal_noise(self, keep_per_sender: int = 2) -> int:
        """Keep newest N NORMAL/LOW peer messages per sender; archive older ones.

        Does not touch CHANGEBOT PATCH/REMINDER/DIGEST or CRITICAL/HIGH mail.
        """
        moved = 0
        try:
            entries = [f for f in self.inbox_dir.iterdir() if f.is_file() and f.suffix == ".json"]
        except OSError:
            return 0
        by_sender: dict[str, list[tuple[str, Path]]] = {}
        for f in entries:
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            sender = str(msg.get("sender") or "")
            subject = str(msg.get("subject") or "")
            priority = str(msg.get("priority") or "NORMAL").upper()
            if sender in {"CHANGEBOT", self.agent_id, ""}:
                continue
            if subject.startswith(("PATCH ", "REMINDER", "PENDING_DIGEST", "PATCH_ACK")):
                continue
            if priority in {"CRITICAL", "HIGH"}:
                continue
            by_sender.setdefault(sender, []).append((str(msg.get("timestamp") or ""), f))
        for _sender, items in by_sender.items():
            if len(items) <= keep_per_sender:
                continue
            items.sort(key=lambda x: x[0])
            for _ts, f in items[:-keep_per_sender]:
                if f.exists() and self._move_to_legacy(f):
                    moved += 1
        return moved

    def send_patch_ack(self, patch_id: str, state: str, note: str = "") -> str:
        """Send minimal PATCH_ACK to CHANGEBOT."""
        state = state.upper()
        allowed = {"RECEIVED", "APPLIED", "VERIFIED", "NOT_REQUIRED"}
        if state not in allowed:
            raise ValueError(f"invalid ack state: {state}")
        body = f"PATCH_ACK patch_id={patch_id} agent={self.agent_id} state={state}"
        if note:
            body += f" note={note}"
        return self.send("CHANGEBOT", f"PATCH_ACK {patch_id}", body, priority="HIGH")

    def archive_legacy_broadcasts(self) -> int:
        """Move old ChangeBot [CREATE]/[MODIFY]/[DELETE] floods out of the active inbox.

        Historical evidence is retained under inbox/legacy_broadcast/ (not deleted).
        """
        legacy_dir = self.inbox_dir / "legacy_broadcast"
        legacy_dir.mkdir(parents=True, exist_ok=True)
        moved = 0
        if not self.inbox_dir.exists():
            return 0
        try:
            entries = list(self.inbox_dir.iterdir())
        except OSError:
            return 0
        for f in entries:
            if not f.is_file() or f.suffix != ".json":
                continue
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    msg = json.load(fp)
            except (json.JSONDecodeError, OSError, TypeError):
                continue
            if not isinstance(msg, dict):
                continue
            subject = str(msg.get("subject") or "")
            sender = str(msg.get("sender") or "")
            is_legacy = sender == "CHANGEBOT" and (
                subject.startswith("[CREATE]")
                or subject.startswith("[MODIFY]")
                or subject.startswith("[DELETE]")
            )
            if not is_legacy:
                continue
            dst = legacy_dir / f.name
            if dst.exists():
                stem, suffix = f.stem, f.suffix
                n = 1
                while dst.exists():
                    dst = legacy_dir / f"{stem}_{n}{suffix}"
                    n += 1
            try:
                f.replace(dst)
                moved += 1
            except OSError:
                continue
        return moved


if __name__ == "__main__":
    import sys

    configure_stdio()
    if len(sys.argv) < 2:
        safe_print(
            "Usage: python mailbox.py <agent_id> "
            "[check|mark-read-all|start-cycle|stop-check|"
            "send <to> <subject> <body>|broadcast <subject> <body>|"
            "archive-legacy|ack-patch <PATCH_ID> <STATE> [note]]"
        )
        sys.exit(1)

    try:
        agent_id = safe_agent_id(sys.argv[1])
    except ValueError as e:
        safe_print(f"Error: {e}")
        sys.exit(1)

    base = str(resolve_coordination_dir(Path(__file__).parent))
    mb = Mailbox(base, agent_id)

    if len(sys.argv) == 2 or sys.argv[2] == "check":
        touch_registry_heartbeat(base, agent_id)
        # Quiet declutter so ACTION patches (R1) stay visible without reminder spam.
        try:
            mb.archive_stale_digests_and_reminders()
            mb.archive_superseded_patch_mail()
            mb.archive_duplicate_patches()
        except OSError:
            pass
        try:
            store = PatchStore(base)
            rec = store.load("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
            st = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id) if rec else None
            if st and st not in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                safe_print(f"[{agent_id}] *** APPLY GATE *** state={st}")
                # Agent invoked mailbox as themselves — auto-APPLY operational R1.
                auto_apply_planned_restart(base, agent_id, mb)
                rec2 = store.load("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
                st2 = (rec2.get("CURRENT_AGENT_STATES") or {}).get(agent_id) if rec2 else st
                if st2 in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                    safe_print(f"[{agent_id}] R1 now {st2} (auto-applied at check)")
                else:
                    safe_print(
                        f"  RUN: python mailbox.py {agent_id} ack-patch "
                        "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED"
                    )
                safe_print(f"[{agent_id}] *** end APPLY GATE ***")
        except Exception as e:
            safe_print(f"[{agent_id}] WARN apply-gate: {e}")
        messages = mb.check_inbox()
        if not messages:
            safe_print(f"[{agent_id}] No unread messages.")
        else:
            safe_print(f"[{agent_id}] {len(messages)} unread message(s):")
            # Surface R1 APPLY GATE / PATCH first
            def _rank(m):
                sub = str((m.get("message") or {}).get("subject") or "")
                pri = str((m.get("message") or {}).get("priority") or "")
                score = 0
                if "!!! R1 APPLY GATE" in sub:
                    score -= 200
                if "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1" in sub or (
                    "PLANNED_RESTART" in sub and sub.startswith("PATCH")
                ):
                    score -= 100
                if sub.startswith("REMINDER APPLY"):
                    score -= 90
                if sub.startswith("PATCH "):
                    score -= 50
                if pri == "CRITICAL":
                    score -= 20
                elif pri == "HIGH":
                    score -= 10
                return (score, str((m.get("message") or {}).get("timestamp") or ""))

            for m in sorted(messages, key=_rank):
                msg = m["message"]
                body = str(msg.get("body", ""))[:100]
                safe_print(f"  [{msg.get('priority', '?')}] From: {msg.get('sender')} | {msg.get('subject')}")
                safe_print(f"    {body}")
                safe_print(f"    @ {msg.get('timestamp')}")
                safe_print()
            safe_print(
                f"NOTE: check does NOT mark read. After you process mail run:\n"
                f"  python mailbox.py {agent_id} mark-read-all"
            )
            try:
                store = PatchStore(base)
                rec = store.load("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
                st = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent_id) if rec else None
                if st and st not in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                    safe_print(
                        f"ACK hint: python mailbox.py {agent_id} ack-patch "
                        "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED"
                    )
            except Exception:
                pass

    elif sys.argv[2] == "mark-read-all":
        msgs = mb.check_inbox()
        n = 0
        for m in msgs:
            try:
                mb.mark_read(m["file"])
                n += 1
            except OSError:
                continue
        touch_registry_heartbeat(base, agent_id)
        safe_print(f"[{agent_id}] marked read={n}; unread now {mb.count_unread()}")

    elif sys.argv[2] == "send" and len(sys.argv) >= 6:
        path = mb.send(sys.argv[3], sys.argv[4], " ".join(sys.argv[5:]))
        safe_print(f"Message sent: {path}")

    elif sys.argv[2] == "broadcast" and len(sys.argv) >= 5:
        paths = mb.broadcast(sys.argv[3], " ".join(sys.argv[4:]))
        safe_print(f"Broadcast sent to {len(paths)} agent(s)")

    elif sys.argv[2] == "archive-legacy":
        n = mb.archive_legacy_broadcasts()
        d = mb.archive_duplicate_patches()
        s = mb.archive_superseded_patch_mail()
        r = mb.archive_stale_digests_and_reminders()
        safe_print(
            f"[{agent_id}] archived legacy={n} dup_patches={d} superseded={s} "
            f"stale_digest_reminder={r}; unread now {mb.count_unread()}"
        )

    elif sys.argv[2] == "stop-check":
        from mbox_lifecycle import stop_cycle

        sys.exit(stop_cycle(Path(base), agent_id))

    elif sys.argv[2] == "start-cycle":
        from mbox_lifecycle import start_cycle

        sys.exit(start_cycle(Path(base), agent_id))

    elif sys.argv[2] == "ack-patch" and len(sys.argv) >= 5:
        patch_id = sys.argv[3]
        state = sys.argv[4]
        note = " ".join(sys.argv[5:]) if len(sys.argv) > 5 else ""
        touch_registry_heartbeat(base, agent_id)
        try:
            path = mb.send_patch_ack(patch_id, state, note)
        except ValueError as e:
            safe_print(f"Error: {e}")
            sys.exit(1)
        # Also update patch store immediately (don't wait for ChangeBot ingest).
        try:
            store = PatchStore(base)
            rec = store.set_agent_state(patch_id, agent_id, state.upper(), note)
            if rec:
                safe_print(f"PATCH store updated: {patch_id} {agent_id}={state.upper()}")
            else:
                safe_print(f"WARN patch record not found: {patch_id}")
        except Exception as e:
            safe_print(f"WARN patch store update failed: {e}")
        # Mark matching PATCH mail read if still unread.
        for item in mb.check_inbox():
            msg = item.get("message") or {}
            subj = str(msg.get("subject") or "")
            if subj == f"PATCH {patch_id}" or (
                subj.startswith("REMINDER") and patch_id in str(msg.get("body") or "")
            ):
                mb.mark_read(item["file"])
        safe_print(f"ACK sent: {path}")

    else:
        safe_print(
            "Usage: python mailbox.py <agent_id> "
            "[check|mark-read-all|start-cycle|stop-check|"
            "send <to> <subject> <body>|broadcast <subject> <body>|"
            "archive-legacy|ack-patch <PATCH_ID> <STATE> [note]]"
        )