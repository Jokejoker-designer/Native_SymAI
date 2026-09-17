from __future__ import annotations
import hashlib, json, pathlib
from .util import canonical_json, utc_ts

class EvidenceLog:
    def __init__(self, root: pathlib.Path):
        self.path = root / ".native_guard" / "evidence.jsonl"
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def _last_hash(self):
        if not self.path.exists(): return "0"*64
        last = None
        with self.path.open("r", encoding="utf-8") as f:
            for line in f:
                if line.strip(): last = json.loads(line)
        return last.get("entry_hash", "0"*64) if last else "0"*64

    def append(self, event: str, status: str, agent: str, data: dict):
        prev = self._last_hash()
        base = {"utc": utc_ts(), "event": event, "status": status, "agent": agent, "data": data, "prev_hash": prev}
        h = hashlib.sha256(canonical_json(base).encode("utf-8")).hexdigest()
        base["entry_hash"] = h
        with self.path.open("a", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps(base, sort_keys=True, ensure_ascii=False) + "\n")
        return base

    def verify(self):
        prev="0"*64; n=0
        if not self.path.exists(): return True,0,None
        for lineno,line in enumerate(self.path.read_text(encoding="utf-8").splitlines(),1):
            if not line.strip(): continue
            e=json.loads(line); got=e.pop("entry_hash",None)
            if e.get("prev_hash") != prev: return False,n,{"line":lineno,"error":"prev_hash mismatch"}
            calc=hashlib.sha256(canonical_json(e).encode("utf-8")).hexdigest()
            if calc != got: return False,n,{"line":lineno,"error":"entry hash mismatch"}
            prev=got; n+=1
        return True,n,None
