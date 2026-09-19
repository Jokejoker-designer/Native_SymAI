# U33 leftover probe 20260919T132346Z

PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

Program frozen U33 `ff399e0b` End of startup HIGH, 30s settle, then probe.

Round 0 after CLEAR1 ACK:
- P1 idle 0.15s: n=0 — leftover BEGIN did **not** auto-fire
- P2 dummy `00010001` nwritten=4 begin_n=0: n=0 — leftover BEGIN + dummy did **not** MAG
- P3 V-04 nwritten=208 begin_n=1: MAG `0200015a` n=4

Phase **V04_CONCURRENT**. Extra BEGIN is concurrent with this V-04 send, not sitting after CLEAR.

JSON sha256 `16ddaa3625b8716b32a1976f103566532bc17dc4d3c2b501fe7f0fff9fd655e5`

Note: prior WAIT=0 nwp4p5 first V-04 was GOLD. This first V-04 MAG after dummy+gap. Dummy/gap vs USB packetization still HYPOTHESIS. Not PACK_ABI_24_24_PASS.
