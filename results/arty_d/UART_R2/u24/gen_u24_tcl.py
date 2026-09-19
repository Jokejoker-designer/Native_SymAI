from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
extra_ban = [
    "1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9",
    "09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9",
    "ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9",
    "dfea894f1f2942f8587fe91007857792ef32253455aa242e083b7347f95d8a8d",
]
for a, b in {
    "94_synth_uart_r2_u20.tcl": "94_synth_uart_r2_u24.tcl",
    "95_impl_uart_r2_u20.tcl": "95_impl_uart_r2_u24.tcl",
    "96_bit_uart_r2_u20.tcl": "96_bit_uart_r2_u24.tcl",
    "97_program_uart_r2_u20.tcl": "97_program_uart_r2_u24.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u20", "build_u24")
    t = t.replace("uart_r2_u20", "uart_r2_u24")
    t = t.replace("[file join $r2 u20 pack_debug_clear.sv]", "[file join $r2 u24 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u20 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u24 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u20.sv", "pack_debug_clear_u24.sv")
    t = t.replace("U20_PROGRAMMED=FACT", "U24_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u20_CANDIDATE", "CLASS=uart_r2_u24_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u20/pack_debug_clear.sv", "CLEAR=UART_R2/u24/pack_debug_clear.sv")
    if 'puts $pfh "NOT_UART_R2_U20=YES"' not in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U19=YES"',
            'puts $pfh "NOT_UART_R2_U19=YES"\nputs $pfh "NOT_UART_R2_U20=YES"'
            '\nputs $pfh "NOT_UART_R2_U21=YES"\nputs $pfh "NOT_UART_R2_U22=YES"'
            '\nputs $pfh "NOT_UART_R2_U23=YES"',
        )
    if extra_ban[0] not in t and b.startswith("97"):
        t = t.replace(
            "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n}",
            "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n"
            + "".join(f"  {h}\n" for h in extra_ban)
            + "}",
        )
    t = t.replace(
        "*uart_r2_u19_candidate* $bitn_fwd]} {",
        "*uart_r2_u19_candidate* $bitn_fwd] || [string match *uart_r2_u20_candidate* $bitn_fwd] || [string match *uart_r2_u21_candidate* $bitn_fwd] || [string match *uart_r2_u22_candidate* $bitn_fwd] || [string match *uart_r2_u23_candidate* $bitn_fwd]} {",
    )
    t = t.replace(
        "*uart_r2_u19_candidate* $bitfile]",
        "*uart_r2_u19_candidate* $bitfile] || [string match *uart_r2_u20_candidate* $bitfile] || [string match *uart_r2_u21_candidate* $bitfile] || [string match *uart_r2_u22_candidate* $bitfile] || [string match *uart_r2_u23_candidate* $bitfile]",
    )
    (src / b).write_text(t, encoding="utf-8", newline="\n")
    print("wrote", b)
