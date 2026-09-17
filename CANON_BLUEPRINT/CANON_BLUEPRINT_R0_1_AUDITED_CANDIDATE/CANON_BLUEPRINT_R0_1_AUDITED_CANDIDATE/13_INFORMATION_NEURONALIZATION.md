---
version: "1.1-candidate"
owner: AGENT_C
status: AUDITED_CANDIDATE
category: SECONDARY
last_modified: "2026-09-16T08:40:00+07:00"
---

# §13 — INFORMATION NEURONALIZATION

> The core research hypothesis of Native AI.
> What "neuronalizing information" means, what it does NOT mean,
> and how to falsify or support it.

## 13.1 The Hypothesis

> **Information Neuronalization:** explicit semantic objects act as virtual
> neuron-like persistent units; typed relations act as explicit connectivity
> (semantic synapses); and sparse event-driven activation operates only on
> the currently relevant working set.

This is an **engineering abstraction**, not a claim that information literally becomes a biological neuron.

## 13.2 What It Means

| Biological Analogy | NSPF Implementation |
|-------------------|---------------------|
| Neuron | Semantic Unit — virtual, persistent, addressable typed object |
| Synapse | Typed Relation — explicit, typed edge between nodes |
| Activation | Active Frontier — current sparse set of activated nodes |
| Neural pulse | Semantic Event — logical event triggering state changes |
| Working memory | Temporary activated/bound state in T1 BRAM |
| Long-term memory | Persistent graph in T2 DDR |

## 13.3 What It Does NOT Mean

- ❌ Each fact physically maps to one neuron (LUT) — rejected as scaling strategy
- ❌ The entire knowledge base fires simultaneously — only working set activates
- ❌ FPGA "grows new LUTs" — hardware specialization requires full bitstream rebuild
- ❌ Physical clock frequency carries semantic meaning — semantic time uses logical ticks
- ❌ Jitter is part of the semantic alphabet — jitter is implementation noise
- ❌ English morphology (is/am/are) is silicon ontology — language adapter normalizes
- ❌ Noun/verb/adjective get different bit widths — TYPE, ID, ROLE are independent

## 13.4 What Makes It Different from a Graph Database

The strongest engineering baseline is not only an LLM; it is also a conventional indexed graph engine. NSPF must demonstrate value from working-state activation, learning, grounding, proof/status governance or hardware behavior beyond ordinary `load → lookup → print`.

If the system only does:
```text
load graph → lookup edge → print result
```
then it is a **hardware knowledge engine**. Useful, but not Native AI.

The strong hypothesis requires demonstrating:

| Capability | Test |
|-----------|------|
| **Masked slot reconstruction** | Hide a frame slot while keeping the supporting graph intact; reconstruct a candidate from structure |
| **ID permutation invariance** | Swap all IDs, behavior unchanged |
| **Unseen-instance transfer** | Skill learned on instance A works on new instance B |
| **Structural rule transfer** | Rules from 4-bit system transfer to 8-bit system |
| **Sensor grounding** | Concept formed from sensor data before human alias |
| **Causal ablation** | Remove supporting evidence → answer changes |
| **Reset/restore** | Clear learned state → baseline returns; restore → learned behavior returns |
| **False teacher resistance** | Teacher provides wrong info → system does not blindly accept |
| **Cache invariance** | Cache on/off → same semantic results |

If these tests PASS across preregistered holdouts, information neuronalization gains empirical support beyond lookup alone.
If the claimed transfer/grounding tests repeatedly fail and success depends on exact IDs, task-specific FSMs or host-side reasoning, the strong form of the hypothesis is materially weakened; the remaining system may still be a useful hardware knowledge/reasoning engine.

## 13.5 The Contrast with Modern AI

**[ESTABLISHED]** The contrast must not be caricatured as "LLMs have no explicit memory." Modern retrieval-augmented models combine parametric models with external memory.

The correct contrast is with **weight-centric cognition**:

