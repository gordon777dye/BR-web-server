# Onboarding the BR Context Kit to a New Application

**Purpose.** This document is a procedure **for teaching an AI Large Language Model (LLM)** the *coding style, 
data model, and toolset* of *your particular BR application*. Let your favorite AI model perform it once. 

When onboarding is complete, the reader may be a human or an AI model.

Please document any errors in ERRORS.md. This includes any inaccuracies *or ambiguities* found during the onboarding process.

---

## Contents

- [Prerequisite — the only thing YOU have to do](#prerequisite)
- [Instructions to AI — the principle: add a layer, don't edit the language](#principle)
- [Target shape when finished](#target-shape)
- [Procedure](#procedure)
  - [STEP 1 — BR launch entries](#step-1)
  - [STEP 2 — Audit source currency](#step-2)
  - [STEP 3 — Locate or create `filelay/`](#step-3)
  - [STEP 4 — Data model](#step-4)
  - [STEP 5 — Blessed exemplars](#step-5)
  - [STEP 6 — Conventions sheet](#step-6)
  - [STEP 7 — Architecture map](#step-7)
  - [STEP 8 — Wire the app layer into the entry point](#step-8)
  - [STEP 9 — Build a test data environment](#step-9)
  - [STEP 10 — Build the application's test suite](#step-10)
  - [STEP 11 — Survey brls vs real BR](#step-11)
- [Done criteria](#done-criteria)
- [The feedback loop (why this works)](#feedback-loop)
- [Maintenance](#maintenance)
- [Appendix A — the `filelay` file format](#appendix-a)
  - [Anatomy](#filelay-anatomy)
  - [Header lines](#filelay-header)
  - [Divider](#filelay-divider)
  - [Field definition lines](#filelay-fields)
  - [Comments, blanks, and end-of-file](#filelay-comments)
  - [Subscript numbers](#filelay-subscripts)
  - [Conversion checklist (other dictionary → filelay)](#filelay-conversion)

---

<a id="prerequisite"></a>
## Prerequisite - The only thing YOU have to do

**The user should place a copy** of the application's `brconfig.sys` into context/`dev/tools/`. The resulting 
file should be named `context/dev/tools/brconfig.sys`. It is best to copy any include files along with 
it that could be needed for AI processing. User specific statements are not needed for AI processing. 
Also remove any SUBSTITUTE and EXECUTE statements in include files, except SUBSTITUTEs with PRN:. 
If SUBSTITUTES are fundamental to the app (it won't run without them) then keep those in. 
There is no need for a license file. 

CAUTION: If you are running with a low end model such as Haiku or github copilot stop now 
and switch to a model that has more than a 200k context (e.g. Sonnet or better)

Onboardiong STEP 1 derives everything else from this one file. The remainder of this procedure is 
best done by an AI model.

---

<a id="principle"></a>
## Instructions to AI -The principle: add a layer, don't edit the language

`context/` ships in three layers. **Only the third is app-specific; leave the other two alone.**

| Layer | Path | Scope | Edit during onboarding? |
|---|---|---|---|
| Language truth | `br_tree/` | BR syntax/semantics (37 verified `2b` specs) | ❌ Never — it is app-independent |
| Generic coding kit | `dev/` | Router, semantics, catalogs, tools | ◐ Only `APP-DEV-GUIDE.md` (add app pointer rows) |
| **App layer** | **`app/`** | **This** application's data model, style, and tools | ✅ This is what you build |

Onboarding adds an **app axis** beside the existing **language axis**; keep them distinct:
- **Language axis** — two parallel keyword entry points into the same reference, reached from a token
  you're about to read or write:
  - `topics.json` (statement/clause keyword) → `statement-semantics.md` → `br_tree/` — a *lexical*
    router with line ranges + the reserved-word `lexicon`.
  - `brtree-index.json` (any BR keyword — config, screen, printing, functions, commands) →
    `br_tree/<spec>#<anchor>` — a concept→spec router over *all* leaves; use it for non-statement
    tokens or to reach the authoritative spec directly. Complements `topics.json`, doesn't replace it.
- **App axis** (new): `context/dev/APP-DEV-GUIDE.md` → always-load `conventions.md` + `BR_launch.md`; on-demand
  `data-model.md` (by file), `exemplars/` (by archetype), `architecture.md`.

The app axis links *into* the language axis for statement detail — it does not live inside it.
`topics.json` stays a keyword→semantics index and is **not** where app conventions/architecture live
(they aren't keyword-addressable).

As you add layer 3 keep the kit's **progressive restatement** discipline: state each app fact in full
in the `app/` docs and as a terse pointer in `context/dev/APP-DEV-GUIDE.md` (the app entry point) — increasing
brevity as it ascends. (Language facts still ascend into `topics.json`; app facts do not.)

---

<a id="target-shape"></a>
## Target shape when finished

```
context/app/
  ONBOARDING.md         # this sheet (stays)
  env.cmd, env.ps1      # STEP 1 — set the BR launch environment variables (cmd, PowerShell)
  onboarding/setx.cmd   # STEP 1 — saves the same variables in the user's Windows profile
  data-model.md         # STEP 4 — generated from the app's filelay/ folder
  data-model-index.json
  exemplars/            # STEP 5 — ~10–20 blessed real programs, annotated
  examples/             # optional, created as needed — one-off technique demos, NOT house style
  conventions.md        # STEP 6 — house style, derived from the app's own source
  architecture.md       # STEP 7 — module map + core data flows
  test/                 # STEP 9 — de-identified sample data, one sub-folder per data folder (optional)
  tests/                # STEP 10 — the app's test suite: screen tests, function tests, endtest stub
  BR_test.md            # STEP 11 — real-BR LOAD/SAVE survey of this app's tree
  BRLS_test.md          # STEP 11 — brls's own parse/sema survey of the same tree
```

`context/dev/BR_launch.md` (referenced by STEP 1 — BR launch env, canonical invocations, run/build commands) is a
static, application-agnostic kit file. 

`context/dev/APP-DEV-GUIDE.md` holds pointers to the generated app docs (STEP 8); `topics.json` is the
language keyword router. 

---

<a id="procedure"></a>
## Procedure

Do them in order. Each step's prerequisites come before it:
- **STEP 1 (BR launch)** comes first, because nothing else can run BR without it.
- **STEP 2 (audit source currency)** uses the BR runtime STEP 1 configured. It comes next because
  everything after it reads the app's source. STEP 3 cross-checks layouts against it, and STEPS 5–6
  learn the house style from it. For a compiled-masters app, that source doesn't exist until
  STEP 2 decompiles it.
- **STEP 3 (locate/create `filelay/`)** gates STEP 4. `extract-schema.exe` only parses `filelay/`,
  so STEP 4 has nothing to read until STEP 3 confirms or creates it.
- **STEP 9 (test data) is optional on a developer's own copy, and required at a customer site.**
  Ask the user before starting it. **STEP 10 (test suite)** comes after it, because the tests run
  on STEP 9's data, or on the main data when STEP 9 was skipped.

The data model (STEP 4) and exemplars (STEP 5) deliver most of the value: correct file I/O and
demonstrated style.

<a id="step-1"></a>
### STEP 1 — BR launch entries (fully automated)
Create 2 of the 4 files to be used by AI for application development.

**Fixed locations:** - files used to compile and test BR programs

| Role | Path |
|---|---|
| BR executable (BR 5.0) | `context/dev/tools/brserver-x64-Release.exe` |
| Existing app startup config | `context/dev/tools/brconfig.sys` |
| AI Utility config (headless) | `context/dev/tools/brconfig.ai_util` |
| AI User config (interactive) | `context/dev/tools/brconfig.ai_user` |

**Generate `context/dev/tools/brconfig.ai_user`** from `context/dev/tools/brconfig.sys`:
1. Copy `brconfig.sys`. If `context/dev/tools/brconfig.sys` doesn't exist, request the user
   to place it there. Don't proceed without it.
2. Remove every line that is an `EXECUTE` statement 
  — matched on the line's leading token (case-insensitive, ignoring leading whitespace); 
    don't touch commented-out (`REM`/`!`) lines.
3. Remove every line that is a `LOGGING` statement, matched the same way.
4. Remove every line that is a `SUBSTITUTE` statement except for those with PRN: or prn:.
5. Prepend, as the new first line of the file:
   ```
   LOGGING 10, context\app\startlog.txt
   ```
6. Check `brconfig.sys`, and every file it includes, for an active `OPTION 60` line (matched the
   same way as step 2, so a commented-out one doesn't count). **Under BR 4.3 this kit does not
   support `OPTION 60`** (see [`essentials.md`](../dev/essentials.md) §2). If you find one, stop
   and tell the user. Don't remove it yourself: under 4.3 it makes BR save programs in the
   4.18-and-earlier format, and production may depend on that. Explain that `OPTION 60` has been 
   repurposed as described in the next step. 
7. Insert this line just before the `include subs.txt` line (or as the last line, if there is none yet):
   ```
   option 60 ! BR 5.0 ($BR_EXE): save in the 4.3 format (level 38) so BR 4.3 can load it
   ```
   The AI configs run `$BR_EXE`, which is BR 5.0. There this option makes `SAVE`/`REPLACE` write
   the 4.3 object format, which a 4.3 production BR can load; without it, 4.3 refuses the program
   with error 2240. Under 4.3 the option means something else, which is why `brconfig.sys` itself
   keeps it off ([`BR_launch.md`](../dev/BR_launch.md#option-60)).

**Generate `context/dev/tools/brconfig.ai_util`** from the `brconfig.ai_user` just produced:
1. Copy `brconfig.ai_user`.
2. Replace its `LOGGING` line with:
   ```
   LOGGING 10, context\app\startlog.txt, unattended
   ```

The UNATTENDED keyword lets AI run BR in a headless (no user prompts) mode.

Both are regenerated whenever `brconfig.sys` changes — generated, never hand-edited (same
convention as `data-model.md`/`topics.json`).

Now back up all 3 configuration files — `brconfig.sys`, `brconfig.ai_user` and
`brconfig.ai_util`, plus any files they include — to `context/app/onboarding/`. These will be
needed for applying future kit updates. They stay out of git: only the kit's own templates in that
folder are tracked.

**Find BR's start folder.** Take the first `DRIVE` line in `brconfig.ai_util`: BR starts in its
2nd parameter plus its 4th (`DRIVE Y:,y:\,,\wb` starts in `y:\wb`). Compare that folder with the app
root (the folder holding `context/`):
- **Same folder:** kit paths work unchanged. Record "BR starts in the app root; no prefix".
- **Different:** every kit path handed to BR needs the app root's path from BR's start folder
  (`ar1\` for the example above, with the kit in `y:\wb\ar1`). Record the folder and that prefix. If
  the app root isn't below BR's start folder, there is no such relative prefix: stop and ask the
  user.

Record it in the "BR starts in" line at the end of the AI Model Rules in `context/README.md`. The
rules, and the probe behind them, are in
[`dev/BR_launch.md`](../dev/BR_launch.md#start-folder). Don't change the `DRIVE` lines to fix a
mismatch: production starts in the same folder, so the app's programs depend on it.

**Write the environment scripts.** These set the variables listed in
[`dev/BR_launch.md`](../dev/BR_launch.md#br-launch-environment). Both build their paths from
their own location, so write them exactly as shown; nothing in them is specific to this app.

1. Write `context/app/env.cmd`:
   ```bat
   @echo off
   rem Sets the BR launch environment variables listed in context\dev\BR_launch.md.
   rem Generated by ONBOARDING.md STEP 1. The paths are built from this script's
   rem own location, so they are absolute and work from any current folder.
   rem
   rem In cmd:        call context\app\env.cmd
   rem From another shell, in the same command as the program that needs them:
   rem   cmd /c "context\app\env.cmd && context\dev\ai_access\br_mcp_driver.exe start"

   for %%I in ("%~dp0..") do set "BR_CONTEXT_KIT=%%~fI"
   for %%I in ("%~dp0..\..") do set "APP_ROOT=%%~fI"

   set "BR_EXE=%BR_CONTEXT_KIT%\dev\tools\brserver-x64-Release.exe"
   set "BR_MCP_DRIVER=%BR_CONTEXT_KIT%\dev\ai_access\br_mcp_driver.exe"
   set "BR_CONFIG=%BR_CONTEXT_KIT%\dev\tools\brconfig.sys"
   set "BR_AI_UTIL=%BR_CONTEXT_KIT%\dev\tools\brconfig.ai_util"
   set "BR_AI_USER=%BR_CONTEXT_KIT%\dev\tools\brconfig.ai_user"
   set "BRLS_EXE=%BR_CONTEXT_KIT%\dev\tools\brls.exe"
   ```
   And beside it `context/app/env.ps1`, the same variables for PowerShell. An agent whose shell
   cannot run `cmd /c "...env.cmd && ..."` reliably (quoting from a Bash tool, measured) uses this
   instead, dot-sourced in the same command: `. context\app\env.ps1; & $env:BR_MCP_DRIVER ...`.
   ```powershell
   # Sets the BR launch environment variables listed in context\dev\BR_launch.md,
   # the same ones env.cmd sets, for PowerShell. Generated by ONBOARDING.md STEP 1.
   # The paths are built from this script's own location, so they are absolute and
   # work from any current folder.
   #
   # In PowerShell, dot-sourced, in the same command as the program that needs them:
   #   . context\app\env.ps1; & $env:BR_MCP_DRIVER uitest --suite

   $kit = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
   $env:BR_CONTEXT_KIT = $kit
   $env:APP_ROOT = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

   $env:BR_EXE = "$kit\dev\tools\brserver-x64-Release.exe"
   $env:BR_MCP_DRIVER = "$kit\dev\ai_access\br_mcp_driver.exe"
   $env:BR_CONFIG = "$kit\dev\tools\brconfig.sys"
   $env:BR_AI_UTIL = "$kit\dev\tools\brconfig.ai_util"
   $env:BR_AI_USER = "$kit\dev\tools\brconfig.ai_user"
   $env:BRLS_EXE = "$kit\dev\tools\brls.exe"
   ```
2. Write `context/app/onboarding/setx.cmd`:
   ```bat
   @echo off
   rem Saves the BR launch environment variables in the Windows user profile, so
   rem every program started afterwards has them. Generated and run by
   rem ONBOARDING.md STEP 1. Takes its values from ..\env.cmd, so the two never
   rem disagree. Re-run it if the kit moves.
   rem
   rem The values reach only programs started after this runs: close every VS Code
   rem window and start it again. To remove one: reg delete HKCU\Environment /v <NAME> /f

   setlocal
   call "%~dp0..\env.cmd"

   setx BR_CONTEXT_KIT "%BR_CONTEXT_KIT%" >nul || goto failed
   setx APP_ROOT       "%APP_ROOT%"       >nul || goto failed
   setx BR_EXE         "%BR_EXE%"         >nul || goto failed
   setx BR_MCP_DRIVER  "%BR_MCP_DRIVER%"  >nul || goto failed
   setx BR_CONFIG      "%BR_CONFIG%"      >nul || goto failed
   setx BR_AI_UTIL     "%BR_AI_UTIL%"     >nul || goto failed
   setx BR_AI_USER     "%BR_AI_USER%"     >nul || goto failed
   setx BRLS_EXE       "%BRLS_EXE%"       >nul || goto failed

   set APP_ROOT
   set BR
   exit /b 0

   :failed
   echo setx failed; nothing after the first failure was saved.
   exit /b 1
   ```
3. Check `env.cmd`: run `cmd /c "context\app\env.cmd && set APP_ROOT && set BR"` from the app
   root. `APP_ROOT` must be the app root, `BR_CONTEXT_KIT` must be its `context` folder, and each
   of the other six must name a file that exists.
4. Ask the user whether they intend to use the context kit in more than one repo (app) on this
   machine. `setx` saves one value per variable for the whole Windows user, so a second kit would
   get the first one's BR, configs and data paths.
   - **More than one:** don't run `setx.cmd`. Each kit uses its own `env.cmd`, so BR commands are
     always prefixed with `cmd /c "context\app\env.cmd && …"`. Fill in the "BR environment
     variables are" line at the end of the AI Model Rules in `context/README.md` with "not
     saved", so later sessions know.
   - **Only this one:** run `cmd /c context\app\onboarding\setx.cmd`. It saves the eight variables
     in the user's Windows profile and lists them. Then tell the user to **close every VS Code
     window and start it again**, from the Start menu or a shortcut rather than a terminal opened
     before the script ran. Programs that are already running, including this session's shells,
     don't see the new values. For the rest of this session, prefix BR commands with
     `cmd /c "context\app\env.cmd && …"`. Fill in the "BR environment variables are" line in
     `context/README.md` with "saved in the Windows user profile".

**While here, check whether this app is written for Lexi** (a preprocessor some BR shops use —
see [`dev/BR_launch.md`](../dev/BR_launch.md#the-lexi-preprocessor) for what
it is and [`dev/essentials.md`](../dev/essentials.md#1-core-language-rules) for its syntax). A
quick signal: grep the app's `.brs/.wbs` source for `/* `, `&=`, or `#Select#` (a bare `SELECT CASE`
with no `#` is **not** a useful signal — it isn't valid syntax in Lexi or base BR either, see
`essentials.md`). If any show up outside `br_tree`/comments, ask the app owner to confirm — don't
just infer it from a grep hit alone. This matters for STEP 2 (a Lexi-based app's `.br` is produced
by Lexi, typically via the "BR Language Server" VS Code extension compiling on save — not by
`LOAD ... source`/`SAVE` directly, though the mtime relationship the audit checks still holds
either way) and STEP 6 below (record it in `conventions.md` if confirmed).

When STEP 1 regenerates brconfig.ai_user and brconfig.ai_util from a changed brconfig.sys, append the include subs.txt line from step 9 to them again, and make brconfig.ai_test again from the new brconfig.ai_user (STEP 10).

<a id="step-2"></a>
### STEP 2 — Audit source currency (`.brs` vs `.br` and `.wbs` vs `.wb` ) ◆ automated; no user decision
Typically AI models have trouble with this one because they don't understand how BR DRIVE statements work. 
Get familiar with the DRIVE statement, examine the first drive statement and thereby learn what 
folder is current (present working directory) when BR starts. Note, BR uses backslashes in 
pathnames like Windows Command Prompts, and forward slashes mean something legacy - 
so don't use them. 

STEPS 5–6 learn the house style by reading the app's **`.brs` source**. Because BR can edit a program
while it is compiled (*incremental compilation*), the `.brs` on disk may be **stale or absent**. A
timestamp audit settles this mechanically — no need to ask which copy is authoritative:

Before proceeding with this step, ask the user whether the program masters are kept in source or
compiled form. Record the answer in `context/README.md` at the end of the Rules section. If the 
program masters are stored in source format decompiling is prohibited. 

> **Audit every compiled `.br`/`.wb`: confirm a corresponding source file (e.g. `prog.br.brs` or 
`prog.brs` for `prog.br`) exists, and compare the two modification date-times.**

A current source is normally a little **older** than its `.br`, not newer. The source is saved
first, and the compile (`LOAD … source` + `SAVE`/`REPLACE`, or an automatic compile on save)
writes the `.br` seconds later. So a small gap in the `.br`'s favour is the normal
save-then-compile sequence, not staleness. In one real audit, 119 of the 134 files a strict
"source ≥ `.br`" rule flagged were within 60 seconds of their `.br`.

- **Pass:** the source exists, and it is newer than its `.br`, or older by **15 minutes or less**.
  That source is current; nothing to do.
- **Stale:** the source is **missing**. If program masters are stored in compiled form, decompile
  the program to create it. Otherwise report it in `context/app/STALE_SOURCE.md`.
- **Suspect:** the source is older than its `.br` by **more than 15 minutes**. The `.br` may have
  been changed without the source, or the compile may simply have happened later.
  - If program masters are stored in **compiled** form, decompile these programs too; it is
    harmless when the source was current.
  - Otherwise, list them in `context/app/STALE_SOURCE.md` with the size of each gap, marked "to
    verify". Don't call them stale. The confirming sign of genuine staleness is the `.brs` also
    being clearly smaller, or missing content that the `.br` has, not the date alone.

The 15-minute window is a default. Widen it if this shop routinely compiles long after saving.

If decompiling: After identifying a missing or stale .brs file refresh it by running BR with the command: 
> `LIST < <path\program-name> > <path\program-name.br.brs> : EXECUTE "system"` 

Or put the LIST commands into a procedure (batch) file and execute it with "PROC <batch-file-pathname>". 

<a id="step-3"></a>
### STEP 3 — Locate or create `filelay/` ◆ prerequisite for STEP 4
STEP 4 does **not** inspect the app's actual data files to learn their layout. `extract-schema.exe`
only parses the plain-text **`filelay/`** directory (described in Appendix A): one 
hand-declared layout file per data file, giving the FORM spec, disk position, and 
key composition of every field. If `filelay/`doesn't exist, STEP 4 has nothing to read.

1. **Search the app tree for an existing `filelay/` directory** — check case variants too, and don't
   assume it sits directly under the app root: FileIO's `DefaultFileLayoutPath$` setting (in
   `fileio.ini`) can relocate it anywhere, so a real app's dictionary may live elsewhere in the
   tree. If found and it holds one layout file per data file in the Appendix A format, note its
   actual path as `<filelay-path>` and skip to STEP 4.
2. **If none exists, synthesize one — from authoritative sources only, never by guessing at record
   shape:**
   - **Best source: the app's own data dictionary**, if one exists. It need not be a text file — a
     dictionary can just as easily be stored as a BR `INTERNAL` (binary) file, since BR reads its
     own internal formats most conveniently. If it's in `INTERNAL` format, write a short BR program
     to read it and export its contents into `context/app/filelay/` in the Appendix A format.
   - If no dictionary — text or `INTERNAL` — can be located, ask the user where it lives and in
     what format, rather than guessing.
   - **Cross-check against the app's own BR source once a draft layout exists.** STEP 2 has made
     that source current. Skip any program STEP 2 listed in `STALE_SOURCE.md`, and don't take its
     `FORM`s as confirmation. Named `FORM`
     declarations and the `OPEN`/`DIM` statements that reference them describe the real on-disk
     field order. Treat this as **confirmation only, not the primary source** — `FORM` specs can
     jump position (`POS n`), skip bytes (`X n`), and be partial, so they don't reliably reconstruct
     a complete layout on their own.
   - **Do not derive a field layout from the raw `.dat` bytes.** A record's field boundaries aren't
     recoverable from binary data without the FORM spec — reverse-engineering a plausible-looking
     layout that way is exactly the kind of guess [README.md's rule](../README.md) forbids.
   - Write each confirmed layout into `context/app/filelay/`, in the exact format given in **Appendix A**:
     header line (data file, prefix, version `0`), key lines, optional `recl=`, `====` divider, then
     one field line per field in on-disk order. Appendix A's "Conversion checklist" is the
     step-by-step for this. Note this path as `<filelay-path>` `context/app/filelay/` or 
     `<app-root>/filelay`) for STEP 4.
3. **Sanity-check before moving on:** every layout file has a header line, a divider, and at least
   one field line; if `recl=` is given, be sure it's consistent with the sum of field sizes. If not,
   stop and report the discrepancy to the user. A solid `filelay/` folder is required to proceed. If
   the user tells you to ignore the discrepancy then do so.

<a id="step-4"></a>
### STEP 4 — Data model (automated) ◆ highest ROI
The LLM cannot write valid `OPEN` / `READ…USING` / `KEY=` without the real field layouts and key
composition. This step is deterministic.

```
context/dev/tools/extract-schema.exe <filelay-path> context/app
context/dev/tools/gen_datamodel_index.exe
```

Run both from the app root (the directory containing `context/`), like every invocation in
`context/dev/BR_launch.md`.

`<filelay-path>` is the directory STEP 3 resolved — not necessarily `<app>/filelay`; use whatever
path STEP 3 found or created.

- **Produces:** `context/app/data-model.md` (readable) — per file: data path, record length, key indexes
  **with their composing fields in order**, and every field's FORM type/position. Each file section
  carries an `<a id="…">` anchor.
- **Index:** `gen_datamodel_index.exe` then builds `context/app/data-model-index.json` — a per-file map to
  1-based inclusive line ranges (like `dev/topics.json` for statement-semantics). Load one file's
  slice instead of the whole (large) `data-model.md`.
- **Verify:** the extractor prints `layouts: N, total fields: M`; the indexer prints `files: N …`.
  Then run `context/dev/tools/gen_datamodel_index.exe --verify`, which checks the index against
  `data-model.md` without writing anything and prints `VERIFY OK: …` when they match (exit 1 and a
  list of problems otherwise).
- **Re-run both** whenever `filelay/` changes — they are generated, never hand-edited.

<a id="step-5"></a>
### STEP 5 — Blessed exemplars ◆ the real way style is learned
An LLM learns style far better from a few gold-standard *real programs* than from prose about style.

1. Pick **one representative, correct program per task archetype** the app actually has — e.g. a
   file-maintenance form (`*fm`), a report (`*p`), a batch update, an EDI translate/load, a
   menu/dispatch, a keyed-read utility. Aim for **10–20** total.
2. Copy each into `context/app/exemplars/` (or reference it) and add a short header comment:
   *"Blessed pattern for X. Note: the error-handling idiom, the naming convention, FileIO-vs-raw-OPEN
   choice, screen handling."*
3. Choose files that are **minimal but complete** and genuinely typical — not the biggest or most
   clever. These are few-shot examples; their style is what the model will imitate.

<a id="step-6"></a>
### STEP 6 — Conventions sheet (derived, not guessed)
A 1–2 page `context/app/conventions.md` that **names** the rules the exemplars embody, so the model can
apply them to code it hasn't seen.

- Cover: naming (subscript constants, file prefixes), FileIO vs. raw `OPEN` preference, the house
  error-handling form, line-numbering / Lexi usage, screen conventions, module placement.
- **Derive the dominant idiom from the app's own source**, don't assert from habit: read a
  representative sample across modules and record which form actually dominates (FileIO adoption
  rate, the prevailing error-handling pattern, the naming shape), then state that as the convention
  with a pointer to an exemplar that shows it.

> **⚠️ Describe shape, don't fabricate an API.** `conventions.md` documents the *shape* of code;
> `exemplars/` are *deliberately chosen* whole files. Do **not** scrape the app's user-defined or
> library function names into a "standard API" list — that manufactures a surface the model will
> call incorrectly. Teach usage by whole-file exemplar instead.

<a id="step-7"></a>
### STEP 7 — Architecture map/res
`context/app/architecture.md` — the directory taxonomy, entry points, and 2–3 **core data flows**
(e.g. order → allocation → ship → EDI). Make them short, like a module table in 
your AI agent's memory file (`CLAUDE.md` or `AGENTS.md`).

<a id="step-8"></a>
### STEP 8 — Wire the app layer into the entry point and update either CLAUDE.md or AGENTS.md

1. Go to the app root and run the /init command to be sure either 
  a CLAUDE.md or AGENTS.md file is placed in the app root.
2. Insert `@context/README.md` at the end of any CLAUDE.md or AGENTS.md files in the app root folder. 
3. Modify `context/README.md` as follows: - State "onboarding has been completed" just ahead of 
  the onboarding paragraph.
4. If you are operating in vscode chat mode stop and use another service with more than 200k of 
  context capacity. This kit only uses around 30k but it requires better intelligence than vscode chat provides. 
5. If you are operating in cursor: - Follow the instructions in `context/app/onboarding/context-kit-always-load.md`. 
  This will create necessary initialization rules for this repo under cursor. 
6. Advise the user that the first prompt after onboarding and restarting should be: 
  "Which documents did you read in full during initialization?"

<a id="step-9"></a>
### STEP 9 — Build a test data environment ◆ optional on a developer's copy; required at a customer site

**Ask the user first whether to build it.** It takes the longest of any step, and on a
developer's own copy of an application, whose data is already a copy, it can be skipped. If the
user skips it, **warn them, in these words or close to them:**

> STEP 9 is required at a customer site. Without it, every AI run and every test reads and writes
> the application's main data, and the real names in it go into the scripts, baselines and test
> output, and to the model. Skip it only when this data is a copy nobody depends on.

Then fill in the "Test data is" line in `context/README.md` with "the main data (STEP 9 skipped
on <date>)", leave `subs.txt` and the `include subs.txt` lines out, and go on to STEP 10, which
treats the main data as the test data. When STEP 9 is done, fill in that line with
`context/app/test/`.

Programs under development or debugging must never run against live data. This step builds a
small, de-identified copy of the application's data under `context/app/test/`, and points the
kit's BR configs at it with `SUBSTITUTE` statements. Every later headless or interactive AI run
then reads and writes test data only.

**1. Create the test folders.**
- Make `context/app/test/`.
- Read the `Data file:` line of every file in `context/app/data-model.md` (e.g. `ard\customer` →
  data folder `ard`). Make one sub-folder for each distinct data folder:
  `context/app/test/ard/`, `context/app/test/oed/`, and so on.
- **Leave out `screen\`, `screenio\`, `tools\` and `toold\`**, and every file in them. They hold ScreenIO's
  screen definitions and the development tools' own data (`toold\`: `app`, `context`, `file_app`,
  `record`), not application data. So they get no test folder, no sample copy and no
  `SUBSTITUTE` statements. Programs keep using the production copies.
- **Skip a data folder that is empty in production** and whose files are all missing or
  per-workstation (`[wsid]`) names. There is nothing to copy, and its name may occur in unrelated
  paths (e.g. `data\` inside Windows `AppData\`), which a `SUBSTITUTE` would then break (step 5).

**2. Copy a sample of every data file.**
- For each file in the data model, copy **the greater of 10 % of its records or 100 records** into
  its test sub-folder. Copy every record of a file that has fewer than 100.
- Do the copy with a BR program, not an OS file copy. Open the production file `INPUT` with
  `SHR`, read each record whole as one string (`FORM C <recl>`), change the de-identified fields
  by position (step 3), and `WRITE` it to a new `INTERNAL` file of the same name and record length
  in the test folder. Every other byte is copied unchanged.
- **Take the record length and record count from the file, not the data model.** First run a
  read-only BR probe that opens each production file and records `RLN(n)` (record length) and the
  number of records it can read. In QSMRP 18 files had a different record length than
  `data-model.md` says.
- Pick the sample spread evenly through the file: of `N` records, keep record `i` when
  `INT(i*M/N)` differs from `INT((i-1)*M/N)`, where `M` is the sample size. This keeps exactly
  `M` records.
- **Rebuild every key file of the data file** in the test folder, under the same key-file names,
  with BR's `INDEX` command:
  - **Key-file name:** in parentheses on each key line of `data-model.md` (e.g.
    `` `ky2` (`customer.ky2`) ``), taken from the file's `filelay/` header. A name with no folder
    is in the data file's folder.
  - **Positions and lengths: take them from the production key file.** The probe opens the data
    file with each `KFNAME=` and records `KPS(n,seg)` and `KLN(n,seg)` for `seg` 1–6 (`-1` = no
    more sections). Compare them with the data model's fields. BR reports adjacent sections as
    one (`1/9/11` with lengths `8/2/9` is `1` with length `19`), so merge adjacent data-model
    segments before comparing. In QSMRP 30 of 308 keys still differed, from filelay errors; the
    production key file is what programs open, so it wins.
  - **Modifiers:** `KPS`/`KLN` don't report them. Take `Y`, `YB` and the like from the data model
    where a data-model segment lines up exactly with a production section, and report any that
    sit inside a merged section (they can't be reproduced). Test `U` (case-insensitive) on
    production: read a record, rebuild its key with one section's letters in the opposite case,
    and look it up with `KEY=`. If it's found, that section is `U`. Write each modifier after the
    section length, as BR's `INDEX` takes them: `INDEX <master> <key> 20/9 30U/2 REPLACE`.
  - **Build a key file only from the data file it's named for.** Some layouts borrow another
    data file's key file. Building it from the borrowing
    file overwrites the real one, or fails with error 7600 when positions lie beyond its record
    length. Leave those to the owning file and report them.
  - **Key files that don't exist** next to the production data file: copy the data without them
    and report them, unless the user says otherwise.
  - Use `REPLACE DUPKEYS LISTDUPKEYS >file`. Without `DUPKEYS`, a duplicate key stops `INDEX` with
    error 7603 and ends an unattended run. Then, for each key with duplicates in
    test, scan the production key file in key order and confirm production has duplicates there
    too. An empty list file still holds one end-of-file byte (`\x1a`).
- Build the key files once the copy, with step 3's de-identification applied, has written the
  last record. A de-identified field can be part of a key (e.g. `customer`'s `ky2` starts with
  `CustomerName`), so the keys must be built from the changed data.
- Before executing this step, read the next step which augments this step.
- Run the probe and copy programs headlessly with `$BR_AI_UTIL`, **before** step 6 adds the
  `include`. Once the configs redirect the data folders, a program can no longer reach the
  production files by their normal names.

**3. De-identify name fields.** Do this inside the step 2 copy program, on each record between
its `READ` and its `WRITE`, so no real name is ever written to the test folder.

*a. Choose the fields.* Read them from `data-model.md`, file by file:
- **Candidates:** a field whose name or description contains "name" (e.g. `CustomerName$`,
  "Customer Name"), and whose type is a string (`C` or `V`).
- **Key fields are included.** A name that is part of a key (e.g. `customer`'s `CustomerName`,
  in `ky2` and `ky3`) is changed like any other. Part *c* keeps every copy of it in step, so
  records in other files that hold it still point to the same record.
- **Never change a system identifier.** "name" also matches fields that name parts of the
  application: files, key files, fields, tables, printers (e.g.
  `file_app.KeyFileName$`, `eqtm.TableName$`, `printer.PrinterName$`). Programs use these
  values to find things, and they hold no personal data. Keep them unchanged.
- **Get the list confirmed.** Write `context/app/test/DEIDENTIFY.md`, with one row per field:
  file, field, position, length, whether it is part of a key, and its status (change, or system
  identifier kept). Ask the user to confirm it before changing any data. Add any other fields
  they want de-identified, such as addresses, phone numbers or tax IDs.
- **`DEIDENTIFY.md` controls the copy.** Once the user has confirmed it, build the copy program's
  field list from this file, not from your own scan. **Only rows whose Status is exactly
  `change` are scrambled.** Any other Status, or a deleted row, leaves the field as it is in
  production. Say this at the top of `DEIDENTIFY.md` too, so the user knows how to edit it.

*b. Build each replacement.* For a field value `V$`:
1. If `RTRM$(V$)` is empty, leave it blank.
2. Otherwise, build a new value one character at a time over `LEN(RTRM$(V$))` characters:
   - a letter becomes a random letter of the same kind, a vowel for a vowel and a consonant for a
     consonant, so the result stays pronounceable (its case is set as part *c* describes);
   - a digit becomes a random digit;
   - a space or punctuation mark stays as it is, so word breaks and the length are kept.
   Use `RND` for the random choices.
3. Pad the result with spaces to the field's full width, and store it at the field's position.

*c. Keep replacements consistent.* The same real value must get the same replacement everywhere
it appears, in every file and field. That keeps key values and the references to them in other
files in step. Build the table before you copy anything:
1. **Collect.** In one pass over the production records being sampled, collect every distinct
   non-blank trimmed value of every field marked "change", into an array of originals.
2. **Compare without case.** Store each original as `UPRC$` of its value, and build its replacement
   in upper case. When you apply a replacement, give each letter the case of the letter it
   replaces. Keys marked `-U` ignore case, so values that differ only in case must still match
   after the change.
3. **Assign longest first.** Give replacements in order of length, longest first. If an original
   is the start of a longer original (a name stored cut short, as in `customer`'s `ky3`, which
   uses `CustomerName(1:8)`), give it the same start of the longer one's replacement, not a new
   one.
4. **Keep replacements unique.** If a new replacement is already in the replacements array, make
   another, so two different names never become the same name and no key gets a duplicate.
5. **Look up while copying.** For each field value, find its original with `SRCH` and use the
   matching replacement.

Size both arrays for the number of distinct values (see [`essentials.md`](../dev/essentials.md) §2).

*d. Check the result.* After the copy, read each changed field in the test files back. Confirm
that:
- every non-blank value differs from the production record's value, and has the same trimmed
  length;
- the same production value has the same test value in every file;
- every key file builds without a duplicate-key error where production has none.

**4. Copy the rest of each data folder.**
Once a data folder is redirected (step 5), programs find **only** what is in its test folder.
A production data folder holds far more than the data model covers: system files such as
`cnd\security`, `cnd\permits` and `cnd\menu.dat`, files with no layout, old copies, logs,
per-workstation work files and subfolders. In QSMRP about 840 files (about 500 MB) were not in
the data model. Without them much of the app fails in test.

- **Data folders:** copy every file and subfolder that the step 2 sample didn't create, whole and
  unchanged, with an OS copy (no BR needed). These files have no layout, so they can't be
  sampled or de-identified. **Names in them stay real** (e.g. `cnd\names`, `cnd\email`); say so to
  the user. Copy any program or proc in the folder too, so it still runs once the folder is
  redirected.
- **Program folders** (a data folder that also holds the app's programs, e.g. QSMRP's `cop\` and
  `bcp\`): don't redirect the folder; step 5 redirects their data files one by one. Copy only the
  non-program files (not `.br`, `.brs`, `.wb`, `.wbs`, `.bro`, `.prc`).
- **Leave in production any program-folder file whose name is the start of a program's name**
  (e.g. data file `bcp\unibarf` and program `bcp\unibarfm.br`, or `cop\ebmxcode` and
  `cop\ebmxcode.br`), together with its key files. Its `SUBSTITUTE` would also redirect the
  program, which then isn't found. Report these files to the user.
- Compare names without case: `HIS\ACCUMCHH` and `his\accumchh` are one file on Windows.

**5. Write the `SUBSTITUTE` statements.**
Write them to `context/dev/tools/subs.txt` (create the file if it doesn't exist). Four facts about
how BR applies them decide the design. They aren't in br_tree (see `context/ERRORS.md`) and were
confirmed on the kit's 4.33c executable with `FILE$`:
- the from-text matches **anywhere** in a path, including the start of a longer name;
- **every** matching entry is applied, **in order, each to the previous one's output**;
- matching ignores case;
- an entry that changes nothing does not stop a later entry from matching.

So a plain pair per folder (`SUBSTITUTE ard\ context\app\test\ard\`) is not enough. It would also
rewrite `reports\standard\…` to `reports\standcontext\app\test\ard\…`, and turn `cod\his\…` into
`context\app\test\cod\context\app\test\his\…`. Write `subs.txt` in four ordered parts:

1. **Protect.** Search the app tree's folder names, and the paths in its source (`OPEN`, `RUN`,
   `EXECUTE`), for a data-folder name that ends a longer folder name or sits below another data
   folder. Rewrite each to a placeholder spelling that no entry matches. QSMRP needed
   `standard\` (contains `ard\`), `save.this\` and the subfolders `cod\his\` and `obd\his\`
   (contain `his\`), and the SFTP folders `download\` and `upload\` (contain `oad\`).
2. **Redirect data folders** to the placeholder `@T@`. Two entries per folder: `/dir` for the
   `name/dir` form and `dir\` for the backslash form.
3. **Redirect program-folder files** (step 4), also to `@T@`, one `name/dir` entry per file. For
   the backslash form, list only the shortest name of a group: `cop\window` already redirects
   `cop\window.key` and `cop\window2`, and a second entry would rewrite that output again.
4. **Restore.** `@T@` becomes `context\app\test\`, then each placeholder becomes its real text.

```
SUBSTITUTE standard\ st@nd@rd\
SUBSTITUTE cod\his\ cod\h@s\
SUBSTITUTE /ard /@T@ard
SUBSTITUTE ard\ @T@ard\
SUBSTITUTE /cod /@T@cod
SUBSTITUTE cod\ @T@cod\
SUBSTITUTE interchg/cop interchg/@T@cop
SUBSTITUTE cop\interchg @T@cop\interchg
SUBSTITUTE @T@ context\app\test\
SUBSTITUTE h@s\ his\
SUBSTITUTE st@nd@rd\ standard\
```

Put a `!` comment at the top of `subs.txt` saying the order matters. The `to` paths are handed to
BR, so they resolve from **BR's start folder**, not the kit root. If STEP 1 recorded a prefix for
that folder in `context/README.md`, put it in front of `context\app\test\` in the restore entry.
See [`dev/BR_launch.md`](../dev/BR_launch.md#start-folder).

**6. Include `subs.txt` in the configs.**
Append this line to the end of each config file in `context/dev/tools/` — `brconfig.sys`,
`brconfig.ai_user` and `brconfig.ai_util`:

```
include subs.txt
```

`INCLUDE` in a config file resolves relative to the file that contains it, so it finds
`context/dev/tools/subs.txt`. See
[`config-directives`](../br_tree/00-configuration/config-directives/spec.md).

When STEP 1 regenerates `brconfig.ai_user` and `brconfig.ai_util` from a changed `brconfig.sys`,
append the `include subs.txt` line to them again.

**7. Verify.**
Run a short headless BR program (`$BR_AI_UTIL`) that opens files through their normal app names
and prints `FILE$(n)` for each to a debug file. When an `OPEN` fails, the LOGGING file's
`Opening file …` line shows the path BR actually tried. Check all of these:
- one file from each redirected data folder, in both the `dir\name` and `name/dir` forms: each
  must resolve inside `context\app\test\`;
- each protected path from step 5 (e.g. a file under `reports\standard\`): it must resolve to its
  real production path, unchanged;
- a subfolder of a data folder (e.g. `cod\his\…`), and a program-folder data file: test;
- a program in each program folder, and each file step 4 left in production: production.

`STATUS SUBSTITUTE` lists the active entries. If any data file resolves to production, or any
other path is changed, stop and fix `subs.txt` before going on.

**8. Free the test data for the assistant, where the site uses `brrestrict.sys`.** A `WORK` line
there names a tree a restricted session may change, and that an AI turn does not ask about. Name
`context\app\test` and nothing else:

```
WORK :C:\ADS\qsmrp\context\app\test
```

Where `brrestrict.sys` lists areas, the `WORK` tree must be inside one of them. Never name the main
data, even with STEP 9 skipped: a `WORK` tree lets the assistant overwrite what is in it without
anybody being asked. Add the `WORK` line and nothing else: **areas in `brrestrict.sys` limit every
BR session run from that executable, the users' own included**, so an area line here could stop
the application reaching its programs or data. A file holding only `WORK` lines limits nothing. See
[`dev/ai_access/AI-Restricted-Operations.md`](../dev/ai_access/AI-Restricted-Operations.md#work-trees).
The file is the site administrator's: ask the user before writing it.

<a id="step-10"></a>
### STEP 10 — Build the application's test suite ◆ needs the user to choose programs and check drafts

This step gives the application tests of its own, in `context/app/tests/`, that one command runs
unattended: screen tests of its programs, and function tests of its libraries. Each test runs in a
BR of its own and passes or fails by itself. How each kind of test is written is in
[`dev/BR_testing.md`](../dev/BR_testing.md) §3.1 and §4, and every step a script can take is in
[`dev/ai_access/README.md`](../dev/ai_access/README.md#4-uitest-a-screen-test-script) §4; read
both before starting.

**Which data the tests use.** Look at the "Test data is" line in `context/README.md`, which STEP 9
fills in.
- **STEP 9 built `context/app/test/`:** the tests run on it, because `brconfig.ai_test` (part 1)
  is made from `brconfig.ai_user`, which includes `subs.txt`.
- **STEP 9 was skipped:** the tests run on the application's main data, as its test data. Tell
  the user once more, before the first test runs, that every test reads that data and that the
  scripts and baselines will hold whatever names it contains. A test that changes data changes it
  for good, because `--restore` (part 4) restores one folder and the main data is many: write
  tests that only read - inquiries, reports, function tests - and add one that writes only when
  the user agrees.

**1. Write the test configuration, `context/dev/tools/brconfig.ai_test`.** Copy
`brconfig.ai_user` and append the lines below. It must stay in `context/dev/tools/` beside the
others: BR resolves each `include` against the folder the configuration is in, and a copy anywhere
else loads no `subs.txt`, saying so only at log level 8.
- **A stub for the program a finished program goes to.** Most programs end by chaining to the
  application's menu, and the menu waits for input, or for a login, so BR never ends and the test
  fails. Find the target in the source (`CHAIN` statements, in every spelling the source uses:
  QSMRP has `chain "Menu"`, `"MENU/Cnp"`, `"MENU/CNP"`) and turn it into the stub of part 2:
  ```
  SUBSTITUTE menu/cnp context\app\tests\endtest
  ```
- **Print that a test can compare, and no print window.** Print preview and a printer-selection
  dialog wait for a person. Read the printer `SUBSTITUTE` lines in `brconfig.sys`, and send any
  that ends in a preview or a `select` to plain printing instead; keep a copy of every print file
  for `expect print`:
  ```
  PRINTDIR context\scratch\print +CHANNEL RAW
  SUBSTITUTE preview: DIRECT:
  SUBSTITUTE /select /default
  ```
- **`OPTION 83`, if the programs under test run shell commands** (`EXECUTE "SYSTEM ..."`). While a
  test is attached BR asks the person before each one, and a script may not answer.

Paths handed to BR resolve from BR's start folder: give them the prefix STEP 1 recorded in
`context/README.md`. When STEP 1 regenerates `brconfig.ai_user`, make `brconfig.ai_test` again.

**2. Write the stub, `context/app/tests/endtest.brs`,** a program of one statement:
```
00010 ! test stub for the main menu: a program under test that chains to the
00020 ! menu ends the session here instead, so the test ends cleanly
00030    execute "system"
```
Check it with `brls -check -sema`. Confirm the stub is reached: a test of any program that ends
by chaining to the menu must end with BR's exit code 0.

**3. Name the application's own error window, in `context/app/tests/uitest.settings`.** A
program with an `on error goto` block shows its own window when an error happens, and BR reports
nothing on the channel, so `expect no error` cannot see it. Find the application's shared error
routine in the source, and the text its window always shows, and write it as a `trap`:
```
# QSMRP's shared Trap: block shows "Error nnnn occurred at line nnnnn" in its own
# window, which BR does not report on the channel.
trap "occurred at line"
```
If the programs have no error routine of their own, leave the file out.

**4. Snapshot the test data,** when STEP 9 built it, with no BR using the files:
```
"$BR_MCP_DRIVER" testdata snapshot context\app\test
```
The snapshot is `context\app\test.snapshot`, as large as the folder. `--restore` puts the data
back from it before every test, so each one starts from the same data. With STEP 9 skipped there
is no snapshot (see "Which data the tests use").

**5. Choose the first tests with the user.** Propose four to six, using `architecture.md` and the
data model, and ask the user to confirm or change the list:
- an **inquiry** screen: what a customer or item shows, read from the test data;
- a **report**: its print, compared with a baseline;
- a **library function** with no screen: a function test;
- an **entry or maintenance** screen, only with a snapshot (part 4): what it saves, read back
  from the file;
- the screen a **missing record** leads to (an unknown key, an empty list).

**6. Write each screen test as a pair** in `context/app/tests/`: `<name>.prc`, which starts the
program, and `<name>.uis`, the script. Give each procedure a port no other test uses, and a log
of its own, first, so that a failure can be read from that run's lines alone (`uitest` quotes it):
```
! uitest --suite: custlist - arp\custlist, the customer list report
CONFIG LOGGING 10, context\app\tests\results\custlist-br.log
PROCERR RETURN
LET X=MSG("harness",8783)
LET X=MSG("grant",300)
! the report prints the run date: fix it
DATE 03/15/24
TIME 09:30:00
RUN arp\custlist
SYSTEM
```
Fix the date and time, as here, for a report that prints them.

**If the program quits at once** - `uitest` says the channel opened and BR then ended - it is
probably checking that the menu started it. Find the check near the program's start and satisfy it
in the procedure before `RUN`, as [`dev/BR_testing.md`](../dev/BR_testing.md#uitest-app) §4.2
describes (QSMRP's `arp\custafm` needs `LET SETENV("LOGNAME","root")`). Ask the user when the check
needs something only the menu can give.

**To see an unfamiliar screen,** run a short script with `screen` after each key before writing
any `expect` lines. Then draft the script by recording it while the user drives the program
once:
```
"$BR_MCP_DRIVER" uitest --record context\app\tests\<name>.uis --start context\app\tests\<name>.prc --config context\dev\tools\brconfig.ai_test
```
When the keys are already known, `--feed "CH620{F10}{F9}{F9}"` sends them instead of the user.
Then make the draft a test:
- **Correct every `press`.** The draft says `ENTER` for every key a person typed, because the
  channel does not report keys; ask the user which key it was (`F10`, `F9`...).
- **Keep the `expect` lines that matter** - the title, the values the test is about - and drop
  the rest.
- **Add what a screen cannot prove:** `expect screen <name>.txt` for the whole screen, `record`
  steps for the file behind it, `expect print <name>.txt` for a report, with `mask "<regexp>"` for
  a clock or a workstation number.
- **End the script by taking the program to its end**, then `expect no error` and `wait end`.

Take every expected value from the data the test runs on, never from production names: STEP 9's
names are de-identified.

**7. Write a function test for one library,** `context/app/tests/<name>.test.brs`, with the kit's
assertion library ([`dev/BR_testing.md`](../dev/BR_testing.md#function) §3.1):
```
00010 ! Function tests for glp\fy_calcs, the fiscal period calculations.
00020    library "context\dev\ai_access\brtest": fnTestNum,fnTestDone
00030    library "glp\fy_calcs": FNDEFINE,FNCCYY
00040    let FNDEFINE
00050    let fnTestNum(FNCCYY(99),1999,"FNCCYY(99)")
00060    let fnTestDone
```
State what each result should be from what the function is for, as the user describes it, not
from what it returns today.

**8. Run the suite until every test passes.** Check every program with `brls -check -sema` first.
With STEP 9's data:
```
"$BR_MCP_DRIVER" uitest --suite --restore context\app\test --config context\dev\tools\brconfig.ai_test
```
With STEP 9 skipped, leave out `--restore context\app\test`. The first run writes each baseline
(`expect screen`, `expect print`) and says so: look at each one, and show the user. The results,
each test's whole output and a picture at each failure, are in `context\app\tests\results\`.
- **A failure in the test** (a wrong key, an expected value the data does not hold): fix the
  script.
- **A failure in the program:** keep the test as it is, say in its header comment that it is
  expected to fail and why, report it to the user, and record it in `context/ERRORS.md` if it is
  in BR or the kit. Measured in QSMRP: `arp\custlist`'s test found the program freeing its work
  file through a channel opened `INPUT`, which BR refuses with error 4151; the program was fixed,
  and the test passes.

Run it again after a change to a program, a library or the configuration; it is meant to be run
often.

<a id="step-11"></a>
### STEP 11 — Survey brls vs real BR ⏱ typically long-running (30–60 minutes)

brls's own diagnostic rejections (which findings mean "BR will actually reject this") are calibrated
against BR itself, not asserted — but that calibration was checked against the programs brls was
developed on, not necessarily against *your* application's source. We need to check each app-specific 
construct BR happens to tolerate, or reject, to be sure our language server handles all code patterns. 
STEP 11 checks that calibration for your app specifically. 

`context/dev/tools/loadsave.exe` and `context/dev/tools/lscheck.exe` are two independent survey
programs, prebuilt and deployed the same way `brls.exe` is (`context/lsp/brls/build.ps1`) — nothing to
build on-site, run them directly, the same as `extract-schema.exe`/`gen_datamodel_index.exe` in STEP 4.

**Run both from the app root** — the directory the kit (`context/`) was installed into, one level above
`context/` itself — **not from inside `context/dev/tools/`.**

`-root` is the only location flag either tool takes: the directory to recursively scan for `.brs`
program source (where the suite of BR programs live), which both tools also assume `context/` is
installed directly inside of — it's how each locates the BR executable/`brconfig.ai_util` (`loadsave`
only) and how every file path in the report gets made relative. `-root .` means "the app root is the
current directory," which is exactly why these must be run from there.

**Run `lscheck` first** — fast, pure brls, no real BR involved; gives an immediate baseline:

```
context/dev/tools/lscheck.exe -root . -out context/app/BRLS_test.md
```

**Then run `loadsave`** — drives the real BR executable one process per batch of files, whole-file
`LOAD`/`SAVE`. This is the long-running half: **budget 30–60 minutes** for an application-sized tree
(QSMRP's ~1,100 files took ~24 minutes; scale roughly linearly, and confirm with the user before
running against a much larger tree — see `context/app/second-corpus-load-validation.md` for why a
flat multi-thousand-file harvest needs a different, sampled approach instead of this whole-file sweep).

```
context/dev/tools/loadsave.exe -root . -out context/app/BR_test.md
```

**Compare the two reports' Summary tables.** `BR_test.md`'s "Load and save clean" count should match
(or come very close to) `BRLS_test.md`'s "Clean + advisory only" count — the two are meant to describe
the same thing, real BR's own opinion and brls's opinion of the identical file set. See
`context/app/br-load-save-validation.md` for a worked example of a clean match and how it was verified
file-for-file, not just by comparing the two totals.

**If the two counts disagree, do not silently accept it and do not try to fix brls's rules yourself as
part of onboarding** — a miscalibrated brls rule is a `brls` repo change, not an app-code change, and
fixing it requires the same real-BR confirmation discipline `br-load-save-validation.md` Instead, 
**append a discrepancy report to `context/ERRORS.md`**, covering:

- The two summary counts (BR's "Load and save clean" vs brls's "Clean + advisory only") and the gap.
- The file-level diff between the two reports' failing-file lists: which files brls flags that BR
  loads/saves clean (candidate brls false positives), and which files BR fails that brls calls
  clean/advisory (candidate brls blind spots) — group by the rule/error each side cites, the same
  grouping both reports already carry.
- For each group, a first-pass guess at cause: a genuine brls miscalibration worth reporting upstream,
  or app-specific noise (non-production scratch files, dev tools, misfiled non-BR text) that belongs in
  this app's own excluded-files list instead — see `br-load-save-validation.md`'s "Excluded —
  non-production files" section for the shape of that judgment call.

If the counts already match, no `ERRORS.md` entry is needed for this step.

---

<a id="done-criteria"></a>
## Done criteria

- [ ] `context/app/env.cmd`, `context/app/env.ps1` and `context/app/onboarding/setx.cmd` written (STEP 1). The user was
      asked whether the kit will be used in more than one repo on this machine: if not, `setx.cmd`
      was run and the user told to restart VS Code; if so, it was not run. Either way, the "BR
      environment variables are" line in `context/README.md` is filled in.
- [ ] Source currency audited (STEP 2): every `.br`/`.wb` passed, or its source was decompiled or
      listed in `context/app/STALE_SOURCE.md`, before layouts were cross-checked and
      exemplars/conventions derived.
- [ ] `filelay/` exists (found or synthesized per STEP 3), one layout file per data file, in
      Appendix A format — no guessed field layouts; any file without a locatable FORM/DIM source
      was flagged to the user instead.
- [ ] `context/app/data-model.md` regenerates cleanly from `filelay/` (0 unparsed files).
- [ ] `context/app/exemplars/` holds ≥10 annotated, representative programs across task archetypes.
- [ ] `context/app/conventions.md` states each rule and points to an exemplar that shows it.
- [ ] `context/dev/BR_launch.md` lets a newcomer build, run, test, and deploy without asking.
- [ ] `context/app/architecture.md` names entry points and the core data flows.
- [ ] `APP-DEV-GUIDE.md` has terse pointer rows to every app doc (conventions/BR_launch marked
      always-load; data-model/exemplars/architecture on-demand); `topics.json` left as the language router.
- [ ] `context/br_tree/` and `context/dev/` are **unchanged**, except the `APP-DEV-GUIDE.md` pointer
      rows, `dev/tools/subs.txt`, and the `include subs.txt` line in each `dev/tools/brconfig.*`.
- [ ] STEP 9 either skipped, with the user warned that it is required at a customer site and the
      "Test data is" line in `context/README.md` saying the main data is the test data; or built:
      `context/app/test/` has one sub-folder per data folder, each
      file sampled (greater of 10 % or 100 records) with its key files rebuilt, name fields
      de-identified per the user-confirmed `DEIDENTIFY.md`, the rest of each data folder copied
      whole, `dev/tools/subs.txt` written as protect / redirect / restore, and the step 7 checks
      passed: data names resolve inside `context\app\test\`, and protected paths and programs don't.
- [ ] STEP 10 test suite built: `context/dev/tools/brconfig.ai_test` with the menu stub and print
      settings; `context/app/tests/` holds `endtest.brs`, `uitest.settings` when the app has its
      own error window, and the tests the user chose, each draft's keys corrected; a snapshot of
      `context/app/test` when STEP 9 built it; and `uitest --suite` passes every test, except any
      the user agreed is failing because of the program, each marked so in its header.
- [ ] STEP 11 ran to completion: `context/app/BR_test.md` and context/app/BRLS_test.md` both exist; their summary
      counts were compared, and any discrepancy is recorded in `context/ERRORS.md` (not silently
      fixed or ignored).

<a id="feedback-loop"></a>
## The feedback loop (why this works)
With STEP 4 (real schema) plus a compile pass in BR itself (`.brs` → `.br`), generated code is
**verifiable**: it can be checked against the actual files and the grammar before it ships. "Style"
then includes "compiles against our data model," not just "looks right."

<a id="maintenance"></a>
## Maintenance
- If a data file is added or its layout changes, update `filelay/` (STEP 3) first, then re-run STEP 4.
- Re-run STEP 4 after any `filelay/` change.
- Re-run the STEP 2 audit after recompiling, and handle any **stale** or **suspect** program as
  STEP 2 says before you re-derive exemplars or conventions. A source up to 15 minutes older than its
  `.br` is normal.
- Refresh exemplars when the house pattern for an archetype changes.
- Language corrections go to `context/br_tree/` and flow to **every** app — never fork them into `context/app/`.

---

<a id="appendix-a"></a>
# Appendix A — the `filelay` file format

STEP 4 consumes a **`filelay/`** directory: one plain-text layout file per data file, describing its
keys and field record layout. If your application's data dictionary is in some other form, convert it
to this format and place the results in `filelay/`. This appendix is the complete spec.
(Source: FileIO Library, `br_tree/50-libraries/fileio/`.)

<a id="filelay-anatomy"></a>
## Anatomy

Each layout file has three parts in order: a **header** (data file + keys + optional `recl`), a
**divider**, then the **field definitions**. Columns on every line are comma-separated; extra spacing
is cosmetic and ignored, except that `recl=` and the divider should start in column 1 (see
[Divider](#divider)).

```
 price.dat, PR_, 1                         ← data file, subscript prefix, version
 price.key, FARM                           ← key 1
 price.ky2, ITEM                           ← key 2
 price.ky3, FARM/ITEM/GRADE                ← key 3 (composite)
 price.ky4, DESCRIPTION-U/COST             ← key 4 (DESCRIPTION segment case-insensitive)
recl=127                                   ← optional record length (column 1)
===================================================    ← divider (column 1)
 FARM$,          Farm Code (or blank),        C 4,                 , 1 -   4, 1 $
 ITEM$,          Item Code,                   C 4,                 , 5 -   8, 2 $
 GRADE$,         Quality,                     C 4,                 , 9 -  12, 3 $
 X,              Empty,                       X 37,                ,13 -  49
 PRICE,          Default Price,               BH 3.2,              ,50 -  52, 1
 (blank line after every 5th field row)

 ! comment lines start with ! and are ignored anywhere
 COST,           Default Cost,                BH 3.2,              ,53 -  55, 2
 EFFDATE,        Effective Date,              BH 3,    Date(days)  ,56 -  58, 3
 DESCRIPTION$,   Description of Price Rule,   C 30,                ,59 -  88, 4 $
 #eof#                                         ← optional; everything after is ignored
 additional comments...
```

<a id="filelay-header"></a>
## Header lines

**Line 1 — `<data-file>, <PREFIX_>, <version>`**
- `<data-file>` — the data file name on disk (e.g. `price.dat`).
- `<PREFIX_>` — a short string prefixing every field's subscript name, so identically-named fields in
  different files stay distinct (`PR_PRICE` vs. `RT_PRICE`). Chosen per file.
- `<version>` — integer file-layout version. **Start at 0; increment by 1 on every layout change.**
  FileIO compares this to the on-disk file's version and auto-migrates data when yours is higher
  (backing up the old layout to `filelay/version/<name>.<n>`). Field data is copied by subscript name,
  so **never rename an existing subscript** — a rename reads as drop-old + add-new and loses that
  field's data. Rearranging fields, adding/removing fields or keys, and changing `recl` are all safe.

**Key lines — `<key-file>, <keydef>`** (zero or more, one per index)
- `<key-file>` — the index file name on disk (e.g. `price.key`, `price.ky2`).
- `<keydef>` — the key's composing field(s), given as **subscript names from this layout**:
  - A single field → simple key.
  - Multiple fields joined by **`/`** → composite key, concatenated in the given order. FileIO derives
    the BR `KPS=`/`KLN=` (position/length) from the fields' positions, so order matters.
  - A suffix on a field name sets that segment's BR key modifier, which FileIO carries into `KLN=`:
    - **`-U`** → the segment is **case-insensitive**: BR keeps it upper-cased in the index. The only
      suffix that also changes the key FileIO builds for a read.
    - **`-Y`** → the field starts with a **two-digit year**, which BR compares using `BASEYEAR`.
    - **`-YB`** or **`-YP`** → the same, for a year stored as a number: **`B`** for a binary (`BH`)
      field, **`P`** for packed decimal (`PD`). `B` and `P` are not suffixes on their own; they go
      with `Y`. (BR accepts either alone, but all it does then is exempt the segment from the file's
      `COLLATE` translation.) BR takes the date's format from the field's length: `PD 2` or `BH 1` is YY;
      `PD 3` or `BH 2` is YYMM; `PD 4`, `BH 3`, `BH 4`, `DT 3`, `DT 4`, `DL 4` or `DH 4` is YYMMDD.
    - BR reads these letters in any order and either case, so `-BY` and `-PY` are the same as `-YB`
      and `-YP`; this app writes `-YB`.
    - A `-Y` segment without `B` or `P` is a text date: it must hold digits, `/` or spaces, or BR
      gives error 4120 ("invalid data for year 2000 key").
    - Example: `VendorName(1:8)-U/FiscalYear-YB`. (Sources: `br_tree/30-io-file/keys-indexes/`,
      `INDEX.md` and `Index_Facility.md`; BR's own source, `getkeyflags` and `process_key_flags`.)
  - Subscript name may be followed by `(<start>:<end>)` to denote a BR substring.
- As many keys as you like; parsing stops at the first non-key header line.

**`recl=<n>`** (optional) — record length used when a file is created or upgraded. If omitted, it is
computed from the field FORM specs. Start it in column 1, for the reason given under
[Divider](#divider).

<a id="filelay-divider"></a>
## Divider

A line of `=` characters separates the header from the fields. The line itself is skipped, but it is
what ends the header, so it is required. **Start it, and `recl=`, in column 1.** FileIO's open reader
trims these lines, but its other readers (`FNREADLAYOUTARRAYS`, `FNMAKESUBPROC` and the version-backup
routine) test the first characters as they stand:
- An indented divider is never found, so those readers take every field line as header and stop with
  "Incomplete Layout." That breaks CSV export, the DataCrawler and layout migration.
- An indented `recl=` is skipped by the array readers, but the version-backup routine copies it as a
  key line named `orecl=…`, which corrupts the saved layout in `filelay/version/`.

`extract-schema.exe` follows FileIO: it does not recognise either line when indented. It also lists
every such layout on its `indented recl=/divider` output line so it can be fixed. An indented divider
also gives `total fields: 0` and a `no-field-parse` entry.

<a id="filelay-fields"></a>
## Field definition lines

One line per field, in **on-disk order**. Comma-separated columns.
Note that only the first 3 columns are required.

| Col | Meaning | Rules |
|----:|---------|-------|
| 1 | **Subscript name** | Append `$` for string fields; nothing for numeric. Gets the header `PREFIX_` in code. Must be unique and stable (see versioning). |
| 2 | **Description** | Human label; also DataCrawler column heading and ScreenIO default caption. Keep ≤ ~80 chars. |
| 3 | **FORM spec** | A BR FORM type + size, e.g. `C 4`, `BH 3.2`, `PD 5`, `N 6`. Type **`X`** = filler: the field is ignored except that its length still advances the disk position of later fields. Full FORM type list: `br_tree/30-io-file/form-spec/`. |
| 4 | **Disk date format** *(optional)* | `DATE(days)`, `DATE(cymd)`, `DATE(ymd)`, `DATE(mdy)`, etc. — marks the field as a date in that storage format (enables DataCrawler/ScreenIO/CSV date handling; your program still unpacks it). **Any col-4 text that isn't `DATE(...)` is treated as a comment and ignored.** The `DAYS()` specification refers to BR's DAYS() system function, which returns the number of days since December 31, 1899; not a `YYDDD` ordinal date. `DATE(days)` means the same with this kit's FileIO or Screenio. `DATE(serial)` is **not** a day number here. Any other text inside `DATE(...)` is taken as a `DAYS()` mask. Details: [FileIO — Disk date formats](../br_tree/50-libraries/fileio/spec.md#disk-date-formats). |
| 5 | **Positions** *(recommended)* | `start - end`, the 1-based inclusive byte range of the field in the record, e.g. `13 - 49`. Documentation for humans and for cross-checking the FORM sizes; it is one of the "comments" columns the parser ignores. **Column 4 must be present (empty if the field is not a date) so this lands in column 5.** |
| 6 | **Subscript** *(recommended)* | The subscript number FileIO assigns to the field on OPEN, followed by ` $` for a string field, e.g. `4 $` or `2` — see [Subscript numbers](#subscript-numbers). **Gap rows (`X`) have none.** Also documentation only. |
| 7+ | **Comments** | Ignored. |

<a id="filelay-comments"></a>
## Comments, blanks, and end-of-file

- A line whose first non-space character is **`!`** is a comment — allowed anywhere, ignored.
- **Blank lines** are ignored. By convention the field rows are grouped in fives: **one blank line after every 5th field row** (counting `X` gap rows), restarting at the first row after the divider, and none after the last row. This is purely visual, for readability.
- An optional **`#eof#`** line after the last field ends parsing; anything below it is ignored (free
  space for notes).

<a id="filelay-subscripts"></a>
## Subscript numbers

Column 6 records the subscript number FileIO assigns each named field when the file is OPENed, so
hard-coded field subscripts in existing code (`F$(7)`, `F(3)`) can be read back to field names, and
migrated to the FileIO subscript names.

- **Two independent sequences, each starting at 1.** String fields (name ends in `$`) are numbered
  1, 2, 3… among the strings; numeric fields 1, 2, 3… among the numerics. The number is assigned in
  the order the rows appear in the layout (FORM order), not by byte position.
- **The ` $` suffix** follows the number on every string-field row (`6 $`) and is absent on numeric
  rows (`6`). It tells you which array — `F$()` or `F()` — the number indexes.
- **`X` rows take no subscript and are not counted.** A gap row's field name is exactly `X` (FORM type
  `X`). A named filler such as `UNUSED` or `UNUSED2$` is a real field: it is numbered like any other.
  Use `X` for a gap only where no subscript is wanted; where the original system numbered a filler,
  keep it as a named field of its real type.
- **Repeated fields are written out.** `4*C 30` becomes four rows (`SPEC1$`…`SPEC4$`), one per
  subscript, so the numbers stay correct.
- **Exception — layouts whose programs are wired to the original order.** For files loaded out of
  order by legacy programs (in this app `invoiceh`, `invoicel`, `invcdelh`, `ihisth`, `ihistl`) the
  column carries the subscript numbers the existing code uses, not the FileIO-assigned ones, because
  its purpose is interpreting that code. Say so in such a file when you do this.

<a id="filelay-conversion"></a>
## Conversion checklist (other dictionary → filelay)

1. One file per data file, in a `filelay/` directory; header first.
2. Line 1: data-file name, a unique `PREFIX_`, version `0`.
3. One key line per index; join composite fields with `/` in physical order; add `-U` to
   case-insensitive segments; use the layout's subscript names, not raw positions.
4. Add `recl=` if you know it (else let FileIO compute it).
5. `====` divider.
6. One field line per field **in disk order**: `NAME[$], description, FORM-type size, [DATE(...)],
   start - end, subscript[ $]`. Column 4 stays present (empty) when there is no date format.
   Represent gaps/reserved bytes as `X <length>` (name `X`, no subscript) so positions stay correct.
7. Number subscripts per [Subscript numbers](#subscript-numbers): strings and numerics separately,
   from 1, `X` rows skipped; put ` $` after each string number.
8. Insert one blank line after every 5th field row.
9. Keep subscript names stable across versions forever.
