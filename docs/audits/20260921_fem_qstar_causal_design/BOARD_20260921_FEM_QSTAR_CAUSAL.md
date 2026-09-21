# FEM → Q* A/B/A/B design lock (2026-09-21)

Watch did **not** build or program. SHA **NOT_ASSIGNED**. Unique tree `D:/FPGA/arty_d/UART_R2/fem_qstar_causal/`. Does **not** overwrite `1db38691` / `ead830ae` / `daaca9c1` / `8bfd993d`. C hashes independently confirmed: FEM `45b9b930…`, Q* `d4f64e65…`, SPEAR `11e71b50…`.

LANGUAGE=EN. Not a product PASS stamp.

```text
STATUS = DESIGN_LOCKED
BUILD = NO
PROGRAM = NO
PASS_XSIM = NOT_RUN
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO
PACK_ABI_24_24_PASS = NO
C_SCALE_GUARD = HOLD
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| `FEM_QSTAR_CAUSAL_ABAB_SPEC.md` | `5ed00715cd0554debed95f131e569d6ced2e15f59aae11511cdbee817846d1ad` |
| `IDENTITY_RESERVATION.md` | `4959495ad5dccf8048f33f371d96ce9751af58057e6c79c63a81ed3a61b89a98` |
| C `qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| C `spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

Predicted greedy 0/1/0/1 is **INFERENCE** from RTL MAC/tie, **NOT_TESTED**. Next: XSim on this tree before any bitgen. Owner must quote a **new** SHA before PROGRAM.
