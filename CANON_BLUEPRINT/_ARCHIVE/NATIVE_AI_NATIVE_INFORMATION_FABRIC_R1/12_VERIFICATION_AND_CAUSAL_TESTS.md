# 12 — VERIFICATION AND CAUSAL TESTS

## 1. Verification ladder

Reference → RTL unit → XSim → integration → OOC → post-impl → board.

Không dùng board để debug schema cơ bản.

## 2. Binary semantic tests

- exact ID parity compiler/RTL/pack
- model != family
- alias != identity
- relation direction correct
- literal/value round-trip
- context separation
- provenance preserved

## 3. Temporal/wave tests

- action causes expected state change
- delayed reward credits only executed action
- reset restores baseline
- restore recovers learned state
- held-out starting state still works

## 4. Knowledge tests

- DIRECT
- REVERSE
- MULTI-HOP
- NEGATIVE
- UNKNOWN
- CONFLICT

## 5. Ablation

Xóa edge/evidence → answer phải biến mất hoặc trở thành UNKNOWN/CONFLICT tương ứng.

## 6. Parser independence

Cùng một structured query phải cho cùng semantic result dù alias/text khác nhau.

## 7. GEMINI independence

Disable GEMINI language layer nhưng structured reasoning result phải vẫn tồn tại.
