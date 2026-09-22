NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PACK-GEN-VIS-XSIM-20260922T050100Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: PACK_GENERATION_VISIBILITY_XSIM_CANDIDATE=SUPPORTED. Same QueryRecord follows pack_loader.active_generation. Slot windows do not alias. Not a board result.
RUN_PROVENANCE: XSim log D:/FPGA/arty_d/UART_R2/pack_gen_vis/xsim/pack_vis_xsim.log sha256 5e9a787d685a79542dd445eeb0d65d0960d7c42745894be62448dd001752c3db finish 9705 ns exit 0. No bitstream. No program. Board unplug does not affect this log.
OBSERVATION: FACT — RAM empty before commit. UNCOMMITTED root ffffffff miss, no command. G1 commit ack reason 00 active=1 writes=12 window base 0000000 win 00 descriptor 025bb7b41001100013100000000099bc command c001 primitive 0. G2 commit active=2 writes=24 window base 0100000 win 01 descriptor f2a071fe100110001310000000009421 command c002 primitive 1, and the G1 descriptor remained in window 0. Stale resend of G1 rejected reason 0e, active stayed 2, writes stayed 24. Same query then returned the G2 descriptor, command c003 primitive 1. Query generation byte stayed 1 on every arm.
HYPOTHESES: H1 host-selected generation was required. CONTRADICTED. The testbench has no visible_generation port. H2 slot1 base 0x01000000 aliases slot0. CONTRADICTED by win=01 at base 0100000 and kept_g1 after the second commit.
HOW_TRACE: Emit two gold.valid_pack streams as stimulus only. Drive unmodified pack_loader into an empty RAM indexed by addr[21:20] and addr[13:2]. Query uses active_generation. Resend G1 for the stale arm.
EVIDENCE_MATRIX: FACT log 5e9a787d… 9705 ns. FACT SLOT1 window base 28'h010_0000 win 01. FACT G1 bytes survived G2. FACT stale reason 0x0E with write_count unchanged. NOT a PACK_ABI_24_24_PASS. NOT a board identity.
SUCCESS_VS_FAILURE: Four arms matched. nfail path printed SUPPORTED.
FIRST_DIVERGENCE: NONE in this run.
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Visibility claim requires the loader root, a rejected stale commit that does not move that root, and a window index taken from the loader address.
STRUCTURAL_GUARD: Do not rebuild 44546b43 or 435bdc88. Do not program from this XSim. C audit before any new board SHA.
BLAST_RADIUS: pack_gen_vis XSim only. Frozen bits on disk unchanged: 44546b43, 435bdc88, 1db38691.
VERDICT_BY_LAYER: PASS_XSIM for PACK_GENERATION_VISIBILITY_XSIM_CANDIDATE only. BOARD_PASS=NO PROGRAM_PASS=NO PACK_ABI_24_24_PASS=NO MIG_PASS=NO.
LESSON_TO_SHARE: NONE beyond LESSON-PACK-SLOT1-BIT20-20260922T044500Z
NEXT_DECISIVE_EXPERIMENT: Independent C audit of this log. No bitstream until that audit. Unplugging the board does not erase the log or the frozen bits.
OWNER_AND_STOP_CONDITION: AGENT_D stops before a board build. C audits the new cuts. PACK_ABI_24_24_PASS stays NO.
HANDOFF_STATUS: COMPLETE
