# H10 paced vs burst — RUN 2026-09-17 JP2_REMOVED

HYPOTHESIS: sticky mute depends on burst traffic / insufficient downstream service.
CONTROL: Identity H `cf62102f`, gold TSV/.mem, 115200, JP2 OWNER_REPORTED_REMOVED, same PC/cable.
SINGLE_CHANGED_VARIABLE: burst vs paced bytes (`--gap-ms 0.5`). Reprogram between arms. No RTL. No gold edit.
EXPECTED_IF_TRUE: BURST sticky/NO_BYTE high; PACED GOLD/ACK survives.
EXPECTED_IF_FALSE: both fail similarly → weight toward persistent state/reset/dest, not rate.
MEASURED_RESULT:
  BURST: CLEAR_ACK_OK=18/24 GOLD=13/24 ISO_EQ=7/24 pack_nobyte=6 jsonl sha256 b565a0cd…
  PACED: CLEAR_ACK_OK=20/24 GOLD=19/24 ISO_EQ=12/24 pack_nobyte=4 jsonl sha256 4a7ba163…
  V-03: both CLEAR ACK then PACK SENTINEL 0200085a (CLASS A independent of rate).
  V-04: burst CLEAR n=0; paced GOLD 010000a5 (rate-sensitive).
FIRST_DIVERGENCE: rate changes GOLD/NO_BYTE counts; does not remove CLASS A SENTINEL on V-03.
NEXT_ACTION: H11 same-case repeat (V-04 default + V-03 as CLASS A candidate). No Identity I.
STOP_CONDITION: both jsonl saved. Done.

H10_STATUS=PARTIAL_RATE_EFFECT_REJECTED_AS_SOLE_ROOT
