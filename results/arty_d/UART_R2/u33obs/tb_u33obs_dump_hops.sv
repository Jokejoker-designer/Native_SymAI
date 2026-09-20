// DUMP-without-NAK + leftover MAG multi-lane. Not overlay U33. Not PACK_ABI.
`timescale 1ns/1ps

module tb_u33obs_dump_hops;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam logic [31:0] DUMPW   = 32'h44554D50;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, uart_fire, fifo_wr_fire, fifo_rd_fire, cdc_a_fire, p_fire;
  logic dump_pulse, clr_event, load_ack, load_reject;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, cdc_a_data, p_data;
  logic [7:0] reason_code;

  pack_obs_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data, .uart_fire,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data,
    .load_ack, .load_reject, .reason_code,
    .dump_pulse, .clr_event
  );

  logic arm_req, freeze_nak_100, ov, freeze, cap_v;
  logic armed_100, armed_ui, arm_p100, arm_pui;
  logic [15:0] epoch_id;
  logic [3:0] freeze_reason;
  (* ASYNC_REG = "TRUE" *) logic nak0, nak1;
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin nak0 <= 1'b0; nak1 <= 1'b0; end
    else begin nak0 <= load_reject; nak1 <= nak0; end
  end
  assign freeze_nak_100 = nak1 && !freeze;

  pack_obs_ctrl u_ctrl (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_req_100(arm_req), .freeze_nak(freeze_nak_100),
    .freeze_dump(dump_pulse), .overflow_any(ov), .rst_abort(1'b0),
    .epoch_id, .armed_100, .armed_ui, .arm_pulse_100(arm_p100), .arm_pulse_ui(arm_pui),
    .freeze, .freeze_reason, .capture_valid(cap_v)
  );

  logic freeze_ui0, freeze_ui;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin freeze_ui0 <= 1'b0; freeze_ui <= 1'b0; end
    else begin freeze_ui0 <= freeze; freeze_ui <= freeze_ui0; end
  end

  logic [8:0] n_uart, n_fw, n_fr, n_ca, n_cb, n_ld;
  logic rd_u, rd_l;
  logic [7:0] rd_ua, rd_la;
  logic [111:0] rd_uart, rd_load;

  pack_obs_hops u_hops (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_100(arm_p100), .arm_ui(arm_pui),
    .armed_100, .armed_ui, .freeze_100(freeze), .freeze_ui,
    .epoch_id, .uart_fire, .uart_data(w_data),
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data, .clr_event,
    .overflow(ov), .n_uart, .n_fifo_wr(n_fw), .n_fifo_rd(n_fr),
    .n_cdc_a(n_ca), .n_cdc_b(n_cb), .n_load(n_ld),
    .rd_uart_en(rd_u), .rd_uart_addr(rd_ua), .rd_uart,
    .rd_load_en(rd_l), .rd_load_addr(rd_la), .rd_load
  );

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
  logic [31:0] got, p0, p1, u0, u1;
  bit mute;
  logic [8:0] n_ld_freeze, n_uart_freeze, n_fw_freeze;

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

  task automatic arm_obs;
    begin
      arm_req = 1;
      @(posedge clk100);
      arm_req = 0;
      c = 0;
      while (c < 80 && (!armed_100 || !armed_ui || !cap_v)) begin
        @(posedge clk100);
        c = c + 1;
      end
    end
  endtask

  task automatic dut_reset;
    begin
      rst100_n = 0;
      rst_ui_n = 0;
      uart_rx = 1;
      hq_r = 0;
      arm_req = 0;
      rd_u = 0;
      rd_l = 0;
      rd_ua = 0;
      rd_la = 0;
      repeat (20) @(posedge clk100);
      rst100_n = 1;
      rst_ui_n = 1;
      repeat (40) @(posedge clk100);
      force u_h.calib_ui = 1'b1;
    end
  endtask

  task automatic read_uart_word(input logic [7:0] addr, output logic [31:0] dw);
    begin
      rd_u = 1;
      rd_ua = addr;
      @(posedge clk100);
      @(posedge clk100);
      dw = rd_uart[47:16];
      rd_u = 0;
    end
  endtask

  task automatic read_load_word(input logic [7:0] addr, output logic [31:0] dw);
    begin
      rd_l = 1;
      rd_la = addr;
      @(posedge ui_clk);
      @(posedge ui_clk);
      dw = rd_load[47:16];
      rd_l = 0;
    end
  endtask

  initial begin
    fail = 0;
    logfd = $fopen("u33obs_dump_hops.log", "w");
    dut_reset;
    begin
      int fd;
      fd = $fopen("PA24-V-04.mem", "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end

    // ---- leftover MAG multi-lane (CLASS_A) ----
    arm_obs;
    if (!cap_v) begin log1("FAIL leftover arm"); fail = 1; end
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      log1($sformatf("FAIL leftover CLEAR %08h", got));
      fail = 1;
    end
    send_word(BEGINW);
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    repeat (8) @(posedge ui_clk);
    log1($sformatf("LEFTOVER mute=%0d got=%08h fr=%0d n_uart=%0d n_fw=%0d n_fr=%0d n_ca=%0d n_cb=%0d n_ld=%0d",
                   mute, got, freeze_reason, n_uart, n_fw, n_fr, n_ca, n_cb, n_ld));
    if (mute || got !== MAG) begin log1("FAIL leftover MAG"); fail = 1; end
    if (freeze_reason != 4'd1) begin
      log1($sformatf("FAIL leftover freeze_reason %0d", freeze_reason));
      fail = 1;
    end
    if (n_ld < 9'd2) begin log1("FAIL leftover n_ld<2"); fail = 1; end
    read_load_word(8'd0, p0);
    read_load_word(8'd1, p1);
    log1($sformatf("LOADER p0=%08h p1=%08h", p0, p1));
    if (p0 !== BEGINW || p1 !== BEGINW) begin
      log1("FAIL leftover hops p0/p1 not BEGIN/BEGIN");
      fail = 1;
    end else
      log1("HOPS_CLASS_A loader p0=BEGIN p1=BEGIN first_divergent=p1");
    read_uart_word(8'd0, u0);
    read_uart_word(8'd1, u1);
    log1($sformatf("UART leftover u0=%08h u1=%08h", u0, u1));
    if (u0 !== CLR_CMD || u1 !== BEGINW) begin
      log1("FAIL leftover uart not CLEAR then BEGIN");
      fail = 1;
    end

    // ---- DUMP-without-NAK on a fresh epoch ----
    dut_reset;
    arm_obs;
    if (!cap_v) begin log1("FAIL dump arm"); fail = 1; end
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      log1($sformatf("FAIL dump CLEAR %08h", got));
      fail = 1;
    end
    send_word(DUMPW);
    repeat (40) @(posedge clk100);
    n_ld_freeze = n_ld;
    n_uart_freeze = n_uart;
    n_fw_freeze = n_fw;
    log1($sformatf("DUMP fr=%0d nak=%0b n_uart=%0d n_fw=%0d n_ld=%0d",
                   freeze_reason, load_reject, n_uart, n_fw, n_ld));
    if (freeze_reason != 4'd3) begin
      log1($sformatf("FAIL dump freeze_reason %0d", freeze_reason));
      fail = 1;
    end
    if (load_reject) begin log1("FAIL dump caused NAK"); fail = 1; end
    if (n_fw != 9'd0) begin log1("FAIL DUMP entered FIFO"); fail = 1; end
    if (n_ld != 9'd0) begin log1("FAIL DUMP reached loader"); fail = 1; end
    if (n_uart < 9'd2) begin log1("FAIL dump n_uart<2"); fail = 1; end
    read_uart_word(8'd0, u0);
    read_uart_word(8'd1, u1);
    log1($sformatf("UART dump u0=%08h u1=%08h", u0, u1));
    if (u0 !== CLR_CMD || u1 !== DUMPW) begin
      log1("FAIL dump uart not CLEAR then DUMP");
      fail = 1;
    end
    send_word(BEGINW);
    repeat (40) @(posedge clk100);
    if (n_ld != n_ld_freeze || n_uart != n_uart_freeze || n_fw != n_fw_freeze) begin
      log1($sformatf("FAIL dump freeze n_ld %0d->%0d n_uart %0d->%0d n_fw %0d->%0d",
                     n_ld_freeze, n_ld, n_uart_freeze, n_uart, n_fw_freeze, n_fw));
      fail = 1;
    end else
      log1("DUMP_MUTE_CLASS freeze_reason=3 no NAK n_ev held DUMP not in FIFO");

    log1($sformatf("PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO"));
    if (fail) log1("FAIL");
    else log1("PASS_XSIM dump-without-NAK hops UART/FIFO/CDC/LOADER leftover CLASS_A");
    $fclose(logfd);
    $finish;
  end
endmodule
