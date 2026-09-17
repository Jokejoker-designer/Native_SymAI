param(
  [switch]$Ooc
)
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Settings = "C:\2026.1\Vivado\settings64.bat"
if (-not (Test-Path $Settings)) { throw "Vivado settings not found: $Settings" }

$dir = Join-Path $Root "rtl\native_ai\directory"
$tb  = Join-Path $Root "tb\native_ai\directory\tb_bounded_walk.sv"
$sim = Join-Path $Root "vivado\m3_walk\xsim"
New-Item -ItemType Directory -Force -Path $sim | Out-Null

$runSim = @"
call `"$Settings`"
cd /d `"$sim`"
copy /Y `"$dir\dir_a.mem`" `"$sim\`" >nul
copy /Y `"$dir\post_a.mem`" `"$sim\`" >nul
copy /Y `"$dir\post_expect.hex`" `"$sim\`" >nul
call xvlog -sv `"$dir\exact_directory.sv`" `"$dir\posting_walk.sv`" `"$dir\bounded_walk.sv`" `"$tb`"
if errorlevel 1 exit /b 1
call xelab tb_bounded_walk -snapshot tb_m3_walk_snap -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> `"$sim\run_all.tcl`"
echo exit>> `"$sim\run_all.tcl`"
call xsim tb_m3_walk_snap -tclbatch run_all.tcl -log `"$sim\xsim.log`"
if errorlevel 1 exit /b 1
"@
$bat = Join-Path $sim "run_xsim.bat"
Set-Content -Path $bat -Value $runSim -Encoding ASCII
cmd /c $bat
if ($LASTEXITCODE -ne 0) { throw "M3 walk XSim failed: $LASTEXITCODE" }
