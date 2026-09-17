import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path


def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def main():
    root = Path(
        r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT"
    )
    ooc = Path(r"D:/FPGA/arty_d/fe256_ooc_r1")
    integ = Path(r"D:/FPGA/arty_d/hold_r2/R2_FE256_R1_INTEGRATED_FREEZE")
    ref = Path(r"D:/FPGA/arty_d/hold_r2/FE256_R1_REFERENCE_FREEZE")
    ref.mkdir(parents=True, exist_ok=True)
    (ref / "reports").mkdir(exist_ok=True)

    shutil.copy2(ooc / "post_route.dcp", ref / "post_route.dcp")
    shutil.copy2(ooc / "post_synth.dcp", ref / "post_synth.dcp")
    shutil.copy2(ooc / "D_FE256_HW_R1.json", ref / "D_FE256_HW_R1.json")
    for n in [
        "route_timing.rpt",
        "route_util.rpt",
        "route_crit.rpt",
        "route_status.rpt",
        "timing.rpt",
        "util.rpt",
        "check_timing.rpt",
    ]:
        s = ooc / "reports" / n
        if s.exists():
            shutil.copy2(s, ref / "reports" / n)

    rtl = root / "rtl" / "native_ai"
    store = sha256(rtl / "fe256" / "fe256_store.mem")
    qp = sha256(rtl / "fe256" / "fe256_query_path.sv")
    ooc_dcp = sha256(ref / "post_route.dcp")
    assert sha256(ooc / "post_route.dcp") == ooc_dcp
    assert store == "6a1815c6be9baf5bdbcc5a74209f9e9b9f82a8230996e36b520a298165150ee8"
    assert qp == "4c69e8fbfafe7d75d667b653639bec453c0510bf7d032ec6ce27b870568d0241"

    gold_q = sha256(root / "verification" / "fe256" / "out" / "fe256_queries.hex")
    gold_r = sha256(root / "verification" / "fe256" / "out" / "fe256_gold_results.hex")
    b_tb = sha256(root / "verification" / "fe256" / "tb_fe256_xsim_compare.sv")

    bl = json.loads((integ / "BASELINE.json").read_text(encoding="utf-8"))
    lines = []
    for k in sorted(bl["file_hashes"]):
        lines.append(f"{bl['file_hashes'][k]}  {k}")
    for k in sorted(bl["gold_hashes"]):
        lines.append(f"{bl['gold_hashes'][k]}  {k}")
    lines.append(f"{bl['new_freeze']['dcp_sha256']}  post_route.dcp")
    lines.append(
        f"{bl['old_freeze']['dcp_sha256']}  OLD_FREEZE/R2_TOP_ROUTE_BASELINE_WHS_0P021/post_route.dcp"
    )
    (integ / "SHA256SUMS.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")

    doc = {
        "guard_id": "D-FE256-POST-GUARD-R1",
        "label": "FE256_R1_REFERENCE_FREEZE",
        "owner": "AGENT_D",
        "mode": "ACTIVE_AFTER_FE256_R1",
        "status": "REFERENCE_IMPLEMENTATION",
        "program": "NO",
        "claim_ceiling": [
            "NO FE256_FULL_PASS",
            "NO FE256_PASS",
            "NO TIMING_PASS",
            "NO MIG_PASS",
            "NO BOARD_PASS",
            "NO FINAL_PASS",
        ],
        "not_final_production_reasoning_path": True,
        "do_not_overwrite": True,
        "do_not_optimize_for_lut_wns": True,
        "wake_only_for": [
            "functional_regression",
            "evidence_corruption",
            "owner_authorized_experiment",
            "comparison_against_common_runtime",
        ],
        "vivado": "2026.1",
        "sw_build": "6511674",
        "part": "xc7a100tcsg324-1",
        "frozen_at_utc": datetime.now(timezone.utc).isoformat(),
        "engine": {
            "rtl": "rtl/native_ai/fe256/fe256_query_path.sv",
            "rtl_sha256": qp,
            "store": "rtl/native_ai/fe256/fe256_store.mem",
            "store_sha256": store,
            "isolated_dcp": str(ref / "post_route.dcp"),
            "isolated_dcp_sha256": ooc_dcp,
            "isolated_route": {
                "WNS_ns": 0.223,
                "WHS_ns": 0.092,
                "LUT": 2953,
                "FF": 3866,
                "RAMB36": 1,
                "DSP": 0,
            },
            "xsim_isolated": "FE256_XSIM_PASS 256/256 bit-exact vs B TB (simulation only; not FE256_PASS)",
            "xsim_integrated": "FE256_SHADOW_BIND_XSIM 256/256 (simulation only; not FE256_PASS)",
        },
        "gold": {
            "queries_sha256": gold_q,
            "results_sha256": gold_r,
            "b_tb_sha256": b_tb,
            "gold_tb_modified": False,
        },
        "related_top_freeze": {
            "label": "R2_FE256_R1_INTEGRATED_FREEZE",
            "note": "owner-authorized integrated baseline; dedicated FE256 currently instantiated; not FE256_PASS; retirement law applies later",
            "dcp_sha256": "858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd",
        },
        "old_fabric_rollback": {
            "label": "R2_TOP_ROUTE_BASELINE_WHS_0P021",
            "preserved": True,
            "dcp_sha256": "b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388",
        },
        "resource_guard": {
            "LUT": 2953,
            "FF": 3866,
            "RAMB36": 1,
            "DSP": 0,
            "increase_requires_owner": True,
        },
    }
    (ref / "BASELINE.json").write_text(json.dumps(doc, indent=2), encoding="utf-8")
    sums = [
        f"{qp}  rtl/native_ai/fe256/fe256_query_path.sv",
        f"{store}  rtl/native_ai/fe256/fe256_store.mem",
        f"{ooc_dcp}  post_route.dcp",
        f"{gold_q}  fe256_queries.hex",
        f"{gold_r}  fe256_gold_results.hex",
        f"{b_tb}  tb_fe256_xsim_compare.sv",
    ]
    (ref / "SHA256SUMS.txt").write_text("\n".join(sums) + "\n", encoding="utf-8")
    print("REF_DCP", ooc_dcp)
    print("INTEG_LINE0", (integ / "SHA256SUMS.txt").read_text(encoding="utf-8").splitlines()[0])


if __name__ == "__main__":
    main()
