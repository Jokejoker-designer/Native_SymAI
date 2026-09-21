@echo off
REM Unique CT1 synth. Does not overwrite build_u33obs_query. PROGRAM=NO.
call "C:\2026.1\Vivado\settings64.bat"
vivado -mode batch -source D:\FPGA\arty_d\UART_R2\ct1\94_synth_uart_r2_ct1.tcl -log D:\FPGA\arty_d\UART_R2\build_ct1\vivado_synth.log -journal D:\FPGA\arty_d\UART_R2\build_ct1\vivado_synth.jou
exit /b %ERRORLEVEL%
