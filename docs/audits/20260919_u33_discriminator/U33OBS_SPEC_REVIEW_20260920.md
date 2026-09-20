# U33OBS specification review — mapper and hop logger

FACT — `uart_token_to_compare.py` selftest passes 24/24 mapping cases and reports `compare_ready_without_observed_flip=0`; it never copies TSV `flip` into a DUT row. This is the correct UART-only boundary. SHA256: `6c4692f72a016e428082717f1a2479c800f74dbf3d6cce672e105df09b60272a`.

FACT — `pack_hop_log.sv` synthetic test passes the current narrow contract: CLEAR is recorded rather than wiping the ring, and same-cycle UART+LOAD sets both mask bits. Output: `PASS_XSIM pack_hop_log CLEAR-survive same-cycle mask` at 96 ns. This is a unit test of the logger, not a U33OBS bitstream or board result.

## Structural gaps to close before any observation identity

1. **Generation is absent from the starter logger.** `pack_hop_log.sv` inputs include `ack_event`, `nak_event` and `reason_code`, but no `active_generation`, previous-generation snapshot or `generation_flipped`. The U33OBS contract must add a compare-snapshot record or a separate register bank. A UART token cannot supply this field.

2. **One data word is insufficient for a multi-hot event.** The logger stores `{mask_c, data_c}`. `data_c` chooses one priority source (`load > cdc_b > cdc_a > fifo_rd > fifo_wr > uart > reason`). If UART and loader fire on the same cycle with different words, the mask says both fired but the single data word preserves only loader data. That can prove co-occurrence but cannot prove each hop's payload. This is insufficient for first-divergent-hop attribution.

3. **The spec's event shape differs from RTL.** U33OBS describes `{hop[3:0], data[31:0], flags[15:0]}`; the starter RTL actually stores a 9-bit event mask plus one 32-bit data word (41 bits). Freeze the on-wire/event ABI before implementation. Either use one record per hop with per-hop data, or define explicit per-hop payload fields in a wider record.

4. **Ring overflow is not exposed.** `n_ev` saturates at DEPTH while `wr` wraps. A full ring can silently overwrite the oldest event. Add `overflow` and a capture-valid/epoch field; any overflow invalidates the run.

5. **No event epoch or arm snapshot.** CLEAR is logged, but the logger has no arm-time state snapshot and no explicit capture epoch. A MUTE with a pre-existing partial loader state needs state before CLEAR, not only post-CLEAR events. Capture must begin before CLEAR and retain parser/CDC reset state.

6. **No loader state/generation fields.** `load_fire/load_data/reason_code` alone cannot establish `state`, `opcode`, `rx_words`, `hw0`, `got_begin`, `active_generation`, `slot_bit`, or reset edges. U33OBS must expose these as observe-only snapshot fields at the relevant event, especially on MUTE where there is no NAK trigger.

7. **Clock-domain separation is required.** A single `clk` logger cannot directly consume both clk100 and ui_clk events. Do not combine unsynchronized multi-bit payloads. Use one logger per domain, local event records, and a small synchronized freeze/epoch indication. Correlate through recorded CDC req/ack transitions and CLEAR request edges.

## Required compare law

FACT — A UART row is load-side only: exact 4-byte GOLD/NAK gives `outcome`, `reason`, `ack`, `reject`. It does not give `generation_flipped`, R-04/G-04 query status, or committed-generation truth.

INFERENCE — A compare-ready DUT row must require observed `generation_flipped` from the Pack-owner COMMIT transition, not from two snapshots across CLEAR/reset/epoch. Owner lock 2026-09-20: `generation_flipped=true` iff `commit_event==1 AND generation_after!=generation_before AND same_capture_epoch AND capture_valid==1`. For R-04/G-04 it must additionally require observed query status/reason from an owner-authorized query path. A row missing any required observation remains `compare_ready=false`; this is not a failed semantic result and cannot be silently filled from TSV.

## Status

FACT — Query wiring remains out of scope and U33 remains untouched. `PACK_ABI_24_24_PASS=NO`; no programming; no overlay. This review does not alter the user's starter RTL. It records the blockers that must be resolved before freezing U33OBS as an observation identity.
