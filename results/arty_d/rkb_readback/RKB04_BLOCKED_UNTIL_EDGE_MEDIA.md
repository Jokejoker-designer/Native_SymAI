# RKB-04 — Edge dereference necessity

LANGUAGE=EN
DATE: 2026-09-21T12:13+07
OWNER: AGENT_D
PROGRAM: NO

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not `PACK_ABI_24_24_PASS`.

## XSim 20260921T051355Z

Isolated `pack_edge_dut` + `dest_posting_edge_walk` (not `posting_walk` `$readmemh`).

```text
RKB-04 = PASS_XSIM 3895 ns
```

Before: hit=1 nb=`00020100` dest_rd=5.
After zero dest[5] and dest[6] only: hit=0 dest_rd=4.
Posting dest[4] still `edge_ref=80` neighbor B. Directory dest[2] unchanged.

JSON sha256 `916a9d90d70d11ccda488a5303a94e6fe19357300ef8fd129cc4e0608d8377c5`.
Log sha256 `6ee9e680abcc5a3f7b0d3d838068d2e8fdcf12ede8968e8c0795e4decdaeb963`.

UART = NOT_RUN (board unplugged). Next = RKB-06 after RKB-05 PASS_XSIM. Do not stamp 8/8.
