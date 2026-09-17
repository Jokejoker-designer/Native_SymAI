---
version: "1.6-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T18:50:00+07:00"
---

# §03 — ASTRA AUTHORITY

> ASTRA is the deterministic authority boundary for legality, proof validity, provenance,
> conflict, completeness, epistemic status and knowledge promotion under the implemented
> rules/evidence contract. It is not an omniscient truth oracle. No other subsystem may
> override or bypass it.

## 3.1 ASTRA's Role

ASTRA answers one set of questions:

> Is this legal? Is the evidence adequate? Is there conflict?
> What epistemic status may be emitted? Can this candidate be promoted?
> May this intent+descriptor+safety bind? [§01.7] [§03.12]

ASTRA does **not** answer:
- "What should I do next?" → Q* [§10]
- "Which candidate first?" → SPEAR [§10]
- "How do I execute this?" → Skill Engine may originate `ACTION_INTENT` [§12];
  pin drive is the Primitive Executor **after** ASTRA action-precheck + `BOUND` [§01.7]
- "How do I say this to a human?" → GEMINI / Language Adapter [§01.8]
  (GEMINI does not drive actuators)

## 3.2 Epistemic Status Codes

ASTRA must emit exactly one of these statuses for every query resolution:

| Status | Meaning |
|--------|---------|
| `ANSWER` | Evidence supports a definite answer with proof trace |
| `UNKNOWN` | Search completed for the declared scope and found no verified support |
| `CONFLICT` | Contradictory evidence exists; cannot resolve |
| `SEARCH_INCOMPLETE` | Budget/resource limit ended search before declared-scope completeness was established |
| `UNSUPPORTED_QUERY` | Query type not supported by current system |
| `DATA_INTEGRITY_FAIL` | Knowledge pack CRC/hash mismatch or corruption |

The adapter layer may additionally emit:
| Status | Meaning |
|--------|---------|
| `PARSE_ERROR` | Input text could not be parsed into a valid QueryRecord |

There is exactly one primary epistemic-status namespace. It is
`StructuredResult.status` [§04.12]: `0x00` illegal (protocol/uninitialized),
`0x01` `ANSWER`, `0x02` `UNKNOWN`, `0x03` `CONFLICT`, `0x04` `SEARCH_INCOMPLETE`,
`0x05` `UNSUPPORTED_QUERY`, `0x06` `DATA_INTEGRITY_FAIL`, and adapter-only
`0x80` `PARSE_ERROR`. `reason_code` is a **separate** field / substatus.
`TIE_OVERFLOW` `0x22`, `K_INVALID` `0x23`, `INVALID_DESCRIPTOR` `0x55`, and
`COMMITTED_CORRUPT` `0x56` are `reason_code` values only. They never replace
a primary status byte. `SEARCH_INCOMPLETE` + `reason_code=0x22` is not
“status `0x22`”. `DATA_INTEGRITY_FAIL` + `reason_code=0x55` is not
“status `0x55`”. `DATA_INTEGRITY_FAIL` + `reason_code=0x23` is not
“status `0x23`”. `DATA_INTEGRITY_FAIL` + `reason_code=0x56` is not
“status `0x56`”.

**Critical distinctions**:
- `SEARCH_INCOMPLETE ≠ UNKNOWN`: If declared-scope postings/frontier were not fully examined, the system must say the search was incomplete, not "I don't know." SPEAR clean Top-K cutoff without TIE-R0 is inspection order, not incompleteness.
- `CONFLICT ≠ UNKNOWN`: Having contradictory evidence is different from having no evidence.
- `ANSWER` requires a proof trace — not just a score.
- If the search budget is exhausted before required completeness is established, status is `SEARCH_INCOMPLETE`, never `UNKNOWN`.

## 3.3 Proof Objects

Every `ANSWER` status must be accompanied by a proof object containing:

```text
ProofObject:
  query_id:        reference to original QueryRecord
  answer_ref:      ID of the answer node/edge/value
  support_chain:   ordered list of edges/relations traversed
  provenance_refs: origin of each supporting piece of evidence
  context_match:   which context constraints were satisfied
  generation:      knowledge generation number at proof time
  timestamp:       logical tick of proof creation
```

