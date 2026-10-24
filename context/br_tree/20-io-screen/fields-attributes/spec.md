---
title: Field formats & attributes
file: spec.md
source: §Screen Operations → Format Specifications, Screen Attributes; br_tree format/attribute pages folded in & pruned (2b) — Format_Specifications/Attribute_(Screen)/HTML_Color_Table retained
category: 20-io-screen
subcategory: 20-io-screen/fields-attributes
kind: spec
status: 2b           # reference base + br_tree enrichment; L/^ resolved (br_tree wins): L=scroll-out, ^ dropped
related: [input-output, controls, windows-cursor]
keywords: [FMT, PIC, attribute, FILTER, color, DATE, CU, CL, GU, GL, VL, VU]
corrections:
  - "keywords: `CU`, `CL`, `GU`, `GL`, `VL`, `VU` added. These are the case-converting **screen** field codes and are absent from BR's FORM format table altogether — using one in a FORM raises error 1006, as the form-spec leaf says. `GU`/`GL` routed nowhere at all; the others were briefly routed to form-spec while its keyword roster was being completed, which sends a reader looking one up to the page saying it does not work there rather than to the page that documents it. This spec is their home. Found in brls phase 10."
---

# Field formats & attributes

The `format` and `attributes` parts of a FIELDS definition — what a field looks like and how it
behaves. The statements that use them are in [input-output](../input-output/spec.md). Reusable
attribute/font names defined in BRConfig.sys live under
[00-configuration/config-directives](../../00-configuration/config-directives/spec.md).

<a id="format-codes"></a>
## Tables — format specifications

```bnf
<format-spec> ::= <string-format>[<length>[/<capacity>]] | <numeric-format> <length>[.<dec>][/<capacity>]
                | PIC(<picture>) | FMT(<identifiers>) | DATE(<mask>)
                | TEXT <rows>/<cols>[/<capacity>] | FILTER
```

| Format | Meaning |
|---|---|
| `C n` / `CR` / `CC` / `CU` / `CL` | Character: left / right / center / upper / lower |
| `V n` / `VU` / `VL` | Variable (trims trailing spaces): normal / upper / lower |
| `N n[.d]` / `NZ` / `NL` | Numeric right-aligned / zero-suppressed / leading-sign |
| `G n` / `GZ` | General (char or numeric) / zero-suppressed |
| `B n` / `L n` | Binary / Long (binary storage - FORM only) |
| `PIC(picture)` | Picture format with insertion chars (numeric-oriented) |
| `FMT(identifiers)` | Validated/formatted field (string-oriented; see below) |
| `DATE(mask)` | Display as date, stored numerically (day-of-century) — enables numeric sort |
| `TEXT rows/cols[/cap]` | Multi-line text box (`^ENTER_LF` default, `^ENTER_CRLF`, `^NOWRAP`; Ctrl+ENTER returns) |
| `FILTER` | Search/filter field for LIST/GRID controls |

**Field capacity override**: `displayed-length/capacity` shows fewer columns than the
field's capacity — e.g. `"5,10,N 10.2/7"`, `"9,10,C 20/25"`. Full format×context usage matrix
(which codes are legal for READ/WRITE/PRINT/INPUT FIELDS): [Format_Specifications](Format_Specifications.md).

<a id="fmt"></a>
### FMT — validated field formatting
`FMT(<identifiers>)` (up to 40) validates input as it is typed (beeps on a bad character) and can
display one logical field as several visual parts split by **insertion characters** (any
non-identifier char, shown but not stored). Best for **strings** (`PIC` is for numerics — see
[FMT_vs_PIC]); `#FMT(...)` / `#PIC` / `#G` process string data **numerically** (4.3+).

| Id | Allows / does |
|---|---|
| `9` | digit 0–9 |
| `a` | letter, case as entered |
| `G` / `g` | letter or digit, force upper / lower |
| `X` / `x` | any char, force upper / lower |
| `Y` / `y` | only Y/N, force upper / lower |
| `P` | protected (cursor skips, value retained) |
| `R` | right-flush this part, then apply the next identifier |
| `#` | right-flush **and zero-fill** this part, then apply the next identifier |

