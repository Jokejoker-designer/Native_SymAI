param()
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
if (-not (Test-Path $Settings)) { throw "Vivado settings not found: $Settings" }

$out = "D:\FPGA\arty_d"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$ooc = Join-Path $Root "vivado\tcl\06_ooc_fem_media_sys.tcl"
$fab = Join-Path $Root "vivado\tcl\05_synth_arty_fabric.tcl"

$run = @"
call `"$Settings`"
cd /d `"$out`"
echo ===== OOC fem_media_sys =====
call vivado -mode batch -source `"$ooc`" -log `"$out\ooc.log`" -journal `"$out\ooc.jou`"
if errorlevel 1 exit /b 1
echo ===== FABRIC arty_a7_r2_top =====
call vivado -mode batch -source `"$fab`" -log `"$out\vivado.log`" -journal `"$out\vivado.jou`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $out "run_synth.bat"
Set-Content -Path $bat -Value $run -Encoding ASCII
cmd /c $bat
# Fabric-only retry helper: skip OOC when ooc.log already has OOC_FEM_MEDIA_SYS_DONE
if ($LASTEXITCODE -ne 0) { throw "synth failed: $LASTEXITCODE" }
