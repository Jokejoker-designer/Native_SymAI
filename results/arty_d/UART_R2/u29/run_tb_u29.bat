@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
call C:\2026.1\Vivado\settings64.bat

if not exist "%R2%\xsim_u29l" mkdir "%R2%\xsim_u29l"
cd /d "%R2%\xsim_u29l"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u29l\" >nul
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
  "%R2%\u29\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u29\pack_uart_dualclk_harness.sv" ^
  "%R2%\u29\tb_u29_leftover_op01.sv"
if errorlevel 1 exit /b 1
call xelab tb_u29_leftover_op01 -s tb_u29l -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u29l -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u29t" mkdir "%R2%\xsim_u29t"
cd /d "%R2%\xsim_u29t"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u29t\" >nul
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
  "%R2%\u29\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u29\pack_uart_dualclk_harness.sv" ^
  "%R2%\u29\tb_u29_two_v04.sv"
if errorlevel 1 exit /b 1
call xelab tb_u29_two_v04 -s tb_u29t -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u29t -runall
exit /b %ERRORLEVEL%
