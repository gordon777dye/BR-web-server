---
title: File model (types, access, sharing)
file: spec.md
source: §File Operations (File Types/Modes/Access/Numbers), §Multi-User Programming
category: 30-io-file
subcategory: 30-io-file/file-model
kind: spec
status: 2b           # reference base + br_tree enrichment (linked files); no conflicts
recovered-fold: Display_Files, File_Handle, File_Ref, Multi-User_Programming, NEW, NOSHR, OUTIN, OUTPUT, REC, RECL, RELATIVE, RESERVE (12 redirect-collision pages folded from re-fetched source; verbatim retained on the BR wiki)
related: [statements, keys-indexes, form-spec]
keywords: [OPEN, INTERNAL, EXTERNAL, KEYED, RELATIVE, DISPLAY, SHR, RESERVE, RELEASE, LINKED, WSID, locking, INPUT]
corrections:
  - "RELEASE added to keywords. The spec documents the RELEASE I/O clause alongside RESERVE (§record locking: `RESERVE` keeps existing locks while reading more records; `RELEASE` reads without locking / drops locks) and the `PROTECT name,RELEASE` form, but declared only RESERVE. The keyword index is built from this list, so the table4k RELEASE clause routed to 50-libraries/library-facility — which documents `LIBRARY RELEASE`, an unrelated sense — and not here."
---

# File model (types, access, sharing)

The concepts behind BR file I/O: file types, usage modes, access methods, file numbers, and
multi-user sharing/locking. The statements that act on files are in
[statements](../statements/spec.md); record layout is [form-spec](../form-spec/spec.md); keyed
access is [keys-indexes](../keys-indexes/spec.md).

<a id="semantics"></a>
## Semantics

<a id="file-types"></a>
### File types
| Type | Format | Access | Modes | Notes |
|---|---|---|---|---|
| **Internal** | binary, fixed-length records | SEQUENTIAL / RELATIVE / KEYED | INPUT / OUTPUT / OUTIN | most efficient; supports SORT/INDEX, in-place update/delete (`.int`,`.dat`) |
| **Display** | human-readable ASCII | SEQUENTIAL only | INPUT / OUTPUT (not OUTIN) | viewable via `TYPE`; uses PRINT/INPUT/LINPUT (`.txt`,`.dis`) |
| **External** | various | SEQUENTIAL / RELATIVE | INPUT / OUTPUT / OUTIN | foreign formats / data streams |

**Display-file specifics.** Display files (`.txt`/`.dis`) hold BR's own procedures, source programs and
`BRConfig.sys` as well as report/printer output. Records are **variable-length** with an optional
programmer-set delimiter (OPEN `EOL=`); the default record length is **132** (matching wide-carriage
printers). Record length doesn't limit *input* — a string longer than the record can be read if its
variable is dimensioned big enough — but on **output** a string longer than the record length is split
into 132-char (or `RECL=`) records. No formatted I/O: input is `INPUT`/`LINPUT`, output is `PRINT`.
They can't be BR-indexed or built-in-sorted, but `AIDX`/`DIDX` in a `MAT` can sort on them; view one
with the `TYPE` command. `OUTIN` is unsupported except on communications files.

<a id="usage-modes"></a>
### Usage modes
- **INPUT** — read only (File → program); READ, REREAD.
- **OUTPUT** — write new data (program → File); WRITE. Creates/overwrites; pointer at end (append).
- **OUTIN** — read + modify in place (internal files only); READ/REREAD/WRITE/REWRITE/DELETE.

<a id="access-methods"></a>
### Access methods (internal files)
- **Sequential** — records in stored order; pointer moves front→back (default).
- **Relative** — direct access by record number (`REC=`); internal only. (`RELATIVE`/`ABSOLUTE` *also*
  appear in `OPEN` *window* statements to qualify SROW/SCOL — that screen sense is in
  [20-io-screen/windows-cursor](../../20-io-screen/windows-cursor/spec.md), not here.)
- **Keyed** — access by key field value (exact or next-higher); internal only — see
  [keys-indexes](../keys-indexes/spec.md).

The **`REC(n)`/`LREC(n)`** functions report the last-processed and last record numbers (handy for a
running `PRINT REC(n);"of";LREC(n)` counter). `REC(n)` returns **−1** if the channel isn't open, and for
**external** files returns the *byte* number when the last I/O used `POS=` instead of `REC=`. Using
`REC` *inside* an I/O statement is discouraged on multi-user systems.

Statement availability by mode:

| Statement | INPUT | OUTPUT | OUTIN |
|---|:---:|:---:|:---:|
| READ / REREAD | ✓ | | ✓ |
| WRITE | | ✓ | ✓ |
| REWRITE / DELETE | | | ✓ |
| RESTORE | ✓ | ✓ | ✓ |

