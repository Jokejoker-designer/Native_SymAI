NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: OWNER-EXCLUSIVE-PROGRAM-IDEAS-TAPCDC-20260920T102700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner converted the work to an idea pile and granted exclusive PROGRAM to AGENT_D until 2026-09-21 00:00 +07. TAP dump p1 is untrusted; leftover MAG is PASS_XSIM CLASS_A at loader p1=BEGIN. TAPCDC re-impl started; bitstream not yet programmed. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: Owner “Chuyển lại thành đống ý cho phép PROGRAM nhé từ giờ tới 12H đêm chỉ có mình bạn dùng board thôi”. Lease until 2026-09-20T17:00:00Z. Mailbox BOARD_LEASE_GRANT to AGENT_E. Impl `95_impl_uart_r2_u33tap_cdc.tcl` from existing post_synth into `build_u33tap_cdc` only.

OBSERVATION:
- FACT: TAP UART vs XSim p0_begin_both=true p1_match=false first_diff byte_i=8.
- FACT: hop_log leftover TB MAG 0200015a p0=BEGIN p1=BEGIN PASS_XSIM; log sha256 564d22e7….
- FACT: programmed TAP bit still d448544f; TAP CDC XDC was rescore-only.
- FACT: exclusive COM12/JTAG holder AGENT_D until midnight +07.
- UNKNOWN: silicon loader p1 after a TAP bit that actually includes TAP CDC constraints.

HYPOTHESES: Dump UART CDC hold scrambled p1/p2. Competing: silicon loader p1 really not BEGIN. Rebuild+recapture is the on/off for dump-path.

HOW_TRACE: Compare script → leftover hop_log XSim → lock lease → start TAPCDC impl (no program until SHA≠d448544f).

EVIDENCE_MATRIX:
- TAP_UART_VS_XSIM.json FACT PASS_IMPLEMENTED compare
- u33obs_leftover_hoplog.log FACT PASS_XSIM
- board_lease.json until 17:00Z FACT
- build_u33tap_cdc impl running INFERENCE until ROUTE_OK

SUCCESS_VS_FAILURE: Idea pile + exclusive lease written. TAPCDC bit not done this export. No Pack24. No overlay.

FIRST_DIVERGENCE: TAP UART p1 vs XSim BEGIN at dump byte 8. Loader hop independently named p1=BEGIN only in XSim hop_log.

DECISIVE_TEST: New TAPCDC bitstream SHA≠d448544f programmed, leftover DUP4 recapture p1 vs 00800001.

ROOT_CAUSE_OR_UNKNOWN: Leftover BEGIN sufficient MAG PASS_XSIM. Silicon dump p1 UNKNOWN. MUTE on TAP not reproduced. PACK_ABI NO.

REUSABLE_DECISION_PROCEDURE: Do not treat TAP dump words as loader beats until byte-aligned to XSim and TAP CDC is in the programmed netlist. Exclusive owner PROGRAM window still forbids overlay H/U33 and Pack24 on TAP.

STRUCTURAL_GUARD: New out dir build_u33tap_cdc. Program Tcl bans H/U33/d448544f. Starter hop_log not a board identity.

BLAST_RADIUS: discriminator docs, leases, mailbox, TAPCDC build dir. Frozen U33/H/freeze DCP untouched.

VERDICT_BY_LAYER: PASS_XSIM leftover CLASS_A loader p1. PASS_IMPLEMENTED TAP byte compare. Not PASS_BOARD for p1. Not TIMING_PASS. Not PROGRAM_PASS. Not PACK_ABI_24_24_PASS. Not BOARD_PASS.

LESSON_TO_SHARE: TAP-DUMP-P0-MATCH-P1-UNTRUSTED-REBUILD-CDC-20260920T102700Z
NEXT_DECISIVE_EXPERIMENT: Finish TAPCDC bit, hash, program OWNER_AUTHORIZED results dir, DUP4 recapture. Then classify dump vs loader. Do not UpdateGoal complete.
OWNER_AND_STOP_CONDITION: AGENT_D exclusive until 00:00+07. Stop Pack24 on TAP. Stop overlay. Goal PACK_ABI remains unproven.
HANDOFF_STATUS: COMPLETE
