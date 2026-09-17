---
version: "1.6-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T18:50:00+07:00"
---

# §04 — ABI AND PROTOCOL

> Versioned binary interfaces for Native AI. This document separates semantic
> identity from transport details and preserves transaction/generation lineage.

## 4.1 Design Principles

1. FPGA-side cognition consumes **typed binary records**, not human-language text.
2. The host adapter may resolve aliases/intent into IDs and construct `QueryRecord`.
3. The host must not inject answer, winner, proof, provenance, or hidden graph reasoning.
4. Every externally committed transaction carries transaction identity and generation.
5. Transport retry must be idempotent and must not double-commit learning or pack state.
6. Protocol faults are never converted into semantic `UNKNOWN`.
7. Exact bit widths are ABI-versioned implementation choices, not ontology.

## 4.2 Semantic ID Width Policy

```text
SEMANTIC_ID_WIDTH = 32
ACTIVE_ID_RANGE   = loaded board/knowledge-pack profile property
                    (A-ID-PROFILE-01: active_id_bits / active_id_max)
                    [§02.4.1b] [§20.1]
SEMANTIC_ID_WIDTH ≠ ACTIVE_ID_RANGE
```

R0.1 wire/canonical semantic references are **32-bit fields**. That is
identity ABI, not a profile knob and not a 24-bit type.

`ACTIVE_ID_RANGE` is which 32-bit IDs are legal in this run. Architecture
does **not** freeze the numeric range (including 24).

**Authoritative admit checker** for an ID entering the active runtime
graph: the **T1 directory / materialization admit** against the loaded
profile [§02.4.1b].

**Pack loader** is required **ingress** on the same profile. It is not a
second identity law and not the T1 admit.

**Rejected as identity law:** hard-coded `candidate_ref[31:24]==0`.
High-zero of bits above `ACTIVE_ID_RANGE` is a packing/range check on the
32-bit field, not a new ID width. SPEAR/Q*/walkers MAY re-check the same
loaded profile defensively; that is not semantic-identity definition.

Do not transcribe rejected 24-bit T1 `semantic_id` from nested MASTER
snapshots into this ABI. Any future incompatible widening or
reinterpretation of `SEMANTIC_ID_WIDTH` requires an ABI major-version
change.

## 4.3 QueryRecord R0.1 — 256 bits / 32 bytes

| Field | Bits | Description |
|---|---:|---|
| magic | 16 | Query record magic |
| abi_version | 8 | ABI version |
| flags | 8 | proof/provenance/inference requirements |
| txn_id | 32 | End-to-end transaction identity |
| generation | 16 | `knowledge_generation` — required active semantic generation; **not** `pack_generation` |
| namespace_id | 16 | Semantic namespace |
| query_meta | 16 | query-op, direction, object-valid, max-hops |
| subject_id | 32 | Subject semantic ID |
| relation_id | 16 | Relation ID |
| object_ref | 32 | Object/constraint reference; interpretation from meta |
| context_id | 32 | Context reference |
| search_budget | 16 | Explicit bounded-work budget (walker/posting/frontier). **Not** `K_soft`. **Not** `K_hard`. Derivation/bind: [§04.13] |
| crc16 | 16 | CRC over preceding record fields |
| **Total** | **256** | **32 bytes** |

`query_meta` is an ABI field, not an English grammar field. A candidate packing is:

```text
[15:12] operation class   DIRECT / REVERSE / MULTIHOP / CONSTRAINT / ...
[11:10] direction
[9]     object_valid
[8:5]   max_hops
[4:2]   native query operator (WHAT/WHO/WHERE/WHEN/WHY/WHICH/HOW)
[1:0]   reserved
```

## 4.4 StructuredResult R0.1 — 384 bits / 48 bytes

| Field | Bits | Description |
|---|---:|---|
| magic | 16 | Result record magic |
| abi_version | 8 | ABI version |
| status | 8 | ASTRA epistemic status |
| reason_code | 8 | Machine reason, not prose |
| answer_kind | 8 | NONE / ENTITY / VALUE / RANGE / PROCEDURE / PROOF_PATH |
| completeness | 8 | COMPLETE / PARTIAL / NOT_APPLICABLE |
| flags | 8 | Result flags |
| txn_id | 32 | Exact query transaction identity |
| generation | 16 | `knowledge_generation` used; **not** `pack_generation` |
| namespace_id | 16 | Semantic namespace |
| answer_ref | 32 | Primary answer reference |
| value_lo | 32 | Typed value payload low/scalar |
| value_hi | 32 | Range high/auxiliary payload |
| proof_ref | 32 | Proof object reference |
| provenance_ref | 32 | Provenance root/reference |
| context_ref | 32 | Context used/resolved |
| conflict_ref | 32 | Conflict object/reference |
| answer_count | 8 | Number of answer items in optional payload |
| payload_words | 8 | Optional payload length |
| crc16 | 16 | CRC over fixed header |
| **Total** | **384** | **48 bytes** |

