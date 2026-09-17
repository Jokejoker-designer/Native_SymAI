// D-owned candidate FPGA UART coexistence.
// Pack ACK/NAK + FE256 gold over the same uart_rx/uart_tx (no tb_steer).
// TB forces calib_ui=1 to model fabric BRAM dest; freeze r2_top not modified.
// CANDIDATE. PROGRAM=NO. XSim != board. Not FE256_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
`timescale 1ns/1ps
`include "fe256_abi_constants.svh"

module tb_r2_fe256_r1_uart_fpga;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam int N = FE256_N_CASES;
  localparam int QW = FE256_QUERY_BYTES;
  localparam int RW = FE256_RESULT_BYTES;

  logic clk = 0;
  logic rst_n = 0;
  logic uart_rx, uart_tx;
  logic [3:0] led;
  always #5 clk = ~clk;

  arty_a7_r2_top_fe256_r1_candidate dut (
    .CLK100MHZ(clk),
    .ck_rst(rst_n),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .led(led)
  );

  logic host_valid, host_ready;
  logic [31:0] host_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk, .rst_n, .rx(uart_tx),
    .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;

  logic [7:0] gold_q [0:N-1][0:QW-1];
  logic [7:0] gold_r [0:N-1][0:RW-1];
  logic [7:0] got_r [0:RW-1];
  logic [31:0] vec [0:1023];
  int nwords, pack_pass, pack_fail, fe_pass, fe_fail, n_fe;
  integer fd, code, rec, bi, hi, lo, mismatch;
  string line;

  function automatic int hex_nibble(byte c);
    if (c >= "0" && c <= "9") return c - "0";
    if (c >= "a" && c <= "f") return 10 + (c - "a");
    if (c >= "A" && c <= "F") return 10 + (c - "A");
    return -1;
  endfunction

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

  task automatic reset_dut;
    begin
      rst_n = 1'b0;
      uart_rx = 1'b1;
      repeat (20) @(posedge clk);
      rst_n = 1'b1;
      repeat (20) @(posedge clk);
    end
  endtask

  task automatic load_mem(input string path);
    int fdi, i;
    begin
      fdi = $fopen(path, "r");
      if (fdi == 0) begin
        $display("FAIL open %s", path);
        pack_fail = pack_fail + 1;
        nwords = 0;
      end else begin
        void'($fscanf(fdi, "%h", nwords));
        for (i = 0; i < nwords; i++) void'($fscanf(fdi, "%h", vec[i]));
        $fclose(fdi);
      end
    end
  endtask

  task automatic send_pack;
    int i;
    begin
      for (i = 0; i < nwords; i++) begin
        uart_byte(vec[i][7:0]);
        uart_byte(vec[i][15:8]);
        uart_byte(vec[i][23:16]);
        uart_byte(vec[i][31:24]);
      end
    end
  endtask

  task automatic wait_status(input logic [31:0] exp, input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && !host_valid) begin
        @(posedge clk);
        c++;
      end
      if (!host_valid) begin
        $display("PACK_TIMEOUT exp=%08h", exp);
        pack_fail = pack_fail + 1;
      end else if (host_data !== exp) begin
        $display("PACK_MISMATCH exp=%08h got=%08h", exp, host_data);
        pack_fail = pack_fail + 1;
      end else begin
        $display("PACK_MATCH %08h", host_data);
        pack_pass = pack_pass + 1;
      end
      @(posedge clk);
    end
  endtask

  task automatic send_query(input int idx);
    int k;
    logic [31:0] word;
    begin
      for (k = 0; k < 8; k++) begin
        word = {gold_q[idx][4*k+3], gold_q[idx][4*k+2],
                gold_q[idx][4*k+1], gold_q[idx][4*k+0]};
        uart_byte(word[7:0]);
        uart_byte(word[15:8]);
        uart_byte(word[23:16]);
        uart_byte(word[31:24]);
      end
    end
  endtask

  task automatic recv_result(output int bad);
    int k, c;
    logic [31:0] word;
    begin
      bad = 0;
      for (k = 0; k < 12; k++) begin
        c = 0;
        while (c < 3000000 && !host_valid) begin
          @(posedge clk);
          c++;
        end
        if (!host_valid) begin
          $display("UART_FE256_TIMEOUT word %0d", k);
          bad = 1;
          return;
        end
        word = host_data;
        got_r[4*k+0] = word[7:0];
        got_r[4*k+1] = word[15:8];
        got_r[4*k+2] = word[23:16];
        got_r[4*k+3] = word[31:24];
        @(posedge clk);
      end
    end
  endtask

  initial begin
    pack_pass = 0;
    pack_fail = 0;
    fe_pass = 0;
    fe_fail = 0;
    n_fe = N;
    uart_rx = 1'b1;
    force dut.calib_ui = 1'b1;
    force dut.tb_steer = 1'b0;

    fd = $fopen("fe256_queries.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_queries.hex", "r");
    if (fd == 0) $fatal(1, "cannot open fe256_queries.hex");
    rec = 0;
    while (!$feof(fd) && rec < N) begin
      code = $fgets(line, fd);
      if (code <= 0) continue;
      if (line.len() < 2 * QW) continue;
      for (bi = 0; bi < QW; bi++) begin
        hi = hex_nibble(line.getc(2 * bi));
        lo = hex_nibble(line.getc(2 * bi + 1));
        if (hi < 0 || lo < 0) $fatal(1, "bad query hex rec %0d", rec);
        gold_q[rec][bi] = 8'(hi * 16 + lo);
      end
      rec++;
    end
    $fclose(fd);
    if (rec != N) $fatal(1, "query count %0d != %0d", rec, N);

    fd = $fopen("fe256_gold_results.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_gold_results.hex", "r");
    if (fd == 0) $fatal(1, "cannot open fe256_gold_results.hex");
    rec = 0;
    while (!$feof(fd) && rec < N) begin
      code = $fgets(line, fd);
      if (code <= 0) continue;
      if (line.len() < 2 * RW) continue;
      for (bi = 0; bi < RW; bi++) begin
        hi = hex_nibble(line.getc(2 * bi));
        lo = hex_nibble(line.getc(2 * bi + 1));
        if (hi < 0 || lo < 0) $fatal(1, "bad result hex rec %0d", rec);
        gold_r[rec][bi] = 8'(hi * 16 + lo);
      end
      rec++;
    end
    $fclose(fd);
    if (rec != N) $fatal(1, "result count %0d != %0d", rec, N);

    reset_dut();
    load_mem("v1_valid.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    reset_dut();
    load_mem("v2_bad_magic.mem");
    send_pack();
    wait_status(32'h0200015A, 2000000);

    if (pack_fail != 0) begin
      $display("UART_FPGA_XSIM_FAIL pack fail=%0d (stop; FE256 not run)", pack_fail);
      $finish;
    end

    reset_dut();
    for (rec = 0; rec < n_fe; rec++) begin
      send_query(rec);
      recv_result(mismatch);
      if (mismatch != 0) begin
        fe_fail++;
        $display("UART_FE256_TIMEOUT case %0d", rec);
        break;
      end else begin
        mismatch = 0;
        for (bi = 0; bi < RW; bi++) begin
          if (got_r[bi] !== gold_r[rec][bi]) mismatch++;
        end
        if (mismatch != 0) begin
          fe_fail++;
          $display("UART_FE256_MISMATCH case %0d byte_mismatches=%0d", rec, mismatch);
          break;
        end else begin
          fe_pass++;
          if ((rec % 32) == 0)
            $display("UART_FE256_MATCH case %0d", rec);
        end
      end
      repeat (DIV * 2) @(posedge clk);
    end

    if (pack_fail == 0 && pack_pass == 2 && fe_fail == 0 && fe_pass == n_fe)
      $display("UART_FPGA_XSIM_CANDIDATE pack 2/2 FE256 %0d/%0d (simulation only; not FE256_PASS; not BOARD_PASS)",
               fe_pass, n_fe);
    else
      $display("UART_FPGA_XSIM_FAIL pack=%0d/%0d fe=%0d/%0d fail_p=%0d fail_f=%0d",
               pack_pass, 2, fe_pass, n_fe, pack_fail, fe_fail);
    $finish;
  end
endmodule
