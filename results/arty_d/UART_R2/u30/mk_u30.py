"""Copy U29 overlay to U30 and apply dest-reset qsc + f_valid park. Does not patch U29."""
from __future__ import annotations

from pathlib import Path

U29 = Path(r"D:/FPGA/arty_d/UART_R2/u29")
U30 = Path(r"D:/FPGA/arty_d/UART_R2/u30")
PKG = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT"
)
TCL = PKG / "vivado" / "tcl"
BIND = PKG / "rtl" / "native_ai" / "memory" / "pack_mig_bind.sv"

OLD_STEER = """  wire pack_begin = (f_data == 32'h00800001);
  wire steer_pack = pack_lock || (pack_begin && qsc_c1);"""
NEW_STEER = """  wire pack_begin = (f_data == 32'h00800001);
  // qsc_c1 is dest-idle synced; rst100_pack_n is ~cdc_rst. Do not use qsc_100 (combo through CDC idle).
  wire dest_accept = qsc_c1 && rst100_pack_n;
  wire steer_pack = pack_lock || (f_valid && pack_begin && dest_accept);"""

OLD_RDY = """  assign f_ready = q_taking ? qh_in_ready :
                   (steer_pack ? cdc_a_ready :
                    ((pack_begin && !qsc_c1) ? 1'b0 : 1'b1));"""
NEW_RDY = """  assign f_ready = q_taking ? qh_in_ready :
                   (steer_pack ? cdc_a_ready :
                    ((f_valid && pack_begin && !dest_accept) ? 1'b0 : 1'b1));"""

OLD_LOCK = "    else if (f_valid && f_ready && !q_taking && pack_begin && qsc_c1)"
NEW_LOCK = "    else if (f_valid && f_ready && !q_taking && pack_begin && dest_accept)"


def copy_text(src: Path, dst: Path) -> str:
    t = src.read_text(encoding="utf-8")
    t = t.replace("U29", "U30").replace("u29", "u30").replace("U29", "U30")
    t = t.replace("tb_u29", "tb_u30")
    t = t.replace("PENDING_U29_BIT", "PENDING_U30_BIT")
    t = t.replace("c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c", "PENDING_U30_BIT")
    t = t.replace("build_u29", "build_u30")
    t = t.replace("PACK24_U29", "PACK24_U30")
    t = t.replace("xsim_u29", "xsim_u30")
    t = t.replace("tb_u30l", "tb_u30l")
    return t


def patch_rtl(t: str) -> str:
    if OLD_STEER not in t:
        raise SystemExit("steer block missing")
    if OLD_RDY not in t:
        raise SystemExit("f_ready block missing")
    if OLD_LOCK not in t:
        raise SystemExit("pack_lock qualifier missing")
    t = t.replace(OLD_STEER, NEW_STEER)
    t = t.replace(OLD_RDY, NEW_RDY)
    t = t.replace(OLD_LOCK, NEW_LOCK)
    t = t.replace(
        "// U29 keeps U25 UART. New BEGIN only when qsc_c1; hold FIFO on BEGIN if dest not idle.",
        "// U30: qsc false during dest reset; park BEGIN only if f_valid. No SETTLE 2048. Do not patch U29.",
    )
    return t


