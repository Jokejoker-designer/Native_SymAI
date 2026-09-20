// Observe leftover MAG via pack_hop_log on frozen U32 harness p_fire.
// Does not overlay U33. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_u33obs_leftover_hoplog;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] BEGINW  = 32'h00800001;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
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
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code
  );

  logic [8:0] n_ev, wr_ptr;
  logic [31:0] last_mask, last_data;
  pack_hop_log #(.DEPTH(64)) u_log (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .clr_event(1'b0),
    .uart_fire(1'b0), .uart_data(32'h0),
    .fifo_wr_fire(1'b0), .fifo_wr_data(32'h0),
    .fifo_rd_fire(1'b0), .fifo_rd_data(32'h0),
    .cdc_a_fire(1'b0), .cdc_a_data(32'h0),
    .cdc_b_fire(1'b0), .cdc_b_data(32'h0),
    .load_fire(p_fire), .load_data(p_data),
    .ack_event(1'b0), .nak_event(load_reject), .reason_code,
    .n_ev, .wr_ptr, .last_mask, .last_data
  );

  logic [31:0] ld [0:7];
  int n_ld;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) n_ld <= 0;
    else if (p_fire && n_ld < 8) begin
      ld[n_ld] <= p_data;
      n_ld <= n_ld + 1;
    end
  end

  logic host_valid;
  logic [31:0] host_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(1'b1), .w_data(host_data)
  );
  logic [31:0] hq [0:31];
  int hq_w, hq_r;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) hq_w <= 0;
    else if (host_valid && hq_w < 32) begin
      hq[hq_w] <= host_data;
      hq_w <= hq_w + 1;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, fail, logfd;
  logic [31:0] got;
  bit mute;

  task automatic log1(input string s);
    begin
      $display("%s", s);
      $fdisplay(logfd, "%s", s);
      $fflush(logfd);
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
      while (c < maxc && hq_r >= hq_w) begin
        @(posedge clk100);
        c = c + 1;
      end
      m = (hq_r >= hq_w);
      g = m ? 32'h0 : hq[hq_r];
      if (!m) hq_r = hq_r + 1;
    end
  endtask

  initial begin
    fail = 0;
    logfd = $fopen("u33obs_leftover_hoplog.log", "w");
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1; hq_r = 0;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    begin
      int fd;
      fd = $fopen("PA24-V-04.mem", "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      log1($sformatf("FAIL CLEAR %08h", got));
      fail = 1;
    end
    send_word(BEGINW);
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    log1($sformatf("STATUS mute=%0d got=%08h n_ld=%0d p0=%08h p1=%08h n_ev=%0d PACK_ABI_24_24_PASS=NO",
                   mute, got, n_ld, ld[0], ld[1], n_ev));
    if (mute || got !== MAG) begin
      log1("FAIL MAG");
      fail = 1;
    end
    if (n_ld < 2 || ld[0] !== BEGINW || ld[1] !== BEGINW) begin
      log1("FAIL hop_log loader p0/p1 not BEGIN/BEGIN");
      fail = 1;
    end else
      log1("HOPLOG_CLASS_A p_fire p0=BEGIN p1=BEGIN first_divergent=p1");
    if (n_ev == 0) begin
      log1("FAIL n_ev=0");
      fail = 1;
    end
    if (fail) log1("FAIL");
    else log1("PASS_XSIM leftover hop_log CLASS_A");
    $fclose(logfd);
    $finish;
  end
endmodule
