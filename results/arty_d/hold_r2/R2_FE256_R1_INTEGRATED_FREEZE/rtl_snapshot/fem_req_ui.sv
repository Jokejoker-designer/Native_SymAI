// fem_req_ui.sv — FEM 4-bit word port -> mig_ui32 at FEM_BASE.
// CANDIDATE. PROGRAM=NO. XSim != board. Not FEM_PERSIST_PASS / MIG_PASS.
// Address: FEM_BASE + {req_addr, 2'b00}. Lane = byte[3:2] = req_addr[1:0].
// Completion = dest readback (mig_ui32) + echoed txn/generation.
// FIFO-empty is not complete (PROXY_METRIC_FALSE_PASS_GUARD).
`timescale 1ns/1ps

module fem_req_ui #(
  parameter logic [27:0] FEM_BASE = 28'h0200000
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        calib_done,

  input  logic        req_valid,
  output logic        req_ready,
  input  logic        req_write,
  input  logic [3:0]  req_addr,
  input  logic [31:0] req_wdata,
  input  logic [15:0] req_txn,
  input  logic [15:0] req_gen,
  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic [31:0] rsp_rdata,
  output logic [15:0] rsp_txn,
  output logic [15:0] rsp_gen,
  output logic        rsp_err,

  output logic [15:0] wr_outstanding,
  output logic        cmd_fifo_empty,
  input  logic        force_fifo_empty,
  input  logic        inject_tear,
  output logic        ui_busy,

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
  logic        mem_cmd_valid, mem_cmd_ready, mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic        mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [15:0] txn_r, gen_r;

  assign mem_cmd_valid = req_valid;
  assign req_ready = mem_cmd_ready;
  assign mem_cmd_write = req_write;
  assign mem_addr = FEM_BASE + {22'h0, req_addr, 2'b00};
  assign mem_wdata = req_wdata;
  assign mem_resp_ready = rsp_ready;
  assign rsp_valid = mem_resp_valid;
  assign rsp_rdata = mem_rdata;
  assign rsp_err = mem_resp_err;
  assign rsp_txn = txn_r;
  assign rsp_gen = gen_r;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      txn_r <= 16'h0;
      gen_r <= 16'h0;
    end else if (req_valid && req_ready) begin
      txn_r <= req_txn;
      gen_r <= req_gen;
    end
  end

  mig_ui32 u_ui (
    .clk, .rst_n, .calib_done,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .wr_outstanding, .cmd_fifo_empty, .force_fifo_empty, .inject_tear, .ui_busy,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );
endmodule
