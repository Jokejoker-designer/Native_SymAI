---
version: "1.3-candidate"
base_version: "1.1-candidate"  # 1.2->1.3: A/B mailbox corrections + C-CODE-05 durability corollary + S11.13/S12.10 bit budgets
base_status: AUDITED_CANDIDATE
patch_version: "1.2"
patch_status: CANDIDATE
owner: AGENT_C
status: AUDITED_BASE_PLUS_UNAUDITED_ADDITIONS
category: SECONDARY
last_modified: "2026-09-16T12:55:00+07:00"
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
| Working memory | Working state — a **logical cognitive class**; T1 is only its typical *placement* |
| Long-term memory | Persistent verified graph — a **logical class**; T2 is only its typical *canonical storage* |

The left column is analogy vocabulary only. "Working memory" and "long-term memory" are **not**
implementation names, not identities of T1 BRAM / T2 DDR, and not record kinds [§20.3]; the
implementation names are the §02 tiers and the §04 record kinds.

**Orthogonality (C-FIX-01).** Cognitive class and memory tier are independent axes:

```text
LOGICAL COGNITIVE CLASS  ×  PHYSICAL MEMORY TIER
{working state, FACT, SKILL, EPISODE, FAILURE, learned weight}  ×  {T1 BRAM, T2 DDR, ...}

PHYSICAL_PLACEMENT != EPISTEMIC_CLASS
FACT cached in BRAM remains FACT
SKILL stored in DDR remains SKILL
```

T1/T2 describe candidate placement, caching, or canonical storage only [§02]; they never
define what a record *is*. BRAM/DDR name physical placement, not epistemic or cognitive class.

## 13.3 What It Does NOT Mean

- ❌ Each fact physically maps to one neuron (LUT) — rejected as scaling strategy
- ❌ The entire knowledge base fires simultaneously — only working set activates
- ❌ FPGA "grows new LUTs" — hardware specialization requires full bitstream rebuild
- ❌ Physical clock frequency carries semantic meaning — semantic time uses logical ticks
- ❌ Jitter is part of the semantic alphabet — jitter is implementation noise
- ❌ English morphology (is/am/are) is silicon ontology — language adapter normalizes
- ❌ Noun/verb/adjective get different bit widths — KIND, CLASS, ID, ROLE are independent axes
  (KIND is the record kind [§04]; CLASS is semantic class; neither substitutes for the other)

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
I CAN EXPRESS UNKNOWN / CONFLICT / SEARCH_INCOMPLETE   (three distinct statuses [§03.2]; SEARCH_INCOMPLETE is not a synonym of UNKNOWN)
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

## 13.8 Learning-Side NSPF-X0 Preparation

> Prep only. The NSPF-X0 suite is defined and owned in §31.7 (X0-01..X0-15). This section
> declares the learning-side preconditions, reset scope, controls, and units those tests require
> from Q* [§10.8], SPEAR [§10.7], FEM [§11] and Skill [§12], so §31.7 is runnable without
> redefining it here. Section is unaudited CANDIDATE.

### 13.8.1 Reset scope (TRAIN-V2)

Reset = **learned state only**: `q_policy_version` weights (θ) [§10.8.3], `spear_policy_version`
weights (w) [§10.7.4], FEM prototypes/counters [§11.5, §11.11], and CANDIDATE/LEARNED skill
records [§12.2]. Verified FACT, knowledge packs, ABI, and RTL are **not** reset. The frozen prior
model is kept as the control [a7-native-graph-gate TRAIN-V2].

### 13.8.2 Unit-of-analysis rule

Every X0 metric counts **independent** holdout cases/episodes. N cycles replaying one traffic
pattern is ONE unit, not N (no pseudoreplication) [scientific-method-native-ai]. XSim evidence
is never reported as board evidence [§31.1].

### 13.8.3 Learning-side mapping matrix (references §31.7; does not restate its contract)

Pass thresholds, vector truth, and falsifier authority remain in §31.7. Columns: C-owned
mechanism · learner state · reset scope · control · observable · expected causal dependency ·
forbidden shortcut.

