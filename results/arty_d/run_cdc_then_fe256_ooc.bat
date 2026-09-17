call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\mig_tx
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\12_cdc_mig_tx.tcl" -log "D:\FPGA\arty_d\mig_tx\cdc.log" -journal "D:\FPGA\arty_d\mig_tx\cdc.jou" > "D:\FPGA\arty_d\mig_tx\cdc_console.txt" 2>&1
if errorlevel 1 exit /b 1
if not exist D:\FPGA\arty_d\fe256_ooc mkdir D:\FPGA\arty_d\fe256_ooc
cd /d D:\FPGA\arty_d\fe256_ooc
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\13_ooc_fe256.tcl" -log "D:\FPGA\arty_d\fe256_ooc\synth.log" -journal "D:\FPGA\arty_d\fe256_ooc\synth.jou" > "D:\FPGA\arty_d\fe256_ooc\synth_console.txt" 2>&1
if errorlevel 1 exit /b 1
