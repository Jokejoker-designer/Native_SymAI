"""Live A/B/C/D receive/read/apply coverage snapshot (stdlib only)."""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

from changebot import ChangeBot
from coord_util import configure_stdio, resolve_coordination_dir, safe_print
from mailbox import Mailbox

configure_stdio()


def main() -> int:
    base = resolve_coordination_dir(Path(__file__).parent)
    bot = ChangeBot(str(Path(base).parent), str(base))
    bot.ingest_acks()
    health = {}
    hp = Path(base) / "changebot_health.json"
    if hp.exists():
        health = json.loads(hp.read_text(encoding="utf-8"))
    now = datetime.now(timezone.utc)
    last = health.get("last_scan")
    age = None
    if last:
        age = round((now - datetime.fromisoformat(str(last))).total_seconds(), 1)

    presence = bot.agent_health_map()
    safe_print(f"UTC {now.isoformat()}")
    safe_print(
        f"DAEMON health={health.get('health')} gen={health.get('daemon_generation')} "
        f"pid={health.get('pid')} age_s={age}"
    )
    safe_print("PRESENCE " + " ".join(f"{a}={presence.get(a)}" for a in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D")))

    safe_print("INBOX")
    for agent in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"):
        mb = Mailbox(str(base), agent)
        msgs = mb.check_inbox()
        patches = [
            m
            for m in msgs
            if str((m.get("message") or {}).get("subject") or "").startswith("PATCH ")
        ]
        safe_print(f"  {agent}: unread={len(msgs)} patch={len(patches)} presence={presence.get(agent)}")

    safe_print("PATCH_COVERAGE (ACTION/CRITICAL active)")
    need_any = False
    for rec in bot.patches.active_action_patches():
        pid = rec["PATCH_ID"]
        safe_print(f"  {pid} [{rec.get('CHANGE_CLASS')}/{rec.get('PRIORITY')}]")
        for agent in rec.get("TARGET_AGENTS") or []:
            state = (rec.get("CURRENT_AGENT_STATES") or {}).get(agent, "NOT_SEEN")
            ok = state in {"APPLIED", "VERIFIED", "NOT_REQUIRED"}
            if not ok:
                need_any = True
            tag = "APPLIED_OK" if ok else "NEED_APPLY"
            # receive vs apply
            if state == "NOT_SEEN":
                meaning = "chua_nhan/chua_doc"
            elif state == "RECEIVED":
                meaning = "da_nhan_chua_apply"
            elif state == "OFFLINE":
                meaning = "offline_luc_deliver"
            elif ok:
                meaning = "da_doc_va_apply"
            else:
                meaning = state
            safe_print(f"    {agent}: {state} ({meaning}) [{tag}]")

    r1 = bot.patches.load("CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1")
    if r1:
        safe_print("R1 " + json.dumps(r1.get("CURRENT_AGENT_STATES") or {}, ensure_ascii=False))
    safe_print("SUMMARY " + ("ALL_ACTIVE_APPLIED" if not need_any else "COVERAGE_GAPS"))
    return 0 if not need_any else 2


if __name__ == "__main__":
    sys.exit(main())
