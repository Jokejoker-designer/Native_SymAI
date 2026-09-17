call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d\mig_tx"
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\10c_impl_arty_mig_tx.tcl" -log "D:\FPGA\arty_d\mig_tx\impl.log" -journal "D:\FPGA\arty_d\mig_tx\impl.jou" > "D:\FPGA\arty_d\mig_tx\impl_console.txt" 2>&1
if errorlevel 1 exit /b 1
