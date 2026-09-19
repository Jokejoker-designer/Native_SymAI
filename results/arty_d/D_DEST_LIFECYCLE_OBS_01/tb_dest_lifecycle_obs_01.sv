// tb_dest_lifecycle_obs_01.sv — CLEAR → V-04 → CLEAR → V-04 dest log at ui_clk.
// Q4 = BEGIN2 accepted → S_COMMIT → load_ack rise → GOLD2. lack_fell is CLEAR
// reset of sticky load_ack, not proof of a new transaction.
// Dest=mig_ui_bram. Not PACK_ABI_24_24_PASS. mig0 board class STILL_OPEN.
`timescale 1ns/1ps

module tb_dest_lifecycle_obs_01;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
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

  dest_lifecycle_obs u_obs (
    .clk(ui_clk), .rst_n(rst_ui_n), .enable(1'b1),
    .calib_done(u_h.calib_ui),
    .p_valid(u_h.p_valid), .p_ready(u_h.p_ready), .p_data(u_h.p_data_i),
    .ld_state(u_h.u_ld.u_ld.state),
    .loader_busy(u_h.u_ld.loader_busy),
    .loader_wr_outstanding(u_h.u_ld.wr_outstanding),
    .ui_state(u_h.u_ld.u_ui.st),
    .ui_outstanding(u_h.u_ld.ui_out),
    .ui_busy(u_h.u_ld.ui_busy),
    .p_en(u_h.p_en), .p_rdy(u_h.p_rdy), .p_wren(u_h.p_wren), .p_wdf_rdy(u_h.p_wdf_rdy),
    .app_en(u_h.d_en), .app_rdy(u_h.d_rdy),
    .app_wdf_wren(u_h.d_wren), .app_wdf_rdy(u_h.d_wdf_rdy),
    .app_rd_data_valid(u_h.d_rdv),
    .mux_g(u_h.u_mux.g),
    .pack_quiescent(u_h.qsc_ui),
    .debug_clear(u_h.debug_clear),
    .load_ack(load_ack), .load_reject(load_reject),
    .reason_code(reason_code),
    .active_generation(u_h.u_ld.active_generation),
    .ack_d(u_h.ack_d), .st_valid_ui(u_h.st_valid_ui)
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
  bit mute;

  time t_gold1, t_gold2, t_ack2, t_dclr2, t_begin2, t_commit2, t_lack2;
  logic q1_ui_idle, q2_out0, dclr_while_busy, lack_fell;
  logic [2:0] ui_at_dclr2;
  logic [3:0] ld_at_dclr2;
  logic [15:0] uout_at_dclr2, lout_at_dclr2;
  logic lack_at_dclr2;
  int n_commit, n_lack_rise, n_stv_rise;
  int commit_before_v04_2, lack_before_v04_2, stv_before_v04_2;
  int commit_count_at_begin2, lack_rise_count_at_begin2, stv_rise_count_at_begin2;
  int d_commit, d_lack, d_stv;
  logic gold1_seen, gold2_seen, clr2_armed, v04_2_armed;
  logic begin2_fire_seen, commit2_seen, lack2_after_commit2, stv2_after_begin2;
  logic lack_r, stv_r, dclr_r, pfire_r;
  logic [3:0] ld_r;
  logic q4_new_commit, no_stuck, status_quiet;
  logic ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2;

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

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      lack_r <= 1'b0;
      stv_r <= 1'b0;
      dclr_r <= 1'b0;
      pfire_r <= 1'b0;
      ld_r <= 4'h0;
      n_commit <= 0;
      n_lack_rise <= 0;
      n_stv_rise <= 0;
      dclr_while_busy <= 1'b0;
      lack_fell <= 1'b0;
      begin2_fire_seen <= 1'b0;
      commit2_seen <= 1'b0;
      lack2_after_commit2 <= 1'b0;
      stv2_after_begin2 <= 1'b0;
      commit_count_at_begin2 <= 0;
      lack_rise_count_at_begin2 <= 0;
      stv_rise_count_at_begin2 <= 0;
    end else begin
      if (u_h.u_ld.u_ld.state == 4'd7 && ld_r != 4'd7) begin
        n_commit <= n_commit + 1;
        if (begin2_fire_seen && !commit2_seen) begin
          commit2_seen <= 1'b1;
          t_commit2 <= $time;
        end
      end
      if (load_ack && !lack_r) begin
        n_lack_rise <= n_lack_rise + 1;
        if (begin2_fire_seen && commit2_seen && !lack2_after_commit2) begin
          lack2_after_commit2 <= 1'b1;
          t_lack2 <= $time;
        end
      end
      if (!load_ack && lack_r)
        lack_fell <= 1'b1;
      if (u_h.st_valid_ui && !stv_r) begin
        n_stv_rise <= n_stv_rise + 1;
        if (begin2_fire_seen)
          stv2_after_begin2 <= 1'b1;
      end
      if (v04_2_armed && p_fire && (p_data == BEGINW) && !begin2_fire_seen) begin
        begin2_fire_seen <= 1'b1;
        commit_count_at_begin2 <= n_commit;
        lack_rise_count_at_begin2 <= n_lack_rise;
        stv_rise_count_at_begin2 <= n_stv_rise;
        t_begin2 <= $time;
      end
      if (u_h.debug_clear && !dclr_r && clr2_armed) begin
        t_dclr2 <= $time;
        ui_at_dclr2 <= u_h.u_ld.u_ui.st;
        ld_at_dclr2 <= u_h.u_ld.u_ld.state;
        uout_at_dclr2 <= u_h.u_ld.ui_out;
        lout_at_dclr2 <= u_h.u_ld.wr_outstanding;
        lack_at_dclr2 <= load_ack;
        if ((u_h.u_ld.u_ui.st != 3'd0) || (u_h.u_ld.ui_out != 16'h0) || u_h.u_ld.ui_busy)
          dclr_while_busy <= 1'b1;
      end
      lack_r <= load_ack;
      stv_r <= u_h.st_valid_ui;
      dclr_r <= u_h.debug_clear;
      pfire_r <= p_fire;
      ld_r <= u_h.u_ld.u_ld.state;
    end
  end

  initial begin
    gold1_seen = 1'b0;
    gold2_seen = 1'b0;
    clr2_armed = 1'b0;
    v04_2_armed = 1'b0;
    q1_ui_idle = 1'b0;
    q2_out0 = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    $display("OBS01_START nwords=%0d PACK_ABI_24_24_PASS=NO dest=mig_ui_bram MIG0_BOARD_CAUSAL_CLASS=STILL_OPEN", nwords);

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("OBS01_FAIL CLEAR1 got=%08h", got);
      $finish;
    end
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    t_gold1 = $time;
    gold1_seen = 1'b1;
    $display("OBS01_GOLD1 mute=%0d got=%08h ui_st=%0d ui_out=%0d ld_st=%0d lack=%0b ack_d=%0b qsc=%0b",
             mute, got, u_h.u_ld.u_ui.st, u_h.u_ld.ui_out, u_h.u_ld.u_ld.state,
             load_ack, u_h.ack_d, u_h.qsc_ui);
    if (mute || got !== GOLD) begin
      $display("OBS01_FAIL V04_0 got=%08h", got);
      $finish;
    end
    repeat (64) @(posedge ui_clk);
    q1_ui_idle = (u_h.u_ld.u_ui.st == 3'd0) && !u_h.u_ld.ui_busy;
    $display("OBS01_AFTER_GOLD1_SETTLE q1_ui_idle=%0b ui_st=%0d ui_busy=%0b ui_out=%0d ld_st=%0d ld_busy=%0b ld_out=%0d qsc=%0b lack=%0b ack_d=%0b stv=%0b",
             q1_ui_idle, u_h.u_ld.u_ui.st, u_h.u_ld.ui_busy, u_h.u_ld.ui_out,
             u_h.u_ld.u_ld.state, u_h.u_ld.loader_busy, u_h.u_ld.wr_outstanding,
             u_h.qsc_ui, load_ack, u_h.ack_d, u_h.st_valid_ui);

    clr2_armed = 1'b1;
    q2_out0 = (u_h.u_ld.ui_out == 16'h0);
    $display("OBS01_BEFORE_CLEAR2 q2_out0=%0b ui_st=%0d ui_out=%0d ui_busy=%0b ld_st=%0d ld_out=%0d qsc=%0b lack=%0b",
             q2_out0, u_h.u_ld.u_ui.st, u_h.u_ld.ui_out, u_h.u_ld.ui_busy,
             u_h.u_ld.u_ld.state, u_h.u_ld.wr_outstanding, u_h.qsc_ui, load_ack);
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    t_ack2 = $time;
    $display("OBS01_CLEAR2 mute=%0d got=%08h dclr_busy=%0b ui_at_dclr=%0d uout_at_dclr=%0d ld_at_dclr=%0d lack_at_dclr=%0b lack_fell=%0b",
             mute, got, dclr_while_busy, ui_at_dclr2, uout_at_dclr2, ld_at_dclr2, lack_at_dclr2, lack_fell);
    if (mute || got !== CLR_ACK) begin
      $display("OBS01_FAIL CLEAR2 got=%08h", got);
      $finish;
    end

    repeat (8) @(posedge ui_clk);
    v04_2_armed = 1'b1;
    commit_before_v04_2 = n_commit;
    lack_before_v04_2 = n_lack_rise;
    stv_before_v04_2 = n_stv_rise;
    $display("OBS01_V04_2_ARM n_commit=%0d n_lack_rise=%0d n_stv_rise=%0d (lack_fell is CLEAR reset, not BEGIN2)",
             commit_before_v04_2, lack_before_v04_2, stv_before_v04_2);

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    t_gold2 = $time;
    gold2_seen = 1'b1;
    d_commit = n_commit - commit_count_at_begin2;
    d_lack   = n_lack_rise - lack_rise_count_at_begin2;
    d_stv    = n_stv_rise - stv_rise_count_at_begin2;
    $display("OBS01_GOLD2 mute=%0d got=%08h begin2=%0b t_begin2=%0t t_commit2=%0t t_lack2=%0t",
             mute, got, begin2_fire_seen, t_begin2, t_commit2, t_lack2);
    $display("OBS01_GOLD2_DELTA d_commit=%0d d_lack=%0d d_stv=%0d vs_begin2 c=%0d l=%0d s=%0d vs_v04_2 c=%0d l=%0d s=%0d",
             d_commit, d_lack, d_stv,
             commit_count_at_begin2, lack_rise_count_at_begin2, stv_rise_count_at_begin2,
             commit_before_v04_2, lack_before_v04_2, stv_before_v04_2);
    if (mute || got !== GOLD) begin
      $display("OBS01_FAIL V04_1 got=%08h", got);
      $finish;
    end

    repeat (64) @(posedge ui_clk);
    ld_idle_g2  = (u_h.u_ld.u_ld.state == 4'd0) && !u_h.u_ld.loader_busy;
    ui_idle_g2  = (u_h.u_ld.u_ui.st == 3'd0) && !u_h.u_ld.ui_busy;
    out0_g2     = (u_h.u_ld.ui_out == 16'h0);
    st_quiet_g2 = !u_h.st_valid_ui && !u_h.st_valid_100;
    status_quiet = st_quiet_g2;
    no_stuck = ld_idle_g2 && ui_idle_g2 && out0_g2 && st_quiet_g2;

    q4_new_commit = begin2_fire_seen && commit2_seen && lack2_after_commit2
                 && (d_commit >= 1) && (d_lack >= 1) && (t_gold2 > t_commit2);

    $display("Q1_MIG_UI32_IDLE_AFTER_GOLD1 %0s (settle snapshot, not ever-idle)",
             q1_ui_idle ? "YES" : "NO");
    $display("Q2_UI_OUTSTANDING_ZERO_BEFORE_CLEAR2 %0s (CLEAR2-boundary snapshot)",
             q2_out0 ? "YES" : "NO");
    $display("Q3_CLEAR2_RESET_BEFORE_RETIRE %0s dclr_while_busy=%0b ui_st=%0d ui_out=%0d ld_st=%0d",
             dclr_while_busy ? "YES" : "NO", dclr_while_busy, ui_at_dclr2, uout_at_dclr2, ld_at_dclr2);
    if (q4_new_commit)
      $display("Q4_GOLD2_SOURCE NEW_COMMIT begin2=%0b commit2=%0b lack2_after_commit=%0b d_commit=%0d d_lack=%0d d_stv=%0d t_gold2>t_commit2=%0b",
               begin2_fire_seen, commit2_seen, lack2_after_commit2, d_commit, d_lack, d_stv, (t_gold2 > t_commit2));
    else if (gold2_seen && !begin2_fire_seen)
      $display("Q4_GOLD2_SOURCE LEVEL_REPLAY_OR_NO_BEGIN2 begin2=0 d_stv=%0d", d_stv);
    else if (gold2_seen && (d_commit < 1))
      $display("Q4_GOLD2_SOURCE LEVEL_REPLAY d_commit=0 d_stv=%0d begin2=%0b (lack_fell=%0b is CLEAR reset)",
               d_stv, begin2_fire_seen, lack_fell);
    else
      $display("Q4_GOLD2_SOURCE MIXED_OR_UNKNOWN begin2=%0b commit2=%0b lack2=%0b d_commit=%0d d_lack=%0d d_stv=%0d lack_fell=%0b",
               begin2_fire_seen, commit2_seen, lack2_after_commit2, d_commit, d_lack, d_stv, lack_fell);

    $display("LAST_GOOD_DEST_EVENT GOLD1_THEN_UI_IDLE_OUT0 t_gold1=%0t t_ack2=%0t", t_gold1, t_ack2);
    if (no_stuck)
      $display("NO_STUCK_STATE_OBSERVED_ON_BRAM_THIS_SEQ ld_idle=%0b ui_idle=%0b out0=%0b st_quiet=%0b",
               ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2);
    else
      $display("STUCK_OR_UNQUIESCED_AFTER_GOLD2 ld_idle=%0b ui_idle=%0b out0=%0b st_quiet=%0b ld_st=%0d ui_st=%0d ui_out=%0d stv=%0b stv100=%0b",
               ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2,
               u_h.u_ld.u_ld.state, u_h.u_ld.u_ui.st, u_h.u_ld.ui_out,
               u_h.st_valid_ui, u_h.st_valid_100);

    if (q1_ui_idle && q2_out0 && !dclr_while_busy && q4_new_commit && no_stuck)
      $display("BRAM_PATH_THIS_SEQUENCE = CLEAN");
    else
      $display("BRAM_PATH_THIS_SEQUENCE = NOT_CLEAN");
    $display("PACK_ABI_24_24_PASS = NO");
    $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
    $display("OBS01_DONE dest=BRAM not_mig0 not_board");
    $finish;
  end
endmodule
