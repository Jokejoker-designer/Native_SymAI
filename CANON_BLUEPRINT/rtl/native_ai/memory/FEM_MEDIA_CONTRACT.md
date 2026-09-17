---
version: "0.1-candidate"
owner: AGENT_D
status: CANDIDATE
task: D-INTEG-01
last_modified: "2026-09-16T14:45:00+07:00"
---

# FEM physical media contract (D-INTEG-01)

> CANDIDATE engineering contract. Not FEM_PERSIST_PASS. Not BOARD_PASS.
> Does not rewrite §11 / §02 / §04. PROGRAM=NO. XSim != board.
> PROXY_METRIC_FALSE_PASS_GUARD applies.

## FEM_STORAGE (actual path)

| Layer | What lives there | Persistence authority? |
|---|---|---|
| C `fem_lifecycle` T2 port | 32-bit word-atomic **model** (sync read next cycle) | **No.** Local crash-cut model only. |
| T1 BRAM | Optional **hot cache** of recent FEM prototypes [§02 T1] | **No.** Cache residency is not COMMIT. |
| T2 DDR3L via MIG (Arty A7-100T) | Canonical FAILURE / prototype / raw / COMMIT / INDEX [§02: FAILURE canonical = T2] | **Yes**, after dest-domain completion + identity match. |
| Staged path (production) | FEM FSM in fabric → media bridge (pack/mask/outstanding) → MIG `app_*` → DDR | Yes, only at DDR-visible completion. |

**FACT:** generated native MIG exists at `D:/FPGA/miggen` (short path; package path exceeded Windows 260).  
`APP_DATA_WIDTH = 128` = `2 * nCK_PER_CLK * PAYLOAD_WIDTH` = `2 * 4 * 16` from `mig0_mig.v`.  
`APP_ADDR_WIDTH = 28`. `ECC = OFF`. `DQ_WIDTH = 16`. Native `app_*` UI (not AXI).  
This is **not** `MIG_PASS`: no calib, no dest readback on silicon.

T1→T2 copy does not change FAILURE identity [§02].

## WRITE_ATOMICITY

| Item | Production (MIG/DDR) | C local model |
|---|---|---|
| Physical write granularity | MIG UI beat **128 b** (`APP_DATA_WIDTH` from generated `mig0_mig.v`) + DDR BL8 | 32-bit word |
| FEM logical word | 32-bit `LEARNING_LOCAL_LAYOUT_CANDIDATE` | 32-bit |
| Torn writes | **Yes** at beat/mask/RMW/reset. A 32-bit lane of a 128-bit beat can be partial. | Assumed impossible |
| Visibility | Destination DDR contents after **readback match** of the same txn/generation | Immediate on `t2_we` |
| `app_wdf` accept / cmd FIFO empty | **Not** completion (PROXY_METRIC_FALSE_PASS_GUARD) | n/a |
| Reset during outstanding | Aborts in-flight beat; dest may be old, new, or mixed | DUT reset; T2 TB RAM survives |

## COMPLETION_AUTHORITY

A FEM write is complete iff **all** hold:

1. Dest-domain readback of the targeted beat/word equals the issued payload (masked lanes).
2. Response carries the **same** `txn_id` and `knowledge_generation` as the request.
3. `wr_outstanding` for that identity is zero **after** the matching response, not because a command FIFO is empty.

Forbidden proxies: FIFO-empty, `t2_we` pulse, loader `load_ack`, OOC WNS, PROGRAM_PASS.

## INTEGRITY_SCHEME

| Item | Rule |
|---|---|
| CRC | CRC16-CCITT-FALSE over prototype `W0\|\|W1` (C layout). Generated **before** dest write of `CRCW`. |
| Check | After dest **readback** of `W0,W1,CRCW` — never from the fabric copy alone. |
| Recovery reread | Recovery **always** rereads COMMIT, CRCW, W0, W1 from dest. |
| ECC | **OFF** in generated `mig0_mig.v`. FEM CRC16 remains the dest integrity tag. |
| COMMIT valid + CRC fail | **FEM_DEST_INTEGRITY = COMMITTED_CORRUPT**. Compaction recover stays **OLD_VALID** (fail-closed). **Not** a fourth compaction state. Do **not** classify as COMMITTED_NEW. Do **not** roll forward index/retire. Raw remains authoritative if still present; if raw already retired this is a dual-loss hazard and must fail closed. ASTRA mapping is B-owned (`0x06` + `0x56`). |

§11.12.3 names three compaction recover states only. `fem_commit_class.recover_state` is `{0,1,2}` only. `dest_committed_corrupt` is the dest-integrity observable.

## Compaction order on real media

```text
build prototype
 -> dest write W0,W1,CRCW  (each: issue → outstanding → readback match)
 -> dest reread + CRC check
 -> dest write COMMIT
 -> dest reread COMMIT == magic AND CRC still valid
 -> dest write INDEX
 -> dest reread INDEX
 -> only then dest write RAW retire
```

No step advances on FIFO-empty or fabric CRC.

## RESET_BEHAVIOR

Reset/power-cut with `wr_outstanding!=0` does **not** drain. In-flight beat is undefined. Recovery must dest-reread and classify. C B0..B6 word cuts are a **subset** of physical windows.

## B0_B6_PHYSICAL_MAPPING

C logical cuts assume one 32-bit word-atomic T2 op. Generated native MIG UI beat is **128 bits** (four 32-bit lanes). Each logical word therefore expands:

