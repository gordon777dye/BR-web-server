# AI_ACCESS: two control channels and three authorities

Status, 2026-09-29: **Phase 0 and Tracks A, B and C are complete and verified.** The design and
the record have grown together in this one document, so a section may describe what was planned,
what was built, or a correction to an earlier claim — each says which. Where a `file:line` is cited
it was correct when written; check it before relying on it.

**This is a plan and working document. `AI-Access-Protocol.md` is the published one, and it is
where every message is officially defined** - the user-level channel's requests and events
(section 6), the debugger channel's (section 7), the `MSG` actions a BR program sends (section 8),
and the client/server messages all of it travels over (section 9). What is here is the design, the
reasoning and the measurements: *why* a message has the shape it has, what was tried first, and
what each claim was checked against. Where the two disagree about what something *is*, the
protocol document is right and this one needs correcting; where they disagree about *why*, this
one has the evidence.

Other companions: `AI-Access-Summary.md` (the short account, for someone deciding whether to turn
any of it on) and `AI-Restricted-Operations.md` (what a restricted session may do). Screen-reader
support is a separate concern and lives in `ACCESSIBILITY.md`.

**Nothing in the implementation sequence remains.** What is still open — the retention period, a
narrower `DATABASE` rule, the client/server gaps, an interactive check of the approval prompt — is
listed under "Open decisions" and "Still open".

## Purpose

BR's control reduces to **two bi-directional channels**:

1. **The programmer channel** — at most one debugger attached at a time. The command console stays
   usable alongside it unless `DEBUG CONSOLE OFF` blocks it. The profiler is subservient to the
   debugger.
2. **The user/AI channel** — shared between the human user and an AI agent. Both have full use of
   the keyboard and mouse pointer, on the desktop-sharing pattern: the user has precedence, and
   when the user pauses, the agent can type and move the pointer.

Three things follow from having those channels, and they are the point of the work: 1) an agent can 
watch a real session, including a programmer stepping through a program; 2) an agent can teach a user by 
driving the application; 3) and the application can call the agent as a resource, driven by stored 
prompts, the way SQL is the interface language for stored data.

## Parties and processes

| Party | Process | Owns exclusively |
|---|---|---|
| User | `brclientdll` + `brclientexe` | Screen buffers (`textBuf`, `attrBuf`, `statBuf`), the key ring `keyBuf`, transient copies of the current fields' variables, the window and control tree |
| Programmer, in an editor | the editor/debugger, attached to brserver via tcp | Breakpoints, step state |
| Programmer, at the console | keyboard → brclient → brserver | Console command entry |
| AI agent | reader/driver process | Nothing; it holds only copies |
| The interpreter | **brserver** | The program, the whole variable space, files and indexes, the log, the profiler, the single debug socket |
| (optional) | `brlistener` | Brokering the client↔server TLS connection |

The interpreter is a party in its own right: it holds nearly all state, and in client/server mode
it runs on a different machine from the user.

## Authority: programmer > user > AI

Each rank is enforced by a mechanism, not by convention.

- **Programmer (highest)** holds the programmer channel. A break suspends what the user/AI channel
  is doing. `DEBUG CONSOLE OFF` takes keyboard entry at the prompt away from the console, leaving the
  debugger as the only source of commands and immediate statements; `debugConsoleBlockLinput` is the
  gate. The console is not blocked by attaching alone: without `DEBUG CONSOLE OFF` the console and
  the debugger can both enter lines at the prompt.
- **User (middle)** holds the user/AI channel by default. Revocation of an agent's grant is a
  cancellation rule: when the user takes back the channel, the agent's queued actions are
  discarded, not merely stopped.
- **AI (lowest)** acts only while holding an explicit, revocable grant — except where no user is
  present at all, which is unattended verification.

## What already exists

This document is mostly reinstatement and reuse. Nothing below needs to be written again.

### A BASIC-visible keyboard, mouse and window automation catalog

`MSG(...)` reaches `callMSAGFunction` (`brmsg.cpp:1503`) from BASIC through `DLL`/`MSG_FN` →
`clientDICT` (`fields.cpp:2400`), dispatching the table at `brmsg.cpp:1463`.

**Typing already works, at the device layer — and is measurably indistinguishable.** `send`
(`brmsg.cpp:751`) → `brm_ParseString` (`:705`) → `brm_SendString` (`:666`) emits real `keybd_event`
input: `|KEYNAME|` tokens resolved through `ScLookup` (`:631`, whose table names include the pipes —
`{ "|F5|", VK_F5, 0 }`), plain text through `VkKeyScan` with shift, control and alt pressed and
released around each character (`:677`, `:696-700`).

Phase 0.2 measured it rather than reasoning about it. Plain text and a shifted sequence arrived
verbatim (`HELLO`, and `|SHIFT+|a|SHIFT-|bC` → `AbC`), and **an A/B against a hand-pressed key agreed
exactly**: a hand-pressed F5 and an MSG-sent F5 produced identical results, down to sharing the same
surprise (both gave `FKEY = -1` with an empty field, because BR consumes F5 itself in that context).
Identical behaviour including the surprise is the strongest form the premise could take. **A call takes a whole string**, with key
tokens interleaved, and `BrMsg_SendObjCmd` loops over several arguments — so one call types a whole
field. Per-keystroke calls are not the design: each would pay `brm_CreateString`/`brm_FreeString`
allocation, the `DLL`/`MSG_FN` dispatch and the name lookup in `callMSAGFunction`.

**`sleeptime` does not pace characters, despite its comment.** The sleep sits *outside* the character
loop in `brm_SendString` (`:666-706`): once before a run of plain text, then every character with no
delay. Named keys are paced, because each token is its own segment. A long string therefore arrives as
a burst, which defeats the teaching case — so step A6 moves the sleep inside the loop, one line, making
the action mean what its table comment claims while whole-string calls are kept. Confirmed in Phase 0.2:
eight characters at 500ms filled the field **instantly** to the eye, with the elapsed time accounted
for by the handful of segment-level sleeps rather than by per-character pacing.

**Its argument is milliseconds, not the centiseconds the BR reference states.**
`BrMsg_SleeptimeObjCmd` stores `argument * 1000` and `wb_sleepex` takes microseconds, so `1000` is one
second and the documented "100 = 1 Second" is wrong by a factor of ten. Whoever changes the pacing
should correct the reference page in the same pass.

**The foreground guard worked, and was not optional — SUPERSEDED 2026-09-30, see "Changed
2026-09-30" below; the guard went then, and `kb` itself was removed 2026-10-12.** `kb` was
`send` behind a foreground-window
check for BR's terminal or "Command Console" (`BrMsg_SendNamedObjCmd`, since deleted); with the desktop
focused it refused, returning error 413, "target MSG window not on top" (Phase 0.2b). That requirement
was inherent to synthetic device input rather than a property of `MSG`: `keybd_event` delivers to
whichever window has focus, so the unguarded `send` would not type into an unfocused BR — it would
type into whatever the user was working in. **The agent therefore used `kb`, never `send`**, and work
that must proceed without focus uses the internal `putKeyVal` path instead. Indistinguishable-at-the-
device-layer and works-without-focus cannot both hold; the two modes divide along exactly that line.

Also live: `loop`; `getcb`; `putcb`; `sleeptime`; `restore`; `state`.

Compiled out in two `#if 0` regions: `show`, `topmost`, `notopmost`, `sendmessage`,
`postmessage`, `getpos`, `setpos`, `getwpos`, `setwpos`, `lclick`, `mclick`, `rclick`. The click
handlers were written and used `mouse_event`; only the pointer-move bodies were additionally
commented out inside their own functions. **So the keyboard half of the shared channel exists and
the pointer half is a table edit plus two function bodies.**

**Both halves are now built, and neither is on the device layer any more** — the keyboard came off
it on 2026-09-30 and the pointer on 2026-10-03, each moving to BR's own input. `show`, `topmost`,
`notopmost`, `sendmessage` and `postmessage` remain compiled out deliberately. That the pointer
was "a table edit plus two function bodies" turned out to be true only of *enabling* it; making it
correct — BR's own window rather than the foreground one, BR's own pointer rather than the
physical cursor, and a cell-addressed form an agent can actually aim with — was the larger part.
See "Working off-screen" below and `AI-Access-Protocol.md` §8.6.

Every `keybd_event` call passed `0` as `dwExtraInfo`, and the click handlers echoed
`GetMessageExtraInfo()`: the provenance slot was available and unused. It no longer arises for
either half — neither keyboard nor pointer goes through the operating system's input queue now,
so there is no `dwExtraInfo` to stamp and nothing of BR's for another program to see.
Nothing in the tree installs a `SetWindowsHookEx` hook or calls `SendInput`.

### An arbitrated programmer channel

One debug socket: `DEBUG CONNECT` and `DEBUG LISTEN` both refuse with `BREDEBUGGERATTACHED`
(`debug.cpp:265`, `:304`). Console-versus-editor exclusivity is `debugConsoleBlockLinput` with
`DEBUG CONSOLE ON|OFF` (`debug.cpp:353-364`), the `DEBUGCONSOLEOFF_ASYNC` message
(`remoteargs.cpp:479`) and the gate `debugCommandAllowLinput()` (`debug.cpp:440`). The profiler is
already a DEBUG subcommand (`DEBUG PROFILE`, `profiler.cpp:200`).

### A console response surface

`st_out()` with `setupStatusOut(ufcb *, fd)` (`statcmd.cpp:1134-1142`) writes lines to the
console/status output and already supports redirection to a file descriptor. It is what STATUS
commands and `DEBUG INTERNAL MESSAGES` use.

### Two input paths, with different properties

- **Device layer.** The `MSG` family's real synthetic input — `keybd_event` and
  `mouse_event` — enters above BR and is therefore indistinguishable from the user's own input.
  Requires BR to be the foreground window, on an unlocked desktop, at the same privilege level
  (UIPI). **The keyboard left this path on 2026-09-30** (see below) and only the pointer group
  is still on it, which is why the pointer is the one thing that cannot work off-screen.
- **Internal (secondary).** `putKeyVal` / `putKeyValScancode` (`key_scan.cpp:121-151`) fill the
  `keyBuf` ring (`:12`) and signal the server through `keyIsAvailable()` (`:32`). Every queued key
  carries a `ControlScreenPosition` (`terminal.h:877`) holding either the target
  `brNativeControl *` or a `RowCol`, so positioned mouse actions are representable. Needs no focus
  and works with the window obscured.

**Changed 2026-09-30: the keyboard is no longer on the device layer.** `MSG("send")` now puts
its keys into the `keyBuf` ring through `putKeyVal`, in every session, instead
of `keybd_event` — which delivered them to whichever window had the focus, so a program could type
into another application or another BR session. It types into its own session only; `kb`'s
foreground check went with the race it could not close. The keys are queued on the client
(`harnessQueueProgramKey`, `harness.cpp`) and fed one per pump visit, `sleeptime` apart, so `MSG`
returns at once, `sleeptime` now paces what is seen typed — it never could for keys going into BR,
since nothing reads the ring while the interpreter waits for `MSG` — and a string is not limited by
the ring. `|SHIFT+|` shifts ordinary characters on the keyboard layout, as Windows did for
`keybd_event`. Only the pointer actions remain device-layer, and a
restricted session may not use them. Decided on the principle that BR's reach should be restricted
across the board now that it is exposed to AI work. The Phase 0 measurements below of `kb` as
device-layer input record what was true when they were made.

**Removed 2026-10-12: `MSG("kb")` is gone.** The change above left it as `send` under a second
name — `BrMsg_SendNamedObjCmd` had become an arity check and a forwarding call — and the guard that
had been its whole reason was not merely redundant but unsound: made once, before a string it then
typed over time, while the focus could move. Keeping it meant two documented names for one action
and a dead error number. So the action, the forwarder, its entry in `restrictedMsgCheck`'s permit
list (now 18, not 19) and its advertisement in the reference docs all went, and error 413 *target
MSG window not on top* became a `BR_DEPRECATED_ERR` so the number stays reserved and unreused. A
program calling it now gets 412 *invalid MSG action*; `send` takes the same arguments. The three
kit programs that exercised it — `p25_pointer.brs`, `p36_holes.brs`, `p36_restricted.brs` — were
moved to `send` or had the duplicate block dropped, since `send` is tested beside it in each.

### Program authoring, execution, and a service precedent

Source to disk, `SAVE`/`LOAD`, procedures and `EXECUTE` already exist, as does `Clientshell`
(`remoteargs.cpp:630`). The agent-as-resource work adds the asking, not the doing. For exposing an
external service as a language feature, the SQL bridge (`sqlaccess.cpp`,
`odbc_query_timeout_support.cpp`) is the shape to imitate: an action, typed parameters, a result, an
error code, a timeout.

### Screen state, readable in place

`textBuf`, `attrBuf` and `statBuf` (`textwin.h:311-332`), with `readString()` (`textwin.cpp:463`),
`readChar()`, `readAttr()`, `getRows()`, `getCols()`, `getFontWidth()` and `cursor()`
(`textwin.cpp:480`). `DisplayAttributes` (`terminal.h:106`) carries `bitFlags`, 32-bit
`foregroundColor`, `backgroundColor` and `fontFlags`. `textBuf` holds one byte per character
position, in the ANSI codepage — today's storage limit, and deliberately not the limit the dump
publishes; see "Characters, positions and encoding".

**The control list is persistent and enumerable at any time**, not only during a fields call.
`LinkedScreenControl::getStart()` returns `currentScreenChain->linkedScreenControls`, with
`getNext()` and `getCount()` (`brcontrols.h:500-516`); `findOverlap()` and
`findSelectedRadioButton()` are there too. Each `ScreenControl` (`brcontrols.h:52`) carries:

- **type** — `controlType`, one of the 22 in `ControlTypes` (`basic.h:170`): label, sunken label,
  button, text, image, linedraw, radio, checkbox, grid, grid cell, list, combo, combo char, screen
  window, toolbar, tab window, tab container, component, oldstyle;
- **geometry** in character units — `screenNum`, `m_row`, `m_col`, `m_width`, `m_height`,
  `m_displayLength`;
- **value** — `data` (a `bstring`) and `datalen`;
- **state** — `m_hasFocus`, `m_protected`, `m_finalized`, and which control is current;
- **position within the control** — cursor position, `m_startMarkPos`/`m_endMarkPos` (the selected
  text), `m_scrollPosition` (horizontal offset for a field longer than its display);
- **interaction** — `getScancode()`, `getPriorScancode()`, and hot state via
  `brNativeControl::isHot()`;
- **appearance** — `attribute` and `markedAttributes`, both `DisplayAttributes`;
- **relationships** — `leftNeighbor`, `rightNeighbor`, `radioButtonGroup`, `m_justification`,
  `resizeToFit`, `m_noWrap`, `m_comboFlags`;
- **which channel it belongs to** — `m_commandMode`, "command console or gui control", so one
  enumeration partitions cleanly between the console and the GUI;
- **the widget** — `nativeControl`, for the pixel rectangle, enabled/visible state and actual font.

**One walk covers every mode.** GUI OFF and console-mode fields are in the same list: they are
created as `LinkedScreenControl`s with `controlType = BRCT_OLDSTYLE` and `commandMode` set
(`brcontrols.cpp:971-977`). So `controlType` and `m_commandMode` together separate GUI controls,
old-style fields and console fields within a single enumeration.

Prefer this to the `cfld` array that `Clientfields()` (`fields.cpp:1381`) builds at `:1430`: the
`cfld` view exists only for the duration of one fields call, while the linked list is available
whenever the dump is asked for. `Clientfieldsdata.tcurfld` (`basic.h:1860`) still names the current
input field.

**A field returns what is displayed in it, not only what the program put there.** Phase 0.2b showed
this plainly: a hand-pressed ENTER on a field at row 12 returned twenty characters of unrelated text
that happened to be on the screen at that position, in a variable the program had just cleared. Two
consequences for readers. A dumped field value may be screen residue rather than program data, so a
reader must not treat it as the variable's value — that is what `Clientfieldsdata` and the ownership
rule below are for. And a driver that submits a field without typing into it accepts whatever is
underneath, which will look like input the agent never sent.

**Grid and list contents are readable too.** `brNativeGridBase` (`multicell.h:1129`) implements
`wxGridTableBase`: `GetNumberRows()`, `GetNumberCols()`, `GetValue(row, col)`, `IsEmptyCell()`, with
`clearSelection()` alongside (`multicell.h:1305-1320`, `multicell.cpp:1788-1800`). The cells are a
walk of a different object than the control list, not an unreachable gap. `BRCT_GRID_CELL` is used
for font and column grouping inside the grid, **not** as an entry in the control list, so cells do
not appear there.

PNG writing is available: `wxInitAllImageHandlers()` (`initwx.cpp:204`).

### The command console shares the terminal's buffers

`CommandConsole` is its own `BaseFrame`, titled "Command Console" (`winterm.cpp:639`), with its own
container areas and sizer — `commandConsoleFullArea`, `commandConsoleTopArea`, `commandSizerWindow`
(`terminal.h:771-775`). But there is **one `TextWin` per screen chain** (`terminal.h:774`) and the
console uses it: `CommandConsole::notifyActivated()` focuses `currentScreenChain->textWin`.

So console text, attributes, cursor and status line come from the same buffers and the same dump as
the terminal. `configGuiMode & CONFIG_GUI_CONSOLE` and each control's `m_commandMode` are how the
two are told apart. Two limits follow:

- **No history, and `LOGGING` does not fill the gap.** The console scrolls the same buffer, so
  anything scrolled past is gone — and console output is logged at *no* level. Phase 0.3 measured
  this: level 11, which the BR reference describes as "any PRINT output that goes to the console is
  also logged (GUI ON only)", is in fact `TRACING_FLOW` (`logger.h:30`) and carries socket, SSL and
  `wbs` plumbing. Three runs — level 11 with GUI off, level 11 with GUI on, level 10 with GUI on —
  produced byte-identical logs with none of the program's output in them. A durable record of what BR
  *said* comes from the dump, the observer tee or `st_out` redirection, never from the log.
- **No command history in the buffer.** F2 recall is a separate structure (`LogCommand::m_maxRecall`,
  set by `CONFIG MAXRECALL` in `config.cpp`) and has to be read deliberately if it is wanted.

## Channel 1: the programmer channel

At most one debugger attached, with the profiler subservient to it. While one is attached,
`DEBUG CONNECT`, `DEBUG LISTEN` and `DEBUG AUTH` are refused with 420.

**The console is not locked out by attaching.** By default the console and the debugger can both
enter lines at the prompt — commands and immediate statements alike. The console is blocked only when `DEBUG CONSOLE OFF` is issued with a debugger
attached, whether the debugger sends it or it is typed at the console. That block lifts when the
debugger disconnects or sends `DEBUG CONSOLE ON`; the person at the console cannot lift it. This is
deliberate: whether the console is shared is the debugger's choice, and an agent acting as the
debugger that wants the channel to itself must send `DEBUG CONSOLE OFF` when it attaches. (This
paragraph once said "one holder, editor/debugger or command console, never both", which the code
never did.)

The mechanisms above already enforce this; the work is to document them and to let an agent
*watch* without taking the channel.

**Console observability is not solved by the log or the dump, and the tee as planned does not reach
it.** Three measurements, and they point the same way:

- **The log's timestamps are one-second.** `getDayTimeString` calls `GetLocalTime`, which supplies
  milliseconds, and formats only down to `wSecond`. An interactive console produces many events a
  second, so the log cannot order them, and nothing in it distinguishes a command from the reply it
  caused.
- **The log carries no console output at all** (Phase 0.3), so a command and its reply cannot be
  correlated from the log however fine the clock.
- **A screen dump is a snapshot of a scrolling buffer.** There is no history, so whatever scrolled
  past between two dumps is unrecoverable. Sampling cannot observe a stream; it can only describe the
  moment it was taken.

**And the observer tee in Track B does not close this.** That tee mirrors `sendMessage` in
`debug.cpp` — the *debugger* protocol. Console text does not travel that path; it goes through
`screen()` (`basic.h:3163`) to the terminal. So "the dump or the tee" as this document had it was
wrong about the tee.

### The screen tee — console and terminal history

**Where.** The two `screen()` overloads (`basic.h:3163-3167`, `#if defined(BRMAIN)`), which every one
of the 47 `WRITEC_SCR` call sites across fourteen files passes through. One mirror call at entry.
Being server-side is the point: it captures local mode as well as client/server, where a tee on the
client protocol would see nothing in local mode, there being no socket to tee.

**What each record carries.** `screen()` is handed everything worth knowing: the action
(`WRITEB_SCR`, `WRITEC_SCR`, `WRITEB_ATTR`, `WRITEC_ATTR`, `WRITECC_ATTR`, `DELETE_CHAR`,
`INSERT_CHAR` — `terminal.h:270-300`), the `RowCol` position, the length, the data, and the
attribute for the `ATTR` forms. Add the timestamp and which surface it was — console or terminal,
which `m_commandMode` and `CONFIG_GUI_CONSOLE` already distinguish — and a reader can reconstruct
what appeared, where, and in what order.

**Destination: a file first.** `DEBUG SCREENLOG <path>`, alongside `DEBUG LOG` and following its
shape — `debugPretty`'s write-and-swallow discipline, so a failed write never changes what
`screen()` returns. A file needs no socket, works in local mode, needs no new security surface, and
is tailable, which is all the gap requires. A live remote observer can come later as a second
destination, and if it does it uses B1's TLS and token exchange rather than opening anything of its
own.

**It must stay read-only.** No early return, no new error path, nothing that alters `screen()`'s
result or timing beyond the write itself. The tee is off unless switched on, because a full-screen
repaint is many calls and this stream is far larger than the event log.

**Merging is why the millisecond timestamp matters.** The screen tee and the event log share
`getDayTimeString`, so with milliseconds the two interleave into one account of a session: the log
says what was commanded, the tee says what appeared. At one-second resolution they could not be
ordered against each other at all.

**Dump for state, tee for history.** They answer different questions and neither replaces the other.
The dump says what is on the screen now, with attributes and cursor, and is the only way to ask that
question. The tee says what happened, including everything that scrolled away between two dumps. An
agent watching a session needs both.

