# FETCH_ACTIVE_SLOT_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: FETCH_ACTIVE_SLOT_XSIM_CANDIDATE=SUPPORTED
BOARD_BUILT=NO
MIG_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/fetch_active_r1/xsim/fetch_active_r1_xsim.log`
SHA256: `b49b9f04467a56652c27b9d7d5a46fa7438a4dbcf953a8be1dc6a077a8fcd1c8`
Finish: 3165 ns

Module: `fetch_active_r1.sv`
SHA256: `df24ea79f9c840d841501ce5eef76b367a204f33f25a99e80fa945a6d396ea8d`

`fetch_only_r1.sv` was not edited. `single_policy_r1` still instantiates `fetch_only_r1`, so that identity still reads window 0 only.

## What the log shows

Query generation stays `0x00AB`.

- No commit: no descriptor.
- Generation 1: read slot 0, ref `025bb7b4`, directory generation 1, 12 writes.
- Generation 2: read slot 1, ref `f2a071fe`, directory generation 2, 24 writes.
- Stale resend of generation 1: reason `0x0E`, root stays 2, write count stays 24, the next query still returns the generation 2 ref from slot 1.

Slot 1 is `addr[20]`, the canonical base `0x00100000`, not bit 24.

## Self-audit

This fetch has no Q* and no UART sample. It closes the window hole. It does not by itself put that window into the single-policy chain.
