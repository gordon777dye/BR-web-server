---
title: Information & debugging commands
file: spec.md
source: §Commands → System / Debugging / Information Commands
category: 70-commands
subcategory: 70-commands/information
kind: spec
status: 2b           # reference base + br_tree fold (BREAK detail, DISPLAY -p/MAT, STATUS/VERIFY, DEBUG_STR, LIST search); PROCIN/PROGRAM$ home resolved; no conflicts
recovered-fold: NOSTEP (redirect-collision page re-fetched; NOSTEP/NOTRACE already covered by the GO bnf in program-management — pruned; verbatim retained on the BR wiki)
related: [program-management, editing]
keywords: [STATUS, LIST, TRACE, DISPLAY, LOGGING, STEP, BREAK, TIME, ALL, FONTS, NORESTORE, DEBUG_STR, PROGRAM$, ATTRIBUTES, BREAKPOINTS, COLORS, DIMS, ENCRYPTION, LOCKS, MEMORY, USERS]
corrections:
  - "From the BR 5.0 parsers (see br50 br/docs/FLAGS.md), 2026-10-21, source reading not yet confirmed by a run: the BREAK paragraph said conditional breakpoints aren't set with BREAK - BR 5.0 has `IF <cond>` on a target, `BREAK IF <cond>` and `BREAK IF OFF`, plus `BREAK FILE` (commandc.cpp breakDisplay(); release notes 3.10, 3.11); DISPLAY gains IF and FILE likewise; STATUS's topics are listed in full from table8k with -P and redirection (statcmd.cpp); VERIFY described as it is, a message and no check (wbos.cpp VERIFY_CMD); pointer to the new `-?` command help added."
  - "MSG(\"sleeptime\",n) unit corrected to milliseconds (was given as seconds here; see MSG.md corrections for the brmsg.cpp evidence). Reported in context/ERRORS.md 2026-09-28."
  - "BREAK, TIME, ALL, FONTS and NORESTORE added to the frontmatter keywords. All five are in this page's BNF — BREAK has an anchor of its own — and none was declared. Found in brls phase 13."
  - "The MSG bullet documented MSG(\"KB\"), which BR 5.0 removed - it now raises 0412 - and
    described the function as driving the WINDOWS keyboard, which it has not done since
    2026-09-30: send puts its keys into BR's own buffer and reaches this session only. Rewritten
    around send; see MSG.md's corrections for the brmsg.cpp evidence. BR 5.0, 2026-10-12."
  - "DEBUG_STR and PROGRAM$ added to the frontmatter keywords. Both are documented in this page's
    body (`DEBUG_STR(level, str$)` has its own anchor; `PROGRAM$` is described alongside `PROCIN`)
    and were routing nowhere despite the status line above already noting their 'home resolved'.
    Found 2026-09-11 auditing `go run ./cmd/gendata`'s unrouted-function list against actual
    br_tree content."
---

# Information & debugging commands

Inspecting state and debugging a running program: date/time, the command console,
single-stepping, breakpoints, variable display, and logging.

<a id="syntax"></a>
## Syntax

```bnf
DATE [<mm-dd-yy>|<mm/dd/yy>]   TIME [<hh:mm:ss>]   -- DA/TI; show/set session date & time (this terminal)
RUN [STEP] [TRACE] [NORESTORE|RESTORE]             -- step / trace execution (resume with GO → program-management)
BREAK [-p <prog>] { <line>[:<clause>] | <label>: | <var> | FN<name> | BEGIN } [IF <cond>] [OFF]   -- ST mode triggers
BREAK IF <cond> | BREAK IF OFF                      -- test <cond> after every line (5.0)
BREAK FILE <name> [OPEN|CLOSE] [OFF]                -- stop when the file is opened or closed (5.0)
BREAK ALL OFF                                       -- clear every breakpoint
DISPLAY [-p <prog>] { <var> | MAT <array> | ALL } [IF <cond>] [OFF | PRINT | '>'['>'] <file>]
DISPLAY FILE <name> [OPEN|CLOSE] [OFF] [PRINT]      -- report the file's OPENs and CLOSEs (5.0)
LIST [<range>] [~]{ "<str>" | '<str>' }[…3x] [REPLACE "<new>"] [PRINT | '>'['>'] <file>]   -- search/replace
LOGGING <level> ',' <logfile> [',' UNATTENDED] [',' +CONSOLE]
STATUS [<topic>…] [-P] ['>'['>'] <file>]          -- ST; topics below
VERIFY                                               -- V; reports that verify is always on
```

