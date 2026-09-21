// tb_ct1_integrated.sv — CT1-01..05 on unique Arty top (CT1_XSIM: mig_ui_bram stand-in).
// Bitstream uses real mig0. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
// Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not CT1_BOARD_PASS.
`timescale 1ns/1ps

module tb_ct1_integrated;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] SID_A = 32'h0001_0100;
  localparam logic [31:0] NB_B  = 32'h0002_0100;
  localparam logic [31:0] NB_C  = 32'h0003_0100;
  localparam integer MAXW = 96;

  logic CLK100MHZ = 1'b0;
  logic ck_rst = 1'b0;
  logic uart_rx = 1'b1;
  logic uart_tx;
  logic [3:0] led;
  always #5 CLK100MHZ = ~CLK100MHZ;

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
  integer ct1_01, ct1_02, ct1_03, ct1_04, ct1_05;
  integer h01, n01, rd01, h02, n02, rd02, h03, n03, rd03, h04, n04, rd04, h05, n05, rd05;
  integer fdj, c, i, nwords, wi;
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
        integer t;
        for (t = 0; t < 64; t++) begin
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
    integer rd0;
    begin
      rd0 = u_dut.dest_rd_cnt;
      send_query();
      wait_tok(8'h03, 8'h51, got, mute);
      if (mute)
        $fatal(1, "query token mute");
    end
  endtask

  task automatic load_mem(input string path);
    integer fd, rc, t;
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
    end
  endtask

  initial begin
    hq_r = 0;
    ck_rst = 1'b0;
    uart_rx = 1'b1;
    repeat (40) @(posedge CLK100MHZ);
    ck_rst = 1'b1;
    repeat (200) @(posedge CLK100MHZ);

    dest_base = u_dut.dest_rd_cnt;
    do_query();
    h01 = u_dut.q_hit;
    n01 = u_dut.q_nb;
    rd01 = u_dut.dest_rd_cnt - dest_base;
    ct1_01 = ((u_dut.active_generation == UNSET_GEN) && (h01 == 0) && (n01 == 0) && (rd01 == 0)) ? 1 : 0;
    $display("CT1-01 gen=%08x hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d",
             u_dut.active_generation, h01, n01, rd01, got, ct1_01);

    load_mem("CT1-A2B.mem");
    $display("CT1-02 dest0=%032h pub=%07h root_v=%0d sid=%08x beat=%032h",
             u_dut.u_mig.dest[0], u_dut.u_cache.pub_root, u_dut.root_valid,
             u_dut.eval_sid, u_dut.u_cache.beat_r);
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    $display("CT1-02 post sid_r=%08x sid_hold=%08x cache_hit=%0d cache_nb=%08x t1_fwd=%08x t1_v=%0d beat=%032h q_hit=%0d q_nb=%08x hit_lat=%0d hit_hold=%0d",
             u_dut.u_cache.sid_r, u_dut.u_qcdc.sid_hold, u_dut.u_cache.hit, u_dut.u_cache.neighbor,
             u_dut.u_cache.t1_fwd, u_dut.u_cache.t1_v, u_dut.u_cache.beat_r, u_dut.q_hit, u_dut.q_nb,
             u_dut.u_qcdc.hit_lat, u_dut.u_qcdc.hit_hold);
    h02 = u_dut.q_hit;
    n02 = u_dut.q_nb;
    rd02 = u_dut.dest_rd_cnt - dest_base;
    ct1_02 = (ack_seen && (u_dut.active_generation != UNSET_GEN) && (h02 == 1) && (n02 == NB_B) && (rd02 >= 1)) ? 1 : 0;
    $display("CT1-02 ack=%0d gen=%08x hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d",
             ack_seen, u_dut.active_generation, h02, n02, rd02, got, ct1_02);

    ck_rst = 1'b0;
    repeat (40) @(posedge CLK100MHZ);
    ck_rst = 1'b1;
    hq_r = 0;
    repeat (200) @(posedge CLK100MHZ);
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    h03 = u_dut.q_hit;
    n03 = u_dut.q_nb;
    rd03 = u_dut.dest_rd_cnt - dest_base;
    ct1_03 = ((u_dut.active_generation == UNSET_GEN) && (h03 == 0) && (n03 == 0) && (rd03 == 0)) ? 1 : 0;
    $display("CT1-03 gen=%08x hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d",
             u_dut.active_generation, h03, n03, rd03, got, ct1_03);

    load_mem("CT1-A2C.mem");
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    h04 = u_dut.q_hit;
    n04 = u_dut.q_nb;
    rd04 = u_dut.dest_rd_cnt - dest_base;
    ct1_04 = (ack_seen && (u_dut.active_generation != UNSET_GEN) && (h04 == 1) && (n04 == NB_C) && (rd04 >= 1)) ? 1 : 0;
    $display("CT1-04 ack=%0d gen=%08x hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d",
             ack_seen, u_dut.active_generation, h04, n04, rd04, got, ct1_04);

    force u_dut.t1_flush = 1'b1;
    repeat (4) @(posedge CLK100MHZ);
    force u_dut.t1_flush = 1'b0;
    force u_dut.t1_rebuild = 1'b1;
    repeat (8) @(posedge CLK100MHZ);
    force u_dut.t1_rebuild = 1'b0;
    repeat (400) @(posedge CLK100MHZ);
    dest_base = u_dut.dest_rd_cnt;
    do_query();
    h05 = u_dut.q_hit;
    n05 = u_dut.q_nb;
    rd05 = u_dut.dest_rd_cnt - dest_base;
    ct1_05 = ((h05 == 1) && (n05 == NB_C) && (n05 == n04) && (rd05 >= 1)) ? 1 : 0;
    $display("CT1-05 hit=%0d nb=%08x dest_rd=%0d tok=%08h OK=%0d", h05, n05, rd05, got, ct1_05);

    fdj = $fopen("CT1_INT_OBS.json", "w");
    $fwrite(fdj, "{\n");
    $fwrite(fdj, "  \"task\": \"D-CT1-INTEGRATED-TOP\",\n");
    $fwrite(fdj, "  \"identity\": \"uart_r2_ct1\",\n");
    $fwrite(fdj, "  \"program\": \"NO\",\n");
    $fwrite(fdj, "  \"PACK_ABI_24_24_PASS\": \"NO\",\n");
    $fwrite(fdj, "  \"RUNTIME_KNOWLEDGE_BINDING_8_8_PASS\": \"NOT_RUN\",\n");
    $fwrite(fdj, "  \"mig0_in_xsim\": \"NO_mig_ui_bram_standin\",\n");
    $fwrite(fdj, "  \"dir_a_mem_on_answer_path\": \"NO\",\n");
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
      $display("CT1-01..05 INTEGRATED PASS_XSIM");
    else
      $fatal(1, "CT1-01..05 INTEGRATED FAIL_XSIM");
    $finish;
  end
endmodule
