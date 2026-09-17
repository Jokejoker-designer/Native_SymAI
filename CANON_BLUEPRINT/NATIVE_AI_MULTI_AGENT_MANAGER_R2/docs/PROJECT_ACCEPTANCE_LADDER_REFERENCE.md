---
version: "1.1-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T08:45:00+07:00"
---

# §32 — ACCEPTANCE LADDERS

> Static Full Evidence acceptance, NSPF research falsification and Developmental
> learning acceptance are deliberately separate. No pass is inherited from
> frozen historical V1 into a new artifact.

## 32.1 Full Evidence board-candidate ladder

```text
AUDIT_COMPLETE
→ XSIM_SMOKE_PASS
→ POST_ROUTE_PASS
→ PROGRAM_PASS
→ PACK_ABI_24_24_PASS
→ RUNTIME_DDR_LOAD_PASS
→ READBACK_PASS
→ FE256_256_256_PASS
→ SHUFFLE_PASS
→ ABLATION_PASS
→ UART_E2E_32_32_PASS
→ FULL_EVIDENCE_BOARD_PASS_CANDIDATE
→ OWNER REVIEW
```

### AUDIT_COMPLETE

- source lineage/dirty state and authority files recorded;
- GOAL/invariants/ABI/status semantics audited;
- forbidden overclaims and stale hardware constants removed;
- benchmark contracts frozen before execution.

### XSIM_SMOKE_PASS

- required RTL compiles and preregistered smoke vectors pass;
- simulation evidence only.

### POST_ROUTE_PASS

- implementation completes;
- timing gate meets the preregistered target (e.g. WNS ≥ 0, TNS = 0, hold clean);
- critical DRC/unconstrained semantic paths resolved;
- resource reports archived.

### PROGRAM_PASS

- exact bitstream hash recorded;
- target JTAG/device identity recorded;
- configuration succeeds/startup is valid.

`PROGRAM_PASS` **only proves configuration**, not semantic behavior.

### PACK_ABI_24_24_PASS

All 24 integrity cases in [§31.2] pass: valid/readback, schema mismatch, ABI
mismatch, content mismatch, corruption and generation/A-B atomicity.

### RUNTIME_DDR_LOAD_PASS

- production loader receives the frozen valid pack;
- no load ACK before FIFO/write responses are drained;
- manifest/generation/integrity level is recorded honestly;
- active generation switches atomically.

### READBACK_PASS

Read back preregistered sentinel pages/records from at least:

```text
NODE / EDGE / VALUE / POSTING / CONTEXT / PROVENANCE
```

and verify exact active-generation contents/integrity. The gate does not require
reading every record in a large pack unless its contract explicitly says so.

### FE256_256_256_PASS

- exactly 256 preregistered FE256 **cases** execute;
- 256/256 semantic results/status/proof requirements match gold;
- all zero-error conditions in [§31.3] hold.

### SHUFFLE_PASS

- replay the same FE256 cases in preregistered deterministic shuffled order;
- semantic outcomes remain identical to canonical order;
- no hidden order/state dependence.

### ABLATION_PASS

- preregistered Pack-A/Pack-B support intervention passes [§31.5];
- no stale cache, host injection or hidden duplicate support explains the result.

### UART_E2E_32_32_PASS

- 32 human-text cases execute through the frozen host adapter and production UART path;
- 32/32 semantic parity;
- zero parse deadlock, frame/CRC/txn mismatch, timeout and status distortion;
- host adapter source/hash/version is part of evidence.

### FULL_EVIDENCE_BOARD_PASS_CANDIDATE

- every preceding static Full Evidence gate passes on the same declared artifact lineage;
- all expected CONFLICT/UNKNOWN/etc. cases match gold;
- no unresolved protocol/integrity failure exists;
- raw board evidence and hashes are sealed.

This candidate does **not** imply NSPF developmental learning/grounding/transfer
passes, and is not owner `BOARD_PASS`.

### OWNER REVIEW

Only the project owner may promote/reject/request more evidence and authorize a
final artifact freeze/stamp.

## 32.2 Separate NSPF research-candidate gate

`NSPF_R0_RESEARCH_CANDIDATE` is separate from Full Evidence. It requires the
preregistered NSPF-X0 campaign relevant to the research claim, including at
minimum ID/alias perturbation, masked slot, causal ablation, logical-time
robustness, cache parity and knowledge-load dependence. Transfer/grounding tests
are required before those stronger claims may be made.

## 32.3 Separate Developmental R2 candidate

`DEVELOPMENTAL_R2_CANDIDATE` additionally requires evidence for:

```text
executed-action credit
reset/restore learning causality
FEM lifecycle/regression
parameterized skill lifecycle + unseen-instance transfer
teacher false-input/anti-parrot boundary
sensor/action/effect grounding
capability binding + safety veto/readback
fact/candidate/episode/skill/weight separation
checkpoint generation/version integrity
```

No lower-level static pass automatically satisfies these.

## 32.4 Claim ceilings

```text
XSIM_*                         -> simulation claim only
PROGRAM_PASS                   -> configuration claim only
FULL_EVIDENCE_BOARD_PASS_CANDIDATE -> static semantic board candidate only
NSPF_R0_RESEARCH_CANDIDATE     -> bounded research-hypothesis support only
DEVELOPMENTAL_R2_CANDIDATE     -> bounded developmental candidate only
OWNER REVIEW                   -> owner decision, never agent self-certification
```

Historical V1 evidence remains frozen/read-only and is never overwritten or
inherited by these new candidates.

## Tóm tắt tiếng Việt

R0.1 tách ba loại acceptance: Full Evidence tĩnh, NSPF falsification, và
Developmental learning. Pack/ABI 24/24 là 24 integrity case; FE256 là 256 case;
UART E2E đi từ human text. Chỉ owner được cấp final stamp.
