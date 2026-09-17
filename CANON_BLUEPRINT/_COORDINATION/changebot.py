"""
Native AI CANON_BLUEPRINT — ChangeBot coordination daemon

Lightweight async patch-delivery control plane.
Does NOT decide semantic truth / ABI / ASTRA / BOARD_PASS.

Usage:
    python changebot.py --watch
    python changebot.py --scan
    python changebot.py --status
    python changebot.py --coverage <PATCH_ID>
    python changebot.py --ingest-acks
    python changebot.py --bootstrap-planned-restart
    python changebot.py --changelog [N]
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from coord_util import (
    atomic_write_json,
    configure_stdio,
    is_dot_dir,
    safe_agent_id,
    safe_print,
)
from mailbox import Mailbox
from patch_store import PatchStore, sha256_file, utc_now

configure_stdio()

ACK_RE = re.compile(
    r"PATCH_ACK\s+"
    r"patch_id=(?P<patch_id>\S+)\s+"
    r"agent=(?P<agent>\S+)\s+"
    r"state=(?P<state>RECEIVED|APPLIED|VERIFIED|NOT_REQUIRED)"
    r"(?:\s+note=(?P<note>.+))?",
    re.IGNORECASE | re.DOTALL,
)

STALE_SECONDS = 15 * 60
COALESCE_WINDOW_SEC = 30
COALESCE_WINDOW_VERIFICATION_SEC = 180
COALESCE_WINDOW_AUTHORITY_SEC = 120
# Hard cap from first item in a batch — prevents endless deadline extension under thrash.
COALESCE_MAX_HOLD_SEC = 240
# Soft unread hints: cue files only (no mailbox spam). Min rewrite interval.
SOFT_PING_MIN_INTERVAL_SEC = 15 * 60

WORKTREE_ROOTS = [
    Path(r"d:\FPGA\NATIVE_AI\worktrees"),
]

# Path prefixes / names → default priority + lane relevance
CRITICAL_NAMES = {
    "03_ASTRA_AUTHORITY.md",
    "04_ABI_AND_PROTOCOL.md",
    "31_VERIFICATION_AND_CAUSAL_TESTS.md",
}
CRITICAL_HINTS = ("xdc", "cdc", "reset", "clock", "bitstream", "signoff")


class ChangeBot:
    """Filesystem watcher + selective patch router."""

    IGNORE_DIRS = {
        "_ARCHIVE",
        "_COORDINATION",
        ".git",
        "__pycache__",
        ".vivado",
        ".Xil",
        ".cache",
        "xsim.dir",
        "sim_1",
        "synth_1",
        "impl_1",
        "CANON_BLUEPRINT_R0_1_AUDITED_CANDIDATE",
        "out",
        # Tooling trees thrash create/delete and must not flood agent mailboxes.
        "NATIVE_AI_AGENT_GUARD_R1",
        "NATIVE_AI_MULTI_AGENT_MANAGER_R2",
        "NATIVE_AI_MULTI_AGENT_MANAGER_R1",
    }
    IGNORE_EXTENSIONS = {
        ".pyc", ".lock", ".tmp", ".swp",
        ".jou", ".log", ".pb", ".wdb", ".bak", ".str",
        ".vvp", ".vcd", ".saif", ".sdb", ".wcfg",
    }
    POLL_INTERVAL = 5

    def __init__(self, watch_dir: str, coordination_dir: str):
        self.watch_dir = Path(watch_dir)
        self.coord_dir = Path(coordination_dir)
        self.changelog_path = self.coord_dir / "changelog.md"
        self.state_path = self.coord_dir / ".changebot_state.json"
        self.health_path = self.coord_dir / "changebot_health.json"
        self.restart_marker_path = self.coord_dir / ".changebot_restart_marker.json"
        self.schema_lock_path = self.coord_dir / "schema_lock.json"
        self.registry_path = self.coord_dir / "registry.json"
        self.running = True
        self.mailbox = Mailbox(str(self.coord_dir), "CHANGEBOT")
        self.patches = PatchStore(self.coord_dir)
        self._pending_batch: list[dict] = []
        self._batch_deadline: float | None = None
        self._batch_opened_at: float | None = None
        self.pending_batch_path = self.coord_dir / "changebot_pending_batch.json"
        self.soft_ping_path = self.coord_dir / "changebot_soft_ping.json"
        self.daemon_generation = 1
        self.start_time = utc_now()
        self.last_scan = None
        self.restart_reason = "cold_start"
        self.old_process_status = None
        self.replacement_status = "HEALTHY"
        self._daemon_mode = False

        try:
            signal.signal(signal.SIGINT, self._shutdown)
            if hasattr(signal, "SIGTERM"):
                signal.signal(signal.SIGTERM, self._shutdown)
        except (ValueError, OSError):
            pass

        # CLI tools must not mutate daemon generation / restart classification.
        self._hydrate_health_readonly()

    def _hydrate_health_readonly(self) -> None:
        if not self.health_path.exists():
            return
        try:
            with open(self.health_path, "r", encoding="utf-8") as f:
                prev = json.load(f) or {}
        except (OSError, json.JSONDecodeError, TypeError):
            return
        self.daemon_generation = int(prev.get("daemon_generation") or 1)
        self.restart_reason = prev.get("restart_reason") or "cold_start"
        self.old_process_status = prev.get("old_process_status")
        self.replacement_status = prev.get("replacement_status") or "HEALTHY"
        self.last_scan = prev.get("last_scan")
        if prev.get("start_time"):
            self.start_time = prev["start_time"]

    def _load_or_init_health(self) -> None:
        prev = {}
        if self.health_path.exists():
            try:
                with open(self.health_path, "r", encoding="utf-8") as f:
                    prev = json.load(f) or {}
            except (OSError, json.JSONDecodeError, TypeError):
                prev = {}

        marker = {}
        if self.restart_marker_path.exists():
            try:
                with open(self.restart_marker_path, "r", encoding="utf-8") as f:
                    marker = json.load(f) or {}
            except (OSError, json.JSONDecodeError, TypeError):
                marker = {}

        prev_gen = int(prev.get("daemon_generation") or 0)
        intentional = bool(marker.get("intentional")) or bool(marker.get("planned_restart"))
        self.start_time = utc_now()
        if intentional:
            self.daemon_generation = prev_gen + 1 if prev_gen else 1
            self.restart_reason = "PLANNED_RESTART"
            self.old_process_status = "INTENTIONAL_TERMINATION"
            self.replacement_status = "HEALTHY"
            try:
                self.restart_marker_path.unlink(missing_ok=True)
            except OSError:
                pass
        elif prev_gen:
            self.daemon_generation = prev_gen + 1
            self.restart_reason = "UNEXPECTED_RESTART"
            self.old_process_status = "UNPLANNED_TERMINATION"
            self.replacement_status = "HEALTHY"
        else:
            self.daemon_generation = 1
            self.restart_reason = "cold_start"
            self.old_process_status = None
            self.replacement_status = "HEALTHY"

        self._persist_health()

    def _shutdown(self, signum, frame):
        safe_print("\n[ChangeBot] Shutting down gracefully...")
        try:
            self._flush_batch()
        except Exception:
            self._persist_pending_batch()
        self.running = False
        self._write_restart_marker(reason="signal_shutdown", intentional=True)

    def _persist_pending_batch(self) -> None:
        """Survive PLANNED_RESTART kills mid-coalesce window."""
        try:
            if not self._pending_batch:
                if self.pending_batch_path.exists():
                    self.pending_batch_path.unlink(missing_ok=True)
                return
            payload = {
                "deadline_epoch": self._batch_deadline,
                "opened_at_epoch": self._batch_opened_at,
                "items": [
                    {
                        "path": it.get("path"),
                        "type": it.get("type"),
                        "details": it.get("details") or "",
                        "old_sha256": it.get("old_sha256"),
                        "new_sha256": it.get("new_sha256"),
                        "route": it.get("route"),
                    }
                    for it in self._pending_batch
                    if isinstance(it.get("route"), dict)
                ],
                "saved_at": utc_now(),
            }
            atomic_write_json(self.pending_batch_path, payload)
        except OSError:
            pass

    def _restore_pending_batch(self) -> int:
        if not self.pending_batch_path.exists():
            return 0
        try:
            with open(self.pending_batch_path, "r", encoding="utf-8") as f:
                data = json.load(f) or {}
        except (OSError, json.JSONDecodeError, TypeError):
            return 0
        items = data.get("items") or []
        if not isinstance(items, list) or not items:
            try:
                self.pending_batch_path.unlink(missing_ok=True)
            except OSError:
                pass
            return 0
        restored = []
        for it in items:
            if not isinstance(it, dict) or not isinstance(it.get("route"), dict):
                continue
            restored.append(it)
        if not restored:
            return 0
        self._pending_batch = restored
        deadline = data.get("deadline_epoch")
        opened = data.get("opened_at_epoch")
        now = time.time()
        if isinstance(opened, (int, float)):
            self._batch_opened_at = float(opened)
        else:
            self._batch_opened_at = now - COALESCE_MAX_HOLD_SEC
        if isinstance(deadline, (int, float)) and deadline > now:
            # Still respect hard hold cap from opened_at
            hard = self._batch_opened_at + COALESCE_MAX_HOLD_SEC
            self._batch_deadline = min(float(deadline), hard)
        else:
            # Overdue batch from prior daemon — flush ASAP on next maybe_flush
            self._batch_deadline = now
        safe_print(f"[ChangeBot] Restored {len(restored)} coalesced change(s) from prior daemon")
        return len(restored)

    def _write_restart_marker(self, reason: str, intentional: bool = True) -> None:
        try:
            atomic_write_json(self.restart_marker_path, {
                "intentional": intentional,
                "planned_restart": intentional,
                "reason": reason,
                "old_pid": os.getpid(),
                "old_generation": self.daemon_generation,
                "at": utc_now(),
                "note": "exit_code 1 during intentional kill/restart is PLANNED_RESTART",
            })
        except OSError:
            pass

    def _persist_health(self) -> None:
        try:
            atomic_write_json(self.health_path, {
                "daemon_generation": self.daemon_generation,
                "pid": os.getpid(),
                "start_time": self.start_time,
                "health": "healthy",
                "last_scan": self.last_scan,
                "restart_reason": self.restart_reason,
                "old_process_status": self.old_process_status,
                "replacement_status": self.replacement_status,
                "classification": (
                    "PLANNED_RESTART"
                    if self.restart_reason == "PLANNED_RESTART"
                    else "RUNTIME_OK"
                ),
            })
        except OSError as e:
            safe_print(f"[ChangeBot] Warning: health write failed: {e}")

    def _should_watch_name(self, name: str) -> bool:
        if name in self.IGNORE_DIRS or is_dot_dir(name):
            return False
        return True

    def _should_watch(self, path: Path) -> bool:
        try:
            parts = path.relative_to(self.watch_dir).parts
        except ValueError:
            return False
        for part in parts:
            if not self._should_watch_name(part):
                return False
        if path.suffix.lower() in self.IGNORE_EXTENSIONS:
            return False
        return True

    def _scan_files(self) -> dict:
        state = {}
        if not self.watch_dir.exists():
            return state
        try:
            walker = os.walk(self.watch_dir, followlinks=False)
        except OSError:
            return state
        for dirpath, dirnames, filenames in walker:
            dirnames[:] = [d for d in dirnames if self._should_watch_name(d)]
            for name in filenames:
                path = Path(dirpath) / name
                if not self._should_watch(path):
                    continue
                try:
                    if not path.is_file():
                        continue
                    digest = sha256_file(path)
                    if digest is None:
                        continue
                    rel = str(path.relative_to(self.watch_dir)).replace("\\", "/")
                    state[rel] = {
                        "sha256": digest,
                        "size": path.stat().st_size,
                    }
                except (OSError, PermissionError, ValueError):
                    continue
        return state

    def _load_state(self) -> dict:
        if self.state_path.exists():
            try:
                with open(self.state_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    # Normalize legacy Windows path keys so upgrades do not
                    # look like mass CREATE/DELETE.
                    return {
                        str(k).replace("\\", "/"): v
                        for k, v in data.items()
                        if isinstance(k, str)
                    }
            except (json.JSONDecodeError, OSError, TypeError):
                pass
        return {}

    def _save_state(self, state: dict) -> None:
        try:
            atomic_write_json(self.state_path, state)
        except OSError as e:
            safe_print(f"[ChangeBot] Warning: could not save state: {e}")

    def _load_schema_lock(self) -> dict:
        if not self.schema_lock_path.exists():
            return {}
        try:
            with open(self.schema_lock_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            return data if isinstance(data, dict) else {}
        except (OSError, json.JSONDecodeError, TypeError):
            return {}

    def _load_registry(self) -> dict:
        if not self.registry_path.exists():
            return {}
        try:
            with open(self.registry_path, "r", encoding="utf-8") as f:
                text = f.read()
            # Tolerate accidental trailing junk after a valid JSON object.
            decoder = json.JSONDecoder()
            data, _ = decoder.raw_decode(text.lstrip())
            return data if isinstance(data, dict) else {}
        except (OSError, json.JSONDecodeError, TypeError, ValueError):
            return {}

    def agent_health_map(self) -> dict[str, str]:
        """ONLINE / OFFLINE / STALE for A/B/C/D (+ known mailbox agents)."""
        now = datetime.now(timezone.utc)
        registry = self._load_registry()
        agents = registry.get("agents") or {}
        result = {}
        for agent_id in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"):
            info = agents.get(agent_id)
            if not info:
                result[agent_id] = "OFFLINE"
                continue
            # Registered agents are never OFFLINE solely due to staleness.
            last = info.get("last_seen")
            try:
                ts = datetime.fromisoformat(str(last).replace("Z", "+00:00"))
                age = (now - ts).total_seconds()
                if age > STALE_SECONDS:
                    result[agent_id] = "STALE"
                else:
                    result[agent_id] = "ONLINE"
            except (TypeError, ValueError):
                result[agent_id] = "STALE"
        return result

    def _owner_for(self, relpath: str) -> str | None:
        name = Path(relpath).name
        docs = (self._load_schema_lock().get("documents") or {})
        meta = docs.get(name)
        if isinstance(meta, dict):
            return meta.get("owner")
        return None

    def classify_and_route(self, relpath: str, change_type: str) -> dict:
        """Return priority, targets, change_class, why."""
        norm = relpath.replace("\\", "/")
        name = Path(norm).name.lower()
        owner = self._owner_for(norm)
        lower = norm.lower()
        # Canon section docs live at blueprint root as NN_*.md — not vivado/01_*.tcl
        is_canon_doc = (
            "/" not in norm
            and name.endswith(".md")
            and (
                bool(re.match(r"^\d{2}_", name))
                or name in {"reading_order.md", "project_goal_lock.md"}
            )
        )

        targets: set[str] = set()
        priority = "INFO"
        change_class = "FILE_CHANGE"
        why_parts = []

        # Ignore generated verification outputs
        if "/out/" in f"/{lower}/" or lower.endswith("/out"):
            return {
                "priority": "INFO",
                "targets": [],
                "change_class": "GENERATED_NOISE",
                "why": "generated out/ ignored",
                "owner": owner,
            }

        # Critical authority surfaces (canon docs + real XDC/CDC/clock contracts)
        if is_canon_doc and name in {n.lower() for n in CRITICAL_NAMES}:
            priority = "CRITICAL"
            change_class = "AUTHORITY_OR_CONTRACT"
            why_parts.append("authority/contract surface")
        elif any(
            h in lower for h in ("/constraints/", ".xdc", "cdc", "/reset", "bitstream", "signoff")
        ):
            priority = "CRITICAL"
            change_class = "AUTHORITY_OR_CONTRACT"
            why_parts.append("XDC/CDC/clock/signoff surface")
            targets.add("AGENT_D")
            if "abi" in lower or "astra" in lower:
                targets.add("AGENT_B")

        # Architecture / memory / glossary — canon docs only
        if is_canon_doc and (
            name.startswith(("00_", "01_", "02_", "20_")) or name == "reading_order.md"
        ):
            targets.update({"AGENT_A"})
            why_parts.append("architecture/memory/glossary")
            if priority != "CRITICAL":
                priority = "ACTION_REQUIRED"
                change_class = "ARCHITECTURE"
            if name.startswith(("01_", "02_")):
                targets.add("AGENT_D")
                why_parts.append("implementation may be affected")

        # ABI / ASTRA / benchmark — canon docs only
        if is_canon_doc and name.startswith(("03_", "04_", "21_", "31_", "32_")):
            targets.update({"AGENT_B", "AGENT_D"})
            why_parts.append("ABI/ASTRA/benchmark")
            if priority != "CRITICAL":
                priority = "ACTION_REQUIRED"
                change_class = "ABI_VERIFICATION"
            if name.startswith(("03_", "04_")):
                targets.add("AGENT_A")
                why_parts.append("architecture contract")
            if any(x in lower for x in ("status", "learner", "qstar", "spear")):
                targets.add("AGENT_C")

        # Learning / FEM — canon docs only
        if is_canon_doc and name.startswith(("10_", "11_", "12_", "13_")):
            targets.update({"AGENT_C", "AGENT_D"})
            why_parts.append("learning/FEM")
            if priority == "INFO":
                priority = "ACTION_REQUIRED"
                change_class = "LEARNING"
            if any(x in lower for x in ("status", "verify", "astra")):
                targets.add("AGENT_B")

        # RTL / timing / resource / vivado / tb
        if any(lower.startswith(p) for p in ("rtl/", "tb/", "vivado/", "python/m1/", "verification/")):
            targets.add("AGENT_D")
            why_parts.append("RTL/implementation lane")
            if priority == "INFO":
                if (
                    lower.startswith("verification/")
                    and "/out/" not in f"/{lower}/"
                    and "abi" in lower
                ):
                    priority = "ACTION_REQUIRED"
                    change_class = "VERIFICATION_IMPL"
                    targets.add("AGENT_B")
                elif lower.startswith("verification/") and "/out/" not in f"/{lower}/":
                    priority = "ACTION_REQUIRED"
                    change_class = "VERIFICATION_IMPL"
                    targets.add("AGENT_B")
                else:
                    priority = "INFO"
                    change_class = "IMPL_LOCAL"
            if "abi" in lower and "AGENT_B" not in targets:
                targets.add("AGENT_B")
            if any(x in lower for x in ("learn", "qstar", "spear", "fem")):
                targets.add("AGENT_C")

        # Owned document → owner always relevant for ACTION+
        if owner and owner.startswith("AGENT_"):
            if priority != "INFO":
                targets.add(owner)
            elif owner == "AGENT_D" and change_type == "MODIFY":
                targets.add(owner)

        # Default: if still empty and PRIMARY doc, route to owner only
        if not targets and owner and owner.startswith("AGENT_"):
            targets.add(owner)
            why_parts.append(f"schema owner {owner}")

        if not targets:
            targets = set()
            priority = "INFO"
            change_class = "UNROUTED"
            why_parts.append("no relevant lane; changelog only")

        return {
            "priority": priority,
            "targets": sorted(targets),
            "change_class": change_class,
            "why": "; ".join(why_parts) or "material change",
            "owner": owner,
        }

    def _log_change(self, change_type: str, filepath: str, details: str = "") -> None:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
        try:
            if not self.changelog_path.exists():
                with open(self.changelog_path, "w", encoding="utf-8") as f:
                    f.write("# CANON_BLUEPRINT Changelog\n\n")
                    f.write("Automatically maintained by ChangeBot.\n\n")
                    f.write("---\n\n")
            with open(self.changelog_path, "a", encoding="utf-8") as f:
                line = f"- **[{change_type}]** `{filepath}` — {ts}"
                if details:
                    line += f" — {details}"
                f.write(line + "\n")
        except OSError as e:
            safe_print(f"[ChangeBot] Warning: changelog write failed: {e}")

    def _format_patch_body(self, record: dict, agent: str) -> str:
        files = record.get("FILES") or []
        files_s = ", ".join(files[:12])
        if len(files) > 12:
            files_s += f" (+{len(files) - 12} more)"
        return (
            f"PATCH_ID: {record['PATCH_ID']}\n"
            f"PRIORITY: {record.get('PRIORITY')}\n"
            f"SOURCE: {record.get('SOURCE_AGENT')}\n"
            f"FILES: {files_s}\n"
            f"SUMMARY: {record.get('SUMMARY')}\n"
            f"WHY_YOU_RECEIVED_THIS: {record.get('WHY')}\n"
            f"REQUIRED_ACTION: {record.get('REQUIRED_ACTION')}\n"
            f"DEPENDENCY: {record.get('DEPENDENCY') or 'none'}\n"
            f"ACK_REQUIRED: {'YES' if record.get('ACK_REQUIRED') else 'NO'}\n"
            f"REQUIRED_STATE: {record.get('REQUIRED_STATE')}\n"
            f"TARGET: {agent}\n"
            f"DETAIL_POINTERS: see FILES paths under CANON_BLUEPRINT (no embedded diff).\n"
            f"ACK_FORMAT: PATCH_ACK patch_id={record['PATCH_ID']} agent={agent} "
            f"state=RECEIVED|APPLIED|VERIFIED|NOT_REQUIRED note=<optional>\n"
        )

    def deliver_patch(
        self,
        record: dict,
        agents: list[str] | None = None,
        force: bool = False,
    ) -> list[str]:
        """Deliver once per agent that still needs it. Returns delivered agent ids."""
        patch_id = record["PATCH_ID"]
        health = self.agent_health_map()
        delivered = []
        targets = agents if agents is not None else list(record.get("TARGET_AGENTS") or [])
        priority_map = {
            "INFO": "LOW",
            "ACTION_REQUIRED": "HIGH",
            "CRITICAL": "CRITICAL",
        }
        mb_priority = priority_map.get(record.get("PRIORITY", "INFO"), "NORMAL")

        for agent in targets:
            if not force and not self.patches.needs_delivery(patch_id, agent):
                # Still refresh pointer if a live unread PATCH file exists under a new name
                live = self._find_unread_patch_file(agent, patch_id)
                if live:
                    self.patches.repair_delivery_pointer(patch_id, agent, str(live))
                continue
            state = (record.get("CURRENT_AGENT_STATES") or {}).get(agent)
            if force and state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                continue
            live = self._find_unread_patch_file(agent, patch_id)
            if live is not None:
                self.patches.repair_delivery_pointer(patch_id, agent, str(live))
                safe_print(f"  [SKIP_DUP] {patch_id} -> {agent} (unread already present)")
                continue
            existing = (record.get("DELIVERIES") or {}).get(agent) or {}
            existing_path = Path(str(existing.get("path") or ""))
            if existing_path.is_file():
                safe_print(f"  [SKIP_DUP] {patch_id} -> {agent} (unread already present)")
                continue
            # Refresh OFFLINE flag from registry absence
            if health.get(agent) == "OFFLINE":
                self.patches.set_agent_state(patch_id, agent, "OFFLINE", "pending delivery")
            try:
                safe_agent_id(agent)
            except ValueError:
                continue
            body = self._format_patch_body(record, agent)
            subject = f"PATCH {patch_id}"
            try:
                path = self.mailbox.send(agent, subject, body, priority=mb_priority)
                self.patches.mark_delivered(patch_id, agent, path)
                delivered.append(agent)
                safe_print(f"  [DELIVERED] {patch_id} -> {agent}")
            except OSError as e:
                safe_print(f"[ChangeBot] deliver failed {agent}: {e}")
        return delivered

    def _find_unread_patch_file(self, agent: str, patch_id: str) -> Path | None:
        inbox = self.coord_dir / "mailbox" / agent / "inbox"
        if not inbox.exists():
            return None
        try:
            for f in inbox.iterdir():
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
                body = str(msg.get("body") or "")
                if subject == f"PATCH {patch_id}" or f"PATCH_ID: {patch_id}" in body:
                    return f
        except OSError:
            return None
        return None

    def create_and_deliver_patch(self, **kwargs) -> dict:
        health = self.agent_health_map()
        # Map STALE to online-for-delivery (mailbox still works); OFFLINE stays OFFLINE
        agent_health = {
            a: ("OFFLINE" if health.get(a) == "OFFLINE" else "ONLINE")
            for a in kwargs.get("target_agents", [])
        }
        record = self.patches.create(agent_health=agent_health, **kwargs)
        # reload in case create returned existing
        record = self.patches.load(record["PATCH_ID"]) or record
        # INFO: changelog-only — do not flood mailboxes (no ACK required).
        if record.get("PRIORITY") == "INFO" and not record.get("ACK_REQUIRED"):
            safe_print(
                f"  [INFO/NO_MAIL] {record['PATCH_ID']} files="
                f"{len(record.get('FILES') or [])} (changelog only)"
            )
            return record
        self.deliver_patch(record)
        return self.patches.load(record["PATCH_ID"]) or record

    def detect_changes(self) -> list:
        old_state = self._load_state()
        new_state = self._scan_files()
        changes = []

        for filepath, info in new_state.items():
            prev = old_state.get(filepath)
            if not isinstance(prev, dict):
                changes.append({
                    "type": "CREATE",
                    "path": filepath,
                    "old_sha256": None,
                    "new_sha256": info.get("sha256"),
                    "details": f"size={info.get('size', 0)}",
                })
                continue
            old_hash = prev.get("sha256")
            new_hash = info.get("sha256")
            # Content-identical → NO PATCH (even if mtime touched)
            if old_hash and new_hash and old_hash == new_hash:
                continue
            # Legacy mtime/size state: first hash capture is baseline only
            if "sha256" not in prev:
                continue
            if not old_hash and new_hash:
                continue
            old_size = prev.get("size", 0) or 0
            new_size = info.get("size", 0) or 0
            try:
                diff = new_size - old_size
            except TypeError:
                diff = 0
            sign = "+" if diff >= 0 else ""
            changes.append({
                "type": "MODIFY",
                "path": filepath,
                "old_sha256": old_hash,
                "new_sha256": new_hash,
                "details": f"size {sign}{diff} bytes",
            })

        for filepath in old_state:
            if filepath not in new_state:
                prev = old_state.get(filepath) or {}
                changes.append({
                    "type": "DELETE",
                    "path": filepath,
                    "old_sha256": prev.get("sha256") if isinstance(prev, dict) else None,
                    "new_sha256": None,
                    "details": "",
                })

        self._save_state(new_state)
        self.last_scan = utc_now()
        self._persist_health()
        return changes

    def _check_authority(self, relpath: str) -> dict | None:
        """If writable_by is locked and change is observed, flag — ChangeBot does not apply."""
        owner = self._owner_for(relpath)
        docs = (self._load_schema_lock().get("documents") or {})
        name = Path(relpath).name
        meta = docs.get(name)
        if not isinstance(meta, dict):
            return None
        writable = meta.get("writable_by")
        if writable == []:
            return {
                "violation": True,
                "file": relpath,
                "owner": owner or "PROJECT_OWNER",
                "reason": "schema_lock writable_by empty (governance)",
            }
        return None

    def _flush_batch(self) -> None:
        if not self._pending_batch:
            return
        batch = list(self._pending_batch)
        self._pending_batch = []
        self._batch_deadline = None
        self._batch_opened_at = None
        try:
            if self.pending_batch_path.exists():
                self.pending_batch_path.unlink(missing_ok=True)
        except OSError:
            pass

        # Group by (priority, frozenset(targets), change_class bucket)
        groups: dict[tuple, list] = {}
        for item in batch:
            key = (
                item["route"]["priority"],
                tuple(item["route"]["targets"]),
                item["route"]["change_class"],
            )
            groups.setdefault(key, []).append(item)

        for (priority, targets, change_class), items in groups.items():
            if not targets:
                for it in items:
                    self._log_change(it["type"], it["path"], it["details"])
                continue

            files = PatchStore.normalize_files([it["path"] for it in items])
            hashes = {
                str(it["path"]).replace("\\", "/"): {
                    "old_sha256": it.get("old_sha256"),
                    "new_sha256": it.get("new_sha256"),
                }
                for it in items
            }
            # Authority check
            for it in items:
                viol = self._check_authority(it["path"])
                if viol:
                    self._emit_authority_violation(viol, it)

            summary = self._summarize_batch(files, change_class)
            fp = PatchStore.content_fingerprint(
                files, change_class, priority, list(targets)
            )
            # Lane-level coalesce: one ACTIVE CRITICAL authority / verification
            # patch at a time — file churn must not re-mail agents.
            if change_class in {"AUTHORITY_OR_CONTRACT", "VERIFICATION_IMPL"} and priority in {
                "CRITICAL",
                "ACTION_REQUIRED",
            }:
                lane_hit = None
                for rec in self.patches.all_active():
                    if rec.get("CHANGE_CLASS") != change_class:
                        continue
                    if rec.get("PRIORITY") not in {"CRITICAL", "ACTION_REQUIRED"}:
                        continue
                    lane_hit = rec
                    break
                if lane_hit:
                    for it in items:
                        self._log_change(it["type"], it["path"], it["details"])
                    safe_print(
                        f"  [LANE/SKIP] {change_class} covered by {lane_hit['PATCH_ID']}"
                    )
                    continue
            # If an ACTIVE patch already covers this fingerprint / file set, skip.
            existing = None
            file_set = set(files)
            for rec in self.patches.all_active():
                meta = rec.get("METADATA") or {}
                rec_fp = meta.get("fingerprint")
                if not rec_fp:
                    rec_fp = PatchStore.content_fingerprint(
                        list(rec.get("FILES") or []),
                        str(rec.get("CHANGE_CLASS") or ""),
                        str(rec.get("PRIORITY") or ""),
                        list(rec.get("TARGET_AGENTS") or []),
                    )
                same_files = set(PatchStore.normalize_files(list(rec.get("FILES") or []))) == file_set
                same_route = (
                    rec.get("CHANGE_CLASS") == change_class
                    and rec.get("PRIORITY") == priority
                    and sorted(rec.get("TARGET_AGENTS") or []) == sorted(targets)
                )
                if rec_fp == fp or (same_files and same_route):
                    existing = rec
                    break
            if existing:
                for it in items:
                    self._log_change(it["type"], it["path"], it["details"])
                safe_print(
                    f"  [COALESCE/SKIP] fingerprint={fp} covered by {existing['PATCH_ID']}"
                )
                continue

            ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
            patch_id = f"CB_{change_class}_{ts}_{fp[:6]}"
            ack_required = priority in {"ACTION_REQUIRED", "CRITICAL"}
            required_state = "APPLIED" if ack_required else "NOT_REQUIRED"
            why = items[0]["route"]["why"]
            action = (
                "Read FILES; apply local awareness; ACK with APPLIED when integrated."
                if ack_required
                else "FYI only; no ACK required."
            )
            for it in items:
                self._log_change(it["type"], it["path"], it["details"])

            # Supersede older actives with same class+targets overlapping files
            supersedes = []
            for rec in self.patches.all_active():
                if rec.get("CHANGE_CLASS") != change_class:
                    continue
                if sorted(rec.get("TARGET_AGENTS") or []) != sorted(targets):
                    continue
                old_files = set(PatchStore.normalize_files(list(rec.get("FILES") or [])))
                if old_files == file_set:
                    supersedes.append(rec["PATCH_ID"])

            record = self.create_and_deliver_patch(
                patch_id=patch_id,
                source_agent="CHANGEBOT",
                files=files,
                change_class=change_class,
                priority=priority,
                target_agents=list(targets),
                required_state=required_state,
                summary=summary,
                why=why,
                required_action=action,
                dependency="",
                ack_required=ack_required,
                supersedes=supersedes,
                metadata={
                    "hashes": hashes,
                    "coalesced": len(files),
                    "fingerprint": fp,
                },
            )
            # Collapse any race-created duplicate ACTIVE fingerprints.
            self.dedupe_patches()
            # INFO already logged inside create_and_deliver_patch (NO_MAIL).
            if not (priority == "INFO" and not ack_required):
                safe_print(
                    f"  [PATCH] {record['PATCH_ID']} pri={priority} "
                    f"files={len(files)} -> {','.join(targets)}"
                )

    def _summarize_batch(self, files: list[str], change_class: str) -> str:
        if len(files) == 1:
            return f"{change_class}: {files[0]}"
        names = [Path(f).name for f in files[:4]]
        extra = f" +{len(files) - 4} more" if len(files) > 4 else ""
        return f"{change_class}: {', '.join(names)}{extra}"

    def _emit_authority_violation(self, viol: dict, change: dict) -> None:
        patch_id = f"AUTHORITY_VIOLATION_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S')}"
        owner = viol.get("owner") or "PROJECT_OWNER"
        targets = []
        if isinstance(owner, str) and owner.startswith("AGENT_"):
            targets.append(owner)
        # notify OWNER mailbox if present; always keep record
        record = self.patches.create(
            patch_id=patch_id,
            source_agent="CHANGEBOT",
            files=[viol["file"]],
            change_class="AUTHORITY_VIOLATION",
            priority="CRITICAL",
            target_agents=targets or ["AGENT_A"],
            required_state="RECEIVED",
            summary=f"AUTHORITY_VIOLATION: {viol['reason']} on {viol['file']}",
            why="schema_lock ownership/governance check",
            required_action="Do not silently apply; correct owner must review.",
            ack_required=True,
            metadata={"violation": viol, "change": change},
        )
        self.deliver_patch(record)
        # OWNER report file (lightweight)
        try:
            owner_dir = self.coord_dir / "mailbox" / "OWNER" / "inbox"
            owner_dir.mkdir(parents=True, exist_ok=True)
            atomic_write_json(owner_dir / f"{patch_id}.json", {
                "sender": "CHANGEBOT",
                "to": "OWNER",
                "timestamp": utc_now(),
                "priority": "CRITICAL",
                "subject": patch_id,
                "body": record.get("SUMMARY"),
            })
        except OSError:
            pass

    def process_changes(self, changes: list) -> None:
        now = time.time()
        for ch in changes:
            route = self.classify_and_route(ch["path"], ch["type"])
            item = {**ch, "route": route}
            self._pending_batch.append(item)
        # Longer coalesce for verification/impl churn and authority-doc thrash.
        window = COALESCE_WINDOW_SEC
        paths = [
            str(it.get("path") or "").replace("\\", "/").lower()
            for it in self._pending_batch
        ]
        if paths and all(p.startswith(("verification/", "tb/", "vivado/")) for p in paths):
            window = COALESCE_WINDOW_VERIFICATION_SEC
        elif paths and any(
            Path(p).name in {n.lower() for n in CRITICAL_NAMES}
            or p.endswith(tuple(n.lower() for n in CRITICAL_NAMES))
            for p in paths
        ):
            window = COALESCE_WINDOW_AUTHORITY_SEC
        if self._batch_deadline is None:
            self._batch_opened_at = now
            self._batch_deadline = now + window
        else:
            # Extend for longer class window, but never past hard hold from open.
            opened = self._batch_opened_at if self._batch_opened_at is not None else now
            hard_cap = opened + COALESCE_MAX_HOLD_SEC
            self._batch_deadline = min(max(self._batch_deadline, now + window), hard_cap)
        self._persist_pending_batch()

    def _maybe_flush(self) -> None:
        if not self._pending_batch:
            return
        now = time.time()
        overdue = self._batch_deadline is not None and now >= self._batch_deadline
        held_too_long = (
            self._batch_opened_at is not None
            and (now - self._batch_opened_at) >= COALESCE_MAX_HOLD_SEC
        )
        if overdue or held_too_long:
            if held_too_long and not overdue:
                safe_print(
                    f"  [COALESCE/FORCE_FLUSH] held>={COALESCE_MAX_HOLD_SEC}s "
                    f"items={len(self._pending_batch)}"
                )
            self._flush_batch()
            safe_print()

    def ingest_acks(self) -> int:
        """Read CHANGEBOT inbox for PATCH_ACK messages."""
        count = 0
        messages = self.mailbox.check_inbox()
        for m in messages:
            msg = m["message"]
            body = str(msg.get("body") or "")
            subject = str(msg.get("subject") or "")
            text = body if "PATCH_ACK" in body.upper() else f"{subject}\n{body}"
            match = ACK_RE.search(text.replace("\n", " "))
            if not match:
                # also accept structured JSON field
                patch = msg.get("patch_ack")
                if isinstance(patch, dict):
                    patch_id = patch.get("patch_id")
                    agent = patch.get("agent")
                    state = patch.get("state")
                    note = patch.get("note") or ""
                else:
                    self.mailbox.mark_read(m["file"])
                    continue
            else:
                patch_id = match.group("patch_id")
                agent = match.group("agent")
                state = match.group("state").upper()
                note = (match.group("note") or "").strip()

            try:
                safe_agent_id(agent)
            except ValueError:
                self.mailbox.mark_read(m["file"])
                continue

            rec = self.patches.set_agent_state(patch_id, agent, state, note)
            if rec:
                count += 1
                safe_print(f"  [ACK] {patch_id} {agent}={state}")
            self.mailbox.mark_read(m["file"])
        return count

    def repair_delivery_index(self) -> int:
        """Rebind DELIVERIES paths by scanning agent inboxes for PATCH <id> messages."""
        fixed = 0
        mailbox_root = self.coord_dir / "mailbox"
        for rec in self.patches.all_active():
            patch_id = rec["PATCH_ID"]
            needle = f"PATCH {patch_id}".lower()
            slug = patch_id.lower().replace("_", "")[:28]
            deliveries = rec.setdefault("DELIVERIES", {})
            changed = False
            for agent in list(rec.get("TARGET_AGENTS") or []):
                inbox = mailbox_root / agent / "inbox"
                if not inbox.exists():
                    continue
                found = None
                try:
                    candidates = list(inbox.glob("*.json"))
                    read_dir = inbox / "read"
                    if read_dir.exists():
                        candidates += list(read_dir.glob("*.json"))
                except OSError:
                    continue
                for path in sorted(candidates, key=lambda p: p.stat().st_mtime, reverse=True):
                    try:
                        with open(path, "r", encoding="utf-8") as f:
                            msg = json.load(f)
                    except (OSError, json.JSONDecodeError, TypeError):
                        continue
                    if not isinstance(msg, dict):
                        continue
                    subj = str(msg.get("subject") or "").lower()
                    body = str(msg.get("body") or "").lower()
                    name = path.name.lower().replace("_", "")
                    if needle in subj or f"patch_id: {patch_id.lower()}" in body or slug in name:
                        found = path
                        break
                if found is None:
                    continue
                prev = (deliveries.get(agent) or {}).get("path")
                if prev != str(found):
                    deliveries[agent] = {"path": str(found), "at": utc_now(), "repaired": True}
                    changed = True
                    fixed += 1
            if changed:
                self.patches.save(rec)
        return fixed

    def reconcile_receipts(self) -> int:
        """Infer RECEIVED when delivery file moved to inbox/read (no full ACK yet)."""
        self.repair_delivery_index()
        updated = 0
        for rec in self.patches.all_active():
            patch_id = rec["PATCH_ID"]
            states = dict(rec.get("CURRENT_AGENT_STATES") or {})
            deliveries = rec.get("DELIVERIES") or {}
            for agent, info in deliveries.items():
                cur = states.get(agent, "NOT_SEEN")
                if cur not in {"NOT_SEEN", "OFFLINE"}:
                    continue
                path = Path(str((info or {}).get("path") or ""))
                if not path.name:
                    continue
                read_path = path.parent / "read" / path.name
                in_read = "read" in path.parts and path.exists()
                if not in_read:
                    in_read = read_path.exists()
                if not in_read and (path.parent / "read").exists():
                    try:
                        in_read = any(
                            p.name.startswith(path.stem)
                            for p in (path.parent / "read").glob("*.json")
                            if path.stem[:40] in p.stem
                        )
                    except OSError:
                        in_read = False
                if in_read:
                    self.patches.set_agent_state(
                        patch_id, agent, "RECEIVED", "inferred from inbox/read"
                    )
                    updated += 1
                    safe_print(f"  [RECEIVED] {patch_id} {agent} (read/)")
        return updated

    def refresh_agent_presence(self) -> int:
        """Clear false OFFLINE when registry shows agent present; digest on return."""
        health = self.agent_health_map()
        registry = self._load_registry()
        if not (registry.get("agents") or {}):
            safe_print("  [PRESENCE] registry empty/unreadable — skip OFFLINE sweep")
            return 0
        fixed = 0
        returned: set[str] = set()
        for rec in self.patches.all_active():
            patch_id = rec["PATCH_ID"]
            states = dict(rec.get("CURRENT_AGENT_STATES") or {})
            deliveries = rec.get("DELIVERIES") or {}
            for agent in list(rec.get("TARGET_AGENTS") or []):
                cur = states.get(agent)
                present = health.get(agent) in {"ONLINE", "STALE"}
                if cur == "OFFLINE" and present:
                    if agent in deliveries:
                        self.patches.set_agent_state(
                            patch_id, agent, "NOT_SEEN", "presence restored; await ACK"
                        )
                    else:
                        self.patches.set_agent_state(
                            patch_id, agent, "NOT_SEEN", "presence restored; delivering"
                        )
                        fresh = self.patches.load(patch_id)
                        if fresh:
                            self.deliver_patch(fresh, agents=[agent])
                    fixed += 1
                    safe_print(f"  [PRESENCE] {patch_id} {agent} OFFLINE->NOT_SEEN")
                    returned.add(agent)
                elif (
                    cur == "NOT_SEEN"
                    and health.get(agent) == "OFFLINE"
                ):
                    self.patches.set_agent_state(
                        patch_id, agent, "OFFLINE", "registry absent"
                    )
                    fixed += 1
        for agent in returned:
            self.deliver_pending_digest(agent)
        return fixed

    def retire_misrouted_patches(self) -> int:
        """Supersede ACTIVE patches that used filename-prefix false positives."""
        retired = 0
        for rec in self.patches.all_active():
            files = PatchStore.normalize_files(list(rec.get("FILES") or []))
            cls = rec.get("CHANGE_CLASS")
            if cls not in {"ARCHITECTURE", "ABI_VERIFICATION"}:
                continue
            has_non_canon = any(
                f.startswith(("vivado/", "rtl/", "tb/", "verification/", "python/"))
                for f in files
            )
            has_canon_md = any(("/" not in f and f.endswith(".md")) for f in files)
            if has_non_canon and not has_canon_md:
                rec["STATUS"] = "SUPERSEDED"
                rec["SUPERSEDED_BY"] = "ROUTER_FIX_CANON_DOC_PREFIX_R1"
                meta = rec.setdefault("METADATA", {})
                meta["retire_reason"] = "misrouted_non_canon_prefix_match"
                self.patches.save(rec)
                retired += 1
                safe_print(f"  [RETIRE] {rec['PATCH_ID']} misrouted")
        return retired

    def collapse_lane_duplicates(self) -> int:
        """Keep newest ACTIVE patch per (CHANGE_CLASS, TARGET_AGENTS).

        ACTION/CRITICAL and INFO lanes both collapse so FYI/impl churn does not
        leave dozens of ACTIVE records (and leftover inbox PATCH mail).
        Never collapses the R1 planned-restart patch.
        """
        groups: dict[tuple, list] = {}
        for rec in self.patches.all_active():
            if rec.get("PATCH_ID") == "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1":
                continue
            if rec.get("PRIORITY") not in {"ACTION_REQUIRED", "CRITICAL", "INFO"}:
                continue
            key = (
                str(rec.get("CHANGE_CLASS") or ""),
                tuple(sorted(rec.get("TARGET_AGENTS") or [])),
            )
            groups.setdefault(key, []).append(rec)
        collapsed = 0
        for key, recs in groups.items():
            if len(recs) < 2:
                continue
            recs.sort(key=lambda r: str(r.get("CREATED_AT") or ""))
            newest = recs[-1]
            for old in recs[:-1]:
                old["STATUS"] = "SUPERSEDED"
                old["SUPERSEDED_BY"] = newest["PATCH_ID"]
                meta = old.setdefault("METADATA", {})
                meta["retire_reason"] = "collapsed_lane_duplicate"
                self.patches.save(old)
                supersedes = list(newest.get("SUPERSEDES") or [])
                if old["PATCH_ID"] not in supersedes:
                    supersedes.append(old["PATCH_ID"])
                    newest["SUPERSEDES"] = supersedes
                collapsed += 1
                safe_print(f"  [COLLAPSE] {old['PATCH_ID']} -> {newest['PATCH_ID']}")
            self.patches.save(newest)
        return collapsed

    def nudge_received_apply(self, patch_id: str, min_age_sec: int = 600) -> list[str]:
        """One APPLY reminder per agent stuck in RECEIVED (no forged APPLIED)."""
        rec = self.patches.load(patch_id)
        if not rec or rec.get("STATUS") != "ACTIVE":
            return []
        nudged: list[str] = []
        now = datetime.now(timezone.utc)
        meta = rec.setdefault("METADATA", {})
        last_nudge = meta.get("apply_nudge") or {}
        if not isinstance(last_nudge, dict):
            last_nudge = {}
        for agent, state in (rec.get("CURRENT_AGENT_STATES") or {}).items():
            if state != "RECEIVED":
                continue
            prev = last_nudge.get(agent)
            if prev:
                try:
                    age = (now - datetime.fromisoformat(str(prev).replace("Z", "+00:00"))).total_seconds()
                    if age < min_age_sec:
                        continue
                except (TypeError, ValueError):
                    pass
            body = (
                f"REMINDER APPLY\n"
                f"PATCH_ID: {patch_id}\n"
                f"STATE: RECEIVED (APPLIED still required)\n"
                f"ACTION: Update local model: classification=PLANNED_RESTART, "
                f"old_process_status=INTENTIONAL_TERMINATION, replacement_status=HEALTHY.\n"
                f"ACK: python mailbox.py {agent} ack-patch {patch_id} APPLIED\n"
            )
            try:
                self.mailbox.send(
                    agent,
                    f"REMINDER APPLY {patch_id}",
                    body,
                    priority="HIGH",
                )
            except OSError as exc:
                safe_print(f"  [NUDGE_WARN] {patch_id} -> {agent}: {exc}")
                continue
            last_nudge[agent] = now.isoformat()
            nudged.append(agent)
            safe_print(f"  [NUDGE] {patch_id} APPLY reminder -> {agent}")
        meta["apply_nudge"] = last_nudge
        self.patches.save(rec)
        return nudged

    def soft_ping_unread_hints(self, min_interval_sec: int = SOFT_PING_MIN_INTERVAL_SEC) -> dict:
        """Non-disturbing unread reminder: cue files only, never new mailbox spam.

        Agents see INBOX_HINT.txt at natural breakpoints (startup / glance at worktree).
        Does not interrupt mid-task with HIGH mailbox pings.
        """
        prev: dict = {}
        if self.soft_ping_path.exists():
            try:
                with open(self.soft_ping_path, "r", encoding="utf-8") as f:
                    prev = json.load(f) or {}
            except (OSError, json.JSONDecodeError, TypeError):
                prev = {}
        last_by = prev.get("agents") if isinstance(prev.get("agents"), dict) else {}
        now = datetime.now(timezone.utc)
        now_epoch = time.time()
        presence = self.agent_health_map()
        updated: dict[str, dict] = {}

        for agent in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"):
            mb = Mailbox(str(self.coord_dir), agent)
            unread = mb.count_unread()
            pending = self.pending_for_agent(agent)
            prev_agent = last_by.get(agent) if isinstance(last_by.get(agent), dict) else {}
            last_ts = prev_agent.get("at_epoch")
            try:
                last_epoch = float(last_ts) if last_ts is not None else 0.0
            except (TypeError, ValueError):
                last_epoch = 0.0
            count_changed = int(prev_agent.get("unread") or -1) != unread
            due = (now_epoch - last_epoch) >= min_interval_sec
            if unread <= 0 and not pending:
                # Clear stale hints
                self._write_inbox_hint(agent, unread=0, pending=[], presence=presence.get(agent))
                updated[agent] = {
                    "unread": 0,
                    "pending_patches": 0,
                    "presence": presence.get(agent),
                    "at": now.isoformat(),
                    "at_epoch": now_epoch,
                    "cleared": True,
                }
                continue
            if not count_changed and not due and prev_agent.get("unread") == unread:
                updated[agent] = prev_agent
                continue
            hint = self._write_inbox_hint(
                agent,
                unread=unread,
                pending=pending,
                presence=presence.get(agent),
            )
            updated[agent] = {
                "unread": unread,
                "pending_patches": len(pending),
                "presence": presence.get(agent),
                "hint_paths": hint,
                "at": now.isoformat(),
                "at_epoch": now_epoch,
            }
            safe_print(
                f"  [SOFT_PING] {agent} unread={unread} pending_patches={len(pending)} "
                f"presence={presence.get(agent)}"
            )

        payload = {"updated_at": now.isoformat(), "agents": updated}
        try:
            atomic_write_json(self.soft_ping_path, payload)
        except OSError:
            pass
        return updated

    def _write_inbox_hint(
        self,
        agent: str,
        *,
        unread: int,
        pending: list,
        presence: str | None,
    ) -> list[str]:
        """Write/clear INBOX_HINT.txt under coord mailbox + known worktrees."""
        written: list[str] = []
        if unread <= 0 and not pending:
            body = (
                f"{agent}: inbox clear.\n"
                f"presence={presence}\n"
                f"updated={utc_now()}\n"
            )
        else:
            lines = [
                f"{agent} has unread coordination mail — check at next natural break.",
                f"unread={unread} presence={presence}",
                f"updated={utc_now()}",
                "",
                "Non-urgent: finish current task first, then:",
                f"  python _COORDINATION/mailbox.py {agent} check",
                f"  python _COORDINATION/changebot.py --pending {agent}",
                f"  python _COORDINATION/mailbox.py {agent} mark-read-all   # after processing",
                "",
            ]
            if pending:
                lines.append(f"Open ACTION/CRITICAL patches ({len(pending)}):")
                for row in pending[:8]:
                    lines.append(
                        f"  [{row.get('PRIORITY')}] {row.get('PATCH_ID')} state={row.get('STATE')}"
                    )
                lines.append("")
            body = "\n".join(lines) + "\n"
            if str(presence or "").upper() not in {"ONLINE", "ACTIVE"}:
                try:
                    from mbox_lifecycle import write_wake

                    write_wake(
                        self.coord_dir,
                        agent,
                        unread=unread,
                        pending=pending,
                        reason="STALE_UNREAD",
                    )
                except Exception:
                    pass

        targets: list[Path] = [
            self.coord_dir / "mailbox" / agent / "INBOX_HINT.txt",
        ]
        for root in WORKTREE_ROOTS:
            wt = root / agent
            if wt.is_dir():
                targets.append(wt / "INBOX_HINT.txt")
                targets.append(wt / "_COORDINATION" / "INBOX_HINT.txt")

        for path in targets:
            try:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(body, encoding="utf-8")
                written.append(str(path))
            except OSError:
                continue
        return written

    def archive_agent_inboxes(self) -> int:
        """Archive legacy/dup/superseded PATCH mail across all agent mailboxes."""
        root = self.coord_dir / "mailbox"
        if not root.exists():
            return 0
        moved = 0
        idx = None
        try:
            with open(self.coord_dir / "patches" / "index.json", "r", encoding="utf-8") as f:
                idx = json.load(f) or {}
        except (OSError, json.JSONDecodeError, TypeError):
            idx = None
        for agent_dir in root.iterdir():
            if not agent_dir.is_dir():
                continue
            try:
                safe_agent_id(agent_dir.name)
            except ValueError:
                continue
            mb = Mailbox(str(self.coord_dir), agent_dir.name)
            moved += mb.recover_tmp_messages()
            moved += mb.archive_legacy_broadcasts()
            moved += mb.archive_duplicate_patches()
            moved += mb.archive_superseded_patch_mail(idx)
            moved += mb.archive_fyi_noise()
            moved += mb.archive_peer_normal_noise()
        return moved

    def collapse_authority_lane(self) -> int:
        """Keep a single newest ACTIVE AUTHORITY_OR_CONTRACT patch (any targets)."""
        recs = [
            r for r in self.patches.all_active()
            if r.get("CHANGE_CLASS") == "AUTHORITY_OR_CONTRACT"
            and r.get("PRIORITY") == "CRITICAL"
        ]
        if len(recs) < 2:
            return 0
        recs.sort(key=lambda r: str(r.get("CREATED_AT") or ""))
        newest = recs[-1]
        collapsed = 0
        for old in recs[:-1]:
            old["STATUS"] = "SUPERSEDED"
            old["SUPERSEDED_BY"] = newest["PATCH_ID"]
            meta = old.setdefault("METADATA", {})
            meta["retire_reason"] = "collapsed_authority_lane"
            self.patches.save(old)
            supersedes = list(newest.get("SUPERSEDES") or [])
            if old["PATCH_ID"] not in supersedes:
                supersedes.append(old["PATCH_ID"])
                newest["SUPERSEDES"] = supersedes
            collapsed += 1
            safe_print(f"  [COLLAPSE/AUTH] {old['PATCH_ID']} -> {newest['PATCH_ID']}")
        self.patches.save(newest)
        return collapsed

    def collapse_architecture_lane(self) -> int:
        """Keep newest ACTIVE ARCHITECTURE ACTION patch; merge target sets."""
        recs = [
            r for r in self.patches.all_active()
            if r.get("CHANGE_CLASS") == "ARCHITECTURE"
            and r.get("PRIORITY") in {"ACTION_REQUIRED", "CRITICAL"}
        ]
        if len(recs) < 2:
            return 0
        recs.sort(key=lambda r: str(r.get("CREATED_AT") or ""))
        newest = recs[-1]
        targets = set(newest.get("TARGET_AGENTS") or [])
        collapsed = 0
        for old in recs[:-1]:
            targets.update(old.get("TARGET_AGENTS") or [])
            old["STATUS"] = "SUPERSEDED"
            old["SUPERSEDED_BY"] = newest["PATCH_ID"]
            meta = old.setdefault("METADATA", {})
            meta["retire_reason"] = "collapsed_architecture_lane"
            self.patches.save(old)
            supersedes = list(newest.get("SUPERSEDES") or [])
            if old["PATCH_ID"] not in supersedes:
                supersedes.append(old["PATCH_ID"])
                newest["SUPERSEDES"] = supersedes
            collapsed += 1
            safe_print(f"  [COLLAPSE/ARCH] {old['PATCH_ID']} -> {newest['PATCH_ID']}")
        newest["TARGET_AGENTS"] = sorted(targets)
        # Ensure states exist for merged targets
        states = newest.setdefault("CURRENT_AGENT_STATES", {})
        for agent in newest["TARGET_AGENTS"]:
            states.setdefault(agent, "NOT_SEEN")
        self.patches.save(newest)
        return collapsed

    def collapse_verification_lane(self) -> int:
        """Keep newest ACTIVE VERIFICATION_IMPL / ABI_VERIFICATION ACTION patch."""
        recs = [
            r for r in self.patches.all_active()
            if r.get("CHANGE_CLASS") in {"VERIFICATION_IMPL", "ABI_VERIFICATION"}
            and r.get("PRIORITY") in {"ACTION_REQUIRED", "CRITICAL"}
        ]
        if len(recs) < 2:
            return 0
        recs.sort(key=lambda r: str(r.get("CREATED_AT") or ""))
        newest = recs[-1]
        targets = set(newest.get("TARGET_AGENTS") or [])
        files = list(newest.get("FILES") or [])
        collapsed = 0
        for old in recs[:-1]:
            targets.update(old.get("TARGET_AGENTS") or [])
            for f in old.get("FILES") or []:
                if f not in files:
                    files.append(f)
            old["STATUS"] = "SUPERSEDED"
            old["SUPERSEDED_BY"] = newest["PATCH_ID"]
            meta = old.setdefault("METADATA", {})
            meta["retire_reason"] = "collapsed_verification_lane"
            self.patches.save(old)
            supersedes = list(newest.get("SUPERSEDES") or [])
            if old["PATCH_ID"] not in supersedes:
                supersedes.append(old["PATCH_ID"])
                newest["SUPERSEDES"] = supersedes
            collapsed += 1
            safe_print(f"  [COLLAPSE/VERIF] {old['PATCH_ID']} -> {newest['PATCH_ID']}")
        newest["TARGET_AGENTS"] = sorted(targets)
        newest["FILES"] = files
        states = newest.setdefault("CURRENT_AGENT_STATES", {})
        for agent in newest["TARGET_AGENTS"]:
            states.setdefault(agent, "NOT_SEEN")
        self.patches.save(newest)
        return collapsed

    def acquire_watch_lock(self) -> bool:
        """Ensure a single watch daemon. Returns False if another live instance holds the lock."""
        if not self.health_path.exists():
            return True
        try:
            with open(self.health_path, "r", encoding="utf-8") as f:
                prev = json.load(f) or {}
        except (OSError, json.JSONDecodeError, TypeError):
            return True
        old_pid = prev.get("pid")
        if not isinstance(old_pid, int) or old_pid <= 0 or old_pid == os.getpid():
            return True
        try:
            # Windows: OpenProcess signal via os.kill(pid, 0) is not portable; use tasklist-ish
            import ctypes
            kernel32 = ctypes.windll.kernel32  # type: ignore[attr-defined]
            PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
            handle = kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, old_pid)
            if handle:
                kernel32.CloseHandle(handle)
                safe_print(
                    f"[ChangeBot] Another watch daemon is alive (pid={old_pid}). "
                    "Refusing second instance."
                )
                return False
        except Exception:
            # If we cannot probe, allow start but prefer planned restart path.
            pass
        return True

    def dedupe_patches(self) -> int:
        pairs = self.patches.dedupe_active_by_fingerprint()
        for old_id, new_id in pairs:
            safe_print(f"  [SUPERSEDED] {old_id} -> {new_id}")
        return len(pairs)

    def pending_for_agent(self, agent: str) -> list[dict]:
        """Compact list of ACTIVE ACTION/CRITICAL patches still open for agent."""
        out = []
        for rec in self.patches.active_action_patches():
            if agent not in (rec.get("TARGET_AGENTS") or []):
                continue
            state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent, "NOT_SEEN")
            if state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                continue
            out.append({
                "PATCH_ID": rec["PATCH_ID"],
                "PRIORITY": rec.get("PRIORITY"),
                "STATE": state,
                "SUMMARY": (rec.get("SUMMARY") or "")[:120],
                "FILES": len(rec.get("FILES") or []),
                "ACK": f"PATCH_ACK patch_id={rec['PATCH_ID']} agent={agent} state=APPLIED",
            })
        return out

    def owner_coverage_report(self, patch_id: str, force: bool = False) -> str | None:
        """Return OWNER report text only when unresolved coverage warrants it."""
        cov = self.patches.coverage(patch_id)
        if not cov:
            return None
        record = self.patches.load(patch_id) or {}
        required = record.get("REQUIRED_STATE", "APPLIED")
        unresolved = []
        lines = []
        for agent in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"):
            if agent not in cov and agent not in (record.get("TARGET_AGENTS") or []):
                continue
            state = cov.get(agent, "NOT_SEEN")
            short = agent[-1]
            lines.append(f"{short}={state}")
            if state in {"NOT_SEEN", "RECEIVED", "OFFLINE"}:
                if required in {"APPLIED", "VERIFIED"} and state != "VERIFIED":
                    if state == "RECEIVED" and required == "APPLIED":
                        unresolved.append(f"{agent} RECEIVED not APPLIED")
                    elif state == "NOT_SEEN":
                        unresolved.append(f"{agent} NOT_SEEN")
                    elif state == "OFFLINE":
                        unresolved.append(f"{agent} OFFLINE PENDING")

        # Always persist machine-readable coverage for operators/agents.
        try:
            atomic_write_json(self.coord_dir / "patches" / f"coverage_{patch_id}.json", {
                "PATCH_ID": patch_id,
                "UPDATED_AT": utc_now(),
                "REQUIRED_STATE": required,
                "CURRENT_AGENT_STATES": cov,
                "UNRESOLVED": unresolved,
                "DAEMON": {
                    "generation": self.daemon_generation,
                    "restart_reason": self.restart_reason,
                    "health": "healthy",
                },
            })
        except OSError:
            pass

        # Healthy-all-applied: stay silent unless force
        if not unresolved and not force:
            return None

        issue = "; ".join(unresolved) if unresolved else "none"
        action = "NONE"
        if any("OFFLINE" in u for u in unresolved):
            action = "Wait for offline agent return; pending patches will digest."
        elif any("NOT_SEEN" in u for u in unresolved):
            action = "Ensure target agents read inbox / ACK."
        elif any("RECEIVED" in u for u in unresolved):
            action = "Nudge agents to APPLY required patch."

        daemon = "healthy"
        if self.restart_reason == "PLANNED_RESTART":
            daemon = "planned_restart"

        return (
            "CHANGEBOT STATUS\n\n"
            f"DAEMON:\n{daemon}\n\n"
            f"PATCH:\n{patch_id}\n\n"
            "COVERAGE:\n" + "\n".join(lines) + "\n\n"
            f"ISSUE:\n{issue}\n\n"
            f"ACTION:\n{action}\n"
        )

    def bootstrap_planned_restart_classification(self) -> dict:
        """CB-03/04: CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1."""
        # Ensure marker classification is recorded even on cold start of this task
        if self.restart_reason != "PLANNED_RESTART":
            self.restart_reason = "PLANNED_RESTART"
            self.old_process_status = "INTENTIONAL_TERMINATION"
            self.replacement_status = "HEALTHY"
            self._persist_health()

        health = self.agent_health_map()
        record = self.create_and_deliver_patch(
            patch_id="CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1",
            source_agent="CHANGEBOT",
            files=[
                "_COORDINATION/changebot.py",
                "_COORDINATION/changebot_health.json",
                "_COORDINATION/patch_store.py",
            ],
            change_class="PLANNED_RESTART",
            priority="ACTION_REQUIRED",
            target_agents=["AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"],
            required_state="APPLIED",
            summary=(
                "Old ChangeBot daemon exit code 1 was caused by intentional termination "
                "during patched restart. Replacement daemon is healthy. This is a "
                "PLANNED_RESTART, not runtime crash/FEM/agent defect."
            ),
            why=(
                "All agents must treat prior ChangeBot exit_code=1 + restart as "
                "PLANNED_RESTART classification (not RUNTIME_CRASH)."
            ),
            required_action=(
                "Update local operational model: old_process_status=INTENTIONAL_TERMINATION, "
                "replacement_status=HEALTHY, classification=PLANNED_RESTART. "
                "ACK with state=APPLIED."
            ),
            dependency="none",
            ack_required=True,
            metadata={
                "old_exit_code": 1,
                "classification": "PLANNED_RESTART",
                "old_process_status": "INTENTIONAL_TERMINATION",
                "replacement_status": "HEALTHY",
                "not": ["RUNTIME_CRASH", "AGENT_DEFECT", "FEM_FAILURE", "PROJECT_FAILURE"],
                "agent_health_at_delivery": health,
            },
        )
        return record

    def deliver_pending_digest(self, agent: str) -> None:
        """On agent return: compact digest of still-active ACTION/CRITICAL patches."""
        active = self.patches.active_action_patches()
        pending = []
        for rec in active:
            state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent)
            if agent not in (rec.get("TARGET_AGENTS") or []):
                continue
            if state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                continue
            pending.append(rec["PATCH_ID"])
            try:
                if self.patches.needs_delivery(rec["PATCH_ID"], agent):
                    self.deliver_patch(rec, agents=[agent])
                else:
                    # Already in inbox once — force re-surface on return
                    state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent)
                    if state not in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}:
                        self.deliver_patch(rec, agents=[agent], force=True)
            except OSError as exc:
                safe_print(f"  [DIGEST_DELIVER_WARN] {rec['PATCH_ID']} -> {agent}: {exc}")
        if not pending:
            return
        body = (
            f"PENDING_PATCH_DIGEST for {agent}\n"
            f"COUNT: {len(pending)}\n"
            f"PATCHES: {', '.join(pending)}\n"
            "Details already in your inbox or re-delivered above. Continue work immediately.\n"
        )
        try:
            self.mailbox.send(agent, f"PENDING_DIGEST {len(pending)}", body, priority="HIGH")
        except OSError:
            pass

    def watch(self) -> None:
        self._daemon_mode = True
        if not self.acquire_watch_lock():
            return
        self._load_or_init_health()
        restored = self._restore_pending_batch()
        safe_print(f"[ChangeBot] Watching {self.watch_dir}")
        safe_print(f"[ChangeBot] Poll interval: {self.POLL_INTERVAL}s")
        safe_print(f"[ChangeBot] Generation: {self.daemon_generation} reason={self.restart_reason}")
        safe_print(f"[ChangeBot] Ignoring: {', '.join(sorted(self.IGNORE_DIRS))}")
        safe_print("[ChangeBot] Selective route + coalesce enabled. Ctrl+C to stop\n")

        # Baseline without flooding (restored coalesce items kept separately)
        self._save_state(self._scan_files())
        self.last_scan = utc_now()
        self._persist_health()
        safe_print("[ChangeBot] Initial state captured.\n")
        if restored:
            self._maybe_flush()
        maintenance_every = 12  # ~60s at 5s poll
        tick = 0

        while self.running:
            try:
                self.ingest_acks()
                # Also recover stranded *.json.tmp ACK drops before presence work.
                try:
                    Mailbox(str(self.coord_dir), "CHANGEBOT").recover_tmp_messages()
                except OSError:
                    pass
                self.refresh_agent_presence()
                self.reconcile_receipts()
                tick += 1
                if tick >= maintenance_every:
                    tick = 0
                    self.collapse_lane_duplicates()
                    self.collapse_authority_lane()
                    self.collapse_architecture_lane()
                    self.collapse_verification_lane()
                    self.dedupe_patches()
                    self.archive_agent_inboxes()
                    self.soft_ping_unread_hints()
                    self.nudge_received_apply(
                        "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1"
                    )
                    self.owner_coverage_report(
                        "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1"
                    )
                changes = self.detect_changes()
                if changes:
                    ts = datetime.now(timezone.utc).strftime("%H:%M:%S")
                    safe_print(
                        f"[{ts}] {len(changes)} content change(s) "
                        f"(coalesce until deadline)"
                    )
                    self.process_changes(changes)
                # Honor COALESCE_WINDOW_* — do not flush on every detect tick.
                self._maybe_flush()
                self.last_scan = utc_now()
                self._persist_health()
                time.sleep(self.POLL_INTERVAL)
            except Exception as e:
                safe_print(f"[ChangeBot] Error: {e}")
                time.sleep(self.POLL_INTERVAL)

        self._flush_batch()
        safe_print("[ChangeBot] Stopped.")

    def scan(self) -> None:
        self.ingest_acks()
        changes = self.detect_changes()
        if changes:
            safe_print(f"{len(changes)} content change(s) since last scan:")
            self.process_changes(changes)
            self._flush_batch()
        else:
            safe_print("No content changes detected since last scan.")

    def show_changelog(self, lines: int = 20) -> None:
        if not self.changelog_path.exists():
            safe_print("No changelog found.")
            return
        try:
            with open(self.changelog_path, "r", encoding="utf-8") as f:
                all_lines = f.readlines()
        except OSError as e:
            safe_print(f"Could not read changelog: {e}")
            return
        for line in all_lines[-lines:]:
            safe_print(line.rstrip())

    def status(self) -> None:
        health = {}
        if self.health_path.exists():
            try:
                with open(self.health_path, "r", encoding="utf-8") as f:
                    health = json.load(f)
            except (OSError, json.JSONDecodeError):
                pass
        agents = self.agent_health_map()
        safe_print(json.dumps({
            "daemon": health,
            "agents": agents,
            "pid_now": os.getpid(),
            "generation": self.daemon_generation,
            "restart_reason": self.restart_reason,
        }, indent=2))


def write_mailbox_audit(coord_dir: Path) -> Path:
    """CB-02: identify coalesce/supersede candidates; do not delete history."""
    audit = {
        "created_at": utc_now(),
        "note": "Historical messages retained. Candidates only.",
        "coalesce_candidates": [
            {
                "window": "2026-09-16T06:11:15..06:11:16Z",
                "suggested_patch_id": "A_MEMORY_ARCH_POINTER_20260916",
                "files": [
                    "00_INDEX.md",
                    "01_MASTER_ARCHITECTURE.md",
                    "02_MEMORY_STRATIFICATION.md",
                    "03_ASTRA_AUTHORITY.md",
                    "04_ABI_AND_PROTOCOL.md",
                    "20_GLOSSARY_AND_LOCKED_TERMS.md",
                    "READING_ORDER.md",
                ],
                "bad_behavior": "7 per-file broadcasts to all mailbox agents",
                "good_behavior": "1 coalesced ACTION_REQUIRED patch to A/B/D as relevant",
                "status": "HISTORICAL_NOISE_RETAINED",
            },
            {
                "window": "2026-09-16T06:18:11Z",
                "suggested_patch_id": "D_M1_LOADER_XSIM_VECTORS_20260916",
                "files": [
                    "tb/native_ai/loader/vectors/v1_valid.mem",
                    "tb/native_ai/loader/vectors/v2_bad_magic.mem",
                    "tb/native_ai/loader/vectors/v3_bad_abi.mem",
                    "tb/native_ai/loader/vectors/v4_bad_page_crc.mem",
                    "tb/native_ai/loader/vectors/v5_valid_drain.mem",
                    "vivado/m1_pack_loader/xsim/run_xsim.bat",
                    "vivado/tcl/02_ooc_synth_pack_loader.tcl",
                ],
                "bad_behavior": "7 per-file broadcasts including TEST",
                "good_behavior": "1 INFO/ACTION patch primarily to D (+B if ABI vectors)",
                "status": "HISTORICAL_NOISE_RETAINED",
            },
        ],
        "supersede_candidates": [
            {
                "older": "duplicate pack_loader.sv MODIFY @ 06:17:35",
                "newer": "pack_loader.sv MODIFY @ 06:17:56",
                "action": "newer supersedes older; do not require apply of older",
                "status": "NOTED_NOT_DELETED",
            }
        ],
        "already_applied_signals": [
            {
                "agent": "AGENT_A",
                "evidence": "38 messages moved to inbox/read",
                "note": "Partial consumption; not full VERIFIED coverage",
            },
            {
                "agent": "AGENT_B",
                "evidence": "0 read/",
                "note": "Likely NOT_SEEN for most historical broadcasts",
            },
            {
                "agent": "AGENT_C",
                "evidence": "not in registry; inbox backlog only",
                "note": "OFFLINE — pending delivery semantics",
            },
            {
                "agent": "AGENT_D",
                "evidence": "0 read/; last_seen older than STALE window",
                "note": "STALE; mailbox pending",
            },
        ],
    }
    out = coord_dir / "patches" / "_mailbox_audit_CB02.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    atomic_write_json(out, audit)
    return out


def _pid_alive(pid: int) -> bool:
    if not isinstance(pid, int) or pid <= 0:
        return False
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32  # type: ignore[attr-defined]
        handle = kernel32.OpenProcess(0x1000, False, pid)
        if handle:
            kernel32.CloseHandle(handle)
            return True
    except Exception:
        pass
    return False


def _detach_watch(coord_dir: str, *, force: bool = True) -> int:
    """Planned-restart detach. Returns new (or existing) pid."""
    bot = ChangeBot(str(Path(coord_dir).parent), coord_dir)
    if not force:
        # Avoid thrash: keep a healthy live watch.
        try:
            with open(bot.health_path, "r", encoding="utf-8") as f:
                prev = json.load(f) or {}
        except (OSError, json.JSONDecodeError, TypeError):
            prev = {}
        pid = prev.get("pid")
        last = prev.get("last_scan")
        if isinstance(pid, int) and pid > 0 and _pid_alive(pid) and last:
            try:
                age = (
                    datetime.now(timezone.utc) - datetime.fromisoformat(str(last))
                ).total_seconds()
            except (TypeError, ValueError):
                age = 9999
            if age <= 90 and prev.get("health") == "healthy":
                safe_print(
                    f"ChangeBot already healthy pid={pid} gen={prev.get('daemon_generation')} "
                    f"age_s={round(age, 1)} — skip detach"
                )
                return pid

    bot._write_restart_marker(reason="detach_watch", intentional=True)
    try:
        out = subprocess.check_output(
            ["wmic", "process", "where", "name='python.exe'", "get", "ProcessId,CommandLine"],
            text=True,
            errors="replace",
        )
        for line in out.splitlines():
            if "changebot.py" in line and "--watch" in line:
                parts = line.strip().split()
                for tok in reversed(parts):
                    if tok.isdigit():
                        pid = int(tok)
                        if pid != os.getpid():
                            try:
                                os.kill(pid, 9)
                                safe_print(f"Stopped stray watch pid={pid}")
                            except OSError:
                                pass
                        break
    except Exception:
        try:
            with open(bot.health_path, "r", encoding="utf-8") as f:
                prev = json.load(f) or {}
            old_pid = prev.get("pid")
            if isinstance(old_pid, int) and old_pid > 0:
                try:
                    os.kill(old_pid, 9)
                except OSError:
                    pass
        except (OSError, json.JSONDecodeError, TypeError):
            pass
    time.sleep(0.5)
    creationflags = 0
    if hasattr(subprocess, "DETACHED_PROCESS"):
        creationflags |= subprocess.DETACHED_PROCESS  # type: ignore[attr-defined]
    if hasattr(subprocess, "CREATE_NEW_PROCESS_GROUP"):
        creationflags |= subprocess.CREATE_NEW_PROCESS_GROUP  # type: ignore[attr-defined]
    log_path = Path(coord_dir) / "changebot_daemon.log"
    logf = open(log_path, "a", encoding="utf-8")
    proc = subprocess.Popen(
        [sys.executable, str(Path(__file__).resolve()), "--watch"],
        cwd=coord_dir,
        stdout=logf,
        stderr=subprocess.STDOUT,
        stdin=subprocess.DEVNULL,
        creationflags=creationflags,
        close_fds=True,
    )
    safe_print(f"Detached ChangeBot pid={proc.pid} log={log_path}")
    return proc.pid


def _ensure_watch(coord_dir: str) -> int:
    """Start watch only if missing/unhealthy; never thrash a healthy daemon."""
    return _detach_watch(coord_dir, force=False)


def _watchdog_once(coord_dir: str, max_age_sec: int = 90) -> str:
    """Restart watch if pid dead or last_scan older than max_age_sec."""
    health_path = Path(coord_dir) / "changebot_health.json"
    if not health_path.exists():
        _detach_watch(coord_dir)
        return "restarted_missing_health"
    try:
        with open(health_path, "r", encoding="utf-8") as f:
            health = json.load(f) or {}
    except (OSError, json.JSONDecodeError, TypeError):
        _detach_watch(coord_dir)
        return "restarted_corrupt_health"
    pid = health.get("pid")
    last = health.get("last_scan")
    alive = _pid_alive(int(pid)) if isinstance(pid, int) else False
    age = None
    if last:
        try:
            ts = datetime.fromisoformat(str(last).replace("Z", "+00:00"))
            age = (datetime.now(timezone.utc) - ts).total_seconds()
        except (TypeError, ValueError):
            age = None
    if not alive or age is None or age > max_age_sec:
        _detach_watch(coord_dir)
        return f"restarted alive={alive} age={age}"
    return f"ok alive={alive} age={age}"


if __name__ == "__main__":
    configure_stdio()
    coord_dir = str(Path(__file__).parent)
    watch_dir = str(Path(__file__).parent.parent)
    bot = ChangeBot(watch_dir, coord_dir)

    if len(sys.argv) < 2 or sys.argv[1] == "--watch":
        bot.watch()
    elif sys.argv[1] == "--scan":
        bot.scan()
    elif sys.argv[1] == "--status":
        bot.status()
    elif sys.argv[1] == "--ingest-acks":
        n = bot.ingest_acks()
        safe_print(f"Ingested {n} ACK(s).")
    elif sys.argv[1] == "--reconcile":
        n = bot.reconcile_receipts()
        p = bot.refresh_agent_presence()
        r = bot.retire_misrouted_patches()
        c = bot.collapse_lane_duplicates()
        ca = bot.collapse_authority_lane()
        d = bot.dedupe_patches()
        a = bot.archive_agent_inboxes()
        nudged = bot.nudge_received_apply("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
        safe_print(
            f"Receipts={n}; presence={p}; retired_misroute={r}; "
            f"collapsed={c}; auth_collapsed={ca}; superseded_dupes={d}; "
            f"archived_mail={a}; r1_apply_nudge={','.join(nudged) or 'none'}"
        )
    elif sys.argv[1] == "--detach-watch":
        force = "--force" in sys.argv
        _detach_watch(coord_dir, force=force)
    elif sys.argv[1] == "--ensure-watch":
        _ensure_watch(coord_dir)
    elif sys.argv[1] == "--soft-ping":
        updated = bot.soft_ping_unread_hints(min_interval_sec=0)
        safe_print(json.dumps(updated, indent=2, ensure_ascii=False))
    elif sys.argv[1] == "--watchdog-once":
        try:
            max_age = int(sys.argv[2]) if len(sys.argv) > 2 else 90
        except ValueError:
            max_age = 90
        safe_print(_watchdog_once(coord_dir, max_age))
    elif sys.argv[1] == "--coverage" and len(sys.argv) >= 3:
        report = bot.owner_coverage_report(sys.argv[2], force=True)
        safe_print(report or f"No record for {sys.argv[2]}")
    elif sys.argv[1] == "--pending" and len(sys.argv) >= 3:
        agent = sys.argv[2]
        rows = bot.pending_for_agent(agent)
        safe_print(f"PENDING ACTION/CRITICAL for {agent}: {len(rows)}")
        for r in rows:
            safe_print(
                f"  [{r['PRIORITY']}] {r['PATCH_ID']} state={r['STATE']} "
                f"files={r['FILES']} | {r['SUMMARY']}"
            )
            safe_print(f"    ACK: {r['ACK']}")
    elif sys.argv[1] == "--bootstrap-planned-restart":
        write_mailbox_audit(Path(coord_dir))
        rec = bot.bootstrap_planned_restart_classification()
        safe_print(f"PATCH created: {rec['PATCH_ID']}")
        safe_print(json.dumps(rec.get("CURRENT_AGENT_STATES"), indent=2))
        report = bot.owner_coverage_report(rec["PATCH_ID"], force=True)
        if report:
            safe_print(report)
            owner_dir = Path(coord_dir) / "mailbox" / "OWNER" / "inbox"
            owner_dir.mkdir(parents=True, exist_ok=True)
            atomic_write_json(
                owner_dir / f"COVERAGE_{rec['PATCH_ID']}.json",
                {
                    "sender": "CHANGEBOT",
                    "to": "OWNER",
                    "timestamp": utc_now(),
                    "priority": "HIGH",
                    "subject": f"PATCH COVERAGE — {rec['PATCH_ID']}",
                    "body": report,
                },
            )
    elif sys.argv[1] == "--changelog":
        try:
            n = int(sys.argv[2]) if len(sys.argv) > 2 else 20
        except ValueError:
            n = 20
        bot.show_changelog(n)
    elif sys.argv[1] == "--write-restart-marker":
        bot._write_restart_marker(reason="patched_replacement", intentional=True)
        safe_print(f"Wrote {bot.restart_marker_path}")
    else:
        safe_print("Usage:")
        safe_print("  python changebot.py --watch")
        safe_print("  python changebot.py --ensure-watch")
        safe_print("  python changebot.py --detach-watch [--force]")
        safe_print("  python changebot.py --scan")
        safe_print("  python changebot.py --status")
        safe_print("  python changebot.py --coverage <PATCH_ID>")
        safe_print("  python changebot.py --ingest-acks")
        safe_print("  python changebot.py --bootstrap-planned-restart")
        safe_print("  python changebot.py --changelog [N]")
        sys.exit(1)
