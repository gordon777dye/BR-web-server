---
title: BR Statement Runtime Semantics
file: statement-semantics.md
category: dev
kind: reference
status: extracted
source: context/br_tree/ specs (10-language, 20-io-screen, 30-io-file, 40-io-printing)
purpose: Model-friendly reference for BR statement behavior, side effects, and error handling
---

# BR Statement Runtime Semantics

Comprehensive reference for the core BR statements covering file I/O, screen input/output, file &
data management, SQL/database access, data declaration, data assignment and manipulation, conditional and branching flow,
loop control, error handling, function definition (including library-linked functions), and command
execution. This
document extracts detailed runtime semantics from the BR language tree for LLM-friendly consumption.

> **This file assumes [`context/br_tree/`](../br_tree/) is present in the context folder.** It is a
> fast, statement-oriented summary; **`br_tree` is the authoritative, comprehensive reference.** When
> you need full syntax, edge cases, version notes, or related concepts, follow the br_tree links in
> each statement's **See also** section (relative paths from this file, e.g.
> [`../br_tree/30-io-file/statements/spec.md`](../br_tree/30-io-file/statements/spec.md)).

**Source:** Synthesized from folded BR language specs in `context/br_tree/`:
- 30-io-file/statements/spec.md (OPEN, READ, REREAD, WRITE, REWRITE, DELETE, RESTORE, CLOSE)
- 30-io-file/form-spec/spec.md (FORM record/print-line layout)
- 10-language/data-manipulation/declaration/spec.md + 00-configuration/config-directives/OPTION_(Config).md (OPTION)
- 20-io-screen/input-output/spec.md (PRINT FIELDS, INPUT FIELDS, RINPUT FIELDS, INPUT SELECT, INPUT, LINPUT)
- 20-io-screen/windows-cursor/spec.md (OPEN window, PRINT BORDER)
- 20-io-screen/controls/spec.md (COMBO, RADIO, CHECK, buttons, GRID/LIST, TEXT, DISPLAY MENU, INPUT MENU)
- 10-language/data-manipulation/conditionals/spec.md (IF/THEN/ELSE/END IF)
- 10-language/flow-control/other-flow/spec.md (GOTO, ON…GOTO/GOSUB, RANDOMIZE, STOP/END/PAUSE, FOR/NEXT, DO/LOOP, GOSUB/RETURN, EXIT)
- 10-language/flow-control/error-handling/spec.md (ON ERROR, RETRY, error conditions)
- 10-language/data-manipulation/assignment/spec.md (LET, :=, MAT ops, substring, DATA/READ/RESTORE)
- 40-io-printing/sort/spec.md (SORT)
- 30-io-file/keys-indexes/spec.md (INDEX)
- 30-io-file/database/spec.md (Database Operations: CONFIG DATABASE, OPEN...SQL, WRITE/READ)
- 30-io-file/serial-comm/spec.md (OPEN serial)
- 70-commands/program-management/spec.md (EXECUTE, CHAIN)
- 10-language/data-manipulation/declaration/spec.md (DIM, MAT redim)
- 10-language/flow-control/functions-udf/spec.md (DEF FN, FNEND)
- 50-libraries/library-facility/spec.md (LIBRARY, DEF LIBRARY linkage)
- 40-io-printing/statements/spec.md (PRINT, PRINT USING)

---

## Table of Contents

