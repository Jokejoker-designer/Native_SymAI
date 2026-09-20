"""U33 three-stage parser discriminator. Default is offline plan only.

Execution examples and outputs: README.md. No programming, process termination,
hidden retry, input-buffer reset, product changes, or full Pack acceptance claim.
UART execution requires real owner coordination; --execute is not that authority.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import time
from datetime import datetime, timezone
from pathlib import Path

BASE = Path(r"D:\FPGA\arty_d\UART_R2")
CANON = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
MEM = CANON / "verification/pack_abi24/out/PA24-V-04.mem"
BIT = BASE / "build_u33/uart_r2_u33_candidate.bit"
BIT_SHA = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
MEM_SHA = "01bb177e88cfb93eaf9e50b2a91420d489fafba6032644c58f3fa8629c3c2e60"
CLEAR, ACK, BEGIN, MAGIC = 0x44524743, 0xC1EA50A5, 0x00800001, 0x3149414E
MAG, UNSUP = 0x0200015A, 0x0200075A


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def stages() -> tuple[list[list[int]], dict]:
    mh, bh = digest(MEM), digest(BIT)
    if mh != MEM_SHA or bh != BIT_SHA:
        raise RuntimeError("SOURCE_IDENTITY_MISMATCH; no UART access permitted")
    values = [int(x.strip(), 16) for x in MEM.read_text().splitlines() if x.strip()]
    words = values[1:]
    if values[0] != 52 or len(words) != 52 or words[:2] != [BEGIN, MAGIC] or words[32] != 0:
        raise RuntimeError("WRONG_CANONICAL_HEADER")
    # No Region or Page command is intentionally sent. In an arbitrary corrupt
    # prior parser state this cannot guarantee that no memory write occurs.
    seq = [words[:32], [words[32]], [0x00000004]]
    return seq, {"mem_path": str(MEM), "mem_sha256": mh, "bit_path": str(BIT),
                 "disk_bit_sha256": bh, "board_identity_readback": "NOT_PERFORMED"}


def classify(phase: int, raw: bytes) -> str:
    if not raw:
        return "SILENT" if phase < 3 else "INCONCLUSIVE_NO_TERMINAL_RESPONSE"
    if len(raw) != 4:
        return "INCONCLUSIVE_REPLY_LENGTH"
    token = int.from_bytes(raw, "little")
    if token == MAG:
        return {1: "EARLY_MANIFEST_COMPLETION", 2: "BAD_MAGIC_AT_EXPECTED_COUNT",
                3: "BAD_MAGIC_AFTER_EXTRA_WORD"}[phase]
    if phase == 3 and token == UNSUP:
        return "HEADER_ALIGNED_POSITIVE_CONTROL_ONLY"
    return "UNEXPECTED_TOKEN"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--execute", action="store_true", help="Use UART only after actual owner authorization")
    ap.add_argument("--port")
    ap.add_argument("--resident-sha256", help="Owner-recorded resident identity; not hardware readback")
    ap.add_argument("--grant-ref", help="Reference to actual owner/D coordination, recorded verbatim")
    ap.add_argument("--out", type=Path, help="New JSONL file; existing files are refused")
    ap.add_argument("--rounds", type=int, default=1)
    ap.add_argument("--warmup-packs", type=int, default=0,
                    help="0..4 V04 packs before staged probe, or 1..24 with --full-v04-only; writes test payload to DDR")
    ap.add_argument("--full-v04-only", action="store_true",
                    help="Run only the bounded repeated V04 campaign; never implies Pack ABI 24-case acceptance")
    ap.add_argument("--phase-window-s", type=float, default=0.5)
    ap.add_argument("--reply-tail-s", type=float, default=0.0,
                    help="End CLEAR/V04/stage reply window after >=4 bytes then this quiet tail; 0 keeps full window")
    ap.add_argument("--post-gold-drain-s", type=float, default=0.0,
                    help="Observe idle after each warmup GOLD; unexpected extra bytes stop the run")
    args = ap.parse_args()
    if not 1 <= args.rounds <= 16 or not 0.1 <= args.phase_window_s <= 3:
        ap.error("rounds must be 1..16; phase-window-s must be 0.1..3")
    if args.full_v04_only:
        if not 1 <= args.warmup_packs <= 24 or args.rounds != 1:
            ap.error("full-v04-only requires warmup-packs=1..24 and rounds=1")
    elif not 0 <= args.warmup_packs <= 4:
        ap.error("warmup-packs must be 0..4 for staged mode")
    if not 0 <= args.reply_tail_s <= 0.5 or not 0 <= args.post_gold_drain_s <= 1:
        ap.error("reply-tail-s must be 0..0.5; post-gold-drain-s must be 0..1")
    seq, identity = stages()
    plan = {"mode": "UART_PREFIX_DIAGNOSTIC", "identity": identity,
            "stages": [{"phase": i + 1, "words": len(w), "bytes": 4 * len(w),
                        "begin_count": w.count(BEGIN)} for i, w in enumerate(seq)],
            "claim_ceiling": "PACK_ABI_24_24_PASS=NO; BOARD_PASS=NO; PROGRAM=NO",
            "warmup_packs": args.warmup_packs,
            "full_v04_only": args.full_v04_only,
            "reply_tail_s": args.reply_tail_s,
            "post_gold_drain_s": args.post_gold_drain_s,
            "note": "Timing is diagnostic, not a replay of the original campaign."}
    if not args.execute:
        print(json.dumps(plan, indent=2))
        return 0
    if not all((args.port, args.resident_sha256, args.grant_ref, args.out)):
        ap.error("live mode requires --port, --resident-sha256, --grant-ref and --out")
    if args.resident_sha256.lower() != BIT_SHA:
        ap.error("resident identity must be the approved U33 identity")

    import serial
    from serial.tools import list_ports

    matches = [p for p in list_ports.comports() if p.device.upper() == args.port.upper()]
    if len(matches) != 1 or (matches[0].serial_number or "").upper() != "210319BE776EB":
        raise RuntimeError("PORT_SERIAL_MISMATCH; no port opened")
    start = time.monotonic_ns()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive create preserves all failed evidence and prevents accidental rerun overwrite.
    with args.out.open("x", encoding="utf-8") as log:
        def emit(kind: str, **fields) -> None:
            row = {"kind": kind, "t_ns": time.monotonic_ns() - start, **fields}
            log.write(json.dumps(row, ensure_ascii=False) + "\n")
            log.flush()

        def read_window(ser, label: str, seconds: float, early_reply: bool = False) -> bytes:
            deadline = time.monotonic() + seconds
            quiet_deadline = None
            buf = bytearray()
            while time.monotonic() < deadline:
                if quiet_deadline is not None and time.monotonic() >= quiet_deadline:
                    break
                chunk = ser.read(max(1, ser.in_waiting))
                if chunk:
                    buf.extend(chunk)
                    emit("rx_chunk", label=label, raw_hex=chunk.hex(), n=len(chunk))
                    if early_reply and args.reply_tail_s and len(buf) >= 4:
                        quiet_deadline = time.monotonic() + args.reply_tail_s
            emit("rx_window", label=label, raw_hex=buf.hex(), n=len(buf))
            return bytes(buf)

        def transmit(ser, label: str, words: list[int]) -> None:
            payload = b"".join(w.to_bytes(4, "little") for w in words)
            emit("tx_begin", label=label, raw_hex=payload.hex(), n=len(payload),
                 sha256=hashlib.sha256(payload).hexdigest(), begin_count=words.count(BEGIN))
            count = ser.write(payload)
            emit("tx_write_return", label=label, nwritten=count)
            ser.flush()
            emit("tx_flush_return", label=label)
            if count != len(payload):
                raise RuntimeError("SHORT_WRITE; no retry")

        emit("session", utc=datetime.now(timezone.utc).isoformat(), plan=plan,
             grant_ref=args.grant_ref, resident_sha256_claim=args.resident_sha256,
             phase_window_s=args.phase_window_s)
        ser = serial.Serial()
        ser.port = args.port
        ser.baudrate = 115200
        ser.bytesize, ser.parity, ser.stopbits = serial.EIGHTBITS, serial.PARITY_NONE, serial.STOPBITS_ONE
        ser.timeout, ser.write_timeout = 0.01, 8.0
        ser.dtr, ser.rts = False, False
        try:
            ser.open()
            # Record startup traffic instead of discarding it or resetting input buffers.
            initial = read_window(ser, "OPEN_IDLE", 2.0)
            if initial:
                emit("stop", reason="PREEXISTING_RX_TRAFFIC")
                return 2
            if args.warmup_packs:
                vals = [int(x.strip(), 16) for x in MEM.read_text().splitlines() if x.strip()]
                full_v04 = vals[1:]
                for warm in range(args.warmup_packs):
                    transmit(ser, f"warm{warm}_CLEAR", [CLEAR])
                    raw = read_window(ser, f"warm{warm}_CLEAR", 3.0, early_reply=True)
                    if raw != ACK.to_bytes(4, "little"):
                        emit("stop", reason="WARMUP_CLEAR_NOT_EXACT_ACK", warmup=warm)
                        print("WARMUP_CLEAR", warm, raw.hex())
                        return 2
                    transmit(ser, f"warm{warm}_V04", full_v04)
                    raw = read_window(ser, f"warm{warm}_V04", max(args.phase_window_s, 1.0), early_reply=True)
                    print("WARMUP_V04", warm, raw.hex())
                    if raw != (0x010000A5).to_bytes(4, "little"):
                        emit("stop", reason="WARMUP_V04_NOT_EXACT_GOLD", warmup=warm,
                             raw_hex=raw.hex())
                        return 1
                    emit("warmup_gold", warmup=warm)
                    if args.post_gold_drain_s:
                        extra = read_window(ser, f"warm{warm}_GOLD_DRAIN", args.post_gold_drain_s)
                        if extra:
                            emit("stop", reason="EXTRA_RX_AFTER_GOLD", warmup=warm, raw_hex=extra.hex())
                            return 1
            if args.full_v04_only:
                emit("complete", verdict="REPEATED_V04_ONLY_NOT_PACK_ABI_24_CASES",
                     v04_gold=args.warmup_packs)
                return 0
            for rnd in range(args.rounds):
                transmit(ser, f"r{rnd}_CLEAR", [CLEAR])
                raw = read_window(ser, f"r{rnd}_CLEAR", 3.0, early_reply=True)
                if raw != ACK.to_bytes(4, "little"):
                    emit("stop", reason="CLEAR_NOT_EXACT_ACK", round=rnd)
                    return 2
                for phase, words in enumerate(seq, 1):
                    label = f"r{rnd}_PHASE{phase}"
                    transmit(ser, label, words)
                    raw = read_window(ser, label, args.phase_window_s, early_reply=True)
                    verdict = classify(phase, raw)
                    emit("classification", round=rnd, phase=phase, verdict=verdict)
                    print(label, verdict, raw.hex())
                    if verdict != "SILENT" and verdict != "HEADER_ALIGNED_POSITIVE_CONTROL_ONLY":
                        emit("stop", reason=verdict, round=rnd, phase=phase)
                        return 1
            emit("complete", verdict="PREFIX_CONTROL_ONLY_NOT_PACK24_PASS")
            return 0
        except Exception as exc:
            emit("error", error_type=type(exc).__name__, message=str(exc))
            raise
        finally:
            ser.close()
            emit("port_closed")


if __name__ == "__main__":
    raise SystemExit(main())
