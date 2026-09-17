// tb_h12_class_a.sv — CLASS A reproducers without board.
// A: extra UART bytes before CLEAR (word misalign).
// B: dest stall + overflow FIFO past DEPTH 128 → uart_rx_word drop if w_valid && !w_ready.
// Dest=mig_ui_bram. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h12_class_a;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD = 32'h010000A5;
  localparam logic [31:0] MAG = 32'h0200015A;
  localparam logic [31:0] UNSUP = 32'h0200075A;
  localparam logic [31:0] SENTINEL = 32'h0200085A;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx, dest_stall;
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
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code,
    .dest_stall
  );

  integer n_drop;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      n_drop = 0;
    else if (u_h.u_rx.st == 2'd3 && u_h.u_rx.div == 16'h0 && u_h.u_rx.bix == 2'd3 &&
             u_h.u_rx.w_valid && !u_h.u_rx.w_ready)
      n_drop = n_drop + 1;
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
    end else if (host_take)
      host_seen <= 1'b0;
    else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, extra;
  logic [31:0] got;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
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
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_word(output logic [31:0] g, input int maxc);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  task automatic tokname(input logic [31:0] g);
    begin
      if (g === 32'h0) $write("MUTE");
      else if (g === CLR_ACK) $write("ACK");
      else if (g === CLR_BUSY) $write("BUSY");
      else if (g === GOLD) $write("GOLD");
      else if (g === MAG) $write("MAG");
      else if (g === UNSUP) $write("UNSUP");
      else if (g === SENTINEL) $write("SENTINEL");
      else $write("OTHER_%08h", g);
    end
  endtask

  initial begin
    dest_stall = 1'b0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-V-04.mem");

    send_word(CLR_CMD);
    wait_word(got, 400000);
    $write("H12 ctrl CLEAR "); tokname(got); $display(" n_drop=%0d", n_drop);
    for (i = 0; i < nwords; i++)
      send_word(vec[i]);
    wait_word(got, 3_000_000);
    $write("H12 ctrl PACK "); tokname(got); $display("");

    for (extra = 1; extra <= 3; extra++) begin
      send_word(CLR_CMD);
      wait_word(got, 400000);
      $write("H12 pre extra=%0d CLEAR1 ", extra); tokname(got); $display("");
      for (i = 0; i < extra; i++)
        uart_byte(8'h00);
      send_word(CLR_CMD);
      wait_word(got, 400000);
      $write("H12 extra=%0d CLEAR2 ", extra); tokname(got);
      $display(" first_w=%08h n_drop=%0d ld_st=%0d", u_h.w_data, n_drop, u_h.u_ld.u_ld.state);
    end

    dest_stall = 1'b0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    n_drop = 0;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);

    dest_stall = 1'b1;
    n_drop = 0;
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $write("H12 overflow CLEAR "); tokname(got); $display("");
    for (i = 0; i < 140; i++)
      send_word(vec[i % nwords]);
    dest_stall = 1'b0;
    wait_word(got, 3_000_000);
    $write("H12 overflow PACK "); tokname(got);
    $display(" n_drop=%0d ld_st=%0d", n_drop, u_h.u_ld.u_ld.state);
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $write("H12 overflow post CLEAR "); tokname(got);
    $display(" ld_st=%0d qsc=%0b", u_h.u_ld.u_ld.state, u_h.qsc_ui);

    $display("H12_CLASS_A_XSIM done (not PACK_ABI_24_24_PASS / not BOARD_PASS)");
    $finish;
  end
endmodule
