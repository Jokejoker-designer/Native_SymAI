NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D-OBS01-MIG0-CLEAR1-BUSY-20260919T015520Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT PASS_XSIM — on generated mig0 OBS01, U32 `pack_quiescent` follows raw `mig0.app_rdy` while loader/ui IDLE and outstanding=0; first UART CLEAR returns BUSY `c1ea50b5`. Candidate name `RAW_MIG_READY_USED_AS_QUIESCENCE` is correct. `MISSING_APP_RDY_GATE` (mux `p_rdy` gating `mig_ui32.app_rdy` into qsc) is CONTRADICTED_THIS_SEQ. Not board root cause. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: `run_obs01_mig0.bat` xsim snapshot `tb_obs01_mig0`. `$finish` 211565 ns. calib_done 122810625 ps. dest_ui_clk.csv sha256 `134b59561bf07f125e3b419ac16e5170a4ce9a77682505310007b8249331b5dc`. xsim_mig0.log sha256 `169061f9f8b577e8e78e0dd1012798eac098b6433d623fb2a730084a2fde70ad`. U32 pack_mig_bind sha256 `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe`. No program. No product overlay.
OBSERVATION: 186 csv rows all ld=IDLE ui=IDLE out=0 mux_g=0. p_rdy=0 and p_wdf_rdy=0 all rows. app_wdf_rdy=1 all rows. qsc==app_rdy 186/186. QSC dips period 960 ns width 24 ns. CLEAR1 got BUSY mute=0. No DEBUG_CLEAR_RISE. LAST_EQUIVALENT_EVENT=CALIB_DONE FIRST_DIVERGENCE=CLEAR1_ACK. BRAM OBS01 same sequence was CLEAN because mig_ui_bram app_rdy=rst_n&&!stall.
HYPOTHESES: H1 RAW_MIG_READY_USED_AS_QUIESCENCE SEEN_THIS_SEQ. H2 MISSING_APP_RDY_GATE CONTRADICTED_THIS_SEQ (qsc uses d_rdy=dest_app_rdy not p_rdy; p_rdy stayed 0 while qsc rose). H3 dest_accept BEGIN-hold via same qsc_c1 NOT_REACHED (CLEAR1 failed first). H4 UART PHY unique root WEAKENED (BUSY token decoded). H5 board U32 CLEAR1 BUSY is same mechanism: INFERENCE not PASS_BOARD.
HOW_TRACE: BRAM CLEAN vs mig0 FAIL at CLEAR1. csv QSC vs app_rdy identity. mux G_NONE vs dest_ui_rdy wiring. pack_clear_ui 64-cycle consecutive qsc vs 80-cycle dest_rdy period. pack_debug_clear S_SAMPLE qsc_100 includes qsc_c1.
EVIDENCE_MATRIX: FACT csv qsc===app_rdy while idle. FACT CLEAR1 BUSY. FACT debug_clear never rose. FACT p_rdy never 1. INFERENCE SAMPLE !qsc_100 or DRAIN nack (both qsc-derived; not distinguished this dump). HYPOTHESIS board class. UNKNOWN which of SAMPLE vs DRAIN fired. CONTRADICTED: qsc_ui=0 while dest_rdy=1 and dest_wdf=1 and client idle (0 such rows).
SUCCESS_VS_FAILURE: BRAM success: sticky dest ready. MIG0 failure: periodic app_rdy dip into qsc AND. Predicted divergence was CLEAR2; actual is earlier (CLEAR1).
FIRST_DIVERGENCE: CLEAR1_ACK. LAST_EQUIVALENT_EVENT=CALIB_DONE.
DECISIVE_TEST: This run is the idle+out0+dest_rdy=0+qsc=0 snapshot. Next A/B (not done): same TB with dest_ui_rdy/wdf forced 1 (PACKAGE qsc). CLEAR1 ACK would make H1 causal for CLEAR1_ACK. Do not product-patch until that A/B.
ROOT_CAUSE_OR_UNKNOWN: PASS_XSIM mechanism for this mig0 sequence. UNKNOWN as PACK_ABI / BOARD / MIG_PASS root. Do not self-stamp.
REUSABLE_DECISION_PROCEDURE: Name the defect RAW_MIG_READY_USED_AS_QUIESCENCE not MISSING_APP_RDY_GATE. Accept-ready is handshake. Quiescence is client idle + outstanding 0. Mux a_rdy is grant handshake, not the U32 qsc term.
STRUCTURAL_GUARD: Keep dest_ui_clk.csv dump of dest_rdy beside qsc. Do not UART overlay. Do not dest_accept overlay. Do not remove dest_ui_* from product qsc until PACKAGE-qsc A/B ACK.
BLAST_RADIUS: U31/U32 pack_mig_bind qsc AND dest_ui_*. PACKAGE live bind has no dest_ui_* terms. C RTL / H / freeze DCP / Pack24 gold untouched.
VERDICT_BY_LAYER: PASS_XSIM_OBS01_MIG0_CLEAR1_BUSY. Not PASS_BOARD. Not PACK_ABI_24_24_PASS. Not MIG_PASS. Not PROGRAM_PASS. MIG0_PATH_THIS_SEQUENCE=FAIL_XSIM_CLEAR1_BUSY.
LESSON_TO_SHARE: RAW-MIG-READY-QSC-FOLLOWS-APP-RDY-IDLE
NEXT_DECISIVE_EXPERIMENT: TB A/B OBS01-MIG0 with PACKAGE qsc (omit dest_ui AND). If CLEAR1 ACK: H1 causal. Then V-04 P0–P15 vs BRAM. No program.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop: no overlay/program/PASS this turn. Owner must authorize A/B then any qsc repair as new overlay identity.
HANDOFF_STATUS: COMPLETE
