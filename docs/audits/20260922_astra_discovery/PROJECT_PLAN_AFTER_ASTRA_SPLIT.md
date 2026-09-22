# Project plan after the ASTRA maturity split

LANGUAGE=EN
RUN_ID: 20260922T073400Z
STATUS: PLAN
RTL_EDIT=NO
BITSTREAM=NO

## Decision

Keep the query-status ladder and the action-precheck lane apart. The next research step is a new action-precheck identity. It is not a rebinding of `astra_edge_qeval.sv` or `astra_walk_qeval.sv` onto `8b632b4a…`.

## Lane Q — query authority, already stratified

| Level | Artifact | Use |
|---|---|---|
| Law | `D:/NATIVEAI_FULL_EVIDENCE/CANON_BLUEPRINT/03_ASTRA_AUTHORITY.md` `1.6-candidate` | Contract only |
| Engine | `astra_edge_qeval.sv` | Q-eval reference. XSim 256/256 versus B gold. Not on the M4 top. Not `FE256_PASS`. |
| Bound bit | `astra_walk_qeval.sv` inside `query_result_bind_t1cache.sv` | Bit `goal_m4_astra_qeval_candidate.bit` sha256 `fccc21ec…`. XSim 4/4. `verified=0` and `proof_ref=0`, so this path does not emit ANSWER. |
| Pre-search | `astra_qeval.sv` | Integrity / unsupported / budget. XSim 12/256. |
| Stub | `astra_adv_dut.sv` | Ready tied 0. Gold does not score the DUT. |

None of these is `ASTRA_PASS`. None emits `ASTRA_DENY` or `SAFETY_VETO`.

## Lane A — next experiment

Canon §03.12. New module. New identity. Do not overwrite `8b632b4a…`, `52b923a6…`, `3ccd03f8…`, `1db38691…`, or `fccc21ec…`.

Hold the Q* proposal fixed. Change only the safety contract or the capability integrity.

```text
same proposed action
safety/capability admissible → final action follows the proposal
safety/capability veto       → NO_ACTION
restore admissible           → proposal returns
```

Verdict names stay in the action namespace: `ASTRA_DENY`, `SAFETY_VETO`, `STALE_DESCRIPTOR`, `NO_BINDING`, `BOUND`. Do not pack them as query status `0x01–0x06`.

FEM does not write the verdict. SPEAR rank does not write the verdict. Q* does not write `legal_mask`.

## Stop

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
