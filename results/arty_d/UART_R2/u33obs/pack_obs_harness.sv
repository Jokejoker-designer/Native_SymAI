// pack_obs_harness.sv — U33OBS copy of U32 harness + DUMP steal + hop taps.
// Does not overwrite u32/u33. DUMP 44554D50 never enters FIFO. PROGRAM=NO.
`timescale 1ns/1ps

module pack_obs_harness #(
  parameter int CLK_HZ = 100_000_000,
  parameter int BAUD   = 1_000_000
) (
  input  logic        clk100,
  input  logic        ui_clk,
  input  logic        rst100_n,
  input  logic        rst_ui_n,
  input  logic        uart_rx,
  output logic        uart_tx,
  output logic        w_valid,
  output logic        w_ready,
  output logic [31:0] w_data,
  output logic        uart_fire,
  output logic        fifo_wr_fire,
  output logic [31:0] fifo_wr_data,
  output logic        fifo_rd_fire,
  output logic [31:0] fifo_rd_data,
  output logic        cdc_a_fire,
  output logic [31:0] cdc_a_data,
  output logic        p_fire,
  output logic [31:0] p_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic        dump_pulse,
  output logic        clr_event,
  output logic        ctrl_fire,
  output logic [31:0] ctrl_data,
  output logic [15:0] ctrl_flags,
  output logic        state_fire,
  output logic [31:0] state_data,
  output logic [15:0] state_flags,
  output logic        term_fire,
  output logic [31:0] term_data,
  output logic [15:0] term_flags,
  output logic        commit_pulse,
  output logic [31:0] active_generation,
  output logic        debug_clear_o,
  input  logic        freeze = 1'b0,
  input  logic [3:0]  freeze_reason = 4'd0,
  input  logic        obs_arm_100 = 1'b0,
  input  logic        obs_arm_ui = 1'b0,
  input  logic        obs_capture_valid = 1'b0,
  input  logic [15:0] obs_epoch = 16'h0,
  input  logic        dest_stall = 1'b0
);
  localparam logic [31:0] DUMP_CMD = 32'h44554D50;

  logic clr_take, clr_hold, uart_flush, cdc_rst_100;
  logic clr_ui_req, clr_ui_ack, clr_ui_nack, debug_clear, clr_tx_busy_rst;
  logic qsc_ui, qsc_100;
  logic clr_ack_valid, clr_ack_ready;
  logic [31:0] clr_ack_data;
  logic cdc_a_idle, cdc_b_idle, tx_a_idle, tx_b_idle;
  logic fifo_wr_ready, f_valid, f_ready, fifo_empty, pack_lock, fifo_flush;
  logic [31:0] f_data;
  logic rx_idle;
  logic st_valid_100, st_ready_100;
  (* ASYNC_REG = "TRUE" *) logic req_u0, req_u1, ack_c0, ack_c1, nack_c0, nack_c1, qsc_c0, qsc_c1, busy_u0, busy_u1;
  logic qsc_ui_r;
  (* DIRECT_RESET = "yes" *) logic rst100_pack_n, rst_ui_pack_n, rst100_tx_b_n, rst_ui_tx_a_n, tx_busy_100_r;
  // OP_BEGIN low byte. Length lives in [31:16]; exact 00800001 dropped A-03/A-04 (len 132/64) as MUTE.
  wire pack_begin = (f_data[7:0] == 8'h01);
  wire dest_accept = qsc_c1 && rst100_pack_n;
  wire steer_pack = pack_lock || (f_valid && pack_begin && dest_accept);
  wire st_fire = st_valid_100 && st_ready_100;
  assign fifo_flush = uart_flush || st_fire;
  wire dump_take = w_valid && (w_data == DUMP_CMD) && !clr_take;

  logic calib_ui;

  pack_debug_clear u_clr (
    .clk(clk100), .rst_n(rst100_n),
    .in_valid(w_valid), .in_data(w_data),
    .take(clr_take), .hold(clr_hold),
    .uart_flush, .cdc_rst_100,
    .ui_req(clr_ui_req), .ui_ack(ack_c1), .ui_nack(nack_c1),
    .pack_quiescent(qsc_100),
    .uart_rx_mark(rx_idle),
    .ack_valid(clr_ack_valid), .ack_ready(clr_ack_ready), .ack_data(clr_ack_data),
    .tx_busy_rst(clr_tx_busy_rst)
  );

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      req_u0 <= 1'b0;
      req_u1 <= 1'b0;
      qsc_ui_r <= 1'b0;
      busy_u0 <= 1'b0;
      busy_u1 <= 1'b0;
    end else begin
      req_u0 <= clr_ui_req;
      req_u1 <= req_u0;
      qsc_ui_r <= qsc_ui;
      busy_u0 <= tx_busy_100_r;
      busy_u1 <= busy_u0;
    end
  end

  pack_clear_ui u_uiclr (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .req(req_u1), .pack_quiescent(qsc_ui),
    .ack(clr_ui_ack), .nack(clr_ui_nack), .debug_clear
  );

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      ack_c0 <= 1'b0;
      ack_c1 <= 1'b0;
      nack_c0 <= 1'b0;
      nack_c1 <= 1'b0;
      qsc_c0 <= 1'b0;
      qsc_c1 <= 1'b0;
    end else begin
      ack_c0 <= clr_ui_ack;
      ack_c1 <= ack_c0;
      nack_c0 <= clr_ui_nack;
      nack_c1 <= nack_c0;
      qsc_c0 <= qsc_ui_r;
      qsc_c1 <= qsc_c0;
    end
  end

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) rst100_pack_n <= 1'b0;
    else rst100_pack_n <= ~cdc_rst_100;
  end
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) rst100_tx_b_n <= 1'b0;
    else rst100_tx_b_n <= ~(clr_ui_req || clr_tx_busy_rst);
  end
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) tx_busy_100_r <= 1'b0;
    else tx_busy_100_r <= clr_tx_busy_rst;
  end
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) rst_ui_pack_n <= 1'b0;
    else rst_ui_pack_n <= ~debug_clear;
  end
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) rst_ui_tx_a_n <= 1'b0;
    else rst_ui_tx_a_n <= rst_ui_pack_n && !busy_u1;
  end

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_rx),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data),
    .flush(uart_flush), .idle(rx_idle), .rx_sync()
  );

  word_fifo32 #(.DEPTH(128)) u_rfifo (
    .clk(clk100), .rst_n(rst100_n),
    .wr_valid(w_valid && !clr_take && !clr_hold && !dump_take),
    .wr_ready(fifo_wr_ready), .wr_data(w_data),
    .rd_valid(f_valid), .rd_ready(f_ready), .rd_data(f_data),
    .flush(fifo_flush), .empty(fifo_empty)
  );

  logic q_taking, qh_in_ready;
  logic uart_q_valid, uart_q_ready, uart_r_ready;
  logic uart_tx_valid, uart_tx_ready;
  logic [31:0] uart_tx_data;
  logic [7:0] uart_q_bytes [0:31];
  logic [7:0] dummy_r [0:47];

  uart_fe256_host u_qhost (
    .clk(clk100), .rst_n(rst100_pack_n),
    .in_valid(1'b0),
    .in_ready(qh_in_ready), .in_data(f_data),
    .taking(q_taking),
    .q_valid(uart_q_valid), .q_ready(uart_q_ready), .q_bytes(uart_q_bytes),
    .r_valid(1'b0), .r_ready(uart_r_ready), .r_bytes(dummy_r),
    .tx_valid(uart_tx_valid), .tx_ready(uart_tx_ready), .tx_data(uart_tx_data)
  );
  assign uart_q_ready = 1'b1;

  logic cdc_a_ready, p_valid, p_ready;
  logic [31:0] p_data_i;
  word_cdc32 u_cdc (
    .a_clk(clk100), .a_rst_n(rst100_pack_n),
    .a_valid(f_valid && !q_taking && !clr_take && !clr_hold && steer_pack),
    .a_ready(cdc_a_ready), .a_data(f_data),
    .b_clk(ui_clk), .b_rst_n(rst_ui_pack_n),
    .b_valid(p_valid), .b_ready(p_ready), .b_data(p_data_i),
    .a_idle(cdc_a_idle), .b_idle(cdc_b_idle)
  );
  assign w_ready = clr_take || dump_take || (!clr_hold && fifo_wr_ready);
  assign f_ready = q_taking ? qh_in_ready :
                   (steer_pack ? cdc_a_ready :
                    ((f_valid && pack_begin && !dest_accept) ? 1'b0 : 1'b1));

  logic pack_busy;
  logic [27:0] p_addr, d_addr;
  logic [2:0] p_cmd, d_cmd;
  logic p_en, d_en, p_end, d_end, p_wren, d_wren, p_rdv, d_rdv, p_rdy, d_rdy, p_wdf_rdy, d_wdf_rdy;
  logic d_rd_end;
  logic [127:0] p_wdata, d_wdata, p_rdata, d_rdata, b_rdata;
  logic [15:0] p_mask, d_mask;
  logic [15:0] wr_outstanding;
  logic b_rdv, b_rdy, b_wdf_rdy;

  pack_mig_bind u_ld (
    .clk(ui_clk), .rst_n(rst_ui_n), .debug_clear, .calib_done(calib_ui),
    .s_valid(p_valid), .s_ready(p_ready), .s_data(p_data_i),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy(pack_busy), .pack_quiescent(qsc_ui),
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en),
    .app_wdf_data(p_wdata), .app_wdf_end(p_end), .app_wdf_mask(p_mask), .app_wdf_wren(p_wren),
    .app_rd_data(p_rdata), .app_rd_data_valid(p_rdv), .app_rdy(p_rdy), .app_wdf_rdy(p_wdf_rdy),
    .dest_ui_rdy(d_rdy), .dest_ui_wdf_rdy(d_wdf_rdy)
  );

  mig_ui_mux u_mux (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .a_busy(pack_busy), .a_addr(p_addr), .a_cmd(p_cmd), .a_en(p_en),
    .a_wdf_data(p_wdata), .a_wdf_end(p_end), .a_wdf_mask(p_mask), .a_wdf_wren(p_wren),
    .a_rd_data(p_rdata), .a_rd_valid(p_rdv), .a_rdy(p_rdy), .a_wdf_rdy(p_wdf_rdy),
    .b_busy(1'b0), .b_addr(28'h0), .b_cmd(3'h0), .b_en(1'b0),
    .b_wdf_data(128'h0), .b_wdf_end(1'b0), .b_wdf_mask(16'h0), .b_wdf_wren(1'b0),
    .b_rd_data(b_rdata), .b_rd_valid(b_rdv), .b_rdy(b_rdy), .b_wdf_rdy(b_wdf_rdy),
    .d_addr, .d_cmd, .d_en, .d_wdf_data(d_wdata), .d_wdf_end(d_end),
    .d_wdf_mask(d_mask), .d_wdf_wren(d_wren),
    .d_rd_data(d_rdata), .d_rd_valid(d_rdv), .d_rdy, .d_wdf_rdy
  );

  mig_ui_bram u_dest (
    .clk(ui_clk), .rst_n(rst_ui_n), .calib_done(calib_ui), .stall(dest_stall),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdata), .app_wdf_end(d_end), .app_wdf_mask(d_mask), .app_wdf_wren(d_wren),
    .app_rd_data(d_rdata), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rdv),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );

  logic ack_d, nak_d, st_valid_ui, st_ready_ui;
  logic [31:0] st_data_ui;
  always_ff @(posedge ui_clk or negedge rst_ui_pack_n) begin
    if (!rst_ui_pack_n) begin
      ack_d <= 1'b0;
      nak_d <= 1'b0;
      st_valid_ui <= 1'b0;
      st_data_ui <= 32'h0;
    end else begin
      ack_d <= load_ack;
      nak_d <= load_reject;
      if (!rst_ui_tx_a_n)
        st_valid_ui <= 1'b0;
      else if (st_valid_ui && st_ready_ui) st_valid_ui <= 1'b0;
      else if (!st_valid_ui) begin
        if (load_ack && !ack_d) begin
          st_data_ui <= {8'h01, 8'h00, reason_code, 8'hA5};
          st_valid_ui <= 1'b1;
        end else if (load_reject && !nak_d) begin
          st_data_ui <= {8'h02, 8'h00, reason_code, 8'h5A};
          st_valid_ui <= 1'b1;
        end
      end
    end
  end

  logic [31:0] st_data_100;
  word_cdc32 u_cdc_tx (
    .a_clk(ui_clk), .a_rst_n(rst_ui_tx_a_n),
    .a_valid(st_valid_ui), .a_ready(st_ready_ui), .a_data(st_data_ui),
    .b_clk(clk100), .b_rst_n(rst100_tx_b_n),
    .b_valid(st_valid_100), .b_ready(st_ready_100), .b_data(st_data_100),
    .a_idle(tx_a_idle), .b_idle(tx_b_idle)
  );

  assign qsc_100 = qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid;

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      pack_lock <= 1'b0;
    else if (uart_flush || cdc_rst_100)
      pack_lock <= 1'b0;
    else if (st_fire)
      pack_lock <= 1'b0;
    else if (f_valid && f_ready && !q_taking && pack_begin && dest_accept)
      pack_lock <= 1'b1;
  end

  logic        tap_b_valid, tap_b_ready;
  logic [31:0] tap_b_data;
  (* ASYNC_REG = "TRUE" *) logic cv0, cv_ui;
  logic [15:0] epoch_ui;
  logic        commit_event, same_ep, flip_present, gen_flip, commit_seen, cap_at;
  logic [31:0] gbefore, gafter;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      cv0 <= 1'b0; cv_ui <= 1'b0; epoch_ui <= 16'h0;
    end else begin
      cv0 <= obs_capture_valid; cv_ui <= cv0;
      if (obs_arm_ui) epoch_ui <= obs_epoch;
    end
  end
  pack_obs_gen u_obs_gen (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .capture_valid(cv_ui), .epoch_id(epoch_ui),
    .debug_clear, .commit_pulse, .active_generation,
    .commit_event, .generation_before(gbefore), .generation_after(gafter),
    .same_capture_epoch(same_ep), .flip_present, .generation_flipped(gen_flip),
    .commit_seen, .capture_valid_at(cap_at)
  );
  pack_obs_dump u_dump (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_100(obs_arm_100), .arm_ui(obs_arm_ui),
    .freeze, .freeze_reason,
    .uart_fire, .uart_data(w_data),
    .p_fire, .p_data(p_data_i),
    .gen_commit_seen(commit_seen), .gen_same_epoch(same_ep),
    .gen_cap_valid(cap_at), .gen_flipped(gen_flip), .gen_epoch(epoch_ui),
    .gen_before(gbefore), .gen_after(gafter),
    .tap_b_valid, .tap_b_ready, .tap_b_data
  );

  logic mux_valid, mux_ready;
  logic [31:0] mux_data;
  assign mux_valid = clr_ack_valid | uart_tx_valid | st_valid_100 | tap_b_valid;
  assign mux_data  = clr_ack_valid ? clr_ack_data :
                     (uart_tx_valid ? uart_tx_data :
                      (st_valid_100 ? st_data_100 : tap_b_data));
  assign clr_ack_ready = mux_ready && !uart_flush;
  assign uart_tx_ready = (!clr_ack_valid) && uart_tx_valid && mux_ready;
  assign st_ready_100  = (!clr_ack_valid) && (!uart_tx_valid) && mux_ready;
  assign tap_b_ready   = (!clr_ack_valid) && (!uart_tx_valid) && (!st_valid_100) && mux_ready;

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk(clk100), .rst_n(rst100_n),
    .w_valid(mux_valid), .w_ready(mux_ready), .w_data(mux_data),
    .flush(uart_flush), .tx(uart_tx)
  );

  assign uart_fire = w_valid && w_ready;
  assign dump_pulse = dump_take && w_ready;
  assign clr_event = clr_take;
  assign fifo_wr_fire = w_valid && !clr_take && !clr_hold && !dump_take && fifo_wr_ready;
  assign fifo_wr_data = w_data;
  assign fifo_rd_fire = f_valid && f_ready && !q_taking && !clr_take && !clr_hold;
  assign fifo_rd_data = f_data;
  assign cdc_a_fire = f_valid && f_ready && !q_taking && !clr_take && !clr_hold && steer_pack;
  assign cdc_a_data = f_data;
  assign p_fire = p_valid && p_ready;
  assign p_data = p_data_i;

  // Observe-only CONTROL/STATE/TERMINAL. Hierarchical peek of pack_loader;
  // product pack_loader.sv is not modified. PROGRAM=NO.
  logic flush_d, lock_d, rst_d, hold_d;
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      flush_d <= 1'b0;
      lock_d <= 1'b0;
      rst_d <= 1'b0;
      hold_d <= 1'b0;
    end else begin
      flush_d <= uart_flush;
      lock_d <= pack_lock;
      rst_d <= cdc_rst_100;
      hold_d <= clr_hold;
    end
  end
  wire flush_rise = uart_flush && !flush_d;
  wire lock_edge  = pack_lock ^ lock_d;
  wire rst_rise   = cdc_rst_100 && !rst_d;
  wire hold_rise  = clr_hold && !hold_d;
  assign ctrl_fire  = clr_take || flush_rise || lock_edge || rst_rise || hold_rise;
  assign ctrl_data  = w_data;
  assign ctrl_flags = {11'h0, rst_rise, lock_edge, uart_flush, clr_hold, clr_take};

  wire [3:0]  ld_state  = u_ld.u_ld.state;
  wire [7:0]  ld_opcode = u_ld.u_ld.opcode;
  wire [15:0] ld_rx     = u_ld.u_ld.rx_words;
  wire        ld_got    = u_ld.u_ld.got_begin;
  wire        ld_slot   = u_ld.u_ld.slot_bit;
  wire [31:0] ld_hw0    = u_ld.u_ld.hw0;

  logic [3:0] st_d;
  logic       got_d, ack_d2, nak_d2;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      st_d <= 4'h0;
      got_d <= 1'b0;
      ack_d2 <= 1'b0;
      nak_d2 <= 1'b0;
    end else begin
      st_d <= ld_state;
      got_d <= ld_got;
      ack_d2 <= load_ack;
      nak_d2 <= load_reject;
    end
  end
  assign state_fire  = (ld_state != st_d) || (ld_got && !got_d);
  assign state_data  = {ld_hw0[3:0], ld_state, ld_opcode, ld_rx};
  assign state_flags = {13'h0, ld_slot, ld_got, 1'b1};
  assign commit_pulse = (ld_state == 4'd7);
  wire ack_rise = load_ack && !ack_d2;
  wire nak_rise = load_reject && !nak_d2;
  assign term_fire  = commit_pulse || ack_rise || nak_rise;
  assign term_data  = {active_generation[15:0], reason_code, 8'h0};
  assign term_flags = {13'h0, nak_rise, ack_rise, commit_pulse};
  assign debug_clear_o = debug_clear;
endmodule
