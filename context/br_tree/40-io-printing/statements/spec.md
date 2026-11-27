---
title: Printing statements
file: spec.md
source: §Printing Operations (PRINT, USING/FORM, PIC, positioning, print files)
category: 40-io-printing
subcategory: 40-io-printing/statements
kind: spec
status: 2b           # reference base + br_tree enrichment (PAGEOFLOW); misfiled command/config pages relocated; no conflicts
recovered-fold: 'PRINT_USING, PRN, REMOTE_PRINTING (3 redirect-collision pages folded from re-fetched source — RUN >/>>/>CON: redirect, string-FORM recompile, PRN:/10 pass-through, DIRECT:/ vs SPOOLCMD, PRINTER_LIST(), CS OPTION 30/@ routing; verbatim retained on the BR wiki)'
related: [pcl-pdf, sort]
keywords: [PRINT, OPEN, PAGEOFLOW, NEWPAGE, BELL, TAB, HEADING, USING, PIC, COPIES, PRINTER_LIST, "WAIT="]
corrections:
  - "2026-11-23, from BR 5.03's source (primop1.cpp: PRINT_PRI calls print() without the statement's wait) and run headless: WAIT= added to both PRINT forms, where BR's syntax tree puts it, as accepted with no effect. `PRINT #3, WAIT=1: \"printed\"` ran clean and wrote the line. Also the formatted form's separator: it read `['#'<file-num> ':'] USING`, and the channel is followed by a comma there (`PRINT #255, USING 100: X`), as the tree has it and as QSMRP writes it 4,672 times, with 0 colons. WAIT= added to the keywords."
  - "PRINTER_LIST added to the frontmatter keywords. `PRINTER_LIST(MAT a$)` is documented on this
    page (populates an array with local printer names/ports) and was routing nowhere. Found
    2026-09-11 auditing `go run ./cmd/gendata`'s unrouted-function list against actual br_tree
    content."
  - "The `PRINT ... | > file` section (console output to a file or string array, BR 5.0) moved here
    from 70-commands/program-management/spec.md, where a pointer stays under the same anchor
    (`print-redirect`). Text unchanged apart from the SOFLOW rule for arrays: they now grow under
    EXECUTE too (2026-11-21), `ON SOFLOW IGNORE` being the only way to cut a line."
---

# Printing statements

<a id="print"></a>`PRINT` (and `PRINT USING`) for screen/printer/display output, formatting with `FORM`/`PIC`,
cursor positioning, page control, and opening printer files. On-screen `PRINT FIELDS` is in
[20-io-screen/input-output](../../20-io-screen/input-output/spec.md); the record-layout `FORM`
codes are canonically in [30-io-file/form-spec](../../30-io-file/form-spec/spec.md); printer
*configuration* (spooling, PRINTER.SYS) is in
[00-configuration](../../00-configuration/config-directives/spec.md).

**File #253 is where a plain `PRINT` goes when it is open.** A `PRINT` with no file number and no `FIELDS` (the
console `PRINT` of a program or the command line) writes to channel 253 if the program has opened it
(`OPEN #253: ...`), and to the screen otherwise. In an **unattended** session this is how a program captures what
would have been printed on the console. `PRINT #253:` itself is refused (error for a bad file use): the channel is
only opened, not printed to by number. (`#254` is the alternate printer and `#255` the main printer.)
Printing `NEWPAGE` to `#255` resets the `PAGEOFLOW` counter and the `KREC(255)` function to zero.

<a id="syntax"></a>
## Syntax

```bnf
-- unformatted --
PRINT ['#'<file-num> [',' 'WAIT=' <numeric-expr>] ':'] [<print-options>] [<print-list>]
<print-options> ::= BELL | NEWPAGE | TAB(<column>)
<print-list>    ::= <expression> [ { ';' | ',' } <expression> ]*

-- formatted --
PRINT ['#'<file-num> ','] USING { <form-ref> | <string-expr> } [',' 'WAIT=' <numeric-expr>] ':' <expression-list>
-- WAIT= is accepted on both and has no effect: PRINT does not read it
<form-ref> ::= FORM <format-spec> [',' <format-spec>]*
<format-spec> ::= POS <column> | X <spaces> | SKIP <lines>            -- cursor
               | C <length> | N <length>[.<dec>] | PIC(<picture>)     -- conversion

OPEN '#255' ':' '"' NAME=<printer-spec> [',' RECL=<n>] [',' EOL=<eol>] [',' COPIES=<n>] [',' CONV=<char>] '"' ',' DISPLAY ',' OUTPUT
<eol> ::= { CR | CRLF | NONE }
```

<a id="semantics"></a>
## Semantics

