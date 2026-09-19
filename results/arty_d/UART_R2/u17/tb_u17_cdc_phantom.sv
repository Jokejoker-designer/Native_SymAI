// tb_u17_cdc_phantom.sv — word_cdc32 A-reset/B-live emits 0; B-reset with A-reset does not.
// Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u17_cdc_phantom;
  logic a_clk, b_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int pass, fail;

  word_cdc32 u_cdc (
    .a_clk, .a_rst_n, .a_valid, .a_ready, .a_data,
    .b_clk, .b_rst_n, .b_valid, .b_ready, .b_data,
    .a_idle, .b_idle
  );

  initial a_clk = 1'b0;
  always #6.25 a_clk = ~a_clk;
  initial b_clk = 1'b0;
  always #5 b_clk = ~b_clk;

  initial begin
    pass = 0;
    fail = 0;
    a_rst_n = 1'b0;
    b_rst_n = 1'b0;
    a_valid = 1'b0;
    a_data = 32'h0;
    b_ready = 1'b0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1'b1;
    b_rst_n = 1'b1;
    repeat (8) @(posedge a_clk);

    @(posedge a_clk);
    a_data = 32'h010000A5;
    a_valid = 1'b1;
    while (!(a_valid && a_ready)) @(posedge a_clk);
    @(posedge a_clk);
    a_valid = 1'b0;

    while (!b_valid) @(posedge b_clk);
    if (b_data !== 32'h010000A5) begin
      $display("FAIL T0 gold data %08h", b_data);
      fail += 1;
    end else pass += 1;
    @(posedge b_clk);
    b_ready = 1'b1;
    @(posedge b_clk);
    b_ready = 1'b0;
    repeat (16) @(posedge b_clk);

    // U14 class: A reset, B live.
    @(posedge a_clk);
    a_rst_n = 1'b0;
    repeat (4) @(posedge a_clk);
    a_rst_n = 1'b1;
    begin : wait_ph
      int c;
      c = 0;
      while (c < 64 && !b_valid) begin
        @(posedge b_clk);
        c += 1;
      end
      if (!b_valid) begin
        $display("FAIL T1 expected phantom 0-word");
        fail += 1;
      end else if (b_data !== 32'h0) begin
        $display("FAIL T1 phantom data %08h", b_data);
        fail += 1;
      end else begin
        $display("PASS T1 A-reset B-live phantom 0");
        pass += 1;
      end
    end
    b_ready = 1'b1;
    @(posedge b_clk);
    b_ready = 1'b0;
    repeat (8) @(posedge b_clk);

    // U17 class: B reset first (ui_req), then A reset (debug_clear).
    // No second GOLD: after GOLD consume, CLEAR dual-reset must not emit.
    @(posedge b_clk);
    b_rst_n = 1'b0;
    repeat (2) @(posedge a_clk);
    a_rst_n = 1'b0;
    repeat (4) @(posedge a_clk);
    a_rst_n = 1'b1;
    repeat (4) @(posedge b_clk);
    b_rst_n = 1'b1;
    begin : wait_clean
      int c;
      bit saw;
      saw = 1'b0;
      c = 0;
      while (c < 64) begin
        @(posedge b_clk);
        if (b_valid) saw = 1'b1;
        c += 1;
      end
      if (saw) begin
        $display("FAIL T2 phantom after dual reset valid=%0b data=%08h", b_valid, b_data);
        fail += 1;
      end else begin
        $display("PASS T2 B-then-A reset no phantom");
        pass += 1;
      end
    end

    $display("UART_R2_U17_CDC %s pass=%0d fail=%0d", (fail==0)?"PASS_XSIM":"FAIL", pass, fail);
    $finish;
  end
endmodule
