// tb_rkb08_gen_lifecycle.sv — AGENT_D. XSim only. PROGRAM=NO.
// Test 1 generation lifecycle + Test 2 RKB-08 dir_a.mem poison.
// Does not modify FE256 / ASTRA / Q* / SPEAR / FEM / B gold / C RTL.
// Does not encode predicted CLASS A into pass/fail.
// Not PACK_ABI_24_24_PASS / READBACK_ACTIVE_GENERATION_PASS /
// RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"
`include "pack_abi24_fopen.svh"

module tb_rkb08_gen_lifecycle;
  localparam integer MAXW = 72;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] V04_GEN = 32'h0000_FFFF;
  localparam logic [31:0] Q_SID = 32'h0001_0100;

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        s_valid, s_ready, load_ack, load_reject;
  logic [31:0] s_data, active_generation;
  logic [7:0]  reason_code, query_status, query_reason;
  logic        query_valid, pack_quiescent;

  pack_abi24_mig_dut u_pack (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid, .pack_quiescent
  );

  logic q_valid, q_ready, r_valid, r_ready, hit, oop, mism, cf, mf;
  logic [7:0] q_bytes [0:31];
  logic [31:0] active_id_max, first_nb, first_eref;
  logic [15:0] count;

  query_posting_bind u_q (
    .clk, .rst_n, .q_valid, .q_ready, .q_bytes, .active_id_max,
    .r_valid, .r_ready, .hit, .out_of_profile(oop), .hdr_mismatch(mism),
    .crc_fail(cf), .magic_fail(mf), .count, .first_neighbor(first_nb),
    .first_edge_ref(first_eref)
  );

  integer dest_rd_win, dest_wr_win;
  always @(posedge clk) begin
    if (rst_n && u_pack.app_en && u_pack.app_rdy && (u_pack.app_cmd == 3'b001))
      dest_rd_win = dest_rd_win + 1;
    if (rst_n && u_pack.app_wdf_wren && u_pack.app_wdf_rdy)
      dest_wr_win = dest_wr_win + 1;
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
      for (ii = 0; ii < 30; ii++) c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    integer k;
    logic [15:0] crc;
    begin
      for (k = 0; k < 32; k++) q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[14] = sid[7:0];
      q_bytes[15] = sid[15:8];
      q_bytes[16] = sid[23:16];
      q_bytes[17] = sid[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
    end
  endtask

  task automatic issue_query;
    integer t;
    begin
      dest_rd_win = 0;
      dest_wr_win = 0;
      pack_q(Q_SID);
      q_valid = 1'b1;
      t = 0;
      while (!q_ready && t < 8000) begin @(posedge clk); t = t + 1; end
      @(posedge clk);
      q_valid = 1'b0;
      t = 0;
      while (!r_valid && t < 8000) begin @(posedge clk); t = t + 1; end
    end
  endtask

  task automatic load_v04;
    integer wi, nwords, t, fd, rc;
    integer unsigned wtmp;
    logic [31:0] stream [0:MAXW-1];
    begin
      fd = pa24_fopen_mem(3);
      if (fd == 0) $fatal(1, "cannot open PA24-V-04.mem");
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > MAXW) $fatal(1, "bad V-04 nwords");
      wi = 0;
      while (wi < nwords) begin
        rc = $fscanf(fd, "%h", wtmp);
        if (rc != 1) $fatal(1, "short V-04");
        stream[wi] = wtmp;
        wi = wi + 1;
      end
      $fclose(fd);
      t = 0;
      while (!s_ready && t < 20000) begin @(posedge clk); t = t + 1; end
      for (wi = 0; wi < nwords; wi = wi + 1) begin
        s_data = stream[wi];
        s_valid = 1'b1;
        t = 0;
        while (!s_ready && t < 40000) begin @(posedge clk); t = t + 1; end
        @(posedge clk);
      end
      s_valid = 1'b0;
      t = 0;
      while (!load_ack && !load_reject && t < 200000) begin @(posedge clk); t = t + 1; end
    end
  endtask

  integer jf;
  integer boot_unset_ok, gold_g_ok, rst_unset_ok;
  integer q0_hit, q1_hit, q2_hit, q3_hit;
  logic [31:0] q0_nb, q1_nb, q2_nb, q3_nb, q0_er, q1_er, q2_er, q3_er;
  integer q0_rd, q1_rd, q2_rd, q3_rd;
  integer poison_sid_before;
  string cls;

  initial begin
    s_valid = 1'b0;
    s_data = 32'h0;
    q_valid = 1'b0;
    r_ready = 1'b1;
    active_id_max = 32'hFFFF_FFFF;
    dest_rd_win = 0;
    dest_wr_win = 0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);

    // ---- Test 1 boot/reset ----
    rst_n = 1'b1;
    repeat (4) @(posedge clk);
    boot_unset_ok = (active_generation === UNSET_GEN);
    $display("T1_BOOT gen=%08h UNSET_OK=%0d", active_generation, boot_unset_ok);

    issue_query();
    q0_hit = hit; q0_nb = first_nb; q0_er = first_eref; q0_rd = dest_rd_win;
    $display("T1_Q_BOOT hit=%0d nb=%08h eref=%08h dest_rd=%0d dest_wr=%0d gen=%08h",
             hit, first_nb, first_eref, dest_rd_win, dest_wr_win, active_generation);
    @(posedge clk);

    load_v04();
    gold_g_ok = (load_ack == 1'b1) && (load_reject == 1'b0) &&
                (active_generation === V04_GEN);
    $display("T1_GOLD ack=%0d rej=%0d reason=%02h gen=%08h G_OK=%0d",
             load_ack, load_reject, reason_code, active_generation, gold_g_ok);

    issue_query();
    q1_hit = hit; q1_nb = first_nb; q1_er = first_eref; q1_rd = dest_rd_win;
    $display("T1_Q_GOLD hit=%0d nb=%08h eref=%08h dest_rd=%0d dest_wr=%0d gen=%08h",
             hit, first_nb, first_eref, dest_rd_win, dest_wr_win, active_generation);
    @(posedge clk);

    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);
    rst_unset_ok = (active_generation === UNSET_GEN);
    $display("T1_RST gen=%08h UNSET_OK=%0d", active_generation, rst_unset_ok);

    issue_query();
    q2_hit = hit; q2_nb = first_nb; q2_er = first_eref; q2_rd = dest_rd_win;
    $display("T1_Q_AFTER_RST hit=%0d nb=%08h eref=%08h dest_rd=%0d dest_wr=%0d gen=%08h",
             hit, first_nb, first_eref, dest_rd_win, dest_wr_win, active_generation);
    $display("T1_KNOWLEDGE_AFTER_RST same_as_gold=%0d",
             (q2_hit == q1_hit) && (q2_nb === q1_nb) && (q2_er === q1_er));
    @(posedge clk);

    if (!boot_unset_ok || !gold_g_ok || !rst_unset_ok)
      $fatal(1, "T1 generation register lifecycle failed");

    // ---- Test 2 RKB-08 poison dir_a.mem, Pack dest left as-is ----
    poison_sid_before = u_q.u_post.dir.rom[0][31:0];
    $display("RKB08_POISON_BEFORE sid0=%08h", poison_sid_before);
    u_q.u_post.dir.rom[0][31:0] = 32'h0;
    repeat (2) @(posedge clk);
    $display("RKB08_POISON_AFTER sid0=%08h pack_gen=%08h",
             u_q.u_post.dir.rom[0][31:0], active_generation);

    issue_query();
    q3_hit = hit; q3_nb = first_nb; q3_er = first_eref; q3_rd = dest_rd_win;
    $display("RKB08_Q_POISON_DIR hit=%0d nb=%08h eref=%08h dest_rd=%0d dest_wr=%0d",
             hit, first_nb, first_eref, dest_rd_win, dest_wr_win);

    if ((q3_hit != q2_hit) || (q3_nb !== q2_nb) || (q3_er !== q2_er))
      cls = "A";
    else if (q3_rd > 0)
      cls = "B";
    else
      cls = "C";

    $display("RKB08_CLASS=%s", cls);
    if (cls == "A") begin
      $display("RKB-08 = FAIL_CURRENT_ARCHITECTURE");
      $display("FIRST_DIVERGENCE: Pack S_COMMIT does not install/update runtime semantic directory root/entry.");
      $display("ROOT_CAUSE: DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT");
      $display("STOP: no post_a.mem poison; no RKB-01..07 this run.");
    end

    jf = $fopen("RKB08_OBS.json", "w");
    $fwrite(jf, "{\n");
    $fwrite(jf, "  \"task\": \"D-RKB08-GEN-LIFECYCLE\",\n");
    $fwrite(jf, "  \"program\": \"NO\",\n");
    $fwrite(jf, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(jf, "  \"READBACK_ACTIVE_GENERATION_PASS\": \"NOT_RUN\",\n");
    $fwrite(jf, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(jf, "  \"t1_boot_unset_ok\": %0d,\n", boot_unset_ok);
    $fwrite(jf, "  \"t1_gold_g_ok\": %0d,\n", gold_g_ok);
    $fwrite(jf, "  \"t1_rst_unset_ok\": %0d,\n", rst_unset_ok);
    $fwrite(jf, "  \"q_sid\": \"00010100\",\n");
    $fwrite(jf, "  \"q_boot\": {\"hit\": %0d, \"nb\": \"%08h\", \"eref\": \"%08h\", \"dest_rd\": %0d},\n",
             q0_hit, q0_nb, q0_er, q0_rd);
    $fwrite(jf, "  \"q_gold\": {\"hit\": %0d, \"nb\": \"%08h\", \"eref\": \"%08h\", \"dest_rd\": %0d},\n",
             q1_hit, q1_nb, q1_er, q1_rd);
    $fwrite(jf, "  \"q_after_rst\": {\"hit\": %0d, \"nb\": \"%08h\", \"eref\": \"%08h\", \"dest_rd\": %0d},\n",
             q2_hit, q2_nb, q2_er, q2_rd);
    $fwrite(jf, "  \"q_poison_dir\": {\"hit\": %0d, \"nb\": \"%08h\", \"eref\": \"%08h\", \"dest_rd\": %0d},\n",
             q3_hit, q3_nb, q3_er, q3_rd);
    $fwrite(jf, "  \"knowledge_after_rst_same_as_gold\": %0d,\n",
             (q2_hit == q1_hit) && (q2_nb === q1_nb) && (q2_er === q1_er));
    $fwrite(jf, "  \"poison_sid_before\": \"%08h\",\n", poison_sid_before);
    $fwrite(jf, "  \"rkb08_class\": \"%s\"\n", cls);
    $fwrite(jf, "}\n");
    $fclose(jf);

    if (cls == "A")
      $display("RKB08_STOP_AFTER_DIR_POISON");
    $finish;
  end
endmodule
