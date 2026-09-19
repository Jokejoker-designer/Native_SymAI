NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART_R2_U14_BOARD_TRIAL / 20260918T072700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT U14 programmed 3597886d… End of startup HIGH. FACT first OPEN CLEAR1 n=0. FACT later MARK-2s CLEAR ACK and V-04 GOLD. FACT next CLEAR n=8 00000000||ACK. FAIL Phase 5. Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: bit 3597886d91c1fc3f6af6c154f240fd02c587168c41f1033ff55f6827029d102b ; JTAG 210319BE776EA ; COM12 FTDI 776EB ; PROGRAM.txt U14_PROGRAMMED=FACT PROGRAM_PASS=NO
OBSERVATION: Handshake U14 unblocked ACK vs U12/U13 mute. First post-program COM OPEN still n=0. Second OPEN + 2s MARK: ACK, ACK. Third OPEN + MARK: ACK then GOLD n=4. Immediate next CLEAR: raw 00000000a550eac1. 0.5s drain after GOLD leftover_n=0 then CLEAR still 00000000||ACK.
HYPOTHESES: H1 extra 32'h0 is TX CDC/st_valid_100 released around CLEAR flush, sent before ACK (HYPOTHESIS). H2 host leftover after GOLD (CONTRADICTED leftover_n=0). H3 MAG class (CONTRADICTED). H4 U14 handshake not on board (CONTRADICTED by ACK/GOLD).
HOW_TRACE: mux_valid = clr_ack_valid | uart_tx_valid | st_valid_100; mux_data prefers ACK. Extra 0 word implies a mux source presented 32'h0 while ack_valid still 0, after uart_flush dropped enough for TX to accept, then ACK.
EVIDENCE_MATRIX: PROGRAM End of startup HIGH | P4 first OPEN n=0 | P4b ACK+GOLD | P5 r0 n=8 00000000||ACK | leftover probe extra=0
SUCCESS_VS_FAILURE: SUCCESS one-shot ACK+GOLD after MARK. FAILURE Phase 5 exact-ACK. FAILURE first-open CLEAR.
FIRST_DIVERGENCE: first CLEAR after V-04 GOLD; expected 4-byte ACK; observed 8-byte 0 then ACK.
DECISIVE_TEST: leftover 0.5s empty then CLEAR still prepends 0 word. Next: XSim CLEAR after GOLD through product mux, score extra word.
ROOT_CAUSE_OR_UNKNOWN: U12/U13 mute class closed_for_tested_U14_ACK. Extra 0-word after pack UNKNOWN. COM-open first CLEAR flaky UNKNOWN.
REUSABLE_DECISION_PROCEDURE: Score full raw hex not only first word. n>4 with trailing ACK is phase-shift/extra-word, not MAG, not n=0.
STRUCTURAL_GUARD: Host must not call 00000000||ACK an ACK. Targeted XSim must include CLEAR after GOLD through product UART mux.
BLAST_RADIUS: host scoring and UART mux/CDC after pack. Do not patch U14 in place. No C/H/gold/FE256.
VERDICT_BY_LAYER: PASS_XSIM U14 targeted. U14_PROGRAMMED FACT. FAIL_BOARD Phase 5 exact contract. Not BOARD_PASS.
LESSON_TO_SHARE: UART-EXTRA-ZERO-WORD-BEFORE-CLEAR-ACK-20260918T072700Z
NEXT_DECISIVE_EXPERIMENT: XSim product mux CLEAR after GOLD; if extra 0, new identity. Do not Pack24 on this bit until Phase 5 exact 24/24.
OWNER_AND_STOP_CONDITION: AGENT_D stopped Phase 5 r0. No RTL change in U14. No 24/24 stamp.
HANDOFF_STATUS: COMPLETE for trial report. INCOMPLETE_HANDOFF for M1 closure.
