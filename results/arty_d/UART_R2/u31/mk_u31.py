"""Copy U30 overlay to U31. Does not patch U30 / PACKAGE live / C / H / gold."""
from __future__ import annotations

from pathlib import Path

U30 = Path(r"D:/FPGA/arty_d/UART_R2/u30")
U31 = Path(r"D:/FPGA/arty_d/UART_R2/u31")
PKG = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT"
)
TCL = PKG / "vivado" / "tcl"


def namemap(name: str) -> str:
    return (
        name.replace("u30", "u31")
        .replace("U30", "U31")
        .replace("tb_u30", "tb_u31")
    )


def copy_text(t: str) -> str:
    t = t.replace("U30", "U31")
    t = t.replace("u30", "u31")
    t = t.replace("PACK24_U31", "PACK24_U31")
    t = t.replace("PENDING_U30_BIT", "PENDING_U31_BIT")
    t = t.replace("9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e", "PENDING_U31_BIT")
    t = t.replace("build_u30", "build_u31")
    t = t.replace("xsim_u30", "xsim_u31")
    t = t.replace("tb_u31l", "tb_u31l")
    t = t.replace("tb_u31t", "tb_u31t")
    return t


def main() -> None:
    U31.mkdir(parents=True, exist_ok=True)
    names = [
        "pack_debug_clear.sv",
        "pack_mig_bind.sv",
        "arty_a7_r2_top_m4_mig_candidate.sv",
        "pack_uart_dualclk_harness.sv",
        "tb_u30_leftover_op01.sv",
        "tb_u30_two_v04.sv",
        "u30_campaign.py",
        "run_tb_u30.bat",
        "run_build_u30.bat",
        "run_program_u30.bat",
        "kill_com12_holders.py",
        "reprogram_nwp4p5.py",
    ]
    for name in names:
        src = U30 / name
        dst = U31 / namemap(name)
        t = copy_text(src.read_text(encoding="utf-8"))
        if name == "run_tb_u30.bat":
            t = t.replace(r"%RTL%\board\pack_clear_ui.sv", r"%R2%\u31\pack_clear_ui.sv")
            t = t.replace("tb_u30_leftover_op01", "tb_u31_leftover_op01")
            t = t.replace("tb_u30_two_v04", "tb_u31_two_v04")
            t = t.replace("-s tb_u31l", "-s tb_u31l")
            t = t.replace("xsim tb_u31l", "xsim tb_u31l")
            t = t.replace("-s tb_u30t", "-s tb_u31t")
            t = t.replace("xsim tb_u30t", "xsim tb_u31t")
        dst.write_text(t, encoding="utf-8", newline="\n")
        print("wrote", dst)

    bans = [
        "6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902",
        "8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375",
        "eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e",
        "c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c",
        "9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e",
    ]
    keep = "*UART_R2_KEEP_U25_CANDIDATE*"
    mapping_tcl = {
        "94_synth_uart_r2_u25.tcl": "94_synth_uart_r2_u31.tcl",
        "95_impl_uart_r2_u25.tcl": "95_impl_uart_r2_u31.tcl",
        "96_bit_uart_r2_u25.tcl": "96_bit_uart_r2_u31.tcl",
        "97_program_uart_r2_u25.tcl": "97_program_uart_r2_u31.tcl",
    }
    for a, b in mapping_tcl.items():
        t = (TCL / a).read_text(encoding="utf-8")
        t = t.replace("*uart_r2_u25_candidate*", keep)
        t = t.replace("build_u25", "build_u31")
        t = t.replace("uart_r2_u25", "uart_r2_u31")
        t = t.replace(keep, "*uart_r2_u25_candidate*")
        t = t.replace("[file join $r2 u25 pack_debug_clear.sv]", "[file join $r2 u31 pack_debug_clear.sv]")
        t = t.replace(
            "[file join $r2 u25 arty_a7_r2_top_m4_mig_candidate.sv]",
            "[file join $r2 u31 arty_a7_r2_top_m4_mig_candidate.sv]",
        )
        t = t.replace("pack_debug_clear_u25.sv", "pack_debug_clear_u31.sv")
        t = t.replace("U25_PROGRAMMED=FACT", "U31_PROGRAMMED=FACT")
        t = t.replace("CLASS=uart_r2_u25_CANDIDATE", "CLASS=uart_r2_u31_CANDIDATE")
        t = t.replace("CLEAR=UART_R2/u25/pack_debug_clear.sv", "CLEAR=UART_R2/u31/pack_debug_clear.sv")
        t = t.replace(
            "read_verilog -sv [file join $rtl memory pack_mig_bind.sv]",
            "read_verilog -sv [file join $r2 u31 pack_mig_bind.sv]",
        )
        t = t.replace(
            "read_verilog -sv [file join $rtl board pack_clear_ui.sv]",
            "read_verilog -sv [file join $r2 u31 pack_clear_ui.sv]",
        )
        if "NOT_UART_R2_U30=YES" not in t and 'puts $pfh "NOT_UART_R2_U24=YES"' in t:
            t = t.replace(
                'puts $pfh "NOT_UART_R2_U24=YES"',
                'puts $pfh "NOT_UART_R2_U24=YES"\nputs $pfh "NOT_UART_R2_U25=YES"\nputs $pfh "NOT_UART_R2_U26=YES"\nputs $pfh "NOT_UART_R2_U27=YES"\nputs $pfh "NOT_UART_R2_U28=YES"\nputs $pfh "NOT_UART_R2_U29=YES"\nputs $pfh "NOT_UART_R2_U30=YES"',
            )
        if b.startswith("97"):
            extra = "".join(f"  {h}\n" for h in bans)
            t = t.replace(
                "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n}",
                "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n" + extra + "}",
            )
        t = t.replace(
            "*uart_r2_u24_candidate* $bitn_fwd]} {",
            "*uart_r2_u24_candidate* $bitn_fwd] || [string match *uart_r2_u25_candidate* $bitn_fwd] || [string match *uart_r2_u26_candidate* $bitn_fwd] || [string match *uart_r2_u27_candidate* $bitn_fwd] || [string match *uart_r2_u28_candidate* $bitn_fwd] || [string match *uart_r2_u29_candidate* $bitn_fwd] || [string match *uart_r2_u30_candidate* $bitn_fwd]} {",
        )
        t = t.replace(
            "*uart_r2_u24_candidate* $bitfile]} {",
            "*uart_r2_u24_candidate* $bitfile] || [string match *uart_r2_u25_candidate* $bitfile] || [string match *uart_r2_u26_candidate* $bitfile] || [string match *uart_r2_u27_candidate* $bitfile] || [string match *uart_r2_u28_candidate* $bitfile] || [string match *uart_r2_u29_candidate* $bitfile] || [string match *uart_r2_u30_candidate* $bitfile]} {",
        )
        (TCL / b).write_text(t, encoding="utf-8", newline="\n")
        print("wrote", b)


if __name__ == "__main__":
    main()
