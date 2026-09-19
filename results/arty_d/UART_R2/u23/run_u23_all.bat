@echo off
setlocal
python D:\FPGA\arty_d\UART_R2\u23\u23_campaign.py program
if errorlevel 1 exit /b 1
python D:\FPGA\arty_d\UART_R2\u23\u23_campaign.py p4ela
exit /b %ERRORLEVEL%
