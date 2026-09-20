// 9-lane leftover MAG + DUMP-without-NAK + GOLD COMMIT four-AND. Not PACK_ABI.
`timescale 1ns/1ps

module tb_u33obs_9lane;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam logic [31:0] DUMPW   = 32'h44554D50;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, uart_fire, fifo_wr_fire, fifo_rd_fire, cdc_a_fire, p_fire;
  logic dump_pulse, clr_event, load_ack, load_reject;
  logic ctrl_fire, state_fire, term_fire, commit_pulse, debug_clear_o;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, cdc_a_data, p_data;
  logic [31:0] ctrl_data, state_data, term_data, active_generation;
  logic [15:0] ctrl_flags, state_flags, term_flags;
  logic [7:0] reason_code;

  pack_obs_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data, .uart_fire,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data,
    .load_ack, .load_reject, .reason_code,
    .dump_pulse, .clr_event,
    .ctrl_fire, .ctrl_data, .ctrl_flags,
    .state_fire, .state_data, .state_flags,
    .term_fire, .term_data, .term_flags,
    .commit_pulse, .active_generation, .debug_clear_o
  );

  logic arm_req, freeze_nak_100, ov, freeze, cap_v;
  logic armed_100, armed_ui, arm_p100, arm_pui;
  logic [15:0] epoch_id, epoch_ui;
  logic [3:0] freeze_reason;
  (* ASYNC_REG = "TRUE" *) logic nak0, nak1, cv0, cv_ui;
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
    if (!rst_ui_n) begin
      freeze_ui0 <= 1'b0; freeze_ui <= 1'b0; cv0 <= 1'b0; cv_ui <= 1'b0; epoch_ui <= 16'h0;
    end else begin
      freeze_ui0 <= freeze; freeze_ui <= freeze_ui0;
      cv0 <= cap_v; cv_ui <= cv0;
      if (arm_pui) epoch_ui <= epoch_id;
    end
  end

  logic commit_event, same_ep, flip_present, gen_flip;
  logic [31:0] gbefore, gafter;
  pack_obs_gen u_gen (
    .clk(ui_clk), .rst_n(rst_ui_n), .capture_valid(cv_ui), .epoch_id(epoch_ui),
    .debug_clear(debug_clear_o), .commit_pulse, .active_generation,
    .commit_event, .generation_before(gbefore), .generation_after(gafter),
    .same_capture_epoch(same_ep), .flip_present, .generation_flipped(gen_flip)
  );

  logic [8:0] n_uart, n_fw, n_fr, n_ca, n_cb, n_ld, n_ctrl, n_state, n_term;
  logic rd_u, rd_l, rd_t;
  logic [7:0] rd_ua, rd_la, rd_ta;
  logic [111:0] rd_uart, rd_load, rd_term;

  pack_obs_9lane u_9 (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_100(arm_p100), .arm_ui(arm_pui),
    .armed_100, .armed_ui, .freeze_100(freeze), .freeze_ui,
    .epoch_id, .uart_fire, .uart_data(w_data),
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data, .p_fire, .p_data, .clr_event,
    .ctrl_fire, .ctrl_data, .ctrl_flags,
    .state_fire, .state_data, .state_flags,
    .term_fire, .term_data, .term_flags,
    .overflow(ov), .n_uart, .n_fifo_wr(n_fw), .n_fifo_rd(n_fr),
    .n_cdc_a(n_ca), .n_cdc_b(n_cb), .n_load(n_ld),
    .n_ctrl, .n_state, .n_term,
    .rd_uart_en(rd_u), .rd_uart_addr(rd_ua), .rd_uart,
    .rd_load_en(rd_l), .rd_load_addr(rd_la), .rd_load,
    .rd_term_en(rd_t), .rd_term_addr(rd_ta), .rd_term
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
  logic [31:0] got, p0, p1, t0;
  bit mute;
  logic [8:0] n_uart_fr, n_fw_fr, n_ld_fr;
  logic [15:0] tflags;

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
      rd_u = 0; rd_l = 0; rd_t = 0; rd_ua = 0; rd_la = 0; rd_ta = 0;
      repeat (20) @(posedge clk100);
      rst100_n = 1; rst_ui_n = 1;
      repeat (40) @(posedge clk100);
      force u_h.calib_ui = 1'b1;
    end
  endtask

  task automatic read_load_word(input logic [7:0] addr, output logic [31:0] dw);
    begin
      rd_l = 1; rd_la = addr;
      @(posedge ui_clk); @(posedge ui_clk);
      dw = rd_load[47:16];
      rd_l = 0;
    end
  endtask

  task automatic read_term0(output logic [31:0] dw, output logic [15:0] fl);
    begin
      rd_t = 1; rd_ta = 8'd0;
      @(posedge ui_clk); @(posedge ui_clk);
      dw = rd_term[47:16];
      fl = rd_term[15:0];
      rd_t = 0;
    end
  endtask

  initial begin
    fail = 0;
    logfd = $fopen("u33obs_9lane.log", "w");
    dut_reset;
    begin
      int fd;
      fd = $fopen("PA24-V-04.mem", "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end

    // leftover MAG: NAK terminal, no COMMIT flip
    arm_obs;
    if (!cap_v) begin log1("FAIL leftover arm"); fail = 1; end
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL leftover CLEAR %08h", got)); fail = 1; end
    send_word(BEGINW);
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    repeat (8) @(posedge ui_clk);
    log1($sformatf("LEFTOVER got=%08h fr=%0d n_ctrl=%0d n_state=%0d n_term=%0d n_ld=%0d flip=%0d present=%0d",
                   got, freeze_reason, n_ctrl, n_state, n_term, n_ld, gen_flip, flip_present));
    if (mute || got !== MAG) begin log1("FAIL leftover MAG"); fail = 1; end
    if (n_ctrl == 0) begin log1("FAIL leftover n_ctrl=0"); fail = 1; end
    if (n_state == 0) begin log1("FAIL leftover n_state=0"); fail = 1; end
    if (n_term == 0) begin log1("FAIL leftover n_term=0"); fail = 1; end
    if (flip_present || gen_flip) begin log1("FAIL leftover invented generation_flipped"); fail = 1; end
    read_load_word(8'd0, p0);
    read_load_word(8'd1, p1);
    if (p0 !== BEGINW || p1 !== BEGINW) begin log1("FAIL leftover p0/p1"); fail = 1; end
    read_term0(t0, tflags);
    log1($sformatf("TERM leftover data=%08h flags=%04h", t0, tflags));
    if (tflags[2] !== 1'b1) begin log1("FAIL leftover term not NAK"); fail = 1; end
    if (tflags[0] !== 1'b0) begin log1("FAIL leftover term COMMIT"); fail = 1; end

    // DUMP-without-NAK
    dut_reset;
    arm_obs;
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL dump CLEAR %08h", got)); fail = 1; end
    send_word(DUMPW);
    repeat (40) @(posedge clk100);
    n_uart_fr = n_uart; n_fw_fr = n_fw; n_ld_fr = n_ld;
    log1($sformatf("DUMP fr=%0d nak=%0b n_uart=%0d n_fw=%0d n_ld=%0d n_ctrl=%0d",
                   freeze_reason, load_reject, n_uart, n_fw, n_ld, n_ctrl));
    if (freeze_reason != 4'd3) begin log1("FAIL dump FR"); fail = 1; end
    if (load_reject) begin log1("FAIL dump NAK"); fail = 1; end
    if (n_fw != 0 || n_ld != 0) begin log1("FAIL DUMP entered path"); fail = 1; end
    send_word(BEGINW);
    repeat (40) @(posedge clk100);
    if (n_uart != n_uart_fr || n_fw != n_fw_fr || n_ld != n_ld_fr) begin
      log1("FAIL dump n_ev moved"); fail = 1;
    end

    // GOLD V-04: COMMIT four-AND generation_flipped
    dut_reset;
    arm_obs;
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin log1($sformatf("FAIL gold CLEAR %08h", got)); fail = 1; end
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    repeat (12) @(posedge ui_clk);
    log1($sformatf("GOLD got=%08h fr=%0d n_term=%0d n_state=%0d flip=%0d present=%0d same=%0d before=%08h after=%08h",
                   got, freeze_reason, n_term, n_state, gen_flip, flip_present, same_ep, gbefore, gafter));
    if (mute || got !== GOLD) begin log1("FAIL GOLD token"); fail = 1; end
    if (!flip_present || !gen_flip || !same_ep) begin
      log1("FAIL GOLD generation_flipped four-AND");
      fail = 1;
    end
    if (gbefore === gafter) begin log1("FAIL GOLD before==after"); fail = 1; end
    read_term0(t0, tflags);
    log1($sformatf("TERM gold data=%08h flags=%04h", t0, tflags));
    if (tflags[0] !== 1'b1) begin log1("FAIL gold term not COMMIT"); fail = 1; end

    log1("PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO");
    if (fail) log1("FAIL");
    else log1("PASS_XSIM 9lane CONTROL/STATE/TERMINAL leftover+DUMP+GOLD four-AND");
    $fclose(logfd);
    $finish;
  end
endmodule
