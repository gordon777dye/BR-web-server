---
title: File & directory commands
file: spec.md
source: §Commands → File System / File Management Commands
category: 70-commands
subcategory: 70-commands/file-directory
kind: spec
status: 2b           # reference base + br_tree fold (full -options, TYPE/PROTECT, CHDIR nav, client-server @:, abbreviations); no conflicts
recovered-fold: MkDir, RENAME (2 redirect-collision pages folded from re-fetched source — RENAME full -NPVF options + PRINT/redirect, MKDIR naming rules; verbatim retained on the BR wiki)
related: [program-management, information]
keywords: [DIR, COPY, MOVE, RENAME, MKDIR, RMDIR, CHDIR, FREE, PROTECT, DROP, TYPE]
corrections:
  - "From the BR 5.0 parsers (see br50 br/docs/FLAGS.md), 2026-10-21, source reading not yet confirmed by a run: COPY, FREE and DROP `-A` removed from the BNF and described as accepted with no effect - findSources() collects every file whatever its archive bit and nothing clears it (wbos.cpp); COPY's BNF gains `-F`, already documented in the overwrite section; the `-<n>` must-be-last rule narrowed to a combined option word (options(), the default case), which is how QSMRP's `COPY a b -124 -d -n` works; TYPE gains `-P` and, new in 5.0, a digit at its pause (processTypeFile()); PROTECT gains READ and WRITE (command0.cpp PROTECT); and the intro points at the new `-?` command help. Later the same day COPY `-C` (prompt for another diskette on a full disk) was removed from BR 5.0, and is removed here from the BNF, the options and the example."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless with a proc: a folder renamed, a folder moved into an existing folder, and a file and a folder refused on E: with both left in place): RENAME gains `-D` to rename a folder (wbos.cpp, RENAME_CMD), and RENAME refuses a target on another file system with 4138, whose message now covers both cases (renameFile() in file_os.cpp, MoveFileEx without MOVEFILE_COPY_ALLOWED; EXDEV on Unix). Added the rename-folder and rename-filesystem paragraphs and `-D` in the BNF."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless with a test program against a three-level tree): COPY and FREE gain `-R`: the name matches folders too and a matched folder is taken whole, each entry keeping its place below the name's fixed part; `**` alone searches below (wbos.cpp: expandFolders(), fixedLength(), makeFoldersFor(); findSources() and globCollect() take a folders flag). RENAME and DROP refuse it with 1006. Added the copy-recursive paragraph and table, FREE -R in drop-free, and `R` in both BNF lines."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless against test trees, including a move to another drive): new command MOVE (wbos.cpp moveFiles() and moveEntry(); MOVE_CMD and T1_MOVE in bascmd.h, tblcmd.cpp, commandc.cpp, wbserver.cpp; Tab completion in fields.h), and a name ending in a separator matches folders only (globSplit(), sourcesWanted(), keepFolderSlash()). Added the move paragraph, its BNF line, the trailing-separator rule, and MOVE to the keywords."
  - "TYPE added to the frontmatter keywords. `TYPE <file>` is in this page's BNF and its semantics, and was not declared. Found in brls phase 13."
  - "FREE's abbreviation `FR` removed: FREE has none, so only `FREE` in full deletes a file. `FRE` is refused with error 1000 (unidentified source remaining), and in 5.0 `FR` goes to the same refusal (it had reached calculator mode, where a bare `FR` printed a variable). `F <file>` also ends in error 1000; a bare `F` is still an expression. Confirmed by running `FR <file>`, `fr <file>`, `FR` and `F <file>` headless: error 1000 each time and the file kept; `FREE <file>` deleted it. 2026-10-20."
---

# File & directory commands

