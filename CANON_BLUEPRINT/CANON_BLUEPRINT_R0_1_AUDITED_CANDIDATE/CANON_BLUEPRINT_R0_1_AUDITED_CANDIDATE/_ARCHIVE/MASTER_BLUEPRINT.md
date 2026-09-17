# MASTER BLUEPRINT — NATIVE INFORMATION NEURONALIZATION R0

> Concatenated view of the numbered design documents. Individual files remain the easier review/edit units.

# 00 — EXECUTIVE SUMMARY

## 0.1 Decision

**[SUPPORTED]** Native Semantic Pulse Fabric (NSPF) is technically plausible as a **bounded cognitive substrate** in which explicit semantic units, typed relations, bindings, events and state transitions are persistent/activatable objects, while only a sparse working frontier is active at a time.

The defensible proposition is **not** “replace neural networks.” The target is narrower:

> Use exact, typed, addressable information as the persistent cognitive substrate; use event-driven sparse activation and bounded retrieval/reasoning over that substrate; reserve dense/approximate neural computation for optional perception, association or language boundaries when it provides measurable benefit.

## 0.2 Architecture in one diagram

```text
HUMAN / SENSOR / ENVIRONMENT
            |
            v
ADAPTERS / EVENT ABSTRACTION
            |
   +--------+--------+
   |                 |
   v                 v
BINARY SEMANTIC   TEMPORAL EVENT
PLANE             PLANE
ID/REL/VALUE      EVENT/STATE/ACTION
CTX/PROV          TICK/DURATION/REWARD
   |                 |
   +--------+--------+
            v
      WORKING MIND
 NCG + Q* + SPEAR + SKILL + FEM
            |
            v
          ASTRA
 proof / legality / status / promotion
            |
            v
    STRUCTURED RESULT
            |
            v
 HUMAN LANGUAGE ADAPTER
```

## 0.3 What is novel enough to test

**[ESTABLISHED]** No individual ingredient is new: semantic networks, CAM, sparse distributed memory, VSA/HDC, production systems, external neural memory, event-driven neuromorphic routing, graph accelerators and event sensors all provide relevant precedent.

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

Novelty must be treated as **unproven** until a dedicated patent/literature search is completed.

## 0.4 Design choices locked in R0

- Semantic identity uses stable `ID`; grammatical/contextual use is carried by `ROLE`.
- `KIND`, `CLASS`, `STATE`, `ROLE`, `STATUS` are independent fields.
- Human strings are aliases, not hardware identity.
- 6W1H may be a compact query-operator algebra, not an English ontology.
- Logical semantic ticks carry order/time meaning; FPGA clock rate does not.
- Jitter is verification noise unless represented explicitly as data.
- Long-term knowledge is virtualized in DDR/HBM; one circuit per semantic unit is rejected.
- BRAM is a managed hot/working store, not a truth tier.
- Promotion across memory tiers changes **placement**, not epistemic status.
- ASTRA remains the authority for legality, proof, conflict, completeness and promotion.

## 0.5 Recommended implementation sequence

1. Keep Full Evidence FE256 as the verified static semantic baseline.
2. Implement a fixed semantic/event ABI and a bounded active-frontier engine.
3. Run `NSPF-X0`: role binding + masked slot + timing perturbation + causal ablation.
4. Only after X0 passes, integrate sensor grounding and parameterized skill transfer.
5. Scale graph size only after DDR access, cache behavior and proof cost are measured.
6. Move to HBM only when profiling shows memory bandwidth/parallel random access is the actual bottleneck.

## 0.6 Critical success criteria

NSPF earns a stronger claim only if behavior survives representational perturbations while remaining causally dependent on its true support:

```text
ID permutation      -> semantics preserved
alias replacement   -> semantics preserved
physical timing gap -> semantics preserved
support edge removal-> answer changes
reset W0            -> baseline returns
restore W1          -> learned behavior returns
```

If the system instead reduces to a manually curated knowledge graph plus task-specific FSMs, or hidden host/LLM reasoning is required for every useful composition, the strong “information neuronalization” hypothesis has failed.

---

# 01 — RESEARCH HYPOTHESIS

## 1.1 Information neuronalization definition

**[HYPOTHESIS]**

> **Information neuronalization** is the representation of explicit semantic units as individually addressable persistent computational objects; typed relations behave as semantic synapses; current cognition is a sparse activation/binding state over those objects; temporal experience is an ordered event stream; learning modifies candidate relations, skills, preferences and policy state without silently changing verified truth.

A semantic unit is virtual, not one physical neuron circuit:

```text
SemanticUnit := {ID, KIND, CLASS, STATE, FLAGS, INDEX_PTRS, PROVENANCE_REF}
SemanticEdge := {SRC, RELATION, DST/VALUE, CONTEXT, STATUS, PROVENANCE_REF}
Activation_t := sparse set of active IDs + bindings + frontier entries
```

## 1.2 Claims

**[SUPPORTED]** This architecture can plausibly provide:

- exact identities and typed relations;
- bounded sparse graph retrieval;
- deterministic provenance/proof paths;
- explicit epistemic states (`ANSWER`, `UNKNOWN`, `CONFLICT`, `SEARCH_INCOMPLETE`);
- incremental update of explicit knowledge without retraining a dense model;
- event-driven working memory over persistent semantic records;
- causal tests that can identify hidden shortcuts.

**[HYPOTHESIS]** It may additionally provide useful structural transfer, grounded concept formation and reusable skill induction. Those are experimental claims, not design truths.

## 1.3 Non-claims

This blueprint does **not** claim:

- AGI, consciousness or human-level cognition;
- that neural networks are unnecessary;
- that all perception can be solved symbolically;
- that graph traversal is intrinsically faster than Transformers;
- that binary representation itself creates intelligence;
- that 6W1H is a universal ontology;
- that event-driven operation automatically saves energy;
- that explicit semantics solve the symbol-grounding problem.

## 1.4 Baselines

### LLM baseline

**[ESTABLISHED]** Transformers and language models use learned parametric representations; retrieval-augmented systems add explicit non-parametric memory. The relevant comparison is therefore **weight-centric cognition vs explicit semantic memory**, not “LLM has no memory.”

### Graph baseline

**[ESTABLISHED]** Indexed graph databases and graph accelerators already provide explicit nodes/edges, postings, traversal and sometimes provenance. NSPF must show value beyond renaming a graph database “neurons.”

### Neuromorphic baseline

**[ESTABLISHED]** TrueNorth, Loihi and SpiNNaker show that sparse event-driven communication and time-multiplexed logical neurons can be efficient. They do not establish exact semantic identity/proof as a cognitive authority.

## 1.5 Falsifiable central hypothesis

NSPF is worth keeping only if, on bounded workloads, it demonstrates some combination of:

```text
lower incremental update cost
+ deterministic provenance
+ bounded causal reasoning
+ transfer across raw IDs/aliases
+ sparse memory-access advantage
+ sensor-grounded concept stability
```

versus a conventional indexed graph engine and a fair small-model baseline.

---

# 02 — PRIOR ART AND NOVELTY

## 2.1 Research rule

**[ESTABLISHED]** No novelty claim is allowed from this blueprint alone. This file maps technical neighborhoods that must be compared before any patent or research novelty statement.

## 2.2 Sparse distributed memory

Kanerva-style Sparse Distributed Memory establishes that high-dimensional patterns can be stored/recalled from distributed locations using partial/noisy cues. Relevance: associative fallback and similarity. Limitation: exact typed provenance and deterministic factual identity are not native.

## 2.3 CAM / associative memory

FPGA CAM/BCAM prior art establishes exact key-to-value lookup in hardware and RAM-backed associative structures. Relevance: hot semantic directory, alias map, visited set. Limitation: CAM solves lookup, not graph reasoning, binding, causality or proof.

## 2.4 VSA / HDC

Vector Symbolic Architectures and Hyperdimensional Computing establish distributed high-dimensional representation, binding, bundling and noise tolerance. Relevance: optional candidate association or compositional sidecar. Limitation: approximate similarity must not become truth authority.

## 2.5 SPA / Nengo

Semantic Pointer Architecture and Nengo/Spaun establish that structured cognitive representations, working memory and action selection can coexist in neural/spiking systems. NSPF must compare variable binding and compositionality against SPA rather than assume the territory is new.

## 2.6 NTM / DNC

Neural Turing Machines and Differentiable Neural Computers establish learned access to external memory. Relevance: controller + memory separation. Difference: NSPF favors exact typed lookup/status/provenance over differentiable addressing for the truth path.

## 2.7 ACT-R / Soar

Production/cognitive architectures establish explicit working memory, long-term memory, goals, procedures and rules. Risk: NSPF can collapse into a re-labeled expert system. Required counter-evidence: unseen-instance transfer, ID permutation, masked composition and sensor grounding.

## 2.8 SNN / neuromorphic

TrueNorth, Loihi, SpiNNaker and related systems establish sparse event routing, local state and online learning. Relevance: event fabric and scalable routing. Difference: NSPF events carry typed semantic references and explicit proof/status rather than spike-only meaning.

