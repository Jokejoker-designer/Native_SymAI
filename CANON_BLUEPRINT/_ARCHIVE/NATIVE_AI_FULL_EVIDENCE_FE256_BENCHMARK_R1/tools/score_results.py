#!/usr/bin/env python3
"""Score FE256 structured results against preregistered JSONL cases.
No external dependencies.
"""
import argparse, json, statistics, sys
from pathlib import Path

def load_jsonl(path):
    out=[]
    with open(path,encoding='utf-8') as f:
        for n,line in enumerate(f,1):
            line=line.strip()
            if not line: continue
            try: out.append(json.loads(line))
            except Exception as e: raise SystemExit(f"{path}:{n}: {e}")
    return out

def norm_answer(x):
    # Canonical JSON equality for structured values; scalar IDs remain exact.
    if isinstance(x,(dict,list)):
        return json.dumps(x,sort_keys=True,separators=(',',':'))
    return x

def pct(a,b): return 0.0 if b==0 else a/b

def qtile(vals,p):
    if not vals: return None
    s=sorted(vals); idx=min(len(s)-1,max(0,int(round((len(s)-1)*p))))
    return s[idx]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('cases'); ap.add_argument('results')
    ap.add_argument('--json-out')
    args=ap.parse_args()
    cases=load_jsonl(args.cases); results=load_jsonl(args.results)
    cmap={c['case_id']:c for c in cases}; rmap={r['case_id']:r for r in results}
    dup=len(results)-len(rmap)
    m={k:0 for k in ['explicit','correct','wrong','false_refusal','empty','timeout','txn_mismatch','proof_missing','prov_missing']}
    answerable=0; group={}
    failures=[]; cycles=[]; ddr=[]
    for cid,c in cmap.items():
        g=c['group']; group.setdefault(g,{'total':0,'pass':0}); group[g]['total']+=1
        r=rmap.get(cid)
        exp=c['expected']; exp_status=exp['status']
        case_ok=True
        if r is None:
            m['empty']+=1; failures.append([cid,'MISSING_RESULT']); continue
        m['explicit']+=1
        if r.get('status') in (None,'','EMPTY'):
            m['empty']+=1; case_ok=False; failures.append([cid,'EMPTY_STATUS'])
        if r.get('status')=='TIMEOUT':
            m['timeout']+=1; case_ok=False; failures.append([cid,'TIMEOUT'])
        if r.get('txn_id') != c['query'].get('txn_id'):
            m['txn_mismatch']+=1; case_ok=False; failures.append([cid,'TXN_MISMATCH'])
        is_answerable=(exp_status=='ANSWER')
        if is_answerable: answerable+=1
        if r.get('status') != exp_status:
            case_ok=False
            if is_answerable: m['false_refusal']+=1
            failures.append([cid,f"STATUS expected={exp_status} got={r.get('status')}"])
        elif exp_status=='ANSWER':
            if r.get('answer_kind') != exp.get('answer_kind') or norm_answer(r.get('answer_ref')) != norm_answer(exp.get('answer_ref')):
                m['wrong']+=1; case_ok=False; failures.append([cid,'WRONG_ANSWER'])
            else: m['correct']+=1
        if exp.get('proof_required') and not r.get('proof_ref'):
            m['proof_missing']+=1; case_ok=False; failures.append([cid,'PROOF_MISSING'])
        if exp.get('provenance_required') and not r.get('provenance_ref'):
            m['prov_missing']+=1; case_ok=False; failures.append([cid,'PROVENANCE_MISSING'])
        if case_ok: group[g]['pass']+=1
        if isinstance(r.get('cycles'),int): cycles.append(r['cycles'])
        if isinstance(r.get('ddr_bytes'),int): ddr.append(r['ddr_bytes'])
    summary={
      'total_cases':len(cases),'results_received':len(results),'duplicate_result_rows':dup,
      'explicit_result_rate':pct(m['explicit'],len(cases)), 'answerable_cases':answerable,
      'correct_answers':m['correct'],'correct_answer_rate_answerable':pct(m['correct'],answerable),
      'wrong_answer_count':m['wrong'],'false_refusal_count':m['false_refusal'],
      'empty_count':m['empty'],'timeout_count':m['timeout'],'txn_mismatch_count':m['txn_mismatch'],
      'proof_missing_count':m['proof_missing'],'provenance_missing_count':m['prov_missing'],
      'groups':group,'failures':failures,
      'cycles':{'p50':qtile(cycles,.50),'p95':qtile(cycles,.95),'p99':qtile(cycles,.99),'max':max(cycles) if cycles else None},
      'ddr_bytes':{'p50':qtile(ddr,.50),'p95':qtile(ddr,.95),'p99':qtile(ddr,.99),'max':max(ddr) if ddr else None}
    }
    print(json.dumps(summary,indent=2,ensure_ascii=False))
    if args.json_out: Path(args.json_out).write_text(json.dumps(summary,indent=2,ensure_ascii=False)+"\n",encoding='utf-8')
    hard_fail=(len(cases)!=256 or m['explicit']!=len(cases) or m['wrong'] or m['false_refusal'] or m['empty'] or m['timeout'] or m['txn_mismatch'] or m['proof_missing'] or m['prov_missing'] or any(v['pass']!=v['total'] for v in group.values()))
    sys.exit(1 if hard_fail else 0)
if __name__=='__main__': main()
