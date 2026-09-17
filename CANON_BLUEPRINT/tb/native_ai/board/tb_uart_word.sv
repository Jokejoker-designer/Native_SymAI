// tb_uart_word.sv — TX->RX 32-bit loopback. CANDIDATE. XSim != board.
`timescale 1ns/1ps

module tb_uart_word;
  logic clk, rst_n, tx, w_valid, w_ready, r_valid, r_ready;
  logic [31:0] w_data, r_data;
  int pass, fail;

  uart_tx_word #(.CLK_HZ(100_000_000), .BAUD(115200)) u_tx (
    .clk, .rst_n, .w_valid, .w_ready, .w_data, .tx
  );
  uart_rx_word #(.CLK_HZ(100_000_000), .BAUD(115200)) u_rx (
    .clk, .rst_n, .rx(tx), .w_valid(r_valid), .w_ready(r_ready), .w_data(r_data)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    w_valid = 1'b0;
    w_data = 32'h0;
    r_ready = 1'b1;
    pass = 0;
    fail = 0;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (20) @(posedge clk);

    send(32'hA1B2C3D4);
    send(32'hA5000001);
    if (fail == 0)
      $display("UART_WORD_XSIM_PASS %0d/2", pass);
    else
      $display("UART_WORD_XSIM_FAIL fail=%0d", fail);
    $finish;
  end

  task send(input logic [31:0] w);
    begin
      @(posedge clk);
      while (!w_ready) @(posedge clk);
      w_data <= w;
      w_valid <= 1'b1;
      @(posedge clk);
      w_valid <= 1'b0;
      fork
        begin
          repeat (400000) @(posedge clk);
          $display("TIMEOUT %08h", w);
          fail = fail + 1;
        end
        begin
          wait (r_valid === 1'b1);
          if (r_data !== w) begin
            $display("MISMATCH exp=%08h got=%08h", w, r_data);
            fail = fail + 1;
          end else begin
            $display("MATCH %08h", r_data);
            pass = pass + 1;
          end
          @(posedge clk);
        end
      join_any
      disable fork;
    end
  endtask
endmodule
