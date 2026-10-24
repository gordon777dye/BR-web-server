---
title: Data types
file: spec.md
source: §Data Types
category: 10-language
subcategory: 10-language/data-manipulation/data-types
kind: spec
status: 2b           # reference base + br_tree enrichment (hex / null); no conflicts
corrections:
  - "Numeric-literal BNF tightened and the compiler's written-form limits added, from command3.cpp's literal scanner. The BNF used <digit>* throughout, admitting a literal with no digits at all, and gave no limits; the compiler rejects more than 15 digits before the point, more than 9 after it, and an exponent over 307 (MAXEXP), and requires at least one digit in an exponent. The string-literal BNF did not show the doubled-quote form, though the examples below already did."
related: [declaration, assignment, expressions]
keywords: [numeric, string, hexadecimal, null, inf]
---

# Data types

The literals and value kinds BR works with: numeric (integer / fixed-point / scientific) and
string. Declaring a variable's storage (string max length, arrays) lives in
[declaration](../declaration/spec.md); the operators that combine these values live in
[expressions](../expressions/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<numeric-literal> ::= <integer> | <floating-point>
<integer>        ::= [+|-] <digit>+
<floating-point> ::= [+|-] { <digit>+ [ '.' <digit>* ] | '.' <digit>+ } [ E [+|-] <digit>+ ]

<string-literal> ::= '"' { <any-char-except-quote> | '""' }* '"'
                   | "'" { <any-char-except-apostrophe> | "''" }* "'"
```

<a id="semantics"></a>
## Semantics

<a id="numeric"></a>
### Numeric values
- Optional leading sign (`+`/`-`), digits `0-9`, optional decimal point; **sign must be first**.
  (The compiler reads the sign as a unary operator rather than as part of the literal, so a tool
  that tokenizes BR will see `-5` as two tokens.)
- **No commas, no currency symbols** in a constant (use `PIC` for display formatting).
- Up to **15 significant digits**; scientific (E) notation supported.
- Kinds: **integer** (no fraction), **fixed-point** (has a fraction), **scientific** (E notation).
- **Limits the compiler enforces on the written form**, each of which rejects the program rather
  than rounding it:

  | Part | Limit | Note |
  |---|---|---|
  | digits before the point | **15** | `PRECISION`, the significant digits of a double |
  | digits after the point | **9** | independent of the 15 above |
  | exponent magnitude | **307** | `MAXEXP`; matches `inf ≈ 1E+307` below |

  A literal may open with the decimal point (`.5`), so digits are required on one side or the
  other but not both. `1E` is **not** a literal with an empty exponent — the exponent needs at
  least one digit, so that text is the literal `1` followed by the name `E`.

<a id="inf"></a>
### Special constant `inf`
`inf` is infinity — the highest representable number, ≈ `1E+307`. It also denotes "beyond end
of string" in substring positions (e.g. `S$(inf:inf) = "END"` appends). Useful for open-ended
ranges and comparisons.

<a id="hex"></a>
### Hexadecimal
Base-16 (digits `0-9` then `A-F`). Hex constants are written with a leading `#` (`#FF`, `#1B`); the
`HEX$`/`UNHEX$` functions convert between hex notation and characters (e.g. printer escapes — see
[system-functions](../system-functions/spec.md#conversion-functions)).

<a id="null"></a>
### Null
**Null** is ASCII character 0 — `CHR$(0)`; `ORD` of it is 0. Used as a low sentinel / binary zero.

<a id="string"></a>
### String values
- Delimited by double `"` or single `'` quotes.
- **Embedded quotes**: use the opposite delimiter, or double the quote char (`""` inside a
  double-quoted string).
- **Default maximum length is 18 characters**; extend with [`DIM`](../declaration/spec.md#dim)
  up to 99,999,999 characters. A literal's length is otherwise bounded by the BR line length.

<a id="tables"></a>
## Tables

| Kind | Form | Example |
|---|---|---|
| Integer | `[±]digits` | `10`, `-10`, `+10` |
| Fixed-point | `[±]digits.digits` | `12.34`, `12.`, `-12.3` |
| Scientific | `mantissa E [±]exp` | `1.5E+6` (= 1,500,000) |
| [`inf`](../system-functions/spec.md#numeric-functions) | infinity ≈ `1E+307` — the literal form; the value is defined with the numeric functions | `S$(inf:inf)` |
| String | `"..."` or `'...'` | `"Hello"`, `'Bruno''s'` |

<a id="examples"></a>
## Examples

```business-rules
10      ! integer constant
-12.3   ! negative fixed-point
1.5E+6  ! scientific notation (1,500,000)
12.     ! valid (trailing decimal)
```

Invalid numeric constants:
```business-rules
10-     ! sign must be at the beginning
12,345  ! no commas allowed
$100.10 ! no currency symbols
12+3    ! cannot combine operations in a constant
```

String literals and embedded quotes:
```business-rules
"Hello, world!"        ! double-quoted
'Hello, world!'        ! single-quoted
"Bruno's computer"     ! apostrophe inside double quotes
'He said "Hello"'      ! double quotes inside single quotes
"He said ""Hello"""    ! doubled quotes for embedding
```

<a id="see-also"></a>
## See also

- [declaration](../declaration/spec.md) — `DIM` for string length and arrays
- [expressions](../expressions/spec.md) — operators over these values; `inf` in substrings
- [assignment](../assignment/spec.md) — putting values into variables
- (Backing keyword pages folded into this spec and pruned.)
