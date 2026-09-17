import hashlib
from pathlib import Path
import sys

sys.path.insert(0, r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION")
from mailbox import Mailbox

coord = r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION"
mb = Mailbox(coord, "AGENT_D")

body = """TASK: D-M4-QUERY-RESULT-SHADOW
STATUS: CANDIDATE. PROGRAM=NO. NO PASS.

FE256_REFERENCE_FREEZE=YES
DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (freeze)
dedicated_engine_on_this_candidate=NO
COMMON_RUNTIME_FE256_STATUS=NOT_RUN
M2_STATUS=CANDIDATE (XSim/OOC only)
T2_MIG_STATUS=OPEN
FEM_PERSIST_STATUS=OPEN
ASTRA_BIND_STATUS=fail-closed SEARCH_INCOMPLETE only
RESOURCE_DELTA_SINCE_FREEZE=N/A (new candidate, not freeze overwrite)
GUARD_VIOLATION=NO
NEXT_MAIN_D_TASK=T2/MIG
FE256_DEVELOPMENT=CLOSED
D_MAIN_ROADMAP=RESUMED

EVIDENCE:
- XSim M4_QUERY_RESULT_SHADOW_XSIM_PASS hop1=122 finish_ns=199735 (not FE256 gold)
- UART M4_QUERY_RESULT_UART_SMOKE_XSIM_PASS 2/2 finish_ns=13881355 (115200, no tb_steer)
- route xc7a100t 100 MHz WNS=+0.555 WHS=+0.049 LUT=6421 FF=6277 RAMB36=20 RAMB18=2 DSP=8 nets=11387/11387 errors=0
- post_route.dcp sha256 f81b2e6582d0018c526d4b12e2a9a0ba3e28137c56124a6db5241d27450484b2
- freeze DCP 858d0e99... unchanged; old freeze b48b7c88... preserved
JSON: D:/FPGA/arty_d/m4_query_result_shadow/D_M4_QUERY_RESULT_SHADOW.json
B-CLASS 20260916T170724 M4 pack absorbed as CANDIDATE only.
"""

p_a = mb.send("AGENT_A", "D-M4-QUERY-RESULT-SHADOW architecture-drift note", body, priority="NORMAL")
p_b = mb.send("AGENT_B", "D-M4-QUERY-RESULT-SHADOW CANDIDATE no promote", body, priority="NORMAL")
print("sent_a", p_a)
print("sent_b", p_b)

# mark B M4 class read
for item in mb.check_inbox():
    msg = item.get("message") or {}
    subj = str(msg.get("subject") or "")
    if "D-M4-QUERY-RESULT-BIND" in subj:
        mb.mark_read(item["file"])
        print("read", item["file"])

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
for name in ["22_RTL_RISK_REGISTER.md", "23_HARDWARE_FACTS.md", "30_MILESTONE_ROADMAP.md", "33_IMPLEMENTATION_GUIDE.md"]:
    h = hashlib.sha256((root / name).read_bytes()).hexdigest()
    print(name, h[:16])
print("unread", mb.count_unread())
