# Source line positions

How BR reports *where* a program is — in its own line numbers and in the lines of
the file a person edits — and what the AI-access channel does with both.

BR has always reported a position as a line number and a clause: `WHERE` carries
`LINE=` and `CLAUSE=`, `ERROR` carries `NUMBER= LINE= CLAUSE=`, and the log
carries `Line:01210`. Every one of those is a **BR line number**, which is the
number written at the front of the statement. That is not where the statement
sits in the file, and with a precompiler in front of BR it is not even in the
same numbering as the text the programmer wrote.

This describes one field in the line table that closes that gap, and the rules
for reporting it.

## 1. Why a BR line number is not a source file position

Three things separate the two, and all three are ordinary BR:

- **Line numbers are chosen, not counted.** `00010`, `00020`, `01230` say nothing
  about how many lines precede them.
- **One BR line can span several physical lines.** The continuation `!:` at the end
  of a physical line carries the statement onto the next one, and acts as a clause
  separator while doing it. So the relation from physical lines to line-table
  entries is many-to-one.
- **A precompiler may renumber entirely.** lexi assigns BR line numbers from
  `#Autonumber# <line-number>, <increment>` directives, which may appear inside any
  comment, including a trailing comment on an active clause. The BR line number
  then has no arithmetic relation to the position of the source line that produced
  it.

None of this is recoverable downstream. Counting lines in the file requires knowing
exactly what the loader did with blanks and continuations; finding a clause requires
knowing where BR considers a clause to begin, and `IF ... THEN` is two clauses with
no separator between them. **Anything that reconstructs a position from text is
modelling the loader and the parser rather than asking them**, and it can fail
silently — a plausible wrong line rather than a refusal. 

So the source file position is recorded by the code that knows it, at the moment it 
knows it.

## 2. What BR stores

One field per line-table entry, in `LineTable` (`basic.h:1141`):

```c
struct LineTable {
   int      lineNumber;     /* high byte contains lineflags */
   uchar *  lineSourcePointer;
   uchar *  lineCodePointer;
   CODE_POINTER_TYPE linenext;
   int      srcLine;        /* physical source line, or 0 - see below */
};
```

`srcLine` is **the physical line this statement occupies in the original user 
edited program**, counting from 1. It is `0` only when no line was stored for
this entry at all, which happens for immediately executed statements with no 
line number.

Two properties of the existing code make this cheap:

- **It goes into the object file as well, and that is a format change.** The
  in-memory `LineTable` holds pointers; the on-disk form is a separate struct,
  `SaveLineTable` (`brexe.cpp:94`), holding offsets. `srcLine` has to be added to
  **both**, because a program loaded from `SAVE OBJECT` retains no source text and
  the stored line is then the only source position it has — that is exactly the
  `BASE` case in section 3. Adding it to `SaveLineTable` costs four bytes per line
  on disk and requires the format version to move:
  `serializerForLineTable` is length-checked against
  `NEW_SERIALIZE_SAVE_LINE_TABLE_LENGTH`, and `oldSerializerForLineTable` sits
  beside it for the previous layout, which is the established way to do this.
- **A program saved by an earlier BR has no stored line.** It loads with
  `srcLine` zero throughout, and `SRCLINE=` is then omitted rather than sent as
  zero. Nothing else degrades: the BR line number and the clause are unaffected.
- **The memory cost is four bytes a line, and in practice probably none.** The
  in-memory struct carries two pointers and a `BRINT16`
  (`CODE_POINTER_TYPE`, `wb.h:279`), so on a 64-bit build it has trailing padding
  an `int` may simply occupy. Either way this is not a consideration that should
  shape the design; it is noted only so nobody looks for a cost that is not
  there.

The loader sets it as it reads the source, because that is the only point at which
the physical line is known without being inferred.

## 3. The three precision states

A position is reported with the precision BR actually has, and never with more.
The state is explicit on every reporting surface, because a consumer that cannot
tell these apart will present the weakest as though it were the strongest.

| State | `SRCLINE=` | Meaning |
|---|---|---|
| `EXACT` | the clause's physical line | Source is retained and unedited. The file on disk matches, and the number indexes into it. |
| `EDITED` | the line it would occupy if written out now | Source is retained and the program has been edited in memory. **The file on disk no longer matches.** |
| `BASE` | the statement's first physical line | No source text is retained, so the clause's own line cannot be resolved. The stored line is still exact for the statement, and the clause within it is still correct. |

**The state is a property of the program, not of a line.** Whether source is
retained is answered for the whole program by `firstline` (`editListSource` is
`!(curpcb->firstline < 0)`, `commandc.cpp:1589`), and an edit makes the file on
disk stale throughout. So all three are program-wide, and a reader may take the
state on any one report as the state of every report about that program.

`BASE` is not an approximation. The line it reports is the stored one and is
exact for the statement; what is missing is only the resolution of a clause to a
line *within* a continued statement, which needs source text to calculate it. For 
a statement that occupies one physical line — the ordinary case — `BASE` and `EXACT` 
name the same line.

`EXACT` and `EDITED` differ only in whether the file on disk can be trusted, and
that difference is the whole point of distinguishing them. A reader told `EXACT`
may open the file and go to the line. A reader told `EDITED` may not: it must take
the text from a listing instead (§6).

## 4. Clause numbers, which are always available

Clause resolution already exists and is **source-independent**:
`getClauseNumber(LineTable *, byteOffset)` (`runa.cpp:47`) walks `lineCodePointer`
with `countSkipClause`, and `getClauseCount` gives the total.
`flowInterruptClauseNumber` (`command1.cpp:716`) supplies the offset from live flow
state, which is the path a reported position already comes down.