**What it does not capture, measured rather than assumed.** `PRINT` reaches the tee, to the main
screen and to a window alike, and the window's BASIC file number distinguishes them. **`PRINT
FIELDS` does not reach it at all** — neither on the main screen nor in a window — because fields
and controls travel the `Clientfields` path, not `screen()`. This document previously said the tee
carried "the control text that goes with it"; that half was wrong, and the kit's `c2_teecover.brs`
is the experiment that settled it.

So the division of labour is sharper than "dump for state, tee for history": **the tee is the
character-cell stream, and the dump is the only way to read controls** — which it does, listing
each with its geometry and value. An agent watching a form-driven program needs the dump; an agent
watching a printing or console program needs the tee. Neither is a screen recording, and nothing
should describe either as one.

**Verify:** a console session whose every visible line appears in the tee in order; a scrolling run
where the tee holds what two dumps either side of it missed; the tee switched off leaving `screen()`
byte-identical in behaviour; and a merge of tee and event log by timestamp putting each command
beside what it produced.

**Console case: the commands come free, the replies do not.** A programmer at BR's console is
typing text onto the `TextWin`, and every command entered is logged at level 8 — `LogEvent(MINOR_EVENT,
"Command entered %s", …)` (`command.cpp:1422`), confirmed in Phase 0.3. BR's *replies* are not logged
at any level, per the correction above, so reading those back needs the screen dump or the observer
tee. The dump covers both halves; the log is a convenience for one of them.

**Editor case, route A — available today, no code, but narrower than it looks.** The programmer
runs `DEBUG LOG [COMMANDS] <file>` (`debug.cpp:329`, written through `debugPretty` at `:115-121`) and
the agent tails it. Phase 0.3b measured what that file actually carries, and the answer divides in
two.

What it does carry: `DEBUG_LINE_BREAK line=…, clause=…` (`:468`) with both fields correct — a
`GO .220:2` against a three-clause line logged `line=220, clause=2` exactly; `ENTER_INPUT_MODE
status=…`, whose status is a `RUNSTAT_VALUES` (`basic.h:504`) and so names the state — 2 `ATTN`,
4 `PAUSE`, 7 `STEP`; and `DEBUG_MESSAGE_LOG`, which mirrors BR's own log stream at levels 6 to 10,
including every command entered. Entries are readable while the session is still running, not held
until close.

**What it does not carry is the stepping position, and that is the limitation to plan around.**
`DEBUG_LINE_BREAK` has exactly one caller — `checkbreakpoints` (`run.cpp:696`) — reached only when a
**breakpoint matches**. Stepping never reaches it. A session stepped line by line logged nothing but
`ENTER_INPUT_MODE status=7` per step, while the line and clause the programmer was looking at went to
the *screen*. So an agent tailing this log learns that stepping is happening and where the programmer
set breakpoints, but not where they currently are. The screen dump (A1) or the observer tee (B1) is
what supplies the position; route A does not, despite being the route that sounds like it would.

**Editor case, route B — the observer tee. Built as B2**, and not an alternative to route A but a
complement to it. A read-only tee in `sendMessage` (`debug.cpp:645`) mirrors each outbound packet to a
passive second socket, enabled by one `DEBUG OBSERVE <port>` keyword beside `T9_LOG` in
`processDebugCommand` (`:254`), reusing `SocketPacket` framing and the existing
`setNoBlock`/`CheckSockets` helpers. The observer never sends, so `processMessage` is untouched and
the editor's session is unchanged. Multi-client debugger support is rejected: it needs per-client
state for a benefit the tee already delivers.

**Route C — `TRACE ON` with `LOGGING 12`, available today and taking no channel at all.** This is
the one Phase 0.3 found, and it is better than the route it was looking for. `run.cpp:363` logs
`Trace line <nnnnn> in <program>` at `TRACING_INFO` (12) for every line the interpreter executes, and
`run.cpp:544` logs `DISPLAY` messages at the same level. Measured: a program with `TRACE ON` produced
one entry per executed line including each iteration of a `FOR` loop, carried the full program path,
and stopped exactly at `TRACE OFF` — the line after it is absent from the log.

What makes it valuable is what it does *not* need. No debugger, so Channel 1 stays free and
exclusivity is never contested; no GUI, so it works `unattended`; no new code. It is the cheapest
execution-flow observation BR has, and the agent should reach for it before anything that attaches.
Its limits are equally clear: it records which lines ran, not values or screen text, and it is a
program-level switch rather than a per-agent one — so a session already tracing for its own reasons
will interleave with it.

**Variable watch.** When a watched variable changes, progress stops and the programmer is notified.
The action from there is to enter step mode, display the new value, or both, at the programmer's
choice. The exchange is audited. This needs new protocol messages and dictionary access, because
`DEBUG_VARIABLE_BREAK` (`debug.cpp:481`) carries only the variable's name and values travel the
command/response path — so it is a costed feature, not a configuration of what exists.

### Authenticating the debugger channel

**Today the channel has no authentication of any kind, and it is the whole programmer channel.**
`setDebugChannelDefaults` (`debug.cpp:180`) sets `debuggerAttached` as soon as the socket is up; both
`DEBUG CONNECT` and `DEBUG LISTEN` call it, and neither exchanges a byte first. The protocol's own
constants confirm there is nowhere for a handshake to hide: the peer may send `FORCE_BREAK` (1) or
`ISSUE_COMMAND` (2) from its first packet (`basic.h:150-168`). Whoever owns that socket can issue
commands, step the program, read variables through the dictionary and reach `DEBUG INTERNAL`. And
`DEBUG LISTEN` binds `INADDR_ANY` (`BindToPort`, `sock.cpp`), so it is reachable from the network
rather than loopback alone. Proven incidentally in Phase 0.3b, where a twenty-line TCP listener that
never sent a byte was accepted as the debugger.

**Attaching is also how you lock the programmer out.** Exclusivity is enforced by the same flag:
`if (isDebuggerActive()) return BREDEBUGGERATTACHED;` guards both `DEBUG CONNECT` and `DEBUG LISTEN`,
and error 420 was confirmed by measurement. So an unauthenticated peer that grabs the socket does not
merely gain the channel — it **denies it to the legitimate debugger**, and `DEBUG CONSOLE OFF` on that
connection blocks the console's LINPUT as well. The hole is a denial-of-service on the programmer
channel as much as an access one, which is the second reason it is sequenced first.

**The exchange.** A challenge-response over the existing `SocketPacket` framing, mutual, with the
secret never on the wire:

1. On accept or connect, before the flag is set, BR sends `DEBUG_AUTH_CHALLENGE` (111) carrying a
   32-byte nonce and a protocol version.
2. The peer replies `DEBUG_AUTH_RESPONSE` (3) with `HMAC-SHA256(secret, br_nonce)` and a nonce of its
   own.
3. BR verifies in constant time, then answers `DEBUG_AUTH_CONFIRM` (112) with
   `HMAC-SHA256(secret, peer_nonce)`, and only now calls the flag-setting half of
   `setDebugChannelDefaults`.

Mutual rather than one-way because `DEBUG CONNECT` dials *out* to a host the operator names: BR
streams source, variables and its log stream to that peer, so BR proving itself matters as much as
the peer proving itself. The cost is one extra packet.

**No new dependency.** brserver already links OpenSSL 3.6.3, so `HMAC()` and `RAND_bytes()` come from
`libcrypto` as `ssl.cpp` uses it — see CLAUDE.md on the directory name that lies about its version.
Keep the code to the tree's C++03-ish house style.

**The secret.** Generated per session from `RAND_bytes`, 32 bytes, written to a per-user cookie file
whose permissions admit only the owner — the X11/Jupyter pattern, and the right default because the
debugger and BR normally share a machine. Two overrides for the cases that need them: a configured
fixed token for a debugger on another host, and an explicit off switch. A `DEBUG_AUTH` directive
carries all three: `DEBUG_AUTH COOKIE` (default), `DEBUG_AUTH TOKEN <hex>`, `DEBUG_AUTH OFF`.

**Where the code goes.** `setDebugChannelDefaults` is the single choke point both paths already share,
so split it: socket options stay, and a new `authenticateDebugChannel()` returns an error the two call
sites check. On failure, close the socket, zero `debuggerSocket`, leave `debuggerAttached` false and
return a new `BREDEBUGAUTHFAILED`. Bound the exchange with `debuggerTimeOut` and the same `breakKey`
escape the connect loop already uses (`:283-292`), so a silent peer cannot wedge BR.

**Audit it at the level BR already has for this.** `SECURITY_EVENT` (5) is defined for "logons, logon
attempts" and is used in only three files; a failed or refused attach, with the peer address, is
exactly what it is for. `brlistener`'s per-IP failure tracking is the precedent for what to do about
repetition, though it is a different binary and nothing is shared.

**Compatibility.** An existing debugger build does not answer the challenge and will time out, which
is the correct failure. Default `REQUIRED` for `DEBUG LISTEN` from the first release, since that is
the inbound exposure; `DEBUG AUTH OFF` is the transition escape for `DEBUG CONNECT` until MyEditBR
implements its half.

**The channel is also encrypted, because authentication alone leaves it readable.** A token exchange
decides *who may attach*; it does nothing about the source, variable values and log stream that then
cross the wire in clear. So the channel runs over TLS, and the work is smaller than it sounds:
`ssl.cpp` already exposes `sendToSSL(SSLSocket *, SocketPacket *)` and
`receiveFromSSL(SSLSocket *, SocketPacket **)` — **the debug channel's own currency**, since
`sendMessage` builds exactly that `SocketPacket`. The change is therefore a wrap at setup and a
substitution of the send/receive pair, not a protocol rewrite:

- `setupSocketSSL` on the accepted or connected socket, then `acceptSSL` for `DEBUG LISTEN` and
  `connectSSL` for `DEBUG CONNECT`. Both take a `bool * finished`, so they drop into the 15×1s
  `breakKey` loop `T9_CONNECT` already runs (`:283-292`) instead of blocking.
- `sendMessage`/`processMessage` switch to the SSL pair; `closeSSL` joins `closeDebuggerConnection`.
- The certificate is the one client, server and listener already use — the debug channel adds no
  new trust store and nothing to manage per site. It is **compiled into the binary**, not
  configured: `br/brs/cryptconstants.cpp` holds the DH parameters, the RSA private key and the
  certificate as generated byte arrays, installed by `SSL_CTX_use_certificate_ASN1` and
  `SSL_CTX_use_PrivateKey_ASN1` in `initSSL_CTX_helper`. It is self-signed by Application
  Development Systems, `CN=BusinessRulesCert`, valid 2025-03-30 to 2052-08-15, and regenerated at
  build time by `unixbuild/crypt` from `dh1024.pem`, `rsapriv.der` and `rsacert.der`
  (`br/docs/brlistener.txt`).
- `getTLSVersionString` and `getCipherInformationString` give the `SECURITY_EVENT` record something
  worth keeping: who attached, over what version and cipher.

**Order is TLS first, then the token exchange inside it — but be clear about what each one buys.**
An earlier draft of this section said TLS "authenticates BR by certificate". **That is wrong, and
the reason matters.** The same private key ships in every copy of BR: it is in
`cryptconstants.cpp`, so anyone with an installation has it, and extracting the certificate from
the source takes about a minute. Presenting it therefore proves only that the peer has a BR build,
not that it is *your* BR, and an active man-in-the-middle holding a BR installation could present
the same certificate.

What TLS genuinely provides here is **confidentiality and integrity** against anyone without that
key, on a path the rest of BR already exercises. **Both ends are authenticated by the token
exchange**, not by the certificate: the peer's proof authenticates the debugger, and BR's proof
authenticates BR. That makes the mutual half load-bearing rather than the courtesy it first looked
like — without it there is nothing tying the far end of the connection to *this* session. The
per-session cookie is what supplies that, being unique to the session and readable only by its
owner. `DEBUG_AUTH` governs the step that does the authenticating. Worth noting for whoever implements it: TLS-PSK
would collapse both into one mechanism with the cookie as the pre-shared key, which is tempting for
the loopback case and avoids certificate handling entirely — but it diverges from how the rest of BR
does TLS, so take it only if certificate reuse proves awkward.

**Loopback only, and that part is done.** `DEBUG LISTEN` bound `INADDR_ANY`; `BindToPort` gained a
`loopbackOnly` parameter (defaulting false, so `brlistener` and the debugger are untouched) and
`DEBUG LISTEN` passes true. Verified: the default shows `127.0.0.1:9555` where it once showed
`0.0.0.0`. (The port was 8556 when this was first measured; it moved to 9555 later, and the binding
was re-checked there.)

**A `PUBLIC` keyword was built here and then removed, 2026-10-03, on Gordon's call.** It bound
`0.0.0.0` on request, and was measured doing so. The argument against keeping it: a debugger holds
the right to issue any command, step the program and read every variable, and `PUBLIC` let *anyone
who could type a BR command in a running session* offer that to the network. Forwarding the port
instead reaches the same debugger and puts the decision with whoever administers the machine.
Anything after the port is now error 1006, so a script still carrying the keyword fails loudly
rather than binding loopback while its author believes otherwise. Two things were measured while
settling that: the refusal is reached before `prepareDebugChannelAuth`, so a refused command
leaves no token file behind; and **`PROCERR RETURN` does not carry a proc past a syntax error**
though it does past a runtime one - `AI is anyone there` (4158) continued in the same run where
`DEBUG LISTEN 8557 PUBLIC` (1006) aborted. That is why `h_nopublic.py` runs under an UNATTENDED
config and reads the abort out of the log, rather than trying to continue past it: an interactive
session halts at READY with the window open, which is correct behaviour and a hung test. `DEBUG OBSERVE` lost its copy of
the keyword at the same time and for a sharper reason - it is shown the same material, so leaving
it would simply have been the way around the removal.

**This lands before the observer tee.** `DEBUG OBSERVE <port>` (Track B) opens another inbound port on
the same channel; shipping it first would add a second unauthenticated listener. The tee uses this
exchange from its first commit.

Other existing feeds, so they are not rebuilt: `DEBUG PROFILE SAMPLED|TIMED` (`profiler.cpp:200`,
with `profileranalyzer.cpp`) and `DEBUG_MESSAGE_LOG` (`basic.h:166`) via `sendDebugMessageLog`
(`debug.cpp:541`), which already forwards BR's log stream to an attached debugger at
`g_debuggerLogLevel`.

## Channel 2: the shared user/AI channel

Channel 2 is the client communicating with the server while the client is driven by the user, by
the agent, or by both. It is not a local-mode feature: the link is the same one an ordinary session
uses, and the only question at any moment is who is driving the client.

### Grant states

Held in the client: **`user`** (default — the agent may read but not act), **`granted`** (the user
has paused; the agent may type and move the pointer), **`exclusive`** (no user present; unattended
verification). Transitions are explicit. Revocation discards the agent's queued actions.

### Input is device-layer, and indistinguishable by design

*Since 2026-09-30 `MSG("send")` is not device-layer: it types into BR's own key
buffer (see "Two input paths" above), and `MSG("kb")` was removed outright on 2026-10-12. What this
section says about typing through `kb` describes the design before those changes;
indistinguishability still holds, because the keys join the same buffer a person's do.*

The agent drives through exactly the paths a person drives through. Nothing is special-cased, so
nothing can diverge: wx key translation, `processFkey`'s modifier reads, `TYPEAHEAD`, field
editing, mouse hit-testing and `controlMouse`'s scancode mapping are all exercised as they are for
a human. `putKeyVal` remains for unattended work, where there is no user to be indistinguishable
from. **Superseded 2026-09-30:** the agent typed through `kb` rather than `send` because `kb` was
`send` behind a foreground-window check, so that the agent could not type into whatever happened to
hold focus. `send` now goes into BR's own key buffer and reaches its own session only, so the
distinction was gone and `kb` was removed with it (2026-10-12).
`sleeptime` paces demonstrations once step A6 corrects where it sleeps, and pacing is a safety feature
as much as a teaching one: a human can see what is happening and intervene.

Four consequences, to be designed rather than discovered:

- **Revocation cannot be detection.** BR cannot tell who typed by inspecting a keystroke, so the
  pause/resume control is the primary mechanism — a hotkey, or a button on the prompt window.
- **Provenance is free, and is not a behavioural fork.** `keybd_event` and `mouse_event` both take
  a `dwExtraInfo` word that BR passes as `0` today. Stamping a BR signature there changes no
  behaviour and no code path branches on it, but it lets the client recognise its own injections
  for the log, and makes an optional "un-stamped input cancels the grant" rule possible.
- **Audit comes from the grant layer.** The record is "the agent held the grant from T1 to T2 and
  submitted these actions", not per-keystroke attribution. That is what answers "who typed this?"
  in a support call.
- **A visible indicator** while the agent holds the grant. With time-boxed, revocable grants this
  bounds the real risk: device-level input carries the user's full authority over live data, and a
  runaway agent is indistinguishable from a runaway user.

**Clicking.** Anything hot can be clicked to generate input, by either party — that is what the
control's scancode is for, and `controlMouse` already turns a click on a hot control into one.
Because `MSG`'s click actions act at the pointer's current location, reaching a target is always move
then click, so the pointer actions and the click actions are one group (see Implementation staging).

### The agent's own conversation surface

Built entirely from existing parts: a BR snippet opens an independent window with a text box
(`brNativeTextControl`) for prompting; the agent's replies display on the command console through
`st_out`/`setupStatusOut`; the application keeps the GUI console. That is a bi-directional text
channel inside BR, equivalent to the terminal this conversation runs over.

### The agent as an application resource

**The agent answers a program the way a person does, and through nothing else.** The rule in "Input
is device-layer, and indistinguishable by design" governs here too: the agent's only way into BR is
the keyboard and pointer it shares with the user, under a grant. So when a program wants something
from the agent it asks on the screen — the question, and a field to answer in — and the agent,
reading the screen over the harness channel, types the answer. There is no second connection and
no path from the agent into a variable that a person's typing does not also take. (C2 was first
built as exactly such a path — a DLL carrying answers over its own socket — and removed for
breaking this rule; see Track C.)

Stored prompts give a program a tidy way to ask: a name, parameters, a result, an error code and a
timeout, in a BASIC library. The question's answer field is declared by the application, and it is
the trust level:

- **Display text** — a `C n` field.
- **Data values** — a field of the receiving type and length, `N w.d` or `C n`, so the answer is
  checked by BR's own field handling, exactly as a person's would be. Nothing is reimplemented.
- **Code** — never executed on the agent's say-so. Typed into a file a line at a time, shown, and
  run only on a person's request, in a restricted session. The question, the answer, the generated
  source and each execution go through the existing logger at a defined level, with the source kept
  and timestamped.

Who typed an answer is not something BR can tell, by design. The grant log says whether the agent
held the keyboard at the time, and a person can always answer the question instead.

### Generated code: authority and the runtime gate

Which safeguard applies depends on who asked, matching the authority order:

- **Generated for the programmer** — the programmer approves it before execution. Nothing further
  is restricted; the programmer already has that authority.
- **Generated for the user** — it may read existing data freely and create new data, but may never
  write to data that already exists.

**The rule as built, from 2026-09-30: a restricted session may change only a file it created
itself.** It supersedes the rule the rest of this section describes — *an `OPEN` for `OUTPUT` or
`OUTIN` must also specify `NEW`*, enforced in `bopen` — which is kept below because the reasoning
behind it still holds. What changed, and why:

- **The `bopen` gate was too far from the open.** It exempted the utility open path so that
  `INDEX` could run (see step B5 below), and `DEBUG LOG`, `DEBUG SCREENLOG` and `DEBUG PROFILE`
  never passed through `bopen` at all. From a restricted session, `INDEX`, `SORT` and all three
  debugger writers could overwrite any existing file. `br/aiaccess/p40_writers.brs` demonstrated all
  five before the fix and is the regression test after it.
- **The check now sits in the `wb…` layer** (`wbname.cpp`, `wbshare.cpp`) — where every file
  operation that takes a BR name meets, one step before the operating-system call:
  `wbopenFile`, `wbdeleteFile`, `wbsharedeleteFile` (whose reserved-file branch truncates through an
  open handle and never reaches `wbdeleteFile`), `wbrenameFile`, `wbsharerenameFile`, `wbrmdirFile`,
  `wbchmodFile` and `wbmkdirFile`. The functions are `restrictedBeforeOpen` and its neighbours in
  `wbserver.cpp`, section "the restricted session's own files". The `bopen` gate is gone.
- **The session keeps a list, in memory, of what it created** — full path and identity (volume
  serial and file index, or device and inode) — and a change is allowed only when both match, so a
  file someone else put under the same name is not the session's. The list is the session's
  alone, never shared, and ends with it; clean-up across sessions is for ordinary programs.
  Creation of a free name is always performed as `NEW`, so it is atomic.
- **The file commands are permitted and decided per file.** `FREE`, `DROP`, `RENAME`, `COPY`,
  `RMDIR`, `PROTECT`, `SAVE` and `REPLACE` joined `INDEX` and `SORT` on the command filter's permit
  list; the filter keeps only what is not a file operation (`EDIT`, the shell form of `SYSTEM`,
  anything unclassified). `DEL` was on the refused list by mistake: it deletes program lines.
- **Two rules that a per-file check needed.** A new program may not shadow an existing one of the
  same base name under another program suffix; and `REPLACE` checks its target before making its
  `.bak`, so a refusal leaves nothing behind.
- **The client applies the same rule to its own files** (added later the same day). The list and
  the check live in `file_os.cpp`, which both sides compile; each side keeps its own list and is
  switched on separately — the server at the latch, the client when the new `restrictedSession`
  field at the tail of `fieldsconfig` (`SERIALIZE_FIELDSCONFIG_LENGTH` 406) says so, after which
  nothing switches it off. The client applies it in its handlers for server-forwarded file
  operations (`remoteargs.cpp`: open, delete, rename, rmdir, mkdir, set-time), to `MSG("dump")` and
  `MSG("shot")`, and to a print job written to a named file (`PDF:`). Knowing the session is
  restricted also lets the client refuse **printing to a UNC name** — which `p36` showed writing a
  file through `\\localhost\c$\…` when unrestricted — and **Ctrl-\] in client/server mode**, where
  the shell starts on the client. Verified in local mode only.
- **`MSG` is a permit list** (`restrictedMsgCheck`, `numfunct.cpp`): reading and arranging windows,
  the harness and grant, `notify` and the three `agent*` actions, and `dump`/`shot` under the file
  rule are permitted; the pointer actions are
  refused, because a click at screen coordinates lands on whatever program is there. `notify`,
  `agentask`, `agenttext` and `agentline` are permitted because none of them writes a file, runs a
  command or puts input anywhere — they let a session that asked a question be handed the answer,
  and a restricted session is the one that most needs to be able to report what it found.
  (`notify` was documented as permitted when it was added and was in fact refused, because it was
  never added to this list; fixed with the three new actions, 2026-10-02.) `send`
  is permitted: in every session, restricted or not, the client types its keys into BR's own key
  buffer (`brm_SendString`, `brmsg.cpp`, through `harnessQueueProgramKey`) rather than through
  `keybd_event`, which went to whichever window had the focus — decided 2026-09-30, first for
  restricted sessions and then for all, on the principle that BR's reach should be restricted
  across the board now that it is exposed to AI work. Named keys map to BR key values as
  `key_scan.cpp` maps physical ones; queued and fed `sleeptime` apart (see "Two input paths").

Verified by `p40` (the five writers), `p41` (everything a session may now do with its own files,
the shadow and `REPLACE` refusals, and a same-name-different-file refusal staged by the parent
while the child runs), and the rewritten `p34` and `p36`, on x64 and Win32 Debug. The audit of
direct calls to `file_os` that bypass the layer found them all to take names BR constructs, or to
be read-only, or to run on the client behind a server-side check; the exceptions are the `MSG`
actions above.

**And a second rule, from 2026-10-05/06: a restricted session may reach only what the site's file
list permits.** It began as the read list step 7 asked for and became the whole filesystem
boundary — reading, creating, changing, renaming, deleting and listing. `brrestrict.sys` beside the
executable, BR names unless prefixed with a colon, `!` to exclude, glob with `**`, case insensitive
everywhere, resolved paths on both sides, `@all` and `@<username>` as section headings over the
entries below them, and absent means unrestricted (which is also why a client
machine is unrestricted until a list is installed there). The customer reference is
`AI-Restricted-Operations.md`, *Files: where the session may be*; the reasons behind its design
are in the comments of `file_os.cpp`'s "the file list" section. What follows is the
part a maintainer needs that is not in either.

**The things a maintainer needs that are not in the step 7 record:**

- **Where the code is.** `file_os.cpp`, section "the file list", below the
  change rule and reached from `restrictedBeforeOpen`, `restrictedBeforeChange`,
  `restrictedBeforeCreate` and `findFiles` — the same funnels the change rule uses, which is why it
  holds for every route to a file. `wbmkdirFile` needed a gate added; every other operation already
  had one.
- **4153 and 4165 answer different questions**, and the order matters. 4165 is *the site does not
  let this session near that file* and 4153 is *this session did not create that file*. The list is
  the outer boundary, so it is tested first, and a change to an unlisted file reports 4165 rather
  than 4153.
- **It comes into force after `processConfig`**, the opposite of the latch's requirement and for the
  opposite reason: the latch precedes the configuration file because it filters it. **The window
  that leaves open is exactly one file and its `INCLUDE`s.** The startup command runs after
  `startup()` returns, so a `PROC`, the program it loads and every operation after it are gated —
  settled by taking the kit directory off the list and watching a session's own startup `PROC` fail
  4165, and held down by a check. The configuration is exempt because whoever named it is outside
  the restriction and could read those files already, and because gating it would fail quietly:
  `config` reports a statement it cannot use and carries on, so a refused `INCLUDE` would drop
  printer definitions rather than stop the session.
- **The session's own files stay its own**, and that clause is reachable rather than dead: an entry
  can begin to apply part way through a session, because an entry naming something absent is
  resolved later rather than dropped. A file made while a folder was permitted stays the session's
  after an exclusion for that folder starts applying.

New error **4165** `BRERESTRICTEDLIST`. Tested by `br/aiaccess/h_readlist.py` with
`h_readlist.brs`, `h_readlist_c.brs`, `r7child.prc`, `r7spawn.prc`, `brconfig.r7` and
`brconfig.r7c`: **30 checks, 0 failures**, in x64 Debug, x64 Release and Win32 Debug, built clean in
all four Windows configurations. The driver installs the list, makes a junction inside a permitted
directory pointing at a denied one, and starts the restricted half itself. That last is not because
`SPAWN_RESTRICTED` is at fault — I said its configuration-file argument was broken and have
withdrawn it; see the step 7 record. A spawned child does die before logging for some combinations,
and it tracks the *parent's* configuration rather than the child's, which is unexplained and
chases nothing this work depends on. `c3` still passes unchanged with no list installed, which is the evidence that the
default behaviour is the old one.

**`WORK` trees (2026-11-09).** A `WORK <tree>` line names where a session may change what it did
not create: `restrictedOwns` in `file_os.cpp` counts a file under one as the session's own, and
that one function decides for the restricted session's change rule, its shadow check and
permission mode's `aiFileIsOurs`. Where the list names any area, the tree must be inside one;
an exclusion wins; the tree's root is not itself free. Tested by `br/aiaccess/h_work.py` with
`h_work_c.brs`, `h_workp.brs`, `hwork.prc` and `hworkp.prc`.

**The list binds every session (2026-11-09).** `brrestrict.sys` is read by every session —
`restrictedReadListActivate()` in `startup()` after `processConfig`, and on the client at the first
`SETFIELDSCONFIG_ASYNC` record (`remoteargs.cpp`, not in `BRMAIN`) — and `restrictedListPermits`
no longer tests `s_restrictedFilesActive`. Each gate (`restrictedBeforeOpen`,
`restrictedBeforeChange`, `restrictedBeforeCreate`, `findFiles`) tests the list first, ahead of
permission mode, so an excluded file is refused with 4165 rather than asked about.
`restrictedNameBeforeChange` in `wbserver.cpp` tests it too (`restrictedListBefore`), so `SAVE`
`REPLACE` onto a refused file leaves no `.bak`. The ownership rule (4153) stays a restricted
session's alone. Error 4165's text is *brrestrict.sys does not permit this file*; the log's lines
begin *File list …*, and a refusal reads *Session refused …* in an ordinary session. A missing
list is logged only in a restricted session. `h_work.py` run U is list A in an ordinary session:
**h_work 0 failures and h_readlist 36/0, x64 Debug and Release.** The client's own list in an
ordinary session has no test.

**Permission mode's ledger takes only what the session made (2026-11-09).** Found with
`h_spawnh.py`, which runs a user-mode primary and restricted children on its WSID, each with a
channel of its own. In a session that is not restricted, `restrictedAfterOpen` recorded every open
but a plain read, so a file the operator allowed with `Y` joined the ledger and was never asked
about again, and so did any file `DROP`, `FREE` or `RENAME` probed with its read-write open. Now
the gates note what they find absent or already the session's own (`aiNoteGate`, called from
`restrictedBeforeOpen` and `restrictedBeforeCreate`), and `restrictedRecord` enters only a noted
path; a restricted session records as before. `restrictedRemoved` and `restrictedRenamed` keep
the ledger in step in permission mode too. Fixing it exposed a second question for one `COPY` -
"to set the time of", after "to open for output" - which the old ledger had hidden; the stamp in
`wbsharerecopyFile` now runs under `PermissionSettled`, local names only. A `COPY` over an `@:`
client file is not covered by that and may still ask twice; untested. Tested by `h_ponce.py` with `hponce.prc`: six
turns, **0 failures**, x64 Release.

**How long an answer lasts (2026-11-09), Gordon's scheme.** `Y` is the turn, `H` the connection,
`A` the BR session, `N` nothing - per file, or per shell keyword - and the session's own files last
the session. `file_os.h` names the scopes `AI_PERMIT_TURN`, `AI_PERMIT_CONNECTION` (value 2, which
was `ALWAYS`) and the new `AI_PERMIT_SESSION` (4); `ONCE` remains for a question with no subject,
and is what `Y` travels to a client as. None of them touches the ledger any more: `H` and `A` are
`s_aiConnectionPermittedFiles` and `s_aiSessionPermittedFiles`, by path and identity, read by
`aiFilePermittedKept` - in `assistantPermitFile` on the server and in the client's own three gates -
and `s_aiPermittedCommands` / `s_aiSessionPermittedCommands` for shell keywords. **`H` used to
survive the assistant leaving**: nothing on the close path turned tracking off, so a program that
reopened the channel handed the next assistant every "always" given to the last.
`aiHarnessConnectionEnded()` now clears the connection's and the turn's answers, called by the
client from `harnessChannelClose` and by the server when `SET_CLIENT_STATE_ASYNC` changes
`CLIENT_STATE_HARNESS_ATTACHED` either way; `aiTrackFiles(false)` no longer empties the ledger. The
`A` and `H` answers travel to a client on the retry (`remotePermittedKeep`). The question is
`N = no, Y = turn, H = connection, A = session`, 75 characters with "this file"; the box's buttons
are "Yes, this turn", "All this session", "While connected" (`winterm.cpp`). Tested by
`h_pscope.py` with `hpscope.prc`, `h_pscope_o.brs` and `h_pscope_r.brs`: two connections to one
session, **13 checks, 0 failures**; `h_permit.py`'s turn check now answers `Y`.

The original reasoning follows. Everything else followed from the `NEW` rule rather than needing
its own:

- `OPEN ... INPUT` is unrestricted, so generated code can still look things up — without which most
  of what a user would ask for is impossible.
- `NEW`, `USE` and `REPLACE` are the three dispositions in the same `OPEN` option table
  (`bopen.cpp:44-47`). Requiring `NEW` therefore makes `USE` and `REPLACE` unavailable for a
  writable open, so **no writable channel to an existing data file can be obtained at all**.
- Record-level modification and deletion of existing data then cannot occur, because there is no
  channel to do it on. `DELETE` needs no separate prohibition.

**`FREE` and `RENAME` must also be prevented.** They are **commands**, not program statements —
entries in `table1k` (`tblcmd.cpp:12-56`), the command keyword list — so they cannot appear in
generated program source at all. They are still reachable two ways, and both must be closed:

- **Through the command channel.** A program reaches a command with `EXECUTE`, or through `PROC` and
  `SUBPROC`. **File-altering commands are blocked, except `INDEX` and `SORT`, which are permitted** —
  a generated report or query needs to build an index and sort its output. Blocked, from `table1k`
  (`tblcmd.cpp:12-56`): `FREE`, `RENAME`, `COPY`, `DEL`, `RMDIR`, `REPLACE` and `SAVE`. `SYSTEM` is
  blocked on separate grounds: it alters nothing by itself but escapes BR entirely, so no gate
  downstream of it can hold.

  The filter tests the **command token**, not the text that produced it, so it applies identically
  whether the command arrives from `EXECUTE` of a string built at run time, a `PROC` file, or a
  `SUBPROC`. A new file-altering command added to `table1k` later must be classified when it is
  added; that is the standing cost of a permit-list over a blanket refusal.
**`CLOSE ... FREE` is allowed**, so a generated program can clean up the files it made. `FREE` is
also a secondary keyword, `T4_FREE` (`tblopr.cpp:337`), so that form is reachable from program code
even though the command is not.

**The free path needs its own check — measured, not inferred.** A program that created a file, closed
it, reopened it `INPUT` with no share spec and issued `CLOSE #1,FREE:` **deleted the file and reported
no error** (Phase 0.1, run 2026-09-28). So an `OPEN ... INPUT`, which the rule permits, followed by a
free removes existing data in two lines.

