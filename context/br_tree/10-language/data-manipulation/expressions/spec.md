---
title: Expressions
file: spec.md
source: §Operators and Expressions
category: 10-language
subcategory: 10-language/data-manipulation/expressions
kind: spec
status: 2b           # reference base; br_tree pages verified (all corroborate); corrected 2026-07-03: MOD is a function, not an infix operator (removed from precedence table); no conflicts
corrections:
  - "Precedence table corrected against BR itself, by running the expressions rather than reading about them. Three errors. (1) `^` was listed with `**` as exponentiation; BR rejects `^` with error 1026 — the expression parser in command3.cpp has no case for it at all, and the runtime's EXCL_OR case is commented out. (2) `NOT` and `~` were on one row as equivalent; they are not. BR's own precedence table (table5x, tblopr.cpp) puts `~` at 13 with unary minus and `NOT` at 5, on opposite sides of the relational operators, and it shows: `PRINT NOT 0==5` gives 1 while `PRINT ~ 0==5` gives 0. (3) The `%`, `<<` and `>>` spellings were undocumented; they compile and silently evaluate to 0, because the compiler emits the opcode and run.cpp has no evaluator case for MODULO and has SHIFT_LEFT/SHIFT_RIGHT commented out. Levels renumbered to suit. Caution for anyone re-folding this: the opcode list in basoprcmn.h and the precedence values in table5x describe more operators than the parser accepts or the runtime evaluates, so neither is evidence that a spelling works."
  - "AND and OR merged onto one precedence level, and §AND and OR short-circuit added. The table previously put AND above OR as C and most other languages do. BR does not: the two share a level and a logical chain runs strictly left to right, stopping as soon as the running value settles the outcome (true meeting OR, or false meeting AND). Confirmed against a running BR: `1 OR 0 AND 0` gives 1 because nothing after `1 OR` is evaluated, while `(1 OR 0) AND 0` gives 0, and `0 OR 1 AND 0` gives 0. BR's own table5x gave both the value 4 and was right; the separate levels were the error. Skipped terms are not evaluated at all, so a function call in an abandoned branch never runs."
  - "Three corrections and one addition from porting BR's expression parser (brls phase 4). (1) §Logical operators still read `parentheses -> NOT -> AND -> OR`, contradicting the precedence table in the same document, which had already been corrected to put AND and OR on one level; it also listed `~` with `NOT`, which §not-vs-tilde had already shown to be wrong. (2) §String expressions called concatenation `precedence level 5` where the table says 6, a leftover from renumbering the table to twelve levels. (3) §associativity added: `**` associates LEFT in BR, so `2**3**2` is 64 and not 512, and unary minus binds tighter than `**`, so `-2**2` is 4 and not -4. Both were derived from the C first and then confirmed against a running BR, which printed 64 and 4. Both follow from table5x (tblopr.cpp) giving `~` and unary `-` the value 13 against RAISE's 9, and from stack() (command3.cpp) breaking out of its unstacking loop only at value 13 — the unary level is the sole right-associative one. Neither grouping was stated anywhere in the kit, and both are the opposite of what C, Python and most calculators do."
related: [assignment, conditionals, data-types, declaration]
keywords: [AND, OR, NOT, precedence, ":=", operators]
---

# Expressions

