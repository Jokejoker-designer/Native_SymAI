# Proof R1 XSim and open-arm UART 45cd7213 (2026-09-23)

Watch did **not** program. No `.bit` in git. Independent hash of the disk bit equals `45cd72131400aeb99a1fb36dd6bb125ac271725d6692c5ebc5ebf0df904540fb`.

LANGUAGE=EN. Not a product PASS stamp.

```text
GOAL_STATUS = JA_LOOPBACK_ABA_UART_MATCH
NEXT_CUT = PROOF_R1_XSIM_CANDIDATE_NOT_ON_BOARD
BUILD = BIT_OK
WNS = +5.765
WHS = +0.177
PROGRAM = PROGRAMMED
EOS = HIGH
PROGRAM.DONE = NA
JTAG = 210319BE776EA
ARM = OPEN
UART = 00020100 d1000001 00000041
TIMING_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
ASTRA_PASS = NO
FEM_PERSIST_PASS = NO
PACK_ABI_24_24_PASS = NO
```

JA image `e2d97151…` remains on disk and was not deleted. SRAM at program time is this newer image. The open arm has no JA jumper.

Live log hashes match the goal-plan lines, including backups where a later run reused the filename:

- alias `2e84ea43…` finish 225 ns
- proof emit `3c53069f…` finish 275 ns
- proof path `1158037c…` finish 275 ns
- UART-sim top `e7cc9f37…` finish 62035 ns at simulated baud 5000000

Board UART is 115200. Aligned words are answer `00020100`, proof id `D1000001`, word `00000041` (primitive 1, effect 0, proposal 1). ANSWER is not a Canon query status on this capture. The XSim candidate is not the JA image.
