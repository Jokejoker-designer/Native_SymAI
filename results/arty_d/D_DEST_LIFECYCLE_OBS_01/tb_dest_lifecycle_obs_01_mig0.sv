// OBS01-MIG0: same CLEAR→V-04→CLEAR→V-04 as BRAM OBS01, dest=generated mig0.
// Checkpoints P0..P15. Q4 = BEGIN2→COMMIT→load_ack rise→GOLD2. lack_fell unused.
// Default U32 dest_ui AND. xvlog -d OBS01_QSC_PKG => PACKAGE A/B (force dest ready 1).
// Not PACK_ABI_24_24_PASS / MIG_PASS / BOARD_PASS.
`timescale 1ps/1ps

module tb_dest_lifecycle_obs_01_mig0;
  localparam bit QSC_USE_DEST_RDY =
`ifdef OBS01_QSC_PKG
    1'b0
`else
    1'b1
`endif
    ;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam time RESET_PERIOD = 200000;
  localparam time CLKIN_HALF   = 3000;
  localparam time REFCLK_HALF  = 2500;
  localparam time CLK100_HALF  = 5000;

  logic sys_clk_i, clk_ref_i, clk100, sys_rst_n;
  wire  sys_rst = sys_rst_n;
  wire  ui_clk, ui_clk_sync_rst, init_calib_complete;
  wire  rst_ui_n = init_calib_complete && !ui_clk_sync_rst;
  logic rst100_n, uart_rx;
  wire  uart_tx;

  initial sys_clk_i = 1'b0;
  always #(CLKIN_HALF) sys_clk_i = ~sys_clk_i;
  initial clk_ref_i = 1'b0;
  always #(REFCLK_HALF) clk_ref_i = ~clk_ref_i;
  initial clk100 = 1'b0;
  always #(CLK100_HALF) clk100 = ~clk100;

  initial begin
    sys_rst_n = 1'b0;
    #RESET_PERIOD;
    sys_rst_n = 1'b1;
  end

  wire [15:0] ddr3_dq;
  wire [1:0]  ddr3_dqs_n, ddr3_dqs_p, ddr3_dm;
  wire [13:0] ddr3_addr;
  wire [2:0]  ddr3_ba;
  wire        ddr3_ras_n, ddr3_cas_n, ddr3_we_n, ddr3_reset_n;
  wire [0:0]  ddr3_ck_p, ddr3_ck_n, ddr3_cke, ddr3_cs_n, ddr3_odt;

  wire [27:0]  dest_app_addr;
  wire [2:0]   dest_app_cmd;
  wire         dest_app_en, dest_app_wdf_end, dest_app_wdf_wren;
  wire [127:0] dest_app_wdf_data, dest_app_rd_data;
  wire [15:0]  dest_app_wdf_mask;
  wire         dest_app_rd_data_end, dest_app_rd_data_valid, dest_app_rdy, dest_app_wdf_rdy;
  wire         app_sr_active, app_ref_ack, app_zq_ack;
  wire [11:0]  device_temp;

  wire w_valid, w_ready, fifo_wr_fire, fifo_rd_fire, p_fire;
  wire [31:0] w_data, fifo_wr_data, fifo_rd_data, p_data;
  wire load_ack, load_reject;
  wire [7:0] reason_code;

  pack_uart_mig0_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD), .QSC_USE_DEST_RDY(QSC_USE_DEST_RDY)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code,
    .calib_done(init_calib_complete),
    .dest_app_addr, .dest_app_cmd, .dest_app_en,
    .dest_app_wdf_data, .dest_app_wdf_end, .dest_app_wdf_mask, .dest_app_wdf_wren,
    .dest_app_rd_data, .dest_app_rd_data_valid, .dest_app_rdy, .dest_app_wdf_rdy
  );

  mig0 u_mig0 (
    .ddr3_dq, .ddr3_dqs_n, .ddr3_dqs_p,
    .ddr3_addr, .ddr3_ba, .ddr3_ras_n, .ddr3_cas_n, .ddr3_we_n, .ddr3_reset_n,
    .ddr3_ck_p, .ddr3_ck_n, .ddr3_cke, .ddr3_cs_n, .ddr3_dm, .ddr3_odt,
    .sys_clk_i, .clk_ref_i,
    .app_addr(dest_app_addr), .app_cmd(dest_app_cmd), .app_en(dest_app_en),
    .app_wdf_data(dest_app_wdf_data), .app_wdf_end(dest_app_wdf_end),
    .app_wdf_mask(dest_app_wdf_mask), .app_wdf_wren(dest_app_wdf_wren),
    .app_rd_data(dest_app_rd_data), .app_rd_data_end(dest_app_rd_data_end),
    .app_rd_data_valid(dest_app_rd_data_valid),
    .app_rdy(dest_app_rdy), .app_wdf_rdy(dest_app_wdf_rdy),
    .app_sr_req(1'b0), .app_ref_req(1'b0), .app_zq_req(1'b0),
    .app_sr_active, .app_ref_ack, .app_zq_ack,
    .ui_clk, .ui_clk_sync_rst, .init_calib_complete, .device_temp,
    .sys_rst
  );

  ddr3_model #(.DEBUG(0)) u_ddr3 (
    .rst_n(ddr3_reset_n),
    .ck(ddr3_ck_p[0]), .ck_n(ddr3_ck_n[0]),
    .cke(ddr3_cke[0]), .cs_n(ddr3_cs_n[0]),
    .ras_n(ddr3_ras_n), .cas_n(ddr3_cas_n), .we_n(ddr3_we_n),
    .dm_tdqs(ddr3_dm), .ba(ddr3_ba), .addr(ddr3_addr),
    .dq(ddr3_dq), .dqs(ddr3_dqs_p), .dqs_n(ddr3_dqs_n),
    .tdqs_n(), .odt(ddr3_odt[0])
  );

  dest_lifecycle_obs u_obs (
    .clk(ui_clk), .rst_n(rst_ui_n), .enable(1'b1),
    .calib_done(init_calib_complete),
    .p_valid(u_h.p_valid), .p_ready(u_h.p_ready), .p_data(u_h.p_data_i),
    .ld_state(u_h.u_ld.u_ld.state),
    .loader_busy(u_h.u_ld.loader_busy),
    .loader_wr_outstanding(u_h.u_ld.wr_outstanding),
    .ui_state(u_h.u_ld.u_ui.st),
    .ui_outstanding(u_h.u_ld.ui_out),
    .ui_busy(u_h.u_ld.ui_busy),
    .p_en(u_h.p_en), .p_rdy(u_h.p_rdy), .p_wren(u_h.p_wren), .p_wdf_rdy(u_h.p_wdf_rdy),
    .app_en(dest_app_en), .app_rdy(dest_app_rdy),
    .app_wdf_wren(dest_app_wdf_wren), .app_wdf_rdy(dest_app_wdf_rdy),
    .app_rd_data_valid(dest_app_rd_data_valid),
    .mux_g(u_h.u_mux.g),
    .pack_quiescent(u_h.qsc_ui),
    .debug_clear(u_h.debug_clear),
    .load_ack(load_ack), .load_reject(load_reject),
    .reason_code(reason_code),
    .active_generation(u_h.u_ld.active_generation),
    .ack_d(u_h.ack_d), .st_valid_ui(u_h.st_valid_ui)
  );

  wire [15:0] t1_seen, t2_seen;
  wire [4:0] t1_last, t1_div, t2_last, t2_div;
  wire t1_pcmd, t1_pwdf, t1_htx, t2_pcmd, t2_pwdf, t2_htx;
  wire [15:0] t2_hrdy, t2_hwdf, t2_hrdv;
  wire [2:0] t2_ui; wire [15:0] t2_uout, t2_lout; wire [3:0] t2_ld;
  wire [1:0] t2_mux; wire t2_dclr, t2_qsc;
  logic t1_arm, t2_arm;

  dest_lifecycle_obs_mig0 #(.FNAME("dest_ckpt_t1.csv")) u_ck1 (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(t1_arm),
    .p_valid(u_h.p_valid), .p_ready(u_h.p_ready), .p_data(u_h.p_data_i),
    .mem_cmd_valid(u_h.u_ld.mem_cmd_valid), .mem_cmd_ready(u_h.u_ld.mem_cmd_ready),
    .mem_cmd_write(u_h.u_ld.mem_cmd_write),
    .app_en(dest_app_en), .app_rdy(dest_app_rdy),
    .app_wdf_wren(dest_app_wdf_wren), .app_wdf_rdy(dest_app_wdf_rdy),
    .app_rd_data_valid(dest_app_rd_data_valid),
    .ui_st(u_h.u_ld.u_ui.st), .cmd_acc(u_h.u_ld.u_ui.cmd_acc), .wdf_acc(u_h.u_ld.u_ui.wdf_acc),
    .wr_r(u_h.u_ld.u_ui.wr_r), .wdata_r(u_h.u_ld.u_ui.wdata_r), .rdata_r(u_h.u_ld.u_ui.rdata_r),
    .err_r(u_h.u_ld.u_ui.err_r), .lane_r(u_h.u_ld.u_ui.lane_r), .app_rd_data(dest_app_rd_data),
    .ui_out(u_h.u_ld.ui_out),
    .mem_resp_valid(u_h.u_ld.mem_resp_valid), .mem_resp_ready(u_h.u_ld.mem_resp_ready),
    .mem_resp_err(u_h.u_ld.mem_resp_err),
    .ld_st(u_h.u_ld.u_ld.state), .ld_out(u_h.u_ld.wr_outstanding),
    .chk_i(u_h.u_ld.u_ld.chk_i), .n_rg(u_h.u_ld.u_ld.n_rg),
    .loader_busy(u_h.u_ld.loader_busy), .ui_busy(u_h.u_ld.ui_busy),
    .debug_clear(u_h.debug_clear), .pack_quiescent(u_h.qsc_ui), .mux_g(u_h.u_mux.g),
    .load_ack, .st_valid_ui(u_h.st_valid_ui), .st_valid_100(u_h.st_valid_100),
    .p_seen(t1_seen), .last_eq(t1_last), .first_div(t1_div),
    .partial_wr_cmd_only(t1_pcmd), .partial_wr_wdf_only(t1_pwdf), .half_txn_clear(t1_htx),
    .hist_app_rdy(), .hist_app_wdf_rdy(), .hist_app_rdv(),
    .snap_ui_st(), .snap_ui_out(), .snap_ld_st(), .snap_ld_out(),
    .snap_mux(), .snap_dclr(), .snap_qsc()
  );

  dest_lifecycle_obs_mig0 #(.FNAME("dest_ckpt_t2.csv")) u_ck2 (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(t2_arm),
    .p_valid(u_h.p_valid), .p_ready(u_h.p_ready), .p_data(u_h.p_data_i),
    .mem_cmd_valid(u_h.u_ld.mem_cmd_valid), .mem_cmd_ready(u_h.u_ld.mem_cmd_ready),
    .mem_cmd_write(u_h.u_ld.mem_cmd_write),
    .app_en(dest_app_en), .app_rdy(dest_app_rdy),
    .app_wdf_wren(dest_app_wdf_wren), .app_wdf_rdy(dest_app_wdf_rdy),
    .app_rd_data_valid(dest_app_rd_data_valid),
    .ui_st(u_h.u_ld.u_ui.st), .cmd_acc(u_h.u_ld.u_ui.cmd_acc), .wdf_acc(u_h.u_ld.u_ui.wdf_acc),
    .wr_r(u_h.u_ld.u_ui.wr_r), .wdata_r(u_h.u_ld.u_ui.wdata_r), .rdata_r(u_h.u_ld.u_ui.rdata_r),
    .err_r(u_h.u_ld.u_ui.err_r), .lane_r(u_h.u_ld.u_ui.lane_r), .app_rd_data(dest_app_rd_data),
    .ui_out(u_h.u_ld.ui_out),
    .mem_resp_valid(u_h.u_ld.mem_resp_valid), .mem_resp_ready(u_h.u_ld.mem_resp_ready),
    .mem_resp_err(u_h.u_ld.mem_resp_err),
    .ld_st(u_h.u_ld.u_ld.state), .ld_out(u_h.u_ld.wr_outstanding),
    .chk_i(u_h.u_ld.u_ld.chk_i), .n_rg(u_h.u_ld.u_ld.n_rg),
    .loader_busy(u_h.u_ld.loader_busy), .ui_busy(u_h.u_ld.ui_busy),
    .debug_clear(u_h.debug_clear), .pack_quiescent(u_h.qsc_ui), .mux_g(u_h.u_mux.g),
    .load_ack, .st_valid_ui(u_h.st_valid_ui), .st_valid_100(u_h.st_valid_100),
    .p_seen(t2_seen), .last_eq(t2_last), .first_div(t2_div),
    .partial_wr_cmd_only(t2_pcmd), .partial_wr_wdf_only(t2_pwdf), .half_txn_clear(t2_htx),
    .hist_app_rdy(t2_hrdy), .hist_app_wdf_rdy(t2_hwdf), .hist_app_rdv(t2_hrdv),
    .snap_ui_st(t2_ui), .snap_ui_out(t2_uout), .snap_ld_st(t2_ld), .snap_ld_out(t2_lout),
    .snap_mux(t2_mux), .snap_dclr(t2_dclr), .snap_qsc(t2_qsc)
  );

  logic host_valid, host_seen, host_take;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(1'b1), .w_data(host_data)
  );
  initial host_take = 1'b0;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin host_seen <= 1'b0; host_cap <= 32'h0; end
    else if (host_take) host_seen <= 1'b0;
    else if (host_valid && !host_seen) begin host_seen <= 1'b1; host_cap <= host_data; end
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
  logic q4_new_commit, no_stuck;
  logic ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2;
  logic clear2_busy, clear2_mute;
  int n_qsc0_idle, n_qsc0_idle_rdy0, n_qsc0_idle_rdy1;
  logic qsc_idle_r;

  wire client_idle = !u_h.u_ld.loader_busy && (u_h.u_ld.u_ui.st == 3'd0)
                  && !u_h.u_ld.ui_busy && (u_h.u_ld.ui_out == 16'h0)
                  && (u_h.u_ld.wr_outstanding == 16'h0);

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_qsc0_idle <= 0;
      n_qsc0_idle_rdy0 <= 0;
      n_qsc0_idle_rdy1 <= 0;
      qsc_idle_r <= 1'b1;
    end else if (gold1_seen) begin
      if (client_idle && !u_h.qsc_ui) begin
        n_qsc0_idle <= n_qsc0_idle + 1;
        if (!dest_app_rdy || !dest_app_wdf_rdy)
          n_qsc0_idle_rdy0 <= n_qsc0_idle_rdy0 + 1;
        else
          n_qsc0_idle_rdy1 <= n_qsc0_idle_rdy1 + 1;
        if (qsc_idle_r)
          $display("OBS01_QSC0_WHILE_IDLE t=%0t dest_rdy=%0b dest_wdf=%0b p_rdy=%0b mux_g=%0d qsc_c1=%0b dest_accept=%0b",
                   $time, dest_app_rdy, dest_app_wdf_rdy, u_h.p_rdy, u_h.u_mux.g,
                   u_h.qsc_c1, u_h.dest_accept);
      end
      qsc_idle_r <= u_h.qsc_ui || !client_idle;
    end
  end

  function automatic string pn(input int n);
    case (n)
      0: pn = "P0_BEGIN_ACCEPT";
      1: pn = "P1_MEM_CMD_WRITE_HS";
      2: pn = "P2_APP_EN_RDY_WR";
      3: pn = "P3_APP_WDF_HS_WR";
      4: pn = "P4_ENTER_S_RD_AFTER_P2P3";
      5: pn = "P5_RD_CMD_ACCEPT";
      6: pn = "P6_APP_RD_DATA_VALID";
      7: pn = "P7_LANE_MATCH_WDATA_R";
      8: pn = "P8_UI_OUTSTANDING_DEC";
      9: pn = "P9_MEM_RESP_CONSUME";
      10: pn = "P10_LOADER_OUT_ZERO";
      11: pn = "P11_SENTINEL_OK";
      12: pn = "P12_S_COMMIT";
      13: pn = "P13_LOAD_ACK_RISE";
      14: pn = "P14_STATUS_VALID_RISE";
      15: pn = "P15_SETTLE_IDLE";
      31: pn = "NONE";
      default: pn = "P?";
    endcase
  endfunction

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) nwords = 0;
      else begin
        void'($fscanf(fd, "%h", nwords));
        for (i = 0; i < nwords; i++) void'($fscanf(fd, "%h", vec[i]));
        $fclose(fd);
      end
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      uart_rx <= 1'b0; repeat (DIV) @(posedge clk100);
      for (k = 0; k < 8; k++) begin uart_rx <= b[k]; repeat (DIV) @(posedge clk100); end
      uart_rx <= 1'b1; repeat (DIV) @(posedge clk100);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]); end
  endtask

  task automatic wait_word(output logic [31:0] g, input int maxc, output bit m);
    begin
      c = 0; host_take = 1'b0;
      while (c < maxc && !host_seen) begin @(posedge clk100); c = c + 1; end
      m = !host_seen;
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1; @(posedge clk100); host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  task automatic dump_div(input string tag, input int last, input int div);
    begin
      $display("%s", tag);
      $display("LAST_EQUIVALENT_EVENT = %s", pn(last));
      $display("FIRST_DIVERGENCE      = %s", pn(div));
      $display("BRAM:");
      $display("  expected event %s", pn(div));
      $display("MIG0:");
      $display("  observed event / absent  seen=%04h last=%s missing=%s", t2_seen, pn(last), pn(div));
      $display("app_rdy history          %016b", t2_hrdy);
      $display("app_wdf_rdy history      %016b", t2_hwdf);
      $display("app_rd_data_valid history %016b", t2_hrdv);
      $display("mig_ui32.state           %0d", t2_ui);
      $display("ui_outstanding           %0d", t2_uout);
      $display("loader.state             %0d", t2_ld);
      $display("loader_outstanding       %0d", t2_lout);
      $display("mux_owner                %0d", t2_mux);
      $display("debug_clear              %0b", t2_dclr);
      $display("pack_quiescent           %0b", t2_qsc);
      $display("partial_wr_cmd_only      %0b", t2_pcmd);
      $display("partial_wr_wdf_only      %0b", t2_pwdf);
      $display("half_txn_clear           %0b", t2_htx);
      if (t2_seen[2] && !t2_seen[3])
        $display("BRANCH P2_WITHOUT_P3 write-command/write-data handshake");
      if (t2_seen[2] && t2_seen[3] && !t2_seen[5])
        $display("BRANCH P2P3_WITHOUT_P5 S_WR->S_RD or MIG command readiness");
      if (t2_seen[5] && !t2_seen[6])
        $display("BRANCH P5_WITHOUT_P6 read-return/MIG/DDR");
      $display("No generic MIG-fault claim.");
    end
  endtask

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      lack_r <= 1'b0; stv_r <= 1'b0; dclr_r <= 1'b0; pfire_r <= 1'b0; ld_r <= 4'h0;
      n_commit <= 0; n_lack_rise <= 0; n_stv_rise <= 0;
      dclr_while_busy <= 1'b0; lack_fell <= 1'b0;
      begin2_fire_seen <= 1'b0; commit2_seen <= 1'b0; lack2_after_commit2 <= 1'b0;
      stv2_after_begin2 <= 1'b0;
      commit_count_at_begin2 <= 0; lack_rise_count_at_begin2 <= 0; stv_rise_count_at_begin2 <= 0;
    end else begin
      if (u_h.u_ld.u_ld.state == 4'd7 && ld_r != 4'd7) begin
        n_commit <= n_commit + 1;
        if (begin2_fire_seen && !commit2_seen) begin commit2_seen <= 1'b1; t_commit2 <= $time; end
      end
      if (load_ack && !lack_r) begin
        n_lack_rise <= n_lack_rise + 1;
        if (begin2_fire_seen && commit2_seen && !lack2_after_commit2) begin
          lack2_after_commit2 <= 1'b1; t_lack2 <= $time;
        end
      end
      if (!load_ack && lack_r) lack_fell <= 1'b1;
      if (u_h.st_valid_ui && !stv_r) begin
        n_stv_rise <= n_stv_rise + 1;
        if (begin2_fire_seen) stv2_after_begin2 <= 1'b1;
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
      lack_r <= load_ack; stv_r <= u_h.st_valid_ui; dclr_r <= u_h.debug_clear;
      pfire_r <= p_fire; ld_r <= u_h.u_ld.u_ld.state;
    end
  end

  initial begin
    gold1_seen = 1'b0; gold2_seen = 1'b0; clr2_armed = 1'b0; v04_2_armed = 1'b0;
    q1_ui_idle = 1'b0; q2_out0 = 1'b0; t1_arm = 1'b0; t2_arm = 1'b0;
    clear2_busy = 1'b0; clear2_mute = 1'b0;
    rst100_n = 0; uart_rx = 1;
    $display("OBS01_MIG0_WAIT_CALIB PACK_ABI_24_24_PASS=NO dest=generated_mig0");
    fork
      begin wait (init_calib_complete); end
      begin #(5ms); end
    join_any
    disable fork;
    if (!init_calib_complete) begin
      $display("OBS01_FAIL CALIB timeout");
      $display("LAST_EQUIVALENT_EVENT = NONE");
      $display("FIRST_DIVERGENCE      = CALIB_DONE");
      $display("PACK_ABI_24_24_PASS = NO");
      $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
      $finish;
    end
    $display("OBS01_MIG0_CALIB_DONE t=%0t", $time);
    rst100_n = 1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-V-04.mem");
    $display("OBS01_START nwords=%0d dest=mig0 USE_DEST_RDY=%0d PACK_ABI_24_24_PASS=NO MIG0_BOARD_CAUSAL_CLASS=STILL_OPEN",
             nwords, QSC_USE_DEST_RDY);

    send_word(CLR_CMD);
    wait_word(got, 800000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("OBS01_FAIL CLEAR1 got=%08h mute=%0d USE_DEST_RDY=%0d", got, mute, QSC_USE_DEST_RDY);
      $display("OBS01_QSC_VS_RDY dest_rdy=%0b dest_wdf=%0b p_rdy=%0b p_wdf=%0b mux_g=%0d qsc_ui=%0b qsc_c1=%0b dest_accept=%0b rst_loc=%0b dclr=%0b ld_st=%0d ui_st=%0d ld_busy=%0b ui_busy=%0b ld_out=%0d ui_out=%0d",
               dest_app_rdy, dest_app_wdf_rdy, u_h.p_rdy, u_h.p_wdf_rdy, u_h.u_mux.g,
               u_h.qsc_ui, u_h.qsc_c1, u_h.dest_accept, u_h.u_ld.rst_loc, u_h.debug_clear,
               u_h.u_ld.u_ld.state, u_h.u_ld.u_ui.st, u_h.u_ld.loader_busy, u_h.u_ld.ui_busy,
               u_h.u_ld.wr_outstanding, u_h.u_ld.ui_out);
      $display("LAST_EQUIVALENT_EVENT = CALIB_DONE");
      $display("FIRST_DIVERGENCE      = CLEAR1_ACK");
      $display("PACK_ABI_24_24_PASS = NO");
      $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
      $finish;
    end
    $display("OBS01_CLEAR1 ACK got=%08h USE_DEST_RDY=%0d dest_rdy=%0b dest_wdf=%0b qsc_ui=%0b qsc_c1=%0b dest_accept=%0b",
             got, QSC_USE_DEST_RDY, dest_app_rdy, dest_app_wdf_rdy,
             u_h.qsc_ui, u_h.qsc_c1, u_h.dest_accept);
    if (QSC_USE_DEST_RDY == 1'b0)
      $display("BRANCH H1_CAUSAL_CLEAR1_ACK PACKAGE_QSC dest_rdy_not_in_qsc");
    t1_arm = 1'b1;
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 5_000_000, mute);
    t_gold1 = $time; gold1_seen = 1'b1;
    $display("OBS01_GOLD1 mute=%0d got=%08h t1_seen=%04h last=%s div=%s",
             mute, got, t1_seen, pn(t1_last), pn(t1_div));
    if (mute || got !== GOLD) begin
      $display("OBS01_FAIL V04_0 got=%08h", got);
      dump_div("TXN1_FAIL", t1_last, t1_div);
      $display("PACK_ABI_24_24_PASS = NO");
      $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
      $finish;
    end
    repeat (64) @(posedge ui_clk);
    q1_ui_idle = (u_h.u_ld.u_ui.st == 3'd0) && !u_h.u_ld.ui_busy;
    t1_arm = 1'b0;
    $display("OBS01_AFTER_GOLD1_SETTLE q1_ui_idle=%0b ui_st=%0d ui_out=%0d ld_st=%0d t1_seen=%04h",
             q1_ui_idle, u_h.u_ld.u_ui.st, u_h.u_ld.ui_out, u_h.u_ld.u_ld.state, t1_seen);

    clr2_armed = 1'b1;
    q2_out0 = (u_h.u_ld.ui_out == 16'h0);
    $display("OBS01_BEFORE_CLEAR2 q2_out0=%0b ui_st=%0d ui_out=%0d ld_out=%0d ld_busy=%0b ui_busy=%0b",
             q2_out0, u_h.u_ld.u_ui.st, u_h.u_ld.ui_out, u_h.u_ld.wr_outstanding,
             u_h.u_ld.loader_busy, u_h.u_ld.ui_busy);
    $display("OBS01_QSC_VS_RDY dest_rdy=%0b dest_wdf=%0b p_rdy=%0b p_wdf=%0b mux_g=%0d qsc_ui=%0b qsc_c1=%0b dest_accept=%0b rst_loc=%0b dclr=%0b",
             dest_app_rdy, dest_app_wdf_rdy, u_h.p_rdy, u_h.p_wdf_rdy, u_h.u_mux.g,
             u_h.qsc_ui, u_h.qsc_c1, u_h.dest_accept, u_h.u_ld.rst_loc, u_h.debug_clear);
    $display("OBS01_QSC0_IDLE_COUNTS n=%0d rdy0=%0d rdy1=%0d (rdy0=H1 window, rdy1=other qsc term)",
             n_qsc0_idle, n_qsc0_idle_rdy0, n_qsc0_idle_rdy1);
    send_word(CLR_CMD);
    wait_word(got, 800000, mute);
    t_ack2 = $time;
    clear2_mute = mute;
    clear2_busy = (!mute && got === CLR_BUSY);
    $display("OBS01_CLEAR2 mute=%0d got=%08h dclr_busy=%0b lack_fell=%0b",
             mute, got, dclr_while_busy, lack_fell);
    if (mute || got !== CLR_ACK) begin
      $display("OBS01_FAIL CLEAR2 got=%08h", got);
      $display("OBS01_QSC_VS_RDY dest_rdy=%0b dest_wdf=%0b p_rdy=%0b mux_g=%0d qsc_ui=%0b qsc_c1=%0b dest_accept=%0b",
               dest_app_rdy, dest_app_wdf_rdy, u_h.p_rdy, u_h.u_mux.g,
               u_h.qsc_ui, u_h.qsc_c1, u_h.dest_accept);
      $display("OBS01_QSC0_IDLE_COUNTS n=%0d rdy0=%0d rdy1=%0d",
               n_qsc0_idle, n_qsc0_idle_rdy0, n_qsc0_idle_rdy1);
      if (t1_seen[6] && t1_seen[10] && (n_qsc0_idle_rdy0 > 0))
        $display("BRANCH RAW_MIG_READY_USED_AS_QUIESCENCE candidate STRENGTHENED (not root cause stamp)");
      else if (t1_seen[6] && t1_seen[10] && (n_qsc0_idle_rdy0 == 0) && (n_qsc0_idle_rdy1 > 0))
        $display("BRANCH QSC0_WITH_DEST_READY_1 other qsc term, not dest_rdy dip");
      if (t1_seen[6] && t1_seen[10])
        $display("BRANCH P6_P10_CLEAN_CLEAR2_NOT_ACK quiescence/CLEAR gating, not MIG transaction");
      $display("LAST_EQUIVALENT_EVENT = TXN1_%s", pn(t1_last));
      $display("FIRST_DIVERGENCE      = CLEAR2_ACK");
      $display("PACK_ABI_24_24_PASS = NO");
      $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
      $finish;
    end

    repeat (8) @(posedge ui_clk);
    v04_2_armed = 1'b1;
    t2_arm = 1'b1;
    commit_before_v04_2 = n_commit;
    lack_before_v04_2 = n_lack_rise;
    stv_before_v04_2 = n_stv_rise;
    $display("OBS01_V04_2_ARM n_commit=%0d n_lack_rise=%0d n_stv_rise=%0d (lack_fell is CLEAR reset, not BEGIN2)",
             commit_before_v04_2, lack_before_v04_2, stv_before_v04_2);

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 5_000_000, mute);
    t_gold2 = $time; gold2_seen = 1'b1;
    d_commit = n_commit - commit_count_at_begin2;
    d_lack   = n_lack_rise - lack_rise_count_at_begin2;
    d_stv    = n_stv_rise - stv_rise_count_at_begin2;
    $display("OBS01_GOLD2 mute=%0d got=%08h begin2=%0b t_begin2=%0t t_commit2=%0t t_lack2=%0t",
             mute, got, begin2_fire_seen, t_begin2, t_commit2, t_lack2);
    $display("OBS01_GOLD2_DELTA d_commit=%0d d_lack=%0d d_stv=%0d", d_commit, d_lack, d_stv);
    if (mute || got !== GOLD) begin
      $display("OBS01_FAIL V04_1 got=%08h", got);
      dump_div("TXN2_FAIL", t2_last, t2_div);
      $display("PACK_ABI_24_24_PASS = NO");
      $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
      $finish;
    end

    repeat (80) @(posedge ui_clk);
    ld_idle_g2  = (u_h.u_ld.u_ld.state == 4'd0) && !u_h.u_ld.loader_busy;
    ui_idle_g2  = (u_h.u_ld.u_ui.st == 3'd0) && !u_h.u_ld.ui_busy;
    out0_g2     = (u_h.u_ld.ui_out == 16'h0);
    st_quiet_g2 = !u_h.st_valid_ui && !u_h.st_valid_100;
    no_stuck = ld_idle_g2 && ui_idle_g2 && out0_g2 && st_quiet_g2;
    q4_new_commit = begin2_fire_seen && commit2_seen && lack2_after_commit2
                 && (d_commit >= 1) && (d_lack >= 1) && (t_gold2 > t_commit2);

    $display("Q1_MIG_UI32_IDLE_AFTER_GOLD1 %0s", q1_ui_idle ? "YES" : "NO");
    $display("Q2_UI_OUTSTANDING_ZERO_BEFORE_CLEAR2 %0s", q2_out0 ? "YES" : "NO");
    $display("Q3_CLEAR2_RESET_BEFORE_RETIRE %0s dclr_while_busy=%0b",
             dclr_while_busy ? "YES" : "NO", dclr_while_busy);
    if (q4_new_commit)
      $display("Q4_GOLD2_SOURCE NEW_COMMIT begin2=%0b commit2=%0b lack2_after_commit=%0b d_commit=%0d d_lack=%0d d_stv=%0d",
               begin2_fire_seen, commit2_seen, lack2_after_commit2, d_commit, d_lack, d_stv);
    else
      $display("Q4_GOLD2_SOURCE MIXED_OR_UNKNOWN begin2=%0b commit2=%0b lack2=%0b d_commit=%0d d_lack=%0d (lack_fell=%0b is CLEAR reset)",
               begin2_fire_seen, commit2_seen, lack2_after_commit2, d_commit, d_lack, lack_fell);

    if (no_stuck)
      $display("NO_STUCK_STATE_OBSERVED_ON_MIG0_THIS_SEQ ld_idle=%0b ui_idle=%0b out0=%0b st_quiet=%0b",
               ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2);
    else
      $display("STUCK_OR_UNQUIESCED_AFTER_GOLD2 ld_idle=%0b ui_idle=%0b out0=%0b st_quiet=%0b",
               ld_idle_g2, ui_idle_g2, out0_g2, st_quiet_g2);

    $display("TXN2_CKPT seen=%04h last=%s div=%s half_txn_clear=%0b pcmd=%0b pwdf=%0b",
             t2_seen, pn(t2_last), pn(t2_div), t2_htx, t2_pcmd, t2_pwdf);

    if (t2_div != 5'd31)
      dump_div("TXN2_DIV", t2_last, t2_div);
    else begin
      $display("LAST_EQUIVALENT_EVENT = P15_SETTLE_IDLE");
      $display("FIRST_DIVERGENCE      = NONE_ON_MIG0_THIS_SEQ");
    end

    if (q1_ui_idle && q2_out0 && !dclr_while_busy && q4_new_commit && no_stuck && (t2_div == 5'd31) && !t2_htx)
      $display("MIG0_PATH_THIS_SEQUENCE = CLEAN");
    else
      $display("MIG0_PATH_THIS_SEQUENCE = NOT_CLEAN");
    $display("PACK_ABI_24_24_PASS = NO");
    $display("MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN");
    $display("OBS01_DONE dest=generated_mig0 not_board not_pack_abi");
    $finish;
  end
endmodule
