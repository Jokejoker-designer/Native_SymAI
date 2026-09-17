# 05 — PACK / ABI INTEGRITY GATES (24)

These are separate from the 256 semantic cases.

| Gate | Count | Expected |
|---|---:|---|
| Valid pack + readback | 4 | LOAD_OK and byte/record parity |
| Schema hash mismatch | 4 | LOAD_REJECT |
| ABI version mismatch | 4 | LOAD_REJECT |
| Content hash mismatch | 4 | LOAD_REJECT |
| Page/record CRC corruption | 4 | reject or DATA_INTEGRITY_FAIL, never answer from corrupted page |
| Generation/A-B atomicity | 4 | no half-new/half-old visible state |

## Hard rules

- No best-effort semantic fallback.
- Reject reason must be explicit and logged.
- Failed pack must not partially become queryable.
- A new generation becomes visible only after complete verification and commit.
