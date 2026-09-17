# 09 — ASTRA / GEMINI BOUNDARY

## 1. ASTRA owns

- legality
- proof
- truth/status
- promotion
- conflict handling
- UNKNOWN vs SEARCH_INCOMPLETE distinction

## 2. GEMINI owns

- language proposal
- wording
- explanation generation
- symbol rendering

## 3. Result states

Tối thiểu phải phân biệt:

- ANSWER
- UNKNOWN
- CONFLICT
- SEARCH_INCOMPLETE
- PARSE_ERROR
- UNSUPPORTED_QUERY
- DATA_INTEGRITY_FAIL

Không được dùng `EMPTY` như production semantic outcome.

## 4. Proof trace

Một answer nên truy được về:

`query → candidate path → evidence/provenance → ASTRA status → result`

## 5. Gemini removable principle

Nếu GEMINI bị tháo, lõi reasoning vẫn phải hoạt động bằng structured input/output.
