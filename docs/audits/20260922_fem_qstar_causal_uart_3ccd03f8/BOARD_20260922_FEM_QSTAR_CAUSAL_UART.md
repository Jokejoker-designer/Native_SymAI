# Unique FEM Q* identity 3ccd03f8 PROGRAMMED + UART A/B/A/B CANDIDATE (2026-09-22)

Watch did **not** program. No `.bit` in git. Independent Get-FileHash of live Q* causal bit equals `3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d`. Disk persist keep `1db38691…` unedited. C hashes independently confirmed.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = FEM_QSTAR_CAUSAL_UNIQUE
STATUS = PROGRAMMED
EOS = HIGH
PROGRAM.DONE = NA
UART_BOARD_SMOKE_CANDIDATE = YES
GREEDY = 0,1,0,1
DEST_POKE = NO
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| Q* causal `.bit` (disk, not committed) | `3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d` |
| `UART_QSTAR_ABAB.json` | `302c7bd46e9262c745c3ef66fdc20d08ac378c8cae618bccb21c220c38b1c76f` |
| `PROGRAM.txt` | `2bf285fcc2caba35f2a0d5057d4255b66759c6fff377531b75a0a0c74822ec96` |
| `BOARD_CANDIDATE.md` | `22eb3cf2081a4cbc39d277e5aea48945cefc323ec3eb93f90a9923083991eb0a` |
| V1 20260922T003200Z | `5a538e0d34b7404637220cfd798abe134ee30bac2f912637b330cc88a16c8e8d` |
| persist `.bit` disk keep | `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |
| C `qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| C `spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |

JSON `SHA256` field matches the independent bit hash. No `44504B31`. `dest_poke=NO`. COM12.

## FACT — parent programmed this SHA (watch did not)

JTAG `210319BE776EA`. `PROGRAM.txt` `STATUS=PROGRAMMED` `EOS=HIGH` `PROGRAM.DONE=NA`. Note: Tcl property query for `PROGRAM.DONE` aborted after startup HIGH; file records that. **PROGRAM_PASS=NO.**

## FACT — UART QOBS discriminator CANDIDATE (not BOARD_PASS)

Independent JSON parse:

```text
QOBS_A  greedy=0 feat0=0 ft=0 life=7 compacted=0
QOBS_B  greedy=1 feat0=2 ft=2 life=3 compacted=1 q_sel=2
QOBS_A2 greedy=0 feat0=0 ft=2 life=3 compacted=1
QOBS_B2 greedy=1 feat0=2 ft=2 life=3 compacted=1 q_sel=2
GREEDY=0,1,0,1
```

FOBS_AFTER_FREC decode `ft=2 life=3 compacted=1 recov=2 key=0x70ea`. A2 kept recovered `failure_total` while greedy returned to 0. Live SRAM hash UNKNOWN (not read back). Identity binding is programmed SHA + provenance, **not** live SRAM hash.
