// mig_ui32.sv — 32-bit fabric word <-> native MIG 128b UI.
// CANDIDATE. PROGRAM=NO. XSim != board. Not MIG_PASS / FEM_PERSIST_PASS.
// Completion = dest readback of the targeted 32-bit lane + txn/generation.
// FIFO-empty / app_rdy accept is not complete (PROXY_METRIC_FALSE_PASS_GUARD).
// APP_W=128 FACT from generated mig0. Byte addr[3:2] = lane; app_addr[3:0]=0.
`timescale 1ns/1ps

module mig_ui32 (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        calib_done,

  input  logic        mem_cmd_valid,
  output logic        mem_cmd_ready,
  input  logic        mem_cmd_write,
  input  logic [27:0] mem_addr,
  input  logic [31:0] mem_wdata,
  output logic        mem_resp_valid,
  input  logic        mem_resp_ready,
  output logic        mem_resp_err,
  output logic [31:0] mem_rdata,

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
  localparam logic [2:0] CMD_WR = 3'b000;
  localparam logic [2:0] CMD_RD = 3'b001;

  typedef enum logic [2:0] {
    S_IDLE, S_WR, S_RD, S_WAIT, S_HOLD, S_RSP
  } st_t;
  st_t st;

  logic        wr_r;
  logic [1:0]  lane_r;
  logic [27:0] beat_r;
  logic [31:0] wdata_r;
  logic [15:0] txn_r, gen_r;
  logic [15:0] out_r;
  logic        cmd_acc, wdf_acc;
  logic        tear_r;
  logic [31:0] rdata_r;
  logic        err_r;

  assign wr_outstanding = out_r;
  assign cmd_fifo_empty = force_fifo_empty | ((st == S_IDLE) && (out_r == 16'h0));
  assign mem_cmd_ready = (st == S_IDLE) && calib_done && rst_n;
  assign ui_busy = (st != S_IDLE);

  assign app_addr = beat_r;
  assign app_cmd = (st == S_WR) ? CMD_WR : CMD_RD;
  assign app_en = ((st == S_WR) && !cmd_acc) || (st == S_RD);
  assign app_wdf_wren = (st == S_WR) && !wdf_acc;
  assign app_wdf_end = app_wdf_wren;
  assign app_wdf_data = ({96'h0, wdata_r}) << (32 * lane_r);
  always_comb begin
    unique case (lane_r)
      2'd0: app_wdf_mask = 16'hFFF0;
      2'd1: app_wdf_mask = 16'hFF0F;
      2'd2: app_wdf_mask = 16'hF0FF;
      2'd3: app_wdf_mask = 16'h0FFF;
      default: app_wdf_mask = 16'hFFFF;
    endcase
  end

  assign mem_resp_valid = (st == S_RSP);
  assign mem_resp_err = err_r;
  assign mem_rdata = rdata_r;

  function automatic logic [31:0] extract32(input logic [127:0] beat, input logic [1:0] ln);
    extract32 = beat[32*ln +: 32];
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      out_r <= 16'h0;
      txn_r <= 16'h1;
      gen_r <= 16'h1;
      cmd_acc <= 1'b0;
      wdf_acc <= 1'b0;
      err_r <= 1'b0;
      rdata_r <= 32'h0;
      wr_r <= 1'b0;
      lane_r <= 2'h0;
      beat_r <= 28'h0;
      wdata_r <= 32'h0;
      tear_r <= 1'b0;
    end else begin
      unique case (st)
        S_IDLE: begin
          cmd_acc <= 1'b0;
          wdf_acc <= 1'b0;
          if (mem_cmd_valid && mem_cmd_ready) begin
            wr_r <= mem_cmd_write;
            lane_r <= mem_addr[3:2];
            beat_r <= {mem_addr[27:4], 4'b0000};
            wdata_r <= mem_wdata;
            tear_r <= inject_tear;
            if (mem_cmd_write) out_r <= out_r + 16'h1;
            st <= mem_cmd_write ? S_WR : S_RD;
          end
        end
        S_WR: begin
          if (app_en && app_rdy) cmd_acc <= 1'b1;
          if (app_wdf_wren && app_wdf_rdy) wdf_acc <= 1'b1;
          if ((cmd_acc || (app_en && app_rdy)) && (wdf_acc || (app_wdf_wren && app_wdf_rdy)))
            st <= S_RD;
        end
        S_RD: begin
          if (app_en && app_rdy) st <= S_WAIT;
        end
        S_WAIT: begin
          if (app_rd_data_valid) begin
            rdata_r <= extract32(app_rd_data, lane_r);
            if (wr_r) begin
              err_r <= (extract32(app_rd_data, lane_r) != wdata_r) || tear_r;
              st <= S_HOLD;
            end else begin
              err_r <= 1'b0;
              st <= S_RSP;
            end
          end
        end
        S_HOLD: begin
          // dest compare done; FIFO-empty must not complete while outstanding
          if (!(force_fifo_empty && (out_r != 16'h0))) begin
            if (out_r != 16'h0) out_r <= out_r - 16'h1;
            txn_r <= txn_r + 16'h1;
            st <= S_RSP;
          end
        end
        S_RSP: begin
          if (mem_resp_ready) st <= S_IDLE;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
