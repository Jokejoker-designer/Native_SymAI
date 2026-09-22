# Semantic SPEAR rank XSim

LANGUAGE=EN
RUN_ID: 20260922T004900Z
RESULT: PASS_XSIM
FINISH: 3735 ns
LOG_SHA256: 52c9eff581976a97858ef3a245ba7af59de6c3f0259e6a0cb18d612191bb0126

Descriptors fixed. Query fixed (namespace 0x0011, generation 0x0007, relation 3). m_fem=0 on both. FEM state held life=3 ft=2 compacted=1.

```text
OFF1  A base=127 delta=0 final=127   B base=0 delta=0   final=0    rank A > B
ON1   A base=127 delta=0 final=127   B base=0 delta=256 final=256  rank B > A
OFF2  A base=127 delta=0 final=127   B base=0 delta=0   final=0    rank A > B
ON2   A base=127 delta=0 final=127   B base=0 delta=256 final=256  rank B > A
```

fem_delta is added only to the unique lower base score, and only while influence is on. Q* and FEM persist RTL were not edited. No bitstream.

```text
BOARD_PASS=NO
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```
