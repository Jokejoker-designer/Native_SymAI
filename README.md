# Native_SymAI

Public snapshot of the Native AI developmental hardware project
(Digilent Arty A7-100T, xc7a100tcsg324-1).

This is a **new** repository. It does not fork, overwrite, or push to
QUAN-NATIVE-AI, native-ai-full-evidence, astra-native-ai-full-evidence,
or any other existing GitHub repo.

## Scope

| Path | Contents |
|---|---|
| `CANON_BLUEPRINT/` | Canon, AGENT_C + AGENT_D RTL, verification, Vivado Tcl, coordination |
| `agent_c_rtl/` | C-owned synthesizable RTL only (hash-locked) |
| `results/arty_d/` | AGENT_D evidence: bits, DCPs, UART/JSON, reports (no Vivado project cache) |

## AGENT_C RTL (SHA256)

- `qstar_select.v` `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240`
- `spear_rank.v` `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293`
- `fem_lifecycle.v` `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed`

Identical bytes also live under `CANON_BLUEPRINT/rtl/native_ai/`.

## Claim ceiling

Not BOARD_PASS, PROGRAM_PASS, PACK_ABI_24_24_PASS, TIMING_PASS, MIG_PASS,
ASTRA_PASS, FE256_PASS, or FINAL_PASS.

H_OBS (observe dump bit) is not identity H. Do not reverse-copy its classifier
onto `cf62102f…`.

FE256 R1 freeze DCPs are a reference implementation, not product architecture.

Xilinx MIG IP is not vendored. Rebuild `mig0` in Vivado if you need a bitstream.

## License

No license file is attached. Default copyright applies unless the owner adds one.
