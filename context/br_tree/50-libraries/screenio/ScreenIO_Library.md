---
title: ScreenIO Library (full wiki manual capture)
file: ScreenIO_Library.md
source: ScreenIO Library manual (Sage AX / Gabriel Bakker) — retrieved 2026-06-19
category: 50-libraries
subcategory: 50-libraries/screenio
kind: reference
status: deep-reference          # full-page capture, retained beside spec.md (cf. FileIO_Library.md)
related: [screenio, library-facility]
---

# ScreenIO Library — full wiki manual

> **Capture note.** This is a local copy of the live wiki manual
> ScreenIO Library (~206 sections, by
> **Sage AX / Gabriel Bakker**), retrieved 2026-06-19 via WebFetch. WebFetch runs each page through a
> summarizing model, so this is a **faithful capture, not a byte-verbatim transcript** — quoted passages
> are exact, but connective prose may be lightly condensed, and the long Designer-UI sections are more
> condensed than the conceptual/reference sections. The **authoritative** machine-readable facts (export
> signatures, the `ExitMode` constants, the data-model schema) live in
> [ScreenIO_Function_Reference.md](ScreenIO_Function_Reference.md) and
> [ScreenIO_Data_Model.md](ScreenIO_Data_Model.md), derived from the shipping `screenio.brs` source and
> `filelay/`. Where the two disagree, **the source-derived pages win** (see the ExitMode callout below).

---

## ScreenIO Library

The **ScreenIO Library** is "a Rapid Application Design tool that enables anyone to write complex user
interfaces or complete custom programs, in a fraction of the time required by traditional development."
Sage AX uses it to build programs rapidly for customers — "a fully functional File Maintenance program
can now be created in half an hour. A zoom function or any other 'single screen' program can be created
in minutes." Programs created with ScreenIO ("screen functions") integrate with existing BR software and
databases, run standalone or embedded, and require the **FileIO Library** to operate.

## Using ScreenIO Screens

### Screen Functions

#### What is a Screen Function?

"A complete self contained program, that can be chained to, procced to, run as a regular program, or even
run as a library from right in the middle of your existing program." A Screen Function is a totally
modular object — easy to add to an existing program or another screen. One customer-selection listview
can serve as part of a File Maintenance program *and* as a standalone picker elsewhere.

#### How does it work?

ScreenIO stores screen layouts in internal data files (what to display where, where to save it on disk,
what to do with it). Custom function calls and business logic embed directly. **On compilation, "a screen
helper library is created with all the custom function code that needs to run from your screen."** Storing
layouts as data makes them easy to modify; calling them as library functions makes implementation
flexible. The minimal call:

```business-rules
LIBRARY "screenio" : fnfm$
let Result$=fnfm$("scrnname")
```

`Result$` reveals user actions: a listview returns the selected record; an Add/Edit screen writes the
record and returns its key; cancel returns "".

#### What can a Screen Function Do?

Three categories:

**Listview Screen Function** — tied to a data file (through FileIO), no editable text controls, includes a
Listview. "Now the very easiest way to implement 2D Controls in your BR programs." Displays all/filtered
records for selection; paired with an Add/Edit screen for the same file it forms a basic File Maintenance
program.

**Add/Edit Screen Function** — "tied to a data file (through fileIO) and has editable text controls on it,
and no Listview control on it anywhere." With a key → Edit mode; without a key → Add mode.

**Menu/Simple Screen Function** — "not tied to any data file… very limited in functionality." Mainly
button menus that invoke other screens/programs/library functions; returns a ≤255-byte string.

## Implementation Guide

### Installing your new screen

When ordering screens, Sage delivers:

```
data\screenio.dat     - Screen Header Data file
data\screenio.key     - Screen Header Key file
data\screenfld.dat    - Screen Fields Data file
data\screenfld.key    - Screen Fields Key file
data\screenfld.ky2    - Screen Fields Key file
screenio.br           - Free ScreenIO Runtime Library
screenio\scrnname.br  - Screen helper library
screenio\scrnname.brs - Screen helper library source
```

Copy these into the main BR programs folder.

### Running your new screen

```
LOAD scrnname
RUN
```

### Calling your screen from your existing programs

```business-rules
01000 LIBRARY "screenio" : fnfm
01200 let fnfm("scrnname")
```

