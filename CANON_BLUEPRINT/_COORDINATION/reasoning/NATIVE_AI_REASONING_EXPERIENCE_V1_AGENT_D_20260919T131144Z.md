NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART-R2-U33-REPROG-NWP4P5-20260919T131144Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT FAIL_BOARD — after owner re-plug, frozen U33 `ff399e0b` programmed (blank SRAM, End of startup HIGH). 12s-settle first V-04 mute n=0. Extra 30s then nwp4p5: 4 GOLD then p5 r2 MAG `0200015a`. Host TX begin_n=1 every V-04. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay. No U34.
RUN_PROVENANCE: bit sha256 ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350. PROGRAM.txt sha256 81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505. JTAG 210319BE776EA. campaign sha256 e9cec162b107f8df38206bc2b99e3b7cb0de2c29290a971d4940bb4a6e783927. T0 BOARD_BASELINE sha256 eca5b720911d78fa8285fd66baeb8359459e2b9f2c4da3b2fdfc6f63a1449ffd. T1 CLEAR_V04_24.json sha256 4d2317ef20913f0d35be2889dfa3df00e92e77af4d368a679db0dec9a9120b6f. OUT PACK24_U33_REPROG. Frozen PACK24_U33 json not overwritten.
OBSERVATION:
  FACT — pre-program DONE=0. End of startup HIGH 20:08:46+07.
  FACT — T0 CLEAR1 ACK then V04_0 n=0 (UART_TIMEOUT 12s).
  FACT — T1 CLEAR1 ACK Phase4 GOLD; r0 GOLD; r1 n=0 reopen GOLD; r2 MAG 0200015a n=4.
  FACT — every TX_V04 nwords=52 begin_n=1 w0=00800001 w1=3149414e.
HYPOTHESES:
  H_PYTHON_DUP_BEGIN CONTRADICTED.
  H_LEFTOVER_EXACT_BEGIN_MAG CONFIRMED sufficient (prior PASS_XSIM inject). Board extra-BEGIN source still UNKNOWN.
  H_FTDI_4BYTE_DUP HYPOTHESIS.
  H_DUT_AUTOGENOUS_BEGIN UNKNOWN (BRAM phantom CONTRADICTED).
  H_COLDPLUG_12S_FIRST_GOLD CONTRADICTED.
HOW_TRACE: Owner reserved/plugged board. Exclusive program frozen U33. Kill hw_server. First campaign mute. No reprogram. +30s settle. nwp4p5 MAG r2. Host payload BEGIN count logged.
EVIDENCE_MATRIX: PASS_IMPLEMENTED program. FAIL_BOARD MAG r2. Host begin_n=1. Prior PASS_XSIM leftover inject / mig0 five GOLD / 115200 five GOLD.
SUCCESS_VS_FAILURE: SUCCESS_ARTIFACT program End of startup HIGH + T1 Phase4 GOLD. FAILURE_ARTIFACT T1 p5 r2 MAG; T0 first GOLD mute.
FIRST_DIVERGENCE: T1 LAST_EQUIVALENT=p5 V-04 r1 GOLD. FIRST_DIVERGENCE=p5 V-04 r2 MAG. Prior exclusive FIRST_DIVERGENCE was r3.
DECISIVE_TEST: MAG with host begin_n=1 vs leftover inject TB (p0=p1=BEGIN). Extra BEGIN not in Python mem.
ROOT_CAUSE_OR_UNKNOWN: Extra 00800001 between Python write and pack_loader hw0 after OP_BEGIN. Path FTDI|uart_rx|FIFO|CDC|DUT UNKNOWN. Not 5th dest commit.
REUSABLE_DECISION_PROCEDURE: After cold-plug, do not score first V-04 n=0 as MAG. Log host begin_n. Do not overlay DUT from MAG while host payload has one BEGIN unless wire capture shows a second 00800001 or owner authorizes a new identity.
STRUCTURAL_GUARD: Freeze U33. No qsc/UART/dest_accept/pack_loader overlay. No U34. PROGRAM=NO for any other bit.
BLAST_RADIUS: UART_R2/results/PACK24_U33_REPROG + campaign OUT path. Product RTL untouched. Frozen PACK24_U33 FAIL json kept. Freeze DCPs / identity H untouched.
VERDICT_BY_LAYER: PASS_IMPLEMENTED U33 program. FAIL_BOARD MAG. Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / MIG_PASS.
LESSON_TO_SHARE: U33-BOARD-MAG-HOST-BEGIN-N1
NEXT_DECISIVE_EXPERIMENT: Capture leftover 00800001 on the wire (FTDI/host tap) without DUT overlay. PROGRAM=NO until owner.
OWNER_AND_STOP_CONDITION: AGENT_D. No overlay/new identity/PASS. Board still reserved; SRAM holds U33 until power loss.
HANDOFF_STATUS: COMPLETE
