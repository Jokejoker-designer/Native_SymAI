// tb_cdc_stagger.sv — PACKAGE word_cdc32 after U9-style A-held / B-live DROP.
`timescale 1ns/1ps

module tb_cdc_stagger;
  logic a_clk, b_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int pass, fail, n_b;
  logic [31:0] got [0:7];

  initial begin
    a_clk = 1'b0;
    b_clk = 1'b0;
  end
  always #5 a_clk = ~a_clk;
  always #7 b_clk = ~b_clk;

  word_cdc32 u_cdc (
    .a_clk, .a_rst_n, .a_valid, .a_ready, .a_data,
    .b_clk, .b_rst_n, .b_valid, .b_ready, .b_data,
    .a_idle, .b_idle
  );

  always @(posedge b_clk) begin
    if (b_rst_n && b_valid && b_ready) begin
      got[n_b] = b_data;
      n_b = n_b + 1;
    end
  end

  task automatic send_word(input logic [31:0] w);
    begin
      @(posedge a_clk);
      a_data <= w;
      a_valid <= 1'b1;
      @(posedge a_clk);
      while (!(a_valid && a_ready))
        @(posedge a_clk);
      @(posedge a_clk);
      a_valid <= 1'b0;
      @(posedge a_clk);
      while (!a_ready)
        @(posedge a_clk);
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    n_b = 0;
    a_valid = 1'b0;
    a_data = 32'h0;
    b_ready = 1'b1;
    a_rst_n = 1'b0;
    b_rst_n = 1'b0;
    repeat (8) @(posedge a_clk);

    b_rst_n = 1'b1;
    repeat (40) @(posedge a_clk);
    if (n_b != 0) begin
      $display("FAIL extra during A-held n_b=%0d first=%08h", n_b, got[0]);
      fail = fail + 1;
    end else begin
      $display("PASS no B word while A held");
      pass = pass + 1;
    end

    a_rst_n = 1'b1;
    repeat (8) @(posedge a_clk);
    if (n_b != 0) begin
      $display("FAIL extra on A release n_b=%0d first=%08h", n_b, got[0]);
      fail = fail + 1;
    end else begin
      $display("PASS no B word on A release");
      pass = pass + 1;
    end

    send_word(32'h0080_0001);
    send_word(32'h3149_414E);
    send_word(32'h0001_0001);
    repeat (80) @(posedge b_clk);

    $display("B_WORDS n=%0d w0=%08h w1=%08h w2=%08h", n_b, got[0], got[1], got[2]);
    if (n_b != 3 || got[0] != 32'h0080_0001 || got[1] != 32'h3149_414E ||
        got[2] != 32'h0001_0001) begin
      $display("FAIL order/count");
      fail = fail + 1;
    end else begin
      $display("PASS three words in order");
      pass = pass + 1;
    end

    if (fail == 0)
      $display("CDC_STAGGER_XSIM_PASS %0d (not BOARD_PASS)", pass);
    else
      $display("CDC_STAGGER_XSIM_FAIL fail=%0d n_b=%0d", fail, n_b);
    $finish;
  end
endmodule
