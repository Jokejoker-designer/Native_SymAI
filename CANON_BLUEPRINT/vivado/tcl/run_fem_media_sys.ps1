param(
  [switch]$Synth
)
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
if (-not (Test-Path $Settings)) { throw "Vivado settings not found: $Settings" }

$mem = Join-Path $Root "rtl\native_ai\memory"
$tb  = Join-Path $Root "tb\learning\tb_fem_media_sys.v"
$sim = Join-Path $Root "tb\learning\build\fem_media_sys"
New-Item -ItemType Directory -Force -Path $sim | Out-Null

$runSim = @"
call `"$Settings`"
cd /d `"$sim`"
call xvlog `"$mem\fem_lifecycle.v`" `"$mem\fem_media_bridge.v`" `"$mem\fem_t2_adapter.v`" `"$mem\fem_t2_ce.v`" `"$mem\fem_media_sys.v`" `"$tb`"
if errorlevel 1 exit /b 1
call xelab tb_fem_media_sys -snapshot snap_ms -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim snap_ms -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $runSim -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "FEM media_sys XSim failed: $LASTEXITCODE" }
Select-String -Path (Join-Path $sim "xsim.log") -Pattern "FEM_MEDIA_SYS_" | ForEach-Object { $_.Line }

if ($Synth) {
  $tcl = Join-Path $Root "vivado\tcl\05_synth_arty_fabric.tcl"
  $out = "D:\FPGA\arty_d"
  New-Item -ItemType Directory -Force -Path $out | Out-Null
  $runSynth = @"
call `"$Settings`"
cd /d `"$out`"
call vivado -mode batch -source `"$tcl`" -log `"$out\vivado.log`" -journal `"$out\vivado.jou`"
if errorlevel 1 exit /b 1
"@
  $sbat = Join-Path $out "run_synth.bat"
  Set-Content -Path $sbat -Value $runSynth -Encoding ASCII
  cmd /c $sbat
  if ($LASTEXITCODE -ne 0) { throw "Arty fabric synth failed: $LASTEXITCODE" }
}
