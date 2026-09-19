@echo off
setlocal
set ROOT=D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_h20_hclass" mkdir "%OUT%\xsim_h20_hclass"
cd /d "%OUT%\xsim_h20_hclass"
call "%XV%\xvlog.bat" -sv "%OUT%\frozen\uart_rx_word_H_class.sv" "%ROOT%\rtl\native_ai\common\crc32_iso_hdlc.sv" "%ROOT%\rtl\native_ai\loader\pack_loader.sv" "%ROOT%\tb\native_ai\board\tb_h20_4th_byte_bp.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_h20_4th_byte_bp -s tb_h20_hclass
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_h20_hclass -runall
exit /b %ERRORLEVEL%
