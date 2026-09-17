---
version: "1.5-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T18:50:00+07:00"
---

# §32 — ACCEPTANCE LADDERS

> Static Full Evidence acceptance, NSPF research falsification and Developmental
> learning acceptance are deliberately separate. No pass is inherited from
> frozen historical V1 into a new artifact.

## 32.1 Full Evidence board-candidate ladder

```text
AUDIT_COMPLETE
→ FE256_GOLD_FROZEN
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

### FE256_GOLD_FROZEN

AGENT_B gate. Required before Agent D XSim may be scored:

- `verification/fe256/fe256_gold.py --selfcheck` exits 0;
- 256/256 packed QueryRecord (32 B) and StructuredResult (48 B);
- class counts match [§31.3];
- `fe256_manifest.json` hashes recorded;
- encodings match [§04.12]; Q-eval matches [§03.9].

Changing gold to rescue a DUT is forbidden [§31.9].

ASTRA adversarial / status-proof Q-eval gold and XSim harness exist
[§31.11] (`verification/astra_adv/astra_adv_gold.py`,
`verification/astra_adv/tb_astra_adv_xsim_compare.sv`). That campaign is
independent of the FE256 histogram and is not DUT RTL. `--selfcheck` and
`ASTRA_ADV_XSIM_PASS` are not ladder stamps. Fail-closed until D binds
`q_ready`/`s_ready`. PROGRAM=NO. B-RUNTIME-LAW-01 appends reward-identity,
`k_invalid`, and FEM `COMMITTED_CORRUPT` vectors without shrinking the
prior 17 case IDs. That append is not a ladder stamp.

Next B-owned READY verifier after this law-sync: action-path /
action-precheck gold echoing the seven [§05.8] names [§31.12] [§03.12].
That gold is not a ladder stamp. Independent D CANDIDATE review is later
and is not this stamp. M2 posting checks, if extended, stay 64-bit
`PostingEntry` [§31.13].

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

All 24 integrity cases in [§31.2] pass against
`verification/pack_abi24/pack_abi24_gold.py` artifacts: valid/readback, schema
mismatch, ABI mismatch, content mismatch, corruption and generation/A-B
atomicity. Generator selfcheck / `PACK_ABI24_GOLD_CANDIDATE` is **not** this
stamp. XSim evidence is not board evidence. Agent D must not import the gold
packer as the DUT encoder. Comparator:
`verification/pack_abi24/tb_pack_abi24_xsim_compare.sv` and
`python pack_abi24_gold.py --compare DUT.jsonl`.
`PACK_ABI24_XSIM_PASS` ≠ `PACK_ABI_24_24_PASS`.

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
- 256/256 semantic results/status/proof requirements match
  `verification/fe256/out/fe256_gold_results.bin` bit-exact;
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
  (seven [§05.8] names [§32.5]; not X0-15 as a substitute)
fact/candidate/episode/skill/weight separation
checkpoint generation/version integrity
```

No lower-level static pass automatically satisfies these.

## 32.4 Claim ceilings

```text
FE256_GOLD_FROZEN              -> host gold/selfcheck only
PACK_ABI24_GOLD_CANDIDATE      -> generator artifacts only; not PACK_ABI_24_24_PASS
XSIM_*                         -> simulation claim only
PROGRAM_PASS                   -> configuration claim only
PACK_ABI_24_24_PASS            -> DUT matched all 24 gold cases (still not board)
FE256_256_256_PASS             -> DUT matched 256 gold cases (still not board)
FULL_EVIDENCE_BOARD_PASS_CANDIDATE -> static semantic board candidate only
NSPF_R0_RESEARCH_CANDIDATE     -> bounded research-hypothesis support only
DEVELOPMENTAL_R2_CANDIDATE     -> bounded developmental candidate only
OWNER REVIEW                   -> owner decision, never agent self-certification
```

No agent may self-stamp `BOARD_PASS` or `FINAL_PASS`.
No agent may self-stamp `PACK_ABI_24_24_PASS`, `FE256_FULL_PASS`,
`MIG_PASS`, `FEM_PERSIST_PASS`, or the seven [§05.8] names from a
document echo.

Historical V1 evidence remains frozen/read-only and is never overwritten or
inherited by these new candidates.

## 32.5 Action-path names and posting width (echo only)

B-owned ladder/test **names** pointing at A-owned [§05.8] results. Not
stamped PASS here:

```text
CAPABILITY_ENUM_PASS
NO_BINDING_NO_ACTION_PASS
SAFETY_VETO_PASS
COMMAND_READBACK_PASS
STALE_DESCRIPTOR_REJECT_PASS
GEMINI_NO_ACTUATOR_AUTHORITY_PASS
UNEXECUTED_NO_CREDIT_PASS
```

Posting lock (not a 128-bit `PostingEntry` type) [§31.13] [§02.4.1]:

```text
PostingEntry = 64 bit
2 × 64 = PACK_GROUP
PACK_GROUP ≠ 128-bit PostingEntry type
Query / Result / Event stay [§04] 256 / 384 / 192 bits
```

## Tóm tắt tiếng Việt

R0.1 tách ba loại acceptance: Full Evidence tĩnh, NSPF falsification, và
Developmental learning. Gold Python phải đóng băng trước khi chấm XSim.
Pack/ABI 24/24 là 24 integrity case; FE256 là 256 case; UART E2E đi từ human
text. Bảy tên [§05.8] được echo ở §32.5, chưa đóng dấu PASS. `PostingEntry`
64 bit; `PACK_GROUP` không phải kiểu 128-bit. Chỉ owner được cấp final stamp.
