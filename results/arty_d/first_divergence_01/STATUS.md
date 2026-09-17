# D-PACK-SILICON-FIRST-DIVERGENCE-01

TASK: D-PACK-SILICON-FIRST-DIVERGENCE-01
STATUS: H19 board after H reprogram: i0 ACK+UNSUP with exact 132 B TX; i1-i2 ACK+NAK. Python extra-byte REJECTED. GOAL_AGENT_D NOT_DONE.

RUN_PROVENANCE:
  Frozen copies: D:/FPGA/arty_d/first_divergence_01/FROZEN_20260917T004100Z/
  Identities: D:/FPGA/arty_d/first_divergence_01/FROZEN_IDENTITIES.json
  Host campaign: D:/FPGA/arty_d/m4_mig/uart_pack24_clear_board.py sha256 prefix 515eba9eccb6a6b9
  Host H11 stamp: D:/FPGA/arty_d/first_divergence_01/uart_h18_stamp.py
  TSV pack_abi24_expect.tsv sha256 prefix 9ec497042feb7293
  Vivado 2026.1 part xc7a100tcsg324-1
  H9 installed: D:/FPGA/arty_d/first_divergence_01/H9_JP2_INSTALLED/
  H9 removed: D:/FPGA/arty_d/first_divergence_01/H9_JP2_REMOVED/
  H10: D:/FPGA/arty_d/first_divergence_01/H10_COMPARE.json
  H11: D:/FPGA/arty_d/first_divergence_01/H11_V04/
  H17/H11 XSim: D:/FPGA/arty_d/first_divergence_01/H17_H11_XSIM.json
  H17 stall: D:/FPGA/arty_d/first_divergence_01/H17_STALL_XSIM.json
  H12: D:/FPGA/arty_d/first_divergence_01/H12_CLASS_A_XSIM.json
  H12 MAG/resync: D:/FPGA/arty_d/first_divergence_01/H12_MAG_RESYNC.json
  H12 board: D:/FPGA/arty_d/first_divergence_01/H12_BOARD.json
  H12 board jsonl: D:/FPGA/arty_d/first_divergence_01/H12_BOARD_RESYNC.jsonl sha256 901322c382cbbe328a39cb95e6059adc50e035361a4660c376d806464a2a964c
  H12 MAG-then-CLEAR XSim: D:/FPGA/arty_d/first_divergence_01/xsim_h12_mag_clear/xsim.log sha256 26e51c0d150a72b6652b2a25ca937608ae9166e2ebac2c3387ea32f0913e1503
  H12 NAK-nopad: D:/FPGA/arty_d/first_divergence_01/H12_BOARD_NAK_NOPAD.json
  H12 UNSUP pad0: D:/FPGA/arty_d/first_divergence_01/H12_BOARD_UNSUP_PAD0.json
  H12 24 pad0: D:/FPGA/arty_d/first_divergence_01/H12_BOARD_24_PAD0.json
  H12 A-01 isolate: D:/FPGA/arty_d/first_divergence_01/H12_BOARD_A01.json
  H16 A-01 115200: D:/FPGA/arty_d/first_divergence_01/H16_A01_115200_XSIM.json
  H16 hold-overlap: D:/FPGA/arty_d/first_divergence_01/H16_HOLD_OVERLAP_XSIM.json
  H19 ACK+pad A-01: D:/FPGA/arty_d/first_divergence_01/H19_ACK_PAD_A01_XSIM.json
  H19 board A-01: D:/FPGA/arty_d/first_divergence_01/H19_BOARD_A01.json
  B compare 24/24: D:/FPGA/arty_d/pack_abi24_b_compare/D_PACK_ABI24_B_COMPARE.json

CURRENT_BITSTREAM_ID: cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
PROGRAM: End of startup HIGH 2026-09-17T13:20:58+07 identity H cf62102f… JTAG 210319BE776EA. PROGRAM_PASS=NO.
OWNER_JTAG: allowed (PROGRAM=NO = no PROGRAM_PASS stamp).
JP2_CK_RST: OWNER_REPORTED_REMOVED after installed arm.
SRAM_LEAVE_STATE: H19_BOARD_A01 after i=2 NAK_R02 (not mute). Prior isolate CLEAR n=0 recovered by reprogram.

FAILURE_CLASS_A_STATUS: PRESENT (UNSUP/SEN/MAG 4-byte). H11 i=0 PACK UNSUP; i=2 MAG. H10 V-03 SENTINEL both rates.
FAILURE_CLASS_B_STATUS: pad3-after-NAK is host mute. 24-case pad0 still MUTE at A-02 CLEAR after A-01 ABI NAK (no pad3). H9 installed sticky from S-01. H11 frozen-host mute.
COMMON_ROOT_STATUS: UNKNOWN (H_MULTIROOT still open)