## 3.4 What ASTRA Checks

Two machines. Do not mix their outputs.

**Q-eval / K-promote** [§03.9] — for every candidate answer or promotion request:

1. **Legality** — Does this operation comply with schema/ABI rules?
2. **Evidence** — Is the support chain present and complete?
3. **Provenance** — Where did each piece of supporting evidence come from?
4. **Conflict** — Does any existing verified knowledge contradict this?
5. **Completeness** — Has the search covered all required paths within budget?
6. **Epistemic Status** — What query status code should be emitted? (`0x01–0x06` only)

**Action-precheck** [§03.12] — **before** `CapabilityBinding` and **before**
the Primitive Executor. Inputs are `ACTION_INTENT`, the resolved
`CapabilityDescriptor`, and `safety_contract` / `safety_contract_ref` [§01.7]
[§05.1]. Verdicts are actuation statuses (`ASTRA_DENY`, `SAFETY_VETO`,
`STALE_DESCRIPTOR`, …) [§20.5.1]. They are **not** query primary status
`0x01–0x06`. `SAFETY_VETO` is not `UNKNOWN`, not `ANSWER`, not `CONFLICT`.

## 3.5 Knowledge Promotion Rules

Knowledge promotion follows a strict pipeline:

```text
Teacher proposal / Sensor observation / Self-experience
         ↓
CANDIDATE record (with provenance attached)
         ↓
Verification against existing knowledge
         ↓
 ┌───────┼────────┐
 ↓       ↓        ↓
VERIFY  REJECT  CONFLICT
 ↓
generation commit (version increment)
 ↓
future retrieval as VERIFIED
```

**Locked rules**:
- Teacher CANNOT directly write FACT — teacher input creates CANDIDATE only
- Teacher CANNOT set weights
- Teacher CANNOT send proof
- Teacher CANNOT declare a winner
- Raw sensor input creates `OBSERVATION`/`EPISODE` evidence. A derived concept/relation may become a CANDIDATE; observation is not automatically a VERIFIED_FACT
- Self-experience creates EPISODE and CANDIDATE relations
- ASTRA may promote runtime `CANDIDATE → VERIFIED` only under the certified knowledge-promotion contract
- Project artifact promotion/freeze is a separate governance action; only the project owner may authorize final artifact promotion/freeze

## 3.6 UNKNOWN Does Not Auto-Trigger Teacher

The draft rule "UNKNOWN → ASK_TEACHER" is **incorrect**. The correct flow:

```text
MISSING / UNKNOWN / SEARCH_INCOMPLETE
            │
            ▼
         Working Mind
            │
      Q* chooses strategy
   ┌────────┼────────┐
   ▼        ▼        ▼
retrieve observe  ask teacher
   │        │        │
   └────────┼────────┘
            ▼
         candidate
```

`ASK_TEACHER` is only valid when:
- Teaching mode is enabled
- Policy permits asking
- Identity/pending context is valid

Teacher returns `CANDIDATE`, not `FACT`.

## 3.7 Authority Boundaries

| Component | Can Create | Cannot Create |
|-----------|-----------|---------------|
| Q* | Strategy choice | Truth, proof |
| SPEAR | Ranking score | Truth, proof, legality override |
| Teacher | CANDIDATE knowledge | FACT, weight, proof |
| Sensor | CANDIDATE concept, observation | FACT |
| FEM | Failure record, recovery | FACT promotion |
| Cache/Hotness | Placement change | Epistemic status change |
| GEMINI | Human-language rendering | Truth, knowledge, actuator command [§01.8] |
| Predictor/HDC/association sidecar | Candidate hints/predictions | Truth, proof, legality |

**No component may override ASTRA's authority.**

## 3.8 Top-K Is Not Answer

A critical distinction that must be maintained:

```text
candidate generation
       ↓
SPEAR / relevance ranking
       ↓
Top-K candidates
       ↓
ASTRA verification
       ↓
proof + provenance + context
       ↓
ANSWER / UNKNOWN / CONFLICT / ...
```

