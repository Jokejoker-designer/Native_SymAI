// =============================================================================
// tb_fem_lifecycle.v — FEM lifecycle + compaction crash-safety fault injection (C-CODE-05)
// XSim + Icarus compatible. Expectations: +VEC=fem_expect.hex (from fem_ref.py).
//
// T2 model lives in the TB and SURVIVES DUT reset (power-cut model: logic dies, T2 persists,
// word writes are atomic). Invariant monitor (§11.12.1) is checked at EVERY clock once armed:
//   never {raw_absent, prototype_not_committed} ; index -> prototype only if committed.
// Boundaries B0..B6 are each ONE unit (one cut per boundary). CONTROL = uninterrupted run.
// Marker: FEM_COMPACTION_LOCAL_PASS / FEM_COMPACTION_LOCAL_FAIL. Local, tested-behavior only.
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module tb_fem_lifecycle;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    reg        ing_valid = 0; reg [1:0] ing_domain = 0; reg [3:0] ing_stage = 0, ing_cap = 0, ing_prim = 0, ing_effect = 0;
    reg [2:0]  ing_macro = 0, ing_ctx = 0;
    wire       ing_done, ing_accepted;
    reg        rep_valid = 0; reg [7:0] rep_skill_id = 0, rep_skill_ver = 0;
    wire       rep_done, rep_accepted;
    reg        cmp_start = 0, rec_start = 0;
    wire       cmp_done, rec_done, busy, unresolved, compacted, integrity_fault;
    wire [2:0] cmp_result, life_state, regression_count;
    wire [3:0] txn_step, n_raw;
    wire [1:0] recover_state;
    wire       t2_we; wire [3:0] t2_addr; wire [31:0] t2_wdata; reg [31:0] t2_rdata = 0;
    // dest completion model (D-INTEG-01). +STALL=1 -> pseudo-random t2_ready; results must be identical.
    reg        t2_ready = 1;
    reg [15:0] stall_lfsr = 16'hACE1;
    integer    stall_mode = 0;
    always @(posedge clk) begin
        if (stall_mode != 0) begin
            stall_lfsr <= {stall_lfsr[14:0], stall_lfsr[15] ^ stall_lfsr[13] ^ stall_lfsr[12] ^ stall_lfsr[10]};
            t2_ready   <= (stall_lfsr[1:0] != 2'b00);        // ~75% ready
        end else t2_ready <= 1'b1;
    end
    wire [7:0] failure_total, failure_recent, success_after_repair, fem_feat;
    wire [15:0] key, ingress_rejected, key_mismatch, exemplar_full;

    fem_lifecycle dut (
        .clk(clk), .rst_n(rst_n),
        .ing_valid(ing_valid), .ing_domain(ing_domain), .ing_stage(ing_stage), .ing_cap(ing_cap), .ing_macro(ing_macro),
        .ing_prim(ing_prim), .ing_effect(ing_effect), .ing_ctx(ing_ctx), .ing_done(ing_done), .ing_accepted(ing_accepted),
        .rep_valid(rep_valid), .rep_skill_id(rep_skill_id), .rep_skill_ver(rep_skill_ver), .rep_done(rep_done), .rep_accepted(rep_accepted),
        .cmp_start(cmp_start), .cmp_done(cmp_done), .cmp_result(cmp_result), .txn_step(txn_step),
        .rec_start(rec_start), .rec_done(rec_done), .recover_state(recover_state), .integrity_fault(integrity_fault),
        .t2_we(t2_we), .t2_addr(t2_addr), .t2_wdata(t2_wdata), .t2_rdata(t2_rdata), .t2_ready(t2_ready),
        .busy(busy), .life_state(life_state), .failure_total(failure_total), .failure_recent(failure_recent),
        .success_after_repair(success_after_repair), .regression_count(regression_count), .unresolved(unresolved),
        .compacted(compacted), .key(key), .n_raw(n_raw), .ingress_rejected(ingress_rejected), .key_mismatch(key_mismatch),
        .exemplar_full(exemplar_full), .fem_feat(fem_feat)
    );

    // ---------------- persistent T2 model (NOT reset by rst_n) ----------------
    reg [31:0] t2 [0:15];
    integer k;
    always @(posedge clk) begin
        // t2_ready clock-enables the whole T2 interface: a write completes and the 1-cycle read
        // register advances only on a ready cycle (D-INTEG-01 candidate contract).
        if (t2_ready) begin
            t2_rdata <= t2[t2_addr];
            if (t2_we) t2[t2_addr] <= t2_wdata;
        end
    end
    wire t2_raw_present = t2[8][16] | t2[9][16] | t2[10][16] | t2[11][16];
    wire t2_committed   = (t2[4] == 32'hC0117ED0);
    wire t2_index_proto = (t2[5] == 32'd1);
    reg  monitor_armed = 0;
    integer inv_violations = 0;
    always @(negedge clk) if (monitor_armed) begin
        if (!t2_raw_present && !t2_committed) begin inv_violations = inv_violations + 1; $display("  INVARIANT {false,false} at %0t", $time); end
        if (t2_index_proto && !t2_committed)  begin inv_violations = inv_violations + 1; $display("  INVARIANT index->proto while uncommitted at %0t", $time); end
    end
    always @(posedge clk) if (t2_we && t2_ready && t2_addr >= 8 && t2_wdata[16]) monitor_armed <= 1;
    integer t2_writes = 0;                       // counts every completed T2 word write (proves "no write" on corrupt recovery)
    always @(posedge clk) if (t2_we && t2_ready) t2_writes = t2_writes + 1;

    task t2_clear; begin for (k = 0; k < 16; k = k + 1) t2[k] = 32'd0; monitor_armed = 0; end endtask

    // ---------------- helpers ----------------
    reg [31:0] mem [0:255];
    reg [1023:0] vec_path;
    integer errors = 0, timeout, i, p;
    reg [31:0] e_key, e_w0, e_w1, e_cw, e_rej, e_mis, e_nrows, e_reopen1, e_reopen2;
    reg [31:0] r_b, r_rs, r_life, r_raw, r_com, r_flife, r_ffeat, r_fraw;
    reg [31:0] c_cut, c_addr, c_flip, c_rs, c_life, c_raw, c_if, c_idx, n_corrupt;
    reg [31:0] t2_snap [0:15];
    integer writes_before, j;
    reg [7:0] ctrl_feat;

    task fail; input [255:0] msg; begin errors = errors + 1; $display("  FAIL: %0s", msg); end endtask

    task pulse_reset; begin
        @(negedge clk); rst_n = 0; @(negedge clk); @(negedge clk); rst_n = 1; @(negedge clk);
    end endtask

    task ingress; input [1:0] dom; input [2:0] ctx; begin
        @(negedge clk);
        ing_domain = dom; ing_stage = 3; ing_cap = 5; ing_macro = 2; ing_prim = 7; ing_effect = 4; ing_ctx = ctx;
        ing_valid = 1; @(negedge clk); ing_valid = 0;
        timeout = 0; while (!ing_done && timeout < 50) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!ing_done) fail("ingress timeout");
    end endtask

    task repair; input [7:0] ver; begin
        @(negedge clk); rep_skill_id = 8'h11; rep_skill_ver = ver; rep_valid = 1; @(negedge clk); rep_valid = 0;
        timeout = 0; while (!rep_done && timeout < 50) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!rep_done) fail("repair timeout");
    end endtask

    task drive_to_resolved; begin
        ingress(2'd1, 3'd1);   // ENGINEERING_TOOL -> rejected (Vivado/CI never becomes FEM)
        if (ing_accepted) fail("tool failure accepted into FEM");
        ingress(2'd2, 3'd1);   // HOST_INJECT -> rejected
        if (ing_accepted) fail("host injection accepted into FEM");
        ingress(2'd0, 3'd1);   // RAW
        if (life_state !== 3'd0) fail("expected RAW after first capture");
        ingress(2'd0, 3'd1);   // CLUSTERED (same key, other episode)
        if (life_state !== 3'd1) fail("expected CLUSTERED");
        ingress(2'd0, 3'd6);   // different typed key -> mismatch observable, no state change
        if (ing_accepted) fail("different key accepted into single prototype");
        repair(8'h01);
        if (life_state !== 3'd2) fail("expected RESOLVED");
        repair(8'h01); repair(8'h01);
        if (success_after_repair !== 8'd3) fail("sar != 3");
        if (n_raw !== 4'd2) fail("n_raw != 2");
        if (key !== e_key[15:0]) begin $display("    key got %04x exp %04x", key, e_key[15:0]); fail("typed key mismatch"); end
        if (ingress_rejected !== e_rej[15:0]) fail("ingress_rejected mismatch");
        if (key_mismatch !== e_mis[15:0]) fail("key_mismatch mismatch");
    end endtask

    task start_cmp; begin @(negedge clk); cmp_start = 1; @(negedge clk); cmp_start = 0; end endtask
    task wait_cmp; begin
        timeout = 0; while (!cmp_done && timeout < 200) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!cmp_done) fail("cmp timeout");
    end endtask
    task do_recover; begin
        @(negedge clk); rec_start = 1; @(negedge clk); rec_start = 0;
        timeout = 0; while (!rec_done && timeout < 200) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!rec_done) fail("recover timeout");
    end endtask

    task load_row; input integer idx; begin
        p = 9 + idx * 8;
        r_b = mem[p]; r_rs = mem[p+1]; r_life = mem[p+2]; r_raw = mem[p+3]; r_com = mem[p+4];
        r_flife = mem[p+5]; r_ffeat = mem[p+6]; r_fraw = mem[p+7];
    end endtask

    initial begin #3000000; $display("FEM_COMPACTION_LOCAL_FAIL watchdog state=%0d", dut.state); $finish; end

    initial begin
        if (!$value$plusargs("VEC=%s", vec_path)) begin $display("FEM_COMPACTION_LOCAL_FAIL no +VEC"); $finish; end
        if ($value$plusargs("STALL=%d", stall_mode)) $display("T2_READY_STALL_MODE=%0d", stall_mode);
        for (i = 0; i < 256; i = i + 1) mem[i] = 32'hXXXX_XXXX;
        $readmemh(vec_path, mem);   // short-file warning expected
        e_key = mem[0]; e_w0 = mem[1]; e_w1 = mem[2]; e_cw = mem[3]; e_rej = mem[4]; e_mis = mem[5]; e_nrows = mem[6];
        e_reopen1 = mem[7]; e_reopen2 = mem[8];

        // ================= CONTROL: uninterrupted compaction =================
        $display("== CONTROL");
        t2_clear; pulse_reset;
        drive_to_resolved;
        start_cmp; wait_cmp;
        load_row(0);
        if (cmp_result !== 3'd0) fail("control cmp_result != OK");
        if (life_state !== r_flife[2:0]) fail("control final life");
        if (n_raw !== r_fraw[3:0] || t2_raw_present) fail("control raw not retired");
        if (!t2_committed || !t2_index_proto) fail("control not committed/indexed");
        if (t2[1] !== e_w0 || t2[2] !== e_w1 || t2[3] !== e_cw) begin
            $display("    W0 %08x/%08x W1 %08x/%08x CRC %08x/%08x", t2[1], e_w0, t2[2], e_w1, t2[3], e_cw);
            fail("prototype words mismatch");
        end
        ctrl_feat = fem_feat;
        if (ctrl_feat !== r_ffeat[7:0]) fail("control fem_feat");
        // regression reopen on the compacted prototype (§11.7)
        ingress(2'd0, 3'd1);
        if ({n_raw, failure_total, unresolved, regression_count, life_state} !==
            {e_reopen1[27:24], e_reopen1[23:16], e_reopen1[8], e_reopen1[6:4], e_reopen1[2:0]}) begin
            $display("    reopen life=%0d reg=%0d unres=%b ftot=%0d nraw=%0d", life_state, regression_count, unresolved, failure_total, n_raw);
            fail("REOPEN observables");
        end
        repair(8'h02);
        if ({success_after_repair, life_state} !== {e_reopen2[15:8], e_reopen2[2:0]}) fail("REOPENED->RESOLVED");
        // guards: compaction must be refused right after reopen+single repair (sar ok but frec cleared... check life)
        if (inv_violations != 0) fail("invariant violated in control");

        // ================= B0..B6: one cut per boundary =================
        for (i = 1; i < e_nrows; i = i + 1) begin
            load_row(i);
            $display("== BOUNDARY B%0d", r_b);
            t2_clear; pulse_reset;
            drive_to_resolved;
            start_cmp;
            timeout = 0;
            while (txn_step !== r_b[3:0] && timeout < 200) begin @(negedge clk); timeout = timeout + 1; end
            if (timeout >= 200) fail("boundary never reached");
            // power cut NOW: logic resets, T2 persists
            rst_n = 0; @(negedge clk); @(negedge clk); rst_n = 1; @(negedge clk);
            if (life_state !== 3'd7) fail("volatile state not cleared by reset");
            do_recover;
            if (recover_state !== r_rs[1:0]) begin
                $display("    recover_state got %0d exp %0d", recover_state, r_rs); fail("recover_state"); end
            if (life_state !== r_life[2:0]) begin $display("    life got %0d exp %0d", life_state, r_life); fail("life after recover"); end
            if (n_raw !== r_raw[3:0]) begin $display("    n_raw got %0d exp %0d", n_raw, r_raw); fail("n_raw after recover"); end
            if (t2_committed !== r_com[0]) fail("committed after recover");
            if (t2_index_proto && !t2_committed) fail("index->proto uncommitted after recover");
            if (life_state == 3'd2) begin   // rolled back: compaction must be re-runnable to completion
                start_cmp; wait_cmp;
                if (cmp_result !== 3'd0) fail("re-run cmp_result != OK");
            end
            if (life_state !== r_flife[2:0]) fail("final life");
            if (n_raw !== r_fraw[3:0] || t2_raw_present) fail("final raw not retired");
            if (fem_feat !== r_ffeat[7:0] || fem_feat !== ctrl_feat) fail("fem_feat differs from control");
            if (!t2_committed || !t2_index_proto) fail("final not committed/indexed");
            if (t2[1] !== e_w0 || t2[2] !== e_w1 || t2[3] !== e_cw) fail("final prototype words");
        end

        // ===== FEM_DEST_INTEGRITY dest COMMITTED_CORRUPT: media damage AFTER the commit (C-CODE-07) =====
        p = 9 + e_nrows * 8;
        n_corrupt = mem[p]; p = p + 1;
        for (i = 0; i < n_corrupt; i = i + 1) begin
            c_cut = mem[p]; c_addr = mem[p+1]; c_flip = mem[p+2]; c_rs = mem[p+3]; c_life = mem[p+4];
            c_raw = mem[p+5]; c_if = mem[p+6]; c_idx = mem[p+7]; p = p + 8;
            $display("== CORRUPT word %0d after %0s", c_addr, (c_cut == 32'hFFFFFFFF) ? "full commit" : "cut");
            t2_clear; pulse_reset;
            drive_to_resolved;
            start_cmp;
            if (c_cut == 32'hFFFFFFFF) wait_cmp;
            else begin
                timeout = 0;
                while (txn_step !== c_cut[3:0] && timeout < 200) begin @(negedge clk); timeout = timeout + 1; end
                if (timeout >= 200) fail("corrupt: boundary never reached");
            end
            if (!t2_committed) fail("corrupt: precondition COMMIT not on media");
            // power cut, then the medium loses/changes one prototype word (word-atomic damage model)
            rst_n = 0; @(negedge clk); @(negedge clk);
            t2[c_addr[3:0]] = t2[c_addr[3:0]] ^ c_flip;
            for (j = 0; j < 16; j = j + 1) t2_snap[j] = t2[j];
            rst_n = 1; @(negedge clk);
            writes_before = t2_writes;
            do_recover;
            if (integrity_fault !== c_if[0]) fail("corrupt: integrity_fault (dest COMMITTED_CORRUPT) not asserted");
            if (recover_state !== c_rs[1:0]) begin $display("    recover_state got %0d exp %0d", recover_state, c_rs); fail("corrupt: compaction class must be held N/A (0)"); end
            if (recover_state == 2'd2) fail("corrupt: dest CORRUPT upgraded to COMMITTED_NEW");
            if (life_state !== c_life[2:0]) begin $display("    life got %0d exp %0d", life_state, c_life); fail("corrupt: life after recover"); end
            if (n_raw !== c_raw[3:0]) begin $display("    n_raw got %0d exp %0d", n_raw, c_raw); fail("corrupt: raw retired on corrupt recovery"); end
            if (t2[5] !== c_idx) fail("corrupt: index changed");
            if (t2_writes != writes_before) fail("corrupt: recovery wrote T2 (silent roll-forward)");
            for (j = 0; j < 16; j = j + 1) if (t2[j] !== t2_snap[j]) fail("corrupt: T2 word changed by recovery");
            if (!t2_committed) fail("corrupt: COMMIT word must be untouched");
        end
        // a subsequent clean recovery (no corruption) still rolls forward; integrity_fault is volatile
        t2_clear; pulse_reset; drive_to_resolved; start_cmp; wait_cmp; pulse_reset; do_recover;
        if (recover_state !== 2'd2 || integrity_fault) fail("clean recover after corrupt runs");

        if (inv_violations != 0) fail("invariant violations recorded");
        if (errors == 0) $display("FEM_COMPACTION_LOCAL_PASS %0s", vec_path);
        else             $display("FEM_COMPACTION_LOCAL_FAIL %0s errors=%0d", vec_path, errors);
        $finish;
    end
endmodule

`default_nettype wire
