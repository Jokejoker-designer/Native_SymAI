from __future__ import annotations
import json, os, pathlib, time
from dataclasses import dataclass
from .util import atomic_write_json, load_json, utc_ts, safe_resolve

@dataclass
class Lease:
    key: str
    agent: str
    pid: int
    created: float
    expires: float
    path: str

class LeaseManager:
    def __init__(self, root: pathlib.Path):
        self.root = root.resolve()
        self.dir = self.root / ".native_guard" / "leases"
        self.dir.mkdir(parents=True, exist_ok=True)

    def _path(self, key: str) -> pathlib.Path:
        safe = "".join(c if c.isalnum() or c in "._-" else "_" for c in key)
        return self.dir / f"{safe}.json"

    def acquire(self, key: str, agent: str, ttl: int = 3600, force_stale: bool = False):
        p = self._path(key)
        now = time.time()
        payload = {"key": key, "agent": agent, "pid": os.getpid(), "created": now, "expires": now + ttl, "created_utc": utc_ts()}
        try:
            fd = os.open(str(p), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            with os.fdopen(fd, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2, sort_keys=True)
            return payload
        except FileExistsError:
            cur = load_json(p, {})
            if force_stale and float(cur.get("expires", 0)) < now:
                stale = p.with_suffix(p.suffix + f".stale.{int(now)}")
                os.replace(p, stale)
                return self.acquire(key, agent, ttl, False)
            raise RuntimeError(f"Lease busy: {key} held by {cur.get('agent')} until {cur.get('expires')}")

    def heartbeat(self, key: str, agent: str, ttl: int = 3600):
        p = self._path(key); cur = load_json(p, None)
        if not cur or cur.get("agent") != agent:
            raise RuntimeError(f"Lease not owned by {agent}: {key}")
        cur["expires"] = time.time() + ttl; cur["heartbeat_utc"] = utc_ts()
        atomic_write_json(p, cur)

    def release(self, key: str, agent: str):
        p = self._path(key); cur = load_json(p, None)
        if not cur:
            return
        if cur.get("agent") != agent:
            raise RuntimeError(f"Lease owned by {cur.get('agent')}, not {agent}")
        try:
            p.unlink()
        except FileNotFoundError:
            return

    def list(self):
        now = time.time(); out=[]
        for p in sorted(self.dir.glob("*.json")):
            cur = load_json(p, {})
            cur["stale"] = float(cur.get("expires", 0)) < now
            out.append(cur)
        return out

    def claim_file(self, relpath: str, agent: str, ttl: int = 3600):
        q = safe_resolve(self.root, relpath)
        key = "file__" + str(q.relative_to(self.root)).replace(os.sep, "__")
        return self.acquire(key, agent, ttl)
