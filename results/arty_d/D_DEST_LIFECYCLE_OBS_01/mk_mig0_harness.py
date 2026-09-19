from pathlib import Path

src = Path(r"D:\FPGA\arty_d\UART_R2\u32\pack_uart_dualclk_harness.sv").read_text(
    encoding="utf-8"
)
src = src.replace("module pack_uart_dualclk_harness", "module pack_uart_mig0_harness")
src = src.replace(
    "Dest is mig_ui_bram, not generated mig0.",
    "Dest is generated mig0 (external app_*). Not BRAM.",
)
old_ports = """  input  logic        dest_stall = 1'b0
);"""
new_ports = """  input  logic        calib_done,
  output logic [27:0]  dest_app_addr,
  output logic [2:0]   dest_app_cmd,
  output logic         dest_app_en,
  output logic [127:0] dest_app_wdf_data,
  output logic         dest_app_wdf_end,
  output logic [15:0]  dest_app_wdf_mask,
  output logic         dest_app_wdf_wren,
  input  logic [127:0] dest_app_rd_data,
  input  logic         dest_app_rd_data_valid,
  input  logic         dest_app_rdy,
  input  logic         dest_app_wdf_rdy
);"""
if old_ports not in src:
    raise SystemExit("ports not found")
src = src.replace(old_ports, new_ports)
src = src.replace("  logic calib_ui;\n\n", "  wire calib_ui = calib_done;\n\n")
old_bram = """  mig_ui_bram u_dest (
    .clk(ui_clk), .rst_n(rst_ui_n), .calib_done(calib_ui), .stall(dest_stall),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdata), .app_wdf_end(d_end), .app_wdf_mask(d_mask), .app_wdf_wren(d_wren),
    .app_rd_data(d_rdata), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rdv),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );"""
new_bram = """  assign dest_app_addr     = d_addr;
  assign dest_app_cmd      = d_cmd;
  assign dest_app_en       = d_en;
  assign dest_app_wdf_data = d_wdata;
  assign dest_app_wdf_end  = d_end;
  assign dest_app_wdf_mask = d_mask;
  assign dest_app_wdf_wren = d_wren;
  assign d_rdata = dest_app_rd_data;
  assign d_rdv   = dest_app_rd_data_valid;
  assign d_rdy   = dest_app_rdy;
  assign d_wdf_rdy = dest_app_wdf_rdy;
  assign d_rd_end = 1'b0;"""
if old_bram not in src:
    raise SystemExit("bram block not found")
src = src.replace(old_bram, new_bram)
out = Path(r"D:\FPGA\arty_d\D_DEST_LIFECYCLE_OBS_01\pack_uart_mig0_harness.sv")
out.write_text(src, encoding="utf-8")
print("wrote", out, out.stat().st_size)
print("mig_ui_bram leftover", "mig_ui_bram" in src)
