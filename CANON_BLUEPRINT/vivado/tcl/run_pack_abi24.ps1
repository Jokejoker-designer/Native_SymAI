param(
  [switch]$Ooc
)
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
$VivadoBat = "C:\2026.1\Vivado\bin\vivado.bat"
if (-not (Test-Path $Settings)) { throw "Vivado settings not found: $Settings" }

$abi = Join-Path $Root "verification\pack_abi24"
$sim = Join-Path $Root "vivado\pack_abi24\xsim"
New-Item -ItemType Directory -Force -Path $sim | Out-Null

$crc = Join-Path $Root "rtl\native_ai\common\crc32_iso_hdlc.sv"
$dut = Join-Path $Root "rtl\native_ai\loader\pack_loader.sv"
$wrap = Join-Path $abi "pack_abi24_dut.sv"
$tb  = Join-Path $abi "tb_pack_abi24_xsim_compare.sv"

$runSim = @"
call `"$Settings`"
cd /d `"$sim`"
if not exist `"$sim\out`" mkdir `"$sim\out`"
copy /Y `"$abi\out\*.mem`" `"$sim\out\`" >nul
copy /Y `"$abi\*.svh`" `"$sim\`" >nul
call xvlog -sv -i `"$abi`" `"$crc`" `"$dut`" `"$wrap`" `"$tb`"
if errorlevel 1 exit /b 1
call xelab tb_pack_abi24_xsim_compare -snapshot tb_pack_abi24_snap -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim tb_pack_abi24_snap -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $runSim -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "Pack/ABI-24 XSim failed: $LASTEXITCODE" }

if ($Ooc) {
  & $VivadoBat -mode batch -source (Join-Path $Root "vivado\tcl\02_ooc_synth_pack_loader.tcl") -nojournal -log (Join-Path $Root "vivado\m1_pack_loader\ooc_batch.log")
}
