# 14 — LEGACY D1–D5 MAPPING

The old 135-case D1–D5 campaign remains historical evidence. Do not rewrite its expected outputs or delete its failures.

Its useful categories map into FE256 as follows:

| Legacy | FE256 successor |
|---|---|
| D1 Direct | FE-DIRECT + FE-VALUE |
| D2 Reverse | FE-REVERSE |
| D3 Multi-hop | FE-MULTIHOP |
| D4 Negative | FE-NEGATIVE + FE-CONFLICT |
| D5 Unknown | FE-NEGATIVE explicit statuses |

Important changes:
- FE256 uses structured Native Semantic Query as the primary input.
- `EMPTY` is never a valid outcome.
- range/value queries have typed ValueRecords.
- reverse is tested by semantic direction/inverse registry, not text prefixes.
- proof/provenance/context are scored explicitly.
- human parser parity is a separate gate.

The historical 2 PASS / 17 MISS_REFUSE / 116 EMPTY result should remain available as a regression baseline, not be reclassified post hoc.
