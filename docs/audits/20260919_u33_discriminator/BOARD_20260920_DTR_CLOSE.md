# U33 transport trigger follow-up — DTR/RTS and close phase

FACT — Resident/disk identity checked against U33 SHA `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350`; canonical V04 SHA `01bb177e...`. No programming or RTL change was performed by these two matrix scripts.

The earlier post-program A/B/A produced A1 mute, B GOLD, A2 mute when only preliminary dummy open/close was changed. That result remains valid for that exact sequence, but it was not deterministic across later probes.

| Follow-up | Arms | Result |
|---|---|---|
| DTR/RTS matrix | false/false, true/false, false/true, true/true | All four CLEAR ACK + V04 GOLD; no drain bytes. |
| Close-phase matrix | baseline single open; immediate dummy close; dummy mark/purge then close | All three CLEAR ACK + V04 GOLD; no drain bytes. |

FACT — All V04 payloads were 208 bytes, one BEGIN, identical payload SHA `a2cbeb8c5c498e47207e5e2a3f9fc90035d3148cc62758f9f3528f871f6148be`. Results: [DTR_RTS_MATRIX.json](D:/FPGA/arty_d/UART_R2/results/U33_DTR_RTS_MATRIX_20260920/DTR_RTS_MATRIX.json) SHA256 `2e6e658d...`; [CLOSE_PHASE_MATRIX.json](D:/FPGA/arty_d/UART_R2/results/U33_CLOSE_PHASE_MATRIX_20260920/CLOSE_PHASE_MATRIX.json) SHA256 `818c6648...`.

INFERENCE — Fixed DTR/RTS levels are not sufficient to cause the mute. A single close event or mark/purge phase is not sufficient in these follow-up runs. The earlier dummy-open A/B/A remains evidence of a history/timing-sensitive trigger, not a deterministic root cause.

UNKNOWN — The remaining host-side mechanisms include USB/FTDI lifecycle timing, inter-byte transmission timing, a UART decoder/framing state reached only under a particular history, and a CLEAR/FIFO/CDC state race. The existing tests cannot choose among these because they observe only returned UART words.

CONTRADICTED — “Dummy-open always causes mute.”

CONTRADICTED — “DTR or RTS final level is the root cause.”

NOT_TESTED — Passive FPGA RX pin capture and accepted-word capture at UART decoder, FIFO pop, CDC source/sink and loader. Those remain necessary to close the MAG history; no loader/MIG patch is justified.

PACK_ABI_24_24_PASS=NO; BOARD_PASS=NO; PROGRAM_PASS=NO; overlay=NO.
