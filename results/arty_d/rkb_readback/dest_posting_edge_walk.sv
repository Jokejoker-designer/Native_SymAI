// dest_posting_edge_walk.sv — dest-backed dir → posting → EdgeRecord.
// AGENT_D XSim DUT. Not posting_walk $readmemh. PROGRAM=NO.
// Neighbor is EdgeRecord.dst_id after both edge beats. Not PostingEntry.neighbor_id.
// Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
`timescale 1ns/1ps

module dest_posting_edge_walk (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         pack_quiescent,
  input  logic         root_valid,
  input  logic [27:0]  published_root,
  input  logic         lookup_go,
  input  logic [31:0]  lookup_sid,
  input  logic         load_ack,
  input  logic         t1_flush,
  output logic         t1_valid,
  output logic         busy,
  output logic         lookup_done,
  output logic         hit,
  output logic [31:0]  neighbor,
  output logic [27:0]  app_addr,
  output logic [2:0]   app_cmd,
  output logic         app_en,
  output logic [127:0] app_wdf_data,
  output logic         app_wdf_end,
  output logic [15:0]  app_wdf_mask,
  output logic         app_wdf_wren,
  input  logic [127:0] app_rd_data,
  input  logic         app_rdy,
  input  logic         app_rd_data_valid
);
  typedef enum logic [3:0] {
    S_IDLE, S_ARM,
    S_DIR_RD, S_DIR_WAIT,
    S_POST_RD, S_POST_WAIT,
    S_ENT_RD, S_ENT_WAIT,
    S_E0_RD, S_E0_WAIT,
    S_E1_RD, S_E1_WAIT,
    S_DONE
  } st_t;
  st_t st;
  logic [31:0] sid_r, post_nb, edge_dst, edge_src, t1_sid, t1_nb;
  logic        t1_v, load_ack_q;
  logic [27:0] dir_addr, post_addr, ent_addr, e0_addr, e1_addr;

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

  function automatic [27:0] beat_addr(input logic [31:0] ptr);
    beat_addr = {ptr[27:4], 4'b0000};
  endfunction

  assign busy = (st != S_IDLE) && (st != S_DONE);
  assign lookup_done = (st == S_DONE);
  assign t1_valid = t1_v;
  assign app_cmd = 3'b001;
  assign app_wdf_data = 128'h0;
  assign app_wdf_end = 1'b0;
  assign app_wdf_mask = 16'hFFFF;
  assign app_wdf_wren = 1'b0;
  assign app_en = (st == S_DIR_RD) || (st == S_POST_RD) || (st == S_ENT_RD) ||
                  (st == S_E0_RD) || (st == S_E1_RD);

  always_comb begin
    unique case (st)
      S_DIR_RD, S_DIR_WAIT: app_addr = dir_addr;
      S_POST_RD, S_POST_WAIT: app_addr = post_addr;
      S_ENT_RD, S_ENT_WAIT: app_addr = ent_addr;
      S_E0_RD, S_E0_WAIT: app_addr = e0_addr;
      S_E1_RD, S_E1_WAIT: app_addr = e1_addr;
      default: app_addr = published_root;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      sid_r <= 32'h0;
      post_nb <= 32'h0;
      edge_dst <= 32'h0;
      edge_src <= 32'h0;
      dir_addr <= 28'h0;
      post_addr <= 28'h0;
      ent_addr <= 28'h0;
      e0_addr <= 28'h0;
      e1_addr <= 28'h0;
      hit <= 1'b0;
      neighbor <= 32'h0;
      t1_v <= 1'b0;
      t1_sid <= 32'h0;
      t1_nb <= 32'h0;
      load_ack_q <= 1'b0;
    end else begin
      load_ack_q <= load_ack;
      // pack_loader load_ack is sticky HIGH until next OP_BEGIN.
      // Invalidate T1 on COMMIT rising edge only so dest-walk can refill.
      if (load_ack && !load_ack_q)
        t1_v <= 1'b0;
      // Invalidate occupancy only. Does not write dest or change generation.
      if (t1_flush)
        t1_v <= 1'b0;
      unique case (st)
        S_IDLE: begin
          hit <= 1'b0;
          neighbor <= 32'h0;
          if (lookup_go && root_valid) begin
            sid_r <= lookup_sid;
            // Skip GOLD dest-page CRC beat at published_root (lane0 CRC).
            dir_addr <= published_root + 28'h10;
            st <= S_ARM;
          end
        end
        S_ARM: begin
          if (pack_quiescent)
            st <= S_DIR_RD;
        end
        S_DIR_RD: begin
          if (app_en && app_rdy)
            st <= S_DIR_WAIT;
        end
        S_DIR_WAIT: begin
          if (app_rd_data_valid) begin
            if (!match_dir(app_rd_data, sid_r)[32] ||
                (match_dir(app_rd_data, sid_r)[31:0] == 32'h0) ||
                (match_dir(app_rd_data, sid_r)[31:28] != 4'h0)) begin
              hit <= 1'b0;
              neighbor <= 32'h0;
              st <= S_DONE;
            end else begin
              post_addr <= beat_addr(match_dir(app_rd_data, sid_r)[31:0]);
              st <= S_POST_RD;
            end
          end
        end
        S_POST_RD: begin
          if (app_en && app_rdy)
            st <= S_POST_WAIT;
        end
        S_POST_WAIT: begin
          if (app_rd_data_valid) begin
            if ((app_rd_data[31:0] != sid_r) || (app_rd_data[95:88] != 8'h0) ||
                (app_rd_data[79:64] == 16'h0)) begin
              hit <= 1'b0;
              neighbor <= 32'h0;
              st <= S_DONE;
            end else begin
              ent_addr <= post_addr + 28'h10;
              st <= S_ENT_RD;
            end
          end
        end
        S_ENT_RD: begin
          if (app_en && app_rdy)
            st <= S_ENT_WAIT;
        end
        S_ENT_WAIT: begin
          if (app_rd_data_valid) begin
            post_nb <= app_rd_data[63:32];
            if ((app_rd_data[31:0] == 32'h0) || (app_rd_data[31:28] != 4'h0)) begin
              hit <= 1'b0;
              neighbor <= 32'h0;
              st <= S_DONE;
            end else begin
              e0_addr <= beat_addr(app_rd_data[31:0]);
              e1_addr <= beat_addr(app_rd_data[31:0]) + 28'h10;
              st <= S_E0_RD;
            end
          end
        end
        S_E0_RD: begin
          if (app_en && app_rdy)
            st <= S_E0_WAIT;
        end
        S_E0_WAIT: begin
          if (app_rd_data_valid) begin
            edge_src <= app_rd_data[31:0];
            edge_dst <= app_rd_data[63:32];
            if ((app_rd_data[31:0] != sid_r) || (app_rd_data[63:32] == 32'h0)) begin
              hit <= 1'b0;
              neighbor <= 32'h0;
              st <= S_DONE;
            end else
              st <= S_E1_RD;
          end
        end
        S_E1_RD: begin
          if (app_en && app_rdy)
            st <= S_E1_WAIT;
        end
        S_E1_WAIT: begin
          if (app_rd_data_valid) begin
            if (app_rd_data[127:120] != 8'h0) begin
              hit <= 1'b0;
              neighbor <= 32'h0;
            end else begin
              hit <= 1'b1;
              neighbor <= edge_dst;
              t1_v <= 1'b1;
              t1_sid <= sid_r;
              t1_nb <= edge_dst;
            end
            st <= S_DONE;
          end
        end
        S_DONE: begin
          if (!lookup_go)
            st <= S_IDLE;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
