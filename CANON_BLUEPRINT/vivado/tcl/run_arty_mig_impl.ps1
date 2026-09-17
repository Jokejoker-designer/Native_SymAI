param()
$ErrorActionPreference = "Stop"
$Settings = "C:\2026.1\Vivado\settings64.bat"
$out = "D:\FPGA\arty_d\mig_bind"
$tcl = "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\10_impl_arty_mig.tcl"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$run = @"
call `"$Settings`"
cd /d `"$out`"
call vivado -mode batch -source `"$tcl`" -log `"$out\impl.log`" -journal `"$out\impl.jou`"
if errorlevel 1 exit /b 1
"@
Set-Content -Path "$out\run_impl.bat" -Value $run -Encoding ASCII
cmd /c "$out\run_impl.bat"
if ($LASTEXITCODE -ne 0) { throw "mig impl failed: $LASTEXITCODE" }
