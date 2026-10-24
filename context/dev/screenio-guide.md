---
title: ScreenIO internals — how a screen actually compiles and runs
file: screenio-guide.md
category: dev
description: The compile-time Helper Library generation pipeline and the runtime event-dispatch machinery underneath ScreenIO's calling convention. Complements the source-derived API reference in br_tree/50-libraries/screenio/ — read that first for "how do I call/write a screen"; this file is about how the machinery under that surface works.
---

# ScreenIO internals

`context/br_tree/50-libraries/screenio/` already has an excellent, source-verified reference for
ScreenIO's **calling convention**: the 21 `DEF LIBRARY` exports of v2.95
([Function Reference](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md)), the
screen/control data schema
([Data Model](../br_tree/50-libraries/screenio/ScreenIO_Data_Model.md)), the full event list with
`ExitMode` constants and handler parameters, and a captured wiki manual
([ScreenIO_Library.md](../br_tree/50-libraries/screenio/ScreenIO_Library.md)). Read those first.

This file covers what those don't: **how a screen actually gets compiled into a runnable program,
and how the runtime dispatches into your code once it's running** — confirmed 2026-09-13 by
reading ScreenIO's own engine source directly (walked through with the engine's original author),
not inferred from behavior.

<a id="contents"></a>
## Contents