| Property | Weight-Centric (LLM) | Information Neuronalization (NSPF) |
|----------|----------------------|-------------------------------------|
| Knowledge storage | Large share of capability/knowledge can be parametric; many modern systems also use external memory | Verified semantic knowledge is represented explicitly; learned policy/skill weights remain separate |
| Retrieval | Attention/association and, in retrieval-augmented systems, external retrieval | Exact directory/posting retrieval on the proof-critical path |
| Provenance | Often weak for parametric recall; external retrieval can provide source metadata | Provenance is a first-class semantic record and proof dependency |
| Update | Model updates may require fine-tuning; external stores can also update incrementally | Explicit records can update incrementally; learned policies remain separately versioned |
| Uncertainty | Probabilistic/model-specific plus application controls | Explicit epistemic status contract for supported query classes |
| Compositionality | Learned/emergent and tool-augmented | Explicit role binding + bounded operators; transfer remains a hypothesis |

**[HYPOTHESIS]** NSPF is worth developing only if it beats simpler alternatives on: causal traceability, incremental update cost, deterministic provenance, transfer across IDs/instances, memory-access efficiency for sparse queries, and bounded hardware behavior.

## 13.6 Dense Neural Models Are Not Enemies

Dense neural computation may exist at the perception/language boundary:

```text
neural output ≠ truth
```

Neural models are allowed as:
- Perception adapters (image → semantic records)
- Language adapters (text → QueryRecord, StructuredResult → text)
- Association hint generators (suggest candidates for SPEAR ranking)

Neural/predictive sidecars obey `PREDICTION != TRUTH`.

Neural models are NOT allowed as:
- Hidden truth engines
- ASTRA bypass mechanisms
- Direct knowledge creators

If useful transfer requires reintroducing a large dense model into the CORE, the strong form of the hypothesis has failed.

## 13.7 "GOAL COMPLETE" Definition

The project vision is NOT proved by:
- ❌ FPGA answers one question correctly
- ❌ LED lights up
- ❌ Bitstream programs successfully

The end-state vision becomes **eligible for a strong bounded claim** only when every required link in this chain has independent causal evidence:

```text
I HAVE NATIVE PRIMITIVES
        ↓
I CAN REPRESENT INFORMATION
        ↓
I CAN LOAD AND RETRIEVE VERIFIED KNOWLEDGE
        ↓
I CAN ACTIVATE ONLY RELEVANT WORKING STATE
        ↓
I CAN REASON WITH BOUNDED EXPLICIT PATHS
        ↓
I CAN EXPRESS UNKNOWN / CONFLICT / INCOMPLETE
        ↓
I CAN OBSERVE THE PHYSICAL WORLD
        ↓
I CAN EXECUTE A REAL ACTION
        ↓
I CAN OBSERVE ITS EFFECT
        ↓
I CAN RECEIVE EXPERIENCE / REWARD
        ↓
I CAN CREATE CANDIDATES
        ↓
I CAN LEARN A REUSABLE SKILL
        ↓
I CAN TRANSFER IT TO AN UNSEEN INSTANCE
        ↓
I CAN ASK FOR TEACHING WITHOUT MAKING TEACHER TRUTH
        ↓
I CAN REMEMBER FAILURE
        ↓
I CAN REPAIR / COMPACT / REOPEN IT
        ↓
I CAN VERIFY CLAIMS THROUGH PROVENANCE / ABLATION
        ↓
I CAN EXPLAIN WHY THROUGH A MACHINE PROOF TRACE
```

## Tóm tắt tiếng Việt

"Thần kinh hóa thông tin" (Information Neuronalization) là giả thuyết trung tâm: semantic objects như neuron ảo, typed relations như synapse, sparse activation chỉ trên working set. Đây là phép ẩn dụ kỹ thuật, KHÔNG phải tuyên bố sinh học. Giả thuyết chỉ hợp lệ nếu qua được các test: ID permutation, unseen transfer, masked slot, causal ablation, sensor grounding, reset/restore, false teacher, cache invariance. Nếu không qua → hệ thống chỉ là graph database.