If Top-K drops a needed candidate due to budget:
→ Emit `SEARCH_INCOMPLETE`, not `UNKNOWN`.

`Candidate Top-K ≠ ANSWER`. Scores do not substitute for proof.

## 3.9 Epistemic Transition Rules (Q-eval and K-promote)

Two machines. Do not mix their outputs.

```text
K-promote: knowledge-CANDIDATE → VERIFIED | REJECTED | CONFLICTED
           (never emits query status ANSWER)

Q-eval:    QueryRecord + active store → StructuredResult.status
           (GOAL: how CANDIDATE + EVIDENCE becomes ANSWER)
```

`K-promote VERIFY ≠ query ANSWER`. A later Q-eval may emit `ANSWER` from a newly
promoted fact only after generation commit.

### 3.9.1 Q-eval priority (first match wins)

```text
PROTOCOL_FAULT          → not an ASTRA status (CRC_ERROR/SEQ_GAP/TIMEOUT/…)
DATA_INTEGRITY_FAIL     → pack/generation/integrity contract failed
                          (also SPEAR `k_invalid=1`; FEM `COMMITTED_CORRUPT`)
PARSE_ERROR             → host adapter only (status 0x80); FPGA must not emit
UNSUPPORTED_QUERY       → operator/relation/direction outside contract
SEARCH_INCOMPLETE       → budget/hop/frontier ended before completeness
                          (also SPEAR TIE-R0 overflow). Never ANSWER/CONFLICT/UNKNOWN
                          once incompleteness is declared, even if hits already exist.
CONFLICT                → ≥2 distinct verified (answer_ref, value payload) pairs
                          in a **complete** scope
ANSWER                  → exactly one verified answer_ref (or diamond paths
                          that collapse to the same answer_ref) + valid proof
UNKNOWN                 → scope complete, no verified support
```

Locked plurality rule: distinct verified `answer_ref` values in the same query
scope are `CONFLICT` (cannot be lawfully collapsed). Multiple proofs of the
**same** `answer_ref` remain `ANSWER`.

### 3.9.2 Guards

| Rule | Guard | Status | reason_code |
|---|---|---|---|
| Q-INT | `integrity_ok=0` or query generation ≠ active generation (unless generation=0) | `DATA_INTEGRITY_FAIL` | `PACK_CRC` / `STALE_GENERATION` |
| Q-KINV | C SPEAR observable `k_invalid=1` (ranking bind illegal vs profile/`K_soft`) | `DATA_INTEGRITY_FAIL` | `K_INVALID` `0x23` |
| Q-DESC | SPEAR `invalid_count>0`, or in-scope record/header kind/count/CRC/schema disagreement | `DATA_INTEGRITY_FAIL` | `INVALID_DESCRIPTOR` `0x55` |
| Q-FEM-CRC | FEM recovery: COMMIT present and prototype CRC invalid (`COMMITTED_CORRUPT`, `integrity_fault=1`) | `DATA_INTEGRITY_FAIL` | `COMMITTED_CORRUPT` `0x56` |
| Q-UNSUP | `op_class=UNSUPPORTED` or relation unimplemented | `UNSUPPORTED_QUERY` | `OPERATOR_UNIMPLEMENTED` |
| Q-DIR | `direction=REV` and relation not reverse-legal | `UNSUPPORTED_QUERY` | `DIRECTION_ILLEGAL` |
| Q-INC-BUDGET | `search_budget=0` or posting/frontier work exceeds budget before completeness | `SEARCH_INCOMPLETE` | `BUDGET_EXHAUSTED` `0x20` |
| Q-INC-TIE | C SPEAR observable `TIE_OVERFLOW_BEYOND_K_HARD` (TIE-R0) is true | `SEARCH_INCOMPLETE` | `TIE_OVERFLOW` `0x22` |
| Q-CONFLICT | ≥2 distinct verified `(answer_ref, value)` pairs after complete scoped retrieval | `CONFLICT` | `DISTINCT_VERIFIED_REFS` `0x30` + non-zero `conflict_ref` |
| Q-ANS | exactly one verified answer_ref; `proof_ref≠0` always; provenance present if required | `ANSWER` | `VERIFIED_SUPPORT` |
| Q-UNK-CAND | only non-`VERIFIED` support (`CANDIDATE`/`OBSERVATION`/`EPISODE`), scope complete | `UNKNOWN` | `CANDIDATE_ONLY` |
| Q-UNK-CTX | specific context, no matching verified edge, scope complete | `UNKNOWN` | `CONTEXT_INCOMPATIBLE` |
| Q-UNK-ABSENT | complete scope, zero verified support | `UNKNOWN` | `NO_VERIFIED_SUPPORT` |
| Q-PROV | proof/provenance required and missing/unresolvable | `UNKNOWN` | `PROVENANCE_MISSING` |

