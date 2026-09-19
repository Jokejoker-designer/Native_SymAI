@echo off
setlocal
set OBS=D:\FPGA\arty_d\D_DEST_LIFECYCLE_OBS_01
call C:\2026.1\Vivado\settings64.bat
cd /d "%OBS%\xsim_mig0"

echo === xvlog harness+TB PACKAGE qsc A/B (-d OBS01_QSC_PKG) ===
call xvlog -work obs -d OBS01_QSC_PKG -sv ^
  "%OBS%\pack_uart_mig0_harness.sv" ^
  "%OBS%\tb_dest_lifecycle_obs_01_mig0.sv"
if errorlevel 1 exit /b 1

echo === xelab tb_obs01_mig0_pkgqsc ===
call xelab obs.tb_dest_lifecycle_obs_01_mig0 obs.glbl -L obs -L unisims_ver -L secureip -s tb_obs01_mig0_pkgqsc -timescale 1ps/1ps
if errorlevel 1 exit /b 1

echo === xsim PACKAGE qsc A/B ===
call xsim tb_obs01_mig0_pkgqsc -runall -log xsim_mig0_pkgqsc.log
if exist dest_ui_clk.csv copy /Y dest_ui_clk.csv "%OBS%\out\dest_ui_clk_mig0_pkgqsc.csv" >nul
if exist dest_ckpt_t1.csv copy /Y dest_ckpt_t1.csv "%OBS%\out\dest_ckpt_t1_pkgqsc.csv" >nul
if exist dest_ckpt_t2.csv copy /Y dest_ckpt_t2.csv "%OBS%\out\dest_ckpt_t2_pkgqsc.csv" >nul
copy /Y xsim_mig0_pkgqsc.log "%OBS%\out\xsim_mig0_pkgqsc.log" >nul
exit /b %ERRORLEVEL%
