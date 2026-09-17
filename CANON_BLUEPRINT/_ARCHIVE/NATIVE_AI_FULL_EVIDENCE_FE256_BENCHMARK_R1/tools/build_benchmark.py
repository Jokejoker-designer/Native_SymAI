#!/usr/bin/env python3
"""Deterministic FE256 case builder from a frozen normalized CANON_GOLD_CLAIMS.jsonl.

This tool intentionally refuses to invent missing semantic classes. If the gold source
cannot supply the requested diversity/count for a group, generation fails rather than
padding with duplicates or fabricated domain facts.
"""
import argparse, json, random, hashlib
from pathlib import Path

COUNTS={
 'FE-DIRECT':48,'FE-VALUE':32,'FE-REVERSE':32,'FE-MULTIHOP':32,
 'FE-CONTEXT':24,'FE-PROVENANCE':16,'FE-NEGATIVE':24,'FE-CONFLICT':16,
 'FE-IDENTITY':16,'FE-ABLATION':16,
}

def load(path):
 out=[]
 with open(path,encoding='utf-8') as f:
  for line in f:
   if line.strip(): out.append(json.loads(line))
 return sorted(out,key=lambda x:x['claim_id'])

def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def take(rng, xs, n, name):
 xs=list(xs)
 if len(xs)<n: raise SystemExit(f"Insufficient gold for {name}: need {n}, have {len(xs)}. Do not fabricate/pad cases.")
 rng.shuffle(xs); return xs[:n]
def qrec(claim,txn,direction='FWD',object_valid=False,object_ref=None):
 return {'subject_id':claim['subject_id'],'relation_id':claim['relation_id'],'object_ref':object_ref,'object_valid':object_valid,'direction':direction,'context_id':claim.get('context_id'),'mode':'EXACT','txn_id':txn}
def answer_expected(c):
 if c['object_kind']=='NODE': a=c.get('object_ref'); kind='NODE'
 else: a=c.get('value'); kind='VALUE'
 return {'status':'ANSWER','answer_kind':kind,'answer_ref':a,'proof_required':True,'provenance_required':True}

def main():
 ap=argparse.ArgumentParser(); ap.add_argument('gold'); ap.add_argument('out'); ap.add_argument('--seed',type=int,default=256)
 args=ap.parse_args(); rng=random.Random(args.seed); claims=load(args.gold)
 verified=[c for c in claims if c.get('status')=='VERIFIED']
 direct=[c for c in verified if c['object_kind']=='NODE']
 values=[c for c in verified if c['object_kind']=='VALUE']
 reverse=[c for c in direct if c.get('inverse_relation_id') is not None]
 prov=[c for c in verified if c.get('provenance_ids')]
 conflicts=[c for c in claims if c.get('status')=='CONFLICT' and c.get('conflict_group')]
 # Build adjacency for multihop. Only node-object verified claims participate.
 by_src={}
 for c in direct: by_src.setdefault(c['subject_id'],[]).append(c)
 paths=[]
 for a in direct:
  mid=a.get('object_ref')
  for b in by_src.get(mid,[]):
   paths.append((a,b))
 # Context contrast candidates: same S,R with >=2 distinct non-null contexts.
 sr={}
 for c in verified: sr.setdefault((c['subject_id'],c['relation_id']),[]).append(c)
 ctx=[]
 for k,ls in sr.items():
  cs={x.get('context_id') for x in ls}
  if len(cs)>=2: ctx.extend(ls)
 # Identity/alias: claims carrying >=2 aliases or multiple exact model/family records must be prepared in gold.
 ident=[c for c in verified if len(c.get('aliases',[]))>=2 or c.get('identity_test',False)]
 selected={}
 selected['FE-DIRECT']=take(rng,direct,48,'FE-DIRECT')
 selected['FE-VALUE']=take(rng,values,32,'FE-VALUE')
 selected['FE-REVERSE']=take(rng,reverse,32,'FE-REVERSE')
 selected['FE-MULTIHOP']=take(rng,paths,32,'FE-MULTIHOP')
 selected['FE-CONTEXT']=take(rng,ctx,24,'FE-CONTEXT')
 selected['FE-PROVENANCE']=take(rng,prov,16,'FE-PROVENANCE')
 selected['FE-CONFLICT']=take(rng,conflicts,16,'FE-CONFLICT')
 selected['FE-IDENTITY']=take(rng,ident,16,'FE-IDENTITY')
 # NEGATIVE and ABLATION require reviewed/generated mutation records to avoid inventing semantics.
 negatives=[c for c in claims if c.get('benchmark_role')=='NEGATIVE']
 ablations=[c for c in claims if c.get('benchmark_role')=='ABLATION']
 selected['FE-NEGATIVE']=take(rng,negatives,24,'FE-NEGATIVE')
 selected['FE-ABLATION']=take(rng,ablations,16,'FE-ABLATION')
 cases=[]; txn=1
 for group in COUNTS:
  for item in selected[group]:
   cid=f"{group}-{len([x for x in cases if x['group']==group])+1:03d}"
   if group=='FE-MULTIHOP':
    a,b=item
    query=qrec(a,txn); expected={'status':'ANSWER','answer_kind':b['object_kind'],'answer_ref':b.get('object_ref') if b['object_kind']=='NODE' else b.get('value'),'proof_required':True,'provenance_required':True}
    src=[a['claim_id'],b['claim_id']]
   elif group=='FE-REVERSE':
    c=item
    query={'subject_id':c['object_ref'],'relation_id':c['inverse_relation_id'],'object_ref':None,'object_valid':False,'direction':'REV','context_id':c.get('context_id'),'mode':'EXACT','txn_id':txn}
    expected={'status':'ANSWER','answer_kind':'NODE','answer_ref':c['subject_id'],'proof_required':True,'provenance_required':True}; src=[c['claim_id']]
   elif group=='FE-CONFLICT':
    c=item; query=qrec(c,txn); expected={'status':'CONFLICT','answer_kind':None,'answer_ref':None,'proof_required':True,'provenance_required':True}; src=[c['claim_id']]
   elif group in ('FE-NEGATIVE','FE-ABLATION'):
    c=item; query=c['benchmark_query']; query=dict(query); query['txn_id']=txn; expected=c['benchmark_expected']; src=[c['claim_id']]
   else:
    c=item; query=qrec(c,txn); expected=answer_expected(c); src=[c['claim_id']]
   cases.append({'case_id':cid,'group':group,'query':query,'expected':expected,'gold_source_ids':src,'pair_id':item.get('pair_id') if isinstance(item,dict) else None})
   txn+=1
 out=Path(args.out); out.parent.mkdir(parents=True,exist_ok=True)
 with out.open('w',encoding='utf-8') as f:
  for c in cases: f.write(json.dumps(c,sort_keys=True,separators=(',',':'))+'\n')
 manifest={'benchmark':'FE256_R1','seed':args.seed,'gold_sha256':sha(args.gold),'case_count':len(cases),'cases_sha256':sha(out)}
 Path(str(out)+'.manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(json.dumps(manifest,indent=2))
if __name__=='__main__': main()
