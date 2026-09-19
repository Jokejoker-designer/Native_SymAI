from pathlib import Path

src = Path(
    r"D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"/CANON_BLUEPRINT/vivado/tcl"
)
bans = [
    "6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902",
    "8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375",
    "eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e",
]
keep = "*UART_R2_KEEP_U25_CANDIDATE*"
mapping = {
    "94_synth_uart_r2_u25.tcl": "94_synth_uart_r2_u29.tcl",
    "95_impl_uart_r2_u25.tcl": "95_impl_uart_r2_u29.tcl",
    "96_bit_uart_r2_u25.tcl": "96_bit_uart_r2_u29.tcl",
    "97_program_uart_r2_u25.tcl": "97_program_uart_r2_u29.tcl",
}
for a, b in mapping.items():
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("*uart_r2_u25_candidate*", keep)
    t = t.replace("build_u25", "build_u29")
    t = t.replace("uart_r2_u25", "uart_r2_u29")
    t = t.replace(keep, "*uart_r2_u25_candidate*")
    t = t.replace("[file join $r2 u25 pack_debug_clear.sv]", "[file join $r2 u29 pack_debug_clear.sv]")
    t = t.replace(
        "[file join $r2 u25 arty_a7_r2_top_m4_mig_candidate.sv]",
        "[file join $r2 u29 arty_a7_r2_top_m4_mig_candidate.sv]",
    )
    t = t.replace("pack_debug_clear_u25.sv", "pack_debug_clear_u29.sv")
    t = t.replace("U25_PROGRAMMED=FACT", "U29_PROGRAMMED=FACT")
    t = t.replace("CLASS=uart_r2_u25_CANDIDATE", "CLASS=uart_r2_u29_CANDIDATE")
    t = t.replace("CLEAR=UART_R2/u25/pack_debug_clear.sv", "CLEAR=UART_R2/u29/pack_debug_clear.sv")
    if "NOT_UART_R2_U28=YES" not in t and 'puts $pfh "NOT_UART_R2_U24=YES"' in t:
        t = t.replace(
            'puts $pfh "NOT_UART_R2_U24=YES"',
            'puts $pfh "NOT_UART_R2_U24=YES"\nputs $pfh "NOT_UART_R2_U25=YES"\nputs $pfh "NOT_UART_R2_U26=YES"\nputs $pfh "NOT_UART_R2_U27=YES"\nputs $pfh "NOT_UART_R2_U28=YES"',
        )
    if b.startswith("97"):
        extra = "".join(f"  {h}\n" for h in bans)
        t = t.replace(
            "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n}",
            "  1cb7dad768bdca96f8a04bd88b85e3684c44ca528760b3c6126dbab023087b6a\n"
            + extra + "}",
        )
    for old, new in [
        ("*uart_r2_u24_candidate* $bitn_fwd]} {",
         "*uart_r2_u24_candidate* $bitn_fwd] || [string match *uart_r2_u25_candidate* $bitn_fwd] || [string match *uart_r2_u26_candidate* $bitn_fwd] || [string match *uart_r2_u27_candidate* $bitn_fwd] || [string match *uart_r2_u28_candidate* $bitn_fwd]} {"),
        ("*uart_r2_u24_candidate* $bitfile]} {",
         "*uart_r2_u24_candidate* $bitfile] || [string match *uart_r2_u25_candidate* $bitfile] || [string match *uart_r2_u26_candidate* $bitfile] || [string match *uart_r2_u27_candidate* $bitfile] || [string match *uart_r2_u28_candidate* $bitfile]} {"),
    ]:
        t = t.replace(old, new)
    (src / b).write_text(t, encoding="utf-8", newline="\n")
    print("wrote", b)
