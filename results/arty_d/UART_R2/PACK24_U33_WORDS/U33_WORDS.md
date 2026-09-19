# U33 word-flush nwp4p5 20260919T132917Z

PACK_ABI_24_24_PASS=NO. No overlay.

52×4-byte `write+flush` (not 208-byte bulk). Phase4 GOLD, r0 GOLD, r1 n=0-retry GOLD, r2 NAK **`0200035a` R_SCHEMA** (not board MAG `0200015a` R_BAD_MAGIC).

Same token as XSim DUP16 (64B prefix). Word-flush does **not** close Pack24; it changes the NAK class.

WORDS.json sha256 `f5239ecc8bd360f58c5fe41f8fb19e242845cb543ee3f9a32b6e4fc521dd6b8a`
