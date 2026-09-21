REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-PERSIST-LEGAL-COMPACT-CLOSURE / 20260921T162400Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent closure audit of 1db38691 legal-compact JSON found no contradiction sufficient to block freeze. FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE=SUPPORTED. Storage/recovery research CLOSED unless a new contradiction. Identity binding is programmed SHA plus no-reprogram provenance plus unique FEM UART, not live SRAM hash. PROGRAM.DONE=NA. FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO MIG_PASS=NO TIMING_PASS=NO PACK_ABI_24_24_PASS=NO. Next question is recovered FEM vs SPEAR/Q* decision. Unique persist top cannot run that test (SPEAR/Q* idle).
RUN_PROVENANCE: Owner authority 07fa414555a7c729cc4d4e4dd093a35a03ea2aa6. C fem_lifecycle.v sha256 45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed unedited. JSON 6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f. Harness f6da7ae0d3d1fea11ce2d3d2d3d47b3a4a748cd8c3d031a04ce3cab1866b2bbe. Disk bit 1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668. No program this turn. No DEST_POKE. No C edit. Historical UART_SMOKE 822f8750… kept. SUPERSEDED_BY_CAUSAL_AUDIT prepended to D/watch T143303Z T144000Z DEST_READ-first exports.
OBSERVATION: Independent CRC 0x552e / A_CRCW a5a5552e. JSON has c0117ed0 x8 and no 44504B31. C_COMMIT is the only C T2 COMMIT_MAGIC writer. dest_diag can DPK but this capture did not. Pack SLOT0=0 SLOT1=0x0100000 does not alias FEM_BASE 0x0200000. fem_t2_ce dest_hold clears on fem_rst_n. FOBS_AFTER_FRST virgin then FREC recov=2. DEST_READ after FRST is dest_diag, not dest_hold. Unique top q_start=0 prop_start=0 feat_flat=0.
HYPOTHESES: H1 FACT legal compact+COMMIT+FRST retention+COMMITTED_NEW on this candidate. H2 FACT missing historical C0117ED0 was FREP omit. H3 STRONG_INFERENCE live identity still 1db38691. H4 CONTRADICTED dest_diag manufactured magic this run. H5 CONTRADICTED FEM dest_hold served post-FRST DEST_READ. H6 CONTRADICTED global FEM_PERSIST_PASS. H7 FACT 1db38691 cannot prove FEM→decision. H8 UNKNOWN power-loss persist.
HOW_TRACE: Re-read JSON raw_hex vs FOBS/DEST_READ packing; grep COMMIT_MAGIC / DPK / FEM_BASE; read C_COMMIT and R_CLASS; read fem_t2_ce rst dest_hold; read unique SPEAR/Q* ties; recompute CRC; git HEAD 07fa414; hash JSON/harness/C/bit.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Legal compact on silicon | FACT | FOBS gates + DEST_READ beats |
| COMMIT magic writer this run | FACT | C_COMMIT; no DPK in JSON |
| Media retained across FRST | FACT | bit-identical dest_diag beats |
| FREC COMMITTED_NEW | FACT | recov=2 after virgin FOBS; RTL R_CLASS |
| Live SRAM SHA | UNKNOWN | not read back |
| FEM_PERSIST_PASS | CONTRADICTED | ceiling locked NO |
| FEM→SPEAR/Q* | NOT_TESTED | idle ties |
SUCCESS_VS_FAILURE: Success of closure = no concrete contradiction in the nine-item search. Failure would be DPK in capture, alias to SLOT, dest_hold explaining DEST_READ, CRC mismatch, or FREC without media. None found.
FIRST_DIVERGENCE: NONE this audit vs legal-compact JSON. Historical smoke FIRST_DIVERGENCE remains TEST_HARNESS_FREP_OMITTED.
DECISIVE_TEST: This audit (RTL+capture). No new silicon.
ROOT_CAUSE_OR_UNKNOWN: Historical DEST_READ miss ROOT=harness without FREP SUPERSEDED_BY_CAUSAL_AUDIT. This candidate ROOT=N/A (observed legal path).
REUSABLE_DECISION_PROCEDURE: Search alternate COMMIT writers and DPK before blaming MIG. Gate compact on FOBS RESOLVED then COMPACTED then DEST_READ magic. After FRST require virgin FOBS before crediting FREC. Do not treat programmed SHA as live SRAM hash. Do not restimulus COMMIT/FRST/FREC after a clean closure unless a new contradiction appears.
STRUCTURAL_GUARD: Keep all PASS stamps NO. Do not edit C FEM RTL. Do not DEST_POKE. Do not rebuild persist-repeat bit. Next bit if any is FEM influence integration with owner PROGRAM.
BLAST_RADIUS: Persist research freeze and D roadmap marker. Unique persist bit file untouched. dest TAP bits untouched. C RTL untouched. FE256 freeze untouched.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE legal compact+FRST+FREC PASS_IMPLEMENTED for this scoped class only. FEM_PERSIST_PASS=NO. MIG_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-LEGAL-COMPACT-CLOSURE-NO-CONTRADICTION-20260921T162400Z ; FEM-TO-SPEAR-QSTAR-CAUSAL-NEXT-20260921T162400Z
NEXT_DECISIVE_EXPERIMENT: Design FEM_TO_SPEAR_QSTAR_CAUSAL_EXPERIMENT.md. A/B/A/B with FEM the only changed variable. Not runnable on 1db38691.
OWNER_AND_STOP_CONDITION: Stop persist-repeat. Stop if C FEM RTL edited, DEST_POKE, or PASS self-stamp. New integration bit needs owner PROGRAM of a quoted SHA.
HANDOFF_STATUS: COMPLETE
