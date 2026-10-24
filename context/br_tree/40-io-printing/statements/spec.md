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
keywords: [PRINT, OPEN, PAGEOFLOW, NEWPAGE, BELL, TAB, HEADING, USING, PIC, COPIES, PRINTER_LIST]
corrections:
  - "PRINTER_LIST added to the frontmatter keywords. `PRINTER_LIST(MAT a$)` is documented on this
    page (populates an array with local printer names/ports) and was routing nowhere. Found
    2026-09-11 auditing `go run ./cmd/gendata`'s unrouted-function list against actual br_tree
    content."
---

# Printing statements

`PRINT` (and `PRINT USING`) for screen/printer/display output, formatting with `FORM`/`PIC`,
cursor positioning, page control, and opening printer files. On-screen `PRINT FIELDS` is in
[20-io-screen/input-output](../../20-io-screen/input-output/spec.md); the record-layout `FORM`
codes are canonically in [30-io-file/form-spec](../../30-io-file/form-spec/spec.md); printer
*configuration* (spooling, PRINTER.SYS) is in
[00-configuration](../../00-configuration/config-directives/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
-- unformatted --
PRINT ['#'<file-num> ':'] [<print-options>] [<print-list>]
<print-options> ::= BELL | NEWPAGE | TAB(<column>)
<print-list>    ::= <expression> [ { ';' | ',' } <expression> ]*

-- formatted --
PRINT ['#'<file-num> ':'] USING { <form-ref> | <string-expr> } ':' <expression-list>
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

<a id="options"></a>**Options** (each followed by `;`): `BELL` sounds the bell, `NEWPAGE` starts a
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
- [sort](../sort/spec.md) — sorting records for reports
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — canonical FORM field codes
- [20-io-screen/input-output](../../20-io-screen/input-output/spec.md) — on-screen `PRINT FIELDS`
- Printer **spooling / PRINTER.SYS config** → [00-configuration/config-directives](../../00-configuration/config-directives/spec.md)
- File/dir **commands** (`COPY`/`DIR`/`DROP`) → [70-commands/file-directory](../../70-commands/file-directory/spec.md)
- Backing keyword page (deep **`PRINTER`** escape-translation reference retained): [PRINTER](PRINTER.md).
  Other backing pages folded/covered and pruned. The 2b
  redirect-collision pages `Print_Using`, `PRN` and `Remote_Printing` were folded here and pruned;
  verbatim wikitext remains on the BR wiki.
