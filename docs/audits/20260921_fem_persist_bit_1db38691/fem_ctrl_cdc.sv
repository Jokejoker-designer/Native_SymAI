// fem_ctrl_cdc.sv — clk100 FEM op -> ui_clk fem_on_mig pulses.
// FRST holds fem_rst_n low for 8 ui cycles; MIG/dest are not reset.
// PROGRAM=NO. Not FEM_PERSIST_PASS.
`timescale 1ns/1ps

module fem_ctrl_cdc (
  input  logic        clk100,
  input  logic        rst100_n,
  input  logic        req100,
  input  logic [2:0]  op100,
  input  logic [31:0] arg100,
  output logic        busy100,
  output logic        done100,
  output logic [31:0] s0,
  output logic [31:0] s1,
  output logic [31:0] s2,
  output logic [31:0] s3,
  output logic [31:0] s4,

  input  logic        clk_ui,
  input  logic        rst_ui_n,
  input  logic        pack_idle,
  output logic        ing_valid,
  output logic [1:0]  ing_domain,
  output logic [3:0]  ing_stage,
  output logic [3:0]  ing_cap,
  output logic [2:0]  ing_macro,
  output logic [3:0]  ing_prim,
  output logic [3:0]  ing_effect,
  output logic [2:0]  ing_ctx,
  input  logic        ing_done,
  input  logic        ing_accepted,
  output logic        rep_valid,
  output logic [7:0]  rep_skill_id,
  output logic [7:0]  rep_skill_ver,
  input  logic        rep_done,
  input  logic        rep_accepted,
  output logic        cmp_start,
  input  logic        cmp_done,
  output logic        rec_start,
  input  logic        rec_done,
  output logic        fem_rst_hold,
  input  logic        fem_busy,
  input  logic [2:0]  life_state,
  input  logic        compacted,
  input  logic        unresolved,
  input  logic [1:0]  recover_state,
  input  logic        integrity_fault,
  input  logic [3:0]  n_raw,
  input  logic [2:0]  cmp_result,
  input  logic [3:0]  txn_step,
  input  logic [7:0]  failure_total,
  input  logic [7:0]  failure_recent,
  input  logic [7:0]  success_after_repair,
  input  logic [7:0]  fem_feat,
  input  logic [15:0] key,
  input  logic [15:0] wr_outstanding,
  input  logic        t2_err
);
  localparam logic [2:0] OP_ING = 3'd1, OP_REP = 3'd2, OP_CMP = 3'd3, OP_REC = 3'd4, OP_RST = 3'd5, OP_OBS = 3'd6;

  logic req_tog, ack_tog;
  (* ASYNC_REG = "TRUE" *) logic req_u0, req_u1, req_u2;
  (* ASYNC_REG = "TRUE" *) logic ack_c0, ack_c1, ack_c2;
  logic [2:0] op_hold, op_u;
  logic [31:0] arg_hold, arg_u;
  logic [31:0] s0_lat, s1_lat, s2_lat, s3_lat, s4_lat;
  logic [31:0] s0_h, s1_h, s2_h, s3_h, s4_h;
  logic done_r, pend;
  logic [3:0] rst_cnt;
  typedef enum logic [2:0] { U_IDLE, U_PULSE, U_WAIT, U_RST, U_ACK } u_t;
  u_t ust;

  assign busy100 = (req_tog != ack_c2);
  assign done100 = done_r;
  assign s0 = s0_h;
  assign s1 = s1_h;
  assign s2 = s2_h;
  assign s3 = s3_h;
  assign s4 = s4_h;

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      req_tog <= 1'b0;
      op_hold <= 3'h0;
      arg_hold <= 32'h0;
      ack_c0 <= 1'b0;
      ack_c1 <= 1'b0;
      ack_c2 <= 1'b0;
      s0_h <= 32'h0;
      s1_h <= 32'h0;
      s2_h <= 32'h0;
      s3_h <= 32'h0;
      s4_h <= 32'h0;
      done_r <= 1'b0;
    end else begin
      ack_c0 <= ack_tog;
      ack_c1 <= ack_c0;
      ack_c2 <= ack_c1;
      done_r <= 1'b0;
      if (req100 && (req_tog == ack_c2)) begin
        req_tog <= ~req_tog;
        op_hold <= op100;
        arg_hold <= arg100;
      end
      if (ack_c1 != ack_c2) begin
        s0_h <= s0_lat;
        s1_h <= s1_lat;
        s2_h <= s2_lat;
        s3_h <= s3_lat;
        s4_h <= s4_lat;
        done_r <= 1'b1;
      end
    end
  end

  always_ff @(posedge clk_ui or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      req_u0 <= 1'b0;
      req_u1 <= 1'b0;
      req_u2 <= 1'b0;
      ack_tog <= 1'b0;
      pend <= 1'b0;
      op_u <= 3'h0;
      arg_u <= 32'h0;
      ust <= U_IDLE;
      ing_valid <= 1'b0;
      ing_domain <= 2'h0;
      ing_stage <= 4'd3;
      ing_cap <= 4'd5;
      ing_macro <= 3'd2;
      ing_prim <= 4'd7;
      ing_effect <= 4'd4;
      ing_ctx <= 3'd1;
      rep_valid <= 1'b0;
      rep_skill_id <= 8'h11;
      rep_skill_ver <= 8'h01;
      cmp_start <= 1'b0;
      rec_start <= 1'b0;
      fem_rst_hold <= 1'b0;
      rst_cnt <= 4'h0;
      s0_lat <= 32'h0;
      s1_lat <= 32'h0;
      s2_lat <= 32'h0;
      s3_lat <= 32'h0;
      s4_lat <= 32'h0;
    end else begin
      req_u0 <= req_tog;
      req_u1 <= req_u0;
      req_u2 <= req_u1;
      ing_valid <= 1'b0;
      rep_valid <= 1'b0;
      cmp_start <= 1'b0;
      rec_start <= 1'b0;
      if ((req_u1 != req_u2) && (ack_tog == req_u2)) begin
        pend <= 1'b1;
        op_u <= op_hold;
        arg_u <= arg_hold;
      end

      unique case (ust)
        U_IDLE: begin
          fem_rst_hold <= 1'b0;
          if (pend && pack_idle && !fem_busy) begin
            if (op_u == OP_OBS)
              ust <= U_ACK;
            else if (op_u == OP_RST) begin
              fem_rst_hold <= 1'b1;
              rst_cnt <= 4'd8;
              ust <= U_RST;
            end else
              ust <= U_PULSE;
          end
        end
        U_PULSE: begin
          if (op_u == OP_ING) begin
            ing_domain <= arg_u[1:0];
            ing_ctx <= arg_u[4:2];
            ing_valid <= 1'b1;
          end else if (op_u == OP_REP) begin
            rep_skill_id <= arg_u[7:0];
            rep_skill_ver <= arg_u[15:8];
            rep_valid <= 1'b1;
          end else if (op_u == OP_CMP)
            cmp_start <= 1'b1;
          else if (op_u == OP_REC)
            rec_start <= 1'b1;
          ust <= U_WAIT;
        end
        U_WAIT: begin
          if ((op_u == OP_ING && ing_done) ||
              (op_u == OP_REP && rep_done) ||
              (op_u == OP_CMP && cmp_done) ||
              (op_u == OP_REC && rec_done))
            ust <= U_ACK;
        end
        U_RST: begin
          fem_rst_hold <= 1'b1;
          if (rst_cnt == 4'd0)
            ust <= U_ACK;
          else
            rst_cnt <= rst_cnt - 4'd1;
        end
        U_ACK: begin
          fem_rst_hold <= 1'b0;
          s0_lat <= {13'h0, integrity_fault, compacted, unresolved, recover_state,
                     life_state, n_raw, cmp_result, txn_step};
          s1_lat <= {failure_total, failure_recent, success_after_repair, fem_feat};
          s2_lat <= {16'h0, key};
          s3_lat <= {ing_accepted, ing_done, rep_accepted, rep_done, cmp_done, rec_done,
                     fem_busy, t2_err, wr_outstanding};
          s4_lat <= {24'h0, op_u, 5'h0};
          ack_tog <= req_u1;
          pend <= 1'b0;
          ust <= U_IDLE;
        end
        default: ust <= U_IDLE;
      endcase
    end
  end
endmodule
