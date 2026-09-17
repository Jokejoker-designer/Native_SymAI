// Hierarchical XSim: QueryRecord → query_result_bind on M4 UART candidate top.
// Not FE256 gold. Not FE256 engine. PROGRAM=NO. XSim != board. Not ASTRA_PASS.
`timescale 1ns/1ps

module tb_m4_query_result_shadow_bind;
  logic clk = 0;
  logic rst_n = 0;
  logic uart_tx;
  logic [3:0] led;
  always #5 clk = ~clk;

  arty_a7_r2_top_m4_query_result_candidate dut (
    .CLK100MHZ(clk),
    .ck_rst(rst_n),
    .uart_rx(1'b1),
    .uart_tx(uart_tx),
    .led(led)
  );

  logic [7:0] q_bytes [0:31];
  int n_pass, n_fail, n_hop1, fd, rec, t;
  logic [31:0] eid, fn, rn;
  logic [15:0] cfwd, crev;
  logic [255:0] qpack;

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

  function automatic [15:0] crc16_n46(input logic [7:0] b [0:45]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 46; ii++) c = crc16_step(c, b[ii]);
      crc16_n46 = c;
    end
  endfunction

  function automatic [255:0] pack_force(input logic [7:0] b [0:31]);
    int i;
    begin
      pack_force = 256'h0;
      for (i = 0; i < 32; i++) pack_force[8*i +: 8] = b[i];
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    input [3:0] hops_i;
    input [15:0] txn;
    integer k;
    logic [15:0] crc;
    logic [15:0] meta;
    begin
      meta = {4'h0, 1'b0, 1'b0, 1'b0, hops_i, 5'h0};
      for (k = 0; k < 32; k++) q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[4] = txn[7:0];
      q_bytes[5] = txn[15:8];
      q_bytes[12] = meta[7:0];
      q_bytes[13] = meta[15:8];
      q_bytes[14] = sid[7:0];
      q_bytes[15] = sid[15:8];
      q_bytes[16] = sid[23:16];
      q_bytes[17] = sid[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
    end
  endtask

  function automatic bit illegal_status(input [7:0] st);
    illegal_status = (st == 8'h00) || (st == 8'h01) || (st == 8'h02) ||
                     (st == 8'h22) || (st == 8'h23) || (st == 8'h55) ||
                     (st == 8'h56) || (st == 8'h80);
  endfunction

  task automatic issue_and_check;
    input [7:0] exp_st;
    input [7:0] exp_rc;
    input [7:0] exp_cmpl;
    input [15:0] txn;
    integer bi;
    logic [7:0] hdr [0:45];
    logic [15:0] crc;
    begin
      qpack = pack_force(q_bytes);
      force dut.tb_q_pack = qpack;
      force dut.tb_q_valid = 1'b1;
      t = 0;
      while (!dut.u_cr.q_ready && t < 10000) begin
        @(posedge clk);
        t++;
      end
      if (!dut.u_cr.q_ready) begin
        n_fail++;
        $display("FAIL q_ready stuck txn=%04x", txn);
        force dut.tb_q_valid = 1'b0;
        return;
      end
      @(posedge clk);
      force dut.tb_q_valid = 1'b0;
      t = 0;
      while (!dut.u_cr.r_valid && t < 20000) begin
        @(posedge clk);
        t++;
      end
      if (!dut.u_cr.r_valid) begin
        n_fail++;
        $display("FAIL timeout txn=%04x", txn);
      end else begin
        for (bi = 0; bi < 46; bi++) hdr[bi] = dut.u_cr.r_bytes[bi];
        crc = crc16_n46(hdr);
        if ({dut.u_cr.r_bytes[1], dut.u_cr.r_bytes[0]} != 16'h4E52) begin
          n_fail++; $display("FAIL magic txn=%04x", txn);
        end else if (dut.u_cr.r_bytes[2] != 8'h01) begin
          n_fail++; $display("FAIL abi txn=%04x", txn);
        end else if (dut.u_cr.r_bytes[3] !== exp_st || dut.u_cr.r_bytes[4] !== exp_rc ||
                     dut.u_cr.r_bytes[6] !== exp_cmpl) begin
          n_fail++; $display("FAIL st=%02x rc=%02x cmpl=%02x txn=%04x",
            dut.u_cr.r_bytes[3], dut.u_cr.r_bytes[4], dut.u_cr.r_bytes[6], txn);
        end else if (dut.u_cr.r_bytes[5] != 8'h00) begin
          n_fail++; $display("FAIL answer_kind txn=%04x", txn);
        end else if ({dut.u_cr.r_bytes[9], dut.u_cr.r_bytes[8]} !== txn) begin
          n_fail++; $display("FAIL txn echo");
        end else if ({dut.u_cr.r_bytes[47], dut.u_cr.r_bytes[46]} !== crc) begin
          n_fail++; $display("FAIL result crc txn=%04x", txn);
        end else if (illegal_status(dut.u_cr.r_bytes[3])) begin
          n_fail++; $display("FAIL illegal status %02x", dut.u_cr.r_bytes[3]);
        end else n_pass++;
      end
      @(posedge clk);
    end
  endtask

  initial begin
    n_pass = 0; n_fail = 0; n_hop1 = 0;
    rst_n = 0;
    force dut.tb_steer = 1'b0;
    force dut.tb_q_valid = 1'b0;
    force dut.tb_r_ready = 1'b1;
    force dut.tb_q_pack = 256'h0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);
    force dut.tb_steer = 1'b1;

    pack_q(32'h00010100, 4'd0, 16'h0001);
    issue_and_check(8'h04, 8'h20, 8'h02, 16'h0001);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    rec = 0;
    while (!$feof(fd)) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cfwd, fn, crev, rn) == 5) begin
        if (cfwd == 0) continue;
        n_hop1++;
        pack_q(eid, 4'd1, n_hop1[15:0]);
        issue_and_check(8'h04, 8'h20, 8'h02, n_hop1[15:0]);
        rec++;
      end
    end
    $fclose(fd);

    pack_q(32'h00010100, 4'd1, 16'h00FF);
    q_bytes[30] = ~q_bytes[30];
    issue_and_check(8'h06, 8'h55, 8'h00, 16'h00FF);

    if (n_fail == 0)
      $display("M4_QUERY_RESULT_SHADOW_XSIM_PASS  hop1=%0d (simulation only; not ASTRA_PASS)", n_hop1);
    else
      $display("M4_QUERY_RESULT_SHADOW_XSIM_FAIL  pass=%0d fail=%0d hop1=%0d", n_pass, n_fail, n_hop1);
    $finish;
  end
endmodule
