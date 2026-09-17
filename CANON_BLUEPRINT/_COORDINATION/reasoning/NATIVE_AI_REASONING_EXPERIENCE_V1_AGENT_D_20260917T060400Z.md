NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-EXPLORE-ACCURACY-FIRST-TRANSPORT
RUN_ID: 20260917T060400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: An accuracy-first collect-full-frame UART transport may be better than the live word/bix UART for Native AI Pack/CLEAR. Under test: whether that idea is new, already present, wrapper-feasible, and whether it should be built before silicon first-divergence is named.
RUN_PROVENANCE:
  Live PACKAGE CANON_BLUEPRINT
  Review: D:/FPGA/arty_d/transport_review/D_EXPLORE_ACCURACY_FIRST_TRANSPORT.md
  RTL hashes: uart_rx_word 638f9719…; pack_debug_clear 77e3dc26…; pack_loader 58302aec…; uart_fe256_host 95f273fa…
  Canon §04.9 recommended SOF/LEN/SEQ/CRC16 frame (doc 04_ABI_AND_PROTOCOL.md)
  H12 extra-byte PASS_XSIM: 0 extra ACK, 1 extra R_UNSUP 0200075a, 2–3 extra MUTE
  H16 115200 A-01 harness NAK_R02; silicon isolate UNSUP/mute not reproduced
  B word comparator 2026-09-17T13:01 PACK_ABI24_XSIM_PASS 24/24 finish 15805 ns (not PACK_ABI_24_24_PASS)
  PROGRAM=NO this task. PRODUCT_RTL_CHANGED=NO. PACK_GOLD_CHANGED=NO. CANON_CHANGED=NO.
OBSERVATION:
  FACT — uart_rx_word emits w_valid only after bix==3; 4th byte with w_valid && !w_ready drops the word and still sets bix=0.
  FACT — pack_debug_clear take requires exact 32'h44524743; success path flushes UART and zeros bix; BUSY path does not flush.
  FACT — pack_loader consumes opcode on first word; PAGE S_WRITE to dest before END; S_COMMIT flips active_generation after sentinel.
  FACT — uart_fe256_host collects 8 words after 0x4E51 then issues QueryRecord; query_walk_bind CRC16 on 32-byte record.
  FACT — §4.9 already specifies [SOF16][VER8][TYPE8][LEN16][SEQ16][payload][CRC16] with ACK/NAK/seq and host pacing; live UART does not implement it.
  FACT — host uart_pack24_clear_board.py send_words is raw LE 32-bit; dtr/rts off; stop-and-wait per CLEAR then pack.
  FACT — silicon extra-byte source remains UNKNOWN; COMMON_ROOT UNKNOWN. This review did not run ILA/program.
HYPOTHESES:
  H1 (INFERENCE): accuracy-first UART is the unimplemented §4.9 layer, not a new product architecture.
  H2 (INFERENCE): an outer wrapper can feed unchanged pack_loader words (OPTION B).
  H3 (INFERENCE): implementing the wrapper before naming the extra byte would DETECT/CONTAIN CLASS A tokens and HIGH-mask the H investigation.
  H4 (HYPOTHESIS): sticky CLASS B mute is loader/MIG/BUSY, not cured by transport CRC.
  H5 (REJECTED as R1): seal entire pack in one BRAM before any dest write — conflicts with live S_WRITE and §4.8 page flow.
