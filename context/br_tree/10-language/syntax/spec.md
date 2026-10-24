---
title: Lexical structure & program syntax
file: spec.md
source: §Lexical Structure, §Language Overview
category: 10-language
subcategory: 10-language/syntax
kind: spec
status: 2b           # reference base + br_tree enrichment (line continuation, name resolution); no conflicts
recovered-fold: Keyword_Abbreviation (rules folded; full-table page RETAINED), DIAGRAM_CONVENTIONS (folded+pruned). 2 redirect-collision pages re-fetched; verbatim retained on the BR wiki
corrections:
  - "§Keyword abbreviations rewritten from the interpreter's own matcher (tokensub, and the syntax-tree keyword compare). The wiki appendix disagrees in 15 places and is stale — do not re-fold it over this section."
  - "§Comments corrected. The section said a `!` comment ends at the end of the current statement, and its example asserted that `LET X = 5 ! set initial value :LET Y = X * 2` still assigns Y. It does not. BR's compiler (command6.cpp, the comment copy loop) scans past every `:` and stops only where the character before the colon is `!` — that is, only at `!:`. A plain colon inside a comment is comment text. The corpus settles it beyond argument: 381 comment bodies in the reference corpus alone contain a bare colon, `! ***** Convert H:M:S To Seconds` among them, and every one of those programs compiles. REM is unchanged and runs to end of line, but the reason it differs is now stated: the same loop skips the `!:` check for REM."
  - "NEXT removed from the intrinsics-outside-the-tables list in §Name resolution, and from that section's DIM example. It is not an intrinsic: it resolves in neither table6k nor table7k, and unlike ABS/INT/SGN (command3.cpp, gated on a following open paren) and AIDX/DIDX (command5.cpp, MAT path) the expression parser has no match for it. It is a keyword — table3k for FOR/NEXT, table4k for record positioning. The DIM line stayed true after the edit (no keyword in BR is reserved) but it was illustrating intrinsic-shadowing with something that is not an intrinsic."
  - "§Name resolution said \"these six names\" where the list above it holds five (ABS, INT, SGN, AIDX, DIDX). Left over from the same edit that removed NEXT from that list (see the note above): the list was corrected and the count under it was not. Confirmed against functions.json, whose outside_tables set is exactly those five."
related: [conditionals, other-flow, functions-udf, system-functions, expressions]
keywords: [REM, comment, line-number, label, continuation, "!:", abbreviation, identifier, name-resolution]
---

# Lexical structure & program syntax

