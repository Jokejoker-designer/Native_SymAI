# U33OBS final observation contract — frozen specification

STATUS: CONTRACT_FROZEN=YES  
READY_TO_BUILD=YES (observe-only load/transport identity, source review only)  
READY_TO_PROGRAM=NO (owner approval required)  
QUERY_IDENTITY_READY=NO  
PROGRAM=NO / OVERLAY=NO / PACK_ABI_24_24_PASS=NO

This contract is limited to finding the first divergent accepted word/hop for MUTE or MAG and observing load-side generation. It does not wire query UART, change U33, or claim Pack/ABI acceptance.

## A. FINAL OBSERVATION CONTRACT

The observation identity copies the frozen U33 functional path and adds only local observers. Functional `valid`, `ready`, reset, and memory handshakes are unchanged. Observers never drive DUT backpressure or select data.

The observer has two local domains:

- `clk100`: UART completed-word acceptance, FIFO write, FIFO read, steering/lock, CDC source acceptance, CLEAR/flush/reset events.
- `ui_clk`: CDC destination acceptance, loader acceptance, loader/parser state snapshots, terminal ACK/NAK and COMMIT events, generation/slot snapshots.

No multi-bit payload crosses domains directly. Cross-domain correlation uses recorded CDC request/ack transitions and a synchronized arm/freeze handshake.

## B. CLOCK-DOMAIN OWNERSHIP

Each hop has its own trace lane. A same-cycle event in different lanes creates one record in each lane; no priority-selected shared data word is used.

| Domain | Lane | Event condition |
|---|---|---|
| clk100 | UART_WORD | completed UART word `w_valid && w_ready` |
| clk100 | FIFO_WR | actual FIFO write `wr_valid && wr_ready` |
| clk100 | FIFO_RD | actual FIFO pop `rd_valid && rd_ready` |
| clk100 | CDC_A | source-side `a_valid && a_ready` |
| clk100 | CONTROL | CLEAR request/hold/flush, pack lock/steer, local reset edges |
| ui_clk | CDC_B | destination-side `b_valid && b_ready` |
| ui_clk | LOADER | loader-side `s_valid && s_ready` |
| ui_clk | STATE | parser state/`opcode`/`rx_words`/`hw0`/`got_begin` snapshots and reset edges |
| ui_clk | TERMINAL | COMMIT, ACK, NAK, reject reason and outstanding-retirement events |

## C. TRACE / RECORD ABI

The frozen trace ABI is one record per event lane, not one record per cycle.

```text
TraceEntry = {
  epoch_id       : 16,
  seq            : 16,
  local_cycle    : 32,
  data           : 32,
  flags          : 16
}
```

Total: 112 bits per entry. Each lane owns a depth-256 BRAM trace array and write pointer. `seq` starts at zero on arm and never wraps during a valid capture. `local_cycle` is a local-domain free-running counter sampled on the event.

`flags` is lane-specific and frozen by this contract:

- UART/FIFO: valid/ready, flush, `pack_lock`, steering decision, FIFO used-low snapshot.
- CDC_A/CDC_B: request/ack/last toggle snapshots, source/destination reset state, `b_valid`/`b_ready`.
- LOADER: `state`, `opcode`, `rx_words[15:0]` and `got_begin` are carried in STATE snapshots; `flags` marks accepted beat and terminal context.
- CONTROL/TERMINAL: event kind, reset/flush, ACK/NAK, reason and commit marker.

Per-lane payload is preserved even when UART, FIFO and CDC events occur on one cycle. Same-lane double-fire is illegal for a single ready/valid interface; if a future lane can generate two events per cycle, it must split into two lanes before implementation.

## D. ARM / FREEZE / OVERFLOW LAW

Global observation control is:

```text
epoch_id       : 16
armed          : 1
capture_valid  : 1
overflow       : 1
freeze_reason  : 4
```

`epoch_id` is loaded through a control-domain handshake and sampled locally in both clock domains; no unsynchronized multi-bit bus is used. `armed` becomes true only after both domains acknowledge the same epoch.

Capture is armed before CLEAR and retains an arm-time snapshot containing, at minimum:

```text
loader_state, opcode, rx_words, hw0, got_begin,
active_generation, slot_bit, reset/flush state
```

CLEAR is an event. It never clears trace RAM, sequence counters, arm snapshot or capture epoch.

`freeze_reason` values:

```text
0 NONE
1 BAD_MAGIC_NAK
2 OTHER_NAK
3 HOST_DUMP_MUTE
4 MANUAL_STOP
5 OVERFLOW
6 RESET_ABORT
```

MAG auto-freezes after the LOADER/TERMINAL record containing the actual reject. MUTE has no NAK; the host/debug control issues `HOST_DUMP_MUTE` after the V-04 timeout, and the ring retains the pre-CLEAR and V-04 history. Dump transport is a separate observation TAP and never reuses product Pack TX CDC.

Any lane reaching depth 256 sets `overflow=1`, freezes all lanes, sets `capture_valid=0`, and marks the whole run `OBSERVATION_INVALID`. No silent oldest-record overwrite is allowed. A missing arm acknowledgement, reset during arm, or incomplete cross-domain freeze also sets `capture_valid=0`.

## E. GENERATION OBSERVATION LAW

Generation is observed at the Pack owner in `ui_clk` as a **state transition on COMMIT**, not as a comparison of two idle snapshots. It is never decoded from UART and never copied from TSV.

