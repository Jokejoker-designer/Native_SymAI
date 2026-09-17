---
version: "1.4-candidate"
base_version: "1.1-candidate"  # 1.2->1.3: A/B mailbox corrections + C-CODE-05 durability corollary + S11.13/S12.10 bit budgets
base_status: AUDITED_CANDIDATE
patch_version: "1.2"
patch_status: CANDIDATE
owner: AGENT_C
status: AUDITED_BASE_PLUS_UNAUDITED_ADDITIONS
category: SECONDARY
last_modified: "2026-09-16T12:58:00+07:00"
---

# §10 — LEARNING AND STRATEGY

> Q* macro strategy, SPEAR micro ranking, candidate generation,
> reward signals, n-step credit assignment, and the learning loop.

## 10.1 Q* — Macro Strategy Selection

Q* answers: **"What should I do next?"**

Available macro actions:

| Action | Description |
|--------|-------------|
| `RETRIEVE` | Look up known information via graph traversal |
| `SEARCH` | Broader exploration beyond immediate neighbors |
| `OBSERVE` | Sample sensor/environment state |
| `ACT` | Emit an `ACTION_INTENT` into the locked action path [§01.7, §05]; never drives an actuator itself. An unexecuted `ACT` produces no `PrimitiveCommand` and no credit [§10.8.4] |
| `ASK_TEACHER` | Request teaching (only when policy permits) [§03.6] |
| `SUBMIT` | Emit StructuredResult to host |
| `STOP` | Cease current task |

Q* learns strategy from experience. It does NOT:
- Create or modify truth
- Override ASTRA legality
- Bypass proof requirements
- Directly set learned weights in other components

## 10.2 SPEAR — Micro Ranking

SPEAR answers: **"Which candidate or target should I inspect first?"**

Within a chosen Q* macro action, SPEAR ranks candidates:
```text
candidate_list from retrieval
       ↓
SPEAR scoring (learned relevance)
       ↓
Top-K selection (bounded by budget)
       ↓
ordered inspection queue
```

SPEAR constraints:
- Score does NOT override proof legality
- Score does NOT substitute for evidence
- If Top-K drops a needed candidate → `SEARCH_INCOMPLETE` [§03.2]
- SPEAR ranking is a utility measure, NOT a truth measure
- `UTILITY ≠ TRUTH` — always
- Any future dynamics/prediction sidecar obeys `PREDICTION ≠ TRUTH`

## 10.3 Learning Loop

The core developmental learning cycle:

```text
state_before
     ↓
Q* proposes action (ACTION_INTENT)
     ↓
ASTRA precheck: legality + safety_contract, capability BOUND [§01.7, §05, §12.8]
     ↓  (ASTRA_DENY / NO_BINDING -> no PrimitiveCommand, no credit [X0-15])
action executed (PrimitiveCommand via executor, or cognitive)
     ↓
state_after observed
     ↓
typed effect extraction from state_before/action/state_after
     ↓
reward/penalty received
     ↓
EPISODE recorded (general experience memory)
     ↓
 ┌───┴────────────────────────────┐
 ↓            ↓        ↓          ↓
FEM*      Q* update  SPEAR   Skill candidate
 ↓            ↓        ↓          ↓
 └────────────┴────────┴──────────┘
 * FEM ingress only if failure policy marks the episode failure-relevant [§11]
                   ↓
        candidate relation/preference
                   ↓
        ASTRA promotion [§03.5]  (after the episode; distinct from the precheck above)
                   ↓
         verify / reject / conflict
                   ↓
           knowledge commit (if verified)
```

**Two ASTRA touch points (A echo).** ASTRA *precheck* gates the command before execution;
ASTRA *promotion* judges knowledge after the episode. Neither is performed by Q*, SPEAR, the
teacher, or the reward path. `expected_effect_schema` vs `ObservedEffect` is a credit-only
comparison [§10.6]; it cannot override ASTRA or authorize a command.