H9_CK_RST: SUPPORTED for CLASS B sticky mute correlation; REJECTED as sole root of CLASS A.
H10_PACED_BURST: PARTIAL_RATE_EFFECT_REJECTED_AS_SOLE_ROOT. GOLD 13/24 burst vs 19/24 paced. V-03 SENTINEL both.
H11_REPEAT_CASE: SAME_CASE_UNSTABLE_CLASS_A_THEN_CLASS_B on V-04.
H12_RX_WORD: PASS_XSIM 1 extra 0x00 before CLEAR → UNSUP 0200075a. extra after BEGIN → MAG 0200015a. pad3 after UNSUP → CLEAR ACK + GOLD.
H12_BOARD: UNSUP pad0 12:23+07 V-04 n=20 GOLD 14 MAG 2 PACK UNSUP 4 mute=0. CLEAR UNSUP then immediate CLEAR ACK x3. jsonl sha256 c20376df1122a46f1f404b8fa68aa1c332cb5e89db4405600cf9cee61e0da4d4. Not PACK_ABI_24_24_PASS.
H13_FIFO_CDC: overflow arm n_drop=0; post CLEAR R_STALE 02000e5a after dest_stall flood. Not FIFO-drop proven.
H13_FIFO_CDC: NOT_RUN
H14_RESET_DOMAIN: RTL table written; not board-proven.
H15_CLEAR_GATE: NOT_RUN
H16_TX_RESPONSE: PASS_XSIM A-01 at 115200 NAK_R02 x2 first_p=BEGIN n_p=33/66 bix=0 fifo=0 tx_rdy=1 POST CLEAR ACK finish 26601335 ns. Silicon isolate UNSUP/MAG/mute NOT in BRAM dualclk at silicon baud without extra byte. Prior 1 Mbps A-01 TB baud gap REJECTED as UNSUP root. n_st_tx=3 for 2 NAKs = HYPOTHESIS extra status after CLEAR, not mute here. log sha256 f187b2262cc9759e3b90c3adfe9bf5cf58e28809176f7fac4ab7cedaaa502fe7.
H16_HOLD_OVERLAP: PASS_XSIM start A-01 at S_ACK hold=1 w_ready=0 still first_p=BEGIN n_drop=0 NAK_R02. clr_hold window << 1 UART word. BEGIN-drop-during-ACK REJECTED at 115200. log sha256 00118871af52a108c4bdc778041b99773cbd23da0c889bb37403944b0c5bef66.
H19_ACK_PAD: PASS_XSIM CLEAR ACK then extra 0x00 then A-01 → PACK 0200075a first_p=80000100 n_p=33 bix=1 reason=07. Token matches silicon A-01 isolate UNSUP. Mechanism: byte-phase shift of BEGIN. log sha256 7ffd4627e216796fdba7a9f0f7ba5147e5be2e440d277576a4e8012c0f4834d6.
H19_BOARD: after reprogram H, exact TX 4 then 132. i=0 ACK+UNSUP 0200075a; i=1,2 ACK+NAK_R02. in_waiting=0. Python extra-byte REJECTED. Host-after-ACK idle 0.15s so software overlap REJECTED. Extra-byte SOURCE still UNKNOWN below Python (FTDI/PHY/FPGA). jsonl sha256 3aa5d56e950b89b6bed64ec221bbe2090d00e56e684891e710a0d17a34f99650. Not PACK_ABI_24_24_PASS.
H17_MIG_DEST: PASS_XSIM BRAM GOLD on complete packs. Stall/incomplete: CLEAR BUSY + sticky S_RX (st=1) + pack MUTE. SENTINEL not produced. BUSY path does not debug_clear (RTL_FACT + PASS_XSIM).
H18_HOST_RAW_STREAM: OFFLINE + H11 stamped jsonl. t_first~0.06s not delayed>1s on CLASS A.

FIRST_DIVERGENCE (XSim CLASS A):
  1 stray UART byte then CLEAR → 0200075a UNSUP (word 52474300). Same token as silicon H11.
  extra 2–3 bytes → MUTE (CLEAR not assembled).
Internal: uart_rx_word bix leftover; clr_take needs exact 44524743.

ROOT_CAUSE_OR_UNKNOWN: extra1 leftover pad0 MUTE / pad3 ACK PASS_XSIM. CLASS A first PACK UNSUP after ACK reproduced by 1 extra byte in XSim (H19) and on board i=0 after program with exact 132 B Python TX. Python-join extra REJECTED. Silicon extra-byte SOURCE UNKNOWN (FTDI/PHY/FPGA). CLASS B sticky mute UNKNOWN (this 3-loop arm did not mute). COMMON_ROOT=UNKNOWN.

NOT_CLAIMED: PACK_ABI_24_24_PASS BOARD_PASS PROGRAM_PASS TIMING_PASS MIG_PASS ASTRA_PASS FE256_PASS FINAL_PASS
NEXT: ILA first FPGA RX byte after CLEAR ACK on first pack after program. FEM persist blocked. No Identity I.
