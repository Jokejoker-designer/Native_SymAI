---
version: "1.0-candidate"
owner: PROJECT_OWNER
status: AUDITED_CANDIDATE
category: GOVERNANCE
last_modified: "2026-09-16T08:45:00+07:00"
---

# AUTHORITY PRECEDENCE — AUDITED CANDIDATE

This file defines how conflicts inside this **candidate package** are resolved.
It does not rewrite frozen historical evidence and does not constitute owner
approval/freeze.

## Precedence

1. **PROJECT_GOAL_LOCK.md** — forward research North Star and invariants.
2. **Top-level R0.1 audited design docs** (`01`–`33`, including §05 capability binding).
3. **Preregistered benchmark/acceptance contracts** for the scope they test.
4. **Archived source packages** under `_ARCHIVE/` — historical/source evidence; immutable, not silently merged into current rules.
5. **Coordination metadata/tools** under `_COORDINATION/` — workflow state only, never semantic/technical authority.
6. **Local run metadata** (COM/JTAG/path/license) — evidence for one run only.

If two top-level docs conflict, stop and register an erratum rather than choosing
silently. If an external authoritative hardware source conflicts with a project
constant, correct the candidate doc and preserve the historical text in archive.

## Final authority

Agents may create candidate designs/evidence. Only the project owner may approve
promotion, final freeze or BOARD_PASS-equivalent artifact status.
