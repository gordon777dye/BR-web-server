---
title: Serial communications channels
file: spec.md
source: §File Operations → OPEN (comm-open-string); br_tree BAUD/DATABITS/Com folded in & pruned (2b)
category: 30-io-file
subcategory: 30-io-file/serial-comm
kind: spec
status: 2b           # reference base + br_tree enrichment; PARITY removed (not an OPEN param on 4.0+)
recovered-fold: OPEN_communications (folded+pruned — FORMAT=ASYNC/OUTIN-init/WAIT→4271/EOL=NONE; PARITY intentionally omitted; verbatim retained on the BR wiki)
related: [statements, file-model]
keywords: [BAUD, DATABITS, STOPBITS, COM, OPEN, serial]
---

# Serial communications channels

Opening an RS-232 / serial port as a DISPLAY channel and reading/writing it with the ordinary
file statements. The general OPEN/PRINT/LINPUT mechanics are in
[statements](../statements/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<port-ref>         ::= 'COM' <digit> ':'           -- Windows (colon after the digit)
                     | ':/dev/tty' <integer>       -- Linux / Mac (colon at the start)

<comm-open-string> ::= '"' 'FORMAT=ASYNC' ',' 'NAME=' <port-ref>
                       [ ',' 'BUFSIZE='  <integer> ]   -- default 2000
                       [ ',' 'BAUD='     <integer> ]   -- default 1200
                       [ ',' 'DATABITS=' {'7'|'8'} ]   -- default 8
                       [ ',' 'STOPBITS=' <integer> ]   -- default 1
                       [ ',' 'RETRY='    <integer> ]   -- default 5
                       [ ',' 'RECL='     <integer> ]   -- default 132 (output only)
                       [ ',' 'WAIT='     <integer> ]
                       [ ',' 'EOL=' { 'LF' | 'CRLF' | 'NONE' } ]
                       [ ',' 'TRANSLATE=' <table> ] '"'
                     | <string-expression>

OPEN '#'<channel> ':' <comm-open-string> ',' 'DISPLAY' ',' { 'INPUT' | 'OUTPUT' | 'OUTIN' }
```

<a id="semantics"></a>
## Semantics

- A serial port is opened as a **DISPLAY** channel — `INPUT`, `OUTPUT`, or **`OUTIN`** (bidirectional,
  e.g. a modem) — and driven with `PRINT #` / `INPUT #` / `LINPUT #` like any display file.
- Line settings default to **1200 baud, 8 data bits, 1 stop bit** — override per the parameters
  above. `BUFSIZE` defaults to 2000; `RECL` (output) to 132.
- **`BAUD`** valid rates: DOS/Network — 110, 150, 300, 600, 1200, 2400, 4800, 9600; Unix/Linux also
  50, 75, 134, 200, 1800; plus extended **19200, 38400, 57600, 115200** (limited by the hardware).
- **`DATABITS`** must be 7 or 8 (default 8); always use **8** for binary files (incl. `.BR`/`.BRO`).
- **Port naming** by platform: `COM2:` on Windows, `:/dev/tty…` on Linux/Mac. `NAME=COM1:` opens
  with defaults.
- A communications file **requires `FORMAT=ASYNC`** and a valid serial-port `NAME`; the channel must be
  `1–127` or `255`. Open it **`OUTIN`** for modems so line initialization can confirm the connection
  (other display files can't use OUTIN). `WAIT=` bounds how long to wait for a complete record before
  **error 4271** (incomplete record). With `EOL=NONE`, use `LINPUT` (it reads to the variable's
  dimensioned length — one byte at a time if `DIM X$*1`). *(The legacy `PARITY=` OPEN parameter is
  intentionally omitted — it is not an OPEN parameter on 4.0+.)*

<a id="com-config"></a>
## COM port definition (BRConfig.sys)

`COM1:`/`COM2:` are built-in device names; the standalone `COM` *statement* is no longer supported,
but the **`COM` BRConfig.sys spec** still defines up to 8 ports (also settable via `CONFIG`):
```
COM <num 1-8> <irq-num 2-15> <base-io-address>
```
- Start-up defaults: `COM1 4 3F8`, `COM2 3 2F8` (IBM-PC standard; reassignable). `COM3`–`COM8`
  default to undefined — opening one without a `COM` spec gives error **4152** (file not found).
- `irq-num` may be **0** to disable input-interrupt processing (output-only ports). Multiple ports
  may share an interrupt (all sharers are checked when it fires). Boards must follow IBM-PC I/O
  conventions and not conflict with existing ports.

<a id="examples"></a>
## Examples

```business-rules
! Modem on COM1 with defaults (bidirectional)
00200 OPEN #77: "NAME=COM1:", DISPLAY, OUTIN

! Explicit line settings, send a message
00250 OPEN #40: "NAME=COM2:,FORMAT=ASYNC,BAUD=2400,DATABITS=8", DISPLAY, OUTPUT
00260 PRINT #40: MESSAGE$
```

<a id="see-also"></a>
## See also

- [statements](../statements/spec.md#open) — OPEN grammar and display-channel I/O
- [file-model](../file-model/spec.md) — communications files as a file type
- [00-configuration/config-directives](../../00-configuration/config-directives/spec.md) — `COM` is a BRConfig.sys directive
