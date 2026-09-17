"""Tests for ChangeBot patch store + planned restart bootstrap."""
from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from patch_store import PatchStore
from changebot import ChangeBot, write_mailbox_audit


class PatchStoreTests(unittest.TestCase):
    def test_create_and_supersede(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = PatchStore(tmp)
            a = store.create(
                "PATCH_A",
                source_agent="CHANGEBOT",
                files=["a.md"],
                change_class="TEST",
                priority="ACTION_REQUIRED",
                target_agents=["AGENT_A"],
                required_state="APPLIED",
                summary="old",
                why="test",
                required_action="apply",
            )
            self.assertEqual(a["STATUS"], "ACTIVE")
            b = store.create(
                "PATCH_B",
                source_agent="CHANGEBOT",
                files=["a.md"],
                change_class="TEST",
                priority="ACTION_REQUIRED",
                target_agents=["AGENT_A"],
                required_state="APPLIED",
                summary="new",
                why="test",
                required_action="apply",
                supersedes=["PATCH_A"],
            )
            self.assertEqual(b["STATUS"], "ACTIVE")
            a2 = store.load("PATCH_A")
            self.assertEqual(a2["STATUS"], "SUPERSEDED")
            self.assertEqual(a2["SUPERSEDED_BY"], "PATCH_B")

    def test_needs_delivery_when_pointer_stale(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = PatchStore(tmp)
            store.create(
                "PATCH_X",
                source_agent="CHANGEBOT",
                files=["a.md"],
                change_class="TEST",
                priority="ACTION_REQUIRED",
                target_agents=["AGENT_A"],
                required_state="APPLIED",
                summary="x",
                why="test",
                required_action="apply",
            )
            missing = str(Path(tmp) / "gone.json")
            store.mark_delivered("PATCH_X", "AGENT_A", missing)
            self.assertTrue(store.needs_delivery("PATCH_X", "AGENT_A"))
            live = Path(tmp) / "live.json"
            live.write_text("{}", encoding="utf-8")
            store.repair_delivery_pointer("PATCH_X", "AGENT_A", str(live))
            self.assertFalse(store.needs_delivery("PATCH_X", "AGENT_A"))


class ChangeBotBootstrapTests(unittest.TestCase):
    def test_planned_restart_deliver_once(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = Path(tmp)
            watch = coord / "watch"
            watch.mkdir()
            (coord / "registry.json").write_text(json.dumps({
                "agents": {
                    "AGENT_A": {
                        "status": "active",
                        "last_seen": "2099-01-01T00:00:00+00:00",
                    },
                    "AGENT_B": {
                        "status": "active",
                        "last_seen": "2000-01-01T00:00:00+00:00",
                    },
                }
            }), encoding="utf-8")
            (coord / "schema_lock.json").write_text("{}", encoding="utf-8")
            # intentional restart marker — applied when daemon watch() starts;
            # bootstrap path also forces PLANNED_RESTART classification in health.
            (coord / ".changebot_restart_marker.json").write_text(json.dumps({
                "intentional": True,
                "planned_restart": True,
                "reason": "test",
            }), encoding="utf-8")

            bot = ChangeBot(str(watch), str(coord))
            bot._load_or_init_health()
            self.assertEqual(bot.restart_reason, "PLANNED_RESTART")
            self.assertEqual(bot.old_process_status, "INTENTIONAL_TERMINATION")

            write_mailbox_audit(coord)
            rec = bot.bootstrap_planned_restart_classification()
            self.assertEqual(rec["PATCH_ID"], "CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")

            # Deliver once — second call should not duplicate
            before = list((coord / "mailbox" / "AGENT_A" / "inbox").glob("*.json"))
            bot.deliver_patch(rec)
            after = list((coord / "mailbox" / "AGENT_A" / "inbox").glob("*.json"))
            self.assertEqual(len(before), len(after))

            # C offline
            self.assertEqual(rec["CURRENT_AGENT_STATES"]["AGENT_C"], "OFFLINE")

            # content-identical should not create changes
            f = watch / "x.md"
            f.write_text("hello", encoding="utf-8")
            bot._save_state(bot._scan_files())
            f.write_text("hello", encoding="utf-8")  # touch-equivalent content
            changes = bot.detect_changes()
            self.assertEqual(changes, [])


class RouterTests(unittest.TestCase):
    def test_vivado_tcl_not_architecture(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = Path(tmp)
            watch = coord / "watch"
            watch.mkdir()
            (coord / "schema_lock.json").write_text("{}", encoding="utf-8")
            (coord / "registry.json").write_text("{}", encoding="utf-8")
            bot = ChangeBot(str(watch), str(coord))
            route = bot.classify_and_route("vivado/tcl/01_create_project_m1.tcl", "MODIFY")
            self.assertEqual(route["targets"], ["AGENT_D"])
            self.assertEqual(route["change_class"], "IMPL_LOCAL")
            self.assertNotEqual(route["priority"], "CRITICAL")

    def test_astra_doc_is_critical_to_abd(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = Path(tmp)
            watch = coord / "watch"
            watch.mkdir()
            (coord / "schema_lock.json").write_text(json.dumps({
                "documents": {
                    "03_ASTRA_AUTHORITY.md": {
                        "owner": "AGENT_B",
                        "writable_by": ["AGENT_B"],
                    }
                }
            }), encoding="utf-8")
            (coord / "registry.json").write_text("{}", encoding="utf-8")
            bot = ChangeBot(str(watch), str(coord))
            route = bot.classify_and_route("03_ASTRA_AUTHORITY.md", "MODIFY")
            self.assertEqual(route["priority"], "CRITICAL")
            self.assertIn("AGENT_B", route["targets"])
            self.assertIn("AGENT_A", route["targets"])
            self.assertIn("AGENT_D", route["targets"])


class CoalesceHoldTests(unittest.TestCase):
    def test_max_hold_caps_deadline_extension(self):
        with tempfile.TemporaryDirectory() as tmp:
            coord = Path(tmp)
            watch = coord / "watch"
            watch.mkdir()
            (coord / "schema_lock.json").write_text("{}", encoding="utf-8")
            (coord / "registry.json").write_text("{}", encoding="utf-8")
            bot = ChangeBot(str(watch), str(coord))
            opened = 1_000_000.0
            bot._batch_opened_at = opened
            bot._batch_deadline = opened + 30
            bot._pending_batch = [{
                "path": "rtl/native_ai/loader/pack_loader.sv",
                "type": "MODIFY",
                "details": "",
                "old_sha256": "a",
                "new_sha256": "b",
                "route": {
                    "priority": "ACTION_REQUIRED",
                    "targets": ["AGENT_D"],
                    "change_class": "IMPL_LOCAL",
                },
            }]
            with mock.patch("changebot.time.time", return_value=opened + 50):
                with mock.patch.object(bot, "_persist_pending_batch"):
                    bot.process_changes([{
                        "path": "rtl/native_ai/loader/pack_loader.sv",
                        "type": "MODIFY",
                        "details": "",
                        "old_sha256": "b",
                        "new_sha256": "c",
                    }])
            # Must not slide forever — hard cap from opened_at
            from changebot import COALESCE_MAX_HOLD_SEC
            self.assertLessEqual(bot._batch_deadline, opened + COALESCE_MAX_HOLD_SEC)
            self.assertGreaterEqual(bot._batch_deadline, opened)


if __name__ == "__main__":
    unittest.main()
