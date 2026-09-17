"""Shared hardening for CANON_BLUEPRINT coordination tools.

Windows cp1252 consoles, None stdout encoding, path separators in names,
and non-atomic JSON writes have already interrupted the agent loop.
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Any

_AGENT_ID = re.compile(r"^[A-Za-z][A-Za-z0-9_-]{0,63}$")


def configure_stdio() -> None:
    """Make prints survive Windows consoles. Never raise."""
    for stream in (sys.stdout, sys.stderr):
        if stream is None:
            continue
        enc = getattr(stream, "encoding", None) or ""
        if enc.lower().replace("-", "") in {"utf8", "utf_8"}:
            continue
        reconfigure = getattr(stream, "reconfigure", None)
        if not callable(reconfigure):
            continue
        try:
            reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass


def safe_print(*args: Any, **kwargs: Any) -> None:
    kwargs.setdefault("flush", True)
    try:
        print(*args, **kwargs)
    except UnicodeEncodeError:
        text = " ".join(str(a) for a in args)
        file = kwargs.get("file", sys.stdout) or sys.stdout
        encoding = getattr(file, "encoding", None) or "ascii"
        raw = (text + "\n").encode(encoding, errors="replace")
        buf = getattr(file, "buffer", None)
        if buf is not None:
            try:
                buf.write(raw)
                buf.flush()
                return
            except Exception:
                pass
        try:
            file.write(text.encode("ascii", "replace").decode("ascii"))
            file.write("\n")
        except Exception:
            pass


def safe_agent_id(agent_id: str) -> str:
    """Reject IDs that would become nested paths on Windows."""
    if not isinstance(agent_id, str) or not _AGENT_ID.fullmatch(agent_id):
        raise ValueError(f"unsafe agent id: {agent_id!r}")
    if agent_id in {".", ".."}:
        raise ValueError(f"unsafe agent id: {agent_id!r}")
    return agent_id


def atomic_write_json(path: Path, data: Any, *, attempts: int = 8) -> None:
    """Write JSON via replace() so a crash cannot leave half a registry/lock.

    On Windows, concurrent readers/writers of the same path (ChangeBot daemon +
    CLI) can briefly deny replace(); retry instead of failing the control plane.
    """
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    payload = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    last_err: OSError | None = None
    for i in range(max(1, attempts)):
        try:
            with open(tmp, "w", encoding="utf-8") as f:
                f.write(payload)
                f.flush()
                try:
                    os.fsync(f.fileno())
                except OSError:
                    pass
            os.replace(tmp, path)
            return
        except OSError as exc:
            last_err = exc
            # WinError 5 Access denied / sharing violation — brief lock contention
            time.sleep(0.05 * (i + 1))
            try:
                if tmp.exists():
                    tmp.unlink(missing_ok=True)  # type: ignore[call-arg]
            except TypeError:
                try:
                    if tmp.exists():
                        tmp.unlink()
                except OSError:
                    pass
            except OSError:
                pass
    assert last_err is not None
    raise last_err


def is_dot_dir(name: str) -> bool:
    return name.startswith(".") and name not in {".", ".."}


def resolve_coordination_dir(local: str | Path | None = None) -> Path:
    """Return the shared package coordination root.

    Agent worktrees keep a local `_COORDINATION` copy with a `mailbox` junction
    only. Registry / patches / ChangeBot state live on the canonical package
    path recorded in `coordination_root.json`. Prefer that root so ACK/presence
    updates are visible to the live daemon.
    """
    here = Path(local) if local is not None else Path(__file__).resolve().parent
    here = here.resolve()
    cfg = here / "coordination_root.json"
    if cfg.exists():
        try:
            data = json.loads(cfg.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError, TypeError, ValueError):
            data = None
        if isinstance(data, dict):
            raw = data.get("canonical_coordination_dir") or data.get("canonical")
            if isinstance(raw, str) and raw.strip():
                cand = Path(raw.strip())
                try:
                    cand = cand.resolve()
                except OSError:
                    cand = cand
                if cand.is_dir() and (cand / "mailbox").exists():
                    return cand
    return here
