from __future__ import annotations
import pathlib,subprocess,os,time
from .locks import LeaseManager
from .authority import changed_files_git

def run_doctor(root:pathlib.Path,cfg:dict):
    issues=[]; lm=LeaseManager(root)
    for x in lm.list():
        if x.get("stale"): issues.append({"severity":"WARN","kind":"STALE_LEASE","detail":x})
    # Build dir collision hints
    for name in [".Xil","runs","build"]:
        p=root/name
        if p.exists() and any(p.iterdir()): issues.append({"severity":"INFO","kind":"SHARED_BUILD_DIR","path":str(p),"message":"Use per-run isolated output directories; never let parallel agents share Vivado run state."})
    # Git/worktree state
    try:
        dirty=changed_files_git(root)
        if dirty: issues.append({"severity":"WARN","kind":"DIRTY_WORKTREE","files":dirty[:200]})
        wt=subprocess.check_output(["git","-C",str(root),"worktree","list","--porcelain"],text=True,stderr=subprocess.DEVNULL)
        issues.append({"severity":"INFO","kind":"WORKTREES","count":wt.count("worktree ")})
    except Exception: pass
    return issues
