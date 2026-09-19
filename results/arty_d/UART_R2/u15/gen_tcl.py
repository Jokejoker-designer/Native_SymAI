from pathlib import Path

src = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\vivado\tcl"
)
pairs = [
    ("82_synth_uart_r2_u14.tcl", "86_synth_uart_r2_u15.tcl"),
    ("83_impl_uart_r2_u14.tcl", "87_impl_uart_r2_u15.tcl"),
    ("84_bit_uart_r2_u14.tcl", "88_bit_uart_r2_u15.tcl"),
    ("85_program_uart_r2_u14.tcl", "89_program_uart_r2_u15.tcl"),
]
for a, b in pairs:
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u14", "build_u15")
    t = t.replace("uart_r2_u14", "uart_r2_u15")
    t = t.replace("UART_R2_U14", "UART_R2_U15")
    t = t.replace("u8 pack_debug_clear", "u15 pack_debug_clear")
    t = t.replace("pack_debug_clear_u8", "pack_debug_clear_u15")
    t = t.replace("CLEAR=UART_R2/u8/pack_debug_clear.sv", "CLEAR=UART_R2/u15/pack_debug_clear.sv")
    t = t.replace(
        "1722e9efef0769ded00ddcfbda5845f24b05ac0015f012f9ca72bb51c511c8e8",
        "1722e9efef0769ded00ddcfbda5845f24b05ac0015f012f9ca72bb51c511c8e8\n"
        "  3597886d91c1fc3f6af6c154f240fd02c587168c41f1033ff55f6827029d102b",
    )
    t = t.replace(
        "[string match *uart_r2_u13_candidate* $bitn_fwd]}",
        "[string match *uart_r2_u13_candidate* $bitn_fwd] || "
        "[string match *uart_r2_u14_candidate* $bitn_fwd]}",
    )
    t = t.replace(
        "[string match *uart_r2_u13_candidate* $bitfile]}",
        "[string match *uart_r2_u13_candidate* $bitfile] || "
        "[string match *uart_r2_u14_candidate* $bitfile]}",
    )
    t = t.replace("NOT_UART_R2_U13=YES", "NOT_UART_R2_U13=YES\nputs $pfh \"NOT_UART_R2_U14=YES\"")
    t = t.replace("TX=U14_uart_tx_word", "TX=U14_uart_tx_word")
    t = t.replace("U14_PROGRAMMED=FACT", "U15_PROGRAMMED=FACT")
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
