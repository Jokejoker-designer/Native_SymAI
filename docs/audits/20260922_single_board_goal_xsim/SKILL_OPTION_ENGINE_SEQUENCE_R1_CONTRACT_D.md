# SKILL_OPTION_ENGINE_SEQUENCE_R1 — D interface proposal

LANGUAGE=EN
STATUS: PROPOSAL_ONLY
RTL: NOT_STARTED
MODULE_NAMESPACE_LOCKED=NO
INTERFACE_CONTRACT_LOCKED=NO
TIMING_CONTRACT_LOCKED=NO

Frozen baseline stays outside this branch:

```text
90220cb5 PACK_GENERATION_VISIBILITY_BOARD_CANDIDATE=SUPPORTED
RERUN=NO
12878be8 INVALID_HARNESS_RUN REPROGRAM=NO
MULTI_RECORD_PACK and GENERATED_MIG_WINDOW remain unopened here
```

Ceilings stay NO: PROGRAM_PASS BOARD_PASS TIMING_PASS MIG_PASS PACK_ABI_24_24_PASS ASTRA_PASS.
No SKILL_ENGINE_PASS. No CHAIN_OF_ACTIONS_PASS.

Canon authority used: live `12_SKILL_AND_TEACHING.md` §12.1, §12.8, §12.10 (256-bit SkillRecord is LEARNING_LOCAL_LAYOUT_CANDIDATE, not a locked ABI). No `skill_*` RTL module exists.

Chain of Actions is the behavior. The Canon subsystem name is Skill / Option Engine. One generic engine. No `case(skill_id)` sequence.

---

## 23. D answers

