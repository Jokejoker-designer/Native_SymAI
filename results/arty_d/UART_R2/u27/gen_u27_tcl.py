from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
u25_sha = "6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902"
u26_sha = "8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375"
keep = "*UART_R2_KEEP_U25_CANDIDATE*"
mapping = {
    "94_synth_uart_r2_u25.tcl": "94_synth_uart_r2_u27.tcl",
    "95_impl_uart_r2_u25.tcl": "95_impl_uart_r2_u27.tcl",
    "96_bit_uart_r2_u25.tcl": "96_bit_uart_r2_u27.tcl",
    "97_program_uart_r2_u25.tcl": "97_program_uart_r2_u27.tcl",
}
for a, b in mapping.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("*uart_r2_u25_candidate*", keep)
    t = t.replace("build_u25", "build_u27")
    t = t.replace("uart_r2_u25", "uart_r2_u27")
    t = t.replace(keep, "*uart_r2_u25_candidate*")
    t = t.replace("[file join $r2 u25 pack_debug_clear.sv]", "[file join $r2 u27 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u25 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u27 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u25.sv", "pack_debug_clear_u27.sv")
    t = t.replace("U25_PROGRAMMED=FACT", "U27_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u25_CANDIDATE", "CLASS=uart_r2_u27_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u25/pack_debug_clear.sv", "CLEAR=UART_R2/u27/pack_debug_clear.sv")
    t = t.replace(
        "read_verilog -sv [file join $rtl board pack_clear_ui.sv]",
        "read_verilog -sv [file join $r2 u27 pack_clear_ui.sv]",
    )
    if "NOT_UART_R2_U26=YES" not in t and 'puts $pfh "NOT_UART_R2_U24=YES"' in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U24=YES"',
            'puts $pfh "NOT_UART_R2_U24=YES"\nputs $pfh "NOT_UART_R2_U25=YES"\nputs $pfh "NOT_UART_R2_U26=YES"',
        )
    if u26_sha not in t and b.startswith("97"):
        t = t.replace(
            "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n}",
            "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n"
            f"  {u25_sha}\n"
            f"  {u26_sha}\n}}",
        )
    t = t.replace(
        "*uart_r2_u24_candidate* $bitn_fwd]} {",
        "*uart_r2_u24_candidate* $bitn_fwd] || [string match *uart_r2_u25_candidate* $bitn_fwd] || [string match *uart_r2_u26_candidate* $bitn_fwd]} {",
    )
    t = t.replace(
        "*uart_r2_u24_candidate* $bitfile]} {",
        "*uart_r2_u24_candidate* $bitfile] || [string match *uart_r2_u25_candidate* $bitfile] || [string match *uart_r2_u26_candidate* $bitfile]} {",
    )
    (src / b).write_text(t, encoding="utf-8", newline="\n")
    print("wrote", b)
