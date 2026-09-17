@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_ILA_A
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\39_build_ila_a_observe.tcl
if not exist "%OUT%\reports" mkdir "%OUT%\reports"
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
vivado -mode batch -notrace -source "%TCL%" -log "%OUT%\vivado_ila_a_observe.log" -journal "%OUT%\vivado_ila_a_observe.jou"
exit /b %ERRORLEVEL%
