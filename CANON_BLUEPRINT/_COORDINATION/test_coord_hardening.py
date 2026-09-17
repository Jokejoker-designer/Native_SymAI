"""Regression: coordination tools must not crash the agent management loop."""
from __future__ import annotations

import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import coord_util
from changebot import ChangeBot
from coord_util import atomic_write_json, configure_stdio, is_dot_dir, safe_agent_id
from mailbox import Mailbox
from resource_lock import ResourceLock


class TestCoordUtil(unittest.TestCase):
    def test_configure_stdio_survives_none_encoding(self):
        fake = mock.Mock()
        fake.encoding = None
        fake.reconfigure = mock.Mock(side_effect=RuntimeError("no"))
        with mock.patch("coord_util.sys.stdout", fake), mock.patch(
            "coord_util.sys.stderr", None
        ):
            configure_stdio()  # must not raise

    def test_safe_agent_id_rejects_path_separators(self):
        for bad in ("AGENT/A", "AGENT\\B", "..", ".", "inbox/read", ""):
            with self.assertRaises(ValueError):
                safe_agent_id(bad)

    def test_safe_agent_id_accepts_known_agents(self):
        self.assertEqual(safe_agent_id("AGENT_D"), "AGENT_D")
        self.assertEqual(safe_agent_id("CHANGEBOT"), "CHANGEBOT")

    def test_atomic_write_json_replace(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "state.json"
            atomic_write_json(path, {"a": 1})
            atomic_write_json(path, {"a": 2})
            self.assertEqual(json.loads(path.read_text(encoding="utf-8"))["a"], 2)
            self.assertFalse((path.parent / (path.name + ".tmp")).exists())

    def test_is_dot_dir(self):
        self.assertTrue(is_dot_dir(".Xil"))
        self.assertTrue(is_dot_dir(".cache"))
        self.assertFalse(is_dot_dir("rtl"))
        self.assertFalse(is_dot_dir("."))


class TestMailboxHardening(unittest.TestCase):
    def test_broadcast_skips_junk_and_continues(self):
        with tempfile.TemporaryDirectory() as tmp:
            Mailbox(tmp, "CHANGEBOT")
            Mailbox(tmp, "AGENT_A")
            Mailbox(tmp, "AGENT_B")
            (Path(tmp) / "mailbox" / "_junk").mkdir(parents=True, exist_ok=True)
            (Path(tmp) / "mailbox" / "9invalid").mkdir(parents=True, exist_ok=True)
            mb = Mailbox(tmp, "CHANGEBOT")
            sent = mb.broadcast("[CREATE] rtl\\native_ai\\x.sv", "body")
            self.assertEqual(len(sent), 2)
            for p in sent:
                self.assertTrue(Path(p).is_file())
                self.assertEqual(Path(p).parent.name, "inbox")

    def test_check_inbox_skips_non_dict_json(self):
        with tempfile.TemporaryDirectory() as tmp:
            mb = Mailbox(tmp, "AGENT_A")
            bad = mb.inbox_dir / "bad.json"
            bad.write_text("[1, 2, 3]", encoding="utf-8")
            (mb.inbox_dir / "empty.json").write_text("not json", encoding="utf-8")
            mb2 = Mailbox(tmp, "CHANGEBOT")
            mb2.send("AGENT_A", "hello", "ok")
            msgs = mb.check_inbox()
            self.assertEqual(len(msgs), 1)
            self.assertEqual(msgs[0]["message"]["subject"], "hello")

    def test_mark_read_collision_does_not_raise(self):
        with tempfile.TemporaryDirectory() as tmp:
            src_mb = Mailbox(tmp, "CHANGEBOT")
            dest = src_mb.send("AGENT_A", "same", "1")
            dst_mb = Mailbox(tmp, "AGENT_A")
            first = Path(dest)
            # Pretend already archived with same name.
            (dst_mb.read_dir / first.name).write_text("{}", encoding="utf-8")
            dst_mb.mark_read(dest)
            self.assertFalse(first.exists())
            archived = list(dst_mb.read_dir.glob("*.json"))
            self.assertGreaterEqual(len(archived), 2)

    def test_unsafe_constructor_agent_id(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(ValueError):
                Mailbox(tmp, r"AGENT\D")


class TestChangeBotHardening(unittest.TestCase):
    def test_scan_prunes_generated_and_dot_dirs(self):
        with tempfile.TemporaryDirectory() as tmp:
            watch = Path(tmp) / "canon"
            coord = Path(tmp) / "coord"
            watch.mkdir()
            coord.mkdir()
            (watch / "30_MILESTONE_ROADMAP.md").write_text("ok", encoding="utf-8")
            xsim = watch / "vivado" / "proj" / "xsim.dir" / "work"
            xsim.mkdir(parents=True)
            (xsim / "huge.wdb").write_text("x", encoding="utf-8")
            (watch / ".Xil" / "secret").mkdir(parents=True)
            (watch / ".Xil" / "secret" / "a.log").write_text("x", encoding="utf-8")
            nested = watch / "CANON_BLUEPRINT_R0_1_AUDITED_CANDIDATE" / "rtl"
            nested.mkdir(parents=True)
            (nested / "old.sv").write_text("x", encoding="utf-8")
            bot = ChangeBot(str(watch), str(coord))
            state = bot._scan_files()
            self.assertIn("30_MILESTONE_ROADMAP.md", state)
            self.assertTrue(all("xsim.dir" not in k for k in state))
            self.assertTrue(all(".Xil" not in k for k in state))
            self.assertTrue(all("AUDITED_CANDIDATE" not in k for k in state))

    def test_process_changes_continues_after_notify_error(self):
        with tempfile.TemporaryDirectory() as tmp:
            watch = Path(tmp) / "canon"
            coord = Path(tmp) / "coord"
            watch.mkdir()
            coord.mkdir()
            (coord / "schema_lock.json").write_text("{}", encoding="utf-8")
            (coord / "registry.json").write_text(
                json.dumps({"agents": {"AGENT_D": {
                    "status": "active",
                    "last_seen": "2099-01-01T00:00:00+00:00",
                }}}),
                encoding="utf-8",
            )
            bot = ChangeBot(str(watch), str(coord))
            calls = []

            def boom(to_agent, subject, body, priority="NORMAL"):
                calls.append(to_agent)
                if len(calls) == 1:
                    raise OSError("simulated send failure")
                return str(coord / "mailbox" / to_agent / "inbox" / "ok.json")

            bot.mailbox.send = boom  # type: ignore[method-assign]
            bot.process_changes([
                {"type": "CREATE", "path": "rtl/a.sv", "details": "",
                 "old_sha256": None, "new_sha256": "aa"},
                {"type": "CREATE", "path": "rtl/b.sv", "details": "",
                 "old_sha256": None, "new_sha256": "bb"},
            ])
            bot._flush_batch()
            # coalesced into one patch; deliver attempts continue past OSError
            self.assertGreaterEqual(len(calls), 1)

    def test_corrupt_state_does_not_crash(self):
        with tempfile.TemporaryDirectory() as tmp:
            watch = Path(tmp) / "canon"
            coord = Path(tmp) / "coord"
            watch.mkdir()
            coord.mkdir()
            (coord / ".changebot_state.json").write_text("[1,2]", encoding="utf-8")
            (watch / "x.md").write_text("x", encoding="utf-8")
            bot = ChangeBot(str(watch), str(coord))
            changes = bot.detect_changes()
            kinds = {c["type"] for c in changes}
            self.assertIn("CREATE", kinds)


class TestResourceLockHardening(unittest.TestCase):
    def test_cli_strings_are_ascii(self):
        src = Path(__file__).parent / "resource_lock.py"
        text = src.read_text(encoding="utf-8")
        self.assertNotIn("✓", text)
        self.assertNotIn("✗", text)
        self.assertNotIn("⚠", text)

    def test_corrupt_lock_and_unlink_race(self):
        with tempfile.TemporaryDirectory() as tmp:
            rl = ResourceLock(tmp)
            lock = rl._lock_file("board_program")
            lock.write_text("not json", encoding="utf-8")
            self.assertTrue(rl.acquire("board_program", "AGENT_D", "synth"))
            self.assertTrue(rl.release("board_program", "AGENT_D"))
            self.assertFalse(lock.exists())
            # Second release / missing file must not raise.
            self.assertFalse(rl.release("board_program", "AGENT_D"))

    def test_exclusive_blocks_other_agent(self):
        with tempfile.TemporaryDirectory() as tmp:
            rl = ResourceLock(tmp)
            self.assertTrue(rl.acquire("vivado_mcp_session", "AGENT_D", "ooc"))
            self.assertFalse(rl.acquire("vivado_mcp_session", "AGENT_B", "ooc"))

    def test_holders_not_list_does_not_crash(self):
        with tempfile.TemporaryDirectory() as tmp:
            rl = ResourceLock(tmp)
            lock = rl._lock_file("uart_port")
            lock.write_text(json.dumps({"holders": "AGENT_D"}), encoding="utf-8")
            self.assertTrue(rl.acquire("uart_port", "AGENT_D", "uart"))


class TestAgentStartupPreserveTask(unittest.TestCase):
    def test_reregister_preserves_current_task(self):
        import agent_startup

        with tempfile.TemporaryDirectory() as tmp:
            fake_registry = Path(tmp) / "registry.json"
            with mock.patch.object(agent_startup, "REGISTRY_PATH", fake_registry):
                agent_startup.register_agent("AGENT_D", "Implementation Lead")
                data = json.loads(fake_registry.read_text(encoding="utf-8"))
                data["agents"]["AGENT_D"]["current_task"] = "M1 Pack Loader"
                data["agents"]["AGENT_D"]["resources_held"] = ["vivado_mcp_session"]
                fake_registry.write_text(json.dumps(data), encoding="utf-8")
                agent_startup.register_agent("AGENT_D", "Implementation Lead")
                again = json.loads(fake_registry.read_text(encoding="utf-8"))
                self.assertEqual(again["agents"]["AGENT_D"]["current_task"], "M1 Pack Loader")
                self.assertEqual(
                    again["agents"]["AGENT_D"]["resources_held"],
                    ["vivado_mcp_session"],
                )

    def test_schema_lock_garbage_does_not_crash(self):
        import agent_startup

        with tempfile.TemporaryDirectory() as tmp:
            fake = Path(tmp) / "schema_lock.json"
            fake.write_text("not json {", encoding="utf-8")
            with mock.patch.object(agent_startup, "SCHEMA_LOCK_PATH", fake):
                agent_startup.show_ownership("AGENT_D")  # must not raise


class TestSafePrintCp1252(unittest.TestCase):
    def test_safe_print_replaces_on_unicode_error(self):
        buf = io.BytesIO()

        class Cp1252:
            encoding = "cp1252"
            buffer = buf

            def write(self, s):
                s.encode("cp1252")  # raise if emoji
                return len(s)

            def flush(self):
                pass

        stream = Cp1252()
        with mock.patch("coord_util.sys.stdout", stream):
            coord_util.safe_print("OK tick ✓")


if __name__ == "__main__":
    unittest.main()
