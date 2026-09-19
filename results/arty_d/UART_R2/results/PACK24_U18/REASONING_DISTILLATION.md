# REASONING_DISTILLATION U18

OBSERVATION: U18 S_DROP RX/FIFO flush destroys a complete 0-word parked during CLEAR ACK (PASS_XSIM: U17 first_p=0 UNSUP, U18 first_p=BEGIN GOLD). Board improved from U17 (first Phase5 V-04 UNSUP) to three extra GOLD then CLEAR r3 UNSUP 0200075a.

EXPECTED_BEHAVIOR: After ACK visible, next command may start. CLEAR 44524743 must be taken at 100 MHz. Pack_loader must not see unlocked junk.

HYPOTHESIS: Unlocked FIFO/CDC word after GOLD (not the ACK-parked class) reaches pack_loader; CLEAR is then not exact CMD.

EVIDENCE: PASS_XSIM parked-ACK class closed. Board r3 CLEAR returns pack R_UNSUP. 32x bram harness 32/32. LiteX/NSL not used.

FIRST_DIVERGENCE: U17 V-04_1 UNSUP vs U18 V-04_0..2 GOLD then CLEAR_3 UNSUP.

DECISIVE_TEST: Inject 0 during ACK (done). Next: inject 0 after GOLD then CLEAR.

ROOT_CAUSE_OR_UNKNOWN: ACK-parked 0 CLOSED_FOR_XSIM. Board r3 CLEAR UNSUP UNKNOWN / HYPOTHESIS unlocked post-GOLD word.

GENERAL_RULE: ACTIVE_UART_FRAME must not be aborted by flush. ACK handshake must not flush. Post-ACK S_DROP may destroy parked RX. Unlocked words must not enter pack_loader. ACK_VISIBLE → NEXT_COMMAND_MAY_START.

DECISION_PROCEDURE: New functional fix → new identity. Do not patch U18.

STRUCTURAL_GUARD: cdc_rst ends at S_DROP. flush may include S_DROP. pack_lock or equivalent must gate CDC.

TRANSFER_TO_NEXT_STAGE: U19 CDC gate: steer_pack = pack_lock || pack_op; discard otherwise. Keep U18 CLEAR flush. Do not start M2.
