# RUNTIME_KNOWLEDGE_BINDING_8_8 — workstream

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not FE256_PASS.

XSim 20260921T022800Z: **RKB-08 = FAIL_CURRENT_ARCHITECTURE** CLASS A.  
**ROOT_CAUSE** `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT` = **CAUSALLY CONFIRMED IN XSIM** (promoted from inferred `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE`).

Canon copy: `verification_r1/rkb08/`  
Live run: `D:/FPGA/arty_d/rkb_readback/RKB08_FAIL_CURRENT_ARCHITECTURE.md`  
JSON sha256 `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e`.

```text
FIRST_DIVERGENCE: Pack S_COMMIT does not install/update runtime semantic directory root/entry.
Pack storage path ≠ runtime knowledge path
Query causally bound to dir_a.mem; dest_rd=0; dest/T2 not on this query path.
```

Stop: no `post_a.mem` poison. No RKB-01..07 on current architecture.

**NEXT:** Isolated CT1-01..05 PASS_XSIM (`verification_r1/ct1/`, JSON `372ea910…`). Owner PROGRAM=YES 09:52+07; **not programmed** (no CT1 bit; do not nạp `8fc14f25`). Then full RKB after unique identity + audit.

Design lock: `CANON_BLUEPRINT/_COORDINATION/designs/2026-09-21-commit-to-t1-install.md`.  
Claim ceiling: `16_FIXTURE_SEMANTIC_CLAIM_CEILING.md`.

Do not modify FE256, ASTRA, Q*, SPEAR, FEM, B gold.py, C RTL. No program.
