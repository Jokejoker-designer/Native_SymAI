import hashlib
import json
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
ooc = Path(r"D:\FPGA\arty_d\m3_query_walk_ooc")

files = {
    "query_walk_bind": root / "rtl/native_ai/directory/query_walk_bind.sv",
    "tb_query_walk_bind": root / "tb/native_ai/directory/tb_query_walk_bind.sv",
    "bounded_walk": root / "rtl/native_ai/directory/bounded_walk.sv",
    "post_synth_dcp": ooc / "post_synth.dcp",
    "post_route_dcp": ooc / "post_route.dcp",
}

out = {
    "task": "D-M3-QUERY-WALK-BIND",
    "class": "CANDIDATE",
    "program": "NO",
    "part": "xc7a100tcsg324-1",
    "clock_ns": 10.0,
    "fe256_engine_used": False,
    "xsim": {
        "banner": "M3_QUERY_WALK_XSIM_PASS",
        "hop1": 122,
        "finish_ns": 194855,
    },
    "query_meta_packs": {
        "want_rev": "query_meta[10]",
        "hop_budget": "query_meta[8:5]",
        "class": "CANDIDATE",
    },
    "ooc_synth": {"LUT": 505, "FF": 624, "RAMB36": 4, "RAMB18": 1, "DSP": 0, "WNS": 2.955, "WHS": 0.256},
    "ooc_route": {
        "LUT": 500,
        "FF": 629,
        "RAMB36": 4,
        "RAMB18": 1,
        "DSP": 0,
        "WNS": 1.899,
        "WHS": 0.132,
        "TNS": 0.0,
        "THS": 0.0,
        "nets_routed": "1167/1167",
        "routing_errors": 0,
        "levels": 8,
        "worst": "qb_reg[10][1] -> hops_i_reg[1]/CE",
    },
    "not_claimed": ["M3_PASS", "M2_PASS", "FE256_PASS", "TIMING_PASS", "MIG_PASS", "BOARD_PASS", "FINAL_PASS"],
    "freeze_dcp_untouched": True,
    "hashes": {},
}

for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()

(ooc / "D_M3_QUERY_WALK.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))
