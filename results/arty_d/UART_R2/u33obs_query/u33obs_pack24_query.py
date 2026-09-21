"""Pack24 run1 on unique QUERY identity 8fc14f25.

G-01: two-step. G-04: G-01 then QueryRecord then fail_B (no CLEAR between).
R-04: GOLD DUMP then QueryRecord. generation_flipped four-AND this-pack only.
Do not invent reject flip=0. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import TAP1, collect_words_from_bytes, decode_tap, mapper  # noqa: E402
from u33obs_hops import (  # noqa: E402
    OUT,
    PROG_QUERY,
    WANT_QUERY,
    dump_tap,
    find_port,
    kill_jtag,
    now_iso,
    open_mark,
    parse_program_txt,
    read_buf,
    rec_of,
    send_clear_until_ack,
    send_words,
)
from u33obs_pack24 import CASES, load_mem, split_status_tap  # noqa: E402

sys.path.insert(0, r"D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator")
from uart_token_to_compare import parse_query_word  # noqa: E402

STEP1 = Path(r"D:\FPGA\arty_d\pack_abi24_obs_dut\xsim\out\PA24-G-01.step1.mem")
GOLD_PY = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\pack_abi24_gold.py"
)
MEM = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)


def load_mem_path(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short")
    return words


def query_words(cid: str) -> list[int]:
    import importlib.util

    spec = importlib.util.spec_from_file_location("pack_abi24_gold", GOLD_PY)
    if spec is None or spec.loader is None:
        raise RuntimeError("gold missing")
    mod = importlib.util.module_from_spec(spec)
    sys.modules["pack_abi24_gold"] = mod
    spec.loader.exec_module(mod)
    blob = None
    for c in mod.build_cases():
        if c.case_id == cid:
            blob = c.query_blob
            break
    if not blob:
        raise RuntimeError(f"no query_blob {cid}")
    pad = blob + (b"\x00" * ((-len(blob)) % 4))
    return [struct.unpack_from("<I", pad, i)[0] for i in range(0, len(pad), 4)]


def four_and_flip(status: int | None, tap: dict | None) -> int | None:
    if not tap or status != 0x010000A5:
        return None
    if (
        tap.get("commit_event") == 1
        and tap.get("same_capture_epoch") == 1
        and tap.get("capture_valid") == 1
        and tap.get("generation_before") is not None
        and tap.get("generation_after") is not None
        and tap.get("generation_before") != tap.get("generation_after")
        and tap.get("generation_flipped") == 1
    ):
        return 1
    if (
        tap.get("commit_event") == 1
        and tap.get("same_capture_epoch") == 1
        and tap.get("capture_valid") == 1
        and tap.get("generation_before") is not None
        and tap.get("generation_after") is not None
        and tap.get("generation_before") == tap.get("generation_after")
        and tap.get("generation_flipped") == 0
    ):
        return 0
    return None


def send_pack(ser, recs: list, cid: str, words: list[int], step: str) -> tuple:
    send_words(ser, words)
    stream = read_buf(ser, 12.0) + read_buf(ser, 0.5)
    rec = rec_of(stream, step)
    recs.append(rec)
    status, n, tap = split_status_tap(stream)
    return rec, status, n, tap


def send_query(ser, recs: list, cid: str) -> dict | None:
    send_words(ser, query_words(cid))
    qrec = rec_of(read_buf(ser, 8.0) + read_buf(ser, 1.0), f"{cid}_query")
    recs.append(qrec)
    parsed = parse_query_word(int(qrec["word"], 16)) if qrec.get("word") else None
    print(cid, "QUERY", qrec.get("status_class"), qrec.get("word"), parsed)
    return parsed


def main() -> int:
    run2 = len(sys.argv) > 1 and sys.argv[1] == "--run2"
    fresh = len(sys.argv) > 1 and sys.argv[1] == "--fresh"
    poweroff = len(sys.argv) > 1 and sys.argv[1] == "--poweroff15"
    resume = len(sys.argv) > 1 and sys.argv[1] == "--resume"
    if run2:
        run_tag = "run2_query"
        json_name = "PACK24_RUN2_QUERY.json"
        jsonl_name = "PACK24_RUN2_QUERY_DUT.jsonl"
    elif fresh:
        run_tag = "fresh_query"
        json_name = "PACK24_FRESH_QUERY.json"
        jsonl_name = "PACK24_FRESH_QUERY_DUT.jsonl"
    elif poweroff:
        run_tag = "poweroff15_query"
        json_name = "PACK24_POWEROFF15_QUERY.json"
        jsonl_name = "PACK24_POWEROFF15_QUERY_DUT.jsonl"
    elif resume:
        run_tag = "resume_query"
        json_name = "PACK24_RESUME_QUERY.json"
        jsonl_name = "PACK24_RESUME_QUERY_DUT.jsonl"
    else:
        run_tag = "run1_query"
        json_name = "PACK24_RUN1_QUERY.json"
        jsonl_name = "PACK24_RUN1_QUERY_DUT.jsonl"
    OUT.mkdir(parents=True, exist_ok=True)
    prog = parse_program_txt(PROG_QUERY)
    out = {
        "when": now_iso(),
        "run": run_tag,
        "want_sha256": WANT_QUERY,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "generation_flipped_law": (
            "true iff commit_event==1 AND generation_after!=generation_before "
            "AND same_capture_epoch AND capture_valid==1 from THIS pack S_COMMIT"
        ),
        "recs": [],
        "rows": [],
        "fresh": fresh,
        "poweroff15": False,
        "resume": resume,
        "dest_word_export": "NOT_RUN",
        "dest_complete_handshake": "GOLD after pack_loader S_RD_WAIT this pack; not dest hex UART",
        "dest_wipe": "NO; owner board never unplugged; do not claim DRAM wipe",
    }
    if prog.get("STATUS") != "PROGRAMMED" or prog.get("SHA256") != WANT_QUERY:
        print("PACK24_REFUSED need 8fc14f25")
        return 4
    kill_jtag()
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    dummy = open_mark(port)
    dummy.close()
    import time

    time.sleep(0.2)
    ser = open_mark(port)
    m = mapper()
    jsonl_lines = []
    recs = out["recs"]
    try:
        for cid in CASES:
            send_clear_until_ack(ser, recs, f"{cid}_clear")
            qparsed = None
            status = None
            n = 0
            tap = None
            rec = None
            if cid == "PA24-G-01":
                rec, status, n, tap = send_pack(ser, recs, cid, load_mem_path(STEP1), f"{cid}_step1")
                rec, status, n, tap = send_pack(
                    ser, recs, cid, load_mem(cid), f"{cid}_step2"
                )
            elif cid == "PA24-G-04":
                send_pack(ser, recs, cid, load_mem_path(STEP1), f"{cid}_prior_g01s1")
                send_pack(ser, recs, cid, load_mem_path(MEM / "PA24-G-01.mem"), f"{cid}_prior_g01s2")
                qparsed = send_query(ser, recs, "PA24-G-04")
                rec, status, n, tap = send_pack(ser, recs, cid, load_mem(cid), cid)
            else:
                rec, status, n, tap = send_pack(ser, recs, cid, load_mem(cid), cid)
            if tap is None and status == 0x010000A5:
                d = dump_tap(ser, recs, f"{cid}_gold_dump")
                tap = d.get("tap")
            if cid == "PA24-R-04" and status == 0x010000A5:
                qparsed = send_query(ser, recs, "PA24-R-04")
            flip = four_and_flip(status, tap)
            stale_tap = bool(tap) and status != 0x010000A5
            qs = qparsed["query_status"] if qparsed else None
            qr = qparsed["query_reason"] if qparsed else None
            row = m.map_row(
                cid,
                status,
                n,
                generation_flipped=flip,
                query_status=qs,
                query_reason=qr,
            )
            if tap:
                row["tap_identity"] = tap.get("identity")
                row["tap_commit_event"] = tap.get("commit_event")
                if stale_tap:
                    row["tap_not_this_pack"] = True
            dut = (
                m.dut_compare_fields(row)
                if row.get("map_ok")
                else {"case_id": cid, "map_ok": False, "map_error": row.get("map_error")}
            )
            dut["PACK_ABI_24_24_PASS"] = "NO"
            if run2:
                dut["source"] = "BOARD_U33OBS_PACK24_RUN2_QUERY"
            elif fresh:
                dut["source"] = "BOARD_U33OBS_PACK24_FRESH_QUERY"
            elif resume:
                dut["source"] = "BOARD_U33OBS_PACK24_RESUME_QUERY"
            else:
                dut["source"] = "BOARD_U33OBS_PACK24_RUN1_QUERY"
            jsonl_lines.append(dut)
            out["rows"].append(row)
            print(
                cid,
                rec.get("status_class") if rec else None,
                "n",
                rec.get("n") if rec else None,
                "flip",
                flip,
                "q",
                qparsed,
                "ready",
                row.get("compare_ready"),
            )
    finally:
        ser.close()
    jsonl_path = OUT / jsonl_name
    jsonl_path.write_text("".join(json.dumps(x) + "\n" for x in jsonl_lines), encoding="utf-8")
    out["dut_jsonl"] = str(jsonl_path)
    out["run2"] = run2
    out["fresh"] = fresh
    out["poweroff15"] = False
    out["resume"] = resume
    (OUT / json_name).write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("DUT", jsonl_path)
    print("PACK_ABI_24_24_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
