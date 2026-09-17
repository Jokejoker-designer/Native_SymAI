from __future__ import annotations
import fnmatch, os, pathlib, subprocess
from .util import sha256_file, sha256_obj, atomic_write_json, utc_ts


def _match_any(rel: str, globs):
    rel2 = rel.replace(os.sep, "/")
    return any(fnmatch.fnmatch(rel2, g) or pathlib.PurePosixPath(rel2).match(g) for g in globs)


def snapshot(root: pathlib.Path, cfg: dict, out: pathlib.Path | None = None):
    root = root.resolve(); files = {}
    ex = set(cfg.get("exclude_dirs", [])); globs = cfg.get("hash_globs", ["**/*"])
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        rel = str(p.relative_to(root)).replace(os.sep, "/")
        if any(part in ex for part in p.relative_to(root).parts):
            continue
        if not _match_any(rel, globs):
            continue
        st = p.stat()
        files[rel] = {"sha256": sha256_file(p), "size": st.st_size, "mtime_ns": st.st_mtime_ns}
    git = {}
    try:
        git["head"] = subprocess.check_output(["git","-C",str(root),"rev-parse","HEAD"], text=True, stderr=subprocess.DEVNULL).strip()
        git["branch"] = subprocess.check_output(["git","-C",str(root),"rev-parse","--abbrev-ref","HEAD"], text=True, stderr=subprocess.DEVNULL).strip()
        git["dirty"] = bool(subprocess.check_output(["git","-C",str(root),"status","--porcelain"], text=True, stderr=subprocess.DEVNULL).strip())
    except Exception:
        git = {"available": False}
    obj = {"created_utc": utc_ts(), "root": str(root), "project": cfg.get("project", {}), "git": git, "files": files}
    obj["manifest_sha256"] = sha256_obj(obj)
    if out:
        atomic_write_json(out, obj)
    return obj


def diff(a: dict, b: dict):
    af, bf = a.get("files", {}), b.get("files", {})
    keys = sorted(set(af) | set(bf)); changes=[]
    for k in keys:
        if k not in af: changes.append({"path":k,"kind":"ADDED"})
        elif k not in bf: changes.append({"path":k,"kind":"DELETED"})
        elif af[k]["sha256"] != bf[k]["sha256"]: changes.append({"path":k,"kind":"MODIFIED","before":af[k]["sha256"],"after":bf[k]["sha256"]})
    return changes
