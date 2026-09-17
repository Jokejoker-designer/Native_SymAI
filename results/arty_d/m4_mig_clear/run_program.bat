@echo off
setlocal
set OUT=D:\FPGA\arty_d\m4_mig_clear
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\32_program_m4_mig_clear.tcl
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
vivado -mode batch -notrace -source "%TCL%" -log "%OUT%\vivado_prog.log" -journal "%OUT%\vivado_prog.jou"
exit /b %ERRORLEVEL%
