@echo off
setlocal
echo === E2 program + p4ela_ack_once ===
call D:\FPGA\arty_d\UART_R2\u23\run_program_u23.bat
if errorlevel 1 exit /b 1
python D:\FPGA\arty_d\UART_R2\u23\u23_campaign.py p4ela_ack_once
set E2=%ERRORLEVEL%
echo E2_RC=%E2%
echo === E1 program + uart_once ===
call D:\FPGA\arty_d\UART_R2\u23\run_program_u23.bat
if errorlevel 1 exit /b 1
python D:\FPGA\arty_d\UART_R2\u23\u23_campaign.py uart_once
set E1=%ERRORLEVEL%
echo E1_RC=%E1%
exit /b 0
