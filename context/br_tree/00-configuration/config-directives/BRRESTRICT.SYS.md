---
title: BRRESTRICT.SYS
file: BRRESTRICT.SYS.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
since: BR 5.0
related: [brconfig.sys, DRIVE, restricted session, SPAWN_RESTRICTED, 4165, 4153, WORKPATH, SPOOLPATH, PRINTDIR]
---
**brrestrict.sys** is the file list: it names the folders and files BR may work with, and it binds **every BR session** run from that installation, whether restricted or not. Reading, creating, changing, renaming, deleting and listing are all confined to what the list permits, less what it excludes. Anything else is refused with error [4165](../../90-reference/error-codes/4165.md), *brrestrict.sys does not permit this file*.

**With no `brrestrict.sys` installed, nothing is limited by it.**

## Where it lives

`brrestrict.sys` goes in the directory of the BR executable. It is not a `brconfig.sys` statement and not a command-line argument, so a session cannot choose its own list. The only way to change what a session may reach is to change the installation it runs from.

**Each side reads its own.** The server's list governs the server's files. The client's own list, beside the client executable, governs the files on the client machine: those a program names for the client, `MSG("dump", …)`, `MSG("shot", …)` and a print job written to a named file. A server's list does not limit a client, so all folders on a client machine are open until a list is installed there.

**When it is read.** Once per session: on the server, just after `brconfig.sys` and its `INCLUDE`s have been read; on the client, when the session starts. The configuration file and its `INCLUDE`s are therefore the one thing a session reads whatever the list says. Everything after them is governed, including the startup command, the procedure it names and the program that procedure loads. Changing the file affects sessions started afterwards, not ones already running.

## An example

```
# where BR may work - one entry a line
Q:\qsmrp
Q:\qsmrp\data
!Q:\qsmrp\data\payroll
:C:\ADS\w*.wrk
:C:\ADS\shared
WORK :C:\ADS\qsmrp\context\app\test
```

## The entries