**Episode vs. FEM (C-FIX-02).** `EPISODE != FAILURE`. Every step produces an EPISODE
(general experience memory). FEM receives only failure-relevant experience, or a failure
prototype produced from eligible episodes according to the failure policy [§11.3, §11.9].
Positive/success episodes do not automatically become FEM records. Engineering/tool failures
(Vivado, Git, agent errors) are never FEM runtime cognitive records [§11.9].

## 10.4 Candidate Generation

When the system encounters missing knowledge or performs inference:

```text
Frontier_A = neighbors(A)
Frontier_B = neighbors(B)
Intersection = Frontier_A ∩ Frontier_B
```

Any node Z in the intersection is a **strong candidate** for bridging A and B.

Bidirectional search can reduce branching:
```text
A → ... → Z
B ← ... → Z
```

But intersection is ONE operator, not universal reasoning. Other queries need:
- DIRECT lookup
- REVERSE lookup
- VALUE/RANGE filter
- CONTEXT filter
- MULTIHOP traversal
- PROVENANCE check
- TEMPORAL ordering

And causal reasoning specifically requires:
- Intervention (change input, observe output)
- Ablation (remove support, observe behavior change)

Not just intersection.

## 10.5 Reward Sources

| Source | Type | Learning meaning |
|--------|------|------------------|
| Physical button / explicit evaluator | Scalar reward/penalty | Human/environment evaluation |
| UART teacher signal | Scalar shaped reward | Accepted only with pending identity and teaching policy |
| Environment/readback outcome | Outcome-derived reward candidate | Depends on verified effect/readback contract |
| Benchmark harness | Test-only reward/evaluation | Must remain distinguishable from production experience |

ASTRA verification is **not a reward source**. ASTRA returns legality/proof/promotion outcomes. A separate learner may derive a bounded training signal from a verified outcome if that mapping is preregistered, but `ASTRA status != reward`.

Reward does NOT directly create FACT. Reward updates policy/preference/skill state only under the learning contract.

## 10.6 Credit Assignment

Action credit rules:
- Action not executed/participating → receives **no causal credit**
- Credit requires exact episode/step identity plus an observed outcome/effect
- Matching expected effect may yield positive credit; mismatch/failure may yield negative or zero credit according to the preregistered reward rule
- N-step credit uses bounded returns over executed trajectories only
- Unselected SPEAR candidates receive no selected-candidate update
- Credit is a learning signal, not proof or truth

## 10.7 SPEAR Ranking Operation — Exact Structure

> Bit-level, bounded, deterministic micro-ranking. `UTILITY ≠ TRUTH`. SPEAR emits an
> ordered inspection queue for ASTRA [§03.8]; it never emits an answer, proof, or status.
> Section is unaudited CANDIDATE.

### 10.7.1 Core-loop gate declaration

```text
OBSERVATION : candidate lists from §10.4 can be large; unbounded ranking breaks the bounded-work budget [§04.3 search_budget].
UNKNOWN     : does a learned fixed-point ranking place the ASTRA-needed candidate inside the budget-bounded Top-K more often than a fixed heuristic, without leaking truth?
H_CANDIDATE : learned SPEAR score raises the needed-candidate-in-Top-K rate at fixed budget vs a static heuristic.
H_RIVAL     : a static heuristic (hop-proximity + provenance-present) ranks equally well; learning adds nothing.
FALSIFIER   : bit-exact SPEAR Top-K == static-heuristic Top-K on the preregistered holdout; OR ID-permutation/alias changes the emitted Top-K set or the downstream ASTRA status; OR freezing prior weights (learn=0) leaves the metric unchanged.
UNIT        : one independent query/holdout case. NOT N cycles of one traffic pattern (no pseudoreplication) [scientific-method-native-ai].
CONTROL     : frozen prior spear_policy_version AND the static heuristic baseline.
METRICS     : needed-candidate-in-Top-K rate, SEARCH_INCOMPLETE rate [§03.2], downstream ANSWER correctness [§31.3], DDR bytes/query [§23.2], score latency (measured post-route, not asserted).
```

### 10.7.2 Six logical reference execution stages

These are **logical reference semantics**, not a mandatory RTL pipeline. Agent D may pipeline,
fold, serialize, share arithmetic, or add registers, provided the implementation is
**bit-exact** against this reference.