| C boundary | C event | Physical MIG windows (APP_W=128 FACT, one word = 1 lane RMW) |
|---|---|---|
| B0 | nothing written | idle |
| W0 / W1 / CRCW | 3 word writes | each: `app_en` write + `app_wdf` + **dest readback match** (2 UI txns) + optional torn-mask/RMW of the other 3 lanes |
| B1 | after T2 proto write | after **3** dest-complete write+readback pairs, not after FIFO-empty |
| B2 | after CRC verify | dest reread W0,W1,CRCW (3 reads) then CRC; CRC over fabric copy is a false pass |
| B3 | after COMMIT mark | COMMIT write+readback; cut during beat may leave torn COMMIT magic |
| B4 | after INDEX | INDEX write+readback |
| B5 | during RAW retire | per-slot write+readback; N_RAW windows |
| B6 | compacted | header write+readback |

**ADDITIONAL_CUT_WINDOWS:** W0-a cmd, W0-b wdf, W0-c readback, plus same for W1 and CRCW, plus RMW sibling-lane windows, plus reset while `wr_outstanding!=0`. C B0..B6 alone does **not** prove DDR crash safety.

C `fem_lifecycle` now has `t2_ready` (C ACK D-INTEG-01 / D-06): dest clock-enable of the whole T2 port. D maps `t2_ready` = dest readback + txn/generation match via `fem_t2_ce` (not FIFO-empty, not adapter-IDLE alone). `integrity_fault` is dest COMMITTED_CORRUPT. Evidence: `FEM_COMPACTION_LOCAL_PASS_BOTH` (Icarus ±STALL) and `FEM_MEDIA_SYS_XSIM_PASS` (XSim dest-complete). Not FEM_PERSIST_PASS (no MIG silicon readback).

## Claim ceiling

| Item | Rule |
|---|---|
| CRC | CRC16-CCITT-FALSE over prototype `W0\|\|W1` (C layout). Generated **before** dest write of `CRCW`. |
| Check | After dest **readback** of `W0,W1,CRCW` — never from the fabric copy alone. |
| Recovery reread | Recovery **always** rereads COMMIT, CRCW, W0, W1 from dest. |
| ECC | **OFF** in generated `mig0_mig.v`. FEM CRC16 remains the dest integrity tag. |
| COMMIT valid + CRC fail | **FEM_DEST_INTEGRITY = COMMITTED_CORRUPT**. Compaction recover stays **OLD_VALID** (fail-closed). **Not** a fourth compaction state. Do **not** classify as COMMITTED_NEW. Do **not** roll forward index/retire. Raw remains authoritative if still present; if raw already retired this is a dual-loss hazard and must fail closed. |

§11.12.3 names three compaction recover states only. `fem_commit_class.recover_state` is `{0,1,2}` only. `dest_committed_corrupt` is the dest-integrity observable. ASTRA mapping is B-owned (`0x06` + `0x56`).

## Compaction order on real media

```text
build prototype
 -> dest write W0,W1,CRCW  (each: issue → outstanding → readback match)
 -> dest reread + CRC check
 -> dest write COMMIT
 -> dest reread COMMIT == magic AND CRC still valid
 -> dest write INDEX
 -> dest reread INDEX
 -> only then dest write RAW retire
```

No step advances on FIFO-empty or fabric CRC.

## RESET_BEHAVIOR

Reset/power-cut with `wr_outstanding!=0` does **not** drain. In-flight beat is undefined. Recovery must dest-reread and classify. C B0..B6 word cuts are a **subset** of physical windows.

## B0_B6_PHYSICAL_MAPPING

C logical cuts assume one 32-bit word-atomic T2 op. Generated native MIG UI beat is **128 bits** (four 32-bit lanes). Each logical word therefore expands:

| C boundary | C event | Physical MIG windows (APP_W=128 FACT, one word = 1 lane RMW) |
|---|---|---|
| B0 | nothing written | idle |
| W0 / W1 / CRCW | 3 word writes | each: `app_en` write + `app_wdf` + dest readback match (2 UI txns) + optional torn-mask/RMW of the other 3 lanes |
| B1 | after T2 proto write | after **3** dest-complete write+readback pairs, not after FIFO-empty |
| B2 | after CRC verify | dest reread W0,W1,CRCW (3 reads) then CRC; CRC over fabric copy is a false pass |
| B3 | after COMMIT mark | COMMIT write+readback; cut during beat may leave torn COMMIT magic |
| B4 | after INDEX | INDEX write+readback |
| B5 | during RAW retire | per-slot write+readback; N_RAW windows |
| B6 | compacted | header write+readback |

**ADDITIONAL_CUT_WINDOWS:** W0-a cmd, W0-b wdf, W0-c readback, plus same for W1 and CRCW, plus RMW sibling-lane windows, plus reset while `wr_outstanding!=0`. C B0..B6 alone does **not** prove DDR crash safety.

C `fem_lifecycle` now has `t2_ready` (C ACK D-INTEG-01 / D-06): dest clock-enable of the whole T2 port. D maps `t2_ready` = dest readback + txn/generation match via `fem_t2_ce` (not FIFO-empty, not adapter-IDLE alone). `integrity_fault` is dest COMMITTED_CORRUPT. Evidence: `FEM_COMPACTION_LOCAL_PASS_BOTH` (Icarus ±STALL) and `FEM_MEDIA_SYS_XSIM_PASS` (XSim dest-complete). Not FEM_PERSIST_PASS (no MIG silicon readback).

## Claim ceiling

`FEM_COMPACTION_LOCAL_PASS` ≠ `FEM_PERSIST_PASS`.  
No `BOARD_PASS` / `FINAL_PASS` / `PACK_ABI_24_24_PASS` from this contract.
