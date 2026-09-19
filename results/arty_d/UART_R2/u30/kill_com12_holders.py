"""Kill GOAL_M1 / probe processes holding COM12. Do not kill this interpreter."""
from __future__ import annotations

import os
import subprocess
import sys

NEEDLES = (
    "probe_pack24_ack4.py",
    "probe_uart_m1_two_gen.py",
    "goal_m1_ack4",
    "u28_campaign.py",
    "u25_campaign.py",
    "u26_campaign.py",
    "u24_campaign.py",
)


def main() -> int:
    me = os.getpid()
    out = subprocess.run(
        ["wmic", "process", "get", "ProcessId,CommandLine"],
        capture_output=True,
        text=True,
        errors="replace",
    )
    killed = []
    for line in out.stdout.splitlines():
        low = line.lower()
        if not any(n.lower() in low for n in NEEDLES):
            continue
        parts = line.strip().rsplit(None, 1)
        if len(parts) < 2 or not parts[-1].isdigit():
            continue
        pid = int(parts[-1])
        if pid == me:
            continue
        subprocess.run(["taskkill", "/F", "/PID", str(pid)], capture_output=True)
        killed.append(pid)
        print("KILLED", pid, line.strip()[:180])
    print("KILL_DONE", killed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