## 2.9 Graph accelerators

FPGP, Graphicionado, ScalaBFS and related designs establish bounded frontier traversal, memory-system specialization and HBM scaling for irregular graphs. Relevance: NCG/Full Evidence walker. Limitation: memory randomness, hub vertices and proof construction remain bottlenecks.

## 2.10 Event sensors

Dynamic/event-based vision sensors demonstrate sparse asynchronous physical events. Relevance: sensor input to Temporal Event Plane. Limitation: raw events are not semantic concepts; grounding/abstraction remains a separate problem.

## 2.11 Patent map — representative technical zones

The research report identified representative prior art around:

- FPGA-integrated CAM and RAM-backed CAM engines;
- distributed event-based neuromorphic computation;
- external neural memory;
- VSA/associative lookup mechanisms.

**[SUPPORTED]** A formal novelty/FTO study should search claims around the *combination* of typed semantic records + event activation + proof authority + hardware caching/specialization, not merely the individual ingredients.

## 2.12 Novelty boundary

Not novel by itself:

```text
concepts stored in memory
events sent as pulses
graph traversal on FPGA
associative lookup
vector binding
working vs long-term memory
```

Potential research contribution:

```text
exact semantic object model
+ explicit epistemic classes
+ dual semantic/event planes
+ sparse activation
+ FPGA causal proof boundary
+ hardware placement stratification
+ causal promotion/falsification discipline
```

## 2.13 Reference anchors from the Deep Research report

- Vaswani et al. — *Attention Is All You Need*.
- Lewis et al. — Retrieval-Augmented Generation.
- Kanerva — Sparse Distributed Memory.
- Kleyko et al. — VSA/HDC frameworks and hardware.
- Eliasmith/Nengo/Spaun — Semantic Pointer Architecture.
- Graves et al. — NTM and DNC.
- ACT-R and Soar official cognitive-architecture literature.
- IBM TrueNorth; Intel Loihi; SpiNNaker.
- FPGP, Graphicionado, ScalaBFS.
- AMD HBM/DDR BCAM.
- Harnad — Symbol Grounding Problem.
- Schölkopf et al. — Causal Representation Learning.

---

# 03 — CORE DOCTRINE

## 3.1 Meaning vs representation

**[ESTABLISHED within project]** Bits and IDs are representation, not meaning. Meaning is carried by stable identity plus typed relations, context, observed effects and provenance.

```text
ALIAS != IDENTITY
NUMERIC_ID != MEANING
BIT_WIDTH != SEMANTIC_CLASS
```

Therefore the rejected design is:

```text
noun = 6-bit namespace
verb = 8-bit namespace
adjective = 10-bit namespace
```

The accepted design is:

```text
ID        = stable addressable identity
KIND      = semantic kind
CLASS     = ontology/capability class
ROLE      = contextual binding
STATE     = lifecycle/epistemic state
```

## 3.2 Persistent information vs activation

Persistent records live in the Binary Semantic Plane. Cognition is a transient sparse activation state over those records.

```text
persistent knowledge != current thought
stored edge          != activated edge
verified fact        != selected candidate
```

## 3.3 Truth vs utility

Q*, SPEAR, cache hotness, success counters and failure penalties express utility/preference, not truth.

```text
utility_score cannot promote fact
access_frequency cannot verify fact
reward cannot override legality
candidate rank cannot override conflict
```

ASTRA remains the authority for legality, proof, status, completeness and knowledge promotion.

## 3.4 Human-language boundary

Human language is a codec/adapter:

```text
text -> alias/intent resolution -> QueryRecord/EventRecord
ResultRecord -> rendering -> text
```

`is/am/are`, Vietnamese morphology or another language must not become core ontology. Equivalent language expressions normalize to native semantic predicates.

## 3.5 Learned vs deterministic

Hard/frozen:

- exact codecs, arithmetic primitives, type checks;
- capability format;
- protocol invariants;
- ASTRA status/proof laws;
- safety/legality;
- identity/version/checkpoint contracts.

Learned/adaptive:

- candidate semantic associations;
- Q*/SPEAR policy state;
- skill composition;
- failure/recovery patterns;
- context-conditioned utility;
- candidate causal relations awaiting verification.

## 3.6 Hardware clock doctrine

**[FALSIFIED]** physical frequency is not semantic identity. Use explicit logical ticks/sequence IDs. Clock and transport latency may change without changing meaning.

---

# 04 — SEMANTIC UNIT MODEL

## 4.1 SemanticUnit

**[HYPOTHESIS]** Minimal canonical record:

```text
SemanticUnit {
  id              u32
  generation      u16
  namespace_id    u16
  kind            u8
  state           u8
  flags           u16
  class_id        u32
  fwd_index_ref   u32
  rev_index_ref   u32
  alias_ref       u32
  provenance_ref  u32
}
```

R0 may pack this to a 32-byte `NodeRecord`.

## 4.2 ID

- stable within `(namespace, generation)` contract;
- never inferred from human alias text;
- never silently reused while old references remain live;
- exact comparison after any hash-index lookup.

## 4.3 KIND

Candidate kinds:

```text
ENTITY AGENT ACTION STATE PROPERTY EVENT VALUE TIME LOCATION
GOAL SKILL CAPABILITY SENSOR SYMBOL FAILURE PROOF_REF
```

KIND is orthogonal to ROLE.

## 4.4 CLASS

CLASS groups transferable properties/capabilities. Examples:

```text
DIGITAL_OUT
TEMPERATURE_SENSOR
REFRIGERANT
FOOD
ROTARY_ACTUATOR
```

Transfer tests should preserve CLASS/effect schema while changing raw instance IDs.

## 4.5 STATE

Do not overload one field. Separate lifecycle/epistemic state where necessary:

```text
record_lifecycle: ACTIVE / RETIRED / TOMBSTONE
knowledge_status: CANDIDATE / VERIFIED / CONFLICTED / REJECTED
skill_status: CANDIDATE / LEARNED / VERIFIED / STABLE / REOPENED
```

## 4.6 Alias separation

```text
SELF_ID = stable native identity
HUMAN_ALIAS = optional, multilingual, versionable
SEMANTIC_ROLE = learned/contextual relation, not the alias
```

Renaming an alias must not invalidate causal/action knowledge.

## 4.7 Namespaces and generations

Recommended native identity tuple:

```text
(namespace_id, generation, local_id)
```

Cross-generation stale references must reject or explicitly migrate. Checkpoints bind schema, pack, policy, skill and capability generations.

---

# 05 — ROLE AND VARIABLE BINDING

## 5.1 Semantic kind vs contextual role

A concept has stable KIND; a frame assigns temporary ROLE.

```text
HUMAN: KIND=AGENT
Frame A: ROLE=SUBJECT
Frame B: ROLE=OBJECT
```

This prevents English grammar from becoming ontology.

## 5.2 Role enum candidate

```text
SUBJECT
PREDICATE
OBJECT
SOURCE
TARGET
CAUSE
EFFECT
INSTRUMENT
LOCATION_ROLE
TEMPORAL_ROLE
CONDITION
GOAL_ROLE
VALUE_ROLE
```

## 5.3 Binding table

Working-memory candidate:

```text
BindingEntry {
  frame_id        u16
  slot_id         u8
  role            u8
  variable_id     u16
  semantic_id     u32
  kind_constraint u8
  flags           u8
  context_id      u32
}
```

BRAM/LUTRAM stores only active bindings.

## 5.4 Variable identity

Variable IDs are local to a frame/transaction and cannot be confused with persistent SemanticUnit IDs.

```text
VAR_X != NODE_X
```

## 5.5 Frame representation

Example:

```text
Frame 17
  slot0 ROLE=SUBJECT   -> HUMAN_1
  slot1 ROLE=PREDICATE -> ?VAR_ACTION
  slot2 ROLE=OBJECT    -> APPLE_1
```

Constraint resolution can request candidate actions whose domain/range/context satisfy the frame.

## 5.6 Missing slot

`MISSING_SLOT` is an explicit condition:

```text
MISSING_SLOT(frame_id, slot_id, role, kind_constraint, context)
```

It may trigger retrieve, infer, observe, act, skill-execute, ask-teacher or return UNKNOWN. No subsystem is allowed to guess-and-promote without ASTRA verification.

---

# 06 — BINARY SEMANTIC PLANE

## 6.1 Purpose

The Binary Semantic Plane stores exact persistent semantic information. It is independent of natural-language strings and distinct from temporal activation.

## 6.2 Node

`NodeRecord` identifies a semantic unit, class, index pointers, alias/provenance references and generation.

Recommended R0 size: **32 bytes**.

## 6.3 Relation

`RelationRecord`/registry defines relation identity and constraints:

```text
relation_id
src_kind_mask
dst_kind_mask
directionality
context_policy
proof_rule
flags
```

Critical distinctions remain exact:

```text
CORRELATES_WITH != CAUSES
NAMED_AS != IS_A
ACHIEVES != PROVES
FAILED_AT != ILLEGAL
```

## 6.4 Edge

Recommended verified edge baseline:

