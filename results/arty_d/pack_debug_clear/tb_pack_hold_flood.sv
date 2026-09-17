// tb_pack_hold_flood.sv — E next experiment 1. Not PACK_ABI_24_24_PASS.
// Extra CLEAR during hold: FIFO must not accept the same word every cycle.
`timescale 1ns/1ps
module tb_pack_hold_flood;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 1_000_000;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;

  logic clk, rst_n, uart_rx;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  logic w_valid, w_ready, clr_take, clr_hold, uart_flush, cdc_rst_100;
  logic [31:0] w_data;
  logic fifo_wr_ready, fifo_empty, f_valid, f_ready;
  logic [31:0] f_data;
  logic [7:0] fifo_used;
  logic ui_req, ui_ack, ui_nack, ack_valid, ack_ready;
  logic [31:0] ack_data;
  logic rx_mark;
  int hold_wr, hold_wr_max, pass, fail, k, c;
  logic host_seen;
  logic [31:0] host_cap;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid(w_valid), .in_data(w_data),
    .take(clr_take), .hold(clr_hold),
    .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(1'b1),
    .uart_rx_mark(rx_mark),
    .ack_valid, .ack_ready, .ack_data
  );

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx(uart_rx),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data),
    .flush(uart_flush), .idle(rx_mark), .rx_sync()
  );

  word_fifo32 #(.DEPTH(128)) u_rfifo (
    .clk, .rst_n,
    .wr_valid(w_valid && !clr_take && !clr_hold),
    .wr_ready(fifo_wr_ready), .wr_data(w_data),
    .rd_valid(f_valid), .rd_ready(f_ready), .rd_data(f_data),
    .flush(uart_flush), .empty(fifo_empty), .used_o(fifo_used)
  );
  assign f_ready = 1'b0;
  assign w_ready = clr_take || (!clr_hold && fifo_wr_ready);
  assign ack_ready = ack_valid;

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) ui_ack <= 1'b0;
    else ui_ack <= ui_req;
  assign ui_nack = 1'b0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hold_wr <= 0;
      hold_wr_max <= 0;
    end else if (clr_hold && w_valid && !clr_take && fifo_wr_ready) begin
      hold_wr <= hold_wr + 1;
      if (hold_wr + 1 > hold_wr_max) hold_wr_max <= hold_wr + 1;
    end
  end

  task automatic uart_byte(input logic [7:0] b);
    int i;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (i = 0; i < 8; i++) begin
        uart_rx <= b[i];
        repeat (DIV) @(posedge clk);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]);
      uart_byte(w[15:8]);
      uart_byte(w[23:16]);
      uart_byte(w[31:24]);
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (20) @(posedge clk);

    send_word(CLR_CMD);
    send_word(CLR_CMD);
    send_word(CLR_CMD);
    send_word(CLR_CMD);

    c = 0;
    host_seen = 1'b0;
    while (c < 300000 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!ack_valid || ack_data !== CLR_ACK) begin
      $display("T10 TIMEOUT/MISMATCH ack_valid=%0d data=%08h", ack_valid, ack_data);
      fail = fail + 1;
    end else begin
      $display("T10 MATCH ACK %08h", ack_data);
      pass = pass + 1;
    end

    if (hold_wr_max >= 8) begin
      $display("T10 FAIL HOLD_WR_MAX=%0d used=%0d (flood)", hold_wr_max, fifo_used);
      fail = fail + 1;
    end else begin
      $display("T10 PASS HOLD_WR_MAX=%0d used=%0d", hold_wr_max, fifo_used);
      pass = pass + 1;
    end

    if (fail == 0)
      $display("PACK_HOLD_FLOOD_XSIM_PASS %0d (not PACK_ABI_24_24_PASS)", pass);
    else
      $display("PACK_HOLD_FLOOD_XSIM_FAIL fail=%0d pass=%0d HOLD_WR_MAX=%0d",
               fail, pass, hold_wr_max);
    $finish;
  end
endmodule
