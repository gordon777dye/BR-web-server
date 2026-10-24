---
title: GUI controls
file: spec.md
source: §Screen Operations → Graphical Controls, Field Help; br_tree control pages folded in & pruned (2b) — Display_Menu retained for deep detail
category: 20-io-screen
subcategory: 20-io-screen/controls
kind: spec
status: 2b           # reference base + br_tree enrichment
recovered-fold: 2D_Controls, CELL_RANGE, COLCNT, Combo_Boxes, Display_Buttons, RANGE folded+pruned; Grid_and_List retained (deep grid/list reference). 7 redirect-collision pages re-fetched; verbatim retained on the BR wiki
related: [input-output, fields-attributes, windows-cursor]
keywords: [GRID, LIST, TEXT, COMBO, RADIO, CHECK, MENU, FIELDS, BUTTON, BUTTONS, BUTTONROWS, MENU$]
corrections:
  - "BUTTONS added to the frontmatter keywords. The list held `BUTTON`, singular, which is not a spelling any of BR's keyword tables carries: table4k's entry is `BUTTONS`, and this page documents it as `DISPLAY BUTTONS MAT X$: MAT Y$`. Routing is an exact match, so the declaration missed by one letter and the keyword reached nothing. `BUTTON` is kept — it is the control's name in the page's own prose. Found in brls phase 13."
  - "MENU$ added to the frontmatter keywords — a distinct spelling from the already-declared `MENU`
    (the `DISPLAY MENU` statement keyword, table4k), routed separately because routing is an exact
    match. `MENU$` is the function returning the last menu option selected, documented in this
    page's body and in the retained Display_Menu.md backing page, and was routing nowhere. Found
    2026-09-11 auditing `go run ./cmd/gendata`'s unrouted-function list against actual br_tree
    content."
---

# GUI controls

Graphical controls built on `FIELDS`: combo boxes, radio buttons, check boxes, buttons, text boxes,
date pickers, grids/lists, native menus, plus field help. They share the FIELDS statement and
attribute machinery in [input-output](../input-output/spec.md) and
[fields-attributes](../fields-attributes/spec.md); selection/clicks return values via the `FKEY`
system variable.

<a id="syntax"></a>
## Syntax

```bnf
PRINT  FIELDS "<r>,<c>[,<disp>/]COMBO <data-cols>,{=|+|-}[,SELECT][,<fkey>]": MAT <array>
INPUT  FIELDS "<r>,<c>[,<disp>/]COMBO <data-cols>[,<attrs>]": <var>
{P|I|RI}NPUT FIELDS "<r>,<c>,RADIO <cols>[,<group>][<attrs>][,<fkey>][,NOWAIT]": "[^]<caption>"
{P|I|RI}NPUT FIELDS "<r>,<c>,CHECK <cols>[<attrs>][,<fkey>][,NOWAIT]": "[^]<caption>"
PRINT  FIELDS "<r>,<c>,CC <cols>,,B<fkey>": "<caption>"                 -- Print-Fields button
{P|I|RI}NPUT FIELDS "<r>,<c>,TEXT <rows>/<cols>/<maxchar>[,<attrs>]": <var$>   -- multi-line text box
PRINT  FIELDS "<r>,<c>,{GRID|LIST} <rows>/<cols>,HEADERS[,<fkey>]": (MAT <head$>, MAT <width>, MAT <form$>)
PRINT  FIELDS "<r>,<c>,{GRID|LIST} <rows>/<cols>,{=|+|-}[{R|C|L|S}]": MAT <data> | (MAT <col1>, …)
INPUT  FIELDS "<r>,<c>,{GRID|LIST} <rows>/<cols>,<read-type>,<selection>[,<qual>][,<fkey>]": <vars>
PRINT  FIELDS "<r>,<c>,LIST <rows>/<cols>,GRIDLINES": 1 | 0           -- show grid lines on a LIST

DISPLAY [#<win>,] MENU: MAT <text$>, MAT <data$>, MAT <status$>      -- show/update a native menu
INPUT   MENU [TEXT|DATA|STATUS]: MAT <text$>[, MAT <data$>, MAT <status$>]   -- read current menu
```