```text
EdgeRecord {
  src_id          u32
  dst_id          u32
  relation_id     u16
  status          u8
  flags           u8
  context_ref     u32
  value_ref       u32
  provenance_ref  u32
  valid_from      u32
  valid_to        u32
}
```

Keep learned utility/counters outside verified fact edges.

## 6.5 Value

Typed values are first-class; never collapse them into entity ID zero.

```text
ValueRecord {
  value_type  u8
  flags       u8
  unit_id     u16
  lo          u32
  hi          u32
  aux_ref     u32
}
```

Supports scalar/range/enum/reference encodings.

## 6.6 Context

Context is explicit, versioned and composable. Examples: device model, environment, goal, time validity, measurement conditions.

## 6.7 Provenance

Provenance must survive caching and inference. Minimum fields:

```text
source_id
source_revision
location/span
content_digest/ref
acquisition_mode
```

## 6.8 Canonical separation

```text
VERIFIED_FACT store
CANDIDATE_FACT store
OBSERVATION store
EPISODE store
SKILL store
FAILURE store
POLICY_WEIGHT store
```

No implicit promotion across stores.

---

# 07 — TEMPORAL EVENT PLANE

## 7.1 Purpose

The Temporal Event Plane represents change, ordering, physical interaction and experience. It complements rather than replaces exact semantic identity.

## 7.2 Event

Candidate event classes:

```text
OBSERVATION
STATE_ENTER
STATE_EXIT
ACTION_ISSUED
ACTION_COMMITTED
EFFECT_OBSERVED
REWARD
FAILURE
TEACHER_DEMO
QUERY_EVENT
RESULT_EVENT
```

## 7.3 State transition

Core experience pattern:

```text
STATE_BEFORE
  -> ACTION
  -> OBSERVED_EFFECT
  -> STATE_AFTER
  -> REWARD / STATUS
```

This is the preferred teaching substrate for physical skills.

## 7.4 Duration

Duration is explicit data, not inferred from arbitrary FPGA cycles. Use logical timestamps/intervals and, when required, calibrated physical-time units.

## 7.5 BEFORE / AFTER

`BEFORE` and `AFTER` are semantic temporal relations derived from explicit event ordering, not from text word order.

## 7.6 Action/effect

An action does not imply its expected effect occurred. Physical/readback evidence must record:

```text
expected_effect
observed_effect
verification_status
```

## 7.7 Reward

Reward is scalar evaluation tied to exact episode/step identity. Reward is not truth and cannot directly set learner weights supplied by a teacher.

## 7.8 Jitter doctrine

**[FALSIFIED]** jitter is not semantic alphabet. Inject timing variation in verification; require same semantic result when logical ordering is unchanged.

---

# 08 — NATIVE SEMANTIC PULSE PROTOCOL

## 8.1 Logical ticks

Every semantic event carries `logical_tick` and `sequence_id`. Physical cycle count is debug/performance metadata only.

## 8.2 Event packet R0

Recommended **192-bit** packet:

```text
191:184 event_type
183:176 semantic_kind
175:168 role
167:160 flags
159:128 semantic_id
127:96  value_or_ref
95:64   logical_tick
63:32   context_id
31:16   source_id
15:0    sequence_id
```

## 8.3 Ordering

Ordering rules:

- same stream: monotonically increasing `sequence_id`;
- logical meaning uses `logical_tick` + frame/transaction identity;
- delayed physical arrival is legal if protocol ordering remains valid;
- reordering requires explicit reorder buffer or rejection.

## 8.4 Flow control

Use `VALID/READY` style interfaces internally. Required invariant:

```text
valid && !ready -> payload stable
```

Backpressure must be observable; FIFO overflow cannot silently become `UNKNOWN`.

## 8.5 CRC

UART/external packet framing includes magic, ABI version, type, length, sequence and CRC. Memory pages additionally carry page integrity metadata.

## 8.6 Retry / duplicate handling

Each externally committed transaction binds:

```text
session_id + txn_id + generation + sequence_id
```

Duplicate data/reward/query frames are detected explicitly. Retry may resend transport data but may not double-commit semantic updates.

## 8.7 Status on protocol fault

Examples:

```text
CRC_ERROR
STALE_GENERATION
DUPLICATE_FRAME
FIFO_OVERFLOW
SEQ_GAP
UNSUPPORTED_ABI
```

Protocol faults must not be rendered as semantic `UNKNOWN`.

---

# 09 — MEMORY ARCHITECTURE

## 9.1 Principle

Physical memory tier is a **placement decision**, not a cognitive truth class.

```text
VERIFIED_FACT may be cached in BRAM
SKILL may be hot in BRAM or cold in DDR
FAILURE remains FAILURE regardless of location
```

## 9.2 Tier model

### T0 — Immutable Semantic Control Plane

Registers/LUT/combinational/sequential logic for:

- primitive operators and exact compare;
- protocol/schema legality;
- ASTRA status/proof control rules;
- safety vetoes;
- routing/arbitration;
- fixed codecs.

Do not bake ordinary domain facts into T0 merely because they are popular.

### T1 — Hot Cognitive Working Store

BRAM/LUTRAM for:

- active frontier and visited state;
- current bindings/goal/query;
- hot directory/postings/edges/values;
- hot skill descriptors;
- proof scratch;
- small Q*/SPEAR state;
- FIFOs and protocol buffers.

### T2 — Canonical Cognitive Memory Store

DDR3/HBM for:

- verified graph/facts/provenance;
- candidate knowledge;
- episodic/failure journals;
- full skill library;
- long-term policies/checkpoints;
- cold indexes and proof artifacts.

## 9.3 Register and LUTRAM

Use for tiny state, counters, shallow queues and exact maps where synthesis shows benefit. Avoid accidental large LUTRAM inference.

## 9.4 BRAM semantic cache

Recommended logical partitions inside the same physical BRAM:

```text
Active Frontier       pinned / short lifetime
Hot Semantic Cache    admission-controlled
Skill Cache           independent policy
Proof Cache           independent policy
```

Admission and eviction are separate. Avoid pure “cache every miss.”

## 9.5 DDR

DDR is authoritative bulk storage on Arty. Latency is variable; do not hard-code a universal “20–30 cycles” assumption. Measure row behavior, MIG arbitration, queueing and traversal indirection.

## 9.6 HBM

**[SPECULATIVE until profiling]** HBM becomes justified when multi-walker random access and bandwidth are measured bottlenecks. Peak HBM bandwidth is not a guaranteed semantic-query bandwidth.

## 9.7 Future external memory

Larger systems may add NVMe/network/object storage behind a page service. Such storage is never directly on the proof-critical hot path without integrity/version checks.

## 9.8 Runtime promotion

Promotion changes location only:

```text
DDR canonical object
 -> shadow BRAM bank
 -> integrity/generation verify
 -> atomic directory commit
 -> active cache entry
```

## 9.9 Offline specialization / “sleep cycle”

Rename this **Semantic Hardware Specialization**:

```text
runtime hot/stable pattern
 -> export
 -> causal/benefit analysis
 -> RTL specialization candidate
 -> synth/P&R/timing/regression
 -> new bitstream / optional future DFX
```

A hot fact does not automatically become instinct. Specialize operators, stable micro-programs, decision predicates or repeated motifs only when measured benefit exceeds resource/verification cost.

---

# 10 — ACTIVATION AND ROUTING

## 10.1 Active frontier

The active frontier is the sparse set of semantic work items currently under consideration. The full graph is never “active” simultaneously.

```text
FrontierEntry {
  semantic_id
  incoming_relation
  depth
  path_cost
  context_id
  proof_parent
  flags
}
```

## 10.2 Activation descriptor

Activation is transient:

```text
ActivationDescriptor {
  semantic_id
  activation_reason
  frame_id
  logical_tick
  ttl
  priority
}
```

Activation does not alter truth status.

## 10.3 Event router

Responsibilities:

- classify event/query/result/control packets;
- route to Working Mind, graph walker, skill engine, ASTRA or learning lane;
- preserve transaction identity;
- enforce backpressure.

## 10.4 Backpressure

Queues expose occupancy/watermarks. No silent drop. Required outputs include overload status if bounded resources cannot accept more work.

## 10.5 Expiry

Transient activation/frontier entries carry TTL/budget. Expiry yields explicit search/budget status, not semantic falsity.

```text
budget exhausted -> SEARCH_INCOMPLETE
not -> UNKNOWN
```

## 10.6 Routing scale

Arty R0 uses one bounded router/shared fabric. Multi-tile packet NoC is deferred until a single-walker/multi-walker memory profile establishes need.

---

# 11 — WORKING MEMORY

## 11.1 Purpose

Working Memory is the bounded hot state needed for one active reasoning/learning context. It must remain small enough for deterministic on-chip implementation.

## 11.2 Contents

Recommended R0 fields:

```text
session_id
txn_id
generation
active_goal
active_query
binding_table
legal_mask
frontier queue
visited filter
candidate set
proof scratch
active skill descriptor
16–32 step trajectory
recent failure prototypes
policy/skill versions
```