Because that counting is done over code rather than text, **the clause number is
correct even for a program loaded as object with no source at all.** That is why
`BASE` still carries a usable position: the line table's own number and the
clause are both right, and only the source line is missing.

Resolving a clause to its *physical* line needs the retained source text. Where there
is no source in the compiled program, the stored line is still the statement's first 
physical line, so `BASE` reports that together with the exact clause, and says which 
it is rather than letting the statement's start pass for the clause's line.

## 5. Editing, and the "as though" rule

A program can be edited in memory: lines inserted, lines deleted, lines replaced.
Positions are then reported **as though the source file had been changed the same
way.**

This applies to lines entered at the command line, through a `PROC`, or by `MERGE`.
It does **not** apply to the initial `LOAD ... SOURCE`, which records what it
counted and adjusts nothing.

- **Insert.** The new entry takes the physical line it would occupy, and every
  following entry's `srcLine` moves up by the number of physical lines the new
  statement spans.
- **Delete.** Every following entry's `srcLine` moves down by the span of the
  deleted statement.
- **Replace.** As a delete and an insert, which matters only when the replacement
  spans a different number of physical lines.
- **Any of the three** puts the program into `EDITED` for every subsequent report,
  not only for the lines that changed, because the file on disk is now stale
  throughout.

Renumbering in place changes no reported source lines. Using RENUM to relocate 
code makes the reported source lines inaccurate until the program source is 
refreshed via decompiling, and reloaded. 

**A source file whose line numbers are not in ascending order makes `srcLine`
wrong, and BR does not correct for it.** The loader counts physical lines in file
order while the line table is ordered by BR line number, so the two disagree the
moment the file does. Nothing detects this at load time and nothing should pretend
to: the condition is a defect in the source file, which `brls -check` already reports 
as an error. A position from such a program may name the wrong source line, and that 
is the cost of loading source files that are out of order. 

**This leaves no line without a source position.** A statement typed at the console, 
or arriving through a procedure — which is how the editor's own merge applies changes, 
occupies the line it would occupy if the program source were changed and the program 
was reloaded from source. 

## 6. What each surface reports to AI

Add `SRCLINE=` and the precision state to the existing argument lists. They are
additive: a reader that does not know them is unaffected.

```
WHERE LINE=1230 CLAUSE=3 SRCLINE=144 EXACT
ERROR NUMBER=405 LINE=1230 CLAUSE=3 SRCLINE=144 EDITED
```

`SRCLINE=` is sent in all three states. It is omitted entirely, rather than sent
as `0`, only when no line is stored at all — see the compatibility note in
section 2 — because an absent field cannot be mistaken for line zero.

BR's log gains the same, beside the `Line:` it already carries — BR line, clause
and source line together:

```
12345:02 2354
```

**The `PROGRAM` request** (see `AI-Access-Protocol.md` for the channel's shape)
reports the **currently active program** — which may be a library rather than the
program the session started — by identity rather than by text, because the driver
runs on BR's machine and can read a file for itself:

```
PROGRAM <lines> <sourcebytes> <codebytes> <source|object> <clean|edited>
<the path, in the record's body>

LISTING <br error number>
<the path, in the record's body>
```

**The path is the body in both, not the first argument.** It is the one field that can hold
spaces, and a record's body is where a field like that belongs - see `harnessVerbProgram` and
`harnessListingReady` in `harness.cpp`.

Which program is active is the question a reported position is about: a `WHERE` or
an `ERROR` inside a library names that library's lines, so `PROGRAM` has to name
the same one or the two cannot be read together.

`<path>` comes from `progname` in `ProgramControlBlock` (`basic.h:1543`);
`sourcebytes` and `codebytes` from the same block. `editListSource` is computed as
`!(curpcb->firstline < 0)` (`commandc.cpp:1589`) and is the test for whether there
is anything to list.

A `LISTING` is a path, meaning **BR has listed the active
program to a workfile**: `getUnusedWorkfile()`. A listing is what is actually 
loaded, which the file on disk may or may not be, so it is the authority whenever 
the program is `edited`.

**`LISTING` is the request's own answer, held until BR can make one.** The interpreter can list
only at a safe point - at the console, or between the lines of a running program - which is not
where the request arrives, so the request is parked and the response is sent when the listing
exists. A bounded answer a client has to subscribe for would be the protocol's plumbing handed to
the client, so there is no `LISTING` event and the name is not subscribable. BR bounds the wait at
ten seconds and answers
error 16, because a client that timed out on its own would read the late answer as the answer to
its next request.

Let `getUnusedWorkfile()` allocate as it normally does. `FreeWorkFiles()`
(`wbexit.cpp:108`) is what clears them.

Reporting a path requires only reading `curpcb` and so can be answered at any time.
A listing cannot: `processSubCommand` runs a command with a `RUNSTAT_VALUES`
save and restore, so it needs a quiescent moment.

## 7. Use of a precompiler

With lexi, the file BR loads is generated and the file the programmer maintains is
not. If the pre-compiler changes the quantity of edited source lines to generated 
source lines, it should report the difference by appending !#+99 to the end of the 
source line, Where +99 is `+ or - followed by 2 digits`. This lets BR accomodate 
differences in generated line quantities. BR drops this in its stored source. 

Nothing in this design is lexi-specific. Any pre-compiler that understands 
these rules will work. In order for a model or editor to 
identify unnumbered source that matches BR line numbers, it needs to honor an  
#Autonumber# (or similar) convention and number the BR statements the way Lexi does. 
