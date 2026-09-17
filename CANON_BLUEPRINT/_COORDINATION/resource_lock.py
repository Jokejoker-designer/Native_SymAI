"""
Native AI CANON_BLUEPRINT — Resource Lock Manager

File-based resource locking for shared hardware/software resources.
Supports EXCLUSIVE and SHARED lock semantics.
No external dependencies — stdlib only.

Usage:
    from resource_lock import ResourceLock
    rl = ResourceLock(base_dir="_COORDINATION")
    rl.acquire("board_program", "AGENT_D", "Programming bitstream", expected_minutes=10)
    rl.release("board_program", "AGENT_D")
    print(rl.status())
"""

import json
from datetime import datetime, timezone, timedelta
from pathlib import Path

from coord_util import atomic_write_json, configure_stdio, safe_agent_id, safe_print


class ResourceLock:
    """File-based resource locking with EXCLUSIVE and SHARED semantics."""

    EXCLUSIVE_RESOURCES = frozenset([
        "board_program",
        "uart_port",
        "vivado_mcp_session",
    ])

    SHARED_RESOURCES = frozenset([
        "vivado_synthesis",
        "vivado_implementation",
    ])

    ALL_RESOURCES = EXCLUSIVE_RESOURCES | SHARED_RESOURCES

    def __init__(self, base_dir: str):
        self.base_dir = Path(base_dir)
        self.locks_dir = self.base_dir / "locks"
        self.locks_dir.mkdir(parents=True, exist_ok=True)

    def _lock_file(self, resource: str) -> Path:
        return self.locks_dir / f"{resource}.lock"

    def _empty_lock(self, resource: str) -> dict:
        return {"resource": resource, "holders": [], "lock_type": self._lock_type(resource)}

    def _read_lock(self, resource: str) -> dict:
        """Read current lock state for a resource."""
        lf = self._lock_file(resource)
        if not lf.exists():
            return self._empty_lock(resource)
        try:
            with open(lf, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, OSError, TypeError):
            return self._empty_lock(resource)
        if not isinstance(data, dict):
            return self._empty_lock(resource)
        holders = data.get("holders", [])
        if not isinstance(holders, list):
            holders = []
        data["holders"] = [h for h in holders if isinstance(h, dict)]
        data.setdefault("resource", resource)
        data.setdefault("lock_type", self._lock_type(resource))
        return data

    def _write_lock(self, resource: str, lock_data: dict) -> None:
        """Write lock state for a resource atomically."""
        atomic_write_json(self._lock_file(resource), lock_data)

    def _lock_type(self, resource: str) -> str:
        if resource in self.EXCLUSIVE_RESOURCES:
            return "EXCLUSIVE"
        if resource in self.SHARED_RESOURCES:
            return "SHARED"
        return "UNKNOWN"

    def acquire(self, resource: str, agent_id: str, action: str,
                expected_minutes: int = 30) -> bool:
        """Attempt to acquire a resource lock.

        Args:
            resource: Resource name (must be in ALL_RESOURCES)
            agent_id: Agent requesting the lock
            action: Description of what the agent will do
            expected_minutes: Expected hold time in minutes

        Returns:
            True if lock acquired, False if blocked.
        """
        if resource not in self.ALL_RESOURCES:
            raise ValueError(
                f"Unknown resource: {resource}. "
                f"Valid: {sorted(self.ALL_RESOURCES)}"
            )
        agent_id = safe_agent_id(agent_id)

        lock_data = self._read_lock(resource)
        lock_type = self._lock_type(resource)

        for holder in lock_data.get("holders", []):
            if holder.get("agent_id") == agent_id:
                holder["action"] = action
                holder["timestamp"] = datetime.now(timezone.utc).isoformat()
                holder["expected_release"] = (
                    datetime.now(timezone.utc) + timedelta(minutes=expected_minutes)
                ).isoformat()
                self._write_lock(resource, lock_data)
                return True

        if lock_type == "EXCLUSIVE" and lock_data.get("holders"):
            return False

        holder_entry = {
            "agent_id": agent_id,
            "action": action,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "expected_release": (
                datetime.now(timezone.utc) + timedelta(minutes=expected_minutes)
            ).isoformat(),
        }

        if "holders" not in lock_data:
            lock_data["holders"] = []
        lock_data["holders"].append(holder_entry)
        lock_data["lock_type"] = lock_type
        lock_data["resource"] = resource

        self._write_lock(resource, lock_data)
        return True

    def release(self, resource: str, agent_id: str) -> bool:
        """Release a resource lock.

        Returns:
            True if released, False if agent didn't hold the lock.
        """
        if resource not in self.ALL_RESOURCES:
            return False
        try:
            agent_id = safe_agent_id(agent_id)
        except ValueError:
            return False

        lock_data = self._read_lock(resource)
        original_count = len(lock_data.get("holders", []))
        lock_data["holders"] = [
            h for h in lock_data.get("holders", [])
            if h.get("agent_id") != agent_id
        ]

        if len(lock_data["holders"]) < original_count:
            if lock_data["holders"]:
                self._write_lock(resource, lock_data)
            else:
                lf = self._lock_file(resource)
                try:
                    lf.unlink()
                except FileNotFoundError:
                    pass
                except OSError:
                    pass
            return True
        return False

    def release_all(self, agent_id: str) -> list:
        """Release all locks held by an agent. Returns list of released resources."""
        released = []
        try:
            agent_id = safe_agent_id(agent_id)
        except ValueError:
            return released
        for resource in self.ALL_RESOURCES:
            if self.release(resource, agent_id):
                released.append(resource)
        return released

    def status(self) -> dict:
        """Return status of all resources."""
        result = {}
        for resource in sorted(self.ALL_RESOURCES):
            lock_data = self._read_lock(resource)
            result[resource] = {
                "lock_type": self._lock_type(resource),
                "holders": lock_data.get("holders", []),
                "available": len(lock_data.get("holders", [])) == 0
                if resource in self.EXCLUSIVE_RESOURCES
                else True,
            }
        return result

    def check_stale(self, max_age_minutes: int = 60) -> list:
        """Find locks held longer than their expected duration.

        Returns:
            List of (resource, holder) tuples for stale locks.
        """
        stale = []
        now = datetime.now(timezone.utc)

        for resource in self.ALL_RESOURCES:
            lock_data = self._read_lock(resource)
            for holder in lock_data.get("holders", []):
                expected = holder.get("expected_release")
                if expected:
                    try:
                        exp_dt = datetime.fromisoformat(expected)
                        if now > exp_dt:
                            stale.append((resource, holder))
                    except (ValueError, TypeError):
                        continue
        return stale


