// uart_tx_word.sv — UART_R2_U10 / G3 candidate. Flush waits for IDLE.
// Does not abort an in-flight 8N1 word. Identity != U8/U9 until that bit.
// Not synthesized into U9. CANDIDATE. PROGRAM=NO.
`timescale 1ns/1ps

module uart_tx_word #(
  parameter int CLK_HZ = 100_000_000,
  parameter int BAUD = 115200
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        w_valid,
  output logic        w_ready,
  input  logic [31:0] w_data,
  input  logic        flush = 1'b0,
  output logic        tx
);
  localparam int DIV = CLK_HZ / BAUD;
  logic [15:0] div;
  logic [3:0]  bitn;
  logic [1:0]  bix;
  logic [7:0]  sh;
  logic [31:0] acc;
  logic        flush_hold;
  typedef enum logic [1:0] { IDLE, START, BITS, STOP } st_t;
  st_t st;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= IDLE;
      tx <= 1'b1;
      w_ready <= 1'b1;
      div <= 16'h0;
      bitn <= 4'h0;
      bix <= 2'h0;
      sh <= 8'h0;
      acc <= 32'h0;
      flush_hold <= 1'b0;
    end else begin
      if (flush)
        flush_hold <= 1'b1;
      unique case (st)
        IDLE: begin
          tx <= 1'b1;
          if (flush || flush_hold) begin
            w_ready <= 1'b1;
            bix <= 2'h0;
            flush_hold <= flush;
          end else begin
            w_ready <= 1'b1;
            if (w_valid && w_ready) begin
              acc <= w_data;
              sh <= w_data[7:0];
              bix <= 2'h0;
              div <= DIV;
              bitn <= 4'h0;
              tx <= 1'b0;
              w_ready <= 1'b0;
              st <= START;
            end
          end
        end
        START: begin
          tx <= 1'b0;
          w_ready <= 1'b0;
          if (div == 16'h0) begin
            tx <= sh[0];
            sh <= {1'b0, sh[7:1]};
            div <= DIV;
            bitn <= 4'h1;
            st <= BITS;
          end else div <= div - 16'h1;
        end
        BITS: begin
          w_ready <= 1'b0;
          if (div == 16'h0) begin
            div <= DIV;
            if (bitn == 4'd8) begin
              tx <= 1'b1;
              st <= STOP;
            end else begin
              tx <= sh[0];
              sh <= {1'b0, sh[7:1]};
              bitn <= bitn + 4'h1;
            end
          end else div <= div - 16'h1;
        end
        STOP: begin
          tx <= 1'b1;
          w_ready <= 1'b0;
          if (div == 16'h0) begin
            if (bix == 2'd3) begin
              w_ready <= 1'b1;
              st <= IDLE;
            end else begin
              bix <= bix + 2'h1;
              acc <= {8'h0, acc[31:8]};
              sh <= acc[15:8];
              div <= DIV;
              bitn <= 4'h0;
              tx <= 1'b0;
              st <= START;
            end
          end else div <= div - 16'h1;
        end
        default: begin
          st <= IDLE;
          tx <= 1'b1;
          w_ready <= 1'b1;
        end
      endcase
    end
  end
endmodule
