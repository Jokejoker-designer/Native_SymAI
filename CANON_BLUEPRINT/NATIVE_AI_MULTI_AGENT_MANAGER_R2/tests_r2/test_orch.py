import pathlib, tempfile, json
from native_orch.core import Orchestrator

def test_failover_and_solo():
    with tempfile.TemporaryDirectory() as td:
        root=pathlib.Path(td); o=Orchestrator(root)
        o.register_agent('CODEX',['ARCH','RTL'])
        o.register_agent('CURSOR',['RTL'])
        o.add_task({'task_id':'A','title':'A','role':'ARCH','objective':'x','independent_review':True,'deps':[]})
        o.add_task({'task_id':'D','title':'D','role':'RTL','objective':'y','allow_candidate_inputs':True,'deps':[{'task_id':'A','min_status':'CANDIDATE_PASS'}]})
        t=o.claim('A','CODEX'); assert t['status']=='RUNNING'
        t=o.finish('A','CODEX','PASS'); assert t['status']=='CANDIDATE_PASS'
        o.refresh_ready(); assert o.task('D')['status']=='READY'
        t=o.claim('D','CURSOR'); assert t['owner']=='CURSOR'
        o.set_agent_state('CURSOR','QUOTA_EXHAUSTED',release_tasks=True)
        o.refresh_ready(); assert o.task('D')['status']=='READY'
        x=o.takeover('D','CODEX',solo=True); assert x['task']['owner']=='CODEX'
