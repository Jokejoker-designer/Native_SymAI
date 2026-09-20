@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set XD=D:\FPGA\arty_d\pack_abi24_obs_dut\xsim
set OBS=D:\FPGA\arty_d\UART_R2\u33obs
if not exist "%XD%" mkdir "%XD%"
if not exist "%XD%\out" mkdir "%XD%\out"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%PA%\out\*.mem" "%XD%\out\" >nul
python "D:\FPGA\arty_d\pack_abi24_obs_dut\emit_query_obs.py"
if errorlevel 1 exit /b 1
copy /Y "%PA%\*.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_expect.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_fopen.svh" "%XD%\" >nul
if exist xvlog.pb del /q xvlog.pb
if exist xelab.pb del /q xelab.pb
call xvlog -work pa24obs -sv -i "%PA%" -i "%PA%\out" ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%PA%\pack_abi24_mig_dut.sv" ^
  "%OBS%\pack_obs_gen.sv" ^
  "D:\FPGA\arty_d\pack_abi24_obs_dut\pack_query_eval.sv" ^
  "D:\FPGA\arty_d\pack_abi24_obs_dut\tb_pack_abi24_obs_dut.sv"
if errorlevel 1 exit /b 1
call xelab pa24obs.tb_pack_abi24_obs_dut -L pa24obs -s tb_pa24_obs -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_pa24_obs -tclbatch run_all.tcl -log "%XD%\xsim.log"
exit /b %ERRORLEVEL%
