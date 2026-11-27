# BR 5.03 Release Notes

What changed in BR 5.03 that a user, an administrator or a support engineer needs to know about.
Entries that can change how an existing program behaves come first, because those are the ones worth
reading before an upgrade rather than after. For BR 5.02, see
[BR 5.02 Release Notes](BR502%20Release_Notes.md); for BR 5.01, see
[BR 5.01 Release Notes](BR501%20Release_Notes.md); for BR 5.0, see
[BR 5.0 Release Notes](BR50%20Release_Notes.md).

## Contents

- [1. Behaviour changes](#behaviour-changes)
  - [1.1 F1 on an empty command line](#f1-empty-line)
  - [1.2 brlistener keeps each login while its client has a session open](#listener-keeps-login)
  - [1.3 Options that did nothing are now errors](#dead-options)
  - [1.4 A bare TRACE statement means TRACE ON](#trace-words)
- [2. New features](#new-features)
  - [2.1 Selecting, copying and pasting at the console with the mouse](#console-mouse)
  - [2.2 Help opens in your web browser](#help-browser)
  - [2.3 COPY, MOVE, RENAME and TYPE take several names](#several-names)
  - [2.4 SEARCH shows the lines of files that match](#search)
  - [2.5 PgDn and digits at the -P pause](#pgdn)
  - [2.6 SPAWN_RESTRICTED works in client/server](#spawn-client-server)
  - [2.7 Debugger messages for editors, and DEBUG STEP OUT](#debug-protocol)
  - [2.8 TRACE LABELS: tracing the labels a run reaches](#trace-labels)
  - [2.9 BREAK on a system function](#break-system-function)
  - [2.10 Variable watching was optimized](#watch-after-write)
  - [2.11 BREAK ... AFTER n](#break-after)
  - [2.12 DISPLAY FNname: the value a function returns](#display-function)
- [3. Fixes](#fixes)
  - [3.1 TYPE with a wildcard types every file into a redirect](#type-wildcard)
  - [3.2 A failed load from source reports its line](#load-failure-line)
  - [3.3 Memory used by a debugger connection is released](#debugger-log-leak)
  - [3.4 XLATE$ with a seven-character table](#xlate-seven)
  - [3.5 BREAK FNx stops in a library function](#break-library-function)
  - [3.6 Breakpoints on consecutive lines each stop](#break-consecutive)
  - [3.7 Five or more DISPLAYs to one file](#display-one-file)
  - [3.8 After a breakpoint: STEP on the status line, and a clean READY](#step-status)
  - [3.9 LOAD ... SOURCE readies the program as a compiled LOAD does](#load-source-ready)
  - [3.10 After a function returns, the calling line is reported](#function-return-line)

<a id="behaviour-changes"></a>
## 1. Behaviour changes

<a id="f1-empty-line"></a>
### 1.1 F1 on an empty command line

F1 on an empty command line, with nothing selected, types `HELP` and presses Tab, so the list of what
`HELP` covers comes up and Tab, Space and the arrow keys work through it as usual. Anywhere else F1
is the help key as before: help for the word under the cursor at the command line, or for the error
at an ERROR halt.

<a id="listener-keeps-login"></a>
### 1.2 brlistener keeps each login while its client has a session open

So that a restricted session started from a client/server session (2.6) opens without a password,
brlistener now keeps the user name and password of **every** login, not only on `MULTISESSION`
labels, while that client has a session open.

- **On a label without `MULTISESSION`** the kept login is used only for such a restricted session,
  only for the client that logged in, and only for the same label. Every ordinary connection is still
  asked for a password, as before. The login is dropped once the client's last session has ended.
- **On a `MULTISESSION` label** nothing changes for ordinary connections.
- **The session it opens is always restricted.** brlistener puts `--restricted` on its command line
  itself, so a login used without a password can only ever start a restricted session.

`brlistener.conf` needs no change. A brlistener from an earlier release still works with these
clients, but asks for a password when such a session starts.

<a id="dead-options"></a>
### 1.3 Options that did nothing are now errors

These were accepted and had no effect. They are now refused, so a program or procedure that still
uses one stops with an error instead of carrying on. In each case, deleting the option is the fix and
changes nothing else.

| Was accepted | Now |
|---|---|
| `-A` on `COPY`, `FREE` and `DROP` (documented as "archive-bit files only") | error **1006**, like any other option the command does not have. `DIR` still takes `-A` |
| `SYSTEM -W` or `-w` | error **4501**, like any other unknown `SYSTEM` flag |
| `SYSTEM +<n>` | error **4501**. It is no longer passed to the shell either |
| `COUNT`, `NOCOUNT`, `DATA` and `NODATA` on `RUN` and `GO` | no longer keywords. Straight after `RUN` the word is taken as a program to load, so `RUN COUNT` looks for a program named `COUNT`; elsewhere it is taken as a line label |

The `-?` help for `SYSTEM` now says that `-Tn` is in seconds.

<a id="trace-words"></a>
### 1.4 A bare TRACE statement means TRACE ON

A `TRACE` statement on its own now means `TRACE ON`: it resumes the kind of tracing the last
`TRACE OFF` stopped, or traces line numbers (2.8). It always compiled, but it read whatever byte
followed the statement, so what it did was undefined.

<a id="new-features"></a>
## 2. New features

<a id="console-mouse"></a>
### 2.1 Selecting, copying and pasting at the console with the mouse

Text on the console can be selected and copied to the clipboard with the mouse at the command
line (READY, ATTN, ERROR and LIST), on a HELP page, and in the
[console history](BR50%20Release_Notes.md#console-history) (HIST). All three take the same
gestures:

| Gesture | Does |
|---|---|
| Drag with the left button | Selects the text dragged over |
| Double-click | Selects the word under the pointer: letters, digits, `_` and `$`. Off a word it does nothing |
| Click while something is selected | Copies the selection to the clipboard and clears it |
| Click with nothing selected | Points Ctrl+Shift+Up/Down at the word clicked |
| Ctrl-C or Ctrl-Ins | Copies the selection and leaves it selected |
| Right-click | Pastes the clipboard into the command line, as Ctrl-V does |

A copy has one line per screen row, without trailing blanks.

The selection is cleared by any key other than Ctrl-C, Ctrl-Ins and F1, and when the text under it
changes or the screen scrolls or is cleared.

**Clicking a word to search for it.** After a click, Ctrl+Shift+Up and Ctrl+Shift+Down look for
the word clicked instead of the word at the cursor:

- **At the command line, on a HELP page and in HIST** they search the console history and the
  screen.
- **In LIST** they search the program. A click on a listed line searches on from that line.

A click points the search once; pressing the keys again goes on to the next match.

**What changes for clicks in these places:**

- **A click is no longer sent to BR.** On a HELP page it does not turn the page; the keys do.
- **A double-click at the command line no longer enters the line.**
- **A right-click at the command line pastes.** It is no longer the help key there; F1 and Ctrl-Y
  still are.
- **In HIST, a right-click** returns to the live screen and pastes into the command line. While a
  program is running it does nothing.
- **On a HELP page, a right-click does nothing.** There is nothing to paste into, and it does not
  turn the page.

**Running programs are not affected.** A program's screen and its input fields get every mouse event
as before, and in `INPUT FIELDS` a right-click is still the field's help key. That includes a
statement such as `INPUT FIELDS` typed at READY: the gestures apply only while the command line
itself is waiting for input.

<a id="help-browser"></a>
### 2.2 Help opens in your web browser

With `OPTION 85` off (the default), F1, Ctrl-Y and the `HELP` command show the br_tree topic in the
person's own web browser, from br_tree2, the HTML edition of br_tree, with its links, layout and
dark mode. The console is not painted over, and the status line says *Help is open in your browser*.

- **One help tab.** The first topic opens a tab; later ones move that tab to the new topic. If the
  tab has been closed, the next topic opens a new one. A browser does not let a page bring its own
  window forward, so a help tab behind other windows changes page without coming to the front.
- **The pages come from the BR server**, through a small web server inside the BR client that only
  this computer can reach. A client on another machine works the same, and nothing is copied to it.
  The server sends a page even while a program is busy in a long statement, so links in the help
  tab keep working while BR runs. No certificate is involved: the browser talks to the client on
  this computer only.
- **Where br_tree2 is.** BR looks for it with `CONFIG HELPTREE2 <folder>`, then `ENV$("BR_TREE2")`,
  then beside br_tree. `CONFIG HELPTREE2 CLEAR` puts back the search. br_tree's configuration
  section describes both `HELPTREE` and `HELPTREE2`.
- **Without br_tree2**, or with a client that cannot open a browser, help pages the topic on the
  console: 23 rows, the arrow keys, Page Up/Down and Home/End to move, F2 or Esc to leave.
- **From a program**, `HELP$(folder$, anchor$, "BROWSE")` shows a topic the same way and returns
  where it is, as `HELP$(folder$, anchor$)` does. Any other third argument is error 410; a third
  argument with `OPTION 85` on is error 9505.

A program's own field help (`INPUT FIELDS … HELP`) is unchanged.

<a id="several-names"></a>
### 2.3 COPY, MOVE, RENAME and TYPE take several names

`COPY`, `MOVE` and `RENAME` take more than one `<from>`, and `TYPE` more than one `<file>`, separated by
commas or blanks. Each may be a pattern. The last name of `COPY`, `MOVE` and `RENAME` is where they go;
`TYPE` has no target and types every name, in order, into the one redirect:

```
COPY a.txt,data\*.dat,notes\ bak
MOVE old1 old2 archive\
RENAME a,b *.bak
TYPE head.txt,body.txt >all.txt
```

- **A folder, unless the target has a wildcard.** With several names the target must be an existing
  folder, or the command is error 4203. A target with `*` or `?` still makes each file's own name.
- **A file that more than one name matches is handled once**, at the first. The overwrite question, or
  error 4150 where none can be asked, still appears when different files would be given one name.
- **A name that matches nothing is skipped**, if another matches. If none do, the command is error 4152, as
  for one name that matches nothing.
- **`RENAME -D`** renames one folder, so several names with it are a syntax error. An error, or Esc or
  Ctrl-A at a question, stops the whole command.

A blank is a separator, so `COPY a b c` now copies `a` and `b` to `c`; it used to be a syntax error. With
one name before the target, every command is as it was. See br_tree, 70-commands/file-directory/filename-patterns.md, section 1.7.

<a id="search"></a>
### 2.4 SEARCH shows the lines of files that match

`SEARCH` (`SE`) is a new file command, a small BR form of `grep`. It shows each line that contains a
pattern as `name:line: text`:

```
SEARCH apple notes.txt
SEARCH -I "apple pie" data\*.txt,old\*.txt >hits.txt
SEARCH /^ *PRINT/ src\**\*.brs >lines$
SEARCH -IWR print src\ -L
```

- **The pattern** is a word, a quoted literal, or a regular expression between slashes (ECMAScript
  syntax). `-I`, before the pattern, ignores case. A regular expression that does not compile is the new
  error 1009, *invalid regular expression*, and at the command line the cursor goes to the fault.
  The syntax, including what other regex languages have that BR's does not, is in br_tree,
  70-commands/file-directory/ECMA_REGEX.md, which `HELP COMMANDS REGEX` (or `HELP REGEX`) shows. A
  regular expression may hold a `!`, as in `/(?!x)/`; elsewhere on the line `!` still starts a remark.
- **Attributes**, before the pattern: `-I` ignores case, `-~` selects the lines that do not match, `-W`
  matches whole words only, `-B` lets a run of blanks and tabs match one blank, and `-R` searches a
  folder whole. They combine: `-I~WB`.
- **Options**, after the file names: `-C` shows a count per file, `-L` the names of the files with a
  match, and `-N` the lines without the `name:line:` prefix. An attribute after the names, or an
  option before the pattern, is error 1006.
- **The files** are named as for `TYPE`: several names, each of which may be a pattern, with the rules of
  2.3. The file the output is redirected to is never searched.
- **Each line is cleaned** before it is compared and shown: only displayable ASCII and tabs are kept, so a
  binary file can be searched without sending stray bytes anywhere.
- **An internal file** is searched record by record, numbered by record, with deleted records left out.
- **Output** goes to the screen, a file (`>`, `>>`), the printer (`PRINT`) or a string array (`>name$`).
  `-P` pauses after each screenful; at the pause a digit 2 to 9 shows that many more lines, and PgDn the
  next screen starting with the last line shown.

**Tab completes every file name** of `DIR`, `COPY`, `MOVE`, `RENAME`, `TYPE` and `SEARCH`, not only the 
first one. For `SEARCH`, completion starts after the pattern.

<a id="pgdn"></a>
### 2.5 PgDn and digits at the -P pause

At the pause that `-P` makes after each screenful of `DIR`, `COPY`, `MOVE`, `RENAME`, `DROP`, `FREE`,
`TYPE` and `SEARCH`, PgDn shows the next screen starting with the last line shown, so one line carries
over and nothing scrolls past unread. A digit 2 to 9 shows that many more lines before pausing again,
as it already did for `TYPE`. Any other key still shows the next screenful and the break key still ends
the command. `LIST -P` is unchanged.

<a id="spawn-client-server"></a>
### 2.6 SPAWN_RESTRICTED works in client/server

`SPAWN_RESTRICTED(command$ [, config$ [, wait [, label$]]])`, which starts a disposable restricted
session (and so `FNAGENT_RUN`, which an application uses to run a program an assistant wrote), used
to work only in local mode on Windows. In a client/server session it returned error 4156. It now
works there too, and behaves as it does locally.

- **The restricted session opens in its own window on the user's computer**, started by the BR
  client, and is connected through the same brlistener and label. It logs in with the user's own
  login and does not ask for a password (1.2).
- **It is restricted from its first statement**, on the server's WSID, with its audit log in the
  folder of the calling session's log, and its exit code comes back as before. With a `wait`, a
  session still running when the wait runs out is ended and its window closes (error 4157). With no
  `wait`, the function returns the session's process id on the server.
- **New error 4178**, *the restricted session did not start*: nothing logged in and started the
  session in time — within 60 seconds, or within `wait` if that is shorter. For example the user
  cancelled a login box, or the listener could not be reached.
- **Error 4156** now means only that the session is running on a console client, which has no second
  window to open.

The BR client and server must both be 5.03. The Windows client and server are tested. The Linux and
Mac client code, and a Linux or Mac server, are written but not yet tested.

<a id="debug-protocol"></a>
### 2.7 Debugger messages for editors, and DEBUG STEP OUT

A debugger attached with `DEBUG LISTEN` can now ask BR for what an editor's debugger needs, as
structured messages instead of text read off the screen: line breakpoints (checked against the
program, and set in a library when it loads), hit counts, logpoints, function and data breakpoints,
a stop on every error, the call stack, variables and arrays, evaluating expressions, setting
variables, and continue, step into, step over and step out. BR reports each stop once, and tells the
debugger when a program starts and ends and what it writes to the debugger. It can also select a
library's program, as F9's *Choose a library* does at the prompt. These are for brls's debug adapter,
which lets editors such as VS Code debug BR programs; the protocol is in `DEBUG_PROTOCOL.md`.
Debuggers that do not use the new messages work as before.

**`DEBUG STEP OUT`** is a new command: it runs to the end of the current `GOSUB`, function or
library call and stops in its caller, as Shift+F5 does in the debugger. Until now the step had no
command that could be typed.

Tested on Windows. Linux and Mac are not yet built.

<a id="trace-labels"></a>
### 2.8 TRACE LABELS: tracing the labels a run reaches

Tracing can now show the line labels a program reaches, as well as, or instead of, line numbers.
Each label the run comes to, by `GOTO`, `GOSUB` or falling into it, is shown with its colon
(`POST_LEDGER:`) on the bottom line of the window, where traced line numbers go. With both on, a
line's label comes before its number.

Tracing now has three modes, which the statement and the `RUN` and `GO` commands name the same way:
`LINES`, `LABELS` and `PRINT` (to the printer instead of the window). They can be given in any
order. Tracing can also go to a file, with `>file` or `>>file`.

| Statement | Console, on `RUN` or `GO` | Effect |
|---|---|---|
| `TRACE LINES ON` | `TRACE LINES` | line numbers |
| `TRACE LABELS ON` | `TRACE LABELS` | labels only |
| `TRACE LABELS LINES ON` | `TRACE LINES LABELS` | both, in any order |
| `TRACE PRINT`, `TRACE PRINT ON` | `TRACE PRINT` | to the printer |
| `TRACE PRINT OFF` | `TRACE PRINT OFF` | back to the window; the other modes stay on |
| `TRACE LABELS ON >t.txt` | `TRACE LABELS >t.txt` | to a file; `>>` adds to it |
| `TRACE LINES OFF`, `TRACE LABELS OFF` | `TRACE LABELS OFF` | stops that mode; the others stay on |
| `TRACE OFF` | `NOTRACE`, `TRACE OFF` | stops every mode, and remembers which were on |
| `TRACE ON`, `TRACE` | `TRACE` | resumes what was remembered, or traces line numbers |

- **The statement turns on and off only the modes it names.** So `TRACE PRINT` still only sends
  tracing to the printer, as it always has, and `TRACE LABELS ON` adds labels to any line tracing
  already on. The console's `TRACE` is what turns tracing on, so `RUN TRACE LABELS` traces exactly the
  labels, and `RUN TRACE PRINT` traces line numbers to the printer.
- **`TRACE OFF` remembers the modes**, the printer included, and a later `TRACE ON` resumes them, so
  a program can bracket a region with `TRACE OFF` and `TRACE ON` without repeating them. `NOTRACE`
  and `TRACE` on `GO` do the same. With nothing remembered, `TRACE ON` traces line numbers, as before,
  so existing programs and commands trace as they did. `RUN` starts afresh: it forgets the remembered
  modes.
- **On `RUN` and `GO`, every trace option follows `TRACE`**: `LINES`, `LABELS`, `PRINT`, `ON` and
  `OFF`, in any order, with `LINES`, `LABELS`, `ON` and `OFF` spelled out. Anywhere else those four
  are what they always were, a program name for `RUN` and a line label for `GO`, and a `PRINT`
  before `TRACE` does nothing, as in `RUN PRINT TRACE`, which traces to the window.
- **A trace file** is laid out for reading: each label is a line of its own, and the line numbers
  between labels follow one another, blank-separated, on lines of up to 80 columns:
  ```
  POST_LEDGER:
  00800 00810 00820 00830 00840 00850 00860 00870 00880 00890 00900 00910 00920
  ```
  It is written as the program runs, stays open through pauses, and closes at a bare `TRACE OFF` or
  `NOTRACE` and when the program ends. A later `TRACE ON` adds to it. In the statement the file comes
  last and needs no quotes (`TRACE LABELS ON >trace.txt`; `LIST` shows the name quoted). On `RUN`, a
  `>file` after `TRACE` redirects only the trace, so `RUN >p.txt TRACE >t.txt` keeps the program's
  printer output and the trace apart. Of `PRINT` and a file, the last named wins. Trace output never
  goes into an array: `>A$` naming one is error 315.
- With logging at level 12, each label is also logged as *Trace label POST_LEDGER: in program*.
  Labels are kept with the source, so a program saved without its source shows none. A program that
  uses `TRACE LINES`, `TRACE LABELS`, `TRACE PRINT OFF` or a trace file needs BR 5.03 or later.

<a id="break-system-function"></a>
### 2.9 BREAK on a system function

`BREAK` now takes the name of any of BR's string or numeric functions, such as `BREAK LEN`,
`BREAK STR$` or `BREAK VAL`. The run stops in STEP mode **before each clause that calls the
function**, so `BREAK LEN` stops before `LET B=LEN(A$)` and before every later statement that
calls `LEN`; `GO` or Enter runs it and goes on. A system function has no lines of its own, so it
cannot stop inside the function as `BREAK FNname` does.

- The name is spelled out in full. `OFF` clears it, `BREAK ALL OFF` clears it with the rest, `-p`
  chooses the program as for any breakpoint, and `STATUS BREAK` lists it as `BREAK FUNCTION LEN`.
- `IF` and a redirection are refused (error 1006), and `DISPLAY` does not take a function (1070).
  `AFTER n` is accepted ([2.11](#break-after)).
- A clause is stopped before if its compiled code calls the function, even where that call would
  not be reached.
- With no function breakpoints set, programs run as fast as before: the check is one test per
  clause.

<a id="watch-after-write"></a>
### 2.10 Variable watching was optimized

`BREAK <variable>` and `DISPLAY <variable>` used to compare every watched variable with its
last value at every statement, so a watched array was compared element by element all the
time. Now a watched variable is marked, and the comparison runs only after a statement that
wrote one: an assignment, `INPUT`, `LINPUT`, `READ` (from a file or from `DATA`), `MAT`, `NEXT`,
a system function that fills an argument such as `STR2MAT`, or output redirected into an array.
With nothing being written, a watched program runs as fast as an unwatched one.

What is reported, and where the run stops, is the same, with one improvement: a variable that a
function in another program (a library) changes through a parameter passed by reference is
reported straight after the line that changed it, inside that function. It used to be reported
only later, at the function's end or back in the caller. A program saved while a watch is on is
saved exactly as it would be without one.

<a id="break-after"></a>
### 2.11 BREAK ... AFTER n

A breakpoint can now pass over its first stops. `AFTER n` lets the first *n* go by and stops
from the next one on:

```
BREAK TOTAL AFTER 5            stops the 6th time TOTAL changes, and every time after
BREAK 1200 AFTER 99            stops the 100th time line 1200 is reached
BREAK FNCALC AFTER 2           the third call of FNCALC
BREAK LEN AFTER 10             the 11th clause that calls LEN
BREAK TOTAL AFTER 3 IF X>0     the 4th change of TOTAL while X>0
BREAK AFTER 2 IF X>100         the 3rd line after which X>100
```

- `AFTER` comes after the line, variable or function, and before `IF`, which takes the rest of the
  command. With `IF`, only the times the condition holds are counted.
- The count starts again at each `RUN`. Entering the same `BREAK` again sets it afresh.
- `STATUS BREAK` shows the count, `BREAK LINE 01200:01 AFTER 99`, and once a run has passed over
  some, how many are left: `AFTER 99 (40 to go)`. A breakpoint made with `-p` keeps its `AFTER` when
  the program is loaded again.
- `AFTER` is a keyword only when a number follows, so a variable named `AFTER` can still be
  watched. It is refused (error 1006) with `OFF`, `ALL`, `BEGIN`, `FILE`, by `DISPLAY`, and
  when given twice.

<a id="display-function"></a>
### 2.12 DISPLAY FNname: the value a function returns

`DISPLAY FNname` writes a line each time the function returns, with the line and clause that
called it and the value it returned, and the run goes on:

```
line 00080:01, FNSQ returned, value = 4
line 00100:01, FNNAME$ returned, value = Mr Smith
```

`BREAK FNname` now implies it, as `BREAK variable` implies `DISPLAY variable`: the break still
stops inside the function when it is called, and when the function returns, the value is shown.

- The line goes where the `DISPLAY` sends it: the screen, `PRINT`, `>file` or `>A$`. For a
  `BREAK FNname`, it goes where the break's redirection sends it (`BREAK FNSQ >trace.txt`), or to
  the screen, or to an attached debugger.
- Both on one function give one line, which goes where the `DISPLAY` sends it.
- It works for a single-line or multi-line `DEF`, numeric or string, and for a library function,
  whether set from the calling program or with `-p <library>`.
- `OFF` takes it away, and `STATUS BREAK` lists it as `DISPLAY VARIABLE FNSQ`.
- `IF` is refused with a function (error 1006): a function returns in the middle of a statement,
  where the run cannot halt to test a condition. `DISPLAY ALL` still leaves functions out, and a
  system function such as `LEN` is still refused (1070).

<a id="fixes"></a>
## 3. Fixes

<a id="type-wildcard"></a>
### 3.1 TYPE with a wildcard types every file into a redirect

`TYPE *.txt > out` wrote only the first file to `out`: the redirect was closed after one file. A
plain wildcard such as `a*.dat` or `a?.dat` did not work at all; it was opened as a literal name
and failed with error 600, *bad wb file name*, with or without a redirect. `TYPE` now types every
file a wildcard names, one after the other, into the one redirect, so `>` and `>>` give the files
joined end to end.

Written to a file, the bytes are copied as they are, so a file that holds a blob comes through whole.
Trailing nulls and Ctrl-Z, which `TYPE >>` used to trim from each file, are now trimmed only when the
file is typed to the screen. This also applies to `TYPE oldfile >> out` for an old text file that ends
in Ctrl-Z: the Ctrl-Z now stays in `out`.

<a id="load-failure-line"></a>
### 3.2 A failed load from source reports its line

When a program is loaded from source and a line cannot be accepted, an unattended session logged
*Unattended processing terminated by error … while loading a program from source* with **line 0**.
It now names the line of the source file that failed, for example *error 1020 … line 2. missing
parenthesis*. A load that succeeds, or one that fails before any line is read because the file cannot
be opened, still reports line 0.

<a id="debugger-log-leak"></a>
### 3.3 Memory used by a debugger connection is released

While a debugger was attached (`DEBUG LISTEN`), each log message BR forwarded to it, which includes
every command entered, kept a little memory that was never released. The amount was small, a few dozen
bytes for each message, but it grew for as long as the session ran. It is now released as soon as the
message is sent.

<a id="xlate-seven"></a>
### 3.4 XLATE$ with a seven-character table

`XLATE$(X$, "STR2UTF")` and `XLATE$(X$, "UTF2STR")` convert between BR's characters and UTF-8. But
BR took **every** seven-character table for one of the two: one beginning with S converted to UTF-8,
and any other converted from it, so `XLATE$(X$, "ABCDEFG")` gave error 438 when `X$` held a character
above 127 and otherwise returned `X$` unchanged. Only those two names, in any mix of upper and lower
case, now convert. Any other seven characters are an ordinary table, which translates `CHR$(0)` to
`CHR$(6)` and passes every other character through. A program that relied on the old result with
some other seven-character table will see the difference.

Also, `UTF2STR` on a string ending with the first byte of a two-byte character read one byte past the
end of the string before giving error 438. It still gives error 438, without the extra read.

<a id="break-library-function"></a>
### 3.5 BREAK FNx stops in a library function

`BREAK FNx` typed at the calling program's prompt never stopped when `FNx` was a library function:
the breakpoint is kept with the calling program, but BR looked for it in the library's. It now
stops at the function's first line, as for a function defined in the program itself.
`BREAK -p <library> FNx` stops too, as before.

<a id="break-consecutive"></a>
### 3.6 Breakpoints on consecutive lines each stop

After a breakpoint stopped the run, `GO` passed over the next breakpoint check, wherever it was, so
that it would not stop again in the same place. Resuming does not check the stopped line again, so
the check passed over was the next line's: with `BREAK 60` and `BREAK 70`, the run stopped at 60
and not at 70. Only the check at the place the run stopped is passed over now.

<a id="display-one-file"></a>
### 3.7 Five or more DISPLAYs to one file

Each `DISPLAY variable >file` held a handle of its own on the file, and BR lets a session have one
file open at most four times. So a fifth `DISPLAY` to the same file failed: from a procedure with
error 4147, *file is opened too many times on this WSID SESSION for locking*; typed at READY it was
accepted, but during the run that variable's changes went to the screen instead of the file, with
no error. `DISPLAY`s (and `BREAK`s with a redirection) that name the same file now share one handle,
however many there are; the names are matched as typed, ignoring case. If BR cannot open a display
file again during a run, it now logs that once.

<a id="step-status"></a>
### 3.8 After a breakpoint: STEP on the status line, and a clean READY

When a breakpoint stopped a program, the status line said `LIST` instead of `STEP`: the stop
shows its line with a `LIST` of its own, and the prompt announces a `LIST` in progress. It now
says `STEP`; the arrow keys still list program lines from there.

And a `GO` typed at that stop that ran the program to its end left the word `GO` on the command
line: the next command was read with it, so `PRINT 3` became `PRINT 3GO` and failed, and the
status still said `LIST` until PgDn cleared it. A typed `GO` now moves to a new line, as `RUN`
does, and the run ends at a clean `READY`. Stepping with Enter is unchanged.

<a id="load-source-ready"></a>
### 3.9 LOAD ... SOURCE readies the program as a compiled LOAD does

Loading a compiled program sets on it the breakpoints recorded for it with `BREAK -p`, and those an
editor's debugger holds for it. Loading from source did neither, so `BREAK -p PROG 50` followed by
`LOAD PROG.BRS,SOURCE` and `RUN` ran without stopping, although `STATUS BREAK` still listed the
breakpoint under *Persistent break points*. A load from source now does the same once its last
line has compiled. A load that stops on an error does not, since the program is incomplete.

<a id="function-return-line"></a>
### 3.10 After a function returns, the calling line is reported

When a statement called a function and then changed a watched variable, as `LET Q=FNSQ(I)+1`
does, `DISPLAY Q` and `BREAK Q` reported the change at the function's last line instead of the
statement's. The function's lines had moved BR's record of where the program is, and returning
did not move it back. It now goes back to the calling line and clause when the function returns.
Everything that reads that position after a return in the same statement now gives the calling
line too: the line BR's log names, the profiler and an editor debugger's current frame.

A variable passed by reference to a function, as `DEF FNBUMP(&Q)`, becomes the program's own
variable of that name again when the function returns. A watch on it now reports that change at
the calling line, not at the function's `FNEND`.
