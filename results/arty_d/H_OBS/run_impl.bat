@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_OBS
set TCL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\41b_impl_h_obs.tcl
if not exist "%OUT%\reports" mkdir "%OUT%\reports"
call C:\2026.1\Vivado\settings64.bat
cd /d "%OUT%"
vivado -mode batch -notrace -source "%TCL%" -log "%OUT%\vivado_h_obs_impl.log" -journal "%OUT%\vivado_h_obs_impl.jou"
exit /b %ERRORLEVEL%
