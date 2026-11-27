---
title: Loops & branching
file: spec.md
source: §Control Structures (Loops, Branching)
category: 10-language
subcategory: 10-language/flow-control/other-flow
kind: spec
status: 2b           # reference base + br_tree enrichment (STOP/END/PAUSE/CHAIN termination); no conflicts
recovered-fold: GOSUB, ON_GOSUB, RANDOMIZE (3 redirect-collision pages folded from re-fetched source — added RANDOMIZE, GOSUB error-1011 immediate restriction, ON-GOSUB NONE-is-a-GOSUB-branch; verbatim retained on the BR wiki)
corrections:
  - "The syntax summary's TRACE line brought into line with §TRACE (2026-11-24): it still read
    `TRACE {ON|OFF|PRINT}`, the pre-5.03 form, after §TRACE gained the modes and the trace file. The
    new line gives the form information/spec.md's summary of the statement gives."
  - "LINES, LABELS, `>` and `>>` added to the frontmatter keywords (2026-11-24). They are BR 5.03's
    TRACE clause keywords (table4k; synbc.cpp's trace[]), which §TRACE documents and did not
    declare, so brls routed none of them."
  - "TRACE added as a statement. BR has a syn.txt tree for it — `TRACE` with three branches, PRINT, OFF and an optional ON — and a primary operation to execute it (TRACE_PRI, primop0.cpp), but the reference documented TRACE only as an option of the RUN and GO *commands*, so the statement form was missing from the tree entirely. It was the one genuinely undocumented statement left in gendata's coverage report. Semantics read from BR's source: primop0.cpp switches on the secondary opcode, where OFF_SEC (0x05) clears RUN_TRACE|RUN_TRACE_PRINT, ON_SEC (0x04) sets RUN_TRACE, and PRINT_SEC (0x06) sets RUN_TRACE_PRINT — the three constants are defined together in basoprcmn.h under the comment `/* trace */`. run.cpp gates the per-line output on RUN_TRACE and picks FILENBR_MAIN_PRINTER (255) over FILENBR_MAINWINDOW (0) on RUN_TRACE_PRINT, printing the line number with L_05ld (`%05i`). That gating is why TRACE PRINT alone traces nothing, and command9.cpp shows the console form guarding the same bit differently. A bare TRACE is left marked unverified rather than assumed equivalent to TRACE ON: command4.cpp stores no operand byte when an optional keyword is absent, so primop0 reads whatever follows the primary op. Added in brls phase 5."
  - "TO and OFF added to the frontmatter keywords. Both are table4k clause keywords this page's own BNF documents — `FOR <v> = <e> TO <e>` and `TRACE {ON|OFF|PRINT}` — and neither was declared, so a reader looking either one up reached nothing. STEP, ON and PRINT, from the same two trees, were declared already; these two were the siblings that got missed. Found in brls phase 13."
  - "A note added under §ON…GOTO/GOSUB that `FKEY`/`FNKEY` used bare or with an operator (`ON FKEY-89
    GOTO A,B`) is this form and not error-handling's `ON FKEY <n> …` condition — the full rule and its
    sourcing are on that page, since it is the condition form's grammar (one target, no repeat) that
    forces the general form to be the only reading whenever a second target follows."
  - "CHAIN added to §Program termination & interruption, and its deep-reference backing page
    (CHAIN.md, 11 technical notes) moved onto this page from 70-commands/program-management,
    which had misclassified it `kind: command` and filed it under the commands subtree. CHAIN
    is a statement, so it belongs with its termination siblings STOP/END/PAUSE here; the full
    BNF/semantics summary stays in program-management, which is where it's coded and used."
related: [conditionals, syntax, functions-udf]
keywords: [FOR, NEXT, DO, LOOP, WHILE, UNTIL, GOTO, GOSUB, RETURN, ON GOTO, ON GOSUB, EXIT, RANDOMIZE, STOP, END, PAUSE, CHAIN, TRACE, STEP, TO, ON, OFF, PRINT, LINES, LABELS, ">", ">>"]
---

# Loops & branching

Iteration and control transfer: `FOR/NEXT`, `DO/LOOP`, `GOTO`, `GOSUB`/`RETURN`,
`ON … GOTO/GOSUB`, and `EXIT`. The `IF` decision itself is in
[conditionals](../../data-manipulation/conditionals/spec.md); the conditions are in
[expressions](../../data-manipulation/expressions/spec.md). Targets are `<line-ref>`s
(line number or label) — see [syntax](../../syntax/spec.md#line-labels).

<a id="syntax"></a>
## Syntax

```bnf
FOR <num-var> = <num-expr> TO <num-expr> [STEP <num-expr>]
    <statements>
NEXT <num-var>

DO [{WHILE|UNTIL} <condition>]
    <statements>
    [EXIT DO]
LOOP [{WHILE|UNTIL} <condition>]

GOTO  <line-ref>
GOSUB <line-ref>          ... RETURN
ON <num-expr> GOTO  <line-ref> [',' <line-ref>]* [NONE <line-ref>]
ON <num-expr> GOSUB <line-ref> [',' <line-ref>]* [NONE <line-ref>]
EXIT DO                   -- there is no EXIT FOR; leave a FOR loop with GOTO
RANDOMIZE                 -- reseed RND from the system clock
TRACE [{LINES|LABELS|PRINT}]* {OFF | [ON] ['>'['>']<file>]}  -- tracing, under program control
```

<a id="semantics"></a>
## Semantics

<a id="for-next"></a>
### FOR / NEXT
Counts the loop variable from start to end by `STEP` (default `1`; negative steps count down).
The test happens **before** each pass; the variable **retains its final value** after the loop.
`NEXT` must name the same variable as `FOR`. Loops must be fully contained (no partial overlap: the inner
`NEXT` comes before the outer `NEXT`). Leave early with `GOTO`. **How many loops can be active** is set by
the [`FORSTACK`](../../../00-configuration/config-directives/spec.md#flowstack) setting in BRConfig.sys, which
counts distinct loop *variables*, not loops: the default is **100** here (the original wiki says 20, which was the
old default), and a variable reused by many loops uses one slot. The number of times each variable is used is not
limited.

<a id="do-loop"></a>
### DO / LOOP
Flexible condition loop; the `WHILE`/`UNTIL` test may sit on `DO` (tested first — may run zero
times) or on `LOOP` (tested last — runs **at least once**). No labels needed for the structure;
leave early with `EXIT DO`. `WHILE` continues while true; `UNTIL` continues until true. `LOOP` must be the last
statement on its line, and the `LOOP` keyword is always required. With `CONFIG STYLE INDENT` (see
[`STYLE`](../../../00-configuration/config-directives/spec.md#style)), `LIST` indents the lines between `DO` and `LOOP`.

<a id="goto"></a>
### GOTO
Unconditional transfer to a `<line-ref>`. Backward jumps form loops; forward jumps skip code.
The target must exist before `SAVE`/`REPLACE`.

<a id="gosub"></a>
### GOSUB / RETURN
Calls a subroutine (a labeled/numbered block ending in `RETURN`); control returns to the line
after the `GOSUB`. The depth of nested GOSUBs is limited by the call stack (`FLOWSTACK`), which is
**configurable** via the BRConfig.sys `FLOWSTACK` directive (default **100**, 4.3+; shared with
user-defined-function returns — see
[config-directives](../../../00-configuration/config-directives/spec.md)); subroutines may call
other subroutines. `GOSUB` **can't run from the command line** (**error 1011**,
illegal immediate statement), and active GOSUBs can't be edited during an interruption; `RETURN`
resumes at the statement after the call even if that's mid-way through a multi-statement line.

<a id="on-goto"></a>
### ON … GOTO / GOSUB
Multi-way branch: the numeric expression is **rounded to the nearest integer** and selects the
*n*-th `<line-ref>` (1 = first). If the value is `< 1` or beyond the list, control goes to the
`NONE` target if present, otherwise falls through to the next line. `ON … GOSUB` returns after the
selected subroutine's `RETURN` (menu dispatch pattern); its `NONE` target is itself a **GOSUB** branch
(the routine there must also `RETURN`), not an error handler, and an `ON … GOSUB` may carry trailing
error-condition clauses.

**`FKEY`/`FNKEY` as the numeric expression** — `ON FKEY-89 GOTO A,B` and `ON FKEY GOTO A,B` are this
form, not [error-handling](../error-handling/spec.md)'s `ON FKEY <n> …` condition, whenever more than
one target follows or nothing/an operator sits where the condition's `<n>` belongs; see that page for
why the two cannot be confused for one another mid-statement.

<a id="exit"></a>
### EXIT
`EXIT DO` terminates the **innermost** `DO`/`LOOP` and continues at the first statement after it.
There is **no `EXIT FOR`** in BR — leave a `FOR`/`NEXT` loop early with `GOTO` (see
[FOR / NEXT](#for-next)).

<a id="randomize"></a>
### RANDOMIZE
Reseeds the `RND` random-number generator from the **system clock** so each run differs. **Without
`RANDOMIZE`, `RND` repeats the same sequence every time BR is loaded.** (`RND` returns 0–1; scale it,
e.g. `INT(RND*100+1)` for 1–100.)

<a id="termination"></a>
### Program termination & interruption
- <a id="stop"></a>**`STOP`** halts the program (it can be resumed with `GO` from the console); used to mark the end
  of the main line before subroutines.
- <a id="end"></a>**`END [<num-expr>]`** ends the program, **closes all files**, and sets the [`CODE`](../../data-manipulation/system-functions/spec.md#system-info)
  return value (`END 12` sets `CODE`=12; default 0). `END` is optional — a program auto-ends with
  `CODE`=0.
- <a id="pause"></a>**`PAUSE`** interrupts execution so the operator can enter commands / inspect variables; `GO`
  resumes and restores the screen (a handy debugging breakpoint).
- **`CHAIN`** also ends the program, but — unlike `STOP`/`END`/`PAUSE` — hands off to another
  program or procedure instead of stopping. It's documented in full in
  [program-management](../../../70-commands/program-management/spec.md#chain) (where it's used
  from), with its deep-reference page retained on this page as [CHAIN](CHAIN.md).

<a id="trace"></a>
### TRACE
`TRACE [LINES|LABELS|PRINT ...] { OFF | [ON] [>file|>>file] }` turns **tracing** on and off from inside the program,
rather than from the console. Tracing has three modes, named by keywords given in any order (BR
5.03; before it, only `TRACE ON`, `TRACE OFF` and `TRACE PRINT`):

- **LINES**: as each line runs, BR writes its line number, five digits, zero-padded.
- **LABELS**: as the run reaches a line with a label, by `GOTO`, `GOSUB` or falling into it, BR
  writes the label followed by a colon (`POST_LEDGER:`). With both on, a line's label comes before
  its number.
- **PRINT**: the items go to the system printer (BR opens `PRN:` if the program has not) instead
  of the main window's bottom line.
- **`>file`, `>>file`** (BR 5.03): the items go to a file, which `>` replaces and `>>` adds to. It
  comes last, after `ON` if given, and needs no quotes: an unquoted name runs to the next blank and
  is taken as written (`>F$` is a file named `F$`); a quoted one may be a string expression, and a
  name with blanks must be quoted. `LIST` shows the name in quotes. Each label is a line of its own
  and line numbers fill the lines between to 80 columns. The file closes at a bare `TRACE OFF` and
  when the program ends; `TRACE ON` reopens it to add to it. Never an array: `>A$` naming one is
  error 315. Of `PRINT` and a file, the last named wins. Details:
  [information](../../../70-commands/information/spec.md#trace-file).

Each item is followed by a space, and BR logs a `Trace line <n> in <program>` or `Trace label
<label>: in <program>` event (logging level 12). Labels are kept with the source, so a program
saved without its source shows none.

| Form | Effect |
|---|---|
| `TRACE LINES ON` | trace line numbers |
| `TRACE LABELS ON` | trace labels; any line tracing already on stays on |
| `TRACE LABELS LINES ON` | both, in any order |
| `TRACE PRINT`, `TRACE PRINT ON` | send tracing to the printer. This does not start tracing |
| `TRACE LINES PRINT ON` | line numbers, to the printer |
| `TRACE PRINT OFF` | back to the window; the other modes stay on |
| `TRACE LABELS ON >t.txt` | labels, to the file `t.txt`, replacing it |
| `TRACE >>t.txt` | send tracing to the end of `t.txt`. This does not start tracing |
| `TRACE LINES OFF`, `TRACE LABELS OFF` | stop that mode; the others stay on |
| `TRACE OFF` | stop **every** mode, printer or file included, and remember which were on; a file closes |
| `TRACE ON` or a bare `TRACE` | resume what the last `TRACE OFF` stopped; with nothing remembered, trace lines |

`ON` is optional, `OFF` comes last, and a file comes after `ON`. A form that names modes turns on or off **only those**
modes. **`TRACE OFF` remembers the modes**: a later `TRACE ON` resumes whichever were on when it
ran, so a region can be bracketed with `TRACE OFF` … `TRACE ON` without naming them again. A
`TRACE OFF` with nothing on leaves the remembered modes as they are, and `RUN` forgets them.

`TRACE` is the statement form of the `RUN`/`GO` command options — the same run flags — so
`TRACE ON` and a console `GO TRACE` do the same thing, and `TRACE OFF` matches `NOTRACE` and
`GO TRACE OFF`. The console names the modes after `TRACE`: `RUN TRACE LABELS PRINT`,
`GO TRACE PRINT OFF`. See
[70-commands/information](../../../70-commands/information/spec.md) for the command side. The value
of the statement is that it can bracket **one suspect region** of a long program instead of tracing
the whole run:

```business-rules
02000 TRACE ON
02010 GOSUB POST_LEDGER
02020 TRACE OFF
```

Two things to know before relying on it:

- **`TRACE PRINT` does not start tracing.** It only selects the printer; write `TRACE ON` (or name
  `LINES` or `LABELS`) as well, as in `TRACE LINES PRINT ON`. On the console, the word `TRACE` is
  what starts tracing, so `RUN TRACE PRINT` traces line numbers to the printer. Every console
  trace option follows `TRACE`: a `PRINT` before it does nothing (`RUN PRINT TRACE` traces to the
  window).
- **A bare `TRACE` means `TRACE ON` from BR 5.03.** Before that the grammar accepted it, but the
  compiler emitted no operand and the runtime read the byte that followed the statement instead, so
  its effect was undefined. Write `TRACE ON` where a program must also run on an older BR, and do not
  use `LINES`, `LABELS`, `PRINT OFF` or a file there: an older BR does not know them, cannot compile them from source,
  and misreads them in a saved program.

<a id="examples"></a>
## Examples

```business-rules
! FOR with STEP, early EXIT
00300 FOR DELAY = 1 TO 10
00310   SLEEP(1)
00320   IF EXISTS("file.dat") THEN GOTO 340
00330 NEXT DELAY
00340 !

! DO with test at bottom (runs at least once)
00100 DO
00110   INPUT "Enter password: ": PASSWORD$
00120 LOOP UNTIL PASSWORD$ = "SECRET"

! File loop with EOF branch and EXIT DO
00200 DO
00210   READ #1: DATA$ EOF DONE
00220   IF DATA$ = "STOP" THEN EXIT DO
00230   ! process...
00240 LOOP
00250 DONE: CLOSE #1

! Multi-way dispatch
00130 ON CHOICE GOSUB ELEC, NATGAS, PHONE, CABLE
00200 ON DAY GOTO 500,1000,1500,2000,2500 NONE 100

! Subroutine
00250 GOSUB SALESTAX
10000 SALESTAX: LET TAX = PRICE * 0.06 : RETURN
```

<a id="see-also"></a>
## See also

- [conditionals](../../data-manipulation/conditionals/spec.md) — `IF` (the decision construct)
- [expressions](../../data-manipulation/expressions/spec.md) — loop/branch conditions
- [syntax](../../syntax/spec.md#line-labels) — `<line-ref>` line numbers & labels
- [functions-udf](../functions-udf/spec.md) — `DEF`/`FN` (the function alternative to `GOSUB`)
- (Backing keyword pages folded into this spec and pruned. The 2b
  redirect-collision pages `GoSub`, `On_GoSub` and `Randomize` were folded here and pruned; verbatim
  wikitext remains on the BR wiki. [CHAIN](CHAIN.md) — 11 technical notes on the CHAIN statement —
  was relocated here from 70-commands/program-management, which had misfiled it as a command; see
  that page's `corrections:` note.)
