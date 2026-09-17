// tb_h17_dest_persist.sv — H17 dest persist after VALIDATION_CLEAR.
// Dual-clock harness, dest=mig_ui_bram not mig0. BAUD 1e6.
// Sequence: CLEAR → V-03 (empty dest) → CLEAR → V-03 again.
// If second V-03 is SENTINEL 0200085a, dest payload survives CLEAR (RTL_FACT).
// Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h17_dest_persist;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD   = 32'h44524743;
  localparam logic [31:0] CLR_ACK   = 32'hC1EA50A5;
  localparam logic [31:0] GOLD      = 32'h010000A5;
  localparam logic [31:0] SENTINEL  = 32'h0200085A;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready;
  logic [31:0] w_data;
  logic fifo_wr_fire, fifo_rd_fire, p_fire;
  logic [31:0] fifo_wr_data, fifo_rd_data, p_data;
  logic load_ack, load_reject;
  logic [7:0] reason_code;

  pack_uart_dualclk_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code
  );

  integer n_cmd_fifo;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      n_cmd_fifo = 0;
    else if (fifo_wr_fire && fifo_wr_data == CLR_CMD)
      n_cmd_fifo = n_cmd_fifo + 1;
  end

  logic [31:0] first_p;
  logic first_p_seen;
  always @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      first_p_seen <= 1'b0;
      first_p <= 32'h0;
    end else if (p_fire && !first_p_seen) begin
      first_p_seen <= 1'b1;
      first_p <= p_data;
    end
  end

  logic host_valid, host_ready, host_seen, host_take;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;
  initial host_take = 1'b0;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      host_seen <= 1'b0;
      host_cap <= 32'h0;
    end else if (host_take) begin
      host_seen <= 1'b0;
    end else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, fail;
  logic [31:0] got_a, got_b;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin
        $display("FAIL open %s", path);
        fail = fail + 1;
        nwords = 0;
      end else begin
        void'($fscanf(fd, "%h", nwords));
        for (i = 0; i < nwords; i++)
          void'($fscanf(fd, "%h", vec[i]));
        $fclose(fd);
      end
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk100);
      for (k = 0; k < 8; k++) begin
        uart_rx <= b[k];
        repeat (DIV) @(posedge clk100);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge clk100);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]);
      uart_byte(w[15:8]);
      uart_byte(w[23:16]);
      uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_word(output logic [31:0] got, input int maxc);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      if (!host_seen)
        got = 32'h0;
      else
        got = host_cap;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  task automatic send_pack();
    begin
      first_p_seen = 1'b0;
      for (i = 0; i < nwords; i++)
        send_word(vec[i]);
    end
  endtask

  initial begin
    fail = 0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);

    load_mem("PA24-V-03.mem");
    send_word(CLR_CMD);
    wait_word(got_a, 400000);
    if (got_a !== CLR_ACK) begin
      $display("H17 CLEAR1 got=%08h n_cmd_fifo=%0d", got_a, n_cmd_fifo);
      fail = fail + 1;
    end else
      $display("H17 CLEAR1 ACK n_cmd_fifo=%0d", n_cmd_fifo);

    send_pack();
    wait_word(got_a, 3_000_000);
    $display("H17 V-03 empty dest got=%08h first_p=%08h reason=%02h lock=%0b",
             got_a, first_p, reason_code, u_h.pack_lock);
    if (got_a !== GOLD)
      fail = fail + 1;

    send_word(CLR_CMD);
    wait_word(got_b, 400000);
    if (got_b !== CLR_ACK) begin
      $display("H17 CLEAR2 got=%08h", got_b);
      fail = fail + 1;
    end else
      $display("H17 CLEAR2 ACK");

    send_pack();
    wait_word(got_b, 3_000_000);
    $display("H17 V-03 after CLEAR got=%08h first_p=%08h reason=%02h n_cmd_fifo=%0d",
             got_b, first_p, reason_code, n_cmd_fifo);

    if (got_a === GOLD && got_b === SENTINEL)
      $display("H17_DEST_PERSIST_XSIM_PASS second=SENTINEL (not PACK_ABI_24_24_PASS / not BOARD_PASS)");
    else if (got_a === GOLD && got_b === GOLD)
      $display("H17_DEST_WIPED_XSIM dest cleared by VALIDATION_CLEAR fail=%0d", fail);
    else
      $display("H17_DEST_PERSIST_XSIM_FAIL empty=%08h second=%08h fail=%0d", got_a, got_b, fail);
    $finish;
  end
endmodule
