@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
set OBS=D:\FPGA\arty_d\D_DEST_LIFECYCLE_OBS_01
call C:\2026.1\Vivado\settings64.bat

if not exist "%OBS%\out" mkdir "%OBS%\out"
if not exist "%OBS%\xsim" mkdir "%OBS%\xsim"
cd /d "%OBS%\xsim"
copy /Y "%PA%\out\PA24-V-04.mem" "%OBS%\xsim\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%R2%\u32\pack_mig_bind.sv" ^
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
  "%OBS%\dest_lifecycle_obs.sv" ^
  "%OBS%\tb_dest_lifecycle_obs_01.sv"
if errorlevel 1 exit /b 1
call xelab tb_dest_lifecycle_obs_01 -s tb_obs01 -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_obs01 -runall
if exist dest_ui_clk.csv copy /Y dest_ui_clk.csv "%OBS%\out\dest_ui_clk.csv" >nul
exit /b %ERRORLEVEL%