## 11.3 Role bindings

Active frame slots are BRAM/LUTRAM records. Persistent semantic nodes remain canonical elsewhere. Bindings are transaction-scoped and must be cleared/versioned on reset, abort or generation change.

## 11.4 Active goal

Goal is an explicit semantic object/reference, not a string. Goal context may influence legal planning and utility, but not rewrite static truth.

## 11.5 Active query

The canonical query is a typed `QueryRecord`; human text is never retained as authority. Debug tooling may retain the original text as provenance only.

## 11.6 Frontier

Use bounded queues with:

- depth/path budget;
- relation masks;
- context constraints;
- proof parent references;
- explicit overflow/incomplete status.

## 11.7 Trajectory

Developmental trajectory stores only executed/observed steps. Unexecuted candidate actions must never receive causal credit.

---

# 12 — RETRIEVAL AND ASSOCIATION

## 12.1 Exact directory

Primary truth-path lookup is exact. Recommended flow:

```text
semantic_id
 -> hash / index
 -> candidate bucket/page
 -> full-key verify
 -> canonical record pointer
```

Hash collisions never become semantic matches.

## 12.2 Forward postings

Forward index maps `(subject, relation, context bucket)` to edge/posting pages. Keep one source-of-truth compiler for page format and an independent verifier for pack equivalence.

## 12.3 Reverse postings

Reverse index is a first-class capability, not “scan all forward edges.” Reverse lookup must be independently benchmarked and causally disabled in ablation tests.

## 12.4 Bounded posting pages

High-degree nodes use paged adjacency. Silent truncation is forbidden. If traversal cannot exhaust a hub within budget, status becomes `SEARCH_INCOMPLETE`.

## 12.5 Optional CAM

CAM/BCAM may accelerate:

- hot ID directory;
- alias dictionary;
- visited set;
- exact compact key lookup.

Do not implement one giant full-width CAM when hash-indexed exact tags are cheaper.

## 12.6 Optional HDC/VSA sidecar

**[HYPOTHESIS]** approximate associative memory may propose Top-K native IDs for ambiguous/sensor-derived inputs:

```text
ambiguous input
 -> HDC candidate proposal
 -> exact native IDs
 -> NCG retrieval
 -> ASTRA proof
```

The sidecar cannot return final truth or proof.

## 12.7 Cache policy

Prefer admission control + segmented hot stores rather than pure LRU. Hotness should consider frequency, recency, retrieval cost, proof-path utility, graph locality, payload size and volatility.

---

# 13 — REASONING ARCHITECTURE

## 13.1 Scope

R0 reasoning is bounded, explicit and proof-producing. It is not unrestricted theorem proving.

## 13.2 Direct retrieval

```text
(subject, relation, context)
 -> exact forward posting
 -> edge/value
 -> proof step
 -> ASTRA status
```

## 13.3 Reverse retrieval

```text
(object/value, relation, context)
 -> reverse posting
 -> candidate subjects
 -> proof step
```

Reverse capability must not be synthesized by host-side inversion.

## 13.4 Bounded multi-hop

Recommended initial limits:

```text
max_depth = 4–6
frontier <= 16/32
step/search budget explicit
visited bounded
relation mask explicit
```

Any exhausted budget must remain visible as `SEARCH_INCOMPLETE`.

## 13.5 Constraint resolution

Frames may constrain:

- semantic kind/class;
- relation compatibility;
- context;
- value/range/unit;
- source/provenance requirements;
- temporal relation.

Constraint filtering can reduce the active candidate set before SPEAR ranking.

## 13.6 Missing slots

Missing slot workflow:

```text
MISSING_SLOT
 -> exact retrieval
 -> graph inference
 -> sensor/observation request
 -> execute experiment/skill
 -> ask teacher
 -> UNKNOWN / SEARCH_INCOMPLETE
```

Q* may choose the macro strategy. SPEAR may rank legal candidates. ASTRA decides whether a candidate is sufficiently supported.

## 13.7 No semantic shortcuts

Forbidden:

```text
if case_id == X -> answer Y
if query string matches -> return gold
materialize inverse edge only to evade reverse test
materialize derived fact only to evade required multi-hop
```

---

# 14 — LEARNING ARCHITECTURE

## 14.1 Separation of learning state

Learning state is not stored inside verified fact records. Maintain independent stores for:

```text
CANDIDATE_RELATION
PREFERENCE
Q_WEIGHT
SPEAR_WEIGHT
SKILL_STATE
FAILURE_PROTOTYPE
AFFORDANCE_STATS
```

## 14.2 Candidate relations

Observation/co-occurrence may create or update candidate relations with explicit status and provenance. Candidate relation lifecycle:

```text
OBSERVED
 -> CANDIDATE
 -> VERIFIED or REJECTED or CONFLICTED
```

No frequency threshold directly yields `VERIFIED`.

## 14.3 Preference

Utility/preference may summarize successful action choice under context. It never changes truth of facts.

## 14.4 Q*

Q* remains macro strategy selection:

```text
RETRIEVE
SEARCH
OBSERVE
ACT
ASK_TEACHER
SUBMIT
STOP
```

Use bounded fixed-point learner with executed-action-only credit and deterministic EXAM mode.

## 14.5 SPEAR

SPEAR ranks targets/candidates inside the macro action. It cannot promote truth or change legality.

## 14.6 Promotion

Promotion to verified knowledge requires ASTRA proof rules, provenance and conflict checks. A teacher statement, reward, repeated observation or high score is insufficient on its own.

## 14.7 Reset/restore causal standard

A learned claim must support:

```text
W0/S0/K0 -> behavior A
train      -> W1/S1/K1 -> behavior B
reset      -> A returns
restore    -> B returns
```

If not, causal learning is not established.

---

# 15 — SENSOR GROUNDING

## 15.1 Objective

Test whether stable native concepts can form from physical effect/observation before a human alias is attached.

## 15.2 Raw event

Physical input enters as typed events with source capability, calibrated value, logical time, quality/error flags and provenance.

## 15.3 Feature/event abstraction

R0 should use deterministic or simple bounded feature extraction first:

```text
raw sample
 -> calibrated value
 -> threshold/range/event bucket
 -> state transition
```

Do not claim concept formation merely because a host preprocessing model labeled the event.

## 15.4 Native concept formation

Candidate native concept may arise when repeated observations share a stable effect/state pattern. Creation must be bounded and versioned; do not create a node for every cycle.

## 15.5 Alias attachment

Teaching sequence:

```text
unlabeled capability/state
 -> observe and act
 -> build effect relations
 -> stable internal SELF_ID
 -> attach HUMAN_ALIAS later
```

The causal structure must remain valid after alias rename or multilingual alias replacement.

## 15.6 Grounding falsification

Claim fails if:

- behavior depends on exact text alias;
- renamed alias destroys learned action/effect relation;
- host supplies hidden semantic label before native interaction;
- raw ID rather than class/effect structure explains transfer.

## 15.7 Perception boundary

**[SUPPORTED]** If raw vision/audio requires a dense or neuromorphic front end, that is compatible with NSPF. Perception may output candidate semantic events; exact identity/proof remains downstream.

---

# 16 — TEACHER AND ACTIVE LEARNING

## 16.1 Teacher modes

Supported modes:

```text
OBSERVE
DEMO
TRAIN
EXAM
```

DEMO provenance must remain separate from autonomous evidence.

## 16.2 Demonstrations

Teacher may provide explicit primitive/skill demonstrations. Demonstration creates trajectory/candidate skill evidence, not immediate stable skill truth.

## 16.3 Reward

Teacher may provide scalar reward tied to exact pending identity:

```text
session_id
txn_id
episode_id
step_id/generation
reward_value
crc
```

Teacher may not send weight deltas, hidden winner action, winner candidate or proof override.

## 16.4 Question to teacher

Active-learning macro action `ASK_TEACHER` is allowed only in teaching lanes. Its output is candidate information with source=`HUMAN_TEACHER`.

Suggested response classes:

```text
ALIAS
CANDIDATE_RELATION
GOAL
DEMONSTRATION
SCALAR_REWARD
CLARIFICATION
```

## 16.5 Authority boundary

```text
teacher proposal -> CANDIDATE
teacher alias    -> alias metadata
teacher reward   -> learner update eligibility
teacher proof override -> forbidden
```

ASTRA remains promotion authority.

## 16.6 Anti-parrot test

After teaching, remove/rephrase the original language cue and test equivalent native conditions. Success that requires verbatim teacher wording is not grounded learning.

---

# 17 — CAUSAL REASONING

## 17.1 Observation

Record only what is observed:

```text
ACTION_X executed
STATE_before
EFFECT_Y observed
STATE_after
```

Do not infer physical cause beyond evidence.

## 17.2 Correlation

Repeated co-occurrence may support `CORRELATES_WITH` or a candidate causal relation. Correlation is explicitly distinct from `CAUSES`.

## 17.3 Intervention

Causal promotion requires intervention where feasible:

```text
hold context approximately fixed
change action/candidate variable
observe effect distribution
```

## 17.4 Ablation

