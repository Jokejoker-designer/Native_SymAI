NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PACK-MIG-WINDOW-XSIM-20260922T085400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: MULTI_RECORD_MIG_WINDOW_XSIM_CANDIDATE=SUPPORTED on the mig_ui_bram stand-in. Not MIG_PASS. 90220cb5 not modified.
RUN_PROVENANCE: Log D:/FPGA/arty_d/UART_R2/pack_mig_window/xsim/pack_mig_window_xsim.log sha256 6d9b62ab37494d6595fe9e36e5e0fc2632fc3f0e4a688d09667ca6e22ea53591 finish 16045 ns. No bitstream. No program.
OBSERVATION: FACT the same two-record pack writes 24 words through mig_ui32 into mig_ui_bram. FACT beat 0 is subject 0x00010100 and beat 4 is subject 0x00010101. FACT subject selection, unknown miss, and stale root behavior match the private-RAM multi-record discriminator. FACT the stand-in is not generated mig0.
HYPOTHESES: Passing this stand-in is MIG_PASS. CONTRADICTED. The claim name stays at the XSim layer.
HOW_TRACE: Leave the frozen bit and the private-RAM multi-record sources in place. Add a new runtime whose only new cut is the mig_ui32 to mig_ui_bram path. Run that XSim.
EVIDENCE_MATRIX: FACT log hash and beat display. NOT MIG_PASS. NOT a board identity.
SUCCESS_VS_FAILURE: New cut passed in XSim. Old checkpoints were not rebuilt.
FIRST_DIVERGENCE: NONE in this run.
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Move one storage boundary at a time. Keep the previous discriminator's sources untouched.
STRUCTURAL_GUARD: Do not rebuild 90220cb5. Do not call mig_ui_bram a generated mig0. C audit before any bit.
BLAST_RADIUS: pack_mig_window only.
VERDICT_BY_LAYER: PASS_XSIM for MULTI_RECORD_MIG_WINDOW_XSIM_CANDIDATE. MIG_PASS=NO. BOARD_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Independent audit of this log. No bitstream until that audit.
OWNER_AND_STOP_CONDITION: AGENT_D stops at the XSim handoff.
HANDOFF_STATUS: COMPLETE