Knowledge-`CANDIDATE` / `OBSERVATION` / `EPISODE` records **cannot** be the sole
support for `ANSWER`. Only `VERIFIED` support may.

Walker/posting/frontier truncation (charged work hit `search_budget` before
declared scope closed) is `SEARCH_INCOMPLETE` / `BUDGET_EXHAUSTED`. Completeness
means the **declared query scope** (postings + hop bound + context), not “we
looked at every graph edge in DDR”. Once incompleteness is declared, Q-eval
**must not** continue to `ANSWER`, `CONFLICT`, or polite `UNKNOWN`, even if
some hits or paths were already collected.

SPEAR **clean** Top-K cutoff (no TIE-R0 overflow) is inspection order only. It
is not a completeness failure. `K = min(K_soft, K_hard)` is C’s ranking
parameter after a **legal bind**; B does not invent a separate
`tie_count > K_HARD` predicate. `K_soft` is not a QueryRecord field.
Ownership of `search_budget → K_soft` and of `K_hard` is [§03.11] [§04.13].

TIE-R0 [§10.7.6]: C sets `TIE_OVERFLOW_BEYOND_K_HARD` when a boundary tie
exists (`score[K]==score[K+1]`) and `|above|+|T| > K_hard`. Widen-all-of-`T`
when it fits `K_hard` is **not** incomplete. When the overflow observable is
true, ASTRA emits primary status `SEARCH_INCOMPLETE` (`0x04`) with
`reason_code` `TIE_OVERFLOW` (`0x22`) and `completeness=PARTIAL`. Never emit
`0x22` as `status`. Never `ANSWER`, never `CONFLICT`, never `UNKNOWN`.
C’s truncated `admitted` prefix is not a complete query scope. SPEAR scores
do not become truth. If SPEAR was not invoked, `tie_overflow` /
`invalid_count` are **N/A**, not 0.

`invalid_count` is C’s observable. R0.1 ASTRA fail-closes: `invalid_count>0`
→ primary status `DATA_INTEGRITY_FAIL` (`0x06`) with `reason_code`
`INVALID_DESCRIPTOR` (`0x55`). Never emit `0x55` as `status`. Never `UNKNOWN`
and never auto-promote. Kind/count/CRC/schema disagreement on the **record/header**
is also Q-DESC. Generation mismatch on a candidate is **not** Q-DESC (C treats
it as a valid feature). Q-DESC is integrity-class and is evaluated **before**
incomplete. C exposes the condition; ASTRA owns the emitted status [this
section].

`k_invalid` is C’s SPEAR-bind observable. R0.1 ASTRA fail-closes:
`k_invalid=1` → primary status `DATA_INTEGRITY_FAIL` (`0x06`) with
`reason_code` `K_INVALID` (`0x23`) and `completeness=NOT_APPLICABLE`.
Never emit `0x23` as `status`. Never `ANSWER`, never `UNKNOWN`, never
`SEARCH_INCOMPLETE` as a polite substitute. Bind failure is judged
**before** ranking observables (`invalid_count` / TIE-R0). If SPEAR was
not invoked, `k_invalid` is **N/A**, not 0. C exposes the condition;
ASTRA owns the emitted status [this section] [§03.11].