```text
CANON_SKILL_INSERTION_POINT:
  Skill step becomes an ACTION_INTENT.
  Then the existing action tail: ASTRA precheck → capability lookup → PrimitiveCommand.
  The engine does not drive actuators and does not bypass that tail.
  R1 unit XSim does not instantiate the tail. D adds the adapter only after C's XSim.

CURRENT_QSTAR_OUTPUT:
  qstar_select.v
  prop_start          input pulse, 1 bit
  prop_done           1-cycle pulse
  prop_valid          1 bit
  prop_refused        1 bit; a second prop_start while one proposal is pending is refused
  proposed_action     [2:0]   PRODUCT FIELD as a primitive index, NOT a skill_id
  greedy_action       [2:0]   PRODUCT FIELD
  explored            1
  no_legal            1
  q_sel               [31:0]  EXPERIMENTAL / debug
  q_sat               1       EXPERIMENTAL
  q_policy_version    [15:0]  exists on Q*; NOT wired into action_product_r1
  skill_ref           NOT IMPLEMENTED
  macro_action        NOT IMPLEMENTED
  sequence_ref        NOT IMPLEMENTED
  Do not cast proposed_action into skill_id.

CURRENT_ACTIONINTENT_INPUT:
  action_product_r1 consumes only:
    decision_done     1-cycle pulse, no ready
    proposed_action   [2:0]
    safety_ok         1; test control
  It emits, same cycle the pulse is seen, product_done as a 1-cycle pulse.
  There is no valid/ready and no backpressure.

PROPOSED_C_MODULES:
  skill_option_engine_r1
  skill_step_decode_r1
  Files: skill_option_pkg_r1.sv, skill_option_engine_r1.sv,
         skill_step_decode_r1.sv, tb_skill_option_engine_r1.sv
  PROPOSED, not locked. C may reject a name only if an existing Canon module owns it.
  No skill_* module exists today.

PROPOSED_D_INTEGRATION_MODULE:
  skill_option_integration_r1
  instance u_skill_option_integration_r1
  Created by D only after the three locks. It adapts pulses and must not copy C's sequencer.

CLOCK_DOMAIN:
  One clock. RTL port name clk.
  Board pin CLK100MHZ, xdc clock sys_clk_pin.
  Frequency 100 MHz. Period 10.000 ns.
  No second domain. No CDC in R1.

TARGET_CLOCK_PERIOD:
  10.000 ns.

RESET_CONTRACT:
  Port rst_n. Active-low.
  qstar_select and action_product_r1 reset synchronously: always @(posedge clk) if (!rst_n).
  pack_loader uses asynchronous negedge rst_n. The skill engine sits on the action-tail side,
  so D proposes synchronous active-low rst_n, same as qstar_select and action_product_r1.
  Board pin ck_rst is wired directly to rst_n.
  C confirms or states an incompatibility. Not locked.

PROPOSED_START_HANDSHAKE:
  skill_start_valid / skill_start_ready
  Payload stable while valid && !ready.
  Accept on the cycle both are 1. One accept per such cycle.
  No combinational ready↔valid loop across the port.
  R1: one active skill. start_ready is 0 while busy.
  Duplicate txn_id while busy: do not accept, do not advance. Status REJECT.
  Fields: skill_id[31:0], skill_version[7:0], txn_id[31:0], generation[7:0].

PROPOSED_STEP_HANDSHAKE:
  step_valid / step_ready
  Payload stable while valid && !ready.
  primitive_id[2:0] must match the current PrimitiveCommand width.
  Also step_id[7:0], skill_id[31:0], skill_version[7:0], txn_id[31:0], generation[7:0].
  target_ref and parameter payload: DEFERRED in R1. Tie unused. Do not invent a second command.
  The current tail has no step_ready. D's later adapter will pulse decision_done only after
  it has accepted step_valid, and will hold step_ready with the adapter's own rule.
  Command emission is not step SUCCESS.

PROPOSED_FEEDBACK_HANDSHAKE:
  step_feedback_valid
  No advance of the sequence unless feedback matches skill_id, skill_version, txn_id, and step_id.
  result[2:0] proposal, C may renumber but must not collapse these:
    0 SUCCESS
    1 FAILURE
    2 VETOED
    3 NO_BINDING
    4 ABORTED
    5 TIMEOUT
  EXECUTION_FEEDBACK = SYNTHETIC_R1_SUBSTITUTE
  The testbench supplies feedback. D will not map PrimitiveCommand.command_valid to SUCCESS.
  Downstream verdicts that can later be translated, still not an observed effect:
    B0 BOUND, B1 DENY, B2 SAFETY, B3 STALE, B4 NO_BINDING, final NO_ACTION 8'hFF.
  R1 failure policy: terminate FAIL. No autonomous recovery unless that edge is in the
  sequence record itself. ARM C must not execute the next primitive.

IDENTITY_FIELDS_AND_WIDTHS:
  R1_EXPERIMENTAL_SKILL_IDENTITY_ABI, not a final product ABI.
  skill_id            32   CONSUMED_R1   Canon SkillRecord W0
  skill_version        8   CONSUMED_R1   Canon W1[7:0]
  generation           8   CONSUMED_R1   Canon W1 generation
  txn_id              32   CONSUMED_R1   experimental; not on action_product_r1
  step_id              8   CONSUMED_R1   bounded by max_steps[7:0]
  intent_id           32   on the tail today; separate counter; not a skill field
  command_id          32   tail; 32'hC000 + n when BOUND, else 0
  binding_id          32   tail; 32'hB000 + n when BOUND, else 0
  intent_generation   16   tail; currently the constant 16'h0007, NOT live skill generation
  command_generation  16   same constant
  q_policy_version    16   on qstar_select only; NOT on the action tail; DEFERRED for R1
  session_id               NOT IMPLEMENTED
  episode_id               NOT IMPLEMENTED
  spear_policy_version     NOT IMPLEMENTED
  capability_manifest_version  NOT IMPLEMENTED
  corpus_epoch             NOT IMPLEMENTED
  Width conflict to resolve, not to hide: Canon skill generation is 8 bits.
  The frozen action tail generation port is 16 bits and is a constant.
  The adapter must show any extension. It must not alias skill generation to 16'h0007.

SKILL_RECORD_FIELDS_R1:
  Use SkillRecord, 256 bits / 8 words, §12.10 candidate layout. Do not invent a second type.
  CONSUMED_R1:
    W0 skill_id[31:0]
    W1 version[7:0], generation[7:0], status[2:0]
    W3 capability_class_mask[31:0]
    W4 max_steps[7:0]
    W5 policy_or_sequence_ref[31:0]
  TRANSPORTED_ONLY:
    W1 goal_class[7:0]
    W2 preconditions[15:0], provenance_ref[15:0]
    W4 parameters_ref[15:0]
    W6 termination_schema_ref[15:0], expected_effect_schema_ref[15:0]
  DEFERRED, still present in the record, utility-only, not proof:
    W4 cost_stats[7:0]
    W7 success_count[7:0], failure_count[7:0], crc16[15:0]
  Sequence body is not inside the 256-bit record. It is fetched through policy_or_sequence_ref.
  C owns step-word decode. D only requires the emitted primitive_id to be 3 bits.
  R1_SEQUENCE_ONLY. Nested DAG is not implemented. Record format must not forbid a later
  sub-skill ref. No recursion. No cycles.
  FUTURE_SUBSKILL_COMPATIBLE is C's answer; D's requirement is YES at the record level
  without implementing expansion.

ALLOWED_SUBSTITUTES:
  LEGAL_MASK_SUBSTITUTE            legal_mask 8'h03 on the current Q* path
  QSTAR_POLICY_SUBSTITUTE          theta[8]=1 and rank0->{0,2}; not a skill selector
  PRIMITIVE_FEATURE_MAP_SUBSTITUTE current map from rank to primitive 0 or 1
  SKILL_RECORD_STORAGE_SUBSTITUTE  test-provisioned SkillRecord and sequence words
  EXECUTION_FEEDBACK_SYNTHETIC_R1  TB feedback; not ObservedEffect
  ACTION_TAIL_SAFETY_TIED          intent_legal is tied 1 in action_product_r1
  ACTION_TAIL_GENERATION_CONSTANT  16'h0007
  CAPABILITY_ONE_ENTRY_SUBSTITUTE  one descriptor, mask 8'h03, id 32'h000000C1
  No unlabeled shortcut.

FROZEN_MODULES_NOT_TO_TOUCH:
  rtl/native_ai/strategy/qstar_select.v
  rtl/native_ai/strategy/spear_rank.v
  rtl/native_ai/memory/fem_lifecycle.v
  astra_action_precheck_v1.sv
  action_product_r1.sv
  bitstream and discriminator of 90220cb5
  12878be8
  pack_abi24_gold.py
  C implements the engine beside these. C does not edit them.

EXPECTED_C_XSIM_CLAIM:
  SKILL_SEQUENCE_XSIM_CANDIDATE=SUPPORTED
  only after arms A–E. Not a PASS stamp.

EXPECTED_LATER_INTEGRATION_CLAIM:
  SKILL_SEQUENCE_TO_PRIMITIVE_COMMAND_XSIM_CANDIDATE
  after D's adapter. Board is a separate decision.

CONTRADICTION_WITH_CANON:
  NO on the insertion order Skill → ActionIntent → ASTRA → binding → PrimitiveCommand.
  KNOWN_GAP, not a silent reinterpretation:
    Q* emits a 3-bit primitive, not a skill_id.
    Action tail has pulses, not ready/valid.
    Action tail generation is a 16-bit constant, not Canon skill generation[7:0].
    No ObservedEffect exists, so feedback is synthetic.
    SkillRecord 256 is a candidate layout, not a B-locked ABI.
```

