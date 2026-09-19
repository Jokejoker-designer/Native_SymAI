from pathlib import Path

src = Path(r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/vivado/tcl")
u19_ban = "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n}"
for a, b in {
    "94_synth_uart_r2_u19.tcl": "94_synth_uart_r2_u20.tcl",
    "95_impl_uart_r2_u19.tcl": "95_impl_uart_r2_u20.tcl",
    "96_bit_uart_r2_u19.tcl": "96_bit_uart_r2_u20.tcl",
    "97_program_uart_r2_u19.tcl": "97_program_uart_r2_u20.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u19", "build_u20")
    t = t.replace("uart_r2_u19", "uart_r2_u20")
    t = t.replace("u19 pack_debug_clear.sv", "u20 pack_debug_clear.sv")
    t = t.replace("u19/pack_debug_clear.sv", "u20/pack_debug_clear.sv")
    t = t.replace("u19 arty_a7_r2_top_m4_mig_candidate.sv", "u20 arty_a7_r2_top_m4_mig_candidate.sv")
    t = t.replace("[file join $r2 u19 pack_debug_clear.sv]", "[file join $r2 u20 pack_debug_clear.sv]")
    t = t.replace("[file join $r2 u19 arty_a7_r2_top_m4_mig_candidate.sv]", "[file join $r2 u20 arty_a7_r2_top_m4_mig_candidate.sv]")
    t = t.replace("pack_debug_clear_u19.sv", "pack_debug_clear_u20.sv")
    t = t.replace("U19_PROGRAMMED=FACT", "U20_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u19_CANDIDATE", "CLASS=uart_r2_u20_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u19/pack_debug_clear.sv", "CLEAR=UART_R2/u20/pack_debug_clear.sv")
    t = t.replace(
        'puts $pfh "NOT_UART_R2_U18=YES"',
        'puts $pfh "NOT_UART_R2_U18=YES"\nputs $pfh "NOT_UART_R2_U19=YES"',
    )
    if "cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576" not in t and b.startswith("97"):
        t = t.replace(
            "  aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949\n}",
            "  aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949\n"
            "  cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576\n}",
        )
    t = t.replace(
        "*uart_r2_u18_candidate* $bitn_fwd]} {",
        "*uart_r2_u18_candidate* $bitn_fwd] || [string match *uart_r2_u19_candidate* $bitn_fwd]} {",
    )
    t = t.replace(
        "*uart_r2_u18_candidate* $bitfile]",
        "*uart_r2_u18_candidate* $bitfile] || [string match *uart_r2_u19_candidate* $bitfile]",
    )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
