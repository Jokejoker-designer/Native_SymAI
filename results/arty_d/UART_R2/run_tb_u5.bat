@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u5" mkdir "%OUT%\xsim_u5"
cd /d "%OUT%\xsim_u5"
call "%XV%\xvlog.bat" -sv "%OUT%\lib\word_fifo32.sv" "%OUT%\u5\tb_u5_fifo.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u5_fifo -s tb_u5
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u5 -runall
exit /b %ERRORLEVEL%
