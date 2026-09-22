# ONE_QSTAR_THEN_EXPERIENCE_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: ONE_QSTAR_THEN_EXPERIENCE_XSIM_CANDIDATE=SUPPORTED
FEM_PERSIST_PASS=NO
MIG_PASS=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/one_qstar_r1/xsim/one_qstar_then_experience_r1_xsim.log`
SHA256: `0f4bc81cbf419fdb24f82536c19a2af304d7ea45b6eed66c8d2ae3d153aadf8d`
Finish: 8205 ns

Wrapper: `one_qstar_then_experience_r1.sv`
SHA256: `8e1466a4ece3fdf9bb5db59fbaf8ae34e6ca99e860dc296110c86a55346953bd`

## What the log shows

- Before a record, a proposal can occur and `decision_done` does not emit a command.
- Effect 3 before a command is not accepted.
- Generation 1, query generation `0x00AB`, evidence ref `025bb7b4`.
- The next `prop_done` of `u_q` is action 0 and becomes command `C001` primitive 0.
- Effect 3 after that command sets `fem_feat` to 1. The following `prop_done` of the same `u_q` is action 1.

## Self-audit

`pack_vis_runtime` still instantiates its own Q*. That instance is not connected to `action_product_r1`. The counted command and the later proposal are `u_q` only.

The first hot feature is feature 0 when the retrieved ref is not `f2a071fe`, and feature 1 after `fem_feat` is nonzero. That map is still a wrapper. The effect value is still the constant 3. `t2_ready` is tied 1. This is not a pin readback and not an ANSWER.
