---
title: FORM specifications
file: spec.md
source: §File Operations → FORM Statement for File I/O
category: 30-io-file
subcategory: 30-io-file/form-spec
kind: spec
status: 2b           # reference base + br_tree enrichment (repetition/groups, SKIP, variant codes); no conflicts
recovered-fold: BH_4, CC, CU, DR, GU, GZ, NZ (7 redirect-collision pages folded from re-fetched source — CU/CL/GU FORM error 1006, CC centering, NZ/GZ blank-on-zero, BH 4 range+sentinel; verbatim retained on the BR wiki)
related: [statements, file-model, keys-indexes]
keywords: [FORM, USING, POS, SKIP, PIC, DATE, C, CC, CR, V, G, N, NZ, GZ, GF, X, B, BL, BH, PD, ZD, DT, DH, DL, D, S, L]
canonical: form-spec   # canonical home for the FORM spec (printing/screen guides link here)
corrections:
  - "`FMT(` was given as an alternative to `PIC(` in the §syntax BNF. It is not a FORM code at all — it is a screen field specification (validated masked input, documented in 20-io-screen/fields-attributes §fmt), and it has no entry in the format table a FORM is matched against, so a FORM cannot contain one. It is absent from BR's own FORM syntax diagram on the FORM.md backing page beside this spec, so it was introduced here rather than inherited; the kit's own keyword router already sent `FMT` to fields-attributes alone. Replaced with a note saying where it does belong, beside the existing note about the screen-only case variants — the two are the same class of mistake. Also corrected in dev/statement-semantics.md, which restated the same BNF under READ. Found in brls phase 10."
  - "The §syntax BNF let a repeat group contain another group. **Groups do not nest**: BR keeps the open-group state in one flag and answers a second `(` with a syntax error, and an unclosed group with error 1020. A `<flat>` production added for a group's members, and the rule stated in §repetition. Same fix in dev/statement-semantics.md, whose FORM entry nested them too (and made the repeat factor mandatory where it is optional). Found in brls phase 10."
  - "`<form-numeric-spec>` allowed a variable to stand for the whole number but not for the fraction. **The decimal count may be a variable on its own** — `PD 6.PRICE_`, `BH 4.WEIGHT_` — because the width and the fraction are separate resolutions, either of which may be a name; BR's own FORM decompiler renders each half from the dictionary independently. This is how an application keeps one setting for how many decimals a price carries, and it is written throughout the reference corpus. Rewritten, and the independence stated in §format-codes. Found in brls phase 10."
  - "A typo made the BNF unresolvable: `<form-striing-spec>` was defined and `<form-string-spec>` referenced. The whole `<format-spec>` block was rewritten, which retires it. Found in brls phase 10."
  - "`DATE(mask)` was missing from §format-codes entirely, though `DT`/`DL`/`DH` were listed and `DATE(` is one of only two codes taking a parenthesised argument. Added, with `PIC(` beside it. Found in brls phase 10."
  - "Five rules BR enforces were absent, each one a way a plausible FORM fails to compile. **The space before a width is syntax** — `X2` is not `X 2`, and BR's answer names neither the format nor the space, so a reader has no way to see it (24 lines across two 1M+ line corpora are this one mistake). **`POS`/`X`/`SKIP` take no repeat factor**, BR using that slot for their own count. **A `(` inside a picture is a picture character**, one of the fill-and-sign set — so an accounting picture like `PIC((((,((#.##))` is not unbalanced parentheses, and a picture runs to its *first* `)` with one following `)` absorbed where the picture itself held a `(`. **Limits**: 126 characters maximum, `B`/`BL`/`BH` 1–4 bytes, `D`/`S`/`L` only the length each implies, `DT`/`DH`/`DL` a literal 3 or 4 and never a variable. **`GF` takes no `.` fraction.** Found in brls phase 10."
  - "§semantics said nothing about **when** a format list is compiled, which decides what kind of error a mistake in one is. One routine serves both callers: a `FORM` statement is compiled as its line is read, so a bad one is a syntax error before the program runs; a `USING` operand is compiled **at run time** from whatever the string then holds, so a bad one is error 801 and the program loads and ships without complaint. `USING <line-ref>` checks the target line begins with a `FORM` and answers error 707 when it does not — which is why commenting out a FORM and leaving its references behind is a latent failure rather than a load error. A variable width inside a `USING` string must also already exist, the runtime path not adding dictionary entries. New §when-a-form-is-compiled. Found in brls phase 10."
  - "**§examples contained the error this page now documents.** The FORM was on line 100 and both I/O statements said `USING 160` — line 160 being the WRITE statement itself, so the READ named a WRITE and the WRITE named itself. Both are error 707 at run time. Corrected to `USING 100`, and examples added for the two constructs newly documented here: a repeat group with a variable decimal count, and an inline `USING \"FORM …\"` string. Found by brls's using-not-a-form rule, which is the rule §when-a-form-is-compiled describes."
  - "The variant list gave `CL`/`CU`/`VL`/`VU` as ordinary string variants beside `C`/`CC`/`CR`/`V`, several paragraphs above the note saying `CU`/`CL` raise error 1006 in a FORM. Marked screen-only in the list itself, and `VL`/`VU` added to the 1006 note: they are absent from BR's format table like the others, and a FORM is matched against that table alone, so the outcome is the same. The `FMT(` and case-variant notes now share one lead sentence, since they are one fact — anything not in the table is not a format here. Found in brls phase 10."
  - "keywords: extended from 5 to 27 — **every word-like entry in BR's format table**, so the roster is a closed set a test can hold this page to rather than a selection. `GF`, `GZ`, `NZ`, `BL`, `BH`, `PD`, `ZD`, `DT`, `DH`, `DL`, `CC`, `CR` and the single letters routed nowhere at all before; `DATE` reached only fields-attributes despite `DATE(` being a FORM code. The screen-only variants `CU`/`CL`/`VL`/`VU` are deliberately **not** here — a reader looking one up wants the page that documents it, not the page that says it raises 1006 — and were moved to fields-attributes, along with `GU`/`GL`, which routed nowhere. Pinned by TestEveryFormatCodeIsDocumented in brls."
  - "§format-codes listed `B n` with no decimal count and had no `BL` row, while the §syntax BNF already gave every internal code an optional `.d`. **`B`, `BL` and `BH` all take a decimal count** and use it identically. BR's encoder scales the value by 10^d and rounds it to an integer. Its decoder divides by 10^d, and the three codes differ only in byte order (nformat.cpp, `FMT_BINARY`/`_LO`/`_HI`). Rows rewritten, `BL` added, and a §semantics bullet added. The same code showed that the range check is symmetric, which refutes the `BH 4` bullet's '≈ −2,147,483,648 … 2,147,483,648'; corrected to ±2,147,483,647. Confirmed with a headless 4.33c probe (context/scratch/bdec/): `B 3.2` 12.346 reads back 12.35, stored `D3 04 00`; `BL 3.2` −12.346 reads back −12.35; `BH 2.1` 3276.7 is stored `7F FF`, and 3276.8 raises error 726. Reported from an app (y:\\wb\\ar1) whose programs use `B 3.2`/`B 2.1`: ERRORS.md item 7."
