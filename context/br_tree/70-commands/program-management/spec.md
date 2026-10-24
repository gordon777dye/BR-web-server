---
title: Program management & procedures
file: spec.md
source: §Commands (System Entry/Exit, System Commands), §Procedures
category: 70-commands
subcategory: 70-commands/program-management
kind: spec
status: 2b           # reference base + br_tree fold (LOAD modes, CHAIN passing, CLEAR variants, GO form, MERGE, express procs); CHAIN/Procedure_files retained; no conflicts
recovered-fold: REPLACE (folded+pruned — source-vs-object/.BRS/.BRO rules, .BAK + OPTION 26, default-extension; verbatim retained on the BR wiki)
related: [file-directory, information, editing]
keywords: [AI, RUN, LOAD, SAVE, REPLACE, MERGE, CLEAR, GO, EXECUTE, CHAIN, PROC, SYSTEM, LOGOFF, ALL, SUBPROC, PROCERR, ALERT, FILES, ECHO, NOECHO, SOURCE, OBJECT, ONLY, NOSTEP, NOTRACE]
corrections:
  - "AI added to the frontmatter keywords, with the AI section (BR 5.0: BR50 Release_Notes.md 2.19, 2.13). The command had no page in this tree."
  - "Added the command-help section: `-?` as the whole of a command's arguments lists what the command takes (BR 5.0, wbosCommandHelp() in wbos.cpp, called from cmdproc() in commandc.cpp). In the same pass, from the BR 5.0 parsers (see br50 br/docs/FLAGS.md): SKIP's label is written without its colon - the BNF said `SKIP n|:label`, which never matches, while this page's own example used `SKIP BUSY` - and a label search wraps to the top of the procedure (command0.cpp SKIP_CMD); PROCERR REM documented (command0.cpp PROCERR, command.cpp proc_comment); SYSTEM -W and +n are accepted and ignored, -W setting SHC_WINDOWS only under BR_V4, and SYSTEM ONQ is no longer special (command7.cpp SYSTEM_CMD); CLEAR name clears a resident program without RESIDENT, and CLEAR ... STATUS demotes only while a program is halted (command7.cpp CLEAR). From source reading, not yet confirmed by a run. 2026-10-21."
  - "SAVE / REPLACE now states which object format is written: level 39 in BR 5.0, level 38 in 4.2/4.3, an older BR refusing level 39 with error 2240, and OPTION 60 selecting level 38. The page described source-versus-object and said nothing about the format level, which an upgrade has to know. From BR 5.0 source: brexe.cpp (SAVE_LEVEL, processNewSaveFile, loadExeFile's level test), config.cpp case 60. Confirmed on brserver 5.0 x64 Debug: a default SAVE wrote level 39 and BR 4.33c refused it with 2240; with OPTION 60 it wrote level 38 and 4.33c loaded it."
  - "SYSTEM LOGOFF was one line (`log the BR client off`). Now documents `SYSTEM LOGOFF [ALL]` in the system-logoff subsection: it is an exit form (exit code 0, error 2108 if keyed while a program is active), what the client clears at exit, and that ALL widens only the session-table clear from this session's slot to all nine. Also the parse rules: ALL is a whole word, and nothing else after LOGOFF is read. LOGOFF and ALL added to keywords. From BR source in context/lsp/brls/brs: command7.cpp SYSTEM_CMD (the LOGOFF/ALL parse and the CLIENT_LOGOFF_ASYNC call), remoteargs.cpp (sets g_logoffAtExit and g_logoffAllSessions), brterm.cpp (runs logoffClient at client exit), term.cpp logoffClient, session.cpp clearSessionID/clearSessionIDs, brlistener.cpp logoffSession. Confirmed on brserver 5.0 x64 Debug over a live client/server link: with eight slots occupied, plain SYSTEM LOGOFF cleared only this session's slot and left the other seven; SYSTEM LOGOFF ALL zeroed all nine; SYSTEM LOGOFF ALLOCATE behaved as plain SYSTEM LOGOFF. All three forms cleared AutoLogin, Remember me, the saved Windows credential and the ClientServer persistent-login id for the listener port."
  - "RUN syntax now shows the program name and the PROC option: `RUN [<program>] [PROC] [STEP|TRACE]`. Added a run-proc subsection giving the literal forms (`RUN <program> PROC`, or `LOAD <program>` then `RUN PROC`) and saying they work only inside a procedure. The page had described RUN PROC's effect and never its syntax. From BR 5.0 source: command9.cpp PROC_TYPE sets RUN_PROCIN and raises BREPROCPARAMETER (2103) when no proc is active. commandc.cpp RUN reads a first word that is an option (PROC among them) as that option, not a file name. Confirmed on brserver 4.33c with a probe: both forms gave PROCIN=1 and fed the LINPUT; plain RUN gave PROCIN=0; the startup argument `RUN <prog> PROC` gave 2103. Reported in context/lsp/ERRORS.md 2026-09-09."
  - "Eleven keywords added to the frontmatter: the CHAIN clause FILES, the commands SUBPROC, PROCERR and ALERT, and the qualifiers ECHO, NOECHO, SOURCE, OBJECT, ONLY, NOSTEP and NOTRACE. Every one is documented in this page's BNF or semantics and none was declared, so BR's own spelling of each reached nothing. Found in brls phase 13."
  - "CHAIN's backing/deep-reference page carried `kind: command` and lived under this
    70-commands subtree, but CHAIN is a **statement** (line-numbered, runs at RUN; every
    other 70-commands backing page is `kind: command`, and CHAIN was the one outlier). Moved
    the backing page to 10-language/flow-control/other-flow/CHAIN.md, alongside the other
    program-termination statements, and corrected its `kind:`. The CHAIN coverage on this
    page (BNF, semantics, examples) is unaffected and remains the authoritative summary —
    only the deep-reference link and the file's physical location changed."
  - "The CHAIN BNF ordered `FILES` ahead of the `MAT <array>`/`<var>` list, as
    `[, FILES] [, MAT <array>]… [, <var>]…`. BR does not enforce that position:
    `00010 chain A$, XXX, FILES` LOADs clean, confirmed directly. Rewritten as one
    repeating alternation, `[, { FILES | MAT <array> | <var> }]…`, so the clause may
    stand at any of the comma-separated positions. BR's own syntax table orders the
    units the same way the old BNF did, which is why the error stayed invisible: past
    the FILES unit, the repeating operand read the word as an ordinary variable *named*
    FILES, so a misplaced FILES was accepted for the wrong reason and anything reading
    the parse got a variable that does not exist. Whether BR accepts `FILES` more than
    once in one CHAIN was not tested, so the alternation neither permits nor forbids it
    deliberately. Found and fixed in brls (internal/parse/walk.go, matchUnit)."