Optional payload records may follow, but the fixed header always preserves the
status/proof/provenance/conflict identity needed by the GOAL.

## 4.5 SemanticEvent R0.1 — 192 bits / 24 bytes

```text
191:184 event_type
183:176 semantic_kind
175:168 role
167:160 flags
159:128 semantic_id
127:96  value_or_ref
95:64   logical_tick
63:32   context_id
31:16   source_id
15:0    sequence_id
```

Logical tick and sequence ID are meaning/order metadata. Physical FPGA cycle count is
performance/debug metadata only.

## 4.6 Knowledge Pack Manifest — locked 128-byte ManifestHeader

The retired 64-byte PackHeader arithmetic was invalid. A listed `reserved=16`
on top of a 116-byte prefix would be **132 bytes**. That interpretation is
**illegal**. R0.1 has exactly one valid header:

```text
ManifestHeader = 128 bytes. Not 64. Not 132.
```

Little-endian. Magic `NAI1` = `0x3149414E`.

| Off | Size | Field |
|---:|---:|---|
| 0 | 4 | `magic` `NAI1` |
| 4 | 2 | `manifest_version` (R0.1 = 1) |
| 6 | 2 | `abi_version` (R0.1 = 1) |
| 8 | 2 | `schema_version` (R0.1 = 1) |
| 10 | 2 | `flags` |
| 12 | 4 | **`pack_generation`** (u32; distinct from 16-bit `knowledge_generation`) |
| 16 | 4 | `node_count` |
| 20 | 4 | `edge_count` |
| 24 | 4 | `value_count` |
| 28 | 4 | `context_count` |
| 32 | 4 | `provenance_count` |
| 36 | 4 | `region_count` |
| 40 | 32 | `schema_sha256` (host identity; FPGA stores, does not compute SHA) |
| 72 | 32 | `content_sha256` (same label rule) |
| 104 | 4 | `page_size` (M1: 256) |
| 108 | 2 | `header_length` **must be 128** |
| 110 | 2 | `page_crc_scheme` = 1 → CRC-32/ISO-HDLC |
| 112 | 4 | `manifest_crc32` over bytes `[0:112)` only |
| 116 | 12 | `reserved` **must be zero** |
| **128** | | **end of header** |

Prefix `[0:112)` is 112 bytes. CRC 4 + reserved 12 = 16. Total 128.
`reserved=16` (132-byte total) is a failed candidate, not an alternate ABI.

BEGIN_PACK payload length must be exactly 128. A 132-byte payload is
`LOAD_REJECT` / `HEADER_LENGTH`. A 64-byte BEGIN payload is `TRUNCATED`.
Big-endian packing of this header is `BAD_MAGIC` (wire magic must be
`4E 41 49 31`), not a second ABI.

LE 32-bit word map:

| Words | Bytes | Contents |
|---|---|---|
| w0 | 0–3 | magic |
| w1 | 4–7 | `{abi_version, manifest_version}` |
| w2 | 8–11 | `{flags, schema_version}` |
| w3 | 12–15 | `pack_generation` |
| w4–w9 | 16–39 | six u32 counts |
| w10–w17 | 40–71 | `schema_sha256` |
| w18–w25 | 72–103 | `content_sha256` |
| w26 | 104–107 | `page_size` |
| w27 | 108–111 | `{page_crc_scheme, header_length}` |
| w28 | 112–115 | `manifest_crc32` |
| w29–w31 | 116–127 | reserved 12 B |

### `pack_generation` vs `knowledge_generation`

| Name | Width | Where | Law |
|---|---:|---|---|
| `pack_generation` | 32 | ManifestHeader offset 12 | Pack/load epoch. Do **not** truncate to 16 bits. |
| `knowledge_generation` | 16 | QueryRecord, StructuredResult, NCG records [§02.4.10] | Active semantic generation used by queries. |

R0.1 legal `pack_generation` is `1..65535`. `0` and `>0xFFFF` are `LOAD_REJECT`
/`UNSUPPORTED` — not silent truncation. After COMMIT, active
`knowledge_generation` equals that legal `pack_generation` value.

### RegionDescriptor — 32 bytes (follows header, `region_count` entries)

