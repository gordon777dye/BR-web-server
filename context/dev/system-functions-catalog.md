# System (built-in) function catalog

Signatures for BR's **intrinsic / system functions** — the functions baked into the runtime
(`table6k` strings + `table7k` numeric/system), as opposed to user `DEF FN…` functions or
`DEF LIBRARY` functions. This file is **system functions only, by themselves**. User-defined and
library (`DEF LIBRARY`) functions are **application-specific** — their signatures are indexed from
the target application's *own* source on demand, not cataloged here. (Functions appearing in the
decompiled corpus are arbitrary and confidential; the corpus is an example/education and
parser-validation source only, **never** a usable API — so corpus UDFs are not cataloged.)

**Authoritative name set:** `table6k` ∪ `table7k`, lifted verbatim from the BR runtime function
tables — every runtime built-in is listed below, so this file is the complete roster.
**Signatures/semantics** are folded from the `br_tree/` reference, primarily
[`system-functions/spec.md`](../br_tree/10-language/data-manipulation/system-functions/spec.md), plus
`windows-cursor`, `controls`, `keys-indexes`, and the printing leaves. The **roster** below is
verified against the BR interpreter source (the `table6k`/`table7k` name tables) and every entry's
usability against the `numfunct.cpp`/`strfunct.cpp`/`trig.cpp` implementations.

> **The arities are not all verified, and this file said they were.** An earlier version claimed
> every signature had been checked against the `ck_num_sysfn`/`ck_alph_sysfn` arity checkers. Eight
> had not, and were found in 2026-08 by running brls's parser over a real application, which used
> forms this file called impossible: `LPAD$`/`RPAD$` with a pad character, `SREP$` with a start
> position, `DATE`/`DATE$` with none or one argument, and `CMDKEY`, `FKEY`, `RND` and `MENU` with
> the one numeric argument this file's own *prose* documents while its signature column omitted it.
> Those eight are corrected. **The mechanical check now exists** (2026-10-13): brls reads the
> signatures from the br_tree spec, runs both checkers over every argument count and type against
> them, and fails its build if **this file's** names or argument counts disagree with the spec. The
> spec is the authority; argument *types* — including positions BR accepts either way — are written
> only there, in its signature notation. See `lsp/brls/LSP_PLAN.md`, phase 16.

Entries marked **✗** are keywords in the runtime tables that are **not usable**:
either reserved-but-unimplemented (`TRUNC`, `DEG`, `RAD` — parse but error at runtime) or compiler-rejected
(`CALL` — no function form). No `†` (unverified-signature) entries remain.

## Notation

```
NAME(arg1, arg2, [opt], rep…)
```

- **Parameters follow BR's own convention — no type tags, no colons.** A `$` suffix marks a string
  argument, no suffix marks a numeric one, and `MAT name` is an array argument. Parameters are
  **comma-separated** (including the first two when there are two or more); a single argument takes no
  separator at all.
- **Return type** is the Returns column — `str` / `num` / `mat num` / `mat str`. A name ending `$`
  always returns `str`, otherwise `num` (BR's hard rule — fixes every return type here, even `✗`
  entries). **The rule has no exceptions.** `BELL` and `NEWPAGE` look like counterexamples and are
  not: they yield no expression value at all — neither `LET X$ = BELL` nor `LET X = BELL` compiles
  — so the rule never applies to them. They are print-list items; see usage note 5.
- `[x]` optional · `x…` one-or-more (variadic) · `(out)` a `MAT` the function **fills** (must be a
  declared array lvalue) · **`MAT name`** an array argument, where the `MAT` keyword is **optional**
  (see note 3) · **`array-name`** an array argument where `MAT` is **not allowed** (only
  `AIDX`/`DIDX`).
- **atom** = usable with **no parentheses** (a bare value); see the table below.
- **assignable** = a pseudo-variable that also accepts assignment, e.g. `LET FKEY(x)`.

## Usage notes (read before using)

1. **Functions are never abbreviated.** Unlike statement keywords, `table6k`/`table7k` require the
   **full** spelling — always written out in full.
