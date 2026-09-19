@echo off
setlocal
REM Continue UART_R2 from post_synth. Independent out only.
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set OUT=D:\FPGA\arty_d\UART_R2\build
set TCL=%ROOT%\vivado\tcl
set PY=D:\FPGA\arty_d\UART_R2\protect_other_branches.py
cd /d "%OUT%"
call "C:\2026.1\Vivado\settings64.bat"

python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== IMPL UART_R2/build only =====
call vivado -mode batch -source "%TCL%\51_impl_uart_r2.tcl" -log "%OUT%\impl.log" -journal "%OUT%\impl.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== BIT UART_R2/build/uart_r2_u2_candidate.bit =====
call vivado -mode batch -source "%TCL%\52_bit_uart_r2.tcl" -log "%OUT%\bit.log" -journal "%OUT%\bit.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== PROGRAM UART_R2 bit only =====
call vivado -mode batch -source "%TCL%\53_program_uart_r2.tcl" -log "%OUT%\program.log" -journal "%OUT%\program.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo UART_R2_BUILD_PROGRAM_FLOW_DONE
exit /b 0
