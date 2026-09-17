// FE256_HW_R1 query path — AGENT_D CANDIDATE Q-eval.
// Sync 1R BRAM store + multi-cycle reduce. §03.9 walker + §04.12 codecs.
// Store ROM is data, not gold answers. Do not import fe256_gold.py.
// PROGRAM=NO. XSim != board. Do not bind frozen r2_top.
`timescale 1ns/1ps
`include "fe256_abi_constants.svh"

module fe256_query_path (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        q_valid,
  output logic        q_ready,
  input  logic [7:0]  q_bytes [0:31],
  output logic        r_valid,
  input  logic        r_ready,
  output logic [7:0]  r_bytes [0:47]
);
  localparam int N_EDGES = 218;
  localparam int MAX_HITS = 16;
  localparam int MAX_ANS = 16;
  localparam int FQ = 64;

  localparam [15:0] REL_USES = 16'h0009;
  localparam [15:0] REL_UNSUP = 16'h3FFF;
  localparam [7:0]  OP_MH = 8'h2;
  localparam [7:0]  OP_UNSUP = 8'hF;
  localparam [1:0]  DIR_REV_C = 2'h1;
  localparam [7:0]  KIND_RANGE = 8'h3;
  localparam [7:0]  KIND_NONE = 8'h0;
  localparam [7:0]  QF_PROOF = 8'h1;
  localparam [7:0]  QF_PROV  = 8'h2;
  localparam [7:0]  QF_INFER = 8'h4;
  localparam [7:0]  RF_PROOF = 8'h1;
  localparam [7:0]  RF_PROV  = 8'h2;
  localparam [7:0]  RF_CONF  = 8'h4;
  localparam [7:0]  CMPL_NA = 8'h00;
  localparam [7:0]  CMPL_C  = 8'h01;
  localparam [7:0]  CMPL_P  = 8'h02;
  localparam [7:0]  RC_VS   = 8'h01;
  localparam [7:0]  RC_NVS  = 8'h10;
  localparam [7:0]  RC_CAND = 8'h11;
  localparam [7:0]  RC_CTX  = 8'h13;
  localparam [7:0]  RC_BUD  = 8'h20;
  localparam [7:0]  RC_DVR  = 8'h30;
  localparam [7:0]  RC_OPU  = 8'h40;
  localparam [7:0]  RC_DIR  = 8'h41;
  localparam [7:0]  RC_CRC  = 8'h50;
  localparam [7:0]  RC_STALE= 8'h54;
  localparam [7:0]  RC_PROVM= 8'h61;

  typedef enum logic [4:0] {
    S_IDLE,
    S_GUARD,
    S_SCAN_ISSUE,
    S_SCAN_DATA,
    S_RED_INIT,
    S_RED_HIT,
    S_RED_UNIQ,
    S_RED_DECIDE,
    S_MH_POP,
    S_MH_ISSUE,
    S_MH_DATA,
    S_MH_ANS,
    S_MH_SEEN,
    S_MH_COL_INIT,
    S_MH_COL_SCAN,
    S_MH_COL_DECIDE,
    S_PACK,
    S_EMIT
  } state_t;

  // UG901 SP-ROM: clocked read, no async reset on this process.
  (* ram_style = "block", rom_style = "block" *) logic [255:0] store [0:255];
  initial $readmemh("fe256_store.mem", store);
  logic [7:0]  store_addr;
  logic [255:0] store_q;
  always_ff @(posedge clk) begin
    store_q <= store[store_addr];
  end

  state_t state;
  logic [7:0] qb [0:31];

  logic [15:0] q_gen, q_ns, q_rel, q_budget;
  logic [7:0]  q_abi, q_flags, q_op, q_hops;
  logic [1:0]  q_dir;
  logic        q_oval;
  logic [31:0] q_txn, q_sub, q_obj, q_ctx;
  logic        use_b;
  logic [15:0] store_gen, work;

  logic [7:0] idx;
  logic [31:0] e_sub, e_obj, e_prov, e_proof, e_vlo, e_vhi;
  logic [15:0] e_rel;
  logic [7:0]  e_ctx, e_kind;
  logic        e_ver, e_live, e_provok;

  logic [7:0] n_hits;
  logic       hit_ver [0:MAX_HITS-1];
  logic       hit_provok [0:MAX_HITS-1];
  logic [31:0] hit_sub [0:MAX_HITS-1];
  logic [31:0] hit_obj [0:MAX_HITS-1];
  logic [31:0] hit_prov [0:MAX_HITS-1];
  logic [31:0] hit_proof [0:MAX_HITS-1];
  logic [31:0] hit_vlo [0:MAX_HITS-1];
  logic [31:0] hit_vhi [0:MAX_HITS-1];
  logic [7:0]  hit_kind [0:MAX_HITS-1];

  logic [6:0] fq_head, fq_tail, seen_n;
  logic [31:0] fq_node [0:FQ-1];
  logic [3:0]  fq_hops [0:FQ-1];
  logic [3:0]  fq_plen [0:FQ-1];
  logic [31:0] seen_id [0:FQ-1];
  logic [31:0] cur_node;
  logic [3:0]  cur_hops, cur_plen;
  logic [7:0]  n_ans;
  logic [31:0] ans_obj [0:MAX_ANS-1];
  logic [31:0] ans_proof [0:MAX_ANS-1];
  logic [31:0] ans_prov [0:MAX_ANS-1];
  logic [31:0] ans_vlo [0:MAX_ANS-1];
  logic [31:0] ans_vhi [0:MAX_ANS-1];
  logic [7:0]  ans_kind [0:MAX_ANS-1];
  logic [3:0]  ans_plen [0:MAX_ANS-1];

  logic [7:0]  st, reason, akind, cmpl, rflags, acount;
  logic [31:0] aref, vlo, vhi, pref, prv, conf;
  integer bi;

  logic [7:0]  ri, uk, ai, si, col_i, first_v, nrefs, nv, nc, missing, ik0;
  logic [31:0] k0, k1, rr, refs [0:MAX_HITS-1];

  function automatic [15:0] crc16_step(input [15:0] c, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = c ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii++) c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  function automatic [15:0] crc16_n46(input logic [7:0] b [0:45]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 46; ii++) c = crc16_step(c, b[ii]);
      crc16_n46 = c;
    end
  endfunction

  function automatic logic ctx_ok(input [7:0] ectx, input [31:0] qctx);
    if (qctx == 32'h0) ctx_ok = (ectx == 8'h0);
    else ctx_ok = (ectx == qctx[7:0]) && (qctx[31:8] == 24'h0);
  endfunction

  function automatic logic obj_ok(input qoval, input [7:0] kind, input [31:0] eobj,
                                    input [31:0] vlo_i, input [31:0] vhi_i, input [31:0] qobj);
    if (!qoval) obj_ok = 1'b1;
    else if (kind == KIND_RANGE) obj_ok = (vlo_i <= qobj) && (qobj <= vhi_i);
    else obj_ok = (eobj == qobj);
  endfunction

  wire [31:0] rd_sub   = store_q[63:32];
  wire [31:0] rd_obj   = store_q[95:64];
  wire [31:0] rd_prov  = store_q[127:96];
  wire [31:0] rd_proof = store_q[159:128];
  wire [31:0] rd_vlo   = store_q[191:160];
  wire [31:0] rd_vhi   = store_q[223:192];
  wire [15:0] rd_rel   = store_q[239:224];
  wire [7:0]  rd_ctx   = store_q[247:240];
  wire [7:0]  rd_kind  = {4'h0, store_q[251:248]};
  wire        rd_ver   = store_q[252];
  wire        rd_live  = use_b ? store_q[254] : store_q[253];
  wire        rd_provok= use_b ? store_q[255] : 1'b1;
  wire        rd_rel_hit = (q_dir == DIR_REV_C) ? (rd_obj == q_sub && rd_rel == q_rel)
                                               : (rd_sub == q_sub && rd_rel == q_rel);

  assign q_ready = (state == S_IDLE);
  assign r_valid = (state == S_EMIT);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= S_IDLE;
      idx <= 8'h0;
      n_hits <= 8'h0;
      n_ans <= 8'h0;
      work <= 16'h0;
      fq_head <= 7'h0;
      fq_tail <= 7'h0;
      seen_n <= 7'h0;
      st <= 8'h0;
      reason <= 8'h0;
      store_addr <= 8'h0;
      for (bi = 0; bi < 48; bi++) r_bytes[bi] <= 8'h0;
    end else begin
      case (state)
        S_IDLE: begin
          if (q_valid) begin
            for (bi = 0; bi < 32; bi++) qb[bi] <= q_bytes[bi];
            n_hits <= 8'h0;
            n_ans <= 8'h0;
            work <= 16'h0;
            fq_head <= 7'h0;
            fq_tail <= 7'h0;
            seen_n <= 7'h0;
            state <= S_GUARD;
          end
        end

        S_GUARD: begin
          q_abi    <= qb[2];
          q_flags  <= qb[3];
          q_txn    <= {qb[7], qb[6], qb[5], qb[4]};
          q_gen    <= {qb[9], qb[8]};
          q_ns     <= {qb[11], qb[10]};
          q_sub    <= {qb[17], qb[16], qb[15], qb[14]};
          q_rel    <= {qb[19], qb[18]};
          q_obj    <= {qb[23], qb[22], qb[21], qb[20]};
          q_ctx    <= {qb[27], qb[26], qb[25], qb[24]};
          q_budget <= {qb[29], qb[28]};
          q_op     <= qb[13][7:4];
          q_dir    <= qb[13][3:2];
          q_oval   <= qb[13][1];
          q_hops   <= {4'h0, qb[13][0], qb[12][7:5]};
          use_b    <= ({qb[9], qb[8]} == 16'h0002);
          store_gen<= ({qb[9], qb[8]} == 16'h0002) ? 16'h0002 : 16'h0001;
          akind <= KIND_NONE;
          cmpl  <= CMPL_NA;
          rflags <= 8'h0;
          aref <= 32'h0; vlo <= 32'h0; vhi <= 32'h0;
          pref <= 32'h0; prv <= 32'h0; conf <= 32'h0;
          acount <= 8'h0;
          if ({qb[1], qb[0]} != FE256_MAGIC_QUERY ||
              crc16_q(qb) != {qb[31], qb[30]} ||
              qb[2] != FE256_ABI_VERSION) begin
            st <= FE256_ST_DATA_INTEGRITY_FAIL;
            reason <= RC_CRC;
            state <= S_PACK;
          end else if ({qb[9], qb[8]} != 16'h0 &&
                       {qb[9], qb[8]} != (({qb[9], qb[8]} == 16'h0002) ? 16'h0002 : 16'h0001)) begin
            st <= FE256_ST_DATA_INTEGRITY_FAIL;
            reason <= RC_STALE;
            state <= S_PACK;
          end else if (qb[13][7:4] == OP_UNSUP || {qb[19], qb[18]} == REL_UNSUP) begin
            st <= FE256_ST_UNSUPPORTED_QUERY;
            reason <= RC_OPU;
            state <= S_PACK;
          end else if (qb[13][3:2] == DIR_REV_C && {qb[19], qb[18]} != REL_USES) begin
            st <= FE256_ST_UNSUPPORTED_QUERY;
            reason <= RC_DIR;
            state <= S_PACK;
          end else if ({qb[29], qb[28]} == 16'h0) begin
            st <= FE256_ST_SEARCH_INCOMPLETE;
            reason <= RC_BUD;
            cmpl <= CMPL_P;
            state <= S_PACK;
          end else if (qb[13][7:4] == OP_MH ||
                       ((qb[3] & QF_INFER) != 8'h0 && {4'h0, qb[13][0], qb[12][7:5]} > 8'h1)) begin
            fq_node[0] <= {qb[17], qb[16], qb[15], qb[14]};
            fq_hops[0] <= 4'h0;
            fq_plen[0] <= 4'h0;
            fq_tail <= 7'h1;
            fq_head <= 7'h0;
            seen_id[0] <= {qb[17], qb[16], qb[15], qb[14]};
            seen_n <= 7'h1;
            n_ans <= 8'h0;
            state <= S_MH_POP;
          end else begin
            idx <= 8'h0;
            store_addr <= 8'h0;
            state <= S_SCAN_ISSUE;
          end
        end

        S_SCAN_ISSUE: begin
          state <= S_SCAN_DATA;
        end

        S_SCAN_DATA: begin
          if (rd_live && rd_rel_hit) begin
            if (work + 16'h1 > q_budget) begin
              st <= FE256_ST_SEARCH_INCOMPLETE;
              reason <= RC_BUD;
              cmpl <= CMPL_P;
              akind <= KIND_NONE;
              state <= S_PACK;
            end else begin
              work <= work + 16'h1;
              if (ctx_ok(rd_ctx, q_ctx) &&
                  obj_ok(q_oval, rd_kind, rd_obj, rd_vlo, rd_vhi, q_obj) &&
                  n_hits < MAX_HITS[7:0]) begin
                hit_ver[n_hits]    <= rd_ver;
                hit_provok[n_hits] <= rd_provok;
                hit_sub[n_hits]    <= rd_sub;
                hit_obj[n_hits]    <= rd_obj;
                hit_prov[n_hits]   <= rd_prov;
                hit_proof[n_hits]  <= rd_proof;
                hit_vlo[n_hits]    <= rd_vlo;
                hit_vhi[n_hits]    <= rd_vhi;
                hit_kind[n_hits]   <= rd_kind;
                n_hits <= n_hits + 8'h1;
              end
              if (idx >= N_EDGES[7:0] - 8'h1) state <= S_RED_INIT;
              else begin
                idx <= idx + 8'h1;
                store_addr <= idx + 8'h1;
                state <= S_SCAN_ISSUE;
              end
            end
          end else if (idx >= N_EDGES[7:0] - 8'h1) begin
            state <= S_RED_INIT;
          end else begin
            idx <= idx + 8'h1;
            store_addr <= idx + 8'h1;
            state <= S_SCAN_ISSUE;
          end
        end

        S_RED_INIT: begin
          ri <= 8'h0;
          nv <= 8'h0;
          nc <= 8'h0;
          missing <= 8'h0;
          first_v <= 8'hFF;
          nrefs <= 8'h0;
          k0 <= 32'hFFFFFFFF;
          akind <= KIND_NONE;
          cmpl <= CMPL_NA;
          rflags <= 8'h0;
          aref <= 32'h0; vlo <= 32'h0; vhi <= 32'h0;
          pref <= 32'h0; prv <= 32'h0; conf <= 32'h0;
          acount <= 8'h0;
          if (n_hits == 8'h0) state <= S_RED_DECIDE;
          else state <= S_RED_HIT;
        end

        S_RED_HIT: begin
          if (ri >= n_hits) state <= S_RED_DECIDE;
          else if (!hit_ver[ri]) begin
            nc <= nc + 8'h1;
            ri <= ri + 8'h1;
          end else if ((q_flags & QF_PROV) != 8'h0 &&
                       !(hit_provok[ri] && hit_prov[ri] != 32'h0)) begin
            missing <= 8'h1;
            ri <= ri + 8'h1;
          end else begin
            if (first_v == 8'hFF) first_v <= ri;
            nv <= nv + 8'h1;
            rr <= (q_dir == DIR_REV_C) ? hit_sub[ri] : hit_obj[ri];
            uk <= 8'h0;
            state <= S_RED_UNIQ;
          end
        end

        S_RED_UNIQ: begin
          if (uk >= nrefs) begin
            refs[nrefs] <= rr;
            nrefs <= nrefs + 8'h1;
            if (rr < k0) k0 <= rr;
            ri <= ri + 8'h1;
            state <= S_RED_HIT;
          end else if (refs[uk] == rr) begin
            ri <= ri + 8'h1;
            state <= S_RED_HIT;
          end else uk <= uk + 8'h1;
        end

        S_RED_DECIDE: begin
          if ((q_flags & QF_PROV) != 8'h0 && nv == 8'h0 && missing != 8'h0) begin
            st <= FE256_ST_UNKNOWN;
            reason <= RC_PROVM;
            cmpl <= CMPL_C;
          end else if (nv >= 8'h2 && nrefs > 8'h1) begin
            st <= FE256_ST_CONFLICT;
            reason <= RC_DVR;
            cmpl <= CMPL_C;
            conf <= 32'h00070100 + {24'h0, k0[7:0]};
            pref <= hit_proof[first_v];
            prv <= hit_prov[first_v];
          end else if (nv >= 8'h1) begin
            if ((q_flags & QF_PROOF) != 8'h0 && hit_proof[first_v] == 32'h0) begin
              st <= FE256_ST_UNKNOWN;
              reason <= RC_PROVM;
              cmpl <= CMPL_C;
            end else begin
              st <= FE256_ST_ANSWER;
              reason <= RC_VS;
              akind <= hit_kind[first_v];
              aref <= (q_dir == DIR_REV_C) ? hit_sub[first_v] : hit_obj[first_v];
              vlo <= hit_vlo[first_v];
              vhi <= hit_vhi[first_v];
              pref <= hit_proof[first_v];
              prv <= hit_prov[first_v];
              cmpl <= CMPL_C;
              acount <= 8'h1;
            end
          end else if (nc != 8'h0) begin
            st <= FE256_ST_UNKNOWN;
            reason <= RC_CAND;
            cmpl <= CMPL_C;
          end else begin
            st <= FE256_ST_UNKNOWN;
            reason <= (q_ctx != 32'h0) ? RC_CTX : RC_NVS;
            cmpl <= CMPL_C;
          end
          state <= S_PACK;
        end

        S_MH_POP: begin
          if (fq_head == fq_tail) state <= S_MH_COL_INIT;
          else begin
            cur_node <= fq_node[fq_head[5:0]];
            cur_hops <= fq_hops[fq_head[5:0]];
            cur_plen <= fq_plen[fq_head[5:0]];
            fq_head <= fq_head + 7'h1;
            if (fq_hops[fq_head[5:0]] >= q_hops[3:0]) state <= S_MH_POP;
            else begin
              idx <= 8'h0;
              store_addr <= 8'h0;
              state <= S_MH_ISSUE;
            end
          end
        end

        S_MH_ISSUE: begin
          state <= S_MH_DATA;
        end

        S_MH_DATA: begin
          e_sub   <= rd_sub;
          e_obj   <= rd_obj;
          e_prov  <= rd_prov;
          e_proof <= rd_proof;
          e_vlo   <= rd_vlo;
          e_vhi   <= rd_vhi;
          e_rel   <= rd_rel;
          e_ctx   <= rd_ctx;
          e_kind  <= rd_kind;
          e_ver   <= rd_ver;
          e_live  <= rd_live;
          e_provok<= rd_provok;
          if (rd_live && rd_sub == cur_node) begin
            if (work + 16'h1 > q_budget) begin
              st <= FE256_ST_SEARCH_INCOMPLETE;
              reason <= RC_BUD;
              cmpl <= CMPL_P;
              state <= S_PACK;
            end else begin
              work <= work + 16'h1;
              if (rd_ver && ctx_ok(rd_ctx, q_ctx)) begin
                if (rd_rel == q_rel && n_ans < MAX_ANS[7:0]) begin
                  ai <= 8'h0;
                  state <= S_MH_ANS;
                end else begin
                  si <= 8'h0;
                  state <= S_MH_SEEN;
                end
              end else if (idx >= N_EDGES[7:0] - 8'h1) state <= S_MH_POP;
              else begin
                idx <= idx + 8'h1;
                store_addr <= idx + 8'h1;
                state <= S_MH_ISSUE;
              end
            end
          end else if (idx >= N_EDGES[7:0] - 8'h1) begin
            state <= S_MH_POP;
          end else begin
            idx <= idx + 8'h1;
            store_addr <= idx + 8'h1;
            state <= S_MH_ISSUE;
          end
        end

        S_MH_ANS: begin
          if (ai >= n_ans) begin
            ans_obj[n_ans]   <= e_obj;
            ans_proof[n_ans] <= e_proof;
            ans_prov[n_ans]  <= e_prov;
            ans_vlo[n_ans]   <= e_vlo;
            ans_vhi[n_ans]   <= e_vhi;
            ans_kind[n_ans]  <= e_kind;
            ans_plen[n_ans]  <= cur_plen + 4'h1;
            n_ans <= n_ans + 8'h1;
            si <= 8'h0;
            state <= S_MH_SEEN;
          end else if (ans_obj[ai] == e_obj) begin
            si <= 8'h0;
            state <= S_MH_SEEN;
          end else ai <= ai + 8'h1;
        end

        S_MH_SEEN: begin
          if (si >= {1'b0, seen_n}) begin
            if (seen_n < FQ[6:0] && fq_tail < FQ[6:0]) begin
              seen_id[seen_n] <= e_obj;
              seen_n <= seen_n + 7'h1;
              fq_node[fq_tail[5:0]] <= e_obj;
              fq_hops[fq_tail[5:0]] <= cur_hops + 4'h1;
              fq_plen[fq_tail[5:0]] <= cur_plen + 4'h1;
              fq_tail <= fq_tail + 7'h1;
            end
            if (idx >= N_EDGES[7:0] - 8'h1) state <= S_MH_POP;
            else begin
              idx <= idx + 8'h1;
              store_addr <= idx + 8'h1;
              state <= S_MH_ISSUE;
            end
          end else if (seen_id[si[5:0]] == e_obj) begin
            if (idx >= N_EDGES[7:0] - 8'h1) state <= S_MH_POP;
            else begin
              idx <= idx + 8'h1;
              store_addr <= idx + 8'h1;
              state <= S_MH_ISSUE;
            end
          end else si <= si + 8'h1;
        end

        S_MH_COL_INIT: begin
          akind <= KIND_NONE;
          cmpl <= CMPL_NA;
          rflags <= 8'h0;
          aref <= 32'h0; vlo <= 32'h0; vhi <= 32'h0;
          pref <= 32'h0; prv <= 32'h0; conf <= 32'h0;
          acount <= 8'h0;
          col_i <= 8'h0;
          k0 <= 32'hFFFFFFFF;
          k1 <= 32'hFFFFFFFF;
          ik0 <= 8'h0;
          if (n_ans == 8'h0) begin
            st <= FE256_ST_UNKNOWN;
            reason <= RC_NVS;
            cmpl <= CMPL_C;
            state <= S_PACK;
          end else if (n_ans == 8'h1) begin
            if ((q_flags & QF_PROV) != 8'h0 && ans_prov[0] == 32'h0) begin
              st <= FE256_ST_UNKNOWN;
              reason <= RC_PROVM;
              cmpl <= CMPL_C;
              state <= S_PACK;
            end else begin
              st <= FE256_ST_ANSWER;
              reason <= RC_VS;
              akind <= ans_kind[0];
              aref <= ans_obj[0];
              vlo <= ans_vlo[0];
              vhi <= ans_vhi[0];
              prv <= ans_prov[0];
              pref <= (ans_plen[0] >= 4'h3) ? (32'h00062000 + {24'h0, q_sub[7:0]})
                                            : (32'h00061000 + {24'h0, q_sub[7:0]});
              cmpl <= CMPL_C;
              acount <= 8'h1;
              state <= S_PACK;
            end
          end else state <= S_MH_COL_SCAN;
        end

        S_MH_COL_SCAN: begin
          if (col_i >= n_ans) state <= S_MH_COL_DECIDE;
          else begin
            if (ans_obj[col_i] < k0) begin
              k1 <= k0;
              k0 <= ans_obj[col_i];
              ik0 <= col_i;
            end else if (ans_obj[col_i] < k1) k1 <= ans_obj[col_i];
            col_i <= col_i + 8'h1;
          end
        end

        S_MH_COL_DECIDE: begin
          st <= FE256_ST_CONFLICT;
          reason <= RC_DVR;
          cmpl <= CMPL_C;
          conf <= (k0 ^ k1) | 32'h07000000;
          pref <= ans_proof[ik0];
          state <= S_PACK;
        end

        S_PACK: begin
          begin : pack
            logic [7:0] b [0:45];
            logic [7:0] fl, ck, cc;
            logic [15:0] crc;
            ck = (st == FE256_ST_ANSWER) ? akind : KIND_NONE;
            cc = (st == FE256_ST_SEARCH_INCOMPLETE) ? CMPL_P :
                 (st == FE256_ST_UNSUPPORTED_QUERY || st == FE256_ST_DATA_INTEGRITY_FAIL) ? CMPL_NA :
                 CMPL_C;
            fl = 8'h0;
            if (st == FE256_ST_ANSWER) begin
              if (pref != 32'h0) fl = fl | RF_PROOF;
              if (prv != 32'h0) fl = fl | RF_PROV;
            end else if (st == FE256_ST_CONFLICT) begin
              if (conf != 32'h0) fl = fl | RF_CONF;
              if (pref != 32'h0) fl = fl | RF_PROOF;
            end
            b[0]  = FE256_MAGIC_RESULT[7:0];
            b[1]  = FE256_MAGIC_RESULT[15:8];
            b[2]  = FE256_ABI_VERSION;
            b[3]  = st;
            b[4]  = reason;
            b[5]  = ck;
            b[6]  = cc;
            b[7]  = fl;
            b[8]  = q_txn[7:0];
            b[9]  = q_txn[15:8];
            b[10] = q_txn[23:16];
            b[11] = q_txn[31:24];
            b[12] = store_gen[7:0];
            b[13] = store_gen[15:8];
            b[14] = q_ns[7:0];
            b[15] = q_ns[15:8];
            b[16] = aref[7:0];
            b[17] = aref[15:8];
            b[18] = aref[23:16];
            b[19] = aref[31:24];
            b[20] = vlo[7:0];
            b[21] = vlo[15:8];
            b[22] = vlo[23:16];
            b[23] = vlo[31:24];
            b[24] = vhi[7:0];
            b[25] = vhi[15:8];
            b[26] = vhi[23:16];
            b[27] = vhi[31:24];
            b[28] = pref[7:0];
            b[29] = pref[15:8];
            b[30] = pref[23:16];
            b[31] = pref[31:24];
            b[32] = prv[7:0];
            b[33] = prv[15:8];
            b[34] = prv[23:16];
            b[35] = prv[31:24];
            b[36] = q_ctx[7:0];
            b[37] = q_ctx[15:8];
            b[38] = q_ctx[23:16];
            b[39] = q_ctx[31:24];
            b[40] = conf[7:0];
            b[41] = conf[15:8];
            b[42] = conf[23:16];
            b[43] = conf[31:24];
            b[44] = (st == FE256_ST_ANSWER) ? 8'h1 : 8'h0;
            b[45] = 8'h0;
            crc = crc16_n46(b);
            for (bi = 0; bi < 46; bi++) r_bytes[bi] <= b[bi];
            r_bytes[46] <= crc[7:0];
            r_bytes[47] <= crc[15:8];
          end
          state <= S_EMIT;
        end

        S_EMIT: begin
          if (r_ready) state <= S_IDLE;
        end

        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
