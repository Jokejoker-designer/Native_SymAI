@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u17c" mkdir "%OUT%\xsim_u17c"
cd /d "%OUT%\xsim_u17c"
call "%XV%\xvlog.bat" -sv ^
  "%OUT%\lib\word_cdc32.sv" ^
  "%OUT%\u17\tb_u17_cdc_phantom.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u17_cdc_phantom -s tb_u17c -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u17c -runall
exit /b %ERRORLEVEL%
