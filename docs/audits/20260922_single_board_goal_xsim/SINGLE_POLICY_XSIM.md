# SINGLE_POLICY_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: SINGLE_POLICY_XSIM_CANDIDATE=SUPPORTED
QSTAR_INSTANCES=1
ANSWER_EMITTED=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/single_policy_r1/xsim/single_policy_r1_xsim.log`
SHA256: `8ed8c0ab8c222d304b154ac523e14b5c84634a454c03c35bfec4f3da05cf6542`
Finish: 730075 ns

The xvlog list does not include `pack_vis_runtime.sv` or `spear_rank.v`. It includes `qstar_select.v` once. `fetch_only_r1` is pack commit plus a 12-word read.

## What the log shows

- No commit: status `0x02`, evidence ref 0.
- Commit generation 1: ack, 12 writes, root 1.
- Query generation `0x00AB`, evidence generation 1, ref `025bb7b4`, status `0x04`.
- Command `C001` primitive 0, equal to that proposal.
- UART byte `0x00`: `fem_feat` stays 0, later proposal stays 0.
- UART byte `0x0A`: nibble `A`, accepted, `fem_feat` 1, later proposal 1.

## Self-audit

The first run of this fetch stalled at 12 writes with no ack because reads were not answered. The passing log is the run after read replies were added. Twelve writes is the same count the earlier G1 commit used.

`QSTAR_INSTANCES=1` is a testbench label. The supporting fact is the file list: one `qstar_select` and no `pack_vis_runtime`.

This is still simulation. `uart_rx` has no semantic role. Status `0x01` is not emitted. `t2_ready` is tied 1. The product goal is not closed.
