---
title: Screen input/output (FIELDS)
file: spec.md
source: §Screen Operations → Full Screen Processing
category: 20-io-screen
subcategory: 20-io-screen/input-output
kind: spec
status: 2b           # reference base + br_tree enrichment (INPUT SELECT, MAT grouping); no conflicts
recovered-fold: Field_Help, Full_Screen_Processing_Statements, INPUT_FIELDS, PRINT_FIELDS (4 redirect-collision pages folded from re-fetched source — multi-window input, 4.17 field-windowing syntax, hot-field fkey ranges + 10000=Enter, ATTR MAT, field-help spec; verbatim retained on the BR wiki)
related: [fields-attributes, controls, windows-cursor]
keywords: [PRINT FIELDS, INPUT FIELDS, RINPUT FIELDS, INPUT SELECT, RINPUT SELECT, INPUT, LINPUT, RINPUT, SELECT, ATTR, HELP, "WAIT="]
corrections:
  - "2026-11-23: WAIT= added to the BNF of plain INPUT, LINPUT and RINPUT (a `<source>` of `#channel[, WAIT=n]:` or `WAIT=n:`) and of INPUT/RINPUT FIELDS (between ATTR and HELP), where BR's syntax trees put it. The WAIT= bullet already said all of these accept it; the BNF did not show it. `INPUT #6, WAIT=1: I$` and `LINPUT #6, WAIT=1: L$` were run headless against a display file and read the line. WAIT= added to the keywords."
  - "ATTR and HELP added to the frontmatter keywords. Both appear in this page's BNF for INPUT/RINPUT FIELDS — `[',' ATTR <attrs>] [',' HELP <help>]` — and in its semantics, and neither was declared. Found in brls phase 13."
---

# Screen input/output (FIELDS)