Operators, precedence, and the numeric / string / relational / logical expressions that BR
evaluates. Substring *mutation* and the `LET` form of assignment live in
[assignment](../assignment/spec.md); the `IF` / `WHILE` / `UNTIL` constructs that consume
relational expressions live in [conditionals](../conditionals/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<expression>            ::= <numeric-expression> | <string-expression> | <relational-expression>
<numeric-expression>    ::= <numeric-term> [ <numeric-operator> <numeric-term> ]*
<string-expression>     ::= <string-term> [ '&' <string-term> ]* | <substring>
<substring>             ::= <string-expr> '(' <start-pos> ':' <end-pos> ')'
<relational-expression> ::= <expression> <relational-operator> <expression>
```

**`name(...)` is ambiguous on its face** — a function call, an array subscript, or a substring —
and BR resolves it by **arity**, not by consulting a symbol table: whether the mandatory operands
that name requires are present decides what it is. `X(3)` subscripts because `X` requires no
arguments; `SIN(3)` calls because `SIN` requires one. A `DIM` does **not** shadow an intrinsic.
Full rule and worked counterexamples:
[syntax — name resolution](../../syntax/spec.md#name-resolution).

<a id="semantics"></a>
## Semantics

### Evaluation order
Innermost parentheses first, then by operator precedence (see [precedence table](#precedence)),
left to right within the same level. The algebraic core is PEMDAS — **P**arentheses,
**E**xponents, **M**ultiplication/**D**ivision, **A**ddition/**S**ubtraction.

<a id="forced-assignment"></a>
### The two meanings of `=`, and forced assignment `:=`
`=` is overloaded by context:
- Inside a conditional expression (`IF`, `WHILE`, `UNTIL`), `=` is **always** the
  "is equal to" comparison operator.
- In a `LET` statement (or any non-conditional context), `=` is **always** assignment.

Use **`:=`** to force *assignment* semantics even inside a conditional; the assignment must be
parenthesized:

```business-rules
00010 IF (X := 5) > 2 THEN PRINT "assigned X then compared"
```

The assignment-statement side of `:=` (and `LET`) is detailed in
[assignment](../assignment/spec.md#forced-assignment).

<a id="relational-operators"></a>
### Relational expressions
Comparisons return **1** (true) or **0** (false), and work on both numeric and string operands.
String comparisons run **character-by-character, left to right, by ASCII value**, stop at the
first unequal pair, and are **case-sensitive**. Operators are *binary* (two operands: `+`, `=`,
`<`, …); `NOT` / `~` is the *unary* negation operator (`NOT` preferred for readability).

<a id="logical-operators"></a>
### Logical operators
`NOT`/`~`, `AND`/`&&`, `OR`/`||` combine relational expressions. Precedence within a logical
expression: parentheses → `NOT` → `AND`/`OR`, which share one level and run **strictly left to
right** ([below](#short-circuit)). `~` is not a synonym for `NOT` and does not belong on this list
— it binds tighter than the comparisons rather than looser ([above](#not-vs-tilde)). See the
[truth tables](#truth-tables).

<a id="concatenation"></a>
### String expressions
- **Concatenation** joins strings with `&` (precedence level 6):
  `C$ = A$ & " " & B$`. As an operator it forms a `<string-expression>`.
- **Substring extraction** reads a slice with 1-based, inclusive positions —
  `S$(2:4)` yields characters 2–4; `INF` denotes beyond end-of-string
  (`S$(6:INF)`). Used on the right-hand side it is a string expression.
- **Substring replacement / insertion / deletion** (slice on the *left* of `=`) is a data
  *change*, documented in [assignment](../assignment/spec.md#substring).

<a id="tables"></a>
## Tables

<a id="precedence"></a>
### Operator precedence (highest to lowest)
| Level | Operators | Description | Example |
|------:|-----------|-------------|---------|
| 1 | `()` `[]` | Grouping, array indexing | `(5+3)*2`, `ARRAY(5)` |
| 2 | `~` unary `-` | **Boolean NOT**, negation — binds tighter than comparison | `~0` = 1 |
| 3 | `**` | Exponentiation (**not** `^` — see below) | `2**3` = 8 |
| 4 | `*` `/` | Multiplication, division | `10/2`, `8/2` |
| 5 | `+` `-` | Addition, subtraction | `5+3`, `10-7` |
| 6 | `&` | String concatenation | `"Hi" & " there"` |
| 7 | `==` `~=` `<>` `><` `<` `>` `<=` `=<` `>=` `=>` | Comparison / relational | `X > 10` |
| 8 | `=` | *is equal to* (comparison; inside `IF`/`WHILE`/`UNTIL`) | `IF X = 5 THEN …` |
| 9 | `NOT` | **Logical NOT** — binds *looser* than comparison | `NOT FOUND` |
| 10 | `AND` `&&` `OR` `\|\|` | Logical AND/OR — **one level, strictly left to right**, and they short-circuit. See below. | `A=1 OR B=1 AND C=2` |
| 11 | `=` | Assignment (`LET` / non-conditional context) | `LET X = 5` |
| 12 | `:=` | Forced assignment (assigns even inside a conditional) | `IF (X := 5) > 2 THEN …` |

<a id="associativity"></a>
**Two groupings where BR differs from nearly every other language**, both of them consequences of
the table above rather than special cases:

```business-rules
PRINT 2**3**2       ! 64, not 512 — `**` groups LEFT: (2**3)**2
PRINT -2**2         ! 4,  not -4  — unary binds TIGHTER than `**`: (-2)**2
```

Both confirmed against a running BR. Operators associate **left to right within a level**, and
`**` is not excepted: BR's operator stacker keeps a pending operator stacked only at the unary
level, so exponentiation chains left like subtraction does. And unary `-` and `~` sit *above* `**` in the table, not below it, so a sign
attaches to the base before the exponent applies. Both readings are the opposite of C, Python and
most calculators. Parenthesise when either could be meant.

<a id="not-vs-tilde"></a>
**`~` and `NOT` are not interchangeable.** Both negate, but they sit on opposite sides of the
comparison operators, so the same expression means different things:

```business-rules
PRINT NOT 0==5      ! 1  — reads as NOT (0==5)
PRINT ~ 0==5        ! 0  — reads as (~0) == 5, i.e. 1 == 5
PRINT ~ (0==5)      ! 1  — parenthesised, now the same as NOT
```

Use `NOT` for a condition and reserve `~` for negating a single value, or parenthesise.

<a id="short-circuit"></a>
### `AND` and `OR`: one level, left to right, short-circuiting

**`AND` does not bind tighter than `OR` in BR.** They share a precedence level and a logical chain
is evaluated strictly left to right — which is the single most likely thing on this page to catch
out anyone arriving from C, Python, SQL or Visual Basic, where `AND` binds tighter.

Evaluation carries a running value and **stops the moment that value settles the outcome**:

- a running value of **true** meeting `OR` → stop, the answer is true
- a running value of **false** meeting `AND` → stop, **unless followed by OR**
- This beacause the value has not been settled if an OR is encountered.

Everything after the stopping point is never looked at.

```business-rules
PRINT 1 OR 0 AND 0      ! 1  — `1 OR` settles it; neither 0 is ever seen
PRINT (1 OR 0) AND 0    ! 0  — the parentheses force the AND to be reached
PRINT 0 OR 1 AND 0      ! 0  — 0 OR 1 -> 1, then 1 AND 0 -> 0
PRINT 1 AND 0 OR 1      ! 1  — 1 AND 0 -> 0, then 0 OR 1 -> 1
PRINT 0 AND 1 OR 1      ! 1  — 0 AND 1 -> 0, then 0 OR 1 -> 1
```

Read left to right, each of those is obvious. Read with `AND` binding tighter, the first and the
third both come out wrong.

**The rule: when a condition mixes `AND` and `OR`, always parenthesise.** Not as a tie-breaker for
doubtful cases — always. An unparenthesised `A OR B AND C` is correct BR and is read wrongly by
almost everyone, including the author six months later, because every other language they know
groups it the other way. The parentheses cost nothing and remove the question:

```business-rules
IF A OR B AND C THEN …        ! legal, and misread by nearly every reader
IF (A OR B) AND C THEN …      ! what BR actually does — say so
IF A OR (B AND C) THEN …      ! if this is what you meant, the parentheses are load-bearing
```

**A second consequence: a function call in the abandoned part of a condition never runs.** If it
has a side effect, reordering the terms changes what the program *does*, not just how fast it does
it.

> **For anyone re-folding this section.** These rows previously separated `AND` (tighter) from
> `OR` (looser), matching most other languages. That was wrong, and BR's own precedence table
> (`table5x`) had it right all along by giving `&&`, `AND`, `||` and `OR` the same value.

**Modulo is a function, not an operator** — use `MOD(a, b)`; there is **no** infix `a MOD b`. See
[system-functions](../system-functions/spec.md). Note the trap below: `%` is *accepted* and returns
the wrong answer.

<a id="non-operators"></a>
### Spellings that look like operators and are not

BR's runtime carries opcodes for a set of bitwise and shift operations that the language never
completed. They divide into two kinds, and **the second kind is dangerous**:

| Spelling | What happens | Why |
|---|---|---|
| `^` | **Error 1026** (illegal expression) | the expression parser has no case for it; it is *not* exponentiation — use `**` |
| `&` `\|` between numbers | **Error 1026** | the parser reaches `NUM_ERR`; only the doubled `&&` / `\|\|` are operators |
| `%` | **compiles, always yields `0`** | the compiler emits a `MODULO` opcode; the runtime evaluator has no case for it |
| `<<` `>>` | **compiles, always yield `0`** | same — the evaluator's `SHIFT_LEFT` / `SHIFT_RIGHT` cases are commented out |

```business-rules
PRINT 17%5          ! 0, not 2 — no error, no warning
PRINT 1<<4          ! 0, not 16
```

The first three rows fail loudly and cost nothing. `%`, `<<` and `>>` fail **silently**: a program
using them compiles, runs, and computes zero. Nothing in BR reports it. Treat all six as
non-existent.

The compound assignment operators `+=` `-=` `*=` `/=` (and multiple assignment `A=B=C=0`) are
assignment-level — see [assignment](../assignment/spec.md#let).

### Relational operators
| Operator | Alternatives | Meaning |
|---|---|---|
| `<` | | Less than |
| `>` | | Greater than |
| `=` | `==` | Equal to |
| `<>` | `><`, `~=` | Not equal to |
| `<=` | `=<` | Less than or equal to |
| `>=` | `=>` | Greater than or equal to |

<a id="truth-tables"></a>
### Logical truth tables
| A | B | `A AND B` | `A OR B` |
|---|---|:---:|:---:|
| true | true | true | true |
| true | false | false | true |
| false | true | false | true |
| false | false | false | false |

<a id="examples"></a>
## Examples

Worked evaluation (precedence in action):
```business-rules
((5+1)*(1+2))+2**3/4
  = (6*3)+2**3/4       ! parentheses first
  = 18+2**3/4          ! more parentheses
  = 18+8/4             ! exponentiation
  = 18+2               ! division
  = 20                 ! addition
```

Relational and logical conditions:
```business-rules
00100 IF X > 10 AND Y < 5 THEN GOTO 500
00110 IF NAME$ = "John" OR NAME$ = "JOHN" OR NAME$ = "john" THEN GOTO 200
00120 IF (A > 0 OR B > 0) AND C = 100 THEN PRINT "Valid"
00130 IF NOT SCORE >= 0 THEN GOTO SCORE_PROMPT
```

String comparison (ASCII, case-sensitive):
```business-rules
00010 IF "a" < "b" THEN PRINT "a is less than b"            ! true
00020 IF "Aaron" > "Aardvark" THEN PRINT "Aaron > Aardvark" ! true (o > d)
```

<a id="see-also"></a>
## See also

- [assignment](../assignment/spec.md) — `LET`, the assignment form of `:=`, substring mutation
- [conditionals](../conditionals/spec.md) — `IF`/`WHILE`/`UNTIL` that consume these expressions
- [data-types](../data-types/spec.md) — the numeric and string operands
- [syntax — name resolution](../../syntax/spec.md#name-resolution) — how `name(...)` is decided
  between a call, a subscript and a substring
- [system-functions](../system-functions/spec.md) — the intrinsics whose arity drives that decision
- (Backing keyword pages verified against this spec and pruned.)
