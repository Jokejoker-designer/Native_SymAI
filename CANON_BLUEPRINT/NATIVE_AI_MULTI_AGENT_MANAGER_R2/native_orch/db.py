from __future__ import annotations
import json, sqlite3, pathlib, time
from contextlib import contextmanager

SCHEMA = r'''
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS agents(
  agent TEXT PRIMARY KEY,
  capabilities TEXT NOT NULL,
  state TEXT NOT NULL DEFAULT 'ONLINE',
  heartbeat REAL NOT NULL,
  notes TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS tasks(
  task_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  role TEXT NOT NULL,
  objective TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 100,
  status TEXT NOT NULL DEFAULT 'PENDING',
  owner TEXT,
  lease_expires REAL,
  independent_review INTEGER NOT NULL DEFAULT 0,
  allow_candidate_inputs INTEGER NOT NULL DEFAULT 0,
  write_scopes TEXT NOT NULL DEFAULT '[]',
  protected_scopes TEXT NOT NULL DEFAULT '[]',
  acceptance TEXT NOT NULL DEFAULT '',
  evidence_required TEXT NOT NULL DEFAULT '',
  context_files TEXT NOT NULL DEFAULT '[]',
  created REAL NOT NULL,
  updated REAL NOT NULL,
  FOREIGN KEY(owner) REFERENCES agents(agent)
);
CREATE TABLE IF NOT EXISTS deps(
  task_id TEXT NOT NULL,
  dep_id TEXT NOT NULL,
  min_status TEXT NOT NULL DEFAULT 'PASS',
  PRIMARY KEY(task_id, dep_id),
  FOREIGN KEY(task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
  FOREIGN KEY(dep_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS reviews(
  task_id TEXT NOT NULL,
  reviewer TEXT NOT NULL,
  verdict TEXT NOT NULL,
  evidence TEXT NOT NULL DEFAULT '{}',
  created REAL NOT NULL,
  PRIMARY KEY(task_id, reviewer),
  FOREIGN KEY(task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS checkpoints(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  agent TEXT NOT NULL,
  created REAL NOT NULL,
  status TEXT NOT NULL,
  git_commit TEXT,
  dirty_files TEXT NOT NULL DEFAULT '[]',
  notes TEXT NOT NULL DEFAULT '',
  next_step TEXT NOT NULL DEFAULT '',
  blockers TEXT NOT NULL DEFAULT '[]',
  evidence TEXT NOT NULL DEFAULT '{}',
  FOREIGN KEY(task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS events(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created REAL NOT NULL,
  kind TEXT NOT NULL,
  agent TEXT,
  task_id TEXT,
  payload TEXT NOT NULL DEFAULT '{}'
);
'''

class DB:
    def __init__(self, coord_root: pathlib.Path):
        self.root = coord_root.resolve()
        self.dir = self.root / '.native_orch'
        self.dir.mkdir(parents=True, exist_ok=True)
        self.path = self.dir / 'state.db'
        with self.connect() as c:
            c.executescript(SCHEMA)

    def connect(self):
        c = sqlite3.connect(self.path, timeout=30, isolation_level=None)
        c.row_factory = sqlite3.Row
        c.execute('PRAGMA busy_timeout=30000')
        return c

    @contextmanager
    def tx(self):
        c = self.connect()
        try:
            c.execute('BEGIN IMMEDIATE')
            yield c
            c.execute('COMMIT')
        except Exception:
            c.execute('ROLLBACK')
            raise
        finally:
            c.close()

    def event(self, c, kind, agent=None, task_id=None, payload=None):
        c.execute('INSERT INTO events(created,kind,agent,task_id,payload) VALUES(?,?,?,?,?)',
                  (time.time(), kind, agent, task_id, json.dumps(payload or {}, sort_keys=True)))