```text
logical_stage_0 quantize  : CandidateDescriptor[] [§10.4] -> bounded typed feature vector f[0..F-1]
logical_stage_1 mac       : signed fixed-point dot(f, w); w = learned weights (spear_policy_version)
logical_stage_2 round/sat : accumulator -> rounded, saturated score field
logical_stage_3 select    : bounded Top-K, K <= search_budget [§04.3]
logical_stage_4 tie law   : deterministic preregistered handling of score[K] == score[K+1]
logical_stage_5 emit      : ordered inspection queue -> ASTRA [§03.8]; no answer/proof/status emitted

RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED
LATENCY            = POST_ROUTE_MEASURED [§23.2]
```

### 10.7.3 CandidateDescriptor (SPEAR input) — LEARNING_LOCAL_LAYOUT_CANDIDATE (128 bits)

**Status: `LEARNING_LOCAL_LAYOUT_CANDIDATE`.** This layout is for the learning reference
model only. It is **not** external ABI, Knowledge Pack ABI, UART ABI, persistent-storage ABI,
or §04 authority. If it is later needed across a persistent/module/external boundary, promotion
must be requested through AGENT_A/AGENT_B before it is treated as ABI. Bit widths are
ABI-versioned implementation choices, not ontology [§04.1, §04.2].

| Field | Bits | Description |
|---|---:|---|
| candidate_ref | 32 | Candidate semantic ID, 32-bit [§04.2, A02.4.1]. Defensively re-checked against the loaded profile's `active_id_max` (Arty EXAMPLE 24 significant bits — a profile value, not an identity law; A-ID-PROFILE-01) |
| source_op | 4 | Generating operator: DIRECT/REVERSE/MULTIHOP/INTERSECTION/CONTEXT/... [§10.4] |
| namespace_id | 16 | Semantic namespace [§04.3] |
| generation | 16 | Knowledge generation of the candidate [§04.6] |
| raw_meta | 40 | Packed raw metadata consumed by S1 (degree/hotness, hop_distance, provenance bit, context class, FEM-hit id, recency, conflict bit, posting-availability) |
| flags | 4 | typing / reserved |
| crc16 | 16 | CRC over descriptor |
| **Total** | **128** | 16 bytes |

### 10.7.4 Feature vector and learned weights

**CANDIDATE design, not ontology law.** `F ≤ 16` typed features; the count may be reduced,
folded, or expanded if falsification or implementation evidence requires it. Each feature is
quantized to signed `Q1.7` (8-bit, range −1.0 … +0.9921875, LSB 2⁻⁷). Each learned weight `w_i`
is signed `Q4.12` (16-bit, range −8.0 … +7.99975, LSB 2⁻¹²) and belongs to
`spear_policy_version`. SPEAR weights are **learned policy, not FACT** and are not the weights
of any other component [§03.7]. Feature *magnitude* is fixed by `logical_stage_0`; the learned
*sign/scale* lives entirely in `w_i`.

| Idx | Feature | Source | Note |
|---:|---|---|---|
| f0 | relation_type_match | relation_id vs query [§04.3] | + |
| f1 | hop_proximity = max_hops − hop_distance | §10.4 / query_meta [§04.3] | + |
| f2 | provenance_present | descriptor | + |
| f3 | context_match {0,1,2} | context_id [§04.3] | + |
| f4 | hotness/degree bucket | T1 placement [§03.7 cache] | learned sign |
| f5 | fem_penalty bucket | FailurePrototype hit [§11.5] | usually − |
| f6 | recency bucket | episode metadata [§11] | + |
| f7 | generation_ok | generation vs required [§04.6] | mismatch strongly − via w7 |
| f8 | answer_kind_affinity | query operator [§04.3] | + |
| f9 | assoc/teacher hint | sidecar [§13.6] | `PREDICTION ≠ TRUTH`, bounded |
| f10 | posting_available (fwd/rev) | index [§04.6] | + |
| f11 | value/range fit | object_ref [§04.3] | + |
| f12 | conflict_known | known-conflicted support [§03.2] | usually − |
| f13 | identity/namespace match | namespace_id [§04] | + |
| f14 | est_cost inverse | budget model [§04.3] | + |
| f15 | reserved | — | 0 |

