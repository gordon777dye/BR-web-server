# BR 5.01 Release Notes

What changed in BR 5.01 that a user, an administrator or a support engineer needs to know about.
Entries that can change how an existing program behaves come first, because those are the ones worth
reading before an upgrade rather than after. For BR 5.0 itself, see
[BR 5.0 Release Notes](old/BR50%20Release_Notes.md).

## Contents

- [1. Behaviour changes](#behaviour-changes)
  - [1.1 `MOVE` moves a folder named on its own](#move-moves-a-folder-named-on-its-own)
  - [1.2 Deleted records are reused; `OPTION 51` stops it](#deleted-records-are-reused)
  - [1.3 `MSG("menu")` chooses a menu item by name](#msg-menu-chooses-a-menu-item-by-name)
  - [1.4 `INDEX ... VERIFY` and `REORG` check and repair a Btree2 index](#index-verify-and-reorg-check-and-repair-a-btree2-index)
  - [1.5 Btree2 indexes reuse freed records](#btree2-indexes-reuse-freed-records)
  - [1.6 New indexes are Btree2; `OPTION 22` makes them Btree](#new-indexes-are-btree2)
  - [1.7 Two opens of a file share a record lock; `OPTION 14` is gone](#two-opens-of-a-file-share-a-record-lock)
  - [1.8 `DAYS` always reads extra digits as the century; `OPTION 18` is gone](#days-always-reads-extra-digits-as-the-century)
  - [1.9 `OPTION 33` is 64 unless set](#option-33-is-64-unless-set)
  - [1.10 Options 1, 4, 7, 11, 16, 19, 28 and 55 are no longer used](#options-no-longer-used)
  - [1.11 A busy lock is had the moment it is let go](#a-busy-index-is-waited-for-in-milliseconds)
  - [1.12 Sessions sharing a Btree2 index wait only for the part of it they use](#btree2-node-locks)
  - [1.13 Btree2 indexes made before 5.01 must be rebuilt](#btree2-version-3)
  - [1.14 A program goes on while its records are written](#write-queue)
  - [1.15 Earlier releases cannot have a file open while 5.01 has it](#no-earlier-release-beside)
- [2. Fixes](#fixes)
  - [2.1 `COPY`, `RENAME` and `MOVE` read a `/` in the destination both ways](#copy-rename-and-move-read-a-slash-in-the-destination-both-ways)
  - [2.2 Btree2 indexes keep their keys in order](#btree2-indexes-keep-their-keys-in-order)
  - [2.3 An index update stopped part way loses no key](#an-index-update-stopped-part-way-loses-no-key)
  - [2.4 An empty Btree2 index reads as end of file](#an-empty-btree2-index-reads-as-end-of-file)
  - [2.5 A Btree2 index `INDEX` builds finds every duplicate key](#a-btree2-index-index-builds-finds-every-duplicate-key)
  - [2.6 A `FORM` group with a count of 0 is skipped](#a-form-group-with-a-count-of-0-is-skipped)
  - [2.7 A sequential read of a Btree2 index meets each key once while the index changes](#a-sequential-read-meets-each-key-once)
  - [2.8 `KEY>=` past a deleted record's key takes the `NOKEY` path](#key-past-a-deleted-records-key-takes-nokey)
  - [2.9 Sessions that start together each get a WSID of their own](#sessions-starting-together-get-their-own-wsids)

<a id="behaviour-changes"></a>
## 1. Behaviour changes

<a id="move-moves-a-folder-named-on-its-own"></a>
### 1.1 `MOVE` moves a folder named on its own

`MOVE folder to` moves the folder as itself, with everything in it, when *folder* is one folder
named without wildcards. It works with or without `-R`.

- **To a name nothing has yet**, the folder takes that name. Within one file system that is a
  rename; to another drive, share or file system, or across the client and server, the folder is
  copied under the new name and then freed.
- **To a folder that exists**, the folder goes inside it under its own name. If a folder of that
  name is already there, the two are merged.

| Command | Result |
|---|---|
| `MOVE cc ..`, `MOVE cc/ ..` | `..\cc`, with everything in it |
| `MOVE src dest` (`dest` exists) | `dest\src`; merged with a `dest\src` already there |
| `MOVE src newname` | `src` renamed `newname` |
| `MOVE src E:\keep\src2` | `src` copied to `E:\keep\src2` and freed |
| `MOVE src aa/bb` | `aa\bb\src` when `aa\bb` exists (see [2.1](#copy-rename-and-move-read-a-slash-in-the-destination-both-ways)) |
| `MOVE src other` (`other` is a file) | error **4150** |
| `MOVE src src\sub` | error **4299** |
| `MOVE src .` | nothing moves |
| `MOVE x.dat dest` | `dest\x.dat` |
| `MOVE src dest -R` | `dest\src` |
| `MOVE src* dest` | error **4152**: wildcards match folders only with `-R` |

`-V` asks `Move? (y/n/all)` for the folder, and `-N` and the redirections work as for any `MOVE`.

`RENAME folder newname -D` also renames a folder within one file system.

<a id="deleted-records-are-reused"></a>
### 1.2 Deleted records are reused; `OPTION 51` stops it

A `WRITE` of a new record to an internal file takes a deleted record instead of adding one at
the end, so a file whose records are deleted about as fast as they are added stops growing. The
last record deleted is the first one reused, and its old contents are gone for good.

`OPTION 51` turns this off: with it on, new records are added at the end and deleted records are
left as they are. **A configuration that already says `OPTION 51` or `OPTION 51 ON` therefore gets
no reuse.** `OPTION 51 OFF`, or no `OPTION 51` at all, gives reuse. Earlier releases add
records at the end whatever `OPTION 51` says. `STATUS` shows
`OPTION 51 is OFF - do not reuse deleted records` when records are reused.

The file keeps its deleted records in a chain, recorded in its header:

- **A file made while records are reused** has the chain from the start.
- **An existing file** gets one, with every deleted record in it, the first time it is opened
  for `OUTPUT` or `OUTIN` while records are reused. The scan takes a moment on a large file; it
  is done again only when something has deleted records outside the chain. An `INPUT` open
  changes nothing.
- **Some files cannot have one** and simply grow: records shorter than 4 bytes, and record
  lengths 14 to 17, whose header has no room for it.

**Rebuilding the chain.** `VERSION(n, v)` with a negative `v`, on a file open `OUTPUT` or
`OUTIN`, leaves the file's version as it is and empties its chain. Writes then add records at the
end, and the next `OUTPUT` or `OUTIN` open that reuses records builds the chain again from every
deleted record in the file. `VERSION` returns the version, unchanged.

```
X = VERSION(1, -1)        ! chain rebuilt at the next open; X is the file's version
```

**Sharing.** Engines with `OPTION 51` on can use the same file at the same time as engines that
reuse records. They add records at the end, and a record they delete is reused once the file is
next opened for output by an engine that reuses records. An earlier release can use the file
before or after 5.01, but not while 5.01 has it open (1.15); it adds and deletes as `OPTION 51 ON`
does. `COPY -D` gives the copy an empty chain.

Every change to the chain's head, including the header that `CLOSE` writes back, is made under
the file's add lock, whatever the open's share mode. So sessions sharing a file never drop a
deleted record from its chain, and a session closing the file while others write and delete
leaves the chain as they made it.

**Keyed files.** A record deleted while one of its indexes was not open leaves that index's key
behind. So in a file that reuses records, a keyed read checks the record a key leads to. A
deleted record, or one whose own key, built the way `WRITE` builds it, is not that key, is
treated as not there: `KEY=` answers key not found, and a sequential keyed read goes on to the
next key. This applies to every engine reading the file, whatever its `OPTION 51`. A read through a
Btree2 index checks the same way in every file, since an update stopped part way can leave a key
behind there too (see [1.4](#index-verify-and-reorg-check-and-repair-a-btree2-index)). In a file
that does not reuse records, a read through a Btree or ISAM index works as it always has.

<a id="msg-menu-chooses-a-menu-item-by-name"></a>
### 1.3 `MSG("menu")` chooses a menu item by name

*This is a documentation omission: the action is in BR 5.0, but the 5.0 release notes did not
describe it.*

`MSG("menu", <path$>)` lets a program choose an item of the menu BR shows on its main window
(`DISPLAY MENU`), as a click on it would. The program gets `FKEY` 98, and `MENU$` returns the
item's data, exactly as if the user had chosen it.

```
X = MSG("menu", "File|Open")               ! an item on the File menu
X = MSG("menu", "File|Recent|first.br")    ! an item on a submenu
```

- The path is the menu's labels, from the menu bar title down to the item, separated by `|`.
  Case, the `&` accelerator marks and any shortcut text are ignored.
- It is queued with the keys from `MSG("send")` and the clicks, and delivered in that order while
  the program waits for input. It needs no mouse, no focus and no visible window.
- A path that names no item is error **0415**, and BR's log lists the paths the menu has.
- Each choice is logged at the security level. A restricted session refuses it with **4154**.

This is how a program clicks a menu item: `MSG("lclick")` and the other clicks are refused over the
menu, because Windows runs a drop-down menu itself and only real mouse input can drive it.

<a id="index-verify-and-reorg-check-and-repair-a-btree2-index"></a>
### 1.4 `INDEX ... VERIFY` and `REORG` check and repair a Btree2 index

For a Btree2 index, `VERIFY` finds what is wrong with the index, and `REORG` repairs it in place.
Both run while programs go on using the index, and neither needs it to be rebuilt.

```
INDEX CUSTOMER CUST.KEY 1 6 VERIFY       ! check, while programs use the index
INDEX CUSTOMER CUST.KEY 1 6 REORG        ! repair, while programs use the index
```

**`VERIFY`** needs no exclusive access. Programs go on reading and updating the index while it runs.
It walks the whole index and checks that:

- every key lies in order, in the record that should hold it;
- no record is reached from two places;
- the key of every live master record is in the index, and every key in the index belongs to a
  live master record that has it - looked at key by key only when the index holds more keys than
  the master file has live records;
- no update of the index was left unfinished.

A key that is being changed while `VERIFY` looks at it can seem wrong for a moment. So anything
that looks wrong is looked at again, after any update of that part of the index has finished, and
only what is still wrong is reported. A master record whose key is not in the index is looked for
again while `VERIFY` holds the record's lock, so after any update of that record has finished. One
that a program keeps locked for more than 15 seconds is not reported.

- **If nothing is wrong**, `VERIFY` ends without an error, and any `.flaws` file left from an earlier
  `VERIFY` is deleted.
- **If anything is wrong**, `VERIFY` ends with error **9401**. It writes what it found to
  *index file*`.flaws` beside the index, for example `CUST.KEY.flaws`, and marks the index as needing
  repair.

Until the index is repaired, its updates add records at the end of the file instead of reusing
freed ones (see [1.5](#btree2-indexes-reuse-freed-records)). An index marked this way keeps working
otherwise.

The `.flaws` file `VERIFY` writes starts with the line `VERIFIED`. Each line after it is one flaw,
its kind first:

| Kind | What is wrong |
|---|---|
| `OUT_OF_RANGE` | a record holds keys that belong in another one |
| `STALE_REF` | a record is reached from two places, and one of them is out of date |
| `SEPARATOR` | a key that steers the search to a record is above that record's first key, so a search can miss the keys in between |
| `MISSING` | a master record's key is not in the index |
| `EXTRA` | a key in the index whose master record is deleted, or has another key |
| `INTERRUPTED` | an update of the index was stopped part way |
| `DISORDER` | a record's keys are out of order, or one is there twice; it can also hold keys that belong in another record, and keys their master records no longer have |
| `DAMAGED` | a record cannot be used: it cannot be read, is marked free, holds an impossible number of keys, or steers the search with keys out of order |
| `DEPTH` | a record's keys lie a level deeper than those beside it |
| `TWICE` | a record is reached from two places, neither out of date (found by `REORG`; `VERIFY` reports it as `DAMAGED`) |
| `STRUCTURE` | the first record of the index, where every search starts, cannot be used; only a rebuild repairs that |

**`REORG`** needs no exclusive access either. If `VERIFY` wrote the `.flaws` file, `REORG` checks
only the parts of the index it names. Otherwise - no `.flaws` file, or one only reads have written
to (see below) - `REORG` checks the whole index and the whole master file. A new index, and one
`INDEX ... REPLACE` rebuilds, starts without a `.flaws` file. It then:

- moves keys to the records they belong in;
- removes the out-of-date link to a record reached from two places;
- corrects the keys that steer the search;
- rewrites a record in `DISORDER` with the keys that belong in it, in order and each once, keeping
  only those its master records still have;
- removes the link to a record that is `DAMAGED` or a level too deep, and frees it and every
  record below it;
- removes the second link to a record reached `TWICE`;
- removes the keys whose master records are deleted or have other keys, each under its master
  record's lock and only if the record still does not have it;
- adds the keys missing for live master records. After it removes a link to a `DAMAGED`, `DEPTH`
  or `TWICE` record, it checks the whole master file for them, `.flaws` file or not.

Each repair is made the way a program's own update is. `REORG` locks just the index records it
changes, looks again at what it found, and repairs it only if it is still wrong. A missing key is
added under its master record's lock, and only if the record still has that key. A record in
`DISORDER` keeps a key only if its master record, looked at under that record's lock, still has
it. Programs reading
the index, or changing a key that stays in its record, are not held up. An update that splits or
merges records waits for a moment twice: as `REORG` starts, and as it finishes, while it frees the
records set aside and clears the repair mark.

A repair whose index records or master record stay locked by a program is tried again on
`REORG`'s next pass. If they are still locked after three passes, `REORG` ends with error **0061**.
The index stays marked as needing repair, the `.flaws` file is kept, and running `REORG` again
later finishes the job.

After the repairs, the index records freed while the index needed repair go on its list of free
records (see [1.5](#btree2-indexes-reuse-freed-records)). The index is no longer marked as needing
repair, and the `.flaws` file is deleted. `REORG` does not look for records an interrupted update
left unused, and does not shorten the file: `REPLACE` rebuilds the index at its smallest.

When the index cannot be repaired in place, `REORG` rebuilds it from the master file, as
`REPLACE` does. That happens for a `STRUCTURE` flaw, or when the repairs do not settle. Removing a
`DAMAGED` or `DEPTH` record needs the master file to put its keys back, so `REORG` does neither
when it cannot open the master file: it ends with that file's error, and the index stays marked
as needing repair. A rebuild
needs the index to itself, so while programs have the index open, `REORG` ends with a file-sharing
error instead, and the index is left as it was. The rebuild takes duplicate keys as `DUPKEYS`
does, whether or not the `INDEX` statement says so: a `WRITE` adds any key to a Btree2 index,
duplicate or not, so the index being replaced can already hold them.

**Reads report what they pass over.** A read through a Btree2 index passes over a key whose
master record is deleted or has another key, a key that points at the record it has just read, and,
for `KEY=` or `KEY>=`, a copy below the key asked for that an update stopped part way left at the
start of the next index record.
Once it is sure no update of that record is under way - it holds the record's lock already, or
gets it at once - it writes the key to the `.flaws` file: `EXTRA` for a key the record does not
have, `REPEATED` for a second copy of the record's own key. It does not mark the index as needing
repair, and each key is written once by a session. `REORG` removes an `EXTRA` key and repairs the
part of the index a `REPEATED` line names; `VERIFY` looks at every `EXTRA` line again before it
replaces the file. A `.flaws` file only reads have written to names just what they met, so it does
not narrow what `REORG` checks.

A Btree2 index is not sorted in two parts, so `REORG` has no unsorted part to sort. For a Btree or
ISAM index, `VERIFY` and `REORG` work as they always have.

<a id="btree2-indexes-reuse-freed-records"></a>
### 1.5 Btree2 indexes reuse freed records

When deleting keys empties a record of a Btree2 index, the record goes on a list of free records
kept in the index's header. The next record the index needs is taken from that list, and the file
grows only when the list is empty. So an index whose keys are deleted about as fast as they are
added stays near the size `INDEX` would build it.

Reuse stops while the index is marked as needing repair, and starts again once `REORG` or
`REPLACE` has dealt with it. The index is marked:

- when an update finds that the one before it was stopped part way;
- when `VERIFY` finds a flaw.

Until then, a freed record is set aside with its keys unchanged, on a second chain, and not
reused, so a record two places still point to is never handed out a second time. `REORG` moves the
records set aside onto the list of free records once it has repaired the index.

An index last updated by an earlier release may have an update that release left unfinished. 5.01
finds the mark it leaves and treats it the same way.

<a id="new-indexes-are-btree2"></a>
### 1.6 New indexes are Btree2; `OPTION 22` makes them Btree

An index that `INDEX` builds, or that an `OPEN` with `KFNAME=` creates, is a Btree2 index. With
`OPTION 22` on, it is a Btree index instead. `OPTION 22 OFF`, or no `OPTION 22` at all, gives
Btree2. **A configuration that says `OPTION 22` to get Btree2 indexes therefore gets Btree ones.**
`STATUS` shows `OPTION 22 is OFF - create BTREE (not BTREE2) indexes` when new indexes are Btree2.

The option decides only what a new index is made as. Each index records its kind in its header,
and BR reads it there whenever the index is opened, so an existing index works as the kind it is
whatever the option says. A master file can have indexes of both kinds, open together and updated
together.

`INDEX ... REPLACE` makes the index afresh, so it gives the kind the option asks for. That is the
way to turn an index into the other kind:

```
INDEX CUSTOMER CUST.KEY 1 6 REPLACE      ! a Btree2 index, with OPTION 22 off
```

A configuration file shared with earlier releases means different things to each: there,
`OPTION 22` gives Btree2 and no `OPTION 22` gives Btree.

<a id="two-opens-of-a-file-share-a-record-lock"></a>
### 1.7 Two opens of a file share a record lock; `OPTION 14` is gone

When a program has the same file open on two channels, both can lock the same record. A read
through the second channel of a record the first holds succeeds at once, without waiting and
without error **0061**. The record stays locked, against every other workstation, until the
last channel holding it lets go: by moving to another record, `RELEASE`, `REWRITE`, `DELETE` or
`CLOSE`. Releasing it on one channel leaves it locked for the other.

```
OPEN #1: "NAME=CUST.INT,SHR", INTERNAL, OUTIN, RELATIVE
OPEN #2: "NAME=CUST.INT,SHR", INTERNAL, OUTIN, RELATIVE
READ #1, USING F, REC=5: A$      ! record 5 locked
READ #2, USING F, REC=5: A$      ! also through #2: no error
RELEASE #1:                      ! still locked: #2 holds it
RELEASE #2:                      ! now free for other workstations
```

`OPTION 14` is no longer needed. A configuration that has it still loads, and the option is
ignored. `STATUS` does not list it.

The sharing is between the channels of one BR session. Two sessions, on the same workstation or
on different ones, still exclude each other.

<a id="days-always-reads-extra-digits-as-the-century"></a>
### 1.8 `DAYS` always reads extra digits as the century; `OPTION 18` is gone

When `DAYS` is given a numeric date with more digits than its format takes, and the format has a
year but no century, the extra digits are the century. The date is read as if the format had a `C`
before the `Y`:

```
X = DAYS(20261225, "YMD")       ! 25 December 2026, as DAYS(20261225, "CYMD")
X = DAYS(261225, "YMD")         ! 25 December, the century from BASEYEAR
```

`OPTION 18`, which dropped the extra digits instead, is ignored. A configuration that has it still
loads, and `STATUS` does not list it. A date too long even with the century, or for a format that
already has a `C`, is a bad date.

<a id="option-33-is-64-unless-set"></a>
### 1.9 `OPTION 33` is 64 unless set

On Windows, Linux and macOS, BR and its ODBC driver lock files with 64-bit lock positions
(`OPTION 33 64`) unless the configuration says otherwise. A file is then no longer limited in size by
its lock zone. On SCO and AIX, which have no 64-bit file support, the default is `31`.

**Every engine that shares files must use the same `OPTION 33`.** It decides where in a file BR
places its locks, so engines with different settings do not see each other's locks.

- **Engines that share a `wbserver.dat`** catch a mismatch: the one that does not match stops with
  *OPTION 33 mismatch using wbserver.dat*. That includes earlier releases, whose default is `31`.
- **Engines that do not share a `wbserver.dat`**, for example on two machines using the same files
  over a network share, are not warned. Set the same `OPTION 33` in all their configurations.

To run beside earlier releases unchanged, give 5.01 `OPTION 33 31`, or give the earlier releases
`OPTION 33 64` (they support it on Windows, Linux and macOS). They can share the `wbserver.dat`,
and use the same files at different times, but not have one open together (1.15). `STATUS` shows the setting in use:
`OPTION 33 is 64 - locking position for large file support`.

<a id="options-no-longer-used"></a>
### 1.10 Options 1, 4, 7, 11, 16, 19, 28 and 55 are no longer used

These options are no longer used. BR always behaves as it did with each one off, the default,
except option 55, where it always behaves as it did with the option on. A configuration file or
`CONFIG` statement that still names any of the others is accepted, and the option is ignored;
`STATUS` does not list them. Option 55 is different: a configuration line that sets it is
refused, the same as an option number BR does not know, and `STATUS` shows it as
`OPTION 55 - no longer used` so that the reason can be found.

| Option | What it used to do | What BR does |
|---|---|---|
| `1` | A `FORM` repeat count below 1 (`A*C 10` with `A` 0 or negative, or `A*( ... )`) was taken as 1: the item or group was used once. | The item or group is skipped. |
| `4` | Output to a display file opened with `EOL=NONE` was padded with spaces to the full record length. | Only what was printed is written. |
| `7` | Turned off the check for a hanging `THEN` or `ELSE` (error 1121) in `IF` statements. No statement tried for 5.01 behaved differently with it on. | The check is always made. |
| `11` | Kept variables that no line of the program refers to any more. | Once an edit has removed a variable's last reference, the variable is removed from the program when it is next saved, replaced, run, chained or continued with `GO`. |
| `16` | Did not show the program's name when it was loaded, saved or replaced. | The name is shown. |
| `19` | On SCO before version 5 only, subtracted a day from the system date after February 2000, to make up for that system's year-2000 error. | The system date is used as it is. |
| `28` | Refused a `PRINTER` substitution statement that named no printer type, so that every substitution had to belong to a type. | A substitution with no type goes into the default table, which every printer uses for any code its own type does not define. |
| `55` | Made NWP printing place each character of a fixed-width font in its own character cell, instead of drawing each word as one run. | Each character of a fixed-width font is always placed in its own cell, in NWP printing and print preview alike. |

<a id="a-busy-index-is-waited-for-in-milliseconds"></a>
### 1.11 A busy lock is had the moment it is let go

BR holds a short lock on a shared Btree index each time it reads or updates it, on the part of a
shared Btree2 index it is using (see [1.12](#btree2-node-locks)), and on a shared data file each
time it chooses where a new record goes or deletes one. A record is locked while a program holds
it. When another session holds the lock BR wants, BR waits for it:

- **On Windows** it waits in the operating system and has the lock the moment the holder lets go,
  for up to 15 seconds for the short locks, or for the time `WAIT=` gives for a record.
- **On Linux and macOS, and for a file reached through the client,** it tries again after about a
  millisecond, then at doubling intervals up to every tenth of a second, for the same time. A record
  lock is still tried once a second there.

Before, BR tried again only once a second. A single wait then cost a second or more, and a session
could lose the lock to the others again and again while they kept using the file. When many
sessions use one file heavily, the file is now shared out more evenly between them, and the longest
wait falls: in a test of eleven sessions working on one index as fast as they could, from 8.2
seconds to 2.2 with the tries a millisecond apart. Waiting in the operating system cut it again,
to about a tenth of a second. The slowest update in twenty took 2 to 6 milliseconds instead of 20,
and the time each session spent waiting fell from about 9 seconds to under 2.

<a id="btree2-node-locks"></a>
### 1.12 Sessions sharing a Btree2 index wait only for the part of it they use

A shared Btree2 index has no lock for the whole of it. Each record of the index has its own:

- **A read** - `READ` with `KEY=` or `SEARCH`, or a sequential read through the index - holds each
  record of the index it passes through, from the top down, only until it has the next one. Reads
  never wait for one another.
- **An update** - adding, deleting or changing a key - holds only the records it will change,
  usually one.
- **Each waits** only for a session using the same record of the index at the same moment.

Sessions using different parts of one index therefore no longer take turns with it. In a test of
eleven sessions adding, deleting, changing and reading keys in one index as fast as they could, each
did about twice as much as when they shared a lock on the whole index, and the slowest update in
twenty took about 20 milliseconds instead of 40. A session that only reads takes a lock for each
level of the index it passes through, so reading alone is somewhat slower than with one lock on the
whole index.

When a data file is shared, its own lock is held only while BR chooses where a new record goes, or
puts a deleted one on the list of records to reuse. The record is locked first, and written after
BR lets go. So sessions adding and deleting records in one file wait much less for one another.
Two sessions adding records at once each take a record of their own, and the second can finish
first. Until the first has written its record, that record reads as not there: reading it by
number gives *no record* (error **0057**), and a sequential read passes over it. An earlier
release, which adds a record at the end of the file under the file's lock alone, would write over
such a record: that is why it cannot have the file open beside 5.01 (1.15).

- **An index opened `NOSHR`** takes no locks.
- **A Btree index,** and a file reached through the client, are locked as before.

<a id="btree2-version-3"></a>
### 1.13 Btree2 indexes made before 5.01 must be rebuilt

5.01 makes Btree2 indexes as version 3. Each record of a version 3 index ends in 4 bytes that link
it into the index's lists of free records (see [1.5](#btree2-indexes-reuse-freed-records)), and it
is locked as [1.12](#btree2-node-locks) describes. An index that `INDEX` builds, or that an `OPEN`
with `KFNAME=` creates, is version 3.

- **A Btree2 index made by an earlier release** (version 2) can still be read. Adding, deleting or
  changing a key in it gives error **0633**, *BTREE2 index made before 5.01: rebuild it with INDEX
  ... REPLACE*.
- **`INDEX ... REPLACE` rebuilds it** as version 3, and so does `INDEX ... REORG`, which rebuilds a
  version 2 index from the master file instead of repairing it.
- **Earlier releases refuse a version 3 index** with error **4124**, an invalid header record,
  instead of damaging it.

So rebuild every Btree2 index when you upgrade, and upgrade every engine that shares the files at the
same time. A version 3 index can hold slightly fewer keys in each of its records, so it may be a
little larger.

<a id="write-queue"></a>
### 1.14 A program goes on while its records are written

On Windows, `WRITE`, `REWRITE` and `DELETE` of an internal file opened `SHR`, or opened `NOSHR` for
output, no longer wait for the record itself to be written. BR locks the record, updates the
indexes and the file's list of deleted records as before, then hands the record to a thread of its
own and goes on with the program. The thread writes the records in the order the
program changed them, across all its files, and lets go of each one's lock when it is written.

Nothing reads a record before it is written:

- **Other sessions** reach the record through an index, or by its number, and wait for its lock.
- **The program itself** waits for the record before it reads it, locks it or releases it.

Two things change for a program:

- **A failed write is reported later.** If writing the record fails, for example because the disk is
  full, the error is the error of the next statement that uses the file, or of its `CLOSE`, not of
  the `WRITE`, `REWRITE` or `DELETE` that made it. An `IOERR` or `ERROR` clause on that statement
  does not see it. A `CLOSE` that reports such an error leaves the file open; a second `CLOSE`
  closes it.
- **A session that is ended abruptly loses more.** `END`, `STOP`, `CHAIN`, `CLEAR`, `CLOSE` and a
  normal exit all wait until every record has been written. A session that is killed, or a machine
  that fails, loses the records still waiting, although the program was told they were written.
  Their index entries were already made; a read through the index passes over them, as over a
  deleted record's.

A file opened `NOSHR` takes no more locks than before: the record is locked only while it waits to
be written, and only this program waits for it.

Files reached through the client, linked files, files opened `SHRI` and files on Linux and macOS
are written as before.

<a id="no-earlier-release-beside"></a>
### 1.15 Earlier releases cannot have a file open while 5.01 has it

A 5.01 session and a session of an earlier release never have the same file open at the same time.
Whichever opens it second is refused:

- **An earlier release opening a file that 5.01 has open** gets error **4149**, *different version
  of BR running for locking*. On Windows with `OPTION 33 31` or `32` it gets **4175**, *different
  wbserver files detected*, instead, and logs that it found a user with WSID 0 on another
  `wbserver.dat`; there is no other `wbserver.dat`.
- **5.01 opening a file that an earlier release has open** gets error **4149**, and logs *A BR
  engine before 5.01 has the file open; 5.01 does not share files with it*.

This applies to every file BR opens with its file sharing, whatever `SHR` or `NOSHR` says, and to
the ODBC drivers of each release. The two can still use the same files one after the other: once
the file is closed, the other can open it.

The reason is the way 5.01 adds a record to a shared file (1.12): it takes the record past the end
of the file and lets go of the file's lock before it writes it. An earlier release, which adds at
the end of the file under that lock alone, would write over it.

The refusal relies on the engines placing their locks alike: they must use the same `OPTION 33`
(1.9).

<a id="fixes"></a>
## 2. Fixes

<a id="copy-rename-and-move-read-a-slash-in-the-destination-both-ways"></a>
### 2.1 `COPY`, `RENAME` and `MOVE` read a `/` in the destination both ways

Under [`OPTION 84`](old/BR50%20Release_Notes.md#option-84-slash), a name with a `/` in it has two
readings: System/23 (`file/directory`) and folders. The destination of `COPY`, `RENAME` and `MOVE`
gets both, as the source does. The first reading is used when something exists by that name or the
folder it would go in exists; otherwise the second reading is used when its folder exists.

With folders `aa` and `aa\bb`, `COPY * aa/bb` copies into `aa\bb`. The System/23 reading, file `aa`
in directory `bb`, has no `bb` to go in. Had there been a folder `bb`, the System/23 reading would
come first and the result would be the file `bb\aa`.

At `OPTION 84 0`, a `/` is read only as System/23, and `COPY * aa/bb` is error **4203** when there
is no folder `bb`.

<a id="btree2-indexes-keep-their-keys-in-order"></a>
### 2.2 Btree2 indexes keep their keys in order

A Btree2 index keeps its keys in ascending order, as a Btree index does, whether
`INDEX` built it or `WRITE` added the keys one at a time. So an index that `INDEX` built and
`WRITE` has added to finds every key, and sequential reads, `LAST`, `PRIOR` and `KEY>=` go in key
order.

<a id="an-index-update-stopped-part-way-loses-no-key"></a>
### 2.3 An index update stopped part way loses no key

Adding or deleting a key can change several records of a Btree or Btree2 index: a record that
fills up is split in two, and one that empties is merged with or rebalanced against its neighbour.
Each such change writes the record that gains keys first, then the record above that points to it,
and the record that gives keys up last. So if the update is stopped part way - BR ends unexpectedly,
the session is closed, or a write fails because the disk is full - every key already in the index
can still be found. The only key that may be missing is the one being added at that moment.

Some keys may then be listed twice by a sequential read.

- **A Btree index** stays that way until it is rebuilt with `INDEX ... REPLACE`.
- **A Btree2 index** is marked as needing repair, and `INDEX ... REORG` repairs it in place (see
  [1.4](#index-verify-and-reorg-check-and-repair-a-btree2-index)). Until then a sequential read,
  forward or with `PRIOR`, never reads the same record twice in a row: a next key that points at
  the record just read is passed over, as a deleted record's key is, and written to the `.flaws`
  file for `REORG` (see [1.4](#index-verify-and-reorg-check-and-repair-a-btree2-index)).

<a id="an-empty-btree2-index-reads-as-end-of-file"></a>
### 2.4 An empty Btree2 index reads as end of file

A sequential read of an empty Btree2 index, `READ ... LAST` and `READ ... PRIOR` on one answer end
of file, as a Btree index does.

<a id="a-btree2-index-index-builds-finds-every-duplicate-key"></a>
### 2.5 A Btree2 index `INDEX` builds finds every duplicate key

In a Btree2 index, the keys that steer a search are the key and master record number of a record's
first entry. `INDEX` gives every level of the index the right record number.

A large index that an earlier release built, one with three or more levels, can hold the record
number of a later record in its upper levels. Where several master records share a key, a search
can then miss one of them: its key cannot be deleted or changed, and `VERIFY` reports `SEPARATOR`
and `MISSING`. Rebuild such an index with `INDEX ... REPLACE`, or repair it with `INDEX ... REORG`.

<a id="a-form-group-with-a-count-of-0-is-skipped"></a>
### 2.6 A `FORM` group with a count of 0 is skipped

A repeated group in a `FORM` whose count is 0 or less is skipped, and the item after it is used
next:

```
00100 LET N = 0
00110 FORM N*(C 3, C 1), C 2
00120 PRINT #9, USING 110: "OK"            ! prints OK
```

Such a `PRINT USING`, `WRITE USING` or `READ USING` no longer runs forever: the item after the group
was skipped as well, so the `FORM` started again from its beginning without ever finding an item to
use.

<a id="a-sequential-read-meets-each-key-once"></a>
### 2.7 A sequential read of a Btree2 index meets each key once while the index changes

A sequential read through a Btree2 index - `READ` with no key, `READ ... PRIOR`, and the reads
after `RESTORE ... KEY>=` - goes on from the last key it read, even when the index has changed
since: another session, or another channel of the same program, has added or deleted keys and so
split, merged or rebalanced records of the index. The read stays in key order, gives each key once,
and misses no key that was in the index the whole time. A key added or deleted during the read is
met or not according to where it falls.

Such a read used to go on from the index as it was at the read before. It could give the last key
again, go back to keys it had already given, or skip keys. That happened most in a program that
reads an index in sequence on one channel while it writes or deletes through another channel on the
same index, where nearly every read after a change was wrong.

<a id="key-past-a-deleted-records-key-takes-nokey"></a>
### 2.8 `KEY>=` past a deleted record's key takes the `NOKEY` path

A `READ` or `RESTORE` with `KEY=` or `KEY>=` on a Btree2 index takes its `NOKEY` path when the
only keys at or after the one asked for belong to deleted records. It used to end with error 4270
(end of file) instead, which a `NOKEY` clause does not catch.

<a id="sessions-starting-together-get-their-own-wsids"></a>
### 2.9 Sessions that start together each get a WSID of their own

When no session is using a `wbserver.dat`, the first one to start empties it and writes it out
afresh. It does so while it holds the file's sign-on lock, and holds the lock until it has its
WSID, so sessions starting at the same moment sign on one after another: exactly one of them
starts the file afresh, each gets a WSID of its own, and all of them share one set of file locks.
Before, two or more could each take themselves for the first. They could then get the same WSID,
or stop with *Couldn't read server header*, *OPTION 33 mismatch using wbserver.dat*, *Too many
users on the system*, or error 4148 (file sharing violation) opening a file the others had open.
