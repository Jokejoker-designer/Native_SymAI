# U33 reopen-COM nwp4p5 20260919T133958Z

PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

Frozen U33 `ff399e0b`. Intended: reopen COM after each GOLD (USB leftover), bulk `send_words` WAIT=0.

Observed: CLEAR1 ACK `c1ea50a5` n=4, then first V-04 **n=0 mute** 12.056 s (`stop=V04_0`). No GOLD, so reopen-after-GOLD did **not** run. Same first-V-04 mute class as exclusive T0. Not MAG `0200015a`. Not 24/24.

REOPEN.json sha256 `fe6482714150ba57e6a856756c8d0a64772f37500f4b16616fc3036c1ff3f07c`
