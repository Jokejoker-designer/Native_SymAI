from pathlib import Path
src = Path(r"D:\FPGA\arty_d\UART_R2\u14\tb_u14_targeted.sv").read_text(encoding="utf-8")
src = src.replace("tb_u14_targeted", "tb_u15_targeted")
src = src.replace("UART_R2_U14", "UART_R2_U15")
out = Path(r"D:\FPGA\arty_d\UART_R2\u15\tb_u15_targeted.sv")
out.write_text(src, encoding="utf-8")
print("wrote", out)
