"""Owner wake card for a stopped agent chat.

Mailbox cannot open the chat. This prints the one line to paste.

Usage:
    python owner_wake.py AGENT_B
    python owner_wake.py AGENT_B --mail
    python owner_wake.py --all-stale
"""
from __future__ import annotations

import sys
from pathlib import Path

from coord_util import configure_stdio, resolve_coordination_dir, safe_agent_id, safe_print
from mbox_lifecycle import inbox_summary, owner_wake

configure_stdio()


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if not args:
        safe_print("Usage: python owner_wake.py <AGENT_X|--all-stale> [--mail]")
        return 1
    coord = resolve_coordination_dir(Path(__file__).resolve().parent)
    send_mail = "--mail" in args
    args = [a for a in args if a != "--mail"]
    if args[0] == "--all-stale":
        from changebot import ChangeBot

        bot = ChangeBot("..", str(coord))
        presence = bot.agent_health_map()
        rc = 0
        for agent in ("AGENT_A", "AGENT_B", "AGENT_C", "AGENT_D"):
            if presence.get(agent) == "ONLINE":
                continue
            summary = inbox_summary(coord, agent)
            if summary["unread"] <= 0 and summary["pending_count"] <= 0:
                continue
            owner_wake(coord, agent, send_mail=send_mail)
            rc = 2
        return rc
    try:
        agent_id = safe_agent_id(args[0])
    except ValueError as e:
        safe_print(f"Error: {e}")
        return 1
    owner_wake(coord, agent_id, send_mail=send_mail)
    return 0


if __name__ == "__main__":
    sys.exit(main())
