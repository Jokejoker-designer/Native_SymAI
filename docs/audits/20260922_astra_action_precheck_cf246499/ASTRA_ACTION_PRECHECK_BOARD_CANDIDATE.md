# ASTRA_ACTION_PRECHECK_BOARD_CANDIDATE

LANGUAGE=EN
FREEZE_UTC: 2026-09-22T074700Z

```text
ASTRA_ACTION_PRECHECK_V1=PASS_XSIM
ASTRA_ACTION_PRECHECK_BOARD_CANDIDATE=SUPPORTED
IDENTITY=cf246499c6e5c09b57fefdd89dc5d6602fc7ded5dc2426d635a0987fc2bc8dae
EOS=HIGH
PROGRAM.DONE=NA
WNS=+5.404
WHS=+0.074
TIMING_PASS=NO
ASTRA_PASS=NO
BOARD_PASS=NO
PROGRAM_PASS=NO
```

Proposal stayed `3'd1`. UART flags are host conditions only.

| Arm | flags | verdict | final |
|---|---:|---|---|
| A | `0x0B` | `B0` BOUND | `01` |
| B | `0x09` | `B2` SAFETY_VETO | `FF` |
| A2 | `0x0B` | `B0` BOUND | `01` |
| C | `0x0F` | `B3` STALE_DESCRIPTOR | `FF` |
| D | `0x03` | `B4` NO_BINDING | `FF` |

The accidental first arm D set the stale bit. The DUT returned `STALE_DESCRIPTOR` before `NO_BINDING`. Verdict follows predicate priority, not an arm-name table.

```text
CAUSAL_BOARD_CANDIDATES=SUPPORTED
PRODUCT_PATH_COMPLETE=NO
```

These identities are not one wired path. See `INTEGRATION_DEBT_CHAIN_AUDIT.md`.

Codes `B0–B4` remain XSim/board packing, not a locked ABI. Not query status.

Bit file does not overwrite `8b632b4a…`. FEM, SPEAR, and Q* RTL were not edited.
