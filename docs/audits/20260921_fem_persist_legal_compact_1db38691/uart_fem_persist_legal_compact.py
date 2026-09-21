"""Gated legal-compact FEM persist UART experiment on identity 1db38691.

LANGUAGE=EN. No DEST_POKE. No red RESET. No new bitstream.
Does not overwrite historical FEM_PERSIST_OWNER_PROGRAM UART_SMOKE.json.
FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO MIG_PASS=NO TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import collect_words_from_bytes  # noqa: E402
from u33obs_hops import (  # noqa: E402
    find_port,
    now_iso,
    open_mark,
    parse_program_txt,
    rec_of,
    read_buf,
    send_words,
)

WANT = "1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668"
PROG = Path(r"D:\FPGA\arty_d\UART_R2\results\FEM_PERSIST_OWNER_PROGRAM_20260921\PROGRAM.txt")
OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\FEM_PERSIST_LEGAL_COMPACT_20260921")
CLR = 0x44524743
ACK = 0xC1EA50A5
CMD_DRD = 0x44524431
CMD_FING = 0x46494E47
CMD_FREP = 0x46524550
CMD_FCMP = 0x46434D50
CMD_FRST = 0x46525354
CMD_FREC = 0x46524543
CMD_FOBS = 0x464F4253
COMMIT_MAGIC = 0xC0117ED0
CRC_MARK = 0xA5A5
KEY = 0x70EA
P_W0 = 0x70EA0203
P_W1 = 0x11010000
HDR_COMPACTED = 0x03000213
HDR2_RESOLVED = 0x110170EA
INDEX_ONE = 0x00000001
FEM_HDR_BEAT = 0x0200000
FEM_COMMIT_BEAT = 0x0200010


class GateAbort(Exception):
    def __init__(self, cut: str, divergence: str, detail: str) -> None:
        super().__init__(detail)
        self.cut = cut
        self.divergence = divergence
        self.detail = detail


def hex4(words: list[int]) -> list[str]:
    return [f"{w:08x}" for w in words]


def slice_magic(words: list[int], magic: int, n: int) -> list[int] | None:
    for i, w in enumerate(words):
        if w == magic and i + n <= len(words):
            return words[i : i + n]
    return None


def crc16_n(d: int, nbits: int) -> int:
    c = 0xFFFF
    for k in range(nbits - 1, -1, -1):
        bit = (d >> k) & 1
        if (bit ^ (c >> 15)) & 1:
            c = ((c << 1) & 0xFFFF) ^ 0x1021
        else:
            c = (c << 1) & 0xFFFF
    return c


CRC_PW = crc16_n((P_W0 << 32) | P_W1, 64)
EXPECT_CRCW = (CRC_MARK << 16) | CRC_PW


def decode_fobs(s0: int, s1: int, s2: int, s3: int = 0) -> dict:
    return {
        "txn_step": s0 & 0xF,
        "cmp_result": (s0 >> 4) & 0x7,
        "n_raw": (s0 >> 7) & 0xF,
        "life": (s0 >> 11) & 0x7,
        "recov": (s0 >> 14) & 0x3,
        "unresolved": (s0 >> 16) & 1,
        "compacted": (s0 >> 17) & 1,
        "integrity_fault": (s0 >> 18) & 1,
        "feat": s1 & 0xFF,
        "sar": (s1 >> 8) & 0xFF,
        "fr": (s1 >> 16) & 0xFF,
        "ft": (s1 >> 24) & 0xFF,
        "key": s2 & 0xFFFF,
        "s3": s3,
    }


def miss(dec: dict, expect: dict) -> list[str]:
    out = []
    for k, v in expect.items():
        if dec.get(k) != v:
            out.append(f"{k}={dec.get(k)!r} want={v!r}")
    return out


def cmd_echo(ser, recs: list, name: str, words_tx: list[int], magic: int, timeout_s: float) -> dict:
    send_words(ser, words_tx)
    buf = read_buf(ser, timeout_s)
    words = collect_words_from_bytes(buf)
    item = rec_of(buf, name)
    item["echo"] = int(magic in words)
    item["words"] = hex4(words[:8])
    recs.append(item)
    print(name, "n", item["n"], "echo", item["echo"], item["words"])
    return item


def do_fobs(ser, recs: list, name: str, timeout_s: float = 12.0) -> dict:
    send_words(ser, [CMD_FOBS])
    buf = read_buf(ser, timeout_s)
    words = collect_words_from_bytes(buf)
    sl = slice_magic(words, CMD_FOBS, 6)
    item = rec_of(buf, name)
    item["ok"] = int(sl is not None)
    item["words"] = None if sl is None else hex4(sl)
    if sl is not None:
        item["decode"] = decode_fobs(sl[1], sl[2], sl[3], sl[4])
    recs.append(item)
    print(name, "ok", item["ok"], item.get("decode"), item.get("words"))
    return item


def require_fobs(item: dict, expect: dict, cut: str, divergence: str) -> dict:
    if not item.get("ok") or "decode" not in item:
        raise GateAbort(cut, divergence, f"{item.get('step')} missing FOBS frame n={item.get('n')}")
    bad = miss(item["decode"], expect)
    if bad:
        raise GateAbort(cut, divergence, f"{item.get('step')} {'; '.join(bad)}")
    return item["decode"]


def do_dest_read(ser, recs: list, name: str, addr: int, timeout_s: float = 12.0) -> dict:
    send_words(ser, [CMD_DRD, addr])
    buf = read_buf(ser, timeout_s)
    words = collect_words_from_bytes(buf)
    sl = slice_magic(words, CMD_DRD, 5)
    item = rec_of(buf, name)
    item["ok"] = int(sl is not None)
    item["addr"] = f"0x{addr:07x}"
    item["beat"] = None if sl is None else hex4(sl[1:5])
    item["commit_magic"] = int(sl is not None and sl[1] == COMMIT_MAGIC)
    recs.append(item)
    print(name, item.get("beat"), "magic", item["commit_magic"])
    return item


def write_out(recs: list, extra: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    body = {
        "utc": now_iso(),
        "identity_want": WANT,
        "kill_jtag": "NO",
        "red_reset": "NO",
        "dest_poke": "NO",
        "new_bitstream": "NO",
        "FEM_PERSIST_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "BOARD_PASS": "NO",
        "TIMING_PASS": "NO",
        "MIG_PASS": "NO",
        "PACK_ABI_24_24_PASS": "NO",
        "expect_crcw": f"{EXPECT_CRCW:08x}",
        "crc16_p_w0_p_w1": f"{CRC_PW:04x}",
        "recs": recs,
    }
    body.update(extra)
    Path(OUT / "UART_LEGAL_COMPACT.json").write_text(
        json.dumps(body, indent=2), encoding="utf-8"
    )


def main() -> int:
    recs: list[dict] = []
    extra: dict = {
        "PRECONDITION": "NOT_RUN",
        "INGRESS_GATE": "NOT_RUN",
        "FREP1_GATE": "NOT_RUN",
        "FREP2_GATE": "NOT_RUN",
        "FREP3_GATE": "NOT_RUN",
        "FCMP_FOBS": "NOT_RUN",
        "DEST_BEAT_0200000_BEFORE_FRST": None,
        "DEST_BEAT_0200010_BEFORE_FRST": None,
        "AFTER_FRST_FOBS": "NOT_RUN",
        "DEST_BEAT_0200000_AFTER_FRST": None,
        "DEST_BEAT_0200010_AFTER_FRST": None,
        "AFTER_FREC_FOBS": "NOT_RUN",
        "FIRST_DIVERGENCE": "NOT_RUN",
        "ROOT_CAUSE_STATUS": "NOT_RUN",
        "BOARD_CANDIDATE_RESULT": "NOT_RUN",
        "CLAIM_CEILING": (
            "FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO "
            "MIG_PASS=NO TIMING_PASS=NO PACK_ABI_24_24_PASS=NO"
        ),
    }
    prog = parse_program_txt(PROG)
    sha = (prog.get("SHA256") or "").lower()
    recs.append(
        {
            "step": "PROGRAM_TXT",
            "sha": sha,
            "match_1db38691": int(sha == WANT),
            "programmed_at": prog.get("PROGRAMMED_AT"),
            "eos": prog.get("EOS"),
        }
    )
    extra["BOARD_BIT_SHA_PROGRAM_TXT"] = sha
    extra["BOARD_BIT_SHA"] = sha
    if sha != WANT:
        extra["FIRST_DIVERGENCE"] = "VIRGIN_PRECONDITION"
        extra["ROOT_CAUSE_STATUS"] = "PROGRAM_TXT_SHA_MISMATCH"
        extra["BOARD_CANDIDATE_RESULT"] = "ABORT_SHA_MISMATCH"
        write_out(recs, extra)
        print("SHA_MISMATCH", sha)
        return 4

    port = find_port()
    recs.append({"step": "PORT", "port": port})
    extra["PORT"] = port
    print("port", port, "sha_ok", sha == WANT, "expect_crcw", f"{EXPECT_CRCW:08x}")
    if not port:
        extra["FIRST_DIVERGENCE"] = "VIRGIN_PRECONDITION"
        extra["ROOT_CAUSE_STATUS"] = "UART_PORT_MISSING"
        extra["BOARD_CANDIDATE_RESULT"] = "ABORT_NO_PORT"
        write_out(recs, extra)
        return 3

    time.sleep(2.0)
    ser = open_mark(port)
    try:
        clr = cmd_echo(ser, recs, "CLEAR", [CLR], CLR, 6.0)
        extra["CLEAR"] = {"n": clr["n"], "ack": clr["echo"] and ACK in [
            int(w, 16) for w in (clr.get("words") or [])
        ]}
        words_clr = collect_words_from_bytes(bytes.fromhex(clr["raw_hex"])) if clr.get("raw_hex") else []
        extra["CLEAR"]["ack"] = int(ACK in words_clr)
        extra["CLEAR"]["word"] = clr.get("word")
        if not extra["CLEAR"]["ack"]:
            extra["PRECONDITION"] = "FAIL_CLEAR"
            extra["FIRST_DIVERGENCE"] = "VIRGIN_PRECONDITION"
            extra["ROOT_CAUSE_STATUS"] = "CLEAR_ACK_MISSING"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_CLEAR"
            write_out(recs, extra)
            return 5

        frst0 = cmd_echo(ser, recs, "FRST_PRE", [CMD_FRST], CMD_FRST, 8.0)
        if not frst0["echo"]:
            extra["PRECONDITION"] = "FAIL_FRST_ECHO"
            extra["FIRST_DIVERGENCE"] = "FEM_RESET_SCOPE"
            extra["ROOT_CAUSE_STATUS"] = "FRST_ECHO_MISSING"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_FRST_PRE"
            write_out(recs, extra)
            return 6

        pre = do_fobs(ser, recs, "FOBS_VIRGIN")
        require_fobs(
            pre,
            {
                "life": 7,
                "n_raw": 0,
                "ft": 0,
                "fr": 0,
                "sar": 0,
                "key": 0,
                "compacted": 0,
                "recov": 0,
            },
            "ABORT_PRECONDITION_NOT_VIRGIN",
            "VIRGIN_PRECONDITION",
        )
        extra["PRECONDITION"] = "PASS"

        for name, arg in (("FING_5", 0x5), ("FING_6", 0x6), ("FING_4a", 0x4), ("FING_4b", 0x4)):
            fing = cmd_echo(ser, recs, name, [CMD_FING, arg], CMD_FING, 10.0)
            if not fing["echo"]:
                raise GateAbort(
                    "ABORT_INGRESS_STATE_MISMATCH",
                    "INGRESS_CONTROL",
                    f"{name} echo missing",
                )

        ing = do_fobs(ser, recs, "FOBS_AFTER_INGRESS")
        require_fobs(
            ing,
            {
                "life": 1,
                "n_raw": 2,
                "ft": 2,
                "fr": 2,
                "sar": 0,
                "key": KEY,
                "compacted": 0,
            },
            "ABORT_INGRESS_STATE_MISMATCH",
            "INGRESS_CONTROL",
        )
        extra["INGRESS_GATE"] = "PASS"

        f1 = cmd_echo(ser, recs, "FREP1", [CMD_FREP, 0x0111], CMD_FREP, 10.0)
        if not f1["echo"]:
            raise GateAbort("ABORT_REPAIR_OR_CONTROL_PATH", "REPAIR_CONTROL", "FREP1 echo missing")
        r1 = do_fobs(ser, recs, "FOBS_AFTER_FREP1")
        require_fobs(
            r1,
            {"life": 2, "sar": 1, "fr": 0, "ft": 2, "key": KEY},
            "ABORT_REPAIR_OR_CONTROL_PATH",
            "REPAIR_CONTROL",
        )
        extra["FREP1_GATE"] = "PASS"

        f2 = cmd_echo(ser, recs, "FREP2", [CMD_FREP, 0x0111], CMD_FREP, 10.0)
        if not f2["echo"]:
            raise GateAbort("ABORT_REPAIR_OR_CONTROL_PATH", "REPAIR_CONTROL", "FREP2 echo missing")
        r2 = do_fobs(ser, recs, "FOBS_AFTER_FREP2")
        require_fobs(
            r2,
            {"life": 2, "sar": 2, "fr": 0},
            "ABORT_REPAIR_OR_CONTROL_PATH",
            "REPAIR_CONTROL",
        )
        extra["FREP2_GATE"] = "PASS"

        f3 = cmd_echo(ser, recs, "FREP3", [CMD_FREP, 0x0111], CMD_FREP, 10.0)
        if not f3["echo"]:
            raise GateAbort("ABORT_REPAIR_OR_CONTROL_PATH", "REPAIR_CONTROL", "FREP3 echo missing")
        r3 = do_fobs(ser, recs, "FOBS_AFTER_FREP3")
        require_fobs(
            r3,
            {"life": 2, "sar": 3, "fr": 0, "ft": 2, "key": KEY, "compacted": 0},
            "ABORT_REPAIR_OR_CONTROL_PATH",
            "REPAIR_CONTROL",
        )
        extra["FREP3_GATE"] = "PASS"

        fcmp = cmd_echo(ser, recs, "FCMP", [CMD_FCMP], CMD_FCMP, 20.0)
        if not fcmp["echo"]:
            raise GateAbort("ABORT_COMPACTION_LIFECYCLE", "COMPACTION_LIFECYCLE", "FCMP echo missing")
        cmpo = do_fobs(ser, recs, "FOBS_AFTER_FCMP")
        require_fobs(
            cmpo,
            {
                "cmp_result": 0,
                "life": 3,
                "compacted": 1,
                "ft": 2,
                "fr": 0,
                "sar": 3,
                "key": KEY,
            },
            "ABORT_COMPACTION_LIFECYCLE",
            "COMPACTION_LIFECYCLE",
        )
        extra["FCMP_FOBS"] = cmpo["decode"]

        b0 = do_dest_read(ser, recs, "DEST_READ_0200000_BEFORE_FRST", FEM_HDR_BEAT)
        b1 = do_dest_read(ser, recs, "DEST_READ_0200010_BEFORE_FRST", FEM_COMMIT_BEAT)
        extra["DEST_BEAT_0200000_BEFORE_FRST"] = b0.get("beat")
        extra["DEST_BEAT_0200010_BEFORE_FRST"] = b1.get("beat")

        beat0 = [int(x, 16) for x in (b0.get("beat") or [])]
        beat1 = [int(x, 16) for x in (b1.get("beat") or [])]
        extra["HDR_LANE_CHECK"] = None
        extra["COMMIT_LANE_CHECK"] = None
        if len(beat0) == 4:
            extra["HDR_LANE_CHECK"] = {
                "lane0_hdr": f"{beat0[0]:08x}",
                "lane0_want": f"{HDR_COMPACTED:08x}",
                "lane0_ok": int(beat0[0] == HDR_COMPACTED),
                "lane1_w0": f"{beat0[1]:08x}",
                "lane1_want": f"{P_W0:08x}",
                "lane1_ok": int(beat0[1] == P_W0),
                "lane2_w1": f"{beat0[2]:08x}",
                "lane2_want": f"{P_W1:08x}",
                "lane2_ok": int(beat0[2] == P_W1),
                "lane3_crcw": f"{beat0[3]:08x}",
                "lane3_want": f"{EXPECT_CRCW:08x}",
                "lane3_mark_ok": int((beat0[3] >> 16) == CRC_MARK),
                "lane3_crc_ok": int(beat0[3] == EXPECT_CRCW),
            }
        if len(beat1) == 4:
            extra["COMMIT_LANE_CHECK"] = {
                "lane0_commit": f"{beat1[0]:08x}",
                "lane0_want": f"{COMMIT_MAGIC:08x}",
                "lane0_ok": int(beat1[0] == COMMIT_MAGIC),
                "lane1_index": f"{beat1[1]:08x}",
                "lane1_want": f"{INDEX_ONE:08x}",
                "lane1_ok": int(beat1[1] == INDEX_ONE),
                "lane2_hdr2": f"{beat1[2]:08x}",
                "lane2_want": f"{HDR2_RESOLVED:08x}",
                "lane2_ok": int(beat1[2] == HDR2_RESOLVED),
            }

        if not extra.get("COMMIT_LANE_CHECK") or not extra["COMMIT_LANE_CHECK"]["lane0_ok"]:
            extra["FIRST_DIVERGENCE"] = "MIG_WRITE_OR_READBACK"
            extra["ROOT_CAUSE_STATUS"] = "COMPACTION_FOBS_OK_COMMIT_MAGIC_MISSING"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_PHYSICAL_COMMIT_MISSING"
            if extra.get("HDR_LANE_CHECK") and not extra["HDR_LANE_CHECK"]["lane1_ok"]:
                extra["FIRST_DIVERGENCE"] = "FEM_ADDRESS_MAPPING"
                extra["ROOT_CAUSE_STATUS"] = "COMPACTION_FOBS_OK_HDR_BEAT_MISMATCH"
            write_out(recs, extra)
            return 7

        cmd_echo(ser, recs, "FRST_POST", [CMD_FRST], CMD_FRST, 8.0)
        after_rst = do_fobs(ser, recs, "FOBS_AFTER_FRST")
        require_fobs(
            after_rst,
            {"life": 7, "n_raw": 0, "key": 0, "compacted": 0},
            "ABORT_FEM_RESET_SCOPE",
            "FEM_RESET_SCOPE",
        )
        extra["AFTER_FRST_FOBS"] = after_rst["decode"]

        a0 = do_dest_read(ser, recs, "DEST_READ_0200000_AFTER_FRST", FEM_HDR_BEAT)
        a1 = do_dest_read(ser, recs, "DEST_READ_0200010_AFTER_FRST", FEM_COMMIT_BEAT)
        extra["DEST_BEAT_0200000_AFTER_FRST"] = a0.get("beat")
        extra["DEST_BEAT_0200010_AFTER_FRST"] = a1.get("beat")
        if a0.get("beat") != b0.get("beat") or a1.get("beat") != b1.get("beat"):
            extra["FIRST_DIVERGENCE"] = "FEM_RESET_SCOPE"
            extra["ROOT_CAUSE_STATUS"] = "FEM_RESET_SCOPE_OR_MEDIA_RETENTION_FAILURE"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_MEDIA_CHANGED_ACROSS_FRST"
            write_out(recs, extra)
            return 8
        if not a1.get("commit_magic"):
            extra["FIRST_DIVERGENCE"] = "FEM_RESET_SCOPE"
            extra["ROOT_CAUSE_STATUS"] = "FEM_RESET_SCOPE_OR_MEDIA_RETENTION_FAILURE"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_COMMIT_LOST_ACROSS_FRST"
            write_out(recs, extra)
            return 8

        cmd_echo(ser, recs, "FREC", [CMD_FREC], CMD_FREC, 20.0)
        recov = do_fobs(ser, recs, "FOBS_AFTER_FREC")
        require_fobs(
            recov,
            {
                "recov": 2,
                "life": 3,
                "compacted": 1,
                "ft": 2,
                "fr": 0,
                "sar": 3,
                "key": KEY,
                "n_raw": 0,
                "integrity_fault": 0,
            },
            "ABORT_RECOVERY_CLASSIFICATION",
            "RECOVERY_CLASSIFICATION",
        )
        extra["AFTER_FREC_FOBS"] = recov["decode"]
        if recov["decode"].get("integrity_fault"):
            extra["FIRST_DIVERGENCE"] = "DATA_INTEGRITY"
            extra["ROOT_CAUSE_STATUS"] = "INTEGRITY_FAULT"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_DATA_INTEGRITY"
            write_out(recs, extra)
            return 9

        post = do_dest_read(ser, recs, "DEST_READ_0200010_AFTER_FREC", FEM_COMMIT_BEAT)
        extra["DEST_BEAT_0200010_AFTER_FREC"] = post.get("beat")
        if not post.get("commit_magic"):
            extra["FIRST_DIVERGENCE"] = "DATA_INTEGRITY"
            extra["ROOT_CAUSE_STATUS"] = "COMMIT_LOST_AFTER_FREC"
            extra["BOARD_CANDIDATE_RESULT"] = "ABORT_COMMIT_AFTER_FREC"
            write_out(recs, extra)
            return 10

        extra["FIRST_DIVERGENCE"] = "NONE"
        extra["ROOT_CAUSE_STATUS"] = "LEGAL_COMPACT_COMMIT_FRST_FREC_OBSERVED"
        extra["BOARD_CANDIDATE_RESULT"] = "FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE"
        extra["CLAIM_CEILING"] = (
            "FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO "
            "MIG_PASS=NO TIMING_PASS=NO PACK_ABI_24_24_PASS=NO"
        )
        write_out(recs, extra)
        print("BOARD_CANDIDATE_RESULT", extra["BOARD_CANDIDATE_RESULT"])
        return 0
    except GateAbort as exc:
        extra["BOARD_CANDIDATE_RESULT"] = exc.cut
        extra["FIRST_DIVERGENCE"] = exc.divergence
        extra["ROOT_CAUSE_STATUS"] = exc.detail
        gate_map = {
            "ABORT_PRECONDITION_NOT_VIRGIN": "PRECONDITION",
            "ABORT_INGRESS_STATE_MISMATCH": "INGRESS_GATE",
            "ABORT_REPAIR_OR_CONTROL_PATH": "FREP_GATE_FAIL",
            "ABORT_COMPACTION_LIFECYCLE": "FCMP_FOBS",
            "ABORT_FEM_RESET_SCOPE": "AFTER_FRST_FOBS",
            "ABORT_RECOVERY_CLASSIFICATION": "AFTER_FREC_FOBS",
        }
        key = gate_map.get(exc.cut)
        if key:
            extra[key] = f"FAIL {exc.detail}"
        if extra["PRECONDITION"] == "NOT_RUN" and exc.cut == "ABORT_PRECONDITION_NOT_VIRGIN":
            extra["PRECONDITION"] = "FAIL"
        write_out(recs, extra)
        print("ABORT", exc.cut, exc.divergence, exc.detail)
        return 11
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
