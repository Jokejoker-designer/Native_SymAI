@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_ILA_A
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\38_ila_a_capture.tcl
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
start "H-ILA-A-HW" /b vivado -mode batch -notrace -source "%TCL%" -log "%OUT%\vivado_ila_a_capture.log" -journal "%OUT%\vivado_ila_a_capture.jou"
python "%OUT%\uart_ila_a_h11.py"
python "%OUT%\decode_ila_a.py"
exit /b %ERRORLEVEL%
