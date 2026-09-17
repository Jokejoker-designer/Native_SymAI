# Original User Request

## 2026-09-15T17:31:01Z

Restructure, audit, rewrite, and scientifically reorganize the entire Native AI CANON_BLUEPRINT repository. The current workspace contains ~24 documents (MD/DOCX), 2 sub-packages, and 3 ZIP archives with significant duplication, outdated claims, formatting inconsistencies, and content that conflicts with the locked PROJECT GOAL. The deliverable is a clean, production-grade blueprint repository aligned to the locked GOAL, plus a Python-based parallel-agent coordination infrastructure (file-based mailbox, resource lock manager, change notification bot) with seed prompts for 4 parallel chat sessions.

Working directory: D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT

Integrity mode: development

## Context: Locked PROJECT GOAL (North Star)

The locked GOAL states:

> Native AI aims to create an FPGA/SoC-native, evidence-governed cognitive substrate in which explicit semantic information is represented as stable typed objects, typed relations and temporal events rather than existing primarily as implicit distributed knowledge inside learned weights.

Key invariants from the GOAL:
- FACT ≠ SKILL ≠ EPISODE ≠ FAILURE ≠ WEIGHT
- ALIAS ≠ IDENTITY; KIND ≠ ROLE; CANDIDATE ≠ VERIFIED
- CORRELATION ≠ CAUSATION; UTILITY ≠ TRUTH; CACHE_HOTNESS ≠ PROOF
- T0 = Immutable Semantic Control Plane; T1 = Hot Cognitive Working Store; T2 = Canonical Cognitive Memory
- Placement never changes epistemic class
- ASTRA is the deterministic authority for legality, proof, provenance, conflict, completeness, epistemic status and knowledge promotion
- Q* selects bounded macro strategy; SPEAR ranks legal candidates
- Human language is an adapter, not the native cognitive substrate
- Teacher input creates CANDIDATE, never directly creates FACT
- Required falsification: ID permutation, unseen-instance transfer, masked-slot, causal ablation, sensor grounding, reset/restore, teacher authority attack, clock-rate invariance, event-jitter robustness, cache-on/off equivalence

Overclaims explicitly forbidden by the GOAL:
- No "reasoning in nanoseconds" (unproven)
- No "100% accuracy" (only preregistered finite benchmarks can claim 100%)
- No "never lies" (unprovable)
- No "perfectly simulates biological cognition" (no basis)
- No "800,000 nodes in DDR" (not yet built/loaded)
- No "LUT finds intersection of thousands of branches in one clock" (no resource/timing evidence)
- No "R0 has perfectly frozen theory" (R0 is research blueprint)

Hardware facts locked:
- Target: Arty A7-100T / XC7A100T-CSG324-1
- DDR3L: 256 MB, 16-bit bus, 333 MHz → 667 MT/s → peak 1.334 GB/s (≈1.24 GiB/s)
- BRAM: 4,860 Kb = 135 BRAM36 ≈ 607.5 KiB
- LUT: 63,400

## Current Workspace Problems Identified

1. **Massive duplication**: `MASTER_BLUEPRINT.md` (73KB) is a concatenation of files 00–09, duplicating their content. The NSPF narrative paper (72KB) overlaps heavily with R0 blueprint (42KB).
2. **Three overlapping sub-packages**: Root files (00–09), `NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` (19 files), `NATIVE_AI_NATIVE_INFORMATION_FABRIC_R1/` (20 files) — unclear what is canonical.
3. **Dual format files**: Files 00–03 exist as both .docx and .md — redundant.
4. **Naming inconsistencies**: `09 MEMORY_ARCHITECTURE (Truth-Mode Update) .md` has spaces and parentheses.
5. **Outdated/conflicting claims**: Some files contain overclaims forbidden by the locked GOAL (e.g., DDR bandwidth numbers, LUT parallelism claims).
6. **No clear primary/secondary research distinction**: All documents are at the same level with no hierarchy.
7. **ZIP archives**: 3 ZIP files (92KB + 28KB + 22KB) duplicate content already present.
8. **Mixed languages**: Some files in Vietnamese, some in English, no consistent policy.

