@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set R2=D:\FPGA\arty_d\UART_R2
set OBS=D:\FPGA\arty_d\D_DEST_LIFECYCLE_OBS_01
set MIG=D:\FPGA\miggen\p\mig0.gen\sources_1\ip\mig0\mig0
set SIM=%MIG%\example_design\sim
set VIVADO_GLBL=C:\2026.1\Vivado\data\verilog\src\glbl.v
call C:\2026.1\Vivado\settings64.bat

if not exist "%OBS%\out" mkdir "%OBS%\out"
if not exist "%OBS%\xsim_mig0" mkdir "%OBS%\xsim_mig0"
cd /d "%OBS%\xsim_mig0"
copy /Y "%PA%\out\PA24-V-04.mem" "%OBS%\xsim_mig0\" >nul
python "%OBS%\mk_mig0_prj.py"
if errorlevel 1 exit /b 1

echo === xvlog pack ===
call xvlog -work obs -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%R2%\u32\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u32\pack_debug_clear.sv" ^
  "%R2%\u32\pack_clear_ui.sv" ^
  "%OBS%\pack_uart_mig0_harness.sv" ^
  "%OBS%\dest_lifecycle_obs.sv" ^
  "%OBS%\dest_lifecycle_obs_mig0.sv" ^
  "%OBS%\tb_dest_lifecycle_obs_01_mig0.sv"
if errorlevel 1 exit /b 1

echo === xvlog ddr3 ===
call xvlog -work obs -sv -i "%SIM%" "%SIM%\ddr3_model.sv"
if errorlevel 1 exit /b 1

echo === xvlog mig0 rtl (sim FAST, skip mig0_mig.v) ===
call xvlog -work obs -f "%OBS%\mig0_rtl.f"
if errorlevel 1 exit /b 1

echo === xvlog glbl ===
call xvlog -work obs "%VIVADO_GLBL%"
if errorlevel 1 exit /b 1

echo === xelab ===
call xelab obs.tb_dest_lifecycle_obs_01_mig0 obs.glbl -L obs -L unisims_ver -L secureip -s tb_obs01_mig0 -timescale 1ps/1ps
if errorlevel 1 exit /b 1

echo === xsim ===
call xsim tb_obs01_mig0 -runall
if exist dest_ui_clk.csv copy /Y dest_ui_clk.csv "%OBS%\out\dest_ui_clk_mig0.csv" >nul
if exist dest_ckpt_t1.csv copy /Y dest_ckpt_t1.csv "%OBS%\out\dest_ckpt_t1.csv" >nul
if exist dest_ckpt_t2.csv copy /Y dest_ckpt_t2.csv "%OBS%\out\dest_ckpt_t2.csv" >nul
copy /Y xsim.log "%OBS%\out\xsim_mig0.log" >nul
exit /b %ERRORLEVEL%
