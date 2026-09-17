call "C:\2026.1\Vivado\settings64.bat"
cd /d "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\build_mig_ui32"
call xvlog -sv "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\rtl\native_ai\memory\mig_ui32.sv" "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\mig_ui_model.sv" "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\tb_mig_ui32.sv"
if errorlevel 1 exit /b 1
call xelab tb_mig_ui32 -snapshot snap_ui32 -timescale 1ns/1ps
if errorlevel 1 exit /b 1
echo run -all> "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\build_mig_ui32\run_all.tcl"
echo exit>> "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\build_mig_ui32\run_all.tcl"
call xsim snap_ui32 -tclbatch run_all.tcl -log "D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\tb\native_ai\memory\build_mig_ui32\xsim.log"
if errorlevel 1 exit /b 1
