from __future__ import annotations
import fnmatch, pathlib, subprocess, os
from .manifest import snapshot, diff
from .util import load_json, atomic_write_json, sha256_file, utc_ts


def changed_files_git(root:pathlib.Path):
    try:
        out=subprocess.check_output(["git","-C",str(root),"status","--porcelain"],text=True,stderr=subprocess.DEVNULL)
    except Exception:
        return []
    files=[]
    for line in out.splitlines():
        if not line.strip(): continue
        p=line[3:].strip()
        if " -> " in p: p=p.split(" -> ",1)[1]
        files.append(p.replace("\\","/"))
    return files

def protected_violations(root:pathlib.Path,cfg:dict,role:str):
    if role.lower()=="owner": return []
    changed=changed_files_git(root); pats=cfg.get("protected_paths",[]); bad=[]
    for p in changed:
        if any(fnmatch.fnmatch(p,pat) or pathlib.PurePosixPath(p).match(pat) for pat in pats): bad.append(p)
    return bad

def freeze_contract(root:pathlib.Path,cfg:dict,name:str):
    d=root/".native_guard"/"contracts"; d.mkdir(parents=True,exist_ok=True)
    m=snapshot(root,cfg,d/f"{name}.json")
    return m

def verify_contract(root:pathlib.Path,cfg:dict,name:str):
    p=root/".native_guard"/"contracts"/f"{name}.json"; base=load_json(p,None)
    if not base: raise FileNotFoundError(p)
    cur=snapshot(root,cfg,None); return diff(base,cur),base,cur
