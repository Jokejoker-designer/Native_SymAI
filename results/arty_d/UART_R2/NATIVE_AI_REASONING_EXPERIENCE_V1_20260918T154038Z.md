NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / UART_R2_U23_FIRST_ACK_UNKNOWN
RUN_ID: 20260918T154038Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: The remaining UNKNOWN ("first ACK after JTAG/ELA arm never reaches COM") is not a stable U23 silicon/ACK-path law under exclusive COM12. After the other lane released the board, 4/4 exclusive first-CLEAR trials returned ACK a550eac1 with ELA done. E2 n=0 did not reproduce. COM12 contention is FACT. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Bit D:/FPGA/arty_d/UART_R2/build_u23/uart_r2_u23_candidate.bit SHA256 dfea894f1f2942f8587fe91007857792ef32253455aa242e083b7347f95d8a8d. JTAG 210319BE776EA End of startup HIGH each program. UART COM12 115200 FTDI 210319BE776EB. Owner said parallel lane must stop using the board. Campaign u23_campaign.py. U22 frozen. C RTL untouched. Pack24 gold unchanged.

OBSERVATION:
- FACT: E2 2026-09-18T22:26:53+07 p4ela_ack_once after exclusive program: CLEAR1 n=0 dt=3.0569s, ELA armed/triggered=false/done=false, class HOST_N0_ELA_NOT_TRIGGERED. Archived BOARD_E2_ACK_ONCE_N0.json sha256 8400afc09c1a65a2038ec084d50045cf54efc4e34946b15ef64d382d24242e88.
- FACT: E1 22:27:32 uart_once 12s no ELA: CLEAR1 ACK n=4 62ms. BOARD_E1_UART_ONCE.json sha256 038817bccc89e285cf01b84a75f5ce36211c71fd7162ba8d517c9883f80f4fe8.
- FACT: 22:28:41 U23 program OK then p4ela_take_once SerialException COM12 Access Denied. Process 46072 `probe_uart_m1_two_gen.py` cwd goal_m1_twogen held COM12 (terminal 511827).
- FACT: After COM free + owner exclusive: E3 take_once 22:32:19 FIRST_CLEAR_ACK_AND_ELA_DONE. take pulse w_data=44524743 then S_SAMPLE. BOARD_E2_TAKE_ONCE.json sha256 42bc893c3348e48775a8b2a6001e028d6ff1079e5ddc45d689f14c17698dbff4.
- FACT: E2B ack_once 22:35:45 FIRST_CLEAR_ACK_AND_ELA_DONE 60ms. trig_win S_ACK ack_valid=1 mux_valid=1 mux_ready=1 st=5 then S_DROP. BOARD_E2B_ACK_ONCE.json sha256 ba0571008eba6726e565b2ed44cdaf691e28c2a8342d1346747da161c783847c.
- FACT: Exclusive dummy p4ela (open/close then CLEAR) 22:39:16 FIRST_CLEAR_ACK_AND_ELA_DONE. BOARD_BASELINE_P4ELA_EXCL_223916.json sha256 5000c1515cf3e278b9b49b7b67c344c0708c69372180b3a09e240a4c866743cd. Original 22:13 dummy CLEAR1 n=0 not reproduced.
- FACT: E2C ack_once 22:40:38 FIRST_CLEAR_ACK_AND_ELA_DONE. BOARD_E2C_ACK_ONCE.json sha256 1170c17ec9e12b40c11745cad3fd2abb3fcb276e2c6d047bb68f64c9188ed6d4.
- FACT: Exclusive first-CLEAR after user release: 4/4 ACK (take_once, ack_once, dummy p4ela, ack_once). n=0 rate 0/4.
- INFERENCE: "ELA/JTAG arm always mutes first ACK" CONTRADICTED as a silicon law.
- INFERENCE: Observed first-n=0 during this session is explained by COM/JTAG sharing with GOAL_M1_TWOGEN (proven Access Denied) plus one unreproduced E2 singleton.
- UNKNOWN: E2 HOST_N0_ELA_NOT_TRIGGERED (ack_valid never) is a singleton; take-vs-no-take on that run not captured. Low-rate FTDI-after-hw_server miss not disproven, only not reproduced exclusive.
- CONTRADICTED: Missing fabric CLEAR as the general cause of first n=0 (prior take window + E3 take).

