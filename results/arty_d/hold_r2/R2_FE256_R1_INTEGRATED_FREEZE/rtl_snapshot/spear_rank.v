// =============================================================================
// spear_rank.v — SPEAR micro-ranking, IMPLEMENTATION_CANDIDATE (AGENT_C lane)
// -----------------------------------------------------------------------------
// Spec: §10.7 (logical_stage_0..5). Truth source for tests: ref/learning/spear_ref.py
//
// Locked: UTILITY != TRUTH ; TOP_K != ANSWER. This module emits an ordered
// inspection queue plus observables. It never decides an epistemic status.
//   * invalid_count / invalid_pulse           -> observable, NOT mapped to UNKNOWN
//   * tie_overflow (TIE_OVERFLOW_BEYOND_K_HARD) -> observable, final status owned by B/ASTRA
//   * k_invalid                               -> observable; K contract violated -> fail-closed
//
// Profile inputs (A-ID-PROFILE-01, C-CODE-07): semantic ID = 32 bits. prof_active_id_max comes
// from the loaded board/knowledge-pack profile (wired by D). candidate_ref > prof_active_id_max
// is DEFENSIVE validation (ID_OUT_OF_ACTIVE_RANGE -> dropped, invalid_count++), not identity
// definition; the authoritative checker is the T1 directory admit. No baked [31:24]==0.
// K contract (fail-closed): k_soft>=1, k_hard>=1, k_hard<=K_HARD_MAX (slot capacity). Violation
// -> k_invalid=1, admitted_count=0, tie_overflow=0. k_soft>k_hard is legal (K = min).
//
// RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED (this candidate is serial: one
// feature MAC per cycle). LATENCY = POST_ROUTE_MEASURED. No latency claim.
//
// CandidateDescriptor / raw_meta layouts are LEARNING_LOCAL_LAYOUT_CANDIDATE.
// Fixed-point: Qm.n with m including sign. f: Q1.7 (8b), w: Q4.12 (16b),
// product Q5.19 (24b), accumulator ACC_W bits saturating (index order),
// score = sat16((acc + 2^(SHIFT-1)) >>> SHIFT)  (round half toward +inf).
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module spear_rank #(
    parameter integer ACC_W      = 32,
    parameter integer SHIFT      = 12,
    parameter integer K_HARD_MAX = 8,      // slot capacity; runtime k_hard > K_HARD_MAX -> k_invalid
    parameter integer SEQ_W      = 16
) (
    input  wire                     clk,
    input  wire                     rst_n,

    // ---- loaded profile (D wires; sampled on q_start) ------------------------
    input  wire [31:0]              prof_active_id_max,   // inclusive upper bound of the active ID range

    // ---- query context (sampled on q_start) --------------------------------
    input  wire                     q_start,
    input  wire [7:0]               q_k_soft,
    input  wire [7:0]               q_k_hard,             // from the same profile (K_HARD) or query
    input  wire [3:0]               q_relation_class,
    input  wire [3:0]               q_max_hops,
    input  wire [3:0]               q_answer_kind,
    input  wire [15:0]              q_namespace_id,
    input  wire [15:0]              q_generation,
    input  wire [255:0]             w_flat,           // w[i] = w_flat[i*16 +: 16], Q4.12

    // ---- candidate stream ---------------------------------------------------
    input  wire                     cand_valid,
    input  wire [127:0]             cand_desc,
    output wire                     cand_ready,
    input  wire                     q_end,            // request finalize (honored when idle-accepting)

    // ---- per-candidate observables ---------------------------------------------
    output reg                      score_valid,
    output reg  [31:0]              score_ref,
    output reg  [15:0]              score_val,
    output reg                      score_sat,
    output reg                      invalid_pulse,

    // ---- finalize -----------------------------------------------------------
    output reg                      done,
    output reg  [7:0]               admitted_count,
    output reg                      tie_overflow,
    output reg                      k_invalid,        // K contract violated for this query (fail-closed)
    output reg  [15:0]              invalid_count,
    output reg  [15:0]              n_valid,
    output wire [(K_HARD_MAX+1)*32-1:0] adm_ref_flat,
    output wire [(K_HARD_MAX+1)*16-1:0] adm_score_flat,
    output wire [K_HARD_MAX:0]          adm_sat_flat
);

    localparam integer NSLOT = K_HARD_MAX + 1;   // +1 witness slot for TIE-R0 overflow detection

    // ------------------------------------------------------------------------
    // FSM
    // ------------------------------------------------------------------------
    localparam [3:0] S_IDLE   = 4'd0,
                     S_ACCEPT = 4'd1,
                     S_VALID  = 4'd2,
                     S_MAC    = 4'd3,
                     S_ROUND  = 4'd4,
                     S_INSERT = 4'd5,
                     S_FINAL  = 4'd6,
                     S_DONE   = 4'd7,
                     S_CHECK  = 4'd8,   // timing stages: CRC16-112 split in two registered halves
                     S_CHECK2 = 4'd9,
                     S_PREFIN = 4'd10,  // timing stage: register boundary-slot picks before S_FINAL
                     S_MACRD  = 4'd11;  // timing stage: register MAC operands (feature/weight mux) before S_MAC
    reg [3:0] state;

    assign cand_ready = (state == S_ACCEPT);

    // ------------------------------------------------------------------------
    // latched context
    // ------------------------------------------------------------------------
    reg [7:0]   k_soft_r, k_hard_r;
    reg [31:0]  id_max_r;
    reg [3:0]   rel_r, hops_r, ak_r;
    reg [15:0]  ns_r, gen_r;
    reg [255:0] w_r;
    reg         end_req;

    localparam [7:0] K_HARD_MAX8 = K_HARD_MAX;
    wire k_bounds_bad = (q_k_soft == 8'd0) || (q_k_hard == 8'd0) || (q_k_hard > K_HARD_MAX8);

    reg [127:0] desc_r;
    reg [SEQ_W-1:0] seq_next, seq_cur;

    // ------------------------------------------------------------------------
    // CRC-16/CCITT-FALSE over desc[127:16] (112 bits, MSB first)
    // ------------------------------------------------------------------------
    // CRC16-CCITT bit-serial step over 56 bits from a given state; crc16_112(d) ==
    // crc16_56(crc16_56(16'hFFFF, d[111:56]), d[55:0]) exactly (bit-serial CRC is resumable).
    function [15:0] crc16_56;
        input [15:0] init;
        input [55:0] d;
        integer i;
        reg [15:0] c;
        reg fb;
        begin
            c = init;
            for (i = 55; i >= 0; i = i - 1) begin
                fb = d[i] ^ c[15];
                c  = {c[14:0], 1'b0};
                if (fb) c = c ^ 16'h1021;
            end
            crc16_56 = c;
        end
    endfunction
    wire [31:0] d_ref   = desc_r[127:96];
    wire [15:0] d_ns    = desc_r[91:76];
    wire [15:0] d_gen   = desc_r[75:60];
    wire [39:0] d_meta  = desc_r[59:20];
    wire [15:0] d_crc   = desc_r[15:0];
    // two-stage CRC: S_CHECK registers the first 56 bits, S_CHECK2 finishes and registers desc_ok
    reg  [15:0] crc_mid_r;
    wire [15:0] crc_hi  = crc16_56(16'hFFFF, desc_r[127:72]);
    wire [15:0] crc_lo  = crc16_56(crc_mid_r, desc_r[71:16]);
    wire        crc_ok  = (crc_lo == d_crc);
    wire        id_ok   = (d_ref <= id_max_r);          // defensive profile range check (not identity)
    reg         desc_ok;

    // ------------------------------------------------------------------------
    // logical_stage_0: typed feature extraction (Q1.7, non-negative magnitudes)
    // ------------------------------------------------------------------------
    wire [3:0] m_rel   = d_meta[39:36];
    wire [3:0] m_hop   = d_meta[35:32];
    wire       m_prov  = d_meta[31];
    wire [1:0] m_ctx   = d_meta[30:29];
    wire [3:0] m_hot   = d_meta[28:25];
    wire [3:0] m_fem   = d_meta[24:21];
    wire [3:0] m_rec   = d_meta[20:17];
    wire [3:0] m_ak    = d_meta[16:13];
    wire [1:0] m_hint  = d_meta[12:11];
    wire [1:0] m_post  = d_meta[10:9];
    wire [3:0] m_vfit  = d_meta[8:5];
    wire       m_conf  = d_meta[4];
    wire [3:0] m_cost  = d_meta[3:0];

    wire [4:0] prox_raw = {1'b0, hops_r} - {1'b0, m_hop};          // 5-bit two's complement
    wire [3:0] prox     = (hops_r > m_hop) ? prox_raw[3:0] : 4'd0;

    function [7:0] b8; input [3:0] b; begin b8 = {1'b0, b, 3'b000}; end endfunction

    wire [7:0] f0  = (m_rel == rel_r)  ? 8'd127 : 8'd0;
    wire [7:0] f1  = b8(prox);
    wire [7:0] f2  = m_prov ? 8'd127 : 8'd0;
    wire [7:0] f3  = (m_ctx == 2'd0) ? 8'd0 : (m_ctx == 2'd1) ? 8'd64 : 8'd127;
    wire [7:0] f4  = b8(m_hot);
    wire [7:0] f5  = b8(m_fem);
    wire [7:0] f6  = b8(m_rec);
    wire [7:0] f7  = (d_gen == gen_r) ? 8'd127 : 8'd0;
    wire [7:0] f8  = (m_ak == ak_r)   ? 8'd127 : 8'd0;
    wire [7:0] f9  = (m_hint == 2'd0) ? 8'd0 : (m_hint == 2'd1) ? 8'd42 : (m_hint == 2'd2) ? 8'd84 : 8'd126;
    wire [7:0] f10 = (m_post == 2'd0) ? 8'd0 : (m_post == 2'd3) ? 8'd126 : 8'd63;
    wire [7:0] f11 = b8(m_vfit);
    wire [7:0] f12 = m_conf ? 8'd127 : 8'd0;
    wire [7:0] f13 = (d_ns == ns_r) ? 8'd127 : 8'd0;
    wire [7:0] f14 = b8(4'd15 - m_cost);
    wire [7:0] f15 = 8'd0;

    wire [127:0] feat_now = {f15, f14, f13, f12, f11, f10, f9, f8, f7, f6, f5, f4, f3, f2, f1, f0};
    reg  [127:0] feat_r;

    // ------------------------------------------------------------------------
    // logical_stage_1: serial MAC with saturating accumulate (index order)
    // ------------------------------------------------------------------------
    reg  [3:0]              mac_i;
    reg  signed [ACC_W-1:0] acc;
    reg                     sat_r;

    wire signed [7:0]        f_i = $signed(feat_r[mac_i*8 +: 8]);
    wire signed [15:0]       w_i = $signed(w_r[mac_i*16 +: 16]);
    reg  signed [7:0]        f_op;                                     // S_MACRD: registered operands
    reg  signed [15:0]       w_op;
    wire signed [23:0]       prod = f_op * w_op;                       // Q5.19, 24b
    wire signed [ACC_W:0]    sum_ext = {acc[ACC_W-1], acc} + {{(ACC_W+1-24){prod[23]}}, prod};

    localparam signed [ACC_W:0] ACC_MAX_E = {2'b00, {(ACC_W-1){1'b1}}};   //  2^(ACC_W-1)-1
    localparam signed [ACC_W:0] ACC_MIN_E = {2'b11, {(ACC_W-1){1'b0}}};   // -2^(ACC_W-1)

    wire                     sum_ovf_p = (sum_ext > ACC_MAX_E);
    wire                     sum_ovf_n = (sum_ext < ACC_MIN_E);
    wire signed [ACC_W-1:0]  acc_next  = sum_ovf_p ? ACC_MAX_E[ACC_W-1:0] :
                                         sum_ovf_n ? ACC_MIN_E[ACC_W-1:0] : sum_ext[ACC_W-1:0];

    // ------------------------------------------------------------------------
    // logical_stage_2: round half toward +inf, then sat16
    // ------------------------------------------------------------------------
    localparam signed [ACC_W:0] RND_BIAS = (1 << (SHIFT-1));
    wire signed [ACC_W:0]   biased  = {acc[ACC_W-1], acc} + RND_BIAS;
    wire signed [ACC_W:0]   shifted = biased >>> SHIFT;
    wire                    sc_ovf_p = (shifted > $signed({{(ACC_W+1-16){1'b0}}, 16'h7FFF}));
    wire                    sc_ovf_n = (shifted < $signed({{(ACC_W+1-16){1'b1}}, 16'h8000}));
    wire [15:0]             score_now = sc_ovf_p ? 16'h7FFF : sc_ovf_n ? 16'h8000 : shifted[15:0];
    wire                    sat_now   = sat_r | sc_ovf_p | sc_ovf_n;

    reg [15:0] score_r;
    reg        satf_r;

    // ------------------------------------------------------------------------
    // logical_stage_3/4: sorted slot array (NSLOT), deterministic total order
    //   key: score desc, f1 desc, f2 desc, f13 desc, seq asc
    // ------------------------------------------------------------------------
    reg                 sl_v   [0:NSLOT-1];
    reg [31:0]          sl_ref [0:NSLOT-1];
    reg [15:0]          sl_sc  [0:NSLOT-1];
    reg                 sl_sat [0:NSLOT-1];
    reg [7:0]           sl_f1  [0:NSLOT-1];
    reg [7:0]           sl_f2  [0:NSLOT-1];
    reg [7:0]           sl_f13 [0:NSLOT-1];
    reg [SEQ_W-1:0]     sl_seq [0:NSLOT-1];

    wire [7:0]  n_f1  = feat_r[15:8];
    wire [7:0]  n_f2  = feat_r[23:16];
    wire [7:0]  n_f13 = feat_r[111:104];

    // a "beats" new entry (a goes before new)
    function beats;
        input        a_v;
        input [15:0] a_sc;  input [7:0] a_f1; input [7:0] a_f2; input [7:0] a_f13; input [SEQ_W-1:0] a_seq;
        input [15:0] b_sc;  input [7:0] b_f1; input [7:0] b_f2; input [7:0] b_f13; input [SEQ_W-1:0] b_seq;
        begin
            if (!a_v)                                   beats = 1'b0;
            else if ($signed(a_sc) != $signed(b_sc))    beats = ($signed(a_sc) > $signed(b_sc));
            else if (a_f1  != b_f1)                     beats = (a_f1  > b_f1);
            else if (a_f2  != b_f2)                     beats = (a_f2  > b_f2);
            else if (a_f13 != b_f13)                    beats = (a_f13 > b_f13);
            else                                        beats = (a_seq < b_seq);
        end
    endfunction

    reg [7:0] ins_pos;
    integer j;
    always @* begin
        ins_pos = 8'd0;
        for (j = 0; j < NSLOT; j = j + 1)
            if (beats(sl_v[j], sl_sc[j], sl_f1[j], sl_f2[j], sl_f13[j], sl_seq[j],
                      score_r, n_f1, n_f2, n_f13, seq_cur))
                ins_pos = ins_pos + 8'd1;
    end

    // ------------------------------------------------------------------------
    // finalize helpers (TIE-R0)
    // ------------------------------------------------------------------------
    // k_eff = min(k_soft, k_hard) registered at q_start; boundary-slot picks registered in S_PREFIN
    // (timing stage), so S_FINAL only compares registered values and counts count_ge.
    reg  [7:0]  k_eff;
    reg  [15:0] sc_at_km1, sc_at_k, sc_at_kh;
    reg         v_at_kh;
    reg  [15:0] sc_km1_c, sc_k_c, sc_kh_c;
    reg         v_kh_c;
    reg  [7:0]  count_ge;
    integer q;
    always @* begin
        sc_km1_c = 16'd0; sc_k_c = 16'd0; sc_kh_c = 16'd0; v_kh_c = 1'b0;
        for (q = 0; q < NSLOT; q = q + 1) begin
            if (q == k_eff - 1)  sc_km1_c = sl_sc[q];
            if (q == k_eff)      sc_k_c   = sl_sc[q];
            if (q == k_hard_r) begin sc_kh_c = sl_sc[q]; v_kh_c = sl_v[q]; end
        end
        count_ge = 8'd0;
        for (q = 0; q < NSLOT; q = q + 1)
            if (sl_v[q] && ($signed(sl_sc[q]) >= $signed(sc_at_km1)))
                count_ge = count_ge + 8'd1;
    end

    // ------------------------------------------------------------------------
    // main sequential
    // ------------------------------------------------------------------------
    integer s;
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_IDLE; end_req <= 1'b0; done <= 1'b0; desc_ok <= 1'b0; crc_mid_r <= 16'd0;
            score_valid <= 1'b0; invalid_pulse <= 1'b0;
            admitted_count <= 8'd0; tie_overflow <= 1'b0; k_invalid <= 1'b0; invalid_count <= 16'd0; n_valid <= 16'd0;
            k_soft_r <= 8'd0; k_hard_r <= 8'd0; id_max_r <= 32'd0; k_eff <= 8'd0;
            sc_at_km1 <= 16'd0; sc_at_k <= 16'd0; sc_at_kh <= 16'd0; v_at_kh <= 1'b0; f_op <= 8'd0; w_op <= 16'd0;
            seq_next <= {SEQ_W{1'b0}}; seq_cur <= {SEQ_W{1'b0}};
            score_ref <= 32'd0; score_val <= 16'd0; score_sat <= 1'b0;
            mac_i <= 4'd0; acc <= {ACC_W{1'b0}}; sat_r <= 1'b0; score_r <= 16'd0; satf_r <= 1'b0;
            for (s = 0; s < NSLOT; s = s + 1) begin
                sl_v[s] <= 1'b0; sl_ref[s] <= 32'd0; sl_sc[s] <= 16'd0; sl_sat[s] <= 1'b0;
                sl_f1[s] <= 8'd0; sl_f2[s] <= 8'd0; sl_f13[s] <= 8'd0; sl_seq[s] <= {SEQ_W{1'b0}};
            end
        end else begin
            done <= 1'b0; score_valid <= 1'b0; invalid_pulse <= 1'b0;
            if (q_end) end_req <= 1'b1;

            case (state)
            S_IDLE: if (q_start) begin
                k_soft_r <= q_k_soft; k_hard_r <= q_k_hard; id_max_r <= prof_active_id_max;
                k_eff <= (q_k_soft < q_k_hard) ? q_k_soft : q_k_hard;
                k_invalid <= k_bounds_bad;
                rel_r <= q_relation_class; hops_r <= q_max_hops; ak_r <= q_answer_kind;
                ns_r <= q_namespace_id; gen_r <= q_generation; w_r <= w_flat;
                end_req <= q_end;
                invalid_count <= 16'd0; n_valid <= 16'd0; tie_overflow <= 1'b0; admitted_count <= 8'd0;
                seq_next <= {SEQ_W{1'b0}};
                for (s = 0; s < NSLOT; s = s + 1) sl_v[s] <= 1'b0;
                state <= S_ACCEPT;
            end

            S_ACCEPT: begin
                if (cand_valid) begin
                    desc_r  <= cand_desc;
                    seq_cur <= seq_next;
                    seq_next <= seq_next + 1'b1;
                    state <= S_CHECK;
                end else if (end_req) begin
                    state <= S_PREFIN;
                end
            end

            S_PREFIN: begin
                sc_at_km1 <= sc_km1_c; sc_at_k <= sc_k_c; sc_at_kh <= sc_kh_c; v_at_kh <= v_kh_c;
                state <= S_FINAL;
            end

            S_CHECK:  begin crc_mid_r <= crc_hi; state <= S_CHECK2; end
            S_CHECK2: begin desc_ok <= crc_ok & id_ok; state <= S_VALID; end

            S_VALID: begin
                if (!desc_ok) begin
                    invalid_count <= invalid_count + 1'b1;
                    invalid_pulse <= 1'b1;
                    state <= S_ACCEPT;
                end else begin
                    feat_r <= feat_now;
                    mac_i  <= 4'd0; acc <= {ACC_W{1'b0}}; sat_r <= 1'b0;
                    state  <= S_MACRD;
                end
            end

            S_MACRD: begin f_op <= f_i; w_op <= w_i; state <= S_MAC; end

            S_MAC: begin
                acc   <= acc_next;
                sat_r <= sat_r | sum_ovf_p | sum_ovf_n;
                mac_i <= mac_i + 1'b1;
                state <= (mac_i == 4'd15) ? S_ROUND : S_MACRD;
            end

            S_ROUND: begin
                score_r <= score_now;
                satf_r  <= sat_now;
                state   <= S_INSERT;
            end

            S_INSERT: begin
                for (s = NSLOT-1; s >= 0; s = s - 1) begin
                    if (s > ins_pos) begin
                        if (s > 0) begin
                            sl_v[s] <= sl_v[s-1]; sl_ref[s] <= sl_ref[s-1]; sl_sc[s] <= sl_sc[s-1];
                            sl_sat[s] <= sl_sat[s-1]; sl_f1[s] <= sl_f1[s-1]; sl_f2[s] <= sl_f2[s-1];
                            sl_f13[s] <= sl_f13[s-1]; sl_seq[s] <= sl_seq[s-1];
                        end
                    end else if (s == ins_pos) begin
                        sl_v[s] <= 1'b1; sl_ref[s] <= d_ref; sl_sc[s] <= score_r; sl_sat[s] <= satf_r;
                        sl_f1[s] <= n_f1; sl_f2[s] <= n_f2; sl_f13[s] <= n_f13; sl_seq[s] <= seq_cur;
                    end
                end
                n_valid     <= n_valid + 1'b1;
                score_valid <= 1'b1; score_ref <= d_ref; score_val <= score_r; score_sat <= satf_r;
                state <= S_ACCEPT;
            end

            S_FINAL: begin
                tie_overflow <= 1'b0;
                if (k_invalid) begin
                    admitted_count <= 8'd0;                           // fail-closed: no queue, no TIE-R0 claim
                end else if (n_valid <= {8'd0, k_eff}) begin
                    admitted_count <= n_valid[7:0];
                end else if (sc_at_k != sc_at_km1) begin
                    admitted_count <= k_eff;
                end else if (n_valid <= {8'd0, k_hard_r}) begin
                    admitted_count <= count_ge;                       // widen: admit all of T
                end else if (v_at_kh && (sc_at_kh == sc_at_km1)) begin
                    tie_overflow   <= 1'b1;                           // TIE_OVERFLOW_BEYOND_K_HARD
                    admitted_count <= k_eff;
                end else begin
                    admitted_count <= count_ge;
                end
                state <= S_DONE;
            end

            S_DONE: begin
                done  <= 1'b1;
                end_req <= 1'b0;
                state <= S_IDLE;
            end

            default: state <= S_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // logical_stage_5: emit queue (flattened)
    // ------------------------------------------------------------------------
    genvar g;
    generate
        for (g = 0; g < NSLOT; g = g + 1) begin : G_OUT
            assign adm_ref_flat  [g*32 +: 32] = sl_ref[g];
            assign adm_score_flat[g*16 +: 16] = sl_sc[g];
            assign adm_sat_flat  [g]          = sl_sat[g];
        end
    endgenerate

endmodule

`default_nettype wire
