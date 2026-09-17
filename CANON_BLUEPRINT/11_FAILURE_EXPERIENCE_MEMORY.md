---
version: "1.4-candidate"
base_version: "1.1-candidate"  # 1.2->1.3: A/B mailbox corrections + C-CODE-05 durability corollary + S11.13/S12.10 bit budgets
base_status: AUDITED_CANDIDATE
patch_version: "1.2"
patch_status: CANDIDATE
owner: AGENT_C
status: AUDITED_BASE_PLUS_UNAUDITED_ADDITIONS
category: SECONDARY
last_modified: "2026-09-16T12:55:00+07:00"
---

# §11 — FAILURE EXPERIENCE MEMORY (FEM)

> Typed runtime failure experience, compaction, regression reopening, and repair linkage.
> FEM is part of the DUT's developmental memory. It is not the developer project issue tracker.

## 11.1 Purpose

FEM answers:

> What failed before, under what context, what repaired it, how often did it recur, and did it regress?

Locked separation:

```text
FACT != SKILL != EPISODE != FAILURE != WEIGHT
FAILURE_RECORD != NEGATIVE_FACT
SEMANTIC_CONFLICT != FAILURE by default
```

A valid `CONFLICT` result may be correct epistemic behavior; it becomes a FEM failure only
if the experiment contract says the system mishandled conflict or the conflict itself caused an
execution failure.

## 11.2 FailureRecord R0.1

```text
FailureRecord {
  failure_id
  episode_id
  step_id
  logical_tick
  domain
  stage
  capability_id
  capability_class
  capability_instance
  macro_action
  primitive_action
  candidate_id
  skill_id
  skill_version
  expected_effect
  observed_effect
  error_code
  reward_value
  reward_source
  state_signature
  action_signature
  effect_signature
  q_policy_version
  spear_policy_version
  capability_manifest_version
  knowledge_generation
  source_mode
  crc
}
```

`source_mode` distinguishes, for example:

```text
AUTONOMOUS
HUMAN_DEMO
UART_TEACHER
BOARD_TEST
BENCHMARK_HARNESS
```

Reward is evaluation metadata, not truth.

## 11.3 Typed Failure Key

Do not cluster by raw text or exact episode ID. Candidate prototype key:

```text
hash(domain,
     stage,
     capability_class,
     macro_action_class,
     primitive_class,
     effect_class,
     context_bucket)
```

The purpose is transferable failure memory while preserving enough context to avoid global
blacklisting of one isolated instance.

## 11.4 Lifecycle

```text
RAW_FAILURE
 -> repeated typed match
CLUSTERED_FAILURE
 -> corrective behavior succeeds
RESOLVED_FAILURE
 -> stable success window
COMPACTED_EXPERIENCE
 -> recurrence
REOPENED_FAILURE
```

A first failure need not immediately form a prototype.

## 11.5 FailurePrototype

```text
FailurePrototype {
  prototype_id
  prototype_key
  domain
  stage
  capability_class
  action_class
  effect_class
  first_seen_episode
  last_seen_episode
  last_failure_episode
  failure_total
  failure_recent
  success_after_repair
  regression_count
  unresolved
  compacted
  repair_skill_id
  repair_skill_version
  exemplar_refs[small_k]
  mean_recovery_steps
  mean_failure_cost
  version
  crc
}
```

Counters should saturate or widen explicitly; silent wrap is forbidden.

## 11.6 Atomic Compaction

Compaction is storage optimization, not deletion of history without evidence.

Required commit order:

```text
build prototype summary
 -> write target T2 record
 -> verify integrity/CRC
 -> mark COMMITTED
 -> update index
 -> only then retire eligible raw records
```

A power/reset interruption must not lose both the raw evidence and its replacement prototype.

## 11.7 Regression Reopen

When a compacted failure pattern reappears:

```text
new typed failure
 -> exact/prototype match
 -> REOPENED
 -> regression_count++
 -> repair skill/version re-evaluated
```

Regression must not silently mutate the original evidence record.

## 11.8 FEM Authority Boundary

FEM may provide features/signals to Q*, SPEAR, curriculum selection, and Skill Memory.

FEM may **not**:

- select final action on its own;
- override Q* or SPEAR;
- override ASTRA legality/proof/status;
- promote semantic truth;
- let a host inject winner/weight delta;
- reinterpret a hardware safety-limit state as a failure-memory truth object.

## 11.9 Engineering Failure vs DUT Failure

Vivado failures, documentation errors, CI failures, or agent mistakes belong in project evidence,
issue tracking, and the audit changelog. They do **not** automatically become runtime FEM data.
Only failures deliberately captured from the DUT/runtime experiment through the defined ingress
belong in FEM.

