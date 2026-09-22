# ASTRA_ACTION_PRECHECK_V1

LANGUAGE=EN
RUN_ID: 20260922T073600Z
STATUS: SPEC_PLUS_XSIM
BITSTREAM=NO
PROGRAM=NO

This is the action lane. It is not Q-eval.

```text
QUERY LANE:
evidence → ASTRA query verification → StructuredResult/status 0x01–0x06

ACTION LANE:
Q* proposed action
→ ASTRA action-precheck
→ capability binding
→ final action / NO_ACTION
```

## Verdict class lock

`ASTRA_DENY`, `SAFETY_VETO`, `STALE_DESCRIPTOR`, `NO_BINDING`, and `BOUND` are an action-verdict class.

They are not `ANSWER`, `UNKNOWN`, `CONFLICT`, `SEARCH_INCOMPLETE`, `UNSUPPORTED_QUERY`, or `DATA_INTEGRITY_FAIL`.

They must not be encoded as query status `0x01–0x06`, illegal status `0x00`, or adapter status `0x80`.

They must not reuse Q-eval reason bytes `0x22`, `0x23`, `0x30`, `0x55`, or `0x56`.

Numeric values below are a V1 candidate packing so the XSim can distinguish them. They are not a B numeric freeze.

| Verdict | Code |
|---|---|
| `BOUND` | `8'hB0` |
| `ASTRA_DENY` | `8'hB1` |
| `SAFETY_VETO` | `8'hB2` |
| `STALE_DESCRIPTOR` | `8'hB3` |
| `NO_BINDING` | `8'hB4` |

`NO_ACTION` for the emitted action is `8'hFF`. A bound result copies `proposed_action` into the low 3 bits and leaves the upper bits 0.

## Fixed proposal

`proposed_action = 3'd1` on every arm. The module does not read FEM, SPEAR, rank, or a query record.

## Single-fault priority

First match:

1. `descriptor_stale` → `STALE_DESCRIPTOR`
2. `!intent_legal` → `ASTRA_DENY`
3. `!safety_ok` → `SAFETY_VETO`
4. `!capability_present` → `NO_BINDING`
5. else → `BOUND`

`SAFETY_VETO` does not override `ASTRA_DENY`. `NO_BINDING` is not a safety failure.

## Causal matrix

| Arm | stale | intent_legal | safety_ok | capability_present | Verdict | final_action |
|---|---|---|---|---|---|---|
| A | 0 | 1 | 1 | 1 | `BOUND` | `proposed_action` |
| B | 0 | 1 | 0 | 1 | `SAFETY_VETO` | `NO_ACTION` |
| A2 | 0 | 1 | 1 | 1 | `BOUND` | `proposed_action` |
| C | 1 | 1 | 1 | 1 | `STALE_DESCRIPTOR` | `NO_ACTION` |
| D | 0 | 1 | 1 | 0 | `NO_BINDING` | `NO_ACTION` |

Encoding guard, not one of the five causal arms: `intent_legal=0` with the other inputs admissible must return `ASTRA_DENY`, not `SAFETY_VETO` and not a query status.

## Claim ceiling

```text
ASTRA_PASS=NO
BOARD_PASS=NO
PROGRAM_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO
PACK_ABI_24_24_PASS=NO
```

Do not build a bitstream from this spec. A silicon identity waits until this XSim matrix passes.
