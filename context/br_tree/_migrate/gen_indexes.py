#!/usr/bin/env python3
"""Phase 4: generate _index.md for every folder, a special error-code index,
a per-category index, and the root master map + routing guide."""
import re, sys
from pathlib import Path
ROOT=Path(sys.executable if getattr(sys, "frozen", False) else __file__).resolve().parent.parent
TOPS=[t for t in ["00-configuration","10-language","20-io-screen","30-io-file","40-io-printing",
      "50-libraries","60-integration","70-commands","90-reference","99-examples"] if (ROOT/t).is_dir()]

# One line per folder, used in TWO places: the folder's own _index.md header and
# its parent's "## Subfolders" list. A folder absent from here gets an empty
# description in both, silently — which is how `30-io-file/database` and
# `50-libraries/fileio` came to have hand-written descriptions in the committed
# _index.md files that a regeneration would have deleted. `check_purpose` below
# now refuses to run in that state, so adding a folder means adding its line here.
PURPOSE={
"00-configuration":"Platform, deployment and environment configuration. **Not coding** — nothing here is needed to reason about program logic.",
"00-configuration/config-directives":"BRConfig.sys directives and OPTION/CONFIG settings that tune BR behavior at start-up.",
"00-configuration/client-server":"BRServer / BRClient deployment, reconnect, keepalive and client-server transport.",
"00-configuration/platform":"OS- and platform-specific notes (Windows, Linux, MAC, SCO, browser, executables).",
"00-configuration/environment":"Environment variables, drives, paths and session-level settings.",
"00-configuration/installation-tooling":"Installers, DLLs, ODBC, editors and other external tooling.",
"30-io-file/serial-comm":"RS-232 / serial device communication settings (BAUD, DATABITS, STOPBITS).",
"10-language":"In-memory data operations — the core coding language: syntax, flow control, and data manipulation.",
"10-language/syntax":"Program structure: line numbers/labels, comments, line continuation, multiple statements.",
"10-language/flow-control":"Directing execution: loops and jumps, user-defined functions, and error trapping.",
"10-language/data-manipulation":"Working with values in memory: declaration, assignment, expressions, conditionals, data types and the intrinsic functions.",
"10-language/flow-control/functions-udf":"User-defined functions: DEF / FN / FNEND / END DEF, local variables, paragraph labels.",
"10-language/flow-control/other-flow":"Loops and jumps: DO/LOOP, FOR/NEXT, GOTO, ON GOTO, EXIT, END/STOP, PAUSE, CHAIN.",
"10-language/flow-control/error-handling":"Trapping & recovery: statement conditions, EXIT groups, ON <cond>/ON ERROR, RETRY/CONTINUE, execution modes.",
"10-language/data-manipulation/declaration":"Variable & array declaration: DIM, arrays, MAT dimensioning, OPTION BASE.",
"10-language/data-manipulation/assignment":"Data movement & change: LET, MAT assignment, DATA/RESTORE, string operations.",
"10-language/data-manipulation/system-functions":"Intrinsic/system functions usable in expressions (ABS, CNVRT$, POS, DATE$, ...).",
"10-language/data-manipulation/conditionals":"Conditional evaluation: IF / THEN / ELSE / END IF.",
"10-language/data-manipulation/expressions":"Operators, precedence, logical AND/OR/NOT, binary and concatenation expressions.",
"10-language/data-manipulation/data-types":"Data types and literals: numeric, string, fixed-point, floating, hex, null.",
"20-io-screen":"Screen input/output authoring: fields, attributes, controls and windows.",
"20-io-screen/input-output":"INPUT / RINPUT statements, field & select lists, on-screen PRINT FIELDS.",
"20-io-screen/fields-attributes":"Field formatting & visual attributes: FMT, PIC, COLOR, FONT, borders, masks.",
"20-io-screen/controls":"GUI controls: buttons, checkboxes, radio buttons, grids, lists, pickers.",
"20-io-screen/windows-cursor":"Windows, cursor positioning and keyboard handling on screen.",
"30-io-file":"File input/output authoring: statements, form specs, keys/indexes and the file model.",
"30-io-file/statements":"File processing statements: OPEN, CLOSE, READ, WRITE, REWRITE, DELETE.",
"30-io-file/form-spec":"FORM / FORMAT specifications describing record layouts.",
"30-io-file/keys-indexes":"Keyed/indexed access: keys, indexes, duplicate keys, reindex/reorg.",
"30-io-file/file-model":"File concepts: internal vs external files, file numbers, locking, sharing.",
"30-io-file/database":"SQL / ODBC database access: CONFIG DATABASE, OPEN…SQL channels, WRITE/READ result rows.",
"40-io-printing":"Printing authoring (coding side only; spool/printer config lives under 00-configuration).",
"40-io-printing/statements":"Print statements and page control: PRINT (printer), PAGEOFLOW, page breaks, borders.",
"40-io-printing/pcl-pdf":"Printer languages and formats: PCL, PDF, PJL, barcodes, pictures.",
"40-io-printing/sort":"Report sorting: SORT, AIDX/DIDX usage, sort order.",
"50-libraries":"Reusable library facility and the shipped function packs.",
"60-integration":"Web & data-exchange integration — JSON/data store and BR as a web server.",
"60-integration/json-datastore":"In-memory object/data store and JSON build/parse/serve functions.",
"60-integration/web":"BR as web server: WEB_SERVER12 + WebForm, ?BR_FUNC= dispatch, and the outbound HTTP=CLIENT.",
"50-libraries/library-facility":"LIBRARY statement and library function mechanics, releasing libraries.",
"50-libraries/fileio":"The FileIO library (Sage AX): layout-driven file access, automatic versioning, DataCrawler, and the Audit BR add-on.",
"50-libraries/fnsnap":"FnSnap shipped function packs (the substantive `FnSnap__*` pages; redirect stubs in _redirects/).",
"50-libraries/screenio":"ScreenIO library, Lexi, and the PhpIO web deployment.",
"70-commands":"Executive/console commands. Integral to coding because they are runnable from program code via `EXECUTE \"<cmd>\"`.",
"70-commands/program-management":"Run and manage programs: RUN, LOAD, MERGE, LIST, CHAIN, PROC, GO.",
"70-commands/file-directory":"File and directory commands: CHDIR, DIR, COPY, FREE, drop options.",
"70-commands/information":"Status/info and console commands: Command Console, Display, DEBUG, MSG.",
"70-commands/editing":"In-editor commands available in interactive/runnable form.",
"90-reference":"Lookup-only reference material — not authoring specifications.",
"90-reference/error-codes":"Every BR numeric error code, one file each. See the table below for fast lookup.",
"90-reference/keyboard-shortcuts":"Key bindings (Ctrl+*, control keys) — not runnable via EXECUTE.",
"90-reference/limits-constants":"Numeric limits and built-in constants (max integer, PI, ...).",
"90-reference/glossary-stubs":"Disambiguation pages and single-letter stubs quarantined from the authoring docs.",
"99-examples":"Multi-topic tutorials and course material (Fast Track, Chapters). Single-topic tutorials were co-located into their topic folder.",
}

