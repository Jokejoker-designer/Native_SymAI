// tb_h17_mig_stall.sv — dest stall stand-in for mig0 not-ready.
// TB-only dest_stall on mig_ui_bram. Not generated mig0. Not MIG_PASS.
// Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h17_mig_stall;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD = 32'h010000A5;
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
  int nwords, i, c;
  logic [31:0] got;
  int n_busy, n_ack, n_gold, n_sen, n_mute, n_other;

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

  task automatic class_tok(input logic [31:0] g, input bit mute);
    begin
      if (mute) n_mute = n_mute + 1;
      else if (g === CLR_BUSY) n_busy = n_busy + 1;
      else if (g === CLR_ACK) n_ack = n_ack + 1;
      else if (g === GOLD) n_gold = n_gold + 1;
      else if (g === SENTINEL) n_sen = n_sen + 1;
      else n_other = n_other + 1;
    end
  endtask

  initial begin
    n_busy = 0; n_ack = 0; n_gold = 0; n_sen = 0; n_mute = 0; n_other = 0;
    dest_stall = 1'b0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);

    load_mem("PA24-V-04.mem");

    dest_stall = 1'b1;
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $display("STALL idle CLEAR got=%08h qsc=%0b out=%0d ui_busy=%0b ld_busy=%0b st=%0d",
             got, u_h.qsc_ui, u_h.wr_outstanding, u_h.pack_busy, u_h.u_ld.loader_busy, u_h.u_ld.u_ld.state);
    class_tok(got, got === 32'h0);

    dest_stall = 1'b0;
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $display("STALL release idle CLEAR got=%08h", got);
    class_tok(got, got === 32'h0);

    for (i = 0; i < 12 && i < nwords; i++)
      send_word(vec[i]);
    dest_stall = 1'b1;
    repeat (200) @(posedge ui_clk);
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $display("STALL midpack CLEAR got=%08h qsc=%0b out=%0d ui_busy=%0b ld_busy=%0b st=%0d reason=%02h",
             got, u_h.qsc_ui, u_h.wr_outstanding, u_h.pack_busy, u_h.u_ld.loader_busy, u_h.u_ld.u_ld.state, reason_code);
    class_tok(got, got === 32'h0);

    dest_stall = 1'b0;
    wait_word(got, 3_000_000);
    $display("STALL after release leftover tok got=%08h (may be pack status or mute)", got);
    if (got === 32'h0)
      n_mute = n_mute + 1;
    else
      class_tok(got, 1'b0);

    send_word(CLR_CMD);
    wait_word(got, 400000);
    $display("STALL post-release CLEAR got=%08h qsc=%0b out=%0d ld_busy=%0b st=%0d",
             got, u_h.qsc_ui, u_h.wr_outstanding, u_h.u_ld.loader_busy, u_h.u_ld.u_ld.state);
    class_tok(got, got === 32'h0);

    dest_stall = 1'b0;
    send_word(CLR_CMD);
    wait_word(got, 400000);
    $display("STALL drain CLEAR got=%08h", got);
    if (got === CLR_ACK) begin
      load_mem("PA24-V-03.mem");
      for (i = 0; i < nwords; i++) begin
        send_word(vec[i]);
        if ((i % 4) == 0) dest_stall = 1'b1;
        else dest_stall = 1'b0;
      end
      dest_stall = 1'b0;
      wait_word(got, 3_000_000);
      $display("STALL 25pct V-03 PACK got=%08h reason=%02h", got, reason_code);
      class_tok(got, got === 32'h0);
    end

    $display("H17_MIG_STALL_XSIM ack=%0d busy=%0d gold=%0d sen=%0d mute=%0d other=%0d (not PACK_ABI_24_24_PASS / not MIG_PASS / not BOARD_PASS)",
             n_ack, n_busy, n_gold, n_sen, n_mute, n_other);
    $finish;
  end
endmodule
