@echo off
setlocal
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl
set OUT=D:\FPGA\arty_d\UART_R2\build_u26
call C:\2026.1\Vivado\settings64.bat
cd /d %OUT%
call vivado -mode batch -notrace -source %TCL%\97_program_uart_r2_u26.tcl -log %OUT%\program.log -journal %OUT%\program.jou
exit /b %ERRORLEVEL%
