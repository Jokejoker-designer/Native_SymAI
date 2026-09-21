# CT1 — COMMIT → T1 candidate gate (XSim only)

**Status:** GATE_SPEC. Not PASS. PROGRAM=NO.  
**Owner:** AGENT_D  
**Date:** 2026-09-21  
**Depends on:** RKB-08 CLASS A (`DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT` CAUSALLY CONFIRMED IN XSIM)

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not `PACK_ABI_24_24_PASS`. Not board.

Do not modify FE256 / ASTRA / Q* / SPEAR / FEM / B `pack_abi24_gold.py` / C RTL.  
Do not emit directory packs by editing `pack_abi24_gold.py`. D-owned emitter beside gold.

## Architecture lock (must hold)

```text
T1 = cache / hot index of committed T2 knowledge
T1 ≠ second source of truth
host must not write T1 after Pack to make a test PASS
```

Invariants:

```text
destroy/rebuild T1          → semantics unchanged
change active T2 knowledge  → semantics change
reset active generation     → old knowledge cannot answer
```

## Five tests (all required before any bitstream thought)

```text
CT1-01  boot UNSET → query cannot use stale fixture
CT1-02  Pack A→B COMMIT → query A returns B
CT1-03  reset → active gen UNSET → old B no longer answerable
CT1-04  Pack A→C new generation → same query returns C
CT1-05  rebuild/flush T1 from same active T2 → result remains identical
```

| ID | Setup | Must observe | Fail if |
|---|---|---|---|
| CT1-01 | Power/rst. No Pack. No `dir_a.mem` on query path. | `active_generation=UNSET`. Query A miss/fail-closed. `dest_rd=0` **or** dest read that does not produce B from a fixture. | Same B as RKB-08 fixture (`nb=00020100`) with `dest_rd=0`. |
| CT1-02 | Directory-bearing Pack: A→B. COMMIT. | `active_generation=G_B`. Query A hit B. Dest/T2 on the lookup path (`dest_rd≥1` unless a just-filled T1 cache is proven rebuilt from that dest). | Hit B from leftover `$readmemh`. Host poke T1. |
| CT1-03 | After CT1-02, `rst_n=0`. Dest bytes of B may remain. | `active_generation=UNSET`. Query A cannot return B. | Silent reuse of pre-reset knowledge. |
| CT1-04 | New Pack A→C, new generation, COMMIT. | Query A returns C, not B. | Stale B. T1 leftover. |
| CT1-05 | Same active T2 as CT1-04. Flush T1. Rebuild T1 from dest. Query A. | Result identical to pre-flush (C). | Semantics live only in T1 (flush changes answer without dest rebuild). |

## After CT1

Full RKB-01..08:

```text
relocation
content mutation
edge dereference necessity
stale-generation cache
cache parity
support removal
fixture independence
```

No RKB-01..07 on the **current** `$readmemh` architecture.

## Pass stamp law

Closing CT1-01..05 in XSim is `PASS_XSIM` on this candidate only.

It does **not** stamp:

```text
CT1_BOARD_PASS
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
PACK_ABI_24_24_PASS
PROGRAM_PASS
BOARD_PASS
MIG_PASS
ASTRA_PASS
FE256_PASS
```
