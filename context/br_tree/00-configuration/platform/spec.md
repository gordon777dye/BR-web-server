---
title: Platforms & executables
file: spec.md
source: §Client Server (platform setup), §Language Overview; br_tree BR32.EXE / Executable_version / Backward_Compatibility / OS stubs folded in & pruned (2b)
category: 00-configuration
subcategory: 00-configuration/platform
kind: spec
status: 2b           # reference base + br_tree enrichment
recovered-fold: Getting_Started (folded+pruned — WBSERVER.DAT/error 4175, spool RAW gotcha, SYSTEM exit/Ctrl-A; verbatim retained on the BR wiki)
related: [config-directives, client-server, installation-tooling]
keywords: [platform, executable, WSID, startup, brnative]
corrections:
  - "OPTION 60 in the backward-compatibility list no longer says it saves in 4.18 format. BR no longer writes that format at all; the option now selects the 4.2/4.3 object format (save level 38), which omits the source line positions level 39 records. From BR 5.0 source: config.cpp case 60, brexe.cpp processNewSaveFile. See the SAVE / REPLACE section of 70-commands/program-management."
---

# Platforms & executables

The operating systems and executables BR runs on, how a session is launched, and the portability
story. BR's promise is that the **same program runs identically across platforms** — platform
differences live here in configuration, not in code.

<a id="executables"></a>
## Executables

`BR<version>.exe` is the start-up command for non-client-server installations; over time it has also
 been named/aliased **`BRNative.exe`**, `BR.exe`, `WB.exe`, `WB32.exe`, `BRServer.exe`. The server side 
 is `brserver`/`brlistener`; the client is `BRClient.exe`. You may **rename the executable** to anything
(handy for keeping multiple versions side by side, e.g. `BR41.exe`, `BR390k.exe`) and launch by that
name. On Unix/Linux the command must be lowercase **`br`**; on Windows `BR` may be either case.
Windows DLLs live under `C:\Windows\System32` (and `SysWOW64` on 64-bit Windows).
On 64‑bit Windows:
  System32 = 64‑bit system files
  SysWOW64 = 32‑bit system files
The above 2 lines are non-intuitive but correct.

<a id="startup"></a>
## Startup command line

```bnf
{br|BR}[.exe] ["<statement-or-command>"] [ -<wsid>[+[<incr>]] ] [ -<config-file> ] [ @<login_name> ]
```
The command is run from the host OS, so it is OS-dependent: on Unix/Linux it **must** be lowercase
`br`; on Windows `BR` may be either case. The parameters (in any order after the keyword):

- **`"<statement-or-command>"`** — a complete BR statement or command, executed the instant BR
  starts. Quotes aren't required but are strongly recommended. E.g. `BR32.exe "RUN MENU"` or
  `BR32.exe "PROC START" -21 -ALT6.SYS`.
- **`-<wsid>`** — the workstation ID: a dash followed by the ID (documented as one-or-two digits
  `01`–`99`, though the same page also says "up to three digits" — preserved as written). If omitted,
  BR assigns a default (**`01`** single-user, the hardware-dependent ID on Unix/Linux, sign-on order
  on Windows). A trailing **`+`** tells BR to **auto-increment** when the requested ID is already in
  use: `+<incr>` sets the step (a whole number `0`–`999`, default `1`), and BR keeps adding the
  increment until it finds a free ID. **Without `+`, a busy ID is an error.**
- **`-<config-file>`** — a dash + optional path + filename naming an alternate `BRConfig.sys` (which
  customizes drives and the many configurable BR/application options). With no file given BR looks
  for `BRConfig.sys`, then `WBConfig.sys`. **All versions except single-user Windows require a config
  file containing a `DRIVE` specification, or start-up fails.**
- **`@<login_name>`** — the login the session runs as (used by per-user `@"login"` config lines).