At a COMMIT event, the observer records:

```text
generation_before = active_generation before S_COMMIT update
generation_after  = active_generation sampled one ui_clk after COMMIT
slot_before       = slot_bit before S_COMMIT update
slot_after        = slot_bit sampled one ui_clk after COMMIT
commit_event      = observed S_COMMIT transition (1 only on that edge)
ack_event         = observed load_ack terminal edge/event
reject_event      = observed load_reject terminal edge/event
reason_code       = observed reason_code at terminal event
epoch_before      = capture epoch_id sampled with generation_before
epoch_after       = capture epoch_id sampled with generation_after
same_capture_epoch = (epoch_before == epoch_after)
                     AND no CLEAR / debug_clear / observer-reset / arm-rearm
                     between those two samples
```

`generation_flipped=true` (stored `1`) if and only if:

```text
commit_event == 1
AND generation_after != generation_before
AND same_capture_epoch
AND capture_valid == 1
```

`generation_flipped=false` (stored `0`) only when `commit_event==1` AND `same_capture_epoch` AND `capture_valid==1` AND `generation_after==generation_before`.

Otherwise the field is **absent** (`compare_ready=false`). Two snapshots whose numeric generation differs across a reset, CLEAR, or epoch change are not a flip. A reject row without an observed COMMIT does not invent `0` or `1`.

## F. R-04/G-04 AUTHORITY DECISION

**Decision: query status/reason is a real requirement of the full 24-case Pack/ABI comparator, but query wiring is outside U33OBS.**

Evidence:

- `31_VERIFICATION_AND_CAUSAL_TESTS.md:54` defines R-04 as load may ACK plus query `DATA_INTEGRITY_FAIL/PACK_CRC`.
- `31_VERIFICATION_AND_CAUSAL_TESTS.md:58` defines G-04 stale query `STALE_GENERATION`.
- `31_VERIFICATION_AND_CAUSAL_TESTS.md:76–79` requires `query_status/query_reason` for R-04/G-04.
- `pack_abi24_gold.py:1151–1158` rejects missing/mismatched query fields.

Therefore:

- U33OBS load-side identity records generation and load truth only.
- U33OBS does not wire `uart_fe256_host.in_valid`; query remains tied off.
- Full `--compare` and `PACK_ABI_24_24_PASS` remain incomplete for R-04/G-04 until an owner-authorized query identity exists.
- No query wiring is added to U33OBS without a separate owner YES naming query-on-UART as in scope.

## G. MAPPER / COMPARE LAW

UART-only mapping may emit only:

```text
outcome, reason, ack, reject
```

From `{hi,mid,reason,tail}`:

```text
01 00 rr A5 -> LOAD_OK
02 00 rr 5A -> LOAD_REJECT
```

UART mapping must never create `generation_flipped`, `committed_generation`, `query_status`, or `query_reason` from TSV/gold. Missing observed fields stay absent and force `compare_ready=false`. A row is compare-ready only when §E `generation_flipped` is present (true or false under that predicate), and R-04/G-04 additionally have direct query observations.

## H. RESOURCE ESTIMATE

Seven lanes × depth 256 × 112 bits = 200,704 bits of trace storage. With BRAM36 rounding, budget approximately 7–8 RAMB36 blocks, plus snapshot/control registers and TAP CDC logic. This is an observation identity budget, not a product-resource claim and not a timing signoff.

The rejected 41-bit starter `{mask,data}` would use less memory but loses same-cycle payload attribution. The frozen contract intentionally spends the additional BRAM to preserve evidence.

## I. RISKS

- Instrumentation can perturb timing or placement; a clean observation identity does not clear U33. Record `INSTRUMENTATION_PERTURB` if the known dummy-open MUTE does not reproduce.
- MUTE has no NAK; the host dump/freeze request must preserve history and cannot be treated as a product transaction.
- Trace lanes can overflow; overflow invalidates the whole run.
- Cross-domain correlation can be wrong if a multi-bit epoch is sampled unsafely; use the arm handshake and local acknowledgements.
- Query remains absent by design; U33OBS cannot produce full R-04/G-04 compare rows.
- A generation snapshot proves load-owner state, not that query runtime consumed the committed DDR image.
- Numeric `generation_after != generation_before` across CLEAR/reset/epoch is not a flip. Only the §E four-conjunct predicate may set `generation_flipped=true`.

## J. READY_TO_BUILD

```text
CONTRACT_FROZEN=YES
READY_TO_BUILD=YES
CORE_RTL=PASS_XSIM pack_obs_lane/gen/ctrl (2026-09-20)
HOPS_RTL=PASS_XSIM leftover CLASS_A + DUMP-without-NAK (2026-09-20; reconfirmed after 9-lane harness ports)
NINE_LANE_RTL=PASS_XSIM CONTROL/STATE/TERMINAL + GOLD four-AND (2026-09-20)
  leftover MAG flip_present=0 NAK flags=0004
  GOLD generation_flipped=1 before=ffffffff after=0000ffff same_epoch
SILICON_IDENTITY=NO
READY_TO_PROGRAM=NO
  missing board top + DUMP TAP CDC + synth-legal COMMIT tap if hierarchical peek rejected

QUERY_IDENTITY_READY=NO
PACK_ABI_24_24_PASS=NO
```

No implementation or programming is performed by freezing this document. The current U33, U33TAP and freeze/reference artifacts remain untouched.
