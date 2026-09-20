# U33OBS — observe identity SPEC (PROGRAM=NO until owner YES)

Not overlay of frozen U33 `ff399e0b…`. Not U33TAP `d448544f…`. Not PACK_ABI_24_24_PASS.

Purpose: (1) first-divergent hop for MUTE dummy-open / MAG; (2) honest `generation_flipped` + load ports for `--compare`.

## Functional lock

Copy U33 pack UART/CLEAR/FIFO/CDC/loader/MIG bind. Do not change `pack_loader` accept/reject law, dest_accept, qsc, or UART PHY product path.

Observe-only additions:

1. **Hop log** (circular, BRAM, depth ≥ 256 events).  
   Event = `{hop[3:0], data[31:0], flags[15:0]}` on fire only (`valid&&ready` same cycle).  
   hops: UART_WORD, FIFO_WR, FIFO_RD, CDC_A, CDC_B, LOADER, CLEAR, ACKNAK.  
   Log **survives CLEAR** (CLEAR is an event, not a wipe).  
   No extra ready-gating of DUT.

2. **Dump** without NAK (MUTE class): after UART RX idle following any hop-log write, or host word `44554D50` (“DUMP”) handled only in observe mux.  
   MAG class: dump on `load_reject` as today, but **after** freeze, do not require NAK to have the log.  
   Dedicated TAP CDC (do not smash pack TX CDC). Magic `31504154`.

3. **Compare snapshot** after each load_ack/load_reject: `reason_code`, Pack-owner `active_generation` around the COMMIT edge, epoch, `capture_valid`.  
   `generation_flipped=true` iff `commit_event==1 AND generation_after!=generation_before AND same_capture_epoch AND capture_valid==1`.  
   Do not infer flip from two snapshots if CLEAR/reset/epoch changed between them. Stream as TAP words. Host builds DUT.jsonl. **Do not copy TSV flip.**

4. **R-04/G-04 query**: frozen U33 `in_valid=0` cannot score query. OBS may wire `uart_fe256_host.in_valid` from UART words **only if** owner YES names query-on-UART as in-scope. Default this SPEC: query still tied off; `--compare` remains incomplete for R-04/G-04 until that YES.

5. Pin UART RX: ILA optional, separate grant. Word-level hops are the default (Arty ILA cannot store 18 ms @ 100 MHz full-rate).

## Stop

Build after SPEC freeze. Program only `OWNER_AUTHORIZED` with a **new** results dir. If OBS does not reproduce dummy-open MUTE: `INSTRUMENTATION_PERTURB`, do not declare U33 clean.

U33TAP dump-after-NAK is **not** this SPEC.
