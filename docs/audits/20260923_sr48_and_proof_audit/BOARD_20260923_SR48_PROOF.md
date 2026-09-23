# 48-byte header XSim and proof audit (2026-09-23)

Watch did **not** program. SRAM image `e2d97151…` was not rebuilt. No `.bit` in git.

LANGUAGE=EN. Not a product PASS stamp.

Live logs hashed in this directory:

| Log | SHA256 | Finish |
|---|---|---|
| `sr48_r01_zero_refs_xsim.log` | `33333660…` | 1 ns |
| `ja_query_qeval_xsim.log` | `a0223821…` | 1 ns |
| `sr_host_frame_xsim.log` | `796d4e71…` | 10595 ns |

`33333660…`: bytes 0–1 are `52 4E`, status `04`, CRC matches, bytes 12–45 are 0 including `answer_ref`. `f2a071fe` is not inside that header.

`a0223821…`: `astra_qeval` on the JA query bytes returns status `04`, reason `20`, completeness `02`. `search_budget` is 0. Not ANSWER.

`796d4e71…`: the 48-byte header takes status, reason, and completeness from that qeval. `answer_ref` stays 0. Evidence ref `f2a071fe` stays outside the header. ANSWER is not emitted.

The goal-plan lines that quote `dec850cc…` and `3073f641…` are earlier notes. Those files were not on disk at publish time. The live host-frame log is `796d4e71…`.

Proof audit in the plan snapshot: Canon §3.3 names seven ProofObject fields and no binary layout. T2 has no ProofObject record. `f2a071fe` is a candidate ref in the G2 spear word, not an answer. `ANSWER_PATH_NOT_READY`. `ASTRA_PASS=NO`. `BOARD_PASS=NO`. `PROGRAM_PASS=NO`.
