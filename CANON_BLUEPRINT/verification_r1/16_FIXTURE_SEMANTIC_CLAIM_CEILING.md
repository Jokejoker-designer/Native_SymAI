# Claim ceiling — fixture-backed semantic PASS

**Status:** LOCK 2026-09-21 (owner). Not a PASS stamp.  
**Reason:** RKB-08 CLASS A proved query causally bound to `dir_a.mem`, not Pack dest / `active_generation`.

## Keep the artifacts, lower the claim

Historical semantic results (M2 query-posting XSim rows, FE256 shadow bind XSim, UART StructuredResult smoke, Pack GOLD four-AND, R1 Pack 24/24) remain **evidence of what they actually ran**.

They are **not** proof that product query uses committed runtime knowledge.

```text
PASS against static fixture-backed semantic path
≠
PASS against production runtime knowledge path
```

| Artifact family | May claim | Must not claim |
|---|---|---|
| `exact_directory` / `posting_walk` `$readmemh dir_a.mem/post_a.mem` | Fixture-backed lookup PASS_XSIM | Production runtime knowledge |
| FE256 256-case on dedicated engine / freeze | Reference/diagnostic | Common-runtime FE256_PASS |
| Pack R1 24/24 | P0 transport closed under R1 | `PACK_ABI_24_24_PASS` (legacy name forbidden) |
| M4 UART smoke `0x4E52` fail-closed | UART path CANDIDATE | ASTRA_PASS / BOARD_PASS |
| RKB-08 CLASS A | Causal confirmation of the hole | RKB 8/8 |

## Do not “fix” the ceiling by host-writing T1

A host/TB install into T1 after Pack can make CT1/RKB look green while T1 is a second SoT. That is a **benchmark cheat**, not a product repair.

## Unchanged bans

Do not modify FE256, ASTRA, Q*, SPEAR, FEM, B gold.py, C RTL to rescue this hole.
