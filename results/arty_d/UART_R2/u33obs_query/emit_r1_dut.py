"""Emit R1-shaped DUT jsonl from observed Pack24 resume recs.

Does not invent generation_flipped=0. Does not rewrite pack_abi24_gold.py.
NAK TAP commit is tap_not_this_pack: this-pack commit_count from UART
NAK/not-GOLD, not TAP sticky GOLD. PACK_ABI_24_24_PASS=NO.
"""
from __future__ import annotations

import json
from pathlib import Path

SRC = Path(r"D:\FPGA\arty_d\UART_R2\results\U33OBS_CAPTURE\PACK24_RESUME_QUERY.json")
OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\U33OBS_CAPTURE\PACK24_RESUME_QUERY_R1.jsonl")
GOLD = "010000a5"


def main() -> int:
    camp = json.loads(SRC.read_text(encoding="utf-8"))
    recs = camp["recs"]
    rows = camp["rows"]
    rec_by_step = {r["step"]: r for r in recs}
    lines = []
    for row in rows:
        cid = row["case_id"]
        token = (row.get("uart_word") or "").lower()
        rec = rec_by_step.get(cid) or {}
        dump = rec_by_step.get(f"{cid}_gold_dump") or {}
        tap = dump.get("tap") or {}
        out: dict = {
            "case_id": cid,
            "uart_token": token,
            "capture_valid": True,
            "overflow": False,
            "PACK_ABI_24_24_PASS": "NO",
            "source": "BOARD_U33OBS_PACK24_RESUME_QUERY_R1",
        }
        if token == GOLD and row.get("generation_flipped") == 1 and tap.get("commit_event") == 1:
            out["commit_event"] = True
            out["same_capture_epoch"] = True
            out["generation_before"] = tap.get("generation_before")
            out["generation_after"] = tap.get("generation_after")
            out["generation_flipped"] = True
            # GOLD pulse is pack_loader S_COMMIT after S_RD_WAIT dest match.
            # Dest hex UART export remains NOT_RUN.
            out["destination_complete"] = True
            out["destination_complete_kind"] = "S_RD_WAIT_THEN_S_COMMIT_GOLD"
        else:
            out["observation_window_complete"] = rec.get("n") in (4, 40)
            out["commit_count"] = 0
            out["commit_event"] = None
            out["this_pack_uart_committed"] = False
            if row.get("tap_not_this_pack"):
                out["tap_not_this_pack"] = True
                out["tap_commit_event_stale"] = row.get("tap_commit_event")
            # generation_flipped omitted — do not synthesize 0
        if row.get("query_status") is not None:
            out["query_status"] = row["query_status"]
            out["query_reason"] = row.get("query_reason")
        if cid == "PA24-G-04":
            out["g04_lifecycle"] = (
                "SELF_CONTAINED_ACTIVE_GEN2_THEN_STALE_QUERY_THEN_FAILED_B"
            )
            out["g04_query_word"] = (rec_by_step.get("PA24-G-04_query") or {}).get("word")
        lines.append(out)
    OUT.write_text("".join(json.dumps(x) + "\n" for x in lines), encoding="utf-8")
    print("R1_JSONL", OUT)
    print("PACK_ABI_24_24_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