if __name__ == "__main__":
    import sys

    configure_stdio()
    base = str(Path(__file__).parent)
    rl = ResourceLock(base)

    if len(sys.argv) < 2 or sys.argv[1] == "status":
        status = rl.status()
        safe_print("=== Resource Lock Status ===")
        for resource, info in status.items():
            lock_type = info["lock_type"]
            holders = info["holders"]
            if holders:
                holder_str = ", ".join(str(h.get("agent_id", "?")) for h in holders)
                safe_print(f"  [{lock_type}] {resource}: HELD by {holder_str}")
            else:
                safe_print(f"  [{lock_type}] {resource}: available")

        stale = rl.check_stale()
        if stale:
            safe_print("\nSTALE locks detected:")
            for resource, holder in stale:
                safe_print(
                    f"  {resource} held by {holder.get('agent_id')} "
                    f"since {holder.get('timestamp')}"
                )

    elif sys.argv[1] == "acquire" and len(sys.argv) >= 5:
        resource, agent_id, action = sys.argv[2], sys.argv[3], " ".join(sys.argv[4:])
        try:
            ok = rl.acquire(resource, agent_id, action)
        except ValueError as e:
            safe_print(f"BLOCKED: {e}")
            sys.exit(1)
        if ok:
            safe_print(f"OK Lock acquired: {resource} by {agent_id}")
        else:
            safe_print(f"BLOCKED Lock: {resource} is held exclusively by another agent")
            sys.exit(2)

    elif sys.argv[1] == "release" and len(sys.argv) >= 4:
        resource, agent_id = sys.argv[2], sys.argv[3]
        if rl.release(resource, agent_id):
            safe_print(f"OK Lock released: {resource} by {agent_id}")
        else:
            safe_print(f"BLOCKED Agent {agent_id} did not hold {resource}")
            sys.exit(2)

    else:
        safe_print("Usage:")
        safe_print("  python resource_lock.py status")
        safe_print("  python resource_lock.py acquire <resource> <agent_id> <action>")
        safe_print("  python resource_lock.py release <resource> <agent_id>")
