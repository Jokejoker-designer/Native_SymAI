// UART_R2_U26 pack_mig_bind overlay. Do not patch PACKAGE live bind or frozen U25.
// U25 FAIL_BOARD: p4 GOLD + p5 r0/r1 GOLD then r2 V-04 n=0 after CLEAR ACK.
// debug_clear resets pack_loader only. mig_ui32 stays on rst_n so generated
// mig0 UI handshake is not dropped. dest payload still not cleared. CANDIDATE.
// Not MIG_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module pack_mig_bind (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        debug_clear = 1'b0,
  input  logic        calib_done,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic [15:0] wr_outstanding,
  input  logic        force_fifo_empty,
  output logic        ui_busy,
  output logic        pack_quiescent,
  output logic [27:0] app_addr,
  output logic [2:0]  app_cmd,
  output logic        app_en,
  output logic [127:0] app_wdf_data,
  output logic        app_wdf_end,
  output logic [15:0] app_wdf_mask,
  output logic        app_wdf_wren,
  input  logic [127:0] app_rd_data,
  input  logic        app_rd_data_valid,
  input  logic        app_rdy,
  input  logic        app_wdf_rdy
);
  logic mem_cmd_valid, mem_cmd_ready, mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [15:0] ui_out;
  logic fifo_empty;
  logic loader_busy;
  // VALIDATION_CLEAR != GLOBAL_RESET / MIG_RESET. dest BRAM/DDR payload not cleared.
  (* DIRECT_RESET = "yes" *) logic rst_ld;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rst_ld <= 1'b0;
    else
      rst_ld <= ~debug_clear;
  end

  pack_loader u_ld (
    .clk, .rst_n(rst_ld),
    .s_valid, .s_ready, .s_data,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .loader_busy
  );

  mig_ui32 u_ui (
    .clk, .rst_n(rst_n), .calib_done,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .wr_outstanding(ui_out), .cmd_fifo_empty(fifo_empty),
    .force_fifo_empty(force_fifo_empty), .inject_tear(1'b0),
    .ui_busy,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  assign pack_quiescent = !loader_busy && !ui_busy && (wr_outstanding == 16'h0) && (ui_out == 16'h0);
endmodule
