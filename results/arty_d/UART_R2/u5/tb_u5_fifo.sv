// tb_u5_fifo.sv — UART_R2_U5 prove existing word_fifo32. Branch A, no vendor FIFO.
// XSim != board. FIFO empty is not destination completion.
`timescale 1ns/1ps

module tb_u5_fifo;
  localparam int DEPTH = 128;
  logic clk, rst_n, wr_valid, wr_ready, rd_valid, rd_ready, flush, empty;
  logic [31:0] wr_data, rd_data;
  logic [7:0] used;
  word_fifo32 #(.DEPTH(DEPTH)) dut (
    .clk, .rst_n, .wr_valid, .wr_ready, .wr_data,
    .rd_valid, .rd_ready, .rd_data, .flush, .empty, .used_o(used)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  int wr_n, rd_n, fail, i;
  logic [31:0] got [0:255];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_n <= 0;
      wr_n <= 0;
    end else begin
      if (wr_valid && wr_ready)
        wr_n <= wr_n + 1;
      if (rd_valid && rd_ready) begin
        got[rd_n] <= rd_data;
        rd_n <= rd_n + 1;
      end
    end
  end

  task automatic reset_all;
    begin
      rst_n = 1'b0; wr_valid = 1'b0; rd_ready = 1'b0; flush = 1'b0; wr_data = 32'h0;
      repeat (4) @(posedge clk);
      rst_n = 1'b1;
      repeat (4) @(posedge clk);
    end
  endtask

  task automatic put1(input logic [31:0] w);
    begin
      @(negedge clk);
      wr_data = w;
      wr_valid = 1'b1;
      @(posedge clk);
      @(negedge clk);
      wr_valid = 1'b0;
    end
  endtask

  task automatic drain_all(input int maxc);
    int c;
    begin
      rd_ready = 1'b1;
      c = 0;
      while (c < maxc && !empty) begin
        @(posedge clk);
        c = c + 1;
      end
      repeat (4) @(posedge clk);
      rd_ready = 1'b0;
    end
  endtask

  initial begin
    $display("UART_R2_U5_FIFO_XSIM start WIDTH=32 DEPTH=128 CLK=same");
    fail = 0;

    reset_all();
    rd_ready = 1'b0;
    for (i = 0; i < DEPTH; i++)
      put1(32'h10000000 + i);
    @(posedge clk);
    if (wr_ready || used != DEPTH) begin
      $display("U5 CHECK_FAIL not full used=%0d rdy=%0b wr_n=%0d", used, wr_ready, wr_n);
      fail = fail + 1;
    end else $display("U5 CHECK_OK FULL used=%0d wr_n=%0d wr_ready=0", used, wr_n);

    reset_all();
    for (i = 0; i < DEPTH-1; i++)
      put1(i);
    @(posedge clk);
    if (!wr_ready || used != DEPTH-1) begin
      $display("U5 CHECK_FAIL almost-full used=%0d rdy=%0b", used, wr_ready);
      fail = fail + 1;
    end else $display("U5 CHECK_OK ALMOST_FULL used=%0d", used);

    reset_all();
    for (i = 0; i < 8; i++)
      put1(32'h20000000 + i);
    rd_ready = 1'b1;
    for (i = 0; i < 8; i++)
      put1(32'h30000000 + i);
    drain_all(32);
    $display("U5 SIM wr_n=%0d rd_n=%0d empty=%0b used=%0d", wr_n, rd_n, empty, used);
    if (wr_n != rd_n || wr_n != 16) begin
      $display("U5 CHECK_FAIL sim conservation wr=%0d rd=%0d", wr_n, rd_n);
      fail = fail + 1;
    end else begin
      for (i = 0; i < 8; i++)
        if (got[i] !== 32'h20000000 + i) fail = fail + 1;
      for (i = 0; i < 8; i++)
        if (got[8+i] !== 32'h30000000 + i) fail = fail + 1;
      $display("U5 CHECK_OK SIMUL_RW order conserved wr=rd=16");
    end

    reset_all();
    rd_ready = 1'b0;
    for (i = 0; i < 32; i++)
      put1(32'h40000000 + i);
    repeat (8) @(posedge clk);
    $display("U5 STALL filled used=%0d wr_n=%0d", used, wr_n);
    @(negedge clk);
    rd_ready = 1'b1;
    i = 0;
    while (i < 64 && !empty) begin
      @(posedge clk);
      i = i + 1;
    end
    repeat (8) @(posedge clk);
    rd_ready = 1'b0;
    @(posedge clk);
    if (wr_n != rd_n || wr_n != 32 || got[0] !== 32'h40000000 || got[31] !== 32'h4000001F) begin
      $display("U5 CHECK_FAIL stall wr=%0d rd=%0d e0=%08h e31=%08h", wr_n, rd_n, got[0], got[31]);
      fail = fail + 1;
    end else $display("U5 CHECK_OK LONG_STALL_DRAIN wr=rd=32");

    reset_all();
    rd_ready = 1'b0;
    for (i = 0; i < 7; i++)
      put1(32'h5);
    @(negedge clk); flush = 1'b1;
    @(posedge clk);
    @(negedge clk); flush = 1'b0;
    drain_all(8);
    if (!empty || rd_n != 0) begin
      $display("U5 CHECK_FAIL flush leftover rd_n=%0d empty=%0b", rd_n, empty);
      fail = fail + 1;
    end else $display("U5 CHECK_OK FLUSH");

    @(negedge clk); wr_valid = 1'b1; wr_data = 32'h9;
    @(posedge clk);
    rst_n = 1'b0; repeat (2) @(posedge clk); rst_n = 1'b1;
    wr_valid = 1'b0; rd_ready = 1'b1;
    repeat (4) @(posedge clk);
    if (!empty) begin
      $display("U5 CHECK_FAIL reset leftover");
      fail = fail + 1;
    end else $display("U5 CHECK_OK RESET");

    $display("U5 width=32 depth=128 clocks=clk100/same usable=%0d full=wr_ready0 empty=rd_valid0", DEPTH);
    $display("U5 max absorbable UART burst while consumer stalled = 128 words (512 B)");
    $display("U5 UART has no RTS/CTS; infinite host burst is not guaranteed");
    $display("U5 HOST_PROTOCOL: Pack/ACK window + query 8-word record. Pacing is not correctness.");

    if (fail == 0)
      $display("UART_R2_U5_FIFO_XSIM_PASS BRANCH_A_EXISTING_FIFO");
    else
      $display("UART_R2_U5_FIFO_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
