// pack_debug_clear.sv — VALIDATION ONLY. Candidate/debug top.
// NOT_PACK_ABI / NOT_ASTRA_ABI / NOT_FINAL_TOP_CONTRACT / NOT production reset.
// VALIDATION_CLEAR != GLOBAL_RESET. VALIDATION_CLEAR != MIG_RESET.
// CLEAR_REQ 32'h44524743  ACK 32'hC1EA50A5  BUSY 32'hC1EA50B5  ERR 32'hC1EA50E5
// Controller is reset only by system rst_n, never by debug_clear.
//
// Success path: SAMPLE → REQ → CDC rst (4) → UART quiet (flush until rx mark idle)
//               → CLEAR_ACK → short 4-phase DROP. ACK is not issued until RX is quiet.
// Busy path:    SAMPLE → BUSY reply → short DROP. No CDC rst, no UART flush, no long hold.
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
  // ~2.3 char-times at 115200 / 100 MHz; also covers 1 Mbaud TB stray bytes.
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
  // FF-driven so LUTAR-1 does not glitch async CDC CLR from one-hot decode.
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
      cdc_rst_r <= (st == S_CDC);
      flush_r <= (st == S_CDC) || (st == S_QUIET);
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
          cnt <= cnt + 16'h1;
          if (ack_ready || (cnt == TO_N[15:0])) begin
            cnt <= 16'h0;
            st <= S_DROP;
          end
        end
        S_BUSY: begin
          reply <= BUSY;
          cnt <= cnt + 16'h1;
          if (ack_ready || (cnt == TO_N[15:0])) begin
            cnt <= 16'h0;
            st <= S_DROP_B;
          end
        end
        S_ERR: begin
          reply <= ERR;
          cnt <= cnt + 16'h1;
          if (ack_ready || (cnt == TO_N[15:0])) begin
            cnt <= 16'h0;
            st <= S_DROP;
          end
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
