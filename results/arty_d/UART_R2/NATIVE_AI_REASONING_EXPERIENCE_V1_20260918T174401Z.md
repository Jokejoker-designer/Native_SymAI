NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / PACK_ABI_24_24_PASS
RUN_ID: 20260918T174401Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U26 exclusive FAIL_BOARD r1 V-04 n=0. U27 soft CLEAR CONTRADICTED in XSim. U28 XSim leftover+four GOLD PASS_XSIM. Owner: do not program. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: U26 bit sha256 8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375 programmed 00:42:25 +07 End of startup HIGH then campaign. First open COM12 Access Denied GOAL_M1 probe_pack24_ack4.py PID 48496; killed; retry exclusive. U25/U26 RTL not patched. C/H/freeze/gold untouched. U27/U28 new overlays. PROGRAM after this run = NO.

OBSERVATION:
- FACT PASS_BOARD_OBSERVE: U26 Phase4 WARMUP ACK, CLEAR1 ACK, V04 GOLD a5000001 n=4. p5 r0 ACK+GOLD.
- FACT FAIL_BOARD: p5 r1 CLEAR n=0, RETRY ACK, V04 n=0 dt=12.04s. CLEAR_V04_24.json stop V04 round 1.
- FACT: U26 first campaign after JTAG: COM12 PermissionError. Not a silicon mute law.
- CONTRADICTED: H-ui32-reset-vs-mig0 as 24/24 fix. U26 loader-only reset failed earlier than U25 (r1 vs r2).
- FACT PASS_XSIM: U27 leftover PASS. U27 four V-04 FAIL V04_2 mute 27167995 ns dest=mig_ui_bram. Soft CLEAR (debug_clear=0) CONTRADICTED. U27 not programmed.
- FACT PASS_XSIM: U28 leftover 4892095 ns. Four V-04 GOLD 9663615 ns. debug_clear resets loader+ui32 then SETTLE 2048 ui_clk.
- FACT: Owner 00:51 +07: không program.

HYPOTHESES:
- H-loader-reset-required (INFERENCE): Repeated V-04 on bram needs debug_clear of pack_loader. U27 XSim mute at V04_2.
- H-mig0-after-clear (HYPOTHESIS): Board hang after N GOLD+CLEAR is mig0 UI vs fabric reset. U28 holds reset SETTLE after clear. Unproven on board (program held).
- H-nth-pack-noise (HYPOTHESIS): U24/U25/U26 fail round 1–2 is the same dest class, not a strict N.

HOW_TRACE: U25 r2 n=0 → U26 split ui32 reset → COM collide → exclusive r1 n=0 → U27 no debug_clear XSim fail → U28 settle after clear XSim pass → program NO.

EVIDENCE_MATRIX:
| claim | class | path |
| U26 GOLD then r1 n=0 | FACT FAIL_BOARD | results/PACK24_U26/CLEAR_V04_24.json |
| U26 COM denied | FACT | 836931 SerialException COM12 |
| U27 four V-04 | FAIL_XSIM | results/PACK24_U27/U27_XSIM_FAIL.md |
| U28 leftover/four V-04 | FACT PASS_XSIM | results/PACK24_U28/U28_XSIM.md |
| PACK_ABI_24_24_PASS | not stamped | PROGRAM=NO this run |

SUCCESS_VS_FAILURE:
- Success: U26 first GOLD lived; U28 XSim four GOLD with settle.
- Failure: 24/24 not met. U26 FAIL_BOARD. U27 not a candidate. Board program held.

FIRST_DIVERGENCE: U26 vs U25 is earlier ACK+n=0 (r1 vs r2), same class. U27 vs U25 is missing debug_clear, visible in XSim at V04_2.

DECISIVE_TEST: U27 XSim without debug_clear fails third V-04 on bram. U28 with settle still PASSes four GOLD on bram.

ROOT_CAUSE_OR_UNKNOWN: Soft CLEAR CONTRADICTED. Loader-only ui32 live CONTRADICTED as 24/24 fix. Board mig0 hang after N CLEAR UNKNOWN. Program held.

REUSABLE_DECISION_PROCEDURE: After GOLD+ACK+n=0, do not skip debug_clear without XSim of >=3 V-04. Do not host-wait. New identity for mig0 settle; do not patch FAIL bits. Stop before JTAG when owner says không program.

STRUCTURAL_GUARD: Freeze U25/U26. Do not program U27. U28 overlay bind SETTLE after debug_clear. Ban U25/U26 sha in U28 program Tcl (unused until owner allows).

BLAST_RADIUS: UART_R2/u26–u28 overlays. PACKAGE live pack_mig_bind/pack_clear_ui not overwritten. No C/gold/FE256/H. SRAM last-writer U26. No new JTAG this run.

VERDICT_BY_LAYER:
- U26 BOARD Phase4 GOLD: PASS_BOARD_OBSERVE
- U26 BOARD 24/24: FAIL_BOARD
- U27 four V-04: FAIL_XSIM
- U28 leftover/four V-04: PASS_XSIM (mig_ui_bram)
- PROGRAM this run: NO
- PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS: NO

LESSON_TO_SHARE: DEBUG-CLEAR-REQUIRED-FOR-NTH-V04-XSIM
NEXT_DECISIVE_EXPERIMENT: Finish U28 bit. Do not program until owner allows. Then exclusive 24/24.
OWNER_AND_STOP_CONDITION: AGENT_D. Owner program=NO. Goal PACK_ABI_24_24_PASS open. No M2_STARTING_POINT. No self-stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
