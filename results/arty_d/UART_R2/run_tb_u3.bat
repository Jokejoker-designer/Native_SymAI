@echo off
setlocal
set OUT=D:\FPGA\arty_d\UART_R2
set XV=C:\2026.1\Vivado\bin
call C:\2026.1\Vivado\settings64.bat
if not exist "%OUT%\xsim_u3" mkdir "%OUT%\xsim_u3"
cd /d "%OUT%\xsim_u3"
call "%XV%\xvlog.bat" -sv "%OUT%\u3\uart_rx_word.sv" "%OUT%\lib\word_fifo32.sv" "%OUT%\lib\word_cdc32.sv" "%OUT%\lib\crc32_iso_hdlc.sv" "%OUT%\lib\pack_loader.sv" "%OUT%\u6\uart_fe256_host.sv" "%OUT%\u3\tb_u3_clear.sv"
if errorlevel 1 exit /b 1
call "%XV%\xelab.bat" tb_u3_clear -s tb_u3
if errorlevel 1 exit /b 1
call "%XV%\xsim.bat" tb_u3 -runall
exit /b %ERRORLEVEL%
