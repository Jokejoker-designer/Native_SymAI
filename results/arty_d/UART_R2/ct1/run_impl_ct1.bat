@echo off
REM Unique CT1 impl. Does not overwrite 8fc14f25. PROGRAM=NO.
call "C:\2026.1\Vivado\settings64.bat"
vivado -mode batch -source D:\FPGA\arty_d\UART_R2\ct1\95_impl_uart_r2_ct1.tcl -log D:\FPGA\arty_d\UART_R2\build_ct1\vivado_impl.log -journal D:\FPGA\arty_d\UART_R2\build_ct1\vivado_impl.jou
exit /b %ERRORLEVEL%
