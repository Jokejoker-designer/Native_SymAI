@echo off
set ROOT=D:\FPGA\Native_SymAI\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set R2=D:\FPGA\arty_d\UART_R2
set CT1=%R2%\ct1
set XD=%CT1%\xsim
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
python "%CT1%\emit_dir_pack.py"
if errorlevel 1 exit /b 1
if exist xvlog.pb del /q xvlog.pb
if exist xelab.pb del /q xelab.pb
call xvlog -work ct1int -sv -d CT1_XSIM -i "%ROOT%\verification\pack_abi24" ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%RTL%\board\word_cdc32.sv" ^
  "%RTL%\board\word_fifo32.sv" ^
  "%R2%\u33\pack_mig_bind.sv" ^
  "%R2%\u11\uart_rx_word.sv" ^
  "%R2%\u14\uart_tx_word.sv" ^
  "%R2%\u32\pack_debug_clear.sv" ^
  "%R2%\u32\pack_clear_ui.sv" ^
  "%R2%\u33obs\pack_obs_ctrl.sv" ^
  "%R2%\u33obs\pack_obs_gen.sv" ^
  "%R2%\u33obs\pack_obs_dump.sv" ^
  "%CT1%\dest_root_cache.sv" ^
  "%CT1%\ct1_lookup_cdc.sv" ^
  "%CT1%\ct1_uart_query.sv" ^
  "%CT1%\arty_a7_r2_top_m4_mig_candidate.sv" ^
  "%CT1%\tb_ct1_integrated.sv"
if errorlevel 1 exit /b 1
call xelab ct1int.tb_ct1_integrated -L ct1int -s tb_ct1_int -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_ct1_int.tcl"
echo exit>> "%XD%\run_ct1_int.tcl"
call xsim tb_ct1_int -tclbatch run_ct1_int.tcl -log "%XD%\ct1_int_xsim.log"
exit /b %ERRORLEVEL%
