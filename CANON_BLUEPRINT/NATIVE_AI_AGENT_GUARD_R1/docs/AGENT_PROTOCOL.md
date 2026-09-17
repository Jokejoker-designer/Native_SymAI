# Multi-Agent Execution Protocol — Native AI

## Mandatory rules

1. **One agent = one Git worktree + one branch.** Never share Vivado `.runs`, `.Xil`, generated IP, or build directories.
2. Before editing a shared/canonical file, acquire a file or authority lease. Protected canon/gold/acceptance files are not agent-editable without owner workflow.
3. Before synthesis/implementation, freeze a source contract manifest. The build wrapper hashes sources before and after the run; any mid-build source mutation fails the run.
4. Vivado implementation, JTAG, UART, and board access use exclusive resource leases.
5. A functional patch invalidates all downstream gates. Rerun from the earliest affected gate.
6. Negative evidence is append-only. Never replace a failed log with a later PASS log.
7. No agent may self-declare OWNER_ACCEPTED, BOARD_PASS, FINAL_FREEZE, or modify benchmark gold/thresholds to obtain a PASS.
8. Every run records: source hashes, XDC hashes, tool version, top/part, run strategy/seed, report hashes, bitstream SHA256, pack/ABI hashes, and raw logs.

## Recommended agent roles

- **RTL Agent:** owns a bounded RTL module family only.
- **Constraints/Timing Agent:** owns XDC, clock contract, CDC review, timing closure evidence; does not change functional RTL without a new task.
- **Verification Agent:** owns TB/assertions/reference vectors; cannot edit RTL and gold in the same task.
- **Pack/ABI Agent:** owns compiler/verifier/ABI; compiler and verifier should not share the same encode/decode helper.
- **Integration Agent:** merges only artifacts whose lower gates PASS.
- **Board Agent:** sole holder of board/JTAG/UART lease during physical runs.
- **Evidence Agent:** seals manifests/hashes and checks claim ceiling.

## Handoff minimum

Every task handoff must include: source commit, changed files, contract hash, tests run, exact first failing gate, unresolved warnings, timing/resource delta, generated artifacts and hashes, and whether downstream evidence was invalidated.