| X0_ID | C-owned mechanism | Learner state | Reset scope | Control | Observable | Expected causal dependency | Forbidden shortcut |
|---|---|---|---|---|---|---|---|
| X0-01 | SPEAR Top-K + TIE-R0 [§10.7.6] | w | none | same w, unpermuted IDs | Top-K set; ASTRA status | depends on features, not raw IDs | raw-ID tiebreak |
| X0-04 | SPEAR f-vector [§10.7.4] | w | none | pack with support | Top-K; status | support removal changes Top-K/status | cached winner; score-as-answer |
| X0-05 | `logical_stage_0..5` [§10.7.2] | w | none | nominal spacing | score, Top-K (bit-exact) | none on timing | timing-dependent arithmetic |
| X0-07 | θ, w, FEM prototypes, CANDIDATE/LEARNED skills | all learned | §13.8.1 only | frozen prior model | behavior A/B [§31.8] | reset→A; restore→B | reset that also clears FACT/pack |
| X0-08 | grounding stages [§12.7] | skill, FEM | learned only | pre-alias run | internal relation; effect evidence | survives alias rename | alias as identity |
| X0-09 | teacher flow [§12.5], anti-parrot [§12.6] | θ, w (via reward only) | none | no-teacher run | record status; θ/w delta | proposal stays CANDIDATE; no direct θ/w write | teacher→FACT, weight, proof, winner |
| X0-10 | SPEAR determinism [§10.7.7] | w | none | cache off | score, Top-K | none on cache | cache-resident answer |
| X0-11 | class/param binding [§12.3] | skill | none | instance A | success on unseen B | follows capability/effect class | literal-ID script |
| X0-12 | Q* + skill, shortcut disabled [§10.8, §12.2] | θ, skill | none | literal-table baseline | holdout success at 8/16-bit | exceeds table/script | primitive shortcut re-enabled |
| X0-13 | f7 generation_ok [§10.7.4] | w | none | valid pack | result | depends on active pack | ROM/hard-coded answer |
| X0-14 | invalid/generation gating [§10.7.5] | w | none | fresh generation | result | stale gen has no influence | stale T1 entry reuse |
| X0-15 | Q* legal_mask input [§10.8.2] | θ | none | bound capability | NO_BINDING/NO_ACTION; zero actuation | unbound → no action | Q* self-issued legality |

### 13.8.4 Controls and metrics

Control = frozen prior policy/model + (where relevant) a static heuristic baseline. Metrics are
preregistered **before** the run; changing gold/threshold/case selection to rescue a candidate is
forbidden [§31.9]. A learned-state claim requires the W0→W1→reset→restore evidence pattern
[§31.8]; a predicted effect never substitutes for readback [§13.6].

### 13.8.5 Theoretical grounding — why X0-07 and X0-09 bear on the hypothesis

**X0-07 Reset/Restore.** The hypothesis [§13.1] separates explicit verified knowledge from
learned policy/skill state (`FACT != SKILL != WEIGHT`). If that separation is real, then
resetting *only* the learned classes [§13.8.1] must return baseline behavior while every FACT
answer stays identical, and restoring them must return the learned behavior. Two failure modes
each falsify a different claim: (a) reset changes FACT answers → learned state was secretly
carrying truth (weight-centric leakage); (b) reset does **not** change learned behavior → the
"learning" was hard-coded FSM/script, not learned state. The frozen prior model is the control
[a7-native-graph-gate TRAIN-V2].

**X0-09 False Teacher.** The hypothesis requires that teacher input creates CANDIDATE, never
FACT/weight/proof [§03.5, §12.4]. Observables are the record's epistemic status and the θ/w
deltas [§10.7.4, §10.8.3]: a false or rephrased proposal must leave verified support intact,
remain CANDIDATE/REJECTED/CONFLICT, and produce **no** direct θ/w write — reward is the only
teacher→learner channel [§10.5], and it is bounded by pending identity. Verbatim-text dependence
(anti-parrot [§12.6]) would show the system learned a string, not a relation. A pass supplies
*bounded* support; it does not prove general cognition [§31.7].

## Tóm tắt tiếng Việt

"Thần kinh hóa thông tin" (Information Neuronalization) là giả thuyết trung tâm: semantic objects như neuron ảo, typed relations như synapse, sparse activation chỉ trên working set. Đây là phép ẩn dụ kỹ thuật, KHÔNG phải tuyên bố sinh học. Giả thuyết chỉ hợp lệ nếu qua được các test: ID permutation, unseen transfer, masked slot, causal ablation, sensor grounding, reset/restore, false teacher, cache invariance. Nếu không qua → hệ thống chỉ là graph database.

§13.8 chuẩn bị phía học cho bộ NSPF-X0 (được định nghĩa và sở hữu ở §31.7): phạm vi reset chỉ
gồm trạng thái đã học (θ của Q*, w của SPEAR, prototype/counter của FEM, skill CANDIDATE/LEARNED);
đơn vị phân tích là case/episode độc lập (cấm pseudoreplication); và bảng ánh xạ từng cơ chế sở
hữu sang test X0 tương ứng (X0-01/04/05/07/08/09/10/11/12/13/14/15). Control là model đóng băng
trước đó; metric phải prereg, cấm đổi gold để cứu candidate. §13.8.3 là ma trận ánh xạ (cơ chế ·
trạng thái học · phạm vi reset · control · observable · phụ thuộc nhân quả · shortcut bị cấm), tham
chiếu §31.7 chứ không sao chép luật pass. §13.8.5 giải thích vì sao X0-07 (reset chỉ trạng thái
học phải trả về baseline mà FACT không đổi) và X0-09 (teacher chỉ tạo CANDIDATE, không ghi θ/w
trực tiếp) là phép thử trực tiếp cho giả thuyết. §13.2 đã sửa: lớp nhận thức logic × tầng bộ nhớ
vật lý là hai trục độc lập; `PHYSICAL_PLACEMENT != EPISTEMIC_CLASS`.
