// dest_root_cache.sv — publish dest root at COMMIT; dest-read is SoT; T1 is refillable cache.
// T1 is NOT a second source of truth. Host must not poke wr_valid.
// Unique CT1 identity copy. PROGRAM=NO. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
`timescale 1ns/1ps

module dest_root_cache (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         load_ack,
  input  logic         pack_quiescent,
  input  logic [27:0]  wr_beat_addr,
  input  logic         wr_beat_valid,
  input  logic         lookup_go,
  input  logic [31:0]  lookup_sid,
  input  logic         t1_flush,
  input  logic         t1_rebuild,
  output logic         busy,
  output logic         lookup_done,
  output logic         hit,
  output logic [31:0]  neighbor,
  output logic         t1_valid,
  output logic [27:0]  published_root,
  output logic         root_valid,
  output logic [27:0]  app_addr,
  output logic [2:0]   app_cmd,
  output logic         app_en,
  output logic [127:0] app_wdf_data,
  output logic         app_wdf_end,
  output logic [15:0]  app_wdf_mask,
  output logic         app_wdf_wren,
  input  logic [127:0] app_rd_data,
  input  logic         app_rdy,
  input  logic         app_wdf_rdy,
  input  logic         app_rd_data_valid
);
  typedef enum logic [2:0] { S_IDLE, S_ARM, S_RD, S_WAIT, S_DONE } st_t;
  st_t st;
  logic [27:0] pending_root, pub_root;
  logic        pub_v;
  logic        want_lookup, want_rebuild;
  logic [31:0] sid_r;
  logic [127:0] beat_r;
  logic        t1_v;
  logic [31:0] t1_sid, t1_fwd;
  logic        have_wr;

  // XSim FACT 2026-09-21: GOLD dest-complete leaves page CRC in beat[31:0].
  // HotDirectoryEntry is lane-aligned: try sid at lane0 then lane1 then lane2.
  function automatic [32:0] match_dir(input logic [127:0] beat, input logic [31:0] sid);
    begin
      if (beat[31:0] == sid)
        match_dir = {1'b1, beat[63:32]};
      else if (beat[63:32] == sid)
        match_dir = {1'b1, beat[95:64]};
      else if (beat[95:64] == sid)
        match_dir = {1'b1, beat[127:96]};
      else
        match_dir = 33'h0;
    end
  endfunction

  assign published_root = pub_root;
  assign root_valid = pub_v;
  assign t1_valid = t1_v;
  assign busy = (st != S_IDLE) && (st != S_DONE);
  assign lookup_done = (st == S_DONE);
  assign app_wdf_data = 128'h0;
  assign app_wdf_end = 1'b0;
  assign app_wdf_mask = 16'hFFFF;
  assign app_wdf_wren = 1'b0;
  assign app_cmd = 3'b001;
  assign app_addr = pub_root;
  assign app_en = (st == S_RD);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      pending_root <= 28'h0;
      pub_root <= 28'h0;
      pub_v <= 1'b0;
      want_lookup <= 1'b0;
      want_rebuild <= 1'b0;
      sid_r <= 32'h0;
      beat_r <= 128'h0;
      hit <= 1'b0;
      neighbor <= 32'h0;
      t1_v <= 1'b0;
      t1_sid <= 32'h0;
      t1_fwd <= 32'h0;
      have_wr <= 1'b0;
    end else begin
      if (wr_beat_valid && !have_wr)
        pending_root <= wr_beat_addr;
      if (wr_beat_valid)
        have_wr <= 1'b1;
      if (load_ack) begin
        if (have_wr)
          pub_root <= pending_root;
        pub_v <= 1'b1;
        have_wr <= 1'b0;
        t1_v <= 1'b0;
      end
      if (t1_flush)
        t1_v <= 1'b0;

      unique case (st)
        S_IDLE: begin
          if (lookup_go && pub_v) begin
            sid_r <= lookup_sid;
            want_lookup <= 1'b1;
            want_rebuild <= 1'b0;
            hit <= 1'b0;
            neighbor <= 32'h0;
            st <= S_ARM;
          end else if (t1_rebuild && pub_v) begin
            want_lookup <= 1'b0;
            want_rebuild <= 1'b1;
            st <= S_ARM;
          end
        end
        S_ARM: begin
          if (pack_quiescent)
            st <= S_RD;
        end
        S_RD: begin
          if (app_en && app_rdy)
            st <= S_WAIT;
        end
        S_WAIT: begin
          if (app_rd_data_valid) begin
            beat_r <= app_rd_data;
            t1_sid <= sid_r;
            t1_fwd <= match_dir(app_rd_data, sid_r)[31:0];
            t1_v <= 1'b1;
            if (want_lookup) begin
              hit <= match_dir(app_rd_data, sid_r)[32];
              neighbor <= match_dir(app_rd_data, sid_r)[31:0];
            end
            st <= S_DONE;
          end
        end
        S_DONE: begin
          want_lookup <= 1'b0;
          want_rebuild <= 1'b0;
          if (!lookup_go && !t1_rebuild)
            st <= S_IDLE;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
