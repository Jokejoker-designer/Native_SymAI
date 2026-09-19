from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
u20_sha = "1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9"
for a, b in {
    "94_synth_uart_r2_u20.tcl": "94_synth_uart_r2_u21.tcl",
    "95_impl_uart_r2_u20.tcl": "95_impl_uart_r2_u21.tcl",
    "96_bit_uart_r2_u20.tcl": "96_bit_uart_r2_u21.tcl",
    "97_program_uart_r2_u20.tcl": "97_program_uart_r2_u21.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u20", "build_u21")
    t = t.replace("uart_r2_u20", "uart_r2_u21")
    t = t.replace("u20 pack_debug_clear.sv", "u21 pack_debug_clear.sv")
    t = t.replace("u20/pack_debug_clear.sv", "u21/pack_debug_clear.sv")
    t = t.replace("u20 arty_a7_r2_top_m4_mig_candidate.sv", "u21 arty_a7_r2_top_m4_mig_candidate.sv")
    t = t.replace("[file join $r2 u20 pack_debug_clear.sv]", "[file join $r2 u21 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u20 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u21 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u20.sv", "pack_debug_clear_u21.sv")
    t = t.replace("U20_PROGRAMMED=FACT", "U21_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u20_CANDIDATE", "CLASS=uart_r2_u21_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u20/pack_debug_clear.sv", "CLEAR=UART_R2/u21/pack_debug_clear.sv")
    t = t.replace("NOT_UART_R2_U19=YES", "NOT_UART_R2_U19=YES\nputs $pfh \"NOT_UART_R2_U20=YES\"")
    if u20_sha not in t and b.startswith("97"):
        t = t.replace(
            "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n}",
            "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n"
            f"  {u20_sha}\n}}",
        )
    t = t.replace(
        "*uart_r2_u19_candidate* $bitn_fwd]} {",
        "*uart_r2_u19_candidate* $bitn_fwd] || [string match *uart_r2_u20_candidate* $bitn_fwd]} {",
    )
    t = t.replace(
        "*uart_r2_u19_candidate* $bitfile]",
        "*uart_r2_u19_candidate* $bitfile] || [string match *uart_r2_u20_candidate* $bitfile]",
    )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