### 10.7.5 Score arithmetic (bounded; no single-cycle-thousands claim)

**Signed Q-format width convention (R0.1).** Notation `Qm.n` means **m integer bits
including the sign bit** + **n fractional bits**, two's complement; total width = `m+n`.
There is no separate sign bit outside `m`.

```text
Q1.7  : m=1 (sign/integer), n=7  ->  8 bits total; LSB = 2^-7;  range [-1, 1-2^-7]
Q4.12 : m=4 (sign+3 mag),  n=12 -> 16 bits total; LSB = 2^-12; range [-8, 8-2^-12]
product Q1.7 × Q4.12 -> Q(1+4).(7+12) = Q5.19 in (8+16) = 24 bits  (unambiguous)
```

Reference arithmetic (bit-exact target for any implementation):

```text
prod_i = f_i (s Q1.7) * w_i (s Q4.12)            -> signed 24-bit, scale Q5.19
acc    = Σ_{i<F} prod_i                            -> signed 32-bit accumulator (Q13.19 headroom)
                                                      saturating add: clamp to [-2^31, 2^31-1]
rnd    = acc + 2^11                                -> signed bias before shift (see rounding law)
score  = sat16( rnd >>> 12 )                       -> signed 16-bit, scale Q9.7 (arith. shift)
                                                      sat16 clamps to [-32768, 32767]
```

**Rounding law (signed, deterministic).** The bias-then-ASR form is **round half toward +∞**
for *both* positive and negative `acc` (mathematical round-half-up). It is **not**
round-half-away-from-zero and **not** round-to-nearest-even. Same formula for all signs:
`score = sat16( (acc + 2^11) >>> 12 )` with arithmetic (sign-extending) right shift.
Ties at exactly `k·2^12 + 2^11` resolve toward +∞ (e.g. pre-shift −0.5 ULP → 0).

Boundary vectors for bit-exact verification (`acc` = s32 before bias; `score` = s16 after):

| Case | `acc` (dec) | `acc+2^11` | `>>>12` | `score` | Note |
|---|---:|---:|---:|---:|---|
| +exact half | 2048 | 4096 | 1 | 1 | +0.5 → +1 (toward +∞) |
| +just below half | 2047 | 4095 | 0 | 0 | |
| +just above half | 2049 | 4097 | 1 | 1 | |
| −exact half | −2048 | 0 | 0 | 0 | −0.5 → 0 (toward +∞, not −1) |
| −just below half | −2049 | −1 | −1 | −1 | |
| −just above half | −2047 | 1 | 0 | 0 | |
| +1.0 exact | 4096 | 6144 | 1 | 1 | `4096 = 1·2^12` |
| −1.0 exact | −4096 | −2048 | −1 | −1 | |
| zero | 0 | 2048 | 0 | 0 | |

Saturation is sticky per candidate: a saturated `acc` or `score` sets `sat_flag` on that
candidate's queue entry (observable, not truth).

Invalid-candidate handling (`logical_stage_0`):

```text
descriptor crc16 fail                    -> INVALID, excluded, invalid_count++
candidate_ref > profile.active_id_max    -> INVALID (ID_OUT_OF_ACTIVE_RANGE), excluded, invalid_count++
                                            defensive re-check of the loaded profile; the authoritative
                                            range checker is the T1 directory admit (A-ID-PROFILE-01)
generation != required                   -> VALID but f7 = generation_ok = 0 (learned penalty via w7)
```

