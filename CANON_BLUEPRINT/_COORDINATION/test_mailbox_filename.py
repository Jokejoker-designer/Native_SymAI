"""Regression: ChangeBot subjects with Windows paths must not create nested dirs."""
import tempfile
import unittest
from pathlib import Path

from mailbox import Mailbox, safe_message_slug


class TestMailboxFilename(unittest.TestCase):
    def test_windows_path_slug_is_flat(self):
        subject = "[CREATE] rtl\\native_ai\\m1_pack_loader\\CONTRACT.md"
        slug = safe_message_slug(subject)
        self.assertNotIn("\\", slug)
        self.assertNotIn("/", slug)
        self.assertEqual(Path(slug).name, slug)

    def test_posix_path_slug_is_flat(self):
        subject = "[CREATE] python/m1/pack_vectors.py"
        slug = safe_message_slug(subject)
        self.assertNotIn("/", slug)
        self.assertTrue(slug.startswith("create") or "python" in slug)

    def test_send_with_backslash_path_writes_one_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            mb = Mailbox(tmp, "CHANGEBOT")
            dest = mb.send(
                "AGENT_A",
                "[CREATE] rtl\\native_ai\\loader\\pack_loader.sv",
                "body",
            )
            p = Path(dest)
            self.assertTrue(p.is_file(), dest)
            self.assertEqual(p.parent, Path(tmp) / "mailbox" / "AGENT_A" / "inbox")
            self.assertEqual(p.suffix, ".json")
            self.assertNotIn("native_ai", str(p.parent))


if __name__ == "__main__":
    unittest.main()
