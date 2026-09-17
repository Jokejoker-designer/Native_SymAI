---
version: "1.1-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:45:00+07:00"
---

# §00 — MASTER INDEX

> Entry point for the audited candidate. Authority precedence is defined in
> `AUTHORITY_PRECEDENCE.md`.

## Governance

| File | Purpose |
|---|---|
| `PROJECT_GOAL_LOCK.md` | forward research North Star / invariants |
| `AUTHORITY_PRECEDENCE.md` | conflict/authority ordering for this candidate |
| `AUDIT_REPORT_R0_1.md` | full audit findings against GOAL |
| `R0_1_ERRATA_AND_PATCHES.md` | P0/P1/P2/P3 patch register |
| `README.md` | package status and entry instructions |
| `MASTER_CANON_BLUEPRINT_R0_1.md` | concatenated convenience view of audited top-level canon |

## Primary architecture

| § | File | Scope |
|---|---|---|
| 01 | `01_MASTER_ARCHITECTURE.md` | dual semantic/event planes, Working Mind, authority partition |
| 02 | `02_MEMORY_STRATIFICATION.md` | T0/T1/T2, cache/coherence/placement |
| 03 | `03_ASTRA_AUTHORITY.md` | legality/proof/status/conflict/promotion |
| 04 | `04_ABI_AND_PROTOCOL.md` | native records, manifest, framing, runtime load |
| 05 | `05_CAPABILITY_AND_ACTION_BINDING.md` | semantic action→verified physical capability→effect/readback |

## Cognitive / learning research

| § | File | Scope |
|---|---|---|
| 10 | `10_LEARNING_AND_STRATEGY.md` | Q*/SPEAR, reward/credit boundaries |
| 11 | `11_FAILURE_EXPERIENCE_MEMORY.md` | runtime FEM capture/prototypes/compaction/reopen |
| 12 | `12_SKILL_AND_TEACHING.md` | skill lifecycle, teacher boundary, grounding |
| 13 | `13_INFORMATION_NEURONALIZATION.md` | central research hypothesis and falsification |

## Reference

| § | File | Scope |
|---|---|---|
| 20 | `20_GLOSSARY_AND_LOCKED_TERMS.md` | canonical definitions/invariants |
| 21 | `21_PRIOR_ART_AND_NOVELTY.md` | prior-art/novelty boundary |
| 22 | `22_RTL_RISK_REGISTER.md` | implementation/evidence risks |
| 23 | `23_HARDWARE_FACTS.md` | Arty A7 hardware facts and measurement boundaries |

## Operational / evidence

| § | File | Scope |
|---|---|---|
| 30 | `30_MILESTONE_ROADMAP.md` | M1–M8 causal roadmap |
| 31 | `31_VERIFICATION_AND_CAUSAL_TESTS.md` | Pack/ABI, FE256, E2E, NSPF-X0 |
| 32 | `32_ACCEPTANCE_LADDER.md` | separate Full Evidence / NSPF / Developmental acceptance |
| 33 | `33_IMPLEMENTATION_GUIDE.md` | implementation sequence and MVP choices |

## Source preservation

- `_ARCHIVE/` contains source/historical packages and must not be silently used
  as newer authority over audited top-level files.
- `_COORDINATION/` contains non-authoritative workflow metadata.
- `.agents/` preserves request/session context, not semantic authority.

## Required reading order

See `READING_ORDER.md`.

## Cross-reference convention

Project docs use `§XX.Y` for numbered top-level sections. Governance filenames
are referenced by name. If a cross-reference points to a missing/renumbered
section, treat it as an audit defect rather than guessing silently.

## Tóm tắt tiếng Việt

Index R0.1 thêm authority precedence, audit/errata và §05 capability binding;
archive/coordination được giữ nhưng không có quyền ghi đè canon top-level.
