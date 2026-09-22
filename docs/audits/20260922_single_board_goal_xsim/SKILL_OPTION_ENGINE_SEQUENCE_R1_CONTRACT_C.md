# SKILL_OPTION_ENGINE_SEQUENCE_R1 — C contract return

LANGUAGE=EN
STATUS: CONTRACT_RETURN_REV2
RTL: NOT_WRITTEN
MODULE_NAMESPACE_LOCKED=NO
INTERFACE_CONTRACT_LOCKED=NO
TIMING_CONTRACT_LOCKED=NO

REV2 locks two items that REV1 left open: STEP_WORD_R1 bit fields, and the
cycle rules for start-status, skill_done, and skill_fail.
REV3 accepts D's fetch and tail-feedback timing. The three lock flags are
still not set by C.

90220cb5 was not rerun. 12878be8 was not reprogrammed.
qstar_select.v, spear_rank.v, fem_lifecycle.v, astra_action_precheck_v1.sv,
action_product_r1.sv, and pack_abi24_gold.py were not edited.

```text
INTERFACE_CONTRACT_ACCEPT = YES
FUTURE_SUBSKILL_COMPATIBLE = YES
R1_SEQUENCE_ONLY = YES
```

No incompatible field. The gaps below stay labeled. They are not a second ABI
and they do not alias a 3-bit primitive to a skill_id.

## C_MODULE_NAME_PROPOSAL

```text
skill_option_engine_r1
skill_step_decode_r1
```

No existing Canon module owns these names. D's later module
`skill_option_integration_r1` is not created in this return.

## C_FILE_NAME_PROPOSAL

```text
D:/FPGA/arty_d/UART_R2/skill_option_r1/skill_option_pkg_r1.sv
D:/FPGA/arty_d/UART_R2/skill_option_r1/skill_step_decode_r1.sv
D:/FPGA/arty_d/UART_R2/skill_option_r1/skill_option_engine_r1.sv
D:/FPGA/arty_d/UART_R2/skill_option_r1/tb_skill_option_engine_r1.sv
```

## C_PORT_CONTRACT

```text
clk
rst_n

skill_start_valid
skill_start_ready
skill_id[31:0]
skill_version[7:0]
txn_id[31:0]
generation[7:0]
skill_start_status_valid
skill_start_status_ready
skill_start_status[2:0]
  0 ACCEPT
  1 REJECT_DUP
  2 REJECT_RECORD
  3 BUSY

rec_req_valid / rec_req_ready
rec_req_ref[31:0]
rec_rsp_valid / rec_rsp_ready
rec_rsp_data[255:0]

seq_req_valid / seq_req_ready
seq_req_ref[31:0]
seq_req_index[7:0]
seq_rsp_valid / seq_rsp_ready
seq_rsp_word[31:0]

step_valid / step_ready
primitive_id[2:0]
step_id[7:0]
step_skill_id[31:0]
step_skill_version[7:0]
step_txn_id[31:0]
step_generation[7:0]

step_feedback_valid / step_feedback_ready
feedback_skill_id[31:0]
feedback_skill_version[7:0]
feedback_txn_id[31:0]
feedback_generation[7:0]
feedback_step_id[7:0]
feedback_result[2:0]

skill_done
skill_fail
skill_result_ready
```

`target_ref` and parameter payload stay tied off. No second command port.
`proposed_action` is not an input of this engine.

## C_RECORD_FIELDS_CONSUMED

SkillRecord 256 bits, §12.10 candidate, not a locked ABI.

```text
CONSUMED_R1
  W0 skill_id[31:0]
  W1 version[7:0], generation[7:0], status[2:0]
  W3 capability_class_mask[31:0]
  W4 max_steps[7:0]
  W5 policy_or_sequence_ref[31:0]
```

`status` is lifecycle state. R1 reads it and checks that it is one of the
§12.2 codes. It does not treat status as execution permission and it does not
emit ASTRA_DENY. `capability_class_mask` is transported and compared only as
the record field. It is not the tail primitive mask `8'h03`.

W1 `goal_class`, W2, W4 `parameters_ref`, W6, and the utility/CRC fields in
W4/W7 are not used as proof. Sequence body is not inside the 256-bit record.

STEP_WORD_R1, 32 bits, owned by `skill_step_decode_r1`. This is the R1 ABI.
An implementation must not infer another packing.

```text
[2:0]   primitive_id
[7:3]   reserved, must be 0
[15:8]  step_tag
[31:16] reserved, must be 0
```