OS-level file and directory operations, runnable interactively or from a procedure / `EXECUTE`.
For opening files inside a program see
[30-io-file/statements](../../30-io-file/statements/spec.md). Each command has a short abbreviation
(in parentheses below). Options follow a leading dash and may be combined (`-AW`); a `-<n>` record
length, when combined into one word, must come **last** in it (`-D124`, not `-124D`) — as a word of
its own it may stand anywhere (`-124 -D`). In BR 5.0 each command lists its own options when given
[`-?`](../program-management/spec.md#command-help) alone (`COPY -?`).

<a id="syntax"></a>
## Syntax

```bnf
CHDIR [<drive>':'] ['\']<path> [-N]     -- CD / CH; no arg = show current dir
MKDIR [<drive>':']<path>                -- MK
RMDIR [<drive>':']<path>                -- RM; directory must be empty
DIR  [<drive>':'][<path>][<filename> | <glob>] [-AOLPWUCB] [PRINT | '>'['>'] <file>]   -- DI
COPY   <from> { <to> | PRN: | AUX: } [-DFNPRSV] [-<new_recl>] [PRINT | '>'['>'] <file>]  -- COP; -R the folders below
MOVE   <from> <to> [-FNPRV] [PRINT | '>'['>'] <file>]  -- MO; renames when it can, else copies and frees
RENAME <from> <to> [-DNPVF] [PRINT | '>'['>'] <file>]  -- REN; renames or moves (wildcards ok); -D a folder
TYPE   <file> [-P] [PRINT | '>'['>'] <file>] -- TY; dump a file to screen/printer/file
DROP <file-ref> [-NPV] [PRINT | '>'['>'] <file>]   -- DR; empties contents, keeps the name (size→0)
FREE <file-ref> [-NPRV] [PRINT | '>'['>'] <file>]  -- no abbreviation; deletes the file (unrecoverable); -R the folders below
PROTECT <file-ref> ',' { RESERVE | RELEASE | READ | WRITE }   -- PROT; reserve a path / set read-only
```

<a id="semantics"></a>
## Semantics

<a id="chdir"></a>**CHDIR / MKDIR / RMDIR** navigate/create/remove directories.
`CHDIR` with no path just *shows* the current directory. A leading `\` means an absolute path from
the root; without it the path is appended to the current directory. `drive:` **alone** changes the
current drive; `drive:\path` changes the current directory *on* that drive without switching to it.
Relative forms work: `\` → root, `..` → parent, `..\..` → grandparent. `-N` suppresses the
"new directory" echo (useful under `PROC NOECHO`). An invalid path raises error **4152**.

<a id="dir"></a>**DIR** lists files (wildcards `*`/`?`), with file size, date and time. `>file`
redirects (`>>` appends), `PRINT` to the printer (mutually exclusive with `>`).

**BR 5.0 listing.** Sorted by name; one line per entry: `yyyy-mm-dd hh:mm`, the size in bytes with
commas (`<DIR>` for a folder), and the long name, in double quotes if it has a space or a comma.
No 8.3 names, and `.` and `..` are not listed. A `Directory of` heading comes first and a summary
last (files and folders counted separately, space in KB/MB/GB/TB). Options:

| Option | Effect |
|---|---|
| `-T` | sort by date and time, newest first |
| `-S` | sort by size, largest first |
| `-R` | reverse whichever order applies; ties go by name |
| `-A` | attributes: names on Windows (`ReadOnly Hidden System Archive`); permission string, owner and group on Unix |
| `-L` | the permission string as well (Unix); on Windows the same as no option |
| `-N` | no `Directory of` heading |
| `-B` | names only, one per line, quoted as in the listing |
| `-W` | names only, across the rows, as many columns as the window holds; `\` after a folder, `*` after an executable |
| `-C` | the same, down the columns |
| `-M` | machine format: `bytes,yyyy-mm-dd,hh:mm:ss,type,attributes,owner,group,name`, no heading or summary, every field before the name in a fixed column, size right-aligned in 15 with no commas, type `D` or `F`, attributes `RHSA`/`-` on Windows or `rwxr-x---` on Unix, owner and group empty on Windows, name last and quoted by the CSV rule |
| `-ddd` | only entries changed *ddd* or fewer calendar days ago (today is day 0) |
| `+ddd` | only entries changed *ddd* or more calendar days ago; with `-ddd`, a range, both ends inclusive: `-30 +7` is days 7 to 30 |
| `-P` | pause per screen |
| `-O` | the pre-5.0 listing, below |

An option `DIR` does not know is error **1006**. A name matching nothing is **4152**; one whose
matches the day filters all remove lists nothing, without an error.

**`-O`, or `OPTION 8`, gives the pre-5.0 listing** and the pre-5.0 meaning of every other option
given with it: 8.3 name and extension, size switching to KB/MB, `mm/dd/yy` and a 12-hour time, the
long name, and a summary in kilobytes; `-A` archive-bit files only (DOS; ignored on Linux), `-O`
sort alphabetically, `-P` pause per screen, `-W` wide four-column (sorted, long names; like `-C`
but across not down), `-U` unadorned (no extended names), `-C` columnar sorted with a trailing `\`
on directories and `*` on executables, `-L` long names + permissions (Linux), `-B` bare long name,
`-N` no screen output. Options meant for other commands are accepted and ignored, as before.

<a id="dir-glob"></a>**Glob patterns (BR 5.0), shown for DIR.** The name may be a glob, in any part of the path.
`*` and `?` are as above; the additions are:

| Pattern | Matches |
|---|---|
| `[abc]` `[a-z]` | one character of the set or range |
| `[^abc]` | one character not in the set (`[!abc]` too, but `!` starts a comment unless the name is quoted) |
| `{a,b,c}` | any one alternative; alternatives may be patterns and may nest |
| `**` (a whole path part) | any number of directories, including none |

`DIR src\**\*.cpp` lists every `.cpp` in `src` and below; `DIR data\20*\*.rpt` allows `*` and `?`
in a directory part. The listing has a `Directory of` heading per directory that has a match, directories
in name order, and one total. Each directory's entries are sorted on their own (by name, or by
`-T`/`-S`); with `-N`, and always with `-M`, there are no headings, each name is given whole, and
the listing is sorted as one. Under `-O`, `-O` sorts within each directory. Rules:

- A last part with only `*` and `?` is unchanged (including `DIR name` meaning `name.*`); a pattern
  using any new form is taken as written, with no `.*` added.
- Case follows `FILENAMES SEARCH`. A leading dot is not special; `.` and `..` are never listed.
- No escape character (`\` is the separator): put `[`, `{`, `}` in a set to match them (`[[]`). An
  unclosed `[` or `{`, and `{}` with no comma, are literal, and a file named exactly as the pattern is
  still found.
- A comma inside braces is part of the name (`DIR *.{brs,prc}`); outside braces it separates names.
- A name that ends with `\` or `/` matches folders only: `DIR src\*\` lists the folders in `src`,
  `DIR src\**\` every folder below it. `DIR src\`, with no pattern before the separator, lists what is
  in `src`. For `COPY`, `MOVE` and `FREE`, which take folders only with `-R`, `src\` is the folder
  `src` itself; without `-R` such a name matches nothing.
- `**` descends at most 40 levels. No match is error **4152**.
- `COPY`, `RENAME`, `FREE`, `DROP` and `TYPE` take the same patterns for the files they act on, directory
  by directory in name order. With a directory target, files from several directories (`**`) all go into
  it without their sub-directories; with [`COPY -R`](#copy-recursive) each keeps its place. `MKDIR`, `RMDIR` and `CHDIR` take no pattern.

<a id="copy"></a>**COPY** duplicates one or more files (same/different disk, or rename-in-place with
a new name), and can copy to a device. Options: `-D` omit deleted records (internal files — **rebuild indexes after**), `-N`
no action log, `-P` pause per screen, `-S` copy an **open** file (must be opened `SHR`/`SHRI` else
error **4148**), `-V` verify each action, `-F` overwrite without asking (see
[overwrite](#overwrite)), `-<n>` set the new internal-file record length (space-padded; last within
a combined option word). **`-A` is accepted and has no effect**: it was documented as copying only
archive-bit files and then clearing the bit, but BR 5.0 collects the files without looking at the
bit and clears nothing. **`-C`** (ask for another diskette when the disk fills) **was removed in BR
5.0**; the letter is still accepted, and does nothing for `COPY`. Device targets `PRN:`/`AUX:`/`COM1:`/`LPT1:`… send to a
printer (on Linux these need a `SUBSTITUTE` mapping in [BRConfig.sys](../../00-configuration/config-directives/spec.md));
copying *to* `PRN:`/`WIN:` is illegal — use `TYPE` with redirection. As of 4.2 a print file copies
unaltered to a `DIRECT:` device. **Destination wildcards truncate**: `COPY src\* dest\*` strips the
extension, `dest\*.*` keeps one dot, `dest\*.*.*` keeps two — prefer a bare `dest`.
*Client/server:* `@:` denotes the client (`COPY file @:file` sends to the client's current
directory; `@:file file` pulls from it; `@::` for client absolute paths).

<a id="copy-recursive"></a>**`COPY <from> <to> -R` (BR 5.0)** lets *from* match folders as well as
files, and copies a folder that matches whole, with everything in it at every level. What matches is
decided as without `-R`: `*` looks in one folder, `**` searches the folders below
([glob patterns](#dir-glob)). Each file and folder keeps its place below the fixed part of *from* -
the folders before the first pattern, or before the last part - and goes to that place below the
folder *to*:

| Command | Copies |
|---|---|
| `COPY src backup -R` | the folder `src`, whole, as `backup\src` |
| `COPY src\* backup -R` | everything in `src`, as `backup\...` |
| `COPY src\*.brs backup -R` | the `.brs` files in `src`, and any folder in `src` named `*.brs`, whole |
| `COPY src\**\*.brs backup -R` | every `.brs` file and `*.brs` folder below `src`; `src\lib\b.brs` is `backup\lib\b.brs` |

*to* is a folder, made with the folders below it as they are needed; a folder copied whole is made
even when empty. A *to* that is a file is **4150**, a *to* with a wildcard **600**, and a *to*
inside a folder being copied **4299**. An entry inside a folder already taken is copied once, as
part of it. Entries come in name order, each folder before what is in it, down to 40 levels. The
other options and the [overwrite](#overwrite) rules apply to each file as without `-R`. `RENAME` and
`DROP` refuse `-R` with **1006**.

<a id="move"></a>**`MOVE <from> <to>` (BR 5.0)** moves each file *from* matches, and with `-R` each
folder, to *to*: renamed when the system can do the whole of it in one step, otherwise - *to* on
another drive, share or file system, or across the client (`@:`) and the server - copied and then
freed. What matches and where it goes are as for [`COPY`](#copy) and [`COPY -R`](#copy-recursive):
without `-R` files only, into a folder or under a name; with `-R` a matched folder is moved whole and
each entry keeps its place below the fixed part of *from*. Each match is moved completely before the
next; a folder being copied is moved entry by entry the same way, so what in it can be renamed is. A
folder moved onto one that exists is merged into it, and the one left behind is removed once empty.
A file onto one that exists follows the [overwrite](#overwrite) rules, and a file left where it is
keeps its folder there. A folder moved into itself is **4299**. Options `-R`, `-F`, `-V`
(`Move? (y/n/all)`), `-N`, `-P` and the redirections; `-D`, `-S` and a record length are refused with
**1006**. Abbreviation `MO`.

<a id="rename"></a>**RENAME** renames or moves one or more files (wildcards ok — `RENAME C:*.*
C:\DIR\*.*` moves a whole group keeping each original name). Options: `-N` (no action log), `-P`
(pause per screen), `-V` (verify each rename), **`-F`** (force-delete an existing target when needed to
complete the rename); `PRINT` / `>` / `>>` redirect the log.

<a id="rename-folder"></a>**`RENAME <from> <to> -D` renames a folder (BR 5.0)**, with everything in
it. *from* is one folder, with no wildcards; a *from* that is not a folder is error **4203**. As
with a file, a *to* that is a folder already gets *from* put inside it under its own name; any other
*to* that exists is refused with **4150** and never replaced, so `-F` does nothing with `-D`. A *to*
that is the folder itself under another name (a change of case) renames it, rather than putting it
inside itself. `-V` asks `Rename? (y/n)`. Without `-D`, `RENAME` acts on files only.

<a id="rename-filesystem"></a>**One file system only (BR 5.0).** A *to* on another drive, share
or mounted file system, or on the other side of the client (`@:`) and the server, is refused with
error **4138**, and both names are left as they are; use `COPY` and then `FREE`. This holds for
files and for `-D`. With `-F`, a file that already has the new name is removed only if the rename
succeeds.

<a id="overwrite"></a>**Onto a file that exists (BR 5.0).** `COPY` and `RENAME` ask before replacing
one: `Overwrite <full target name>? (y/n/all)` on a line of its own. `Y` overwrites, `N` leaves that
file and goes on to the next, `A` overwrites it and every later one in the command without asking,
and Esc stops the command. **`-F`** overwrites without asking, on `COPY` as well as `RENAME`. Nobody
is asked in `UNATTENDED` mode or while an assistant holds the prompt: the command stops with error
**4150** (file already exists), and `-F` is the way past it. A target that is the source itself under
another name (a change of case, a relative or 8.3 short name, a hard link) is not another file, so
nothing is asked or refused: `RENAME` goes ahead, and `COPY` becomes a `RENAME`, since there is no
second file to make. The file is left under the second name exactly as written, so `RENAME abc.txt
abc.txt` turns `Abc.txt` into `abc.txt`. [`OPTION 6`](../../00-configuration/config-directives/OPTION_(Config).md)
restores the earlier behaviour: `COPY` replaces the file silently and `RENAME` refuses it with **4150**
unless `-F`.

**TYPE** sends a file's contents to the
screen, a printer, or another file. **`-P`** pauses after each screenful; at the pause a digit
from 2 to 9 shows the next that many lines before pausing again (BR 5.0), and any other key the next
screenful. **MKDIR** subdirectory names follow file-name rules, and the same
name may exist under different parent directories.

<a id="drop-free"></a>**DROP** empties a file's contents — freeing all allocated space and leaving
only the header record for internal files — but keeps the name (size→0). **FREE** deletes the
file(s) outright (unrecoverable). Both take `-N`/`-P`/`-V` and accept wildcards (use `-V` to
verify); `-A` is accepted and has no effect, as on `COPY`. **`FREE <name> -R`** (BR 5.0) deletes
what *name* matches, as [`COPY -R`](#copy-recursive) reads *from*, and frees a folder that matches
whole: its files, then its folders, deepest first. `FREE old -R` removes the folder `old` and
everything in it. Under `-V` each file is asked about, and a folder that still has a file in it is
kept. A procedure can `FREE` itself as its last line; a `.$$$`-named procedure self-deletes
after running. *(The same-named `DROP`/`FREE` **CLOSE parameters** inside a program are a separate
file operation — [30-io-file/statements](../../30-io-file/statements/spec.md#close).)*

<a id="protect"></a>**PROTECT … RESERVE/RELEASE** reserves a full path name for one workstation's
exclusive use (and releases it) — the multi-user purge idiom; see
[30-io-file/file-model](../../30-io-file/file-model/spec.md). **`PROTECT … READ`** makes the file
read-only (it is refused while the file is open for output) and **`PROTECT … WRITE`** makes it
writable again. A name containing `*` is accepted and ignored.

<a id="examples"></a>
## Examples

```text
CHDIR \DATA\REPORTS
DIR *.BR -C
DIR DATA\*.{BRS,PRC}               ! glob (5.0): alternatives
DIR SRC\**\*.CPP -O               ! glob (5.0): every .CPP below SRC, sorted per directory
COPY CUST.FIL TEMP[WSID].FIL -D     ! copy omitting deleted records
RENAME TEMP[WSID].FIL CUST.FIL
COPY A:SAMPLE.* B: -D               ! copy group; drop deleted recs
FREE *.BAK -V
TYPE README.TXT PRINT
```

<a id="see-also"></a>
## See also

- [program-management](../program-management/spec.md) — these commands inside procedures / `EXECUTE`
- [30-io-file/statements](../../30-io-file/statements/spec.md) — in-program `OPEN`/`CLOSE … FREE/DROP`
- [30-io-file/file-model](../../30-io-file/file-model/spec.md) — `[WSID]` per-workstation names, `PROTECT`
- [filename-patterns](filename-patterns.md) — glob patterns, `/` in names and Tab completion in full
- Client-side **OPEN/SAVE file browser** (`OPEN #99: "NAME=OPEN|SAVE:dir[mask],…"`) →
  [30-io-file/statements](../../30-io-file/statements/spec.md)

*(Backing keyword pages — `CHDIR`, `COPY`, `Copy_option`, `DIR`, `Dir_option`,
`Directory_Management_Commands`, `Drop`, `Drop_options`, `FREE`, `Free_option`,
`File_Management_Commands`, `File_Browser`, and the misfiled `Delete_(command)` — were folded into
this spec and pruned. The 2b redirect-collision pages `MkDir` and
`Rename` were likewise folded here and pruned; verbatim wikitext remains on the BR wiki.)*
