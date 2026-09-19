from pathlib import Path

pkg = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT"
)
r2 = Path(r"D:\FPGA\arty_d\UART_R2")
u17 = r2 / "u17"
u17.mkdir(exist_ok=True)

top = (pkg / "rtl/native_ai/board/arty_a7_r2_top_m4_mig_candidate.sv").read_text(
    encoding="utf-8"
)
old_decl = '  (* DIRECT_RESET = "yes" *) logic rst100_pack_n, rst_ui_pack_n;'
new_decl = (
    '  (* DIRECT_RESET = "yes" *) logic rst100_pack_n, rst_ui_pack_n, rst100_tx_b_n;'
)
if old_decl not in top:
    raise SystemExit("decl not found")
top = top.replace(old_decl, new_decl, 1)
old_ff = """  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      rst100_pack_n <= 1'b0;
    else
      rst100_pack_n <= ~cdc_rst_100;
  end"""
new_ff = (
    old_ff
    + """
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      rst100_tx_b_n <= 1'b0;
    else
      rst100_tx_b_n <= ~clr_ui_req;
  end"""
)
if old_ff not in top:
    raise SystemExit("ff not found")
top = top.replace(old_ff, new_ff, 1)
old_cdc = """  word_cdc32 u_cdc_tx (
    .a_clk(ui_clk), .a_rst_n(rst_ui_pack_n),
    .a_valid(st_valid_ui), .a_ready(st_ready_ui), .a_data(st_data_ui),
    .b_clk(clk100), .b_rst_n(rst100_pack_n),
    .b_valid(st_valid_100), .b_ready(st_ready_100), .b_data(st_data_100),
    .a_idle(tx_a_idle), .b_idle(tx_b_idle)
  );"""
new_cdc = old_cdc.replace(".b_rst_n(rst100_pack_n),", ".b_rst_n(rst100_tx_b_n),")
if old_cdc not in top:
    raise SystemExit("cdc not found")
top = top.replace(old_cdc, new_cdc, 1)
top = (
    "// UART_R2_U17 overlay. PACKAGE live top NOT overwritten.\n"
    "// TX CDC B rst = ~clr_ui_req. CLEAR=U8 flush. RX=U11 TX=U14. CANDIDATE.\n"
    + top
)
(u17 / "arty_a7_r2_top_m4_mig_candidate.sv").write_text(top, encoding="utf-8")
print("top overlay", len(top))

h = (pkg / "tb/native_ai/board/pack_uart_dualclk_harness.sv").read_text(encoding="utf-8")
h_old_decl = '  (* DIRECT_RESET = "yes" *) logic rst100_pack_n, rst_ui_pack_n;'
h_new_decl = '  (* DIRECT_RESET = "yes" *) logic rst100_pack_n, rst_ui_pack_n, rst100_tx_b_n;'
if h_old_decl not in h:
    raise SystemExit("h decl not found")
h = h.replace(h_old_decl, h_new_decl, 1)
h_old_ff = """  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      rst100_pack_n <= 1'b0;
    else
      rst100_pack_n <= ~cdc_rst_100;
  end"""
h_new_ff = (
    h_old_ff
    + """
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      rst100_tx_b_n <= 1'b0;
    else
      rst100_tx_b_n <= ~clr_ui_req;
  end"""
)
if h_old_ff not in h:
    raise SystemExit("h ff not found")
h = h.replace(h_old_ff, h_new_ff, 1)
h_old_cdc = """  word_cdc32 u_cdc_tx (
    .a_clk(ui_clk), .a_rst_n(rst_ui_pack_n),
    .a_valid(st_valid_ui), .a_ready(st_ready_ui), .a_data(st_data_ui),
    .b_clk(clk100), .b_rst_n(rst100_pack_n),
    .b_valid(st_valid_100), .b_ready(st_ready_100), .b_data(st_data_100),
    .a_idle(tx_a_idle), .b_idle(tx_b_idle)
  );"""
h_new_cdc = h_old_cdc.replace(".b_rst_n(rst100_pack_n),", ".b_rst_n(rst100_tx_b_n),")
if h_old_cdc not in h:
    raise SystemExit("h cdc not found")
h = h.replace(h_old_cdc, h_new_cdc, 1)
h = (
    "// UART_R2_U17 harness overlay. Dest still mig_ui_bram. TX CDC B ~clr_ui_req.\n"
    + h
)
(u17 / "pack_uart_dualclk_harness.sv").write_text(h, encoding="utf-8")
print("harness overlay", len(h))

src = pkg / "vivado/tcl"
pairs = [
    ("90_synth_uart_r2_u16.tcl", "94_synth_uart_r2_u17.tcl"),
    ("91_impl_uart_r2_u16.tcl", "95_impl_uart_r2_u17.tcl"),
    ("92_bit_uart_r2_u16.tcl", "96_bit_uart_r2_u17.tcl"),
    ("93_program_uart_r2_u16.tcl", "97_program_uart_r2_u17.tcl"),
]
for a, b in pairs:
    t = (src / a).read_text(encoding="utf-8")
    t = t.replace("build_u16", "build_u17")
    t = t.replace("uart_r2_u16", "uart_r2_u17")
    t = t.replace("UART_R2_U16", "UART_R2_U17")
    t = t.replace("pack_debug_clear_u16", "pack_debug_clear_u17")
    t = t.replace("UART_R2/u16/pack_debug_clear.sv", "UART_R2/u17/pack_debug_clear.sv")
    t = t.replace("u16 pack_debug_clear", "u17 pack_debug_clear")
    t = t.replace(
        "file join $r2 u16 pack_debug_clear.sv",
        "file join $r2 u17 pack_debug_clear.sv",
    )
    t = t.replace(
        "file join $rtl board arty_a7_r2_top_m4_mig_candidate.sv",
        "file join $r2 u17 arty_a7_r2_top_m4_mig_candidate.sv",
    )
    t = t.replace(
        "bc457238db3696ce038ed5fe0f117acb7f73ad5fc6b637a63e9b8ae46325b20b",
        "bc457238db3696ce038ed5fe0f117acb7f73ad5fc6b637a63e9b8ae46325b20b\n"
        "  e32a64e74602d35e470e8b6efca8b1f0fdf70b24ea981fb4ed5b3e6f5f896a45",
    )
    t = t.replace(
        "[string match *uart_r2_u15_candidate* $bitn_fwd]}",
        "[string match *uart_r2_u15_candidate* $bitn_fwd] || "
        "[string match *uart_r2_u16_candidate* $bitn_fwd]}",
    )
    t = t.replace(
        "[string match *uart_r2_u15_candidate* $bitfile]",
        "[string match *uart_r2_u15_candidate* $bitfile] || "
        "[string match *uart_r2_u16_candidate* $bitfile]",
    )
    t = t.replace(
        'puts $pfh "NOT_UART_R2_U15=YES"',
        'puts $pfh "NOT_UART_R2_U15=YES"\nputs $pfh "NOT_UART_R2_U16=YES"',
    )
    t = t.replace("U16_PROGRAMMED=FACT", "U17_PROGRAMMED=FACT")
    (src / b).write_text(t, encoding="utf-8")
    print("wrote", b)

c = (r2 / "u16/u16_campaign.py").read_text(encoding="utf-8")
c = c.replace("U16", "U17")
c = c.replace("u16", "u17")
c = c.replace("PACK24_U16", "PACK24_U17")
(u17 / "u17_campaign.py").write_text(c, encoding="utf-8")
print("campaign", [ln for ln in c.splitlines() if ln.startswith("BIT")][0])
