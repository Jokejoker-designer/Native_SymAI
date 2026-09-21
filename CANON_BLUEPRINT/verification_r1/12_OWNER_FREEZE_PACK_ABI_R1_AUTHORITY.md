# Owner freeze — Pack ABI authority is R1 Causal (2026-09-21)

Not a historical `PACK_ABI_24_24_PASS` stamp. D does not self-stamp that name.

```text
GUARD_ID  D-PACK-ABI24-R1-AUTHORITY-FREEZE
RUN_ID    20260921T021200Z
```

## Authority split

| Layer | Role after this freeze |
|---|---|
| `verification_r1/` Native_SymAI Benchmark R1 Causal zip `4bc37ffe…` | **Pack ABI authority.** Comparator `10_pack24_r1_compare.py`. |
| `verification/pack_abi24/pack_abi24_gold.py` (R0.1 / B) | **Historical reference.** Do not edit. `--compare` remains 6/24 on honest omit-DUT. |
| `verification/fe256/fe256_gold.py` | Unchanged FE256 authority. Not opened by this freeze. |
| `32_ACCEPTANCE_LADDER.md` | Historical R0.1 ladder. Unchanged. |

## P0 Pack closed (R1)

This-turn command (copies in freeze dir, originals not overwritten):

```text
python 10_pack24_r1_compare.py PACK24_RESUME_QUERY_R1.jsonl
→ PACK_ABI24_R1_CANDIDATE: 24/24 contract match  rc=0
NOTE: does NOT authorize historical PACK_ABI_24_24_PASS
```

DUT sha256 `090b7814d0bbe6d31089e07339bfa64c93651881c429deb83d0621de56639737`.

Historical B compare on the sibling B-shaped jsonl:

```text
python pack_abi24_gold.py --compare PACK24_RESUME_QUERY_DUT.jsonl
→ compare 6/24 match, 18 fail  rc=1
```

Eighteen fails are `generation_flipped` got `None` expected `0`. Owner freeze does **not** fill TSV 0.

```text
PACK_ABI24_R1_P0_CLOSED = YES
PACK_ABI_24_24_PASS     = NO
U33OBS_DEBUG            = CLOSED
```

## Still not claimed

`destination_complete=true` in the R1 jsonl is `S_RD_WAIT_THEN_S_COMMIT_GOLD` (page first-word handshake). Dest hex UART = `NOT_RUN`. Manifest `pack_generation` is flop `active_generation` at `S_COMMIT`, not a dest header word.

```text
PACK_DEST_COMPLETE_BOARD_PASS          = NOT_RUN
UART_MUX_8_8_PASS                      = NOT_RE_RUN_THIS_CLOSE
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS     = NOT_RUN
READBACK_ACTIVE_GENERATION_PASS        = NOT_RUN
```

## Next (owner)

Stop Pack/U33OBS debug. Next D work:

```text
READBACK_ACTIVE_GENERATION
RUNTIME_KNOWLEDGE_BINDING_8_8
```

Freeze copies: `D:/FPGA/arty_d/UART_R2/results/PACK_ABI24_R1_AUTHORITY_FREEZE_20260921/`
`SHA256SUMS.txt` sha256 `998f19c4691bce886727d23ae074a127908c55bd071626ec93e00ec76a0404bf`.
