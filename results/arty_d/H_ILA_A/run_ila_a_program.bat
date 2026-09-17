@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_ILA_A
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\40_program_ila_a.tcl
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
vivado -mode batch -notrace -source "%TCL%" -log "%OUT%\vivado_ila_a_prog.log" -journal "%OUT%\vivado_ila_a_prog.jou"
exit /b %ERRORLEVEL%