That is consistent with everything the guard does test. It keys on **share mode, not open mode**:
`bfclose` refuses `DROP` and `FREE` when `uf->ufshare` is non-zero (`bopen.cpp:2182-2186`), and again
when another open of the same file exists (`:2304`). `SHAREMODE_NOSHR` is 0 (`file.h:80`) and **NOSHR
is the default when no share spec is given**, so the ordinary open satisfies it. Nothing on that path
compares `INPUT` against `OUTPUT`/`OUTIN`, and the free itself deletes by file name after the close
(`FFREE`/`KFREE`, `file.cpp:836-848`). The BR reference agrees: it requires `NOSHR` for both `DROP`
and `FREE` and says nothing about the open mode.

**This was a BR defect, and it is now fixed.** `CLOSE ,FREE` on a file opened `INPUT` is meant to
fail, so the fix went into BR rather than the gate: a test beside the existing share-mode guard in
`bfclose` (`bopen.cpp`), which is already where `DROP` and `FREE` are vetted, returning a new
`BREFREEREADONLY` (4151, "CLOSE DROP or FREE requires the file to be opened for output").

Two details differ from how this section first specified it. The test is `uf->ufopen <
OPENMODE_OUTPUT`, not `bf->fio`: `ufopen` is the **per-channel** BASIC open mode
(`OPENMODE_INPUT` 1, `OPENMODE_OUTPUT` 2, `OPENMODE_OUTIN` 3, `file.h:68-70`), while `fio` sits on the
shared `bfcb` and records the OS-level access, which can read `OFW_READ_WRITE` because *another*
channel opened the file writable. `ufopen` is also the idiom the same function already uses a few
lines earlier. And the guard covers `DROP` as well as `FREE`, because both destroy: `FFREE` deletes
the file and `FDROP` empties it (`file.cpp`). It is limited to the cases that would really destroy
something — the same set the drop/free below it is limited to — so closes on window, async
communications and printer channels behave exactly as before.

Verified by re-running the Phase 0.1 experiment against the rebuilt `brserver`: the file now survives
and the program stops with 4151 at the `CLOSE` line. A regression test covering the legitimate case —
a program creating a file and freeing it, opened `OUTPUT` and again `OUTIN` — still frees both with no
error.

**With that fixed the gate needs no free-path test at all**, which is why the rules stand as written.
A program generated for a user can only open an existing file `INPUT`, because the `NEW` requirement
blocks every writable open of a file that already exists — so once an `INPUT` channel cannot be freed,
existing data is unreachable. The files such a program creates itself are opened `OUTPUT` or `OUTIN`
and remain freeable, which is what `CLOSE ,FREE` was allowed for.

**The compatibility note is written.** Any existing program that frees a file it opened `INPUT`
worked before and now fails — the point of calling it a defect, but a behaviour change in shipped
code, so it leads `BR50 Release_Notes.md` in this directory.

That makes two enforcement points in the gate — the `NEW` requirement at the file-open path and the
command filter — over one BR defect that has to be fixed for them to be sufficient. Both are checks at
the operation, which is why neither can be evaded by how the code was reached.

### The gate is a session latch, not a program scope

**A session marked user-initiated stays that way for the duration of its life.** Nothing clears the
latch: not a program ending, not `CHAIN`, not a `LIBRARY` call or `LIBRARY RELEASE`, not a procedure
continuing past it, not an error exit, not returning to the command console. Only the session ending
clears it, and the session is disposable by design.

