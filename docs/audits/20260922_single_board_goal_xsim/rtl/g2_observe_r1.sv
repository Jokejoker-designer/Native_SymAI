// g2_observe_r1.sv
// Generation 2's active window is the evidence and the command.
// A UART nibble is admitted only after that command, and only when it is
// neither the primitive nor the command_valid bit. FEM then changes the next proposal.
// Evidence ref stays the generation-2 record. One qstar_select.
// Does not edit policy_active_slot_r1, fetch_active_r1, fem_lifecycle, or qstar_select.
`timescale 1ns/1ps

module g2_observe_r1 (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        uart_rx,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic        loader_busy,
  output logic [15:0] write_count,
  output logic        read_slot,
  input  logic        q_valid,
  input  logic [7:0]  q_bytes [0:31],
  output logic        result_done,
  output logic [15:0] sr_magic,
  output logic [7:0]  sr_status,
  output logic [31:0] sr_evidence_ref,
  output logic [15:0] sr_evidence_gen,
  output logic [15:0] query_generation,
  output logic [7:0]  verdict,
  input  logic        prop_start,
  output logic        prop_done,
  output logic [2:0]  proposed_action,
  output logic        q_busy,
  input  logic        decision_done,
  output logic        command_valid,
  output logic [2:0]  command_primitive,
  output logic [31:0] command_id,
  output logic [15:0] command_generation,
  output logic        ing_accepted,
  output logic [7:0]  fem_feat,
  output logic [3:0]  sample_nibble,
  input  logic        theta_we,
  input  logic [5:0]  theta_addr,
  input  logic [15:0] theta_wdata
);
  logic        descriptor_valid;
  logic [31:0] evidence_ref;
  logic [15:0] dir_generation;
  logic [63:0] feat_flat;
  logic        w_valid;
  logic [31:0] w_data;
  logic        cap_arm, cap_valid;
  logic [3:0]  cap_value;
  wire [3:0]   echo = {1'b0, command_primitive};
  wire [3:0]   as_cmd = {3'b0, command_valid};
  wire         admit = cap_valid && command_valid && (cap_value != echo) && (cap_value != as_cmd);

  fetch_active_r1 u_fetch (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .loader_busy, .write_count,
    .q_valid, .q_bytes, .result_done, .descriptor_valid, .evidence_ref,
    .query_generation, .dir_generation, .read_slot
  );

  assign sr_magic = 16'h4E52;
  assign sr_status = descriptor_valid ? 8'h04 : 8'h02;
  assign sr_evidence_ref = evidence_ref;
  assign sr_evidence_gen = descriptor_valid ? dir_generation : 16'h0;
  // SUBSTITUTE. Generation 2 is feature 2. An accepted observation is feature 1.
  assign feat_flat = (!descriptor_valid) ? 64'h0
    : (fem_feat != 8'h00) ? 64'h0000_0000_0000_4000
    : (evidence_ref == 32'hf2a071fe) ? 64'h0000_0000_0040_0000
    : 64'h0000_0000_0000_0040;
  assign sample_nibble = cap_value;

  uart_rx_word u_uart (
    .clk, .rst_n, .rx(uart_rx),
    .w_valid, .w_ready(1'b1), .w_data,
    .flush(1'b0), .idle(), .rx_sync()
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      cap_arm <= 1'b0;
      cap_valid <= 1'b0;
      cap_value <= 4'h0;
    end else begin
      cap_valid <= 1'b0;
      if (w_valid) begin
        cap_value <= w_data[3:0];
        cap_arm <= 1'b1;
      end else if (cap_arm) begin
        cap_valid <= 1'b1;
        cap_arm <= 1'b0;
      end
    end
  end

  qstar_select u_q (
    .clk, .rst_n, .prop_start, .feat_flat,
    .legal_mask(8'h03), .exam(1'b1), .epsilon16(16'h0),
    .prop_done, .prop_valid(), .prop_refused(), .pending(),
    .proposed_action, .greedy_action(), .explored(), .no_legal(),
    .q_sel(), .q_sat(),
    .upd_start(1'b0), .exec_valid(1'b0), .exec_action(3'd0),
    .reward_accepted(1'b0), .reward16(16'h0), .qnext_max32(32'h0),
    .alpha8(8'h0), .gamma8(8'h0),
    .upd_done(), .upd_applied(), .upd_reason(), .delta_out(),
    .learn_reset(1'b0), .theta_we, .theta_addr, .theta_wdata, .theta_rdata(),
    .version_we(1'b0), .version_wdata(16'h0), .q_policy_version(),
    .lfsr_we(1'b0), .lfsr_wdata(16'h0), .lfsr_state(),
    .busy(q_busy), .explore_count(), .credit_denied_count(), .no_legal_count(),
    .illegal_exec_count(), .exam_blocked_count(), .illegal_selection_count(),
    .prop_refused_count()
  );

  action_product_r1 u_tail (
    .clk, .rst_n,
    .decision_done(decision_done && descriptor_valid),
    .proposed_action, .safety_ok(1'b1),
    .product_done(), .intent_id(), .origin(), .intent_primitive(), .intent_generation(),
    .lookup_hit(), .capability_id(), .instance_id(), .primitive_mask(),
    .descriptor_crc_ok(), .verdict, .binding_result(), .binding_id(),
    .command_valid, .command_id, .command_binding_id(), .command_primitive,
    .command_generation, .probe_hit(), .probe_verdict()
  );

  fem_lifecycle u_fem (
    .clk, .rst_n,
    .ing_valid(admit),
    .ing_domain(2'd0), .ing_stage(4'd0), .ing_cap(4'd0), .ing_macro(3'd0),
    .ing_prim(4'd0), .ing_effect(cap_value), .ing_ctx(3'd0),
    .ing_done(), .ing_accepted,
    .rep_valid(1'b0), .rep_skill_id(8'h0), .rep_skill_ver(8'h0),
    .rep_done(), .rep_accepted(),
    .cmp_start(1'b0), .cmp_done(), .cmp_result(), .txn_step(),
    .rec_start(1'b0), .rec_done(), .recover_state(), .integrity_fault(),
    .t2_we(), .t2_addr(), .t2_wdata(), .t2_ready(1'b1), .t2_rdata(32'h0),
    .busy(), .life_state(), .failure_total(), .failure_recent(),
    .success_after_repair(), .regression_count(), .unresolved(), .compacted(),
    .key(), .n_raw(), .ingress_rejected(), .key_mismatch(), .exemplar_full(),
    .fem_feat
  );
endmodule
