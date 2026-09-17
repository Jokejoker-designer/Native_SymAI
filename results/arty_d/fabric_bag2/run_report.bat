call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d\fabric_bag2"
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\05d_report_fabric_bag2.tcl" -log "D:\FPGA\arty_d\fabric_bag2\report.log" -journal "D:\FPGA\arty_d\fabric_bag2\report.jou" > "D:\FPGA\arty_d\fabric_bag2\report_console.txt" 2>&1
if errorlevel 1 exit /b 1
