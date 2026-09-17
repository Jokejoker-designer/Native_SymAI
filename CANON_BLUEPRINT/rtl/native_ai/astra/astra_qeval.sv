// astra_qeval.sv — §03.9 pre-search Q-eval (integrity / unsupported / budget=0).
// AGENT_D CANDIDATE. Not ASTRA_PASS. PROGRAM=NO. Does not import gold answers.
// Never emits ANSWER/UNKNOWN/CONFLICT. Hop-1 walk completeness is not established
// here; remaining queries stay SEARCH_INCOMPLETE 0x04/0x20 PARTIAL.
`timescale 1ns/1ps

module astra_qeval #(
  parameter logic [15:0] REV_LEGAL_REL = 16'd9,
  parameter logic [15:0] REL_UNSUPPORTED = 16'h3FFF
) (
  input  logic [7:0] q [0:31],
  input  logic       crc_fail,
  input  logic       magic_fail,
  output logic [7:0] status,
  output logic [7:0] reason,
  output logic [7:0] answer_kind,
  output logic [7:0] completeness,
  output logic [7:0] flags
);
  localparam logic [7:0] ST_SEARCH_INCOMPLETE = 8'h04;
  localparam logic [7:0] ST_UNSUPPORTED_QUERY = 8'h05;
  localparam logic [7:0] ST_DATA_INTEGRITY_FAIL = 8'h06;
  localparam logic [7:0] RC_BUDGET_EXHAUSTED = 8'h20;
  localparam logic [7:0] RC_OPERATOR_UNIMPLEMENTED = 8'h40;
  localparam logic [7:0] RC_DIRECTION_ILLEGAL = 8'h41;
  localparam logic [7:0] RC_INVALID_DESCRIPTOR = 8'h55;
  localparam logic [7:0] CMPL_NA = 8'h00;
  localparam logic [7:0] CMPL_PARTIAL = 8'h02;
  localparam logic [3:0] OP_UNSUPPORTED = 4'hF;
  localparam logic [1:0] DIR_REV = 2'h1;

  logic [3:0]  op_class;
  logic [1:0]  direction;
  logic [15:0] relation_id;
  logic [15:0] search_budget;

  always_comb begin
    op_class = q[13][7:4];
    direction = q[13][3:2];
    relation_id = {q[19], q[18]};
    search_budget = {q[29], q[28]};
    flags = 8'h00;
    answer_kind = 8'h00;
    if (crc_fail || magic_fail) begin
      status = ST_DATA_INTEGRITY_FAIL;
      reason = RC_INVALID_DESCRIPTOR;
      completeness = CMPL_NA;
    end else if ((op_class == OP_UNSUPPORTED) || (relation_id == REL_UNSUPPORTED)) begin
      status = ST_UNSUPPORTED_QUERY;
      reason = RC_OPERATOR_UNIMPLEMENTED;
      completeness = CMPL_NA;
    end else if ((direction == DIR_REV) && (relation_id != REV_LEGAL_REL)) begin
      status = ST_UNSUPPORTED_QUERY;
      reason = RC_DIRECTION_ILLEGAL;
      completeness = CMPL_NA;
    end else if (search_budget == 16'h0) begin
      status = ST_SEARCH_INCOMPLETE;
      reason = RC_BUDGET_EXHAUSTED;
      completeness = CMPL_PARTIAL;
    end else begin
      status = ST_SEARCH_INCOMPLETE;
      reason = RC_BUDGET_EXHAUSTED;
      completeness = CMPL_PARTIAL;
    end
  end
endmodule