<a id="semantics"></a>
## Semantics

<a id="combo"></a>**Combo box** — really a **text field** (implied `Q` dropdown attribute) plus a drop-down
list. Three steps: `PRINT FIELDS "…,[disp/]COMBO data-cols,{=|+|-}[,SELECT][,fkey]": MAT list$`
populates the *drop-down* (`=` replace / `+` append / `-` insert); an optional `PRINT` sets the text
field's default value; `INPUT`/`RINPUT FIELDS` reads the *text field* (it behaves like any text field,
so combos can be grouped into one `RINPUT` with other fields by pre-populating them). Pressing Enter
takes an Enter action; selecting a *new* value with the mouse fires the trailing `fkey` — unrelated to
the drop-down, and **`OPTION 48`** makes Enter behave like a mouse double-click. **`SELECT`** (4.20+)
restricts the control to drop-down choices only (no typing) and **must** be given when the combo is
*created* — adding it to an existing combo raises an error. Combos are **single-column**; for a
multi-column drop-down use the `Q` attribute with a `LIST` in its own child window so it doesn't
clobber underlying controls. (A combo carrying the `x` attribute can return `FKEY` **209** — loop with
`LET CURFLD(CURFLD,FKEY)` to stop blinking; see [windows-cursor](../windows-cursor/spec.md#keyboard-results).)

<a id="radio"></a>**Radio buttons** — mutually exclusive within a **group** (the number after `cols`);
the selected caption is prefixed `^`. `RINPUT` shows and updates the selection; test
`X$(1:1)="^"` to find which is set. An optional `fkey` fires on selection.

<a id="check"></a>**Check boxes** — like radio buttons but **not grouped** (independent); each stores
its checked state as a leading `^`. The three verbs differ: `PRINT FIELDS` shows label+box but no
selection; `INPUT FIELDS` shows the box (no label — pair with a separate `PRINT FIELDS` label);
`RINPUT FIELDS` shows both and allows selection. Each may carry its own `fkey` (fires on/off);
`NOWAIT` = the `G` attribute (return control immediately). Commonly looped until a Done button.

<a id="buttons"></a>**Buttons** — two kinds: **Display Buttons** print into the button panel at the
**bottom** of the window that `BUTTONROWS=<n>` reserves (see
[windows-cursor §semantics](../windows-cursor/spec.md#semantics)) — `DISPLAY BUTTONS MAT X$: MAT Y$`,
where each `X$` uses the **same field spec as `PRINT FIELDS`** —
`"row,col,caption-form-spec,attributes,fkey-or-hex-scancode"` — **except the `B` prefix is not needed
in the fkey field** (a Display Button is already a button, so the fkey value stands alone). `Y$` is the
caption; `P` in the attributes disables/greys a button. A click returns the given FKEY and raises an
FKEY interrupt; instead of a numeric FKEY you may give a two-digit **hex scancode** (`X02`) for
`KSTAT$` consistency (so a clicked button and its key yield the same scancode — e.g. `X02` = Ctrl-B =
PgUp = FKEY 90). **Print-Fields Buttons** (`CC <cols>,,B<fkey>`, 4.2+) can go *anywhere* and set
`FKEY` to the given number; the program tests `FKEY` to dispatch (Done/OK/Cancel). The window open
string `BUTTONROWS=nn` parameter sizes the button panel (`0` supported 4.20+; the default is also
settable via `SCREEN OPENDFLT`) — see
[windows-cursor §semantics](../windows-cursor/spec.md#semantics) for two easy-to-miss constraints:
`BUTTONROWS=` must be set *before* the first `DISPLAY BUTTONS`, and the panel belongs to window #0 as
a whole, not to whichever window issues the statement.

<a id="text"></a>**Multi-line text box** — `TEXT <rows>/<cols>/<maxchar>` via `INPUT/RINPUT FIELDS`;
dimension the variable to at least `<maxchar>` (e.g. `DIM Buff$*2048`).

<a id="date-picker"></a>**Date picker** — appears on a `DATE` field; the
`DATE {ALWAYS|INVALID|NEVER}` config statement controls when (default `INVALID` = only when the
date's days-value is 0), or force it with the `^DATE_PICKER` leading attribute. `Ctrl-DownArrow`
opens it (also opens a combo); inside the picker, `Shift-PgUp/PgDn` = prev/next month,
`Ctrl-PgUp/PgDn` = prev/next year.

<a id="grid-list"></a>**Grid / List (2-D)** — `GRID` is editable, `LIST` is read-only selection.
Always send **HEADERS** first `(MAT headings$, MAT widths, MAT forms$)`, then populate with `=`
(replace) / `+` (append) / `-` (insert). Read back with read-types (`ROWCNT`, `ROWSUB`, `ROW`,
`CELL`, `CHG` for grid; **`COLCNT`** = number of columns defined by the HEADERS arrays; grid-only:
`CNT`, `SUB`, `CELL`, and selection `CHG` = items edited since the last `=`) and selections (`SEL`,
`ALL`, `CUR`, `RANGE`, **`CELL_RANGE`** — a special cell-output range). The `DISPLAYED_ORDER`
qualifier (4.30+, with `ALL`) returns rows in their current on-screen order rather than the original
order. Cell subscript = `(row-1)*cols + col`.
`RINPUT` does **not** work with 2-D controls. Columns sort on header click (display only — file
order unchanged; the `NOSORT` parameter suppresses column sorting); `CURROW`/`CURCOL` give the
active cell. `GRIDLINES 1|0` makes a LIST show grid
lines; the `GRID_CURSOR_MOVE {DOWN|RIGHT|NONE|DEFAULT}` config (4.2+) sets cursor movement after
Enter / Field +/-. A **2-D control** is one BR must do vertical/line math for — GRID, LIST, COMBO;
radio buttons and check boxes are **1-D**. `PRINT FIELDS "…,GRID …,ATTR": (MAT start, MAT end, MAT
attr$)` overrides the display attributes of a *range* of cells/rows (shading, or `P` to protect);
clear an override by printing a **null** attribute spec to the same cells. `AEX` and `P` are also
honored in HEADERS column attributes. Populate flags: primary `=`/`+`/`-` (replace / append /
insert-ahead, `-` is 4.16+), secondary `R` (row at a time — default), `C` (column at a time, for
same-type columns), `L` (fire the FKEY/Enter interrupt when the user arrows/pages past the first/last
field), `S` (single-click activates, 4.17+). Other operations: **`SORT`** sorts programmatically
(`PRINT FIELDS "…,SORT": colnum` — repeat the same column to reverse; 4.3+ also takes a
`SORT_ORDER`-style array); the **`SORT_ORDER`** read-type reports the current order (0 = unsorted,
negative = reversed); **`MASK`** (4.3+) filters displayed rows to a true/`T` array (the search-bar-like
`FILTER` field works too); **`RANGE`**/**`CELL_RANGE`** read or replace row/cell ranges and can
insert/delete by sizing the data arrays larger/smaller (deletion only on row boundaries). Columns of
**zero width** serve as *hidden* columns (stash record numbers/keys); `^nosort` in a column's FORM
blocks user sorting of it; `^select`/`^deselect` pre-select elements; sorting is **aggregate** (equal
values keep prior order, 4.2) and **numeric/DATE-aware**. 1-D receiving arrays are **auto-resized** on
2D INPUT (4.3+), and string arrays auto-`VAL`/`STR` convert against numeric column types (4.2). Full
grid/list reference: [Grid_and_List](Grid_and_List.md).

<a id="menus"></a>**Native menus (Windows only)** — define three parallel arrays: `MAT text$`
(captions; leading spaces = submenu depth; `"-"` = separator; `&` marks the accelerator key),
`MAT data$` (the value returned for each item), `MAT status$` (codes below). `DISPLAY MENU:` shows
it; `INPUT MENU[ TEXT|DATA|STATUS]:` reads the current state (it does **not** wait — use `KSTAT$`
or `INPUT FIELDS`; a menu click gives `KSTAT$` = 6200 and, 3.92I+, `FKEY` = 98). `MENU$` returns the
selected item's data, `MENU` its subscript. Status codes: `E` send FKEY 98 (no submenu), `P`
protect/grey, `C` checkable, `X` checked (with C), `R` retain across program end/CHAIN. Full grammar
and examples in [Display_Menu](Display_Menu.md).

<a id="picture"></a>**Picture / image field** — `P` (or `PICTURE`) `rows/cols` displays an image file
(`PRINT/INPUT/RINPUT FIELDS`); a trailing `,<fkey>` makes it clickable (returns that FKEY). The IO
string holds the filename; `:NORESIZE|TILE|ISOTROPIC` control sizing. An image can also be a window's
NEWPAGE background (`SCREEN OPENDFLT … Picture=` or `OPEN #0: "…Picture=…"`). Many formats (JPG/PNG/
BMP/GIF/TIFF/…). Deep detail: [Picture](Picture.md).

<a id="help"></a>
### Field help
`INPUT/RINPUT FIELDS … , HELP <help-specs>` attaches per-field help. A spec is
`<priority><placement><sep><text><sep>`: priority `1`–`4` (1 always shows … `4` tooltip only,
per `USERLEVEL`); placement `A`/`B`/`L`/`R` or a window channel; the char after placement is the
text separator. `&<n>;` reuses a prior field's help. (`X` = no help on that field.)

<a id="examples"></a>
## Examples

```business-rules
! Radio group + button dispatch
00180 RINPUT FIELDS "13,5,RADIO 10,2,8;14,5,RADIO 7,2,9": X$,Y$
00340 PRINT FIELDS "23,30,CC 8,,B99": "Done"
00350 DO : INPUT FIELDS "2,2,C 10": DUMMY$ : LOOP WHILE FKEY~=99

! Check boxes looped until Esc
00400 RINPUT FIELDS "1,1,CHECK 8,,10;2,1,CHECK 8,,11": X$,Y$
00600 LOOP WHILE FKEY~=99

! Grid: headers then data
00310 PRINT FIELDS "5,10,GRID 15/70,HEADERS": (MAT HEADERS$, MAT WIDTHS, MAT FORMS$)
00430 PRINT FIELDS "5,10,GRID 15/70,=": (MAT NAMES$, MAT CITIES$, MAT AGES, MAT WEIGHTS)
00510 INPUT FIELDS "5,10,GRID 15/70,ROWCNT,CHG": CHANGED_ROWS

! Multi-line text box + field help
00010 DIM BUFF$*2048
00020 RINPUT FIELDS "#0,5,2,TEXT 14/58/20,[D]S": BUFF$
00100 INPUT FIELDS "10,10,C 20,U", HELP "2B;Enter customer name;": NAME$
```

<a id="see-also"></a>
## See also

- [input-output](../input-output/spec.md) — the underlying FIELDS statements & `FKEY`
- [fields-attributes](../fields-attributes/spec.md) — formats/attributes used by controls
- [windows-cursor](../windows-cursor/spec.md) — `FIELDHELP`/`Help_Facility`, cursor position functions
- [system-functions](../../10-language/data-manipulation/system-functions/spec.md#screen-query) — `NXTFLD`/`NXTROW`/`CURTAB`/`KSTAT$` for 2-D control clicks
- Backing keyword pages (deep detail retained): [Display_Menu](Display_Menu.md), [Picture](Picture.md),
  [Grid_and_List](Grid_and_List.md) (full 2-D control reference — re-fetched and retained in 2b),
  [Properties,_Events,_and_Methods_(PEM)_and_.NET_controls](Properties,_Events,_and_Methods_(PEM)_and_.NET_controls.md)
  (embedding interactive `.NET` controls in a BR window — relocated here from config-directives in 2b). The 2b
  redirect-collision pages `2D_Controls`, `Cell_Range`, `ColCnt`, `Combo_Boxes`, `Display_Buttons` and
  `Range` were folded here and pruned; verbatim wikitext remains on the BR wiki.