Each of these commands lists its forms and options when given
[`-?`](../program-management/spec.md#command-help) alone (`STATUS -?`, BR 5.0).

<a id="semantics"></a>
## Semantics

- <a id="date-time"></a>**DATE/TIME** (commands, `DA`/`TI`) set or show the clock for this terminal,
  **session only** (per-workstation, lost on exit, no effect on the OS clock) — distinct from the
  [`DATE$`/`TIME$`](../../10-language/data-manipulation/system-functions/spec.md#date-functions)
  *functions* that only read it. Quirk: `DATE` is *set* as `mm-dd-yy` (or `mm/dd/yy`) but *reported*
  as `yy/mm/dd` (legacy — programs normally use the function, not the command).
- **RUN STEP** pauses after each action statement (Enter = next, `GO` = resume); **TRACE** prints
  line numbers as they execute; combine `STEP TRACE`. The fuller `GO [STEP|TRACE] [.line]` resume /
  temporary-breakpoint forms and Shift+F1–F5 stepping are in
  [program-management](../program-management/spec.md#go).
- <a id="break"></a>**BREAK** drops a program into STEP mode when its target is hit: a `line`
  (must be an executable line — flow/assignment/I-O; not comments, `DATA`, or `DIM`), a `label:`,
  a changed `variable`/array/array-element (e.g. `BREAK CUSTOMER$(6)`, as of 4.16), a `FNname`, or
  `BEGIN` (on entry). `BREAK var` also implies `DISPLAY var`. `OFF` clears one setting, `ALL OFF`
  clears all; `-p <prog>` masks which program/libraries it applies to. **Conditional** breakpoints
  (BR 5.0): `IF <cond>` after a target stops only when the condition is true, and `BREAK IF <cond>`
  with no target tests it after every line (`BREAK IF OFF` ends that). Before 5.0 the way was a
  stored `IF A>B THEN EXECUTE "go step"`. **`BREAK FILE <name>`** stops when the file is opened or
  closed (`OPEN` or `CLOSE` for one of the two).
- <a id="display"></a>**DISPLAY** monitors variables as they change, printing
  `line  var  new-value`. It takes whole arrays (`DISPLAY MAT CUSTOMER$`) and single elements
  (`DISPLAY CUSTOMER$(5)`); `-p <prog>` masks programs; `OFF` stops it. `IF <cond>` (BR 5.0)
  reports a change only when the condition is true, and takes a variable of its own. `DISPLAY FILE
  <name>` reports the file's OPENs and CLOSEs. In STEP/error mode, just typing a variable name prints
  its current value.
- <a id="list-search"></a>**LIST "str"** searches the program (and `REPLACE "new"` replaces):
  **single** quotes match case-insensitively, **double** quotes require an exact-case match, `~`
  negates a term, and up to three terms combine (all must match). Edit-while-running tip: change a
  line, then `LIST … >file` to record it; `LOAD` that source later. (Plain `LIST <range>` for
  display/editing is in [editing](../editing/spec.md#list).)
- **LOGGING** writes a level-filtered log (0 major-error … 5 minor-event … 9 debugging).
  <a id="debug-str"></a>**`DEBUG_STR(level, str$)`** (function, BR 4.3+) emits `str$` to the log
  (when `level` ≤ the active log level) and to the debugger, or to the command console if no
  debugger is attached and GUI is ON (levels >10 clamp to 10).
- <a id="status-verify"></a>**STATUS** (`ST`) reports system state by topic; with none, the
  general status (program, active procedures, …). Topics, any of which may be abbreviated:
  `ALL`, `ATTRIBUTES`, `BREAKPOINTS`, `BTREE_VERIFY`, `COLORS`, `CONFIG`, `DATABASE`,
  `DIMS [LENGTHS [n]]`, `ENCRYPTION`, `ENV [name]`, `FILES [name]`, `FONTS`, `KEYBOARD`, `LIBRARY`,
  `LOCKS [name]`, `MEMORY`, `PRINTER`, `STACKS [RESET]`, `SUBSTITUTE` and `USERS`; a name after
  `ENV`, `FILES` or `LOCKS` narrows the report to it. `-P` pauses after each screenful and
  `>file`/`>>file` redirects. **VERIFY** (`V`) is kept for old procedures: in BR 5.0 it only
  reports `Verify is always on.` and checks nothing.
- <a id="console"></a>**Console**: the **command console** is the programming/run window (the
  bottom row is the **command line**); commands typed there run immediately, and you can inspect
  variables mid-run. `MSG`/`BELL` signal the operator.
- <a id="msg"></a>**`MSG("send", str$)`** (function, Windows/CS only — not raw Unix/Linux
  terminals) types a string into **this session**: the keys go into BR's own key buffer, the same
  ring a key pressed in BR's window lands in, so they reach no other window and need no focus.
  Special keys go in pipes (`MSG("send","|CTRL+|c|CTRL-|")`), and `MSG("sleeptime", ms)` paces them
  in milliseconds (default 200 = 0.2s) — `MSG` returns before they arrive, since they are fed in one
  at a time while the program runs. **`MSG("kb")` was removed in BR 5.0 and raises `0412`**; it was
  only `send` behind a foreground-window check, and error `0413` went with it. The full action list
  (twenty-five, of which a restricted session permits eighteen) and the key table: [MSG](MSG.md).
- <a id="printer-list"></a>**`PRINTER_LIST(MAT a$)`** (function) redims `a$` to the active Windows
  printers (default first) and returns the count; the names double as `OPEN "NAME=PRN:/…"` targets
  (any matching substring suffices). Idiom + spooling tip: [PRINTER_LIST](PRINTER_LIST.md).
- <a id="procin-program"></a>**`PROCIN`** returns 1 when input is coming from a procedure file
  (else 0 from the screen) — useful to echo `RUN PROC` input. **`PROGRAM$`** returns the full
  path (`br_filename$`) of the loaded `.br`/`.wb` program — handy in shared error routines. *(Both
  are value-returning functions; they live here as console/debugging aids and are cross-linked from
  the [function index](../../10-language/data-manipulation/system-functions/spec.md#system-info).)*

<a id="examples"></a>
## Examples

```text
RUN STEP TRACE
BREAK 1000           ! stop at line 1000;  BREAK TOTAL stops when TOTAL changes
DISPLAY MAT CUSTOMER$
LIST 'error'                 ! find error/ERROR/Error (case-insensitive)
LIST 60 300 '2,40,C 20,R' REPLACE "3,42,C 30,R"
LOGGING 9, trace.log
```

<a id="see-also"></a>
## See also

- [program-management](../program-management/spec.md) — `RUN`/`GO`/`STOP`, `GO STEP/.line`, procedures
- [editing](../editing/spec.md#list) — `LIST` for display/editing (vs `LIST "search"` here)
- [filename-patterns](../file-directory/filename-patterns.md#tab-completion) — Tab completes the file after `>`/`>>` of `STATUS`, `DISPLAY`, `LIST` and `RUN` at `READY`
- [system-functions](../../10-language/data-manipulation/system-functions/spec.md#system-info) — `ERR`/`LINE`/`CODE`, and the `PROCIN`/`PROGRAM$` cross-links
- Backing keyword pages retained (deep reference): [MSG](MSG.md) (keystroke table),
  [PRINTER_LIST](PRINTER_LIST.md) (printer-select idiom), [PROCIN](PROCIN.md), [PROGRAM$](PROGRAM$.md)

*(Other backing pages — `Information_Commands`, `Command_Console`, `Command_line`,
`Display_(Command)`, `Date_(Command)`, `DEBUG_STR`, `ECHO`, `Increment`, `BELL` — were folded into
this spec and pruned; the `Break_(Command)` page from program-management was folded into `#break`
here.)*
