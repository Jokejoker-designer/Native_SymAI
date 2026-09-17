call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\m3_query_walk_ooc
if not exist D:\FPGA\arty_d\m3_query_walk_ooc mkdir D:\FPGA\arty_d\m3_query_walk_ooc
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\19_ooc_m3_query_walk.tcl" -log "D:\FPGA\arty_d\m3_query_walk_ooc\synth.log" -journal "D:\FPGA\arty_d\m3_query_walk_ooc\synth.jou"
if errorlevel 1 exit /b 1
