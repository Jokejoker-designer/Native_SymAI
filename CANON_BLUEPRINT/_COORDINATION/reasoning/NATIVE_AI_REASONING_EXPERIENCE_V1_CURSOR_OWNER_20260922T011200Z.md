REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-SPEAR-SEMANTIC-BOARD / 20260922T011200Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: New identity 52b923a6 programmed EOS HIGH. UART rank A>B, B>A, A>B, B>A. Base scores 127 and 0 fixed. fem_delta 0 then 256 on B. FEM stayed life=3 ft=2 compacted=1. Prior bits 3ccd03f8 and 1db38691 remain on disk. BOARD_PASS=NO. PROGRAM.DONE=NA. C RTL unedited.
RUN_PROVENANCE: Owner ordered the unique fem_spear_semantic board candidate. WNS=+0.352 WHS=+0.012. JSON sha256 a94aaad375878922cf0cc1a954b858c002be74ebcf4cca53da9267858eeb5619. JTAG 210319BE776EA.
OBSERVATION: rank0 alternated 0xA1 and 0xB1. No descriptor was sent on UART.
HYPOTHESES: H1 FACT influence toggle flipped rank with fixed bases. H2 FACT old identity files were not overwritten. H3 CONTRADICTED BOARD_PASS.
HOW_TRACE: Synth, route, bitstream, program EOS HIGH, UART script exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Rank order | FACT | UART print and JSON |
| Old bits kept | FACT | rehash prefixes 3ccd03f8 and 1db38691 |
| BOARD_PASS | CONTRADICTED | ceiling |
SUCCESS_VS_FAILURE: The four-arm order matched with stable bases and FEM state.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: uart_fem_spear_rank.py
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: New out dir. Ban previous SHAs in the program script. Quote the new SHA. Do not rewrite cand_desc.
STRUCTURAL_GUARD: Pass ceilings stay NO. Do not edit C. Do not repeat the frozen Q* mux test.
BLAST_RADIUS: SRAM now 52b923a6. Disk copies of prior identities kept.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-SPEAR-SEMANTIC-UART-CANDIDATE-20260922T011200Z
NEXT_DECISIVE_EXPERIMENT: None unless a new contradiction appears. Do not repeat this rank sequence without a new question.
OWNER_AND_STOP_CONDITION: Stop if a later run edits cand_desc or restamps BOARD_PASS.
HANDOFF_STATUS: COMPLETE
