param()
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
$sim = Join-Path $Root "tb\native_ai\loader\build_pack_mig"
$vec = Join-Path $Root "tb\native_ai\loader\vectors"
New-Item -ItemType Directory -Force -Path $sim | Out-Null
$rtl = Join-Path $Root "rtl\native_ai"
$tb  = Join-Path $Root "tb\native_ai\loader"
$run = @"
call `"$Settings`"
cd /d `"$sim`"
copy /Y `"$vec\*.mem`" `"$sim\`" >nul
call xvlog -sv `"$rtl\common\crc32_iso_hdlc.sv`" `"$rtl\loader\pack_loader.sv`" `"$rtl\memory\mig_ui32.sv`" `"$rtl\memory\pack_mig_bind.sv`" `"$rtl\memory\mig_ui_bram.sv`" `"$tb\tb_pack_mig.sv`"
if errorlevel 1 exit /b 1
call xelab tb_pack_mig -snapshot snap_pack_mig -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim snap_pack_mig -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $run -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "pack_mig XSim failed: $LASTEXITCODE" }
Select-String -Path (Join-Path $sim "xsim.log") -Pattern "PACK_MIG_UI32_|PASS V|FAIL" | ForEach-Object { $_.Line }
