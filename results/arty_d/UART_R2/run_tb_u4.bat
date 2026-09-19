@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u4" mkdir "%OUT%\xsim_u4"
cd /d "%OUT%\xsim_u4"
call "%XV%\xvlog.bat" -sv "%OUT%\u3\uart_rx_word.sv" "%OUT%\u4\tb_u4_idle_gap.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u4_idle_gap -s tb_u4
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u4 -runall
exit /b %ERRORLEVEL%
