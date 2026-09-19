from pathlib import Path

src = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\vivado\tcl"
)
pairs = [
    ("78_synth_uart_r2_u13.tcl", "82_synth_uart_r2_u14.tcl"),
    ("79_impl_uart_r2_u13.tcl", "83_impl_uart_r2_u14.tcl"),
    ("80_bit_uart_r2_u13.tcl", "84_bit_uart_r2_u14.tcl"),
    ("81_program_uart_r2_u13.tcl", "85_program_uart_r2_u14.tcl"),
]
for a, b in pairs:
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u13", "build_u14")
    t = t.replace("uart_r2_u13", "uart_r2_u14")
    t = t.replace("UART_R2_U13", "UART_R2_U14")
    t = t.replace("u13 uart_tx_word", "u14 uart_tx_word")
    t = t.replace("uart_tx_word_u13", "uart_tx_word_u14")
    t = t.replace(
        "0f774e8745377ea75dab6ccd533fedf059a03a00612f90fbe9bddb9ce3ab5121",
        "0f774e8745377ea75dab6ccd533fedf059a03a00612f90fbe9bddb9ce3ab5121\n"
        "  1722e9efef0769ded00ddcfbda5845f24b05ac0015f012f9ca72bb51c511c8e8",
    )
    t = t.replace(
        "[string match *uart_r2_u12_candidate* $bitn_fwd]}",
        "[string match *uart_r2_u12_candidate* $bitn_fwd] || "
        "[string match *uart_r2_u13_candidate* $bitn_fwd]}",
    )
    t = t.replace(
        "[string match *uart_r2_u12_candidate* $bitfile]}",
        "[string match *uart_r2_u12_candidate* $bitfile] || "
        "[string match *uart_r2_u13_candidate* $bitfile]}",
    )
    t = t.replace("NOT_UART_R2_U12=YES", "NOT_UART_R2_U12=YES\nputs $pfh \"NOT_UART_R2_U13=YES\"")
    t = t.replace("TX=U13_uart_tx_word", "TX=U14_uart_tx_word")
    t = t.replace("U13_PROGRAMMED=FACT", "U14_PROGRAMMED=FACT")
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
