# R2 — ASYNCHRONOUS / QUOTA-RESILIENT ORCHESTRATION

## Principle
The four specialties are **roles, not people**. Codex, Cursor, Grok, or another agent may temporarily execute any role for which it is permitted/capable. No role requires a specific vendor/model.

The project uses an asynchronous task DAG with work stealing. Agents do not wait for one another unless a **hard evidence dependency** requires it.

## Two dependency strengths
- `CANDIDATE_PASS`: downstream development may consume the artifact provisionally.
- `PASS`: acceptance/signoff dependency; requires the specified review discipline.

This lets implementation continue while an independent reviewer is offline, without falsely promoting provisional evidence.

## Solo continuation mode
When only one agent is available:
1. It may claim any READY task with `--solo`.
2. It may switch roles (ARCH/RTL/LEARN/VERIFY) for development.
3. A task requiring independent review can only finish as `CANDIDATE_PASS` if that same agent produced it.
4. Downstream tasks marked to accept `CANDIDATE_PASS` may continue.
5. Board/final/authority gates remain blocked until independent review or owner review occurs.

Thus quota exhaustion slows certification, not development.

## Quota/stoppage recovery
Agents heartbeat into the shared SQLite control plane. If an agent stops or reaches quota:
- graceful path: mark `QUOTA_EXHAUSTED --release-tasks`;
- abrupt path: `native-orch sweep` marks stale agents and reclaims expired tasks;
- the next agent uses `task-takeover` and receives the latest checkpoint.

## Checkpoint contract
Every meaningful work unit must record:
- git commit;
- dirty files;
- what was done;
- next exact step;
- blockers;
- evidence produced.

This is the mechanism that allows another agent to continue without re-reading the whole project.

## Concurrency safety
Each task declares `write_scopes`. Two RUNNING tasks with overlapping scopes cannot be claimed at the same time. Separate Git worktrees are still recommended for each live agent.

## Separation that cannot be bypassed
One agent may continue development alone, but may not self-certify an independent-review gate. This applies especially to:
- acceptance contract mutation;
- benchmark gold;
- ASTRA authority semantics;
- final timing/CDC signoff when the same agent changed constraints to obtain closure;
- BOARD_PASS / owner freeze.
