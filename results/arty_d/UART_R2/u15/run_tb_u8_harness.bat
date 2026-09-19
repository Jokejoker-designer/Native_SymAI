@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set TB=%ROOT%\tb\native_ai\board
set R2=D:\FPGA\arty_d\UART_R2
set XD=%R2%\xsim_u15h
if not exist "%XD%" mkdir "%XD%"
call C:\2026.1\Vivado\settings64.bat
cd /d "%XD%"
copy /Y "%PA%\out\PA24-V-04.mem" "%XD%\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u8\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%TB%\pack_uart_dualclk_harness.sv" ^
  "%R2%\u15\tb_u15_harness_v04_clear.sv"
if errorlevel 1 exit /b 1
call xelab tb_u15_harness_v04_clear -s tb_u15h -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u15h -runall
exit /b %ERRORLEVEL%
