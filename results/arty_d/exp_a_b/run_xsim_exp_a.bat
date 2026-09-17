@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set TB=%ROOT%\tb\native_ai\board
set XD=D:\FPGA\arty_d\exp_a_b\xsim_a
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%PA%\out\PA24-V-02.mem" "%XD%\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%RTL%\board\uart_rx_word.sv" ^
  "%RTL%\board\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%RTL%\board\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%TB%\pack_uart_dualclk_harness.sv" ^
  "%TB%\tb_exp_a_v02_dualclk.sv"
if errorlevel 1 exit /b 1
call xelab tb_exp_a_v02_dualclk -snapshot snap_exp_a -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim snap_exp_a -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
