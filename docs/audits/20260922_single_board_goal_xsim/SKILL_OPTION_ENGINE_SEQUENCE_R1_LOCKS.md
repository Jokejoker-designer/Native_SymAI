# SKILL_OPTION_ENGINE_SEQUENCE_R1 — locks

LANGUAGE=EN
STATUS: UNIT_LOCKED_AND_XSIM_RECORDED
DATE: 2026-09-22
RTL: C_UNIT_PRESENT
TAIL_ADAPTER: NOT_STARTED

C returned `FETCH_AND_TAIL_FEEDBACK_ACCEPT=YES` with no line to remove. D records the locks. C did not set them.

```text
MODULE_NAMESPACE_LOCKED = YES
INTERFACE_CONTRACT_LOCKED = YES
TIMING_CONTRACT_LOCKED = YES
REV2_STEP_WORD = WRITTEN
REV2_STATUS_HANDSHAKE = WRITTEN
REV2_FETCH_AND_TAIL_FEEDBACK = ACCEPTED
```

`TIMING_CONTRACT_LOCKED` is the unit plus the written tail-adapter timing. The adapter RTL is not built. `command_valid` does not select `feedback_result`.

```text
SKILL_SEQUENCE_XSIM_CANDIDATE = SUPPORTED
LOG = D:/FPGA/arty_d/UART_R2/skill_option_r1/xsim/skill_sequence_r1_xsim.log
SHA256 = 2f86fc500cf84389b861dfb9543b754d63852c07868d9891a2059509fcf1ec86
FINISH = 1305 ns
SCOPE = unit only
SKILL_SEQUENCE_TO_PRIMITIVE_COMMAND = NOT_RUN
BITSTREAM = NO
```

Arms in that log:

```text
A  two-step SUCCESS, result held until skill_result_ready
B  duplicate txn REJECT_DUP, step did not advance
C  illegal step_tag FAIL, no step_valid
D  FAILURE feedback terminates, no further primitive
E  record mismatch REJECT_RECORD, no done, no fail, no step
F  response delay of 3 cycles still completes
```

Not in this log: a second skill whose sequence is primitive 1 then primitive 0. The engine reads the step word from the sequence response. This log does not by itself show two different stored orders. That falsifier remains open. It is not a contradiction of the arms above.

`90220cb5` was not modified and was not rerun. `12878be8` stays `INVALID_HARNESS_RUN`.

`90220cb5` was not modified and was not rerun. `12878be8` stays `INVALID_HARNESS_RUN`.

## Locked names

```text
skill_option_pkg_r1.sv
skill_step_decode_r1.sv
skill_option_engine_r1.sv
tb_skill_option_engine_r1.sv
```

Modules: `skill_option_engine_r1`, `skill_step_decode_r1`.
Directory: `D:/FPGA/arty_d/UART_R2/skill_option_r1/`.
D's later adapter, not part of C's unit: `skill_option_integration_r1`.

No existing Canon module owns these names. No second name for the same Zone 4 engine.

## Locked clock and reset

```text
clk
period 10.000 ns
one domain
no CDC
rst_n active-low
synchronous to posedge clk
same form as qstar_select and action_product_r1
```

## Locked handshakes

Payload holds while `valid && !ready`. One accept on the cycle both are 1. No combinational ready/valid loop across a port. One active skill.

Start fields: `skill_id[31:0]`, `skill_version[7:0]`, `txn_id[31:0]`, `generation[7:0]`.
`skill_start_status`: `ACCEPT`, `REJECT_DUP`, `REJECT_RECORD`, `BUSY`.
`start_ready` is 0 when the start is not accepted.
Duplicate `txn_id` while busy is `REJECT_DUP` and does not advance.
A different transaction while busy is `BUSY` and does not accept.
`max_steps == 0` is `REJECT_RECORD`.

Record fetch and sequence fetch are separate req/rsp ports. One outstanding request on each.

