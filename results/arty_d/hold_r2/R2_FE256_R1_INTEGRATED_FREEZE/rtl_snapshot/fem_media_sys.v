// fem_media_sys.v — C fem_lifecycle + dest-complete T2 (adapter + 128b bridge).
// CANDIDATE. PROGRAM=NO. XSim != board. Not FEM_PERSIST_PASS.
// Completion = dest readback + txn/generation. FIFO-empty is not complete.
`timescale 1ns/1ps
`default_nettype none

module fem_media_sys (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ing_valid,
    input  wire [1:0]  ing_domain,
    input  wire [3:0]  ing_stage,
    input  wire [3:0]  ing_cap,
    input  wire [2:0]  ing_macro,
    input  wire [3:0]  ing_prim,
    input  wire [3:0]  ing_effect,
    input  wire [2:0]  ing_ctx,
    output wire        ing_done,
    output wire        ing_accepted,
    input  wire        rep_valid,
    input  wire [7:0]  rep_skill_id,
    input  wire [7:0]  rep_skill_ver,
    output wire        rep_done,
    output wire        rep_accepted,
    input  wire        cmp_start,
    output wire        cmp_done,
    output wire [2:0]  cmp_result,
    output wire [3:0]  txn_step,
    input  wire        rec_start,
    output wire        rec_done,
    output wire [1:0]  recover_state,
    output wire        integrity_fault,
    output wire        busy,
    output wire [2:0]  life_state,
    output wire [7:0]  failure_total,
    output wire [7:0]  failure_recent,
    output wire [7:0]  success_after_repair,
    output wire [2:0]  regression_count,
    output wire        unresolved,
    output wire        compacted,
    output wire [15:0] key,
    output wire [3:0]  n_raw,
    output wire [15:0] ingress_rejected,
    output wire [15:0] key_mismatch,
    output wire [15:0] exemplar_full,
    output wire [7:0]  fem_feat,
    input  wire        force_fifo_empty,
    input  wire        inject_tear,
    output wire [15:0] wr_outstanding,
    output wire        cmd_fifo_empty,
    output wire        t2_err
);
    wire t2_we;
    wire [3:0] t2_addr;
    wire [31:0] t2_wdata;
    wire t2_ready;
    wire [31:0] t2_rdata;

    wire c_req, c_we_iss, adp_ready, adp_ack, adp_err;
    wire [3:0] c_addr_iss;
    wire [31:0] c_wdata_iss, adp_rdata;
    wire [15:0] c_txn, c_gen;

    wire req_valid, req_ready, req_write, rsp_valid, rsp_err, rsp_ready;
    wire [3:0] req_addr;
    wire [31:0] req_wdata, rsp_rdata;
    wire [15:0] req_txn, req_gen, rsp_txn, rsp_gen;

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

    fem_media_bridge u_br (
        .clk(clk), .rst_n(rst_n),
        .req_valid(req_valid), .req_ready(req_ready), .req_write(req_write),
        .req_addr(req_addr), .req_wdata(req_wdata), .req_txn(req_txn), .req_gen(req_gen),
        .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata),
        .rsp_txn(rsp_txn), .rsp_gen(rsp_gen), .rsp_err(rsp_err),
        .wr_outstanding(wr_outstanding), .cmd_fifo_empty(cmd_fifo_empty),
        .force_fifo_empty(force_fifo_empty), .inject_tear(inject_tear)
    );
endmodule
`default_nettype wire
