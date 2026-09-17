#!/usr/bin/env python3
"""Unit tests for the FE256 R0.1 gold reference. Stdlib only."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("fe256_gold", ROOT / "fe256_gold.py")
gold = importlib.util.module_from_spec(SPEC)
sys.modules["fe256_gold"] = gold
SPEC.loader.exec_module(gold)


class Fe256GoldTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cases = gold.build_cases()
        cls.store_a, cls.store_b, cls.rows = gold.evaluate_campaign(cls.cases)

    def test_counts_and_selfcheck(self):
        self.assertEqual(len(self.rows), 256)
        self.assertEqual(gold.selfcheck(self.rows), [])

    def test_packed_sizes_and_crc_roundtrip(self):
        for case, result, qbin, rbin in self.rows:
            self.assertEqual(len(qbin), 32, case.case_id)
            self.assertEqual(len(rbin), 48, case.case_id)
            q2 = gold.unpack_query(qbin)
            r2 = gold.unpack_result(rbin)
            self.assertEqual(q2.txn_id, case.query.txn_id)
            self.assertEqual(r2.status, result.status)
            self.assertEqual(r2.txn_id, case.query.txn_id)

    def test_status_zero_illegal(self):
        for case, result, _, _ in self.rows:
            self.assertNotEqual(result.status, 0, case.case_id)

    def test_answer_has_proof(self):
        for case, result, _, _ in self.rows:
            if result.status == gold.ST_ANSWER:
                self.assertNotEqual(result.proof_ref, 0, case.case_id)
                self.assertNotEqual(result.answer_kind, gold.KIND_NONE, case.case_id)
                self.assertEqual(result.completeness, gold.CMPL_COMPLETE, case.case_id)
                self.assertEqual(result.conflict_ref, 0, case.case_id)

    def test_incomplete_is_not_unknown(self):
        inc = [r for c, r, _, _ in self.rows if c.group == "FE-NEGATIVE" and r.status == gold.ST_SEARCH_INCOMPLETE]
        self.assertEqual(len(inc), 4)
        for r in inc:
            self.assertEqual(r.completeness, gold.CMPL_PARTIAL)
            self.assertEqual(r.reason_code, gold.RC_BUDGET_EXHAUSTED)
            self.assertNotEqual(r.status, gold.ST_UNKNOWN)
            self.assertNotEqual(r.status, gold.ST_ANSWER)

    def test_conflict_reason_distinct_verified_refs(self):
        for case, result, _, _ in self.rows:
            if result.status == gold.ST_CONFLICT:
                self.assertNotEqual(result.conflict_ref, 0, case.case_id)
                self.assertEqual(result.reason_code, gold.RC_DISTINCT_VERIFIED_REFS, case.case_id)
                self.assertEqual(result.reason_code, 0x30, case.case_id)
                self.assertNotEqual(result.reason_code, 0x00, case.case_id)
                self.assertEqual(result.status, 0x03, case.case_id)
                self.assertNotEqual(result.status, 0x00, case.case_id)

    def test_fpga_path_illegal_status_absent(self):
        for case, result, _, _ in self.rows:
            self.assertNotIn(result.status, (0x00, 0x22, 0x55, 0x80), case.case_id)

    def test_shuffle_is_permutation(self):
        order = gold.shuffle_indices(256)
        self.assertEqual(sorted(order), list(range(256)))
        self.assertNotEqual(order, list(range(256)))

    def test_rival_all_answer_fails_policy(self):
        rival = []
        for case, result, qbin, rbin in self.rows:
            fake = gold.ResultRec(
                txn_id=case.query.txn_id,
                status=gold.ST_ANSWER,
                reason_code=gold.RC_VERIFIED_SUPPORT,
                answer_kind=gold.KIND_ENTITY,
                proof_ref=1,
                answer_ref=1,
            )
            rival.append((case, fake, qbin, fake.pack()))
        err = gold.selfcheck(rival)
        self.assertTrue(any("FE-NEGATIVE" in e or "FE-CONFLICT" in e or "FE-ABLATION" in e for e in err))

    def test_encoding_locks(self):
        self.assertEqual(gold.MAGIC_QUERY, 0x4E51)
        self.assertEqual(gold.MAGIC_RESULT, 0x4E52)
        self.assertEqual(gold.ST_ANSWER, 0x01)
        self.assertEqual(gold.ST_UNKNOWN, 0x02)
        self.assertEqual(gold.ST_CONFLICT, 0x03)
        self.assertEqual(gold.ST_SEARCH_INCOMPLETE, 0x04)
        self.assertEqual(gold.ST_UNSUPPORTED_QUERY, 0x05)
        self.assertEqual(gold.ST_DATA_INTEGRITY_FAIL, 0x06)
        self.assertEqual(gold.ST_PARSE_ERROR, 0x80)
        self.assertEqual(gold.RC_TIE_OVERFLOW, 0x22)
        self.assertEqual(gold.RC_K_INVALID, 0x23)
        self.assertEqual(gold.RC_INVALID_DESCRIPTOR, 0x55)
        self.assertEqual(gold.RC_COMMITTED_CORRUPT, 0x56)
        self.assertNotIn(gold.RC_TIE_OVERFLOW, gold.STATUS_NAME)
        self.assertNotIn(gold.RC_INVALID_DESCRIPTOR, gold.STATUS_NAME)
        self.assertNotIn(gold.RC_K_INVALID, gold.STATUS_NAME)
        self.assertNotIn(gold.RC_COMMITTED_CORRUPT, gold.STATUS_NAME)
        self.assertNotIn(gold.RC_TIE_OVERFLOW, gold.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(gold.RC_INVALID_DESCRIPTOR, gold.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(gold.RC_K_INVALID, gold.PRIMARY_ASTRA_STATUS)
        self.assertNotIn(gold.RC_COMMITTED_CORRUPT, gold.PRIMARY_ASTRA_STATUS)
        q = self.rows[0][2]
        self.assertEqual(int.from_bytes(q[0:2], "little"), 0x4E51)


if __name__ == "__main__":
    unittest.main()