```text
skill_rec_req_valid/ready
skill_rec_req_id[31:0]
skill_rec_rsp_valid/ready
skill_rec_rsp_data[255:0]
skill_rec_rsp_status

skill_seq_req_valid/ready
skill_seq_req_ref[31:0]
skill_seq_req_step[7:0]
skill_seq_rsp_valid/ready
skill_seq_rsp_data[31:0]
skill_seq_rsp_status
```

`skill_seq_req_ref` is `policy_or_sequence_ref`. `skill_seq_req_step` is the step index.

Step word, locked from C:

```text
[2:0]   primitive_id
[15:3]  reserved; R1 must not decode these as a sub-skill
[31:16] must be 0; nonzero terminates FAIL and is not expanded
```

Step outputs: `step_valid/ready`, `primitive_id[2:0]`, `step_id[7:0]`, and the same identity fields. `target_ref` is tied off. This unit has no command port.

Feedback: `step_feedback_valid/ready`, matching `skill_id`, `skill_version`, `txn_id`, `step_id`, and `feedback_result[2:0]`.

```text
0 SUCCESS
1 FAILURE
2 VETOED
3 NO_BINDING
4 ABORTED
5 TIMEOUT
```

These results are not collapsed. Unmatched feedback does not advance and does not change the wait. `EXECUTION_FEEDBACK = SYNTHETIC_R1_SUBSTITUTE`. `command_valid` is not success and is not ObservedEffect.

Completion ports stay separate:

```text
skill_done_valid/ready   SUCCESS completion only
skill_fail_valid/ready   every other termination
```

Both carry `txn_id`, `skill_id`, `skill_version`, and `last_step_id`. Fail also carries `fail_result[2:0]`.

## Locked latency

```text
FIXED_LATENCY 1 cycle:
  step-word decode
  reset to idle
  sample of a matching feedback beat
  terminate

BOUNDED_VARIABLE_LATENCY, one outstanding request:
  SkillRecord fetch
  sequence-word fetch
  start to first step
  step accept to next step
```

No next step without matching feedback. No global fixed cycle count. No `skill_done` before the final required feedback. `max_steps` cannot be exceeded. Fail cannot become success.

Success only when the accepted step count reaches `max_steps` and the last matching feedback is SUCCESS. Any other result terminates FAIL and presents no further primitive.

## Record

Canon SkillRecord, 256 bits, §12.10 candidate layout, not a locked ABI.
Consumed: W0 `skill_id`, W1 `version`, `generation`, `status`, W3 `capability_class_mask`, W4 `max_steps`, W5 `policy_or_sequence_ref`.
`status` is lifecycle state, not execution permission. R1 does not turn it into `ASTRA_DENY`.
`capability_class_mask` is not the tail primitive mask `8'h03`.
`R1_SEQUENCE_ONLY = YES`. `FUTURE_SUBSKILL_COMPATIBLE = YES` at the record and at bits `[31:16]` of the step word. No recursion.

## Identity

`R1_EXPERIMENTAL_SKILL_IDENTITY_ABI`.
Skill generation stays 8 bits. It is not aliased to the tail constant `16'h0007`.
`proposed_action[2:0]` stays a primitive index. It is not a `skill_id`.
This engine does not drive tail generation ports.

## Not locked

```text
skill_option_integration_r1
translation of step_valid into decision_done
translation of B0..B4 into feedback_result
any claim that command emission is an observed effect
board
MULTI_RECORD_PACK
GENERATED_MIG_WINDOW
```

The tail still has no ready and overwrites on a second `decision_done`. Primitive 2 still misses mask `8'h03`. Those facts bind the later adapter, not this unit.

C must not write the unit RTL while the three locks are NO.

## REV2 — two items written, third still open

### STEP_WORD_R1

```text
[2:0]   primitive_id
[7:3]   reserved = 0
[15:8]  step_tag
[31:16] reserved = 0
```

`step_tag` is the opcode. The only legal R1 value is `8'h00`, name `STEP_TAG_PRIM`. `primitive_id` is used only when the tag is that value. `step_id` on the step port is the engine counter, `0` through `max_steps-1`. It is not in the step word.

