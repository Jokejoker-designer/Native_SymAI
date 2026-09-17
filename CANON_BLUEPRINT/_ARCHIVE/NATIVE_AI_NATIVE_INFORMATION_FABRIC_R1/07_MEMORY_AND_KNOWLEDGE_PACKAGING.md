# 07 — MEMORY AND KNOWLEDGE PACKAGING

## 1. BRAM vs DDR

### BRAM — hot bounded state
- current query
- graph frontier
- visited set
- candidate cache
- proof scratch
- current skill/trajectory
- Q*/SPEAR hot weights

### DDR — long-term
- nodes/edges/facts
- values/literals
- context
- provenance
- episodes
- skills
- failure journals/prototypes
- checkpoints
- knowledge packs

## 2. Knowledge Pack

Một pack chuẩn nên có:

- Manifest
- Node Table
- Edge Table
- Value Table
- Context Table
- Provenance Table
- Directory/Posting indexes
- Lexicon/Alias table (adapter-level)
- Checksums / schema/version hashes

## 3. ABI identity

Manifest cần khóa:

- pack_id
- pack_version
- schema_version
- ABI_version
- schema hash
- content hash
- generation
- domain/source set

Mismatch ABI phải `LOAD_REJECT`.

## 4. Persistence

Checkpoint cần generation consistency. Nếu dùng A/B:

`write inactive → verify CRC/hash → commit → atomic generation flip`

Không cho half-new/half-old semantic state.