| Off | Size | Field |
|---:|---:|---|
| 0 | 1 | `region_id` |
| 1 | 1 | `region_kind` 1 NODE 2 EDGE 3 VALUE 4 CONTEXT 5 PROVENANCE 6 FWD 7 REV 8 SENTINEL |
| 2 | 2 | `flags` |
| 4 | 4 | `ddr_offset` |
| 8 | 4 | `byte_length` |
| 12 | 2 | `record_width` |
| 14 | 2 | `page_count` |
| 16 | 4 | `record_count` |
| 20 | 4 | `region_crc32` CRC-32/ISO-HDLC over region payload |
| 24 | 4 | `sentinel_word` |
| 28 | 4 | `reserved` = 0 |

### Pack-loader reason codes (not ASTRA query status)

| Code | Name | Maps to ASTRA query status? |
|---|---|---|
| 0x00 | OK | no (load path) |
| 0x01 | BAD_MAGIC | never `UNKNOWN` |
| 0x02 | ABI_MISMATCH | never `UNKNOWN` |
| 0x03 | SCHEMA_MISMATCH | never `UNKNOWN` |
| 0x04 | MANIFEST_CRC | never `UNKNOWN` |
| 0x05 | PAGE_CRC | never `UNKNOWN` |
| 0x06 | SEQ_GAP | protocol |
| 0x07 | UNSUPPORTED | never `UNKNOWN` |
| 0x08 | SENTINEL_MISMATCH | never `UNKNOWN` |
| 0x09 | HEADER_LENGTH | never `UNKNOWN` |
| 0x0A | RESERVED_NZ | never `UNKNOWN` |
| 0x0B | REGION_COUNT | never `UNKNOWN` |
| 0x0C | DRAIN_ERR | never `UNKNOWN` |
| 0x0D | CONTENT_MISMATCH | never `UNKNOWN` |
| 0x0E | STALE_PACK_GENERATION | never `UNKNOWN` |
| 0x0F | TRUNCATED | never `UNKNOWN` |

Executable gold: `verification/pack_abi24/pack_abi24_gold.py`.

## 4.7 Integrity Evidence Levels

Do not claim `FPGA_SHA256_VERIFIED` unless SHA-256 is actually implemented and tested
on FPGA. Distinguish:

```text
HOST_SHA256_VERIFIED
FPGA_MANIFEST_ID_VERIFIED
FPGA_PAGE_CRC_VERIFIED
FPGA_SENTINEL_READBACK_VERIFIED
```

A host-verified SHA plus FPGA page CRC/readback is valid evidence if labeled honestly.

## 4.8 Runtime Pack Transaction

```text
HELLO/CAPABILITIES
  -> BEGIN_PACK(manifest)
  -> ABI/schema/generation precheck
  -> DATA_PAGE(seq, region, offset, payload, CRC)
  -> page ACK/NAK
  -> END_PACK
  -> write-drain complete
  -> sentinel readback
  -> integrity verification
  -> COMMIT_GENERATION
  -> atomic active-generation flip
```

`ACK_LOAD` is forbidden until all accepted writes have drained to the memory
controller completion point defined by the implementation contract.

## 4.9 UART Transport R0.1

Laboratory baseline may use 115200-8-N-1. Baud rate is a transport parameter and may
change without semantic change.

Recommended frame:

```text
[SOF16] [PROTO_VER8] [FRAME_TYPE8] [LENGTH16] [SEQ16]
[PAYLOAD N bytes]
[CRC16]
```

Length and CRC make a dedicated EOF byte unnecessary. The transport uses explicit
ACK/NAK/sequence handling and host pacing. Do not assume RTS/CTS wiring or XON/XOFF
support unless separately verified for the board path.

Timeouts are operation-specific. A transport timeout is a protocol/transport failure,
not semantic `UNKNOWN`.

## 4.10 Human-Language Boundary

Current architecture decision:

```text
Human text
 -> Host Adapter
 -> frozen/preregistered alias + intent mapping
 -> QueryRecord IDs/codes
 -> UART
 -> FPGA
 -> StructuredResult
 -> Host Renderer
 -> Human text
```

Allowed host work:
- tokenization/parsing;
- alias lookup;
- unit normalization;
- query-operator and direction resolution;
- `QueryRecord` construction;
- result rendering.

Forbidden host work:
- answer lookup;
- graph traversal to choose the winner;
- proof construction;
- provenance fabrication;
- benchmark answer injection.

## 4.11 Protocol Faults

Examples:

