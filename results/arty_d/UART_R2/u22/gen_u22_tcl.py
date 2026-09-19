from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
u21_sha = "09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9"
for a, b in {
    "94_synth_uart_r2_u21.tcl": "94_synth_uart_r2_u22.tcl",
    "95_impl_uart_r2_u21.tcl": "95_impl_uart_r2_u22.tcl",
    "96_bit_uart_r2_u21.tcl": "96_bit_uart_r2_u22.tcl",
    "97_program_uart_r2_u21.tcl": "97_program_uart_r2_u22.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("*uart_r2_u21_candidate*", "*UART_R2_KEEP_U21_NAME*")
    t = t.replace("build_u21", "build_u22")
    t = t.replace("uart_r2_u21", "uart_r2_u22")
    t = t.replace("*UART_R2_KEEP_U21_NAME*", "*uart_r2_u21_candidate*")
    t = t.replace("[file join $r2 u21 pack_debug_clear.sv]", "[file join $r2 u22 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u21 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u22 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u21.sv", "pack_debug_clear_u22.sv")
    t = t.replace("U21_PROGRAMMED=FACT", "U22_PROGRAMMED=FACT")
    t = t.replace("CLEAR=UART_R2/u21/pack_debug_clear.sv", "CLEAR=UART_R2/u22/pack_debug_clear.sv")
    if 'puts $pfh "NOT_UART_R2_U21=YES"' not in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U20=YES"',
            'puts $pfh "NOT_UART_R2_U20=YES"\nputs $pfh "NOT_UART_R2_U21=YES"',
        )
    if u21_sha not in t and b.startswith("97"):
        t = t.replace(
            "  1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9\n}",
            "  1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9\n"
            f"  {u21_sha}\n}}",
        )
    if "*uart_r2_u21_candidate*" not in t:
        t = t.replace(
            "*uart_r2_u20_candidate* $bitn_fwd]} {",
            "*uart_r2_u20_candidate* $bitn_fwd] || [string match *uart_r2_u21_candidate* $bitn_fwd]} {",
        )
        t = t.replace(
            "*uart_r2_u20_candidate* $bitfile]",
            "*uart_r2_u20_candidate* $bitfile] || [string match *uart_r2_u21_candidate* $bitfile]",
        )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
