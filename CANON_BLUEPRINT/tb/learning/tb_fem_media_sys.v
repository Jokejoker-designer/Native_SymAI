// tb_fem_media_sys.v — C lifecycle over dest-complete 128b bridge.
// CANDIDATE. Not FEM_PERSIST_PASS. PROXY_METRIC_FALSE_PASS_GUARD.
`timescale 1ns/1ps
`default_nettype none

module tb_fem_media_sys;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    reg        ing_valid = 0;
    reg [1:0]  ing_domain = 0;
    reg [3:0]  ing_stage = 0, ing_cap = 0, ing_prim = 0, ing_effect = 0;
    reg [2:0]  ing_macro = 0, ing_ctx = 0;
    wire       ing_done, ing_accepted;
    reg        rep_valid = 0;
    reg [7:0]  rep_skill_id = 0, rep_skill_ver = 0;
    wire       rep_done, rep_accepted;
    reg        cmp_start = 0, rec_start = 0;
    wire       cmp_done, rec_done, busy, unresolved, compacted, integrity_fault;
    wire [2:0] cmp_result, life_state, regression_count;
    wire [3:0] txn_step, n_raw;
    wire [1:0] recover_state;
    wire [7:0] failure_total, failure_recent, success_after_repair, fem_feat;
    wire [15:0] key, ingress_rejected, key_mismatch, exemplar_full;
    wire [15:0] wr_outstanding;
    wire       cmd_fifo_empty, t2_err;
    reg        force_fifo_empty = 0, inject_tear = 0;

    fem_media_sys dut (
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
        .busy(busy), .life_state(life_state), .failure_total(failure_total),
        .failure_recent(failure_recent), .success_after_repair(success_after_repair),
        .regression_count(regression_count), .unresolved(unresolved), .compacted(compacted),
        .key(key), .n_raw(n_raw), .ingress_rejected(ingress_rejected),
        .key_mismatch(key_mismatch), .exemplar_full(exemplar_full), .fem_feat(fem_feat),
        .force_fifo_empty(force_fifo_empty), .inject_tear(inject_tear),
        .wr_outstanding(wr_outstanding), .cmd_fifo_empty(cmd_fifo_empty), .t2_err(t2_err)
    );

    integer nfail, timeout;

    task pulse_reset; begin
        @(negedge clk); rst_n = 0; @(negedge clk); @(negedge clk); rst_n = 1; @(negedge clk);
    end endtask

    task ingress; input [1:0] dom; input [2:0] ctx; begin
        @(negedge clk);
        ing_domain = dom; ing_stage = 3; ing_cap = 5; ing_macro = 2; ing_prim = 7; ing_effect = 4; ing_ctx = ctx;
        ing_valid = 1; @(negedge clk); ing_valid = 0;
        timeout = 0;
        while (!ing_done && timeout < 4000) begin @(posedge clk); timeout = timeout + 1; end
        if (!ing_done) begin nfail = nfail + 1; $display("FAIL ingress timeout"); end
    end endtask

    task repair; input [7:0] ver; begin
        @(negedge clk); rep_skill_id = 8'h11; rep_skill_ver = ver; rep_valid = 1; @(negedge clk); rep_valid = 0;
        timeout = 0;
        while (!rep_done && timeout < 4000) begin @(posedge clk); timeout = timeout + 1; end
        if (!rep_done) begin nfail = nfail + 1; $display("FAIL repair timeout"); end
    end endtask

    task drive_to_resolved; begin
        ingress(2'd1, 3'd1);
        if (ing_accepted) begin nfail = nfail + 1; $display("FAIL tool accepted"); end
        ingress(2'd2, 3'd1);
        if (ing_accepted) begin nfail = nfail + 1; $display("FAIL host accepted"); end
        ingress(2'd0, 3'd1);
        if (life_state !== 3'd0) begin nfail = nfail + 1; $display("FAIL RAW"); end
        ingress(2'd0, 3'd1);
        if (life_state !== 3'd1) begin nfail = nfail + 1; $display("FAIL CLUSTERED"); end
        repair(8'h01); repair(8'h01); repair(8'h01);
        if (life_state !== 3'd2) begin nfail = nfail + 1; $display("FAIL RESOLVED"); end
    end endtask

    initial begin
        nfail = 0;
        pulse_reset;
        drive_to_resolved;

        // PROXY: FIFO-empty asserted during compaction must not complete dest.
        @(negedge clk); cmp_start = 1; @(negedge clk); cmp_start = 0;
        timeout = 0;
        while (txn_step !== 4'd0 && timeout < 4000) begin @(posedge clk); timeout = timeout + 1; end
        force_fifo_empty = 1;
        repeat (20) @(posedge clk);
        if (txn_step > 4'd1) begin
            nfail = nfail + 1;
            $display("FAIL PROXY_METRIC_FALSE_PASS_GUARD txn_step=%0d while fifo-empty", txn_step);
        end
        force_fifo_empty = 0;
        timeout = 0;
        while (!cmp_done && timeout < 8000) begin @(posedge clk); timeout = timeout + 1; end
        if (!cmp_done) begin nfail = nfail + 1; $display("FAIL cmp timeout"); end
        if (cmp_result !== 3'd0) begin nfail = nfail + 1; $display("FAIL cmp_result=%0d", cmp_result); end
        if (!compacted) begin nfail = nfail + 1; $display("FAIL not compacted"); end
        if (n_raw !== 4'd0) begin nfail = nfail + 1; $display("FAIL raw not retired n_raw=%0d", n_raw); end

        @(negedge clk); rec_start = 1; @(negedge clk); rec_start = 0;
        timeout = 0;
        while (!rec_done && timeout < 8000) begin @(posedge clk); timeout = timeout + 1; end
        if (!rec_done) begin nfail = nfail + 1; $display("FAIL recover timeout"); end
        if (integrity_fault) begin nfail = nfail + 1; $display("FAIL unexpected COMMITTED_CORRUPT"); end
        if (recover_state !== 2'd2) begin nfail = nfail + 1; $display("FAIL recover_state=%0d", recover_state); end

        if (nfail == 0) $display("FEM_MEDIA_SYS_XSIM_PASS dest-complete (not FEM_PERSIST_PASS)");
        else $display("FEM_MEDIA_SYS_XSIM_FAIL nfail=%0d", nfail);
        $finish;
    end

    initial begin
        #5_000_000;
        $display("FEM_MEDIA_SYS_XSIM_FAIL watchdog");
        $finish;
    end
endmodule
`default_nettype wire
