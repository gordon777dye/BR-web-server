---
title: Declaration (variables & arrays)
file: spec.md
source: §Variables, §MAT (redimensioning)
category: 10-language
subcategory: 10-language/data-manipulation/declaration
kind: spec
status: 2b           # reference base + br_tree enrichment (OPTION BASE/statement, DIMONLY); no conflicts
recovered-fold: Array_Name, Numeric_Variable (2 redirect-collision pages folded from re-fetched source — FN-prefix reserved, scalar/array/string co-existence; verbatim retained on the BR wiki). NOTE 2026-07-29 - that fold also changed the first-character rule to "letter" only, following the wiki; reverted to "letter or _" after testing the runtime, which accepts `_a = 1`. The wiki is wrong on this point.
related: [data-types, assignment, expressions]
keywords: [DIM, MAT, OPTION, BASE, PRTZO, INVP, COLLATE, RETAIN, NATIVE, ALTERNATE, EBCIDIC]
corrections: |
  2026-08-05 §option: the OPTION statement's roster completed and closed. It named BASE and
  COLLATE, alluded to INVP without naming it, and did not mention PRTZO or RETAIN as OPTION words
  at all; COLLATE was given two values where BR tests three. Level 1: OPTION_PRI in command5.cpp
  (reached through syntxfn2) tokenizes each word, resolves it through table4k, and switches on the
  table4v token value — SOURCE_BASE, PRTZO, SOURCE_INVP, COLLATE, RETAIN — with
  `default: goto SYNTAX_ERR` returning WBEBADSYNTAX (1006), which is what closes the roster.
  COLLATE's own argument is tested against WBALTERNATE, NATIVE and EBCIDIC, returning
  BREMISSINGKEYWORD (1022) otherwise; `EBCIDIC` is table4k's spelling and not a typo introduced
  here. The ranges are from the same routine: OPTN_GETNUM checks BASE against 0..1 and PRTZO
  against 1..128. Found in brls phase 11, where the completion list had no roster to offer after
  OPTION; the five spellings are now generated into the language pack from table4k
  (cmd/gendata/options.go) and pinned by langdata.TestOptionsAreBRsOwnRoster.
  The BRConfig.sys COLLATE directive in 00-configuration/config-directives is a different reader in
  a different file and was deliberately left alone.

  2026-08-06 §redimensioning: a redimension and a sub-array were not distinguished here, and this
  leaf is where the confusion was reachable — `MAT A(5)` resizes, `MAT A(1:5)` names five elements
  and resizes nothing, and a sub-array cannot be redimensioned at all (error 0315, matching
  run.cpp's setNoRedim(true) on the SUB_ARRAY descriptor). Added, with a pointer to
  assignment/spec.md#mat-sub-array, where the sub-array operator now lives: it had been documented
  only on this leaf's retained deep page MAT.md (§MAT subarray operator), under the leaf that owns
  redimensioning rather than the one that owns MAT operations, so a reader of the MAT-operations
  section had no path to it. Found in brls phase 12; see LSP_PLAN.md finding 37.

  2026-10-01 §redimensioning, §syntax: the page said a redimension "cannot exceed the original `DIM`
  size without re-`DIM`ming", while its own example grows `DIM A(100)` to `MAT A(200)`. The example
  was right and the sentence wrong (stated by the project owner, who runs real BR); the sentence now
  says a DIM size is not a ceiling. Added that `MAT` is not allowed inside a DIM (error 1026 at LOAD,
  from ERRORS.md: `dim A$*5,MAT KP(6)` on BR 4.33c; only that position was tested, not a leading
  `DIM MAT A(5)`), and defined `<array-name>` so the string-array form `NAMES$(100)*30` is in the
  grammar and not only in the examples. Also stated what OPTION BASE does to a DIM: under BASE 0,
  `DIM A(5)` is six elements, `A(0)` to `A(5)` (verified by the project owner against real BR).
---

# Declaration (variables & arrays)

Declaring storage: variable kinds and naming, `DIM` for string length and arrays, and runtime
redimensioning with `MAT`. Putting *values* into variables/arrays (`LET`, `MAT` copy/arithmetic,
`READ`/`DATA`) lives in [assignment](../assignment/spec.md); the value kinds themselves are in
[data-types](../data-types/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<numeric-variable> ::= <identifier>
<string-variable>  ::= <identifier> '$'
<numeric-array>    ::= <identifier> '(' <subscript> [',' <subscript>]* ')'
<string-array>     ::= <identifier> '$' '(' <subscript> [',' <subscript>]* ')'

DIM <variable-list>
<variable-list>        ::= <variable-declaration> [',' <variable-declaration>]*
<variable-declaration> ::= <numeric-variable>
                         | <string-variable> '*' <max-length>
                         | <array-declaration>
<array-declaration>    ::= <array-name> '(' <dimension> [',' <dimension>]* ')' ['*' <max-length>]
<array-name>           ::= <identifier> | <identifier> '$'   ! '$' goes before the '(' : NAMES$(100)*30
<dimension>            ::= <integer>
```

A `DIM` declares by plain name. `MAT` is not part of a declaration: `MAT` in a `DIM` list is
rejected at LOAD as error 1026, "invalid expression" (confirmed for `DIM A$*5,MAT KP(6)`). Write
`DIM KP(6)`; `MAT KP(n)` is the runtime [redimension](#redimensioning).

<a id="semantics"></a>
## Semantics

### Variables
- **Numeric** (`X`, `TOTAL_COST`) default to `0`; **string** (ends in `$`, e.g. `NAME$`) default
  to the empty string and cannot do arithmetic.
- **Case-insensitive** (`NAME$` = `name$`) and **implicitly declared** on first use.
- **Naming**: **begin with a letter or `_`** (1–30 chars of letters, digits and `_`); not a reserved
  word, and **never an `FN…` name** (those are reserved for user-defined functions). The *same*
  identifier can coexist as a numeric scalar, numeric array, string scalar **and** string array —
  `A`, `MAT A`, `A$`, `MAT A$` are four distinct variables. (`MAT` is how an expression or statement
  *refers* to the array; a `DIM` names it without `MAT`.)
- Values **persist** until reassigned, or cleared by `CLEAR`, `RUN`, `LOAD`, `CHAIN`, or exit.

<a id="dim"></a>
### DIM
- Sets a string variable's **maximum** length (required above the 18-char default) and **declares
  arrays**. Syntax `DIM name$*length`; actual length ≤ maximum (use
  [`LEN`](../system-functions/spec.md#string-functions) for the current length).
- Non-executable (processed before the run); may appear anywhere; multiple declarations per `DIM`.

<a id="arrays"></a>
### Arrays
- Hold many values of **one type** (numeric *or* string) under one name, indexed by subscript.
- **1-based** by default (first element is index 1). Arrays of **≤10 elements need no `DIM`**
  (auto-dimensioned to 10). **1 to 7 dimensions**. Elements are contiguous; defaults are `0`
  (numeric) / empty (string).
- **A dimension is the highest subscript, not the element count.** Under the default `OPTION BASE 1`,
  `DIM A(5)` holds five elements, `A(1)` to `A(5)`; under `OPTION BASE 0` it holds **six**, `A(0)` to
  `A(5)`. See [OPTION & base](#option).
- **Size limit** 99,999,999 bytes (4.30+; previously 512 KB).

<a id="option"></a>
### OPTION statement & base
The `OPTION` statement sets program-wide choices. It takes a **comma-separated list** drawn from a
**closed roster of five words** — anything else after `OPTION` is error 1006:

| Option | Takes | Effect |
|---|---|---|
| `BASE` | `0` or `1` | `BASE 0` makes every array include a **zero element**, so `DIM A(5)` holds six elements, `A(0)` to `A(5)`; `BASE 1` is the default, 1-based, and `DIM A(5)` holds five. Any other value is error 1006 |
| `PRTZO` | `1`–`128` | Print-zone width, for the `,` separator in a print list (default 24). Outside the range is error 1006 |
| `INVP` | — | Inverted (European) decimal/comma format: the roles of `.` and `,` swap in `PIC`, `N`, `NZ`, `L`, `G` and `GZ` [format specifications](../../../30-io-file/form-spec/spec.md) and in `INPUT FIELDS` |
| `COLLATE` | `NATIVE`, `ALTERNATE` or `EBCIDIC` | Letters-vs-numbers sort order: `NATIVE` is the platform/character-set order (ASCII: digits before letters), `ALTERNATE` moves digits *after* letters, `EBCIDIC` uses EBCDIC order. A fourth word is error 1022. **`EBCIDIC` is BR's own spelling** of the keyword |
| `RETAIN` | — | A RESIDENT library keeps its variables across unloads — see [library-facility](../../../50-libraries/library-facility/spec.md) |

`OPTION` is a non-executable directive: it **must occupy its own line** (it cannot be compounded
with `:`), but it may appear **anywhere** in the program and takes effect **program-wide**
regardless of position. (The numbered `OPTION <nn>` feature toggles are configuration, and a
different thing entirely — see
[config-directives](../../../00-configuration/config-directives/spec.md#behavior). `INVP` and
`COLLATE` are *both*: a BRConfig.sys directive and an option of this statement.)
The **`DIMONLY`** BRConfig.sys/`CONFIG` setting forbids creating a variable during editing unless it
was declared in a `DIM` — a discipline aid against typo-variables.

<a id="redimensioning"></a>
### Redimensioning (MAT)
Resize at runtime with `MAT`; existing values are preserved when growing and lost when shrinking.
The size a `DIM` gave is not a ceiling: a redimension may grow an array past it, and no re-`DIM` is
needed.
```business-rules
00400 DIM A(100), B(50)
00410 MAT A(200)        ! grow to 200
00420 MAT B(25)         ! shrink to 25
00430 MAT A(10,10) = A  ! reshape 100 → 10×10
```
**A redimension is not a sub-array.** `MAT A(5)` resizes A to five elements; `MAT A(1:5)` *names*
five of them and resizes nothing. The comma and the colon are the whole difference, and a sub-array
cannot be redimensioned at all — error [0315](../../../90-reference/error-codes/0315.md).

The value-moving forms of `MAT` (copy, arithmetic, sort) are in
[assignment](../assignment/spec.md#mat), and the sub-array operator at
[§mat-sub-array](../assignment/spec.md#mat-sub-array) — which is where the
[deep MAT page](MAT.md)'s §MAT subarray operator material was folded, it having sat under this leaf
while the operator belongs to MAT *operations*.

<a id="tables"></a>
## Tables

| Dimensions | Declaration | Use |
|---|---|---|
| 1-D | `DIM AGE_COUNTS(120)` | linear list |
| 2-D | `DIM OFFICE_COUNTS(40,5)` | matrix (row, col) |
| 3-D | `DIM TEMPERATURES(99,99,24)` | cubic |
| up to 7-D | `DIM X(...)` | complex structures |
| string array | `DIM NAMES$(100)*30` | 100 strings, ≤30 chars each |

<a id="examples"></a>
## Examples

```business-rules
00100 DIM NAME$*30, AMOUNT, SCORES(100), MATRIX(10,10)
00120 DIM LONG_MESSAGE$*80      ! string up to 80 chars
00140 DIM NAMES$(100)*30        ! array of 100 strings, each ≤30 chars
00080 DIM MATRIX(5,4)           ! 5×4 two-dimensional array
00090 DIM DATA$(5,3,2)*20       ! three-dimensional string array
```

<a id="see-also"></a>
## See also

- [assignment](../assignment/spec.md) — `LET`, `MAT` copy/arithmetic, `READ`/`DATA` to populate arrays
- [data-types](../data-types/spec.md) — the value kinds being stored
- [system-functions](../system-functions/spec.md#array-functions) — `UDIM`, `SUM`, `AIDX`/`DIDX`, `LEN`
- [30-io-file/form-spec](../../../30-io-file/form-spec/spec.md) — `DT`/`DL`/`DH` date FORM specs (relocated there)
- [20-io-screen/input-output](../../../20-io-screen/input-output/spec.md) — MAT grouping in FIELDS I/O lists (relocated there)
- Backing keyword page (deep MAT reference retained): [MAT](MAT.md)

*(2 redirect-collision pages re-fetched in 2b — `Array_Name`, `Numeric_Variable` — were folded into this
spec and pruned; verbatim wikitext remains on the BR wiki.)*
