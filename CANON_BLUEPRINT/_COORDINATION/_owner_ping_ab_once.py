"""One-shot OWNER ping for AGENT_A + AGENT_B. Safe to re-run when they go STALE."""
from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

from coord_util import configure_stdio, resolve_coordination_dir, safe_print
from mailbox import Mailbox

configure_stdio()
base = resolve_coordination_dir(".")
mb = Mailbox(str(base), "CHANGEBOT")
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

body_a = f"""OWNER DIRECT PING — {now}
Presence was STALE. When you stop / at next natural break, CONTINUE:

1) Startup + drain
   python _COORDINATION/agent_startup.py --agent-id AGENT_A --role "Architecture Lead"
   python _COORDINATION/mailbox.py AGENT_A check
   python _COORDINATION/changebot.py --pending AGENT_A

2) ACTION patches (must ACK)
   - CB_ARCHITECTURE_20260916T083021_ecbdd9  state=NOT_SEEN
     files: 00_INDEX.md, 20_GLOSSARY_AND_LOCKED_TERMS.md, READING_ORDER.md
     ACK: python _COORDINATION/mailbox.py AGENT_A ack-patch CB_ARCHITECTURE_20260916T083021_ecbdd9 APPLIED

3) Semantic backlog from C-CODE-07 CANDIDATE (not ChangeBot)
   - Close/publish row S11.12.3 after republish (C waiting_contract A)
   - A-ID-PROFILE-01 / A-C-14 already consumed by C

4) After processing
   python _COORDINATION/mailbox.py AGENT_A mark-read-all

Non-blocking: finish current task first, then run the steps above.
See also CONTINUE_HINT.txt / CONTINUE.cmd in your worktree.
"""

body_b = f"""OWNER DIRECT PING — {now}
Presence was STALE. When you stop / at next natural break, CONTINUE:

1) Startup + drain (unread was high)
   python _COORDINATION/agent_startup.py --agent-id AGENT_B --role "Verification Lead"
   python _COORDINATION/mailbox.py AGENT_B check
   python _COORDINATION/changebot.py --pending AGENT_B

2) ACTION/CRITICAL patches (must ACK)
   - CB_AUTHORITY_OR_CONTRACT_20260916T071241_aa1750  state=RECEIVED (CRITICAL)
     file: 31_VERIFICATION_AND_CAUSAL_TESTS.md
     ACK: python _COORDINATION/mailbox.py AGENT_B ack-patch CB_AUTHORITY_OR_CONTRACT_20260916T071241_aa1750 APPLIED
   - CB_ABI_VERIFICATION_20260916T074628_82dcef  state=NOT_SEEN
     file: 32_ACCEPTANCE_LADDER.md (+ related)
     ACK: python _COORDINATION/mailbox.py AGENT_B ack-patch CB_ABI_VERIFICATION_20260916T074628_82dcef APPLIED

3) Semantic backlog from C-CODE-07 CANDIDATE (B-owned)
   - Retarget R1 04.2 "24 significant bits" -> profile parameter (SPEAR_ID_ALIGNMENT / A-ID-PROFILE-01)
   - B-RUNTIME-LAW-01 already confirmed COMPATIBLE for QSTAR_FIX

4) After processing
   python _COORDINATION/mailbox.py AGENT_B mark-read-all

Non-blocking: finish current task first, then run the steps above.
See also CONTINUE_HINT.txt / CONTINUE.cmd in your worktree.
"""

pa = mb.send("AGENT_A", "OWNER_PING CONTINUE when idle", body_a, priority="HIGH")
pb = mb.send("AGENT_B", "OWNER_PING CONTINUE when idle", body_b, priority="HIGH")
safe_print(f"sent_A {pa}")
safe_print(f"sent_B {pb}")

continue_a = """AGENT_A — CONTINUE CHECKLIST (owner ping)
Use when you stop / between tasks. Soft cue — do not interrupt mid-edit.

1. python _COORDINATION/agent_startup.py --agent-id AGENT_A --role "Architecture Lead"
2. python _COORDINATION/mailbox.py AGENT_A check
3. python _COORDINATION/changebot.py --pending AGENT_A
4. ACK open ACTION:
   python _COORDINATION/mailbox.py AGENT_A ack-patch CB_ARCHITECTURE_20260916T083021_ecbdd9 APPLIED
5. Semantic: close/publish S11.12.3 after republish (C waiting)
6. python _COORDINATION/mailbox.py AGENT_A mark-read-all
"""

