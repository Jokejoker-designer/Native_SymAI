"""U33OBS TAP decoder + capture scaffold. Does not program. Not PACK_ABI.

generation_flipped four-AND is TAP word 6:
  commit_seen AND same_capture_epoch AND capture_valid_at AND bit16
plus word7 != word8. Snapshots are Pack S_COMMIT, not idle dumps across CLEAR.
"""
from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

TAP1 = 0x31504154
BEGINW = 0x00800001
DUMPW = 0x44554D50
CLR_CMD = 0x44524743
GOLD = 0x010000A5
MAG = 0x0200015A
GEN_MAGIC = 0x47
WANT_BIT = "71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u33obs\uart_r2_u33obs_candidate.bit")
OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\U33OBS_CAPTURE")


def words_from_le_hex(raw_hex: str) -> list[int]:
    hx = (raw_hex or "").replace(" ", "")
    out = []
    for i in range(0, len(hx) - (len(hx) % 8), 8):
        chunk = hx[i : i + 8]
        b = bytes.fromhex(chunk)
        out.append(int.from_bytes(b, "little"))
    return out


def decode_tap(words: list[int]) -> dict:
    rec = {
        "n": len(words),
        "tap1": None,
        "uart0": None,
        "uart1": None,
        "load0": None,
        "load1": None,
        "marker": None,
        "gen_stat": None,
        "generation_before": None,
        "generation_after": None,
        "commit_event": None,
        "same_capture_epoch": None,
        "capture_valid": None,
        "generation_flipped": None,
        "hw_generation_flipped": None,
        "identity": "UNKNOWN",
        "class": "INSUFFICIENT",
        "PACK_ABI_24_24_PASS": "NO",
    }
    if not words or words[0] != TAP1:
        rec["class"] = "NO_TAP1"
        return rec
    rec["tap1"] = f"{words[0]:08x}"
    if len(words) < 5:
        rec["class"] = "SHORT_SOF"
        return rec
    rec["uart0"] = f"{words[1]:08x}"
    rec["uart1"] = f"{words[2]:08x}"
    rec["load0"] = f"{words[3]:08x}"
    rec["load1"] = f"{words[4]:08x}"
    if len(words) >= 6:
        rec["marker"] = f"{words[5]:08x}"
    if len(words) < 9:
        rec["identity"] = "NOT_U33OBS_GEN"
        rec["class"] = "SOF_ONLY_NO_GEN"
        rec["hop"] = hop_class(words[3], words[4])
        return rec
    rec["identity"] = "U33OBS_GEN"
    rec["gen_stat"] = f"{words[6]:08x}"
    rec["generation_before"] = f"{words[7]:08x}"
    rec["generation_after"] = f"{words[8]:08x}"
    st = words[6]
    if (st >> 24) != GEN_MAGIC:
        rec["class"] = "GEN_MAGIC_BAD"
        rec["hop"] = hop_class(words[3], words[4])
        return rec
    commit = (st >> 19) & 1
    same = (st >> 18) & 1
    cap = (st >> 17) & 1
    flip = (st >> 16) & 1
    rec["commit_event"] = commit
    rec["same_capture_epoch"] = same
    rec["capture_valid"] = cap
    rec["hw_generation_flipped"] = flip
    rec["epoch"] = st & 0xFFFF
    rec["generation_flipped"] = mapper().observe_from_tap_gen(st, words[7], words[8])
    rec["hop"] = hop_class(words[3], words[4])
    rec["class"] = rec["hop"]
    return rec


_MAPPER = None


def mapper():
    global _MAPPER
    if _MAPPER is not None:
        return _MAPPER
    p = Path(r"D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator\uart_token_to_compare.py")
    spec = importlib.util.spec_from_file_location("uart_token_to_compare", p)
    if spec is None or spec.loader is None:
        raise RuntimeError("uart_token_to_compare missing")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    _MAPPER = mod
    return mod


def hop_class(p0: int, p1: int) -> str:
    if p0 == BEGINW and p1 == BEGINW:
        return "CLASS_A_p1_BEGIN first_divergent=p1"
    if p0 == 0 and p1 == 0:
        return "LOADER_EMPTY"
    if p0 == BEGINW:
        return f"CLASS_P1_OTHER p1={p1:08x}"
    return f"CLASS_P0_NOT_BEGIN p0={p0:08x}"


def collect_words_from_bytes(buf: bytes) -> list[int]:
    n = len(buf) - (len(buf) % 4)
    return [int.from_bytes(buf[i : i + 4], "little") for i in range(0, n, 4)]


def classify_status(word: int | None, n: int) -> str:
    if n == 0 or word is None:
        return "MUTE_n0"
    if word == GOLD:
        return "GOLD"
    if word == MAG:
        return "MAG"
    if word == 0xC1EA50A5:
        return "CLEAR_ACK"
    if word == 0xC1EA50B5:
        return "CLEAR_BUSY"
    return f"OTHER_{word:08x}"


