# 13 — MIGRATION FROM LANGUAGE-CENTRIC C4G

## 1. Vấn đề hiện tại

C4G cũ phụ thuộc mạnh vào:

- text tokens
- short aliases
- flat S-R-O
- 8/16-bit drift
- model/family collapse
- OID=0 literal hack
- limited output vocabulary

## 2. Migration target

### Step 1 — freeze evidence
Giữ nguyên historical logs/SHA.

### Step 2 — introduce Native Semantic Bus
Structured query bypass parser.

### Step 3 — canonical pack
Node/Edge/Value/Context/Provenance.

### Step 4 — validate direct/reverse/multi-hop via structured queries
Parser chưa tham gia.

### Step 5 — rebuild adapter/parser
Text→same structured query packet.

### Step 6 — structured output
Status + answer ref/value + proof/provenance.

### Step 7 — human rendering
GEMINI/renderer diễn đạt kết quả.

## 3. Không tăng corpus trước khi semantic ABI sạch

More facts không sửa được schema/query mismatch.
