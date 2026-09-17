param()
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
$sim = Join-Path $Root "tb\native_ai\memory\build_mig_ui32"
New-Item -ItemType Directory -Force -Path $sim | Out-Null
$rtl = Join-Path $Root "rtl\native_ai\memory"
$tb  = Join-Path $Root "tb\native_ai\memory"
$run = @"
call `"$Settings`"
cd /d `"$sim`"
call xvlog -sv `"$rtl\mig_ui32.sv`" `"$tb\mig_ui_model.sv`" `"$tb\tb_mig_ui32.sv`"
if errorlevel 1 exit /b 1
call xelab tb_mig_ui32 -snapshot snap_ui32 -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim snap_ui32 -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $run -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "mig_ui32 XSim failed: $LASTEXITCODE" }
Select-String -Path (Join-Path $sim "xsim.log") -Pattern "MIG_UI32_" | ForEach-Object { $_.Line }
