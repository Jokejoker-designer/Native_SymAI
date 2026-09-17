from __future__ import annotations
import pathlib,re

def scan(path:pathlib.Path,patterns:list[str]):
    text=path.read_text(encoding="utf-8",errors="replace")
    out=[]
    for i,line in enumerate(text.splitlines(),1):
        for p in patterns:
            if re.search(re.escape(p),line,re.I): out.append({"line":i,"pattern":p,"text":line[:500]})
    return out
