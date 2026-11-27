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
keywords: [HELP, STATUS, LIST, TRACE, DISPLAY, LOGGING, STEP, BREAK, DATE, TIME, ALL, FONTS, NORESTORE, DEBUG_STR, PROGRAM$, ATTRIBUTES, BREAKPOINTS, COLORS, DIMS, ENCRYPTION, LOCKS, MEMORY, USERS]
corrections:
  - "DISPLAY FNname documented (BR 5.03, 2026-11-24; br50 br/docs/BR503 Release_Notes.md 2.12): the value
    a function returns, at each return, and implied by BREAK FNname. From run.cpp (functionReturnDisplay,
    called by popFlowStack) and commandc.cpp; tested by br50's br/aiaccess/fnreturn.py."
  - "BREAK -p is set again at every LOAD of the program, now from source too (BR 5.03, 2026-11-24; release
    notes 3.9): command7.cpp's programLoaded(), called by command.cpp at the end of a source load; tested by
    br50's br/aiaccess/aftertest.py."
  - "BREAK ... AFTER n documented (BR 5.03, 2026-11-24; br50 br/docs/BR503 Release_Notes.md 2.11): passes
    over the first n stops of a line, variable, FNname, system function or BREAK IF; before IF; counted
    afresh at RUN; shown by STATUS BREAK. From commandc.cpp (breakDisplay), run.cpp (checkbreakpoints)
    and command1.cpp (conditionalBreakCommand), tested by br50's br/aiaccess/aftertest.py."
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
  - "DATE added to keywords:, and a `date` anchor beside `time`: the DATE command is documented here and
    was not declared, so it routed nowhere of its own (2026-11-22). Found when brls stopped linking a sense to another sense's section: the DATE command, the procedure SKIP and the POS= clause had been linked only to the DATE function, FORM's SKIP n and the POS format code."
  - "TRACE documented in full beside BREAK (2026-11-24, BR 5.03; br50 br/docs/BR503 Release_Notes.md 2.8):
    the three modes LINES, LABELS and PRINT, the console options and the statement side by side, OFF
    remembering the modes, and how tracing meets STEP, SOURCE, BREAK IF and STATUS BREAK. The RUN and
    GO lines of the syntax gain the trace options and NOTRACE, and the TRACE line gives the modes in
    any order. From primop0.cpp (traceOn, traceOff), command9.cpp and run.cpp, and tested by br50's
    br/aiaccess/tracetest.py and tracescreen.py."
  - "BREAK <system function> documented (BR 5.03, 2026-11-24): stops before a clause that calls it;
    BREAK FNname on a library function now stops from the caller's prompt; consecutive breakpoints
    each stop. From run.cpp (checkbreakpoints, clauseBreakFunction, functionBreakPointMatch) and
    commandc.cpp, tested by br50's br/aiaccess/fnbreak.py."
---

# Information & debugging commands

Inspecting state and debugging a running program: date/time, the command console,
single-stepping, breakpoints, variable display, and logging. The `HELP` command, which shows
br_tree topics in the browser or on the console, has its own page: [HELP](HELP.md).

<a id="syntax"></a>
## Syntax

