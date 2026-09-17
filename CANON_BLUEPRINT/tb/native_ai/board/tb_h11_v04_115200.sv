// tb_h11_v04_115200.sv — H11 first CLEAR+V-04 at silicon baud 115200.
// Dual-clock harness, dest=mig_ui_bram not mig0.
// Probes: fifo write of CLEAR cmd, first loader word, pack_lock, reason.
// Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h11_v04_115200;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 115_200;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam int NLOOP  = 2;
  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] GOLD     = 32'h010000A5;
  localparam logic [31:0] UNSUP    = 32'h0200075A;
  localparam logic [31:0] MAG      = 32'h0200015A;

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

  integer n_cmd_fifo, n_p;
  logic [31:0] first_p;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      n_cmd_fifo = 0;
    else if (fifo_wr_fire && fifo_wr_data == CLR_CMD)
      n_cmd_fifo = n_cmd_fifo + 1;
  end
  always @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_p = 0;
      first_p <= 32'h0;
    end else if (p_fire) begin
      if (n_p == 0)
        first_p <= p_data;
      n_p = n_p + 1;
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
  int nwords, i, c, loop_i, n_gold, n_unsup, n_mag, n_mute, n_other;
  logic [31:0] got;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin
        $display("FAIL open %s", path);
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

  task automatic wait_word(output logic [31:0] g, input int maxc, output bit mute);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      mute = !host_seen;
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  bit mute;
  initial begin
    n_gold = 0;
    n_unsup = 0;
    n_mag = 0;
    n_mute = 0;
    n_other = 0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);

    load_mem("PA24-V-04.mem");
    $display("H11_115200 DIV=%0d nwords=%0d", DIV, nwords);

    for (loop_i = 0; loop_i < NLOOP; loop_i++) begin
      send_word(CLR_CMD);
      wait_word(got, 800000, mute);
      $display("H11 i=%0d CLEAR mute=%0d got=%08h n_cmd_fifo=%0d clr_st=%0d lock=%0b t=%0t",
               loop_i, mute, got, n_cmd_fifo, u_h.u_clr.st, u_h.pack_lock, $time);
      if (mute) begin
        n_mute = n_mute + 1;
        break;
      end
      if (got !== CLR_ACK) begin
        n_other = n_other + 1;
        continue;
      end
      send_word(vec[0]);
      for (i = 1; i < nwords; i++)
        send_word(vec[i]);
      wait_word(got, 8_000_000, mute);
      $display("H11 i=%0d PACK mute=%0d got=%08h first_p=%08h n_p=%0d reason=%02h lock=%0b t=%0t",
               loop_i, mute, got, first_p, n_p, reason_code, u_h.pack_lock, $time);
      if (mute)
        n_mute = n_mute + 1;
      else if (got === GOLD)
        n_gold = n_gold + 1;
      else if (got === UNSUP)
        n_unsup = n_unsup + 1;
      else if (got === MAG)
        n_mag = n_mag + 1;
      else
        n_other = n_other + 1;
    end

    if (n_unsup == 0 && n_mag == 0 && n_mute == 0 && n_gold == NLOOP)
      $display("H11_V04_115200_XSIM_GOLD_ONLY n=%0d (silicon first-pack UNSUP not in BRAM dualclk; not PACK_ABI_24_24_PASS)", n_gold);
    else
      $display("H11_V04_115200_XSIM_CLASS gold=%0d unsup=%0d mag=%0d mute=%0d other=%0d n_cmd_fifo=%0d",
               n_gold, n_unsup, n_mag, n_mute, n_other, n_cmd_fifo);
    $finish;
  end
endmodule
