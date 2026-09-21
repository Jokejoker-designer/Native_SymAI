# RKB-08 = FAIL_CURRENT_ARCHITECTURE

RUN_ID: 20260921T022800Z  
OWNER: AGENT_D  
PROGRAM: NO  
Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not `PACK_ABI_24_24_PASS`.  
FE256 / ASTRA / Q* / SPEAR / FEM / B gold / C RTL: **not modified**.

XSim `$finish` 6455 ns. Log sha256 `4a7c22203c62e3107b6036aa6c33d601a24d2be43daa35a60c4e1f4ac6ddab7d`.  
JSON sha256 `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e`.

Class promotion 2026-09-21 (owner):

```text
DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT
= CAUSALLY CONFIRMED IN XSIM
```

Prior 2026-09-19 name `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE` remains the structural analysis; RKB-08 is the causal confirmation.

## Test 1 — Generation lifecycle (register) PASS_XSIM

```text
boot  active_generation = ffffffff  UNSET_OK=1
GOLD  V-04 ack=1 reason=00          gen=0000ffff  G_OK=1
reset active_generation = ffffffff  UNSET_OK=1
```

QueryRecord `subject_id=00010100` (first `dir_a.mem` entry) at every step:

| Phase | hit | neighbor | edge_ref | dest_rd |
|---|---|---|---|---|
| boot UNSET | 1 | 00020100 | 00000020 | 0 |
| after GOLD G | 1 | 00020100 | 00000020 | 0 |
| after reset UNSET | 1 | 00020100 | 00000020 | 0 |

`knowledge_after_rst_same_as_gold = 1`. Dest was never read on the query path.

## Test 2 — RKB-08 dir poison CLASS A (observed, not predicted-in-TB)

Pack dest / GOLD leftover left in place. Only `exact_directory.rom[0][31:0]` `00010100` → `00000000`. Same QueryRecord.

```text
before poison sid0=00010100
after  poison sid0=00000000  pack_gen still UNSET (post-reset)
query        hit=0 nb=0 eref=0 dest_rd=0 dest_wr=0
RKB08_CLASS  A
```

Answer changed/failed when the **static directory fixture** changed. No causal DDR/pack dest lookup (`dest_rd=0`).

```text
RKB-08 = FAIL_CURRENT_ARCHITECTURE

FIRST_DIVERGENCE:
Pack S_COMMIT does not install/update
runtime semantic directory root/entry.

ROOT_CAUSE:
DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT
= CAUSALLY CONFIRMED IN XSIM
```

Stop: no `post_a.mem` poison. No RKB-01..07 this run.

## Next (owner lock)

T1 = cache of committed T2. Host must not write T1 after Pack.  
CT1-01..05 XSim before board. See `15_CT1_COMMIT_T1_GATE.md`.
