call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\board\build_uart_pack"
copy /Y "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\loader\vectors\v1_valid.mem" . >nul
copy /Y "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\loader\vectors\v2_bad_magic.mem" . >nul
set RTL=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\rtl\native_ai
set TB=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\board\tb_uart_pack.sv
call xvlog -sv "%RTL%\common\crc32_iso_hdlc.sv" "%RTL%\loader\pack_loader.sv" "%RTL%\memory\mig_ui32.sv" "%RTL%\memory\pack_mig_bind.sv" "%RTL%\memory\mig_ui_bram.sv" "%RTL%\memory\mig_ui_mux.sv" "%RTL%\board\uart_rx_word.sv" "%RTL%\board\uart_tx_word.sv" "%TB%"
if errorlevel 1 exit /b 1
call xelab tb_uart_pack -snapshot snap_uart_pack -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> run_all.tcl
echo exit>> run_all.tcl
call xsim snap_uart_pack -tclbatch run_all.tcl -log xsim.log
if errorlevel 1 exit /b 1
