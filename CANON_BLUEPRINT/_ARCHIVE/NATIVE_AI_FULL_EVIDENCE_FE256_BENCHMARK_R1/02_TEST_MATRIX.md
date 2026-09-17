# 02 — FE256 TEST MATRIX

## FE-DIRECT — 48

Purpose: exact typed edge retrieval.

Selection rule:
- choose verified node→relation→node claims,
- preserve exact subject and relation direction,
- cover at least 8 relation kinds when corpus permits,
- include model-specific and family-level facts separately.

Expected: `ANSWER`, exact `answer_ref`, valid proof and provenance.

## FE-VALUE — 32

Purpose: prove the replacement of the old literal/OID hack.

Required mix when corpus permits:
- 12 ranges,
- 8 scalars,
- 4 enum/symbolic values,
- 4 units with same number but different unit semantics,
- 4 boundary/equality checks.

Expected: typed `VALUE` answer; exact value kind/unit; no object-id zero fallback.

## FE-REVERSE — 32

Purpose: prove real inverse/directional retrieval.

Each case is derived from a verified directed edge whose relation has a declared inverse or legal reverse-query rule.

Expected: exact reverse result. The test must not rely on a magic text prefix such as `rev`.

## FE-MULTIHOP — 32

Purpose: prove bounded iterative graph traversal.

Recommended mix:
- 24 two-hop paths,
- 8 three-hop paths.

Gold path is preregistered by canonical IDs. The implementation may find an equivalent valid proof path only if the normalized proof/evidence set satisfies the case policy.

## FE-CONTEXT — 24

Purpose: detect context leakage.

Create paired cases where the same subject/relation has different applicability by model, mode, voltage/frequency regime, version, or other canonical context actually present in the corpus.

At least half should be contrast pairs: X context ANSWER, incompatible Y context UNKNOWN or a different answer.

## FE-PROVENANCE — 16

Purpose: prove source traceability.

Expected:
- answer/proof resolves to allowed provenance IDs,
- provenance record hash/page locator is valid,
- removing the only accepted evidence changes the result in the paired ablation.

## FE-NEGATIVE — 24

Purpose: test epistemic status rather than silence.

Recommended split:
- 12 `UNKNOWN` (known nodes/relation but absent supported claim),
- 4 `UNSUPPORTED_QUERY`,
- 4 `SEARCH_INCOMPLETE` induced by a preregistered reduced search budget,
- 4 negative relation/direction cases.

No `EMPTY` accepted.

## FE-CONFLICT — 16

Purpose: prove opposing evidence is not flattened into ANSWER or UNKNOWN.

Use conflict groups explicitly marked in benchmark gold data. Expected status `CONFLICT` with non-null conflict/proof reference.

## FE-IDENTITY — 16

Purpose: prevent semantic collapse.

Use 8 paired tests:
- exact model vs family,
- sibling model isolation,
- alias A vs alias B mapping to same canonical ID,
- alias change with unchanged semantic result.

## FE-ABLATION — 16

Purpose: causal proof that the result depends on the claimed evidence.

Recommended split:
- 4 remove required edge,
- 4 mutate relation direction,
- 4 switch/remove required context,
- 4 remove required provenance/evidence support.

Every ablation pair must have a preregistered expected semantic delta.
