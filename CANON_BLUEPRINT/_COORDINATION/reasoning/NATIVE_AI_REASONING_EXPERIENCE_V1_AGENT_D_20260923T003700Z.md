NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: SR-ABI-SPLIT-20260923T003700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Two StructuredResult layouts exist and must not be mixed. The live numbered ABI file defines 48 bytes with magic. The 40-byte table is an archived candidate whose first byte is status and which has no magic. No new packer is adopted. The SRAM image was not replaced.
RUN_PROVENANCE: CANON_BLUEPRINT/04_ABI_AND_PROTOCOL.md §4.4 title "StructuredResult R0.1 — 384 bits / 48 bytes" lists magic as the first field. §4.12 locks StructuredResult magic 0x4E52 and status values 0x01 through 0x06. CANON_BLUEPRINT/_ARCHIVE/MASTER_BLUEPRINT.md §22.2 row says "StructuredResult | 40 B candidate". §22.4 field list starts with status and includes unit_id and conflict_count. rtl/native_ai/directory/query_result_bind.sv writes bytes 0..1 as 0x52, 0x4E and byte 3 as status, into a 48-byte array.
OBSERVATION: FACT: §4.4 and the legacy packer agree on a 48-byte record that begins with magic. FACT: the archive blueprint labels 40 bytes as a candidate and does not start with magic. FACT: sr_host_frame_r1 packed magic and status into one 32-bit word. FACT: sr48_active_ref_r1.sv was written from the 48-byte offsets and was not finished as a passing cut. Neither file is an authority.
HYPOTHESES: NONE. The owner must name which document governs the next host frame.
HOW_TRACE: Read the plan. Read §4.4, §4.12, archive §22.2 and §22.4, and the packer byte stores. Did not run the unfinished 48-byte sim to a pass. Did not program. Did not edit fem_lifecycle, spear_rank, or qstar_select.
EVIDENCE_MATRIX: 04_ABI_AND_PROTOCOL.md §4.4 and §4.12. _ARCHIVE/MASTER_BLUEPRINT.md §22.2 and §22.4. query_result_bind.sv lines that store magic at bytes 0 and 1.
SUCCESS_VS_FAILURE: The split is identified. A packed result for this path is not adopted.
FIRST_DIVERGENCE: Byte 0 is magic in §4.4 and status in the 40-byte candidate.
DECISIVE_TEST: Name one file as the authority, then pack only that file's offsets.
ROOT_CAUSE_OR_UNKNOWN: A later R0.1 ABI section and an older candidate blueprint were both still readable. A hybrid word was built from memory of the magic plus the live status mux.
REUSABLE_DECISION_PROCEDURE: Before packing a result, quote the file and the byte-0 field. If byte 0 differs, stop.
STRUCTURAL_GUARD: Do not merge 40-byte offsets with 0x4E52. Do not replace SRAM image e2d97151… for this question.
BLAST_RADIUS: Plan ABI_SPLIT note. No bitstream. Unfinished sr48 module is not a cut.
VERDICT_BY_LAYER: ABI_SPLIT recorded. No PASS. BOARD_PASS=NO. PROGRAM_PASS=NO. ANSWER_EMITTED=NO.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Owner names 04_ABI_AND_PROTOCOL.md §4.4 or the archive 40-byte candidate. Then one packer, XSim only, SRAM unchanged.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop if a frame uses offsets from both documents.
HANDOFF_STATUS: COMPLETE
