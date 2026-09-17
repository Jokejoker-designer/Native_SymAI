# 12 — BOARD RUN PROTOCOL

## Before run

Record:
- repository commit / dirty state,
- top module,
- Vivado version,
- board/part,
- bitstream SHA256,
- canonical schema SHA256,
- knowledge pack SHA256,
- FE256 cases SHA256,
- acceptance config SHA256,
- UART/transport configuration,
- active ABI version.

## Run order

1. Program board.
2. Arm UART/logger before reset/reseat where applicable.
3. Confirm READY.
4. Execute all 24 Pack/ABI gates on dedicated pack variants or a preregistered loader campaign.
5. Load the frozen valid pack.
6. Read back required sentinel pages/records.
7. Run FE256 in canonical order.
8. Run FE256 in deterministic shuffled order for liveness regression.
9. Run ablation variants.
10. Save raw bytes and decoded records separately.
11. Score offline with `tools/score_results.py`.

## Do not

- patch cases after seeing failures,
- skip a failed case and continue calling the suite PASS,
- convert timeout into UNKNOWN,
- count a renderer string as proof of semantic correctness,
- let host inject winner/proof/answer.
