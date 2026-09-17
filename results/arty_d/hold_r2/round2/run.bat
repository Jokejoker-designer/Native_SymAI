call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d\hold_r2\round2"
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\11_hold_r2_round2.tcl" -log "D:\FPGA\arty_d\hold_r2\round2\vivado.log" -journal "D:\FPGA\arty_d\hold_r2\round2\vivado.jou" > "D:\FPGA\arty_d\hold_r2\round2\console.txt" 2>&1
if errorlevel 1 exit /b 1