How BR source is written: line numbers, comments, identifiers, line labels, and multiple
statements per line — and [how BR decides what a bare token *is*](#name-resolution), which is by
arity rather than by symbol table and catches most newcomers out. The control statements that
*use* line refs are in [other-flow](../flow-control/other-flow/spec.md) and
[conditionals](../data-manipulation/conditionals/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<line-number> ::= <integer>                      -- 1 to 99999, required on every line
<comment>     ::= '!'  [ <text-to-end-of-statement> ]
               |  REM  [ <text-to-end-of-line> ]
<identifier>  ::= { <letter> | '_' } { <letter> | <digit> | '_' }*
<line-label>  ::= ' ' <identifier> ':'           -- immediately after the line number
<line-ref>    ::= <line-number> | <line-label>
```

Statement separators: `:` or `!:` join multiple statements on one physical line.

<a id="semantics"></a>
## Semantics

<a id="line-numbers"></a>
### Line numbers
- **Required on every program line**; range **1–99999**; conventionally incremented by 10
  (`100, 110, 120 …`) to leave room for insertions.

### Language-wide lexical rules
- **Case-insensitive** keywords and identifiers (`PRINT` = `pr` = `Print`; `NAME$` = `name$`).
- **Abbreviated keywords** — most statements/commands have short forms (`PRINT` → `PR`); see
  [§Keyword abbreviations](#abbreviations).
- **Implicit typing** — variables need no explicit declaration (created on first use).

<a id="comments"></a>
### Comments — `!` vs `REM`
Both are non-executable and preserve case. They differ in **scope**:
- **`!`** runs to the end of the line, **unless** it is ended by an explicit `!:`. A plain `:`
  inside a comment is comment text and does **not** start a new statement:
  ```business-rules
  00100 LET X = 5 ! set initial value :LET Y = X * 2   ! all of this is comment; Y is NOT assigned
  00110 LET X = 5 ! set initial value !: LET Y = X * 2 ! Y IS assigned — !: ends the comment
  ```
  `!:` is the only thing that closes a comment, which is why it doubles as the
  [line-continuation marker](#line-continuation): a bare `!:` is an empty comment followed by a
  statement separator.
- **`REM`** ends at the end of the **line** — everything after it, including `:`-joined
  statements, is comment text. Unlike `!`, **not even `!:` ends it**:
  ```business-rules
  00200 REM whole line is a comment : LET Y = 5        ! Y is NOT assigned
  ```
- Use `!` for inline comments (by far the most common), `REM` for stand-alone comment lines.

<a id="identifiers"></a>
### Identifiers
1–30 characters; must start with a letter or `_`; may contain letters, digits, `_`;
case-insensitive. (String variables add a trailing `$`.) A name held in the runtime function
tables (`table6k` ∪ `table7k`) cannot be a variable; a few intrinsics resolved *outside* those
tables can be — see [name resolution](#name-resolution) for what that costs you.

<a id="name-resolution"></a>
### Name resolution — how BR decides what a token is
BR does **not** decide by looking the name up in a symbol table. It decides by 
**arity**: on meeting a token that matches a keyword or intrinsic, it checks whether 
the **mandatory operands that name requires are actually present**. If they are, the 
token is accepted as that keyword or function. If they are not, BR moves on, and 
the token eventually resolves as a variable.

This is the general rule behind BR's positional lexicon — the same mechanism that lets a label or
variable reuse a statement-keyword spelling. Its sharpest consequence involves the intrinsics that
live outside `table6k`/`table7k` (`ABS`, `INT`, `SGN`, `AIDX`, `DIDX`), which are
therefore not reserved:

```business-rules
00010 DIM AIDX, ABS, SGN         ! legal — no arguments supplied, so these are names
00020 LET ABS = 7
00030 PRINT ABS                  ! 7        — the variable
00040 PRINT ABS(3)               ! 3        — the intrinsic, in the same program
```

```business-rules
00010 DIM ABS(3)                 ! rejected — ABS(3) supplies ABS's required argument,
                                 ! so it reads as a call; no subscript reading remains
```

So a scalar variable and an intrinsic of the same name coexist, told apart **only** by whether an
argument is present — and such a variable can never be subscripted, because the subscripted form
is always the function.

Two corollaries worth stating plainly:

- **A `DIM` does not shadow an intrinsic.** Declaring `ABS` does not make `ABS(3)` a subscript.
- **Being declared is not what distinguishes `X(3)` from `SIN(3)`.** Arity is. `X` requires no
  arguments and so yields a name that `(3)` then subscripts; `SIN` requires one, so `SIN(3)`
  is a call. Reasoning from "is it DIM'd?" gives the wrong answer for any declared intrinsic.

Writing a variable with one of these five names is legal and inadvisable; a language server may
reasonably warn about it.

**Scope: this is about keywords and *system* functions.** User-defined and library functions are
not part of this contest — every one is named `FN…`, and a variable never starts `FN`, so the
name alone settles what a `FN…` token is and no arity lookahead is needed to disambiguate it.
Their signatures follow their own rules (typed and sized returns, `;`-optional parameters, `&`
by-reference parameters, one exit), which belong to
[functions-udf](../flow-control/functions-udf/spec.md) and do not carry over from anything above.
The one rule the two do share: a **parameterless** function of either kind is called with no
parentheses — `FNGET$`, never `FNGET$()`.

<a id="line-labels"></a>
### Line labels
A name immediately after the line number, ending in `:`. Usable anywhere a line number is
expected (a `<line-ref>`). Must be unique in the program; may reuse keyword/variable spellings.
```business-rules
00050 FORMULA: LET MPG = MI/GAL   ! label definition
00100 GOTO FORMULA                ! jump to the labeled line
```

<a id="multiple-statements"></a>
### Multiple statements per line
Separate statements on one physical line with `:` (or `!:`). Useful for compact branches and
loop bodies — but see the comment-scope rules above when mixing with `!`/`REM`.

<a id="line-continuation"></a>
### Line continuation — `!:`
`:` joins statements on one physical line; **`!:`** joins them but tells BR to **LIST** each part on
its own physical line while they keep the same line number — each such part is a **sub-line**. This
is the standard way to write one logical line across several display lines.
```business-rules
00010 LET A = 1 !:
      LET B = 2 !:
      LET C = 3          ! all three are line 00010, listed separately
```
A **paragraph (line) label** may **not** follow a `!:` continuation, but it may follow a sub-line that
is commented out with a bare `!`:
```business-rules
00010 TOP: ! !:
      PRINT NEWPAGE
```

<a id="abbreviations"></a>
### Keyword abbreviations
Primary keywords (statement/command **names**) and secondary keywords (other words in a statement) may
be abbreviated (`DELETE`→`DEL`; any longer prefix also works — `DELE`, `DELET`). **The two are matched
by different mechanisms, and the minimum differs accordingly.**

**Primary keywords — shortest *unique* prefix.** BR looks the token up in the keyword table for its
position, scanning only the entries that share its first letter; two partial matches cancel to "not a
keyword" rather than resolving to the first of them. An exact whole-word match wins outright even where
a longer keyword extends it (`FRE` is the FRE command, not an abbreviation of `FREE`). Common minimums:
`PRINT`→`PR`, `PRINT FIELDS`→`PR F`, `PRINT USING`→`PR U`, `INPUT`→`IN`, `INPUT FIELDS`→`IN F`,
`LET`→`LE`, `LINPUT`→`LIN`, `GOSUB`→`GOS`, `GOTO`→`GOT`, `EXECUTE`→`EXE`, `RINPUT`→`RI`, `MAT`→`M`,
`NEXT`→`N`, `WRITE`→`W`, `PAUSE`→`PA`; the five `OPEN …` forms and both `READ` forms all share
`OPE`/`REA`. Commands: `CHDIR`→`CH`, `CONFIG`→`CON`, `COPY`→`COP`, `DIR`→`DIR`, `LIST`→`LIS`,
`RENAME`→`RENA`, `RENUM`→`RENU`, `STATUS`→`ST`, `TYPE`→`TY`, `DEL`→`DEL`, `FREE`→`FREE`.

**Secondary keywords — any prefix.** Where a statement's syntax admits a particular clause keyword, BR
compares the token against **that one keyword** and accepts any non-empty prefix of it; it does not
consult the table, so uniqueness never arises. That is what "secondary abbreviations are not unique —
BR uses the context and placement of the keyword" means. `SEARCH=` shows the difference at its widest:
it cannot be shortened at all in a table lookup, `SEARCH` being equally a prefix of `SEARCH>=`, yet a
bare `S` is accepted where the syntax expects `SEARCH=`. Two exceptions: a clause keyword in an `ON`
statement needs at least three characters, and for the `=`-suffixed forms BR takes `=>` as `>=` and
needs no space after the `=`.

**Function names never abbreviate** — always the full spelling.

**Caution:** BR auto-expands abbreviations **only inside program statements** — never in commands,
procedure files, `BRConfig.sys`, or `EXECUTE` literal strings, and never inside literals — so **spell
keywords out in full** in those places. Full appendix (every command/statement minimum):
[Keyword_Abbreviation](Keyword_Abbreviation.md) — but **the appendix is stale in fifteen places** and
the minimums above supersede it. It gives `CD` for `ChDir`, which is not a prefix of the word and which
the interpreter has no way to match; `DE`, `DI`, `FR`, `REN` and `LI` have since gone ambiguous against
`DEBUG`, `DISPLAY`, `FRE`, `RENUM` and `LIBRARY`; and nine entries are more conservative than BR now
is. The page is retained verbatim as wiki source, so do not "correct" this section back to it.

<a id="diagram-conventions"></a>
### Reading the manual's syntax diagrams
The original BR manual/wiki uses railroad diagrams (this corpus uses BNF instead). In those diagrams:
**UPPERCASE** = an exact keyword (type it, or an allowed abbreviation); **lowercase** = a parameter you
replace (defined in the following Parameters section); shown punctuation (`,` `:` `/`) must be typed;
items on the **main line** are required (if you can reach the end without passing a parameter, it's
optional); a **returning dotted line** means the item may repeat (separated by the shown `,`/`;`); `<n>`
in angle brackets is a default keyed to the Defaults list; **insertable** sub-diagrams (e.g.
`helpstring`, `share-spec`) have no start/end circles; the **end circle** marks the statement's end.

<a id="program-structure"></a>
## Program structure

- **Size limits**: up to **32,000 lines** (line numbers 1–99999); dictionary up to **2 MB**.
- **Conventional layout**: header comment block → initialize (`DIM`, `ON ERROR GOTO`) → main
  (dispatch via `GOSUB`s) → `STOP` → subroutines at high line numbers → error handler → `END`.
- **Best practices**: meaningful line labels over bare numbers; comment section dividers; keep
  related code together; one consistent error handler (`ON ERROR`); place subroutines at the end.
- **Menu-driven** programs loop: display options → read choice → dispatch (`ON … GOSUB` or `IF`s)
  → repeat until quit. (Branching constructs: [other-flow](../flow-control/other-flow/spec.md).)

```business-rules
00200 DIM CUST$*30 : ON ERROR GOTO 9000   ! initialize
00310 GOSUB 1000 : GOSUB 2000             ! main: process
00999 STOP
01000 ! subroutine … : RETURN
09000 PRINT "Error";ERR;"at line";LINE : STOP   ! handler
99999 END
```

<a id="examples"></a>
## Examples

```business-rules
00001 ! ========================================
00002 ! Program: MILEAGE   — header comment block
00003 ! ========================================
00020 INPUT MI CONV CONVRSN      ! reference a label
00050 FORMULA: LET MPG = MI/GAL  ! labeled line
00080 CONVRSN: PRINT "Enter numbers, not letters."
00090 RETRY
00100 GOTO FORMULA               ! jump by label
```

<a id="see-also"></a>
## See also

- [other-flow](../flow-control/other-flow/spec.md) — `GOTO`/`GOSUB`/`ON GOTO` that consume `<line-ref>`
- [conditionals](../data-manipulation/conditionals/spec.md) — `IF` line/label targets
- [functions-udf](../flow-control/functions-udf/spec.md) — `DEF`/`FN` definitions
- [system-functions](../data-manipulation/system-functions/spec.md) — the intrinsics whose arity
  drives [name resolution](#name-resolution); which names are reserved
- [expressions](../data-manipulation/expressions/spec.md) — where call-vs-subscript is parsed
- [installation-tooling — Lexi preprocessor](../../00-configuration/installation-tooling/spec.md#lexi) —
  `/* ... */` comments, `X$&=` compound append, and `#Select#`/`#Case#`/`#Define#`/`#AutoNumber#`
  directives are not base-BR syntax at all; they're rewritten to plain BR *before* this spec's
  grammar ever sees them. Encountering one of these in real source is a sign the app preprocesses
  with Lexi, not a gap in this page.
- Backing keyword page retained (deep reference — full command/statement abbreviation appendix):
  [Keyword_Abbreviation](Keyword_Abbreviation.md)
- (Other backing pages folded into this spec and pruned. The 2b
  redirect-collision page `Diagram_Conventions` was folded here and pruned, and `Keyword_Abbreviation`
  retained; verbatim wikitext remains on the BR wiki.)
