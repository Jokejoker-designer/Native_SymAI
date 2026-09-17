// Unit TB: extra 0x00 after CLEAR vs BEGIN 0x01. No MIG. Not BOARD_PASS.
`timescale 1ns/1ps
module tb_h_ila_a_cap;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  logic clk, rst_n, rx, w_ready, flush;
  logic w_valid, idle;
  logic [31:0] w_data;
  logic [1:0] dbg_bix, dbg_st;
  logic [7:0] dbg_sh;
  logic dbg_rx_d;
  logic [3:0] dbg_bitn;
  logic captured, false_start, have_word, wv0, fifo0;
  logic [7:0] sh0, sh1, sh2, sh3;
  logic [3:0] n_bytes;
  logic [1:0] bix_arm;
  logic [9:0] wire10;
  logic [31:0] first_word;
  logic clr_take;
  integer err;

  assign w_ready = 1'b1;
  assign flush = 1'b0;
  assign clr_take = w_valid && (w_data == 32'h44524743);

  uart_rx_word_observe #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data, .flush, .idle, .rx_sync(),
    .dbg_bix, .dbg_sh, .dbg_rx_d, .dbg_st, .dbg_bitn
  );
  h_ila_a_cap #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_cap (
    .clk, .rst_n, .clr_take, .w_valid, .w_data,
    .fifo_wr_valid(1'b0), .fifo_wr_ready(1'b1),
    .dbg_bix, .dbg_sh, .dbg_rx_d, .dbg_st,
    .captured, .sh0, .sh1, .sh2, .sh3, .n_bytes, .bix_at_arm(bix_arm),
    .wire10, .false_start, .have_word, .first_word, .wv_at_sh0(wv0), .fifo_wr_at_sh0(fifo0)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic send_byte(input byte b);
    integer i;
    rx = 1'b0;
    repeat (DIV) @(posedge clk);
    for (i = 0; i < 8; i++) begin
      rx = b[i];
      repeat (DIV) @(posedge clk);
    end
    rx = 1'b1;
    repeat (DIV) @(posedge clk);
  endtask

  initial begin
    err = 0;
    rst_n = 0;
    rx = 1;
    repeat (20) @(posedge clk);
    rst_n = 1;
    repeat (20) @(posedge clk);
    send_byte(8'h43);
    send_byte(8'h47);
    send_byte(8'h52);
    send_byte(8'h44);
    repeat (DIV) @(posedge clk);
    send_byte(8'h00);
    send_byte(8'h01);
    send_byte(8'h00);
    send_byte(8'h80);
    repeat (4 * DIV) @(posedge clk);
    if (!captured) begin $display("FAIL not captured"); err++; end
    if (sh0 !== 8'h00) begin $display("FAIL sh0=%h", sh0); err++; end
    if (sh1 !== 8'h01) begin $display("FAIL sh1=%h", sh1); err++; end
    if (sh2 !== 8'h00) begin $display("FAIL sh2=%h", sh2); err++; end
    if (sh3 !== 8'h80) begin $display("FAIL sh3=%h", sh3); err++; end
    if (wire10[0] !== 1'b0) begin $display("FAIL start=%b", wire10[0]); err++; end
    if (wire10[8:1] !== 8'h43) begin $display("FAIL data=%b want 43", wire10[8:1]); err++; end
    if (wire10[9] !== 1'b1) begin $display("FAIL stop=%b", wire10[9]); err++; end
    if (false_start) begin $display("FAIL false_start"); err++; end
    if (first_word !== 32'h44524743) begin $display("FAIL word=%h", first_word); err++; end
    if (err == 0) $display("TB_H_ILA_A_CAP_PASS sh=%h %h %h %h wire=%03h word=%h", sh0, sh1, sh2, sh3, wire10, first_word);
    else $display("TB_H_ILA_A_CAP_FAIL n=%0d", err);
    $finish;
  end
endmodule
