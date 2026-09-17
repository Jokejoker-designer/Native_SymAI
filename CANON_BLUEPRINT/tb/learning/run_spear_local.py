"""Run all SPEAR vector cases against spear_rank.v (C-CODE-02/04 runner).

Uses XSim (xvlog/xelab/xsim) when on PATH, else Icarus Verilog (iverilog/vvp).
Aggregate marker: TB_SPEAR_LOCAL_PASS  (local, tested-behavior evidence only).
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RTL = ROOT / "rtl" / "native_ai" / "strategy" / "spear_rank.v"
TB = ROOT / "tb" / "learning" / "tb_spear_rank.v"
VEC_DIR = ROOT / "tb" / "learning" / "vectors" / "spear"
BUILD = ROOT / "tb" / "learning" / "build" / "spear"


SIM_TIMEOUT_S = 120


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
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=SIM_TIMEOUT_S, shell=shell)
    except subprocess.TimeoutExpired as exc:
        return 124, f"TIMEOUT after {SIM_TIMEOUT_S}s: {' '.join(cmd)}\n{exc.stdout or ''}"
    return proc.returncode, proc.stdout + proc.stderr


def sim_icarus(acc_w: int, shift: int, vec: Path) -> str:
    BUILD.mkdir(parents=True, exist_ok=True)
    out = BUILD / f"tb_a{acc_w}_s{shift}.vvp"
    if not out.exists():
        rc, log = run(["iverilog", "-g2005", "-o", str(out),
                       f"-Ptb_spear_rank.ACC_W={acc_w}", f"-Ptb_spear_rank.SHIFT={shift}",
                       str(RTL), str(TB)])
        if rc != 0:
            return "COMPILE_FAIL\n" + log
    rc, log = run(["vvp", "-n", str(out), f"+VEC={vec.as_posix()}"])
    return log


def sim_xsim(acc_w: int, shift: int, vec: Path) -> str:
    wd = BUILD / f"xsim_a{acc_w}_s{shift}"
    wd.mkdir(parents=True, exist_ok=True)
    snap = f"snap_a{acc_w}_s{shift}"
    if not (wd / "xsim.dir" / snap).exists():
        for cmd in (["xvlog", str(RTL), str(TB)],
                    ["xelab", "tb_spear_rank", "-s", snap,
                     "-generic_top", kv(f"ACC_W={acc_w}"), "-generic_top", kv(f"SHIFT={shift}")]):
            rc, log = run(cmd, cwd=wd)
            if rc != 0:
                return "COMPILE_FAIL\n" + log
    rc, log = run(["xsim", snap, "-R", "-testplusarg", kv(f"VEC={vec.as_posix()}")], cwd=wd)
    return log


def main() -> int:
    manifest = json.loads((VEC_DIR / "manifest.json").read_text())
    use_xsim = shutil.which("xvlog") and shutil.which("xelab") and shutil.which("xsim")
    tool = "XSIM" if use_xsim else ("ICARUS" if shutil.which("iverilog") else None)
    if tool is None:
        print("TB_SPEAR_LOCAL_BLOCKED no simulator (need xsim or iverilog)")
        return 2
    print(f"SIMULATOR={tool}", flush=True)
    if BUILD.exists():
        shutil.rmtree(BUILD)
    passed = failed = 0
    for case in manifest:
        vec = VEC_DIR / f"{case['name']}.hex"
        log = (sim_xsim if use_xsim else sim_icarus)(case["acc_w"], case["shift"], vec)
        ok = "TB_SPEAR_CASE_PASS" in log
        passed += ok
        failed += (not ok)
        print(f"  {'PASS' if ok else 'FAIL'} {case['name']}", flush=True)
        if not ok:
            print("    " + "\n    ".join(l for l in log.splitlines() if l.strip())[:4000])
    print(f"cases={len(manifest)} pass={passed} fail={failed} tool={tool}")
    if failed == 0:
        print(f"TB_SPEAR_LOCAL_PASS ({tool})")
        return 0
    print("TB_SPEAR_LOCAL_FAIL")
    return 1


if __name__ == "__main__":
    sys.exit(main())