FEM `COMMITTED_CORRUPT` is C’s recovery observable: COMMIT mark/magic
present and prototype CRC invalid, with `integrity_fault=1`. R0.1 ASTRA
fail-closes: primary status `DATA_INTEGRITY_FAIL` (`0x06`) with
`reason_code` `COMMITTED_CORRUPT` (`0x56`) and
`completeness=NOT_APPLICABLE`. Never emit `0x56` as `status`. Never
`UNKNOWN`. The object is **not** a valid committed prototype: it is not
`COMMITTED_NEW`, must not retire raw evidence, and must not feed FEM
features as if CRC-good. If FEM recovery was not invoked, the observable
is **N/A**, not 0. C exposes the condition; ASTRA owns the emitted status
[this section].

Wire `status==0x00` is an uninitialized/protocol fault, never a lawful ASTRA
status and never coerced to `UNKNOWN` or `CONFLICT`. Pack-loader `OK=0x00` is
not a query status [§04.6]. `PARSE_ERROR` `0x80` is adapter-only; FPGA must
not emit it.

### 3.9.3 Field coupling

| Status | completeness | answer_kind | proof_ref | conflict_ref |
|---|---|---|---|---|
| `ANSWER` | `COMPLETE` | ≠ `NONE` | ≠ 0 | 0 |
| `UNKNOWN` | `COMPLETE` | `NONE` | 0 allowed | 0 |
| `SEARCH_INCOMPLETE` | `PARTIAL` | `NONE` | 0 | 0 |
| `CONFLICT` | `COMPLETE` | `NONE` | optional | ≠ 0 |
| `UNSUPPORTED_QUERY` | `NOT_APPLICABLE` | `NONE` | 0 | 0 |
| `DATA_INTEGRITY_FAIL` | `NOT_APPLICABLE` | `NONE` | 0 | 0 |

`txn_id` and used `generation` must echo. Protocol faults never become `UNKNOWN`.

Numeric encodings for `status` / `reason_code` / `answer_kind` / `completeness`
are locked in [§04.12]. The executable gold is `verification/fe256/fe256_gold.py`.

### 3.9.4 K-promote (not a query status)

```text
inputs:  CANDIDATE record + provenance + existing verified set
guards:  certified promotion contract only (score/frequency/teacher/reward
         are never sufficient by themselves)
output:  VERIFIED | REJECTED | CONFLICTED + generation commit yes/no
query StructuredResult.status = N/A
```

Teacher/sensor/self-experience still create `CANDIDATE` only [§03.5].

## 3.10 Reward Delivery Law (B-RUNTIME-LAW-01)

Q* consumes `reward_accepted`. It does **not** assert it. ASTRA
`StructuredResult.status` is **not** a reward (`ASTRA status != reward`
[§10.5]). SPEAR scores are not rewards.

Authoritative causal chain:

```text
Q* pending proposal
  -> legal/accepted action          [§03] [§05]
  -> executed PrimitiveCommand      (command_id produced)
  -> ObservedEffect / readback
  -> Reward Gate asserts reward_accepted
  -> Q* credit / learner update
```

**Causal identity** (existing action-lane fields; no second identity):

```text
(episode_id, step_id, command_id, generation)
```

These are the fields already required on `ObservedEffect` and produced by
`PrimitiveCommand` [§01.7] [§05.6]. Do not invent a competing reward-id.

**Who asserts `reward_accepted=1`:** the **action-lane Reward Gate**
(B-owned protocol object; wired outside Q*). Q* is a consumer. The Gate
may set `reward_accepted=1` only after **all** of the following have
already succeeded:

1. Exactly one outstanding pending proposal exists for this Q* instance.
2. That pending identity equals the executed command identity
   `(episode_id, step_id, command_id, generation)`.
3. `exec_valid=1`: a `PrimitiveCommand` was issued and ran.
4. `ObservedEffect` cites the same `command_id` **and** episode/step
   [§05.6]; `ObservedEffect.accepted=1` (not `EFFECT_UNOBSERVED`).
5. Reward source is a legal source under [§10.5] (teacher requires
   teaching policy + pending identity).
6. Mode is credit-eligible (`TRAIN`). `EXAM` does not assert
   `reward_accepted=1` for a learner update.