```text
CRC_ERROR
SEQ_GAP
DUPLICATE_FRAME
STALE_GENERATION
UNSUPPORTED_ABI
FIFO_OVERFLOW
TRANSPORT_TIMEOUT
```

These are protocol/system outcomes and must not be silently mapped to `UNKNOWN`.

## 4.12 R0.1 locked numeric encodings (FE256 gold)

These values are frozen for FE256 gold / XSim compare. They are **not** the
historical C3 4-bit UART nibble map. `0x00` is not a legal ASTRA `status`
(uninitialized-buffer detect). Wire endianness is **little-endian**. Record CRC
is CRC16-CCITT-FALSE (poly `0x1021`, init `0xFFFF`, xorout `0`), covering the
bytes before the CRC field.

| Symbol | Width | Value |
|---|---:|---|
| QueryRecord magic | 16 | `0x4E51` (`NQ`) |
| StructuredResult magic | 16 | `0x4E52` (`NR`) |
| `abi_version` | 8 | `0x01` |
| `ANSWER` | 8 | `0x01` |
| `UNKNOWN` | 8 | `0x02` |
| `CONFLICT` | 8 | `0x03` |
| `SEARCH_INCOMPLETE` | 8 | `0x04` |
| `UNSUPPORTED_QUERY` | 8 | `0x05` |
| `DATA_INTEGRITY_FAIL` | 8 | `0x06` |
| `PARSE_ERROR` (adapter only) | 8 | `0x80` |

This table is the **only** primary ASTRA `status` namespace. FPGA may emit
`0x01`–`0x06` only. `0x00` is illegal on the wire (uninitialized/protocol
fault). `0x80` is adapter-only. No other byte is a lawful `status`.

`answer_kind`: `NONE=0x00`, `ENTITY=0x01`, `VALUE=0x02`, `RANGE=0x03`,
`PROCEDURE=0x04`, `PROOF_PATH=0x05`.

`completeness`: `NOT_APPLICABLE=0x00`, `COMPLETE=0x01`, `PARTIAL=0x02`.

Query `flags`: bit0 proof-required, bit1 provenance-required, bit2 inference-allowed.

`reason_code` is a **separate** namespace (substatus), never a substitute
primary status byte. Selected values: `NONE=0x00` (absent reason only; **not**
CONFLICT and **not** a lawful `status`), `VERIFIED_SUPPORT=0x01` (reason field
only; numeric overlap with status `ANSWER` does not merge the namespaces),
`NO_VERIFIED_SUPPORT=0x10`, `CANDIDATE_ONLY=0x11`,
`CONTEXT_INCOMPATIBLE=0x13`, `BUDGET_EXHAUSTED=0x20`, `TIE_OVERFLOW=0x22`,
`K_INVALID=0x23`, `DISTINCT_VERIFIED_REFS=0x30`, `OPERATOR_UNIMPLEMENTED=0x40`, `DIRECTION_ILLEGAL=0x41`,
`PACK_CRC=0x50`, `STALE_GENERATION=0x54`, `INVALID_DESCRIPTOR=0x55`,
`COMMITTED_CORRUPT=0x56`, `PROVENANCE_MISSING=0x61`.

`TIE_OVERFLOW` `0x22`, `K_INVALID` `0x23`, `INVALID_DESCRIPTOR` `0x55`, and
`COMMITTED_CORRUPT` `0x56` are `reason_code` only.
FPGA must not emit `status∈{0x00,0x22,0x23,0x55,0x56,0x80}`. Lawful pairings:
`SEARCH_INCOMPLETE` `0x04` + `TIE_OVERFLOW` `0x22`; `DATA_INTEGRITY_FAIL`
`0x06` + `INVALID_DESCRIPTOR` `0x55`; `DATA_INTEGRITY_FAIL` `0x06` +
`K_INVALID` `0x23`; `DATA_INTEGRITY_FAIL` `0x06` + `COMMITTED_CORRUPT` `0x56`.

Host `StructuredResult.status==0x00` is an uninitialized/protocol fault, never
`UNKNOWN` and never `CONFLICT`. Pack-loader `OK=0x00` is a **load** reason, not
an ASTRA status.

`query_meta[15:12]` operation class: `DIRECT=0`, `REVERSE=1`, `MULTIHOP=2`,
`VALUE=3`, `CONSTRAINT=4`, `IDENTITY=5`, `PROVENANCE=6`, `CONTEXT=7`,
`UNSUPPORTED=15`. Direction `[11:10]`: `FWD=0`, `REV=1`.

