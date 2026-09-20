@echo off
setlocal
rem Simulation only, Arty A7-100T source profile, Vivado 2026.1.
rem Usage: run_sim.bat [new-output-directory]
rem Outputs: discriminator.log, xsim.log, xvlog.log, xelab.log and snapshot files.
rem Next: inspect all five signatures; no board acceptance or programming authority.
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set R2=D:\FPGA\arty_d\UART_R2
set OUT=%~dp0sim
if not "%~1"=="" set OUT=%~1
if exist "%OUT%" exit /b 2
mkdir "%OUT%"
if errorlevel 1 exit /b 3
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
copy "%ROOT%\verification\pack_abi24\out\PA24-V-04.mem" "%OUT%\PA24-V-04.mem" >nul
call xvlog -work auditdisc -sv ^
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
 "%~dp0tb_u33_discriminator.sv"
if errorlevel 1 exit /b 4
call xelab auditdisc.tb_u33_discriminator -L auditdisc -s auditdisc -debug off -timescale 1ns/1ps
if errorlevel 1 exit /b 5
call xsim auditdisc -runall -log xsim.log
if errorlevel 1 exit /b 6
findstr /C:"DISCRIMINATOR_SIGNATURES_VERIFIED_XSIM_ONLY" discriminator.log >nul
if errorlevel 1 exit /b 7
exit /b 0
