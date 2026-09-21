# Unique dest TAP ead830ae PROGRAMMED + UART dest causal (2026-09-21)

Watch did **not** program. No `.bit` in git. Independent Get-FileHash of live dest-TAP bit equals `ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0`. Frozen `daaca9c1…` and `8bfd993d…` files **UNTOUCHED**.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = RKB_DEST_CAUSAL_TAP_BOARD_CANDIDATE
PROGRAMMED_EOS_HIGH = FACT (16:07+07; restore 20:38+07 after USB DONE=0)
PROGRAM_PASS = NO
BOARD_PASS = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| dest-TAP `.bit` (disk, not committed) | `ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0` |
| `daaca9c1` file keep | `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381` |
| CT1 file keep | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| dest-TAP `PROGRAM.txt` | `adc4ec9b182b84b3e390363d75d3337be0fdef4c610a1315d57a344c391caaaf` |
| dest-TAP `program.log` | `97b8ea59248878916c4cc5ad8a8a9866f67478167e5ed85c460d9e73884f478d` |
| RKB-04 UART json | `f5dbafcf4d0ac1b70ac850a0dda88cd095e23d9ad0281492e4208322230746f9` |
| RKB-02/08 UART json | `4bfbd1ae2317fc9f6d2e42dd8c18a6f7d81807915603eabdcc3a84678d8f81ee` |
| RKB-05/06 UART json | `f1615793e38d690a915341f6b71b25bfbf272157e5b8a7bfd16d0d0c965c63a6` |
| `CLOSURE_AUDIT_8_8.json` | `ca26a0ff53e16da1f74c4e02cda043cc5e5bcb33b91c4fadf90089d02374c0ad` |
| prior TAP-gen json (daaca9c1) | `56f61d650da0434482c1d92c2363437105ee7f3b4219e119131776a7e8a6c953` |

## FACT — first dest-TAP route failed (not JTAG)

WNS=−0.647 `SETUP_NOT_MET`. Rebuild WNS=+0.092 WHS=+0.016 `TIMING_PASS=NO`. TAP SID must come from walk `last_sid`, not `sid_hold`.

## FACT — silicon dest causality on ead830ae (PASS_BOARD_UART / CANDIDATE)

RKB-04: DEST_POKE zero EdgeRecord only → MISS dest_rd delta=4; gen/root/dir/post held; restore HIT C. Query token remains `03|hit|00|51`; **WALK_TAP nb** is EdgeRecord.dst_id.

RKB-02 after CLEAR: relocate poison old still HIT; poison active MISS. First same-session A2B over live C was NAK `02000e5a` R_STALE (not dest fail).

RKB-08: leftover B did not rescue poisoned C.

RKB-05 `STALE_KNOWLEDGE_EXCLUSION`; RKB-06 `SEMANTIC_PARITY_ONLY`; T1 drop **NOT_PROVEN**. Inventory `CLOSURE_AUDIT_8_8` is **not** 8/8.

On `daaca9c1`, TAP dump is pack generation B=`b1` vs C=`c1`; dest poison BLOCKED on that older TAP.
