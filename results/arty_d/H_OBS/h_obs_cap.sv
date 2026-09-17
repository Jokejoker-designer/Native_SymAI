// H_OBS capture. Observe identity only. H_OBS != identity H.
// Latch first PACK-ACCEPTED word after CLEAR, not the CLEAR word.
// Sample bix at arm and in the ACK-to-first-pack gap. Not a silicon fix for H.
// Not BOARD_PASS / PACK_ABI_24_24_PASS / PROGRAM_PASS.
`timescale 1ns/1ps

module h_obs_cap (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        clr_take,
  input  logic        w_valid,
  input  logic        w_ready,
  input  logic [31:0] w_data,
  input  logic        fifo_wr_valid,
  input  logic        fifo_wr_ready,
  input  logic        dump_go,
  input  logic [1:0]  dbg_bix,
  input  logic [7:0]  dbg_sh,
  input  logic [1:0]  dbg_st,
  output logic        cap_fresh,
  output logic        have_pack_word,
  output logic [31:0] first_pack_word,
  output logic [1:0]  bix_at_arm,
  output logic [1:0]  bix_at_first_pack,
  output logic [1:0]  bix_gap,
  output logic        drop_seen,
  output logic [7:0]  sh0,
  output logic [7:0]  sh1,
  output logic [7:0]  sh2,
  output logic [7:0]  sh3,
  output logic [3:0]  n_bytes
);
  logic take_d, bix_d;
  logic [1:0] bix_prev;
  logic armed;
  logic gap_got;
  wire pack_accept = fifo_wr_valid && fifo_wr_ready;
  wire drop_now = (dbg_st == 2'd3) && (dbg_bix == 2'd3) && w_valid && !w_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      take_d <= 1'b0;
      bix_prev <= 2'h0;
      armed <= 1'b0;
      cap_fresh <= 1'b0;
      have_pack_word <= 1'b0;
      first_pack_word <= 32'h0;
      bix_at_arm <= 2'h0;
      bix_at_first_pack <= 2'h0;
      bix_gap <= 2'h0;
      gap_got <= 1'b0;
      drop_seen <= 1'b0;
      sh0 <= 8'h0;
      sh1 <= 8'h0;
      sh2 <= 8'h0;
      sh3 <= 8'h0;
      n_bytes <= 4'h0;
    end else begin
      take_d <= clr_take;
      bix_prev <= dbg_bix;
      if (clr_take && !take_d) begin
        armed <= 1'b1;
        cap_fresh <= 1'b1;
        have_pack_word <= 1'b0;
        first_pack_word <= 32'h0;
        bix_at_arm <= dbg_bix;
        bix_at_first_pack <= 2'h0;
        bix_gap <= 2'h0;
        gap_got <= 1'b0;
        drop_seen <= 1'b0;
        sh0 <= 8'h0;
        sh1 <= 8'h0;
        sh2 <= 8'h0;
        sh3 <= 8'h0;
        n_bytes <= 4'h0;
      end else begin
        if (dump_go)
          cap_fresh <= 1'b0;
        if (armed && drop_now)
          drop_seen <= 1'b1;
        if (armed && !gap_got && (dbg_bix != bix_prev)) begin
          bix_gap <= dbg_bix;
          gap_got <= 1'b1;
        end
        if (armed && (dbg_bix != bix_prev) && (n_bytes < 4'h4)) begin
          unique case (n_bytes)
            4'h0: sh0 <= dbg_sh;
            4'h1: sh1 <= dbg_sh;
            4'h2: sh2 <= dbg_sh;
            default: sh3 <= dbg_sh;
          endcase
          n_bytes <= n_bytes + 4'h1;
        end
        if (armed && pack_accept && !have_pack_word) begin
          first_pack_word <= w_data;
          bix_at_first_pack <= dbg_bix;
          have_pack_word <= 1'b1;
        end
      end
    end
  end
endmodule
