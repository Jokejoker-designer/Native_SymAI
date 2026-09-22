# SHARED_ACTIVE_GENERATION_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: SHARED_ACTIVE_GENERATION_XSIM_CANDIDATE=SUPPORTED
ANSWER_EMITTED=NO
ASTRA_PASS=NO
BOARD: NOT_BUILT

Log: `D:/FPGA/arty_d/UART_R2/shared_gen_r1/xsim/shared_generation_r1_xsim.log`
SHA256: `4f053828a806473ea74d56e9bddb8e4ce6f5f4ea7e1ea2b4c55db47625d95dd7`
Finish: 10085 ns

Wrapper: `shared_generation_r1.sv`
SHA256: `bea068a6f913169f7fbec34b4ef04478e0818c727c79c162bded1c70b8a61d90`

`pack_vis_runtime.sv` was instantiated and not edited. `90220cb5` was not rebuilt.

## What the log shows

QueryRecord generation is `0x00AB` on every arm.

- No commit: root unset, query status `0x02` UNKNOWN, evidence ref 0, no command.
- Commit G1: evidence ref `025bb7b4`, evidence generation 1, command primitive 0, verdict `B0`, query status `0x04` reason `0x20`.
- Commit G2: evidence ref `f2a071fe`, evidence generation 2, command primitive 1.
- Stale G1: root stays 2, evidence and command stay on G2.

## Self-audit

The query fields are a projection of the same descriptor registers the action lane already holds. They are not a second walker. That is enough to show the QueryRecord generation byte does not select the record, and that both reported identities move together when the commit moves.

It is not an ANSWER. Status `0x01` is not emitted. Proof is absent. `ASTRA_PASS` stays no.

Action verdict `B0` and query status `0x04` stayed different codes.
