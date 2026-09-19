NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART_ROOT_CAUSE_AND_RESILIENCE_R2 / 20260917T144400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Arty SRAM holds isolated UART_R2 U3 candidate bit 17494f2c… End of startup HIGH. Other-branch bits/DCPs unchanged. Not PROGRAM_PASS / BOARD_PASS.
RUN_PROVENANCE: D:/FPGA/arty_d/UART_R2/build_u3/; RX u3 79fa752f…; host 9e768216…; JTAG 210319BE776EA; lease holder AGENT_D program=true
OBSERVATION:
  FACT — Owner: do not overwrite any other branch bitstream; independent UART_R2 path only.
  FACT — First image uart_r2_u2_candidate.bit sha256 ec322575… was PACKAGE live RX ab1b9571… written only under UART_R2/build. Not H. Kept on disk; not the isolated U3 candidate.
  FACT — U3 rebuild used UART_R2/u3/uart_rx_word.sv 79fa752f… into UART_R2/build_u3 only. Bit uart_r2_u3_candidate.bit sha256 17494f2c… End of startup HIGH.
  FACT — Other-branch snapshot n=46 VERIFY_OK after synth/impl/bit/program. H cf62102f… m4_mig f6a6091f… freeze f25fdf64 / 858d0e99 / b48b7c88 unchanged. PACKAGE live RX still ab1b9571….
  FACT — Route U3 LUT 11146 FF 9927 RAMB36=4 RAMB18=2 setup WNS +0.528 hold WHS +0.046. Not TIMING_PASS.
  FACT — m4_mig_clear/PROGRAM.txt still records identity H. UART_R2 PROGRAM.txt written only under build_u3.
  INFERENCE — Mixing PACKAGE live RX into UART_R2/build would have been a false UART_R2 identity; U3 is the isolated campaign RX.
  UNKNOWN — UART hop-1 / Pack24 board behavior on 17494f2c… (campaign not run). H19/H20 silicon SOURCE.
HYPOTHESES:
  Independent out-dir + unique bit name + banned SHA of other identities prevents cross-branch overwrite — CONFIRMED this run (VERIFY_OK n=46).
  Windows vivado.bat without `call` terminates the parent bat — CONFIRMED (synth-only exit after first flow).
HOW_TRACE: snapshot other hashes → synth PACKAGE-live into UART_R2/build (wrong RX vs isolated campaign) → keep that bit → synth U3 into build_u3 → program U3 only → re-hash locks.
EVIDENCE_MATRIX:
  PASS_IMPLEMENTED U3 bit + JTAG End of startup HIGH.
  PASS_XSIM prior U1–U6 isolated campaign (not re-run this step).
  NOT_RUN Pack24 board / hop-1 smoke this step.
  NOT_CLAIMED PROGRAM_PASS BOARD_PASS TIMING_PASS MIG_PASS.
SUCCESS_VS_FAILURE: Isolation succeeded; first programmed image was PACKAGE-live (documented, superseded in SRAM by U3). No other-branch mutation.
FIRST_DIVERGENCE: Isolated U3 RX 79fa752f vs PACKAGE live ab1b9571 vs identity H cf62102f.
DECISIVE_TEST: sha256 of locked bits after program; program tcl refuses H/m4_mig/ec322575 SHA and non-build_u3 paths.
ROOT_CAUSE_OR_UNKNOWN: Cross-identity overwrite is an operator/path error class, not an RTL bug. Silicon UART still UNKNOWN.
REUSABLE_DECISION_PROCEDURE: New identity ⇒ new directory + unique .bit name + hash-ban of every other known bit + snapshot/verify other artifacts before and after. call vivado.bat. Never write PROGRAM.txt into another identity folder.
STRUCTURAL_GUARD: G-UART-R2-OUT-ONLY-BUILD_U3; G-BAN-OTHER-IDENTITY-SHA; G-CALL-VIVADO-BAT
BLAST_RADIUS: UART_R2/build and UART_R2/build_u3 only. Not AGENT_C. Not freeze. Not H. Not gold. Not Ethernet.
VERDICT_BY_LAYER: PASS_IMPLEMENTED program of 17494f2c…. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / TIMING_PASS / MIG_PASS / ASTRA_PASS.
LESSON_TO_SHARE: UART-R2-INDEPENDENT-BIT-NO-CROSS-OVERWRITE-20260917T144400Z
NEXT_DECISIVE_EXPERIMENT: UART hop-1 / Pack24 vs B gold on 17494f2c… only; write jsonl under UART_R2/build_u3. Do not reprogram H.
OWNER_AND_STOP_CONDITION: Stop before writing any path under m4_mig, m4_mig_clear, H_OBS, hold_r2. Do not stamp PROGRAM_PASS.
HANDOFF_STATUS: COMPLETE isolated U3 program. INCOMPLETE_HANDOFF board UART campaign / silicon H19/H20 / Ethernet.