K contract (fail-closed, C-CODE-07): `k_soft >= 1`, `k_hard >= 1`, `k_hard <= K_HARD_MAX`
(implementation slot capacity). Violation -> `k_invalid = 1`, `admitted_count = 0`,
`tie_overflow = 0` (no TIE-R0 claim is made on an unevaluable K). `k_soft > k_hard` is legal
(`K = min`; the min-clamp is not `k_invalid`). `K_HARD` comes from the same loaded profile (D
wires, C consumes; A does not freeze the integer). `k_invalid` is a C observable; B-RUNTIME-LAW-01
maps it to `DATA_INTEGRITY_FAIL 0x06` + reason `K_INVALID 0x23` + completeness NOT_APPLICABLE
(never ANSWER, never UNKNOWN). `QueryRecord.search_budget` is walker/posting work, not `K_soft`;
`K_soft` is derived at SPEAR bind (formula NOT FROZEN — do not invent one) and `search_budget = 0`
stays `SEARCH_INCOMPLETE / BUDGET_EXHAUSTED 0x20`, not `k_invalid`.

`invalid_count` is a **C-defined SPEAR observable** (count of excluded invalid descriptors).
SPEAR never maps an invalid candidate to `UNKNOWN`. The mapping of `invalid_count > 0` to a
final epistemic status (e.g. `DATA_INTEGRITY_FAIL` vs other) is **owned by ASTRA / AGENT_B**
[§03.2]; C does not assert that mapping here.

Sixteen candidate lanes (aligned to the 16-lane scorer [a7-native-graph-gate]) may share a
time-multiplexed DSP48E1 MAC array (240 DSP48E1 available [§23.1]) — an implementation option,
not a contract. Latency is **POST_ROUTE_MEASURED** [§23.2]; we do **not** claim a single clock
evaluates thousands of branches [PROJECT_GOAL_LOCK forbidden claims].

### 10.7.6 Top-K semantics and deterministic tie law

**Top-K semantics.** `K = min(search_budget-derived K_soft, K_hard)` [§04.3]. The Top-K is the
set of candidates with the K highest `score` values, emitted in descending score order as an
*inspection queue*. `TOP_K != ANSWER`; `UTILITY != TRUTH` [§03.8].

**Tie law TIE-R0 (preregistered, benchmark-independent).** Let scores be sorted descending
and let `score[K] == score[K+1]` (a tie straddles the boundary):

```text
T = { c : score(c) == score[K] }              # the full tied class at the boundary
if |admitted_above_tie| + |T| <= K_hard:
    admit ALL of T                            # widen; set is deterministic
else:
    TIE_OVERFLOW_BEYOND_K_HARD = true         # C condition/observable; never silently drop part of T
    # candidate status hint: SEARCH_INCOMPLETE — FINAL STATUS OWNED BY AGENT_B / ASTRA [§03.2]
```

**C owns the condition and the observable** `TIE_OVERFLOW_BEYOND_K_HARD`. Whether that
condition maps to `SEARCH_INCOMPLETE` (or another status) is **status-law confirmation owned
by AGENT_B / ASTRA**; C does not finalize that mapping here.

**Status law as confirmed by AGENT_B (consumed, not owned here; ASTRA emits):**

```text
TIE_OVERFLOW_BEYOND_K_HARD = true  -> SEARCH_INCOMPLETE / reason TIE_OVERFLOW 0x22 / completeness = PARTIAL
                                      never ANSWER, never CONFLICT, never UNKNOWN on overflow
widen-all-of-T within K_hard       -> NOT incomplete (inspection order only)
clean cutoff without TIE-R0        -> inspection order only, not SEARCH_INCOMPLETE
invalid_count > 0                  -> DATA_INTEGRITY_FAIL / reason INVALID_DESCRIPTOR 0x55 (fail-closed; integrity-class,
                                      judged before incompleteness; never UNKNOWN, never auto-promote)
generation mismatch                -> NOT invalid; remains a SPEAR feature (f13/ctx)
SPEAR not invoked                  -> tie_overflow / invalid_count are N/A, not 0
```

Implementation consequence: SPEAR observables are qualified by the finalize `done` pulse
(`rtl/native_ai/strategy/spear_rank.v`); a consumer must not read them as 0 when SPEAR did not
run. The status/reason emission itself stays in ASTRA (B).

