"""Map UART load tokens to B --compare rows WITHOUT inventing generation_flipped or query.

Honest mapper: fill outcome/reason/ack/reject from a 32-bit UART status word.
Leave generation_flipped and query_* absent unless the caller supplies observed values
from observe_generation_flipped() (Pack-owner COMMIT transition, same epoch).

Copying TSV flip/query into DUT.jsonl is forbidden (false-PASS).
Not PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import csv
import json
from pathlib import Path

GOLD_HI, GOLD_LO = 0x01, 0xA5
NAK_HI, NAK_LO = 0x02, 0x5A
GEN_MAGIC = 0x47
HEADER_LENGTH = 128

TSV = Path(
    r"D:\FPGA\Native_SymAI\CANON_BLUEPRINT\verification\pack_abi24\out\pack_abi24_expect.tsv"
)
SHAPE_OUT = Path(
    r"D:\FPGA\arty_d\UART_R2\results\U33OBS_CAPTURE\U33OBS_DUT_SHAPE_V04.jsonl"
)


def parse_status_word(word: int) -> dict | None:
    hi = (word >> 24) & 0xFF
    mid = (word >> 16) & 0xFF
    reason = (word >> 8) & 0xFF
    lo = word & 0xFF
    if mid != 0:
        return None
    if hi == GOLD_HI and lo == GOLD_LO:
        return {"outcome": "LOAD_OK", "reason": reason, "ack": 1, "reject": 0}
    if hi == NAK_HI and lo == NAK_LO:
        return {"outcome": "LOAD_REJECT", "reason": reason, "ack": 0, "reject": 1}
    return None


def observe_generation_flipped(
    *,
    commit_event: int,
    generation_before: int | None,
    generation_after: int | None,
    epoch_before: int | None,
    epoch_after: int | None,
    capture_valid: int,
    clear_or_reset_between: int = 0,
) -> int | None:
    """Pack-owner COMMIT transition only. None = field absent.

    generation_flipped=1 iff
      commit_event==1 AND generation_after!=generation_before
      AND same_capture_epoch AND capture_valid==1
    """
    same_capture_epoch = (
        epoch_before is not None
        and epoch_after is not None
        and epoch_before == epoch_after
        and int(clear_or_reset_between) == 0
    )
    if (
        int(commit_event) == 1
        and generation_before is not None
        and generation_after is not None
        and same_capture_epoch
        and int(capture_valid) == 1
    ):
        return int(generation_after != generation_before)
    return None


def observe_from_tap_gen(st: int, before: int, after: int) -> int | None:
    """TAP word6 {8'h47, 4'h0, commit, same, cap, hw_flip, epoch[15:0]} plus words 7/8.

    Authority is the owner four-AND on Pack S_COMMIT, not after!=before alone.
    Hardware flip bit must match the predicate or the field stays absent.
    """
    if ((st >> 24) & 0xFF) != GEN_MAGIC:
        return None
    commit = (st >> 19) & 1
    same = (st >> 18) & 1
    cap = (st >> 17) & 1
    hw_flip = (st >> 16) & 1
    epoch = st & 0xFFFF
    got = observe_generation_flipped(
        commit_event=commit,
        generation_before=before,
        generation_after=after,
        epoch_before=epoch,
        epoch_after=epoch,
        capture_valid=cap,
        clear_or_reset_between=0 if same else 1,
    )
    if got is None:
        return None
    if hw_flip != got:
        return None
    return got


def dut_compare_fields(mapped: dict) -> dict:
    rec = {"case_id": mapped["case_id"]}
    for k in ("outcome", "reason", "ack", "reject", "generation_flipped", "query_status", "query_reason"):
        if k in mapped:
            rec[k] = mapped[k]
    rec["header_bytes"] = HEADER_LENGTH
    rec["PACK_ABI_24_24_PASS"] = "NO"
    return rec


def map_row(
    case_id: str,
    word: int | None,
    n: int,
    *,
    generation_flipped: int | None = None,
    query_status: int | None = None,
    query_reason: int | None = None,
) -> dict:
    rec: dict = {"case_id": case_id, "uart_n": n, "uart_word": None if word is None else f"{word:08x}"}
    if n != 4 or word is None:
        rec["map_ok"] = False
        rec["map_error"] = "UART_NOT_EXACT4"
        return rec
    parsed = parse_status_word(word)
    if not parsed:
        rec["map_ok"] = False
        rec["map_error"] = "UART_NOT_GOLD_NAK"
        return rec
    rec.update(parsed)
    if generation_flipped is not None:
        rec["generation_flipped"] = generation_flipped
    if query_status is not None:
        rec["query_status"] = query_status
    if query_reason is not None:
        rec["query_reason"] = query_reason
    rec["map_ok"] = True
    rec["compare_ready"] = (
        "generation_flipped" in rec
        and (case_id not in {"PA24-R-04", "PA24-G-04"} or ("query_status" in rec and "query_reason" in rec))
    )
    return rec


def tsv_cases(path: Path = TSV) -> list[dict]:
    return list(csv.DictReader(path.open(encoding="utf-8"), delimiter="\t"))


def selftest() -> int:
    rows = tsv_cases()
    if len(rows) != 24:
        print("FAIL tsv rows", len(rows))
        return 1
    n_ready = 0
    n_need_obs = 0
    for row in rows:
        cid = row["case_id"]
        ack = int(row["ack"])
        reason = int(row["reason"])
        word = ((0x01 << 24) | (reason << 8) | 0xA5) if ack else ((0x02 << 24) | (reason << 8) | 0x5A)
        mapped = map_row(cid, word, 4)
        if not mapped["map_ok"]:
            print("FAIL map", cid, mapped)
            return 1
        if mapped.get("reason") != reason:
            print("FAIL reason", cid)
            return 1
        if mapped.get("compare_ready"):
            n_ready += 1
        else:
            n_need_obs += 1
        cheat = map_row(cid, word, 4, generation_flipped=int(row["flip"]))
        if cid not in {"PA24-R-04", "PA24-G-04"} and cheat.get("compare_ready") and cheat["generation_flipped"] == int(
            row["flip"]
        ):
            # Document: this would be ready for --compare only if flip is OBSERVED.
            pass
    cases = [
        (
            "flip_ok",
            dict(
                commit_event=1,
                generation_before=3,
                generation_after=4,
                epoch_before=1,
                epoch_after=1,
                capture_valid=1,
            ),
            1,
        ),
        (
            "no_flip_ok",
            dict(
                commit_event=1,
                generation_before=3,
                generation_after=3,
                epoch_before=1,
                epoch_after=1,
                capture_valid=1,
            ),
            0,
        ),
        (
            "epoch_change",
            dict(
                commit_event=1,
                generation_before=3,
                generation_after=4,
                epoch_before=1,
                epoch_after=2,
                capture_valid=1,
            ),
            None,
        ),
        (
            "clear_between",
            dict(
                commit_event=1,
                generation_before=3,
                generation_after=4,
                epoch_before=1,
                epoch_after=1,
                capture_valid=1,
                clear_or_reset_between=1,
            ),
            None,
        ),
        (
            "no_commit",
            dict(
                commit_event=0,
                generation_before=3,
                generation_after=4,
                epoch_before=1,
                epoch_after=1,
                capture_valid=1,
            ),
            None,
        ),
        (
            "invalid_capture",
            dict(
                commit_event=1,
                generation_before=3,
                generation_after=4,
                epoch_before=1,
                epoch_after=1,
                capture_valid=0,
            ),
            None,
        ),
    ]
    for name, kwargs, want in cases:
        got = observe_generation_flipped(**kwargs)
        if got != want:
            print("FAIL observe_generation_flipped", name, "got", got, "want", want)
            return 1
    tap_cases = [
        ("gold_four_and", 0x470F0002, 0xFFFFFFFF, 0x0000FFFF, 1),
        ("leftover_no_commit", 0x47000002, 0x00000000, 0x00000000, None),
        ("dump_idle", 0x47000002, 0x00000000, 0x00000000, None),
        ("idle_snapshot_delta", 0x47060002, 0xFFFFFFFF, 0x0000FFFF, None),
        ("epoch_or_clear", 0x470A0002, 0xFFFFFFFF, 0x0000FFFF, None),
        ("commit_no_change", 0x470E0002, 0x00000003, 0x00000003, 0),
        ("hw_flip_mismatch", 0x470E0002, 0xFFFFFFFF, 0x0000FFFF, None),
    ]
    for name, st, before, after, want in tap_cases:
        got = observe_from_tap_gen(st, before, after)
        if got != want:
            print("FAIL observe_from_tap_gen", name, "got", got, "want", want)
            return 1
    gold_flip = observe_from_tap_gen(0x470F0002, 0xFFFFFFFF, 0x0000FFFF)
    v04 = map_row("PA24-V-04", 0x010000A5, 4, generation_flipped=gold_flip)
    if not v04.get("compare_ready") or v04.get("generation_flipped") != 1:
        print("FAIL V-04 shape", v04)
        return 1
    leftover_flip = observe_from_tap_gen(0x47000002, 0, 0)
    mag = map_row("PA24-A-01", 0x0200015A, 4, generation_flipped=leftover_flip)
    if "generation_flipped" in mag or mag.get("compare_ready"):
        print("FAIL leftover invented flip", mag)
        return 1
    idle = map_row(
        "PA24-V-04",
        0x010000A5,
        4,
        generation_flipped=observe_from_tap_gen(0x47060002, 0xFFFFFFFF, 0x0000FFFF),
    )
    if "generation_flipped" in idle or idle.get("compare_ready"):
        print("FAIL idle snapshot delta invented flip", idle)
        return 1
    SHAPE_OUT.parent.mkdir(parents=True, exist_ok=True)
    shape = dut_compare_fields(v04)
    shape["source"] = "SYNTHETIC_TAPDUMP_XSIM_NOT_SILICON"
    SHAPE_OUT.write_text(json.dumps(shape) + "\n", encoding="utf-8")
    print("SELFTEST map_ok 24/24; compare_ready_without_observed_flip", n_ready, "need_observe", n_need_obs)
    print("SELFTEST observe_generation_flipped 6/6 observe_from_tap_gen 7/7")
    print("SHAPE", SHAPE_OUT)
    print("PACK_ABI_24_24_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(selftest())