- [1. Two halves, one library program](#two-halves)
- [2. Compiling a screen: how a Helper Library actually gets built](#compiling)
- [3. Runtime: the screen stack and library-linkage slots](#runtime-stack)
  - [Hosting several screens as tabs (`run.brs`, distributed with ScreenIO)](#tabs)
- [4. The real trick: subscript constants are generated at runtime via `EXECUTE`](#subscript-constants)
- [5. Special internal function tokens](#internal-tokens)
- [6. The Filter event's exact return-value contract](#filter-contract)
  - [Performance pattern: `RESTORE` in `fnInit_` + `"STOP"` at the boundary](#filter-performance)
- [7. Investigating a specific screen's structure directly](#investigating)
- [8. Child screen controls (the `screen` field type)](#child-screens)
- [9. Authoring a new screen programmatically (writing `screenio.dat`/`screenfld.dat` directly)](#authoring)
  - [The technique is just an ordinary FileIO write, twice](#fileio-write)
  - [Reasoning about control layout and position without the Designer's visual grid](#layout)
  - [Field values to copy from a real minimal screen, not reconstruct from memory](#minimal-screen)
  - [A second archetype: Add/Edit forms, and how they link back to a listview screen](#add-edit-forms)
  - [A third archetype: writing a genuine custom Filter function, and passing `ParentKey$` between screens](#custom-filter)
  - [A fourth technique: a free-floating lookup column, opened once via `fnInit_`/`fnFinal_`](#lookup-column)
  - [Compiling is not optional — and no longer requires the Designer UI](#compiling-from-code)
  - [How the deployed `screenio.br` is built from `design.brs`](#screenio-build)
  - [`fnCheckScreenErrors` — the Designer's "To Do" validation, also callable from code](#check-screen-errors)
  - [A general lesson: exposing an internal function via bare `LIBRARY` linkage skips *all* of the host program's own top-level setup](#bare-library-linkage)
- [10. A Windows dropdown menu bar on a ScreenIO screen (`DISPLAY MENU` + fkey 98)](#windows-menu)
- [See also](#see-also)

<a id="two-halves"></a>
## 1. Two halves, one library program

ScreenIO ships as a single BR library program with two distinct halves:

- **The Designer** — an interactive screen-building UI (place controls, wire up event/validation
  functions, generate a compiled screen). This is what runs if you execute the library program
  directly.
- **The Runtime Engine** — `fnfm`/`fnfm$` and everything underneath them that loads a compiled
  screen, displays it, and drives its events. This is what your own programs link to.

The actual source filename varies by installation — it's commonly `screenio.brs`, but check
`app/conventions.md` for what a specific app calls its own copy (some apps carry it under a
different historical name).

**Screens are data, not code.** A screen's layout, controls, and which function each
event/control points at all live as records in `screenio.dat`/`screenfld.dat`, edited entirely
through the Designer half — see the Data Model reference above for that schema.

<a id="compiling"></a>
## 2. Compiling a screen: how a Helper Library actually gets built

Triggered by the Designer's Save-and-Compile (or "Recompile All Screens"). The compiler:

1. Walks every function reference the screen uses — each control's `Function$` value, plus the
   13 screen-level event slots (Enter through Exit, per the Function Reference's event table) — and
   for each one written as a `{name}` token, resolves it to `function\name.brs` and imports its
   text.
2. **Imports each function file individually through Lexi** (`library "lexi" : fnApplyLexi`,
   translate-syntax-only mode) before splicing it into the output — this is why `function/*.brs`
   files freely use Lexi-only syntax (`#Select#/#Case#`, `/* */`, `&=`, `#Define#`): each one gets
   translated on its own as it's pulled in, not as part of one giant combined pass.
   - A `#include somename` line inside a function file queues `somename` to be imported too —
     this is a **ScreenIO-level directive** handled by the Designer's own import scanner, not a
     Lexi directive.
   - A line ending `!:` (comment-then-continuation, see `essentials.md`) is tracked so a
     multi-physical-line statement in the source function survives the import as one logical
     unit, not split apart.
   - Each imported block is tagged `! Imported From "function\name.brs"` — the marker you'll see
     in every generated `screenio/*.brs` file.
3. **Auto-imports a default handler per screen-level event, if present**: `function/defaults/
   enter.brs`, `init.brs`, `read.brs`, `load.brs`, `write.brs`, `wait.brs`, `locked.brs`,
   `merge.brs`, `mainloop.brs`, `nokey.brs`, `prelist.brs`, `postlist.brs`, `exit.brs` — one file
   per event in the Function Reference's event table, giving a stock/fallback behavior apps can
   rely on or override per screen.
4. **Generates two more pieces as literal printed text** (not copied from a template):
   - `fnCheckStringFunction` — an `IF`/`ELSEIF` chain stating, for every `{name}` the screen
     references, whether that function returns a string or a number (inspected from the
     function's own `DEF` signature). The runtime uses this to pick string vs. numeric dispatch.
   - `fnFunctionSwitch`/`fnFunctionSwitch$`, plus 7 more numbered pairs
     (`fnFunctionSwitch1`..`fnFunctionSwitch7`, each with a `$` variant) — the actual dispatcher
     that takes a `{name}` token and calls the real function. The 8 numbered variants exist
     because up to 8 screens can be open/nested at once — see §3.
5. Writes the whole thing to `screenio/<screenname>.brs` with the compiler's own reserved
   line-number bands (confirmed from source): ~10-300 header/dims, ~1000 the `Main:` driver,
   ~5000+ the imported custom functions, **85000** `fnCheckStringFunction`, **89000**
   `fnFunctionSwitch`. Then compiles it (`LOAD ... source` / `SAVE` or `REPLACE`) to
   `screenio/<screenname>.br`, same as any other BR program.

**Practical consequence** (an app's own `app/conventions.md` may already state this under its own
ScreenIO-specific section — restated here as the general rule regardless): to change a screen's
behavior, edit the relevant `function/<name>.brs` and
recompile the **screen** — never hand-edit the generated `screenio/<screenname>.brs`; it is fully
regenerated from scratch on every compile and any hand edit is silently lost.

**A `function/` file that no screen uses is not, by itself, a defect.** ScreenIO ships example
functions with no screens to go with them, so a `function/` folder normally holds some that nothing
calls. The Designer's **Tools ▸ Orphaned Functions** lists them: `fnPopulateOrphanedFunctions`
(`tools/screenio.brs` line 11925) keeps each `function/` file that no screen references and that
no used function `#include`s. That list is "not used by a screen", not "safe to delete": before
reporting one as dead code, check whether anything else calls it (Tools ▸ Power Search;
[ScreenIO_Library](../br_tree/50-libraries/screenio/ScreenIO_Library.md)).

**This whole sequence is also callable from code, not just the Designer's Load/Save-and-Compile
menu items** — see §9's `fnCompileScreen(ScreenCode$)`, added in ScreenIO v2.93.

<a id="runtime-stack"></a>
## 3. Runtime: the screen stack and library-linkage slots

`fnfm$`/`fnfm` (and the thin wrappers `Fndisplayscreen`, `Fncallscreen$`) all funnel into one
internal engine, `Fnmasterfm$`, which:

- saves/restores a small set of caller state across nested calls,
- pushes the *current* screen's working arrays onto an internal memory stack before loading a new
  one, and pops them back when it returns — this is what lets screen A open screen B open screen C
  without their working data colliding,
- loops back into the screen engine if `ExitMode` comes back `Reload`/`AutoReload`.

Each concurrently-open (nested) screen's compiled Helper Library gets linked into one of **8
library-linkage slots**, tracked by a `LibraryLinkage` variable (1-8) — this is *why* the generated
Helper Library defines `fnFunctionSwitch` for slot 1 and `fnFunctionSwitch1`-`fnFunctionSwitch7`
for slots 2-8: the engine picks which one to call by the current `LibraryLinkage` value, so a child
screen's own events don't get routed into its parent's Helper Library by mistake.

The same nesting depth also drives click routing: every screen's hot-zone (`Fkey`) numbers are
`fnKeyBase + <control index>`, and `fnKeyBase` climbs by 200 for each additional nested screen
(`fnKeyBase = 1500 + 200*LoadedScreenCount`) — so a click that resolves to a number *below* the
current screen's own band always belongs to a screen further up the stack, telling that screen to
exit and hand the click back up, with no geometry/window-focus test involved. This is what makes
"click outside this screen returns control to its parent" work identically whether the child was
opened via an embedded `screen`-type control, a `[SCREENNAME]` button function, or
`#run:fnRun(...)` — see §8 for the full mechanism and the exact source lines.

<a id="tabs"></a>
### Hosting several screens as tabs (`run.brs`, distributed with ScreenIO)

None of ScreenIO's public `DEF LIBRARY` exports build a tabbed launcher directly — that's what
**`run.brs`** is for: a companion library **distributed alongside ScreenIO itself** (not something
one app wrote for its own use) specifically so any ScreenIO app can load screens onto tabs via
`fnRunTabs`/`fnTabs`/`fnRunTab` without reimplementing the mechanism. Confirmed by reading it
directly (`fnRunTabs`/`fn_Tabs$`). Which tabs exist and which a given user sees is naturally
app-specific business logic layered on top of this library-provided mechanism, even though the
library itself isn't — worth its own note under an app's `app/` tier if that logic is non-trivial.
Under the hood it's plain BR window features plus repeated `fnfm$` calls:

1. Open one BR window per tab, each with a `tab=<caption>` clause on the `OPEN` statement —
   `"srow=2,scol=2,rows=...,cols=...,tab="&Caption$&...` — BR's own windowing groups same-parent
   windows opened this way into a native tabbed control. This is a **base BR window feature**, not
   anything ScreenIO adds.
2. Call `fnfm$(Screen$(CurrentTab),...)` targeting the current tab's window as the `Parent_Window`
   argument, same as any other screen call.
3. Detect a tab switch via the `CURTAB` system function (`br_tree/10-language/data-manipulation/
   system-functions/spec.md#screen-query`) — `CURTAB(FirstTabWindow)` returns the window number of
   the now-active tab; search your array of tab window numbers for it to find which screen to run
   next, then loop back to step 2 for the new current tab.
4. Optionally "predraw" every tab's screen into its own window up front (calling `fnfm`/`fnfm$` on
   all of them before the user switches to each), trading startup time for instant tab switching
   later — `run.brs`'s `Predraw`/`DisplayOnly` parameters are this trade-off exposed as options.

<a id="tabs-shared-record"></a>
**Sharing one record across all tabs (`FileLay$`).** By default, each tab's screen reads and
writes its own file, the same as a stand-alone screen. `fnRunTabs`/`fnRunTabs$`/`fnTabs`/`fnTabs$`
also take an optional **`FileLay$`**, a FileIO layout name. When it is given, `run.brs` owns the
record, and every tab edits that one in-memory copy. This is confirmed from the `fn_Tabs$` source
(ScreenIO's `run.brs` dated 2020-10-25 and 2022-05-24). An older `run.brs` whose `fnRunTabs` ends at
`ParentKey$` has none of these parameters.

1. **Read once.** `run.brs` opens `FileLay$` itself, through its local `fnOpen`, which wraps
   FileIO's `fnOpenFile`. It reads the record into `mat F$`/`mat F`, by `Key$` if one is given,
   otherwise by record number (`RecordNum`). If neither is given, it starts from a blank record.
   A key or record that isn't found shows a message box and skips the tabs.
2. **Every tab edits the same arrays.** Each tab's screen is run as
   `fnfm$(Screen$(n),"",…,Usemyf=1,mat F$,mat F,…)`. The key is empty and `Usemyf` is `1`, so
   ScreenIO does not read the file: the screen works directly on the arrays passed in (`Usemyf`,
   `mat Myf$` and `mat Myf` are ordinary `fnfm`/`fnfm$` parameters).
3. **Write once, on exit.** After the tab loop, `run.brs` checks the return value of the screen
   that was active when the user exited. If it is non-empty (the user did not cancel), `run.brs`
   rewrites the record by the saved key or record number.
   With neither, it writes a new record. Then it closes the file.
4. **`AskSaveTogether`** asks one "The data has changed. Do you want to accept the changes?"
   question for all the tabs instead of one per screen.
   - Before the loop, `run.brs` keeps a copy of the record as read, and it compares the arrays
     with that copy on exit.
   - `mat IgnoreStrings` / `mat IgnoreNumbers` list the elements to leave out of that
     comparison.
   - Unchanged means no write. **No** discards the edits; **Cancel** returns to the tabs.
   - The same flag is passed to each screen's `fnfm$` as
     [`SaveDontAsk`](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md), so the
     individual screens don't also ask.

Without `FileLay$`, none of this happens: each screen is called with `Key$`/`RecordNum` and does its
own reading and writing.

This is a genuinely reusable pattern for any ScreenIO app that wants a tabbed main-menu shell; the
*specific* tabs, and which employee sees which, are naturally 100% app-defined business logic —
worth its own `app/`-tier note if a given app's tab-visibility logic is non-trivial enough to
document separately.

<a id="subscript-constants"></a>
## 4. The real trick: subscript constants are generated at runtime via `EXECUTE`

This is the single most important "how does this even work" fact about writing ScreenIO event
code. Names like `cu_code`, `sio_startdate`, `ctl_customername`, `QuitOnly`, `FkeyEsc` are never
`DIM`'d or declared anywhere you can grep for — because they don't need to be.

Before dispatching to a custom function, the engine (`fnGenerateSubscripts`) builds a big array of
literal `"let <name>=<value>"` text strings covering:

- every field of the screen's bound data file, prefixed with that file's own `filelay` prefix
  (`cu_`, `em_`, ... — matches `app/data-model.md`) — these index into **`mat F$`/`mat F`**, which
  ScreenIO reads from disk and populates automatically;
- every field of ScreenIO's own `screenio.dat`/`screenfld.dat` records, under ScreenIO's own
  internal prefix;
- every control that has a **Control Name but a blank Field Name** — a "free-floating" field not
  tied to any data-file column — prefixed `sio_` + the control name, indexing into **`mat S$`**
  (confirmed with the app owner, 2026-09-13). This is what `sio_startdate`/`sio_enddate` in a
  report screen's function actually are, and — the nuance worth getting right — **it's not "every
  control," only the ones with no Field Name set.** A control *with* a Field Name is bound and
  already reachable through `mat F$`/`mat F` via the file's own prefix, same as any other field of
  that file — it doesn't get a separate `sio_` entry too. Unlike file fields, ScreenIO doesn't
  know how to populate an `S$` field on its own — something in the screen's event code (commonly
  the Filter/Read event, e.g. a shared helper function some apps write for exactly this) has to set
  it explicitly, e.g. `let s$(sio_somecolumn)=fnSomeHelper$(...)`. A blank-Field-Name column on a
  listview showing something derived from a real file field (a formatted phone number, a Yes/No
  computed from whether another field is populated, ...) is the normal reason to reach for this,
  rather than binding the column directly to the raw field;
- every control's **identity/property-array index**, prefixed `ctl_` + the control's name (so a
  handler can do `let Invisible(ctl_MyField)=1` to hide a control at runtime) — this one *does*
  apply to every control, bound or not;
- fixed named constants for `ExitMode` values (`QuitOnly`, `SaveAndQuit`, `SelectAndQuit`,
  `QuitOther`, `AskSaveAndQuit`, `Reload`, `AutoReload` — see the Function Reference's table) and
  function-key codes (`FkeyEsc`, `FkeyClick`, `FkeyDblClick`, `FkeyPgUp`/`FkeyPgDn`, arrow keys,
  ...).

Then, immediately before your custom function runs, the engine **`EXECUTE`s every one of those
strings** — which, per BR's own name-resolution rule (an assignment to an undeclared name just
creates it), silently creates each as a live local numeric variable in the calling scope,
initialized to its value. That's the entire mechanism: no compile-time constant table, no
generated `DIM` list — just `EXECUTE "let cu_code=1"` (etc.) run once per screen-load, guarded so
it only happens the first time (not once per event).

**Consequence:** these names only exist *while* a screen's event code is executing, injected fresh
at that moment. Don't expect them outside that context, and don't expect `brls`/base BR to know
about them — an undefined-name warning on one of these from `brls -sema` inside a `function/*.brs`
file is very likely a false positive, not a real bug.

<a id="internal-tokens"></a>
## 5. Special internal function tokens

- `{{SetData}}` / `{{GetData}}` — double-braced markers the runtime uses internally to push/pop the
  full screen-state arrays into/out of the compiled Helper Library's own local scope around a
  custom-function call. You won't write these yourself, but you may see them in engine-level
  traces.
- An ordinary custom function reference is single-braced: `{functionname}`, resolving to
  `function/functionname.brs`.

<a id="filter-contract"></a>
## 6. The Filter event's exact return-value contract

`ScreenIO_Function_Reference.md#events` already documents that a listview's Filter function
"decides whether the current record is added to the list (and its row colour)" — this is the
precise contract behind that, confirmed both by ScreenIO's author and directly in the engine
source (`design.brs`, the inclusion test and the early-exit check on the Filter return value):

- The Filter function is called **once per record** as the file is read for the listview.
- Return **`0`, `""` (blank), or `"STOP"`** → the record is **suppressed** (not added).
  Returning **`"STOP"` additionally halts reading the file** — a real early-exit optimization,
  useful when the file's read order guarantees nothing after this point can match either.
- Return **`1`, `"1"`, or any other non-blank string** → the record **is** added to the list.
- If that non-blank return value happens to be a **valid BR color spec** (e.g. `"/#123456:
  #124324"`, or a named color macro from `BRConfig.sys`/an included file like `color.sys`, e.g.
  `"[BLUE]"`) → the record is added **and rendered in that color** — the "row colour" half of the
  contract, driven by the same single return value as inclusion, not a separate mechanism.

A screen's Filter function can therefore do triple duty from one return value: filter, and
conditionally color-code, in a single expression — e.g. returning a status-derived color string
only for overdue rows, `"1"` for everything else that should show.

**A Filter function can have `fnInit_<name>`/`fnFinal_<name>` companions in the same file**,
running once before/after the whole per-record loop rather than on every record — see
`ScreenIO_Function_Reference.md#events` for the exact naming/truncation rule; confirmed against a
real Filter function that opens a lookup file in its `fnInit_...` companion for a keyed read on
every row, closing it again in `fnFinal_...`. This pairing is optional — plenty of Filter functions
are just the one function, no `_Init`/`_Final`.

This is actually the *newer* of two mechanisms for the same purpose. **The screen-level Listview
Prepopulate/Postpopulate events (`PRELISTVIEWFN$`/`POSTLISTVIEWFN$`) predate `fnInit_`/`fnFinal_`**
and are how older screens got the same one-time setup/teardown; both are fully supported today,
and — confirmed directly against `design.brs`'s `Fnpopulatealllistviews`, not just inferred —
**none of the four (including the `function/defaults/prelist.brs`/`postlist.brs` fallback files
from §2) are a fallback for another; each is checked and run independently.** The verified order
for one listview load:

`defaults\prelist.brs` (if it exists) → `PRELISTVIEWFN$` (if set) → `fnInit_<name>` (if this
screen's listview has a Filter function) → **the listview loads, Filter function once per record**
→ `defaults\postlist.brs` (if it exists) → `POSTLISTVIEWFN$` (if set) → `fnFinal_<name>` (if
present — genuinely last, *after* both postlist calls, not before `POSTLISTVIEWFN$`).

When investigating a screen with a listview, check for all three pairs (the `defaults\` files, the
two screen-level event fields, and the two same-file Filter companions — six checks in total)
before concluding you've found everything that runs around the list load.

<a id="filter-performance"></a>
### Performance pattern: `RESTORE` in `fnInit_` + `"STOP"` at the boundary

A listview bound to a large keyed file doesn't have to scan every record just to show a small,
contiguous subset of it. The pattern (confirmed via a fully-traced real example, 2026-09-13):

1. The screen's **read index** — `screenio.dat`'s own `READINDEX` field, selecting which key of the
   bound file to read by — is set to an index whose key groups the records you want contiguously —
   typically a foreign-key-style index (e.g. a line-items file keyed by its parent header's ID).
2. `fnInit_<name>` does `RESTORE #datafile, KEY>=ParentKey$: NOKEY IGNORE` — jumps the read
   position straight to the first record at or after the target key, via that index, instead of
   starting from the top of the file.
3. The Filter function then reads forward normally. As long as the current record still belongs to
   the target group (e.g. `F$(<foreign-key-field>) = ParentKey$`), it includes the row; the moment
   it reads a record belonging to the *next* group in key order, it returns `"STOP"` —
   simultaneously excluding that record and halting the read entirely (§6's contract).

Net effect: a file with any number of unrelated groups only ever gets read from the target group's
first record through its last — never the records before it, never anything after. Confirmed real
example: a line-items file's Filter function, with `READINDEX` set to the index keyed by the
parent header record's ID:

```
def fnFastFilterLineItems$
   if f$(li_parentid)=ParentKey$ then
      ... format the row ...
      let fnFastFilterLineItems$="1"
   else
      let fnFastFilterLineItems$="STOP"     ! hit the next parent's lines - done
   end if
fnend

def fnInit_FastFilterLineItems
   restore #datafile, key>=parentkey$: nokey Ignore     ! jump straight to this parent's block
fnend
```

<a id="investigating"></a>
## 7. Investigating a specific screen's structure directly

`screenio.dat`/`screenfld.dat` are BR `INTERNAL` files — don't hex-dump them (same rule as any
other data file, see [`APP-DEV-GUIDE.md` §4's "Inspecting actual data values"](APP-DEV-GUIDE.md#inspecting-actual-data-values)
section, including which `DialogType` is safe headless). Since
ScreenIO is itself FileIO-based, the exact same method applies: export both to CSV with
FileIO's `fnCsvExport` and read the result as plain text.

1. Use the app's generic exporter if it has one, or write the minimal caller described in
   `APP-DEV-GUIDE.md` §4: `library "fileio" : fnCsvExport` +
   `let fnCsvExport(Layout$,1,OutFile$)`, with `Layout$` and `OutFile$` read by `LINPUT`.
2. Export **both** files — a screen's own record in `screenio.dat` only has the screen-level
   settings and event-function references; every one of its **controls** is a separate record in
   `screenfld.dat`, matched back by `SCREENCODE`. One proc can run the exporter twice, giving it
   the two `LINPUT` answers each time (`<exporter>` is whatever you named the caller; see
   [`BR_launch.md`](BR_launch.md#run-a-program-with-proc-fed-input)):
   ```
   RUN <exporter> PROC
   screenio
   screenio_dump.csv
   RUN <exporter> PROC
   screenfld
   screenfld_dump.csv
   SYSTEM
   ```
3. Grep both dumps for the screen code (case-insensitive, e.g. `grep -i '^"SOMESCREEN"'`) — the
   `screenio_dump.csv` hit is the screen header (one row); the `screenfld_dump.csv` hits are its
   controls (one row per control, in no particular order).
4. Read the columns against
   [`ScreenIO_Data_Model.md`](../br_tree/50-libraries/screenio/ScreenIO_Data_Model.md) — it names
   every field in both files. Key columns to look at first: `FILELAY` (which data file the screen
   is bound to), the 13 event-function columns (`ENTERFN`...`EXITFN`), and per-control
   `FIELDTYPE`/`FUNCTION`/`PARENT` (a `listchld` control's `PARENT` names the `listview` control
   it's a column of). **Also check `CONTROLNAME` vs `FIELDNAME` on every control**: a non-blank
   `FIELDNAME` means it's bound to that column of the file named in `FILELAY` (reachable in code as
   `F$(<prefix>_<fieldname>)`); a **blank** `FIELDNAME` means it's a free-floating `S$` field
   (reachable as `S$(sio_<controlname>)`, see §4) that something in the screen's own event code has
   to compute and set — don't assume a column showing file-looking data is actually bound without
   checking this.
5. **Decode each `FUNCTION` value** using the prefix rules in
   [`ScreenIO_Function_Reference.md`](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md#function-types):
   `{name}` → read `function/name.brs`; `#libname:call(...)` → an inline call to that library, no
   file to find; `[SCRNNAME]` → a link to another screen (recurse into it the same way if you need
   to follow the flow); anything else is a raw BR statement, read literally (a bare
   `let ExitMode=QuitOnly`/`let ExitMode=SaveAndQuit` on a button is common and needs nothing
   fancier). If you see `#somelib:fnSomething('[SCRNNAME]',...)`, don't assume `fnSomething` is
   doing anything beyond opening a screen — some apps write a thin app-level wrapper around
   ScreenIO's own `fnCallScreen$` (which itself just normalizes `SCRNNAME`/`[SCRNNAME]` and calls
   the same internal launcher a literal `[SCRNNAME]` value would) purely out of house style; check
   the library's source before assuming it does more than that.
6. Delete the full CSV dumps when you're done extracting what you need — they're bulky, disposable
   working artifacts (potentially every screen in the app), not something to keep around. Note
   findings about the specific screen in `../app/` (an app's own `app/screens/<name>.md` is a
   reasonable place — this method itself is what belongs here in `dev/`).

<a id="child-screens"></a>
## 8. Child screen controls (the `screen` field type)

A control whose `FIELDTYPE` is `screen` embeds an *entire other compiled screen* live inside a
parent screen's layout — e.g. a small "currently open time logs" listview screen sitting inside a
bigger form. Confirmed end-to-end by reading the engine source (`design.brs`), cross-checked
against the owner's own description of the observed behavior. This is a real nested `fnMaster$`
call under the hood, not a special widget — same engine, same event lifecycle as any other screen,
just parented into a rectangle on another screen instead of the whole display.

**1. Initial predraw, in Display Only mode, when the parent screen loads.** The parent's own
`Fninitializescreen` calls `fnDrawScreens` (only `if ~Editing`, i.e. only in an actual run, not in
the Designer), which walks every control looking for `FieldType$="screen"` and calls
`fnOpenScreen` for each. `fnOpenScreen` computes a click-target code for the *whole embedded
window* — `ForceIndex = Control + fnKeyBase`, the same code-space used for an ordinary control's
own hot zone — then calls:

```
fnMaster$(ChildScreenName$, Keyval$, Vpos, Hpos, Parent_Key$, Window,
          Display_Only=1, Dontredolistview=1, RecordVal, Path$, ...,
          Active=0, ForceThisIndex=ForceIndex, Editing=~Runtime, ...)
```

`Display_Only=1` and `Active=0` together mean the child's `screenio.dat` `ACTIVECOLOR` is **not**
applied yet (see step 3) — it renders in its ordinary colors.

**`Dontredolistview` is about the *caller's* (parent's) listview, not the child's own** — confirmed
by the owner, and worth stating plainly since the parameter name invites the opposite reading.
Whenever a nested screen exits, ScreenIO's normal behavior is to automatically redraw/repopulate
whatever listview exists on the screen regaining control, because the nested screen might have
edited a record that listview is displaying (the classic case: a listview's Edit button opens an
Add/Edit screen on a selected row; when that editor exits, the listview it was launched from has to
be refreshed to show the change). `Dontredolistview=1` suppresses *that* auto-refresh. Passing it
here on the initial Display-Only predraw makes sense under that reading: a Display-Only screen
can't be edited, so it can never change anything the parent's listview would need to reflect, and
skipping the refresh avoids paying for a repopulate that could never matter. Under the hood this
opens a genuine BR **child window** — `Parent=<parent's window number>` is passed all the way down
to the actual `OPEN` statement (confirmed:
`Fnopenwindow(Row,Col,mat ScreenIO$,mat ScreenIO,Parentwindow,...)`) — so this is a real OS-level
parent/child window relationship, not something ScreenIO fakes by drawing on top of the parent.

**2. Clicking the embedded (still-passive) child activates it.** Because the whole embedded
window's hot-zone code is `Control + fnKeyBase` — the exact same numbering space as any ordinary
control on the parent — a click anywhere on it is delivered to the *parent* screen's own running
`Fnrespondtouseraction` as `Function = Control + fnKeyBase`, resolved to `Control =
Function - fnKeyBase`, whose `FieldType$` is `"screen"`. That dispatches to:

```
#Case# "screen"
   let fnMaster$(FieldName$(Control), Keyval$, VPosition(Control), HPosition(Control),
                 Parent_Key$, Window, 0, 0, RecordVal, Path$)          ! interactive session
   let fnMaster$(FieldName$(Control), Keyval$, VPosition(Control), HPosition(Control),
                 Parent_Key$, Window, 1, 0, RecordVal, Path$, 0, 0, Function)  ! back to passive
```

**3. The first call runs the child screen fully interactively**, `Display_Only=0`. This is a
genuine blocking `fnMaster$` call — it runs the child's own Load/Enter events, populates its
listview, and services its own buttons (an Edit/Delete button on the embedded screen runs its
normal `FUNCTION$`-referenced handler exactly as if that screen had been opened standalone).
Because `fnMakeWindowSpec$`'s active-color test is `(Active or ~DisplayOnly) and
len(trim$(screenio$(si_activecolor))) and ...`, and `Display_Only` is now `0` (so `~DisplayOnly` is
true) regardless of the `Active` flag, **`ACTIVECOLOR` from the child's own `screenio.dat` record
gets applied to the window as its background** the moment it goes interactive — this is exactly
the highlight-to-show-it's-live color the owner described.

**4. Returning control to the parent ("clicking outside") — the `fnKeyBase` stack.** Confirmed by
the owner and by source (`design.brs` lines ~12232-12233):

```
def fnKeyBase=(fnBase+(200*LoadedScreenCount))
def fnBase=1500
```

Every hot zone ScreenIO ever assigns (button, field, or a whole embedded-screen window) is numbered
`fnKeyBase + <that screen's control index>`, capped at 200 controls per screen. `fnKeyBase` climbs
by 200 for every screen currently nested on the stack (`LoadedScreenCount`), so **each deeper
screen's controls occupy a strictly higher numeric band than every screen above it**: the
outermost screen's controls are `1501`-`1700`, a screen it opens is `1701`-`1900`, a screen *that*
one opens is `1901`-`2100`, and so on — regardless of *how* that child got opened (an embedded
`screen`-type control, a button whose function is `[SCREENNAME]`, or `#run:fnRun("ScreenName")`
all end up on the same stack, all get the same next-200-band treatment).

A screen's own `Fnrespondtouseraction` never has to detect "the click landed outside my window" as
a geometry problem — it only has to compare *numbers*:

```
if Function<fnKeyBase and Function>fnBase then
   ! Go back up a level
   ...  ! sets ExitMode (SelectAndQuit / SaveAndQuit / AskSaveAndQuit, per the usual unsaved-changes rules)
end if
```

`Function < fnKeyBase` means the click's code is *below this screen's own band* — it belongs to
some screen further up the stack, i.e. it landed outside the current screen. `Function > fnBase`
(the fixed floor, `1500`) excludes true BR-native Fkeys that aren't part of this numbering at all
(`99` = Esc, `93` = clicking the window's native close/X — both handled by their own explicit
`Function=99`/`Function=93` checks elsewhere in the same routine). Whenever both hold, this screen
sets `ExitMode` and unwinds, handing the click back to be re-processed by whichever screen it
actually belonged to — which is exactly how control returns to the parent when you click outside
the embedded child, with no special-casing for the `screen` field type at all; it's the same
generic "click outside the current level" mechanism every nested screen uses no matter how it was
invoked.

**5. The second call redraws the child passively again, now showing whatever changed.** Once the
interactive call returns, the immediate second `fnMaster$` call reopens the same child screen with
`Display_Only=1` again. This re-opening is an ordinary fresh screen load — like any `fnMaster$`
call, it populates that screen's own listview as part of loading it, the same way step 1's initial
predraw did — so anything edited or deleted during the interactive session simply shows up because
the child is being redrawn from scratch, not because of anything `Dontredolistview` does. This call
passes `Dontredolistview=0`, which looks like it should re-trigger the parent-listview auto-refresh
from step 1 on top of the redraw this call is already doing — but it doesn't, and there's no
inconsistency: **`Display_Only` alone already forces that suppression, independent of whatever
`Dontredolistview` was explicitly passed.** Confirmed at the actual consumer, `design.brs`
~12062-12064 (`Fnmasterfm$`'s unwind path, right before returning to whichever screen called this
one):

```
let Loadedscreencount-=1
if ~Editing then
   if Loadedscreencount then let Fnpopmemory((Display_Only or Dontredolistview or (fkey==93)))
end if
```

`Fnpopmemory` (~15078) is the routine that pops the caller's saved screen state back off the stack
and, unless its own `Dontredolistview` parameter is true, repopulates that now-restored caller's
listview(s) (`if ~Dontredolistview then let Lastrow=Fnpopulatealllistviews(...)`, ~15099). The
value it actually receives is the OR of three things: `Display_Only`, the `Dontredolistview` the
caller passed, and `fkey==93` (window-close/X — no point refreshing anything if the whole thing is
being torn down). Because it's an OR, **`Display_Only=1` by itself is sufficient to suppress the
refresh no matter what `Dontredolistview` was set to** — so step 5's explicit `Dontredolistview=0`
is inert here, not a bug or a missed optimization. This also matches what actually happens on a real
screen using this pattern: the listview does not visibly redraw twice. `Active`
is `0` again and `Display_Only=1`, so the active-color condition is false again and the window
drops back to its normal (non-active) coloring — visually confirming to the user that this portion
of the screen is passive again and the parent is what's really active.

**Net shape:** predraw passive (the screen's own ordinary colors, no `ACTIVECOLOR`, suppresses
parent-listview auto-refresh) → click → activate (interactive, `ACTIVECOLOR` applied, own buttons
run their real handlers) → click outside → interactive session ends (parent-listview auto-refresh
fires, per the standard nested-screen-exit behavior) → redraw passive again from scratch (back to
ordinary colors, shows whatever changed).
Same `fnMaster$` engine as any other screen call throughout — a "screen" control is purely a
*placement and activation* wrapper around it, not a different runtime path.

### Driving a child screen from its parent

Three facts confirmed by ScreenIO's author (2026-10-09) against the `screenio.brs` source, while
designing a parent screen whose embedded child lists the parent record's detail lines:

1. **Pass the child its key through the control's `FUNCTION$` text.** `fnOpenScreen` builds
   `"[" & FieldName$ & "]" & Function$` and hands it to `Fnparsescreeninfo`, which `EXECUTE`s
   everything after the `]` (or, if that text starts with `{` or `#`, calls it as a function and
   uses the result as the child's *key*). So a `screen` control whose `FIELDNAME$` is the child
   screen and whose `FUNCTION$` is `ParentKey$=F$(IV_INVOICENO)` hands the child the parent's
   current invoice number as `ParentKey$`; the child's Filter then shows only matching rows.
2. **Refresh it with `RedrawScreens`, and only when something changed.** Any event can set
   `RedrawScreens=1`; on its next pass the main loop calls `fnDrawScreens`, which redraws every
   embedded child (a fresh load, so the child's listview is repopulated). `RedrawScreens=-n`
   redraws only control `n`. Redrawing children is relatively slow, so set it only when the
   child's data actually changed — e.g. after a line was really added, never after a failed
   lookup.
3. **Validate, not Main Loop, for "the user typed something and pressed Enter".** After each input
   pass, ScreenIO runs the Validate event (the control's `FUNCTION$`) of every input field whose
   text changed, before acting on the key. Enter (`Function=0`) only exits a screen that has its
   own `listview` control (`fnTheresAListview`); a screen whose list lives in an embedded child has
   none, so Enter just validates and stays. Main Loop also works but fires on every pass, so it
   would have to test which field was current and which key was pressed; Validate only fires when
   the data changed. A barcode scanner (it types the code and presses Enter) therefore works
   through Validate too.

**Enter and Esc on a listview screen** (verified in `screenio.brs`'s `Fnrespondtouseraction`,
2026-10-09; an earlier belief that Enter depended on exit buttons turned out to be about Esc):

- **Enter always selects and exits** on a screen with its own listview control:
  `if Function=0 then if fnTheresAListview(mat FieldType$) then ExitMode=SelectAndQuit`. Select,
  Cancel or other exit buttons make no difference.
- **Esc is the key that checks for exit buttons.** If any control's function contains both
  `exitmode` and `quitonly` (`Fnsearchclosely`), Esc sets no exit mode at all, leaving exiting to
  that button. The main loop likewise skips saving pending changes on Esc in that case. Without
  such a button, Esc quits a listview screen (`QuitOnly`) or asks to save on an edit screen.
- **To give Enter (or any key) another meaning** — e.g. open the selected row in an edit screen
  instead of selecting it — use the **Main Loop** event. It runs **last** in
  `Fnrespondtouseraction`, *after* Enter has already set `ExitMode=SelectAndQuit`, so the handler
  has to cancel that. The owner's production pattern (confirmed in a real app's Main Loop
  functions, 2026-10-09) does three things after acting on the key:
  ```
  if fkey=0 then
     ! ... act on Enter, e.g. let fnfm("someedit",CurrentKey$) ...
     if fkey<>93 then let fkey(-1)   ! reset the key, unless the user closed the window (93)
     let Function=-1                 ! so nothing else treats this pass as Enter
     let ExitMode=0                  ! don't exit after processing the key
  end if
  ```
  `ExitMode` and `Function` are passed to event functions by reference. The same three-statement
  cancel suppresses other keys: Esc (`function=99 or fkey=99`), the window's close X (`93`, e.g.
  only after a "you still have unsaved work" `Msgbox`), or a tab click (`fkey=92`).

<a id="authoring"></a>
## 9. Authoring a new screen programmatically (writing `screenio.dat`/`screenfld.dat` directly)

**Confirmed end-to-end 2026-09-18**: a screen doesn't have to be built by hand in the Designer —
since "screens are data, not code" (§1), a program can write a new screen's records the same way
it would write to any other FileIO-managed data file, and the Designer will pick it up correctly.
Verified by writing a minimal listview screen (a made-up `SCREENCODE`, bound to an ordinary
customer-equivalent file) entirely through a standalone FileIO program, then opening it cold in
the Designer: every field — Notes, Caption, Rows/Cols, colors, File Layout, even the Field List —
appeared exactly as written, with no indication the record hadn't been hand-built in the UI.

If a person is at the keyboard, ScreenIO v2.95's own **`fnMakeScreen(; Layout$, LaunchScreen)`**
may be enough. It is an interactive wizard that generates a `<layout>LIST` listview,
a `<layout>EDIT` add/edit form and/or a `<layout>COMBO` screen from a FileIO layout
([Function Reference §E](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md#build)).
It prompts for every choice, so it can't run unattended. The technique below is for unattended
generation, or for layouts the wizard doesn't produce.

<a id="fileio-write"></a>
### The technique is just an ordinary FileIO write, twice

1. Open `screenio` and `screenfld` the normal way (`fnOpenFile`/an app's local `Fnopen` wrapper —
   see `APP-DEV-GUIDE.md` §4), getting named subscript constants the same way any other file's
   caller does (`si_...` for `screenio.dat`'s fields, `sf_...` for `screenfld.dat`'s — the prefix
   is whatever that app's own `.lay` file declares — see that app's own `app/conventions.md` for
   the exact casing/format it uses). **Copy that app's own `Fnopen` wrapper verbatim from wherever it
   already lives — commonly right at the bottom of `fileio.brs` itself — rather than
   reconstructing it from a caller/exemplar that merely *uses* it.** The two look similar but
   aren't identical: the real wrapper's own duplicate-suppression check (skip re-`EXECUTE`ing a
   file's subscripts if that file was already opened once this run, for performance) is easy to
   get subtly wrong by eye. And **by house convention this wrapper's `DEF FN` block sits at the
   *end* of the program's source, not the top** (see the real exemplar below — the tail of
   `fileio.brs` itself puts it under a `! #Autonumber# 99000,10` high line-number band, matching
   where `DEF`s conventionally cluster in a hand-authored file, per that app's own conventions).
2. Write **one** record to `screenio.dat` — the screen header: `SCREENCODE$`, which data file it's
   bound to (`FILELAY$`), size (`VSIZE`/`HSIZE`), and — for a screen with zero custom logic — every
   one of the 13 event-function fields (`ENTERFN$`...`EXITFN$`) simply left blank.
3. Write **one record per control** to `screenfld.dat`, all sharing that same `SCREENCODE$`. A
   minimal read-only listview needs only: a `caption` control (the on-screen title), one
   `LISTVIEW` control, and one `LISTCHLD` control per visible column.
4. **Guard against a duplicate `SCREENCODE`** with a keyed pre-check on `screenio.dat` before
   writing (its primary key is `SCREENCODE` alone, and it's a screen-level singleton — a second
   `WRITE` under the same key is a real `DUPREC`, not a scenario to leave untrapped).

Nothing else is special-cased — this is the same `Fnopen`-wrapper-then-`WRITE`-using-`Form$(chan)`
pattern documented for any data file, applied to two files that happen to define screens instead
of business records. **A full, real, working exemplar** building exactly this minimal listview end
to end, `Fnopen` wrapper included at the tail in the correct house position, was built and kept in
the source app's own `app/examples/` folder (not shipped with this kit-level guide, since it
necessarily binds to one app's real data file) — confirmed both to syntax-check clean and to
Save-and-Compile into a genuinely working screen with no changes needed. Any app following this
technique should keep its own worked exemplar the same way, under its own `app/examples/`.

<a id="layout"></a>
### Reasoning about control layout and position without the Designer's visual grid

The Designer shows control placement visually; writing records by hand means reasoning about the
same grid numerically instead. There's no trick beyond careful arithmetic, but the arithmetic
itself is simple and worth stating plainly:

- The screen is a character-cell grid `VSIZE` rows by `HSIZE` columns (both fields on the
  `screenio.dat` header record) — not pixels, not a proportional layout.
- Every control's `VPOSITION`/`HPOSITION` (top-left corner) plus `WIDTH`/`HEIGHT` (its box) are all
  in that same row/column grid, so two controls conflict exactly when their two rectangles overlap
  — ordinary 2D bounding-box arithmetic, nothing ScreenIO-specific.
- A `LISTVIEW`'s own box should comfortably contain its columns' *combined* display width (though
  the columns' individual `WIDTH`s don't have to sum to exactly the listview's `WIDTH` — real
  screens don't always match them exactly, there's slack); its `HEIGHT` is how many data rows show
  at once, unrelated to the number of columns.
- Before trusting a hand-built layout, walk every control's rectangle against every other's on
  paper (or in a scratch calculation) the same way you'd check for overlapping rectangles in any
  other UI — there's no ScreenIO-side validation that catches an overlap for you at write time; the
  first time it would visibly surface is opening the screen in the Designer or running it.
- **A companion tool, built and confirmed 2026-09-18** (kept as one of the source app's own
  `app/examples/` scripts, not shipped with this kit-level guide) reads a screen's raw
  `screenio.dat`/`screenfld.dat` records (no GUI, no Designer, no `design.brs` changes) and
  writes a plain-text `VSIZE`x`HSIZE` character grid with each control's rectangle sketched in,
  plus a `Listview columns:` summary and an explicit pairwise overlap report. `RUN PROC` it the
  same way as a CSV-export utility (feed 2 lines: `<SCREENCODE>` then an output path). Confirmed
  against both a minimal screen and a busy real one (~20 controls) — the dense-looking button row
  in that second case turned out to be an accurate rendering of genuinely tightly-packed (not
  actually overlapping) real coordinates, not a rendering bug. Building it surfaced two more
  confirmed BR gotchas worth knowing before writing anything similar:
  - **`KEY=` on a keyed file needs the value padded to the file's real key length, not just
    trimmed** — a bare `KEY=ScreenCode$` worked by pure coincidence for one 18-character
    `SCREENCODE$` (matching the field's full width) and then failed with `ERR 718, key length
    mismatch` on an 8-character one. The house fix is FileIO's own `Fnkey$(Filenumber,
    Key$)` (`Rpad$(Key$, Kln(Filenumber))`) — use it for every `KEY=`/`RESTORE ... KEY=`, not a
    bare string, even when a literal happens to match by luck once.
  - **`DIM name$(0)*width` (zero elements, generous string length) is the real house pattern for
    an array `Fnopenfile` will resize** — confirmed against a real login/session program's own
    `dim usersession$(0)*1023,usersession(0)`. Two wrong guesses before landing here: an explicit
    `*255` cap is too small for `screenfld.dat`'s `TOOLTIP$` (`*1000`) and overflows on a
    structural (declared-width) mismatch regardless of the actual value's length; dropping the
    `*length` clause entirely doesn't mean "let it grow freely" — it defaults to BR's ordinary
    18-char cap (`essentials.md` §2), which is *smaller*, not larger. Also don't forget to
    explicitly `DIM` every plain scratch string scalar that receives a wide field's value (e.g. a
    `DESCRIPTION$` value copied into an un-DIM'd `Label$`) — the same 18-char default bites scalars
    too, and it's an easy one to miss since the failure only shows up on real, long-enough content.

<a id="minimal-screen"></a>
### Field values to copy from a real minimal screen, not reconstruct from memory

Don't hand-derive `FIELDTYPE$` spellings or the `PARENT$` wiring from this doc or from recollection
— **export a real, already-working minimal listview screen via §7's CSV-dump method and copy its
actual field values.** A wholly standalone list-and-edit screen, or any bare listview (a screen
whose `LISTVIEW` control has a blank `FUNCTION$` — "show everything, no filter"), makes a good
confirmed-minimal real example to dump and compare against. Confirmed specifics worth knowing
before you read that dump, so the raw CSV makes sense on sight:

- `FIELDTYPE$` values are exact case-sensitive tokens: `"caption"`, `"LISTVIEW"`, `"LISTCHLD"`,
  `"button"` — not a documented enum anywhere else in this kit, only visible in real data.
- The `LISTVIEW` control's own `CONTROLNAME$` is conventionally **blank**; it carries an
  identifying token (commonly `"LV1"`) in its **`PARENT$`** field instead. Each `LISTCHLD` column
  then puts that same token in *its own* `PARENT$` to declare "I am a column of that listview" —
  the linkage runs through `PARENT$` on both sides, not through `CONTROLNAME$`/a foreign key.
- A `LISTVIEW` with a **blank `FUNCTION$`** has no Filter function at all — every record in the
  bound file shows, unconditionally (the "bare listview" pattern; see §6 for what a non-blank
  Filter function's return value would otherwise control).
- **An empty listview always shows one blank row.** When no record passes the filter,
  `Fnpopulatealllistviews` prints a single row of empty values (`if ~Populatecolorudim then …
  mat Populatedata$(1:Populatedataudim)=("")`) so the listview stays clickable (owner,
  2026-10-09). Numeric columns with an `N`/`PIC` conversion show it as `0`/`0.00`. It disappears
  once a real row is added — expected, not a filter bug.
- `FGCOLOR$`/`BGCOLOR$` are fixed **6-character** fields — a short code like `"W"` (BR's system
  *window* colors: black text on a white field, not "white") is
  stored left-justified, **padded with trailing spaces to 6 chars**, not bare. Blank/inherited
  color is 6 literal spaces, not an empty string.
- **Column order is not controlled by `VPOSITION`/`HPOSITION`.** Every `LISTCHLD` sibling of the
  same listview carries the identical `VPOSITION=1, HPOSITION=0` — confirmed across multiple real
  screens' dumps. Since `screenfld.dat`'s primary key (`SCREENCODE`) is shared by every control on
  a screen (a duplicate-key file by design — one screen has many control records under one key),
  same-keyed records are returned in **original write order**, and that write order is what
  actually determines the columns' left-to-right order on screen. Write your `LISTCHLD` records in
  the exact order you want the columns to appear.

<a id="add-edit-forms"></a>
### A second archetype: Add/Edit forms, and how they link back to a listview screen

The technique above covers a read-only listview; an Add/Edit form (bound input fields, Save/Cancel)
is a second common archetype, confirmed end to end 2026-09-18 (worked exemplar kept in the source
app's own `app/examples/`) against two real screens — one minimal (two fields) and one full production
form (~40 fields) — for a real worked comparison:

- **A bound input field is `FIELDTYPE$="C"`** (not `"field"` or anything else), with `FIELDNAME$`
  set the same way a `LISTCHLD` binds a column — ScreenIO reads/writes it automatically by name,
  no custom Read/Write function needed. The minimal real screen has **zero** custom event functions
  at all (every one of its 13 event fields blank) and still fully saves/loads real data — the same
  "bare" pattern §9's listview technique already established, now confirmed for editable forms too.
- **`DESCRIPTION$` on a `"C"` field is a cross-reference to its caption control's own
  `CONTROLNAME$`, not display text** — confirmed against the full production form: `Field_NAME`'s
  `DESCRIPTION$="Caption_NAME"`, and a separate `caption`-type control named exactly
  `CONTROLNAME$="Caption_NAME"` carries the real visible text (e.g. `"Customer Name:"`). This is the
  opposite of `DESCRIPTION$`'s role on `caption`/`button`/`check` controls, where it *is* the
  visible text directly (confirmed on the same screen: `SaveButton`'s `DESCRIPTION$="Save"`).
  Whether this cross-reference is functionally load-bearing or just a house documentation
  convention wasn't determined — it was replicated faithfully anyway, since the cost of doing so
  is zero and the cost of *not* doing so (if it turns out to matter) is unknown.
- **Save and Cancel are just buttons with a literal `FUNCTION$`, not a special control type**:
  `"let ExitMode=SaveAndQuit"` and `"let ExitMode=QuitOnly"` respectively — confirmed identically
  worded on both real screens. No screen-level event needs to call these; ScreenIO's
  own generic button dispatch runs the literal statement.
- **A listview's Add/Edit buttons open the edit screen via a `[SCREENNAME]`-style `FUNCTION$`**,
  confirmed on two real production screens and reproduced on a from-scratch test screen (worked
  exemplar in the source app's own `app/examples/`, demonstrating **adding controls to an
  already-existing, already-compiled screen** without touching its other records — scan for a
  specific `CONTROLNAME$` under the same `SCREENCODE$` as a not-already-present guard, `WRITE` the
  new rows, recompile):
  - **Add** (new record): bare `"[SCREENNAME]"` — no key, so the edit screen opens on a blank
    record.
  - **Edit** (the selected row): `"[SCREENNAME]Key$=CurrentKey$"` — `CurrentKey$` is ScreenIO's own
    built-in "whichever listview row is currently selected" value; no custom code needed to compute
    it. (One real screen's own Edit button uses `Record=CurrentRec` instead — a relative-record-number
    variant of the same idea; `Key$=CurrentKey$` is the more general form and the one used in the
    worked exemplar.)

<a id="custom-filter"></a>
### A third archetype: writing a genuine custom Filter function, and passing `ParentKey$` between screens

Both archetypes above use either no custom functions at all, or ones copied verbatim from a real
screen. This one is about writing an actual new one from scratch — confirmed end to end 2026-09-18
(worked exemplar in the source app's own `app/examples/`: a listview scoped to one customer's time-log
rows, plus the button that opens it from the customer listview screen).

**The Filter function itself is exactly as simple as §6's contract describes** — no shared/generic
filter, no keyed skip-ahead optimization (§9's own earlier note about that pattern still applies if
performance ever matters; this one deliberately doesn't use it), just a direct per-record test
against the ambient `ParentKey$`:

```
def fnTimelogFilter$
   if trim$(f$(tl_customer))=trim$(ParentKey$) then
      let fnTimelogFilter$="1"
   else
      let fnTimelogFilter$=""
   end if
fnend
```

Saved as `function/timelogfilter.brs`, referenced from the `LISTVIEW` control's `FUNCTION$`
as `"{timelogfilter}"` — same import mechanism as any other custom function (§2).
`f$(tl_customer)` and `ParentKey$` both come from the standard injection machinery (§4) — nothing
special was needed to make either one visible inside a hand-written function.

**Hit the confirmed 30-character function-name cap immediately**: the first name tried for this
exemplar's own filter function (33 characters) failed with a genuinely confusing error — see
`essentials.md`'s `DEF`/`FNEND` entry for the exact message and why it doesn't mention length at
all. Renamed to a 22-character name and it compiled clean. Worth counting characters *before*
writing the body, not after a cryptic failure sends you looking in the wrong place.

**Two different ways to wire a button that opens another screen with a value**, both real and
confirmed, worth knowing as alternatives rather than assuming there's only one:

1. **Bracket shorthand on the button's own `FUNCTION$`** (§9's Add/Edit pattern, extended): a real
   confirmed example passing `ParentKey$` this way — `"[somescreen(4,7)]parentKey$=ThisParentKey$"`
   (a real production screen's own Add button) — `[SCREENNAME]anyvar$=value` isn't limited to
   `Key$`; any variable ScreenIO recognizes as one of its own passed-through values works the same
   way, `ParentKey$` included. The optional `(row,col)` right after the screen name (as in
   `somescreen(4,7)`) positions the opened window; omit it (as every other example in this guide
   does) to use ScreenIO's default placement.
2. **A custom function that calls `fnfm$` directly**, used for the worked exemplar's "View
   Timelogs" button instead:
   ```
   def fnViewTimelogsForCustomer
      library : fnfm$
      let fnfm$("viewtimelogs","",0,0,CurrentKey$)
   fnend
   ```
   `fnfm$`'s own signature (`ScreenIO_Function_Reference.md`) is `Fnfm$(Screenname$;Keyval$,Srow,
   Scol,Parent_Key$,...)` — the 5th positional argument *is* `Parent_Key$`, so this is the same
   mechanism as option 1, just spelled out explicitly instead of through the bracket shorthand.
   `library : fnfm$` (bare, no library name) is **confirmed unnecessary here**: ScreenIO
   automatically handles the basic library linkages for every custom function it runs, so this
   re-link was already redundant the moment it was written — `fnAutoCallScreen`'s own real source
   (`design.brs`) happens to do the identical re-link before its own `fnDesignScreen` call, which is
   *why* the pattern got copied here, but that doesn't mean it was needed there either. It only
   actually matters if the same function is ever called from **outside** a ScreenIO screen context
   (a plain BR program with no ScreenIO-provided linkage of its own) — and it's harmless to include
   either way, so leaving it in isn't wrong, just not load-bearing inside a screen.

Option 2 is strictly more code for the same result here — reach for it when the screen-opening
logic needs to be anything more than "open this screen with this value" (a condition to check
first, a value to compute, logging, etc.); option 1 is simpler when a literal bracket expression
is genuinely all that's needed.

<a id="lookup-column"></a>
### A fourth technique: a free-floating lookup column, opened once via `fnInit_`/`fnFinal_`

A natural next question once a listview shows a foreign-key code (a customer's `PROJECT$`, an
invoice's `CUSTOMER$`, ...): how do you show the *related* record's name instead of the raw code,
without opening a lookup file on every single row? Confirmed end to end 2026-09-18 (worked exemplar
in the source app's own `app/examples/`), upgrading a "Project" column from a raw project-code field to
the real project name looked up from the project file. This combines two mechanisms already
documented separately into one worked example:

1. **The column itself becomes a free-floating `S$` field** (§4): blank `FIELDNAME$`, a real
   `CONTROLNAME$` (e.g. `"ProjectName"`) — reachable in code as `s$(sio_projectname)`. Size
   `SPECWIDTH`/`WIDTH` for the *looked-up* value's real width (a project name field might be `V64`),
   not the original bound field's width — a column that used to hold a 4-character code needs much
   more room once it holds a name.
2. **The lookup file opens once per listview load, not once per row**, via the same confirmed
   `fnInit_`/`fnFinal_` companion mechanism §6 already documented (real reference example: a Filter
   function that opens two lookup files in its own `fnInit_` companion) — copied faithfully rather
   than reconstructed:
   ```
   dim project, project$(0)*1024, project(0)
   !
   def fnTimelogFilter$
      if trim$(f$(tl_customer))=trim$(ParentKey$) then
         mat Project$=("") : mat Project=(0)
         read #project, using form$(project), key=f$(tl_project) : mat Project$, mat Project nokey Ignore
         let s$(sio_projectname)=Project$(pj_name)
         let fnTimelogFilter$="1"
      else
         let fnTimelogFilter$=""
      end if
   fnend
   !
   def fnInit_TimelogFilter
      let project=fnOpen("project",mat project$,mat project,mat form$,1)
   fnend
   !
   def fnFinal_TimelogFilter
      close #project:
   fnend
   ```
   The `,1` trailing argument to `fnOpen` is `Inputonly=1` (read-only) — appropriate for a pure
   lookup file the screen never writes to. The `KEY=` value here is a bare `f$(tl_project)`, **not**
   wrapped in `Fnkey$()`, copied exactly from the real reference example. It works only because
   that field is exactly as long as the project file's key: a `KEY=` value must equal the key
   length, or it fails with error 0718
   ([`essentials.md`](essentials.md#5-outputio-gotchas) §5). In new code, pad it:
   `key=rpad$(f$(tl_project),kln(project))`, which is plain BR, or FileIO's `Fnkey$` where that is
   linked.
3. **Naming the `fnInit_`/`fnFinal_` companions correctly matters** — they're recognized by exact
   name, not simply "any function near the main one." The derivation (`design.brs`'s
   `fnGetSpecialFunctionName$`) inserts `Init_`/`Final_` right after the `fn` prefix of the *base*
   function name, then truncates the whole result to the 30-character cap. The insertion is an
   ordinary BR substring assignment: a range whose end is before its start, `X$(3:2)=...`,
   inserts and replaces nothing
   ([assignment — substring mutation](../br_tree/10-language/data-manipulation/assignment/spec.md#substring)).
   For `fnTimelogFilter$` (no truncation needed), that's `fnInit_TimelogFilter` /
   `fnFinal_TimelogFilter` — confirmed correct by checking the compiled Helper Library's own
   generated dispatcher, which calls exactly those two names.

<a id="sort-column"></a>
**A related trick: a hidden column that only sets the sort order.** A listview's **Sort Column**
(the Designer attribute, "which column the listview is sorted on at load";
[ScreenIO_Library](../br_tree/50-libraries/screenio/ScreenIO_Library.md)) is stored in the
LISTVIEW control's `SPECWIDTH`. When the listview is populated, `tools/screenio.brs` (lines
1901–1906) sends BR's `,SORT` with that column number: once for a positive value (ascending),
and twice on its absolute value for a negative one. Sending `SORT` twice reverses the sort
([Grid and List — `SORT_ORDER`](../br_tree/20-io-screen/controls/Grid_and_List.md)). That lets the
sort key be a column nobody reads. One production screen has a free-floating column of width `0`
whose Filter function fills it with a priority digit, then the description and date, and sorts on
it. The rows come out grouped by priority, which sorting on the raw key fields can't do.

<a id="compiling-from-code"></a>
### Compiling is not optional — and no longer requires the Designer UI

Writing the records is necessary but **not sufficient** to make a screen runnable. Two independent
confirmations from the original investigation (2026-09-18, before the function below existed):

1. **Static**: an existing real screen with *zero* custom event functions (every one of its 13
   event fields blank, same as the technique above) still has a compiled Helper Library sitting on
   disk (tens of KB — ScreenIO's own generic engine boilerplate, per §2, gets baked in even when
   there's no app-specific code to import).
2. **Live**: a programmatically-written test screen's record did **not** run via `fnfm()` until it
   was compiled — after which it worked immediately and correctly, no further changes needed. (A
   genuinely data-only screen is *technically* able to run without a compiled Helper Library, but
   this is a rare edge case not worth special-casing — treat compiling as mandatory, full stop, even
   when a screen has no custom functions at all.)

**As of ScreenIO v2.93, compiling no longer requires opening the Designer UI at all.** A new
library function, added specifically to close this loop for programmatic screen authoring:

```
library "screenio" : fnCompileScreen
let Success=fnCompileScreen(ScreenCode$,WaitForComplete)   ! ScreenCode$*18; 1 = found and compile launched, 0 = not found
```

**Pass `WaitForComplete=1` whenever more than one compile happens in the same process, or
anything after the call assumes the `.br` already exists.** The actual compile is a separate
spawned OS process (`Fncompilehelperlibrary`'s own `execute "system -C -M ..."`) — without waiting,
`fnCompileScreen` returns as soon as that process is *launched*, not when it *finishes*. Confirmed
the hard way, 2026-09-18: calling it twice back to back for two different screens in one program
(no wait) raced on the shared default temp filename, and the first screen's `.br` silently stayed
stale — its `.brs` (generated helper-library *source*, written synchronously) updated, but the
actual compiled object didn't, and nothing in the run's own output said so. `WaitForComplete=1`
fixed it outright (confirmed: two compiles, ~1.6 seconds total, both `.br`/`.brs` pairs correctly
fresh) — prefer it over an ad hoc `SLEEP` in the caller, which is what was tried first and worked
only by luck/timing.

does exactly what the Designer's own **Load** then **Save-and-Compile** menu options do — confirmed
by reading `design.brs`'s own menu-handler code (`Fnrecompileallscreens`'s per-screen loop already
chained the same two internal calls, `Fnreadscreen` then `Fncompilehelperlibrary`; `fnCompileScreen`
is that same pair, extracted for one screen code and exposed via `def library`). Call it any time
after writing/updating a screen's `screenio.dat`/`screenfld.dat` records — including immediately
after the write technique above, in the very same program, so a screen can go from "doesn't exist"
to "fully compiled and runnable" in one headless run with no Designer interaction at any point. See
the source app's own `app/examples/` for a worked exemplar that does exactly this: writes the records,
closes its own file channels, and calls `fnCompileScreen` before exiting.

This makes the programmatic-write technique useful for genuinely unattended screen generation (not
just scaffolding to be finished by hand in the Designer) — e.g. generating many similar screens
from a template, one per data file, entirely from a script.

**`fnCompileScreen` originated as one app's own addition (v2.93) and has since been released
upstream:** it (and `fnCheckScreenErrors`) are standard `DEF LIBRARY` exports in ScreenIO v2.95, so
an installation on v2.95 or later needs no hand-applied patch. Signatures for all 21 exports are in the
[Function Reference](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md#build). `design.brs` (confirmed: not a separate
`screenio.brs` — that's its *compiled, source-stripped* deployment artifact; see an app's own
`app/conventions.md` for its ScreenIO-modification specifics, if it keeps any) remains
the real source. Its home, right after `Fncompilehelperlibrary` (~line 5474), as of v2.93:

```
COMPILESCREEN: ! Compiles One Screen's Helper Library By Screen Code (Callable From Code)
   def library fnCompileScreen(ScreenCode$*18;WaitForComplete,___,Success)
      let fnSettings ! Also includes library linkage to FileIO
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      if Fnreadscreen(Uprc$(Trim$(ScreenCode$)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
         let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],"",WaitForComplete)
         let Success=1
      end if
      let fnCompileScreen=Success
   fnend
```

<a id="screenio-build"></a>
### How the deployed `screenio.br` is built from `design.brs`

Read this if you need to patch the ScreenIO engine by hand (for example, to apply an upstream
addition before your installation has the release that contains it). **`design.brs` is the source;
`screenio.br` is built from it in two stages.** The stages below come from one installation, where
the owner confirmed them end-to-end on 2026-09-18. That installation's files are not in this kit,
so check its line ranges and file names against your own copy.

1. **Full build.** Edit `design.brs` (Lexi-authored, so use the
   [Lexi-aware coding loop](APP-DEV-GUIDE.md#lexi-aware-coding-loop)) and compile it to
   `design.br`. This is the **complete** program, Designer UI included.
2. **Deployment build.** `design.br` is not what apps load. A short BR procedure loads it,
   deletes the *source text* of the Designer-UI line ranges, and replaces `screenio.br`. At that
   installation the procedure is:
   ```
   lo design
   del 71000 74999 source
   del 70400 source
   del 25500 source
   del 13040 source
   rep screenio.br
   ```
   Every `LIBRARY "screenio": …` in an app then resolves to that `screenio.br`. A new process
   picks up the redeployed file at once.

**The deployment build removes no functionality.** [`DEL … SOURCE`](../br_tree/70-commands/editing/spec.md#del)
deletes a line's source text and keeps its compiled object. The lines vanish from `LIST` and can't
be decompiled, but they still run. This is how ScreenIO's copy protection works. It was confirmed
on the kit's 4.33c runtime with a probe (`context/scratch/delsrc/`):
- `DEL 100 120 SOURCE` on a program whose lines 100–120 define `fnTwice`
- `SAVE`, then a fresh `LOAD`
- result: `LIST` showed only lines 10–40, and `fnTwice(21)` still returned 42.

**Two things to watch when patching:**
- **Keep new code outside the stripped ranges.** It still *runs* inside them, but its source
  disappears from your deployed copy.
- **Compare against real line numbers.** Those ranges are BR line numbers, not physical lines in
  `design.brs`: Lexi's `#Autonumber#` assigns the real numbers, so check against the translated
  output (see the `#Autonumber#` caveat under [bare `LIBRARY` linkage](#bare-library-linkage)).

<a id="check-screen-errors"></a>
### `fnCheckScreenErrors` — the Designer's "To Do" validation, also callable from code

Added right alongside `fnCompileScreen` (v2.94, same release), for the other half of what the
Designer does interactively: **`Fnvalidatefields`** (design.brs, ~line 6197) is what populates the
Designer's "To Do" debug listview — but it only ever *prints* into a live GUI listview control
(`Static_Wdebug`), which is opened as part of drawing the Designer's own window and simply doesn't
exist headless. So exposing this one needed a small change to two existing functions
(`Fncleardebuglistview`/`Fnprinttodebuglistview`), not just a new wrapper: both now *also*
unconditionally mirror into a plain growable array (`Debugerror_Object`/`Debugerror_Field`/
`Debugerror_Message$`/`Debugerror_Type`), and the real `PRINT #Static_Wdebug` calls are guarded
behind `if Static_Wdebug<>0 and File(Static_Wdebug)<>-1 then` so the Designer's own interactive
behavior is unchanged. The new entry point just runs the same validation and copies that array out:

```
CHECKSCREENERRORS: ! Runs The Same Validation The "To Do" Debug Listview Shows, Callable From Code
   def library fnCheckScreenErrors(ScreenCode$*18,Mat ErrObject,Mat ErrField,Mat ErrMessage$,Mat ErrType;___,Success,ErrCnt,Index)
      let fnSettings ! Also includes library linkage to FileIO
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      let Db_Warning=1 ! Normally set by Fnpaintdebugwindow, which never runs headless
      let Db_Error=2
      if Fnreadscreen(Uprc$(Trim$(ScreenCode$)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
         let Fnvalidatefields(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         let ErrCnt=Udim(Mat Debugerror_Object)
         mat ErrObject(ErrCnt) : mat ErrField(ErrCnt) : mat ErrMessage$(ErrCnt) : mat ErrType(ErrCnt)
         for Index=1 to ErrCnt
            let ErrObject(Index)=Debugerror_Object(Index)
            let ErrField(Index)=Debugerror_Field(Index)
            let ErrMessage$(Index)=Debugerror_Message$(Index)
            let ErrType(Index)=Debugerror_Type(Index)
         next Index
         let Success=1
      end if
      let fnCheckScreenErrors=Success
   fnend
```

Call it as `library "screenio" : fnCheckScreenErrors` then `let Success=fnCheckScreenErrors(
ScreenCode$, mat ErrObject, mat ErrField, mat ErrMessage$, mat ErrType)` — the four `mat`
parameters are **required, not optional**, per the array-scratch-parameter limitation below;
pass real (even zero-sized) arrays. `Success=0` means the screen code wasn't found; otherwise
`Udim(mat ErrMessage$)` is the finding count, `ErrType`'s values are `Db_Warning`(1)/`Db_Error`(2).
Confirmed working end to end on a deliberately-flawed throwaway test screen (blank `FILELAY$`
correctly produced one `Db_Warning` finding, "You should enter a file layout.") as well as
returning a clean zero-finding result on two real working screens.

**Two more bugs this one cost, on top of the two below** (same "bare `LIBRARY` linkage skips
top-level setup" root cause, worth listing since they're easy to reproduce in any future addition):
`Db_Warning`/`Db_Error` are themselves only ever assigned inside `Fnpaintdebugwindow` (GUI-only,
never runs headless) — without setting them explicitly first, every finding silently reported
`ErrType=0` instead of the real 1/2, a *quiet* bug (no crash, just wrong data) that only surfaced
by actually inspecting a positive-detection test's output, not by the syntax/compile gates or even
a "does it crash" run. And `CNT` (used as a natural-sounding loop-count variable name here) is a
reserved BR system pseudo-variable (`essentials.md` §5) — `brls -sema` caught that one immediately
as a real error, not a silent one, illustrating both ends of the same lesson: static checks catch
some naming mistakes outright, but a wrong-but-not-crashing value needs an actual inspected test
run to catch.

<a id="bare-library-linkage"></a>
### A general lesson: exposing an internal function via bare `LIBRARY` linkage skips *all* of the host program's own top-level setup

This cost two real, confirmed bugs while building `fnCompileScreen` — both worth knowing before
exposing *any* similarly "internal" function as a new `def library` entry point, in ScreenIO or any
other BR library:

- **`ERR 122`, invalid array element.** The first draft called `Fnreadscreen` directly. It crashed
  writing into `Screenio$`/`Screenio` past their bounds — because nothing had ever sized them.
  `Fnreadscreen` only *fills* them (`mat Screenio$=("")`, a value-assignment, not a resize — see
  `essentials.md`'s `MAT A(n)` vs `MAT A = (0)` distinction); the real sizing happens as a side
  effect of `Fnopen`'s call into FileIO's `Fnopenfile`, which normally runs once, early, as part of
  the Designer's own startup flow (`Fnloadandeditscreen` calling `Fnopenscreenfiles`). A function
  reached only via `LIBRARY "screenio" : fnCompileScreen` — with the Designer's own program body
  never having run at all in that process — never gets that sizing for free.
- **`ERR 2282`, library function not processed by a `LIBRARY` statement.** Fixed the above by
  calling `Fnopenscreenfiles` directly — which then failed one level deeper, because `Fnopen`
  itself calls FileIO's `Fnopenfile`, and *that* `LIBRARY` linkage is normally established by
  `fnSettings` (called once, early, in the same Designer startup flow — `let fnSettings ! Also
  includes library linkage to FileIO`, right there in the comment). Same root cause, one layer
  further down.

**The pattern, worth checking every time before exposing a new headless entry point**: find every
place the function's *normal* callers already run before reaching it (an initializer, a
lazy-open-if-not-open helper, a one-time settings/linkage loader), and call each one explicitly at
the top of the new entry point — never assume "it already ran," because under bare `LIBRARY`
linkage with no host program executing, *nothing* ran. `fnSettings` and `Fnopenscreenfiles` are
both cheap and idempotent (guarded by their own flag checks), so calling them defensively costs
nothing even on a second call within the same process.

**How this was actually diagnosed, worth repeating for the next one**: real end-to-end testing —
writing a screen record, calling the new function against a real headless BR process, and reading
the `UNATTENDED` log for the exact error number and line — caught both bugs; neither would have
been found by `brls`/`LOAD ... source` syntax-checking alone, since both are runtime state
problems, not syntax errors. Cross-referencing the crash's real BR line number against the
Lexi-translated output (§7's CSV-dump method's sibling technique — `lexi-compile.ps1 -OutFile` on
`design.brs` itself) was what actually located each failing statement, since **a `.brs` file using
`#Autonumber#` has physical text-line positions that do not correspond to its real BR line
numbers** — the crash log's line number can only be matched up against the *translated* output
with real sequential numbers, not the original source's physical line count.

<a id="windows-menu"></a>
## 10. A Windows dropdown menu bar on a ScreenIO screen (`DISPLAY MENU` + fkey 98)

ScreenIO has no menu-bar control, but a screen can host BR's own native dropdown menu. Nothing
here is ScreenIO-specific except where the code goes, and ScreenIO's own manual names this use:
the Main Loop event is where you "implement special keys or windows menus"
([ScreenIO_Library](../br_tree/50-libraries/screenio/ScreenIO_Library.md)). The BR half is
[`DISPLAY MENU`](../br_tree/20-io-screen/controls/Display_Menu.md). The pattern below is taken
from a production ScreenIO app, with the Lexi removed and names made generic.

1. **Enter event: display the menu once.** The screen's Enter function builds three parallel
   arrays and issues `display menu: mat M$, mat Pgm$, mat Status$`.
   - `M$` holds the captions. Each two-space indent makes an item a submenu of the one above.
   - `Pgm$` holds each item's payload: the string your code will get back.
   - `Status$` holds each item's flags. **An item must include `E` in its status to raise fkey
     98 when chosen**; add `R` to keep the menu across program chains.
2. **Main Loop event: watch for fkey 98.** Main Loop fires every time ScreenIO's main
   `RINPUT FIELDS` is passed, so a menu click arrives there as `fkey=98`. It does not close the
   screen: ScreenIO's input loop exits only when `ExitMode` is set, or on Esc or Enter.
3. **Dispatch on `MENU$`.** `MENU$` returns the chosen item's `Pgm$` string (`MENU` returns its
   subscript).
4. **Refresh afterwards.** After running the chosen action, set `RepopulateListviews=1` and
   `RedrawScreens=1` so the screen repaints. Both are by-reference parameters ScreenIO passes to
   every event function. The source app also re-issues its `DISPLAY MENU` after each dispatch;
   copy that, but its cause wasn't traced.

**Why 98 can't collide with a control.** Every ScreenIO hot zone is numbered from `fnBase` = 1500
upward (see [§8](#child-screens), `fnKeyBase`), and the "click outside this screen" test requires
`Function>fnBase`. A native BR key code such as 98 is below that floor, so ScreenIO never mistakes
it for a control click.

**The reusable trick: let the payload be a screen name.** `fnfm(Screen$)` takes a screen name as
a string, so a menu item whose `Pgm$` is a screen name needs no dispatch branch of its own. Handle
the few special items explicitly, and send everything else to `fnfm`. A whole menu of screen
launchers then costs one line:

```
def fnMenuEnter   ! Enter event
   ! ... fill mat M$, mat Pgm$, mat Status$ (e.g. "  &Customers","custedit","ER") ...
   display menu: mat M$, mat Pgm$, mat Status$
fnend
def fnMenuLoop    ! Main Loop event
   if fkey=98 then
      if lwrc$(menu$)="logoff" then
         execute "system"
      else
         let fnfm(menu$)      ! any other item: its payload is a screen name
      end if
      let RepopulateListviews=1
      let RedrawScreens=1
   end if
fnend
```

<a id="see-also"></a>
## See also

- [`../br_tree/50-libraries/screenio/spec.md`](../br_tree/50-libraries/screenio/spec.md) / [`ScreenIO_Function_Reference.md`](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md) / [`ScreenIO_Data_Model.md`](../br_tree/50-libraries/screenio/ScreenIO_Data_Model.md) — the authoritative calling convention, event list, `ExitMode` constants, and handler parameter list.
- [`../app/conventions.md`](../app/conventions.md) — an app's own confirmed ScreenIO specifics, if it documents any (the `function/` vs `screenio/` split, the Lexi tie-in).
- [`BR_launch.md`](BR_launch.md#the-lexi-preprocessor) — what Lexi is and how it's invoked; directly relevant since every Helper Library compile runs Lexi per function.
- `../app/examples/` — real, verified-working exemplars for the technique in §9 (writing screens programmatically), necessarily built against one app's own real data files; kept under that app's own `app/` rather than this kit-level file since they can't be application-agnostic. See also `../app/exemplars/` for an app's own blessed *production* programs (a different category — real shipped code, not built-to-teach-the-technique scripts).
