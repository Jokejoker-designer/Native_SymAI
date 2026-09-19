from pathlib import Path

src = Path(r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/vivado/tcl")
pairs = {
    "94_synth_uart_r2_u17.tcl": "94_synth_uart_r2_u18.tcl",
    "95_impl_uart_r2_u17.tcl": "95_impl_uart_r2_u18.tcl",
    "96_bit_uart_r2_u17.tcl": "96_bit_uart_r2_u18.tcl",
    "97_program_uart_r2_u17.tcl": "97_program_uart_r2_u18.tcl",
}
for a, b in pairs.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u17", "build_u18")
    t = t.replace("uart_r2_u17", "uart_r2_u18")
    t = t.replace("u17/pack_debug_clear.sv", "u18/pack_debug_clear.sv")
    t = t.replace("pack_debug_clear_u17.sv", "pack_debug_clear_u18.sv")
    t = t.replace("U17_PROGRAMMED=FACT", "U18_PROGRAMMED=FACT")
    t = t.replace("*uart_r2_u16_candidate*", "*uart_r2_u16_candidate* || [string match *uart_r2_u17_candidate*")
    t = t.replace(
        'puts $pfh "NOT_UART_R2_U16=YES"',
        'puts $pfh "NOT_UART_R2_U16=YES"\nputs $pfh "NOT_UART_R2_U17=YES"',
    )
    if "7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4" not in t and b.startswith("97"):
        t = t.replace(
            "  e32a64e74602d35e470e8b6efca8b1f0fdf70b24ea981fb4ed5b3e6f5f896a45\n}",
            "  e32a64e74602d35e470e8b6efca8b1f0fdf70b24ea981fb4ed5b3e6f5f896a45\n"
            "  7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4\n}",
        )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)

p = Path(r"D:/FPGA/arty_d/UART_R2/u17/u17_campaign.py").read_text(encoding="utf-8")
p = p.replace("U17", "U18").replace("u17", "u18").replace("PACK24_U17", "PACK24_U18")
Path(r"D:/FPGA/arty_d/UART_R2/u18/u18_campaign.py").write_text(p, encoding="utf-8")
print("campaign ok")
