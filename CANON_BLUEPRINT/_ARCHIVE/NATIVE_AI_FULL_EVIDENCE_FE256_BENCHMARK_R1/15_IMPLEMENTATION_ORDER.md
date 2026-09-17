# 15 — IMPLEMENTATION ORDER FOR CLOSING FE256

Do not attempt all 256 on board first.

## Gate 0 — Gold/ABI
- freeze canonical gold export,
- generate schema/ABI,
- independent pack readback verifier,
- loader reject tests.

## Gate 1 — Tier-K smoke (8 cases)
- 2 direct,
- 2 values,
- 2 reverse,
- 2 explicit UNKNOWN.

## Gate 2 — FE64
- 16 direct,
- 8 value,
- 8 reverse,
- 8 multihop,
- 8 negative/status,
- 8 identity/context/provenance mixed.

Requires EMPTY=0 before continuing.

## Gate 3 — FE128
Expand relation/value/context/path diversity.

## Gate 4 — FE256
Full preregistered functional acceptance.

## Gate 5 — Scale labels
S / M / L / XL separately.

This sequencing prevents board time from being wasted on schema/front-end bugs that should have been caught at reference/XSim level.