---

# FORM specifications

`FORM` describes the byte-level layout of a record (or a print line) — the field type codes that
`READ`/`WRITE`/`REWRITE` and `PRINT … USING` decode/encode against. **This is the canonical FORM
reference**; the file-I/O statements ([statements](../statements/spec.md)) and the printing guide
link here rather than redefining it.

<a id="syntax"></a>
## Syntax

```bnf
FORM <item> [ ',' <item> ]*
<item>  ::= { POS | X | SKIP } <qty>          -- positioning / line skip; never takes a repeat factor
          | [ <qty> '*' ] <format-spec>       -- a field, optionally repeated
          | [ <qty> '*' ] '(' <flat> [',' <flat>]* ')'   -- repeat a group; groups do not nest
          | <literal> | PIC '(' <picture> ')' | DATE '(' <mask> ')'
<flat>  ::= { POS | X | SKIP } <qty> | [ <qty> '*' ] <format-spec>
          | <literal> | PIC '(' <picture> ')' | DATE '(' <mask> ')'

<format-spec> ::= <string-code>  [ ' ' <qty> ]              -- width optional: the string's own length
                | <numeric-code>  ' ' <qty> [ '.' <qty> ]   -- width and decimals, either a variable
                | <internal-code> ' ' <qty> [ '.' <qty> ]
                | { D | S | L }   [ ' ' <fixed> ]           -- only the length the code implies: 8, 4, 9
                | { DT | DH | DL } ' ' { 3 | 4 }            -- a literal 3 or 4, never a variable
<qty>     ::= <integer> | <numeric-variable>
<literal> ::= '"' <text> '"' | "'" <text> "'"
```

