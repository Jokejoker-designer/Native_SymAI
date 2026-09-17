// =============================================================================
// tb_qstar_select.v — Q* op-script testbench (C-CODE-04). XSim + Icarus compatible.
// +VEC=<hex> (layout: ref/learning/gen_qstar_vectors.py). Expected values preregistered
// from qstar_ref.py. Prints TB_QSTAR_CASE_PASS / TB_QSTAR_CASE_FAIL.
// Local pass proves only tested behavior. Not NSPF-X0, not board evidence.
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module tb_qstar_select;
    reg clk = 1'b0, rst_n = 1'b0;
    always #5 clk = ~clk;

    reg         prop_start = 0;
    reg  [63:0] feat_flat = 0;
    reg  [7:0]  legal_mask = 0;
    reg         exam = 0;
    reg  [15:0] epsilon16 = 0;
    wire        prop_done, prop_valid, prop_refused, pending, explored, no_legal, q_sat;
    wire [2:0]  proposed_action, greedy_action;
    wire [31:0] q_sel;

    reg         upd_start = 0, exec_valid = 0, reward_accepted = 0;
    reg  [2:0]  exec_action = 0;
    reg  [15:0] reward16 = 0;
    reg  [31:0] qnext_max32 = 0;
    reg  [7:0]  alpha8 = 0, gamma8 = 0;
    wire        upd_done, upd_applied;
    wire [3:0]  upd_reason;
    wire [31:0] delta_out;

    reg         learn_reset = 0, theta_we = 0, version_we = 0, lfsr_we = 0;
    reg  [5:0]  theta_addr = 0;
    reg  [15:0] theta_wdata = 0, version_wdata = 0, lfsr_wdata = 0;
    wire [15:0] theta_rdata, q_policy_version, lfsr_state;
    wire        busy;
    wire [15:0] explore_count, credit_denied_count, no_legal_count, illegal_exec_count,
                exam_blocked_count, illegal_selection_count, prop_refused_count;

    qstar_select dut (
        .clk(clk), .rst_n(rst_n),
        .prop_start(prop_start), .feat_flat(feat_flat), .legal_mask(legal_mask), .exam(exam), .epsilon16(epsilon16),
        .prop_done(prop_done), .prop_valid(prop_valid), .prop_refused(prop_refused), .pending(pending),
        .proposed_action(proposed_action), .greedy_action(greedy_action),
        .explored(explored), .no_legal(no_legal), .q_sel(q_sel), .q_sat(q_sat),
        .upd_start(upd_start), .exec_valid(exec_valid), .exec_action(exec_action), .reward_accepted(reward_accepted),
        .reward16(reward16), .qnext_max32(qnext_max32), .alpha8(alpha8), .gamma8(gamma8),
        .upd_done(upd_done), .upd_applied(upd_applied), .upd_reason(upd_reason), .delta_out(delta_out),
        .learn_reset(learn_reset), .theta_we(theta_we), .theta_addr(theta_addr), .theta_wdata(theta_wdata),
        .theta_rdata(theta_rdata), .version_we(version_we), .version_wdata(version_wdata),
        .q_policy_version(q_policy_version), .lfsr_we(lfsr_we), .lfsr_wdata(lfsr_wdata), .lfsr_state(lfsr_state),
        .busy(busy), .explore_count(explore_count), .credit_denied_count(credit_denied_count),
        .no_legal_count(no_legal_count), .illegal_exec_count(illegal_exec_count),
        .exam_blocked_count(exam_blocked_count), .illegal_selection_count(illegal_selection_count),
        .prop_refused_count(prop_refused_count)
    );

    reg [31:0] mem [0:16383];
    reg [1023:0] vec_path;
    integer n_ops, i, p, errors, timeout;
    reg [31:0] op, p0, p1, p2, p3, e0, e1, e2, e3, got0;

    task fail; input [255:0] msg; begin
        errors = errors + 1;
        $display("  FAIL op#%0d code=%0d: %0s", i, op, msg);
    end endtask

    task wait_pulse_prop; begin
        timeout = 0;
        while (!prop_done && timeout < 500) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!prop_done) fail("timeout prop_done");
    end endtask

    task wait_pulse_upd; begin
        timeout = 0;
        while (!upd_done && timeout < 500) begin @(posedge clk); #1; timeout = timeout + 1; end
        if (!upd_done) fail("timeout upd_done");
    end endtask

    initial begin
        #4000000;
        $display("TB_QSTAR_CASE_FAIL watchdog state=%0d", dut.state);
        $finish;
    end

    initial begin
        errors = 0;
        if (!$value$plusargs("VEC=%s", vec_path)) begin $display("TB_QSTAR_CASE_FAIL no +VEC"); $finish; end
        for (i = 0; i < 16384; i = i + 1) mem[i] = 32'hXXXX_XXXX;
        $readmemh(vec_path, mem);   // short-file warning expected
        n_ops = mem[0];

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        p = 2;
        for (i = 0; i < n_ops; i = i + 1) begin
            op = mem[p]; p0 = mem[p+1]; p1 = mem[p+2]; p2 = mem[p+3]; p3 = mem[p+4];
            e0 = mem[p+5]; e1 = mem[p+6]; e2 = mem[p+7]; e3 = mem[p+8];
            p = p + 9;
            // all drives at negedge
            case (op)
            32'd1: begin lfsr_we = 1; lfsr_wdata = p0[15:0]; @(negedge clk); lfsr_we = 0; end
            32'd2: begin learn_reset = 1; @(negedge clk); learn_reset = 0; end
            32'd3: begin theta_we = 1; theta_addr = p0[5:0]; theta_wdata = p1[15:0]; @(negedge clk); theta_we = 0; end
            32'd4: begin
                theta_addr = p0[5:0]; #1;
                if (theta_rdata !== e0[15:0]) begin
                    $display("    theta[%0d] got %04x exp %04x", p0[5:0], theta_rdata, e0[15:0]);
                    fail("READ_THETA mismatch");
                end
                @(negedge clk);
            end
            32'd5: begin
                feat_flat = {p1, p0}; legal_mask = p2[7:0]; exam = p2[8]; epsilon16 = p3[15:0];
                prop_start = 1; @(negedge clk); prop_start = 0;
                wait_pulse_prop;
                got0 = {18'd0, pending, prop_refused, q_sat, prop_valid, no_legal, explored, 1'b0, greedy_action, 1'b0, proposed_action};
                if (got0 !== e0) begin
                    $display("    PROPOSE got %04x exp %04x (prop=%0d greedy=%0d expl=%b nolegal=%b valid=%b refused=%b pending=%b)",
                             got0, e0, proposed_action, greedy_action, explored, no_legal, prop_valid, prop_refused, pending);
                    fail("PROPOSE flags/action mismatch");
                end
                if (q_sel !== e1) begin $display("    q_sel got %08x exp %08x", q_sel, e1); fail("q_sel mismatch"); end
                if (lfsr_state !== e2[15:0]) begin $display("    lfsr got %04x exp %04x", lfsr_state, e2[15:0]); fail("lfsr mismatch"); end
                @(negedge clk);
            end
            32'd6: begin
                exec_action = p0[2:0]; exec_valid = p0[4]; reward_accepted = p0[5]; exam = p0[6];
                reward16 = p1[15:0]; qnext_max32 = p2; alpha8 = p3[7:0]; gamma8 = p3[15:8];
                upd_start = 1; @(negedge clk); upd_start = 0;
                wait_pulse_upd;
                if ({pending, upd_reason, 3'd0, upd_applied} !== e0[8:0]) begin
                    $display("    UPDATE applied=%b reason=%0d pending=%b exp e0=%03x", upd_applied, upd_reason, pending, e0[8:0]);
                    fail("UPDATE applied/reason/pending mismatch");
                end
                if (q_policy_version !== e1[15:0]) begin
                    $display("    version got %0d exp %0d", q_policy_version, e1[15:0]); fail("version mismatch"); end
                if (delta_out !== e2) begin $display("    delta got %08x exp %08x", delta_out, e2); fail("delta mismatch"); end
                @(negedge clk);
            end
            32'd7: begin
                if (explore_count !== e0[15:0])       begin $display("    explore %0d exp %0d", explore_count, e0[15:0]); fail("explore_count"); end
                if (prop_refused_count !== e0[31:16]) begin $display("    refused %0d exp %0d", prop_refused_count, e0[31:16]); fail("prop_refused_count"); end
                if (credit_denied_count !== e1[15:0]) begin $display("    denied %0d exp %0d", credit_denied_count, e1[15:0]); fail("credit_denied_count"); end
                if (no_legal_count !== e2[15:0])      fail("no_legal_count");
                if (illegal_exec_count !== e3[15:0])  fail("illegal_exec_count");
                if (exam_blocked_count !== e3[31:16]) fail("exam_blocked_count");
                if (illegal_selection_count !== 16'd0) fail("illegal_selection_count != 0");
            end
            32'd8: begin version_we = 1; version_wdata = p0[15:0]; @(negedge clk); version_we = 0; end
            default: fail("unknown op");
            endcase
        end

        if (errors == 0) $display("TB_QSTAR_CASE_PASS %0s", vec_path);
        else             $display("TB_QSTAR_CASE_FAIL %0s errors=%0d", vec_path, errors);
        $finish;
    end
endmodule

`default_nettype wire
