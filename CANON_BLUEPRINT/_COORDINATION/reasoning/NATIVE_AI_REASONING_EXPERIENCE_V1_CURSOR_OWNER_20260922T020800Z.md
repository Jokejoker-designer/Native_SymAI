REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-PUBLISH-SPEAR-QSTAR-ASTRA / 20260922T020800Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent verify then public GitHub of COMPLETE after 491f844: 3ccd03f8 closure SUPPORTED; 52b923a6 rank UART CANDIDATE CONTRADICTION_FOUND=NO; 8b632b4a SPEAR-to-Q* UART CANDIDATE CONTRADICTION_FOUND=NO; ASTRA discovery split; cf246499 action-precheck UART CANDIDATE nfail=0; integrated XSim e112783e; 435bdc88 BIT_OK PROGRAM=NO. Watch did not program. No .bit in git. Prior unique dirs not overlaid. PASS ceilings unchanged.
RUN_PROVENANCE: Owner asked GitHub update. Last public SHA 491f844. Parent jsonl 7722376 @ 2026-09-22T02:03:25Z. Bits independently hashed. C hashes from AGENT_C worktree.
OBSERVATION: Five unique bit SHAs on disk. PROGRAM.txt present for 52b923a6 8b632b4a cf246499 EOS HIGH PROGRAM.DONE=NA. 435bdc88 PROGRAM.txt absent. JSON ORDER A>B,B>A,A>B,B>A. JSON ACTIONS 0,1,0,1. Precheck verdicts B0 B2 B0 B3 B4 nfail 0. Persist file still 1db38691. C FEM 45b9b930 Q* d4f64e65 SPEAR 11e71b50.
HYPOTHESES: H1 FACT unique identities. H2 FACT 8b632b4a action follows rank-0. H3 FACT 435bdc88 not programmed. H4 UNKNOWN live SRAM hash. H5 CONTRADICTED BOARD_PASS PROGRAM_PASS ASTRA_PASS FEM_PERSIST_PASS TIMING_PASS MIG_PASS PACK_ABI_24_24_PASS.
HOW_TRACE: Hashed bits JSON PROGRAM logs BUILD TIMING C RTL. Parsed UART arms. Copied new unique dirs only. No JTAG.
EVIDENCE_MATRIX:
| claim | class | evidence |
| 52b923a6 rank order | FACT | JSON a94aaad3 SRNK 0xA1/B1/A1/B1 |
| 8b632b4a actions 0,1,0,1 | FACT | JSON 7cc2f947 OFF/ON/OFF/ON |
| cf246499 five-arm | FACT | JSON 9394fd98 nfail 0 |
| 435bdc88 BIT_OK | FACT | Get-FileHash + BUILD.txt |
| 435bdc88 programmed | CONTRADICTED | PROGRAM.txt absent |
| Watch nạp | FACT | this watch issued no program Tcl |
SUCCESS_VS_FAILURE: Success is unique-dir publish without overlay, .bit commit, or PASS inflation. Failure would be programming 435bdc88 or overlaying 3ccd03f8 uart dir.
FIRST_DIVERGENCE: NONE this publish.
DECISIVE_TEST: Independent hashes vs source files; git add excludes .bit/.dcp and published unique overlays.
ROOT_CAUSE_OR_UNKNOWN: N/A for publish. Live SRAM hash UNKNOWN.
REUSABLE_DECISION_PROCEDURE: One new unique dir per identity after a published UART dir. Do not overlay. Do not program an unquoted BIT_OK.
STRUCTURAL_GUARD: PROGRAM=NO for 435bdc88. No .bit in git. C RTL unedited. Frozen identities not rebuilt by this watch.
BLAST_RADIUS: New GitHub unique dirs and ledger only. Watch did not write SRAM.
VERDICT_BY_LAYER: PASS_XSIM plus UART_BOARD_SMOKE_CANDIDATE on named SHAs. BIT_OK 435bdc88 PROGRAM=NO. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. ASTRA_PASS=NO. MIG_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Owner quotes 435bdc88 before PROGRAM. Watch does not nạp unless that quote is explicit.
OWNER_AND_STOP_CONDITION: Stop if C RTL is edited, a frozen SHA is rebuilt, or .bit is committed.
HANDOFF_STATUS: COMPLETE
