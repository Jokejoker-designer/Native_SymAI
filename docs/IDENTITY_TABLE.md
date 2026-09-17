# Identity table (do not mix bits)

| Name | SHA256 | Folder in this repo | May classify H? |
|---|---|---|---|
| H | `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` | `results/arty_d/m4_mig_clear/` | Internals UNKNOWN |
| H unique copy | same | `.../arty_a7_r2_top_m4_mig_validation_clear_cf62102f.bit` | no |
| H-ILA-A | `b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef` | `results/arty_d/H_ILA_A/` | NO |
| H_OBS | `07776d516d5f46b2ccf318cc12cf33a2eae886281b1bd824ae7aa55e1f26f7d7` | `results/arty_d/H_OBS/` | NO |
| M4+mig candidate bit | `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7` | `results/arty_d/m4_mig/` | historical; not H |
| FE256 integrated freeze DCP | `858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd` | `results/arty_d/hold_r2/R2_FE256_R1_INTEGRATED_FREEZE/` | reference only |
| FE256 rollback DCP | `b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388` | `results/arty_d/hold_r2/R2_TOP_ROUTE_BASELINE_WHS_0P021/` | do not overwrite |
| Isolated FE256 R1 freeze DCP | (see folder) | `results/arty_d/hold_r2/FE256_R1_REFERENCE_FREEZE/` | reference only |

AGENT_C RTL SHA256 (also under `agent_c_rtl/` and `CANON_BLUEPRINT/rtl/native_ai/`):

- `qstar_select.v` `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240`
- `spear_rank.v` `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293`
- `fem_lifecycle.v` `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed`

JTAG `210319BE776EA` UART FTDI `210319BE776EB` COM12 115200. PROGRAM_PASS=NO.
