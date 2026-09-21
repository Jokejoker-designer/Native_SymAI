# Runtime Knowledge Binding R1

## Gate

```text
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
```

This is the missing causal gate between successful Pack storage and FE256 semantic acceptance.

## Why it exists

A system can pass static semantic tests while:

```text
Pack → DDR
Query → dir_a.mem / post_a.mem
```

If so, the semantic answer does not depend on the active committed Pack.

R1 therefore requires interventions on the physical source of truth.

## Eight cases

### RKB-01 — Install

Pack generation G1 at physical placement P1:

```text
A --R--> B
```

Query A must return B **and** the trace must show the lookup/dereference path reaching G1/P1.

### RKB-02 — Relocation

Relocate the same semantic graph from P1 to P2. Poison or invalidate P1.

Same QueryRecord must still return B and the observed physical dereference must use P2.

### RKB-03 — Content mutation

At the active placement change only canonical content:

```text
A --R--> B
```

to:

```text
A --R--> C
```

Keep the QueryRecord identical. Result must change B→C.

### RKB-04 — Edge dereference necessity

Keep directory/posting structure the same but invalidate/corrupt only the referenced canonical EdgeRecord.

The system must fail closed or emit the preregistered integrity/status result.

### RKB-05 — Generation switch with stale cache

Warm T1/cache on G1 (`A→B`), commit G2 (`A→C`), and query without manually clearing semantic caches.

Result must be C and stale G1 must not influence proof/result.

### RKB-06 — Cache parity

Same generation/query with cache enabled and disabled:

```text
semantic result/proof identical
```

Only performance metadata may differ.

### RKB-07 — Runtime knowledge removal

Remove the sole supporting relation from the active Pack while keeping host fixtures unchanged.

The result must change to the preregistered unsupported/unknown result.

### RKB-08 — Host/fixture independence

Disable or poison any compile-time directory/posting/expected-neighbor fixture that is not the declared runtime source.

The production query must either continue from canonical runtime memory or fail closed. It must not silently obtain the gold answer from the fixture.

**XSim 2026-09-21:** RKB-08 on current RTL is CLASS A. `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT` = CAUSALLY CONFIRMED IN XSIM. See `rkb08/` and `15_CT1_COMMIT_T1_GATE.md`. Do not run RKB-01..07 until CT1-01..05 pass on a COMMIT→T1 candidate where T1 is a cache of committed T2.

## Required causal evidence

For every case record:

```text
query_id / txn_id
active_generation
semantic_id
directory source
posting source
physical pointer/root
DDR/T2 read transaction identity
retrieved record identity
ASTRA/result dependency
```

A raw “DDR read happened” is insufficient. The read must be causally necessary to the returned semantic result.

## Gate rule

FE256 board acceptance may not be promoted unless `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS` is closed first on the same declared runtime lineage.
