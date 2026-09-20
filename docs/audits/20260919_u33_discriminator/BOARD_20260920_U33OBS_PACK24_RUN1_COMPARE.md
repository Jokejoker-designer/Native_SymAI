# U33OBS Pack24 run1 D-json + V-03/A-03 probe — not PACK_ABI (2026-09-20)

This watch did **not** run Pack24. Parent `D_U33OBS_PACK24_RUN1.json` sha256 `18ae5afb…`. Probe `PACK24_PROBE_V03_A03.json` sha256 `e0725e26…`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**.

B `--compare` printed `compare -16/24 match, 40 fail` (field-fail count, not 16 matching cases). TAP four-AND **absent** this run (OBS freeze sticky; CLEAR does not re-arm). Isolated retry: V-03 still `0200085a` R_SENTINEL; A-03 still MUTE n=0.

Parent names 21/24 UART load/reason match **ignoring** flip/query. Fail 3: V-03 R_SENTINEL, A-03/A-04 MUTE. This watch does **not** stamp `BOARD_PASS` or Pack 24/24. Do not run2 until V-03 on fresh dest is classified.
