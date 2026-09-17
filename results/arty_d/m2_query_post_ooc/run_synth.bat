call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\m2_query_post_ooc
if not exist D:\FPGA\arty_d\m2_query_post_ooc mkdir D:\FPGA\arty_d\m2_query_post_ooc
call vivado -mode batch -source "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\17_ooc_m2_query_post.tcl" -log "D:\FPGA\arty_d\m2_query_post_ooc\synth.log" -journal "D:\FPGA\arty_d\m2_query_post_ooc\synth.jou"
if errorlevel 1 exit /b 1
