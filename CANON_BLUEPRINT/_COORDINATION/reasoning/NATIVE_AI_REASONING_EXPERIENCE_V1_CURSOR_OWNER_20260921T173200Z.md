REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-PUBLISH-FEM-QSTAR-ABAB-XSIM-BIT-UART / 20260921T173200Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent verify then public GitHub of Q* A/B/A/B PASS_XSIM (log a4d5576e greedy 0,1,0,1 at 12445 ns), unique BIT_OK 3ccd03f8… WNS=+0.468 WHS=+0.010, and UART_BOARD_SMOKE_CANDIDATE on the same SHA (JSON 302c7bd4 QOBS 0,1,0,1 A2 ft=2). Watch did not program. No .bit in git. Prior unique dirs not overlaid. PASS ceilings unchanged.
RUN_PROVENANCE: Owner asked GitHub update. Last public SHA b2016cc. Parent jsonl 7327006 @ 2026-09-21T17:08:43Z. Disk COMPLETE after jsonl: bit 00:30+07, PROGRAM.txt + UART JSON 00:32+07. C hashes from AGENT_C worktree and Native_SymAI PACKAGE.
OBSERVATION: XSim ARM lines match. Independent bit hash equals BIT_SHA256.txt. PROGRAM.txt in results/FEM_QSTAR_CAUSAL_20260922 STATUS=PROGRAMMED EOS=HIGH PROGRAM.DONE=NA. JSON QOBS A/B/A2/B2 greedy 0,1,0,1; A2 ft=2 life=3 compacted=1; dest_poke=NO; no 44504B31. Persist disk bit still 1db38691. Design Timing Summary WNS 0.468 WHS 0.010. loops=0.
HYPOTHESES: H1 FACT mux isolation in XSim. H2 FACT same discriminator on UART JSON. H3 FACT 3ccd03f8 != 1db38691. H4 UNKNOWN live SRAM hash. H5 CONTRADICTED BOARD_PASS / PROGRAM_PASS / FEM_PERSIST_PASS / TIMING_PASS / MIG_PASS / PACK_ABI_24_24_PASS.
HOW_TRACE: Hashed log DUT TB C RTL bit DCP BUILD TIMING check_timing PROGRAM JSON. Read QOBS records. Copied into new unique dirs only. No JTAG from this watch.
EVIDENCE_MATRIX:
| claim | class | evidence |
| greedy 0,1,0,1 XSim | FACT | log a4d5576e finish 12445 ns |
| greedy 0,1,0,1 UART | FACT | JSON 302c7bd4 QOBS_A/B/A2/B2 |
| A2 media held | FACT | UART ft=2 life=3 compacted=1 |
| BIT_OK 3ccd03f8 | FACT | Get-FileHash + BIT_SHA256.txt |
| PROGRAMMED EOS HIGH | FACT | PROGRAM.txt 2bf285fc… JTAG 776EA |
| Watch nạp | FACT | this watch issued no program Tcl |
| jsonl-idle miss | FACT | jsonl 17:08Z vs bit/UART 00:30–00:32+07 |
SUCCESS_VS_FAILURE: Success is unique-dir publish without overlay, .bit commit, or PASS inflation. Failure would be overlaying DESIGN_LOCKED dir or stamping BOARD_PASS.
FIRST_DIVERGENCE: NONE this publish. Jsonl-idle miss of BIT/PROGRAM is expected.
DECISIVE_TEST: Independent hashes vs source files; git add excludes .bit/.dcp and published unique overlays.
ROOT_CAUSE_OR_UNKNOWN: N/A for publish. Live SRAM hash UNKNOWN.
REUSABLE_DECISION_PROCEDURE: New unique dir per COMPLETE layer. Do not overlay DESIGN_LOCKED with later XSim/BIT/UART. Do not treat jsonl freeze as no-COMPLETE.
STRUCTURAL_GUARD: No .bit in git. C RTL unedited. Persist file keep. No PASS stamp.
BLAST_RADIUS: New GitHub unique dirs and ledger only. Watch did not write SRAM.
VERDICT_BY_LAYER: PASS_XSIM. BIT_OK. UART_BOARD_SMOKE_CANDIDATE. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. MIG_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-QSTAR-ABAB-UART-CANDIDATE-20260922T003200Z already on disk. Publish adds unique-dir layering.
NEXT_DECISIVE_EXPERIMENT: Do not restamp. SPEAR stays idle on this bit. Watch does not nạp again unless owner quotes a new SHA.
OWNER_AND_STOP_CONDITION: Stop if C RTL is edited, 1db38691 is programmed as the decision DUT, or .bit is committed.
HANDOFF_STATUS: COMPLETE
