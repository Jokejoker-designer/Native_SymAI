param(
  [switch]$Ooc
)
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
if (-not (Test-Path $Settings)) { throw "Vivado settings not found: $Settings" }

$fe = Join-Path $Root "verification\fe256"
$rtl = Join-Path $Root "rtl\native_ai\fe256"
$sim = Join-Path $Root "vivado\fe256\xsim"
New-Item -ItemType Directory -Force -Path (Join-Path $sim "out") | Out-Null

$dut = Join-Path $rtl "fe256_query_path.sv"
$tb  = Join-Path $fe "tb_fe256_xsim_compare.sv"
$inc = $fe

$runSim = @"
call `"$Settings`"
cd /d `"$sim`"
copy /Y `"$fe\out\fe256_queries.hex`" `"$sim\`" >nul
copy /Y `"$fe\out\fe256_gold_results.hex`" `"$sim\`" >nul
copy /Y `"$fe\out\fe256_queries.hex`" `"$sim\out\`" >nul
copy /Y `"$fe\out\fe256_gold_results.hex`" `"$sim\out\`" >nul
copy /Y `"$fe\fe256_abi_constants.svh`" `"$sim\`" >nul
copy /Y `"$rtl\fe256_store.mem`" `"$sim\`" >nul
call xvlog -sv -i `"$inc`" `"$dut`" `"$tb`"
if errorlevel 1 exit /b 1
call xelab tb_fe256_xsim_compare -snapshot tb_fe256_snap -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim tb_fe256_snap -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $runSim -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "FE256 XSim failed: $LASTEXITCODE" }
