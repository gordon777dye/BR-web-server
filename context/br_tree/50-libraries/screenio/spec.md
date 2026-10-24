---
title: ScreenIO library
file: spec.md
source: screenio.brs (shipping source) + filelay/screenio,screenfld (schema) + the ScreenIO_Library manual; §ScreenIO Library
category: 50-libraries
subcategory: 50-libraries/screenio
kind: spec
status: 2b           # spec + source-derived deep-reference pages (Function Reference, Data Model); authoritative over the earlier fabricated ScreenIO library guide; no conflicts
related: [library-facility, fnsnap]
keywords: [ScreenIO, LIBRARY, fnfm, fnfm$]
---

# ScreenIO library

A Rapid-Application-Development library (a Sage AX tool) for building event-driven, screen-based applications; it builds on the **FileIO** library for data access. A **Screen Function** (built in the ScreenIO designer) is called like any [library function](../library-facility/spec.md); ScreenIO drives
the underlying [screen FIELDS](../../20-io-screen/input-output/spec.md) and
[file I/O](../../30-io-file/statements/spec.md) for you.

<a id="syntax"></a>
## Syntax

```business-rules
LIBRARY "screenio": fnfm$, fnfm
fnfm$(scrnname$ [; key$] [, row] [, col] [, parentkey$] [, parentwindow] [, displayonly] …)  -- returns record key (or "")
fnfm (scrnname$ [; key$] [, row] [, col] …)                                       -- returns 1 ok / 0 cancelled
```
The library exports **21 functions** (ScreenIO v2.95; 16 in earlier builds); `fndisplayscreen` (read-only view) and `fncallscreen$` (the programmatic `[SCRNNAME]` call) are the other two invocation entry points. Full signatures and the rest
(helpers, wait-animation, version flags) are in
[ScreenIO_Function_Reference](ScreenIO_Function_Reference.md).

<a id="semantics"></a>
## Semantics

- **Screen Function types**: *Listview* (browse/select records from a file), *Add/Edit* (data
  entry), and *Menu/Simple* (menus & non-data screens). A Screen Function can be CHAINed/PROCed,
  run standalone, or called as a library function.
- **Calls**: `fnfm$` returns the selected/edited record key (blank if cancelled); `fnfm` returns
  1/0 (or a screen return value). Key arguments: `key$` (record to edit, blank = new), `row`/`col`
  (position), `displayonly`, `parentkey$`, `MAT passeddata$`, `usemyf`+`MAT myf$/myf`.
