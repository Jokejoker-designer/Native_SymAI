# Independent audit checklist — uart_r2_ct1 (before any nạp)

Owner must authorize the **exact bitstream SHA256**. PROGRAM=YES already recorded is not a blanket.

## Must confirm (ANALYSIS_ONLY unless owner later grants nạp)

1. Synth file list has **zero** `dir_a.mem` / `post_a.mem` copies.
2. No `exact_directory` / `query_result_bind` / `posting_walk` cells on the query answer path.
3. `ct1_uart_query` is the UART QueryRecord steal; it waits dest lookup; it does not TX a fixture token on `go`.
4. `dest_root_cache` has no host `wr_valid` / T1 poke port from UART or debug TAP.
5. `t1_flush` / `t1_rebuild` tied off in the bitstream (`ifndef CT1_XSIM`).
6. UNSET `active_generation` (0xFFFFFFFF) fail-closes query with dest_rd=0 (no dest lookup).
7. Pack COMMIT publishes dest root; query uses that dest beat (lane-scan SID).
8. Bit file is `D:/FPGA/arty_d/UART_R2/build_ct1/uart_r2_ct1_candidate.bit` and SHA matches `SHA256.txt`.
9. Does not overwrite `build_u33obs_query` / `8fc14f25…`.
10. FE256 / ASTRA / Q* / SPEAR / FEM **files** unchanged; C RTL unchanged; `pack_abi24_gold.py` unchanged.

## Claim ceiling

PASS_XSIM integrated + BIT_OK ≠ BOARD_PASS / PROGRAM_PASS / MIG_PASS / TIMING_PASS / PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