## 11.10 Acceptance

Minimum FEM gate:

```text
CAPTURE_CAUSAL = PASS
CLUSTER_TYPED = PASS
SEPARATION_BY_STAGE = PASS
COMPACTION_NO_DATA_LOSS = PASS
REGRESSION_REOPEN = PASS
ASTRA_AUTHORITY_PRESERVED = PASS
HOST_SEMANTIC_AUTHORITY = 0
PERSIST/RESTORE = PASS when claimed
```

## 11.11 FailureRecord Lifecycle — Formal Transitions & Bit-Level State

> Makes §11.4 executable: a single 3-bit lifecycle state per FailurePrototype [§11.5], with
> explicit triggers, guards, and counter effects. Section is unaudited CANDIDATE.

### 11.11.1 Lifecycle state field — LOGICAL_STATE_ENCODING_CANDIDATE

**Status: `LOGICAL_STATE_ENCODING_CANDIDATE`.** The semantic lifecycle and transition legality
below are the contract; the 3-bit code assignment is a proposal only. Agent D is **not**
required to use this exact physical register encoding. State names are the canonical §11.4
names, unchanged.

```text
life_state[2:0] : 000 RAW_FAILURE
                  001 CLUSTERED_FAILURE
                  010 RESOLVED_FAILURE
                  011 COMPACTED_EXPERIENCE
                  100 REOPENED_FAILURE
                  101..111 reserved
```

`life_state` lives on the FailurePrototype [§11.5]. A raw FailureRecord [§11.2] carries no
lifecycle state of its own; it is evidence that a prototype clusters, and is only retired by
the atomic protocol in §11.6 / §11.12.

### 11.11.2 Transition table

| From | To | Trigger | Guard | Counter effect |
|---|---|---|---|---|
| (none) | RAW_FAILURE | first typed capture via defined ingress [§11.9] | valid identity + context [§11.2] | `failure_total=1`, `failure_recent=1` |
| RAW_FAILURE | CLUSTERED_FAILURE | repeated typed-key match [§11.3] | ≥ threshold matches; same stage bucket [§11.10 SEPARATION_BY_STAGE] | `failure_total++`, `failure_recent++` (saturating) |
| CLUSTERED_FAILURE | RESOLVED_FAILURE | corrective behavior succeeds | `repair_skill_id` bound + verified success [§12.2] | `success_after_repair++`, `failure_recent→0` decay |
| RESOLVED_FAILURE | COMPACTED_EXPERIENCE | stable success window | atomic compaction complete [§11.6, §11.12] | `compacted=1`, raw retired only after COMMIT |
| COMPACTED_EXPERIENCE | REOPENED_FAILURE | recurrence, exact/prototype match [§11.7] | new typed failure matches compacted key | `regression_count++`, `unresolved=1` |
| REOPENED_FAILURE | RESOLVED_FAILURE | re-evaluated repair succeeds | new `repair_skill_version` verified | `success_after_repair++`; original evidence unchanged [§11.7] |

Guards are one-directional: a valid `CONFLICT` is not a failure transition unless the
experiment contract says so [§11.1]. Engineering/CI/Vivado failures never enter this machine
[§11.9].

### 11.11.3 Counter bit-level

Counters (`failure_total`, `failure_recent`, `success_after_repair`, `regression_count`,
`mean_recovery_steps`, `mean_failure_cost`) are unsigned saturating fields; exact widths are
ABI-versioned implementation choices [§04.1]. **Silent wrap is forbidden** — a counter either
saturates at its max or is explicitly widened by an ABI change [§11.5].

### 11.11.4 Deduplication, compaction trigger, and retirement

**Deduplication** is by the typed failure key [§11.3], never by raw text or exact episode ID:

```text
new FailureRecord
 -> key = hash(domain, stage, capability_class, macro_action_class, primitive_class, effect_class, context_bucket)
 -> exact key match to an existing prototype  -> attach as exemplar (or bump counters if exemplar_refs full)
 -> no match                                  -> new RAW_FAILURE (no prototype yet [§11.4])
```

Two records with the same key but different `episode_id/step_id` are **distinct evidence of
one prototype**, not duplicates; the identity fields [§11.2] are kept on each raw record.

**When compaction runs** — all guards must hold (preregistered thresholds, learning-local):

```text
life_state == RESOLVED_FAILURE
AND success_after_repair >= N_stable          (stable success window)
AND failure_recent == 0 over the window
AND no open REOPENED prototype with the same key
```

