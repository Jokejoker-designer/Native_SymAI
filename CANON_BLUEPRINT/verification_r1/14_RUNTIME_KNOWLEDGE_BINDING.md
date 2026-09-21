# RUNTIME_KNOWLEDGE_BINDING_8_8 — workstream

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not FE256_PASS.

XSim 20260921T022800Z: **RKB-08 = FAIL_CURRENT_ARCHITECTURE** CLASS A.
Evidence: `D:/FPGA/arty_d/rkb_readback/RKB08_FAIL_CURRENT_ARCHITECTURE.md`
JSON sha256 `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e`.

```text
FIRST_DIVERGENCE: Pack S_COMMIT does not install/update runtime semantic directory root/entry.
ROOT_CAUSE: DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT
```

Stop: no `post_a.mem` poison. No RKB-01..07 until a COMMIT→T1 candidate exists.

Design (not RTL): `CANON_BLUEPRINT/_COORDINATION/designs/2026-09-21-commit-to-t1-install.md`.

Do not modify FE256, ASTRA, Q*, SPEAR, FEM, B gold.py, C RTL. No program.
