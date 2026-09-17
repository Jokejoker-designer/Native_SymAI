// uart_fe256_host.sv — UART 32-bit LE words <-> QueryRecord/StructuredResult.
// Magic 0x4E51 (existing QueryRecord) vs pack MAGIC_NAI1. No new ABI.
// Shadow-bind only. PROGRAM=NO. Not on frozen r2_top.
`timescale 1ns/1ps

module uart_fe256_host (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        in_valid,
  output logic        in_ready,
  input  logic [31:0] in_data,
  output logic        taking,
  output logic        q_valid,
  input  logic        q_ready,
  output logic [7:0]  q_bytes [0:31],
  input  logic        r_valid,
  output logic        r_ready,
  input  logic [7:0]  r_bytes [0:47],
  output logic        tx_valid,
  input  logic        tx_ready,
  output logic [31:0] tx_data
);
  localparam logic [15:0] QMAGIC = 16'h4E51;

  typedef enum logic [2:0] {
    S_IDLE,
    S_RX,
    S_ISSUE,
    S_WAIT,
    S_TX
  } st_t;

  st_t st;
  logic [2:0]  wix;
  logic [3:0]  tox;
  logic [31:0] qw [0:7];
  logic [31:0] rw [0:11];
  integer jj;

  assign taking = (st == S_RX) || (st == S_IDLE && in_valid && in_data[15:0] == QMAGIC);

  always_comb begin : unpack_q
    automatic int k;
    for (k = 0; k < 32; k++)
      q_bytes[k] = qw[k/4][8*(k%4) +: 8];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      wix <= 3'h0;
      tox <= 4'h0;
      q_valid <= 1'b0;
      r_ready <= 1'b0;
      tx_valid <= 1'b0;
      tx_data <= 32'h0;
      in_ready <= 1'b1;
      for (jj = 0; jj < 8; jj++) qw[jj] <= 32'h0;
      for (jj = 0; jj < 12; jj++) rw[jj] <= 32'h0;
    end else begin
      unique case (st)
        S_IDLE: begin
          q_valid <= 1'b0;
          r_ready <= 1'b0;
          tx_valid <= 1'b0;
          in_ready <= 1'b1;
          wix <= 3'h0;
          if (in_valid && in_data[15:0] == QMAGIC) begin
            qw[0] <= in_data;
            wix <= 3'h1;
            in_ready <= 1'b1;
            st <= S_RX;
          end
        end
        S_RX: begin
          in_ready <= 1'b1;
          if (in_valid && in_ready) begin
            qw[wix] <= in_data;
            if (wix == 3'h7) begin
              in_ready <= 1'b0;
              q_valid <= 1'b1;
              st <= S_ISSUE;
            end else wix <= wix + 3'h1;
          end
        end
        S_ISSUE: begin
          in_ready <= 1'b0;
          q_valid <= 1'b1;
          if (q_ready) begin
            q_valid <= 1'b0;
            st <= S_WAIT;
          end
        end
        S_WAIT: begin
          r_ready <= 1'b1;
          if (r_valid && r_ready) begin
            r_ready <= 1'b0;
            for (jj = 0; jj < 12; jj++)
              rw[jj] <= {r_bytes[4*jj+3], r_bytes[4*jj+2], r_bytes[4*jj+1], r_bytes[4*jj+0]};
            tox <= 4'h0;
            tx_valid <= 1'b1;
            tx_data <= {r_bytes[3], r_bytes[2], r_bytes[1], r_bytes[0]};
            st <= S_TX;
          end
        end
        S_TX: begin
          if (tx_valid && tx_ready) begin
            if (tox == 4'd11) begin
              tx_valid <= 1'b0;
              st <= S_IDLE;
              in_ready <= 1'b1;
            end else begin
              tox <= tox + 4'h1;
              tx_data <= rw[tox + 1];
            end
          end
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
