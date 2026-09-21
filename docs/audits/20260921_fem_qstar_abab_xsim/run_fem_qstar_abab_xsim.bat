@echo off
REM Q* A/B/A/B on mig_ui_bram. PROGRAM=NO. Does not touch 1db38691 bit.
REM PASS_XSIM only. FEM_PERSIST_PASS=NO BOARD_PASS=NO.
set ROOT=D:\FPGA\Native_SymAI\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set TREE=D:\FPGA\arty_d\UART_R2\fem_qstar_causal
set XD=%TREE%\xsim
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
if exist xvlog.pb del /q xvlog.pb
if exist xelab.pb del /q xelab.pb
call xvlog -work fq -sv ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%RTL%\memory\fem_req_ui.sv" ^
  "%RTL%\memory\fem_on_mig.sv" ^
  "%RTL%\memory\fem_lifecycle.v" ^
  "%RTL%\memory\fem_t2_adapter.v" ^
  "%RTL%\memory\fem_t2_ce.v" ^
  "%RTL%\strategy\qstar_select.v" ^
  "%TREE%\fem_qstar_infl.sv" ^
  "%TREE%\tb_fem_qstar_abab.sv"
if errorlevel 1 exit /b 1
call xelab fq.tb_fem_qstar_abab -L fq -s tb_fem_qstar_abab -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_fem_qstar_abab.tcl"
echo exit>> "%XD%\run_fem_qstar_abab.tcl"
call xsim tb_fem_qstar_abab -tclbatch run_fem_qstar_abab.tcl -log "%XD%\fem_qstar_abab_xsim.log"
exit /b %ERRORLEVEL%
