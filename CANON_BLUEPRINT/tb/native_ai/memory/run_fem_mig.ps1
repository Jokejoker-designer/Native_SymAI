param()
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
$sim = Join-Path $Root "tb\native_ai\memory\build_fem_mig"
New-Item -ItemType Directory -Force -Path $sim | Out-Null
$rtl = Join-Path $Root "rtl\native_ai"
$tb  = Join-Path $Root "tb\native_ai\memory"
$run = @"
call `"$Settings`"
cd /d `"$sim`"
call xvlog -sv `"$rtl\common\crc32_iso_hdlc.sv`" `"$rtl\loader\pack_loader.sv`" `"$rtl\memory\mig_ui32.sv`" `"$rtl\memory\pack_mig_bind.sv`" `"$rtl\memory\mig_ui_bram.sv`" `"$rtl\memory\mig_ui_mux.sv`" `"$rtl\memory\fem_req_ui.sv`" `"$rtl\memory\fem_on_mig.sv`" `"$tb\tb_fem_mig.sv`"
if errorlevel 1 exit /b 1
call xvlog `"$rtl\memory\fem_lifecycle.v`" `"$rtl\memory\fem_t2_adapter.v`" `"$rtl\memory\fem_t2_ce.v`"
if errorlevel 1 exit /b 1
call xelab tb_fem_mig -snapshot snap_fem_mig -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim snap_fem_mig -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $run -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "fem_mig XSim failed: $LASTEXITCODE" }
Select-String -Path (Join-Path $sim "xsim.log") -Pattern "FEM_MIG_UI32_|FAIL" | ForEach-Object { $_.Line }