def campaign_plan() -> dict:
    return {
        "identity": "uart_r2_u33obs_CANDIDATE",
        "bit": str(BIT),
        "want_sha256": WANT_BIT,
        "program": "OWNER_YES_REQUIRED run_program_u33obs.bat OWNER_AUTHORIZED",
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "no_pack24_on_obs": True,
        "generation_flipped_law": (
            "commit_event==1 AND generation_after!=generation_before "
            "AND same_capture_epoch AND capture_valid==1 "
            "from Pack S_COMMIT, not idle snapshots across CLEAR/reset/epoch"
        ),
        "steps_after_program": [
            {
                "id": "0_sram_gate",
                "do": "DUMP 44554D50; require TAP 9 words and gen magic 0x47. Else IDENTITY_NOT_OBS (TAPCDC still SRAM).",
            },
            {
                "id": "1_dummy_open",
                "do": "COM open MARK_S=2 close; gap 200ms; real open MARK_S=2; CLEAR; one V-04. MUTE=n=0 vs MAG vs GOLD.",
            },
            {
                "id": "2_leftover_mag",
                "do": "CLEAR ACK; extra BEGIN; V-04; expect MAG then TAP CLASS_A p1=BEGIN; generation_flipped absent (no COMMIT).",
            },
            {
                "id": "3_dump_mute",
                "do": "CLEAR ACK; DUMP; TAP uart CLEAR/DUMP loader empty; no NAK; flip=false.",
            },
            {
                "id": "4_gold_four_and",
                "do": "CLEAR ACK; V-04 GOLD; DUMP; TAP four-AND before!=after. Not Pack24.",
            },
        ],
    }


def selfcheck() -> int:
    gold = [
        TAP1,
        CLR_CMD,
        BEGINW,
        BEGINW,
        BEGINW,
        0xA100011A,
        0x470F0002,
        0xFFFFFFFF,
        0x0000FFFF,
    ]
    leftover = [
        TAP1,
        CLR_CMD,
        BEGINW,
        BEGINW,
        BEGINW,
        0xA100011A,
        0x47000002,
        0x00000000,
        0x00000000,
    ]
    dump = [
        TAP1,
        CLR_CMD,
        DUMPW,
        0,
        0,
        0xA100031A,
        0x47000002,
        0,
        0,
    ]
    g = decode_tap(gold)
    l = decode_tap(leftover)
    d = decode_tap(dump)
    fail = 0
    if g["generation_flipped"] != 1:
        print("FAIL gold four-AND")
        fail = 1
    if l["generation_flipped"] is not None:
        print("FAIL leftover invented flip")
        fail = 1
    if d["generation_flipped"] is not None:
        print("FAIL dump invented flip")
        fail = 1
    if "CLASS_A" not in l["class"]:
        print("FAIL leftover hop", l["class"])
        fail = 1
    if d["class"] != "LOADER_EMPTY":
        print("FAIL dump hop", d["class"])
        fail = 1
    print("GOLD", json.dumps({k: g[k] for k in ("generation_flipped", "commit_event", "same_capture_epoch", "capture_valid", "generation_before", "generation_after")}))
    print("LEFTOVER", l["class"], "flip", l["generation_flipped"])
    print("DUMP", d["class"], "flip", d["generation_flipped"])
    tapcdc = [TAP1, CLR_CMD, BEGINW, BEGINW, BEGINW, 0xA108011A]
    tcdc = decode_tap(tapcdc)
    if tcdc["identity"] != "NOT_U33OBS_GEN":
        print("FAIL TAPCDC 6-word misread as OBS")
        fail = 1
    payload = b"".join(w.to_bytes(4, "little") for w in gold)
    le = words_from_le_hex(payload.hex())
    if le != gold:
        print("FAIL LE roundtrip", le)
        fail = 1
    if collect_words_from_bytes(payload) != gold:
        print("FAIL collect_words")
        fail = 1
    if classify_status(None, 0) != "MUTE_n0":
        print("FAIL MUTE class")
        fail = 1
    idle_delta = [
        TAP1,
        CLR_CMD,
        BEGINW,
        BEGINW,
        BEGINW,
        0xA100011A,
        0x47060002,
        0xFFFFFFFF,
        0x0000FFFF,
    ]
    idle = decode_tap(idle_delta)
    if idle["generation_flipped"] is not None:
        print("FAIL idle snapshot delta invented flip", idle)
        fail = 1
    m = mapper()
    v04 = m.map_row("PA24-V-04", GOLD, 4, generation_flipped=g["generation_flipped"])
    if not v04.get("compare_ready") or v04.get("generation_flipped") != 1:
        print("FAIL DUT V-04", v04)
        fail = 1
    mag = m.map_row("PA24-A-01", MAG, 4, generation_flipped=l["generation_flipped"])
    if mag.get("compare_ready") or "generation_flipped" in mag:
        print("FAIL DUT leftover flip", mag)
        fail = 1
    OUT.mkdir(parents=True, exist_ok=True)
    plan = campaign_plan()
    plan["dut_map"] = (
        "generation_flipped from observe_from_tap_gen four-AND only; "
        "UART GOLD/MAG never invents the field; idle snapshot delta stays absent"
    )
    (OUT / "U33OBS_CAMPAIGN_PLAN.json").write_text(json.dumps(plan, indent=2), encoding="utf-8")
    print("PLAN", OUT / "U33OBS_CAMPAIGN_PLAN.json")
    print("PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO")
    if fail:
        print("FAIL")
        return 1
    print("PASS_SELFCHECK TAP four-AND decoder + DUT map")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) <= 1 or argv[1] in {"--selfcheck", "selfcheck"}:
        return selfcheck()
    if argv[1] == "--board":
        print("uart_r2_u33obs_CAPTURE_REFUSED need programmed OBS + owner YES; this argv does not program")
        print("PACK_ABI_24_24_PASS=NO")
        return 4
    print("usage: u33obs_capture.py --selfcheck")
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
