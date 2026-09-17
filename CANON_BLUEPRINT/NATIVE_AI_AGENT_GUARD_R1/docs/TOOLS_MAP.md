# Tool Map

## 1. `native-guard claim/release/leases`
Atomic leases for files, Vivado implementation, JTAG, UART, board, and canonical promotion.

## 2. `native-guard snapshot`
Hashes source/constraints/scripts/docs and records Git state. Use before every build and acceptance run.

## 3. `native-guard freeze-contract / verify-contract`
Freezes the exact project state for a milestone. Any unexpected mutation invalidates downstream evidence.

## 4. `native-guard task-claim / task-finish / tasks`
Dependency-aware stage state. Prevents an agent from running `impl` before `synth`, or FE256 before readback.

## 5. `native-guard run`
Watchdog execution wrapper with exclusive resource lease, isolated evidence directory, stdout/stderr capture, timeout, PASS-marker check and pre/post source-manifest comparison.

## 6. `native-guard vivado-tcl`
Generates a Tcl sign-off report bundle for timing/methodology/DRC/CDC/clock interaction/utilization/route/QoR.

## 7. `native-guard vivado-check`
Fail-closed parser/evaluator. Missing timing fields become `REVIEW_REQUIRED`, never PASS.

## 8. `native-guard log-scan`
Scans Vivado/XSim logs for critical warnings, DRC, CDC, latch, blackbox, multi-driver, overflow/underflow and timing failures.

## 9. `native-guard authority-check`
Detects non-owner edits to protected GOAL/ABI/acceptance/gold files in Git worktrees.

## 10. `native-guard evidence-verify`
Verifies the append-only SHA-256 hash chain of engineering evidence.

## 11. `native-guard doctor`
Detects stale leases, shared build-state directories, dirty worktree and worktree topology risks.
