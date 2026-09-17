// pack_abi24_mig_dut.sv — AGENT_D. Pack/ABI-24 through pack_mig_bind dest-complete.
// Not Agent B gold. PROGRAM=NO. query_* fail-closed.
`timescale 1ns/1ps

module pack_abi24_mig_dut (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        debug_clear = 1'b0,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic [7:0]  query_status,
  output logic [7:0]  query_reason,
  output logic        query_valid,
  output logic        pack_quiescent
);
  logic        ui_busy, d_rd_end, calib_done;
  logic [15:0] wr_outstanding;
  logic [27:0] app_addr;
  logic [2:0]  app_cmd;
  logic        app_en, app_wdf_end, app_wdf_wren;
  logic [127:0] app_wdf_data, app_rd_data;
  logic [15:0] app_wdf_mask;
  logic        app_rd_data_valid, app_rdy, app_wdf_rdy;

  assign query_status = 8'h00;
  assign query_reason = 8'h00;
  assign query_valid = 1'b0;

  pack_mig_bind u_ld (
    .clk, .rst_n, .debug_clear, .calib_done,
    .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy, .pack_quiescent,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done, .stall(1'b0),
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_end(d_rd_end), .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );
endmodule
