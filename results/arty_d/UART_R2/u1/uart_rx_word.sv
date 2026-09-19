// uart_rx_word.sv — UART_R2_U1 candidate. NOT identity H.
// H-class silent drop at 4th STOP is removed: completed word is held until
// handshake or free output slot. No timeout. No STOP=1 check (U2). No new FIFO.
// PROGRAM=NO. Not BOARD_PASS / PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module uart_rx_word #(
  parameter int CLK_HZ = 100_000_000,
  parameter int BAUD = 115200
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        rx,
  output logic        w_valid,
  input  logic        w_ready,
  output logic [31:0] w_data,
  input  logic        flush = 1'b0,
  output logic        idle,
  output logic        rx_sync
);
  localparam int DIV = CLK_HZ / BAUD;
  logic [15:0] div;
  logic [3:0] bitn;
  logic [7:0] sh;
  logic [1:0] bix;
  logic [31:0] acc;
  logic stop_hold;
  typedef enum logic [1:0] { IDLE, START, BITS, STOP } st_t;
  st_t st;
  logic rx_s, rx_d;
  assign idle = rst_n && (st == IDLE) && !w_valid && (bix == 2'h0) && !stop_hold;
  assign rx_sync = rx_d;

  wire can_take = !w_valid || w_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rx_s <= 1'b1;
      rx_d <= 1'b1;
    end else begin
      rx_s <= rx;
      rx_d <= rx_s;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= IDLE;
      w_valid <= 1'b0;
      w_data <= 32'h0;
      bix <= 2'h0;
      acc <= 32'h0;
      bitn <= 4'h0;
      stop_hold <= 1'b0;
      div <= 16'h0;
    end else if (flush) begin
      st <= IDLE;
      w_valid <= 1'b0;
      w_data <= 32'h0;
      bix <= 2'h0;
      acc <= 32'h0;
      bitn <= 4'h0;
      stop_hold <= 1'b0;
      div <= 16'h0;
    end else begin
      if (w_valid && w_ready)
        w_valid <= 1'b0;
      case (st)
        IDLE: if (!rx_d) begin
          div <= DIV/2;
          bitn <= 4'h0;
          st <= START;
        end
        START: begin
          if (div == 16'h0) begin
            if (!rx_d) begin
              div <= DIV;
              bitn <= 4'h0;
              st <= BITS;
            end else st <= IDLE;
          end else div <= div - 16'h1;
        end
        BITS: begin
          if (div == 16'h0) begin
            sh <= {rx_d, sh[7:1]};
            div <= DIV;
            bitn <= bitn + 4'h1;
            if (bitn == 4'd7) st <= STOP;
          end else div <= div - 16'h1;
        end
        STOP: begin
          if (div == 16'h0) begin
            if (stop_hold) begin
              if (can_take) begin
                w_data <= {sh, acc[31:8]};
                w_valid <= 1'b1;
                acc <= {sh, acc[31:8]};
                bix <= 2'h0;
                stop_hold <= 1'b0;
                st <= IDLE;
              end
            end else if (bix == 2'd3) begin
              if (can_take) begin
                w_data <= {sh, acc[31:8]};
                w_valid <= 1'b1;
                acc <= {sh, acc[31:8]};
                bix <= 2'h0;
                st <= IDLE;
              end else
                stop_hold <= 1'b1;
            end else begin
              acc <= {sh, acc[31:8]};
              bix <= bix + 2'h1;
              st <= IDLE;
            end
          end else div <= div - 16'h1;
        end
        default: st <= IDLE;
      endcase
    end
  end
endmodule