**Two things take the latch, and this section describes only one of them.** A session is also
latched, before it reads its configuration file, when an **AI-user-mode flag** is held — a file in
the account's own local application directory, kept open by whichever session has an assistant
connected to it, so that any BR session starting while an assistant is present is restricted however
it was launched. The rules are in
[`AI-Restricted-Operations.md`](AI-Restricted-Operations.md#how-a-session-becomes-restricted) and are
not repeated here.

**The flag could not have used the byte lock described below**, and the reason is worth keeping. A
byte lock needs a WSID and `g_lockOffset`, neither of which exists until after the configuration
file has been read — which is exactly too late to latch a session. It is also advisory: it informs a
reader that consults it and prevents nothing. And because a restricted session may not set
`WBSERVER`, one can end up reading a different `wbserver.dat` than the session that took the lock,
and so see no lock at all. The flag instead withholds `FILE_SHARE_DELETE` on an open handle, which
makes the operating system itself refuse to unlink the file, and is testable from a file path alone
before any of BR's own state exists.

**Where the flag lives.** In the brserver file, against the session — not in the program and not in
interpreter memory alone. `wbserver.dat` already tracks state per `(wsid, sessionid)`: the high-byte
lock areas hold `WB_MAX_SESSIONS * maxWSID` bytes per region (`wbserver.h:207`), addressed by
`wbLockOffsetID(regionID, wsid, sessionid)`, with `wbIsLoggedOn(wsid, sessionid)` and
`wbIsNewUserID()` as the existing tests. Three consequences worth building on:

- **Use the generic product-region scheme.** `wbserver.h:245-265` documents it: each
  independent product takes its own region ID — out of more than 2300 available, with
  the regions to avoid named (the first several, ~1191-1193 near the double-lock checks, ~2085-2088
  near wsid processing). This is preferable to extending the 64-byte login record, which is already
  full: `name[60]` plus `processId`, the name having been cut from 64 to make room (`wbserver.h:61-66`).
- **A lock cannot go stale; a data byte can.** If the mark is held as a byte lock in the manner of the
  existing session tracking, the operating system releases it when the process dies, so a crashed
  session cannot leave a flag behind that gates an innocent session reusing the number. Writing it as
  data instead would require explicit cleanup and a reaper.
- **Any process that can open the file can read it.** brclient, brlistener and the utilities can all
  see which sessions are latched without asking the interpreter — which is how the status-line
  indicator and the agent learn the state.

**Nine sessions per WSID is the accepted ceiling.** `WB_MAX_SESSIONS` is 9, so a WSID has at most
nine concurrent sessions and disposable ones are drawn from that pool. This is accepted rather than
worked around: whoever builds the spawn path releases a latched session when it is finished, and an
application that spawns them faster than it releases them will exhaust its WSID and must throttle.

The bluntness is the point. Every place the gate could be lifted is an escape, because a generated
program that can hand control to un-gated code — by chaining, by calling into an existing library, by
starting another program — launders its restrictions through it. A latch removes that whole class
instead of enumerating its members, which is the same reasoning that chose a runtime gate over a
source scan.

**Not even the programmer can override it.** The authority order governs who drives BR — which channel
holds the keyboard, who approves what — and the latch is not a question of authority. It is a
statement about data that has already been put at risk in this session, so it stands above the
ranking rather than inside it. A programmer who needs write access to a latched session restarts BR.
If that proves too strict in practice it can be revisited, but it is deliberate, not an oversight.

Two consequences to accept deliberately:

- **The user's own later work in that session is restricted too.** After such a program has run, an
  ordinary program that writes data is refused until BR restarts. That has to be visible — the state
  belongs on the status line, and in the log at the moment the latch is set — or it reads as a
  malfunction rather than a rule.
- **An application that must keep writing should run the generated program in a separate BR session**
  and treat that session as disposable. In client/server each client has its own brserver session, so
  a latch never reaches another user.

**The restriction is enforced by a runtime gate, not by inspecting the source.** The interpreter
enforces the disposition requirement at the file-open path itself and the command filter at the
command token. The gate is the only mechanism, and it is the only sound one: a source scan is
evadable through `EXECUTE` of a string built at run time, `CHAIN`, a `LIBRARY` call into existing
code, or a called procedure, whereas a check at the operation refuses regardless of how execution
arrived there.

**The flag belongs to the session, not to the program.** A disposable session is the **same WSID with
a different session number**, and the brserver file records that the session is user-initiated. Two
reasons this is better than marking a program: there is no window in which the session is running
un-gated before the mark is noticed, and nothing about a program — its name, its source, how it was
reached — has to be trusted or tracked.

This matters because BR has no privilege separation: a generated program otherwise runs with the
full rights of the session and can reach every file the user can. There is no sandbox to fall back
on, so the gate plus approval *is* the boundary.

**Retention.** Programs generated for programmer requests are kept indefinitely. Programs generated
for user responses are removable, with a retention period still to be set.

**Program data is data, not instructions.** Text the agent reads from BR files or screens may
contain anything; it is summarized and acted on, never treated as a directive.

## The harness channel: transport and payload

The specification for sequence step A2. A **new listening socket in brclient**, localhost, opt-in, off
by default. Not the client↔server link (a lockstep two-party protocol carrying data the server never
needs), not the debugger socket (server-side and exclusive to the programmer channel), and not the
embedded goahead server (server-side, so it would make the client ship its screen to the server and
fail exactly when the link is down). The socket is new; the plumbing is not — it reuses `SocketPacket`
framing and the helpers `debug.cpp` already uses: `BindToPort`, `startListening`, `acceptConnection`,
`CheckSockets`, `receiveFromSocket`, `sendToSocket`, `setNoBlock`, `setNoDelay`, `SetInheritable`.

One connection at a time; one response per request, in request order. Requests may be pipelined
(see "Sending: a ring, never a wait"). The service call in the client's event pump handles **at
most one request per visit** and never waits on the socket, so the pump stays cheap. (This
said `processOSEventsShort()`; as built it is `processPendingEventsLocal()` in `initwx.cpp` — see
Track A, step 2.)

**The byte-level reference is [`harness-formats.json`](harness-formats.json)**: every request and
record with its fields in order, the error codes, the control types, attribute flags and key codes.
It is written for an agent to read, and is kept to what `harness.cpp` actually does.

### Actions

| Request | Returns |
|---|---|
| `HELLO <token>` | accepted or the connection closes — see Authorisation |
| `PING` | protocol version and capability flags, so a driver can tell what this build supports |
| `SCREEN` | rows of text |
| `ATTRS` | attribute runs |
| `CONTROLS` | the control-list walk, each entry carrying `controlType`, `commandMode` and (protocol 3, 2026-09-30) the scancode pressing it sends, so a button can be pressed with `SCANCODE` — the channel has no pointer |
| `CURSOR` | cursor position and the current control |
| `GRID <id> [<firstRow>]` | that grid's size, then up to 200 rows of its cells from `firstRow` |
| `LIST <id> [<firstRow>]` | the same for a list |
| `SHOT` | renders to PNG beside the token, returns the path; takes no path |
| `GRANT?` | the current grant state |
| `KEYS <string>`, `SCANCODE <n>` | injection; refused unless a grant is held |

Responses are `OK` with a payload or `ERR` with a numeric code and text.

### Framing: the length governs, never the newline

Payloads are multi-line by nature — a screen is rows, a grid is cells, and a field value may itself
contain line breaks. So a record is a header line followed by a body of exactly the declared size:

```
<RECORD> <args> <byteLength>\n
<exactly byteLength bytes>\n
```

The reader consumes the declared count and never scans for a delimiter, so **a body may contain
newlines, control bytes, or anything else without escaping.** A response holding many records begins
with its record count, and each record then declares its own length. This is the reason for choosing
length prefixes over JSON: the tree has no JSON writer, one would be hand-rolled under the C++03 rule,
and hand-rolled escaping of arbitrary screen bytes fails silently on the byte nobody tested.

**The framing length is in bytes; everything semantic is in characters.** The reader needs bytes to
know where a record ends, while positions, field lengths and attribute-run extents are character
positions and character lengths per "Characters, positions and encoding". The two differ only once
strings carry multi-byte characters, which is what the next rule announces.

### Sending: a ring, never a wait

**BR never waits for the agent to read.** The first version sent each response with `sendToSocket`
and a five-second timeout, from the client's event pump. An agent that stopped reading froze BR's
window for five seconds, and indefinitely if it read a byte every four, because each partial send
restarted the clock. When the time did run out, the failure was ignored, leaving half a response in
the stream, so every later response was misread.

Responses now leave through a ring: one 50 KB buffer used as a rotating stack, with a start pointer
(the oldest response), an end pointer (where the next goes) and **a running count of bytes
available**, which is also what tells a full ring from an empty one when the two pointers are equal.
Each response is an entry: a control block holding its length, how much has been sent, when it
was queued and a heap pointer, then its data.

- **Responses up to 8 KB are copied in whole**, and their data may run off the end of the buffer
  and resume at the start. That costs nothing, because `WSASend` gathers the two pieces.
- **Larger responses**, which in practice means a page of `GRID` or `LIST`, **go to a heap block**,
  and only the control block is kept in the ring. The heap block is freed when the response has
  been sent.
- **A control block never wraps**, because it is read as a structure. Where there is no room for a
  whole one before the end, a wrap marker goes there and the block starts at 0.
- **When the ring empties it starts again at 0**, so the next entry is as contiguous as it can be.

Each pass of the pump makes **one non-blocking `WSASend`** of up to 16 pieces, retires whatever the
socket took, and frees heap blocks as it passes them. `WSAEWOULDBLOCK` is not an error; it means
"not yet".

**Back-pressure is by not reading.** A request is read only when the ring has room for the largest
response it could produce: 8 KB inline, plus the tail a wrap can waste, and heap use under 1 MB.
This check comes before the request is read rather than after it is answered, so a finished
response always has somewhere to go. Pipelining falls out of it: several requests can be
outstanding, and replies leave in request order. An agent that stops reading stops being read, and
its surplus requests wait in its own socket buffer.

**The limit:** if the oldest response has not been fully taken 10 seconds after it was queued, the
connection is closed and the reason logged. Unsent responses are discarded, never delivered to a
later connection. The clock runs from queuing, so reading a byte at a time does not extend it.

**No locking, because nothing needs it.** Reading requests, building responses and sending them all
happen inside `harnessService()`, under the re-entry guard it already had for `SetTitle`. That guard
is the invariant: nothing touches the ring from outside it.

**Observability:** every connection's close logs one line — the ring and inline sizes, how many
responses, how many went to the heap, data wraps, wrap markers, peak bytes in use, and how many
were unsent at close. **At level 11 (`TRACING_FLOW`), and in a Debug build only**, since
2026-10-03; it was level 10 and in every build, which put this one module's internal bookkeeping
into the log of any site running at the level it would choose to see its own commands and files.
It belongs with the rest of the ring's test hooks, below. The *reason* a connection closed is
still logged at level 10, in every build.

**Testing the wrap cases** needs the ring kept full, which a fast reader never does, and Windows'
own send buffer absorbs tens of KB before the ring holds anything. A **Debug** build therefore takes
three environment variables, which Release builds ignore:

| Variable | Sets |
|---|---|
| `BR_HARNESS_RING_SIZE` | the ring size |
| `BR_HARNESS_INLINE_MAX` | the inline limit |
| `BR_HARNESS_SNDBUF` | the socket's send buffer |

`br/aiaccess/h_ring.py` uses a 3,000-byte ring, a 1 KB inline limit and a 2 KB send buffer, under
`brconfig.ring` — its own configuration at `LOGGING 11`, because that is where the line above now
goes. It checks:

1. **Pipelining:** 20 mixed requests in one write, with replies in order.
2. **Pressure:** 1,000 pipelined requests read more slowly than BR answers them, every reply
   checked byte for byte. The log line must show the configured ring size and heap entries. **Data
   wraps and wrap markers are read but not required**, and that is deliberate: both need the ring
   to be non-empty as the write offset passes the top of the buffer, and `harnessQueue` resets
   both offsets to 0 whenever the ring drains — so whether either happens is one run's timing.
   Three consecutive runs gave 2 wraps, then 1, then 0, with every reply byte-perfect each time.
   A wrap that went wrong would fail the byte-for-byte comparison, which is the check that
   actually covers the path.
3. **A stalled agent:** BR's window answers `WM_NULL` throughout, and the connection is closed at
   10 seconds.
4. **Recovery:** a fresh connection afterwards works normally.

### The expansion marker

**Any string carrying a UTF-8 expansion must begin with the null UTF-8 character.** A consumer seeing
the marker knows byte length and character length diverge for that string and must not index it by
byte; a string without the marker is single-byte throughout, and the two lengths agree.

**The marker is the UTF-8 BOM, `EF BB BF`.** A literal leading `0x00` was considered and rejected: it
cannot occur in valid text, but it terminates a C string, so any `strlen`/`strcpy` path on either side
of the socket would truncate the value to empty — and BR handles plenty of text as `char *` even though
`bstring` is length-counted. The BOM gives the identical signal, survives `char *` handling, and is the
established convention for "UTF-8 ahead".

Two consequences for implementers: the BOM is three bytes of the record's declared byte length but
contributes **no character positions**, and a consumer strips it before using the text. A string
without it is single-byte throughout, so byte and character lengths agree and it may be indexed either
way.

### Authorisation: a token

**The token method is chosen.** When the channel opens the client writes a token to a file only the
session owner can read, under the per-user application data path. (This paragraph first said
"single-use" and "on start-up"; as built, the token is good for every connection while that listener
stays open, and is replaced each time it opens.) A connection's first packet must be
`HELLO <token>`; anything else, and the connection closes without a reply. Loopback-only binding and
off-by-default are necessary but insufficient on a multi-user Windows machine, where another logged-in
account can reach `127.0.0.1` — the token is what makes the endpoint the session owner's alone, and it
carries to the unix builds unchanged if this ever goes there.

## Threads

The design needs none. The channel is serviced from `processOSEventsShort()` (`common.cpp:158`) on
the GUI thread, the socket helpers are already non-blocking, and a long agent turn is handled by
**submit-then-poll**: a wait that yields through `wbIdleProc()` (`common.cpp:205`) so redraws
continue and ATTN/break still works. A blocking `DLL()` call that freezes the terminal for the
length of an agent turn is the thing to avoid.

One condition would force a thread: a transport that cannot be made non-blocking. If that ever
happens, the thread must hand keys to the GUI thread rather than call `putKeyVal` itself, because
`keyBuf` has no synchronisation.

## Streams, storage, devices

**The client and server activity logs are already merged.** `clientMessageLog()` (`term.cpp:1330`)
forwards every client `LogEvent` over `LOG_EVENT_ASYNC`, so the client's log is written on the
server: one file, one clock, levels in `logger.h:18-40`, configured at `config.cpp:2328`. No new
correlation layer is needed. The caveat is that `LOG_EVENT` is an `ASYNC_MERGE_MESSAGE` batched
until roughly 4K accumulates or a non-merge message forces a send, so the *ordering* of client
events within the merged log is approximate.

**Whose disk.** The activity log, `DEBUG LOG` trace and profiler output are written server-side;
screenshots and session artifacts client-side. One machine in local mode, two over a network —
which is the practical limit of tailing a trace file, and the main argument for the tee.

**Devices.** The user's monitor at the user's DPI; the agent sees PNG and text, never a screen.
Real and agent input share the keyboard and pointer by design. Printer and PDF output are checked
only for regressions. Speech is upstream of BR: dictation produces text into a field and changes
nothing here.

## Working off-screen

**The whole agent loop runs without the foreground, and that is measured rather than argued.**
An agent doing research and development on a BR session can park that session where nobody can
see it, drive it, read it, and check it visually — then bring it back on screen only when a
programmer is wanted. Nothing in the path needs focus except the pointer group.

**What was measured** (`br/aiaccess/h_capture.py`, 2026-10-03, Win32 Debug). A session holding at
one screen was captured in four states and each capture compared with a baseline taken with the
window in front. Below the caption, in a 1290x820 region of 1,057,800 pixels:

| state | client area against the on-screen baseline |
|---|---|
| idle, nothing touched | identical, 0 pixels |
| **fully covered** by a maximized topmost window | **identical, 0 pixels** |
| **moved past the right edge of the virtual desktop** | **identical, 0 pixels** |
| minimized | no usable capture at all |

Whole-window, a covered capture differs from the baseline by 3833 of 1,199,700 pixels — **every
one of them above y=110**, in the caption and menu bar, which Windows draws greyed when the window
is not in front. That is a true report of the window's state, not an error, and it is why the test
compares the client area separately rather than hiding the difference under a tolerance.

**So, for an agent:**

- **Reading the screen needs no focus.** The harness channel's `SCREEN`, `ATTRS`, `CONTROLS`,
  `CURSOR` and `HISTORY` never did. `MSG("shot")` renders from BR's own text buffer and never
  did either.
- **Reading the *frame* needs no focus, and this is the new part.** `brwin.py capture` takes the
  window through `PrintWindow(PW_RENDERFULLCONTENT)`, which draws from the window's own backing
  content rather than from the display. It is the only way to see the title bar, the menu, the
  status line and the window's real geometry — none of which the dump or `shot` can show — and it
  costs about a second and never raises or focuses anything.
- **Typing needs no focus.** `MSG("send")` puts keys into BR's own `keyBuf` ring
  (2026-09-30, above), and the harness channel's `KEYS`/`SCANCODE` always did.
- **The pointer, since 2026-10-03, is no longer the exception.** It was, and the section
  below records what it cost; BR now keeps a pointer of its own and delivers the press into
  its own input, so aiming and pressing work out of sight like everything else.

### What breaks off-screen, and how quietly

**The pointer group could not work, and said nothing — FIXED 2026-10-03.** `getwpos` and
`setwpos` converted through `ScreenToClient`/`ClientToScreen` on **`GetForegroundWindow()`**, not
on BR's window, so with BR out of sight they answered and aimed relative to whatever was in front;
`lclick`/`mclick`/`rclick` were `mouse_event` at the pointer's physical position, so they landed on
whatever program was actually under it. No error was raised in either case.

They now move a pointer BR keeps itself, in the client coordinates of its own top-level window,
and deliver the press into BR's own input through the same routing a real press takes
(`TextWin::deliverMouseButton`, which `OnMouse` also calls, so there is one routing rather than
two to keep in step). The press is queued with the keys, so typing and clicking keep their order.
**`setcpos`/`getcpos` were added** because an agent reads the screen as rows and columns: without
a cell-addressed pointer it would have to know BR's font metrics and where the terminal sits in
the frame, which is arithmetic BR is already doing. `AI-Access-Protocol.md` §8.6 is the
definition; `br/aiaccess/h_pointer.py` is the measurement — ten checks, run with the window in
front and again with it off the desktop, output identical.

Two limits worth knowing. A press can only be delivered to the **character screen**; over the
menu, the status line, a native control or outside the window it is refused rather than delivered
somewhere else. And **the physical pointer is no longer moved at all**, which is what makes the
rest possible — `SetCursorPos` could not reach a window parked off the desktop, and would have
dragged the user's cursor across the screen to try.

**The window actions that acted on whatever was in front are gone.** `wlist`, `minimize`,
`maximize`, `top` and `bottom` listed or rearranged other applications' windows; `minimize` would
also have made the session's own screen uncapturable. `restore` and `state` were kept and now act
on BR's own window, which is what the off-screen model needs: `state` says whether a capture can
be believed, `restore` brings the session back when a programmer is wanted. A session is still
moved out of the way from outside, with `brwin.py state`, not by BR. `gettext` went with them:
it returned the foreground window's caption, which is another application's title whenever BR is
not in front.

**Minimizing is not a way to get a session out of sight.** Windows gives a minimized window no
client area: `GetWindowRect` answers with a 237x50 taskbar rectangle at -32000,-32000, and the
capture is faithfully that rectangle. It does not fail. An agent that minimizes a session to tidy
the desktop keeps receiving PNGs and keeps believing them. **Move the window off the edge of the
virtual desktop instead** (`brwin.py state --state offscreen`), which leaves it mapped and painting,
and restore it by position when a programmer is wanted. Hiding it with `SW_HIDE` is worse again:
`MainWindowHandle` then reads 0, so there is no window to capture at all.

### The capture kit

In `br/aiaccess/`, all PowerShell, none of it needing BR to be in front:

- **`brwin.py`** — one module for every window operation: `windows` lists a process's top-level
  windows, `capture` renders one to a PNG, `state` places it, `probe` lists a window's child
  controls with the state that decides what they draw, `at` says what draws at a point, and
  `nudge` forces a repaint. **Python with `ctypes`, not PowerShell**: PowerShell cannot reach
  Win32 without `Add-Type -TypeDefinition`, which compiles C#, and this tree has none. The PNG is
  written with `zlib` and `struct`, so there is no PIL and no new dependency. Proved equivalent to
  the PowerShell version it replaced: the same window captured both ways differed by 0 of
  1,199,700 pixels.
- **`capture` takes `--title`**, because a session with `CONSOLE ON` has more than one top-level
  window and Windows calls the **Command Console** the main one. Every capture taken before that
  option existed photographed the console rather than the terminal.
- **`brcover.py`** — the full-screen window `state --state cover` raises, which **closes itself
  after 120 seconds**. One left standing by a driver that was killed mid-run blanked a monitor
  until the process was hunted down; `state` also sweeps any cover still up before raising another.
- The old PowerShell capture — `printwindow` by default; `children` walks descendants with
  `WM_PRINT` and is **measured to add nothing here** (byte-identical output, 0 pixels changed, 15
  children) but is kept for a control that one day does not print; `screen` is `CopyFromScreen`,
  the reference the other two were checked against, and the only one that shows anything drawn
  *over* the window — it alone needs the window raised.
- **`brwin.py state`** — puts a window in a state a capture must cope with, and reports whether the
  foreground window actually covers it, so a test cannot pass by never having been asked.
- **`comparepng.ps1`** — every pixel through `LockBits`, with an optional region.
- **`pnginfo.ps1`** — colour count and "ink": how much of an image is not its single commonest
  colour. The instrument for "did this come back empty?".
- **`cropzoom.ps1`**, **`diffpng.ps1`** — crop and magnify, and a difference image. PowerShell
  still, but they only load `System.Drawing` as an assembly; nothing here compiles.
- **`h_capture.py`** — the measurement above, re-runnable.

**`SetProcessDPIAware` before any `GetWindowRect` is not optional.** Without it the rectangle comes
back in logical pixels while the screen is physical: on this 1.5x display a 1290x930 window is
captured as 860x620, and the bottom of the window — where the status line is — is simply absent.
That cost an hour once, because a cropped-away status line reads exactly like a status line that
failed to render. `brwin.py` keeps a `--nodpi` switch to reproduce the fault on demand.

## Value ownership and staleness

The server holds the whole variable space. The client holds copies of **only** the fields in the
current PRINT/INPUT FIELDS, for the duration of the call: serialized in at
`remoteargs.cpp:814-823`, the changed ones serialized back at `:836-853`, then freed by
`clearSerializedDictionary*`.

Therefore:

- Field values are readable client-side with no server round-trip.
- Everything else — non-field variables, arrays, the current line, file state, the program text —
  is server-only.
- Where both sides hold a value they may differ, from the first keystroke until `FIELDS_RET`. Both
  are correct. **Any reader records which side a value came from, and never reports a mid-call
  divergence as a fault.**

## Characters, positions and encoding

Rules for everything the dump publishes, settled now because they are cheap to honour from the
first version and expensive to change once readers exist.

- **The wire format is UTF-8**, from the first version, whatever the buffers hold internally. Today
  `textBuf` stores one byte per character position in the ANSI codepage, so the dump converts with
  `wxCSConv(wxFONTENCODING_SYSTEM)` — the encoding `MonoCharacterPicture::prepareByFont` renders
  with (`textwin.cpp:203`), which is what makes the published text match the glyphs actually on
  screen. When the storage widens, the conversion step disappears and **no consumer changes**.
- **Lengths are character lengths; offsets are character positions.** Never byte offsets, never
  pixels. A field's length is its character length; the cursor sits at a character position; an
  attribute run starts at a character position and spans a character count; control geometry
  (`m_row`, `m_col`, `m_width`, `m_height`, `m_displayLength`) is in characters.
- Today those units happen to coincide with byte offsets, because the storage is single-byte.
  **The interface must not encode that coincidence.** A consumer never indexes the published UTF-8
  by byte to reach character position N.
- `COMBO_BOX_CHAR` (0xFE) and control bytes are published as spaces.
- **Left open until non-Latin scripts arrive:** a character position is not always a screen column
  — a CJK character occupies two columns and a combining mark occupies none. When that matters, the
  dump will have to state which of the two it is reporting. While the terminal is single-byte the
  two are identical, and the dump reports character positions.

## Implementation sequence

The work divides along the client/server boundary and the two halves do not collide: everything the
agent *reads and does* is in brclient, everything that *governs and records* is in brserver. Only the
resource at the end needs both. So tracks A and B can proceed independently, each with its own builds
and its own verification, and neither blocks the other.

Every step leaves the tree buildable and the product shippable. Client steps are verified in all four
configurations plus the legacy `brclient.vcxproj` Win32 Debug; server steps in all four.

### Phase 0 — settled by experiment, 2026-09-28

**Complete.** Each of these decided something the document had written two ways. The findings are
stated as rules in the sections named; what follows is only the index, so nothing is measured twice.

1. **`CLOSE ,FREE` on a `NOSHR` `INPUT` open** deleted the file and reported no error. Judged a BR
   defect rather than something for the gate to work around, and **fixed** — see "Generated code:
   authority and the runtime gate". The rules were not changed, and the gate needs no free-path test.
2. **`MSG` fidelity held.** Text and shifted sequences arrive verbatim, an MSG-sent key and a
   hand-pressed one behave identically down to sharing the same surprise, `kb` refuses off-focus with
   error 413, and pacing is per segment. See "Input is device-layer, and indistinguishable by design".
3. **Observation routes.** Console output reaches **no** log at any level; commands reach it at level
   8; `TRACE ON` with `LOGGING 12` gives a line-by-line execution trace needing no debugger and no
   GUI; `DEBUG LOG` writes live but carries positions only for **breakpoints**, never for stepping.
   See "Channel 1", "The screen tee" and route C.
4. **`getcb` was not broken.** It reads the clipboard exactly as its table comment says. The defect
   reported here earlier came from misreading stitched `sed` output as one function; the real, minor
   fault is a shadowed `interp1` that loses its error messages. See "Open decisions".

Two claims this document made before Phase 0 were wrong and are corrected in place, so a reader who
remembers them should not trust the memory: that the console case needed nothing built (its
*replies* are not logged), and that the observer tee would supply console text (it mirrors the
debugger protocol; the screen tee is what covers the console).

**Already landed, built in every configuration and verified.** `BREFREEREADONLY` 4151 with its guard in
`bfclose`; `DEBUG LISTEN` bound to loopback (its `PUBLIC` opt-in has since been removed - see
above); a server-side start-up log line
naming an earlier run's heap report; the client's heap-report notice requiring an answer before it
stops appearing; millisecond log timestamps. The other three configurations and the legacy
`brclient.vcxproj` build clean too, all four CMake configurations with zero warnings; none of it is
committed.

#### The test kit

**The kit lives in `br/aiaccess/` and is tracked.** It used to sit outside the repository, which
made it one disk failure from gone while being the only thing that exercises any of this.

It is still *reached* at `C:\ADS\qsmrp\context\scratch\aiaccess\`, because every program, procedure and
configuration in it names that path, and rewriting ninety files would have been ninety chances to
break a test. **That path is now a junction pointing into the repository**, which inverts the
arrangement the ignored dependency trees use: there the repository holds a link to files kept
outside, here the outside path is the link and the repository holds the files.

On a fresh clone the junction has to be recreated before the kit will run, the same way `wx315`
needs a build step:

```
mklink /J "C:\ADS\qsmrp\context\scratch\aiaccess" "<repo>\br\aiaccess"
```

No elevation is needed for a junction. The rest of the kit needs `C:\ADS\qsmrp` itself — a real application
with real data and drive mappings — so a clone alone cannot run most of it. The findings in this
document remain the durable part; the kit is how they were obtained and how they are re-checked.

Tests run as `brserver-<platform>-Debug.exe -<config> proc <proc-file>` from `C:\ADS\qsmrp`.
**The kit writes its output beside its inputs**, so `br/aiaccess/.gitignore` excludes everything a
run produces — logs, dumps, screenshots, BR data files, the screen tee and the C1 handshake
files. A full run of the suite leaves no tracked file modified; that was checked rather than
assumed.

- `brconfig.p0` is the unattended one, `brconfig.aiuser` the interactive one, `brconfig.log12` traces
  at level 12, `brconfig.dbg` is for a debugger session. **`unattended` exits BR at the first
  keyboard wait**, so any test needing a prompt, a stepping session or `MSG` must omit it.
- Phase 0: `p01` free/drop, `p04` `getcb`, `p05` console output, `p06` `TRACE`, `p07` breakpoints,
  `p09` the free/drop regression.
- Track A: `p11` the dump, `p12`/`p13` the control walk in GUI off and on, `p14` the channel,
  `p16` a screenshot, `p20` printing while connected, `p22` the grant lifecycle, `p23` the agent
  typing into a field, `p24` revoke-discards-the-queue, `p25` the pointer group. `p25`'s pacing
  lines check that `MSG("send")` returns at once rather than taking the paced time.
  **`harnessclient.py` is a working driver for the channel** and the quickest way to see it answer:
  it reads the token, does the handshake, and exercises every action.
- Track C: `c1_chat.brs` with `c1agent.py` for the text channel by hand; then **`runtrackc.py
  c2|c3|c4`**, which runs the test and prints its `.out` and the log lines that matter
  (`--platform x64`, `--config Release` for the other builds). For `c2` and `c4` it first starts
  **`agentdriver.py`**, the stand-in assistant: a harness client that reads the screen, finds a
  question and types its answer under the grant. Those two run attended, with a BR window, because
  a question is an input wait. `c2_answer.brs` is the channel with no library; `c3_spawn.brs` with
  `c3_child.brs`, `c3_hold.brs` and `c3quick.prc` the disposable sessions; `c4_prompts.brs` the
  stored prompts, through `agentlib.brs` and the files in `prompts\`. C3 runs about 50 seconds,
  because its throttle check waits for seven holders to end. `p34` and `p36` run their restricted
  half in a spawned session, `p34_restricted.brs` and `p36_restricted.brs`.
- BR AI tools (`br/docs/BR_AI_TOOLS2.md`), steps 1 to 4: **`h_cells.py`** the grid and list
  cells; **`h_history.py`** the console history and the view over the harness, with
  **`h_viewui.py`** for the parts of the view that live on the desktop — the overlay scrollbar,
  the wheel, the drag and the clipboard — which it checks by asking the window manager rather
  than by looking at a picture, because `PrintWindow` does not render the bar;
  **`h_sbdata.py`** what is in the character cells and what `PRINT NEWPAGE` leaves in the
  history — the measurement behind withholding that history with `GUI OFF`, and the gate that
  does it;
  **`h_develop.py`** where a grant may type, in three passes (normal, `DEVELOP`, restricted);
  **`h_events.py`** the pushed events; and **`h_driver.py`** the Go driver in `br/mcpdriver/`,
  including a whole MCP conversation over its stdin and stdout. Each writes its own `.out`.
  Step 3 adds **`h_text.py`** with `h_text.brs`: text delivered in one request, read back by the
  program a line at a time, and every refusal the wire has - and **`h_textbox.py`** with
  `h_textbox.brs`, which is not a test of BR AI tools at all but the measurement behind one
  design decision in them (what BR's multi-line `TEXT` control holds, what `P` costs, and what
  GUI OFF does with it); it is kept because it is the evidence. `brconfig.text` is its GUI ON
  configuration. **`cs_steps.py`** runs the same ground in **client/server** mode, with
  `cs_history.prc`, `cs_develop.prc` and `cs_text.prc`; its third phase runs `h_text`'s own
  checks over the link rather than a copy of them, so what is proved there is the same thing. It
  needs the rig below. **`h_nopublic.py`** with `p10nopublic.prc` and `p10noobserve.prc` proves
  that the removed `PUBLIC` keyword is refused rather than ignored and leaves nothing listening;
  it runs under `brconfig.nopub`, an UNATTENDED copy of `brconfig.dbg`, because a syntax error
  halts an interactive session at READY. **`h_display.py`** with `h_display.brs` measures where
  `DISPLAY <var>` goes with no redirect - the console, one line per change, which is what lets an
  assistant on a client follow a value through a loop. Step 4 adds **`h_chat.py`** with `h_chat.brs`: the `AI` command at the
  console, the `ASK` event, the reply printing, `COMMAND` and its refusals - and a last phase that
  runs the whole loop through the real `br_mcp_driver chat` in `--echo` mode, so the loop around
  the model call is proved without the call. `h_chatwait.brs` only holds a client/server session
  open long enough for the console to be read before `SYSTEM` clears it.
  **`h_grantraise.py`** with `h_grantraise.brs`, `h_grtry.brs`, `h_grwait.brs`, `hgraise.prc` and
  `hgraiseb.prc` proves the one thing a line the assistant sent may not do with the console it has
  been lent: raise its own grant. Every `MSG("grant", n)` but `n = 0` is refused with 4166, a
  longer grant, an exclusive one and a shorter one alike; withdrawing is allowed; the person's own
  grant is untouched; and a program the assistant's `RUN` line loaded is refused too. `hgraiseb.prc`
  is a session of its own for the **last line of a turn**, which BR pops the proc before running -
  the case that sank a first implementation built on walking the proc stack.
  **`h_permit.py`** with `h_permit.brs`, `h_pmopen.brs`, `h_pmwait.brs`, `hpermit.prc` and
  `hpermitg.prc` covers permission mode: a turn runs its commands, and every destructive file
  operation stops and asks the operator `Y`/`N`/`A` at the console. It answers the question by
  posting a keystroke to the console window, because the assistant deliberately cannot - `KEYS`
  needs the grant, so it has no way to answer its own question. `hpermitg.prc` is a second session
  for the cases that need a grant given before any turn opens, and what it proves now is that a
  grant **does not** waive the question: that it did was the rule for one release, and lending the
  keyboard is not consent to an operation nobody has seen yet. Its `SYSTEM` cases have been round
  the houses: asked about by keyword, then refused outright with 4168, and asked about again once
  the gate moved into `shell()` - which is what made it worth asking, because that is the one place
  every route passes through. They now assert that `N` refuses with 4167, that the next `SYSTEM`
  asks again, and that `H` is remembered against the first keyword so a third `cmd` is not asked
  about at all.
  **`h_opt83.py`** with `h_opt83.brs`, `h_o83wat.brs`, `hopt83.prc`, `ho83r.prc` and the two
  configurations `brconfig.opt83` and `brconfig.o83off` covers **`OPTION 83`**, which lifts the
  shell question and the AI-user-mode flag together for an application the site has declared
  starts BR sessions of its own. **It runs every phase twice**, with the option and with a
  configuration identical but for that one line, because "no question appeared" and "no question
  was ever triggered" look the same from the driver - the control is the known reading that makes
  the measurement mean anything, and it is also what would catch the flag being renamed or moved.
  With the option on, a `SYSTEM` in a turn runs unasked and the flag is absent; with it off the
  same line puts the question up and the flag is held. `CONFIG OPTION 83` is refused with **4172**
  in both runs, checked from inside a BR program so the error is the one a program would trap, and
  a `--restricted` session is refused the option from its own configuration file. **Both
  configurations are `GUI ON` deliberately**: with `GUI OFF` the question goes into a modal box
  instead of onto the console these runs read. The box's side is `h_msgown.py`: the `MSGBOX`
  request reports it as BR's own question, refuses to answer it with error 18, and a Break sent on
  the channel interrupts it.
  **`h_chatsrc.py`** with `hchatsrc.prc` covers a turn answered with a PROGRAM: both of the turn's
  questions are listed by `QUESTIONS` with the path BR will write to, a `SOURCE` delivery for the
  code question is written by the interpreter to that path, and the commands that load and run it
  each come back with BR's own error number - 0, and 4152 for a file that is not there - while the
  turn stays open.
  **`h_aiturn.py`** covers `AI_TURN_OK` - whether a turn may happen over something that is
  running - in three sessions, because the rules are not all visible from one place.
  `haiturn.prc` uses **no assistant at all**, which is the point: the gate is about the session's
  state, not about the channel. It is refused with 4169 with no flag and with the wrong value,
  allowed with `"Y"` (and with `"y"`), and then **not spent** - the AI command is neither of the
  flag's two resets, so a line that failed before a turn could open leaves the consent standing,
  which the proc checks by asking again. The first reset, **the programmer's own `SETENV`**, is
  checked there too: `"N"` withdraws it and the next line is 4169. The numbers come from the proc
  reading `ERR`, not from the console, because an error on a command line goes to the status line
  and never becomes a row `HISTORY` carries - the same arrangement `hchatalone.prc` has always
  used for 4158.
  `haiturnh.prc`, with `h_aiturn.brs`, `h_aiturnw.brs` and `aiturnsub.prc`, covers what the proc
  cannot see for itself: a line from the assistant may not set the flag (4170) nor use the `AI`
  command at all (4171), and a `PROC` command from the assistant **pushes** - if it had replaced,
  the proc that consented would be gone and `h_aiturnw.brs` would never be loaded. That program is
  also where **the second reset** is measured: it runs after the turn and reads `AI_TURN_OK` back
  empty, which the turn's end did. `haiturnc.prc` covers `CLEAR PROC`
  ending an open turn, and the assistant being told rather than left waiting.
  It also carries, with `h_aiturnbad.brs`, `h_aiturnok.brs` and `h_aiturncode.brs`, three
  programs that meet the same divide by zero and end three different ways - and are **not** about
  the flag. One dies untrapped, and the `RUN` reports the error BR stopped on, where it used to
  report 0. One handles it and did the work, and still reports success, with nothing added. One
  handles it and could not do the job, and says so with `STOP 3`: the number stays 0 and `the
  program stopped with CODE 3` arrives in the message. The first was found by the flag's own
  refusal coming back as 0; the third by asking what a program that copes but fails could
  possibly say.
  **`h_defer.py`** with `h_defer.brs`, `h_dfwait.brs` and `hdefer.prc` covers **turn+** - work a
  turn started, running after the turn has ended. Its assistant writes a procedure of its own in
  three commands, which no question is put about because creating a file is not destructive, then
  `PROC`s it; the pushed procedure's lines run once the turn has stopped holding the prompt, and
  its `FREE` of a sentinel the session never created has to be asked about anyway. **Two shapes,
  and the second is why the test exists**: BR pops a proc as it reads its last line, so a one-line
  procedure's only statement runs with the stack already back at level x. The first run of this
  test questioned the two-line procedure and let the one-line one delete the file unasked, which
  is what moved the depth comparison to where the line is **read** (`aiTurnWorkLineFrom`).
  **`h_exec.py`** with `h_exec.brs`, `h_exwait.brs` and `hexec.prc` covers a turn a **program**
  opened with `EXECUTE "AI ..."`, whose reply is fed to that program's own `LINPUT` as keyboard
  input rather than printed on the console - two lines answering two reads, in order. It also
  pins what the console does and does not show: the reply is on the screen only where the
  `LINPUT` echoed it, as a typed line would be, with no `[AI]` copy of it, because a
  console-routed reply would have arrived after the program ended and the program would never
  have seen it.
  **`h_listing.py`** with `h_listing.brs` and `hlisting.prc` covers `PROGRAM` and `LISTING`. The
  program loops for the whole test, so the session is a **running program** throughout - which is
  the case `LISTING`'s shape exists for, since the interpreter can list only at a safe point and
  the request is parked until one comes. A session sitting at READY would pass without exercising
  that at all.
- `dbglistener.py` is a twenty-line TCP listener that BR accepts as a debugger, because
  `setDebugChannelDefaults` sets `debuggerAttached` as soon as the socket is up. It is how the
  debugger-channel tests ran without the real debugger, and it is also why that channel needs B1.
- **Removed 2026-10-02, superseded rather than retired.** Four Track A tests were each redone
  with a better method and the earlier attempt left behind: `p17` and `p21` by **`p22`**, whose
  own header says why ("margins wide enough that the driver is certainly watching before the
  grant starts and after it ends"), and `p18` and `p19` by **`p20`**, which prints continuously
  instead of once or twice. The Track A list above already named only the survivors. Also gone:
  `p05check.prc` and `p07check.prc`, which loaded a program and exited to see whether it parsed -
  an idiom `brls -check -sema` replaced, and which the context README now requires instead.
- **`p25`'s pacing section was corrected, not removed, 2026-10-02.** Its pointer half still
  tests the A6 group; the timing lines expected `MSG("kb")` to take `sleeptime` x characters to
  return, which stopped being true when send/kb began queueing into BR's own key buffer. They now
  expect it to return at once, and say that `p36_holes.brs` is where the pacing itself is tested.
- **Retired 2026-09-30:** `p02`, `p03` and `p26` (with `run-aiuser.cmd`) tested `MSG` send/kb
  when it typed through the operating system into the focused window: one sleep per run of text,
  a foreground guard, function keys arriving as `FKEY -1`. `send` now types into BR's own key
  buffer, paced key by key, and `p36_holes.brs`/`p36_restricted.brs` test that. **Deleted from
  disk 2026-10-02**; `git show 1f99e86^:br/aiaccess/p02_msgkb.brs` and the rest still have them,
  and the kit's `.gitignore` keeps the patterns so restoring one for reference does not dirty the
  tree.

#### Client/server test setup

*Set up 2026-10-01, for step 0 of `br/docs/BR_AI_TOOLS2.md`: everything above was tested standalone,
and the AI tools are to work through each user's client in client/server mode.*

**On one machine, with the listener as a service.** `brlistener TESTING` runs the listener in a
console reading `brlistener.conf` from the current folder, but it cannot start sessions: the
listener launches brserver with `CreateProcessAsUser` (`brlistener.cpp`), which an ordinary process
may not call. So the listener runs as the `BR_Listener` service, installed with
`brlistenerinstaller.exe` (sources `br/brs/install.cpp` and `elevate.cpp`; it installs
`%SystemRoot%\System32\brlistener.exe` as an **automatic-start** service unless given another
path). Its configuration is always `%SystemRoot%\brlistener.conf`:

```ini
logfile=C:\ADS\cstest\brlistener.log
loglevel=10
port=8565

[
LABEL=QSMRP
STARTDIR=C:\ADS\qsmrp
EXECUTABLE=C:\cygwin64\home\gordon\br50\br\winbuild\dllbuild\output\brserver-x64-Debug.exe
CONFIG=context\scratch\aiaccess\brconfig.cs
STDERR=C:\ADS\cstest\stderr.txt
MULTISESSION
]
```

- **Port 8565**, so it cannot collide with a real listener on 8555. The service listens on all
  interfaces, as listeners do.
- **The login names the server's account.** The listener calls `LogonUser` with the name and
  password typed at the client (`security.cpp`) and starts brserver with that token. **`ANONYMOUS`
  is not used**, by decision: it keeps a password in the file, and the listener writes that password
  to its log at level 8 (`brlistener.cpp`, the `anonymous name %s password %s` line).
  **`MULTISESSION`** keeps the credentials in the listener's memory after the first login, so later
  sessions from the same client do not ask again until the listener restarts.
- **The client** runs from its own folder, so `@:` paths differ from server paths:
  `brclient-x64-Debug.exe 127.0.0.1:8565 QSMRP` with `C:\ADS\csclient` as its working folder.
- **`brconfig.cs`** is `brconfig.b5` logging to `cs.log`.

**Two traps found on the first run, both now handled:**

- **Antivirus TLS interception.** Avast's Web Shield intercepted the client's connection, even to
  `127.0.0.1`, and presented a certificate of its own ("Avast Web/Mail Shield Self-signed Root").
  The client's certificate pinning correctly refuses it. Before the fix this showed as a
  "connecting" window flickering for minutes, then a timeout: the handshake failure was retried, and
  after three failures in a minute `brlistener` blocks the address for five minutes and **stops
  logging it**, so the listener's log went silent. The client now refuses on the first attempt and
  says why (release notes, *The client refuses a server certificate that was replaced in transit*).
  `openssl s_client -connect 127.0.0.1:8565 -tls1_3` shows who is answering: the certificate's
  issuer should be `BusinessRulesCert` itself. Exclude BR's programs from such scanning.
- **"Bad action 10129" at connect.** An unrecognised Windows error before the version handshake
  made the client send `SET_UKNOWN_ERR` too early and exit. Fixed in `file_os.cpp`.

**Open:** whether `brclient localhost ...` works. `localhost` resolves to `::1` before `127.0.0.1`,
and the client takes an IPv4 address; this was not yet tested on its own when the Avast problem was
found.

**A second label, `QSMRPR`, starts a restricted session**, with `ACTION=--restricted`,
`ACTION=--restricted-log=10,C:\ADS\cstest\restricted.log` and `WSID=50`. That is the
first of the two candidates the plan named for the gap where `SPAWN_RESTRICTED` refuses in
client/server mode, and it works: `restricted.log` holds a complete session. `SPAWN_RESTRICTED`
itself was left alone.

> **The `ACTION=` line above is as it was measured and no longer does what it says
> (noted 2026-10-08).** `--restricted-log=` takes a **folder and nothing else** now — no level, no
> `U` — and BR names the file `restricted-<session>.log`, by `SESSION$` (one file per session since 2026-11-10; it was one per
> WSID before). So that label should read `ACTION=--restricted-log=C:\ADS\cstest`, and the
> session's log would be `C:\ADS\cstest\restricted-501.log` with `WSID=50`, session 1. Left as written it would be **fatal**: the
> whole string is taken as a folder name, is not a directory, and BR refuses to start a restricted
> session whose audit trail it cannot keep where it was told to.

**Driving a session for a test.** Nothing can open the harness until a program runs, and no
program runs until something types at the console, so a test types at the client's own window
with posted key messages. Two things make that work:

- **Wait for the status line to say `READY`.** The window exists while the session is still
  starting, and a key posted into it then goes nowhere. This was the cause of an intermittent
  failure that looked like the feature failing.
- **Expect only the first command to land.** Posting `WM_CHAR` into another process's window
  delivers one command and then stops, so a test starts its session with a single `PROC` and the
  procedure does the rest. Through the harness, several commands in a row all arrive - the limit
  is in driving a window from outside, not in BR.

**End by typing `SYSTEM`, not by killing the client**, or the server is left waiting to reconnect
(`Found server socket awaiting reconnect` in the listener's log) and has to be killed by hand.

`br/aiaccess/cs_steps.py` is the test that uses all of this, and the evidence that steps 1 and 2
of `br/docs/BR_AI_TOOLS2.md` work through the link.

#### Building and testing the client, for whoever changes it next

- **Nothing in the kit builds BR, so every driver refuses a binary older than `br/brs`.**
  `brkit.server()` resolves the binary and stops the run with exit 3 if it, or the client DLL
  beside it, predates the newest file in the shared source pool; `brkit.py` on its own reports
  all four configurations. `--stale-ok` (or `BR_KIT_STALE_OK=1`) overrides it. The drivers do
  not agree on a platform — most default to `Win32`, a few to `x64` — so a rebuild of one
  leaves the other stale, and a driver running a stale binary reports every check passed. A
  config keyword the old binary does not know is simply ignored, which is how `OPTION 82 ON`
  read as green while the windows it was meant to park stayed on the screen.
- **Stop `brserver` before building `brclient`.** brserver loads the *version-stamped* DLL,
  `brclientdll501-...`, and the POST_BUILD step that makes it is a file copy: a running session
  holds that file open, the copy fails, and the stale stamped DLL wins. The build still reports
  success. CLAUDE.md says as much — "a stale stamped file wins and the fresh build is never
  loaded" — and it is easy to walk into anyway. Check the build output for the
  `stamp-client-dll:` line, or compare the two timestamps, before believing any test result.
- **Give a timing test room.** BR's `SLEEP` in these programs runs faster than nominal, so a test
  program reaches its end sooner than the arithmetic suggests. Three separate "defects" chased in
  A4 were all this: a connection closing was the program's own shutdown, and a grant that seemed
  invisible had expired five seconds before the first poll. Log the times and compare them against
  the client's, rather than trusting the intended schedule.

#### Driving BR by hand, for whoever runs these next

Each of these cost a wasted round trip when it was learned.

- **`GO` leaves a `PAUSE`, and `GO STEP` resumes in step mode.** `DEBUG STEP` does not: it goes
  through `setStepMode`, which does not accept `RUNSTAT_PAUSE` and fails **silently**.
- **`GO <line>` resumes *at* a line; `GO .<line>` runs *until* it.** `GO .220:2` stops before line
  220, clause 2.
- **`DEBUG CONSOLE OFF` needs the debugger attached at that moment**, or the `isDebuggerActive()`
  guard rejects it as syntax error 1006, which reads as a broken command. Dropping the connection is
  what releases a console it has blocked.
- **A `LOGGING` level above 10 buys nothing for console output**, whatever the reference says.

### Track A — brclient: what the agent reads and does

1. **Dump to file — done.** `harness.{h,cpp}`, client-only, because the screen chain, the text
   buffer and the control list are. Triggered by **`MSG("dump", <native OS path>)`**: `brmsg.cpp` is
   in the same module and BR already carries a `MSG` call from the interpreter to it, so this needs no
   protocol message. The path is a native OS filename, as `LOGGING`'s is — BR's own filename
   translation asserts on the client, where no default drive is assigned (`wbuser.cpp:74`).

   The file is UTF-8 JSON: screen chain and GUI mode, rows and columns, cursor, the text of every row
   converted from the buffer's ANSI codepage, attributes as runs rather than per cell, and every
   control with geometry, state, marks, attributes and displayed value. **All rows and columns are
   0-based**, which BASIC's are not, so the file says `rowColBase` rather than leaving a reader to
   guess. Grid cells are walked through `brNativeGridBase` and capped, with the file recording that
   it truncated.

   Verified: valid JSON; printed text appearing at the right rows; the control walk in **GUI OFF**
   (three `BRCT_OLDSTYLE` controls, `commandMode` set) and in **GUI ON** (six `BRCT_LABEL` controls,
   `commandMode` clear, each field split into value and padding), which is the single-walk claim
   holding from both sides. **Not yet verified: a screen-chain switch, and a grid** — no test here
   builds either. The grid path is written but unexercised, so treat it as untested code.

   One trap found by building it: `getStartMarkPos()`/`getEndMarkPos()` assert `isMarked()`
   (`brcontrols.h:332-343`), so an unmarked control must not be asked. A dump that asks crashes BR,
   which is the sharpest possible reminder that a read-only observer is only read-only if every
   accessor it touches tolerates being called.
2. **Dump over the socket — done.** The listener, the actions, the length-governed framing, the
   expansion marker and the `HELLO <token>` handshake, per "The harness channel". Opened by
   **`MSG("harness", <port>)`** and closed with `0`; loopback only, always, and off until asked for.
   The token is 32 random bytes from `makeRandomBytes` written to `harness.token` beside the heap
   reports, rewritten each time the listener opens and deleted when it closes. The port is bound
   before the token is written, so an opening that fails leaves no token behind — it first did it the
   other way round, which replaced the token for a channel that then did not exist. A client that
   exits with the channel still open leaves its file; the next opening replaces it.

   **The token is locked while it waits (2026-11-10).** `harnessWriteToken` opens the file with
   `FILE_SHARE_READ` alone and holds the handle until `harnessRemoveTokenFile` runs on a good
   `HELLO`, so another session can neither delete it (the startup sweep, as before) nor write over
   it: its `CREATE_ALWAYS` fails with `ERROR_SHARING_VIOLATION`, returned as
   **`BREHARNESSTOKENBUSY` (4173)** from `MSG("harness", port)`. The case that found it was a
   primary whose channel was still unclaimed when its spawned child opened one: the child's token
   replaced the primary's, the primary's agent was refused `ERR 14 bad handshake`, and that
   attempt counted toward the primary's lockout. `harnessRemoveTokenFile` deletes only a file this
   session holds, so a refused opening's cleanup cannot take a sibling's. On POSIX the hold is an
   `fcntl` write lock on the open descriptor, which the sweep and the writer test for themselves
   (open without truncating, lock, then truncate); that branch is in no build yet. The debugger's
   `brdebug.token` is locked the same way (`writeDebugCookie`, `removeDebugCookieFile`): Windows
   grants `FILE_SHARE_READ` alone, and Linux's holder now takes `flock(LOCK_EX | LOCK_NB)` where it
   took `LOCK_SH`, which kept the sweep out but let a second writer take a shared lock too and
   write over the token. The refusal is **`BREDEBUGTOKENBUSY` (4176)**; `p42_dbgtoken.py` checks it
   with `p42busy.prc` and `p42_dbgbusy.brs` (**16 checks, 0 failures** on x64 Debug).
   `br_mcp_driver`'s `Dial` refuses a port
   that differs from the token file's before connecting (`TestDialRefusesAnotherChannelsToken`).
   Tested by `h_tokensib.py` with `htokensibb.prc` and `h_tokensibb.brs`: **8 checks, 0 failures**
   on x64 Release.

   **The service hook is not `processOSEventsShort()`, as this document said it would be.** That
   function exists in both binaries, and during a wait the copy that runs is the **server's**, where
   `BRCLIENT` is undefined and the call compiles away to nothing. It lives in
   `processPendingEventsLocal()` (`initwx.cpp`), which is the client's own pump.

   Verified: a connection that never says HELLO is closed unanswered; a wrong token likewise; the
   right token is accepted; `PING`, `SCREEN`, `ATTRS`, `CONTROLS`, `CURSOR` and `GRANT?` answer;
   `KEYS`/`SCANCODE` are refused for want of a grant; and **it answers while the client is blocked
   at an `INPUT FIELDS`**, which is the property that matters — a channel that only worked between
   statements would be useless. Not verified: a human typing at that same instant, a grid (none
   built), and `SHOT`, which is A3.

   Three traps for whoever writes A3, all found by running it. `receiveFromSocket` returns **0 for
   success**, not a byte count, and `SOCKET_ERROR` for both "no data yet" and "peer gone" — so
   readiness must be asked first, with `CheckSockets`, which answers with **the ready socket** rather
   than a flag. And a partial request must be held **between** pump visits: keeping it in a local ate
   every request that did not arrive whole, which `HELLO` and its 64-character token never does.
3. **Screenshots %s the client-side render is done.** `TextWin::OnPaint` is two lines, and the
   second hands the whole screen to any `wxDC`, so a `wxBitmap` and a `wxMemoryDC` produce exactly
   what the window would paint. `TextWin::renderToDC()` wraps it: the colour tracking is cleared
   before, so the draw sets colours on the caller's DC, and again after, so the next real repaint
   does not believe colours set on someone else's %s without that second clear a screenshot quietly
   corrupts the next repaint. The cursor is deliberately left alone, so taking one is invisible to
   the person at the screen; `CURSOR` is how its position is asked for.

   Reached by `MSG("shot", <native OS path>)` and by the channel's `SHOT`, which always writes
   `harness-shot.png` beside the token and answers with that path. **It took a path once, and that
   was a hole:** a connection with no grant could replace any file the user could write with a PNG,
   so reading was a way to write. A path sent now is ignored. `MSG("shot", ...)` keeps its path,
   because it is the program's own call, not the agent's. Verified by reading the image
   back: printed lines, a `PRINT FIELDS` value and the source listing all present and correctly
   placed %s and produced under `gui off` in an unattended run, which is the strongest form of the
   "works obscured" claim, since there was no visible window at all. `PrintWindow`, for what Windows
   actually composited, stays the driver's job and a different question.

   **A failure here must never reach the screen, and that is not a nicety.** A path wx cannot write
   makes it raise a **modal** error dialog, and a modal dialog stops the event pump that services the
   harness channel: the request does not merely fail, the client wedges and every later connection
   sits unaccepted. Found exactly that way, with sockets piling up in `CLOSE_WAIT`. `SaveFile` now
   runs under `wxLogNull` and the failure comes back as an error code. **The rule generalises to A4
   and A5**: anything the socket can ask the client to do must be unable to raise a dialog, because
   whoever is on that socket can otherwise hang BR by asking for something impossible.
4. **Grants — the frame is built; one channel defect is open.** The three states live in the
   client and are read through `harnessGrantState()`, which applies the time box as it answers, so a
   grant that has run out is never reported as held. `MSG("grant", n)` gives one locally: seconds to
   grant, `0` to withdraw, `-1` for exclusive, which does not expire because unattended work has
   nobody to expire for.

   **The socket may lower a grant and never raise one.** `RELEASE` gives one back; `GRANT` over the
   channel is refused outright. That asymmetry is the whole of the frame: an agent that could grant
   itself authority would be restrained by nothing. `KEYS`/`SCANCODE` are refused without a grant
   and answer "not built yet" with one, which is A5's slot.

   The indicator is the **window title**, not the screen, because the screen belongs to the program:
   an indicator painted into it would corrupt the thing the agent is there to read. Exclusive shows
   none — there is no one to inform.

   **The audit record is the grant window**, since BR cannot tell who typed by inspecting a
   keystroke and per-keystroke attribution would be a fiction. Verified in the log: *AI grant given*,
   then *AI grant ended (time expired): held 10 seconds, 0 actions submitted*. That said **10**, the
   authority window, only after a fix: expiry is noticed lazily, and the first version reported when
   it was *noticed* (24 seconds), overstating how long the agent could act. An audit record must
   report the authority, not the bookkeeping.

   Verified end to end: `user` to `granted 30` with the remaining seconds counting down, `KEYS`
   refused before the grant and answering "not built yet" during it, `RELEASE` accepted, and the
   audit line *AI grant ended (released by the agent): held 7 seconds*. The channel also survives a
   program printing continuously throughout — 45 seconds and some 150 `PRINT`s while connected.
5. **Internal injection under grant — done.** `KEYS <text>` and `SCANCODE <n>` queue; `PENDING`
   says how much is left. An ordinary character is queued as its own code, which is what
   `processChar` pushes for a real keystroke (`key_scan.cpp`), so the agent's keys are the same
   values a person's are and take the same path: field editing, typeahead and the rest are exercised
   rather than bypassed.

   **The agent's keys wait in the harness, not in BR's ring**, and are fed one per pump visit. Two
   consequences follow from the same fact — that a key in BR's ring is indistinguishable from the
   user's. A revoke can therefore discard what has not yet gone, which is what "revocation discards
   the agent's queued actions" has to mean; and the feeding paces the typing, which the design
   counts as a safety feature rather than a cosmetic one.

   Verified: `KEYS HELLO-FROM-THE-AGENT` into a live `INPUT FIELDS` produced
   `RECEIVED:[HELLO-FROM-THE-AGENT]`; `SCANCODE 13` submitted the ENTER that closed the field; keys
   are refused outright without a grant; and a `RELEASE` with 57 keys still queued left `PENDING 0`
   with **none of them reaching the screen**. The audit for that window read *held 18 seconds, 4
   actions submitted* — the four that actually went, not the sixty that were asked for, which is
   the distinction an audit record has to keep.
6. **`MSG` completion — done.** The pointer group is live as one unit: `getpos`/`setpos` in screen
   coordinates, `getwpos`/`setwpos` in window coordinates, and `lclick`/`mclick`/`rclick`. Together
   because they are useless apart — the click actions pass no coordinates and no move flag, so they
   click wherever the pointer already is, and a click you cannot aim is not worth enabling.
   `getpos`/`setpos` and the clicks needed bodies written; `getwpos` and the clicks were already
   complete behind the `#if 0`.

   Verified: `setpos 300 200` then `getpos` reads `300 200`; `setwpos 40 30` then `getwpos` reads
   `40 30`; and with a real foreground window the two coordinate systems differ as they should
   (`screen=[-1003 498]`, `window=[755 383]` — that window was on a second monitor). In an
   unattended `gui off` run they coincide, because there is no client area to be relative to.

   **`kb`'s foreground guard survived this step, and proved it** — but was REMOVED on 2026-09-30,
   so this paragraph records what A5 measured, not how BR behaves now: the unattended run stopped
   with error 0413, *target MSG window not on top*, at the `kb` line. The temptation was to reach
   for `send`, which had no such guard; that was precisely the hazard, so the pacing had to be
   measured in a focused session instead.

   **Synthetic input is now stamped.** `keybd_event` and `mouse_event` carried `0` in `dwExtraInfo`
   and now carry a BR signature; the clicks previously echoed `GetMessageExtraInfo()`, which is
   whatever came last. Nothing branches on it — that is the point — but the client can recognise
   its own injections for the log, and the "unstamped input cancels the grant" rule becomes
   possible.

   **The sleep moved inside `brm_SendString`'s character loop.** Measured with BR focused: eight
   characters take 0.11s unpaced and **4.45s at `sleeptime 300`**, where before the whole string
   arrived as one burst after a single sleep. Note that 4.45s over eight characters is 0.55s each,
   not the 0.30s asked for: `sleeptime` sets a floor rather than an interval, because `wb_sleepex`
   pumps events while it waits. Time a demonstration by measuring it, not by multiplying.

   **Left off deliberately**, now under one comment saying why rather than a bare `#if 0`:
   `sendmessage` and `postmessage` (arbitrary messages at arbitrary windows, far more authority than
   driving BR needs, and `putKeyVal` is the better path into BR's own controls), and `show`,
   `topmost` and `notopmost` (`top`, `bottom`, `restore`, `minimize` and `maximize` already cover
   it).

### Track B — brserver: what governs and records

**TRACK B IS COMPLETE (B1-B7), 2026-09-29.** Built in all four Windows configurations; verified in
Win32 Debug. The kit for it is `dbgauth.py` (modes `good`, `bad`, `silent`, `plain`, `off`, `stay`,
`observe`, `watch`), `runb1.py`, `soakb1.py`, `mergelog.py`, and programs p27 and p31-p35.

1. **Securing the debugger channel — done, and verified against four kinds of peer.** TLS 1.3
   through `ssl.cpp`'s `SocketPacket` send/receive pair, then the mutual challenge/response inside
   it, cookie by default, `SECURITY_EVENT` on every outcome, `DEBUG LISTEN` on loopback unless told
   otherwise. What the implementation settled, beyond the design:

   **The split is where the design said, and the flag is the thing being protected.**
   `setDebugChannelDefaults` became three functions — `setDebugSocketOptions`,
   `authenticateDebugChannel`, `setDebugChannelAttached` — with `openDebugChannel` sequencing them
   and closing the socket on refusal. Nothing sets `debuggerAttached` until the peer has proved
   itself, which matters twice over: that one flag is both the permission and the exclusivity lock,
   so an unauthenticated peer that set it would deny the channel as well as take it.

   **`DEBUG AUTH` carries all three modes**, added to `table9k`/`table9s` as the first T9 keyword.
   `COOKIE` (the default) mints 32 random bytes per session and publishes them at
   `%LOCALAPPDATA%\ADS\brdebug.token` — swept at startup, held open while unclaimed, and removed
   on a successful attach, on five consecutive failures (4161) and after five minutes with nobody
   attaching (4163), the assistant channel's lifetime exactly; `TOKEN <64 hex>` takes a fixed secret for a debugger on
   another host and writes no file; `OFF` restores the pre-5.0 plaintext channel and says so in the
   security log. Bare `DEBUG AUTH` reports the mode and, in cookie mode, the token's path. The
   command is refused while a debugger is attached — changing the rule mid-session is not a thing.

   **The token is published before the port opens, not when a peer arrives.** The first version
   minted it inside the authentication, which is too late to be useful: the debugger needs to read
   the file in order to answer the challenge it triggers. `prepareDebugChannelAuth()` now runs at
   the top of `DEBUG LISTEN` and `DEBUG CONNECT`.

   **Domain separation on the two proofs.** Both are keyed by the same secret, so each is labelled
   with the side that must produce it — `BR-DEBUG-PEER` and `BR-DEBUG-BR`. Unlabelled, a peer could
   hand BR a nonce of its choosing and collect a proof to replay in the other direction.

   **Verified, all against the Win32 Debug build**, kit `dbgauth.py` + `runb1.py` + `p27_auth.brs`,
   which listens eight times so one session can be offered peer after peer. `soakb1.py` repeats the
   whole set; `p28off.prc` is the OFF-mode session, `p30token.prc` the TOKEN-mode one, and
   `p29_show.brs` reads `DEBUG AUTH`'s own output back through A1's screen dump, since it goes to
   the console and there is no other way to see it from outside:

   - *plaintext peer* (what a pre-5.0 debugger is) — `acceptSSL` fails with "wrong version number";
     refused. **This is the hole closed**: the twenty-line listener that became the debugger in
     Phase 0.3b now gets nothing.
   - *wrong token* — refused after a successful TLS handshake.
   - *silent peer* — refused, and BR carried on.
   - *correct peer* — attached, and then did real debugger work over the channel:
     `ENTER_INPUT_MODE`, `ISSUE_COMMAND` accepted with result 0, the `DEBUG_MESSAGE_LOG` stream
     flowing, and `SYSTEM` obeyed.
   - *no lockout* — every refusal above was followed, in the same BR run, by a successful attach.
     The denial-of-service half of the hole is closed with the access half.
   - *the security record* — one line per outcome, with the peer address, and on success the
     version and cipher: `Debugger authenticated over TLSv1.3 TLS_AES_256_GCM_SHA384 from
     127.0.0.1`.
   - *loopback default* — `netstat` shows `127.0.0.1:9555`, as it did when that part landed.

   **The timeout is a floor, not an interval — the A6 lesson again.** `debuggerTimeOut` is 5
   seconds and the wait loop is 50 × 100 ms, but a silent peer is refused after about **10**
   seconds of wall clock, because each turn of the loop also runs `wbIdleProc()`. Time it by
   measuring, not by multiplying.

   **The channel closed itself from inside its own error logging, and that took most of the
   work.** Symptom: an access violation on roughly one exit in two, but only with TLS, only with
   an authenticated debugger, and only when the debugger was the one that issued `SYSTEM`. The
   chain, once found, is short. `checkSSL` hits an SSL error; `processErrorSSL` **logs** it;
   `sendDebugMessageLog` forwards every log event to the attached debugger; that send goes out on
   the very session that just failed and fails too; the failure closes the channel and frees
   `debuggerSSL` — while `checkSSL` is still on the stack. Control returns to a caller that
   still believes it holds a session, and `receiveFromSSL(NULL, …)` faults reading offset 12 of
   a null `SSLSocket`.

   The fix is a re-entrancy guard, `DebugChannelInUse`, held across the channel's own send and
   receive; `sendDebugMessageLog` does not forward while it is set. The caller also retests
   `debuggerSSL` after `checkSSL` — belt to that brace. **The general rule, and it is the same
   shape as A3's modal dialog:** anything the channel does on error must not re-enter the channel.
   A transport that reports its own failures through itself has no way to fail once.

   Verified by soak, because the fault was intermittent and two earlier "fixes" looked right for
   three or four runs and then did not: 6 rounds — 4 peers each — with no crash, against a
   build that crashed in 4 to 6 rounds out of 6. `soakb1.py` in the kit is that harness, and
   anything touching this path should be run through it rather than tried once.

   **How it was found, since the same tools will be wanted again.** The crash dump uploader is a
   separate program that is not installed here, so BR's log said only that something had gone
   wrong. `dumpcore.cpp` now logs the **exception code, the faulting address as an RVA, and the
   address being read or written**, which turns an unhandled exception into something resolvable
   against a link map (`/MAP` on a throwaway build) long afterwards. That is what identified
   `receiveFromSSL+26`; hours of bisecting had not. Two further traps worth knowing: `0xDD` is the
   CRT debug heap's fill for freed memory, so an address like `0xDDDDDDD4` names a use-after-free
   on sight; and the unhandled-exception filter is **process-wide**, so a fault anywhere is
   reported by whichever module registered last — here the client, which made a server-side
   fault look like a client one for some time.

   **Four defects fixed along the way, none of them in the new design:**
   - `DEBUG LISTEN` **ignored the return of `processListenOnSocket`** and called
     `setDebugChannelDefaults` regardless, so a failed accept or a break at the listen prompt left
     `debuggerAttached` true with a socket of zero — and the next `DEBUG LISTEN` was then refused
     with 420. Pre-existing; fixed here because the same lines were being rewritten.
   - Bare `DEBUG AUTH` **crashed** (`c0000005`) on its first run: `st_out` writes through state that
     `setupStatusOut` installs, and `DEBUG INTERNAL MESSAGES` calls it first for exactly that
     reason.
   - `getCipherInformationString` is a multi-line diagnosis written for a *client* handshake
     failure; called after a successful server-side handshake it asserted "handshake failed before
     ServerHello… the server does not support TLS 1.3" into the security log. Replaced with a new
     one-fact accessor, `getCipherNameSSL`. While there, `initSSL_CTX` logged "Setting minimum
     protocol version to (null)" every run from a pointer that was never assigned.
   - **Exit never closed the debugger channel**, leaving it to process teardown. That was
     survivable while the channel was a bare socket; with a TLS session on it the event pump keeps
     calling `checkSSL` right through the exit, and `cleanupSSL()` is on the same path.
     `closeDebugChannelOnExit()` now runs at the top of `cleanupNormalExits()`, before anything
     below it pumps.

   **Compatibility is a real break and needs saying plainly.** An existing debugger build speaks
   neither TLS nor the token exchange, so it is refused. `DEBUG AUTH OFF` is the transition escape
   and was verified to restore the old behaviour exactly — a plaintext peer attaches and drives the
   session, with both the switch and the attach recorded as security events. It belongs in the
   release notes, and does.
2. **Observer tee — done.** `DEBUG OBSERVE [<port>]` accepts one observer on **9556** and
   mirrors to it, in `sendMessage`, every packet BR sends the debugger. `DEBUG OBSERVE OFF` detaches
   it. It authenticates exactly as the debugger does, because it is shown exactly the same material:
   B1's `authenticateChannel` was generalised to take a socket and an SSL session rather than reach
   for the debugger's globals, so one exchange now serves both and the log names which channel it is
   talking about.

   **Read-only is enforced by what the code cannot do, not by intention.** The mirror cannot change
   what the debugger receives, what `sendMessage` returns, or how long it takes beyond the write; an
   observer that has gone away is dropped quietly rather than reported as a debug channel error. The
   packet goes to the observer **before** the debugger, so the last thing BR tried to send still
   reaches the observer when the debugger has already gone.

   **An observer that leaves is reaped.** It is defined never to send, so anything readable on its
   socket is end-of-file or a peer that has misunderstood; `serviceObserver()` treats both the same
   way. Without it a departed observer was only noticed when a mirrored write finally failed, which
   on a loopback socket can take many packets — measured, not assumed.

   Verified: an observer authenticated on its own port received the whole session — the
   `DEBUG_MESSAGE_LOG` stream, both `ENTER_INPUT_MODE`s, both `ISSUE_COMMAND_RESPONSE`s and
   `TERMINATE_CONNECTION`, twelve packets in order; a debugger attaching with the observer already
   dead worked normally and the observer was reaped; and the security log distinguishes the two
   (*Observer authenticated over TLSv1.3 ...* beside *Debugger authenticated over TLSv1.3 ...*).
3. **The screen tee — done.** `DEBUG SCREENLOG <path>`, `DEBUG SCREENLOG OFF`, mirroring in
   `screenBase` (`brmain.cpp`), which both `screen()` overloads funnel through — so it is one call
   site, not the 47 that `WRITEC_SCR` has. One line per record: millisecond timestamp, the window's
   BASIC file number (`ufnbr`, 0 being the terminal), the action, row and column, the length, the
   attribute for the `ATTR` forms, and the text with anything unprintable escaped, because a screen
   write carries attribute-propagation bytes that would otherwise break the line structure a reader
   depends on.

   **Only the actions that put something on the screen are recorded** — `WRITEB_SCR`, `WRITEC_SCR`,
   `WRITEB_ATTR`, `WRITEC_ATTR`, `WRITECC_ATTR`, `DELETE_CHAR`, `INSERT_CHAR`. Cursor moves, opens
   and font changes would bury the stream that makes this worth having. Write failures are
   swallowed, `debugPretty`'s discipline, so the tee cannot change what `screen()` does including by
   failing.

   Verified against the claim that justifies it. A 42-line run on a 24-row screen: `TEE-START`,
   `line 1` and `line 5` are **in the tee and absent from a dump taken immediately afterwards**,
   while `line 30` and `TEE-END` are in both — which is the whole argument for a tee over sampling,
   demonstrated rather than asserted. A line printed after `DEBUG SCREENLOG OFF` appears in neither.
   And the merge works: `mergelog.py` in the kit interleaves the event log and the tee by timestamp,
   putting *Command entered DEBUG SCREENLOG*, then *Screen tee opened*, then each line as it
   appeared — the "command beside what it produced" this was for.
4. **The `CLOSE ,FREE` fix**, before the gate, which is not sufficient without it: refuse a free of a
   read-only channel (`fio == OFW_READ`) beside the share-mode guard in `bfclose`. A behaviour change
   in shipped code, so it wants a release note.
5. **The gate — done, both enforcement points.** In `bopen` (`bopen.cpp`), an `OPEN` that can write
   must also create: refused with **4153** unless `NEW` is specified. In `command.cpp`, immediately
   after the command token is resolved and logged, a restricted session is refused **4154** for
   `FREE`, `RENAME`, `COPY`, `DEL`, `RMDIR`, `REPLACE`, `SAVE` and `SYSTEM`. The classifier
   `isRestrictedCommand()` is a list rather than a blanket refusal, and that carries the standing
   cost the design named: a file-altering command added to `table1k` later has to be classified
   there when it is added.

   **The command filter is a permit list, and it is one because the refused list was wrong.**
   The first version enumerated what the design text named — `FREE`, `RENAME`, `COPY`, `DEL`,
   `RMDIR`, `REPLACE`, `SAVE`, `SYSTEM` — and missed three commands out of forty-one in `table1k`:
   **`DROP`**, which empties an existing file from the same `wbos.cpp` branch as `FREE`;
   **`PROTECT`**, which `chmod`s one; and **`EDIT`**, which calls `shell()` on the configured
   editor and so leaves BR entirely. This document had already named that risk — "the standing
   cost of a permit-list over a blanket refusal" — and the first implementation committed the
   error the sentence warns about, by trusting the enumeration instead of auditing the table.

   `isRestrictedCommand` is now inverted: everything is refused in a restricted session unless it
   is explicitly permitted. A command added to `table1k` later is refused until somebody
   classifies it, which is the direction a security boundary should fail in.

   **`SYSTEM` is two commands and only one of them is dangerous.** `SYSTEM "<string>"` calls
   `shell()` (`command7.cpp:839`) and runs an operating system command — which is the real reason
   it has to be blocked, far stronger than "it escapes BR": the shell is outside every gate BR
   has, so `SYSTEM "del sales.dat"` would make the whole restriction cosmetic. `SYSTEM`, `SYSTEM
   <n>` and `SYSTEM LOGOFF` merely exit, and exiting is what clears the latch anyway. The token is
   therefore permitted and the **shell form is refused inside `command7.cpp`**, at the point where
   BR has already parsed which form it is — deliberately not in the command filter, where a second
   parser could disagree with the real one. A restricted session can now end itself, which it
   could not before.

   **Configuration is filtered by operation, not by refusing the `CONFIG` command.** Refusing the
   command would guard nothing: a supplementary session is started with a configuration file of
   the caller's choosing, so anything refused at run time would simply be written into that file
   instead. `isConfigOperationRestricted` in `config.cpp` is therefore a permit list checked at the
   single `tokensub` into `tablek` that **both** routes pass through — the file at startup and the
   command at run time. Refused, with the reason recorded beside each in the code: `SPOOLCMD` and
   `SHELL` (a shell at print time), `EDITOR` and `PDF_READER` (name a program to launch),
   `LOGGING` (the audit trail), `DATABASE` (an SQL write path the file gate does not cover),
   `HTTP`/`HTTPS` (network listeners), `SETENV`, `WBSERVER`/`BRSERVER` (the file recording the
   restriction) and `WSID`/`LOGIN_NAME` (the identity it is recorded against). `DATABASE` stays
   refused as a whole pending a narrower rule: the cost is that a restricted session cannot
   report from a database at all, which is a real one.

   **`EXECUTE`, `DRIVE` and `USERLEVEL` were refused at first and that was wrong**, caught by
   Gordon asking why `EXECUTE` was on the list.
   `CONFIG EXECUTE` sets `t.cmdline`, which goes through `ANALYZE` and `tokensub` into `table1k`
   in `command.cpp` like any other command — so the startup command is already filtered by the
   command permit list, and refusing it closed nothing while breaking the ordinary way to say
   what a supplementary session should run. `DRIVE` confers no capability either: reading is
   permitted anywhere already, a writable open is gated by its disposition rather than by where
   the file is, and `NEW` onto an existing file fails with 4150 however the drive is mapped —
   while a reporting session that cannot declare its drives cannot find the data. And `USERLEVEL`
   is not a privilege level at all despite the name — `startup.cpp:88` initialises it as the field
   help level, 0 to 3, and `fieldin.cpp:975` reads it to decide whether a field's help text
   appears. All three are now permitted. The lesson is the one this section keeps relearning: a
   permit list is only as good as the reasoning behind each entry, and "it sounds powerful" is
   not reasoning — two of these three were classified on the strength of a keyword's name. From a `CONFIG`
   command the refusal returns
   4154; from a configuration file it reports the line and carries on, which is BR's existing
   handling for a bad statement.

   `CONFIG SPOOLCMD` deserves singling out: it was a **complete escape in three permitted steps** —
   set the spool command, print something, and `spool.cpp:606` hands it to `shell()`.

   **Then every caller of `shell()` was audited, rather than reasoning about which ones mattered.**
   That audit was done against the restricted session's gates, and it did *not* generalise: when the
   same question was asked of an attached assistant later, three of the callers were guarded and the
   rest were not. The gate now lives inside `shell()` itself, which is the only place every route
   passes through. The two that this audit left:

   - **`spool.cpp:606`.** Refusing `CONFIG SPOOLCMD` does not help if the spool command was set
     *before* the session was restricted, and printing is deliberately allowed — so the command
     would still run on the restricted session's behalf. Now refused at the spool itself.

     *Revised 2026-09-30:* `SPOOLCMD` is now **permitted** as a configuration statement, and the
     refusal at the spool is the whole rule. Setting a spool command does nothing; running it is
     what reaches outside BR, and that is refused where it would happen — the same principle as the
     file rule. (Since `DEBUG RESTRICT` was removed a session is restricted before it reads its
     configuration, so "set before the session was restricted" can no longer happen anyway.)
     `p36` sets one that would write a marker file, prints, and checks the print is refused with
     4154 and the marker never appears.
   - **`remoteargs.cpp`, `KEYBOARDSHELL_CALL`.** **Ctrl-]** opens an operating system shell from
     the terminal. One keystroke walked around the entire gate. Refused where the request lands,
     which covers a person pressing it, keys injected through `MSG`, and an agent holding a grant.

   **A gap that was recorded here and is closed.** This said that in client/server mode the
   Ctrl-] branch spawned `COMSPEC` on the *client* and never reached the server, so the
   server-side refusal could not see it. That is not how the path runs: `keyboardShell()`
   (`terminal.cpp`) sends `KEYBOARDSHELL_CALL`, and the **server** is what calls `shell()`
   (`remoteargs.cpp`, inside `#ifdef BRMAIN`). The client asks; the server refuses. So the
   refusal covers both modes as written, and the latch did not need to be carried client-side
   for this. Corrected 2026-10-04 after reading the path rather than the note.

   **And one thing that is not a hole, though it looks like one.** In an *unrestricted* session an
   agent holding a grant can type `SYSTEM "cmd"` at the Ready prompt, or press Ctrl-], exactly as
   the person could. That is not a leak in the grant; it is what the grant *is* — the authority to
   act as the user, on a channel whose whole design goal is that BR cannot tell the difference.
   Blocking one keystroke would be theatre while the command prompt is right there. The honest
   statement is that a grant in an unrestricted session confers the user's authority, and the
   place to run untrusted work is a restricted session. That is now said plainly in
   `AI-Access-Summary.md` rather than left to be inferred.

   **Utility opens are exempt, and they have to be.** `INDEX` is deliberately permitted, but it
   opens the data file on its own behalf through `bopenOpenStruct` — the utility path, also used by
   the ODBC driver — and the open gate refused it, so a permitted command failed anyway. Found by
   running the test, not by reading: `INDEX returned err=4153`. The gate now applies to `OPEN`
   statements only. Permitting a command and then gating the work it does is a permission that
   means nothing.

   *Superseded 2026-09-30.* The exemption was the hole: `INDEX` and `SORT` could then write their
   output over any existing file, and so could `DEBUG LOG`, `DEBUG SCREENLOG` and `DEBUG PROFILE`,
   which never passed through `bopen`. The resolution was not to gate the utility path but to move
   the check below it — see "The rule as built, from 2026-09-30" under *Generated code*.

   Verified with the same operations run **before and after** the latch, so that what refuses them
   afterwards is shown to be the gate and not something that would have refused anyway: `OUTIN,USE`
   and `OUTPUT,REPLACE` on an existing file both succeed before and are refused 4153 after; `INPUT`
   still opens; `OUTPUT,NEW` still opens and the file it creates is still freeable; all six blocked
   commands refused 4154 individually; `INDEX` still runs; and the protected file is intact at the
   end. Every refusal is in the log as a `SECURITY_EVENT` naming the file or the command.

   **`SYSTEM` being blocked has a consequence to accept:** a latched session cannot end itself from
   a program, so it is ended from outside — which is what a disposable session spawned and released
   by the application does anyway. Confirmed in the test, where the closing `SYSTEM` was refused and the
   session had to be terminated externally.

   One thing measured and *not* a defect of this work: `RECL=` on an `OPEN ... INPUT` of an internal
   file returns 605, "syntax error in open string", with or without the gate. The first version of
   the test used that form and misread its own failure.
