call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d"
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\07_ooc_mig_ui32.tcl" -log "D:\FPGA\arty_d\ooc_mig_ui32.log" -journal "D:\FPGA\arty_d\ooc_mig_ui32.jou"
if errorlevel 1 exit /b 1
