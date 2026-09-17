"""Copy mailbox lifecycle scripts, cmds, and Cursor rule into A/B/C/D worktrees."""
from __future__ import annotations

import shutil
from pathlib import Path

from coord_util import configure_stdio, resolve_coordination_dir, safe_print

configure_stdio()

AGENTS = ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D")
COPY_NAMES = (
    "mbox_lifecycle.py",
    "mailbox_cycle.py",
    "owner_wake.py",
    "agent_chat_roster.json",
    "OWNER_WAKE.cmd",
    "prompts/MBOX_LIFECYCLE_R1.md",
)
RULE_REL = Path(".cursor") / "rules" / "mbox-lifecycle.mdc"


def _cmd(agent: str, phase: str) -> str:
    return (
        "@echo off\r\n"
        "cd /d \"%~dp0\"\r\n"
        "if exist \"_COORDINATION\\mailbox_cycle.py\" (\r\n"
        f"  python _COORDINATION\\mailbox_cycle.py {agent} {phase}\r\n"
        ") else (\r\n"
        "  set COORD=D:\\FPGA\\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\\CANON_BLUEPRINT\\_COORDINATION\r\n"
        f"  python \"%COORD%\\mailbox_cycle.py\" {agent} {phase}\r\n"
        ")\r\n"
    )


def main() -> int:
    src = resolve_coordination_dir(Path(__file__).resolve().parent)
    package_root = src.parent
    rule_src = package_root / RULE_REL
    wt_root = Path(r"d:\FPGA\NATIVE_AI\worktrees")
    copied = 0
    for agent in AGENTS:
        wt = wt_root / agent
        if not wt.is_dir():
            safe_print(f"skip missing {wt}")
            continue
        dest_coord = wt / "_COORDINATION"
        dest_coord.mkdir(parents=True, exist_ok=True)
        (dest_coord / "prompts").mkdir(parents=True, exist_ok=True)
        for name in COPY_NAMES:
            s = src / name
            d = dest_coord / name
            if not s.exists():
                continue
            d.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(s, d)
            copied += 1
        (wt / "CHECK_MAILBOX.cmd").write_text(_cmd(agent, "start"), encoding="utf-8")
        (wt / "STOP_CHECK.cmd").write_text(_cmd(agent, "stop"), encoding="utf-8")
        if rule_src.exists():
            dest_rule = wt / RULE_REL
            dest_rule.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(rule_src, dest_rule)
            copied += 1
        safe_print(f"installed {agent} -> {wt}")
    safe_print(f"copied_files={copied}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