Example: `INPUT FIELDS "10,10,FMT(RAAA-#999),AE":X$` → 4 alpha (uppercased) + dash + 4 numeric
(zero-filled), e.g. `ABCD-1234`, `ACB-0001`.

<a id="attributes"></a>
## Semantics — attributes

#### Screen Attributes

Attributes control appearance and behavior of fields. They consist of three optional components:

```bnf
<attributes> ::= [<control-attrs>][<display-attrs>][/<color-attrs>]
```

##### Display Attributes
Legacy monochrome attributes (still supported):
- `B` - Blink (deprecated)
- `H` - Highlight (brighter text, deprecated) 
- `U` - Underline (deprecated)
- `R` - Reverse video (dark on light)
- `N` - Normal (reset to default)
- `I` - Invisible/Password field (4.17+: displays as asterisks or dots)
- `S` - Sunken/3D appearance (PRINT FIELDS only)

##### Color Attributes
```bnf
/<foreground>[:<background>]
```

**Basic Colors:**
- `R` - Red
- `G` - Green  
- `B` - Blue
- `H` - Grey
- `W` - Windows default (black on grey)
- `T` - Transparent (default black foreground)

**Color Combinations:**
- `BG` - Light blue (Blue + Green = Cyan)
- `RB` - Purple/Magenta (Red + Blue)
- `RG` - Olive/Yellow (Red + Green)
- `BGR` - White (all colors)

**Hexadecimal Colors:**
```bnf
/#RRGGBB[:#RRGGBB]
```
Example: `/#228B22:#CC99FF` (forest green on light purple)

**Color Priority (4.17+):**
When multiple color specs are present, priority is:
1. #RRGGBB style values (highest)
2. W (Windows system colors)
3. HRGB values (lowest)

This allows specifying fallback colors for different display types.

##### Control Attributes
Control field input behavior:

- `A` - Auto-advance to next field when current field filled
- `E` - Enter (submit all fields) when exited with changes
- `AE` - Auto-enter when field filled (A+E combined)
- `C` - Cursor starts here (multiple field processing only)
- `T` - Tab to next field when filled
- `P` - Protect (read-only)
- `L` - Lowercase only
- `^` - Uppercase only
- `X` - Return control on any key press
- `Q` - Enable dropdown for combo box


<a id="display-attributes"></a>
### Display attributes
`R` reverse video (highlights only if no colour set) · `N` normal (grey, no effects; other attrs
take precedence) · `I` invisible/password (shows dots/asterisks) · `S` sunken/3D (PRINT FIELDS).
Legacy monochrome **no longer functional**: `B` blink, `H` highlight, `U` underline (mixed
mono+colour attributes are auto-selected per monitor unless `COLOR N`).

<a id="color-attributes"></a>
### Color attributes — `/foreground[:background]`
Basic: `R` red, `G` green, `B` blue, `H` grey, `W` Windows default, `T` transparent. Combinations:
`BG` cyan, `RB` magenta, `RG` yellow, `BGR` white. Hex: `/#RRGGBB[:#RRGGBB]`. Priority when several
are present (4.17+): `#RRGGBB` > `W` > basic HRGB. Define named colour shortcuts with the `COLOR`
BRConfig.sys directive (`COLOR [WARNING]#FFFF00`); `COLOR N` ignores colour attributes. Full named
colour values: [HTML_Color_Table](HTML_Color_Table.md).

<a id="control-attributes"></a>
### Control attributes
Meaningful only with `INPUT`/`RINPUT FIELDS` (`PRINT FIELDS` ignores them).

| Attr | Effect |
|---|---|
| `A` | auto-advance to next field when this one fills |
| `E` | auto-enter (submit) when the field is changed and exited (Field+/Field−/exit) |
| `AE` | auto-enter when the field fills (A+E) |
| `C` | cursor starts here (multi-field; last `C` wins) |
| `G` | auto-enter on *entering* the field (no key wait) — read the screen without operator response |
| `L` | first/last-field scroll-out — up-arrow in the first field or down-arrow in the last returns control with FKEY 102/103/104 (no effect on other fields) |
| `P` | protect / read-only (cursor skips; error 0866 if **all** fields protected) |
| `Q` | hot-text field — followed by the value returned when clicked (linedraw chars can be hot) |
| `S` | sunken effect (PRINT mode) |
| `T` | Tab key moves to the next `T` field |
| `X` | return control on any exit key (turns INPUT FIELDS into single-field input; pairs with `CURFLD`) |
| `<n>` | a leading number = starting cursor position within the field (e.g. `u3`, `R1841`) |