**When raw records are retired** — only after the compaction transaction reaches
`COMMITTED_NEW` [§11.12.3]; retirement keeps `exemplar_refs[small_k]` [§11.5] as recoverable
evidence. Raw failure evidence is **never deleted** without a committed prototype replacing it,
and `REOPENED` never mutates or deletes the original evidence [§11.7]. There is no other
deletion path; FEM has no "forget" primitive in R0.1.

## 11.12 Compaction Crash-Safety Falsifier

> Extends the §11.6 commit order into a preregistered interruption test. Section is unaudited CANDIDATE.

### 11.12.1 Invariant

At every step boundary of the §11.6 sequence, **at least one** recoverable representation
exists — raw evidence intact, or prototype committed-and-indexed — and **exactly one of them is
authoritative**; authority changes only at the atomic COMMIT write (§11.12.3). Both may
physically coexist (B3–B5). The pair `{raw_present, prototype_committed}` must **never** be
`{false, false}`; the index may point to the prototype only once it is committed.

### 11.12.2 Core-loop gate declaration

```text
OBSERVATION : compaction retires raw records to reclaim T2; a reset/power-cut mid-sequence risks losing history.
UNKNOWN     : does the §11.6 commit order actually survive an interruption at every step boundary?
H_CANDIDATE : for any single interruption point, either raw-intact OR prototype-committed-and-indexed holds (never neither).
H_RIVAL     : some interruption window loses both (invariant violated).
FALSIFIER   : an injected reset between "mark COMMITTED" and "retire raw" that leaves the index pointing at a not-yet-durable prototype while raw is already retired.
UNIT        : one injected-interruption trial at one step boundary (independent) — repeated cuts at one boundary are ONE unit, not many (no pseudoreplication).
CONTROL     : clean run with no interruption (baseline integrity).
METRICS     : per-boundary {raw_present, prototype_committed} (never {false,false}); CRC pass rate; index consistency. Maps to §11.10 PERSIST/RESTORE and §31.7 X0-07.
```

Required order is unchanged from §11.6: build summary → write T2 → verify CRC → mark
COMMITTED → update index → only then retire eligible raw records.

### 11.12.3 Commit-state observables (behavior, not ABI)

A compaction transaction must be observably in exactly one of three states after any
interruption; this is a **required observable behavior**, and defines no §04 wire/pack field:

```text
OLD_VALID       : raw records present and indexed; no prototype, or prototype not yet COMMITTED
                  -> restart discards any partial prototype; raw remains authoritative
CANDIDATE_NEW   : prototype written, CRC verifiable, NOT marked COMMITTED, index still -> raw
                  -> restart may finish or discard; raw remains authoritative
COMMITTED_NEW   : prototype marked COMMITTED and index -> prototype, prototype CRC verifies
                  -> raw records now eligible for retirement; prototype authoritative
```

**FEM_DEST_INTEGRITY — a separate namespace, not a fourth compaction state** (A-C-14,
A-D-INTEG-01 [A §02.4.1c, §20.1]; B-RUNTIME-LAW-01 B-05). The compaction class above stays
exactly three values and `commit_state[1:0]` (§11.13 W9) is compaction-only. Destination
integrity is a **parallel observable**:

```text
dest COMMITTED_CORRUPT : COMMIT magic present AND destination prototype CRC invalid
                         (post-commit media damage; dest re-read, never FIFO-empty)
  -> integrity_fault = 1 ; compaction class NOT_APPLICABLE
  -> fail closed: NO roll-forward, NO index upgrade to COMMITTED_NEW, NO raw retirement, nothing written
  -> consumers must never read it as OLD_VALID, COMMITTED_NEW, ANSWER or UNKNOWN
  -> ASTRA mapping (B-owned): DATA_INTEGRITY_FAIL 0x06, reason COMMITTED_CORRUPT 0x56,
     completeness NOT_APPLICABLE
```

Dest COMMITTED_CORRUPT is unreachable under the local word-atomic, no-post-write-corruption T2
model and is exercised only by injected corruption (`fem_ref.run_corrupt`, TB "CORRUPT" units).
The durable-media protocol (DDR via MIG, torn physical beats, dest readback = completion,
`t2_ready` stall) is AGENT_D-owned (D-INTEG-01); C's FSM freezes on `t2_ready = 0` and is
stall-invariant (TB `+STALL=1`).

Boundary interruption schedule (each is one UNIT for §11.12.2):

```text
B0 before build | B1 after T2 write | B2 after CRC verify | B3 after COMMITTED mark
B4 after index update | B5 during raw retirement | B6 after retirement
```

