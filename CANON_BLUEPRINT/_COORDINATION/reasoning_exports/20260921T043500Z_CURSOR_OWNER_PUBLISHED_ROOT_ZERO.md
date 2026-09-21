NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PUBLISHED-ROOT-ZERO / 20260921T043500Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: ASK_D Q1–Q5. Why published_root probe stays 0 after P2 is UNKNOWN until D measures dest_rd_pulse. PACK_ABI_24_24_PASS=NO. RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.
HANDOFF_STATUS: INCOMPLETE_HANDOFF
RUN_PROVENANCE: Isolated tb_rkb02_reloc.sv + pack_runtime_dut.sv + dest_root_cache.sv + mig_ui_bram fold. RKB02_OBS.json fd896dab… rkb02_xsim.log $finish 2775 ns. CT1-02 integrated log pub=0 root_v=1. AGENT_D 043300Z H4 CONTRADICTED.
OBSERVATION:
FACT — dest_root_cache assign published_root=pub_root; root_valid=pub_v. Reset both 0. load_ack sets pub_v=1; copies pending_root only if have_wr.
FACT — SLOT0 base 28'h0; SLOT1_BASE 28'h010_0000 → mig_ui_bram widx {addr[21:20],addr[13:4]} dest[0] vs dest[1024].
FACT — pack_runtime_dut query: UNSET_GEN or !root_valid → miss, no dest_rd. Else dest_root_cache dest-read app_addr=pub_root. No dest[] walk.
FACT — tb_rkb02 dc1/rkb02 do not AND root_valid or pub!=0.
FACT — RKB02_OBS p1/p2 pub=0000000; poison dest[0] hit=1 dest_rd=1; poison dest[1024] hit=0 dest_rd=1; RKB02_XSIM=1.
FACT — CT1-02 integrated: pub=0000000 root_v=1 before query.
INFERENCE — P1 pub=0 is SLOT0 published, not unpublished, when root_v=1.
INFERENCE — After P2, lookup SoT is dest[1024] not dest[0]; published_root probe is not SoT.
HYPOTHESES:
H1–H5 OPEN guesses withdrawn. ASK_D file D:/FPGA/arty_d/rkb_readback/ASK_D_PUBLISHED_ROOT.md Q1–Q5. Do not treat probe vs dest[1024] as explained until D measures c_addr at dest_rd.
HOW_TRACE: owner asked not to guess; mailbox OWNER→AGENT_D; questions only.
ROOT_CAUSE_OR_UNKNOWN: Why probe stays 0 after P2 while poison dest[1024] misses = UNKNOWN. ASK D.
NEXT_DECISIVE_EXPERIMENT: AGENT_D answers Q1–Q5 with $display at dest_rd_pulse. Stop guessing.
HANDOFF_STATUS: INCOMPLETE_HANDOFF
EVIDENCE_MATRIX: RTL FACT; OBS json FACT; poison CONTRADICTS probe-as-addr; ASTRA unrelated FACT.
SUCCESS_VS_FAILURE: N/A status question.
FIRST_DIVERGENCE: probe published_root vs dest[1024] poison.
DECISIVE_TEST: already run — wipe dest[0] then dest[1024]. Next: $monitor c_addr at dest_rd_pulse after P2.
ROOT_CAUSE_OR_UNKNOWN: Why probe stays 0 after P2 while lookup uses dest[1024] UNKNOWN. Do not treat probe as SoT.
REUSABLE_DECISION_PROCEDURE: 0 is legal SLOT0. Always sample root_valid. Relocation proof is double poison not pub hex. Query path is dest-read of published beat, not dest[] scan, not M4 ASTRA.
STRUCTURAL_GUARD: AND root_valid into dc1; AND (pub2!=0 or c_addr[20]) into rkb02; $display c_addr at dest_rd.
BLAST_RADIUS: analysis only. No RTL edit. No program.
VERDICT_BY_LAYER: PASS_XSIM RKB-02 isolated (D). Probe published_root NOT_SOT. NO 8/8 / PACK_ABI / BOARD.
LESSON_TO_SHARE: PUBLISHED-ROOT-ZERO-IS-SLOT0-NOT-ASTRA-20260921T043500Z
NEXT_DECISIVE_EXPERIMENT: Wave c_addr/pub_root/root_valid at dest_rd after P2 COMMIT. Do not stamp 8/8.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. No program. No C RTL. No gold.py.
HANDOFF_STATUS: COMPLETE