---

# Program management & procedures

Loading, saving, running, and chaining programs, plus **procedure files** (command scripts).
Commands run immediately (no line number) and — crucially — from program code via
[`EXECUTE`](#execute). Line-editing commands are in [editing](../editing/spec.md); file/dir
commands in [file-directory](../file-directory/spec.md).

<a id="command-vs-statement"></a>
## Command vs statement

A **command** executes immediately when typed (no line number) and manages the environment
(`LOAD`, `SAVE`, `RUN`, `LIST`, `DIR`). A **statement** has a line number and runs at `RUN`.
Any statement can be run immediately as a command; a bare expression is an implied `PRINT`
(`6+4`→`10`). Commands can't appear in a program **except** via `EXECUTE` or inside a `PROC`.

<a id="command-help"></a>
## `-?` — what a command takes (BR 5.0)

Any command given `-?` as the **whole** of its arguments lists the forms and options it accepts and
does nothing else: `COPY -?`, `LIST -?`, `STATUS -?`. Nothing runs, so `RUN -?` loads nothing and
`SYSTEM -?` does not leave BR. `-?` alongside other arguments is not the help: `COPY a.txt -?` is a
`COPY` with an unknown option, a syntax error, and a `LIST` search string containing `-?` is a
search. A long list pauses after each screenful (any key goes on, Ctrl-A stops). `DIR -?` lists the
options of the listing in use — the 5.0 ones, or the 4.x ones under `OPTION 8`. Every command in
BR's command table has it except `HELP` (and the internal `LINK`). The lists are written from each
command's parser, so where this tree and `-?` differ, `-?` is the one that matches the code.

<a id="entry-exit"></a>
## Entry & exit
```bnf
BR [<instructions>] [-<id>] [-<config>] [-<ref>]   -- start BR (optionally run a command / set WSID / config)
SYSTEM | SY                                         -- exit BR to the OS (closes files)
SYSTEM <integer>                                    -- exit to the OS, returning <integer> as the process exit code
SYSTEM LOGOFF [ALL]                                  -- exit BR and log the client off (ALL: every session slot)
SYSTEM [<flags>] "<os-command>"                      -- run an OS shell command, then return to BR
```

<a id="system"></a>
### SYSTEM — exit BR / call the OS shell
`SYSTEM` is a **command** (not a primary-op statement); a program reaches it via
[`EXECUTE`](#execute) or a `PROC`. Three forms:

- **Exit** — bare `SYSTEM` (`SY`) closes files and returns to the OS; `SYSTEM <n>` returns `<n>` as the
  process **exit code** (readable by a calling shell/script). `SYSTEM LOGOFF [ALL]` exits and also
  logs the client off — see [logoff](#system-logoff).
- **Shell call** — `SYSTEM "<os-command>"` runs an operating-system command (launch another program,
  run a script), then returns to BR — **the program's main way to invoke other applications through the
  OS.** This is consequential for app development and for security review (it executes arbitrary OS
  commands with the caller's privileges).

**Shell-call flags** precede the command string and are **case-sensitive** (an unknown flag → error
**4501**; conflicting flags → *flag-conflict* error):

| Flag | Effect |
|---|---|
| `-@` | run the command on the BR **client** side |
| `-S` / `-s` | run on the BR **server** side (default follows the `SHELL DEFAULT CLIENT`/`SERVER` config) |
| `-R` / `-r` (or leading `*`) | **restore** the BR screen after the call |
| `-C` / `-c` | **continue asynchronously** — don't wait for the command to finish (conflicts with `-R`) |
| `-M` / `-m` | **hide** / **minimize** the launched program's window |
| `-H` / `-h` | **hide** / **minimize** BR's own window during the call |
| `-W` / `-w` | accepted and **ignored** in BR 5.0 (it marked a Windows program in 4.x, and no longer conflicts with `-R`) |
| `-E` / `-e` | permit a shell-call **error** to be reported/trapped |
| `-P` / `-p` | page |
| `-T`/`-t<secs>` | override the shell-call **timeout** |
| `+<n>` | accepted and **ignored** (it once requested `<n>` of memory for the child) |

(`SYSTEM ONQ …` is an ordinary shell command in BR 5.0: the built-in ONQ interface was removed.)

<a id="system-logoff"></a>
#### SYSTEM LOGOFF / SYSTEM LOGOFF ALL

`SYSTEM LOGOFF` is an **exit** form: it ends BR exactly as bare `SYSTEM` does (files closed, exit
code **0**). It is subject to the same rule as the other exit forms: keyed at the console while a
program is active, it fails with error **2108** ("program is active"). Before exiting, it flags the
client to log off. The logoff then runs when the client shuts down, and it removes what a logon
leaves on the workstation:

| Cleared | Scope |
|---|---|
| The persistent-login session id (registry `ClientServer\sessionId_<listener port>`) | machine |
| The login dialog's **AutoLogin** and **Remember me** settings | machine |
| The saved Windows credentials | machine |
| The session table entry — WSID, window handle, window class name, process time | **this session's slot only** (`SYSTEM LOGOFF`) or **all nine slots** (`SYSTEM LOGOFF ALL`) |

In client-server mode the client also tells the listener to drop this session's multisession
login, so the next connection must log on again.

The machine-wide items are cleared by both forms. **`ALL` only changes the session table.**
- Plain `SYSTEM LOGOFF` frees only this session's slot and leaves the other eight as they were.
- `SYSTEM LOGOFF ALL` zeroes every slot. That includes the WSIDs of sessions that are still
  running, which is why it is not the default. It is the recovery for a slot left unusable — for
  example when Windows reports another session's window as still live, so that session's WSID is
  never freed and WSIDs get assigned wrongly.

Parsing:
- `LOGOFF` and `ALL` are case-insensitive. `ALL` must be spelled in full and be a whole word
  (followed by a space, a tab or the end of the line). `SYSTEM LOGOFF ALLOCATE` is therefore plain
  `SYSTEM LOGOFF`.
- Nothing else after `LOGOFF` is read. A number there is **not** an exit code: `SYSTEM LOGOFF 5`
  still exits with 0.

<a id="program-commands"></a>
## Program lifecycle commands
| Command (abbrev) | Action |
|---|---|
| `LOAD f [SOURCE\|OBJECT]` (LO) | clear memory, load `f`; see [loading](#loading) for modes & extensions |
| `SAVE f [SOURCE]` (SA) | save to a **new** file (error 4150 if exists) |
| `REPLACE [f]` (REP) | overwrite an existing file (keeps a `.bak`) |
| `RUN [<program>] [PROC] [STEP\|TRACE]` (RU) | execute from the lowest line (resets vars); with `<program>`, load it first. `PROC` takes input from the running procedure (see [run-proc](#run-proc)); STEP/TRACE → [information](../information/spec.md) |
| `MERGE f [-<from>] [-<to>] [<first>\|ADD]` (ME) | merge program lines from a file (see [merge](#merge)) |
| `CLEAR [PROC\|RESIDENT\|ALL]` (CL) | clear program/vars/procedures/libraries (see [clear](#clear)) |
| `GO [RUN][STEP][TRACE][.<line>]` | resume / step a halted program (see [go](#go)); `GO END` terminates it |
| `STOP` | halt execution (also a statement) |

<a id="loading"></a>
### Loading & the default extension
`LOAD` (`LO`) clears memory, then loads. **`SOURCE`** loads an ASCII `.brs` program line-by-line as
if typed (syntax-checked per line; on a syntax error BR halts for a fix — unless `PROCERR RETURN` is
active in a procedure, which instead returns the code in `ERR` and the failing line in `LINE` so a
`SKIP` can test it). **`OBJECT`** loads the `.bro` object; **`RESIDENT`** loads the file as a
resident library. **The mode is set by the keyword, not inferred from the extension:** `LOAD` defaults
to object, so loading a source program **requires an explicit `SOURCE`** — `LOAD "prog.brs" SOURCE`.
Naming the `.brs` file alone (`LOAD "prog.brs"`) does *not* trigger source mode; BR tries to read it
as an object file and fails. Extension search: a bare name tries `.BR` then `.BRO` (`.BRS` for
`SOURCE`), overridable via `CHAINDFLT` in
[BRConfig.sys](../../00-configuration/config-directives/spec.md); a **trailing period**
(`LOAD NAME.`) suppresses the search and loads the name as-is. A failed `LOAD` leaves memory intact.

<a id="merge"></a>
### MERGE
`MERGE f [-<from>] [-<to>] [{<first>|ADD}]` (syntax mirrors `RENUM`) pulls lines from another `.br`
into memory. With no `first`/`ADD`, merged lines keep their numbers and **replace** any existing
lines that share them. `ADD` appends all lines after the current program's last line; `<first>`
renumbers the first merged line (others follow the source increments). A single line number merges
only that line.

<a id="replace"></a>
### SAVE / REPLACE — source vs object
`SAVE` writes a **new** file (error 4150 if it exists); `REPLACE` overwrites an **existing** one and
leaves the lines in memory. Both save **source** only when the name ends `.BRS` or the **`SOURCE`**
keyword is given; otherwise they save **object** (`.BR`/`.BRO`). With no filename, `REPLACE` reuses the
file's full original name (a trailing period suppresses the default extension). **`OBJECT`** (`.BRO`)
omits source — *unrecoverable*, used to ship protected code. Before overwriting, BR copies the original
to **`.BAK`** (recoverable until the next `REPLACE`); **`OPTION 26`** suppresses `.BAK` creation. End
execution before `REPLACE`; to save without ending, `LIST >tmp` then `LOAD` it from source.

**Which object format is written.** BR 5.0 writes **save level 39**, which records for each
statement the source file line it came from. BR 4.2 and 4.3 wrote **level 38**, which has nowhere
to keep that. A BR older than 5.0 given a level 39 program **refuses it** with error **2240**
(*release level error*) rather than misreading it; BR 5.0 loads either level, and a level 38
program simply has no source line positions in it.

**`OPTION 60`** makes `SAVE` and `REPLACE` write level 38, so a program can be read by a 4.2 or
4.3 BR - at the cost of those positions. It also sets `OPTION 74`. The 4.18-and-earlier format
this option used to write is no longer written at all, though programs already in it still load.
**`OPTION 60` governs saving only**: BR 5.0 loads the pre-4.2 format, level 38 and level 39 alike,
set or not.

<a id="clear"></a>
### CLEAR
`CLEAR` (`CL`) with no argument clears the program for new entry. `ALL` ends the program, closes all
procedures and clears memory. `PROC` closes all procedures but **keeps** memory (variables remain
for debugging); `PROC ONLY` additionally keeps the program running. `RESIDENT` clears all resident
libraries (`"name"` clears one, and so does `CLEAR name` without `RESIDENT`); adding `STATUS`
instead *demotes* resident → present rather than unloading — but only while a program is halted;
otherwise `STATUS` is read as `RESIDENT`. `CHAIN` and `LOAD` perform an implicit `CLEAR`.

<a id="go"></a>
### GO — resume / step
`GO [RUN] [STEP|NOSTEP] [TRACE [PRINT]|NOTRACE] [.<line>]` resumes a halted/interrupted program with
all variables and open files intact. `RUN` first clears prior STEP/TRACE settings; `STEP` pauses
before each action statement, `TRACE` echoes line numbers (`PRINT` → printer). `GO <line>` resumes
*at* a line; **`GO .<line>`** runs *until* a line then issues a STEP interrupt (`GO .5280:2` stops
before line 5280 clause 2; a bare `GO .` reuses the last temp breakpoint; `GO` with no period clears
it). After an error, `GO` retries the failing statement. In STEP mode, Shift+F1–F5 step with
widening scope (into-clause / over-clause / into-line / over-line / to `RETURN`|`FNEND`).
**`GO END`** terminates the interrupted program and closes all files.

<a id="ai"></a>
## AI (BR 5.0)

```bnf
AI NEW
AI <text>
```

At the `READY` prompt, `AI` followed by what you want opens a conversation with an assistant attached to the
session's channel. The reply prints in the `HILITE` colour; the commands the assistant asks to have run are
marked `[AI] >`. `AI NEW` starts a fresh conversation. With no assistant listening the command stops at
once with error 4158.

- **A turn is the person's to open.** It needs an open turn, not the keyboard grant; anything destructive
  stops and asks. The assistant itself may not use `AI` (error 4171).
- **A running program or procedure must consent**: set `ENV$("AI_TURN_OK")` to `"Y"` first
  (`LET X=SETENV("AI_TURN_OK","Y")`), or `AI` is refused with error 4169. `AI NEW` needs no flag.
- A break key halts the wait at `READY` with the turn still open, and `GO` resumes it; `CLEAR PROC` and
  `CLEAR ALL` end a turn.
- `AI=5` still assigns to a variable called `AI`; only `AI` followed by a space is the command.

<a id="execute"></a>
## EXECUTE — run a command from code
```bnf
EXECUTE "[*]<command-string>"
```
Runs any command/statement string at runtime — the bridge that makes commands part of the
coding surface (build index files, run a SORT, start a PROC, …). A leading `*` suppresses screen
restoration (the default does **not** restore the screen). Inspect
[`CODE`](../../10-language/data-manipulation/system-functions/spec.md#system-info) afterward for a
procedure's return value. **Restrictions:** because it is illegal to *terminate* a program from
`EXECUTE`, the program-ending commands `LOAD`, `SAVE`, `REPLACE` and the `CHAIN` statement may not
be used inside it. This `LOAD` restriction applies to a `LOAD` that replaces the running program;
`LOAD ...,RESIDENT` (loading a resident library) does not terminate the current program and is
allowed. `INDEX`/`SORT` *can* be started from `EXECUTE` (no prior `CLEAR`, so less memory
— may run slowly; out-of-memory → error `7607`/`7811`). All errors (including command syntax
errors) are passed back, trappable with `ERROR`/`IOERR`/`Exit`; an `EXECUTE` may itself be the
subject of another `EXECUTE`.

<a id="chain"></a>
## CHAIN — end this program, start another
```bnf
CHAIN { "<program>" | "PROC=<name>" | "SUBPROC=<name>" } [, { FILES | MAT <array> | <var> }]…
```
`CHAIN` (a statement) ends the current program and loads/runs another program, or starts a
procedure. By default it **closes all files** (except procedure files) and resets the new program's
variables; **`FILES`** keeps files open at their current positions (pointers are *not* moved — use
`RESTORE` to reposition), and trailing `MAT array`/`var` names carry those values into the chained
program (dimensions needn't match; the caller's win). `FILES` may stand at any of those
comma-separated positions, not only the first — `chain A$, XXX, FILES` is accepted. The
program name follows the same default extension rules as `LOAD` (`.BR`→`.BRO`, `CHAINDFLT`).
`"PROC=…"` ends the program and starts a
procedure (closing the lowest active proc first); `"SUBPROC=…"` starts a **nested** procedure
without disturbing the running one — both keep the terminated program in memory so its variables
stay available to the procedure. `CHAIN "PROC=XYZ"` is like `EXECUTE "PROC XYZ"` except `CHAIN`
ends the program. (Deep reference, incl. the 11 technical notes:
[CHAIN](../../10-language/flow-control/other-flow/CHAIN.md) — filed alongside the other
program-termination statements since CHAIN is a statement, not a command.)

<a id="procedures"></a>
## Procedure files
A **procedure** is an ASCII (DISPLAY) text file of commands run in order — one command per line,
`!` comments, `:label` branch targets, no line numbers, up to 800 chars/line. A `.$$$` extension
makes it **self-deleting** after execution.

<a id="proc"></a>**Starting**: `PROC {name|*name|ECHO|NOECHO}` (runs it; `*` suppresses F2 logging;
NOECHO hides lines). `SUBPROC file` runs a **nested** procedure (up to 9 deep) then resumes.
From code: `CHAIN "PROC=…"` / `CHAIN "SUBPROC=…"` (ends program) or `EXECUTE "PROC …"` (keeps
program running). `RUN PROC` feeds procedure lines to a program's `INPUT`/`LINPUT`.

<a id="run-proc"></a>**`RUN … PROC`** — `PROC` is an **option of `RUN`**, not a command. It is not
followed by a file name: the lines fed to the program are the ones that follow the `RUN` line in
the procedure that is *already running*. Two forms work, both only as lines **inside a procedure**:

```
RUN <program> PROC           ! load <program>, then run it with proc-fed input
LOAD <program>               ! or: load first ...
RUN PROC                     ! ... then run what is in memory with proc-fed input
```

- **Outside a procedure** (typed at READY, or as the startup command-line argument)
  `RUN … PROC` fails with error [2103](../../90-reference/error-codes/2103.md), "illegal PROC
  parameter".
- **`RUN PROC <file>` does not name a proc file.** `RUN`'s first word is checked against its
  options before being read as a program name, so `PROC` is taken as the option and no program is
  loaded. `<file>` never becomes a program name. With nothing in memory, BR reports error 2104
  (no active lines).
- **A plain `RUN` inside a procedure does not feed it.** `PROCIN` stays 0 and the program reads
  the keyboard; under `UNATTENDED` logging it aborts at its first input statement.
- **How the lines are used.** Each input statement consumes the next proc line. When the program
  ends, the following proc lines are commands again. Confirmed on 4.33c.
- **The `RUN … PROC` line must not be the proc's last line.** See [look-ahead](#look-ahead).

**Flow & errors**: `SKIP n|label [IF <cond>]` branches — the label is written **without** its
colon (`SKIP BUSY` goes to the line `:BUSY`; `SKIP :BUSY` never matches), and a label search that
reaches the end of the procedure carries on from the top, so a skip may go backward;
`PROCERR STOP` (default) halts on error, `PROCERR RETURN` continues (sets `ERR`), and
`PROCERR REM`, with `RETURN`, keeps a program line that fails to load as a `REM`; `ALERT msg` pauses for the operator (`GO` resumes; under
`PROC NOECHO` the message shows but the operator must press F2/F3 to see the *command* — bracket
`ALERT` with `PROC ECHO`…`PROC NOECHO`); `CLEAR PROC` / `CLEAR ALL` close procedures.

<a id="look-ahead"></a>**Look-ahead close**: BR closes a procedure *before* executing its **last
line**, so that line behaves as an independent one-line command — it **cannot** be a `SKIP` that
branches backward or a `RUN PROC` (the file is already closed), and shouldn't be error-prone; add a
blank/comment line if you need the proc to stay open. This look-ahead is what lets a `.$$$` proc (or
one whose last line is `FREE`) delete itself, and avoids stacking an extra open file. Each active
procedure counts as one open file; nesting goes 9 deep (status-line columns 58–59 show `P1`…`P9`),
and `RUN PROC` feeds procedure lines to a program's `INPUT`/`LINPUT`/`RINPUT` — **one proc line per
input statement** (too many/few lines causes unpredictable misreads; `PROCIN` →
[information](../information/spec.md#procin-program) tells the program input is coming from a proc).

<a id="express"></a>**Express procedures** run *during* a program via `EXECUTE "PROC …"` /
`"SUBPROC …"` (or operator-keyed during an interruption): they imply `NOECHO`, are subordinate to
the running program, and resume it when done. An error in an executed express proc closes the proc
and returns to the `EXECUTE` statement's error trap. `EXECUTE "PROC XYZ"` cancels the
last-activated proc (and ends any `RUN PROC` input mode); `EXECUTE "SUBPROC XYZ"` preserves the
hierarchy (and keeps `RUN PROC` active). A program can shed one procedure layer by running an empty
express `PROC`. The full procedure-system reference (start methods, syntax rules, express-vs-standard
chart) is retained in [Procedure_files](Procedure_files.md).

<a id="examples"></a>
## Examples

```business-rules
04200 EXECUTE "PROC DAILY"            ! start a procedure, program keeps running
99000 EXECUTE "INDEX ACCT.INT ACCT.KEY 1 4 REPLACE"
00900 CHAIN "proc=MONTHEND"           ! end program, run procedure
```

A procedure that runs a program with its input supplied (`PROCIN` returns 1). Start it with
`PROC nightly.prc`. The program's first input statement reads `FIRST-ANSWER` and its second
`SECOND-ANSWER`. When the program ends, `SYSTEM` runs as an ordinary command:

```
RUN myprog PROC
FIRST-ANSWER
SECOND-ANSWER
SYSTEM
```
```text
! procedure: purge deleted records safely (multi-user)
PROCERR RETURN
PROTECT CUST.FIL,RESERVE
SKIP BUSY IF ERR<>0
COPY CUST.FIL TEMP[WSID].FIL -D
RENAME TEMP[WSID].FIL CUST.FIL
PROTECT CUST.FIL,RELEASE
SKIP DONE
:BUSY
ALERT File is busy, try again later -- type GO
:DONE
RUN MENU
```

<a id="see-also"></a>
## See also

- [editing](../editing/spec.md) — `AUTO`/`RENUM`/`DEL`/`LIST` line editing
- [file-directory](../file-directory/spec.md) — `COPY`/`RENAME`/`FREE`/`CHDIR` used in procedures
- [filename-patterns](../file-directory/filename-patterns.md#tab-completion) — Tab completes the file name of `LOAD`, `RUN`, `SAVE`, `REPLACE`, `MERGE`, `PROC` and `SUBPROC` at `READY`
- [information](../information/spec.md) — `RUN STEP/TRACE`, `DISPLAY`, `BREAK` debugging
- [50-libraries/library-facility](../../50-libraries/library-facility/spec.md) — `LIBRARY` (vs `CHAIN`)
- [information](../information/spec.md#break) — `BREAK` breakpoints (folded there)
- [other-flow](../../10-language/flow-control/other-flow/spec.md#termination) — `STOP`/`END`/`PAUSE`,
  `CHAIN`'s sibling program-termination statements
- Backing keyword pages retained (deep reference):
  [CHAIN](../../10-language/flow-control/other-flow/CHAIN.md) (11 technical notes; relocated there
  because CHAIN is a statement, not a command — see that page's `corrections:` note),
  [Procedure_files](Procedure_files.md) (the full procedure-system reference)

*(Backing pages `LOAD`, `MERGE`, `GO`, `Go_End`, `CLEAR`, `EXECUTE`, `PROC`, `Procedure_Commands`,
`Program_Management_Commands`, `Alert` were folded into this spec and pruned; `Break_(Command)` was
folded into [information](../information/spec.md#break).)*