continue_b = """AGENT_B — CONTINUE CHECKLIST (owner ping)
Use when you stop / between tasks. Soft cue — do not interrupt mid-edit.

1. python _COORDINATION/agent_startup.py --agent-id AGENT_B --role "Verification Lead"
2. python _COORDINATION/mailbox.py AGENT_B check
3. python _COORDINATION/changebot.py --pending AGENT_B
4. ACK open ACTION/CRITICAL:
   python _COORDINATION/mailbox.py AGENT_B ack-patch CB_AUTHORITY_OR_CONTRACT_20260916T071241_aa1750 APPLIED
   python _COORDINATION/mailbox.py AGENT_B ack-patch CB_ABI_VERIFICATION_20260916T074628_82dcef APPLIED
5. Semantic: retarget R1 04.2 "24 significant bits" -> profile parameter
6. python _COORDINATION/mailbox.py AGENT_B mark-read-all
"""

cmd_a = """@echo off
REM OWNER: run when AGENT_A stops — drain + show pending (does not auto-ACK)
cd /d "%~dp0"
if exist "_COORDINATION\\mailbox.py" (
  python _COORDINATION\\agent_startup.py --agent-id AGENT_A --role "Architecture Lead"
  python _COORDINATION\\mailbox.py AGENT_A check
  python _COORDINATION\\changebot.py --pending AGENT_A
) else (
  set COORD=D:\\FPGA\\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\\CANON_BLUEPRINT\\_COORDINATION
  python "%COORD%\\agent_startup.py" --agent-id AGENT_A --role "Architecture Lead"
  python "%COORD%\\mailbox.py" AGENT_A check
  python "%COORD%\\changebot.py" --pending AGENT_A
)
echo.
echo Next: ACK ARCHITECTURE patch then mark-read-all. See CONTINUE_HINT.txt
pause
"""

cmd_b = """@echo off
REM OWNER: run when AGENT_B stops — drain + show pending (does not auto-ACK)
cd /d "%~dp0"
if exist "_COORDINATION\\mailbox.py" (
  python _COORDINATION\\agent_startup.py --agent-id AGENT_B --role "Verification Lead"
  python _COORDINATION\\mailbox.py AGENT_B check
  python _COORDINATION\\changebot.py --pending AGENT_B
) else (
  set COORD=D:\\FPGA\\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\\CANON_BLUEPRINT\\_COORDINATION
  python "%COORD%\\agent_startup.py" --agent-id AGENT_B --role "Verification Lead"
  python "%COORD%\\mailbox.py" AGENT_B check
  python "%COORD%\\changebot.py" --pending AGENT_B
)
echo.
echo Next: ACK AUTHORITY + ABI patches then mark-read-all. See CONTINUE_HINT.txt
pause
"""

wt_a = Path(r"d:\FPGA\NATIVE_AI\worktrees\AGENT_A")
wt_b = Path(r"d:\FPGA\NATIVE_AI\worktrees\AGENT_B")
mb_a = Path(base) / "mailbox" / "AGENT_A"
mb_b = Path(base) / "mailbox" / "AGENT_B"

for root in (wt_a, mb_a):
    root.mkdir(parents=True, exist_ok=True)
    (root / "CONTINUE_HINT.txt").write_text(continue_a, encoding="utf-8", newline="\n")
(wt_a / "CONTINUE.cmd").write_text(cmd_a, encoding="utf-8", newline="\r\n")

for root in (wt_b, mb_b):
    root.mkdir(parents=True, exist_ok=True)
    (root / "CONTINUE_HINT.txt").write_text(continue_b, encoding="utf-8", newline="\n")
(wt_b / "CONTINUE.cmd").write_text(cmd_b, encoding="utf-8", newline="\r\n")

owner = Path(base) / "OWNER_PING_AB.cmd"
owner.write_text(
    """@echo off
REM Re-ping A+B when they go idle/STALE
cd /d "%~dp0"
python changebot.py --soft-ping
python _owner_ping_ab_once.py
python live_agent_coverage.py --once
pause
""",
    encoding="utf-8",
    newline="\r\n",
)
safe_print("wrote CONTINUE_HINT + CONTINUE.cmd + OWNER_PING_AB.cmd")
