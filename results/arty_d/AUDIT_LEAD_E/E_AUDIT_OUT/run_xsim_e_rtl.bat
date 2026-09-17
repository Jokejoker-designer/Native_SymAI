@echo off
set SNAP=D:\FPGA\arty_d\AUDIT_LEAD_E\snapshot\CANON_BLUEPRINT
set LIVE=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%SNAP%\rtl\native_ai
set TB=D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT
set XD=D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT\xsim_e_rtl
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
call xvlog -sv ^
  "%LIVE%\rtl\native_ai\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\board\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%TB%\tb_e_rtl_audit.sv"
if errorlevel 1 exit /b 1
call xelab tb_e_rtl_audit -snapshot snap_e_rtl -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim snap_e_rtl -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
