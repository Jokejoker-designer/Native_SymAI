import hashlib
import json
import sys
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
out_dir = Path(r"D:\FPGA\arty_d\m4_mig")
jpath = out_dir / "D_M4_MIG.json"
out = json.loads(jpath.read_text(encoding="utf-8"))
out["program"] = "YES"
out["programmed"] = True
out["program_auth"] = "OWNER PROGRAM=YES 2026-09-17"
out["jtag"] = {
    "target": "localhost:3121/xilinx_tcf/Digilent/210319BE776EA",
    "device": "xc7a100t_0",
    "serial": "210319BE776EA",
    "end_of_startup": "HIGH",
}
out["bitstream"]["programmed"] = True
out["not_claimed"] = list(dict.fromkeys(out.get("not_claimed", []) + [
    "BOARD_PASS", "PROGRAM_PASS", "MIG_PASS", "TIMING_PASS", "FINAL_PASS",
]))
jpath.write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")

sys.path.insert(0, str(root / "_COORDINATION"))
from mailbox import Mailbox
mb = Mailbox(str(root / "_COORDINATION"), "AGENT_D")
try:
    mb.mark_read("20260916T175631_AGENT_B_b-class_d-m4-mig-bitstream_no_program_no_d78810.json")
    print("marked_b_bitstream")
except Exception as e:
    print("mark_read", e)
body = f"""TASK: D-M4-MIG-PROGRAM
STATUS: PROGRAMMED. OWNER PROGRAM=YES. NO PASS.

FE256_REFERENCE_FREEZE=YES
DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (freeze)
COMMON_RUNTIME_FE256_STATUS=NOT_RUN
M2_STATUS=CANDIDATE
T2_MIG_STATUS=CANDIDATE (mig0 programmed; calib not board-measured)
FEM_PERSIST_STATUS=OPEN
ASTRA_BIND_STATUS=fail-closed SEARCH_INCOMPLETE
GUARD_VIOLATION=NO
NEXT_MAIN_D_TASK=FEM persist / UART board smoke

EVIDENCE:
- JTAG localhost:3121/xilinx_tcf/Digilent/210319BE776EA xc7a100t_0
- End of startup HIGH
- bit sha256 f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7
- D does not self-stamp PROGRAM_PASS
- NOT BOARD_PASS / MIG_PASS / TIMING_PASS
PROGRAM.txt: D:/FPGA/arty_d/m4_mig/PROGRAM.txt
JSON: D:/FPGA/arty_d/m4_mig/D_M4_MIG.json
"""
print("sent_a", mb.send("AGENT_A", "D-M4-MIG-PROGRAM programmed not BOARD_PASS", body, "HIGH"))
print("sent_b", mb.send("AGENT_B", "D-M4-MIG-PROGRAM CANDIDATE config only no promote", body, "HIGH"))
for name in ["22_RTL_RISK_REGISTER.md", "23_HARDWARE_FACTS.md", "30_MILESTONE_ROADMAP.md", "33_IMPLEMENTATION_GUIDE.md"]:
    print(name, hashlib.sha256((root / name).read_bytes()).hexdigest()[:16])
