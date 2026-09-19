NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / UART_R2_GOLD
RUN_ID: 20260918T160355Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Exclusive COM produced V-04 GOLD on frozen U20. U22 30s MIG settle still GOLD n=0. GOLD is identity/dest path, not COM mute. Phase5 then ACK+GOLD r0-r4, V-04 r5 UNSUP 0200075a. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Owner COM reserved; continue until GOLD. U22 ba45936f… reprogram+30s settle still V04 n=0. U20 1c3f954f… program End of startup HIGH 23:03:45 +07. JTAG 210319BE776EA COM12. U20/U22 RTL not patched. C/gold/FE256/H untouched.

OBSERVATION:
- FACT: U22 exclusive + MIG_SETTLE_S=30 CLEAR ACK then V04 n=0 12s. Calib-wait CONTRADICTED as sufficient cause. Terminal 836915.
- FACT: U20 exclusive p4: CLEAR1 n=0, RETRY ACK a550eac1, V04 GOLD a5000001 / 010000a5 dt=0.0757s. BOARD_P4_GOLD_EXCL_230355.json sha256 dd4b16fbb69593cd2604ba76f41865533c5ecfd5e60b9c93e29bba98131a3a57.
- FACT: Same SRAM p5: CLEAR+GOLD rounds 0-4; round 5 V04 UNSUP 5a070002 / 0200075a. CLEAR_V04_24.json sha256 5590b3506ade0cb02b46e323da852eb0fd57f13b55981b4900249532617836b6 stop V04 round=5 n0=0 mag=0.
- INFERENCE: U22 pack_lock-without-GOLD is U21/U22 overlay/P&R vs U20 dest-complete path (TX.flush=0 and clr_ack_ready=mux_ready are U22 deltas; dest readback hang still UNKNOWN for U22).
- CONTRADICTED: GOLD impossible on this board tonight; GOLD n=0 as COM contention (U20 GOLD exclusive).

HYPOTHESES:
- H-U22-dest (strengthened): U22/U23 dest-complete after lock does not match U20. Do not patch U22.
- H-unsup-r5 (INFERENCE): extra GOLD then unlocked 0 → R_UNSUP, U18 class. Not this GOLD run's stop.

HOW_TRACE: U22 30s settle fail → U20 exclusive p4 GOLD → p5 r5 UNSUP.

EVIDENCE_MATRIX:
| claim | class | path |
| U20 GOLD | FACT | BOARD_P4_GOLD_EXCL_230355.json |
| U22 GOLD after 30s | CONTRADICTED | 836915 V04 NONE |
| Phase5 24/24 | FAIL_BOARD | CLEAR_V04_24.json r5 UNSUP |
| BOARD_PASS | not stamped | PROGRAM_PASS=NO |

SUCCESS_VS_FAILURE:
- Success: owner stop GOLD met on U20 exclusive.
- Failure: U22 still no GOLD. p5 not 24/24.

FIRST_DIVERGENCE: U20 V-04 GOLD 76ms vs U22 V-04 n=0 12s after exclusive CLEAR ACK.

DECISIVE_TEST: Already run — same COM, U22 vs U20. Next 24/24 is UNSUP-after-GOLD, new identity, do not patch U20.

ROOT_CAUSE_OR_UNKNOWN: GOLD missing on U22 UNKNOWN (dest/P&R). GOLD present on U20 FACT.

REUSABLE_DECISION_PROCEDURE: If pack_lock without GOLD, retest last identity that had GOLD under exclusive COM before a new overlay. 30s calib settle is not a substitute.

STRUCTURAL_GUARD: Freeze U20 and U22. No flush overlay for GOLD-miss. SRAM last-writer U20 after r5 UNSUP.

BLAST_RADIUS: u20/u22 host campaign kill_jtag/settle. No C/gold/FE256/H. GOAL_M* PROGRAM.txt not this run's watch.

VERDICT_BY_LAYER:
- BOARD V-04 GOLD U20: PASS_BOARD_OBSERVE (not BOARD_PASS)
- BOARD V-04 GOLD U22: FAIL_BOARD
- Phase5 24/24: FAIL_BOARD r5 UNSUP
- PACK_ABI_24_24_PASS / PROGRAM_PASS / M1 READY: NO

LESSON_TO_SHARE: GOLD-U20-EXCL-NOT-U22-SETTLE
NEXT_DECISIVE_EXPERIMENT: For 24/24, new identity for UNSUP-after-repeated-GOLD. Do not patch U20. Do not expect U22 GOLD from settle.
OWNER_AND_STOP_CONDITION: AGENT_D. GOLD stop met. No M2_STARTING_POINT.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
