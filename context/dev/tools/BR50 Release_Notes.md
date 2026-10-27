# BR 5.0 Release Notes - For Development - Not for Customer Use

What changed in BR 5.0 that an administrator or a support engineer needs to know about.
Entries that can change how an existing program behaves come first, because those are the ones worth
reading before an upgrade rather than after.

Deeper reference material stays in its own document; this page links to it rather than repeating it.

## Contents

- [1. Behaviour changes](#behaviour-changes)
  - [1.1 `CLOSE ,FREE` and `CLOSE ,DROP` now require a file opened for output](#close-free-and-close-drop-now-require-a-file-opened-for-output)
  - [1.2 Debuggers must be updated in order to attach](#debuggers-must-be-updated-to-attach)
  - [1.3 `MSG("send")` types into BR ](#msg-send-types-into-br)
  - [1.4 `MSG("gettext", …)` has been removed](#msggettext--has-been-removed)
  - [1.5 The `MSG` pointer actions now move a pointer BR keeps itself](#the-msg-pointer-actions-now-move-a-pointer-br-keeps-itself)
  - [1.6 `SPAWN_RESTRICTED` is a new reserved word](#spawn-restricted-is-a-new-reserved-word)
  - [1.7 The splash screen now waits 2 seconds, not 20](#the-splash-screen-now-waits-2-seconds-not-20)
  - [1.8 The serial number is no longer shown on the status line](#the-serial-number-is-no-longer-shown-on-the-status-line)
  - [1.9 Row and column are shown on the status line by default](#row-and-column-are-shown-on-the-status-line-by-default)
  - [1.10 The command console is set aside rather than hidden](#the-command-console-is-set-aside-rather-than-hidden)
  - [1.11 `CONFIG CONSOLE` now defaults to `DATA_ONLY`](#config-console-now-defaults-to-data-only)
  - [1.12 `OPTION 82` - work off the display area](#option-82-work-off-the-display-area)
  - [1.13 A program saved by 5.0 will not load in an earlier BR](#a-program-saved-by-50-will-not-load-in-an-earlier-br)
  - [1.14 `OPTION 60` - save in the 4.2/4.3 object format](#option-60-save-in-the-42-43-object-format)
  - [1.15 `SOFLOW-GROW` - a string can grow instead of overflowing](#soflow-grow-a-string-can-grow-instead-of-overflowing)
  - [1.16 `>` can send output into an array](#redirection-into-an-array)
  - [1.17 `DIR` takes glob patterns](#dir-glob-patterns)
  - [1.18 Tab completes file names at the `READY` prompt](#tab-completes-file-names)
  - [1.19 `OPTION 84` - a `/` in a file name](#option-84-slash)
  - [1.20 `FR` is refused as `FRE` is](#fr-is-refused-as-fre-is)
  - [1.21 `COPY` and `RENAME` ask before overwriting a file (`OPTION 6`)](#copy-and-rename-ask-before-overwriting)
  - [1.22 New `OPTION`s, and which ones are legacy](#new-options-and-legacy-options)
  - [1.23 `DIR` has a new listing and new options (`OPTION 8`)](#dir-new-listing)
  - [1.24 `-?` lists a command's options](#command-help)
  - [1.25 `RENAME` stays on one file system, and renames folders with `-D`](#rename-folders-and-file-systems)
  - [1.26 `COPY -R` and `FREE -R` take folders whole](#copy-free-recursive)
  - [1.27 `MOVE` - rename when possible, otherwise copy and free](#move)
- [2. Security](#security)
  - [2.1 The debugger connection is now encrypted and authenticated](#the-debugger-connection-is-now-encrypted-and-authenticated)
  - [2.2 The debugger port no longer accepts connections from the network](#the-debugger-port-no-longer-accepts-connections-from-the-network)
  - [2.3 Restricted sessions](#restricted-sessions)
  - [2.4 Where a restricted session may be: the file list](#the-restricted-session-read-list)
  - [2.5 UI regression scripts](#ui-regression-scripts)
  - [2.6 Starting a disposable restricted session](#starting-a-disposable-restricted-session)
  - [2.7 Calling an assistant from a program](#calling-an-assistant-from-a-program)
  - [2.8 An assistant no longer types at the `READY` prompt by default](#an-assistant-no-longer-types-at-the-ready-prompt-by-default)
  - [2.9 Both windows show a grant and a restriction](#both-windows-show-a-grant-and-a-restriction)
  - [2.10 An assistant cannot extend its own grant](#an-assistant-cannot-extend-its-own-grant)
  - [2.11 A turn asks you before anything destructive](#a-turn-without-a-grant-asks-before-anything-destructive)
  - [2.12 `OPTION 83` for an application that starts BR sessions](#option-83-for-an-application-that-starts-br-sessions)
  - [2.13 A turn needs the consent of whatever is running](#a-turn-needs-the-consent-of-whatever-is-running)
  - [2.14 A command from an assistant reports the error it died on](#a-run-that-fails-now-says-so)
  - [2.15 `CODE` is cleared by `LOAD`, `CHAIN` and `CLEAR`](#code-is-cleared-by-load-chain-and-clear)
  - [2.16 A restricted session's log is named for its WSID](#a-restricted-sessions-log-is-named-for-its-wsid)
  - [2.17 A program can tell an assistant something directly](#a-program-can-tell-an-assistant-something-directly)
  - [2.18 A program can be given a whole text in one go](#a-program-can-be-given-a-whole-text-in-one-go)
  - [2.19 `AI` - a conversation at the console](#ai-a-conversation-at-the-console)
  - [2.20 The client refuses a server certificate that was replaced in transit](#the-client-refuses-a-server-certificate-that-was-replaced-in-transit)
  - [2.21 New error codes for AI and restricted sessions](#new-error-codes-for-ai-and-restricted-sessions)
- [3. Debugging and observation](#debugging-and-observation)
  - [3.1 Watching a debugging session without taking it over](#watching-a-debugging-session-without-taking-it-over)
  - [3.2 A log of what appeared on the screen](#a-log-of-what-appeared-on-the-screen)
  - [3.3 Console history](#console-history)
  - [3.4 The debugger can now interrupt a running program](#the-debugger-can-now-interrupt-a-running-program)
  - [3.5 A variable watch now reports the value, not just the name](#a-variable-watch-now-reports-the-value-not-just-the-name)
  - [3.6 A step now tells the debugger where it stopped](#a-step-now-tells-the-debugger-where-it-stopped)
  - [3.7 Recording what a debugger submits](#recording-what-a-debugger-submits)
  - [3.8 The log now carries the clause and the source line](#the-log-now-carries-the-clause-and-the-source-line)
  - [3.9 `CLEAR PROC`, `STOP` and `END` at a halt in a library reload that library](#clear-proc-stop-and-end-at-a-halt-in-a-library-reload-that-library)
  - [3.10 `BREAK FILE` and `DISPLAY FILE` watch OPENs and CLOSEs](#break-file-and-display-file-watch-opens-and-closes)
  - [3.11 `BREAK` and `DISPLAY` take an `IF` condition](#break-takes-an-if-condition)
  - [3.12 `BREAK` and `DISPLAY` on a parameter watch the variable it stands for](#break-and-display-on-a-parameter-watch-the-variable-it-stands-for)
  - [3.13 `STATUS` shows the source line](#status-shows-the-source-line)
  - [3.14 `STATUS STACKS` shows what a function's parameters really are](#status-stacks-shows-what-a-functions-parameters-really-are)
  - [3.15 `STATUS DIMS LENGTHS` shows how long strings really got](#status-dims-lengths)
- [4. Printing and fonts](#printing-and-fonts)
- [5. Fixes](#fixes)
  - [5.1 `LIST ... CLAUSE` counted `ON ... GOSUB` as two clauses](#list-clause-counted-on-gosub-as-two-clauses)
  - [5.2 Screen chains on a `LIBRARY RELEASE,NOFILES` return](#screen-chains-on-a-library-releasenofiles-return)
  - [5.3 `DLL()` calls no longer wait 100 ms each](#dll-calls-no-longer-wait-100-ms-each)
  - [5.4 `PROTECT` no longer repeats forever when it fails on Windows](#protect-no-longer-repeats-forever-when-it-fails-on-windows)
  - [5.5 Comment lines in `brconfig.sys` no longer hold the splash screen](#comment-lines-in-brconfig-sys-no-longer-hold-the-splash-screen)
  - [5.6 `MSG("state")` now checks its argument count](#msg-state-now-checks-its-argument-count)
  - [5.7 The client no longer stops with "Bad action 10129" while connecting](#the-client-no-longer-stops-with-bad-action-10129-while-connecting)
  - [5.8 Most of the status line was blank](#most-of-the-status-line-was-blank)
- [6. Debug builds](#debug-builds)
  - [6.1 Memory leak reporting at exit](#memory-leak-reporting-at-exit)
  - [6.2 The harness channel's ring statistics are now Debug-only](#the-harness-channels-ring-statistics-are-now-debug-only)

<a id="behaviour-changes"></a>
## 1. Behaviour changes

<a id="close-free-and-close-drop-now-require-a-file-opened-for-output"></a>
### 1.1 `CLOSE ,FREE` and `CLOSE ,DROP` now require a file opened for output

**New error 4151** — *CLOSE DROP or FREE requires the file to be opened for output*.

Previously a program could open an existing file `INPUT` and then `CLOSE #n,FREE:` it. The file was
deleted and **no error was reported**. `CLOSE #n,DROP:` behaved the same way, emptying the file. The
guard on that path tested only the share mode, and since `NOSHR` is the default when no share option
is given, an ordinary read-only open satisfied it.

That was never the intent: a channel opened for input should not be able to destroy the file. BR now
refuses, raising error 4151 and leaving the file untouched.

**What still works, unchanged.** A program that opens a file `OUTPUT` or `OUTIN` and frees or drops
it — the case the feature exists for — behaves exactly as before. So does every close on a window,
async-communications or printer channel.

**What this can break.** Any existing program that frees or drops a file it opened `INPUT` works
today and will fail with 4151 after upgrading. The fix in the program is to open the file `OUTIN`
(or `OUTPUT`) when the intent really is to remove it. If a run stops with 4151, that statement is
the one to look at.

<a id="debuggers-must-be-updated-to-attach"></a>
### 1.2 Debuggers must be updated in order to attach

The debugger connection is now encrypted and authenticated, so a debugger built against an earlier
release will no longer attach. This is the change most likely to interrupt an upgrade, and there is
a switch to defer it: see
[The debugger connection is now encrypted and authenticated](#the-debugger-connection-is-now-encrypted-and-authenticated)
under Security for what changed, what a debugger now has to do, and `DEBUG AUTH OFF` for working 
the old way during the transition.

<a id="msg-send-types-into-br"></a>
### 1.3 `MSG("send")` types into BR

`MSG("send", …)` used to type through the operating system's keyboard input, which goes to whichever
window has the focus — so a program could type into another application, a command prompt, or
another BR session. It now puts its keys straight into the session's own keyboard buffer, the same
one keys typed in BR's window land in. They reach this session and nothing else, whichever window
has the focus. This applies in every session.

What changes for a program that uses it:

- **It no longer reaches other applications.** A program that used `MSG("send")` to drive another
  Windows program must find another way.
- **`MSG("kb", …)` has been removed. Use `MSG("send", …)`,** which takes the same arguments and
  behaves the same way. A call to `kb` now raises 412 *invalid MSG action*. 
- **`MSG` returns at once, and the keys follow.** They are queued and fed into the session one at a
  time, `MSG("sleeptime", …)` apart, while the program runs and reads them — so `sleeptime` now
  paces what is seen typed, which is what it is for. A program must not expect every key to be
  waiting the moment `MSG` returns. Because keys are only fed as fast as they are read, a string is
  not limited by the 200-key keyboard buffer.
- **Named keys** — `|RET|`, `|TAB|`, `|ESC|`, `|F1|`…`|F12|`, the arrows, `|PGUP|`, `|HOME|` and the
  rest — arrive as the same keys pressed on the keyboard would. `|SHIFT+|` shifts ordinary characters
  on the current keyboard layout (`a` to `A`, `1` to `!`) and gives the shifted function, arrow and
  editing keys; `|CTRL+|` gives Ctrl+letter and the Ctrl variants of those keys. Keys that mean
  nothing inside BR — Alt combinations, the Windows and Apps keys, PrintScreen — are dropped.

The pointer actions (`setpos`, `lclick` and the rest) are unchanged in an ordinary session; a
restricted session may not use them.

<a id="msggettext--has-been-removed"></a>
### 1.4 `MSG("gettext", …)` has been removed

**Removed 2026-10-03.** `MSG("gettext", <text$>)` returned the caption of whichever window was in
front. That was BR's own caption only when BR happened to be the foreground window; at any other
moment it was another application's window title, which a BR program has no business reading and
a restricted session must not be able to read at all. It took no window name, so there was no way
to ask it for BR's own caption specifically.

A call to it is now error 412. A program that used it to read **BR's own** caption should use the
`application_name` it already configured; there is no replacement for reading another
application's title, and that is deliberate.

`MSG("state", <state$>)` is unaffected and now answers for BR's own window.

<a id="the-msg-pointer-actions-now-move-a-pointer-br-keeps-itself"></a>
### 1.5 The `MSG` pointer actions now move a pointer BR keeps itself

`MSG("setpos")`, `MSG("setwpos")`, `MSG("lclick")`, `MSG("mclick")` and `MSG("rclick")` used to
drive the **physical** mouse: `SetCursorPos` moved the cursor on the desk, and the clicks were
`mouse_event` wherever that cursor had ended up. They now move a pointer BR keeps for itself and
deliver the press into BR's own session.

- **They no longer reach other applications.** A press used to land on whichever program was under
  the cursor. A program that used them to drive another Windows program must find another way.
- **They no longer move the cursor on the screen.** The user's pointer stays where the user left
  it.
- **`getwpos` answers relative to BR's window.** It and `setwpos` used to convert against
  *whichever window was in front*, so with BR not in front they silently answered, and aimed,
  relative to another application's window. Neither reported an error; they simply acted
  somewhere else.
- **They work with the window unfocused, covered, or off the screen.** Nothing on the path
  consults the display.
- **A press can only be delivered to the character screen.** Over the menu, the status line, a
  native control, or outside the window, the click actions are refused.
- **`MSG` returns before the press arrives.** It is queued with the keys from `send`,
  behind any still waiting, and paced by `MSG("sleeptime", …)` — so typing and clicking keep the
  order the program wrote them in.
- **Every delivered press is logged** at the security level: `MSG pressed button <key> at row
  <row> column <col>`.

**`MSG("setcpos", <row>, <col>)` and `MSG("getcpos", <position$>)` are new**, addressing the
pointer by character cell with zero-based rows and columns. They exist because a caller that knows
where something is on the screen knows it as a row and a column, not as a pixel offset inside the
frame.

These actions were not available before this release — they were compiled out, and a call to any of
them returned error 412 — so no existing program can be relying on the old behaviour.

<a id="spawn-restricted-is-a-new-reserved-word"></a>
### 1.6 `SPAWN_RESTRICTED` is a new reserved word

`SPAWN_RESTRICTED` is now a built-in function — see
[Starting a disposable restricted session](#starting-a-disposable-restricted-session). A program that
uses `SPAWN_RESTRICTED` as a variable name will no longer compile, and needs the variable renamed.

<a id="the-splash-screen-now-waits-2-seconds-not-20"></a>
### 1.7 The splash screen now waits 2 seconds, not 20

The first session on a workstation used to hold the splash screen for 20 seconds before going on,
and so did any session whose startup produced a configuration message. Both now wait **2 seconds**.

Nothing else about the splash screen changes: it still appears, it still shows the workstation and
user counts and any configuration messages, sessions 2 to 9 still start with no wait at all, and an
`UNATTENDED` session still has no wait in any case. A configuration message that matters is in the
log as well as on the splash, so the shorter wait does not lose it.

<a id="the-serial-number-is-no-longer-shown-on-the-status-line"></a>
### 1.8 The serial number is no longer shown on the status line

**Changed 2026-10-03.** The status line no longer has a serial number field. It was a fixed
nine-digit field that never changed during a session, and on the graphical status line it was
taking about a seventh of the width from the message field - the one field that has to shorten
its text when there is no room. The message field now gets that space.

The serial number is still available to a program as the **`SERIAL`** function, and it still
appears in a crash dump.

A printed screen (Ctrl-P) carries the same status line in eighty columns, and there the row and
column has moved up into the space the serial number occupied, rather than leaving a gap in the
middle of the line. It also prints in full now where it was previously cut to five characters.

This changes the size of the status line message the server sends the client, so **a client and
a server must be the same release** - which has always been the rule, and is worth repeating
because a mismatch here would garble the status line rather than refuse to connect.

<a id="row-and-column-are-shown-on-the-status-line-by-default"></a>
### 1.9 Row and column are shown on the status line by default

**Changed 2026-10-03.** The field at the right-hand end of the status line shows the cursor's
row and column while a program is at an input. Previously this was off unless the configuration
said `STATUSLINE ROWCOL ON`, and the field held the release number instead.

`STATUSLINE ROWCOL OFF` still turns it off and restores the release number there. The release is
also shown in the message field when BR starts, so it is not lost either way.

The field is now sized from the screen, so a screen with more than ninety-nine rows or columns
gets the extra digit it needs. Previously such a position was cut short - on a 132-column screen,
column 105 was stored as `10:10`.

<a id="the-command-console-is-set-aside-rather-than-hidden"></a>
### 1.10 The command console is set aside rather than hidden

**Changed 2026-10-10.** When the console has nothing to show it is moved off the display area
instead of being hidden. It is still there, and still a window: it paints, it can be captured, and
it receives input sent to it. A hidden window does none of those - it has no client area at all,
and anything posted to it is discarded without a trace, which is a hard failure to diagnose
because nothing reports it.

Nothing about this is visible in normal use: the console is out of sight either way, and it comes
back to where it was the moment something needs it. It matters to anything that drives BR without
a person at the keyboard, and to support staff capturing a screen.

A parked window has no taskbar button, so an operator is not offered a window they cannot see.

<a id="config-console-now-defaults-to-data-only"></a>
### 1.11 `CONFIG CONSOLE` now defaults to `DATA_ONLY`

**Changed 2026-10-10.** The default was `OFF`. Under `DATA_ONLY` the console appears when
something is written to it and goes away again when there is nothing to show, so output a program
sends to the console can be seen without the session having been told in advance to expect it.

An application that writes to the console and was built expecting no console window will now show
one when it writes. `CONFIG CONSOLE OFF` restores the previous behaviour.

<a id="option-82-work-off-the-display-area"></a>
### 1.12 `OPTION 82` - work off the display area

**New 2026-10-10.** `OPTION 82 ON` puts a session's windows past the edge of the display and
leaves them there. It is for sessions nobody is watching - test runs, development drivers,
automation - so that they do not take the screen from whoever is using the machine.

Parked windows stay live - they paint, they capture, and they receive input - which is what
separates this from not opening a window at all, and from `UNATTENDED`, which suppresses the
windows entirely. A parked window has no taskbar button, so an operator is not offered one they
cannot see.

**Turning it off brings them back**, which is the way out of a session found parked. Ending the
session is enough on its own: a parked window's position is never saved, so the next start is on
the display whatever the option said.

It is off unless a session asks for it, and that is the whole of the protection - a session that
turns it on and forgets has windows it cannot see until it turns it off again. `OPTION 82` was
going to require `UNATTENDED` as well, on the reasoning that parking is only safe where nobody is
at the keyboard. That proved unworkable: `UNATTENDED` changes much more about a session than its
name suggests, enough that requiring it would have put this out of reach of the very sessions that
want it.

<a id="a-program-saved-by-50-will-not-load-in-an-earlier-br"></a>
### 1.13 A program saved by 5.0 will not load in an earlier BR

**Please read this before upgrading if programs are saved on one machine and run on another, or if
some machines will stay on 4.3 for a while.**

BR 5.0 records, for every statement, which line of the source file it came from. That number is
kept in the line table, and the line table is part of a saved program, so the object format has
moved: 5.0 writes save level **39** where 4.2 and 4.3 wrote level **38**.

An older BR given a level 39 program **refuses it**, with error **2240** - *release level error*.
It does not misread it. Nothing is damaged and nothing runs with a wrong program; the load simply
does not happen, and says why.

The direction that matters less is already fine: **5.0 loads anything an earlier BR saved.** A
level 38 program loads and runs normally. It has no source line positions in it - there were none
to save - and BR reports positions without them, which is the only difference.

If a program has to be read by a 4.2 or 4.3 BR, see [`OPTION
60`](#option-60-save-in-the-42-43-object-format) below.

<a id="option-60-save-in-the-42-43-object-format"></a>
### 1.14 `OPTION 60` - save in the 4.2/4.3 object format

**`OPTION 60` has a new meaning, and its old one is gone.**

It used to make `SAVE` write the 4.18-and-earlier object format. **That format is no longer
written at all** - it was retired on 2026-09-26. Programs already in it still load; they just
cannot be produced any more.

`OPTION 60 ON` now makes `SAVE` write the **4.2/4.3 format, save level 38**, so the program can be
loaded by a BR that predates 5.0. The cost is in the name of what level 39 added: **the source
line positions are not written**, because level 38's line table has nowhere to put them. Such a
program runs identically; what it loses is BR's ability to say which line of the source file a
statement came from.

Use it when a program must be read by an older BR. Leave it off otherwise - level 39 is the
default and loses nothing.

**It affects saving only.** BR 5.0 loads all three object formats - the pre-4.2 one, level 38 and
level 39 - whether `OPTION 60` is set or not. Nothing about loading depends on it.

`OPTION 60` continues to set `OPTION 74` as well (*treat `IGNORE` as a label reference for line
level error handlers*), which it has done since the old format was retired. A save meant for 4.2
or 4.3 wants 4.2/4.3 code generation with it.

`STATUS CONFIG` reports `OPTION 60` again; while it had no meaning it was left out.

<a id="soflow-grow-a-string-can-grow-instead-of-overflowing"></a>
### 1.15 `SOFLOW-GROW` - a string can grow instead of overflowing

A string that would overflow can now be made longer instead of failing. It is **off unless you ask
for it**, so no existing program changes.

**Turning it on.** A configuration statement, in `brconfig.sys` or given at run time with
`EXECUTE "CONFIG ..."` (which reads it exactly as the file does):

```
SOFLOW-GROW  [ MAX=n ]  [ ON | OFF ]
```

- `ON` is the default when neither `ON` nor `OFF` is given, so `SOFLOW-GROW` alone turns it on.
- `MAX=n` also turns it on, unless `OFF` is given with it.
- No `SOFLOW-GROW` statement means off.
- **Abbreviations.** The keyword and each word after it may be shortened to a part that no other word
  starts with: `SOFLOW-G`, `M=40`, `MA=40`, `OF`. `O` alone is both `ON` and `OFF`, so it is refused.
- `n` is the most bytes one string variable or array element may grow to. Without a `MAX` the
  limit is that of a dictionary element, 256 MB. `MAX` stays as last given until it is given again.
- A restricted session may set it, as it may set `PAGEOFLOW`.

**In a program.** `ON SOFLOW GROW` turns it on for the program. GROW is one of the `ON SOFLOW`
modes, beside `IGNORE`, `SYSTEM` and `GOTO`, and the last one set wins, so any other `ON SOFLOW`
turns GROW off. There is no `NOGROW`, because it would not say whether to ignore, stop or branch;
say which. `ON SOFLOW GROW` takes no line number.

**When the setting applies.** Every `RUN` starts in the mode the configuration gives it, and the
program can change that with `ON SOFLOW`. A change to the configuration does not change a program
that is already running, except that `MAX=` takes effect at once.

**Where a string grows.** Only where a value is stored into a string that is too short for it:

- an assignment to a string variable, `A$ = expr` or `A$ := expr`, including an assignment inside
  a larger expression;
- an assignment to an array element, `A$(3) = expr` or `M$(2,1) = expr`. **Every element of the
  array gets the longer length**, because the elements of an array are all the same length; the
  other elements keep their values;
- `LINPUT` from a file into a string variable or an array element;
- `PRINTER_LIST` into an array, which is widened until the longest name fits.

Everywhere else a string that would overflow behaves as it always did: assignment to a substring,
a by-value parameter, `LINPUT` from the keyboard or at the READY prompt, print formatting, input
fields, and every function that returns text. 

**Parameters passed by reference** grow the caller's own variable, or the caller's array. This
holds across a library: a library function runs in **its own mode**, not the caller's, so what
decides is the library's `ON SOFLOW` or the configuration when the library is loaded. If the
library is in GROW mode, assigning to a by-reference parameter grows the variable in the
program that called it; if not, the library's assignment overflows as it always did.

**An array that is in use will not widen.** If another element of the same array is on the stack
at the time, because it was passed by reference to a function that is still running, the
assignment that would widen the array raises the overflow error and nothing changes.

**The ceiling.** A string never grows past `MAX`. `MAX` is looked at only when a value is longer
than the string it is going into; a value that fits is stored whatever `MAX` is, even into a
string already longer than `MAX`. A value that would take the string past `MAX` is not stored: the
variable keeps its value and length, and the statement raises the overflow error it always raised
(and the same happens if there is no memory to grow into). Growing up to `MAX` and then ignoring or
branching on the rest is not supported. A string that has grown to `MAX` or less is a longer string
from then on, and `ON SOFLOW IGNORE` or `GOTO` apply to its new length.

**A line exit on the statement wins.** `LINPUT #3: A$ SOFLOW 800` branches to line 800 on overflow
and does not grow, as an exit on a statement always took precedence over `ON SOFLOW`.

**It lasts for the run.** The longer length is not saved with the program, and the next `RUN`
starts again from the length in the `DIM` and gives the memory back.

**`STATUS CONFIG`** shows `SOFLOW-GROW`, its `MAX`, and whether the running program is in GROW
mode.

**New word.** `GROW` is a new word after `ON SOFLOW`. Variables named `GROW` or `NOGROW` keep
working.

<a id="redirection-into-an-array"></a>
### 1.16 `>` can send output into an array

Where a command takes `> file` to send its output to a file, it now also takes the name of a string
array of the program that is loaded:

```
LIST > L$
STATUS CONFIG >> LINES$
```

The output goes into the array, one line to an element, and the array is **redimensioned to fit**, so
it ends with exactly as many elements as there were lines - none, if the command wrote nothing. The
program can then read the output as it reads any other array. It works for every command that
redirects: `LIST`, `STATUS`, `INDEX`, `TYPE` and `DIR`, and from `EXECUTE` as well as at
the `READY` prompt.

- **`>` replaces and `>>` adds.** `> A$` throws away what the array held. `>> A$` keeps it and puts the
  new lines after the last element.
- **A name is an array only if it is one.** The name must end in `$` and be a string array of the
  program that is loaded. Any other name is a file name, as it always was, including a file whose name
  ends in `$` when the program has no array of that name.
- **One dimension.** A two or three dimensional array is refused with error 130, as `MAT REDIM` would
  refuse it.
- **A line longer than the array's string length follows `ON SOFLOW`.** In GROW mode (see
  [`SOFLOW-GROW`](#soflow-grow-a-string-can-grow-instead-of-overflowing)) every element becomes as long
  as the longest line, up to `MAX`. With `ON SOFLOW IGNORE` the line is cut. Otherwise the command stops
  with the string overflow error, 58, and the array holds the lines stored before it. The length is a
  property of the array: `DIM A$(1)*200` takes any line up to 200 characters in any mode.
- **`TYPE` and `DIR`.** `TYPE file > A$` puts the lines of the file into the array, including a last
  line that has no line end. `DIR > A$` puts the lines the directory listing would show on the screen.
  If the file is not found or cannot be read the array is left with the lines stored before the error.
- **The end of each line is not stored.** A carriage return in front of the line feed is dropped, so
  the elements are the same text that `> file` would hold, without the line ends.
- **`RUN >` and `DISPLAY >` do not take an array.** They keep the output open after the command has
  finished, while the program that holds the array could be cleared. They refuse with error 315, as
  they refuse any array that cannot be redimensioned.
- **An array that is in use will not redimension.** If an element of the array is on the stack - an
  element passed by reference to a function that is running - the redirection stops with error 317,
  as `MAT REDIM` does.
- **`STATUS` reports a failed write.** A `STATUS` that could not write to its redirection used to end
  without saying so. It now ends with the error.

<a id="dir-glob-patterns"></a>
### 1.17 `DIR` takes glob patterns

The name given to `DIR` may now be a glob pattern. `*` and `?` work as they always have. These are new:

| Pattern | Matches |
|---|---|
| `[abc]` `[a-z]` | one character from the set or range |
| `[^abc]` | one character that is not in the set |
| `{a,b,c}` | any one of the alternatives; they may contain other patterns, and may nest |
| `**` as a whole part of the name | any number of directories, or none |

```
DIR data\*.{brs,prc}
DIR data\rpt[0-9][0-9].dat
DIR src\**\*.cpp
DIR data\20*\*.rpt
```

`DIR src\**\*.cpp` lists every `.cpp` file in `src` and in every directory below it. `DIR src\**` lists
everything below `src`. A pattern may also be in a directory part of the name, as in the last example,
where `*` is not in the last part.

- **One heading per directory.** The listing has a `Directory of` heading for each directory that has
  a match, a blank line between them, and one total at the end. Directories are taken in name order.
  `-B`, `-W`, `-C`, `-A` and `>` work as they do for any `DIR`, and `-O` sorts the files within each
  directory.
- **What did not change.** A name whose last part has only `*` and `?`, and no other pattern, is
  listed as before, including `DIR name` meaning `name.*`. A pattern that uses any of the new forms
  is taken exactly as written: `{a,b}` does not have `.*` added to it.
- **Case** follows `FILENAMES SEARCH`, as it does for `*` and `?`.
- **A leading dot is not special.** `*` matches a name that begins with a dot. `.` and `..` are never
  listed by a pattern.
- **No escape character.** Backslash is the separator on Windows, so there is none. To match `[`, `{` or
  `}` itself, put it in a set: `[[]`, `[{]`, `[}]`. A `[` or `{` with no closing partner, and `{}` with no
  comma in it, stand for themselves. A file whose name is the pattern written out - `a[1].txt` - is also
  found when it is asked for by that name.
- **Negation and the comment character.** `[!abc]` also means "not in the set", but `!` begins a comment
  in a command line unless the name is quoted: `DIR "data\[!ab]*"`. `[^abc]` needs no quotes.
- **A comma in braces belongs to the name.** `DIR *.{brs,prc}` is one name, not two. A comma that is
  not inside braces separates names, as it always did.
- **A name that ends with `\` or `/` matches folders only.** `DIR src\*\` lists the folders in `src`,
  and `DIR src\**\` every folder below it. `DIR src\`, with no pattern before the separator, lists
  what is in `src`. For `COPY`, `MOVE` and `FREE`, which act on folders only with `-R`, `src\` is the
  folder `src` itself and `src\*.brs\` the folders in `src` named `*.brs`; see
  [1.26](#copy-free-recursive).
- **Nothing matched** is error 4152, file not found.
- **Depth.** `**` goes down at most 40 directories.
- **The other file commands take them too.** `COPY`, `MOVE`, `RENAME`, `FREE`, `DROP` and `TYPE` accept the
  same patterns for the files they act on: `COPY src\**\*.cpp backup\`, `FREE tmp\*.{bak,old}`,
  `TYPE notes\[ab]*.txt`. The files are acted on directory by directory, in name order. A `**` pattern
  can bring files from several directories; with a directory as the target they all go into it, without
  their sub-directories, so two files of the same name overwrite each other. `RENAME` and a
  non-directory `COPY` target keep their `*` rule (`RENAME a{1,2}.txt *.bak`). `MKDIR`, `RMDIR` and
  `CHDIR` name one directory and take no pattern, but they do take a `/` as a separator (see
  [1.19](#option-84-slash)).

The full statement of the patterns, with `/` in names and Tab completion, is the document
`filename-patterns.md` in the context kit (`br_tree/70-commands/file-directory`).

<a id="tab-completes-file-names"></a>
### 1.18 Tab completes file names at the `READY` prompt

At the `READY` prompt, Tab completes the file name the cursor is in, from the server's files, for
`COPY`, `RENAME`, `FREE`, `DROP`, `TYPE`, `DIR`, `LOAD`, `RUN`, `SAVE`, `REPLACE`, `MERGE`, `PROC`,
`SUBPROC`, `RMDIR`, `CHDIR`/`CD`, the program named after `<` in `LIST <program`, and the file named
after `>` or `>>` on every command that redirects its output (the file commands, `LIST`, `RUN`,
`STATUS`, `DISPLAY` and `INDEX`). One match is put in. Several are listed and the first is put in;
each further Tab puts the next in its place, cycling round, until something else is done. The command word may be abbreviated as far as BR itself allows. Everywhere
else Tab still moves to the next tab stop.

The full statement — which words of each command are completed, the abbreviations, redirections,
quoting, directories-only for `RMDIR` and `CHDIR`, and the listing — is section 3 of
`filename-patterns.md`, in the same place as for 1.17.

<a id="option-84-slash"></a>
### 1.19 `OPTION 84` - a `/` in a file name

A `/` in a file name has always meant System/23: `file/directory/drive`, with `file//10` the spooler
and `file//11` AUX. It can now also be a **folder separator**, so `data/rpt/a.dat` and `src/**/*.cpp`
work as they do on other systems. A name that could be either is tried both ways, and BR does not look
at the disk to decide: the name is resolved the first way, the operation is tried, and if it fails as
file or folder not found it is tried the other way.

**Which way first.** The System/23 reading is tried first if the name has a `\` in it, has `//` and a
digit, or has only one `/`. Anything else is tried as folders first. A name with `//` and a digit is
only ever read as System/23. A name with a drive letter or a device in front (`C:/data/x`, `PRN:/10`)
has only one reading.

**`OPTION 84 n`** changes that:

| n | First | If not found |
|---|---|---|
| 0 | System/23 | not tried again - the behaviour of earlier releases |
| 1 | by the rule above (the default) | tried the other way |
| 2 | by the rule above | not tried again |
| 3 | System/23 | tried as folders |
| 4 | folders | tried as System/23 |
| 5 | folders | System/23 names stop working |

`OPTION 84 ON` is 1 and `OFF` is 0. `STATUS CONFIG` shows the level.

- **A failed operation reports the first way's error,** except that "file not found" (4152) replaces
  "path does not exist" (4203) when the other way found the folder but not the file. That is what
  lets `OPEN ... NEW` or `REPLACE` create a file by either reading.
- **When both readings exist the first wins.** `x/y` is file `x` in directory `y` (System/23) or file
  `y` in folder `x`; with both present it is the first one tried, so a name can change meaning when
  folders are created or removed. Level 0 or 5 removes the doubt.
- **It applies to** `OPEN`, `LOAD`/`SAVE`, `DIR`, `COPY`, `RENAME`, `FREE`, `DROP`, `MKDIR`, `RMDIR`,
  `TYPE` and the other commands and statements that name a file. The `DIR` glob patterns of
  [1.17](#dir-glob-patterns) work with `/` as with `\`.
- **`OPTION 84` is a configuration setting** and may be changed with `CONFIG OPTION 84 n`.

<a id="fr-is-refused-as-fre-is"></a>
### 1.20 `FR` is refused as `FRE` is

`FREE` has no abbreviation: only `FREE` in full deletes a file. `FRE` is refused with error 1000,
"unidentified source remaining", and deletes nothing, and `FR` now takes that same refusal. Before,
`FR` reached the error only by being read as an expression, so a bare `FR` at the `READY` prompt
printed the value of a variable named `FR`; it is now error 1000 as well.

<a id="copy-and-rename-ask-before-overwriting"></a>
### 1.21 `COPY` and `RENAME` ask before overwriting a file (`OPTION 6`)

`COPY` used to replace a target that already existed without a word, and `RENAME` refused one with
error 4150 (file already exists) unless given `-F`. Both now ask, on a line of their own:

    Overwrite C:\DATA\CUST.FIL? (y/n/all)

- **`Y`** overwrites; **`N`** leaves that file and goes on to the next one the command names;
  **`A`** overwrites it and every later one in the same command without asking; **Esc** stops the
  command. **Ctrl-A** interrupts it, as it does anything else in BR: the command halts with no
  error, and a procedure that issued it stops there until `GO`. A program that ran the command
  with `EXECUTE` is interrupted too, at its next statement, exactly as if Ctrl-A had been typed
  while it ran - its `ON ATTN` applies, so it may carry on by design. The same holds at the `-V`
  confirmation question.
- **`-F` overwrites without asking**, and now applies to `COPY` as well as `RENAME`.
- **Nobody is asked when nobody can answer.** In `UNATTENDED` mode, or while an assistant holds the
  `READY` prompt, the command stops with error 4150 instead and nothing is overwritten. `-F` gets
  past it.
- **A target that is the source itself** under another name (a change of case, a relative or 8.3
  short name, a hard link) affects no other file, so nothing is asked or refused, with or without
  `OPTION 6`. `RENAME` goes ahead, and `COPY` becomes a `RENAME`; either way the file is left under
  the second name exactly as written, so `RENAME abc.txt abc.txt` turns `Abc.txt` into `abc.txt`. Before, `RENAME -F` of a name
  to its own upper case could delete the file on Windows (the target was deleted first), and
  `COPY @:x @:X` was error 4299.
- **`OPTION 6` restores the old behaviour**: `COPY` replaces silently and `RENAME` refuses with 4150
  unless `-F`. It may be set in `brconfig.sys` or with `CONFIG OPTION 6 ON`, and `STATUS` shows it.
  The number is reused: `OPTION 6` was once keep path on exit, long withdrawn and accepted as a
  no-op, so a configuration file that still says `OPTION 6` keeps the behaviour it has always had.

<a id="new-options-and-legacy-options"></a>
### 1.22 New `OPTION`s, and which ones are legacy

BR 5.0 adds eight `OPTION` numbers (8 and 78 to 84), gives two existing numbers new meanings (6 and
60), and retires one (55). **Six of them are legacy options**: each one turns a 5.0 behaviour change
back to what earlier releases did. If an upgrade has changed something an application depends on,
look here first.

**Legacy options** - set one to get the old behaviour back:

| Set | To get | Instead of the 5.0 default | See |
|---|---|---|---|
| `OPTION 6 ON` | `COPY` replaces an existing file without asking, and `RENAME` refuses one with error 4150 unless given `-F` | both ask `Overwrite ...? (y/n/all)` | [1.21](#copy-and-rename-ask-before-overwriting) |
| `OPTION 8 ON` | `DIR` lists as it did before 5.0, as if every `DIR` were given `-O`: the 8.3 layout with two-digit years, and the old meanings of `-A`, `-L`, `-N`, `-O` and `-U` | the 5.0 listing: ISO dates, sizes in full, long names only, sorted by name | [1.23](#dir-new-listing) |
| `OPTION 60 ON` | `SAVE` writes the 4.2/4.3 object format (save level 38), which a 4.2 or 4.3 BR can load | level 39, which an earlier BR refuses with error 2240 | [1.13](#a-program-saved-by-50-will-not-load-in-an-earlier-br), [1.14](#option-60-save-in-the-42-43-object-format) |
| `OPTION 79 3` | no font errors reported to the program, as before 5.0. The conditions are still logged | `0`: errors 6249, 6251 and 6253 are all reported | |
| `OPTION 81 ON` | 4.3.3's print sizing: a proportional face is never scaled, and a fixed-pitch face is stretched to the cell | the size derived from the pitch, with every face scaled to the cell | [4](#printing-and-fonts) |
| `OPTION 84 0` | a `/` in a file name read only as System/23 (`file/directory/drive`) | `1`: a name that could be either is tried both ways | [1.19](#option-84-slash) |

- **Each may be set in `brconfig.sys` or with `CONFIG OPTION`**, and `STATUS CONFIG` shows it.
- **A configuration file carried over from 4.3 is safe with all six.** `OPTION 6` was a no-op there
  and now gives exactly the behaviour 4.3 had, and 4.3 had no use for the others, except
  `OPTION 60`; it refused `OPTION 8`, a long-withdrawn number now reused. **A 4.3 configuration with `OPTION 60 ON` now saves level 38**, not the
  4.18-and-earlier format it asked for there, which 5.0 no longer writes.
- `OPTION 79` is a level, not a switch: `1` stops 6253 (*internal font resolution error*) being
  reported, `2` stops 6251 (*requested print font is not available, a substitute was used*) as
  well, and `3` stops 6249 (*invalid NWP font specification*) too.
- `OPTION 81` implies no other option. `OPTION 68` keeps its own meaning inside it, as in 4.3.3.

**Other new options** - new capabilities, with no earlier behaviour to restore:

| Set | To get | See |
|---|---|---|
| `OPTION 78 a b` | grid and list selection backgrounds lightened by `a` when dark and darkened by `b` when light, each 0 to 127 (default is 40 for both) | |
| `OPTION 80 ON` | for a large font, type at the size its pitch implies, with the line advance growing to fit - at fewer lines per page | [4](#printing-and-fonts) |
| `OPTION 82 ON` | this session's windows parked off the display area | [1.12](#option-82-work-off-the-display-area) |
| `OPTION 83 ON` | operating-system calls not asked about, and BR sessions this one starts not restricted. Configuration file only | [2.12](#option-83-for-an-application-that-starts-br-sessions) |

**Retired:** `OPTION 55` (fixed-pitch alignment for NWP printing) is now refused in
`brconfig.sys`, and `STATUS CONFIG` reports it as `OPTION 55 - no longer used`. Remove it from any
configuration file before upgrading.

<a id="dir-new-listing"></a>
### 1.23 `DIR` has a new listing and new options (`OPTION 8`)

**Please read this before upgrading if a program reads the output of `DIR`**, for instance with
`DIR >file` or [`DIR >arr$`](#redirection-into-an-array): the layout has changed. `DIR -O`, or
`OPTION 8 ON` for every `DIR`, gives the old listing exactly.

A plain `DIR` now looks like this:

```
Directory of M:\qsmrp\data\*.*
2026-10-20 23:36              7  "a,b.txt"
2026-10-20 23:36      2,500,000  big.dat
2026-10-20 23:36          <DIR>  sub
2026-10-10 23:36             10  week.txt
 3 Files, 1 Folder, 2.4 MB Used, 59.2 GB Free
```

- **Dates** are `yyyy-mm-dd hh:mm`, with a four-digit year and a 24-hour clock.
- **Sizes** are in bytes with commas, however large. They no longer switch to KB above 999,999
  and MB above 999,999,999.
- **Long names only.** The 8.3 name column is gone, and a name with a space or a comma in it is in
  double quotes.
- **Sorted by name.** Before, a listing came in the order the system gave it unless asked to sort.
- **`.` and `..` are not listed.**
- **The summary** counts files and folders separately, and gives space in KB, MB, GB or TB rather
  than always in kilobytes.

**The options:**

| Option | Effect |
|---|---|
| `-T` | Sort by date and time, newest first |
| `-S` | Sort by size, largest first |
| `-R` | Reverse whichever order applies |
| `-A` | Attributes. Windows: their names (`ReadOnly`, `Hidden`, `System`, `Archive`). Unix: the permission string, owner and group |
| `-L` | The permission string as well. On Windows, the same as the default format |
| `-N` | No `Directory of` heading |
| `-B` | Names only, one per line, quoted as in the listing above |
| `-W` | Names only, across the rows, in as many columns as the window holds |
| `-C` | Names only, down the columns, sized the same way |
| `-M` | Machine format, for programs (below) |
| `-ddd` | Only entries changed *ddd* or fewer days ago: `-7` is today and the 7 days before it |
| `+ddd` | Only entries changed *ddd* or more days ago. With `-ddd`, a range: `+7 -30` is entries changed from 7 to 30 days ago |
| `-P` | Pause after each screenful, as before |
| `-O` | The old listing, and the old meaning of every other option given with it |

A tie in `-T` or `-S` order goes by name. **Days are calendar days**, by the date an entry changed
and not its time: today is day 0 and yesterday day 1, so the same entries match whatever time of
day `DIR` is run. **Both ends are inclusive**, so `+7 -30` takes in day 7 and day 30, and `-0` is
today only.

**`-M` - machine format.** One line per entry, with no heading and no summary, and every field but
the name in the same column on every line:

```
        2500000,2026-10-20,23:36:39,F,---A,,,big.dat
              7,2026-10-20,23:36:39,F,---A,,,"my file.txt"
              0,2026-10-20,23:36:39,D,----,,,sub
```

The fields are `bytes,date,time,type,attributes,owner,group,name`. The size has no commas and is
right-aligned in 15 characters. `type` is `D` for a folder and `F` for a file. The attributes are
`RHSA` letters on Windows (`-` where absent) and `rwxr-x---` on Unix, and owner and group are empty
on Windows. The name is last and quoted by the CSV rule, so the output reads as CSV, and a program
can also take everything after the seventh comma as the name.

**With a [glob](#dir-glob-patterns)**, each folder still gets its own heading. With `-N`, and
always with `-M`, each name is given whole instead, since there is no heading to say which folder
it is in.

**What a program may notice:**

- **Three options changed meaning.** `-A` was "archive bit set only" and now shows attributes; `-L`
  showed the permission string in the old layout; `-N` suppressed all screen output and now
  suppresses only the heading. `-U` (no long names) is gone, since the listing has no short ones.
- **An unknown option is now error 1006**, *syntax error*. Before, `DIR` accepted options meant
  for other commands, such as `-F` and `-V`, and ignored them. With `-O`, they are still accepted.
- **A name that matches nothing is still error 4152**, *file not found*. A name that matches
  something of which `-ddd` or `+ddd` leaves nothing is not an error: the listing is empty.

**`-O` restores the old listing entirely**: the old layout, and the old meaning of every other
option given with it. So an existing `DIR -O`, which used to mean "sorted", gives exactly the
output it always did, and an old option string still works with `-O` added. **`OPTION 8 ON`** makes
every `DIR` behave as if given `-O`. It may be set in `brconfig.sys` or with `CONFIG OPTION 8 ON`,
and `STATUS CONFIG` shows it. The number is reused: it was once use old style loop counter for
keyboard, long since withdrawn, and 4.3 refused it as a bad `OPTION`, so no working configuration
file already has it.

<a id="command-help"></a>
### 1.24 `-?` lists a command's options

Every command takes `-?` in place of its arguments and lists the forms and options it accepts,
instead of running:

```
READY
COPY -?
COPY from to [options]
  from may hold wildcards; to may be a folder.
  -F           overwrite files that exist without asking
  -V           ask before each file (y/n/all)
  -N           show no messages
  -P           pause after each screenful
  -D           leave out deleted records (internal files)
  -S           copy a file even when it is open for output
  -nnn         give the copy a record length of nnn
  PRINT        send the report to the printer
  >file        write the report to a file; >>file appends
  >name$       fill the string array name$, a line to an element
```

- **`-?` must be the whole of the arguments.** `COPY -?` lists; `COPY a.txt -?` is a `COPY` with
  an option it does not know, which is a syntax error as before. So a file name or a `LIST` search
  string that contains `-?` is never mistaken for it.
- **Nothing is run.** The command does not start, so `RUN -?` loads nothing and `SYSTEM -?` does
  not leave BR.
- **A long list pauses after each screenful**; any key goes on and Ctrl-A stops it.
- **`DIR -?` shows the options of the listing in use**: the 5.0 ones, or under
  [`OPTION 8`](#dir-new-listing) the 4.x ones.
- **Every command has it except `HELP`.** The file and directory commands, `LIST`, `DEL`,
  `RENUM`, `AUTO`, `EDIT`, `LOAD`, `SAVE`, `REPLACE`, `MERGE`, `RUN`, `GO`, `CLEAR`, `PROC`,
  `SUBPROC`, `PROCERR`, `SKIP`, `ALERT`, `STATUS`, `BREAK`, `DISPLAY`, `DEBUG`, `AI`, `CONFIG`,
  `INDEX`, `SORT`, `SYSTEM`, `PROTECT`, `DATE`, `TIME` and `VERIFY`.

Some of what it lists was never written down before - `PROTECT name READ|WRITE`, `EDIT -` and
`EDIT ~`, `PROCERR REM`, `LIST CLAUSES` and `NOEJECT`, `INDEX VERIFY`, `SHR` and `BTREE`, and the
`SYSTEM` shell flags among them. The text was written from each command's own parser.

**And a digit at a `-P` pause.** `LIST -P` has always paused after each line and taken a digit
there: `5` lists the next five lines before pausing again. **`TYPE -P` now takes it too**: at its
pause, a digit from 2 to 9 shows the next that many lines, and any other key the next screenful as
before.

<a id="rename-folders-and-file-systems"></a>
### 1.25 `RENAME` stays on one file system, and renames folders with `-D`

**`RENAME` works within one file system.** A *to* on another drive, share or mounted file system
is refused with error **4138**, "can't rename from one file system to another, or between client
and server", and both names are left as they are. To move a file there, use `COPY` and then `FREE`.

**`RENAME -F`** gives the new name to the file being renamed, even when another file already has
that name. The other file is removed only if the rename succeeds.

**`RENAME from to -D` renames a folder**, with everything in it:

```
RENAME reports reports2025 -D       the folder reports is now reports2025
RENAME reports archive -D           archive is a folder, so this is archive\reports
```

- *from* must be one folder, with no wildcards. If it is not a folder, the error is **4203**.
- As with a file, a *to* that is an existing folder receives *from* under its own name.
- Any other *to* that exists is refused with **4150** and never replaced, so `-F` has no effect.
- `-V` asks `Rename? (y/n)`, and `-N` and the redirections work as for files.
- Without `-D`, `RENAME` acts on files only. For `COPY`, `-D` means leave out deleted records.

<a id="copy-free-recursive"></a>
### 1.26 `COPY -R` and `FREE -R` take folders whole

`-R` lets the name match folders as well as files, and a folder that matches is taken whole, with
everything in it at every level. The pattern decides what matches exactly as it does without `-R`:
a `*` looks in one folder, and `**` (see [`DIR` takes glob patterns](#dir-glob-patterns))
searches the folders below.

**`COPY from to -R`.** Each file and folder keeps its place below the fixed part of *from* - the
folders before the first pattern, or before the last part - and goes to that place below the
folder *to*:

```
COPY src backup -R             the folder src, whole, as backup\src
COPY src\* backup -R           everything in src, as backup\...
COPY src\*.brs backup -R       the .brs files in src, and any folder in src named *.brs, whole
COPY src\**\*.brs backup -R    every .brs file and *.brs folder below src: src\lib\b.brs
                               is backup\lib\b.brs
```

- *to* is a folder. It and the folders below it are made as they are needed, and a folder copied
  whole is made even when it is empty. A *to* that is a file is error **4150**. *to* takes no
  wildcards (error **600**).
- A *to* inside a folder being copied is error **4299**, as the copy would be among what it copies.
- An entry inside a folder already taken is copied once, as part of that folder.
- Each folder's entries are in name order, each folder before what is in it, down to 40 levels.
- `-F`, `-V`, `-N`, `-P`, `-D`, `-S` and the record length apply to each file as for any `COPY`.
  Without `-F`, a file that exists is asked about, and refused with **4150** in `UNATTENDED` mode.

**`FREE name -R`** deletes what *name* matches, and a folder that matches is freed whole: its
files, then its folders, deepest first. `FREE old -R` removes the folder `old` and everything in it;
`FREE src\*.tmp -R` deletes the `.tmp` files in `src` and any folder there named `*.tmp`. Under `-V`
each file is asked about, and a folder that still has a file in it is kept.

`RENAME` and `DROP` do not take `-R`: given it, they stop with error **1006**.

**A name that ends with `\` or `/` matches folders only** (see [1.17](#dir-glob-patterns)), so with
`-R`, `COPY src\*\ backup -R` copies the folders in `src`, each whole, and not its files, and
`FREE tmp\*\ -R` frees the folders in `tmp` and leaves its files. Without `-R` such a name matches
nothing (4152), as these commands then act on files only.

<a id="move"></a>
### 1.27 `MOVE` - rename when possible, otherwise copy and free

`MOVE from to` moves each file that *from* matches, and with `-R` each folder, to *to*. A file or
folder is renamed when the system can do the whole of it in one step. When it cannot - *to* is on
another drive, share or file system, or on the other side of the client (`@:`) and the server - it
is copied and then freed.

```
MOVE reports\*.pdf archive          the .pdf files in reports, into the folder archive
MOVE reports archive -R             the folder reports, as archive\reports
MOVE reports\* E:\archive -R        everything in reports, copied to E:\archive and freed
MOVE src\**\*.bak old -R            every .bak file below src, each keeping its place below old
```

- **What is moved, and where, is as for `COPY`.** *from* matches files, and with `-R` folders too,
  each moved whole; `**` searches the folders below, and a name ending in `\` matches folders only.
  Without `-R`, *to* is a folder the files go into, or a name for them (`*` in it as for `COPY`). With
  `-R`, *to* is a folder, made as needed, and each file and folder keeps its place below the fixed
  part of *from*, as in [1.26](#copy-free-recursive).
- **One at a time.** Each file or folder is moved completely before the next: renamed, or copied
  and freed. A folder that is being copied is moved entry by entry in the same way, so whatever
  in it can still be renamed is renamed. An entry that has already gone with a folder moved before
  it (`src\**\*` matches a folder and what is in it) is not moved again.
- **Onto a folder that exists.** A folder moved onto one that is already there is merged into it:
  each file and folder is moved in, and the folder left behind is removed once it is empty.
- **Onto a file that exists.** As for `COPY`: asked about, replaced with `-F`, and refused with
  **4150** in `UNATTENDED` mode. A file left where it is keeps its folder there too.
- A folder moved into itself (`MOVE src src\old -R`) is error **4299**.
- `-R`, `-F`, `-V` (`Move? (y/n/all)`), `-N`, `-P` and the redirections work as for `COPY`. 
  `MOVE` refuses `-D`, `-S` and record length change, available in `COPY`, with error **1006**.
- `MOVE` may be shortened to `MO`, and Tab completes its two names as it does for `COPY`.

<a id="security"></a>
## 2. Security

<a id="the-debugger-connection-is-now-encrypted-and-authenticated"></a>
### 2.1 The debugger connection is now encrypted and authenticated

**This changes how an existing debugger connects, and a debugger that has not been updated will no
longer attach.** Please read this before upgrading if you use `DEBUG CONNECT` or `DEBUG LISTEN`.

Previously, whatever connected to the debugger socket became the debugger, with no exchange of any
kind first. That carried the right to issue commands, step the program, read variables and reach
`DEBUG INTERNAL`; and because BR allows only one debugger at a time, connecting also locked the
real debugger out. Everything the debugger then saw — program source, variable values and BR's log
stream — crossed the connection in clear text.

The connection now runs over TLS 1.3, and inside it BR and the debugger prove themselves to each
other with a shared token. Both sides prove themselves, not just the debugger: `DEBUG CONNECT` dials
out to a host you name and then streams your source and data to it, so BR proving it is BR matters
as much as the other way round. A connection that fails either step is closed and recorded in the
log, and the channel stays free for the legitimate debugger.

Three modes, set with the new `DEBUG AUTH` command:

```
DEBUG AUTH                    ! report the current mode, and where the token is
DEBUG AUTH COOKIE             ! the default
DEBUG AUTH TOKEN <64 hex>     ! a token you supply, for a debugger on another host
DEBUG AUTH OFF                ! no encryption, no authentication - as BR behaved before
```

In the default `COOKIE` mode BR generates a fresh token for each session and writes it where only
your own account can read it, alongside BR's other per-user files — on Windows
`%LOCALAPPDATA%\ADS\brdebug.token`. A debugger running as you reads it from there and needs no
configuration. The token is written as soon as the port opens, so it is always in place before
anything can connect. `DEBUG AUTH` on its own prints the mode and the token's location.

`TOKEN` mode is for the case the cookie cannot cover — a debugger on another machine, which cannot
read your local file. Supply the same 64 hex digits to both sides. No token file is written.

`DEBUG AUTH OFF` restores exactly the old behaviour and exists for one reason: so that a debugger
that has not yet implemented its half can still be used during the transition. It is recorded in the
log as a security event both when you set it and each time a debugger attaches under it. Please
treat it as temporary.

Every outcome is written to the log at the security level, with the address of the peer, and on
success the TLS version and cipher:

```
Debugger authenticated over TLSv1.3 TLS_AES_256_GCM_SHA384 from 127.0.0.1
Debugger attach refused: wrong token over TLSv1.3 from 127.0.0.1
Debugger attach refused: the TLS handshake with 127.0.0.1 failed
```

A peer that connects and then says nothing is refused after a few seconds rather than holding the
channel; BR carries on either way.

<a id="the-debugger-port-no-longer-accepts-connections-from-the-network"></a>
### 2.2 The debugger port no longer accepts connections from the network

`DEBUG LISTEN` used to bind every interface on the machine, so the debugger port was reachable from
the network. Anything that connected to it was treated as the attached debugger, which carries the
right to issue commands, step the program and read variables.

**`DEBUG LISTEN` now binds the loopback interface only, and there is no option to change that.** A
debugger on the same machine connects as before; nothing off the machine can.

```
DEBUG LISTEN                  ! port 9555, loopback
DEBUG LISTEN 9555             ! the same, said explicitly
```

Anything after the port is now a **syntax error** (1006), refused rather than ignored: a script
still carrying the keyword must fail where you can see it, not bind loopback while you believe it
is on the network.

Note what that means for a procedure. A syntax error halts a proc at the `READY` prompt - or
aborts an `UNATTENDED` run - and **`PROCERR RETURN` does not carry it past one**; it carries a proc
past a runtime error, which this is not. So a startup procedure with the old keyword in it stops
there until the line is removed. That is deliberate.

**If you need to attach a debugger from another machine, forward the port** — with SSH, or
whatever your site already uses for administrative access. That is a deliberate choice either way;
the difference is that forwarding puts it with whoever administers the machine, rather than with
whoever can type a BR command into a running session.

`DEBUG CONNECT`, where BR dials out to a debugger the operator names, is unaffected, and remains
the way to reach a debugger that is somewhere else.

**The default port has also moved, from 8556 to 9555.** The debug observer's default moved with it,
from 8558 to 9556. The 8555 series belongs to `brlistener`, which already uses 8555, 8557 and 8559
for its successive versions; the debug channel had taken two ports out of the middle of that range
and left it unable to grow. A debugger that connects to an explicit port is unaffected; one that
relies on the default needs updating, which it needs anyway for the authentication above.

**Loopback and authentication are two defences, not one repeated.** The connection is now
encrypted and authenticated (below), and it is still bound to loopback: the first means there is no
endpoint off the machine to reach at all, which is a stronger statement than any check made after
something has already connected.

<a id="restricted-sessions"></a>
### 2.3 Restricted sessions

A session can be started **restricted** — see
[Starting a disposable restricted session](#starting-a-disposable-restricted-session). It is
restricted from before it reads its configuration file until it ends, and throughout:

- **the session may change only files it created itself** — **error 4153** otherwise. It may
  create files freely, and may then rewrite, empty, rename, copy over and delete them for as long
  as it runs. Anything else it may read but not write, empty, rename, delete, change the attributes
  of, or overwrite by `INDEX`, `SORT`, `COPY` or `SAVE`. BR tracks the session's files by path and
  by identity on disk, so a file someone else later puts under the same name is not the session's;
  the tracking is the session's own and ends with it. A new program is also refused if it would be
  loaded in place of an existing one of the same name under another program suffix;
- commands are refused unless they are on a permitted list — **error 4154**. The file commands —
  `FREE`, `DROP`, `RENAME`, `COPY`, `RMDIR`, `PROTECT`, `SAVE`, `REPLACE`, `INDEX` and `SORT` — are
  on the list, and each is decided per file by the rule above. `EDIT` is refused;
- `SYSTEM` with an operating system command is refused. `SYSTEM` on its own still ends the session
  normally;
- configuration operations are refused unless permitted, whether they arrive from a `CONFIG`
  command or from the session's configuration file. Refused are those that can reach outside BR or
  move the audit trail: `SHELL`, `EDITOR`, `PDF_READER`, `LOGGING`, `DATABASE`, `HTTP`, `HTTPS`,
  `SETENV`, `WBSERVER`, `BRSERVER`, `WSID` and `LOGIN_NAME`. Appearance, formatting, limits,
  printing destinations, `SPOOLCMD`, `OPTION`, `USERLEVEL`, `DRIVE` and `EXECUTE` are unaffected,
  so a session can still declare its drives and name the program it is to run. `SPOOLCMD` may be
  set, but the command never runs (below);

  `DATABASE` is refused as a whole for now. SQL is a write path the file rules above do not
  reach, so a connection would let a restricted session change data freely; the consequence is
  that such a session cannot report from a database, and a narrower rule is intended.

<a id="the-restricted-session-read-list"></a>
### 2.4 Where a restricted session may be: the file list

A restricted session could always reach anything the account could. The rules above govern what it
may **change**; a site that needs to govern what it may **see and touch at all** can now install a
file list. This matters most where a model is driving the session: what such a session can read is
what the model can be shown, and what it prints leaves the site with the model's next request.

**With no file list installed nothing changes** — a restricted session reaches whatever the account
can, as before. The feature costs an existing site nothing until it chooses to use it. **All
folders on a client machine are likewise unrestricted until a list is installed on that machine**:
each side reads its own, and restricting a server does not restrict a client.

**The list is `brrestrict.sys`, in the directory of the BR executable.** It is not a configuration
statement and not a command-line argument, so a session cannot choose its own: the only way to
change what a session may reach is to change the installation it runs from.

One entry a line:

```
# what a disposable reporting session may reach
Q:\data                            a directory: it and everything under it
Q:\rates.dat                       one file
Q:\data\*.rpt                      the .rpt files in data
Q:\data\**\*.rpt                   and in every directory under it
!Q:\data\payroll                   an exception inside a permitted tree
:C:\ADS\shared                     a native path, marked by the leading colon
```

Anything the list does not reach is refused with **error 4165**, *restricted session:
brrestrict.sys does not permit this file*.

**Entries can be given per user.** A line of its own beginning `@` qualifies every entry that
follows it, until the next one:

```
Q:\common                          everybody: no heading yet, so @all applies
@payroll                           only when the session's login name is payroll
Q:\wages
!Q:\wages\archive
@all                               and back to everybody
Q:\reports
```

`@all` is the default, so a list without any `@` line behaves exactly as before, and
`@<username>` matches the login name without regard to case — as `brconfig.sys` already matches
its own `@<username>`. Entries under a heading that does not match this session are not loaded at
all. Note that this is a **section** heading governing the lines below it, where `brconfig.sys`'s
`@` qualifies the rest of its own line; a file list is usually a run of entries per user, so the
name is written once above them. An `@` line that names nobody switches the entries below it off
rather than leaving the previous heading open.

**It governs every operation on a named file**, not reading alone: an `OPEN` for input or output,
`INDEX`, `SORT`, `COPY`, `SAVE`, `REPLACE`, `FREE`, `DROP`, `RENAME`, `PROTECT`, `MKDIR`, `RMDIR`,
and `DIR` or any other directory listing. So a restricted session cannot see out of the folders
the list names, and cannot put anything into a folder it cannot see. Error 4165 and error 4153
answer different questions — 4165 is *the site does not let this session near that file*, 4153 is
*this session did not create that file* — and the list is tested first, being the outer boundary.

- **Entries are BR names**, resolved through the session's `DRIVE` statements, **unless they begin
  with a colon**, which is BR's mark for a native path everywhere else and is the mark here too.
  The drive mapping is fixed when the list is read, so a mapping added later cannot move an entry.
  On the client, entries are native names either way, because client file names are not subject to
  `DRIVE` statements. None of BR's other filename conventions apply — in particular not the
  `<filename>/<parent-path>` form an open string still accepts; a forward slash in an entry is an
  ordinary path separator.
- **`#` begins a comment**, and `!` does **not** — `!` marks an exclusion, as in a `.gitignore`.
  This is the one place where BR's own comment character does not apply, and it is deliberate: a
  line meant as a comment but read as an exclusion excludes nothing and is logged, while an
  exclusion read as a comment would silently leave a file permitted.
- **An exclusion overrides every permit**, whatever order the lines are in. To allow something
  inside an excluded area, narrow the permit instead of adding one.
- **`*` and `?` stay within one name and `**` crosses**, which is POSIX glob under `FNM_PATHNAME`
  plus `.gitignore`'s `**`. So `data\*.rpt` is the files in `data` itself, and `data\**\*.rpt`
  reaches every directory under it, `data` included. There are no bracket expressions and no
  backslash escape.
- **Whatever an entry names, it takes the tree under it if it is a directory** — by pattern as
  well as exactly, so `Q:\*\data` is each application's data directory and its contents.
- **Names are compared without regard to case on every platform**, Linux and macOS included, so a
  list written and tested on Windows means the same thing on the server it is deployed to.
- **An entry for something not there yet applies when it appears.** The list is read once at
  startup, and an entry naming a path that does not exist then is kept rather than discarded — so
  an exclusion for a nightly export directory, or for a volume not yet mounted, is not one that
  quietly never applies.

**BR's own working files are inside the rule.** A site that installs a list has to name the work,
spool and print directories in it as it names its data. Exempting them could not be made safe,
because `WORKPATH`, `SPOOLPATH` and `PRINTDIR` are configuration statements a restricted session is
permitted to set. They can be named narrowly rather than by opening their directory —
`:C:\ADS\w*.wrk` permits the work files in `C:\ADS` and nothing else there.

Two things are reachable whatever the list says:

- **the files the session created itself**, wherever it put them — it wrote the content, and a
  session that could not read back its own sort output or its own index would be no use;
- **the session's configuration file and its `INCLUDE`s**, which are read before the list comes
  into force. Everything after that is governed: the startup command, the procedure it names, the
  program that procedure loads, and every operation from then on.

`EXISTS` reports nothing about a file outside the list, and a listing of a permitted folder still
shows the names of excluded things inside it — the exclusion stops them being opened or listed,
not named.

**Every name is resolved to the file it actually reaches before it is compared**, and so is every
entry in the list. A junction, a symbolic link, `..`, a relative path and an 8.3 short name
therefore cannot widen or evade the list — in particular, **a junction inside a permitted
directory does not make its target reachable**. The same resolution means a directory may be named
in the list by any of its paths.

Each entry, and every refusal, is written to the log as a security event naming the resolved
path, so an administrator can read back from the log exactly what the list was taken to mean.

The full reference is `AI-Restricted-Operations.md`, *Files: where the session may be*.

<a id="ui-regression-scripts"></a>
### 2.5 UI regression scripts

`br_mcp_driver uitest` runs a plain text script against a running session, so a programmer who has
changed a screen can say what should be on it and rerun that after the next change. One step a line:

```
expect row 0 "ORDER ENTRY"
expect "Customer code:"
absent "Customer not found"
field 0 spec "C 8"
type ACME
press ENTER
expect "Customer not found"
```

`expect` retries for a few seconds, because a program takes time to paint; `absent` does not, since
a thing that must not appear cannot be waited for. A failed step does not stop the script, so one
run reports everything that is wrong, and a failed `expect` prints the screen with it. Keys are
named — `ENTER`, `TAB`, `F1`, `SHIFT-F3` — and a number still works for anything unnamed. Typing
needs the keyboard grant, which is given inside the session and cannot be taken by the script.

Several scripts may be named in one command, which is how a suite is run: the assistant channel is
claimed once per session, so the set goes in together.

**`DLL(...)` is refused**, with error 4154. A DLL is native code: once it is running it is outside
every check a restricted session is made of, and it could call the operating system directly. Since
a restricted session may create files, it could otherwise write a library and load it. `MSG(...)`
is permitted action by action: actions that read or arrange windows work, and `MSG("dump", …)` and
`MSG("shot", …)` follow the file rule. `MSG("send", …)` works, and as in every
session it types into this session only (see
[the behaviour change](#msg-send-now-types-into-br-only-and-msg-kb-is-removed)). The pointer actions (`setpos`, `setwpos`, `lclick`, `mclick`, `rclick`) are refused with 4154,
because a click at screen coordinates can land on any program. An action added later is refused until
classified.

**Printing is to installed printers.** A restricted session may print to printers installed on the
computer, which may be shared printers, and to preview. Printing to a UNC name is refused with 4154:
a UNC name that is not an installed printer is opened as a file and the job written into it. A job
written to a named file, such as `PDF:` output, follows the file rule.

**The client enforces the same rule on its own files.** The server tells the client that the
session is restricted, and the client applies the file rule to the files a program names for it —
the same rule, with its own list of what the session created on the client side.

Two further routes out to the operating system are closed while a session is restricted: a spool
command does not run — a print job that would hand its file to the `SPOOLCMD` command is refused
with 4154, although the setting itself is allowed — and **Ctrl-]**, which opens a shell from the
terminal, is refused — by the client in client/server mode, where the shell is started on the
client.

This exists so that a program written on a user's behalf — by an assistant, or by anything else
the application does not fully trust — can be run without putting existing data at risk. Because
the check is at the operation rather than in the source, it cannot be evaded by how the code was
reached: `EXECUTE` of a string built at run time, `CHAIN`, a `LIBRARY` call and a called procedure
all land on the same check.

**Nothing clears it but ending the session.** Not a program ending, not `CHAIN`, not `LIBRARY
RELEASE`, not an error exit, not returning to the command console, and not the programmer: a
session that needs write access again is restarted. Two consequences to plan for:

- **Your own later work in that session is restricted too.** After such a program has run, an
  ordinary program that writes data is refused until BR restarts. An application that must keep
  writing should run the untrusted program in a separate session and treat that session as
  disposable.
- **A restricted session can end itself.** `SYSTEM`, `SYSTEM <n>` and `SYSTEM LOGOFF` exit as they
  always did; only the form that runs an operating system command is refused. (An earlier draft of
  these notes said `SYSTEM` was blocked outright. It was, briefly, and that was changed.)

Every refusal is written to the log, as is the moment the session became restricted. The state is
also recorded in `wbserver.dat` as a byte lock, so other processes can see which sessions are
restricted — and so that a session that crashes cannot leave the mark behind for whichever session
next reuses its number.

<a id="starting-a-disposable-restricted-session"></a>
### 2.6 Starting a disposable restricted session

**New function `SPAWN_RESTRICTED(command$ [, config$ [, wait]])`.** It starts a new BR session on
the same workstation ID — the next free session number — restricted from its first moment, and runs
`command$` as that session's startup command, typically `PROC <file>`. `config$` names its
configuration file and defaults to the current session's.

- With no `wait`, or 0, it returns the new process's id at once.
- With a `wait` in seconds it waits — the screen keeps repainting and ATTN still works, as with
  `SLEEP` — and returns the session's exit code. A session still running when the wait runs out is
  ended, and **error 4157** is raised.

This is the way to run something untrusted without restricting the session you are working in:
the new session is restricted and disposable, and yours is not.

**It is restricted before it reads its configuration file.** That ordering matters because the
configuration file is the caller's choice: the configuration operations listed above are refused in
it, not applied and then locked. Since `LOGGING` and `WBSERVER` are among them, the new session is
handed the current session's log and `wbserver.dat` instead, and logs to the same file.

**One session per workstation ID is always kept free**, so that spawned sessions can never take the
last one a person might need: when eight of the nine are in use, `SPAWN_RESTRICTED` raises **error
4155**. A session gives its number back when it ends, including one ended at its timeout.

A restricted session may not call `SPAWN_RESTRICTED` (error 4154). It is available in local mode on
Windows; elsewhere it raises **error 4156** for now.

New `brserver` command-line flags, which `SPAWN_RESTRICTED` passes and which are not normally typed
by hand: `--restricted`, `--restricted-log=<folder>` and `--restricted-wbserver=<dir>`. The
last two are accepted only with the first.

<a id="calling-an-assistant-from-a-program"></a>
### 2.7 Calling an assistant from a program

A program asks an assistant a question the way it asks a person: on the screen, with a field to
answer in. The assistant — reading the screen over the AI harness channel, and holding the keyboard
grant the person gives it — types the answer. **There is no other way in**: no connection of its own
and no path into a variable that a person's typing does not also take. So the field's own type and
length check the answer exactly as they check a person's, and the person can always answer instead.

Program source an assistant writes is typed into a file, never into a variable; it is shown to the
person and run only if they agree, and then in a restricted session started with
`SPAWN_RESTRICTED`. The assistant's grant is withdrawn while the program asks for that agreement, so
the assistant cannot give it on the person's behalf.

`br/aiaccess/agentlib.brs` is a reference library for this — stored prompts, each naming its
question and the field its answer goes in — and `br/docs/AI_ACCESS.md` (Track C) describes it in
full.

<a id="an-assistant-no-longer-types-at-the-ready-prompt-by-default"></a>
### 2.8 An assistant no longer types at the `READY` prompt by default

An assistant holding the keyboard grant could type wherever BR was taking input, including the
command line, where `FREE` or `SYSTEM` is one keystroke away from an assistant that misfires.

Its keys now go in only while a **program** is waiting for input. At `READY` they are **held** —
not discarded and not refused — and go in when a program next asks, so an assistant may still
type ahead. A session that wants the old behaviour opens the channel with

```
LET X=MSG("harness", <port>, "DEVELOP")
```

which is what a development session wants, because there typing at the console is the point. A
restricted session is refused that mode.

<a id="both-windows-show-a-grant-and-a-restriction"></a>
### 2.9 Both windows show a grant and a restriction

**Changed 2026-10-08.** A session marks its title bar `[RESTRICTED]` while it is a restricted
session, and `[AI Has Keyboard Access 4:37]` - with the time left - while an assistant holds the
keyboard. Both marks now appear on **both** of BR's titled windows: the application's own and the
Command Console's. Previously only the application window carried them.

Which window an operator is looking at is their business, not the session's - they break to
`READY`, work at the console, and go back - so a mark on one of them told them the truth only
while they happened to be in front of it. For the Console that is exactly when they are typing
commands by hand, which is when it matters most. With `GUI OFF` there is no application window at
all, and the Console is the only one there is.

Each window keeps its own title text - whatever a program or the configuration set, or the
Console's own caption - and the marks follow it, `[RESTRICTED]` first. A program that sets the
title is unaffected: the text it sets is kept apart from the marks, so neither is lost and neither
doubles when the other changes.

<a id="an-assistant-cannot-extend-its-own-grant"></a>
### 2.10 An assistant cannot extend its own grant

**New 2026-10-09. New error 4166, `BREGRANTNOTRAISED`** - *the assistant's own commands may not
raise the keyboard grant - only the person at the session may.*

A grant is given at the session, by you, for a fixed time, and the time left is in the title bar -
so lending the keyboard has a known end. But a line an assistant asked to have run goes through
BR's console as if typed, and `MSG("grant", 3600)` is a line like any other. Nothing stopped a
turn from granting itself another hour, or `MSG("grant", -1)`, which never expires at all.

**A grant may now only be lowered from there.** While a line the assistant sent is the thing
running, `MSG("grant", n)` is accepted for `n = 0` - handing the keyboard back, which an assistant
that has finished should be able to do without asking - and refused for every other `n`:

| from the assistant's own lines | |
|---|---|
| `MSG("grant", 0)` | allowed - the grant ends |
| `MSG("grant", <any time>)` | **refused, 4166** |
| `MSG("grant", -1)` (never expires) | **refused, 4166** |

A shorter grant is refused along with a longer one. Not because shortening is dangerous, but
because the side making the decision cannot tell the two apart - the grant lives at the client and
the check is made at the server, before the request is sent - and nothing is lost by it: the
assistant can already end a grant early over its own connection, which the protocol has always
called the only change to a grant it may make.

**The rule covers everything a sent line starts**, including a program its own `RUN` line loaded
and anything that program calls. Your own commands are untouched: a `MSG("grant", …)` you type, or
one in a procedure of your own, behaves exactly as before. Every refusal is logged.

<a id="a-turn-without-a-grant-asks-before-anything-destructive"></a>
### 2.11 A turn asks you before anything destructive

**New 2026-10-09. New error 4167, `BREAINOTPERMITTED`** - *the operator did not permit this
operation for the assistant.*

A command an assistant sends used to need the keyboard grant. That made the useful half of a
console conversation - the assistant saying "run this" - need the keyboard lent first, which is a
far larger thing to ask for than "look at my error". **A command now needs only an open turn**,
which only you can open, by typing `AI`.

What a turn may do without asking is the same either way:

| | within a turn |
|---|---|
| ordinary commands | run |
| anything destructive | **stops and asks you** |
| `SYSTEM` with a command, a spool command, the editor, `Ctrl-]` | **stops and asks you**, whenever an assistant is attached - a refusal is error 4167 |
| the powerful `CONFIG` operations | refused - error 4168 |

**The grant does not change that line, and for one release it did.** With the keyboard lent,
nothing was asked; the reading was that lending the keyboard is consent to whatever follows. It is
not. You lend the keyboard so the assistant can get on with the work, and you lend it once, for
minutes, before you know what it is going to do - so it cannot stand as consent to a particular
operation. What a grant buys is typing.

**It does not ask about the assistant's own work.** While the channel is open, BR keeps a list of
the files the session creates - the same create-then-own list a restricted session uses to decide
what it may change. A file on that list is the assistant's to rewrite; anything that was already
there, and belongs to somebody else, is what you are asked about. The list starts when the channel
opens and is emptied when it closes, so it means "created while an assistant was here" rather than
"created at any time". Without it every scratch file the assistant wrote raised its own question,
which is the fastest way to teach a person to answer without reading.

The question is on the console, where you are already reading the conversation:

```
[AI] the assistant asks permission to delete:
[AI]   C:\ADS\myapp\CUSTMAST
[AI] allow?  N = no, Y = this once, A = this turn, H = while the harness is attached:
```

- **`N`** refuses it, and the operation fails as though the file were protected - error 4167, which
  a program can trap.
- **A break key is not an answer at all.** Ctrl-A interrupts the question the way it interrupts
  anything else: nothing is allowed, nothing is refused, no error is raised, and the session takes
  an ATTN halt that `GO` resumes. An interrupt must never mean "go ahead", and it does not mean
  "no" either - the person has not answered, and the operation is simply not carried out.
- **`Y`** allows that one operation and is forgotten.
- **`A`** allows it and remembers it **until this turn ends**. Someone who has said "yes, the
  assistant may write to this report file" has said it; being asked six more times while it does
  that piece of work is noise, not safety.
- **`H`** allows it and remembers it **until the assistant disconnects** - the file joins the list
  above.

**There are two kinds of always because they are two different judgements.** Allowing a file for
the piece of work in front of you is one a person can weigh; allowing it for every turn until the
assistant goes home is a much larger one, and on a console left open all day the two are not
close. They used to be the same keystroke, which meant an answer given in the first turn silently
covered the twentieth.

The third line always names what would be kept, because "all" on its own is not something anyone
can weigh.

**It cannot be stepped around by putting the work in a program.** The question is asked where the
operation is attempted - the same points a restricted session refuses at - and not in front of
named commands like `FREE` and `COPY`. A list of commands is exactly what a sent line can walk
around: a program can open a master file for output and write over it without naming any of them,
and that open is asked about too.

**One operation asks one question, in its own words.** `FREE` asks about the delete, a rename
about the rename, `DROP` about emptying the file, and an `OPEN` for output about the open. BR tests
whether it can act before it acts - `FREE`, `DROP` and a rename each open the file exclusively
first, to find out whether another session holds it - and that test is not the operation, so it
asks nothing. A conflict there is the ordinary **error 4148**, *file sharing violation*, and it
happens before any permission question: a file somebody else has open is not a question for you to
answer.

**Every route to the operating system asks, and they all ask in one place.** What the shell runs
touches files through the operating system and never passes a BR gate at all, so the question cannot
be put where the files are - it is put where the shell is, inside `shell()` itself. That is the only
function every route passes through: `SYSTEM` with a command, a spool command, the editor `EDIT`
launches, the terminal's `Ctrl-]` escape. The gate used to sit in three of those four, which left
the editor and the shell escape reachable in two console lines.

The question names the program that would run, and what `A` or `H` remembers is **the first keyword**
for `SYSTEM` - so `H` on `cmd /c ...` passes later `cmd` commands and still asks about `powershell` -
or the route itself for the others, because an editor's first word is a program path rather than
something a person can weigh. An interactive shell is remembered never: saying yes to "a shell" is
saying yes to everything it can launch, so that one offers only `N` and `Y`.

**The person is asked about their own shell calls too**, for as long as an assistant is attached. A
rule the assistant could satisfy by asking the person to type the command for it would be the same
hole with one more step in it, which is why the question does not look at whose line it is. The cost
is one question per program per connection, not one per command.

The powerful `CONFIG` operations remain refused outright, with error 4168: those change what the
session *is*, and there is no program to name in a question about them.

<a id="option-83-for-an-application-that-starts-br-sessions"></a>
### 2.12 `OPTION 83` for an application that starts BR sessions

An application that spawns sessions of its own meets both halves of the new behaviour at once:
every `SYSTEM` it issues stops to ask, and every session it starts comes up restricted. For those
applications there is **`OPTION 83`**, which turns both off together:

```
OPTION 83 ON
```

With it set, this session asks nothing about operating-system calls — all four routes — and does
**not** raise the AI-user-mode flag, so the BR sessions it starts run normally. It is the exemption
`DEVELOP` mode already has from the flag, given to a user-mode session the site has declared
reaches the shell.

**It may be set only in the configuration file.** `CONFIG OPTION 83` at run time is refused with
**error 4172**, *this OPTION may be set only in the configuration file, never with a CONFIG
command*, whoever issues it. That is not tidiness: `OPTION` is on the permitted list for both the
restricted-session filter and the assistant filter, so without this an assistant could send
`CONFIG OPTION 83 ON` inside a turn and hand itself an unasked shell and unrestricted children —
the gate would be settable by the party it restrains.

**A restricted session is refused it outright**, configuration file or not. A contained session
that could set this would spawn an uncontained one, and a session restricted by the AI-user-mode
flag reads a configuration file that may be an assistant's own work — the reasoning that already
keeps `LOGGING` out of one.

**The flag is shared, so this exempts the session that sets it and nothing else.** It takes down no
flag another session holds: a second session with an assistant attached and no `OPTION 83` still
restricts what starts.

Turning it on is logged as a security event at startup, in those words, because it is the one
setting that lifts both gates at once:

```
OPTION 83: this session will NOT ask the operator about operating-system calls while an
assistant is attached, and will NOT restrict the BR sessions it starts.
```

**Use it where the application genuinely needs the shell**, not as a way round the question. What
it removes is the protection that stops an assistant reaching the operating system; with it off,
the only thing between an assistant's `SYSTEM` and the shell is that it has to get a line run at
all.

**A file on the client is decided by the client.** When a program reaches a file through an `@:`
path, the file belongs to the machine running the terminal, and only that side knows which of its
files this session created. So it makes the decision and reports back; the server puts the
question to you, in the same words and the same window as any other, and sends the operation again
if you allow it. Nothing about this is visible from where you sit - which is the point - but it is
why an `@:` operation is asked about at all.

**With `GUI OFF` the question still appears**, because it is written to the console and read with a
keystroke - the same path the `READY` prompt itself uses - rather than put in a dialog box. It
works the same way over a client/server link.

**In `UNATTENDED` mode a destructive operation is refused rather than asked about.** There is
nobody to answer, and a prompt with nobody at it is not a safeguard - it is a session that hangs
until someone notices.

Every question and answer is logged, and so is every operation refused for want of one.

<a id="a-turn-needs-the-consent-of-whatever-is-running"></a>
### 2.13 A turn needs the consent of whatever is running

**New 2026-10-13. New error 4169, `BREAITURNNOTPERMITTED`** - *a program or procedure is active:
set `ENV$("AI_TURN_OK")` to `"Y"` before an AI command, or end what is running* - **and 4170,
`BREAITURNFLAGNOTSET`**, for a line of the assistant's that tries to set the flag itself.

**You cannot break into a running program to ask the assistant something.** BR has never let an
interrupted program be replaced: `SAVE`, `REPLACE`, `RENUM` and `RUN` all refuse with **2108**,
*program is active*, while one is. An AI turn can `LOAD`, which is the same thing - so `AI` is now
refused the same way. End the program, or say it is all right:

```
00100    LET X=SETENV("AI_TURN_OK","Y")
00110    STOP                                  ! the person can now ask the assistant
00120 ! GO comes back here
```

A **procedure** is in the same position for a different reason. A proc stands above a program the
way an operator does, so it survives a turn - but it is driving the program state, and a turn can
change it underneath. A proc that resumes expecting the program it loaded, and finds another, does
harm it cannot detect. So a proc says so too, before each inquiry:

```
LET X=SETENV("AI_TURN_OK","Y")
AI which of these customers is over their limit
```

**Why the flag is needed even when the proc wrote the `AI` line itself.** Writing `AI <text>`
consents to *asking*. It cannot consent to the `LOAD` and the `RUN` the assistant will send,
because those did not exist when the line was written - which is the whole point of a turn. The
flag is you saying *I know the loaded program may be gone when control comes back to me*.

| | |
|---|---|
| nothing running | no flag needed |
| a program or a procedure active, no flag | **4169**, before the assistant hears of it |
| the flag set to anything but `Y` | **4169** - `"y"` counts, `"YES"` does not |
| the flag set by a line the assistant sent | **4170**, and logged |
| `CONFIG SETENV AI_TURN_OK` | refused where the configuration file is read |
| a proc whose **last** line is the `AI` line | no flag needed - BR has already closed the proc |

**Two things take the flag down, and the `AI` command is neither.** You clear it yourself, with a
`SETENV` of any value but `"Y"`; or the turn ends, which clears it for you. So a proc driving three
turns still says so three times - each turn's end takes the last one's consent with it - but
reading the flag is not spending it.

**One case follows from that and is worth knowing.** An `AI` line that never opened a turn - no
assistant listening, 4158 - leaves the flag standing, because nothing ended. The next `AI` line in
that procedure is still authorised. If that matters to your program, clear the flag yourself:

```
00200    LET X=SETENV("AI_TURN_OK","Y")
00210    AI what is wrong with this record
00220    LET X=SETENV("AI_TURN_OK","")     ! whatever became of the turn
```

The flag also stays **readable during** a turn, so a program the assistant's own `RUN` loaded can
check `ENV$("AI_TURN_OK")` and find out how it was reached.

**`AI NEW` needs no flag.** It only ends a turn, and gating that would strand one.

**New 2026-10-13. New error 4171, `BREAITURNNOTYOURS`** - *the assistant may not use the `AI`
command: a turn is the person's to start, and a reply is how one ends.* A turn's whole authority
is that a person typed `AI`, and the state is single - so a line the assistant sent that ran `AI`
ended the person's turn and opened one of its own, with a question nobody had asked. What made
that worth a rule rather than a curiosity is where the new question goes: an `ASK` reaches
whatever is listening, which in `chat` mode is the model that just sent the line, so it would be
handed its own text as a fresh inquiry and could do it again - a loop nobody started. `AI NEW` is
refused from there too: the assistant already ends its turn by answering.

**Two commands behave differently inside a turn**, both to protect the procedure that consented:

- **`PROC <file>` from the assistant pushes**, like `SUBPROC`, instead of replacing the procedure
  it was sent into. Replacing it would destroy the proc that said the turn could happen. Your own
  `PROC` at the console is unchanged.
- **`CLEAR PROC` ends an open turn**, along with the procedures - and so does `CLEAR ALL`. A turn
  is a state of the command processor like a proc feeding it lines, and `CLEAR PROC` is how you
  say *stop taking commands from anywhere but me*. The assistant is told its turn is over rather
  than left waiting for a result.

<a id="a-run-that-fails-now-says-so"></a>
### 2.14 A command from an assistant reports the error it died on

**Fixed 2026-10-13.** A line the assistant asked to have run comes back with BR's error number, 0
for success. An **untrapped run-time error** did not reach that report: `RUN` of a program that
stopped on a divide by zero answered **0**, and told the assistant its program had worked. The
same was true of an immediate statement - `LET X=1/0` reported success.

Errors raised in the command processor itself were always reported, which is why this was not
obvious: `LOAD` of a file that does not exist has always come back 4152.

**An error the program handles is not the command failing** and still reports 0. `ON ERROR` and a
trailing `ERROR`/`NOKEY`/`EOF` clause are the program coping, which is not the same as the command
going wrong, and only what actually stopped the program is reported.

**But coping is not the same as having done the job**, and a program can now say which. `STOP n`
with a non-zero `n` sets `CODE`, as it always has; what is new is that the assistant is told. The
result's **message** carries `the program stopped with CODE <n>`, and the person sees `[AI] <- the
program stopped with CODE <n>` on the console. The number stays BR's error code: a return code is
a different fact from an error, and putting 3 where an error number goes would send a reader to
BR's error table for something that is not there.

```
00160    STOP 3                      ! handled the error; did not do the work
```

A **bare `STOP` sets 0**, so a program that ended normally reports nothing extra.

<a id="code-is-cleared-by-load-chain-and-clear"></a>
### 2.15 `CODE` is cleared by `LOAD`, `CHAIN` and `CLEAR`

**Changed 2026-10-13.** `CODE` is the return code a program set with `STOP n` or `END n`. `CLEAR`
has always zeroed it; `LOAD` and `CHAIN` now do too, so `CODE` cannot be read stale from a program
that ran before the one now loaded.

**`RUN` deliberately does not**, which is worth knowing rather than discovering: re-running an
already-loaded program leaves the previous run's code standing until that run sets one. For a
program ending in a bare `STOP` that is immediately, so it only shows for a program that ends some
other way.

A **`LIBRARY` load does not clear it either**, and that is also deliberate: a library loads while a
program is running, and clearing `CODE` under a program about to read it would lose the value
rather than make it trustworthy.

**`CODE` has never been set by a procedure.** Reference material described it as "the return value
of the most recent procedure, set by `EXIT n`". There is no `EXIT` command in BR - `EXIT` is the
loop statement `EXIT DO`/`EXIT FOR` - and a procedure line reading `EXIT 3` raises **error 1000**,
*unidentified source remaining*, leaving `CODE` at 0. Measured, and the reference corrected.

<a id="a-restricted-sessions-log-is-named-for-its-wsid"></a>
### 2.16 A restricted session's log is named for its WSID

**Changed 2026-10-08.** Every restricted session now writes an audit log called
**`restricted-<wsid>.log`**, and nothing outside BR chooses that name. A caller may choose only the
**folder**, with `--restricted-log=<folder>`.

**That argument took `<level>[U],<file>` before, and all three parts are gone.** The name is BR's,
as above. The level is BR's and is 8, because a caller able to lower it could ask for an audit
trail with the interesting part left out — the same objection that keeps `LOGGING` out of a
restricted configuration. And `U`, which told the session it was unattended, was never a log
setting: it rode along on this argument because this argument was already being passed.
`SPAWN_RESTRICTED` passes the directory of its own log and nothing else.

**`UNATTENDED` in a `LOGGING` statement now works in a restricted session**, which is what
replaces `U`. It had been swept up in the refusal of `LOGGING` as a whole: `UNATTENDED` is parsed
inside that statement, so refusing the statement left a restricted session with no way to be told
there was nobody at the keyboard. The statement reaches its handler now, and the handler keeps only
`UNATTENDED` — the log file, the log level, `DEBUG_LOG_LEVEL=` and `+CONSOLE` are dropped and the
session records that it kept its own log.

**From the configuration file only.** `CONFIG LOGGING` as a command in a running restricted program
is still refused with error 4154, as it always was: a program that could reach `LOGGING` would be
changing where its own audit trail goes while the thing being audited is happening.

**Everything a restricted session refuses in its configuration file is in its audit log**, and
until now none of it was. The log is named for the WSID, so it opens after the configuration has
been read — and the refusals, which are what an audit log is for, had already happened. They are
held and written in as the log opens, each marked `Before this log opened:`.

**A folder BR cannot write the log in is now fatal**, where the old form fell back to no log at
all. A caller that passes `--restricted-log=` has asked for this session's audit trail to be kept
somewhere, and a contained session running with no record of what it refused is worth refusing to
start for. BR's own default folder stays quiet if it is missing, because BR chose it and the
restriction holds either way — the latch in memory is what enforces it, not the log.

With no folder given, the file goes where a flag-restricted session's log has always gone: the
account's own local application directory, beside the AI-user-mode flag. The name was
`restricted-<pid>.log` there until now, which was unique but told a reader nothing.

The WSID is what an operator already knows a session by — it is `WSID$`, it is `[WSID]`, it is on
the status line — so a folder of these reads as a folder of sessions. Two sessions from one
workstation share a WSID and differ only in their session id, so **both append to the one file**;
nothing is lost by that, because every log line already carries `Wsid: <wsid><session>` in its
header and the two stay separable line by line. Measured: ten spawned sessions in one
`restricted-01.log`, stamped `012` through `018`.

**A session that fails before its WSID is assigned leaves no audit log**, because the name does not
exist until then — the configuration has to be read first, and the latch has to precede the
configuration. Such a failure is still reported the way any startup failure is. In exchange the log
records what it is a log of: its first entry names the WSID and says whether the session was
restricted because an assistant is connected or because it was started as a disposable one.

<a id="a-program-can-tell-an-assistant-something-directly"></a>
### 2.17 A program can tell an assistant something directly

```
LET X=MSG("notify", "report ready: t41list.txt")
```

sends the text to an assistant connected to the user-level channel, instead of leaving it to
notice something on the screen. An assistant waiting on the channel is woken by it.

The text is information, never an instruction: an assistant treats what a program says as data,
the same way it treats what it reads on the screen. `MSG("notify")` is allowed in a restricted
session — saying something is not doing something, and a restricted session is the one that most
needs to be able to report what it found.

This is part of a wider change: the channel now **pushes** what happens — a program waiting for
input, the screen settling after a burst of output, a grant given or expired, keys delivered, the
channel closing — so an assistant waits to be told rather than asking over and over. Nothing is
sent to one that has not asked for it, and no message ever carries what was typed.

<a id="a-program-can-be-given-a-whole-text-in-one-go"></a>
### 2.18 A program can be given a whole text in one go

An assistant's only way into BR was the keyboard, under a grant, a character at a time. That is
right for an answer a field holds, because BR's own field checks are then what hold it to its type
and length. It is useless for a program — source arrived a line a second, with no line longer than
a field — and there was nowhere at all for an explanation of several paragraphs to go.

A program can now ask for one and be handed it whole:

```
LET ID$=STR$(INT(TIMER*100))
LET X=MSG("agentask", ID$, "CODE")          ! or "MESSAGE", or a field spec
LET X=MSG("notify", "QUESTION "&ID$&" report CODE")
...
LET X=MSG("agenttext", ID$, ST$)            ! "12 595 source", or "0 0 none"
LET X=MSG("agentline", ID$, L$)             ! the next line of it
```

`MSG("agentask")` declares a question and says what answers it; an empty third argument closes it.
`MSG("agenttext")` says how many lines and bytes are still to be read, and `MSG("agentline")`
gives the next line. All three are allowed in a restricted session: none of them writes a file,
runs a command, or puts input anywhere.

**The program's question is the whole of the permission.** The assistant may deliver a text only
while a question with that id is open, and may deliver *source* only when that question says it is
answered by code. A question can be opened only from inside the session, by a program — nothing
the assistant sends can open one — so no grant is needed and none is consulted. What authorises
the delivery is a question a program asked, on the side the assistant cannot reach.

**Nothing delivered appears anywhere until the program reads it.** BR holds it; the program takes
it a line at a time, when it chooses to. So a delivery cannot interrupt the person at the
terminal, and cannot put text on the screen of a program that never asked for any. Source read
this way goes to a file and is never run on the assistant's say-so — a person still approves it,
and it still runs in a restricted session.

Limits: 256 KB a text, 2048 characters a line, printable ASCII with tabs and line breaks. Every
delivery is logged with its length and line count, beside the grants, so "where did this program
come from" has an answer.

<a id="ai-a-conversation-at-the-console"></a>
### 2.19 `AI` - a conversation at the console

A new command. At the `READY` prompt, `AI` followed by what you want:

```
READY
AI list the customers with an overdue balance over 1000
  I'll write a short report program. It reads CUSTMAST and AR-DETAIL ...
  [AI] > LOAD "@:C:\BR\agent\overdue.brs",SOURCE
  [AI] > RUN
  ... the program's output ...
READY
```

The reply prints in your `HILITE` colour, so the assistant speaking is plainly not a program
printing. **Only lines the assistant asked to have run carry the `[AI] >` mark**, so you can always
tell which commands came from the assistant and which you typed yourself. Those lines are logged
as commands like any others, and obey every restricted-session rule.

They need an **open turn** rather than the keyboard grant: only you can open one, by typing `AI`.
Without a grant the turn runs in *permission mode*, where anything destructive stops and asks you
first - see [A turn without a grant asks before anything
destructive](#a-turn-without-a-grant-asks-before-anything-destructive).

`AI NEW` starts a fresh conversation. With no assistant attached the command says so at once -
error 4158, *no assistant is listening on this session's channel* - rather than making you wait.
While it waits, the terminal keeps repainting. A break key - Ctrl-A - **halts** the wait rather
than ending the turn: you land at `READY`, the turn is still open, and `GO` goes back into the
wait where it left off. `CLEAR PROC` is how a turn is ended on purpose.

**`AI` does not take a name away from you.** `AI=5` still assigns to a variable called `AI`,
because BR reads a command keyword only when the line ends or a space follows - the same reason
`AUTO=5` has always assigned while `AUTO` is a command. The one form that changes is `AI` followed
by a space, which was a syntax error before; as with every other command, `AI = 5` written with
spaces is read as the command.

The assistant itself runs outside BR, and answering an `AI` line is the one thing it does that
involves anything leaving this machine. Nothing is sent anywhere unless the tool holding the
conversation has been given an API key.

<a id="the-client-refuses-a-server-certificate-that-was-replaced-in-transit"></a>
### 2.20 The client refuses a server certificate that was replaced in transit

BRClient pins the server's certificate: it accepts Business Rules' own certificate and no other.
That check now runs during the connection's handshake, so a substituted certificate is refused at
once, on the first attempt, with an explanation.

**The usual cause is security software, not an attacker.** Antivirus products that scan encrypted
connections — Avast's Web Shield "HTTPS scanning" is one, and ESET, Kaspersky and Bitdefender have
the same feature — sit in the middle of the connection, even to `127.0.0.1`, and present a
certificate of their own. Such software can read everything that passes, so BR refuses it. The fix
is to exclude BRClient from that scanning, or turn the scanning off.

**What the user sees.** A larger error window that names the server and port, says who issued the
certificate that arrived (for example "Avast Web/Mail Shield Self-signed Root"), explains what
that means, and gives the full path of the program to exclude, which can be selected and copied.
The details pane and the server's log record the issuer and both certificates' fingerprints.

**What it replaces.** Before, the handshake failure was retried until the connect timeout, each
attempt counting against the address at `brlistener`. After three failures in a minute the listener
blocks an address for five minutes and stops logging it, so the user saw a "connecting" window
flicker for minutes and then a timeout, and the listener's log said nothing. When the message did
reach the user it was a generic "no shared cipher" text that was wrong for this case.

<a id="new-error-codes-for-ai-and-restricted-sessions"></a>
### 2.21 New error codes for AI and restricted sessions

Seventeen error codes are new in 5.0, all in the 41xx range. None of them exists in 4.3, so a
program written against 4.3 can meet any of them for the first time here - which matters if it
traps by number.

| Code | Name | Raised when |
|---|---|---|
| 4153 | `BRERESTRICTEDOPEN` | A restricted session tried to change a file it did not create - the create-then-own rule, applied per file where the file is touched |
| 4154 | `BRERESTRICTEDCOMMAND` | A restricted session used a command that is not on its permit list; also `DLL(`, a refused `MSG` action, and `SYSTEM` with an operating-system command |
| 4155 | `BRENOSPARESESSION` | No session was free on this WSID to start a restricted one |
| 4156 | `BRESPAWNLOCALONLY` | A restricted session was asked for from something other than a local Windows session |
| 4157 | `BRESPAWNTIMEOUT` | The restricted session overran its time and was ended |
| 4158 | `BRENOAGENT` | `AI` was used with no assistant listening. Raised at once, so the command does not wait out its timeout for a reply that cannot come |
| 4161 | `BREHARNESSLOCKED` | The assistant channel was closed after repeated bad handshakes. A program's next input returns this, by the route an ATTN break travels, so it can be trapped |
| 4162 | `BREHARNESSFOREIGN` | A process belonging to another Windows user reached for the channel |
| 4163 | `BREHARNESSUNCLAIMED` | Nobody connected to the channel within its time window, and it closed itself |
| 4164 | `BREHARNESSNOTDEVELOP` | `MSG("harness", <port>, "DEVELOP")` in a session that may not change to DEVELOP mode |
| 4165 | `BRERESTRICTEDLIST` | A restricted session asked for a file `brrestrict.sys` does not permit |
| **4166** | `BREGRANTNOTRAISED` | A line the assistant sent ran `MSG("grant", n)` with any `n` but 0. See [An assistant cannot extend its own grant](#an-assistant-cannot-extend-its-own-grant) |
| **4167** | `BREAINOTPERMITTED` | In permission mode, the operator answered `N` - or there was nobody to ask, in `UNATTENDED`. See [A turn asks you before anything destructive](#a-turn-without-a-grant-asks-before-anything-destructive) |
| 4168 | `BREAIOPERATIONREFUSED` | The session reached for the operating system while an assistant was attached - `SYSTEM` with a command, a spool command, a gated `CONFIG` operation, or `Ctrl-]`. Refused to you as well as to the assistant |
| **4169** | `BREAITURNNOTPERMITTED` | `AI` was used while a program or a procedure was active and `ENV$("AI_TURN_OK")` was not `"Y"`. See [A turn needs the consent of whatever is running](#a-turn-needs-the-consent-of-whatever-is-running) |
| **4170** | `BREAITURNFLAGNOTSET` | A line the assistant sent tried to set `AI_TURN_OK`. Same entry |
| **4171** | `BREAITURNNOTYOURS` | A line the assistant sent used the `AI` command. Same entry |

The four in bold are the most recent: 4167 was added 2026-10-09, and 4169, 4170 and 4171 on
2026-10-13.
**4168 was missing from this table** until then, although it has had its own section all along -
and it is the one code here that is refused to the person as well as to the assistant, which makes
it exactly the one somebody would come to this table to look up.

One nearby code is **not** an AI restriction and is easy to mistake for one: **4151**,
`BREFREEREADONLY`, *CLOSE DROP or FREE requires the file to be opened for output*. It is also new
in 5.0 and has its own entry under [Behaviour
changes](#close-free-and-close-drop-now-require-a-file-opened-for-output). 4159 is deprecated and
4160 is unrelated.

There is **no 61xx range** in BR's error table. 6201 and 6213-6231 are `lp`/`lpr` and Windows
print-dialog failures, and nothing lies between 4177 and 6201 - so a 61xx reported from an AI path
is a wrong number rather than a code listed somewhere else.

<a id="debugging-and-observation"></a>
## 3. Debugging and observation

<a id="watching-a-debugging-session-without-taking-it-over"></a>
### 3.1 Watching a debugging session without taking it over

BR allows one debugger at a time, and connecting to the debug socket takes that place. There was no
way to watch a session someone else was debugging.

`DEBUG OBSERVE` accepts an **observer**: a second connection that receives a copy of everything BR
sends the debugger and may say nothing back. It holds no part of the debugger's channel, cannot
issue a command, and the session is unaffected by whether it is there.

```
DEBUG OBSERVE                 ! port 9556, loopback
DEBUG OBSERVE 9556            ! the same, said explicitly
DEBUG OBSERVE OFF             ! detach the observer
```

Loopback only, like the channel it mirrors, and for the same reason: it is shown the same material,
so a rule that applied to one and not the other would simply be the way around the one it applied
to.

It is shown the same material as the debugger, so it authenticates the same way — the TLS and
token exchange described under Security, with the same `DEBUG AUTH` setting. An observer that
disconnects is noticed and dropped; nothing about the debugger's session changes when it does.

This is not multi-client debugging: an observer watches, and only the debugger drives.

<a id="a-log-of-what-appeared-on-the-screen"></a>
### 3.2 A log of what appeared on the screen

`DEBUG SCREENLOG <file>` writes a line for every screen write BR makes, and `DEBUG SCREENLOG OFF`
stops it. Each line carries the time to the millisecond, the window's file number, what kind of
write it was, the row and column, the length and the text.

It answers a question nothing else could. BR's log records commands but not output, and a screen
dump shows only what is on the screen at that instant — so anything that scrolled past between two
looks was simply gone. The tee keeps it.

```
DEBUG SCREENLOG context\logs\screen.txt
DEBUG SCREENLOG OFF
```

Because it shares the log's timestamps, the two files can be merged into a single account of a
session: the log says what was commanded, the tee says what appeared. It is off unless you turn it
on — a full-screen repaint is many writes, and this stream is far larger than the event log. It
records the character-cell screen, not a picture: text drawn by native controls is not in it.

<a id="console-history"></a>
### 3.3 Console history

The console now keeps what scrolls off the top of it. Previously the top line was overwritten and
nothing kept it, so anything that scrolled past between one look and the next was gone.

`CONSOLE HISTORY <lines>` sets how much is kept, defaulting to **1000** lines. `0` switches it
off. The figure is a budget rather than a count: lines are stored without their trailing blanks, so
a console printing short lines keeps considerably more than the figure names, and a screen using
many different colours in one line keeps fewer. At 80 columns the default costs about 96K of
memory.

The screen is also kept when something is about to paint over it rather than scroll it, which
would otherwise lose it without trace: `PRINT NEWPAGE`, and paging forward through a listing with PgDn, which redraws the screen instead of scrolling it.
Paging **back** with PgUp keeps nothing, because those lines are about to be shown again.

**Program lines are not kept.** When you list a program, BR already lets you arrow up and down over
the listing and edit a line in place, and a second kind of recall holding a read-only copy of the
same lines would be worse than none. So the lines a listing draws are left out of the history and
everything among them — the commands you typed between two pages, and their output — is kept. A
program loaded with `LOAD <file> SOURCE` *is* kept as it is echoed, because the listing recall does
not reach those; `PROC NOECHO` suppresses them in the usual way.

**What a prompt writes is kept when the program resumes.** At an ATTN, READY or ERROR prompt the
console is shared with the program that was put aside, and when you `GO` or `RUN` the program
paints its own screen over whatever the prompt left. Nothing scrolled that off, so it never reached
the history: the commands you typed, the output of `STATUS` and anything else printed there simply
vanished. BR now puts it into the history at that moment, so it is there to scroll back to. This
covers what was **written to the console** at the prompt, with the same exception as everywhere
else: lines drawn by `LIST` are not kept. The program's own screen, controls and the status line are
not part of it.

**To look at the history**, use any of:

- **Shift** and the mouse wheel over the console
- **Shift+Up** or **Shift+PgUp**
- **Up** or **PgUp** on their own, immediately after something has scrolled off the top

The last of those is deliberately only good for one keystroke. Straight after a line has scrolled
away, "up" can only mean "put that back"; a moment later the same key belongs to whatever else
wants it, so anything you type in between hands it back.

None of them interrupt the command line's own listing. While a program is loaded and BR is ready to
draw more of it, the plain arrows, PgUp, PgDn and the plain wheel all belong to that listing, and
only the Shift forms reach the history. A single `.` followed by an arrow switches the listing off
in the usual way, which hands the plain keys to the history.

**The status line says which you are in** — `READY`, `LIST` while BR is ready to draw more program
lines, or `HIST` while you are reading the history.

Once you are in the history, the arrows, PgUp, PgDn, Ctrl+Home, Ctrl+End, the wheel and the
scrollbar at the right-hand edge all move the view, and **none of them leave it** — including
scrolling all the way back down to the live screen, where the arrows still work and a further Down
does nothing at all rather than disturbing the screen. Drag over the text to select it and press
Ctrl+C, or right-click, to copy it; you can then return to the prompt and paste.

**This is also how to copy what is on the console now.** The console itself takes no selection -
outside the history the mouse belongs to the program - but the history view shows the live screen
too, under the lines that went before it. Press **Shift+Up** once and everything on the console is
there to select and copy, except its bottom row, the line you are typing on; for that, mark it with
Shift and the arrows and press Ctrl+C as in any field. Selecting needs the view moved back at least
that one line: scrolled all the way down, the live screen is the program's again.

**Any other key leaves the history**, and the key you typed goes to the live prompt, so there is no
mode to get stuck in. While you are reading, the screen does not repaint and the program's output
is still being kept: coming back shows all of it.

Shift is needed to start scrolling with the wheel because BR already gives the plain wheel to the
running program, and the arrows and paging keys are the listing's. Nothing a program sees changes
until you ask for the history.

An assistant connected to the user-level channel reads the same history with its `HISTORY`
request, and can see what you are looking at with `SCROLLVIEW` — **but only with `GUI ON`.** With
`GUI OFF` the application paints the console itself, so the history is not Console traffic but the
session's own past screens, complete with the contents of their fields. An assistant reads the
screen without needing permission to act, so with `GUI OFF` it is refused the history: `HISTORY`
answers an error and the rows `SCROLLVIEW` marks `HISTORY` come back blank. Your own use of the
history is unaffected in either mode — scroll, select and copy exactly as above.

<a id="the-debugger-can-now-interrupt-a-running-program"></a>
### 3.4 The debugger can now interrupt a running program

A debugger's break request was acknowledged and then had no effect until the program next waited
for input of its own. A program in a loop, or in a `SLEEP`, simply carried on.

The cause was that BR only collects a key from the client when it has been told one is waiting, and
the debugger's break did not tell it. It now does, so a break takes effect while the program is
running — which is what it was always for.

<a id="a-variable-watch-now-reports-the-value-not-just-the-name"></a>
### 3.5 A variable watch now reports the value, not just the name

`BREAK <variable>` stops the program when the variable changes. With a debugger attached, BR used
to send only the variable's **name** — the value was worked out and displayed only when no debugger
was attached, which is precisely when it is least needed.

BR now sends the value as well, in the same form the console shows: line, clause, variable,
subscript where it is an array, and the value it changed to. The existing notification is unchanged
and still sent, so a debugger that has not been updated behaves exactly as before. Each stop is
also written to the log.

<a id="a-step-now-tells-the-debugger-where-it-stopped"></a>
### 3.6 A step now tells the debugger where it stopped

When a program was stepped, the line went to the screen and the debugger was told only that a step
had happened, so it had to ask where execution was after every step. BR now sends the line and
clause of each step exactly as it does for a breakpoint — the existing line-break message, followed
by the usual input-mode message. A stop is reported once: a breakpoint that is also a step stop, and
a breakpoint the check used to report twice, now each send one position. A debugger that treated
every line-break message as a breakpoint hit will now also receive one per step; the input-mode
status that follows (step mode) and the absence of a breakpoint on that line tell them apart. See
`AI-Access-Protocol.md`, section 7.

<a id="recording-what-a-debugger-submits"></a>
### 3.7 Recording what a debugger submits

BR's log records commands as they are entered but not immediate statements such as `PRINT X` or
`LET X=0`, whoever enters them. `DEBUG LOG COMMANDS <file>` — present before 5.0 but little known —
records every line a debugger submits, statements included, and is now documented as the way to
keep a full record of what an attached debugger, human or assistant, did at the prompt. See
`AI-Access-Protocol.md` 7.6, *The `DEBUG` commands*.

<a id="the-log-now-carries-the-clause-and-the-source-line"></a>
### 3.8 The log now carries the clause and the source line

A log line used to identify a position by BR's line number alone:

```
Line:01210
```

It now gives the clause within that line, and the line of the source file the statement came from:

```
Line:01210:03 144
```

**Why the extra two.** A BR line number does not say which clause of a multi-clause line was
running, and it is not a position in the file anyone edits - line numbers are chosen rather than
counted, one statement can span several physical lines through the `!:` continuation, and a
precompiler may renumber entirely. The clause and the source line answer both.

**The source line is left out rather than shown as zero** when BR has none - a program saved
before 5.0, or saved with [`OPTION 60`](#option-60-save-in-the-42-43-object-format). An absent
field cannot be mistaken for line zero:

```
Line:01210:03
```

**A word follows it when the number is not one you can look up as it stands**, and nothing follows
it when it is:

| | Means |
|---|---|
| `Line:01210:03 144` | source line 144, and the file on disk has it there |
| `Line:01210:03 144 EDITED` | the program has been changed since it was loaded, so the file no longer matches - 144 is where the statement would be if it were written out now |
| `Line:01210:03 2 BASE` | no source text is kept (an object-only program), so the number is the **statement's** first line rather than the clause's; the clause number is still exact |

`BASE` is the one worth knowing about: for a continued statement it reports a different, earlier
line than `EXACT` would, and without the word there is nothing to say so.

Anything reading these logs by splitting on `Line:` still finds it in the same place. The
reference material is in `br/docs/LINES.md`.

<a id="clear-proc-stop-and-end-at-a-halt-in-a-library-reload-that-library"></a>
### 3.9 `CLEAR PROC`, `STOP` and `END` at a halt in a library reload that library

**Changed 2026-10-18.** An ATTN or an error halt inside a library leaves that library as the program
you are working in: `LIST` shows its lines and `PRINT` reads its variables. `CLEAR PROC`, `STOP` or
`END` then ended the run, and ending a run puts the workspace back to the **top level** program, so
the library you were looking at disappeared and had to be loaded again by hand.

BR now notes which program had control when you issued one of those three at a halt, and once the
stop is complete it **loads that program into the workspace**. It does this silently: nothing is
echoed and nothing is added to the command log. A program saved as source (`.brs`) is loaded as
source.

- **Only when a library had control.** If the top level program was the one halted, the workspace
  already goes back to it and nothing is loaded.
- **Only at a halt.** `STOP` or `END` run by a program, and a run that simply finishes, behave as
  before.
- **`CLEAR ALL` and `CLEAR` are not changed.** They still leave the workspace empty.
- **If the library cannot be loaded** (it was moved or deleted, say) BR reports the usual load
  error and carries on.

<a id="break-file-and-display-file-watch-opens-and-closes"></a>
### 3.10 `BREAK FILE` and `DISPLAY FILE` watch OPENs and CLOSEs

**Changed 2026-10-19.** Two new debugging commands report a file being opened or closed:

```
BREAK FILE name [OPEN | CLOSE]
DISPLAY FILE name [OPEN | CLOSE]
```

`name` is a case-insensitive piece of the file's full name as BR holds it - `ORDERS` matches
`M:\qsmrp\data\orders.dat`. Put it in quotes if it contains a blank. With neither `OPEN` nor `CLOSE`
the watch is for both.

- **`DISPLAY FILE`** says each match and carries on, in the form of a variable display:
  `line 00080:01, OPEN #1 M:\qsmrp\context\zzwatch.txt`. `DISPLAY FILE name PRINT` sends it to the
  printer.
- **`BREAK FILE`** stops the program after the statement that opened or closed the file, at the next
  line or clause, as a variable break stops after the statement that changed the variable.
- **Every open and close counts**: the `OPEN` and `CLOSE` statements, the opens BR makes for itself,
  and the closes at the end of a run. A file closed as the run ends is shown by `DISPLAY FILE` but
  does not stop a `BREAK FILE`, because there is no program left to stop.
- **`name OFF`** takes the watch away: `BREAK FILE orders OFF`. `BREAK FILE orders OPEN OFF` takes away
  only the OPEN half. `BREAK ALL OFF` and `DISPLAY ALL OFF` clear the file watches of their kind.
- **Watches are global**, not a program's: a file is opened from wherever the run happens to be, so
  they are listed by `STATUS BREAKPOINTS` under `File watches:` and last until removed.
- **No condition.** `IF`, `-p program` and a redirect are syntax errors on a file watch.

<a id="break-takes-an-if-condition"></a>
### 3.11 `BREAK` and `DISPLAY` take an `IF` condition

**Changed 2026-10-18.** A break can now carry a condition, so it stops only when the condition is
true:

```
BREAK IF cond              tested after every line of the program
BREAK variable IF cond     tested when the variable changes
BREAK line-ref IF cond     tested when the line is reached
BREAK IF OFF               removes the every-line condition
BREAK line-ref             turn condition test off
BREAK variable             turn condition test off
```

The condition is the rest of the command and can be any valid BR condition, including function
calls: `BREAK TOTAL IF FNOVERLIMIT(TOTAL)` or `BREAK 1200 IF FNNAME$ > NULL$`. A `-p program` option
goes before the `IF`. Giving a break a new `IF` replaces its condition, and giving it none makes it
unconditional again.

`DISPLAY variable IF cond` does the same for a display: the change is shown only when the condition
is true when the variable changes, and the run carries on either way - a display never halts the
program. It needs a variable: `DISPLAY ALL IF` and `DISPLAY IF` with nothing to watch are syntax
errors. An error evaluating the condition is the one thing that stops a display, so it is seen.

**How it is evaluated.** A condition can call functions, so it is evaluated by BR itself at the
break, the way `EXECUTE` runs a statement: the break halts as any break does, BR evaluates
`LET BRKIF_RESULT=(condition)` without echoing it, and then either stays at the halt or carries on
with a `GO`. When the condition is false nothing is displayed: a variable break's report of what
changed, and the line shown at a halt, are held back until the condition is known. No break is
checked while a condition is being evaluated.

- **The condition is evaluated in the program that is running when the break is reached.**
- **It is checked when you enter it.** A name the program does not have - a mistyped variable or
  function - is an error, as it would be under `DIMONLY`, and so is a condition that does not
  compile: the command is refused and the break or display it made is taken away. The check
  compiles the condition and never runs it, so none of your functions are called by it. The
  same rule applies each time the condition is evaluated, in case the program has been edited since.
- **An error evaluating it stops the run** and shows the error - a division by zero, or a function
  that fails.
- **`BREAK IF` is slow.** It costs a round trip through the command processor after every line. A
  break on a line or a variable is tested far less often.
- **A numeric variable named `BRKIF_RESULT` is created** in the program the condition is evaluated
  in. It will appear in `DISPLAY ALL` and in a listing of the program's variables.
- **`STATUS BREAKPOINTS` shows the conditions**, for example `BREAK LINE 01200:01 IF X>5`,
  `BREAK VARIABLE TOTAL IF TOTAL>100`, `BREAK IF X>5` and `DISPLAY VARIABLE TOTAL IF TOTAL>100`,
  and persistent break points remember them, so a program loaded later has them applied.

<a id="break-and-display-on-a-parameter-watch-the-variable-it-stands-for"></a>
### 3.12 `BREAK` and `DISPLAY` on a parameter watch the variable it stands for

**Changed 2026-10-18.** A parameter passed by reference is another name for the caller's
variable. `BREAK x` and `DISPLAY x` used to watch the *name* `x` in the program they were typed in, so
the watch stopped meaning anything once the function returned, and did not fire when the value was
changed through any other name. When `x` is currently a parameter given by reference, BR now puts
the watch on the variable it stands for. With `a` passed in as `x`, `BREAK x` means `BREAK a`:

```
BREAK P                      (P is V in the caller)
line 00150:01, V, value = 2
```

- **It is the original that is watched, in its own program, under its own name.** The watch is
  listed by `STATUS BREAKPOINTS` as `BREAK VARIABLE V`, reported as `V`, removed by `BREAK V OFF` or
  `BREAK P OFF`, and recorded as `V` among the persistent break points.
- **It keeps working after the function returns**, and fires when the variable is changed from the
  caller, from a deeper call or from a library. Watches put on a variable this way are checked from
  whichever program is running; every other watch is still tied to its own program.
- **However many calls deep**, and across libraries, the original is found the same way `STATUS STACKS`
  finds it - see [`STATUS STACKS` shows what a function's parameters really are](#status-stacks-shows-what-a-functions-parameters-really-are).
- **A parameter bound to an array element** (`FNA(X(3))`) is watched as that element, `X(3)`.
- **Not redirected:** a parameter passed by value, which has no caller variable behind it, and one
  bound to a slice such as `X(2:4)`, which is only some of an array's elements. Those are watched by
  their own name as before.

<a id="status-shows-the-source-line"></a>
### 3.13 `STATUS` shows the source line

**Changed 2026-10-18.** `STATUS` and `STATUS STACKS` gave a position as a BR line number and a
clause, as the log used to. They now add the line of the source file, as the log
[already does](#the-log-now-carries-the-clause-and-the-source-line), after the clause:

```
Current Line=59008:03 3863
 current  line 59008:03 3863, program M:\qsmrp\oap\ordera.br in function FNSELECT
called by line 39318:02 1204, program M:\qsmrp\oap\ordera.br in function FNM
called by line 07200:01 88, program M:\qsmrp\oap\ordera.br
```

It is on the `Current Line` row of `STATUS`, on the current line of `STATUS STACKS` and on every
`called by` row. A call into a library shows the line in the library's own source, since each row is
worked out from its own program.

**It is the clause's line, not just the statement's.** One statement can span several physical lines
with `!:`, and a clause on the third of them is on that line. A plain `:` between clauses does not
start a new line. BR works this out from the one statement's stored source, so nothing is listed and
the whole program is never loaded: a program saved with its source and loaded from the `.br` file
has its source read from the file one statement at a time, only when `STATUS` asks. The status line
at the bottom of the window now does the same, so its number is exact for such a program too
rather than the statement's first line.

**The number is left off when BR has none:**

| | Shows |
|---|---|
| A program saved by 5.0, or loaded from source | the clause's line |
| A program saved by an earlier BR, or with [`OPTION 60`](#option-60-save-in-the-42-43-object-format) | no number - the object keeps no source lines |
| A program saved as object only | the **statement's** first line, which is the clause's line for a statement on one physical line |
| A program edited since it was loaded | the line it would have if written out now, so the file no longer matches |

Unlike the log, `STATUS` does not follow the number with `EDITED` or `BASE`. The log is read by
tools that need to know how far to trust the number; `STATUS` is read by a person at the console. A
program that shows no number here was saved without one: save it again with 5.0, without `OPTION
60`.

<a id="status-stacks-shows-what-a-functions-parameters-really-are"></a>
### 3.14 `STATUS STACKS` shows what a function's parameters really are

**Changed 2026-10-18.** A variable passed to a function by reference is renamed inside it, and the
variable it was passed from may itself be a parameter of the function that called it, many calls
deep. Finding the original used to mean reading back through the program. `STATUS STACKS` now says,
ahead of the stack list, for the function the program is in:

```
Passed by reference: MYVAR -> X, VAR3$ -> Y$, D -> C
 current  line 00090:01 10, program M:\qsmrp\oap\ordera.br in function FNB
```

Each parameter given by reference is shown with the **original** variable, however many levels it
was handed down, and across calls into library programs. Only the current function is listed, and
the line is left out when it has no by-reference parameters or the program is not in a function.

- **An array element or a slice is named with its subscripts**, as the program writes it: `X(3)`,
  `M(2,3)`, `A$(2)` or `X(2:4)`. The subscripts follow `OPTION BASE`.
- **A scalar given to an array parameter** is shown as the scalar: `MAT P5 -> S`.
- **A parameter that was passed by value, or an argument that is an expression**, is not listed.
  There is no caller variable behind it. When a function passes one of its own by-value parameters
  on by reference, the original is that parameter: `D -> C` above.
- **A long list wraps** to continue on indented lines.

The line is part of the output of `STATUS STACKS` only. It is not written to the log.

<a id="status-dims-lengths"></a>
### 3.15 `STATUS DIMS LENGTHS` shows how long strings really got

```
STATUS DIMS LENGTHS [ n ] [ > file | > A$ ]
```

lists each string variable that is dimensioned to **n bytes or more**, or has held a string of
**n bytes or more**; `n` is 100 if it is not given. `LENGTHS` can be shortened to any part of it, such
as `LEN` or `L`. For each variable there is one line:

```
A$ DIM: 18  USED: 142
LINES$() DIM: 10  USED: 118
```

- **`DIM`** is the element length the program dimensioned, which is 18 for a string with no `DIM`.
- **`USED`** is the longest string the variable has held. An array is one line, for the longest of
  its elements, and its name is followed by `()`.
- **Use it to size `DIM` statements.** A `DIM` that is much larger than `USED` can be smaller; a
  `DIM` that is smaller than `USED` has grown at run time (see
  [`SOFLOW-GROW`](#soflow-grow-a-string-can-grow-instead-of-overflowing)) and would overflow without it.
  A program with nothing at or over `n` prints one line saying so.
- **It runs while a program is running,** from `EXECUTE` or at a halt. It reads the variables and
  changes nothing. The older `STATUS DIMS`, which reports duplicate, unreferenced and undimmed
  variables, is unchanged.
- **`>` takes an array.** `STATUS DIMS LENGTHS >R$` puts the lines in `R$`, as for any command that
  redirects (see [`>` can send output into an array](#redirection-into-an-array)). The standard
  `STATUS` header is not printed before the lines.

**What `USED` means.** BR now clears the memory a string variable lives in when it is allocated.
Shortening a string changes only its length, so the bytes after it keep what was stored, and the last
byte that is not zero shows how long the longest string was. The number is kept when something would
lose it: `MAT REDIM` to fewer elements, and the restart that frees a variable that grew or was
redimensioned. It is **the longest string held since the variable's memory was allocated**, so it
carries over from one `RUN` to the next, and it starts again from nothing after `CLEAR`.

- A string that ends in null characters shows as shorter than it was.
- A string padded with blanks counts its blanks.

<a id="printing-and-fonts"></a>
## 4. Printing and fonts

Numerous changes have been made concerning PDF printing, including smart stretching of proportional
fonts for proper vertical placement and better `FONTFAMILY` handling.

Two reference documents cover the detail, and are the place to look when output does not land where
it used to:

- **[`FONT_SELECTION.md`](FONT_SELECTION.md) — which face a print request resolves to.** The
  priority order (a face name beats a family, a family beats nothing, and a later selection by
  number takes the face back), the number-to-face map, and the **`FONTFAMILY`** configuration
  statement, which pins the faces BR uses. `FONTFAMILY` matters on Windows in particular: ten of the
  twenty-one entries in the built-in map name LaserJet ROM typefaces that do not exist as Windows
  fonts, so without it the system font mapper chooses them and output can move between releases.
  `STATUS FONTS` reports what resolved.
- **[`FONT_MEASUREMENT.md`](FONT_MEASUREMENT.md) — how the chosen face is then sized and placed.**
  Units by domain, how the em is derived from the pitch, how a run is scaled to fill the cells it
  occupies, and the controls that change this: **`OPTION 68`**, which leaves proportional text
  unscaled, and **`\Estretch='off'`**, which does the same for a single span.

If a report's layout changed after upgrading, read `FONT_SELECTION.md` first to confirm which face
is being chosen, then `FONT_MEASUREMENT.md` for how it is being sized.

<a id="fixes"></a>
## 5. Fixes

<a id="list-clause-counted-on-gosub-as-two-clauses"></a>
### 5.1 `LIST ... CLAUSE` counted `ON ... GOSUB` as two clauses

**Fixed 2026-10-18.** `LIST <line> CLAUSE` marks where each clause of a line begins with a backtick.
For `ON x GOSUB a,b` and `ON x GOTO a,b` it marked two - one before `ON` and one before `GOSUB` or
`GOTO` - although BR runs the statement as one clause and reports it as one in a clause number such
as `99106:06`. Every clause after an `ON` on the line was therefore numbered one higher in the
listing than in the stack, so a clause number from `STATUS STACKS` or an error pointed at the wrong
tick, and the source line worked out from it for a continued statement was a line too early for each
`ON` before it.

```
00100    `on 0 gosub L1 !:
         `on X gosub L1,L2 !:
         `print "after"
```

The listing now marks an `ON` statement once, so the ticks agree with the clause numbers BR reports.
The other forms are unchanged: `IF ... THEN ... ELSE` is still marked as separate clauses, and
`ON ERROR GOTO` and `ON ATTN GOSUB` are marked once.

<a id="screen-chains-on-a-library-releasenofiles-return"></a>
### 5.2 Screen chains on a `LIBRARY RELEASE,NOFILES` return

Returning from a library with `LIBRARY RELEASE,NOFILES` clears that library's screen chain while it
is still the current one — the only situation in which that happens. Two faults followed, both now
fixed:

- **A deleted menu left attached to the menu bar.** Every screen chain's menu frame shares the
  frame's single menu bar. Releasing the chain deleted its menus outright, which is correct only
  once they have been swapped out of that bar — true for any chain except the current one. The bar
  kept a deleted menu, and the caller then picked it up as its blank menu and faulted while removing
  it. The menus are now swapped out first, exactly as switching away from the chain would have done.
- **Work continuing on a freed screen chain.** After the release the server still sends messages for
  that chain, and only afterwards the screen switch back to the caller. Deleting the chain
  immediately left all of that running on freed memory — harmless by luck in a Release build, but an
  access violation on every such return in a Debug build, where the heap overwrites what it frees.
  The chain is now unlinked but kept alive until the switch retires it.

Programs that use `LIBRARY RELEASE,NOFILES` with screen I/O were the ones affected.

<a id="dll-calls-no-longer-wait-100-ms-each"></a>
### 5.3 `DLL()` calls no longer wait 100 ms each

Every `DLL(...)` call took at least a tenth of a second, however little the DLL did: BR waited for
the call in 100 ms steps and did not notice it had finished until the step was over. A call that
returned at once was measured at 109 ms. BR now resumes as soon as the call returns — under a
millisecond for the same call — while a long-running DLL call keeps the screen responsive exactly as
before. Programs that make many `DLL` calls in a loop will run noticeably faster. `MSG(...)` was
never affected.

<a id="protect-no-longer-repeats-forever-when-it-fails-on-windows"></a>
### 5.4 `PROTECT` no longer repeats forever when it fails on Windows

On Windows, if `PROTECT <file>,READ` or `PROTECT <file>,WRITE` could not change the file's
attributes — for example on a file the user had no permission to change — BR ran the command again,
and again, without end, and the session had to be ended. The error is now reported like any other
failed command. Other platforms were not affected.

<a id="comment-lines-in-brconfig-sys-no-longer-hold-the-splash-screen"></a>
### 5.5 Comment lines in `brconfig.sys` no longer hold the splash screen

The splash screen waits for the first session on a workstation, and for any session whose startup
produced configuration messages; sessions 2 to 9 otherwise start at once. Since comment-only lines
in `brconfig.sys` began to be shown on the splash screen earlier in 5.0, each one counted as a
configuration message, so every session using a configuration file with a comment line waited the
full time. Comments are still shown, but no longer hold the splash screen; a real configuration
error still does.

That wait is also now 2 seconds rather than 20 — see
[The splash screen now waits 2 seconds, not 20](#the-splash-screen-now-waits-2-seconds-not-20).

<a id="msg-state-now-checks-its-argument-count"></a>
### 5.6 `MSG("state")` now checks its argument count

The check was written so that it could never be true - it asked whether the count was both below
three and above four - so `MSG("state")` accepted any number of arguments and then read two of
them regardless. Called with fewer, it read past the end of the arguments BR had prepared. It now
accepts three or four, which is what it always documented and what its own body expects.

<a id="the-client-no-longer-stops-with-bad-action-10129-while-connecting"></a>
### 5.7 The client no longer stops with "Bad action 10129" while connecting

If Windows reported an error BR has no name for while BRClient was still connecting, the client
tried to pass it to a server it had not yet agreed a protocol version with, failed an internal
check, showed "brassertion (Bad action 10129 …" and exited. The error is now kept and written to
the server's log once the connection is up, and the connection carries on.

<a id="most-of-the-status-line-was-blank"></a>
### 5.8 Most of the status line was blank

**Fixed 2026-10-03.** On the graphical status line, five of the eight fields displayed nothing -
the run state, the line number, the program name, the serial number and the row and column. The
message and the error code were unaffected, which is what made it look intermittent rather than
systematic.

Nothing was wrong with the data: every field was being given the right text, in the right colours,
in a correctly positioned control. The field **widths** were the problem. They were written as
literal pixel counts - about ten pixels per character - against the small font that wxWidgets 2.6
gave the status bar through BR 4.3. wxWidgets 3.1, which BR 5.0 uses, supplies a considerably
larger one, and a text control that cannot fit its text in Windows draws **nothing at all** rather
than clipping it. Only the two fields with room to spare still appeared.

Each field is now measured in the font actually in use, against the longest value it can hold, and
is remeasured if the screen size changes. A value that still will not fit is now shown with an
ellipsis rather than vanishing.

<a id="debug-builds"></a>
## 6. Debug builds

<a id="memory-leak-reporting-at-exit"></a>
### 6.1 Memory leak reporting at exit

Debug builds ask the CRT debug heap to report what is still allocated when the process exits, and
capture that report to a file instead of losing it to a debugger's output window — so a leak seen on
another machine can be sent in.

**Where to find it.** Each module has its own debug heap and its own report file, written to the
local application-data folder — on Windows, `%LOCALAPPDATA%\ADS\`:

```
BRServer-heap.log
BRClient-heap.log
```

Each run appends, with a timestamped header line naming the module, so a file can hold several runs.
The report also goes to the debugger's output window when one is attached.

The report is **not** written to the log named in your `LOGGING` configuration statement. That log is
closed during shutdown, before the heap report is produced, which is why these files exist.

Exits taken from mid-stack do not produce a report: the fatal exits and a client-initiated close
leave functions on the stack that never return to free what they hold, so a dump taken there lists
in-flight memory as leaks and cannot tell a real leak from one of those.

Because the report is written during shutdown, a message box cannot safely be raised at the time.
The client instead leaves a marker and tells you on the *next* run that the previous run ended with
a heap report.

This affects Debug builds only; Release builds are unchanged.

<a id="the-harness-channels-ring-statistics-are-now-debug-only"></a>
### 6.2 The harness channel's ring statistics are now Debug-only

When a connection on the user-level channel closes, BR logged two lines at level 10: why it closed,
and a line of statistics about the queue it sends responses through — how many responses, how many
were held off-queue, how often the queue wrapped, the peak bytes in use. The second line is of use
only to BR's own authors, and level 10 is a level a site runs to see its own commands and files.

It is now logged at **level 11** and **only by a Debug build**, so a release binary no longer
produces it at any level. The line saying why a connection closed is unchanged: still level 10, and
still in every build.
