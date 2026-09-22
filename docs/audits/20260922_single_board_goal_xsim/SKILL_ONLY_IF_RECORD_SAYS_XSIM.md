# SKILL_ONLY_IF_RECORD_SAYS_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: SKILL_ONLY_IF_RECORD_SAYS_XSIM_CANDIDATE=SUPPORTED
SKILL_ENGINE_PASS=NO
BOARD: NOT_BUILT

Log: `D:/FPGA/arty_d/UART_R2/skill_select_r1/xsim/skill_select_from_record_r1_xsim.log`
SHA256: `41035b832d1a3d8119d7dad7ab74f4631f7c8d422f5449c68b43ca03080f011b`
Finish: 645 ns

Selector: `skill_select_from_record_r1.sv`
SHA256: `e6c43c5ce4e1116dbb17dcb3c15e1dd09a41eea66ac32cf7f0a4ec67bcf3c417`

Adapter `skill_option_integration_r1.sv` remains `b645e1f8ae0765182aae4f82c76e22f38df3d370460a54a24ebc51e8fb99c429`.

## What the log shows

- Record skill `0x20`, proposal 7: steps are primitive 1 then 0. The proposal is not the skill id and not the first primitive.
- Record skill `0x10`, proposal 0: steps are primitive 0 then 1. The skill id stays `0x10`.
- Record with max_steps 0, proposal 1: no step.

Feedback is still `SYNTHETIC_R1_SUBSTITUTE`. Generation in the record is `8'h03`, not the tail constant `16'h0007`. This selector does not drive the action tail.

## Self-audit

The sequence body is still chosen in the testbench by `sequence_ref`, not by `case(skill_id)` in the selector. The records themselves are testbench inputs, not a pack commit. The new fact is only the start id and the decision to start.

A first primitive of 0 while the proposal is also 0 would not, alone, reject a cast. The proposal-7 arm is the one that does.
