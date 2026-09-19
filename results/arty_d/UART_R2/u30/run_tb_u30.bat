@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
call C:\2026.1\Vivado\settings64.bat

if not exist "%R2%\xsim_u30l" mkdir "%R2%\xsim_u30l"
cd /d "%R2%\xsim_u30l"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u30l\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%R2%\u30\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u30\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u30\pack_uart_dualclk_harness.sv" ^
  "%R2%\u30\tb_u30_leftover_op01.sv"
if errorlevel 1 exit /b 1
call xelab tb_u30_leftover_op01 -s tb_u30l -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u30l -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u30t" mkdir "%R2%\xsim_u30t"
cd /d "%R2%\xsim_u30t"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u30t\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%R2%\u30\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u30\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u30\pack_uart_dualclk_harness.sv" ^
  "%R2%\u30\tb_u30_two_v04.sv"
if errorlevel 1 exit /b 1
call xelab tb_u30_two_v04 -s tb_u30t -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u30t -runall
exit /b %ERRORLEVEL%
