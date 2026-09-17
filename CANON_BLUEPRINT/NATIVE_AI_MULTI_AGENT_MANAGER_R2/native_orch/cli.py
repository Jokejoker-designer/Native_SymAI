from __future__ import annotations
import argparse, json, pathlib, sys
from .core import Orchestrator

def jp(x): print(json.dumps(x,indent=2,sort_keys=True,ensure_ascii=False))

def main(argv=None):
    ap=argparse.ArgumentParser(prog='native-orch',description='Resumable work-stealing orchestrator for Native AI agents')
    ap.add_argument('--coord-root',default='.')
    sub=ap.add_subparsers(dest='cmd',required=True)
    p=sub.add_parser('init')
    p=sub.add_parser('agent-register'); p.add_argument('--agent',required=True); p.add_argument('--cap',action='append',default=[]); p.add_argument('--state',default='ONLINE'); p.add_argument('--notes',default='')
    p=sub.add_parser('agent-heartbeat'); p.add_argument('--agent',required=True); p.add_argument('--state')
    p=sub.add_parser('agent-state'); p.add_argument('--agent',required=True); p.add_argument('state'); p.add_argument('--release-tasks',action='store_true')
    p=sub.add_parser('plan-import'); p.add_argument('path')
    p=sub.add_parser('task-next'); p.add_argument('--agent',required=True); p.add_argument('--solo',action='store_true'); p.add_argument('--claim',action='store_true'); p.add_argument('--ttl',type=int,default=3600)
    p=sub.add_parser('task-claim'); p.add_argument('task_id'); p.add_argument('--agent',required=True); p.add_argument('--solo',action='store_true'); p.add_argument('--ttl',type=int,default=3600)
    p=sub.add_parser('task-checkpoint'); p.add_argument('task_id'); p.add_argument('--agent',required=True); p.add_argument('--worktree',required=True); p.add_argument('--notes',default=''); p.add_argument('--next-step',default=''); p.add_argument('--blocker',action='append',default=[]); p.add_argument('--evidence',default='{}'); p.add_argument('--status',default='WORKING')
    p=sub.add_parser('task-pause'); p.add_argument('task_id'); p.add_argument('--agent',required=True); p.add_argument('--reason',default='PAUSED')
    p=sub.add_parser('task-finish'); p.add_argument('task_id'); p.add_argument('verdict'); p.add_argument('--agent',required=True); p.add_argument('--evidence',default='{}'); p.add_argument('--force-candidate',action='store_true')
    p=sub.add_parser('task-review'); p.add_argument('task_id'); p.add_argument('verdict'); p.add_argument('--reviewer',required=True); p.add_argument('--evidence',default='{}')
    p=sub.add_parser('task-takeover'); p.add_argument('task_id'); p.add_argument('--agent',required=True); p.add_argument('--solo',action='store_true'); p.add_argument('--ttl',type=int,default=3600)
    p=sub.add_parser('task-context'); p.add_argument('task_id'); p.add_argument('--out',required=True)
    p=sub.add_parser('sweep'); p.add_argument('--stale-after',type=int,default=900)
    p=sub.add_parser('status')
    args=ap.parse_args(argv); root=pathlib.Path(args.coord_root).resolve(); o=Orchestrator(root)
    if args.cmd=='init': jp({'coord_root':str(root),'db':str(o.db.path)}); return 0
    if args.cmd=='agent-register': jp(o.register_agent(args.agent,args.cap,args.state,args.notes)); return 0
    if args.cmd=='agent-heartbeat': jp(o.heartbeat(args.agent,args.state)); return 0
    if args.cmd=='agent-state': o.set_agent_state(args.agent,args.state,args.release_tasks); jp({'ok':True}); return 0
    if args.cmd=='plan-import': jp(o.import_plan(pathlib.Path(args.path))); return 0
    if args.cmd=='task-next': jp(o.next_task(args.agent,args.solo,args.ttl,args.claim)); return 0
    if args.cmd=='task-claim': jp(o.claim(args.task_id,args.agent,args.solo,args.ttl)); return 0
    if args.cmd=='task-checkpoint': jp(o.checkpoint(args.task_id,args.agent,pathlib.Path(args.worktree),args.notes,args.next_step,args.blocker,json.loads(args.evidence),args.status)); return 0
    if args.cmd=='task-pause': o.pause(args.task_id,args.agent,args.reason); jp({'ok':True}); return 0
    if args.cmd=='task-finish': jp(o.finish(args.task_id,args.agent,args.verdict,json.loads(args.evidence),args.force_candidate)); return 0
    if args.cmd=='task-review': jp(o.review(args.task_id,args.reviewer,args.verdict,json.loads(args.evidence))); return 0
    if args.cmd=='task-takeover': jp(o.takeover(args.task_id,args.agent,args.solo,args.ttl)); return 0
    if args.cmd=='task-context': jp(o.context_packet(args.task_id,pathlib.Path(args.out))); return 0
    if args.cmd=='sweep': jp(o.sweep_stale(args.stale_after)); return 0
    if args.cmd=='status': jp(o.status()); return 0
    return 1

if __name__=='__main__': raise SystemExit(main())