A reserved field that is not 0, or a `step_tag` other than `8'h00`, is an illegal word. The engine holds `skill_fail`, does not assert `step_valid`, and does not recurse. A later sub-skill must be a new `step_tag` value. `[31:16]` is not the tag.

### Start, done, and fail

Every status and result is a registered level, not a one-cycle pulse.

The capture edge of `skill_start` is the posedge where `skill_start_valid` and `skill_start_ready` are both 1. That edge takes the payload. It is not yet ACCEPT.

`skill_start_status_valid` rises on the next posedge after the result is known, then holds until a posedge where `skill_start_status_ready` is 1. It is not in the same cycle as `skill_start_valid`.

```text
REJECT_DUP     start_valid while not ready, same txn as the running skill
BUSY           start_valid while not ready, different txn
REJECT_RECORD  record received and the check failed
ACCEPT         record received and the check passed
```

`REJECT_DUP` and `BUSY` do not touch the running skill. `REJECT_RECORD` does not raise done or fail. There is no `step_valid` before ACCEPT has been acknowledged.

`skill_done` and `skill_fail` are mutually exclusive. The selected one rises on the posedge after the termination condition and holds until a posedge where `skill_result_ready` is 1. Both fall on the following posedge. While either is 1, `step_valid` and `skill_start_ready` are 0. If `skill_result_ready` is absent, the result stays. The pulse is not lost.

### Closed — fetch and tail feedback

C returned `FETCH_AND_TAIL_FEEDBACK_ACCEPT=YES`. No line removed. D records that accept. The timing text in the previous section stands, including:

```text
SYNTHETIC_R1_FEEDBACK_EVENT = TB_RESULT_AFTER_PRODUCT_DONE
command_valid does not select feedback_result
```

The unit XSim does not instantiate the tail. Delay of 3 cycles is in arm F.

```text
RECORD_FETCH
  accept = skill_rec_req_valid && skill_rec_req_ready at a posedge
  one outstanding request
  skill_rec_rsp_valid rises on a later posedge, not on the accept edge
  rsp payload holds until skill_rec_rsp_ready
  D's R1 storage substitute uses exactly 1 cycle: rsp_valid is 1 on the
  posedge after accept
  the engine must still tolerate a longer delay
  a second record request is not accepted until the first response is accepted
  responses on this channel cannot reorder

SEQUENCE_FETCH
  same rule, independent channel
  accept = skill_seq_req_valid && skill_seq_req_ready
  one outstanding
  skill_seq_rsp_valid rises on a later posedge and holds until ready
  D's R1 substitute: exactly 1 cycle after accept
  engine: longer delay allowed
  no reorder on this channel

STEP INTO THE EXISTING TAIL
  The unit under C does not contain this tail.
  The later adapter, and only that adapter, does the following.
  posedge S: step_valid && step_ready. Adapter captures primitive_id.
  That edge is not decision_done and is not SUCCESS.
  posedge S+1: adapter drives proposed_action = captured primitive_id
               and holds decision_done high for that one cycle only.
               It does not do this if the previous product_done has not
               been observed. step_ready stays 0 in that case.
  action_product_r1 samples decision_done on a posedge.
  product_done is high for the following cycle only.
  verdict, command_valid, and command_id update on that same sample
  and are visible during the product_done cycle.
  A second decision_done overwrites those registers. There is no queue.
  ASTRA and the capability lookup are combinational into that register.

SYNTHETIC_R1_FEEDBACK_EVENT
  name: TB_RESULT_AFTER_PRODUCT_DONE
  earliest cycle the adapter may present step_feedback_valid:
    the cycle in which product_done is 1 for this step's decision_done
  feedback_result: the scripted arm value
    SUCCESS, FAILURE, VETOED, NO_BINDING, ABORTED, or TIMEOUT
  command_valid does not select that value
  verdict does not select that value
  command_id does not select that value
  command_valid = 1 is not SUCCESS
  command_valid = 0 is not FAILURE
```

C closes this item by returning `FETCH_AND_TAIL_FEEDBACK_ACCEPT = YES` or by naming the incompatible line. Until that line exists, the three locks stay NO and no engine RTL is written.

That return is now YES. The three locks above are D's record of it.
