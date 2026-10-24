---
title: File name patterns and Tab completion
file: filename-patterns.md
source: BR 5.0 behaviour, verified against the interpreter source and by running it
category: 70-commands
subcategory: 70-commands/file-directory
kind: concept
status: 2b
related: [spec, ../editing/spec, ../program-management/spec, ../../30-io-file/file-model/spec, ../../00-configuration/config-directives/OPTION_(Config)]
keywords: [DIR, COPY, MOVE, RENAME, FREE, DROP, TYPE, LOAD, RUN, SAVE, REPLACE, MERGE, PROC, SUBPROC, CD, LIST, STATUS, DISPLAY, INDEX, MKDIR, RMDIR, CHDIR, glob, OPTION 84, Tab completion]
---

# File name patterns and Tab completion

The file and directory commands share three BR 5.0 behaviours, stated in full
here: **glob patterns** in file names, **`/` as a folder separator**, and **Tab
completion** of file names at the `READY` prompt, which also serves the program
commands (`LOAD`, `RUN`, `SAVE`, `LIST <` …). The command syntax is in
[spec.md](spec.md).

## Contents

1. [Glob patterns](#globs)
   1. [Where a pattern may be used](#glob-where)
   2. [Pattern syntax](#glob-syntax)
   3. [Matching a character that is part of the syntax](#glob-literal)
   4. [When a name is a glob](#glob-when)
   5. [The command line](#glob-command-line)
   6. [What the commands do with the matches](#glob-matches)
2. [`/` in a file name](#slash)
3. [Tab completion at the `READY` prompt](#tab-completion)
   1. [What it does](#tab-what)
   2. [Details](#tab-details)
   3. [Options not taken](#tab-not-taken)

<a id="globs"></a>
## 1. Glob patterns

<a id="glob-where"></a>
### 1.1 Where a pattern may be used

| Command | What a pattern names |
|---|---|
| `DIR` | the entries to list |
| `COPY` | the files to copy (the source; the target is a name, a directory, or a name with `*`) |
| `RENAME` | the files to rename |
| `MOVE` | the files to move, and with `-R` the folders (the target as for `COPY`) |
| `FREE`, `DROP` | the files to delete or empty |
| `TYPE` | the files to show, one after the other |

`MKDIR`, `RMDIR` and `CHDIR` name one directory and take no pattern. A pattern
may be in any part of the name, in the file part or in a directory part:

```
DIR data\*.{brs,prc}
DIR data\rpt[0-9][0-9].dat
DIR src\**\*.cpp
DIR data\20*\*.rpt
COPY src\**\*.cpp backup\
FREE tmp\*.{bak,old}
TYPE notes\[ab]*.txt
```

<a id="glob-syntax"></a>
### 1.2 Pattern syntax

| Pattern | Matches |
|---|---|
| `*` | any run of characters, including none; never crosses a separator |
| `?` | exactly one character |
| `[abc]` | one character that is a, b or c |
| `[a-z]` | one character in the range |
| `[^abc]` or `[!abc]` | one character that is not in the set |
| `{a,b,c}` | any one of the alternatives |
| `**` as a whole part of the name | any number of directories, or none |

- **Sets.** A set ends at the first `]` after its members. A `]` that comes
  first in the set (after the `^` or `!`, if there is one) is a member:
  `[]x]` is `]` or `x`. A `-` between two characters is a range; a `-` first
  or last is itself. Case follows `FILENAMES SEARCH`, so `[a-c]` also matches
  `B` where names are not case sensitive.
- **`^` and `!`.** Either as the first character of a set makes it a negation
  (`[^abc]` and `[!abc]` are the same). `!` is the POSIX form; `^` is the same
  one that most shells and regular expressions use inside brackets, and is the
  one to write in a command line because `!` begins a comment there unless the
  name is quoted. They mean nothing anywhere else: outside a set, `^` is an
  ordinary character, and there is no start-of-name anchor, since a pattern
  always has to match the whole name (`a*` is "starts with a", `*a` is "ends
  with a"). To match a caret or an exclamation mark inside a set put it
  anywhere but first: `[a^]`, `[x!]`.
- **Alternatives.** They may contain any pattern, including other `{ }` and
  sets: `{a,{b,c}}.*` is `a.*`, `b.*` or `c.*`. A `{ }` with no comma at its
  own level is not a list; it stands for itself.
- **`**`.** It is a whole part of the name, between separators. `src\**\*.cpp`
  is every `.cpp` in `src` and every directory below it, and `src\**` is every
  file in `src` and below. `**` inside a name (`a**b`) is the same as `*`. It
  goes down at most 40 directories; a name may have at most 64 parts.
- **A leading dot is not special.** `*` matches `.hidden`. The entries `.` and
  `..` are never matched by a pattern.
- **Case** follows `FILENAMES SEARCH`, as the old `*` and `?` always did.

<a id="glob-literal"></a>
### 1.3 Matching a character that is part of the syntax

There is no escape character: backslash is the separator on Windows. To match
`[`, `{` or `}` themselves put them in a set. A `]` that is not inside a set is
an ordinary character and needs nothing.

| To match | Write |
|---|---|
| `[` | `[[]` |
| `{` | `[{]` |
| `}` | `[}]` |
| `]` | `]` (outside a set) or `[]]` |

So `x[[]1].txt` is `x`, a set holding `[`, `1`, a plain `]`, and `.txt`: it
matches the one file named `x[1].txt`, and `x[[]*].txt` matches every
`x[…].txt`.

A `[` or `{` that has no closing partner is itself. And **a name that is the
pattern written out is also a match**: the file `a[1].txt` is found by asking
for `a[1].txt`, although `[1]` as a set would match only `a1.txt`.

<a id="glob-when"></a>
### 1.4 When a name is a glob

A name is treated as a glob only if some part uses a form that `*` and `?`
alone could not:

- a set `[ ]` or a list `{a,b}` in any part;
- `**` as a whole part;
- `*` or `?` in a part that is not the last.

A name whose last part has only `*` and `?` is listed the way it always was,
including `DIR name` meaning `name.*`, and the DOS rule that a pattern ending
in its first dot matches only names with no dot. A glob is taken as written:
`{a,b}` does not have `.*` added to it.

<a id="glob-command-line"></a>
### 1.5 The command line

- **Commas.** A comma separates names, except inside `{ }`, where it belongs to
  the name. `DIR *.{brs,prc}` is one name.
- **`!`.** `!` begins a comment in a command line unless it is inside quotes, so
  `[!abc]` must be quoted: `DIR "data\[!ab]*"`. `[^abc]` needs no quotes.
- **Quotes.** A name may be quoted with `'` or `"`; the quotes are not part of
  it.

<a id="glob-matches"></a>
### 1.6 What the commands do with the matches

- The matches are taken **directory by directory, in name order**, files in name
  order within each.
- `DIR` prints a `Directory of` heading for each directory that has a match, a
  blank line between them, and one total at the end. `-B`, `-W`, `-C`, `-A`
  and `>` work as for any `DIR`; `-O` sorts within each directory.
  `DIR` lists directories that match as well as files.
- `COPY`, `MOVE`, `RENAME`, `FREE`, `DROP` and `TYPE` act on **files only**, never on a
  matching directory. (`RENAME -D` renames one folder, and takes no pattern; see
  [spec.md](spec.md#rename-folder). With `-R`, `COPY`, `MOVE` and `FREE` match folders too,
  and take a matching folder whole; see [spec.md](spec.md#copy-recursive).)
- A name that ends with `\` or `/` matches **folders only**: `DIR src\*\` lists the
  folders in `src`, `DIR src\**\` every folder below it, and `COPY src\*\ bak -R`
  copies the folders in `src` and not its files. `DIR src\`, with no pattern before
  the separator, lists what is in `src`; for `COPY`, `MOVE` and `FREE -R` it is the
  folder `src`.
- `COPY ... dir\` puts every file into the directory, **without its
  sub-directories**, so two files with the same name from different
  directories overwrite each other; with `-R` each file keeps its place below the
  folders before the first pattern. `RENAME` and `COPY` to a name with `*` apply
  the `*` to each file's own name (`RENAME a{1,2}.txt *.bak`).
- A pattern that matches nothing is error **4152**, file not found, as before.
- Redirection (`> file`, `>> file`, `> A$`) works for the commands that had it.

<a id="slash"></a>
## 2. `/` in a file name

A `/` has two readings, the System/23 one (`file/directory/drive`, and
`file//10`, `file//11` for the spooler and AUX) and a folder separator.
`OPTION 84` says which is tried first and whether the other is tried if the
first finds no file or folder. The full rules are in
[file-model](../../30-io-file/file-model/spec.md#slash) and the option is in
[OPTION (config)](../../00-configuration/config-directives/OPTION_(Config).md). In brief:

- The name is resolved the first way and the operation tried; if it fails as
  file not found (4152) or path not found (4203) it is tried the other way.
  Nothing looks at the disk to decide.
- Level 1, the default: System/23 first if the name has a `\`, has only one `/`,
  or has `//` and a digit (which is never read any other way); otherwise
  folders first. Level 0 is the behaviour of earlier releases; level 5 is
  folders only.
- Patterns work with `/` as with `\`: `DIR src/**/*.cpp`.
- `CHDIR` goes to whichever reading is a directory.

<a id="tab-completion"></a>
## 3. Tab completion at the `READY` prompt

<a id="tab-what"></a>
### 3.1 What it does

With the cursor in a file name of one of these commands, **Tab** completes the
name from the files that are there:

| Command | Shortest form Tab knows | Words completed | `>` file |
|---|---|---|---|
| `COPY` | `COP` | the first and second (source and target) | yes |
| `RENAME` | `REN` | the first and second (from and to) | yes |
| `MOVE` | `MO` | the first and second (from and to) | yes |
| `FREE` | `FREE` | the first | yes |
| `DROP` | `DR` | the first | yes |
| `TYPE` | `TY` | the first | yes |
| `DIR` | `DIR` | the first | yes |
| `LOAD` | `LO` | the first | |
| `RUN` | `RU` | the first | yes |
| `SAVE` | `SA` | the first | |
| `REPLACE` | `REP` | the first | |
| `MERGE` | `ME` | the first | |
| `PROC` | `PROC` | the first; in `PROC *name` the `*` stays and the name after it is completed | |
| `SUBPROC` | `SU` | the first | |
| `RMDIR` | `RM` | the first — **directories only** | |
| `CHDIR` | `CH`, or `CD` | the first — **directories only**. `CD` may have `\`, `/` or `.` straight after it (`CD\data`, `CD..\x`), as BR allows | |
| `LIST` | `LIS` | only a word that begins with `<`, wherever it is on the line (`LIST <menu`, `LIST 100 500 <menu`); the `<` stays and the name after it is completed. See [`LIST <program`](../editing/spec.md#list-input) | yes |
| `STATUS` | `ST` | none | yes |
| `DISPLAY` | `DIS` | none | yes |
| `INDEX` | `I` | none | yes |

**The `>` column** is the output redirection. On these commands a word that
begins with `>` or `>>` is a file name wherever it is on the line, and Tab
completes the name written straight after the `>` or `>>`, leaving them in
place: `DIR *.brs >li` becomes `DIR *.brs >list.txt`, `STATUS >>lo` becomes
`STATUS >>log.txt`. These are the commands that read a redirection
themselves. `GO` and `BREAK` refuse one, so Tab does not complete it there,
nor on `LOAD`, `SAVE` and the others with no mark in the column. A
redirection to a string array of the running program (`> A$`) names no file,
and Tab offers files only.

The names are those of BR's own file system, found the way the command itself
would find them (drive, current directory, `DRIVE` mappings), and so are the
**server's** files. Every file is offered, whatever its extension, even where
the command adds one itself (`LOAD`, `RUN`, `LIST <`).

| Names starting with what was typed | Result |
|---|---|
| one | it is put in. A directory gets a separator after it, so the next Tab goes into it. A file that is the first name of `COPY` or `RENAME` gets a blank after it, ready for the second (a `>` file does not) |
| none | the bell; the line is unchanged |
| several | they are **listed**, sorted, in columns above the command line, and the line comes back below the list with the first of them put in and the cursor after it. No bell |

Tab again, with the line and the cursor exactly as the last Tab left them,
puts the **next** name in place of the one before, and after the last comes
round to the first again; the list is shown only once. Enter takes the name
that is there. Anything typed or moved ends the round and makes the next Tab a
fresh completion, so a directory is entered by typing `\` or `/` after it and
pressing Tab. A name put in this way gets nothing after it: no separator for a
directory and no blank before a second name. The list is cut to the height of
the screen less three rows and ends `... and n more`.

<a id="tab-details"></a>
### 3.2 Details

- **The word** is the one the cursor is in, up to the cursor. What follows the
  cursor is kept, so a name in the middle of a line can be completed.
- **Separators.** `\` and `/` both end a directory part. A completed directory
  keeps the separator the person typed, or `\` if none was typed.
- **Quotes.** A name with a blank or comma in it is put in quotes (`"` unless
  the name has one, then `'`), the opening quote going before the whole word. It
  completes inside the quotes once they are open, and a completed file gets its
  closing quote. A directory is left open, to be continued.
- **Case.** The completed name takes the case of the file.
- **Not completed.** Options (`-S`, `-NPVF`) and any word after the file
  names the command takes (a third word of `COPY` or `RENAME`, `TYPE`'s
  `PRINT`, `LOAD`'s or `SAVE`'s `SOURCE`, `RUN`'s `PROC`) are not file names;
  Tab there sounds the bell. On a `LIST`, `STATUS`, `DISPLAY` or `INDEX` line
  every word but a `<` (`LIST` only) or `>` word is left alone. A word with
  `*` or `?` in it is not completed.
- **Abbreviations.** The command word may be the shortest form in the table in
  3.1 or anything longer, which is exactly what BR itself accepts. `FREE`,
  `DIR` and `PROC` have no abbreviation: BR refuses `FR` and `FRE`, `DI`
  is also `DISPLAY`, and `PRO` is also `PROCERR` and `PROTECT`. A shorter word
  is ambiguous to BR (`CO` is also `CONFIG`, `T` also `TIME`, `L` and `LI` also
  `LINK`, `M` also `MKDIR`, `RE` also `RENUM`, `S` also `SAVE` …), and Tab
  after it moves to the next tab stop. `INDEX` is the only command beginning
  with `I`, so `I` alone is enough.
- **Everywhere else Tab is what it was**: on any other command, and in the
  command word itself, it moves the cursor to the next tab stop.
- **Length.** A completion that would make the line longer than the command
  line allows (2000 characters) is not made.

<a id="tab-not-taken"></a>
### 3.3 Options not taken

- Tab does not complete for commands not in the table in 3.1 (`MKDIR`,
  `PROTECT`, `SORT` and the rest), nor `INDEX`'s own file names (only its `>`
  file).
- It does not expand a pattern: a word with `*` is left alone.
- It is not offered to a program's `LINPUT`, only to the `READY` prompt.
