import hashlib
import json
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
ooc = Path(r"D:\FPGA\arty_d\m4_query_result_ooc")
files = {
    "query_result_bind": root / "rtl/native_ai/directory/query_result_bind.sv",
    "tb_query_result_bind": root / "tb/native_ai/directory/tb_query_result_bind.sv",
    "post_synth_dcp": ooc / "post_synth.dcp",
    "post_route_dcp": ooc / "post_route.dcp",
}
out = {
    "task": "D-M4-QUERY-RESULT-BIND",
    "class": "CANDIDATE",
    "program": "NO",
    "fe256_engine_used": False,
    "astra_status_law": "fail-closed: never ANSWER/UNKNOWN; CRC/magic->0x06+0x55; else 0x04+0x20 PARTIAL",
    "q_ready": "implemented (IDLE)",
    "s_ready": "tied 1 (no extra stream this slice)",
    "xsim": {"banner": "M4_QUERY_RESULT_XSIM_PASS", "hop1": 122, "finish_ns": 198455},
    "ooc_synth": {"LUT": 564, "FF": 893, "RAMB36": 4, "RAMB18": 1, "DSP": 0, "WNS": 2.969, "WHS": 0.256},
    "ooc_route": {
        "LUT": 558, "FF": 896, "RAMB36": 4, "RAMB18": 1, "DSP": 0,
        "WNS": 1.203, "WHS": 0.135, "nets": "1484/1484", "routing_errors": 0,
    },
    "not_claimed": ["ASTRA_PASS", "M3_PASS", "FE256_PASS", "TIMING_PASS", "BOARD_PASS", "FINAL_PASS"],
    "freeze_dcp_untouched": True,
    "hashes": {},
}
for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()
(ooc / "D_M4_QUERY_RESULT.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))