Remove or disable the purported support and rerun the same query/behavior. If outcome survives unchanged, investigate hidden duplicate support, stale cache, host injection or hard-coded logic.

## 17.5 Verified cause

Candidate ladder:

```text
OBSERVED_TOGETHER
 -> CORRELATES_WITH
 -> INTERVENTION_SUPPORTED
 -> CANDIDATE_CAUSES
 -> ASTRA proof gate
 -> VERIFIED_CAUSES
```

Not all domains allow strong causal verification; status must reflect uncertainty rather than force a cause label.

## 17.6 Causal proof object

Proof should reference intervention episodes, controls, context and effect observations. Natural-language explanation is derived from the proof, never the source of it.

---

# 18 — SKILL AND PROCEDURE MEMORY

## 18.1 Primitive

Primitive is a deterministic capability/opcode supplied by the substrate:

```text
READ WRITE TOGGLE COMPARE PACK UNPACK MEM_READ MEM_WRITE UART_TX ...
```

## 18.2 Option / skill

A reusable skill contains:

```text
skill_id
version
goal_class
preconditions
capability_class_mask
max_steps
policy_or_sequence_ref
termination_schema
expected_effect_schema
cost statistics
status
```

## 18.3 Parameterized skill

Skills should reference capability classes/roles/parameters rather than literal IDs where possible.

Bad:

```text
WRITE LED3
```

Better:

```text
SET_STATUS_INDICATOR(target: DIGITAL_OUT with required effect)
```

## 18.4 Transfer

Train on capability instance A; exam on unseen instance B with same class/effect schema. ID permutation is mandatory to detect scripts.

## 18.5 Skill lifecycle

```text
CANDIDATE
 -> LEARNED
 -> VERIFIED
 -> STABLE
 -> COMPACTED
 -> REOPENED on regression
```

One positive reward cannot directly create a stable skill.

## 18.6 Procedure memory vs truth

A skill is procedural memory, not a verified proposition. `ACHIEVES` relations are context-conditioned utility/procedure relations unless separately proven as facts.

---

# 19 — ASTRA PROOF MODEL

## 19.1 Authority

ASTRA owns:

```text
legality
proof validity
conflict
completeness
status
knowledge promotion
```

Scores, cache hotness, teacher statements and language rendering cannot override these fields.

## 19.2 Proof object

Recommended binary object:

```text
ProofHeader {
  proof_id
  txn_id
  status
  rule_id
  step_count
  flags
  root_ref
}

ProofStep {
  edge_id
  source_id
  relation_or_rule
  target_or_value
}
```

## 19.3 Provenance chain

Every proof-relevant semantic step references source/provenance. Inference must preserve ancestry rather than emit only a final answer.

## 19.4 Status

Minimum R0 statuses:

```text
ANSWER
UNKNOWN
CONFLICT
SEARCH_INCOMPLETE
UNSUPPORTED_QUERY
DATA_INTEGRITY_FAIL
```

Transport/parser faults belong to protocol status, not semantic UNKNOWN.

## 19.5 Conflict

Opposing verified support yields `CONFLICT` or a conflict object; Q*/SPEAR cannot break the tie by utility and call it truth.

## 19.6 Completeness

Completeness is explicit:

```text
COMPLETE
PARTIAL
NOT_APPLICABLE
```

A partial proof or exhausted search cannot silently be rendered as a certain answer.

---

# 20 — LANGUAGE ADAPTER

## 20.1 Boundary

Human language is outside the proof-critical core:

```text
text -> alias/intent resolver -> QueryRecord
StructuredResult -> renderer -> text
```

The adapter may resolve IDs. It may not perform hidden graph reasoning or answer lookup.

## 20.2 Multilingual aliases

One native ID may have multiple aliases:

```text
alias("human", en)
alias("con người", vi)
```

Changing language must not alter canonical semantics.

## 20.3 6W1H mapping

Candidate 3-bit native `QUERY_OPERATOR`:

```text
000 WHAT
001 WHO
010 WHERE
011 WHEN
100 WHY
101 WHICH
110 HOW
111 RESERVED
```

These codes represent query functions, not English words.

## 20.4 Text -> QueryRecord

Allowed host work:

- tokenize/parse human text;
- resolve aliases;
- normalize units;
- infer query operator/direction;
- construct canonical constraints.

Forbidden host work:

- choose answer;
- traverse hidden knowledge base for winner;
- construct proof on behalf of FPGA;
- encode expected benchmark answer in IDs/flags.

## 20.5 ResultRecord -> text

Renderer maps native status faithfully. Examples:

```text
ANSWER -> render answer/proof summary
UNKNOWN -> "insufficient verified support"
CONFLICT -> render conflict state, not a guessed winner
SEARCH_INCOMPLETE -> "search budget incomplete"
DATA_INTEGRITY_FAIL -> system/integrity error
```

## 20.6 Adapter parity

Different surface forms that resolve to the same canonical QueryRecord must produce the same semantic result. Parser failure is adapter failure, not knowledge UNKNOWN.

---

# 21 — FPGA MICROARCHITECTURE

## 21.1 Recommended Arty R0 pipeline

```text
UART / Host Adapter
      |
      v
Frame RX + CRC + Seq
      |
      +------> Knowledge Pack Loader
      |              |
      |              v
      |           MIG DDR3
      |
      v
Query/Event Decoder
      |
      v
Working Memory / Bindings
      |
      v
Exact Directory + Cache
      |
      v
Graph Walker / Constraint Resolver
      |
      +----> Q* / SPEAR / Skill lane when enabled
      |
      v
ASTRA Proof/Status Engine
      |
      v
Structured Result TX
```

## 21.2 Loader

Loader accepts manifest + pages, verifies ABI/schema/integrity at the implemented level, performs readback sentinels and atomically activates generation.

## 21.3 MIG

All semantic DDR traffic is blocked until MIG calibration completes. Centralize byte/beat conversion and 128-bit packing rules. Do not assume command/data ready coincide.

## 21.4 Cache

BRAM cache holds hot directory/postings/records and active frontier. Use shadow-bank fill + atomic activation for promoted pages/entries.

## 21.5 Graph walker

R0 walker is one bounded engine with:

- forward/reverse posting access;
- max depth/budget;
- visited filter;
- relation/context masks;
- proof parent tracking;
- explicit overflow/incomplete status.

## 21.6 Event router

Single on-chip router first. Route semantic packets to frame assembler, working mind, learning lane and result/proof lane with VALID/READY backpressure.

## 21.7 Proof engine

Proof builder records machine edges/rules and provenance refs while walking. Language is not generated in RTL.

## 21.8 Optional hardware profiler

Sideband access profiler may track frequency/recency/miss cost for cache admission without stalling the main path. Count-Min Sketch or compact counters are candidate mechanisms; cache score remains placement-only metadata.

## 21.9 Deferred features

Do not include in Arty MVP unless a benchmark justifies them:

```text
multi-walker NoC
HBM-specific banking
full CAM fabric
HDC vector sidecar
DFX semantic specialization
large dense neural blocks
```

---

# 22 — DATA STRUCTURES AND ABI

## 22.1 ABI rule

All binary layouts are versioned, endian-explicit, generated from one schema authority, and verified by an independent decoder/checker. Do not let the pack compiler and verifier share the same encode/decode helper if that would hide the same bug on both sides.

## 22.2 Core records

Recommended R0 sizes:

| Record | Size | Purpose |
|---|---:|---|
| `NodeRecord` | 32 B | semantic identity + indices |
| `EdgeRecord` | 32 B | typed verified/candidate relation |
| `PostingRecord` | 8 B | edge/neighbor reference |
| `ValueRecord` | 16 B | typed scalar/range/reference |
| `ContextRecord` | 16–32 B | contextual constraints |
| `ProvenanceRecord` | 32 B baseline | source/version/location/digest ref |
| `ProofHeader` | 16 B | proof identity/status |
| `ProofStep` | 16 B | edge/rule step |
| `SemanticEventPacket` | 24 B | 192-bit event packet |
| `QueryRecord` | 32 B | 256-bit native query |
| `StructuredResult` | 40 B candidate | semantic result + proof refs |

## 22.3 QueryRecord binary candidate

```text
magic                16
abi_version           8
flags                 8
txn_id               32
query_meta           16
subject_id           32
relation_id          16
object_or_constraint 32
context_id           32
value_or_constraint  32
search_budget        16
crc16                16
-----------------------
TOTAL               256 bits
```

`query_meta` packs query operator, direction, answer-kind hint and max hops.

## 22.4 StructuredResult candidate

```text
status           8
reason_code      8
answer_kind      8
flags            8
txn_id          32
answer_ref      32
value_lo        32
value_hi        32
unit_id         16
completeness     8
conflict_count   8
proof_ref       32
provenance_ref  32
context_ref     32
conflict_ref    32
```

If alignment requires a wider fixed word, pad explicitly and include a versioned length.

## 22.5 Manifest

Knowledge Pack manifest includes:

```text
magic
manifest_version
abi_version
schema_version
endianness
generation
record counts
region offsets/sizes
schema_sha256
content_sha256
compiler_abi_sha256
page_size
page_crc_scheme
manifest_crc
```