Full-screen data entry: positioning text and input at any row/column with `PRINT FIELDS`,
`INPUT FIELDS`, and `RINPUT FIELDS`. Field **formats and attributes** are in
[fields-attributes](../fields-attributes/spec.md); GUI **controls** (buttons, grids, …) in
[controls](../controls/spec.md); **windows** in [windows-cursor](../windows-cursor/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
PRINT  ['#'<window>,] FIELDS <field-specs> ':' <expression-list>
INPUT  ['#'<window>,] FIELDS <field-specs> [',' ATTR <attrs>] [',' 'WAIT=' <seconds>] [',' HELP <help>] ':' <io-list> [<error-cond>]
RINPUT ['#'<window>,] FIELDS <field-specs> [',' ATTR <attrs>] [',' 'WAIT=' <seconds>] [',' HELP <help>] ':' <io-list> [<error-cond>]

<field-specs> ::= '"' <field-def> [ ';' <field-def> ]* '"'   -- one or more fields
                | MAT <string-array>                          -- array of field definitions
<field-def>   ::= <row> ',' <col> ',' <format> [ ',' <attributes> ]
<row> ::= 1-24    <col> ::= 1-80     -- default screen
```

<a id="semantics"></a>
## Semantics

- **PRINT FIELDS** displays values at positions; **INPUT FIELDS** accepts entry; **RINPUT FIELDS**
  ("reverse input") shows current values *and* accepts changes (PRINT + INPUT combined). Abbreviations:
  `PR F` / `IN F` / `RI F` (and `IN S` / `RI S` for SELECT). **PRINT FIELDS ignores control attributes**
  (only monochrome/color attributes apply), and an `FMT` spec on output behaves as plain `C` — no
  formatting or validation is done on output.
- A field def is `row, col, format[, attributes]` (see
  [fields-attributes](../fields-attributes/spec.md#format-codes)). Multiple fields are separated
  by `;` in one string, or supplied as a `MAT` of definition strings for array processing.
- **Field windowing** lets a field accept more text than it displays. As of **4.17** the syntax is
  `<disp>/<format> <max>` — `"10,5,8/C 12,UH"` shows 8 chars but accepts 12 (the pre-4.17 form was
  `C 8/12`).
- Always bracket full-screen sections with `PRINT NEWPAGE`, and don't mix them with ordinary
  bottom-line `PRINT`/`INPUT`.
- **Error conditions**: `CONV` (wrong type), `EXIT` (Esc), `HELP` (Help key), `SOFLOW` (overflow).

<a id="multiple-fields"></a>
### Multiple-field processing
One statement can process many fields as a unit (via `;` list or `MAT`). Control attributes drive
flow: `A` auto-advances, `AE` on the last field auto-submits, `C` sets initial cursor focus; `ENTER`
submits the whole group. (Attribute letters: [fields-attributes](../fields-attributes/spec.md#control-attributes).)
- **MAT grouping** — parenthesizing several `MAT`s in the I/O list alternates assignment across them:
  `INPUT FIELDS A$: (MAT B$, MAT C), X$` fills B$(1), C(1), B$(2), C(2), … (faster, far larger arrays
  than spelling them out). Up to 62 MATs, all the same length (else error 0106); MAT variables only.
- **Input across multiple windows** (4.3): a `#<win>,` prefix *inside* a field def overrides the
  statement's window, so one statement can span windows —
  `INPUT FIELDS #121: "10,10,C 20;#124,10,10,C 30": a$,b$`.
- **Per-field current attribute**: `ATTR MAT <attr$>` supplies a different highlight per field (ideal
  for multi-select `INPUT SELECT`); it is compiled for attributes only and reuses the first if too few.
- **Hot fields**: a trailing fkey value makes a field clickable; valid ranges are **1–128** (90–99 are
  reserved) and **1000–9999**, and the special value **10000 = Enter** (yields fkey 0). `NOWAIT`
  raises a Tab (returns without waiting). *(The old `X'xx'` hex-scancode trailing attribute was removed —
  use numeric fkey values.)*

<a id="select"></a>
### INPUT / RINPUT SELECT — menu selection
`INPUT SELECT` (and `RINPUT SELECT`) reuse the FIELDS machinery for **menu choice**: the syntax is
identical to `INPUT FIELDS` but with the `SELECT` keyword. It does **not** change field data — it
just sets [`CMDKEY`](../windows-cursor/spec.md) and [`CURFLD`](../windows-cursor/spec.md) when the
operator picks a field with Enter / a function key / a control key. Navigation: typing a character
jumps to the next field whose first matching (upper)case char matches; arrows / Tab / Shift-Tab move
field to field. `ATTR "<attrs>"` highlights the current field (e.g. `ATTR "R"`); `HELP` attaches
per-field help windows (shown when `USERLEVEL` ≠ 0).
```business-rules
00150 PRINT FIELDS FSPEC$: MAT MENU$
00160 INPUT SELECT FSPEC$, ATTR "R", HELP C$: MAT MENU$   ! sets CMDKEY + CURFLD on pick
```

<a id="field-help"></a>
### Field help
`INPUT/RINPUT FIELDS … , HELP "<helpstring>"` attaches per-field help (also usable on `PRINT FIELDS`
buttons); the helpstring is one `;`-separated spec per field: `<level><placement>[<|>]<sep><text><sep>`,
or `X` (no help on that field), or `&<n>;` (reuse field n's text — backward references only). **Level
1–4** is the `USERLEVEL` at/below which the help auto-displays (`1` important/everyone … `3` novices;
**`4` = Windows tooltip only**, suppressing help windows — the recommended setting, 4.2; `USERLEVEL 0`
disables all auto-display, though `<HELP>` still shows it). **Placement** is `A`/`B`/`L`/`R` (add `<`/`>`
for flush-left/right), or an **open window number 1–999** to render the help *into* that window — a big
optimization that avoids repainting per field (especially on Unix/Linux terminals). Text uses `\n` or
`CHR$(10)` for line breaks (max **78 chars/line**; up to 1000 shown, ~100 practical); the separator must
be a non-alphanumeric character absent from the text. Border/attributes come from the BRConfig.sys
`FIELDHELP` directive. (Format/attribute summary in [controls §help](../controls/spec.md#help).)

<a id="plain-input"></a>
### Plain (non-FIELDS) keyboard input
Bottom-line input without positioning:
```bnf
INPUT  [<source>] <variable-list> [ CONV <ref> ] [ SOFLOW <ref> ] [ EOF <ref> ] [ TIMEOUT <ref> ]
LINPUT [<source>] <string-variable> [ TIMEOUT <ref> ]            -- whole line, including commas/punctuation
RINPUT [<source>] <variable> [ TIMEOUT <ref> ]                   -- single variable: prints its current value, then prompts for a replacement
<source> ::= '#'<channel> [ ',' 'WAIT=' <seconds> ] ':'
           | 'WAIT=' <seconds> ':'                                -- the keyboard, with a timeout (see WAIT= below)
```
`INPUT` reads comma-separated values into the list (type-checked for numerics; `CONV`/`SOFLOW`
handle bad data) — it takes **no prompt argument** (`INPUT "X", A$` does not compile; emit the
prompt with a separate `PRINT` first). <a id="linput"></a>`LINPUT` reads an entire line into one string. Plain
`RINPUT <var>` ("reverse input") prints the current value and prompts for a replacement; it is
seldom used because `RINPUT FIELDS` is preferred (it accepts a single variable only, not a list).
Program-driven plain `PRINT`
(zone/concatenated output) is in
[40-io-printing/statements](../../40-io-printing/statements/spec.md). In **INPUT mode** the status
line shows "INPUT" and the program waits for Enter. `INPUT`/`LINPUT`/`RINPUT` all honor an input
timeout: a `WAIT=<sec>` in effect arms a `TIMEOUT` trap (**error 4145**) when no input arrives in time
(`WAIT=0` = no wait, `WAIT=-1` = wait forever, reset on each keypress).

<a id="input-details"></a>
**Plain `INPUT`, in more detail.** The full form is
`INPUT [#<file>:] {<variable>|MAT <array>}[, …] [<condition> <line>]…`.
- **Where the data comes from.** The keyboard by default (no file number, or `#0`); the next records of a procedure
  file when the program was started with `RUN PROC`; or a file or window already opened, named by `#<number>:`: a
  display file, a communications file or a window file. From a display file the record is read as if it were typed,
  so it must hold the right number of items, separated by commas; extra values left in the record after the last
  variable has been given its value are ignored.
- **Error conditions** that can be trapped: `CONV`, `EOF`, `ERROR`, `EXIT`, `HELP`, `IOERR` and `SOFLOW`.
  With none active an error interrupts the program.
- **Typing.** A numeric item may be entered with an exponent (`5.2E3` is 5200, `-5.2e+3` is -520, `+5e-4` is .0005).
  A forward slash `/` as the last character typed ends a multi-variable `INPUT` without an error: the slash is not
  read, and the variables not yet read are **not changed**, so they can keep default values (this also holds for
  `RUN PROC` and display files). With `OPTION INVP` a comma, not a period, is the decimal point. Control characters
  are not accepted as input.
- **Choosing the right statement.** To take a whole record, `LINPUT` is preferred unless the fields are separated by
  commas; `INPUT` must not be used with `EOL=NONE` for a display or communications file (`LINPUT` reads up to the
  string's maximum length instead). To wait for any response, use `LINPUT A$`: `INPUT A$` gives error **0501**
  (no data was entered) if only Enter is pressed.
- **Type-ahead.** BR buffers keystrokes (up to 128) so none are lost between `INPUT` statements, and passes them to
  `INPUT` or `KSTAT$`. Ctrl-A clears everything typed ahead of it and is seen at once. Function keys and the Help key
  are also recognised unless `ON FNKEY IGNORE` or `ON HELP IGNORE` is in effect. The BRConfig.sys
  [`TYPEAHEAD`](../../00-configuration/config-directives/spec.md#typeahead) setting turns the buffering off.
- **`WAIT=`.** `WAIT=<seconds>` before the variables makes BR wait that long for input and then raise the `TIMEOUT`
  condition (error **4145**). `WAIT=0` waits zero seconds (it does not ignore the clause), and `WAIT=-1` waits as long
  as it takes, the clock restarting at each key. It is accepted by `INPUT`, `RINPUT`, `LINPUT` and the `FIELDS`/`SELECT`
  forms:

  ```text
  00100 INPUT WAIT=10:X$ TIMEOUT 100
  00130 INPUT FIELDS "10,10,C 10", WAIT=10:X$ TIMEOUT 100
  00160 INPUT SELECT "10,10,C 10",WAIT=10:X$ TIMEOUT 100
  ```

  The `TIMEOUT` routine is the place to `RELEASE` records the operator was holding, after a warning and an
  invitation to carry on, in multi-user programs. See also `KSTAT$`, which takes a `WAIT` too.

<a id="navigation"></a>
### Navigation keys
`Tab`/`Shift+Tab` next/prev field · `Enter` next field (unless NOWAIT) / submit group · `F1` field
help · `Esc` cancel · `PgUp`/`PgDn` scroll grids · `Home`/`End` field start/end ·
`Ctrl+Home`/`Ctrl+End` first/last field.

<a id="examples"></a>
## Examples

```business-rules
00100 PRINT NEWPAGE
00110 PRINT FIELDS "5,10,C 20": "Enter Name:"
00120 INPUT FIELDS "5,31,C 30,U": NAME$
00140 INPUT FIELDS "7,31,N 10.2": AMOUNT

! Multiple fields from a MAT (auto-advance, last auto-enters)
00110 DATA "8,15,C 30,A","10,15,C 40,A","14,15,C 12,AE"
00130 READ MAT FLDDEF$
00190 RINPUT FIELDS MAT FLDDEF$: NAME$, ADDR$, PHONE$

! Password masking with the I attribute
00140 INPUT FIELDS "12,26,C 20,I": PASSWORD$
```

<a id="see-also"></a>
## See also

- [fields-attributes](../fields-attributes/spec.md) — formats (`C`/`N`/`PIC`/`DATE`/`TEXT`) and attributes
- [controls](../controls/spec.md) — combo/radio/check/buttons/grid built on FIELDS
- [windows-cursor](../windows-cursor/spec.md) — windowed FIELDS (`PRINT #w, FIELDS …`)
- (Backing keyword pages folded into this spec and pruned. Buttons → [controls](../controls/spec.md); TEXT `^ENTER_LF`/`^ENTER_CRLF` → [fields-attributes](../fields-attributes/spec.md). The 2b redirect-collision pages `Input_Fields`, `Print_Fields`, `Field_Help` and `Full_Screen_Processing_Statements` were folded here and pruned; verbatim wikitext remains on the BR wiki.)
