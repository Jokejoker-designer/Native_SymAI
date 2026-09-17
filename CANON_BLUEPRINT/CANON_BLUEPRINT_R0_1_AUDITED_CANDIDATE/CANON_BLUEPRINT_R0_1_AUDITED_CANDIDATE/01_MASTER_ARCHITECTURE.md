---
version: "1.1-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:27:00+07:00"
---

# §01 — MASTER ARCHITECTURE

> Core dual-plane architecture of the Native Semantic Pulse Fabric (NSPF).
> This document defines the top-level information flow, authority partition,
> and the relationship between all major subsystems.

## 1.1 Design Decision

**[SUPPORTED]** Native Semantic Pulse Fabric (NSPF) is technically plausible as a **bounded cognitive substrate** in which explicit semantic units, typed relations, bindings, events and state transitions are persistent/activatable objects, while only a sparse working frontier is active at a time.

The defensible proposition is **not** "replace neural networks." The target is:

> Use exact, typed, addressable information as the persistent cognitive substrate; use event-driven sparse activation and bounded retrieval/reasoning over that substrate; reserve dense/approximate neural computation for optional perception, association or language boundaries when it provides measurable benefit.

## 1.2 End-State Architecture

```text
                HUMAN / PHYSICAL WORLD
                         │
          ┌──────────────┴──────────────┐
          │                             │
 LANGUAGE ADAPTER                SENSOR ADAPTER
          │                             │
          └──────────────┬──────────────┘
                         ▼
            QUERY / SEMANTIC EVENT BUS
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
 BINARY SEMANTIC                   TEMPORAL EVENT
     PLANE                             PLANE
 ID/REL/VALUE                    EVENT/STATE/ACTION
 CTX/PROV                        TICK/DURATION/REWARD
        │                                 │
        └────────────────┬────────────────┘
                         ▼
                T1 WORKING MEMORY
        Query / Goal / Bindings / Context
             Active Frontier / Cache
                         │
                         ▼
                 EXACT DIRECTORY
                         │
                  T1 HIT │ MISS
                      ┌──┴──┐
                      ▼     ▼
                    BRAM   DDR
                           T2
                            │
                     posting pages
                            │
                            ▼
          BOUNDED RELEVANCE-GUIDED WALKER
             ┌────────┼─────────────┐
             ▼        ▼             ▼
           direct   reverse      multihop
                     │
          optional intersection
                     │
                     ▼
            candidate generation
                     │
                   SPEAR
                   Top-K
                     │
                     ▼
            value/context checks
             provenance/conflict
             causal constraints
                     │
                     ▼
                   ASTRA
                     │
      ┌──────────────┼────────────────────┐
      ▼              ▼                    ▼
   ANSWER         UNKNOWN              CONFLICT
SEARCH_INCOMPLETE / UNSUPPORTED / INTEGRITY_FAIL
                     │
                     ▼
             STRUCTURED RESULT
                     │
                     ▼
                  GEMINI
                     │
                     ▼
                   HUMAN
```

## 1.3 Binary Semantic Plane

Persistent typed records representing stable knowledge:

| Record Type | Contents |
|------------|----------|
| **Node** | Stable ID, KIND, CLASS, STATE, generation |
| **Edge** | Source ID, relation type, destination ID, context, provenance |
| **Value** | Typed payload (numeric, enum, composite) |
| **Context** | Spatial, temporal, conditional scope |
| **Provenance** | Origin (teacher, sensor, inference), timestamp, confidence |

Key invariant: meaning is separated from human-language representation. Node IDs are stable binary identifiers; human strings are aliases attached via NAMED_AS edges.

## 1.4 Temporal Event Plane

Dynamic records representing experience and change:

| Record Type | Contents |
|------------|----------|
| **Event** | Logical tick, event type, references |
| **State Transition** | Before/after state, trigger |
| **Action** | Operator, parameters, target |
| **Observation** | Sensor source, value, timestamp |
| **Reward/Penalty** | Source, magnitude, context |
| **Episode** | Ordered sequence of events/actions/effects |

Semantic time uses explicit logical ticks, not physical FPGA clock. Clock frequency and jitter are implementation noise, not semantic identity.

## 1.5 Working Mind

The active cognitive process combining:

| Component | Function | Reference |
|-----------|----------|-----------|
| **NCG** (Native Cognitive Graph) | Exact retrieval via directory/posting lookup | [§02] |
| **Q*** | Macro strategy selection: retrieve, search, observe, act, ask teacher, submit, stop | [§10] |
| **SPEAR** | Ranking legal candidates or targets within chosen strategy | [§10] |
| **Skill Engine** | Executing reusable verified procedures | [§12] |
| **FEM** | Failure Experience Memory — typed failure, recovery, regression detection | [§11] |

## 1.6 Authority Partition

This partition is **locked** and must not be violated:

