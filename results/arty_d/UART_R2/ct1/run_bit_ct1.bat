@echo off
REM Unique CT1 bitstream. STOP before program_hw_devices. PROGRAM=NO.
call "C:\2026.1\Vivado\settings64.bat"
vivado -mode batch -source D:\FPGA\arty_d\UART_R2\ct1\96_bit_uart_r2_ct1.tcl -log D:\FPGA\arty_d\UART_R2\build_ct1\vivado_bit.log -journal D:\FPGA\arty_d\UART_R2\build_ct1\vivado_bit.jou
exit /b %ERRORLEVEL%
