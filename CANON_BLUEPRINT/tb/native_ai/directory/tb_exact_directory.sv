// tb_exact_directory.sv — M2 CANDIDATE smoke. Exact ID hit/miss. XSim != board.
`timescale 1ns/1ps

module tb_exact_directory;
  localparam int N_DIR = 235;
  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic req_valid, req_ready, rsp_valid, rsp_ready, hit, out_of_profile;
  logic [31:0] semantic_id, fwd_ptr, rev_ptr, active_id_max;
  logic [15:0] generation;
  logic [7:0] kind, flags;

  exact_directory #(.N_DIR(N_DIR)) dut (
    .clk, .rst_n, .req_valid, .req_ready, .semantic_id, .active_id_max,
    .rsp_valid, .rsp_ready, .hit, .out_of_profile, .fwd_ptr, .rev_ptr, .generation, .kind, .flags
  );

  logic [31:0] keys [0:255];
  int n_keys, n_pass, n_fail, fd, rec, t;
  string line;

  initial begin
    n_keys = 0;
    fd = $fopen("dir_keys.hex", "r");
    if (fd == 0) $fatal(1, "cannot open dir_keys.hex");
    while (!$feof(fd) && n_keys < 256) begin
      if ($fgets(line, fd) > 0 && line.len() >= 8) begin
        keys[n_keys] = line.substr(0, 7).atohex();
        n_keys++;
      end
    end
    $fclose(fd);
    if (n_keys != N_DIR) $fatal(1, "key count %0d != %0d", n_keys, N_DIR);

    rsp_ready = 1;
    req_valid = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    n_pass = 0;
    n_fail = 0;
    for (rec = 0; rec < n_keys; rec++) begin
      semantic_id = keys[rec];
      req_valid = 1;
      t = 0;
      while (!req_ready && t < 1000) begin @(posedge clk); t++; end
      @(posedge clk);
      req_valid = 0;
      t = 0;
      while (!rsp_valid && t < 1000) begin @(posedge clk); t++; end
      if (!rsp_valid || !hit) begin
        n_fail++;
        $display("FAIL hit id=%08x hit=%0d fwd=%08x", semantic_id, hit, fwd_ptr);
      end else n_pass++;
      @(posedge clk);
    end

    // absent IDs must miss
    for (rec = 0; rec < 4; rec++) begin
      semantic_id = 32'h00F00F00 + rec;
      req_valid = 1;
      t = 0;
      while (!req_ready && t < 1000) begin @(posedge clk); t++; end
      @(posedge clk);
      req_valid = 0;
      t = 0;
      while (!rsp_valid && t < 1000) begin @(posedge clk); t++; end
      if (!rsp_valid || hit) begin
        n_fail++;
        $display("FAIL miss expected id=%08x hit=%0d", semantic_id, hit);
      end else n_pass++;
      @(posedge clk);
    end

    // profile: ID in ROM but above active_id_max is miss + out_of_profile
    semantic_id = keys[n_keys-1];
    active_id_max = 32'h0;
    req_valid = 1;
    t = 0;
    while (!req_ready && t < 1000) begin @(posedge clk); t++; end
    @(posedge clk);
    req_valid = 0;
    t = 0;
    while (!rsp_valid && t < 1000) begin @(posedge clk); t++; end
    if (!rsp_valid || hit || !out_of_profile) begin
      n_fail++;
      $display("FAIL oop id=%08x hit=%0d oop=%0d", semantic_id, hit, out_of_profile);
    end else n_pass++;
    @(posedge clk);
    active_id_max = 32'hFFFF_FFFF;

    if (n_fail == 0)
      $display("M2_DIR_XSIM_PASS  hit=%0d miss_ok=4 (simulation only)", n_keys);
    else
      $display("M2_DIR_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
