NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-04-ASTRA-EDGE-QEVAL-256
RUN_ID: 20260917T084800Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Common-runtime DUT astra_edge_qeval is bit-exact 256/256 vs B gold at PASS_XSIM. Not FE256_PASS. Dedicated fe256_query_path is not instantiated. Freeze top and M4 hop-1 top unchanged.
RUN_PROVENANCE:
  astra_edge_qeval.sv sha256 825b1eafe8c2f002e7904d3bad41759a5c2aeb4ffbf0389c28c38f8728be5872
  fe256_query_path.sv UNTOUCHED 4c69e8fbfafe7d75d667b653639bec453c0510bf7d032ec6ce27b870568d0241
  fe256_store.mem sha256 6a1815c6be9baf5bdbcc5a74209f9e9b9f82a8230996e36b520a298165150ee8 n=218
  gold results 9a3aec0d7b54764bfcf1155ad91083bc0b4097fdb28c58f1680931acfaa35ad5 unmodified
  B TB f95b10b2… unmodified
  xsim.log sha256 56fd6f725fbaa7daf5bfab93b9a0304750b61c4e0ba366d38e9f87938dfc4290 finish 1488295 ns
OBSERVATION:
  FACT — XSim banner COMMON_RUNTIME_FE256_XSIM 256/256 fail=0. Simulation only.
  FACT — DUT module name astra_edge_qeval. fe256_query_path not in the snapshot.
  FACT — Store ROM matches freeze store hash 6a1815c6… (pack edges, not result gold).
  FACT — M4 candidate still instantiates query_result_bind. Freeze candidate still instantiates fe256_query_path.
  FACT — PROGRAM=NO. C RTL hashes unchanged.
HYPOTHESES:
  H1 (INFERENCE): Algorithm is the freeze Q-eval copied into astra/; bit-exact follows if store+gold match.
  H2 (FACT): This is not hybrid-instantiation of fe256_query_path.
  H3 (HYPOTHESIS): Owner may still class a copy as FE256-only path vs common runtime. Documented as CANDIDATE.
HOW_TRACE:
  Export/copy store-scan Q-eval into rtl/native_ai/astra/astra_edge_qeval.sv
  -> D-04 TB DUT swap
  -> xvlog/xelab/xsim same B hex
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Bit-exact | 256/256 | xsim.log 56fd6f72… | PASS_XSIM
  Oracle import | gold unmodified | hex sha MATCH | FACT
  Dedicated engine | not instantiated | xvlog only astra_edge_qeval | FACT
  Product top | M4 still hop-1 | arty_a7_r2_top_m4_mig_candidate.sv | FACT
  Freeze DCP | untouched | not opened this run | FACT
SUCCESS_VS_FAILURE:
  Success: D-04 bind to B comparator, 256/256 XSim, no gold rewrite, no fe256_query_path instance.
  Failure to retire: timing/board/product-top still missing; FE256_PASS not claimed.
FIRST_DIVERGENCE:
  None vs gold this run. Divergence vs product: M4 UART path still SEARCH_INCOMPLETE hop-1.
DECISIVE_TEST:
  Same B 256 hex; pass=256 fail=0 finish 1488295 ns.
ROOT_CAUSE_OR_UNKNOWN:
  ROOT of prior 12/256: hop-1 packer without edge store. This DUT uses the 218-edge pack ROM + §03.9 scan.
REUSABLE_DECISION_PROCEDURE:
  Load pack edges as ROM, run §03.9 scan, compare B gold. Do not instantiate fe256_query_path. Do not stamp FE256_PASS from XSim.
STRUCTURAL_GUARD:
  D-04 TB comment: not fe256_query_path. JSON not_claimed includes FE256_PASS and DEDICATED_FE256_ENGINE_RETIRE.
BLAST_RADIUS:
  astra_edge_qeval.sv, D-04 TB, run_xsim.bat. Not C RTL, freeze DCP, M4 top, gold.
VERDICT_BY_LAYER:
  PASS_XSIM: 256/256 D-04
  PASS_IMPLEMENTED: astra_edge_qeval exists; not on M4 top
  PASS_BOARD: NO
  FE256_PASS: NO
  ASTRA_PASS: NO
LESSON_TO_SHARE: D-04-EDGE-QEVAL-XSIM-256
NEXT_DECISIVE_EXPERIMENT:
  Owner-auth bind astra_edge_qeval onto M4 candidate (not freeze). Pack board class still blocks FEM persist. PROGRAM=NO.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP FE256_PASS self-stamp. STOP freeze overwrite. STOP hybrid instance of fe256_query_path. GOAL open until Arty product path is testable as required.
HANDOFF_STATUS: COMPLETE
