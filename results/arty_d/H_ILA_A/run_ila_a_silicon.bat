@echo off
setlocal
set OUT=D:\FPGA\arty_d\H_ILA_A
call "%OUT%\run_ila_a_program.bat"
if errorlevel 1 exit /b %ERRORLEVEL%
python -c "import time; time.sleep(2)"
python "%OUT%\uart_ila_a_h11.py"
exit /b %ERRORLEVEL%
