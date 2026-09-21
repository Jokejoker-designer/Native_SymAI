// tb_rkb_edge_integrated.sv — RKB-01..08 on unique Arty top (RKB_EDGE_XSIM: mig_ui_bram).
// Bitstream uses real mig0. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
// Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not BOARD_PASS.
`timescale 1ns/1ps

module tb_codex_rkb01_delta;
  string audit_mem;
  integer audit_expect;
  integer audit_p_index = 0;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam logic [31:0] CLEAR_CMD = 32'h44524743;
  localparam logic [31:0] FLSH_CMD  = 32'h464C5348;
  localparam integer MAXW = 160;
  localparam integer SLOT0_E0 = 5;
  localparam integer SLOT0_E1 = 6;
  localparam integer SLOT1_E0 = 1029;
  localparam integer SLOT1_E1 = 1030;

  logic CLK100MHZ = 1'b0;
  logic ck_rst = 1'b0;
  logic uart_rx = 1'b1;
  logic uart_tx;
  logic [3:0] led;
  always #5 CLK100MHZ = ~CLK100MHZ;

  // Unused TB fixtures. Intact C words must not recover a poisoned dest EdgeRecord.
  logic [31:0] fx_dir [0:15];
  logic [31:0] fx_post [0:15];

  arty_a7_r2_top_m4_mig_candidate u_dut (
    .CLK100MHZ, .ck_rst, .uart_rx, .uart_tx, .led,
    .ddr3_dq(), .ddr3_dqs_n(), .ddr3_dqs_p(),
    .ddr3_addr(), .ddr3_ba(), .ddr3_ras_n(), .ddr3_cas_n(), .ddr3_we_n(), .ddr3_reset_n(),
    .ddr3_ck_p(), .ddr3_ck_n(), .ddr3_cke(), .ddr3_cs_n(), .ddr3_dm(), .ddr3_odt()
  );

  logic host_valid;
  logic [31:0] host_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(CLK100MHZ), .rst_n(ck_rst), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(1'b1), .w_data(host_data)
  );
  logic [31:0] hq [0:255];
  integer hq_w, hq_r;
  always @(posedge CLK100MHZ or negedge ck_rst) begin
    if (!ck_rst) hq_w <= 0;
    else if (host_valid && hq_w < 256) begin
      hq[hq_w] <= host_data;
      hq_w <= hq_w + 1;
    end
  end

  integer dest_base;
  integer rkb01, rkb02, rkb03, rkb04, rkb05, rkb06, rkb07, rkb08;
  integer h, n, rd, c, wi, nwords, t, fdj;
  integer h01, n01, rd01, h02a, n02a, rd02a, h02b, n02b, rd02b, h02c, n02c, rd02c;
  integer h03, n03, rd03, h04a, n04a, rd04a, h04b, n04b, rd04b;
  integer h06, n06, rd06, h07, n07, rd07, h08a, n08a, rd08a, h08b, n08b, rd08b;
  integer leftover_b, t1_before_flush, t1_after_flush, gen_before_flush, gen_after_flush;
  logic [127:0] save_e0, save_e1, save_s0e0, save_s0e1;
  logic [31:0] vec [0:MAXW-1];
  logic [31:0] got;
  bit mute;
  logic ack_seen, nack_seen;
  logic [7:0] q_bytes [0:31];

  task automatic uart_byte(input logic [7:0] b);
    integer k;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge CLK100MHZ);
      for (k = 0; k < 8; k++) begin
        uart_rx <= b[k];
        repeat (DIV) @(posedge CLK100MHZ);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge CLK100MHZ);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_word(output logic [31:0] g, input integer maxc, output bit m);
    begin
      c = 0;
      while ((c < maxc) && (hq_r >= hq_w)) begin
        @(posedge CLK100MHZ);
        c = c + 1;
      end
      m = (hq_r >= hq_w);
      g = m ? 32'h0 : hq[hq_r];
      if (!m) hq_r = hq_r + 1;
    end
  endtask

  task automatic wait_tok(input logic [7:0] hi, input logic [7:0] lo, output logic [31:0] g, output bit m);
    begin
      m = 1'b1;
      g = 32'h0;
      begin : scan
        integer tt;
        for (tt = 0; tt < 64; tt++) begin
          wait_word(g, 400_000, m);
          if (m) disable scan;
          if ((g[31:24] == hi) && (g[7:0] == lo)) begin
            m = 1'b0;
            disable scan;
          end
        end
      end
    end
  endtask

  function automatic [15:0] crc16_step(input [15:0] cc, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = cc ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] cc;
    integer ii;
    begin
      cc = 16'hFFFF;
      for (ii = 0; ii < 30; ii++)
        cc = crc16_step(cc, b[ii]);
      crc16_q = cc;
    end
  endfunction

  task automatic send_query;
    integer k;
    logic [15:0] crc;
    logic [31:0] w;
    begin
      for (k = 0; k < 32; k++)
        q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[3] = 8'h00;
      q_bytes[4] = 8'h01;
      q_bytes[14] = SID_A[7:0];
      q_bytes[15] = SID_A[15:8];
      q_bytes[16] = SID_A[23:16];
      q_bytes[17] = SID_A[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
      for (k = 0; k < 8; k++) begin
        w = {q_bytes[4*k+3], q_bytes[4*k+2], q_bytes[4*k+1], q_bytes[4*k]};
        send_word(w);
      end
    end
  endtask

  task automatic do_query;
    begin
      send_query();
      wait_tok(8'h03, 8'h51, got, mute);
      if (mute)
        $fatal(1, "query token mute");
      repeat (8) @(posedge CLK100MHZ);
    end
  endtask

  task automatic load_mem(input string path);
    integer fd, rc;
    logic [31:0] w;
    begin
      ack_seen = 1'b0;
      nack_seen = 1'b0;
      fd = $fopen(path, "r");
      if (fd == 0)
        $fatal(1, "open %s", path);
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > MAXW)
        $fatal(1, "bad count %s", path);
      for (wi = 0; wi < nwords; wi++) begin
        rc = $fscanf(fd, "%h", w);
        if (rc != 1)
          $fatal(1, "short %s", path);
        vec[wi] = w;
      end
      $fclose(fd);
      for (wi = 0; wi < nwords; wi++)
        send_word(vec[wi]);
      wait_tok(8'h01, 8'hA5, got, mute);
      if (mute) begin
        wait_tok(8'h02, 8'h5A, got, mute);
        nack_seen = !mute;
        $fatal(1, "pack ACK mute nack=%0d tok=%08h", nack_seen, got);
      end
      ack_seen = 1'b1;
      t = 0;
      while ((t < 20000) && !u_dut.qsc_ui) begin
        @(posedge CLK100MHZ);
        t = t + 1;
      end
      repeat (16) @(posedge CLK100MHZ);
    end
  endtask

  initial begin
    hq_r = 0;
    ck_rst = 1'b0;
    uart_rx = 1'b1;
    repeat (40) @(posedge CLK100MHZ);
    ck_rst = 1'b1;
    repeat (200) @(posedge CLK100MHZ);

    // Board smoke UNSET
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    h01 = u_dut.q_hit;
    n01 = u_dut.q_nb;
    rd01 = u_dut.dest_rd_cnt - dest_base;
    rkb01 = ((u_dut.active_generation == UNSET_GEN) && (h01 == 0) && (n01 == 0) && (rd01 == 0)) ? 1 : 0;
    $display("RKB-UNSET gen=%08x hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d",
             u_dut.active_generation, h01, n01, rd01, got, rkb01);

    // RKB-01 install A->B SLOT0
    if (!$value$plusargs("AUDIT_MEM=%s", audit_mem)) $fatal(1, "AUDIT_MEM missing");
    if (!$value$plusargs("EXPECT_HIT=%d", audit_expect)) $fatal(1, "EXPECT_HIT missing");
    load_mem(audit_mem);
    $display("RKB-01 dest0=%032h dest1=%032h dest2=%032h dest3=%032h dest4=%032h dest5=%032h dest6=%032h",
             u_dut.u_mig.dest[0], u_dut.u_mig.dest[1], u_dut.u_mig.dest[2],
             u_dut.u_mig.dest[3], u_dut.u_mig.dest[4], u_dut.u_mig.dest[5],
             u_dut.u_mig.dest[6]);
    $display("RKB-01 pub=%07h root_v=%0d gen=%08x eval_sid=%08x walk_sid=%08x",
             u_dut.pub_root, u_dut.root_valid, u_dut.active_generation,
             u_dut.eval_sid, u_dut.u_walk.sid_r);
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    $display("RKB-01 post q_hit=%0d q_nb=%08x walk_hit=%0d walk_nb=%08x sid_r=%08x dir_addr=%07h dest_rd_cnt=%0d",
             u_dut.q_hit, u_dut.q_nb, u_dut.u_walk.hit, u_dut.u_walk.neighbor,
             u_dut.u_walk.sid_r, u_dut.u_walk.dir_addr, u_dut.dest_rd_cnt);
    h02a = u_dut.q_hit;
    n02a = u_dut.q_nb;
    rd02a = u_dut.dest_rd_cnt - dest_base;
    rkb01 = rkb01 && ack_seen && (h02a == 1) && (n02a == NB_B) && (rd02a >= 4);
    $display("RKB-01 A2B hit=%0d nb=%08x dest_rd=%0d t1=%0d pub=%07h OK_partial=%0d",
             h02a, n02a, rd02a, u_dut.t1_valid, u_dut.pub_root, rkb01);


    if (u_dut.u_walk.sid_r !== SID_A) $fatal(1, "AUDIT_SID_MISMATCH");
    if (audit_expect == 0) begin
      if (h02a !== 0 || n02a !== 0 || rd02a != 1) $fatal(1, "FAIL_REPLAY_NOT_REPRODUCED");
      $display("CODEX_FAIL_VECTOR_REPRODUCED sid=%08h reads=%0d hit=%0d",u_dut.u_walk.sid_r,rd02a,h02a);
    end else begin
      if (h02a !== 1 || n02a !== NB_B || rd02a != 5) $fatal(1, "CONTROL_NOT_REPRODUCED");
      $display("CODEX_CURRENT_VECTOR_CONTROL sid=%08h reads=%0d hit=%0d nb=%08h",u_dut.u_walk.sid_r,rd02a,h02a,n02a);
    end
    $display("CODEX_DELTA_EXPERIMENT_DONE XSIM_ONLY PROGRAM=NO");
    $finish;
  end
  always @(posedge CLK100MHZ) begin
    if (!ck_rst) audit_p_index <= 0;
    else begin
      if (u_dut.p_valid && u_dut.p_ready) begin
        if (audit_p_index >= 47 && audit_p_index <= 55)
          $display("CODEX_ACCEPT time_ns=%0d word_index=%0d data=%08h",$time,audit_p_index,u_dut.p_data);
        audit_p_index <= audit_p_index+1;
      end
      if (u_dut.eval_req && !u_dut.eval_busy)
        $display("CODEX_CDC_SOURCE time_ns=%0d eval_sid=%08h",$time,u_dut.eval_sid);
      if (u_dut.lookup_go && !u_dut.walk_busy)
        $display("CODEX_LOOKUP time_ns=%0d go=%b sid=%08h root_valid=%b root=%07h",$time,u_dut.lookup_go,u_dut.lookup_sid,u_dut.root_valid,u_dut.pub_root);
      if (u_dut.walk_busy && u_dut.w_en && u_dut.p_rdy)
        $display("CODEX_READ_ACCEPT time_ns=%0d state=%0d sid=%08h addr=%07h",$time,u_dut.u_walk.st,u_dut.u_walk.sid_r,u_dut.w_addr);
      if (u_dut.p_rdv && u_dut.walk_busy)
        $display("CODEX_READ_RETURN time_ns=%0d state=%0d sid=%08h addr=%07h beat=%032h match_dir=%09h",$time,u_dut.u_walk.st,u_dut.u_walk.sid_r,u_dut.w_addr,u_dut.p_rdata,u_dut.u_walk.match_dir(u_dut.p_rdata,u_dut.u_walk.sid_r));
      if (u_dut.lookup_done)
        $display("CODEX_LOOKUP_DONE time_ns=%0d sid=%08h hit=%b neighbor=%08h",$time,u_dut.u_walk.sid_r,u_dut.walk_hit,u_dut.walk_nb);
    end
  end
endmodule

