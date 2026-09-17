# 04 — GOLD SOURCE AND CASE GENERATION

## 1. Gold authority

FE256 cases must be generated from a **frozen canonical gold export**, not from RTL output and not from the same lookup helper used by the DUT.

Recommended source:

`CANON_GOLD_CLAIMS.jsonl`

Each claim should contain canonical identity and evidence references. Human text is optional metadata.

## 2. Independence law

The encoder/pack compiler and the benchmark oracle must not share the same encode/decode implementation in a way that lets one bug self-confirm.

Preferred:

```text
source docs / reviewed gold
     ↓
CANON_GOLD_CLAIMS.jsonl
     ├── pack compiler → DUT binary
     └── independent benchmark builder → FE256 cases
```

## 3. Deterministic selection

- fixed seed,
- stable sorting by claim ID before sampling,
- generated case IDs never reused with different semantics,
- selection manifest contains source gold SHA256.

## 4. Preregistration

Before board execution freeze:
- case JSONL,
- expected statuses,
- expected canonical answer/value,
- proof policy,
- benchmark config,
- source gold SHA,
- bitstream SHA after build.

Do not regenerate failed cases to make a campaign pass.
