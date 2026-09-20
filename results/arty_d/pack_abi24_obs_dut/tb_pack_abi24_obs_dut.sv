// D-owned 24-case Pack/ABI-24 observe. pack_obs_gen four-AND on Pack S_COMMIT.
// QueryRecord observe via dest scan + TB CRC16-CCITT-FALSE. Does not modify B TB.
// Does not copy PA24_FLIP / PA24_QSTATUS into DUT.jsonl. PROGRAM=NO.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_pack_abi24_obs_dut;
`include "pack_abi24_expect.svh"
`include "pack_abi24_fopen.svh"

  logic clk = 0;
  logic rst_n = 0;
  logic        s_valid;
  logic        s_ready;
  logic [31:0] s_data;
  logic        load_ack, load_reject;
  logic [7:0]  reason_code;
  logic [31:0] active_generation;
  logic [7:0]  query_status, query_reason;
  logic        query_valid;
  logic        pack_quiescent;
  logic [15:0] epoch_id;
  logic        cap_v;
  logic        commit_pulse;
  logic        commit_event, same_ep, flip_present, gen_flip, commit_seen, cap_at;
  logic [31:0] gbefore, gafter;
  logic        qv_obs;
  logic [7:0]  qs_obs, qr_obs;
  logic [7:0]  q_bytes [0:31];
  logic        dest_inner_crc_fail;
  logic [255:0] q_pack;

  pack_abi24_mig_dut dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid, .pack_quiescent
  );

  assign commit_pulse = (dut.u_ld.u_ld.state == 4'd7);
  assign cap_v = rst_n;

  logic        gen_rst_n;

  pack_obs_gen u_gen (
    .clk, .rst_n(gen_rst_n), .capture_valid(cap_v), .epoch_id,
    .debug_clear(1'b0), .commit_pulse, .active_generation,
    .commit_event, .generation_before(gbefore), .generation_after(gafter),
    .same_capture_epoch(same_ep), .flip_present, .generation_flipped(gen_flip),
    .commit_seen, .capture_valid_at(cap_at)
  );

  always #5 clk = ~clk;

  integer rec, wi, nwords, t, n_fail, n_pass, n_loaded, fd, rc, jfd, k, di, bi;
  integer unsigned wtmp;
  integer exp_ack, exp_rej, got_ack, got_rej, mismatch;
  logic [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];
  string outcome;
  string line;
  string qpath;
  string g01s1;

  function automatic logic [7:0] dest_byte(input integer off);
    dest_byte = dut.u_dest.dest[off / 16][8 * (off % 16) +: 8];
  endfunction

  function automatic logic scan_dest_inner_crc_fail;
    integer ii, jj, kk;
    logic [7:0] b;
    logic [15:0] c, got;
    logic found;
    begin
      found = 1'b0;
      for (ii = 0; ii < 4096 * 16 - 32; ii = ii + 1) begin
        if (dest_byte(ii) == 8'h51 && dest_byte(ii + 1) == 8'h4E) begin
          c = 16'hFFFF;
          for (jj = 0; jj < 30; jj = jj + 1) begin
            b = dest_byte(ii + jj);
            c = c ^ {b, 8'h00};
            for (kk = 0; kk < 8; kk = kk + 1)
              c = c[15] ? {c[14:0], 1'b0} ^ 16'h1021 : {c[14:0], 1'b0};
          end
          got = {dest_byte(ii + 31), dest_byte(ii + 30)};
          if (c != got) found = 1'b1;
        end
      end
      scan_dest_inner_crc_fail = found;
    end
  endfunction

  function automatic [15:0] crc16_ccitt_false(input [255:0] p);
    integer ii, kk;
    logic [7:0] bb;
    logic [15:0] cx;
    begin
      cx = 16'hFFFF;
      for (ii = 0; ii < 30; ii = ii + 1) begin
        bb = p[8 * ii +: 8];
        cx = cx ^ {bb, 8'h00};
        for (kk = 0; kk < 8; kk = kk + 1)
          cx = cx[15] ? ({cx[14:0], 1'b0} ^ 16'h1021) : {cx[14:0], 1'b0};
      end
      crc16_ccitt_false = cx;
    end
  endfunction

  task automatic eval_query_tb;
    logic [15:0] magic, q_gen, got, calc;
    logic mag_fail, crc_fail, stale;
    begin
      magic = q_pack[15:0];
      q_gen = q_pack[79:64];
      got = q_pack[255:240];
      calc = crc16_ccitt_false(q_pack);
      mag_fail = (magic != 16'h4E51);
      crc_fail = (calc != got);
      stale = (active_generation != 32'hFFFF_FFFF) && (q_gen != 16'h0) &&
              (q_gen != active_generation[15:0]);
      if (mag_fail || crc_fail) begin
        qv_obs = 1'b1;
        qs_obs = 8'h06;
        qr_obs = 8'h55;
      end else if (stale) begin
        qv_obs = 1'b1;
        qs_obs = 8'h06;
        qr_obs = 8'h54;
      end else if (dest_inner_crc_fail) begin
        qv_obs = 1'b1;
        qs_obs = 8'h06;
        qr_obs = 8'h50;
      end else begin
        qv_obs = 1'b0;
        qs_obs = 8'h00;
        qr_obs = 8'h00;
      end
      $display("QUERY TB mag=%04h calc=%04h got=%04h mag_fail=%0d crc_fail=%0d stale=%0d dest_fail=%0d qv=%0d qs=%0d qr=%0d active=%08h qgen=%04h",
               magic, calc, got, mag_fail, crc_fail, stale, dest_inner_crc_fail,
               qv_obs, qs_obs, qr_obs, active_generation, q_gen);
    end
  endtask

  task automatic reset_pack;
    rst_n = 1'b0;
    gen_rst_n = 1'b0;
    s_valid = 1'b0;
    for (di = 0; di < 4096; di = di + 1) dut.u_dest.dest[di] = 128'h0;
    dest_inner_crc_fail = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    gen_rst_n = 1'b1;
    repeat (4) @(posedge clk);
  endtask

  task automatic reset_obs_gen;
    gen_rst_n = 1'b0;
    repeat (4) @(posedge clk);
    gen_rst_n = 1'b1;
    repeat (2) @(posedge clk);
  endtask

  task automatic stream_mem(input string path);
    integer fdx, rcx, wix, nwx, tx;
    integer unsigned wtx;
    begin
      fdx = $fopen(path, "r");
      if (fdx == 0) $fatal(1, "cannot open %s", path);
      rcx = $fscanf(fdx, "%h", nwx);
      if (rcx != 1 || nwx <= 0 || nwx > PACK_ABI24_MAX_WORDS)
        $fatal(1, "bad word count %s", path);
      wix = 0;
      while (wix < nwx) begin
        rcx = $fscanf(fdx, "%h", wtx);
        if (rcx != 1) $fatal(1, "short %s word %0d", path, wix);
        stream[wix] = wtx;
        wix = wix + 1;
      end
      $fclose(fdx);
      tx = 0;
      while (!s_ready && tx < 20000) begin @(posedge clk); tx = tx + 1; end
      if (!s_ready) begin
        n_fail = PACK_ABI24_N;
        $display("FAIL s_ready stuck 0 %s", path);
        $finish;
      end
      for (wix = 0; wix < nwx; wix = wix + 1) begin
        s_data = stream[wix];
        s_valid = 1'b1;
        tx = 0;
        while (!s_ready && tx < 40000) begin @(posedge clk); tx = tx + 1; end
        if (!s_ready) begin
          n_fail = PACK_ABI24_N;
          $display("FAIL s_ready timeout %s word %0d", path, wix);
          $finish;
        end
        @(posedge clk);
      end
      s_valid = 1'b0;
      tx = 0;
      while (!load_ack && !load_reject && tx < 200000) begin @(posedge clk); tx = tx + 1; end
      for (k = 0; k < 8; k = k + 1) @(posedge clk);
      tx = 0;
      while (!pack_quiescent && tx < 20000) begin @(posedge clk); tx = tx + 1; end
    end
  endtask

  task load_query_mem(input string path);
    integer fdx, rcx, wix, nwx;
    integer unsigned wtx;
    begin
      fdx = $fopen(path, "r");
      if (fdx == 0) $fatal(1, "cannot open query %s", path);
      rcx = $fscanf(fdx, "%h", nwx);
      if (rcx != 1 || nwx < 8) $fatal(1, "bad query mem %s", path);
      wix = 0;
      while (wix < 8) begin
        rcx = $fscanf(fdx, "%h", wtx);
        if (rcx != 1) $fatal(1, "short query %s", path);
        q_bytes[wix * 4 + 0] = wtx[7:0];
        q_bytes[wix * 4 + 1] = wtx[15:8];
        q_bytes[wix * 4 + 2] = wtx[23:16];
        q_bytes[wix * 4 + 3] = wtx[31:24];
        q_pack[8 * (wix * 4 + 0) +: 8] = wtx[7:0];
        q_pack[8 * (wix * 4 + 1) +: 8] = wtx[15:8];
        q_pack[8 * (wix * 4 + 2) +: 8] = wtx[23:16];
        q_pack[8 * (wix * 4 + 3) +: 8] = wtx[31:24];
        wix = wix + 1;
      end
      $fclose(fdx);
    end
  endtask

  task automatic run_query(input string path);
    begin
      dest_inner_crc_fail = scan_dest_inner_crc_fail();
      load_query_mem(path);
      $display("QBYTES %02h %02h %02h %02h ... %02h %02h %02h %02h q_pack_lo=%016h dest_fail=%0d",
               q_bytes[0], q_bytes[1], q_bytes[2], q_bytes[3],
               q_bytes[28], q_bytes[29], q_bytes[30], q_bytes[31], q_pack[63:0], dest_inner_crc_fail);
      eval_query_tb();
    end
  endtask

  initial begin
    n_fail = 0; n_pass = 0; n_loaded = 0;
    s_valid = 1'b0; s_data = 32'h0; epoch_id = 16'h1;
    dest_inner_crc_fail = 1'b0; gen_rst_n = 1'b0; q_pack = 256'h0;
    qv_obs = 1'b0; qs_obs = 8'h00; qr_obs = 8'h00;
    for (bi = 0; bi < 32; bi = bi + 1) q_bytes[bi] = 8'h0;
    jfd = $fopen("DUT.jsonl", "w");
    if (jfd == 0) $fatal(1, "cannot open DUT.jsonl");
    for (di = 0; di < 4096; di = di + 1) dut.u_dest.dest[di] = 128'h0;
    reset_pack();

    for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
      epoch_id = epoch_id + 16'h1;
      dest_inner_crc_fail = 1'b0;
      if (rec != 23) begin
        qv_obs = 1'b0;
        qs_obs = 8'h00;
        qr_obs = 8'h00;
      end

      if (rec == 20) begin
        g01s1 = "out/PA24-G-01.step1.mem";
        fd = $fopen(g01s1, "r");
        if (fd != 0) begin
          $fclose(fd);
          stream_mem(g01s1);
          if (!load_ack) begin
            n_fail = n_fail + 1;
            $display("FAIL_G01_STEP1 ack=%0d rej=%0d reason=%02h", load_ack, load_reject, reason_code);
          end
          epoch_id = epoch_id + 16'h1;
        end
      end

      if (rec == 23) begin
        stream_mem("out/PA24-G-01.mem");
        if (!load_ack) begin
          n_fail = n_fail + 1;
          $display("FAIL_G04_PRIOR_G01 ack=%0d rej=%0d reason=%02h", load_ack, load_reject, reason_code);
        end
        epoch_id = epoch_id + 16'h1;
        run_query("out/PA24-G-04.query.mem");
        reset_obs_gen();
      end

      fd = pa24_fopen_mem(rec);
      if (fd == 0) $fatal(1, "cannot open mem case %0d", rec);
      $fclose(fd);
      stream_mem($sformatf("out/%0s.mem", PA24_ID[rec]));
      n_loaded = n_loaded + 1;

      got_ack = load_ack;
      got_rej = load_reject;
      exp_ack = PA24_ACK[rec];
      exp_rej = PA24_REJ[rec];
      mismatch = 0;
      if (got_ack !== exp_ack) mismatch = mismatch + 1;
      if (got_rej !== exp_rej) mismatch = mismatch + 1;
      if (reason_code !== PA24_REASON[rec]) mismatch = mismatch + 1;

      if (mismatch != 0) begin
        n_fail = n_fail + 1;
        $display("FAIL_LOAD %s ack=%0d/%0d rej=%0d/%0d reason=%02h/%02h",
                 PA24_ID[rec], got_ack, exp_ack, got_rej, exp_rej,
                 reason_code, PA24_REASON[rec]);
      end else n_pass = n_pass + 1;

      if (rec == 19 && got_ack) run_query("out/PA24-R-04.query.mem");

      if (got_ack) outcome = "LOAD_OK";
      else outcome = "LOAD_REJECT";

      if (flip_present && commit_seen && same_ep && cap_at && qv_obs)
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"generation_flipped\":%0d,\"header_bytes\":128,\"commit_event\":1,\"same_capture_epoch\":%0d,\"capture_valid\":%0d,\"generation_before\":\"%08h\",\"generation_after\":\"%08h\",\"query_status\":%0d,\"query_reason\":%0d,\"source\":\"XSIM_PACK_OBS_GEN_QUERY_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, gen_flip,
          same_ep, cap_at, gbefore, gafter, qs_obs, qr_obs);
      else if (flip_present && commit_seen && same_ep && cap_at)
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"generation_flipped\":%0d,\"header_bytes\":128,\"commit_event\":1,\"same_capture_epoch\":%0d,\"capture_valid\":%0d,\"generation_before\":\"%08h\",\"generation_after\":\"%08h\",\"source\":\"XSIM_PACK_OBS_GEN_QUERY_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, gen_flip,
          same_ep, cap_at, gbefore, gafter);
      else if (qv_obs)
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"header_bytes\":128,\"commit_event\":%0d,\"flip_present\":%0d,\"query_status\":%0d,\"query_reason\":%0d,\"source\":\"XSIM_PACK_OBS_GEN_QUERY_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, commit_seen, flip_present, qs_obs, qr_obs);
      else
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"header_bytes\":128,\"commit_event\":%0d,\"flip_present\":%0d,\"source\":\"XSIM_PACK_OBS_GEN_QUERY_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, commit_seen, flip_present);
      $fdisplay(jfd, "%s", line);
      $display("OBS %s ack=%0d rej=%0d reason=%02h flip_present=%0d gen_flip=%0d qv=%0d qs=%02h qr=%02h before=%08h after=%08h",
               PA24_ID[rec], got_ack, got_rej, reason_code, flip_present, gen_flip, qv_obs, qs_obs, qr_obs, gbefore, gafter);

      reset_pack();
    end

    $fclose(jfd);
    if (n_fail == 0 && n_pass == PACK_ABI24_N)
      $display("PACK_ABI24_OBS_DUT_XSIM_LOAD  %0d/%0d dest-complete observe (simulation only; not PACK_ABI_24_24_PASS)", n_pass, PACK_ABI24_N);
    else
      $display("PACK_ABI24_OBS_DUT_XSIM_LOAD_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $display("PACK_ABI_24_24_PASS=NO PROGRAM=NO");
    $finish;
  end
endmodule
