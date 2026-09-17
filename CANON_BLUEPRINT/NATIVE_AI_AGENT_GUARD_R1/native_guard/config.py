from __future__ import annotations
import pathlib
from .util import load_json

DEFAULT = {
  "project": {"name": "NATIVE_AI", "fpga_part": "xc7a100tcsg324-1"},
  "protected_paths": [
    "PROJECT_GOAL_LOCK.md", "PACKAGE_LOCK.md", "AUTHORITY_PRECEDENCE.md",
    "32_ACCEPTANCE_LADDER.md", "04_ABI_AND_PROTOCOL.md"
  ],
  "hash_globs": ["**/*.sv", "**/*.v", "**/*.vh", "**/*.svh", "**/*.xdc", "**/*.tcl", "**/*.py", "**/*.json", "**/*.md"],
  "exclude_dirs": [".git", ".native_guard", ".Xil", "runs", "build", "__pycache__"],
  "timing": {"wns_min_ns": 0.0, "tns_max_ns": 0.0, "whs_min_ns": 0.0, "ths_max_ns": 0.0, "unconstrained_paths_max": 0},
  "utilization_max_pct": {"LUT": 85.0, "FF": 85.0, "BRAM": 85.0, "DSP": 85.0},
  "critical_log_patterns": [
    "CRITICAL WARNING", "[DRC", "multiple driver", "multi-driven", "unconstrained", "timing constraints are not met",
    "FIFO overflow", "FIFO underflow", "CDC-", "latch inferred", "black box", "route_design failed"
  ],
  "forbidden_gold_paths": ["gold", "benchmark", "acceptance", "vectors"],
  "stages": {
    "audit": [], "xsim": ["audit"], "synth": ["xsim"], "impl": ["synth"], "post_route": ["impl"],
    "program": ["post_route"], "pack_abi": ["program"], "ddr_load": ["pack_abi"], "readback": ["ddr_load"],
    "fe256": ["readback"], "shuffle": ["fe256"], "ablation": ["shuffle"], "uart_e2e": ["ablation"]
  },
  "resource_leases": ["vivado_impl", "jtag", "uart", "board", "canonical_promotion"],
  "allowed_executables": ["vivado", "xvlog", "xelab", "xsim", "python", "python3", "py"]
}


def load_config(root: pathlib.Path, cfg_path: str | None):
    p = root / (cfg_path or "guard_config.json")
    cfg = DEFAULT.copy()
    if p.exists():
        user = load_json(p, {})
        # shallow merge + nested key merges for common sections
        for k, v in user.items():
            if isinstance(v, dict) and isinstance(cfg.get(k), dict):
                z = dict(cfg[k]); z.update(v); cfg[k] = z
            else:
                cfg[k] = v
    return cfg
