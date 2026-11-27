---
title: SORT command and facility
file: spec.md
source: §SORT Facility
category: 70-commands
subcategory: 70-commands/sort
kind: spec
status: 2b           # reference base verified comprehensive; backing stubs pruned (NoSort → controls); no conflicts
related: [statements, keys-indexes]
keywords: [SORT, EXECUTE]
corrections:
  - "Moved from 40-io-printing/sort to 70-commands/sort (2026-11-01): SORT is a READY command - it is in the command table (tblcmd.cpp, SORT_CMD) and takes `-N` - and a command is filed where the commands are, as CHAIN was moved out of 70-commands for being a statement. The facility itself (the control file) is unchanged; its page still reads as the printing reference, and 40-io-printing/statements links here."
  - "FILE described position by position (2026-11-16), from sort.cpp's parser (the FILE branch and file_name): the eleven positions, each file's name/path/drive triple, the defaults, REPLACE and the share words, the file-spec codes including `3` and `I`, and that an explicit `N` or `A` wins over the configuration's COLLATE (sort.cpp changed the same day so that `N` does)."
  - "Control files may be text as well as internal, and RECORD limits plain values with @ for a position (2026-11-16, sort.cpp changed the same day). Tested: context/scratch/sorttest/st4.brs (plain 20,60 and TX, @13) and st5.brs (CRLF, LF, no final line end, two sorts in one text file, an internal file)."
  - "RECORD described from sort.cpp and tested (2026-11-16, context/scratch/sorttest/st4.brs): I and O, OR and AND chains, quoted values (numeric ones too), unquoted limits as positions, and that a trailing ! comment is refused on FILE/RECORD/MASK (7804/7805/7807) - the example's trailing comments were moved to a comment line."
  - "Index-out (`I`) described (2026-11-16) after sort.cpp was changed to build it as INDEX builds an ISAM index (key_build entries, FKWRITE, the sorted count recorded); tested: 8 and 10 records with C, PD and C+PD keys under both collating sequences, every record found by its key; 150,000 records through the work file (MAX_SORT_MEMORY 2 MB), in order, 2,000 lookups found, 5 records written through the index and found; D refused with 7807."
  - "MASK field limits corrected from sort.cpp (2026-11-16): the parser holds 20 fields (mask[20], refused at m == 20 with 7807), not 10; index-out takes at most MAX_KEY_FIELDS = 6 (basic.h). A 7th index-out field was reported as 7829, whose message is about RECORD; sort.cpp was changed the same day to report it as 7807 (MASK syntax). Tested (context/scratch/sorttest/st6.brs): 5 and 6 index-out fields build indexes in which every record is found by its own key; a 7th is 7807 and writes no index; 7 fields with R sort normally."
  - "Added the command: how it is run (READY, a PROC, EXECUTE), the `-N` option, what running it does to a program in memory, and the command-help line `SORT control-file [-N]` (wbos.cpp s_commandHelp), all from the source (command7.cpp SORT_CMD; wbos.cpp)."
---

<a id="sort"></a>
# SORT command and facility

Produces sorted output from an internal file via a **sort control file** of specifications.
For ordered access *without* a separate sort, an index ([30-io-file/keys-indexes](../../30-io-file/keys-indexes/spec.md))
reads records in key order.

<a id="syntax"></a>
## Syntax

```bnf
SORT [<control-file>] [-N]     -- run from READY, a PROC, or EXECUTE "SORT file.SRT"
```

<a id="control-file"></a>**The control file is a text file or an internal file**, one specification per
line or record; trailing blanks are ignored, and so are blank lines.

- **A text file**, written with an editor or by a program as a `DISPLAY` file: lines may end in
  CR LF or LF, and the last needs no line end. A line may be up to 490 characters (longer is
  error 1060).
- **An internal file**, written by a program with `OPEN ... INTERNAL, OUTPUT` and a `WRITE` of
  each line as a `C` field.

A `SORT` with no file name in a procedure reads the specifications from the procedure's own lines
that follow it instead, as in the first example below; given a name, or run from `READY` or
`EXECUTE`, it reads the control file. One control file may hold several sorts, each from its
`FILE` to its `MASK`.

A control file holds up to six specification types, in this order:

| Spec | Req | Purpose |
|---|---|---|
| `!` comment | no | message to operator |
| `FILE` | **yes** | input/output/work files + parameters (first) |
| `ALTS` | no | reorder/equate the collating sequence |
| `RECORD` | no | include/omit records |
| `SUM` | no | display record counts |
| `MASK` | **yes** | define sort fields (must be **last**) |

<a id="semantics"></a>
## Semantics

<a id="sort-command"></a>**The SORT command** reads the control file and runs the sort. `SORT -?` lists its
form, as it does for any command: `SORT control-file [-N]`.