Order *within* an admitted equal-score class is by preregistered secondary keys
`(f1 hop_proximity desc, f2 provenance_present desc, f13 namespace_match desc, arrival_seq asc)`.
`arrival_seq` is the deterministic order from candidate generation [§10.4]. Because the whole
class `T` is admitted or the overflow observable is raised, **set membership** never depends on
`arrival_seq` or any raw wire ID — this preserves X0-01 (Top-K set invariant modulo ID remap)
[§13.8, §31.7]. No benchmark-dependent tie handling is permitted.

### 10.7.7 Invariance guarantees (feed NSPF-X0 [§13.8, §31.7])

- Determinism: identical feature vectors → bit-exact identical scores and Top-K, independent
  of physical clock/spacing (X0-05) and T1 cache (X0-10).
- `UTILITY ≠ TRUTH`: a score never becomes ANSWER; `Top-K ≠ ANSWER` [§03.8].
- The association/teacher hint feature `f9` obeys `PREDICTION ≠ TRUTH` [§13.6]; a maximal hint
  cannot push past budget, override legality, or force an ASTRA status.

## 10.8 Q* Macro-Action Selection — Bit-Level Logic

> Deterministic argmax over the *legal* macro set. Q* selects strategy, never truth/proof/legality [§03.7].
> Section is unaudited CANDIDATE.

### 10.8.1 Core-loop gate declaration

```text
OBSERVATION : the wrong macro wastes budget or attempts an illegal/unbound action.
UNKNOWN     : does a learned Q-policy reach a lawful ASTRA outcome at lower budget than a fixed policy, with zero illegal selections?
H_CANDIDATE : learned Q* lowers mean budget-to-lawful-resolution vs a fixed priority policy on holdout tasks, with 0 illegal selections.
H_RIVAL     : a fixed priority policy (RETRIEVE→SEARCH→OBSERVE→…) matches it.
FALSIFIER   : learned argmax == fixed-policy choice on the holdout; OR any illegal/unbound action is selected; OR resetting learned state (X0-07) does not change behavior.
UNIT        : one independent task/episode; not cycles.
CONTROL     : frozen prior q_policy_version + fixed priority policy.
METRICS     : budget-to-lawful-resolution, illegal-selection count (must be 0), NO_BINDING/NO_ACTION correctness (X0-15).
```

### 10.8.2 Action code and legality mask

```text
action_code[2:0] : 000 RETRIEVE  001 SEARCH  010 OBSERVE  011 ACT
                   100 ASK_TEACHER 101 SUBMIT 110 STOP     111 reserved
legal_mask[7:0]  : bit a = 1 iff action a is currently legal
```

`legal_mask` is an **input** to Q*, produced by the authority/capability path — ASTRA legality
[§03] and capability binding [§12.8] — never by Q* itself. Examples: `ACT` requires a bound
capability [X0-15]; `ASK_TEACHER` requires teaching mode + policy + valid pending identity
[§03.6]. Illegal actions are masked out **before** argmax; an illegal action cannot win merely
because its Q-value is high. Encoding is a `LOGICAL_STATE_ENCODING_CANDIDATE`, not a required
physical register layout.

### 10.8.3 Q-value evaluation and macro **proposal**

```text
q_a  = dot(state_feat (s Q1.7), theta_a (s Q4.12))   per action a, signed 32-bit saturating
q_a := -INF   for a where legal_mask[a] == 0
a*   = argmax_a q_a   (tie-break among legal actions by fixed action-priority order, NOT by any data ID)
```

`a*` is a **proposal**. `theta` belongs to `q_policy_version` (learned policy, not FACT [§03.7]).
Q* creates neither truth nor legality and is not an authority layer.

### 10.8.4 Proposal, legality, execution, effect, reward, credit — distinct

```text
proposed_action      (Q* output)
 -> legal/accepted_action   (ASTRA legality + capability binding [§03, §12.8])
 -> executed_action         (Primitive Executor actually ran it [§12.8])
 -> observed_effect         (readback/episode, not predicted effect [§31.8])
 -> accepted_reward         (reward source + pending identity valid [§10.5])
 -> eligible_credit         (§10.6 credit rules)
 -> update                  (theta, q_policy_version++)
```