If FPGA hardware does not implement SHA-256, state the evidence level accurately, e.g. `HOST_SHA256_VERIFIED`, not a fake hardware hash claim.

## 22.6 Generations

Generation changes are atomic. Active state is never overwritten in place:

```text
write inactive
 -> integrity verify
 -> sentinel readback
 -> commit
 -> atomic active-generation flip
```

## 22.7 Compatibility

Compatibility matrix is explicit:

```text
ABI exact match required for binary record width/layout
schema major mismatch -> reject
schema minor compatible only if declared
unknown required flag -> reject
unknown optional flag -> ignore only if contract says so
```

## 22.8 Machine-readable schemas

This package includes:

- `schemas/query_record.schema.json`
- `schemas/structured_result.schema.json`
- `schemas/semantic_event.schema.json`
- `schemas/pack_manifest.schema.json`

These are design schemas, not proof that RTL exists.

---

# 23 — BRAM / DDR BUDGET

## 23.1 Physical baseline

**[ESTABLISHED from project research]** Arty A7-100T provides approximately 4,860 Kib (~607.5 KiB raw) block RAM and 256 MiB-class external DDR3L. Full integration must reserve BRAM for MIG-side buffers, protocol FIFOs, Working Mind, proof scratch and other logic.

## 23.2 Planning model

A conservative semantic-unit planning model from the research uses roughly **256 bytes per unit** when average edges, bidirectional postings and indexing/provenance overhead are included. This is a sizing hypothesis, not measured pack density.

| Scale | Approx footprint | Arty implication |
|---:|---:|---|
| 1k | ~0.244 MiB | can fit in BRAM only as a lab case, but wastes hot memory |
| 10k | ~2.44 MiB | DDR required |
| 100k | ~24.4 MiB | DDR comfortable; locality becomes key |
| 1M | ~244 MiB | near Arty DDR capacity before other state |
| 10M | ~2.38 GiB | HBM/server-class target |

## 23.3 Recommended Arty BRAM envelope

Initial target, to be validated by OOC synthesis:

```text
directory/node cache           4–8 BRAM36
forward/reverse posting cache  8–12
edge/value cache               4–8
frontier + visited             2–4
proof scratch                  2–4
bindings/working state         2–4
query/result/event FIFOs       2–4
skill/failure hot state        4–8
MIG-side buffering             8–16
--------------------------------------
preferred semantic subtotal    ~34–68 BRAM36
reserve                        >=20 BRAM36 if practical
```

Do not treat this as utilization evidence.

## 23.4 Cache directory sizing example

A 128-bit hot-directory entry:

```text
semantic_id      32
cache_addr       24
generation       16
semantic_class    8
epistemic_status  8
context_tag      16
payload_words     8
flags             8
integrity_tag     8
```

1024 entries require only ~16 KiB raw storage before RAM granularity overhead. This favors hash-indexed exact tags over a full parallel CAM.

## 23.5 DDR region candidate

Reuse the forward Developmental memory philosophy:

```text
manifest/checkpoint headers
lexicon/alias/skill metadata
exact directory + forward/reverse postings
nodes/edges/values/contexts/provenance
episodes + raw failures
compacted skills/failure/procedural memory
policy checkpoints + scratch
reserve/growth
```

No migration into frozen V1 memory maps without a separate gate.

## 23.6 HBM scale

HBM is a later scale target for multiple independent graph partitions/walkers. Capacity/bandwidth gains do not remove the need for bounded frontier, locality, proof-cost accounting and exact generation control.

---

# 24 — TIMING AND THROUGHPUT

## 24.1 Logical vs physical clocks

Semantic time is represented by logical tick/sequence fields. Physical FPGA cycles measure implementation latency only.

Clock-rate invariance requirement:

```text
same semantic packet sequence
+ same logical ticks
+ different legal physical spacing/clock enable
=> same semantic result/proof
```

## 24.2 DDR latency

Do not freeze a universal latency estimate into the architecture. Measure:

- MIG initialization and clock-domain behavior;
- row hit/miss patterns;
- read/write turnaround;
- arbitration/queueing;
- burst size;
- posting indirection;
- cache hit/miss penalty.

Report latency as distributions, not one number.

## 24.3 Event throughput

Metrics:

```text
accepted events/s
stalled events/s
FIFO high-water mark
drop/duplicate count (must be zero in valid runs)
router cycles/event
```

## 24.4 Traversal throughput

Metrics per query:

```text
index reads
posting pages
edge/value reads
frontier expansions
visited checks
proof steps
DDR bytes
cycles
time_ns
```

Target the relation:

```text
query cost ~= index cost + visited frontier cost + proof cost
```

Do not claim O(1) or O(log N) general reasoning unless the benchmark actually demonstrates the asymptotic behavior.

## 24.5 Pipeline ownership

On Arty, time-multiplex arithmetic and walkers where possible to protect timing/resource margin. Parallelism is added only after profiling.

## 24.6 Timing acceptance

For board-candidate RTL:

```text
WNS >= 0
TNS = 0
hold clean
critical DRC = 0
unconstrained semantic paths = 0
```

Preferred pre-board margin may be stricter (e.g. positive WNS reserve), but it must be declared before the run.

---

# 25 — SCALING ANALYSIS

## 25.1 Hub nodes

High-degree concepts can dominate traversal. Required design:

- paged adjacency;
- explicit page count;
- bounded hot Top-K only as optimization;
- no silent truncation;
- `SEARCH_INCOMPLETE` if budget cannot cover required evidence.

## 25.2 Cache hit rate

Track separately:

```text
directory hit
posting hit
edge/value hit
proof/provenance hit
skill hit
```

A single aggregate hit rate hides the true bottleneck.

## 25.3 Cache thrashing controls

R0 candidates:

- admission policy based on frequency/recency/miss cost;
- segmented hot stores;
- pinned active-frontier entries;
- context-aware eviction;
- aging;
- subgraph-aware prefetch only when measured useful.

## 25.4 Graph partition

Future HBM/large FPGA partition key candidates:

```text
semantic namespace
relation class
community/locality partition
source/context partition
hash partition with replication of hot hubs
```

Partitioning must preserve proof/provenance references and generation coherence.

## 25.5 Multi-walker

Only introduce multiple walkers after single-walker profiling shows memory-level parallelism is available. Required issues:

- duplicate frontier suppression;
- visited-set ownership;
- DDR/HBM bank conflicts;
- proof merge;
- deterministic transaction ordering where required.

## 25.6 HBM

HBM R2 scale target:

```text
many memory channels
 -> graph partitions
 -> walker per channel/group
 -> semantic-event merge
 -> ASTRA proof/status merge
```

Peak bandwidth is an upper bound, not expected random-graph performance.

## 25.7 ASIC/SoC long range

**[SPECULATIVE]** A mature implementation could use distributed local semantic caches + packet routers + persistent semantic memory. This is not an Arty requirement and should not distort R0 verification.

---

# 26 — VERIFICATION

## 26.1 Philosophy

Correct output is insufficient. Verify representation, selection, causal dependence, learning state, transfer, authority and hardware integrity separately.

## 26.2 Ladder

```text
L0 reference model
L1 RTL unit
L2 XSim subsystem
L3 integrated hierarchy
L4 OOC synthesis/timing
L5 post-implementation
L6 physical board
```

Do not use L6 to discover basic logic bugs that should fail at L0–L4.

## 26.3 Reference model

Reference implementation must:

- parse the exact frozen ABI;
- implement bounded traversal and statuses;
- produce machine-readable proof steps;
- keep deterministic seeds/order for EXAM;
- remain independent enough from RTL packing logic to detect encoding mistakes.

## 26.4 RTL assertions

Minimum examples:

```text
assert !(commit && !legal)
assert !(q_update && !action_participated)
assert !(spear_update && !candidate_selected)
assert !(fifo_wr && fifo_full)
assert !(fifo_rd && fifo_empty)
assert !(exam_mode && exploration_enable)
valid && !ready -> payload stable
accepted_request -> exactly_one_commit
```

Add NSPF-specific assertions:

```text
semantic_status change -> ASTRA_authorized
cache promotion -> exact generation match
hash lookup hit -> full key match
logical sequence gap -> explicit fault
proof step -> referenced edge valid in active generation
```

## 26.5 XSim

XSim must cover:

- role binding and reordered timings;
- direct/reverse/multi-hop;
- typed value/range;
- status distinctions;
- CRC/duplicate/stale packet handling;
- cache hit/miss parity;
- ablation;
- reset/restore for learned state.

## 26.6 OOC / implementation

Every block reports LUT/FF/BRAM/DSP, inferred RAM/multiplier shape, WNS/TNS, hold, CDC and high-fanout risks.

## 26.7 Board

Board evidence requires exact source/bit/pack/schema identities, UART raw capture, runtime load/readback, benchmark results and limitations. `PROGRAM_PASS` means configuration only.

## 26.8 Failure discipline

On failure:

