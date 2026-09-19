# U33 DUP4 vs DUP16 — PASS_XSIM class, not PACK_ABI

PACK_ABI_24_24_PASS=NO. PROGRAM=NO. No DUT overlay.

TB `tb_u33_dup_begin.sv` sha256 `842850c9615eac026b4cd153595609f75a920a4a09582b602a20212f47f1fa4a`
cells `u33_dup_begin.log` sha256 `e97b02e151cddf74207e6bd53605bff62e25aef1d94990520bbe9f6056aa8601`
xsim `xsim_u33dup.log` sha256 `2296ae6a5b1f59e1b5b0ca7ea259b99cd3fddd17ce2e2c680ad81a16af0bf364`
`$finish` 7978465 ns (LATE cell aborted on CLEAR BUSY).

| Cell | Token | p0 / p1 | Class |
|---|---|---|---|
| DUP4 extra `00800001` then V-04 | `0200015a` rsn=01 R_BAD_MAGIC | BEGIN / BEGIN | **same as board MAG** |
| DUP16 extra first 16 words (64B) then V-04 | `0200035a` rsn=03 R_SCHEMA | BEGIN / MAGIC | **not board MAG** |
| LATE extra BEGIN after GOLD then CLEAR | CLEAR `c1ea50b5` BUSY | — | **not MAG**; leftover-before-CLEAR is BUSY |

64-byte USB-packet retry of the V-04 prefix is CONTRADICTED as the board MAG token.
4-byte BEGIN dup after CLEAR IDLE remains the only MAG `0200015a` match.
Late BEGIN after GOLD would make the next CLEAR BUSY, not ACK-then-MAG.

## Host TX diagnostic (not Pack24)

`u33_hosttx.py` after MAG leftover: CLEAR n=0, retry ACK, V-04 n=0.
`ser.write` V-04 **nwritten=208** begin_n=1. Python issued one 208-byte write.
JSON sha256 `890f00a3f39eda3801e57c30c030d3ebe4310b151919c8c446c841a1fd8e922a`.
Mute after MAG is not a leftover-BEGIN capture. Not PACK_ABI_24_24_PASS.
