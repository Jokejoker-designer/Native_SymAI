from __future__ import annotations
import os, pathlib, time
from .util import load_json, atomic_write_json, utc_ts
from .locks import LeaseManager

class TaskDB:
    def __init__(self, root: pathlib.Path, cfg: dict):
        self.root=root; self.cfg=cfg; self.path=root/".native_guard"/"tasks.json"; self.path.parent.mkdir(parents=True, exist_ok=True)
        if not self.path.exists():
            atomic_write_json(self.path, {k:{"deps":v,"status":"PENDING"} for k,v in cfg.get("stages",{}).items()})
        self.lm=LeaseManager(root)

    def _load(self): return load_json(self.path,{})
    def claim(self, stage:str, agent:str, ttl:int=7200):
        db=self._load()
        if stage not in db: raise KeyError(stage)
        missing=[d for d in db[stage].get("deps",[]) if db.get(d,{}).get("status")!="PASS"]
        if missing: raise RuntimeError(f"Dependencies not PASS: {missing}")
        self.lm.acquire("task__"+stage,agent,ttl,force_stale=True)
        db[stage].update({"status":"RUNNING","agent":agent,"started_utc":utc_ts()}); atomic_write_json(self.path,db); return db[stage]
    def finish(self, stage:str, agent:str, status:str, evidence:dict):
        status=status.upper()
        if status not in {"PASS","FAIL","FAIL_PARTIAL","REVIEW_REQUIRED"}: raise ValueError(status)
        db=self._load(); rec=db[stage]
        rec.update({"status":status,"finished_utc":utc_ts(),"evidence":evidence,"agent":agent}); atomic_write_json(self.path,db)
        self.lm.release("task__"+stage,agent)

    def invalidate_from(self, stage:str, reason:str, agent:str):
        db=self._load()
        if stage not in db: raise KeyError(stage)
        # reverse dependency closure
        affected={stage}; changed=True
        while changed:
            changed=False
            for k,v in db.items():
                if k in affected: continue
                if any(d in affected for d in v.get("deps",[])):
                    affected.add(k); changed=True
        for k in affected:
            db[k].update({"status":"INVALIDATED","invalidated_utc":utc_ts(),"invalidated_by":agent,"reason":reason})
        atomic_write_json(self.path,db)
        return sorted(affected)
    def show(self): return self._load()
