---
alwaysApply: true
---

# Business Rules — application development guide

This is the capstone for this context kit. It stitches the language reference, the built-in function
catalog, and the schema-extraction tooling into one starting point for writing correct **Business Rules!
(BR)** code — whether you're a developer onboarding to a BR codebase or an LLM acquiring
context. Each section says **where the authoritative detail lives** so this stays a map, not
a duplicate. It is application-agnostic: point the tooling at whatever BR app you're working
on.

Please document any errors in context/ERRORS.md. This includes any inaccuracies *or ambiguities* found (within the context folder) while using this kit. Let the user know when you post something to ERRORS.md so users can forward the report to ADS. 

---

## Models Start here — by task type

**Don't load the whole kit**; for one program it's mostly ballast. **[`topics.json`](topics.json) is the
entry point for reading or writing BR code:** it routes a keyword to its anchored
[`statement-semantics.md`](statement-semantics.md) section (with a line range, so you load ~5–10k,
not the whole file) and carries the `lexicon` — the classified inventory of which spellings are
reserved. The path is **`topics.json` → `statement-semantics.md` → [`../br_tree/`](../br_tree/)** (the
authoritative backstop), pulling in the catalogs and your app's data-model as needed.

For access to the Business Rules compiler:
1. Read BR_launch.md to extract the environment variable definitions
2. Extract the PowerShell snippet that sets $env:BR_EXE, $env:BR_AI_UTIL, etc.
3. Execute those environment variable assignments before attempting any BR invocation
4. Use those variables in subsequent commands (e.g. $VAR_NAME in Bash)
5. See section 6 below for advice on how to run BR and identify program errors.

The language axis has **two parallel keyword indexes** — use whichever fits the token:
- **[`topics.json`](topics.json)** for statements/clauses — fast, line-ranged semantics + the `lexicon`.
  This is the default for reading or writing statement code.
- **[`brtree-index.json`](brtree-index.json)** for *any* BR keyword — config directives, screen
  controls, printing, functions, commands — or to jump straight to the authoritative spec. Its
  `keyword_index` maps a token to its br_tree spec path(s) + anchors: **`brtree-index.json` →
  `../br_tree/<spec>/spec.md#<anchor>`**. It complements `topics.json`; it does not replace it.

Both are generated, never hand-edited: line ranges go stale as soon as their source changes. After
editing `statement-semantics.md` (or `tools/lexicon.json`), run `context/dev/tools/gen_topics.exe`;
after editing a br_tree `spec.md`'s frontmatter, anchors or opening paragraph, run `context/dev/tools/gen_brtree_index.exe`.
Either tool given `--verify` checks its index against the source without writing anything: it
prints `VERIFY OK` when they match, and otherwise lists what is out of step and exits 1.

