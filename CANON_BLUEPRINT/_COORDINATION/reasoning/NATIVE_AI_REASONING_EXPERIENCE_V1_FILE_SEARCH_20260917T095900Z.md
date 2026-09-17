NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D2025-HDLD-FILENAME-SEARCH / 20260917T095900Z
OWNER_AGENT: FILE_SEARCH_SUBAGENT
CURRENT_CLAIM: D:\2025 contains employee labor-contract files (HDLD / hop dong lao dong / employment contract) discoverable from filename or parent folder names without opening contents.
RUN_PROVENANCE:
  PowerShell Get-ChildItem -LiteralPath D:\2025 -Recurse -Force
  Unicode FormD strip + U+0110/U+0111 -> d; case-insensitive phrase/compact match
  No document contents opened. No files under D:\2025 modified.
  Output: %TEMP%\d2025_labor_search\matching_files.jsonl (147), matching_folders.jsonl (64)
OBSERVATION:
  FACT — Test-Path D:\2025 = True; LastWriteTime 2026-07-18 12:48:05 +07.
  FACT — Top-level 59 directories + 1 file (Bảng Kê QUÝ 3 2025.pdf). GciErrorCount=0.
  FACT — Enumerated FileCountScanned=2144 DirCountScanned=526 in 36s.
  FACT — Keyword matches: 147 files, 64 folders. Hits dominated by hop dong/hopdong.
  FACT — Filename/folder scan for hdld, hdtv, lao dong, thu viec, employment, \bcontract\b, apprenticeship, intern, personnel, \bhr\b: 0 hits.
  FACT — 46 files match nhan vien (site worker registration lists under Báo giá, not Hợp đồng lao động).
  FACT — 1 file LaborLikely=true via substring nhansu inside "xac nhan sua chua" (false positive).
  INFERENCE — Tree is HVAC/construction project archive; "Hợp đồng" folders are commercial installation/sale/maintenance contracts.
  INFERENCE — No employee labor contract is present under the requested name/folder criteria.
HYPOTHESES:
  H1 Labor contracts exist but use only person names / "HD" + person without HDLD keywords. UNTESTED (would need content read; disallowed).
  H2 Labor contracts live outside D:\2025. UNKNOWN.
  H3 Empty Hợp đồng folders (29) once held files that were moved. HYPOTHESIS.
HOW_TRACE:
  exists+top-level UTF-8 listing
  -> recursive Get-ChildItem name+ancestor match
  -> classify labor-strong vs commercial hop dong
  -> second pass related (danh sach, ho so, HD-abbrev, luong)
  -> targeted name regex for HDLD/employment/contract: empty
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Root exists | True | Test-Path / Get-Item | PASS_IMPLEMENTED filesystem
  Recurse complete | 2144 files 526 dirs | summary.json GciErrorCount=0 | PASS_IMPLEMENTED
  HDLD by name | none | targeted name scan 0 hits | PASS_IMPLEMENTED name-only
  Nhan vien lists | 46 files | matching_files.jsonl LaborLikely | PASS_IMPLEMENTED name-only; NOT labor contracts
  Commercial hop dong | 100 files + 64 folders | jsonl Hits hop dong | PASS_IMPLEMENTED name-only
  Contents | not inspected | privacy constraint | UNKNOWN as labor-contract bodies
SUCCESS_VS_FAILURE:
  Success for search: complete name/folder inventory with timestamps/sizes/extensions.
  Failure for "found HDLD": zero files named as labor/employment contracts.
FIRST_DIVERGENCE:
  User keywords include generic "hop dong"/"contract"; tree uses those for construction contracts, not HDLD.
DECISIVE_TEST:
  Recurse name+parent compact/phrase match including hdld, hopdonglaodong, employment, contract: 0 labor-contract names.
ROOT_CAUSE_OR_UNKNOWN:
  FACT: no HDLD-named files in D:\2025. UNKNOWN whether unsigned/scanned contracts exist under unrelated names.
REUSABLE_DECISION_PROCEDURE:
  1) Confirm root. 2) Recurse Get-ChildItem capture ErrorVariable. 3) Normalize Vietnamese then phrase+compact match. 4) Whole-token short keys (HR, HDLD). 5) Split commercial hop dong vs labor-strong. 6) Do not treat "luong" or "nhan su" as substring of khoi luong / xac nhan sua. 7) Never open contents unless authorized.
STRUCTURAL_GUARD:
  Privacy: filename/folder only. Do not read PDF/DOC bodies. Do not write into D:\2025.
BLAST_RADIUS:
  Read-only D:\2025. Temp JSONL under %TEMP%\d2025_labor_search. FPGA RTL untouched.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED name-index of D:\2025. NOT a labor-contract archive finding. No BOARD/XSim relevance.
LESSON_TO_SHARE:
  LESSON_ID FILESEARCH-SUBSTRING-FALSE-POSITIVE-NHANSU-KHOILUONG-20260917T095900Z
NEXT_DECISIVE_EXPERIMENT:
  If owner authorizes content search, OCR/text-extract only files already tagged hop dong PLUS unnamed HD*.pdf; else search other drives for HDLD.
OWNER_AND_STOP_CONDITION:
  Stop when name/folder inventory is complete and permission errors recorded. STOP MET.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
