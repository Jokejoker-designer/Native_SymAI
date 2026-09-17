#!/usr/bin/env python3
import json,sys
from collections import Counter
EXPECTED={'FE-DIRECT':48,'FE-VALUE':32,'FE-REVERSE':32,'FE-MULTIHOP':32,'FE-CONTEXT':24,'FE-PROVENANCE':16,'FE-NEGATIVE':24,'FE-CONFLICT':16,'FE-IDENTITY':16,'FE-ABLATION':16}
c=Counter()
ids=set()
for n,line in enumerate(open(sys.argv[1],encoding='utf-8'),1):
 if not line.strip(): continue
 x=json.loads(line); c[x['group']]+=1
 if x['case_id'] in ids: raise SystemExit(f'duplicate case_id {x["case_id"]}')
 ids.add(x['case_id'])
print(dict(c)); print('total',sum(c.values()))
if dict(c)!=EXPECTED or sum(c.values())!=256: raise SystemExit(1)