Semantic IDs and T2 pointers on this ABI are **32-bit**
(`SEMANTIC_ID_WIDTH = 32`). Do not transcribe the rejected 24-bit T1
`semantic_id` from nested MASTER snapshots. High-zero above
`ACTIVE_ID_RANGE` is a loaded-profile range/packing check, not a 24-bit
identity type. Admit is T1 directory; pack loader is ingress [§04.2]
[§02.4.1b]. Hard-coded `candidate_ref[31:24]==0` is rejected as identity
law.

Executable packers:
- FE256: `verification/fe256/fe256_gold.py`
- Pack/ABI-24: `verification/pack_abi24/pack_abi24_gold.py`
- ASTRA Q-eval adversarial: `verification/astra_adv/astra_adv_gold.py`
- ASTRA Q-eval XSim harness (PROGRAM=NO, fail-closed): `verification/astra_adv/tb_astra_adv_xsim_compare.sv`

## 4.13 Runtime-law bind (B-RUNTIME-LAW-01)

Not a second status namespace. Action-lane objects
(`ACTION_INTENT`, `ActionResolution`, `CapabilityBinding`,
`PrimitiveCommand`, `ObservedEffect`) remain **off** the Query/Result/
`SemanticEvent` UART unless a later ABI revision adds distinct records
[§01.7] [§05.1]. They are not QueryRecord / StructuredResult /
SemanticEvent. Action-precheck verdicts (`ASTRA_DENY`, `SAFETY_VETO`,
`STALE_DESCRIPTOR`, `NO_BINDING`, `BOUND`) must not reuse query
`0x01–0x06` [§03.12] [§20.5.1].

### Reward causal identity

Learner credit uses the existing action-lane tuple, not a new wire field:

```text
(episode_id, step_id, command_id, generation)
```

`reward_accepted` is asserted only by the action-lane Reward Gate [§03.10].
It is not `StructuredResult.status`. Same causal key → at most one learner
update. Exactly one outstanding Q* pending proposal is allowed.

These objects are not Query/Result/SemanticEvent records [§04.5].

### `search_budget` → `K_soft`

`K_soft` is **not** packed in QueryRecord. C derives it at SPEAR bind from
`search_budget`. The numeric formula is **not frozen** (immature). B owns
the validation law; C owns the derivation implementation. Validation is at
SPEAR bind, before ranking. `search_budget=0` is Q-INC-BUDGET, not
`k_invalid`. Illegal bind → C `k_invalid=1` → ASTRA `DATA_INTEGRITY_FAIL`
/ `K_INVALID` `0x23` / `completeness=NOT_APPLICABLE` [§03.9.2].

### `K_hard` source

`K_hard` is the SPEAR/Top-K candidate-slot capacity on the **same loaded
board/knowledge-pack profile** as `ACTIVE_ID_RANGE` (A
`K_HARD_PROFILE_OWNER`). D implements/wires it. C consumes it. A does not
freeze the integer. It is not an ASTRA status and not a QueryRecord field.

## Tóm tắt tiếng Việt

ABI R0.1 bổ sung `txn_id`, `generation`, namespace, proof/provenance/conflict refs và
completeness. `SEMANTIC_ID_WIDTH = 32`; `ACTIVE_ID_RANGE` lấy từ profile đã nạp
(`active_id_bits` / `active_id_max`); T1 directory là admit; pack loader là ingress,
không phải luật identity thứ hai; cấm `candidate_ref[31:24]==0` như luật identity.
QueryRecord là 256 bit, StructuredResult 384 bit, SemanticEvent 192 bit.
Object action-lane không phải Query/Result/SemanticEvent. ManifestHeader **khóa 128 byte** (reserved 12, CRC `[0:112)`); 132 byte là ABI sai;
64-byte BEGIN là TRUNCATED. `pack_generation` u32 ≠ `knowledge_generation` u16; cấm cắt 32→16.
CONFLICT reason = `0x30` (`DISTINCT_VERIFIED_REFS`); status `0x00` bất hợp pháp.
`0x22`/`0x23`/`0x55`/`0x56` là reason, không phải status. `K_soft` không nằm trên QueryRecord; `K_hard` lấy từ profile đã nạp. Reward identity = `episode_id/step_id/command_id/generation`. Gold Pack/ABI-24: `verification/pack_abi24/pack_abi24_gold.py` (candidate; chưa phải PACK_ABI_24_24_PASS).
UART dùng framing nhị phân có seq/CRC; host được phép map alias→ID nhưng không được suy luận ra
answer/proof thay FPGA. §04.12 khóa magic `0x4E51/0x4E52`, **một** namespace status `0x01–0x06`, CRC16-CCITT-FALSE, little-endian.