2. **No-paren atoms** (below) are bare **values**, not `name(` calls. A **parameterless** function
   (built-in *or* user `FN…`) is called with **no** parentheses — `FNGET$`, never `FNGET$()`.
   What tells `X(3)` (an array element) apart from `SIN(3)` (a function call) is **arity, not
   declaration**: `X` requires no arguments, so it resolves to a name that `(3)` subscripts;
   `SIN` requires one, so `SIN(3)` is a call. Do **not** reason from "is it `DIM`'d?" — declaring
   a name does not shadow an intrinsic. Full rule and worked counterexamples:
   [10-language/syntax — name resolution](../br_tree/10-language/syntax/spec.md#name-resolution).
3. **The `MAT` qualifier is optional.** Wherever an argument must be an array, BR accepts either
   `MAT name` or a bare `name`, reading the bare name as an array name — `UDIM(MAT Y)` and
   `UDIM(Y)` both compile. Signatures below are written `MAT name` for clarity about what the
   argument *is*, not because the keyword is required.
   **`AIDX`/`DIDX` are the sole exception: they reject it** — `MAT X = AIDX(Y)` compiles,
   `MAT X = AIDX(MAT Y)` does not. Their argument is shown as `array-name`. See note 6.
4. **Assignable pseudo-variables** appear on the LHS: `CMDKEY`, `FKEY`, `CURFLD`, `CURTAB`,
   `CURWINDOW`, `PIC$`. `LET name(args)` is valid for these.
5. **`BELL`, `NEWPAGE` and `TAB(x)` are print-list items, not value-returning functions.** All
   three are `<print-options>` — valid **only inside a `PRINT` list** and yielding no expression
   value: neither `LET X$ = BELL` nor `LET X = BELL` compiles. They are documented with the print
   statements ([40-io-printing/statements](../br_tree/40-io-printing/statements/spec.md#options)).

   They differ in one respect only, and it is a naming matter, not a usage one: **`BELL` and
   `NEWPAGE` are reserved** (declared in `table7k`), so no variable may take those spellings, while
   **`TAB` is in neither runtime table** and is therefore not reserved. `BELL`/`NEWPAGE` are listed
   below because they are reserved names a reader will look up; `TAB` is deliberately absent.
   (`NEWPAGE` also works as a print *target*.)
6. **`AIDX`/`DIDX` are functions only as a `MAT` primary** — the right-hand side of a `MAT`
   assignment, `MAT ORDER = AIDX(CUST$)`. They are not system functions anywhere else, so they are
   not callable in an ordinary expression. Their home production is `<mat-rhs>` in
   [assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#syntax).

## Functions BR does **not** have (read this first)

This catalog is the complete roster, so **any name not in it does not exist** — but a positive list
is easy to read past. The names below are the ones most often reached for by habit, from other
BASICs or from C/Python/JS. None of them is a BR function; each row gives what BR uses instead.
Every entry was checked against the roster.

| Not in BR | Use instead |
|---|---|
| `MID$`, `SUBSTR` | **substring notation** `s$(m:n)` — 1-based, inclusive |
| `LEFT$` | `s$(1:n)` |
| `RIGHT$` | `s$(m:inf)` — `inf` means "end of string" |
| `INDEX`, `INSTR` | `POS(s1$, s2$[, start])` |
| `ASC` | `ORD(s$)` |
| `UCASE$`, `UPPER$` / `LCASE$`, `LOWER$` | `UPRC$(s$)` / `LWRC$(s$)` |
| `LTRIM$` / `RTRIM$` | `LTRM$(s$[,c$])` / `RTRM$(s$[,c$])` |
| `SPACE$`, `STRING$` | `RPT$(s$, n)` |
| `REPLACE$` | `SREP$(src$, find$, repl$)` |
| `FORMAT$` | `CNVRT$(spec$, n)` |
| `STR` | `STR$(n)` |
| `SPLIT` / `JOIN` | `STR2MAT` / `MAT2STR` |
| `SQRT` | `SQR(n)` |
| `ATAN` | `ATN(n)` |
| `LOG10` | `LOG(n)` is the **natural** log; scale it yourself |
| `CINT` / `FIX` | `INT(n)` / `IP(n)` |
| `POWER` | the `^` or `**` operator |
| `RANDOM` | `RND` |
| `UBOUND`, `ARRAYLEN`, `COUNT` | `UDIM(MAT arr[, dim])` |
| `LBOUND` | nothing needed — BR arrays are **1-based** |

Two traps this list does not cover, because they are operators rather than functions: `MOD` is a
**function only** (`MOD(a, b)`, never `a MOD b`), and `&` is **string concatenation**, not
bitwise-AND. See [essentials](essentials.md#1-core-language-rules).

## No-paren atoms (lex as a value, not `name(`)

**An atom is a name that may be written bare.** That is all this table asserts. It is *not* the
claim that no argument is accepted — an earlier version was headed "Never take arguments", and six
of its entries did take one.

Two things to read off the rows:

- Some atoms also accept an argument, shown in the row: `LOGIN_NAME$[(name$)]` sets the name,
  `SYSERR$[(n)]` describes a given OS code. They are still atoms, because bare is legal.
- Four (‡) are accepted with one argument by BR's *compiler* and ignore it at run time — see the
  note under the table. Writing one is legal, silent, and does nothing.


| Atom | Returns | Meaning |
|---|---|---|
| `ERR` | num | last error number |
| `LINE` | num | current line number |
| `CNT` | num | items processed by the last I/O |
| `CODE` | num | the return code the last **program** set, with `STOP n`/`END n`; cleared by `LOAD`, `CHAIN` and `CLEAR`. There is no `EXIT n` — see the CODE correction in [system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md) |
| `PROCIN` ‡ | num | non-zero while a procedure feeds input |
| `FILENUM` | num | file number of the most recent I/O error |
| `PI` | num | 3.14159265358979 |
| `INF` | num | largest representable number (`1.0E+307`) |
| `WSID$` | str | this session's workstation ID (string only — there is **no** numeric `WSID`; the curated spec's `WSID` is a typo for `WSID$`) |
| `USERID$` | str | BR licensee name |
| `LOGIN_NAME$[(name$)]` | str | current user's OS login name. **With an argument it *sets* the name** (`strfunct.cpp`: "Setting LOGIN_NAME$ changes the name only") — a setter in function form, not an atom |
| `PROGRAM$` | str | current program name (ref home: 70-commands/information) |
| `TIME$` ‡ | str | current time `hh:mm:ss` |
| `NXTFLD` | num | relative position of the next control to be occupied — **takes no arguments, and is not assignable**. `ck_num_sysfn` groups it with `NXTROW`/`NXTCOL`/`CURPOS`/`TIMER` under `// 0 parameters` … `if (subcount) return -1`, and there is no second path: `command3.cpp` sends both the bare form (line 524) and any parenthesised form (line 653) to that same checker, and its one escape (`NOT_FN_REF`) is guarded by `EXTENDED_USER_FUNCTION`, so it is reachable only by `FN…` names. At run time `numfunct.cpp` reads `fieldsdata.tnxtFld` without popping an argument. `LET NXTFLD(…)` does not compile; to set the next input field use `CURFLD` |
| `NXTROW` / `NXTCOL` | num | row / col of the next cursor position |
| `CURROW` ‡ / `CURCOL` ‡ | num | current/ending cursor row / column |
| `CURPOS` | num | cursor position within the field data |
| `SERIAL` | num | serial number of this BR copy |
| `SESSION$` | str | session id (`WSID` + session digit) |
| `PROCLVL` | num | procedure nesting level |
| `TIMER` | num | seconds since the Unix epoch (5-decimal) |
| `VARIABLE$` | str | variable that failed in the last I/O |
| `WBVERSION$` / `WBPLATFORM$` | str | running BR version / platform |
| `SYSERR` / `SYSERR$[(n)]` | num / str | OS error number / description. Both may be written bare; `SYSERR$(n)` describes that code rather than the last |

‡ **Accepted with one argument, and ignored.** BR's arity checkers let these take a single
argument — `ck_num_sysfn` groups `CURROW`/`CURCOL`/`PROCIN` under "optional 1 numeric" and
`ck_alph_sysfn` groups `TIME$` with `LOGIN_NAME$` under "0-1 parameters, optional string" — while
the implementations never read it. `strfunct.cpp`'s `TIME_` arm is commented *"return system time,
no parms"*; `numfunct.cpp`'s `CURROW`/`CURCOL` return the field data and return; `PROCIN` is
commented *"optional parameter 0 or non-zero to set"* and then does not set anything. So
`PRINT TIME$("hh:mm")` compiles, runs, and prints the ordinary time — the same failure mode as
`%`, `<<` and `>>`, where the compiler agrees and the runtime has nothing to do. Documented here
rather than as an optional parameter, because calling it a parameter would be the more damaging
error.

Optionally bare (also have a parenthesized form): `DATE$`, `DATE`, `KSTAT$`,
`CMDKEY`, `FKEY`, `CURFLD`, `CURTAB`, `CURWINDOW`, `MENU`, `MENU$`, `BRERR$`, `SYSERR$`,
`LOGIN_NAME$`, `RND` (bare = next value; `LET RND(seed)`
seeds). `DATE` was missing here: `ck_num_sysfn` gives `DATE_FN` 0–2 parameters, both
optional, and `LET TODAY = DATE` is written 1,216 times in one application corpus.

<!-- corrected: `NEXT` was listed here as "next position within a 2-D control (INPUT FIELDS NEXT
clause)". It is not a function or an atom of any kind. Every other atom above resolves in
table6k or table7k; NEXT is in neither, and unlike ABS/INT/SGN (command3.cpp, gated on a following
`(`) and AIDX/DIDX (command5.cpp, MAT path) it has no resolution path in the expression parser at
all. It is a *keyword*: table3k as the FOR/NEXT loop terminator, table4k as the record-positioning
clause on DELETE/READ/RESTORE/REWRITE, beside FIRST/LAST/PRIOR/SAME (synbc.cpp). Both readings are
already carried by the keyword pack. The "2-D control" gloss was wrong as well as the placement. -->


## String & character

| Function | Returns | Description |
|---|---|---|
| `CHR$(n)` | str | character for ASCII code `n` |
| `ORD(s$)` | num | ASCII code (0–255) of the first char of `s$` (inverse of `CHR$`); BR has **no** `ASC` — use `ORD` |
| `UPRC$(s$)` / `LWRC$(s$)` | str | upper / lower case |
| `TRIM$(s$, [c$])` | str | strip leading **and** trailing spaces (or the 1-char `c$`) — the same optional argument `LTRM$`/`RTRM$` carry, and `strfunct.cpp` reads it from the same line for all three |
| `LTRM$(s$, [c$])` / `RTRM$(s$, [c$])` | str | strip leading / trailing spaces (or the 1-char `c$`) |
| `LPAD$(s$, n, [pad$])` / `RPAD$(s$, n, [pad$])` | str | pad to length `n` on the left / right, with `pad$` (default space) |
| `RPT$(s$, n)` | str | `s$` repeated `n` times |
| `LEN(s$)` | num | **actual** current length (not the `DIM` max) |
| `POS(s1$, s2$, [start])` | num | position of `s2$` in `s1$`, 0 if none (`^`-prefix on `s2$` = case-insensitive; negative `start` = search backward) |
| `SREP$(src$, [start], find$, repl$)` | str | string search-and-replace, optionally from `start` |
| `XLATE$(s$, table$, [start])` | str | translate `s$` through a 256-byte table (input char value `n` → the `(n+1)`-th char of `table$`; longer values pass through; `STR2UTF`/`UTF2STR` tables do UTF-8) |

## Type conversion & formatting

| Function | Returns | Description |
|---|---|---|
| `STR$(n)` | str | number → plain string |
| `VAL(s$)` | num | string → number |
| `CNVRT$(spec$, n)` | str | number → string per a FORM code (`B BH BL D G GZ L N NZ PD PIC S ZD`) |
| `CFORM$(form$)` | str | compile a FORM string into a fast (opaque, release-dependent) format value |
| `HEX$(s$)` / `UNHEX$(s$)` | str | chars → hex notation / hex → chars |
| `PIC$` | str | current currency symbol (atom) |
| `PIC$(sym$)` | str | set the currency symbol to 1-char `sym$` (assignable; persists per workstation) |

## Numeric & math

| Function | Returns | Description |
|---|---|---|
| `INT(n)` | num | integer part (truncates) |
| `IP(n)` / `FP(n)` | num | integer / fractional part (sign preserved) |
| `CEIL(n)` | num | smallest integer ≥ `n` |
| `TRUNC(n)` ✗ | num | **reserved but not implemented** — parses (1 numeric arg) but errors at runtime (`trig()` has no case); no `[,d]` form. Use `INT`/`IP` |
| `ROUND(n, d)` | num | round to `d` decimals |
| `ABS(n)` | num | absolute value (intrinsic — resolved outside `table6k/7k`) |
| `SGN(n)` | num | sign: `-1` / `0` / `1` (a near-zero value can round to `0` per the `RD` config) |
| `SQR(n)` | num | square root |
| `MOD(a, b)` / `REM(a, b)` | num | remainder (`REM` is an alias of `MOD`); **function only — no infix `a MOD b`** |
| `MAX(n, n…)` / `MIN(n, n…)` | num | largest / smallest of a numeric list — **two or more** arguments |
| `MAX$(s$, s$…)` / `MIN$(s$, s$…)` | str | largest / smallest string (ASCII order) — **two or more** arguments |
| `SIN(n)` `COS(n)` `TAN(n)` `ATN(n)` | num | trig / arctangent (radians) |
| `LOG(n)` / `EXP(n)` | num | natural log / e^n |
| `DEG(n)` ✗ / `RAD(n)` ✗ | num | **reserved but not implemented** — recognized keywords that error at runtime (`trig()` has no case); no conversion exists in the current source |
| `RND[(seed)]` | num | pseudo-random `0`–`1` (seed with `RANDOMIZE`, or `LET RND(seed)` for a repeatable sequence) |
| `SHIFT[(n)]` | num | always returns `0` — a legacy System/23-compatibility no-op (argument ignored) |

## Date / time

| Function | Returns | Description |
|---|---|---|
| `DATE$` | str | current date `yy/mm/dd` (atom) |
| `DATE$([days], [mask$])` | str | format a day-count to a string (time masks 4.30+); either argument may be omitted |
| `DATE[(days, mask$)]` | num | numeric date sibling of `DATE$` (stores the days value, for sorting); bare, or with either argument |
| `DAYS(date, [mask$])` | num | day-count; Y2K-aware (dates from 1700, 3.90+) |
| `SQL_DATE$(d, [fmt$])` / `BR_DATE$(s$, [fmt$])` | str | pack / unpack SQL dates (4.30+); the format is optional |

## Array-processing (used with `MAT`)

| Function | Returns | Description |
|---|---|---|
| `UDIM(MAT arr, [dim])` | num | current size of an array (or of dimension `dim`) |
| `SUM(MAT arr)` | num | sum of all elements |
| `SRCH(MAT arr, arg, [start])` | num | row of a match (0/-1 if none; `^`-prefix = case-insensitive) |
| `AIDX(array-name)` / `DIDX(array-name)` | mat num | ascending / descending **index** array (source unchanged). Only as a `MAT =` right-hand side, and the argument takes **no `MAT` keyword**: `MAT X = AIDX(Y)` compiles, `MAT X = AIDX(MAT Y)` does not |
| `STR2MAT(s$, MAT a$ (out), [[MAT]sep$], [flags$])` | num | split string → array (dynamically redims `a$`); returns the count. `sep$` is a user delimiter (default = any `\n`/`\r` run; `""` = per-char); `flags$` = quote type `Q`/`'`/`"` [ `:` `TRIM`/`LTRM`/`RTRM` ] | `TRIM`/`LTRM`/`RTRM`
| `MAT2STR(MAT a$, s$ (out), [[MAT]sep$], [flags$])` | num | join array → string; returns the count. `sep$` default = `CRLF`/`CR`, placed after every element incl. the last; `""` concatenates |

## File / drive query

| Function | Returns | Description |
|---|---|---|
| `FILE$([n], [keyword$])` | str | open file's name; no arg = file of the most recent I/O error. **A second, keyword argument queries the open file** — `"HTTPINFO"`, `"PAGE-URL"` and others dispatched in `strfunct.cpp`'s `FILE_` arm — and is not otherwise documented in this kit |
| `FILE(n)` | num | status: `-1` not open, `0` ok, `10/11` EOF, `20/21` transmission error |
| `FILE(n, kind$, [MAT a (out)])` | num | `"WINDOW_RECT"`/`"USABLE_RECT"` (x,y,w,h px) or `"FONTSIZE"` (cell) |
| `FREESP(n)` | num | free bytes on the drive holding file `n` |
| `EXISTS(file$)` | num | nonzero if file/PROC exists (`1`=directory, `>1`=file) — test zero/nonzero only |
| `BR_FILENAME$(os$)` / `OS_FILENAME$(br$)` | str | convert OS path ↔ BR filename (4.18+) |
| `KPS(n, [seg])` | num | key start position (`seg` = split-key section; `-1` if none) |
| `KLN(n, [seg])` | num | key length (split-key aware) |
| `KREC(n)` | num | last record in the **index/key** file (not the master) |
| `REC(n)` / `LREC(n)` | num | current / last record number |
| `RLN(n, [newlen])` | num | record length of file `n`; `newlen` resets it (EXTERNAL only, ≤ OPEN `RECL=`) |
| `VERSION(n, [ver])` | num | marked version number of INTERNAL file `n` (**not** the BR release); `ver` sets it when open `OUTPUT` |
| `LINES(n)` | num | lines printed since the last new-page |
| `LINESPP(n)` | num | current lines per page (PRINTER `LPP`, else 66) |
| `LINESTATUS$(n)` | str | serial-line/modem status of channel `n` — see 30-io-file/serial-comm |
| `PRINTER_LIST(MAT a$ (out))` | num | redim `a$` to the active Windows printer names |

## Screen & keyboard (cursor, input results)

| Function | Returns | Description |
|---|---|---|
| `KSTAT$([n], [secs])` | str | unprocessed keystrokes; with `n`, wait for `n` keys (BR scancodes — `UNHEX$` to read) |
| `NXTFLD` | num | relative position of the next control to be occupied — **no arguments, not assignable**; an atom, listed with the evidence in the **No-paren atoms** table above. Pairs with `FKEY` to identify a clicked hot control. To *set* the next input field use `CURFLD` below |
| `CURTAB([win], [1])` | num | active tabbed-window number; `CURTAB(win,1)` raises it (assignable) |
| `CURPOS` | num | cursor position **within the field data** when control returns (4.20+; excludes untyped trailing spaces, counts invisible CRLF) — atom |
| `CURFLD([field], [attr$], [fkey])` | num | 1-based field after the last `INPUT FIELDS`; with args **sets** the next input's start field/attrs (assignable) |
| `CURWINDOW[(n)]` | num | focused `PARENT=NONE` window (`-1` if none); `n` raises it (assignable). The argument is **optional** |
| `CMDKEY[(n)]` | num | key that terminated input (`0`=Enter; `-1` before first input). `LET CMDKEY(x)` presets (assignable, atom) |
| `FKEY[(n)]` | num | richer successor to `CMDKEY` (preferred); set by controls/buttons/hot windows. `LET FKEY(x)` (assignable, atom; `FNKEY`=`FKEY` as of 4.20) |
| `MENU[(n)]` | num | subscript of the selected native-menu item |
| `MENU$[(n)]` | str | data string of the selected native-menu item; with `n`, of the *n*-th item |
| `SCR_FREEZE` / `SCR_THAW` | num | **(no args)** suspend / resume **remote (client-server) display** repaint (`freezeRemoteDisplay`/`thawRemoteDisplay`); return `0` |

## System / information

| Function | Returns | Description |
|---|---|---|
| `BRERR$([code])` | str | the *description* of a BR error code (what `ERR` is to the number; 4.3+). **Bare** describes the last error (`t.curpcb->lastError`) |
| `SYSERR` | num | system (OS) error number — home: 90-reference/error-codes |
| `SYSERR$[(n)]` | str | system error description; with `n`, of that OS error code rather than the last — home: 90-reference/error-codes |
| `ENV$(status$, [MAT cfg$ (out)], [arg])` | str | environment / status interrogation (4.30+) |
| `SETENV(name$, [value$])` | num | set a BR **session** environment variable (function form of `CONFIG SETENV`; read back with `ENV$`). 2 args = `name$`,`value$`; 1 arg = a `NAME=VALUE` directive |
| `MSG$(text$)` | str | display text in the 2nd box of the command console |
| `MSG(action$, [arg…])` | num | session control, Windows/CS (**not** a companion of `MSG$`): `MSG("send",keys$)` types into this session through BR's own buffer, `MSG("sleeptime",ms)` sets the delay between keys in milliseconds; `MSG("kb")` was removed in 5.0 (0412). The compiler takes one or more arguments, the first a string — home: 70-commands/information/MSG.md |
| `SLEEP(seconds)` | num | pause (fractional seconds, ms resolution) |
| `SPAWN_RESTRICTED(command$, [config$], [wait])` | num | **BR 5.0.** start a disposable **restricted** session on this WSID running `command$`; returns its process id, or with `wait` (seconds) its exit code. Errors 4154–4157 — home: system-functions/SPAWN_RESTRICTED.md |
| `HELP$([*]kw$, [mark])` | str | enter HELP mode / show a topic; returns a scancode or selection. **Two arguments at most**, and the second is *numeric* — `ck_alph_sysfn` gives `BETWEEN(1, 2, subcount)` with `PARMCHECK_NUMERIC` on it, so the `file$` this row used to list is not a parameter |
| `MSGBOX(prompt$, [title$], [buttons$], [icon$])` | num | Windows message box; returns the chosen button (also in `CNT`): 1 OK · 2 Yes · 3 No · 4 Cancel |
| `DEBUG_STR(level, str$)` | num | emit `str$` to the debug log (4.3+) |
| `PROCLVL` | num | current procedure nesting level (`0` = keyboard / not in a procedure) — atom |
| `TIMER` | num | seconds since the Unix epoch (1970-01-01 UTC) as a 5-decimal real — atom |
| `SERIAL` | num | serial number of this BR software copy — atom |
| `SESSION$` | str | this session's ID — `WSID` + a 1-digit session number `1`–`9` (e.g. `011`) — atom |
| `VARIABLE$` | str | name of the variable that failed in the **last I/O statement** (not for field-spec errors 850–890 or calculated expressions) — atom |
| `WBVERSION$` / `WBPLATFORM$` | str | running BR version / platform string (`WBPLATFORM$` = `WINDOWS` on unix CS under `CONFIG SHELL DEFAULT CLIENT`) — atoms |
| `NEWPAGE` | — | starts a new page on **any** channel — clears a screen or window, form-feeds a printer or display file, zeroes that channel's line counter. **`PRINT` list only** — no expression value (see note 5); also usable as a print *target* |
| `BELL` | — | sounds the tone. **`PRINT` list only** — no expression value (see note 5) |

### Integration / native (name-level — verify against the cited leaf)

Signatures below are source-verified against `strfunct.cpp`/`numfunct.cpp` (`GET$`/`SET$` → 2 strings,
`INVOKE$` → 3, `DLL` → ≥2 strings, all dispatched client-side). `CALL` is the lone `✗`: it is in
`table7k` but has **no function implementation** (compiler-rejected).

| Function | Returns | Role |
|---|---|---|
| `GET$("#f,r,c", prop$)` | str | read a `.NET`/PEM control property (remote `PEM_PROPERTY_CALL`) |
| `SET$("#f,r,c", assign$)` | str | set a control property, `"prop=value"` (dotted paths allowed) |
| `INVOKE$("#f,r,c", method$, MAT args$)` | str | invoke a control method (`method$` from `INPUT FIELDS … METHOD_NAMES`); results written back into the args array |
| `DLL(a$, b$, [arg…])` | num | call a client-side DLL command (≥2 args, first two strings; errors 0321–0327) |
| `CALL` ✗ | num | **reserved keyword, no implementation** — in `table7k` but rejected as a function expression |

> **OS shell access — `SYSTEM` (a command, not a function).** Not in `table6k`/`table7k`, so it has no
> entry above, but it is a program's primary way to reach the operating system, so it's noted here for
> findability. A program runs it via `EXECUTE`: `EXECUTE "SYSTEM '<os-command>'"` launches another
> application / runs a shell command (flags: `-C` async, `-R` restore screen, `-@`/`-S` client/server
> side, `-M`/`-m` hide/minimize); `SYSTEM [<n>]` exits BR to the OS with exit code `<n>`; `SYSTEM LOGOFF`
> logs the client off. Runs arbitrary OS commands with the caller's privileges — security-sensitive.
> Full description: [70-commands/program-management §SYSTEM](../br_tree/70-commands/program-management/spec.md#system).

## Encryption (4.30+) — deep reference: `system-functions/Encryption.md`

| Function | Returns | Description |
|---|---|---|
| `ENCRYPT$(data$, [key$], [type$], [iv$])` | str | encrypt; types AES/BLOWFISH/DES/3DES/RC4/RC2 (default `AES:256:CBC:128`) |
| `DECRYPT$(data$, [key$], [type$], [iv$])` | str | inverse of `ENCRYPT$` |
| `ENCRYPT$(data$, "", "MD5"\|"SHA"\|"SHA-1")` | str | one-way hash |

---

**✗ not usable:** the name is a live keyword in `table6k`/`table7k` (so it lexes and, for the numeric
ones, may compile) but it has **no working implementation** — `TRUNC`/`DEG`/`RAD` reach `trig()`'s
`default` and return a bad-function error at runtime; `CALL` is rejected by `ck_num_sysfn`. Do not emit
completions for these as callable functions. (Signatures for every other entry are source-verified; the
former `†` "unverified" tier is retired.)
