---
alwaysApply: true
---

# BR Launch

## BR launch environment

AI models need to know how to invoke Business Rules for compilation and testing. The executable and
all three config files are fixed, kit-relative paths — nothing here is machine-specific.
`brconfig.ai_util`/`brconfig.ai_user` are generated from `brconfig.sys` by ONBOARDING.md STEP 1, 
never hand-edited.

| Fact | Value | Nature |
|---|---|---|
| **BR executable** | `$BR_EXE` | Ships with the kit — BR 5.0 x64 Release, in `tools/` |
| **`br_mcp_driver.exe`** | `$BR_MCP_DRIVER` | Ships with the kit — launches a live BR 5.0 session for the harness ([below](#harness-launch)) |
| **`brconfig.sys`** | `$BR_CONFIG` | Existing app startup config |
| **`brconfig.ai_util`** | `$BR_AI_UTIL` | AI Utility — headless (`UNATTENDED`) |
| **`brconfig.ai_user`** | `$BR_AI_USER` | AI User — interactive, for testing user interfaces |
| **`brls.exe`** | `$BRLS_EXE` | Standalone syntax pre-check (optional semantic pass via `-check -sema`) — does **not** invoke BR (§6.1) |
| **Kit folder** | `$BR_CONTEXT_KIT` | This kit's `context/` folder, absolute. The harness reads it ([below](#harness-launch)) |
| **App root** | `$APP_ROOT` | The folder holding `context/`, absolute |

**Onboarding sets all eight for you.** STEP 1 of
[`app/ONBOARDING.md`](../app/ONBOARDING.md) writes two scripts:

- **`context\app\env.cmd`** sets the variables with absolute paths, built from the script's own
  location. In cmd, `call` it once. From PowerShell or Bash, run it in the **same command** as the
  program that needs the variables, because they disappear when that cmd process ends:
  ```
  cmd /c "context\app\env.cmd && context\dev\ai_access\br_mcp_driver.exe start"
  ```
  This works because the program reads the variables itself. Don't write `%BR_EXE%` in that line:
  cmd expands it when it reads the line, before `env.cmd` has run, so it comes out empty. Use
  `cmd /v:on /c "context\app\env.cmd && !BR_EXE! …"` instead.
- **`context\app\onboarding\setx.cmd`** saves the same values in the user's Windows profile with
  `setx`, so every program started afterwards has them. Onboarding runs it once, unless the user
  says the kit will be used in more than one repo on this machine: the values apply to every
  program the user runs, so a second kit would pick up the first one's. Only programs started
  later see the values, so close every VS Code window and start it again. Re-run it if the kit moves; to remove a
  value, `reg delete HKCU\Environment /v <NAME> /f`.

The snippets below set the same variables for one shell session. Run them from the app root.

```powershell
$env:BR_CONTEXT_KIT = (Resolve-Path "context").Path
$env:APP_ROOT       = (Get-Location).Path
$env:BR_EXE        = "context\dev\tools\brserver-x64-Release.exe"
$env:BR_MCP_DRIVER = "context\dev\ai_access\br_mcp_driver.exe"
$env:BR_CONFIG     = "context\dev\tools\brconfig.sys"
$env:BR_AI_UTIL    = "context\dev\tools\brconfig.ai_util"
$env:BR_AI_USER    = "context\dev\tools\brconfig.ai_user"
$env:BRLS_EXE      = "context\dev\tools\brls.exe"
```

```bash
export BR_CONTEXT_KIT="$PWD/context"
export APP_ROOT="$PWD"
export BR_EXE="context/dev/tools/brserver-x64-Release.exe"
export BR_MCP_DRIVER="context/dev/ai_access/br_mcp_driver.exe"
export BR_CONFIG="context/dev/tools/brconfig.sys"
export BR_AI_UTIL="context/dev/tools/brconfig.ai_util"
export BR_AI_USER="context/dev/tools/brconfig.ai_user"
export BRLS_EXE="context/dev/tools/brls.exe"
```

**`$BR_EXE` is BR 5.0, and with it exported it is also the BR the harness runs.** BR itself
lives in [`tools/`](tools/) beside the config files; the driver and `brls.exe` live in
[`ai_access/`](ai_access/). Run directly, as
every invocation in this file does, it is an ordinary BR: it runs a program and leaves you its
output, and opens no harness channel. To attach to a **live** session and watch a screen, start
it through `$BR_MCP_DRIVER` instead — see [Live sessions](#harness-launch) below, then
[`BR_harness.md`](BR_harness.md).

*Measured, 2026-10-18:* `"$BR_EXE" "PROC <proc>" -"$BR_AI_UTIL"` ran a proc headlessly and
exited 0, and `LOAD … source` / `SAVE` compiled a program.

<a id="option-60"></a>
> **`OPTION 60` is ON in `$BR_AI_UTIL` and `$BR_AI_USER`, because they run BR 5.0, so what they
> save loads in BR 4.3.** BR 5.0 loads all three object formats, but by default it saves its own
> (level 39), which a pre-5.0 BR refuses with **error 2240, "release level error"**. Under 5.0,
> `OPTION 60` saves the 4.3 format (level 38) instead
> ([SAVE / REPLACE](../br_tree/70-commands/program-management/spec.md)). *Measured:* without it,
> a program `SAVE`d by `$BR_EXE` failed to `LOAD` in 4.33c with 2240; with it, the same program
> loaded. **The option means something else in BR 4.3**: there it saves the legacy
> 4.18-and-earlier format. So it stays **OFF in `$BR_CONFIG`** while production is 4.3, and the
> AI configs belong with `$BR_EXE` only. Don't `SAVE` through them with the 4.33c executable
> still in `context\dev\tools\`.

**All paths above, and every invocation in this file and in §6.1, are run from the kit root**
(the directory containing `context/`). Run from there, or resolve these paths against it first.
`brls.exe` takes no config file and needs none of `$BR_CONFIG`/
`$BR_AI_UTIL`/`$BR_AI_USER` — it never launches BR.

<a id="start-folder"></a>
### Two starting folders: where you launch BR, and where BR starts

A BR run involves two folders, and they are not always the same one:

| Path | Resolved against |
|---|---|
| The executable, the `-<config-file>` argument, and the config's `LOGGING` file | the **OS folder BR is launched from** — the kit root |
| Every path handed **to BR**: the startup command (`"PROC …"`, `"RUN …"`, `"LOAD …"`), the lines of a proc, and the names a program opens | **BR's start folder**: the first `DRIVE`'s 2nd parameter plus its 4th (`DRIVE M:,C:\ads,,\app` starts in `C:\ads\app`) — see [br_tree — DRIVE](../br_tree/00-configuration/config-directives/spec.md#paths) |

When the two are the same folder, which is the usual install, a kit path such as
`context\scratch\x.prc` works in both places. When they differ, give BR the kit file's path from
BR's start folder. ONBOARDING STEP 1 records that prefix at the end of the AI Model Rules in
`context/README.md`. For example, if the kit is installed in `y:\wb\ar1` but the first `DRIVE`
starts BR in `y:\wb`, launch from `y:\wb\ar1` with `"PROC ar1\context\scratch\x.prc"`.
Keep `LOGGING context\app\startlog.txt` unprefixed, because it resolves against the launch folder.

Don't `CD` to the kit root instead. Production BR starts in the same folder (the AI configs keep
`brconfig.sys`'s `DRIVE` lines), so any file name an app program gives relative to it would stop
resolving.

Confirmed on the kit's 4.33c executable, launched from the kit root each time (probe:
`context/scratch/startdir/`): with BR starting one folder above the kit root, the kit-relative
`"PROC context\…"` failed with error 4203 ("path does not exist"), and `"PROC <folder>\context\…"`
ran. With BR starting one folder below it, only the path from that folder ran. In every case the
`LOGGING` file was written under the launch folder.

## AI Canonical invocations

Copy these verbatim.

```
"$BR_EXE" -"$BR_CONFIG"                           # start BR into the app (interactive)
"$BR_EXE" "RUN glp\trial_bal" -"$BR_AI_UTIL"       # run a program, headless
"$BR_EXE" "RUN cnp\menu" -"$BR_AI_USER"            # run a statement/command, interactive
"$BR_EXE" "PROC cnp\batch.prc" -"$BR_AI_UTIL"      # run a procedure, headless
"$BR_MCP_DRIVER" start                            # live session with the harness (see below)
```

- **`-<config-file>`** names a config file — a dash **immediately followed** by the
  path/filename (e.g. `-"$BR_CONFIG"`), no space. With none given, BR looks for `brconfig.sys`, then
  `wbconfig.sys`.
- The **first quoted argument** is a BR statement/command to run the instant BR starts 
  (e.g. `"RUN cnp\menu"`, `"PROC start"`). 
- Syntax reference: [br_tree — Startup command line](../br_tree/00-configuration/platform/spec.md).

---

## Development commands

### Compile / syntax-check
Sources compile `.br.brs` → `.br` on modification. To force a compile-check of one source:

```
"$BR_EXE" "LOAD program.brs source" -"$BR_AI_UTIL"   # parses; reports first error + line
```

The **`source`** keyword is required to load a `.brs` as source — `LOAD` defaults to object mode and
will not infer source from the extension ([LOAD](../br_tree/70-commands/program-management/spec.md#loading)).

### Run a program with console input
```
"$BR_EXE" "RUN cop\xlate850" -"$BR_AI_USER"
```

### Run a program with proc-fed input

Use this to run an interactive program headlessly. The program's `INPUT`/`LINPUT`/`RINPUT`
statements read the lines of a procedure file instead of the keyboard, and `PROCIN` returns 1.
Put the program and its answers in a proc, then start BR with `PROC` on that file:

```
! tmp\run_it.prc
RUN custom\myprog PROC
first answer
second answer
SYSTEM
```

```
"$BR_EXE" "PROC tmp\run_it.prc" -"$BR_AI_UTIL"
```

- **`PROC` is an option of `RUN` here, not a file name.** `LOAD custom\myprog` followed by
  `RUN PROC` is equivalent.
- **These spellings fail** (confirmed on the kit's 4.33c executable):
  - `"RUN custom\myprog PROC"` as the startup argument → error 2103, because no procedure is
    running yet.
  - `RUN PROC tmp\x.prc` → error 2104, because nothing is loaded and `tmp\x.prc` is never read
    as a name.
  - A plain `RUN custom\myprog` inside the proc → `PROCIN` stays 0, and the run aborts at the
    first input statement.
- **One proc line is read per input statement.** Lines after the last one the program reads run
  as commands once it ends, so finish with `SYSTEM`.
- **The `RUN` line must not be the proc's last line.**
- Full rules: [`br_tree` — RUN … PROC](../br_tree/70-commands/program-management/spec.md#run-proc).

---

<a id="harness-launch"></a>
## Live sessions: launching BR with the harness

Everything above runs a program and leaves you its output. To **watch** a program while it
runs (its screen, its fields, its listviews, a picture of its window), start the session through
the BR MCP driver instead. What you can do once it is up is in [`BR_harness.md`](BR_harness.md).
This section is only how to bring it up.

### The files the harness uses

Two folders, and nothing on `PATH` and nothing in the registry. **BR is not in `ai_access/`**:
since 2026-10-21 it is deployed to [`tools/`](tools/), and the driver finds it only through a
variable or a flag (below).

| File | Folder | What needs it | Kept current by |
|---|---|---|---|
| `br_mcp_driver.exe` (`$BR_MCP_DRIVER`) | `ai_access/` | you — it is the launcher and the MCP server | `br/mcpdriver/build.ps1` |
| `brls.exe` | `ai_access/` | the `check_source` tool, which the driver finds beside itself | the brls tree's own `build.ps1` |
| `brserver-x64-Release.exe` (`$BR_EXE`) | `tools/` | the driver, through `--br`, `$BRSERVER` or `$BR_EXE` | `br/winbuild/dllbuild/bld.ps1` |
| `brclientdll501-x64-Release-gui.dll` | `tools/` | BR, which loads it from its own directory | the same, with the server |
| `brclient-x64-Release.exe` | `tools/` | a person starting a client by hand | the same, with the server |

**Each is deployed by whatever builds it, on every build**, with an up-to-date check so that
costs nothing and a warning rather than a failure when the folder is not on the machine.
Nothing is hand-copied, and that is deliberate: every one of these has gone silently stale at
least once, and a stale one does not announce itself ([`BR_harness.md` §1](BR_harness.md#setup)).

**Only an x64 Release build updates `tools/`** — a full build, or
`bld.ps1 -Recompile -Configuration Release`. The everyday Debug `-Recompile` leaves it as it is,
so a change you have only built in Debug is not yet in the BR the kit runs.

**The driver needs to be told where BR is.** It resolves BR as `--br`, then `$BRSERVER`, then
`$BR_EXE`, then a file called exactly `brserver.exe` beside itself, then `PATH`. The first
variable that is set decides, even when what it names is missing. No `brserver.exe` ships beside
the driver any more, so with no flag and neither variable set, `start` refuses with
`brserver.exe was not found`. Exporting `$BR_EXE` as above is enough.

**The three BR files are a matched set.** The DLL keeps its versioned name because BR builds the
name it looks for from **compile-time constants** (release, platform, configuration, display)
and prefixes its own directory; the server's filename plays no part. A new server beside an old
DLL is a mismatch BR cannot report usefully, so `bld.ps1` copies all three whenever any one is
out of date, and deletes a `brclientdll*-x64-Release-gui.dll` left behind by an earlier version
string.

**Running `$BR_EXE` directly gives you no harness.** It is the same executable, but the
channel is opened only by the procedure the driver starts BR on (below), so a session started by
any invocation earlier in this file has no channel to attach to.

**The driver also reads `$BR_CONTEXT_KIT`**, which `env.cmd` and `setx.cmd` set. Without it the
driver uses `C:\ADS\qsmrp\context`, the default compiled into it, so it matters wherever the kit
is anywhere else. It is how `get_reference` and `get_layout` answer at all. *Measured: with the kit found, `guide` comes back carrying the
catalogue (49 reference topics and every data-dictionary file name), and
`get_reference print-fields` returns this kit's own `PRINT FIELDS` section.*

Two variables choose what runs: **`$BRSERVER`** (or `$BR_EXE`) names the BR, and **`$BRLS`**
names a checker other than the `brls.exe` beside the driver. Both are read by the process that
runs `start`, and only that one. The MCP shim ([below](#harness-mcp)) holds no credential, no
connection and no state.

### The procedure has to sit in BR's start folder

This is the one that will cost you an hour, and it does not announce itself when it goes wrong.

The launcher starts BR with the command `proc BR_dev.prc`: **no path, and you cannot change
it**. BR resolves it against **BR's start folder**, not the folder you launched from
([above](#start-folder)).

So **`BR_dev.prc` must be in BR's start folder.** For this application the first `DRIVE` is
`DRIVE m:,c:\ads,xxx,\qsmrp`, so that folder is `C:\ADS\qsmrp`, the application root.

```
copy context\dev\ai_access\prc\BR_dev.prc   <BR's start folder>
copy context\dev\ai_access\prc\BR_user.prc  <BR's start folder>
```

*Measured both ways.* Without it:

```
BR started from ...brserver-x64-Debug.exe (pid 6664) on BR_dev.prc; waiting for the channel
br_mcp_driver start: BR is running (pid 6664) but BR_dev.prc published no channel within 30s
```

With it:

```
harness claimed on port 8720, protocol 5
serving \\.\pipe\br_mcp_driver.Gordon.requests and .replies, holding the harness on port 8720
```

`BR_report.prc` is different and needs no copying: the `run_report` tool writes it and its
loader into the directory it is told to run in.

### The configuration file

`--config` is resolved against the **launch** folder, not BR's start folder, so a kit-relative
name works. **`$BR_AI_USER`** is the right one to start with: interactive, logging to
`context\app\startlog.txt`, `OPTION 60` on ([above](#option-60)), and otherwise this
application's own settings. *Measured: a session on it opens the channel and answers every
reading request.*

**`start` uses `$BR_AI_USER` when you give it no `--config`**, so with the variables above
exported the flag is optional. *Measured, 2026-10-18:* `start` with no flags printed
`configuration from BR_AI_USER: context\dev\tools\brconfig.ai_user` and BR wrote
`context\app\startlog.txt`, which is that file's `LOGGING` destination and not the default
one's.

**Omit it with the variable unset and nothing tells you.** BR takes no configuration from the
command line, hunts `brconfig.sys` beside the executable and then in the launch folder, and
comes up on whichever it meets first — a session with different `DRIVE` mappings and no
`LOGGING`, which looks like a working session right until something reaches for a file. Note
that the first place it looks is beside BR, which is now **`tools/`** — and `tools/` holds
`brconfig.sys`, the application's own startup configuration. So what you get is that file,
with its `EXECUTE` lines (which start the application) and none of the AI configs' changes.

Three config keywords change what you can see, and they are the session's, not yours:

| Keyword | Effect on you |
|---|---|
| `GUI ON` / `GUI OFF` | which tool reads the program's screen ([`BR_harness.md` §0, §5](BR_harness.md#the-one-thing)) |
| `OPTION 82 ON` | parks BR's windows off the display area, so a session of yours does not take the screen from whoever is using the machine. **Reading and picturing still work.** *Measured: `shot ... COMPOSED` succeeded on a window parked at x=2019, outside the desktop* |
| `LOGGING <n>, <file>` | where BR's own diagnostics go, for when a program dies and the screen does not say why |

**Do not flip an application's `GUI` setting to make it easier to read.** The two modes are not
display preferences: under `GUI ON`, `PRINT` to the screen and `LINPUT` are *not allowed*, so a
program written for `GUI OFF` stops working
([br_tree](../br_tree/20-io-screen/windows-cursor/spec.md#gui-console)).

### Starting the session

```
"$BR_MCP_DRIVER" start [--user] [--config FILE] [--br PATH] [--port N] [--wait DURATION]
```

For example, from the kit root — with the variables at the top of this file exported, this is
the whole command:

```
"$BR_MCP_DRIVER" start
```

**The flag beats the variable, which beats the fallback.** For each of the two:

| | `--config` | `--br` |
|---|---|---|
| 1. the flag, if given | the file it names | the BR it names |
| 2. else the variable | `$BR_AI_USER` | `$BRSERVER`, else `$BR_EXE` |
| 3. else | BR's own `brconfig.sys` hunt — see the warning above | `brserver.exe` beside the driver (none ships there now), else `PATH` |

*Measured, 2026-10-18:* with `$BR_EXE`, `$BRSERVER` and `$BR_AI_USER` all pointed at files
that do not exist, `start --br <real> --config <real>` came up and claimed the channel — the
flags are consulted first, not merely preferred. **Whichever step answers, what it names is
checked before BR is launched**, so a misspelling is a refusal naming the flag or the variable
rather than a session quietly running on the wrong configuration.

It is worth confirming the two lines `start` prints before `harness claimed`, because they say
which BR and which configuration it actually got:

```
configuration from BR_AI_USER: context\dev\tools\brconfig.ai_user
BR started from context\dev\tools\brserver-x64-Release.exe (pid 26860) on BR_dev.prc; waiting for the channel
harness claimed on port 8720, protocol 5
```

It launches BR on a standard procedure, claims the channel that procedure opens, and then
*becomes the service* that fronts it.

| Command | Procedure | Session | Grant |
|---|---|---|---|
| `start` | `BR_dev.prc` | **`DEVELOP` mode** | none given |
| `start --user` | `BR_user.prc` | user mode | the keyboard, for an hour |

**`DEVELOP` mode is what you want for development work**, and it is chosen by the procedure's
third argument to `MSG("harness", <port>, "DEVELOP")`. **Nothing outside BR can set it**, not
a flag here and not a tool. It buys two things:

- **you may type at the `READY` prompt.** In user mode keys go in only while a program is
  waiting for input, so a command typed at `READY` sits in the queue instead of running.
  In a development session the `READY` prompt is where the work is.
- **it does not raise the AI-user-mode flag**, so a BR session started from this one comes up
  unrestricted and can write the application's own files. A user-mode session raises it, and
  every session started while it is up is restricted to files it created itself.

What `start` does **not** do: set `DEVELOP` mode (above), and give a grant. `BR_dev.prc`
deliberately gives none, because a development session usually wants an assistant that reads.
To let it type, somebody at the session types `LET X=MSG("grant",600)`.

`--config` names the configuration **file** in full: BR reads the text after the dash as that
name, so `--config mine` asks for a file called `mine`.

**BR's own output does not come back to the shell.** `brserver.exe` is a GUI-subsystem binary
with no console: its screen goes to its own window and its diagnostics to the `LOGGING` file.
What appears in the shell is the launcher's own three lines.

To end it: close BR, or from inside the session `LET X=MSG("harness",0)`.

<a id="harness-mcp"></a>
### The MCP server entry

For Claude Code, in the MCP configuration:

```json
{
  "mcpServers": {
    "br": { "command": "<full path to br_mcp_driver.exe>", "args": ["connect"] }
  }
}
```

`connect` is a relay onto a pipe pair the running service holds. It can be restarted any number
of times at no cost, which is the whole reason the arrangement is split in two: the harness
token is spent at the first handshake, so a process that claimed the channel itself would get
**one** attempt.

With the service up and the client connected, go to
[`BR_harness.md` §3](BR_harness.md#attaching).

---

## The Lexi preprocessor

Some BR shops write source for **Lexi**, a preprocessor that adds a handful of constructs base BR
doesn't have (`/* ... */` comments, `X$&=` compound append, `#Select#/#Case#`, `#Autonumber#`,
`#Define#`, and line-number-free editing) and rewrites them into plain, correctly line-numbered BR
text before real BR ever compiles it. 

- **Lexi's syntax** (what each construct does): [`essentials.md`](essentials.md#1-core-language-rules).
- **The full reference** — what Lexi is, both known distributions, how the VS Code extension
  invokes it, and every directive in detail:
  [`br_tree` — Lexi](../br_tree/00-configuration/installation-tooling/Lexi.md).
- **How this fits into the actual coding loop**:
  [`APP-DEV-GUIDE.md`](APP-DEV-GUIDE.md#lexi-aware-coding-loop).

### Running `lexi-compile.ps1`

[`dev/tools/lexi-compile.ps1`](tools/lexi-compile.ps1) translates (and optionally compiles) a
Lexi-authored `.brs` file headlessly — no editor or VS Code window involved — running under
`UNATTENDED` logging so a bad input aborts fast instead of hanging the shell.

```powershell
# Translate only (default) — produces <source>.lexiout.brs next to the source
context\dev\tools\lexi-compile.ps1 -Source path\to\file.brs

# Translate AND compile to a real .br object
context\dev\tools\lexi-compile.ps1 -Source path\to\file.brs -Compile

# Explicit output paths
context\dev\tools\lexi-compile.ps1 -Source path\to\file.brs -OutFile path\to\translated.brs -Compile -OutObject path\to\file.br
```

| Parameter | Default | Meaning |
|---|---|---|
| `-Source` | *(required)* | The `.brs` file to translate. |
| `-OutFile` | `<Source>.lexiout.brs` | Where the translated, plain-BR output goes. |
| `-Compile` | off (switch) | Also compile the translated output to a `.br` object (`LOAD`/`SAVE` or `REPLACE`, whichever applies), via the same bundled runtime. |
| `-OutObject` | `<Source>` with its extension replaced by `.br` | Where the compiled `.br` goes, when `-Compile` is given. |
| `-LexiPath` | auto-detected under `$env:USERPROFILE\.vscode\extensions\crs-dev.vslang-br-*\Lexi` | The Lexi install folder (`lexi.brs`, `lexionly.brs`, `linenum.brs`, `brnative.exe`, `wbconfig.sys`). Pass explicitly if that extension isn't installed, or to compile through a different Lexi install. |
| `-BrExe` | `<LexiPath>\brnative.exe` | The BR executable to run Lexi with. |
| `-WbConfig` | `<LexiPath>\wbconfig.sys` | The config to run Lexi with (Lexi's own — separate from this app's `brconfig.sys`). |
| `-KeepTemp` | off (switch) | Keep the generated proc/config/log temp files afterward — useful for debugging a failure. |
| `-TimeoutSec` | `30` | Kill the BR process if it hasn't exited after this many seconds. A safety net only — unattended mode should abort on its own well before this. |

See `Get-Help -Full dev\tools\lexi-compile.ps1` for the complete parameter help and examples.

---

## Deploy notes

- Deploy = copy compiled `.br` and `.brs` into the app tree; no further build required.
- ScreenIO event-code changes require recompiling the **screen**, not just the program.