```text
freeze failing run
 -> classify first causal divergence
 -> minimal patch
 -> targeted regression
 -> rerun lower gates
 -> fresh full campaign after functional change
```

Never overwrite negative evidence.

---

# 27 — FALSIFICATION EXPERIMENTS

Every experiment is preregistered with hypothesis, DUT, input, control, intervention, expected result, failure criterion and allowed claim.

## 27.1 ROLE_ORDER

**Hypothesis:** `KIND + ROLE + logical ordering` preserves frame semantics independent of physical spacing.

- **DUT:** event ingress + frame assembler.
- **Input:** same IDs/roles/logical ticks under different physical gaps.
- **Control:** swap SUBJECT/OBJECT roles while keeping IDs.
- **Intervention:** inject stalls/jitter; role swap separately.
- **Expected:** timing perturbation preserves result; role swap changes/rejects interpretation.
- **Fail:** raw cycle spacing changes meaning or swapped roles produce same frame semantics.
- **Allowed claim:** role binding is causally used and clock-spacing independent in tested bounds.

## 27.2 MASKED_SLOT

**Hypothesis:** a typed missing slot can be resolved from semantic constraints without answer-table lookup.

- **DUT:** NCG + constraint resolver + ASTRA.
- **Input:** frame `AGENT ? FOOD` with holdout IDs.
- **Control:** candidate-order shuffle and ID permutation.
- **Intervention:** remove one required support relation.
- **Expected:** supported candidate answers; ablated support -> UNKNOWN/INCOMPLETE as appropriate.
- **Fail:** exact training ID required, host supplies winner, or answer survives support removal.
- **Allowed claim:** bounded structural slot resolution is evidenced.

## 27.3 4BIT_TO_8BIT

**Hypothesis:** a learned parameterized procedure transfers across widths.

- **DUT:** Skill Engine + Working Mind; direct `ADD/INCREMENT` shortcut disabled for this experiment.
- **Input:** 4-bit training trajectories, unseen 8/16-bit exam.
- **Control:** literal-script baseline and bit-ID permutation.
- **Intervention:** width change and ID remap.
- **Expected:** carry/toggle abstraction transfers better than literal baseline.
- **Fail:** per-bit script or no transfer.
- **Allowed claim:** bounded structural transfer for tested procedure.

## 27.4 SENSOR_GROUNDING

**Hypothesis:** stable internal concept/effect relation can exist before human alias.

- **DUT:** benign sensor/GPIO + NCG + episode memory.
- **Input:** repeated action/effect observations without alias.
- **Control:** attach/rename alias after learning.
- **Intervention:** alias replacement and equivalent unseen capability instance.
- **Expected:** learned relations remain stable and transfer by class/effect.
- **Fail:** behavior collapses when alias changes.
- **Allowed claim:** effect-grounded internal identity is evidenced in bounded task.

## 27.5 CAUSAL_ABLATION

**Hypothesis:** semantic answer depends on declared support.

- **DUT:** Full Evidence/NSPF retrieval + ASTRA.
- **Input:** Pack A contains support; Pack B removes only that support.
- **Control:** exact same query, generation correctly switched.
- **Intervention:** runtime A -> B reload.
- **Expected:** A answers; B becomes UNKNOWN or another correctly supported state.
- **Fail:** old answer survives with no alternate support.
- **Allowed claim:** runtime-loaded evidence causally determines tested answer.

## 27.6 CLOCK_RATE_INVARIANCE

**Hypothesis:** semantics depends on logical events, not physical frequency.

- **DUT:** same RTL at two legal clocks or clock-enable schedules.
- **Input:** identical logical event sequence.
- **Control:** identical active pack/generation.
- **Intervention:** change physical rate/spacing.
- **Expected:** semantic result/proof invariant modulo timing metadata.
- **Fail:** meaning/status changes solely due to physical rate.
- **Allowed claim:** clock-rate invariance within tested configurations.

## 27.7 EVENT_JITTER_ROBUSTNESS

**Hypothesis:** bounded physical arrival variation is transport noise, not semantic information.

- **DUT:** ingress FIFO + assembler.
- **Input:** same sequence/ticks.
- **Control:** clean spacing.
- **Intervention:** seeded stalls/gaps/bounded async shifts.
- **Expected:** same semantic result, no duplicate/drop/deadlock.
- **Fail:** output change, event loss/duplication, parse deadlock.
- **Allowed claim:** event protocol is robust to preregistered jitter envelope.

## 27.8 Additional required experiments before R2 scale

Also preregister:

```text
DIRECT_RETRIEVAL
REVERSE_RETRIEVAL
MULTIHOP
VALUE_BINDING
CONTEXT_BINDING
PROVENANCE
TEACHER_CORRECTION
CONFLICT
UNKNOWN
LANGUAGE_ADAPTER_REMOVAL
MEMORY_SCALE
ENERGY_LATENCY
```

Each must use the same evidence template and retain negative results.

---

# 28 — BENCHMARKS

## 28.1 FE256

FE256 remains the core acceptance benchmark for the verified static semantic plane. NSPF does not redefine it.

Required principles:

```text
256/256 explicit structured results
wrong answer = 0
false refusal = 0
EMPTY = 0
timeout = 0
txn mismatch = 0
context/identity leak = 0
proof/provenance valid where required
```

A partial score is `FAIL_PARTIAL`, not PASS.

## 28.2 FE-UART-E2E-32

Human-facing acceptance after FE256:

```text
human text
 -> host adapter
 -> native QueryRecord
 -> UART
 -> FPGA semantic path
 -> StructuredResult
 -> UART
 -> host renderer
```

32/32 semantic parity required with zero EMPTY/TIMEOUT/PARSE_DEADLOCK/TXN mismatch/status distortion.

## 28.3 Transfer tests

NSPF-specific transfer set:

- ID permutation;
- unseen equivalent capability instance;
- alias/language replacement;
- unseen initial state;
- unseen goal composition;
- 4->8->16 width transfer where primitive shortcut is disabled;
- masked-slot holdout composition.

## 28.4 Latency tests

Report distributions by case class:

```text
cache hit
DDR direct
reverse
multi-hop
hub/overflow
proof-heavy
```

Separate retrieval cycles from proof cycles and UART/adapter time.

## 28.5 Energy tests

Energy thesis is valid only with measured power/latency on fair hardware. Compare:

- FPGA NSPF;
- CPU indexed graph/reference;
- appropriate small neural/transformer baseline for the same bounded task where meaningful.

Report joules/query or energy/work unit; do not infer energy from “event-driven” terminology.

## 28.6 Order/ablation controls

Every benchmark family that claims semantic correctness should include shuffled order and causal ablation where technically meaningful.

---

# 29 — IMPLEMENTATION ROADMAP

## 29.1 Rule

One milestone = one primary causal question. Each milestone freezes:

```text
CONTRACT.md
RESULT.json
EVIDENCE.md
SHA256SUMS.txt
```

Add artifacts only when needed to reproduce/debug.

## 29.2 Phase A — Arty MVP

### A0 — Freeze research lane

- no mutation of frozen V1/FE evidence;
- create isolated NSPF worktree/folder;
- pin research/ABI source hashes.

### A1 — ABI + reference model

- Node/Edge/Value/Context/Provenance;
- SemanticEventPacket;
- QueryRecord/StructuredResult;
- pack compiler/verifier separation.

### A2 — NSPF-X0

- event ingress;
- frame binding;
- masked-slot resolver;
- proof builder;
- timing perturbation;
- causal ablation.

### A3 — Runtime DDR integration

- production loader/MIG;
- directory/posting caches;
- readback;
- FE256 parity.

### A4 — UART E2E

- Host language adapter;
- FE-UART-E2E-32.

Maximum claim: bounded explicit semantic/event execution on Arty.

## 29.3 Phase B — R1 laboratory

Only after Arty MVP gates pass:

- sensor grounding;
- candidate relation lifecycle;
- teacher active learning;
- parameterized skill transfer;
- FEM integration;
- cache profiler/admission experiments;
- optional HDC proposal sidecar.

Maximum claim: bounded structural transfer/grounding if causal tests pass.

## 29.4 Phase C — R2 HBM scale

Entry conditions:

- profiling proves DDR/random-access bottleneck;
- proof overhead characterized;
- single walker correct and deterministic;
- cache semantics stable.

Implement:

- partitioned graph;
- multi-walker;
- HBM channel mapping;
- semantic-event merge;
- larger active-frontier profiling.

## 29.5 Phase D — Hardware specialization research

After stable workload evidence:

- offline profiler export;
- profitability model;
- candidate microprogram/operator specialization;
- full bitstream rebuild first;
- DFX only later if rollback/timing/lineage can be verified safely.

---

# 30 — RISK REGISTER

