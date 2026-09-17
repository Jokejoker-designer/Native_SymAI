@echo off
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set RTL=%ROOT%\rtl\native_ai
set XD=D:\FPGA\arty_d\fe256_r1_shadow\xsim
if not exist "%XD%" mkdir "%XD%"
if not exist "%XD%\out" mkdir "%XD%\out"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "%XD%"
copy /Y "%ROOT%\verification\fe256\out\fe256_queries.hex" "%XD%\" >nul
copy /Y "%ROOT%\verification\fe256\out\fe256_gold_results.hex" "%XD%\" >nul
copy /Y "%ROOT%\verification\fe256\out\fe256_queries.hex" "%XD%\out\" >nul
copy /Y "%ROOT%\verification\fe256\out\fe256_gold_results.hex" "%XD%\out\" >nul
copy /Y "%ROOT%\verification\fe256\fe256_abi_constants.svh" "%XD%\" >nul
copy /Y "%RTL%\fe256\fe256_store.mem" "%XD%\" >nul
copy /Y "%RTL%\directory\dir_a.mem" "%XD%\" >nul
copy /Y "%RTL%\directory\post_a.mem" "%XD%\" >nul
call xvlog -sv -i "%ROOT%\verification\fe256" ^
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
  "%RTL%\fe256\fe256_query_path.sv" ^
  "%RTL%\board\arty_a7_r2_top_fe256_r1_candidate.sv" ^
  "%ROOT%\verification\fe256\tb_fe256_r1_shadow_bind.sv"
if errorlevel 1 exit /b 1
call xelab tb_fe256_r1_shadow_bind -snapshot tb_fe256_shadow -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "%XD%\run_all.tcl"
echo exit>> "%XD%\run_all.tcl"
call xsim tb_fe256_shadow -tclbatch run_all.tcl -log "%XD%\xsim.log"
if errorlevel 1 exit /b 1
