"""Run FEM lifecycle + crash-safety TB (C-CODE-05). XSim if on PATH else Icarus.

Marker: FEM_COMPACTION_LOCAL_PASS (local, tested-behavior evidence only).
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RTL = ROOT / "rtl" / "native_ai" / "memory" / "fem_lifecycle.v"
TB = ROOT / "tb" / "learning" / "tb_fem_lifecycle.v"
VEC = ROOT / "tb" / "learning" / "vectors" / "fem" / "fem_expect.hex"
BUILD = ROOT / "tb" / "learning" / "build" / "fem"
TOP = "tb_fem_lifecycle"


def kv(s: str) -> str:
    return s


def run(cmd, cwd=None):
    exe = shutil.which(cmd[0]) or cmd[0]
    cmd = [exe] + list(cmd[1:])
    shell = False
    if os.name == "nt" and exe.lower().endswith((".bat", ".cmd")):
        # cmd.exe splits .bat arguments on '=' ; quote those so "NAME=value" reaches the tool intact
        cmd = " ".join(f'"{a}"' if ("=" in a or " " in a) else a for a in cmd)
        shell = True
    try:
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=180, shell=shell)
    except subprocess.TimeoutExpired as exc:
        return 124, f"TIMEOUT: {' '.join(cmd)}\n{exc.stdout or ''}"
    return proc.returncode, proc.stdout + proc.stderr


def main() -> int:
    use_xsim = shutil.which("xvlog") and shutil.which("xelab") and shutil.which("xsim")
    tool = "XSIM" if use_xsim else ("ICARUS" if shutil.which("iverilog") else None)
    if tool is None:
        print("FEM_COMPACTION_LOCAL_BLOCKED no simulator")
        return 2
    print(f"SIMULATOR={tool}", flush=True)
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True)
    if use_xsim:
        for cmd in (["xvlog", str(RTL), str(TB)], ["xelab", TOP, "-s", "snap"]):
            rc, log = run(cmd, cwd=BUILD)
            if rc:
                print("COMPILE_FAIL\n" + log); return 1
    else:
        rc, log = run(["iverilog", "-g2005", "-o", str(BUILD / "tb.vvp"), str(RTL), str(TB)])
        if rc:
            print("COMPILE_FAIL\n" + log); return 1
    # Windows +VEC=D:/... can be eaten at the first '=' by some shells (D fix). Keep the hex beside the snapshot.
    vec_arg = "fem_expect.hex"
    shutil.copyfile(VEC, BUILD / vec_arg)
    # pass 1: sync T2 model (t2_ready=1). pass 2: pseudo-random t2_ready stalls (D-INTEG-01); same expectations.
    ok = True
    for stall in (0, 1):
        if use_xsim:
            rc, log = run(["xsim", "snap", "-R", "-testplusarg", kv(f"VEC={vec_arg}"),
                           "-testplusarg", kv(f"STALL={stall}")], cwd=BUILD)
        else:
            rc, log = run(["vvp", "-n", str(BUILD / "tb.vvp"), f"+VEC={vec_arg}", f"+STALL={stall}"], cwd=BUILD)
        print(f"--- STALL={stall}")
        print("\n".join(l for l in log.splitlines() if l.strip() and "readmemh" not in l))
        ok = ok and ("FEM_COMPACTION_LOCAL_PASS" in log)
    print("FEM_COMPACTION_LOCAL_PASS_BOTH" if ok else "FEM_COMPACTION_LOCAL_FAIL_SOME")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
