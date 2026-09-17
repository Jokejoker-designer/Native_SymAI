# Recommended Integration into Native AI Repository

## Directory

Place this package at:

```text
tools/native_guard/
```

Keep runtime state out of Git:

```text
.native_guard/
.Xil/
*.jou
*.log
runs/
build/
```

Raw acceptance evidence should instead be copied/sealed under a project-defined immutable `evidence/<campaign_id>/` after the run.

## CI/pre-merge gates

1. `authority-check --role agent`
2. `verify-contract <milestone>`
3. XSim/unit regression
4. OOC synthesis per modified RTL block
5. integration synth
6. post-route signoff only when integration/timing-sensitive paths changed
7. `evidence-verify`

## Parallel execution policy

Each agent gets:

```text
worktrees/AGENT_A/
worktrees/AGENT_B/
worktrees/AGENT_TIMING/
worktrees/AGENT_VERIFY/
```

Never run two Vivado implementations in the same worktree/run directory. Hardware agent must acquire `board`, `jtag`, and `uart` leases before programming/capture.

## Functional-change invalidation

After a functional RTL/ABI/XDC change:

```powershell
native-guard task-invalidate synth --agent AGENT_X --reason "RTL functional patch"
```

This invalidates `synth` and every downstream stage in the configured DAG. Never reuse post-route/board evidence from a pre-patch artifact.
