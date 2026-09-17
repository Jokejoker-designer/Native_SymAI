// =============================================================================
// tb_spear_rank.v — SPEAR unit testbench (C-CODE-02/04). XSim + Icarus compatible.
// Vector file via +VEC=<path> (layout: ref/learning/gen_spear_vectors.py).
// Expected values are preregistered from the reference model, never from the DUT.
// Prints TB_SPEAR_CASE_PASS / TB_SPEAR_CASE_FAIL. Runner aggregates TB_SPEAR_LOCAL_PASS.
// Local pass proves only the tested behavior. Not NSPF-X0, not board evidence.
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module tb_spear_rank;
    parameter integer ACC_W = 32;
    parameter integer SHIFT = 12;
    parameter integer K_HARD_MAX = 8;
    localparam integer NSLOT = K_HARD_MAX + 1;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    always #5 clk = ~clk;

    reg  [31:0]  prof_active_id_max = 0;
    reg          q_start = 0;
    reg  [7:0]   q_k_soft = 0, q_k_hard = 0;
    reg  [3:0]   q_rel = 0, q_hops = 0, q_ak = 0;
    reg  [15:0]  q_ns = 0, q_gen = 0;
    reg  [255:0] w_flat = 0;
    reg          cand_valid = 0;
    reg  [127:0] cand_desc = 0;
    wire         cand_ready;
    reg          q_end = 0;
    wire         score_valid;
    wire [31:0]  score_ref;
    wire [15:0]  score_val;
    wire         score_sat;
    wire         invalid_pulse;
    wire         done;
    wire [7:0]   admitted_count;
    wire         tie_overflow, k_invalid;
    wire [15:0]  invalid_count;
    wire [15:0]  n_valid;
    wire [NSLOT*32-1:0] adm_ref_flat;
    wire [NSLOT*16-1:0] adm_score_flat;
    wire [NSLOT-1:0]    adm_sat_flat;

    spear_rank #(.ACC_W(ACC_W), .SHIFT(SHIFT), .K_HARD_MAX(K_HARD_MAX)) dut (
        .clk(clk), .rst_n(rst_n), .prof_active_id_max(prof_active_id_max),
        .q_start(q_start), .q_k_soft(q_k_soft), .q_k_hard(q_k_hard),
        .q_relation_class(q_rel), .q_max_hops(q_hops), .q_answer_kind(q_ak),
        .q_namespace_id(q_ns), .q_generation(q_gen), .w_flat(w_flat),
        .cand_valid(cand_valid), .cand_desc(cand_desc), .cand_ready(cand_ready), .q_end(q_end),
        .score_valid(score_valid), .score_ref(score_ref), .score_val(score_val), .score_sat(score_sat),
        .invalid_pulse(invalid_pulse),
        .done(done), .admitted_count(admitted_count), .tie_overflow(tie_overflow), .k_invalid(k_invalid),
        .invalid_count(invalid_count), .n_valid(n_valid),
        .adm_ref_flat(adm_ref_flat), .adm_score_flat(adm_score_flat), .adm_sat_flat(adm_sat_flat)
    );

    reg [31:0] mem [0:8191];
    reg [1023:0] vec_path;
    integer n_desc, i, p, errors, timeout;
    integer exp_acc_w, exp_shift, exp_khm;
    reg [31:0] exp_word, fin0, fin1;
    reg [127:0] d;
    reg [31:0] exp_ref; reg [16:0] exp_sc;

    task fail; input [255:0] msg; begin
        errors = errors + 1;
        $display("  FAIL: %0s", msg);
    end endtask

    // Global watchdog: hangs are a FAIL, never silent.
    initial begin
        #500000;
        $display("TB_SPEAR_CASE_FAIL watchdog state=%0d cand_ready=%b done=%b", dut.state, cand_ready, done);
        $finish;
    end

    initial begin
        errors = 0;
        if (!$value$plusargs("VEC=%s", vec_path)) begin
            $display("TB_SPEAR_CASE_FAIL no +VEC");
            $finish;
        end
        for (i = 0; i < 8192; i = i + 1) mem[i] = 32'hXXXX_XXXX;
        $readmemh(vec_path, mem);   // short-file warning is expected (variable-length vectors)

        n_desc     = mem[0];
        q_k_soft   = mem[1][7:0];
        q_k_hard   = mem[1][15:8];
        q_rel      = mem[1][19:16];
        q_hops     = mem[1][23:20];
        q_ak       = mem[1][27:24];
        q_ns       = mem[2][15:0];
        q_gen      = mem[2][31:16];
        exp_acc_w  = mem[3][7:0];
        exp_shift  = mem[3][15:8];
        exp_khm    = mem[3][23:16];
        prof_active_id_max = mem[4];      // loaded-profile value (runtime input, not a parameter)
        for (i = 0; i < 8; i = i + 1) w_flat[i*32 +: 32] = mem[5 + i];

        if (exp_acc_w != ACC_W || exp_shift != SHIFT || exp_khm != K_HARD_MAX) begin
            $display("TB_SPEAR_CASE_FAIL config mismatch: vec acc_w=%0d shift=%0d khm=%0d tb ACC_W=%0d SHIFT=%0d K_HARD_MAX=%0d",
                     exp_acc_w, exp_shift, exp_khm, ACC_W, SHIFT, K_HARD_MAX);
            $finish;
        end

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        q_start = 1'b1; @(negedge clk); q_start = 1'b0;

        p = 13;
        for (i = 0; i < n_desc; i = i + 1) begin
            d = {mem[p], mem[p+1], mem[p+2], mem[p+3]};
            exp_word = mem[p+4];
            p = p + 5;
            // handshake: drive at negedge, accepted at the posedge where cand_ready==1
            // (we are at a negedge here)
            cand_desc = d; cand_valid = 1'b1;
            while (!cand_ready) @(negedge clk);
            // cand_ready is high now; next posedge accepts. Drop valid after it.
            @(posedge clk); #1; cand_valid = 1'b0;
            // wait for outcome
            timeout = 0;
            while (!(score_valid || invalid_pulse) && timeout < 200) begin @(posedge clk); #1; timeout = timeout + 1; end
            if (timeout >= 200) fail("timeout waiting for score/invalid");
            else if (exp_word[31]) begin
                if (!score_valid)               fail("expected VALID, DUT rejected");
                else begin
                    if (score_ref != d[127:96])  fail("score_ref mismatch");
                    if (score_val != exp_word[15:0]) begin
                        $display("    desc %0d: score got %0d exp %0d", i, $signed(score_val), $signed(exp_word[15:0]));
                        fail("score mismatch");
                    end
                    if (score_sat != exp_word[30]) fail("sat_flag mismatch");
                end
            end else begin
                if (!invalid_pulse) fail("expected INVALID, DUT scored it");
            end
            @(negedge clk);
        end

        // finalize
        @(negedge clk); q_end = 1'b1; @(posedge clk); @(negedge clk); q_end = 1'b0;
        timeout = 0;
        while (!done && timeout < 100) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!done) fail("timeout waiting for done");

        fin0 = mem[p]; fin1 = mem[p+1]; p = p + 2;
        if (admitted_count != fin0[7:0])  begin $display("    admitted got %0d exp %0d", admitted_count, fin0[7:0]);  fail("admitted_count mismatch"); end
        if (tie_overflow  != fin0[8])     fail("tie_overflow mismatch");
        if (k_invalid     != fin0[9])     begin $display("    k_invalid got %b exp %b", k_invalid, fin0[9]); fail("k_invalid mismatch"); end
        if (k_invalid && (admitted_count != 0 || tie_overflow)) fail("k_invalid must fail closed (admitted=0, tie_overflow=0)");
        if (n_valid       != fin0[31:16]) fail("n_valid mismatch");
        if (invalid_count != fin1[15:0])  fail("invalid_count mismatch");
        for (i = 0; i < fin0[7:0] && i < NSLOT; i = i + 1) begin
            exp_ref = mem[p]; exp_sc = mem[p+1][16:0]; p = p + 2;
            if (adm_ref_flat[i*32 +: 32] != exp_ref) begin
                $display("    slot %0d: ref got %08x exp %08x", i, adm_ref_flat[i*32 +: 32], exp_ref);
                fail("admitted ref/order mismatch");
            end
            if (adm_score_flat[i*16 +: 16] != exp_sc[15:0]) fail("admitted score mismatch");
            if (adm_sat_flat[i] != exp_sc[16]) fail("admitted sat mismatch");
        end

        if (errors == 0) $display("TB_SPEAR_CASE_PASS %0s", vec_path);
        else             $display("TB_SPEAR_CASE_FAIL %0s errors=%0d", vec_path, errors);
        $finish;
    end
endmodule

`default_nettype wire
