#!/usr/bin/env python3
"""Export M2 HotDirectory + posting pages from FE256 store-A. CANDIDATE. PROGRAM=NO."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "fe256"))
from fe256_gold import GENERATION_A, KIND_ENTITY, build_store_a  # noqa: E402

DIR = Path(__file__).resolve().parent


def pack_header(node, gen, rel, count, flags, nxt) -> int:
    w = 0
    w |= node & 0xFFFFFFFF
    w |= (gen & 0xFFFF) << 32
    w |= (rel & 0xFFFF) << 48
    w |= (count & 0xFFFF) << 64
    w |= (flags & 0xFF) << 80
    w |= (nxt & 0xFFFFFFFF) << 96
    return w


def pack_pair(e0, e1) -> int:
    # e = (edge_ref, neighbor)
    w = 0
    w |= e0[0] & 0xFFFFFFFF
    w |= (e0[1] & 0xFFFFFFFF) << 32
    w |= (e1[0] & 0xFFFFFFFF) << 64
    w |= (e1[1] & 0xFFFFFFFF) << 96
    return w


def main() -> int:
    s = build_store_a()
    fwd: dict[int, list] = {}
    rev: dict[int, list] = {}
    nodes = set()
    for e in s.edges:
        eref = e.edge_id * 32
        nodes.add(e.subject)
        nodes.add(e.obj)
        fwd.setdefault(e.subject, []).append((eref, e.obj))
        rev.setdefault(e.obj, []).append((eref, e.subject))

    words: list[int] = []
    # Word 0 reserved so page pointer 0 remains "no page" (not a real T2 addr).
    words.append(0)
    byte_addr = 16
    page_ptr: dict[tuple[int, str], int] = {}

    def emit_page(nid: int, entries: list, flags: int) -> int:
        nonlocal byte_addr
        ptr = byte_addr
        words.append(pack_header(nid, GENERATION_A, 0, len(entries), flags | 0x4, 0))
        byte_addr += 16
        padded = list(entries)
        if len(padded) % 2:
            padded.append((0, 0))
        for i in range(0, len(padded), 2):
            words.append(pack_pair(padded[i], padded[i + 1]))
            byte_addr += 16
        return ptr

    for nid in sorted(nodes):
        fe = fwd.get(nid, [])
        re = rev.get(nid, [])
        page_ptr[(nid, "f")] = emit_page(nid, fe, 0x1) if fe else 0
        page_ptr[(nid, "r")] = emit_page(nid, re, 0x2) if re else 0

    keys = sorted(nodes)
    dlines = []
    elines = []
    for nid in keys:
        fptr = page_ptr.get((nid, "f"), 0)
        rptr = page_ptr.get((nid, "r"), 0)
        dw = 0
        dw |= nid & 0xFFFFFFFF
        dw |= (fptr & 0xFFFFFFFF) << 32
        dw |= (rptr & 0xFFFFFFFF) << 64
        dw |= (GENERATION_A & 0xFFFF) << 96
        dw |= (KIND_ENTITY & 0xFF) << 112
        dw |= 1 << 120
        dlines.append(f"{dw:032x}")
        fe = fwd.get(nid, [])
        re = rev.get(nid, [])
        fn = fe[0][1] if fe else 0
        rn = re[0][1] if re else 0
        elines.append(f"{nid:08x} {len(fe):04x} {fn:08x} {len(re):04x} {rn:08x}")

    (DIR / "dir_a.mem").write_text("\n".join(dlines) + "\n", encoding="ascii")
    (DIR / "post_a.mem").write_text("\n".join(f"{w:032x}" for w in words) + "\n", encoding="ascii")
    (DIR / "dir_keys.hex").write_text("\n".join(f"{k:08x}" for k in keys) + "\n", encoding="ascii")
    (DIR / "post_expect.hex").write_text("\n".join(elines) + "\n", encoding="ascii")
    meta = {
        "n_dir": len(keys),
        "n_post_words": len(words),
        "layout": "HotDirectoryEntry 128b + PostingPageHeader 128b + PostingEntry 64b",
    }
    (DIR / "dir_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"M2_DIR_EXPORT n={len(keys)} post_words={len(words)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
