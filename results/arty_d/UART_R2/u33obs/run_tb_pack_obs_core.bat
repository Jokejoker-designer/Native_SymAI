@echo off
setlocal
set R2=D:\FPGA\arty_d\UART_R2
set OUT=%R2%\xsim_u33obs_core
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%" mkdir "%OUT%"
cd /d "%OUT%"
echo run -all> run.tcl
echo puts DONE>> run.tcl
echo exit>> run.tcl
call xvlog -work obs -sv ^
  "%R2%\u33obs\pack_obs_lane.sv" ^
  "%R2%\u33obs\pack_obs_gen.sv" ^
  "%R2%\u33obs\pack_obs_ctrl.sv" ^
  "%R2%\u33obs\tb_pack_obs_core.sv"
if errorlevel 1 exit /b 1
call xelab obs.tb_pack_obs_core -L obs -s tb_obs_core -debug off -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim tb_obs_core -tclbatch run.tcl -log xsim_u33obs_core.log
exit /b %ERRORLEVEL%
