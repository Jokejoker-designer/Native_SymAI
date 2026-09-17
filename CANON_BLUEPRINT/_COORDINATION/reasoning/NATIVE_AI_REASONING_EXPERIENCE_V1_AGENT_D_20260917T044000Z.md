NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-PACK-SILICON-FIRST-DIVERGENCE-01
RUN_ID: 20260917T044000Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: H9 JP2/CK_RST is a single-variable cause of MAG/UNS/MUTE; H10 rate is the mute cause; H11 same V-04 is stable GOLD after ACK.
RUN_PROVENANCE:
  Identity H bit sha256 cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  JTAG 210319BE776EA UART FTDI 210319BE776EB COM pack 115200
  Host campaign uart_pack24_clear_board.py (frozen; not edited)
  Host H11 uart_h18_stamp.py
  JP2 CK_RST owner-reported removed after installed arm
  No C RTL edit. No Identity I. Freeze DCPs untouched. Hist bit f6a6091f file untouched.
OBSERVATION:
  FACT — H9 INSTALLED: post-program ACK c1ea50a5; campaign pack_ok=0/3; first CLEAR 0200075a; sticky NO_BYTE from r0 S-01; post-probe n=0.
    jsonl sha256 232cdb25090981376915a68654be6395d2285299f5389b5d397582afc8e067ea
  FACT — Owner reported CLK_RST/JP2 removed. Device was unprogrammed (DONE=0) then reprogrammed H End of startup HIGH SHA MATCH.
  FACT — H9 REMOVED: post-program ACK; campaign pack_ok=16/21; first WRONG V-02 CLEAR 0200075a; intermittent NO_BYTE=20; CLEAR_BUSY seen; post-probe BUSY c1ea50b5 n=4 not n=0.
    jsonl sha256 f88e9778e94e19d805d4052b4b973fc084ad22ebd80ab393086493d8577bdddd
  FACT — H10 burst (reprogram): CLEAR_ACK 18/24 GOLD 13/24 pack_nobyte=6. jsonl sha256 b565a0cdbd7be0e313582c5db8f64404c61a79f97711ec1529215dd53a04c406
  FACT — H10 paced gap 0.5 ms/byte (reprogram): CLEAR_ACK 20/24 GOLD 19/24 pack_nobyte=4. jsonl sha256 4a7ba163334223a26d5dc2b363bee474f20e9721bc8bdb335133c1d4df2ce4d9
  FACT — H10 V-03 both arms: CLEAR ACK a550eac1 then PACK 0200085a SENTINEL.
  FACT — H10 V-04: burst CLEAR n=0; paced GOLD 010000a5.
  FACT — H11 V-04 n=8 stop at i=5: ACK+UNSUP, ACK+GOLD, ACK+MAG, ACK+GOLD, CLEAR UNSUP, CLEAR n=0.
    t_first ~0.06 s on 4-byte replies (not delayed>1s). jsonl sha256 c1d33aa8e6da2a757059049bdd932acf01ba7fd9c7a6699e64c9df676b180156
  FACT — SRAM leave-state after H11 = CLEAR n=0.
HYPOTHESES:
  H9 CK_RST/FT2232 drives sticky CLASS B mute — SUPPORTED as correlation (installed sticky n=0 vs removed not all-rest mute). NOT proven causal mechanism. REJECTED as sole CLASS A root.
  H10 burst vs paced as mute root — PARTIAL (GOLD 13 vs 19) REJECTED as sole root (V-03 SENTINEL both; both have n=0).
  H11 same-case stability — CONTRADICTED (UNSUP/MAG/GOLD mix then NO_BYTE).
  H_MULTIROOT — still open. CLASS A and CLASS B remain separable.
  H17 dest/MIG busy — HYPOTHESIS from H9-removed post BUSY c1ea50b5; unproven.
HOW_TRACE:
  owner "Đã tháo CLK_RST" → program H → probe ACK → same --mode clear --rounds 2 → post BUSY
  → reprogram → H10 burst → reprogram → H10 paced → reprogram → H11 V-04 stamp
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  H9 installed sticky n=0 | pack_ok 0/3 post n=0 | UART_BOARD CANDIDATE
  H9 removed liveness | pack_ok 16/21 post BUSY | UART_BOARD CANDIDATE
  CLASS A on removed | UNSUP/SEN/MAG remain | UART_BOARD CANDIDATE
  H10 rate GOLD delta | 13/24 vs 19/24 | UART_BOARD CANDIDATE
  H10 V-03 SENTINEL both | 0200085a | UART_BOARD CANDIDATE
  H11 i=0 PACK UNSUP | 0200075a t_first 0.063s | UART_BOARD CANDIDATE
  H11 i=5 CLEAR n=0 | CLASS B delayed | UART_BOARD CANDIDATE
  Internal net | missing | UNKNOWN
  ILA | not synthesized | NOT_RUN
SUCCESS_VS_FAILURE:
  Success: H9 A/B closed with same bit/host; H10 pair saved; H11 sequence named; no RTL; no PASS stamp.
  Failure to name internal first divergence: still UART tokens only.
FIRST_DIVERGENCE:
  Observable CLASS B: installed sticky n=0 vs removed BUSY/intermittent.
  Observable CLASS A earliest this H11 run: i=0 PACK UNSUP after CLEAR ACK on V-04.mem.
  Internal (clr_take / pack_lock / FIFO / TX mux / dest) UNKNOWN.
DECISIVE_TEST:
  H9 jumper A/B DONE. H10 paced/burst DONE. H11 same-case DONE.
  Next: ILA-A on H11 6-step requires owner-authorized debug bitstream.
ROOT_CAUSE_OR_UNKNOWN:
  CLASS_B_STICKY_MUTE = H9_CORRELATED_NOT_PROVEN
  CLASS_A = UNKNOWN
  COMMON_ROOT = UNKNOWN
REUSABLE_DECISION_PROCEDURE:
  1. Classify 4-byte WRONG_VALID vs n=0 NO_BYTE before naming mute.
  2. Change one physical variable (jumper, then rate, then repeat-index).
  3. Do not merge CLASS A and CLASS B.
  4. Do not treat paced GOLD improvement as root.
  5. ILA only after a named UART sequence exists.
STRUCTURAL_GUARD:
  Frozen campaign host not edited. find_known still hides UNSUP as tok=None; H18/stamp used for H11.
  No Identity I. C_SCALE_GUARD not tripped. FE256 freeze DCPs not written.
BLAST_RADIUS:
  UART CLEAR/Pack on identity H SRAM. Freeze DCPs and hist f6a6091f file untouched.
VERDICT_BY_LAYER:
  PASS_XSIM: not this run (prior dualclk only)
  PASS_IMPLEMENTED: not claimed
  UART_BOARD CANDIDATE: H9/H10/H11 tokens
  PASS_BOARD / PROGRAM_PASS / PACK_ABI_24_24_PASS: NO
LESSON_TO_SHARE: D-H9-H10-H11-20260917T044000Z
NEXT_DECISIVE_EXPERIMENT:
  ILA-A on H11 sequence (ACK/UNSUP/GOLD/MAG/GOLD/CLEAR UNSUP/n=0) after owner debug-bit grant.
  Do not synthesize ILA without that grant. FEM persist still blocked.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D exclusive board. STOP RTL/Identity I until owner authorizes debug bitstream.
  HANDOFF_STATUS COMPLETE for H9/H10/H11 UART arms; task first-internal-divergence still open.
HANDOFF_STATUS: COMPLETE
