# Multi-record pack XSim

LANGUAGE=EN
Status: `MULTI_RECORD_PACK_XSIM_CANDIDATE=SUPPORTED`
This is a new identity. It does not modify or rerun `90220cb5`.

Log: `D:/FPGA/arty_d/UART_R2/pack_nrec/xsim/pack_nrec_xsim.log`
sha256 `b4c6c822d3024bf9cb1efa526f230f9377e463af8a40e4426077332e70249e3f`
finish 11475 ns

OLD PROVEN BOUNDARY: `90220cb5` single-record pack generation visibility. FROZEN.
NEW OPEN BOUNDARY: one committed generation holds two subject records in the same runtime window.
NOT IN THIS BATCH: generated MIG, board, bitstream.

One pack, generation 1, region 0 subject `0x00010100` at byte 0, region 1 subject `0x00010101` at byte 64. Content id is `CONTENT_NS`. The query subject selects the record.

```text
UNCOMMITTED root=ffffffff no descriptor
COMMIT root=1 writes=24
S1 spear=025bb7b4…99bc command c001 primitive 0
S2 spear=f2a071fe…9421 command c002 primitive 1
UNKNOWN subject no descriptor
STALE reason=0x0E root stays 1 writes stay 24
S1_HELD spear A command c003 primitive 0
```

`theta`, `legal_mask`, and `REF_G2 -> feature 2` stay policy substitutes.

```text
BOARD_PASS=NO PROGRAM_PASS=NO TIMING_PASS=NO MIG_PASS=NO PACK_ABI_24_24_PASS=NO ASTRA_PASS=NO
```

Next gate is an independent audit. No board until that audit says the new cut is worth silicon.

## Independent audit

Relayed by the owner. C did not write a freeze line and did not write a claim-ceiling line. D reads the block as supporting the XSim ceiling already stated above, and as refusing a board build.

```text
SUBJECT_SELECTS_COMMITTED_RECORD: YES
UNKNOWN_SUBJECT_MISS: YES
STALE_DOES_NOT_MOVE_ROOT: YES
OLD_CHECKPOINT_MODIFIED: NO
CONTRADICTION_FOUND: NO
RECOMMEND_BOARD_BUILD: NO
```

`90220cb5` stays frozen. This XSim is not rerun to manufacture a board identity. Generated MIG remains the next unopened product boundary.
