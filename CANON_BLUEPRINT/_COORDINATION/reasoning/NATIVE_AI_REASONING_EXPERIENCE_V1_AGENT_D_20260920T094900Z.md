NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33-ABA-DUMMYOPEN-POSTPROG-20260920T094900Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: After owner-authorized exact U33 reprogram, dummy-open/close is sufficient to mute first V-04 GOLD on this A/B/A; skipping dummy-open yields GOLD. Mute is n=0, not MAG. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Owner “Phải nạp lại board nhé”. program_exact_u33.tcl sha256 3fedd01d…4ca0fb4; bit ff399e0b…338a350; JTAG 210319BE776EA; PROGRAM_RECORD 8da16eda…efed3ea3 STATUS=PROGRAMMED_CANDIDATE_ONLY DONE=1 CRC=0 End of startup HIGH. taskkill hw_server after program. aba_dummy_open_20260920.py ae7191d8…7034c75a OUT U33_ABA_DUMMYOPEN_20260920_POSTPROG. No RTL change. No flash. No U33TAP/H.

OBSERVATION:
- FACT: Pre-reprogram A/B/A all arms CLEAR1 n=0 reopen 6e6f00 — not a dummy-open result; SRAM UNKNOWN.
- FACT: Post-program A1 dummy: CLEAR1 n=0 then reopen ACK then V-04 n=0 / 12 s / drain 0.
- FACT: Post-program B no-dummy: CLEAR1 ACK then GOLD 010000a5 n=4 drain 0.
- FACT: Post-program A2 dummy: CLEAR1 ACK (no reopen) then V-04 n=0 / 12 s / drain 0.
- FACT: No MAG 0200015a this A/B/A.
- CONTRADICTED (this run): dummy-open is required for CLEAR ACK (A2 and B both ACK).
- UNKNOWN: DTR/RTS vs COM close vs leftover UART bytes as physical cause. Historical MAG SOF.

HYPOTHESES: Dummy COM open/close leaves FTDI/UART/RX in a state that drops or ignores the 208-byte V-04 after CLEAR ACK. Pack/MIG not permanently dead (B GOLD without reprogram).

HOW_TRACE: Owner reprogram → exact U33 → kill hw_server → A/B/A dummy-only variable → compare A1/B/A2 first hop.

EVIDENCE_MATRIX:
- PROGRAM_RECORD.txt sha256 8da16edac5e3662b723554ac2b0b51468469596c74a36e0a3c120621efed3ea3 FACT
- ABA.json sha256 01e2cd64495a680e7cb4daac81b4a0c50896c78a30072083bab3e324d6322d08 FACT
- bit uart_r2_u33_candidate.bit sha256 ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350 FACT
- BOARD_20260920_ABA_POSTPROG.md INFERENCE classified in-file

SUCCESS_VS_FAILURE: Success (B): no dummy-open, GOLD hop-1. Failure (A1/A2): dummy-open, V-04 mute n=0. Pre-reprogram failure: CLEAR n=0 all arms — discarded as discriminator.

FIRST_DIVERGENCE: Dummy-open/close before real-open. Held constant: MARK 2 s, timeout 0.05, real-open purge, 208 B V-04, WAIT_AFTER_ACK=0.

DECISIVE_TEST: This A/B/A after fresh program. PASS_BOARD for dummy→mute / no-dummy→GOLD on this one run only. Not PACK_ABI.

ROOT_CAUSE_OR_UNKNOWN: Dummy-open/close sufficient for V-04 mute (this run). Physical FTDI vs UART vs Pack state UNKNOWN. MAG root UNKNOWN.

REUSABLE_DECISION_PROCEDURE: A/B/A without a recorded program is not a UART-host discriminator if CLEAR1 n=0 on every arm. Kill hw_server after JTAG. Do not treat mute n=0 as MAG. Do not patch loader/MIG to fix a host dummy-open mute.

STRUCTURAL_GUARD: No overlay U33/H/freeze. No U33TAP unless MAG returns + owner YES. No PROGRAM_PASS / PACK_ABI_24_24_PASS self-stamp.

BLAST_RADIUS: discriminator script argv/env only; product u33_campaign.py untouched; C RTL untouched; freeze DCPs untouched.

VERDICT_BY_LAYER: PASS_IMPLEMENTED program Tcl + A/B/A script. PASS_BOARD one A/B/A after PROGRAMMED_CANDIDATE_ONLY (dummy mute vs GOLD). Not PROGRAM_PASS. Not PACK_ABI_24_24_PASS. Not BOARD_PASS. Not MIG_PASS. Not TIMING_PASS. MAG NOT_OBSERVED this run.

LESSON_TO_SHARE: DUMMY-OPEN-SUFFICIENT-V04-MUTE-20260920T094900Z
NEXT_DECISIVE_EXPERIMENT: Pack24 host without dummy-open if owner wants hop-1 GOLD on campaign path; optional DTR/RTS-only split. TAP only if MAG returns.
OWNER_AND_STOP_CONDITION: AGENT_D. Reprogram+A/B/A done. Do not stamp PACK_ABI. Do not overlay.
HANDOFF_STATUS: COMPLETE
