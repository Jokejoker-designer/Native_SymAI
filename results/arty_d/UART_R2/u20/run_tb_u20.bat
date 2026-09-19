@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
call C:\2026.1\Vivado\settings64.bat

if not exist "%R2%\xsim_u20d" mkdir "%R2%\xsim_u20d"
cd /d "%R2%\xsim_u20d"
call xvlog -sv ^
  "%R2%\u20\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u20\tb_u20_drop_flush.sv"
if errorlevel 1 exit /b 1
call xelab tb_u20_drop_flush -s tb_u20d -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u20d -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u20f" mkdir "%R2%\xsim_u20f"
cd /d "%R2%\xsim_u20f"
call xvlog -sv ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u20\pack_debug_clear.sv" ^
  "%R2%\u20\tb_u20_followon_drop.sv"
if errorlevel 1 exit /b 1
call xelab tb_u20_followon_drop -s tb_u20f -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u20f -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u20p" mkdir "%R2%\xsim_u20p"
cd /d "%R2%\xsim_u20p"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u20p\" >nul
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
  "%R2%\u20\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u20\pack_uart_dualclk_harness.sv" ^
  "%R2%\u20\tb_u20_parked_word.sv"
if errorlevel 1 exit /b 1
call xelab tb_u18_parked_word -s tb_u20p -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u20p -runall
if errorlevel 1 exit /b 1

if not exist "%R2%\xsim_u20j" mkdir "%R2%\xsim_u20j"
cd /d "%R2%\xsim_u20j"
copy /Y "%PA%\out\PA24-V-04.mem" "%R2%\xsim_u20j\" >nul
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
  "%R2%\u20\pack_debug_clear.sv" ^
  "%RTL%\board\pack_clear_ui.sv" ^
  "%R2%\u20\pack_uart_dualclk_harness.sv" ^
  "%R2%\u20\tb_u20_junk_after_gold.sv"
if errorlevel 1 exit /b 1
call xelab tb_u19_junk_after_gold -s tb_u20j -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_u20j -runall
exit /b %ERRORLEVEL%
