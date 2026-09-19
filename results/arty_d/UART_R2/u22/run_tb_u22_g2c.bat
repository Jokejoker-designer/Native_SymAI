@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
call C:\2026.1\Vivado\settings64.bat

if not exist "%R2%\xsim_u21d" mkdir "%R2%\xsim_u21d"
cd /d "%R2%\xsim_u21d"
call xvlog -sv ^
  "%R2%\u21\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u21\tb_u20_drop_flush.sv"
if errorlevel 1 exit /b 1
call xelab tb_u20_drop_flush -s tb_u21d -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21d -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u21f" mkdir "%R2%\xsim_u21f"
cd /d "%R2%\xsim_u21f"
call xvlog -sv ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u21\pack_debug_clear.sv" ^
  "%R2%\u21\tb_u20_followon_drop.sv"
if errorlevel 1 exit /b 1
call xelab tb_u20_followon_drop -s tb_u21f -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21f -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u21t" mkdir "%R2%\xsim_u21t"
cd /d "%R2%\xsim_u21t"
call xvlog -sv ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%R2%\u21\tb_u21_tx_ack.sv"
if errorlevel 1 exit /b 1
call xelab tb_u21_tx_ack -s tb_u21t -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21t -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u21p" mkdir "%R2%\xsim_u21p"
cd /d "%R2%\xsim_u21p"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u21p\" >nul
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
  "%R2%\u21\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u21\pack_uart_dualclk_harness.sv" ^
  "%R2%\u21\tb_u20_parked_word.sv"
if errorlevel 1 exit /b 1
call xelab tb_u18_parked_word -s tb_u21p -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21p -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u21j" mkdir "%R2%\xsim_u21j"
cd /d "%R2%\xsim_u21j"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u21j\" >nul
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
  "%R2%\u21\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u21\pack_uart_dualclk_harness.sv" ^
  "%R2%\u21\tb_u20_junk_after_gold.sv"
if errorlevel 1 exit /b 1
call xelab tb_u19_junk_after_gold -s tb_u21j -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21j -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u21g" mkdir "%R2%\xsim_u21g"
cd /d "%R2%\xsim_u21g"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u21g\" >nul
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
  "%R2%\u21\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u21\pack_uart_dualclk_harness.sv" ^
  "%R2%\u21\tb_u21_gold_then_clear.sv"
if errorlevel 1 exit /b 1
call xelab tb_u21_gold_then_clear -s tb_u21g -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u21g -runall
exit /b %ERRORLEVEL%
