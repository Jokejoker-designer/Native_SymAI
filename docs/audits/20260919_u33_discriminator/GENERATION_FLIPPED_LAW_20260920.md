# generation_flipped — owner lock Ý 5–6 (2026-09-20)

PACK_ABI_24_24_PASS=NO. Not a product RTL change.

`generation_flipped` is a Pack-owner **COMMIT state transition**, not `snap_a != snap_b` of two idle samples. If CLEAR, debug_clear, observer reset, or epoch re-arm sits between the samples, the pair is not a flip even when the numbers differ.

```text
generation_flipped = true   iff
  commit_event == 1
  AND generation_after != generation_before
  AND same_capture_epoch
  AND capture_valid == 1

generation_flipped = false  iff
  commit_event == 1
  AND same_capture_epoch
  AND capture_valid == 1
  AND generation_after == generation_before

else: field absent → compare_ready=false
```

`same_capture_epoch` = `epoch_id` at the before sample equals `epoch_id` at the after sample, and `clear_or_reset_between=0`.

Do not copy TSV `flip`. UART GOLD/NAK does not carry this field. Mapper: `observe_generation_flipped()` in `uart_token_to_compare.py`.
