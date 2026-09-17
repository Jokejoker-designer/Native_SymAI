param()
$ErrorActionPreference = "Stop"
$Settings = "C:\2026.1\Vivado\settings64.bat"
$out = "D:\FPGA\arty_d"
$tcl = "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\06_ooc_fem_media_sys.tcl"
$run = @"
call `"$Settings`"
cd /d `"$out`"
call vivado -mode batch -source `"$tcl`" -log `"$out\ooc_fem_crcpipe.log`" -journal `"$out\ooc_fem_crcpipe.jou`"
if errorlevel 1 exit /b 1
"@
Set-Content -Path "$out\run_ooc_fem_crcpipe.bat" -Value $run -Encoding ASCII
cmd /c "$out\run_ooc_fem_crcpipe.bat"
if ($LASTEXITCODE -ne 0) { throw "ooc fem_media_sys failed: $LASTEXITCODE" }
