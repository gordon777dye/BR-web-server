# br_mcp_driver

`br_mcp_driver.exe` connects an AI assistant, such as Claude or Codex, to a running BR 5.0
session. It uses no language interpreter and needs no toolset installed. This file is the  
reference for anyone using AI for writing, running or testing BR programs (`.brs`): its 
modes, its tools, its rules, and the standard procedures in [`prc/`](prc/).

## 1. What it is for: three scenarios

The driver serves BR in three situations. They differ in who is at the keyboard, and in whether
the driver calls a model or the assistant already has one.

1. **An assistant helping a developer.** The assistant has its own model, so the driver calls
   none. `start` brings up a `DEVELOP`-mode session, or `serve` serves one that BR opened itself,
   and the assistant's own `connect` reaches it. The assistant reads the screen, checks source,
   runs commands inside an open turn, and types with the keyboard the procedure lent it.
   Testing a changed program is this scenario. An assistant with a shell and no MCP connection
   reaches the same session with `read screen` and `send keys` (§3).
2. **An assistant working alongside an end user.** The same machinery as scenario 1, but
   `start --user` runs the session in user mode. The keyboard is lent for an hour, keys go in
   only while BR is waiting for input, and BR stops and asks the person before an
   operating-system command or a destructive file operation.
3. **An application that uses AI for its users and programs.** A person types `AI <text>` at
   `READY`, or a program asks for something: `EXECUTE "AI ..."`, or agentlib's `FNAGENT_CODE` for
   a program to be written. The driver calls the model itself: `chat` answers the console, and
   `report` writes BR programs for the application, which `run_report` runs in a restricted
   session (§7, §9). No assistant is involved.

`uitest` (§4) and `watch` use the same channel as scenarios 1 and 2, and call no model.

**Start somewhere else if you have a task:**