The executable itself may be **renamed** to anything (see [Executables](#executables)) and launched
by that name.

<a id="cross-platform"></a>
## Cross-platform differences (config, not code)

- **Filename case** — Unix/Linux/Mac are case-sensitive, DOS/Windows insensitive; tune with
  [`FILENAMES … SEARCH`](../config-directives/spec.md#paths) (program filenames are lowercased on
  Unix unless overridden).
- **End-of-line** — `EOL=LF` (Unix) vs `EOL=CRLF` (DOS/Windows) on display files.
- **Paths/drives** — abstract physical paths behind logical [`DRIVE`](../config-directives/spec.md#paths)
  mappings; a Windows client can drive a Linux/Mac server and vice-versa
  ([client-server](../client-server/spec.md)). SCO OpenServer is also supported.

<a id="wbserver-exit"></a>
## Workstation tracking & exit
- **`WBSERVER.DAT`** (located via the `BRSERVER`/`WBSERVER` BRConfig.sys statement, else the first
  `DRIVE`) tracks workstation IDs and **must be the *same* file for every workstation** sharing data —
  two stations using *different* `WBSERVER.DAT`s and opening the same file raise **error 4175**.
- **Windows spooling gotcha**: a client printing to a local printer must set the printer's Spool Data
  Format to **RAW** (the default EMF drops BR's pass-through data), or bypass the spooler with
  `SUBSTITUTE PRN:/10 LPT1:`.
- **Exit**: the only proper way to leave BR is the **`SYSTEM`** command (returns to the OS; `SYSTEM
  <exe>` shells out and returns); in READY mode you may also just close the main window. Interrupt a
  program/procedure with **Ctrl-A** (`CLEAR PROC ONLY` ends an interrupted procedure, `GO` resumes it).

<a id="security"></a>
## Security settings

  - `OPTION 70 ON` — high security (the default in locked-down deployments).
  - `OPTION 70 OFF` — no restriction.
  - `OPTION 70 RELAXED` — mild security: disables `COPY`/`DIR`/`CONFIG` commands and edits to BR
    programs, allowing some debugging. *Defeatable* — those actions can still run from programs/procs,
    so use `ON` for real security.

The separate **BR-as-webserver** model (serving HTML to browsers) is
[60-integration/web](../../60-integration/web/spec.md).

<a id="compat"></a>
## Backward compatibility

Newer BR (4.1+) checks syntax more strictly, so programs that ran on older releases may break.
BRC provides a set of legacy [`OPTION <nn>`](../config-directives/spec.md#behavior) toggles you add
to `BRConfig.sys` to relax the new checks (e.g. `OPTION 29` save as `.WB`, `OPTION 41` ignore GUI
statements in non-GUI mode, `OPTION 47` allow `PRINTER=` in OPEN, `OPTION 60` save in the 4.2/4.3
object format (it no longer writes the 4.18 one),
plus `FieldBreak Min_Spaces`, `CONFIG GUI OFF`). The full annotated upgrade list is in
[Backward_Compatibility](Backward_Compatibility.md).

<a id="version"></a>
## Version / licence mismatch

At launch, *"executable version ### does not match license version ###"* (version numbers with
periods removed, e.g. 420 vs 490) means `brserial.dat` is older than the executable and must be
updated ([installation-tooling](../installation-tooling/spec.md) → `CheckSerial.exe`).

<a id="see-also"></a>
## See also

- [client-server](../client-server/spec.md) — Windows/Linux/Mac server deployment
- [config-directives](../config-directives/spec.md#behavior) — `DRIVE`, `FILENAMES`, `INCLUDE`, `OPTION <nn>` for portability/compat
- [installation-tooling](../installation-tooling/spec.md) — installers, DLLs, runtimes per OS
- [60-integration/web](../../60-integration/web/spec.md) — serving HTML from BR (the BR-as-webserver model)
- Backing keyword page (deep detail retained): [Backward_Compatibility](Backward_Compatibility.md)