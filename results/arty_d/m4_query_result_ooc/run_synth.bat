call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\m4_query_result_ooc
if not exist D:\FPGA\arty_d\m4_query_result_ooc mkdir D:\FPGA\arty_d\m4_query_result_ooc
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\21_ooc_m4_query_result.tcl" -log "D:\FPGA\arty_d\m4_query_result_ooc\synth.log" -journal "D:\FPGA\arty_d\m4_query_result_ooc\synth.jou"
if errorlevel 1 exit /b 1
