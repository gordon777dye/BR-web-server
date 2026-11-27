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
keywords: [DIR, COPY, MOVE, RENAME, MKDIR, RMDIR, CHDIR, FREE, FRE, PROTECT, DROP, TYPE, SEARCH, RESERVE, RELEASE]
corrections:
  - "2026-11-24, from BR 5.03's source (tblcmd.cpp table1k FRE -> FRE_FORCE_CMD; commandc.cpp cmdproc, whose only action for it is error 1000; wbos.cpp s_commandHelp, which has no FRE entry) and a headless run of `FRE -?` (error 1000): the `fre` paragraph after DROP/FREE, and FRE added to the keywords. It had been named only in the FREE-abbreviation correction."
  - "2026-11-22: RESERVE and RELEASE added to the keywords, with `reserve` and `release` anchors on PROTECT's two bullets, so PROTECT's qualifiers (table2k) link to them. The RESERVE qualifier had no link, and the RELEASE qualifier linked to the top of the file-model page."
  - "BR 5.03, 2026-11-22: the regex syntax now has a page of its own, ECMA_REGEX.md (HELP COMMANDS REGEX), linked from the search section. A /regex/ may hold a ! (command.cpp no longer takes it for the start of a remark, which had made /(?!x)/ error 1003)."
  - "BR 5.03, 2026-11-22, from the source change (wbos.cpp, tested headless): SEARCH phase 2 - attributes -~ -W -B -R before the pattern and options -C -L -N after the names (-L with -C or -N is 1006); a line written to a disk file is no longer wrapped at the record length; a line the regex engine gives up on is skipped and noted, not error 1009. The search section and the BNF line are updated."
  - "BR 5.03, 2026-11-22, from the source change (wbos.cpp output(); built, the pause not yet run on a screen): a digit 2 to 9 at the `-P` pause of DIR, COPY, MOVE, RENAME, DROP and FREE shows the next that many lines, as TYPE's and SEARCH's already did. The paging paragraph says so."
  - "BR 5.03, 2026-11-22, from the source change (wbos.cpp: output() and processTypeFile(); built, file output checked headless, the pause itself not yet run on a screen): PgDn at the `-P` pause of DIR, COPY, MOVE, RENAME, DROP, FREE and TYPE shows the next screen starting with the last line shown, as SEARCH's already did. Added the paging paragraph to the intro and PgDn to TYPE."
  - "BR 5.03, 2026-11-21, from the source change (wbos.cpp, tested headless): SEARCH added (phase 1: -I, -P, redirection, literal and /regex/ patterns, several names, cleaned lines, internal files record by record, error 1009). Section `search`, a BNF line and SEARCH in the keywords. Also repaired two `TYPE PRT\\report` examples whose `\\r` had become a line break."
  - "BR 5.0, 2026-11-21, from the source change (wbos.cpp, tested headless): COPY, MOVE and RENAME take several `<from>` and TYPE several `<file>`, separated by commas or blanks, the last name of the first three being `<to>`. The four BNF lines show `<from> [[','] <from>]...`; the rules (folder target unless it has a wildcard, a file matched twice handled once, a name that matches nothing skipped unless none match, RENAME -D one name) are in filename-patterns.md section 1.7."
  - "From the BR 5.0 parsers (see br50 br/docs/FLAGS.md), 2026-10-21, source reading not yet confirmed by a run: COPY, FREE and DROP `-A` removed from the BNF and described as accepted with no effect - findSources() collects every file whatever its archive bit and nothing clears it (wbos.cpp); COPY's BNF gains `-F`, already documented in the overwrite section; the `-<n>` must-be-last rule narrowed to a combined option word (options(), the default case), which is how QSMRP's `COPY a b -124 -d -n` works; TYPE gains `-P` and, new in 5.0, a digit at its pause (processTypeFile()); PROTECT gains READ and WRITE (command0.cpp PROTECT); and the intro points at the new `-?` command help. Later the same day COPY `-C` (prompt for another diskette on a full disk) was removed from BR 5.0, and is removed here from the BNF, the options and the example."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless with a proc: a folder renamed, a folder moved into an existing folder, and a file and a folder refused on E: with both left in place): RENAME gains `-D` to rename a folder (wbos.cpp, RENAME_CMD), and RENAME refuses a target on another file system with 4138, whose message now covers both cases (renameFile() in file_os.cpp, MoveFileEx without MOVEFILE_COPY_ALLOWED; EXDEV on Unix). Added the rename-folder and rename-filesystem paragraphs and `-D` in the BNF."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless with a test program against a three-level tree): COPY and FREE gain `-R`: the name matches folders too and a matched folder is taken whole, each entry keeping its place below the name's fixed part; `**` alone searches below (wbos.cpp: expandFolders(), fixedLength(), makeFoldersFor(); findSources() and globCollect() take a folders flag). RENAME and DROP refuse it with 1006. Added the copy-recursive paragraph and table, FREE -R in drop-free, and `R` in both BNF lines."
  - "BR 5.0, 2026-10-21, from the source change (confirmed headless against test trees, including a move to another drive): new command MOVE (wbos.cpp moveFiles() and moveEntry(); MOVE_CMD and T1_MOVE in bascmd.h, tblcmd.cpp, commandc.cpp, wbserver.cpp; Tab completion in fields.h), and a name ending in a separator matches folders only (globSplit(), sourcesWanted(), keepFolderSlash()). Added the move paragraph, its BNF line, the trailing-separator rule, and MOVE to the keywords."
  - "BR 5.01, 2026-10-24, from the source change (confirmed headless against test trees): MOVE takes a folder named on its own, without wildcards, with or without `-R` - to a name nothing has yet it takes that name, into a folder that exists it goes under its own name, onto a file it is 4150 (moveFolderAsItself() in wbos.cpp); and the to of COPY, RENAME and MOVE gets both OPTION 84 readings (chooseTargetReading()). Added the folder-on-its-own paragraph and the example table to MOVE, and took MOVE out of the trailing-separator rule's folders-only-with-`-R` sentence."
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

