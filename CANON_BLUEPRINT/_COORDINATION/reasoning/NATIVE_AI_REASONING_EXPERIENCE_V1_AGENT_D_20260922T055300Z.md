NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PACK-GEN-VIS-BIT-20260922T055300Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Bitstream file exists. SHA256 12878be8889c4c6bbb025b0f3d3c0a42a41745766d67e1f30878059a5732d701. Not programmed. Not a board candidate.
RUN_PROVENANCE: Route WNS +0.340 WHS +0.019. BUILD.txt STATUS=BIT_OK. PROGRAM=NO. C_RECOMMEND_BOARD_BUILD=NO was recorded and not overridden into a board claim. Owner requested the file.
OBSERVATION: FACT the first route WNS was -0.434. Phys-opt reached -0.111 and wrote no bit. FACT the read-data mux was registered for one cycle in pack_vis_runtime. FACT rerun XSim log c435d86d5d129d4ceb6c39430391d32840b9ad0337b77be8c1e36402af1cd992 still printed SUPPORTED with the same four arms. FACT the C-audited log 5e9a787d… was copied aside and was not the netlist of this bit. FACT frozen SHA reject list did not match 12878be8….
HYPOTHESES: Positive WNS is TIMING_PASS. CONTRADICTED. The build record keeps TIMING_PASS=NO.
HOW_TRACE: Route abort, phys-opt abort, pipeline the wrapper RAM read, rerun XSim, rebuild, hash the bit.
EVIDENCE_MATRIX: FACT bit sha above. FACT WNS +0.340 WHS +0.019. FACT XSim c435d86d SUPPORTED. FACT C audit remains on 5e9a787d and RECOMMEND_BOARD_BUILD=NO. NOT PROGRAMMED.
SUCCESS_VS_FAILURE: File written. Board experiment not run.
FIRST_DIVERGENCE: Setup slack was negative until the read mux was registered.
ROOT_CAUSE_OR_UNKNOWN: The loader wr_len cone plus the combinational RAM read missed 100 MHz by 0.434 ns.
REUSABLE_DECISION_PROCEDURE: Do not emit a bit on negative WNS. A one-cycle registered read in the D wrapper can be checked by rerunning the same discriminator before a second route.
STRUCTURAL_GUARD: Do not program 12878be8 until the owner says the board is ready and the file hash matches. Do not call it the C-audited netlist. Do not stamp TIMING_PASS or BOARD_PASS.
BLAST_RADIUS: build_pack_gen_vis only. Frozen bits untouched.
VERDICT_BY_LAYER: PASS_XSIM on c435d86d for the pipelined read. BIT file only. TIMING_PASS=NO. PROGRAM=NO. BOARD_PASS=NO.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: None until the owner plugs the board and asks to program this SHA. C has not audited the pipelined-read log.
OWNER_AND_STOP_CONDITION: AGENT_D stops. No program.
HANDOFF_STATUS: COMPLETE