- **Events** are where you add logic. They are stored per screen and per control as call **strings**
  the engine `EXECUTE`s at each lifecycle point (not fixed-signature callbacks) — you point each at your own `DEF FN…`. Screen-level: Enter, Initialize, Read, Load, Write, Wait, Record-Locked, Merge, Main Loop, Nokey, Listview Pre/Postpopulate, Exit. Control-level: Validation (data controls), Click
  (buttons/pictures/captions), Filter (listviews → include/colour rows). Full contract and the screen/ control fields they live in: [Function Reference](ScreenIO_Function_Reference.md#events) and [Data Model](ScreenIO_Data_Model.md).
- **Screen-to-screen**: inside a ScreenIO screen, call another with `[SCRNNAME]`,
  `[SCRNNAME]KEY$="123"`, `[SCRNNAME(10,5)]`, `[SCRNNAME]DISPLAYONLY=1`.

<a id="how-it-works"></a>
## How it works

- **Screens are data, then code.** A screen's layout lives as records in `screenio.dat`/`screenfld.dat`
  (see [Data Model](ScreenIO_Data_Model.md)) — *what data to display where, where to save it on disk, and
  what to do with it.* When a screen is **compiled**, ScreenIO generates a per-screen **helper library**
  holding the custom function code its events call.
- **Editing event code means recompiling the *screen*.** Because a screen's event `DEF FN…` code is
  compiled **into** that per-screen helper library at screen-compile time, an edit takes effect only
  when the **screen** is recompiled — not by compiling the event source on its own, and never by
  editing the compiled `screenio.dat`/helper output directly. (Apps commonly keep these event
  snippets in a dedicated source directory that is never compiled standalone.) The compile pipeline
  itself — and how to run it from code, without the Designer — is in the kit's
  [ScreenIO internals guide](../../../dev/screenio-guide.md#compiling).
- **Runtime lifecycle** (one `fnfm`/`fnfm$` call): load the layout → if the screen has a file layout, open it; with a `key$`, read the record and fire **Read**, otherwise fire **Initialize** → map fields onto controls and display → run the input loop (firing **Main Loop**, **Wait**, validations, clicks) until **ExitMode** is set — by an event, or **ESC** (Cancel) / **ENTER** (Select) → compute the return value and save / add / drop / ignore the record, firing **Write** then **Exit**. The exit codes are the [ExitMode constants](ScreenIO_Function_Reference.md#exitmode).
- **One data file per screen.** A Screen Function binds to a single file. To maintain a parent/child pair (e.g. an invoice header + line items) you tie **four** screens together: a header listview → a header add/edit (which embeds the detail listview `DISPLAYONLY` in its Enter event) → a detail listview
  (filtered to the parent via `parentkey$`) → a detail add/edit (whose Initialize event stamps the parent
  key onto each new line).

<a id="examples"></a>
## Examples

```business-rules
00100 LIBRARY "screenio": fnfm$, fnfm
00300 LET RESULT$ = fnfm$("CUSTLIST")            ! browse, return chosen key
00500 LET OK = fnfm("CUSTEDIT", CUSTKEY$)        ! edit a record

! A listview Filter event (include only active customers)
DEF FNFILTER(MAT F$, MAT F)
   IF F$(CUST_STATUS) = "A" THEN LET FNFILTER = 1 ELSE LET FNFILTER = 0
FNEND
```

<a id="see-also"></a>
## See also

- [ScreenIO_Function_Reference](ScreenIO_Function_Reference.md) — the 21 `DEF LIBRARY` exports (v2.95) and the event-callback contract, including the Designer/compile entry points `fnDesignScreen`, `fnMakeScreen`, `fnCompileScreen`, `fnCheckScreenErrors`
- [ScreenIO_Data_Model](ScreenIO_Data_Model.md) — the `screenio.dat`/`screenfld.dat` screen & control schema (from `filelay/`)
- [ScreenIO_Library](ScreenIO_Library.md) — the full ~206-section Sage AX wiki manual, captured locally (prose/tutorial reference)
- [ScreenIO internals guide](../../../dev/screenio-guide.md) — *(dev kit)* how a screen compiles into its Helper Library, the runtime screen stack and event dispatch, the Filter return contract, and authoring/compiling screens programmatically
- [library-facility](../library-facility/spec.md) — linking `screenio` and its functions
- [20-io-screen/controls](../../20-io-screen/controls/spec.md) — the controls ScreenIO renders
- [30-io-file/statements](../../30-io-file/statements/spec.md) — the file I/O ScreenIO performs
- [60-integration/web](../../60-integration/web/spec.md) — web integration; the PhpIO library deploys ScreenIO screens to the web
- [00-configuration/installation-tooling](../../00-configuration/installation-tooling/spec.md) — **Lexi** (the no-line-numbers preprocessor, relocated there)
- **`run.brs`** — a companion library **distributed with ScreenIO** (confirmed with ScreenIO's
  author, 2026-09-13), not something an app writes for itself: `fnRunTabs`/`fnTabs`/`fnRunTab` load
  several Screen Functions onto native BR tab-windows (one `OPEN ... "tab=<caption>"` per tab, the
  `CURTAB` system function to detect a tab switch, `fnfm$` re-invoked per tab) so an app can build a
  tabbed main-menu shell without reimplementing that plumbing itself.

*(The **live** wiki ScreenIO Library
page is a full ~206-section manual — only the *local* snapshots of it were empty stubs. The
deep-reference pages here are built from the shipping `screenio.brs` source, the `filelay/` schema, and
that wiki manual. The misfiled `Lexi` page — an editor preprocessor, not ScreenIO — was relocated to
installation-tooling.)*
