NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / PACK_ABI_24_24_PASS
RUN_ID: 20260918T172430Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U25 is a new overlay after U24 r1 V-04 n=0. Exclusive board: first GOLD lived (not U21 GOLD-kill) then p5 r2 V-04 n=0. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: uart_r2_u25_candidate.bit sha256 6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902. post_route.dcp sha256 254826761b87bab4b4921994b55ed59e0a78dfafb49d6244abadb7a51f4ae221. JTAG 210319BE776EA End of startup HIGH 00:24:02 +07. COM12 115200 FTDI 210319BE776EB. Frozen U24 bit on disk still 1cb7dad7…. C RTL / H / freeze DCP / Pack24 gold untouched. Overlay: fifo_flush=uart_flush||st_fire; TX.flush=uart_flush; unlocked steer=BEGIN 00800001; query in_valid=0.

OBSERVATION:
- FACT PASS_XSIM: UART_R2_U25_LEFTOVER_XSIM_PASS finish 4892095 ns GOLD after unlocked 00010001. UART_R2_U25_TWO_V04_XSIM_PASS finish 4832065 ns second V-04 GOLD first_p=00800001 dest=mig_ui_bram. U25_XSIM.json.
- FACT: Route LUT 10548 FF 8893 RAMB36=3 RAMB18=2 DSP 8 WNS +0.390 WHS +0.008 observation only. Not TIMING_PASS.
- FACT PASS_BOARD_OBSERVE: Phase4 WARMUP ACK, CLEAR1 ACK, V04 GOLD a5000001 n=4 dt=0.077s.
- FACT FAIL_BOARD: p5 r0 CLEAR n=0 then RETRY ACK then GOLD; r1 ACK+GOLD; r2 ACK then V-04 n=0 dt=12.00s. CLEAR_V04_24.json stop V04 round 2. MAG=0 UNSUP=0.
- FACT: Host WAIT_AFTER_ACK/GOLD=1.0 on same SRAM: Phase4 GOLD then p5 r0 V-04 MAG 0200015a n=4. WAIT1S/CLEAR_V04_24.json. Not a drain fix.
- CONTRADICTED: U25 st_fire FIFO flush is U21 GOLD-kill. First GOLD and two follow-on GOLDs existed.
- CONTRADICTED: U25 24/24 fail class is leftover UNSUP 0200075a. Fail is n=0 after ACK.
- CONTRADICTED: 1s host wait restores dest-complete. It produced MAG.

HYPOTHESES:
- H-ui32-reset-vs-mig0 (INFERENCE): debug_clear resets pack_loader+mig_ui32 via rst_loc while generated mig0 stays live. pack_quiescent uses ui32/loader counters, so CLEAR can ACK while mig0 UI is desynced. Next V-04 hangs. Matches ACK then n=0. XSim bram dest cannot see this.
- H-nth-pack-mig (HYPOTHESIS): Hang appears after N dest-completes (U24 after 2 GOLD, U25 after 3 GOLD), not a fixed round.
- H-idle-uart-inject (INFERENCE): 1s open-port wait after GOLD injected/assembled a word so next V-04 MAG.

HOW_TRACE: U24 r1 n=0 → U25 st_fire flush (not U21 delayed unlock-flush) → XSim leftover+two_v04 PASS_XSIM → exclusive program → p4 GOLD + r0/r1 GOLD → r2 n=0 → WAIT1S MAG.

EVIDENCE_MATRIX:
| claim | class | path |
| leftover/two_v04 XSim | FACT PASS_XSIM | results/PACK24_U25/U25_XSIM.json |
| U25 bit | FACT | build_u25/uart_r2_u25_candidate.bit 6c41ed18… |
| Phase4 GOLD | FACT PASS_BOARD_OBSERVE | CLEAR_V04_24.json V04_0 |
| 24/24 | FAIL_BOARD | CLEAR_V04_24.json round 2 n=0 |
| WAIT1S drain | CONTRADICTED | WAIT1S/CLEAR_V04_24.json MAG |
| PACK_ABI_24_24_PASS | not stamped | PROGRAM_PASS=NO |

SUCCESS_VS_FAILURE:
- Success vs U21: GOLD lived. vs U24: one extra follow-on GOLD (r1).
- Failure: 24/24 and Pack24 dest-complete not met. First divergence p5 r2 V-04 n=0 after ACK.

FIRST_DIVERGENCE: After two successful follow-on GOLD rounds, CLEAR ACK then V-04 never returns. Not UNSUP, not first-GOLD kill.

DECISIVE_TEST: WAIT1S on frozen U25 SRAM produced MAG not GOLD. Next identity must not reset mig_ui32 on debug_clear.

ROOT_CAUSE_OR_UNKNOWN: UART leftover UNSUP CONTRADICTED for this fail. Dest/mig0 vs ui32 reset is INFERENCE. mig0 hang mechanism UNKNOWN until U26 board.

REUSABLE_DECISION_PROCEDURE: After GOLD exists, classify 24/24 fail as UNSUP leftover vs ACK+n=0 dest hang. Do not host-wait as silicon law. Do not patch a FAIL identity. New overlay if debug_clear resets fabric UI in front of live mig0.

STRUCTURAL_GUARD: Freeze U25. U26 pack_mig_bind overlay: debug_clear → pack_loader rst only; mig_ui32 on rst_n. Ban U25 sha in program Tcl.

BLAST_RADIUS: UART_R2/u25 overlay + host wait diag. No C/gold/FE256/H/freeze DCP. PACKAGE pack_mig_bind not overwritten.

VERDICT_BY_LAYER:
- XSim leftover/two_v04: PASS_XSIM (mig_ui_bram, not mig0)
- BOARD Phase4 GOLD: PASS_BOARD_OBSERVE
- BOARD Phase5 24/24: FAIL_BOARD
- PACK_ABI_24_24_PASS / PROGRAM_PASS / TIMING_PASS / MIG_PASS: NO

LESSON_TO_SHARE: GOLD-THEN-NTH-PACK-N0-NOT-HOST-WAIT
NEXT_DECISIVE_EXPERIMENT: U26 overlay, loader-only debug_clear, exclusive program, 24/24 then pack1/2/3. Do not patch U25.
OWNER_AND_STOP_CONDITION: AGENT_D. Goal PACK_ABI_24_24_PASS evidence still open. No M2_STARTING_POINT. No self-stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
