# 09 — CAUSAL ABLATION TESTS

FE256 does not accept correlation-only success.

For each selected baseline answer, create one mutation and preregister the expected effect.

## ABL-EDGE
Remove the only required edge/evidence path.
Expected: ANSWER disappears or changes according to remaining valid evidence.

## ABL-DIRECTION
Flip relation direction without adding the inverse claim.
Expected: original directed query must not continue to pass.

## ABL-CONTEXT
Replace required context with incompatible context.
Expected: no cross-context answer.

## ABL-PROVENANCE
Remove or invalidate the only admissible evidence source.
Expected: proof cannot remain valid.

If the answer survives an ablation that removes its sole preregistered support, the case is FAIL even if the answer text happens to be correct.
