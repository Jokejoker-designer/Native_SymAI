@echo off
setlocal
cd /d D:\FPGA\arty_d\H_OBS
echo WAIT 8s after program before UART
powershell -NoProfile -Command "Start-Sleep -Seconds 8"
python uart_h_obs.py
exit /b %ERRORLEVEL%
