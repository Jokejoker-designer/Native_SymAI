"""FEM lifecycle + atomic compaction + crash-safety — bit-exact reference model (C-CODE-05).

Spec: 11_FAILURE_EXPERIENCE_MEMORY.md §11.4, §11.6, §11.9, §11.11, §11.12 (unaudited CANDIDATE).
Truth source for rtl/native_ai/memory/fem_lifecycle.v tests.

Single-prototype unit: one typed key, up to N_RAW raw exemplar slots, one prototype record.
Multi-prototype tables are a storage layout question for D; the semantic contract tested here is
the lifecycle machine, the §11.6 commit order and the §11.12.3 recovery classification.

Persistent store ("T2", survives DUT reset) — word-atomic, LEARNING_LOCAL_LAYOUT_CANDIDATE:
  0 HDR    {sar[31:24], frec[23:16], ftot[15:8], reg[7:5], compacted[4], unresolved[3], life[2:0]}
  1 W0     {key[31:16], ftot[15:8], sar[7:0]}
  2 W1     {skill_id[31:24], skill_ver[23:16], 0[15:3], reg[2:0]}
  3 CRCW   {MARK=0xA5A5[31:16], crc16(W0||W1)[15:0]}   (crc16 CCITT-FALSE, MSB first over 64 bits)
  4 COMMIT 0xC0117ED0 when committed else 0
  5 INDEX  1 -> prototype authoritative, 0 -> raw authoritative
  6 HDR2   {skill_id[31:24], skill_ver[23:16], key[15:0]}   write-through at first capture / repair
  8..8+N_RAW-1 RAW[i] {0[31:17], valid[16], key[15:0]}

Finding (B0 cut, first TB run): repair_skill_id/version were volatile-only and lost by a cut before
the prototype write, so the re-run prototype differed from the control. §11.5 lists them as prototype
fields; they are therefore made durable at the transition that sets them (HDR2).

Lifecycle (life_state, LOGICAL_STATE_ENCODING_CANDIDATE): 0 RAW 1 CLUSTERED 2 RESOLVED 3 COMPACTED
4 REOPENED 7 NONE. Counters saturate (never wrap).

Ingress law (§11.9): only domain DUT_RUNTIME (0) enters FEM. ENGINEERING_TOOL (1), HOST_INJECT (2),
reserved (3) are counted in ingress_rejected and never touch state or T2.

Compaction (§11.6) order with boundary markers B0..B6:
  B0 accepted | write W0,W1,CRCW -> B1 | read+verify CRC -> B2 | write COMMIT -> B3 | write INDEX=1 -> B4
  | retire RAW[0] -> B5 | retire remaining -> B6 | write HDR(COMPACTED)
Recovery (§11.12.3) compaction class, exactly THREE states: COMMIT magic AND prototype CRC valid ->
  COMMITTED_NEW (roll forward: index, retire, HDR); else CRCW valid -> CANDIDATE_NEW (policy: discard
  partial prototype, raw authoritative); else -> OLD_VALID.
FEM_DEST_INTEGRITY (separate namespace; A-C-14 / A-D-INTEG-01, NOT a fourth compaction state):
  COMMIT magic AND dest CRC invalid -> dest class COMMITTED_CORRUPT: integrity_fault=1, compaction
  class NOT_APPLICABLE (recover() returns None), NO roll-forward, NO raw retirement, nothing written.
  Status mapping is B-owned (DATA_INTEGRITY_FAIL 0x06 / reason 0x56). Reachable here only by injected
  corruption; models real-media damage (D owns the media integrity contract).
Invariant at every word boundary: raw_present or prototype_committed.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List, Optional

from spear_ref import crc16_bits

N_RAW = 4
CLUSTER_THRESHOLD = 2
N_STABLE = 3

L_RAW, L_CLUSTERED, L_RESOLVED, L_COMPACTED, L_REOPENED, L_NONE = 0, 1, 2, 3, 4, 7
DOM_DUT_RUNTIME, DOM_ENGINEERING_TOOL, DOM_HOST_INJECT = 0, 1, 2
COMMIT_MAGIC = 0xC0117ED0
CRC_MARK = 0xA5A5
A_HDR, A_W0, A_W1, A_CRCW, A_COMMIT, A_INDEX, A_HDR2, A_RAW0 = 0, 1, 2, 3, 4, 5, 6, 8
R_OLD_VALID, R_CANDIDATE_NEW, R_COMMITTED_NEW = 0, 1, 2          # compaction recover class (three)
DEST_OK, DEST_COMMITTED_CORRUPT = 0, 1                            # FEM_DEST_INTEGRITY (separate namespace)
CMP_OK, CMP_NOT_RESOLVED, CMP_UNSTABLE, CMP_RECENT, CMP_CRC_FAIL = 0, 1, 2, 3, 4


def sat_inc(v: int, bits: int) -> int:
    return min(v + 1, (1 << bits) - 1)


def typed_key(domain: int, stage: int, cap: int, macro: int, prim: int, effect: int, ctx: int) -> int:
    """hash(domain, stage, capability_class, macro_action_class, primitive_class, effect_class, context_bucket)."""
    packed = ((domain & 3) << 22 | (stage & 0xF) << 18 | (cap & 0xF) << 14 | (macro & 7) << 11
              | (prim & 0xF) << 7 | (effect & 0xF) << 3 | (ctx & 7))
    return crc16_bits(packed, 24)


class T2:
    """Word-atomic persistent store. write_log records every word write for fault injection."""

    def __init__(self) -> None:
        self.mem: Dict[int, int] = {}

    def rd(self, a: int) -> int:
        return self.mem.get(a, 0)

    def wr(self, a: int, v: int) -> None:
        self.mem[a] = v & 0xFFFFFFFF

    def raw_present(self) -> bool:
        return any((self.rd(A_RAW0 + i) >> 16) & 1 for i in range(N_RAW))

    def committed(self) -> bool:
        return self.rd(A_COMMIT) == COMMIT_MAGIC

    def invariant_ok(self) -> bool:
        # never {raw absent, prototype not committed}; index may point to prototype only if committed
        if not self.raw_present() and not self.committed():
            return False
        if self.rd(A_INDEX) == 1 and not self.committed():
            return False
        return True


class Interrupted(Exception):
    pass


@dataclass
class FEM:
    t2: T2 = field(default_factory=T2)
    life: int = L_NONE
    key: int = 0
    ftot: int = 0
    frec: int = 0
    sar: int = 0
    reg: int = 0
    unresolved: int = 0
    compacted: int = 0
    skill_id: int = 0
    skill_ver: int = 0
    n_raw: int = 0
    ingress_rejected: int = 0
    key_mismatch: int = 0
    exemplar_full: int = 0
    integrity_fault: int = 0   # FEM_DEST_INTEGRITY: 1 = dest COMMITTED_CORRUPT seen by recovery (volatile)
    # fault injection: stop after reaching boundary b (None = run clean)
    stop_at: Optional[int] = None
    boundary: int = -1
    invariant_violations: int = 0

    # ---- persistent header write-through -------------------------------------------------
    def hdr_word(self) -> int:
        return (self.sar << 24 | self.frec << 16 | self.ftot << 8 | self.reg << 5
                | self.compacted << 4 | self.unresolved << 3 | self.life)

    def _wr(self, a: int, v: int) -> None:
        self.t2.wr(a, v)
        if self.life != L_NONE and not self.t2.invariant_ok():
            self.invariant_violations += 1

    def _hdr(self) -> None:
        self._wr(A_HDR, self.hdr_word())

    def _hdr2(self) -> None:
        self._wr(A_HDR2, self.skill_id << 24 | self.skill_ver << 16 | self.key)

    def _mark(self, b: int) -> None:
        self.boundary = b
        if self.stop_at is not None and b == self.stop_at:
            raise Interrupted()

    # ---- ingress ------------------------------------------------------------------------------
    def capture(self, domain: int, stage: int, cap: int, macro: int, prim: int, effect: int, ctx: int) -> bool:
        if domain != DOM_DUT_RUNTIME:
            self.ingress_rejected = sat_inc(self.ingress_rejected, 16)
            return False
        k = typed_key(domain, stage, cap, macro, prim, effect, ctx)
        if self.life == L_NONE:
            self.key = k
            self.life = L_RAW
            self.ftot, self.frec = 1, 1
            self._store_raw(k)
            self._hdr2()
            self._hdr()
            return True
        if k != self.key:
            self.key_mismatch = sat_inc(self.key_mismatch, 16)
            return False
        self.ftot = sat_inc(self.ftot, 8)
        self.frec = sat_inc(self.frec, 8)
        if self.life == L_RAW and self.ftot >= CLUSTER_THRESHOLD:
            self.life = L_CLUSTERED
        elif self.life == L_COMPACTED:
            self.life = L_REOPENED
            self.reg = sat_inc(self.reg, 3)
            self.unresolved = 1
        self._store_raw(k)
        self._hdr()
        return True

    def _store_raw(self, k: int) -> None:
        for i in range(N_RAW):
            if not (self.t2.rd(A_RAW0 + i) >> 16) & 1:
                self._wr(A_RAW0 + i, 1 << 16 | k)
                self.n_raw += 1
                return
        self.exemplar_full = sat_inc(self.exemplar_full, 16)

    def repair_success(self, skill_id: int, skill_ver: int) -> bool:
        if self.life in (L_CLUSTERED, L_REOPENED):
            self.life = L_RESOLVED
            self.skill_id, self.skill_ver = skill_id & 0xFF, skill_ver & 0xFF
            self.unresolved = 0
        elif self.life != L_RESOLVED:
            return False
        self.sar = sat_inc(self.sar, 8)
        self.frec = 0
        self._hdr2()
        self._hdr()
        return True

    # ---- compaction ---------------------------------------------------------------------------
    def cmp_guard(self) -> int:
        if self.life != L_RESOLVED:
            return CMP_NOT_RESOLVED
        if self.sar < N_STABLE:
            return CMP_UNSTABLE
        if self.frec != 0:
            return CMP_RECENT
        return CMP_OK

    def proto_words(self) -> tuple[int, int, int]:
        w0 = self.key << 16 | self.ftot << 8 | self.sar
        w1 = self.skill_id << 24 | self.skill_ver << 16 | self.reg
        crc = crc16_bits(w0 << 32 | w1, 64)
        return w0, w1, CRC_MARK << 16 | crc

    def compact(self) -> int:
        g = self.cmp_guard()
        if g != CMP_OK:
            return g
        self._mark(0)
        w0, w1, cw = self.proto_words()
        self._wr(A_W0, w0); self._wr(A_W1, w1); self._wr(A_CRCW, cw)
        self._mark(1)
        r0, r1, rc = self.t2.rd(A_W0), self.t2.rd(A_W1), self.t2.rd(A_CRCW)
        if rc >> 16 != CRC_MARK or (rc & 0xFFFF) != crc16_bits(r0 << 32 | r1, 64):
            return CMP_CRC_FAIL
        self._mark(2)
        self._wr(A_COMMIT, COMMIT_MAGIC)
        self._mark(3)
        self._wr(A_INDEX, 1)
        self._mark(4)
        self._retire(first_only=True)
        self._mark(5)
        self._retire(first_only=False)
        self._mark(6)
        self.life = L_COMPACTED
        self.compacted = 1
        self._hdr()
        return CMP_OK

    def _retire(self, first_only: bool) -> None:
        for i in range(N_RAW):
            if (self.t2.rd(A_RAW0 + i) >> 16) & 1:
                self._wr(A_RAW0 + i, 0)
                self.n_raw -= 1
                if first_only:
                    return

    # ---- reset + recovery ----------------------------------------------------------------------
    def reset_volatile(self) -> None:
        """DUT reset: all volatile state lost, T2 persists."""
        self.life, self.key, self.ftot, self.frec, self.sar, self.reg = L_NONE, 0, 0, 0, 0, 0
        self.unresolved = self.compacted = self.skill_id = self.skill_ver = 0
        self.n_raw = 0
        self.integrity_fault = 0
        self.stop_at = None

    def recover(self) -> Optional[int]:
        """Returns the compaction recover class (R_OLD_VALID / R_CANDIDATE_NEW / R_COMMITTED_NEW), or None
        when FEM_DEST_INTEGRITY reports dest COMMITTED_CORRUPT (see self.integrity_fault)."""
        t = self.t2
        hdr = t.rd(A_HDR)
        w0, w1, cw = t.rd(A_W0), t.rd(A_W1), t.rd(A_CRCW)
        crc_valid = (cw >> 16) == CRC_MARK and (cw & 0xFFFF) == crc16_bits(w0 << 32 | w1, 64)
        # restore volatile from HDR (write-through header)
        self.life = hdr & 7
        self.unresolved = (hdr >> 3) & 1
        self.compacted = (hdr >> 4) & 1
        self.reg = (hdr >> 5) & 7
        self.ftot = (hdr >> 8) & 0xFF
        self.frec = (hdr >> 16) & 0xFF
        self.sar = (hdr >> 24) & 0xFF
        self.n_raw = sum((t.rd(A_RAW0 + i) >> 16) & 1 for i in range(N_RAW))
        h2 = t.rd(A_HDR2)
        self.key = h2 & 0xFFFF
        self.skill_id, self.skill_ver = (h2 >> 24) & 0xFF, (h2 >> 16) & 0xFF
        if t.committed():
            if not crc_valid:
                # dest COMMITTED_CORRUPT (FEM_DEST_INTEGRITY). Fail closed: nothing written, nothing
                # retired, no roll-forward. Compaction class is NOT_APPLICABLE -> None.
                self.integrity_fault = DEST_COMMITTED_CORRUPT
                return None
            if t.rd(A_INDEX) != 1:
                self._wr(A_INDEX, 1)
            self._retire(first_only=False)
            self.life = L_COMPACTED
            self.compacted = 1
            self._hdr()
            return R_COMMITTED_NEW
        if crc_valid:
            self._wr(A_CRCW, 0)  # discard partial prototype; raw remains authoritative
            return R_CANDIDATE_NEW
        return R_OLD_VALID

    def fem_feat(self) -> int:
        """FEM feature offered to SPEAR/Q* (candidate): failure_total, saturating 8-bit."""
        return self.ftot


# ---------------------------------------------------------------------------------------------
# Scenario shared with the RTL testbench (stimulus is fixed; expectations come from this model)
# ---------------------------------------------------------------------------------------------
STIM = dict(stage=3, cap=5, macro=2, prim=7, effect=4, ctx=1)


def drive_to_resolved(f: FEM) -> None:
    f.capture(DOM_ENGINEERING_TOOL, **STIM)               # Vivado/CI failure -> rejected
    f.capture(DOM_HOST_INJECT, **STIM)                     # host injection -> rejected
    f.capture(DOM_DUT_RUNTIME, **STIM)                     # RAW
    f.capture(DOM_DUT_RUNTIME, **STIM)                     # CLUSTERED (same key, other episode)
    f.capture(DOM_DUT_RUNTIME, **dict(STIM, ctx=6))        # different key -> mismatch observable
    f.repair_success(0x11, 0x01)                           # RESOLVED
    f.repair_success(0x11, 0x01)
    f.repair_success(0x11, 0x01)                           # sar = 3 = N_STABLE


@dataclass
class BoundaryExpect:
    boundary: int
    recover_state: int
    life_after_recover: int
    raw_after_recover: int
    committed_after_recover: bool
    final_life: int
    final_feat: int
    final_raw: int


def run_boundary(b: Optional[int]) -> BoundaryExpect:
    f = FEM()
    drive_to_resolved(f)
    assert f.ingress_rejected == 2 and f.key_mismatch == 1 and f.life == L_RESOLVED and f.n_raw == 2
    f.stop_at = b
    try:
        rc = f.compact()
        assert rc == CMP_OK, rc
        interrupted = False
    except Interrupted:
        interrupted = True
    assert f.invariant_violations == 0
    if not interrupted:  # control
        return BoundaryExpect(-1, -1, f.life, f.n_raw, f.t2.committed(), f.life, f.fem_feat(), f.n_raw)
    proto_ctrl = f.proto_words()  # prototype content that the uninterrupted run would commit
    f.reset_volatile()
    rs = f.recover()
    assert f.invariant_violations == 0
    life_r, raw_r, com_r = f.life, f.n_raw, f.t2.committed()
    if f.life == L_RESOLVED:          # rolled back -> compaction is re-runnable
        assert f.compact() == CMP_OK
    assert f.invariant_violations == 0
    # durable identity/repair fields: the committed prototype must equal the control's
    assert (f.t2.rd(A_W0), f.t2.rd(A_W1), f.t2.rd(A_CRCW)) == proto_ctrl, (b, proto_ctrl)
    return BoundaryExpect(b, rs, life_r, raw_r, com_r, f.life, f.fem_feat(), f.n_raw)


@dataclass
class CorruptExpect:
    cut_boundary: int          # -1 = corrupt after a complete commit
    corrupt_addr: int
    recover_state: Optional[int]   # compaction class; None = NOT_APPLICABLE (RTL holds 0)
    life_after_recover: int
    raw_after_recover: int
    integrity_fault: int           # FEM_DEST_INTEGRITY: DEST_COMMITTED_CORRUPT
    committed_after: bool
    index_after: int


def run_corrupt(cut_b: Optional[int], addr: int, flip: int = 1 << 5) -> CorruptExpect:
    """Commit (fully, or cut at boundary >= B3 so COMMIT is on media), corrupt one prototype word after
    the commit, reset, recover. Expectation: dest COMMITTED_CORRUPT (integrity_fault), compaction class
    N/A, no write, no retirement."""
    f = FEM()
    drive_to_resolved(f)
    f.stop_at = cut_b
    try:
        rc = f.compact()
        assert rc == CMP_OK, rc
    except Interrupted:
        pass
    assert f.t2.committed()
    snapshot = dict(f.t2.mem)
    f.t2.wr(addr, f.t2.rd(addr) ^ flip)      # media corruption AFTER the commit
    snapshot[addr] = f.t2.rd(addr)
    f.reset_volatile()
    rs = f.recover()
    assert rs is None and f.integrity_fault == DEST_COMMITTED_CORRUPT
    assert dict(f.t2.mem) == snapshot, "recovery must not write on dest COMMITTED_CORRUPT"
    assert f.invariant_violations == 0
    return CorruptExpect(-1 if cut_b is None else cut_b, addr, rs, f.life, f.n_raw, f.integrity_fault,
                         f.t2.committed(), f.t2.rd(A_INDEX))


def self_test() -> None:
    ctrl = run_boundary(None)
    assert ctrl.final_life == L_COMPACTED and ctrl.final_raw == 0 and ctrl.committed_after_recover
    for b in range(7):
        e = run_boundary(b)
        exp_rs = R_OLD_VALID if b == 0 else R_CANDIDATE_NEW if b in (1, 2) else R_COMMITTED_NEW
        assert e.recover_state == exp_rs, (b, e)
        assert e.final_life == L_COMPACTED and e.final_raw == 0 and e.final_feat == ctrl.final_feat, (b, e)
        if exp_rs != R_COMMITTED_NEW:
            assert e.life_after_recover == L_RESOLVED and e.raw_after_recover == 2 and not e.committed_after_recover
        else:
            assert e.life_after_recover == L_COMPACTED and e.raw_after_recover == 0 and e.committed_after_recover
    # dest COMMITTED_CORRUPT (FEM_DEST_INTEGRITY): COMMIT magic present, prototype CRC broken after the commit
    c1 = run_corrupt(None, A_W1)            # after full compaction: raw already retired
    assert c1.life_after_recover == L_COMPACTED and c1.raw_after_recover == 0 and c1.committed_after
    c2 = run_corrupt(4, A_W0)               # cut at B4: raw still present -> must NOT be retired
    assert c2.life_after_recover == L_RESOLVED and c2.raw_after_recover == 2 and c2.index_after == 1
    c3 = run_corrupt(3, A_CRCW, flip=1)     # cut at B3: index still -> raw
    assert c3.raw_after_recover == 2 and c3.index_after == 0
    # a clean recover afterwards (no corruption) is unaffected: integrity_fault is volatile
    f = FEM(); drive_to_resolved(f); assert f.compact() == CMP_OK
    f.reset_volatile(); assert f.recover() == R_COMMITTED_NEW and f.integrity_fault == 0
    # reopen + regression + no mutation of evidence counters
    f = FEM()
    drive_to_resolved(f)
    f.compact()
    assert f.life == L_COMPACTED
    f.capture(DOM_DUT_RUNTIME, **STIM)
    assert f.life == L_REOPENED and f.reg == 1 and f.unresolved == 1 and f.ftot == 3 and f.n_raw == 1
    f.repair_success(0x11, 0x02)
    assert f.life == L_RESOLVED and f.sar == 4
    # compaction guards
    g = FEM(); g.capture(DOM_DUT_RUNTIME, **STIM)
    assert g.compact() == CMP_NOT_RESOLVED
    g.capture(DOM_DUT_RUNTIME, **STIM); g.repair_success(1, 1)
    assert g.compact() == CMP_UNSTABLE
    g.repair_success(1, 1); g.repair_success(1, 1); g.capture(DOM_DUT_RUNTIME, **STIM)  # frec=1, life stays RESOLVED
    assert g.life == L_RESOLVED and g.compact() == CMP_RECENT
    # saturation, exemplar full
    h = FEM()
    for _ in range(300):
        h.capture(DOM_DUT_RUNTIME, **STIM)
    assert h.ftot == 255 and h.frec == 255 and h.n_raw == N_RAW and h.exemplar_full == 300 - N_RAW
    print("FEM_REF_SELFTEST_PASS")


if __name__ == "__main__":
    self_test()
