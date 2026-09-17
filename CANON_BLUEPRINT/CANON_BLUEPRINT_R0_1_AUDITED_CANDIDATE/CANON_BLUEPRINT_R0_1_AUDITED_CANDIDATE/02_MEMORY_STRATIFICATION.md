---
version: "1.1-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:31:00+07:00"
---

# §02 — MEMORY STRATIFICATION

> Physical memory tiers, their roles, what belongs where, and the
> absolute rule: placement never changes epistemic class.

## 2.1 The Cardinal Rule

> **A FACT remains a FACT whether it is stored in DDR or cached in BRAM.**
> Physical tier movement changes **placement**, not **epistemic status**.

This means the following table is the correct mental model:

```text
                PHYSICAL PLACEMENT
              T0          T1          T2
            Logic        BRAM       DDR/HBM

FACT                     cache      canonical
SKILL                    hot        canonical
EPISODE                             canonical
FAILURE                  hot        canonical
POLICY WEIGHT            active     checkpoint
PROOF                    scratch    archive
CANDIDATE                hot        canonical
```

Do NOT write: "FACT = DDR", "SKILL = BRAM", "INSTINCT = LUT".

## 2.2 Tier Definitions

### T0 — Immutable Semantic Control Plane

**Physical**: LUT, distributed RAM, fixed logic.

**Contains**:
- Exact comparators
- Hash primitives
- AND / OR / NOT operators
- Type checks
- CRC / protocol logic
- Routing fabric
- Schema / ABI enforcement laws
- ASTRA state/status rules
- Safety / legality veto logic
- Bounded graph machinery
- Primitive arithmetic

**Does NOT contain**:
- Device-specific facts (e.g., "RAC_WALL → R32")
- LED mappings (e.g., "LED3 = SUCCESS")
- Teacher statements
- Learned facts, Q* preferences, episodes
- Any knowledge that could change

**Resource reality**: XC7A100T has 63,400 LUTs, but they are NOT all available for intersection engines. Each comparator costs LUT + routing + fanout + timing + power. Hardware intersection is bounded — see [§01.2].

### T1 — Hot Cognitive Working Store

**Physical**: BRAM/LUTRAM. XC7A100T provides 135 BRAM36 blocks, approximately 607.5 KiB raw block-RAM capacity before subsystem allocation.

**Contains**:
- Current QueryRecord
- Active context and role bindings
- Active goal
- Frontier (current activated working set)
- Visited set / Bloom filter
- Top-K candidate queue
- Hot directory entries (semantic node directory cache)
- Hot posting pages
- Hot edge/value records
- Proof scratch space
- Hot skills (currently executing procedures)
- Q*/SPEAR working state
- Recent FEM prototypes
- FIFO / event buffers

**Function**: Working Memory + Hot Cache + Hot Procedural Memory.

These three are logically different but share the same physical tier:
1. **Working Memory** — transient query/binding state
2. **Hot Cache** — frequently accessed T2 records
3. **Hot Procedural Memory** — currently active skills

If you want to call this "muscle memory", reserve the metaphor for learned/verified/reusable **skills only**, not for all of BRAM.

### T2 — Canonical Cognitive Memory Store

**Physical**: DDR3L (256 MB on Arty A7-100T).

**Contains**:
- Nodes, Edges, Values, Contexts, Provenance records
- Forward posting lists (node → outgoing edges)
- Reverse posting lists (node → incoming edges)
- Candidate facts (unverified)
- Episodes (temporal experience)
- Failures (typed failure records)
- Skills (verified procedures)
- Policy checkpoints (Q*/SPEAR learned state)
- Long-term learning state
- Conflict records
- Proof artifacts

**Relation types stored** (not exhaustive):
```text
IS_A, PART_OF, USES, HAS_STATE, NAMED_AS,
BEFORE, AFTER, CORRELATES_WITH, CAUSES,
ACHIEVES, FAILED_AT, ...
```

Critical invariant: `CORRELATES_WITH != CAUSES` — always.

## 2.3 Bounded Relevance-Guided Graph Traversal

The correct name for "BRAM anchor → open only needed DDR branches":

```text
Query / Goal
     │
     ▼
T1 active anchors (BRAM cached directory entries)
     │
     ▼
exact directory lookup (ID → directory slot)
     │
     ▼
selected posting page pointer(s)
     │
     ▼
DDR fetch (only selected pages)
     │
     ▼
relation/context filter
     │
     ▼
new frontier
```

It does NOT scan all of DDR. The path is:
```text
ID → directory → posting pointer → selected adjacency
```

BRAM does not contain the entire graph. It holds the **working set** of the graph.

## 2.4 Hot Directory ABI (Candidate)

