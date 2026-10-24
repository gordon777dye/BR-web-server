---
alwaysApply: false
---

# BR Harness — watching a running BR 5.0 program

**Read this when you need to see what a program is doing while it does it.** Not afterwards,
from a log or a CSV, but the screen the person is looking at, the fields on it, the rows in its
listview, and a PNG of the window.

[`BR_launch.md`](BR_launch.md) is the other half: it is how you compile a file, run a program
headlessly, and **launch the session this file attaches to**
([Live sessions](BR_launch.md#harness-launch)). **This file is for the case a headless run
cannot reach** — an
interactive program, a screen, a form that is waiting for input. The difference is a BR 5.0
facility called the **harness**: a side channel a session opens on its own account, which an
assistant reads and types through while the program runs.

> **Everything below marked *measured* was run on this machine against BR 5.0 and the output
> kept.** Everything else is cited to the authority that states it. Nothing here is inferred
> from how it ought to work — see [AI Model Rules](../README.md) on guessing.

<a id="contents"></a>
## Contents

- [0. The one thing to understand first](#the-one-thing)
- [1. What has to be true before anything works](#setup)
- [2. Starting a session](#starting)
- [3. Attaching to it](#attaching)
- [4. The tools](#tools)
- [5. Seeing a running program — and the trap](#seeing)
- [6. ScreenIO through the harness](#screenio)
- [7. Typing into a screen](#typing)
- [8. What will be refused, and why](#refused)
- [9. A worked loop](#loop)
- [10. Where the authority is](#authority)

---

<a id="the-one-thing"></a>
## 0. The one thing to understand first

**A BR session's GUI mode decides where its screen lives, and therefore which tool reads it.**

| | `GUI OFF` | `GUI ON` |
|---|---|---|
| where the program's screen is | character cells, in the console | native Windows controls, in the application's own window |
| so you read it with | **`read_view`** | **`controls`** |

Get that backwards and you will read a screenful of something else and believe it is the
program's. Under `GUI ON`, `read_view` returns the *Command Console* — which, in a session
started by a procedure, is the procedure's own echoed lines. It is not an error and nothing
warns you.

**How to tell which mode you are in, from here**, without asking anybody: call `windows` and
read the `cells` flag.

| | `GUI OFF` | `GUI ON` |
|---|---|---|
| the `SCREEN` window | `cells` **1** | `cells` **0** |
| the `CONSOLE` window | `cells` **0** | `cells` **1** |

*Measured, both ways round.* `read_history` being refused with error 9 is the other tell, and
a program can be asked directly: `ENV$("GUIMODE")` answers `ON` or `OFF`.

**This application is `GUI OFF`** — every `brconfig` in [`tools/`](tools/) says so. A ScreenIO
application is `GUI ON`, because ScreenIO's listviews cannot exist without it (§6).

---

<a id="setup"></a>
## 1. What has to be true before anything works

**Setting up and starting a session is in [`BR_launch.md`](BR_launch.md#harness-launch)**: the
driver and `brls.exe` in [`ai_access/`](ai_access/), BR itself in [`tools/`](tools/) (which the
driver finds only through `$BR_EXE`, `$BRSERVER` or `--br`), the procedure that has to sit in BR's start folder (the
one that will cost you an hour), the configuration file, and the MCP server entry. Two things
remain here, because you only meet them once you are attached.

### 1.1 The BR build has to be new enough — and a tool existing does not mean BR has it

**The driver and BR are versioned separately, and the driver publishes every tool whether or not
the session can answer it.** A tool whose request this BR does not know comes back as:

```
ERR 4 unknown request
```

**That is the one error that means "the BR build is too old", not "you called it wrong."** No
other error says it, and nothing warns you up front.

*Measured, on a BR 5.0 build six days older than the one beside it:* `windows` and `program`
answered `ERR 4`, and `shot` replied without any of the fields §5 describes. `controls`,
`attrs`, `cursor`, `read_view` and `field_info` all worked on it. So **`windows` — the very
first call §0 tells you to make — is the one most likely to be missing**, and a BR that is
only a little behind looks like one that works.

This is why BR's three files in [`tools/`](tools/) are **replaced together by the build script**
on every x64 Release build ([`BR_launch.md`](BR_launch.md#harness-launch)) rather than left to
drift. You will still meet it after a change built only in Debug, which does not reach `tools/`,
or if you point `$BR_EXE` (or `$BRSERVER`) at a BR of your own.

Two things to do about it:

1. **`start` prints the protocol version** as it claims the channel: `harness claimed on port
   8720, protocol 5`. The same two runs reported `protocol 5` for a current build and
   `protocol 4` for the older one. Treat anything below **5** as "expect gaps".
2. **The version is not the real test — the request list is.** Several requests were added
   without moving the version, because adding one is additive and breaks nobody; the `HELLO`
   answer carries a `REQUESTS` record naming what *this* session offers, and
   [`AI-Access-Protocol.md`](ai_access/AI-Access-Protocol.md) says plainly that this is the list
   to test against and not the number. In practice: call `windows` early, and if it answers
   `ERR 4`, get a newer BR — an x64 Release build, which deploys to `tools/` — before going
   further.

### 1.2 One client at a time

The harness has a single event queue per connection, and `wait_for_event` *takes* an event
rather than copying it. A second assistant is told `another assistant is already attached`.

---

<a id="starting"></a>
## 2. Starting a session

Moved to [`BR_launch.md` — Starting the session](BR_launch.md#harness-launch):
`"$BR_MCP_DRIVER" start`, what `start` and `start --user` each give you
(`DEVELOP` mode or user mode, and no grant or an hour's), and how to end it.

---

<a id="attaching"></a>
## 3. Attaching to it

With the service up, the tools are live. **Call `guide` first** — once, before anything else.
It is 11.6 KB and carries what no single tool owns: the order of operations, the grant and the
turn in full, the ways BR is not the BASIC you remember, the error numbers, and the catalogue
of what `get_reference` and `get_layout` will answer for. The MCP `instructions` field holds a
summary of it and **is cut at 2048 characters by at least one host**, so the summary you were
given may be three-quarters absent. The tool result is not capped.

*Measured, this kit, this machine:* `initialize` → ok; `controls` → the live console;
`get_reference print-fields` → this kit's `PRINT FIELDS` section; `windows` → both windows.

---

<a id="tools"></a>
## 4. The tools

**29 of them, and they are the whole of what you can do** — there is no "run any request" tool
and no escape hatch. Reading costs nothing. Typing needs a grant, which is given *inside* the
session and which you can neither raise nor extend.

### Reading the screen

| Tool | Grant | What it answers |
|---|---|---|
| `read_view` | no | what is on the glass, row by row, each marked `LIVE` or `HISTORY`. Reports where the view sits **without moving it** when called with no offset |
| `controls` | no | every field, button and control: index, type, position, size, protected, which has input, and the scancode that presses it — **the index every other control tool uses** |
| `grid` | no | the cells of a `GRID` (type 11), 200 rows a page |
| `list` | no | the rows of a `LIST` (type 13) — a list box, or a dropped combo |
| `attrs` | no | how the screen is painted, as runs of identically displayed cells |
| `cursor` | no | where the caret is, and which control has input |
| `field_info` | no | what one input field *expects*: its spec (`C 20`, `N 10.2`), its picture, its lengths, whether it is protected |
| `read_history` | no | console output that has scrolled off, newest first — **`GUI ON` only** |
| `windows` | no | BR's top-level windows, and which can be pictured |
| `shot` | no | writes a PNG of one window and answers with its path |

### The program

| Tool | Grant | What it answers |
|---|---|---|
| `program` | no | which program the session has loaded |
| `listing` | no | what that program says, as BR itself has it, written to a file |
| `check_source` | no | syntax- and semantic-check BR source before anything runs it |

### Typing

| Tool | Grant | What it does |
|---|---|---|
| `keys` | **yes** | types printable text |
| `press` | **yes** | sends one key by its BR scancode |
| `pace` | **yes** | milliseconds between the keys this channel types |
| `pending` | no | how many of your keys have not gone in yet |
| `release` | no | gives the keyboard back and discards your queued keys |
| `grant_state` | no | whether you may type, and for how much longer |

### Being told instead of asking

| Tool | Grant | What it does |
|---|---|---|
| `wait_for_event` | no | blocks until BR says something happened — it sleeps on a read, so waiting costs no turns |

### The conversation with a program

| Tool | Grant | What it does |
|---|---|---|
| `questions` | no | what the session is waiting for an answer to, and where BR will write a delivered program |
| `deliver_source` | no | gives BR a whole program, for a question a program opened |
| `send_message` | no | gives BR a long text for a program to show |
| `command` | no* | runs one line at BR's console and **waits for it to finish**. \*needs an **open turn** |

### Reference, from this kit

| Tool | Grant | What it answers |
|---|---|---|
| `get_reference` | no | the authoritative syntax for one BR statement, function or topic |
| `get_layout` | no | one data file's record layout from the data dictionary — **call it for every file a program you write will open** |
| `guide` | no | everything true of the server as a whole (§3) |

### Running a report

| Tool | Grant | What it does |
|---|---|---|
| `run_report` | no | runs a BR program in a **restricted** session; answers at once |
| `report_status` | no | how the last one went, and its exit code |

**Control, grid, list and window indices are positions, not names.** The session rebuilds those
lists as it redraws. One you kept from earlier in the conversation goes out of date without
saying so: an index past the end is refused with error 2, and one naming the wrong kind of
control with error 3. Call `controls` or `windows` again.

---

<a id="seeing"></a>
## 5. Seeing a running program — and the trap

This is the table to work from. **Every row measured on BR 5.0**, on one hand-built screen —
two captions, two input fields (`C 20` and `N 10.2`), a button, a 10-row grid and a 3-row
list — run twice through the same configuration file with nothing different but `gui off` /
`gui on`.

The screen, the driver and both runs' raw output are kept in
[`../scratch/hprobe/`](../scratch/hprobe/), with its own `README.md`. **Re-run it rather than
trusting this table** if anything about BR's screen handling has changed since:
`python hprobe.py off` and `python hprobe.py on`.

| | `GUI OFF` | `GUI ON` |
|---|---|---|
| **the program's text** | `read_view`, `LIVE` rows — the fields are painted into the cells | **`controls`**. `read_view` shows the *Command Console*, which is not the program's screen |
| **control types** | **everything is type 0**, and `console` is 1. You cannot tell a button from a field by type | real types: `6` input field, `5` button, `11` grid, `13` list, `3` static text. `console` is 0 |
| **what a field expects** | `field_info` — answered `C 20` and `N 10.2` | the same, identically |
| **grid and list rows** | **they do not exist.** A `GRID` field spec fails the statement with **BR error 852**, *more variables than fields*, because no grid is made for the matrices to go into | `grid` and `list` — answered all 10 grid rows × 2 columns and all 3 list rows, each cell with its absolute row and column |
| **a picture of the screen** | `shot` with no arguments, or `shot <SCREEN id> CELLS` | **`shot <SCREEN id> COMPOSED`**. `CELLS` is refused, error 10, *that window has no character cells* |
| **a bare `shot`** | the program's screen | the **Console's** cells, not the program's screen |
| **console history** | refused, error 9 — the application paints the console itself, so its history is the session's own past screens | `read_history` works normally |
| **which window has cells** | the `SCREEN` window | the `CONSOLE` window |

Three consequences worth stating on their own:

**1. `field_info` and `cursor` work in both modes, and they are the reliable pair.** `cursor`
names the control BR is taking input for; `field_info` on that index says what it will accept.
Ask before offering a value: a numeric field refuses text and a short field truncates. It
answers **only while a program is waiting for input** — `ERR 4` otherwise, and `ERR 4` for a
control that is not an input field of the waiting statement, which is most of them. That is not
a gap: a field *has* a spec only while the statement that declared it is running.

**2. Under `GUI OFF`, a control's value is what the cells show, not what the program put
there.** A field can be showing text that was on the console underneath it. *Measured, and
conspicuously: on the `GUI OFF` run the probe's own source listing was still on the console, so
rows came back as* `0Customer code:#1, FIELDS "19,1,CC 12,,B42": "Post" ERROR 00940` — the
program's label and a line of its source in the same 80 cells. A real application clears with
`PRINT NEWPAGE` and will not look like that, but the rule stands: never read a control's value
as a variable's value.

**3. `shot` writes the file on the machine running BR**, and BR chooses the name — the no-window
form is `%LOCALAPPDATA%\ADS\harness-shot.png`, a named window gets `harness-shot-<id>.png`
beside it. You cannot pass a path. If you can read that filesystem, **this is the fastest way
to see a screen you do not understand**: take the shot and open the PNG.

---

<a id="screenio"></a>
## 6. ScreenIO through the harness

**ScreenIO renders onto the same BR controls the table above describes** — "the underlying BR
controls ScreenIO renders (grid/list, picture, combo…)", per its own data model
([ScreenIO_Data_Model.md](../br_tree/50-libraries/screenio/ScreenIO_Data_Model.md)). So a
ScreenIO screen needs no new tool and no new idea. It needs `GUI ON`, and then:

| A ScreenIO thing | How you see it |
|---|---|
| the screen as a person sees it | `shot <the SCREEN window's id> COMPOSED` |
| its controls, with ScreenIO's own layout | `controls` — input, search, check, combo and filter controls arrive as input fields; `caption`, `button`, `p`, `frame` as static text and buttons |
| **a listview** | `controls` to find the type 13 (or 11) index, then `list` / `grid` |
| which control has input now | `cursor` |
| what one control will accept | `field_info` on that index |
| a Windows menu bar | `controls`, then `press` its scancode |

**ScreenIO's listviews require `GUI ON`.** That is not a style preference: *measured, a `GRID`
field specification under `GUI OFF` does not make a grid and fails its statement with error
852.* An application whose screens are ScreenIO screens is a `GUI ON` application, and therefore
one where `read_view` reads the Console and **`controls` is how you read the screen**.

> **Not tested against a real ScreenIO screen.** This application does not use ScreenIO yet, so
> there was none to attach to. What is measured is the layer underneath — BR's own grid, list,
> field and button controls, which is what ScreenIO draws with, and `grid`/`list`/`controls`/
> `field_info` reading them. The mapping in the table above is from ScreenIO's documented data
> model to those measurements, and the first person to attach to a real ScreenIO screen should
> confirm it and correct this section.

For how a ScreenIO screen is built, compiled and dispatched, read
[`screenio-guide.md`](screenio-guide.md) and the source-verified reference in
[`br_tree/50-libraries/screenio/`](../br_tree/50-libraries/screenio/). This file is only about
watching one run.

---

<a id="typing"></a>
## 7. Typing into a screen

Typing needs a grant. **A grant is permission, not delivery**: keys go in only while a program
is waiting for input, and queue until one is — except in `DEVELOP` mode, where the console takes
them at `READY` too. `pending` says how many of yours are still waiting, and a non-zero count is
the normal resting state, not a fault.

- **`keys`** for printable text.
- **`press`** for everything else, by BR scancode: `13` Enter, `9` Tab, `7` back-tab,
  `8` Backspace, `27` Escape, `11`/`10`/`14`/`12` the arrows, `23` Home, `5` end of field,
  **`1` Break**.
- **A button is pressed by its own scancode, which `controls` reports.** Nothing on this
  channel clicks. A button declared `B42` reports `10752`, which is 42 × 256; `press 10752`
  does what a click does. *Measured: the probe's button reported 10752.*
- **`press 29` is refused**, error 3 — `Ctrl-]` opens an operating-system shell, and it is
  refused as the key is queued rather than silently dropped later.
- **`pace`** is for a demonstration rather than for filling a form: with no pace the keys go in
  as fast as BR's event loop runs, which is too fast for anybody to follow or interrupt.

**Break is `press 1`, and in BR 5.0 it interrupts — it does not answer anything.** It halts what
is running with no error and `GO` resumes; at a permission question it is not one of the
answers. Do not use it to decline something.

---

<a id="refused"></a>
## 8. What will be refused, and why

**These are the session's rules, not the driver's, and a refusal is usually a person saying no.**

**Every route to the operating system stops and asks the person** while you are attached —
`SYSTEM` with a command, a spool command, the editor `EDIT` launches, the terminal's shell
escape — and the question names the program that would run. A refusal is **BR error 4167**. They
are asked about their own shell calls too, so one of these failing is not evidence that the rule
is about you. The powerful `CONFIG` operations are refused outright, with **4168**.

**A site can turn that off and you cannot tell by looking.** `OPTION 83` in a session's
configuration file means shell calls are not asked about at all — it exists for applications
that start BR sessions of their own. So a `SYSTEM` that simply runs is not a gate that failed
and not an invitation. You cannot set the option: `CONFIG OPTION 83` is refused **4172**
whoever sends it.

**Every destructive file operation inside a turn stops and asks**, grant or no grant, in user
mode *and* in `DEVELOP` — including operations by a program your own `RUN` loaded. 4167 again.

**`command` needs an open turn**, which exists only while the person has typed `AI <text>` and
BR is waiting. Outside one it is refused with harness error 13. A turn cannot open over a
running program unless that program consented by setting `AI_TURN_OK` to `"Y"`; you can neither
set that flag nor ask for it. Inside a turn, `CLEAR PROC` **ends your turn** and comes back
as `-1`.

**In a `GUI OFF` session, a question put to the person goes into a modal message box, and a
modal box stops BR's event loop and the harness channel with it.** Nothing you send will be
read until somebody answers it. If the channel goes silent in a `GUI OFF` session, that is the
first thing to suspect — not a crash.

The 14 harness error numbers are in `guide`. The ones you will actually meet:

| Code | Means |
|---|---|
| 1 | no screen — there is no Command Console to read |
| 2 | no such control — an index past the end |
| 3 | wrong kind of control — a grid read as a list, or the reverse |
| 4 | that control is not an input field of the statement now waiting |
| 5 | refused — no grant is held, so nothing was typed |
| 9 | `read_history` in a `GUI OFF` session; or no such question |
| 10 | that window cannot be pictured in the mode asked for |

---

<a id="loop"></a>
## 9. A worked loop

Watching a program you have just changed:

1. **`check_source`** on the file. It runs `brls -check -sema`, which catches an unclosed block
   that a per-line check will not.
2. Start the session — `"$BR_MCP_DRIVER" start`
   ([`BR_launch.md`](BR_launch.md#harness-launch)) — or, if one is already up, skip to 3.
3. **`guide`**, once.
4. **`windows`** — read the `cells` flags and settle which mode you are in (§0). Everything
   after this depends on that answer. If it answers `ERR 4 unknown request`, stop: this BR is
   too old for half of what follows (§1.1).
5. Get the program running. In `DEVELOP` mode, with a grant: `keys` the `RUN` line and
   `press 13`. Without a grant, ask the person to type it.
6. **`wait_for_event`** rather than polling.
7. When it is waiting for input: **`cursor`**, then **`field_info`** on the control it names,
   then `keys`/`press` a value that fits the spec.
8. To see the whole screen: `read_view` under `GUI OFF`, `controls` under `GUI ON`, and
   `shot ... COMPOSED` whenever you want a picture — then open the PNG.
9. If it stops: **`read_view`** for what is on the glass, and the `LOGGING` file for what BR
   thought. A program that died says more in the log than on the screen.

Writing a program for the session to run is a different loop, and `guide` has it in full:
`questions` → `get_layout` **for every file the program opens** → `deliver_source` →
`command` to `LOAD` and `RUN` → `send_message`. Build every `FORM` from `get_layout` and never
from the field names — a program that opens the right file and reads the wrong columns passes
every check there is and is wrong.

---

<a id="authority"></a>
## 10. Where the authority is

In the order you should reach for them:

| For | Read |
|---|---|
| everything true of the tool server | the **`guide` tool** — call it, do not look for a file |
| the driver: its modes, the tools, the standard procedures, the safety model | [`ai_access/README.md`](ai_access/README.md) |
| the protocol itself — every request, every record, every error | [`ai_access/AI-Access-Protocol.md`](ai_access/AI-Access-Protocol.md) §5 |
| what the facility is, for a reader who is not implementing it | [`ai_access/AI-Access-Summary.md`](ai_access/AI-Access-Summary.md) |
| what a restricted session may and may not do | [`ai_access/AI-Restricted-Operations.md`](ai_access/AI-Restricted-Operations.md) |
| compiling, running a program headlessly, and launching a harness session | [`BR_launch.md`](BR_launch.md), [Live sessions](BR_launch.md#harness-launch) |
| BR's two GUI modes | [`br_tree`](../br_tree/20-io-screen/windows-cursor/spec.md#gui-console) |
| ScreenIO: building, compiling, dispatching | [`screenio-guide.md`](screenio-guide.md), [`br_tree/50-libraries/screenio/`](../br_tree/50-libraries/screenio/) |

**The copies under [`ai_access/`](ai_access/) are copies.** The authority is `br/docs/` and
`br/mcpdriver/` in the BR source tree, and a copy here can fall behind one — if something in
them contradicts what a tool actually does, the tool is right and the copy is stale. Say so in
[`ERRORS.md`](../ERRORS.md).

Found anything in this file that is wrong, or ambiguous? Put it in
[`ERRORS.md`](../ERRORS.md) and tell the user, so it can be forwarded to ADS.
