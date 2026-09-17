import hashlib
import json
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
ooc = Path(r"D:\FPGA\arty_d\m2_query_post_ooc")

files = {
    "query_posting_bind": root / "rtl/native_ai/directory/query_posting_bind.sv",
    "exact_directory": root / "rtl/native_ai/directory/exact_directory.sv",
    "posting_walk": root / "rtl/native_ai/directory/posting_walk.sv",
    "post_synth_dcp": ooc / "post_synth.dcp",
    "post_route.dcp": ooc / "post_route.dcp",
}

out = {
    "task": "D-M2-QUERY-POST-OOC",
    "class": "CANDIDATE",
    "program": "NO",
    "part": "xc7a100tcsg324-1",
    "clock_ns": 10.0,
    "fe256_engine_used": False,
    "xsim": {
        "M2_DIR_XSIM_PASS": {"hit": 235, "miss_ok": 4, "finish_ns": 578335},
        "M2_POST_XSIM_PASS": {"rows": 235, "finish_ns": 1139735},
        "M2_QUERY_POST_XSIM_PASS": {"rows": 235, "finish_ns": 1153925},
        "M3_WALK_XSIM_PASS": {"hop": 1, "finish_ns": 191065},
    },
    "ooc_synth": {
        "LUT": 496,
        "FF": 617,
        "RAMB36": 4,
        "RAMB18": 1,
        "DSP": 0,
        "WNS": 2.945,
        "WHS": 0.256,
        "levels": 7,
    },
    "ooc_route": {
        "LUT": 492,
        "FF": 620,
        "RAMB36": 4,
        "RAMB18": 1,
        "Block_RAM_Tile": 4.5,
        "DSP": 0,
        "WNS": 0.935,
        "WHS": 0.124,
        "TNS": 0.0,
        "THS": 0.0,
        "nets_routed": "1105/1105",
        "routing_errors": 0,
        "levels": 8,
        "worst": "qb_reg[9][4] -> cnt_reg[10]/CE",
    },
    "not_claimed": [
        "M2_PASS",
        "FE256_PASS",
        "TIMING_PASS",
        "MIG_PASS",
        "BOARD_PASS",
        "FINAL_PASS",
    ],
    "freeze_dcp_untouched": True,
    "hashes": {},
}

for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()

(ooc / "D_M2_QUERY_POST_OOC.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))
