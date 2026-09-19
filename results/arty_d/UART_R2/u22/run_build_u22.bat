@echo off
setlocal
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl
set OUT=D:\FPGA\arty_d\UART_R2\build_u22
if not exist "%OUT%\reports" mkdir "%OUT%\reports"
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
call vivado -mode batch -notrace -source %TCL%\94_synth_uart_r2_u22.tcl -log %OUT%\synth.log -journal %OUT%\synth.jou
if errorlevel 1 exit /b 1
call vivado -mode batch -notrace -source %TCL%\95_impl_uart_r2_u22.tcl -log %OUT%\impl.log -journal %OUT%\impl.jou
if errorlevel 1 exit /b 1
call vivado -mode batch -notrace -source %TCL%\96_bit_uart_r2_u22.tcl -log %OUT%\bit.log -journal %OUT%\bit.jou
exit /b %ERRORLEVEL%