### File I/O Statements
1. [OPEN file](#open-file--file-opening-modes-attributes)
2. [READ](#read--record-input-keying-locking-position)
3. [REREAD](#reread--re-decode-buffered-current-record)
4. [WRITE](#write--record-output-new-record-creation)
5. [REWRITE](#rewrite--update-existing-record)
6. [DELETE](#delete--remove-record)
7. [RESTORE](#restore--reposition-file-pointer)
8. [CLOSE](#close--finalize-file)
9. [FORM](#form--record-and-print-line-layout)

### SORT, INDEX and Database
10. [SORT](#sort--sort-an-internal-file-via-a-control-file)
11. [INDEX](#index--create-or-rebuild-a-key-index)
12. [Database Operations](#database-operations--sql-database-access-via-odbc)

### Unformatted I/O Operations
13. [PRINT](#print--output-to-screen-or-file-without-fields)
14. [INPUT/LINPUT/RINPUT](#input--screen-input-prompt)
15. [OPEN serial](#open-serial--serial-communications-channel)
16. [DISPLAY MENU / INPUT MENU — native Windows menus](#display-menu--input-menu--native-windows-menus)

### Full Screen Processing
17. [OPEN window](#open-window--bordered-display-windows)
18. [PRINT FIELDS](#print-fields--formatted-output-with-attributes)
19. [INPUT FIELDS](#input-fields--formatted-input-with-field-attributes)
20. [RINPUT FIELDS](#rinput-fields--display-current-values-then-accept-edits)
21. [INPUT SELECT / RINPUT SELECT](#input-select--rinput-select--menu-selection-via-fields)
22. [GRID / LIST / TEXT — 2-D and multi-line controls](#grid--list--text--2-d-and-multi-line-controls)
23. [Screen controls — COMBO / RADIO / CHECK / buttons](#screen-controls--combo--radio--check--buttons)

### Data Declaration
24. [OPTION](#option--program-options-and-array-base)
25. [DIM / MAT (redim)](#dim--variable-and-array-declaration-multi-dimensionality)

### Assignment & Data Manipulation
26. [LET](#let--variable-assignment-multiple-and-compound-forms)
27. [Forced assignment (:=)](#forced-assignment--assign-inside-a-condition)
28. [MAT (array assignment)](#mat--whole-array-assignment-operations)
29. [Substring assignment](#substring-assignment--in-place-string-mutation)
30. [DATA / READ / RESTORE (data table)](#data--read--restore--internal-data-table)

### Conditional & Branching Flow
31. [IF / THEN / ELSE](#if--then--else--conditional-execution)
32. [GOTO](#goto--unconditional-branch)
33. [ON … GOTO / GOSUB](#on--goto--gosub--computed-indexed-branch)
34. [RANDOMIZE](#randomize--reseed-the-random-number-generator)
35. [STOP / END / PAUSE / CHAIN](#stop--end--pause--chain--program-termination-and-interruption)

### Flow Control & Loops
36. [FOR / NEXT](#for--next--loop-construct-nesting)
37. [DO / LOOP](#do--loop--conditional-loops)
38. [GOSUB / RETURN](#gosub--return--subroutine-call-and-return)
39. [EXIT](#exit--loop-or-subroutine-exit)
40. [EXECUTE](#execute--run-a-command-string-from-code)
41. [TRACE](#trace--line-number-tracing-under-program-control)

### Error Handling & Recovery
42. [ON condition](#on-condition--program-wide-condition-traps)
43. [ON ERROR](#on-error--catch-all-error-handler)
44. [RETRY / CONTINUE](#retry--continue--re-execute-or-skip-after-an-error)

### Function Definition
45. [DEF FN / FNEND](#def-fn--fnend--user-defined-function-declaration)
46. [Library Functions](#library-functions--link-reusable-fn-functions-across-programs)

---

<a id="open-file"></a>
## OPEN file — File opening, modes, attributes

**Syntax:**
```bnf
<share-spec> ::= `NOSHR` | `SHR` | `SHRI`
<key-spec>   ::= `KPS=` <start> [`/` <start>]* `,` `KLN=` <len> [`/` <len>]*   -- ≤6 sections, ≤128 bytes total

<file-open-string> ::= `"` `NAME=` <file-pathname>
                       [ `,` `KFNAME=` <key-pathname> ] [ `,` `LINKED` ]
                       [ `,` { `NEW` | `USE` | `REPLACE` } ]
                       [ `,` `RECL=` <integer> ] [ `,` `RESERVE` ]
                       [ `,` <key-spec> ] [ `,` <share-spec> ] 
                       [ `,` `VERSION=` <integer> ] [ `,` `WAIT=` <integer> ]
                       [ `,` `TRANSLATE=` <table> ] [ `,` `NOCLOSE` ] 
                       [ `,` { `BTREE` | `ISAM` } ] [ `,` `TMPIDX` ] `"`
                     | <string-expression>

OPEN `#`<channel> `:` <file-open-string> `,` `INTERNAL` `,`
     { `INPUT` | `OUTPUT` | `OUTIN` } [ `,` { `SEQUENTIAL` | `RELATIVE` | `KEYED` } ]
     [ <error-condition> <line-ref> ]*
OPEN `#`<channel> `:` <file-open-string> `,` `EXTERNAL` `,`
     { `INPUT` | `OUTPUT` | `OUTIN` } [ `,` { `SEQUENTIAL` | `RELATIVE` } ]
```

**What it does:**
1. **Acquires a file channel** — Associates a logical channel (`1–199` or `300–999`; plus the reserved `#0` console and `#255` printer) with a physical file
2. **Establishes access mode** — `INPUT` (read-only), `OUTPUT` (write-only), or `OUTIN` (both)
3. **Sets positioning strategy** — `SEQUENTIAL` (linear scan), `RELATIVE` (by record number), or `KEYED` (by key field)
4. **Applies file creation logic** — `NEW` (error if exists), `USE` (open-or-create), `REPLACE` (overwrite), or reuse existing
5. **Configures sharing behavior** — `NOSHR` (exclusive), `SHR` (full share), `SHRI` (others may open INPUT only)
6. **Sets record locking** — `RESERVE` enables pessimistic locking; default allows optimistic updates
7. **Initializes I/O position** — SEQUENTIAL starts at beginning; RELATIVE/KEYED require positioning via READ or RESTORE

**Defaults (internal files):**
- Reuse existing file (not create)
- Not keyed
- `NOSHR` (exclusive access)
- `WAIT=15` seconds (applies to both file-lock and locked-record waits)
- `SEQUENTIAL` access
- `TRANSLATE=` none (no character translation)

**Key semantics:**
- **File parameters** (`RECL`, `KPS`, `KLN`) are **only for file creation** — they live in the file header once written. Never supply them on an existing file; BR ignores them if present.
- **Key-spec limits:** `KPS`/`KLN` define up to **6 key sections** (split keys, separated by `/`), totaling **≤128 bytes**.
- **`NEW` vs. `USE` vs. `REPLACE`:** `NEW` errors (4150) if file exists; `USE` opens-or-creates; `REPLACE` overwrites the entire file.
- **`OUTIN` ordering:** When opening a file both `OUTIN` and `INPUT`, the **`OUTIN` open must come first** or you get **error 0608**.
- **`TRANSLATE=<table>`:** Names a 256- or 512-byte character-translation file applied to all `C`/`V`/`G`/`N`/`ZD`/`PIC` I/O (first 256 bytes = input table; optional second 256 = output table, else BR inverts input).
- **`WAIT=` timing:** Number of seconds BR waits on a lock before failing (**default 15**). Two roles: (1) at `OPEN`, how long to wait for a *file* another workstation has locked → **error 4146**; (2) during I/O, how long to wait for a locked *record* → **error 0061**. Historically `WAIT=` governed only the locked-*record* case (0061); the file-lock-at-OPEN role (4146) was added later. (For keyboard `LINPUT`, `WAIT=` instead arms an input `TIMEOUT` → **error 4145** — see INPUT.)
- **<channel> range** is (1–199 & 300-999)

**Display files** (`OPEN … DISPLAY`):
- Opens a text file or printer for `INPUT` *or* `OUTPUT` (never `OUTIN`), sequential only
- Defaults add `PAGEOFLOW` 60 lines and `EOL=` CRLF (DOS) / LF (Unix)
- Print-side parameters (`EOL=`, `PAGEOFLOW=`, `COPIES=`, `PRINTER=`, `CONV=`, `RETRY=`) are in printing spec
- `OPEN #0:` resizes the BR main window and sets `BUTTONROWS`

**Internal files** (`OPEN … INTERNAL`):
- **Most efficient and commonly used** file type in BR applications
- **Fixed-length records** with BR binary format (includes internal header, delete byte per record, index support)
- **Multi-access modes:** SEQUENTIAL (scan), RELATIVE (direct by record #), KEYED (index-based)
- **In-place update:** OUTIN mode supports READ, REWRITE, DELETE on same file (with `RESERVE`/`RELEASE` for locking)
- **Indexing & sorting:** Native support for SORT and INDEX operations; keyed files use B-tree indexes
- **Sharing:** Supports NOSHR (exclusive), SHR (read/write share), SHRI (input only), RESERVE (multi-record locks)
- **Record locking:** With SHR,OUTIN: locks on READ, persists until next I/O, file close, or RELEASE; fine-grained by record byte-zone (supports file growth)
- **Linked lists:** Optional LINKED mode for efficient hierarchical data (master-detail); internally maintained pointers in first 8 bytes
- **Efficient record lengths:** Powers of 2 minus 1 (7, 15, 31, 63, 127, 255, 511, 1023, …) minimize I/O fragmentation
- **File growth:** No pre-allocation needed; WRITE appends; REORG rebuilds for deleted-record recovery
- **Performance:** Keyed files 2–3× faster than sequential for large datasets; record locking has minimal overhead (byte-zone reservation)
- **Multiple keys** are supported by consecutively opening the same file with different key filenames

**External files** (`OPEN … EXTERNAL`):
- Read/write **any** bytes of **any** file (no BR header, no delete byte)
- **`DELETE` is invalid** on them
- Position with `REC=` (record × `RECL`) or `POS=` (absolute byte); don't mix the two on one file
- `EOF` fires only when the final record is a full `RECL`; a **short** final record raises **error 4271** (trap with `IOERR`)
- **Error 4271 buffer state:**
  - **Cause:** External file record stream contains fewer bytes than `RECL`; occurs at end-of-file when last block is partial
  - **Buffer after 4271:** The variable is **null-padded to `RECL` length** (short data + binary zeros filling remainder); `CNT` holds the actual bytes read (before padding)
  - **Recovery:** Save `CNT` value immediately, then issue `REREAD` into **same buffer variable** using a 'form C cnt_len' — BR will then read only the valid portion of the buffer
  - **Subsequent reads:** After error 4271 recovery, next READ gives normal error 4270 (EOF)
  - **Use case:** Common when processing binary streams or variable-length records in chunks; always trap `IOERR` in external file reads
- For external RELATIVE file last positioned with `POS=`, `REC(n)`/`LREC(n)` return a *byte* number rather than a record number

**Common errors:**
- ERR 4150: File exists (with `NEW`); file not found (with `INPUT`)
- ERR 4146: File locked by another workstation (wait timeout expired)
- ERR 0608: `OUTIN` open must come before `INPUT` open of same file
- ERR 4271: Short final record on external file (see detailed explanation in External files section above)

**Gotchas:**
1. **File parameters are header-permanent** — Once a file exists, `RECL`/`KPS`/`KLN` in the OPEN are ignored; use `COPY` to change `RECL`
2. **`REPLACE` is destructive** — It overwrites the file entirely; there is no undo
3. **External files and short records** — The `4271` error is common in external file loops; always trap `IOERR` for safety
4. **Keyed files need `KFNAME`** — If you `KEYED` but don't provide `KFNAME`, BR generates error 607

**Example code:**
```business-rules
! Create / open / sequential read (INTERNAL)
00110 OPEN #1: "NAME=MILES.DAT,RECL=255,NEW", INTERNAL, OUTPUT, SEQUENTIAL
00150 WRITE #1, USING 160: DATE, MILES, GALLONS, MPG 
00160 FORM N 6, N 6.2, N 6.2, N 6.3
00200 CLOSE #1:

! Keyed lookup in INTERNAL file (most common pattern in application code)
00310 OPEN #2: "NAME=CUSTOMER.DAT, KFNAME=CUSTOMER.KEY", INTERNAL, INPUT, KEYED
00320 DIM CUST_ID$*10, CUST_NAME$*30, CREDIT_LIMIT
00330 READ #2, KEY=CUST_ID$: CUST_NAME$, CREDIT_LIMIT NOKEY 400
00340 PRINT "Found: " & CUST_NAME$
00350 GOTO 500
00400 PRINT "Customer not found"
00500 CLOSE #2:

! Multi-record lock with INTERNAL file (RESERVE/RELEASE pattern)
00150 OPEN #3: "NAME=INVENTORY.DAT, KFNAME=INVENTORY.KEY", INTERNAL, OUTIN, SHR
00160 READ #3, USING 600,KEY=PART_ID$, RESERVE: QTY, ALLOCATED NOKEY 300
00170 IF QTY > ALLOCATED THEN REWRITE #3, RESERVE: QTY, ALLOCATED ELSE RESTORE #3:
00180 GOTO 500
00300 PRINT "Part not found"
00500 CLOSE #3:
00550 !
00600 FORM N 7,N 7

! INTERNAL LINKED file (hierarchical master-detail)
00100 OPEN #4: "NAME=ORDERS.DAT,RECL=200,USE,LINKED", INTERNAL, OUTIN, RELATIVE
00110 READ #4, KEY=ORDER_ID$: ORDER_FORM$ NOKEY 200
00120 ! Order linked to detail records; iteration follows internal list pointers

! External file input with 4271 error handling (short record at EOF)
00050 OPEN #3: "NAME=DATA.BIN,RECL=256", EXTERNAL, INPUT, SEQUENTIAL
00060 DIM RAW$*256
00070 READ #3, USING 90: RAW$ IOERR 100 EOF 200
00080 GOTO 70
00090 FORM C 256
00100 ! Handle 4271 (short record) or other I/O error
00110 IF ERR=4271 THEN GOSUB 300 ELSE GOTO 200
00200 CLOSE #3: : STOP                     ! two colons: terminate CLOSE, then separate STOP
00300 ! 4271 handler: save actual bytes read, re-read to get padded buffer
00310 LET ACTUAL_CNT = CNT
00320 REREAD #3: RAW$ 
00330 ! RAW$ now contains: first ACTUAL_CNT bytes = data, rest = binary zeros
00340 ! Process RAW$ with length = ACTUAL_CNT
00350 RETURN
```

**See also:**
- OPEN window (bordered display windows — the `DISPLAY, OUTIN` window form)
- OPEN serial (serial/RS-232 communications channel — `DISPLAY, FORMAT=ASYNC`)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full OPEN syntax, defaults, and record I/O (comprehensive)
- [30-io-file/file-model](../br_tree/30-io-file/file-model/spec.md) — types, modes, access methods, sharing/locking
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — the `USING FORM` record layout
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — `KEY=`/`SEARCH=` keyed I/O and the INDEX facility
- [30-io-file/serial-comm](../br_tree/30-io-file/serial-comm/spec.md) — OPEN of a serial channel
- [40-io-printing/statements](../br_tree/40-io-printing/statements/spec.md) — DISPLAY/printer opens (`EOL=`, `PAGEOFLOW=`, …)

---

<a id="read"></a>
## READ — Record input, keying, locking, position

**Syntax:**
```bnf
READ `#`<channel> [ `,` `USING` <form-ref> ] [ `,` <position> ] [ `,` {`RESERVE` | `RELEASE`}] [ `,` `KEYONLY` ]
      `:` <variable-list> [ `EOF` <line-ref> ] [ `NOKEY` <line-ref> ] [ `NOREC` <line-ref> ] [ `ERROR` <line-ref> ]
      -- KEYONLY reads the key, not the record; READ only, and the colon must follow it
<position> ::= `REC=` <numeric-expr> | `KEY[>]=` <string-expr> | `SEARCH[>]=` <string-expr>
             | `LINK=` <string-expr>   -- LINKED files only; exact total key length, else 0718
             | `POS=` <numeric-expr>   -- absolute byte, external RELATIVE files; do not mix with REC=
             | `FIRST` | `LAST` | `PRIOR` | `NEXT` | `SAME`
<form-ref> ::= <line-ref> | <form-string>
<form-string> ::= `"` `FORM` <form-item> [ `,` <form-item> ]* `"`
<form-item> ::= { `POS` | `X` | `SKIP` } <qty>      -- positioning / line skip; never takes a repeat factor
         | [ <qty> `*` ] <format-spec>        -- a field, optionally repeated
         | [ <qty> `*` ] `(` <flat> [`,` <flat>]* `)` -- repeat a group; groups do not nest
         | <literal> | `PIC(` <picture> `)` | `DATE(` <mask> `)`
<flat>   ::= { `POS` | `X` | `SKIP` } <qty> | [ <qty> `*` ] <format-spec>
         | <literal> | `PIC(` <picture> `)` | `DATE(` <mask> `)`
<format-spec> ::= <string-code> [ ` ` <qty> ] | <numeric-code> ` ` <qty> [ `.` <qty> ]
<qty> ::= <integer> | <numeric-variable>      -- width and decimals resolve separately: `PD 6.PRICE_`

```

**What it does:**
1. **Fetches the next record** or a record at a specified position into the variable list
2. **Decodes via FORM** — If `USING <line-ref>` is provided, interprets bytes according to the FORM specification; otherwise reads raw data in the same variable list form written
3. **Updates file position** — After a successful READ, the current position marker is set to that record (affects `REREAD`, `REWRITE`, `DELETE`)
4. **Sets system variables** — `CNT` = number of items successfully read (stops at first error); `REC(n)` = current record number (mostly used in RELATIVE mode, but also valid for keyed)
5. **Handles positioning clauses:**
   - **`REC=<n>`** — Reads record #n (1-based); RELATIVE or KEYED mode; missing/deleted → `NOREC`
   - **`KEY=<k$>`** — Reads the first record with an exact key match (KEYED mode); not found → `NOKEY`
   - **`KEY>=<k$>`** — Reads the first record with a key ≥ the search value (KEYED mode, exact or next-greater)
   - **`SEARCH=<k$>`** — Arg key may be partial- must be exact match on portion specified
   - **`SEARCH>=<k$>`** — Arg key may be partial- => than arg
   - **`FIRST`** — Repositions to the first record of the file
   - **`LAST`** — Repositions to the last record of the file
   - **`PRIOR`** — Reads the record before the current position
   - **`NEXT`** — Reads the record after the current position
   - **`SAME`** — Reads the current position again (useful for checking 
   for updated data on unlocked records before rewriting)
6. **`KEYONLY` reads the key instead of the record** — `READ #n, KEYONLY: key$, recnum` takes the key
   and its relative record number from the **index**, without touching the master record: one file's
   worth of I/O on a sequential key scan rather than two, and a key still comes back when the master
   record is locked. `FORM` is the key length plus `B 4`. A master record must have been read first
   (else error 0718), and a following `REREAD`/`REWRITE`/`DELETE` errors. Accepted on `READ` alone and
   only immediately before the colon. Full description under
   [keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md#keyonly)

**Error conditions:**
- **`EOF`** — No more records (end of file reached); `ERR` = 4270 (file) or 57 (data)
- **`NOKEY`** — Key not found in keyed access; only on READ statement, not with `ON`
- **`NOREC`** — Record number out of range or deleted  (`REC=` access); only on statement
- **`IOERR`** — Any trapped I/O error (CONV, type mismatch, disk I/O failure)

**File position side effects:**
- After a successful READ, the **current position is updated** to that record
- Next READ (with no position clause) continues from that position
- The position persists until another READ/RESTORE/REREAD repositions it
- `REC(n)` holds the last-read record number
- **Buffered read** — The record stays in the buffer until the next READ or file close, allowing `REREAD` to re-interpret it

**Locking behavior:**
- **Default (NOSHR):** Records are **not locked** on READ; another workstation can modify them before you REWRITE
- `RESERVE` and `RELEASE` can be applied to **filenames** (even while the file is not open) or **records**
- `OPEN` and `PROTECT` can reserve (lock) a filename; `CLOSE` and `PROTECT` can release it; `OPEN` cannot open a protected filename
- READ and REREAD can RESERVE (the default) a record, or release it; `WRITE` or `REWRITE` can keep it locked; `REWRITE` cannot be performed on an unlocked record in a shared file
- **Between `SHR` opens:** READ applies a **pessimistic lock**; (exclusive read/rewrite lock) — however foreign applications can read the record
- ** `SHRI` allows other workstations to open the same file `INPUT` and read the file unhampered; `SHRI` and `SHR` are incompatible but multiple `SHRI` opens are supported with `SHR` locking
- Explicit lock release- `REREAD #n, RELEASE:`
- The locking system allows multiple records to be locked and the RESERVE keyword retains the locks on all of the records until one lock is released, in which case all record locks on the file are released

**Common errors:**
- ERR 4148 File locked
- ERR 61 Record locked timeout
- ERR 4270: EOF (no more records, or no file space on output file)
- ERR 4271: Short final record on external file (padded; re-READ to fetch the padding)
- ERR 57: NOREC (record deleted/out of range) or EOF (data stream)
- ERR 4272: NOKEY (key not found)
- ERR CONV: Type mismatch between FORM spec and variable

**Gotchas:**
1. **Buffered record lifespan** — The decoded record stays in the buffer until the *next* READ on that channel; you can `REREAD` it unlimited times; opening another file on the same channel is not allowed
2. **Duplicate keys** — To walk duplicate keys, read `NEXT`
3. **File position after EOF** — Once EOF is hit, the file position is at the end; you must `RESTORE` to go back or READ `PRIOR`
4. **RELATIVE vs. KEYED position** — In RELATIVE mode, `REC(n)` is the record number; in KEYED, you use the key; mixing them is allowed but `NEXT` / `PRIOR` always positions by key
5. **Deleted records and `NOREC`** — A deleted record occupies a slot; RELATIVE and SEQUENTIAL READs skip deleted slots automatically; RELATIVE REC= traps NOREC conditions

**Example code:**
```business-rules
! Sequential read until EOF
00100 OPEN #1: "NAME=test.int,RECL=50", INTERNAL, INPUT, SEQUENTIAL
00110 DO
00120   READ #1: A$, B EOF DONE
00130   PRINT A$, B
00140 LOOP
00150 DONE: CLOSE #1

! Keyed access with duplicate-key walk
00200 OPEN #2: "NAME=test.int,RECL=50,KPS=1,KLN=20", INTERNAL, INPUT, KEYED
00210 READ #2, KEY="ABC": A$ NOKEY 300  ! read by key
00220 REREAD #2: A$, B, C, D            ! re-read full record
00230 READ #2: A$ EOF 300               ! read next (same or greater) key

! Relative access by record number
00300 OPEN #3: "NAME=test.int", INTERNAL, INPUT, RELATIVE
00310 FOR I = 1 TO 100
00320   READ #3, REC=I: A$, B NOREC 350
00330   PRINT A$, B
00340 NEXT I
00350 CLOSE #3:

! Re-interpret buffered record
00400 READ #1, USING SHORTFORM: KEY$
00410 IF KEY$ = "SKIP" THEN REREAD #1, USING FULLFORM: A$, B, C
```

**See also:**
- REREAD (re-decode buffered record)
- REWRITE, DELETE (modify current record)
- RESTORE (reposition file pointer)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full READ reference (comprehensive)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — keyed I/O (`KEY=`/`SEARCH=`)
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — `USING FORM` decoding

---

<a id="reread"></a>
## REREAD — Re-decode buffered current record

**Syntax:**
```bnf
REREAD `#`<channel> [ `,` `USING` <form-ref> ] [ `,` {`RESERVE` | `RELEASE`}] `:` <variable-list>
```

**What it does:**
1. **Re-decodes the buffered current record** — Re-interprets the record most recently READ (or REREAD) on the channel; **no file I/O** is performed
2. **Optionally applies a different FORM** — A `USING <form-ref>` re-maps the same bytes through a new FORM spec (e.g., a fuller layout than the original READ used)
3. **No `EOF`** — Because no record is fetched, there is no end-of-file condition
4. **Sets system variables** — `CNT` = number of items successfully decoded (stops at first error)

**Semantics:**
- **Must follow a successful `READ`/`REREAD`** — There must be a buffered record on the channel; REREAD against an empty buffer (e.g., after `RESTORE` or `CLOSE`) errors
- **No positioning clause** — REREAD takes **no** `REC=`/`POS=`/`KEY=` clause; it always operates on the current buffered record (the only Record-I/O statement that cannot reposition)
- **Buffer persists** — The decoded record stays in the buffer until the next `READ` on that channel; you can REREAD it any number of times
- **Lock release** — `REREAD #n, RELEASE:` releases the record lock without repositioning; this is **faster than `RESTORE #n:`** when all you need is to drop the lock
- **External short-record recovery** — After **error 4271** (short final record on an external file), the record is null-padded to `RECL`; a following REREAD retrieves the padded record, after which reads return the normal `4270` EOF

**Duplicate-key walk idiom:**
- A useful pattern reads a **key-only FORM** first, tests the key, then REREADs the **full FORM** only when the key matches — avoiding the cost of decoding every full record while walking duplicate keys:
```business-rules
00100 READ #1, USING SHORTFORM: KEY$ EOF 200      ! decode key only
00110 IF KEY$ <> TARGET$ THEN GOTO 100            ! skip non-matches
00120 REREAD #1, USING FULLFORM: KEY$, A, B, C    ! decode full record
```

**Error conditions:**
- **`IOERR`** — No buffered record (no prior successful READ)
- **`CONV`** — Type mismatch between the FORM spec and a variable

**Common errors:**
- ERR CONV: Type mismatch between FORM spec and variable
- ERR IOERR: No buffered record to re-read (buffer cleared by RESTORE/CLOSE)

**Gotchas:**
1. **No repositioning** — REREAD cannot take `REC=`/`KEY=`/`POS=`; if you need a different record, use `READ` with a position clause
2. **Buffer cleared by RESTORE/CLOSE** — `RESTORE` and `CLOSE` discard the buffered record; a following REREAD errors

**Example code:**
```business-rules
! Re-interpret buffered record with a fuller FORM
00100 OPEN #1: "NAME=cust.int,KPS=1,KLN=10", INTERNAL, INPUT, KEYED
00110 READ #1, USING 120, KEY="ACME": CUST_KEY$ NOKEY 300
00120 FORM C 10                                  ! key-only FORM
00130 REREAD #1, USING 140: CUST_KEY$, NAME$, BALANCE
00140 FORM C 10, C 30, N 10.2                    ! full record FORM
00150 PRINT NAME$, BALANCE
00300 CLOSE #1:

! Release a record lock without repositioning
00400 OPEN #2: "NAME=inv.int,KPS=1,KLN=8", INTERNAL, OUTIN, SHR, KEYED
00410 READ #2, KEY=PART$, RESERVE: QTY           ! locks the record
00420 IF QTY > 0 THEN GOSUB ALLOCATE
00430 REREAD #2, RELEASE:                        ! drop the lock (no reposition)
00440 CLOSE #2:
```

**See also:**
- READ (fetch a record into the buffer)
- REWRITE, DELETE (modify the current record)
- RESTORE (reposition file pointer / release locks)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full REREAD reference (comprehensive)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — keyed I/O, duplicate-key walks

---

<a id="write"></a>
## WRITE — Record output, new record creation

**Syntax:**
```bnf
WRITE `#`<channel> [ `,` `USING` <form-ref> ] [ `,` { `REC=`<n> | `POS=`<n> } ]
      [ `,` {`RESERVE` | `RELEASE`}] `:` <expression-list>
      -- REC= writes a specific slot (see below); POS= is an absolute byte, external RELATIVE only
```

**What it does:**
1. **Appends a new record** to the file (at the next available slot)
2. **Optionally overwrites a specific slot** — If `REC=<n>` is provided and that slot is deleted or new (unwritten), writes there; else traps `DUPREC`
3. **Encodes via FORM** — If `USING <line-ref>` is provided, writes according to FORM spec; otherwise writes raw data
4. **Updates file position** — Sets the current position to the newly written record (like READ does)
5. **Sets system variables** — `CNT` = number of items successfully written (stops at first error); `LREC` = last record number written
6. **Record Locks** - The locking system allows multiple records to be locked and the RESERVE keyword retains the locks on all of the records until one lock is released, in which case all record locks on the file are released

**Modes:**
- **`WRITE` with no `REC=`** — Appends the record to the file (file must be `OUTPUT` or `OUTIN`)
- **`WRITE … REC=<n>`** — Writes to a specific record slot (only if that slot was previously deleted or is new/unwritten); useful for structured files with pre-allocated slots
- **Space not automatically reclaimed** — Deleted records don't compress the file; use the `COPY -D` command to reclaim space

**Error conditions:**
- **`DUPREC`** — Attempt to write to `REC=<n>` when that slot already exists with data
- **`EOF`** — No space on file (file is full, disk full, or an `OUTPUT SEQUENTIAL` file hit `RESTORE` which drops data and marks EOF)
- **`IOERR`** — I/O error, type mismatch, conversion failure

**File position side effects:**
- After a successful WRITE, the **current position is updated** to the new record
- On an `OUTPUT` file, position advances automatically to the next slot
- On an `OUTIN` file, you can READ, REWRITE, DELETE, or RESTORE to reposition
- **New record slot** — If `REC=<n>` is used, that slot is now marked as written; a later `REC=<n>` WRITE to the same slot traps `DUPREC`

**Locking behavior:**
- **Default:** New records are **not locked** after WRITE; another workstation can READ them immediately
- **With `RESERVE` open:** The written record is **locked** until you REWRITE/DELETE/RESTORE or close the file

**Common errors:**
- ERR 4270: EOF (no more space on file)
- ERR DUPREC: Record slot already exists (with `REC=<n>`)
- ERR CONV: Type mismatch between expression and FORM spec
- ERR SOFLOW: String too long for field

**Gotchas:**
1. **No auto-create** — You must `OPEN … NEW` or `OPEN … USE` to create a file; a plain OPEN on a nonexistent file errors
2. **`DUPREC` only with `REC=`** — Without `REC=`, WRITE always appends and never triggers `DUPREC`
3. **`OUTPUT SEQUENTIAL` + `RESTORE`** — Rewinding an `OUTPUT SEQUENTIAL` file **drops all data** and marks EOF; a following WRITE begins with record position 1
4. **Space reuse** — Deleted slots can be reused with `REC=<n>` WRITE, but there's no automatic free-list; manage your slots explicitly
5. **File growth** — WRITE auto-extends the file; disk space is consumed immediately; check `EOF` to prevent runaway growth

**Example code:**
```business-rules
! Create and populate a new file
00100 OPEN #1: "NAME=new.int,RECL=100,NEW", INTERNAL, OUTPUT
00110 FOR I = 1 TO 1000
00120   WRITE #1, USING 130: "Record", I
00130   FORM C 20, N 8
00140 NEXT I
00150 CLOSE #1:

! Reuse a deleted slot
00200 OPEN #2: "NAME=test.int", INTERNAL, OUTIN
00210 READ #2, REC=50: A$ NOREC 220
00220 DELETE #2:
00230 WRITE #2, REC=50: "New data"        ! reuse slot 50
00240 CLOSE #2:

! Trap duplicate record
00300 WRITE #3: A$, B DUPREC 400
00310 CONTINUE 450
00400 PRINT "Record already exists"
00450 CONTINUE
```

**See also:**
- REWRITE (update existing record)
- DELETE (remove record)
- RESTORE (reposition file pointer)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full WRITE reference (comprehensive)
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — `USING FORM` encoding

---

<a id="rewrite"></a>
## REWRITE — Update existing record

**Syntax:**
```bnf
REWRITE `#`<channel> [ `,` `USING` <form-ref> ] [ `,` <update-position> ]
       [ `,` {`RESERVE` | `RELEASE`}] `:` <expression-list> [ { `NOKEY` | `NOREC` } <line-ref> ]
<update-position> ::= `REC=` <numeric-expr> | `KEY=` <string-expr> | `LINK=` <string-expr>
             | `POS=` <numeric-expr>
             | `FIRST` | `LAST` | `PRIOR` | `NEXT` | `SAME`
             -- no `KEY>=` and no `SEARCH=`/`SEARCH>=`: an update names one record,
             --   not the next-greater one
```

**What it does:**
1. **Updates the current record** (the one most recently READ) with new values or if REC= or KEY= then reads and rewrites the specified record
2. **Optionally specifies which record** — `REC=<n>` (RELATIVE mode) or `KEY=<k$>` (KEYED mode) to update; else uses the last-read record
3. **Changes only named fields** — If a FORM is provided, only the fields in the FORM are updated; other fields in the record remain intact
4. **Encodes via FORM** — Applies FORM spec to write values; without FORM, writes raw data
5. **Updates file position** — Sets the position to the rewritten record (like READ does)
6. **Record Locks** - The locking system allows multiple records to be locked and the RESERVE keyword retains the locks on all of the records until one lock is released, in which case all record locks on the file are released

**Semantics:**
- **File must be `OUTIN`** — You cannot rewrite on an `OUTPUT`-only file
- **Partial updates** — REWRITE preserves all fields not mentioned in the FORM; ideal for selective record updates
- **If no `REC=` / `KEY=`** — REWRITE uses the position from the last READ; this is the typical pattern
- **With `REC=` / `KEY=`** — Repositions and updates in one step (useful if the file was read elsewhere)
- **`WAIT=` (positioning only)** — When repositioning via `REC=`/`KEY=`, the target record must be lockable; `WAIT=<sec>` bounds how long to wait for a record another workstation has locked before **error 0061** (defaults to the OPEN's `WAIT=`, 15s). It is meaningless on a plain REWRITE, which updates the already-locked current record
- **Lock is held** — If the file was opened `SHR` and REWRITE RESERVE is specified, the lock persists across READ/REWRITE; other `SHR` workstations remain blocked from accessing the record
- **Key Fields** - Multiple key files, if opened as a group, will be updated automatically when key field values are changed by a REWRITE

**Error conditions:**
- **`IOERR`** - Media failure, out of space, or file not opened `OUTIN`
- **`CONV`** - Conversion Failure — Field type or capacity mismatch between expression and FORM spec
** Side effects:**
- The record buffer is refreshed with the new data
- You can `REREAD` the record to re-interpret the fields you just wrote

**Common errors:**
- ERR CONV: Type mismatch (e.g., numeric expression into character field)
- ERR SOFLOW: String too long for field
- ERR: File not opened `OUTIN` (file is `INPUT` or `OUTPUT`)

**Example code:**
```business-rules
! Read and update in place
00100 OPEN #1: "NAME=test.int,RECL=100", INTERNAL, OUTIN
00110 READ #1, REC=5: A$, B, C, D
00120 LET C = C * 1.1                         ! increase C by 10%
00130 REWRITE #1: A$, B, C, D                 ! update all fields
00140 CLOSE #1:

! Partial update (only change the amount)
00200 DIM AMOUNT$*20
00210 READ #1, REC=10: CUSTNAME$, AMOUNT$ NOREC 300
00220 LET AMOUNT$ = AMOUNT$ + 100
00230 REWRITE #1, USING 240: CUSTNAME$, AMOUNT$
00240 FORM C 30, C 20
00300 CLOSE #1:

! Update including the key field (BR updates all related key files)
00400 OPEN #2: "NAME=test.int,KPS=1,KLN=10", INTERNAL, OUTIN, KEYED
00410 READ #2, KEY="ABC": A$, B, C
00420 REWRITE #2, KEY="ABC": "XYZ", B, C      ! change the key value ABC → XYZ
00430 CLOSE #2:
```

**See also:**
- READ (fetch a record)
- REREAD (re-interpret buffered record without file I/O)
- WRITE (create a new record)
- DELETE (remove a record)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full REWRITE reference (comprehensive)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — keyed update, multi-key files

---

<a id="delete"></a>
## DELETE — Remove record

**Syntax:**
```bnf
DELETE `#`<channel> [ `,` <update-position> ] [ `,` { `RESERVE` | `RELEASE` } ] `:` [ <error-condition> ]
<update-position> ::= `REC=` <numeric-expr> | `KEY=` <string-expr> | `LINK=` <string-expr>
             | `FIRST` | `LAST` | `PRIOR` | `NEXT` | `SAME`
             -- as REWRITE, but no `POS=`; and no `KEY>=`/`SEARCH=`/`SEARCH>=`
```

**What it does:**
1. **Marks the current record as deleted** (the one most recently READ) — the record is not erased, just marked with a delete byte
2. **Optionally specifies which record** — `REC=<n>` (RELATIVE mode) or `KEY=<k$>` (KEYED mode) to delete; else uses the last-read record
3. **Does not reclaim space** — The slot remains in the file; use the `COPY -D` command to compact the file
4. **Updates file position** — The position remains at the deleted record (you can `RESTORE` to move forward)
5. **Record Locks** - The locking system allows multiple records to be locked and the RESERVE keyword retains the locks on all of the records until one lock is released, in which case all record locks on the file are released

**Semantics:**
- **Delete byte is set** — The deleted record is no longer visible to sequential READ; RELATIVE READ REC= traps `NOREC`; keyed search skips over it
- **No `REC=` / `KEY=`** — DELETE uses the position from the last READ; this is the typical pattern
- **With `REC=` / `KEY=`** — Deletes that record without first reading it (useful for batch deletes or error recovery)
- **Space is marked, not freed** — Deleted slots can be reused with a later `WRITE … REC=<n>`
- **`RESERVE` / `RELEASE` clauses** — Manage the lock after deletion (see locking section below)

**Error conditions:**
- **`IOERR`** — I/O error, record not found, or file not opened `OUTIN`
- **Invalid on external files** — `DELETE` is **not allowed** on external files (error occurs at compile or runtime)

**File position side effects:**
- After DELETE, the **current position is updated** to the deleted record
- You can `REREAD` to verify the delete (record data is still there until file is compacted)
- Sequential READ will **skip the deleted slot** and continue to the next record
- RELATIVE READ at that `REC=` traps `NOREC` (record not found / deleted)

**Locking behavior:**
- **Default:** DELETE acquires and releases a write lock; record is immediately available for reuse
- **`RESERVE`** — Holds the lock after deletion; useful to prevent another workstation from immediately reusing the slot
- **`RELEASE`** — Explicitly releases the lock (rarely needed, as DELETE releases automatically); useful after error trapping

**Common errors:**
- ERR IOERR: File not opened `OUTIN` or file not found
- ERR NOREC: Record was already deleted or doesn't exist (only with `REC=` or `KEY=`)
- ERR: Invalid on external file

**Gotchas:**
1. **Space not reclaimed automatically** — Deleted slots accumulate; use `COPY -D` or file reorganization to recover space
2. **Sequential reads skip deleted records** — A `READ` loop in SEQUENTIAL or RELATIVE mode will skip over deleted slots without error
3. **RELATIVE read traps `NOREC`** — If you try to READ a deleted slot by `REC=`, you get `NOREC`, not the deleted data
4. **Keyed search skips deleted records** — A keyed READ with `SEARCH>=` or `KEY>=` skips deleted records with that key
5. **Deleted data persists until reorg** — You can read a deleted record using EXTERNAL file access and see its contents (until the file is compacted) - the leading delete byte is marked "D" when itis deleted 
6. **No cascading deletes** — Deleting a record does not delete related records in other files; you must handle referential integrity yourself

**Example code:**
```business-rules
! Read and delete
00100 OPEN #1: "NAME=test.int", INTERNAL, OUTIN
00110 READ #1, REC=10: A$, B, C
00120 DELETE #1:                              ! delete record 10
00130 CLOSE #1:

! Delete by key
00200 OPEN #2: "NAME=test.int,KPS=1,KLN=20", INTERNAL, OUTIN, KEYED
00210 DELETE #2, KEY="OLDKEY": IOERR 300
00220 CONTINUE 350
00300 PRINT "Delete failed"
00350 CLOSE #2:

! Batch delete with loop
00400 OPEN #3: "NAME=test.int", INTERNAL, OUTIN, RELATIVE
00410 FOR I = 1 TO 100
00420   READ #3, REC=I: A$ NOREC 450
00430   IF A$ = "REMOVE" THEN DELETE #3:
00440 NEXT I
00450 CLOSE #3:
```

**See also:**
- READ (fetch a record before delete)
- REWRITE (update instead of delete)
- RESTORE (reposition file pointer)
- COPY command (compact file with -D flag)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full DELETE reference (comprehensive)
- [70-commands/file-directory](../br_tree/70-commands/file-directory/spec.md) — `COPY -D` and file commands

---

<a id="restore"></a>
## RESTORE — Reposition file pointer

> **Different statement from the channel-less [RESTORE](#data--read--restore--internal-data-table),
> which resets the internal `DATA` table.** The punctuation is where the difference shows: **this
> form ends in a required colon** (`RESTORE #1:`), while the `DATA`-table form takes **no colon at
> all** (`RESTORE`, `RESTORE 900`). Writing either one the other way is a compile error.

**Syntax:**
```bnf
RESTORE `#`<channel> [ `,` <position> ] [ `,` { `RESERVE` | `RELEASE` } ] `:` [ <error-condition> ]

<position> ::= `REC=` <numeric-expr> | `KEY[>]=` <string-expr> | `SEARCH[>]=` <string-expr>
             | `LINK=` <string-expr>   -- LINKED files only; exact total key length, else 0718
             | `POS=` <numeric-expr>   -- absolute byte, external RELATIVE files
             | `FIRST` | `LAST` | `PRIOR` | `NEXT` | `SAME`
```

**What it does:**
1. **Repositions the file pointer** to a new location (or resets to the start with no clause)
2. **Optionally positions to a specific record** — `REC=`, `KEY[>]=`, `SEARCH[>]=`, or positional keywords
3. **Releases locks** — RESTORE releases all held record locks (unless `RESERVE` clause is specified)
4. **Clears or resets the buffer** — Data no longer available for `REREAD`

**Modes:**
- **`RESTORE #n:` (no clause)** — Repositions to the **start of the file** (first record for sequential, first slot for relative, first key for keyed)
- **`RESTORE … REC=<n>`** — Repositions to record #n (RELATIVE mode)
- **`RESTORE … KEY=<k$>`** — Repositions to first record with exact key (KEYED mode); `NOKEY` if not found
- **`RESTORE … KEY>=<k$>`** — Repositions to first record with key ≥ the value (KEYED mode, exact or next-greater)
- **`RESTORE … SEARCH[>]=<k$>`** — Synonym for `KEY=`except it allows a (leading) partial key
- **`RESTORE … FIRST`** — Repositions to the first record/slot/key
- **`RESTORE … LAST`** — Repositions to the last record/slot/key
- **`RESTORE … PRIOR`** — Positions to the record before current (SEQUENTIAL/RELATIVE); must have read at least one)
- **`RESTORE … NEXT`** — Positions to the record after current (SEQUENTIAL/RELATIVE)
- **`RESTORE … SAME`** — Keeps the same position (unusual; mainly for lock release)

**`RESTORE #<n>:` (no clause) data loss warnings:**
- **`RESTORE` on `OUTPUT SEQUENTIAL`** — **Drops all data written** to the file and marks EOF; the file is truncated
- **`RESTORE` on `DISPLAY OUTPUT`** — **Drops all output** sent; the file is reset to empty
- **`RESTORE` on `OUTPUT RELATIVE`** — **Errors** (cannot rewind an output-only relative file)
- **`RESTORE` on `OUTPUT KEYED`** — **Errors** (cannot rewind an output-only keyed file)

**Linked files:**
- **`RESTORE … REC=<anchor>`** — Repositions to a linked-list anchor (and sets `KREC`); used for walking linked records via read next
- **`RESTORE … REC=0` (or bare `RESTORE`)** — Starts a *new* anchor for insertion into a master record
- **`READ … NEXT`** - reads next record in the linked list; EOF error if end-of-list; KREC retains anchor pointer

**Locking behavior:**
- **Default:** RESTORE releases all locks held by that channel
- **`RESERVE` clause:** Keeps the locks (unusual; mainly for specific locking patterns)
- **Slower than REREAD** — `REREAD #n, RELEASE:` is faster than `RESTORE #n:` for just unlocking

**Error conditions:**
- **`NOKEY`** — Key not found in keyed access (only on statement, not with `ON NOKEY`)
- **`IOERR`** — I/O error, invalid channel, or invalid operation (e.g., `RESTORE` on `OUTPUT RELATIVE`)

**File position effects:**
- After RESTORE, the **current position is updated** to the new location
- The record buffer is **cleared** — `REREAD` will error because there is no buffered record
- Next READ starts from the new position

**Gotchas:**
1. **`RESTORE` on `OUTPUT SEQUENTIAL` files is destructive** — Backing up or undoing the reset is not possible; be very careful with this pattern
2. **Lock release is automatic** — You don't need `RESTORE` just to release a lock; `REREAD #n: RELEASE` is faster
3. **PRIOR/NEXT require prior positioning** — You must have read at least one record before using PRIOR or NEXT (the initial position is undefined)
4. **Linked files use `KREC`** — When working with linked lists, keeps track of the anchor in `KREC`; bare `RESTORE` starts a new anchor (REC=0)

**Example code:**
```business-rules
! Rewind file and re-read from top
00100 OPEN #1: "NAME=test.int", INTERNAL, INPUT, SEQUENTIAL
00110 READ #1: A$ EOF 200
00120 PRINT A$
00130 GOTO 110
00200 PRINT "End of first pass"
00210 RESTORE #1:                             ! go back to start
00220 READ #1: A$ EOF 300
00230 PRINT "Second pass:", A$
00240 GOTO 220
00300 CLOSE #1:

! Use PRIOR to walk backward
00400 OPEN #2: "NAME=test.int", INTERNAL, INPUT, SEQUENTIAL
00410 RESTORE #2, LAST:                       ! go to last record
00420 READ #2, PRIOR: A$ NOKEY 500            ! read backward
00430 PRINT A$
00440 GOTO 420
00500 CLOSE #2:

! Linked list traversal
00600 READ #3, REC=ANCHOR_KEY, KEY=STARTKEY: DATA$  ! read first
00610 RESTORE #3, REC=KREC:                   ! follow the link
00620 READ #3: DATA$ EOF 700
```

**See also:**
- READ (fetch a record)
- REREAD (re-interpret buffered record)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full RESTORE reference: positions, linked anchors (comprehensive)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — `KEY=`/`SEARCH=` positioning

---

<a id="close"></a>
## CLOSE — Finalize file

**Syntax:**
```bnf
CLOSE `#`<channel>  [`,` { `DROP` | `FREE` } ] [ `,` `RELEASE` ] `:`
```

**What it does:**
1. **Releases the file channel** — Closes the file and makes the channel available for reuse
2. **Flushes all pending I/O** — Writes are committed to disk
3. **Releases all record locks** — Any pessimistic locks held on the file are released
4. **`RELEASE` releases the FILENAME** - If the filename was reserved with PROTECT, it becomes available
5. **Optionally empties or deletes** — `DROP` (empty contents), `FREE` (erase file), or neither (close normally)

**Options:**
- **`CLOSE #n:` (no clause)** — Closes the file normally; data is saved; the file remains on disk
- **`CLOSE #n, DROP:`** — Empties the file's **contents** — the file remains (internal files keep only the header record, all space freed); external files become zero-length
- **`CLOSE #n, FREE:`** — **Erases** the file from the system — the file path is deleted and the space is reclaimed
- **A following statement needs a second colon** — the `:` in `CLOSE #n:` **terminates** the CLOSE statement; to code another statement after it on one physical line, add a **second** colon as the separator: `CLOSE #n: : STOP` (a single `CLOSE #n: STOP` mis-parses the next statement as part of CLOSE)

**Semantics:**
- **Both `DROP` and `FREE` require the file opened `NOSHR`** (exclusive mode)
- **Auto-close** — Files auto-close at program end (unless `NOCLOSE` was specified in the OPEN)
- **Flushing** — All pending writes are committed; buffers are cleared
- **Locks released** — Any record locks held are released

**Error conditions:**
- **`IOERR`** — File I/O error during close (rare; usually silent)
- **Error if `DROP`/`FREE` on a file not opened `NOSHR`** — The options require exclusive access

**File position side effects:**
- After CLOSE, the **channel is released** — you can reuse it with a different file
- The **record buffer is cleared** — `REREAD` on that channel will error

**Common errors:**
- ERR IOERR: Error 704 - file not open
- ERR: `DROP`/`FREE` on a file not opened `NOSHR` (exclusive required)

**Gotchas:**
1. **`DROP` vs. `FREE`** — `DROP` leaves the file empty but intact; `FREE` deletes the file entirely; once freed, the file is gone
2. **No undo for `FREE`** — Deleting a file with `FREE` is permanent; no recovery possible
3. **Auto-close at program end** — You do not need to CLOSE if the program is ending; it happens automatically (except files opened `NOCLOSE`)
4. **Channel reuse** — After CLOSE, the channel number can be opened for a different file
5. **`NOCLOSE` persistence** — If a file was opened `NOCLOSE`, it stays open across `STOP`/`RUN` and requires explicit CLOSE or program exit to close

**Example code:**
```business-rules
! Normal close
00100 OPEN #1: "NAME=test.int", INTERNAL, INPUT
00110 READ #1: A$
00120 CLOSE #1:

! Close with drop (empty the file)
00200 OPEN #2: "NAME=test.int", INTERNAL, OUTIN, NOSHR
00210 WRITE #2: "Old data"
00220 CLOSE #2, DROP:                         ! file is now empty
00230 OPEN #2: "NAME=test.int", INTERNAL, OUTPUT
00240 WRITE #2: "New data"
00250 CLOSE #2:

! Close with free (delete the file)
00300 OPEN #3: "NAME=test.int", INTERNAL, INPUT, NOSHR
00310 CLOSE #3, FREE:                         ! file is deleted
```

**See also:**
- OPEN file (open a file)
- OPEN window (a window channel is also closed with CLOSE)
- DROP command (console command equivalent)
- FREE command (console command equivalent)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — full CLOSE/DROP/FREE reference (comprehensive)
- [30-io-file/file-model](../br_tree/30-io-file/file-model/spec.md) — file lifecycle
- [70-commands/file-directory](../br_tree/70-commands/file-directory/spec.md) — `DROP`/`FREE` console commands

---

<a id="form"></a>
## FORM — record and print-line layout

**Syntax:**
```bnf
[<line-number>] `FORM` <form-item> [ `,` <form-item> ]*

<form-item>    ::= [ <n> `*` ] <format-spec>          -- one field, optionally repeated
                 | [ <n> `*` ] `(` <flat> [`,` <flat>]* `)` -- repeat a group; groups do not nest
                 | { `POS` | `X` | `SKIP` } <n>         -- absolute column / skip columns / skip lines
                                                        --   (never carries a repeat factor)
                 | `"` <literal> `"`                    -- literal text (output only)
<flat>         ::= [ <n> `*` ] <format-spec> | { `POS` | `X` | `SKIP` } <n> | `"` <literal> `"`
<format-spec>  ::= `C` <len>            -- character, fixed length (blank-padded)
                 | `V` <len>            -- variable-length character (trailing-blank aware)
                 | `G` <len>            -- character, blanks trimmed
                 | `N` <len>[`.`<dec>]  -- zoned/display numeric
                 | `NZ` <len>[`.`<dec>] -- zero-suppressed numeric
                 | `PD` <len>[`.`<dec>] -- packed decimal
                 | `ZD` <len>[`.`<dec>] -- zoned decimal (signed overpunch)
                 | `PIC(` <picture> `)` -- picture-formatted / edited numeric
                 | `DATE(` <mask> `)`   -- date held as a day count, read/written readably
                 | ...                  -- further print-edit codes: see form-spec
<len>, <dec>   ::= <integer> | <numeric-variable>   -- independently: `PD 6.PRICE_` is legal
```

The code and its width are separated by a **space that is part of the syntax**: `X2` is not `X 2`
and is not a format at all. See [form-spec](../br_tree/30-io-file/form-spec/spec.md#syntax).

**What it does:**
1. **Describes a record or print line as an ordered list of fields** — Each `<form-item>` maps the next bytes/columns of the buffer to the next variable in the I/O statement's list.
2. **Is referenced, not executed** — A FORM is a *non-executable* line invoked by `USING <line-ref>` on `READ`/`REREAD`/`WRITE`/`REWRITE`/`RESTORE` (record I/O) or `PRINT`/`PRINT FIELDS` (screen/print). Control never "falls into" a FORM line at run time.
3. **Drives both encode and decode** — On input it decodes bytes into typed variables; on output it encodes/edits values into bytes or display columns.
4. **Positions within the line** — `POS n` sets the absolute column, `X n` skips n columns forward, `SKIP n` advances n lines (print).
5. **Repeats layouts** — `n*spec` repeats a single field; `n*(...)` repeats a parenthesized group — matching a variable list or a `MAT` array.

**Semantics:**
- **One FORM, many statements** — A single FORM line can be shared by any number of I/O statements; grouping reused FORMs aids maintainability.
- **The FORM cycles** — If the variable list is longer than the FORM, BR **restarts the FORM from the beginning** and keeps consuming variables; a FORM longer than the list simply stops early. This cycling is how one short FORM drives a whole `MAT` read/write.
- **Numeric editing** — `N`/`NZ`/`PIC` control sign, decimal alignment, and zero-suppression; with the European/`INVP` option the comma and period roles interchange.
- **Character trimming** — `C` is fixed length (blank-padded); `V`/`G` are trailing-blank aware. The choice governs whether trailing spaces are stored/compared.
- **String literals are output-only** — A `"text"` item prints literal text on output; on input it is skipped over (advances the column).
- **Inline FORM string** — Instead of a line reference, a statement may carry the spec inline as a string: `WRITE #1, USING "FORM C 10, N 6.2": A$, B` — identical semantics, no separate line.
- **Run-time widths** — `<len>` may be a numeric variable, so a FORM can adapt at run time (e.g., width held in `N`); so may `<dec>`, independently of the width.
- **A FORM statement is compiled when its line is read; a `USING` string is compiled when the statement runs.** One routine does both, so the same malformed text is a load-time syntax error in the first position and error **801** in the second — the program loads and ships and fails on first execution. `USING <line-ref>` additionally checks that the named line's first statement really is a FORM, answering error **707** if not. See [form-spec §when-a-form-is-compiled](../br_tree/30-io-file/form-spec/spec.md#when-a-form-is-compiled).

**Common errors:**
- ERR CONV — value/type mismatch between a FORM item and its variable (e.g., non-numeric bytes into an `N` field)
- ERR SOFLOW — a string longer than its `C`/`V` width on output
- ERR OFLOW — a number too large for its `N`/`PIC` field
- 1006 — malformed FORM item / unknown format code **in a FORM statement**, reported as the line is read
- 801 — the same, in a `USING` string, reported when the referencing statement runs
- 707 — `USING <line-ref>` names a line whose first statement is not a FORM

**Gotchas:**
1. **The FORM cycles silently** — An accidentally short FORM re-applies from the start rather than erroring; count items against your variable list.
2. **`C` keeps trailing blanks** — Use `V`/`G` (or `RTRM$`) when you don't want fixed-width padding stored or compared.
3. **Position is cumulative** — `POS`/`X`/`SKIP` change the running column; a stray `X n` shifts every field after it.
4. **Not a branch target** — A `GOTO`/`GOSUB` into a FORM line does nothing useful; FORMs are data, referenced only via `USING`.

**Example code:**
```business-rules
! Record layout shared by WRITE and READ
00100 OPEN #1: "NAME=cust.int,RECL=64,NEW", INTERNAL, OUTPUT
00110 WRITE #1, USING 900: "ACME", 1250.75, 30
00120 CLOSE #1:
00900 FORM C 20, N 10.2, N 4            ! name, balance, terms

! Repeat a group across a MAT
00200 DIM CODE$(3)*4, QTY(3)
00210 WRITE #2, USING 910: MAT CODE$, MAT QTY
00910 FORM 3*(C 4, N 6)                 ! three (code, qty) pairs

! Inline FORM string on PRINT USING (positioning + literal)
00300 PRINT USING "FORM POS 5, C 20, X 2, N 8.2": NAME$, BALANCE
```

**See also:**
- READ / REREAD / WRITE / REWRITE — record I/O statements that reference a FORM via `USING`
- PRINT — `PRINT USING` for formatted screen/printer output
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — full FORM syntax, every format code, repetition & positioning (comprehensive)
- [40-io-printing/statements](../br_tree/40-io-printing/statements/spec.md) — `PRINT USING` and print-side format codes
- [00-configuration/config-directives — OPTION table](../br_tree/00-configuration/config-directives/OPTION_(Config).md#option-table) — `INVP` and format-related toggles

---

<a id="sort"></a>
## SORT — Sort an internal file via a control file

**Syntax:**
```bnf
`SORT` [<control-file>]        -- run from READY, a PROC, or `EXECUTE "SORT <file>.SRT"`
```

Control-file specification types (in this order):

| Spec | Req | Purpose |
|---|---|---|
| `!` comment | no | message to the operator |
| `FILE` | **yes** | input/output/work files + parameters (**first**) |
| `ALTS` | no | reorder/equate the collating sequence |
| `RECORD` | no | include/omit records |
| `SUM` | no | display record counts |
| `MASK` | **yes** | define sort fields (**last**) |

**What it does:**
1. **Produces sorted output** from an internal file according to a **sort control file** of specifications
2. **Reads the control file** for the input/output/work files and the sort-field definitions
3. **Can filter** (include/omit) records, redefine the collating sequence, and report counts
4. **Emits either full records** (record-out) or an **address list** (record numbers)

**Semantics:**
- **Control file, not inline** — `SORT` is driven by a `.SRT` control file of up to six spec types in a fixed order: `FILE` (required, first), `ALTS`, `RECORD`, `SUM`, `MASK` (required, last)
- **Invoked from code** — `EXECUTE "SORT CUSTOMER.SRT"` runs it from a program; it also runs from READY or a PROC
- **FILE** — input, output, and work paths; output style `R` (full records), `A` (address-out PD3, ≤99,999 recs) or `B` (address-out B4, ≤2.147 billion); native/alternate collating; plus `REPLACE` and a share-spec
- **ALTS** — reorder or equate collating (e.g. make upper match lower, sort digits equal)
- **RECORD** — include (`I`) / omit (`O`) records by a field's value range; chain with `AND`/`OR`
- **MASK** — up to **10** sort fields, each `<pos>,<len>,<form>,{A|D}`; max total key length **32,767 bytes**; append `Y` for BASEYEAR Y2K dates
- **Index alternative** — for ordered access *without* a separate sort pass, a keyed read returns records in key order (see INDEX)

**Common errors:**
- **Missing `FILE`/`MASK`** — both are required (`FILE` first, `MASK` last)

**Gotchas:**
1. **It's a control-file command** — you don't sort inline; you write a `.SRT` spec and run it (often via `EXECUTE`)
2. **`MASK` last, `FILE` first** — the six spec types have a fixed order
3. **Address-out vs. record-out** — choose `A`/`B` to emit record numbers, `R` to emit full records
4. **Consider an index instead** — a keyed file already reads in key order without a sort pass

**Example code:**
```text
! control file CUSTOMER.SRT — TX/LA customers, record-out, replace, shared
FILE orders.int,,,samplesort2,,,,,R,,REPLACE,SHR
ALTS RO,97,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"   ! upper matches lower
RECORD I,106,2,C,"TX","TX",OR
RECORD I,106,2,C,"LA","LA",OR
SUM
MASK 31,30,C,A,1,30,C,A                   ! by field@31 then field@1, ascending
```
```business-rules
99000 EXECUTE "SORT CUSTOMER.SRT"          ! run the sort from a program
```

**See also:**
- INDEX (keyed order as an alternative to sorting)
- EXECUTE (run the SORT command from code)
- OPEN file / READ (the internal file being sorted)
- [40-io-printing/sort](../br_tree/40-io-printing/sort/spec.md) — full SORT control-file reference (comprehensive)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — keyed (index) order alternative

---

<a id="index"></a>
## INDEX — Create or rebuild a key index

**Syntax:**
```bnf
`INDEX` <master-file> <key-file> <key-positions> <key-lengths> [<work-path>]
        [`REPLACE`] [`REORG`] [`VERIFY`] [`DUPKEYS`] [`LISTDUPKEYS`]
        [`BADKEYS`] [`LISTBADKEYS`] [ `>` <output-file> ] [`NATIVE`]
```

**What it does:**
1. **Builds or rebuilds an index (key) file** for fast record access by key value
2. **Records each master record's key value plus its relative record number**
3. **Enables keyed `READ`/`REWRITE`/`DELETE`** and in-key-order sequential reads
4. **Can reorganize** an existing index without re-reading the master (`REORG`)

**Semantics:**
- **Index/key file** — holds each key value + the master's relative record number (binary `B 4`); BR binary-searches it and jumps straight to the master (no scan). Reading keyed **without** `KEY=` returns records **in key order** (a free sort)
- **Positions/lengths** — up to **6** non-contiguous split-key sections separated by `/`; total **≤128 bytes**; append `Y` for BASEYEAR (Y2K) dates (`23Y`; binary date fields `2BY`); key fields may overlap
- **`REPLACE`** fully rebuilds; **`REORG`** reorganizes the sorted primary + overflow directly (fast; does **not** add new records; fully rebuilds only if the index is missing/invalid or the key positions/lengths differ)
- **Duplicate/bad keys** — `DUPKEYS`/`LISTDUPKEYS`, `BADKEYS`/`LISTBADKEYS`; `>file` redirects the list
- **Index types** — Btree (default, self-maintaining), Btree2 (`OPTION 22`, faster shared I/O, `VERIFY` audits), ISAM (`OPTION 5 = 4`); BR **won't mix** Btree types across related files
- **Invocation** — runs from READY, a PROC, or `EXECUTE "INDEX …"`; performs an implicit `CLEAR` (unless a program is active); interruptible with `Ctrl-A` / resume with `GO`; `-N` suppresses the log; parameters separated by spaces or commas
- **Keeping it current** — keep the index open whenever you write the master, or `REORG`/`REPLACE` after batch updates

**Common errors:**
- **ERR 7611** — key file already exists (no `REPLACE`)
- **ERR 7603** — duplicate keys found (warning)
- **ERR 0718** — key string length mismatch on keyed access (`KEY=` length ≠ `KLN`)
- **ERR 4272** — NOKEY (key not found) on keyed access

**Gotchas:**
1. **Split keys use `/`** — separate up to 6 position/length sections with `/`
2. **`REORG` doesn't add records** — it sorts existing overflow into the primary area; it fully rebuilds only when necessary
3. **Rebuild after batch updates** — `EXECUTE "INDEX … REPLACE"` after mass changes keeps lookups correct
4. **Changing a key value is allowed** — a `REWRITE` may alter the key field; BR automatically updates all related key files opened as a group (the old error **0059** is deprecated)

**Example code:**
```business-rules
! Build a split-key index: name (1-20) + zip (50-54)
INDEX CUSTOMER.DAT CUSTZIP.KEY 1/50 20/5 REPLACE

! Rebuild after batch updates, from a program
99000 EXECUTE "INDEX ACCT.INT ACCT.KEY 1 4 REPLACE"

! Then open and read in key order
00410 OPEN #3: "NAME=MILES.DAT,RECL=24,KFNAME=MILES.KEY", INTERNAL, INPUT, KEYED
00420 READ #3, KEY>="070196": DATE, MILES EOF 480  ! start at a key, read onward
```

**See also:**
- OPEN file (KEYED opens use `KFNAME=`/`KPS=`/`KLN=`)
- READ / REWRITE / DELETE (keyed I/O with `KEY=`/`SEARCH=`)
- SORT (one-off sorted output as an alternative)
- EXECUTE (run the INDEX command from code)
- [30-io-file/keys-indexes](../br_tree/30-io-file/keys-indexes/spec.md) — full index & keyed-access reference (comprehensive)

---

<a id="database"></a>
## Database Operations — SQL database access via ODBC

**Syntax:**
```bnf
`EXECUTE` "`CONFIG DATABASE` <db-ref> { `DSN=`<dsn> | `CONNECTSTRING=`"<conn>" | `ODBC-MANAGER` }"
`OPEN` `#`<channel>`:` "`DATABASE=`<db-ref>"`,` `SQL` <sql-string>`,` `OUTIN`
`WRITE` `#`<channel>`:` [ <param> [`,` <param>]* ]        -- execute the bound statement (data = bind params)
`READ`  `#`<channel>`,` `USING` <form>`:` <var> [`,` <var>]* `EOF` <line-ref>   -- fetch one result row
`CLOSE` `#`<channel>`:`
```

**What it does:**
1. **Connects BR as a SQL client** to an external database (SQLite, MySQL, SQL Server, MS Access, …) over ODBC
2. **`CONFIG DATABASE`** names a connection `<db-ref>` — via a DSN, a DSN-less connection string, or the `ODBC-MANAGER` prompt; run it from code with `EXECUTE`
3. **`OPEN … DATABASE=<db-ref>, SQL <sql$>, OUTIN`** binds a channel to one SQL statement over that connection
4. **`WRITE #ch:`** (no data) executes it — `SELECT` readies the result set; `INSERT`/`UPDATE`/`DELETE` apply the change
5. **`READ #ch, USING <form>:`** fetches result rows (loop to `EOF`); a `FORM` maps result columns to variables
6. **`CLOSE #ch:`** releases the channel

**Semantics:**
- **Connection vs. channel** — configure once with `CONFIG DATABASE`, then reference by `<db-ref>` in the OPEN name-string. Requires BR **4.3+**.
- **SQL bound at OPEN** — to run a different statement, build a new string and `OPEN` a fresh channel. SQL text may instead come from a file: `OPEN #h: "DATABASE=<db-ref>,NAME=<file>", SQL, OUTIN`.
- **`WRITE` submits, `READ` fetches** — a `WRITE` must precede the first `READ` on a `SELECT`. A `WRITE` **with** a data list binds parameters in order (count must match — else error 3007/4007).
- **Columns map by FORM** — the SELECT list maps left-to-right onto the FORM fields (`C`/`N`/`PD`/dates), exactly like a native record.
- **Connection & schema discovery** — `Env$("STATUS.DATABASE.<db-ref>.CONNECTSTRING")` returns the resolved string (no brackets in the path); `STATUS.DATABASE.LIST`, `.<db-ref>.TABLES.LIST`, and `.TABLES.<table>.COLUMNS.LIST`/`.<column>.TYPE` enumerate the live schema. The `.LIST` forms load a `MAT` array via `LET Env$(…, MAT arr$)`.
- **Releasing connections** — `EXECUTE "CONFIG DATABASE CLEAR <db-ref>"` drops one configured connection; `CLEAR ALL` drops them all.
- **Client/Server** — `ODBC-MANAGER` cannot be used in Client/Server mode (it depends on the user's local ODBC settings).

**Common errors:**
- **3002–3015 / 4002–4015** — the SQL/ODBC error ranges (prepare/execute/fetch/bind failures; 3007/4007 = parameter-count mismatch; 4015 = database not opened)
- **0366** — no SQL command supplied with the submit/fetch statement
- **4270** — `EOF` on `READ` with no `EOF` clause given (normal end of result set, not a failure)

**Gotchas:**
1. **Size the SQL buffer** — `DIM C_SQL$*4096`; SQL text is long
2. **Doubled quotes** — inside a BR string, `""` is one literal `"`, so `VALUES (""EVETS"")` sends `"EVETS"`
3. **Prefer parameter binding** over concatenating operator input (injection / quoting safety)
4. **Always CLOSE** — re-opening per operation leaks ODBC handles otherwise
5. **Protect credentials** — connection strings hold `UID=`/`PWD=`; prefer `PASSWORDD=` (encrypted) or `BR_PASSWORD`/`LOGIN_NAME`

**Example code:**
```business-rules
48001 DIM C_SQL$*4096, C1$*4096, C2$*4096
48002 LET C_SQL$="SELECT firstname, lastname FROM tbl_names"
49001 EXECUTE 'CONFIG database BRG_DEMO CONNECTSTRING="DSN=BRG_DEMO;SERVER=127.0.0.1;UID=dbadmin;PWD=...;DATABASE=brg_demo;PORT=3306"'
49002 OPEN #(DB_HANDLE:=21): "DATABASE=BRG_DEMO", SQL C_SQL$, OUTIN
49003 WRITE #DB_HANDLE:                                    ! run the query
49005 RD: READ #DB_HANDLE, USING 'form POS 1,C 50,C 50': C1$, C2$ EOF DONE
49006    PRINT C1$ & "," & C2$
49007    GOTO RD
49008 DONE: CLOSE #DB_HANDLE:
```

**See also:**
- SORT / INDEX (other data-management operations)
- OPEN file / WRITE / READ / CLOSE (channel mechanics)
- EXECUTE (run the `CONFIG DATABASE` command from code)
- [30-io-file/database](../br_tree/30-io-file/database/spec.md) — full SQL/ODBC database reference (comprehensive)
- [00-configuration/config-directives](../br_tree/00-configuration/config-directives/spec.md) — the `CONFIG DATABASE` directive
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — FORM field types for mapping result columns

---

<a id="print"></a>
## PRINT — Output to screen or file (without FIELDS)

**Syntax:**
```bnf
-- unformatted --
PRINT [`#`<file-num> `:`] [<print-options>] [<print-list>]
<print-options> ::= `BELL` | `NEWPAGE` | `TAB(`<column>`)`
<print-list>    ::= <expression> [ { `;` | `,` } <expression> ]*

-- formatted --
PRINT [`#`<file-num> `:`] `USING` { <form-ref> | <string-expr> } `:` <expression-list>

-- window border and caption --
PRINT `#`<window> `,` `BORDER` [<border-spec>] [ `:` <caption> ]

-- special OPEN parameters --
OPEN `#`<channel> `:` `"` `NAME=`<printer-spec> [`,` `RECL=`<n>] [`,` `EOL=`<eol>] [`,` `COPIES=`<n>] [`,` `CONV=`<char>] [`,` `PAGEOFLOW=`<n>]`"` `,` `DISPLAY` `,` `OUTPUT`
<eol> ::= { `CR` | `CRLF` | `NONE` }
```

**What it does:**
1. **Evaluates expressions and outputs them** — to the screen (`#0`, default) or a specified file/printer channel
2. **Supports options** — `BELL` (sound beep), `NEWPAGE` (clear screen or form-feed printer), `TAB(col)` (move cursor)
3. **Redraws a window border and sets its caption** — `PRINT #<window>, BORDER [<spec>] [: <caption>]`, the run-time counterpart of `OPEN`'s `BORDER=` parameter. Written 215 times in the reference corpus and documented until now only under [OPEN … window](#open--window-)
3. **Auto-wraps** — Text beyond the screen width or printer width wraps to the next line
4. **Handles multiple types** — Numbers, strings, arrays (in row order)

**Channel numbers:**
- **`#0` or none** — Screen (default); output appears on the display
- **`#255`** — Printer (implicit open on first use); output goes to the default printer or spooler
- **`#<n>` (1–199 | 300-999)** — Normal use channel number (via `OPEN … DISPLAY`)

**Value Options** — these are **print-list items only, not expressions.** They yield no value, so
they cannot be assigned, passed, or compared: neither `LET X$ = BELL` nor `LET X = BELL` compiles.
`BELL` and `NEWPAGE` are nonetheless **reserved** words (both are declared in BR's `table7k`), so
no variable may take those spellings; `TAB` is in neither runtime table and is not reserved.

**Any `PRINT` statement may carry them, on any channel** — screen, a window, a report/printer file,
any opened display channel. The channel does not restrict *which* options are available; it only
determines what the option does.
- **`BELL`** — Sounds the bell/beep
- **`NEWPAGE`** — Starts a new page on whatever the channel is: clears a screen or window, form-feeds a printer or display file, and zeroes that channel's line counter (`LINES`). Use it as the first output of a screen section or report page. Also usable as a print *target*
- **`TAB(<col>)`** — Moves the cursor to column <col> (1-based); wraps to next line if already past col

**Value Separators:**
- **Without FORM - unformated separators** — `;` - concatenate, no spacing; numbers print with automatic leading/trailing spaces; strings do not
- **`,` (comma)** — Tabs to the next **print zone**
  - Screen: 1, 24, 48 (24-char wide zones)
  - Printer: 1, 24, 48, 72, 96 (24-char wide zones)

**Output formatting without FORM:**
- **Numbers** — Print left-aligned with automatic single leading space
- **Strings** — Print as-is (no leading/trailing spaces unless in the string itself)
- **2 dimensional arrays** — Elements print in **row order** (row-major)
- **Expressions** — Evaluated before printing

**Common errors:**
- **`PAGEOFLOW`** — Page length reached on a printer file (condition, not an error); trap with `ON PAGEOFLOW`
- **`CONV`** — Data formatting error

**File position side effects:**
- On a display file, the line counter increases (used for `PAGEOFLOW`)
- On the screen, text is immediately visible

**Examples of separator behavior:**
```business-rules
! Comma (tab) separates to next zone
00100 PRINT 10, 20, 30
       ! output: "         10         20         30" (columns 1, 24, 48)

! Semicolon (concat) has no spacing
00110 PRINT "A"; "B"; "C"
       ! output: "ABC"

! Mixed separators
00120 PRINT "First",; "Second"
       ! output: "First" then tab, then "Second"

! Numbers with auto-spacing
00130 PRINT 1, 2, 3
       ! output: "          1          2          3"
```

**Gotchas:**
1. **No prompt argument** — PRINT has **no** built-in prompt (use `PRINT "prompt"` separately before `INPUT`)
2. **Zone widths are fixed** — You cannot customize the (24 char) tab stops; use `PRINT USING` or `PRINT FIELDS` for custom formatting
3. **Arrays print in row order** — 2-D arrays print left-to-right, top-to-bottom; if you need column-major, transpose manually
4. **`NEWPAGE` is not queued** — It executes immediately; put it first in the statement to clear before printing data to screen
5. **Printer redirection at runtime** — Use the `RUN` command (defaults to screen - same as `RUN >CON:`); `RUN >file` (create/overwrite), `RUN >>file` (append)
6. **Display file page counting** — `KREC` tracks line count; reset with `RESTORE #<n>:`

**Example code:**
```business-rules
! Simple screen output
00100 PRINT "Hello, World!"
00110 PRINT "A", "B", "C"                     ! comma-separated (zones)

! Printer output
00200 PRINT #255: NEWPAGE
00210 PRINT #255: "Report Title"
00220 FOR I = 1 TO 100
00230   PRINT #255: "Line", I
00240 NEXT I

! Tab positioning
00300 PRINT TAB(10); "Column 10"
00310 PRINT TAB(40); "Column 40"

! Mixed output
00400 PRINT "Count: ";
00410 FOR I = 1 TO 5
00420   PRINT I;
00430 NEXT I
00440 PRINT ""                                ! newline
```

**Special OPEN … DISPLAY Parameters**
1. **`EOL=`** - end-of-line delimiter for output: `CR`, `CRLF`, or `NONE` (display-file default is `CRLF` on Windows/DOS, `LF` on Unix/Linux)
2. **`COPIES=`** - number of spooled report images
3. **`CONV=`** - a fill character to use when a field capacity is exceeded
4. **`PAGEOFLOW=`** - number of lines before generating a page overflow error

**See also:**
- PRINT USING (formatted output with FORM spec)
- PRINT FIELDS (full-screen positioned output)
- INPUT (input from screen)
- [40-io-printing/statements](../br_tree/40-io-printing/statements/spec.md) — full PRINT / PRINT USING reference (comprehensive)
- [30-io-file/form-spec](../br_tree/30-io-file/form-spec/spec.md) — FORM/PIC layout for `PRINT USING`

---

<a id="input"></a>
## INPUT — Screen input, prompt

**Syntax:**
```bnf
INPUT <variable-list> [ `CONV` <ref> ] [ `SOFLOW` <ref> ] [ `EOF` <ref> ] [ `TIMEOUT` <ref> ]
`LINPUT` <string-variable> [ `TIMEOUT` <ref> ]
`RINPUT` <variable> [ `TIMEOUT` <ref> ]           -- any single variable (numeric or string), not a list
```

**What it does:**
1. **Plain INPUT** — Reads comma-separated values from the keyboard into a variable list; type-checked for numeric versus string
2. **LINPUT** — Reads an entire line (including commas, quotes, punctuation) into a single string variable
3. **RINPUT** — Displays the current value of a variable (numeric or string) and prompts for a replacement

**Semantics:**
- **INPUT** reads comma-separated values (like `INPUT A, B, C`)
- **Type checking** — Numerics are validated (non-numeric chars trap `CONV`); string variables accept any text
- **LINPUT** reads an entire line, preserving commas and quotes (unlike `INPUT`, which splits on commas)
- **`EOL=` (DISPLAY opens only; `FORMAT=ASYNC` is just the optional communications variant)** — When `LINPUT` reads from a `DISPLAY` file opened `INPUT` (a plain display file **or** a `FORMAT=ASYNC` communications file), the open's `EOL=` controls delimiting: `EOL=NONE` lets `LINPUT` read up to the LINPUT variable's dimensioned length (one byte at a time if `DIM X$*1`); `EOL=CRLF`/`LF` accepts and strips the delimiter. Affects `LINPUT` only — not the plain `INPUT` statement, and not INTERNAL/EXTERNAL files
- **`RECL` does not limit input** — `RECL` governs output only; `LINPUT` may read strings longer or shorter than `RECL` (provided the variable is dimensioned large enough)
- **Timeout (`WAIT=` / `TIMEOUT`)** — `INPUT`, `LINPUT`, and `RINPUT` all honor an input timeout: a `WAIT=<sec>` in effect (from the input channel's OPEN, or a `WAIT=` clause on the `FIELDS` forms) arms a `TIMEOUT` trap — **error 4145** if nothing is entered in time. `WAIT=0` = don't wait; `WAIT=-1` = wait forever (the timer resets on each keypress). Trap it with a `TIMEOUT <line-ref>` clause (otherwise `GO` re-executes the line)
- **RINPUT <var>** prints the current value of the variable and prompts for a replacement (single variable only)
- **No auto-advance** — The cursor stays at the input line until Enter is pressed
- **In INPUT mode** — The status line shows "INPUT" and the program waits for Enter
- **INPUT to a MAT*** - The array elements are each part of the variable list

**Error conditions:**
- **`CONV`** — Type mismatch (non-numeric in a numeric field)
- **`SOFLOW`** — String too long for a dimensioned string variable (truncated)
- **`TIMEOUT`** — No input entered within the `WAIT=` period (**error 4145**)

**Gotchas:**
1. **No prompt argument** — `INPUT "X", A$` does not compile; use `PRINT "X"; : INPUT A$` instead
2. **LINPUT preserves delimiters** — Commas and quotes are kept in the input; if you need to parse them, use `READ` with a FORM or manual string parsing
3. **RINPUT is rarely used** — `RINPUT FIELDS` is preferred for data entry because it provides formatting and validation
4. **Type checking is strict** — Non-numeric input in a numeric field immediately errors; the user must correct it
5. **Variable list order** — `INPUT A, B, C` reads values in comma-separated order; if the user enters fewer values, an error is generated
6. **LINPUT to a MAT** — Not alloed

**Example code:**
```business-rules
! Simple numeric input with type checking
00100 PRINT "Enter a number: ";
00110 INPUT NUM CONV 150
00120 PRINT "You entered: ", NUM
00130 STOP
00150 PRINT "That's not a number!" : RETRY   ! CONV branches here, then re-prompts

! Multiple comma-separated values
00300 PRINT "Enter name, age, salary: ";
00310 INPUT NAME$, AGE, SALARY

! Read an entire line (including commas)
00400 PRINT "Enter data (including commas): ";
00410 LINPUT DATA$
00420 PRINT "You entered: ", DATA$

! Reverse input (display current value and prompt for change)
00500 LET AMOUNT = 100
00510 PRINT "Current amount: ";
00520 RINPUT AMOUNT
00530 PRINT "New amount: ", AMOUNT

! LINPUT from a display file
00600 OPEN #1: "NAME=data.txt", DISPLAY, INPUT
00610 DO
00620   LINPUT #1: LINE$ EOF 650
00630   PRINT "Line:", LINE$
00640 LOOP
00650 CLOSE #1:
```

**See also:**
- INPUT FIELDS (positioned full-screen entry with formatting)
- RINPUT FIELDS (display + input combined, full-screen)
- PRINT (emit prompt before INPUT)
- [20-io-screen/input-output](../br_tree/20-io-screen/input-output/spec.md) — full INPUT/LINPUT/RINPUT reference (comprehensive)
- [30-io-file/statements](../br_tree/30-io-file/statements/spec.md) — LINPUT from DISPLAY/communications files

---

<a id="open-serial"></a>
## OPEN serial — Serial communications channel

**Syntax:**
```bnf
OPEN `#`<channel> `:` <comm-open-string> `,` `DISPLAY` `,` { `INPUT` | `OUTPUT` | `OUTIN` }

<comm-open-string> ::=
  `"` `FORMAT=ASYNC` `,` `NAME=` <port-ref>
      [ `,` `BAUD=`<int> ]     [ `,` `DATABITS=`{`7`|`8`} ] [ `,` `STOPBITS=`<int> ]
      [ `,` `BUFSIZE=`<int> ]  [ `,` `RETRY=`<int> ]        [ `,` `RECL=`<int> ]
      [ `,` `WAIT=`<int> ]     [ `,` `EOL=`{`LF`|`CRLF`|`NONE`} ] [ `,` `TRANSLATE=`<table> ] `"`
    | <string-expression>

<port-ref> ::= `COM`<digit>`:`          -- Windows (colon after the digit)
             | `:/dev/tty`<int>         -- Linux / Mac (colon at the start)
```

**What it does:**
1. **Opens an RS-232 / serial port as a DISPLAY channel**
2. **Drives it with the ordinary display-file statements** — `PRINT #`, `INPUT #`, `LINPUT #`
3. **Supports `INPUT`, `OUTPUT`, or `OUTIN`** (bidirectional, e.g. a modem)
4. **Sets line parameters** (baud, data bits, stop bits, buffering, delimiters)

**Semantics:**
- **Requires `FORMAT=ASYNC` + a valid port `NAME`** — a communications file must include `FORMAT=ASYNC` and a serial-port `NAME`; the channel must be **`1–127` or `255`** (narrower than the general user range)
- **`OUTIN` for modems** — open `OUTIN` so line initialization can confirm the connection (other display files can't use `OUTIN`)
- **Defaults** — **1200 baud, 8 data bits, 1 stop bit**; `BUFSIZE`=2000; `RECL`=132 (output only)
- **`BAUD` rates** — 110/150/300/600/1200/2400/4800/9600 (Unix/Linux also 50/75/134/200/1800), plus extended 19200/38400/57600/115200 (hardware permitting)
- **`DATABITS`** — 7 or 8 (default 8); always **8** for binary files (`.BR`/`.BRO`)
- **`WAIT=`** — bounds how long to wait for a complete record before **error 4271** (incomplete record)
- **`EOL=NONE`** — use `LINPUT` (it reads to the variable's dimensioned length — one byte at a time if `DIM X$*1`)
- **Port naming by platform** — `COM2:` on Windows, `:/dev/tty…` on Linux/Mac
- **COM ports** — `COM1:`/`COM2:` are built in; `COM3`–`COM8` need a BRConfig.sys `COM` spec (else **error 4152**). The legacy `PARITY=` OPEN parameter is **not supported on 4.0+**

**Common errors:**
- **ERR 4271** — incomplete record received before `WAIT=` elapsed
- **ERR 4152** — `COM3`–`COM8` opened without a BRConfig.sys `COM` definition (file not found)

**Gotchas:**
1. **`FORMAT=ASYNC` is mandatory** — a serial OPEN without it is not a communications file
2. **Channel range is narrower** — serial channels are `1–127` (or `255`), not the full user range
3. **Use `OUTIN` for modems** — needed for line initialization / handshake
4. **`EOL=NONE` ⇒ `LINPUT`** — `INPUT` won't delimit; `LINPUT` reads to the DIM length
5. **No `PARITY=`** — intentionally unsupported on 4.0+

**Example code:**
```business-rules
! Modem on COM1 with defaults (bidirectional)
00200 OPEN #77: "NAME=COM1:,FORMAT=ASYNC", DISPLAY, OUTIN

! Explicit line settings, send a message
00250 OPEN #40: "NAME=COM2:,FORMAT=ASYNC,BAUD=2400,DATABITS=8", DISPLAY, OUTPUT
00260 PRINT #40: MESSAGE$
00270 CLOSE #40:

! Read one byte at a time with EOL=NONE
00300 OPEN #5: "NAME=COM1:,FORMAT=ASYNC,EOL=NONE", DISPLAY, INPUT
00310 DIM CH$*1
00320 LINPUT #5: CH$ EOF 350
```

**See also:**
- OPEN file / OPEN window (the other `OPEN` targets)
- PRINT / INPUT / LINPUT (drive the serial channel)
- CLOSE (release the channel)
- [30-io-file/serial-comm](../br_tree/30-io-file/serial-comm/spec.md) — full serial-comm OPEN & COM-port reference (comprehensive)
- [00-configuration/config-directives](../br_tree/00-configuration/config-directives/spec.md) — `COM` BRConfig.sys directive

---

<a id="display-menu"></a>
## DISPLAY MENU / INPUT MENU — native Windows menus

**Syntax:**
```bnf
`DISPLAY` [`#`<win>`,`] `MENU` `:` `MAT` <text$>`,` `MAT` <data$>`,` `MAT` <status$>          -- show/update a native menu
`INPUT`   `MENU` [ `TEXT` | `DATA` | `STATUS` ] `:` `MAT` <text$>[`,` `MAT` <data$>`,` `MAT` <status$>]   -- read current menu

`DISPLAY` [`#`<win>`,`] `BUTTONS` `MAT` <spec$> `:` `MAT` <caption$>                        -- the button bar
```

**What it does:**
1. **Displays a native drop-down menu bar (Windows only)** built from three parallel arrays
2. **`INPUT MENU` reads back the menu's current state** — it does **not** wait for a pick
3. **Reports the operator's choice through `MENU$` / `MENU` and `FKEY`/`KSTAT$`** — a menu click gives `KSTAT$` = 6200 and (3.92I+) `FKEY` = 98

**Semantics:**
- **Three parallel arrays** — `MAT text$` (captions; leading spaces = submenu depth; `"-"` = separator; `&` marks the accelerator key), `MAT data$` (the value returned for each item), `MAT status$` (codes below)
- **`DISPLAY MENU`** shows or updates the menu; **`INPUT MENU[ TEXT|DATA|STATUS]`** reads the current arrays (does not block — poll with `KSTAT$`, or select with `INPUT FIELDS`)
- **Result functions** — `MENU$` returns the selected item's `data$`; `MENU` returns its subscript
- **Status codes** (`MAT status$`) — `E` send FKEY 98 (item has no submenu), `P` protect/grey, `C` checkable, `X` checked (with `C`), `R` retain across program end / `CHAIN`
- **Windows only** — a character-mode / non-Windows console has no native menu bar
- **`DISPLAY BUTTONS` is the other half of DISPLAY**, and the only other keyword its syntax tree
  admits: the button bar on the top or bottom row. Each `spec$` is
  `"row,col,caption-form-spec,attributes,fkey-or-hex-scancode"` and the matching `caption$` is the
  label; `P` in the attributes greys the button. A click returns that FKEY and raises an FKEY
  interrupt, and a two-digit hex scancode (`X02`) may be given instead of a number so a clicked
  button and its key yield the same `KSTAT$`. Fully described under
  [GUI controls](../br_tree/20-io-screen/controls/spec.md#buttons), and missing from here until now

**Common errors:**
- **Expecting `INPUT MENU` to wait** — it returns immediately; a menu pick surfaces via `KSTAT$`/`FKEY`, not by blocking

**Gotchas:**
1. **Keep the three arrays parallel** — `text$`, `data$`, `status$` are indexed together; a mismatch mis-labels items
2. **`INPUT MENU` is a query, not a prompt** — read the pick from `MENU$`/`MENU` (or trap `FKEY` 98 / `KSTAT$` 6200)
3. **`R` status persists the menu** — use it to keep a menu across `CHAIN`; otherwise the menu ends with the program
4. **Windows-only feature** — guard with `ENV$("GUIMODE")`/platform checks before relying on a native menu

**Example code:**
```business-rules
! Build and show a native menu, then act on the pick
00100 DIM MTEXT$(3)*20, MDATA$(3)*8, MSTAT$(3)*4
00110 DATA "&File","  &Open","  E&xit" : READ MAT MTEXT$
00120 DATA "FILE","OPEN","EXIT"        : READ MAT MDATA$
00130 DATA "","E","E"                  : READ MAT MSTAT$
00140 DISPLAY MENU: MAT MTEXT$, MAT MDATA$, MAT MSTAT$
00150 ! … later, when KSTAT$ = 6200 / FKEY = 98:
00160 IF MENU$="EXIT" THEN GOTO DONE
```

**See also:**
- INPUT SELECT / RINPUT SELECT (full-screen FIELDS-based menu selection)
- Screen controls — COMBO / RADIO / CHECK / buttons (in-window GUI controls)
- ON condition (`ON FKEY 98` to trap a menu click)
- [20-io-screen/controls](../br_tree/20-io-screen/controls/spec.md#menus) — native-menu reference; [Display_Menu](../br_tree/20-io-screen/controls/Display_Menu.md) full grammar/examples (comprehensive)

---

<a id="open-window"></a>
## OPEN window — Bordered display windows

**Syntax:**
```bnf
OPEN `#`<channel> `:` <window-open-string> `,` `DISPLAY` `,` `OUTIN`

<window-open-string> ::=
  `"` { `SROW=`<int> `,` `SCOL=`<int> `,` `EROW=`<int> `,` `ECOL=`<int>     -- by corners
      | `SROW=`<int> `,` `SCOL=`<int> `,` `ROWS=`<int> `,` `COLS=`<int> }   -- by origin + size
      [ `,` { `ABSOLUTE` | `RELATIVE` } ]
      [ `,` `CAPTION=` [`<`|`>`] <title> ]
      [ `,` `BORDER=` <border-spec> ]
      [ `,` `PARENT=NONE` ] [ `,` `MODAL` ] [ `,` `NO_TASK_BAR` ] [ `,` `NAME=`<window-name> ]
      [ `,` `N=`<display-attr> ] [ `,` `FKEY=`<int> ]
      [ `,` `FONT=`<font> ] [ `,` `FONTSIZE=`<int>`x`<int> ] `"`
    | <string-expression>

<border-spec> ::= { `S` | `D` | `B` | `NONE` | <2-corner-chars> } [ <display-attr> ]

PRINT `#`<window> `,` `BORDER` [<border-spec>] [ `:` <caption> ]   -- (re)draw border / set caption
```

**What it does:**
1. **Opens a bordered mini-screen (window)** on a user channel as a `DISPLAY, OUTIN` device
2. **Positions it by coordinates** — `SROW`/`SCOL` (top-left) and `EROW`/`ECOL` (bottom-right), or origin + `ROWS`/`COLS`
3. **Optionally draws a border and caption**, sets a hot-window `FKEY`, or chooses font/size
4. **Directs subsequent I/O at the window** via its channel — `PRINT #w`, `PRINT #w, FIELDS …`, `INPUT #w, FIELDS …`
5. **`#0` is always the main console** (the parent), never opened this way for content

**Semantics:**
- **`DISPLAY, OUTIN`** — a window is always opened `DISPLAY, OUTIN` on a user channel; FIELDS I/O *inside* it uses the `#w,` window prefix (`PRINT #w, FIELDS …`)
- **Corners vs. size** — give the two corners (`SROW`/`SCOL`/`EROW`/`ECOL`) or an origin plus `ROWS`/`COLS`
- **Positioning** — `RELATIVE` (default) measures from the parent window `#0`'s top-left (negatives allowed → place above/left of the parent); `ABSOLUTE` measures from the screen's top-left
- **Leave room for the border** — when a `BORDER` is specified, `EROW`/`ECOL` must be **one short** of the desired edge (for the one-cell border), and end values may not precede start values
- **Borders** — `S` single/sunken, `D` double, `B` blank, `NONE`, or two custom corner characters (BR derives the rest), optional trailing display attribute; `PRINT #w, BORDER` redraws it or sets a caption (`D`/`H`/8-char specs need `OPTION 62`, 4.2+)
- **Caption** — `CAPTION=<title>` sets the top-border title; lead with `<` (flush-left) or `>` (flush-right), else centered
- **Hot windows** — `FKEY=<n>` (4.2+) makes the *whole* window clickable (fires that FKEY interrupt, usually to switch focus); inherited by child windows, but **not** independent ones
- **Independent / modal (`PARENT=NONE`)** — a top-level window not clipped to `#0` (Windows / Client-Server only, **GUI mode ON** — else **error 0877**); `MODAL` blocks `#0` until it closes; `NO_TASK_BAR` hides the taskbar icon; `NAME=` persists size/position across opens (even across sessions)
- **Console switches close windows** — toggling GUI/non-GUI closes all windows and reopens `#0`; `PRINT NEWPAGE` afterward

**Common errors:**
- **ERR 0877** — `PARENT=NONE` requested under `GUI OFF` (independent windows need GUI mode ON)
- **ERR 0868** — `PRINT BORDER` with the `S` (drop-shadow) attribute on a window not opened with `S`
- **ERR 0704** — output to a stale `PARENT=NONE` window after a GUI switch closed it (reopen first)

**Gotchas:**
1. **Leave room for the border** — with `BORDER`, set `EROW`/`ECOL` one cell short of the intended edge
2. **`RELATIVE` is the default** — coordinates are relative to `#0`, not the screen, unless you say `ABSOLUTE`
3. **`CLOSE #w` releases the window** — closing removes the window and frees the channel like any file
4. **Not the same as OPEN file** — the same `OPEN` statement, but `DISPLAY, OUTIN` + window coordinates rather than `INTERNAL`/`EXTERNAL` + a file
5. **GUI mode changes behavior** — `PARENT=NONE`, proportional fonts, and `PRINT`-vs-`FIELDS` rules differ between `GUI ON`/`OFF`

**Example code:**
```business-rules
! Bordered data-entry window with a caption
00110 OPEN #1: "SROW=5,SCOL=10,EROW=15,ECOL=60,BORDER=S,CAPTION=Data Entry", DISPLAY, OUTIN
00120 PRINT #1: NEWPAGE
00130 INPUT #1, FIELDS "2,5,C 20": NAME$
00140 CLOSE #1:

! Scrollable text box inside a window (origin + size)
00200 OPEN #10: "SROW=10,SCOL=10,ROWS=5,COLS=40", DISPLAY, OUTIN
00210 RINPUT #10, FIELDS "1,1,100/C 2000,N/W:W": TEXT$

! Independent modal window (GUI mode), caption flush-right
00300 OPEN #2: "SROW=4,SCOL=4,EROW=20,ECOL=70,PARENT=NONE,MODAL,CAPTION=>Alert", DISPLAY, OUTIN
```

**See also:**
- OPEN file (INTERNAL / EXTERNAL / DISPLAY-file opening)
- OPEN serial (serial/RS-232 communications channel)
- PRINT FIELDS / INPUT FIELDS (positioned I/O inside a window via `#w,`)
- CLOSE (release the window channel)
- INPUT SELECT / RINPUT SELECT (menus inside a window)
- [20-io-screen/windows-cursor](../br_tree/20-io-screen/windows-cursor/spec.md#open-window) — full window OPEN, borders, `PARENT=NONE`, cursor, Help facility (comprehensive)
- [20-io-screen/fields-attributes](../br_tree/20-io-screen/fields-attributes/spec.md) — border/caption display attributes
- Related cursor/keyboard *functions* (not statements): `CURROW`/`CURCOL`/`CURWINDOW`/`CURPOS`/`HELP$` — see [20-io-screen/windows-cursor](../br_tree/20-io-screen/windows-cursor/spec.md#semantics)

---

<a id="print-fields"></a>
## PRINT FIELDS — Formatted output with attributes

**Syntax:**
```bnf
PRINT [`#`<window>`,`] `FIELDS` <field-specs> `:` <expression-list>

<field-specs> ::= `"` <field-def> [ `;` <field-def> ]* `"` -- one or more fields
                | `MAT` <string-array>                          -- array of field definitions
<field-def>   ::= <row> `,` <col> `,` <format-spec> [ `,` <attributes> ]
<row> ::= 1-<scr-height>    <col> ::= 1-<scr-width>
<format-spec> ::= <string-format>[<length>] | <numeric-format> <length>[.<dec>]
                | PIC(<picture>) | FMT(<identifiers>) | DATE(<mask>)
                | TEXT <rows>/<cols>[/<capacity>] | FILTER
```

**What it does:**
1. **Positions text at specific row/column** — Places each field at an exact screen location
2. **Formats values** — Applies format codes (C=char, N=numeric, PIC=picture, DATE=date)
3. **Applies attributes** — Color, bold, underline, reverse video, etc. (if supported by terminal)
4. **Multiple fields in one spec** — Semicolon-separated (`;` in the spec string) or via `MAT` array
5. **Displays but does not accept input** — Use `INPUT FIELDS` for interactive entry

**Field definition syntax:**
- **`<row>, <col>, <format> [, <attributes>]`**
- Row: <last-screen-row>; Col: <last-screen-column>
- Format: `C <len>` (char), `N <len>[.<dec>]` (numeric), `PIC(<picture>)` (picture), `DATE <len>` (date)
- Attributes: `U` (underline), `R` (reverse), `B` (bold), `H` (highlight), etc.

**Format codes:**
- **`C <len>`** — Character (left-aligned); displays as-is
- **`N <len>[.<dec>]`** — Numeric (right-aligned, rounded); `N 10.2` = 10 chars total, 2 decimals
- **`PIC(<picture>)`** — Picture (e.g., `PIC(##,###.##)` for currency)
- **`DATE <len>`** — Date (formatted per BRConfig.sys `DATE` directive)
- **`TEXT <width>`** — Multi-line text with wrapping

**Attributes:**
- **`U`** — Underline
- **`R`** — Reverse video
- **`B`** — Bold
- **`H`** — Highlight
- **`I`** — Invisible (password masking)
- **`D`** — Dim
- And others (terminal/system-dependent)

**Semantics:**
- **PRINT FIELDS ignores control attributes** — Only monochrome/color attributes apply (U/R/B/H/I/D)
- **Format on output is plain** — An `FMT` spec on output behaves as plain `C` — no special formatting is done
- **No input** — This statement is display-only; use `INPUT FIELDS` for data entry
- **Multiple fields** — Process as a unit; each field is positioned and formatted independently

**Multiple field syntax:**
- **Semicolon-separated** — `PRINT FIELDS "5,10,C 20;10,10,N 8.2;15,10,C 30": A$, B, C$`
- **`MAT` array** — `PRINT FIELDS MAT FSPEC$: MAT VALUES` (one field def per FSPEC$ element, 
        one value per VALUES element)

**Error conditions:**
- **`CONV`** — Type mismatch between expression and format spec
- **`SOFLOW`** — String too long for field (truncated)

**Gotchas:**
1. **No input acceptance** — `PRINT FIELDS` displays values but does not prompt or accept input; use `INPUT FIELDS` for that
2. **Field overflow on N** — If a number is too large for the field, asterisks (`***`) are printed
3. **Screen positioning** — Be sure to `PRINT NEWPAGE` before a full-screen section to clear the background
4. **Mixing FIELDS and plain PRINT** — Don't mix `PRINT FIELDS` with ordinary bottom-line `PRINT` in the same screen section
5. **Field clipping** — If a field extends beyond column 80, it is silently clipped; use windowing for larger display areas

**Example code:**
```business-rules
! Simple display
00100 PRINT NEWPAGE
00110 PRINT FIELDS "1,1,C 80": "Report Title"
00120 PRINT FIELDS "3,1,C 20;3,25,C 20;3,50,C 20": "Column 1", "Column 2", "Column 3"

! Numeric with decimals
00200 PRINT FIELDS "5,10,N 8.2": 1234.56

! Picture format (currency)
00300 PRINT FIELDS "10,10,PIC($#,###.##)": 9876.54

! Multiple fields via MAT
00400 DIM FSPEC$(10)*40, VALUES$(10)*20
00410 FOR I = 1 TO 3
00420   READ MAT FSPEC$
00430   READ MAT VALUES$
00440   PRINT FIELDS MAT FSPEC$: MAT VALUES$
00450 NEXT I

! With attributes (reverse video, bold)
00500 PRINT FIELDS "10,10,C 30,RB": "Important Message"
```

**See also:**
- INPUT FIELDS (interactive full-screen entry)
- RINPUT FIELDS (display + input combined)
- PRINT (simple screen output)
- [20-io-screen/input-output](../br_tree/20-io-screen/input-output/spec.md) — full FIELDS reference (comprehensive)
- [20-io-screen/fields-attributes](../br_tree/20-io-screen/fields-attributes/spec.md) — format codes, attributes
- [20-io-screen/controls](../br_tree/20-io-screen/controls/spec.md) — buttons/grids/lists built on FIELDS

---

<a id="input-fields"></a>
## INPUT FIELDS — Formatted input with field attributes

**Syntax:**
```bnf
INPUT [`#`<window>`,`] `FIELDS` <field-specs> [`,` `ATTR` <attrs>] [`,` `HELP` <help>] `:` <io-list> [<error-cond>]

<field-specs> ::= `"` <field-def> [ `;` <field-def> ]* `"` -- one or more fields
                | `MAT` <string-array>                          -- array of field definitions
<field-def>   ::= <row> `,` <col> `,` <format> [ `,` <attributes> ]
<row> ::= 1-<scr-height>    <col> ::= 1-<scr-width>
<io-list>     ::= <variable> [`,` <variable>]*
<error-cond>  ::= `CONV` <ref> | `EXIT` <ref> | `HELP` <ref> | `SOFLOW` <ref>
```

**What it does:**
1. **Positions input fields** at specific row/column locations on the screen
2. **Accepts user entry** — Data is typed into each field; validation is performed per the format spec
3. **Applies field attributes** — Highlighting, cursor focus, auto-advance, etc.
4. **Supports multiple fields** — Processed as a unit; Tab/Enter/arrows navigate between fields
5. **Provides error trapping** — Type mismatch (`CONV`), string overflow (`SOFLOW`), Esc (`EXIT`), Help key (`HELP`)

**Field definition syntax:**
- **`<row>, <col>, <format> [, <attributes>]`**
- Row: 1–24; Col: 1–80
- Format: `C <len>` (char), `N <len>[.<dec>]` (numeric), `PIC(<picture>)` (picture)
- Attributes: `U` (underline), `A` (auto-advance), `C` (initial cursor), etc.

**Format codes (input):**
- **`C <len>`** — Character input (any text, up to <len> chars)
- **`N <len>[.<dec>]`** — Numeric input; non-numeric chars trap `CONV`
- **`PIC(<picture>)`** — Picture format (e.g., phone `PIC((###) ###-####)`)
- **`DATE <len>`** — Date input (validated per `DATE` directive)

**Control attributes (affect behavior):**
- **`A`** — Auto-advance to next field when the field is full
- **`AE`** — Auto-advance on the last field, and auto-submit (like Enter)
- **`C`** — Sets initial cursor focus to this field
- **`U`** — Underline
- **`R`** — Reverse video
- **`I`** — Invisible (password masking, input hidden with `*`)
- **`NOWAIT`** — Raise Tab instead of waiting for Enter (moves to next field immediately)

**Display attributes:**
- **`U`** — Underline
- **`R`** — Reverse video
- **`B`** — Bold
- **`H`** — Highlight (inverse video or color)
- **`D`** — Dim

**Semantics:**
- **Input validation** — Type checking is performed per format; bad input triggers `CONV`
- **Field navigation** — Tab/Shift+Tab move field-to-field; Enter/arrows also move or submit
- **Auto-advance** — If `A` is set, moving to the next field when the current field is full
- **Auto-submit** — If `AE` is set on the last field, Enter auto-submits the entire form
- **Cursor focus** — The `C` attribute sets the initial cursor position
- **Attributes via `ATTR`** — The `ATTR "<attrs>"` clause applies attributes to all fields (overrides per-field attributes)

**Field windowing (4.17+):**
- **`<disp>/<format> <max>`** — Display <disp> chars but accept <max> chars
- Example: `"10,5,8/C 12,UH"` shows 8 chars but accepts 12

**Multiple field processing:**
- **Semicolon-separated** — `INPUT FIELDS "5,10,C 20;10,10,N 8.2;15,10,C 30": A$, B, C`
- **`MAT` array** — `INPUT FIELDS MAT FSPEC$: MAT A$, MAT B`
- **MAT grouping** — `INPUT FIELDS … : (MAT A$, MAT B)` alternates: A$(1), B(1), A$(2), B(2), …
- **Per-field attributes** — `ATTR MAT ATTRS$` supplies a different highlight per field

**Hot fields (clickable):**
- **Trailing fkey value** — Makes a field clickable; valid ranges are 1–128 and 1000–9999, plus **10000 = Enter** (which **yields fkey 0**)
- **`90–99` are reserved** — BR assigns them to built-in events (PgUp/PgDn/Tab/Exit/Menu/Esc); avoid them for custom hot fields
- **Hex scancodes removed** — the old `X'xx'` hex-scancode trailing attribute is gone; use numeric fkey values
- Example: `"10,10,C 20,10"` makes the field respond to F10

**Error conditions:**
- **`CONV`** — Type mismatch (non-numeric in `N` field, invalid date, etc.)
- **`SOFLOW`** — String too long for the field (truncated, field turns red)
- **`EXIT`** — Esc key pressed (cancelled by user)
- **`HELP`** — Help key pressed (F1) with per-field help defined

**Navigation keys:**
- **Tab/Shift+Tab** — Next/prev field
- **Enter** — Next field (unless NOWAIT), or submit the entire form
- **F1** — Field help (if defined)
- **Esc** — Cancel (traps `EXIT`)
- **PgUp/PgDn** — Scroll grids
- **Home/End** — Field start/end
- **Ctrl+Home/Ctrl+End** — First/last field

**Common errors:**
- ERR CONV: Non-numeric in `N` field, invalid date, type mismatch
- ERR SOFLOW: String too long for field
- ERR: Esc pressed (trapped by `EXIT`)

**Gotchas:**
1. **Type validation is strict** — Non-numeric input in `N` fields immediately triggers `CONV`; the user must correct it
2. **Field overflow** — If a user tries to type beyond the field length, the extra chars are either ignored (with `A` auto-advance) or overwrite earlier chars
3. **Cursor positioning** — After an error (e.g., `CONV`), the cursor auto-positions to the offending field; set `C` on the first field if you want a specific start point
4. **Esc cancels the form** — Pressing Esc anywhere in the form traps `EXIT` for all fields; the form is not submitted
5. **Enter submits if AE on last field** — If `AE` is set on the last field, Enter submits the entire form; otherwise it moves to the first field
6. **Grouped arrays** - Arrays may be grouped within parentheses to process their elements one from each array in the order listed, looping until all elements are processed for all arrays
7. **Grouped MAT arrays must be same length** — When using a parentesized group of arrays, all arrays in the I/O list must be the same length (else error 0106)

**Example code:**
```business-rules
! Simple single-field entry
00100 PRINT NEWPAGE
00110 INPUT FIELDS "5,10,C 30": NAME$

! Multiple fields with navigation
00200 INPUT FIELDS "5,10,C 20,U;7,10,N 8.2;9,10,C 10": CUSTNAME$, AMOUNT, ZIP$

! Auto-advance and auto-submit on last field
00300 DIM FSPEC$(3)*30
00310 DATA "5,10,C 20,A","7,10,N 8.2,A","9,10,C 10,AE"
00320 READ MAT FSPEC$
00330 INPUT FIELDS MAT FSPEC$: NAME$, AMOUNT, ZIP$ CONV 400
00340 PRINT "Data entered successfully"
00350 CONTINUE 450
00400 PRINT "Invalid entry; please re-enter"
00450 CONTINUE

! Password masking
00500 INPUT FIELDS "10,20,C 20,I": PASSWORD$

! Field with picture format
00600 INPUT FIELDS "12,15,PIC((###) ###-####)": PHONE$

! Per-field help
00700 INPUT FIELDS "5,10,C 30,U", HELP "1|Enter your name here": NAME$
```

**See also:**
- RINPUT FIELDS (display + input combined)
- INPUT SELECT (menu selection via FIELDS)
- PRINT FIELDS (display-only positioned output)
- [20-io-screen/input-output](../br_tree/20-io-screen/input-output/spec.md) — full INPUT FIELDS reference: navigation, hot fields, SELECT, MAT grouping (comprehensive)
- [20-io-screen/fields-attributes](../br_tree/20-io-screen/fields-attributes/spec.md) — formats, attributes, field help
- [20-io-screen/controls](../br_tree/20-io-screen/controls/spec.md) — combo/radio/check/grid controls

---

<a id="rinput-fields"></a>
## RINPUT FIELDS — Display current values, then accept edits

**Syntax:**
```bnf
RINPUT [`#`<window>`,`] `FIELDS` <field-specs> [`,` `ATTR` <attrs>] [`,` `HELP` <help>] `:` <io-list> [<error-cond>]

<field-specs> ::= `"` <field-def> [ `;` <field-def> ]* `"` -- one or more fields
                | `MAT` <string-array>                          -- array of field definitions
<field-def>   ::= <row> `,` <col> `,` <format> [ `,` <attributes> ]
<io-list>     ::= <variable> [`,` <variable>]*
<error-cond>  ::= `CONV` <ref> | `EXIT` <ref> | `HELP` <ref> | `SOFLOW` <ref>
```

**What it does:**
1. **"Reverse input" — PRINT + INPUT combined** — Displays each I/O variable's **current value** in its field, *then* accepts edits (unlike `INPUT FIELDS`, which doesn't initialize field content)
2. **Pre-fills editable defaults** — The operator sees existing values and can keep, modify, or replace them; whatever remains on submit is read back into the variables
3. **Same machinery as `INPUT FIELDS`** — Positioning, formats, attributes, navigation, hot fields, and error trapping are identical
4. **Provides error trapping** — Type mismatch (`CONV`), string overflow (`SOFLOW`), Esc (`EXIT`), Help key (`HELP`)

**Relationship to INPUT FIELDS:**
- **Only difference is initial field content** — `RINPUT FIELDS` seeds each field from the variable's current value; `INPUT FIELDS` shows previously initialized values
- **Everything else is shared** — Field windowing (`<disp>/<format> <max>`), `MAT` grouping, `ATTR MAT`, per-field `HELP`, multi-window field prefixes, and `NOWAIT` all behave exactly as in `INPUT FIELDS`

**RINPUT SELECT — menu selection:**
- **`RINPUT SELECT`** reuses the FIELDS machinery for **menu choice**: identical syntax with the `SELECT` keyword in place of `FIELDS`. It does **not** change field data — it sets [`CMDKEY`](../br_tree/20-io-screen/windows-cursor/spec.md) and [`CURFLD`](../br_tree/20-io-screen/windows-cursor/spec.md) to report which field/fkey the operator chose

**Semantics:**
- **Current values shown** — Each variable's value is formatted per its field spec and displayed as the starting field content
- **Edit-in-place** — The operator navigates fields (Tab/Shift+Tab/Enter/arrows) and edits; on submit, the (possibly changed) field contents are validated and read back
- **Input validation** — Type checking per format; bad input triggers `CONV`
- **Attributes via `ATTR`** — The `ATTR "<attrs>"` clause (or `ATTR MAT <attr$>`) **applies only when the field is in focus** (e.g. the cursor is in the field)
- **Always bracket with `PRINT NEWPAGE`** — Don't mix full-screen `RINPUT FIELDS` with ordinary bottom-line `PRINT`/`INPUT`

**Error conditions:**
- **`CONV`** — Type mismatch (non-numeric in `N` field, invalid date, etc.)
- **`SOFLOW`** — String too long for the field (truncated, field turns red)
- **`EXIT`** — Esc key pressed (cancelled by user)
- **`HELP`** — Help key pressed (F1) with per-field help defined

**Common errors:**
- ERR CONV: Non-numeric in `N` field, invalid date, type mismatch
- ERR SOFLOW: String too long for field
- ERR 0106: MAT arrays in the I/O list are not all the same length

**Gotchas:**
1. **Use RINPUT to edit, INPUT to enter** — Reach for `RINPUT FIELDS` when the variables already hold values the operator should review/change; use `INPUT FIELDS` for fresh entry into blank fields
2. **Current value must fit the field** — If a variable's current value is wider than the field (or display width under windowing) an error is generated; ensure the format/window can hold the seeded value
3. **Numeric formatting on seed** — A numeric variable is shown through its `N`/`PIC` format on entry; the operator edits the *formatted* text, which is re-parsed on submit
4. **Grouped MAT arrays must be same length** — As with `INPUT FIELDS`, when using a parentesized group of arrays, all `MAT`s in the I/O list must match in length (else error 0106)

**Example code:**
```business-rules
! Edit an existing record (fields pre-filled with current values)
00100 PRINT NEWPAGE
00110 READ #1, KEY=CUST_KEY$: NAME$, CREDIT_LIMIT, ZIP$ NOKEY 300
00120 RINPUT FIELDS "5,10,C 30,U;7,10,N 10.2;9,10,C 10": NAME$, CREDIT_LIMIT, ZIP$ CONV 200
00130 REWRITE #1, KEY=CUST_KEY$: NAME$, CREDIT_LIMIT, ZIP$
00140 GOTO 400
00200 PRINT "Invalid entry; please re-enter" : RETRY
00300 PRINT "Customer not found"
00400 CLOSE #1:

! MAT-driven edit form
00500 DIM FLDDEF$(3)*30
00510 DATA "8,15,C 30,A","10,15,C 40,A","14,15,C 12,AE"
00520 READ MAT FLDDEF$
00530 RINPUT FIELDS MAT FLDDEF$: NAME$, ADDR$, PHONE$

! RINPUT SELECT — highlight current choice, let operator pick another
00600 RINPUT SELECT "5,10,C 20;7,10,C 20;9,10,C 20": OPT1$, OPT2$, OPT3$
00610 PRINT "Chose field "; CURFLD; " via key "; CMDKEY
```

**See also:**
- INPUT FIELDS (entry into blank fields)
- INPUT SELECT / RINPUT SELECT (menu selection via FIELDS)
- PRINT FIELDS (display-only positioned output)
- [20-io-screen/input-output](../br_tree/20-io-screen/input-output/spec.md) — full FIELDS reference: navigation, hot fields, SELECT, MAT grouping (comprehensive)
- [20-io-screen/fields-attributes](../br_tree/20-io-screen/fields-attributes/spec.md) — formats, attributes, field help

---

<a id="input-select"></a>
## INPUT SELECT / RINPUT SELECT — Menu selection via FIELDS

**Syntax:**
```bnf
`INPUT`  [`#`<window>`,`] `SELECT` <field-specs> [`,` `ATTR` <attrs>] [`,` `HELP` <help>] `:` <io-list> [<error-cond>]
`RINPUT` [`#`<window>`,`] `SELECT` <field-specs> [`,` `ATTR` <attrs>] [`,` `HELP` <help>] `:` <io-list> [<error-cond>]

<field-specs> ::= `"` <field-def> [ `;` <field-def> ]* `"` | `MAT` <string-array>
-- abbreviations: IN S (INPUT SELECT), RI S (RINPUT SELECT)
```

**What it does:**
1. **Presents the fields as a menu** — reuses the `INPUT FIELDS` machinery, but for **choosing** a field rather than editing data
2. **Does not change field data** — no value is read into the io-list variables; the statement only records *which* field the operator picked
3. **Sets `CMDKEY` and `CURFLD`** — on a pick (Enter / a function key / a control key), `CURFLD` = the chosen field's ordinal and `CMDKEY` = the key used to confirm it
4. **`RINPUT SELECT`** first displays the current values (like `RINPUT FIELDS`), then selects; **`INPUT SELECT`** selects over already-displayed fields

**Semantics:**
- **Same field syntax as FIELDS** — identical to `INPUT FIELDS` but with the `SELECT` keyword; fields come from a `"…;…"` spec string or a `MAT` of definition strings
- **Navigation** — typing a character jumps to the next field whose first character matches (case-folded); arrows / `Tab` / `Shift+Tab` move field to field
- **Pick result** — `CURFLD` holds the selected field's ordinal (1-based); `CMDKEY` holds the key that confirmed the pick (`CMDKEY`/`CURFLD` values in [windows-cursor](../br_tree/20-io-screen/windows-cursor/spec.md))
- **`ATTR "<attrs>"`** — highlights the current field (e.g., `ATTR "R"` for reverse video); `ATTR MAT <attr$>` gives each field its own highlight
- **`HELP`** — attaches per-field help windows, shown when `USERLEVEL` ≠ 0
- **Paint first** — typically pair with `PRINT FIELDS MAT MENU$` (or use `RINPUT SELECT`) so the choices are on screen before/while selecting
- **Mode** — the status line shows **SELECT** while awaiting a choice (distinct from INPUT mode)
- **Abbreviations** — `IN S` / `RI S`

**Common errors:**
- **`EXIT`** (Esc) and **`HELP`** (Help key) — the same FIELDS error conditions apply; trap them on the statement

**Gotchas:**
1. **No data is read** — `INPUT SELECT` sets `CURFLD`/`CMDKEY` only; the io-list variables are *not* changed by the pick
2. **Display the menu first** — `INPUT SELECT` selects over existing screen fields; use `PRINT FIELDS` (or `RINPUT SELECT`) to paint them
3. **Check `CMDKEY` too** — the operator may confirm with a function key, not just Enter; branch on `CMDKEY` as well as `CURFLD`
4. **SELECT ≠ INPUT mode** — the status line reads SELECT; menu keys behave differently from data entry

**Example code:**
```business-rules
! Build a menu array and let the operator pick
00100 DIM MENU$(4)*20, FSPEC$(4)*20
00110 DATA "Add","Change","Delete","Exit"
00120 READ MAT MENU$
00130 DATA "8,20,C 20,R","10,20,C 20,R","12,20,C 20,R","14,20,C 20,R"
00140 READ MAT FSPEC$
00150 PRINT NEWPAGE
00160 PRINT FIELDS MAT FSPEC$: MAT MENU$              ! paint the choices
00170 INPUT SELECT MAT FSPEC$, ATTR "R": MAT MENU$    ! pick one (no data read)
00180 ON CURFLD GOSUB ADD, CHANGE, DELETE, DONE
00190 GOTO 150

! RINPUT SELECT — highlight current values, then reselect
00300 RINPUT SELECT "5,10,C 20;7,10,C 20": OPT1$, OPT2$
00310 PRINT "Chose field "; CURFLD; " via key "; CMDKEY
```

**See also:**
- INPUT FIELDS (data entry over fields — SELECT reuses its machinery)
- RINPUT FIELDS (display current values, then edit)
- PRINT FIELDS (paint the menu choices first)
- ON … GOTO / GOSUB (dispatch on `CURFLD`)
- [20-io-screen/input-output](../br_tree/20-io-screen/input-output/spec.md#select) — full INPUT/RINPUT SELECT reference (comprehensive)
- [20-io-screen/windows-cursor](../br_tree/20-io-screen/windows-cursor/spec.md) — `CMDKEY`/`CURFLD` values, windowed menus

---

<a id="grid-list-text"></a>
## GRID / LIST / TEXT — 2-D and multi-line controls

**Syntax:**
```bnf
`PRINT` `FIELDS` `"`<r>`,`<c>`,`{ `GRID` | `LIST` } <rows>`/`<cols>`,HEADERS`[`,`<fkey>]`"` `:` `(` `MAT` <head$>`,` `MAT` <width>`,` `MAT` <form$> `)`
`PRINT` `FIELDS` `"`<r>`,`<c>`,`{ `GRID` | `LIST` } <rows>`/`<cols>`,`{ `=` | `+` | `-` }[{ `R` | `C` | `L` | `S` }]`"` `:` `MAT` <data> | `(` `MAT` <col1>`,` … `)`
`INPUT` `FIELDS` `"`<r>`,`<c>`,`{ `GRID` | `LIST` } <rows>`/`<cols>`,`<read-type>`,`<selection>[`,`<qual>][`,`<fkey>]`"` `:` <vars>
{ `INPUT` | `RINPUT` } `FIELDS` `"`<r>`,`<c>`,TEXT` <rows>`/`<cols>`/`<maxchar>[`,`<attrs>]`"` `:` <var$>   -- multi-line text box
```

**What it does:**
1. **`GRID`/`LIST`** — a two-dimensional table control; `GRID` is **editable**, `LIST` is **read-only selection**
2. **`TEXT`** — a multi-line word-wrapping text box read/edited through one string variable
3. **Populates from parallel MATs and reads back rows/cells/selections** via *read-types* and *selection* qualifiers

**Semantics:**
- **Always send `HEADERS` first** — `(MAT headings$, MAT widths, MAT forms$)` defines the columns; then populate the body with `=` (replace) / `+` (append) / `-` (insert, 4.16+)
- **Populate flags** — after `=`/`+`/`-`, a secondary letter: `R` row-at-a-time (default), `C` column-at-a-time, `L` fire the FKEY/Enter interrupt when the operator pages past the first/last row, `S` single-click activates (4.17+)
- **Read-types (`INPUT FIELDS`)** — `ROWCNT`, `ROWSUB`, `ROW`, `CELL`, `CHG` (grid: rows edited since the last `=`); `COLCNT` = columns defined by HEADERS. **Selections** — `SEL`, `ALL`, `CUR`, `RANGE`, `CELL_RANGE`; the `DISPLAYED_ORDER` qualifier (4.30+, with `ALL`) returns on-screen order. Cell subscript = `(row-1)*cols + col`
- **`RINPUT` does not work with 2-D controls** — use `PRINT FIELDS` to populate + `INPUT FIELDS` to read
- **Column behavior** — clicking a header sorts (display only; file order unchanged; `NOSORT`/`^nosort` suppress); **zero-width columns** are *hidden* (stash record numbers/keys); `CURROW`/`CURCOL` give the active cell
- **Programmatic ops** — `SORT` (`PRINT FIELDS "…,SORT": colnum`, repeat to reverse), `SORT_ORDER` read-type, `MASK`/`FILTER` to filter rows, `ATTR` range override to shade/protect cells; sorting is aggregate (stable) and numeric/DATE-aware
- **`TEXT` box** — dimension the variable to at least `<maxchar>` (e.g., `DIM BUFF$*2048`); it word-wraps `<cols>` wide over `<rows>` lines

**Common errors:**
- **`RINPUT` on a GRID/LIST** — not supported; the pattern is `PRINT FIELDS` (populate) then `INPUT FIELDS` (read)
- **Body sent before `HEADERS`** — populate flags have no column definitions to align to

**Gotchas:**
1. **HEADERS before data, every time** — the three header MATs (`headings$`, `widths`, `forms$`) must be parallel and sent first
2. **`GRID` edits, `LIST` selects** — pick the control by whether the operator should change cells or just choose rows
3. **Hidden columns for keys** — give a column zero width to carry a record number/key the operator never sees
4. **Size the TEXT variable** — `TEXT 14/58/2000` needs `DIM BUFF$*2000` (at least `<maxchar>`) or input is truncated

**Example code:**
```business-rules
! Grid: headers first, then column data
00310 PRINT FIELDS "5,10,GRID 15/70,HEADERS": (MAT HEADERS$, MAT WIDTHS, MAT FORMS$)
00430 PRINT FIELDS "5,10,GRID 15/70,=": (MAT NAMES$, MAT CITIES$, MAT AGES, MAT WEIGHTS)
00510 INPUT FIELDS "5,10,GRID 15/70,ROWCNT,CHG": CHANGED_ROWS   ! read count of edited rows

! Read-only list, single-click select, dispatch on FKEY
00600 PRINT FIELDS "3,3,LIST 10/40,=S": MAT OPTIONS$
00610 INPUT FIELDS "3,3,LIST 10/40,ROWSUB,SEL": PICK

! Multi-line text box
00700 DIM BUFF$*2048
00710 RINPUT #0, FIELDS "5,2,TEXT 14/58/2000,[D]S": BUFF$
```

**See also:**
- Screen controls — COMBO / RADIO / CHECK / buttons (1-D controls on FIELDS)
- PRINT FIELDS / INPUT FIELDS (the underlying positioned-I/O statements)
- DIM (dimension the TEXT-box string variable)
- [20-io-screen/controls](../br_tree/20-io-screen/controls/spec.md#grid-list) — full 2-D control reference; [Grid_and_List](../br_tree/20-io-screen/controls/Grid_and_List.md) deep reference (comprehensive)
- [10-language/data-manipulation/system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md#screen-query) — `NXTFLD`/`NXTROW`/`CURTAB`/`KSTAT$` for 2-D clicks

---

<a id="screen-controls"></a>
## Screen controls — COMBO / RADIO / CHECK / buttons

**Syntax:**
```bnf
`PRINT`  `FIELDS` `"`<r>`,`<c>[`,`<disp>`/`]`COMBO` <data-cols>`,`{ `=` | `+` | `-` }[`,SELECT`][`,`<fkey>]`"` `:` `MAT` <list$>
`INPUT`  `FIELDS` `"`<r>`,`<c>[`,`<disp>`/`]`COMBO` <data-cols>[`,`<attrs>]`"` `:` <var>
{ `PRINT` | `INPUT` | `RINPUT` } `FIELDS` `"`<r>`,`<c>`,RADIO` <cols>[`,`<group>][<attrs>][`,`<fkey>][`,NOWAIT`]`"` `:` `"`[`^`]<caption>`"`
{ `PRINT` | `INPUT` | `RINPUT` } `FIELDS` `"`<r>`,`<c>`,CHECK` <cols>[<attrs>][`,`<fkey>][`,NOWAIT`]`"` `:` `"`[`^`]<caption>`"`
`PRINT`  `FIELDS` `"`<r>`,`<c>`,CC` <cols>`,,B`<fkey>`"` `:` `"`<caption>`"`        -- Print-Fields button (anywhere)
`DISPLAY` `BUTTONS` `MAT` <specs$> `:` `MAT` <captions$>                     -- button-bar buttons
… `FIELDS` `"`<r>`,`<c>`,DATE`[`,`<attrs>]`"` `:` <date>                     -- DATE field → date picker
{ `PRINT` | `INPUT` | `RINPUT` } `FIELDS` `"`<r>`,`<c>`,`{ `P` | `PICTURE` } <rows>`/`<cols>[`,`<fkey>][`:`{ `NORESIZE` | `TILE` | `ISOTROPIC` }]`"` `:` <filename$>
```

**What it does:**
1. **Puts a GUI control on the screen built from a `FIELDS` spec** — combo box, radio button, check box, button, date picker, or picture/image field — sharing the `FIELDS` statement/attribute machinery
2. **Reads the operator's interaction back through `FKEY`** — a click or selection fires the field's trailing `fkey` and sets the `FKEY` system variable; the program tests `FKEY` to dispatch
3. **Uses the three FIELDS verbs by role** — `PRINT FIELDS` displays/populates, `INPUT FIELDS` accepts, `RINPUT FIELDS` shows the current state *and* accepts a change

**Semantics:**
- **Combo box** — really a text field (implied `Q` dropdown) plus a drop-down list. `PRINT FIELDS "…COMBO cols,{=|+|-}…": MAT list$` fills the drop-down (`=` replace / `+` append / `-` insert); `INPUT`/`RINPUT FIELDS` reads the *text field* (so combos group into one `RINPUT` with other fields). `SELECT` (4.20+) restricts to drop-down choices only and **must** be set when the combo is *created*. Combos are **single-column** (multi-column → use the `Q` attribute with a `LIST` in a child window)
- **Radio buttons** — mutually exclusive within a **group** (the number after `cols`); the selected caption is prefixed `^` — test `X$(1:1)="^"`. `RINPUT` shows and updates the selection
- **Check boxes** — like radio buttons but **independent** (not grouped); each stores its state as a leading `^`. Verbs differ: `PRINT FIELDS` shows label+box (no selection), `INPUT FIELDS` shows the box only (pair with a `PRINT FIELDS` label), `RINPUT FIELDS` shows both and allows selection
- **`fkey` / `NOWAIT`** — a trailing `fkey` fires on selection/click (radio, check, combo); `NOWAIT` is the `G` attribute (return control immediately without waiting) — commonly looped until a Done button
- **Buttons** — *Print-Fields buttons* (`CC cols,,B<fkey>`, 4.2+) can go anywhere and set `FKEY` to the given number (test `FKEY` for Done/OK/Cancel). *Display buttons* (`DISPLAY BUTTONS`) sit on the button bar; each spec is `"row,col,caption-spec,attributes,fkey"` and a click raises that FKEY interrupt (`P` in the attributes greys the button)
- **Date picker** — appears on a `DATE` field; the `DATE {ALWAYS|INVALID|NEVER}` config statement controls when (default `INVALID` = only when the date's days-value is 0), or force it with the `^DATE_PICKER` leading attribute. `Ctrl-DownArrow` opens it (also opens a combo); inside, `Shift-PgUp/PgDn` = prev/next month, `Ctrl-PgUp/PgDn` = prev/next year
- **Picture / image field** — `P` (or `PICTURE`) `rows/cols` displays an image file via `PRINT`/`INPUT`/`RINPUT FIELDS`; the io-string holds the **filename**, a trailing `,<fkey>` makes it clickable (returns that FKEY), and `:NORESIZE|TILE|ISOTROPIC` control sizing. Many formats (JPG/PNG/BMP/GIF/TIFF/…); an image can also be a window's `NEWPAGE` background (`SCREEN OPENDFLT … Picture=` / `OPEN #0: "…Picture=…"`)
- **`^` is the selection sentinel** — radio/check state and the combo default all travel as a leading `^` in the caption/value string

**Common errors:**
- **Adding `SELECT` to an existing combo** — raises an error; `SELECT` may only be given at creation
- **Reading a control before painting it** — `INPUT FIELDS` over a combo/check that was never `PRINT FIELDS`-populated has no list/box to show

**Gotchas:**
1. **Test `FKEY`, not the data** — a button/click communicates through `FKEY`; the io-list value is secondary (or, for buttons, unused)
2. **Loop the interaction** — controls with `NOWAIT`/`fkey` return immediately; wrap them in a `DO … LOOP WHILE FKEY~=<done>` (see the check-box example)
3. **Combo reads the text field** — the value you get back is what's in the text portion, not necessarily a drop-down row; use `SELECT` to force a list choice
4. **`INPUT FIELDS` check box shows no label** — supply the caption with a separate `PRINT FIELDS`, or use `RINPUT FIELDS`

**Example code:**
```business-rules
! Combo: populate the drop-down, then read the text field
00100 DIM STATES$(3)*2 : DATA "CA","NY","TX" : READ MAT STATES$
00110 PRINT FIELDS "5,10,COMBO 4,=,SELECT": MAT STATES$   ! fill list (choose-only)
00120 INPUT FIELDS "5,10,COMBO 4": ST$                    ! read the picked value

! Radio group + Print-Fields button, dispatched on FKEY
00180 PRINT FIELDS "23,30,CC 8,,B99": "Done"
00190 DO
00200   RINPUT FIELDS "13,5,RADIO 10,2,8;14,5,RADIO 7,2,9": X$, Y$
00210 LOOP WHILE FKEY~=99

! Check boxes looped until a done key
00400 RINPUT FIELDS "1,1,CHECK 8,,10;2,1,CHECK 8,,11": X$, Y$
00410 IF X$(1:1)="^" THEN PRINT "box 1 checked"

! Date picker on a DATE field, and a clickable image
00500 RINPUT FIELDS "8,20,DATE": SHIP_DATE       ! Ctrl-DownArrow opens the picker
00510 PRINT FIELDS "2,2,PICTURE 6/20,77:ISOTROPIC": "logo.png"   ! clickable → FKEY 77
```

**See also:**
- INPUT FIELDS / RINPUT FIELDS (the underlying positioned-I/O statements)
- PRINT FIELDS (populate combos / draw buttons and labels)
- GRID / LIST / TEXT (2-D and multi-line controls)
- ON condition (`ON FKEY <n>` traps for hot controls/buttons)
- [20-io-screen/controls](../br_tree/20-io-screen/controls/spec.md) — full control reference: combo/radio/check/buttons, date picker, picture fields (comprehensive)
- [20-io-screen/fields-attributes](../br_tree/20-io-screen/fields-attributes/spec.md) — formats/attributes the controls carry

---

<a id="option"></a>
## OPTION — program options and array base

**Syntax:**
```bnf
[<line-number>] `OPTION` <option-clause> [ `,` <option-clause> ]*
<option-clause> ::= `BASE` { `0` | `1` }                              -- array subscript lower bound
                  | `PRTZO` <1..128>                                  -- print-zone width
                  | `INVP`                                            -- European decimal/comma
                  | `COLLATE` { `NATIVE` | `ALTERNATE` | `EBCIDIC` }   -- string comparison order
                  | `RETAIN`                                          -- resident library keeps its variables
```

**The roster is closed and is these five.** `OPTION` has no syntax tree: `OPTION_PRI`
(command5.cpp, reached through `syntxfn2`) tokenizes each word, resolves it through **table4k**, and
switches on the table4v token value, with `default: goto SYNTAX_ERR`. `EBCIDIC` is table4k's own
spelling of that keyword.

**What it does:**
1. **Sets program-wide language options** — `OPTION` changes how the *current program* interprets certain constructs; it is a directive, not a computation.
2. **`OPTION BASE 0 | 1`** — Selects the lower bound for array subscripts: `1` (default) makes arrays 1-based; `0` makes them 0-based. Governs every `DIM` that follows.
3. **`OPTION PRTZO <n>`** — Sets the print-zone width the `,` separator in a print list advances to, 1 to 128 (default 24).
4. **`OPTION INVP`** — Inverts the roles of `.` and `,` in the `PIC`, `N`, `NZ`, `L`, `G` and `GZ` format specifications and in `INPUT FIELDS`, for European number entry and display.
5. **`OPTION COLLATE NATIVE | ALTERNATE | EBCIDIC`** — Chooses the collating sequence used by string relational operators: `NATIVE` (the platform/character-set order — e.g. ASCII, digits before letters), `ALTERNATE` (digits after letters) or `EBCIDIC` (EBCDIC order).
6. **`OPTION RETAIN`** — A RESIDENT library keeps its variables across unloads.

**Semantics:**
- **Two faces of OPTION** — This topic covers the *program statement* `OPTION` (a small set of language toggles). The name `OPTION` is also the large family of **numbered configuration toggles** (`OPTION 1`…`OPTION 99`) set in `BRConfig.sys` or at run time via `EXECUTE "CONFIG OPTION n"` — those are *configuration*, not program statements. See the br_tree OPTION table for the full 0–99 list.
- **Position-independent and program-wide** — `OPTION` is a non-executable directive processed before the run, so it may appear on **any line, anywhere in the program**, and its effect applies to the **entire program** regardless of where it sits (like `DIM`). There is no "before/after" ordering relative to the `DIM`s it governs.
- **Must stand alone on its line** — `OPTION` cannot share a line with other statements (no `:` statement-compounding); it occupies its own line.
- **Scope is the program** — Options apply to the program unit that declares them; a chained or loaded program re-establishes its own options.

**Common errors:**
- **1100** `BRENOMULTICLAUSE` — `OPTION` combined with another statement on the same line (it must stand alone). Raised on a *prior* clause, so it is the second statement's line that is refused
- **1006** `WBEBADSYNTAX` — a word that is not one of the five, a `BASE` other than 0 or 1, or a `PRTZO` outside 1–128
- **1022** `BREMISSINGKEYWORD` — `COLLATE` followed by anything but `NATIVE`, `ALTERNATE` or `EBCIDIC`
- **1152** `BRESTMTATRUNTIME` — an `OPTION` compiled while a program is active

**Gotchas:**
1. **`OPTION BASE 0` changes element counts** — `DIM A(10)` under base 0 has **11** elements (0–10); code that assumes 1-based indexing can silently misbehave.
2. **Statement vs. config** — Don't confuse the language `OPTION BASE`/`COLLATE` with the numbered `OPTION n` configuration toggles; only the former is a program statement. `INVP` and `COLLATE` are *both*, reaching the same setting from either side.
3. **Applies program-wide, not from its position** — Unlike an executable statement, `OPTION` affects the whole program no matter where the line appears; conventionally placed at the top for readability, but that is style, not a requirement.

**Example code:**
```business-rules
! 0-based arrays and alternate collation
00100 OPTION BASE 0, COLLATE ALTERNATE
00110 DIM SCORES(10)            ! indices 0..10 → 11 elements
00120 IF "1" < "A" THEN PRINT "digits collate before letters"
```

**See also:**
- DIM / MAT — `OPTION BASE` governs array lower bound and element counts
- EXECUTE — run-time `EXECUTE "CONFIG OPTION n"` sets the numbered config toggles
- [10-language/data-manipulation/declaration — OPTION](../br_tree/10-language/data-manipulation/declaration/spec.md#option) — OPTION BASE/COLLATE/decimal-format language statement (comprehensive)
- [00-configuration/config-directives — OPTION table](../br_tree/00-configuration/config-directives/OPTION_(Config).md#option-table) — the full 0–99 numbered configuration toggles

---

<a id="dim"></a>
## DIM — Variable and array declaration, multi-dimensionality

**Syntax:**
```bnf
`DIM` <variable-list>
<variable-list>        ::= <variable-declaration> [`,` <variable-declaration>]*
<variable-declaration> ::= <numeric-variable>
                         | <string-variable> `*` <max-length>
                         | <array-declaration>
<array-declaration>    ::= <array-name> `(` <dimension> [`,` <dimension>]* `)` [`*` <max-length>]
<dimension>            ::= <integer>

`MAT` <array> `(` <dimension> [`,` <dimension>]* `)` -- redimension at runtime
```

**What it does:**
1. **DIM** — Declares storage for variables and arrays (non-executable; processed before the run)
2. **Sets maximum string length** — `DIM NAME$*30` declares a string with maximum 30 characters
3. **Declares arrays** — `DIM ARR(100)` declares a 1-D array; `DIM MAT(10,10)` declares 2-D
4. **Multi-dimensional arrays** — Up to 7 dimensions; syntax `DIM X(d1, d2, …, d7)`
5. **String arrays** — `DIM NAMES$(100)*30` declares 100 strings, each up to 30 characters
6. **MAT redimensioning** — `MAT ARRAY(new-size)` resizes an array at runtime, preserving existing values when growing, or losing the truncated portion when shrinking. **Not to be confused with a sub-array**: `MAT A(5)` resizes A to five elements, `MAT A(1:5)` *names* five of them — see [MAT](#mat--whole-array-assignment-operations)

**Semantics:**
- **DIM is Non-executable** — DIM is processed before the run; it can appear anywhere (beginning, middle, or end)
- **Implicit declaration** — Variables used without DIM are implicitly declared on first use
- **Identifier naming** — **`_` counts as a letter** for naming: names are 1–30 chars of letters, digits and `_`, and may **begin** with `_` (`_a = 1` is valid; a name of nothing but underscores, `_`, is valid too). The same rule covers **line labels**. Not a reserved word, and never an `FN…` name (reserved for user-defined functions). *The wiki says names must begin with a letter — it is wrong; the runtime accepts these.*
- **Case-insensitive** — `NAME$` and `name$` are the same variable
- **Type/shape coexistence** — One identifier can name **four distinct variables** at once — numeric scalar, numeric array, string scalar, string array: `A`, `MAT A`, `A$`, `MAT A$`
- **Auto-dimension** — Arrays of ≤10 elements are auto-dimensioned to 10 without explicit DIM
- **1-based by default** — Arrays are 1-based (first element is index 1); use `OPTION BASE 0` for 0-based indexing
- **Default initialization** — Numeric variables and arrays default to 0; string variables default to empty strings
- **Persistence/clearing** — Values persist until reassigned or cleared by `CLEAR`, `RUN`, `LOAD`, `CHAIN`, or program exit
- **String size limit** — 99,999,999 bytes (**4.30+**; previously 512 KB)
- **Multiple dimensions** — Up to 7 dimensions; elements are contiguous (row-major order)

**String variables:**
- **`DIM NAME$*30`** — Declares a string with maximum length 30 (default is 18)
- **Actual length** — The string can be shorter; use `LEN(NAME$)` to get the current length

**Array declarations:**
- **`DIM ARR(100)`** — 1-D numeric array (100 elements, 1–100)
- **`DIM MATRIX(5,10)`** — 2-D array (5 rows, 10 columns; 50 total elements)
- **`DIM CUBE(3,4,5)`** — 3-D array (60 total elements)
- **`DIM NAMES$(50)*20`** — Array of 50 strings, each up to 20 characters

**`OPTION BASE` statement:**
- **`OPTION BASE 0`** — Makes arrays 0-based (first element is index 0)
- **`OPTION BASE 1`** (default) — Arrays are 1-based (first element is index 1)
- **Must appear at program start** — Affects all subsequent DIM declarations

**`DIMONLY` configuration:**
- **BRConfig.sys / CONFIG setting** — Forbids creating a variable during editing unless it was declared in a DIM
- **Discipline aid** — Helps prevent typo-variables

**Redimensioning with MAT:**
- **executable** - must be executed to affect
- **`MAT ARRAY(200)`** — Grow array ARRAY from 100 to 200 (existing values preserved)
- **`MAT ARRAY(50)`** — Shrink array to 50 (values beyond 50 are lost)
- **`MAT ARRAY(10,10) = ARRAY`** — Reshape 1-D array to 2-D (size must match)
- **Element length cannot change** — You cannot re-`DIM` element length

**Multi-dimensional indexing:**
- **Row-major order** — Elements are stored left-to-right, top-to-bottom (innermost index varies fastest)
- **Example:** `MATRIX(i,j)` accesses row i, column j

**Common errors:**
- **Dimension mismatch** — Using wrong number of subscripts (e.g., `MATRIX(5)` instead of `MATRIX(i,j)`)
- **Index out of range** — Subscript greater than the declared max

**Gotchas:**
1. **Auto-dimension limit** — Arrays of other than 10 elements must be explicitly DIM'd; auto-dimension only works for 10
2. **Default base is 1** — The first element is index 1 (not 0); use `OPTION BASE 0` if you need 0-based indexing
3. **String array element length** — When DIM'ing a string array, the element length applies to all elements (e.g., `DIM NAMES$(50)*20` means each element is up to 20 chars)

**Example code:**
```business-rules
! Basic declarations
00100 DIM NAME$*30, AMOUNT, SCORES(100), MATRIX(10,10)

! String with max length
00110 DIM LONG_MESSAGE$*80      ! up to 80 chars

! Array of strings
00120 DIM NAMES$(100)*30        ! 100 strings, each up to 30 chars

! Multi-dimensional
00130 DIM OFFICE_COUNTS(40,5)   ! 40×5 matrix
00140 DIM TEMPERATURES(99,99,24) ! 3-D array (lat, lon, hour)

! 0-based indexing
00150 OPTION BASE 0
00160 DIM ARR(10)               ! indices 0–10 (11 elements)

! Redimension at runtime
00170 MAT SCORES(200)           ! grow from 100 to 200
00180 MAT SCORES(50)            ! shrink to 50
00190 MAT ARR(10,10) = ARR      ! reshape to 2-D

! Auto-dimension (no DIM needed)
00200 A(5) = 100               ! implicitly DIM A(10)
```

**See also:**
- [10-language/data-manipulation/declaration](../br_tree/10-language/data-manipulation/declaration/spec.md) — full DIM / array / redimension reference (comprehensive)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md) — LET, MAT copy/arithmetic
- [10-language/data-manipulation/data-types](../br_tree/10-language/data-manipulation/data-types/spec.md) — value kinds
- [10-language/data-manipulation/system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md) — UDIM, array functions

---

<a id="let"></a>
## LET — Variable assignment, multiple and compound forms

**Syntax:**
```bnf
[`LET`] <variable> `=` <expression> [ <error-condition> <line-ref> ]*
[`LET`] <variable> [`=` <variable>]* `=` <expression>          -- multiple assignment
[`LET`] <variable> { `+=` | `-=` | `*=` | `/=` } <expression>  -- compound (in-place)
[`LET`] <function-call> [ <error-condition> <line-ref> ]*      -- call a function for effect
```

**What it does:**
1. **Evaluates the right-hand expression** and stores the result in the variable
2. **`LET` is optional** — `X = Y*2+Z` is an implicit `LET`, and it is optional on the call-for-effect form
   too — `fnCloseDisplayWindow` and `STR2MAT("300,400,700",MAT DEPT$,",")` both run with no `LET` written
3. **Multiple assignment** — assigns one value to several variables at once
4. **Compound operators** — update a variable in place (`+=`, `-=`, `*=`, `/=`)
5. **Function-call form** — `LET` can invoke a function for its side effect (the assignment target is optional)
6. **Trailing error-condition clause** — either form, assigned or called, `LET` written or implied, may close
   with the same `[<error-condition> <line-ref>]*` clause list any statement takes (see [ON condition](#on-condition--program-wide-condition-traps) for the roster, and the full one in error-handling)

**Semantics:**
- **Optional `LET`** — the keyword is almost always omitted; `PUMA = COUGAR` copies `COUGAR` into `PUMA`
- **Type agreement** — a numeric expression assigns to a numeric variable, a string expression (quoted / concatenated with `&`) to a string variable; strings cannot be used in arithmetic
- **Multiple assignment** — `LET SUMA = SUMB = SUMC = 0` sets all three to 0 (the rightmost value propagates leftward)
- **Compound assignment** — `LET TOTAL += AMT` is exactly `TOTAL = TOTAL + AMT`; likewise `-=`, `*=`, `/=`
- **Immediate mode** — an assignment typed **without** a line number also **prints** its result
- **Function for effect** — `LET FNSETUP(X)` runs the function and discards/uses the return; for a **library** function `LET` loads and runs it. The target is optional
- **Use `=`, not `:=`, in a `LET`** — the forced-assignment operator is for conditions/expressions (see next section)
- **Error-condition clause** — `LET VAL(F$(N)) CONV skipval` (or, with `LET` dropped, `X = 5 CONV 900`) traps a conversion failure the same way `CONV` traps it after any other statement

**Common errors:**
- **Type mismatch** — assigning a string to a numeric variable (or vice versa)
- **SOFLOW** — the string result is longer than the target's `DIM` length

**Gotchas:**
1. **`=` is overloaded** — inside a condition `=` means *comparison*, not assignment; use `:=` to assign inside a condition
2. **Multiple assignment is right-to-left** — the single RHS value is stored into every listed variable
3. **Implicit declaration** — assigning to an undeclared variable implicitly declares it (a string defaults to length 18 unless `DIM`'d)
4. **Compound ops start from the current value** — `X += 1` on a never-assigned numeric starts from 0

**Example code:**
```business-rules
00050 LET MPG = MI / GAL              ! compute and assign
00060 PUMA = COUGAR                   ! implicit LET (copy)
00070 LET SUMA = SUMB = SUMC = 0      ! multiple assignment
00080 LET TOTAL += AMT                ! compound: TOTAL = TOTAL + AMT
00090 LET COUNT -= 1                  ! decrement in place
00100 NAME$ = "ACME " & DIV$          ! string concatenation
00110 FNSETUP                          ! call a function for effect (no target)
00120 LET VAL(F$(N)) CONV skipval      ! call for effect, trapping a conversion failure
```

**See also:**
- Forced assignment (`:=`) (assign inside a condition)
- MAT (whole-array assignment)
- IF / THEN / ELSE (`=` as comparison)
- ON condition (the trailing error-condition clause's roster)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#let) — full LET / assignment reference (comprehensive)
- [10-language/data-manipulation/expressions](../br_tree/10-language/data-manipulation/expressions/spec.md) — operators forming the RHS
- [10-language/data-manipulation/data-types](../br_tree/10-language/data-manipulation/data-types/spec.md) — value kinds being assigned
- [10-language/flow-control/error-handling](../br_tree/10-language/flow-control/error-handling/spec.md#conditions) — the error-condition roster and clause repetition rule

---

<a id="forced-assignment"></a>
## Forced assignment — assign inside a condition

**Syntax:**
```bnf
<variable> `:=` <expression>
```

**What it does:**
1. **Always performs assignment** — even in a context where a plain `=` would mean "is equal to"
2. **Evaluates the RHS, assigns it, and yields the assigned value** as the expression's result
3. **Enables assign-and-test** — capture a value and test it in a single step (loops, guards)

**Semantics:**
- **Distinct from `=`** — a plain `=` inside `IF`/`WHILE`/`UNTIL` is a **comparison**; `:=` forces the store
- **Yields the value** — the whole `X := <expr>` evaluates to the assigned value, so it can nest inside a larger expression
- **Parenthesize in conditions** — write `(X := <expr>)` so the assignment happens first, then its result is compared
- **Numeric and string** — works for both variable kinds
- **Not idiomatic in `LET`** — inside a plain assignment use `=`; reserve `:=` for conditions/expressions (precedence is in the expressions spec)

| Context | `=` means | `:=` means |
|---|---|---|
| `LET X = 5` | assignment | not idiomatic — use `=` |
| `IF X = 5 THEN` | comparison (is X = 5?) | n/a |
| `IF (X := 5) > 2 THEN` | compares X to 5 | assigns 5 to X, then tests 5 > 2 (true) |

**Gotchas:**
1. **Parenthesize the assignment** — `IF X := 5 > 2` may not group as intended; write `IF (X := 5) > 2`
2. **Don't use it in a `LET`** — `LET X := 5` is non-idiomatic; use `LET X = 5`
3. **Hidden side effect** — assign-and-test changes state inside a test; comment it for clarity

**Example code:**
```business-rules
! Assign-and-test: decrement inside the loop test
00150 LET N = 5
00160 DO WHILE (N := N - 1) > 0
00170   PRINT N
00180 LOOP

! Capture and compare in one step
00200 IF (BAL := BAL - FEE) < 0 THEN PRINT "Overdrawn"
```

**See also:**
- LET (plain `=` assignment)
- IF / THEN / ELSE (`=` comparison vs `:=` assignment)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#forced-assignment) — full forced-assignment reference (comprehensive)
- [10-language/data-manipulation/expressions](../br_tree/10-language/data-manipulation/expressions/spec.md#forced-assignment) — `:=` precedence

---

<a id="mat"></a>
## MAT — Whole-array assignment operations

> **Distinct from `MAT` redimensioning** (resizing an array — labeled "MAT (redim)"), which is covered under [DIM](#dim--variable-and-array-declaration-multi-dimensionality). This section is about moving/computing array **values**.

**Syntax:**
```bnf
`MAT` <array-ref> [ `=` <mat-rhs> ]
<array-ref> ::= <array>                                    -- the whole array
              | <array> `(` <dim> [`,` <dim>]* `)`          -- redimension (see DIM)
              | <array> `(` <first> `:` <last> `)`          -- sub-array: a run of elements
<mat-rhs>   ::= `(` <expression> `)`                        -- init every element
            | <array-ref2>                                  -- copy / copy sub-array
            | <num-array-ref2> { `+` | `-` } <num-array-ref2>  -- element-wise arithmetic
            | `(` <num-expr> `)` { `*` | `/` } <num-array-ref2>  -- scalar × array
            | `AIDX(` <array> `)` | `DIDX(` <array> `)`     -- ascending / descending sort index
<array-ref2> ::= <array> | <array> `(` <first> `:` <last> `)`   -- MAT is implied here
```

**What it does:**
1. **Operates on a whole array in one statement** — far faster than an element-by-element loop
2. **Initialize** — set every element to one value
3. **Copy** — duplicate an array or a run of its elements
4. **Element-wise arithmetic** — add/subtract arrays, or scale by a scalar
5. **Sort index** — build an index array giving sorted order (the data array is left unchanged)

**Semantics:**
- **Initialize** — `MAT A = (0)`, `MAT B$ = ("")`; the scalar **must be parenthesized**
- **Copy** — `MAT A = B`; a subarray copy `MAT A(6:10) = B` copies `B(1:5)` into `A(6:10)`
- **Arithmetic** — `MAT A = B + C` (element-wise); `MAT SAL = (1.064) * SAL` scales every element (scalar parenthesized)
- **`*` and `/` need the parenthesized scalar first** — they are only reachable from the `(<num-expr>)` form; `+` and `-` take either
- **String arrays take no operator** — a string target ends the statement after one right-hand operand, so `MAT A$ = B$` and nothing more
- **Sort index** — `MAT ORDER = AIDX(CUST$)` builds an **ascending** index; `DIDX` a descending one; `CUST$` is *not* reordered — `ORDER` holds the visiting sequence, so index into the original with it
- **Conformability** — element-wise operands must match in shape; a size mismatch errors
- **Assign vs. redimension** — `MAT A = …` moves **values** (this section); `MAT A(n)` alone **resizes** the array (see DIM)

**Sub-array references (`MAT A(first:last)`)** — the same characters that write a **substring** of a
string, on an array reference instead:

- **A `MAT` reference gets the array reading; anything else gets the substring.** What the name was
  dimensioned as does not enter into it. `A$(1:5)` is five characters of the string `A$`;
  `MAT A$(1:5)` is five elements of the array `MAT A$`. They are two different variables in BR
  (`A$` and `MAT A$`), so the two readings are not two views of one thing
- **Inside a `MAT` statement the qualifier is implied** at the target and at every right-hand array
  operand: `MAT FA$(1:5) = SP$(1:5)` is a run of elements on **both** sides, and the bare `SP$(1:5)`
  there means what `MAT SP$(1:5)` means anywhere else. A parenthesized right-hand side is an
  ordinary expression instead, so the `(1:5)` in `MAT A$ = (B$(1:5))` is a substring again
- **It aliases, it does not copy.** The reference is a temporary array descriptor over the original's
  own storage, of length `last - first + 1`, so `MAT A(6:10) = B` writes `A(6)` through `A(10)`
- **One dimension, one range.** The array must be one-dimensional and the reference must carry
  exactly one `first:last` pair; more is **error 0123** at run time, not at compile time
- **Bounds are checked at run time** — `first` and `last` must both be within the array's *current*
  size and `first <= last`, else **error 0122**. Positions are in the program's `OPTION BASE`
- **The `=` is optional**, as it is after a redimension. `MAT A(1:5)` alone compiles: it computes the
  descriptor and discards it

**Common errors:**
- **0123 array dimension conflict** — a sub-array of a multi-dimensional array, or more than one range
- **0122 invalid array element** — a sub-array bound outside the array, or `first > last`
- **Shape mismatch** — element-wise arithmetic or copy between arrays of different dimensions
- **Type mismatch** — mixing string and numeric arrays in one operation
- **0121 invalid reference to an array** — a right-hand operand that is not an array reference at all

**Gotchas:**
1. **Scalars need parentheses** — `MAT A = (0)` not `MAT A = 0`; `(1.064) * SAL` not `1.064 * SAL`
2. **Copy can reshape** — `MAT A = B` copies values and can take B's shape; `MAT A(10,10)` only resizes
3. **Sort index doesn't move data** — `AIDX`/`DIDX` return an ordering; you dereference the original array through it
4. **Not `MAT` redimensioning** — declaring/sizing is under DIM; this is value movement
5. **`(m:n)` is a redimension away from a sub-array** — `MAT A(5)` resizes A to five elements and
   `MAT A(1:5)` names five of them. The comma and the colon are the whole difference

**Example code:**
```business-rules
00100 MAT A = (0)                   ! zero every element
00110 MAT B$ = ("")                 ! blank every string element
00120 MAT A = B                     ! copy B into A
00130 MAT A = B + C                 ! element-wise sum
00140 MAT SAL = (1.064) * SAL       ! 6.4% raise to every salary
00150 MAT ORDER = AIDX(CUST$)       ! ascending sort index (CUST$ unchanged)
00160 FOR I = 1 TO UDIM(CUST$) : PRINT CUST$(ORDER(I)) : NEXT I
00170 MAT FA$(1:5) = SP$(1:5)       ! five elements, both sides — not substrings
00180 MAT A(6:10) = B               ! writes A(6)..A(10) from B(1)..B(5)
00190 READ #1: MAT LINE$(1:12)      ! a sub-array as an I/O operand
```

**See also:**
- DIM / MAT (redim) (declaring & redimensioning arrays)
- DATA / READ / RESTORE (`READ MAT` fills an array from the data table)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#mat) — full MAT-operations reference (comprehensive)
- [10-language/data-manipulation/system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md#array-functions) — `AIDX`/`DIDX`, `STR2MAT`, `SRCH`
- [10-language/data-manipulation/declaration](../br_tree/10-language/data-manipulation/declaration/spec.md#redimensioning) — `MAT` resizing

---

<a id="substring-assignment"></a>
## Substring assignment — in-place string mutation

**Syntax:**
```bnf
<string-variable> `(` <start-pos> `:` <end-pos> `)` `=` <string-expression>
```

**What it does:**
1. **Replaces part of a string in place** — a substring reference on the **left** of `=` changes those positions
2. **Supports replace, delete, insert, append, and prepend** through position idioms
3. **A slice on the right of `=` is extraction** (a string expression), not mutation

**Semantics:**
- **1-based, inclusive** — positions count from 1; `X$(2:3)` is characters 2 through 3
- **Replace** — `X$(2:3) = "23"` turns `"ABCD"` into `"A23D"`
- **Delete** — assign `""`: `Y$(2:3) = ""` turns `"ABCD"` into `"AD"`
- **Insert** — an end-pos of `0` inserts **before** start-pos: `Z$(2:0) = "123"` turns `"ABCD"` into `"A123BCD"`
- **Append** — `X$(inf:0) = …` (fastest) or `X$(inf:inf) = …`
- **Prepend** — `X$(0:0) = …` or `X$(1:0) = …`
- **Grows within `DIM`** — an insertion longer than the slice **extends** the string, but the result cannot exceed the variable's declared length
- **Extraction is separate** — `A$ = X$(2:3)` *reads* a slice (an expression); only a slice on the **left** of `=` mutates

**Common errors:**
- **SOFLOW** — the result would exceed the variable's `DIM` length
- **Position out of range** — a start position beyond the current length (except when inserting/appending)

**Gotchas:**
1. **`end-pos = 0` means insert** — `(pos:0)` inserts *before* `pos` rather than replacing
2. **`inf` marks the end** — use `inf` to mean "the end of the string" for appends
3. **`DIM` must be large enough** — grow operations raise `SOFLOW` if the declared length is too small
4. **Left vs. right of `=`** — left mutates in place; right extracts a value

**Example code:**
```business-rules
00200 LET X$ = "ABCD"
00210 X$(2:3) = "23"        ! replace   → "A23D"
00300 LET Y$ = "ABCD"
00310 Y$(2:3) = ""          ! delete    → "AD"
00400 LET Z$ = "ABCD"
00410 Z$(2:0) = "123"       ! insert    → "A123BCD"
00420 Z$(0:0) = ">>"        ! prepend   → ">>A123BCD"
00430 Z$(inf:0) = "<<"      ! append (fastest idiom)
```

**See also:**
- LET (whole-string assignment)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#substring) — full substring-mutation reference (comprehensive)
- [10-language/data-manipulation/expressions](../br_tree/10-language/data-manipulation/expressions/spec.md#concatenation) — substring *extraction* & concatenation

---

<a id="data-read-restore"></a>
## DATA / READ / RESTORE — Internal data table

> **Different statements from the file-I/O [READ](#read--record-input-keying-locking-position) and [RESTORE](#restore--reposition-file-pointer).** A `READ`/`RESTORE` **without** a `#channel` operates on the compiled-in **data table**; **with** a `#channel` they are the file-record statements. Same keywords, different behavior.
>
> **The colon tells them apart.** These channel-less forms take **no colon** — `RESTORE`,
> `RESTORE 900`, `READ A$, B$`. The file forms end in (or carry) a **required** one — `RESTORE #1:`,
> `READ #1: A$, B$`. Neither is optional in its own form, so a colon here or a missing colon there
> is a compile error.

**Syntax:**
```bnf
`DATA` <value> [`,` <value>]*
`READ` <variable-list>              -- channel-less: reads the internal data table; no colon
`READ` `MAT` <array>                -- fill a whole array from the table
`RESTORE` [<line-ref>]              -- reset the table pointer (optionally to a DATA line); no colon
```

**What it does:**
1. **`DATA`** defines an internal table of constants compiled into the program (non-executable)
2. **`READ`** (no `#channel`) pulls the next value(s) from the table into variables, advancing a pointer
3. **`READ MAT`** fills an entire array from the table in one statement
4. **`RESTORE`** resets the read pointer to the start (or to a specific `DATA` line)

**Semantics:**
- **Channel-less vs. file I/O** — the presence of a `#channel` is what distinguishes these from the record-I/O `READ`/`RESTORE`
- **Merged in line-number order** — all `DATA` lines merge into **one** table in line-number order, regardless of where they physically appear
- **Sequential pointer** — each `READ` advances the pointer; reading past the last value raises a trappable error
- **Type agreement** — a numeric variable needs a numeric `DATA` value; string values may be quoted
- **`RESTORE` re-reads** — bare `RESTORE` returns to the first value; `RESTORE <line-ref>` resets to the first `DATA` value on/after that line (re-read a subset)
- **`READ MAT`** — fills all elements of a (dimensioned) array at once; often chained with a `MAT` assignment (e.g., build a sort index with `AIDX`)
- **A value can be empty** — a `DATA` value is whatever text sits between one comma and the next, verbatim, and that can be nothing: `DATA ,ISA,GS` starts with an empty value, `DATA A,B,,` has one between the two commas together. `READ` assigns it as a null string or 0 depending on the receiving variable. A single trailing comma at the true end of the statement just ends the list — it does not add one more empty value on top of whatever the last comma already introduced.

**Common errors:**
- **Out of data** — a `READ` past the last table value
- **CONV** — a non-numeric `DATA` value read into a numeric variable

**Gotchas:**
1. **Not the file `READ`** — the channel-less form is the data table; don't confuse it with record `READ #n`
2. **`DATA` is global and merged** — ordering follows line numbers, not physical placement in the program
3. **`RESTORE` needed to re-read** — the pointer does not auto-reset; call `RESTORE` to reuse the table
4. **Keep `DATA` and `READ` types aligned** — a stray quote or comma shifts every subsequent value

**Example code:**
```business-rules
! Load a 12-element array from a DATA table
00100 DIM SPTEMP(12)
00110 DATA 6,17,38,49,66,75,93,84,77,67,42,22
00120 READ MAT SPTEMP           ! load all 12 at once
00130 RESTORE                   ! reset pointer to re-read

! Read scalars one pair at a time
00200 DATA "MON",1, "TUE",2, "WED",3
00210 FOR I = 1 TO 3
00220   READ DAY$, DAYNUM
00230   PRINT DAY$, DAYNUM
00240 NEXT I
```

**See also:**
- READ (file-record input — the `#channel` form)
- RESTORE (file-pointer reposition — the `#channel` form)
- MAT (whole-array assignment; `AIDX`/`DIDX` after `READ MAT`)
- [10-language/data-manipulation/assignment](../br_tree/10-language/data-manipulation/assignment/spec.md#data-table) — full DATA/READ/RESTORE table reference (comprehensive)

---

<a id="if-then-else"></a>
## IF / THEN / ELSE — Conditional execution

**Syntax:**
```bnf
-- single-line form (the whole IF is one program line) --
`IF` <condition> `THEN` <stmt-or-line> [`ELSE` <stmt-or-line>]
`IF` <condition> `THEN` <stmt-or-line>
   [`ELSE IF` <condition> `THEN` <stmt-or-line>]* [`ELSE` <stmt-or-line>]

-- multi-line block form (requires END IF) --
`IF` <condition> `THEN`
    <statements>
[`ELSE IF` <condition> `THEN`
    <statements>]*
[`ELSE`
    <statements>]
`END IF`

<stmt-or-line> ::= <statement> | <line-ref>          -- a bare line-ref is an implied GOTO
<condition>    ::= <numeric-expr>                     -- non-zero = true, 0 = false
                 | <expr> <rel-op> <expr> [ { `AND` | `OR` | `NOT` } <condition> ]*
<rel-op>       ::= `=`/`==` | `<>`/`><`/`~=` | `<` | `>` | `<=`/`=<` | `>=`/`=>`
```

**What it does:**
1. **Evaluates the condition(s) sequentially** — the **first** branch whose condition is true runs
2. **Runs exactly one branch** — once a true branch executes, no later `ELSE IF`/`ELSE` is considered
3. **`ELSE` is the default** — runs only when no preceding condition was true
4. **`THEN`/`ELSE` target** — a statement to run, or a bare `<line-ref>` (an implied `GOTO` to that line)
5. **`ELSE IF` chains** — adds further tested branches between the first `THEN` and the final `ELSE`

**Semantics:**
- **Single-line vs. block** — the single-line form is one program line and needs **no** `END IF`; the multi-line block form **requires** `END IF` (omitting it is a syntax error)
- **Truth values** — true = `1`, false = `0`; **any non-zero number is true**. `IF A THEN …` is an implied `IF A<>0`. A bare string cannot be a condition — use a relational expression
- **`THEN <line>` is a `GOTO`** — `IF X=1 THEN 500` jumps to line 500 (it does **not** call/return); the same goes for a bare line-ref after `ELSE`
- **Sequential evaluation** — conditions are tested top to bottom; evaluation stops at the first true branch
- **Operators** — `=`/`==`, `<>`/`><`/`~=`, `<`, `>`, `<=`/`=<`, `>=`/`=>`, combined with `AND`/`OR`/`NOT` (`~`); full precedence is in the expressions spec
- **Conditional-expression form is shared** — the same true/false test also drives the `SKIP` command (true → skip)

**Common errors:**
- **Missing `END IF`** — a multi-line `IF … THEN` (newline) block without a closing `END IF`
- **String as condition** — using a bare string where a numeric/relational condition is expected

**Gotchas:**
1. **Single-line is one line** — everything after `THEN` (and after `ELSE`) lives on the same program line; to span multiple lines, use the block form with `END IF`
2. **`ELSE` binds to the nearest `IF`** — in nested single-line `IF`s the `ELSE` associates with the closest unmatched `IF`; use the block form to disambiguate
3. **`THEN <line>` jumps, not calls** — `IF cond THEN 100` is a `GOTO`; use `THEN GOSUB 100` if you need to return
4. **Only one branch runs** — after a true branch, remaining `ELSE IF`/`ELSE` clauses never execute

**Example code:**
```business-rules
! Single-line IF with ELSE
00070 IF CHOICE = 1 THEN PRINT "Video games cost $17.99 each"
00090 IF CHOICE = 2 THEN PRINT "DVDs cost $14.00" ELSE PRINT "Item not recognized"

! THEN <line> is an implied GOTO
00100 IF EOFLAG = 1 THEN 500
00110 PRINT "more data"

! Multi-line block with ELSE IF (requires END IF)
00200 IF AGE <= 5 THEN
00210   PRINT "Kids get 50% off"
00220   LET DISCOUNT = 50
00230 ELSE IF AGE < 65 THEN
00240   LET DISCOUNT = 0
00250 ELSE
00260   PRINT "Senior discount 20%"
00270   LET DISCOUNT = 20
00280 END IF

! Compound condition
00300 IF QTY > 0 AND STATUS$ = "OPEN" THEN GOSUB ALLOCATE
```

**See also:**
- GOTO (target of a `THEN`/`ELSE` line-ref)
- ON … GOTO / GOSUB (multi-way branch on a numeric value)
- DO / LOOP (`WHILE`/`UNTIL` conditions reuse the same test)
- [10-language/data-manipulation/conditionals](../br_tree/10-language/data-manipulation/conditionals/spec.md) — full IF/THEN/ELSE/END IF reference (comprehensive)
- [10-language/data-manipulation/expressions](../br_tree/10-language/data-manipulation/expressions/spec.md) — relational/logical operators, `=` vs `:=`

---

<a id="goto"></a>
## GOTO — Unconditional branch

**Syntax:**
```bnf
`GOTO` <line-ref>
```

**What it does:**
1. **Transfers control unconditionally** to `<line-ref>` (a line number or a label)
2. **Backward jumps form loops; forward jumps skip code**
3. **No return address** — unlike `GOSUB`, `GOTO` does **not** push the call stack

**Semantics:**
- **Line reference** — `<line-ref>` is a line number (e.g., `500`) or a label (e.g., `DONE:`)
- **Target must exist** — the destination must be present before `SAVE`/`REPLACE`
- **No stack effect** — `GOTO` into or out of a loop leaves the `FLOWSTACK` unchanged; jumping out of an active `GOSUB` without `RETURN`, however, leaves that return address on the stack
- **Paired with `IF`** — `IF cond THEN GOTO line` (or the `THEN <line>` shorthand) is the basic conditional branch
- **Early loop exit** — `GOTO` is the supported way to leave a `FOR`/`NEXT` early (there is **no `EXIT FOR`** in BR)

**Common errors:**
- **Undefined line/label** — a `GOTO` to a nonexistent target fails at `SAVE`/`REPLACE`

**Gotchas:**
1. **Leaving a subroutine** — `GOTO` out of a `GOSUB` bypasses `RETURN` and does not pop the stack; repeating the pattern can overflow `FLOWSTACK`
2. **Leaving a `FOR` loop** — `GOTO` is how you exit a `FOR`/`NEXT` early; the loop variable keeps its current value
3. **Spaghetti risk** — prefer structured `DO`/`LOOP` and `IF` blocks where practical; reserve `GOTO` for early exits and error branches

**Example code:**
```business-rules
! Conditional branch with IF … THEN GOTO
00100 IF DONE = 1 THEN GOTO 300
00110 GOSUB PROCESS
00120 GOTO 100
00300 PRINT "Finished"

! Early exit from a FOR loop (no EXIT FOR in BR)
00400 FOR K = 1 TO 100
00410   IF FOUND THEN GOTO 440
00420   READ #1: K$ EOF 440
00430 NEXT K
00440 PRINT "Stopped at K ="; K
```

**See also:**
- IF / THEN / ELSE (the conditional that usually precedes a GOTO)
- ON … GOTO / GOSUB (computed multi-way GOTO)
- FOR / NEXT (use GOTO for early exit)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — full GOTO / branching reference (comprehensive)

---

<a id="on-goto-gosub"></a>
## ON … GOTO / GOSUB — Computed (indexed) branch

**Syntax:**
```bnf
`ON` <num-expr> `GOTO`  <line-ref> [`,` <line-ref>]* [`NONE` <line-ref>] [<error-condition> <line-ref>]*
`ON` <num-expr> `GOSUB` <line-ref> [`,` <line-ref>]* [`NONE` <line-ref>] [<error-condition> <line-ref>]*
```

**What it does:**
1. **Evaluates the numeric expression** and **rounds it to the nearest integer**
2. **Selects the *n*-th `<line-ref>`** (1 = first, 2 = second, …)
3. **`ON … GOTO` jumps** (no return); **`ON … GOSUB` calls** the selected subroutine and resumes after its `RETURN`
4. **Out of range** — if the value is `< 1` or beyond the list, control goes to the `NONE` target if present, otherwise **falls through** to the next line

**Semantics:**
- **Rounding, not truncation** — the index is the value rounded to the nearest integer
- **`NONE` target** — for `ON … GOTO` it is an ordinary branch; for `ON … GOSUB` the `NONE` target is itself a **GOSUB** branch (the routine there must also `RETURN`), **not** an error handler
- **Trailing error-conditions** — an `ON … GOTO`/`GOSUB` may carry trailing error-condition clauses (e.g., `ON N GOTO A, B, C IOERR 900`)
- **Dispatch idioms** — `ON … GOTO` is a **jump table**; `ON … GOSUB` is the classic **menu dispatcher** (each routine returns, then the menu loop continues)
- **Distinct from `ON ERROR` / `ON FKEY`** — those are condition/event traps; `ON <num-expr> GOTO/GOSUB` is a value-indexed branch (see GOSUB for `ON <error-cond> GOSUB` and `ON FKEY … GOSUB`)

**Common errors:**
- **Index out of range with no `NONE`** — falls through silently to the next line (a logic bug, not a runtime error); add a `NONE` target to catch it

**Gotchas:**
1. **Fall-through is silent** — without `NONE`, an out-of-range value simply continues at the next line; always provide `NONE` for menus
2. **`NONE` after `ON … GOSUB` still returns** — its routine must `RETURN`; it is not an error trap
3. **One-based** — index `1` selects the first line-ref; a value rounding to `0` or below is out of range
4. **`ON … GOTO` does not return** — use `ON … GOSUB` when each branch should come back

**Example code:**
```business-rules
! Jump table (ON … GOTO)
00200 ON DAY GOTO 500, 1000, 1500, 2000, 2500 NONE 100
00210 ! falls here only if NONE were absent and DAY out of range

! Menu dispatcher (ON … GOSUB)
00300 PRINT "1=Add, 2=Del, 3=List: ";
00310 INPUT CHOICE
00320 ON CHOICE GOSUB ADD_REC, DEL_REC, LIST_RECS NONE BAD_CHOICE
00330 GOTO 300
00700 ADD_REC:    PRINT "Add"    : RETURN
00800 DEL_REC:    PRINT "Delete" : RETURN
00900 LIST_RECS:  PRINT "List"   : RETURN
01000 BAD_CHOICE: PRINT "Invalid choice" : RETURN
```

**See also:**
- GOSUB / RETURN (`ON … GOSUB` return semantics, `ON <error-cond> GOSUB`, `ON FKEY … GOSUB`)
- GOTO (the single-target unconditional branch)
- IF / THEN / ELSE (two-way decision)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — full ON…GOTO / ON…GOSUB reference (comprehensive)

---

<a id="randomize"></a>
## RANDOMIZE — Reseed the random-number generator

**Syntax:**
```bnf
`RANDOMIZE`
```

**What it does:**
1. **Reseeds the `RND` generator from the system clock** so each program run produces a different sequence
2. **Without `RANDOMIZE`** — `RND` repeats the **same** sequence every time BR is loaded (useful for reproducible test runs)

**Semantics:**
- **No argument** — `RANDOMIZE` takes no operands
- **Run once** — typically executed a single time near program start; reseeding repeatedly is unnecessary
- **`RND` range** — `RND` returns a value in `0`–`1`; scale it for an integer range, e.g. `INT(RND*100+1)` yields 1–100

**Gotchas:**
1. **Reproducibility trade-off** — omit `RANDOMIZE` when you *want* a repeatable sequence (tests, demos); include it for genuinely varying output
2. **Not cryptographic** — `RND` is a deterministic PRNG seeded from the clock; do not use it for security-sensitive values

**Example code:**
```business-rules
! Seed once, then draw random numbers
00100 RANDOMIZE
00110 FOR I = 1 TO 5
00120   PRINT INT(RND*100+1)            ! 1–100
00130 NEXT I
```

**See also:**
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — RANDOMIZE & `RND` seeding (comprehensive)
- [10-language/data-manipulation/system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md) — `RND` and numeric functions

---

<a id="stop-end-pause-chain"></a>
## STOP / END / PAUSE / CHAIN — Program termination and interruption

**Syntax:**
```bnf
`STOP`
`END` [<num-expr>]
`PAUSE`
`CHAIN` { `"`<program>`"` | `"PROC=`<name>`"` | `"SUBPROC=`<name>`"` }
        [`,` `FILES`] [`,` `MAT` <array>]* [`,` <var>]*
```

**What it does:**
1. **`STOP`** — halts the program; it can be **resumed** with `GO` from the console
2. **`END [<num-expr>]`** — ends the program, **closes all files**, and sets the `CODE` return value (`END 12` → `CODE`=12; default 0). `END` is optional — a program auto-ends with `CODE`=0
3. **`PAUSE`** — interrupts execution so the operator can enter commands / inspect variables; `GO` resumes and restores the screen (a debugging breakpoint)
4. **`CHAIN`** — ends the current program and loads/runs **another** program, or starts a procedure

**Semantics:**
- **`STOP` vs. `END`** — `STOP` is resumable (`GO` continues at the next statement); `END` terminates and closes files. `STOP` commonly marks the end of the main line, just before the subroutine block
- **`END` return code** — `END <num-expr>` sets the `CODE` value a caller/OS can read; default 0
- **`PAUSE` is a breakpoint** — like `STOP` for inspection, but intended for interactive debugging; `GO` resumes and repaints the screen
- **`CHAIN` closes files by default** — it closes all files (except procedure files) and **resets the new program's variables**; **`FILES`** keeps files open at their current positions (pointers are *not* moved — use `RESTORE` to reposition)
- **Passing values across `CHAIN`** — trailing `MAT <array>` / `<var>` names carry those values into the chained program (dimensions need not match; the caller's values win)
- **`USE` in the chained-to program is a leftover, not a requirement** — older IBM Business BASIC programs declared the incoming names with a `USE <var-list>` statement (same item shapes as `DIM`: a plain name, `MAT name`, either with a dimension list and a `*length`); in Business Rules `USE` is accepted for compatibility and otherwise treated as a comment — nothing checks its contents against what `CHAIN` actually passed
- **`CHAIN` targets** — `"<program>"` follows the same extension search as `LOAD` (`.BR`→`.BRO`, `CHAINDFLT`); `"PROC=…"` ends the program and starts a procedure; `"SUBPROC=…"` starts a **nested** procedure without disturbing the running one

**Common errors:**
- **`CHAIN` to a missing program** — file-not-found if the named program/proc cannot be located under the extension rules
- **`RETRY`/`CONTINUE` after `STOP`** — error recovery statements do not apply to a normal `STOP`

**Gotchas:**
1. **`END` closes files; `STOP` does not** — use `STOP` when you intend to resume with `GO` and keep files open; use `END` for a clean shutdown
2. **`CHAIN` resets variables unless passed** — only the `MAT`/`var` names you list (or `FILES`) survive the chain; everything else is cleared
3. **`CHAIN … FILES` does not reposition** — open files keep their *position*; `RESTORE` if the chained program expects the top of file
4. **`PAUSE` vs. `STOP`** — both suspend and resume with `GO`; `PAUSE` is conventionally the debugging breakpoint, `STOP` the program-structure terminator
5. **`END` is optional** — falling off the end of the program auto-ends with `CODE`=0

**Example code:**
```business-rules
! STOP marks end of main line before subroutines
00100 GOSUB SETUP
00110 GOSUB PROCESS
00120 STOP
00200 SETUP:   ! ... : RETURN
00300 PROCESS: ! ... : RETURN

! END with a return code
00400 IF FATAL THEN END 12              ! CODE=12 for the caller
00410 END                               ! normal exit, CODE=0

! CHAIN to the menu, passing a value and keeping files open
00500 CHAIN "MENU", FILES, USERID$

! CHAIN to a procedure
00600 CHAIN "PROC=NIGHTLY"
```

**See also:**
- GOSUB / RETURN (`STOP` ends the main line before the subroutine block)
- IF / THEN / ELSE (guard `END`/`CHAIN` with a condition)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — `STOP`/`END`/`PAUSE` termination (comprehensive)
- [70-commands/program-management](../br_tree/70-commands/program-management/spec.md) — full `CHAIN`, `LOAD`, procedures reference (comprehensive)

---

<a id="for-next"></a>
## FOR / NEXT — Loop construct, nesting

**Syntax:**
```bnf
`FOR` <num-var> `=` <num-expr> `TO` <num-expr> [`STEP` <num-expr>]
    <statements>
`NEXT` <num-var>
```

**What it does:**
1. **Initializes loop variable** — Sets <num-var> to the start value
2. **Tests condition** — Compares <num-var> to the end value (before each pass; may run zero times)
3. **Executes loop body** — Runs <statements> zero or more times
4. **Increments/decrements** — Adds `STEP` (default `1`) to <num-var> after each pass
5. **Tests and exits** — Exits when <num-var> exceeds the end value (or goes below it with negative `STEP`)

**Semantics:**
- **Start value** — <num-expr> is evaluated once at loop entry
- **End value** — <num-expr> is evaluated once at loop entry (not recalculated each pass; changes inside the loop do not affect the end)
- **STEP default** — `1` (count up); negative `STEP` counts down
- **Variable persists** — After the loop exits, <num-var> retains its final value
- **Must match NEXT** — The `NEXT` statement must name the same variable as `FOR`
- **Nesting** — Up to **20 levels** of nested FOR/NEXT loops; innermost NEXT comes before outermost NEXT
- **NEXT must match** — Partial overlap is not allowed; each inner `NEXT` closes before the outer `NEXT`

**Loop testing:**
- **Test before each pass** — The condition is checked **before** executing the loop body; a loop may run zero times (e.g., `FOR I = 10 TO 1` runs zero times)
- **Test uses initial end value** — If the end value is changed inside the loop, the test still uses the original value

**Early exit:**
- **`EXIT FOR`** — There is no EXIT FOR; use GOTO instead; GOTO out of a FOR loop has no stack effect
- **Partial exit** — Exiting an outer loop does not directly exit inner loops; use caution with nested exits

**Non-integer step:**
- **Decimal STEP is allowed** — `FOR X = 1.0 TO 10.0 STEP 0.5` works and produces fractional values
- **Non-integer counters** — Loop variables can be non-integer; precision depends on floating-point accuracy

**Common errors:**
- **Syntax error** — `NEXT` variable doesn't match `FOR` variable
- **Nesting violation** — Partial overlap of FOR/NEXT (inner NEXT outside outer FOR)

**Gotchas:**
1. **Variable persists after loop** — The loop variable retains its final value after the loop; use a different variable if you need the original value
2. **End value is fixed** — Changing the end value inside the loop has no effect; the original end value is used for all iterations
3. **STEP is signed** — Negative `STEP` is required for counting down; `FOR I = 10 TO 1 STEP -1` counts down, but `FOR I = 10 TO 1` (without negative STEP) runs zero times
4. **Floating-point precision** — Decimal STEP may accumulate rounding errors over many iterations; use caution with fractional steps

**Example code:**
```business-rules
! Count up with default step
00100 FOR I = 1 TO 10
00110   PRINT I
00120 NEXT I

! Count down with negative step
00200 FOR J = 10 TO 1 STEP -1
00210   PRINT J
00220 NEXT J

! Nested loops (row, column)
00300 FOR ROW = 1 TO 5
00310   FOR COL = 1 TO 10
00320     PRINT ROW, COL;
00330   NEXT COL
00340   PRINT ""
00350 NEXT ROW

! Early exit
00400 FOR K = 1 TO 100
00410   IF K = 50 THEN GOTO 440
00420   PRINT K
00430 NEXT K
00440 PRINT "Exited at K =", K    ! K retains value 50

! Decimal step
00500 FOR X = 1.0 TO 2.0 STEP 0.1
00510   PRINT X
00520 NEXT X
```

**See also:**
- DO / LOOP (conditional loop alternative)
- EXIT DO (early loop exit)
- NEXT statement
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — full loop & branching reference (comprehensive)

---

<a id="do-loop"></a>
## DO / LOOP — Conditional loops

**Syntax:**
```bnf
`DO` [{`WHILE`|`UNTIL`} <condition>]
    <statements>
    [`EXIT DO`]
`LOOP` [{`WHILE`|`UNTIL`} <condition>]
```

**What it does:**
1. **Starts an unconditional or conditional loop**
2. **Runs statements** at least once if test is on `LOOP`, or can run zero times if test is on `DO`
3. **Tests condition** — `WHILE` (continue while true), `UNTIL` (continue until true)
4. **Loops back** — Continues until the condition is false (WHILE) or true (UNTIL)
5. **Allows early exit** — `EXIT DO` terminates the loop and continues after `LOOP`

**Semantics:**
- **`DO` with no test** — Loop body runs at least once; `LOOP` with test controls continuation
- **`DO WHILE <cond>`** — Test first; loop runs only if condition is true (may run zero times)
- **`DO UNTIL <cond>`** — Test first; loop runs only if condition is false (may run zero times)
- **`LOOP WHILE <cond>`** — Test last; loop runs at least once, then continues while condition is true
- **`LOOP UNTIL <cond>`** — Test last; loop runs at least once, then continues until condition is true
- **`DO` and `LOOP` optional** — Either can have a test; if both have tests, both tests are effective
- **No variables required** — Unlike FOR/NEXT, DO/LOOP doesn't require dedicated variable names
- **Nesting** — Multiple DO/LOOP loops can nest; `EXIT DO` exits the **innermost** loop

**Early exit:**
- **`EXIT DO`** — Terminates the **innermost** DO/LOOP loop and continues at the first statement after `LOOP`
- **No nesting required** — Multiple EXIT statements from a DO loop are permitted; the first one processed exits the loop
- GOTO out of a DO loop also has no stack effect


**Common patterns:**
```business-rules
! Run at least once, test at bottom
DO
  PRINT "Enter yes or no: ";
  INPUT CHOICE$
LOOP UNTIL CHOICE$ = "yes" OR CHOICE$ = "no"

! File processing with EOF
DO
  READ #1: DATA$ EOF 200
  PRINT DATA$
LOOP

! Menu with exit
DO
  PRINT "1=Add, 2=Delete, 3=Exit: ";
  INPUT CHOICE
  IF CHOICE = 1 THEN GOSUB ADD_ITEM
  IF CHOICE = 2 THEN GOSUB DELETE_ITEM
LOOP UNTIL CHOICE = 3
```

**Error conditions:**
- **None specific** — Infinite loops are possible if the test never becomes true/false; use caution with loop conditions

**Common errors:**
- **Infinite loop** — If the test never becomes false (WHILE) or true (UNTIL), the loop continues forever; add safeguards

**Gotchas:**
1. **Test timing** — `DO WHILE/UNTIL` tests before entering; `LOOP WHILE/UNTIL` tests after each pass (loop runs at least once)
2. **EXIT DO exits only the innermost loop** — Nested exits are required for multiple levels
3. **Infinite loops are possible** — Always have a clear exit condition and test it thoroughly
4. **No automatic variable management** — Unlike FOR/NEXT, DO/LOOP doesn't manage loop variables; you must update them manually (or use `EXIT DO` to break out)

**Example code:**
```business-rules
! Password validation (repeat until valid)
00100 DO
00110   PRINT "Enter password: ";
00120   INPUT PASSWORD$
00130 LOOP UNTIL PASSWORD$ = "SECRET"
00140 PRINT "Access granted"

! File processing with EOF
00200 DO
00210   READ #1: DATA$ EOF 250
00220   PRINT DATA$
00230 LOOP
00250 CLOSE #1:

! Menu-driven loop
00300 DO
00310   PRINT "1=Add, 2=List, 3=Exit: ";
00320   INPUT CHOICE
00330   ON CHOICE GOSUB ADD, LIST, EXIT_MENU
00340 LOOP

! Count with manual increment
00400 LET COUNT = 1
00410 DO
00420   PRINT COUNT
00430   LET COUNT = COUNT + 1
00440 LOOP WHILE COUNT <= 10

! Early exit with flag
00500 LET FOUND = 0
00510 DO
00520   READ #1: RECORD$ EOF 550
00530   IF RECORD$ = "TARGET" THEN LET FOUND = 1 : EXIT DO
00540 LOOP
00550 IF FOUND THEN PRINT "Found!" ELSE PRINT "Not found"
```

**See also:**
- FOR / NEXT (fixed-count loop)
- EXIT DO (early loop exit)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — full loop & branching reference (comprehensive)
- [10-language/data-manipulation/conditionals](../br_tree/10-language/data-manipulation/conditionals/spec.md) — `WHILE`/`UNTIL` conditions

---

<a id="gosub-return"></a>
## GOSUB / RETURN — Subroutine call and return

**Syntax:**
```bnf
`GOSUB` <line-ref>
`RETURN`
`ON` <num-expr> `GOSUB` <line-ref> [`,` <line-ref>]* [`NONE` <line-ref>]
`ON` <error-cond> `GOSUB` <line-ref>
`ON FKEY` <num-expr> `GOSUB` <line-ref>
```

**What it does:**
1. **GOSUB** — Calls a subroutine at a specific line/label
2. **Pushes return address** — The statement after `GOSUB` is saved on the call stack
3. **Transfers control** — Execution jumps to the subroutine
4. **RETURN** — Returns control to the statement after the `GOSUB`
5. **ON … GOSUB** — Multi-way dispatch; selects one of several subroutines based on a numeric expression
6. **ON <error-cond> GOSUB** - wherever the specified error occurs a GOSUB process is executed; RETURN rexecutes the error producing statement unless the interrupt occurred after an IO operation
7. **ON FKEY <number> GOSUB** - When FKEY <number> is activated a GOSUB operation is performed

**Semantics:**
- **Line reference** — <line-ref> can be a line number (e.g., `10000`) or a label (e.g., `SALESTAX:`)
- **Return address** — The next statement after `GOSUB` is automatically pushed; `RETURN` resumes there
- **Nested subroutines** — Subroutines can call other subroutines; the call stack (FLOWSTACK) allows **up to 100 active (nested) GOSUBs** by default; this limit is configurable via the BRConfig.sys `FLOWSTACK` directive
- **Global variables** — Subroutines can read and modify active variables (global plus FN parameters)
- **RETURN behavior** — Returns to the statement after the call even if that's mid-way through a multi-statement line

**ON … GOSUB** multi-way dispatch:
- **Expression is rounded** — The numeric expression is rounded to the nearest integer
- **Selects the *n*-th target** — 1 = first, 2 = second, etc.
- **Falls through if out of range** — If the value is < 1 or beyond the list, control goes to the `NONE` target if present, otherwise falls through to the next line
- **NONE target is itself a GOSUB** — The `NONE` branch goes to another subroutine, not an error handler; the routine must also `RETURN`
- **Error conditions allowed** — `ON … GOSUB` may carry trailing error-condition clauses (e.g., `ON CHOICE GOSUB A, B, C IOERR 500`)

**Restrictions:**
- **GOSUB cannot run from the command line** — Error 1011 (illegal immediate statement)
- **Active GOSUBs cannot be edited** — During program interruption (Ctrl-A), you cannot edit the target line

**Call stack limits:**
- **FLOWSTACK limit** — Up to 100 active (nested) GOSUBs by default (configurable via the BRConfig.sys `FLOWSTACK` directive); exceeding this limit raises an error

**Common errors:**
- ERR 1011: GOSUB from command line (illegal immediate statement)
- ERR FLOWSTACK: Call stack overflow (more than the FLOWSTACK limit, default 100, nested GOSUBs)

**Gotchas:**
1. **Global variables** — Subroutines share the global namespace; there is no automatic local scope (unlike DEF FN, which creates local copies of by-value parameters)
2. **Return address on call stack** — The return address is stored; if you execute `GOTO` resume from inside a subroutine, you bypass the `RETURN` and don't clean up the stack
3. **ON … GOSUB NONE is not an error** — The `NONE` target is itself a subroutine that must `RETURN`; it's not an error handler
4. **Mid-statement return** — If the `GOSUB` is part of a multi-statement line (e.g., `LET X = 1: GOSUB CALC: PRINT X`), `RETURN` resumes after the GOSUB, not at the next line
5. **Deep nesting is slow** — Each GOSUB adds overhead; deeply nested subroutines are slower than inline code

**Example code:**
```business-rules
! Simple subroutine call
00100 GOSUB CALC_TAX
00110 PRINT "Tax: ", TAX
00120 STOP

! Subroutine with global variables
00200 CALC_TAX: LET TAX = PRICE * 0.06 : RETURN

! Nested subroutines
00300 GOSUB OUTER
00310 PRINT RESULT
00320 STOP

00400 OUTER: GOSUB INNER : RETURN
00500 INNER: LET RESULT = 42 : RETURN

! Multi-way dispatch
00600 PRINT "1=Add, 2=Del, 3=List: ";
00610 INPUT CHOICE
00620 ON CHOICE GOSUB ADD_REC, DEL_REC, LIST_RECS NONE INVALID

00700 ADD_REC: PRINT "Add selected" : RETURN
00800 DEL_REC: PRINT "Delete selected" : RETURN
00900 LIST_RECS: PRINT "List selected" : RETURN
01000 INVALID: PRINT "Invalid choice" : RETURN
```

**See also:**
- RETURN (return from subroutine)
- DEF FN (user-defined function alternative to GOSUB)
- ON … GOTO (unconditional multi-way dispatch)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — full GOSUB / ON…GOSUB reference (comprehensive)
- [00-configuration/config-directives](../br_tree/00-configuration/config-directives/spec.md) — `FLOWSTACK` directive (call-stack size)

---

<a id="exit"></a>
## EXIT — Loop or subroutine exit

**Syntax:**
```bnf
`EXIT DO`
`EXIT` <error-condition> <line-ref> [`,` <error-condition> <line-ref> ]*
... <statement> `EXIT` <line-ref>
```

**What it does:**
1. **`EXIT DO`** — Terminates the **innermost** DO/LOOP loop; continues at the first statement after `LOOP`
2. **`EXIT` group** — Defines reusable error-condition line-ref sets
3. `… <statement> EXIT <line-ref>` Error exit specifications can redirect to an EXIT group line-ref

**Semantics:**
- **Innermost only** — `EXIT DO` affects only the innermost DO loop
- **Control transfer** — Execution jumps to the first statement after the loop terminator (`LOOP`)
- **Exit groups** — Named sets of error-condition handlers; multiple `EXIT` conditions can point to the same handler line

**EXIT groups pattern:**
```business-rules
EXIT CONV 100, SOFLOW 100, OFLOW 100    ! three conditions → one handler
... <statement> EXIT 100
100 HANDLER: PRINT "Error: "; ERR : RETRY
```

**Common errors:**
- **None specific** — `EXIT DO` without a matching DO is a syntax error

**Gotchas:**
1. **No partial exit** — `EXIT DO` exits only the innermost loop; nested exits are required for multiple levels
2. **Exit groups are complex** — The EXIT group pattern is powerful but less common

**Example code:**
```business-rules
! Exit innermost FOR loop
00100 FOR I = 1 TO 10
00110   FOR J = 1 TO 10
00120     IF J = 5 THEN GOTO 150            ! exits inner (J) loop
00130     PRINT I, J
00140   NEXT J
00150   PRINT "Row complete"
00160 NEXT I

! Exit DO loop on condition
00200 DO
00210   READ #1: DATA$ EOF 250
00220   IF DATA$ = "STOP" THEN EXIT DO
00230   PRINT DATA$
00240 LOOP
00250 CLOSE #1:

! Exit group for multiple error conditions
00300 EXIT CONV 400, SOFLOW 400
00310 INPUT FIELDS "5,10,C 20;10,10,N 8.2": NAME$, AMOUNT
00320 PRINT "Success"
00330 CONTINUE 450
00400 PRINT "Error: "; ERR : RETRY
00450 CONTINUE
```

**See also:**
- FOR / NEXT (loop construct)
- DO / LOOP (conditional loop)
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md) — `EXIT DO` semantics
- [10-language/flow-control/error-handling](../br_tree/10-language/flow-control/error-handling/spec.md) — `EXIT` condition groups (comprehensive)

---

<a id="execute"></a>
## EXECUTE — Run a command string from code

**Syntax:**
```bnf
`EXECUTE` `"` [`*`] <command-string> `"`
`EXECUTE` <string-expression>
```

**What it does:**
1. **Runs any command/statement string at runtime** — the bridge that makes commands part of the coding surface
2. **Typical uses** — build `INDEX` files, run a `SORT`, start a `PROC`, `LOAD` a resident library, run a command
3. **A leading `*`** suppresses screen restoration
4. **Sets `CODE`** — inspect the `CODE` function afterward for a procedure's return value

**Semantics:**
- **Commands from code** — commands normally can't appear in a program **except** via `EXECUTE` (or inside a `PROC`); `EXECUTE` runs one at runtime
- **String argument** — a literal or string expression holding the command (e.g. `EXECUTE "INDEX ACCT.INT ACCT.KEY 1 4 REPLACE"`)
- **Leading `*`** — suppresses screen restoration (the default does not restore the screen either)
- **Return value** — after a `PROC`, read `CODE` for its return value
- **Restrictions** — you **cannot terminate** the program from `EXECUTE`, so the **program-ending** commands `LOAD`, `SAVE`, `REPLACE` and the `CHAIN` **statement** may not be used inside it. This applies to `LOAD` that **replaces the running program**; **`LOAD …,RESIDENT`** (loading a *resident library*) does **not** end the program and **is** allowed — e.g. `EXECUTE "LOAD RESLIB,RESIDENT"`
- **`INDEX` / `SORT`** — *can* be started from `EXECUTE`; there is **no prior `CLEAR`** (less free memory, may run slowly; out-of-memory → **error 7607 / 7811**)
- **OS shell access via `SYSTEM`** — `SYSTEM` is a *command*, not a statement, so a program invokes it through `EXECUTE` (e.g. `EXECUTE "SYSTEM 'notepad log.txt'"`). This is the program's main way to **launch other applications / run OS commands**. Flags precede the command string — e.g. `-C` run asynchronously (don't wait), `-R` restore the BR screen afterward, `-@`/`-S` run on the client/server side, `-M`/`-m` hide/minimize the launched window. `SYSTEM` alone (or `SYSTEM <n>`) instead **exits BR to the OS** (with exit code `<n>`), and `SYSTEM LOGOFF` logs the client off. Because it runs arbitrary OS commands with the caller's privileges, treat it as security-sensitive. Full flag set: [70-commands/program-management §SYSTEM](../br_tree/70-commands/program-management/spec.md#system)
- **Error handling** — all errors (including command syntax errors) are passed back and are trappable with `ERROR`/`IOERR`/`EXIT`
- **Nestable** — an `EXECUTE` may itself be the subject of another `EXECUTE`

**Common errors:**
- **ERR 7607 / 7811** — out of memory running `INDEX`/`SORT` via `EXECUTE` (no `CLEAR` leaves less memory)
- **Illegal terminating command** — `LOAD`/`SAVE`/`REPLACE`/`CHAIN` inside `EXECUTE`

**Gotchas:**
1. **Can't end the program** — no `CHAIN`/`LOAD`/`SAVE`/`REPLACE` inside `EXECUTE`; use `CHAIN` as a statement instead
2. **Screen not restored by default** — handle repainting yourself after a command that paints the screen
3. **Check `CODE` after a `PROC`** — that's how you read its return value
4. **Trap its errors** — command syntax errors come back to the caller (`ERROR`/`IOERR`/`EXIT`)
5. **`INDEX`/`SORT` may run slowly via `EXECUTE`** — no `CLEAR` means less free memory

**Example code:**
```business-rules
! Rebuild an index from code
99000 EXECUTE "INDEX ACCT.INT ACCT.KEY 1 4 REPLACE"

! Run a sort control file
99010 EXECUTE "SORT CUSTOMER.SRT"

! Preload a resident library
01000 EXECUTE "LOAD RESLIB,RESIDENT"

! Launch an OS application / run a shell command (SYSTEM is a command → via EXECUTE)
01100 EXECUTE "SYSTEM -C 'backup.bat'"     ! -C = run asynchronously, don't wait
01110 EXECUTE "SYSTEM 'lp report.txt'"     ! run an OS command, then return to BR

! Build the command string dynamically, trap errors with ON ERROR
00090 ON ERROR GOTO 200
00100 LET CMD$ = "INDEX " & MASTER$ & " " & KEYFILE$ & " 1 10 REPLACE"
00110 EXECUTE CMD$
00120 GOTO 300
00200 PRINT "Reindex failed: "; ERR : STOP
00300 !
```

**See also:**
- SORT / INDEX (commonly launched via `EXECUTE`)
- LIBRARY (`EXECUTE "LOAD …,RESIDENT"` to preload a library)
- STOP / END / PAUSE / CHAIN (`CHAIN` is a statement — not allowed inside `EXECUTE`)
- `SYSTEM` command (OS shell call / exit-to-OS) — run from a program via `EXECUTE`
- [70-commands/program-management](../br_tree/70-commands/program-management/spec.md#execute) — full EXECUTE / command reference (comprehensive); [§SYSTEM](../br_tree/70-commands/program-management/spec.md#system) — the SYSTEM shell call

---

<a id="trace"></a>
## TRACE — Line-number tracing under program control

**Syntax:**
```bnf
`TRACE` { `ON` | `OFF` | `PRINT` }
```

**What it does:**
1. **`TRACE ON` starts line-number tracing** — as each line executes, BR writes its line number (five digits, zero-padded) to the main window and logs a `Trace line <n> in <program>` event
2. **`TRACE OFF` stops it**, and also clears the print destination
3. **`TRACE PRINT` sends trace output to the system printer** instead of the window
4. **Same two run flags as the console options** — `TRACE ON` is the program-controlled equivalent of `RUN TRACE`, and `TRACE OFF` of `NOTRACE`

**Semantics:**
- **The point of the statement form** is that it can bracket one suspect region of a long program, instead of tracing the whole run from the console
- **`TRACE PRINT` does not start tracing** — it selects the destination only, and output is still gated on tracing being on. Write `TRACE ON` as well
- **Statement and command differ here** — `RUN PRINT` sets the destination *only* if tracing is already on, while the statement sets it either way, so the setting survives to apply to a later `TRACE ON`
- **Tracing costs a per-line check** even when nothing is printed, so turn it off rather than leaving it set

**Gotchas:**
1. **Write `TRACE ON`, never a bare `TRACE`** — BR's grammar marks the `ON` keyword optional so a bare `TRACE` compiles, but no operand is emitted for it and the runtime reads the byte that follows the statement instead. The effect is unverified; the two-word form is unambiguous
2. **`TRACE PRINT` alone looks broken** — it is legal, it changes a flag, and it prints nothing. That is the gating above, not a fault
3. **Trace output interleaves with program output** — it goes to the same main window, so a screen-formatted program becomes hard to read while tracing; `TRACE PRINT` exists for exactly that case

**Example code:**
```business-rules
! Trace one suspect subroutine, not the whole run
02000 TRACE ON
02010 GOSUB POST_LEDGER
02020 TRACE OFF
02030 !
! Send the trace to the printer, leaving the screen readable
02100 TRACE PRINT
02110 TRACE ON
```

**See also:**
- [10-language/flow-control/other-flow](../br_tree/10-language/flow-control/other-flow/spec.md#trace) — TRACE statement (comprehensive)
- [70-commands/information](../br_tree/70-commands/information/spec.md) — `RUN STEP`/`TRACE` and the console debugging options
- STOP / END / PAUSE / CHAIN (`PAUSE` as the other in-program debugging aid)

---

<a id="on-condition"></a>
## ON condition — Program-wide condition traps

**Syntax:**
```bnf
`ON` <error-condition> { `GOTO` <line-ref> | `GOSUB` <line-ref> | `IGNORE` | `SYSTEM` }
`ON` { `FKEY` | `FNKEY` } <n>  { `GOTO` <line-ref> | `GOSUB` <line-ref> | `IGNORE` | `SYSTEM` }

<error-condition> ::= `ATTN` | `CONV` | `DUPREC` | `IOERR` | `NOKEY` | `OFLOW`
                    | `PAGEOFLOW` | `SOFLOW` | `ZDIV` | `HELP`   -- ON-eligible conditions
```

**What it does:**
1. **Installs a program-wide trap for one specific condition** — narrower than the catch-all `ON ERROR`
2. **Fires whenever that condition arises** and the statement itself did not trap it
3. **Four dispositions** — `GOTO` (branch), `GOSUB` (call & `RETURN`), `IGNORE` (skip silently), `SYSTEM` (restore default)
4. **`ON FKEY <n>`** traps a function key during RUN

**Semantics:**
- **Per-condition** — e.g., `ON CONV GOTO 100`, `ON ZDIV IGNORE`, `ON PAGEOFLOW GOSUB 900`
- **Level 3 of 4** — see the trapping hierarchy below; it sits between `EXIT` groups and the catch-all `ON ERROR`
- **`GOTO` vs. `GOSUB`** — after a `GOSUB` handler `RETURN`s, BR **re-executes the error-producing statement**, *unless* the interrupt followed an I/O operation (then it resumes after it)
- **`IGNORE`** — skips silently and sets **no** `ERR`/`LINE`; for `SOFLOW` it **truncates** the string instead of erroring
- **`SYSTEM`** — restores the default beep-and-suspend behavior for that condition
- **Not every condition is ON-eligible** — `CONV` works on a statement, in an `EXIT` group **and** with `ON`; but **`EOF` and `NOREC` are accepted only on a statement or in an `EXIT` group — never with `ON`** (they are position/data conditions tied to a specific I/O)
- **`PAGEOFLOW`** — commonly `ON PAGEOFLOW GOSUB` to emit a footer/header, then `CONTINUE`
- **`ON FKEY <n>`** — traps function keys during RUN (F1–F10 default to `IGNORE`); during `INPUT`, function keys instead set `CMDKEY` rather than trapping
- **`ON FNKEY <n>` is the same statement under a second spelling**, and it is switched on and off by a config directive rather than always available: `config.cpp` case **58** calls `setConfigAllowFnkeySyntax`, which rewrites the `FNKEY` entry of `table4xCompiling` to point at `FKEY` when the option is off (`tblopr.cpp`, and BR's own comment there reads "FNKEY has been disabled by changing to FKEY"). `STATUS` reports its state under key `58`. The directive itself is undocumented in the reference
- **`ON ATTN`** — traps the Attention key; written 59 times in the reference corpus and previously absent from the condition list above
- **`ON FKEY`/`ON FNKEY` branch to exactly one target, never a comma list** — `FKEY`/`FNKEY` are also
  plain callable functions, so with no `<n>` or an operator where it belongs (`ON FKEY-89 GOTO A,B`,
  `ON FKEY GOTO A,B`), the whole line is the *other* `ON` statement, [ON … GOTO / GOSUB — Computed
  (indexed) branch](#on--goto--gosub--computed-indexed-branch), using FKEY's return value as the
  selector — only `ON FKEY <n> …` / `ON FKEY(<n>) …` with nothing else before the verb is this form
- **`ON HELP`** — traps the Help key (field help); `ON HELP GOSUB <line>` opens a program-driven help screen, then `RETURN`/`CONTINUE`. (`HELP` is also a statement-level FIELDS error condition — see [INPUT FIELDS](#input-fields--formatted-input-with-field-attributes).)

**Four levels of trapping (processed in order):**
1. **Statement-level conditions** — e.g., `READ … EOF 200` (highest priority)
2. **`EXIT` groups** — named, reusable condition sets (see [EXIT](#exit--loop-or-subroutine-exit))
3. **`ON <condition>`** — program-wide, per condition (this statement)
4. **`ON ERROR`** — catch-all for anything still untrapped
   → then the **system default** (beep and suspend)

**Common errors:**
- **`EOF`/`NOREC` with `ON`** — not allowed; use a statement-level condition or an `EXIT` group instead

**Gotchas:**
1. **`ON` is not a catch-all** — it traps only its named condition; use `ON ERROR` for everything else
2. **`GOSUB` re-executes on `RETURN`** — unless the error followed an I/O op; fix the cause before returning or it loops
3. **`IGNORE` hides the error** — no `ERR`/`LINE` is set; `SOFLOW` silently truncates
4. **`EOF`/`NOREC` are statement/EXIT-only** — a common mistake is `ON EOF …`, which is rejected

**Example code:**
```business-rules
! Install per-condition traps at program start
00001 ON ERROR GOTO GENERAL_ERROR      ! level-4 catch-all
00002 ON ZDIV IGNORE                    ! silently skip divide-by-zero
00003 ON CONV GOTO BAD_INPUT            ! branch on conversion errors
00004 ON PAGEOFLOW GOSUB PAGE_BREAK     ! footer/header, then CONTINUE

! Page-overflow handler for a report
00900 PAGE_BREAK: PRINT #255: NEWPAGE
00910   PRINT #255: "Report (cont.)"
00920 CONTINUE                          ! resume the interrupted PRINT

! Function-key trap during RUN
00050 ON FKEY 5 GOSUB HELP_SCREEN
```

**See also:**
- ON ERROR (the level-4 catch-all)
- EXIT (level-2 `EXIT` condition groups)
- RETRY / CONTINUE (recovery after the handler)
- GOSUB / RETURN (`ON <cond> GOSUB` / `ON FKEY … GOSUB` return behavior)
- [10-language/flow-control/error-handling](../br_tree/10-language/flow-control/error-handling/spec.md) — full trapping model, ON-eligibility, conditions (comprehensive)
- [90-reference/error-codes](../br_tree/90-reference/error-codes/_index.md) — per-code error reference

---

<a id="on-error"></a>
## ON ERROR — Catch-all error handler

**Syntax:**
```bnf
`ON ERROR` { `GOTO` <line-ref> | `GOSUB` <line-ref> | `IGNORE` | `SYSTEM` }
```

**What it does:**
1. **Catches all untrapped errors** — Any error not caught by a statement-level condition or `ON <condition>` goes to the ON ERROR handler
2. **GOTO** — Transfers control to a handler subroutine
3. **GOSUB** - Executes a GOSUB; RETURN rexecutes the error producing statement
3. **IGNORE** — Silently suppresses the error (sets `CNT=0`, clears `ERR`)
4. **SYSTEM** — Restores default beep-and-suspend behavior (useful to reset after a custom handler)

**Semantics:**
- **Last-resort handler** — ON ERROR catches everything; it is the catch-all for unspecified errors
- **Hierarchy** — four levels processed in order: statement-level conditions (highest), `EXIT` groups, `ON <condition>`, then `ON ERROR` (lowest)
- **Error variables set** — `ERR` (error code), `LINE` (line number where error occurred), `CNT` (I/O items processed), `FILENUM` (file number for I/O errors)
- **`IGNORE` clears error** — Sets `ERR` to 0; normal execution continues at the next statement
- **`GOTO` branches** — Transfers control to a handler; the handler may `RETRY`, `CONTINUE`, or take other action
- **`GOSUB` branches** - Requires a RRETURN to avoid call stack accumulation
- **`SYSTEM` restores default** — Useful to reset the error handler inside an existing handler

**Error hierarchy (processed in order):**
1. Statement-level conditions (e.g., `READ … EOF 200`)
2. `EXIT` groups (named, reusable condition sets)
3. `ON <condition>` (program-wide, per condition — e.g., `ON CONV GOTO 100`)
4. `ON ERROR` (catch-all)
5. System default (beep and suspend)

**Common patterns:**
```business-rules
! Catch-all at program start
00001 ON ERROR GOTO 9000
... (program code)
09000 GENERAL_ERROR:
        PRINT "Error";ERR;"at line";LINE
        STOP
```

**Gotchas:**
1. **IGNORE suppresses all errors** — `ON ERROR IGNORE` silently suppresses all errors; use with caution (you may mask bugs)
2. **Error variables can be stale** — If multiple statements execute before you check `ERR`, the value may have changed; save `ERR` immediately in a handler
3. **`RETRY` or `CONTINUE` without an error** — Using `RETRY` when no error has occurred (or after `ON ERROR IGNORE`) is itself an error
4. **CONTINUE vs. RETRY** — `CONTINUE` moves to the next statement; `RETRY` re-executes the failing statement
5. **Second error loses first address** — If a second error occurs in a handler before the first is retried, the return address for the first is lost; use `ON ERROR SYSTEM` on entry and reinstate traps just before `RETRY`

**Example code:**
```business-rules
! Catch-all at program start
00001 ON ERROR GOTO 90000

00010 OPEN #1: "NAME=test.int", INTERNAL, INPUT
00020 READ #1: A$, B EOF 50
00030 PRINT A$, B
00040 GOTO 20
00050 CLOSE #1:
00060 STOP

90000 GENERAL_ERROR:
        LET SAVECNT = CNT         ! save CNT first
        PRINT "Error "; ERR; " at line "; LINE
        IF FILENUM > 0 THEN PRINT "File: "; FILE$(FILENUM)
        STOP
```

**See also:**
- ON condition (program-wide per-condition traps — level 3)
- EXIT (level-2 `EXIT` condition groups)
- RETRY / CONTINUE (error recovery)
- [10-language/flow-control/error-handling](../br_tree/10-language/flow-control/error-handling/spec.md) — full error-trapping reference: ON/EXIT/conditions, recovery (comprehensive)
- [90-reference/error-codes](../br_tree/90-reference/error-codes/_index.md) — per-code error reference

---

<a id="retry-continue"></a>
## RETRY / CONTINUE — Re-execute or skip after an error

**Syntax:**
```bnf
`RETRY`
`CONTINUE`
```

**What it does:**
1. **RETRY** — Re-executes the statement (or clause) that caused the most recent error
2. **CONTINUE** — Resumes execution at the **next** statement (after the one that errored)
3. **Both are recovery mechanisms** — Used inside error handlers to recover from errors

**Semantics:**
- **RETRY address** — BR tracks the address of the statement that caused the error; `RETRY` re-executes it
- **CONTINUE skips** — Moves to the next statement without re-executing
- **Context preservation** — `RETRY` preserves the context of the original error; you can modify variables before retrying
- **Common pattern** — Prompt the user to fix the problem, then `RETRY`

**Restrictions:**
- **No outstanding error** — Using `RETRY` when no error has occurred (or after `ON ERROR IGNORE`) is itself an error (0500)
- **Second error loses first address** — If a second error occurs before the first `RETRY`, the return address is lost; use `ON ERROR SYSTEM` on entry and reinstate traps before `RETRY`
- **Input field positioning** — If the retried statement is `INPUT FIELDS`/`RINPUT FIELDS`, the cursor auto-positions on the offending field

**Help-key return path exception:**
- **Error 4273** (help-topic-not-found) — Leaves `ERR`/`LINE` unset and keeps `RETRY` aimed at the *original* error, not the help lookup

**Typing RETRY at interrupted program:**
- **Same as `GO`** — At an interrupted program (Ctrl-A), typing `RETRY` resumes execution and re-executes the next line (similar to `GO`)

**Common patterns:**
```business-rules
! Retry on invalid input
00050 INPUT NUM CONV 100
00060 PRINT "Accepted: ", NUM
00070 CONTINUE 200
00100 PRINT "Not a number; please re-enter"
00110 RETRY

! Retry with variable modification
00200 INPUT AMOUNT CONV 300
00210 LET NET = FNPROCESS(AMOUNT)
00220 CONTINUE 400
00300 PRINT "Invalid amount. Enter a positive number: "
00310 RETRY

! Two-tier recovery
00400 WRITE #1: REC$ IOERR 500
00410 CONTINUE 600
00500 PRINT "Write failed; retrying..."
00510 RETRY
00600 PRINT "Write successful"
```

**Error handling with nested errors:**
```business-rules
! Safe nested error handling
00001 ON ERROR GOTO 9000

00050 INPUT NUM CONV 100  ! if CONV, branch to 100
00060 PRINT NUM : CONTINUE 200

00100 ON ERROR SYSTEM     ! temporarily suppress ON ERROR
      PRINT "Bad input"
      ON ERROR GOTO 9000  ! reinstate the handler
00110 RETRY

09000 GENERAL_ERROR:
        PRINT "Fatal error "; ERR : STOP
```

**Common errors:**
- ERR 0500: RETRY without an outstanding error
- ERR: Second error before first `RETRY` (return address lost)

**Gotchas:**
1. **RETRY requires an error** — You cannot use `RETRY` after `ON ERROR IGNORE` or if no error has occurred; BR will error (0500)
2. **Second error loses context** — If a second error occurs inside the handler before the first is retried, the return address for the first is lost; set `ON ERROR SYSTEM` at handler entry and reinstate the trap before `RETRY`
3. **Infinite loops are possible** — If you `RETRY` without fixing the underlying problem, the same error recurs immediately; be sure your handler makes progress toward a fix
4. **CONTINUE instead** — If you want to skip the problematic statement, use `CONTINUE` instead of `RETRY`
5. **Input field positioning** — After `RETRY` on `INPUT FIELDS`, the cursor auto-positions to the offending field, which can be confusing; clarify with a message

**Example code:**
```business-rules
! Simple retry loop
00100 PRINT "Enter a positive number: ";
00110 INPUT NUM CONV 100
00120 IF NUM <= 0 THEN PRINT "Must be positive" : GOTO 100
00130 PRINT "You entered: ", NUM

! Error handler with retry
00200 ON ERROR GOTO 300
00210 OPEN #1: "NAME=test.int", INTERNAL, INPUT
00220 READ #1: A$ EOF 250
00230 PRINT A$
00240 GOTO 220
00250 CLOSE #1:
00260 STOP

00300 IF ERR = 4270 THEN CONTINUE 250   ! EOF, move to close
       PRINT "Error "; ERR; " - retrying..."
00310 RETRY
```

**See also:**
- ON condition (per-condition traps that hand off to RETRY/CONTINUE)
- ON ERROR (error handler setup)
- [10-language/flow-control/error-handling](../br_tree/10-language/flow-control/error-handling/spec.md) — full RETRY/CONTINUE recovery reference (comprehensive)

---

<a id="def-fn"></a>
## DEF FN / FNEND — User-defined function declaration

**Syntax:**
```bnf
-- single-line form (the whole function is one expression)
`DEF FN`<name>[`$` `*` <len>] [ `(` <parameter-list> `)` ] `=` <expression> [ <error-condition> <line-ref> ]*

-- multi-line form
`DEF FN`<name>[`$` `*` <len>] [ `(` <parameter-list> `)` ]
    <statements>
    [`LET`] `FN`<name> `=` <expression> -- set the return value
`FNEND`

<parameter-list> ::= <params> [ `;` <params> ] -- every param after a `;` is OPTIONAL (and used to declare locals)
<params>      ::= <parameter> [ `,` <parameter> ]*
<parameter>   ::= [ `MAT` | `&` ] <variable> [ `*` <len> ] -- `&` = by reference; `MAT` = array reference
<def-library> ::= `DEF LIBRARY` <function-name>[`(`<parameter-list>`)`] … `FNEND`
                  ! no pathname here — the path lives on the LIBRARY linking statement
```

**What it does:**
1. **Single-line form** — Computes one expression; compact and efficient
2. **Multi-line form** — Runs multiple statements and returns a value by assigning to the function name
3. **Parameters** — Passed by value (copy) or by reference (`&` prefix) to avoid copying
4. **Arrays are passed only by reference** - &MAT is illegal
5. **Return value** — Assigned via `LET FN<name> = <expression>` (or just `FN<name> = <expression>`)
6. **DEF LIBRARY** — Marks a function as callable from other programs via the LIBRARY facility
7. **Trailing error-condition clause (single-line only)** — the body expression may close with the same
   `[<error-condition> <line-ref>]*` clause list any statement takes; the corpus writes only `CONV`
   (guarding a `VAL()`/`CNVRT$()` call), never another condition, but the grammar is not narrowed to
   that one — see [ON condition](#on-condition--program-wide-condition-traps) for the roster

**Naming:**
- **Function name** — `FN` + up to 28 more characters (**30 max, `FN` included**; a string function's trailing `$` is extra) (e.g., `FNCALC`, `FNPROCESS`)
- **String functions** — End in `$` (e.g., `FNFORMAT$`); size via `$*<len>`
- **Reserved prefix** — `FN…` is reserved for functions; variables cannot start with `FN` without causing conflicts

**Parameters:**
- **By value (default)** — `DEF FNF(X)` — the function gets a **copy** of X; changes inside the function don't affect the caller's variable
- **By reference** — `DEF FNF(&X)` — the function reads/writes the caller's **original** variable
- **Arrays are always by reference** — `DEF FNF(MAT DATA)` — the array is **not copied** (efficient)
- **String length** — `DEF FN<name>$*<len>` specifies the max length of the returned string
- **Optional parameters & locals (`;`)** — a semicolon makes **every parameter after it optional**. An optional the caller omits becomes a **fresh temporary variable** (`0`/null on each call). Idiom: after the `;`, list first any optional parameters the caller *may* pass, then the names used purely as **local scratch variables** (never passed). Unpassed by-reference optionals default an array to dim 1 and a string to length 18. Such an array cannot be redimensioned (`MAT Z(1)` raises 0315), so a scratch array belongs in the body, not the parameter list; a caller may not pass more args than defined, and types must match

**Semantics:**
- **Scope** — By-value parameters are local (fresh copy per call); global variables are accessible
- **Recursion** — Only multi-line functions can recurse; each recursive call gets fresh local copies of by-value parameters
- **Return value** — If never assigned, the function returns 0 (numeric) or empty (string)
- **File I/O** — Only multi-line functions can perform file I/O; single-line functions cannot
- **Library functions** — DEF LIBRARY marks a function as callable from other programs; it must be linked with a `LIBRARY` statement; the rules for library linkage are sophisticated with respect to performance, and need to be carefully considered
- **Skipped in normal flow** — a `DEF…FNEND` block is not executed by falling into it; the runtime skips over the definition during ordinary top-to-bottom/`GOTO` flow the same way it skips a `FORM` line. No `STOP`/`GOTO` guard before a function definition is needed to keep execution from entering it with unset parameters — a function only runs when called

**Writing functions — gotchas:**
- **Return name is write-only - never a "value so far".** A bare `FN<name>` in the body of the function is always another call. BR keeps no readable slot for the pending return value. So `IF NOT FNRESOLVE` or `LET FOUND = FNRESOLVE` re-invokes `FNRESOLVE` (producing runaway recursion). It does not test what you last assigned. Assign `FN<name>` as often as you like (last write wins); just never read it back and track state in a scratch variable.
- **One exit** — a function has a single `FNEND` and no early return (`RETURN` belongs to `GOSUB`); to bail out, `GOTO` a label just before `FNEND`
- **No empty parens** — call a no-parameter function as `FNGET$`, not `FNGET$()`; invoke for side effects with a bare `LET FNFOO`
- **No array dims in the signature** — a parameter may size a string (`NAME$*20`) but not dimension an array (`ROW(1)*255` is illegal); arrays enter as `MAT name` and are dimensioned by the caller or a `DIM` — declare array locals with their own `DIM`

**Single-line functions:**
```business-rules
DEF FNHYPOT(X, Y) = SQR(X*X + Y*Y)
DEF FNRAND100 = INT(RND*100+1)
DEF FNVAL(PC$*80) = VAL(PC$) CONV Ignore   ! trailing CONV falls through to 0 on a non-numeric string
```

**Multi-line functions:**
```business-rules
DEF FN<name>(params)
  ... <statements>
  FN<name> = <return-expression>
FNEND
```

**Local variables:**
- **By-value parameters are local** — Changes don't affect the caller's variables
- **Declared via the `;` optional list** — the standard way to get private scratch variables: list them after the `;` (with any genuinely-optional parameters). Because the caller never passes them, BR gives each call a fresh temporary initialized to `0`/null. E.g. in `DEF FNP(QTY, UNIT; DISCOUNT, TAX, TOTAL)`, `TAX` and `TOTAL` are locals. Real code occasionally puts a throwaway parameter named `___` (triple underscore) right after the `;` to mark where locals begin — `DEF FNFOO(A$; ___, TMP, US)` — a naming convention, not a keyword
- **Global variables** — Not local unless passed as by-value parameters, or declared as `;` locals; otherwise accessible and modifiable
- **Library function isolation** — Non-local LIBRARY functions cannot see the main program's globals; only parameters and return value are channels of communication

**DEF LIBRARY functions:**
- **Cross-program access** — Must be linked with a `LIBRARY` statement before any program can call them
- **Initialization** — Use initialization functions to set library globals
- **Loading strategies** — Resident (loaded once, persists), release (cleared after each call), 
  or load resident with `OPTION RETAIN` for retention across main program chains.

**Common errors:**
- **Name conflicts** — Using `FN…` as a variable name or vice versa
- **Parameter count mismatch** — Calling with wrong number of parameters
- **Parameter type mismatch** — Calling with wrong parameters

**Gotchas:**
1. **Global variables in functions** — Functions share global namespace; changing a global inside a function affects the caller (unless passed as a by-value parameter)
2. **Recursion requires multi-line** — Single-line functions cannot recurse; use multi-line `DEF FN … FNEND` if you need recursion
3. **Return value not automatic** — If you don't assign to `FN<name>`, the function returns 0 or empty; be explicit about the return value
4. **DEF LIBRARY scope isolation** — Non-local library functions cannot access main program globals; design them to accept all necessary data as parameters
5. **String function length** — The `$*<len>` size limit applies to the returned value; the function cannot return a longer string

**Example code:**
```business-rules
! Simple single-line functions
00100 DEF FNHYPOT(X, Y) = SQR(X*X + Y*Y)
00110 DEF FNFAHR(C) = C * 9 / 5 + 32
00120 PRINT FNHYPOT(3, 4)         ! 5
00130 PRINT FNFAHR(0)             ! 32

! Multi-line function with state
00200 DEF FNCALC(PRICE, QTY)
00210   LET SUBTOTAL = PRICE * QTY
00220   LET TAX = SUBTOTAL * 0.06
00230   FNCALC = SUBTOTAL + TAX
00240 FNEND

! By-reference parameter (efficient array processing)
00300 DEF FNSUM(MAT DATA)
00310   LET TOTAL = 0
00320   FOR I = 1 TO UDIM(DATA)
00330     LET TOTAL = TOTAL + DATA(I)
00340   NEXT I
00350   FNSUM = TOTAL
00360 FNEND

! Library function
00400 DEF LIBRARY FNPROCESS(MAT INPUT, MAT OUTPUT)
00410   FOR I = 1 TO UDIM(INPUT)
00420     LET OUTPUT(I) = INPUT(I) * 2
00430   NEXT I
00440   FNPROCESS = UDIM(INPUT)
00450 FNEND

! String function
00500 DEF FNFORMAT$*30(VALUE)
00510   LET FNFORMAT$ = "Value: " & STR$(VALUE)
00520 FNEND

! Optional parameter + locals after ';' — QTY/UNIT required, DISCOUNT optional,
! TAX and TOTAL never passed so they are fresh locals (0) each call
00600 DEF FNPRICE(QTY, UNIT; DISCOUNT, TAX, TOTAL)
00610   LET TOTAL = QTY * UNIT
00620   IF DISCOUNT > 0 THEN LET TOTAL = TOTAL * (1 - DISCOUNT)
00630   LET TAX = TOTAL * 0.06
00640   LET FNPRICE = TOTAL + TAX
00650 FNEND
```

**See also:**
- LIBRARY (link a `DEF LIBRARY` function for cross-program use)
- GOSUB / RETURN (subroutine alternative)
- ON condition (the trailing error-condition clause's roster)
- [10-language/flow-control/functions-udf](../br_tree/10-language/flow-control/functions-udf/spec.md) — full DEF/FN reference: params, scope, recursion (comprehensive)
- [50-libraries/library-facility](../br_tree/50-libraries/library-facility/spec.md) — LIBRARY statement, loading strategies
- [10-language/data-manipulation/system-functions](../br_tree/10-language/data-manipulation/system-functions/spec.md) — built-in functions

---

<a id="library-functions"></a>
## Library Functions — link reusable FN functions across programs

**Syntax:**
```bnf
`LIBRARY` [ `RELEASE` `,` ] [ `NOFILES` `,` ] [ <library-program> ] `:` <fn> [ `,` <fn> ]*
`LIBRARY` [ <library-program> ] `:`          -- load-present form (no functions; loads the named library immediately)

<library-program> ::= `"` <file-pathname> `"` | <string-expression>
<fn>              ::= `FN`<identifier>
```

**What it does:**
1. **Links one or more `FN…` functions** defined in another program (or the caller's own `DEF LIBRARY`s) so they can be called
2. **Loads the library program** on first use (unless already resident)
3. **Optionally isolates** the library's variables (`RELEASE`) or file channels (`NOFILES`)
4. **The no-functions form** (`LIBRARY "name":`) loads the named library *present* immediately — it does **not** detach anything (a linkage detaches only when the main program ends)

**Semantics:**
- **Link before call** — a function must be linked with `LIBRARY` before it can be called, **even one defined locally with `DEF LIBRARY`** (defining functions is in DEF FN / FNEND)
- **Named vs. unnamed linkage** — the `<library-program>` file reference is **optional**. *Named* (reference given, `LIBRARY "PRESLIB": FNX`) links each function **directly** to that library. *Unnamed* (reference omitted, `LIBRARY : FNX`) leaves BR to pick the library, resolving **final linkage** by the search order below; an unnamed statement is **required** to call back into the main program
- **`RELEASE`** — clears the function's workspace variables after it returns (as-needed loading); requires an explicit `<library-program>`; incompatible with `OPTION RETAIN`
- **`NOFILES`** — keeps the library's file channels separate from the caller's; a `NOFILES` library also gets its **own console** (window #0); a library can't be both passed-files and `NOFILES`
- **Loading strategies** — *Resident* (loaded once, stays: `EXECUTE "LOAD lib,RESIDENT"`), *Present* (`LIBRARY "name":` with no functions loads it immediately, or named-with-functions loads it on the first call), *As-needed* (`LIBRARY RELEASE,…` — loaded per call, not searched by unnamed linkage)
- **Search order (unnamed)** — the **main program first**, then each loaded library in **reverse load order** (last-loaded first-searched); BR links to the **first** library where the function is defined, and that linkage sticks until reassigned; as-needed (`RELEASE`) libraries are **not** searched
- **Communication** — a library **can't see the main program's globals**; pass **parameters**, use the **return value**, or call **init functions**
- **Variable clearing** — main/resident functions clear when the main program ends; resident + `OPTION RETAIN` only when the library is cleared/reloaded; resident + `RELEASE` or as-needed after each call
- **Loopback** — a library function can call back into the main program via an **unnamed** `LIBRARY` link (the main program is treated as "loaded last"); uses fresh stack space
- **Reassignment** — re-executing `LIBRARY` for the same function but a different library relinks it; when all of a *present* library's functions are reassigned it is removed from memory; all linkages detach when the main program ends
- **Run a program as a function** — `LIBRARY RELEASE,NOFILES,"MNTCUST": FNMNTCUST` runs another whole program as a callable function
- **Errors** — an untrapped error in a library function is reported to the caller with `LINE`/`ERR`/`CNT` set; `STATUS LIBRARY` lists active linkages

**Common errors:**
- **Duplicate-function-definition** — naming a **local non-library** function on a `LIBRARY` statement
- **RELEASE conflicts** — referencing one library both with and without `RELEASE` errors; `RELEASE` with `OPTION RETAIN` errors

**Gotchas:**
1. **Must link before calling** — even a local `DEF LIBRARY` function needs a `LIBRARY` statement
2. **No shared globals** — communicate only via parameters / return value / init functions
3. **Load resident libraries first** — before application programs, to avoid memory fragmentation
4. **Editing a running library** — `REPLACE` has no effect until the main program ends and the library reloads; `CLEAR` a resident library before loading a replacement
5. **Don't name the current program** — it spawns a second, variable-isolated copy of the main program (confusing)

**Example code:**
```business-rules
! Named linkage — path + functions
00100 LIBRARY "PRESLIB": FNPRESLIB1, FNPRESLIB2
00110 LIBRARY "ENV$(BRLIBS)mylib.br": FNPROCESS, FNVALIDATE

! Load a resident library once, then link unnamed
01000 EXECUTE "LOAD RESLIB,RESIDENT"
01400 LIBRARY : FNALIBI                 ! unnamed — searches the loaded queue

! Run an entire program as a callable function (isolated files/vars)
50000 LIBRARY RELEASE,NOFILES,"MNTCUST": FNMNTCUST
50010 LET X = FNMNTCUST(CUST_ID$)
```

**See also:**
- DEF FN / FNEND (defining functions, incl. `DEF LIBRARY` and `&` by-reference params)
- EXECUTE (`LOAD …,RESIDENT` to preload a resident library)
- STOP / END / PAUSE / CHAIN (`CHAIN` vs. a library call; `OPTION RETAIN` across chains)
- [50-libraries/library-facility](../br_tree/50-libraries/library-facility/spec.md) — full LIBRARY linkage, loading, search-order reference (comprehensive)
- [10-language/flow-control/functions-udf](../br_tree/10-language/flow-control/functions-udf/spec.md) — `DEF LIBRARY` definition & scope

---

<a id="cross-reference-map"></a>
## Cross-Reference Map

| Statement | Category | Key Semantics | Primary Use |
|---|---|---|---|
| OPEN file | File I/O | File channel setup, access modes, locking | Acquire file for read/write |
| READ | File I/O | Sequential/keyed record fetch, position | Input records from file |
| REREAD | File I/O | Re-decode buffered record (no I/O), no reposition | Re-interpret current record / release lock |
| WRITE | File I/O | Append or REC= position, new record | Create records in file |
| REWRITE | File I/O | Update current record, partial updates | Modify existing record |
| DELETE | File I/O | Mark record deleted, space not reclaimed | Remove record from file |
| RESTORE | File I/O | Reposition file pointer, lock release | Jump to specific position or rewind |
| CLOSE | File I/O | Flush, finalize, DROP/FREE options | Close file and release channel |
| FORM | File I/O | Non-executable record/print-line layout referenced by `USING`; cycles over long lists; POS/X/SKIP, n*(...) repeats | Describe byte/column field layout |
| PRINT | Screen/Print | Output to #0 (screen) / #255 (printer), zones | Simple text output |
| OPEN window | Screen/Print | Bordered DISPLAY,OUTIN window; borders/caption, PARENT=NONE/MODAL | Open a mini-screen window |
| PRINT FIELDS | Screen/Print | Positioned full-screen output, formatting | Display at specific row/col |
| INPUT FIELDS | Screen/Print | Positioned full-screen data entry, validation | Accept formatted user input |
| RINPUT FIELDS | Screen/Print | Seeds fields with current values, then edits | Edit existing values in place |
| INPUT SELECT / RINPUT SELECT | Screen/Print | Menu choice over FIELDS; sets CURFLD/CMDKEY, reads no data | Full-screen menu selection |
| INPUT | Screen/Print | Comma-separated keyboard input, type check | Bottom-line data entry |
| LINPUT | Screen/Print | Whole-line input preserving delimiters | Read line with punctuation |
| Screen controls (COMBO/RADIO/CHECK/buttons) | Screen Controls | GUI controls on FIELDS; selection/click via FKEY; `^` selection sentinel; also date picker & picture/image fields | Combo/radio/check/button entry |
| GRID / LIST / TEXT | Screen Controls | 2-D table (GRID edit / LIST select) + multi-line text; HEADERS then data, read-types/selections | Tabular & multi-line entry |
| DISPLAY MENU / INPUT MENU | Screen Controls | Native Windows menu from 3 parallel MATs; MENU$/MENU, FKEY 98; INPUT MENU does not wait | Native drop-down menu bar |
| SORT | File/Data Mgmt | Sort an internal file via a .SRT control file (FILE/ALTS/RECORD/SUM/MASK) | Produce sorted output |
| INDEX | File/Data Mgmt | Create/rebuild a key index (split keys, REPLACE/REORG, Btree) | Fast keyed access |
| Database Operations | SQL/ODBC | Connect via CONFIG DATABASE; OPEN ...SQL, WRITE=execute, READ=fetch rows | Read/write an external SQL database |
| OPEN serial | File/Data Mgmt | Serial/RS-232 port as DISPLAY channel (FORMAT=ASYNC, BAUD, EOL) | Serial communications |
| OPTION | Declaration | Program statement `OPTION BASE 0/1` & `COLLATE NATIVE/ALTERNATE`; distinct from numbered `OPTION n` config toggles | Set array base / collation |
| DIM / MAT (redim) | Declaration | Array declaration, multi-dimensional, redimension | Define data structures |
| LET | Assign/Data | Optional LET, multiple (A=B=0), compound (+=,-=,*=,/=), call-for-effect | Assign / compute values |
| Forced assignment (:=) | Assign/Data | Assign inside a condition; yields the assigned value | Assign-and-test |
| MAT (array assignment) | Assign/Data | Whole-array init/copy/arithmetic, AIDX/DIDX sort index | Bulk array operations |
| Substring assignment | Assign/Data | Slice-on-left mutation: replace/delete/insert/append/prepend | Edit part of a string |
| DATA / READ / RESTORE (data table) | Assign/Data | Internal constant table; READ MAT; RESTORE pointer | Built-in data tables |
| IF / THEN / ELSE | Cond/Branch | Single-line & block decision; ELSE IF/END IF; THEN <line>=GOTO | Branch on a condition |
| GOTO | Cond/Branch | Unconditional jump to line/label; no stack effect | Jump / early loop exit |
| ON … GOTO / GOSUB | Cond/Branch | Computed n-th-target branch (rounded), NONE fallback | Jump / dispatch table |
| RANDOMIZE | Cond/Branch | Reseed RND from the system clock | Vary the random sequence |
| STOP / END / PAUSE / CHAIN | Cond/Branch | Halt/resume, end+close+CODE, breakpoint, chain to program | Terminate / interrupt / chain |
| FOR / NEXT | Flow Control | Fixed-count loop, variable persists | Counted iteration |
| DO / LOOP | Flow Control | Conditional loop, flexible test placement | Conditional iteration |
| GOSUB / RETURN | Flow Control | Subroutine call, call stack (default 100 nested, FLOWSTACK-configurable) | Structured code reuse |
| EXIT | Flow Control | Exit innermost loop early; EXIT condition groups | Break from loop / reusable handlers |
| EXECUTE | Flow Control | Run a command/statement string at runtime (INDEX/SORT/PROC/LOAD) | Run commands from code |
| ON condition | Error Handling | Program-wide per-condition trap (GOTO/GOSUB/IGNORE/SYSTEM), + ON FKEY | Trap a specific condition |
| ON ERROR | Error Handling | Catch-all error handler, last resort | Global error trap |
| RETRY / CONTINUE | Error Handling | Re-execute failing statement, or skip to next | Recover from / skip past an error |
| DEF FN / FNEND | Functions | User-defined function, by-value/reference params | Encapsulate computation |
| LIBRARY | Functions | Link FN functions across programs; named/unnamed, RELEASE/NOFILES, resident | Reuse functions across programs |

---

<a id="error-code-quick-reference"></a>
## Error Code Quick Reference

| Code | Condition | Common Cause |
|---|---|---|
| 0061 | Locked-record timeout | Record locked by another workstation; `WAIT=` period expired |
| 0500 | RETRY without error | No outstanding error to retry |
| 0608 | OUTIN order violation | OUTIN open must come before INPUT open |
| 4145 | TIMEOUT | No input within WAIT= period (LINPUT) |
| 4146 | File locked | Another workstation has file locked; wait timeout expired |
| 4150 | NEW file exists | Tried to create with NEW but file exists |
| 4270 | EOF | End of file (READ), no space (WRITE), or EOF data |
| 4271 | Short record | External file short final record (padded with nulls) |
| 4272 | NOKEY | Key not found in keyed access (READ/RESTORE) |
| CONV | Type mismatch | Numeric chars in numeric field, etc. |
| DUPREC | Duplicate record | WRITE to REC= that already exists |
| SOFLOW | String overflow | String too long for field |
| OFLOW | Numeric overflow | Number too large for field |
| ZDIV | Divide by zero | Division by zero |
| EXIT | Esc key | User pressed Esc during INPUT FIELDS |

---

<a id="quick-start-examples"></a>
## Practical Quick-Start Examples

### File Processing Loop
```business-rules
00100 OPEN #1: "NAME=input.int", INTERNAL, INPUT, SEQUENTIAL
00110 DO
00120   READ #1: RECORD$ EOF 200
00130   PRINT RECORD$
00140 LOOP
00200 CLOSE #1:
```

### Interactive Data Entry with Validation
```business-rules
00100 PRINT NEWPAGE
00110 PRINT FIELDS "1,1,C 80": "Data Entry Form"
00120 DO
00130   INPUT FIELDS "5,10,C 20;10,10,N 8.2": NAME$, AMOUNT CONV 150
00140   PRINT "Entered: ", NAME$, AMOUNT
00150   PRINT "Continue? (Y/N): ";
00160   INPUT CONTINUE$ CONV 150
00170 LOOP UNTIL CONTINUE$ = "N"
00150 PRINT "Invalid; please re-enter"
00160 RETRY
```

### Keyed Record Lookup and Update
```business-rules
00100 OPEN #1: "NAME=master.int,KPS=1,KLN=20", INTERNAL, OUTIN, KEYED
00110 PRINT "Enter customer key: ";
00120 INPUT CUST_KEY$ CONV 300
00130 READ #1, KEY=CUST_KEY$: NAME$, BALANCE NOKEY 200
00140 PRINT "Found: ", NAME$, "Balance: ", BALANCE
00150 LET BALANCE = BALANCE + 100
00160 REWRITE #1: NAME$, BALANCE
00170 CLOSE #1:
00180 END
00200 PRINT "Customer not found"
00210 GOTO 100
00300 PRINT "Invalid key"
00310 RETRY
```

### Multi-Way Menu Dispatch
```business-rules
00100 DO
00110   PRINT NEWPAGE
00120   PRINT "1=Add, 2=Delete, 3=List, 4=Exit: ";
00130   INPUT CHOICE
00140   ON CHOICE GOSUB ADD, DELETE, LIST, EXIT_PROG NONE INVALID
00150 LOOP

00200 ADD: PRINT "Add function" : RETURN
00300 DELETE: PRINT "Delete function" : RETURN
00400 LIST: PRINT "List function" : RETURN
00500 EXIT_PROG: END
00600 INVALID: PRINT "Invalid choice" : RETRY
```

---

**Document Status:** Extracted from `context/br_tree/` specs (2b status, verified and folded). Synthesized for LLM consumption. Last updated: 2026-08-08 — LET and DEF FN sections gained the trailing error-condition clause (`CONV`, etc.) and, for LET, the call-with-no-`LET`-keyword form; both were found missing from `context/br_tree/10-language/data-manipulation/assignment/spec.md` and `.../flow-control/functions-udf/spec.md` while fixing the brls parser gaps that had been rejecting them outright.