Each BRAM directory entry is a **placement/index record**, not a duplicate truth record. A 128-bit R0.1 candidate is:

| Field | Bits | Description |
|---|---:|---|
| semantic_id | 24 | Arty MVP active-range ID; full wire field remains 32-bit [§04] |
| generation | 16 | Active knowledge generation tag |
| kind | 8 | Node kind/type code |
| fwd_descriptor_ptr | 28 | Byte address/reference within 256-MB T2 space |
| rev_descriptor_ptr | 28 | Reverse-posting descriptor address/reference |
| flags | 8 | valid/pinned/dirty/prefetch metadata |
| integrity_tag | 8 | cache-entry integrity/version tag |
| namespace_tag | 8 | compact namespace/cache partition tag |
| **Total** | **128** | |

Epistemic status/proof is not inferred from cache residency. Canonical semantic state remains in the referenced record and is generation-checked.

A hypothetical directory occupying every BRAM bit would be misleading; T1 also contains working memory, FIFOs, proof scratch, postings, skills and learner state. Directory capacity must therefore be budgeted from post-synthesis allocation, not from raw-BRAM division alone.

## 2.5 DDR Performance Model

Arty A7-100T DDR3L specifications:

| Parameter | Value |
|-----------|-------|
| Capacity | 256 MB |
| Bus width | 16 bit |
| Memory clock | 333 MHz |
| Effective rate | 667 MT/s |
| Peak bandwidth | 1.334 GB/s ≈ 1.24 GiB/s |

**These are peak physical transfer numbers.** They do not specify user-visible random-access latency or semantic-query throughput.

Do **not** publish fixed row-hit, row-miss, or cycles-per-hop numbers until the exact generated MIG/user-interface implementation is measured. End-to-end latency depends on command/data handshakes, row/bank state, refresh, arbitration, bursts, CDC/buffering, graph indirection and proof fetches.

Required benchmarks [§31]:
```text
sequential burst throughput
random page access latency
random posting lookup
cache hit ratio
cache miss penalty
forward lookup latency
reverse lookup latency
multi-hop traversal time
```

## 2.6 Cache Strategy

BRAM cache is important for performance but not for correctness:

- **Correctness** can work with DDR-only (no cache). Results are the same.
- **Cache** improves: latency, DDR traffic, working-set locality, throughput.

Cache hypothesis for R0:
> Hot working set caching improves sparse semantic traversal.

This must be benchmarked, not assumed as design truth.

Arty MVP baseline: simple LRU/segmented LRU for ease of causal verification.

Post-baseline candidates, enabled only after profiling:
- TinyLFU / Count-Min Sketch admission
- cost-aware or context-aware admission
- subgraph-aware prefetch
- pinned entries for active query nodes

Admission and eviction are separate decisions. Any probabilistic profiler affects placement only and cannot affect ASTRA truth/status.

## 2.7 Cache Coherence and Atomic Promotion

Runtime T2→T1 promotion uses shadow fill and exact generation checks:

```text
DDR canonical object/page
 -> fill inactive/shadow cache slot
 -> verify generation + integrity
 -> atomic directory visibility update
 -> active cache entry
```

On generation change, stale entries are invalidated or generation-mismatched. Cache on/off must produce semantically equivalent results; only latency/traffic may change.

## 2.8 Runtime Consolidation vs Offline Specialization

Two distinct processes — do not conflate:

### Runtime Consolidation (Caching)

```text
T2 DDR → hot object → T1 BRAM
```

This is **caching**. No new truth. No status change. Pure placement optimization.

### Offline Hardware Specialization

After extensive evidence that a pattern is stable:

```text
stable operator / skill / motif
       ↓
profiling
       ↓
benefit analysis
       ↓
causal verification
       ↓
host compiler
       ↓
RTL candidate
       ↓
Vivado synthesis → P&R → timing → regression
       ↓
new bitstream (NEW ARTIFACT, NEW HASH, NEW BITSTREAM)
```

A procedure MAY become hardware-accelerated ("reflex"), but this requires a full bitstream rebuild. The FPGA does not "grow new LUTs" autonomously.

## Tóm tắt tiếng Việt

Bộ nhớ chia 3 tầng vật lý: T0 (LUT — logic cố định), T1 (BRAM — working memory + cache nóng, 607.5 KiB), T2 (DDR3L — bộ nhớ chính, 256 MB). Quy tắc bất biến: di chuyển giữa T1↔T2 chỉ thay đổi vị trí vật lý, KHÔNG thay đổi trạng thái tri thức (FACT vẫn là FACT). DDR peak 1.334 GB/s nhưng random access chậm hơn nhiều — phải benchmark. BRAM cache cải thiện hiệu năng nhưng không ảnh hưởng tính đúng đắn.
