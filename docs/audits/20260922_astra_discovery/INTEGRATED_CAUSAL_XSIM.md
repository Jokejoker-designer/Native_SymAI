# Integrated causal XSim

LANGUAGE=EN
RUN_ID: 20260922T012300Z
SIM: behavioral xsim only
BITSTREAM: NOT_BUILT

```text
INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED
```

This is one behavioral netlist. It is not a board candidate and not a product path.

## DUT

`D:/FPGA/arty_d/UART_R2/fem_spear_qstar_astra/chain_fem_spear_qstar_astra.sv`
sha256 `39044d771f8d2332a2a929639a1aa56327a69e0bfdc06d142ecbc98f1af6dd29`

TB sha256 `82c445e1e9dafd222e923382c0e82d66a728ef9894e811a35bbb71512b0c2ef5`

Log `D:/FPGA/arty_d/UART_R2/fem_spear_qstar_astra/xsim/chain_xsim.log`
sha256 `e112783e8c350633bb8111e13462e894746bc55091cdf6fb895eac52e59ed0ea`
Finish 18555 ns. nfail 0.

C RTL hashes unchanged: `fem_lifecycle.v` `45b9b930…`, `spear_rank.v` `11e71b50…`, `qstar_select.v` `d4f64e65…`.

Frozen board files were not rebuilt.

## Live edges

| Edge | Connection |
|---|---|
| recovered `failure_total` → SPEAR `fem_delta` | `fem_on_mig.failure_total` drives `spear_fem_rank.fem_ft` |
| live `rank0` → Q* feature | `rank0_id == 0xB1` selects feature 2, otherwise 0 |
| Q* proposal → ASTRA proposal | `qstar_select.proposed_action` is the precheck input |

The testbench has no port for `failure_total`, rank, feature, proposal, verdict, or final action.

## Same-epoch captures

`theta[8]` stayed `0001`. `theta_we_count` stayed 1. Descriptors, bases 127 and 0, mask `03`, intent 1, stale 0, and capability 1 were identical on every epoch. Life, `failure_total`, and compacted at the start of each epoch matched the end.

| Epoch | Arm | infl | safe | life | ft | comp | rank0 | dB | feat0 | prop | qsel | verdict | final |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | PRE | 1 | 1 | 7 | 0 | 0 | `0xA1` | 0 | 0 | 0 | 0 | `B0` | `00` |
| 2 | OFF1 | 0 | 1 | 3 | 2 | 1 | `0xA1` | 0 | 0 | 0 | 0 | `B0` | `00` |
| 3 | ON1 | 1 | 1 | 3 | 2 | 1 | `0xB1` | 256 | 2 | 1 | 2 | `B0` | `01` |
| 4 | OFF2 | 0 | 1 | 3 | 2 | 1 | `0xA1` | 0 | 0 | 0 | 0 | `B0` | `00` |
| 5 | VETO | 1 | 0 | 3 | 2 | 1 | `0xB1` | 256 | 2 | 1 | 2 | `B2` | `FF` |

PRE is the ablation before FREC. The required discriminator is epochs 2–5. FREC had restored life 3, `failure_total` 2, compacted 1. No FEM reset sits between those four arms.

## False-integration audit

| Mode | Result |
|---|---|
| Stale latch | OFF2 returned to the OFF1 rank, feature, proposal, and final |
| Constant delta | PRE and ON1 both have influence on and safety on. ft 0 gives delta 0 and action 0. ft 2 gives delta 256 and action 1 |
| Constant proposal | OFF arms propose 0. ON arms propose 1. `apro` equals `prop` |
| Downstream injection | VETO keeps proposal 1 and `qsel` 2, then verdict `B2` and final `FF` |
| Arm-selector leakage | The DUT has no arm input. The split is `fem_infl_en`, recovered `failure_total`, and `safety_ok` |
| Theta rewrite | One write of `theta[8]=1`, still `0001` on epoch 5 |
| Descriptor swap | Both descriptor words unchanged across five epochs |
| FEM drift inside an epoch | `ft0` equals `ft` on every line |

## Still synthetic

Preregistered descriptors, fixed query and generation, fixed theta, fixed `legal_mask`, the `{0,2}` feature map, test-controlled safety, tied intent/stale/capability, and `B0–B4` packing. The destination is `mig_ui_bram`, not generated `mig0`. The final code is not a `PrimitiveCommand`.

## Ceilings

`BOARD_PASS=NO`
`ASTRA_PASS=NO`
`TIMING_PASS=NO`
`PROGRAM_PASS=NO`
`FE256_PASS=NO`
`PACK_ABI_24_24_PASS=NO`
`FEM_PERSIST_PASS=NO`
`MIG_PASS=NO`
