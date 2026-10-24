---
title: Debugger
file: Debugger.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: reference
related: [BR32.exe, MyEdit BR, DEBUG CONNECT, DEBUG PROFILE, third-party editor, breakpoints, BR32.exe Debug]
corrections:
  - "Consolidated from nine separate pages that lived under 90-reference/error-codes/ — Debugger.md,
    DEBUG.md, Debug_Connect.md, Debugging_Statements.md, Debugging_Errors.md, BR32.exe_Debug.md,
    Begin.md, STEP_mode.md and ERROR_mode.md — and moved here, since this is about the debugger
    *tool* (installation/tooling), not an error code; each original is recorded pruned-2b in
    _migrate/MANIFEST.csv pointing at this file. Four of the nine (Begin.md, STEP_mode.md,
    ERROR_mode.md, Debugging_Statements.md) turned out to contain no fact not already stated more
    completely elsewhere — BREAK's BEGIN clause and PAUSE are in
    70-commands/information/spec.md#break and 10-language/flow-control/other-flow/spec.md, and every
    execution mode (READY/RUN/ERROR/ATTN/PAUSE/STEP/…) is tabulated in
    10-language/flow-control/error-handling/spec.md#modes — so their wording was dropped rather than
    restated, per instruction, and only a see-also link kept."
  - "One fact recovered from br_tree/90-reference/error-codes/Chapter_6.md (a BR Tutorial chapter,
    left in place — it is pedagogical, not reference material, and everything else it says about
    STEP/TRACE/BREAK/DISPLAY/LOGGING/LIST-search was already covered in the specs above) and not
    recorded anywhere else in this kit: as of BR 4.3, RUN STEP additionally displays each source
    statement immediately before executing it, not just the line-number field."
  - "Converted from MediaWiki syntax throughout: backtick-wrapped generic nouns un-linked to plain
    prose, the `;Term` definition-list syntax in Debugging_Statements.md dropped (redundant, see
    above), `===Syntax===` headers converted to `##` with anchors, and the external MyEditBR help
    link converted to a Markdown link."