def split_fm(text):
    if text.startswith("﻿"): text=text[1:]
    m=re.match(r'^---\s*\n(.*?\n)---\s*\n(.*)$', text, re.S)
    return (m.group(1),m.group(2)) if m else ("",text)

def field(fm,key):
    m=re.search(rf'^{key}:\s*(.+)$', fm, re.M)
    return m.group(1).strip() if m else ""

def clean(s):
    s=re.sub(r'`([^`]*)`', r'\1', s)
    s=re.sub(r'\*\*([^*]*)\*\*', r'\1', s)
    s=re.sub(r"'''?([^']*)'''?", r'\1', s)
    s=re.sub(r'={2,}','',s)
    s=re.sub(r'\s+',' ',s).strip()
    return s

LIMIT=140

def cut(s, limit=LIMIT):
    """Trim to the limit at a sentence or word boundary, never mid-word.

    The old truncation was a bare slice, which produced summaries ending "the" and
    "is taken" — worse than useless in a navigation table, because they read as
    though the sentence continued somewhere the reader could go.
    """
    s=s.strip()
    if len(s)<=limit: return s
    head=s[:limit+1]
    # Prefer ending on a sentence that finished inside the limit.
    end=max(head.rfind(". "), head.rfind("; "))
    if end>=limit//2: return head[:end+1]
    sp=head.rfind(" ")
    return (head[:sp] if sp>0 else head[:limit]).rstrip(",;:-—") + "…"

SKIP_PREFIX=("=","#","|","{","<","[","File:","file:",":","*Mat","-",">")

