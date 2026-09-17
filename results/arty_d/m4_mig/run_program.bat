@echo off
call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\m4_mig
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\28_program_m4_mig.tcl" -log D:\FPGA\arty_d\m4_mig\program.log -journal D:\FPGA\arty_d\m4_mig\program.jou
if errorlevel 1 exit /b 1
