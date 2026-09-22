# SKILL_STEP_TO_ACTION_TAIL_R1

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: SKILL_STEP_TO_ACTION_TAIL_XSIM_CANDIDATE=SUPPORTED
BOARD: NOT_BUILT
BITSTREAM: NONE

Log: `D:/FPGA/arty_d/UART_R2/skill_step_tail_r1/xsim/skill_step_to_action_tail_r1_xsim.log`
SHA256: `cb8616f28a292aafdc43530c0717eec65ba5cb258456d79a90f80d72100af24e`
Finish: 1005 ns

Adapter: `skill_option_integration_r1.sv`
SHA256: `b645e1f8ae0765182aae4f82c76e22f38df3d370460a54a24ebc51e8fb99c429`

Testbench: `tb_skill_step_to_action_tail_r1.sv`
SHA256: `0a93f6ae9be77344b4bd09f069abf3937314f66666cb52bea982edc2c19fd7a4`

## Causal cut

Skill engine `primitive_id` is captured when the step is accepted.
The next cycle presents that value as `proposed_action` with one `decision_done`.
The existing `action_product_r1` then emits or refuses a PrimitiveCommand.
`script_result` is an arm constant. `command_valid` does not select it.

## What the log shows

- Skill `0x20`, sequence ref `B000`: command primitive 1 then primitive 0, ids `C001` then `C002`, verdict `B0`. The first proposal is 1. `skill_id[2:0]` of `0x20` is 0.
- Skill `0x10`, first command valid, script `FAILURE`: one command, `skill_fail`, no second command.
- Safety blocked: `command_valid=0`, verdict `B2`, id 0, script `SUCCESS`, `skill_done`.
- Primitive 2 outside mask `8'h03`: verdict `B4`, `command_valid=0`, primitive echo 2, id 0, script `SUCCESS`, `skill_done`.

## Self-audit

The crossed arms are the audit. A mapper from `command_valid` to success would fail the second arm. A mapper from `command_valid=0` to failure would fail the third and fourth arms. A cast from `skill_id[2:0]` to `proposed_action` would fail the first arm.

`command_generation` stayed `16'h0007`. Skill generation in the record is `8'h03`. Those fields were not aliased.

`origin` stayed `8'h01`. That is the frozen tail constant. This batch does not claim the origin field names the skill.

Q* does not start the skill. The testbench does. Record storage is still the testbench substitute. Feedback is still `EXECUTION_FEEDBACK=SYNTHETIC_R1_SUBSTITUTE`. A PrimitiveCommand is not an ObservedEffect.

`skill_option_engine_r1`, `action_product_r1`, and `astra_action_precheck_v1` were instantiated and not edited. Frozen bits `90220cb5`, `44546b43`, and `435bdc88` were not rebuilt.

## Board

XSIM_ONLY. Both sides of the join already had their own evidence. This run adds no pin, memory, or timing fact that silicon would answer. A bitstream of a scripted result is not worth building.

## Ceilings

SKILL_ENGINE_PASS=NO
CHAIN_OF_ACTIONS_PASS=NO
ASTRA_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
PACK_ABI_24_24_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO

RERUN of this log is not required. Do not edit the adapter to absorb a later effect model. A later effect boundary is a new candidate that instantiates this adapter.
