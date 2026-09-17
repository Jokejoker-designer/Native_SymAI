#!/usr/bin/env python3
"""ASTRA adv Q-eval gold tests. Stdlib + the gold module only."""

from __future__ import annotations

import ast
import importlib.util
import json
import struct
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("astra_adv_gold", ROOT / "astra_adv_gold.py")
mod = importlib.util.module_from_spec(SPEC)
sys.modules["astra_adv_gold"] = mod
SPEC.loader.exec_module(mod)


class AstraAdvGoldTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.case_list = mod.build_cases()
        cls.cases = {c.case_id: c for c in cls.case_list}

    def test_selfcheck(self):
        self.assertEqual(mod.selfcheck(self.case_list), [])

    def test_does_not_import_pack_vectors_or_fe256(self):
        self.assertNotIn("pack_vectors", sys.modules)
        src = (ROOT / "astra_adv_gold.py").read_text(encoding="utf-8")
        tree = ast.parse(src)
        imported = []
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                imported.extend(a.name for a in node.names)
            elif isinstance(node, ast.ImportFrom):
                imported.append(node.module or "")
        self.assertFalse(any("pack_vectors" in n or "fe256_gold" in n for n in imported))

    def test_magics_locked(self):
        self.assertEqual(mod.MAGIC_QUERY, 0x4E51)
        self.assertEqual(mod.MAGIC_RESULT, 0x4E52)

    def test_locked_prefix_not_shrunk(self):
        self.assertEqual(list(mod.LOCKED_CASE_IDS[:11]), list(mod.LOCKED_PREFIX_11))
        self.assertEqual(list(mod.LOCKED_CASE_IDS[:17]), list(mod.LOCKED_PREFIX_17))
        self.assertGreaterEqual(len(mod.LOCKED_CASE_IDS), 17)
        self.assertEqual(
            [c.case_id for c in self.case_list[:17]],
            [
                "AA-ILLEGAL-00",
                "AA-NS-ST22",
                "AA-NS-ST55",
                "AA-TIE-01",
                "AA-DESC-01",
                "AA-ANS-PROOF0",
                "AA-INC-BUDGET",
                "AA-UNK-ABSENT",
                "AA-CONFLICT-01",
                "AA-ANS-DIAMOND",
                "AA-CAND-01",
                "AA-NS-ST80",
                "AA-TXN-ECHO",
                "AA-QTRUNC-01",
                "AA-QCRC-01",
                "AA-STALE-GEN",
                "AA-PROTO-01",
            ],
        )
        self.assertEqual(
            [c.case_id for c in self.case_list[17:]],
            ["AA-REW-DUP", "AA-REW-ID", "AA-KINV-01", "AA-FEM-CRC"],
        )

    def test_reason_bytes_are_not_status(self):
        self.assertNotIn(mod.RC_TIE_OVERFLOW, mod.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(mod.RC_INVALID_DESCRIPTOR, mod.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(mod.RC_K_INVALID, mod.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(mod.RC_COMMITTED_CORRUPT, mod.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(mod.RC_TIE_OVERFLOW, mod.STATUS_NAME)
        self.assertNotIn(mod.RC_INVALID_DESCRIPTOR, mod.STATUS_NAME)
        self.assertEqual(mod.classify_status(0x22), "ILLEGAL_STATUS_REASON_COLLISION")
        self.assertEqual(mod.classify_status(0x55), "ILLEGAL_STATUS_REASON_COLLISION")
        self.assertEqual(mod.classify_status(0x23), "ILLEGAL_STATUS_REASON_COLLISION")
        self.assertEqual(mod.classify_status(0x56), "ILLEGAL_STATUS_REASON_COLLISION")
        self.assertFalse(mod.status_namespace_ok(0x22))
        self.assertFalse(mod.status_namespace_ok(0x55))
        self.assertFalse(mod.status_namespace_ok(0x23))
        self.assertFalse(mod.status_namespace_ok(0x56))

    def test_illegal_status_zero(self):
        self.assertEqual(mod.classify_status(0x00), "PROTOCOL_FAULT")
        self.assertEqual(self.cases["AA-ILLEGAL-00"].expect_class, "PROTOCOL_FAULT")

    def test_fpga_illegal_status_namespace(self):
        for st in (0x00, 0x22, 0x23, 0x55, 0x56, 0x80):
            self.assertFalse(mod.status_namespace_ok(st), hex(st))
            self.assertIn(st, mod.ILLEGAL_FPGA_STATUS)
        self.assertEqual(mod.classify_status(0x80), "ADAPTER_ONLY")
        self.assertEqual(self.cases["AA-NS-ST80"].expect_class, "ADAPTER_ONLY")

    def test_tie_overflow_reason_not_status(self):
        r = self.cases["AA-TIE-01"].expect
        self.assertIsNotNone(r)
        self.assertEqual(r.status, mod.ST_SEARCH_INCOMPLETE)
        self.assertEqual(r.reason_code, mod.RC_TIE_OVERFLOW)
        self.assertEqual(r.status, 0x04)
        self.assertEqual(r.reason_code, 0x22)
        self.assertNotEqual(r.status, 0x22)
        self.assertEqual(r.completeness, mod.CMPL_PARTIAL)

    def test_invalid_count_integrity_reason_not_status(self):
        r = self.cases["AA-DESC-01"].expect
        self.assertIsNotNone(r)
        self.assertEqual(r.status, mod.ST_DATA_INTEGRITY_FAIL)
        self.assertEqual(r.reason_code, mod.RC_INVALID_DESCRIPTOR)
        self.assertEqual(r.status, 0x06)
        self.assertEqual(r.reason_code, 0x55)
        self.assertNotEqual(r.status, 0x55)

    def test_answer_proof_ref_zero_forbidden(self):
        r = self.cases["AA-ANS-PROOF0"].expect
        self.assertIsNotNone(r)
        self.assertNotEqual(r.status, mod.ST_ANSWER)
        self.assertEqual(r.status, mod.ST_UNKNOWN)
        self.assertEqual(r.reason_code, mod.RC_PROVENANCE_MISSING)
        self.assertEqual(r.proof_ref, 0)

    def test_answer_field_coupling(self):
        r = self.cases["AA-ANS-DIAMOND"].expect
        self.assertEqual(r.status, mod.ST_ANSWER)
        self.assertNotEqual(r.proof_ref, 0)
        self.assertNotEqual(r.answer_kind, mod.KIND_NONE)
        self.assertEqual(r.completeness, mod.CMPL_COMPLETE)
        self.assertEqual(r.conflict_ref, 0)
        self.assertEqual(mod.field_coupling_errors("AA-ANS-DIAMOND", r), [])

    def test_search_incomplete_never_unknown_or_answer(self):
        inc = self.cases["AA-INC-BUDGET"].expect
        unk = self.cases["AA-UNK-ABSENT"].expect
        self.assertEqual(inc.status, mod.ST_SEARCH_INCOMPLETE)
        self.assertEqual(inc.completeness, mod.CMPL_PARTIAL)
        self.assertNotEqual(inc.status, mod.ST_UNKNOWN)
        self.assertNotEqual(inc.status, mod.ST_ANSWER)
        self.assertEqual(unk.status, mod.ST_UNKNOWN)
        self.assertNotEqual(unk.status, mod.ST_SEARCH_INCOMPLETE)

    def test_conflict_reason_not_status_zero(self):
        conf = self.cases["AA-CONFLICT-01"].expect
        diamond = self.cases["AA-ANS-DIAMOND"].expect
        self.assertEqual(conf.status, mod.ST_CONFLICT)
        self.assertEqual(conf.reason_code, mod.RC_DISTINCT_VERIFIED_REFS)
        self.assertEqual(conf.reason_code, 0x30)
        self.assertNotEqual(conf.reason_code, 0x00)
        self.assertNotEqual(conf.status, 0x00)
        self.assertNotEqual(conf.conflict_ref, 0)
        self.assertNotEqual(conf.status, mod.ST_ANSWER)
        self.assertEqual(diamond.status, mod.ST_ANSWER)
        self.assertNotEqual(diamond.proof_ref, 0)

    def test_candidate_only_cannot_answer(self):
        r = self.cases["AA-CAND-01"].expect
        self.assertEqual(r.status, mod.ST_UNKNOWN)
        self.assertEqual(r.reason_code, mod.RC_CANDIDATE_ONLY)
        self.assertNotEqual(r.status, mod.ST_ANSWER)

    def test_txn_echo_and_mismatch_is_not_unknown(self):
        r = self.cases["AA-TXN-ECHO"].expect
        self.assertEqual(r.txn_id, 0xA201)
        forged = [
            {
                "case_id": "AA-TXN-ECHO",
                "status": mod.ST_UNKNOWN,
                "reason_code": mod.RC_NO_VERIFIED_SUPPORT,
                "completeness": mod.CMPL_COMPLETE,
                "answer_kind": mod.KIND_NONE,
                "proof_ref": 0,
                "conflict_ref": 0,
                "txn_id": 0xDEAD,
            }
        ]
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "dut.jsonl"
            p.write_text(json.dumps(forged[0]) + "\n", encoding="utf-8")
            err = mod.compare_jsonl(p, self.case_list)
        self.assertTrue(any("txn_id" in e or "echo" in e for e in err))

    def test_truncated_query_never_unknown(self):
        c = self.cases["AA-QTRUNC-01"]
        r = c.expect
        q = bytes.fromhex(c.query_hex)
        self.assertEqual(len(q), 16)
        self.assertEqual(r.status, mod.ST_DATA_INTEGRITY_FAIL)
        self.assertEqual(r.reason_code, mod.RC_INVALID_DESCRIPTOR)
        self.assertNotEqual(r.status, mod.ST_UNKNOWN)

    def test_bad_query_crc_never_unknown(self):
        c = self.cases["AA-QCRC-01"]
        r = c.expect
        q = bytes.fromhex(c.query_hex)
        self.assertEqual(len(q), 32)
        self.assertNotEqual(mod.crc16_ccitt_false(q[:30]), struct.unpack("<H", q[30:])[0])
        self.assertEqual(r.status, mod.ST_DATA_INTEGRITY_FAIL)
        self.assertEqual(r.reason_code, 0x55)
        self.assertNotEqual(r.status, mod.ST_UNKNOWN)

    def test_stale_generation_not_unknown(self):
        r = self.cases["AA-STALE-GEN"].expect
        self.assertEqual(r.status, 0x06)
        self.assertEqual(r.reason_code, 0x54)
        self.assertEqual(r.reason_code, mod.RC_STALE_GENERATION)
        self.assertNotEqual(r.status, mod.ST_UNKNOWN)
        self.assertNotEqual(r.status, mod.ST_ANSWER)

    def test_protocol_fault_never_unknown(self):
        c = self.cases["AA-PROTO-01"]
        self.assertEqual(c.expect_class, "PROTOCOL_FAULT")
        self.assertNotEqual(c.expect.status, mod.ST_UNKNOWN)
        self.assertNotIn(c.expect.status, (0x00, 0x22, 0x23, 0x55, 0x56, 0x80))

    def test_duplicate_reward_one_update(self):
        steps = self.cases["AA-REW-DUP"].reward_steps
        self.assertEqual(len(steps), 2)
        self.assertTrue(steps[0].reward_accepted)
        self.assertTrue(steps[0].learner_update)
        self.assertEqual(steps[0].reason, mod.REW_ACCEPTED)
        self.assertFalse(steps[1].learner_update)
        self.assertEqual(steps[1].reason, mod.REW_DUPLICATE)

    def test_reward_identity_mismatch_refused(self):
        steps = self.cases["AA-REW-ID"].reward_steps
        self.assertEqual(len(steps), 1)
        self.assertFalse(steps[0].reward_accepted)
        self.assertFalse(steps[0].learner_update)
        self.assertEqual(steps[0].reason, mod.REW_IDENTITY_MISMATCH)

    def test_qstar_overwrite_refused(self):
        cid = mod.CausalId(1, 1, 1, 1)
        d = mod.reward_gate(
            mod.RewardObs(
                pending=cid,
                executed=cid,
                effect=cid,
                exec_valid=True,
                effect_accepted=True,
                reward_source_legal=True,
                overwrite_attempt=True,
            )
        )
        self.assertFalse(d.reward_accepted)
        self.assertFalse(d.learner_update)
        self.assertEqual(d.reason, mod.REW_OVERWRITE_REFUSED)

    def test_k_invalid_integrity_not_answer_or_unknown(self):
        r = self.cases["AA-KINV-01"].expect
        self.assertEqual(r.status, mod.ST_DATA_INTEGRITY_FAIL)
        self.assertEqual(r.reason_code, mod.RC_K_INVALID)
        self.assertEqual(r.reason_code, 0x23)
        self.assertNotEqual(r.status, 0x23)
        self.assertNotEqual(r.status, mod.ST_ANSWER)
        self.assertNotEqual(r.status, mod.ST_UNKNOWN)
        self.assertEqual(r.completeness, mod.CMPL_NA)

    def test_committed_corrupt_not_unknown(self):
        r = self.cases["AA-FEM-CRC"].expect
        self.assertEqual(r.status, 0x06)
        self.assertEqual(r.reason_code, 0x56)
        self.assertEqual(r.reason_code, mod.RC_COMMITTED_CORRUPT)
        self.assertNotEqual(r.status, 0x56)
        self.assertNotEqual(r.status, mod.ST_UNKNOWN)
        self.assertNotEqual(r.status, mod.ST_ANSWER)
        self.assertEqual(r.completeness, mod.CMPL_NA)

    def test_qeval_rows_pack_48_and_magic(self):
        for cid, case in self.cases.items():
            if case.expect is None:
                continue
            blob = bytes.fromhex(case.result_hex)
            self.assertEqual(len(blob), 48, cid)
            self.assertEqual(int.from_bytes(blob[0:2], "little"), 0x4E52, cid)
            unpacked = mod.unpack_result(blob)
            self.assertEqual(unpacked.status, case.expect.status, cid)

    def test_compare_rejects_status_0x22(self):
        rows = [
            {
                "case_id": "AA-TIE-01",
                "status": 0x22,
                "reason_code": 0x22,
                "completeness": 2,
                "proof_ref": 0,
                "conflict_ref": 0,
            }
        ]
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "dut.jsonl"
            p.write_text(json.dumps(rows[0]) + "\n", encoding="utf-8")
            err = mod.compare_jsonl(p, self.case_list)
        self.assertTrue(any("0x22" in e or "status" in e for e in err))

    def test_compare_rejects_fpga_0x80(self):
        rec = {
            "case_id": "AA-UNK-ABSENT",
            "status": 0x80,
            "reason_code": 0,
            "completeness": 1,
            "proof_ref": 0,
            "conflict_ref": 0,
            "txn_id": 0xA110,
        }
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "dut.jsonl"
            p.write_text(json.dumps(rec) + "\n", encoding="utf-8")
            err = mod.compare_jsonl(p, self.case_list)
        self.assertTrue(any("0x80" in e or "illegal" in e for e in err))

    def test_emit_mem_and_svh(self):
        with tempfile.TemporaryDirectory() as td:
            out = Path(td)
            man = mod.emit_artifacts(out, self.case_list)
            self.assertEqual(man["n_cases"], len(self.case_list))
            self.assertTrue((out / "AA-QTRUNC-01.mem").exists())
            self.assertTrue((out / "astra_adv_expect.svh").exists())
            self.assertTrue((out / "astra_adv_fopen.svh").exists())
            mem = (out / "AA-QTRUNC-01.mem").read_text(encoding="ascii").splitlines()
            self.assertEqual(int(mem[0], 16), 4)


if __name__ == "__main__":
    unittest.main()
