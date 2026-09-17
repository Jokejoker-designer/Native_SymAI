# FAILOVER PROTOCOL — CODEX / CURSOR / GROK

## Normal start of every agent session
```powershell
native-orch --coord-root D:\FPGA\PROJECT agent-heartbeat --agent CODEX
native-orch --coord-root D:\FPGA\PROJECT sweep
native-orch --coord-root D:\FPGA\PROJECT task-next --agent CODEX --claim
```

Generate the task capsule:
```powershell
native-orch --coord-root D:\FPGA\PROJECT task-context TASK_ID --out D:\FPGA\PROJECT\_COORDINATION\CURRENT_TASK_CODEX.md
```

## During work
Checkpoint after any of:
- semantic decision;
- first passing unit test;
- first failing causal divergence identified;
- RTL structural change;
- before long Vivado run;
- after long Vivado run.

```powershell
native-orch --coord-root D:\FPGA\PROJECT task-checkpoint TASK_ID `
  --agent CODEX --worktree D:\FPGA\worktrees\CODEX `
  --notes "Implemented X" --next-step "Run OOC synth"
```

## Quota nearly exhausted
```powershell
native-orch --coord-root D:\FPGA\PROJECT task-checkpoint TASK_ID ...
native-orch --coord-root D:\FPGA\PROJECT task-pause TASK_ID --agent CODEX --reason QUOTA_LOW
native-orch --coord-root D:\FPGA\PROJECT agent-state --agent CODEX QUOTA_EXHAUSTED --release-tasks
```

## Another agent takes over
```powershell
native-orch --coord-root D:\FPGA\PROJECT sweep
native-orch --coord-root D:\FPGA\PROJECT task-takeover TASK_ID --agent CURSOR --solo
native-orch --coord-root D:\FPGA\PROJECT task-context TASK_ID --out CURRENT_TASK_CURSOR.md
```

The latest checkpoint is returned by `task-takeover`.