**The space before a width is part of the syntax**, not layout: `X 2` is a skip of two, and `X2` is
not a format at all — BR abandons the match and reads the run as a repeat factor, then fails
elsewhere on the line about something else. Same for `SKIP1`, `NZ4`, `C30`.

A `USING` clause names either a `FORM` line number/label or a literal `"FORM …"` string — **the
keyword is part of the string**: `USING "FORM N 5"`, not `USING "N 5"`. One routine compiles both,
and it requires its text to begin `FORM ` — see
[when a FORM is compiled](#when-a-form-is-compiled), which is also where the two forms stop being
interchangeable.

<a id="repetition"></a>
### Repetition, groups & positioning
- **`n*spec`** repeats a field: `FORM 4*C 30` = four `C 30` fields. **`n*( … )`** repeats a group:
  `FORM 3*(C 10,C 1,C 4)`. `n` may be a (non-subscripted) variable; if its value `< 1`, **0** is
  used (the spec is skipped). For a **string** repeat with no explicit length, the field length
  defaults to the **first** string's length — so list the longest first (or give a length) to avoid
  string-overflow.
- **Groups are one level deep.** BR holds the open-group state in a single flag, so a second `(`
  before the first has closed is a syntax error, and a group left open at the end of the list is
  error **1020** (*missing parenthesis*). `2*(C 8,3*C 4)` is legal — the inner `3*` repeats a field,
  not a group — while `2*(C 8,(C 4))` is not.
- **`POS n`** positions to byte/column `n` (forward or backward); **`X n`** skips `n` positions;
  **`SKIP n`** skips `n` print lines (`SKIP 0` = carriage-return, no line-feed → overstrike; `POS 0`
  suppresses output and holds the line position). PRINT defaults to `SKIP 1` at statement end.
- **`POS`, `X` and `SKIP` cannot carry a repeat factor.** BR stores their count in the same slot a
  factor would occupy, so `3*POS 5` is a syntax error rather than three positionings. To repeat one,
  put it in a group: `3*(POS 5,C 4)`.

<a id="format-codes"></a>
## Tables — format codes

| Code | Meaning |
|---|---|
| `N n[.d]` | Numeric (ASCII), `n` total digits, `d` decimals |
| `C n` | Character, `n` bytes |
| `V n` | Variable-length string, max `n` bytes |
| `X n` | Skip `n` byte positions |
| `POS n` | Position to byte `n` |
| `B n[.d]` | Binary, `n` = 1–4 bytes, `d` implied decimals; the data file's byte order (low byte first on Windows) |
| `BL n[.d]` | Binary as `B`, bytes low to high |
| `BH n[.d]` | Binary as `B`, bytes high to low (sorts as characters when non-negative) |
| `PD n.d` | Packed decimal |
| `ZD n.d` | Zoned decimal |
| `DT 3` / `DT 4` | Date, binary storage (Y2K-compliant) |
| `DL 3` / `DL 4` | Date "long", binary storage |
| `DH 3` / `DH 4` | Date "high", binary storage (indexable as characters) |
| `DATE(mask)` | Date held as a day count and read/written in readable form; the mask runs to its `)` as a `PIC` picture does |
| `PIC(picture)` | Picture-edited numeric; the picture runs to its `)` |

**Widths and their limits.** A width, a repeat factor and a decimal count are each an *integer or a
non-subscripted numeric variable* — `FORM POS POSITION, C LENGTH` and `FORM PD 6.PRICE_` are both
ordinary, and the two halves are independent, so the decimals may be a variable while the width is a
literal. Never a *string* variable: the name rule here admits no `$`. A literal width is at most
**126**; `B`/`BL`/`BH` hold 1 to 4 bytes and no more, being machine integers rather than digits;
`D`, `S` and `L` accept only the one length each already implies (8, 4 and 9) and reject every other;
`DT`/`DH`/`DL` take a literal 3 or 4 and — alone among the codes — **reject a variable**, which is a
consequence of the order BR applies its checks in rather than anything about dates. `GF` places the
decimal point itself, so a `.` fraction on it is an error.

**A `(` inside a picture is a picture character**, not a nested group: it belongs to the same
fill-and-sign set as `-`, `+`, `Z`, `#`, `$` and `*`. So `PIC(((,(((,(((.##)` is a picture made of
them, and a reader that balances parentheses never finds its close. A picture runs to its **first**
`)` — except that where the picture itself contains a `(`, a second `)` immediately after the first
is taken as part of the picture. That is what lets a picture end in the literal `)` of accounting
notation: `PIC((((,((#.##))` prints a negative as `(1,234.00)`.

**String variants:** `C`/`CC`/`CR` (char: left/center/right) and `V` (variable length), plus
`CL`/`CU`/`VL`/`VU` (lower/upper) which are **screen-only** — see below. **Numeric variants:** `N`/`NZ` (zero-suppressed),
`G`/`GZ` (general char-or-numeric), `GF` (generic floating — left-justifies strings, right-justifies
numbers; for FORM and INPUT/PRINT FIELDS). **Internal:** `B`/`BL`/`BH` (binary), `PD` (packed),
`ZD` (zoned). **Floating-point:** `D`/`S`/`L` — very fast but **hardware-dependent / non-portable**.
A bare `"literal"` prints as text on output and acts like `X` (skip its length) on input.

**The screen and the record share most of one vocabulary, and not all of it.** A `FORM` is matched
against a single fixed table of codes, so anything absent from it is not a format there — whatever it
means elsewhere — and the result is error **1006**. Two ways to fall over that:

**`FMT(…)` is not a FORM code.** It is a *screen field* specification — validated, masked input, see
[fields-attributes](../../20-io-screen/fields-attributes/spec.md#fmt). `PIC(` and `DATE(` are the only
two FORM codes whose argument is parenthesised.

**Nor are the case-converting variants.** `CU`/`CL`/`GU`/`GL`/`VL`/`VU` convert case **as keys are typed**
during `INPUT FIELDS`/`RINPUT FIELDS` (internal files) and never alter data already on screen or in the
record; `PRINT FIELDS` accepts them but treats them as plain `C`/`G`; **using any of them in a `FORM`
statement raises error 1006**. `CC` (centered) strips leading/trailing spaces then pads evenly, with
**odd padding going to the right**; given no length it centers within the string's own length.
**`NZ`/`GZ`** output a zero value as **all blanks** (non-zero prints like `N` — right-justified, blank-
padded, rounded to the stated decimals) and are a shorter, faster, more compact substitute for simple
`PIC(- -.- -)` constructions; on **input** they behave as `N`/`G`. (`DR` is a `PIC` insertion code for
displaying negative values — see [fields-attributes](../../20-io-screen/fields-attributes/spec.md).)

<a id="semantics"></a>
## Semantics

- The FORM's fields are applied in order to the record's bytes; `POS`/`X` move or skip the
  cursor so fields can be placed at exact offsets.
- On **REWRITE**, only the fields the FORM lists are written — bytes not covered are unchanged.
- Date types `DT`/`DL`/`DH` store a day-count in binary and are Y2K-compliant with a proper
  `BASEYEAR`; `DH` can be indexed as character data for sorting (see
  [keys-indexes](../keys-indexes/spec.md)).
- Efficient internal record lengths are `2^N − 1` (see [file-model](../file-model/spec.md#tables)).
- **`B`/`BL`/`BH` all take a decimal count**, and apply it the same way. On write the value is
  multiplied by 10^`d` and rounded to the nearest integer; on read the stored integer is divided by
  10^`d`. So `B 3.2` stores 12.346 as 1235 and reads it back as 12.35. The byte-size range applies to
  the *scaled* integer, and is symmetric — the most negative two's-complement value is refused too.
  So `BH 2.1` holds −3276.7 … 3276.7, and writing 3276.8 raises error **726** (trappable with
  `CONV`). The three differ only in byte order.
- A **`BH 4`** field holds a signed 32-bit integer, −2,147,483,647 … 2,147,483,647 with no decimals (see the
  bullet above). An **empty,
  never-written `BH 4` reads as `538,976,288`** (the value of four ASCII spaces) — test for that
  sentinel, not `0`, when detecting unwritten records.

<a id="when-a-form-is-compiled"></a>
### When a FORM is compiled, and why it decides the error you get

One routine compiles every format list, and it is reached from two places at two different times.
The same malformed text is therefore a compile-time error in one position and a runtime failure in
the other, which is worth knowing before trusting that a program with no load errors has no format
errors.

| Written as | Compiled | A malformed list is |
|---|---|---|
| `FORM` statement | as the line is read | an ordinary syntax error, reported with a column, before the program will run at all |
| `USING "FORM …"` or `USING <string-expr>` | **at run time**, from whatever the string then holds | error **801** (*invalid FORM specification*) — the program loads, ships, and fails the first time that statement executes |
| `USING <line-ref>` | at run time, by fetching the named line's compiled form | error **707** (*referenced line is not a FORM statement*) if the line's first statement is not a `FORM` |

Three consequences follow.

- **A `USING` string must begin `FORM `** — the keyword and one space — because that is what the
  routine tests before reading anything else. `USING "N 5"` compiles and then fails with 801 every
  time.
- **`USING <line-ref>` is not a branch.** The line has to exist *and* begin with a `FORM`; a
  reference that has drifted onto a neighbouring line, or points at a `FORM` somebody commented out,
  passes every check BR makes until the statement runs. Commenting out a `FORM` while leaving its
  references in place is the common way to acquire a 707.
- **A variable width inside a `USING` string must already exist.** Compiling a `FORM` *statement*
  creates the name if it is absent; the runtime call does not add dictionary entries, so a name that
  appears nowhere else in the program is error 801 as surely as a malformed code is.

<a id="examples"></a>
## Examples

```business-rules
! CHECKBOOK.INT record: check#, amount, flag, date written, date cleared, payee
00100 FORM N 5, N 10.2, C 1, N 6, N 6, C 25

! Used by READ/WRITE — both name line 100, the FORM
00150 READ  #1, USING 100: CHECK, AMOUNT, DW$, DWR, DCL, PAYEE$ EOF 200
00160 WRITE #1, USING 100: CHECK, AMOUNT, DW$, DWR, DCL, PAYEE$

! A repeat group, and a decimal count held in a variable
00200 DIM CODE$(3)*4, QTY(3)
00210 LET PRICE_ = 2
00220 WRITE #2, USING 230: MAT CODE$, MAT QTY, TOTAL
00230 FORM 3*(C 4, N 6), PD 6.PRICE_

! Inline, where the FORM keyword is part of the string
00300 PRINT #255, USING "FORM POS 5, C 20, X 2, N 8.2": NAME$, BALANCE
```

<a id="see-also"></a>
## See also

- [statements](../statements/spec.md#io) — `READ`/`WRITE`/`REWRITE … USING <form>`
- [file-model](../file-model/spec.md) — record/field concepts, RECL
- [keys-indexes](../keys-indexes/spec.md) — date field types as keys
- Printing-side FORM/PIC usage → [40-io-printing/statements](../../40-io-printing/statements/spec.md)
- Backing keyword page (deep FORM reference retained): [FORM](FORM.md)

*(7 redirect-collision pages re-fetched in 2b — `BH_4`, `CC`, `CU`, `DR`, `GU`, `GZ`, `NZ` — were
folded into this spec and pruned; verbatim wikitext remains on the BR wiki.)*
