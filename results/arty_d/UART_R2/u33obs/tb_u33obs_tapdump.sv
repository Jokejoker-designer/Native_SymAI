// TAP dump after freeze via dedicated CDC. GOLD has no TAP1. Not PACK_ABI.
`timescale 1ns/1ps

module tb_u33obs_tapdump;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam logic [31:0] DUMPW   = 32'h44554D50;
  localparam logic [31:0] TAP1    = 32'h31504154;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, uart_fire, fifo_wr_fire, fifo_rd_fire, cdc_a_fire, p_fire;
  logic dump_pulse, clr_event, load_ack, load_reject;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, cdc_a_data, p_data;
  logic [7:0] reason_code;

  logic arm_req, freeze_nak_100, ov, freeze, cap_v;
  logic armed_100, armed_ui, arm_p100, arm_pui, debug_clear_o, rearm_clear;
  logic [15:0] epoch_id;
  logic [3:0] freeze_reason;
  (* ASYNC_REG = "TRUE" *) logic c0, c1, cd;

  pack_obs_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data, .uart_fire,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data,
    .load_ack, .load_reject, .reason_code,
    .dump_pulse, .clr_event, .debug_clear_o,
    .freeze, .freeze_reason, .obs_arm_100(arm_p100), .obs_arm_ui(arm_pui),
    .obs_capture_valid(cap_v), .obs_epoch(epoch_id)
  );

  (* ASYNC_REG = "TRUE" *) logic nak0, nak1;
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin nak0 <= 1'b0; nak1 <= 1'b0; end
    else begin nak0 <= load_reject; nak1 <= nak0; end
  end
  assign freeze_nak_100 = nak1 && !freeze;
  assign ov = 1'b0;
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      c0 <= 1'b0; c1 <= 1'b0; cd <= 1'b0; rearm_clear <= 1'b0;
    end else begin
      c0 <= debug_clear_o;
      c1 <= c0;
      cd <= c1;
      rearm_clear <= (c1 && !cd && freeze);
    end
  end

  pack_obs_ctrl u_ctrl (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_req_100(arm_req), .freeze_nak(freeze_nak_100),
    .freeze_dump(dump_pulse), .overflow_any(ov), .rst_abort(1'b0),
    .rearm_clear,
    .epoch_id, .armed_100, .armed_ui, .arm_pulse_100(arm_p100), .arm_pulse_ui(arm_pui),
    .freeze, .freeze_reason, .capture_valid(cap_v)
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

  logic [31:0] vec [0:1023];
  int nwords, i, c, fail, logfd;
  logic [31:0] got, t0, t1, t2, t3, t4, t5, t6, t7, t8;
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
      rst100_n = 0; rst_ui_n = 0; uart_rx = 1; hq_r = 0; arm_req = 0;
      repeat (20) @(posedge clk100);
      rst100_n = 1; rst_ui_n = 1;
      repeat (40) @(posedge clk100);
      force u_h.calib_ui = 1'b1;
    end
  endtask

  initial begin
    fail = 0;
    logfd = $fopen("u33obs_tapdump.log", "w");
    dut_reset;
    begin
      int fd;
      fd = $fopen("PA24-V-04.mem", "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end

    arm_obs;
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL leftover CLEAR %08h", got)); fail = 1; end
    send_word(BEGINW);
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== MAG) begin log1($sformatf("FAIL leftover MAG %08h", got)); fail = 1; end
    wait_word(t0, 400000, mute);
    wait_word(t1, 400000, mute);
    wait_word(t2, 400000, mute);
    wait_word(t3, 400000, mute);
    wait_word(t4, 400000, mute);
    wait_word(t5, 400000, mute);
    wait_word(t6, 400000, mute);
    wait_word(t7, 400000, mute);
    wait_word(t8, 400000, mute);
    log1($sformatf("MAG_TAP TAP1=%08h u0=%08h u1=%08h l0=%08h l1=%08h gen=%08h before=%08h after=%08h",
                   t0, t1, t2, t3, t4, t6, t7, t8));
    if (t0 !== TAP1) begin log1("FAIL leftover TAP1"); fail = 1; end
    if (t1 !== CLR_CMD || t2 !== BEGINW) begin log1("FAIL leftover TAP uart"); fail = 1; end
    if (t3 !== BEGINW || t4 !== BEGINW) begin log1("FAIL leftover TAP load CLASS_A"); fail = 1; end
    else log1("TAP_CLASS_A dump-after-NAK p0=p1=BEGIN first_divergent=p1");
    if (t6[31:24] !== 8'h47) begin log1("FAIL leftover GEN magic"); fail = 1; end
    if (t6[16] !== 1'b0) begin log1("FAIL leftover invented generation_flipped"); fail = 1; end

    dut_reset;
    arm_obs;
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL dump CLEAR %08h", got)); fail = 1; end
    send_word(DUMPW);
    wait_word(t0, 400000, mute);
    wait_word(t1, 400000, mute);
    wait_word(t2, 400000, mute);
    wait_word(t3, 400000, mute);
    wait_word(t4, 400000, mute);
    wait_word(t5, 400000, mute);
    wait_word(t6, 400000, mute);
    wait_word(t7, 400000, mute);
    wait_word(t8, 400000, mute);
    log1($sformatf("DUMP_TAP TAP1=%08h u0=%08h u1=%08h l0=%08h l1=%08h nak=%0b fr=%0d gen=%08h",
                   t0, t1, t2, t3, t4, load_reject, freeze_reason, t6));
    if (t0 !== TAP1) begin log1("FAIL dump TAP1"); fail = 1; end
    if (t1 !== CLR_CMD || t2 !== DUMPW) begin log1("FAIL dump TAP uart CLEAR/DUMP"); fail = 1; end
    if (t3 !== 32'h0 || t4 !== 32'h0) begin log1("FAIL dump TAP load not empty"); fail = 1; end
    if (load_reject) begin log1("FAIL dump NAK"); fail = 1; end
    if (freeze_reason != 4'd3) begin log1("FAIL dump FR"); fail = 1; end
    if (t6[16] !== 1'b0) begin log1("FAIL dump invented generation_flipped"); fail = 1; end
    else log1("TAP_DUMP_MUTE freeze_reason=3 no NAK dedicated CDC");

    dut_reset;
    arm_obs;
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL gold CLEAR %08h", got)); fail = 1; end
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin log1($sformatf("FAIL GOLD %08h", got)); fail = 1; end
    mute = 1;
    wait_word(t0, 80000, mute);
    log1($sformatf("GOLD_TAP extra=%08h mute=%0d fr=%0d", t0, mute, freeze_reason));
    if (!mute || t0 === TAP1) begin log1("FAIL GOLD emitted TAP1"); fail = 1; end
    else log1("GOLD_NO_TAP_DUMP");

    send_word(DUMPW);
    wait_word(t0, 400000, mute);
    wait_word(t1, 400000, mute);
    wait_word(t2, 400000, mute);
    wait_word(t3, 400000, mute);
    wait_word(t4, 400000, mute);
    wait_word(t5, 400000, mute);
    wait_word(t6, 400000, mute);
    wait_word(t7, 400000, mute);
    wait_word(t8, 400000, mute);
    log1($sformatf("GOLD_DUMP_GEN TAP1=%08h stat=%08h before=%08h after=%08h", t0, t6, t7, t8));
    if (t0 !== TAP1) begin log1("FAIL GOLD DUMP TAP1"); fail = 1; end
    if (t6[31:24] !== 8'h47) begin log1("FAIL GOLD GEN magic"); fail = 1; end
    if (t6[19] !== 1'b1) begin log1("FAIL GOLD commit_event unseen"); fail = 1; end
    if (t6[18] !== 1'b1) begin log1("FAIL GOLD same_capture_epoch"); fail = 1; end
    if (t6[17] !== 1'b1) begin log1("FAIL GOLD capture_valid_at"); fail = 1; end
    if (t6[16] !== 1'b1) begin log1("FAIL GOLD generation_flipped four-AND"); fail = 1; end
    if (t7 === t8) begin log1("FAIL GOLD before==after idle snapshots"); fail = 1; end
    else log1("GOLD_DUMP four-AND generation_flipped Pack-owner COMMIT");

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL rearm CLEAR %08h", got)); fail = 1; end
    c = 0;
    while (c < 40000 && (freeze || !cap_v)) begin
      @(posedge clk100);
      c = c + 1;
    end
    if (freeze || !cap_v) begin log1($sformatf("FAIL CLEAR did not re-arm freeze=%0d cap=%0d", freeze, cap_v)); fail = 1; end
    else log1("CLEAR_REARM freeze=0 capture_valid=1");
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin log1($sformatf("FAIL GOLD2 %08h", got)); fail = 1; end
    send_word(DUMPW);
    wait_word(t0, 400000, mute);
    wait_word(t1, 400000, mute);
    wait_word(t2, 400000, mute);
    wait_word(t3, 400000, mute);
    wait_word(t4, 400000, mute);
    wait_word(t5, 400000, mute);
    wait_word(t6, 400000, mute);
    wait_word(t7, 400000, mute);
    wait_word(t8, 400000, mute);
    log1($sformatf("GOLD2_DUMP_GEN TAP1=%08h stat=%08h before=%08h after=%08h", t0, t6, t7, t8));
    if (t0 !== TAP1) begin log1("FAIL GOLD2 DUMP TAP1"); fail = 1; end
    if (t6[31:24] !== 8'h47) begin log1("FAIL GOLD2 GEN magic"); fail = 1; end
    if (t6[19] !== 1'b1) begin log1("FAIL GOLD2 commit_event unseen"); fail = 1; end
    if (t6[18] !== 1'b1) begin log1("FAIL GOLD2 same_capture_epoch"); fail = 1; end
    if (t6[17] !== 1'b1) begin log1("FAIL GOLD2 capture_valid_at"); fail = 1; end
    if (t6[16] !== 1'b1) begin log1("FAIL GOLD2 generation_flipped four-AND"); fail = 1; end
    if (t7 === t8) begin log1("FAIL GOLD2 before==after"); fail = 1; end
    else log1("GOLD2_DUMP four-AND after CLEAR re-arm");

    log1("PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO");
    if (fail) log1("FAIL");
    else log1("PASS_XSIM TAP dump CDC leftover CLASS_A + DUMP-without-NAK + GOLD_NO_TAP + GOLD four-AND + CLEAR re-arm GOLD2 four-AND");
    $fclose(logfd);
    $finish;
  end
endmodule
