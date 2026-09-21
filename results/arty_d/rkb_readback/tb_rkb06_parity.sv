// tb_rkb06_parity.sv — AGENT_D. RKB-06 semantic cache parity XSim.
// Warm T1 on G2 A→C, flush T1 only, same SID still C. Dest and generation unchanged.
// Host/TB does not poke t1_sid/t1_nb/t1_v. T1 may refill from dest-walk.
// Warm path still dest-reads: SEMANTIC_PARITY_ONLY, not cache acceleration.
// PROGRAM=NO. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_rkb06_parity;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam logic [31:0] GEN_C = 32'h0000_00C1;
  localparam integer MAXW = 160;
  localparam integer S1_CRC  = 1025;
  localparam integer S1_DIR  = 1026;
  localparam integer S1_POST = 1027;
  localparam integer S1_ENT  = 1028;
  localparam integer S1_E0   = 1029;
  localparam integer S1_E1   = 1030;

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        s_valid, s_ready, load_ack, load_reject, pack_quiescent;
  logic [31:0] s_data, active_generation;
  logic [7:0]  reason_code;
  logic        q_valid, q_ready, r_valid, r_ready, hit, dest_rd_pulse, t1_valid, root_valid;
  logic        t1_flush;
  logic [7:0]  q_bytes [0:31];
  logic [31:0] first_neighbor;
  logic [27:0] published_root;

  pack_edge_dut u_dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .pack_quiescent,
    .q_valid, .q_ready, .q_bytes, .r_valid, .r_ready, .hit, .first_neighbor,
    .dest_rd_pulse, .t1_valid, .t1_flush, .root_valid, .published_root
  );

  integer dest_rd_win;
  logic ack_seen, nack_seen;
  always @(posedge clk) begin
    if (rst_n && dest_rd_pulse)
      dest_rd_win = dest_rd_win + 1;
    if (load_ack)
      ack_seen = 1'b1;
    if (load_reject)
      nack_seen = 1'b1;
  end

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
      repeat (8) @(posedge clk);
    end
  endtask

  integer fdj, rkb06, h_w, h_p, rd_w, rd_p, t1_w, t1_fl, t1_p;
  logic [31:0] n_w, n_p, gen_w, gen_fl, gen_p;
  logic [27:0] pub_w, pub_fl, pub_p, post_w, edge_w, post_p, edge_p;
  logic [127:0] d_crc, d_dir, d_post, d_ent, d_e0, d_e1;
  logic [127:0] a_crc, a_dir, a_post, a_ent, a_e0, a_e1;
  integer dest_same;

  initial begin
    s_valid = 1'b0;
    s_data = 32'h0;
    q_valid = 1'b0;
    r_ready = 1'b0;
    t1_flush = 1'b0;
    dest_rd_win = 0;
    ack_seen = 1'b0;
    nack_seen = 1'b0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    load_mem("ct1/RKB04-A2B-EDGE.mem");
    load_mem("ct1/RKB05-A2C-EDGE.mem");

    dest_rd_win = 0;
    do_query();
    h_w = hit;
    n_w = first_neighbor;
    rd_w = dest_rd_win;
    t1_w = t1_valid;
    gen_w = active_generation;
    pub_w = published_root;
    post_w = u_dut.u_walk.post_addr;
    edge_w = u_dut.u_walk.e0_addr;
    d_crc  = u_dut.u_dest.dest[S1_CRC];
    d_dir  = u_dut.u_dest.dest[S1_DIR];
    d_post = u_dut.u_dest.dest[S1_POST];
    d_ent  = u_dut.u_dest.dest[S1_ENT];
    d_e0   = u_dut.u_dest.dest[S1_E0];
    d_e1   = u_dut.u_dest.dest[S1_E1];
    $display("RKB-06 WARM hit=%0d nb=%08x dest_rd=%0d t1=%0d gen=%08x pub=%07h post=%07h edge=%07h",
             h_w, n_w, rd_w, t1_w, gen_w, pub_w, post_w, edge_w);

    @(posedge clk);
    t1_flush = 1'b1;
    @(posedge clk);
    t1_flush = 1'b0;
    repeat (4) @(posedge clk);
    t1_fl = t1_valid;
    gen_fl = active_generation;
    pub_fl = published_root;
    $display("RKB-06 FLUSH t1=%0d gen=%08x pub=%07h (no dest write, no COMMIT)",
             t1_fl, gen_fl, pub_fl);

    dest_rd_win = 0;
    do_query();
    h_p = hit;
    n_p = first_neighbor;
    rd_p = dest_rd_win;
    t1_p = t1_valid;
    gen_p = active_generation;
    pub_p = published_root;
    post_p = u_dut.u_walk.post_addr;
    edge_p = u_dut.u_walk.e0_addr;
    a_crc  = u_dut.u_dest.dest[S1_CRC];
    a_dir  = u_dut.u_dest.dest[S1_DIR];
    a_post = u_dut.u_dest.dest[S1_POST];
    a_ent  = u_dut.u_dest.dest[S1_ENT];
    a_e0   = u_dut.u_dest.dest[S1_E0];
    a_e1   = u_dut.u_dest.dest[S1_E1];
    dest_same = ((a_crc == d_crc) && (a_dir == d_dir) && (a_post == d_post) &&
                 (a_ent == d_ent) && (a_e0 == d_e0) && (a_e1 == d_e1)) ? 1 : 0;
    $display("RKB-06 POST hit=%0d nb=%08x dest_rd=%0d t1=%0d gen=%08x dest_same=%0d post=%07h edge=%07h",
             h_p, n_p, rd_p, t1_p, gen_p, dest_same, post_p, edge_p);

    rkb06 = (ack_seen && !nack_seen &&
             (h_w == 1) && (n_w == NB_C) && (rd_w >= 4) && (t1_w == 1) &&
             (t1_fl == 0) &&
             (h_p == 1) && (n_p == NB_C) && (rd_p >= 4) && (t1_p == 1) &&
             (gen_w == GEN_C) && (gen_fl == GEN_C) && (gen_p == GEN_C) &&
             (pub_w == pub_fl) && (pub_fl == pub_p) &&
             (post_w == post_p) && (edge_w == edge_p) &&
             (dest_same == 1) && (d_e0[63:32] == NB_C)) ? 1 : 0;

    fdj = $fopen("RKB06_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-RKB06-CACHE-PARITY\",\n");
    $fwrite(fdj, "  \"LANGUAGE\": \"EN\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"CT1_BOARD_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"PROGRAM_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"BOARD_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"host_write_T1\": \"NO\",\n");
    $fwrite(fdj, "  \"static_fixture\": \"NO\",\n");
    $fwrite(fdj, "  \"CACHE_KIND\": \"SEMANTIC_PARITY_ONLY\",\n");
    $fwrite(fdj, "  \"CACHE_ACCELERATION\": \"NO\",\n");
    $fwrite(fdj, "  \"T1_ON_ANSWER_PATH\": \"NO dest-walk always\",\n");
    $fwrite(fdj, "  \"RKB06_XSIM\": %0d,\n", rkb06);
    $fwrite(fdj, "  \"warm\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"t1_valid\": %0d, \"gen\": \"%08x\", \"pub\": \"%07h\", \"posting_ref\": \"%07h\", \"edge_ref\": \"%07h\"},\n",
           h_w, n_w, rd_w, t1_w, gen_w, pub_w, post_w, edge_w);
    $fwrite(fdj, "  \"after_flush\": {\"t1_valid\": %0d, \"gen\": \"%08x\", \"pub\": \"%07h\"},\n",
           t1_fl, gen_fl, pub_fl);
    $fwrite(fdj, "  \"post_flush_query\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"t1_valid\": %0d, \"gen\": \"%08x\", \"pub\": \"%07h\", \"posting_ref\": \"%07h\", \"edge_ref\": \"%07h\"},\n",
           h_p, n_p, rd_p, t1_p, gen_p, pub_p, post_p, edge_p);
    $fwrite(fdj, "  \"dest_unchanged\": %0d\n", dest_same);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (rkb06)
      $display("RKB-06 PASS_XSIM SEMANTIC_PARITY_ONLY");
    else
      $display("RKB-06 FAIL_XSIM rkb06=%0d h_w=%0d n_w=%08x t1_w=%0d t1_fl=%0d h_p=%0d n_p=%08x rd_p=%0d dest_same=%0d",
               rkb06, h_w, n_w, t1_w, t1_fl, h_p, n_p, rd_p, dest_same);
    $finish;
  end
endmodule
