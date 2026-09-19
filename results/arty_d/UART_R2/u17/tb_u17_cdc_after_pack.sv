// tb_u17_cdc_after_pack.sv — after N transfers, CLEAR-like reset order vs extra B word.
`timescale 1ns/1ps

module tb_u17_cdc_after_pack;
  logic a_clk, b_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int i, extra, pass, fail;

  word_cdc32 u_cdc (
    .a_clk, .a_rst_n, .a_valid, .a_ready, .a_data,
    .b_clk, .b_rst_n, .b_valid, .b_ready, .b_data,
    .a_idle, .b_idle
  );

  initial a_clk = 0; always #5 a_clk = ~a_clk;     // 100
  initial b_clk = 0; always #6.25 b_clk = ~b_clk;  // UI

  task automatic send_n(input int n);
    begin
      for (i = 0; i < n; i++) begin
        @(posedge a_clk);
        a_data = 32'h00800001 + i;
        a_valid = 1'b1;
        while (!(a_valid && a_ready)) @(posedge a_clk);
        @(posedge a_clk);
        a_valid = 1'b0;
        while (!b_valid) @(posedge b_clk);
        @(posedge b_clk);
        b_ready = 1'b1;
        @(posedge b_clk);
        b_ready = 1'b0;
      end
      repeat (16) @(posedge a_clk);
    end
  endtask

  task automatic watch_extra(input string tag);
    begin
      extra = 0;
      repeat (80) begin
        @(posedge b_clk);
        if (b_valid) begin
          extra += 1;
          $display("%s extra b_data=%08h", tag, b_data);
          b_ready = 1'b1;
          @(posedge b_clk);
          b_ready = 1'b0;
        end
      end
      if (extra == 0) begin
        $display("PASS %s no extra", tag);
        pass += 1;
      end else begin
        $display("FAIL %s extra=%0d", tag, extra);
        fail += 1;
      end
    end
  endtask

  initial begin
    pass = 0; fail = 0;
    a_rst_n = 0; b_rst_n = 0; a_valid = 0; b_ready = 0; a_data = 0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1; b_rst_n = 1;
    repeat (8) @(posedge a_clk);

    send_n(8);
    // MAG: A reset, B live
    a_rst_n = 0;
    repeat (4) @(posedge a_clk);
    a_rst_n = 1;
    watch_extra("MAG_A_rst_B_live");

    send_n(8);
    // U8 overlap: A and B reset together, then A live while B still reset, then B live (S_DROP)
    a_rst_n = 0; b_rst_n = 0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1;
    repeat (4) @(posedge b_clk);
    b_rst_n = 1;
    watch_extra("U8_A_then_B_release");

    send_n(8);
    // both release together
    a_rst_n = 0; b_rst_n = 0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1; b_rst_n = 1;
    watch_extra("BOTH_release");

    send_n(8);
    // B first then A (U17 TX order), then both live
    b_rst_n = 0;
    repeat (2) @(posedge a_clk);
    a_rst_n = 0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1; b_rst_n = 1;
    watch_extra("B_then_A_then_release");

    $display("UART_R2_U17_CDC_PACK %s pass=%0d fail=%0d", (fail==0)?"PASS_XSIM":"FAIL", pass, fail);
    $finish;
  end
endmodule
