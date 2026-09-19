"""U23 board: exclusive program U23 fcapz bit, arm ELA, drop JTAG, CLEAR, readout.
Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
Do not program fpgacapZero example bits. Do not patch U22.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    CLR_ACK,
    CLR_CMD,
    GOLD_OK,
    UART_TIMEOUT_S,
    dump_json,
    find_port,
    load_mem,
    now_iso,
    read_raw_stamped,
    send_words,
    sha256_file,
    kill_jtag_usb_servers,
)
import serial
import uart_r2_u9_board_test as u9mod

u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_U23")
OUT = u9mod.OUT
RAW = OUT / "RAW_UART"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u23\uart_r2_u23_candidate.bit")
TCL = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\vivado\tcl\97_program_uart_r2_u23.tcl"
)
WATCH = [
    Path(r"D:\NATIVEAI_FULL_EVIDENCE\CANON_BLUEPRINT\work\goal_m1\PROGRAM.txt"),
    Path(r"D:\NATIVEAI_FULL_EVIDENCE\CANON_BLUEPRINT\work\goal_m2\PROGRAM.txt"),
    Path(r"D:\NATIVEAI_FULL_EVIDENCE\CANON_BLUEPRINT\work\goal_m1_t2dump\PROGRAM.txt"),
    Path(r"D:\NATIVEAI_FULL_EVIDENCE\CANON_BLUEPRINT\work\goal_m1_dest\PROGRAM.txt"),
]
MARK_S = 2.0
VIVADO_SETTINGS = r"C:\2026.1\Vivado\settings64.bat"
HW_SERVER = r"C:\2026.1\Vivado\bin\hw_server.bat"
XSDB = r"C:\2026.1\Vivado\bin\xsdb.bat"

# Probe map must match u23 top ela_probe.
PROBES = [
    ("clr_take", 1, 0),
    ("spare1", 3, 1),
    ("clr_hold", 1, 4),
    ("uart_flush", 1, 5),
    ("mux_ready", 1, 6),
    ("clr_ack_valid", 1, 7),
    ("w_valid", 1, 8),
    ("w_ready", 1, 9),
    ("pack_lock", 1, 10),
    ("fifo_empty", 1, 11),
    ("uart_tx_valid", 1, 12),
    ("st_valid_100", 1, 13),
    ("qsc_100", 1, 14),
    ("mux_valid", 1, 15),
    ("fifo_wr_ready", 1, 16),
    ("rx_idle", 1, 17),
    ("fifo_flush", 1, 18),
    ("cdc_rst_100", 1, 19),
    ("clr_ack_ready", 1, 20),
    ("clr_ui_req", 1, 21),
    ("ack_c1", 1, 22),
    ("nack_c1", 1, 23),
    ("spare24", 4, 24),
    ("clr_st", 4, 28),
    ("w_data", 32, 32),
]


def snap_watch() -> dict:
    out = {}
    for p in WATCH:
        out[str(p)] = p.read_text(encoding="utf-8", errors="replace") if p.is_file() else "MISSING"
    return out


def decode(sample: int) -> dict:
    rec = {"raw": f"{sample:016x}"}
    for name, width, lsb in PROBES:
        rec[name] = (sample >> lsb) & ((1 << width) - 1)
    rec["w_data_hex"] = f"{rec['w_data']:08x}"
    rec["clr_st"] = int(rec["clr_st"])
    return rec


def open_mark(port: str) -> serial.Serial:
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 0.05
    ser.write_timeout = 8.0
    ser.dtr = False
    ser.rts = False
    last = None
    for _ in range(10):
        try:
            ser.open()
            last = None
            break
        except serial.SerialException as e:
            last = e
            time.sleep(0.4)
    if last is not None:
        raise last
    t0 = time.time()
    while time.time() - t0 < MARK_S:
        ser.read(max(1, ser.in_waiting))
    ser.reset_input_buffer()
    return ser


def start_hw_server() -> None:
    kill_jtag_usb_servers()
    time.sleep(0.5)
    subprocess.Popen(
        ["cmd", "/c", f"call {VIVADO_SETTINGS} && hw_server"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0),
    )
    time.sleep(3.0)


def ela_connect(trig: str = "take"):
    from fcapz import Analyzer, CaptureConfig, ProbeSpec, TriggerConfig, XilinxHwServerTransport

    t = XilinxHwServerTransport(
        host="127.0.0.1",
        port=3121,
        fpga_name="xc7a100t",
        bitfile=None,
        xsdb_path=XSDB,
        ready_probe_addr=0x0000,
        ready_probe_timeout=8.0,
    )
    t.connect()
    a = Analyzer(t)
    a.connect()
    probes = [ProbeSpec(name=n, width=w, lsb=lsb) for n, w, lsb in PROBES]
    if trig == "ack":
        tval, tmask = 0x80, 0x80
    elif trig == "pack":
        tval, tmask = 1 << 10, 1 << 10
    else:
        tval, tmask = 1, 1
    cfg = CaptureConfig(
        pretrigger=128,
        posttrigger=384,
        trigger=TriggerConfig(mode="value_match", value=tval, mask=tmask),
        sample_width=64,
        depth=1024,
        sample_clock_hz=100_000_000,
        probes=probes,
        startup_arm=False,
        trigger_delay=1,
    )
    return t, a, cfg


def classify_once(ela_st: dict | None, uart_rec: dict, trig: str) -> str:
    n = uart_rec.get("n", 0)
    ack = uart_rec.get("word") == f"{CLR_ACK:08x}"
    done = bool(ela_st and ela_st.get("done"))
    if n == 4 and ack and done:
        return "FIRST_CLEAR_ACK_AND_ELA_DONE"
    if n == 4 and ack and not done:
        return "FIRST_CLEAR_ACK_ELA_NOT_DONE"
    if n == 0 and done:
        return "HOST_N0_ELA_TRIGGERED"
    if n == 0 and ela_st is None:
        return "HOST_N0_NO_ELA"
    if n == 0 and not done:
        return "HOST_N0_ELA_NOT_TRIGGERED"
    return "UNCLASSIFIED"


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "p4ela"
    OUT.mkdir(parents=True, exist_ok=True)
    RAW.mkdir(parents=True, exist_ok=True)
    if not BIT.is_file():
        print("NO_BIT")
        return 2
    sha = sha256_file(BIT)
    print("U23_SHA", sha, "MODE", mode)
    pre = snap_watch()
    (OUT / "COLLISION_WATCH_PRE.json").write_text(json.dumps(pre, indent=2), encoding="utf-8")
    if mode == "settle":
        kill_jtag_usb_servers()
        time.sleep(5)
        return 0
    if mode == "program":
        rc = subprocess.call(["cmd", "/c", r"D:\FPGA\arty_d\UART_R2\u23\run_program_u23.bat"])
        post = snap_watch()
        (OUT / "COLLISION_WATCH_POST_PROGRAM.json").write_text(
            json.dumps({"rc": rc, "sha": sha, "post": post}, indent=2), encoding="utf-8"
        )
        print("PROGRAM_RC", rc)
        return rc
    if mode == "uart_once":
        kill_jtag_usb_servers()
        print("SETTLE_12S_NO_ELA")
        time.sleep(12.0)
        port = find_port()
        if not port:
            print("NO_COM")
            return 2
        ser = open_mark(port)
        recs = []
        try:
            send_words(ser, [CLR_CMD])
            c1 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR1", **c1})
            print("CLEAR1", c1["sub"], c1["n"], c1.get("raw_hex"))
        finally:
            ser.close()
        cls = classify_once(None, recs[0] if recs else {}, "none")
        print("E1_CLASS", cls)
        dump_json(
            "BOARD_E1_UART_ONCE.json",
            {
                "when": now_iso(),
                "sha": sha,
                "class": cls,
                "uart": recs,
                "ela": None,
                "PROGRAM_PASS": "NO",
                "BOARD_PASS": "NOT_EVIDENCED",
            },
        )
        return 0 if recs and recs[0].get("n") == 4 else 1
    if mode not in {"p4ela", "p4ela_ack", "p4ela_ack_once", "p4ela_take_once", "p4ela_pack_v04"}:
        print("usage: settle|program|uart_once|p4ela|p4ela_ack|p4ela_ack_once|p4ela_take_once|p4ela_pack_v04")
        return 2

    trig_ack = mode in {"p4ela_ack", "p4ela_ack_once"}
    trig_pack = mode == "p4ela_pack_v04"
    once = mode.endswith("_once") or trig_pack
    ela_trig = "pack" if trig_pack else ("ack" if trig_ack else "take")

    start_hw_server()
    t, a, cfg = ela_connect(ela_trig)
    try:
        info = a.probe()
        print("ELA_PROBE", info)
        a.configure(cfg)
        a.force_idle()
        a.arm()
        print("ELA_ARMED", a.status())
    finally:
        try:
            t.close()
        except Exception:
            pass
    kill_jtag_usb_servers()
    time.sleep(1.0)

    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    if once:
        ser = open_mark(port)
    else:
        dummy = open_mark(port)
        dummy.close()
        time.sleep(0.2)
        ser = open_mark(port)
    recs = []
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], c1["n"], c1.get("raw_hex"))
        if (not once) and c1.get("n", 0) == 0:
            send_words(ser, [CLR_CMD])
            c1r = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR1_RETRY", **c1r})
            print("CLEAR1_RETRY", c1r["sub"], c1r["n"], c1r.get("raw_hex"))
        if trig_pack:
            if c1.get("word") == f"{CLR_ACK:08x}":
                send_words(ser, load_mem("PA24-V-04"))
                v04 = read_raw_stamped(ser, UART_TIMEOUT_S)
                recs.append({"step": "V04_0", **v04})
                print("V04", v04["sub"], v04["n"], v04.get("raw_hex"))
            else:
                print("V04_SKIP_NO_ACK")
    finally:
        ser.close()

    start_hw_server()
    t2, a2, cfg2 = ela_connect(ela_trig)
    capture_err = None
    result_meta = {}
    try:
        st = a2.status()
        print("ELA_STATUS_AFTER_UART", st)
        result_meta["status_after_uart"] = st
        a2._config = cfg2
        a2._hw_timestamp_w = 0
        a2._hw_num_segments = 1
        result = None
        if st.get("done"):
            try:
                result = a2.capture(timeout=8.0)
            except TimeoutError as e:
                capture_err = str(e)
        else:
            capture_err = "ELA_NOT_DONE_AFTER_UART"
            print("ELA_NOT_DONE", st)
        if result is not None:
            tag = (
                "PACK_V04" if trig_pack else (
                    "ACK_ONCE" if once and trig_ack else (
                        "TAKE_ONCE" if once else ("ACK" if trig_ack else "")
                    )
                )
            )
            a2.write_json(result, str(OUT / f"ELA_CAPTURE{tag}.json"))
            a2.write_vcd(result, str(OUT / f"ELA_CAPTURE{tag}.vcd"))
            trig_i = result.config.pretrigger
            samples = result.samples
            decoded = [decode(s) for s in samples]
            at = decoded[trig_i] if trig_i < len(decoded) else {}
            cls = classify_once(st, recs[0] if recs else {}, ela_trig)
            result_meta.update(
                {
                    "n_samples": len(samples),
                    "trig_index": trig_i,
                    "at_trigger": at,
                    "class": cls,
                    "overflow": result.overflow,
                }
            )
            (OUT / f"ELA_DECODE{tag}.json").write_text(
                json.dumps({"at_trigger": at, "head": decoded[:8], "trig_win": decoded[max(0, trig_i - 4) : trig_i + 8]}, indent=2),
                encoding="utf-8",
            )
            print("ELA_CLASS", cls)
            print("ELA_AT_TRIG", at)
        else:
            cls = classify_once(st, recs[0] if recs else {}, ela_trig)
            result_meta["class"] = cls
            print("ELA_CLASS", cls)
    finally:
        try:
            t2.close()
        except Exception:
            pass
    kill_jtag_usb_servers()
    post = snap_watch()
    out_name = "BOARD_U23_V04.json" if trig_pack else (
        "BOARD_BASELINE_ACK.json" if trig_ack and not once else (
            "BOARD_E2_ACK_ONCE.json" if once and trig_ack else (
                "BOARD_E2_TAKE_ONCE.json" if once else "BOARD_BASELINE.json"
            )
        )
    )
    dump_json(
        out_name,
        {
            "when": now_iso(),
            "sha": sha,
            "uart": recs,
            "ela": result_meta,
            "capture_err": capture_err,
            "watch_post": {k: ("CHANGED" if pre.get(k) != v else "SAME") for k, v in post.items()},
            "PROGRAM_PASS": "NO",
            "BOARD_PASS": "NOT_EVIDENCED",
            "PACK_ABI_24_24_PASS": "NO",
        },
    )
    print("U23_P4ELA_DONE")
    if trig_pack:
        vrec = next((r for r in recs if r.get("step") == "V04_0"), None)
        return 0 if vrec and vrec.get("word") == f"{GOLD_OK:08x}" else 1
    return 0 if recs and recs[0].get("n") == 4 else 1


if __name__ == "__main__":
    raise SystemExit(main())
