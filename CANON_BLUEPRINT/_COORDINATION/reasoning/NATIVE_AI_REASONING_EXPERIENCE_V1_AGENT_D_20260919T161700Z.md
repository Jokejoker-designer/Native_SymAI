NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: SEMANTIC-TO-PHYSICAL-RESOLUTION / 20260919T161700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Independent falsification of SEMANTIC_ID → PHYSICAL_POINTER → PHYSICAL_PLACEMENT after Pack write. Do not treat as true before evidence. Separated from U33 R_BAD_MAGIC.
RUN_PROVENANCE: Read-only. No TAP/RTL/relocation TB. No overlay. No PASS stamp.
  pack_loader.sv sha256 58302aec460323059facf5856ee2cbdedc0c489506ac911e20b299c9a8c1a35a
  exact_directory.sv (Native_SymAI live) sha256 699fb145720259c5b720b21213a19eaad4f1bb46110e0d441d2dc354d58a3d28
  posting_walk.sv (Native_SymAI live) sha256 c1617ec259dac3bfe4f752bc2669b83dc3aa66526a167d12836c1276c559d59a
  query_posting_bind.sv sha256 fb8eea24f9e15142c44e3ad6bd94a4000bba9f84e4b429c7fa6855629cefddaf
  bounded_walk.sv sha256 1e6ad3a4ef357051b59bdb7995cb7749b8e5f64d141d7128eff7c059ae284be8
  export_directory.py sha256 55c0e966b05752bc3ea0bf9dbbb845dc0f0831ce5b0486105c067f84f83399c4
  U33 top sha256 c2385d82adcc0ed69cbb4606871fb9b0aa8c5c4698ff066366bcc32885783843
  spec 2026-09-19-semantic-to-physical.md sha256 0501aaf2bfeabc88bba6cf2f55b4e1963f6babcd9349b62af61741a5626c47d1
  M2 JSON D:/FPGA/arty_d/m2_query_posting/D_M2_QUERY_POSTING.json M2_QUERY_POST_XSIM_PASS rows=235; exact_directory/posting_walk hashes in that JSON differ from Native_SymAI live copies; query_posting_bind matches.
OBSERVATION:
  FACT — Write address is pack_loader mem_addr = slot_base + rg_ddr[wr_sel][27:0] + wr_off_bytes + {wr_idx,2'b00}. rg_ddr from OP_REGION hw1 (ddr_offset). slot_base from slot_bit ping-pong (0 or 28'h010_0000). Not semantic_id.
  FACT — S_COMMIT stores active_generation <= man_generation, flips slot_bit, load_ack. Does not write HotDirectoryEntry / posting / T2 tables.
  FACT — QueryRecord §04.3 has subject_id etc., no physical address.
  FACT — exact_directory $readmemh dir_a.mem; posting_walk $readmemh post_a.mem; BRAM index = ptr[15:4].
  FACT — bounded_walk hops on first_neighbor; first_edge_ref unused as MIG read.
  FACT — export_directory.py bakes dir_a.mem/post_a.mem/post_expect.hex from FE256 store-A; edge_ref = edge_id*32; first live page byte 16.
  FACT — U33 uart_fe256_host.in_valid=1'b0. query_result_bind present; walks BRAM via query_walk_bind, not Pack DDR.
  FACT — M2_QUERY_POST_XSIM_PASS is not M2_PASS. Gold post_expect.hex.
  FACT — Canon §02.4.8 says MIG map/relocation remains D's to measure. No relocation TB found.
  FACT — MAG is pack_loader S_DEC before REGION/PAGE/COMMIT. No causal wire from this hole to R_BAD_MAGIC.
HYPOTHESES:
  H1 (tested): system stores SEMANTIC_ID→PHYSICAL_POINTER at COMMIT — CONTRADICTED.
  H2 (tested): write path places bytes; query gets semantic IDs and expects directory/posting/walker to find them — CONFIRMED as current RTL behavior.
  H3: query would be placement-invariant today because it never reads Pack DDR — INFERENCE, NOT_TESTED as XSim.
HOW_TRACE: pack_loader S_WRITE/S_COMMIT → pack_mig_bind mem_* only → mig_ui_mux Pack A. Query: QueryRecord sid → exact_directory ROM → fwd_ptr → posting_walk BRAM → neighbor_id → bounded_walk. No mem_cmd from directory RTL.
EVIDENCE_MATRIX:
  PASS_IMPLEMENTED — quoted RTL/canon/host gold.
  PASS_XSIM — M2_QUERY_POST_XSIM_PASS isolated BRAM walk only (prior run).
  NOT_TESTED — Pack write G at P1 then P2, same Q, A1 vs A2.
  NOT_TESTED — DDR contents/addressing wrong.
  CONTRADICTED — COMMIT installs T1; FPGA semantic_id→app_addr; query uses Pack DDR; UART QueryRecord live on U33.
SUCCESS_VS_FAILURE: Success = named class from RTL. Failure would be claiming DDR corruption or using this hole to explain MAG.
FIRST_DIVERGENCE: After Pack S_COMMIT, T1 HotDirectoryEntry is not written from the committed page bytes. Query looks up a host-baked BRAM instead of the Pack slot.
DECISIVE_TEST: Relocation XSim same G at P1 vs P2 with directory filled from Pack vs from $readmemh — NOT_TESTED. Thought-test: current query A would not follow P.
ROOT_CAUSE_OR_UNKNOWN: Named class SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE / DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT. DDR corruption UNKNOWN/NOT_TESTED.
REUSABLE_DECISION_PROCEDURE: For every Pack COMMIT, ask: which RAM is written besides DDR payload? If T1/T2 index is $readmemh, tests can PASS without semantic→physical resolve. Do not call DDR corruption without a DDR readback fail. Do not attach MAG (pre-REGION) to directory (post-COMMIT).
STRUCTURAL_GUARD: MAG firewall. No PACK_ABI/M2/ASTRA/MIG/BOARD self-stamp. Do not treat M2 235/235 as relocation invariance.
BLAST_RADIUS: design spec + canvas + this export. No RTL. C RTL/freeze DCPs/identity H untouched.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED mapping-gap inventory.
  PASS_XSIM M2 isolated only, not this claim.
  NOT BOARD_PASS / M2_PASS / PACK_ABI_24_24_PASS / ASTRA_PASS / MIG_PASS / PROGRAM_PASS.
LESSON_TO_SHARE: SEMANTIC-TO-PHYSICAL-RESOLUTION-INCOMPLETE-20260919T161700Z
NEXT_DECISIVE_EXPERIMENT: If owner YES, a TB that Pack-writes G at ddr_offset P1, queries subject_id without $readmemh gold, relocates to P2. Stop if first hop still missing (no T1 install). Do not implement unless YES.
OWNER_AND_STOP_CONDITION: Stop. No RTL. No MAG mix. No PASS stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
