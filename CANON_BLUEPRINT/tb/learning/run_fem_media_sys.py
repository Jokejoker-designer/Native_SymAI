"""C FEM lifecycle over dest-complete media. Not FEM_PERSIST_PASS."""
from __future__ import annotations
import os, shutil, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RTL = [
    ROOT / "rtl" / "native_ai" / "memory" / "fem_lifecycle.v",
    ROOT / "rtl" / "native_ai" / "memory" / "fem_media_bridge.v",
    ROOT / "rtl" / "native_ai" / "memory" / "fem_t2_adapter.v",
    ROOT / "rtl" / "native_ai" / "memory" / "fem_t2_ce.v",
    ROOT / "rtl" / "native_ai" / "memory" / "fem_media_sys.v",
]
TB = ROOT / "tb" / "learning" / "tb_fem_media_sys.v"
BUILD = ROOT / "tb" / "learning" / "build" / "fem_media_sys"
TOP = "tb_fem_media_sys"
MARK = "FEM_MEDIA_SYS_XSIM_PASS"


def run(cmd, cwd=None):
    exe = shutil.which(cmd[0]) or cmd[0]
    cmd = [exe] + list(cmd[1:])
    shell = False
    if os.name == "nt" and str(exe).lower().endswith((".bat", ".cmd")):
        cmd = " ".join(f'"{a}"' if ("=" in a or " " in a) else a for a in cmd)
        shell = True
    proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=240, shell=shell)
    return proc.returncode, proc.stdout + proc.stderr


def main() -> int:
    BUILD.mkdir(parents=True, exist_ok=True)
    print("SIMULATOR=XSIM", flush=True)
    srcs = [str(p) for p in RTL] + [str(TB)]
    for cmd in (["xvlog"] + srcs, ["xelab", TOP, "-s", "snap_ms"]):
        rc, log = run(cmd, cwd=BUILD)
        if rc:
            print("COMPILE_FAIL\n" + log)
            return 1
    (BUILD / "run_all.tcl").write_text("run -all\nexit\n", encoding="ascii")
    rc, log = run(["xsim", "snap_ms", "-tclbatch", "run_all.tcl"], cwd=BUILD)
    print(log)
    return 0 if MARK in log else 1


if __name__ == "__main__":
    sys.exit(main())
