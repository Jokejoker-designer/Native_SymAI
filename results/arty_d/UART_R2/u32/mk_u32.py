"""Copy U31 overlay to U32. One delta: TX CDC b-reset on cdc_rst, not ui_req.
Does not patch U31 / dest_accept / dest_ui_rdy / C / H / gold / PACKAGE live bind.
"""
from __future__ import annotations

from pathlib import Path

U31 = Path(r"D:/FPGA/arty_d/UART_R2/u31")
U32 = Path(r"D:/FPGA/arty_d/UART_R2/u32")
PKG = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT"
)
TCL = PKG / "vivado" / "tcl"
U31_BIT = "08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d"


def namemap(name: str) -> str:
    return name.replace("u31", "u32").replace("U31", "U32")


def copy_text(t: str) -> str:
    t = t.replace("U31", "U32")
    t = t.replace("u31", "u32")
    t = t.replace("PACK24_U32", "PACK24_U32")
    t = t.replace(U31_BIT, "PENDING_U32_BIT")
    t = t.replace("build_u32", "build_u32")
    return t


def main() -> None:
    U32.mkdir(parents=True, exist_ok=True)
    names = [
        "pack_debug_clear.sv",
        "pack_clear_ui.sv",
        "pack_mig_bind.sv",
        "pack_uart_dualclk_harness.sv",
        "arty_a7_r2_top_m4_mig_candidate.sv",
        "tb_u31_leftover_op01.sv",
        "tb_u31_two_v04.sv",
        "tb_u31_sreq_nack_leftover.sv",
        "u31_campaign.py",
        "run_tb_u31.bat",
        "run_tb_u31_sreq_nack.bat",
        "run_build_u31.bat",
        "run_program_u31.bat",
        "kill_com12_holders.py",
        "reprogram_nwp4p5.py",
    ]
    for name in names:
        src = U31 / name
        dst = U32 / namemap(name)
        t = copy_text(src.read_text(encoding="utf-8"))
        if name == "pack_uart_dualclk_harness.sv":
            t = t.replace(
                "      rst100_tx_b_n <= ~clr_ui_req;",
                "      // U32: b-reset only when committing cdc_rst (S_CDC|S_QUIET).\n"
                "      // S_REQ probe must not replay GOLD (xsim_u31r BUSY_THEN_GOLD_N8).\n"
                "      rst100_tx_b_n <= ~cdc_rst_100;",
            )
        if name == "arty_a7_r2_top_m4_mig_candidate.sv":
            t = t.replace(
                "      rst100_tx_b_n <= ~clr_ui_req;",
                "      // U32: b-reset only when committing cdc_rst (S_CDC|S_QUIET).\n"
                "      rst100_tx_b_n <= ~cdc_rst_100;",
            )
        if name == "pack_mig_bind.sv":
            t = t.replace(
                "// Overlay U32 only. PACKAGE live bind not overwritten.",
                "// Overlay U32: dest_ui_rdy kept (not dest_accept change). PACKAGE live not overwritten.",
            )
        if name == "run_tb_u31.bat":
            t += (
                "\nif errorlevel 1 exit /b 1\n"
                "if not exist \"%R2%\\xsim_u32r\" mkdir \"%R2%\\xsim_u32r\"\n"
                "cd /d \"%R2%\\xsim_u32r\"\n"
                "copy /Y \"%PA%\\out\\PA24-V-04.mem\" \"%R2%\\xsim_u32r\\\" >nul\n"
            )
        dst.write_text(t, encoding="utf-8", newline="\n")
        print("wrote", dst)

    # sreq nack bat already copied; run_tb_u32.bat leftover+two_v04 from u31.

    bans = [
        "6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902",
        "8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375",
        "eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e",
        "c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c",
        "9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e",
        U31_BIT,
    ]
    mapping_tcl = {
        "94_synth_uart_r2_u31.tcl": "94_synth_uart_r2_u32.tcl",
        "95_impl_uart_r2_u31.tcl": "95_impl_uart_r2_u32.tcl",
        "96_bit_uart_r2_u31.tcl": "96_bit_uart_r2_u32.tcl",
        "97_program_uart_r2_u31.tcl": "97_program_uart_r2_u32.tcl",
    }
    for a, b in mapping_tcl.items():
        t = (TCL / a).read_text(encoding="utf-8")
        t = t.replace("build_u31", "build_u32")
        t = t.replace("uart_r2_u31", "uart_r2_u32")
        t = t.replace("[file join $r2 u31 ", "[file join $r2 u32 ")
        t = t.replace("pack_debug_clear_u31.sv", "pack_debug_clear_u32.sv")
        t = t.replace("U31_PROGRAMMED=FACT", "U32_PROGRAMMED=FACT")
        t = t.replace("CLASS=uart_r2_u31_CANDIDATE", "CLASS=uart_r2_u32_CANDIDATE")
        t = t.replace("CLEAR=UART_R2/u31/pack_debug_clear.sv", "CLEAR=UART_R2/u32/pack_debug_clear.sv")
        if 'puts $pfh "NOT_UART_R2_U31=YES"' not in t and 'puts $pfh "NOT_UART_R2_U30=YES"' in t:
            t = t.replace(
                'puts $pfh "NOT_UART_R2_U30=YES"',
                'puts $pfh "NOT_UART_R2_U30=YES"\nputs $pfh "NOT_UART_R2_U31=YES"',
            )
        if b.startswith("97"):
            extra = "".join(f"  {h}\n" for h in bans)
            t = t.replace(
                "  9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e\n}",
                "  9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e\n" + extra + "}",
            )
        t = t.replace(
            "*uart_r2_u31_candidate* $bitn_fwd]} {",
            "*uart_r2_u31_candidate* $bitn_fwd] || [string match *uart_r2_u31_candidate* $bitn_fwd]} {",
        )
        # 96/97 already have u30; add u31 forbid
        t = t.replace(
            "*uart_r2_u30_candidate* $bitfile]} {",
            "*uart_r2_u30_candidate* $bitfile] || [string match *uart_r2_u31_candidate* $bitfile]} {",
        )
        t = t.replace(
            "*uart_r2_u30_candidate* $bitn_fwd]} {",
            "*uart_r2_u30_candidate* $bitn_fwd] || [string match *uart_r2_u31_candidate* $bitn_fwd]} {",
        )
        (TCL / b).write_text(t, encoding="utf-8", newline="\n")
        print("wrote", b)


if __name__ == "__main__":
    main()
