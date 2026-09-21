// tb_rkb05_edge.sv — AGENT_D. RKB-05 generation switch, dest-backed walk.
// Warm dest T1 on A→B, COMMIT A→C, query without host t1_flush / T1 poke.
// Result must be C. T1 is dest-filled cache only; host does not write T1.
// PROGRAM=NO. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_rkb05_edge;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam integer MAXW = 160;
  localparam integer SLOT0_EDGE0 = 5;
  localparam integer SLOT1_EDGE0 = 1029;

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        s_valid, s_ready, load_ack, load_reject, pack_quiescent;
  logic [31:0] s_data, active_generation;
  logic [7:0]  reason_code;
  logic        q_valid, q_ready, r_valid, r_ready, hit, dest_rd_pulse, t1_valid, root_valid;
  logic [7:0]  q_bytes [0:31];
  logic [31:0] first_neighbor;
  logic [27:0] published_root;

  pack_edge_dut u_dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .pack_quiescent,
    .q_valid, .q_ready, .q_bytes, .r_valid, .r_ready, .hit, .first_neighbor,
    .dest_rd_pulse, .t1_valid, .t1_flush(1'b0), .root_valid, .published_root
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

  integer fdj, rkb05, h_b, h_c, rd_b, rd_c, t1_b, t1_after_c, t1_c;
  logic [31:0] n_b, n_c;
  logic [27:0] pub_b, pub_c;
  logic [127:0] e0_slot0, e0_slot1, leftover_b;

  initial begin
    s_valid = 1'b0;
    s_data = 32'h0;
    q_valid = 1'b0;
    r_ready = 1'b0;
    dest_rd_win = 0;
    ack_seen = 1'b0;
    nack_seen = 1'b0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    dest_rd_win = 0;
    load_mem("ct1/RKB04-A2B-EDGE.mem");
    pub_b = published_root;
    dest_rd_win = 0;
    do_query();
    h_b = hit;
    n_b = first_neighbor;
    rd_b = dest_rd_win;
    t1_b = t1_valid;
    e0_slot0 = u_dut.u_dest.dest[SLOT0_EDGE0];
    $display("RKB-05 A2B hit=%0d nb=%08x dest_rd=%0d t1=%0d pub=%07h gen=%08x edge0=%032h",
             h_b, n_b, rd_b, t1_b, pub_b, active_generation, e0_slot0);

    dest_rd_win = 0;
    load_mem("ct1/RKB05-A2C-EDGE.mem");
    pub_c = published_root;
    t1_after_c = t1_valid;
    e0_slot1 = u_dut.u_dest.dest[SLOT1_EDGE0];
    leftover_b = u_dut.u_dest.dest[SLOT0_EDGE0];
    $display("RKB-05 after A2C COMMIT t1=%0d pub=%07h gen=%08x leftover_slot0_edge=%032h slot1_edge=%032h (no host flush)",
             t1_after_c, pub_c, active_generation, leftover_b, e0_slot1);

    dest_rd_win = 0;
    do_query();
    h_c = hit;
    n_c = first_neighbor;
    rd_c = dest_rd_win;
    t1_c = t1_valid;
    $display("RKB-05 query after C hit=%0d nb=%08x dest_rd=%0d t1=%0d",
             h_c, n_c, rd_c, t1_c);

    rkb05 = (ack_seen && !nack_seen && (h_b == 1) && (n_b == NB_B) && (rd_b >= 4) &&
             (t1_b == 1) && (t1_after_c == 0) &&
             (h_c == 1) && (n_c == NB_C) && (rd_c >= 4) && (t1_c == 1) &&
             (pub_c != pub_b) && (e0_slot0[63:32] == NB_B) &&
             (leftover_b[63:32] == NB_B) && (e0_slot1[63:32] == NB_C) &&
             (active_generation == 32'h0000_00C1)) ? 1 : 0;

    fdj = $fopen("RKB05_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-RKB05-STALE-T1\",\n");
    $fwrite(fdj, "  \"LANGUAGE\": \"EN\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"host_write_T1\": \"NO\",\n");
    $fwrite(fdj, "  \"T1_ON_ANSWER_PATH\": \"NO dest-walk always\",\n");
    $fwrite(fdj, "  \"RKB05_XSIM\": %0d,\n", rkb05);
    $fwrite(fdj, "  \"a2b\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"t1_valid\": %0d, \"pub\": \"%07h\"},\n",
           h_b, n_b, rd_b, t1_b, pub_b);
    $fwrite(fdj, "  \"after_a2c_commit_t1_valid\": %0d,\n", t1_after_c);
    $fwrite(fdj, "  \"leftover_slot0_edge_dst\": \"%08x\",\n", leftover_b[63:32]);
    $fwrite(fdj, "  \"slot1_edge_dst\": \"%08x\",\n", e0_slot1[63:32]);
    $fwrite(fdj, "  \"a2c_query\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"t1_valid\": %0d, \"pub\": \"%07h\"}\n",
           h_c, n_c, rd_c, t1_c, pub_c);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (rkb05)
      $display("RKB-05 PASS_XSIM");
    else
      $display("RKB-05 FAIL_XSIM rkb05=%0d h_b=%0d n_b=%08x t1_b=%0d t1_ac=%0d h_c=%0d n_c=%08x rd_c=%0d",
               rkb05, h_b, n_b, t1_b, t1_after_c, h_c, n_c, rd_c);
    $finish;
  end
endmodule
