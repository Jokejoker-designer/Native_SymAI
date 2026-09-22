# PRIMITIVE_EXECUTOR_EFFECT_R1

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: PRIMITIVE_EXECUTOR_EFFECT_XSIM_CANDIDATE=SUPPORTED
BOARD: NOT_BUILT

This candidate instantiates `skill_option_integration_r1` unchanged.
Adapter SHA256 remains `b645e1f8ae0765182aae4f82c76e22f38df3d370460a54a24ebc51e8fb99c429`.

Log: `D:/FPGA/arty_d/UART_R2/skill_effect_r1/xsim/primitive_executor_r1_xsim.log`
SHA256: `30588990db1b2957933fee72a7b14ea5e2f47c3e024872067d2d3bc35f28800c`
Finish: 915 ns

Executor: `primitive_executor_r1.sv`
SHA256: `97009ac6bbe70e169a2855ce88246ef6269f20af66c8cc17d1b00aab7927d3db`

## Causal cut

`product_done` samples the PrimitiveCommand.
If `command_valid` is 1, the effect code is the 3-bit row of `effect_table` at that primitive.
If `command_valid` is 0, the effect code is `FB_NO_BINDING` and the table row is not used.
The skill engine receives that effect. It does not receive `command_valid`.

## What the log shows

- Table rows SUCCESS, SUCCESS. Skill `0x20` emits primitive 1 (`C001`, result 0) then primitive 0 (`C002`, result 0) and finishes.
- Table row for primitive 0 is FAILURE. The same skill still issues both commands with `valid=1`. The second observation is result 1. The skill fails.
- Safety blocks the command. The table row for primitive 0 is SUCCESS. The observation is `valid=0`, id 0, result 3 (`FB_NO_BINDING`). The skill fails. The success row was not consumed.

## Self-audit

The second arm is the proof that a valid command can be a failed observation.
The third arm is the proof that a success row cannot observe an act that was not commanded.
`command_valid=0` did not become `FB_FAILURE`. It became `FB_NO_BINDING`.

The refused-command path uses one code for every refusal. This run's refusal was safety (`B2` on the tail), and the effect code is still `FB_NO_BINDING`. The executor does not yet distinguish safety from a missing capability. That distinction is not claimed.

`effect_table` is a test memory. `EFFECT_TABLE_SUBSTITUTE=YES`. It is not a sensor and not FEM.

Q* still does not select the skill. The testbench does.

## Board

BOARD_NOT_WORTH_BUILDING. The effect is a table in the testbench. Silicon would replay that table.

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

Do not edit the skill-tail adapter or this executor to add skill selection. The next selector needs its own candidate, and it must not cast `proposed_action` to `skill_id`.
