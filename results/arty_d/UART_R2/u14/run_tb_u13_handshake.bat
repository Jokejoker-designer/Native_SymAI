@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
set PKG=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u13h" mkdir "%OUT%\xsim_u13h"
cd /d "%OUT%\xsim_u13h"
call "%XV%\xvlog.bat" -sv ^
  "%OUT%\u13\uart_tx_word.sv" ^
  "%OUT%\u8\pack_debug_clear.sv" ^
  "%PKG%\rtl\native_ai\board\pack_clear_ui.sv" ^
  "%OUT%\u14\tb_u14_handshake.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u14_handshake -s tb_u13h -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u13h -runall
exit /b %ERRORLEVEL%