| Line | Meaning |
|---|---|
| `Q:\data` | a directory: it and everything under it |
| `Q:\rates.dat` | one file |
| `Q:\data\*.rpt` | the `.rpt` files in `data` |
| `Q:\data\**\*.rpt` | the `.rpt` files in `data` and every directory under it |
| `!Q:\data\payroll` | an **exclusion** inside a permitted tree |
| `:C:\ADS\shared` | a native path, marked by the leading colon |
| `WORK Q:\data\test` | a [`WORK` tree](#work-trees): where a change needs no permission |
| `@payroll` | the entries below apply only to the login name `payroll` |
| `@all` | the entries below apply to every user |
| `# text` | a comment |

- **One entry a line, and nothing else on it.** Leading and trailing spaces are ignored, and so are blank lines. A comment must be a line of its own beginning with `#`; text after an entry is taken as part of its path.
- **`#` is the comment character here, not `!`.** `!` marks an exclusion, as in a `.gitignore`. That is deliberate: a line meant as a comment but read as an exclusion excludes nothing and is logged, while an exclusion read as a comment would silently leave a file permitted.
- **Entries are BR names**, resolved through the session's `DRIVE` statements, **unless they begin with a colon**, which marks a native path. The drive mapping is fixed when the list is read, so a `DRIVE` added later cannot move an entry. On the client, entries are native names either way. A forward slash is an ordinary path separator; BR's `<filename>/<parent-path>` form does not apply.
- **An exclusion overrides every permit**, whatever order the lines are in, and a session's own files are no exception to it. To allow something inside an excluded area, narrow the permit instead of adding one.
- **`*` and `?` match within one name, and `**` crosses directories.** So `data\*.rpt` is the files in `data` itself, and `data\**\*.rpt` reaches every directory under it, `data` included. There are no bracket expressions and no backslash escape.
- **Whatever an entry names, it takes the tree under it if it is a directory**, by pattern as well as exactly: `Q:\*\data` is each application's data directory and everything in it.
- **Names are compared without regard to case** on every platform, Linux and macOS included.
- **An entry for something not there yet applies straight away, by name.** An exclusion for a directory that does not exist yet also stops that directory being created.
- **Every name is resolved to the file it actually reaches** before it is compared, and so is every entry. A junction, a symbolic link, `..`, a relative path and an 8.3 short name cannot widen or evade the list. In particular, a junction inside a permitted directory does not make its target reachable. A directory may be named in the list by any of its paths.
- **A list fails closed.** If the file is there but none of its lines is usable, it permits nothing.

### Entries per user

A line of its own beginning `@` qualifies every entry that follows it, until the next `@` line:

```
Q:\common
@payroll
Q:\wages
!Q:\wages\archive
@all
Q:\reports
```

`@all` is the default, so a list without any `@` line applies to every user. `@<username>` matches the session's login name without regard to case, as `brconfig.sys` matches its own `@<username>`. Entries under a heading that does not match the session are not loaded at all.

This is a **section heading**, unlike `brconfig.sys`, where `@` qualifies the rest of its own line. An `@` line that names nobody switches the entries below it off; it does not leave the previous heading open.

<a id="work-trees"></a>
### `WORK` trees

```
Q:\data
WORK Q:\data\test
!Q:\data\test\keys
```

A `WORK` line names a tree, typically a site's test data, where a session may change files it did not create:

- **In a restricted session,** a file under a `WORK` tree may be rewritten, emptied, renamed or deleted, and a directory under it removed, as if the session had created it. Elsewhere it may change only files it created ([4153](../../90-reference/error-codes/4153.md)).
- **In a session that is not restricted,** a `WORK` tree adds nothing to what the session may do, because it may already change anything the list permits. In an AI turn, the assistant's permission question is not asked about a change under a `WORK` tree.
- **It frees changing, not reaching.** Where the list names any area, a `WORK` tree must be inside one, and a `WORK` tree outside every area frees nothing. A list of `WORK` lines and nothing else names no area, so it does not limit where a session may be.
- **An exclusion still wins** inside a `WORK` tree.
- **The tree, not its root.** If a `WORK` entry names a directory, the directory itself may not be removed or renamed; what is under it is free. A `WORK` entry naming a file frees that file.
- `WORK` is not case-sensitive and takes the same entry forms as any other line. `WORK !…` is ignored and logged; write an exclusion on a line of its own.

**Name test data only.** A `WORK` tree lets an assistant overwrite what is in it without anybody being asked.

## What it governs

| Operation | Outside the list |
|---|---|
| `OPEN` for input | 4165 |
| `OPEN` for output or update, `INDEX`, `SORT`, `COPY`, `SAVE`, `REPLACE` onto a file | 4165 |
| `FREE`, `DROP`, `CLOSE ,FREE`, `RENAME`, `PROTECT`, a new timestamp | 4165 |
| `MKDIR`, `RMDIR` | 4165 |
| `DIR`, and every other directory listing | 4165 |
| `EXISTS` | reports nothing |

The check is made on the file operation itself, so it holds however the operation was reached: a statement, a command, `EXECUTE`, a `PROC`, a library call. In an AI turn the list is checked before the assistant's permission question, so a file it refuses is refused rather than asked about.

A listing of a permitted folder still shows the names of excluded things inside it. The exclusion stops them being opened or listed, not named.

**Everything BR works with has to be listed:** the program and procedure directories, the data, and BR's own work, spool and print directories (`WORKPATH`, `SPOOLPATH`, `PRINTDIR`). They are not exempt, because those are settings any session may change. The work files can be named narrowly: `:C:\ADS\w*.wrk` permits the work files in `C:\ADS` and nothing else there.

**It governs BR's file operations, not the operating system.** What an operating-system command does (`SYSTEM` with a command, a spool command) is outside the list. A restricted session cannot run one.

## Checking a list

Every entry and every refusal is written to BR's log as a security event, naming the resolved path. A list that was found and understood logs one line stating it:

```
File list in force from <path>: N entries from M lines, X of them exclusions.  Reading,
creating, changing, renaming, deleting and listing are all refused with error 4165 outside it,
...
```

followed by a line per entry (*Session may use …*, *Session may not use …*) and, for each refusal, *Session refused to read …* with the path and the reason. In a restricted session these lines say *Restricted session …*.

If the log has no *File list in force* line, the list was not found or not read: check the file name and that it is beside the executable the session is running. A restricted session with no list logs *No file list at &lt;path&gt;*.

## See also

- [4165](../../90-reference/error-codes/4165.md) — the error a refused file gives
- [SPAWN_RESTRICTED](../../10-language/data-manipulation/system-functions/SPAWN_RESTRICTED.md) — starting a restricted session
- [spec.md](spec.md) — `brconfig.sys`, read before the list