def main() -> None:
    U30.mkdir(parents=True, exist_ok=True)
    names = [
        "pack_debug_clear.sv",
        "arty_a7_r2_top_m4_mig_candidate.sv",
        "pack_uart_dualclk_harness.sv",
        "tb_u29_leftover_op01.sv",
        "tb_u29_two_v04.sv",
        "u29_campaign.py",
        "run_tb_u29.bat",
        "run_build_u29.bat",
        "run_program_u29.bat",
        "kill_com12_holders.py",
    ]
    mapping = {
        "tb_u29_leftover_op01.sv": "tb_u30_leftover_op01.sv",
        "tb_u29_two_v04.sv": "tb_u30_two_v04.sv",
        "u29_campaign.py": "u30_campaign.py",
        "run_tb_u29.bat": "run_tb_u30.bat",
        "run_build_u29.bat": "run_build_u30.bat",
        "run_program_u29.bat": "run_program_u30.bat",
    }
    for name in names:
        src = U29 / name
        dst = U30 / mapping.get(name, name)
        t = copy_text(src, dst)
        if name.endswith(".sv") and name.startswith(("arty_", "pack_uart")):
            t = patch_rtl(t)
        if name == "u29_campaign.py":
            t = t.replace('WANT = "c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c"', 'WANT = "PENDING_U30_BIT"')
            t = t.replace('WANT = "PENDING_U29_BIT"', 'WANT = "PENDING_U30_BIT"')
        if name == "run_tb_u29.bat":
            t = t.replace("pack_mig_bind.sv", "pack_mig_bind.sv")
            t = t.replace(
                r"%RTL%\memory\pack_mig_bind.sv",
                r"%R2%\u30\pack_mig_bind.sv",
            )
            t = t.replace("tb_u29_leftover_op01", "tb_u30_leftover_op01")
            t = t.replace("tb_u29_two_v04", "tb_u30_two_v04")
            t = t.replace("tb_u30l", "tb_u30l")
            t = t.replace("-s tb_u30l", "-s tb_u30l")
            t = t.replace("xsim tb_u30l", "xsim tb_u30l")
            t = t.replace("-s tb_u29t", "-s tb_u30t")
            t = t.replace("xsim tb_u29t", "xsim tb_u30t")
            t = t.replace("-s tb_u30t", "-s tb_u30t")
        dst.write_text(t, encoding="utf-8", newline="\n")
        print("wrote", dst)

    bind = BIND.read_text(encoding="utf-8")
    old = "  assign pack_quiescent = !loader_busy && !ui_busy && (wr_outstanding == 16'h0);\n"
    new = (
        "  // Overlay U30 only. PACKAGE live bind not overwritten.\n"
        "  assign pack_quiescent = !loader_busy && !ui_busy && (wr_outstanding == 16'h0) && rst_loc && !debug_clear;\n"
    )
    if old not in bind:
        raise SystemExit("pack_quiescent assign missing")
    bind = bind.replace(old, new, 1)
    bind = bind.replace(
        "// debug_clear is DEBUG-only local reset of loader+ui32; not Pack ABI; not mig0.",
        "// U30 overlay: qsc false while debug_clear or rst_loc=0. PACKAGE live not overwritten.",
    )
    (U30 / "pack_mig_bind.sv").write_text(bind, encoding="utf-8", newline="\n")
    print("wrote overlay bind")

    bans = [
        "6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902",
        "8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375",
        "eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e",
        "c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c",
    ]
    keep = "*UART_R2_KEEP_U25_CANDIDATE*"
    mapping_tcl = {
        "94_synth_uart_r2_u25.tcl": "94_synth_uart_r2_u30.tcl",
        "95_impl_uart_r2_u25.tcl": "95_impl_uart_r2_u30.tcl",
        "96_bit_uart_r2_u25.tcl": "96_bit_uart_r2_u30.tcl",
        "97_program_uart_r2_u25.tcl": "97_program_uart_r2_u30.tcl",
    }
    for a, b in mapping_tcl.items():
        t = (TCL / a).read_text(encoding="utf-8")
        t = t.replace("*uart_r2_u25_candidate*", keep)
        t = t.replace("build_u25", "build_u30")
        t = t.replace("uart_r2_u25", "uart_r2_u30")
        t = t.replace(keep, "*uart_r2_u25_candidate*")
        t = t.replace("[file join $r2 u25 pack_debug_clear.sv]", "[file join $r2 u30 pack_debug_clear.sv]")
        t = t.replace(
            "[file join $r2 u25 arty_a7_r2_top_m4_mig_candidate.sv]",
            "[file join $r2 u30 arty_a7_r2_top_m4_mig_candidate.sv]",
        )
        t = t.replace("pack_debug_clear_u25.sv", "pack_debug_clear_u30.sv")
        t = t.replace("U25_PROGRAMMED=FACT", "U30_PROGRAMMED=FACT")
        t = t.replace("CLASS=uart_r2_u25_CANDIDATE", "CLASS=uart_r2_u30_CANDIDATE")
        t = t.replace("CLEAR=UART_R2/u25/pack_debug_clear.sv", "CLEAR=UART_R2/u30/pack_debug_clear.sv")
        t = t.replace(
            "read_verilog -sv [file join $rtl memory pack_mig_bind.sv]",
            "read_verilog -sv [file join $r2 u30 pack_mig_bind.sv]",
        )
        if "NOT_UART_R2_U29=YES" not in t and 'puts $pfh "NOT_UART_R2_U24=YES"' in t:
            t = t.replace(
                'puts $pfh "NOT_UART_R2_U24=YES"',
                'puts $pfh "NOT_UART_R2_U24=YES"\nputs $pfh "NOT_UART_R2_U25=YES"\nputs $pfh "NOT_UART_R2_U26=YES"\nputs $pfh "NOT_UART_R2_U27=YES"\nputs $pfh "NOT_UART_R2_U28=YES"\nputs $pfh "NOT_UART_R2_U29=YES"',
            )
        if b.startswith("97"):
            extra = "".join(f"  {h}\n" for h in bans)
            t = t.replace(
                "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n}",
                "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n" + extra + "}",
            )
        for old, new in [
            (
                "*uart_r2_u24_candidate* $bitn_fwd]} {",
                "*uart_r2_u24_candidate* $bitn_fwd] || [string match *uart_r2_u25_candidate* $bitn_fwd] || [string match *uart_r2_u26_candidate* $bitn_fwd] || [string match *uart_r2_u27_candidate* $bitn_fwd] || [string match *uart_r2_u28_candidate* $bitn_fwd] || [string match *uart_r2_u29_candidate* $bitn_fwd]} {",
            ),
            (
                "*uart_r2_u24_candidate* $bitfile]} {",
                "*uart_r2_u24_candidate* $bitfile] || [string match *uart_r2_u25_candidate* $bitfile] || [string match *uart_r2_u26_candidate* $bitfile] || [string match *uart_r2_u27_candidate* $bitfile] || [string match *uart_r2_u28_candidate* $bitfile] || [string match *uart_r2_u29_candidate* $bitfile]} {",
            ),
        ]:
            t = t.replace(old, new)
        (TCL / b).write_text(t, encoding="utf-8", newline="\n")
        print("wrote", b)


if __name__ == "__main__":
    main()
