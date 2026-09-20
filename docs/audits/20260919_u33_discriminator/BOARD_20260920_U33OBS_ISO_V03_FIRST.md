# U33OBS isolated V-03 first after program — still R_SENTINEL (2026-09-20)

This watch did **not** run Pack24. Parent `PACK24_ISO_V03_FIRST.json` sha256 `2ad33654…` run=`iso_v03_first_after_program`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **no_pack24=true**.

CLEAR ACK then V-03 NAK `0200085a` n=40 with TAP 9 words: identity **U33OBS_GEN** `gen_stat=47000002` commit=0 capture_valid=0 `generation_flipped` **absent** hop `CLASS_P1_OTHER p1=3149414e`.

Isolated V-03 as first case after this program still R_SENTINEL. TAP piggyback present (unlike UART-only probe). Dest-fresh vs dirty DDR still **not closed** by this run (FPGA program does not wipe DDR). Do not stamp Pack 24/24.
