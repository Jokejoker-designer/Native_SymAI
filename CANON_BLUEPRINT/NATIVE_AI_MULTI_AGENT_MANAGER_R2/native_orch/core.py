from __future__ import annotations
import json, os, pathlib, subprocess, time, fnmatch
from .db import DB

PASS_RANK = {
  'PENDING':0,'READY':1,'RUNNING':2,'PAUSED':2,'PAUSED_STALE':2,'BLOCKED':2,
  'FAIL':0,'FAIL_PARTIAL':0,'REVIEW_REQUIRED':3,'CANDIDATE_PASS':4,'PASS':5
}


def _j(x):
    return json.dumps(x, ensure_ascii=False, sort_keys=True)

def _loads(x, default):
    try: return json.loads(x) if x else default
    except Exception: return default

def git_state(worktree: pathlib.Path):
    def run(*args):
        try:
            p=subprocess.run(['git',*args], cwd=worktree, capture_output=True, text=True, timeout=20)
            return p.stdout.strip() if p.returncode==0 else ''
        except Exception: return ''
    commit=run('rev-parse','HEAD')
    dirty=[x for x in run('status','--porcelain').splitlines() if x]
    return commit, dirty

def prefix_conflict(a:str,b:str)->bool:
    a=a.replace('\\','/').rstrip('/')
    b=b.replace('\\','/').rstrip('/')
    return a==b or a.startswith(b+'/') or b.startswith(a+'/')