Pass observable at every `Bn`: recovery lands in exactly one of the three named compaction
states (or reports dest COMMITTED_CORRUPT via `integrity_fault` under injected damage), `{raw_present,
prototype_committed} != {false,false}`, and a re-run of the same query against FEM features
[§10.7.4 f5] yields the same value as the uninterrupted control. **Durability corollary
(found by C-CODE-05 at B0):** every prototype field that a lifecycle transition sets
(`repair_skill_id`, `repair_skill_version`, key, counters) must be written through to durable
storage at that transition, not first materialized by compaction — otherwise a cut before the
prototype write (B0–B2) rolls back to a RESOLVED state whose re-committed prototype differs from
the control. Reference: `ref/learning/fem_ref.py` (`HDR`/`HDR2` write-through words). Learning-local sequencing
identifiers used to tell these states apart are `LEARNING_LOCAL_LAYOUT_CANDIDATE`; if they must
cross a persistent boundary, promotion is requested through A/B [§04].

## 11.13 Candidate Bit Budgets — FAILURE records are not NodeRecord-256

> `LEARNING_LOCAL_LAYOUT_CANDIDATE`. FailureRecord / FailurePrototype are their own record kinds
> (`FAILURE`), never overloaded onto NodeRecord or NCG tables. Widths below are a proposal for D;
> any field that must cross a persistent/ABI boundary is promoted through A/B [§04]. EPISODE
> records are temporal records owned by §01.4 / §02 (T2 episodes), not by FEM.

**FailureRecord (raw evidence) — 128 bits / 4 words**

| Word | Field(s) | Bits |
|---|---|---|
| W0 | `episode_id` | 32 |
| W1 | `step_id[31:16]`, `typed_key[15:0]` | 16 + 16 |
| W2 | `stage[3:0]`, `capability_class[3:0]`, `action_class[2:0]`, `effect_class[3:0]`, `context_bucket[2:0]`, `domain[1:0]`, `valid`, pad | 4+4+3+4+3+2+1+11 |
| W3 | `crc16[15:0]`, `version[7:0]`, pad | 16 + 8 + 8 |

**FailurePrototype — 320 bits / 10 words** (alignment to a physical burst is D's choice)

| Word | Field(s) | Bits |
|---|---|---|
| W0 | `prototype_id` | 32 |
| W1 | `prototype_key[15:0]`, `stage[3:0]`, `capability_class[3:0]`, `action_class[2:0]`, `effect_class[3:0]`, pad | 16+4+4+3+4+1 |
| W2 | `first_seen_episode` | 32 |
| W3 | `last_seen_episode` | 32 |
| W4 | `last_failure_episode` | 32 |
| W5 | `success_after_repair[7:0]`, `failure_recent[7:0]`, `failure_total[7:0]`, `regression_count[2:0]`, `compacted`, `unresolved`, `life_state[2:0]` | 8+8+8+3+1+1+3 (= `HDR` word in `fem_ref.py`) |
| W6 | `repair_skill_id[7:0]`, `repair_skill_version[7:0]`, `mean_recovery_steps[7:0]`, `mean_failure_cost[7:0]` | 8+8+8+8 |
| W7 | `exemplar_ref[0][15:0]`, `exemplar_ref[1][15:0]` (`small_k = 2`; raw-record slot refs) | 16 + 16 |
| W8 | `exemplar_ref[2][15:0]`, `exemplar_ref[3][15:0]` | 16 + 16 |
| W9 | `crc16[15:0]`, `version[7:0]`, `commit_state[1:0]` (OLD_VALID / CANDIDATE_NEW / COMMITTED_NEW), pad | 16+8+2+6 |

Counters are saturating; `life_state` codes per §11.11.1. The single-prototype T2 word map used
by the C-CODE-05 candidate (`HDR`, `HDR2`, `W0/W1/CRCW`, `COMMIT`, `INDEX`, `RAW[i]`) is a test
layout of the same fields, not a second ABI.

## Tóm tắt tiếng Việt

FEM là bộ nhớ kinh nghiệm thất bại của chính Native AI, không phải nơi ghi lỗi phát triển
project. Failure được capture có identity, context, action/effect, version; lặp lại thì cluster,
sửa ổn định thì compact, tái phát thì reopen. FEM không phải FACT và không được vượt quyền
ASTRA/Q*/SPEAR.

§11.11 hình thức hóa lifecycle thành máy trạng thái 3-bit (`life_state`) với bảng chuyển
trạng thái RAW → CLUSTERED → RESOLVED → COMPACTED → REOPENED kèm trigger, guard, và tác động
counter; counter bão hòa, cấm wrap âm thầm, bề rộng theo ABI. §11.12 biến thứ tự commit ở §11.6
thành test crash-safety có prereg: bất biến là cặp `{raw_present, prototype_committed}` không bao
giờ được `{false,false}` tại mọi ranh giới bước; ánh xạ sang PERSIST/RESTORE và X0-07 [§31.7].