If any check fails, `reward_accepted` remains 0 and the learner must not
update.

**Idempotency:** the same causal key must cause **at most one** learner
update. Credit resolution **consumes** the pending proposal. A later
presentation of the same key is refused (`DUPLICATE`); it must not
reapply theta/policy. C implements the consume/refuse; B owns this law.

**One outstanding proposal:** R0.1 allows **exactly one** outstanding
pending Q* proposal per learner instance. A new proposal while one is
still pending is overwrite → **observable/refused**, not silent replace.
C’s proposed local machine (one pending; credit consumes it; duplicate
cannot reapply; overwrite observable/refused) is **compatible** with this
protocol. C owns learner RTL. B does not implement it.

Expected-vs-observed compare is for **credit only**. It cannot override
ASTRA or authorize a command [§01.7].

## 3.11 K_soft / K_hard bind (B-RUNTIME-LAW-01)

`QueryRecord.search_budget` [§04.3] is the only wire budget. It is
**walker/posting/frontier work**, not Top-K.

| Name | Owner | Source | Numeric map |
|---|---|---|---|
| `search_budget` | B (ABI field) | QueryRecord [§04.3] | frozen 16-bit field |
| `K_soft` | B owns validation law; **C derives** at SPEAR bind | derived from `search_budget` | **not frozen** (immature; no fake formula) |
| `K_hard` | A profile property; **D wires**; **C consumes** | same loaded board/knowledge-pack profile as `ACTIVE_ID_RANGE` [A `K_HARD_PROFILE_OWNER` / §02.4.1b] | A does **not** freeze the integer |

Validation occurs at **SPEAR bind**, before ranking and before ASTRA
consumes SPEAR observables. After a legal bind, C may compute
`K = min(K_soft, K_hard)` [§10.7.6]. Clamping `K_soft > K_hard` through
that min is **not** `k_invalid`.

`search_budget=0` remains Q-INC-BUDGET → `SEARCH_INCOMPLETE` /
`BUDGET_EXHAUSTED`. It does not require SPEAR and is not `k_invalid`.

Invalid bind (C sets `k_invalid=1`) includes, without inventing a
`K_soft` formula:

- SPEAR invoked and `K_hard==0`, or `K_hard` exceeds the loaded profile
  capacity / implementation max;
- SPEAR invoked and derived `K_soft` is not in `1..K_hard` for a reason
  other than the legal min-clamp (unrepresentable, zero from a non-zero
  budget, or profile `K_HARD` unavailable);
- profile `K_HARD` missing when SPEAR is invoked.

Mapping: Q-KINV [§03.9.2]. C exposes; ASTRA emits.

## 3.12 Action-precheck (before CapabilityBinding / executor)

Action-precheck is a **second ASTRA machine**, not Q-eval [§03.9] and not
the Reward Gate [§03.10]. It certifies legality of `ACTION_INTENT` +
resolved `CapabilityDescriptor` + `safety_contract` **before**
`CapabilityBinding` commit and **before** the Primitive Executor [§01.7]
[§05.1] [§05.5].

```text
Q*/Skill/HUMAN_DEMO ACTION_INTENT
  -> ActionResolution + installed CapabilityDescriptor lookup
     (non-actuating; no PrimitiveCommand)
  -> ASTRA legality + safety_contract precheck     ← this section
  -> CapabilityBinding (BOUND | deny)
  -> PrimitiveCommand
  -> Primitive Executor
  -> ObservedEffect / readback
```

Lookup may precede ASTRA. ASTRA must see the candidate descriptor and
`safety_contract_ref`. Lookup is not a binding and not a command. Safety
is not a second authority that can approve what ASTRA denied.

**Inputs (A names):** `ACTION_INTENT`, resolved `CapabilityDescriptor`,
`safety_contract` / `safety_contract_ref` [§01.7.1] [§05.2].

**Precheck / binding results** (architecture statuses [§20.5.1]; **not**
`StructuredResult.status` `0x01–0x06`):

