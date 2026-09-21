# 05 — FE256 AS COMMON-RUNTIME REGRESSION

## 1. FE256 is retained unchanged

R2 does not replace the 256-case benchmark. It changes its role.

Old interpretation:

```text
FE256 pass ≈ major project semantic acceptance
```

R2 interpretation:

```text
FE256 pass = static semantic regression gate
             AFTER runtime knowledge binding is proven
```

## 2. Production path requirement

The final scored path is:

```text
QueryRecord
→ committed generation/root
→ exact directory/index
→ posting/value/context/provenance records
→ bounded walker/frontier
→ candidate/evidence
→ ASTRA proof/status/conflict/completeness
→ StructuredResult
```

The dedicated `fe256_query_path` may remain frozen for:

- known-good regression;
- comparator/reference behavior;
- corruption detection;
- architecture debugging.

It must not be the final product reasoning path.

## 3. Required FE256 sequence

```text
CR01 canonical 256/256
→ CR02 deterministic shuffle 256/256
→ CR03 Pack-A/Pack-B ablation
→ CR04 ASTRA adversarial/status-proof vectors
→ CR05 identity/context/provenance leak checks
→ CR06 common runtime on final product path
→ CR07 UART E2E 32/32
```

All stages must retain exact artifact lineage.

## 4. Current evidence interpretation

A common-runtime `256/256 bit-exact` XSim result is valuable and should be kept as
a candidate regression result. It does **not** satisfy R2 by itself because the
current recorded result explicitly says:

- simulation only;
- common runtime not on the product M4 top;
- no PROGRAM/TIMING/BOARD/ASTRA/FE256 pass claimed.

R2 therefore records it as:

```text
COMMON_RUNTIME_FE256_XSIM = PASS_CANDIDATE
COMMON_RUNTIME_FE256_PRODUCT_TOP = NOT_EVIDENCED
COMMON_RUNTIME_FE256_BOARD = NOT_EVIDENCED
```
