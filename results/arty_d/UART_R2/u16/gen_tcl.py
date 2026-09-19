from pathlib import Path

src = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\vivado\tcl"
)
pairs = [
    ("86_synth_uart_r2_u15.tcl", "90_synth_uart_r2_u16.tcl"),
    ("87_impl_uart_r2_u15.tcl", "91_impl_uart_r2_u16.tcl"),
    ("88_bit_uart_r2_u15.tcl", "92_bit_uart_r2_u16.tcl"),
    ("89_program_uart_r2_u15.tcl", "93_program_uart_r2_u16.tcl"),
]
for a, b in pairs:
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u15", "build_u16")
    t = t.replace("uart_r2_u15", "uart_r2_u16")
    t = t.replace("UART_R2_U15", "UART_R2_U16")
    t = t.replace("u15 pack_debug_clear", "u16 pack_debug_clear")
    t = t.replace("pack_debug_clear_u15", "pack_debug_clear_u16")
    t = t.replace("CLEAR=UART_R2/u15/pack_debug_clear.sv", "CLEAR=UART_R2/u16/pack_debug_clear.sv")
    t = t.replace(
        "3597886d91c1fc3f6af6c154f240fd02c587168c41f1033ff55f6827029d102b",
        "3597886d91c1fc3f6af6c154f240fd02c587168c41f1033ff55f6827029d102b\n"
        "  bc457238db3696ce038ed5fe0f117acb7f73ad5fc6b637a63e9b8ae46325b20b",
    )
    t = t.replace(
        "[string match *uart_r2_u14_candidate* $bitn_fwd]}",
        "[string match *uart_r2_u14_candidate* $bitn_fwd] || "
        "[string match *uart_r2_u15_candidate* $bitn_fwd]}",
    )
    t = t.replace(
        "[string match *uart_r2_u14_candidate* $bitfile]}",
        "[string match *uart_r2_u14_candidate* $bitfile] || "
        "[string match *uart_r2_u15_candidate* $bitfile]}",
    )
    t = t.replace("NOT_UART_R2_U14=YES", "NOT_UART_R2_U14=YES\nputs $pfh \"NOT_UART_R2_U15=YES\"")
    t = t.replace("U15_PROGRAMMED=FACT", "U16_PROGRAMMED=FACT")
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)

bat = Path(r"D:\FPGA\arty_d\UART_R2\u15\run_tb_u15_harness.bat").read_text(encoding="utf-8")
bat = bat.replace("xsim_u15h15", "xsim_u16h").replace(r"\u15\pack_debug_clear", r"\u16\pack_debug_clear")
Path(r"D:\FPGA\arty_d\UART_R2\u16\run_tb_u16_harness.bat").write_text(bat, encoding="utf-8")

tb = Path(r"D:\FPGA\arty_d\UART_R2\u15\run_tb_u15.bat").read_text(encoding="utf-8")
tb = tb.replace("xsim_u15", "xsim_u16t").replace(r"\u15\pack_debug_clear", r"\u16\pack_debug_clear")
tb = tb.replace(r"\u15\tb_u15_targeted", r"\u15\tb_u15_targeted")
Path(r"D:\FPGA\arty_d\UART_R2\u16\run_tb_u16.bat").write_text(tb, encoding="utf-8")
print("bats")