| ID | Risk | Class | Severity | Detection | Mitigation |
|---|---|---|---|---|---|
| S-01 | IDs/aliases mistaken for meaning | semantic | Critical | alias rename / ID permutation | separate ID/KIND/ROLE/alias |
| S-02 | ontology becomes English grammar | semantic | High | multilingual parity | normalize language at adapter |
| S-03 | explicit graph is just hand-coded expert system | semantic | Critical | unseen composition/instance tests | reusable primitives + transfer gates |
| M-01 | DDR random-access wall | memory | High | bytes/query, latency distribution | cache/postings/paging; HBM only after profiling |
| M-02 | hub node explosion | memory | High | adjacency overflow tests | paged adjacency + incomplete status |
| M-03 | cache thrashing | memory | High | hit/miss by cache class | admission control + segmentation |
| M-04 | cache stale generation | memory | Critical | generation-ablation test | exact generation tags + atomic switch |
| P-01 | event drop/duplicate | protocol | Critical | seq/CRC assertions | FIFO/backpressure/retry identity |
| P-02 | logical time coupled to cycles | protocol | High | clock-rate invariance | explicit logical tick |
| P-03 | retry causes double semantic commit | protocol | Critical | duplicate frame test | idempotent transaction IDs |
| L-01 | unexecuted action receives credit | learning | Critical | trajectory audit | executed-action-only updates |
| L-02 | teacher injects semantic winner | learning | Critical | authority attack | scalar/demo candidate only |
| L-03 | correlation promoted to cause | learning | Critical | intervention/ablation | ASTRA causal ladder |
| A-01 | Q*/SPEAR score overrides truth | authority | Critical | high-score invalid candidate attack | ASTRA veto/status authority |
| A-02 | GEMINI changes status | authority | Critical | conflict/unknown rendering test | structured result locked before text |
| A-03 | host becomes hidden reasoner | authority | Critical | log QueryRecord + host code audit | host alias/codec only |
| T-01 | accidental multiplier/logic replication | timing | High | OOC resources | shared/sequential arithmetic |
| T-02 | unconstrained CDC fake timing pass | timing | Critical | clock interaction report | explicit CDC constraints/handshakes |
| T-03 | proof path timing dominates query | timing | Medium/High | separate retrieval/proof cycles | bounded proof object / pipelining |
| G-01 | sensor grounding fails | cognition | Critical | alias-before/after, unseen sensor | permit hybrid perception if required |
| G-02 | no advantage vs ordinary graph engine | project | Critical | fair CPU/FPGA graph baseline | falsify strong claim if no added value |
| E-01 | no energy benefit | project | High | measured joules/query | keep claim narrow; optimize only measured bottleneck |

## 30.1 Stop rules

After repeated repair attempts in the same causal class without progress, stop patching and require architecture review. Never rescue a benchmark by changing gold/thresholds or by adding case-specific semantic rules.

---

# 31 — WHAT WOULD FALSIFY THE PROJECT

The strong NSPF hypothesis is considered falsified or materially weakened if controlled experiments repeatedly show several of the following:

1. New domains require new hand-written semantic FSMs instead of reusable primitives/relations.
2. ID permutation destroys supposed concepts or skills.
3. Alias/language replacement destroys physical/semantic knowledge.
4. Masked-slot success disappears on novel composition even though the necessary relations exist.
5. Causal ablation leaves the same answer without alternate verified support.
6. Physical clock/spacing changes semantic meaning despite identical logical events.
7. Sensor concepts cannot remain stable before/after human naming.
8. Query cost approaches a whole-graph scan for ordinary bounded queries.
9. Proof/provenance overhead removes the claimed sparse-execution advantage.
10. A conventional indexed graph engine matches every semantic/reasoning benefit with less complexity.
11. Useful transfer only appears when a large dense model performs the real reasoning and NSPF is a passive store.
12. Candidate/utility scores repeatedly need to override proof/status to achieve acceptable outputs.
13. Truth, skill, episode and failure classes cannot be kept separated without unacceptable overhead.
14. Continual updates require full-system retraining comparable to weight-centric models.
15. The hardware cannot meet timing/resource constraints at the minimum useful working-set size.

## 31.1 Partial falsification

A failure of the strong form does not make the engineering work worthless. Possible narrower outcomes:

- Full Evidence remains a useful auditable FPGA knowledge engine.
- NSPF becomes a semantic control plane around neural perception.
- Event/graph caching yields useful hardware acceleration without broader cognitive claims.
- Sensor/skill learning remains bounded to specific capability classes.

## 31.2 Required intellectual discipline

Do not convert a failed hypothesis into a new definition after seeing results. Freeze the preregistered claim, retain negative evidence, and version any revised hypothesis as a new research artifact.

---

# 32 — RECOMMENDED R2 ARCHITECTURE

## 32.1 Recommendation

Adopt **NSPF R2 candidate architecture** only as a forward Developmental integration target after R0 falsification gates pass. It must not replace or reinterpret frozen V1 evidence.

## 32.2 Top-level architecture

```text
                         HUMAN / SENSOR WORLD
                                 |
                 +---------------+---------------+
                 |                               |
          LANGUAGE ADAPTER                SENSOR ADAPTER
                 |                               |
                 +---------------+---------------+
                                 |
                       NATIVE EVENT/QUERY BUS
                                 |
          +----------------------+----------------------+
          |                                             |
          v                                             v
  BINARY SEMANTIC PLANE                         TEMPORAL EVENT PLANE
 Node/Edge/Value/Context                       Event/State/Action/Reward
 Provenance/Proof refs                         Logical tick/trajectory
          |                                             |
          +----------------------+----------------------+
                                 v
                         WORKING MEMORY
                  bindings / goal / frontier
                                 |
                    +------------+------------+
                    |            |            |
                    v            v            v
                   NCG          Q*           FEM
             exact retrieval   macro       experience
                    |            |            |
                    +-------> SPEAR <---------+
                               |
                               v
                        SKILL / OPTION
                               |
                               v
                       PRIMITIVE EXECUTOR
                               |
                               v
                          PHYSICAL EFFECT
                               |
                               v
                             ASTRA
               legality / proof / conflict / status
                               |
                               v
                      STRUCTURED RESULT
```

## 32.3 Physical memory stratification

```text
T0 IMMUTABLE SEMANTIC CONTROL PLANE
  primitives, exact compare, protocol rules,
  ASTRA control laws, safety, routing

T1 HOT COGNITIVE WORKING STORE
  active frontier, bindings, hot semantic cache,
  skill/proof caches, learner hot state

T2 CANONICAL COGNITIVE MEMORY STORE
  DDR/HBM verified graph, candidates, episodes,
  failures, skills, provenance, checkpoints
```

Placement never changes epistemic class.

## 32.4 Runtime information flow

Query path:

```text
text/sensor
 -> native record
 -> exact ID/context resolution
 -> active frontier
 -> directory/postings
 -> bounded retrieval/inference
 -> candidate set
 -> ASTRA proof/status
 -> structured result
 -> optional human rendering
```

Learning path:

```text
state_before + action + effect + state_after + reward
 -> episode
 -> learner/FEM updates
 -> candidate relation/skill
 -> verification
 -> promotion or reject
```

## 32.5 Recommended Arty realization

Implement first:

- one production UART/frame interface;
- one runtime Knowledge Pack loader;
- MIG DDR path;
- BRAM exact-directory/posting/edge caches;
- one bounded graph walker;
- one event router;
- one frame/binding unit;
- one ASTRA proof/status path;
- small Q*/SPEAR/Skill integration only after core semantic correctness is stable.

Do not begin with multi-walker/HDC/DFX.

## 32.6 Recommended HBM realization

After profiling:

```text
HBM partitions
 -> parallel exact directories/postings
 -> multiple bounded walkers
 -> merge frontier/proof candidates
 -> single or partitioned ASTRA authority
```

HDC may remain a proposal sidecar; exact graph/proof remains authority.

## 32.7 “Sleep cycle” recommendation

Treat consolidation as two separate processes:

### Runtime consolidation

```text
cold DDR object -> hot BRAM cache
```

Pure placement optimization; no semantic status change.

### Offline semantic hardware specialization

```text
stable repeated operator/skill/motif
 -> export statistics
 -> benefit + causal review
 -> RTL specialization
 -> synthesis/P&R/timing/regression
 -> new bitstream candidate
```

Full bitstream rebuild is preferred initially. DFX is deferred until the static/reconfigurable boundary, rollback, timing and artifact lineage are proven.

## 32.8 Minimum acceptance before R2 promotion

```text
FE256 core acceptance intact
FE-UART-E2E-32 pass
NSPF-X0 pass
ROLE_ORDER pass
MASKED_SLOT holdout pass
CAUSAL_ABLATION pass
CLOCK_RATE_INVARIANCE pass
EVENT_JITTER_ROBUSTNESS pass
sensor grounding local causal evidence
ID permutation / unseen-instance transfer evidence
resource/timing fit
no host semantic authority leak
```

## 32.9 Final claim ceiling

If the above passes, a defensible research claim is:

> A bounded FPGA-native semantic/event substrate can execute exact typed knowledge, maintain sparse logical activation and role bindings, retrieve and compose bounded evidence paths, preserve explicit proof/status authority, and acquire selected grounded procedural/relational state while remaining causally dependent on runtime memory and robust to representational/timing perturbations.

This still does not imply AGI, consciousness, universal reasoning or human-equivalent language learning.

---

