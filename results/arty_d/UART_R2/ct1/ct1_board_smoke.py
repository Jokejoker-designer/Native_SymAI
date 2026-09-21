"""CT1 silicon UART smoke after unique 8bfd993d program.

CT1-01 query UNSET miss; CT1-02 Pack A->B hit; CT1-03 CLEAR UNSET miss;
CT1-04 Pack A->C hit. CT1-05 flush is bitstream-tied-off: NOT_RUN.
Does not edit gold.py. PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO. Not CT1_BOARD_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import collect_words_from_bytes  # noqa: E402
from u33obs_hops import (  # noqa: E402
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

WANT = "8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c"
BAN_LIVE = "8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5"
PROG = Path(r"D:\FPGA\arty_d\UART_R2\results\CT1_OWNER_PROGRAM_20260921\PROGRAM.txt")
MEM = Path(r"D:\FPGA\arty_d\UART_R2\ct1\xsim")
OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\CT1_OWNER_PROGRAM_20260921")
SID_A = 0x00010100
Q_MISS = 0x03000051
Q_HIT = 0x03010051
GOLD_HI = 0x01
GOLD_LO = 0xA5


def load_mem(name: str) -> list[int]:
    path = MEM / name
    lines = [ln.strip() for ln in path.read_text(encoding="ascii").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{name} short {len(words)}/{nwords}")
    return words


def crc16_step(c: int, b: int) -> int:
    x = c ^ (b << 8)
    for _ in range(8):
        x = ((x << 1) & 0xFFFF) ^ 0x1021 if x & 0x8000 else ((x << 1) & 0xFFFF)
    return x


def query_words() -> list[int]:
    q = [0] * 32
    q[0] = 0x51
    q[1] = 0x4E
    q[2] = 0x01
    q[3] = 0x00
    q[4] = 0x01
    q[14] = SID_A & 0xFF
    q[15] = (SID_A >> 8) & 0xFF
    q[16] = (SID_A >> 16) & 0xFF
    q[17] = (SID_A >> 24) & 0xFF
    c = 0xFFFF
    for i in range(30):
        c = crc16_step(c, q[i])
    q[30] = c & 0xFF
    q[31] = (c >> 8) & 0xFF
    return [
        q[i] | (q[i + 1] << 8) | (q[i + 2] << 16) | (q[i + 3] << 24)
        for i in range(0, 32, 4)
    ]


def scan_tok(words: list[int], hi: int, lo: int) -> int | None:
    for w in words:
        if ((w >> 24) & 0xFF) == hi and (w & 0xFF) == lo:
            return w
    return None


def step_query(ser, recs: list, name: str) -> dict:
    send_words(ser, query_words())
    buf = read_buf(ser, 4.0)
    words = collect_words_from_bytes(buf)
    tok = scan_tok(words, 0x03, 0x51)
    item = rec_of(buf, name)
    item["query_tok"] = None if tok is None else f"{tok:08x}"
    item["query_hit"] = 1 if tok == Q_HIT else 0
    recs.append(item)
    print(name, "n", item["n"], "tok", item["query_tok"], "words", [f"{w:08x}" for w in words[:8]])
    return item


def step_pack(ser, recs: list, name: str, mem: str) -> dict:
    send_words(ser, load_mem(mem))
    buf = read_buf(ser, 8.0)
    words = collect_words_from_bytes(buf)
    gold = scan_tok(words, GOLD_HI, GOLD_LO)
    nak = scan_tok(words, 0x02, 0x5A)
    item = rec_of(buf, name)
    item["gold"] = None if gold is None else f"{gold:08x}"
    item["nak"] = None if nak is None else f"{nak:08x}"
    recs.append(item)
    print(name, "n", item["n"], "gold", item["gold"], "nak", item["nak"])
    return item


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    prog = parse_program_txt(PROG)
    sha = (prog.get("SHA256") or "").lower()
    if sha != WANT:
        print("REFUSE program sha", sha, "want", WANT)
        return 4
    if sha == BAN_LIVE:
        print("REFUSE live 8fc14f25")
        return 4
    port = find_port()
    if not port:
        print("NO_UART FTDI 776EB")
        return 3
    kill_jtag()
    recs: list[dict] = []
    ser = open_mark(port)
    try:
        time.sleep(2.0)
        drain = rec_of(ser.read(max(1, ser.in_waiting or 1)) or b"", "0_drain")
        recs.append(drain)
        print("drain n", drain["n"])
        q01 = step_query(ser, recs, "CT1-01")
        p02 = step_pack(ser, recs, "CT1-02-pack", "CT1-A2B.mem")
        time.sleep(0.3)
        q02 = step_query(ser, recs, "CT1-02")
        clr = send_clear_until_ack(ser, recs, "CT1-03-clear")
        time.sleep(0.3)
        q03 = step_query(ser, recs, "CT1-03")
        p04 = step_pack(ser, recs, "CT1-04-pack", "CT1-A2C.mem")
        time.sleep(0.3)
        q04 = step_query(ser, recs, "CT1-04")
    finally:
        ser.close()

    ct1_01 = 1 if q01.get("query_tok") == f"{Q_MISS:08x}" else 0
    ct1_02 = 1 if (p02.get("gold") and q02.get("query_tok") == f"{Q_HIT:08x}") else 0
    ct1_03 = 1 if q03.get("query_tok") == f"{Q_MISS:08x}" else 0
    ct1_04 = 1 if (p04.get("gold") and q04.get("query_tok") == f"{Q_HIT:08x}") else 0
    out = {
        "task": "D-CT1-BOARD-SMOKE",
        "iso": now_iso(),
        "port": port,
        "sha256": sha,
        "program": "NO_SELF_STAMP",
        "PROGRAM_PASS": "NO",
        "PACK_ABI_24_24_PASS": "NO",
        "CT1_BOARD_PASS": "NO",
        "RUNTIME_KNOWLEDGE_BINDING_8_8_PASS": "NOT_RUN",
        "CT1_05": "NOT_RUN_FLUSH_TIED_OFF",
        "CT1_01": ct1_01,
        "CT1_02": ct1_02,
        "CT1_03": ct1_03,
        "CT1_04": ct1_04,
        "q01": q01.get("query_tok"),
        "q02": q02.get("query_tok"),
        "q03": q03.get("query_tok"),
        "q04": q04.get("query_tok"),
        "gold02": p02.get("gold"),
        "gold04": p04.get("gold"),
        "clear": clr.get("word") if clr else None,
        "recs": recs,
        "CLASS": "UART_BOARD_SMOKE_CANDIDATE" if (ct1_01 and ct1_02 and ct1_03 and ct1_04) else "UART_BOARD_SMOKE_FAIL",
    }
    path = OUT / "UART_CT1_BOARD.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("WROTE", path, "class", out["CLASS"], "01..04", ct1_01, ct1_02, ct1_03, ct1_04)
    return 0 if out["CLASS"] == "UART_BOARD_SMOKE_CANDIDATE" else 2


if __name__ == "__main__":
    raise SystemExit(main())
