rem Isolated shadow-bind inspect of FE256_HW_R1 RAMB. PROGRAM=NO.
call "C:\2026.1\Vivado\settings64.bat"
cd /d D:\FPGA\arty_d\fe256_ooc_r1
call vivado -mode batch -source "D:\FPGA\arty_d\fe256_ooc_r1\inspect_ramb.tcl" -log "D:\FPGA\arty_d\fe256_ooc_r1\inspect_ramb.log" -journal "D:\FPGA\arty_d\fe256_ooc_r1\inspect_ramb.jou"
