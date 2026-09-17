// tb_word_cdc32.sv — ui_clk-like -> clk100 word CDC. CANDIDATE. XSim != board.
`timescale 1ns/1ps

module tb_word_cdc32;
  logic a_clk, b_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  int pass, fail;

  word_cdc32 u_cdc (
    .a_clk, .a_rst_n, .a_valid, .a_ready, .a_data,
    .b_clk, .b_rst_n, .b_valid, .b_ready, .b_data
  );

  initial a_clk = 1'b0;
  always #6 a_clk = ~a_clk;
  initial b_clk = 1'b0;
  always #5 b_clk = ~b_clk;

  initial begin
    a_rst_n = 1'b0;
    b_rst_n = 1'b0;
    a_valid = 1'b0;
    a_data = 32'h0;
    b_ready = 1'b1;
    pass = 0;
    fail = 0;
    repeat (8) @(posedge a_clk);
    a_rst_n = 1'b1;
    b_rst_n = 1'b1;
    repeat (8) @(posedge a_clk);
    send(32'hA5000001);
    send(32'h5A000002);
    if (fail == 0)
      $display("WORD_CDC32_XSIM_PASS %0d/2", pass);
    else
      $display("WORD_CDC32_XSIM_FAIL fail=%0d", fail);
    $finish;
  end

  task send(input logic [31:0] w);
    begin
      @(posedge a_clk);
      while (!a_ready) @(posedge a_clk);
      a_data <= w;
      a_valid <= 1'b1;
      @(posedge a_clk);
      a_valid <= 1'b0;
      fork
        begin
          repeat (200) @(posedge b_clk);
          $display("TIMEOUT %08h", w);
          fail = fail + 1;
        end
        begin
          wait (b_valid === 1'b1);
          if (b_data !== w) begin
            $display("MISMATCH exp=%08h got=%08h", w, b_data);
            fail = fail + 1;
          end else begin
            $display("MATCH %08h", b_data);
            pass = pass + 1;
          end
          while (b_valid) @(posedge b_clk);
        end
      join_any
      disable fork;
    end
  endtask
endmodule
