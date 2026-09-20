// UART steer A-03: BEGIN 00840001 (len 132) vs pack_begin exact 00800001.
// Gold LOAD_REJECT reason 9 / 0200095a. Not PACK_ABI. PROGRAM=NO.
`timescale 1ns/1ps

module tb_u33obs_a03_steer;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] NAK9    = 32'h0200095A;
  localparam logic [31:0] BEGIN132 = 32'h00840001;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, uart_fire, fifo_wr_fire, fifo_rd_fire, cdc_a_fire, p_fire;
  logic dump_pulse, clr_event, load_ack, load_reject;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, cdc_a_data, p_data;
  logic [7:0] reason_code;
  logic freeze;
  logic [3:0] freeze_reason;
  logic arm_p100, arm_pui, cap_v;
  logic [15:0] epoch_id;

  pack_obs_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data, .uart_fire,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data,
    .load_ack, .load_reject, .reason_code,
    .dump_pulse, .clr_event,
    .freeze, .freeze_reason, .obs_arm_100(arm_p100), .obs_arm_ui(arm_pui),
    .obs_capture_valid(cap_v), .obs_epoch(epoch_id)
  );

  logic host_valid;
  logic [31:0] host_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(1'b1), .w_data(host_data)
  );
  logic [31:0] hq [0:63];
  int hq_w, hq_r;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) hq_w <= 0;
    else if (host_valid && hq_w < 64) begin
      hq[hq_w] <= host_data;
      hq_w <= hq_w + 1;
    end
  end

  int n_p;
  logic [31:0] p0;
  always @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_p <= 0;
      p0 <= 32'h0;
    end else if (p_fire) begin
      if (n_p == 0) p0 <= p_data;
      n_p <= n_p + 1;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, fail, logfd;
  logic [31:0] got;
  bit mute;
  bit want_nak;

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
    want_nak = $test$plusargs("EXPECT_NAK");
    logfd = $fopen("u33obs_a03_steer.log", "w");
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1; hq_r = 0;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    begin
      int fd;
      fd = $fopen("PA24-A-03.mem", "r");
      if (fd == 0) begin
        log1("FAIL missing PA24-A-03.mem");
        fail = 1;
        $fclose(logfd);
        $finish;
      end
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end
    if (nwords < 1 || vec[0] !== BEGIN132) begin
      log1($sformatf("FAIL mem[0]=%08h want 00840001 n=%0d", vec[0], nwords));
      fail = 1;
    end

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      log1($sformatf("FAIL CLEAR %08h mute=%0d", got, mute));
      fail = 1;
    end else log1("CLEAR_ACK");

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    log1($sformatf("A03_STATUS mute=%0d got=%08h n_p=%0d p0=%08h reason=%02h want_nak=%0d",
                   mute, got, n_p, p0, reason_code, want_nak));

    if (want_nak) begin
      if (mute || got !== NAK9) begin
        log1($sformatf("FAIL expect NAK9 0200095a got mute=%0d %08h", mute, got));
        fail = 1;
      end else if (n_p == 0 || p0 !== BEGIN132) begin
        log1($sformatf("FAIL loader p0=%08h n_p=%0d want 00840001", p0, n_p));
        fail = 1;
      end else log1("PASS_XSIM A-03 UART steer OP_BEGIN NAK reason 9");
    end else begin
      if (!mute) begin
        log1($sformatf("FAIL expect MUTE got %08h (exact BEGIN gate not dropping 00840001?)", got));
        fail = 1;
      end else if (n_p != 0) begin
        log1($sformatf("FAIL MUTE but n_p=%0d p0=%08h", n_p, p0));
        fail = 1;
      end else log1("PASS_XSIM A-03 UART exact-BEGIN 00800001 MUTE loader empty");
    end

    log1("PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO");
    if (fail) log1("FAIL");
    else log1(want_nak ? "PASS_XSIM A03_STEER_NAK9" : "PASS_XSIM A03_STEER_MUTE");
    $fclose(logfd);
    $finish;
  end
endmodule
