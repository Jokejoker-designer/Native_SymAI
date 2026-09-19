// pack_debug_clear.sv — UART_R2_U15. U8 MAG overlap + flush through S_REQ.
// Board U14: GOLD then CLEAR raw 00000000||ACK. TX CDC A (UI) resets on
// debug_clear while B (100) still live; req_a 1→0 is sampled as a new word
// with hold=0. uart_flush was only S_CDC|S_QUIET, so TX accepted the 0-word
// during S_REQ before ACK.
// U15: uart_flush includes S_REQ (TX w_ready=0 before debug_clear) and
// cdc_rst includes S_REQ (TX CDC B resets before A req drop).
// Does not edit frozen u8. MAG overlap S_DROP still excluded. CANDIDATE.
`timescale 1ns/1ps

module pack_debug_clear (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        in_valid,
  input  logic [31:0] in_data,
  output logic        take,
  output logic        hold,
  output logic        uart_flush,
  output logic        cdc_rst_100,
  output logic        ui_req,
  input  logic        ui_ack,
  input  logic        ui_nack,
  input  logic        pack_quiescent,
  input  logic        uart_rx_mark = 1'b1,
  output logic        ack_valid,
  input  logic        ack_ready,
  output logic [31:0] ack_data
);
  localparam logic [31:0] CMD  = 32'h44524743;
  localparam logic [31:0] ACK  = 32'hC1EA50A5;
  localparam logic [31:0] BUSY = 32'hC1EA50B5;
  localparam logic [31:0] ERR  = 32'hC1EA50E5;
  localparam int SAMPLE_N = 8;
  localparam int CDC_N    = 4;
  localparam int QUIET_N  = 20000;
  localparam int TO_N     = 65535;

  typedef enum logic [3:0] {
    S_IDLE, S_SAMPLE, S_REQ, S_CDC, S_QUIET, S_ACK, S_BUSY, S_ERR, S_DROP, S_DROP_B
  } st_t;
  st_t st;
  logic [15:0] cnt, wall;
  logic [31:0] reply;
  logic ui_req_r;

  assign take = (st == S_IDLE) && in_valid && (in_data == CMD);
  assign hold = (st != S_IDLE);
  assign ack_data = reply;
  assign ack_valid = (st == S_ACK) || (st == S_BUSY) || (st == S_ERR);
  assign ui_req = ui_req_r;
  (* DIRECT_RESET = "yes" *) logic cdc_rst_r;
  logic flush_r;

  assign uart_flush = flush_r;
  assign cdc_rst_100 = cdc_rst_r;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ui_req_r <= 1'b0;
      cdc_rst_r <= 1'b0;
      flush_r <= 1'b0;
    end else begin
      ui_req_r <= (st == S_REQ) || (st == S_CDC) || (st == S_QUIET) || (st == S_ACK);
      cdc_rst_r <= (st == S_REQ) || (st == S_CDC) || (st == S_QUIET) || (st == S_ACK);
      flush_r <= (st == S_REQ) || (st == S_CDC) || (st == S_QUIET);
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      cnt <= 16'h0;
      wall <= 16'h0;
      reply <= ACK;
    end else begin
      unique case (st)
        S_IDLE: begin
          cnt <= 16'h0;
          wall <= 16'h0;
          reply <= ACK;
          if (take)
            st <= S_SAMPLE;
        end
        S_SAMPLE: begin
          cnt <= cnt + 16'h1;
          if (cnt == SAMPLE_N[15:0] - 16'h1) begin
            cnt <= 16'h0;
            if (!pack_quiescent) begin
              reply <= BUSY;
              st <= S_BUSY;
            end else
              st <= S_REQ;
          end
        end
        S_REQ: begin
          cnt <= cnt + 16'h1;
          if (ui_nack) begin
            cnt <= 16'h0;
            reply <= BUSY;
            st <= S_BUSY;
          end else if (ui_ack) begin
            cnt <= 16'h0;
            st <= S_CDC;
          end else if (cnt == TO_N[15:0]) begin
            cnt <= 16'h0;
            reply <= ERR;
            st <= S_ERR;
          end
        end
        S_CDC: begin
          cnt <= cnt + 16'h1;
          wall <= 16'h0;
          if (cnt == CDC_N[15:0] - 16'h1) begin
            cnt <= 16'h0;
            st <= S_QUIET;
          end
        end
        S_QUIET: begin
          wall <= wall + 16'h1;
          if (uart_rx_mark)
            cnt <= cnt + 16'h1;
          else
            cnt <= 16'h0;
          reply <= ACK;
          if ((uart_rx_mark && (cnt == QUIET_N[15:0] - 16'h1)) ||
              (wall == TO_N[15:0])) begin
            cnt <= 16'h0;
            wall <= 16'h0;
            st <= S_ACK;
          end
        end
        S_ACK: begin
          reply <= ACK;
          if (ack_ready)
            st <= S_DROP;
        end
        S_BUSY: begin
          reply <= BUSY;
          if (ack_ready)
            st <= S_DROP_B;
        end
        S_ERR: begin
          reply <= ERR;
          if (ack_ready)
            st <= S_DROP;
        end
        S_DROP: begin
          cnt <= cnt + 16'h1;
          if ((!ui_ack && !ui_nack) || (cnt == TO_N[15:0]))
            st <= S_IDLE;
        end
        S_DROP_B: begin
          cnt <= cnt + 16'h1;
          if ((!ui_ack && !ui_nack) || (cnt == TO_N[15:0]))
            st <= S_IDLE;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
