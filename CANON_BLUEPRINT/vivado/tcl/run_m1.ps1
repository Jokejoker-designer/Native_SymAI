param(
  [switch]$Ooc
)
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$VivadoBat = "C:\2026.1\Vivado\bin\vivado.bat"
$Settings = "C:\2026.1\Vivado\settings64.bat"
if (-not (Test-Path $VivadoBat)) { throw "Vivado not found: $VivadoBat" }

Set-Location $Root
python (Join-Path $Root "python\m1\pack_vectors.py")

$vec = Join-Path $Root "tb\native_ai\loader\vectors"
$sim = Join-Path $Root "vivado\m1_pack_loader\xsim"
New-Item -ItemType Directory -Force -Path $sim | Out-Null

$crc = Join-Path $Root "rtl\native_ai\common\crc32_iso_hdlc.sv"
$dut = Join-Path $Root "rtl\native_ai\loader\pack_loader.sv"
$tb  = Join-Path $Root "tb\native_ai\loader\tb_pack_loader.sv"

$runSim = @"
call `"$Settings`"
cd /d `"$sim`"
copy /Y `"$vec\*.mem`" `"$sim\`" >nul
call xvlog -sv `"$crc`" `"$dut`" `"$tb`"
if errorlevel 1 exit /b 1
call xelab tb_pack_loader -snapshot tb_pack_loader_snap -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim tb_pack_loader_snap -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $runSim -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "XSim failed: $LASTEXITCODE" }

if ($Ooc) {
  & $VivadoBat -mode batch -source (Join-Path $Root "vivado\tcl\02_ooc_synth_pack_loader.tcl") -nojournal -log (Join-Path $Root "vivado\m1_pack_loader\ooc_batch.log")
}