Case-forcing is **not** a control attribute — use the format codes (`CU`/`CL`, `VU`/`VL`) or FMT
identifiers (`X`/`x`, `G`/`g`).

<a id="date-fields"></a>
### Date fields
`DATE(mask)` displays a numeric day-of-century value as a formatted date and accepts date input
(4.3+): punctuation (`, : / ; -`) is auto-skipped during entry, insert/delete work within
punctuation-delimited subfields, and paste converts Excel/OpenOffice/string dates via `DAYS`. The
**date picker** behaviour (`DATE ALWAYS|INVALID|NEVER`, `^DATE_PICKER`) is in
[controls](../controls/spec.md#date-picker).

<a id="filter-fields"></a>
### Filter fields (LIST/GRID, 4.3+)
`RINPUT FIELDS "r,c,<size>/FILTER <chars>,<attrs>,<grid-row>,<grid-col>,<col-to-search>[,<type>][,CASE]": var$`
— a live search box over a grid/list. `<col-to-search>` may be `FULLROW`. Types: `LEADING`
(default, left-justified), `WORD` (each word leading-matched), `ALL` (substring, like `POS`). `CASE`
forces case-sensitivity (default insensitive). `MASK` queries the filter display (value 1).

<a id="subattributes"></a>
### Reusable subattributes & fonts (BRConfig.sys)
Named attribute combinations are defined in BRConfig.sys and referenced by `[name]` in a field:
```
ATTRIBUTE [heading]/#006600:#FFFFFF
```
```business-rules
00100 PRINT FIELDS "10,10,C 20,[heading]": "Main Menu"
```
Fonts: `FONT=`, `FONT.TEXT=`, `FONT.LABELS=`, `FONT.BUTTONS=` (families decor/roman/script/swiss/
modern; weights/styles light/bold/ital/slant/under; sizes small/medium/large/max); two fonts run
at once (background/captions vs input fields, via `3DFONT=`); child windows inherit the parent's
font, size persists across window opens. `STATUS FONTS` lists installable fonts. Full grammar:
[config-directives](../../00-configuration/config-directives/spec.md#appearance).

<a id="examples"></a>
## Examples

```business-rules
00030 PRINT FIELDS "12,39,C 3,B:W": X$           ! row,col,format,attributes
00110 PRINT FIELDS "10,10,C 20,/#FFFFFF:#0000FF": "Important:"
00120 INPUT FIELDS "10,31,C 30,AE/#FFFF00:#000000": RESPONSE$
00200 INPUT FIELDS "10,10,FMT(RAAA-#999),AE": PARTNO$   ! validated 2-part field
00300 PRINT FIELDS "10,20,DATE(mm/dd/yy)": INVOICE_DATE  ! date display (numeric sort)
00400 RINPUT FIELDS "4,8,78/FILTER 30,,5,6,FULLROW,ALL;5,6,LIST 21/80,ROWSUB,SELONE": FIND$, SEL
```

<a id="see-also"></a>
## See also

- [input-output](../input-output/spec.md) — the PRINT/INPUT/RINPUT FIELDS statements
- [controls](../controls/spec.md) — formats `COMBO`/`RADIO`/`CHECK`/`GRID`/`LIST`, date picker
- [windows-cursor](../windows-cursor/spec.md) — window borders & captions, cursor functions
- [config-directives](../../00-configuration/config-directives/spec.md#appearance) — `ATTRIBUTE`/`COLOR`/`FONT` definitions
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — the related file FORM codes
- Backing keyword pages (deep detail retained): [Format_Specifications](Format_Specifications.md),
  [Attribute_(Screen)](Attribute_(Screen).md), [HTML_Color_Table](HTML_Color_Table.md), [PIC](PIC.md)
