// tb_e_rtl_audit.sv — AGENT_E ANALYSIS_ONLY XSim. Not PACK_ABI / not BOARD.
// Handshake + leftover opcode. No mig0. Not a PASS stamp.
`timescale 1ns/1ps

module tb_e_rtl_audit;
  localparam logic [31:0] CLR = 32'h44524743;
  localparam logic [31:0] MAGIC = 32'h3149414E;
  localparam string LOGP = "D:/FPGA/debug-463f7f.log";

  logic clk, rst_n;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  integer logf, pass, fail, n;
  integer max_used, wr_while_nready, pops, accepts;

  task automatic dlog(input string hid, input string loc, input string msg, input string data);
    begin
      $fwrite(logf,
        "{\"sessionId\":\"463f7f\",\"runId\":\"e-rtl-xsim\",\"hypothesisId\":\"%s\",\"location\":\"%s\",\"message\":\"%s\",\"data\":%s,\"timestamp\":%0d}\n",
        hid, loc, msg, data, $time);
      $fflush(logf);
    end
  endtask

  // --- CLEAR + FIFO (top handshake copy) ---
  logic w_valid, w_ready;
  logic [31:0] w_data;
  logic clr_take, clr_hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic clr_ack_valid, clr_ack_ready;
  logic [31:0] clr_ack_data;
  logic fifo_wr_ready, f_valid, f_ready, fifo_empty;
  logic [31:0] f_data;
  logic [8:0] used_probe, used_live;
  logic fifo_wr_ready_live;
  logic pack_qsc;
  logic rd_ready_force;
  logic w_ready_live;

  assign used_probe = u_fifo.used;

  logic stall_ui_ack;
  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid(w_valid), .in_data(w_data),
    .take(clr_take), .hold(clr_hold),
    .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack(stall_ui_ack ? 1'b0 : ui_ack), .ui_nack,
    .pack_quiescent(pack_qsc),
    .uart_rx_mark(1'b1),
    .ack_valid(clr_ack_valid), .ack_ready(clr_ack_ready), .ack_data(clr_ack_data)
  );

  pack_clear_ui u_ui (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  word_fifo32 #(.DEPTH(128)) u_fifo (
    .clk, .rst_n,
    .wr_valid(w_valid && !clr_take), .wr_ready(fifo_wr_ready), .wr_data(w_data),
    .rd_valid(f_valid), .rd_ready(f_ready), .rd_data(f_data),
    .flush(uart_flush), .empty(fifo_empty)
  );

  logic f_valid_live, fifo_empty_live;
  logic [31:0] f_data_live;
  // Live PACKAGE formula (D handshake patch). Not on SRAM bbba86c1.
  word_fifo32 #(.DEPTH(128)) u_fifo_live (
    .clk, .rst_n,
    .wr_valid(w_valid && !clr_take && !clr_hold), .wr_ready(fifo_wr_ready_live),
    .wr_data(w_data),
    .rd_valid(f_valid_live), .rd_ready(1'b0), .rd_data(f_data_live),
    .flush(uart_flush), .empty(fifo_empty_live)
  );
  assign used_live = u_fifo_live.used;
  assign w_ready_live = clr_take || (!clr_hold && fifo_wr_ready_live);

  assign w_ready = clr_take || !clr_hold;
  assign f_ready = rd_ready_force;
  assign clr_ack_ready = 1'b1;

  // --- pack_loader leftover opcode ---
  logic s_valid, s_ready;
  logic [31:0] s_data;
  logic mem_cmd_valid, mem_cmd_ready, mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic load_ack, load_reject;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;
  logic loader_busy;

  pack_loader u_ld (
    .clk, .rst_n,
    .s_valid, .s_ready, .s_data,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .loader_busy
  );
  assign mem_cmd_ready = 1'b1;
  assign mem_resp_err = 1'b0;
  assign mem_rdata = 32'h0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) mem_resp_valid <= 1'b0;
    else mem_resp_valid <= mem_cmd_valid && mem_cmd_ready;
  end

  initial begin
    logf = $fopen(LOGP, "a");
    pass = 0;
    fail = 0;
    pack_qsc = 1'b1;
    stall_ui_ack = 1'b0;
    rst_n = 1'b0;
    w_valid = 1'b0;
    w_data = 32'h0;
    rd_ready_force = 1'b0;
    s_valid = 1'b0;
    s_data = 32'h0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);

    // T1: extra mailbox word during hold, no FIFO pop → used climbs
    dlog("H3", "tb_e_rtl_audit.sv:T1", "hold-flood no-pop start", "{\"rd_ready\":0}");
    rd_ready_force = 1'b0;
    stall_ui_ack = 1'b1;
    @(posedge clk);
    w_data = CLR;
    w_valid = 1'b1;
    @(posedge clk);
    max_used = 0;
    wr_while_nready = 0;
    for (n = 0; n < 300; n = n + 1) begin
      @(posedge clk);
      if (used_probe > max_used) max_used = used_probe;
      if ((w_valid && !clr_take) && !fifo_wr_ready) wr_while_nready = wr_while_nready + 1;
    end
    w_valid = 1'b0;
    dlog("H3", "tb_e_rtl_audit.sv:T1", "hold-flood no-pop result",
         $sformatf("{\"max_used\":%0d,\"wr_nready\":%0d,\"hold\":%0d,\"max_used_live\":%0d}",
                   max_used, wr_while_nready, clr_hold, used_live));
    if (max_used >= 64) begin
      $display("T1 PASS_XSIM snapshot max_used=%0d (flood)", max_used);
      pass = pass + 1;
    end else begin
      $display("T1 FAIL max_used=%0d expected>=64", max_used);
      fail = fail + 1;
    end
    if (used_live == 0) begin
      $display("T1b PASS_XSIM live-formula used_live=0 (hold gated)");
      pass = pass + 1;
    end else begin
      $display("T1b FAIL live-formula used_live=%0d expected 0", used_live);
      fail = fail + 1;
    end

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);

    // T2: same flood but FIFO pops (cdc ready) — used may stay small
    dlog("H3", "tb_e_rtl_audit.sv:T2", "hold-flood with-pop start", "{\"rd_ready\":1}");
    rd_ready_force = 1'b1;
    stall_ui_ack = 1'b1;
    pops = 0;
    accepts = 0;
    max_used = 0;
    @(posedge clk);
    w_data = CLR;
    w_valid = 1'b1;
    @(posedge clk);
    for (n = 0; n < 200; n = n + 1) begin
      @(posedge clk);
      if (used_probe > max_used) max_used = used_probe;
      if (f_valid && f_ready) pops = pops + 1;
    end
    w_valid = 1'b0;
    dlog("H3", "tb_e_rtl_audit.sv:T2", "hold-flood with-pop result",
         $sformatf("{\"max_used\":%0d,\"pops\":%0d}", max_used, pops));
    $display("T2 INFO max_used=%0d pops=%0d (void-pop path)", max_used, pops);
    pass = pass + 1;

    rst_n = 1'b0;
    stall_ui_ack = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    rd_ready_force = 1'b0;
    repeat (4) @(posedge clk);

    // T3: pack path hold=0, fill 129 words, silent drop
    dlog("H3", "tb_e_rtl_audit.sv:T3", "fifo-full silent drop start", "{}");
    for (n = 0; n < 129; n = n + 1) begin
      w_data = 32'h00800001;
      w_valid = 1'b1;
      @(posedge clk);
    end
    w_valid = 1'b0;
    dlog("H3", "tb_e_rtl_audit.sv:T3", "fifo-full result",
         $sformatf("{\"used\":%0d,\"wr_ready\":%0d,\"used_live\":%0d,\"w_ready_live\":%0d}",
                   used_probe, fifo_wr_ready, used_live, w_ready_live));
    if (used_probe == 128 && w_ready == 1'b1) begin
      $display("T3 PASS_XSIM snapshot used=128 w_ready=1 silent-drop possible");
      pass = pass + 1;
    end else begin
      $display("T3 FAIL used=%0d w_ready=%0d", used_probe, w_ready);
      fail = fail + 1;
    end
    if (used_live == 128 && w_ready_live == 1'b0) begin
      $display("T3b PASS_XSIM live-formula used=128 w_ready_live=0 backpressure");
      pass = pass + 1;
    end else begin
      $display("T3b FAIL used_live=%0d w_ready_live=%0d", used_live, w_ready_live);
      fail = fail + 1;
    end

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T4: leftover CLEAR at pack_loader S_IDLE → R_UNSUP 0x07
    dlog("H2", "tb_e_rtl_audit.sv:T4", "leftover CLEAR opcode", "{}");
    s_data = CLR;
    s_valid = 1'b1;
    @(posedge clk);
    s_valid = 1'b0;
    begin : t4wait
      for (n = 0; n < 20000; n = n + 1) begin
        @(posedge clk);
        if (load_reject) disable t4wait;
      end
    end
    dlog("H2", "tb_e_rtl_audit.sv:T4", "leftover CLEAR result",
         $sformatf("{\"reject\":%0d,\"reason\":\"%02h\"}", load_reject, reason_code));
    if (load_reject && reason_code == 8'h07) begin
      $display("T4 PASS_XSIM leftover CLEAR -> R_UNSUP");
      pass = pass + 1;
    end else begin
      $display("T4 FAIL reject=%0d rc=%02h", load_reject, reason_code);
      fail = fail + 1;
    end

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T5: MAGIC as opcode (dropped BEGIN) → R_UNSUP
    dlog("H2", "tb_e_rtl_audit.sv:T5", "MAGIC as opcode", "{}");
    s_data = MAGIC;
    s_valid = 1'b1;
    @(posedge clk);
    s_valid = 1'b0;
    begin : t5wait
      for (n = 0; n < 20000; n = n + 1) begin
        @(posedge clk);
        if (load_reject) disable t5wait;
      end
    end
    dlog("H2", "tb_e_rtl_audit.sv:T5", "MAGIC-as-opcode result",
         $sformatf("{\"reject\":%0d,\"reason\":\"%02h\"}", load_reject, reason_code));
    if (load_reject && reason_code == 8'h07) begin
      $display("T5 PASS_XSIM MAGIC-as-opcode -> R_UNSUP");
      pass = pass + 1;
    end else begin
      $display("T5 FAIL reject=%0d rc=%02h", load_reject, reason_code);
      fail = fail + 1;
    end

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T6: S_REJECT absorbing — second CLEAR produces no new reject edge
    dlog("H5", "tb_e_rtl_audit.sv:T6", "S_REJECT absorbing", "{}");
    s_data = CLR;
    s_valid = 1'b1;
    @(posedge clk);
    s_valid = 1'b0;
    begin : t6a
      for (n = 0; n < 20000; n = n + 1) begin
        @(posedge clk);
        if (load_reject) disable t6a;
      end
    end
    begin : t6b
      logic saw_ack, saw_new;
      saw_ack = load_ack;
      s_data = CLR;
      s_valid = 1'b1;
      @(posedge clk);
      s_valid = 1'b0;
      saw_new = 1'b0;
      for (n = 0; n < 64; n = n + 1) begin
        @(posedge clk);
        if (load_ack && !saw_ack) saw_new = 1'b1;
      end
      dlog("H5", "tb_e_rtl_audit.sv:T6", "S_REJECT second CLEAR",
           $sformatf("{\"load_reject\":%0d,\"new_ack\":%0d,\"busy\":%0d}", load_reject, saw_new, loader_busy));
      if (load_reject && !saw_new) begin
        $display("T6 PASS_XSIM S_REJECT eats second CLEAR no new ACK");
        pass = pass + 1;
      end else begin
        $display("T6 FAIL reject=%0d new_ack=%0d", load_reject, saw_new);
        fail = fail + 1;
      end
    end

    if (fail == 0)
      $display("E_RTL_AUDIT_XSIM_PASS %0d (not PACK_ABI_24_24_PASS / not BOARD_PASS)", pass);
    else
      $display("E_RTL_AUDIT_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $fclose(logf);
    $finish;
  end
endmodule