HOW_TRACE:
  task OPEN ARCHITECTURE REVIEW
  -> architecture-lock on live UART/Pack/CLEAR
  -> read uart_rx_word, pack_debug_clear, word_fifo32, word_cdc32, pack_loader, uart_fe256_host, uart_tx_word, pack_mig_bind, §04.8–4.9, frozen host
  -> classify already/partial/missing vs proposed collect-validate-commit
  -> compare failure classes MAG/UNSUP/SENTINEL/PARTIAL/MUTE/STICKY
  -> choose DEFER not EXPERIMENT
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Word assemble | 4-byte bix, drop on backpressure | uart_rx_word.sv STOP | RTL_FACT
  CLEAR | exact word, flush only success | pack_debug_clear.sv | RTL_FACT
  Pack commit | PAGE write then generation flip | pack_loader S_WRITE/S_COMMIT | RTL_FACT
  Query collect | 8 words then CRC | uart_fe256_host + query_walk_bind | RTL_FACT
  Canon transport | SOF/LEN/CRC recommended | 04_ABI_AND_PROTOCOL.md §4.9 | DOC_FACT (not on wire)
  Extra byte map | 0/1/2-3 → ACK/UNSUP/MUTE | H12 PASS_XSIM | PASS_XSIM
  Silicon extra source | unknown | H STATUS COMMON_ROOT | UNKNOWN
  Word TB vs UART vs board | 24/24 word; UART NAK; board UNSUP | B xsim 15805 ns; H16; H12 board | mixed layers
SUCCESS_VS_FAILURE:
  Success of this task: architecture answer without RTL/gold/program; H investigation unedited.
  Failure mode avoided: building a packet wrapper that converts 0200075a into FRAME_CRC and claiming CLASS A fixed.
FIRST_DIVERGENCE:
  Canon §4.9 frame vs implemented 4-byte grouping. Independently: H12 XSim extra 0x00 vs unnamed silicon extra-byte source.
DECISIVE_TEST:
  Not run (review). Decisive for later wrapper: H12 0/1/2/3 extra-byte UART TBs must still fail-closed at transport CRC AND inner word path must still reproduce UNSUP/MUTE without wrapper. Decisive for H: ILA first RX word after CLEAR ACK / mig0.
ROOT_CAUSE_OR_UNKNOWN:
  Extra byte on silicon UNKNOWN (unchanged). Architecture gap FACT: §4.9 not implemented. Drop-on-backpressure RTL_FACT, not proven as silicon CLASS A.
REUSABLE_DECISION_PROCEDURE:
  1 Classify transport vs semantic vs persistence integrity.
  2 Ask whether the proposed frame already exists in canon and at which layer in RTL.
  3 Prefer outer wrapper over Pack ABI rewrite if payload can stay identical.
  4 Do not implement transport that changes diagnostic tokens while a silicon first-divergence is unnamed.
  5 Keep extra-byte vectors as regressions; do not retune gold.
STRUCTURAL_GUARD:
  GUARD_ID: G-TPORT-DEFER-UNTIL-H
  IMPACT_RULE_ID: IR-H12-UART-FRAMING (existing) — elevate only after CONFIRMED silicon source; do not auto-create IR from this review alone beyond documenting §4.9 gap.
BLAST_RADIUS:
  Review markdown + reasoning/lesson append. Product RTL, Pack gold, freeze DCP, identity H, first_divergence STATUS.md untouched.
VERDICT_BY_LAYER:
  RTL_FACT: word UART, CLEAR exact, Pack streaming writes, Query collect+CRC, drop-on-4th-byte.
  DOC_FACT: §4.9 recommended frame missing on wire.
  PASS_XSIM: extra-byte CLASS A mapping; A-01 115200 harness NAK; B 24/24 word.
  PASS_BOARD: no. Silicon extra source UNKNOWN.
  ENGINEERING_ESTIMATE: wrapper ≤1 RAMB18 PAGE-sized; +~1 ms/frame at 115200.
SUCCESS_VS_FAILURE: (see above)
LESSON_TO_SHARE: D-TPORT-CANON-49-NOT-ON-WIRE-20260917T060400Z
NEXT_DECISIVE_EXPERIMENT:
  Continue H/ILA/mig0/FTDI extra-byte measurement. Do not build TRANSPORT_EXPERIMENT without owner auth after that measurement (or owner override).
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D review complete. Stop prototype. Owner auth required to implement wrapper. H STATUS remains UNKNOWN/open.
HANDOFF_STATUS: COMPLETE
