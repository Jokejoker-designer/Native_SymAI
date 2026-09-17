---
version: "1.1-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:22:00+07:00"
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

R0.1 uses **32-bit fields for semantic references** on the wire. The Arty MVP may
restrict the currently allocated ID range (for example to 24 significant bits),
but unused upper bits must be zero and checked.

This avoids making a 24-bit Arty implementation limit into a permanent semantic
identity law. Any future incompatible widening or reinterpretation requires an ABI
major-version change.

## 4.3 QueryRecord R0.1 — 256 bits / 32 bytes

| Field | Bits | Description |
|---|---:|---|
| magic | 16 | Query record magic |
| abi_version | 8 | ABI version |
| flags | 8 | proof/provenance/inference requirements |
| txn_id | 32 | End-to-end transaction identity |
| generation | 16 | Required active knowledge generation |
| namespace_id | 16 | Semantic namespace |
| query_meta | 16 | query-op, direction, object-valid, max-hops |
| subject_id | 32 | Subject semantic ID |
| relation_id | 16 | Relation ID |
| object_ref | 32 | Object/constraint reference; interpretation from meta |
| context_id | 32 | Context reference |
| search_budget | 16 | Explicit bounded-work budget |
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
| generation | 16 | Knowledge generation used |
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

## 4.6 Knowledge Pack Manifest

The previous draft called a set of fields totaling more than 64 bytes a "64-byte
PackHeader". That arithmetic is invalid. R0.1 replaces it with a **128-byte fixed
manifest header plus a region-descriptor table**.

### 128-byte ManifestHeader candidate

```text
magic                 4 B
manifest_version      2 B
abi_version           2 B
schema_version        2 B
flags                 2 B
generation            4 B
node_count            4 B
edge_count            4 B
value_count           4 B
context_count         4 B
provenance_count      4 B
region_count          4 B
schema_sha256        32 B
content_sha256       32 B
page_size             4 B
header_length         2 B
page_crc_scheme       2 B
manifest_crc32        4 B
reserved             16 B
-------------------------
TOTAL                128 B
```

`RegionDescriptor[]` follows the header and defines typed region offset, size,
record width/count, and integrity metadata for Node/Edge/Value/Context/Provenance,
forward postings, reverse postings, proof/archive data, etc.

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

## Tóm tắt tiếng Việt

ABI R0.1 bổ sung `txn_id`, `generation`, namespace, proof/provenance/conflict refs và
completeness. QueryRecord là 256 bit, StructuredResult 384 bit, SemanticEvent 192 bit.
Pack manifest được sửa thành 128 byte vì header 64 byte cũ sai phép tính. UART dùng
framing nhị phân có seq/CRC; host được phép map alias→ID nhưng không được suy luận ra
answer/proof thay FPGA.
