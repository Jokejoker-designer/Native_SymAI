import hashlib
import json
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
out_dir = Path(r"D:\FPGA\arty_d\m4_query_result_shadow")
freeze = Path(r"D:\FPGA\arty_d\hold_r2\R2_FE256_R1_INTEGRATED_FREEZE")
old = Path(r"D:\FPGA\arty_d\hold_r2\R2_TOP_ROUTE_BASELINE_WHS_0P021")
files = {
    "candidate_top": root / "rtl/native_ai/board/arty_a7_r2_top_m4_query_result_candidate.sv",
    "query_result_bind": root / "rtl/native_ai/directory/query_result_bind.sv",
    "query_walk_bind": root / "rtl/native_ai/directory/query_walk_bind.sv",
    "tb_shadow": root / "tb/native_ai/board/tb_m4_query_result_shadow_bind.sv",
    "tb_uart": root / "tb/native_ai/board/tb_m4_query_result_uart_smoke.sv",
    "uart_fe256_host": root / "rtl/native_ai/board/uart_fe256_host.sv",
    "post_synth_dcp": out_dir / "post_synth.dcp",
    "post_route_dcp": out_dir / "post_route.dcp",
}
out = {
    "task": "D-M4-QUERY-RESULT-SHADOW",
    "class": "CANDIDATE",
    "program": "NO",
    "fe256_engine_used": False,
    "dedicated_engine_on_this_candidate": False,
    "DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP": "YES",
    "freeze_note": "R2_FE256_R1_INTEGRATED_FREEZE still has dedicated FE256; this candidate does not",
    "astra_status_law": "fail-closed: never ANSWER/UNKNOWN; CRC/magic->0x06+0x55; else 0x04+0x20 PARTIAL",
    "xsim": {
        "banner": "M4_QUERY_RESULT_SHADOW_XSIM_PASS",
        "hop1": 122,
        "finish_ns": 199735,
        "fe256_gold_used": False,
    },
    "uart_smoke": {
        "banner": "M4_QUERY_RESULT_UART_SMOKE_XSIM_PASS",
        "cases": "2/2",
        "finish_ns": 13881355,
        "baud": 115200,
        "tb_steer": False,
    },
    "synth": {
        "LUT": 6590,
        "FF": 6565,
        "RAMB36": 20,
        "RAMB18": 2,
        "DSP": 8,
        "WNS": 1.548,
        "WHS": 0.070,
    },
    "route": {
        "LUT": 6421,
        "FF": 6277,
        "RAMB36": 20,
        "RAMB18": 2,
        "DSP": 8,
        "WNS": 0.555,
        "WHS": 0.049,
        "nets": "11387/11387",
        "routing_errors": 0,
        "worst_setup": "u_spear/spear/feat_r_reg[22] -> sl_seq_reg[2][0]/CE",
        "logic_levels": 7,
    },
    "not_claimed": [
        "ASTRA_PASS",
        "M2_PASS",
        "M3_PASS",
        "FE256_PASS",
        "TIMING_PASS",
        "MIG_PASS",
        "BOARD_PASS",
        "FINAL_PASS"
    ],
    "freeze_dcp_untouched": True,
    "hashes": {},
}
for k, p in files.items():
    out["hashes"][k] = hashlib.sha256(p.read_bytes()).hexdigest()
for label, p in {
    "R2_FE256_R1_INTEGRATED_FREEZE": freeze / "post_route.dcp",
    "R2_TOP_ROUTE_BASELINE_WHS_0P021": old / "post_route.dcp",
}.items():
    if p.exists():
        out["hashes"][label] = hashlib.sha256(p.read_bytes()).hexdigest()
    else:
        out["hashes"][label] = "MISSING_THIS_RUN"
(out_dir / "D_M4_QUERY_RESULT_SHADOW.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps(out["hashes"], indent=2))
print("freeze_exists", (freeze / "post_route.dcp").exists(), (old / "post_route.dcp").exists())
print("candidate_dcp", (out_dir / "post_route.dcp").exists())
