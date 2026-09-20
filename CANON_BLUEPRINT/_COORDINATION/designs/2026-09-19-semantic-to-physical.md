# Semantic → physical resolution (independent)

**Status:** ANALYSIS_ONLY. Not RTL. Not a PASS stamp.  
**Date:** 2026-09-19  
**Owner:** CURSOR_OWNER (independent of U33 MAG)  
**Class:** `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE`  
**Separated from:** U33 `R_BAD_MAGIC` / `0200015a`. No causal evidence connects MAG to directory/posting.

```text
ARCHITECTURE LOCK
CHIP     Artix-7 Arty A7-100T
DDR      generated mig0 Native UI  app_addr[27:0]
HOST     UART 8N1 Pack words  AND  QueryRecord 32B (UART query currently tied off)
MUX      Pack A wins FEM B
C RTL    frozen size   FE256 = reference only
PASS     PACK_ABI=NO  M2_PASS=NO  ASTRA_PASS=NO  MIG_PASS=NO  BOARD_PASS=NO
```

Hypothesis under test (not assumed true): after Pack writes an object at a physical address, the system stores or reconstructs `SEMANTIC_ID → PHYSICAL_POINTER → PHYSICAL_PLACEMENT`. Alternative: write path places bytes; query path only gets semantic IDs and expects directory/posting/walker to find them.

**Verdict:** The alternative is **CONFIRMED** on current RTL. The stored-mapping claim is **CONTRADICTED** for Pack COMMIT → query. Name: **SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE**. Not DDR corruption.

---

## 1. Where the physical address is born (write path)

FACT — `pack_loader` `S_WRITE` / `S_RD_ISSUE` (`arty_d/UART_R2/lib/pack_loader.sv`):

```text
mem_addr = slot_base + rg_ddr[wr_sel][27:0] + wr_off_bytes + {wr_idx, 2'b00}
slot_base = slot_bit ? 28'h010_0000 : 28'h0
```

| Field | Source | Module |
|---|---|---|
| `slot_base` | ping-pong `slot_bit` after previous COMMIT | `pack_loader` |
| `rg_ddr[n]` | Pack `OP_REGION` `hw1` = RegionDescriptor `ddr_offset` [§04.6] | host Pack stream |
| `wr_off_bytes` | Pack `OP_PAGE` `hw1` | host Pack stream |
| `wr_idx` | page word index | `pack_loader` |
| `mem_wdata` | page RAM (payload) | `pack_loader` |

Not from `semantic_id`. Not from QueryRecord. Not from `exact_directory`.

FEM window is separate: `fem_req_ui` `FEM_BASE=28'h0200000 + {req_addr,2'b00}` — not the Pack object map.

---

## 2. What kind of address it is

FACT: **taken from Pack** (host `ddr_offset` + page offset), plus a **slot ping-pong base**, not an allocator and not a function of semantic ID.

Gold Pack (`pack_abi24_gold.py`) uses literal `ddr_offset=0` and `16` for ABI-24 cases. Host chooses placement.

There is a **host-side** T2-namespace formula in `export_directory.py`: `edge_ref = edge_id * 32`. That is gold-export packing into BRAM hex, not `mig0.app_addr`.

---

## 3. What COMMIT stores

FACT — `S_COMMIT`:

```text
active_generation <= man_generation   // pack_generation
slot_bit <= ~slot_bit
load_ack <= 1
reason_code <= R_OK
```

Does **not** write:

- HotDirectoryEntry (`semantic_id`, `fwd_ptr`, `rev_ptr`, generation, kind, flags)
- posting page / `PostingEntry`
- T2 Node/Edge records into a query-visible table
- `runtime_profile` (`prof_wr_valid` tied `0` on U33 top)

`rg_ddr[]` remains in flops until the next BEGIN overwrites REGION state; it is **not** a query-visible map.

Canon [§02.4.2] **names** T1 directory as the placement record. Live fill of that table from Pack COMMIT is **absent**.

---

## 4. Deterministic reconstruct for query?

FACT: no FPGA function `semantic_id → mem_addr`.

QueryRecord [§04.3] has `subject_id` / `relation_id` / `object_ref` / `context_id` — semantic refs, no DDR base.

`posting_walk` uses `fwd_ptr[15:4]` as **BRAM word index** into `$readmemh("post_a.mem")`, not `mig0.app_addr`.

If query later used T2 byte addresses as MIG addresses without a stored base, relocating Pack `ddr_offset` would desynchronize unless directory was rewritten. That wiring **does not exist** today.

---

