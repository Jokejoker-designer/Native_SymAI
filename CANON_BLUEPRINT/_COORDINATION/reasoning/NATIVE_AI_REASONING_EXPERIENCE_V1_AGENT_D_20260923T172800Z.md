NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: G2-JA-LOOP-20260923T172800Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: PASS_XSIM only. Same generation, same command C001 primitive 1, drive pin held 1. Open input stays 0 and the proposal stays 1. A testbench wire makes the synchronized input 1, FEM stores code 4, and the next proposal becomes 0. This is not a copper jumper and not a package measurement.
RUN_PROVENANCE: Local Digilent master XDC header says Arty A7-100 Rev. D. Lines map PACKAGE_PIN G13 to ja[0] sch=ja[1] and PACKAGE_PIN B11 to ja[1] sch=ja[2], both LVCMOS33. RTL g2_ja_loop_r1.sv SHA256 3bc914cd57219fb1a82cb0bd30a9bfc04cc725307aff64383b21db4bc7d6ed51. TB SHA256 2d42b1a86e12d144903faeb99cd4d59663877bd9dd1f850b01bdc4be95953e74. XDC SHA256 ef0c8848d54e6f11c9933bece4692f610e5ee69b4639305b6dd61c598d9a4cea. Log SHA256 bb79156a3dcae8841812a90ed6c14d712c729e7f0dbf4c77bb3da33d20ff796f finish 10595 ns.
OBSERVATION: FACT: open arm printed closed=0 ref=f2a071fe prim=1 id=0000c001 drive=1 sync=0 qual=0 feat=0 prop=1. FACT: closed arm printed closed=1 with the same ref, primitive, and id, sync=1 qual=1 feat=1 prop=0. FACT: the testbench assigns effect_sense from effect_drive only when jumper=1. FACT: the DUT has no assign between those ports. FACT: pin_readback is given constant 3'd4 and samples only when the qualifier is true. INFERENCE: a raw stored 1 would have failed the existing admit rule because primitive 1 and command_valid both equal 1.
HYPOTHESES: The copper jumper on the plugged board will match the closed arm. UNKNOWN until the PCB revision is read and a voltage is measured. The local XDC header does not say Rev E.
HOW_TRACE: Read the plan. Confirmed G13 and B11 in the local master XDC. Wrote a new identity. Did not edit fem_lifecycle, spear_rank, qstar_select, g2_pin, or the closed top. Ran one XSim with both arms. Did not implement the XDC. Did not program.
EVIDENCE_MATRIX: Log bb79156a3dcae8841812a90ed6c14d712c729e7f0dbf4c77bb3da33d20ff796f. Module 3bc914cd57219fb1a82cb0bd30a9bfc04cc725307aff64383b21db4bc7d6ed51. TB 2d42b1a86e12d144903faeb99cd4d59663877bd9dd1f850b01bdc4be95953e74. XDC ef0c8848d54e6f11c9933bece4692f610e5ee69b4639305b6dd61c598d9a4cea. Master pin lines are comments in Arty-A7-100-Master.xdc at the UART_DDR reference copy.
SUCCESS_VS_FAILURE: Open arm did not update FEM. Closed testbench arm did, and the proposal changed from 1 to 0. Same command both times.
FIRST_DIVERGENCE: sense_sync is 0 on the open arm and 1 on the closed arm. Everything else in the printed command line matches.
DECISIVE_TEST: On one bitstream, leave JA1 and JA2 open, then connect only the jumper. The proposal may change only on the closed arm. XSim cannot answer that.
ROOT_CAUSE_OR_UNKNOWN: A one-bit copy of drive=1 collides with primitive 1. The qualifier requires a low baseline and a later match. FEM stores code 4, not the raw 1.
REUSABLE_DECISION_PROCEDURE: Do not store the raw loopback bit when that bit equals the primitive. Qualify on the input change, and keep the raw pin in the log.
STRUCTURAL_GUARD: PULLDOWN is in the unapplied XDC so an open JA2 is not a float. Do not use sw or led as the plant. Do not program before the silkscreen revision is read.
BLAST_RADIUS: New files under g2_ja_loop_r1 only. Frozen C RTL and prior identities unedited. No bitstream.
VERDICT_BY_LAYER: PASS_XSIM for the testbench open and closed arms. Not PASS_IMPLEMENTED. Not PASS_BOARD. PACKAGE_PIN_MEASURED=NO. BOARD_PASS=NO. PROGRAM_PASS=NO. INDEPENDENT_C_AUDIT=NOT_RUN.
LESSON_TO_SHARE: LESSON-JA-LOOPBACK-ONE-IS-AN-ECHO
NEXT_DECISIVE_EXPERIMENT: Read the PCB revision. If it is not Rev D, stop and use that revision's schematic before any program. Then one bitstream, open arm, then closed jumper.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop if the board revision is not Rev D. Do not call the testbench wire a physical proof.
HANDOFF_STATUS: COMPLETE
