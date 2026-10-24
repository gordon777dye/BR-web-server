---
title: Profiler
file: Profiler.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: reference
related: [DEBUG PROFILE, profiler.exe, Profiler File Layout, Luis Gomez, Vertican]
corrections:
  - "Consolidated from 90-reference/error-codes/DEBUG_PROFILE.md (moved here and folded in; recorded
    pruned-2b in _migrate/MANIFEST.csv pointing at this file) and re-expanded from the one-paragraph
    summary this topic had been folded into at spec.md#diagnostics, which now links back to this
    page for the full capture/view workflow. Converted from MediaWiki syntax: `= Heading =`/`==
    Heading ==` converted to `#`/`##`, and `<pre>` blocks converted to fenced code blocks."
---
The **BR Profiler** captures a line-by-line or timed execution profile of a running program to a
log file, for troubleshooting performance. It's a separate tool (Luis Gomez / Vertican) distributed
from `/Dll_Distr/Profiler` on the FTP site, not a built-in BR command beyond the `DEBUG PROFILE`
statement that drives it.

<a id="generating"></a>
## Generating profiler output

```
DEBUG PROFILE SAMPLED <filename>
DEBUG PROFILE TIMED <filename>
DEBUG PROFILE STOP
```

`SAMPLED` and `TIMED` both start capture to `<filename>`; `TIMED` additionally records time spent
per line (see [Profiler_File_Layout](Profiler_File_Layout.md#time-spent-in-line)). `DEBUG PROFILE
STOP` ends capture.

<a id="viewing"></a>
## Viewing profiler output

Use **`profiler.exe`** (from the same FTP distribution) to render the captured log as readable
text:

```
profiler.exe <filename>
profiler.exe <filename> raw
```

<a id="file-format"></a>
## File format

The captured log is a binary sequence of variable-length, typed records (module mapping, current
line, time-in-line, backtrace, function name, GOSUB, main-routine, end-of-line markers), all
numbers in network byte order. Full byte-level layout:
[Profiler_File_Layout](Profiler_File_Layout.md).

<a id="see-also"></a>
## See also

- [Installation & tooling — Diagnostics & utilities](spec.md#diagnostics) — the folded category
  summary this page backs.
- [Profiler_File_Layout](Profiler_File_Layout.md) — the binary log record format in full detail.
- [Debugger](Debugger.md) — `DEBUG CONNECT`/`DEBUG CONSOLE OFF` and the rest of the `DEBUG` command
  family the profiler statements belong to.
- [70-commands/information](../../70-commands/information/spec.md) — BR's other built-in debugging
  commands (`BREAK`, `DISPLAY`, `RUN STEP`/`TRACE`).