At line 1200 the screen loads and displays; control returns to the next line on completion.

### Calling your screen from an existing non-gui program

Identical to a GUI call. "When a ScreenIO screen loads, the first thing it does is check if Gui is on. If
its not, then it saves everything on the screen, and then turns GUI on to run your ScreenIO screen." On
completion the prior screen state is restored and GUI is turned back off. (BR 4.1 with a non-24×80 screen
needs manual env-var config for rows/cols; **BR 4.2+ handles this automatically.**)

### Returning Information from your screen

The runtime returns a ≤255-char string, by default the edited/added/selected record key; cancel returns
"". "If you just draw a screen, and tie some fields from the file to it, writing no custom code at all,
the key of the edited record will be the return value." Custom code can override the return. For results
not stored in a file, tie the screen to a temp file and read by the returned key, or override the return
value with ≤255 bytes of custom string data.

## Advanced Screen Implementation / Runtime Engine Library Functions

All take the same parameters (only `scrnname$` is required):

- **`fnfm("scrnname"; key$, row, col, ParentKey$, ParentWindow, DisplayOnly, Dontredolistview, Recordval,
  Mat Passeddata$, Usemyf, Mat Myf$, Mat Myf, Path$, Selecting)`** — "Displays and passes control to your
  screen. FnFm returns true if a record was selected/edited and false if the record was not edited. If the
  return value for the screen is numeric, then fnfm would return the numeric return value of the screen.
  If the return value is a string, calling fnfm will discard the string return value and return only 1 if
  the user didn't cancel, or 0 if they did."
- **`fnfm$(…same params…)`** — "returns the key of the record selected/edited, or blank if the user
  cancelled… If the return value for a screen is numeric, then fnfm$ returns `str$()` of the numeric
  return value… Use `val()` to turn it back into a number."
- **`fnDisplayScreen("scrnname"; key$, row, col, ParentKey$, ParentWindow, Recordval)`** — **"Deprecated,
  use fnfm instead, with the Display Only parameter."** Displays a screen without passing control to it
  (useful to show a listview before the user interacts). Returns the **window number** of the new Screen
  Function window; close that window number to erase it.

Inside a ScreenIO screen, call another from any event (e.g. a button click) with the internal syntax
`[SCRNNAME(Row,Col)]Key$="blah" : ParentKey$="blahblah"` — `Row, Col, Key$, ParentKey$` optional; also
`Record=`, `Selecting=`, `DisplayOnly=`, `Path$=`. Simplest form: `[SCRNNAME]`.

### Runtime Engine Library Function Parameters

- **`Scrnname$`** — the screen to call (the only required parameter).
- **`Key$`** — key of the current record. Blank → the screen does **not** read; it runs the **Initialize**
  event (add a new record). Non-blank → reads that record, runs input, saves. *A key should never be
  passed into a Listview screen.*
- **`Row, Col`** — top-left position; if omitted the screen centres in window 0 (resizing it if needed).
  If given, you must ensure the screen fits or you get an invalid Row/Col internal error.
- **`ParentKey$`** — an extra value passed through to your custom functions (ignored by the engine). Most
  often used by a listview **filter** event to limit records. (No filter event → all records show.)
- **`ParentWindow`** — with Row/Col, the parent window for positioning (default window 0).
- **`DisplayOnly`** — display then exit without passing control (makes `fnfm`/`fnfm$`/`fnCallScreen$`
  behave like `fnDisplayScreen`). `fnfm` then returns the new window number; `fnfm$`/`fnCallScreen$`
  return `str$()` of it.
- **`DontRedoListview`** — when calling a screen from within a screen, skip repopulating the listview you
  are returning **to** (a speed optimization). *Set on the call to the add/edit screen but it applies to
  the listview screen.*