`step_tag` is the opcode. The only R1 value is `8'h00`, name `STEP_TAG_PRIM`.
`primitive_id` is used only when `step_tag` is `STEP_TAG_PRIM`.

`step_id` on the step port is the engine counter, `0 .. max_steps-1`. It is
not `step_word[15:8]` and it is not `step_word[7:3]`.

A word is illegal when any reserved field is nonzero or `step_tag` is not
`8'h00`. R1 then raises `skill_fail` under the result-hold rule below. It
does not emit `step_valid` for that word and it does not recurse. A later
sub-skill, if ever added, must be a new `step_tag` value. R1 does not define
or execute any other tag. `[31:16]` is not a tag.

## C_CLOCK_RESET_CONTRACT

```text
clk
period 10.000 ns
one domain
no CDC
rst_n active-low
synchronous to posedge clk
same form as qstar_select: always @(posedge clk) if (!rst_n)
```

Not the asynchronous reset used by pack_loader. Not locked until D sets
TIMING_CONTRACT_LOCKED.

## C_HANDSHAKE_CONTRACT

Start, step, record response, sequence response, and feedback hold their
payload while valid && !ready. One transfer per posedge where both are 1.
No combinational ready-depends-on-valid loop. Every status and result output
below is registered. None of them is a one-cycle pulse.

`skill_start_ready` is 1 only while idle. The capture edge is the posedge
where `skill_start_valid` and `skill_start_ready` are both 1. That edge
samples the start payload. It is not ACCEPT.

`skill_start_status` is meaningful only while `skill_start_status_valid` is 1.
That valid rises on the posedge after the outcome is known, then holds until
a posedge where `skill_start_status_ready` is also 1. It falls on the next
posedge. Outcomes:

```text
REJECT_DUP   start_valid while not ready, and txn_id is the active txn
BUSY         start_valid while not ready, and txn_id is not the active txn
REJECT_RECORD record response accepted and the record check fails
ACCEPT       record response accepted and the record check passes
```

The outcome is known on that event's posedge. `skill_start_status_valid`
is 1 from the following posedge, not on the event edge and not in the same
combinational cone as `skill_start_valid`. A duplicate is not captured.
`REJECT_DUP` and `BUSY` do not change the active skill. `REJECT_RECORD` does
not raise `skill_done` or `skill_fail`. After that status is acknowledged the
engine is idle again.

No `step_valid` until a posedge has seen `skill_start_status_valid`,
`skill_start_status_ready`, and `skill_start_status == ACCEPT`. A sequence
word may be fetched earlier. It stays internal until that acknowledge.

`skill_done` and `skill_fail` are levels. They are never both 1. The chosen
one rises on the posedge after the terminating condition and holds until a
posedge where `skill_result_ready` is 1. Both fall on the next posedge, and
only then may `skill_start_ready` become 1. While either result is 1,
`step_valid` is 0 and `skill_start_ready` is 0. Missing `skill_result_ready`
leaves the result high. It is not a pulse.

The current action tail has no `step_ready`. That remains D's later adapter.
This unit does not instantiate that tail.

## C_LATENCY_CONTRACT

```text
DECODE                 FIXED_LATENCY 1 cycle
RESET_TO_IDLE          FIXED_LATENCY 1 cycle
FEEDBACK_SAMPLE        FIXED_LATENCY 1 cycle when valid and ready and identity matches
TERMINATE              FIXED_LATENCY 1 cycle from the terminating condition to skill_done or skill_fail rising
RESULT_HOLD            level, not a latency; waits for skill_result_ready
RECORD_FETCH           BOUNDED_VARIABLE_LATENCY  one outstanding req
SEQUENCE_WORD_FETCH    BOUNDED_VARIABLE_LATENCY  one outstanding req, one word per step
START_TO_FIRST_STEP    BOUNDED_VARIABLE_LATENCY
STEP_TO_NEXT_STEP      BOUNDED_VARIABLE_LATENCY  no next step without matching feedback
```

There is no global fixed cycle count. Storage latency is not claimed.

## C_FEEDBACK_CONTRACT

```text
0 SUCCESS
1 FAILURE
2 VETOED
3 NO_BINDING
4 ABORTED
5 TIMEOUT
```

These codes are not collapsed. Advance requires a match on skill_id,
skill_version, txn_id, generation, and step_id. Any other result terminates
FAIL and does not present another step.