6. **The session latch — done.** `RESTRICTED_SESSION_REGION_ID` 411 in `wbserver.h` (410 is ODBC's;
   409 was OnQ's and is not reused, since deployed `wbserver.dat` files may still carry records under
   it), set with `wbAddUserID` and read with `wbIsNewUserID`. `latchRestrictedSession()` and
   `isRestrictedSession()` live in `wbserver.cpp`, which owns the region machinery.

   **Held two ways on purpose.** The byte lock in `wbserver.dat` is what other processes read and
   what the operating system releases if this one dies; the flag in memory is what the gate tests,
   because the gate runs at every `OPEN` and every command and must not pay for a file lock each
   time. `isRestrictedSessionElsewhere(wsid, sessionid)` is how another process asks.

   **It cannot go stale, and that was verified by accident and then on purpose.** Every test run
   ended with the session killed outright while latched — `SYSTEM` is blocked, so there was no
   other way — and the next run, same WSID, started unrestricted every time. That is the property
   the byte lock was chosen for.

   **It was first set by hand, with `DEBUG RESTRICT`, and that command is gone.** It latched the
   running session, one way, until C3 existed; it then remained for the gate tests, which compared
   operations before and after the latch within one session. It was **removed after Track C**,
   because a session latched while running has already had its configuration applied unfiltered —
   the window C3 exists to close — and a switch that opens that window is not worth keeping for
   testing's convenience. The only way to restrict a session now is to start one restricted, with
   `SPAWN_RESTRICTED`. The gate tests (`p34`, `p36`, and `c2`'s restricted check) run their "after"
   half in a spawned session and copy its report into their own; their results are unchanged.
   `DEBUG RESTRICT` now fails as an unknown qualifier, error 1006.
7. **Variable watch — done, and it was much smaller than costed.** The machinery already existed:
   `ChangeVariableInformation` tracks the old value, `checkbreakpoints` (`run.cpp`) notices the
   change, stops the program and sends `DEBUG_VARIABLE_BREAK`. What was missing is the thing the
   programmer actually needs.

   **The value was computed only on the branch that had no debugger to send it to.** `run.cpp` read
   `if (!isDebuggerActive()) displayVariableInfo(...)` — so with a debugger attached BR worked out
   nothing, and the debugger was told a name and no value. The guard is gone; `displayVariableInfo`
   now runs either way, before `updateData` so the old value is still there to compare against, and
   `displayVariableOutput` decides where the text goes: to the debugger as the new
   `DEBUG_VARIABLE_CHANGED` (113) when one is attached, to the screen as before when not.

   `DEBUG_VARIABLE_BREAK` is unchanged and still sent, so an existing debugger sees exactly what it
   saw before. The text is the one the console already produced — line, clause, variable, subscript
   where it is an array, and value — so there is one format, not two.

   **Audited at the break, not per keystroke.** Every stop is logged: *Variable watch stopped: line
   00090:01, X, value = 10*. Stepping and displaying from there use the command path that already
   exists, which is why this needed no new protocol beyond the one message.

   Verified: `BREAK X` on a loop assigning 10, 20 and 30 stopped three times, and the debugger
   received all three values and resumed each time with `GO`; the three audit lines match.

### Track C — the channel and the resource

1. **The text channel by hand — done, and it needed no C++ as predicted.** `c1_chat.brs` opens an
   independent window with a text box, exchanges files with `c1agent.py`, and displays the reply.
   Two files in each direction, payload first and marker second, so neither side can read something
   that is still being written. It runs unattended when `c1_auto.txt` supplies the prompts, which is
   how it is tested; a person just types instead.

   **`SLEEP` is a function, not a statement, and it is exactly the wait the design wanted.**
   `numfunct.cpp` implements it as a loop over `wbIdleProc()` that also runs the keyboard through
   `runKeyboard`, returning `BRETRAPSLEEPKEY` on a trapped key. So submit-then-poll needs nothing
   built: `LET X=SLEEP(.25)` in a poll loop yields, redraws and stays interruptible.

   **The no-threads claim is now measured, not argued.** With the agent deliberately taking five
   seconds, the screen tee from B3 records the terminal repainting once a second *between* the
   prompt and the reply — `...waiting 1s`, `2s`, `3s`, `4s`, each timestamped, then the reply. A
   long agent turn does not freeze the session, and the evidence is a file rather than an
   impression.

   **The count drifts, and the reason is the familiar one.** `SLEEP(.25)` takes about a third of a
   second, because the loop only exits after `wbIdleProc()` returns, and that waits up to **100**
   ms at a time — a dead sleep in local mode. (This said 10 ms, copying the comment in
   `numfunct.cpp`; C2 measured it, and the comment is corrected.) The one-second ticks land about
   1.33 s apart. Third time this pattern has appeared — A6's
   `sleeptime`, B1's authentication timeout, now this: **every wait in BR is a floor, not an
   interval.** Anything that needs real elapsed time must read the clock.

   **A defect found by testing the interruptibility half, and fixed.** `FORCE_BREAK` from the
   debugger was acknowledged and then ignored for as long as the program kept running: BR sat in
   the poll and the break arrived only when the program next waited for input of its own. Cause:
   `processKeyboard()` (`brmain.cpp`) skips the client entirely unless `keyboardSignal` says a key
   is waiting, and that flag is raised only by `KEYBOARD_MOUSE_ASYNC` from a real key. The
   debugger's key goes in through `DEBUGGERKEY_ASYNC` → `setDebuggerScancode`, which never signalled
   anything. `KB_DEBUG_BREAK` is commented "allow the debugger to interrupt BR", and it could not
   interrupt BR at the one moment that matters — when BR is busy. The handler now calls
   `keyIsAvailable()`, the function that exists for precisely this. Verified: the break that
   produced nothing in fifteen seconds now returns `ENTER_INPUT_MODE` in the same second.

   Not yet tested: a person pressing ATTN at the keyboard. The mechanism is the same
   `runKeyboard` path the fix restored, but it wants an interactive session to confirm.
2. **The channel — done: the agent answers on the screen, through the keyboard.** A program asks
   the agent the way it would ask a person: the question on the screen, in a window, with a field
   to answer in. The agent reads the screen over the harness channel it already holds (A2) and,
   while it holds a grant (A4), types the answer and Enter through the same key path a person's
   keystrokes take (A5). Nothing was built for this in C++: it is A2, A4 and A5 used together, and
   the proof that the input rule in "Input is device-layer, and indistinguishable by design" is
   enough on its own.

   **C2 was first built another way, and that was a mistake to record.** The first version was a
   DLL, `bragent.dll`, with its own socket to a broker process, its own token and its own HMAC
   exchange, delivering answers straight into BASIC variables. It worked and was tested, and it
   broke the rule this document states in Channel 2: it gave the agent a second way into BR that a
   person's input does not take. The plan text for this step had said "replace the file exchange
   with the `DLL` call", and it was followed without being checked against that rule. The DLL, the
   broker and the second token were removed. What that version found about `DLL()` itself stands —
   see the next paragraph.

   **Every `DLL()` call cost at least 100 ms — fixed, and independent of the agent.** Measured while
   the DLL version existed: **109 ms for a call that did nothing**. `callDLLFunction` (`fields.cpp`)
   runs the DLL on its own thread and waited with a `wbIdleProc()` loop, and `wbIdleProc()` is
   `processOSEventsShort(100000)`, which in local mode is a dead `Sleep(100)` with nothing to wake
   it when the DLL thread finishes. The comment beside `SLEEP`'s loop said it slept 10 ms; it sleeps
   100, and C1's drift and A6's floor were both this. The wait now blocks on an event the DLL thread
   raises (`MsgWaitForMultipleObjects`), still waking for window messages and every 100 ms, so a
   long call behaves as before; an empty call measured under 1 ms after. It applies to every `DLL()`
   call BR makes. `MSG()` does not take that path and was never affected.

   **Who answers is not the program's business.** A person at the screen can answer the same
   question, and BR cannot tell the difference — which is the design, not a gap. The grant log is
   the record: in the C2 run, *AI grant ended (withdrawn): held 2 seconds, 26 actions submitted*.
   With the grant withdrawn the agent can still read the question but its keys are refused (error
   5 on the harness), so the question waits for a person or times out.

   **A modal dialog stops the agent, even one the harness did not cause.** The first runs took
   30 seconds to answer. The harness had accepted the agent's connection and then answered nothing
   until the field's wait ran out. The cause was not the wait: a Debug client that finds a pending
   heap-report marker (`%LOCALAPPDATA%\ADS\BRClient-heap.pending`) shows a modal notice at its first
   keyboard wait, attended runs only, and the notice times out after 30 seconds. A modal dialog
   stops the event pump the harness is serviced from — A3's rule, arriving from the other side.
   Debug builds only; `runtrackc.py` sets such a marker aside before an attended run, and says so.

   **Test runs are attended now.** An unattended BR ends at its first input wait, and a question is
   an input wait. So C2 and C4 run with a BR window open; the grant, which is the person's to give,
   is given by the test program in their place, and says so.

   Verified (`c2_answer.brs` with `agentdriver.py`, Win32 and x64 Debug): a question answered in
   about 1.3 seconds from the question appearing, 26 keystrokes; the same question with the grant
   withdrawn, the agent's keys refused and the field timing out after 4 seconds, empty.
3. **Disposable sessions — done.** `SPAWN_RESTRICTED(command$ [, config$ [, wait [, label$]]])` starts a new
   `brserver` on this WSID, which gives it the next free session number, running `command$` as its
   startup command. With no wait it returns the process id; with one it yields as `SLEEP` does
   until the session ends and returns its exit code, or ends it and returns **4157** if it outlives
   the wait — a disposable session nobody is waiting for has no business holding a session number.
   `config$` defaults to this session's configuration file. A restricted session may not call it
   (4154).

   **The latch is set before the configuration is read, by a command-line flag.** `--restricted`
   is parsed with the other arguments and acted on immediately before `processConfig`, so the B5
   filter applies to the configuration file itself. The byte lock that makes the latch visible to
   other processes cannot be written yet — there is no WSID — so `latchRestrictedSession()` now sets
   the flag at once and `recordRestrictedSessionLatch()` writes the lock when startup has assigned
   one. Measured in the log, in order: *Session restricted*, then *refused the configuration
   operation* for `LOGGING`, `EDITOR`, `SETENV`, `WBSERVER`, `WSID=UNIQUE`, `SPOOLCMD` and `SHELL`
   from the caller's file, then *WSID has been assigned*, then *latch recorded for wsid 1 session 2*.

   **Two things the child cannot configure, and so is handed.** `LOGGING` is refused because the
   log is the audit trail — which left a spawned session with no log at all. And `WBSERVER` is
   refused because it names the file the latch is recorded in — which would have sent the child to
   the default `wbserver.dat`, a different file from its parent's, taking its session number,
   recording its latch and being counted somewhere else entirely. The parent therefore passes
   `--restricted-log=<folder>` (the **directory** of its own log, and nothing else: BR names the
   file `restricted-<session>.log` and sets the level) and
   `--restricted-wbserver=<dir>` (its own `wbserver.dat`, as an OS path so the child's `DRIVE`
   statements do not matter). Both are accepted only with `--restricted`. The child's WSID comes
   from `-<wsid>` on the same command line, `WSID` being refused too.

   **Saying what a child is for (2026-11-10).** `label$`, the fourth argument, travels as
   `--restricted-label=<text>` (accepted only with `--restricted`) and is written into the first
   entry of the child's audit log, `…for session 012, started for "<label>": …`. It is the parent's
   word, from the unrestricted side. The child's own word is `DEBUG_STR`: in a restricted session
   `numfunct.cpp` writes it as `Program note: <text>`, at no lower than `SECURITY_EVENT`. Both go
   through `cleanLogNote` (`logger.cpp`): control characters become spaces, because a newline in
   a note would let it write a log header of its own; `"` becomes `'` and trailing backslashes go,
   because the label also rides the Windows command line, where either would break or escape the
   quoting `appendArgument` puts round it; and it is cut to `LOG_NOTE_MAX` (200). The child
   cleans the label again on arrival, as the command line is anybody's to write. Tested by
   `h_note.py` with `hnotep.prc`, `hnotec.prc`, `h_note_p.brs` and `h_note_c.brs`: **13 checks, 0
   failures** on x64 Debug. **brls still knows `SPAWN_RESTRICTED` as 1 to 3 arguments** and
   reports `h_note_p.brs:17` as an error until its signature table is updated.

   **Throttled below nine, keeping the last session for the person**: a spawn is refused **4155**
   when eight of the WSID's nine sessions are in use. Released when finished: every session number
   and latch is a byte lock, which the operating system drops with the process, including one
   ended at its timeout.

   **Local mode on Windows only** (4156 otherwise). The child starts its own client, which in
   client/server mode would open a window on the server; and there is no unix spawn yet.

   `isRestrictedSessionElsewhere` was wrong and nothing had noticed: it called `wbIsNewUserID`,
   which asks whether any session on the WSID *other than* the one named holds the region, and so
   answered about the wrong session. It now probes the one byte that belongs to the session asked
   about.

   Verified (`c3_spawn.brs` with `c3_child.brs`, `c3_hold.brs`, `c3quick.prc`; Win32 and x64
   Debug): a child on WSID 01 as session 2 while the parent is session 1; inside it, `OUTIN USE`
   of existing data refused 4153, `INPUT` allowed, `CONFIG LOGGING`, `SPAWN_RESTRICTED` and `DLL`
   refused 4154, from its first statement; exit code 0 collected; the parent still able to write;
   a holder ended at its 3-second wait with 4157; a process id returned with no wait; exactly
   seven holders started before 4155; and, once they ended, a session free again and `SYSTEM 3`'s
   exit code 3 returned. All of them logging to the parent's file.
4. **Stored prompts as a resource — done**, as a BR library, `agentlib.brs` in the kit, over the
   C2 channel and the C3 spawn. No C++ was needed.

   **A stored prompt is a file**, `<name>.prompt`: an `ANSWER` line, a `TIMEOUT` line, then the
   question with `[1]` to `[9]` replaced from `MAT PARM$`. The `ANSWER` line is the answer field's
   own spec — `C n`, `N w.d`, or `CODE` — declared by the application, not by the agent, and it is
   the trust level: BR's field handling checks the answer exactly as it checks a person's typing.
   The library puts the question in a window whose first line is `QUESTION <id> <name>` — for
   whoever answers; a person can ignore it — and waits on the field with `WAIT=` the prompt's
   timeout.

   - `FNAGENT_ASK(NAME$, MAT PARM$, &REPLY$)` — a `C n` answer; refuses a `CODE` prompt (-12),
     because code goes to a file, never into a variable.
   - `FNAGENT_NUMBER(NAME$, MAT PARM$, &VALUE)` — an `N w.d` answer, taken by a numeric field;
     an answer that will not convert is -5 and leaves `VALUE` as it was.
   - `FNAGENT_CODE(NAME$, MAT PARM$, &SOURCE$ [, FORPROGRAMMER])` — source typed a line at a
     time, following a `SOURCE <id> LINE <n>` line, an empty line ending it; written to
     `agent\user\` or `agent\programmer\`, named with its date and time, and **not run**. The two
     directories are the retention split: programmer code kept, user code sweepable once a period
     is set.
   - `FNAGENT_SHOW(SOURCE$ [, TIMEOUT])` — shows the source in a window and asks; 1 only for `Y`.
     This is the human action, and **it withdraws the agent's grant before it asks**: the approval
     is a field, and the agent types into fields, so without that the agent could approve its own
     code. Withdrawing the grant also discards any keys the agent had queued, so a `Y` typed ahead
     cannot land there either. The person gives the grant again afterwards if they want to. With a
     `TIMEOUT`, no answer is a no.
   - `FNAGENT_RUN(SOURCE$ [, TIMEOUT])` — runs it in a disposable restricted session through
     `SPAWN_RESTRICTED`, waiting, and returns its exit code. Called only after `FNAGENT_SHOW`, and
     nothing in the library calls it for the agent.

   Returns are 0, -5 for an answer that would not convert, -10 for no answer within the timeout,
   -11 for no such prompt, -12 for the wrong function for the kind. **Everything is logged at
   level 5**, beside the latch and the gate's refusals, one line per entry: each question shown,
   each answer taken, each timeout, each source written with its line count, each run with its
   outcome.

   **What BR's own fields do with an answer, measured rather than assumed** — the same as they do
   with a person's typing, which is the point, but not all of it is a refusal:

   - `12x4` into `N 10.2`: refused on conversion, -5, value untouched.
   - `12.345` into `N 10.2`: **accepted and rounded to 12.35**. The field's decimal places round,
     they do not reject.
   - sixteen characters into `C 10`: **the first ten kept**; the field stops taking characters.

   An application that needs a stricter rule than the field's — refuse rather than round — checks
   the value itself, as it would for a person.

   Verified (`c4_prompts.brs` with `agentdriver.py`, Win32 and x64 Debug): the text and number
   answers; the three field behaviours above; no such prompt -11, code into a variable and text as
   a number -12; an 18-line program typed in about 14 seconds (some thousand keystrokes), written
   and **not** run — the report it would produce does not exist. Then the approval: the stand-in
   agent deliberately typed `Y` into it, and was refused — *no grant is held* — so after its four
   seconds the answer was no, and the log says *shown for approval, the assistant's grant
   withdrawn; answer []*. Then, with the test standing in for a person's `Y`, run restricted with
   exit code 0. Inside it the generated program read the existing file, wrote its report `NEW`, and was
   refused `OUTIN USE` of that file (4153) and `SPAWN_RESTRICTED` (4154); the existing file still
   held its two records afterwards. Programmer code went to its own directory unrun; a question the
   agent leaves alone timed out at its 3 seconds, -10; and with the grant withdrawn the agent's keys
   were refused and the question timed out, -10. The grant log for the run: *held 56 seconds, 2015
   actions submitted*.

   **Not verified: a person answering the approval.** That it refuses the agent is verified; that a
   person's `Y` runs the program wants a person. The test calls `FNAGENT_RUN` directly in their
   place, which is exactly what an application must never do on the agent's behalf.

### Order of attack

**Phase 0 and all three tracks are complete.** The ordering argument below is kept because it
explains why things landed as they did, not because anything still waits on it.

The reasoning was: B1 first, because the debugger channel was unauthenticated and B2 waited on it;
A1 and B3 alongside, since the dump makes every later step verifiable and the screen tee is what
makes a console session observable at all; then A2 and A3 to finish the read-only picture; then B5,
so the governing rules existed before anything could write; then A4, A5 and Track C, with A6 and B7
last as the most invasive of their tracks. Within Track C the order was forced: C4 needed the channel
from C2 and the disposable session from C3.

## Settled

Recorded here because each was an open question and the answer now governs a section above:

- **The observer tee is built** — not weighed against tailing `DEBUG LOG` (Channel 1).
- **An assistant attached as the debugger uses both channels, and may grant itself the keyboard
  through the debugger** (decided 2026-09-30). It holds the programmer's authority there, and the
  programmer outranks the user, so `MSG("harness", …)` and `MSG("grant", …)` sent through the
  debugger channel are legitimate, as often as needed. A grant is never raised over the harness
  channel itself — `GRANT` there is refused with `ERR 8` whoever asks. The harness supplies what the
  debugger channel lacks (the screen, fields, controls, and acting as an operator); it replaces
  `DEBUG SCREENLOG` for anything that stays on the screen, but not for output that scrolls past
  between reads. Verified by `br/aiaccess/dualchannel_test.py`; described in
  `AI-Access-Protocol.md` 7.11, "Both channels at once".
- **The step position reaches the debugger** (2026-09-30): a step stop sends `DEBUG_LINE_BREAK` as a
  breakpoint does, once per stop. The debugger bridge (`br/aiaccess/dbgbridge.py`) holds the
  channel between an assistant's turns; turn-taking is by protocol — the assistant says "request
  complete".
- **Generated code**: programmer-requested is approved by the programmer; user-requested may read
  and create but not overwrite — enforced by a runtime gate rather than a source scan (Channel 2).
  Since 2026-09-30 the gate is the session's own-files rule: a restricted session may change only
  what it created, checked by path and identity in the `wb…` layer; it replaced "an `OPEN` for
  output must carry `NEW`", which `INDEX`, `SORT` and the debugger's writers went round.
- **Channel 2 spans the client/server link**, with the client driven by the user, the agent, or both
  — not a local-mode feature (Channel 2).
- **Variable watch**: stop, notify the programmer, then step or display or both, audited
  (Channel 1, staging step 6).
- **Clicking**: anything hot can be clicked to generate input; the `MSG` pointer and click actions are
  revived as one group (Channel 2, staging step 4).
- **Retention**: programmer-requested generated programs indefinitely; user-response ones removable.
- **Commands**: file-altering commands blocked except `INDEX` and `SORT`; `SYSTEM` blocked because it
  escapes BR. `CLOSE ... FREE` is allowed (Channel 2).
- **The gate latches for the session's life.** The flag marks the *session*, recorded in the brserver
  file against `(wsid, sessionid)` — a disposable session being the same WSID with a new session
  number. Nothing lifts it, including the programmer: the latch sits above the authority order rather
  than inside it (Channel 2).
- **Nine sessions per WSID** is accepted as the ceiling; the spawn path releases what it takes and
  throttles rather than the limit being raised (Channel 2).
- **The harness channel is a new brclient socket**, not the client/server link, the debugger socket or
  goahead ("The harness channel").
- **Framing is governed by a declared length, never by a delimiter**, so multi-line payloads need no
  escaping; the length is in bytes while all positions and lengths reported are characters.
- **A string carrying a UTF-8 expansion begins with the UTF-8 BOM** (`EF BB BF`), warning the consumer
  that byte and character lengths diverge. A literal NUL was rejected because it terminates C strings.
- **Authorisation is by token**: `HELLO <token>`, the token written where only the session owner can
  read it. Loopback-only is not sufficient on a multi-user machine.
- **The debugger channel gets TLS *and* token-exchange authentication** before anything else in
  Track B, and the observer tee inherits both. TLS through `ssl.cpp`'s existing `SocketPacket`
  send/receive pair, then a mutual HMAC-SHA256 challenge/response inside it, a per-session cookie by
  default, refusals logged at `SECURITY_EVENT` with the negotiated cipher, and `DEBUG LISTEN` bound to
  loopback unless explicitly opened.
- **Nothing the harness channel can trigger may raise a modal dialog.** A modal dialog stops the
  event pump the channel is serviced from, so a caller who asks for something impossible does not
  get an error - it wedges the client, and later connections are never accepted. Measured with a
  bad screenshot path. Every client-side operation reachable from the socket suppresses its dialogs
  and answers with a code instead.
- **`sleeptime` is a floor, not an interval.** Measured after A6 moved the sleep into the character
  loop: eight characters at `sleeptime 300` took 4.45 seconds, 0.55 each rather than 0.30, because
  `wb_sleepex` pumps events while it waits. Pacing works; the arithmetic does not. Measure a
  demonstration rather than computing its length.
- **Screen coordinates are floats.** `CONTROL_COORDINATE_TYPE` is `BRFLOAT32` (`brtypes.h:104`), so
  a `RowCol` member passed to a varargs `%i` is undefined behaviour and prints as its bit pattern.
  Nothing warns: `brStringMaxSnprintf` is not a format function the compiler checks. Cast at every
  such call. The harness reports whole cells, which is what a character screen means.
- **An unwritten screen cell holds 0, not a space.** `readString` is a memcpy of the buffer
  (`textwin.cpp:463`) and tidies nothing, so a reader that wants what is *displayed* maps NUL to
  blank — the harness does, for screen rows only, leaving a control's own data untouched.
- **Console observability needs a tee at `screen()`, not the log and not the dump.** The log has no
  console output and, until now, one-second timestamps; a dump is a snapshot of a buffer with no
  history, so it cannot see what scrolled past between two of them. The Track B observer tee
  mirrors the *debugger* protocol and does not carry console text either. `DEBUG SCREENLOG` (B3)
  closes it; dump for state, tee for history.
- **Log timestamps carry milliseconds** (done). `GetLocalTime` always supplied them and the format
  discarded them, which left an interactive session unorderable and the event log unmergeable with
  the screen tee. The unix branch still uses `asctime` at second resolution — a divergence to close
  when that build is next exercised.
- **Route A gives breakpoints, not the stepping position.** `DEBUG_LINE_BREAK` comes only from a
  breakpoint match; the position during stepping goes to the screen. Position tracking is the dump's
  job or the tee's (Channel 1, editor case).
- **A bare TCP listener is treated as the debugger.** `setDebugChannelDefaults` (`debug.cpp:180`)
  sets `debuggerAttached` as soon as the socket is up, with no handshake, so anything that accepts the
  connection takes the programmer channel. Harmless for `DEBUG CONNECT`, where the operator names the
  host — worth weighing before `DEBUG LISTEN` is offered to an agent, and it is what let Phase 0.3b
  run without the real debugger.
- **The operator can step a paused program; the debugger cannot.** `GO` is what exits a `PAUSE`, and
  `GO STEP` resumes in step mode — the `GO` command sets `RUN_STEP` on `t.runflags` directly
  (`command9.cpp`), with no reference to the run status. `DEBUG STEP` goes the other way, through
  `setStepMode` (`debug.cpp:125`), which takes `RUNSTAT_RUN`, `ATTN`, `ERROR` and `STEP` and returns
  false *silently* for `PAUSE` — so on the debugger channel it is accepted and does nothing. An agent
  on the console uses `GO STEP`; an agent on the debugger channel has to interrupt or break first.
  The silent failure is the trap, and the asymmetry is worth closing if the debugger channel is ever
  meant to match the console.
- **`GO <line>` resumes at a line; `GO .<line>` runs until it.** The period is the whole difference.
- **`MSG` stays, taking whole strings**, and the agent calls `kb` rather than `send`; per-keystroke
  calls are rejected, and the `sleeptime` sleep moves inside the character loop instead (step A6).
- **The focus requirement is inherent, not a reason to avoid `MSG`.** Device-layer input goes wherever
  focus is, so the guard is what prevents keystrokes landing in the user's other windows; background
  work uses `putKeyVal` (Channel 2, "What already exists").
- **`CLOSE ,FREE` on an `INPUT` open is a BR defect to fix, not a rule to work around.** Measured in
  Phase 0.1: it deletes the file and reports no error. The fix is an `fio == OFW_READ` test beside the
  share-mode guard in `bfclose`; with it, the gate needs no free-path check (Channel 2).
- **The agent has one way in: the keyboard and pointer it shares with the user, under a grant.** A
  program that wants an answer from it asks on the screen, and the agent types the answer. There is
  no second connection and no side door into a variable; a first version of C2 that had one was
  removed for that reason (C2).
- **`wbIdleProc()` waits 100 ms, not 10.** It is `processOSEventsShort(100000)`, a dead sleep in
  local mode. That made every `DLL()` call cost at least 100 ms until `callDLLFunction` learned to
  wake when the call finishes, and it is why every `SLEEP`-based wait in BR runs long (C1, C2).
- **A modal dialog stops the agent, whoever raised it.** The harness is serviced from the event
  pump, and a modal dialog stops the pump; the Debug build's heap-report notice held an attended
  run's agent off for 30 seconds (C2). A3 said the harness must never raise one; the rule is wider.
- **A disposable session is latched by `--restricted` on its command line, before its
  configuration is read**, and is handed its parent's log and `wbserver.dat` the same way, since
  it may configure neither. `SPAWN_RESTRICTED` is how an application starts one; it keeps the
  WSID's last session free, and it is local mode on Windows only for now (C3).
- **A stored prompt's answer field is declared by the application** and checked by BR's own field
  handling, as a person's answer would be; code is only ever typed into a file and run restricted
  on a person's request (C4).

## Open decisions

- **The retention period** for generated programs written in response to a user request. C4 keeps
  them apart — `agent\user\` against `agent\programmer\` — so a sweep needs only the period.
- **Character position versus screen column**, once non-Latin scripts are supported — see
  "Characters, positions and encoding".
- **`getcb` lost its error messages — fixed 2026-09-29.** The action itself was always correct; it
  reads the clipboard, confirmed by measurement in Phase 0.4. Its optional message container was
  declared twice: `if(objc == 3) DLL_PARM_LIST *interp1 = &objv[2];` shadowed the outer `interp1`
  inside the `if`, leaving it null for the rest of the function, so every clipboard failure path
  called `brm_AppendResult` on a null container, which returns early — an error code with no
  message. The inner declaration is gone. It was noted here as "worth fixing whenever `brmsg.cpp`
  is next open, which step A6 will do"; A6 came and went without it, which is the usual fate of a
  fix attached to somebody else's errand.

### Still open after Track B

- **`DATABASE` is refused wholesale in a restricted session.** SQL is a write path the file gate
  does not reach, so a connection would let such a session change data freely; the cost is that it
  cannot report from a database at all. A narrower rule — connections permitted, writes refused —
  is wanted and not designed.
- **Ctrl-\] in client/server mode.** The keyboard shell is refused for a restricted session where
  the request lands on the server, but in client/server mode that path spawns the command
  processor on the client and never reaches the check. Closing it needs the restriction carried in
  the client's copy of the session configuration.
- **The audit is not tamper-evident in an ordinary session.** `CONFIG LOGGING` is refused in a
  restricted session, but in any other session anyone holding the command channel — including an
  AI attached at programmer level — can redirect the log or lower its level until the entries stop.
  Refusing to lower logging while a debugger is attached, or recording a logging change as a
  security event the new destination cannot erase, would close it.
- **`debugger.doc`** in this directory predates the debugger-channel reference (now
  `AI-Access-Protocol.md` section 7) and is a binary Word file. Whether it still holds anything
  current is unknown; it wants folding in or retiring.

### Still open after Track C

- **A person has not yet answered `FNAGENT_SHOW`.** That the agent cannot answer it — its grant is
  withdrawn first — is verified; the person's side wants an interactive session. Withdrawing the
  grant means the person has to give it again after approving, which may prove tiresome in use; a
  grant that is suspended for the prompt and restored after would be kinder, and is not built.
- **An agent can type into a restricted session.** `MSG` is permitted there, so a restricted session
  can open the harness and give a grant, and the agent then types as the person could. That is
  consistent — the gate governs what runs, not who typed — but it is worth stating, since the
  earlier DLL design kept the agent out of restricted sessions altogether.
- **`SPAWN_RESTRICTED` is local mode on Windows only** (4156 elsewhere). Client/server needs the
  child's client to reach the person rather than the server's desktop; unix needs a fork/exec path.
- **`agentdriver.py` is a stub.** A real assistant replaces its `answer()` and `source()`
  functions — or is simply any harness client — and nothing on the BR side changes.
- **A client heap report is unexplained.** `BRClient-heap.log` holds a 15,000-block dump from one
  Win32 Debug client exit during the Track C runs (15:58 on 2026-09-29), from a client that did not
  clean up — hashmaps, fonts, fields. It was not tied to a particular run. Smaller dumps beside it
  came from the removed DLL: BR's DLL table never frees a loaded DLL's name at exit, a small
  pre-existing leak that any `DLL()` call triggers.
- **BRODBC does not build**, for reasons that predate this work: its Unicode conversion is
  unfinished in `drdeebee` and the ODBC sources. `odbcreset`, which compiles the same changed
  files (`startup.cpp`, `wbserver.cpp`, `numfunct.cpp`), builds clean.

## Verification

1. **The device-layer premise — done, Phase 0.2/0.2b.** Plain text and shifted sequences arrive
   verbatim; a hand-pressed and an MSG-sent F5 behave identically; `kb` refuses with error 413 when BR
   is not the foreground window; pacing is per segment, not per character. Re-run this A/B whenever the
   `MSG` path is touched, A6 in particular.
2. **Programmer exclusivity — done, Phase 0.3b.** With a debugger attached, a second `DEBUG CONNECT`
   was refused with error 420, `BREDEBUGGERATTACHED` (`wberrdefs.h:94`), and `DEBUG CONSOLE OFF`
   blocked console input as `debugCommandAllowLinput()` describes. Note both halves require the
   debugger to be *currently* attached: with the socket gone, `DEBUG CONSOLE OFF` is rejected as a
   syntax error (1006) by the `isDebuggerActive()` guard in `T9_CONSOLE`, which is easy to mistake for
   a broken command. Releasing the console means dropping the debugger connection — the wait loop
   exits and clears the flag as soon as `debuggerSocket` is zero.
3. **Observation routes — done, Phase 0.3.** Commands entered are logged at level 8; console
   output is logged at no level; `TRACE ON` with `LOGGING 12` gives one entry per executed line.
   Confirming that a *dump* captures the console text as displayed belongs to A1, which has to exist
   first.
4. **Editor observation — done, Phase 0.3b.** `DEBUG LOG` writes live, and a breakpoint hit logged
   `DEBUG_LINE_BREAK line=220, clause=2`, matching the `00220:02` the console showed. Stepping logs no
   position; re-check that if `checkbreakpoints` (`run.cpp:696`) ever gains a caller.
5. **Merged log.** In a client/server session, client-originated events reach the server's log;
   look for merge batching delaying them.
6. **Text channel by hand — done, C1.** A BR program opens a window with a text box, writes a
   prompt to a file, polls for a reply and displays it on the console. The poll keeps the terminal
   redrawing and ATTN-able — this is the no-threads claim under test.
7. **Profiler.** `DEBUG PROFILE TIMED <path>`, run a loop, `DEBUG PROFILE STOP`; output is
   non-empty and `profileranalyzer` reads it.
8. **Builds**, once code exists: brclient and brserver in all four configurations
   (`bld.ps1 -Recompile`), plus the legacy `brclient.vcxproj` Win32 Debug. Screen chains exercised
   through `LIBRARY RELEASE,NOFILES` with no heap report in Debug. PDF harness output unchanged
   (`PDF_TEST_ENV.md`).

   **The legacy `brclient.vcxproj` had not built since A1**, although this item said it was
   checked: `harness.cpp` was added to the CMake source list and never to the `.vcxproj`, and
   once added it failed C1020 because it opened an `#ifndef BRPRECOMP` above `useprecomp.h`,
   which the `.vcxproj`'s `/Yu` skips. Both fixed in Track C. As of then: all CMake targets in
   all four configurations with no warnings; `brclient.vcxproj` and
   `brserver.vcxproj` Win32 Debug; `odbcreset`. BRODBC does not build, for the older reason given
   under "Still open after Track C".
9. **The gate's two refusals.** Each individually: an `OPEN ... OUTPUT` without `NEW` refused, with
   `NEW` permitted and `OPEN ... INPUT` unaffected; and a blocked command refused while `INDEX` and
   `SORT` pass. There is no free-path test to verify — that hazard was closed in `bfclose` instead
   (error 4151), and its own regression test is Phase 0's `p01` and `p09`.
10. **Track C — done.** `runtrackc.py c2`, `c3` and `c4`, each against Win32 and x64 Debug. The
    gate tests `p34` and `p36`, now running their restricted half in a spawned session, give the
    same results line for line. If an attended run's first answer takes about 30 seconds, look for
    a modal dialog before looking at the harness (C2).