---
A **debugger** is a third-party tool that attaches to a running BR session over a TCP connection
(via [`DEBUG CONNECT`](#debug-connect)) to add breakpoints, watches, and step-execution on top of
BR's own built-in [`BREAK`/`DISPLAY`/`RUN STEP`](../../70-commands/information/spec.md#break)
facilities. **MyEditBR** was the first editor built with one — see
[MyEdit_(BR_Edition)](MyEdit_(BR_Edition).md) — via its "Debug BR Program" tool
(`DebugBR.cmd`), which needs a matching `brnative.exe` in the application folder.

This page also covers the separate **debug build of BR32.exe itself** (used by BRC beta testers,
see [Debug builds of BR32.exe](#debug-build)) — a different sense of "debug" from the debugger tool
above: one is an external program attaching to a normal BR session, the other is a special build of
BR meant for finding bugs *in BR*.

<a id="debug-connect"></a>
## The DEBUG CONNECT command

`DEBUG CONNECT` opens a TCP connection on a specific port and starts listening for commands from an
attached editor/debugger. Once connected, the BR console is disabled and made non-visible; commands
received from the debugger over that connection are treated exactly as if typed at the standard BR
console.

```
DEBUG CONNECT [LOCALHOST | <ip-address>]
```

```
debug connect localhost
debug connect 127.0.0.1
debug connect
```

<a id="debug-family"></a>
## The DEBUG command family

Beyond `DEBUG CONNECT`, the `DEBUG` statement covers a small family of debugging-related commands:

- **`DEBUG CONSOLE OFF`** — supported as of BR **4.18a**.
- **`DEBUG PROFILE SAMPLED|TIMED <filename>`** / **`DEBUG PROFILE STOP`** — captures a line/timing
  profile to a log file; see [Profiler](Profiler.md) for the full workflow and
  [Profiler_File_Layout](Profiler_File_Layout.md) for the binary log format.

Other than the `DEBUG` family itself, the
[`GO`](../../70-commands/program-management/spec.md#go) command (resume/step a halted program) is
one of the most useful general-purpose debugging tools in BR — see
[program-management](../../70-commands/program-management/spec.md#go) and
[information](../../70-commands/information/spec.md#break) for the full `BREAK`/`DISPLAY`/`RUN
STEP`/`GO` set.

<a id="run-step-43"></a>
### RUN STEP source-line display (4.3+)

As of BR **4.3**, stepping through a program with `RUN STEP` (or `GO STEP`) additionally displays
each program source statement immediately before executing it, not just the next-line-number field
in the status line. Earlier releases show only the line number.

<a id="debug-build"></a>
## Debug builds of BR32.exe

A **Debug build of BR32.exe** is a separate, enhanced build used by beta testers and Business Rules
developers — not something end users run. It creates crash dumps and FTPs these error reports to
BRC. As of BR **4.3**, debug builds expect a [`LOGGING`](../config-directives/spec.md#behavior)
configuration statement to be present, so BR can post exit messages during unexpected terminations.

This is distinct from the **Native Release** end-user build — see
[Native_Release](../../90-reference/error-codes/Native_Release.md) — and from the interactive
debugger tool described above.

<a id="error-codes"></a>
## Debugger-related error codes

Introduced in BR **4.18a** (`Support for the DEBUG CONSOLE OFF command` shipped in the same
release — see
[90-reference/limits-constants/4.18a](../../90-reference/limits-constants/4.18a.md)):

| Code | Meaning |
|---|---|
| [0420](../../90-reference/error-codes/0420.md) | Operation not permitted with debugger attached — disconnect the debugger before performing this operation |
| [0422](../../90-reference/error-codes/0422.md) | Unknown host name |
| [0424](../../90-reference/error-codes/0424.md) | `DEBUG CONNECT` issued but no debugger enabled — enable the debugger before using `DEBUG CONNECT` |
| [0426](../../90-reference/error-codes/0426.md) | Bad debugging port defined |
| [0428](../../90-reference/error-codes/0428.md) | Debugging accept failed |
| [0430](../../90-reference/error-codes/0430.md) | Not processing input command mode |
| [0432](../../90-reference/error-codes/0432.md) | The given clause number is invalid |

<a id="see-also"></a>
## See also

- [Installation & tooling — Diagnostics & utilities](spec.md#diagnostics) — the folded category
  summary this page backs, including the Profiler catalog entry.
- [70-commands/information](../../70-commands/information/spec.md#break) — `BREAK`, `DISPLAY`,
  `RUN STEP`/`TRACE`, `STATUS BREAK` — BR's own built-in debugging tools.
- [70-commands/program-management](../../70-commands/program-management/spec.md#go) — `GO
  [STEP|TRACE] [.line]` resume/temporary-breakpoint forms.
- [10-language/flow-control/error-handling — Execution modes](../../10-language/flow-control/error-handling/spec.md#modes) —
  the full READY/RUN/ERROR/ATTN/PAUSE/STEP/… status-line mode table.
- [10-language/flow-control/other-flow](../../10-language/flow-control/other-flow/spec.md) —
  the `PAUSE` statement.
- [Profiler](Profiler.md) — `DEBUG PROFILE` capture and `profiler.exe` viewing workflow.
- [MyEdit_(BR_Edition)](MyEdit_(BR_Edition).md) — the editor with the first built-in BR debugger.
- [90-reference/error-codes/Native_Release](../../90-reference/error-codes/Native_Release.md) —
  the end-user build, as distinct from a debug build of BR32.exe.
- [90-reference/error-codes/Chapter_6](../../90-reference/error-codes/Chapter_6.md) — the BR
  Tutorial chapter this page's RUN STEP 4.3 note was recovered from (left in place; pedagogical,
  not reference material).
