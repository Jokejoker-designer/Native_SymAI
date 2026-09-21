#!/usr/bin/env python3
from pathlib import Path
import hashlib, json, sys

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT / "BENCHMARK_MANIFEST.json").read_text(encoding="utf-8"))

required = [
    "00_README.md",
    "01_TARGET_CLAIM_AND_LAWS.md",
    "02_ACCEPTANCE_LADDER_R2.md",
    "03_GATE_MATRIX.csv",
    "04_RUNTIME_KNOWLEDGE_BINDING.md",
    "05_FE256_COMMON_RUNTIME.md",
    "06_NSPF_X0_FALSIFICATION.md",
    "07_DEVELOPMENTAL_LEARNING_AND_ACTION.md",
    "08_CURRENT_STATUS_20260921.md",
    "09_MIGRATION_FROM_FE256_R1.md",
    "cases/runtime_binding_cases.jsonl",
    "cases/nspf_x0_cases.jsonl",
    "cases/developmental_cases.jsonl",
]

missing = [p for p in required if not (ROOT / p).exists()]
if missing:
    print("FAIL missing:", *missing, sep="\n  ")
    sys.exit(2)

assert manifest["blocking_new_gate"] == "L1_RUNTIME_KNOWLEDGE_BINDING"
assert "FE256" in manifest["fe256_policy"]

print("BENCHMARK_R2_PACKAGE_SELF_CHECK = PASS")
print("version =", manifest["version"])
print("repo_head_observed =", manifest["repo_head_observed"])
print("blocking_new_gate =", manifest["blocking_new_gate"])
