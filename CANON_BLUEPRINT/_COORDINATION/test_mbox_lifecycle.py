"""Mailbox START/STOP lifecycle: dirty stop writes WAKE, clean stop clears it."""
import json
import tempfile
import unittest
from pathlib import Path

from mailbox import Mailbox
from mbox_lifecycle import (
    OWNER_PASTE,
    clear_wake,
    owner_wake,
    start_cycle,
    stop_cycle,
    wake_exists,
    write_wake,
)


class TestMboxLifecycle(unittest.TestCase):
    def _coord(self, tmp: str) -> Path:
        root = Path(tmp)
        (root / "mailbox").mkdir(parents=True, exist_ok=True)
        (root / "patches").mkdir(parents=True, exist_ok=True)
        roster = {
            "owner_paste": OWNER_PASTE,
            "agents": {
                "AGENT_B": {
                    "role": "Verification Lead",
                    "chat_id": "96631e87-de06-4217-b61c-8c29c47237a6",
                    "chat_title": "Verification lead responsibilities- B",
                    "worktree": str(root / "wt_b"),
                }
            },
        }
        (root / "agent_chat_roster.json").write_text(
            json.dumps(roster, indent=2), encoding="utf-8", newline="\n"
        )
        (root / "wt_b").mkdir(parents=True, exist_ok=True)
        return root

    def test_dirty_stop_writes_wake_and_exit_2(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            Mailbox(str(coord), "AGENT_A").send(
                "AGENT_B", "TEST_WAKE mailbox ping", "please ACK", priority="HIGH"
            )
            rc = stop_cycle(coord, "AGENT_B")
            self.assertEqual(rc, 2)
            self.assertTrue(wake_exists(coord, "AGENT_B"))
            wake = (coord / "mailbox" / "AGENT_B" / "WAKE_REQUIRED.txt").read_text(
                encoding="utf-8"
            )
            self.assertIn("WAKE_REQUIRED", wake)
            self.assertIn("SHUTDOWN_UNREAD", wake)
            self.assertIn(OWNER_PASTE, wake)
            snap = json.loads(
                (coord / "mailbox" / "AGENT_B" / "last_shutdown.json").read_text(
                    encoding="utf-8"
                )
            )
            self.assertFalse(snap["clean"])
            self.assertGreaterEqual(snap["unread"], 1)

    def test_clean_stop_clears_wake(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            write_wake(coord, "AGENT_B", unread=1, pending=[], reason="OWNER_WAKE")
            self.assertTrue(wake_exists(coord, "AGENT_B"))
            rc = stop_cycle(coord, "AGENT_B")
            self.assertEqual(rc, 0)
            self.assertFalse(wake_exists(coord, "AGENT_B"))

    def test_start_cycle_dirty_then_clean_after_mark_read(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            mb = Mailbox(str(coord), "AGENT_A")
            mb.send("AGENT_B", "TEST_WAKE", "ack", priority="HIGH")
            self.assertEqual(start_cycle(coord, "AGENT_B"), 2)
            dst = Mailbox(str(coord), "AGENT_B")
            for item in dst.check_inbox():
                dst.mark_read(item["file"])
            self.assertEqual(start_cycle(coord, "AGENT_B"), 0)
            self.assertFalse(wake_exists(coord, "AGENT_B"))

    def test_owner_wake_prints_roster_id(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            result = owner_wake(coord, "AGENT_B", send_mail=False)
            self.assertEqual(result["owner_paste"], OWNER_PASTE)
            self.assertEqual(result["chat_id"], "96631e87-de06-4217-b61c-8c29c47237a6")
            self.assertTrue(result["wake_paths"])
            self.assertTrue(wake_exists(coord, "AGENT_B"))

    def test_temp_coord_does_not_write_canonical_worktree_wake(self):
        live = Path(r"d:\FPGA\NATIVE_AI\worktrees\AGENT_B\WAKE_REQUIRED.txt")
        before = live.read_text(encoding="utf-8") if live.exists() else None
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            Mailbox(str(coord), "AGENT_A").send(
                "AGENT_B", "isolated", "x", priority="HIGH"
            )
            self.assertEqual(stop_cycle(coord, "AGENT_B"), 2)
            after = live.read_text(encoding="utf-8") if live.exists() else None
        self.assertEqual(before, after)

    def test_clear_wake_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = self._coord(tmp)
            clear_wake(coord, "AGENT_B")
            clear_wake(coord, "AGENT_B")
            self.assertFalse(wake_exists(coord, "AGENT_B"))


if __name__ == "__main__":
    unittest.main()
