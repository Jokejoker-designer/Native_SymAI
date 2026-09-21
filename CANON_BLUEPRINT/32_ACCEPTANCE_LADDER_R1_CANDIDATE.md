# Acceptance Ladder R1

R1 separates transport correctness, causal runtime memory, semantic correctness and research falsification.

## Static / Board causal ladder

```text
AUDIT_COMPLETE
→ R1_CONTRACT_FROZEN
→ XSIM_SMOKE_PASS
→ POST_ROUTE_CANDIDATE
→ PROGRAM_IDENTITY_RECORDED
→ UART_MUX_8_8_PASS
→ PACK24_UART_24_24_BOARD
→ PACK24_COMMIT_OBSERVATION_PASS
→ PACK_DEST_COMPLETE_BOARD_PASS
→ PACK_ABI24_R1_CANDIDATE
→ RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
→ READBACK_ACTIVE_GENERATION_PASS
→ FE256_R0_REGRESSION_256_256
→ ASTRA_ADVERSARIAL_PASS
→ FE256_R1_256_256_PASS
→ SHUFFLE_PASS
→ CAUSAL_ABLATION_PASS
→ UART_E2E_32_32_PASS
→ FULL_EVIDENCE_R1_BOARD_CANDIDATE
→ OWNER_REVIEW
```

## Meaning of new gates

### `PROGRAM_IDENTITY_RECORDED`

Only records:

```text
bitstream SHA
device/JTAG identity
startup state
route/timing report
```

It is not `PROGRAM_PASS` unless the existing authority definition is explicitly satisfied.

### `PACK24_UART_24_24_BOARD`

All 24 Pack load-side UART outcome/reason tokens match on silicon.

This is useful but **not** full Pack ABI.

### `PACK24_COMMIT_OBSERVATION_PASS`

All six commit cases have positive four-AND COMMIT evidence.

All 18 reject cases have explicit complete negative coverage with `commit_count=0`.

### `PACK_DEST_COMPLETE_BOARD_PASS`

The accepted Pack cases are proven destination-complete, not merely UART-ACK complete.

### `PACK_ABI24_R1_CANDIDATE`

Requires all Pack24 R1 fields including R-04 6/80 and self-contained G-04 6/84.

### `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`

Proves semantic output depends causally on active committed knowledge and follows relocation/generation.

This gate did not exist explicitly enough in R0.1 and is now mandatory before FE256 board semantic promotion.

## Separate research ladders

### NSPF R1 research candidate

Requires the relevant strengthened X0 tests after L0–L2.

### Developmental candidate

Additionally requires:

```text
executed-action credit
reset/restore learning causality
FEM lifecycle
skill lifecycle
unseen-instance transfer
teacher anti-parrot
sensor/action/effect grounding
capability binding + safety veto/readback
fact/candidate/episode/skill/weight separation
checkpoint integrity
```

## No inherited stamps

No R1 candidate run automatically inherits:

```text
PACK_ABI_24_24_PASS
BOARD_PASS
PROGRAM_PASS
TIMING_PASS
MIG_PASS
FE256_PASS
ASTRA_PASS
FEM_PERSIST_PASS
FINAL_PASS
```

Those remain governed by existing authority until the owner explicitly promotes a revised contract.
