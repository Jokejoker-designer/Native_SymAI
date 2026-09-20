# Pack/ABI-24 observe DUT XSim — dest-complete + QueryRecord R-04/G-04, not PACK_ABI (2026-09-20)

This watch did **not** program Arty, did **not** invoke Pack24 hops, did **not** resume parent xelab/xsim, and did **not** run B `--compare`. Parent XSim `tb_pack_abi24_obs_dut` through `pack_mig_bind` + `mig_ui_bram` dest stand-in. **Not** generated `mig0`. **Not** board. B TB unmodified. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Unique rearm bit `08c647ee…` not overwritten.

| Artifact | SHA256 |
|---|---|
| `DUT.jsonl` | `57a7b65d26af1b7820a17a9fe31f64ab26e9ae2751658d09517a256e9c2705b0` |
| `D_PACK_ABI24_OBS_DUT.json` | `577f333ddc35b981a199b4b09d2b5fc9d5092b037e991625094b36dcdcdc83f7` |
| `tb_pack_abi24_obs_dut.sv` | `46d37a720a309086cc5db2b69ca5c4a91e1fd6a2095f7773634fd386c0449295` |
| `pack_query_eval.sv` | `c04876f09bad8f0cc3bddff349c6303c3ceaead019a6f1bcd47661c1fd5ca738` |

`xsim.log`: `PACK_ABI24_OBS_DUT_XSIM_LOAD 24/24` at **26165 ns**. Source field `XSIM_PACK_OBS_GEN_QUERY_NOT_SILICON`. LOAD_OK six this-pack four-AND `flip=1`. Observed QueryRecord **R-04** `query_status=6` `query_reason=80`; **G-04** `6/84` with `generation_flipped` absent (no this-pack COMMIT). AGENT_D `b_compare`: **6/24 match, 18 fail** (reject flip None vs TSV 0). Watch did **not** invoke `--compare`.

Reject flip 0-vs-absent remains OPEN. Dest is UI BRAM, not MIG/board. **PACK_ABI_24_24_PASS=NO**.
