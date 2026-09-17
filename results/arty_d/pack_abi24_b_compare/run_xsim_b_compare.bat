@echo off
REM Run B-owned tb_pack_abi24_xsim_compare against D pack_abi24_dut. Do not edit B TB/gold.
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set PA=%ROOT%\verification\pack_abi24
set RTL=%ROOT%\rtl\native_ai
set XD=D:\FPGA\arty_d\pack_abi24_b_compare\xsim
if not exist "%XD%" mkdir "%XD%"
if not exist "%XD%\out" mkdir "%XD%\out"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%PA%\out\*.mem" "%XD%\out\" >nul
copy /Y "%PA%\*.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_expect.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_fopen.svh" "%XD%\" >nul
copy /Y "%PA%\out\pack_abi24_constants.svh" "%XD%\" >nul
call xvlog -sv -i "%PA%" -i "%PA%\out" -i "%XD%" ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%PA%\pack_abi24_dut.sv" ^
  "%PA%\tb_pack_abi24_xsim_compare.sv"
if errorlevel 1 exit /b 1
call xelab tb_pack_abi24_xsim_compare -snapshot tb_pa24_b -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_pa24_b -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
