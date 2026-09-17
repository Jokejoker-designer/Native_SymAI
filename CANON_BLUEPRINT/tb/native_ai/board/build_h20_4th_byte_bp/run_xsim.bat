@echo off
call "C:\2026.1\Vivado\settings64.bat"
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set OUT=%ROOT%\tb\native_ai\board\build_h20_4th_byte_bp
if not exist "%OUT%" mkdir "%OUT%"
cd /d "%OUT%"
set RTL=%ROOT%\rtl\native_ai
set TB=%ROOT%\tb\native_ai\board\tb_h20_4th_byte_bp.sv
call xvlog -sv "%RTL%\common\crc32_iso_hdlc.sv" "%RTL%\loader\pack_loader.sv" "%RTL%\board\uart_rx_word.sv" "%TB%"
if errorlevel 1 exit /b 1
call xelab tb_h20_4th_byte_bp -snapshot snap_h20_bp -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> run_all.tcl
echo exit>> run_all.tcl
call xsim snap_h20_bp -tclbatch run_all.tcl -log xsim.log
if errorlevel 1 exit /b 1
