@echo off
if not exist D:\FPGA\arty_d\m4_mig mkdir D:\FPGA\arty_d\m4_mig
call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\m4_mig
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\25_synth_m4_mig.tcl" -log "D:\FPGA\arty_d\m4_mig\synth.log" -journal "D:\FPGA\arty_d\m4_mig\synth.jou"
if errorlevel 1 exit /b 1
