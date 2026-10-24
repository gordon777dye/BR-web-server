---
title: User-defined functions (DEF / FN)
file: spec.md
source: §Functions → User-Defined Functions, §Libraries (DEF LIBRARY, parameter passing & scope)
category: 10-language
subcategory: 10-language/flow-control/functions-udf
kind: spec
status: 2b           # reference base + br_tree enrichment (single-line DEF, string-fn length, recursion, function-authoring gotchas: return-name-is-call, single exit, no-paren calls, no array dims in params); no conflicts
corrections:
  - "The multi-line `DEF`'s closer was documented as `FNEND` only. BR accepts `END DEF` as a
    synonym — command5.cpp's `END_PRI` handler tokenizes the word after `END` and, when it is
    `DEF`, rewrites the statement in place to `FNEND` (`*opsubp = T3_FNEND`) rather than treating
    it as a return-code expression. Verified against BR's own C source, not the wiki. Added to
    both closer positions in the syntax block and a semantics bullet. Found auditing brls's `END`
    handling, which parsed `END DEF` as a plain `END` with a bogus return-code identifier until
    this was ported."
  - "§Scope & local variables: \"it's own\" -> \"its own\"."
  - "Single-line DEF's syntax line carried no error-condition clause, though two reference
    corpora both write one routinely — `DEF FNVAL(PC$*80)=VAL(PC$) CONV Ignore`, over a dozen distinct
    call sites. It is the same statement-level clause list documented in error-handling#conditions —
    any statement may take `[<error-condition> <line-ref>]*` from the 17-word statement/EXIT roster,
    not a DEF-specific one — so every condition in that roster (`CONV`, `IOERR`, `EOF`, `TIMEOUT`, …)
    is permissible after a single-line DEF's body, and not only `CONV`. The corpus writes `CONV`
    exclusively because a single-line DEF's body is a plain expression evaluation — a VAL()/CNVRT$()
    call is what fails there — but the grammar does not narrow it to that one condition. Added to the
    syntax line and semantics. Found harvesting brls's failure corpus: the clause was rejected outright
    (parser gap, since fixed), not merely undocumented."
  - "Return-name-is-write-only bullet reworded. It stated the rule (\"`FN<name>` in an expression is
    a recursive call\") but not the symptom or where it bites. A reader on this codebase wrote
    `IF NOT FNRESOLVE_ORDER` inside `FNRESOLVE_ORDER`'s own body — a boolean test that reads as
    ordinary, and 'expression' did not obviously cover an `IF` condition. Reworded to name the two
    concrete forms (`IF NOT FN...`, `LET x = FN...`), the outcome (runaway recursion), and the fix
    (scratch variable). No semantic change. Kept in sync with `dev/statement-semantics.md` and
    `dev/essentials.md`."
  - "2026-10-14 §Declaring locals: the page said an unpassed by-reference optional defaults an
    array to dimension 1, which reads as a usable scratch array. It is not one: such an array
    cannot be redimensioned, and `MAT Z(1)` on it raises 0315. Error page 0315 already gave this
    exact case (`def fna(mat y;mat z)` / `mat z(1)`), and the owner confirmed it 2026-10-14. Added
    a sentence and a link to 0315. Kept in sync with `dev/essentials.md` §1."
related: [other-flow, syntax, system-functions, error-handling]
keywords: [DEF, FNEND, FN, LIBRARY, CONV]
---

# User-defined functions (DEF / FN)

Defining your own `FN…` functions with `DEF … FNEND`, their parameters (by value vs. by
reference), local scope, and return value. The library *facility* that loads and links functions
across programs (`LIBRARY` statement, loading strategies, search order) is in
[50-libraries/library-facility](../../../50-libraries/library-facility/spec.md). Built-in
intrinsic functions are in
[system-functions](../../data-manipulation/system-functions/spec.md).

