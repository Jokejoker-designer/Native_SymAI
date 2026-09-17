if not exist "D:\FPGA\arty_d\uart_word" mkdir "D:\FPGA\arty_d\uart_word"
call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\arty_d\uart_word"
call xvlog -sv "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\rtl\native_ai\board\uart_tx_word.sv" "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\rtl\native_ai\board\uart_rx_word.sv" "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\board\tb_uart_word.sv"
if errorlevel 1 exit /b 1
call xelab tb_uart_word -snapshot snap_uart_word -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> run_all.tcl
echo exit>> run_all.tcl
call xsim snap_uart_word -tclbatch run_all.tcl -log xsim.log
if errorlevel 1 exit /b 1
