# ANALYSIS_ONLY scanner for AGENT_E. Does not program, edit RTL, or stamp PASS.
from __future__ import annotations

import hashlib
import json
import time
from collections import Counter
from pathlib import Path

LOG = Path(r"d:\FPGA\debug-463f7f.log")
SNAP = Path(r"D:\FPGA\arty_d\AUDIT_LEAD_E\snapshot")
LIVE_PKG = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
)
MANIFEST = Path(r"D:\FPGA\arty_d\AUDIT_LEAD_E\SHA256MANIFEST.json")
OUT = Path(r"D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT\scan_result.json")


def dlog(hypothesis_id: str, location: str, message: str, data: dict) -> None:
    rec = {
        "sessionId": "463f7f",
        "runId": "e-audit-pre",
        "hypothesisId": hypothesis_id,
        "location": location,
        "message": message,
        "data": data,
        "timestamp": int(time.time() * 1000),
    }
    with LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=True) + "\n")


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def load_mem(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    n = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + n]]
    return words


def reason_name(st: str | None) -> str:
    if not st or len(st) < 8:
        return "NONE"
    w = int(st, 16)
    kind = (w >> 24) & 0xFF
    reason = (w >> 8) & 0xFF
    names = {
        0x00: "R_OK",
        0x01: "R_BAD_MAGIC",
        0x02: "R_ABI",
        0x03: "R_SCHEMA",
        0x04: "R_MAN_CRC",
        0x05: "R_PAGE_CRC",
        0x06: "R_SEQ",
        0x07: "R_UNSUP",
        0x08: "R_SENTINEL",
        0x09: "R_HDR_LEN",
        0x0A: "R_RESNZ",
        0x0B: "R_REGCNT",
        0x0C: "R_DRAIN",
        0x0D: "R_CONTENT",
        0x0E: "R_STALE",
        0x0F: "R_TRUNC",
    }
    tag = "ACK" if kind == 1 else "NAK" if kind == 2 else "OTHER"
    return f"{tag}/{names.get(reason, hex(reason))}"


