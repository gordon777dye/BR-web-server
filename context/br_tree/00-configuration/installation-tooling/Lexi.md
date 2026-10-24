---
title: Lexi
file: Lexi.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: reference
related: [BR, third party editor, MyEdit, BR Programs, line numbers, brserial.dat, fnApplyLexi, fnUndoLexi, BR Language Server, crs-dev.vslang-br, lexi-compile.ps1, RENUM]
corrections:
  - "Added the underlying mechanism this page never described: Lexi is itself a BR **library
    program** (`lexi.br`/`lexi.brs`), exposing `fnApplyLexi(InFile$, OutFile$, Mode,
    SourceMapFile$)` and `fnUndoLexi(InFile$, OutFile$)` — confirmed by reading the bundled
    library source directly, not inferred. Added a second real, confirmed distribution beyond the
    classic SageAX/MyEdit zip: the \"BR Language Server\" VS Code extension (`crs-dev.vslang-br`)
    bundles the identical engine under its own `Lexi/` folder and runs it automatically on save;
    its invocation mechanism (temp-file copy, a generated proc that types `Infile$`/`Outfile$` as
    new numbered lines into the loaded driver program, then `run`/`save`/`replace`) was
    reverse-engineered from the extension's own bundled `dist/extension.js` and the translation
    step re-verified by actually running it outside VS Code. Added two real Lexi conversions this
    page never documented at all — `/* ... */` multi-line comments (→ `!` comments) and
    `X$&=\"...\"` compound append (→ the safe `X$(INF:0)=\"...\"` idiom, not naive
    self-concatenation) — confirmed by running the real `fnApplyLexi` engine against test input."
  - "Clarified the ambiguous ***SELECT CASE*** section (below, unchanged in substance from the
    original wikitext, whose code example already showed `#SELECT#`/`#CASE#`/`#End Select#`) —
    the heading and lead-in sentence read as if bare `SELECT CASE ... END SELECT` were valid
    syntax. It is not, in Lexi or in base BR: confirmed by running `fnApplyLexi` (both `Mode 0`
    and `Mode 1`) against a file containing bare `select case`/`case`/`end select` — Lexi left it
    completely untouched in both modes, and the untouched result then failed to `LOAD` in real BR.
    The `#` signs on `#Select#`/`#Case#`/`#End Select#` are required; the *feature* is informally
    called \"Select Case\" (matching this library's own header comment), but that is not its
    spelling. A downstream doc (this kit's `dev/essentials.md`) briefly repeated the bare-spelling
    reading before this was caught; see that file's `context/ERRORS.md` entry, 2026-09-11."
---
**Lexi**, the **BR! Lexical Preprocessor**, rewrites a handful of extra constructs — plus, in its
best-known feature, an entire program's **line numbers** — into plain, correctly line-numbered BR
text before real BR ever compiles it. It was originally built to integrate `BR` with a `third
party editor` (`MyEdit` first, then `Notepad++`, and it will work with any editor that supports
customizable user tools), and that editor-integration story is still how most people meet it — but
Lexi itself is not an editor plugin. It's a **BR program**, runnable headlessly with no editor
involved at all (see [Headless / scripted invocation](#headless)).

If you use Lexi, you can edit your `BR Programs` **without line numbers**. This frees you up to
copy and paste code, rearrange code, and add and edit code without having to worry about or
manually change any line numbers — Lexi adds and changes and manages your `line numbers` for you
automatically when you "compile" your program. By preprocessing your `source code|code` before
it's passed to BR, Lexi also gives you access to a handful of extra constructs BR doesn't have on
its own: the `#Select#`/`#Case#` construct (informally called "Select Case") and the `#Define#`
substitution directive documented under [Directive reference](#directives) below, plus `/* ... */`
comments and the `X$&=` compound-append shorthand.

<a id="mechanism"></a>
## What Lexi actually is

Lexi is a **BR library program**, not a separate compiler binary:

- **`lexi.br`/`lexi.brs`** is the library itself, exposing two functions:
  - **`fnApplyLexi(InFile$, OutFile$, Mode, SourceMapFile$)`** — translates Lexi-only syntax to
    plain BR and writes the result to `OutFile$`. The `Mode` argument controls line numbering:
    `1` translates syntax only, keeping whatever line numbers `InFile$` already has; `0` assigns
    line numbers **and** translates syntax in one pass — the mode a file written with
    `#AutoNumber#` (no baked-in numbers of its own — the normal shape of hand-authored,
    number-free source) needs.
  - **`fnUndoLexi(InFile$, OutFile$)`** — the reverse: strips line numbers back out of a numbered
    program, restoring the number-free editing shape (see [No Line Numbers](#no-line-numbers)).
- Every distribution of Lexi — the classic SageAX zip and the VS Code extension bundle described
  next — ships the same `fnApplyLexi`/`fnUndoLexi` engine; only the surrounding driver scripts and
  packaging differ.

<a id="distributions"></a>
## Where Lexi comes from

Two confirmed real distributions (there may be others):

### Classic distribution — the SageAX zip

The traditional path: download `Lexi.zip` from SageAX, unzip to a fixed local folder, and wire it
into an editor's user-tools menu. This is the distribution [Installing the classic
distribution](#installation) below walks through, and the one the rest of BR's ecosystem has
historically meant by "Lexi."

### Bundled distribution — the "BR Language Server" VS Code extension

The VS Code extension **`crs-dev.vslang-br`** ("BR Language Server") bundles the identical Lexi
engine under `<extension-install-dir>/Lexi/`:

| File | Role |
|---|---|
| `lexi.br` / `lexi.brs` | The Lexi library itself (see [above](#mechanism)) |
| `lexionly.brs` | Thin driver: `fnApplyLexi(InFile$, OutFile$, 1, SourceMapFile$)` — translate only, numbers already present |
| `linenum.brs` | Thin driver: `fnApplyLexi(InFile$, OutFile$, 0, SourceMapFile$)` — assign numbers and translate |
| `strip.brs` | Thin driver: `fnUndoLexi(InFile$, OutFile$)` |
| `brnative.exe` / `brnative.42.exe` / `brlinux` | Bundled BR runtimes (4.3 / 4.2 / Linux 4.3) used to actually run the above |
| `wbconfig.sys` | A config used only for this compile step — separate from any app's own `brconfig.sys` |

The extension's own README states its user-facing behavior plainly: **"Compile `.brs`/`.wbs` to
`.br`/`.wb` via the Lexi preprocessor"**, triggerable by `Ctrl+Shift+B` or automatically **on
save** (a per-file status-bar toggle). "Saving a `.brs` file in VS Code produces the matching
`.br`" is not the editor compiling anything itself — it's the extension shelling out to run this
same Lexi library through its bundled BR runtime. Some apps also keep their own root-level copy of
`lexi.brs` (e.g. because a screen-compile step invokes it directly) — check that app's own
conventions doc if so; a byte-for-byte diff against one such app-root copy, done during a prior
onboarding, found it identical to the extension's bundled copy aside from CRLF-vs-LF line endings,
but confirm byte-identity again rather than assuming it for a given app.

<a id="vscode-mechanism"></a>
### How the VS Code extension invokes Lexi

Reverse-engineered by reading the extension's own bundled `dist/extension.js` (not officially
documented) — the *translation* step has since been verified independently by actually running it
outside VS Code; the surrounding copy-in/compile-to-`.br`/copy-out steps are still as-read from the
code, not personally re-run end-to-end:

1. Copy the current source into a temp file the extension manages (under a `tmp/` folder next to
   the source).
2. Generate a small BR **proc** that:
   - `subproc lexionly.brs` or `subproc linenum.brs`, picked by whether the source already has
     line numbers;
   - **types two more numbered lines directly into the proc** — `Infile$="tmp\..."` /
     `Outfile$="tmp\..."` (and `SourceMapFile$=...`, if a source map was requested) — which BR
     inserts into the `lexionly.brs`/`linenum.brs` program now sitting in memory, between its
     existing `dim` and `library`/`fnApplyLexi` lines, exactly as if a human had typed new lines
     at the keyboard. This is how `Infile$`/`Outfile$` actually get set — not a command-line
     argument or an environment variable;
   - `run` (executes the now-patched Lexi driver against those files);
   - `clear`;
   - `subproc <the-now-translated-temp-file>` (loads the plain-BR result as the program to
     compile);
   - `skip PROGRAM_REPLACE if exists(...)` / `save "<target>.br"` **or** `replace "<target>.br"`
     (fresh compile vs. recompile over an existing object);
   - `system` (exit).
3. Run that proc through the bundled runtime with the bundled `wbconfig.sys` (a
   `"<brnative.exe>" "PROC <path>" -<wbconfig>` invocation — the same shape as any BR
   [startup command line](../platform/spec.md)), and watch stdout for BR's own error patterns to
   report a compile failure back in the editor.

<a id="headless"></a>
### Headless / scripted invocation

The mechanism above can be reproduced directly, with no editor involved. Verified live against
the VS Code extension's bundled `Lexi/brnative.exe` + `Lexi/wbconfig.sys`, run under `UNATTENDED`
logging so a bad input aborts fast instead of hanging:

```
proc noecho
subproc linenum.brs
00025 Infile$=":C:\full\path\to\source.brs"
00026 Outfile$=":C:\full\path\to\translated-output.brs"
run
clear
system
```

Run from inside the `Lexi/` folder (so the bare `subproc linenum.brs` resolves), e.g.
`Lexi\brnative.exe "proc :C:\full\path\to\this.prc" -Lexi\wbconfig.sys`. The leading `:` on each
absolute path is required — without it BR applies its own `DRIVE`-letter substitution to `C:` and
resolves the path wrong; a bare `:` marks a literal OS path (see [platform — startup command
line](../platform/spec.md)).

This kit ships a maintained wrapper around exactly this proc —
**[`dev/tools/lexi-compile.ps1`](../../../dev/tools/lexi-compile.ps1)** (PowerShell) — that
auto-detects the VS Code extension's bundled Lexi install, builds the proc, and runs it under
unattended logging with proper quoting/timeout handling:

```powershell
# Translate only — produces <source>.lexiout.brs next to the source
dev\tools\lexi-compile.ps1 -Source path\to\file.brs

# Translate AND compile to a real .br object
dev\tools\lexi-compile.ps1 -Source path\to\file.brs -Compile
```

See [`dev/BR_launch.md`](../../../dev/BR_launch.md#the-lexi-preprocessor) for the full parameter
list, and [`dev/APP-DEV-GUIDE.md`](../../../dev/APP-DEV-GUIDE.md#lexi-aware-coding-loop) for the
"Lexi-aware coding loop" this feeds into (translate → `brls -check`/`-sema` the translated file →
fix the original → recompile).

<a id="installation"></a>
## Installing the classic distribution

Lexi can be used to automatically convert between BRS and BR files from within MyEdit. This can
make your editing life much easier. Lexi works with **all versions of BR**; the classic
zip-and-user-tools installation below requires a version of MyEdit dated `October 20`, `2006` or
later. (If you're onboarding an app that's built around the VS Code extension instead, see
[Bundled distribution](#distributions) and [Headless / scripted invocation](#headless) — none of
the MyEdit-specific steps below apply to that path.)

The latest version of Lexi can be found at `http://www.sageax.com/downloads/Lexi.zip` (SageAX).

### Automatic installation (MyEdit)

Requires a version of MyEdit dated `March 5`, `2010` or later.

1. Unzip `Lexi.zip` into `C:\Lexi`. You must use this directory for the automatic installation to
   work.
2. Copy your personal `brserial.dat` file into this directory (`C:\Lexi`).
3. Launch MyEdit.
4. Select *Tools → Configure User Tools → Import Tools*. Select the `Lexi.mut` file that came in
   `Lexi.zip`.

### Manual installation (MyEdit)

1. Unzip `Lexi.zip` into its own directory.
2. Copy your personal `BRSerial.dat` file into this directory.
3. Launch MyEdit.
4. Go to the Tools menu, then select *Configure User Tools*.
5. Select *Add*.
6. Enter the following (replacing `C:\Lexi\` with the appropriate folder) and click OK to add the
   "Compile" tool:

   | Field | Value |
   |---|---|
   | Menu Item Name | Compile BR Program |
   | Application/Command | `C:\Lexi\ConvStoO.cmd` |
   | Working Folder | `C:\Lexi\` |
   | Command Line Parameters | `%%np_name %%npne_name "%%name" "%%folder"` |

   There are six other tools you can add the same way, substituting from the table below.

Once installed: loading a `.BR` file in MyEdit and selecting "Extract Source" converts it to
`.BRS` and reloads it; loading a `.BRS` file and selecting "Compile" automatically compiles it back
into a `.BR` file. This works with all versions of BR.

#### Available functions (MyEdit user tools)

| Menu Item | Application | Parameters |
|---|---|---|
| Compile BR Program | `ConvStoO.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Extract Source Code | `ConvOtoS.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Debug BR Program* | `DebugBR.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Extract Source Code and Strip Line Numbers | `ConvOSNL.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Add Line Numbers | `AddLN.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Strip Line Numbers | `StripLN.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |
| Run BR Program | `RunBR.cmd` | `%%np_name %%npne_name "%%name" "%%folder"` |

\* Debug BR Program requires a copy of `brnative.exe` (the matching version) sitting in the
application folder — not always possible. Use Compile BR Program where Debug BR Program can't be
used.

### Notepad++

Lexi can also be driven from Notepad++ by adding user commands to `shortcuts.xml` (typically
`%appdata%\Roaming\Notepad++`) or via *Run → Run...* saved as user commands, e.g.:

```
BR!s - Compile
C:\Lexi\ConvStoO.cmd "$(FULL_CURRENT_PATH)"

BRS - Line numbers - Add
C:\Lexi\AddLN.cmd "$(FULL_CURRENT_PATH)"
Alt+Shift+8

BRS - Line numbers - Remove
C:\Lexi\StripLN.cmd "$(FULL_CURRENT_PATH)"
Alt+8
```

Only these three functions (compile, add line numbers, strip line numbers) are documented for
Notepad++ — the other MyEdit tools (debug, extract-source) have not been ported to a Notepad++
command by any documented setup.

### Sublime Text

No documented setup exists for Sublime Text specifically; the general "any editor with
customizable user tools" approach (wire a command to `ConvStoO.cmd`/`StripLN.cmd`/`AddLN.cmd`, same
parameter shape as the Notepad++ commands above) is the only known path.

### Tips (all third-party editors)

- Inside the `\Lexi\` folder is a copy of BR renamed to `brnative.exe`. It works better if this is
  the same BR version you use in your programs — copy your BR over it if not.
- If "Extract Source" fails and MyEdit was installed to a custom location, edit `ConvOtoS.cmd` to
  point at the correct `MyEdit.exe` path.
- `DebugBR.cmd` only works if a working `brnative.exe` sits in the same folder as your program
  files.

<a id="directives"></a>
## Directive reference

Lexi preprocesses source code before passing it to BR, adding line numbers and interpreting the
following directives/constructs. (The first two below — multi-line comments and compound append —
were confirmed by running the real `fnApplyLexi` engine against test input; they were never
documented in this reference before.)

### `/* ... */` — multi-line comments

A C-style block comment, rewritten to ordinary `!` comments. A comment spanning multiple source
lines collapses on translation — the closing fragment attaches to the *next* line as a trailing
`!` comment rather than getting its own numbered line, so don't expect a strict
1:1 source-line-to-output-line mapping.

### `X$&="..."` — compound append

Shorthand for appending to a string variable. Lexi does **not** rewrite this to naive
self-concatenation (`X$=X$&"..."`, which silently corrupts past ~120,000 cumulative bytes — see
[`dev/essentials.md`](../../../dev/essentials.md), §4's self-concatenation gotcha).
It emits the corruption-safe append idiom directly: `X$(INF:0)="..."`.

<a id="no-line-numbers"></a>
### No line numbers

Working without `Line Numbers` is the feature Lexi is best known for. Load a file in MyEdit as
source code; if it has line numbers, select "Strip Line Numbers" to launch BR, strip them, and
reload the number-free program. Edit freely, then choose "Compile" or "Add Line Numbers" to put
numbers back — "Compile" also saves the result as a `.BR` file.

```
43900  ! #Autonumber# 43900,10
43910  DoesLayoutExist: ! Return true if layout exists in the layouts folder
43920        def library FnDoesLayoutExist(layout$;LayoutPath$*255)
43930           let Fnsettings(Layoutpath$) !:
                fnDoesLayoutExist = exists(LayoutPath$&Filename$)
43940        fnend
```

becomes, with line numbers stripped (and back again, identically, when re-added):

```
! #Autonumber# 43900,10
DoesLayoutExist: ! Return true if layout exists in the layouts folder
      def library FnDoesLayoutExist(layout$;LayoutPath$*255)
         let Fnsettings(Layoutpath$) !:
         fnDoesLayoutExist = exists(LayoutPath$&Filename$)
      fnend
```

### `#Autonumber# <line>,<increment>`

Directs the line-number-add routine to use specific numbers from this point on. Without it, Lexi
starts at `00001` and counts by 1. Placed as a comment:

```
! #Autonumber# 16000,10
DefineModes: ! Define the input spec modes
def fnDefineInputModes
   dim InputAttributesMode
   ...
```

becomes:

```
16000 ! #Autonumber# 16000,10
16010 DefineModes: ! Define the input spec modes
16020 def fnDefineInputModes
16030    dim InputAttributesMode
...
```

Numbers between successive `#Autonumber#` directives must stay ascending with enough room for the
intervening lines — if it detects the directives out of order, or not enough room, Lexi raises an
error and stops; `clear` then `system` returns to the editor to fix the directives before saving
and recompiling again. Placing `#Autonumber#` comments before stripping line numbers preserves the
original numbering structure as closely as possible when numbers are re-added.

### `#Define# `name` = text`

A precompiler text-substitution constant. Wherever `` `name` `` appears afterward in the program,
Lexi substitutes the defined text at preprocess time; a leading `.` on the `#Define#` comment line
stops BR from re-casing it:

```
!. "#Define# `ScreenControls` = "mat ControlName$, mat FieldName$, mat Description$, mat VPosition, mat HPosition, mat FieldType$"
```

lets a function signature reference `` `ScreenControls` `` and have Lexi expand it to the full
argument list every time the program is compiled. When line numbers are stripped back out, the
substitution reverts to `` `name` `` — the expansion is a preprocess-time artifact, not a
permanent rewrite of the source.

<a id="select-case"></a>
### `#Select# expr #Case# value ... #End Select#` (informally "Select Case")

Lexi's case/switch-style branch. **The `#` signs are required** — this is the actual spelling, not
the bare `SELECT CASE ... END SELECT` its informal name might suggest (see the correction note in
this page's frontmatter). It translates line-for-line into an `IF`/`ELSE IF` chain, with each
original directive line kept as a trailing `!` comment on its replacement:

```
#SELECT# Mode #CASE# InputAttributesMode
   let Window=fnGetAttributesWindow
   ...
#CASE# InputFieldlistMode
   let Window=fnGetFieldsWindow
   ...
#End Select#
```

becomes:

```
   IF  Mode  =  InputAttributesMode THEN  ! #SELECT# Mode #CASE# InputAttributesMode
      let Window=fnGetAttributesWindow
      ...
   ELSE IF  Mode  =  InputFieldlistMode THEN  ! #CASE# InputFieldlistMode
      let Window=fnGetFieldsWindow
      ...
   END IF  ! #End Select#
```

**The first `#Case#` must be on the same line as `#Select#`.** Lexi only recognizes the
`#Select# expr #Case# value` pair as one line. Split them (`#Select# Type$` on one line,
`#Case# "caption"` on the next) and Lexi leaves the `#Select#` and `#Case#` lines untouched but
still turns `#End Select#` into `END IF`. The result has an unopened `END IF`, which `brls -check
-sema` reports and real BR refuses to LOAD (confirmed 2026-10-09). One `#Case#` can match several
values separated by `#`, as ScreenIO's own source does:
`#Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "c" # "search" # "combo" # "filter"`.

The trailing comments are what let "Strip Line Numbers" turn the `IF`/`ELSE IF` chain back into
`#Select#`/`#Case#` form on the editor/number-free side. **A bare `SELECT CASE ... END SELECT`
(no `#` signs) is not valid syntax at all** — confirmed live: Lexi leaves it completely untouched
in both `Mode 0` and `Mode 1`, and the untouched result then fails to `LOAD` in real BR. It was
never valid Lexi syntax, and it isn't valid base BR either (BR's `SELECT CASE`/`END SELECT` support
requires the Lexi preprocessing step or an equivalent one — there is no built-in runtime construct
by that bare name).

### Spacing

Blank lines in the number-free source are turned into blank comment lines when numbers are added,
preserving the program's visual spacing and layout.

<a id="considerations"></a>
## Considerations

### `L#####` labels

Because Lexi strips line numbers before you edit, a hard-coded `GOTO`/`GOSUB` line-number
reference would break the moment numbers change. So before stripping numbers from any program,
Lexi loads it in BR and runs **`RENUM LABELS_ONLY`**, which replaces every hard-coded line-number
reference with a label of the form `L#####` (`#####` = the original line number). You're then free
to edit without line numbers, and the program still works once numbers are re-added.

`L#####` labels don't harm your code — it runs exactly as before. If you need them removed (e.g.
because they read as clutter), that's a separate cleanup step, not something Lexi does
automatically. When line numbers are re-added, any `L#####` labels present are used as hints to
match the new numbers back to the original numbering as closely as possible.

### Save source code before running a tool

Any Lexi user tool operates on the on-disk copy of the file, not what's currently in the editor
buffer. Save before invoking a Lexi tool, or the tool compiles/strips/adds numbers to stale
content — and because the tool reloads its *output* into the editor afterward, there's no undo:
the editor now believes the reloaded file is what you had, and unsaved changes are simply gone.

### `PROC NOECHO`

Older Lexi versions scrolled through the program's contents on screen while adding/removing line
numbers, which could be slow for large programs. Current versions compile under `PROC NOECHO` to
suppress that scroll and speed up compilation. The tradeoff: if a compile-time error occurs, you
won't see the offending line printed — press **F2** to see it.

## Disclaimer

Gabriel Bakker and Sage AX are not responsible for anything that happens to your BR programs or
data as a result of using this or any other tool they create.

<a id="see-also"></a>
## See also

- [Installation & tooling — Lexi preprocessor](spec.md#lexi) — the folded category summary this
  page backs.
- [`dev/BR_launch.md` — The Lexi preprocessor](../../../dev/BR_launch.md#the-lexi-preprocessor) —
  invoking `lexi-compile.ps1` headlessly, with its full parameter list.
- [`dev/APP-DEV-GUIDE.md` — Lexi-aware coding loop](../../../dev/APP-DEV-GUIDE.md#lexi-aware-coding-loop) —
  the detection check and the full translate/check/fix/compile loop this feeds into.
- [`dev/essentials.md` §1](../../../dev/essentials.md#1-core-language-rules) — Lexi's syntax
  summarized alongside BR's other core-language gotchas.
- [`dev/tools/lexi-compile.ps1`](../../../dev/tools/lexi-compile.ps1) — the maintained headless
  wrapper around [Headless / scripted invocation](#headless).
- [MyEdit_(BR_Edition)](MyEdit_(BR_Edition).md) — the editor Lexi's classic distribution targets
  first.
- [50-libraries/screenio](../../50-libraries/screenio/spec.md) — Lexi also supports ScreenIO
  development (a screen's compiled Helper Library can be built from Lexi-preprocessed pieces).
- [platform — startup command line](../platform/spec.md) — the `"<exe>" "PROC <path>" -<config>`
  invocation shape Lexi's own headless proc runs through.
