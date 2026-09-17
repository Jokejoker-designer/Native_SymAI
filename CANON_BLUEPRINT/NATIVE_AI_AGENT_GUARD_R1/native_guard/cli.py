from __future__ import annotations
import argparse,json,pathlib,sys,os
from .config import load_config
from .locks import LeaseManager
from .manifest import snapshot,diff
from .evidence import EvidenceLog
from .tasks import TaskDB
from .runner import run_stage
from .vivado import parse_timing,parse_util,scan_report,evaluate,write_tcl
from .authority import freeze_contract,verify_contract,protected_violations
from .logscan import scan as scan_log
from .doctor import run_doctor
from .util import atomic_write_json,load_json

def jprint(x): print(json.dumps(x,indent=2,sort_keys=True,ensure_ascii=False))

def main(argv=None):
    ap=argparse.ArgumentParser(prog="native-guard",description="Native AI multi-agent FPGA guard")
    ap.add_argument("--root",default="."); ap.add_argument("--config",default=None)
    sub=ap.add_subparsers(dest="cmd",required=True)
    p=sub.add_parser("init"); p.add_argument("--force",action="store_true")
    p=sub.add_parser("claim"); p.add_argument("key"); p.add_argument("--agent",required=True); p.add_argument("--ttl",type=int,default=3600); p.add_argument("--stale",action="store_true")
    p=sub.add_parser("release"); p.add_argument("key"); p.add_argument("--agent",required=True)
    p=sub.add_parser("claim-file"); p.add_argument("path"); p.add_argument("--agent",required=True); p.add_argument("--ttl",type=int,default=3600)
    p=sub.add_parser("leases")
    p=sub.add_parser("snapshot"); p.add_argument("--out",default=None)
    p=sub.add_parser("freeze-contract"); p.add_argument("name")
    p=sub.add_parser("verify-contract"); p.add_argument("name")
    p=sub.add_parser("task-claim"); p.add_argument("stage"); p.add_argument("--agent",required=True); p.add_argument("--ttl",type=int,default=7200)
    p=sub.add_parser("task-finish"); p.add_argument("stage"); p.add_argument("status"); p.add_argument("--agent",required=True); p.add_argument("--evidence",default="{}")
    p=sub.add_parser("task-invalidate"); p.add_argument("stage"); p.add_argument("--agent",required=True); p.add_argument("--reason",required=True)
    p=sub.add_parser("tasks")
    p=sub.add_parser("run"); p.add_argument("stage"); p.add_argument("--agent",required=True); p.add_argument("--timeout",type=int,default=7200); p.add_argument("--resource",default=None); p.add_argument("--expect-marker",default=None); p.add_argument("--fail-marker",action="append",default=[]); p.add_argument("command",nargs=argparse.REMAINDER)
    p=sub.add_parser("vivado-tcl"); p.add_argument("--out",default="native_guard_signoff.tcl"); p.add_argument("--reports-dir",default="native_guard_reports")
    p=sub.add_parser("vivado-check"); p.add_argument("--timing",required=True); p.add_argument("--util"); p.add_argument("--drc"); p.add_argument("--methodology"); p.add_argument("--cdc"); p.add_argument("--clock-interaction"); p.add_argument("--out",default=None)
    p=sub.add_parser("log-scan"); p.add_argument("log")
    p=sub.add_parser("authority-check"); p.add_argument("--role",default="agent")
    p=sub.add_parser("doctor")
    p=sub.add_parser("evidence-verify")
    args=ap.parse_args(argv); root=pathlib.Path(args.root).resolve(); cfg=load_config(root,args.config)
    if args.cmd=="init":
        ng=root/".native_guard"; ng.mkdir(parents=True,exist_ok=True)
        cfgp=root/"guard_config.json"
        if args.force or not cfgp.exists(): atomic_write_json(cfgp,cfg)
        TaskDB(root,cfg); print(f"initialized {ng}"); return 0
    lm=LeaseManager(root)
    if args.cmd=="claim": jprint(lm.acquire(args.key,args.agent,args.ttl,args.stale)); return 0
    if args.cmd=="release": lm.release(args.key,args.agent); print("released"); return 0
    if args.cmd=="claim-file": jprint(lm.claim_file(args.path,args.agent,args.ttl)); return 0
    if args.cmd=="leases": jprint(lm.list()); return 0
    if args.cmd=="snapshot":
        out=pathlib.Path(args.out) if args.out else root/".native_guard"/"snapshot.json"; jprint(snapshot(root,cfg,out)); return 0
    if args.cmd=="freeze-contract": jprint(freeze_contract(root,cfg,args.name)); return 0
    if args.cmd=="verify-contract":
        ch,a,b=verify_contract(root,cfg,args.name); jprint({"changes":ch,"ok":not ch,"base":a["manifest_sha256"],"current":b["manifest_sha256"]}); return 0 if not ch else 2
    td=TaskDB(root,cfg)
    if args.cmd=="task-claim": jprint(td.claim(args.stage,args.agent,args.ttl)); return 0
    if args.cmd=="task-finish": td.finish(args.stage,args.agent,args.status,json.loads(args.evidence)); print("updated"); return 0
    if args.cmd=="task-invalidate": jprint({"invalidated":td.invalidate_from(args.stage,args.reason,args.agent)}); return 0
    if args.cmd=="tasks": jprint(td.show()); return 0
    if args.cmd=="run":
        cmd=args.command[1:] if args.command and args.command[0]=="--" else args.command
        if not cmd: raise SystemExit("command required after --")
        result,run_dir=run_stage(root,cfg,args.stage,args.agent,cmd,args.timeout,args.resource,args.expect_marker,args.fail_marker)
        jprint({"run_dir":str(run_dir),**result}); return 0 if result["status"]=="PASS" else 3
    if args.cmd=="vivado-tcl": write_tcl(root/args.out,args.reports_dir); print(str(root/args.out)); return 0
    if args.cmd=="vivado-check":
        timing=parse_timing(pathlib.Path(args.timing).read_text(encoding="utf-8",errors="replace")); util=parse_util(pathlib.Path(args.util).read_text(encoding="utf-8",errors="replace")) if args.util else {}
        hits={}
        for name in ["drc","methodology","cdc","clock_interaction"]:
            p=getattr(args,name.replace("_","-"),None) if False else None
        for name,val in [("drc",args.drc),("methodology",args.methodology),("cdc",args.cdc),("clock_interaction",args.clock_interaction)]:
            hits[name]=scan_report(pathlib.Path(val).read_text(encoding="utf-8",errors="replace"),cfg.get("critical_log_patterns",[])) if val else []
        res=evaluate(timing,util,cfg,hits)
        if args.out: atomic_write_json(pathlib.Path(args.out),res)
        jprint(res); return 0 if res["status"]=="PASS" else 4
    if args.cmd=="log-scan": jprint(scan_log(pathlib.Path(args.log),cfg.get("critical_log_patterns",[]))); return 0
    if args.cmd=="authority-check":
        bad=protected_violations(root,cfg,args.role); jprint({"role":args.role,"violations":bad,"ok":not bad}); return 0 if not bad else 5
    if args.cmd=="doctor": jprint(run_doctor(root,cfg)); return 0
    if args.cmd=="evidence-verify":
        ok,n,err=EvidenceLog(root).verify(); jprint({"ok":ok,"entries":n,"error":err}); return 0 if ok else 6
    return 1

if __name__=="__main__": raise SystemExit(main())
