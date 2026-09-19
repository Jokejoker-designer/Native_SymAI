NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D-RAW-MIG-READY-QUIESCENCE-REVIEW-20260919T013100Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT — U31/U32 `pack_quiescent` ANDs raw `dest_ui_rdy`/`dest_ui_wdf_rdy` (mig0 `app_rdy`/`app_wdf_rdy`), not mux `p_rdy`. HYPOTHESIS — that term can drive CLEAR BUSY or BEGIN hold while `mig_ui32` is IDLE and outstanding=0. Not stamped root cause.
RUN_PROVENANCE: User review before overlay. RTL read: UART_R2/u32 pack_mig_bind, pack_clear_ui, pack_debug_clear, top dest_ui_rdy=app_rdy; PACKAGE bind without dest_ui_*; mig_ui_mux G_NONE a_rdy=0; mig_ui_bram app_rdy=rst_n&&!stall; mig_ui32 PROXY_METRIC_FALSE_PASS_GUARD. No new XSim this review. PACK_ABI_24_24_PASS=NO.
OBSERVATION: U32 top wires `.dest_ui_rdy(app_rdy)` `.dest_ui_wdf_rdy(app_wdf_rdy)` from generated mig0, bypassing mux. `dest_accept=qsc_c1&&rst100_pack_n`. `pack_clear_ui` NACKs if `!pack_quiescent` at req or during 64-cycle drain. `pack_debug_clear` S_SAMPLE uses `qsc_100` which includes `qsc_c1`. BRAM dest ready is level-1 after reset unless stall. PACKAGE live qsc has no dest_ui_* terms.
HYPOTHESES: H1 RAW_MIG_READY_USED_AS_QUIESCENCE (leading). H2 MISSING_APP_RDY_GATE on mig_ui32 handshake (weak: when G_A, p_rdy=d_rdy; idle does not need app_rdy). H3 mux G_NONE zeros p_rdy so qsc would be stuck if qsc used p_rdy (FACT of mux; U31 already avoided p_rdy). H4 UART PHY unique root (WEAKENED by prior GOLD/ACK tokens).
HOW_TRACE: Compare PACKAGE qsc vs U31/U32 qsc; mux a_rdy vs d_rdy; BRAM vs mig0 ready law; CLEAR drain 64 + dest_accept CDC.
EVIDENCE_MATRIX: FACT wiring U31/U32/top/mux/BRAM. INFERENCE BRAM OBS01 CLEAN hides dest-ready dips. HYPOTHESIS board CLEAR1 BUSY / BEGIN hold caused by app_rdy/wdf_rdy dip. UNKNOWN until OBS01-MIG0 snapshot: idle+out0+loader0 AND dest_rdy=0 AND qsc_ui=0 at CLEAR/BEGIN. CONTRADICTED would be qsc_ui=0 while dest_rdy=1 and dest_wdf_rdy=1 and loader/ui idle.
SUCCESS_VS_FAILURE: Success of this review = do not overlay; keep candidate named correctly. Failure mode = treat as root cause or patch dest_accept/UART.
FIRST_DIVERGENCE: Not measured on mig0 this run. Predicted window: qsc_ui fall while ui IDLE/out0 due to dest_ui_rdy or dest_ui_wdf_rdy, before CLEAR ACK or BEGIN accept.
DECISIVE_TEST: OBS01-MIG0 log at CLEAR2/BEGIN2: loader_busy, ui_st, ui_out, ld_out, dest_app_rdy, dest_app_wdf_rdy, qsc_ui, qsc_c1, dest_accept, mux.g, p_rdy. Confirm only if qsc_ui=0 with client idle and dest ready=0. Do not remove dest_ui_* from qsc until that snapshot.
ROOT_CAUSE_OR_UNKNOWN: UNKNOWN as board/mig0 class. Mechanism is FACT; causal board class still OPEN.
REUSABLE_DECISION_PROCEDURE: Accept-ready (app_rdy/app_wdf_rdy) is handshake, not idle. Quiescence = client idle + outstanding 0. Mux a_rdy is grant-qualified handshake, also not idle. Do not AND cycle-ready into CLEAR/BEGIN gates.
STRUCTURAL_GUARD: OBS01-MIG0 must dump dest_app_rdy/wdf_rdy beside qsc_ui. Do not UART overlay. Do not BRAM loader patch.
BLAST_RADIUS: U31/U32 pack_mig_bind qsc formula and dest_accept consumers. PACKAGE live bind unaffected. C RTL / H / freeze DCP untouched.
VERDICT_BY_LAYER: PASS_IMPLEMENTED wiring review. Not PASS_XSIM mig0. Not BOARD. Not PACK_ABI_24_24_PASS. MIG0_BOARD_CAUSAL_CLASS=STILL_OPEN.
LESSON_TO_SHARE: RAW-MIG-READY-IS-NOT-QUIESCENCE
NEXT_DECISIVE_EXPERIMENT: OBS01-MIG0 P0–P15 plus qsc vs dest_rdy snapshot at CLEAR2. If P6–P10 clean and CLEAR2 BUSY with dest_rdy=0: H1 strengthened. If dest_rdy=1 throughout CLEAR2 fail: H1 CONTRADICTED for that event.
OWNER_AND_STOP_CONDITION: AGENT_D observe-only until snapshot. No U33. No dest_accept overlay. No PACK_ABI / MIG_PASS / BOARD_PASS stamp.
HANDOFF_STATUS: COMPLETE
