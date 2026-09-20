// tb_pack_obs_core.sv — lane CLEAR-survive, overflow invalid, gen 4-AND.
`timescale 1ns/1ps

module tb_pack_obs_core;
  logic clk, rst_n, arm, armed, freeze, clr_event, fire, overflow, rd_en;
  logic [15:0] epoch_id, flags;
  logic [31:0] data;
  logic [8:0] n_ev;
  logic [7:0] wr_ptr, rd_addr;
  logic [111:0] rd_data;
  integer fails;

  pack_obs_lane #(.DEPTH(4)) u_lane (
    .clk, .rst_n, .arm, .armed, .freeze, .clr_event, .epoch_id,
    .fire, .data, .flags, .overflow, .n_ev, .wr_ptr,
    .rd_en, .rd_addr, .rd_data
  );

  logic cap_v, dbg_c, cpulse, commit_event, same_ep, flip_present, gen_flip;
  logic [31:0] agen, gbefore, gafter;
  pack_obs_gen u_gen (
    .clk, .rst_n, .capture_valid(cap_v), .epoch_id,
    .debug_clear(dbg_c), .commit_pulse(cpulse), .active_generation(agen),
    .commit_event, .generation_before(gbefore), .generation_after(gafter),
    .same_capture_epoch(same_ep), .flip_present, .generation_flipped(gen_flip)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic tick;
    begin
      @(posedge clk);
      #1;
      fire = 1'b0;
      arm = 1'b0;
      clr_event = 1'b0;
      cpulse = 1'b0;
      dbg_c = 1'b0;
      rd_en = 1'b0;
    end
  endtask

  initial begin
    fails = 0;
    rst_n = 0; arm = 0; armed = 0; freeze = 0; clr_event = 0; fire = 0;
    epoch_id = 16'h1; data = 32'h0; flags = 16'h0; rd_en = 0; rd_addr = 0;
    cap_v = 1; dbg_c = 0; cpulse = 0; agen = 32'd3;
    repeat (4) @(posedge clk);
    rst_n = 1;
    tick;
    arm = 1; armed = 1;
    tick;
    fire = 1; data = 32'h00800001; flags = 16'h0001;
    tick;
    fire = 1; data = 32'h3149414E; flags = 16'h0001;
    tick;
    clr_event = 1;
    tick;
    if (n_ev != 9'd2) begin $display("FAIL n_ev after CLEAR %0d", n_ev); fails = fails + 1; end
    fire = 1; data = 32'hAABBCCDD;
    tick;
    if (n_ev != 9'd3) begin $display("FAIL survive CLEAR %0d", n_ev); fails = fails + 1; end
    fire = 1; data = 32'h1;
    tick;
    fire = 1; data = 32'h2;
    tick;
    if (!overflow) begin $display("FAIL overflow"); fails = fails + 1; end
    rd_en = 1; rd_addr = 8'd0;
    tick;
    tick;
    if (rd_data[47:16] != 32'h00800001) begin
      $display("FAIL rd data %h", rd_data[47:16]);
      fails = fails + 1;
    end

    cap_v = 1; epoch_id = 16'h5; agen = 32'd3;
    tick;
    cpulse = 1;
    tick;
    agen = 32'd4;
    tick;
    tick;
    if (!flip_present || !gen_flip || !same_ep) begin
      $display("FAIL flip_ok present=%0d flip=%0d same=%0d", flip_present, gen_flip, same_ep);
      fails = fails + 1;
    end
    agen = 32'd4;
    cpulse = 1;
    tick;
    tick;
    tick;
    if (!flip_present || gen_flip) begin
      $display("FAIL no_flip present=%0d flip=%0d", flip_present, gen_flip);
      fails = fails + 1;
    end
    epoch_id = 16'h5; agen = 32'd8;
    cpulse = 1;
    tick;
    epoch_id = 16'h6; agen = 32'd9;
    tick;
    tick;
    if (flip_present) begin
      $display("FAIL epoch_change present");
      fails = fails + 1;
    end
    epoch_id = 16'h7; agen = 32'd1;
    cpulse = 1;
    tick;
    dbg_c = 1; agen = 32'd2;
    tick;
    tick;
    if (flip_present) begin
      $display("FAIL clear_between present");
      fails = fails + 1;
    end
    cap_v = 0; epoch_id = 16'h8; agen = 32'd10;
    cpulse = 1;
    tick;
    agen = 32'd11;
    tick;
    tick;
    if (flip_present) begin
      $display("FAIL invalid_capture present");
      fails = fails + 1;
    end

    if (fails == 0)
      $display("PASS_XSIM pack_obs_core CLEAR-survive overflow gen-4AND");
    else
      $display("FAIL pack_obs_core %0d", fails);
    $finish;
  end
endmodule
