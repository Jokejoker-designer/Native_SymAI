// =============================================================================
// qstar_select.v — Q* macro-action PROPOSAL + credit-safe update, IMPLEMENTATION_CANDIDATE
// -----------------------------------------------------------------------------
// Spec: §10.8 (unaudited CANDIDATE). Truth source for tests: ref/learning/qstar_ref.py
//
// LAW kept in hardware:
//   * legal_mask is an INPUT (ASTRA legality + capability binding). Q* never creates legality.
//     A masked action can never be proposed. Reserved code 7 is never proposable.
//   * proposed != executed. theta changes only when exec_valid && reward_accepted && !exam &&
//     executed action was legal in the mask latched at proposal time. Otherwise ZERO credit.
//   * EXAM: epsilon forced 0, LFSR not advanced, learning frozen -> deterministic.
//   * learn_reset -> theta=0 (fixed action-priority baseline), version=0, pending cleared.
//     theta_we/version_we restore a snapshot (X0-07 reset/restore).
//   * Pending credit (C-CODE-07, candidate until B's law): at most ONE unresolved pending proposal.
//     TRAIN proposal with a non-empty legal mask -> pending=1. EXAM / no-legal -> no pending.
//     prop_start while pending -> REFUSED (prop_valid=0, prop_refused=1, no LFSR advance, no MAC,
//     prop_refused_count++); the pending credit context is never overwritten.
//     Update consumes pending on APPLIED / NOT_EXECUTED / EXAM_FROZEN / ILLEGAL_EXEC;
//     REWARD_NOT_ACCEPTED keeps it; NO_PROPOSAL changes nothing. No proposal_id here:
//     episode/step/command identity is the action lane's (§05.6).
//   * Emits proposals and observables only. Not truth, not proof, not ASTRA status.
//
// Arithmetic (bit-exact with qstar_ref.py):
//   q_a    = sat32 serial MAC over i of feat_i(Q1.7) * theta[a][i](Q4.12), index order
//   target = sat32( (reward<<7) + rshr8(gamma * qnext_max) )
//   delta  = clip( sat32(target - q_exec), +-DELTA_MAX )
//   theta[a][i] = sat16( theta + rshr22(alpha * delta * feat_i) )    (round half toward +inf)
//
// Serial implementation: ~66 cycles/proposal, ~20 cycles/update. IMPLEMENTATION_DEFINED,
// not a spec latency. D may parallelize/pipeline/fold; only bit-exactness is required.
// =============================================================================
`default_nettype none

module qstar_select #(
    parameter integer DELTA_MAX_LOG2 = 22
) (
    input  wire         clk,
    input  wire         rst_n,

    // ---- proposal request -----------------------------------------------------
    input  wire         prop_start,
    input  wire [63:0]  feat_flat,        // 8 x Q1.7, feat_i = feat_flat[i*8 +: 8]
    input  wire [7:0]   legal_mask,       // from ASTRA/capability path
    input  wire         exam,             // 1 = EXAM (deterministic, frozen)
    input  wire [15:0]  epsilon16,        // Q0.16 exploration probability (TRAIN only)
    output reg          prop_done,        // 1-cycle pulse
    output reg          prop_valid,       // 0 => no legal action (NO_ACTION / X0-15) or refused
    output reg          prop_refused,     // 1 => refused: an earlier proposal is still pending
    output wire         pending,          // unresolved pending proposal exists
    output reg  [2:0]   proposed_action,
    output reg  [2:0]   greedy_action,
    output reg          explored,
    output reg          no_legal,
    output reg  [31:0]  q_sel,            // q of proposed action (debug observable)
    output reg          q_sat,

    // ---- credit-safe update request --------------------------------------------
    input  wire         upd_start,
    input  wire         exec_valid,       // Primitive Executor actually ran it
    input  wire [2:0]   exec_action,
    input  wire         reward_accepted,  // reward source + pending identity valid (external)
    input  wire [15:0]  reward16,         // Q4.12 signed
    input  wire [31:0]  qnext_max32,      // bootstrap value (signed Q13.19)
    input  wire [7:0]   alpha8,           // Q0.8
    input  wire [7:0]   gamma8,           // Q0.8
    output reg          upd_done,         // 1-cycle pulse
    output reg          upd_applied,
    output reg  [3:0]   upd_reason,       // 0 APPLIED 1 NOT_EXEC 2 REWARD_NOT_ACC 3 EXAM 4 ILLEGAL_EXEC 5 NO_PROPOSAL
    output reg  [31:0]  delta_out,

    // ---- learned-state management (reset / restore / readback) ------------------
    input  wire         learn_reset,      // theta := 0, version := 0 (baseline)
    input  wire         theta_we,         // only honored when idle
    input  wire [5:0]   theta_addr,       // a*8 + i
    input  wire [15:0]  theta_wdata,
    output wire [15:0]  theta_rdata,      // async read of theta[theta_addr]
    input  wire         version_we,
    input  wire [15:0]  version_wdata,
    output reg  [15:0]  q_policy_version,
    input  wire         lfsr_we,
    input  wire [15:0]  lfsr_wdata,
    output reg  [15:0]  lfsr_state,

    // ---- observables -------------------------------------------------------------
    output wire         busy,
    output reg  [15:0]  explore_count,
    output reg  [15:0]  credit_denied_count,
    output reg  [15:0]  no_legal_count,
    output reg  [15:0]  illegal_exec_count,
    output reg  [15:0]  exam_blocked_count,
    output reg  [15:0]  illegal_selection_count,  // must remain 0 by construction
    output reg  [15:0]  prop_refused_count        // proposals refused while one was pending
);
    localparam [4:0] S_IDLE = 5'd0, P_MAC = 5'd1, P_SEL = 5'd2, P_OUT = 5'd3,
                     U_CHK  = 5'd4, U_MAC = 5'd5, U_DELTA = 5'd6, U_WRITE = 5'd7, U_OUT = 5'd8,
                     U_TGT  = 5'd9, U_DA  = 5'd10, U_MUL = 5'd11,
                     P_RD   = 5'd12, P_ROW = 5'd13, U_RD = 5'd14, U_DISC = 5'd15,
                     P_EXP1 = 5'd16, P_EXP2 = 5'd17;
    //   Select: P_EXP1 registers k_expl = mod(lfsr, popcnt(mask)) and explore_hit; P_EXP2 registers
    //           a_expl = kth_legal(mask, k_expl); P_SEL then only muxes q_row / best (mask_r -> q_sel cone split).
    // Pipelines (timing only; RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED; arithmetic unchanged):
    //   MAC: {P_RD/U_RD (register theta[a][i], feat_i), P_MAC/U_MAC (acc)} x8; P_ROW compares the row.
    //   Update: U_DISC (gamma*q_next rshr8) -> U_TGT (target sat) -> U_DELTA (clip) -> U_DA (delta*alpha)
    //           -> {U_MUL, U_WRITE} x8.
    // Integer products are exact at full width, so (delta*alpha)*f == (delta*f)*alpha bit-for-bit.
    reg [4:0] state;
    assign busy = (state != S_IDLE);

    // ---- theta storage ----------------------------------------------------------------
    reg [15:0] theta [0:63];
    assign theta_rdata = theta[theta_addr];

    // ---- latched proposal context ---------------------------------------------------------
    reg [63:0] feat_r;        // features latched at proposal (used for credit)
    reg [7:0]  mask_r;        // legal mask latched at proposal (reserved bit cleared)
    reg        have_prop;     // unresolved pending proposal (credit context valid)
    reg        exam_r;
    reg [15:0] eps_r;
    assign pending = have_prop;

    // ---- MAC ---------------------------------------------------------------------------------
    reg [2:0]  a_i, f_i;
    reg signed [31:0] acc;
    reg        acc_sat;
    wire [5:0] mac_addr = {a_i, f_i};
    wire signed [7:0]  f_cur = feat_r[f_i*8 +: 8];
    wire signed [15:0] t_cur = theta[mac_addr];
    reg  signed [7:0]  f_r;                          // registered operands (P_RD / U_RD / U_MUL)
    reg  signed [15:0] t_r;
    wire signed [23:0] prod  = f_r * t_r;
    wire signed [32:0] sum   = {acc[31], acc} + {{9{prod[23]}}, prod};
    wire ovf_p = ~sum[32] & sum[31];
    wire ovf_n =  sum[32] & ~sum[31];
    wire signed [31:0] acc_next = ovf_p ? 32'sh7FFFFFFF : ovf_n ? 32'sh80000000 : sum[31:0];

    // ---- running argmax (strict >, lower code first => tie -> lowest code) ----------------------
    reg        have_best;
    reg [2:0]  best_a;
    reg signed [31:0] best_q;
    reg [31:0] q_row [0:7];
    reg        any_sat;

    // ---- LFSR x^16+x^14+x^13+x^11+1 ----------------------------------------------------------------
    wire lfsr_fb = lfsr_state[0] ^ lfsr_state[2] ^ lfsr_state[3] ^ lfsr_state[5];
    wire [15:0] lfsr_next = {lfsr_fb, lfsr_state[15:1]};

    function [3:0] popcnt8; input [7:0] m; integer k; begin
        popcnt8 = 0; for (k = 0; k < 8; k = k + 1) popcnt8 = popcnt8 + m[k];
    end endfunction

    function [2:0] mod_small; input [2:0] x; input [3:0] n; reg [3:0] t; integer k; begin
        t = {1'b0, x};
        for (k = 0; k < 7; k = k + 1) if (t >= n) t = t - n;
        mod_small = t[2:0];
    end endfunction

    function [2:0] kth_legal; input [7:0] m; input [2:0] k; reg [3:0] cnt; reg found; integer a; begin
        cnt = 0; found = 0; kth_legal = 3'd7;
        for (a = 0; a < 8; a = a + 1) begin
            if (m[a] && !found) begin
                if (cnt == {1'b0, k}) begin kth_legal = a[2:0]; found = 1; end
                cnt = cnt + 1;
            end
        end
    end endfunction

    // mask_r / lfsr_state / eps_r / exam_r are stable from S_IDLE latch until P_SEL, so the exploration
    // pick is computed in two registered stages (P_EXP1, P_EXP2) instead of one combinational cone.
    wire        explore_hit = ~exam_r & (lfsr_state < eps_r);
    wire [3:0]  n_legal     = popcnt8(mask_r);
    wire [2:0]  k_expl      = mod_small(lfsr_state[15:13], n_legal);
    reg  [2:0]  k_expl_r;                                   // P_EXP1
    reg         hit_r;                                      // P_EXP1
    wire [2:0]  a_expl      = kth_legal(mask_r, k_expl_r);
    reg  [2:0]  a_expl_r;                                   // P_EXP2
    reg         a_expl_ok_r;                                // P_EXP2: mask_r[a_expl]

    // ---- update datapath --------------------------------------------------------------------------
    reg         ev_r, ra_r;
    reg  [2:0]  ea_r;
    reg  [15:0] rew_r;
    reg  [31:0] qn_r;
    reg  [7:0]  alpha_r, gamma_r;
    reg signed [31:0] q_exec_r;
    reg signed [31:0] delta_r;

    wire signed [8:0]  gamma_s  = {1'b0, gamma_r};
    wire signed [40:0] disc_m   = $signed(qn_r) * gamma_s;               // 32s x 9s
    wire signed [40:0] disc_b   = disc_m + 41'sd128;
    wire signed [32:0] disc_r   = disc_b >>> 8;                           // rshr8
    reg  signed [32:0] disc_reg;                                          // U_DISC
    wire signed [32:0] rew_ext  = {{10{rew_r[15]}}, rew_r, 7'b0};         // reward<<7
    wire signed [33:0] tgt_sum  = {rew_ext[32], rew_ext} + {disc_reg[32], disc_reg};
    wire signed [31:0] target   = (tgt_sum > 34'sd2147483647) ? 32'sh7FFFFFFF :
                                  (tgt_sum < -34'sd2147483648) ? 32'sh80000000 : tgt_sum[31:0];
    reg  signed [31:0] target_r;                                          // U_TGT
    wire signed [32:0] d_sum    = {target_r[31], target_r} - {q_exec_r[31], q_exec_r};
    wire signed [31:0] d_sat    = (~d_sum[32] & d_sum[31]) ? 32'sh7FFFFFFF :
                                  ( d_sum[32] & ~d_sum[31]) ? 32'sh80000000 : d_sum[31:0];
    localparam signed [31:0] DMAX = (32'sd1 << DELTA_MAX_LOG2);
    wire signed [31:0] d_clip   = (d_sat > DMAX) ? DMAX : (d_sat < -DMAX) ? -DMAX : d_sat;

    wire signed [8:0]  alpha_s  = {1'b0, alpha_r};
    wire signed [40:0] da       = delta_r * alpha_s;                      // 32s x 9s  (U_DA, once per update)
    reg  signed [40:0] da_r;
    wire signed [48:0] m2       = da_r * f_cur;                           // 41s x 8s  (U_MUL, per element)
    reg  signed [48:0] m2_r;
    wire signed [48:0] m2_b     = m2_r + (49'sd1 << 21);
    wire signed [26:0] step     = m2_b >>> 22;                            // |step| <= 255*2^22*128 >> 22 < 2^15
    wire signed [27:0] th_sum   = {{12{t_r[15]}}, t_r} + {step[26], step};
    wire signed [15:0] th_new   = (th_sum > 28'sd32767) ? 16'sh7FFF : (th_sum < -28'sd32768) ? 16'sh8000 : th_sum[15:0];

    integer s;
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_IDLE; have_prop <= 1'b0; mask_r <= 8'd0; feat_r <= 64'd0; exam_r <= 1'b0; eps_r <= 16'd0;
            prop_done <= 1'b0; prop_valid <= 1'b0; prop_refused <= 1'b0; proposed_action <= 3'd7; greedy_action <= 3'd7;
            explored <= 1'b0; no_legal <= 1'b0; q_sel <= 32'd0; q_sat <= 1'b0;
            upd_done <= 1'b0; upd_applied <= 1'b0; upd_reason <= 4'd0; delta_out <= 32'd0;
            q_policy_version <= 16'd0; lfsr_state <= 16'hACE1;
            explore_count <= 0; credit_denied_count <= 0; no_legal_count <= 0;
            illegal_exec_count <= 0; exam_blocked_count <= 0; illegal_selection_count <= 0; prop_refused_count <= 0;
            a_i <= 0; f_i <= 0; acc <= 0; acc_sat <= 0; have_best <= 0; best_a <= 0; best_q <= 0; any_sat <= 0;
            ev_r <= 0; ra_r <= 0; ea_r <= 0; rew_r <= 0; qn_r <= 0; alpha_r <= 0; gamma_r <= 0;
            q_exec_r <= 0; delta_r <= 0; target_r <= 0; da_r <= 0; m2_r <= 0; t_r <= 0; f_r <= 0; disc_reg <= 0;
            k_expl_r <= 3'd0; hit_r <= 1'b0; a_expl_r <= 3'd7; a_expl_ok_r <= 1'b0;
            for (s = 0; s < 64; s = s + 1) theta[s] <= 16'd0;
            for (s = 0; s < 8; s = s + 1) q_row[s] <= 32'd0;
        end else begin
            prop_done <= 1'b0; upd_done <= 1'b0;

            // learned-state management: honored only when idle (TB/host contract)
            if (state == S_IDLE) begin
                if (learn_reset) begin
                    for (s = 0; s < 64; s = s + 1) theta[s] <= 16'd0;
                    q_policy_version <= 16'd0;
                    have_prop <= 1'b0; mask_r <= 8'd0;
                end else if (theta_we) theta[theta_addr] <= theta_wdata;
                if (version_we && !learn_reset) q_policy_version <= version_wdata;
                if (lfsr_we) lfsr_state <= lfsr_wdata;
            end

            case (state)
            S_IDLE: begin
                if (prop_start && !learn_reset) begin
                    if (have_prop) begin
                        // REFUSE: pending credit context must not be overwritten. No MAC, no LFSR step.
                        prop_valid <= 1'b0; prop_refused <= 1'b1; no_legal <= 1'b0; explored <= 1'b0;
                        proposed_action <= 3'd7; greedy_action <= 3'd7; q_sel <= 32'd0; q_sat <= 1'b0;
                        prop_refused_count <= prop_refused_count + 1'b1;
                        state <= P_OUT;
                    end else begin
                        feat_r <= feat_flat; mask_r <= legal_mask & 8'h7F; exam_r <= exam; eps_r <= epsilon16;
                        prop_refused <= 1'b0;
                        a_i <= 0; f_i <= 0; acc <= 0; acc_sat <= 0; have_best <= 0; any_sat <= 0;
                        state <= P_RD;
                    end
                end else if (upd_start && !learn_reset) begin
                    ev_r <= exec_valid; ra_r <= reward_accepted; ea_r <= exec_action; exam_r <= exam;
                    rew_r <= reward16; qn_r <= qnext_max32; alpha_r <= alpha8; gamma_r <= gamma8;
                    state <= U_CHK;
                end
            end

            // ---------------- proposal ----------------
            P_RD:  begin t_r <= t_cur; f_r <= f_cur; state <= P_MAC; end      // registered operand read

            P_MAC: begin
                acc     <= acc_next;
                acc_sat <= acc_sat | ovf_p | ovf_n;
                f_i     <= f_i + 1'b1;
                state   <= (f_i == 3'd7) ? P_ROW : P_RD;
            end

            P_ROW: begin
                // row complete: acc is q_a (registered in the last P_MAC)
                q_row[a_i] <= acc;
                any_sat <= any_sat | acc_sat;
                if (mask_r[a_i] && (!have_best || acc > best_q)) begin
                    have_best <= 1'b1; best_a <= a_i; best_q <= acc;
                end
                acc <= 0; acc_sat <= 0;
                a_i <= a_i + 1'b1;
                state <= (a_i == 3'd7) ? P_EXP1 : P_RD;
            end

            P_EXP1: begin k_expl_r <= k_expl; hit_r <= explore_hit; state <= P_EXP2; end
            P_EXP2: begin a_expl_r <= a_expl; a_expl_ok_r <= mask_r[a_expl]; state <= P_SEL; end

            P_SEL: begin
                q_sat <= any_sat;
                if (mask_r == 8'd0) begin
                    prop_valid <= 1'b0; no_legal <= 1'b1; explored <= 1'b0;
                    proposed_action <= 3'd7; greedy_action <= 3'd7; q_sel <= 32'd0;
                    no_legal_count <= no_legal_count + 1'b1;
                end else begin
                    have_prop <= ~exam_r;           // creditable only in TRAIN
                    prop_valid <= 1'b1; no_legal <= 1'b0; greedy_action <= best_a;
                    if (hit_r) begin
                        proposed_action <= a_expl_r; explored <= 1'b1; q_sel <= q_row[a_expl_r];
                        explore_count <= explore_count + 1'b1;
                        if (!a_expl_ok_r) illegal_selection_count <= illegal_selection_count + 1'b1;
                    end else begin
                        proposed_action <= best_a; explored <= 1'b0; q_sel <= best_q;
                    end
                end
                if (!exam_r) lfsr_state <= lfsr_next;   // TRAIN advances the preregistered PRNG
                state <= P_OUT;
            end

            P_OUT: begin prop_done <= 1'b1; state <= S_IDLE; end

            // ---------------- update ----------------
            U_CHK: begin
                upd_applied <= 1'b0; delta_out <= 32'd0;
                if (!have_prop)            begin upd_reason <= 4'd5; state <= U_OUT; end                                    // no state change
                else if (!ev_r)            begin upd_reason <= 4'd1; credit_denied_count <= credit_denied_count + 1'b1; have_prop <= 1'b0; state <= U_OUT; end
                else if (!ra_r)            begin upd_reason <= 4'd2; credit_denied_count <= credit_denied_count + 1'b1; state <= U_OUT; end  // pending kept
                else if (exam_r)           begin upd_reason <= 4'd3; exam_blocked_count <= exam_blocked_count + 1'b1; have_prop <= 1'b0; state <= U_OUT; end
                else if (!mask_r[ea_r])    begin upd_reason <= 4'd4; illegal_exec_count <= illegal_exec_count + 1'b1; have_prop <= 1'b0; state <= U_OUT; end
                else begin
                    a_i <= ea_r; f_i <= 0; acc <= 0; acc_sat <= 0;
                    state <= U_RD;
                end
            end

            U_RD:  begin t_r <= t_cur; f_r <= f_cur; state <= U_MAC; end

            U_MAC: begin
                f_i <= f_i + 1'b1;
                acc <= acc_next;
                if (f_i == 3'd7) begin q_exec_r <= acc_next; state <= U_DISC; end
                else state <= U_RD;
            end

            U_DISC:  begin disc_reg <= disc_r; state <= U_TGT; end             // rshr8(gamma*q_next)
            U_TGT:   begin target_r <= target; state <= U_DELTA; end          // sat(reward<<7 + disc)

            U_DELTA: begin
                delta_r <= d_clip;
                state <= U_DA;
            end

            U_DA:    begin da_r <= da; f_i <= 0; state <= U_MUL; end            // delta*alpha once

            U_MUL:   begin m2_r <= m2; t_r <= t_cur; state <= U_WRITE; end      // (delta*alpha)*f_i, theta read

            U_WRITE: begin
                theta[mac_addr] <= th_new;      // a_i == ea_r
                f_i <= f_i + 1'b1;
                if (f_i == 3'd7) begin
                    q_policy_version <= q_policy_version + 1'b1;
                    upd_applied <= 1'b1; upd_reason <= 4'd0; delta_out <= delta_r;
                    have_prop <= 1'b0;              // consumed: exactly one credit per proposal
                    state <= U_OUT;
                end else state <= U_MUL;
            end

            U_OUT: begin upd_done <= 1'b1; state <= S_IDLE; end

            default: state <= S_IDLE;
            endcase
        end
    end
endmodule

`default_nettype wire
