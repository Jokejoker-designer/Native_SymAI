# UART Mux / Arbitration R1

Recent silicon work showed that QueryRecord interception can corrupt Pack behavior even when Pack and Query blocks are individually correct.

A query signature such as low word `0x4E51` must never steal payload from an active Pack transaction.

## Gate name

```text
UART_MUX_8_8_PASS
```

This is an L0 gate, not a semantic PASS.

## Eight preregistered cases

| ID | Intervention | Required behavior |
|---|---|---|
| MUX-01 | Query marker while UART owner is IDLE | Query path accepts exactly once |
| MUX-02 | Same marker appears as Pack payload while OP_BEGIN active | Pack path owns it; query sees nothing |
| MUX-03 | Marker is first data word after Pack BEGIN | Pack path owns it; no steal |
| MUX-04 | Valid Pack terminates, then Query begins | Ownership transfers once; no drop/dup |
| MUX-05 | Query terminates, then Pack begins | Ownership transfers once; no drop/dup |
| MUX-06 | CLEAR then Query | clean query ownership; no stale pack busy |
| MUX-07 | malformed query-looking word inside Pack | still Pack-owned until Pack transaction releases |
| MUX-08 | back-to-back Pack/Query under UART backpressure/busy | same logical order and exactly-once delivery |

## Required observables

```text
uart_accept_count
pack_accept_count
query_accept_count
owner_state
pack_busy / uart_busy
clear_epoch
drop_count
dup_count
```

Pass requires:

```text
drop_count = 0
dup_count = 0
misroute_count = 0
```

and each accepted word has exactly one owner.

## Permanent regressions from current project

The suite must permanently catch:

1. **Unconditional Query steal** — every UART word matching `0x4E51` is diverted.
2. **Missing Pack ownership guard** — query interception is allowed while OP_BEGIN/Pack transaction is active.
