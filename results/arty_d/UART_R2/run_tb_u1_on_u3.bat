@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u1_on_u3" mkdir "%OUT%\xsim_u1_on_u3"
cd /d "%OUT%\xsim_u1_on_u3"
call "%XV%\xvlog.bat" -sv "%OUT%\u3\uart_rx_word.sv" "%OUT%\u1\tb_u1_h20_conservation.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u1_h20_conservation -s tb_u1u3
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u1u3 -runall
exit /b %ERRORLEVEL%
