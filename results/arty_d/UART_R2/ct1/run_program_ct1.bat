@echo off
setlocal
if not "%~1"=="OWNER_AUTHORIZED" (
  echo uart_r2_ct1_PROGRAM_REFUSED need OWNER_AUTHORIZED
  echo PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO
  exit /b 4
)
set OUT=D:\FPGA\arty_d\UART_R2\results\CT1_OWNER_PROGRAM_20260921
if not exist "%OUT%" mkdir "%OUT%"
call C:\2026.1\Vivado\settings64.bat
vivado -mode batch -notrace -log %OUT%\program.log -journal %OUT%\program.jou -source D:\FPGA\arty_d\UART_R2\ct1\97_program_uart_r2_ct1.tcl -tclargs %OUT% OWNER_AUTHORIZED
exit /b %ERRORLEVEL%