| To | Read |
|---|---|
| test a changed program: check it, run it headless, script a screen test, or watch it live | [`../BR_testing.md`](../BR_testing.md) |
| set up and start a session with an assistant attached | [`../BR_launch.md` — Live sessions](../BR_launch.md#harness-launch) |
| read and type into a running program's screen | [`../BR_harness.md`](../BR_harness.md) |
| do the same from a shell, one command at a time | [`../BR_testing.md` §5](../BR_testing.md#live-shell), and §3 here |

Once attached, **call the `guide` tool first.** It gives the order of operations, the grant and
the turn in full, the ways BR differs from other BASICs, and the list of reference topics and data
files the other tools can answer for.

## Contents

- [1. What it is for: three scenarios](#1-what-it-is-for-three-scenarios)
- [2. Files and settings](#2-files-and-settings)
- [3. Modes](#3-modes)
- [4. `uitest`: a screen test script](#4-uitest-a-screen-test-script)
- [5. The tools](#5-the-tools)
- [6. What an assistant may do](#6-what-an-assistant-may-do)
- [7. `run_report`: running a program in a restricted session](#7-run_report-running-a-program-in-a-restricted-session)
- [8. The standard procedures](#8-the-standard-procedures)
- [9. Modes that call a model: `chat` and `report`](#9-modes-that-call-a-model-chat-and-report)
- [10. Error numbers and exit codes](#10-error-numbers-and-exit-codes)
- [11. Further reading](#11-further-reading)

## 2. Files and settings

| File | What it is |
|---|---|
| `br_mcp_driver.exe` | the driver |
| `brls.exe` | the BR syntax checker; the `check_source` tool runs it |
| `prc/BR_dev.prc`, `prc/BR_user.prc` | the procedures `start` launches BR on. **Copy them into BR's start folder** ([`BR_launch.md`](../BR_launch.md#the-procedure-has-to-sit-in-brs-start-folder)) |
| `prc/BR_report.prc` | the procedure `run_report` runs. **Copy it into the folder `run_report` runs in** (§7) |
| `examples/` | the kit's three complete screen tests: `greet` (a program that should end cleanly), `oops` (one that should hit error 4152) and `orders` (a `GUI ON` screen with a grid, a list and a button). Each is a `.brs`, a `.prc` and a `.uis`; [`BR_testing.md` §4](../BR_testing.md#uitest) runs them. Tests of the application's programs go in `context/app/tests/`, not here |

BR itself (`brserver-x64-Release.exe`) is in [`../tools/`](../tools/), not here.

The driver reads these settings. A flag has precedence over an environmental variable.

| Setting | Used for | Without it |
|---|---|---|
| `--br`, then `$BRSERVER`, then `$BR_EXE` | the BR that `start` and `run_report` launch. The first variable that is set decides, even if what it names is missing | `brserver.exe` beside the driver, then `PATH`; neither is shipped, so `start` refuses |
| `--config`, then `$BR_AI_USER` | the configuration file `start` gives BR, named in full | BR finds a `brconfig.sys` of its own, with the wrong `DRIVE` mappings and no `LOGGING`. Nothing warns you |
| `$BRLS` | a different `brls.exe` | `brls.exe` beside the driver, then `PATH` |
| `$BR_CONTEXT_KIT`, or `--kit` for `report` | the kit folder, for `get_reference`, `get_layout` and the catalogue in `guide` | `C:\ADS\qsmrp\context` |
| `--port` | which session to reach | the port in the session's token file. Needed only with more than one session open |

The driver checks a named BR or configuration file before it launches BR, and refuses a missing
one by name.

**How a session is found.** A BR session that opens its channel writes its port and a token to
`%LOCALAPPDATA%\ADS\harness.token`. The first client to connect uses the token up and the file is
removed. A session therefore accepts **one connection**: when that client disconnects, the channel
closes, and only `MSG("harness", port)` inside BR opens it again.

## 3. Modes

The first argument picks the mode.

| Command | What it does |
|---|---|
| `br_mcp_driver start [--user] [--config F] [--br PATH] [--port N] [--pipe NAME] [--wait D]` | launch BR on `BR_dev.prc` (or `BR_user.prc` with `--user`), claim the channel it opens, and serve it to `connect` |
| `br_mcp_driver serve [--port N] [--pipe NAME] [--ready-file PATH]` | claim a channel a BR session opened itself, and serve it |
| `br_mcp_driver connect [--pipe NAME]` | what an assistant launches as its MCP server: a relay onto the pipes `start` or `serve` holds |
| `br_mcp_driver read screen [--offset N] [--ascii] [--pipe NAME]` | print the session's screen, row by row, and BR's status line as `sl`. A client of the service `start` or `serve` holds |
| `br_mcp_driver send keys TEXT [--read S] [--ascii] [--pipe NAME]` | type text and keys into the session: `ACME{ENTER}{F9}`. `--read S` then prints the screen |
| `br_mcp_driver uitest <script>... [--port N] [--settle S] [--ascii] [--start PROC ...]` | run screen test scripts against a session, or start BR for them (§4) |
| `br_mcp_driver testdata snapshot\|restore\|check <dir> [--snapshot S]` | keep a test data folder at a known starting point (§4.3) |
| `br_mcp_driver watch [--port N] [--events "..."] [--seconds N] [--quiet D]` | print the session's events as they arrive. The default events are `INPUT SCREEN GRANT KEYSDONE NOTE CLOSING` |
| `br_mcp_driver tools` | print the published tool list, as JSON, with no session |
| `br_mcp_driver chat ...` | answer the `AI` command at BR's console (§9) |
| `br_mcp_driver report ...` | write the BR program an application asks for (§9) |

### `start`

`start` takes no BR command; BR always starts on the standard procedure. It removes a stale token
file, launches BR detached, waits for the channel, and prints three lines worth reading, because
they say which configuration and which BR it got:

```
configuration from BR_AI_USER: context\dev\tools\brconfig.ai_user
BR started from context\dev\tools\brserver-x64-Release.exe (pid 26860) on BR_dev.prc; waiting for the channel
harness claimed on port 8720, protocol 5
```

A protocol below 5 means an old BR that lacks several requests; see
[`BR_harness.md` §1.1](../BR_harness.md#setup).

BR's own screen goes to its window and its diagnostics to the `LOGGING` file, not to the shell.
To end the session, close BR, or type `LET X=MSG("harness",0)` in it.

### `serve` and `connect`

The assistant's configuration is always the same:

```json
{
  "mcpServers": {
    "br": { "command": "C:\\path\\to\\br_mcp_driver.exe", "args": ["connect"] }
  }
}
```

or `claude mcp add br -- br_mcp_driver connect`. `connect` holds no connection or credential, so
the assistant can restart it at any time. `start` or `serve` holds the one connection to BR for
the life of the session.

Use `serve` when a BR program opens the channel itself:

```
LET X=MSG("harness", 8720)
EXECUTE "SYSTEM -@ -C -W -M br_mcp_driver serve"
```

One assistant at a time: a second `connect` is told `another assistant is already attached`.

### `read screen` and `send keys`

For an assistant that has a shell and no MCP connection. Each command dials the pipe `start` or
`serve` holds, makes its calls and leaves, so any number of them can follow one another, and the
session stays up between them. They call the tools an MCP assistant has (`read_view`, `keys`,
`press`), so the grant and the rule about where keys go are the same.

```
br_mcp_driver start                                  # in the background; BR on BR_dev.prc
br_mcp_driver read screen
br_mcp_driver send keys "PRINT 2+3{ENTER}" --read 1
br_mcp_driver send keys "{PAGEDOWN}SYSTEM{ENTER}"    # end the session
```

`read screen` prints each row from 0 between bars, then BR's status line as `sl`, which is where
BR says why it stopped: an error that halted a procedure is on it and on no row. `--offset N`
scrolls the view back N history lines and marks those rows `h`. `send keys` types text as it is
and takes a key as `{NAME}`: `{ENTER}`, `{TAB}`, `{F9}`, `{SHIFT-F2}`, `{CTRL-END}` or a scancode,
with `{{` for a brace. The whole string is checked before anything is sent. `--ascii` prints plain
ASCII, one character a cell: box drawing as `+ - |`, shading as `. : #`, accents dropped.

At `READY`, press `{PAGEDOWN}` before a command if the line may hold text left from earlier
output. Exit codes: 0 done, 1 refused or no session, 2 a usage error. They are refused while an
assistant is attached through `connect`. They read the console's cells, so under `GUI ON` they
show the Command Console, not the program's screen.

## 4. `uitest`: a screen test script

A script says what should be on a screen, what to type, and what should come up. `uitest` runs
it and exits **0** if every check passed, **1** if one failed or no session could be reached, and
**2** for a usage error. Its last line is `<n> checks, <m> failures`. A failed `expect` prints the
screen. **[`BR_testing.md` §4](../BR_testing.md#uitest) has a complete, tested example**: the
program, the procedure that opens the channel, and the script.

```
# the order entry screen, and what a bad code does
expect row 0 "ORDER ENTRY"
expect "Customer code:"
absent "Customer not found"
field 0 spec "C 8"
type ACME
press ENTER
expect "Customer not found"
press ESC
expect no error
wait end
```

### 4.1 Starting BR for the test

```
br_mcp_driver uitest --start <proc> [--config F] [--br PATH] [--wait S] [--end S]
                     [--restore DIR [--snapshot S]] [--leave] [--timeout S]
                     [--blocked S] [--out DIR] <script>...
```

With `--start`, `uitest` runs the whole test:

1. With `--restore DIR`, it restores that test data folder from its snapshot (§4.3).
2. It removes a stale token file and starts BR on the procedure, with `--config` or
   `$BR_AI_USER`. BR is found as `start` finds it (§2), and with neither `$BRSERVER` nor `$BR_EXE`
   set, it is the kit's `dev\tools\brserver-x64-Release.exe`. The procedure's path is handed to BR,
   so it is from BR's start folder. A BR an earlier run started that is still running is warned
   of first (below).
3. It waits up to `--wait` seconds (90) for the channel the procedure opens. If BR ends first, it
   says so at once, and which way: before the channel opened, or after it opened, because the
   program ended at once. Either way it quotes the end of BR's log for the run.
4. It runs the scripts, then waits up to `--end` seconds (30) for BR to end. **BR's exit code must
   be 0**; when it is not, the failure quotes the end of BR's log.
5. A BR that does not end fails the run, and is then ended as a person would end it (§4.2). Only
   one that will not take that is stopped, which can leave its workstation slot taken, so the next
   run may fail during WSID assignment. `--leave` leaves BR running instead, for a person to look
   at.

**Give each test a log of its own.** Every BR writes to the configuration's `LOGGING` file, so one
run's lines are mixed with every other session's. A `CONFIG LOGGING` line first in the procedure
switches this run to a file of its own; `uitest` makes its folder, empties it before BR starts, and
quotes it when the run fails:

```
CONFIG LOGGING 10, context\app\tests\results\custlist-br.log
```

BR opens the log as a plain file, so a `SUBSTITUTE` or `[WSID]` in the configuration's `LOGGING`
name cannot do this. BR's own start-up lines, before the procedure runs, still go to the shared
file.

**The shared log is cleared at the start of each run.** When the configuration's `LOGGING` file is
under `context\app\` - the kit's configurations name `context\app\startlog.txt` - `uitest` and
`brtest` delete it before their first BR starts, once per run of the driver, so a suite is one
run and its tests do not wipe one another's lines. Each test still quotes only what it added. A log
anywhere else is never touched, and a log another BR has open cannot be deleted: the driver says
so and reads it from where it ends.

**Sessions left behind.** Every BR `uitest` or `brtest` starts is written down, and struck off when
it ends. A run warns before it starts when an earlier run's BR is still running, because such a
session breaks later runs: measured, every `record` step exited with code 99 while two were up.
End them with

```
br_mcp_driver uitest --cleanup
```

which ends only BRs a run started, never a person's own session. Their channels are spent, so they
cannot be ended cleanly and are stopped.

Two limits stop a test from waiting for ever. `--timeout S` ends the whole test after `S`
seconds: BR is stopped, the step in progress fails, and so does the test. `--blocked S` (30) is
how long one request waits for BR's answer; a session that stops answering fails the step as
*blocked*, and every later step at once. `--out DIR` keeps a picture of the screen at each of the
first three failures, as `<test>-<line>.png`.

Without `--start`, `uitest` connects once to a session that has already opened its channel, and
does not wait for one. Start it after the token file appears.

The checks `uitest` makes itself are reported as `start` and `end` instead of a line number:

```
ok    start: the channel is open on port 8751, protocol 5
...
ok    end: no untrapped error
ok    end: BR ended, exit code 0
```

### 4.2 Untrapped errors and the end of the program

**Every untrapped error BR shows must be accounted for.** BR reports each one on the channel with
its number, its message and the line. A script that provokes one on purpose says
`expect error <n>`. Any other fails the run: at `expect no error` if the script has one, and at
the end of the run if it does not. So a test fails on an untrapped error even if its author did
not think to check.

`wait end` passes when the session ends, which is normally the procedure reaching `SYSTEM` after
the program stops. If it does not end in time, the failure says where the program was, or which
untrapped error it is stopped at.

**After an untrapped error the program waits at BR's error prompt.** A user-mode channel's keys
do not reach that prompt, so a test that expects an error opens the channel in `DEVELOP` mode,
`MSG("harness", <port>, "DEVELOP")`, and ends the session itself, with `CLEAR PROC` and then
`SYSTEM` with no parameters:

```
expect error 4152
type CLEAR PROC
press ENTER
type SYSTEM
press ENTER
wait end
```

**A session the scripts leave behind is ended.** If BR is still up `--end` seconds after the last
script, `uitest` fails the run and then ends BR. With a `DEVELOP` channel it does so as a person
would: BREAK, to stop a program that is running or waiting; PAGE DOWN, to move aside whatever is
on the command line; then `CLEAR PROC` and `SYSTEM`. The keys need the grant, as `type` does. With
a user-mode channel the keys do not reach the command prompt, so BR is killed, and a killed BR can
leave its workstation slot taken.

**A procedure line that fails leaves BR at that line.** Under `PROCERR RETURN`, BR stops the
procedure, puts the failed line back on the command line for editing with the cursor at the
error, and waits there, so the session stays up. Text typed then lands inside that line. A script
on a `DEVELOP` channel that ends such a session itself presses `PAGEDOWN` first, which moves the line aside however many
rows it takes:

```
press PAGEDOWN
type CLEAR PROC
press ENTER
type SYSTEM
press ENTER
wait end
```

### 4.3 Test data: `testdata`

Programs under test use test data, never live data: a developer's sample copy, or at a customer
site the area onboarding STEP 9 builds under `context/app/test/`, which `subs.txt` redirects every
data folder to. What a test also needs is the **same** data every run, because a test that saves a
record changes the copy.

```
br_mcp_driver testdata snapshot <dir>     # once, when the data is as the tests expect
br_mcp_driver testdata check <dir>        # what has changed since; exit 1 if anything
br_mcp_driver testdata restore <dir>      # make it the snapshot again
```

The snapshot is `<dir>.snapshot` beside the folder, or where `--snapshot` says. Restore makes the
folder exactly the snapshot: changed files are copied back and files a test added are removed.
Files whose size and time match are skipped, so a restore copies only what a test wrote.
`uitest --start ... --restore <dir>` restores before it starts BR.

Run `testdata` with no BR session using the files. A file BR has open cannot be replaced, and the
error names it. A snapshot takes as much disk as the folder: the STEP 9 area at this site is
493 MB in 2,052 files.

### 4.4 Steps

| Step | What it does |
|---|---|
| `expect "text"` / `expect row N "text"` | the text must be on the screen, or on row `N` (rows count from 0). Retries for up to `--settle` seconds, 5 by default |
| `absent "text"` | the text must not be on the screen. Checked once, so `wait` first if timing matters |
| `field "Customer code:" spec "C 30"` / `field N spec "C 30"` | the field that caption labels, or control `N`, must expect that spec. Retries like `expect` |
| `field "Customer code:" value "ACME"` / `field N value "ACME"` | the field must show that text, trimmed. Retries like `expect` |
| `type ACME` | type printable text. Needs the grant |
| `press ENTER` / `press F1` / `press 13` | a named key, a function key (`F1` to `F20`, `SHIFT-F1`, `CTRL-F1`), or a scancode. Needs the grant |
| `press button "Post"` | press the button showing that caption, by its scancode. Needs the grant |
| `grid cell R,C "text"` | that cell of the first grid on the screen must show the text. Rows and columns count from 0 |
| `grid rows N` / `grid contains "text"` | the grid must have `N` rows / some cell must show the text |
| `grid 4 cell R,C "text"` | the same for the grid that is control 4, when there is more than one |
| `list ...` | the same three checks for a list |
| `pace 300` | milliseconds between typed keys |
| `wait input` / `wait screen` / `wait 2` | until a program asks for input, until the screen changes and settles, or for seconds |
| `view offset N` / `view` | the console history view must be at offset `N` / report the offset and lines held |
| `expect no error` | no untrapped error since the last check (§4.2) |
| `expect error 4152` | an untrapped error with that number was shown. Retries like `expect` |
| `wait end` / `wait end 120` | the session must end, within 60 seconds or the number given |
| `grant?` / `screen` | record whether the script may type / print the screen, and under it BR's status line as an `sl` row. `--ascii` prints it in plain ASCII |
| `expect screen orders.txt` | the whole screen must match that baseline file, beside the script (§4.7) |
| `msgbox` / `msgbox "Overwrite?"` | a message box must be open / and its prompt or title must contain the text. Retries like `expect` |
| `msgbox none` | no message box is open |
| `check orders.test.brs` | run a test program now, headless, and count its lines (§4.10) |
| `record customer key "A100" Name$="ACME"` / `... absent` | read a record and compare fields, from its layout (§4.10) |
| `trap "occurred at line"` / `trap none` | look for the program's own error window after every step, as well as any `uitest.settings` names / look for none (§4.8) |
| `answer YES` / `answer OK tick` | press a button of the open box: `OK`, `YES`, `NO`, `CANCEL` or `ALL`; `tick` ticks "Don't ask again" first. Waits for the box to open and then to close. Needs the grant (§4.6) |
| `variable CODE$ "ACME"` / `variable TOTAL 42` / `variable CODE$` | a watched variable's latest value must be that, a number compared as one / report its value and every change. Retries like `expect` (§4.11) |
| `expect print report.txt` / `expect print h_print.40 report.txt` | the newest print capture, or that one, must match the baseline beside the script; `mask "<regexp>"`, repeatable, hides what changes from run to run (§4.12) |
| `signal held` / `await held` / `await held 90` | in a pair of scripts: tell the other script / wait until it has, up to 60 seconds or the number given (§4.13) |

Text that begins with `no error` or `error` is checked as screen text by quoting it:
`expect "error 12 in input"`.

The named keys are `ENTER` (`RETURN`), `TAB`, `BACKTAB`, `BACKSPACE`, `ESC` (`ESCAPE`), `UP`,
`DOWN`, `LEFT`, `RIGHT`, `HOME`, `END`, `INSERT`, `DELETE`, `PAGEUP`, `PAGEDOWN`, `HELP`, `UNDO`,
`FIELDPLUS`, `FIELDMINUS`, `UPFIELD`, `DOWNFIELD`, `BREAK`, `COPY`, `PASTE`, `CUT`, `WHEELUP`,
`WHEELDOWN`, the `SHIFT-` forms of the arrows, `ENTER`, `HOME`, `END`, `PAGEUP` and `PAGEDOWN`,
and `CTRL-HOME` and `CTRL-END`.

Rules for scripts:

- **A failed check does not stop the script**, so one run reports everything that is wrong.
- **No variables, loops or conditions.** A test that needs them is a program.
- **Name every script in one command.** The session accepts one connection, so a second `uitest`
  cannot get in.
- **The script must take the program to its end.** When `uitest` disconnects, the program is still
  waiting for input, and BR stays up until something answers it. End a script with `wait end`.
- Typing needs a grant, which only the session can give, with `MSG("grant", <seconds>)`.

### 4.5 `GUI ON` screens, captions and grids

**The same steps work in both GUI modes.** `uitest` asks the session which mode it is in. Under
`GUI OFF`, `expect`, `absent` and `screen` read the character cells, which hold the program's
screen. Under `GUI ON` the cells hold the Command Console, so `uitest` builds the program's screen
from its controls instead: each control's text is placed at its row and column, which is what a
person sees. Rows and columns are those `controls` reports, counted within the window the program
opened. Grids and lists are left out of that screen and read with `grid` and `list`.

**Name a field by its caption rather than its number.** A control's number is its position in
BR's list and changes when the screen does. `field "Customer code:" ...` finds the control showing
that caption (exactly, or failing that containing it) and takes the nearest input field to its
right on the same row, or failing that the nearest one below it. The pass line says which control
it took:

```
ok    5: "Customer code:" (control 4 at 2,0) labels control 0 at 2,15, which expects C 8
```

**Grids and lists exist only under `GUI ON`.** Under `GUI OFF` a `GRID` or `LIST` field
specification fails with BR error 852, and a `grid` step says so. A failed `grid` or `list` check
prints the whole table. A program can switch mode itself: the `orders` example's procedure runs
`CONFIG GUI ON` before it opens the channel, so it uses the standard user-mode configuration.

### 4.6 Message boxes

**A message box stops the program, and keys cannot reach it.** `MSGBOX` shows the platform's
own dialog, which reads the system's keyboard, so `type` and `press` go nowhere while it is up and
nothing on the screen changes. `msgbox` checks that a box is open and `answer` presses one of its
buttons; the program then receives the value that button gives, exactly as if a person had pressed
it:

```
press ENTER
msgbox "Overwrite ORDERS?"
answer YES
expect "Saved"
```

When a check fails because a box is open, the failure says so and names the box. A box still open
when the script ends is a failure of its own, because the program is stopped in it and BR cannot
end.

**BR's own permission question is never answered from a script.** With `GUI OFF`, BR asks the
person in a message box before a shell command runs while an assistant is attached. `msgbox`
reports it, as *BR's own permission question*, and `answer` fails with error 18 whatever the
grant: a test that could answer it would be granting itself the permission. `press BREAK`
interrupts it instead: the command does not run and the program halts at that line.

### 4.7 Suites and baselines

```
br_mcp_driver uitest --suite [<dir>] [<name>...] [--timeout S] [--out DIR]
                     [--update-baselines] [--restore DIR] [--config F] [--br PATH]
```

**A suite is a folder of pairs**: `<name>.uis` and the `<name>.prc` that starts the program it
tests, by default `context\app\tests`. Each pair runs as `uitest --start <name>.prc <name>.uis`
would, in a BR of its own, so one test's leftovers cannot reach the next. Name tests after the
folder to run only those. Each test has a `--timeout`, 300 seconds unless given; `--restore` puts
the test data back before every test.

**The results go to `--out`**, by default `<dir>\results`: `<name>.log`, the test's whole output,
and pictures of the screen at its first failures. The run ends with one line a test and a summary,
and exits 0 only if every test passed:

```
pass  order_entry               18 checks,  0 failures,    6.6s
FAIL  customer_lookup           8 checks,  1 failures,   10.0s

suite: 2 tests, 1 passed, 1 failed
```

**A baseline is the screen as text**, one row a line, trailing blanks and empty rows ignored.
`expect screen orders.txt` compares the screen with that file, beside the script. **The first run
writes it** and passes, saying so: look at the file, and keep it with the test. A mismatch prints
the rows that differ and keeps the screen as found, in `--out` or beside the baseline as
`<file>.actual`. After a deliberate change to the screen, `--update-baselines` rewrites every
baseline the run reaches.

### 4.8 The program's own error window

**`expect no error` hears only errors BR shows itself.** A program with its own `on error goto`
block catches the error first and shows a window of its own, and the channel hears nothing. Name
that window's text once, in `uitest.settings` in the scripts' folder:

```
# what this application's error window says
trap "occurred at line"
```

`uitest` reads it before every script in that folder, as a suite or alone, and reads the screen
after every step and once at the end. Any trap text on the screen fails the test, once each time
the window appears, with the row it is on:

```
FAIL  3: the program's own error window is up: "Error 704 occurred at line 110" (trap "occurred at line", from uitest.settings)
```

After `press` or `answer` the check first waits, up to two seconds, for the program to ask for
input again, so a window that appears a moment after the key is not missed. A run in which it
never appeared ends `ok    end: the program's error window never appeared`.

In a script, `trap "text"` adds one for that script, and `trap none` turns them off, for a test
that means to cause the window and then `expect`s it. The next script starts from the settings
again.

### 4.9 Test programs: `brtest`

For a library function or anything else with no screen, a **test program** is cheaper than a
screen script: an ordinary BR program that links the kit's assertion library and says what each
result should be.

```
00010    library "context\dev\ai_access\brtest": fnTestOk,fnTestEq,fnTestNum,fnTestNote,fnTestDone
00020    library "glp\fy_calcs": FNCCYY
00030    let fnTestNum(FNCCYY(99),1999,"FNCCYY(99)")
00040    let fnTestEq(uprc$("acme"),"ACME","uprc$")
00050    let fnTestDone
```

| Function | Checks |
|---|---|
| `fnTestOk(condition, what$)` | the condition is true |
| `fnTestEq(got$, want$, what$)` | the strings are equal, trailing blanks ignored; a failure shows both |
| `fnTestNum(got, want, what$ [, tolerance])` | the numbers are equal, to within 0.000001 or the tolerance |
| `fnTestNote(text$)` | nothing: a line in the output, saying what a test was doing |
| `fnTestDone` | the last line; a program that never calls it has failed |

Run it headless:

```
br_mcp_driver brtest <name>.test.brs... [--config F] [--br PATH] [--timeout S]
```

Each program runs in a BR of its own under `$BR_AI_UTIL` (the kit's `brconfig.ai_util` when that
is not set), so the test data is the redirected copy, as for every AI run. A `.brs` is loaded as
source and run; a `.prc` is run as it is. The output is the program's own lines, and the run fails
when any check fails, and when a program does not reach `fnTestDone`, with BR's reason from the
`LOGGING` file:

```
*** first.test.brs
      ok    trailing blanks do not count
      FAIL  a deliberate failure: got [ACME], expected [ACNE]
FAIL  crash.test.brs: it ended before fnTestDone: Unattended processing terminated by error 0006 ... line 30.  divide by zero
```

A program that waits for input ends at once, with `Input attempted in unattended mode`, and is
reported the same way. The library is `brtest.brs` in this folder; the driver compiles it to
`brtest.br`, with this BR, the first time and whenever the source is newer.

**In a suite**, a `<name>.test.brs` in the folder is a test of its own, beside the screen tests,
with `--restore` before it as before them. `--check-config` names the headless configuration
there.

### 4.10 The data behind the screen: `check` and `record`

A screen saying "Saved" does not prove the record is right. Two steps look at the file itself,
while the script runs, each in a headless BR beside the session under test:

```
check orders_saved.test.brs
record customer key "CH620   BT" CustomerName$="FMHHLGOZ TIPAWE, PRJ." ClassCode=1
record openitem ky2 key "CH620   S0123982" InvoiceAmount=1309.62
record customer key "ZZ999   BT" absent
```

- **`check <program>`** runs a test program (§4.9) and counts its lines as the script's own, under
  the step's line number. The name is from the kit root, or beside the script.
- **`record <file> [<index>] key "<key>" <Field>=<value>...`** reads one record and compares
  fields. `uitest` writes the program from the file's layout in `app/data-model.md`: its path,
  its key files, and each field's type, position and width, so nothing in the step depends on
  knowing the record's FORM. The index is the layout's first unless named (`ky2`). The key is the
  whole key, as `KEY=` takes it, and is padded to the key's length. Strings are compared without
  trailing blanks; numbers as numbers, after the field's decimals are applied (`BH 4.2` reads
  `1309.62`). `absent` passes when there is no such record.

A wrong value fails with what the record holds, a field or index the layout does not have fails
before anything runs, and the program a `record` step wrote is kept in `context\scratch\brtest\`
so it can be run again by hand.

### 4.11 A program's variables: `variable`

The harness does not expose a program's variables, on purpose. BR's own `DISPLAY` watch does, with
no harness and no debugger: given in the procedure after `LOAD` and before `RUN`, with its output
sent to a file, it writes one line each time the variable changes, and the program neither stops
nor shows anything.

```
LOAD context\app\tests\orders.brs source
DISPLAY CODE$ >context\scratch\watch\code.txt
DISPLAY TOTAL >context\scratch\watch\total.txt
RUN
```

```
variable CODE$ "ACME"
variable TOTAL 42
variable CODE$
```

The step reads every file in the watch folder (`--watch`, `context\scratch\watch` unless given),
by the variable each line names, so the files may be called anything. A string is compared
without trailing blanks, a number as a number. A failure shows every value the variable took and
the line that set each; a variable no file watches fails with the `DISPLAY` line that would watch
it. With `--start`, the folder is emptied before BR starts, so an earlier run's values cannot pass
a new test.

Watch one variable a file: a second `DISPLAY` to a file already open is error 4148. Watch an array
an element at a time, `DISPLAY LIST$(2) >...`; a whole array is error 1070.

**To read a value at one moment, stop the program from the script.** With the channel opened in
`DEVELOP` mode, `MSG("harness", <port>, "DEVELOP")`, the break key goes in at once, even while the
program runs, and what is typed then reaches BR's prompt:

```
press BREAK
type PRINT "N="&RTRM$(NAME$)
press ENTER
expect "N=ADA"
type GO
press ENTER
```

`GO` takes the program on from where it stopped. Mark the printed value, as `N=` does here, so
the `expect` cannot match the same text elsewhere on the screen.

### 4.12 Printed output: `expect print`

A report is checked by what it prints. BR's `PRINTDIR` keeps a copy of every print file the
program spools, named `<program>.<channel>`, and `RAW` keeps it as the program wrote it, without
the printer's escape codes. Turn it on in the test's procedure or configuration:

```
CONFIG PRINTDIR context\scratch\print +CHANNEL RAW
```

`expect print report.txt` compares the newest capture with that baseline, beside the script, and
`expect print agedtbal.20 report.txt` names the capture. As with `expect screen` (§4.7), the first
run writes the baseline and passes, saying so; `--update-baselines` rewrites it; a mismatch prints
the lines that differ and keeps the capture as found, as `<baseline>.actual`. Lines are compared
without trailing blanks, and a page break is a line of its own, `<page>`. A capture that never
appears fails within `--settle` seconds, naming what was printed.

**Mask what changes from run to run.** `mask "<regexp>"`, as many as needed after the files,
replaces each match with `~` in both, so a clock or a workstation number still compares:

```
expect print report.txt mask "\d\d:\d\d:\d\d" mask "WSID +\d+"
```

**Fix the date instead of masking it.** BR's `DATE` and `TIME` commands in the procedure, before
`RUN`, set the session's date and clock:

```
DATE 03/15/24
TIME 09:30:00
```

`--print-dir` names the capture folder, `context\scratch\print` unless given; `--start` empties
it first. A program that previews its print, or asks for a printer, waits for a person; its test
configuration sends print straight to the spool instead, for example with `SUBSTITUTE preview:
DIRECT:`.

### 4.13 Two sessions at once: record locking

A lock is tested with two sessions: one holds a record while the other tries it. In a suite, a
pair is `<name>.a.uis` and `<name>.b.uis`, each with its own `<name>.a.prc` and `<name>.b.prc`,
run together as one test, each in a BR of its own. The two scripts take turns:

```
# lock.a.uis                        # lock.b.uis
expect row 0 "A HOLDS RECORD 1"      expect row 0 "B READY"
signal held                          await held 90
await sawlock 90                     press ENTER
press ENTER                          expect "RECORD 1 IS LOCKED"
expect "A RELEASED"                  signal sawlock
signal released                      await released 90
press ENTER                          press ENTER
wait end                             expect "B GOT RECORD 1: THE RECORD"
                                     press ENTER
                                     wait end
```

A signal, once given, stays given, so an `await` after it returns at once. Every line of the
output is tagged `[a]` or `[b]`, and the pair passes only if both scripts do. `--restore` runs
once, before either half: the two share their data.

Two things the procedures need:

- **Both open the channel in `DEVELOP` mode**, `MSG("harness", <port>, "DEVELOP")`, with ports of
  their own. A user-mode channel raises the AI-user-mode flag, and a BR that starts while it is
  up runs restricted, to files it made itself, so the second session could not open the first
  one's file for update.
- **B starts once A has claimed its channel.** The suite does this: two sessions starting
  together overwrite each other's token file.

A `READ` waits for a locked record for as long as the channel's `WAIT=` says, set at `OPEN`, 15
seconds unless given. A program that is meant to find the record locked opens it with `WAIT=1`,
or the test takes that long.

### 4.14 Recording a draft script: `--record`

```
br_mcp_driver uitest --record orders.uis [--record-for S] [--feed "..."]
                     [--start <proc> --config F ...]
```

The recorder holds the channel and watches while a person uses the program in its BR window.
At each point the program waits for input, it writes what is new on the screen as `expect` lines;
when the program moves on, it writes the field's new value as `type`, then a `press`. When the
session ends, or after `--record-for` seconds (an hour unless given), it writes `wait end`:

```
expect "GREETING TEST"
expect "Your name:"
type ADA
# a key ended the field here; ENTER is assumed - check it
press ENTER
expect "Your name:  ADA"
expect "Hello ADA"
```

**A draft, not a test.** The channel never reports the keys a person types, passwords included,
so the key that ended each field is unknown, and every `press` says `ENTER` with a comment, to be
corrected to the real key (`F10`, `F9`...). A field the program clears as it moves on leaves no
value, so its `type` is missing. A wait at a hot-key label or a border is noted as a comment, not
typed. Then cut the `expect` lines down to the ones that matter: the draft names everything that
changed.

**`--feed "CH620{F10}{F9}{F9}"`** stands in for the person: at each wait it sends the next piece,
text and then a key, and the draft states those keys exactly. It needs the grant, as `type` does.
A draft recorded with a feed replays as it is, which is how the recorder is tested.

## 5. The tools

These are the tools an assistant gets through `connect`. `br_mcp_driver tools` prints the current
list with each tool's full description. **The descriptions carry every limit, error and refusal**,
so read them rather than guessing.

| Tool | Arguments | What it does |
|---|---|---|
| `guide` | | the server as a whole, in one answer. Call it first |
| `read_view` | `offset` | the screen as shown: live rows and any history the person scrolled back to, each marked `LIVE` or `HISTORY`, then BR's status line as a `STATUSLINE` record |
| `read_history` | `count`, `first` | console output that has scrolled off, newest first. `GUI ON` only (§6) |
| `controls` | | the fields and buttons, with the scancode that presses each |
| `grid` | `control`, `first_row` | the cells of a grid, 200 rows a page |
| `list` | `control`, `first_row` | the rows of a list or combo box |
| `attrs` | | how the screen is painted: highlighted, reversed, underlined, error colours |
| `cursor` | | where the cursor is |
| `field_info` | `control` | what an input field expects: spec (`C 30`, `N 10.2`), picture, lengths, protection. Only while a program waits for input |
| `windows` | | BR's windows, and which can be pictured. Its `cells` flags show whether the session is `GUI ON` or `GUI OFF` |
| `shot` | `mode`, `window` | a PNG of a window: its character cells, or the whole window as Windows draws it |
| `program` | | the loaded program: full path, size, `source` or `object`, `clean` or `edited` |
| `listing` | | the loaded program as BR holds it, written to a file to open — for a chained program, a library, or edited source |
| `grant_state` | | whether the assistant may type, and for how long |
| `pending` | | how many of the assistant's keys are still waiting to go in |
| `release` | | give the keyboard back, discarding queued keys |
| `wait_for_event` | `event`, `seconds` | block until BR reports something, instead of polling |
| `check_source` | `source` or `path` | run `brls -check -sema` on source text or a file, and return its words unchanged |
| `command` | `line` | run one line at BR's console during a turn, and wait for its result (§6) |
| `questions` | | what the session is waiting for an answer to, and where a delivered program will be written |
| `get_layout` | `file` | one data file's record layout from the application's data dictionary |
| `get_reference` | `topic` | the reference for one BR statement or topic |
| `deliver_source` | `question_id`, `source` | give BR a whole program for a question the session opened. Audited first (§6) |
| `send_message` | `question_id`, `text` | give BR a long text for a program to show |
| `run_report` | `program`, `dir`, `procedure`, `config`, `seconds`, `wbserver` | run a program in a restricted session (§7) |
| `report_status` | | how the last `run_report` went, and its exit code |
| `pace` | `ms` | the delay between typed keys. Needs the grant |
| `keys` | `text` | type text. Needs the grant |
| `press` | `scancode` | send one key. Needs the grant |

**Which tool reads the program's screen depends on the session's GUI mode:** `read_view` under
`GUI OFF`, `controls` under `GUI ON`. See [`BR_harness.md` §0](../BR_harness.md#the-one-thing).

**A tool that answers `ERR 4 unknown request`** is one this BR is too old for. The driver
publishes every tool whatever BR it is attached to.

**Writing a program for the session**, the order is `questions` → `get_layout` for every file the
program opens → `deliver_source` → `command` to `LOAD` and `RUN` the path `questions` reported.
Build every `FORM` from `get_layout`, never from field names.

## 6. What an assistant may do

**Reading needs nothing.** Every tool that reads works without a grant.

**Typing needs a grant**, which a person or procedure gives inside the session with
`MSG("grant", <seconds>)`. A negative number lends the keyboard with no expiry; `0` takes it back.
The assistant cannot give, raise or extend a grant (a line it sends that tries is refused with
4166). It can hand one back with `release`.

**Keys go in only while a program is waiting for input.** At BR's command prompt - `READY`, an
ATTN halt or an error - they queue, unless the channel was opened in `DEVELOP` mode, where a typed
line runs as a command, as the person's own would. While nothing is waiting they queue. How the channel was opened decides something else: a user-mode
session (`MSG("harness", port)`) raises the AI-user-mode flag when the assistant connects, so any
BR session started while it is up runs restricted; a `DEVELOP` session
(`MSG("harness", port, "DEVELOP")`) does not. Only BR can choose `DEVELOP` mode.

**`command` needs an open turn.** A turn opens when a person types `AI <text>` and BR waits for
the answer. `command` returns BR's error number for the line (0 for success) and BR's message. It
returns when the work is finished: a `RUN` returns when the program stops.

- **Read the message even when the number is 0.** A program that handles its own error still
  returns 0. A program that ends with `STOP <n>` returns `the program stopped with CODE <n>` in
  the message. That code is the program's own verdict, not a BR error number.
- **Destructive file operations ask the person** at the console: yes, no, or yes for the rest of
  the turn. A refusal is 4167. A grant does not change this.
- **`SYSTEM` with an operating-system command, a spool command, the terminal's shell escape, and
  `EDIT` ask the operator** while an assistant is attached, whoever typed them. A refusal is 4167.
  A site can turn this question off with `OPTION 83` in the configuration file; `CONFIG OPTION 83`
  is refused with 4172.
- **The powerful `CONFIG` operations are refused** with 4168.
- **A turn cannot open over a running program or procedure** unless it set
  `SETENV("AI_TURN_OK","Y")`; otherwise 4169. A line from the assistant cannot set it (4170).
- **Inside a turn, `PROC <file>` pushes**, like `SUBPROC`, so the procedure that allowed the turn
  survives. **`CLEAR PROC` and `CLEAR ALL` end the turn**, and the command returns -1.
- **The `AI` command is refused** from the assistant, with 4171.

**`deliver_source` is audited before anything is sent.** Line numbers must ascend and be unique;
`brls` must report no error; a data-dictionary file may be opened only after `get_layout` for it;
each `FORM` is compared with that layout; and statements a restricted session refuses (`DLL(`,
`SYSTEM` with a command) are refused here. A failed delivery is not sent, and the reasons come
back. A delivery is accepted only for a question a running program opened, so it needs no grant.
BR writes the program to the path `questions` reported; nothing runs it until a person or a
`command` says so.

**`deliver_source` and `send_message` carry printable ASCII only**, up to 256 KB. The driver names
any character it will not send, such as a curly quote or a dash.

**Under `GUI OFF` the console history is withheld.** An application in `GUI OFF` paints its forms
on the console, so the history holds the records the person has looked at. `read_history` is
refused (error 9) and `read_view` returns its `HISTORY` rows blank. The live screen stays
readable. Under `GUI ON` both work normally.

## 7. `run_report`: running a program in a restricted session

`run_report` runs a program a model wrote, after it has passed `check_source` and a person has
approved it. It writes a one-line `loader.prc` into `dir`, starts
`brserver --restricted proc <procedure>` there, and **returns at once**. `BR_report.prc` must
already be in `dir`; the tool refuses to run without it. `report_status` gives the
exit code when the run ends.

A restricted session may write only files it creates, or files under a `WORK` tree that a
`brrestrict.sys` beside BR names. It cannot run `SYSTEM` commands or `DLL(`, and reads only what
that `brrestrict.sys` permits, as every BR session does; with no such file it reads anything. So the
tool needs no grant. Each run is logged by BR to `restricted-<wsid>.log` in
`%LOCALAPPDATA%\ADS`. A `LOGGING` line in the run's configuration is refused.

| Argument | Meaning |
|---|---|
| `program` | the program to run. **It must number its lines from 10 up**: `BR_report.prc` adds lines 1 to 3 as an error trap |
| `dir` | the folder BR runs in, which gets `loader.prc`. Every other name is relative to it. Default: the folder the driver runs in |
| `procedure` | the procedure, relative to `dir`. Default `BR_report.prc`. An absolute path is refused, because BR then sits at the console and runs nothing |
| `config` | a configuration file for the session |
| `seconds` | the time limit, 300 by default. The session is killed at the limit. 0 is refused |
| `wbserver` | the folder of the `wbserver.dat` the site's other sessions share, so the run takes part in their record locking. Not defaulted |

One run at a time; a second while one is running is refused.

**Exit codes**, from `report_status`:

| Code | Meaning |
|---|---|
| `0` | the program ran and ended normally |
| `1` | the program would not load |
| other | BR's error code for an untrapped error (for example 4152, file not found), or the value the program gave `STOP` |

**Read the exit code as a 32-bit number.** A POSIX shell keeps only the low byte, so 4152 reads as
56 there and 605 as 93.

## 8. The standard procedures

| Procedure | Session | Channel | Grant | Started by |
|---|---|---|---|---|
| `BR_dev.prc` | ordinary | `DEVELOP` mode, port 8720 | keyboard, no expiry | `br_mcp_driver start` |
| `BR_user.prc` | ordinary | user mode, port 8721 | keyboard, one hour | `br_mcp_driver start --user` |
| `BR_report.prc` | **restricted** | none | none | the `run_report` tool |

A procedure echoes every line as it runs, comments included, so the comments in these files are
what the operator sees, and they say how to take the keyboard back or send the assistant away.

**`BR_report.prc`** runs `SUBPROC loader.prc`, whose one line is a literal
`LOAD "<program>" SOURCE`. It then adds this trap before `RUN`:

```
 1 ON ERROR GOTO TRAP : GOTO 3
 2 TRAP: STOP ERR
 3 !
```

An untrapped error therefore ends the program with its error number in `CODE`, and the procedure
exits BR with that number. Without the trap, an error would leave the session at `READY` with
nobody to answer it.

To bring up a session of your own for a test, write a procedure that opens the channel, gives a
grant and runs the program: [`BR_testing.md` §4](../BR_testing.md#uitest).

## 9. Modes that call a model: `chat` and `report`

These two modes call a model themselves. Every other mode serves an assistant that already has
one.

### `chat`: answering the `AI` command

```
br_mcp_driver chat [--port N] [--model NAME] [--via api|cli|echo] [--ready-file PATH] [--no-tools]
```

`chat` answers each `AI <text>` typed at the console, printing the reply in the `HILITE`
attribute. A line of the reply that starts with `> ` runs as a command, shown as `[AI] >`. A
program can ask too, with `SETENV("AI_TURN_OK","Y")` then `EXECUTE "AI <text>"`; the reply is fed
to the program as keyboard input. With nothing listening, `AI` fails at once with 4158. Up to two
requests wait behind one in progress; a fourth is refused.

| `--via` | Uses | The model can read the session |
|---|---|---|
| `api` | an API key | yes, with the reading tools, unless `--no-tools` |
| `cli` | the Claude Code CLI's own claude.ai login (`claude auth login`, done once by a person) | no, prose only |
| `echo` | nothing; answers locally | n/a |

Without `--via`, the driver uses `api` if there is a key, and otherwise `cli`. It says which it
used when it starts. A turn has 100 seconds and twelve passes; BR's console gives up at 120.

**The API key** comes from `ANTHROPIC_API_KEY`, or from the Windows Credential Manager, never from
a file. To store it:

```
cmdkey /generic:br_mcp_driver /user:api /pass
```

`/pass` with no value asks for the key, so it stays out of the shell history. Do not store a
`claude setup-token` token there: it is not an API key and fails with a 401.
`ANTHROPIC_BASE_URL` sends requests to a gateway instead.

`--ready-file` is written once `chat` is listening and removed when it exits, so a BR program can
tell when someone may type `AI`.

### `report`: writing a program for an application

```
br_mcp_driver report [--port N] [--kit DIR] [--model M] [--echo] [--once] [--ready-file PATH] [--quiet]
```

An application asks with agentlib's `FNAGENT_CODE`, which opens a question with
`MSG("agentask", id$, "CODE")` and announces it with a `NOTE`. `report` reads the question off the
screen, writes the program with the model, and answers with one `SOURCE` delivery. It runs
nothing: agentlib's `FNAGENT_SHOW` asks a person to approve the program, and `run_report` runs it.

The model gets three tools: `get_layout`, `get_reference`, and `check_syntax`, which runs `brls`.
Its first pass must call one of them. The same audit as `deliver_source` (§6) applies, and also
refuses a program that opens the application's own data for output or update. It needs an API
key; `--echo` returns a canned program and calls no model.

**Start `report` before the program asks.** A question announced while nothing is listening is
lost, and the program waits out its own timeout. `report` retries its connection for 60 seconds,
so it can be started first, and `--ready-file` tells a program when it is listening.

## 10. Error numbers and exit codes

| Number | Where | Meaning |
|---|---|---|
| `ERR 4 unknown request` | any tool | this BR is older than the driver |
| 9 | `read_history` | refused under `GUI OFF` (§6) |
| 4152 | a run | file not found |
| 4158 | `AI` | nothing is listening for it |
| 4166 | a line from the assistant | it tried to change its own grant |
| 4167 | `command` | the person refused the question |
| 4168 | `command` | a `CONFIG` operation that is refused while an assistant is attached |
| 4169 | `AI` | a program or procedure is running and did not set `AI_TURN_OK` |
| 4170 | `command` | the assistant tried to set `AI_TURN_OK` |
| 4171 | `command` | the assistant tried to use the `AI` command |
| 4172 | `CONFIG OPTION 83` | the option can be set only in a configuration file |
| -1 | `command` | the turn ended before the result was known (`CLEAR PROC`, `CLEAR ALL`) |
| 2108 | typed `SYSTEM` | a program is active, paused at an error; type `CLEAR PROC` first (§4.2) |

Driver exit codes: `uitest` 0, 1 or 2 (§4); `testdata check` 1 when the folder differs from its
snapshot (§4.3); `run_report` through `report_status` (§7). Other modes exit 1 on an error, with
the reason on stderr.

## 11. Further reading

In this folder:

- [`AI-Access-Protocol.md`](AI-Access-Protocol.md) §5: the protocol itself — every request,
  record and error.
- [`AI-Access-Summary.md`](AI-Access-Summary.md): what the facility is, for a reader who will not
  implement it.
- [`AI-Restricted-Operations.md`](AI-Restricted-Operations.md): what a restricted session may and
  may not do.

If anything here disagrees with what a tool actually does, the tool is right. Record it in
[`ERRORS.md`](../../ERRORS.md).
