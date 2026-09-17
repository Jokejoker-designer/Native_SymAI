@echo off
REM D-04 common-runtime FE256 gate. Same B hex as tb_fe256_xsim_compare.
REM DUT=astra_edge_qeval (not fe256_query_path). Not FE256_PASS.
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set FE=%ROOT%\verification\fe256
set RTL=%ROOT%\rtl\native_ai
set XD=D:\FPGA\arty_d\common_runtime_fe256\xsim
if not exist "%XD%" mkdir "%XD%"
if not exist "%XD%\out" mkdir "%XD%\out"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%FE%\out\fe256_queries.hex" "%XD%\" >nul
copy /Y "%FE%\out\fe256_gold_results.hex" "%XD%\" >nul
copy /Y "%FE%\out\fe256_queries.hex" "%XD%\out\" >nul
copy /Y "%FE%\out\fe256_gold_results.hex" "%XD%\out\" >nul
copy /Y "%FE%\fe256_abi_constants.svh" "%XD%\" >nul
copy /Y "%RTL%\directory\dir_a.mem" "%XD%\" >nul
copy /Y "%RTL%\directory\post_a.mem" "%XD%\" >nul
copy /Y "%RTL%\fe256\fe256_store.mem" "%XD%\" >nul
call xvlog -sv -i "%XD%" -i "%FE%" ^
  "%RTL%\astra\astra_edge_qeval.sv" ^
  "%ROOT%\tb\native_ai\directory\tb_common_runtime_fe256_xsim_compare.sv"
if errorlevel 1 exit /b 1
call xelab tb_common_runtime_fe256_xsim_compare -snapshot tb_cr_fe256 -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_cr_fe256 -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
