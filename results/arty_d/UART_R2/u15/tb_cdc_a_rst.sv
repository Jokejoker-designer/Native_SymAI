// tb_cdc_a_rst.sv — A-reset after one consumed word must not emit 32'h0 on B.
`timescale 1ns/1ps
module tb_cdc_a_rst;
  logic a_clk, b_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int pass, fail, got0;

  word_cdc32 u_cdc (
    .a_clk, .a_rst_n, .a_valid, .a_ready, .a_data,
    .b_clk, .b_rst_n, .b_valid, .b_ready, .b_data, .a_idle, .b_idle
  );

  initial begin a_clk=0; b_clk=0; end
  always #7 a_clk = ~a_clk;
  always #5 b_clk = ~b_clk;

  initial begin
    pass=0; fail=0; got0=0;
    a_rst_n=0; b_rst_n=0; a_valid=0; a_data=0; b_ready=1;
    repeat (4) @(posedge a_clk);
    a_rst_n=1; b_rst_n=1;
    repeat (8) @(posedge a_clk);
    a_data=32'h010000A5; a_valid=1;
    @(posedge a_clk);
    while (!(a_valid && a_ready)) @(posedge a_clk);
    @(posedge a_clk); a_valid=0;
    while (!b_idle) @(posedge b_clk);
    repeat (20) @(posedge a_clk);
    $display("IDLE after GOLD a_idle=%0b b_idle=%0b req_a=%0b last_b=%0b ack_b=%0b ack_a1=%0b b_data=%08h",
             a_idle, b_idle, u_cdc.req_a, u_cdc.last_b, u_cdc.ack_b, u_cdc.ack_a1, b_data);
    // Reset A only, B live.
    @(posedge a_clk); a_rst_n=0;
    repeat (4) @(posedge a_clk);
    a_rst_n=1;
    repeat (40) begin
      @(posedge b_clk);
      if (b_valid && b_data==32'h0) got0=1;
      if (b_valid) $display("B_VALID data=%08h", b_data);
    end
    if (got0) begin
      $display("FAIL A-reset emitted 0 on B");
      fail=1;
    end else begin
      $display("PASS A-reset did not emit 0");
      pass=1;
    end
    $display("CDC_A_RST_XSIM fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