- **`RecordVal`** — edit an Add/Edit record by record number instead of key (leave `Key$` blank).
- **`Mat PassedData$`** — array for passing custom info into the screen; every function inside has access.
- **`UseMyF` + `Mat MyF$` / `Mat MyF`** — pass your own record arrays; ScreenIO uses them instead of
  reading/writing the disk (good for an Add/Edit screen that shouldn't touch disk).
- **`Path$`** — FileIO `Path$` prepended to the layout's path (same layout in multiple paths).
- **`Selecting`** — a flag passed through to your functions to define screen "modes" (engine ignores it,
  like `ParentKey$`).

## How does it work Internally / Program Flow

"When you call your new screen… the screen layout is loaded from the screenio data files (ScreenIO.DAT and
ScreenFld.DAT). Then, if a file layout is given, the file is opened, and if there is a key given, then the
key is read and the read event is triggered. If a key is not given, then the initialize event is
triggered." ScreenIO maps the file's fields onto the screen's fields and displays them; the screen keeps
control "until 'ExitMode' is triggered, either from one of the events, or by pressing the ESC key to
trigger an ExitMode of Cancel (by default), or the ENTER key to trigger an ExitMode of Select (by
Default)." On exit, depending on ExitMode, the return value is calculated and the data is saved / added /
dropped / ignored; the **Prewrite** and **Exit** events fire here.

## Philosophy

"ScreenIO is a modular event driven system for BR. The ScreenIO Design and Runtime Libraries do for BR
what Visual Basic did for the Microsoft world of programming" — but simpler, because BR is simpler than VB
and ScreenIO screens can write to data files with no custom code. It is limited to interfaces BR can
produce: one modal input screen at a time, BR-style listviews/grids, rows/columns (not pixels/twips). The
focus is "remaining as simple as possible, while still allowing the flexibility to accomplish 90% of the
business programming purposes."

**Modular** — implement screens in existing programs via `CHAIN` or (more commonly) a library call;
screens can call each other, even recursively. **Event Driven** — easy to call existing business logic
from a screen; each Screen Function has several events overridable with custom code, a library call, an
execute command, or a link to another screen.

## Screen Events (overview)

- **Enter** — when the screen is first displayed.
- **Initialize** — any time the screen is called without a `key$` (and there is a data file); initialize
  values for newly-added records.
- **Read** — when the initial record is read, and in a Listview, any time the selection changes; mainly to
  unpack data onto the screen.
- **Write** — when the user picks "Save", just before writing to disk; can cancel the exit, change the
  exit mode, or make last-minute changes.
- **Mainloop** — every time the main `RINPUT FIELDS` statement is passed; update screen info, implement
  special keys or windows menus.
- **Wait** — works with the screen's timeout; fires if the keyboard is idle that many seconds (else the
  default Wait event runs).
- **Record Locked** — when a record is locked (else the default Locked Record event runs).
- **Exit** — last, when the screen is closing.

## Individual Control Events

- **Filter** (Listview) — "gets called to determine if the currently selected record should be added to
  the listview or not. Your filter function receives MAT F$ and MAT F for the screen, and if it returns
  true… then the record is included in the listview. If your filter function returns an HTML color code,
  then that HTML color is used to color that specific row of the listview." No filter → all records show.
- **Validation** (data controls: TextBoxes, CheckBoxes, SearchBoxes, Radio Buttons, Filter Boxes, Combo
  Boxes) — "gets called to determine if the data is acceptable or not." Receives the value being saved,
  may modify it, returns true/false. (String data is never forced into a numeric field.)
- **Click** (Buttons, Pictures, Captions) — "triggered whenever the user clicks on the control."

## Purpose of Events

"By overriding various events with custom code, we can make your screen functions behave any way you want
them to."

## Screens with two data files

"ScreenIO Screen Functions are limited to one data file each." Each screen directly modifies only its
MAIN file, though custom event code can touch related files. A parent/child pair is handled with **four
screens**:

> **Example (invoice header + detail):** (1) a **listview** of invoice headers (optionally filtered by
> customer via `ParentKey$`), with buttons to the header add/edit; (2) the header **add/edit**, which links
> `DisplayOnly` to screen 3 in its **Enter** event (and a button to screen 3 without DisplayOnly); (3) a
> **listview** of detail lines with a **filter** function limiting it to the current invoice's lines
> (passed via `ParentKey$`), with buttons to the detail add/edit; (4) the detail **add/edit**, whose
> **Initialize** event stamps the parent (invoice) key onto each new line. "This process allows you to
> quickly and easily create a set of four Screen Functions that preform complete FM operations on two
> linked data files with a parent/child relationship."

## The ScreenIO Animated Loading Icon

An animated loading icon appears automatically whenever a listview takes more than a couple seconds to
load — no developer action needed. (See *Working with the ScreenIO Loading Icon*.)

