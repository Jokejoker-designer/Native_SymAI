# 11 — HUMAN LANGUAGE ADAPTER — SEPARATE, NON-BLOCKING CORE GATE

Human text is not the core FE256 input.

After FE256 semantic PASS, an adapter campaign may test:

```text
human text / alias
→ adapter
→ QueryRecord
```

## Adapter parity law

For each adapter test:

```text
QueryRecord(text form A)
== QueryRecord(text form B alias)
== preregistered Tier-K QueryRecord
```

The semantic result must therefore match the structured-query result.

Parser failure is reported as `PARSE_ERROR`; it must not be confused with `UNKNOWN`.

## GEMINI boundary

GEMINI may render a verified Structured Result into natural language. Disable/remove GEMINI and the semantic result must remain available. GEMINI is not part of FE256 truth scoring.
