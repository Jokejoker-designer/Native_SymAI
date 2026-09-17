NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-OPEN-TRANSPORT-CDC-MIG-ARCHITECTURE-AUDIT-R1
RUN_ID: 20260917T064130Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Custom UART/FIFO/CDC/reset/MIG-mux RTL must not be replaced
  unless a mapped failure class is shown. Xilinx IP is not automatically better.
  Claim ceiling: PACK_ABI_24_24_PASS=NO BOARD_PASS=NO FEM_PERSIST_PASS=NO
  CURRENT_SILICON_EXTRA_BYTE_SOURCE=UNKNOWN.
RUN_PROVENANCE:
  Identity H DCP D:/FPGA/arty_d/m4_mig_clear/post_route_clear.dcp
    sha256 beab0263e094dbf2e7bdebfaffb120d1cdc379492b1cc68b82c851183c6e17a9
  Bit cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  Top 382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40
  Vivado 2026.1 batch Tcl 35_static_diag_m4_mig_clear.tcl
    STATIC_DIAG_DONE 2026-09-17T13:41:30+07
  Reports D:/FPGA/arty_d/AUDIT_TRANSPORT_CDC_MIG_R1/STATIC_IMPLEMENTATION_DIAGNOSTICS/
  Audit D:/FPGA/arty_d/AUDIT_TRANSPORT_CDC_MIG_R1/D_OPEN_TRANSPORT_CDC_MIG_ARCHITECTURE_AUDIT_R1.md
  PRODUCT_RTL_CHANGED=NO PROGRAM=NO NEW_IDENTITY=NO
OBSERVATION:
  FACT — user sketch placed uart_fe256_host after word_cdc32. Live top and H DCP
    place u_qhost on clk100 FIFO read; u_cdc is clk100→ui_clk after the query steer.
  FACT — DCP cell u_cdc REF_NAME=word_cdc32__xdcDup__1; u_cdc_tx=word_cdc32;
    u_rfifo=word_fifo32; u_rx=uart_rx_word; u_mig/ui_clk clock=clk_pll_i period=12 ns.
  FACT — u_mig/app_addr has 28 pins [0]..[27]. Not truncated in netlist.
  FACT — word_fifo32 is same-clock LUTRAM DEPTH=128. Not CDC.
  FACT — word_cdc32 is toggle+2FF+hold, one word in flight, max_delay 8 ns.
    report_cdc sys_clk_pin↔clk_pll_i Safely Timed, 0 unsafe, CDC-15 on hold bus.
  FACT — routed WNS +0.497 WHS +0.014 TNS=THS=0. Constraints met.
  FACT — report_cdc Critical is input-port-clock→sys_clk_pin False Path (ck_rst class).
  FACT — H19 XSim extra 0x00 after ACK → bix=1 → first_p=80000100 → 0200075a PASS_XSIM.
  FACT — H19 board exact 132 B; Python extra REJECTED; SOURCE UNKNOWN.
  FACT — uart_rx_word STOP does not check stop-bit high; bix not cleared on S_ACK/S_DROP.
  FACT — query collects 8 words then walk CRC16. Pack opcode has no CRC.
  FACT — fem_on_mig ing_valid=0; mux pack-wins exclusive grant; ui_busy=st!=IDLE.
STATIC_EVIDENCE:
  timing_summary.rpt sha16 7af7081d0da0b70a
  cdc.rpt sha16 b82058c9e45bce36
  cdc_details.rpt sha16 9b97ad663dfce5c5
  clock_interaction.rpt sha16 04c4c17ce6951917
  high_fanout.rpt sha16 5d1f44f985ba879e
  netlist_probe.txt sha16 24f77f57b380f201
RUNTIME_EVIDENCE:
  Prior H11/H19 only. This run did not program and did not capture ILA.
  FIRST_DIVERGENCE still OPEN on silicon extra-byte source.
HYPOTHESES:
  H_UART_IP_IS_WRONG: custom uart_rx_word is defective vs Xilinx UART IP.
    Status: NOT supported as extra-byte generator. STOP does not mint 0x00.
  H_CDC_CORRUPTS_WORDS: word_cdc32 scrambles Pack words on silicon.
    Status: NOT supported by H19 (failure before FIFO) nor by CDC unsafe=0 on that pair.
  H_XPM_FIFO_ASYNC_FIXES_UNSUP: one async FIFO replaces fifo+cdc and fixes silicon.
    Status: REJECTED as extra-byte fix; also illegal vs query-on-clk100 split.
  H_CLEAR_ACK_WINDOW_KEEPS_BIX: stray byte during S_ACK/S_DROP shifts phase.
    Status: SUPPORTED as containment hole (RTL_FACT + H19 mechanism). Not source.
  H_MUX_CROSSES_PACK_FEM: mux mixes app_en vs wdf.
    Status: NOT evidenced; FEM idle; grant held on ui_busy.
  H_APP_ADDR_TRUNCATED: schematic [26:0] loses a bit.
    Status: CONTRADICTED for MIG port (28 pins present). Unused MSB possible.
