# NEXT — thorough close (not a PASS stamp)

GOLD on first U8 program session is **not** N/N. Later same bit:
- ACK then V-04 n=0 12s
- CLEAR1 n=0 after fresh program (12s and ~25s settle)

Do not treat U8 as triệt để.

## Ordered close (one class per identity)

1. **Host law (no new bit):** PROGRAM≠READY; COM-open≠MARK-idle; ACK≠pack license; GOLD≠CLEAR2 license. Prove DTR on open. N repeats after one program, COM never closed mid-pack.
2. **U9 CDC release:** after `rst100_pack_n` rises, hold `a_valid` off for ≥8 cycles; keep `cdc_rst` until IDLE. Separate identity.
3. **G3** `uart_tx_word` flush does not abort in-flight word. Separate identity.
4. Repeat T1+V-04+CLEAR2 until N/N on one identity. Then Pack24 campaign. Not PACK_ABI_24_24_PASS self-stamp.
5. **FEM persist** only after Pack is B-classifiable.
6. Common-runtime FE256 gate; ASTRA completeness; do not hybrid-route to dedicated FE256.

AGENT_C RTL / identity H / freeze DCP / B gold: do not touch.
