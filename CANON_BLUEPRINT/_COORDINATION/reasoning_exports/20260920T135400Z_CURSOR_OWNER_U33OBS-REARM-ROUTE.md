NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK59-U33OBS-REARM-ROUTE / 20260920T135400Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Unique OBS rearm ROUTE_DONE WNS=-1.373 (1 endpoint debug_clear→clr100) WHS=+0.010. TIMING_PASS=NO. New bit NOT_BUILT. Silicon still bd541f95. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. This watch did not program and did not resume Vivado.
RUN_PROVENANCE: Watch last_github_sha f2e15e3. Parent jsonl 4837497. Disk ROUTE_DONE 13:54:42Z. Overlay NO. Unique dir. 95_impl TAP_CDC_XDC_AT_IMPL=YES.

OBSERVATION:
  FACT — BUILD.txt ROUTE_DONE TIMING_PASS=NO READY_TO_PROGRAM=NO sha256 9a9e930c…
  FACT — timing_route.rpt WNS=-1.373 TNS=-1.373 1 fail WHS=+0.010 constraints not met
  FACT — fail path u_uiclr/debug_clear_reg/C clk_pll_i -> clr100_0_reg/D sys_clk_pin
  FACT — post_route.dcp sha256 cd51e9e4…; no .bit in out dir
  FACT — old OBS 71b9198f rgoff 251eafa9 steer bd541f95 files intact
  FACT — this watch did not invoke impl/bit/program
  INFERENCE — rearm CLEAR pulse CDC is the setup fail
  UNKNOWN — unique bitstream SHA; board four-AND after CLEAR on new identity

HYPOTHESES: Route is not legal at 100 MHz until this CDC is constrained or staged. Do not BIT_OK as TIMING_PASS.

HOW_TRACE: Hash BUILD/DCP. Read timing_route WNS. Copy hashes not DCP. Do not nạp. Do not run 96_bit.

EVIDENCE_MATRIX: PASS_IMPLEMENTED route checkpoint. FAIL_TIMING 1 endpoint. Not TIMING_PASS. Not PROGRAM_PASS. Not PACK_ABI.

SUCCESS_VS_FAILURE: Unique dir routed. Setup not met. Bit not built.

FIRST_DIVERGENCE: f2e15e3 SYNTH WNS=-1.227 unplaced vs ROUTE WNS=-1.373 1 endpoint.

DECISIVE_TEST: report_timing_summary post_route.dcp WNS sign.

ROOT_CAUSE_OR_UNKNOWN: debug_clear→clr100 setup (FACT path). CDC fix UNKNOWN until next unique impl.

REUSABLE_DECISION_PROCEDURE: ROUTE_DONE + TIMING_PASS=NO is not BIT legal. Unique dir. Do not overlay steer bit. Watch does not bitstream failing WNS as PASS.

STRUCTURAL_GUARD: BUILD TIMING_PASS=NO READY_TO_PROGRAM=NO; 96_bit still allowed by tcl but watch does not run it; PROGRAM_PASS=NO.

BLAST_RADIUS: New build dir only. Frozen identities and prior unique bits untouched. SRAM unchanged.

VERDICT_BY_LAYER: PASS_IMPLEMENTED route DCP. FAIL_TIMING. Not PACK_ABI / PROGRAM_PASS / BOARD_PASS / TIMING_PASS.

LESSON_TO_SHARE: REARM-ROUTE-WNS-NEG-DEBUG-CLEAR-CDC-NOT-TIMING-PASS-20260920T135400Z
NEXT_DECISIVE_EXPERIMENT: Do not stamp TIMING_PASS. Watch does not nạp. Owner may fix CDC then unique impl; do not overlay bd541f95.

OWNER_AND_STOP_CONDITION: CURSOR_OWNER github_audit. Stop TIMING_PASS / PACK_ABI / PROGRAM_PASS / BOARD_PASS stamps. Stop if user says dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
