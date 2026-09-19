@echo off
setlocal
REM Isolated U3 RX bit. Writes ONLY UART_R2/build_u3. Leaves UART_R2/build and all other identities alone.
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set OUT=D:\FPGA\arty_d\UART_R2\build_u3
set TCL=%ROOT%\vivado\tcl
set PY=D:\FPGA\arty_d\UART_R2\protect_other_branches.py
if not exist "%OUT%" mkdir "%OUT%"
cd /d "%OUT%"
call "C:\2026.1\Vivado\settings64.bat"

python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== SYNTH UART_R2/build_u3 =====
call vivado -mode batch -source "%TCL%\54_synth_uart_r2_u3.tcl" -log "%OUT%\synth.log" -journal "%OUT%\synth.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== IMPL UART_R2/build_u3 =====
call vivado -mode batch -source "%TCL%\55_impl_uart_r2_u3.tcl" -log "%OUT%\impl.log" -journal "%OUT%\impl.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== BIT uart_r2_u3_candidate.bit =====
call vivado -mode batch -source "%TCL%\56_bit_uart_r2_u3.tcl" -log "%OUT%\bit.log" -journal "%OUT%\bit.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo ===== PROGRAM U3 bit only =====
call vivado -mode batch -source "%TCL%\57_program_uart_r2_u3.tcl" -log "%OUT%\program.log" -journal "%OUT%\program.jou"
if errorlevel 1 exit /b 1
python "%PY%" verify
if errorlevel 1 exit /b 1

echo UART_R2_U3_FLOW_OK
exit /b 0
