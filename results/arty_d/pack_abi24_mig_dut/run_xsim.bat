@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set PA=%ROOT%\verification\pack_abi24
set XD=D:\FPGA\arty_d\pack_abi24_mig_dut\xsim
if not exist "%XD%" mkdir "%XD%"
if not exist "%XD%\out" mkdir "%XD%\out"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%PA%\out\*.mem" "%XD%\out\" >nul
copy /Y "%PA%\*.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_expect.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_fopen.svh" "%XD%\" >nul
call xvlog -sv -i "%PA%" -i "%PA%\out" ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%PA%\pack_abi24_mig_dut.sv" ^
  "%ROOT%\tb\native_ai\loader\tb_pack_abi24_mig_dut.sv"
if errorlevel 1 exit /b 1
call xelab tb_pack_abi24_mig_dut -snapshot tb_pa24_mig -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_pa24_mig -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
