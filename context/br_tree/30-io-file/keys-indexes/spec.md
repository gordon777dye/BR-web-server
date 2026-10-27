---
title: Keyed access & the index facility
file: spec.md
source: §File Operations → Keyed File Processing (Index Facility); br_tree keyed pages folded in & pruned (2b) — INDEX/Index_Facility retained
category: 30-io-file
subcategory: 30-io-file/keys-indexes
kind: spec
status: 2b           # reference base + br_tree enrichment
recovered-fold: BTREE, Key_Spec, KFNAME, KLN, KREC (5 redirect-collision pages folded from re-fetched source — Btree2 no-mix rule, KLN/KPS split-key segment param, KREC=index-record vs REC=master + display/linked behavior; verbatim retained on the BR wiki)
related: [statements, file-model, form-spec]
keywords: [INDEX, KEY, SEARCH, KEYED, KEYONLY, REORG, VERIFY, BTREE_VERIFY, KLN, KREC]
corrections:
  - "KEYONLY declared in the frontmatter keywords and given an anchor, so the statements spec can link to it: this page owns the index side of the construct and READ's own production now admits it. Also corrected on the same list: `DELETE #n, KEY=k$:` said \"only KEY= is allowed (not >=/SEARCH)\", which is right about the key parameters and wrong as a whole - DELETE also takes REC=, LINK= and the positional five, from its syn.txt tree and confirmed in the second corpus. Found in brls phases 13 and 15; see lsp/brls/LSP_PLAN.md findings 40 and 41."
  - "BTREE_VERIFY added to the frontmatter keywords. `BTREE_VERIFY <master>[ OFF]` is documented on this page and was not declared. Found in brls phase 13."
  - "KLN and KREC added to the frontmatter keywords. Both functions are documented in this page's
    Functions bullet (key length and last index-file record accessed, alongside KPS — KPS itself
    routes via its own dedicated row in system-functions/spec.md, so it wasn't added here too) and
    were routing nowhere. Found 2026-09-11 auditing `go run ./cmd/gendata`'s unrouted-function
    list against actual br_tree content."
---

# Keyed access & the index facility

Building and using index (key) files for fast record access by key value. The OPEN/READ/REWRITE
statements are in [statements](../statements/spec.md); access-method concepts in
[file-model](../file-model/spec.md); record layout in [form-spec](../form-spec/spec.md).

<a id="semantics"></a>
## Semantics

### How it works
An **index/key file** holds each master record's **key value** plus its **relative record number**
(binary `B 4`). To fetch by key, BR binary-searches the index, gets the record number, and jumps
straight to the master record — no sequential scan. Reading a keyed file **without** a `KEY=`
clause returns records **in key order** (a free sort).

- **Key field**: up to **6 non-contiguous sections** (a *split key*), **≤128 bytes** total.
- **Index types**: **Btree2** (the default for new indexes, ~25–35% faster shared I/O,
  `BTREE_VERIFY <master>[ OFF]` audits structure after each index-altering op), Btree (`OPTION 22`
  makes new indexes Btree), ISAM (`OPTION 5 = 4`). The option decides only what a **new** index is
  made as (`INDEX`, `INDEX … REPLACE`, an `OPEN` that creates the key file); each index records its
  kind in its header and is opened as that kind whatever the option says. One master may have Btree
  and Btree2 indexes open and updated together. `INDEX … REPLACE` converts an index to the kind the
  option asks for.
- **Btree2 locking (5.01)**: a shared Btree2 index has no lock for the whole of it; each index
  record has its own. A read holds each record it passes through only until it has the next one, an
  update only the records it changes (usually one), so sessions wait only for one using the same
  part of the index. `NOSHR` takes no locks. **Version 3:** the first 5.01 update (or `REORG`) marks
  a Btree2 index version 3, and new ones are version 3. Earlier releases refuse it with error 4124,
  so never run 5.01 and an earlier release on the same Btree2 index; upgrade them together.
- **Primary vs overflow area**: `INDEX … REORG` sorts the overflow (recently added/changed) into
  the sorted primary area.

<a id="index"></a>
### INDEX command (create/rebuild)
```bnf
INDEX <master-file> <key-file> <key-positions> <key-lengths> [<work-path>]
      [REPLACE] [REORG] [VERIFY] [DUPKEYS] [LISTDUPKEYS] [BADKEYS] [LISTBADKEYS]
      [ '>' <output-file> ] [NATIVE]
```
- Positions/lengths use `/` to separate up to 6 sections; append **`Y`** for `BASEYEAR` (Y2K)
  date handling (`23Y`; for binary date fields `2BY`).
- `REPLACE` rebuilds; `VERIFY` checks a Btree2 index (below); `DUPKEYS`/`LISTDUPKEYS` and
  `BADKEYS`/`LISTBADKEYS` control duplicate/invalid-key handling (`BADKEYS` = Y2K/baseyear keys whose
  master field holds non-numeric data; with both, bad keys list before dup keys); `>file` redirects
  the list. Parameters may be separated by **spaces or commas**; key fields **may overlap**.
- `REORG` reorganizes the index directly (no master read) — fast, since the already-sorted part is
  skipped. It does **not add new records** (keep the overflow current by opening the index whenever
  you write the master). It **fully rebuilds** only when the index is absent, isn't an index file,
  or the stored key positions/lengths differ from those given. For a Btree2 index, `REORG` repairs
  instead (below).
- **Btree2: `VERIFY` and `REORG`.** `VERIFY` runs while programs use the index (no exclusive
  access). It checks key order, that no record is reached twice, that every live master record's
  key is present, and that no update was left unfinished. Anything that looks wrong is rechecked
  once any update of that part has finished, so updates in progress are not reported. Clean: no error, and an old
  `<index file>.flaws` is deleted. Otherwise error **9401**, the flaws are written to
  `<index file>.flaws` (one per line, kind first: `OUT_OF_RANGE`, `STALE_REF`, `SEPARATOR`,
  `MISSING`, `INTERRUPTED`, `STRUCTURE`), and the index is marked as needing repair. Freed index
  records are not reused until it is repaired. `REORG` needs the index to itself. It checks the
  ranges `.flaws` names (or everything, master file included, without one), repairs them in place,
  adds missing keys, puts unused records on the free list, shortens the file,
  then clears the mark and deletes `.flaws`. When the index cannot be repaired (`STRUCTURE`), it
  rebuilds it from the master file as `REPLACE` does.
- `INDEX` performs an implicit `CLEAR` (unless a program is active), runs from READY mode / a
  procedure / `EXECUTE`, can be interrupted with `Ctrl-A` and resumed with `GO`; `-N` suppresses the
  action log.

<a id="open-keyed"></a>
### Opening for keyed access
```business-rules
! existing keyed file (no RECL/KPS/KLN)
00500 OPEN #5: "NAME=ACCT.INT,KFNAME=ACCT.KEY", INTERNAL, INPUT, KEYED
! new keyed file (include RECL, KPS, KLN)
00100 OPEN #1: "NAME=ACCT.INT,RECL=31,KFNAME=ACCT.KEY,KPS=1,KLN=4", INTERNAL, OUTIN, KEYED
```
A master file may have **multiple index files** (different `KFNAME`, different channels, same
master name; consistent share params).

<a id="key-clause"></a>
### KEY vs SEARCH
| Clause | Match |
|---|---|
| `KEY=k$` | exact; `k$` length must equal `KLN` (else error 0718); `NOKEY` if absent |
| `KEY>=k$` | exact, else next-higher key |
| `SEARCH=k$` | partial (leading substring) allowed |
| `SEARCH>=k$` | partial, else next-higher |

<a id="keyed-io"></a>
### Keyed I/O
- `READ #n, KEY=k$: … NOKEY <ref>` — fetch by key.
- `RESTORE #n, KEY>=k$:` / `SEARCH>=…` — position for a sequential keyed scan.
- A sequential read (forward or `PRIOR`) goes on from the last key it read. That holds even when
  other sessions, or another channel of the same program, have added or deleted keys since. On a
  **Btree2** index it stays in key order, gives each key once, and misses none that was there
  throughout. A key added or deleted meanwhile is met or not, according to where it falls.
- `REWRITE` without `KEY=` updates the last record read (fast); with `KEY=` it searches first
  (slower). **Changing the key field value is allowed** — BR automatically updates all related key
  files opened as a group (the old error 0059 is deprecated).
- `DELETE #n, KEY=k$:` — of the *key* parameters only `KEY=` is allowed, not `KEY>=` or
  `SEARCH=`/`SEARCH>=`, because a delete has to name one record and not the next-greater one. It does
  also take `REC=`, `LINK=` and the positional five — see
  [statements](../statements/spec.md#positioning-per-statement).
- <a id="keyonly"></a>**`READ #n, KEYONLY: key$, recnum`** reads the key + relative record number from the index
  **without** touching the master record (faster sequential key scans; returns the key when the
  master record is locked). Valid only for `INPUT KEYED`/`OUTIN KEYED`; a master record must have
  been read first (else error 0718); use `FORM` of key length + `B 4`; it moves the master pointer
  but a following `REREAD`/`DELETE`/`REWRITE` errors. Keep the key file current or it may return a
  stale record number.
- **Functions**: `KPS(n)`, `KLN(n)`, `KREC(n)` — key start position, key length, and last *index*-file
  record accessed; all return `-1` if the file isn't open keyed. `KLN(n,seg)` (and `KPS(n,seg)`) give a
  **split-key section's** length/position — `seg=0` (or omitted) is the *total* combined length, a
  too-large `seg` returns `-1`. **`KREC(n)` is the last record in the *index/key* file, not the master**
  (that's `REC(n)`); for a **display** file it's instead the line counter since the last `NEWPAGE`
  (same as `LINES(n)`; `NEWPAGE;` with a trailing `;` suppresses the reset). In a **linked** file
  `KREC` tracks an *anchor* record only when `REC=<anchor>` is processed or an anchor is read/written/
  deleted; `RESTORE REC=<non-anchor>` sets it to 0.

<a id="duplicates"></a>
### Duplicate keys
All `KEY=` forms return the **first** match (lowest record number); read sequentially to walk the
rest, stopping when the key changes:
```business-rules
00100 READ #1, KEY="JONES": NAME$, ADDR$, AMOUNT
00110 DO
00120   READ #1: NAME2$, ADDR2$, AMT2 EOF DONE
00130   IF NAME2$ <> "JONES" THEN EXIT DO
00140   ! process duplicate
00150 LOOP
```

<a id="tables"></a>
## Tables — error codes
| Code | Meaning |
|---|---|
| 4272 | NOKEY — key not found |
| 0718 | key string length mismatch |
| 0059 | *(deprecated, 2.x only)* attempt to change key field value — changing a key is now allowed |
| 7603 | duplicate keys found (warning) |
| 7611 | key file already exists (no `REPLACE`) |

<a id="examples"></a>
## Examples

```business-rules
! Build a split-key index: name (1-20) + zip (50-54)
INDEX CUSTOMER.DAT CUSTZIP.KEY 1/50 20/5 REPLACE

! Read July–August by key range
00410 OPEN #3: "NAME=MILES.DAT,RECL=24,KFNAME=MILES.KEY", INTERNAL, INPUT, KEYED
00420 READ #3, USING 430, KEY>=070196: DATE, MILES, GALLONS, MPG
00430 FORM N 6, N 6.2, N 6.2, N 6.3
00440 DO WHILE DATE < 090196
00460   READ #3, USING 430: DATE, MILES, GALLONS, MPG EOF 480
00470 LOOP
00480 CLOSE #3:

! Rebuild after batch updates
99000 EXECUTE "INDEX ACCT.INT ACCT.KEY 1 4 REPLACE"
```

<a id="see-also"></a>
## See also

- [statements](../statements/spec.md#io) — `READ`/`REWRITE`/`DELETE` with `KEY=`/`SEARCH=`
- [file-model](../file-model/spec.md#access-methods) — keyed vs relative vs sequential
- [form-spec](../form-spec/spec.md) — key field types (incl. `DH` dates as character keys)
- [filename-patterns](../../70-commands/file-directory/filename-patterns.md#tab-completion) — Tab completes the file after `INDEX`'s `>`/`>>` at `READY` (not its master or key file)
- Backing keyword pages (deep detail retained): [INDEX](INDEX.md), [Index_Facility](Index_Facility.md)

*(5 redirect-collision pages re-fetched in 2b — `BTree`, `Key_Spec`, `KFName`, `KLn`, `KRec` — were
folded into this spec and pruned; verbatim wikitext remains on the BR wiki.)*
