@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u2" mkdir "%OUT%\xsim_u2"
cd /d "%OUT%\xsim_u2"
call "%XV%\xvlog.bat" -sv "%OUT%\u2\uart_rx_word.sv" "%OUT%\u2\tb_u2_framing.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u2_framing -s tb_u2
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u2 -runall
exit /b %ERRORLEVEL%
