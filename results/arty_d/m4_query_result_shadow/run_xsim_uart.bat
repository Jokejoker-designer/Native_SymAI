@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set XD=D:\FPGA\arty_d\m4_query_result_shadow\xsim_uart
if not exist "%XD%" mkdir "%XD%"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%RTL%\directory\dir_a.mem" "%XD%\" >nul
copy /Y "%RTL%\directory\post_a.mem" "%XD%\" >nul
copy /Y "%RTL%\directory\post_expect.hex" "%XD%\" >nul
call xvlog -sv ^
  "%RTL%\common\crc32_iso_hdlc.sv" ^
  "%RTL%\loader\pack_loader.sv" ^
  "%RTL%\memory\mig_ui32.sv" ^
  "%RTL%\memory\pack_mig_bind.sv" ^
  "%RTL%\memory\mig_ui_bram.sv" ^
  "%RTL%\memory\mig_ui_mux.sv" ^
  "%RTL%\memory\fem_req_ui.sv" ^
  "%RTL%\memory\fem_on_mig.sv" ^
  "%RTL%\directory\runtime_profile.sv" ^
  "%RTL%\directory\exact_directory.sv" ^
  "%RTL%\directory\posting_walk.sv" ^
  "%RTL%\directory\bounded_walk.sv" ^
  "%RTL%\directory\query_walk_bind.sv" ^
  "%RTL%\astra\astra_qeval.sv" ^
  "%RTL%\directory\query_result_bind.sv" ^
  "%RTL%\strategy\spear_rank.v" ^
  "%RTL%\strategy\spear_profile_bind.sv" ^
  "%RTL%\strategy\qstar_select.v" ^
  "%RTL%\memory\fem_lifecycle.v" ^
  "%RTL%\memory\fem_media_bridge.v" ^
  "%RTL%\memory\fem_t2_adapter.v" ^
  "%RTL%\memory\fem_t2_ce.v" ^
  "%RTL%\memory\fem_media_sys.v" ^
  "%RTL%\board\uart_rx_word.sv" ^
  "%RTL%\board\uart_tx_word.sv" ^
  "%RTL%\board\uart_fe256_host.sv" ^
  "%RTL%\board\arty_a7_r2_top_m4_query_result_candidate.sv" ^
  "%ROOT%\tb\native_ai\board\tb_m4_query_result_uart_smoke.sv"
if errorlevel 1 exit /b 1
call xelab tb_m4_query_result_uart_smoke -snapshot tb_m4_uart -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_m4_uart -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