<a id="paging"></a>**`-P` pauses after each screenful** of `DIR`, `COPY`, `MOVE`, `RENAME`, `DROP`, `FREE`,
`TYPE` and `SEARCH`. At the pause, the break key ends the command, PgDn (BR 5.03) shows the next screen
starting with the last line shown, a digit 2 to 9 (BR 5.03; `TYPE` since 5.0) the next that many lines
before pausing again, and any other key the next screenful.

**Patterns in file names (BR 5.0).** The name parameter of `DIR` (`<filename> | <glob>`), `COPY`, `MOVE` and
`RENAME` (`<from>`), and `TYPE`, `DROP` and `FREE` (`<file>`) may be a glob pattern (`*`, `?`, `[ ]`, `{a,b}`,
`**`) that names several files. The other parameters take none: `<to>` is a name or a folder (for `COPY`,
`MOVE` and `RENAME` a `*` in it is applied to each file's own name), the `<file>` after `PRINT` or `>` is the
redirect target, and `CHDIR`, `MKDIR`, `RMDIR` and `PROTECT` take no pattern. The pattern syntax, when a name
counts as a glob and how matches are handled are in [filename-patterns.md](filename-patterns.md#globs).
`COPY`, `MOVE`, `RENAME`, `TYPE` and `SEARCH` also take **several** `<from>` (`<file>`) separated by commas or blanks,
the last name of the first three being `<to>`; see [filename-patterns.md](filename-patterns.md#glob-several).

<a id="syntax"></a>
## Syntax

```bnf
CHDIR [<drive>':'] ['\']<path> [-N]     -- CD / CH; no arg = show current dir
MKDIR [<drive>':']<path>                -- MK
RMDIR [<drive>':']<path>                -- RM; directory must be empty
DIR  [<drive>':'][<path>][<filename> | <glob>] [-AOLPWUCB] [PRINT | '>'['>'] <file>]   -- DI
COPY   <from> [[','] <from>]... { <to> | PRN: | AUX: } [-DFNPRSV] [-<new_recl>] [PRINT | '>'['>'] <file>]  -- COP; -R the folders below
MOVE   <from> [[','] <from>]... <to> [-FNPRV] [PRINT | '>'['>'] <file>]  -- MO; renames when it can, else copies and frees
RENAME <from> [[','] <from>]... <to> [-DNPVF] [PRINT | '>'['>'] <file>]  -- REN; renames or moves (wildcards ok); -D a folder
TYPE <file> [[','] <file>]... [-P] [PRINT | '>'['>'] <file>] -- TY; dump 1 or more files to screen/printer/file - concatenate
SEARCH [-I~WBR] <pattern> <file> [[','] <file>]... [-PCLN] [PRINT | '>'['>'] <file>]  -- SE; lines that match: name:line: text
DROP <file> [-NPV] [PRINT | '>'['>'] <file>]   -- DR; empties contents, keeps the name (size→0)
FREE <file> [-NPRV] [PRINT | '>'['>'] <file>]  -- no abbreviation; deletes the file (unrecoverable); -R the folders below
PROTECT <file-ref> ',' { RESERVE | RELEASE | READ | WRITE }   -- PROT; reserve a path / set read-only
```

<a id="semantics"></a>
## Semantics

<a id="chdir"></a><a id="mkdir"></a><a id="rmdir"></a>**CHDIR / MKDIR / RMDIR** navigate/create/remove directories.
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
  in `src`. For `COPY` and `FREE`, which take folders only with `-R`, `src\` is the folder `src`
  itself; without `-R` such a name matches nothing. `MOVE src\ to` is `MOVE src to`, a
  [folder named on its own](#move-folder).
- `**` descends at most 40 levels. No match is error **4152**.
- `COPY`, `RENAME`, `FREE`, `DROP` and `TYPE` take the same patterns for the files they act on, directory
  by directory in name order. With a directory target, files from several directories (`**`) all go into
  it without their sub-directories; with [`COPY -R`](#copy-recursive) each keeps its place. `MKDIR`, `RMDIR` and `CHDIR` take no pattern.

<a id="copy"></a>**COPY** duplicates one or more files (same/different disk, or rename-in-place with
a new name), and can copy to a device. Options: `-D` omit deleted records (internal files — **rebuild indexes after**), `-N`
no action log, `-P` pause per screen, `-S` copy an **open** file (must be opened `SHR`/`SHRI` else
error **4148**), `-V` verify each action, `-F` overwrite without asking (see
[overwrite](#overwrite)), `-<n>` set the new internal-file record length (space-padded; last within
a combined option word). **`-A` is a syntax error (1006)** from BR 5.03: it was documented as
copying only archive-bit files and then clearing the bit, but BR never applied it - it collected
the files without looking at the bit and cleared nothing - so it was accepted and ignored until it
was made an error like any other flag `COPY` does not have. Only `DIR` takes `-A`. **`-C`** (ask for another diskette when the disk fills) **was removed in BR
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

<a id="move-folder"></a>**A folder named on its own** - one folder, no wildcards (BR 5.01) - is moved
as itself, with or without `-R`. To a name nothing has yet, it takes that name: a rename, or copied
under that name and freed. Into a folder that exists, it goes under its own name, merged with a
folder of that name already there. Onto an existing file it is **4150**. A wildcard pattern matches
folders only with `-R`.

| Command | Result |
|---|---|
| `MOVE cc ..`, `MOVE cc/ ..` | `..\cc`, with everything in it |
| `MOVE src dest` (`dest` exists) | `dest\src`; merged with a `dest\src` already there |
| `MOVE src newname` | `src` renamed `newname` |
| `MOVE src aa/bb` | `aa\bb\src` when `aa\bb` exists ([`/` in a file name](../../30-io-file/file-model/spec.md#slash)) |
| `MOVE src other` (`other` is a file) | error **4150** |
| `MOVE src src\sub` | error **4299** |
| `MOVE src .` | nothing moves |
| `MOVE x.dat dest` | `dest\x.dat` |
| `MOVE src dest -R` | `dest\src` |
| `MOVE src* dest` | error **4152**: wildcards match folders only with `-R` |

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

<a id="type"></a>**TYPE** sends a file's contents to the
screen, a printer, or another file. **`-P`** pauses after each screenful; at the pause a digit
from 2 to 9 shows the next that many lines before pausing again (BR 5.0), PgDn the next screen starting
with the last line shown (BR 5.03), and any other key the next screenful. **MKDIR** subdirectory names follow file-name rules, and the same
name may exist under different parent directories.

- **`TYPE <name> [-P] [>file|>>file|PRINT]`**: `name` may hold wildcards, and then every file it names is typed, one
  after the other, into the **one** redirect, so `TYPE *.txt > all.txt` joins them (`>>` appends to an existing file).
  Written to a file the bytes are copied as they are, so a file that holds a blob comes through whole; only on the
  screen are trailing nulls and Ctrl-Z trimmed.
- **Printer escape sequences (4.2+).** `TYPE` translates the printer escape sequences in a print file for the
  *destination*, matched as the destination's printer name is at `OPEN` time (as `NAME=PRN:/printer`). To a display
  file the printer type can be named with `PRINTER_TYPE=<type>`, matched against the second parameter of the
  configuration's `PRINTER` statements: `TYPE PRT\report >PREVIEW:/HP4` translates the HP4 sequences in `report` for the
  preview, and `TYPE PRT\report-file1 >report-file2 PRINTER_TYPE=HP4` copies file1 to file2 interpreting them. In contrast
  `COPY PRT\EDITLIST.255 DIRECT:/HP4` sends a print file to a printer unaltered.

<a id="search"></a>**`SEARCH` (BR 5.03)** (`SE`) shows the lines of text files that contain a pattern, each as
`name:line: text`, a small BR form of `grep`:

```
SEARCH apple notes.txt
SEARCH -I "apple pie" data\*.txt,old\*.txt >hits.txt
SEARCH /^ *PRINT/ src\**\*.brs >lines$
SEARCH -IWR print src\ -L
SEARCH -~ todo notes.txt -C
```

- **The pattern** comes first, after any attributes: a word (`apple`), a quoted literal (`"apple pie"`,
  `'say "hi"'`; two of the quote that opened it stand for one, `"say ""hi"""`), or a regular expression
  between slashes (`/^apple/`, ECMAScript syntax: see [Regular expressions](ECMA_REGEX.md), or
  `HELP COMMANDS REGEX`). A pattern may hold blanks, commas and quotes, and a regex may hold a `!`,
  which elsewhere on the line starts a remark; inside `/.../`, `\/` is a `/`. An unterminated quote or regex is error 1003, and a regex that does not compile
  is [error 1009](../../90-reference/error-codes/1009.md).
- **Attributes**, before the pattern, decide what matches; they may be combined (`-I~WB`):
  - **`-I`** ignores the case of ASCII letters, for both forms.
  - **`-~`** selects the lines that do **not** match.
  - **`-W`** whole word: a match may not touch a word character (a letter, a digit, `_` or `$`) on either
    side, so `-W PRINT` finds `PRINT X` and `(PRINT)` but not `PRINTER` or `PRINT$`. A match that fails
    is passed over and the search goes on in the same line, so `PRINTER PRINT` is found.
  - **`-B`** blank-tolerant: in each line a run of blanks and tabs counts as one blank, and blanks at
    either end are ignored; a literal pattern is treated the same way, so `-B "IF X"` finds `IF   X`
    and `IF<tab>X`. A regex sees the normalised line. The line shown is the line as it is.
  - **`-R`** a folder that a name matches is searched whole, with the folders below it, as `COPY -R`
    takes it; without `-R` a name ending in `\` names folders only and finds nothing (4152).
- **Options**, after the names, decide how the result is shown:
  - **`-C`** only a count of matching lines per file, `name:count`, a file with none included.
  - **`-L`** only the name of each file with a match.
  - **`-N`** no `name:line:` prefix: the lines alone (with `-C`, the counts alone).
  - **`-P`** pauses; see Output below.
  An attribute after the names, an option before the pattern, `-L` with `-C` or `-N`, or any other letter
  (`-V`, `-F`, a record length) is error 1006.
- **The files** are named as for `TYPE`: one or more names, separated by commas or blanks, each of which
  may be a pattern, with the rules of [filename-patterns.md](filename-patterns.md#glob-several): a name
  that matches nothing is skipped unless none match (4152), and a file that two names match is searched
  once. The file the output is redirected to is never searched, so `SEARCH x *.txt >hits.txt` does not
  read its own results.
- **Each line is cleaned before it is compared**: only displayable ASCII (32 to 126) and the tab are
  kept, and every other byte is removed, bytes above 127 among them, so a pattern holding an accented
  letter never matches. The line shown is the cleaned line, so a binary file sends no stray bytes to the
  screen or a redirect. Line numbers count the file's own lines. A UTF-8 byte-order mark at the start of
  a file is ignored.
- **An internal file** is searched record by record: the header is skipped (the record length is read
  from it), each record is a line, numbered by its record number, a deleted record is not searched, and
  trailing blanks are removed. Numeric fields (`PD`, `B` and the like) clean away to nothing or to stray
  characters, so search the character fields.
- **No match** is no output and no error.
- **Output** goes to the screen, wrapped as `TYPE` wraps, or to `>file` or `>>file`, which get each line
  whole however long, or to `PRINT` or
  `>name$`, which fills a string array a line to an element, growing it as
  [filename-patterns.md](filename-patterns.md#glob-matches) describes. With `>name$` the array's size
  is the number of lines found. **`-P`**, after the names, pauses after each screenful: a digit 2 to 9
  shows the next that many lines, PgDn the next screen starting with the last line shown, and any other
  key the next screenful.
- A regular expression is not tried on a line longer than 4,096 characters, nor on a line the regex
  engine gives up on (a pattern such as `(a*)*b` can be too complex for it); the first such line in
  each file is reported on the screen, and the search goes on.
- A restricted session may run it.

<a id="drop-free"></a><a id="drop"></a><a id="free"></a>**DROP** empties a file's contents — freeing all allocated space and leaving
only the header record for internal files — but keeps the name (size→0). **FREE** deletes the
file(s) outright (unrecoverable). Both take `-N`/`-P`/`-V` and accept wildcards (use `-V` to
verify); `-A` is a syntax error (1006) from BR 5.03, as on `COPY`. **`FREE <name> -R`** (BR 5.0) deletes
what *name* matches, as [`COPY -R`](#copy-recursive) reads *from*, and frees a folder that matches
whole: its files, then its folders, deepest first. `FREE old -R` removes the folder `old` and
everything in it. Under `-V` each file is asked about, and a folder that still has a file in it is
kept. A procedure can `FREE` itself as its last line; a `.$$$`-named procedure self-deletes
after running. *(The same-named `DROP`/`FREE` **CLOSE parameters** inside a program are a separate
file operation — [30-io-file/statements](../../30-io-file/statements/spec.md#close).)*

<a id="fre"></a>**`FRE`** is in BR's command table only so that a short spelling of `FREE` is refused
rather than deleting anything: `FRE`, with or without operands, is error **1000** (unidentified
source remaining), and so is `FRE -?`, which has no command help. Type `FREE` in full.

<a id="protect"></a>**`PROTECT <file> {RESERVE|RELEASE|READ|WRITE}`** (`PROT`) turns on or off one of two kinds of file
protection; exactly one of the four words is required. The file name ends at the first blank or comma, so
`PROTECT CUSTOMER.FIL RESERVE` and `PROTECT CUSTOMER.FIL, RESERVE` are the same. A name containing `*` is
accepted and ignored.

**Multi-user protection: `RESERVE` and `RELEASE`.**
- <a id="reserve"></a>`RESERVE` reserves the file's full path name for **this workstation's exclusive use**: before every
  `OPEN` BR consults a table of reservations, and an `OPEN` by another workstation fails with error **4148**
  (file sharing rules violated) without touching the disk. The reservation holds even when the file is not
  open, and it reserves the *name*, so it can be made for a file that does not exist, or kept after `FREE` has
  deleted the file, which lets you reserve a name, delete the file, and rename the contents of another file
  to it. Reserving a file this workstation has already reserved is not an error.
- <a id="release"></a>`RELEASE` removes a reservation, and only the workstation that made it can. All of a workstation's
  reservations are released when it leaves BR. `STATUS ALL` lists the ones issued from this workstation.
- Alternatives when the file is open: `CLOSE` with `RELEASE` (to release) and `OPEN` with `RESERVE` (to reserve).
- It differs from locking with `NOSHR` in two ways: `PROTECT` keeps the file locked while it is not open, and
  it does **not** stop other opens by the same workstation.
- The multi-user purge idiom (remove deleted records and rebuild the index while nobody else can open the file),
  as a procedure:

  ```text
  PROCERR RETURN
  PROTECT CUSTMAST,RESERVE
  PROCERR STOP
  SKIP DONE IF ERR <> 0
  COPY CUSTMAST WORK[WSID] -D
  FREE CUSTMAST
  RENAME WORK[WSID] CUSTMAST
  INDEX CUSTMAST,CUSTMAST.KEY,1,4,REPLACE
  PROTECT CUSTMAST,RELEASE
  :DONE
  CHAIN "MENU"
  ```

  Without the `RESERVE`, another workstation could open the file during the `COPY` and the `FREE` and `RENAME`
  would fail. `SKIP` tests `ERR` only for zero or not because `PROCERR RETURN` forces it to zero. See also
  [30-io-file/file-model](../../30-io-file/file-model/spec.md).

**Read protection: `READ` and `WRITE`.** `READ` makes the file read-only (the file must exist, and it is refused
while the file is open for output): every workstation, **including the one that issued it**, can read the data
but not change it. `WRITE` removes that and allows reading and writing again. The operating system's permissions
decide whether either succeeds. Unlike a reservation, read protection stays on the file after the workstation
leaves BR, and it works on single-user systems too.

Unlike `RESERVE` and `RELEASE`, which touch only BR's own table, `READ` and `WRITE` **change the file's real
operating-system permissions**, so they take effect for every program, not just BR, and they are not reversed
by anything but `WRITE` (or a change made outside BR). Exactly what is set, from the source:
- **Windows:** `READ` sets the file's attributes to *archive + read-only*; `WRITE` sets them to *archive* only.
  The whole attribute set is **replaced**, not edited, so any other attribute the file had (hidden, system)
  is cleared by either word.
- **Unix:** `READ` does `chmod 0444` (read-only for owner, group and everyone); `WRITE` does `chmod 0666`
  (read and write for all three). The file's previous mode is not remembered, so `WRITE` on a file that
  was `0640` leaves it `0666`, **widening access to group and public**, and execute bits are dropped by both.
- `READ` first opens the file once to check that it exists and is not open for output; a failure comes back as
  an ordinary file error. `PROTECT` is refused in a restricted session.

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
