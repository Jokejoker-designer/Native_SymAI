---
version: "1.1-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:33:00+07:00"
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

ASTRA does **not** answer:
- "What should I do next?" → Q* [§10]
- "Which candidate first?" → SPEAR [§10]
- "How do I execute this?" → Skill Engine [§12]
- "How do I say this to a human?" → GEMINI / Language Adapter [§01.7]

## 3.2 Epistemic Status Codes

ASTRA must emit exactly one of these statuses for every query resolution:

| Status | Meaning |
|--------|---------|
| `ANSWER` | Evidence supports a definite answer with proof trace |
| `UNKNOWN` | Search completed for the declared scope and found no verified support |
| `CONFLICT` | Contradictory evidence exists; cannot resolve |
| `SEARCH_INCOMPLETE` | Budget exhausted before all candidates examined |
| `UNSUPPORTED_QUERY` | Query type not supported by current system |
| `DATA_INTEGRITY_FAIL` | Knowledge pack CRC/hash mismatch or corruption |

The adapter layer may additionally emit:
| Status | Meaning |
|--------|---------|
| `PARSE_ERROR` | Input text could not be parsed into a valid QueryRecord |

**Critical distinctions**:
- `SEARCH_INCOMPLETE ≠ UNKNOWN`: If Top-K budget dropped a needed candidate, the system must say "I ran out of budget" not "I don't know."
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

For every candidate answer or promotion request, ASTRA verifies:

1. **Legality** — Does this operation comply with schema/ABI rules?
2. **Evidence** — Is the support chain present and complete?
3. **Provenance** — Where did each piece of supporting evidence come from?
4. **Conflict** — Does any existing verified knowledge contradict this?
5. **Completeness** — Has the search covered all required paths within budget?
6. **Epistemic Status** — What status code should be emitted?

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
MISSING / UNKNOWN / INCOMPLETE
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
| GEMINI | Human-language rendering | Truth, knowledge |
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

## Tóm tắt tiếng Việt

ASTRA là authority cuối cùng cho mọi quyết định về tính hợp lệ, bằng chứng, provenance, xung đột và trạng thái tri thức. Mọi câu trả lời phải kèm proof trace. Hệ thống phân biệt rõ 6 trạng thái: ANSWER, UNKNOWN, CONFLICT, SEARCH_INCOMPLETE, UNSUPPORTED_QUERY, DATA_INTEGRITY_FAIL. Teacher chỉ tạo CANDIDATE, không bao giờ tạo FACT trực tiếp. Không component nào được phép vượt quyền ASTRA.
