@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u6" mkdir "%OUT%\xsim_u6"
cd /d "%OUT%\xsim_u6"
call "%XV%\xvlog.bat" -sv "%OUT%\lib\crc32_iso_hdlc.sv" "%OUT%\lib\pack_loader.sv" "%OUT%\u6\uart_fe256_host.sv" "%OUT%\u6\tb_u6_generation.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u6_generation -s tb_u6
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u6 -runall
exit /b %ERRORLEVEL%