| Task | Start with | Then pull in |
|---|---|---|
| **Interpret / debug** — read existing BR | `topics.json` → `statement-semantics.md` | [`system-functions-catalog.md`](system-functions-catalog.md), [`error-reference.md`](error-reference.md), the app data-model (§4) |
| **Coding** — write correct, idiomatic BR | `topics.json` → `statement-semantics.md` | the two catalogs + data-model, closed by a fast **`brls -check -sema`** pass (§6 — `-check` alone is per-line and will not tell you a block is still open) then the authoritative **`LOAD … source`** syntax check in BR (write→check→fix; §6) |
| **App design** — architecture, data model, modules | [`../app/architecture.md`](../app/architecture.md) + generated **data-model** (§4) + [`../app/conventions.md`](../app/conventions.md) | br_tree concept leaves — [`file-model`](../br_tree/30-io-file/file-model/spec.md), [`library-facility`](../br_tree/50-libraries/library-facility/spec.md), [`screenio`](../br_tree/50-libraries/screenio/spec.md) |
| **Testing** — validate behaviour headlessly | headless BR (§6) | syntax-check via `LOAD "<prog>.brs" source`; run programs and procs headlessly through the BR invocation |
| **Watching a program run** — screens, fields, listviews, a ScreenIO screen, anything interactive | [`BR_launch.md` — Live sessions](BR_launch.md#harness-launch) to start one, then [`BR_harness.md`](BR_harness.md) | the `guide` tool first, then [`ai_access/README.md`](ai_access/README.md) for the driver and [`ai_access/AI-Access-Protocol.md`](ai_access/AI-Access-Protocol.md) for the protocol |

**Which of those last two you want:** headless BR runs a program and leaves you its output —
a log, a file, a CSV — and cannot show you a screen. The harness attaches to a **live BR 5.0
session** and reads the screen, the fields, the cursor and a listview's rows while the program
is still running, and can type into it. If the thing you need to know is "what is on the glass
right now", it is [`BR_harness.md`](BR_harness.md) and not §6.


*Why `topics.json` and not a flat keyword list: BR's lexicon is **positional** — only system
functions are reserved against variable names, so telling a keyword from a variable needs the
`lexicon` block, not a keyword table. And the decision itself is made by **arity**, not by a
symbol table: see
[name resolution](../br_tree/10-language/syntax/spec.md#name-resolution), which is also why
declaring a name never shadows an intrinsic.*

### The app layer (after onboarding)

The above is the **language axis**. Once a codebase is onboarded (see
[`../app/ONBOARDING.md`](../app/ONBOARDING.md)), a third layer under [`../app/`](../app/) carries
*this application's* specifics — reached **directly**, not through `topics.json` (which stays a
language keyword router; app conventions/architecture aren't keyword-addressable):

- **Always-load** when reading or writing this app's code:
  - [`../app/conventions.md`](../app/conventions.md) — house coding style (naming, error handling, FileIO-vs-raw-OPEN idiom)
  - [`BR_launch.md`](BR_launch.md) — BR launch environment + build / run / test / deploy commands
- **On-demand** (pull the one you need):
  - [`../app/data-model.md`](../app/data-model.md) — file schemas & key composition; look up **by file** (generated — §4)
  - [`../app/DATA-MODEL-NOTES.md`](../app/DATA-MODEL-NOTES.md) — measured RLN/record counts/versions and layout history that the generated model can't show
  - [`../app/architecture.md`](../app/architecture.md) — module map, entry points, core data flows (orientation)
  - [`../app/exemplars/`](../app/exemplars/) — blessed real programs; pick **by archetype** and imitate
  - [`../app/examples/`](../app/examples/README.md) (optional, created as needed; its README says which scripts are safe to run in this app) — throwaway scripts that show **how a technique
    was done** (e.g. writing a ScreenIO screen's records from code, as
    [`screenio-guide.md`](screenio-guide.md) §9 refers to). They are verified to work but are
    **not** house style: never imitate them as you would `exemplars/`. They are kept in a separate
    folder so they don't dilute that signal.

The `app/` files above are generated/written during onboarding and are app-private (git-ignored) — a
fresh kit skeleton won't have them yet. `BR_launch.md` is the exception: it lives in `dev/` (this
file's directory), is part of the tracked kit, and is application-agnostic.

---

## 1. How a BR codebase is shaped

BR is a line-numbered Business BASIC. Programs are `.brs` source, compiled to tokenized `.br`, and run inside the BR runtime. Systems are commonly multi-user.

BR apps converge on a few conventions worth recognizing:

- **Module directories** group programs by function (admin/menus, printing/output, the data
  modules, etc.). Learn the target app's layout — there's no fixed standard, but related
  programs and their data files usually sit together.
- **Program-name suffixes** often signal a program's role: `…fm` = file-maintenance screen,
  `…f` = file-maintenance utility, `…p` = print/report, `…e` = entry/input, `cvt/` =
  upgrade-conversion utilities. (Conventions vary per app — verify against the codebase.)
- **`filelay/` (or similar)** holds the **data dictionary**: text schemas describing each
  data file's fields, FORM types, and key composition. This is the single best source for
  the data model — see §4.

---

## 2. The reference map — what to open for what

| You need… | Go to |
|---|---|
| A statement's behavior / semantics / side effects / error clauses | [`topics.json`](topics.json) routes to the right [`statement-semantics.md`](statement-semantics.md) section (anchor + line range); each topic links to br_tree for depth |
| Full syntax, edge cases, version notes, related concepts | the [`../br_tree/`](../br_tree/) language reference tree (authoritative; the semantics file's See-also links land here) |
| Which br_tree spec documents keyword `X` — across *all* topics (config, screen, printing, functions, commands), not just statements | [`brtree-index.json`](brtree-index.json) `keyword_index` maps a BR keyword to its spec path(s); each spec record carries its anchors + a one-line summary. Complements `topics.json` (which is statement-centric) |
| Is `X` a keyword or a variable? Which words are reserved | [`topics.json`](topics.json) `lexicon` — the classified inventory; only system functions are reserved, every other keyword is positional (a variable may reuse its spelling) |
| Built-in (system) functions (`STR$`, `CNVRT$`, `SRCH`, …) | [`system-functions-catalog.md`](system-functions-catalog.md) — the full `table6k∪table7k` roster with signatures |
| App library / UDF signatures | index the **target app's own** `DEF LIBRARY`/`DEF FN` source — not the corpus (its UDFs are confidential) |
| Standard libraries (FileIO, ScreenIO, JSON) | [`library-catalog.md`](library-catalog.md) (signatures) → [`../br_tree/50-libraries/`](../br_tree/50-libraries/) for full docs |
| **How ScreenIO actually compiles and runs** — the Helper Library compile pipeline, runtime event dispatch/screen-stack mechanics, writing/compiling screens programmatically | [`screenio-guide.md`](screenio-guide.md) — internals; complements the calling-convention reference in [`../br_tree/50-libraries/screenio/`](../br_tree/50-libraries/screenio/) (read that first for "how do I call/write a screen") |
| Error code meaning (for diagnostics) | [`error-reference.md`](error-reference.md) (70 curated, with fixes) → [`../br_tree/90-reference/error-codes/`](../br_tree/90-reference/error-codes/) (all 773) |
| Edit an existing `*.br.brs` / `*.wbs` source file that holds **CP437** bytes (window-frame `data` tables) — `Edit` / `Write` corrupt them | [`BRSAFE.md`](BRSAFE.md) — run `brsafe check <file>` first; if it flags the file, read with `brsafe view` and edit with `brsafe replace` |
| **This app's** data model (files/fields/keys) | [`../app/data-model.md`](../app/data-model.md) — generated by §4 (`tools/extract-schema.exe`); look up **by file** |
| **This app's** coding conventions (house style) | [`../app/conventions.md`](../app/conventions.md) — *always-load* when writing app code |
| **This app's** build / run / test commands + BR launch env | [`BR_launch.md`](BR_launch.md) — *always-load* |
| **This app's** architecture (modules, entry points, data flows) | [`../app/architecture.md`](../app/architecture.md) — orientation, on-demand |
| **This app's** worked examples to imitate | [`../app/exemplars/`](../app/exemplars/) — blessed real programs; pick **by archetype** |

---

## 3. Language essentials you must get right

Moved to [`essentials.md`](essentials.md) — the language rules that bite newcomers (and LLMs
trained on other BASICs), **plus a growing set of runtime gotchas confirmed empirically** while
actually RUNning BR programs - built-ins that didn't behave as expected, and more. Read it before writing or debugging any BR code; per-statement detail
stays in [`statement-semantics.md`](statement-semantics.md) indexed by [`topics.json`](topics.json),
full detail in the br_tree reference.

---

## 4. Working with data files

### Get the schema first

A BR data file is a fixed-length keyed record store; you need its field layout and key
composition before reading it. The app's `filelay/` (or equivalent) directory is the data
dictionary. Turn it into a structured model with the bundled tool:

```
context/dev/tools/extract-schema.exe <path-to-app/filelay> context/app
context/dev/tools/gen_datamodel_index.exe
```

Run both from the app root, like every invocation in [`BR_launch.md`](BR_launch.md). The second
argument to `extract-schema.exe` is where `data-model.md` is written — always pass `context/app`.
Without it the file goes to `context/dev/`, and `gen_datamodel_index.exe` (which only looks in
`context/app/`) will index an old copy or none at all.

This produces `data-model.md` for *that* app: per file, the data path,
record length, each key index **with its composing fields** (the order you concatenate to
build a `KEY=` lookup), and every field's FORM type/position. No app's data model is bundled
here — generate the one you need. (No `filelay/`? Convert your data dictionary to the filelay format —
see [`../app/ONBOARDING.md`](../app/ONBOARDING.md) Appendix A — then run the tool.)

`data-model.md` is large. `gen_datamodel_index.exe` builds `data-model-index.json` beside it — a
per-file map to 1-based inclusive line ranges (the same sharding `topics.json` gives
`statement-semantics.md`). **Don't load the whole data model:** look the file up in the index and
read only its line slice. Re-run the indexer whenever the model is regenerated.
`gen_datamodel_index.exe --verify` checks the index against `data-model.md` without writing
anything: it prints `VERIFY OK` when they match, and otherwise lists what is out of step and exits 1.

### Read records (raw BR keyed I/O)

Open a keyed file, build the composite key from the schema, read by key or scan to EOF. A
record's layout comes from a **named `FORM`**.

Worked examples — keyed read and sequential scan — are in the `OPEN`/`READ` sections of
[`statement-semantics.md`](statement-semantics.md#read). Adapt the file name, key layout, and `FORM`
to your data model. Key construction is positional concatenation in schema order (e.g. a 3-field key
= field1 + field2 + field3, each padded to its width).

### Or use a file-access library

Many BR apps wrap raw I/O in a library layer (the standard **FileIO** library, or an app's
own access functions). Prefer the codebase's established layer for new code so it matches
surrounding programs — find the candidates in the **app's own library source** and the FileIO
reference under [`../br_tree/50-libraries/fileio/`](../br_tree/50-libraries/fileio/).

<a id="inspecting-actual-data-values"></a>
### Inspecting actual data values, not just schema

`data-model.md` gives a file's *shape* (fields, keys, positions), not what is stored in it. Don't
decode an `INTERNAL` file from a hex dump: `V` strings and packed `BH`/`PD` numerics are easy to
misread. Read the records with a BR program that uses the file's `FORM` (§4 above), or, if the app
uses **FileIO**, export them with its `fnCsvExport`, which decodes the real on-disk format:

```
def library fnCsvExport(Layout$*64;DialogType,Filename$*300,IncludeRecNums,KeyNumber,StartKey$,KeyMatch$,Startrec,mat Records,SearchMatch$,Launch,___,SearchNow$,OkToRun)
```

That is the signature in this kit's copy of FileIO ([`tools/fileio.brs`](tools/fileio.brs) line
1753). An app's own FileIO copy may differ, so check its source. Every parameter is described in
[FileIO_Library §fnCSVExport](../br_tree/50-libraries/fileio/FileIO_Library.md#fncsvexport).

**Headless, pass `DialogType=1` and nothing else.** In this copy of the source:

| `DialogType` | What it opens |
|---|---|
| `1` | Nothing: uses `Filename$`, or generates a name when it is blank. No completion message. |
| `3` | No file dialog, but a column-picker screen (`fnSelectDataCrawlerCols`, line 1868) |
| `0`, `2`, other | The `fnCsvExportDlg` file dialog (line 1764), then an `"Export complete!"` `MsgBox` |

Anything that opens a screen or a `MsgBox` stops an `UNATTENDED` run with "Input attempted in
unattended mode". Two more things to know:

- Leave `Launch` at 0. When it is set, FileIO runs `sy -C -M start` on the CSV to open it in the
  OS's default program (line 1772).
- If the output file can't be opened, `fnExportToCSV` shows a `MsgBox` even with `DialogType=1`
  (line 1951). So a run that stops at an input wait here may mean a bad `Filename$`.

A minimal caller is `library "fileio" : fnCsvExport` followed by
`let fnCsvExport(Layout$, 1, OutFile$)`. To reuse it across files without editing it, read
`Layout$` and `OutFile$` with `LINPUT` and feed them from a proc
([`BR_launch.md`](BR_launch.md#run-a-program-with-proc-fed-input)). ScreenIO's own
`screenio.dat`/`screenfld.dat` are FileIO files, so the same method works for them
([`screenio-guide.md`](screenio-guide.md#investigating) §7).

---

## 5. Screens, printing, web library

- **Screens**: ScreenIO drives interactive forms; persisted definitions live in the binary
  `screenio.dat`/`screenfld.dat`, edited within BR/ScreenIO itself — never hand-edit those files. A
  screen's event `DEF FN…` code is compiled **into** the screen, so after editing an event function you
  **recompile the screen** (not the event source alone).
  Reference: [`../br_tree/50-libraries/screenio/`](../br_tree/50-libraries/screenio/) for the calling
  convention; [`screenio-guide.md`](screenio-guide.md) for the internals — how a screen actually
  compiles into a Helper Library, the runtime event-dispatch/screen-stack machinery, and how to
  write or compile a screen programmatically (no Designer UI) via `fnCompileScreen`.
- **Printing**: `PRINT #n, USING form:` to an opened print file; PCL/PDF detail in
  [`../br_tree/40-io-printing/`](../br_tree/40-io-printing/).
- **web integration**: BR has JSON and web-integration facilities —
  [`../br_tree/60-integration/`](../br_tree/60-integration/). 

---

## 6. Running BR (headless, via procedures)

### 6.1 Syntax pre-check (`brls.exe`, standalone)

[`$BRLS_EXE`](tools/brls.exe) (defined in [`BR_launch.md`](BR_launch.md)) is a standalone BR
**syntax checker**. It does not invoke BR, so it avoids the operational hazards in §6.3 (no splash
delay, no WSID slot, no keyboard-focus theft), needs no config file, and requires no BR license.

Currently brls.exe is early release. So, while it has been thoroughly lab tested, 
there is nothing like real world testing. So please report (in context/ERRORS.md) any br syntax 
failures that it doesn't detect along with any false positives.

**Scope boundary (read once):**
1. `-check` reads **one line at a time**. It catches everything that makes a single line bad BR, and
  nothing that takes a second line to see.
2. What it therefore misses is **not only names**: block pairing spans lines, so a `FOR` with no
  `NEXT`, a `DO` with no `LOOP`, a block `IF` with no `END IF`, a `DEF` with no `FNEND`, and a
  closer with nothing open are all invisible to a bare `-check` — even though real BR refuses to
  LOAD every one of them. `-check`'s own clean sentence says as much.
3. `-check -sema` adds that whole-file pass: block pairing, plus undefined names, argument counts,
  unresolved `LIBRARY` links and reserved-name misuse. Single-file — cross-file linkage needs the
  editor's workspace.
4. Therefore clean `-check` means "no bad lines", clean `-check -sema` means "no bad lines and no bad
  file", and the authoritative gate is still real BR: `LOAD <prog>.brs source`, then `SAVE` or
  `REPLACE` (see §7, step 6).

**VS Code's BR diagnostics are not `brls`.** The "BR Language Server" extension
(`crs-dev.vslang-br`) runs its own bundled checker, `server\br-lsp.exe`, a separate third-party
program (`github.com/christopherroyshields/br-lsp`). It has its own table of built-in function
signatures and does not use this kit's data. Where it and `brls` disagree, go by `brls -check
-sema`, then by real BR `LOAD … source`.

Known false positive, in 0.1.22: its table knows only `MSG("KB", <string$>)`, so every correct
`MSG("sleeptime", <milliseconds>)` is flagged "Expected string argument at position 2, got numeric".
Report further ones to that project, not in `context/ERRORS.md`, unless `brls` agrees with them.

**Before trusting a `brls`/`LOAD ... source` failure, check whether this app uses Lexi** — a
preprocessor some BR shops write source for (`/* */` comments, `X$&=`, `#Select#/#Case#`, and
more — full syntax in [`essentials.md`](essentials.md#1-core-language-rules)). Neither `brls` nor
base BR understands Lexi syntax, so a file using it will show false syntax errors in both — that's
not a bug in the source. Check `../app/conventions.md` (once onboarded) for whether *this* app
uses it; if it does, use the **Lexi-aware coding loop** below instead of running `brls -check` on
the raw source — the loop immediately below assumes plain BR and needs that substitution for a
Lexi-using app.

**Required AI Coding loop:**
1. Edit file using `-next` as needed.
2. Run cat <program-line> | `$BRLS_EXE -check -`
3. Fix findings.
4. Repeat until brls reports "no line-level syntax errors" — a per-line verdict, which is all a
  single piped line can be given.
5. Loop to code the next program statement.
6. After each subroutine or function is coded:
    `$BRLS_EXE -check -sema <program.brs>`
   This is the step that closes the blocks: step 2 cannot tell you that a `FOR`, `DO`, block `IF`
   or `DEF` you opened is still open, so never read a clean step 4 as a clean program.
7. Fix findings.
8. Close with real BR `LOAD ... source` plus `SAVE` or `REPLACE`.

#### Lexi-aware coding loop

For a file confirmed to use Lexi, substitute this loop for the one above — translate before every
syntax check, and never run `brls`/`LOAD ... source` against the Lexi-flavored source directly,
only against its translated output:

1. Edit the `.brs` file (Lexi syntax is fine — that's what it's written for).
2. Translate it headlessly: `dev\tools\lexi-compile.ps1 -Source <file.brs> -OutFile
   <tmp-translated.brs>` (parameters in [`BR_launch.md`](BR_launch.md#the-lexi-preprocessor)). A
   translation failure here (the script throws) means Lexi itself rejected something — e.g. a
   `#Select#` with no matching `#End Select#` — fix that before going further.
3. Run `brls -check` (and `-sema`) against the **translated** file, not the original — this is now
   plain BR, so `brls`'s diagnostics are meaningful again. Fix findings in the *original* `.brs`,
   then repeat from step 2 (translation is cheap; don't hand-edit the translated temp file, it'll
   just be regenerated).
4. Once clean, either let `-Compile` finish the job (`lexi-compile.ps1 -Source <file.brs>
   -Compile`), or save the file in VS Code with the "BR Language Server" extension installed —
   both run the identical underlying Lexi engine, so either is a legitimate way to produce the
   final `.br` (mechanism:
   [`br_tree` — Lexi](../br_tree/00-configuration/installation-tooling/Lexi.md#mechanism)).
5. Close with real BR's own gate regardless: `LOAD <the-compiled-or-translated-file> source` (or
   trust step 4's `-Compile`, which already does this) — same discipline as any other BR program,
   per §7.

**Editing existing BR source — CP437 safety:** `*.br.brs` / `*.wbs` source is stored as
**CP437**; some files carry high-bit window-frame `data` tables that `Edit` / `Write` / `MultiEdit`
corrupt, because they re-encode the whole file as UTF-8 (this happens even when your edit is
ASCII and nowhere near them). Run `brsafe check <file>` first — if it exits `1`, read with
`brsafe view` and edit with `brsafe replace`, never `Edit` / `Write`. See [`BRSAFE.md`](BRSAFE.md).

All examples assume the application working directory that [`BR_launch.md`](BR_launch.md) expects for
`$BR_EXE` and related tools. `$BRLS_EXE` is set the same way. 

#### 6.1.0 `$BRLS_EXE` Command capability matrix

| Mode | Purpose | Exit code | Notes |
|---|---|---|---|
| `-check <file> [more files]` | Parse BR syntax **one line at a time**; one `file:line:col: message` block per file, each bad line with a `see:` pointer into `br_tree/` | `0` all lines clean, `1` any parse error | Primary automation flag. `-` reads stdin. Every positional argument is checked in one invocation — batch, don't loop. Blind to anything spanning lines: see the `-sema` row |
| `-sema`  | Adds brls's whole-file findings, prefixed `error:`/`warning:` — **block pairing** (`FOR`/`NEXT`, `DO`/`LOOP`, block `IF`/`END IF`, `DEF`/`FNEND`, and closers with nothing open) as well as undefined names, argument counts, … | folds into `-check`'s code — only an `error:` finding flips `0`→`1` | Single-file only; NA to cross-file `LIBRARY` links. Exit `1` if error detected. Block pairing is error-severity and fails LOAD in real BR, so this is not an optional extra on a program you intend to run |
| `-json` - Structured json output: array of `{file, clean, diagnostics[]}` (`line`, `col`, `severity`, `rule`, `message`) | same as underlying mode | Exit code 1 if not `clean`, decides pass/fail - (`clean: true` can accompany a warning). Exit `1` if combined with any other mode failure |
| `-next '<partial line>'` | Legal continuations at the end of a partial statement | always `0` | Safe to call speculatively; never signals failure |
| `-keyword <NAME>` | Class, token subscript, abbreviation, spec/topic pointers | `0` found, `1` unknown | One block per class for a spelling in several tables (e.g. `DISPLAY`) |
| `-stats` | Embedded language-pack summary (statement/keyword/function/error-code counts) | `0` | Sanity check after picking up a new build |
| `-version` | Print build version | always `0` | Quote in any brls defect report |
| *(no flags)* | LSP transport (JSON-RPC over stdin/stdout) for editors | N/A — blocks on handshake | **Never** run this from a script or agent shell |
| *(unrecognized flag)* | usage text to stderr | `2` | A `2` means bad invocation, not a diagnostic result |

**Ordering:** a mode flag must appear before the first positional file/path argument. `-check a.brs -json`, `-json -check a.brs`, `-sema -check a.brs` all work; `a.brs -check` does not (it falls into LSP mode).

**Output stability:** prose output is human-oriented and may change between builds. Script against the exit code, plus the stable anchors `file:line:col:` and `brls: ` (hard stderr errors); prefer `-json` when the result must be parsed.

#### 6.1.1 Examples

```bash
$ "$BRLS_EXE" -check cnp/compare.br.brs            # every line clean
cnp/compare.br.brs: no line-level syntax errors (-check reads one line at a time; block pairing — a FOR, DO, block IF or DEF that never closes — and the name checks need -sema)
$ echo $?
0

$ printf '100 OPEN #1: "NAME=X"\n110 CLOSE #1: WAITEQ\n' | "$BRLS_EXE" -check -
<stdin>:1:22: unexpected end of statement; expected DISPLAY, EXTERNAL, INTERNAL or SQL
    see: .../br_tree/10-language/syntax/spec.md#syntax
<stdin>:2:15: unexpected "WAITEQ" after the end of this statement
    see: .../br_tree/10-language/syntax/spec.md#syntax
$ echo $?
1

$ "$BRLS_EXE" -check somefile.brs -sema
somefile.brs:1:18: warning: A appears twice in this parameter list
    see: .../br_tree/10-language/flow-control/functions-udf/spec.md#parameters
somefile.brs:4:11: error: FNFOO is not defined in this file and no LIBRARY statement links it
    see: .../dev/system-functions-catalog.md

$ "$BRLS_EXE" -next 'OPEN #1: "NAME=X", EXTERNAL '
statement: OPEN
complete:  false
keywords:
  , INPUT    clause of OPEN               br_tree/30-io-file/file-model/spec.md
  , OUTPUT   clause of OPEN               br_tree/30-io-file/statements/spec.md
  , OUTIN    clause of OPEN               br_tree/30-io-file/statements/spec.md
operands:  (none)

$ "$BRLS_EXE" -next 'OPEN #1: "NAME=X", EXT'
statement: OPEN
complete:  false
keywords:  (narrowed to those "EXT" can still become)
  EXTERNAL   clause of OPEN               br_tree/30-io-file/file-model/spec.md
operands:  (none)
as typed:  Left as it stands, BR reads "EXT" as the EXTERNAL clause — this
           keyword takes any non-empty abbreviation. What may follow
           EXTERNAL:
  , INPUT    clause of OPEN               br_tree/30-io-file/file-model/spec.md
  , OUTPUT   clause of OPEN               br_tree/30-io-file/statements/spec.md
  , OUTIN    clause of OPEN               br_tree/30-io-file/statements/spec.md

$ "$BRLS_EXE" -keyword CLOSE
CLOSE  (statement, table3k[3])
  abbreviates to   CL  (in a table lookup; any prefix where a syntax tree expects it)
  spec             br_tree/30-io-file/statements/spec.md
  topic            close
  documented as    CLOSE — Finalize file
```

#### 6.1.2 Reading the results

1. **`-check` exit code is the verdict**, not the presence of output — and it is a verdict on the
  *lines*. Plain `-check` spells that out on a clean file precisely so its result is not over-read
  as a verdict on the program: an unclosed `FOR`, `DO`, block `IF` or `DEF` will not LOAD in real
  BR and does not show up here. Add `-sema` for those and for the name checks.
2. **An empty `-next` keyword list is not "done."** `keywords: (none — nothing else is valid here)`
  prints whenever no *keyword* fits, even when BR still owes a non-keyword operand (`LINPUT #10:`
  still needs a string variable; `READ #1,KEY="X",RESERVE ` still needs a `:`). `complete:false` is
  the only signal that more input belongs there, and no field says *what* — fall back to
  the `br_tree/` spec.
3. **A `-next` line ending mid-word gets two answers, and both are true.** `keywords:` is
  narrowed to what the typed prefix can still *become* — BR matches a clause keyword on any
  non-empty prefix — and the header says so. A prefix that can reach nothing is reported as
  *ruled out*, not as absent, and names what the position would otherwise admit: `(none — no
  clause of CLOSE begins with "xr"; without it: WAIT=, FREE, DROP, RELEASE)`. Operands are never
  narrowed: a half-typed word may still be becoming a variable name, so `operands:` stays the
  answer to "what kind of thing goes here".
  Below them, `as typed:` is the other true answer: what may follow that word taken as
  **finished**, because BR needs no more of it. It names the reading first — `Left as it stands,
  BR reads "fr" as the FREE clause`, or `"f" is a complete name here, not a clause keyword` —
  since the list under it is true only of that reading. So `close #1, fr` may grow into FREE *and*
  is already FREE, and `, RELEASE` and the closing `:` may equally be typed next; `00020 close
  #1,fr:` LOADs. `complete:` answers for this reading, which is why `chain A$,xxx,f` is complete:
  `f` is a variable name. Where the word could still become something else, the sentence says
  which — `rewrite #1, r` is read as RESERVE and notes that REC= and RELEASE continue
  differently.
  **The section appears only where the abbreviation is real.** Most clause keywords match on any
  non-empty prefix, but the eight positioning keywords — `PRIOR`, `LAST`, `KEYONLY`, `FIRST`,
  `NEXT`, `END`, `SAME`, `LINK=` on `READ`/`RESTORE`/`DELETE`/`REWRITE` — must be spelled in full
  (see [statements](../br_tree/30-io-file/statements/spec.md#no-abbreviation)). `read #1, keyo`
  therefore offers KEYONLY under `keywords:` and prints no `as typed:` section, because as it
  stands the line does not LOAD — real BR gives error 1024, "missing colon".
4. **Confirm abbreviations with `-keyword`**, don't infer them from source or assume the shortest
  intuitive prefix — BR's abbreviation minimums are table-driven.

### 6.2 How to Execute BR

Before running BR check the BR configuration file (specified in [`BR_launch.md`](BR_launch.md)) to see where the `LOGGING` 
output file is located. This will need to be interrogated after your batch run to see how the program 
ended. The log level should be set to 8 or greater.

When interrogating the configuration file take note of the first `DRIVE` statement **to see what folder 
BR starts in**. Paths you hand to BR (the startup `PROC`/`RUN`, proc lines) resolve from that folder,
not from the kit root you launch in. If the two differ, prefix kit paths as recorded in
`context/README.md` rather than `CD`-ing away from the app's start folder (see
[`BR_launch.md`](BR_launch.md#start-folder)).

You can write a `.prc` procedure containing the commands you want and run it through the BR invocation 
described in [`BR_launch.md`](BR_launch.md).

Use a BR config with **no auto-launch of the app menu** (`brconfig.ai_util`), so BR runs your initial
command (e.g. `PROC <procname>`) unattended; [`BR_launch.md`](BR_launch.md) covers creating such an "AI access" 
config from the normal app `brconfig.sys`.  When BR runs unattended, it exits as soon as it stops. 
Then check the log file to what caused BR to stop. This may take a little investigation to 
understand how to efficiently interrogate the log file. Tip- grep based on date and time after you see
how it is formatted.

**Reading the log — don't regard "failed"/"error" text as final:** at `LOGGING` level ≥8 BR traces
routine internal retries that contain those words on operations that still *succeed* — e.g. an
`OPEN … REPLACE`/`USE` logs `"...failed during CreateFile...system error 2"` for an
open-existing-first probe even when the file is then created fine. Grepping for `error`/`failed`
alone over-reports. Instead:
- Confirm the **actual outcome** — did the file end up with the expected content, did the program
  reach its own final `STOP`/`PRINT`/log marker — not just the presence of alarming-looking text.
- The unambiguous fatal signal in `UNATTENDED` mode is **`"Unattended processing terminated by
  error <n> while processing..."`**, which names the real error number and the line it happened at.
  `"Input attempted in unattended mode"` is usually a symptom arriving *after* an earlier untrapped
  error (see [`essentials.md`](essentials.md) §2) — trace backward from it, don't treat it as the
  root cause line.

| Task | How (BR, headless) |
|---|---|
| **Syntax-check** a program | `LOAD "<prog>.brs" source` — parses line-by-line, halts on the first error with `ERR`/`LINE` set. The **`source`** keyword is required (`LOAD` defaults to object). |
| **Run** a program | `RUN "<prog>"` If running attended, end the proc with `EXECUTE "system"` so BR exits instead of waiting at READY. |
| **Run** an interactive program with scripted input | In a proc: `RUN <prog> PROC`, followed by one answer line per input statement, then `SYSTEM`. Launch it with `PROC <that proc>`. `PROCIN` returns 1 only in this form. Worked example: [`BR_launch.md`](BR_launch.md#run-a-program-with-proc-fed-input). |
| **Read / maintain data** | Write a short BR program/proc that `OPEN`s the file (layout from `data-model.md`) and `READ`/`REWRITE`/`WRITE`s it — the kit has no external query tool. |
| **Decompile** `.br` → `.brs` | a proc of `LOAD "<prog>.br"` / `LIST >"<prog>.br.brs"` pairs, ending `EXECUTE "system"` (see [`../app/ONBOARDING.md`](../app/ONBOARDING.md) STEP 2). |

A proc is just BR commands, one per line, ending in `EXECUTE "system"`; run it with
`"$BR_EXE" 'PROC <path>' -"$BR_CONFIG"` (exact executable and config in [`BR_launch.md`](BR_launch.md)). A command that
errors leaves BR waiting at READY, so keep procs self-contained. File references resolve through the
config's `DRIVE` map — use the **drive-relative** form (`<d>:dir\prog`, *no* leading backslash after the
colon), per [`../br_tree/00-configuration/config-directives/spec.md`](../br_tree/00-configuration/config-directives/spec.md#paths).

### 6.3 Operational hazards of a headless run

These bite the *runner*, not the program, and each one masquerades as something else:

- **Every *non-headless* BR start pays a splash delay (~20s observed) before it does anything.** 
  Budget a generous timeout — **≥90s** — or a perfectly healthy run looks like a hang and gets 
  killed just before it starts working. Note this applies to BRconfig.AI_user not BRconfig.AI_util.
  The splash is **skipped when another BR session is already running**, and a person can dismiss
  it with its button.
- **A headless BR GUI run can steal OS keyboard focus from a live, interactive BR session.** A
  keystroke typed into the real session has been observed landing in the headless one (and the reverse
  is presumably possible). Therefore users should not run production concurrently with AI programming.
- **Force-killing a hung BR process does not cleanly release its workstation (`WSID`) session slot.**
  After a `taskkill -F`, a *later* run can fail during WSID assignment (observed: exit code 99) —
  which reads exactly like a bug in the program you just changed, and isn't. **If a headless run
  mysteriously dies at the assign-WSID stage, suspect a leaked slot from an earlier force-kill before
  you suspect your code.** Letting every run reach its own `EXECUTE "system"` exit avoids this;
  `UNATTENDED` logging (below) is what makes that achievable, since it turns hangs into fast aborts.
  **Exit code 99 is BR's generic exit code after *any* unattended-mode fatal error, not a dedicated
  WSID signal** — confirm a leaked WSID slot by checking the LOGGING file's own `"Unattended
  processing terminated by error <n> while ..."` line (the same authoritative signal §6.2 already
  documents) before assuming a leaked slot. A bad file path handed to `PROC` (e.g. a POSIX-style path
  from Git Bash instead of PowerShell/cmd) produces the identical exit code via a different real cause
  (BR error 4215, "invalid drive reference") — no leaked WSID or force-kill involved.
- **`LIST` regenerates source through the config's `style` directive, so a decompile *restyles* it.**
  Keywords, label case, indentation and comment alignment are normalized to the config (e.g.
  `style indent 3 45 keywords lower labels mixed expressions upper`). A program whose stored source
  used a different style therefore shows a **huge textual diff that is almost entirely cosmetic, not a
  code change** — don't read it as one, and don't hand-"fix" it back.

### 6.4 When something silently fails: how to actually debug it

- Run headless with a `gui off` config and **`UNATTENDED`** logging (above). This turns an
  otherwise-indefinite hang into a fast, logged abort with the offending program and line number —
  the difference between one diagnostic pass and manually killing a stuck process every time.
- Don't assume the reported line number is the *root cause* line — it's where the symptom
  surfaced. Trace backward from there; the actual defect (an un-sized variable, a bad `GOTO`
  target) is often several statements upstream.
- **Plain `PRINT` (no channel) is invisible when driven headlessly through `brnative.exe`** — it
  outputs to the command console, which nothing captures in an unattended/scripted run; 
  an `ON ERROR` handler's `PRINT "Error";ERR` produced no
  visible output at all, making a real failure look like silent success. **Route any diagnostic
  output a headless run needs to see through a file** (`OPEN #n: "NAME=...,REPLACE,EOL=LF",
  DISPLAY, OUTPUT` then `PRINT #n:`), not bare `PRINT`.
- When a documented, spec-correct construct still fails, **isolate it** with a minimal `mini*.brs`
  probe — a handful of lines, one `OPEN`/`PRINT`/`CLOSE` to a debug file — before assuming your own
  program logic is the bug. Several of the gotchas in [`essentials.md`](essentials.md) cost real time
  specifically because the failing construct *looked* like it must be a logic error in the larger
  program, when it was actually a runtime limitation unrelated to the surrounding code. If you find
  that the runtime execution conflicts with the br_tree or semantics specifcations preserve and
  reference the mini program that demonstrates the failure.
- **A symptom disappearing is not proof you found the cause.** Adding statements prior to finding the 
  cause, is equivalent to guessing, which is prohibited by rule #1. 
- **Writing a large BR program? Generate it, don't hand-type it.** Past ~100–150 lines, write a 
  script that emits the `.brs` — without the line numbers to a list and auto-number them
  in one final pass — rather than typing line numbers by hand. Renumbering to insert a line becomes
  problematic, not bookkeeping, and repetitive or derived content (`DATA` blocks, static JSON skeletons)
  can be emitted **from the actual source data** instead of hand-transcribed, which at that scale is a
  real source of silent bugs.

---

## 7. Checklist for writing a new BR program

1. Identify the data files you touch → generate/consult the app's data model (§4) for fields,
   types, and **key composition**.
2. Pick the access pattern → the codebase's file-access library for app code; raw keyed I/O
   (§4 recipes) for standalone utilities.
3. Find existing functions before writing new ones → search the app's own libraries
   (its `DEF LIBRARY`/`DEF FN` source).
4. Follow the codebase's naming and module conventions.
5. Handle every I/O error clause (`EOF`/`NOKEY`/`IOERR`/`LOCKED`).
6. Syntax-check it — `$BRLS_EXE -check` first for a fast iteration loop, then
  `LOAD <prog>.brs source` and `SAVE` or `REPLACE` in real BR (§6) — checking the log before 
  considering it done.
