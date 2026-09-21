# Pack ABI-24 R1 Contract

## 1. Keep the 24-case taxonomy

R1 keeps the existing case groups unchanged:

```text
VALID   V-01..V-04
SCHEMA  S-01..S-04
ABI     A-01..A-04
CONTENT C-01..C-04
CRC     R-01..R-04
GEN     G-01..G-04
```

The UART load outcome/reason expectations remain frozen unless a separate owner-authorized authority change is made.

## 2. Replace Boolean-only generation semantics

The old comparison effectively treated:

```text
reject → generation_flipped = 0
```

as if `0` were directly observed.

R1 separates **commit applicability** from **observed state transition**.

### Commit policy

Each case declares one of:

```text
MUST_COMMIT_FLIP
MUST_NOT_COMMIT
```

For the current 24 cases:

```text
MUST_COMMIT_FLIP:
  V-01 V-02 V-03 V-04 R-04 G-01

MUST_NOT_COMMIT:
  S-01..S-04
  A-01..A-04
  C-01..C-04
  R-01..R-03
  G-02 G-03 G-04
```

### Positive COMMIT proof

`MUST_COMMIT_FLIP` passes only if:

```text
capture_valid == true
overflow == false
same_capture_epoch == true
commit_event == true
generation_before is observed
generation_after is observed
generation_after != generation_before
generation_flipped == true
destination_complete == true
```

### Negative COMMIT proof

`MUST_NOT_COMMIT` does **not** pass merely because `generation_flipped` is absent.

It requires explicit negative coverage:

```text
capture_valid == true
overflow == false
observation_window_complete == true
terminal reject observed
commit_count == 0
```

`generation_flipped` must be absent/N/A for a no-COMMIT case. The benchmark must not synthesize `false` from TSV expected data.

This distinguishes:

```text
FALSE
ABSENT
NOT_OBSERVED
NOT_APPLICABLE
```

and prevents an unobserved transition from being scored as a valid negative observation.

## 3. R-04 query law

R-04 remains:

```text
load = GOLD / LOAD_OK
COMMIT = observed flip
query_status = 6
query_reason = 80 (0x50, PACK_CRC)
```

The QueryRecord must be evaluated after the R-04 committed destination state, on the same declared test lineage.

## 4. G-04 lifecycle law

G-04 must be **self-contained**. It may not depend on an earlier external G-01 case surviving an inter-case CLEAR.

Within one G-04 benchmark case:

```text
establish active generation = 2
→ attempt failed-B / PAGE_CRC
→ active generation must remain 2
→ issue stale query with q_gen = 1
→ query_status = 6
→ query_reason = 84 (0x54, STALE_GENERATION)
```

An inter-case CLEAR that destroys this state invalidates the G-04 experiment rather than proving 6/84.

## 5. Destination-complete law

A UART ACK is insufficient. For every `MUST_COMMIT_FLIP` case, destination completion must be causally observed:

```text
all writes retired
→ readback/verification addressed to the actual written destination
→ matching transaction/generation
→ only then load acceptance
```

The V-03 `region_base` vs `region_base + rg_off` bug is now a permanent regression target.

## 6. R1 Pass definition

`PACK_ABI_24_24_PASS_R1_CANDIDATE` requires, on one declared artifact lineage:

- 24/24 UART outcome/reason/token match;
- positive COMMIT proof for all six commit cases;
- explicit zero-COMMIT coverage for all 18 reject cases;
- R-04 query 6/80;
- G-04 query 6/84 under the self-contained lifecycle;
- destination-complete evidence for the six commit cases;
- no capture overflow/epoch ambiguity;
- exact bitstream/run manifest.

This candidate name does not authorize the historical `PACK_ABI_24_24_PASS` stamp.
