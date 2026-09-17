@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_OBS
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
if not exist xsim_cap mkdir xsim_cap
cd xsim_cap
call "%XV%\xvlog.bat" -sv ..\uart_rx_word_observe.sv ..\h_obs_cap.sv ..\tb_h_obs_cap.sv
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_h_obs_cap -s tb_h_obs_cap
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_h_obs_cap -runall
exit /b %ERRORLEVEL%