def debullet(s):
    """Drop a leading wiki/markdown bullet marker.

    A `-` bullet never starts a summary (SKIP_PREFIX), but a `*` one may, because
    on a disambiguation page the bullet list *is* the content — and joining the
    paragraph then carried the markers into the middle of the sentence.
    """
    return re.sub(r'^[*+]\s+', '', s)

def summary(body, is_err=False):
    if is_err:
        m=re.search(r'\*\*Description:\*\*\s*(.+)', body)
        if m: return cut(clean(m.group(1)))
    lines=body.splitlines()
    for i,line in enumerate(lines):
        l=line.strip()
        # `>` skips blockquotes. A page opening with a capture or provenance note
        # — "> Capture note. This is a local copy…" — was having that note lifted
        # as its summary, which describes the file's history and not its subject.
        if not l: continue
        if l.startswith(SKIP_PREFIX): continue
        if l.startswith("**") and l.endswith("**") and len(l)<40: continue
        # Take the whole paragraph, not the first physical line of it. The specs
        # are hard-wrapped at about a hundred characters, so a one-line read ended
        # every summary mid-sentence — "Every signature below is taken" — and it
        # looked like truncation when it was the wrap.
        para=[debullet(l)]
        for nxt in lines[i+1:]:
            n=nxt.strip()
            if not n or n.startswith(SKIP_PREFIX): break
            para.append(debullet(n))
        c=clean(" ".join(para))
        if len(c)>15: return cut(c)
    return ""

def iter_md(folder):
    return sorted([p for p in folder.glob("*.md") if p.name!="_index.md"])

KEEP_RE=re.compile(r'<!--\s*keep\s*-->\n?(.*?)\n?<!--\s*/keep\s*-->', re.S)
kept=[]

def keep_block(folder, rel):
    """Return any hand-written region of an existing _index.md, verbatim.

    These files are generated, and four of them had been hand-edited anyway —
    curated deep-reference lists in `fileio` and `screenio`, a "moved to its own
    leaf" pointer in `library-facility` — because the generator has no way to say
    anything it cannot derive. Running it destroyed all of that silently, which is
    why nobody ran it, which is why the tree and the script drifted apart for as
    long as they did.

    So the editor gets a region the generator copies forward untouched:

        <!-- keep -->
        Deep-reference pages:
        - [X.md](X.md) — what it is for
        <!-- /keep -->

    It is emitted where the boilerplate "Backing keyword pages below" line would
    go, and the file inventory is still generated below it. The generator owns the
    inventory; the editor owns the commentary; neither overwrites the other.
    """
    f=folder/"_index.md"
    if not f.exists(): return ""
    m=KEEP_RE.search(f.read_text(encoding="utf-8",errors="replace"))
    if not m: return ""
    kept.append(rel)
    return m.group(1).strip("\n")

def write_leaf_index(folder, rel):
    files=iter_md(folder)
    is_err = rel=="90-reference/error-codes"
    spec=folder/"spec.md"
    keep=keep_block(folder, rel)
    lines=[f"# {rel}","",PURPOSE[rel],""]
    # Feature the synthesized guide (spec.md) at the top — the durable artifact (PLAN §1.6).
    if spec.exists():
        fm,body=split_fm(spec.read_text(encoding="utf-8",errors="replace"))
        st=field(fm,"status").split("#")[0].strip()
        tag=f" _(status: {st})_" if st else ""
        files=[p for p in files if p.name!="spec.md"]
        lines+=[f"**📄 Guide → [spec.md](spec.md)**{tag} — {summary(body)}",""]
        if keep:
            lines+=["<!-- keep -->",keep,"<!-- /keep -->",""]
        else:
            lines+=(["_Backing keyword pages below._",""] if files
                    else ["_Backing keyword pages pruned; `spec.md` is the sole content._",""])
    else:
        lines+=[f"_{len(files)} entries._",""]
        if keep:
            lines+=["<!-- keep -->",keep,"<!-- /keep -->",""]
    if is_err:
        lines+=["| Code | Description |","|---|---|"]
        for p in files:
            fm,body=split_fm(p.read_text(encoding="utf-8",errors="replace"))
            lines.append(f"| [{p.stem}]({p.name}) | {summary(body,True)} |")
    elif files:
        lines+=["| File | Kind | Summary |","|---|---|---|"]
        for p in files:
            fm,body=split_fm(p.read_text(encoding="utf-8",errors="replace"))
            title=field(fm,"title") or p.stem
            kind=field(fm,"kind")
            lines.append(f"| [{title}]({p.name}) | {kind} | {summary(body)} |")
    # note subfolders if any
    subs=[d for d in folder.iterdir() if d.is_dir() and not d.name.startswith("_")]
    if subs:
        lines+=["","## Subfolders"]
        for d in sorted(subs):
            sr=f"{rel}/{d.name}"
            lines.append(f"- [{d.name}/]({d.name}/_index.md) — {PURPOSE[sr]}")
    (folder/"_index.md").write_text("\n".join(lines)+"\n",encoding="utf-8")