```bnf
DATE [<mm-dd-yy>|<mm/dd/yy>]   TIME [<hh:mm:ss>]   -- DA/TI; show/set session date & time (this terminal)
RUN [<program>] ['>'['>']<file>] [STEP] [TRACE [LINES|LABELS|PRINT|'>'['>']<file>]… [ON|OFF] | NOTRACE] [NORESTORE|RESTORE]
                                                    -- run, stepping and/or tracing; options in any order
GO [<line>] [STEP] [TRACE [LINES|LABELS|PRINT|'>'['>']<file>]… [ON|OFF] | NOTRACE] [NORESTORE|RESTORE]
                                                    -- resume a halted program, the same options
BREAK [-p <prog>] { <line>[:<clause>] | <label>: | <var> | FN<name> | <system-function> | BEGIN } [OFF | '>'['>'] { <file> | <array$> }] [AFTER <n>] [IF <cond>]   -- ST mode triggers
BREAK [AFTER <n>] IF <cond> | BREAK IF OFF          -- test <cond> after every line (5.0)
BREAK FILE <name> [OPEN|CLOSE] [OFF]                -- stop when the file is opened or closed (5.0)
BREAK ALL OFF                                       -- clear every breakpoint
DISPLAY [-p <prog>] { <var> | MAT <array> | FN<name> | ALL } [OFF | PRINT | '>'['>'] { <file> | <array$> }] [IF <cond>]
                                                    -- IF <cond> is last on BREAK and DISPLAY: it takes the rest of the line
DISPLAY FILE <name> [OPEN|CLOSE] [OFF] [PRINT]      -- report the file's OPENs and CLOSEs (5.0)
TRACE [LINES|LABELS|PRINT]… { OFF | [ON] ['>'['>']<file>] }  -- the statement: set the trace modes, in a program
                                                    -- or typed at READY (BR 5.03 for LINES, LABELS, PRINT OFF)
HELP <category> <topic>                             -- display documentation in the user's browser
LIST [<range>] [~]{ "<str>" | '<str>' }[…3x] [REPLACE "<new>"] [PRINT | '>'['>'] <file>]   -- search/replace
LOGGING <level> ',' <logfile> [',' UNATTENDED] [',' +CONSOLE]
STATUS [<topic>…] [-P] ['>'['>'] <file>]          -- ST; topics below
VERIFY                                               -- V; reports that verify is always on
```

