@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat

if not exist "%R2%\xsim_u18d" mkdir "%R2%\xsim_u18d"
cd /d "%R2%\xsim_u18d"
call xvlog -sv ^
  "%R2%\u18\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u18\tb_u18_drop_flush.sv"
if errorlevel 1 exit /b 1
call xelab tb_u18_drop_flush -s tb_u18d -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u18d -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u18p" mkdir "%R2%\xsim_u18p"
cd /d "%R2%\xsim_u18p"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u18p\" >nul
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
  "%R2%\u18\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u17\pack_uart_dualclk_harness.sv" ^
  "%R2%\u18\tb_u18_parked_word.sv"
if errorlevel 1 exit /b 1
call xelab tb_u18_parked_word -s tb_u18p -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u18p -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u18t" mkdir "%R2%\xsim_u18t"
cd /d "%R2%\xsim_u18t"
call xvlog -sv ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%R2%\u18\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\lib\word_cdc32.sv" ^
  "%R2%\u15\tb_u15_targeted.sv"
if errorlevel 1 exit /b 1
call xelab tb_u15_targeted -s tb_u18t -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u18t -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u18h" mkdir "%R2%\xsim_u18h"
cd /d "%R2%\xsim_u18h"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u18h\" >nul
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
  "%R2%\u18\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u17\pack_uart_dualclk_harness.sv" ^
  "%R2%\u17\tb_u17_harness_repeat.sv"
if errorlevel 1 exit /b 1
call xelab tb_u17_harness_repeat -s tb_u18h -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u18h -runall
exit /b %ERRORLEVEL%