---

## Save Money with Screen Functions  *(marketing — retained for completeness)*

A Screen Function ≈ 4–8 hrs of traditional development. "Sage AX is selling all custom screens at a base
price of $150." Custom processing code carries a modest additional charge. **Lower Maintenance Costs:** the
runtime library is free; the Design engine is a one-time unlimited license (pays for itself after ~30
screens); standard editors suffice for helper-library code; when file layouts change, screens adapt
automatically via FileIO — only the layouts need updating. **Estimated Price:** "contact Sage AX
(gabriel.bakker@gmail.com)… Visit http://www.sageax.com/products/screenio-library/ for more details."

## Screenio.ini

A text file (`ScreenIO.ini`) in the root or `screenio` subfolder; holds BR code snippets that set config
variables. Defaults apply if omitted:

```
Setting_EnableLogging=0
setting_FileIOPath$="fileio"
setting_ScreenIOPath$="screenio"
setting_ClockPath$="clocks\\clock"
setting_ImagePath$="images"
setting_ScreenFolder$="screenio"
setting_ClickToMove=1
setting_PreviewListviews=1
setting_RealtimeFilters=0
setting_load_filter=0
setting_functionsel_filter=1
```

- **EnableLogging** — automatic logging via FileIO's log function.
- **FileIOPath$** — path to FileIO ("once you start using non-standard paths, it gets pretty tricky…
  recommend sticking with the defaults").
- **ScreenIOPath$** — path and filename of your copy of screenio.
- **ClockPath$** — clock files for the loading animation.
- **ImagePath$** — screenio images folder (movement grid, search icons).
- **ScreenFolder$** — folder for compiled screen helper libraries.
- **ClickToMove** (default 1) — show the blue movement-dot grid (toggle via Tools menu / F6; can hurt perf
  on constrained systems).
- **PreviewListviews** (default 1) — WYSIWYG render of listview data at design time (disable for large
  datasets).
- **RealtimeFilters** (default 0) — apply custom filter functions during the preview (off by default; a
  buggy filter can crash the designer and lose unsaved work).
- **Load Filter** (`setting_load_filter`, 2.3+) — filter box vs search box on the Load dialog.
- **setting_functionsel_filter** — filter box vs search box on the Function Select dialog.

---

## Making ScreenIO Screens — the ScreenIO Designer

*(The Designer is a visual tool for licensed developers; this UI walkthrough is condensed.)*

The Designer (built entirely in BR) has a **Windows Menu** (top), a **Toolbar** (left: Window Attributes,
Field List, Toolbox), a **Debug** window (bottom), and an **Editor** window (centre). It runs in modes
(Attributes, FieldsList, Editor, EditorMove, Debug, SelectColor, SelectFileLay, Listview, SelectEvents,
SetTabOrder, ConfigureDebug); the active mode highlights yellow.

- **Saving** — a screen needs a name; File→Save writes it and compiles its helper library. **No autosave —
  save frequently.** **Backups:** auto-saved to the `backup` folder as `screenname.sio`; restore via
  Import.
- **Windows X** — in the Designer, closes ScreenIO and exits BR; when running screens, cancels/exits all
  active screens recursively back to the calling program.
- **Windows Menu** — *File* (New, Load, Save and Compile, Compile, Save and Test, Export/Import Screen,
  Purge ScreenFlds File, Recompile All Screens, FileIO, New Window, BR Console, Explore Local Folder,
  Quit); *Options* (Click to Move, Preview Listviews, Real Time Filters); *Tools* (Power Search, Code
  Explore, Generate Screen, Generate Code, Orphaned Functions); *Add Control* (keyboard adders for each
  control type); *Screen* (Adjust Screen Size, Move Controls, Draw Movement Grid, Visit Checklist, Set
  FG/BG Color, Select File Layout, Set Events, Set Tab Order, Configure Debug, Configure Additional Info,
  Test Screen); *Help* (Documentation, About).

### Window Attributes (screen-level)

- **Window Name** — unique 8-char primary key (used to load from code and from File menu).
- **Caption** — window title bar (and the child-window border if bordered).
- **Rows / Cols** — window size (changeable any time; resize so controls fit).
- **Attributes** — any valid BR window-attribute statement (e.g. `BORDER=S`, or `N=[BackgroundColor]`).
- **Picture** — background image path.
- **Read Key** — key used to read the file (defaults: first key for Add/Edit, Sequential Read for
  Listview).
- **Return Key** — key used to compute the return value (defaults to the first key).
- **Input Attr** — Input-Attr spec for the main `RINPUT FIELDS` (appearance of the active field).
- **Wait Time** — seconds of idle before the WAIT event (else default Wait).
- **FG Color / BG Color** — default new-control foreground / whole-screen background.
- **File Layout** — pick the FileIO layout the screen binds to.
- **Set Form Events** / **Set Tab Order** — shortcuts to configure screen-level events / tab order.
- **Field List** — listview of the layout's fields; Enter/double-click adds a field to the screen.

### Toolbox (control types)

**Field** (selected layout field as a textbox + caption), **TextBox** (file-tied or screen-only),
**MultiLine Textbox** (add a textbox, then **PgDn** in movement mode to stretch it multi-line), **Caption**,
**CheckBox** (with TrueValue/FalseValue), **Radio Button** (a checkbox with a **group number** in
Attributes; tie several to one field using TrueValue + `~ignore~` for the false value), **Combo Box**
(needs a Populate function, which doubles as validation), **Listview** (press **Enter twice** for Edit
Listview Columns Mode), **Search Box** (auto-tied to a listview; jumps as the user types), **Filter Box**
(4.3+; case-insensitive full-row search, narrows in real time), **Button** (with a Click event), **Picture**
(clickable image), **Frame** (a BR child window for grouping — add it before placing controls on it),
**Screen** (a child screen rendered with the parent), **Skip a Space** (skip a row in auto-placement).

- **Editor** — the central graphical workspace (move controls, edit attributes/events).
- **Debug** — warnings (blue) and errors (red) from validation; double-click to jump to the location.

## Using the ScreenIO Designer (workflow)

1. **Create** — type a unique 8-char Window Name; click the File Layout button to pick the FileIO layout
   (populates the Field List).
2. **Add fields** — select from Field List + Add Field / Enter; for listviews add a blank Listview then
   Enter twice for Edit Listview Columns Mode.
3. **Position** — click a control to enter **Movement Mode** (blue dots, yellow highlight): "Arrow Keys"
   move; **Backspace** narrows; **Space** widens; **PgUp/PgDn** taller/shorter; **Enter** toggles
   Movement ↔ Control Attributes mode. Captions move with their textbox automatically.
4. **Click to Move** — select a control (yellow), click a blue dot to jump it there (groups move relative
   to the primary control).

### Control Attributes Window

- **Control Name** — optional; *"if your control is not tied to a field, but you give it a name, then
  ScreenIO automatically reserves a place for that control in Mat S$."*
- **Field** — the data-file field the control is tied to (read on entry, written on Save).
- **Caption** — caption text for Caption Fields, Check Boxes, Buttons.
- **Caption Field** — the control-name moved automatically with this one in Movement Mode.
- **Spec Width** — internal data width (not the physical display width — that's Space/Backspace in
  Movement Mode).
- **Sort Column** — (Listviews) which column the listview is sorted on at load (recommended with a search
  box).
- **Multiselect** — (Listviews) enable multi-select; read `mat SelectedKeys$` / `mat SelectedRecords` in
  custom functions.
- **Truth Value / Falsehood Value** — (Checkboxes) translate checked/unchecked to your file's true/false
  representation.
- **`~ignore~`** — for radio buttons tied to one field: set each option's TrueValue and use `~ignore~` as
  the false value so ScreenIO ignores it.
- **Function** — the Click event for a Button/Picture (Edit to pick/create a Custom Screen Function).
- **Validation** — the function run when a control's data changes; returning false/null discards input and
  restores the prior value; `Fieldtext$` is the field being validated.
- **Filter** — (Listview) "triggered for Each Row in the data file, before it is added to the listview."
- **Conversion** — how to treat the data: any valid BR field spec, `FMT`, `PIC`, or `DATE`, or your own
  conversion function for unpacking. **Special ScreenIO Date processing:** `DATE` converts disk↔display
  format both ways (works with FileIO Date features).
- **Picture File** — image path for a picture control (all BR-supported image types).
- **FG / BG Color** — control colours; **leave blank if you use Attribute Substitute statements**, since
  these override them.
- **Justification Spec** — BR justification (default left): `C` (left), `CC` (center), `CR` (right), `CU`
  (force upper), `CL` (force lower).
- **Set Listview** — (Search Boxes) the listview the search box drives.
- **Attributes** — any valid BR control/display attributes, incl. Attribute Substitution from brconfig.sys.
- **Tooltip Text** — help text (optionally your own help level; else ScreenIO picks the least-used level).
- **User Data** — free field readable/writable in your functions.
- **Protected** — excludes the field from the input statement (used because BR's protect attribute
  sometimes fails; alternatively put `P` in Attributes).
- **Invisible** — kept off the screen entirely (unlike BR's invisible attribute, which masks with
  asterisks).

### Listview Columns Editing

Enter the mode (listview becomes a grid); delete the default empty column; add fields from the Fields
listview via Enter/double-click; reorder with **Ctrl-Left / Ctrl-Right**.

### Save and Test Screen

File→Save writes the screen and compiles its helper library; Screen→Test Screen runs it in a separate BR
process. **Conclusion:** the default Add/Edit screen already adds/edits records with no custom code; most
production screens add custom code via Events and Custom Screen Functions.

---

## ScreenIO Custom Screen Functions

Custom events can initialize new records, unpack after read, validate before save, and manage
open/close; control events include listview filters and button clicks. Custom functions can modify any
ScreenIO value, including control attributes. **All screen controls are reachable via FileIO syntax in
`mat F$`/`mat F`; named non-file controls live in `mat S$` (by control name).**

### Screen (Form) Level Events

(Same set as the overview, plus:) **Listview Read** — on listview selection change, unpack data.
**Merge** — during data-merge operations. **NoKey** — when no key is provided. **Listview
Prepopulate/Postpopulate** — before/after listview population. **Default Event Functions** provide
baseline behaviour (e.g. record locking, wait timeouts) when no custom handler is supplied.

### Control-Specific Events

**Click** (buttons/pictures/captions), **Validate** (data controls — receives the value, may modify,
returns true/false), **Filter** (listviews — per-row include + optional HTML row colour).

**`fnInit_` and `fnFinal_`** — naming-convention pair: `fnInit_` runs before control processing,
`fnFinal_` after.

### Conversion Function

"You may also specify your own conversion function to be used when unpacking the data from the disk."

### Valid Custom Function Types

- **Link to another screen** — `[SCRNNAME(Row,Col)]Key$="…" : ParentKey$="…"` (all optional); simplest
  `[SCRNNAME]`. **`CurrentKey$`** is the current record's key; **`ThisParentKey$`** is the pass-through
  value (engine-ignored, used by your functions).
- **Chain statement** — transfer control to another program.
- **Any single BR command.**
- **Any valid BR Field Spec** (Conversion functions only) — `FMT`, `PIC`, `DATE`, etc.
- **Link to a Custom Screen Function** — call a developer-written BR function from an event (pick/create
  via the Edit dialog in control attributes).
- **Link to a Library Function** — call an external library function.

### Writing Screen Helper Functions

Helper functions receive ScreenIO's parameters and can read/modify screen state.

- **Custom Screen Function Parameters** — `mat F$` / `mat F` (file record), `mat S$` (named non-file
  controls), `Mat PassedData$` (caller info), control properties by name.
- **Accessing Control Properties** — "If the control is called MyControl, then you can access its
  Background Color by looking at `BgColor$(ctl_MyControl)`." All control attributes use the `ctl_` prefix.
- **#Include Statement** — pull external BR code files into the helper library.
- **Prewritten Functions** — built-in utilities for listview manipulation, navigation, validation.

### Examples

```business-rules
def fnValidateField
    if val(fieldtext$) < 0 then
        let fnValidateField=0
    else
        let fnValidateField=1
    end if
fnend
```
```business-rules
def fnFilterRecords
    if mat f$(cu_active) = "Y" then
        let fnFilterRecords=1
    else
        let fnFilterRecords=0
    end if
fnend
```
```business-rules
def fnButtonClick
    let result$=fnfm$("otherscrn")
    if result$ <> "" then
        [process result]
    end if
fnend
```
```business-rules
def fnMainloop
    [update screen values]
    [check for special keys]
    let fnMainloop=1
fnend
```

---

## ScreenIO Built-In functions & runtime variables

**`Mat S$`** — named controls not tied to a file field reserve space here; access by control name
(`Mat S$(ControlName)`), readable/writable at runtime.

### ExitMode

A special variable controlling how a screen terminates; set it from event functions to override default
exit/save behaviour.

> **⚠ Correction (source-verified).** The wiki's ExitMode constant list is garbled. The **authoritative**
> values from `screenio.brs` (`fnDefineExitModes`) are: `0` keep running · `QuitOnly=1` (cancel, ESC
> default) · `SaveAndQuit=2` · `SelectAndQuit=3` (select, ENTER default) · `QuitOther=4` ·
> `AskSaveAndQuit=5` · `Reload=6` · `AutoReload=7`. See
> [ScreenIO_Function_Reference.md#exitmode](ScreenIO_Function_Reference.md#exitmode).

### Working with Listviews

`Mat F$` / `Mat F` hold the selected row's record; `Mat SelectedKeys$` and `Mat SelectedRecords` give all
selected keys/records when multiselect is on; `ParentKey$` in a filter restricts displayed records.

### Loading Icon & clock animations

The animated loading icon appears automatically when a listview is slow to load. Change it via `ClockPath$`
in `screenio.ini`. Custom animations are a series of image frames plus a `clock.ini` config (frame timing,
image references, dimensions; BR config syntax) — frames use BR-supported image formats.

### Keyboard Reference

Movement mode: **Arrows** move · **Backspace** narrow · **Space** widen · **PgUp/PgDn** resize vertically ·
**Enter** toggle movement/attributes · **F6** redraw movement grid. Listview editing: **Ctrl-Left /
Ctrl-Right** reorder columns. General: **Esc** = Cancel exit · **Enter** = Select exit. Multi-select:
**Shift-Click** / **Shift-Arrow**.

### Support for New FileIO Dates

Via the Conversion field's `DATE` spec: automatic disk↔display conversion; user input supports natural and
**relative** dates (e.g. `+5` = five days forward, `+2w` = two weeks); the year may be omitted (defaults
to the current year).

### Useful ScreenIO Functions

*For use inside your ScreenIO functions:* **`fnFunctionBase`** (base FKEY/index for the screen's function
dispatch), **`fnIsOutputSpec` / `fnIsInputSpec`** (classify a field-type code), **`fnGetUniqueName$`**
(collision-free control name), **`fnFindSubscript`** (index of a value/subscript in an array).
*For your own programs:* **Animations** (`fnPrepareAnimation`/`fnAnimate`/`fnCloseAnimation`),
**`fnDays`** (days between dates / relative arithmetic), **`fnBr42` / `fnBr43`** (BR ≥ 4.2 / ≥ 4.3
detection), **`fnListSpec$`** (the manual's description is "build a listview column spec from
width/justification/type"; the v2.95 source does something narrower: see the note below).
*To interact with the Designer:* **`fnDesignScreen`** (launch the Designer, optional screen to load),
**`fnSelectEvent$`** (dialog to select/create an event handler; returns the function name).

> Authoritative signatures for the exported helpers are in
> [ScreenIO_Function_Reference.md](ScreenIO_Function_Reference.md). `fnListSpec$` and
> `fnDesignScreen` were missing from the earlier 16-export build, but **are** `DEF LIBRARY` exports in
> ScreenIO v2.95 (21 exports). In v2.95 `fnListSpec$(SpecIn$)` only returns its argument cut before the
> third comma (the `row,col,LIST rows/cols` head of a listview spec). It does not build a spec from
> width, justification and type, as the manual says. Trust the
> [Function Reference](ScreenIO_Function_Reference.md#helpers) over the manual here.

### Update Process / Future Changes

Updates ship from Sage AX as replacement library files; **Recompile All Screens** regenerates helper
libraries after an update. The wiki tracks *New Future Change Requests* (proposed) and *Completed Future
Change Requests* (a per-version implemented-features log).

---

## Attribution

ScreenIO Library © Sage AX (Gabriel Bakker). Source manual:
. Captured here for local development
reference, alongside the source-derived
[Function Reference](ScreenIO_Function_Reference.md) and [Data Model](ScreenIO_Data_Model.md).
