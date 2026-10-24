---
title: Command signatures
file: command-signatures.md
category: 70-commands
subcategory: 70-commands
kind: reference
related: [program-management, file-directory, information, editing]
corrections:
  - "Brought into line with the 2026-10-21 corrections to the four command specs (from the BR 5.0 parsers; see br50 br/docs/FLAGS.md): a fifth reading rule for the `-?` command help; COPY/DROP/FREE lose -A, which BR accepts and ignores, and COPY gains -F; the record-length rule narrowed; TYPE gains -P; PROTECT gains READ and WRITE; EDIT gains its operands; BREAK and DISPLAY gain IF and FILE; PROCERR gains REM. brls reads these signatures through its generator, so it follows only once regenerated."
  - "Brought into line with BR50 Release_Notes.md (dev/tools): AI and DEBUG gain signatures (1.30, 2.19, 2.1, 2.2, 3.1, 3.2, 3.7); DIR gains the 5.0 options -T -S -R -M -N -B and +ddd (1.29), with the old letters kept for -O and OPTION 8; LIST gains CLAUSES and NOEJECT (1.30). New operand kind <plusint>."
---

# Command signatures

The argument shape of each BR console command, in one strict, machine-readable table. The prose
BNF in the four command specs ([editing](editing/spec.md), [file-directory](file-directory/spec.md),
[information](information/spec.md), [program-management](program-management/spec.md)) is written for
a reader, with `--` commentary and informal brackets; this page restates it so a tool can match a
command line against it. **Nothing here is new behaviour.** Every line cites the page it restates, and
where a spec is vague the signature is deliberately loose (`<word>`, `<text>`) rather than guessed.

