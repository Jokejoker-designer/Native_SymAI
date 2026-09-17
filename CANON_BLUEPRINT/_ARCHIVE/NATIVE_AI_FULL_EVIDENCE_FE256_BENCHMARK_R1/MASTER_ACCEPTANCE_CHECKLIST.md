# MASTER ACCEPTANCE CHECKLIST — FE256 R1

## Authority / freeze
- [ ] Canonical schema authority identified
- [ ] Gold source frozen + SHA256
- [ ] Cases generated before board result is known
- [ ] Cases SHA256 frozen
- [ ] Acceptance config SHA256 frozen
- [ ] Bitstream SHA256 recorded
- [ ] Knowledge pack SHA256 recorded

## Pack / ABI
- [ ] 24/24 integrity gates PASS
- [ ] no best-effort load
- [ ] valid pack readback parity PASS
- [ ] generation atomicity PASS

## Core FE256
- [ ] DIRECT 48/48
- [ ] VALUE 32/32
- [ ] REVERSE 32/32
- [ ] MULTIHOP 32/32
- [ ] CONTEXT 24/24
- [ ] PROVENANCE 16/16
- [ ] NEGATIVE 24/24
- [ ] CONFLICT 16/16
- [ ] IDENTITY 16/16
- [ ] ABLATION 16/16

## Cross-cutting
- [ ] explicit result 256/256
- [ ] EMPTY 0
- [ ] timeout 0
- [ ] wrong answer 0
- [ ] false refusal 0
- [ ] txn mismatch 0
- [ ] context leak 0
- [ ] identity leak 0
- [ ] required proof valid 100%
- [ ] required provenance valid 100%

## Liveness / ordering
- [ ] canonical order PASS
- [ ] deterministic shuffled order PASS
- [ ] malformed/unsupported query cannot poison following transaction

## Claim discipline
- [ ] FE256 PASS does not claim self-learning
- [ ] FE256 PASS does not claim natural-language understanding
- [ ] FE256 PASS does not imply scale label not physically tested
- [ ] owner Board Pass not auto-issued
