---
title: SORT facility
file: spec.md
source: §SORT Facility
category: 40-io-printing
subcategory: 40-io-printing/sort
kind: spec
status: 2b           # reference base verified comprehensive; backing stubs pruned (NoSort → controls); no conflicts
related: [statements, keys-indexes]
keywords: [SORT]
---

# SORT facility

Produces sorted output from an internal file via a **sort control file** of specifications.
For ordered access *without* a separate sort, an index ([30-io-file/keys-indexes](../../30-io-file/keys-indexes/spec.md))
reads records in key order.

<a id="syntax"></a>
## Syntax

```bnf
SORT [<control-file>]          -- run from READY, a PROC, or EXECUTE "SORT file.SRT"
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

- [statements](../statements/spec.md) — printing the sorted report
- [30-io-file/keys-indexes](../../30-io-file/keys-indexes/spec.md) — keyed (index) order as an alternative
- [30-io-file/form-spec](../../30-io-file/form-spec/spec.md) — field form codes used in MASK/RECORD
- (Backing keyword pages were stubs, pruned. Grid `NOSORT` → [20-io-screen/controls](../../20-io-screen/controls/spec.md).)
