// tb_rkb04_edge.sv — AGENT_D. RKB-04 EdgeRecord dereference XSim.
// Same dir/posting; corrupt only EdgeRecord dest beats; fail closed.
// PROGRAM=NO. gold.py not edited. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
`timescale 1ns/1ps

module tb_rkb04_edge;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam integer MAXW = 160;
  localparam integer DIR_IDX = 2;
  localparam integer POST_HDR_IDX = 3;
  localparam integer POST_ENT_IDX = 4;
  localparam integer EDGE0_IDX = 5;
  localparam integer EDGE1_IDX = 6;

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        s_valid, s_ready, load_ack, load_reject, pack_quiescent;
  logic [31:0] s_data, active_generation;
  logic [7:0]  reason_code;
  logic        q_valid, q_ready, r_valid, r_ready, hit, dest_rd_pulse;
  logic [7:0]  q_bytes [0:31];
  logic [31:0] first_neighbor;
  logic        root_valid;
  logic [27:0] published_root;

  pack_edge_dut u_dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .pack_quiescent,
    .q_valid, .q_ready, .q_bytes, .r_valid, .r_ready, .hit, .first_neighbor,
    .dest_rd_pulse, .t1_valid(), .t1_flush(1'b0), .root_valid, .published_root
  );

  integer dest_rd_win;
  logic ack_seen, nack_seen;
  always @(posedge clk) begin
    if (rst_n && dest_rd_pulse) begin
      dest_rd_win = dest_rd_win + 1;
      $display("DEST_RD t=%0t app=%07h widx=%0d dest1=%032h dest3=%032h dest4=%032h dest5=%032h",
               $time, u_dut.d_addr, u_dut.u_dest.widx,
               u_dut.u_dest.dest[DIR_IDX], u_dut.u_dest.dest[POST_ENT_IDX],
               u_dut.u_dest.dest[EDGE0_IDX], u_dut.u_dest.dest[EDGE1_IDX]);
    end
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

  integer fdj, rkb04, h1, h2, rd1, rd2;
  logic [31:0] n1, n2;
  logic [127:0] d1, d2, d3, d4, d5, d1b, d3b, d4b, d5b;
  logic [27:0] pub_s;
  logic rv_s;

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
    pub_s = published_root;
    rv_s = root_valid;
    d1 = u_dut.u_dest.dest[DIR_IDX];
    d2 = u_dut.u_dest.dest[POST_HDR_IDX];
    d3 = u_dut.u_dest.dest[POST_ENT_IDX];
    d4 = u_dut.u_dest.dest[EDGE0_IDX];
    d5 = u_dut.u_dest.dest[EDGE1_IDX];
    $display("LAYOUT pub=%07h rv=%0d dest1=%032h dest2=%032h dest3=%032h dest4=%032h dest5=%032h dest6=%032h",
             pub_s, rv_s, u_dut.u_dest.dest[1], d1, d2, d3, d4, d5);

    dest_rd_win = 0;
    do_query();
    h1 = hit;
    n1 = first_neighbor;
    rd1 = dest_rd_win;
    $display("RKB-04 before poison hit=%0d nb=%08x dest_rd=%0d gen=%08x",
             h1, n1, rd1, active_generation);

    u_dut.u_dest.dest[EDGE0_IDX] = 128'h0;
    u_dut.u_dest.dest[EDGE1_IDX] = 128'h0;
    repeat (4) @(posedge clk);
    d1b = u_dut.u_dest.dest[DIR_IDX];
    d3b = u_dut.u_dest.dest[POST_ENT_IDX];
    d4b = u_dut.u_dest.dest[EDGE0_IDX];
    d5b = u_dut.u_dest.dest[EDGE1_IDX];
    dest_rd_win = 0;
    do_query();
    h2 = hit;
    n2 = first_neighbor;
    rd2 = dest_rd_win;
    $display("RKB-04 after edge poison dest1=%032h dest3=%032h dest4=%032h hit=%0d nb=%08x dest_rd=%0d",
             d1b, d3b, d4b, h2, n2, rd2);

    rkb04 = (ack_seen && !nack_seen && rv_s && (h1 == 1) && (n1 == NB_B) &&
             (rd1 >= 4) && (h2 == 0) && (n2 == 32'h0) && (rd2 >= 3) &&
             (d1b == d1) && (d3b == d3) && (d4b == 128'h0) && (d5b == 128'h0) &&
             (d3[63:32] == NB_B) && (d4[63:32] == NB_B) &&
             (active_generation == 32'h0000_00B1)) ? 1 : 0;

    fdj = $fopen("RKB04_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-RKB04-EDGE-DEREF\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"RKB04_XSIM\": %0d,\n", rkb04);
    $fwrite(fdj, "  \"pub\": \"%07h\",\n", pub_s);
    $fwrite(fdj, "  \"root_valid\": %0d,\n", rv_s);
    $fwrite(fdj, "  \"before\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"dest1\": \"%032h\", \"dest3\": \"%032h\", \"dest4\": \"%032h\"},\n",
           h1, n1, rd1, d1, d3, d4);
    $fwrite(fdj, "  \"after_edge_poison\": {\"hit\": %0d, \"nb\": \"%08x\", \"dest_rd\": %0d, \"dest1\": \"%032h\", \"dest3\": \"%032h\", \"dest4\": \"%032h\"}\n",
           h2, n2, rd2, d1b, d3b, d4b);
    $fwrite(fdj, "}\n");
    $fclose(fdj);

    if (rkb04)
      $display("RKB-04 PASS_XSIM");
    else
      $display("RKB-04 FAIL_XSIM rkb04=%0d h1=%0d n1=%08x rd1=%0d h2=%0d n2=%08x rd2=%0d",
               rkb04, h1, n1, rd1, h2, n2, rd2);
    $finish;
  end
endmodule
