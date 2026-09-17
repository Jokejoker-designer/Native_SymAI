"""Run all Q* op-script vectors against qstar_select.v (C-CODE-04 runner).

XSim (xvlog/xelab/xsim) when on PATH, else Icarus (iverilog/vvp).
Aggregate marker: TB_QSTAR_LOCAL_PASS (local, tested-behavior evidence only).
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RTL = ROOT / "rtl" / "native_ai" / "strategy" / "qstar_select.v"
TB = ROOT / "tb" / "learning" / "tb_qstar_select.v"
VEC_DIR = ROOT / "tb" / "learning" / "vectors" / "qstar"
BUILD = ROOT / "tb" / "learning" / "build" / "qstar"
TOP = "tb_qstar_select"
SIM_TIMEOUT_S = 180


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


def compile_icarus() -> str:
    out = BUILD / "tb.vvp"
    rc, log = run(["iverilog", "-g2005", "-o", str(out), str(RTL), str(TB)])
    return "" if rc == 0 else log


def sim_icarus(vec: Path) -> str:
    return run(["vvp", "-n", str(BUILD / "tb.vvp"), f"+VEC={vec.as_posix()}"])[1]


def compile_xsim() -> str:
    for cmd in (["xvlog", str(RTL), str(TB)], ["xelab", TOP, "-s", "snap"]):
        rc, log = run(cmd, cwd=BUILD)
        if rc != 0:
            return log
    return ""


def sim_xsim(vec: Path) -> str:
    return run(["xsim", "snap", "-R", "-testplusarg", kv(f"VEC={vec.as_posix()}")], cwd=BUILD)[1]


def main() -> int:
    manifest = json.loads((VEC_DIR / "manifest.json").read_text())
    use_xsim = shutil.which("xvlog") and shutil.which("xelab") and shutil.which("xsim")
    tool = "XSIM" if use_xsim else ("ICARUS" if shutil.which("iverilog") else None)
    if tool is None:
        print("TB_QSTAR_LOCAL_BLOCKED no simulator (need xsim or iverilog)")
        return 2
    print(f"SIMULATOR={tool}", flush=True)
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True)
    err = (compile_xsim if use_xsim else compile_icarus)()
    if err:
        print("COMPILE_FAIL\n" + err)
        print("TB_QSTAR_LOCAL_FAIL")
        return 1
    passed = failed = 0
    for case in manifest:
        log = (sim_xsim if use_xsim else sim_icarus)(VEC_DIR / f"{case['name']}.hex")
        ok = "TB_QSTAR_CASE_PASS" in log
        passed += ok
        failed += (not ok)
        print(f"  {'PASS' if ok else 'FAIL'} {case['name']} (ops={case['n_ops']})", flush=True)
        if not ok:
            body = "\n".join(l for l in log.splitlines() if l.strip() and "readmemh" not in l)
            print("    " + body[:6000].replace("\n", "\n    "))
    print(f"cases={len(manifest)} pass={passed} fail={failed} tool={tool}")
    if failed == 0:
        print(f"TB_QSTAR_LOCAL_PASS ({tool})")
        return 0
    print("TB_QSTAR_LOCAL_FAIL")
    return 1


if __name__ == "__main__":
    sys.exit(main())