<a id="records-fields"></a>
### Records & fields
A **record** is a line of related information made of **fields** (programmer-defined length and
placement, numeric or character, no limit on count). Plan the layout — field types, lengths,
positions, total record length — before creating an internal file; describe it with a
[FORM](../form-spec/spec.md).

<a id="file-numbers"></a>
### File numbers (channels)
Per the OPEN grammar, channels are `0–200 | 253 | 255 | 300–999`. Reserved: **#0** = main
console/screen (pre-opened), **#255** = default printer (implicit open on first use). The rest are
user files. Channels **300–999** were added in **4.14**; #255 is the printer by convention, not
exclusively.

<a id="file-ref"></a>
### File references & OPEN parameters
A **file-ref** is the full specification of a file wherever the grammar calls for one:
`[<drive>:][<path>]<name>[.<ext>]` — defaults are the current drive, the default directory and a null
extension, so only the name is strictly required. A legacy System/23 form
`<name>[.<ext>][//<drive-name>|/<subdir>][/<drive-number>]` is accepted for converted code only. The
`SAVE`/`OPEN` dialog keywords may stand in for a file-ref to pop the standard Windows Save/Open picker.

Two OPEN parameters that belong to the file model itself:
- **`NEW`** — create the file; if a file of that name already exists the OPEN fails with **error 4150**.
- **`RECL=<n>`** — record length; **required when creating** a file but **never given for an existing
  internal file** (BR stores it in the file's header record). Efficient internal lengths are `2^N−1`
  (table below); `RLN(n)` returns the current record length.

<a id="sharing"></a>
### Multi-user sharing (share-spec)
BR runs identically on **centralized** (Unix/Linux — one shared CPU) and **distributed** (networked
PCs — a CPU per station) multi-user systems; the difference is throughput and cost, not semantics, so
the same sharing/locking code works on both. The share-spec governs whether **other** OPENs may access
the file — it does *not* restrict the current OPEN's own I/O level — and closing the file releases its
share restrictions. Code these even in single-user programs (it's far cheaper than retrofitting later).
- **NOSHR** — exclusive (default when no share-spec is given); no other open permitted (own workstation
  too, except multiple indexes). Use it for batch updates, record purges and temp work files.
- **SHRI** — others may open **INPUT only** (good during batch update / SORT).
- **SHR** — full sharing; records lock individually during OUTIN update. Conflicts raise
  **error 4148**.

<a id="locking"></a>
### Record & file-name locking
- With `SHR,OUTIN`, a record **locks automatically on READ** and stays locked until another record
  is read, it is rewritten, `RELEASE`/`RESTORE` is used, or the file closes.
- `RESERVE` keeps existing locks while reading more records (multi-record updates; must be repeated
  on each I/O); `RELEASE` reads without locking / drops locks. `WAIT=<seconds>` (default 15) before
  **error 0061** on a locked record.
- **Lock zone & file size** — BR locks not the record itself but a byte in a reserved zone keyed to the
  record number (so locking works on growing files and lets `ODBC`/report writers read locked records).
  That zone caps the lockable file size: [`OPTION 33`](../../00-configuration/config-directives/OPTION_(Config).md)
  selects `30` = 1 GB, `31` = 2 GB, `32` = 4 GB, or `64` = 64-bit locking for larger files (the default
  as of BR 5.01 on Windows, Linux and macOS). Every engine sharing files must use the same setting.
- **File-name locking** — the `PROTECT` command takes one of four parameters: **`RESERVE`** (deny others
  any access to the full pathname — BR checks an internal reservation table before *every* OPEN and
  returns **error 4148** *without touching the disk*), **`READ`** (others may read but not change it;
  file must exist — write-protect), **`WRITE`** (lift read-only; all may read and write), and
  **`RELEASE`** (drop this workstation's reservation — only the originating workstation may release).
  The OPEN `RESERVE` parameter reserves a name the same way; release it with `PROTECT name,RELEASE` or
  `CLOSE #n,RELEASE`. A name can be reserved even for a file that doesn't exist (or after `FREE`),
  enabling safe copy/rename/reindex sequences. *(Caveat: on the IBM Network, RESERVE/RELEASE only
  verify a record is free — they don't actually reserve it, so RELEASE has no effect there.)*

<a id="linked"></a>
### Linked files (OPEN … LINKED)
An internal file opened **`LINKED`** holds one or more **linked lists** of records — useful to
attach a group of records to a master record (e.g. notes per customer) when access is only ever
*through* that master. Often **2–3× faster than indexed** files with less overhead, performance
doesn't degrade with size, and records can be inserted anywhere. Each linked record reserves its
**first 8 bytes** for two `BH 4` pointers — **next** (positions 1–4, `0` = last) and **previous**
(positions 5–8) — maintained by BR; don't overwrite them (read with `FORM 2*BH 4` if needed). The
list head is the [Anchor_Record](Anchor_Record.md). Drawbacks: corrupted lists are hard to rebuild,
and insertion order isn't recoverable.

<a id="wsid"></a>
### Workstation ID
`[WSID]` in a filename is replaced with the workstation's unique ID (`WORK[WSID]`); the `WSID$`
function returns it as a string — used to build per-workstation temp/index files. BR treats `[WSID]`
as a special `SUBSTITUTE` default and accepts it in any case, effectively applying
`NAME$ = SREP$(NAME$,1,"[WSID]",WSID$)` to every file reference (all names are upper-cased for
processing); `STATUS` shows the current WSID. It's indispensable when two workstations run the same
program — every temp/output/index name must be unique or one run will fail.

<a id="slash"></a>
### A `/` in a file name (BR 5.0, `OPTION 84`)

A name with a `/` in it can be read two ways: as a System/23 name, **`file/directory/drive`**
(`CUST/DATA/2` is file `CUST` in directory `DATA` on the drive that 2 stands for, and `file//10` and
`file//11` are the spooler and AUX), or as a **folder separator**, so that `data/rpt/a.dat` is
`data\rpt\a.dat`. BR does not look at the disk to decide. It resolves the name the way
it prefers and, if the file or folder is **not found** (error 4152 or 4203), tries the other reading
before giving up. If both fail the error is the first reading's, except that "file not found" replaces
"path does not exist" when the other reading found the folder - that is what lets a file be created.

The first reading is the System/23 one if the name has a `\` in it, has only one `/`, or has `//` and a
digit (which is never read any other way); otherwise it is the folder one. `OPTION 84` changes that
(see [OPTION (config)](../../00-configuration/config-directives/OPTION_(Config).md)); level `0` is the
behaviour of earlier releases.

When both readings exist the first wins, so a name can mean different files as folders are created
or removed. Names with a drive letter or a device (`C:/data/x`, `PRN:/10`, `PDF:/x`) have only one
reading.

<a id="tables"></a>
## Tables

| RECL tip | value |
|---|---|
| Efficient internal record lengths | `2^N − 1` → 7, 15, 31, 63, 127, 255, 511, 1023 |
| Sharing conflict | error **4148** |
| Locked-record timeout | error **0061** (after `WAIT=`) |

<a id="examples"></a>
## Examples

```business-rules
! TYPE shows a display file (not internal/binary)
TYPE C:\REPORT.TXT
! Per-workstation temp file name
00100 LET TEMPFILE$ = "WORK" & WSID$ & ".TMP"
```
```business-rules
! Multi-record lock: lock every line of an order, verify stock, update, release all.
00210 READ #3,USING 220,KEY=ITEM$(X),RESERVE: QTY,ALLOC   ! RESERVE keeps prior locks held
00230 IF QTY(X)>QTY-ALLOC THEN RESTORE #3: : GOTO 100      ! out of stock -> drop all locks
00240 ALLOC(X)=ALLOC+QTY(X) : R(X)=REC(3)                  ! save REC for a faster rewrite
00260 REWRITE #3,USING 270,REC=R(X),RESERVE: ALLOC(X)
00290 RESTORE #3:                                          ! release ALL record locks
```
```business-rules
! Graceful file-lockout recovery (record/file already locked -> error 4148)
00100 OPEN #1: "NAME=...",INTERNAL,OUTIN,SHR  IOERR CONFLICT
00500 CONFLICT: IF ERR=4148 THEN PRINT "File in use - <CR> retry, F10 quit" ELSE 510
00510 LINPUT X$ : IF CMDKEY=10 THEN STOP ELSE RETRY
```

<a id="see-also"></a>
## See also

- [statements](../statements/spec.md) — OPEN/READ/WRITE/… that use these modes & shares
- [keys-indexes](../keys-indexes/spec.md) — keyed access & the index facility
- [form-spec](../form-spec/spec.md) — record layout (FORM)
- Backing keyword pages (deep detail retained): [OPEN_internal](OPEN_internal.md),
  [PROTECT](PROTECT.md), [LINKED](LINKED.md), [Multi-User_Considerations_Tutorial](Multi-User_Considerations_Tutorial.md),
  [Anchor_Record](Anchor_Record.md). Others folded into this spec and pruned.
  The 12 redirect-collision pages re-fetched in 2b — `Display_Files`, `File_Handle`, `File_Ref`,
  `Multi-User_Programming`, `NEW`, `NOSHR`, `OUTIN`, `OUTPUT`, `Rec`, `RecL`, `Relative`, `Reserve` —
  were folded here and pruned; verbatim wikitext remains on the BR wiki.
