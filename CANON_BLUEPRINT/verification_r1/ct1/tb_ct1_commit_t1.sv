// tb_ct1_commit_t1.sv — AGENT_D. XSim CT1-01..05. PROGRAM=NO.
// T1 = cache of committed dest. Host does not write T1.
// Does not modify FE256 / ASTRA / Q* / SPEAR / FEM / B gold / C RTL.
// Not PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
`timescale 1ns/1ps

module tb_ct1_commit_t1;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam integer MAXW = 96;

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

  pack_runtime_dut u_dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .pack_quiescent,
    .q_valid, .q_ready, .q_bytes, .r_valid, .r_ready, .hit, .first_neighbor,
    .dest_rd_pulse, .t1_flush, .t1_rebuild, .t1_valid, .root_valid
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
    end
  endtask

  integer fdj;
  integer ct1_01, ct1_02, ct1_03, ct1_04, ct1_05;
  integer h01, n01, rd01, h02, n02, rd02, h03, n03, rd03, h04, n04, rd04, h05, n05, rd05;
  integer t1_before, t1_after;

  initial begin
    s_valid = 1'b0;
    s_data = 32'h0;
    q_valid = 1'b0;
    r_ready = 1'b0;
    t1_flush = 1'b0;
    t1_rebuild = 1'b0;
    dest_rd_win = 0;
    ack_seen = 1'b0;
    nack_seen = 1'b0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    dest_rd_win = 0;
    do_query();
    h01 = hit;
    n01 = first_neighbor;
    rd01 = dest_rd_win;
    ct1_01 = ((active_generation == UNSET_GEN) && (h01 == 0) && (n01 == 0) && (rd01 == 0)) ? 1 : 0;
    $display("CT1-01 gen=%08x hit=%0d nb=%08x dest_rd=%0d OK=%0d", active_generation, h01, n01, rd01, ct1_01);

    dest_rd_win = 0;
    load_mem("ct1/CT1-A2B.mem");
    $display("CT1-02 dest0=%032h pub=%07h root_v=%0d gen=%08x",
             u_dut.u_dest.dest[0], u_dut.u_cache.pub_root, root_valid, active_generation);
    do_query();
    h02 = hit;
    n02 = first_neighbor;
    rd02 = dest_rd_win;
    ct1_02 = (ack_seen && !nack_seen && (reason_code == 8'h00) && (active_generation != UNSET_GEN) &&
              (h02 == 1) && (n02 == NB_B) && (rd02 >= 1)) ? 1 : 0;
    $display("CT1-02 ack=%0d gen=%08x hit=%0d nb=%08x dest_rd=%0d OK=%0d", ack_seen, active_generation, h02, n02, rd02, ct1_02);

    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);
    dest_rd_win = 0;
    do_query();
    h03 = hit;
    n03 = first_neighbor;
    rd03 = dest_rd_win;
    ct1_03 = ((active_generation == UNSET_GEN) && (h03 == 0) && (n03 == 0) && (rd03 == 0)) ? 1 : 0;
    $display("CT1-03 gen=%08x hit=%0d nb=%08x dest_rd=%0d OK=%0d", active_generation, h03, n03, rd03, ct1_03);

    dest_rd_win = 0;
    load_mem("ct1/CT1-A2C.mem");
    do_query();
    h04 = hit;
    n04 = first_neighbor;
    rd04 = dest_rd_win;
    ct1_04 = (ack_seen && !nack_seen && (active_generation != UNSET_GEN) && (h04 == 1) && (n04 == NB_C) && (rd04 >= 1)) ? 1 : 0;
    $display("CT1-04 ack=%0d gen=%08x hit=%0d nb=%08x dest_rd=%0d OK=%0d", ack_seen, active_generation, h04, n04, rd04, ct1_04);

    t1_before = t1_valid;
    @(posedge clk);
    t1_flush = 1'b1;
    @(posedge clk);
    t1_flush = 1'b0;
    @(posedge clk);
    t1_rebuild = 1'b1;
    repeat (4) @(posedge clk);
    t1_rebuild = 1'b0;
    repeat (200) @(posedge clk);
    t1_after = t1_valid;
    dest_rd_win = 0;
    do_query();
    h05 = hit;
    n05 = first_neighbor;
    rd05 = dest_rd_win;
    // Owner CT1-05: flush/rebuild T1 from same T2 → result identical (T1 is cache, not SoT).
    ct1_05 = ((h05 == 1) && (n05 == NB_C) && (n05 == n04) && (rd05 >= 1)) ? 1 : 0;
    $display("CT1-05 t1_before=%0d t1_after=%0d hit=%0d nb=%08x dest_rd=%0d OK=%0d", t1_before, t1_after, h05, n05, rd05, ct1_05);

    fdj = $fopen("CT1_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-CT1-COMMIT-T1\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"CT1_01\": %0d,\n", ct1_01);
    $fwrite(fdj, "  \"CT1_02\": %0d,\n", ct1_02);
    $fwrite(fdj, "  \"CT1_03\": %0d,\n", ct1_03);
    $fwrite(fdj, "  \"CT1_04\": %0d,\n", ct1_04);
    $fwrite(fdj, "  \"CT1_05\": %0d,\n", ct1_05);
    $fwrite(fdj, "  \"q01\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n", h01, n01, rd01);
    $fwrite(fdj, "  \"q02\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n", h02, n02, rd02);
    $fwrite(fdj, "  \"q03\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n", h03, n03, rd03);
    $fwrite(fdj, "  \"q04\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d},\n", h04, n04, rd04);
    $fwrite(fdj, "  \"q05\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d}\n", h05, n05, rd05);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (ct1_01 && ct1_02 && ct1_03 && ct1_04 && ct1_05)
      $display("CT1-01..05 PASS_XSIM");
    else
      $display("CT1-01..05 FAIL_XSIM");
    $finish;
  end
endmodule
