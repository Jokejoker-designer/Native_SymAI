# Design LOCK — Pack COMMIT → runtime T1 / root (T1 = cache)

**Status:** ARCHITECTURE_LOCKED 2026-09-21 (owner). DESIGN + XSim candidate gate. Not RTL PASS. Not board.  
**Date:** 2026-09-21  
**Owner:** AGENT_D (project lead); lock text ratified by OWNER  
**Trigger:** XSim RKB-08 CLASS A, 6455 ns, `dest_rd=0` at boot / GOLD / reset / poison.  
**Root:** `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT` = **CAUSALLY CONFIRMED IN XSIM**  
**Do not modify:** FE256, ASTRA, Q*, SPEAR, FEM, B `pack_abi24_gold.py`, C RTL.

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not `PACK_ABI_24_24_PASS`. Not `CT1_PASS` until CT1-01..05 close in XSim.

## What XSim proved (FACT)

```text
Pack storage path ≠ runtime knowledge path
```

| Phase | active_generation | query sid `00010100` | dest_rd |
|---|---|---|---|
| boot | UNSET | hit B | 0 |
| load V-04 GOLD | `0000ffff` | same B | 0 |
| reset | UNSET | same B | 0 |
| poison `dir_a.mem` (same Pack dest, same QueryRecord) | UNSET | hit=0 | 0 |

Causal conclusion:

> Query result depends on `dir_a.mem`, not on Pack destination or active committed generation.

`dest_rd=0` in all three phases: no evidence DDR/T2 is on this query path.

Stop at first divergence. Do **not** poison `post_a.mem`.

Evidence class promotion:

```text
WAS:  SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE  = inferred/structural (2026-09-19)
NOW:  DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT = CAUSALLY CONFIRMED IN XSIM
```

Workspace copies: `verification_r1/rkb08/` (not GitHub-published until owner push). Local run: `D:/FPGA/arty_d/rkb_readback/`.

## Forbidden repair

**Do not** make RKB/CT1 PASS by having the host write T1 directory after Pack.

That can fake the benchmark while breaking the product invariant (T1 becomes a second source of truth).

```text
FORBIDDEN: Pack COMMIT  →  host/UART/TB pokes T1  →  query hits T1
```

## Required candidate shape

```text
Pack bytes committed to canonical storage (T2 / dest / DDR)
        │
        ▼
verified Pack metadata / index records
        │
        ▼
S_COMMIT
        │
        ▼
atomic publish of runtime root / directory generation
        │
        ▼
T1 cache MAY populate from that committed source
        │
        ▼
Query semantic_id
        │
        ▼
active-generation directory lookup
        │
        ▼
posting
        │
        ▼
T2 / DDR dereference
```

```text
T1 = cache / hot index of committed knowledge
T1 ≠ second hidden source of truth
```

## Three core invariants

```text
destroy/rebuild T1          → semantics unchanged
change active T2 knowledge  → semantics change
reset active generation     → old knowledge cannot answer
```

## XSim gate before any board thought (CT1-01..05)

See `verification_r1/15_CT1_COMMIT_T1_GATE.md`.

Only after CT1-01..05 PASS_XSIM + independent audit + owner YES: bitstream. Then full RKB-01..08 (relocation, content mutation, edge deref, stale-gen cache, cache parity, support removal, fixture independence).

## Claim ceiling for old semantic PASSes

See `verification_r1/16_FIXTURE_SEMANTIC_CLAIM_CEILING.md`.

```text
PASS against static fixture-backed semantic path
≠
PASS against production runtime knowledge path
```

Keep the evidence. Lower the claim.

## Project split (not a regression)

```text
P0 — reliable Pack transport     CLOSED under R1 (not PACK_ABI_24_24_PASS)
P1 — runtime knowledge causality FAILED current architecture; ROOT CAUSE KNOWN
NEXT: redesign COMMIT → runtime T1/root binding
```

R1 did its job: it caught an architecture that can give a false semantic PASS.

## Incomplete RTL (REJECTED_SHORTCUT)

`arty_d/rkb_readback/pack_t1_install.sv` + the first `pack_runtime_dut.sv` copy dest 128b into T1 and query T1 without:

- UNSET generation fail-closed (CT1-01 / CT1-03)
- dest remaining SoT after T1 flush (CT1-05)
- per-COMMIT republish of root (CT1-04)

Those files are **not** the locked candidate. See `arty_d/rkb_readback/REJECTED_SHORTCUT.md`.
