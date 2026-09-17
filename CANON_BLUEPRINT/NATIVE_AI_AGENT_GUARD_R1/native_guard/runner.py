from __future__ import annotations
import json, os, pathlib, shlex, signal, subprocess, time
from .manifest import snapshot, diff
from .util import atomic_write_json, utc_ts, sha256_file
from .locks import LeaseManager
from .evidence import EvidenceLog


def _kill_tree(proc: subprocess.Popen):
    try:
        if os.name == "nt":
            subprocess.run(["taskkill","/PID",str(proc.pid),"/T","/F"], capture_output=True)
        else:
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM); time.sleep(1)
            if proc.poll() is None: os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
    except Exception:
        try: proc.kill()
        except Exception: pass


def run_stage(root:pathlib.Path,cfg:dict,stage:str,agent:str,cmd:list[str],timeout:int=7200,resource:str|None=None,expect_marker:str|None=None,fail_markers:list[str]|None=None):
    if not cmd:
        raise ValueError("empty command")
    exe=pathlib.Path(cmd[0]).name.lower()
    allowed={x.lower() for x in cfg.get("allowed_executables", [])}
    if allowed and exe not in allowed:
        raise RuntimeError(f"Executable not allowed by guard_config.json: {exe}. Allowed: {sorted(allowed)}")
    lm=LeaseManager(root); ev=EvidenceLog(root)
    lease_key=resource or ("vivado_impl" if stage in {"synth","impl","post_route","program"} else "stage__"+stage)
    lm.acquire(lease_key,agent,timeout+600,force_stale=True)
    run_id=time.strftime("%Y%m%d_%H%M%S")+f"_{stage}_{agent}"
    run_dir=root/".native_guard"/"runs"/run_id; run_dir.mkdir(parents=True,exist_ok=False)
    pre=snapshot(root,cfg,run_dir/"source_manifest_pre.json")
    env=os.environ.copy(); env["NATIVE_GUARD_RUN_ID"]=run_id; env["NATIVE_GUARD_AGENT"]=agent
    log=run_dir/"stdout_stderr.log"
    creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name=="nt" else 0
    preexec_fn=os.setsid if os.name!="nt" else None
    t0=time.time(); rc=None; timed_out=False
    with log.open("w",encoding="utf-8",errors="replace") as f:
        f.write(f"# UTC {utc_ts()}\n# CMD {json.dumps(cmd)}\n# CWD {root}\n")
        f.flush()
        p=subprocess.Popen(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT,text=True,env=env,creationflags=creationflags,preexec_fn=preexec_fn)
        try: rc=p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            timed_out=True; _kill_tree(p); rc=-999
    post=snapshot(root,cfg,run_dir/"source_manifest_post.json")
    changes=diff(pre,post)
    text=log.read_text(encoding="utf-8",errors="replace")
    marker_ok=(expect_marker is None or text.count(expect_marker)==1)
    fail_hit=[m for m in (fail_markers or []) if m in text]
    immutable_ok=not changes
    status="PASS" if rc==0 and not timed_out and marker_ok and not fail_hit and immutable_ok else "FAIL"
    result={"run_id":run_id,"stage":stage,"agent":agent,"command":cmd,"rc":rc,"timeout":timed_out,"elapsed_s":round(time.time()-t0,3),"expect_marker":expect_marker,"marker_ok":marker_ok,"fail_markers_hit":fail_hit,"source_changed_during_run":changes,"pre_manifest":pre["manifest_sha256"],"post_manifest":post["manifest_sha256"],"log_sha256":sha256_file(log),"status":status}
    atomic_write_json(run_dir/"result.json",result); ev.append("RUN_STAGE",status,agent,result)
    lm.release(lease_key,agent)
    return result,run_dir
