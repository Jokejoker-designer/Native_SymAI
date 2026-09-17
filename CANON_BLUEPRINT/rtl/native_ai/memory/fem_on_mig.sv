// fem_on_mig.sv — C FEM lifecycle on mig_ui32 (not local fem_media_bridge).
// CANDIDATE. PROGRAM=NO. XSim != board. Not FEM_PERSIST_PASS / MIG_PASS.
// Completion = dest readback + txn/generation. FIFO-empty is not complete.
`timescale 1ns/1ps

module fem_on_mig #(
  parameter logic [27:0] FEM_BASE = 28'h0200000
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        calib_done,
  input  logic        ing_valid,
  input  logic [1:0]  ing_domain,
  input  logic [3:0]  ing_stage,
  input  logic [3:0]  ing_cap,
  input  logic [2:0]  ing_macro,
  input  logic [3:0]  ing_prim,
  input  logic [3:0]  ing_effect,
  input  logic [2:0]  ing_ctx,
  output logic        ing_done,
  output logic        ing_accepted,
  input  logic        rep_valid,
  input  logic [7:0]  rep_skill_id,
  input  logic [7:0]  rep_skill_ver,
  output logic        rep_done,
  output logic        rep_accepted,
  input  logic        cmp_start,
  output logic        cmp_done,
  output logic [2:0]  cmp_result,
  output logic [3:0]  txn_step,
  input  logic        rec_start,
  output logic        rec_done,
  output logic [1:0]  recover_state,
  output logic        integrity_fault,
  output logic        busy,
  output logic [2:0]  life_state,
  output logic [7:0]  failure_total,
  output logic [7:0]  failure_recent,
  output logic [7:0]  success_after_repair,
  output logic [2:0]  regression_count,
  output logic        unresolved,
  output logic        compacted,
  output logic [15:0] key,
  output logic [3:0]  n_raw,
  output logic [15:0] ingress_rejected,
  output logic [15:0] key_mismatch,
  output logic [15:0] exemplar_full,
  output logic [7:0]  fem_feat,
  input  logic        force_fifo_empty,
  input  logic        inject_tear,
  output logic [15:0] wr_outstanding,
  output logic        cmd_fifo_empty,
  output logic        t2_err,
  output logic        ui_busy,

  output logic [27:0] app_addr,
  output logic [2:0]  app_cmd,
  output logic        app_en,
  output logic [127:0] app_wdf_data,
  output logic        app_wdf_end,
  output logic [15:0] app_wdf_mask,
  output logic        app_wdf_wren,
  input  logic [127:0] app_rd_data,
  input  logic        app_rd_data_valid,
  input  logic        app_rdy,
  input  logic        app_wdf_rdy
);
  logic t2_we, t2_ready;
  logic [3:0] t2_addr;
  logic [31:0] t2_wdata, t2_rdata;

  logic c_req, c_we_iss, adp_ready, adp_ack, adp_err;
  logic [3:0] c_addr_iss;
  logic [31:0] c_wdata_iss, adp_rdata;
  logic [15:0] c_txn, c_gen;

  logic req_valid, req_ready, req_write, rsp_valid, rsp_err, rsp_ready;
  logic [3:0] req_addr;
  logic [31:0] req_wdata, rsp_rdata;
  logic [15:0] req_txn, req_gen, rsp_txn, rsp_gen;

  fem_lifecycle u_fem (
    .clk(clk), .rst_n(rst_n),
    .ing_valid(ing_valid), .ing_domain(ing_domain), .ing_stage(ing_stage),
    .ing_cap(ing_cap), .ing_macro(ing_macro), .ing_prim(ing_prim),
    .ing_effect(ing_effect), .ing_ctx(ing_ctx),
    .ing_done(ing_done), .ing_accepted(ing_accepted),
    .rep_valid(rep_valid), .rep_skill_id(rep_skill_id), .rep_skill_ver(rep_skill_ver),
    .rep_done(rep_done), .rep_accepted(rep_accepted),
    .cmp_start(cmp_start), .cmp_done(cmp_done), .cmp_result(cmp_result), .txn_step(txn_step),
    .rec_start(rec_start), .rec_done(rec_done), .recover_state(recover_state),
    .integrity_fault(integrity_fault),
    .t2_we(t2_we), .t2_addr(t2_addr), .t2_wdata(t2_wdata),
    .t2_ready(t2_ready), .t2_rdata(t2_rdata),
    .busy(busy), .life_state(life_state), .failure_total(failure_total),
    .failure_recent(failure_recent), .success_after_repair(success_after_repair),
    .regression_count(regression_count), .unresolved(unresolved), .compacted(compacted),
    .key(key), .n_raw(n_raw), .ingress_rejected(ingress_rejected),
    .key_mismatch(key_mismatch), .exemplar_full(exemplar_full), .fem_feat(fem_feat)
  );

  fem_t2_ce u_ce (
    .clk(clk), .rst_n(rst_n),
    .c_busy(busy), .c_we(t2_we), .c_addr(t2_addr), .c_wdata(t2_wdata),
    .t2_ready(t2_ready), .t2_rdata(t2_rdata), .t2_err(t2_err),
    .c_req(c_req), .c_we_iss(c_we_iss), .c_addr_iss(c_addr_iss), .c_wdata_iss(c_wdata_iss),
    .c_txn(c_txn), .c_gen(c_gen),
    .adp_ready(adp_ready), .adp_ack(adp_ack), .adp_rdata(adp_rdata), .adp_err(adp_err)
  );

  fem_t2_adapter u_adp (
    .clk(clk), .rst_n(rst_n),
    .c_req(c_req), .c_we(c_we_iss), .c_addr(c_addr_iss), .c_wdata(c_wdata_iss),
    .c_txn(c_txn), .c_gen(c_gen),
    .t2_ready(adp_ready), .t2_ack(adp_ack), .t2_rdata(adp_rdata), .t2_err(adp_err),
    .req_valid(req_valid), .req_ready(req_ready), .req_write(req_write),
    .req_addr(req_addr), .req_wdata(req_wdata), .req_txn(req_txn), .req_gen(req_gen),
    .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata),
    .rsp_txn(rsp_txn), .rsp_gen(rsp_gen), .rsp_err(rsp_err)
  );

  fem_req_ui #(.FEM_BASE(FEM_BASE)) u_ui (
    .clk, .rst_n, .calib_done,
    .req_valid, .req_ready, .req_write, .req_addr, .req_wdata, .req_txn, .req_gen,
    .rsp_valid, .rsp_ready, .rsp_rdata, .rsp_txn, .rsp_gen, .rsp_err,
    .wr_outstanding, .cmd_fifo_empty, .force_fifo_empty, .inject_tear, .ui_busy,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );
endmodule