A command is runnable from code only through `EXECUTE "<command-string>"`
([program-management](program-management/spec.md#execute)), which is how brls meets them. Command
**names and abbreviations** are not listed here: they come from BR's own `table1k`.

<a id="notation"></a>
## Notation

One command form per line; blank lines and `--` comments are ignored. A line is the command's full
name followed by its operands.

| Element | Meaning |
|---|---|
| `WORD` | a keyword, written as in BR's tables. A qualifier from `table2k` may be abbreviated; any other word is matched whole. Case is ignored |
| `'text'` | a literal word, such as `','` or `'-p'` |
| `<kind>` | an operand, one word; see the kinds below |
| `[ … ]` | optional |
| `{ a \| b }` | one of the alternatives; each alternative is a sequence |
| `{ a \| b }*` | any number of the alternatives, in any order |

Words are separated by blanks or commas; a comma is a word of its own, and a quoted string is one word
whatever it holds.

<a id="reading"></a>
### How a line is read

The signatures describe the operands; five rules describe how BR reads the line around them, and are
applied to every command. Each was found by running the signatures over the QSMRP source, where
production programs use forms the command specs do not write down, and each is backed by the tree where
the tree speaks:

- **Options stand anywhere.** A word that is a dash and letters or digits (`-N`, `-D`, `-124`) is an
  option, and is passed over wherever it falls and for any command. The specs list options per command
  ([file-directory](file-directory/spec.md) gives `-D -F -N -P -S -V` for the file commands, and
  [INDEX](../30-io-file/keys-indexes/INDEX.md) gives `-N`), but QSMRP also writes `-N` after `SORT`,
  `TYPE`, `DIR`, `MKDIR`, `PROTECT` and `PROC`, and `COPY a b -124 -d -n` with the record length
  *before* other options, which BR accepts: it must be last only within one combined option word. The
  letters are not checked.
- **A comma is a blank.** [INDEX.md](../30-io-file/keys-indexes/INDEX.md) says parameters are
  separated by spaces or commas, and QSMRP writes `PROTECT f Release` and `PROTECT f, Release` alike.
  A `','` in a signature is therefore never required.
- **Keywords may be abbreviated** to two letters or more (`INDEX … Rep Dup -N`). The commands have no
  table to say which prefixes are unique, so any prefix is accepted.
- **Case is ignored.**
- **`-?` alone is the command help** (BR 5.0). A line whose operands are exactly `-?` matches every
  command in BR's table except `HELP` and `LINK`: it lists the command's options and runs nothing
  ([command-help](program-management/spec.md#command-help)). `-?` among other operands is not this,
  and is not an option either, since `?` is neither a letter nor a digit: it is error 1006, whatever
  the command and wherever it stands after the command's keyword.

| Operand | Accepts |
|---|---|
| `<int>` | digits only |
| `<dashint>` | `-` followed by digits, as in `RENUM -245 -365` |
| `<plusint>` | `+` followed by digits, as `DIR +7` (entries changed 7 or more days ago) |
| `<word>` | any one word, including a quoted string |
| `<path>` | a file or directory name: any one word |
| `<string>` | a quoted string |
| `<text>` | one or more words, to the end of the line |
| `<redirect>` | `PRINT`, or `>file` / `>>file`, the file attached or in the next word |
| `<fromfile>` | `<name`: the `<` written against the name, as `LIST <menu` |
| `<search>` | a quoted string, optionally preceded by `~` |
| `<flags:XYZ>` | `-` followed by one or more of the letters shown, as `-AOLPWUCB` |
| `<status-topic>` | any one word; the topics BR knows are `STATUS`'s table |

<a id="signatures"></a>
## Signatures

```brcmd
-- editing/spec.md#syntax
AUTO     [<int>] [[','] <int>]
RENUM    [<dashint>] [<dashint>] [<int>] [<int>] [LABELS_ONLY]
DEL      <word> [<word>] [SOURCE]
LIST     { <fromfile> [<int> [<int>]] | [<word>] [<word>] [<search>] [<search>] [<search>] [REPLACE <string>] [{ CLAUSES | NOEJECT }*] [<redirect>] }
EDIT     [{ '-' | '~' | <path> }]

-- file-directory/spec.md#syntax
CHDIR    [<path>] [<flags:N>]
MKDIR    <path>
RMDIR    <path>
DIR      [<path>] { <flags:ABCLMNOPRSTUW> | <plusint> | <redirect> }*
COPY     <path> <path> [<flags:DFNPRSV>] [<dashint>] [<redirect>]
RENAME   <path> <path> [<flags:DNPVF>] [<redirect>]
MOVE     <path> <path> [<flags:FNPRV>] [<redirect>]
TYPE     <path> [<flags:P>] [<redirect>]
DROP     <path> [<flags:NPV>] [<redirect>]
FREE     <path> [<flags:NPRV>] [<redirect>]
PROTECT  <path> ',' { RESERVE | RELEASE | READ | WRITE }

-- information/spec.md#syntax; BR50 Release_Notes 3.1-3.2, 3.7, 2.1-2.2 for DEBUG
DEBUG    [{ AUTH [{ COOKIE | TOKEN <word> | OFF }] | LISTEN [<int>] | OBSERVE [{ <int> | OFF }] | SCREENLOG { <path> | OFF } | LOG <text> | CONNECT <text> | DISCONNECT [<text>] | CONSOLE [<text>] | INTERNAL [<text>] | PROFILE [<text>] | STEP [<text>] }]
DATE     [<word>]
TIME     [<word>]
RUN      [<word>] [PROC] [STEP] [TRACE] [NORESTORE] [RESTORE]
BREAK    { ALL OFF | IF <text> | FILE <word> [{ OPEN | CLOSE }] [OFF] | ['-p' <word>] <word> [OFF] [IF <text>] }
DISPLAY  { FILE <word> [{ OPEN | CLOSE }] [OFF] [PRINT] | ['-p' <word>] { ALL | MAT <word> | <word> } [{ OFF | <redirect> }] [IF <text>] }
STATUS   [<status-topic>] [<text>]
VERIFY

-- program-management/spec.md#entry-exit, #program-commands, #clear, #go, #procedures
SYSTEM   [{ LOGOFF [ALL] | <int> | <text> }]
LOAD     <path> [[','] RESIDENT] [SOURCE] [OBJECT]
SAVE     <path> [SOURCE] [OBJECT]
REPLACE  [<path>] [SOURCE] [OBJECT]
MERGE    <path> [<dashint>] [<dashint>] [{ <int> | ADD }]
CLEAR    [{ ALL | PROC [ONLY] | RESIDENT [<string>] [STATUS] }]
GO       [RUN] [{ STEP | NOSTEP }] [{ TRACE [PRINT] | NOTRACE }] [<word>]
PROC     [<text>]
SUBPROC  <text>
PROCERR  { STOP | RETURN | REM }
AI       [{ NEW | <text> }]
ALERT    <text>
SKIP     <word> [IF <text>]

-- 30-io-file/keys-indexes/spec.md#index and INDEX.md (SHR, BTREE, ISAM)
INDEX    <path> <path> <word> <word> [<word>] { REPLACE | REORG | VERIFY | DUPKEYS | LISTDUPKEYS | BADKEYS | LISTBADKEYS | NATIVE | SHR | BTREE | ISAM | <redirect> }*

-- 40-io-printing/sort/spec.md#syntax
SORT     [<path>]
```

<a id="unspecified"></a>
## Commands with no signature

These are in BR's command table and are not documented in this tree, so nothing is stated about their
operands and a line using them is not checked past the name: `CONFIG`, `FRE`, `HELP`, `LINK`. (`FRE` is refused with error 1000; see [file-directory](file-directory/spec.md).)
`LOGGING` is documented in [information](information/spec.md) but is not in BR's command table
(`table1k`), so it has no signature here either.

<a id="notes"></a>
## Notes on the looser lines

- **`LIST`, `DEL`, `GO`, `BREAK`**: the line-reference operand is `<word>` because the specs allow a
  line, a range, a label, `n:clause` and `.n` without giving one grammar for them. `LIST` takes up to
  two, since the spec says blank-separated line numbers may limit `LIST <program` and is silent on
  whether plain `LIST` does too.
- **`RUN`**: the two spellings in the specs, `RUN [<program>] [PROC] [STEP|TRACE]` and
  `RUN [STEP] [TRACE] [NORESTORE|RESTORE]`, are merged. `PROC` is an option, never a file name
  ([run-proc](program-management/spec.md#run-proc)).
- **`SYSTEM`**: inside an `EXECUTE` string the operating-system command is the rest of the line, with no
  quotes of its own (`EXECUTE "SYSTEM chmod 777 x"`), so it is `<text>`.
- **`PROC`, `SUBPROC`**: the specs name only the procedure (`PROC {name|*name|ECHO|NOECHO}`), but QSMRP
  writes `SubProc * default.clr` and `Proc default.clr -N`, so anything may follow.
- **`INDEX`**: the work path is `<word>` and so also accepts a stray word that is not a keyword. The
  spec and INDEX.md disagree on how the work path is written (`[<work-path>]` against `[-<work path>]`).
- **`STATUS`**: the spec lists topics with "…", so the topic is not checked.

- **`DEBUG`**: the sub-options BR 5.0 documents are given their operands (`AUTH`, `LISTEN`, `OBSERVE`,
  `SCREENLOG`); the others in BR's table (`LOG`, `CONNECT`, `DISCONNECT`, `CONSOLE`, `INTERNAL`,
  `PROFILE`, `STEP`) are named and take `<text>`, since the release notes name them without giving
  their operands. `DEBUG LISTEN` takes a port and nothing after it: anything more is error 1006
  (release notes 2.2).
- **`DIR`**: the letters are the union of the 5.0 options (`-T -S -R -A -L -N -B -W -C -M -P -O`) and
  the 4.x ones kept under `-O` and `OPTION 8` (adding `-U`). Which set applies depends on `-O` and
  `OPTION 8`, which a signature cannot see, so the letters are not checked (options stand anywhere).
  `-ddd` is an option word; `+ddd` is `<plusint>`.
- **`AI`**: `AI NEW` starts a fresh conversation; any other text is the question. The assistant is not
  itself allowed to use it (error 4171).
