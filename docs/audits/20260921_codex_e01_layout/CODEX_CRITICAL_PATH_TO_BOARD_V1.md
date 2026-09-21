# CODEX critical path to a trustworthy integrated candidate

This path starts only from the integrated RKB-01 failure. Checkpoint X is not reopened.

1. **Lock the corrected integration identity.** Include top, local walk/cache, CDC, actual compiler inputs/flags and every integrated input vector. Preserve pinned FAIL raw log and separate the 13:48 result. INT-B02 currently prevents an unambiguous build recommendation.
2. **Retain the completed E01 causal control.** FAIL words must yield correct SID + one directory read + miss; aligned current words must yield the same SID + reads 0x20/0x30/0x40/0x50/0x60 + B. This fixes the producer/consumer boundary without changing lookup semantics.
3. **Validate the integrated hardware-facing boundary.** Exercise intended UI clock/reset and memory response timing using the pinned corrected graph. Existing same-clock BRAM evidence must keep that label. Review the current integrated suite against those same sources; do not substitute isolated results.
4. **Build a uniquely named candidate only after the identity/validation review is closed.** Collect source/input hashes and implementation timing/CDC reports. Existing frozen bitstreams remain untouched.
5. **Review the exact candidate bit hash and owner authorization before board programming.** Compare board request/read/result evidence to the same RKB-01 chain. No claim is promoted merely because a bit is built or programmed.

| Item | Severity | Evidence / first divergence | Blocks bit / program / RKB | Decisive action | Blast radius |
|---|---|---|---|---|---|
| INT-B01 image layout | S1 | E01 fail/control; wrong lane at first directory response | Old-layout bit candidate YES / YES / YES | Keep aligned producer/vector contract; E01 completed | Input packaging |
| INT-B02 changed run identity | S1 | Source manifest versus live hashes | YES / YES / evidence validity | Full current build manifest | Evidence only |
| INT-U02 clock/MIG coverage | S1 board risk | Top RKB_EDGE_XSIM branch; no failing cycle alleged | Current readiness NO / YES / synchronous test NO | Hardware-boundary integration validation | Test configuration |

```text
SAFE_TO_CONTINUE_INTEGRATED_XSIM=YES
SAFE_TO_BUILD_BITSTREAM=NO
SAFE_TO_PROGRAM_BOARD=NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN
BOARD_PASS=NO
PROGRAM_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
```
