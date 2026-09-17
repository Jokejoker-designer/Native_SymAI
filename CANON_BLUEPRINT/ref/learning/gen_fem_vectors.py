"""Emit FEM crash-safety expectations from fem_ref.py for tb_fem_lifecycle.v (C-CODE-05).

Layout (32-bit words):
  [0] typed key      [1] W0   [2] W1   [3] CRCW   [4] ingress_rejected   [5] key_mismatch   [6] n_rows
  [7] reopen after capture : life | reg<<4 | unresolved<<8 | ftot<<16 | n_raw<<24
  [8] reopen after repair  : life | sar<<8
  [9..] n_rows x 8 words   : boundary (0xFFFFFFFF = control), recover_state, life_after_recover,
                             raw_after_recover, committed_after_recover, final_life, final_feat, final_raw
  then  [n_corrupt]        : number of dest COMMITTED_CORRUPT rows (C-CODE-07, FEM_DEST_INTEGRITY)
        n_corrupt x 8 words: cut_boundary (0xFFFFFFFF = after full commit), corrupt_addr, flip_mask,
                             recover_state (compaction class; 0 = held/N/A), life_after_recover,
                             raw_after_recover, integrity_fault, index_after
"""
from __future__ import annotations

from pathlib import Path

import fem_ref as F

OUT = Path(__file__).resolve().parents[2] / "tb" / "learning" / "vectors" / "fem" / "fem_expect.hex"


def main() -> None:
    f = F.FEM()
    F.drive_to_resolved(f)
    w0, w1, cw = f.proto_words()
    head = [f.key, w0, w1, cw, f.ingress_rejected, f.key_mismatch, 8]
    # reopen scenario
    g = F.FEM()
    F.drive_to_resolved(g)
    assert g.compact() == F.CMP_OK
    g.capture(F.DOM_DUT_RUNTIME, **F.STIM)
    head.append(g.life | g.reg << 4 | g.unresolved << 8 | g.ftot << 16 | g.n_raw << 24)
    g.repair_success(0x11, 0x02)
    head.append(g.life | g.sar << 8)
    rows = []
    for b in [None] + list(range(7)):
        e = F.run_boundary(b)
        rows += [0xFFFFFFFF if b is None else b, e.recover_state & 0xFFFFFFFF, e.life_after_recover,
                 e.raw_after_recover, int(e.committed_after_recover), e.final_life, e.final_feat, e.final_raw]
    corrupt_cases = [(None, F.A_W1, 1 << 5), (4, F.A_W0, 1 << 5), (3, F.A_CRCW, 1)]
    crows = [len(corrupt_cases)]
    for cut_b, addr, flip in corrupt_cases:
        c = F.run_corrupt(cut_b, addr, flip)
        rs_word = 0 if c.recover_state is None else c.recover_state   # N/A -> RTL holds recover_state at 0
        crows += [0xFFFFFFFF if cut_b is None else cut_b, addr, flip, rs_word, c.life_after_recover,
                  c.raw_after_recover, c.integrity_fault, c.index_after]
    words = head + rows + crows
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(f"{w & 0xFFFFFFFF:08x}" for w in words) + "\n")
    print(f"FEM_VECTORS_WRITTEN {len(words)} words -> {OUT}")


if __name__ == "__main__":
    main()
