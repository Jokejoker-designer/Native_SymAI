call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d\cdc_xsim"
call xvlog -sv "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\rtl\native_ai\board\word_cdc32.sv" "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\board\tb_word_cdc32.sv"
if errorlevel 1 exit /b 1
call xelab tb_word_cdc32 -snapshot snap_cdc -timescale 1ns/1ps
if errorlevel 1 exit /b 1
call xsim snap_cdc -runall
if errorlevel 1 exit /b 1
