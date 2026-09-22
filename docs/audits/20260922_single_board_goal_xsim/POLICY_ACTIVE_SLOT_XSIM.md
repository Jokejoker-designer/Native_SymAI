# POLICY_ACTIVE_SLOT_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: POLICY_ACTIVE_SLOT_XSIM_CANDIDATE=SUPPORTED
BOARD_BUILT=NO
ASTRA_PASS=NO
MIG_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/policy_active_slot_r1/xsim/policy_active_slot_r1_xsim.log`
SHA256: `a1fba9dbe37baaa8e9aff9429e98f0760638a25ee3c07c03460fc6ae37c7a162`
Finish: 11905 ns

Module: `policy_active_slot_r1.sv`
SHA256: `3f875352ba029f50f54a406bf82ae3698242b3d559571076e4c5b0ad2407918a`

xvlog lists one `qstar_select.v`. It does not list `pack_vis_runtime.sv`, `spear_rank.v`, `fetch_only_r1.sv`, or `uart_rx_word.sv`. `single_policy_r1.sv` and `fetch_active_r1.sv` were not edited. `fetch_active_r1` is instantiated.

## What the log shows

The query generation stays `0x00AB`. Magic is `0x4E52`. Status is `0x04` when a descriptor is present and `0x02` when it is not. Status `0x01` is not emitted.

- No commit: no evidence, `command_valid=0`.
- Generation 1, slot 0: ref `025bb7b4`, evidence generation 1, command `C001` primitive 0. A later proposal stays 0.
- Generation 2, slot 1: ref `f2a071fe`, evidence generation 2, 24 writes, command `C002` primitive 1. A later proposal stays 1.
- Stale generation 1: reason `0x0E`, root stays 2, write count stays 24, the query still returns the generation-2 ref, and the proposal stays 1.

`command_generation` stays `16'h0007`, the action-tail constant. It is not the pack generation.

FEATURE_MAP_SUBSTITUTE=YES. THETA_SUBSTITUTE=YES. Theta address 0 weights feature 0 toward action 0. Theta address 10 weights feature 2 toward action 1.

## Self-audit

This identity has no UART sample and no FEM ingress. An observed effect that changes a later decision is still the earlier single-policy identity, and that identity still reads window 0 only. This log does not close that join.
