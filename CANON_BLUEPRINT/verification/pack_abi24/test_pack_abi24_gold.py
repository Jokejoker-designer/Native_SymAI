#!/usr/bin/env python3
"""Pack/ABI-24 gold tests. Stdlib + the gold module only."""

from __future__ import annotations

import importlib.util
import struct
import sys
import unittest
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("pack_abi24_gold", ROOT / "pack_abi24_gold.py")
mod = importlib.util.module_from_spec(SPEC)
sys.modules["pack_abi24_gold"] = mod
SPEC.loader.exec_module(mod)


class PackAbi24Tests(unittest.TestCase):
    def setUp(self):
        self.cases = {c.case_id: c for c in mod.build_cases()}

    def test_selfcheck(self):
        self.assertEqual(mod.selfcheck(list(self.cases.values())), [])

    def test_header_128_not_132(self):
        h = mod.pack_header(pack_generation=1)
        self.assertEqual(len(h), 128)
        self.assertEqual(mod.unpack_header(h)["header_length"], 128)
        rival = mod.pack_header_rival_132()
        self.assertEqual(len(rival), 132)
        self.assertEqual(mod.unpack_header(rival)["header_length"], 132)

    def test_crc_independent_matches_zlib(self):
        blob = bytes(range(112))
        self.assertEqual(mod.crc32_iso_hdlc(blob), zlib.crc32(blob) & 0xFFFFFFFF)

    def test_does_not_import_dut_helper(self):
        self.assertNotIn("pack_vectors", sys.modules)

    def test_identities_not_dut_fillers(self):
        self.assertNotEqual(mod.SCHEMA_ID_R01, b"\x11" * 32)
        self.assertNotEqual(mod.CONTENT_A, b"\x22" * 32)
        self.assertEqual(mod.SCHEMA_ID_R01, __import__("hashlib").sha256(mod.SCHEMA_LABEL_R01).digest())

    def test_header_length_132_payload_is_reject(self):
        c = self.cases["PA24-A-03"]
        self.assertEqual(c.expect.reason, mod.RC_HEADER_LENGTH)
        self.assertEqual(c.expect.outcome, mod.OUTCOME_REJECT)
        self.assertEqual(struct.unpack_from("<H", c.blob, 2)[0], 132)

    def test_be_magic_is_bad_magic(self):
        c = self.cases["PA24-A-02"]
        self.assertEqual(c.expect.reason, mod.RC_BAD_MAGIC)
        self.assertEqual(c.blob[4:8], bytes.fromhex("3149414E"))

    def test_no_truncate_pack_generation(self):
        c = self.cases["PA24-G-03"]
        self.assertEqual(c.expect.reason, mod.RC_UNSUPPORTED)
        hdr = c.blob[4:]
        self.assertEqual(mod.unpack_header(hdr)["pack_generation"], 0x10000)

    def test_crc_group_is_not_reserved_nz(self):
        for cid in ("PA24-R-01", "PA24-R-02", "PA24-R-03"):
            self.assertNotEqual(self.cases[cid].expect.reason, mod.RC_RESERVED_NZ)

    def test_r04_never_unknown_or_status_zero(self):
        c = self.cases["PA24-R-04"]
        self.assertEqual(c.expect.outcome, mod.OUTCOME_OK)
        self.assertEqual(c.expect.query_status, mod.ST_DATA_INTEGRITY_FAIL)
        self.assertNotIn(c.expect.query_status, (0, mod.ST_UNKNOWN))

    def test_g01_two_steps(self):
        self.assertEqual(len(self.cases["PA24-G-01"].steps), 2)

    def test_host_compare_matches_gold_rows(self):
        import json
        import tempfile
        from pathlib import Path

        cases = list(self.cases.values())
        rows = mod.gold_dut_rows(cases)
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "dut.jsonl"
            p.write_text("".join(json.dumps(r) + "\n" for r in rows), encoding="utf-8")
            self.assertEqual(mod.compare_dut(p, cases), 0)
            bad = rows[0].copy()
            bad["reason"] = 0x7F
            p.write_text(json.dumps(bad) + "\n", encoding="utf-8")
            self.assertEqual(mod.compare_dut(p, cases), 1)


if __name__ == "__main__":
    unittest.main()