class Orchestrator:
    def __init__(self, coord_root:pathlib.Path):
        self.db=DB(coord_root)

    def register_agent(self, agent, capabilities, state='ONLINE', notes=''):
        now=time.time()
        caps=sorted(set(capabilities))
        with self.db.tx() as c:
            c.execute('''INSERT INTO agents(agent,capabilities,state,heartbeat,notes) VALUES(?,?,?,?,?)
              ON CONFLICT(agent) DO UPDATE SET capabilities=excluded.capabilities,state=excluded.state,heartbeat=excluded.heartbeat,notes=excluded.notes''',
              (agent,_j(caps),state,now,notes))
            self.db.event(c,'AGENT_REGISTER',agent,payload={'capabilities':caps,'state':state})
        return self.agent(agent)

    def agent(self, agent):
        with self.db.connect() as c:
            r=c.execute('SELECT * FROM agents WHERE agent=?',(agent,)).fetchone()
            return dict(r) if r else None

    def heartbeat(self, agent, state=None):
        with self.db.tx() as c:
            r=c.execute('SELECT * FROM agents WHERE agent=?',(agent,)).fetchone()
            if not r: raise RuntimeError(f'Unknown agent: {agent}')
            st=state or r['state']
            c.execute('UPDATE agents SET heartbeat=?,state=? WHERE agent=?',(time.time(),st,agent))
            self.db.event(c,'AGENT_HEARTBEAT',agent,payload={'state':st})
        return self.agent(agent)

    def set_agent_state(self, agent, state, release_tasks=False):
        now=time.time()
        with self.db.tx() as c:
            c.execute('UPDATE agents SET state=?,heartbeat=? WHERE agent=?',(state,now,agent))
            if release_tasks:
                rows=c.execute("SELECT task_id FROM tasks WHERE owner=? AND status='RUNNING'",(agent,)).fetchall()
                for r in rows:
                    c.execute("UPDATE tasks SET status='PAUSED',owner=NULL,lease_expires=NULL,updated=? WHERE task_id=?",(now,r['task_id']))
                    self.db.event(c,'TASK_RELEASED',agent,r['task_id'],{'reason':state})
            self.db.event(c,'AGENT_STATE',agent,payload={'state':state,'release_tasks':release_tasks})

    def add_task(self, spec:dict):
        now=time.time()
        tid=spec['task_id']
        with self.db.tx() as c:
            c.execute('''INSERT INTO tasks(task_id,title,role,objective,priority,status,independent_review,allow_candidate_inputs,
              write_scopes,protected_scopes,acceptance,evidence_required,context_files,created,updated)
              VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
              ON CONFLICT(task_id) DO UPDATE SET title=excluded.title,role=excluded.role,objective=excluded.objective,priority=excluded.priority,
              independent_review=excluded.independent_review,allow_candidate_inputs=excluded.allow_candidate_inputs,
              write_scopes=excluded.write_scopes,protected_scopes=excluded.protected_scopes,acceptance=excluded.acceptance,
              evidence_required=excluded.evidence_required,context_files=excluded.context_files,updated=excluded.updated''',
              (tid,spec.get('title',tid),spec.get('role','GENERAL'),spec.get('objective',''),int(spec.get('priority',100)),
               spec.get('status','PENDING'),1 if spec.get('independent_review') else 0,1 if spec.get('allow_candidate_inputs') else 0,
               _j(spec.get('write_scopes',[])),_j(spec.get('protected_scopes',[])),spec.get('acceptance',''),spec.get('evidence_required',''),
               _j(spec.get('context_files',[])),now,now))
            c.execute('DELETE FROM deps WHERE task_id=?',(tid,))
            for d in spec.get('deps',[]):
                if isinstance(d,str): dep_id,min_status=d,'PASS'
                else: dep_id,min_status=d['task_id'],d.get('min_status','PASS')
                c.execute('INSERT INTO deps(task_id,dep_id,min_status) VALUES(?,?,?)',(tid,dep_id,min_status))
            self.db.event(c,'TASK_UPSERT',task_id=tid,payload=spec)
        return self.task(tid)

    def import_plan(self, path:pathlib.Path):
        data=json.loads(path.read_text(encoding='utf-8'))
        # Insert no-dep tasks first, then all; FK deps require referenced rows.
        for spec in data['tasks']:
            tmp=dict(spec); tmp['deps']=[]; self.add_task(tmp)
        for spec in data['tasks']: self.add_task(spec)
        return {'tasks':len(data['tasks'])}

    def task(self, tid):
        with self.db.connect() as c:
            r=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not r: return None
            x=dict(r)
            x['deps']=[dict(d) for d in c.execute('SELECT dep_id,min_status FROM deps WHERE task_id=?',(tid,)).fetchall()]
            x['write_scopes']=_loads(x['write_scopes'],[]); x['protected_scopes']=_loads(x['protected_scopes'],[]); x['context_files']=_loads(x['context_files'],[])
            return x

    def _deps_ok(self,c,tid):
        rows=c.execute('''SELECT d.dep_id,d.min_status,t.status FROM deps d JOIN tasks t ON t.task_id=d.dep_id WHERE d.task_id=?''',(tid,)).fetchall()
        bad=[]
        for r in rows:
            if PASS_RANK.get(r['status'],0) < PASS_RANK.get(r['min_status'],5): bad.append(dict(r))
        return not bad,bad

    def refresh_ready(self):
        changed=[]
        with self.db.tx() as c:
            rows=c.execute("SELECT task_id,status FROM tasks WHERE status IN ('PENDING','BLOCKED','PAUSED','PAUSED_STALE','READY')").fetchall()
            for r in rows:
                ok,bad=self._deps_ok(c,r['task_id'])
                target='READY' if ok else 'BLOCKED'
                if r['status']!=target:
                    c.execute('UPDATE tasks SET status=?,updated=? WHERE task_id=?',(target,time.time(),r['task_id']))
                    changed.append((r['task_id'],target))
        return changed

    def _cap_ok(self, agent_row, task_row, solo=False):
        caps=set(_loads(agent_row['capabilities'],[]))
        role=task_row['role']
        return solo or role in caps or 'GENERAL' in caps or '*' in caps

    def _scopes_conflict(self,c,task_id,scopes):
        active=c.execute("SELECT task_id,owner,write_scopes FROM tasks WHERE status='RUNNING' AND task_id<>?",(task_id,)).fetchall()
        hits=[]
        for r in active:
            other=_loads(r['write_scopes'],[])
            for a in scopes:
                for b in other:
                    if prefix_conflict(a,b): hits.append({'task_id':r['task_id'],'owner':r['owner'],'a':a,'b':b})
        return hits

    def next_task(self, agent, solo=False, ttl=3600, auto_claim=False):
        self.refresh_ready(); now=time.time()
        with self.db.tx() as c:
            ar=c.execute('SELECT * FROM agents WHERE agent=?',(agent,)).fetchone()
            if not ar: raise RuntimeError(f'Unknown agent: {agent}')
            if ar['state'] not in ('ONLINE','DEGRADED'): raise RuntimeError(f'Agent {agent} state={ar["state"]}')
            rows=c.execute("SELECT * FROM tasks WHERE status='READY' ORDER BY priority ASC,created ASC").fetchall()
            for r in rows:
                if not self._cap_ok(ar,r,solo): continue
                scopes=_loads(r['write_scopes'],[])
                conflicts=self._scopes_conflict(c,r['task_id'],scopes)
                if conflicts: continue
                out=dict(r); out['write_scopes']=scopes; out['context_files']=_loads(r['context_files'],[])
                if auto_claim:
                    c.execute("UPDATE tasks SET status='RUNNING',owner=?,lease_expires=?,updated=? WHERE task_id=? AND status='READY'",
                              (agent,now+ttl,now,r['task_id']))
                    if c.total_changes:
                        self.db.event(c,'TASK_CLAIM',agent,r['task_id'],{'solo':solo,'ttl':ttl})
                        out['status']='RUNNING'; out['owner']=agent; out['lease_expires']=now+ttl
                        return out
                else: return out
        return None

    def claim(self, tid, agent, solo=False, ttl=3600):
        self.refresh_ready(); now=time.time()
        with self.db.tx() as c:
            ar=c.execute('SELECT * FROM agents WHERE agent=?',(agent,)).fetchone(); tr=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not ar or not tr: raise RuntimeError('Unknown agent/task')
            if tr['status']!='READY': raise RuntimeError(f'Task {tid} not READY: {tr["status"]}')
            if not self._cap_ok(ar,tr,solo): raise RuntimeError(f'Agent lacks capability role={tr["role"]}')
            conflicts=self._scopes_conflict(c,tid,_loads(tr['write_scopes'],[]))
            if conflicts: raise RuntimeError(f'Write scope conflict: {conflicts}')
            c.execute("UPDATE tasks SET status='RUNNING',owner=?,lease_expires=?,updated=? WHERE task_id=?",(agent,now+ttl,now,tid))
            self.db.event(c,'TASK_CLAIM',agent,tid,{'solo':solo,'ttl':ttl})
        return self.task(tid)

    def checkpoint(self, tid, agent, worktree:pathlib.Path, notes='', next_step='', blockers=None, evidence=None, status='WORKING'):
        commit,dirty=git_state(worktree); now=time.time()
        with self.db.tx() as c:
            tr=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not tr or tr['owner']!=agent: raise RuntimeError(f'{agent} does not own {tid}')
            c.execute('''INSERT INTO checkpoints(task_id,agent,created,status,git_commit,dirty_files,notes,next_step,blockers,evidence)
                         VALUES(?,?,?,?,?,?,?,?,?,?)''',(tid,agent,now,status,commit,_j(dirty),notes,next_step,_j(blockers or []),_j(evidence or {})))
            c.execute('UPDATE tasks SET lease_expires=?,updated=? WHERE task_id=?',(now+3600,now,tid))
            self.db.event(c,'CHECKPOINT',agent,tid,{'status':status,'git_commit':commit,'dirty_count':len(dirty),'next_step':next_step})
        return self.latest_checkpoint(tid)

    def latest_checkpoint(self, tid):
        with self.db.connect() as c:
            r=c.execute('SELECT * FROM checkpoints WHERE task_id=? ORDER BY id DESC LIMIT 1',(tid,)).fetchone()
            if not r:return None
            x=dict(r); x['dirty_files']=_loads(x['dirty_files'],[]); x['blockers']=_loads(x['blockers'],[]); x['evidence']=_loads(x['evidence'],{})
            return x

    def pause(self, tid, agent, reason='PAUSED'):
        with self.db.tx() as c:
            tr=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not tr or tr['owner']!=agent: raise RuntimeError('Not owner')
            c.execute("UPDATE tasks SET status='PAUSED',owner=NULL,lease_expires=NULL,updated=? WHERE task_id=?",(time.time(),tid))
            self.db.event(c,'TASK_PAUSE',agent,tid,{'reason':reason})
        self.refresh_ready()

    def finish(self, tid, agent, verdict, evidence=None, force_candidate=False):
        verdict=verdict.upper(); now=time.time()
        if verdict not in ('PASS','FAIL','FAIL_PARTIAL','REVIEW_REQUIRED','CANDIDATE_PASS'): raise ValueError(verdict)
        with self.db.tx() as c:
            tr=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not tr or tr['owner']!=agent: raise RuntimeError('Not owner')
            final=verdict
            if verdict=='PASS' and (tr['independent_review'] or force_candidate): final='CANDIDATE_PASS'
            c.execute('UPDATE tasks SET status=?,owner=NULL,lease_expires=NULL,updated=? WHERE task_id=?',(final,now,tid))
            self.db.event(c,'TASK_FINISH',agent,tid,{'requested':verdict,'final':final,'evidence':evidence or {}})
        self.refresh_ready(); return self.task(tid)

    def review(self, tid, reviewer, verdict, evidence=None):
        verdict=verdict.upper(); now=time.time()
        if verdict not in ('PASS','FAIL','REVIEW_REQUIRED'): raise ValueError(verdict)
        with self.db.tx() as c:
            tr=c.execute('SELECT * FROM tasks WHERE task_id=?',(tid,)).fetchone()
            if not tr: raise RuntimeError('Unknown task')
            # Reviewer must be different from last producer if independent review.
            last=c.execute("SELECT agent FROM events WHERE task_id=? AND kind='TASK_FINISH' ORDER BY id DESC LIMIT 1",(tid,)).fetchone()
            if tr['independent_review'] and last and last['agent']==reviewer:
                raise RuntimeError('Independent review requires a different agent')
            c.execute('INSERT OR REPLACE INTO reviews(task_id,reviewer,verdict,evidence,created) VALUES(?,?,?,?,?)',(tid,reviewer,verdict,_j(evidence or {}),now))
            c.execute('UPDATE tasks SET status=?,updated=? WHERE task_id=?',(verdict,now,tid))
            self.db.event(c,'TASK_REVIEW',reviewer,tid,{'verdict':verdict,'evidence':evidence or {}})
        self.refresh_ready(); return self.task(tid)

    def sweep_stale(self, stale_agent_after=900):
        now=time.time(); reclaimed=[]; offline=[]
        with self.db.tx() as c:
            ars=c.execute("SELECT * FROM agents WHERE state IN ('ONLINE','DEGRADED')").fetchall()
            for a in ars:
                if now-a['heartbeat']>stale_agent_after:
                    c.execute("UPDATE agents SET state='STALE' WHERE agent=?",(a['agent'],)); offline.append(a['agent'])
            rows=c.execute("SELECT * FROM tasks WHERE status='RUNNING'").fetchall()
            for r in rows:
                ar=c.execute('SELECT state,heartbeat FROM agents WHERE agent=?',(r['owner'],)).fetchone()
                expired=(r['lease_expires'] or 0)<now
                stale=(not ar) or ar['state'] in ('STALE','OFFLINE','QUOTA_EXHAUSTED')
                if expired or stale:
                    c.execute("UPDATE tasks SET status='PAUSED_STALE',owner=NULL,lease_expires=NULL,updated=? WHERE task_id=?",(now,r['task_id']))
                    self.db.event(c,'TASK_RECLAIM',r['owner'],r['task_id'],{'expired':expired,'stale_agent':stale})
                    reclaimed.append(r['task_id'])
        self.refresh_ready(); return {'offline_agents':offline,'reclaimed_tasks':reclaimed}

    def takeover(self, tid, agent, solo=False, ttl=3600):
        self.refresh_ready()
        t=self.task(tid)
        if not t: raise RuntimeError('Unknown task')
        if t['status']!='READY': raise RuntimeError(f'Not READY: {t["status"]}')
        claimed=self.claim(tid,agent,solo,ttl)
        return {'task':claimed,'checkpoint':self.latest_checkpoint(tid)}

    def status(self):
        self.refresh_ready()
        with self.db.connect() as c:
            agents=[dict(r) for r in c.execute('SELECT * FROM agents ORDER BY agent').fetchall()]
            tasks=[dict(r) for r in c.execute('SELECT task_id,title,role,priority,status,owner,lease_expires FROM tasks ORDER BY priority,task_id').fetchall()]
            return {'agents':agents,'tasks':tasks}

    def context_packet(self, tid, out:pathlib.Path):
        t=self.task(tid)
        if not t: raise RuntimeError('Unknown task')
        cp=self.latest_checkpoint(tid)
        lines=[f'# TASK CAPSULE — {tid}', '', f'**Title:** {t["title"]}', f'**Role:** {t["role"]}', f'**Status:** {t["status"]}', '', '## Objective', t['objective'] or '(none)', '', '## Acceptance', t['acceptance'] or '(none)', '', '## Evidence required', t['evidence_required'] or '(none)', '', '## Allowed write scopes']
        lines += [f'- `{x}`' for x in t['write_scopes']] or ['- (none declared)']
        lines += ['', '## Context files'] + ([f'- `{x}`' for x in t['context_files']] or ['- (none declared)'])
        lines += ['', '## Dependencies'] + ([f'- `{d["dep_id"]}` >= `{d["min_status"]}`' for d in t['deps']] or ['- none'])
        if cp:
            lines += ['', '## Latest checkpoint', f'- Agent: `{cp["agent"]}`', f'- Git: `{cp.get("git_commit") or "unknown"}`', f'- Status: `{cp["status"]}`', f'- Next step: {cp.get("next_step") or "(none)"}', f'- Notes: {cp.get("notes") or "(none)"}', f'- Blockers: `{cp.get("blockers",[])}`', f'- Dirty files: `{cp.get("dirty_files",[])}`']
        lines += ['', '## Operating rule', 'Continue from the latest checkpoint. Do not reinterpret protected project authority. If independent review is required and you are the producer, finish as CANDIDATE_PASS; a different agent or owner must review it.']
        out.parent.mkdir(parents=True,exist_ok=True); out.write_text('\n'.join(lines)+'\n',encoding='utf-8')
        return {'out':str(out),'task_id':tid}
