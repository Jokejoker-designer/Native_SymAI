NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: FILE-SEARCH-D2026-HDLD
RUN_ID: 20260917T100500Z
OWNER_AGENT: FILE_SEARCH_SUBAGENT
CURRENT_CLAIM: D:\2026 contains employee labor contracts (HDLD / hop dong lao dong / labor/employment contract) discoverable from filename and parent folder names without reading document bodies.
RUN_PROVENANCE:
  Get-ChildItem -LiteralPath D:\2026 -Recurse -Force
  Unicode FormD strip + đ/Đ -> d; match on FullName (all path segments) + Name
  No document content read. No files under D:\2026 modified.
  Machine lists: %TEMP%\d2026_labor_contract_search\matching_files.tsv matching_folders.tsv near_miss.tsv top_level.tsv summary.json
OBSERVATION:
  FACT — Test-Path D:\2026 = True. Directory LastWriteTime 2026-09-17 13:53:48.
  FACT — Recurse enumerated 7759 items: 6024 files, 1735 dirs. PermissionErrorCount=0.
  FACT — Keyword hits: 248 files, 156 folders. Near-miss (HD abbrev / phu luc / numbered HD): 55 files.
  FACT — Strict labor tokens on FullName (hdld, hdtv, thu viec, labor/labour/employment contract, hop dong lao dong, apprentice, intern contract, personnel, employment) count = 0.
  FACT — No path contains HDLD / HĐLĐ / hop dong lao dong / employment contract.
  INFERENCE — Tree is a 2026 HVAC/MEP commercial-project archive with a template subfolder named Hợp đồng under almost every client.
  FACT — Closest HR-like names are site worker lists (nhan vien thi cong, nhan su thi cong) and ATLD (an toan lao dong) templates, not HDLD.
HYPOTHESES:
  H1 Employee HDLD files exist but are named without keywords (scan.pdf, HD-2026-00xx) inside Hợp đồng folders. UNTESTED without content read.
  H2 HDLD is stored outside D:\2026. UNTESTED here.
  H3 Empty Hợp đồng folders are a project-template artifact, not missing HR files. INFERENCE from many dirs with LastWriteTime 2026-07-07 16:39 and no matching files inside.
HOW_TRACE:
  Test-Path + UTF-8 top-level listing
  -> Get-ChildItem recurse (first matcher dropped parent Hợp đồng for files whose names lacked hop dong)
  -> rescan matching Get-Norm(FullName)
  -> strict token pass count=0
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  Root exists | True | PASS_IMPLEMENTED
  Recurse complete | 7759 items, 0 access errors | PASS_IMPLEMENTED
  Strict HDLD name | 0 | PASS_IMPLEMENTED name-index
  Broad hop_dong/contract | 248 files / 156 folders | PASS_IMPLEMENTED name-index
  Content is HDLD | not read | UNKNOWN
SUCCESS_VS_FAILURE:
  Success for inventory: complete name+folder list with times/sizes/ext.
  Failure for the labor-contract claim: no filename or folder token is HDLD/employment-contract.
FIRST_DIVERGENCE:
  hop dong / Hợp đồng folder = commercial installation/purchase/maintenance, not hop dong lao dong.
DECISIVE_TEST:
  Strict FullName regex hdld|hop dong lao dong|employment contract|thu viec = 0 hits. PASS_IMPLEMENTED.
ROOT_CAUSE_OR_UNKNOWN:
  D:\2026 is not an HR filing tree. Remaining UNKNOWN: bodies of generic HD-2026-00xx / scan PDFs.
REUSABLE_DECISION_PROCEDURE:
  1) Enumerate with Get-ChildItem -Recurse -Force -ErrorVariable.
  2) Normalize Unicode; match FullName not only leaf name.
  3) Bucket: STRICT labor tokens vs BROAD hop_dong vs RELATED nhan vien/nhan su/ATLD vs HD-abbrev near-miss.
  4) Do not open bodies unless authorized.
STRUCTURAL_GUARD:
  Word-boundary for HR (do not match Error_log_1hr). Do not score khoi luong as luong. Do not treat hop_dong+nhan_vien site forms as HDLD.
BLAST_RADIUS:
  Search only. D:\2026 unread/unmodified. Temp TSV under %TEMP%\d2026_labor_contract_search.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED filesystem name-index. Content UNKNOWN. Not an HR/HDLD archive by name.
LESSON_TO_SHARE: FILESEARCH-FULLNAME-PARENT-HOPDONG-20260917T100500Z
NEXT_DECISIVE_EXPERIMENT:
  If HDLD still required: search other roots, or owner-authorize content scan of Hợp đồng files whose names are generic HD-2026-00xx.
OWNER_AND_STOP_CONDITION:
  FILE_SEARCH_SUBAGENT. Stop when name/folder inventory + permission errors are reported.
HANDOFF_STATUS: COMPLETE