## Requirements

### R1. Full Audit and Rewrite

Audit every existing document against the locked PROJECT GOAL. For each document:
- Identify claims that conflict with the GOAL (overclaims, wrong numbers, outdated concepts)
- Identify content duplicated across multiple files
- Identify content that is outdated or superseded by later documents
- Rewrite into clean, production-grade English documents with Vietnamese summary cheat-sheets
- Archive all original files into `_ARCHIVE/` subdirectory before any modifications
- Remove all .docx duplicates (keep .md only)
- Fix all file naming to use consistent `XX_SNAKE_CASE.md` format

### R2. Scientific Reorganization

Reorganize documents into a clear hierarchy distinguishing:
- **PRIMARY RESEARCH** (must-implement, on critical path): Core architecture, memory stratification, ABI/protocol, ASTRA authority, acceptance ladder
- **SECONDARY RESEARCH** (important but can follow): Learning/Q*/SPEAR, skill memory, sensor grounding, teacher protocol, sleep/consolidation
- **REFERENCE** (supporting material): Prior art, glossary, risk register, historical mapping
- **OPERATIONAL** (process/workflow): Milestone roadmap, verification matrix, implementation prompts, change control

Create a new `00_INDEX.md` that maps every document to its category and shows dependencies. Create a `READING_ORDER.md` that tells a new agent/reader which documents to read first.

### R3. Parallel Agent Coordination Infrastructure

Build a Python-based coordination system for 4 parallel chat sessions working on the project simultaneously. The system must include:

1. **File-based Mailbox** (`_COORDINATION/mailbox/`): Each agent has an inbox. Messages are JSON files with sender, timestamp, priority, subject, body. Agents poll their inbox on startup and periodically.

2. **Resource Lock Manager** (`_COORDINATION/locks/`): Lock files for shared resources:
   - `vivado_synthesis.lock` — who is running synthesis (multiple allowed)
   - `vivado_implementation.lock` — who is running P&R
   - `board_program.lock` — EXCLUSIVE lock for board programming (only one at a time)
   - `uart_port.lock` — EXCLUSIVE lock for UART communication
   Each lock file contains: agent_id, timestamp, action, expected_duration

3. **Change Notification Bot** (`_COORDINATION/changebot.py`): Python script that:
   - Watches `CANON_BLUEPRINT/` for file changes using filesystem polling (no external deps)
   - When a file changes, writes a notification to ALL other agents' inboxes
   - Includes: changed file path, change type (create/modify/delete), timestamp, diff summary
   - Logs all changes to `_COORDINATION/changelog.md`

4. **Agent Registry** (`_COORDINATION/registry.json`): Lists all active agents, their roles, current task, status (active/idle/blocked), and which resources they hold.

5. **Startup Script** (`_COORDINATION/agent_startup.py`): Script each agent must run at session start. It:
   - Registers the agent in registry
   - Checks inbox for pending messages
   - Checks locks for resource conflicts
   - Prints summary of project state and any blocking issues

### R4. Agent Seed Prompts

Create 4 seed prompt files, one per parallel agent, with clear role definitions:

**Agent A — Architecture & Core Documentation Lead**
- Rewrites: 00_INDEX, 01_MASTER_ARCHITECTURE, 02_MEMORY, 32_R2_ARCHITECTURE
- Creates: READING_ORDER, GOAL_LOCK reference
- Scope: Primary research documents, T0/T1/T2 stratification, end-state architecture diagram

**Agent B — Verification & Evidence Lead**
- Rewrites: 07_VERIFICATION, FE256 benchmark suite, acceptance ladder
- Creates: Updated test matrix, causal test specifications
- Scope: All falsification experiments, acceptance criteria, benchmark protocols