## 5. Actual query hop chain and first missing hop

Intended (canon): `QueryRecord → directory → posting pointer → posting page → walker → T2 EdgeRecord → ASTRA`.

Live U33 UART: `uart_fe256_host.in_valid = 1'b0`. QueryRecord is **not** accepted from UART. `query_result_bind` is instantiated; SPEAR `q_start=1'b0`. `fe256_query_path` is not the common-runtime path.

When a TB steers QueryRecord (`tb_steer` / `tb_query_posting_bind`):

```text
subject_id
  → exact_directory  BRAM dir_a.mem  (scan semantic_id)
  → fwd_ptr / rev_ptr  (T2 byte address fields)
  → posting_walk     BRAM post_a.mem  (index ptr[15:4])
  → first_neighbor, first_edge_ref
  → bounded_walk hops on neighbor_id only
  → astra_qeval      SEARCH_INCOMPLETE 0x04/0x20  (never ANSWER)
```

`first_edge_ref` is **returned**, not used to read DDR.

**First missing hop after a Pack write of G:** Pack `S_COMMIT` does not install T1 `semantic_id → T2 pointer` from the bytes just written. Query never issues `mem_cmd` into the Pack slot.

---

## 6. Hidden lookups that can make tests PASS

FACT:

| Surface | What it injects |
|---|---|
| `exact_directory` `$readmemh("dir_a.mem")` | full T1 map |
| `posting_walk` `$readmemh("post_a.mem")` | posting pages |
| `export_directory.py` from FE256 `build_store_a()` | `edge_ref = edge_id*32`, page ptrs from byte_addr starting 16 |
| `tb_query_posting_bind` `post_expect.hex` | expected neighbor/count; 235 rows `M2_QUERY_POST_XSIM_PASS` |
| `astra_edge_qeval` / `fe256_query_path` `$readmemh("fe256_store.mem")` | dedicated FE256 store, not Pack DDR |
| Pack gold `ddr_offset` literals | physical placement without semantic_id |
| U33 `tb_steer` | TB can inject QueryRecord bytes; UART host tied 0 |

`M2_QUERY_POST_XSIM_PASS` is **not** M2_PASS. It does not prove Pack→DDR→query.

---

## 7. Relocation thought-test

Infrastructure for Pack-write G at P1, relocate to P2, same QueryRecord: **NOT_TESTED** (no such TB).

Thought-test (INFERENCE, not XSim):

- Pack write at P1 vs P2 changes `mem_addr` (`rg_ddr` / slot). DDR bytes move.
- Query still reads `dir_a.mem` / `post_a.mem`. Answer A is independent of P.
- Therefore **A1 == A2** would happen **even if Pack DDR were empty or relocated**, so it would **not** prove relocation invariance of semantic→physical.
- If directory pointers were ever wired as MIG addresses without rewrite, A would follow P (first divergence: directory `fwd_ptr` vs new `slot_base+rg_ddr`).

Do not treat M2 235/235 as A1==A2 under relocation.

---

## 8. Classification

| Claim | Layer |
|---|---|
| Pack physical addr = slot_base + host ddr_offset + page offset | FACT |
| COMMIT stores pack_generation + slot ping-pong only | FACT |
| COMMIT writes T1/T2/posting | CONTRADICTED |
| FPGA `semantic_id → app_addr` | CONTRADICTED (absent) |
| Query UART live on U33 | CONTRADICTED (`in_valid=0`) |
| Isolated QueryRecord→posting XSim 235 rows | PASS_XSIM (`M2_QUERY_POST_XSIM_PASS`); not M2_PASS |
| Query uses Pack DDR | CONTRADICTED |
| Host/TB bake directory+posting | FACT |
| Relocation XSim A1==A2 | NOT_TESTED |
| Query would ignore Pack placement today | INFERENCE |
| Hypothesis “query only has semantic IDs and expects directory to find objects” | CONFIRMED |
| Hypothesis “system stores SEMANTIC_ID→PHYSICAL_POINTER at COMMIT” | CONTRADICTED |
| DDR contents/addressing wrong | NOT_TESTED; do not call corruption |
| U33 MAG caused by this hole | NO CAUSAL EVIDENCE; MAG is pre-retrieval |

**Named class:** `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE`

Equivalent if you need a hop label: `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT`.

---

## MAG firewall

`R_BAD_MAGIC` is decided in `pack_loader` `S_DEC` on accepted BEGIN/hw0 **before** REGION/PAGE/COMMIT and before any QueryRecord. This audit does not explain MAG.
