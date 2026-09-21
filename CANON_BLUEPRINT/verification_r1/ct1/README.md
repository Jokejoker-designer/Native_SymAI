# CT1-01..05 isolated XSim

**Status:** `PASS_XSIM` on isolated `pack_runtime_dut` + `mig_ui_bram` stand-in.  
**Not** `CT1_BOARD_PASS`. **Not** `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. **Not** `PROGRAM_PASS`.  
PROGRAM: owner YES 2026-09-21 09:52+07; **this run did not nạp**. No CT1 bitstream exists.

`$finish` 4885 ns. JSON sha256 `372ea910653cf608024833c20b0c2b8ce190554c00cd790f265bab7721326a3c`.  
Log sha256 `3d07636590db90d12a32d1661dc261b56283f4e45c9a8c8e51a15fd8dae6f4a3`.

| ID | Result | Evidence |
|---|---|---|
| CT1-01 | 1 | boot UNSET, query miss, dest_rd=0 |
| CT1-02 | 1 | Pack A→B COMMIT gen=`000000b1`, query A hit B, dest_rd=1 |
| CT1-03 | 1 | reset UNSET, miss, dest_rd=0 (dest bytes of B may remain) |
| CT1-04 | 1 | Pack A→C gen=`000000c1`, query A hit C, dest_rd=1 |
| CT1-05 | 1 | flush/rebuild then query still C, dest_rd=1 |

T1 occupancy flag stayed 0 (`t1_before=t1_after=0`). Query path dest-reads T2 every time. That matches T1=cache not SoT; it does **not** yet prove a populated T1 RAM.

Dest beat FACT: `[31:0]=page CRC`, SID at `[63:32]`, fwd at `[95:64]`. Decoder scans lanes. Host does not write T1.

Live silicon unchanged: `8fc14f25…` (not this DUT).
