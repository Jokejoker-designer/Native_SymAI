"""Notify A/B/OWNER of Pack board SEQ+ISO raw results. No PASS stamp."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(
    0,
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\_COORDINATION",
)
from mailbox import Mailbox

coord = (
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\_COORDINATION"
)
root = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT"
)
mig = Path(r"D:\FPGA\arty_d\m4_mig")

seq = json.loads((mig / "D_PACK_BOARD_SEQ.json").read_text(encoding="utf-8"))
iso = json.loads((mig / "D_PACK_BOARD_ISO.json").read_text(encoding="utf-8"))
iso_txt = (mig / "UART_PACK24_ISO_BOARD.txt").read_text(encoding="utf-8")
seq_txt = (mig / "UART_PACK24_BOARD.txt").read_text(encoding="utf-8")

iso_lines = [ln for ln in iso_txt.splitlines() if ln.startswith("PA24-")]
seq_lines = [ln for ln in seq_txt.splitlines() if ln.startswith("PA24-")]

body = f"""TASK: D-PACK-BOARD-SEQ-01 + D-PACK-BOARD-ISO-01
STATUS: CANDIDATE. NO PASS. D does not stamp PACK_ABI_24_24_PASS.
B classifies raw ACK/NAK vs immutable TSV.

FE256_DEVELOPMENT=CLOSED
FEM_PERSIST=DEFERRED (owner: close Pack board evidence first)
NEXT_MAIN_D_TASK=await B classify; FEM persist after Pack board closed
GUARD_VIOLATION=NO
PROGRAM=YES (owner 2026-09-17)
bit_sha256=f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7
JTAG=210319BE776EA xc7a100t_0
UART=COM12 115200 8N1 FTDI 210319BE776EB
expect=CANON_BLUEPRINT/verification/pack_abi24/out/pack_abi24_expect.tsv

D-PACK-BOARD-SEQ-01:
CLASS={seq.get("class")}
isolated_reset=false reprogram_count=1
pass={seq.get("pass")} fail={seq.get("fail")}/24
first_divergence={seq.get("first_divergence")}
log=D:/FPGA/arty_d/m4_mig/UART_PACK24_BOARD.txt
RAW_SEQ:
{chr(10).join(seq_lines)}

D-PACK-BOARD-ISO-01:
CLASS={iso.get("class")}
isolated_reset=true 1 reprogram per case
pass={iso.get("pass")} fail={iso.get("fail")}/24
log=D:/FPGA/arty_d/m4_mig/UART_PACK24_ISO_BOARD.txt
jsonl=D:/FPGA/arty_d/m4_mig/UART_PACK24_ISO_BOARD.jsonl
json=D:/FPGA/arty_d/m4_mig/D_PACK_BOARD_ISO.json
RAW_ISO:
{chr(10).join(iso_lines)}

NOT CLAIMED: PACK_ABI_24_24_PASS BOARD_PASS MIG_PASS PROGRAM_PASS TIMING_PASS FEM_PERSIST_PASS
Abort settle1 (not official): V-01/V-02 BAD_MAGIC V-03 SENTINEL at POST_PROG=1s; discarded.
Official ISO uses POST_PROG=5s + DTR/RTS off + RX drain.
"""

mb = Mailbox(coord, "AGENT_D")
p_b = mb.send(
    "AGENT_B",
    "D-PACK-BOARD SEQ+ISO raw ACK/NAK for B classify",
    body,
    priority="HIGH",
)
p_a = mb.send(
    "AGENT_A",
    "D-PACK-BOARD-SEQ-01 / ISO-01 architecture-drift note",
    body,
    priority="NORMAL",
)
p_o = mb.send(
    "OWNER",
    "D-PACK-BOARD SEQ+ISO CANDIDATE no PASS",
    body,
    priority="NORMAL",
)
print("sent_b", p_b)
print("sent_a", p_a)
print("sent_o", p_o)

for name in [
    "22_RTL_RISK_REGISTER.md",
    "23_HARDWARE_FACTS.md",
    "30_MILESTONE_ROADMAP.md",
    "33_IMPLEMENTATION_GUIDE.md",
]:
    h = hashlib.sha256((root / name).read_bytes()).hexdigest()
    print(name, h[:16], h)
print("unread", mb.count_unread())
