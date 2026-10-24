---
title: Error handling
file: spec.md
source: §Error Handling
category: 10-language
subcategory: 10-language/flow-control/error-handling
kind: spec
status: 2b           # synthesized from the reference; new leaf
recovered-fold: ATTN_Mode, CONV, EOF, NOREC, Operating_Mode, Operating_System_Error, PAUSE_mode, RETRY (8 redirect-collision pages folded from re-fetched source — full operating-mode table, OS-error 4300/4320+SysErr, ON-eligibility, RETRY caveats; verbatim retained on the BR wiki)
corrections:
  - "GROW added to the frontmatter keywords, with the ON SOFLOW GROW section (BR 5.0: BR50 Release_Notes.md 1.21). GROW is a new word after ON SOFLOW, in BR's statement table, with no syntax tree of its own in syn.txt: brls accepts `ON SOFLOW GROW` and refuses a line number after it, as BR does."
  - "The error-condition roster was one list of 13 and is two rosters of 17 and 13. `<error-condition>` is used as a nonterminal in all four levels of the trapping BNF and was never given a production; §conditions named 13 words informally and said only that \"not every condition works with ON\". BR keeps the two sets in different places, and neither matches that list. A statement or EXIT clause is whatever `getExit` accepts — a table4k clause keyword whose token value appears in BR's `synexits` table, which is 17 words; `ON` takes its conditions from `ON`'s own syntax tree in `syn.txt`, which is 13, two of them taking an operand. Missing from the old list as statement clauses: ERROR, EVENT, LOCKED, TIMEOUT. Missing as ON conditions: ATTN, ERROR, EVENT, FKEY, FNKEY, LOCKED. Also added: that the clauses repeat with a space and not a comma, and the LOCKED-before-IOERR-before-ERROR ordering rule. LOCKED, TIMEOUT and the ordering rule were already in the tree, in `90-reference/error-codes/Locked_Error_Cond.md`, `IOERR.md` and the file-I/O and screen specs — they had simply never been folded into the roster, and three backing pages (`Error-Cond_Line-Ref.md`, `EXIT.md`, `EXIT_Error_Cond.md`) point at an `Error Conditions` page this tree does not have, which is where a complete roster would have lived. EVENT is listed as compiling and never firing - nothing in BR raises the condition, so the branch is unreachable in both rosters; it is a forward look left in the tables, the same shape as SELECT and CASE. Stated by the maintainer, and consistent with the reference corpus, which traps it 0 times. brls reports it as `non-functional-form`. Sources are level 1: BR's `synexits`/`table4v`/`table4k` (carried verbatim in `lsp/brls/brsz/`) and `lsp/syn.txt`. Found in brls phase 7, when `ON POS(…) GOTO A,B,C NONE Done` and a second exit clause on one statement were both rejected by a parser whose roster had been transcribed from the file-I/O spec's BNF; see lsp/brls/LSP_PLAN.md finding 33. HELP was deliberately left out of the frontmatter keywords for the reason DROP/FREE/INPUT were — it also names a command — and that exclusion was reversed in brls phase 13; see the entry below."
  - "RETRY and CONTINUE had no syntax line. The spec described both at length in prose and its BNF block covered only the four levels of trapping, so the two recovery statements — which the page's own frontmatter declares as keywords — were documented without a form. `dev/statement-semantics.md`'s retry-continue topic did carry the BNF, which is backwards: the distilled layer held a syntax line the curated reference did not. Added under §recovery, with the fact that both are primary operations taking no operand. That last point is not cosmetic: `syn.txt` gives CONTINUE a two-branch tree taking DO or FOR, and neither form exists — BR compiles them and does nothing, which brls now reports as `non-functional-form`. Stated by the maintainer; see lsp/brls/LSP_PLAN.md finding 32. Added in brls phase 5."
  - "`ON FKEY <n>`/`ON FNKEY <n>` documented as branching to exactly one target with no note that
    `FKEY`/`FNKEY` are ambiguous with the general `ON <numeric-expr> GOTO/GOSUB <line-ref>[,…]*`
    form, both being plain zero/one-argument functions as well as ON conditions. `ON`'s own tree
    (`syn.txt`, ported to brls's `internal/langdata/syntax.json`) gives the condition form's tail
    exactly one line reference and no repeat, matching this page's existing BNF — so real application code
    reading `ON FKEY-89 GOTO Cprev_Pgq,Cnext_Pgq` (branch on which of two keys was pressed) can only
    parse under the general form, using FKEY's own value as the selector, never under the condition
    form. Found fixing brls's parser: it matched the bare word `FKEY` as the condition keyword on
    sight and, per BR's own 'no retreat once a keyword matches' rule, could never back out to try the
    general form, so it accepted only the first target and reported the rest of the line as trailing
    garbage. Level 1 is the syntax tree itself; the disambiguating rule (a comma-joined second target,
    or an operator/no operand at all where `<n>` belongs, can only be the general form) follows from
    it and from functions.json's existing FKEY/FNKEY entries, not from a new source."
  - "HELP added to the frontmatter keywords, reversing the exclusion recorded above. The reason for it was sound when it was written and stopped being so: a name-only router hands a spelling's every sense the same specs, so declaring HELP here would once have told the *command* sense that the error-handling roster documents it. brls has since grown a disambiguation table (cmd/gendata, `ambiguities`) that narrows a sense to named routes, which is how DROP, FREE and INPUT are handled, and HELP now has a row naming the three specs that document the clause — this one for the error condition, 20-io-screen/input-output for `INPUT/RINPUT FIELDS … HELP <line-ref>`, and 20-io-screen/windows-cursor, which documents the field-help clause *and* the console HELP command. So both senses now reach pages about themselves, where the exclusion left both reaching nothing: HELP was the one member of this page's own 17-word roster that routed to no spec at all, and langdata.TestEveryExitClauseIsDocumented carried an unexplained `continue` for it. That skip is gone. IGNORE added at the same time — it is in this page's BNF at all four trapping levels as an action rather than a branch target, and was declared nowhere. Found in brls phase 13."
related: [other-flow, conditionals]
keywords: [GROW, ON ERROR, ERROR, IOERR, RETRY, CONTINUE, EXIT, ERR, LINE, SOFLOW, ZDIV, ATTN, CONV, DUPREC, EOF, EVENT, FKEY, FNKEY, HELP, LOCKED, NOKEY, NONE, NOREC, OFLOW, PAGEOFLOW, TIMEOUT, IGNORE]
---

# Error handling

Trapping and recovering from runtime errors without halting. The numeric error **codes**
themselves are the lookup table in
[90-reference/error-codes](../../../90-reference/error-codes/_index.md); this spec is the
**mechanism**.

<a id="system-variables"></a>
## System variables (set on error)

| Variable | Meaning |
|---|---|
| `ERR` | most recent 4-digit error code |
| `LINE` | line number where the error occurred |
| `CNT` | I/O items successfully processed (I/O errors only; `CNT+1` = first failed field) |
| `FILENUM` | file number of the failing I/O (use with `FILE$(n)`) |

**Always save `CNT` first** in a handler — any I/O (including `PRINT`) resets it.

<a id="levels"></a>
## Four levels of trapping (processed in order)

```bnf
-- 1. Statement-level conditions (on the statement itself)
<statement> [ <error-condition> <line-ref> ]*
-- 2. EXIT groups (named, reusable condition sets)
EXIT <error-condition> <line-ref> [',' <error-condition> <line-ref>]*
... <statement> EXIT <line-ref>
-- 3. ON <condition> (program-wide, per condition)
ON <error-condition> { GOTO <line-ref> | GOSUB <line-ref> | IGNORE | SYSTEM }
-- 4. ON ERROR (catch-all for anything untrapped)
ON ERROR { GOTO <line-ref> | GOSUB <line-ref> | IGNORE | SYSTEM }
```

<a id="conditions"></a>
## Error conditions

`<error-condition>` above stands for **two rosters, not one**, and BR keeps them in two different
places. A name in one is not necessarily in the other.

### On a statement, or in an `EXIT` group — 17

```bnf
<statement> [ <error-condition> <line-ref> ]*      -- space-separated, not comma-separated
```

`CONV` `DUPREC` `EOF` `ERROR` `EVENT`† `EXIT` `HELP` `IOERR` `LOCKED` `NOKEY` `NONE` `NOREC`
`OFLOW` `PAGEOFLOW` `SOFLOW` `TIMEOUT` `ZDIV`

† **`EVENT` compiles and can never fire** — nothing in BR raises the condition. It is admissible
everywhere the others are and traps nothing, in either roster.

The clauses **repeat with no delimiter between them** — `… NOKEY 910 EOF 900` is two clauses, not
one clause and a syntax error. A `line-ref` may also be `IGNORE` or `SYSTEM`, which are actions
rather than branch targets (`… ERROR IGNORE`).

**Order matters when several are listed**, because each of these traps a superset of the one before:
list `LOCKED` before `IOERR` before `ERROR`, or the broader one takes the error first. At the `ON`
level BR instead picks the most specific action for the error that occurred —
[`Locked_Error_Cond.md`](../../../90-reference/error-codes/Locked_Error_Cond.md),
[`IOERR.md`](../../../90-reference/error-codes/IOERR.md).

### With `ON` — 13

```bnf
ON <on-condition> { GOTO <line-ref> | GOSUB <line-ref> | IGNORE | SYSTEM }
```

`ATTN` `CONV` `ERROR` `EVENT`† `FKEY <n>` `FNKEY <n>` `HELP` `IOERR` `LOCKED` `OFLOW` `PAGEOFLOW`
`SOFLOW` `ZDIV`

`FKEY` and `FNKEY` are the two that take an operand. `ON FNKEY` is the pre-4.20 spelling and needs
[`OPTION 58`](../../../00-configuration/platform/Backward_Compatibility.md); as of 4.20 the name is
just `FKEY` ([20-io-screen/windows-cursor](../../../20-io-screen/windows-cursor/spec.md)).

### Which roster a name is in

| Statement / `EXIT` only | Both | `ON` only |
|---|---|---|
| `DUPREC` `EOF` `EXIT` `NOKEY` `NONE` `NOREC` `TIMEOUT` | `CONV` `ERROR` `EVENT` `HELP` `IOERR` `LOCKED` `OFLOW` `PAGEOFLOW` `SOFLOW` `ZDIV` | `ATTN` `FKEY <n>` `FNKEY <n>` |

**This is the table behind "not every condition works with `ON`".** `CONV` is in the middle column,
`EOF` and `NOREC` in the left with five others, and `ATTN` on the right — so `EXIT ATTN 900` is not
a form: `ATTN` is a clause keyword BR declares, but its token value is not among the exits, so the
lookup that reads an exit clause never matches it.

**A statement and an `EXIT` group share one roster** because they share one code path. `EXIT` is not
table-driven — its syntax tree covers only `EXIT FOR` and `EXIT SELECT`, and the error-condition form
goes to a hand-written routine. That routine, having ruled out `EXIT DO`, marks the line
non-executable and *resumes normal compilation*, so the condition list that follows is read by the
same matcher that reads the clauses on a `READ`.

### What each one traps

| Condition | Traps |
|---|---|
| `ATTN` | the Ctrl-A interrupt (see [§modes](#modes)) |
| `CONV` | conversion/type — four cases, below |
| `DUPREC` | `WRITE` over an existing record |
| `EOF` | no more records / no space — three cases, below |
| `ERROR` | the broadest trap: everything `IOERR` traps and more |
| `EVENT` | **nothing — it never fires.** BR accepts the clause in both rosters and no part of the runtime raises the condition, so the branch is unreachable. A forward look left in the tables, like `SELECT` and `CASE` |
| `EXIT` | references an `EXIT` group |
| `FKEY <n>` / `FNKEY <n>` | function key `<n>` during RUN (F1–F10 default `IGNORE`; during `INPUT`, keys set `CMDKEY` instead) |
| `HELP` | the Help key |
| `IOERR` | any untrapped I/O error; everything `LOCKED` traps and more |
| `LOCKED` | the record is locked at another workstation (**0061**) or file-sharing rules are violated (**4148**) |
| `NOKEY` | key absent |
| `NONE` | no match on a computed `ON … GOTO/GOSUB` |
| `NOREC` | record deleted / out of range — three cases, below |
| `OFLOW` | numeric overflow |
| `PAGEOFLOW` | page length reached |
| `SOFLOW` | string overflow (`ON … IGNORE` truncates instead) |
| `TIMEOUT` | a `WAIT=<sec>` expired with no input (**4145**) |
| `ZDIV` | divide by zero |

These are the same condition words used on I/O statements
([30-io-file/statements](../../../30-io-file/statements/spec.md#io)) and screen
([20-io-screen/input-output](../../../20-io-screen/input-output/spec.md)).

Specifics worth knowing:
- **`CONV`** traps four conversions: non-numeric characters in a numeric field (or vice versa); a number
  too big for the field; an I/O-list item whose type disagrees with its `FORM` spec; or a negative value
  output through a `PIC` that specifies no sign.
- **`EOF`** (error **4270** for files / **57** for data) traps three: no more records on input
  (`READ`/`INPUT`/`LINPUT`), no file space on output (`PRINT`/`WRITE`), or no more `DATA` on a `READ`.
- **`NOREC`** (error **57**) traps three, only under `RELATIVE` access with a `REC=` clause: the record
  was deleted, the number is ≥2 past the last record (`WRITE`), or past the last record (`READ`).

<a id="soflow-grow"></a>
## ON SOFLOW GROW (BR 5.0)

A string that would overflow can be made longer instead of failing. It is off unless asked for, so no
existing program changes.

```bnf
ON SOFLOW GROW
```

`GROW` is one of the `ON SOFLOW` modes, beside `IGNORE`, `SYSTEM` and `GOTO`, and the last one set wins, so
any other `ON SOFLOW` turns GROW off. There is no `NOGROW`. `ON SOFLOW GROW` takes **no line number**.
Variables named `GROW` or `NOGROW` keep working.

The configuration statement `SOFLOW-GROW [ MAX=n ] [ ON | OFF ]` (in `brconfig.sys`, or given at run time
with `EXECUTE "CONFIG ..."`) sets the mode each `RUN` starts in. `ON` is the default when neither is
given, `MAX=n` also turns it on unless `OFF` is given, and no statement means off. `n` is the most bytes
one string variable or array element may grow to; without it the limit is that of a dictionary element,
256 MB. A restricted session may set it.

- **Where a string grows**: an assignment to a string variable (`A$ = expr`, `A$ := expr`); an assignment
  to an array element, which gives **every element** the longer length; `LINPUT` from a file into a
  string variable or element; `PRINTER_LIST` into an array. Elsewhere — a substring assignment, a
  by-value parameter, `LINPUT` from the keyboard, print formatting, input fields, functions that return
  text — a string that would overflow behaves as it always did.
- **By-reference parameters** grow the caller's own variable or array. A library function runs in its own
  mode, not the caller's.
- **An array in use will not widen**: if another element is on the stack, the assignment raises the
  overflow error and nothing changes.
- **The ceiling**: a string never grows past `MAX`; a value that would take it past is not stored and the
  statement raises the usual overflow error.
- **A line exit on the statement wins**: `LINPUT #3: A$ SOFLOW 800` branches and does not grow.
- **It lasts for the run**; the next `RUN` starts again from the length in the `DIM`.
- `STATUS CONFIG` shows `SOFLOW-GROW`, its `MAX` and whether the running program is in GROW mode;
  `STATUS DIMS LENGTHS` shows how long strings really got.

<a id="recovery"></a>
## Recovery & ON options

```bnf
RETRY                -- re-execute the statement that caused the error
CONTINUE             -- resume at the statement *after* the one that caused it
```

**Both are primary operations taking no operand.** There is no `CONTINUE DO`, no
`CONTINUE FOR`, and no secondary operation of any kind on either — `syn.txt`
carries a two-branch tree for `CONTINUE` that BR does not implement.

- **`RETRY`** re-executes the statement (clause) that caused the most recent error — analogous to
  `RETURN` at the end of a subroutine; **`CONTINUE`** instead resumes at the *next* statement (common
  with `PAGEOFLOW`). Caveats: with no outstanding error (or one suppressed by `ON … IGNORE`) `RETRY`
  itself errors; a **second error before `RETRY` loses the first return address** — so handlers often do
  `ON ERROR SYSTEM` on entry and reinstate their traps just before `RETRY` to avoid loops. The
  exception is a **`4273`** (help-topic-not-found) trapped by `NOKEY` (typically from `HELP$` inside a
  handler): it leaves `ERR`/`LINE` unset and keeps `RETRY`/`CONTINUE` aimed at the *original* error. If
  the retried statement is `INPUT FIELDS`/`RINPUT FIELDS`, the cursor auto-positions on the offending
  field. Typing `RETRY` at an interrupted program is the same as `GO`. (`RETRY=<n>` is also an unrelated
  `OPEN` *communications* parameter — send/receive attempts, default 5.)
- **ON options**: `GOTO` branch to a handler; `GOSUB` call a handler that `RETURN`s (which re-executes
  the error-producing statement, unless the interrupt followed an I/O operation); `IGNORE` skip silently
  (no `ERR`/`LINE` set; `SOFLOW` truncates instead); `SYSTEM` restore default beep-and-suspend behavior.
- **`ON FKEY <n> {GOTO|GOSUB|IGNORE|SYSTEM}`** traps function keys during RUN (F1–F10 default IGNORE;
  during INPUT, keys set `CMDKEY` instead). Like every `ON` condition this branches to exactly one
  target — but `FKEY`/`FNKEY` are also plain callable functions ([system-functions](../../data-manipulation/system-functions/spec.md)), so `ON FKEY-89 GOTO A,B` and `ON FKEY GOTO A,B` are not
  this form at all: with no operand, or an operator instead of one, `FKEY` is the bare function call
  and the whole line is [other-flow](../other-flow/spec.md#on-goto)'s general
  `ON <numeric-expr> GOTO <line-ref>[,<line-ref>]*`, using FKEY's return value as the selector — only
  `ON FKEY <n> …` and `ON FKEY(<n>) …`, with nothing else before the verb, are the condition.

<a id="modes"></a>
## Execution modes
The **operating mode** shows in the status line (columns **1–7**); the most recent **error code** shows
in columns **38–41**, in reverse video until ENTER/an arrow key is pressed, then normal. The code
**persists until the next error** — `CLEAR` removes it but also wipes the program/memory, so it's rarely
worth it. The modes BR reports:

| Mode | Meaning / how to resume |
|---|---|
| **READY** | waiting for commands or program lines |
| **RUN** | program executing (`RUN` command or `CHAIN`) — no action |
| **INPUT** | awaiting `INPUT`/`LINPUT`/`RINPUT`/`INPUT FIELDS` entry |
| **SELECT** | awaiting an `INPUT SELECT`/`RINPUT SELECT` menu choice |
| **ERROR** | runtime/syntax error — `GO` resumes, `STOP`/`END`/`CLEAR` end; `LIST`/`PRINT` allowed for debugging; SAVE/RUN/REPLACE/SYSTEM blocked |
| **ATTN** | Ctrl-A interrupt — line# field shows the next line; `LIST`/`PRINT`/line-editing/`STEP`/`TRACE` and changing variable values are all allowed; `GO` resumes |
| **PAUSE** | hit a `PAUSE` statement — inspect state, then `GO` resumes |
| **HOLD** | Esc pressed — no keyboard input accepted; press Esc again to resume |
| **STEP** | single-stepping — ENTER executes each line; line# field shows the next line |
| **INSERT** | Ins-key character-insert editing (else typing overwrites); Ins/ENTER exits |
| **HELP** | help facility active (HELP/F1 key or the `HELP$` function) |
| **PROC** | a procedure file is executing (`GO` resumes if interrupted) |
| **CHAIN / LOAD / SAVE / REPLACE / PR-EDIT** | transient program-management states — no action required |
| **SYSERR** | a system error occurred; the code appears in the error field |

<a id="os-errors"></a>
## Operating-system errors
OS errors vary by platform. **Before 4.16** BR reported them as `4200 + <OS error number>` (the 4200
series), which could exceed 4299 and collide with Unix/Linux codes. **4.16+** instead raises **`4300`**
and **`4320`** and exposes the OS detail through the **`SysErr`** (number) and **`SysErr$`** (text)
variables — always read those for the actual cause. (E.g. OS 72 = print/disk redirection paused;
267 = invalid directory name. See MSDN "System Error Codes" for the Windows list.)

<a id="examples"></a>
## Examples

```business-rules
00001 ON ERROR GOTO GENERAL_ERROR     ! catch-all
00002 ON ZDIV IGNORE                   ! skip divide-by-zero
00003 ON IOERR GOTO 90000
00020 INPUT MI CONV 80                 ! statement-level condition
00050 EXIT CONV CONV_HANDLER, SOFLOW OVERFLOW   ! reusable group
00080 CONV_HANDLER: PRINT "Enter numbers" : RETRY

99000 GENERAL_ERROR: LET SAVECNT=CNT   ! save CNT before any I/O
99030   PRINT "Error";ERR;"at line";LINE
99060   IF FILENUM>0 THEN PRINT "File #";FILENUM;"--";FILE$(FILENUM)
99120   STOP
```

<a id="see-also"></a>
## See also

- [other-flow](../other-flow/spec.md) — `ON … GOTO`/`GOSUB`, `GOTO`, loop flow
- [conditionals](../../data-manipulation/conditionals/spec.md) — `IF` in handlers
- [90-reference/error-codes](../../../90-reference/error-codes/_index.md) — the numeric code lookup table
- [system-functions](../../data-manipulation/system-functions/spec.md#system-info) — `ERR`/`LINE`/`BRERR$`/`FILE$`
- [30-io-file/statements](../../../30-io-file/statements/spec.md#io) — I/O error conditions in context

*(8 redirect-collision pages re-fetched in 2b — `ATTN_Mode`, `CONV`, `EOF`, `NOREC`, `Operating_Mode`,
`Operating_System_Error`, `PAUSE_mode`, `Retry` — were folded into this spec and pruned; verbatim
wikitext remains on the BR wiki.)*