<a id="destinations"></a>**Destinations**: `#0` screen (default), a window channel, `#255` printer
(implicit open on first use), or any opened display channel.

<a id="options"></a>**Options** (each followed by `;`): <a id="bell"></a><a id="newpage"></a>`BELL` sounds the bell, `NEWPAGE` starts a
new page on whatever the channel is — clearing a screen or window, form-feeding a printer or
display file, and zeroing that channel's line counter (use as the first output of a screen section
or report page) — and `TAB(col)` moves to a column (wraps to next line if already past it).

**Any `PRINT` may carry these, on any channel.** The channel does not restrict which options are
available; it only determines what each one does.

These are **print-list items, not expressions** — they yield no value and cannot appear outside a
`PRINT` list: neither `LET X$ = BELL` nor `LET X = BELL` compiles. `BELL` and `NEWPAGE` are
nonetheless **reserved** names (both declared in
[`table7k`](../../10-language/syntax/table7k.txt)), so no variable may take those spellings;
`TAB` is declared in neither runtime table and is not reserved. See
[10-language/syntax](../../10-language/syntax/spec.md#identifiers).

<a id="separators"></a>**Separators**: `,` tabs to the next **print zone** (screen 1/24/48;
printer 1/24/48/72/96, 24 wide); `;` concatenates with no spacing. Numbers print with automatic
leading/trailing spaces; strings do not.

<a id="using"></a>**PRINT USING / FORM** formats output against a [FORM](../../30-io-file/form-spec/spec.md):
`C n` (left-aligned char), `N n.d` (right-aligned numeric, rounded), `PIC(...)` (picture). A FORM
**repeats** if there are more data items than specs. Field overflow on `N` prints asterisks. The
`USING` target may be a `<line-ref>` or a **string** beginning `"FORM …"` — the string form recompiles
on every execution (slower). Array elements print in **row order**. 

`HEX$(...)` embedded in a PRINT
can send raw printer-mode/attribute bytes (often paired with a `PRINTER.SYS` translation).
**Redirect `#255`** at run time via the `RUN` command: `RUN >file` (create/overwrite), `RUN >>file`
(create/append), `RUN >CON:` (to the screen — saves paper while debugging).

<a id="pic"></a>
### PIC picture symbols
| Symbol | Function | | Symbol | Function |
|---|---|---|---|---|
| `$` | floating dollar + digit | | `Z` | zero-suppress digit |
| `*` | asterisk fill + digit | | `,` | comma insertion |
| `#` | required digit (shows 0) | | `.` | decimal point |
| `-` | floating minus + digit | | `B` | blank insertion |
| `+` | sign (plus/minus) | | `CR`/`DR`/`DB` | shown only when negative |

<a id="positioning"></a>
### Cursor positioning (in FORM)
`POS n` jump to column *n* · `X n` skip *n* spaces · `SKIP n` move to column 1, *n* lines down.
FORM may also contain literal text (`FORM "Customer: ", C 30`).

<a id="pageoflow"></a>
### Page overflow — `PAGEOFLOW`
When lines printed since the last page-feed reach the OPEN display file's **page length** (default
60), the **`PAGEOFLOW`** condition fires — the *only* condition that traps it (`ERROR`/`IOERR` do
not; if neither `PAGEOFLOW` on the statement nor `ON PAGEOFLOW` is set, overflow is ignored). Use it
to print headers/footers and form-feed:
```business-rules
00100 PRINT #255, USING 110: MAT ROW$ PAGEOFLOW 900
00900 HDR: PRINT #255: NEWPAGE : GOSUB HEADING : CONTINUE
```
(The BRConfig.sys `PAGEOFLOW` directive sets the default page length — see
[config-directives](../../00-configuration/config-directives/spec.md).)

<a id="print-files"></a>
### Opening a printer file
`OPEN #255: "NAME=<spec>,RECL=…", DISPLAY, OUTPUT`. Printer destination specs:

| Spec | Behavior |
|---|---|
| `PRN:/DEFAULT` | Windows default printer (uses driver and spooling) |
| `PRN:/SELECT` | Show printer selection dialog at print time |
| `PRN:/10` or `PRN:/<substring>` | Numbered printer or match printer name substring |
| `WIN:/<substring>` | Native Windows Printing API (printer name substring) |
| `PREVIEW:/<substring>` | Print preview instead of sending to printer |
| `DIRECT:/<substring>` | Bypass printer driver; Equivalent to `WIN:/<substring>` with `OPTION 31` set (now preferred over `WIN:/` for direct printing) |

`COPIES=n` prints multiple copies. **`PRINTER_LIST(MAT a$)`** populates array `a$` with local printer names and their port addresses; pass the array's element length as the first dimension, and BR redimensions it to the actual printer count.

