// tb_rkb08_arch.sv — AGENT_D. RKB-08 current-architecture fixture independence.
// Dest-backed Directory → Posting → EdgeRecord. Not query_posting_bind.
// 08A: Pack/T2 C valid; TB fixture poisoned (unused arrays); query still C.
// 08B: dest EdgeRecord poisoned; TB intact fixture holds C; query must not recover C.
// 08C: dest EdgeRecord restored; query C.
// 08D: DUT sources have no $readmemh dir_a.mem/post_a.mem (python precheck).
// PROGRAM=NO. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not PACK_ABI_24_24_PASS.
// Historical 8fc14f25 CLASS A is unchanged. This is pack_edge_dut only.
`timescale 1ns/1ps

module tb_rkb08_arch;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam logic [31:0] GEN_C = 32'h0000_00C1;
  localparam logic [31:0] POISON_NB = 32'hDEAD_BEEF;
  localparam integer MAXW = 160;
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

  // TB-only fixture images. Not connected to pack_edge_dut.
  logic [31:0] fx_dir [0:3];
  logic [31:0] fx_post [0:3];

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

  integer fdj, rkb08a, rkb08b, rkb08c, rkb08, h_a, h_b, h_c, rd_a, rd_b, rd_c;
  logic [31:0] n_a, n_b, n_c, fx_a, fx_b;
  logic [127:0] e0_save, e1_save, ent_b, e0_b, dir_b, post_b;

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

    // ---- 08A: poisoned TB fixture, dest C valid ----
    $readmemh("ct1/rkb08_dir_poison.mem", fx_dir);
    $readmemh("ct1/rkb08_post_poison.mem", fx_post);
    fx_a = fx_dir[1];
    dest_rd_win = 0;
    do_query();
    h_a = hit;
    n_a = first_neighbor;
    rd_a = dest_rd_win;
    $display("RKB-08A dest C fixture_poison nb=%08x hit=%0d dut_nb=%08x dest_rd=%0d gen=%08x",
             fx_a, h_a, n_a, rd_a, active_generation);
    rkb08a = ((h_a == 1) && (n_a == NB_C) && (rd_a >= 4) && (fx_a == POISON_NB) &&
              (active_generation == GEN_C) && (fx_dir[0] == SID_A)) ? 1 : 0;

    // ---- 08B: intact TB fixture holds C; poison dest EdgeRecord only ----
    $readmemh("ct1/rkb08_dir_intact.mem", fx_dir);
    $readmemh("ct1/rkb08_post_intact.mem", fx_post);
    fx_b = fx_dir[1];
    e0_save = u_dut.u_dest.dest[S1_E0];
    e1_save = u_dut.u_dest.dest[S1_E1];
    dir_b = u_dut.u_dest.dest[S1_DIR];
    post_b = u_dut.u_dest.dest[S1_POST];
    ent_b = u_dut.u_dest.dest[S1_ENT];
    u_dut.u_dest.dest[S1_E0] = 128'h0;
    u_dut.u_dest.dest[S1_E1] = 128'h0;
    t1_flush = 1'b1;
    @(posedge clk);
    t1_flush = 1'b0;
    repeat (4) @(posedge clk);
    dest_rd_win = 0;
    do_query();
    h_b = hit;
    n_b = first_neighbor;
    rd_b = dest_rd_win;
    e0_b = u_dut.u_dest.dest[S1_E0];
    $display("RKB-08B dest edge poison fixture_intact nb=%08x hit=%0d dut_nb=%08x dest_rd=%0d ent_nb=%08x e0=%032h",
             fx_b, h_b, n_b, rd_b, ent_b[63:32], e0_b);
    rkb08b = ((h_b == 0) && (n_b != NB_C) && (rd_b >= 3) && (fx_b == NB_C) &&
              (ent_b[63:32] == NB_C) && (e0_b == 128'h0) &&
              (u_dut.u_dest.dest[S1_DIR] == dir_b) &&
              (u_dut.u_dest.dest[S1_POST] == post_b) &&
              (u_dut.u_dest.dest[S1_ENT] == ent_b) &&
              (active_generation == GEN_C)) ? 1 : 0;

    // ---- 08C: restore dest EdgeRecord; fixture still intact C ----
    u_dut.u_dest.dest[S1_E0] = e0_save;
    u_dut.u_dest.dest[S1_E1] = e1_save;
    repeat (4) @(posedge clk);
    dest_rd_win = 0;
    do_query();
    h_c = hit;
    n_c = first_neighbor;
    rd_c = dest_rd_win;
    $display("RKB-08C dest restored hit=%0d dut_nb=%08x dest_rd=%0d gen=%08x",
             h_c, n_c, rd_c, active_generation);
    rkb08c = ((h_c == 1) && (n_c == NB_C) && (rd_c >= 4) &&
              (fx_dir[1] == NB_C) && (active_generation == GEN_C) &&
              (u_dut.u_dest.dest[S1_E0] == e0_save)) ? 1 : 0;

    rkb08 = (ack_seen && !nack_seen && rkb08a && rkb08b && rkb08c) ? 1 : 0;

    fdj = $fopen("RKB08_ARCH_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-RKB08-CURRENT-ARCH-FIXTURE\",\n");
    $fwrite(fdj, "  \"LANGUAGE\": \"EN\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"identity_8fc14f25_CLASS_A\": \"UNCHANGED historical\",\n");
    $fwrite(fdj, "  \"host_write_T1\": \"NO\",\n");
    $fwrite(fdj, "  \"fixture_connected_to_DUT\": \"NO TB arrays only\",\n");
    $fwrite(fdj, "  \"RKB08A_XSIM\": %0d,\n", rkb08a);
    $fwrite(fdj, "  \"RKB08B_XSIM\": %0d,\n", rkb08b);
    $fwrite(fdj, "  \"RKB08C_XSIM\": %0d,\n", rkb08c);
    $fwrite(fdj, "  \"RKB08_ARCH_XSIM\": %0d,\n", rkb08);
    $fwrite(fdj, "  \"a\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"fixture_nb\": \"%08x\"},\n",
           h_a, n_a, rd_a, fx_a);
    $fwrite(fdj, "  \"b\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"fixture_nb\": \"%08x\", \"posting_nb_still_c\": %0d},\n",
           h_b, n_b, rd_b, fx_b, (ent_b[63:32] == NB_C));
    $fwrite(fdj, "  \"c\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d}\n",
           h_c, n_c, rd_c);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (rkb08)
      $display("RKB-08 ARCH PASS_XSIM A=%0d B=%0d C=%0d", rkb08a, rkb08b, rkb08c);
    else
      $display("RKB-08 ARCH FAIL_XSIM A=%0d B=%0d C=%0d h_a=%0d n_a=%08x h_b=%0d n_b=%08x h_c=%0d",
               rkb08a, rkb08b, rkb08c, h_a, n_a, h_b, n_b, h_c);
    $finish;
  end
endmodule
