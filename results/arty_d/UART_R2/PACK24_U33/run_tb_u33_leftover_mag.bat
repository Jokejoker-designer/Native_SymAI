@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
set OUT=%R2%\xsim_u33mag
call C:\2026.1\Vivado\settings64.bat

if not exist "%OUT%" mkdir "%OUT%"
cd /d "%OUT%"
copy /Y "%PA%\out\PA24-V-04.mem" "%OUT%\" >nul
echo run -all> run.tcl
echo puts DONE>> run.tcl
echo exit>> run.tcl
echo === leftover BEGIN MAG inject BRAM (not mig0 work) ===
call xvlog -work u33mag -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%R2%\u33\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u32\pack_debug_clear.sv" ^
  "%R2%\u32\pack_clear_ui.sv" ^
  "%R2%\u32\pack_uart_dualclk_harness.sv" ^
  "%R2%\u33\tb_u33_leftover_begin_mag.sv"
if errorlevel 1 exit /b 1
call xelab u33mag.tb_u33_leftover_begin_mag -L u33mag -s tb_u33mag -debug off -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u33mag -tclbatch run.tcl -log xsim_u33mag.log
exit /b %ERRORLEVEL%