HYPOTHESES:
- H-contention (strengthened): Parallel UART on COM12 / JTAG last-writer produces host n=0 or Access Denied. FACT for 22:28. INFERENCE for 22:13 dummy n=0 and E2.
- H-ela-arm-law (weakened to CONTRADICTED as always-true): ELA arm via hw_server before first CLEAR always mutes ACK.
- H-dummy-open (CONTRADICTED as necessary): Dummy COM open/close before CLEAR is required for first n=0. Exclusive dummy ACK.
- H-intermittent-ftdi (UNKNOWN remaining, low prior): rare first-write loss after TAP activity even exclusive.

HOW_TRACE: E2 n=0 → E1 no-ELA ACK → take_once COM denied (twogen) → owner exclusive → take_once ACK → ack_once ACK → dummy p4ela ACK → ack_once ACK.

EVIDENCE_MATRIX:
| claim | class | path |
| COM12 held by twogen probe | FACT | 836908 SerialException; PID 46072 probe_uart_m1_two_gen.py; 511827 |
| exclusive first CLEAR ACK 4/4 | FACT | TAKE_ONCE / E2B / BASELINE_EXCL / E2C json |
| E2 n=0 ack ELA not triggered | FACT | BOARD_E2_ACK_ONCE_N0.json |
| ELA/JTAG always mutes ACK | CONTRADICTED | E2B+E2C+E3 ACK after arm |
| dummy open causes n=0 | CONTRADICTED | BASELINE_P4ELA_EXCL ACK |
| BOARD_PASS | not stamped | PROGRAM_PASS=NO |

SUCCESS_VS_FAILURE:
- Success: exclusive isolation; first ACK after program+ELA reaches COM; S_ACK handshake observed.
- Failure: E2 singleton n=0 unreproduced; original 22:13 first n=0 unreproduced exclusive.

FIRST_DIVERGENCE: Host COM exclusive vs shared. Shared: Access Denied or n=0. Exclusive: ACK 4/4.

DECISIVE_TEST: Already run — exclusive program + first CLEAR with take trigger, ack trigger, and dummy reopen. All ACK. Next only if n=0 returns exclusive.

ROOT_CAUSE_OR_UNKNOWN: Primary class = UART/JTAG board sharing (FACT at 22:28). Silicon first-ACK-mute after ELA arm = not reproduced. E2 singleton remains UNKNOWN at low rate.

REUSABLE_DECISION_PROCEDURE: Before naming UART n=0 as RX/ACK silicon: (1) list COM holders, (2) exclusive program last-writer, (3) one CLEAR no dummy/retry, (4) if ELA: take vs ack_valid separately, (5) archive timestamped JSON so later runs do not overwrite. Do not add a flush overlay for an unreproduced n=0.

STRUCTURAL_GUARD: WATCH PROGRAM.txt is not enough; WATCH COM12 process list. Campaign open_mark retries Access Denied. Unique BOARD_* copies (E2 N0 / E2B / E2C / BASELINE_EXCL). U23 observe identity only. No C/gold/FE256/H overwrite.

BLAST_RADIUS: UART_R2/u23 campaign retry + results JSON copies. U22 frozen. SRAM last-writer U23 dfea894f…. GOAL_M1/M2/t2dump PROGRAM.txt SAME this session. Freeze/H untouched.

VERDICT_BY_LAYER:
- BOARD UART exclusive first CLEAR: PASS_BOARD_OBSERVE ACK 4/4 (not BOARD_PASS)
- ELA S_ACK handshake: PASS_BOARD_OBSERVE (E2B trig_win st=5 ack_valid=1 mux_ready=1)
- E2 n=0: FAIL_BOARD singleton, unreproduced exclusive
- PROGRAM_PASS / PACK_ABI_24_24_PASS / M1_PASS: NO

LESSON_TO_SHARE: UART-FIRST-N0-COM-CONTENTION-NOT-ELA-ARM-LAW
NEXT_DECISIVE_EXPERIMENT: Exclusive Pack24 CLEAR-V04 on a frozen product/observe identity only if COM lease holds. Do not new flush overlay for E2 singleton. If first n=0 returns exclusive, then uart_once_1s vs ELA+12s.
OWNER_AND_STOP_CONDITION: AGENT_D. No Pack24 this run. No M2_STARTING_POINT. No PASS self-stamp. Stop after UNKNOWN class named.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
