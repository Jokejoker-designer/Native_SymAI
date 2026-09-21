# Migration Plan — R0.1 → R1

## Do not mutate historical evidence

Keep these as frozen historical/reference artifacts:

```text
CANON_BLUEPRINT/31_VERIFICATION_AND_CAUSAL_TESTS.md
CANON_BLUEPRINT/32_ACCEPTANCE_LADDER.md
verification/pack_abi24/pack_abi24_gold.py
verification/fe256/fe256_gold.py
```

Do not rewrite them merely because the current DUT disagrees with a field.

## Recommended side-by-side repo layout

```text
CANON_BLUEPRINT/verification_r1/
  README.md
  pack_abi24_r1/
    pack24_r1_expected.json
    pack24_r1_compare.py
    PACK_ABI24_R1_CONTRACT.md
  uart_mux_r1/
    UART_MUX_ARBITRATION_R1.md
  runtime_binding_r1/
    RUNTIME_KNOWLEDGE_BINDING_R1.md
  fe256_r1/
    FE256_AND_ASTRA_R1.md
  nspf_x0_r1/
    NSPF_X0_R1.md

CANON_BLUEPRINT/31_VERIFICATION_AND_CAUSAL_TESTS_R1_CANDIDATE.md
CANON_BLUEPRINT/32_ACCEPTANCE_LADDER_R1_CANDIDATE.md
```

## Promotion sequence

```text
1. Owner reviews R1 semantics.
2. Agent B independently audits comparator/gold independence.
3. Agent D binds observations without importing expected values.
4. Agent C audits causal false-pass paths.
5. Run R1 as candidate beside R0.1.
6. Resolve disagreements by authority decision, not DUT convenience.
7. Only owner promotes R1 to Canon.
```

## Required “no rescue” rule

A benchmark change is valid only if it is justified by a clearer semantic/causal contract and applied consistently to future DUTs.

Invalid reason:

```text
"current DUT would pass if we changed this field"
```

Valid reason:

```text
"the old Boolean field conflated no-COMMIT with an observed false transition;
R1 now requires explicit negative COMMIT coverage"
```

## Current recommended first implementation

Implement only these three R1 additions first:

```text
UART_MUX_8_8_PASS
PACK24 negative COMMIT coverage
PACK_DEST_COMPLETE_BOARD_PASS
```

Then close Pack R1 before opening the full runtime-binding work.
