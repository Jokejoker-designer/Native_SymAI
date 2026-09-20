@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2\build_u33obs_steer
if not exist "%OUT%\reports" mkdir "%OUT%\reports"
call C:\2026.1\Vivado\settings64.bat
vivado -mode batch -notrace -log %OUT%\synth.log -journal %OUT%\synth.jou -source D:\FPGA\arty_d\UART_R2\u33obs\94_synth_uart_r2_u33obs_steer.tcl
exit /b %ERRORLEVEL%