Each of these commands lists its forms and options when given
[`-?`](../program-management/spec.md#command-help) alone (`STATUS -?`, BR 5.0).

<a id="semantics"></a>
## Semantics

- <a id="date-time"></a><a id="date"></a><a id="time"></a>**DATE/TIME** (commands, `DA`/`TI`) set or show the clock for this terminal,
  **session only** (per-workstation, lost on exit, no effect on the OS clock) — distinct from the
  [`DATE$`/`TIME$`](../../10-language/data-manipulation/system-functions/spec.md#date-functions)
  *functions* that only read it. Quirk: `DATE` is *set* as `mm-dd-yy` (or `mm/dd/yy`) but *reported*
  as `yy/mm/dd` (legacy — programs normally use the function, not the command).
- **RUN STEP** pauses after each action statement (Enter = next, `GO` = resume); **TRACE** shows
  the program's flow as it runs ([below](#trace)); combine `STEP TRACE`. The fuller
  `GO [STEP|TRACE] [.line]` resume / temporary-breakpoint forms and Shift+F1–F5 stepping are in
  [program-management](../program-management/spec.md#go).
- <a id="trace"></a>**TRACE** shows where a program goes while it runs, without stopping it, where
  `BREAK` stops it at a chosen point. It has three **modes** (BR 5.03; before, line numbers were the
  only kind):
  - **LINES**: each line's number as the line starts, five digits (`00120`). The line a `GO <line>`
    resumes at is not shown; the lines after it are.
  - **LABELS**: each line label the run reaches, by `GOTO`, `GOSUB` or falling into it,
    with its colon (`POST_LEDGER:`). With both on, a line's label comes before its number.
    Labels are kept with the source, so a program saved without its source shows none.
  - **PRINT**: where it goes. Without it, each item and a space are added to the main window's bottom
    line, which wraps onto a new line when full; with it, to the system printer (BR opens `PRN:` if
    the program has not). While the program waits at a `PAUSE`, the bottom line
    being built is covered by the prompt; it shows once the run goes on.
  - <a id="trace-file"></a>**`>file`** or **`>>file`** (BR 5.03): to a file, which `>` replaces and
    `>>` adds to. The trace is laid out for reading: each label is a line of its own, and the line
    numbers between labels follow one another on a line, blank-separated, starting a new line before
    one would pass column 80:
    ```
    POST_LEDGER:
    00800 00810 00820 00830 00840 00850 00860 00870 00880 00890 00900 00910 00920
    00930 00940
    ```
    Each item is written as it happens, so the file can be read while the program is paused. It
    stays open while the run continues, through `PAUSE`s and stops, and closes at a bare `TRACE OFF`
    (or `NOTRACE`) and when the program ends and BR returns to READY. A `TRACE ON` that resumes
    tracing to it reopens it and **adds** to it, whether it was named with `>` or `>>`. `RUN`
    forgets it. The name is a file, never an array: `>A$` naming an array of the program is refused
    with error 315. The file is opened by the same code as `DISPLAY`'s and `BREAK`'s redirection, so
    names, drives and sessions work as they do there.

  `PRINT` and a file are exclusive, and **the last one named wins**: `RUN TRACE >t.txt PRINT` traces
  to the printer, `RUN TRACE PRINT >t.txt` to the file, and naming the printer closes the file.

  BR also logs each item at logging level 12, as `Trace line 00120 in <program>` or
  `Trace label POST_LEDGER: in <program>`, so `LOGGING 12, <file>` gives a permanent record of the
  flow that survives the screen.

  **Turning it on and off.** The console options and the statement set the same modes:

  | Console, on `RUN` or `GO` | Statement, in a program or at READY | Effect |
  |---|---|---|
  | `TRACE` | `TRACE ON`, `TRACE` | resume the modes the last `OFF` stopped; with none remembered, line numbers |
  | `TRACE LINES` | `TRACE LINES ON` | line numbers |
  | `TRACE LABELS` | `TRACE LABELS ON` | labels |
  | `TRACE LINES LABELS` | `TRACE LABELS LINES ON` | both, named in any order |
  | `TRACE PRINT` | `TRACE PRINT`, `TRACE PRINT ON` | to the printer |
  | `TRACE PRINT OFF` | `TRACE PRINT OFF` | back to the window, the other modes left on |
  | `TRACE >t.txt`, `TRACE LABELS >>t.txt` | `TRACE LABELS ON >t.txt`, `TRACE >>"t.txt"` | to a file, replacing or adding to it |
  | `TRACE LABELS OFF` | `TRACE LINES OFF`, `TRACE LABELS OFF` | that mode off, the others left on |
  | `NOTRACE`, `TRACE OFF` | `TRACE OFF` | every mode off, remembering which were on |

  - **The statement turns on or off only the modes it names.** `TRACE LABELS ON` adds labels to any
    line tracing already on, and `TRACE PRINT` or `TRACE >t.txt` only selects where tracing goes; it
    does not start it, so write `TRACE LINES PRINT ON` or `TRACE LINES ON >t.txt` (or a `TRACE ON` as
    well).
  - **In the statement, `>file` comes last**, after `ON` if there is one, and needs no quotes: an
    unquoted name runs to the next blank and is the file's name as written, so `>F$` is a file named
    `F$`, not the variable. A name with blanks in it goes in quotes, and a quoted name may be a string
    expression (`>"t"&STR$(N)&".txt"`). `LIST` shows an unquoted name in quotes. A file that cannot be
    opened is an error of the `TRACE` statement, which `ON ERROR` traps.
  - **On the console, the word `TRACE` starts tracing.** `RUN TRACE PRINT` traces line numbers to the
    printer, and `RUN TRACE LABELS` traces exactly the labels, turning line numbers off. Every trace
    option follows `TRACE`: before it, `LINES`, `LABELS`, `ON` and `OFF` are a program name to `RUN`
    and a line label to `GO`, and `PRINT` does nothing. Those four must be spelled out; `PRINT` may
    be abbreviated. Options may come in any order with `STEP`, `NORESTORE` and the rest, and are
    acted on once the whole command is read, so `GO TRACE PRINT OFF` never switches anything on.
  - **`>file` on the console belongs to `TRACE` only when it follows `TRACE`.** `RUN TRACE LABELS
    >t.txt` sends just the trace to `t.txt`. A `>file` before `TRACE` (or with no `TRACE`) is `RUN`'s
    own printer redirection, as before, and the two are independent: `RUN >p.txt TRACE >t.txt` puts
    the program's printer output in `p.txt` and the trace in `t.txt`. `GO` accepts `>file` only after
    `TRACE`.
  - **`OFF` remembers.** A `TRACE OFF` that names no mode, `GO TRACE OFF` and `NOTRACE` stop every mode,
    the printer or file included, and remember which were on; a later `TRACE ON`, bare `TRACE` or `GO TRACE`
    resumes exactly those. So a program can bracket the region it wants traced, and a halted run can
    be resumed with tracing off and back on, without naming the modes again. An `OFF` with nothing on
    leaves the memory alone. `RUN` starts afresh: it clears the modes and forgets the memory. `GO`
    keeps both.
  - **With other debugging.** `STEP TRACE` shows each line number and then stops before the line.
    `SOURCE` after `TRACE` (`RUN TRACE SOURCE`) shows each line's source in place of its number.
    A `BREAK … IF` or `BREAK IF` condition is evaluated with tracing and stepping suspended, so it
    adds nothing to the trace. `STATUS BREAK` lists breakpoints and displays, not the trace modes.
  - **Compatibility.** A program that uses `TRACE LINES`, `TRACE LABELS`, `TRACE PRINT OFF` or `>file` needs
    BR 5.03: an older BR cannot compile them and misreads them in a saved program. `TRACE ON`,
    `TRACE OFF` and `TRACE PRINT` behave as they always did, except that a bare `TRACE` now means
    `TRACE ON` (it was undefined). The statement's grammar is in
    [other-flow](../../10-language/flow-control/other-flow/spec.md#trace), the console forms in
    [command-signatures](../command-signatures.md#trace-options).
- <a id="break"></a>**BREAK** drops a program into STEP mode when its target is hit: a `line`
  (must be an executable line — flow/assignment/I-O; not comments, `DATA`, or `DIM`), a `label:`,
  a changed `variable`/array/array-element (e.g. `BREAK CUSTOMER$(6)`, as of 4.16), a `FNname`, a
  system function (BR 5.03), or `BEGIN` (on entry). `BREAK var` also implies `DISPLAY var`. A redirection (`> file`,
  `>> file`, `> A$`, as for [DISPLAY](#display)) does not change the break itself, but the line
  that implied display shows for a changed variable goes there instead of the screen
  (`BREAK TOTAL >> TRACE$`); with `OFF` it is refused (1006). **The redirection must come before
  `IF`**: `IF` takes the rest of the command as its condition, so `BREAK TOTAL > T$ IF TOTAL>100`
  works, while in `BREAK TOTAL IF TOTAL>100 > T$` the condition is `TOTAL>100 > T$`, which is not
  a valid expression (error 1026 when the break is reached). `OFF` clears one setting, `ALL OFF`
  clears all; `-p <prog>` masks which program/libraries it applies to, and is remembered: the
  breakpoint is set again whenever a program of that name is loaded, compiled or from source (from
  source only since BR 5.03, and only once every line has compiled). **Conditional** breakpoints
  (BR 5.0): `IF <cond>` after a target stops only when the condition is true, and `BREAK IF <cond>`
  with no target tests it after every line (`BREAK IF OFF` ends that). Before 5.0 the way was a
  stored `IF A>B THEN EXECUTE "go step"`. **`BREAK FILE <name>`** stops when the file is opened or
  closed (`OPEN` or `CLOSE` for one of the two).
  - <a id="break-function"></a>**`BREAK FNname`** stops inside the function, at its first line, once
    the call has been made and its arguments evaluated. A library function stops too, whether the
    break was set at the calling program's prompt or with `-p <library>` (before BR 5.03 only the
    second worked). When the function returns, the value it returned is shown, as
    [`DISPLAY FNname`](#display-function) shows it (BR 5.03): where the break's redirection sends
    it, or to the screen or an attached debugger.
  - **`BREAK <system function>`** (BR 5.03), such as `BREAK LEN`, `BREAK STR$` or `BREAK VAL`, stops
    **before any clause** that calls the function, since a system function has no lines of its own
    to stop in: `BREAK LEN` stops before `LET B=LEN(A$)`, and again before every later clause that
    calls `LEN`. `GO` (or Enter) runs the clause and goes on. Any of BR's string or numeric functions
    can be named, spelled out in full; `OFF` clears it, `-p` chooses the program as for any
    breakpoint, and `STATUS BREAK` lists it as `BREAK FUNCTION LEN`. `AFTER <n>` is taken (see
    below); `IF` and a redirection are refused (1006), and `DISPLAY` does not take a function (1070). A clause is stopped before if its
    compiled code calls the function, even where the call would not be reached.
  - **When a watch is checked** (BR 5.03). `BREAK var` and `DISPLAY var` compare the variable
    only after a statement that wrote a watched variable (an assignment, `INPUT`, `LINPUT`,
    `READ`, `MAT`, `NEXT`, a function that fills an argument such as `STR2MAT`, or output
    redirected into an array), so a watch costs nothing while nothing writes it. A variable a
    function changes through a parameter passed by reference is caught right after that line,
    inside the function, even when the function is in a library.
  - <a id="break-after"></a>**`AFTER <n>`** (BR 5.03) passes over a breakpoint's first *n* stops and
    stops from the next one on: `BREAK TOTAL AFTER 5` stops the 6th time `TOTAL` changes and every
    time after, `BREAK 1200 AFTER 99` the 100th time line 1200 is reached, `BREAK FNCALC AFTER 2`
    at the third call, `BREAK LEN AFTER 10` before the 11th clause that calls `LEN`. It goes after
    the target and **before `IF`**, which takes the rest of the command; with `IF` only the times
    the condition holds are counted (`BREAK TOTAL AFTER 3 IF X>0`, and with no target
    `BREAK AFTER 2 IF X>100`, the third line after which `X>100`). The count starts again at each
    `RUN`, and entering the `BREAK` again sets it afresh. `STATUS BREAK` shows it
    (`BREAK LINE 01200:01 AFTER 99`) and, part way through a run, how many are left
    (`AFTER 99 (40 to go)`); a `-p` breakpoint keeps its `AFTER` when the program is loaded again.
    `AFTER` is a keyword only when a number follows, so a variable named `AFTER` can still be
    watched. It is refused (1006) with `OFF`, `ALL`, `BEGIN` or `FILE`, by `DISPLAY`, and twice.
  - With several breakpoints, each stops in turn: before BR 5.03, a stop passed over the next
    check, wherever it was, so `BREAK 60` and `BREAK 70` stopped at 60 only.
- <a id="display"></a>**DISPLAY** monitors variables as they change, printing
  `line  var  new-value`. It takes whole arrays (`DISPLAY MAT CUSTOMER$`) and single elements
  (`DISPLAY CUSTOMER$(5)`); `-p <prog>` masks programs; `OFF` stops it. `IF <cond>` (BR 5.0)
  reports a change only when the condition is true, and takes a variable of its own. **The
  redirection must come before `IF`**, which takes the rest of the command as its condition:
  `DISPLAY TOTAL > T$ IF TOTAL>100`, not `DISPLAY TOTAL IF TOTAL>100 > T$`.
  `PRINT` sends the lines to the printer and `> file` to a file (`>>` adds to it). Any number of
  `DISPLAY`s may name the same file; they share one handle on it (BR 5.03; before, a fifth to
  one file failed with error 4147 or lost its lines to the screen). `> A$` sends
  them into a one-dimensional string array of the program the command is given in, one line to
  an element: `>` empties it first, `>>` keeps what it holds, and it is redimensioned as each
  line is written. A line longer than the elements makes them all that long, at the console and
  under `EXECUTE` alike; the one exception is an `EXECUTE` run under `ON SOFLOW IGNORE`, which
  cuts the line to the element length. Growing stops at
  `SOFLOW-GROW MAX=`. A display does not watch the array it fills: `DISPLAY ALL > A$` leaves `A$`
  out, and `DISPLAY MAT A$ > A$` (or an element of it) is refused (1006). If the program or the
  array is gone when a line is written, the line goes to the screen. `DISPLAY FILE
  <name>` reports the file's OPENs and CLOSEs. In STEP/error mode, just typing a variable name prints
  its current value.
  - <a id="display-function"></a>**`DISPLAY FNname`** (BR 5.03) says what the function returns, each
    time it returns, with the line and clause that called it, and the run goes on:
    `line 00080:01, FNSQ returned, value = 4`. The line goes where the display sends it (the
    screen, `PRINT`, a file or an array). It works for a single-line or multi-line `DEF`, numeric or
    string, and a library function, whether set from the calling program or with `-p <library>`.
    `IF` is refused with a function (1006): a function returns in the middle of a statement, where
    the run cannot halt to test a condition. `DISPLAY ALL` leaves functions out, and a system
    function (`DISPLAY LEN`) is refused (1070). [`BREAK FNname`](#break-function) implies it.
- <a id="list-search"></a>**LIST "str"** searches the program (and `REPLACE "new"` replaces):
  **single** quotes match case-insensitively, **double** quotes require an exact-case match, `~`
  negates a term, and up to three terms combine (all must match). Edit-while-running tip: change a
  line, then `LIST … >file` to record it; `LOAD` that source later. (Plain `LIST <range>` for
  display/editing is in [editing](../editing/spec.md#list).) Syntax:
  `LIST [<from> [<to>]] [~]{"<str>"|'<str>'}[…3x] [REPLACE "<str>"] [CLAUSES] [{>[>]<file>|PRINT}]`.
  A term with `~` must be **absent** from a line and one without it **present**, in any mix, up to three; the
  search runs over `<from>` to `<to>` (line numbers or labels) or the whole program. With `REPLACE` the lines are
  shown **with the replacement made**, but nothing is stored until you scroll back to each line and press Enter on it;
  to keep them all, redirect the output to a file and run it with `PROC`. `-P` shows one line at a time during a search
  or replace.
- **LOGGING** writes a level-filtered log (0 major-error … 5 minor-event … 9 debugging).
  <a id="debug-str"></a>**`DEBUG_STR(level, str$)`** (function, BR 4.3+) emits `str$` to the log
  (when `level` ≤ the active log level) and to the debugger, or to the command console if no
  debugger is attached and GUI is ON (levels >10 clamp to 10). **In a restricted session** it is
  how a program says what it is in its audit log, and the line is marked as the program's: it reads
  `Program note: <str$>`, control characters become spaces so it stays on one line, it is cut to
  200 characters, and a `level` below 5 is logged at 5, so a note cannot pass for one of BR's own
  entries or errors. See [LOGGING in a restricted session](../../00-configuration/config-directives/LOGGING.md#restricted-session).
- <a id="status-verify"></a><a id="status"></a>**STATUS** (`ST`) reports system state by topic; with none, the
  general status (program, active procedures, …). Topics, any of which may be abbreviated:
  `ALL`, `ATTRIBUTES`, `BREAKPOINTS`, `COLORS`, `CONFIG`, `DATABASE`,
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
- <a id="help"></a>**`HELP <category> <topic>`** shows the br_tree topic for those words (`HELP COMMANDS LIST`,
  `HELP LIBRARIES FILEIO`), in the person's own web browser when br_tree2 is found and as pages on the
  console otherwise. `HELP` alone lists what it covers; Tab, Enter and the arrow keys then work together on
  that list, and Backspace at the end of a word takes the whole word and offers the words that fit there.
  F1 and Ctrl-Y show the topic for the word at the cursor. The browser tab, where the trees are found
  (`CONFIG HELPTREE`, `HELPTREE2`) and what the browser connects to: [HELP](HELP.md).

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
- [HELP](HELP.md) — the `HELP` command: Tab, Enter and arrow keys on the command line, the browser help tab, where the trees are found
- Backing keyword pages retained (deep reference): [MSG](MSG.md) (keystroke table),
  [PRINTER_LIST](PRINTER_LIST.md) (printer-select idiom), [PROCIN](PROCIN.md), [PROGRAM$](PROGRAM$.md)

*(Other backing pages — `Information_Commands`, `Command_Console`, `Command_line`,
`Display_(Command)`, `Date_(Command)`, `DEBUG_STR`, `ECHO`, `Increment`, `BELL` — were folded into
this spec and pruned; the `Break_(Command)` page from program-management was folded into `#break`
here.)*
