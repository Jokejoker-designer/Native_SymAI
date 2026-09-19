# REASONING_DISTILLATION — UART_R2_U12_PACK24_FINAL

REASONING_DISTILLATION_REQUIRED=YES
TASK_ID / RUN_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / 20260918T054400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U12 closed MAG/partial/TX-flush in PASS_XSIM but failed Phase 4 board liveness (CLEAR n=0). Not BOARD_PASS.

OBSERVATION:
- FACT — TARGETED_XSIM PASS 54, MAG=0, n0=0, T9 32/32 BEGIN+MAGIC exact. warn=1 U8 quiet-timeout still ACKs.
- FACT — U12 bit SHA256 `0f774e8745377ea75dab6ccd533fedf059a03a00612f90fbe9bddb9ce3ab5121` programmed twice; End of startup HIGH; JTAG 210319BE776EA.
- FACT — Phase 4 CLEAR1 n=0 on COM12 115200. Retry MARK 2s n=0. Double-open 5× CLEAR n=0.
- FACT — Same-day A/B U8 bit `2bc835fd…` produced one token `5a070002` (UNSUP `0200075a`) then sticky mute.
- FACT — Synth inferred sequential FSM on U10 `st` in the same always_ff as `flush_hold` (Synth 8-802 / 8-3354). PACKAGE TX on U8/U11 also inferred FSM but has no flush_hold in that process and historically emitted ACK/GOLD.

EXPECTED_BEHAVIOR: Fresh program → COM open → U11 MARK recovery → CLEAR ACK → V-04 GOLD.

HYPOTHESIS: U10 flush_hold + FSM extraction yields a TX that never leaves MARK on silicon. PACKAGE TX (U8) can still emit a word. Host windows do not explain U12-total-silence vs U8-one-token.

EVIDENCE: XSIM_TARGETED.log; BUILD_MANIFEST.md; PROGRAM.txt; BOARD_BASELINE.json; U8 A/B UNSUP hex `5a070002`.

FIRST_DIVERGENCE: U12 never produces a UART token; U8 same host later produced UNSUP.

DECISIVE_TEST: U13 TX = U10 behavior with `fsm_encoding=none` and flush_hold in a separate always_ff. New identity.

ROOT_CAUSE_OR_UNKNOWN: Board n=0 on U12 = INFERENCE U10 FSM/flush_hold silicon. MAG CLOSED. COM-open partial SUPPORTED by U11 XSim. Sticky mute after one U8 token remains OPEN.

GENERAL_RULE: Do not share an inferred-FSM process with extra handshake flags (flush_hold). ACK_VISIBLE → NEXT_COMMAND_MAY_START. PASS_XSIM != board token.

DECISION_PROCEDURE: Fail U12 campaign without RTL mix-in. New TX guard = new identity U13.

STRUCTURAL_GUARD: `(* fsm_encoding = "none" *)` on uart_tx_word st; split flush_hold.

TRANSFER_TO_NEXT_STAGE: M1 not closed. Do not start M2. Do not stamp BOARD_PASS.

HANDOFF_STATUS: COMPLETE for U12 FAIL package; INCOMPLETE_HANDOFF for M1 closure.