| Result | Meaning | Next |
|---|---|---|
| `BOUND` | post-ASTRA binding commit after precheck pass | command **may** be issued |
| `ASTRA_DENY` | ASTRA rejected legality of intent+descriptor | `NO_ACTION` |
| `SAFETY_VETO` | ASTRA-admissible `safety_contract` fail; not a second approver | `NO_ACTION` |
| `STALE_DESCRIPTOR` | version/generation/integrity mismatch | `NO_ACTION` |
| `NO_BINDING` | no compatible installed capability/primitive/instance | `NO_ACTION` |

`NO_BINDING` is a lookup/capability miss. It is not an ASTRA query status
and not a substitute for `SAFETY_VETO`.

`SAFETY_VETO` is **not** `UNKNOWN`, **not** `ANSWER`, **not** `CONFLICT`,
**not** `SEARCH_INCOMPLETE`, **not** `DATA_INTEGRITY_FAIL`. Do not collapse
it into Q-eval primary status.

Action-precheck verdicts must not reuse query primary status `0x01–0x06`.
Numeric freeze of actuation statuses is B-owned and is **not** packed on
Query/Result/`SemanticEvent` UART [§04.13]. Reason bytes `0x22` / `0x23` /
`0x30` / `0x55` / `0x56` remain Q-eval `reason_code` only; they are never
action-precheck status and never query `status`.

**Credit chain** (A [§01.7] [§05.6]; B Reward Gate [§03.10] consumes it):

```text
proposal ≠ legal acceptance ≠ execution ≠ observed effect
  ≠ reward acceptance ≠ credit update
```

Precheck pass is **not** execution. `BOUND` is **not** a `PrimitiveCommand`.
`COMMAND_ACCEPTED` is **not** `EFFECT_OBSERVED`. `reward_accepted` is
**not** ASTRA query status. Unexecuted / `NO_ACTION` / never-issued Top-1
gets **zero** execution credit. The seven [§05.8] names are the action-path
acceptance set; [§31]/[§32] echo those names and do not stamp them PASS
here.

GEMINI / host language adapter [§01.8] cannot drive the executor.

## Tóm tắt tiếng Việt

ASTRA là authority cuối cùng cho mọi quyết định về tính hợp lệ, bằng chứng, provenance, xung đột và trạng thái tri thức. §3.9 khóa thứ tự Q-eval: integrity → unsupported → incomplete → conflict → answer → unknown. Chỉ **một** namespace status truy vấn: `0x01–0x06` (+ `0x00` bất hợp pháp, `0x80` adapter). TIE-R0 của C (không phải `tie_count > K_HARD`) → status `SEARCH_INCOMPLETE` `0x04` + reason `TIE_OVERFLOW` `0x22` (không phải status `0x22`); `invalid_count>0` → status `DATA_INTEGRITY_FAIL` `0x06` + reason `INVALID_DESCRIPTOR` `0x55` (không phải status `0x55`); `k_invalid=1` → `0x06` + `K_INVALID` `0x23`; FEM COMMIT+CRC xấu → `0x06` + `COMMITTED_CORRUPT` `0x56`. Incomplete không được thành ANSWER/CONFLICT/UNKNOWN. Chỉ VERIFIED mới ANSWER; CANDIDATE/OBSERVATION/EPISODE-only là UNKNOWN. CONFLICT dùng reason `DISTINCT_VERIFIED_REFS` `0x30`. status `0x00` là lỗi protocol. Teacher chỉ tạo CANDIDATE. §3.12 khóa action-precheck **trước** `CapabilityBinding` / executor: `ACTION_INTENT` + descriptor + `safety_contract`; `SAFETY_VETO` ≠ UNKNOWN/ANSWER/CONFLICT và không dùng status `0x01–0x06`. Proposal ≠ legality ≠ execution ≠ effect ≠ reward ≠ credit. Reward Gate (ngoài Q*) mới được assert `reward_accepted`; identity = `episode_id/step_id/command_id/generation`; cùng key chỉ một lần cập nhật; Q* một pending. `K_soft` do C suy từ `search_budget` (công thức số chưa khóa); `K_hard` từ profile A (D wiring). Encode số truy vấn nằm ở §04.12.
