NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / UART_R2_U22_EXCL_PACK24
RUN_ID: 20260918T155410Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: With COM reserved, frozen U22 is not CLEAR-mute. Exclusive Phase4 CLEAR ACK then PA24-V-04 GOLD n=0. Retry CLEAR is BUSY. U23 ELA pack_lock=1 while GOLD never returns. First-fail is dest/pack complete, not UART first-word. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Owner COM reserved. U22 bit D:/FPGA/arty_d/UART_R2/build_u22/uart_r2_u22_candidate.bit SHA256 ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9 program End of startup HIGH 22:48:14 +07. U23 observe dfea894f… program 22:53:35 +07 for pack_lock ELA only. JTAG 210319BE776EA. COM12 115200 FTDI 210319BE776EB. U22 RTL not patched. C RTL untouched. Pack24 gold unchanged. Freeze/H untouched.

OBSERVATION:
- FACT: Exclusive U22 p4p5 CLEAR1 ACK a550eac1 n=4 dt=0.0607s. Prior U22 FAIL CLEAR1 n=0 CONTRADICTED under COM lease. Artifact BOARD_BASELINE_EXCL_CLEAR_ACK_V04_N0.json sha256 bac26a46e4a7f2f4b49dc7ecdb61cc4a679d974f536a99ea03a774675b6e1a3c.
- FACT: Same session V04_0 NONE n=0 dt=12.005s. PA24-V-04 is 52 words / 208 bytes.
- FACT: No-reprogram retry CLEAR1 BUSY b550eac1 / c1ea50b5 n=4. Artifact BOARD_BASELINE_EXCL_CLEAR_BUSY.json sha256 88a3992c80536733d52ddf908bff6920eff78bb2521cd648da9a9d4f4d11704a.
- FACT: Exclusive U23 p4ela_pack_v04: CLEAR ACK then V04 n=0 12.048s. ELA trigger pack_lock: done=true. trig_win lock 0→1, fifo_empty 1→0→1, w_valid 1→0, mux_valid=0, uart_tx_valid=0, clr_st=IDLE. BOARD_U23_V04.json sha256 e0b838459c0f2514068d10f90f58ca16e6d92ab83c0cd4aaff990a55b96e5488. ELA_DECODEPACK_V04.json sha256 9f912831a339f1a84dc5bf798eed62e9968586c4def3cec0d48ba66b31f05a9c.
- INFERENCE: V-04 BEGIN/pack is accepted (pack_lock). GOLD TX never. Sticky BUSY = lock held.
- CONTRADICTED: U22 CLEAR1 silicon mute; V-04 n=0 as COM contention (ACK then BUSY on same COM).
- UNKNOWN: why dest/GOLD never after lock (MIG/UI/pack_loader complete vs CDC word 4e008001 vs BEGIN 00800001).

HYPOTHESES:
- H-dest (strengthened): pack_lock without GOLD in 12s + BUSY = destination/MIG/pack complete hang. Same class as U21 V-04 n=0. U22 fifo_flush revert did not restore U20 GOLD.
- H-word (UNKNOWN): w_data 4e008001 at lock (V-04 word1 is 3149414e) may be bus mash or later word; not proven corrupt BEGIN.
- H-flush (CONTRADICTED as this fail): another UART flush overlay would not make GOLD; CLEAR UART already ACK.

HOW_TRACE: exclusive U22 program → p4p5 CLEAR ACK / V04 n=0 → p4 retry BUSY → U23 program → ELA pack_lock → CLEAR ACK / V04 n=0 / lock=1.

EVIDENCE_MATRIX:
| claim | class | path |
| exclusive U22 CLEAR ACK | FACT | BOARD_BASELINE_EXCL_CLEAR_ACK_V04_N0.json |
| V-04 GOLD n=0 12s | FACT | same; BOARD_U23_V04.json |
| retry CLEAR BUSY | FACT | BOARD_BASELINE_EXCL_CLEAR_BUSY.json |
| pack_lock taken | FACT | ELA_DECODEPACK_V04.json trig_win |
| U22 CLEAR1 mute silicon | CONTRADICTED | exclusive ACK |
| BOARD_PASS | not stamped | PROGRAM_PASS=NO |

SUCCESS_VS_FAILURE:
- Success: COM lease made CLEAR classifiable; ELA proved pack enter.
- Failure: Phase4 GOLD missing. Pack24 24/24 not started. M1 not READY.

FIRST_DIVERGENCE: After exclusive CLEAR ACK, first V-04 has no GOLD while pack_lock=1.

DECISIVE_TEST: Already run — exclusive U22 V-04 + BUSY retry + U23 pack_lock ELA. Next is dest/MIG complete observe, not UART flush identity.

ROOT_CAUSE_OR_UNKNOWN: UART first-word mute closed for this COM lease. Remaining UNKNOWN is pack dest-complete/GOLD after lock.

REUSABLE_DECISION_PROCEDURE: After exclusive CLEAR ACK, classify V-04 n=0 by a second CLEAR: ACK=never-took, BUSY=took-and-stuck. Confirm with pack_lock ELA. Do not add RX flush for GOLD-miss.

STRUCTURAL_GUARD: Freeze U22. U23 observe only. Ban new flush overlay for this class. No M2_STARTING_POINT. No PASS self-stamp.

BLAST_RADIUS: U22 campaign host kill_jtag/COM retry; U23 p4ela_pack_v04 mode; PACK24_U22/U23 JSON. SRAM last-writer U23 dfea894f… after V-04 lock. U22 RTL frozen. C/gold/FE256/H untouched. GOAL_M* PROGRAM.txt SAME.

VERDICT_BY_LAYER:
- BOARD CLEAR exclusive: PASS_BOARD_OBSERVE ACK (not BOARD_PASS)
- BOARD V-04 GOLD: FAIL_BOARD n=0
- ELA pack_lock: PASS_BOARD_OBSERVE lock=1
- PACK_ABI_24_24_PASS / PROGRAM_PASS / M1 READY: NO

LESSON_TO_SHARE: PACK-V04-LOCK-WITHOUT-GOLD-NOT-UART-MUTE
NEXT_DECISIVE_EXPERIMENT: Dest/MIG complete probe on observe identity (pack_lock held, GOLD never). Do not U24 flush. Do not Pack24 until GOLD exists.
OWNER_AND_STOP_CONDITION: AGENT_D. Stopped at first GOLD miss + BUSY + pack_lock. No M2_STARTING_POINT.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
