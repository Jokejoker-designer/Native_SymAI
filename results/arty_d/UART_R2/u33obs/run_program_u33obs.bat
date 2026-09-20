@echo off
setlocal
if not "%~1"=="OWNER_AUTHORIZED" (
  echo uart_r2_u33obs_PROGRAM_REFUSED need OWNER_AUTHORIZED
  echo PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO
  exit /b 4
)
set OUT=D:\FPGA\arty_d\UART_R2\results\U33OBS_OWNER_PROGRAM
if not exist "%OUT%" mkdir "%OUT%"
call C:\2026.1\Vivado\settings64.bat
vivado -mode batch -notrace -log %OUT%\program.log -journal %OUT%\program.jou -source D:\FPGA\arty_d\UART_R2\u33obs\97_program_uart_r2_u33obs.tcl -tclargs %OUT% OWNER_AUTHORIZED
exit /b %ERRORLEVEL%
