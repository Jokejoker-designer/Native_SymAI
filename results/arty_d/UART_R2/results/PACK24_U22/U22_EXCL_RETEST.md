# U22 exclusive retest — COM reserved 2026-09-18T22:48+07

Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
Do not patch U22.

BIT_SHA256 = ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9
JTAG End of startup HIGH 22:48:14 +07
COM12 exclusive (owner reserved; no twogen holder)

## FIRST_FAILING_PHASE (exclusive)

4 — V04_0 after CLEAR1 ACK

## FIRST_FAILING_CASE

PA24-V-04 GOLD n=0 dt=12.005s

## LAST_GOOD_EVENT

CLEAR1 ACK a550eac1 n=4 dt=0.0607s (`BOARD_BASELINE_EXCL_CLEAR_ACK_V04_N0.json`)

## FIRST_BAD_EVENT

V04_0 NONE n=0 12s. Same session as CLEAR ACK (COM live).

## RETRY SAME SRAM (no reprogram)

CLEAR1 BUSY b550eac1 / c1ea50b5 (`BOARD_BASELINE_EXCL_CLEAR_BUSY.json`)

Fabric still in a transaction after the mute GOLD. V-04 mute is not host COM loss.

## Vs prior U22 FAIL

Prior exclusive-claimed CLEAR1 n=0 twice is CONTRADICTED under COM lease.
That n=0 class was COM/JTAG sharing (see U23 20260918T154038Z).

## Vs U21

Same class: CLEAR ACK then V-04 n=0. U22 fifo_flush=uart_flush-only did not restore U20 GOLD.

## ROOT_CAUSE_STATUS

UNKNOWN dest/pack/MIG complete path. Named: V-04 taken or lock held (BUSY) without GOLD.
Do not new UART flush overlay.
