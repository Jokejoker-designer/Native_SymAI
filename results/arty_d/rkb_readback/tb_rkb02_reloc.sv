// tb_rkb02_reloc.sv — AGENT_D. Dest-complete peek + RKB-02 relocation XSim.
// Pack GOLD dest-handshake then dest-readable; second COMMIT relocates root;
// poison P1 dest; query still hits P2. PROGRAM=NO. gold.py not edited.
// Not PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS /
// READBACK_ACTIVE_GENERATION_PASS / dest_word_export UART.
`timescale 1ns/1ps

module tb_rkb02_reloc;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam integer MAXW = 96;
  localparam integer P1_IDX = 0;
  localparam integer P2_IDX = 1024; // SLOT1_BASE bit20 -> widx {01,000}

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        s_valid, s_ready, load_ack, load_reject, pack_quiescent;
  logic [31:0] s_data, active_generation;
  logic [7:0]  reason_code;
  logic        q_valid, q_ready, r_valid, r_ready, hit, dest_rd_pulse;
  logic [7:0]  q_bytes [0:31];
  logic [31:0] first_neighbor;
  logic        t1_flush, t1_rebuild, t1_valid, root_valid;
  logic [27:0] published_root;

  pack_runtime_dut u_dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .pack_quiescent,
    .q_valid, .q_ready, .q_bytes, .r_valid, .r_ready, .hit, .first_neighbor,
    .dest_rd_pulse, .t1_flush, .t1_rebuild, .t1_valid, .root_valid,
    .published_root
  );

  integer dest_rd_win, dest_hs_win, qphase;
  integer wr_n_p1, wr_n_p2;
  logic ack_seen, nack_seen;
  logic [27:0] q3_app, q3_pub, q3_pend, wr1_p2;
  logic        q3_have, q3_pubv, q3_rv, wr1_p2_v;
  logic [11:0] q3_widx, q3_ridx;
  logic [27:0] samp1_pend, samp2_pend;
  logic        samp1_rv, samp2_rv, samp1_have, samp2_have, samp1_pubv, samp2_pubv;
  always @(posedge clk) begin
    if (rst_n && u_dut.wr_beat_v) begin
      $display("WR_BEAT phase=%0d t=%0t wr_beat=%07h have_wr=%0d pending=%07h pub=%07h",
               qphase, $time, u_dut.wr_beat, u_dut.u_cache.have_wr,
               u_dut.u_cache.pending_root, u_dut.u_cache.pub_root);
      if (qphase == 1)
        wr_n_p1 = wr_n_p1 + 1;
      if (qphase == 2) begin
        wr_n_p2 = wr_n_p2 + 1;
        if (!wr1_p2_v) begin
          wr1_p2 = u_dut.wr_beat;
          wr1_p2_v = 1'b1;
        end
      end
    end
    if (rst_n && dest_rd_pulse) begin
      dest_rd_win = dest_rd_win + 1;
      $display("DEST_RD phase=%0d t=%0t app_addr=%07h pub_root=%07h pending=%07h have_wr=%0d pub_v=%0d root_valid=%0d widx=%03d ridx=%03d d_addr=%07h dest0=%032h dest1024=%032h",
               qphase, $time, u_dut.u_cache.app_addr, u_dut.u_cache.pub_root,
               u_dut.u_cache.pending_root, u_dut.u_cache.have_wr, u_dut.u_cache.pub_v,
               root_valid, u_dut.u_dest.widx, u_dut.u_dest.ridx, u_dut.d_addr,
               u_dut.u_dest.dest[P1_IDX], u_dut.u_dest.dest[P2_IDX]);
      if (qphase == 3) begin
        q3_app  = u_dut.u_cache.app_addr;
        q3_pub  = u_dut.u_cache.pub_root;
        q3_pend = u_dut.u_cache.pending_root;
        q3_have = u_dut.u_cache.have_wr;
        q3_pubv = u_dut.u_cache.pub_v;
        q3_rv   = root_valid;
        q3_widx = u_dut.u_dest.widx;
        q3_ridx = u_dut.u_dest.ridx;
      end
    end
    if (rst_n && !u_dut.cache_busy && u_dut.p_en && u_dut.d_rdy && (u_dut.p_cmd == 3'b001))
      dest_hs_win = dest_hs_win + 1;
    if (load_ack)
      ack_seen = 1'b1;
    if (load_reject)
      nack_seen = 1'b1;
  end

  function automatic sid_in(input logic [127:0] b);
    sid_in = (b[31:0] == SID_A) || (b[63:32] == SID_A) || (b[95:64] == SID_A);
  endfunction

  function automatic [15:0] crc16_step(input [15:0] c, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = c ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii++)
        c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    integer k;
    logic [15:0] crc;
    begin
      for (k = 0; k < 32; k++)
        q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[3] = 8'h00;
      q_bytes[4] = 8'h01;
      q_bytes[14] = sid[7:0];
      q_bytes[15] = sid[15:8];
      q_bytes[16] = sid[23:16];
      q_bytes[17] = sid[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
    end
  endtask

  task automatic do_query;
    integer t;
    begin
      pack_q(SID_A);
      @(posedge clk);
      q_valid = 1'b1;
      t = 0;
      while (!q_ready && t < 2000) begin
        @(posedge clk);
        t = t + 1;
      end
      @(posedge clk);
      q_valid = 1'b0;
      t = 0;
      while (!r_valid && t < 5000) begin
        @(posedge clk);
        t = t + 1;
      end
      r_ready = 1'b1;
      @(posedge clk);
      r_ready = 1'b0;
    end
  endtask

  task automatic load_mem;
    input string path;
    integer fd, rc, nwords, wi, t;
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
      s_valid = 1'b0;
      for (wi = 0; wi < nwords; wi = wi + 1) begin
        rc = $fscanf(fd, "%h", w);
        if (rc != 1)
          $fatal(1, "short %s", path);
        t = 0;
        s_data = w;
        s_valid = 1'b1;
        while (!s_ready && t < 20000) begin
          @(posedge clk);
          t = t + 1;
        end
        @(posedge clk);
      end
      s_valid = 1'b0;
      $fclose(fd);
      t = 0;
      while (!pack_quiescent && t < 50000) begin
        @(posedge clk);
        t = t + 1;
      end
    end
  endtask

  integer fdj;
  integer dc1, rkb02, h1, h2, h3, h4, rd1, rd2, rd3, rd4, hs1, hs2;
  logic [27:0] pub1, pub2;
  logic [31:0] n1, n2, n3, n4;
  logic [127:0] d0_p1, d0_p2, d1k_p2, d0_after;

  initial begin
    s_valid = 1'b0;
    s_data = 32'h0;
    q_valid = 1'b0;
    r_ready = 1'b0;
    t1_flush = 1'b0;
    t1_rebuild = 1'b0;
    dest_rd_win = 0;
    dest_hs_win = 0;
    wr_n_p1 = 0;
    wr_n_p2 = 0;
    wr1_p2_v = 1'b0;
    wr1_p2 = 28'h0;
    q3_app = 28'h0;
    q3_pub = 28'h0;
    q3_pend = 28'h0;
    q3_have = 1'b0;
    q3_pubv = 1'b0;
    q3_rv = 1'b0;
    q3_widx = 12'h0;
    q3_ridx = 12'h0;
    qphase = 0;
    ack_seen = 1'b0;
    nack_seen = 1'b0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    dest_hs_win = 0;
    dest_rd_win = 0;
    qphase = 1;
    load_mem("ct1/CT1-A2B.mem");
    hs1 = dest_hs_win;
    pub1 = published_root;
    samp1_rv = root_valid;
    samp1_pend = u_dut.u_cache.pending_root;
    samp1_have = u_dut.u_cache.have_wr;
    samp1_pubv = u_dut.u_cache.pub_v;
    $display("SAMPLE P1 pub=%07h root_valid=%0d pending=%07h have_wr=%0d pub_v=%0d",
             pub1, samp1_rv, samp1_pend, samp1_have, samp1_pubv);
    d0_p1 = u_dut.u_dest.dest[P1_IDX];
    do_query();
    h1 = hit;
    n1 = first_neighbor;
    rd1 = dest_rd_win;
    dc1 = (ack_seen && !nack_seen && (hs1 >= 1) && sid_in(d0_p1) && (h1 == 1) &&
           (first_neighbor == NB_B) && (rd1 >= 1) && (active_generation != UNSET_GEN)) ? 1 : 0;
    $display("DEST_COMPLETE P1 ack=%0d hs=%0d dest0=%032h pub=%07h hit=%0d nb=%08x dest_rd=%0d OK=%0d",
             ack_seen, hs1, d0_p1, pub1, h1, first_neighbor, rd1, dc1);

    dest_hs_win = 0;
    dest_rd_win = 0;
    qphase = 2;
    load_mem("ct1/CT1-A2B-P2.mem");
    hs2 = dest_hs_win;
    pub2 = published_root;
    samp2_rv = root_valid;
    samp2_pend = u_dut.u_cache.pending_root;
    samp2_have = u_dut.u_cache.have_wr;
    samp2_pubv = u_dut.u_cache.pub_v;
    $display("SAMPLE P2 pub=%07h root_valid=%0d pending=%07h have_wr=%0d pub_v=%0d",
             pub2, samp2_rv, samp2_pend, samp2_have, samp2_pubv);
    d0_p2 = u_dut.u_dest.dest[P1_IDX];
    d1k_p2 = u_dut.u_dest.dest[P2_IDX];
    do_query();
    h2 = hit;
    n2 = first_neighbor;
    rd2 = dest_rd_win;
    $display("RELOC P2 ack=%0d hs=%0d dest0=%032h dest1024=%032h pub=%07h hit=%0d nb=%08x dest_rd=%0d gen=%08x",
             ack_seen, hs2, d0_p2, d1k_p2, pub2, h2, first_neighbor, rd2, active_generation);

    u_dut.u_dest.dest[P1_IDX] = 128'h0;
    u_dut.u_dest.dest[P1_IDX+1] = 128'h0;
    repeat (4) @(posedge clk);
    d0_after = u_dut.u_dest.dest[P1_IDX];
    dest_rd_win = 0;
    qphase = 3;
    do_query();
    h3 = hit;
    n3 = first_neighbor;
    rd3 = dest_rd_win;
    $display("RKB-02 poison P1 dest0=%032h dest1024=%032h hit=%0d nb=%08x dest_rd=%0d",
             d0_after, u_dut.u_dest.dest[P2_IDX], h3, n3, rd3);

    u_dut.u_dest.dest[P2_IDX] = 128'h0;
    u_dut.u_dest.dest[P2_IDX+1] = 128'h0;
    repeat (4) @(posedge clk);
    dest_rd_win = 0;
    qphase = 4;
    do_query();
    h4 = hit;
    n4 = first_neighbor;
    rd4 = dest_rd_win;
    $display("RKB-02 poison P2 dest1024=%032h hit=%0d nb=%08x dest_rd=%0d",
             u_dut.u_dest.dest[P2_IDX], h4, n4, rd4);

    rkb02 = (dc1 && ack_seen && !nack_seen && (hs2 >= 1) &&
             sid_in(d1k_p2) && (d0_after == 128'h0) &&
             (h2 == 1) && (h3 == 1) && (h4 == 0) && (n3 == NB_B) && (n4 == 32'h0) &&
             (rd2 >= 1) && (rd3 >= 1) && (rd4 >= 1) &&
             (active_generation == 32'h0000_00B2)) ? 1 : 0;

    fdj = $fopen("RKB02_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-DEST-COMPLETE-RKB02\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"READBACK_ACTIVE_GENERATION_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"dest_word_export\": \"XSIM_HIERARCHICAL_PEEK\",\n");
    $fwrite(fdj, "  \"PACK_DEST_COMPLETE_XSIM\": %0d,\n", dc1);
    $fwrite(fdj, "  \"RKB02_XSIM\": %0d,\n", rkb02);
    $fwrite(fdj, "  \"p1\": {\"hs\": %0d, \"pub\": \"%07h\", \"dest0\": \"%032h\", \"hit\": %0d, \"dest_rd\": %0d},\n",
           hs1, pub1, d0_p1, h1, rd1);
    $fwrite(fdj, "  \"p2\": {\"hs\": %0d, \"pub\": \"%07h\", \"dest0\": \"%032h\", \"dest1024\": \"%032h\", \"hit\": %0d, \"dest_rd\": %0d},\n",
           hs2, pub2, d0_p2, d1k_p2, h2, rd2);
    $fwrite(fdj, "  \"after_poison_p1\": {\"dest0\": \"%032h\", \"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n",
           d0_after, h3, n3, rd3);
    $fwrite(fdj, "  \"after_poison_p2\": {\"dest1024\": \"%032h\", \"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n",
           u_dut.u_dest.dest[P2_IDX], h4, n4, rd4);
    $fwrite(fdj, "  \"sample_p1\": {\"pub\": \"%07h\", \"root_valid\": %0d, \"pending\": \"%07h\", \"have_wr\": %0d, \"pub_v\": %0d},\n",
           pub1, samp1_rv, samp1_pend, samp1_have, samp1_pubv);
    $fwrite(fdj, "  \"sample_p2\": {\"pub\": \"%07h\", \"root_valid\": %0d, \"pending\": \"%07h\", \"have_wr\": %0d, \"pub_v\": %0d, \"first_wr_beat\": \"%07h\", \"wr_n\": %0d},\n",
           pub2, samp2_rv, samp2_pend, samp2_have, samp2_pubv, wr1_p2, wr_n_p2);
    $fwrite(fdj, "  \"dest_rd_after_poison_p1\": {\"app_addr\": \"%07h\", \"pub_root\": \"%07h\", \"pending\": \"%07h\", \"have_wr\": %0d, \"pub_v\": %0d, \"root_valid\": %0d, \"widx\": %0d, \"ridx\": %0d}\n",
           q3_app, q3_pub, q3_pend, q3_have, q3_pubv, q3_rv, q3_widx, q3_ridx);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (dc1 && rkb02)
      $display("DEST_COMPLETE+RKB-02 PASS_XSIM");
    else
      $display("DEST_COMPLETE+RKB-02 FAIL_XSIM dc1=%0d rkb02=%0d", dc1, rkb02);
    $finish;
  end
endmodule