## Downstream facts C must not rediscover

```text
ASTRA precheck is combinational. No backpressure.
Order inside astra_action_precheck_v1:
  stale → B3
  !intent_legal → B1
  !safety_ok → B2
  !capability_present → B4
  else B0 and final_action = {5'h0, proposed_action}
Capability lookup is combinational: stored CRC 16'h28AE and primitive_mask[prim].
Mask is 8'h03, so primitive 2 is a miss (B4) on the current tail.
PrimitiveCommand is registered when decision_done is seen and verdict is B0 and lookup hits.
Otherwise command_valid=0 and command_id=0. command_primitive still echoes the request.
That echo is not an issued command.
product_done is a 1-cycle pulse. A second decision_done overwrites the registers.
There is no queue.
```

## What C must not bypass

```text
Frozen downstream block: action_product_r1 plus astra_action_precheck_v1.
C may eventually cause a step to be presented to that block as a primitive.
C must not write command_valid, command_id, or an actuator.
C must not treat B0 or command_valid as effect verified.
```

## Build drop-in

```text
Directory: D:/FPGA/arty_d/UART_R2/skill_option_r1/
Simulator: Vivado xsim 2026.1
Compile: xvlog -sv, one line, no caret continuation
Order: skill_option_pkg_r1.sv, skill_step_decode_r1.sv, skill_option_engine_r1.sv, tb_skill_option_engine_r1.sv
Top: tb_skill_option_engine_r1
Log: D:/FPGA/arty_d/UART_R2/skill_option_r1/xsim/skill_sequence_r1_xsim.log
Hash: SHA256 of that log file
Timescale: 1ns/1ps
```

## C return required before any RTL

```text
C_MODULE_NAME_PROPOSAL
C_FILE_NAME_PROPOSAL
C_PORT_CONTRACT
C_RECORD_FIELDS_CONSUMED
C_CLOCK_RESET_CONTRACT
C_HANDSHAKE_CONTRACT
C_LATENCY_CONTRACT          FIXED_LATENCY or BOUNDED_VARIABLE_LATENCY per phase
C_FEEDBACK_CONTRACT
C_TERMINATION_CONTRACT
C_ABORT_ERROR_CONTRACT
C_IDENTITY_PROPAGATION_CONTRACT
C_INTEGRATION_RISKS
C_CONTRADICTIONS_WITH_CANON
INTERFACE_CONTRACT_ACCEPT = YES or NO
FUTURE_SUBSKILL_COMPATIBLE = YES or NO
R1_SEQUENCE_ONLY = YES
```

If ACCEPT is NO, list the incompatible fields. D does not start the adapter, and C does not write the engine, until:

```text
MODULE_NAMESPACE_LOCKED = YES
INTERFACE_CONTRACT_LOCKED = YES
TIMING_CONTRACT_LOCKED = YES
```