| Layer | Authority | Question It Answers |
|-------|-----------|-------------------|
| **Q*** | Macro strategy | "What should I do next?" |
| **SPEAR** | Candidate/target ranking | "Which candidate should I inspect first?" |
| **Skill Engine** | Procedure execution | "How do I execute this reusable procedure?" |
| **FEM** | Failure memory | "What failed before, how was it repaired?" |
| **ASTRA** | Legality, proof, status, promotion | "Is this legal? Is evidence adequate? Any conflict?" |
| **GEMINI** | Human expression | "How do I express the structured result to a human?" |

**No layer may usurp the authority of another.**

Critical rules:
- Host truth/proof authority = 0. The host may perform frozen alias/intent/unit normalization and construct QueryRecord IDs, but cannot inject answer, winner, proof, provenance, or hidden graph reasoning.
- Q* chooses macro action, not truth.
- SPEAR ranks, does not override proof legality.
- Score does not override proof legality.
- GEMINI expresses results but does not create truth and does not drive actuators directly.
- Teacher does not write weights directly.
- Candidate, episode and failure memory do not self-promote to verified fact.
- `SEARCH_INCOMPLETE != UNKNOWN`.

## 1.7 Physical Action / Capability Boundary

Semantic reasoning never drives an actuator directly. The physical action path is:

```text
Q*/Skill ACTION_INTENT
  -> ASTRA legality/safety precheck
  -> Capability Binding
  -> verified Primitive Executor
  -> physical hardware action
  -> readback / observed effect
  -> Temporal Event / Episode
```

A `CapabilityDescriptor` identifies what the installed hardware can actually do. If a semantic
action has no compatible capability binding, no physical action is issued. This boundary prevents
knowledge-pack semantics or GEMINI text from becoming direct electrical control. See [§05].

## 1.8 Human Language Boundary

```text
Human:
"Máy lạnh này dùng gas gì?"
            ↓
HOST LANGUAGE ADAPTER
            ↓
subject_id
relation_id
query_op
context
            ↓
QueryRecord
            ↓
UART
            ↓
FPGA (reasoning)
            ↓
StructuredResult
status = ANSWER
answer_ref = R32_ID
proof_ref = ...
            ↓
HOST LANGUAGE ADAPTER
            ↓
"Máy sử dụng R32."
```

The host adapter may:
- Map "RAC_WALL" → node ID
- Map "uses refrigerant" → relation ID

The host adapter **must not**:
- Directly produce "R32" as the answer (bypassing FPGA reasoning)

This is the boundary that prevents cheating.

## 1.9 Sensor Boundary

Sensors provide the path to native meaning formation:

```text
Sensor readings: 31°, 45°, 62°, 75°
→ STATE observations
→ Experience (state_before, action, effect, state_after)
→ Candidate concept C_8734
→ Human later attaches: alias(C_8734) = "hot"
```

**[HYPOTHESIS]** If the alias changes ("nóng", "hot", "高温"), grounded internal relations should remain unchanged. This is a critical falsification test [§31], not an established property until demonstrated.

## 1.10 What Is Novel

**[ESTABLISHED]** No individual ingredient is new. Semantic networks, CAM, sparse distributed memory, VSA/HDC, production systems, external neural memory, event-driven neuromorphic routing, graph accelerators and event sensors all provide relevant precedent.

**[HYPOTHESIS]** The potentially distinctive combination is:

```text
exact typed semantic identity
+ explicit context/provenance
+ verified/candidate/episode/skill separation
+ sparse logical-event activation
+ causal proof/status authority
+ FPGA-native bounded graph/event execution
+ causal falsification by ablation/permutation/reset/clock invariance
```

Novelty must be treated as **unproven** until a dedicated patent/literature search is completed [§21].

## 1.11 Design Choices Locked in R0

- Semantic identity uses stable ID; grammatical/contextual use carried by ROLE.
- KIND, CLASS, STATE, ROLE, STATUS are independent fields.
- Human strings are aliases, not hardware identity.
- 6W1H may be a compact query-operator algebra, not an English ontology.
- Logical semantic ticks carry order/time meaning; FPGA clock rate does not.
- Jitter is verification noise unless represented explicitly as data.
- Long-term knowledge is virtualized in DDR/HBM; one circuit per semantic unit is rejected.
- BRAM is a managed hot/working store, not a truth tier.
- Promotion across memory tiers changes placement, not epistemic status.
- ASTRA remains the authority for legality, proof, conflict, completeness and promotion.
- Semantic action intent must pass capability binding and verified primitive execution before any actuator command.
- Prediction/association may propose candidates but never establishes truth.

## Tóm tắt tiếng Việt

Kiến trúc NSPF gồm hai mặt phẳng: Binary Semantic Plane (tri thức tĩnh: node, edge, value, context, provenance) và Temporal Event Plane (sự kiện động: state, action, reward, episode). Working Mind kết hợp NCG + Q* + SPEAR + Skill + FEM. ASTRA là authority cuối cùng cho mọi proof/status/promotion. Ngôn ngữ tự nhiên chỉ là adapter — không phải substrate nhận thức. Mỗi layer có authority riêng, không được xâm phạm layer khác.