Invariants: `proposal != legal acceptance != execution != observed effect != reward acceptance
!= credit update`. A Top-1 proposal that was never executed receives **ZERO EXECUTION CREDIT**.

Pending-credit protocol (C-CODE-07; B-RUNTIME-LAW-01 B-01/B-02 states it is COMPATIBLE): Q* holds
**at most one unresolved pending proposal** (a TRAIN proposal with a non-empty legal set). A
proposal while one is pending is **refused** (observable `prop_refused`, counter), never a silent
overwrite of the credit context. Credit **consumes** the pending on APPLIED / NOT_EXECUTED /
EXAM_FROZEN / ILLEGAL_EXEC; REWARD_NOT_ACCEPTED keeps it pending (the Reward Gate may present a
correctly identified reward later); a resolved proposal can never be credited twice — a duplicate
presentation is `R_NO_PROPOSAL`, no reapply. EXAM and no-legal proposals create no pending.
`reward_accepted` is asserted only by the action-lane Reward Gate after: one pending, identities
equal (`episode_id, step_id, command_id, generation`), `exec_valid = 1`, `ObservedEffect.accepted =
1` citing `command_id`, legal reward source, TRAIN not EXAM. Q* consumes; it holds no proposal_id.
A rejected or unbound proposal is logged as `NO_BINDING/NO_ACTION` [X0-15] and yields no effect
credit.

### 10.8.5 Mode semantics (candidate)

```text
TRAIN : exploration allowed (preregistered ε, logged); learning state mutable
EXAM  : exploration disabled; learning state frozen; deterministic selection
        (teacher=0 external_LLM=0 learn=0 freeze=1 [a7-native-graph-gate])
```

### 10.8.6 Update rule (credit-safe)

n-step bounded TD update over the **executed** trajectory only [§10.6]; saturating fixed-point;
increments `q_policy_version`. Unselected, unexecuted, or non-participating steps receive no
credit [§10.6]. Q* never writes truth, proof, or legality [§03.7]; ASTRA is not redefined here.

## Tóm tắt tiếng Việt

Q* chọn chiến lược macro (retrieve, search, observe, act, ask teacher, submit, stop). SPEAR xếp hạng candidate trong chiến lược đã chọn — score không thay thế proof. Vòng học: state → action → effect → reward → episode → cập nhật Q*/SPEAR/FEM/Skill → ASTRA verify → commit. Intersection là một operator, không phải toàn bộ reasoning. Reward không trực tiếp tạo FACT.

§10.7 mô tả cấu trúc tham chiếu của SPEAR: 6 *logical stage* (quantize → MAC → round/sat → Top-K → tie law → emit) — không phải pipeline RTL bắt buộc; `RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED`, latency đo sau route. CandidateDescriptor 128-bit là `LEARNING_LOCAL_LAYOUT_CANDIDATE`, không phải ABI §04. Quy ước Qm.n: m gồm cả bit dấu, n là fractional, total = m+n → Q1.7×Q4.12 = Q5.19 trong 24 bit. Làm tròn signed = bias `+2^11` rồi ASR 12 (**round half toward +∞** cho cả số âm; −0.5 → 0); bảng vector biên kèm theo để bit-exact. 16 feature là thiết kế CANDIDATE. Descriptor lỗi → `invalid_count` (observable của C); ánh xạ status cuối thuộc AGENT_B/ASTRA. TIE-R0: overflow lớp tie → `TIE_OVERFLOW_BEYOND_K_HARD` (điều kiện/observable của C); status cuối (gợi ý SEARCH_INCOMPLETE) do B xác nhận. §10.8: Q* chỉ *đề xuất* macro; `legal_mask` là input từ ASTRA/capability; chuỗi proposed → legal → executed → effect → reward → credit → update; Top-1 chưa thực thi nhận ZERO EXECUTION CREDIT; TRAIN/EXAM như trên. §10.3: `EPISODE != FAILURE`. Độ trễ phải đo sau route, không tuyên bố một-clock cho hàng nghìn nhánh. `UTILITY ≠ TRUTH`, `PREDICTION ≠ TRUTH`; bề rộng bit là lựa chọn theo ABI, không phải ontology.
