from pathlib import Path

src = Path(r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/vivado/tcl")
for a, b in {
    "94_synth_uart_r2_u18.tcl": "94_synth_uart_r2_u19.tcl",
    "95_impl_uart_r2_u18.tcl": "95_impl_uart_r2_u19.tcl",
    "96_bit_uart_r2_u18.tcl": "96_bit_uart_r2_u19.tcl",
    "97_program_uart_r2_u18.tcl": "97_program_uart_r2_u19.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u18", "build_u19")
    t = t.replace("uart_r2_u18", "uart_r2_u19")
    t = t.replace("u18 pack_debug_clear.sv", "u19 pack_debug_clear.sv")
    t = t.replace("u18/pack_debug_clear.sv", "u19/pack_debug_clear.sv")
    t = t.replace("u17 arty_a7_r2_top_m4_mig_candidate.sv", "u19 arty_a7_r2_top_m4_mig_candidate.sv")
    t = t.replace("pack_debug_clear_u18.sv", "pack_debug_clear_u19.sv")
    t = t.replace("U18_PROGRAMMED=FACT", "U19_PROGRAMMED=FACT")
    t = t.replace(
        'puts $pfh "NOT_UART_R2_U17=YES"',
        'puts $pfh "NOT_UART_R2_U17=YES"\nputs $pfh "NOT_UART_R2_U18=YES"',
    )
    if "aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949" not in t and b.startswith("97"):
        t = t.replace(
            "  7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4\n}",
            "  7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4\n"
            "  aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949\n}",
        )
    t = t.replace("*uart_r2_u17_candidate*", "*uart_r2_u17_candidate*")
    if "uart_r2_u18_candidate" not in t.split("uart_r2_u19")[0] or True:
        t = t.replace(
            "*uart_r2_u17_candidate* $bitfile]",
            "*uart_r2_u17_candidate* $bitfile] || [string match *uart_r2_u18_candidate* $bitfile]",
        )
        t = t.replace(
            "*uart_r2_u17_candidate* $bitn_fwd]",
            "*uart_r2_u17_candidate* $bitn_fwd] || [string match *uart_r2_u18_candidate* $bitn_fwd]",
        )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)

p = Path(r"D:/FPGA/arty_d/UART_R2/u18/u18_campaign.py").read_text(encoding="utf-8")
p = p.replace("U18", "U19").replace("u18", "u19").replace("PACK24_U18", "PACK24_U19")
p = p.replace("WAIT_AFTER_ACK_S = 0.05", "WAIT_AFTER_ACK_S = 0.0")
p = p.replace("WAIT_AFTER_GOLD_S = 0.05", "WAIT_AFTER_GOLD_S = 0.0")
Path(r"D:/FPGA/arty_d/UART_R2/u19/u19_campaign.py").write_text(p, encoding="utf-8")
print("campaign")