HOW_TRACE:
  task A–Z
  → live top + uart_rx_word/fifo/cdc/clear/mux/mig_ui32/XDC
  → generated mig0 ADDR_WIDTH=28
  → open_checkpoint H DCP; report_* suite
  → classify XPM/AXIS against actual clocks and query split
  → no RTL change
EVIDENCE_MATRIX:
  LAYER | RESULT
  RTL_FACT | hierarchy, bix, flush, handshake, mux grant, query 8-word+CRC
  PASS_IMPLEMENTED | WNS/WHS met; 28-bit app_addr; u_cdc xdcDup; clocks
  CDC/CONSTRAINT | pack word path max_delay met, 0 unsafe; ck_rst Critical bucket
  PASS_XSIM | H19 extra-byte→UNSUP mechanism (prior)
  PASS_BOARD | H19 exact-TX isolate only; SOURCE UNKNOWN
  CONTRADICTED | “fifo+cdc is one CDC”; “host after CDC”; “app_addr truncated”
SUCCESS_VS_FAILURE:
  Success of this audit: boundaries mapped; IP candidates scored per failure class;
    no premature redesign.
  Failure vs GOAL_AGENT_D: Pack silicon still not classifiable; FEM persist blocked.
FIRST_DIVERGENCE:
  Runtime extra byte still unmeasured on FPGA RX. Static reports cannot locate it.
DECISIVE_TEST:
  ILA-A: w_valid, byte/sh, bix, word_data, clr_take. Not MIG. Owner auth for new identity.
ROOT_CAUSE_OR_UNKNOWN:
  UNKNOWN for silicon extra-byte source.
  Named for UNSUP-given-extra-byte (bix shift) at PASS_XSIM.
REJECTED_HYPOTHESES:
  Replace custom RTL because Xilinx IP exists.
  XPM_FIFO_ASYNC as universal fix.
  report_cdc Critical ⇒ word_cdc32 protocol fail.
  Clean timing ⇒ UART protocol correct.
ARCHITECTURE_RISK:
  CLEAR success flush does not cover S_ACK/S_DROP/S_IDLE.
  Dual independent CDC resets can theoretically duplicate; not H19 cause.
  High-fanout rst_loc / rst100_pack_n is CLEAR by design.
STANDARD_IP_LESSON:
  Match IP to the actual crossing and traffic. Handshake IP fits word_cdc32
  but does not see bytes. Async FIFO fits clk100→ui_clk but cannot eat the
  clk100 query tap. Sync-rst IP fits ck_rst release, not bix.
GENERAL_RULE:
  Score each IP with PREVENTS/DETECTS/CONTAINS/NOT_ADDRESS against the named
  failure class. Do not promote vendor primitives from report_cdc nag text.
DECISION_PROCEDURE:
  1. Map clocks from implemented netlist, not names.
  2. Locate the first block that could insert the observed extra byte.
  3. If that block is before FIFO, do not replace FIFO/CDC/MIG.
  4. Keep the silicon identity until ILA names the byte.
  5. Only then consider CONTAIN vs PREVENT changes with OWNER_AUTH.
STRUCTURAL_GUARD:
  G-TRANSPORT-AUDIT-R1-NO-PREMATURE-XPM
  PRODUCT_RTL_CHANGE=NO until extra-byte SOURCE named or owner overrides.
BLAST_RADIUS:
  Evidence/docs/Tcl/reports only. Identity H bit/DCP/C RTL/gold untouched.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED static timing met (not TIMING_PASS self-stamp)
  PASS_XSIM H19 mechanism only
  NOT PASS_BOARD / PACK_ABI_24_24_PASS / FEM_PERSIST_PASS
LESSON_TO_SHARE: D-TRANSPORT-CDC-MIG-AUDIT-R1-20260917T064130Z
NEXT_DECISIVE_EXPERIMENT: ILA-A on identity H (owner-authorized new debug identity)
OWNER_AND_STOP_CONDITION:
  AGENT_D. Stop RTL redesign. Stop if owner declines ILA and still forbids
  new identity. FEM persist remains blocked.
HANDOFF_STATUS: COMPLETE
