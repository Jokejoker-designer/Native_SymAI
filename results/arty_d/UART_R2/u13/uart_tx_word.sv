// uart_tx_word.sv — UART_R2_U13. U10 G3 flush-not-abort + FSM extract guard.
// Board U12 (U10 as-written) produced CLEAR n=0; U8 PACKAGE TX still emitted a token.
// Vivado inferred sequential FSM on U10 st in the same always_ff as flush_hold.
// U13: flush_hold is a separate process; st has fsm_encoding=none.
// Does not abort an in-flight 8N1 frame. CANDIDATE. PROGRAM=NO.
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
  (* fsm_encoding = "none" *) st_t st;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      flush_hold <= 1'b0;
    else if (flush)
      flush_hold <= 1'b1;
    else if (st == IDLE)
      flush_hold <= 1'b0;
  end

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
    end else begin
      unique case (st)
        IDLE: begin
          tx <= 1'b1;
          w_ready <= 1'b1;
          if (flush || flush_hold)
            bix <= 2'h0;
          else if (w_valid && w_ready) begin
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
