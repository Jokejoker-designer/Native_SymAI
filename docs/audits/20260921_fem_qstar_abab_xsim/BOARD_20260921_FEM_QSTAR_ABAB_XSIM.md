# FEM Q* A/B/A/B XSim PASS_XSIM (2026-09-21)

Watch did **not** program. Unique dir `docs/audits/20260921_fem_qstar_abab_xsim/`. Does **not** overlay `20260921_fem_qstar_causal_design/`. Same-clock `mig_ui_bram`. Not `mig0`. Not silicon. Bit of this mux is a **separate** unique identity `3ccd03f8…` (STOP_BEFORE_PROGRAM). Persist `1db38691…` cannot run this mux.

LANGUAGE=EN. Not a product PASS stamp.

```text
RESULT = PASS_XSIM
FINISH = 12445 ns
BIT = NOT_THIS_DIR
PROGRAM = NO
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO
PACK_ABI_24_24_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| `fem_qstar_abab_xsim.log` | `a4d5576ea6212dad70719b95dece8b4e6d62bd2a9deb38c399c167e30edee944` |
| `FEM_QSTAR_ABAB_XSIM_RESULT.md` | `32b246a46a6d2ed8ca539d5d26a06ef227d5d64c2a692b343baaf08aa1aeb5fc` |
| `fem_qstar_infl.sv` | `0a83aba1a3cb01ee168c94374a18eca85ebf5b1817abf6ea1c4aa98c3bc81e47` |
| `tb_fem_qstar_abab.sv` | `4b902f289637372d53531ad22b722073beb43fc871ae63ea0eac4da39ffa23df` |
| `run_fem_qstar_abab_xsim.bat` | `24022923dfa9c31c7fbe918d63aa9b738355ae15b8b6a63b0d339b5a37d5ba37` |
| V1 20260921T165800Z | `cce69e57b7c61931d9bc61d989e735cdb99fdf8893db414b02f69c6e0e62a29e` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |
| C `qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| C `spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |

Log lines independently read:

```text
ARM A  infl=1 feat0=0 ft=0 life=7 greedy=0 q_sel=0
ARM B  infl=1 feat0=2 ft=2 life=3 greedy=1 q_sel=2
ARM A2 infl=0 feat0=0 ft=2 life=3 greedy=0 q_sel=0
ARM B2 infl=1 feat0=2 ft=2 life=3 greedy=1 q_sel=2
FEM_QSTAR_ABAB_XSIM_RESULT greedy=0,1,0,1 PASS_XSIM
$finish 12445 ns
```

A2 kept recovered `failure_total=2` and `life=3` while greedy returned to 0. CDC across a separate Q* clock is NOT_TESTED. C RTL unedited (hashes match AGENT_C worktree and Native_SymAI PACKAGE).
