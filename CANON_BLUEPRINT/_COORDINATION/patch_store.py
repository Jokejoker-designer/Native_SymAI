"""Patch state store for ChangeBot coordination (stdlib only)."""
from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from coord_util import atomic_write_json

AGENT_STATES = frozenset({
    "NOT_SEEN",
    "RECEIVED",
    "APPLIED",
    "VERIFIED",
    "OFFLINE",
    "NOT_REQUIRED",
})

PRIORITIES = frozenset({"INFO", "ACTION_REQUIRED", "CRITICAL"})
TERMINAL_OK = frozenset({"APPLIED", "VERIFIED", "NOT_REQUIRED"})


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_file(path: Path) -> str | None:
    try:
        h = hashlib.sha256()
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(65536), b""):
                h.update(chunk)
        return h.hexdigest()
    except OSError:
        return None


class PatchStore:
    """Tracks PATCH_ID records under _COORDINATION/patches/."""

    def __init__(self, coord_dir: str | Path):
        self.coord_dir = Path(coord_dir)
        self.patches_dir = self.coord_dir / "patches"
        self.patches_dir.mkdir(parents=True, exist_ok=True)
        self.index_path = self.patches_dir / "index.json"
        if not self.index_path.exists():
            atomic_write_json(self.index_path, {"patches": {}, "updated_at": utc_now()})

    def _path(self, patch_id: str) -> Path:
        safe = "".join(c if c.isalnum() or c in "-_" else "_" for c in patch_id)
        return self.patches_dir / f"{safe}.json"

    def _load_index(self) -> dict:
        try:
            with open(self.index_path, "r", encoding="utf-8") as f:
                data = json_load(f)
            if isinstance(data, dict):
                return data
        except (OSError, ValueError, TypeError):
            pass
        return {"patches": {}, "updated_at": utc_now()}

    def _save_index(self, index: dict) -> None:
        index["updated_at"] = utc_now()
        atomic_write_json(self.index_path, index)

    def load(self, patch_id: str) -> dict | None:
        path = self._path(patch_id)
        if not path.exists():
            return None
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json_load(f)
            return data if isinstance(data, dict) else None
        except (OSError, ValueError, TypeError):
            return None

    def save(self, record: dict) -> Path:
        patch_id = record["PATCH_ID"]
        path = self._path(patch_id)
        record["UPDATED_AT"] = utc_now()
        atomic_write_json(path, record)
        index = self._load_index()
        patches = index.setdefault("patches", {})
        patches[patch_id] = {
            "status": record.get("STATUS", "ACTIVE"),
            "priority": record.get("PRIORITY"),
            "created_at": record.get("CREATED_AT"),
            "superseded_by": record.get("SUPERSEDED_BY"),
            "path": str(path.name),
        }
        self._save_index(index)
        return path

    def create(
        self,
        patch_id: str,
        *,
        source_agent: str,
        files: list[str],
        change_class: str,
        priority: str,
        target_agents: list[str],
        required_state: str,
        summary: str,
        why: str,
        required_action: str,
        dependency: str = "",
        ack_required: bool = True,
        agent_health: dict[str, str] | None = None,
        supersedes: list[str] | None = None,
        metadata: dict | None = None,
    ) -> dict:
        if priority not in PRIORITIES:
            raise ValueError(f"invalid priority: {priority}")
        if required_state not in AGENT_STATES:
            raise ValueError(f"invalid required_state: {required_state}")

        existing = self.load(patch_id)
        if existing and existing.get("STATUS") not in {"SUPERSEDED", "OBSOLETE"}:
            return existing

        health = agent_health or {}
        current: dict[str, str] = {}
        for agent in target_agents:
            if health.get(agent) == "OFFLINE":
                current[agent] = "OFFLINE"
            else:
                current[agent] = "NOT_SEEN"

        record = {
            "PATCH_ID": patch_id,
            "CREATED_AT": utc_now(),
            "SOURCE_AGENT": source_agent,
            "FILES": self.normalize_files(list(files)),
            "CHANGE_CLASS": change_class,
            "PRIORITY": priority,
            "TARGET_AGENTS": list(target_agents),
            "REQUIRED_STATE": required_state,
            "CURRENT_AGENT_STATES": current,
            "SUMMARY": summary,
            "WHY": why,
            "REQUIRED_ACTION": required_action,
            "DEPENDENCY": dependency,
            "ACK_REQUIRED": bool(ack_required),
            "STATUS": "ACTIVE",
            "SUPERSEDES": list(supersedes or []),
            "SUPERSEDED_BY": None,
            "DELIVERIES": {},
            "ACKS": [],
            "METADATA": metadata or {},
        }
        meta = record["METADATA"]
        if "fingerprint" not in meta:
            meta["fingerprint"] = self.content_fingerprint(
                record["FILES"], change_class, priority, list(target_agents)
            )
        self.save(record)

        for old_id in supersedes or []:
            old = self.load(old_id)
            if not old:
                continue
            old["STATUS"] = "SUPERSEDED"
            old["SUPERSEDED_BY"] = patch_id
            self.save(old)

        return record

    def set_agent_state(self, patch_id: str, agent: str, state: str, note: str = "") -> dict | None:
        if state not in AGENT_STATES:
            raise ValueError(f"invalid state: {state}")
        record = self.load(patch_id)
        if not record:
            return None
        record.setdefault("CURRENT_AGENT_STATES", {})[agent] = state
        if note or state:
            record.setdefault("ACKS", []).append({
                "agent": agent,
                "state": state,
                "note": note,
                "at": utc_now(),
            })
        self.save(record)
        return record

    def mark_delivered(self, patch_id: str, agent: str, path: str) -> dict | None:
        record = self.load(patch_id)
        if not record:
            return None
        deliveries = record.setdefault("DELIVERIES", {})
        if agent not in deliveries:
            deliveries[agent] = {"path": path, "at": utc_now()}
        states = record.setdefault("CURRENT_AGENT_STATES", {})
        if states.get(agent) == "OFFLINE":
            # Delivered to offline mailbox = pending read; keep OFFLINE semantics
            pass
        elif states.get(agent) in {None, "NOT_SEEN"}:
            states[agent] = "NOT_SEEN"
        self.save(record)
        return record

    def coverage(self, patch_id: str) -> dict[str, str]:
        record = self.load(patch_id)
        if not record:
            return {}
        return dict(record.get("CURRENT_AGENT_STATES") or {})

    def needs_delivery(self, patch_id: str, agent: str) -> bool:
        record = self.load(patch_id)
        if not record or record.get("STATUS") != "ACTIVE":
            return False
        if agent not in record.get("TARGET_AGENTS", []):
            return False
        state = (record.get("CURRENT_AGENT_STATES") or {}).get(agent, "NOT_SEEN")
        if state in TERMINAL_OK:
            return False
        deliveries = record.get("DELIVERIES") or {}
        if agent not in deliveries:
            return True
        # Stale delivery pointer (archived/moved): allow re-delivery.
        path = Path(str((deliveries.get(agent) or {}).get("path") or ""))
        if path.is_file():
            return False
        return True

    def repair_delivery_pointer(self, patch_id: str, agent: str, path: str) -> dict | None:
        record = self.load(patch_id)
        if not record:
            return None
        deliveries = record.setdefault("DELIVERIES", {})
        deliveries[agent] = {"path": path, "at": utc_now()}
        self.save(record)
        return record

    def active_action_patches(self) -> list[dict]:
        index = self._load_index()
        out = []
        for patch_id, meta in (index.get("patches") or {}).items():
            if meta.get("status") != "ACTIVE":
                continue
            if meta.get("priority") not in {"ACTION_REQUIRED", "CRITICAL"}:
                continue
            rec = self.load(patch_id)
            if rec:
                out.append(rec)
        return out

    def all_active(self) -> list[dict]:
        index = self._load_index()
        out = []
        for patch_id, meta in (index.get("patches") or {}).items():
            if meta.get("status") != "ACTIVE":
                continue
            rec = self.load(patch_id)
            if rec:
                out.append(rec)
        return out

    @staticmethod
    def normalize_files(files: list[str]) -> list[str]:
        seen = set()
        out = []
        for f in files:
            n = str(f).replace("\\", "/")
            if n not in seen:
                seen.add(n)
                out.append(n)
        return sorted(out)

    @staticmethod
    def content_fingerprint(
        files: list[str],
        change_class: str,
        priority: str,
        targets: list[str],
    ) -> str:
        norm = PatchStore.normalize_files(files)
        key = "|".join([
            change_class,
            priority,
            ",".join(sorted(targets)),
            ",".join(norm),
        ])
        return hashlib.md5(key.encode()).hexdigest()[:12]

    def dedupe_active_by_fingerprint(self) -> list[tuple[str, str]]:
        """Supersede older ACTIVE patches that share fingerprint with a newer one.

        Returns list of (old_id, newer_id).
        """
        actives = self.all_active()
        groups: dict[str, list[dict]] = {}
        for rec in actives:
            fp = rec.get("METADATA", {}).get("fingerprint")
            if not fp:
                fp = self.content_fingerprint(
                    list(rec.get("FILES") or []),
                    str(rec.get("CHANGE_CLASS") or ""),
                    str(rec.get("PRIORITY") or ""),
                    list(rec.get("TARGET_AGENTS") or []),
                )
                meta = rec.setdefault("METADATA", {})
                meta["fingerprint"] = fp
                self.save(rec)
            groups.setdefault(fp, []).append(rec)

        superseded_pairs = []
        for fp, recs in groups.items():
            if len(recs) < 2:
                continue
            recs.sort(key=lambda r: str(r.get("CREATED_AT") or ""))
            newest = recs[-1]
            for old in recs[:-1]:
                old["STATUS"] = "SUPERSEDED"
                old["SUPERSEDED_BY"] = newest["PATCH_ID"]
                self.save(old)
                supersedes = list(newest.get("SUPERSEDES") or [])
                if old["PATCH_ID"] not in supersedes:
                    supersedes.append(old["PATCH_ID"])
                    newest["SUPERSEDES"] = supersedes
                superseded_pairs.append((old["PATCH_ID"], newest["PATCH_ID"]))
            self.save(newest)
        return superseded_pairs


def json_load(f) -> Any:
    import json
    return json.load(f)
