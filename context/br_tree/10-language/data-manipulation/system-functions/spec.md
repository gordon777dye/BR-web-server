---
title: System (built-in) functions
file: spec.md
source: §Functions → Internal Functions; br_tree keyword pages folded in & pruned (2b) — ENV$/Encryption/DATE$/DAYS/DATE/NXTFLD/CFORM$ retained for deep detail
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: spec
status: 2b           # reference base + 50 br_tree function pages folded in + runtime-table gap closure
recovered-fold: BR_FILENAME$, BRErr$, COS, MSGBOX, NEWPAGE, REM (6 redirect-collision pages folded from re-fetched source — added MSGBOX/BR_FILENAME$/NEWPAGE, REM=MOD alias, BRErr$ corrected to 4.3+; COS already in trig table; verbatim retained on the BR wiki)
runtime-gap-closure: added the table6k/table7k intrinsics that had no br_tree signature — SGN, RND, XLATE$, RLN, VERSION(file), LINESTATUS$, CURPOS, SCR_FREEZE/THAW, SERIAL, SESSION$, PROCLVL, TIMER, SETENV, VARIABLE$, WBVERSION$, WBPLATFORM$, SYSERR/SYSERR$ (xref), MSG (xref), and the PEM integration set GET$/SET$/INVOKE$/DLL. Sourced from the brulescorp wiki + release notes; the delimiter arg of STR2MAT/MAT2STR documented (there is no DLM$ function).
source-verified: 'cross-checked against the BR interpreter source (basfn.h/tblfn.cpp function tables, ck_num_sysfn/ck_alph_sysfn arity checkers, numfunct.cpp/strfunct.cpp/trig.cpp impls). Corrections: TRUNC/DEG/RAD are reserved keywords that parse but return a runtime bad-function error (NOT implemented — trig() lacks them); CALL is in table7k but has no function implementation (compiler-rejected); SHIFT is a fixed-0 System/23 no-op; SCR_FREEZE/THAW take no args (freeze/thaw remote display); DLL is ≥2 strings dispatched client-side; SETENV is 1–2 args.'
corrections:
  - "The MSG row documented MSG(\"KB\",keys$) as injecting keystrokes through Windows. BR 5.0
    removed the kb action - it now raises 0412 - and send has not gone through the operating
    system since 2026-09-30: it puts its keys into BR's own buffer, reaching this session only and
    needing no focus. Rewritten around send; MSG.md carries the full action list and the
    brmsg.cpp evidence. 2026-10-12."
  - "MSG(\"sleeptime\",n) unit corrected to milliseconds (was given as centiseconds here; see MSG.md corrections for the brmsg.cpp evidence). Reported in context/ERRORS.md 2026-09-28."
  - "LPAD$/RPAD$ take an optional third argument, the pad character. ck_alph_sysfn (command2.cpp) reads `case LPAD_: case RPAD_: // 2-3 string, numeric, optional string` and enforces `BETWEEN(2, 3, subcount)` with PARMCHECK_STRING on the third. Neither this spec nor the dev catalog derived from it carried the third argument, and 46 lines of the reference corpus use it. Found in brls phase 5."
  - "The source-verified note above claimed 'Exact arities confirmed for all'. It was not true of LPAD$/RPAD$ above, and the dev catalog inherited both the claim and the error, so the claim is withdrawn rather than restated. What is verified is the function roster and the individual corrections listed in that note; the arities as a whole have not been checked case by case against ck_num_sysfn/ck_alph_sysfn. Doing that mechanically is brls LSP_PLAN.md, Where the authority sits."
  - "DATE$ and DATE were given as `DATE$(days,\"mask\")` and `DATE(days,\"mask\")`, both arguments required. BR accepts none, one or two of them: ck_alph_sysfn (command2.cpp) reads `case DATE_: // 0-2 with 1 either, numeric, alpha` and ck_num_sysfn (command3.cpp) `case DATE_FN: // 0-2 parameters (1 numeric and 1 string both optional)`. The one-argument forms were never lost from the tree — the DATE$ backing page beside this spec is full of them (`PRINT DATE$(\"mm-dd-yy\")`, `PRINT DATE$(1)`, `DATE(\"m\")`) — it was the summary table here that dropped them, and the dev catalog generated from that table inherited the loss. Bare numeric `DATE` added to the no-parentheses list for the same reason. 1,216 lines of the reference corpus use a form this table called impossible. Found in brls phase 5."
  - "Nine signatures corrected against BR's own arity checkers (ck_alph_sysfn in command2.cpp, ck_num_sysfn in command3.cpp) and their implementations in strfunct.cpp/numfunct.cpp: TRIM$ takes the same optional strip character as LTRM$/RTRM$; BRERR$ and SYSERR$ take their code optionally, bare meaning the last error; FILE$ takes a second keyword argument querying the open file; SQL_DATE$/BR_DATE$ take the format optionally; HELP$ takes two arguments at most and the second is numeric, not the third string this table listed; LOGIN_NAME$ with an argument sets the name rather than being an atom. Separately, TIME$/CURROW/CURCOL/PROCIN are accepted with one argument by the compiler and ignore it at run time, which is now marked ‡ and explained rather than documented as an optional parameter. Found in brls phase 5 by diffing every arity in the two checkers against the generated pack — 15 of 119 disagreed."
  - "NXTFLD was given as `NXTFLD[(…)]`, \"4 syntax forms\", and the retained NXTFLD.md backing page documented a parameterised setter at length. NXTFLD takes no arguments and is not assignable. ck_num_sysfn (command3.cpp) lists it under `// 0 parameters` with NXTROW/NXTCOL/CURPOS/TIMER and returns -1 for any subcount; both the bare form (command3.cpp:524) and any parenthesised form (:653) reach that same checker, and the one escape from it, NOT_FN_REF, is guarded by EXTENDED_USER_FUNCTION and so is reachable only by FN… names. numfunct.cpp reads fieldsdata.tnxtFld without popping an argument. The parameterised behaviour described on that page is CURFLD's: ck_num_sysfn reads `case CURFLD: // 0-3 parameters if 2 or more numeric, string, numeric` and numfunct.cpp implements it as `// curfld(pos,attr$,firstkey)` — the page's own prose gives it away, explaining its `LET NXTFLD(NXTFLD,FKEY)` example with the sentence \"The CURFLD function in line 40 is then used to…\". Corroborated by the reference corpus: 696 files call CURFLD with 1-3 arguments and not one of 1,107 files writes NXTFLD with any. NXTFLD added to the no-parentheses list above for the same reason. Determined by the maintainer, who states NXTFLD never supported parameters; found in brls phase 5."
  - "This page documented the workstation-ID function as bare `WSID` (no-parentheses atom list, the
    System/information table row, and the `SESSION$` description). There is no numeric `WSID`
    function — confirmed against `table6k.txt`, BR's own runtime function-name table, which lists
    `WSID$` and nothing named `WSID` bare; `dev/system-functions-catalog.md`'s roster (built from
    that same table) already carried the correction note ('there is no numeric WSID; the curated
    spec's WSID is a typo for WSID$') that this page never picked up. All three mentions corrected
    to `WSID$`. (The unrelated `WSID` **config directive** — `@user WSID <n>`, `OPTION 74` — is a
    different keyword class entirely and is unaffected; see
    [00-configuration/config-directives](../../../00-configuration/config-directives/spec.md).)
    Found while auditing this page's `keywords:` frontmatter against its own body, 2026-09-11."
  - "CODE was given as the \"numeric return value of the most recent procedure (set by `EXIT n`)\",
    with a worked example reading `EXECUTE \"PROC BACKUP\"` then `IF CODE = 0`. No such mechanism
    exists. There is no `EXIT` COMMAND in BR at all: `tblcmd.cpp`'s keyword table has no entry for
    it, and `EXIT` exists only as the loop statement `EXIT DO`/`EXIT FOR` (`EXIT_PRI`, tblopr.cpp).
    Measured rather than inferred - a proc whose line is `EXIT 3` raises **error 1000**,
    *unidentified source remaining*, and CODE is still 0 afterwards; the documented idiom was run
    end to end in BR 5.0 and reports `code-after-proc 0`.

    What CODE actually is: `t.returncode`, read by `numfunct.cpp` at `case CODE` (commented there
    as 'the return code set by last program'). Every assignment to it, exhaustively: `STOP n` and
    `END n` (run.cpp, `t.returncode = (dict) ? toInt(dict) : 0` - so a BARE `STOP` sets it to 0,
    which is why a program ending normally clears it); `SYSTEM n` (command7.cpp), which is BR's
    exit status to the operating system rather than a value a program lives to read; the `ONQ` and
    shell returns (command7.cpp); and a zeroing by `CLEAR`. BR 5.0 added a zeroing by `LOAD` and by
    `CHAIN` (2026-10-13) so that CODE cannot be read stale from a program that ran before the one
    now loaded. `RUN` deliberately does NOT reset it: re-running an already-loaded program leaves
    the previous run's code standing until that run sets one, which for a program ending in a bare
    `STOP` is immediately.

    A `LIBRARY` load does not reset it either, deliberately: that happens while a program is
    running, and clearing CODE under a program about to read it would lose the value rather than
    make it trustworthy.

    dev/system-functions-catalog.md carried the same claim, derived from this table, and is
    corrected with it. brls.exe and lscheck.exe embed the old wording and need a rebuild from the
    corrected pack. 2026-10-13."
  - "Signatures made exact against BR 5.0's own argument checkers, and this page made the source
    brls reads them from (2026-10-13). A [signature notation](#signature-notation) section now says
    what a signature claims: the counts and types ck_alph_sysfn (command2.cpp) and ck_num_sysfn
    (command3.cpp) accept, with a|a$ for a position BR types either way and nested brackets for
    optionals that depend on one another. brls's TestPackSignaturesMatchBR runs both checkers over
    every count up to six and every assignment of the two types, and the corrections below are
    what it and the cross-check against dev/system-functions-catalog.md required. Rows added for
    the thirteen intrinsics that had none here - CURROW, CURCOL, CURFLD, CURWINDOW, CMDKEY, FKEY,
    MENU, MENU$, KLN, KREC, PROGRAM$, DEBUG_STR, PRINTER_LIST - and a table row for MSGBOX, whose
    signature was only in prose. MAX/MIN/MAX$/MIN$ take two or more (subcount < 2 is refused), not
    any number; RND takes an optional seed; DAYS's date may be a string (no check on parms[0]);
    SQL_DATE$/BR_DATE$ take a string first (LTRM$'s case, both strings); UDIM's array may be of
    either type, SUM's must be numeric, and SRCH's value must match its array's type
    (parms[0] != parms[1] is refused); STR2MAT/MAT2STR, FILE$ and MSGBOX's optionals are nested, the
    flags only after a separator and FILE$'s keyword only after a channel; FILE's MAT is optional
    (numfunct.cpp reads the keyword at parms >= 2 and the array only at 3); ENV$'s first argument is
    a string name and its others either type; SETENV's value either type; MSG takes one or more,
    only the first checked; HELP$'s topic is a string; DLL's arguments after the second are
    unchecked; DECRYPT$ written out. Eighteen of these confirmed by LOADing a probe in the kit's
    4.33c brserver - every refusal raised 1042 and every acceptance loaded clean."
related: [expressions, assignment, declaration, data-types]
keywords: [CNVRT$, POS, LEN, TRIM$, UPRC$, LWRC$, STR$, VAL, DATE$, TIME$, RND, MAX, MIN, SUM, MSGBOX, KSTAT$, AIDX, DIDX, UDIM, SRCH, STR2MAT, MAT2STR, CHR$, ORD, LTRM$, RTRM$, LPAD$, RPAD$, RPT$, SREP$, XLATE$, LOGIN_NAME$, CFORM$, HEX$, UNHEX$, PIC$, INT, IP, FP, CEIL, ROUND, TRUNC, ABS, SGN, SQR, MOD, MAX$, MIN$, SIN, COS, TAN, ATN, DEG, RAD, LOG, EXP, PI, DAYS, SQL_DATE$, BR_DATE$, FILE, FILE$, FILENUM, FREESP, EXISTS, BR_FILENAME$, OS_FILENAME$, KPS, LREC, RLN, VERSION, LINESTATUS$, LINES, LINESPP, NXTFLD, NXTROW, NXTCOL, CURPOS, CURTAB, SCR_FREEZE, SCR_THAW, CNT, BRERR$, ENV$, CODE, PROCIN, WSID$, USERID$, SESSION$, PROCLVL, TIMER, VARIABLE$, WBVERSION$, WBPLATFORM$, SYSERR, SYSERR$, SHIFT, MSG$, MSG, SLEEP, SPAWN_RESTRICTED, HELP$, GET$, SET$, INVOKE$, CALL, ENCRYPT$, DECRYPT$, CMDKEY, FKEY, CURROW, CURCOL, CURFLD, CURWINDOW, MENU$, KLN, KREC, PROGRAM$, DEBUG_STR, PRINTER_LIST]
---

# System (built-in) functions

BR's intrinsic functions — they return a value and are used inside
[expressions](../expressions/spec.md). Grouped below by purpose. User-defined functions
(`DEF`/`FN`) are a separate topic in
[flow-control/functions-udf](../../flow-control/functions-udf/spec.md).

<a id="syntax"></a>
## Syntax

Most take the form `NAME(args)`. A few system values take **no parentheses**: `DATE$`, `DATE`, `TIME$`,
`ERR`, `LINE`, `CNT`, `CODE`, `PROCIN`, `FILENUM`, `INF`, `PI`, `USERID$`, `LOGIN_NAME$`, `WSID$`,
`SERIAL`, `SESSION$`, `PROCLVL`, `TIMER`, `VARIABLE$`, `WBVERSION$`, `WBPLATFORM$`, `SYSERR`,
`SYSERR$`, `BRERR$`, `MENU$`, `CURPOS`, `NXTFLD`, `RND` (and `PIC$`, whose parentheses are optional). All yield a value usable
anywhere an expression is allowed.

<a id="signature-notation"></a>
**Signature notation.** The signatures in the tables below are the argument counts and types BR's
compiler accepts — `ck_alph_sysfn` (`command2.cpp`) and `ck_num_sysfn` (`command3.cpp`) check every
call against them, and a call outside them fails at LOAD with error **1042**, *system function
parameter mismatch*. BR types each argument as it compiles it, as a string if it can and as a number
otherwise; an array argument has its elements' type.

- No type tags: a `$` suffix is a **string** argument and no suffix a **number**, without exception.
  A quoted literal is a string.
- `MAT x` / `MAT x$` is an array of that type; the `MAT` keyword is optional (see
  [semantics](#mat-qualifier)), and `[MAT]x$` says so in place.
- `[ ]` encloses optional arguments. A bracket nested in another needs the one around it:
  `F(a$[,b$[,c]])` takes one, two or three arguments, never `a$` and `c` alone. A bracket written
  *on* a name — `[^]s2$`, `[-]start` — is text inside that argument, not an optional one.
- `x…` is an argument that may be repeated: one or more of them.
- `a|a$` is an argument the compiler accepts as **either type**.
- `NAME[(…)]` may also be written bare, with no parentheses.
- A row listing several signatures for one name lists every form the compiler accepts.

**Assignable pseudo-variables**: `CMDKEY`, `CURFLD`, `CURTAB`, `CURWINDOW`, `FKEY`, `PIC$`. Each
is set by calling it with `LET` and no `=` — `LET FKEY(5)`, `LET CURFLD(5)` — never by assigning to
it: `LET FKEY=5` and `LET FKEY(5)=1` both fail LOAD with 1026 (1030 for `PIC$`).

<a id="semantics"></a>
## Semantics

- String functions return strings (suffix `$`); numeric functions return numbers.
- The **array-processing** functions (`AIDX`/`DIDX`, `UDIM`, `SUM`, `SRCH`, `STR2MAT`/`MAT2STR`)
  take array arguments and pair with [assignment](../assignment/spec.md#mat).
- <a id="mat-qualifier"></a>**The `MAT` qualifier is optional.** Wherever an argument must be an
  array, BR accepts either `MAT name` or a bare `name`, and reads the bare name as an array name.
  Both `UDIM(MAT Y)` and `UDIM(Y)` compile. Signatures in this spec and in
  [`dev/system-functions-catalog.md`](../../../../dev/system-functions-catalog.md) may show either
  spelling; neither is the required one.
- **The sole exception is `AIDX`/`DIDX`, which reject it** — `MAT X = AIDX(Y)` compiles,
  `MAT X = AIDX(MAT Y)` does not. They are also functions **only as an operand of 
  a `MAT` primary**, the right-hand side of a `MAT` assignment, and are not callable 
  in an ordinary expression; see
  [assignment](../assignment/spec.md#syntax) for the `<mat-rhs>` production they belong to.
- `LEN(s$)` returns the **actual** current length, not the `DIM` maximum.
- **Inverse pairs**: `CHR$`↔`ORD`, `HEX$`↔`UNHEX$`, `STR$`↔`VAL`, `ENCRYPT$`↔`DECRYPT$`.
- Several entries here query **file/window** or **screen/keyboard** state; they live in this index
  but belong operationally to [30-io-file](../../../30-io-file/statements/spec.md) and
  [20-io-screen](../../../20-io-screen/input-output/spec.md) — cross-linked in their tables below.
- `PROCIN` / `PROGRAM$` are value-returning here but their reference pages live under
  [70-commands/information](../../../70-commands/information/spec.md).

<a id="tables"></a>
## Tables

<a id="string-functions"></a>
### String & character
| Function | Returns |
|---|---|
| `CHR$(n)` | character for ASCII code `n` |
| `ORD(s$)` | ASCII ordinate (0–255) of the first char of `s$` (inverse of `CHR$`) |
| `UPRC$(s$)` / `LWRC$(s$)` | upper / lower case |
| `TRIM$(s$[,c$])` | strip leading **and** trailing spaces (or the 1-char `c$`) — the same optional argument as `LTRM$`/`RTRM$`, read on the same line of `strfunct.cpp` for all three |
| `LTRM$(s$[,c$])` / `RTRM$(s$[,c$])` | strip leading / trailing spaces (or the 1-char `c$`, nulls allowed) |
| `LPAD$(s$,n[,pad$])` / `RPAD$(s$,n[,pad$])` | pad to length `n` (left / right), with `pad$` if given and a space otherwise |
| `RPT$(s$,n)` | `s$` repeated `n` times |
| `LEN(s$)` | actual current length |
| `POS(s1$,[^]s2$[,[-]start])` | position of `s2$` in `s1$` (0 if none); `^`=case-insensitive (`CONFIG SEARCH_CHAR`); `-start`=search backward |
| `SREP$(src$[,start],find$,repl$)` | string replace (each occurrence) |
| `XLATE$(s$,table$[,start])` | translate `s$` through a 256-byte `table$`: each input char of ASCII value `n` is replaced by the `(n+1)`-th char of `table$`; chars past the table's length pass through unchanged. Optional `start` position. A `table$` beginning `STR2UTF`/`UTF2STR` does UTF-8 conversion |
| `LOGIN_NAME$[(name$)]` | current user's login name (3.83h+); **with an argument it sets the name** |

<a id="conversion-functions"></a>
### Type conversion & formatting
| Function | Returns |
|---|---|
| `STR$(n)` | number → string (plain) |
| `VAL(s$)` | string → number |
| `CNVRT$(spec$,n)` | number → string per a FORM format code (`B BH BL D G GZ L N NZ PD PIC S ZD`); enhanced `STR$` (slower than a `FORM`) — see [form-spec](../../../30-io-file/form-spec/spec.md#syntax) |
| `CFORM$(form$)` | pre-compile a FORM string into a fast format variable (see note) |
| `HEX$(s$)` | **hex text → binary.** `s$` must be hex digits in **pairs**: `HEX$("2B00")` → 2 bytes (printer escapes; a printer translation starts this way). `HEX$("ABC")` (odd length) is invalid, and passing data that is not hex-digit text can abort the BR process rather than raise a trappable error — validate before calling |
| `UNHEX$(s$)` | **binary → hex text** — the inverse. Renders arbitrary bytes readable: a 20-byte `ENCRYPT$(…,"SHA-1")` digest becomes its familiar 40-character hex string |
| `PIC$[(sym$)]` | current currency symbol; with a 1-char `sym$`, sets it (persists until changed / BR exit; per-workstation) |

> **`CFORM$` caveat** — output is an unreadable, machine/release-dependent internal format: never
> save it to a file or pass a format that references a variable (by length/decimals) into a library —
> the compiled form points to a *dictionary slot*, not a name, and may bind to the wrong variable.

<a id="numeric-functions"></a>
### Numeric & math
| Function | Returns |
|---|---|
| `INT(n)` | integer part (truncates) |
| `IP(n)` / `FP(n)` | integer part / fractional part (sign preserved: `FP(-3.1)`=-0.1) |
| `CEIL(n)` | smallest integer ≥ `n` (always rounds up: `CEIL(-5.1)`=-5) |
| `ROUND(n,d)` | round to `d` decimals |
| `TRUNC(n)` | ⚠️ **reserved but not implemented** — parses (1 numeric arg) but returns a runtime *bad-function* error in the current BR source (`trig()` has no `TRUNC` case); there is **no** `[,d]` form. Use `INT`/`IP` to truncate |
| `ABS(n)` | absolute value |
| `SGN(n)` | sign of `n`: `-1` (negative) / `0` (zero) / `1` (positive); a near-zero value can round to `0` per the `RD` config |
| `SQR(n)` | square root |
| `MOD(a,b)` / `REM(a,b)` | remainder (`MOD(7,3)` → 1; **function only, no infix `a MOD b`**; `REM` is an alias for `MOD`) |
| `MAX(n,n…)` / `MIN(n,n…)` | largest / smallest of a numeric list |
| `MAX$(s$,s$…)` / `MIN$(s$,s$…)` | largest / smallest string (by ASCII value) |
| `SIN(n)` `COS(n)` `TAN(n)` `ATN(n)` | trig / arctangent (radians) |
| `DEG(n)` / `RAD(n)` | ⚠️ **reserved but not implemented** — recognized keywords that return a runtime *bad-function* error (`trig()` has no `DEG`/`RAD` case); no radian↔degree conversion exists in the current source |
| `LOG(n)` / `EXP(n)` | natural log / e^n |
| `PI` | 3.14159265358979 |
| `INF` | largest representable number (`1.0E+307`); `1/INF` = smallest |
| `RND[(seed)]` | pseudo-random number in `0`–`1`. Reseed from the clock with [`RANDOMIZE`](../../flow-control/other-flow/spec.md); `LET RND(seed)` sets a fixed seed for a repeatable sequence. Scale e.g. `INT(RND*100+1)` |


<a id="accepted-and-ignored"></a>
> **‡ Accepted with one argument, and ignored.** BR's arity checkers admit a single argument to
> `TIME$`, `CURROW`, `CURCOL` and `PROCIN` — `ck_num_sysfn` groups the last three under
> "optional 1 numeric", `ck_alph_sysfn` groups `TIME$` under "0-1 parameters, optional string" —
> and the implementations never read it. `strfunct.cpp`'s `TIME_` arm is commented *"return system
> time, no parms"*; `numfunct.cpp`'s `CURROW`/`CURCOL` return the field data and return; `PROCIN`
> carries a comment describing a setter it does not implement. So `PRINT TIME$("hh:mm")` compiles,
> runs and prints the ordinary time. This is the same failure mode as `%`, `<<` and `>>` in
> [expressions](../expressions/spec.md#non-operators): the compiler agrees and the runtime has
> nothing to do. Recorded as ignored rather than as an optional parameter, because calling it a
> parameter is the more damaging error.

<a id="date-functions"></a>
### Date / time
| Function | Returns |
|---|---|
| `DATE$` | current date (`yy/mm/dd`) |
| `TIME$` ‡ | current time (`hh:mm:ss`) |
| `DAYS(date\|date$[,mask$])` | day-count; Y2K-aware (BASEYEAR, auto century) 3.83+; dates from 1700 (3.90+) |
| `DATE$([days][,"mask"])` | format a day-count to a string (`"day month, ccyy"`; time masks 4.30+). **Both arguments are optional and either may stand alone**: `DATE$("mm-dd-yy")` formats today, `DATE$(1)` formats a day-count with the default mask |
| `DATE([days][,"mask"])` | numeric date sibling of `DATE$` (for sorting; stores the days value); same optional arguments, and bare `DATE` is today |
| `SQL_DATE$(d$[,fmt$])` / `BR_DATE$(s$[,fmt$])` | pack/unpack SQL dates (4.30+); the format is optional |

> Date *storage* types `DT`/`DL`/`DH` are FORM field types — see
> [30-io-file/form-spec](../../../30-io-file/form-spec/spec.md), not here. The currency/format-string
> behaviour interacts with `PIC$` and `OPTION INVP`. Full mask reference: [DATE$](DATE$.md),
> [DAYS](DAYS.md), [DATE](DATE_\(Internal_Function\).md).

<a id="array-functions"></a>
### Array-processing (used with MAT)
| Function | Returns |
|---|---|
| `UDIM(MAT arr\|MAT arr$[,dim])` | current size of an array (or of dimension `dim`) |
| `SUM(MAT arr)` | sum of all elements |
| `SRCH(MAT arr,arg[,start])` / `SRCH(MAT arr$,arg$[,start])` | row of match [0/ -1(opt 56) if none]; `^` prefix = case-insensitive substring |
| `AIDX(arr)` / `DIDX(arr)` | ascending / descending **index** array (original unchanged) |
| `STR2MAT(s$,MAT a$[,[MAT]sep$[,flags$]])` | split `s$` → array; **dynamically redimensions** `a$`; returns the element count (delimiter/flags below) |
| `MAT2STR(MAT a$,s$[,[MAT]sep$[,flags$]])` | join array → `s$` (delimiter/flags below) |

<a id="str2mat-delimiter"></a>
**`STR2MAT` / `MAT2STR` delimiter (`sep$`) and flags.** `sep$` is an ordinary **user-supplied
delimiter string** — any string variable or literal (older wiki examples name the variable `DLM$`,
but there is **no `DLM$` function**) — or, as of **4.3**, a `MAT` of delimiter strings (`[MAT]sep$`).

- **`STR2MAT` default** (`sep$` omitted): splits on any end-of-line run — **`\n\r`, `\r\n`, `\n`, or
  `\r`** — so multiple CSV/text rows in one string each become an element.
- **Empty delimiter `sep$=""`**: `STR2MAT` puts **every character** in its own element; `MAT2STR`
  **concatenates** with no separator.
- **Adjacent identical delimiters**: `STR2MAT` honors each — all but the first produce an **empty
  element** (e.g. `STR2MAT("Mary,,John",MAT c$,",")` → `Mary`, ``, `John`).
- **`MAT2STR` default** (`sep$` omitted): **`CRLF`** on Windows / **`CR`** on Linux; the delimiter is
  placed **after every element, including the last**.
- **`flags$`** — an optional quote type `Q` / `QUOTES` / `'` / `"` (case-insensitive), optionally
  followed by a trim flag `:TRIM` / `:LTRM` / `:RTRM` (the colon is used only when a quote type
  precedes it). On `STR2MAT`, quoting means a delimiter **inside** a quoted field is not a split point,
  and a **doubled** quote (`""`) inside a quoted field is one literal quote; on `MAT2STR`, each element
  is wrapped in the quote character.
- **Versions**: `MAT2STR` introduced **4.20**; `STR2MAT` CSV/XML/quote/`MAT`-delimiter enhancements
  added in **4.3**.

<a id="file-query"></a>
### File / drive query (I/O handlers — see [30-io-file](../../../30-io-file/statements/spec.md#io))
| Function | Returns |
|---|---|
| `FILE$[(n[,keyword$])]` | open file's name; with no arg = file of the most recent I/O error. A second **keyword** argument queries the open file (`"HTTPINFO"`, `"PAGE-URL"`, …) |
| `FILE(n)` | status: `-1` not open, `0` ok, `10`/`11` EOF in/out, `20`/`21` transmission err in/out |
| `FILE(n,"WINDOW_RECT"\|"USABLE_RECT"\|"FONTSIZE"[,MAT a])` | window/usable rect (x,y,w,h px) or char cell size |
| `FILENUM` | file number of the most recent I/O error (= `FILE$` with no arg) |
| `FREESP(n)` | free bytes on the drive holding file `n` |
| `EXISTS(file$)` | nonzero if file/PROC exists & readable (`1`=directory, `>1`=file) — test zero/nonzero only |
| `BR_FILENAME$(os$)` / `OS_FILENAME$(br$)` | convert an OS path to a BR filename and back (4.18+; omit any leading colon — it would bypass the conversion) |
| `KPS(n[,seg])` | key start position; `seg` selects a split-key section; `-1` if not open / no key / bad seg |
| `LREC(n)` / `REC(n)` | last record / current record number |
| `RLN(n[,newlen])` | record length of open file `n`; the optional `newlen` **resets** it (EXTERNAL files only, and not above the OPEN `RECL=`) |
| `VERSION(n[,ver])` | the marked **version number** of INTERNAL file `n` (**not** the BR release); the optional `ver` sets it when the file is open `OUTPUT` (also settable with `VERSION=` on OPEN); a **negative** `ver` leaves the version as it is and empties the file's deleted record chain, which the next `OUTPUT`/`OUTIN` open that reuses records builds again (see `OPTION 51`) |
| `LINESTATUS$(n)` | serial-line/modem status of communications channel `n` — see [30-io-file/serial-comm](../../../30-io-file/serial-comm/spec.md) |
| `LINES(n)` | lines printed since last new-page (= `KREC` for display files) |
| `LINESPP(n)` | current lines per page (PRINTER `LPP`, else 66) |
| `KLN(n[,seg])` / `KREC(n)` | key length of keyed file `n` (`seg` selects a split-key section) / last record read in the **index** file, not the master; `-1` if `n` is not open keyed (see [keys-indexes](../../../30-io-file/keys-indexes/spec.md#keyed-io)) |

<a id="screen-query"></a>
### Screen & keyboard query (see [20-io-screen](../../../20-io-screen/windows-cursor/spec.md))
| Function | Returns |
|---|---|
| `KSTAT$[(n[,secs])]` | unprocessed keystrokes; with `n`, waits for `n` keys (`secs` timeout each). Fn keys = 2 chars; values are BR scancodes (`UNHEX$` to read) |
| `NXTFLD` | relative position of the next control to be occupied — **no arguments, not assignable**; pairs with `FKEY` to identify a clicked hot control. To *set* the next input field, attribute or exit keystroke, use `CURFLD([field][,attr$][,fkey])` — see [windows-cursor](../../../20-io-screen/windows-cursor/spec.md#semantics) |
| `NXTROW` / `NXTCOL` | row / col of the next cursor position (4.20+; mouse or keyboard; `OPTION 59` for old `CurCol`) |
| `NEXT` | next cursor position within a 2D control (4.20+; used in an INPUT FIELDS `NEXT` clause) |
| `CURTAB[(win[,1])]` | active tabbed-window number; `CURTAB(win,1)` raises that tab (4.16+) |
| `CURPOS` | cursor position **within the field data** when control returns to the program (4.20+); excludes untyped trailing spaces but counts invisible CRLF characters. Cursor row/col are `CURROW`/`CURCOL` — see [windows-cursor](../../../20-io-screen/windows-cursor/spec.md#semantics) |
| `SCR_FREEZE` / `SCR_THAW` | **(no arguments)** suspend / resume **remote (client-server) display** repainting — `freezeRemoteDisplay()` / `thawRemoteDisplay()` in the source; each returns `0` (batch updates, then thaw to repaint once) |
| `CURROW` ‡ / `CURCOL` ‡ | cursor row / column when input ended (see [windows-cursor](../../../20-io-screen/windows-cursor/spec.md#keyboard-results)) |
| `CURFLD[(field[,attr$[,fkey]])]` / `CURFLD(field,row\|cell)` / `CURFLD(field$)` | the 1-based field the cursor was on after the last `INPUT FIELDS`; with arguments it **sets** the next input's starting field, added attributes and a replayed `fkey`, or positions into a 2-D control's `row`/`cell` (see [windows-cursor](../../../20-io-screen/windows-cursor/spec.md#keyboard-results)). The compiler also accepts a single string argument, to no documented effect |
| `CURWINDOW[(n)]` | the focused `PARENT=NONE` window (`-1` if none); `n` raises that window |
| `CMDKEY[(n)]` / `FKEY[(n)]` | the key that ended input (`0` = Enter; `-1` before the first input); `FKEY` is the richer successor, also set by controls, buttons and hot windows. `LET CMDKEY(x)` / `LET FKEY(x)` preset them (see [windows-cursor](../../../20-io-screen/windows-cursor/spec.md#keyboard-results)) |
| `MENU[(n)]` / `MENU$[(n)]` | subscript / data string of the selected native-menu item; `MENU$(n)` gives the *n*-th item's (see [controls](../../../20-io-screen/controls/spec.md#menus)) |

<a id="system-info"></a>
### System / information
| Function | Returns |
|---|---|
| `ERR` | last error number |
| `LINE` | current line number |
| `CNT` | data items successfully processed by the last I/O (`MAT A(CNT)` to size to what was read) |
| `BRERR$([code])` | the *description* of a BR error code — what `ERR` is to the number (e.g. `BRERR$(682)`; 4.3+). **Bare** describes the last error |
| `ENV$(name$[,MAT cfg$\|MAT cfg[,arg\|arg$]])` | environment / status interrogation (4.30+) — see [environment](../../../00-configuration/environment/spec.md#env-read) |
| `CODE` | the return code the last **program** set, with `STOP n` or `END n` (a bare `STOP` or `END` sets 0); 0 until something sets one, and cleared again by `LOAD`, `CHAIN` and `CLEAR` (`RUN` leaves it). **Not** a procedure's return value: BR has no `EXIT n` command |
| `PROCIN` ‡ | non-zero while a procedure is feeding input (0 = keyboard) |
| `WSID$` | this session's workstation ID |
| `USERID$` | BR licensee name |
| `SERIAL` | serial number of this BR software copy |
| `SESSION$` | this session's ID — `WSID$` (3–4 digits) followed by a 1-digit session number `1`–`9` (e.g. `011`, `012`) |
| `PROCLVL` | current procedure nesting level (`0` = keyboard / not in a procedure) |
| `TIMER` | seconds since the Unix epoch (1970-01-01 UTC) as a 5-decimal real; use two readings to time a section (accuracy follows the OS clock) |
| `SETENV(name$[,value$\|value])` | set a **BR session** environment variable (read back with `ENV$`; function form of `CONFIG SETENV`). **2 args** = `name$`,`value$`; **1 arg** = a single `NAME=VALUE` directive string |
| `VARIABLE$` | name of the variable that failed in the **last I/O statement** (for debugging / `HELP$` topics); not set for field-spec errors 850–890 or for calculated expressions |
| `WBVERSION$` | the running BR version, as a string |
| `WBPLATFORM$` | the platform string; returns `WINDOWS` on a unix/aix/linux client-server run when `CONFIG SHELL DEFAULT CLIENT` is set (so client-side shell/print behavior is used) |
| `SYSERR` / `SYSERR$[(n)]` | the underlying **OS** error number / its description (companion to `ERR`/`BRERR$`); `SYSERR$(n)` describes that code rather than the last — see [90-reference/error-codes](../../../90-reference/error-codes/_index.md) |
| `SHIFT[(n)]` | always returns **`0`** — a legacy **System/23-compatibility** no-op (any argument is accepted and ignored) |
| `MSG$("text")` | display text in the 2nd box of the command console |
| `MSG(action$[,arg\|arg$…])` | twenty-five actions (Windows / Client-Server): `MSG("send",keys$)` types into **this session** — the keys go into BR's own buffer, so they reach no other window and need no focus — with special keys in pipes, e.g. `"|CTRL+|c|CTRL-|"`; `MSG("sleeptime",ms)` sets the delay between them in milliseconds. **`MSG("kb")` was removed in BR 5.0 and raises 0412.** Full action list: [70-commands/information/MSG.md](../../../70-commands/information/MSG.md) |
| `SLEEP(seconds)` | pause; fractional seconds, ms resolution (3.83h+) |
| `SPAWN_RESTRICTED(command$[,config$[,wait]])` | **BR 5.0.** Start a disposable **restricted** session on this WSID — the next free session number — running `command$` as its startup command, typically `PROC <file>`. `config$` defaults to this session's. No `wait` or `0` returns the new process id at once; a `wait` in seconds yields as `SLEEP` does and returns the session's **exit code**. See [SPAWN_RESTRICTED](SPAWN_RESTRICTED.md) for the errors and the ordering that makes the restriction hold |
| `HELP$([*]kw$[,mark])` | enter HELP mode / show a topic (see [windows-cursor §help](../../../20-io-screen/windows-cursor/spec.md#help-facility)). Two arguments at most, the second numeric |
| `PROGRAM$` | full path of the loaded program — handy in shared error routines (see [information](../../../70-commands/information/spec.md#procin-program)) |
| `DEBUG_STR(level,str$)` | write `str$` to the debug log at `level` (4.3+; see [information](../../../70-commands/information/spec.md#debug-str)) |
| `PRINTER_LIST(MAT a$)` | redimensions `a$` to the active Windows printer names (see [information](../../../70-commands/information/spec.md#printer-list)) |
| `NEWPAGE` | a char that form-feeds the printer / clears the screen and **zeroes the line counter** (`LINES`/`KREC`); `PRINT #255: NEWPAGE` no longer emits a trailing CR — avoid it immediately before `TAB(x)` in an *unformatted* `PRINT` |
| `BELL` / `TAB(x)` | sound the tone / tab to column `x` within a `PRINT` list |

<a id="integration-functions"></a>
### External / .NET (PEM) integration
| Function | Returns |
|---|---|
| `GET$("#f,r,c",prop$)` | read a property of the `.NET`/PEM control at field `#f,r,c` (e.g. `GET$("#1,5,10","city")`) — see [controls PEM](../../../20-io-screen/controls/Properties,_Events,_and_Methods_(PEM)_and_.NET_controls.md) |
| `SET$("#f,r,c",assign$)` | set a control property, `"prop=value"` (dotted paths allowed, e.g. `"address.city=…"`) |
| `INVOKE$("#f,r,c",method$,MAT args$)` | invoke a control method (`method$` must be a full entry from `INPUT FIELDS … METHOD_NAMES`) |
| `CALL` | ⚠️ **reserved keyword — no function implementation**: it is in the numeric function name table (`table7k`) but the compiler rejects `CALL(…)` as an expression (no `CALL_FN` handler in `numfunct.cpp`). Not usable as a function |
| `DLL(a$,b$[,arg\|arg$…])` | call a client-side DLL command — **≥2 args, first two strings**; dispatched to the client via `callClientDictCommand` (errors 0321–0327) — see [00-configuration/installation-tooling](../../../00-configuration/installation-tooling/spec.md#dotnet) |

<a id="msgbox"></a>
### Message box (Windows)
| Function | Returns |
|---|---|
| `MSGBOX(prompt$[,title$[,buttons$[,icon$]]])` | the chosen button, also in `CNT` |

`MSGBOX` pops a Windows message box and **returns the chosen
button in `CNT`** (and as the function value). Only `prompt$` is required. `buttons$` ∈
`OK`(default)/`YN`/`OKC`/`YNC`, and the **capitalized** letter is the default (Enter) button (`Yn`→Yes,
`yN`→No); `icon$` ∈ `INF`/`ERR`/`EXCL`/`QST`. Return values: `0` error (rare), `1` OK, `2` Yes, `3` No,
`4` Cancel/Esc. Force a line break in the text with `CHR$(13)` or `HEX$("0D0A")` (two in a row = a blank
line).
```business-rules
00060 IF MSGBOX('Are the labels aligned?','Check Printer','Yn','Qst')><2 THEN GOTO ALIGN
```

<a id="encryption"></a>
### Encryption (4.30+) — deep reference in [Encryption](Encryption.md)
| Function | Notes |
|---|---|
| `ENCRYPT$(data$[,key$[,type$[,iv$]]])` | types AES/BLOWFISH/DES/3DES/RC4/RC2; default `AES:256:CBC:128` |
| `DECRYPT$(data$[,key$[,type$[,iv$]]])` | inverse of `ENCRYPT$` |
| `ENCRYPT$(data$,"","MD5"\|"SHA"\|"SHA-1")` | one-way hashes |

<a id="examples"></a>
## Examples

```business-rules
00470 LET LASTNAME$(N) = UPRC$(ANSWERS$(2))    ! normalize for sorting
00100 PRINT LEN("John")                        ! 4 (actual length)
00200 PRINT POS("AaEeIiOoUu", X$)              ! >0 if X$ is a vowel
00300 LET S$ = CNVRT$("NZ 5.2", AMOUNT)        ! number → formatted string

00520 READ MAT CUST$ : MAT ORDER = AIDX(CUST$) ! ascending index
00540 FOR I=1 TO 5 : PRINT CUST$(ORDER(I)) : NEXT I   ! print sorted
00030 READ MAT A EOF 40 : MAT A(CNT)           ! resize to items actually read
00050 STR2MAT(CSV_LINE$, MAT FIELDS$, ",", "Q:TRIM")  ! parse a CSV line

00900 LET FMT$ = CFORM$("FORM C 10, V 20, BH 3")  ! compile once, reuse in a loop
01010 FOR X=1 TO 100 : READ #1,USING FMT$: MAT V : NEXT X

00100 ! CODE is a PROGRAM's return code, not a procedure's.  A program that
00110 ! copes with an error but did not do what it was asked says so with
00120 ! STOP n; whoever runs it next reads CODE before loading anything else,
00130 ! because LOAD, CHAIN and CLEAR all clear it.
00140    OPEN #1: "NAME=MASTER,SHR",INTERNAL,OUTIN,KEYED IOERR 00160
00150    GOTO 00170
00160    STOP 1                                 ! handled, but nothing was done
00170 LET K$ = KSTAT$(1)                        ! idle until one key pressed
```

<a id="see-also"></a>
## See also

- [expressions](../expressions/spec.md) — using functions within expressions
- [assignment](../assignment/spec.md#mat) — `AIDX`/`DIDX`/`STR2MAT` with `MAT`
- [declaration](../declaration/spec.md) — `UDIM`/`LEN` for array & string sizes
- [30-io-file/statements](../../../30-io-file/statements/spec.md#io) — `FILE`/`FREESP`/`EXISTS`/`KPS`/`LREC`/`REC` in I/O context
- [20-io-screen/windows-cursor](../../../20-io-screen/windows-cursor/spec.md) — `KSTAT$`/`NXTFLD`/`NXTROW`/`CURTAB` cursor & keyboard
- [00-configuration/environment](../../../00-configuration/environment/spec.md#env-read) — `ENV$`/`LOGIN_NAME$`/`WSID$`
- [70-commands/program-management](../../../70-commands/program-management/spec.md) — `CODE`/`PROCIN` and procedures
- [30-io-file/form-spec](../../../30-io-file/form-spec/spec.md#syntax) — the format codes used by `CNVRT$`/`CFORM$`
- Backing keyword pages (deep detail retained): [ENV$](ENV$.md), [Encryption](Encryption.md),
  [DATE$](DATE$.md), [DAYS](DAYS.md), [DATE](DATE_\(Internal_Function\).md), [NXTFLD](NXTFLD.md),
  [CFORM$](CFORM$.md)

*(6 redirect-collision pages re-fetched in 2b — `BR_FileName$`, `BRErr$`, `CoS`, `MsgBox`, `NewPage`,
`Rem (internal function)` — were folded into this spec and pruned; verbatim wikitext remains on the BR wiki.)*
