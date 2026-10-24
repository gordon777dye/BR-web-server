---
title: ScreenIO Function Reference
file: ScreenIO_Function_Reference.md
source: screenio.brs (shipping library source, earlier 16-export build) + screenio.br.brs (listing of ScreenIO v2.95) — signatures verified against every visible DEF LIBRARY export
category: 50-libraries
subcategory: 50-libraries/screenio
kind: reference
status: deep-reference          # source-derived; retained alongside spec.md (too detailed to fold)
related: [screenio, library-facility, fnsnap]
---

# ScreenIO Function Reference

The library's **public surface is 21 `DEF LIBRARY` functions** as of **ScreenIO v2.95**
(`FNVERSION=2.95`). The rest of its ~425 functions are internal to the engine and the Designer.
Every signature below is taken verbatim from the shipping source, not the wiki (the ScreenIO wiki page
is empty). Parameters after the `;` are optional; `&` marks pass-by-reference; `Mat` marks array
parameters. See [Coverage check](#coverage) for the full list of 21 and how v2.95 differs from the
earlier 16-export build (a 2020 source with no version number recorded).

All the screen-invocation calls are thin wrappers over one internal engine, `Fnmasterfm$` — so they
share the same parameter set and semantics.

<a id="invocation"></a>
## A. Screen invocation (the everyday surface)

```business-rules
Fnfm$ (Screenname$; Keyval$, Srow, Scol, Parent_Key$, Parent_Window, Display_Only,
       Dontredolistview, Recordval, Mat Passeddata$, Usemyf, Mat Myf$, Mat Myf,
       Path$, Selecting, SaveDontAsk)                      -- returns chosen/edited record key$ ("" if cancelled)

Fnfm  (Screenname$; …same params…, ___, Returnvalue)       -- returns 1 ok / 0 cancelled (or the screen's return value)

Fndisplayscreen (Screenname$; Keyval$, Srow, Scol, Parent_Key$,
                 Parent_Window, Recordval, Path$, Selecting)  -- read-only display of a screen (forces Display_Only)

Fncallscreen$ (Screen$; Keyval$, Parent_Key$, Display_Only, Parent_Window,
               Dontredolistview, Recordval, Mat Passeddata$, Usemyf, Mat Myf$,
               Mat Myf, Path$, Selecting)                   -- call by the bracket form; wraps name in [ … ] if absent
```

| Function | Returns | Use |
|---|---|---|
| `Fnfm$` | record key (string) | Run/edit a screen; the workhorse call. |
| `Fnfm` | numeric (1/0 or screen return value) | Same, when you want an ok/cancel or numeric result rather than the key. |
| `Fndisplayscreen` | numeric | Show a screen read-only (it sets `Display_Only`/`Selecting` for you). |
| `Fncallscreen$` | record key (string) | Programmatic equivalent of the in-screen `[SCRNNAME]` call syntax — adds the `[` `]` if you omit them. |

### Shared parameters

| Param | Meaning |
|---|---|
| `Screenname$` / `Screen$` | The screen **code** (key into `screenio.dat`; see [data model](ScreenIO_Data_Model.md)). |
| `Keyval$` | Record key to edit. **Blank = add a new record.** |
| `Srow`, `Scol` | Upper-left position for the screen window (0 = default/centred). |
| `Parent_Key$`, `Parent_Window` | Calling screen's key and window channel — establishes the parent/child relationship. |
| `Display_Only` | `1` = read-only (no edits / no Write event). |
| `Dontredolistview` | Suppress re-populating a listview when returning to it. |
| `Recordval` | Open by **record number** instead of key. |
| `Mat Passeddata$` | Arbitrary data handed to the screen; readable in its event code. |
| `Usemyf` + `Mat Myf$`, `Mat Myf` | Supply your **own** open file record arrays instead of letting ScreenIO open the file. |
| `Path$` | Override the data-file path. |
| `Selecting` | Listview is being used as a **picker** (return a selection rather than just browse). |
| `SaveDontAsk` | **`Fnfm$` only; added after the 2020 build, present in v2.95.** On a screen with **no** listview, exiting by ESC (`fkey 99`), `fkey 93`, or a click on a parent screen sets `ExitMode` to **SaveAndQuit** instead of **AskSaveAndQuit**, so edits are kept without a "save changes?" prompt. It is meant for a caller that asks once for several screens itself: `run.brs`'s `fnRunTabs` passes its `AskSaveTogether` here. Listview screens are unaffected. `Fncallscreen$` does not take it. |

<a id="designer"></a>
## B. Event / designer support

```business-rules
Fnselectevent$ (&Current$; &Returnfkey)     -- opens the designer's "select event function" dialog
```
Presents the event-function picker used inside the ScreenIO designer; updates `Current$` (the chosen
function call) and `Returnfkey` **by reference** and returns the chosen function string. Used when wiring
a screen/control event to a `DEF FN…` (see [Event-callback contract](#events)).

<a id="helpers"></a>
## C. Helpers (callable from event code and the designer)

| Function | Signature | Returns / purpose |
|---|---|---|
| `Fnfindsubscript` | `(Mat Subscripts$, Prefix$, String$*40)` | Index of a field subscript by `Prefix$`+`String$` — resolves `FILE_FIELD` subscript constants at run time. |
| `fnGetUniqueName$` | `(Mat ControlName$, Control)` | A control name guaranteed not to collide with the existing names in `Mat ControlName$`. |
| `fnIsInputSpec` | `(type$)` | `1` if a control field-type code is an **input** control: `c`, `search`, `check`, `combo`, `filter`. |
| `fnIsOutputSpec` | `(type$)` | `1` if a code is **output/static**: `caption`, `button`, `p` (picture), `frame`, `screen`. |
| `fnDays` | `(String$*255; DateSpec$*255)` | The numeric `DAYS` value parsed from a date string; supports **relative** offsets (e.g. `-3w` = three weeks ago). |
| `fnFunctionBase` | *(no args)* | Base **FKEY** number for the current screen nesting level — `1500 + 200 × loaded-screen-count`. ScreenIO assigns each screen's buttons/controls function keys above this base, so nested screens never collide. |
| `fnBR42` | *(no args)* | `1` if running **BR ≥ 4.2** (feature detection on `WBVERSION$`). |
| `fnBR43` | *(no args)* | `1` if running **BR ≥ 4.3**. |
| `fnListSpec$` | `(SpecIn$*255)` → `*255` | *(export in v2.95, not in the 2020 build)* Returns `SpecIn$` **cut before its third comma**, i.e. the `row,col,LIST rows/cols` head of a listview `FIELDS` spec with everything after it dropped. It is a one-line `DEF` expression: `SpecIn$(1:POS(SpecIn$,",",POS(SpecIn$,",",POS(SpecIn$,",")+1)+1)-1)`. With fewer than three commas it does not error: it returns `""` (zero or two commas) or just the first field (one comma). ScreenIO's compiler links it into every generated helper library, so event code can call it with no `LIBRARY` statement of its own. |

<a id="animation"></a>
## D. Wait animation

A small "please wait" animation for long operations.

| Function | Signature | Purpose |
|---|---|---|
| `fnPrepareAnimation` | *(no args)* | Initialise the animation (timing, speed defaults via `fnSettings`). |
| `fnAnimate` | `(; Text$*60)` | Render one animation frame, with an optional caption. Call repeatedly during the long task. |
| `fnCloseAnimation` | *(no args)* | Tear down the animation window. |

<a id="build"></a>
## E. Designing, generating and compiling screens *(exports in v2.95, not in the 2020 build)*

```business-rules
fnDesignScreen (; ScreenName$)                                   -- open the Designer
fnMakeScreen (; Layout$, LaunchScreen)                           -- run the Screen Generator wizard
fnCompileScreen (ScreenCode$*18; WaitForComplete)                -- rebuild one screen's helper library
fnCheckScreenErrors (ScreenCode$*18, Mat ErrObject, Mat ErrField,
                     Mat ErrMessage$, Mat ErrType)               -- run the Designer's "To Do" validation
```

Two of these (`fnDesignScreen`, `fnMakeScreen`) are **interactive**. The other two work headless,
which lets a program build or check a screen with no Designer UI. The
[ScreenIO internals guide](../../../dev/screenio-guide.md#compiling-from-code) covers that workflow.

| Function | Returns | Behaviour (from the v2.95 source) |
|---|---|---|
| `fnDesignScreen` | — | Opens the Designer, loading `ScreenName$` if given. Needs GUI mode: if `ENV$("guimode")` is blank it only prints *"Please use a New GUI version of BR to design your screens."* If GUI is `OFF` it turns it on for the session and back off afterwards. Restores the console's original rows/cols on exit. |
| `fnMakeScreen` | — | Opens the **Screen Generator** wizard for a FileIO layout (`Layout$` pre-fills it). It is interactive: you pick which screens to build and which fields go on each. It can write up to three screens, named from the first 13–14 characters of the layout: **`<layout>LIST`** (listview with columns, a filter box on BR ≥ 4.3 or a search box otherwise, and exit buttons), **`<layout>EDIT`** (add/edit form), and **`<layout>COMBO`** (listview + edit fields on one screen). Each is written to `screenio.dat`/`screenfld.dat`. `LaunchScreen` non-zero then opens **every** generated screen in the Designer, each in its own BR process (`execute "system -C -M …"`). `LaunchScreen` zero (the default) opens none. It checks an internal `FNWARNMESSAGE` first and does `execute "system"` if that returns true. That function's source is not visible in the v2.95 listing, so the condition it tests is unknown. |
| `fnCompileScreen` | `1` = screen found, compile launched; `0` = no such screen | Reads the screen by code (upper-cased and trimmed) and generates its helper library, as the Designer's compile does. **The compile itself runs in a separate BR process** (`execute "system -C -M <br> -<config> proc <file>"`). A return of `1` therefore does **not** mean the compile succeeded. With `WaitForComplete` non-zero it waits for that process's output file before returning. Otherwise it returns immediately. |
| `fnCheckScreenErrors` | `1` = screen found and validated; `0` = no such screen | Runs the same field validation as the Designer's "To Do" debug listview, with no window. It resizes the four arrays to one element per finding: `ErrObject` = the Designer mode/panel the finding belongs to, `ErrField` = the `SI_…` field subscript or control index, `ErrMessage$` = the text (e.g. *"File layout not found."*), `ErrType` = **`1` warning / `2` error**. Zero findings leaves them dimensioned to 0. A return of `1` does not mean "no errors": check `UDIM(Mat ErrType)`. |

<a id="events"></a>
## Event-callback contract (how your code runs)

ScreenIO is **event-driven**, but events are **not** fixed-signature callbacks. The designer stores, per
screen and per control, a **BR statement string** (a function call you write); the engine `EXECUTE`s it
(`fnExecute`) at the right point in the screen lifecycle. So you "wire an event" by typing a **filename** of a custom function file (in .\function\\) such as
`{MyValidation}` (assumes .brs) into the event field.

**Screen-level events** (each is a field in the `screenio.dat` header — see data model):

| Event | Header field | Fires |
|---|---|---|
| Enter | `ENTERFN$` | when the screen is first displayed |
| Initialize | `INITFN$` | when the screen is called **without** a `key$` (add mode), if it has a data file |
| Read | `READFN$` | when the initial record is read; in a **listview**, also whenever the selection changes |
| Load | `LOADFN$` | as field values are loaded into controls |
| Write | `WRITEFN$` | when the user picks **Save**, just before the record is written to disk |
| Wait | `WAITFN$` | on keyboard idle, per the screen's `WAITTIME` timeout (`-1` disables) |
| Record Locked | `LOCKEDFN$` | when the record is locked by another user |
| Merge | `MERGEFN$` | during ScreenIO AutoMerge, before the record is written |
| Main Loop | `LOOPFN$` | every pass of the main `RINPUT FIELDS` statement |
| Nokey | `NOKEYFN$` | when a keyed read finds no record |
| Listview Prepopulate | `PRELISTVIEWFN$` | before a listview is filled, **after** a `defaults\prelist.brs` if one exists — not a fallback pair, see the full ordering below |
| Listview Postpopulate | `POSTLISTVIEWFN$` | after a listview is filled, **after** a `defaults\postlist.brs` if one exists — see the full ordering below |
| Exit | `EXITFN$` | last, as the screen closes |

**Control-level events** (the control's `FUNCTION$` field — see data model):
- **Validate** — input controls (`c`, `search`, `check`, `combo`, `filter`): decide whether the entered
  value is acceptable; may modify or reject it.
- **Click** — `button`, `caption`, `p` (picture): runs when the user clicks the control.
- **Filter** — listviews: called once per record as the file is read. Return `0`/`""`/`"STOP"` to
  suppress the record (`"STOP"` also halts reading the file — an early-exit optimization); return
  `1`/`"1"`/any other non-blank string to include it. If that non-blank return value is itself a
  valid BR color spec (`"/#123456:#124324"`, or a named macro from `BRConfig.sys`/an included file
  like `color.sys`, e.g. `"[BLUE]"`), the record is included **and** rendered in that color — one
  return value drives both inclusion and row color, not two separate mechanisms. Confirmed against
  the engine source (`design.brs`'s listview-population loop) and by ScreenIO's author, 2026-09-13.
  Example in [spec.md](spec.md#examples).

A **`fnInit_<name>`** / **`fnFinal_<name>`** pair (`<name>` matching the Filter function's own name,
truncated together with the `Init_`/`Final_` prefix to fit BR's identifier length limit — e.g.
`fnFilterSubscriptionCharges` pairs with `fnInit_FilterSubscriptionCharg`/
`fnFinal_FilterSubscriptionChar`) lets a **listview's Filter function** run one-time setup/teardown
around the whole per-record loop, rather than on every record.

**`fnInit_`/`fnFinal_` were added to ScreenIO later than `PRELISTVIEWFN$`/`POSTLISTVIEWFN$`**
(confirmed by ScreenIO's author, 2026-09-13) — older screens built before that addition achieve
the same one-time-setup/teardown effect using the screen-level Listview Prepopulate/Postpopulate
events instead. All three mechanisms (the `function/defaults/prelist.brs`/`postlist.brs` files,
the screen-level `PRELISTVIEWFN$`/`POSTLISTVIEWFN$`, and the Filter function's own `fnInit_`/
`fnFinal_`) **are fully supported today, and none is a fallback for another** — each is checked
and run independently, so a screen can have any combination of the six fire around one listview
load. **Exact order, confirmed directly against the engine source** (`design.brs`'s
`Fnpopulatealllistviews`, lines ~1730-1753 for the open side and ~1930-1944 for the close side —
verify against current source if `design.brs` changes, this is not a documented contract
elsewhere):

1. `defaults\prelist.brs`, if that file exists (regardless of whether `PRELISTVIEWFN$` is also
   set — checked independently, not "used only if blank").
2. `PRELISTVIEWFN$` (screen-level Listview Prepopulate), if specified.
3. `fnInit_<name>` (in the Filter function's own file), if a listview control's Filter function
   exists on this screen.
4. The listview loads: the Filter function runs once per record, until EOF or a `"STOP"` return.
5. `defaults\postlist.brs`, if that file exists.
6. `POSTLISTVIEWFN$` (screen-level Listview Postpopulate), if specified.
7. `fnFinal_<name>`, if present — **last**, after both postlist calls, not before `POSTLISTVIEWFN$`
   as an earlier draft of this note (and the author's own initial recollection) had it.

Confirmed real-world purpose of the `fnInit_`/`fnFinal_` pair, 2026-09-13: `fnInit_...` commonly
opens files the per-record Filter function will do a keyed read against on every row
(opening/closing per-row instead would be wasteful for a large list) and/or computes a one-time
value (e.g. a listview header caption); `fnFinal_...` then closes what `fnInit_
...` opened. All three functions live in the **same** `function/<name>.brs` file, sharing
module-level `DIM`s declared at the top of that file (that's how the open file numbers survive
from `fnInit_...` through every call of the main Filter function to `fnFinal_...`). This pairing is
optional — older Filter functions may have only the plain function, no `_Init`/`_Final`.

<a id="context"></a>
### Handler runtime context

The engine passes one large fixed parameter list into every event/helper function (so the same code can
run from any event); most are **by reference**, so assigning to them changes the screen. The
author-relevant ones:

| In scope | Meaning |
|---|---|
| `Mat F$` / `Mat F` | the screen's **file** record — fields by `FILE_FIELD` subscript constants |
| `Mat S$` | values of **non-file** controls (named controls not bound to a file field), by control name |
| `Key$` / `CurrentKey$` | current record key |
| `CurrentRec` | current record number |
| `ParentKey$` | the parent screen's key (child screens) |
| `FieldText$` / `FieldIndex` | value / index of the field being validated (Validate events) |
| `ControlIndex` | the control that fired (index into `Mat ControlName$`) |
| `ExitMode` | set this to exit the screen — see [constants](#exitmode) |
| `Mat PassedData$` | the `Mat passeddata$` handed to the screen at the call |
| `Path$`, `Selecting`, `DisplayOnly`, `Active` | call / mode context |
| `RepopulateListviews`, `RedrawListviews`, `RedrawScreens`, `RepopulateCombo` | set to force a UI refresh |
| `Window` | the screen's window channel |
| `Mat Disk_F$` / `Mat Disk_F` | the on-disk record (for Merge / compare) |

**Control properties** are addressable by a `ctl_<ControlName>` subscript into property arrays, e.g.
`let Invisible(ctl_MyField)=0` or `let BgColor$(ctl_MyField)="…"` — so a handler can show/hide and
recolour controls at run time.

<a id="exitmode"></a>
### ExitMode constants

A handler ends the screen by setting `ExitMode`; the engine keeps looping while it is `0`. From source
(`fnDefineExitModes`):

| Constant | Value | Meaning |
|---|---:|---|
| *(none)* | `0` | keep running (default) |
| `QuitOnly` | `1` | cancel / discard — the **ESC** default |
| `SaveAndQuit` | `2` | save the record, then exit |
| `SelectAndQuit` | `3` | select the record, then exit — the **ENTER** default in select mode |
| `QuitOther` | `4` | quit to another target |
| `AskSaveAndQuit` | `5` | prompt to save, then exit |
| `Reload` | `6` | reload the screen |
| `AutoReload` | `7` | reload automatically (no prompt) |

<a id="function-types"></a>
### Valid custom-function types

An event or control `FUNCTION$` field may hold any of (dispatch logic confirmed from source,
`Fnexecute`/`fnFS` in `screenio.brs`, 2026-09-13):
- **`{name}`** — a custom function file, `function/name.brs`, imported and compiled into the
  screen's Helper Library (see [spec.md](spec.md#how-it-works)).
- **`#libname:call(...)`** — an inline library-function call needing no separate function file:
  parsed as library name (up to the first `:`) and a call expression (after it); the compiler
  generates `library "libname" : fnXxx` (`fnXxx` taken from the call expression) plus
  `let ReturnValue[$] = call(...)` directly in the Helper Library's dispatcher. E.g.
  `#run:fnRun('[CUSTEDIT]',F$(CU_CODE))` calls `fnRun` from `library "run"`.
- a **link to another screen** — the `[SCRNNAME]` form, optionally `(row,col)` and/or a trailing
  expression after `]` (assigning `CurrentKey$` / `ThisParentKey$`, `DISPLAYONLY=1`, etc.) —
  evaluated via the same `{`/`#`/`*` rules as above.
- **`%progname`** — `CHAIN`s to an entirely different program, ending the current screen stack.
- **any single BR command/statement** — with none of the above prefixes, the field is passed
  straight to `EXECUTE`.
- (Conversion functions only) **any valid BR field spec**.

<a id="coverage"></a>
## Coverage check

This page documents **all 21** `DEF LIBRARY` exports of ScreenIO **v2.95**:

- **The original 16** (all present in the 2020 build this page was first written from):
  `fnPrepareAnimation`, `fnAnimate`, `fnCloseAnimation`, `fnBR42`, `fnBR43`, `Fnselectevent$`,
  `Fndisplayscreen`, `Fnfm`, `Fnfm$`, `fnFunctionBase`, `fnGetUniqueName$`, `fnIsOutputSpec`,
  `fnIsInputSpec`, `fnDays`, `Fncallscreen$`, `Fnfindsubscript`.
- **Added since the 2020 build (5):** `fnDesignScreen`, `fnMakeScreen`, `fnCompileScreen`,
  `fnCheckScreenErrors` ([§E](#build)), and `fnListSpec$` ([§C](#helpers)). The
  [internals guide](../../../dev/screenio-guide.md#compiling-from-code) dates `fnCompileScreen` to
  v2.93 and `fnCheckScreenErrors` to v2.94. When the other three became exports is not recorded.
  `fnDesignScreen` already existed in the 2020 build, but as a private `DEF`.
- **Changed since the 2020 build:** `Fnfm$` takes a 16th parameter, `SaveDontAsk`
  ([shared parameters](#invocation)).

**Two of the 21 are not visible in the v2.95 source listing.** `Fnfm` and `Fndisplayscreen` do not
appear in a `LIST` of the shipped `screenio.br`, but both names are in the compiled program, and
ScreenIO's own compiler writes them into the `LIBRARY` line of every helper library it generates.
The likely reason is that the shipped `screenio.br` has line ranges removed from its source with
`DEL … source`, which hides them from `LIST` without removing the compiled code. That is not confirmed for these two functions. Their signatures above are therefore from the
earlier, fully listed build and are not re-verified against v2.95.

*(To regenerate the inventory: `grep -niE "^[0-9]*\s*def\s+library\s+fn" <listing>`, then drop the
`fnFunctionSwitch*`/`fnShow…`/`fnCheckStringFunction` hits, which are text inside `FNPRINTLINE`/`FNGC`
calls that ScreenIO writes into generated helper libraries, not its own exports. A decompiled
listing is not a complete inventory, for the reason above.)*

## See also

- [spec.md](spec.md) — concepts, screen-function types, screen-to-screen call syntax
- [ScreenIO_Data_Model.md](ScreenIO_Data_Model.md) — the `screenio.dat` / `screenfld.dat` schema events and controls live in
- [fileio](../fileio/spec.md) — the FileIO library ScreenIO builds on
- [library-facility](../library-facility/spec.md) — linking the library (the BR `LIBRARY` statement)
- [ScreenIO internals guide](../../../dev/screenio-guide.md) — *(dev kit)* how the engine dispatches these events at run time; the Filter event's exact [return-value contract](../../../dev/screenio-guide.md#filter-contract)
