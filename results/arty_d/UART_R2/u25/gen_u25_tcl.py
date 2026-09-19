from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
u24_sha = "1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a"
keep = "*UART_R2_KEEP_U24_CANDIDATE*"
mapping = {
    "94_synth_uart_r2_u24.tcl": "94_synth_uart_r2_u25.tcl",
    "95_impl_uart_r2_u24.tcl": "95_impl_uart_r2_u25.tcl",
    "96_bit_uart_r2_u24.tcl": "96_bit_uart_r2_u25.tcl",
    "97_program_uart_r2_u24.tcl": "97_program_uart_r2_u25.tcl",
}
for a, b in mapping.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("*uart_r2_u24_candidate*", keep)
    t = t.replace("build_u24", "build_u25")
    t = t.replace("uart_r2_u24", "uart_r2_u25")
    t = t.replace(keep, "*uart_r2_u24_candidate*")
    t = t.replace("[file join $r2 u24 pack_debug_clear.sv]", "[file join $r2 u25 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u24 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u25 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u24.sv", "pack_debug_clear_u25.sv")
    t = t.replace("U24_PROGRAMMED=FACT", "U25_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u24_CANDIDATE", "CLASS=uart_r2_u25_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u24/pack_debug_clear.sv", "CLEAR=UART_R2/u25/pack_debug_clear.sv")
    if "NOT_UART_R2_U24=YES" not in t and 'puts $pfh "NOT_UART_R2_U23=YES"' in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U23=YES"',
            'puts $pfh "NOT_UART_R2_U23=YES"\nputs $pfh "NOT_UART_R2_U24=YES"',
        )
    if u24_sha not in t and b.startswith("97"):
        t = t.replace(
            "  dfea894f1f2942f8587fe91007857792ef32253455aa242e083b7347f95d8a8d\n}",
            "  dfea894f1f2942f8587fe91007857792ef32253455aa242e083b7347f95d8a8d\n"
            f"  {u24_sha}\n}}",
        )
    t = t.replace(
        "*uart_r2_u23_candidate* $bitn_fwd]} {",
        "*uart_r2_u23_candidate* $bitn_fwd] || [string match *uart_r2_u24_candidate* $bitn_fwd]} {",
    )
    t = t.replace(
        "*uart_r2_u23_candidate* $bitfile]",
        "*uart_r2_u23_candidate* $bitfile] || [string match *uart_r2_u24_candidate* $bitfile]",
    )
    t = t.replace(
        "*uart_r2_u23_candidate* $bitfile]} {",
        "*uart_r2_u23_candidate* $bitfile] || [string match *uart_r2_u24_candidate* $bitfile]} {",
    )
    (src / b).write_text(t, encoding="utf-8", newline="\n")
    print("wrote", b, "bytes", (src / b).stat().st_size)