def main() -> int:
    man = json.loads(MANIFEST.read_text(encoding="utf-8"))
    mismatches = []
    missing = []
    for item in man["manifest"]:
        dest = Path(item["dest"])
        if not dest.exists():
            missing.append(item["dest"])
            continue
        got = sha256(dest)
        if got != item["sha256"]:
            mismatches.append({"dest": item["dest"], "want": item["sha256"], "got": got})
    dlog(
        "H0",
        "e_audit_scan.py:manifest",
        "snapshot vs SHA256MANIFEST",
        {"copied": man.get("copied_files"), "mismatch": len(mismatches), "missing": len(missing)},
    )

    c_files = {
        "qstar_select.v": "d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240",
        "spear_rank.v": "11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293",
        "fem_lifecycle.v": "45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed",
    }
    c_hash = {}
    for name, want in c_files.items():
        p = SNAP / "CANON_BLUEPRINT" / "rtl" / "native_ai" / (
            "strategy" if "fem" not in name else "memory"
        ) / name
        if name == "fem_lifecycle.v":
            p = SNAP / "CANON_BLUEPRINT" / "rtl" / "native_ai" / "memory" / name
        elif name == "spear_rank.v":
            p = SNAP / "CANON_BLUEPRINT" / "rtl" / "native_ai" / "strategy" / name
        got = sha256(p)
        c_hash[name] = {"want": want, "got": got, "match": got == want}
    dlog("H0", "e_audit_scan.py:c_rtl", "C RTL snapshot hashes", c_hash)

    jsonl = SNAP / "arty_d" / "m4_mig_clear" / "UART_PACK24_CLEAR_BOARD.jsonl"
    recs = [json.loads(ln) for ln in jsonl.read_text(encoding="utf-8").splitlines() if ln.strip()]
    phases = Counter((r.get("round"), r.get("phase"), r.get("got") is not None) for r in recs)
    pack = [r for r in recs if r.get("phase") == "PACK"]
    clr = [r for r in recs if r.get("phase") == "CLEAR"]
    mute_from = next((r for r in recs if r.get("phase") == "CLEAR" and r.get("got") is None), None)
    dlog(
        "H2",
        "e_audit_scan.py:campaign",
        "identity D campaign summary",
        {
            "n": len(recs),
            "pack_ok": sum(1 for r in pack if r.get("ok")),
            "pack_n": len(pack),
            "clear_none": sum(1 for r in clr if r.get("got") is None),
            "first_clear_none": mute_from,
            "pack_got": [(r["case_id"], r.get("got"), reason_name(r.get("got"))) for r in pack],
        },
    )

    mem_dir = SNAP / "CANON_BLUEPRINT" / "verification" / "pack_abi24" / "out"
    mem_info = {}
    for p in sorted(mem_dir.glob("PA24-*.mem")):
        words = load_mem(p)
        ops = [w & 0xFF for w in words if (w & 0xFF) in (1, 2, 3, 4) or w == 0x44524743]
        mem_info[p.stem] = {
            "nwords": len(words),
            "first": f"{words[0]:08x}" if words else None,
            "first_op": words[0] & 0xFF if words else None,
            "has_CLEAR_CMD": any(w == 0x44524743 for w in words),
            "has_QMAGIC_4E51": any((w & 0xFFFF) == 0x4E51 for w in words),
            "qmagic_words": [f"{w:08x}" for w in words if (w & 0xFFFF) == 0x4E51],
        }
    dlog(
        "H1",
        "e_audit_scan.py:mem",
        "gold mem opcode/QMAGIC scan",
        {
            "v02": mem_info.get("PA24-V-02"),
            "s01": mem_info.get("PA24-S-01"),
            "r04": mem_info.get("PA24-R-04"),
            "max_nwords": max(v["nwords"] for v in mem_info.values()),
            "any_clear_in_gold": any(v["has_CLEAR_CMD"] for v in mem_info.values()),
        },
    )

    top = (SNAP / "CANON_BLUEPRINT" / "rtl" / "native_ai" / "board" / "arty_a7_r2_top_m4_mig_candidate.sv").read_text(
        encoding="utf-8"
    )
    handshake = {
        "w_ready_no_fifo": "assign w_ready = clr_take || !clr_hold;" in top,
        "wr_valid_not_hold_gated": ".wr_valid(w_valid && !clr_take)" in top,
        "qsc_no_fifo_empty": "assign qsc_100 = qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid;"
        in top,
    }
    dlog("H3", "e_audit_scan.py:rtl", "top handshake predicates", handshake)

    live_bit = Path(r"D:\FPGA\arty_d\m4_mig_clear\arty_a7_r2_top_m4_mig_validation_clear.bit")
    live_prog = Path(r"D:\FPGA\arty_d\m4_mig_clear\PROGRAM.txt")
    live_json = Path(r"D:\FPGA\arty_d\m4_mig_clear\D_PACK_VALIDATION_CLEAR.json")
    hist_bit = Path(r"D:\FPGA\arty_d\m4_mig\arty_a7_r2_top_m4_mig_candidate.bit")
    freeze = {
        "live_bit_exists": live_bit.exists(),
        "live_bit_sha": sha256(live_bit) if live_bit.exists() else None,
        "hist_bit_sha": sha256(hist_bit) if hist_bit.exists() else None,
        "live_prog_text": live_prog.read_text(encoding="utf-8") if live_prog.exists() else None,
        "stale_json_live_programmed": None,
    }
    if live_json.exists():
        js = json.loads(live_json.read_text(encoding="utf-8"))
        freeze["stale_json_live_programmed"] = (js.get("live_programmed") or {}).get("bit")
    snap_json = json.loads((SNAP / "arty_d" / "m4_mig_clear" / "D_PACK_VALIDATION_CLEAR.json").read_text(encoding="utf-8"))
    dlog(
        "H4",
        "e_audit_scan.py:identity",
        "live bit vs JSON identity",
        {
            "live_bit_sha": freeze["live_bit_sha"],
            "want_bbba86c1": (freeze["live_bit_sha"] or "").startswith("bbba86c1"),
            "hist_untouched": freeze["hist_bit_sha"]
            == "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
            "snap_json_bit": (snap_json.get("live_programmed") or {}).get("bit"),
            "live_json_bit": freeze["stale_json_live_programmed"],
        },
    )

    iso_path = SNAP / "arty_d" / "m4_mig" / "UART_PACK24_ISO_BOARD.jsonl"
    iso = {}
    for ln in iso_path.read_text(encoding="utf-8").splitlines():
        if ln.strip():
            r = json.loads(ln)
            iso[r["case_id"]] = r.get("got")
    cmp_rows = []
    for r in pack:
        if r.get("round") != 0:
            continue
        cmp_rows.append(
            {
                "case": r["case_id"],
                "clear_got": r.get("got"),
                "iso_got": iso.get(r["case_id"]),
                "eq": r.get("got") == iso.get(r["case_id"]),
                "decode": reason_name(r.get("got")),
            }
        )
    dlog("H5", "e_audit_scan.py:iso", "CLEAR r0 PACK vs ISO", {"rows": cmp_rows})

    out = {
        "mandate": "ANALYSIS_ONLY",
        "PASS_STAMP": "NONE",
        "manifest_mismatch": mismatches,
        "manifest_missing": missing,
        "c_hash": c_hash,
        "handshake": handshake,
        "mem_info": mem_info,
        "campaign_n": len(recs),
        "pack": pack,
        "first_clear_none": mute_from,
        "iso_cmp": cmp_rows,
        "live": freeze,
        "snap_json_bit": (snap_json.get("live_programmed") or {}).get("bit"),
    }
    OUT.write_text(json.dumps(out, indent=2), encoding="utf-8")
    dlog("H0", "e_audit_scan.py:done", "wrote scan_result.json", {"out": str(OUT)})
    print(json.dumps({"ok": True, "out": str(OUT), "mismatch": len(mismatches), "missing": len(missing)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
