# br_mcp_driver

Everything an agent needs **outside** BR, in one compiled executable.

A customer site may have no Python and no Node, so nothing may need installing there. Go gives one
signed binary with no runtime, and its standard library already has the sockets, the JSON and the
process control this needs — so **this builds with no module downloads at all**. 

## Contents

- [1. Building](#1-building)
- [2. Modes](#2-modes)
  - [2.1 Where chat gets its credentials](#21-where-chat-gets-its-credentials)
  - [2.2 The Windows Credential Manager](#22-the-windows-credential-manager)
  - [2.3 Two ways to reach a model](#23-two-ways-to-reach-a-model)
  - [2.4 The model can look at the session](#24-the-model-can-look-at-the-session)
  - [2.5 `start` — bringing a session up and serving it](#25-start--bringing-a-session-up-and-serving-it)
  - [2.6 `report` — the report writer](#26-report--the-report-writer)
  - [2.7 `uitest` - a UI test script](#27-uitest---a-ui-test-script)
- [3. The tools, which are the safety model](#3-the-tools-which-are-the-safety-model)
  - [3.1 The console history is `GUI ON` only](#31-the-console-history-is-gui-on-only)
  - [3.2 `run_report` — running a program in a restricted session](#32-run_report--running-a-program-in-a-restricted-session)
- [4. Using it from Claude Code](#4-using-it-from-claude-code)
- [5. The standard procedures](#5-the-standard-procedures)
  - [5.1 How `BR_report.prc` loads its program](#51-how-br_reportprc-loads-its-program)
  - [5.2 The trap `BR_report.prc` installs, and what the exit code says](#52-the-trap-br_reportprc-installs-and-what-the-exit-code-says)
  - [5.3 What bounds a restricted session's files](#53-what-bounds-a-restricted-sessions-files)
- [6. Testing](#6-testing)
- [7. Where the protocol is written down](#7-where-the-protocol-is-written-down)

## 1. Building

```
cd br/mcpdriver
go build -o br_mcp_driver.exe .
```

Go 1.21 or later (`go.mod` says 1.21; it is built here with 1.27, the same version
`brls.exe` and `brsafe.exe` use). It cross-compiles to BR's other platforms:

```
GOOS=linux  GOARCH=amd64 go build -o br_mcp_driver .
GOOS=darwin GOARCH=arm64 go build -o br_mcp_driver .
```

The executable is gitignored; the source is not.

## 2. Modes

The first argument picks one.

| Invocation | What it does |
|---|---|
| `br_mcp_driver serve` | hold the harness connection for the whole session and serve MCP on a pair of named pipes |
| `br_mcp_driver connect` | relay stdin and stdout to a running `serve` — what an assistant launches |
| `br_mcp_driver start` | launch BR on `BR_dev.prc`, claim its channel and serve it |
| `br_mcp_driver start --user` | the same with `BR_user.prc`: user mode, keyboard granted |
| `br_mcp_driver watch` | subscribe to events and print them as they arrive |
| `br_mcp_driver chat` | hold the conversation an `AI` line at BR's console starts |
| `br_mcp_driver report` | the report **writer**: answer the questions an application opens by writing BR programs. Running one is the `run_report` tool (3.2), not a mode |
| `br_mcp_driver tools` | print the published tool list and exit, needing no session |
| `br_mcp_driver uitest <script>...` | run UI regression scripts against a session |

**"Assistant" throughout means the program that runs the model and launches `connect` as its MCP
server** — Claude Code, Claude Desktop or an IDE extension. BR's own messages use the word the same
way, as in `another assistant is already attached`, because from a session's point of view the
program and the model it runs are one actor. It is deliberately **not** "editor": `CONFIG EDITOR`
already names the program BR's `EDIT` statement launches, and two of the three assistants are not
editors at all.

**`chat` is the one mode that calls the model itself.** Every other mode serves a model that is
already running elsewhere, as an MCP server does; a person typing `AI` at BR's console has no
model of their own, so the driver becomes the one that asks.

### 2.1 Where chat gets its credentials

Nothing is sent anywhere without one, and the driver always says which it used — reported
*before* the wait for BR, so a key file with a typo in it does not look like a hang.

| Source | How |
|---|---|
| `ANTHROPIC_API_KEY` | the environment, which a BR-launched driver inherits from BR |
| **the Windows Credential Manager** | where a key belongs when it is meant to stay: per account, and not plain text |

**A key is never read from a file.** There were two more sources — `--key-file` and a
`key_file.txt` beside the executable — and they were removed. A key in a file is plain text in a
directory somebody else can probably read; it gets copied with the install and swept into
backups, and the driver had to print a warning every time it used one. The credential store is
the same convenience without any of that, and the environment variable covers the rest.

### 2.2 The Windows Credential Manager

One generic credential, named `br_mcp_driver`, so a person looking through their credentials can
see what it is for and remove it without wondering what else it might break. Put a key there with
the tool Windows already ships — nothing to install, and no command of this driver's own:

```
cmdkey /generic:br_mcp_driver /user:api /pass
```

Give `/pass` no value and it **asks**, so the key never reaches the command line or the shell's
history. The driver reads it through `advapi32`, so the package still builds with no module
downloads.

**It is better than the file, and it is not a vault.** The credential is per Windows account and
encrypted at rest, so the key stops being something a passer-by can read off a shared install
directory. But any process running *as that person* can read it back — which is exactly how the
driver reads it — so it guards against other people and casual copying, not against code already
running as them. The same is true of the store the Claude Code CLI uses, and of every keychain of
this kind.

**`cmdkey` writes the password as UTF-16**, measured rather than assumed, so a key stored that way
comes back with a NUL after every character. The driver detects that and decodes it, and also
accepts a plain-byte blob written by a program calling `CredWriteW` directly. Either works.

On Linux and macOS there is no credential store yet and the other three sources carry the key: the
Keychain would need the `security` command or cgo, and Linux has no dependable answer on the
headless servers BR usually runs on, so rather than choose one badly the driver looks elsewhere.

The file is read forgivingly, because a person writes it by hand: blank lines and `#` comments are
skipped, a trailing newline and surrounding quotes are trimmed, and `ANTHROPIC_API_KEY=sk-...`
works as well as the bare key. The first thing that looks like a key wins, so a file holding notes
and a key is fine. A key from a file beside the executable draws one line of caution, since
anyone who can read that directory can read the key.

`ANTHROPIC_BASE_URL` points the API elsewhere — for a site reaching Anthropic through its own
gateway, and for the stub the tool loop is tested against.

### 2.3 Two ways to reach a model

`--via` picks one; without it the driver takes the first that is available, preferring the API
because that is the path on which the model can *see* the session.

| `--via` | What it uses | Tools |
|---|---|---|
| `api` | a key of your own, one HTTPS request per pass | **yes** — all 27 |
| `cli` | the Claude Code CLI's own claude.ai login, so **no key at all** | no (see below) |
| `echo` | nothing; answers locally, no network call | n/a |

**The CLI path is how a site with a subscription and no API key gets going.** The driver runs
`claude -p --restricted`, which drops the CLI's own Bash, PowerShell and REPL tools, and never
sees the credentials. It is found the way `brls` is: `CLAUDE_CLI`, then beside this executable,
then `PATH`.

**Signing in happens once, outside the driver, and a person does it.** `claude auth login` opens
claude.ai in a browser; if that browser is already signed in it is one approval and no email, and
if it is not, claude.ai signs the person in its own way first. The driver checks the result with
`claude auth status` before it commits to this path, and names who it found:

```
reaching the model through: the Claude Code CLI at ...\claude.cmd
                            (claude.ai, someone@example.com, pro)
```

With nobody signed in it stops and says to run `claude auth login`, rather than letting the first
question typed at BR's console be the thing that discovers it.

**The driver does not sign anyone in, and does not keep a copy of the login.** Doing the browser
approval from inside the driver would mean registering as an OAuth client or borrowing another
program's identity, and the command that does it properly already exists. The credential stays in
the CLI's own store, which is a better place than any file this program could write — in
particular, **a `claude setup-token` token is not an API key** and must not be put where one
goes: it is an OAuth token, so it needs an `Authorization: Bearer` header rather than the
`x-api-key` the driver sends, and it would fail as a confusing 401. Leave it where the CLI put it.

**It is prose only, and that is a boundary rather than a gap.** This path exists for one person:
the one with a subscription, no API key, and no assistant of their own, who wants an answer at
the console.
Anyone who wants a tool-using assistant is already served two simpler ways — `--via api` with a
key, which runs the loop in this one process; or Claude Code itself pointed at
`br_mcp_driver connect`, which is the arrangement this whole program was written for and a better
interface than an `AI` line.

**Giving this path tools was considered and dropped, 2026-10-05.** The obstacle was stated then
as transport — an HTTP MCP server in the driver and a token to guard the port, because stdio MCP
has the CLI spawn the server as its own child. **That part is no longer true:** `serve` and
`connect` supply the transport, so nobody need build one. What stops this path is the channel,
which accepts one client (`harness.cpp`: "the one connection slot"), and the client is the driver
process itself — the one that spawned the CLI. A CLI with tools would be calling back into its own
caller, a nesting that only ever existed because of credentials. **Not a to-do.** If this is ever
revisited, revisit the single-slot rule first — that is what forces the shape.

### 2.4 The model can look at the session

On the API path the driver runs the tool loop itself, declaring the same 27 tools the MCP
server publishes — the definitions are shared, not copied, so the two cannot drift. It already
holds the harness connection, so a tool call costs a request on an open socket rather than a
second process.

The whole turn is budgeted at **100 seconds**, under the 120 BR's console allows before it prints
"the assistant did not answer in time", and capped at twelve passes. When either runs out, every
outstanding tool request is still answered — with the reason — because the API refuses a turn with
an unanswered one, and the model is asked to reply from what it has. `--no-tools` turns the loop
off.

`--ready-file <path>` writes a file once the driver has subscribed and removes it on the way out.
That is what lets a BR program know when it may let someone type `AI`: a question asked before the
driver subscribes is answered 4158, correctly, so it is a race a program cannot win by sleeping.

The model is told to put a line it wants run at the console on a line of its own beginning `> `.
That convention lives in the prompt, not in BR: prose and commands reach BR over two different
requests, so **BR never parses model output**, and a command still needs an open turn — without a
grant it runs in permission mode, where anything destructive stops and asks the person.

**No port is needed.** A running BR session publishes its port beside its token in
`%LOCALAPPDATA%\ADS\harness.token`, so the driver finds its own client's channel. `--port` is for
the case where more than one session is open for the same user.

**But the file is consumed by the first client that authenticates**, and the port is in it, so
`--port` does not let a *second* process attach: a connection needs the token too, and only the
process that already holds it in memory can reconnect. That is deliberate — the token is published
only while the channel is unclaimed — but it means `screen` and then a `serve`, in that order,
cannot both reach one session. The token's lifetime is an open decision.

**Checking BR source is a tool, not a mode.** `check_source` is how a model asks, and there is no
`br_mcp_driver check` command: a person with a source file to check has `brls` itself, and a
wrapper around it only adds somewhere for the wrapper and the tool to disagree. Whatever `brls`
says is passed back word for word, so a model is told exactly what a person would be.

**It takes source TEXT or a path, and text is the one that matters here.** A model that has just
composed a program holds text, and there is no tool on this surface that would write a file to BR's
machine - so a path-only check was a check it could not reach, which is the whole reason the
check-and-fix loop existed only in report mode. `brls -e` takes the program as one argument,
newlines and all, and implies `-check`, so there is no temporary file to write or clean up and
`-sema` still applies: text and path get the same check. Diagnostics name the input `<-e>` instead
of a file. Exactly one of the two arguments is accepted - both is refused rather than resolved,
because a model that sent text and a stale path would have no way to tell which answer it got.

**`brls` is found, never guessed at:** `BRLS` in the environment, then beside this executable, then
`PATH`. A wrong fixed path that silently checks nothing would be worse than a refusal. It is a
separate program that this one does not contain, so **the site deliverable is two files** — put
`brls.exe` beside `br_mcp_driver.exe` and nothing else needs arranging. Without it the driver still
runs and `check_source` alone refuses, naming what is missing.

### 2.5 `start` — bringing a session up and serving it

```
br_mcp_driver start [--user] [--port N] [--config FILE] [--br PATH]
                    [--pipe NAME] [--wait DURATION]
```

**Two arrangements, one shape.** It launches BR on a standard procedure, claims the channel that
procedure opens, and becomes the service — so the assistant's half stays `br_mcp_driver connect`
whichever was used:

| Command | Runs | Session |
|---|---|---|
| `br_mcp_driver start` | `PROC BR_dev.prc` | `DEVELOP` mode, no grant |
| `br_mcp_driver start --user` | `PROC BR_user.prc` | user mode, keyboard granted for an hour |

The only difference is which procedure runs, which is to say `DEVELOP` mode or user mode. Everything
after that is identical.

**It takes no command, and used to.** This began as a general launcher, told what to run, from before
the standard procedures existed. Starting BR on something else is BR's own business and wants no mode
here, so a command now draws a refusal rather than being passed through.

**The plain mode could not simply default to `BR_dev.prc` until that procedure stopped serving
itself.** `BR_dev.prc` used to carry a `SYSTEM` line starting `serve`, and *that* driver claimed the
channel and removed the token file — which is the very thing `start` waits for — so `start` reported a
failure for a session that had come up perfectly, with `serve` running and both pipes open. Measured,
not reasoned about. Moving the serving into `start` removes the second actor rather than sequencing
two.

**A stale token file is removed first.** This waits for a token and then dials it, so one left by a
session that has since died would be found at once, dialled, refused, and the wait would end having
reached nothing. What that can destroy is another session's *unclaimed* invitation — the token is
published only while a channel is unclaimed — and the session it would belong to keeps its secret in
memory and expires the channel on its own schedule.

**What it does not do.** It does not put the channel in `DEVELOP` mode — that is the procedure's own
third argument to `MSG("harness", port, "DEVELOP")`, settable nowhere else — and it does not give a
grant. `BR_user.prc` gives its own; `BR_dev.prc` deliberately gives none, because a development
session usually wants an assistant that reads.

`--config` names the configuration **file**, in full: BR takes the text after the dash as that name,
so `--config mine` asks for a file called `mine`. The startup command this passes beats a
`brconfig.sys` `EXECUTE`, which applies only when no command was given, so a site that has one will
not silently override it.

**Omitted, `--config` falls to `$BR_AI_USER`** — the context kit's own name for the interactive
configuration, which `BR_launch.md` has a developer export before anything else and then writes this
very command as `start --config "$BR_AI_USER"`. **The flag is consulted first**, so it overrides the
variable rather than merely being preferred to it; same for `--br` against `$BR_EXE`/`$BRSERVER`.
The variable is worth honouring because forgetting it is **not loud**: with no configuration named,
BR hunts `brconfig.sys` beside the executable and then in the launch folder and comes up on
whichever it meets first, which is a session with different `DRIVE` mappings and no `LOGGING` — and
that looks like a working session right up until something reaches for a file.

**Whichever of the two supplied it, the file is checked before BR is launched.** `--config` used to
go to BR unexamined while `--br` beside it was checked, so a misspelt one reached BR, which could not
find it either and fell back to exactly that silent default. Being told the name is wrong beats a
session running on the wrong `DRIVE` mappings, so both sources now refuse, naming the flag or the
variable.

**BR is launched detached, and nothing about the session depends on its having been started here.**
Its own process group, so a Ctrl-C in this shell no longer kills the database engine mid-write; no
inherited handles; no process handle kept on this side — see `spawn_windows.go`, which holds the
reasons.

**BR's own output does not come here.** `brserver.exe` is a GUI-subsystem binary with no console
attached: its screen goes to its own window and its diagnostics to the `LOGGING` file. What appears in
the shell this was typed into is this mode's own lines, on stderr — worth saying, because somebody
watching that shell for BR's output waits for ever.

### 2.6 `report` — the report writer

An application asks for a report and a model writes the BR program. The asking is agentlib's and is
unchanged: a program calls `FNAGENT_CODE`, which declares a question with
`MSG("agentask", id$, "CODE")` and announces it with `MSG("notify", "QUESTION <id> <name> CODE")`.
This mode waits on that NOTE, reads the question off the screen where the program put it, writes the
program, and answers with one `SOURCE` delivery.

```
br_mcp_driver report [--port N] [--kit DIR] [--model M] [--echo] [--once]
                     [--ready-file PATH] [--quiet]
```

**The model produces program text and nothing else**, which is why this needs no sandbox: every execution is
on our side. In this mode the approval is a person's — agentlib's `FNAGENT_SHOW` is explicit that
*"nothing in this library runs generated code without it"* — and the program is checked by `brls`
first and run in a restricted session. A model-initiated run has no such approval step and leans on
the restricted session alone; see [5.3](#53-what-bounds-a-restricted-sessions-files) for what bounds one.

It gets three tools and no others:

| Tool | What it does |
|---|---|
| `get_layout` | one data file's record layout: fields, positions, types, lengths, keys |
| `get_reference` | the authoritative reference for one BR statement or topic |
| `check_syntax` | runs `brls -check -sema` and hands back its words verbatim |

**`--kit` names the context kit**, which supplies BR's own reference material; `BR_CONTEXT_KIT` does
the same. The distilled part goes into the system prompt **marked for caching** — about 49,000
characters, identical on every request — and the data dictionary stays behind `get_layout` because
it is half a megabyte over 272 files. The *names* of every file and topic are in the prompt, so the
model knows what it can ask for.

**The site deliverable is two files.** `check_source` and `check_syntax` have no checker of their
own: they run `brls -check -sema` and return its words verbatim, deliberately, so a model is told
exactly what a person running `brls` would be told. `brls.exe` therefore **ships beside
`br_mcp_driver.exe`**, which is the documented arrangement and the second of the three places the
driver looks: `BRLS` in the environment, then beside this executable, then `PATH`. A fixed install
path is never guessed at — a wrong one that silently finds nothing is worse than a refusal — and the
value of `BRLS` is checked rather than trusted, so a stale one is refused here instead of failing
later with the operating system's words. The same helper finds `brserver.exe` for `start` and
`run_report`, under **`BRSERVER` or `BR_EXE`** — two names for one thing because the context kit got
there first, exporting `BR_EXE` in every example a person reads before they ever run this. The first
of the two that is *set* decides, even if what it names is missing: falling through to the other
would quietly run a different BR than the one just pointed at.

**Where `brls` is, is said when the mode starts**, not at the first question. A report writer whose
checker is missing still works — the model is told the source is unchecked and to say so — but it
has lost the check-and-fix loop, which is most of what this mode is for. Not fatal, deliberately: a
refusal would make an unchecked report impossible rather than merely worse. `brls` ships beside the
driver, or `BRLS` names it.

`check_syntax` also carries its own check that **line numbers ascend and are unique**, which
matters because BR resolves a duplicate silently by keeping the last line with that number, so a
duplicate loses a line and says nothing — and it is the mistake a model writing line numbers by
hand actually makes. `brls` now reports both cases itself, so the two agree rather than the
wrapper covering a gap; it is kept because it runs before `brls` is needed and so still fires
when no checker was found.

#### The gates, which are rules rather than requests

The system prompt *asks* the model to look layouts up and check its source. A prompt is not a
constraint, and the gap matters because **a program that opens the right file and reads the wrong
columns compiles clean** — `brls` has no idea what a record looks like, so nothing downstream
catches it. `integrity.go` therefore enforces, and a delivery that breaks a rule goes back to the
model with the reason rather than in front of the person who has to approve it:

- **The first pass cannot answer** — `tool_choice: {"type":"any"}`, so the model must call something
  before it may reply. Only the first, or the loop could never end.
- **A dictionary file opened without its layout read is refused**, naming the file.
- **The `FORM` is checked against the layout** — the data model carries each field's type, position
  and the record length, so a FORM walked against it is checkable. `OPEN #n` gives the file,
  `READ/WRITE #n,USING` gives which FORM belongs to it.
- **The application's own data opened for output or update is refused.** A report reads.
- **Statements a restricted session refuses anyway** — `DLL(`, `SYSTEM` with a command — are refused
  here, where the reason can be given to the model instead of becoming a run-time failure in front
  of the approver.
- **The checker runs on the final source whatever the model did.** "It said it checked" and "it
  checked" look identical from outside.
- **Resending refused source is stopped**, not looped at.

**Conservative on purpose.** A false finding is worse than a missed one, so the FORM walk stops at
the first thing whose stored width it cannot compute — a width held in a variable, which BR allows,
or a `PD` or `PIC` — and says how far it got rather than guessing an offset. It flags an item only
where it starts exactly at a field's start, because a FORM item straddling two character fields is
ordinary. It does not compute total consumed width, because a FORM **cycles** when the variable list
is longer than it; only a single pass overrunning the record length is a certainty. And only a
`brls` **error** blocks — refusing warnings would refuse most real source.

What none of this catches: a FORM that aligns and types correctly but reads the wrong *field* —
`PoNumber` where the report wanted `CustPartNum`, both `C` and both the right width. Only a person
reading the report catches that.

**`--echo` answers with a real but canned program and calls no model**, so the whole loop either
side of the model can be tested with nothing leaving the machine. `--ready-file` is written when the
mode has subscribed and removed when it exits, so a BR program can tell *ready* from *gone* as well
as from *not yet* — a NOTE posted before anyone is listening is a NOTE nobody hears.

**And this mode may be started before BR**, which is the order that is not a race. It retries its
dial for 60 seconds, as `chat` does, so it can be waiting before the session exists and subscribe the
moment the channel opens. That matters because a question is announced once and an event with nobody
subscribed is discarded rather than queued (`harness.cpp`: `if (!(s_eventSubscribed & kind) ||
!s_harnessClient) return;`), so a question asked in the gap is not delayed — it is gone, and the
program waits out its own timeout for a delivery that cannot come.

`test_run` is not built as a tool of this mode. The reason recorded here used to be that a restricted
session "needs a file list naming the test data — a configuration decision", and that was wrong: a
restricted session needs no list to read, and none to write what it creates (see what bounds a
restricted session's files, [5.3](#53-what-bounds-a-restricted-sessions-files)). What such a run does need is a session of
its own, which is `BR_report.prc`'s job rather than this mode's. The check-and-fix loop catches most
of what it would.

### 2.7 `uitest` - a UI test script

A programmer who has just changed a screen wants to say what should be on it and rerun that after
the next change. The UI tests in `br/aiaccess` are one-off Python, each a programme in its own
right; this runs a script instead.

```
br_mcp_driver uitest <script> [<script>...] [--port N] [--settle SECONDS]
```

One step a line, `#` for a comment, and nothing conditional - no variables, no loops. The moment a
test format grows those it becomes a language, and a language needs its own tests; a test that
needs a loop should be Python.

```
# what should be on the order entry screen, and what a bad code does
expect row 0 "ORDER ENTRY"
expect "Customer code:"
absent "Customer not found"
field 0 spec "C 8"
type ACME
press ENTER
expect "Customer not found"
```

| Step | What it does |
|---|---|
| `expect "text"` / `expect row N "text"` | the text must be on the screen, or on that row (rows count from 0) |
| `absent "text"` | it must not be |
| `field N spec "C 30"` | what that control expects, through `FIELDINFO` |
| `type ACME` | printable text; needs the grant |
| `press ENTER` / `press F1` / `press 13` | a named key, a function key, or a number; needs the grant |
| `press SHIFT-UP` / `press CTRL-END` | the shifted arrows and pages, and the history's top and bottom |
| `pace 300` | milliseconds between typed keys |
| `wait input` / `wait screen` / `wait 2` | until a program asks for input, until the screen settles, or just seconds |
| `view offset 1` | where the console history view sits; retries like `expect` |
| `grant?` / `screen` / `view` | record the grant state, dump the screen, or report the view's offset and lines held |

**The shifted keys are named because the console history needs them.** Shift+Up and Shift+PgUp are
how a person enters the history view, and `historyHandleKey()` tests those very scancodes, so
a script that could not send them could not test the feature. They are separate entries rather than
`SHIFT-` composed, because that rule is the *function*-key rule (add 10 to the key number) and these
have scancodes of their own.

**`WHEELUP` and `WHEELDOWN` are for programs that read the wheel, not for the console history.** A
real wheel is taken by `TextWin::OnMouse` and offered to `historyHandleWheel` before it ever
becomes a scancode; a wheel scancode sent from here reaches `historyHandleKey` instead, which has
no navigation case for it, so with `option 44` off it reads as "anything else" and *leaves* the
history where a real notch would scroll. With `option 44` on the wheel is an arrow before it gets
anywhere, and `press UP` is a notch. **Shift+wheel cannot be sent at all** - the shift is read from
the live event rather than carried in the scancode - and nothing needs it: `SCROLLVIEW` moves the
view directly, `SHIFT-UP` is the keyboard way in, and `historyHandleWheel` calls only what the
key path already calls, differing just in how far one notch scrolls.

**`view` reads the offset, not the history's text.** With `GUI OFF` the harness blanks the rows
above the seam - the console there is the application's own screens - so a history script asserts
on where the view sits. That is enough: the offset moves only if there is history to move into, so
`view offset 1` after a `press SHIFT-UP` is itself the proof that the ring was armed and had
something in it. There is deliberately no `view held N`: the ring's budget is bytes, not lines, so an
exact count would be a property of the test data's line lengths.

**Every `expect` retries**, up to `--settle` seconds (5 by default). That one property is what makes
the format usable: a program takes time to paint, so an assertion made the instant the key went in
would fail constantly for reasons nothing to do with the change under test. `absent` does not retry
- a thing that must not appear cannot be waited for - so `wait` first if it matters.

**A failed assertion does not stop the script.** One run reports everything that is wrong rather
than the first thing, and a failed `expect` dumps the screen so the reason is in the output.

**Several scripts in one invocation**, because the harness channel is claimed once: the token is
spent at the handshake and a greeted connection closing closes the channel, so a second run against
the same session cannot get in. A suite is naturally a set of scripts, so the mode takes a set.

Typing needs a grant, which is given inside the session with `MSG("grant", <seconds>)` and cannot be
taken from here. The script says exactly that when a step is refused for want of one.

## 3. The tools, which are the safety model

A model can do exactly what these tools do and nothing else. There is
no "run any request" tool and no escape hatch, so **which tools a mode offers is the main safety
setting** — a shorter list, not a new set of checks. There is one list today, below; `DEVELOP`
mode and user mode differ in what the *session* permits, not in what is published.

**One list, two paths.** The service publishes it to an assistant running on the person's machine;
`chat --via api` declares the same definitions to the Messages API and runs the loop itself. They
are the same `toolDef` values, so a tool cannot exist on one path and not the other.

**And one thing besides the list: `instructions`.** `initialize` answers with a block of text a
host **may** fold into the model's system prompt — the MCP spec says may, and means it. So it
carries only what no single tool owns, and nothing a model must not be without:

- what this server is, and the safety model in a paragraph;
- **the order of operations**, which no description can state because no one tool knows it:
  `questions` → `get_layout` → `deliver_source` → `command` for the path it reported;
- the few ways BR is not the BASIC a model remembers;
- and **the catalogue** — the 49 reference topics and 272 data-file names `get_reference` and
  `get_layout` will answer for.

The catalogue is why it earns its size. `get_reference` takes "a keyword or a topic name": a model
can guess `OPEN` and `SORT`, and has no way to invent a topic called `open-file` or a file called
`accumchh`. It is 3,086 bytes of the 7,086, and it turns two tools from "ask the right question and
you get an answer" into "here is what there is to ask for". With no context kit on the machine it
is replaced by a sentence saying so.

**All of it, and exactly when each piece is sent on each channel, is in
[`br/docs/AI-Prompt.md`](../docs/AI-Prompt.md)** — generated from the built driver by
`makeprompt.py` in this directory, so it cannot claim text the build does not send.

**Every limit, every error code and every refusal stays in the descriptions**, because a host that
ignores the instructions leaves a model holding those and nothing else. `dev/essentials.md` is
deliberately *not* there either: 35 KB on every request, for sessions that mostly drive a screen
and never write a line of BR. Report mode sends it, in full, in a cached block, because every one
of its turns writes a program. What this surface has instead is the short list and one instruction
— call `get_reference` — and then the audit on `deliver_source`, which is what makes the layout
half of that a contract rather than advice.

| Tool | Needs a grant | What it does |
|---|---|---|
| `guide` | no | **everything true of the server as a whole**, in one answer: the order of operations, the grant and the turn in full, the ways BR is not the BASIC a model remembers, and the catalogue of reference topics and data file names. The first call to make |
| `read_view` | no | **the screen**: what is on the glass — the live screen, or the history the person scrolled back to, each row marked `LIVE` or `HISTORY` (history rows blank with `GUI OFF`) |
| `read_history` | no | console output that has scrolled off, newest first — **`GUI ON` only** |
| `controls` | no | the fields and buttons, with the scancode that presses each |
| `grid` | no | the cells of a grid control, 200 rows a page — `controls` lists a grid but cannot show inside it |
| `list` | no | the rows of a list or combo box, the same way |
| `attrs` | no | how the screen is **painted**, as runs of identically displayed cells: highlighted, reversed, underlined, in an error colour |
| `cursor` | no | where the cursor is |
| `field_info` | no | what one input field **expects**: its spec (`C 30`, `N 10.2`), its picture, its lengths, whether it is protected |
| `windows` | no | BR's top-level windows, and which of them a shot can be taken of |
| `shot` | no | a PNG of one window: its character cells, or the whole window as Windows composited it |
| `grant_state` | no | whether the agent may type, and for how long |
| `pending` | no | how many of this agent's keys are still waiting to go in |
| `release` | no | give the keyboard back early, discarding any keys still queued |
| `wait_for_event` | no | block until BR says something happened |
| `check_source` | no | check BR source before running it - **source text**, or a file on BR's machine |
| `command` | no | run one line at BR's console during a turn, and wait for its result |
| `questions` | no | what the session is waiting for an answer to, and where a delivered program will be written |
| `get_layout` | no | one data file's record layout, from the application's data dictionary |
| `get_reference` | no | the reference for one BR statement or topic |
| `run_report` | no | run a BR program in a **restricted** session; answers at once |
| `report_status` | no | how the last `run_report` went, and its exit code |
| `deliver_source` | no | give BR a whole program, for a question the session opened — **audited first** |
| `send_message` | no | give BR a long text for a program to show |
| `pace` | **yes** | the delay between the keys this channel types, in milliseconds |
| `keys` | **yes** | type text |
| `press` | **yes** | send one key by scancode |

Reading needs nothing. Typing needs a grant, which is given **inside** the session by a person —
`MSG("grant", <seconds>)` — and can never be raised from this side. `keys` and `press` go in only
while a program is waiting for input, never at the `READY` prompt, unless the session opened the
channel in `DEVELOP` mode.

**`release` is the one change to a grant an agent can make**, and it needs no grant of its own: it
gives one back, it cannot take one, and it succeeds doing nothing when none is held.

`wait_for_event` is what makes the driver passive: it subscribes on first use and then sleeps on a
read, so a model waits on a socket instead of spending turns asking whether anything changed.

**`deliver_source` does not take the model at its word.** Before anything is sent it runs the
audit report mode has always run: line numbers must ascend and be unique, `brls` must report no
error, a file in the data dictionary may not be opened unless `get_layout` was called for it, a
`FORM` is compared against that layout field by field, and statements a restricted session would
refuse are refused now. A program that fails is not delivered and the reasons go back to the model.
"It said it checked" and "it checked" look the same from outside, and a model that checked and then
edited one line has delivered something nothing ever read. `get_layout` and `get_reference` are
here because that third audit needs them to have been answerable — see §3.4 of
`br/docs/AI-Access-Protocol.md`. With no context kit on the machine, the
dictionary audits are skipped and the delivery's answer says they were.

**Where a delivered program goes.** Nothing here writes a file. For a question a *program* opened,
the program reads the text back and does what it likes with it. For a console turn, **BR** writes
it, to a file BR named, on the machine running the interpreter — `questions` reports that path, and
the only way to use it is to ask for it to be loaded as a command, in front of the person.

**`command` runs one line and waits for it.** It needs an open console turn — a person has typed
`AI <text>` and BR is waiting for the answer — and it answers with BR's own error number for that
line, 0 for success, and BR's message. *Finished* means finished: a `LOAD` of a source file answers
when the last line of it has been read and a `RUN` answers when the program has stopped, so one
call can take as long as the work does. On the wire that is two messages, the request's `QUEUED`
and a `RAN` event; the tool does both, so a model makes one call.

**What a command may and may not do, inside a turn.** Every destructive file operation anything on
that line reaches — including a program its own `RUN` loaded — stops and asks the person at the
console, who answers yes, no, or yes for the rest of the turn; a refusal arrives as BR error 4167.
That happens **whether or not the keyboard has been lent**: a grant buys typing, and it is given
before anybody knows what the assistant will do with it, so it is not consent to a particular
operation. Three routes to the shell **stop and ask the operator** for as long as an assistant is
attached, turn or no turn, and about the person's own calls as much as the assistant's — `SYSTEM`
with an operating-system command, a spool command, and the terminal's shell escape, with the
editor `EDIT` launches alongside them; a refusal is 4167. The powerful `CONFIG` operations are
refused outright instead, with 4168, having no program to name in a question.

**A site may switch the shell question off with `OPTION 83`**, set in a session's configuration
file, for applications that start BR sessions of their own — those would otherwise be stopped
twice over, once by the question and once by the sessions they start coming up restricted. A
`SYSTEM` that runs without a question is therefore not a gate that failed. The option cannot be
set with a `CONFIG` command by anyone (error 4172), and a restricted session is refused it.

**Two commands do not mean inside a turn what they mean at a console**, and both differences exist
to protect the procedure that let the turn happen. A turn cannot open over a running program or
procedure unless that program or procedure sets `AI_TURN_OK` to `"Y"` — see the release notes, *A
turn needs the consent of whatever is running* — and nothing here can set it or ask for it
(a command that tries answers 4170). So:

- **`PROC <file>` pushes**, like `SUBPROC`, rather than replacing the procedure it was sent into,
  which is what `PROC` normally does. Replacing it would destroy the proc that consented.
- **`CLEAR PROC`, and `CLEAR ALL`, end the turn** along with the procedures. The command answers
  `-1` — the turn ended before its result was known — and nothing sent afterwards will run.
- **The `AI` command is refused**, with 4171, `AI NEW` included. A turn's authority is that a
  person typed `AI`; a line of the assistant's that ran it replaced that turn with one of its own,
  and the `ASK` it sent would come straight back to the model that sent the line.

**An error a program died on is reported like any other.** That was not true until 2026-10-13: an
untrapped run-time error never reached the command processor's error path, where a failed command
is recorded, so a `RUN` whose program stopped on a divide by zero answered **0**. An error the
program *handles*, with `ON ERROR` or a trailing clause, is not the command failing and still
answers 0.

**So read the message even when the number is 0.** Handling an error is not the same as having
done the job, and a program says which with `STOP <n>`: a non-zero `CODE` arrives as `the program
stopped with CODE <n>` in the message, with the number left as BR's error code. A `CODE` is the
program's own verdict on its work, so what it *means* is whatever that program documents — it is
not a BR error number and must not be looked up as one.

### 3.1 The console history is `GUI ON` only

`read_history` is refused in a session configured `GUI OFF`, and `read_view` returns its `HISTORY`
rows blank there. The reason is that `GUI OFF` means something quite different from a display
preference: **the application paints the Command Console itself.** Every screen it clears with
`PRINT NEWPAGE` is pushed into the console's history rather than discarded, and `PRINT FIELDS` data
is in the character cells in that mode — measured, in `h_sbdata.py`, after being guessed at twice in
opposite directions. So the ring holds the contents of the forms the session has been through, a
thousand lines of them by default.

None of the reading tools need a grant. That is the whole of it: without this gate an ungranted
connection could read back every record the person had looked at today, having typed nothing and
raised no event anybody would notice. The live screen stays readable, because that is what the
person is looking at and what an assistant is there to help with.

With `GUI ON` the application has window #0 of its own, the Console carries Console traffic, and
the history is what it was always meant to be — so both tools work normally.

`read_view` still *moves* the view with an offset, because moving is not reading: it is how a tool
or a test drives the scrollbar. What is withheld is the text above the seam.

`field_info` answers a different question from `controls`: that one says where a control is and what
it shows, this one says what it will accept. Ask before offering a value — a numeric field refuses
text and a short field truncates. It answers only while a program is waiting for input, because a
field has a spec only while the statement that declared it is running.

`pace` is for a demonstration rather than for filling a form: without it the keys go in as fast as
BR's event loop runs, which is too fast to follow. Pacing is a safety feature as much as a teaching
one — a person who can see what is happening can stop it — and a break key is exempt from it.

> **`--tutor` is gone, as of 2026-10-08.** It published nine of these fifteen and republished
> `read_view` with no arguments, so that a tutor could read the glass and not scroll it, on `serve`,
> `start` and `tools`. **User mode is sufficient**, and a second published list was a second thing
> to keep in step with the first. It took nothing with it: `field_info` and `pace` were built for a
> tutor and are in the list above, BR advertises `FIELDINFO` and `PACE` to every caller, and
> `h_tutor.py` still tests both — it drives BR directly and never used the flag. Nor did BR, which
> was never told: the flag chose a tool list on the driver's side and was never sent, so no session
> could tell a tutor from anybody else. The way to narrow what a model may do is still a shorter
> list, and `mcp.go` says where it would go.

**The two delivery tools need no grant, and that is not a gap.** A delivery is accepted only for a
question a running BR program opened and said what answers it — `MSG("agentask", id$, "CODE")` —
and nothing this driver sends can open one. So the authority is a question a program asked, on a
side the model cannot reach, rather than a permission it holds. Nothing delivered reaches a screen
or a variable by itself either: BR holds it, and the program reads it back a line at a time if and
when it chooses to, so a delivery cannot interrupt the person at the terminal. `deliver_source`
goes into a file the program writes and is never run without a person saying so.

Both carry **ASCII only**, up to 256 KB. The driver checks a body before sending it and names the
character it will not send, because the session refuses one and a body it cannot frame costs the
connection. A model writing prose produces a dash or a curly quote sooner or later.

### 3.2 `run_report` — running a program in a restricted session

A model that has just written a report program, had `check_source` pass it and had a person approve
it needs one more thing: the program run. That is `run_report`, and it is a **tool** rather than a
mode of the driver, because it is not for a person — asking somebody to type a command on the
model's behalf is a worse arrangement than the one the restriction already pays for.

```
run_report  program  [dir]  [procedure]  [config]  [seconds]
report_status
```

The driver writes `loader.prc` into `dir`, starts
`brserver [-config] --restricted proc <procedure>` with `dir` as its working directory, and
**answers at once**. `report_status` gives the exit code when it arrives.

**What makes it safe to hand a model is the session, not a check in the driver.** `--restricted`
means the run may write only files it creates itself, cannot `SYSTEM` a command or `DLL(` native
code, and reads only what the site's `brrestrict.sys` permits. So there is nothing it can do that a
restricted session could not have done anyway — which is why it needs no grant, and why a site that
wants it narrower installs a read list rather than asking the driver for one. `--restricted` is
passed explicitly even though the AI-user-mode flag would usually have done it: the session that
opened the question may have closed between the report being approved and this running.

**It does not approve anything.** Approval is the person `agentlib` asks, inside the session that
opened the question. This tool is what happens after that.

**Every run is logged, and the log is BR's.** A restricted session writes `restricted-<wsid>.log` —
the name is never a caller's choice — in the account's local application directory unless
`--restricted-log=<folder>` names somewhere else. `run_report` passes no such folder, so
a report run's audit trail lands in that default directory alongside the AI-user-mode flag. Give
the tool a `config` whose own `LOGGING` you expect to apply and you will be disappointed: `LOGGING`
is one of the statements a restricted configuration is refused.

Four things it refuses, each because the failure would otherwise be confusing or silent:

| Refused | Why |
|---|---|
| a program numbered below 10 | `BR_report.prc` inserts lines 1 to 3 to arm its error trap, and they must sort first to be the entry point. A program numbering from 1 takes the entry point instead — and then an error in it is **not reported at all**. The one silent failure in this path, so it is checked. |
| an absolute `procedure` | measured: BR started on an absolute `proc` name sits at the Command Console and runs nothing, with no error and no exit. Refused here, where it can be explained, rather than passed on to hang. |
| a second run while one is in flight | the program's name reaches BR through one `loader.prc` in one directory, under that one name, so a second run would replace the first one's program. |
| `seconds` of 0 | a report session has nobody at it, so a program that loops or waits for input waits for ever. 300 seconds by default; the session is killed at the limit and `report_status` says so. |

**One at a time is the driver's own rule, and it covers the case that happens.** One driver serves
one account's channel and a second driver on that account is refused the pipe, so the driver *is*
the boundary. Two *accounts* sharing one application directory would still collide on
`loader.prc`; that wants a per-workstation name inside the procedure, which is left alone
deliberately — it changes a file a site may have taken a copy of.

**The exit code is a 32-bit value, and reading it as one byte will mislead you.** `0` ran, `1` the
program would not load, anything else is BR's own error code or the program's `STOP` value — `4152`,
*file not found*, for an untrapped `OPEN` of a missing file. Windows carries the whole number and
`GetExitCodeProcess` returns it, so the driver reports `4152`; a POSIX shell truncates to one byte
and the same run reads as `56`. That caught me while writing this, which is the reason it is
stated twice.

## 4. Using it from Claude Code

One arrangement, and the assistant's half of it never changes:

```json
{
  "mcpServers": {
    "br": { "command": "C:\path\to\br_mcp_driver.exe", "args": ["connect"] }
  }
}
```

A session is brought up and fronted in one command —

```
br_mcp_driver start --user
```

— and that is what the standard procedures use. An application that wants to invite an assistant on
its own account can still open the channel and start the service itself, which is what
`br/aiaccess/aistart.brs` does:

```
LET X=MSG("harness", 8720)
EXECUTE "SYSTEM -@ -C -W -M br_mcp_driver serve"
```

but nothing in `prc/` does, because a procedure that serves itself and a launcher that waits for the
token are two actors on one channel.

**Why it is split this way.** An MCP server on stdio is disposable by design: the assistant respawns
it when its configuration changes, when it crashes, when the assistant reopens. That is normal
operation.
But the harness token is consumed on the first handshake and reopening the channel is deliberately
BR's decision, so a respawned process cannot attach again. The service moves the durable end: it
holds the one harness connection for the life of the session, and the shim the assistant launches holds
no credential, no connection and no state, so it can be restarted for ever at no cost.

**There used to be a second arrangement, and it is gone.** An `mcp` mode served MCP on stdin and
stdout and claimed the channel itself, which gave it **one attempt** — once the token was consumed, a
restarted assistant could not reconnect until BR reopened the channel. That is the limitation `serve`
exists to remove, so keeping a mode that walked into it only invited the wrong configuration. What
remains of it is `br_mcp_driver tools`, which prints the published list without a session, because
that was the one thing the mode could do that `serve` cannot: it connected lazily, so it could answer
`tools/list` with no BR running.

**One client at a time.** The harness has a single event queue per connection and `WaitEvent` takes
an event rather than copying it, so two consumers sharing the connection would steal each other's
events *and* block each other's tool calls for the length of a wait. A second client is told
`another assistant is already attached` instead.

**Two pipes, one per direction** — `<base>.requests` and `<base>.replies`, named from the service's
point of view. A relay reads and writes at the same time, and Windows serialises I/O on a handle
opened for synchronous use, so one duplex pipe let the shim deadlock against itself. Splitting the
directions removes the condition instead of working around it: every handle is only ever read or only
ever written, each is opened one-way at both ends so the kernel enforces it, and no overlapped I/O is
needed anywhere.

**The channel itself is still claimed once.** A greeted agent's connection ending closes BR's
listening socket too, so `serve` stopping means the program must reopen the channel with
`MSG("harness", port)`. That is the point rather than a limitation — what the split removes is the
need for the *assistant's* end to be the thing that claims it.

## 5. The standard procedures

`prc/` holds three procedures, one per arrangement a site wants. They are **procedures and nothing
else** — no companion programs. BR compiles and executes a statement in immediate mode, so
`LET X=MSG("harness", 8720, "DEVELOP")` runs from a proc exactly as typed at the console. And a
procedure is a programming system in its own right — line labels, `SKIP` for conditional and
unconditional branching, `SUBPROC`, looping — which is why `BR_report.prc` can load a program, run
it, interrogate `ERR` and `CODE` afterwards and choose its own exit code without a `.brs` anywhere.
Wanting a decision is not a reason to reach for a program.

**A procedure is its own display, which is why these carry no `PRINT`s.** BR echoes every line of a
procedure as it runs, comments included, so a `!` line is on the operator's screen and a `PRINT`
saying the same thing would say it twice. Only values that have to be computed stay as `PRINT`s —
`BR_report.prc`'s error line is the one example. `PRINT NEWPAGE` sits deliberately after each
header: everything above it has already been echoed and is cleared by it, so the notes for a reader
stay off the screen of somebody who just wanted a session. `PROC NOECHO` would hide lines instead,
and `PROC ECHO` turn them back on, if a site ever wants that control inside a procedure.

| Procedure | Session | Assistant | Brought up by |
|---|---|---|---|
| `BR_dev.prc` | ordinary | attached, `DEVELOP` | `br_mcp_driver start` |
| `BR_user.prc` | ordinary | attached, user mode | `br_mcp_driver start --user` |
| `BR_report.prc` | **restricted** | none | the `run_report` **tool** (3.2) |

**Only the report session is restricted.** `BR_user.prc` is the session somebody *works* in, and a
restricted session may write only files it created — an application doing ordinary record updates is
refused by it. User mode is the restriction there instead: the channel is opened with no third
argument, so the assistant's keys are taken only while a program is waiting for input, never at the
`READY` prompt, and the AI-user-mode flag goes up when it greets, so every session started
afterwards comes up restricted. That contains what the assistant causes to run rather than the
session it is attached to.

**`BR_report.prc` has no channel, no grant and no driver, and that is the design.** The asking
happens in the person's own session — the one `BR_user.prc` set up, where an assistant is already
attached and can see the screen. A session whose only purpose was to prompt for a report requirement
would be a second place for the same conversation. What this session is for is executing the program
that came out of it, with the model's authority ending at the text it wrote.

**What a restricted session cannot do for itself.** Restriction is decided when BR starts, by BR's
own `--restricted`, so no procedure can turn it on for its own session. And a restricted session is
refused `SYSTEM` with a command — *"the shell is outside every gate BR has"*
([command7.cpp](../brs/command7.cpp)) — so it could not start the driver even if it wanted to.
`MSG("harness")` and `MSG("grant")` are both on the restricted permit list
([numfunct.cpp](../brs/numfunct.cpp)), so everything else works unchanged.

**`run_report` passes `--restricted` explicitly** even though the flag would usually have done it
already, because the originating session may have closed between the report being approved and this
being run — and then the flag is down and the session would come up with the run of the place. Slim,
and not worth leaving to chance.

**That choice costs the configured `wbserver.dat`, and the tool therefore takes a `wbserver`
argument.** `WBSERVER` in a restricted configuration is refused *unless* the session was restricted
by the AI-user-mode flag — `restrictedStartupConfigPermits` permits exactly that one keyword for
exactly that one origin ([config.cpp](../brs/config.cpp)). Passing `--restricted` latches the origin
as `SPAWN`, because the command line is read before the flag is looked at, so the session cannot name
its own `wbserver.dat` even when the flag happens to be up. It falls back to the **default** one —
counted, and taking its record locks, apart from every other instance sharing the same application
files. A site that keeps one configured `wbserver.dat` for those instances names its directory in
`wbserver`, and the driver passes `--restricted-wbserver=<dir>`, which is what BR passes to its own
spawned children for the same reason ([wbserver.cpp](../brs/wbserver.cpp)). It is **not defaulted**:
guessing a lock directory is worse than falling back to a documented one.

**No procedure starts the driver any more.** `BR_dev.prc` used to, with a `SYSTEM` line, and that
made it self-sufficient at the cost of putting two actors on one channel: the driver it started
claimed the channel and removed the token file, which is what `start` waits for, so `start` reported a
failure for a session that had come up perfectly. The serving moved into `start`, so each procedure
now only opens the channel — `BR_dev.prc` in `DEVELOP` mode, `BR_user.prc` in user mode — and nothing
inside either session claims it.

### 5.1 How `BR_report.prc` loads its program

A one-line `loader.prc`, written per run by whatever launches the session, holding a literal `LOAD`:

```
LOAD "agent\programmer\sales-20261007-1431.brs" SOURCE
```

`BR_report.prc` reaches it with `SUBPROC loader.prc`. Two things have to be true at once, and that is
the only shape found that gives both:

- **The name must be literal**, because a command operand is not an expression. Measured three ways:
  `LOAD ENV$("BR_REPORT_PROGRAM")` does not read the variable, `LOAD "goo"&"d.brs"` does not
  concatenate, and `LOAD "report.brs"` loads. The quotes in BR's documented form are delimiters round
  a literal name, not a string expression.
- **The failure must be catchable**, which rules out building the command with `EXECUTE`. `PROCERR`
  covers an error in a *procedure command*; an error raised inside an `EXECUTE`d string is not one, so
  BR halts at `READY` and the proc never reaches a `SKIP`. Not a quirk of `LOAD` — a plain `FREE` of a
  missing file is caught, and the same `FREE` wrapped in `EXECUTE` hangs.

`SUBPROC` satisfies both because **`ERR` survives the return**: the `LOAD` inside `loader.prc` is a
plain procedure command, so a bad name sets `ERR`, the subprocedure ends, and the parent's `SKIP`
sees it. Verified restricted and unrestricted.

**One `loader.prc` per run**, so each session gets a directory of its own. Nothing serialises that
name, and two report sessions sharing one would race to read each other's program. `@:` separates
machines rather than sessions, so it is not a substitute — though it does work here: a standalone
(non client/server) session writes `@::C:\...` successfully, the client half being in-process.

### 5.2 The trap `BR_report.prc` installs, and what the exit code says

Three lines go in after the `LOAD` and before the `RUN`:

```
 1 ON ERROR GOTO TRAP : GOTO 3
 2 TRAP: STOP ERR
 3 !
```

Line 1 runs first, arms a trap for the whole program, and jumps clear of line 2 into the program's
own first line. Any untrapped error then lands on line 2, which ends the program with the error code
as its value — and that value arrives in `CODE`, which the procedure reads.

**The program must therefore number from 10 up.** Those three lines have to sort first to be the
entry point, so a program numbering from 1 would collide with them. That is a rule for whoever writes
the program.

**Without the trap, an error in the program could not be reported at all.** `PROCERR` does not reach
inside a running program: an untrapped error halts the program, interrupts the procedure, and leaves
the session at `READY` with nobody to answer it. Measured both ways — without the trap a failing
program hangs until something kills it; with it, the same program exits `605`.

| Exit code | Meaning |
|---|---|
| `0` | the program ran and ended normally |
| `1` | `loader.prc` is missing, or names a program that will not load |
| other | BR's own error code, or whatever the program chose to `STOP` with |

All four verified in a restricted session: `0` for a clean run, an untrapped error arriving as
BR's own code, `42` for a program that traps its own error and ends `STOP 42`, and `1` for a loader
naming nothing. The untrapped case measured `605` — *syntax error in an open string*, not a missing
file as this used to say — in the program used then, and `4152`, *file not found*, in
`h_runreport.brs`, which opens a file that is not there. The code is whatever BR raised; what the
procedure promises is that it arrives.

**Read the exit code as a 32-bit value.** Windows carries the whole number and `GetExitCodeProcess`
returns it, so a driver sees `4152`. A POSIX shell truncates to one byte, which is why the same run
reads as `56` in bash — and `605` reads as `93`. Worth knowing before someone reports it as a bug,
or mistakes the two readings for two different errors.

**A time limit is still wanted, though no longer for errors.** A program that waits for input in a
session with nobody at it, or loops, will sit there — so whatever starts the session should not wait
for ever.

### 5.3 What bounds a restricted session's files

Worth stating plainly, because it is less configuration than it sounds:

- **Writing** is the create-then-own rule and needs no configuration at all: a restricted session may
  create files and then do anything with those, and may change nothing it did not create.
- **Reading** is governed by `brrestrict.sys`, which is **optional**. With none installed a restricted
  session reads by default — *"the widest setting is the one a session has already got"*.
- That file is **not a configuration statement**: it sits beside the running executable, because *"a
  session cannot choose which executable it is, so it cannot choose its list"*
  ([file_os.cpp](../brs/file_os.cpp)). A site narrows a session by installing one there, and nothing
  the driver does can widen it.

## 6. Testing

The tests are in `br/aiaccess`, part of the kit, and they need the kit's junction:
`C:\ADS\qsmrp\context\scratch\aiaccess` must point at `br/aiaccess`, because every file
in the kit names that path internally.

```
cd br/aiaccess
python h_driver.py --platform x64 --config Debug
```

`h_driver.py` covers `watch` and the service, including a full MCP conversation over stdin and
stdout and every tool in the published list. It does **not** cover `start`, which still has no automated test — but the reason
has changed, and it is now worth writing one. While `start` held the connection until BR exited
there was nothing to assert that was not a test of `exec` and of the wait. Now it has a property
worth checking and easy to check: **after `start` returns, the token file is still there and
another mode can attach.** That is one `screen` against the session `start` just made, and it is
the whole of what the mode promises.

Verified by hand on 2026-10-07, and the manual run is what a test would automate: `start` returned
in 3.7 s with the channel open on its port, the token file survived its exit, a second mode then
attached and read the screen, and the token was gone afterwards — spent at `HELLO`, as designed.

`h_driver.py` used to fail nine checks, and not because of the driver: it ran two modes as two
processes, and the harness token is removed as soon as a client authenticates — with the port
published in that same file — so the second process could never find the session. **It now gives each mode its own session**, which was the one option
needing no product change. That also made
`watch` testable, which it had never been. The token's lifetime is still an open decision; nothing
depends on it any more.

chat mode has four tests of its own:

| Test | What it covers | Needs |
|---|---|---|
| `h_chat.py` | the console conversation, with a stand-in assistant the test drives directly | nothing |
| `h_tools.py` | the API tool loop: the tools really declared, the screen really read back, the reply's command really run | nothing — a stub Messages API |
| `h_invite.py` | BR starting the driver itself: `SYSTEM -C`, the inherited key, the ready file, the dismissal | nothing — the same stub |
| `h_clichat.py` | a **real** model through the CLI's own claude.ai login, read back off the console with the screen tee | `--live`, a logged-in CLI, and it costs a turn |

The two stub tests reach the driver through `ANTHROPIC_BASE_URL`, so the loop is exercised with no
key and no network call. Only `h_clichat.py` spends anything, which is why it refuses to run
without `--live`.

report mode has two tests, running a report has one, and the tutor's two requests have one. **`report`
mode writes a program; the `run_report` tool runs one** — different halves, tested separately:

| Test | What it covers | Needs |
|---|---|---|
| `h_report.py` | the whole report loop: agentlib's question, the writer reading it off the controls, the delivery, and `brls` on the program that arrived | nothing — `--echo` calls no model |
| `h_runreport.py` | the `run_report` and `report_status` tools: that the session really is restricted and really writes its own file, that the call returns at once, all four refusals, the time limit, and every exit code the procedure promises | nothing |
| `h_reportapi.py` | the middle of that loop, which `--echo` skips: the request shape, the cached system block, the tool loop, all three tools, the stripping of a fenced reply, and every gate above | nothing — a stub Messages API |
| `h_tutor.py` | `FIELDINFO` against specs the BR program itself wrote, and `PACE` holding keys back | nothing |
| `h_uitest.py` | the `uitest` runner: a script a programmer could have written, and a second one whose every assertion is false | nothing |
| `sbkeys.uis` + `sbkeys.prc` | the console history driven by its own keys, with a listing live: that the listing keeps the plain keys and Shift+Up gets in anyway, the line and page movements, the bottom that stops without releasing the keyboard, that no arrow is a way out, and the typed key that is | `C:\ADS\qsmrp`, and the x64 Release brserver |
| `sbarm.uis` + `sbarm.prc` | the one shot the script above cannot reach: a plain Up straight after something scrolled away, and that it is spent by the next key whatever that key is | the same |
| `h_evcap.py` | the harness's 256-event queue cap and `EVENT LOST`, which needs a megabyte and a half of unsent events to reach | nothing |

**`--echo` returns a canned program before any message is built**, so it proves the parts either
side of the API call and nothing between. `h_reportapi.py` is what covers between: a stub serves a
five-pass conversation — `get_layout`, `get_reference`, `check_syntax` on bad source, `check_syntax`
on good source, then a reply wrapped in a markdown fence — and the test reads the real request to
check the system prompt is sent as a cached block, that only three tools are declared, and that each
tool answered with real content.

A stub is the only way to test the gates, because it can play a model that disobeys — five ways in
one run, each corrected, then a delivery that passes everything. A real model usually will not
disobey, which is exactly why a real one is no test of them.

`h_report.py --live` calls a real model and is the step 7 milestone; it has not been run. What it
would add is how *often* the model obeys unprompted, which the gates turn into a question of cost
rather than of correctness.

**Neither of those tool-count checks is a number written down any more.** `h_tools.py` and
`h_invite.py` used to assert "twelve tools", which went stale the first time a tool was added. They
now ask `br_mcp_driver tools` for the published list and compare, because the claim worth testing is
that chat mode lends that one list rather than keeping one of its own. That mode exists for this:
the old `mcp` server could answer `tools/list` with no session because it connected lazily, and
`tools` keeps the question askable without keeping the mode.

## 7. Where the protocol is written down

`br/docs/AI-Access-Protocol.md` section 5, and `br/docs/harness-formats.json`, which say the same
thing for a person and for a machine. If either disagrees with `br/brs/harness.cpp`, the code is
right. `br/aiaccess/harnessclient.py` is the Python reference this package was ported from, and it
stays as the development machine's test kit.
