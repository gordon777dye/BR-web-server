#!/usr/bin/env python3
"""Phases 1-2: scaffold target tree, move each file per MANIFEST.csv, inject
metadata frontmatter (category/subcategory/kind/related). Reversible: MANIFEST
records old->new for every file."""
import csv, re, shutil, sys
from pathlib import Path

ROOT = Path(sys.executable if getattr(sys, "frozen", False) else __file__).resolve().parent.parent
MAN = ROOT/"_migrate"/"MANIFEST.csv"

def harvest_related(body):
    toks=[]
    for m in re.findall(r'`([^`\n]{2,40})`', body):
        t=m.strip()
        if not t or t.startswith(("http","File:","file:")): continue
        if re.fullmatch(r'[\w$ ().\-/!=]+', t):
            key=t.lower()
            if key not in [x.lower() for x in toks]:
                toks.append(t)
        if len(toks)>=10: break
    return toks

def split_frontmatter(text):
    if text.startswith("﻿"): text=text[1:]
    m=re.match(r'^---\s*\n(.*?\n)---\s*\n(.*)$', text, re.S)
    if m: return m.group(1), m.group(2)
    return None, text

def inject(path, row):
    text=path.read_text(encoding="utf-8", errors="replace")
    fm, body = split_frontmatter(text)
    related=harvest_related(body)
    rel_line = "related: ["+", ".join(related)+"]\n" if related else "related: []\n"
    meta=(f"category: {row['category']}\n"
          f"subcategory: {row['subcategory']}\n"
          f"kind: {row['kind']}\n"
          + rel_line)
    if fm is None:
        new=f"---\ntitle: {path.stem}\n{meta}---\n{body}"
    else:
        # drop any pre-existing copies of our keys, then append before close
        fm_clean="\n".join(l for l in fm.splitlines()
                           if not re.match(r'\s*(category|subcategory|kind|related):',l))
        if fm_clean and not fm_clean.endswith("\n"): fm_clean+="\n"
        new=f"---\n{fm_clean}{meta}---\n{body}"
    path.write_text(new, encoding="utf-8")

rows=list(csv.DictReader(MAN.open(encoding="utf-8")))
moved=0
for r in rows:
    old=ROOT/r["old_path"]; new=ROOT/r["new_path"]
    if not old.exists():
        print("MISSING", old); continue
    new.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(old), str(new))
    inject(new, r)
    moved+=1
print(f"moved+enriched {moved} files")
