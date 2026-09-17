call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\fe256_ooc_r1
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\14_impl_fe256_r1.tcl" -log "D:\FPGA\arty_d\fe256_ooc_r1\impl.log" -journal "D:\FPGA\arty_d\fe256_ooc_r1\impl.jou" > "D:\FPGA\arty_d\fe256_ooc_r1\impl_console.txt" 2>&1
if errorlevel 1 exit /b 1