# walk every folder under TOPS (and the tops themselves)
allfolders=set()
for top in TOPS:
    tp=ROOT/top
    allfolders.add(tp)
    for d in tp.rglob("*"):
        if d.is_dir() and not d.name.startswith("_"):
            allfolders.add(d)
allrels=sorted(str(f.relative_to(ROOT)).replace("\\","/") for f in allfolders)

def check_purpose(rels):
    """Refuse to run if any folder would get an empty description.

    This is checked before a single file is written, so a failure leaves the tree
    as it was rather than half regenerated.

    The failure it guards against is silent: PURPOSE is consulted with .get(rel,'')
    in both places a description appears, so a folder nobody added a line for
    simply loses one — in its own header and in its parent's subfolder list. Four
    folders had reached that state, two of them carrying hand-written descriptions
    in the committed _index.md that running this script would have deleted. There
    is nowhere else for the text to come from, so this cannot be recovered
    automatically; the only fix is to notice, which is what this does.
    """
    missing=[r for r in rels if r not in PURPOSE]
    if missing:
        raise SystemExit(
            "gen_indexes: no PURPOSE entry for:\n"
            + "".join("    %s\n" % m for m in missing)
            + "Add one line per folder to PURPOSE. Without it the folder's _index.md and its\n"
              "parent's subfolder list both get an empty description, and if one was written by\n"
              "hand it is overwritten with nothing.")
    # A key naming no folder is inert rather than wrong: TOPS is filtered by
    # is_dir(), so a top-level folder this tree does not currently hold is simply
    # skipped, and its line here is what would describe it if it returned.
    for k in sorted(k for k in PURPOSE if k not in rels):
        print("  note: PURPOSE describes %s, which this tree does not contain" % k)

check_purpose(allrels)

for folder in allfolders:
    rel=str(folder.relative_to(ROOT)).replace("\\","/")
    write_leaf_index(folder, rel)

# ---- root master index --------------------------------------------------------
def count(top): return sum(1 for _ in (ROOT/top).rglob("*.md") if _.name!="_index.md")
root=["# Business Rules! Documentation — Master Index","",
"Reorganized for segmented application development. **Configuration/platform concerns are",
"kept separate from coding specifications.** Each folder has its own `_index.md`.","",
"## Top-level map",""]
for top in TOPS:
    root.append(f"- **[{top}/]({top}/_index.md)** ({count(top)} docs) — {PURPOSE[top]}")
root+=["","## Where do I look for…","",
"| I want to… | Go to |",
"|---|---|",
"| Declare a variable or array (DIM) | `10-language/data-manipulation/declaration` |",
"| Assign / move data (LET, MAT) | `10-language/data-manipulation/assignment` |",
"| Use a built-in function (CNVRT$, POS…) | `10-language/data-manipulation/system-functions` |",
"| Write an IF / loop / GOTO | `10-language/data-manipulation/conditionals`, `10-language/flow-control/other-flow` |",
"| Define a function (DEF/FN) | `10-language/flow-control/functions-udf` |",
"| Read/write a record | `30-io-file/statements` |",
"| Build or use an index | `30-io-file/keys-indexes` |",
"| Lay out a screen / field | `20-io-screen/*` |",
"| Print a report | `40-io-printing/*` |",
"| Run a program from code (EXECUTE) | `70-commands` |",
"| Look up an error code | `90-reference/error-codes/_index.md` |",
"| Configure BR / deploy | `00-configuration/*` |",
"",
"_Provenance: `_migrate/MANIFEST.csv` maps every file's original location to its new path._",""]
(ROOT/"_index.md").write_text("\n".join(root)+"\n",encoding="utf-8")
print("indexes generated for",len(allfolders),"folders + root")
if kept:
    print("hand-written regions preserved in:", ", ".join(sorted(kept)))
