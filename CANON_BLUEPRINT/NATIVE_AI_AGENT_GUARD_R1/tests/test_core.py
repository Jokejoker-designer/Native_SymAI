from pathlib import Path
import tempfile
from native_guard.locks import LeaseManager
from native_guard.evidence import EvidenceLog
from native_guard.vivado import parse_timing,evaluate
from native_guard.config import DEFAULT


def test_lease_and_evidence():
    with tempfile.TemporaryDirectory() as d:
        r=Path(d); lm=LeaseManager(r); lm.acquire("board","A",10)
        assert lm.list()[0]["agent"]=="A"; lm.release("board","A")
        e=EvidenceLog(r); e.append("X","FAIL","A",{"x":1}); e.append("X","PASS","A",{"x":2})
        ok,n,err=e.verify(); assert ok and n==2

def test_timing_fail_closed():
    t=parse_timing("WNS (ns): -0.123\nTNS (ns): -4.0\nWHS (ns): 0.10\nTHS (ns): 0.0\nUnconstrained Paths: 0")
    r=evaluate(t,{},DEFAULT,{})
    assert r["status"]=="FAIL"
