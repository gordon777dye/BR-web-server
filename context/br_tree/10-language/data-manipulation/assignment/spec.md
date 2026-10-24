---
title: Assignment & data movement
file: spec.md
source: §Statements (Assignment, MAT, DATA/READ/RESTORE), §String Operations
category: 10-language
subcategory: 10-language/data-manipulation/assignment
kind: spec
status: 2b           # reference base + br_tree enrichment (multiple assignment, += compound ops, append/prepend idioms); no conflicts
corrections:
  - "The MAT sub-array operator folded in, with a §mat-sub-array section and a BNF that defines it. <sub-array-reference> was used in the <mat-rhs> production and never defined, and the target admitted only a <dimension> list — so `MAT A(6:10) = B`, this section's own example, was not derivable from this section's own grammar. The operator was not undocumented: it is on the retained deep page `declaration/MAT.md` (§MAT subarray operator), under the leaf that owns *redimensioning* rather than the one that owns MAT operations, so a reader here had no path to it. Facts carried across from that page: the notation, the five worked examples, expression-valued bounds, and that multi-dimensional matrices are not supported. Facts added from level 1 that no kit page had: which of the two readings of `(m:n)` applies is decided by whether the reference is a MAT reference — written, or *implied* at a MAT statement's target and right-hand array operands (get_array in command5.cpp compiles them by inserting the characters `MAT `, so `MAT B(1:5) = A(6:10)` is elements on both sides, while a parenthesized right-hand side is an ordinary expression and slices a string); that the reference *aliases* the original's storage rather than copying it (run.cpp's SUB_ARRAY builds a descriptor with curDmat[0] = last - first + 1 over the original data pointer); that the one-dimension and one-range limits and the bounds check are enforced at **run time**, so `MAT A(1:5,2:3)` compiles and answers 0123 while a bad bound answers 0122; and that the `=` is optional after a sub-array as it is after a redimension (MAT_PRI: `if (!*sp) goto MAT_END`). The no-redimension rule already had an error page and is now linked: 0315, which matches run.cpp's setNoRedim(true) on the descriptor. Two further MAT rules read off MAT_PRI's switch while establishing the above: `*` and `/` are reachable only from the parenthesized-scalar form, so `MAT A = B * C` is a syntax error; and a **string** target ends the statement after one right-hand operand, so `MAT A$ = B$ + C$` is rejected. `MAT.md` is retained rather than pruned — it is a deep reference with much more than sub-arrays on it. Pinned in brls by TestSubArrayIsAnArrayAndNotAString and TestSubArrayNeedsNoRightHandSide; see LSP_PLAN.md finding 37."
  - "DATA's value syntax added. The spec gave `DATA <value> [',' <value>]*` and never defined <value>, which left the impression that a value is an expression. It is not: BR's DATA handler (command5.cpp, case DATA_PRI) copies any value not opening with a quote verbatim to the next comma, so `DATA \"x\",bcp\\scanser` and `DATA ...,3001 MILLER ROAD\"` are both valid and their second values contain a backslash and a lone double quote. Also records that DATA must be the first statement on its line (the handler rejects a prior clause with BRENOMULTICLAUSE) and owns the rest of it. One more consequence of 'verbatim to the next comma' that stayed implicit: the text between two commas can be zero characters, so a value can be **empty** — `DATA ,ISA,GS` starts with an empty value and `DATA A,B,,` (two commas together) has an empty one between them — READ assigns it as a null string or 0 depending on the receiving variable's type. A trailing comma with nothing after it at all (true end of statement, not another comma) does not add one more empty value beyond that; it just ends the list. Found the same way: brls's DATA reader stopped at the first comma with nothing before it, rejecting real corpus lines."
  - "§LET said the assignment target is optional when LET calls a function (`FNSCRNH(LINES)`) but not
    that `LET` itself is also optional there, the same as it is for `X = 5`. The corpus writes both:
    bare `fnCloseDisplayWindow` and `str2mat(\"...\",MAT DEPT$,\",\")`, no `LET`, called purely for
    effect. Also missing: `LET`'s own operand — assigned or called — may be followed by a trailing
    [error-condition clause](../../flow-control/error-handling/spec.md#conditions), and that carries
    over too when `LET` is dropped: `VAL(F$(N)) CONV skipval` is a complete statement, same as
    `LET VAL(F$(N)) CONV skipval`. Added to the syntax line and semantics. Found harvesting brls's
    failure corpus: both forms were rejected outright (parser gaps, since fixed), not merely
    undocumented."
related: [expressions, declaration, data-types, system-functions, error-handling]
keywords: [LET, MAT, DATA, READ, RESTORE, ":=", AIDX, DIDX]
---

# Assignment & data movement

Putting values into variables and arrays and changing them in place: `LET`, the forced-assignment
operator `:=`, `MAT` array operations, substring mutation, and the internal data table
(`DATA`/`READ`/`RESTORE`). Operators that *form* the right-hand-side values are in
[expressions](../expressions/spec.md); declaring/sizing storage is in
[declaration](../declaration/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
[LET] <variable> = <expression> [ <error-condition> <line-ref> ]*
[LET] <function-call> [ <error-condition> <line-ref> ]*    -- call for effect; return value discarded
<forced-assignment> ::= <variable> ':=' <expression>

<mat-assignment>  ::= MAT <array-reference> [ '=' <mat-rhs> ]
<array-reference> ::= <array-name>                                 -- the whole array
                   | <array-name> '(' <dimension> [',' <dimension>]* ')'  -- redimension
                   | <sub-array-reference>                          -- a run of elements
<sub-array-reference> ::= <array-name> '(' <first> ':' <last> ')'   -- MAT implied at these positions
<mat-rhs>        ::= '(' <expression> ')'                          -- init all elements
                   | <array-name> | <sub-array-reference>          -- copy / copy subarray
                   | <numeric-array> { '+' | '-' } <numeric-array> -- element-wise
                   | '(' <numeric-expression> ')' { '*' | '/' } <numeric-array>  -- scalar × array
                   | AIDX '(' <array-name> ')' | DIDX '(' <array-name> ')'  -- sort index

<substring-target> ::= <string-variable> '(' <start-pos> ':' <end-pos> ')'   -- left of '='

READ <variable-list>            -- from the internal data table
DATA <value> [',' <value>]*
RESTORE [<line-ref>]

<value> ::= <quoted-literal>   -- '"' or "'" delimited; a doubled quote embeds one
          | <unquoted-text>    -- everything up to the next comma, taken verbatim (may be empty)
```

<a id="semantics"></a>
## Semantics

<a id="let"></a>
### LET
Assigns a value or computed expression; `LET` is optional (`X = Y*2+Z` is an implicit `LET`).
String values must be quoted and cannot be used in arithmetic. In immediate mode (no line number)
an assignment also prints its result. `LET` also **calls a function** (the assignment target is
optional: `FNSCRNH(LINES)` runs a function for effect; for a library function `LET` loads & runs it).
**`LET` is optional there too** — a bare call is a complete statement, the same as a bare assignment
is: `fnCloseDisplayWindow` and `STR2MAT("300,400,700",MAT DEPT$,",")` both run with no `LET` written,
their return values discarded.

Either form — assigned or called, `LET` written or implied — may close with a trailing
[error-condition clause](../../flow-control/error-handling/spec.md#conditions), the same one any
statement takes: `LET VAL(F$(N)) CONV skipval` and, with `LET` dropped, `X = 5 CONV 900`.
- **Multiple assignment** — assign one value to several variables at once:
  `LET SUMA = SUMB = SUMC = SUMD = 0`.
- **Compound assignment operators** `+=`, `-=`, `*=`, `/=` update a variable in place:
  `LET TOTAL += AMT` (= `TOTAL = TOTAL + AMT`).

<a id="forced-assignment"></a>
### Forced assignment `:=`
Always performs assignment — even inside a conditional, where a plain `=` would mean "is equal
to". It evaluates the RHS, assigns it, and yields the assigned value as the expression result.
- **Parenthesize** it inside `IF`/`WHILE`/`UNTIL` so the assignment happens first, then the result
  is compared.
- Works for numeric and string variables; can nest in larger expressions.
- Do **not** use it in a `LET` — plain `=` is idiomatic there. (Operator precedence of `:=` is in
  [expressions](../expressions/spec.md#forced-assignment).)

| Context | `=` means | `:=` means |
|---|---|---|
| `LET X = 5` | assignment | not idiomatic — use `=` |
| `IF X = 5 THEN` | comparison (is X = 5?) | n/a |
| `IF (X := 5) > 2 THEN` | compares X to 5 | assigns 5 to X, then tests 5 > 2 (true) |

<a id="mat"></a>
### MAT operations
Whole-array operations, much faster than element loops. Scalars must be parenthesized when used
with an operator. (Runtime *resizing* via `MAT` is in
[declaration](../declaration/spec.md#redimensioning).)
- **Initialize**: `MAT A = (0)`, `MAT B$ = ("")`
- **Copy**: `MAT A = B`, subarray `MAT A(6:10) = B` (copies `B(1:5)`) — see
  [sub-array references](#mat-sub-array) below
- **Arithmetic**: `MAT A = B + C` (element-wise), `MAT SAL = (1.064) * SAL` (scalar × array).
  `*` and `/` are reachable **only** from the parenthesized-scalar form, so `MAT A = B * C` is a
  syntax error; `+` and `-` take either. A **string** target ends the statement after one right-hand
  operand, so `MAT A$ = B$` and never `MAT A$ = B$ + C$`
- **Sort index**: `MAT ORDER = AIDX(CUST$)` / `DIDX(...)` builds an *index* array (original
  unchanged); see [system-functions](../system-functions/spec.md#array-functions).
- **The `=` is optional.** `MAT A(4,5)` alone redimensions; `MAT A(1:5)` alone computes a sub-array
  reference and discards it (legal, and pointless).

<a id="mat-sub-array"></a>
#### Sub-array references — `MAT A(first:last)`

A run of an array's **elements**, written with the same characters that slice a string's *characters*.
`first` and `last` are ordinary numeric expressions, not literals: `MAT A$(F:F+9)` is ten elements
starting at `F`.

**Which of the two readings applies is decided by the reference, never by the variable.** A `MAT`
reference gets the element reading and anything else gets the [substring](#substring) reading — what
the name was dimensioned as is not consulted, and could not be, because `A$` and `MAT A$` are
[two different variables](../declaration/spec.md#semantics). So `A$(1:5)` is five characters and
`MAT A$(1:5)` is five elements, in the same program, of names spelled the same way.

**Inside a `MAT` statement the qualifier is implied** — at the target and at each right-hand array
operand. That is why every one of these is elements on both sides:

```business-rules
00100 MAT A(6:10) = B          ! copies B(1)..B(5) into A(6)..A(10)
00110 MAT B = A(6:10)          ! B must be dimensioned for 5 elements
00120 MAT B(1:5) = A(6:10)     ! part of one array to part of another
00130 READ MAT A(1:5)          ! read only elements 1-5
00140 PRINT FIELDS SF$: MAT A$(F:F+9)   ! ten elements starting at F
00150 MAT A$ = (B$(1:5))       ! a *substring*, spread over the array
```

Line 150 is the boundary: a parenthesized right-hand side is an ordinary expression, so the
implication stops at the `(`.

- **It aliases; it does not copy.** The reference is a descriptor over the original array's own
  storage, of length `last - first + 1`. The copying in line 100 is done by the assignment, not by
  the reference
- **A sub-array cannot be redimensioned** — error [0315](../../../90-reference/error-codes/0315.md),
  which is also what a `MAT X(0)` on an unpassed optional array parameter reports
- **One dimension, one range.** The array must be one-dimensional and the reference must carry exactly
  one `first:last` pair. More is a **run-time** failure, not a compile-time one: `MAT A(1:5,2:3)`
  compiles and answers error 0123
- **Bounds are checked at run time** — both within the array's *current* size and `first <= last`,
  else error 0122. Positions are in the program's `OPTION BASE`

<a id="substring"></a>
### Substring mutation
A substring on the **left** of `=` changes part of a string (positions are 1-based, inclusive;
`0` inserts before, `inf` appends). Reading a slice on the right is a string *expression*
([expressions](../expressions/spec.md#concatenation)).
```business-rules
00210 X$(2:3) = "23"      ! replace  → "A23D"   (from "ABCD")
00310 Y$(2:3) = ""        ! delete   → "AD"
00410 Z$(2:0) = "123"     ! insert   → "A123BCD"
00430 Z$(inf:inf) = "End" ! append
```
The string must be dimensioned large enough; an insertion that exceeds the slice extends the
result (but cannot exceed `DIM`). Idioms: **append** with `X$(inf:0)=…` (fastest) or `X$(inf:inf)=…`;
**prepend** with `X$(0:0)=…` or `X$(1:0)=…`; **insert** with `X$(pos:0)=…`; **delete** with
`X$(pos:end)=""`.

<a id="data-table"></a>
### Internal data table — DATA / READ / RESTORE
`DATA` defines an internal table of constants (non-executable; all `DATA` lines merge in
line-number order). `READ` pulls the next value(s) into variables, advancing the pointer.
`RESTORE` resets the pointer (optionally to a specific `DATA` line). `MAT READ` fills a whole
array at once.

**A `DATA` value is not an expression, and the language's ordinary lexical rules do not apply
inside one.** A value that does not begin with a quote is taken **verbatim to the next comma** —
so a backslash, an apostrophe, a stray double quote, an operator or a space are all just data:

```business-rules
00010 DATA "Scanning Program",bcp\scanser        ! second value is  bcp\scanser
00020 DATA "340 HENRY FORD II",3001 MILLER ROAD" ! second value keeps its lone quote
```

A value that *does* begin with `"` or `'` is a quoted literal with the usual doubling rule, and
only a comma, a `!` comment or the end of the line may follow it — anything else is an error.

Two consequences worth stating: **`DATA` must be the first statement on its line** (a second
clause raises "invalid operation in multiclause statement"), and it **owns the rest of that
line**. A tool that lexes `DATA` items by the general rules will report errors in valid programs.

<a id="examples"></a>
## Examples

```business-rules
00050 LET MPG = MI/GAL           ! compute
00080 PUMA = COUGAR              ! implicit LET (copy)
00150 DO WHILE (LINE$ := LINPUT$(1)) <> ""   ! assign-and-test
00160    PRINT LINE$
00170 LOOP

00100 MAT A = (0)                ! init all to 0
00350 MAT SAL = (1.064) * SAL    ! 6.4% raise to every salary
00520 READ MAT CUST$ : MAT ORDER = AIDX(CUST$)   ! ascending index

00100 DATA 6,17,38,49,66,75,93,84,77,67,42,22
00110 READ MAT SPTEMP            ! load all 12 at once
00300 RESTORE                    ! reset DATA pointer
```

<a id="see-also"></a>
## See also

- [expressions](../expressions/spec.md) — operators forming RHS values; `:=` precedence; substring extraction
- [declaration](../declaration/spec.md) — `DIM`/`MAT` sizing of the targets
- [system-functions](../system-functions/spec.md#array-functions) — `AIDX`/`DIDX`, `STR2MAT`, `SRCH`
- [data-types](../data-types/spec.md) — value kinds being assigned
- (Backing keyword pages folded into this spec and pruned.)
