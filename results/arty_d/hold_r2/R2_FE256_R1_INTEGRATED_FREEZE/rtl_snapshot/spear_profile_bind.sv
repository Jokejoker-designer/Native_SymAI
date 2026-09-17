// spear_profile_bind.sv — D wires loaded profile into C SPEAR. CANDIDATE. PROGRAM=NO.
// K_HARD from profile; K_HARD_MAX is SPEAR slot ceiling. k_hard > K_HARD_MAX is C k_invalid.
`timescale 1ns/1ps

module spear_profile_bind #(
  parameter integer ACC_W = 32,
  parameter integer SHIFT = 12,
  parameter integer K_HARD_MAX = 8
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        prof_wr_valid,
  input  logic [31:0] wr_active_id_max,
  input  logic [7:0]  wr_k_hard,
  output logic [31:0] active_id_max,
  output logic [7:0]  k_hard,
  input  logic        q_start,
  input  logic [7:0]  q_k_soft,
  input  logic [3:0]  q_relation_class,
  input  logic [3:0]  q_max_hops,
  input  logic [3:0]  q_answer_kind,
  input  logic [15:0] q_namespace_id,
  input  logic [15:0] q_generation,
  input  logic [255:0] w_flat,
  input  logic        cand_valid,
  input  logic [127:0] cand_desc,
  output logic        cand_ready,
  input  logic        q_end,
  output logic        done,
  output logic        k_invalid,
  output logic        tie_overflow,
  output logic [7:0]  admitted_count
);
  runtime_profile prof (
    .clk, .rst_n,
    .wr_valid(prof_wr_valid),
    .wr_active_id_max(wr_active_id_max),
    .wr_k_hard(wr_k_hard),
    .active_id_max(active_id_max),
    .k_hard(k_hard)
  );

  logic score_valid, score_sat, invalid_pulse;
  logic [31:0] score_ref;
  logic [15:0] score_val, invalid_count, n_valid;
  logic [(K_HARD_MAX+1)*32-1:0] adm_ref_flat;
  logic [(K_HARD_MAX+1)*16-1:0] adm_score_flat;
  logic [K_HARD_MAX:0] adm_sat_flat;

  spear_rank #(.ACC_W(ACC_W), .SHIFT(SHIFT), .K_HARD_MAX(K_HARD_MAX)) spear (
    .clk, .rst_n,
    .prof_active_id_max(active_id_max),
    .q_start, .q_k_soft(q_k_soft), .q_k_hard(k_hard),
    .q_relation_class, .q_max_hops, .q_answer_kind,
    .q_namespace_id, .q_generation, .w_flat,
    .cand_valid, .cand_desc, .cand_ready, .q_end,
    .score_valid, .score_ref, .score_val, .score_sat, .invalid_pulse,
    .done, .admitted_count, .tie_overflow, .k_invalid,
    .invalid_count, .n_valid, .adm_ref_flat, .adm_score_flat, .adm_sat_flat
  );
endmodule
