import hashlib
import json
from pathlib import Path

root = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")

files = {
    "query_posting_bind": root / "rtl/native_ai/directory/query_posting_bind.sv",
    "tb_query_posting_bind": root / "tb/native_ai/directory/tb_query_posting_bind.sv",
    "posting_walk": root / "rtl/native_ai/directory/posting_walk.sv",
    "exact_directory": root / "rtl/native_ai/directory/exact_directory.sv",
    "xsim_log": root / "vivado/m2_query_posting/xsim/xsim.log",
}

out = {}
for k, p in files.items():
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    out[k] = {"path": str(p), "sha256": h, "bytes": p.stat().st_size}

out["result"] = "M2_QUERY_POST_XSIM_PASS"
out["rows"] = 235
out["finish_ns"] = 593505
out["class"] = "CANDIDATE"
out["not_claimed"] = [
    "M2_PASS",
    "FE256_PASS",
    "FE256_FULL_PASS",
    "TIMING_PASS",
    "MIG_PASS",
    "BOARD_PASS",
    "FINAL_PASS",
]
out["program"] = "NO"
out["fe256_engine_used"] = False
out["gold_set"] = "post_expect.hex (M2 posting; not FE256 256-case)"
out["query_meta_want_rev"] = "query_meta[10] CANDIDATE packing of §04.3 [11:10] direction"
out["vivado"] = "2026.1 SW Build 6511674"

dest = Path(r"D:\FPGA\arty_d\m2_query_posting")
dest.mkdir(parents=True, exist_ok=True)
(dest / "D_M2_QUERY_POSTING.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
print(json.dumps({k: v["sha256"] if isinstance(v, dict) and "sha256" in v else v for k, v in out.items()}, indent=2))
