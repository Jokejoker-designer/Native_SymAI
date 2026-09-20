@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2\build_u33obs_rgoff
call C:\2026.1\Vivado\settings64.bat
vivado -mode batch -notrace -log %OUT%\impl.log -journal %OUT%\impl.jou -source D:\FPGA\arty_d\UART_R2\u33obs\95_impl_uart_r2_u33obs_rgoff.tcl
exit /b %ERRORLEVEL%
