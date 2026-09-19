from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
u22_sha = "ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9"
fcapz_inject = r'''
set fcapz [file join $r2 u23 fpgacapZero rtl]
add_files [file join $fcapz fcapz_version.vh]
set_property file_type {Verilog Header} [get_files *fcapz_version.vh]
set_property is_global_include true [get_files *fcapz_version.vh]
read_verilog [file join $fcapz reset_sync.v]
read_verilog [file join $fcapz dpram.v]
read_verilog [file join $fcapz trig_compare.v]
read_verilog [file join $fcapz jtag_reg_iface.v]
read_verilog [file join $fcapz jtag_pipe_iface.v]
read_verilog [file join $fcapz jtag_burst_read.v]
read_verilog [file join $fcapz jtag_tap/jtag_tap_xilinx7.v]
read_verilog [file join $fcapz fcapz_ela.v]
read_verilog [file join $fcapz fcapz_ela_xilinx7.v]
'''

for a, b in {
    "94_synth_uart_r2_u22.tcl": "94_synth_uart_r2_u23.tcl",
    "95_impl_uart_r2_u22.tcl": "95_impl_uart_r2_u23.tcl",
    "96_bit_uart_r2_u22.tcl": "96_bit_uart_r2_u23.tcl",
    "97_program_uart_r2_u22.tcl": "97_program_uart_r2_u23.tcl",
}.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("*uart_r2_u22_candidate*", "*UART_R2_KEEP_U22_NAME*")
    t = t.replace("build_u22", "build_u23")
    t = t.replace("uart_r2_u22", "uart_r2_u23")
    t = t.replace("*UART_R2_KEEP_U22_NAME*", "*uart_r2_u22_candidate*")
    t = t.replace("[file join $r2 u22 pack_debug_clear.sv]", "[file join $r2 u23 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u22 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u23 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u22.sv", "pack_debug_clear_u23.sv")
    t = t.replace("U22_PROGRAMMED=FACT", "U23_PROGRAMMED=FACT")
    t = t.replace("CLEAR=UART_R2/u22/pack_debug_clear.sv", "CLEAR=UART_R2/u23/pack_debug_clear.sv")
    t = t.replace("CLASS=uart_r2_u23_CANDIDATE", "CLASS=uart_r2_u23_FCAPZ_CANDIDATE")
    if 'puts $pfh "NOT_UART_R2_U22=YES"' not in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U21=YES"',
            'puts $pfh "NOT_UART_R2_U21=YES"\nputs $pfh "NOT_UART_R2_U22=YES"',
        )
    if u22_sha not in t and b.startswith("97"):
        t = t.replace(
            "  09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9\n}",
            "  09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9\n"
            f"  {u22_sha}\n}}",
        )
    if "*uart_r2_u22_candidate*" not in t:
        t = t.replace(
            "*uart_r2_u21_candidate* $bitn_fwd]} {",
            "*uart_r2_u21_candidate* $bitn_fwd] || [string match *uart_r2_u22_candidate* $bitn_fwd]} {",
        )
        t = t.replace(
            "*uart_r2_u21_candidate* $bitfile]",
            "*uart_r2_u21_candidate* $bitfile] || [string match *uart_r2_u22_candidate* $bitfile]",
        )
    if b.startswith("94"):
        t = t.replace(
            "read_verilog -sv [file join $r2 u23 pack_debug_clear.sv]",
            fcapz_inject.strip() + "\nread_verilog -sv [file join $r2 u23 pack_debug_clear.sv]",
        )
        t = t.replace(
            "synth_design -top arty_a7_r2_top_m4_mig_candidate -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt\nwrite_checkpoint",
            "synth_design -top arty_a7_r2_top_m4_mig_candidate -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt\n"
            "catch {read_xdc [file join $r2 u23 fcapz_bscan.xdc]}\n"
            "write_checkpoint",
        )
        t = t.replace('puts $fh "CDC=PACKAGE_word_cdc32"',
                      'puts $fh "CDC=PACKAGE_word_cdc32"\nputs $fh "ELA=fcapz_ela_xilinx7_SAMPLE64_DEPTH1024"')
    if b.startswith("95"):
        t = t.replace(
            "read_xdc $xdc_clr\nopt_design",
            "read_xdc $xdc_clr\n"
            "catch {read_xdc {D:/FPGA/arty_d/UART_R2/u23/fcapz_bscan.xdc}}\n"
            "opt_design",
        )
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)
