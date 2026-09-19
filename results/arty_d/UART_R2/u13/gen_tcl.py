from pathlib import Path

src = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\vivado\tcl"
)
pairs = [
    ("74_synth_uart_r2_u12.tcl", "78_synth_uart_r2_u13.tcl"),
    ("75_impl_uart_r2_u12.tcl", "79_impl_uart_r2_u13.tcl"),
    ("76_bit_uart_r2_u12.tcl", "80_bit_uart_r2_u13.tcl"),
    ("77_program_uart_r2_u12.tcl", "81_program_uart_r2_u13.tcl"),
]
for a, b in pairs:
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u12", "build_u13")
    t = t.replace("uart_r2_u12", "uart_r2_u13")
    t = t.replace("UART_R2_U12", "UART_R2_U13")
    t = t.replace("u10 uart_tx_word", "u13 uart_tx_word")
    t = t.replace("uart_tx_word_u10", "uart_tx_word_u13")
    t = t.replace(
        "713ea856baa9f36bdfecad0eaa356c4f3be872191d2820845bcd4f8f90e55b0e",
        "713ea856baa9f36bdfecad0eaa356c4f3be872191d2820845bcd4f8f90e55b0e\n"
        "  0f774e8745377ea75dab6ccd533fedf059a03a00612f90fbe9bddb9ce3ab5121",
    )
    t = t.replace(
        "[string match *uart_r2_u11_candidate* $bitn_fwd]}",
        "[string match *uart_r2_u11_candidate* $bitn_fwd] || "
        "[string match *uart_r2_u12_candidate* $bitn_fwd]}",
    )
    t = t.replace(
        "[string match *uart_r2_u11_candidate* $bitfile]}",
        "[string match *uart_r2_u11_candidate* $bitfile] || "
        "[string match *uart_r2_u12_candidate* $bitfile]}",
    )
    t = t.replace("NOT_UART_R2_U11=YES", "NOT_UART_R2_U11=YES\nputs $pfh \"NOT_UART_R2_U12=YES\"")
    t = t.replace("TX=5e11b03202935c88e20ce7d27ef405fdfefdaef69e403a644ef1a1e236ab1a36", "TX=U13_uart_tx_word")
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
