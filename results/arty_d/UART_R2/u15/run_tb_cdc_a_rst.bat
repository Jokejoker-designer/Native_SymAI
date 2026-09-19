@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_cdc_rst" mkdir "%OUT%\xsim_cdc_rst"
cd /d "%OUT%\xsim_cdc_rst"
call "%XV%\xvlog.bat" -sv "%OUT%\lib\word_cdc32.sv" "%OUT%\u15\tb_cdc_a_rst.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_cdc_a_rst -s tb_cdc -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_cdc -runall
exit /b %ERRORLEVEL%
