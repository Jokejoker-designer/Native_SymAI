# H9 JP2/CK_RST — both arms

HYPOTHESIS: JP2 CK_RST installed lets FT2232 participate in reset and changes MAG/UNS/MUTE vs removed.
CONTROL: Identity H `cf62102f`, host `uart_pack24_clear_board.py`, 115200, `--mode clear --rounds 2`.
SINGLE_CHANGED_VARIABLE: JP2 installed vs removed. No RTL.
EXPECTED_IF_TRUE: MUTE/sticky post-CLEAR or MAG/UNS counts differ.
EXPECTED_IF_FALSE: same classes both ways.
MEASURED_RESULT:
  INSTALLED: post-program ACK; pack_ok=0/3; first campaign CLEAR 0200075a; sticky NO_BYTE from r0 S-01; post-probe n=0.
  REMOVED (owner 2026-09-17): post-program ACK; pack_ok=16/21; first WRONG V-02 CLEAR 0200075a; intermittent NO_BYTE; CLEAR_BUSY appears; post-probe BUSY c1ea50b5 not n=0.
FIRST_DIVERGENCE: CLASS B sticky n=0 (installed) vs responding BUSY/ACK mix (removed). CLASS A (UNSUP/SEN/MAG) remains on both.
NEXT_ACTION: H10 paced vs burst with jumper remaining REMOVED. No Identity I.
STOP_CONDITION: H9 A/B logged. Done.

JP2_INSTALLED_RESULT=pack_ok=0/3; sticky MUTE S-01; post n=0
JP2_REMOVED_RESULT=pack_ok=16/21; post BUSY c1ea50b5; NO_BYTE=20 intermittent
H9_STATUS=SUPPORTED for CLASS B sticky mute correlation; REJECTED as sole root of CLASS A

FPGA `ck_rst` = PACKAGE_PIN C2.
