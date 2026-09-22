# EXPERIENCE_CHANGES_NEXT_DECISION_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: EXPERIENCE_CHANGES_NEXT_DECISION_XSIM_CANDIDATE=SUPPORTED
FEM_PERSIST_PASS=NO
BOARD_BUILT=NO
PROGRAM=NO

Log: `D:/FPGA/arty_d/UART_R2/experience_next_r1/xsim/experience_next_r1_xsim.log`
SHA256: `e3f45e077900eb7cde395a26e2e0322dea8c51d3baffe2e30fe43cea8221c26d`
Finish: 4415 ns

Wrapper: `experience_next_r1.sv`
SHA256: `7aa50daf9c736e37ccc721f9ced015df2557e6a4dbb0d6ac3d2e969951ef700d`

`fem_lifecycle.v` and `qstar_select.v` were instantiated and not edited. Bit `1db38691` was not rebuilt.

## What the log shows

Same theta and legal mask. `command_valid` stays 1.

- Before ingress: `fem_feat` 0, proposal 0.
- Ingress effect 3 accepted: `fem_feat` 1, next proposal 1.
- A later proposal with no new ingress stays 1.

## Self-audit

`t2_ready` is tied 1. That is the local sync model named on the FEM port, not DDR and not `mig0`.

`fem_feat` is `failure_total`. The wrapper turns a zero count into Q1.7 feature 0 and any other count into feature 1. FEM does not choose the action. Q* does, from that feature and the testbench theta. Q1.7 value `8'h40` is used because `8'h80` is negative and inverts the winner. An earlier log that used `8'h80` failed and was replaced by this run.

The effect code is part of the FEM key. This run does not show a success observation clearing the count. The command bit is not an ingress field. It was high both before and after the proposal changed, so it is not what moved the proposal.

This cut is not on the pack generation path. It does not close the product loop.
