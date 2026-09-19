// Scratch TB: leftover GOLD source hunt. Dest=mig_ui_bram. Not PACK_ABI_24_24_PASS.
// L2 first: pulse TX CDC b-reset after Phase4 GOLD, no CLEAR (drain-replay?).
// L1: dest_stall CLEAR, force ack_d=0 while clr_ack_valid (BUSY), score mux leftover.
`timescale 1ns/1ps

module tb_u31_leftover_gold_hunt;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD     = 32'h010000A5;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  logic dest_stall;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, fifo_wr_fire, fifo_rd_fire, p_fire;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, p_data;
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
  int nwords, i, c, nw;
  logic [31:0] got;
  logic [31:0] capw [0:7];
  bit mute;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) nwords = 0;
      else begin
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
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_word(output logic [31:0] g, input int maxc, output bit m);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      m = !host_seen;
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  task automatic score_words(input string tag);
    begin
      nw = 0;
      for (i = 0; i < 8; i++) begin
        wait_word(got, 200000, mute);
        if (mute)
          break;
        capw[nw] = got;
        nw = nw + 1;
        $display("%s_WORD %0d %08h", tag, nw, got);
      end
      if (nw == 0)
        $display("UART_R2_U31_LEFTOVER_SCORE %s MUTE", tag);
      else if (nw == 1 && capw[0] === CLR_BUSY)
        $display("UART_R2_U31_LEFTOVER_SCORE %s BUSY_N4_NO_GOLD", tag);
      else if (nw >= 2 && capw[0] === CLR_BUSY && capw[1] === GOLD)
        $display("UART_R2_U31_LEFTOVER_SCORE %s BUSY_THEN_GOLD_N8", tag);
      else if (nw == 1 && capw[0] === CLR_ACK)
        $display("UART_R2_U31_LEFTOVER_SCORE %s ACK", tag);
      else if (nw >= 1 && capw[0] === GOLD)
        $display("UART_R2_U31_LEFTOVER_SCORE %s GOLD_ONLY nw=%0d", tag, nw);
      else
        $display("UART_R2_U31_LEFTOVER_SCORE %s OTHER nw=%0d w0=%08h", tag, nw, capw[0]);
    end
  endtask

  initial begin
    dest_stall = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U31_LEFTOVER_XSIM_FAIL CLEAR1 got=%08h", got);
      $finish;
    end
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin
      $display("UART_R2_U31_LEFTOVER_XSIM_FAIL V04_0 got=%08h", got);
      $finish;
    end
    $display("PHASE4_GOLD load_ack=%0b ack_d=%0b st_valid_ui=%0b st_valid_100=%0b req_a=%0b last_b=%0b",
             load_ack, u_h.ack_d, u_h.st_valid_ui, u_h.st_valid_100,
             u_h.u_cdc_tx.req_a, u_h.u_cdc_tx.last_b);

    $display("L2_PRE req_a=%0b last_b=%0b rst100_tx_b_n=%0b tx_b_idle=%0b",
             u_h.u_cdc_tx.req_a, u_h.u_cdc_tx.last_b, u_h.rst100_tx_b_n, u_h.tx_b_idle);
    force u_h.rst100_tx_b_n = 1'b0;
    repeat (8) @(posedge clk100);
    release u_h.rst100_tx_b_n;
    repeat (16) @(posedge clk100);
    $display("L2_AFTER_PULSE rst100_tx_b_n=%0b st_valid_100=%0b req_a=%0b last_b=%0b",
             u_h.rst100_tx_b_n, u_h.st_valid_100, u_h.u_cdc_tx.req_a, u_h.u_cdc_tx.last_b);
    score_words("L2");

    dest_stall = 1'b1;
    repeat (64) @(posedge ui_clk);
    repeat (32) @(posedge clk100);

    fork
      send_word(CLR_CMD);
      begin
        c = 0;
        while (!u_h.clr_ack_valid && (c < 200000)) begin
          @(posedge clk100);
          c = c + 1;
        end
      end
    join
    $display("L1_AT_ACKV st=%0d clr_ack_data=%08h load_ack=%0b ack_d=%0b",
             u_h.u_clr.st, u_h.clr_ack_data, load_ack, u_h.ack_d);
    force u_h.ack_d = 1'b0;
    repeat (2) @(posedge ui_clk);
    release u_h.ack_d;
    $display("L1_AFTER_FORCE ack_d=%0b st_valid_ui=%0b st_valid_100=%0b",
             u_h.ack_d, u_h.st_valid_ui, u_h.st_valid_100);
    score_words("L1");

    $display("UART_R2_U31_LEFTOVER_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $finish;
  end
endmodule
