# FEM persist XSim + restore ead830ae (2026-09-21)

Watch did **not** program. Unique `fem_persist` bitgen was **still running** at this publish; do not invent BIT_OK. C `fem_lifecycle.v` sha256 `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` unedited.

LANGUAGE=EN. Not a product PASS stamp.

```text
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
PACK_ABI_24_24_PASS = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
MIG_PASS = NO
TIMING_PASS = NO
```

| Artifact | SHA256 |
|---|---|
| iso XSim log 7215 ns | `c260ce51194c1433d78e793216b513ca6acc03aaf58da48fe2dc106b572b5855` |
| UART XSim log 3057395 ns | `a25d20176789f2861f4df7b210d3366bf5ea361d06e164d7372dad40f8c9c78a` |
| iso result json | `ff65b0377abc8dac55509bc74f425b4f2ce7f8d3625824eb40d09abffbd9c3f5` |
| UART result json | `bb4699a05c8e5a279471fc0b35e1a5c677b2c49e6d61ac0b78215db0df051a91` |
| restore PROGRAM.txt | `058a7fc56c537d398c7bf8501b220a14c17be78cc697926f30f480cf9289d5e8` |
| restore program.log | `15086e86b48588e1076d1cc7c90d7c95410f586f46e50fed38666ef8008b5374` |
| FEM_BASE_OBSERVE.json | `0dfe85858a4ca9838d9de21aa91f6916a138e03c7bf8dde35b60d9860a575b4e` |

## FACT — PASS_XSIM only

Isolated: compact COMMIT `c0117ed0` held across `rst_n`; rec restores life/key/ft. UART TB: FING/FCMP/DEST_READ/FRST/FREC. FRST is FEM fabric reset, not red board RESET / MIG recalib.

## FACT — silicon on restored ead830ae is not persist

USB unplug: JTAG DONE=0, UART n=0. Restore quoted `ead830ae…` EOS HIGH 20:38+07. CLEAR ACK. FEM_BASE DEST_READ is DRAM garbage, COMMIT != `c0117ed0`. dest TAP stimulus still tied 0.

Do not overwrite dest-TAP / CT1 files. Next persist identity needs a **new SHA** and quoted PROGRAM=YES.
