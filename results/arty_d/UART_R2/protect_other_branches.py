# Snapshot/verify hashes of EVERY other-branch .bit/.dcp under D:/FPGA/arty_d.
# UART_R2/build is excluded. Failure means another identity was mutated.
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ARTY = Path(r"D:/FPGA/arty_d")
SELF = ARTY / "UART_R2"
SNAP = SELF / "OTHER_BRANCH_HASHES_BEFORE.json"
SKIP_PARTS = {".Xil", "xsim.dir"}


def iter_artifacts():
    for p in ARTY.rglob("*"):
        if not p.is_file():
            continue
        if p.suffix.lower() not in (".bit", ".dcp"):
            continue
        parts = set(p.parts)
        if SKIP_PARTS & parts:
            continue
        try:
            p.relative_to(SELF)
            continue
        except ValueError:
            pass
        yield p


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def snapshot():
    rec = {}
    for p in sorted(iter_artifacts()):
        rec[str(p).replace("\\", "/")] = {
            "sha256": sha256(p),
            "size": p.stat().st_size,
            "mtime_ns": p.stat().st_mtime_ns,
        }
    SELF.mkdir(parents=True, exist_ok=True)
    payload = {
        "when_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "count": len(rec),
        "exclude": "D:/FPGA/arty_d/UART_R2/**",
        "files": rec,
    }
    SNAP.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"SNAPSHOT_OK n={len(rec)} {SNAP}")
    return 0


def verify():
    if not SNAP.exists():
        print("VERIFY_FAIL missing snapshot", SNAP)
        return 2
    prev = json.loads(SNAP.read_text(encoding="utf-8"))
    files = prev["files"]
    bad = []
    for path, meta in files.items():
        p = Path(path)
        if not p.exists():
            bad.append(("MISSING", path, meta["sha256"], None))
            continue
        got = sha256(p)
        if got != meta["sha256"] or p.stat().st_size != meta["size"]:
            bad.append(("CHANGED", path, meta["sha256"], got))
    now = {str(p).replace("\\", "/") for p in iter_artifacts()}
    extra = sorted(now - set(files))
    if bad or extra:
        print("VERIFY_FAIL other-branch mutation")
        for row in bad:
            print(" ", row)
        for e in extra:
            print("  EXTRA", e)
        return 1
    print(f"VERIFY_OK other branches unchanged n={len(files)}")
    return 0


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "snapshot"
    if cmd == "snapshot":
        raise SystemExit(snapshot())
    if cmd == "verify":
        raise SystemExit(verify())
    print("usage: protect_other_branches.py snapshot|verify")
    raise SystemExit(2)
