// UART smoke: uart_rx_word → uart_fe256_host → query_result_bind → uart_tx_word.
// Two hop-1 QueryRecords. Checks 0x4E52 / 0x04+0x20. Not FE256 gold.
// CANDIDATE. PROGRAM=NO. XSim != board. Not ASTRA_PASS / BOARD_PASS.
`timescale 1ns/1ps

module tb_m4_query_result_uart_smoke;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam int N_SMOKE = 2;

  logic clk = 0;
  logic rst_n = 0;
  logic uart_rx, uart_tx;
  logic [3:0] led;
  always #5 clk = ~clk;

  arty_a7_r2_top_m4_query_result_candidate dut (
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

  logic [7:0] q_bytes [0:31];
  logic [7:0] got_r [0:47];
  int n_pass, n_fail, n_hop1, fd;
  logic [31:0] eid, fn, rn;
  logic [15:0] cfwd, crev;
  logic [31:0] smoke_id [0:N_SMOKE-1];

  function automatic [15:0] crc16_step(input [15:0] c, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = c ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii++) c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  function automatic [15:0] crc16_n46(input logic [7:0] b [0:45]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 46; ii++) c = crc16_step(c, b[ii]);
      crc16_n46 = c;
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    input [3:0] hops_i;
    input [15:0] txn;
    integer k;
    logic [15:0] crc;
    logic [15:0] meta;
    begin
      meta = {4'h0, 1'b0, 1'b0, 1'b0, hops_i, 5'h0};
      for (k = 0; k < 32; k++) q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[4] = txn[7:0];
      q_bytes[5] = txn[15:8];
      q_bytes[12] = meta[7:0];
      q_bytes[13] = meta[15:8];
      q_bytes[14] = sid[7:0];
      q_bytes[15] = sid[15:8];
      q_bytes[16] = sid[23:16];
      q_bytes[17] = sid[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
    end
  endtask

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

  task automatic send_query;
    int k;
    logic [31:0] word;
    begin
      for (k = 0; k < 8; k++) begin
        word = {q_bytes[4*k+3], q_bytes[4*k+2], q_bytes[4*k+1], q_bytes[4*k+0]};
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
          $display("UART_M4_TIMEOUT word %0d", k);
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

  integer si, bad;
  logic [7:0] hdr [0:45];
  logic [15:0] crc;
  integer bi;

  initial begin
    n_pass = 0; n_fail = 0; n_hop1 = 0;
    uart_rx = 1'b1;

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while (!$feof(fd) && n_hop1 < N_SMOKE) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cfwd, fn, crev, rn) == 5) begin
        if (cfwd == 0) continue;
        smoke_id[n_hop1] = eid;
        n_hop1++;
      end
    end
    $fclose(fd);
    if (n_hop1 != N_SMOKE) $fatal(1, "need %0d hop1 ids, got %0d", N_SMOKE, n_hop1);

    rst_n = 0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (4) @(posedge clk);

    for (si = 0; si < N_SMOKE; si++) begin
      pack_q(smoke_id[si], 4'd1, si[15:0] + 16'h1);
      send_query();
      recv_result(bad);
      if (bad) begin
        n_fail++;
      end else begin
        for (bi = 0; bi < 46; bi++) hdr[bi] = got_r[bi];
        crc = crc16_n46(hdr);
        if ({got_r[1], got_r[0]} != 16'h4E52) begin
          n_fail++; $display("UART FAIL magic case %0d", si);
        end else if (got_r[3] !== 8'h04 || got_r[4] !== 8'h20 || got_r[6] !== 8'h02) begin
          n_fail++; $display("UART FAIL st=%02x rc=%02x cmpl=%02x", got_r[3], got_r[4], got_r[6]);
        end else if (got_r[5] != 8'h00) begin
          n_fail++; $display("UART FAIL answer_kind");
        end else if ({got_r[47], got_r[46]} !== crc) begin
          n_fail++; $display("UART FAIL crc case %0d", si);
        end else n_pass++;
      end
    end

    if (n_fail == 0 && n_pass == N_SMOKE)
      $display("M4_QUERY_RESULT_UART_SMOKE_XSIM_PASS  %0d/%0d (simulation only; not BOARD_PASS)", n_pass, N_SMOKE);
    else
      $display("M4_QUERY_RESULT_UART_SMOKE_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