**Agent C — Learning & Cognitive Systems Lead**
- Rewrites: 03_ALGORITHMS, 04_FAILURE_MEMORY, 05_SKILL_AND_TEACHING
- Creates: Q*/SPEAR/FEM/Skill integration doc, teacher protocol spec
- Scope: Secondary research documents, learning pipeline, developmental pathway

**Agent D — Implementation & Operations Lead**
- Rewrites: 06_MILESTONES, 08_RTL_RISK, 09_IMPLEMENTATION_START
- Creates: Updated roadmap, resource budget, RTL module dependency map
- Scope: Operational documents, Vivado workflow, board test protocols

Each seed prompt must include:
- The locked GOAL (full text)
- The agent's specific document scope (which files to read/write)
- Files that are READ-ONLY for this agent (owned by another agent)
- Instructions to run `agent_startup.py` before starting work
- Instructions to check inbox and respect resource locks
- The coordination protocol (how to notify others of changes)
- Clear boundaries: what this agent MUST NOT modify

### R5. Convergence Safety

Design the file organization so that 4 agents working in parallel cannot structurally conflict:
- Each document has exactly ONE owner agent
- Cross-references use stable document IDs (e.g., `[§01.3]`) not file paths
- A `_COORDINATION/schema_lock.json` defines the document tree structure — agents can add content within their owned documents but cannot rename, move, or delete documents owned by others
- The `00_INDEX.md` is owned by Agent A but includes a machine-readable section that other agents can append to (their own entries only)
- Version stamps in each document header: `version: X.Y`, `owner: AGENT_X`, `last_modified: ISO_TIMESTAMP`

## Acceptance Criteria

### Document Quality
- [ ] All original files are preserved in `_ARCHIVE/` with original names
- [ ] Every rewritten document passes a check: no overclaims forbidden by the GOAL appear anywhere
- [ ] Every rewritten document has consistent format: YAML frontmatter (version, owner, status), English body, Vietnamese summary section at end
- [ ] No duplicate .docx/.md pairs remain in the active directory
- [ ] All file names follow `XX_SNAKE_CASE.md` convention
- [ ] `00_INDEX.md` exists and maps every document to its category (PRIMARY/SECONDARY/REFERENCE/OPERATIONAL)
- [ ] `READING_ORDER.md` exists and defines a dependency-ordered reading sequence
- [ ] Hardware numbers (DDR bandwidth, BRAM capacity, LUT count) match the locked values exactly wherever they appear

### Coordination Infrastructure
- [ ] `_COORDINATION/` directory exists with: `mailbox/`, `locks/`, `changebot.py`, `registry.json`, `agent_startup.py`, `schema_lock.json`
- [ ] `changebot.py` runs without external dependencies (stdlib only) and correctly detects file changes in the blueprint directory
- [ ] `agent_startup.py` runs without errors, registers an agent, checks inbox, and prints status summary
- [ ] Lock files use EXCLUSIVE/SHARED semantics correctly: `board_program.lock` and `uart_port.lock` are exclusive; `vivado_synthesis.lock` allows multiple holders
- [ ] Mailbox messages are valid JSON with required fields: sender, timestamp, priority, subject, body

### Seed Prompts
- [ ] 4 seed prompt files exist in `_COORDINATION/prompts/`
- [ ] Each prompt includes the full locked GOAL text
- [ ] Each prompt specifies exactly which documents the agent owns (read-write) and which are read-only
- [ ] Each prompt includes startup instructions (run agent_startup.py, check inbox, check locks)
- [ ] No two agents own the same document
- [ ] Every document in the active directory is owned by exactly one agent

### Convergence Safety
- [ ] `schema_lock.json` defines the complete document tree with ownership
- [ ] Cross-references between documents use stable IDs (§XX.Y format), not file paths
- [ ] Each document header contains version, owner, and last_modified fields
- [ ] A simulated 4-agent parallel edit scenario (Agent A modifies §01, Agent B modifies §07) does not create merge conflicts in any shared file