In **client-server** mode: output prints on the *client* by default. `OPTION 30` (not available on Windows servers) routes `PRN:/` and `WIN:/` to the *server* instead, while `PRN:@/` and `WIN:@/` print on the *client*. The `SPOOLCMD` setting runs server-side by default unless prefixed with `@` for client-side. See [client-server](../../00-configuration/client-server/spec.md).

<a id="print-redirect"></a>
### `PRINT ... | > file` — console output to a file or array (BR 5.0)

A `PRINT` given at the command line — typed at `READY`, in a procedure, or run by
[`EXECUTE`](../../70-commands/program-management/spec.md#execute) — can send what it would show on the console to a file or a string array:

```bnf
PRINT [<print-list>] | > { <file> | <array$> }     -- create or replace the file; empty the array
PRINT [<print-list>] | >> { <file> | <array$> }    -- add to the end of the file or array
```

```
PRINT MAT CUST$ | > cust.txt
PRINT USING "form pos 3,c 10": NAME$ | >> names.txt
PRINT MAT A | > LINES$
```

- **It is the console output that is redirected.** The lines are exactly what the console would
  have shown, wrapped and zoned at the console's width as they would be there, and nothing goes to
  the screen. `PRINT USING` is redirected the same way. A `PRINT #n:` writes to its file as usual;
  it produces no console output, so its target is created or emptied and receives nothing.
- **`|` comes after the whole print list**, and the target is the last thing on the line (a `!`
  comment may follow it). Blanks between `|`, `>` and the name are optional: `|>out.txt` and
  `| > out.txt` are the same.
- **`<array$>`** is a one-dimensional string array of the program the command is given in, one
  line to an element, as with `LIST > A$` and `DISPLAY ... > A$`. A name ending in `$` is always
  an array: if the program has none by that name it is made, as `A$(1)` would make it, and starts
  empty even with `>>`. A file whose name ends in `$` is written in quotes: `| > "A$"`.
  It is redimensioned to the lines it holds. A line longer than its elements makes them that long,
  at the console and under `EXECUTE` alike; the one exception is an `EXECUTE` run under
  `ON SOFLOW IGNORE`, which cuts the line to the element length. Growing stops at
  `SOFLOW-GROW MAX=`, past which the line is error 58. It is written when the `PRINT` is done, so a `PRINT`
  may print the array it fills: `PRINT MAT A$ | >> A$` adds a copy of `A$` to its end.
- **A line a `PRINT` leaves unfinished** (ending in `;` or `,`) is written without a line end.
- The file is opened before the statement runs and closed when it ends, whether it ends normally
  or with an error. An error opening it stops the statement before anything runs.
- **Only on a command line.** In a numbered program line `|` is not an operator, and the line is a
  syntax error. A single `|` is never an operator (`||` is OR), so nothing else is read
  differently.
- A missing name, or anything other than a comment after it, is error **1006**.

<a id="examples"></a>
## Examples

```business-rules
00100 PRINT NEWPAGE;
00120 FORM C 15, X 5, C 10, X 5, C 12, X 5, C 10
00120 PRINT USING 110: "Product", "Price", "Quantity", "Total"
00200 FORM C 15, X 5, PIC($$,$$$.##), X 5, N 12, X 5, PIC($$,$$$.##)
00210 PRINT USING 200: "Widget A", 25.50, 100, 2550.00

! Print preview to a printer file
00010 OPEN #255: "NAME=PREVIEW:/DEFAULT,RECL=32000", DISPLAY, OUTPUT
00020 PRINT #255: "Hello World!"
00050 CLOSE #255:
```

<a id="see-also"></a>
## See also

- [pcl-pdf](../pcl-pdf/spec.md) — NWP/PCL escape sequences, fonts, color, boxes, images
- [sort](../../70-commands/sort/spec.md) — sorting records for reports (the SORT command)
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — canonical FORM field codes
- [20-io-screen/input-output](../../20-io-screen/input-output/spec.md) — on-screen `PRINT FIELDS`
- Printer **spooling / PRINTER.SYS config** → [00-configuration/config-directives](../../00-configuration/config-directives/spec.md)
- File/dir **commands** (`COPY`/`DIR`/`DROP`) → [70-commands/file-directory](../../70-commands/file-directory/spec.md)
- `PRINT ... | > file` is also run from `EXECUTE` and from procedures: [program-management](../../70-commands/program-management/spec.md#execute)
- Backing keyword page (deep **`PRINTER`** escape-translation reference retained): [PRINTER](PRINTER.md).
  Other backing pages folded/covered and pruned. The 2b
  redirect-collision pages `Print_Using`, `PRN` and `Remote_Printing` were folded here and pruned;
  verbatim wikitext remains on the BR wiki.
