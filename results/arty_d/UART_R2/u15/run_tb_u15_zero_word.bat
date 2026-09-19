@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
set PKG=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u15z" mkdir "%OUT%\xsim_u15z"
cd /d "%OUT%\xsim_u15z"
call "%XV%\xvlog.bat" -sv ^
  "%OUT%\u14\uart_tx_word.sv" ^
  "%OUT%\u15\pack_debug_clear.sv" ^
  "%PKG%\rtl\native_ai\board\pack_clear_ui.sv" ^
  "%OUT%\lib\word_cdc32.sv" ^
  "%OUT%\u15\tb_u15_zero_word.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u15_zero_word -s tb_u15z -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u15z -runall
exit /b %ERRORLEVEL%
