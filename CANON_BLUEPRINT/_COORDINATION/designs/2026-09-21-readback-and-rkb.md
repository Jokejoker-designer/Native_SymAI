# Active-generation readback + runtime semantic→physical (2026-09-21)

**Status:** ACTIVE workstream after owner P0 Pack close. Not a PASS stamp.  
**Owner freeze:** R1 Causal is Pack ABI authority. `PACK_ABI_24_24_PASS=NO`.  
**U33OBS_DEBUG:** CLOSED.

Separated from Pack24 MAG/MUTE/TAP-freeze debug. No causal need to overlay H/U33.

## A. Generation is flop-only today (FACT)

`pack_loader` dest port writes **page payload**. `active_generation` is assigned at `S_COMMIT` from UART-parsed `man_generation`. Reset returns `UNSET_GEN`. GOLD dest-complete is `mem_rdata == rg_first[chk_i]` (first written page word).

Therefore TAP four-AND is **flop readback**, not dest-generation readback. Dest hex UART remains `NOT_RUN`.

## B. Query does not dereference Pack dest (FACT)

`exact_directory` `$readmemh("dir_a.mem")`. `posting_walk` `$readmemh("post_a.mem")`. COMMIT does not write HotDirectoryEntry. Class remains `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE` / `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT`.

## C. Next experiments

| ID | Test | Open gate |
|---|---|---|
| GEN-S | Structural selfcheck pack_loader + directory `$readmemh` | PASS_IMPLEMENTED if script rc=0 |
| GEN-X | XSim GOLD then rst → UNSET; dest page ≠ generation | READBACK still NOT_RUN until dest word observed |
| RKB-08 | Poison fixture ROM; query must not silently gold | RUNTIME_KNOWLEDGE_BINDING still NOT_RUN |

Do not stamp `READBACK_ACTIVE_GENERATION_PASS` or `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS` from structural grep.
