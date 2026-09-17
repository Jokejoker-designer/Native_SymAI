// =============================================================================
// fem_lifecycle.v — FEM FailurePrototype lifecycle + §11.6 atomic compaction + §11.12.3 recovery
// IMPLEMENTATION_CANDIDATE (AGENT_C lane). Truth source: ref/learning/fem_ref.py
// -----------------------------------------------------------------------------
// Single-prototype unit (one typed key, N_RAW exemplar slots). Multi-prototype tables are a
// storage-layout choice for D; the contract here is the lifecycle machine, the commit ORDER
// and the recovery classification. Encodings are LOGICAL_STATE_ENCODING_CANDIDATE.
//
// LAW kept in hardware:
//   * §11.9 ingress: only domain DUT_RUNTIME(0) enters. Tool/CI/host failures are counted and
//     dropped; they never touch lifecycle state or T2.
//   * §11.11 lifecycle: NONE -> RAW -> CLUSTERED -> RESOLVED -> COMPACTED -> REOPENED -> RESOLVED.
//     Counters saturate; no silent wrap.
//   * §11.6 order: build -> write T2 -> verify CRC -> mark COMMITTED -> update index -> retire raw.
//     txn_step exposes boundaries B0..B6 so a testbench can cut power at each one.
//   * §11.12.3 recovery (compaction class, THREE states, recover_state[1:0]): COMMIT magic + prototype
//     CRC valid -> COMMITTED_NEW (roll forward); CRC-valid prototype without COMMIT -> CANDIDATE_NEW
//     (discard, raw authoritative); else OLD_VALID.
//   * FEM_DEST_INTEGRITY (separate namespace, A-C-14 / A-D-INTEG-01; NOT a fourth compaction state):
//     COMMIT magic + dest CRC invalid -> integrity_fault=1 (dest class COMMITTED_CORRUPT). Fail closed:
//     no roll-forward, no index fix, no raw retirement, no T2 write. recover_state is then
//     NOT_APPLICABLE and is held at 2'd0; consumers must test integrity_fault before recover_state.
//     B owns the status mapping (DATA_INTEGRITY_FAIL 0x06 / reason 0x56); D owns media integrity.
//   * t2_ready (D-INTEG-01): destination completion. t2_ready clock-enables the entire T2 interface:
//     the FSM holds t2_we/t2_addr/t2_wdata and freezes while t2_ready=0; a write completes on
//     t2_we && t2_ready; the 1-cycle read register t2_rdata must advance only on ready cycles
//     (rdata for the address presented on the last ready cycle). S_IDLE issues no T2 traffic and is
//     never gated, so requests are not dropped. Tie t2_ready=1 for the local sync model.
//     TB proves stall-invariance with +STALL=1 (pseudo-random ~25% not-ready).
//   * FEM emits features/observables only. Not FACT, not ASTRA status, not an action selector.
//
// T2 port: word-atomic, synchronous read (rdata valid the cycle after addr). Layout in fem_ref.py.
// =============================================================================
`default_nettype none

module fem_lifecycle #(
    parameter integer N_RAW = 4,
    parameter integer CLUSTER_THRESHOLD = 2,
    parameter integer N_STABLE = 3
) (
    input  wire        clk,
    input  wire        rst_n,

    // ---- ingress (typed failure capture) ----------------------------------------
    input  wire        ing_valid,
    input  wire [1:0]  ing_domain,      // 0 DUT_RUNTIME 1 ENGINEERING_TOOL 2 HOST_INJECT 3 reserved
    input  wire [3:0]  ing_stage,
    input  wire [3:0]  ing_cap,
    input  wire [2:0]  ing_macro,
    input  wire [3:0]  ing_prim,
    input  wire [3:0]  ing_effect,
    input  wire [2:0]  ing_ctx,
    output reg         ing_done,        // pulse
    output reg         ing_accepted,

    // ---- repair success (verified by §12 path, external) --------------------------
    input  wire        rep_valid,
    input  wire [7:0]  rep_skill_id,
    input  wire [7:0]  rep_skill_ver,
    output reg         rep_done,
    output reg         rep_accepted,

    // ---- compaction / recovery --------------------------------------------------------
    input  wire        cmp_start,
    output reg         cmp_done,        // pulse
    output reg  [2:0]  cmp_result,      // 0 OK 1 NOT_RESOLVED 2 UNSTABLE 3 RECENT 4 CRC_FAIL
    output reg  [3:0]  txn_step,        // 0..6 = B0..B6 reached, 15 = idle
    input  wire        rec_start,
    output reg         rec_done,        // pulse
    output reg  [1:0]  recover_state,   // compaction class: 0 OLD_VALID 1 CANDIDATE_NEW 2 COMMITTED_NEW (N/A when integrity_fault)
    output reg         integrity_fault, // FEM_DEST_INTEGRITY: dest COMMITTED_CORRUPT (COMMIT magic AND dest CRC invalid); sticky until rst_n

    // ---- T2 persistent store port ------------------------------------------------------
    output reg         t2_we,
    output reg  [3:0]  t2_addr,
    output reg  [31:0] t2_wdata,
    input  wire        t2_ready,        // dest completion (D-INTEG-01); 1 = local sync model
    input  wire [31:0] t2_rdata,

    // ---- observables -----------------------------------------------------------------------
    output wire        busy,
    output reg  [2:0]  life_state,
    output reg  [7:0]  failure_total,
    output reg  [7:0]  failure_recent,
    output reg  [7:0]  success_after_repair,
    output reg  [2:0]  regression_count,
    output reg         unresolved,
    output reg         compacted,
    output reg  [15:0] key,
    output wire [3:0]  n_raw,
    output reg  [15:0] ingress_rejected,
    output reg  [15:0] key_mismatch,
    output reg  [15:0] exemplar_full,
    output wire [7:0]  fem_feat         // candidate FEM feature for SPEAR/Q*: failure_total
);
    // lifecycle codes (candidate)
    localparam [2:0] L_RAW = 3'd0, L_CLUSTERED = 3'd1, L_RESOLVED = 3'd2, L_COMPACTED = 3'd3,
                     L_REOPENED = 3'd4, L_NONE = 3'd7;
    localparam [3:0] A_HDR = 4'd0, A_W0 = 4'd1, A_W1 = 4'd2, A_CRCW = 4'd3, A_COMMIT = 4'd4,
                     A_INDEX = 4'd5, A_HDR2 = 4'd6, A_RAW0 = 4'd8;
    localparam [31:0] COMMIT_MAGIC = 32'hC0117ED0;
    localparam [15:0] CRC_MARK = 16'hA5A5;
    localparam [7:0]  N_STABLE8 = N_STABLE;
    localparam [7:0]  CL_TH8 = CLUSTER_THRESHOLD;

    // ---- states -------------------------------------------------------------------------------
    localparam [5:0]
        S_IDLE = 0,
        ING_STORE = 1, ING_HDR = 2, ING_DONE = 3, ING_HDR2 = 6,
        REP_HDR = 4, REP_DONE = 5, REP_HDR2 = 7,
        C_B0 = 8, C_W0 = 9, C_W1 = 10, C_WCRC = 11, C_B1 = 12,
        C_R0 = 13, C_R0C = 14, C_R1 = 15, C_R1C = 16, C_RCC = 18, C_VERIFY = 19,
        C_COMMIT = 20, C_B3 = 21, C_INDEX = 22, C_B4 = 23, C_RET1 = 24, C_B5 = 25, C_RETN = 26,
        C_B6 = 27, C_HDR = 28, C_DONE = 29,
        R_RH = 32, R_RHC = 33, R_R0 = 34, R_R0C = 35, R_R1 = 36, R_R1C = 37, R_RCC = 39,
        R_RCMC = 41, R_RH2 = 42, R_RRAWC = 45, R_CLASS = 46,
        R_FIXIDX = 47, R_RET = 48, R_HDR = 49, R_DISCARD = 50, R_DONE = 51;
    reg [5:0] state;
    assign busy = (state != S_IDLE);

    reg [7:0]  skill_id, skill_ver;
    reg [N_RAW-1:0] raw_valid;      // volatile mirror of T2 RAW valid bits
    reg [3:0]  ri;                  // raw index iterator
    reg [31:0] rd_w0, rd_w1, rd_cw, rd_hdr, rd_commit, rd_index, rd_hdr2;
    reg        first_capture;

    function [3:0] popc; input [N_RAW-1:0] v; integer k; begin
        popc = 0; for (k = 0; k < N_RAW; k = k + 1) popc = popc + v[k];
    end endfunction
    assign n_raw = popc(raw_valid);
    assign fem_feat = failure_total;

    function [7:0] sat8; input [7:0] v; begin sat8 = (v == 8'hFF) ? 8'hFF : v + 8'd1; end endfunction
    function [2:0] sat3; input [2:0] v; begin sat3 = (v == 3'h7) ? 3'h7 : v + 3'd1; end endfunction
    function [15:0] sat16; input [15:0] v; begin sat16 = (v == 16'hFFFF) ? 16'hFFFF : v + 16'd1; end endfunction

    // CRC-16/CCITT-FALSE, MSB first
    function [15:0] crc16_n; input [63:0] d; input integer nbits; integer k; reg [15:0] c; begin
        c = 16'hFFFF;
        for (k = nbits - 1; k >= 0; k = k - 1) begin
            if (d[k] ^ c[15]) c = {c[14:0], 1'b0} ^ 16'h1021;
            else              c = {c[14:0], 1'b0};
        end
        crc16_n = c;
    end endfunction

    // typed key = crc16 over packed 24-bit (domain,stage,cap,macro,prim,effect,ctx)
    wire [23:0] key_pack = {ing_domain, ing_stage, ing_cap, ing_macro, ing_prim, ing_effect, ing_ctx};
    wire [15:0] key_now  = crc16_n({40'd0, key_pack}, 24);

    wire [31:0] hdr_word = {success_after_repair, failure_recent, failure_total, regression_count,
                            compacted, unresolved, life_state};
    wire [31:0] hdr2_word = {skill_id, skill_ver, key};
    wire [31:0] p_w0 = {key, failure_total, success_after_repair};
    wire [31:0] p_w1 = {skill_id, skill_ver, 13'd0, regression_count};
    // CRC pipeline (D-INTEG-01 timing note): the 64-bit CRC16 trees are registered one cycle behind
    // their operands. Operands are stable >= 1 cycle before use (p_w0/p_w1 change only in S_IDLE
    // dispatch, used from C_WCRC; rd_w1 is captured in C_R1C/R_R1 and classified in C_VERIFY/R_CLASS),
    // so behavior is unchanged. Free-running (not gated by t2_ready): a stall only adds margin.
    reg  [15:0] crc_p_r, crc_rd_r;
    always @(posedge clk) begin
        crc_p_r  <= crc16_n({p_w0, p_w1}, 64);
        crc_rd_r <= crc16_n({rd_w0, rd_w1}, 64);
    end
    wire [31:0] p_cw = {CRC_MARK, crc_p_r};

    // first free / first valid raw slot
    function [3:0] first_free; input [N_RAW-1:0] v; integer k; reg f; begin
        first_free = 4'hF; f = 0;
        for (k = 0; k < N_RAW; k = k + 1) if (!v[k] && !f) begin first_free = k[3:0]; f = 1; end
    end endfunction
    function [3:0] first_valid; input [N_RAW-1:0] v; integer k; reg f; begin
        first_valid = 4'hF; f = 0;
        for (k = 0; k < N_RAW; k = k + 1) if (v[k] && !f) begin first_valid = k[3:0]; f = 1; end
    end endfunction
    wire [3:0] free_slot  = first_free(raw_valid);
    wire [3:0] valid_slot = first_valid(raw_valid);

    // recovery classification
    wire rec_crc_valid = (rd_cw[31:16] == CRC_MARK) && (rd_cw[15:0] == crc_rd_r);
    wire rec_committed = (rd_commit == COMMIT_MAGIC);

    // compaction guard
    wire [2:0] guard = (life_state != L_RESOLVED) ? 3'd1 :
                       (success_after_repair < N_STABLE8) ? 3'd2 :
                       (failure_recent != 8'd0) ? 3'd3 : 3'd0;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_IDLE; t2_we <= 1'b0; t2_addr <= 4'd0; t2_wdata <= 32'd0;
            ing_done <= 0; ing_accepted <= 0; rep_done <= 0; rep_accepted <= 0;
            cmp_done <= 0; cmp_result <= 0; txn_step <= 4'hF; rec_done <= 0; recover_state <= 0; integrity_fault <= 0;
            life_state <= L_NONE; failure_total <= 0; failure_recent <= 0; success_after_repair <= 0;
            regression_count <= 0; unresolved <= 0; compacted <= 0; key <= 0;
            ingress_rejected <= 0; key_mismatch <= 0; exemplar_full <= 0;
            skill_id <= 0; skill_ver <= 0; raw_valid <= {N_RAW{1'b0}}; ri <= 0;
            rd_w0 <= 0; rd_w1 <= 0; rd_cw <= 0; rd_hdr <= 0; rd_commit <= 0; rd_index <= 0; rd_hdr2 <= 0;
            first_capture <= 0;
        end else if (t2_ready || state == S_IDLE) begin
            // Freeze (hold t2_we/addr/wdata) while the destination is not ready. S_IDLE issues no T2
            // traffic, so request dispatch is never gated by t2_ready (a request is not dropped).
            t2_we <= 1'b0;
            ing_done <= 0; rep_done <= 0; cmp_done <= 0; rec_done <= 0;

            case (state)
            // ------------------------------------------------------------------ idle / dispatch
            S_IDLE: begin
                if (ing_valid) begin
                    if (ing_domain != 2'd0) begin
                        ingress_rejected <= sat16(ingress_rejected); ing_accepted <= 0; state <= ING_DONE;
                    end else if (life_state == L_NONE) begin
                        key <= key_now; life_state <= L_RAW; failure_total <= 8'd1; failure_recent <= 8'd1;
                        ing_accepted <= 1; first_capture <= 1; state <= ING_STORE;
                    end else if (key_now != key) begin
                        key_mismatch <= sat16(key_mismatch); ing_accepted <= 0; state <= ING_DONE;
                    end else begin
                        failure_total <= sat8(failure_total); failure_recent <= sat8(failure_recent);
                        if (life_state == L_RAW && sat8(failure_total) >= CL_TH8) life_state <= L_CLUSTERED;
                        else if (life_state == L_COMPACTED) begin
                            life_state <= L_REOPENED; regression_count <= sat3(regression_count); unresolved <= 1'b1;
                        end
                        ing_accepted <= 1; first_capture <= 0; state <= ING_STORE;
                    end
                end else if (rep_valid) begin
                    if (life_state == L_CLUSTERED || life_state == L_REOPENED) begin
                        life_state <= L_RESOLVED; skill_id <= rep_skill_id; skill_ver <= rep_skill_ver; unresolved <= 0;
                        success_after_repair <= sat8(success_after_repair); failure_recent <= 0;
                        rep_accepted <= 1; state <= REP_HDR2;
                    end else if (life_state == L_RESOLVED) begin
                        success_after_repair <= sat8(success_after_repair); failure_recent <= 0;
                        rep_accepted <= 1; state <= REP_HDR2;
                    end else begin rep_accepted <= 0; state <= REP_DONE; end
                end else if (cmp_start) begin
                    cmp_result <= guard;
                    if (guard != 3'd0) state <= C_DONE;
                    else begin txn_step <= 4'd0; state <= C_B0; end
                end else if (rec_start) begin
                    state <= R_RH;
                end
            end

            // ------------------------------------------------------------------ ingress
            ING_STORE: begin
                if (free_slot != 4'hF) begin
                    t2_we <= 1; t2_addr <= A_RAW0 + free_slot; t2_wdata <= {15'd0, 1'b1, key};
                    raw_valid[free_slot] <= 1'b1;
                end else exemplar_full <= sat16(exemplar_full);
                state <= first_capture ? ING_HDR2 : ING_HDR;
            end
            ING_HDR2: begin t2_we <= 1; t2_addr <= A_HDR2; t2_wdata <= hdr2_word; state <= ING_HDR; end
            ING_HDR:  begin t2_we <= 1; t2_addr <= A_HDR; t2_wdata <= hdr_word; state <= ING_DONE; end
            ING_DONE: begin ing_done <= 1; state <= S_IDLE; end

            // ------------------------------------------------------------------ repair (identity/repair fields durable, §11.5)
            REP_HDR2: begin t2_we <= 1; t2_addr <= A_HDR2; t2_wdata <= hdr2_word; state <= REP_HDR; end
            REP_HDR:  begin t2_we <= 1; t2_addr <= A_HDR; t2_wdata <= hdr_word; state <= REP_DONE; end
            REP_DONE: begin rep_done <= 1; state <= S_IDLE; end

            // ------------------------------------------------------------------ compaction (§11.6 order)
            C_B0:    begin state <= C_W0; end                                            // B0: nothing written
            C_W0:    begin t2_we <= 1; t2_addr <= A_W0;   t2_wdata <= p_w0; state <= C_W1; end
            C_W1:    begin t2_we <= 1; t2_addr <= A_W1;   t2_wdata <= p_w1; state <= C_WCRC; end
            C_WCRC:  begin t2_we <= 1; t2_addr <= A_CRCW; t2_wdata <= p_cw; state <= C_B1; end
            C_B1:    begin txn_step <= 4'd1; state <= C_R0; end                          // B1: after T2 write
            // sync read: data for the address set in state k is captured in state k+2
            C_R0:    begin t2_addr <= A_W0;   state <= C_R0C; end
            C_R0C:   begin t2_addr <= A_W1;   state <= C_R1; end
            C_R1:    begin rd_w0 <= t2_rdata; t2_addr <= A_CRCW; state <= C_R1C; end
            C_R1C:   begin rd_w1 <= t2_rdata; state <= C_RCC; end
            C_RCC:   begin rd_cw <= t2_rdata; state <= C_VERIFY; end
            C_VERIFY: begin
                if (rec_crc_valid) begin txn_step <= 4'd2; state <= C_COMMIT; end        // B2: after CRC verify
                else begin cmp_result <= 3'd4; state <= C_DONE; end                       // partial proto stays; raw authoritative
            end
            C_COMMIT: begin t2_we <= 1; t2_addr <= A_COMMIT; t2_wdata <= COMMIT_MAGIC; state <= C_B3; end
            C_B3:    begin txn_step <= 4'd3; state <= C_INDEX; end                       // B3: after COMMITTED mark
            C_INDEX: begin t2_we <= 1; t2_addr <= A_INDEX; t2_wdata <= 32'd1; state <= C_B4; end
            C_B4:    begin txn_step <= 4'd4; state <= C_RET1; end                        // B4: after index update
            C_RET1: begin
                if (valid_slot != 4'hF) begin
                    t2_we <= 1; t2_addr <= A_RAW0 + valid_slot; t2_wdata <= 32'd0; raw_valid[valid_slot] <= 1'b0;
                end
                state <= C_B5;
            end
            C_B5:    begin txn_step <= 4'd5; state <= C_RETN; end                        // B5: during retirement
            C_RETN: begin
                if (valid_slot != 4'hF) begin
                    t2_we <= 1; t2_addr <= A_RAW0 + valid_slot; t2_wdata <= 32'd0; raw_valid[valid_slot] <= 1'b0;
                end else state <= C_B6;
            end
            C_B6:    begin txn_step <= 4'd6; life_state <= L_COMPACTED; compacted <= 1'b1; state <= C_HDR; end  // B6
            C_HDR:   begin t2_we <= 1; t2_addr <= A_HDR; t2_wdata <= hdr_word; state <= C_DONE; end
            C_DONE:  begin cmp_done <= 1; txn_step <= 4'hF; state <= S_IDLE; end

            // ------------------------------------------------------------------ recovery (§11.12.3)
            // pipelined sync reads: addr set in state k -> data captured in state k+2
            R_RH:    begin t2_addr <= A_HDR;    ri <= 0; state <= R_RHC; end
            R_RHC:   begin t2_addr <= A_W0;     state <= R_R0; end
            R_R0:    begin rd_hdr <= t2_rdata;  t2_addr <= A_W1;     state <= R_R0C; end
            R_R0C:   begin rd_w0 <= t2_rdata;   t2_addr <= A_CRCW;   state <= R_R1; end
            R_R1:    begin rd_w1 <= t2_rdata;   t2_addr <= A_COMMIT; state <= R_R1C; end
            R_R1C:   begin rd_cw <= t2_rdata;   t2_addr <= A_INDEX;  state <= R_RCC; end
            R_RCC:   begin rd_commit <= t2_rdata; t2_addr <= A_HDR2; state <= R_RCMC; end
            R_RCMC:  begin rd_index <= t2_rdata;  t2_addr <= A_RAW0; state <= R_RH2; end
            R_RH2:   begin rd_hdr2 <= t2_rdata;   t2_addr <= A_RAW0 + 4'd1; ri <= 0; state <= R_RRAWC; end
            R_RRAWC: begin
                raw_valid[ri] <= t2_rdata[16];
                ri <= ri + 4'd1;
                t2_addr <= A_RAW0 + ri + 4'd2;
                if (ri == N_RAW - 1) state <= R_CLASS;
            end
            R_CLASS: begin
                // restore volatile from write-through header
                life_state <= rd_hdr[2:0]; unresolved <= rd_hdr[3]; compacted <= rd_hdr[4];
                regression_count <= rd_hdr[7:5]; failure_total <= rd_hdr[15:8];
                failure_recent <= rd_hdr[23:16]; success_after_repair <= rd_hdr[31:24];
                key <= rd_hdr2[15:0]; skill_id <= rd_hdr2[31:24]; skill_ver <= rd_hdr2[23:16];
                if (rec_committed && !rec_crc_valid) begin
                    // FEM_DEST_INTEGRITY: dest COMMITTED_CORRUPT. Separate namespace; compaction class N/A (held 0).
                    recover_state <= 2'd0; integrity_fault <= 1'b1; state <= R_DONE;   // fail closed: no write
                end else if (rec_committed) begin
                    recover_state <= 2'd2;
                    state <= (rd_index != 32'd1) ? R_FIXIDX : R_RET;
                end else if (rec_crc_valid) begin
                    recover_state <= 2'd1; state <= R_DISCARD;
                end else begin
                    recover_state <= 2'd0; state <= R_DONE;
                end
            end
            R_FIXIDX: begin t2_we <= 1; t2_addr <= A_INDEX; t2_wdata <= 32'd1; state <= R_RET; end
            R_RET: begin
                if (valid_slot != 4'hF) begin
                    t2_we <= 1; t2_addr <= A_RAW0 + valid_slot; t2_wdata <= 32'd0; raw_valid[valid_slot] <= 1'b0;
                end else begin
                    life_state <= L_COMPACTED; compacted <= 1'b1; state <= R_HDR;
                end
            end
            R_HDR:    begin t2_we <= 1; t2_addr <= A_HDR; t2_wdata <= hdr_word; state <= R_DONE; end
            R_DISCARD: begin t2_we <= 1; t2_addr <= A_CRCW; t2_wdata <= 32'd0; state <= R_DONE; end
            R_DONE:   begin rec_done <= 1; state <= S_IDLE; end

            default: state <= S_IDLE;
            endcase
        end
    end
endmodule

`default_nettype wire
