NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PACK-SLOT-ROOT-20260922T044500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Pack slot 1 is window addr[21:20]=01 because SLOT1_BASE is 28'h010_0000 (bit 20). Query visibility follows pack_loader.active_generation. XSim was not run.
RUN_PROVENANCE: FACT from pack_loader.sv, mig_ui32.sv, mig_ui_bram.sv, and a non-XSim bit decode. RTL/TB updated. No xvlog, no xsim, no bitstream.
OBSERVATION: FACT — pack_loader SLOT1_BASE = 28'h010_0000 = 0x00100000 = 2^20. Bit 20 is set. Bit 24 is clear. FACT — 0x01000000 = 2^24 is a different constant. Decoding that misread with addr[20] puts it in window 0 with slot 0. FACT — mig_ui32 takes lane addr[3:2] and beat addr[27:4]. mig_ui_bram indexes {addr[21:20], addr[13:4]}. The 32-bit word key is window=addr[21:20], word=addr[13:2]. FACT — slot0 base 0 decodes to window 0. Slot1 base 0x100000 decodes to window 1. FEM 28'h0200000 decodes to window 2. The 12-word records have an empty (window, word) intersection. The bit-24 misread intersects all 12 slot0 words. FACT — pack_loader S_COMMIT is the only update of active_generation and slot_bit. R_STALE (0x0E) is taken in S_DEC of BEGIN when the new generation is less than or equal to the active root, before a page write.
HYPOTHESES: H1 — a private RAM index addr[20] plus addr[5:2] matches this payload but is not the canonical decoder. CONTRADICTED as the model to keep. The DUT now uses win_of/word_of. H2 — a host visible_generation can prove pack-root visibility. CONTRADICTED. That port was removed.
HOW_TRACE: Read pack_loader SLOT1_BASE and mem_addr. Read mig_ui32 lane/beat and mig_ui_bram widx. Evaluated the four bases in Python. Replaced the DUT index and deleted the host generation port. Pointed the query at active_generation and at the word-0 address the loader actually wrote.
EVIDENCE_MATRIX: FACT pack_loader.sv SLOT1_BASE 28'h010_0000. FACT mig_ui_bram.sv widx {app_addr[21:20], app_addr[13:4]}. FACT mig_ui32.sv lane mem_addr[3:2], beat {mem_addr[27:4], 4'b0}. FACT Python overlap_canonical_slot0_slot1 is empty. FACT Python overlap of 0x01000000 with slot0 is the full 12-word set. INFERENCE G2 cannot overwrite G1 under this decoder because the loader's second commit address has bit 20 set. NOT_RUN XSim.
SUCCESS_VS_FAILURE: Architectural resolution recorded. XSim success is not claimed.
FIRST_DIVERGENCE: Reading 28'h010_0000 as 0x01000000 moves the set bit from 20 to 24 and collapses both slots into window 0.
ROOT_CAUSE_OR_UNKNOWN: The alias is real for the misread constant. It is not the ABI constant.
REUSABLE_DECISION_PROCEDURE: Print the 28-bit literal in decimal or as a power of two before choosing a bank bit. Use addr[21:20] for the window and addr[13:2] for the 32-bit word. Do not add a second base constant in the query path.
STRUCTURAL_GUARD: DUT stores at win_of(mem_addr)/word_of(mem_addr). Query reads slot_base_seen captured from the loader write. No visible_generation port. Stale resend of G1 must leave active_generation at 2 and must not add writes.
BLAST_RADIUS: pack_gen_vis runtime and its testbench only. pack_loader.sv base unchanged. Frozen bits unchanged. gold.py unchanged. C RTL unchanged.
VERDICT_BY_LAYER: PASS_STATIC on the address decode. PASS_IMPLEMENTED on the DUT/TB edit. XSIM_NOT_RUN. BOARD_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: LESSON-PACK-SLOT1-BIT20-20260922T044500Z
NEXT_DECISIVE_EXPERIMENT: XSim of the four arms only after this resolution is accepted. Same QueryRecord S. Roots: unset miss, G1 to primitive 0, G2 to primitive 1, stale G1 leaves root G2 and the same query still returns primitive 1.
OWNER_AND_STOP_CONDITION: AGENT_D stops before XSim. Do not retarget SLOT1_BASE. Do not stamp PACK_ABI_24_24_PASS.
HANDOFF_STATUS: COMPLETE
