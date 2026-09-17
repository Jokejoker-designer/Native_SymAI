@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set TB=D:\FPGA\arty_d\pack_debug_clear
set XD=D:\FPGA\arty_d\pack_debug_clear\xsim_hold
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
call xvlog -sv ^
  "%RTL%\board\uart_rx_word.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%RTL%\board\pack_debug_clear.sv" ^
  "%TB%\tb_pack_hold_flood.sv"
if errorlevel 1 exit /b 1
call xelab tb_pack_hold_flood -snapshot snap_hold -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim snap_hold -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
