# 03 — NATIVE INFORMATION FABRIC ARCHITECTURE

## 1. Sơ đồ tổng thể

```text
HUMAN WORLD
text / voice / manual / labels / demonstration
        |
        v
HUMAN SYMBOL ADAPTER
parser / GEMINI / teacher interface
        |
        v
================ NATIVE BOUNDARY ================
        |
        v
BINARY SEMANTIC PLANE
NodeID / RelationID / Value / Context / Provenance
        |
        +---------------------+
        |                     |
        v                     v
NATIVE KNOWLEDGE GRAPH    TEMPORAL/WAVE PLANE
facts/relations           events/pulses/trajectories
        |                     |
        +----------+----------+
                   v
            WORKING MIND
             Q* / SPEAR
             NCG / Skill
             FEM / Episode
                   |
                   v
                ASTRA
         proof / legality / truth
                   |
                   v
             RESULT RECORD
                   |
                   v
         HUMAN SYMBOL ADAPTER
                   |
                   v
             HUMAN OUTPUT
```

## 2. Planes

### Plane A — Binary Semantic
Deterministic IDs, typed records, exact graph relationships.

### Plane B — Temporal/Wave
Dynamic experience: sampled signals, event pulses, action sequences, timing and reward.

### Plane C — Human Symbol
Strings, speech, document labels, aliases. Không được dùng làm semantic authority.

## 3. Interfaces giữa planes

- Human→Native: tokenize/resolve identity/compile query/claim into structured records.
- Native→Human: structured result→language rendering.
- Temporal→Semantic: repeated effect evidence may create candidate relations.
- Semantic→Temporal: goals/skills select actions against dynamic state.

## 4. Không dùng “wave” để thay exact identity

Waveform phù hợp với dynamic behavior, không phù hợp để thay thế exact model ID, provenance hash, relation type hay proof identity.