- **`-N`** shows nothing while it sorts. As for every command, an option is a dash and letters or
  digits and may stand anywhere in the line ([command-signatures](../command-signatures.md#unspecified)).
- **Where it can be run.** At the `READY` prompt, from a procedure, or from a program with
  `EXECUTE "SORT <control-file>"`. `INDEX` and `SORT` are the two commands `EXECUTE` starts
  without a `CLEAR` first, so a sort run that way has more memory than one run after it
  ([program-management](../program-management/spec.md#execute)).
- **What it does to the program in memory.** At `READY` with no program interrupted, BR clears the
  program and its data and loads its sort module to do the work. When a running program has been
  interrupted, the sort is done in place and the program is left as it was.
- **The whole word is needed.** `SORT` cannot be abbreviated: a shorter start of it is not the
  command (the table must match exactly, commandc.cpp), and the line is taken for a calculation.
- Errors in the control file or the files it names are in the 78xx range: see
  [error codes](../../90-reference/error-codes/7801.md).

<a id="file"></a>**FILE** — names the three files and how the sort runs. It must be the first
specification after any comments, and comes once per sort: after a `MASK`, another `FILE`
starts a further sort from the same control file.

```bnf
FILE <in-name>,[<in-path>],[<in-drive>],<out-name>,[<out-path>],[<out-drive>],
     [<work-name>],[<work-path>],[<work-drive>],[<file-spec>],[<collating>]
     [,REPLACE] [,<share-spec>]
```

The parameters are positional, separated by commas; an empty position takes its default, so
leave its comma in (`FILE orders.int,,,sorted.int`). The line is read in upper case.

| # | Parameter | Meaning | Default |
|---|---|---|---|
| 1 | in-name | The file to sort. It must be an internal file (error 7810). | required |
| 2 | in-path | A folder put in front of the name: `<path>\<name>`. | none |
| 3 | in-drive | One character: a drive letter, put in front as `<drive>:`. More than one character is error 7804. | none |
| 4 | out-name | The file the sort writes. It is created if it does not exist. If it exists it must be empty (error 7832) and its records long enough for the output (error 7831), unless `REPLACE` is given. | required |
| 5 | out-path | As in-path, for the output file. | none |
| 6 | out-drive | As in-drive, for the output file. | none |
| 7 | work-name | The sort's work file, deleted when the sort ends. | `SORT<session>.WRK` in the current folder (with the login name added when the work-file names carry it) |
| 8 | work-path | As in-path, for the work file. | none |
| 9 | work-drive | As in-drive, for the work file. | none |
| 10 | file-spec | What each output record holds - see below. | `R` |
| 11 | collating | `N` native or `A` alternate collating sequence, the order character fields are sorted in (`ALTS` changes it further). | native, or alternate when the configuration has [`COLLATE ALTERNATE`](../../00-configuration/config-directives/spec.md#collate) |
| 12+ | `REPLACE` | Replace the output file if it exists, instead of writing into an empty one. | the existing file is used |
| 12+ | share-spec | How the input file is opened: `NOSHR` (no one else may open it), `SHRI` (others may open it only for input), `SHR` or `SHRU` (others may update it; records are read with `RELEASE`). | `SHRI` |

`REPLACE` and the share-spec may come in either order after position 11. Any other word there,
or a bad value in positions 10 or 11, is error 7804. The output file is always opened `NOSHR`.

**file-spec** (position 10):

| Code | Output record | Output record length |
|---|---|---|
| `R` | record-out: the whole input record, in sorted order | the input file's |
| `A` | address-out: the input record number as `PD 3` (up to 99,999 records) | 3 |
| `B` | address-out: the input record number as `B 4` (up to 2,147,483,647 records) | 4 |
| `3` | address-out for System/36 programs: the record number less one, as `B 3` | 3 |
| `I` | index-out: an ISAM index of the input file, named out-name, its key the `MASK` fields | the `MASK` fields' total length, plus 4 |

An address-out file is read with the input file opened `RELATIVE`: each record gives the
next record number to read, in sorted order.

<a id="index-out"></a>**Index-out (`I`).** The output is an ISAM index of the input file, the same
as `INDEX ... ISAM` would build, so it is used as one:
`OPEN #n: "NAME=<in-name>,KFNAME=<out-name>", INTERNAL, INPUT, KEYED`, and records written
through it are added to it. Its key is the `MASK` fields, in their order, as they stand in the
record; keyed reads follow the index's order, as for any index, so a `PD` key's negative values
come after its positive ones. Only the records `RECORD` selects get an entry. Creation of an ISAM 
index has the following limitations:

- Every `MASK` field must be ascending: `D`, or the `Y` of BASEYEAR order, is error 7807.
- At most **six** `MASK` fields, one for each part of an ISAM key (as `KPS=`/`KLN=` allow at
  `OPEN`); a seventh is error 7807. The check is made as the `MASK` line is read, so nothing is
  written.
- The collating sequence (position 11) is the index's own and stays with it; `ALTS` does not
  apply.
- `REPLACE` replaces an existing index; without it an existing out-name must be non-existent (7832).

`N` and `A` in position 11 apply whatever the configuration's `COLLATE` says; a blank position
takes the configuration's sequence.

<a id="alts"></a>**ALTS** — `RO,<start>` reorders characters from a value; `EQ,<value>` equates a
set to one value (e.g. make upper match lower; sort digits equal).

<a id="record"></a>**RECORD** — `{I|O},<pos>,<len>,<form>,<low>,<high>[,{AND|OR}]` includes (`I`) or
omits (`O`) the records whose field at `<pos>`, `<len>` bytes in form `<form>`, lies between the
two limits, both included.

- **A limit is a value, quoted or plain**: `"TX"` or `TX`, `"20"` or `20`, up to 40
  characters. A plain value is read in upper case and cannot hold a comma, so quote text that
  has lower case letters or commas: `RECORD I,1,10,C,"apple","fig"`.
- **`@` and a number is a position in the record**: the field of the same length and form
  starting there is the limit, so a record can be compared with another of its own fields:
  `RECORD I,13,4,PD,@17,@21`. Past the end of the record is error 7829.
- **An empty limit** (`,,`) is the lowest or the highest value.
- **`OR`** ties the line to the next one: the record passes if either does. **`AND`**, or nothing,
  ties it so that both must. `OR` on the last `RECORD` line is ignored.
- Up to 20 `RECORD` lines (a 21st is error 7825); a low limit above the high one is error 7830.

**No comment after a specification.** Only a line that starts with `!` is a comment. A `!` after
a `FILE`, `RECORD` or `MASK` line is a syntax error in it (7804, 7805, 7807); an `ALTS` line
ignores what follows its last value.

<a id="mask"></a>**MASK** — `<pos>,<len>,<form>,{A|D}[,…]` lists up to **20** sort fields
(ascending/descending); a 21st is error 7807. Index-out (`I`) takes at most six
([above](#index-out)). Form codes: `B`/`BL`/`BH`, `C`, `D`, `L`, `N`, `PD`, `S`, `ZD`. Max total
key length 32,767 bytes. Append **`Y`** to `A`/`D` for BASEYEAR Y2K date handling.

<a id="sizing"></a>
**Space and limits.**
- **Temporary work space** (address-out and record-out sorts alike): *records selected* x 2 x (*sort key length* + 4), rounded
  up to a multiple of **1024** bytes.
- **Address-out output file, `A` (PD3 format):** *records selected* x 4 + 15, rounded up to a multiple of **512**; the
  record limit is **99,999** records.
- **Address-out output file, `B` (B4 format):** *records selected* x 5 + 16, rounded up to a multiple of **512**; the
  limit is 2,147,483,647 (2**31-1) records.
- **Record-out output file, `R`:** *records selected* x (*record length* + 1), rounded up to a multiple of **512**.
- BR **clears the controls, collating sequence included, that one sort group set** before it runs the next group in the
  same control file. All commas of the `FILE` specification must be present even when some parameters are omitted.

<a id="examples"></a>
## Examples

The specifications in a procedure, after a `SORT` with no file name:

```text
Sort
! TX/LA customers, record-out, replace, shared
FILE orders.int,,,samplesort2,,,,,R,,REPLACE,SHR
! upper case sorts with lower; by field@31, then field@1
ALTS RO,97,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
RECORD I,106,2,C,"TX","TX",OR
RECORD I,106,2,C,"LA","LA",OR
SUM
MASK 31,30,C,A,1,30,C,A
```
A program writing a control file and running it, here to build an ISAM index of `CUSTOMER.INT`
on its name field:

```business-rules
99000 OPEN #20: "NAME=CUSTOMER.SRT,RECL=128,REPLACE", INTERNAL, OUTPUT
99010 WRITE #20, USING 99020: "FILE CUSTOMER.INT,,,CUSTNAME.IDX,,,,,I,,REPLACE"
99020 FORM C 128
99030 WRITE #20, USING 99020: "MASK 1,30,C,A"
99040 CLOSE #20:
99050 EXECUTE "SORT CUSTOMER.SRT"
```

<a id="see-also"></a>
## See also

- [statements](../../40-io-printing/statements/spec.md) — printing the sorted report
- [30-io-file/keys-indexes](../../30-io-file/keys-indexes/spec.md) — keyed (index) order as an alternative
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — field form codes used in MASK/RECORD
- (Backing keyword pages were stubs, pruned. Grid `NOSORT` → [20-io-screen/controls](../../20-io-screen/controls/spec.md).)
