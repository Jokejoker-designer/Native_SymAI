import hashlib
import json
import sys
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
out_dir = Path(r"D:\FPGA\arty_d\m4_mig")
jpath = out_dir / "D_M4_MIG.json"
out = json.loads(jpath.read_text(encoding="utf-8"))
bit = out_dir / "arty_a7_r2_top_m4_mig_candidate.bit"
dcp = out_dir / "post_route.dcp"
freeze = Path(r"D:\FPGA\arty_d\hold_r2\R2_FE256_R1_INTEGRATED_FREEZE\post_route.dcp")
old = Path(r"D:\FPGA\arty_d\hold_r2\R2_TOP_ROUTE_BASELINE_WHS_0P021\post_route.dcp")
mig_tx = Path(r"D:\FPGA\arty_d\mig_tx\post_route.dcp")
mig_uiclk = Path(r"D:\FPGA\arty_d\mig_uiclk\post_route.dcp")

out["bitstream"] = {
    "written": True,
    "programmed": False,
    "program": "NO",
    "path": str(bit),
    "bytes": bit.stat().st_size,
    "sha256": hashlib.sha256(bit.read_bytes()).hexdigest(),
    "drc_errors": 0,
    "tcl": "vivado/tcl/27_bit_m4_mig.tcl",
}
out["hashes"]["bitstream"] = out["bitstream"]["sha256"]
out["hashes"]["post_route_dcp"] = hashlib.sha256(dcp.read_bytes()).hexdigest()
out["hashes"]["R2_FE256_R1_INTEGRATED_FREEZE"] = hashlib.sha256(freeze.read_bytes()).hexdigest()
out["hashes"]["R2_TOP_ROUTE_BASELINE_WHS_0P021"] = hashlib.sha256(old.read_bytes()).hexdigest()
out["hashes"]["mig_tx_post_route"] = hashlib.sha256(mig_tx.read_bytes()).hexdigest()
out["hashes"]["mig_uiclk_post_route"] = hashlib.sha256(mig_uiclk.read_bytes()).hexdigest()
if "BOARD_PASS" not in out["not_claimed"]:
    out["not_claimed"].append("BOARD_PASS")
jpath.write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print("bit", out["bitstream"]["sha256"], out["bitstream"]["bytes"])
print("freeze_ok", out["hashes"]["R2_FE256_R1_INTEGRATED_FREEZE"].startswith("858d0e99"))
print("dcp_ok", out["hashes"]["post_route_dcp"].startswith("91c9f084"))

sys.path.insert(0, str(root / "_COORDINATION"))
from mailbox import Mailbox
mb = Mailbox(str(root / "_COORDINATION"), "AGENT_D")
body = f"""TASK: D-M4-MIG-BITSTREAM
STATUS: CANDIDATE. PROGRAM=NO. NO PASS. NOT PROGRAMMED.

FE256_REFERENCE_FREEZE=YES
DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (freeze)
COMMON_RUNTIME_FE256_STATUS=NOT_RUN
M2_STATUS=CANDIDATE
T2_MIG_STATUS=CANDIDATE (mig0 + bitstream written; not MIG_PASS)
FEM_PERSIST_STATUS=OPEN
ASTRA_BIND_STATUS=fail-closed SEARCH_INCOMPLETE
PACK_ABI24_STATUS=PACK_ABI24_MIG_DUT_XSIM_PASS 24/24 dest-complete; not PACK_ABI_24_24_PASS
RESOURCE_DELTA_SINCE_FREEZE=N/A (candidate bit, freeze DCP untouched)
GUARD_VIOLATION=NO
NEXT_MAIN_D_TASK=FEM persist

EVIDENCE:
- write_bitstream DRC 0 Errors; Bitgen Completed Successfully
- bit 2003005 B sha256 {out['bitstream']['sha256']}
- source DCP {out['hashes']['post_route_dcp']}
- freeze 858d0e99... match={out['hashes']['R2_FE256_R1_INTEGRATED_FREEZE'].startswith('858d0e99')}
JSON: D:/FPGA/arty_d/m4_mig/D_M4_MIG.json
"""
print("sent_a", mb.send("AGENT_A", "D-M4-MIG-BITSTREAM architecture-drift note", body, "NORMAL"))
print("sent_b", mb.send("AGENT_B", "D-M4-MIG-BITSTREAM CANDIDATE no program no promote", body, "NORMAL"))
for name in ["22_RTL_RISK_REGISTER.md", "23_HARDWARE_FACTS.md", "30_MILESTONE_ROADMAP.md", "33_IMPLEMENTATION_GUIDE.md"]:
    print(name, hashlib.sha256((root / name).read_bytes()).hexdigest()[:16])