`EXECUTION_FEEDBACK = SYNTHETIC_R1_SUBSTITUTE`. The testbench supplies it.
`command_valid` is not SUCCESS and is not ObservedEffect.

## C_TERMINATION_CONTRACT

SUCCESS only when the accepted step count reaches `max_steps` and the
matching feedback for the last step is SUCCESS. `max_steps == 0` is
`REJECT_RECORD` at start.

FAILURE, VETOED, NO_BINDING, ABORTED, and TIMEOUT terminate FAIL. No invented
recovery and no next primitive. A record id, version, or generation mismatch
is `REJECT_RECORD` and does not start the sequence.

## C_ABORT_ERROR_CONTRACT

Abort is feedback result ABORTED with matching identity. TIMEOUT is the same
class. There is no sideband abort pin in R1. An unmatched feedback is ignored
and does not advance. An illegal STEP_WORD_R1 terminates FAIL under the
result-hold rule. Reserved bits and a `step_tag` other than `8'h00` are
both illegal. `[31:16]` is reserved, not a tag.

## C_IDENTITY_PROPAGATION_CONTRACT

```text
R1_EXPERIMENTAL_SKILL_IDENTITY_ABI
skill generation is 8 bits
txn_id is 32 bits and is experimental
```

The engine does not drive `intent_generation` or `command_generation`. Those
tail ports stay the constant `16'h0007` inside the frozen tail. This contract
does not alias the 8-bit skill generation to that constant. `q_policy_version`
stays on Q* and is not an engine port.

## C_INTEGRATION_RISKS

Q* `proposed_action[2:0]` remains a primitive index. R1 does not start from it.
The later adapter must present `primitive_id` to the existing
`decision_done` / `proposed_action` pulse. It must not copy this sequencer.
Primitive 2 still misses the current capability mask `8'h03`. That miss is a
tail fact, not a reason to narrow this port below 3 bits.
A second `decision_done` overwrites the tail registers. The adapter has to
respect that. This unit does not.

## C_CONTRADICTIONS_WITH_CANON

No contradiction with the order Skill → ActionIntent → ASTRA → binding →
PrimitiveCommand. This unit stops before that tail.

Known gaps, not silent reinterpretations:

```text
Q* emits a 3-bit primitive, not a skill_id
the action tail is pulse-only
skill generation is 8 bits and the tail generation port is 16 bits
no ObservedEffect exists
SkillRecord 256 is a candidate layout
lifecycle status is not execution permission
```

## C_FETCH_AND_TAIL_FEEDBACK

```text
FETCH_AND_TAIL_FEEDBACK_ACCEPT = YES
```

Record fetch and sequence fetch are independent channels. A transfer is the
posedge where that channel's `req_valid` and `req_ready` are both 1. One
request is outstanding per channel. `rsp_valid` rises on a later posedge and
holds until `rsp_ready`. One channel cannot reorder. `req_ready` is 0 from
the accept posedge until the response accept posedge. The R1 storage
substitute may answer on the posedge after accept. The engine does not
require that 1-cycle delay and waits if the response is later.

The unit under this contract does not instantiate the action tail. The
adapter timing below is accepted for D's later integration only.

```text
S    step_valid && step_ready captures primitive_id
     this edge is not decision_done and is not SUCCESS
S+1  adapter presents the captured primitive_id on proposed_action
     and holds decision_done high for that one cycle
     only when no earlier decision_done is waiting for product_done
     the first step has no earlier one, so its step_ready is not blocked
S+2  action_product_r1 observes decision_done
     on that posedge it updates verdict, command_valid, and command_id
     and raises product_done
     those values are visible during the product_done cycle
     product_done falls at the next posedge
```

A second `decision_done` before that `product_done` is not issued.
`step_ready` stays 0 while one is outstanding. There is no queue.

`SYNTHETIC_R1_FEEDBACK_EVENT = TB_RESULT_AFTER_PRODUCT_DONE` applies to the
integration testbench, not to this unit. The earliest `step_feedback_valid`
for a tail-connected step is the cycle `product_done` is 1. A later cycle is
legal. `feedback_result` is the scripted arm value. `command_valid`,
`verdict`, and `command_id` do not select it. `command_valid = 1` is not
SUCCESS. `command_valid = 0` is not FAILURE.

## Locks

REV2 closes STEP_WORD_R1 and the start-status / done / fail cycle rules.
The message named a third pre-lock item and did not specify it, so that item
is not closed here.

C does not set the three lock flags. No RTL follows until D records all three
locks as YES.
