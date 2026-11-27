---
alwaysApply: false
---

# Testing a BR program

**Read this when you have changed a BR program and need to show that it works.** It picks the way
to test and gives the commands for each. The details are in the files it links to.

Run every command here from the kit root (the folder that holds `context/`), with the variables of
[`BR_launch.md`](BR_launch.md#br-launch-environment) set. In Windows, use PowerShell or cmd, not
Git Bash: a POSIX path handed to `PROC` fails with error 4215.

## 1. Pick the way

| What you need to show | Way | Pass or fail is |
|---|---|---|
| The program compiles | [§2 Check](#check) | `brls` reports no error |
| A program with no screen does its job | [§3 Headless run](#headless) | the files it writes, and the `LOGGING` file |
| An interactive program, given set answers, does its job | [§3 Headless run](#headless), with proc-fed input | the same |
| A library function returns what it should | [§3.1 Function tests](#function) | `brtest` exits 0 |
| A screen shows what it should, and still does after the next change | [§4 UI script](#uitest) | `uitest` exits 0 |
| A report prints what it should; a variable holds what it should; two users meet a lock | [§4.3 Beyond the screen](#uitest-more) | `uitest` exits 0 |
| You want a first script without writing it | [§4.3](#uitest-more), `uitest --record` | a draft to correct, then the above |
| You need to watch, explore or debug a running screen | [§5 Live session](#live) | what you see; not a repeatable test |
| The same, from a shell with no MCP connection: look at the screen, type a command, look again | [§5, from a shell](#live-shell): `read screen`, `send keys` | what you see; not a repeatable test |
| A program a model wrote runs safely | [§6 Restricted run](#restricted) | the exit code from `report_status` |

Always do §2 first. The other ways cost a BR start, and a syntax error wastes it.

<a id="check"></a>
## 2. Check

```
"$BRLS_EXE" -check -sema program.brs
```

`-sema` catches what a line-by-line check misses, such as an unclosed block. With an assistant
attached, the `check_source` tool runs the same check and takes source text as well as a path.
`brls` does not start BR.

BR's own check is `"$BR_EXE" "LOAD program.brs source" -"$BR_AI_UTIL"`, which stops at the first
error ([`BR_launch.md`](BR_launch.md#compile--syntax-check)).

<a id="headless"></a>
## 3. Headless run

For a program that needs no person at the screen. Use `$BR_AI_UTIL`: it is `UNATTENDED`, so BR
exits when the program stops, and an untrapped error ends the run instead of leaving BR waiting.

```
"$BR_EXE" "RUN glp\trial_bal" -"$BR_AI_UTIL"          # a program
"$BR_EXE" "PROC tmp\run_it.prc" -"$BR_AI_UTIL"        # a procedure
```

To give an interactive program its answers, put `RUN <program> PROC` in a procedure, then one
line per input statement, then `SYSTEM`
([`BR_launch.md`](BR_launch.md#run-a-program-with-proc-fed-input)).

**Judge the result by what the program did, not by the exit code alone.** Check the files it
wrote. In the `LOGGING` file, the line that says a run failed is
`Unattended processing terminated by error <n> while processing...`, which names the error and
the line. Exit code 99 follows any unattended fatal error, so it does not say which. Reading the
log, and the hazards of a headless run, are in
[`APP-DEV-GUIDE.md` §6](APP-DEV-GUIDE.md).

<a id="function"></a>
### 3.1 Function tests

For a library function, write a test program instead of reading output by hand. It links the
kit's assertion library and states each expected result; `br_mcp_driver brtest` runs it headless
and exits 0 only when every check passes and the program reached its end:

```
00010    library "context\dev\ai_access\brtest": fnTestOk,fnTestEq,fnTestNum,fnTestNote,fnTestDone
00020    library "glp\fy_calcs": FNCCYY
00030    let fnTestNum(FNCCYY(99),1999,"FNCCYY(99)")
00040    let fnTestDone
```

```
"$BR_MCP_DRIVER" brtest context\app\tests\fy_calcs.test.brs
```

Name it `<name>.test.brs` and keep it in `context\app\tests\` with the screen tests: a suite runs
both. *Measured:* `fy_calcs.test.brs` checks QSMRP's `glp\fy_calcs`, 9 checks in about a second.
Details: [`ai_access/README.md` §4.9](ai_access/README.md#49-test-programs-brtest).

<a id="uitest"></a>
## 4. UI script

For a screen you want to check now and again after the next change. You write what should be on
the screen, what to type and what should come up. `br_mcp_driver uitest --start` starts BR on a
procedure, runs the script, and checks that BR ended cleanly. It exits **0** when every check
passes, **1** when one fails, and **2** for a usage error. It ends with `<n> checks, <m>
failures`. A failed `expect` prints the screen, and under it BR's status line as an `sl` row, so the
reason is in the output: an error that stopped a procedure is on the status line and nowhere else.
`--ascii` prints a dump in plain ASCII, one character a cell: a window's border as `+---+` and `|`, not
box characters a terminal may not show.

The run fails on any untrapped error BR shows, whether or not the script checks for one, and when
BR does not end or ends with a non-zero exit code.

You need three files: the program under test, a procedure and a script. A complete example ships
in [`ai_access/examples/`](ai_access/examples/) as `greet.brs`, `greet.prc` and `greet.uis`, and
is shown below. *Measured, 2026-11-08*, exactly as shipped: 12 checks,
0 failures and exit 0, and with one wrong expectation, 1 failure, the screen printed, and exit 1.
Both times BR ended on its own with exit code 0.

**The program under test** is an ordinary program. It does nothing for the harness itself:

```
00010    DIM NAME$*20,A$*1
00020    PRINT NEWPAGE
00030    PRINT FIELDS "1,2,C 20": "GREETING TEST"
00040    PRINT FIELDS "3,2,C 12": "Your name:"
00050    RINPUT FIELDS "3,14,C 20,U": NAME$
00060    PRINT FIELDS "5,2,C 40": "Hello "&RTRM$(NAME$)
00070    RINPUT FIELDS "7,2,C 1,U": A$
00080    STOP
```

**The procedure** opens the channel, lends the keyboard and runs the program (its comment lines
are left out here):

```
PROCERR RETURN
LET X=MSG("harness",8751)
LET X=MSG("grant",300)
LOAD context\dev\ai_access\examples\greet.brs source
RUN
SYSTEM
```

**The script**, one step a line, `#` for a comment:

```
expect row 0 "GREETING TEST"
expect "Your name:"
field 0 spec "C 20"
type ADA
press ENTER
expect "Hello ADA"
# the last key lets the program end, so the procedure reaches SYSTEM
press ENTER
expect no error
wait end
```

**The run**:

```
"$BR_MCP_DRIVER" uitest --start context\dev\ai_access\examples\greet.prc context\dev\ai_access\examples\greet.uis
```

It removes a stale token file, starts BR on the procedure with `$BR_AI_USER`, waits up to 90
seconds for the channel, runs the script, and then waits up to 30 seconds for BR to end. The end
of a passing run reads:

```
ok    11: the session ended (the connection closed)
*** the session has ended
ok    end: no untrapped error
ok    end: BR ended, exit code 0

12 checks, 0 failures
```

To start every run from the same data, add `--restore <test data folder>`; see
[§4.1](#uitest-data).

**Tests of the application's own programs go in `context\app\tests\`**, never in
`ai_access\examples\`, which holds only the kit's examples. Copy the example procedure and script
there, name them after the program under test (`trial_bal.prc`, `trial_bal.uis`), change the
`LOAD` line, and write the steps for its screen. The procedure's paths are from BR's start
folder, so it loads the program from where the application keeps it, and the run names the test
files from the kit root:

```
"$BR_MCP_DRIVER" uitest --start context\app\tests\trial_bal.prc context\app\tests\trial_bal.uis --config context\dev\tools\brconfig.ai_test
```

Do not confuse the two folders: `context\app\test\` is the test **data** (onboarding STEP 9), and
`context\app\tests\` is the tests. Like everything under `context\app\`, the tests are the
application's own files and are not part of the kit's repository; keep them in the application's
source control.

What to know about it:

- **The script must drive the program to its end**, and `wait end` says so. If the program is
  still waiting for input when the scripts finish, BR does not end, and `uitest` fails the run
  and then ends BR itself. On a `DEVELOP` channel it types BREAK, PAGE DOWN, `CLEAR PROC`,
  `SYSTEM`; on a user-mode channel, whose keys do not reach the command prompt, it kills BR, and a
  killed BR can leave its workstation slot taken.
- **One connection per session.** To run several scripts against one session, name them all in
  one `uitest` command, in order.
- **The log is cleared for you.** `uitest` and `brtest` delete the configuration's `LOGGING` file
  before the first BR of a run when it is under `context\app\` (the kit's configurations name
  `context\app\startlog.txt`), so a failure quotes this run and the file does not grow without
  limit. A log anywhere else is never touched. A procedure that starts with `CONFIG LOGGING` has a
  log of its own ([`ai_access/README.md` §4.1](ai_access/README.md#41-starting-br-for-the-test)).
- **User mode is enough for a test that drives a program.** Keys go in while a program is waiting
  for input. They do not reach BR's command prompt - `READY`, an ATTN halt or an error - except on
  a `DEVELOP` channel. `DEVELOP` is for a test that types at that prompt, and for a test that
  starts other BR sessions, which a user-mode channel would start restricted (§4.3, record
  locking). How a grant works is in
  [`BR_harness.md` §7](BR_harness.md#typing).
- **A test that provokes an error on purpose** says `expect error <n>`, opens the channel in
  `DEVELOP` mode, `MSG("harness", <port>, "DEVELOP")`, and ends the session from BR's error prompt
  with `type CLEAR PROC`, `press ENTER`, `type SYSTEM`, `press ENTER`, `wait end`.
  `oops.brs`, `oops.prc` and `oops.uis` in [`ai_access/examples/`](ai_access/examples/) are a
  complete example, measured with 11 checks and 0 failures
  ([`ai_access/README.md` §4.2](ai_access/README.md#42-untrapped-errors-and-the-end-of-the-program)).
- **The procedure opens the channel, so `br_mcp_driver start` is not used here.** `start` claims
  the channel itself, and `uitest` would find nothing left to claim.

**The same script works under `GUI OFF` and `GUI ON`.** Under `GUI OFF`, which is how this
application runs, `expect` reads the character cells. Under `GUI ON`, where the cells hold the
Command Console ([`BR_harness.md` §0](BR_harness.md#the-one-thing)), `uitest` reads the
program's controls instead. `orders.brs`, `orders.prc` and `orders.uis` in
[`ai_access/examples/`](ai_access/examples/) are a complete `GUI ON` test, with a grid, a list
and a button: 18 checks, 0 failures, measured 2026-11-08.

**Name fields by their caption** (`field "Customer code:" spec "C 8"`) and buttons by theirs
(`press button "Post"`). Control numbers change when the screen does; captions change only when
the programmer changes them.

The steps:

| Step | What it does |
|---|---|
| `expect "text"` / `expect row N "text"` | the text must be on the screen, or on that row (rows count from 0). Retries for up to `--settle` seconds, 5 by default |
| `absent "text"` | the text must not be on the screen. Does not retry, so `wait` first if timing matters |
| `field "Caption:" spec "C 30"` / `field N spec ...` | the field that caption labels, or control `N`, must expect that spec |
| `field "Caption:" value "ACME"` | the field must show that text |
| `type ACME` | type printable text |
| `press ENTER` / `press F1` / `press 13` | a named key, a function key, or a scancode. Also `SHIFT-UP`, `CTRL-END` and the like |
| `press button "Post"` | press the button with that caption |
| `grid cell R,C "text"` / `grid rows N` / `grid contains "text"` | the first grid's cell (from 0), row count, or any cell. `GUI ON` only |
| `list ...` | the same for a list |
| `pace 300` | milliseconds between typed keys |
| `wait input` / `wait screen` / `wait 2` | until a program asks for input, until the screen settles, or for seconds |
| `expect no error` / `expect error 4152` | no untrapped error so far / that error was shown |
| `wait end` | the session must end, within 60 seconds or the number given |
| `grant?` / `screen` | record the grant state, or print the screen |
| `expect screen orders.txt` | the whole screen must match that baseline file; the first run writes it |
| `msgbox "Overwrite?"` / `msgbox none` | a message box with that text is open / none is |
| `answer YES` / `answer OK tick` | press a button of the open box, ticking "Don't ask again" first |

A failed check does not stop the script, so one run reports everything that is wrong. There are no
variables or loops: a test that needs them is a program, not a script. More about the format, and
the console-history steps, is in [`ai_access/README.md`](ai_access/README.md#4-uitest-a-screen-test-script).

**A message box stops the program, and keys cannot reach it.** When the program under test calls
`MSGBOX`, answer the box with `msgbox` and `answer`; a check that fails because a box is open says
so. BR's own permission question, which asks the person before a shell command runs, is never
answered from a script: `answer` fails with error 18, and `press BREAK` interrupts it.

**Many tests at once: a suite.** Keep each test as a `<name>.prc` and `<name>.uis` pair in
`context\app\tests`, and run them all, each in a BR of its own:

```
"$BR_MCP_DRIVER" uitest --suite --restore context\app\test --config context\dev\tools\brconfig.ai_test
```

Each test has 300 seconds unless `--timeout` says otherwise. The results, with each test's output
and pictures of the screen at its failures, go to `context\app\tests\results`. Details, and
baselines: [`ai_access/README.md` §4.6 and §4.7](ai_access/README.md#46-message-boxes).

<a id="uitest-data"></a>
### 4.1 The same data every run

Every kit configuration already points programs at test data, never live data: a developer's
sample copy, or the area onboarding STEP 9 builds under `context\app\test\`. A test that saves a
record still changes that copy, so the next run would start from different data. Take a snapshot
once, when the data is as your tests expect it, and restore it before each run:

```
"$BR_MCP_DRIVER" testdata snapshot context\app\test
"$BR_MCP_DRIVER" uitest --start <proc> --restore context\app\test <script>
```

The snapshot is `context\app\test.snapshot`. A restore copies back only the files a test changed
and removes the files it added. `testdata check context\app\test` lists what a run changed, which
is also a way to see what a program wrote. Run `testdata` with no BR session using the files.
The details are in [`ai_access/README.md` §4.3](ai_access/README.md#43-test-data-testdata).

<a id="uitest-app"></a>
### 4.2 Testing an application's own programs

Four things an application's programs do that the kit's small examples don't, measured on QSMRP's
`arp\arinq` (`context\app\tests\arinq_open` and `arinq_none` are its tests):

**A program that ends by chaining to the menu never ends the session.** The menu waits for
input, or for the login that a normal start sets up, so BR does not end and the run fails. Give
the tests a configuration that turns that chain into a stub that ends the session:
`brconfig.ai_test` in `context\dev\tools\` is `brconfig.ai_user` plus what a scripted run needs:

```
SUBSTITUTE menu/cnp context\app\tests\endtest
PRINTDIR context\scratch\print +CHANNEL RAW
SUBSTITUTE preview: DIRECT:
SUBSTITUTE /select /default
```

The first line is the stub: `endtest` is a program of one statement, `execute "system"`. The rest
send print to files a test can compare and never to a window it cannot answer: `PRINTDIR` keeps a
copy of every print file, and the two `SUBSTITUTE`s turn print preview and the printer-selection
dialog into plain printing. **Every test of the application's own programs names it with
`--config`**, as the commands above do; a program that prints, run on `brconfig.ai_user`, stops at
the dialog and the run hangs. Like the other two AI configurations, regenerate it when
`brconfig.sys` changes.

**Check the records, not only the screen.** `record customer key "CH620   BT"
CustomerName$="..."` reads a record and compares fields, using the file's layout from the data
model; `check <program>.test.brs` runs a test program of your own at that point in the script. See
[`ai_access/README.md` §4.10](ai_access/README.md#410-the-data-behind-the-screen-check-and-record).

**Keep every configuration in `context\dev\tools\`.** BR reads each `include` from the folder the
configuration is in, then from the application root. A copy anywhere else loads no `subs.txt`, and
BR records that only as `Failed to find brconfig.sys INCLUDE subs.txt` at log level 8, so the
tests run on the data `subs.txt` exists to redirect. *Measured:* a copy in `context\scratch\` ran
`arinq` on the application's own data folders.

**`expect no error` does not see an error the program traps itself.** A program with an `on
error goto` block shows its own error window instead of BR's error, and the channel reports only
untrapped errors. Name the window's text once, in `uitest.settings` beside the tests, and `uitest`
reads the screen for it after every step. In QSMRP the shared `Trap:` block says `Error 0702
occurred at line 56506`, so `context\app\tests\uitest.settings` holds

```
trap "occurred at line"
```

Details: [`ai_access/README.md` §4.8](ai_access/README.md#48-the-programs-own-error-window).

**A program that runs a shell command stops at a question no script can answer.** While a test
is attached, BR asks the person before any `SYSTEM` or other shell command runs, and under `GUI
OFF` the question is a message box. `answer` is refused there with error 18, by design: a test
that could answer it would be granting itself the permission. If the program under test shells
out, the test configuration needs `OPTION 83`, which lets that session run shell commands
without asking. It is read only from a configuration file, never from a program.

**A program that will run only from the menu.** Many programs check, early on, that the menu
started them, and go back to it otherwise: QSMRP's `arp\custafm` quits at line 3990 unless the
menu passed it a security level by `CHAIN` or `LOGNAME` is `root`. A test starts the program
directly, so it fails at once - `uitest` says the channel opened and BR then ended, and quotes the
log. Find the check (search the program's first few hundred lines for a test followed by a `CHAIN`
or `GOTO` to the menu), and satisfy it in the test's procedure, before `RUN`:

```
! custafm quits to the menu unless the menu passed it a security level or
! LOGNAME is root, and a test starts it directly: say LOGNAME is root
LET SETENV("LOGNAME","root")
RUN arp\custafm
```

`SETENV` returns a number, so `LET X$=SETENV(...)` is error 1030; `LET` can call a function
without assigning it, as above. `CONFIG SETENV LOGNAME root` in the procedure is the alternative.
A program that needs a value only the menu sets in its own variables cannot be satisfied this way:
test it through the menu, or ask the program's owner.

**A procedure line that fails leaves the session up.** Under `PROCERR RETURN`, BR stops at the
failed line and waits there, so the program never starts and the script fails at its first
`expect`. `uitest` ends such a session cleanly, and its failure quotes the error. See
[`ai_access/README.md` §4.2](ai_access/README.md#42-untrapped-errors-and-the-end-of-the-program).

**`record` or `check` steps that exit with code 99, in a test that passed before,** usually mean
BR sessions an earlier run left behind. `uitest` warns of them before it starts; end them with
`"$BR_MCP_DRIVER" uitest --cleanup`, and run the test again. The failure quotes the helper's own
log, which says why BR stopped.

**Exploring an unfamiliar screen.** Before writing `expect` lines, run a short script that puts
`screen` after each key, and read what the program shows at each step:

```
expect "Customer"
screen
type CH620
press ENTER
screen
```

Each run starts BR again, so do as many steps as possible in one run. `uitest --record` with
`--feed` writes the same walk as a draft script. To look at a screen many times without a BR
start each time, hold one session and use `read screen` and `send keys` ([§5](#live-shell)).

Two smaller things:

- **Start a script with `expect`.** It says where the program should be, which `wait input`
  does not. A `wait input` first works too: a wait already under way when the script subscribes
  is reported to it.
- **Window borders appear in a baseline as box characters** (`┌─┐│└┘`, `╔═╗`), as BR draws them,
  whatever `GRAPHIC_LINEDRAW` is set to. A baseline written when borders were reported as `Ú`,
  `Ä`, `³` fails against a current BR; write it again with `--update-baselines`. For a dump that
  a terminal may not show, add `--ascii`: the border prints as `+---+` and `|`, and `expect`
  still compares the real characters.

<a id="uitest-more"></a>
### 4.3 Beyond the screen: print, variables, locks, recording

Each is a few lines in the test's procedure and a step in its script; the details are in
[`ai_access/README.md` §4.11 to §4.14](ai_access/README.md#411-a-programs-variables-variable).

- **Printed output.** `CONFIG PRINTDIR context\scratch\print +CHANNEL RAW` in the procedure keeps
  a copy of each print file, and `expect print report.txt` compares the newest with a baseline,
  written by the first run as `expect screen` does. `mask "<regexp>"` hides a clock or a WSID.
- **Fixed dates.** `DATE 03/15/24` and `TIME 09:30:00` in the procedure, before `RUN`, so output
  that prints the date is the same every day.
- **A variable's value.** `DISPLAY TOTAL >context\scratch\watch\total.txt` in the procedure,
  after `LOAD` and before `RUN`, and `variable TOTAL 42` in the script. The program neither stops
  nor shows anything. To read one at a given moment instead, open the channel in `DEVELOP` mode
  and `press BREAK`, `type PRINT TOTAL`, `press ENTER`, then `type GO`.
- **Record locking.** A pair, `<name>.a.uis` and `<name>.b.uis` with their `.prc`s, run together
  by `uitest --suite`, taking turns with `signal` and `await`. Both procedures open the channel in
  `DEVELOP` mode.
- **A first draft.** `uitest --record <name>.uis --start <name>.prc` writes a script while you use
  the program: `expect` lines at every input, and the values typed. The keys are not reported, so
  every `press` is `ENTER` until you correct it.

<a id="live"></a>
## 5. Live session

For watching a program, exploring a screen, or finding out why a script fails. This is not a
repeatable test: you look and decide.

**With an MCP connection**, it is all in [`BR_harness.md`](BR_harness.md), whose §9 is the loop to
follow; starting the session is in [`BR_launch.md`](BR_launch.md#harness-launch).

<a id="live-shell"></a>
**From a shell, with no MCP connection**, `read screen` and `send keys` do the same looking and
typing, one command each. `start` brings the session up and holds it, so run it in the
background, and the other commands reach it from any shell:

```
"$BR_MCP_DRIVER" start                                   # BR on BR_dev.prc; leave it running
"$BR_MCP_DRIVER" read screen                             # the rows, then BR's status line as `sl`
"$BR_MCP_DRIVER" send keys "PRINT 2+3{ENTER}" --read 1   # type, wait a second, read again
"$BR_MCP_DRIVER" send keys "{PAGEDOWN}SYSTEM{ENTER}"     # end the session
```

- **Keys** are typed as written; `{KEY}` is a key, named as a script's `press` names it: `{ENTER}`,
  `{TAB}`, `{F9}`, `{SHIFT-F2}`, `{CTRL-END}` or a scancode. `{{` is a brace. A misspelt key is
  refused before anything is typed. `--read S` waits S seconds after the last key and prints the
  screen, so one command both acts and looks.
- **At `READY`, press `{PAGEDOWN}` first** when the line may hold text left from earlier output:
  it moves that text aside, and without it the new command is typed into the middle of it.
- **`start` gives the keyboard** (`BR_dev.prc`, `DEVELOP` mode, no expiry), so keys reach `READY`.
  In `start --user` they reach only a program that is waiting for input. A refusal that says
  `no grant is held` means BR ran an old copy of the procedure; see
  [§7](#when-something-goes-wrong).
- **`read screen --offset N`** scrolls the view back N history lines, marking those rows `h`;
  **`--ascii`** prints plain ASCII.
- **One client at a time.** While an assistant is attached through `connect` these are refused,
  and a command that follows another waits a few seconds for the service to be free again. Exit
  codes: 0 done, 1 refused or no session, 2 a usage error.
- **They read the console's cells**, so under `GUI ON` they show the Command Console and not the
  program's screen ([`BR_harness.md` §0](BR_harness.md#the-one-thing)).

A live session is one BR start however many looks you take, which is what exploring an unfamiliar
screen needs ([§4.2](#uitest-app)); a repeatable check of what you find is still a `uitest` script.

<a id="restricted"></a>
## 6. Restricted run

For a program a model has written. The `run_report` tool runs it in a restricted session, which
may write only files it creates and cannot run operating-system commands. `report_status` gives
the exit code: 0 for a clean run, 1 if the program would not load, and otherwise BR's error code
or the program's own `STOP` value. The program must number its lines from 10 up. Details are in
[`ai_access/README.md` §7](ai_access/README.md#7-run_report-running-a-program-in-a-restricted-session).

<a id="when-something-goes-wrong"></a>
## 7. When something goes wrong

| You see | It means |
|---|---|
| `FAIL start: no channel within 90s` | the procedure is missing (its path is from BR's start folder) or does not call `MSG("harness", <port>)` |
| `FAIL end: BR did not end within 30s` | the script left the program waiting for input, or the program stopped at an untrapped error (§4) |
| `FAIL end: untrapped error ...` | the program hit an error that no `expect error` accounted for |
| `uitest: could not reach a BR session` | without `--start`: the channel was not open yet, or the token file was stale |
| a `type` or `press` step is refused | no grant; the procedure must call `MSG("grant", <seconds>)` |
| `send keys` says `no grant is held` under `start` | BR found an old `BR_dev.prc` in its start folder, one that gives no keyboard. Copy the kit's again ([`BR_launch.md`](BR_launch.md#the-procedure-has-to-sit-in-brs-start-folder)) |
| `read screen` or `send keys` says `another assistant is already attached` | an assistant holds the session through `connect`; one client at a time |
| `read screen` or `send keys` says `no driver service is running` | `start` or `serve` is not running, or has ended with the session |
| exit 99 from a headless run | an unattended fatal error; the `LOGGING` file names it (§3) |
| error 4215 from `PROC` | a POSIX path, usually from Git Bash; use PowerShell or cmd |

Problems in a live session, including a tool answering `ERR 4 unknown request`, are in
[`BR_harness.md`](BR_harness.md) §1 and §8.

Found anything here that is wrong or unclear? Put it in [`ERRORS.md`](../ERRORS.md) and tell the
user.
