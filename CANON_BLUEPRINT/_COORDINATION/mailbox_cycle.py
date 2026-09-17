"""Agent mailbox START/STOP cycle.

Usage:
    python mailbox_cycle.py AGENT_B start
    python mailbox_cycle.py AGENT_B stop
    python mailbox_cycle.py AGENT_B status
    python mailbox_cycle.py --all-stale-wake
"""
from __future__ import annotations

import sys
from pathlib import Path

from coord_util import configure_stdio, resolve_coordination_dir, safe_agent_id, safe_print
from mbox_lifecycle import (
    inbox_summary,
    owner_wake,
    roster_entry,
    show_wake_banner,
    start_cycle,
    stop_cycle,
    wake_exists,
)

configure_stdio()


def _coord():
    return resolve_coordination_dir(Path(__file__).resolve().parent)


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if not args:
        safe_print(
            "Usage: python mailbox_cycle.py <AGENT_X> <start|stop|status> | --all-stale-wake"
        )
        return 1
    coord = _coord()
    if args[0] == "--all-stale-wake":
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
            owner_wake(coord, agent, send_mail=False)
            rc = 2
        return rc

    try:
        agent_id = safe_agent_id(args[0])
    except ValueError as e:
        safe_print(f"Error: {e}")
        return 1
    phase = args[1] if len(args) > 1 else "status"
    if phase == "start":
        return start_cycle(coord, agent_id)
    if phase == "stop":
        return stop_cycle(coord, agent_id)
    if phase == "status":
        info = roster_entry(coord, agent_id)
        summary = inbox_summary(coord, agent_id)
        show_wake_banner(coord, agent_id)
        safe_print(
            f"[{agent_id}] unread={summary['unread']} pending={summary['pending_count']} "
            f"wake={wake_exists(coord, agent_id)} chat_id={info.get('chat_id')}"
        )
        return 0 if summary["unread"] == 0 and summary["pending_count"] == 0 else 2
    safe_print("phase must be start|stop|status")
    return 1


if __name__ == "__main__":
    sys.exit(main())
