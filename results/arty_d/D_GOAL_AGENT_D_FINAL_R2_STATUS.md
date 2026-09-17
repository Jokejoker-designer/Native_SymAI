# GOAL_AGENT_D FINAL R2 — evidence vs requirement

Updated: 2026-09-17T13:22+07:00
PROGRAM_PASS=NO. BOARD_PASS=NO. PACK_ABI_24_24_PASS=NO. TIMING_PASS=NO. FEM_PERSIST_PASS=NO. FINAL_PASS=NO.
GOAL not complete. B owns ABI/gold. No Identity I.

ck_rst FPGA pin = C2 (`arty_a7_mig.xdc`). JP2/CK_RST jumper H9 = OWNER_REPORTED_REMOVED.

| ID | Requirement | Evidence now | Verdict |
|---|---|---|---|
| D-01 BRAM dest | synthesizable dest | `mig_ui_bram.sv` + Pack DUT XSim 24/24 dest-complete | CANDIDATE. Not MIG_PASS. |
| D-02 timing RCA | OOC/route numbers | M4+mig WNS+0.233 candidate; H route WNS+0.497 | Not TIMING_PASS. |
| D-03 Pack/ABI-24 XSim | PACK_ABI24_XSIM_PASS only | B `tb_pack_abi24_xsim_compare` 24/24 finish 15805 ns log sha256 21dae23d… (word DUT, not UART/board). MIG-DUT 24/24 dest-complete earlier. | PASS_XSIM CANDIDATE. PACK_ABI_24_24_PASS=NO. |
| D-04 FE256 bind B comparator | no oracle import | FE256 R1 freeze; COMMON_RUNTIME_FE256=NOT_RUN | CANDIDATE. Not FE256_PASS. |
| D-05 C SPEAR/Q*/FEM | bind, no C RTL edit | C RTL hashes frozen; FEM persist blocked on Pack class | FEM persist NOT_STARTED. |
| D-06 §30/§33 | after M1 gates | §30/§33 hashes in AGENTS; silicon Pack unclassified | NOT_MET. |
| Testable Arty | Pack 24 board classified | H19 board after H reprogram: i0 ACK+UNSUP with exact 132 B TX; i1-i2 NAK. Python extra REJECTED. CLASS B mute not in this 3-loop. | NOT_MET. |

First-divergence (D-PACK-SILICON-FIRST-DIVERGENCE-01): H9 A/B + H10 + H11 UART COMPLETE; H17/H11 PASS_XSIM BRAM; ILA not synthesized.
H9_STATUS=SUPPORTED for CLASS B sticky mute correlation; REJECTED as sole root of CLASS A.
H10_STATUS=PARTIAL_RATE_EFFECT_REJECTED_AS_SOLE_ROOT.
H11 silicon V-04: ACK→UNSUP→GOLD→MAG→GOLD→CLEAR UNSUP→CLEAR n=0.
H11_XSIM 115200: 2/2 GOLD first_p=BEGIN n_cmd_fifo=0. Silicon UNSUP not in BRAM dualclk.
H17 BRAM complete packs: V-03 twice GOLD; V-01→V-02→V-03 GOLD.
H17 stall/incomplete pack PASS_XSIM: CLEAR BUSY `c1ea50b5`, loader `S_RX` st=1 sticky, pack MUTE; idle dest-stall still ACK. BUSY path does not debug_clear.
H12 PASS_XSIM: 1 extra 0x00 then CLEAR → UNSUP `0200075a` (same token as silicon H11). extra 2–3 → MUTE.
H12 MAG/resync PASS_XSIM: stray then PACK → UNSUP; extra byte after BEGIN → MAG `0200015a`; pad3 after UNSUP then CLEAR ACK + V-04 GOLD.
H12 A-01 isolate: XSim 6x NAK_R02 then CLEAR ACK. Board UNSUP, NAK_R02, MAG, NAK_R02 x2, CLEAR n=0 at i=5. CLASS B after A-01 is silicon-only, not 24-prefix leftover.
H16 A-01 115200 XSim: NAK_R02 x2, POST ACK, first_p=BEGIN, dest BRAM not mig0. Clean 115200 harness is not silicon UNSUP.
H16 hold-overlap: S_ACK hold=1 still BEGIN/NAK; BEGIN-drop-during-ACK REJECTED.
H19 PASS_XSIM: extra 0x00 after CLEAR ACK then A-01 → `0200075a` first_p=`80000100`.
H19 BOARD: identity H reprogram End of startup HIGH; exact TX 4+132; i0 UNSUP i1-i2 NAK; Python extra-byte REJECTED; idle 0.15s after ACK. Source below Python UNKNOWN.
B word comparator 24/24 PASS_XSIM 15805 ns; not UART; not PACK_ABI_24_24_PASS.
COMMON_ROOT=UNKNOWN. CLASS A first-after-program UNSUP remains. RTL_CHANGE_AUTH_REQUIRED=NO.
FEM persist still blocked. No Identity I. Frozen campaign host not edited. GOAL PROGRAM=NO = no PROGRAM_PASS stamp, not a JTAG ban.
