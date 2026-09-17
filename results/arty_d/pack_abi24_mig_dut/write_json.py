import hashlib
import json
import sys
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
out_dir = Path(r"D:\FPGA\arty_d\pack_abi24_mig_dut")
files = {
    "pack_mig_bind": root / "rtl/native_ai/memory/pack_mig_bind.sv",
    "mig_ui32": root / "rtl/native_ai/memory/mig_ui32.sv",
    "mig_ui_bram": root / "rtl/native_ai/memory/mig_ui_bram.sv",
    "pack_loader": root / "rtl/native_ai/loader/pack_loader.sv",
    "dut_wrapper": root / "verification/pack_abi24/pack_abi24_mig_dut.sv",
    "tb": root / "tb/native_ai/loader/tb_pack_abi24_mig_dut.sv",
    "xsim_log": out_dir / "xsim" / "xsim.log",
}
freeze = Path(r"D:\FPGA\arty_d\hold_r2\R2_FE256_R1_INTEGRATED_FREEZE\post_route.dcp")
old = Path(r"D:\FPGA\arty_d\hold_r2\R2_TOP_ROUTE_BASELINE_WHS_0P021\post_route.dcp")

out = {
    "task": "D-PACK-ABI24-MIG-DUT",
    "class": "CANDIDATE",
    "program": "NO",
    "claim": "PACK_ABI24_MIG_DUT_XSIM_PASS",
    "cases": 24,
    "pass": 24,
    "fail": 0,
    "finish_ns": 21965,
    "dest": "mig_ui_bram dest-complete (not mig0, not board)",
    "b_tb_modified": False,
    "fe256_engine_used": False,
    "DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP": "YES",
    "not_claimed": [
        "PACK_ABI_24_24_PASS", "MIG_PASS", "BOARD_PASS", "FINAL_PASS",
        "TIMING_PASS", "FE256_PASS",
    ],
    "cases_sha256": "8807745328e766747f0c28861fd6405b6af7b1a8690a63e2474cdd2ba0ba51dd",
    "hashes": {},
}
for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()
for label, p in {
    "R2_FE256_R1_INTEGRATED_FREEZE": freeze,
    "R2_TOP_ROUTE_BASELINE_WHS_0P021": old,
}.items():
    out["hashes"][label] = hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else "MISSING"
(out_dir / "D_PACK_ABI24_MIG_DUT.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
lines = [f"{out['hashes'][k]}  {k}" for k in files]
(out_dir / "SHA256SUMS.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))

sys.path.insert(0, str(root / "_COORDINATION"))
from mailbox import Mailbox
mb = Mailbox(str(root / "_COORDINATION"), "AGENT_D")
try:
    mb.mark_read("20260916T174728_AGENT_B_b-class_d-m4-mig-candidate_no_promote_99678c.json")
    print("marked_b_class_m4_mig")
except Exception as e:
    print("mark_read", e)
body = f"""TASK: D-PACK-ABI24-MIG-DUT
STATUS: CANDIDATE. PROGRAM=NO. NO PASS.

FE256_REFERENCE_FREEZE=YES
DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (freeze)
COMMON_RUNTIME_FE256_STATUS=NOT_RUN
M2_STATUS=CANDIDATE (QueryRecord path; not M2_PASS)
T2_MIG_STATUS=CANDIDATE (mig0 on m4_mig top; this XSim uses mig_ui_bram)
FEM_PERSIST_STATUS=OPEN
ASTRA_BIND_STATUS=fail-closed SEARCH_INCOMPLETE
PACK_ABI24_STATUS=PACK_ABI24_MIG_DUT_XSIM_PASS 24/24 dest-complete; not PACK_ABI_24_24_PASS
RESOURCE_DELTA_SINCE_FREEZE=N/A (XSim only)
GUARD_VIOLATION=NO
NEXT_MAIN_D_TASK=bitstream prep (no PROGRAM) / FEM persist

EVIDENCE:
- PACK_ABI24_MIG_DUT_XSIM_PASS 24/24 finish 21965 ns
- DUT pack_mig_bind + mig_ui_bram; B TB unmodified
- dest-complete not FIFO-empty
JSON: D:/FPGA/arty_d/pack_abi24_mig_dut/D_PACK_ABI24_MIG_DUT.json
"""
print("sent_a", mb.send("AGENT_A", "D-PACK-ABI24-MIG-DUT architecture-drift note", body, "NORMAL"))
print("sent_b", mb.send("AGENT_B", "D-PACK-ABI24-MIG-DUT CANDIDATE no promote", body, "NORMAL"))
for name in ["22_RTL_RISK_REGISTER.md", "23_HARDWARE_FACTS.md", "30_MILESTONE_ROADMAP.md", "33_IMPLEMENTATION_GUIDE.md"]:
    print(name, hashlib.sha256((root / name).read_bytes()).hexdigest()[:16])
