import hashlib
import json
import sys
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
out_dir = Path(r"D:\FPGA\arty_d\m4_mig")
files = {
    "candidate_top": root / "rtl/native_ai/board/arty_a7_r2_top_m4_mig_candidate.sv",
    "query_result_bind": root / "rtl/native_ai/directory/query_result_bind.sv",
    "word_cdc32": root / "rtl/native_ai/board/word_cdc32.sv",
    "post_synth_dcp": out_dir / "post_synth.dcp",
    "post_route_dcp": out_dir / "post_route.dcp",
}
freeze = Path(r"D:\FPGA\arty_d\hold_r2\R2_FE256_R1_INTEGRATED_FREEZE\post_route.dcp")
old = Path(r"D:\FPGA\arty_d\hold_r2\R2_TOP_ROUTE_BASELINE_WHS_0P021\post_route.dcp")
mig_tx = Path(r"D:\FPGA\arty_d\mig_tx\post_route.dcp")
mig_uiclk = Path(r"D:\FPGA\arty_d\mig_uiclk\post_route.dcp")

out = {
    "task": "D-M4-MIG-CANDIDATE",
    "class": "CANDIDATE",
    "program": "NO",
    "fe256_engine_used": False,
    "dedicated_engine_on_this_candidate": False,
    "DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP": "YES",
    "mig0_instantiated": True,
    "calib_source": "mig0 init_calib_complete (IP, not board-measured)",
    "query_clock": "sys_clk_pin 100 MHz",
    "pack_fem_clock": "ui_clk",
    "xsim_this_top": False,
    "query_xsim_evidence": "M4_QUERY_RESULT_SHADOW_XSIM_PASS on fabric candidate",
    "synth": {"LUT": 11111, "FF": 10102, "RAMB36": 4, "RAMB18": 2, "DSP": 8, "WNS": 1.277, "WHS": -1.631},
    "route": {
        "LUT": 10609, "FF": 9773, "RAMB36": 4, "RAMB18": 2, "DSP": 8,
        "WNS": 0.233, "WHS": 0.016, "nets": "18686/18686", "routing_errors": 0,
        "worst_setup": "u_q/m2_r_reg -> theta_reg[19][15]", "logic_levels": 12,
    },
    "not_claimed": [
        "MIG_PASS", "TIMING_PASS", "BOARD_PASS", "FINAL_PASS",
        "ASTRA_PASS", "FE256_PASS", "M2_PASS", "FEM_PERSIST_PASS",
    ],
    "freeze_dcp_untouched": True,
    "mig_uiclk_untouched": True,
    "hashes": {},
}
for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()
for label, p in {
    "R2_FE256_R1_INTEGRATED_FREEZE": freeze,
    "R2_TOP_ROUTE_BASELINE_WHS_0P021": old,
    "mig_tx_post_route": mig_tx,
    "mig_uiclk_post_route": mig_uiclk,
}.items():
    out["hashes"][label] = hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else "MISSING"
(out_dir / "D_M4_MIG.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))

sys.path.insert(0, str(root / "_COORDINATION"))
from mailbox import Mailbox
mb = Mailbox(str(root / "_COORDINATION"), "AGENT_D")
body = f"""TASK: D-M4-MIG-CANDIDATE
STATUS: CANDIDATE. PROGRAM=NO. NO PASS.

FE256_REFERENCE_FREEZE=YES
DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (freeze)
dedicated_engine_on_this_candidate=NO
T2_MIG_STATUS=CANDIDATE (mig0 instantiated; calib=IP not board)
COMMON_RUNTIME_FE256_STATUS=NOT_RUN
FEM_PERSIST_STATUS=OPEN
ASTRA_BIND_STATUS=fail-closed SEARCH_INCOMPLETE
GUARD_VIOLATION=NO
NEXT_MAIN_D_TASK=FEM persist / Pack-ABI24 DUT compare

EVIDENCE:
- route WNS=+0.233 WHS=+0.016 LUT=10609 FF=9773 RAMB36=4 RAMB18=2 DSP=8 nets=18686/18686 errors=0
- post_route.dcp sha256 {out['hashes']['post_route_dcp']}
- freeze 858d0e99... match={out['hashes']['R2_FE256_R1_INTEGRATED_FREEZE'].startswith('858d0e99')}
JSON: D:/FPGA/arty_d/m4_mig/D_M4_MIG.json
"""
print("sent_a", mb.send("AGENT_A", "D-M4-MIG-CANDIDATE architecture-drift note", body, "NORMAL"))
print("sent_b", mb.send("AGENT_B", "D-M4-MIG-CANDIDATE CANDIDATE no promote", body, "NORMAL"))
for name in ["22_RTL_RISK_REGISTER.md", "23_HARDWARE_FACTS.md", "30_MILESTONE_ROADMAP.md", "33_IMPLEMENTATION_GUIDE.md"]:
    print(name, hashlib.sha256((root / name).read_bytes()).hexdigest()[:16])
