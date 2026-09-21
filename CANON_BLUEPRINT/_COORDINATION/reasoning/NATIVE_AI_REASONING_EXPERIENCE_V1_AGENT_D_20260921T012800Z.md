NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: NOON-QUERY-IDENTITY-R04-6-80 / 20260921T012800Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unique query identity 8fc14f25 programmed EOS HIGH (WNS +0.275 MET, not TIMING_PASS). Iso R-04 GOLD four-AND then UART QUERY 03065051 (status 6 reason 0x50) observed, not RC_TRUNC 02000f5a. First steal-all-4E51 bit 99823c92 stole inner pack QR (03065551). uart_busy after OP_BEGIN is the gate. G-04 after CLEAR is NAK 0200055a reason 5 plus QUERY 03000051 (not TSV 6/84). PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
RUN_PROVENANCE: Owner 2026-09-21 07:16+07 board until 12:00 +07. No overlay H/U33/freeze. C RTL unmodified. B gold unmodified. Same unique dir rebuilt; SRAM identity is PROGRAM.txt 8fc14f25 after second program.

OBSERVATION:
- FACT — Isolated XSim pack_obs_query: 03000051 CRC-ok, 03065051 dest PACK_CRC, 03065451 stale, uart_busy blocks steal after 00800001. PASS_XSIM.
- FACT — First route WNS −1.276 dest_fail←FIFO RAM and −1.798 gen100 CDC. No bit. Input-register + ASYNC_REG max_delay 8 ns → WNS +0.365 then +0.275. Not TIMING_PASS.
- FACT — Bit 99823c92 programmed EOS HIGH. Iso R-04 returned QUERY 03065551 then 03000051 (inner 4E51 stolen from pack). TAP no COMMIT.
- FACT — Bit 8fc14f25 programmed EOS HIGH. Iso R-04 GOLD 010000a5 TAP four-AND ffffffff→0000002b epoch 2 generation_flipped=1. QUERY 03065051 parse 6/0x50. rc_trunc=false. json sha256 9da6c2d8…
- FACT — Iso G-04 CLEAR_ACK then 0200055a n=40 (NAK reason 5 + TAP piggyback). QUERY 03000051. Not 6/84. json sha256 00623302…
- INFERENCE — G-04 TSV 6/84 needs G-01 in the same capture epoch. CLEAR-between leaves generation UNSET so stale is false.
- FACT — Gold TSV R-04 LOAD_OK flip=1 query 6/80. G-04 LOAD_REJECT reason 5 flip=0 query 6/84. D does not invent reject flip=0.

HYPOTHESES:
- H1 steal every UART 0x4E51 — CONTRADICTED on 99823c92 (pack inner QR stolen).
- H2 uart_busy from OP_BEGIN until pack_done/CLEAR — supported by 8fc14f25 R-04 GOLD+03065051.
- H3 board CLEAR-between G-04 equals XSim two-step 6/84 — CONTRADICTED (03000051).

HOW_TRACE: noon grant → rearm hops RC_TRUNC → query synth → dest_fail+CDC timing fail → pipeline+XDC → 99823c steal-bug hop → uart_busy XSim → rebuild 8fc14f → R-04 6/50 observe → G-04 NAK5 + query 0/0.

EVIDENCE_MATRIX:
- XSim intercept PASS_XSIM FACT.
- Route WNS +0.275 FACT. TIMING_PASS=NO.
- PROGRAM 8fc14f25 EOS HIGH PASS_BOARD identity CANDIDATE. PROGRAM_PASS=NO.
- R-04 QUERY 03065051 PASS_BOARD observe. Not PACK_ABI.
- G-04 QUERY 03000051 PASS_BOARD observe. Not TSV 6/84.
- B --compare still blocked on 18 reject flip 0-vs-absent plus G-04 query mismatch if CLEAR-between.

SUCCESS_VS_FAILURE: Silicon QueryRecord path closed for R-04 6/80. G-04 6/84 not this CLEAR-between hop. PACK_ABI unproven.

FIRST_DIVERGENCE: 99823c92 stole pack-stream 0x4E51 before OP_BEGIN lock vs 8fc14f25 uart_busy gate.

DECISIVE_TEST: iso R-04 GOLD then 8-word gold QueryRecord. 8fc14f25 → 03065051.

ROOT_CAUSE_OR_UNKNOWN: RC_TRUNC was OP_BEGIN alias of QueryRecord interior (FACT). 99823c inner-steal was MAGIC-without-busy (FACT). G-04 0/0 vs 6/84 is CLEAR-between vs two-step (INFERENCE).

REUSABLE_DECISION_PROCEDURE: generation_flipped four-AND this-pack only. Query token only 03|qs|qr|51 observed. Steal 0x4E51 only when uart_busy=0. Do not copy TSV query or reject flip=0. Unique SHA; do not overlay U33.

STRUCTURAL_GUARD: q_take requires !uart_busy; uart_busy sets on UART OP_BEGIN, clears on pack_done/CLEAR. 97_program bans 08c647ee and 99823c92. 96_bit refuses WNS<0.

BLAST_RADIUS: Unique u33obs_query dir + host iso + mapper parse_query_word. Frozen H/U33/rearm bits untouched. C RTL untouched.

VERDICT_BY_LAYER:
- PASS_XSIM intercept 6/80 6/84 0/0 uart_busy
- PASS_IMPLEMENTED unique query RTL/XDC
- setup MET WNS +0.275 (not TIMING_PASS)
- PASS_BOARD program CANDIDATE 8fc14f25 EOS HIGH
- PASS_BOARD R-04 GOLD four-AND + QUERY 03065051
- PASS_BOARD G-04 NAK 5 + QUERY 03000051
- Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS

LESSON_TO_SHARE: QUERY-STEAL-INNER-4E51-UART-BUSY-20260921T012800Z
NEXT_DECISIVE_EXPERIMENT: G-01 then G-04 in the same epoch (no CLEAR between) if testing TSV 6/84. Do not invent reject flip=0. Pack24 query after GOLD only on unique 8fc14f. Stop PROGRAM at 12:00 +07.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop overlay H/U33. Stop inventing query/flip. Goal PACK_ABI unproven. Exclusive PROGRAM until 12:00 +07.
HANDOFF_STATUS: COMPLETE