**These are two separate systems and their rules do not carry over.** What is written here about
signatures — typed and sized returns, `;`-optional parameters, `&` by reference, one exit — applies
to `FN…` functions only, and the intrinsics' rules (which names are reserved, the optional `MAT`
qualifier, atoms and assignables) apply only to them. Nor do `FN…` names take part in
[arity-driven name resolution](../../syntax/spec.md#name-resolution): a variable never starts
`FN`, so the prefix alone settles what such a token is. The one rule shared by both: a
**parameterless** function of either kind is called with no parentheses — `FNGET$`, never
`FNGET$()`.

<a id="syntax"></a>
## Syntax

```bnf
-- single-line form (the whole function is one expression)
DEF FN<name>[$ '*' <len>] [ '(' <parameter-list> ')' ] '=' <expression> [ <error-condition> <line-ref> ]*

-- multi-line form
DEF FN<name>[$ '*' <len>] [ '(' <parameter-list> ')' ]
    <statements>
    [LET] FN<name> = <expression>      -- the return value
{ FNEND | END DEF }                    -- END DEF is an accepted synonym for FNEND

<parameter-list> ::= <params> [ ';' <params> ]   -- ';' : every param after it is OPTIONAL
                   | ';' <params>                -- an all-optional list (no required params)
<params>         ::= <parameter> [ ',' <parameter> ]*
<parameter>      ::= [ MAT | '&' ] <variable> [ '*' <len> ]   -- '&' = by reference; MAT = array
<def-library>    ::= DEF LIBRARY <function-name>[(<parameter-list>)] … { FNEND | END DEF }
```

A function name is `FN` + up to 28 more chars (**30 max, `FN` included**); a **string** function's
trailing `$` is extra (size via `$*<len>`).
Parameters **before** the `;` are required; those **after** it are optional — and any optional the
caller omits becomes a fresh **local variable** (see [Scope & local variables](#local-variables)).
A **scalar** parameter prefixed with `&` (e.g. `&RATE`) is passed **by reference**. **Arrays (`MAT`)
are always passed by reference** and must **not** take `&` — `&MAT` is illegal.

**Calling.** A call to a function with no parameters takes **no parentheses** — `X$ = FNGETNAME$`,
not `FNGETNAME$()` (empty `()` is a syntax error). Call a function for its side effects with a bare
`LET FN<name>`.

<a id="semantics"></a>
## Semantics

<a id="def"></a>
### Defining a function
- **Single-line** functions compute one expression: `DEF FNY(X) = (X-INT(X/100)*100)*10000+INT(X/100)`.
  The expression may be followed by any of the statement-level
  [error-condition clauses](../error-handling/spec.md#conditions) — `[<error-condition> <line-ref>]*`,
  the same trailing clause list every statement takes, not one specific to DEF. `CONV` is what shows
  up in practice, guarding a `VAL()`/`CNVRT$()` call in the body: `DEF FNVAL(PC$*80)=VAL(PC$) CONV
  Ignore` falls through to 0 on a non-numeric string instead of raising an error.
- **Multi-line** functions run between `DEF FN<name>` and `FNEND` and **return a value** by assigning
  to their own name: `LET FN<name> = <expression>` (if never assigned, they return 0 / null). Only
  multi-line functions can do file I/O, change by-reference params, and **recurse** (a fresh local
  copy of each by-value parameter is created per call).
- **Return name is write-only - never a "value so far".** A bare `FN<name>` in the body of the
  function is always another call. BR keeps no readable slot for the pending return value. So
  `IF NOT FNRESOLVE` or `LET FOUND = FNRESOLVE` re-invokes `FNRESOLVE` (producing runaway
  recursion). It does not test what you last assigned. Assign `FN<name>` as often as you like
  (last write wins); just never read it back and track state in a scratch variable.
- **One exit per function.** A function has exactly one `FNEND` and no early-return statement
  (`RETURN` belongs to `GOSUB`). To leave early, `GOTO` a label placed just before `FNEND`.
  **`END DEF` is accepted as a synonym for `FNEND`** — BR's compiler recognizes the word after
  `END` and rewrites `END DEF` to behave exactly as `FNEND`, in the same statement position.
- **`DEF LIBRARY`** marks a function as callable from other programs through the library facility
  (it must still be linked with a `LIBRARY` statement before another program can call it — see
  [library-facility](../../../50-libraries/library-facility/spec.md)). An entire program can be
  wrapped as one `DEF LIBRARY` function.

<a id="parameters"></a>
### Parameters — by value vs. by reference
- Plain parameters are passed **by value** (the function gets a copy).
- Prefix with **`&`** to pass **by reference** — the function reads/writes the caller's variable.
  For arrays this also **avoids copying**, which is faster:
  ```business-rules
  DEF LIBRARY FNPROCESS(&DATA$, &VALUE)   ! efficient — no copy
  DEF LIBRARY FNPROCESS(DATA$, VALUE)     ! copies the values
  DEF LIBRARY FNPROCESS(MAT ARRAY)        ! always passed by reference
  ```
- **No array dimensions in the parameter list.** A parameter is `[MAT|&] name [*len]`: you may size a
  *string* parameter (`NAME$*20`) but **not** dimension an array in the signature (`ROW(1)*255` is
  illegal). Arrays arrive as `MAT name`, dimensioned by the caller or a separate `DIM`; declare array
  *locals* with their own `DIM`, never in the parameter list.

<a id="local-variables"></a>
### Scope & local variables
- **By-value parameters are local** — a plain parameter is a private copy; assigning it never touches a
  like-named variable outside the function. `&` (by-reference) and `MAT` parameters are local *names*
  too, but writing them updates the caller's variable.
- **Declaring locals via the `;` (optional-parameter) list** — a semicolon in the parameter list marks
  **every parameter after it as optional**. When the caller omits an optional parameter, BR creates a
  **fresh temporary variable** for it, initialised to `0`/null on *each* call. This is the standard idiom
  for **local variables**: after the `;`, list first any optional parameters the caller *may* pass, then
  the names you want purely as private scratch variables (which no call ever passes). An unpassed
  by-reference optional defaults an array to dimension 1 and a string to length 18. Such an array
  cannot be redimensioned (`MAT Z(1)` raises [0315](../../../90-reference/error-codes/0315.md)), so
  don't list a scratch array as a parameter; use an ordinary array name in the body. A function may be
  all-optional (`DEF FNX(;A,B$)`); a caller may **not** pass more arguments than are defined, and the
  variable types (numeric/string) must match.
- Each library has its own set of global variables. The rules for clearing these variables are sophisticated and need to be carefully considered.
- When library globals are cleared depends on how the library was loaded (resident vs. release vs.
  `OPTION RETAIN`) — see the table in
  [library-facility](../../../50-libraries/library-facility/spec.md).
- On an error inside a function, `LINE` is the call site in the caller, `ERR` the error number,
  and `CNT` is set for context.

<a id="examples"></a>
## Examples

```business-rules
! Simple library function with a return value
00240 DEF LIBRARY FNCALC(AMT)
00250    LET FNCALC = AMT * (1 + TAX_RATE) * (1 - DISCOUNT_PCT)
00260 FNEND

! Initialization function sets library globals via by-reference params
00100 DIM TAX_RATE, DISCOUNT_PCT          ! library globals
00200 DEF LIBRARY FNINIT(&RATE, &DISCOUNT)
00210    LET TAX_RATE = RATE
00220    LET DISCOUNT_PCT = DISCOUNT
00230 FNEND

! Caller
00100 LIBRARY "CALC": FNINIT, FNCALC
00110 LET FNINIT(TAX_RATE, DISCOUNT_PCT)
00120 LET RESULT = FNCALC(AMOUNT)

! Optional parameter + locals after the ';':
!   QTY, UNIT are required; DISCOUNT is an optional the caller may pass;
!   TAX and TOTAL are never passed → fresh locals (0) on each call.
00300 DEF FNPRICE(QTY, UNIT; DISCOUNT, TAX, TOTAL)
00310    LET TOTAL = QTY * UNIT
00320    IF DISCOUNT > 0 THEN LET TOTAL = TOTAL * (1 - DISCOUNT)
00330    LET TAX = TOTAL * 0.06
00340    LET FNPRICE = TOTAL + TAX
00350 FNEND
```

<a id="see-also"></a>
## See also

- [50-libraries/library-facility](../../../50-libraries/library-facility/spec.md) — `LIBRARY` statement, loading, search order, clearing rules
- [system-functions](../../data-manipulation/system-functions/spec.md) — built-in functions
- [other-flow](../other-flow/spec.md) — `GOSUB`/`RETURN` subroutines (the non-function alternative)
- [syntax](../../syntax/spec.md) — line labels / paragraph labels inside functions
- (Backing keyword pages folded into this spec and pruned. The
  normal-vs-library feature comparison lives in [library-facility](../../../50-libraries/library-facility/spec.md).)
