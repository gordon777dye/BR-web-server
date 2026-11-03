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

<a id="file"></a>**FILE** — input, output, and work paths plus:
- **file-spec**: `R` record-out (full records) · `A` address-out PD3 (≤99,999 recs) · `B`
  address-out B4 (≤2.147 billion recs).
- **collating**: `N` native · `A` alternate. Plus `REPLACE` and a share-spec.

<a id="alts"></a>**ALTS** — `RO,<start>` reorders characters from a value; `EQ,<value>` equates a
set to one value (e.g. make upper match lower; sort digits equal).

<a id="record"></a>**RECORD** — `{I|O},<pos>,<len>,<form>,<low>,<high>[,{AND|OR}]` includes (I) or
omits (O) records whose field falls within limits; chain with AND/OR.

<a id="mask"></a>**MASK** — `<pos>,<len>,<form>,{A|D}[,…]` lists up to **10** sort fields
(ascending/descending). Form codes: `B`/`BL`/`BH`, `C`, `D`, `L`, `N`, `PD`, `S`, `ZD`. Max total
key length 32,767 bytes. Append **`Y`** to `A`/`D` for BASEYEAR Y2K date handling.

<a id="examples"></a>
## Examples

```text
Sort
! TX/LA customers, record-out, replace, shared
FILE orders.int,,,samplesort2,,,,,R,,REPLACE,SHR
ALTS RO,97,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"   ! upper matches lower
RECORD I,106,2,C,"TX","TX",OR
RECORD I,106,2,C,"LA","LA",OR
SUM
MASK 31,30,C,A,1,30,C,A                   ! by field@31 then field@1, ascending
```
```business-rules
99000 EXECUTE "SORT CUSTOMER.SRT"
```

<a id="see-also"></a>
## See also

- [statements](../../40-io-printing/statements/spec.md) — printing the sorted report
- [30-io-file/keys-indexes](../../30-io-file/keys-indexes/spec.md) — keyed (index) order as an alternative
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — field form codes used in MASK/RECORD
- (Backing keyword pages were stubs, pruned. Grid `NOSORT` → [20-io-screen/controls](../../20-io-screen/controls/spec.md).)
