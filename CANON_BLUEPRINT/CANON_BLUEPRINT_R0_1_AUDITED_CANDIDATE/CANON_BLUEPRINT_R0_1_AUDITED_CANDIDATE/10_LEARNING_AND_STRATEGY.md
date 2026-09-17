---
version: "1.1-candidate"
owner: AGENT_C
status: AUDITED_CANDIDATE
category: SECONDARY
last_modified: "2026-09-16T08:34:00+07:00"
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
| `ACT` | Execute a physical action via actuator |
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
Q* selects action
     ↓
action executed (physical or cognitive)
     ↓
state_after observed
     ↓
typed effect extraction from state_before/action/state_after
     ↓
reward/penalty received
     ↓
episode recorded [§11]
     ↓
 ┌───┴────────────────────┐
 ↓        ↓        ↓      ↓
FEM    Q* update  SPEAR  Skill candidate
 ↓        ↓        ↓      ↓
 └────────┴────────┴──────┘
                   ↓
        candidate relation/preference
                   ↓
              ASTRA [§03.5]
                   ↓
         verify / reject / conflict
                   ↓
           knowledge commit (if verified)
```

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

## Tóm tắt tiếng Việt

Q* chọn chiến lược macro (retrieve, search, observe, act, ask teacher, submit, stop). SPEAR xếp hạng candidate trong chiến lược đã chọn — score không thay thế proof. Vòng học: state → action → effect → reward → episode → cập nhật Q*/SPEAR/FEM/Skill → ASTRA verify → commit. Intersection là một operator, không phải toàn bộ reasoning. Reward không trực tiếp tạo FACT.
