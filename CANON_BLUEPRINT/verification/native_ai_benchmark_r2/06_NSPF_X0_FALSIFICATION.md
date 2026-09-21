# 06 — NSPF-X0 FALSIFICATION CAMPAIGN

The purpose of NSPF-X0 is to answer a stronger question than FE256:

> Is the observed behavior caused by the intended semantic structure, or by
> accidental IDs, fixed fixtures, order, timing, cache state or memorized cases?

## Test set

| ID | Intervention | Expected invariant / change |
|---|---|---|
| X0-01 | Permute canonical IDs consistently | Same semantics, new IDs. |
| X0-02 | Change aliases/labels only | Same canonical semantics. |
| X0-03 | Relocate records physically | Same semantics, different physical trace. |
| X0-04 | Shuffle query order | Same case results. |
| X0-05 | Cache on vs flushed/off | Same semantics; work/latency may differ. |
| X0-06 | Change physical clock / preserve logical semantics | Same logical result within legal timing. |
| X0-07 | Inject bounded DDR stalls/jitter | Same semantics or explicit timeout only if preregistered bound exceeded. |
| X0-08 | Mask one role/slot and require inference/transfer | Correct fill only if support exists; no lookup leak. |
| X0-09 | New instance with same relational role | Transfer without hard-coded instance ID. |
| X0-10 | Remove sole support edge/record | Previous answer must disappear/change. |
| X0-11 | Inject verified contradictory support | ASTRA must emit conflict law, not pick by utility. |
| X0-12 | Swap generation with stale cache retained | New generation wins; stale result rejected. |

## Anti-cheating requirements

A test is invalid if:

- gold answer is directly visible to DUT logic;
- host sends winner/answer/proof;
- intervention changes more than the preregistered causal variable;
- test and expected output share one unverified exporter that could reproduce the
  same bug on both sides;
- only latency is checked while semantic output is constant;
- the same instance/case is repeated and counted as independent transfer.

## Research claim ceiling

Passing X0 supports only the exact tested forms of invariance/transfer.
It does not establish general intelligence or open-domain abstraction.
