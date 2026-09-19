# JTAG collision — U19 vs GOAL_M1 (same Arty)

SRAM is one image. Two agents programmed `210319BE776EA` in the same minutes.
The 17:20 Phase4 MAG run is **not** U19 silicon evidence.

PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO

## Identities

| Lane | File | SHA256 | Size |
|---|---|---|---|
| UART_R2 U19 (this agent) | `D:/FPGA/arty_d/UART_R2/build_u19/uart_r2_u19_candidate.bit` | `cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576` | 1985681 |
| GOAL_M1 (parallel tree) | `D:/NATIVEAI_FULL_EVIDENCE/CANON_BLUEPRINT/work/goal_m1/goal_m1_uart_ingest_candidate.bit` | `c0bdcce496366c3cc89184a011a45b6cef7e6cc5a97a1d37a75592954ebd72e7` | 1880985 |

## Timeline (local +07, 2026-09-18) — FACT from file mtimes / logs

| Time | Event |
|---|---|
| 17:03 | GOAL_M1 first JTAG (`vivado_103_program.log`) |
| 17:14:13 | U19 bit file on disk (unchanged; this retest did not rebuild) |
| 17:15:05–17:15:25 | This agent first U19 program (`836891`) |
| 17:16:03 | This agent Phase4 GOLD then Phase5 CLEAR n=0 (may still be U19) |
| 17:16:52–17:17:39 | GOAL_M1 **reprogram** overwrites SRAM (`vivado_103_reprogram.log`, `PROGRAM.txt`) |
| 17:17:48 | GOAL_M1 hop-1 UART 48-byte StructuredResult |
| 17:17:52 | GOAL_M1 BEGIN-zero-header NAK `rx_hex=5a010002` reason `0x01` |
| 17:19:27–17:19:47 | This agent U19 retest program (`836893`, `program_retest.log`) |
| 17:20:26–17:20:27 | This agent Phase4 CLEAR ACK then V-04 `5a010002` MAG — VOID |
| 17:27:25 | Exclusive U19 program (`program_exclusive.log`) SHA `cecb020f…` End of startup HIGH |
| 17:28:21 | Exclusive CLEAR1 ACK |
| 17:28:34 | Exclusive V-04 n=0 (12 s timeout) — U19 first-fail |
| 17:30:40–43 | Same-SRAM retry CLEAR n=0 twice. GOAL_M1 `PROGRAM.txt` still 17:17:39 |

## Why MAG is contaminated (FACT + INFERENCE)

FACT — GOAL_M1 BEGIN-NAK board capture is `5a010002` (`UART_PACK_BEGIN_NAK_BOARD.json`).
FACT — U19 17:20 V-04 host record is the same 4 bytes (`BOARD_BASELINE_CONTAMINATED_goal_m1.json`).
INFERENCE — at 17:20 the UART was answering the GOAL_M1 ingest NAK path (or a torn last-writer race), not a clean U19 GOLD path.
CONTRADICTED — treating `stop=V04_0 MAG` as U19 first-divergence.

Do not patch U19 from MAG. Exclusive first-fail is V-04 n=0, not MAG.
