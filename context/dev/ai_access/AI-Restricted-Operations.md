# Authorized Operations in a Restricted Session

The reference list: what a restricted BR session may and may not do. `AI-Access-Summary.md`
explains what a restricted session is and why it exists; this page is the detail.

A restricted session is in effect a **reporting session with a workspace of its own**. It may
create files and do anything it likes with the files it created — rewrite, empty, rename, or delete
them. **It may not change a file it did not create**, and it may not reach outside of BR. 

In addition to supporting restricted sessions, BR supports general application restriction such 
that a list of folders and files can specify where any and all BR activity - reading, creating, 
changing, renaming, deleting and listing - can operate. (The list can exclude sub-folders 
or files.)  Anything else is refused with error 4165. 

Session restriction is on top of that. 

## AI User Mode
In a normal AI + app setting the user can 
instruct AI to do anything and the AI service acting on behalf of the user can, at the users request, 
inadvertently destroy critical application data with the user's authority. Not so with Business Rules. 
When AI attaches to BR, BR goes into **AI user mode**. From that point on without additional permission, 
AI cannot type at the console, or issue commands. It can, however, print on the console. It just cannot 
press enter, etc.

Confining what it may *write* as well makes the list one boundary instead of two overlapping ones.
It is **not** a seal against a model that has the keyboard: a model holding a grant on an
*unrestricted* session reaches whatever that session can, and no rule inside a restricted session
bears on that — confining it is the job of a BR-owned agent, `br/mcpdriver/`. What the list bounds
is the approved program: the report a model wrote and a person glanced at, running against a
site's whole disk.

**Every rule here is enforced by a check at the core operation within BR.** How the
operation was reached makes no difference — `EXECUTE` of a string built at run time, a `PROC` 
file, a `SUBPROC`, a `CHAIN`, a `LIBRARY` call into existing code, all land on the same checks. 
The restriction lasts for the life of the BR session; nothing can clear it but the session ending.

**Errors.** Anything refused under the change rule — an open for `OUTPUT` or `OUTIN`, a `DELETE`, 
a `RENAME`, a `COPY` over a file, a file `DROP` or `FREE`, an attribute change, a `REPLACE` — 
gives **error 4153**, *restricted session: may
not change a file this session did not create*. Anything the file list does not
permit gives **error 4165**, *restricted session: brrestrict.sys does not permit this file* — which
also answers a create, a rename, a delete, a `MKDIR` and a listing outside the list. Every other
violation gives **error 4154**, 
*restricted session: this operation is not permitted*. Every refusal is written to the log as 
a security event, naming the file and the reason, or the command or operation.

## Contents

- [How a session becomes restricted](#how-a-session-becomes-restricted)
- [Files: the rule](#files-the-rule)
- [Files: where the session may be](#files-what-may-be-read)
- [Program statements](#program-statements)
- [Commands](#commands)
- [Configuration statements](#configuration-statements)
- [Known gaps](#known-gaps)
- [Summary: what each state restricts](#summary-what-each-state-restricts)

<a id="how-a-session-becomes-restricted"></a>
## How a session becomes restricted

A session is restricted **before it reads its own configuration file**, and nothing can restrict one
afterwards. That ordering is the whole of it: configuration is filtered only once a session is
restricted, so a session latched any later would already have had every configuration operation
applied unfiltered. There is no command, statement or switch that restricts a running session.

Two things start a restricted session:

- **The AI-user-mode flag.** While an assistant is connected to this Windows account, BR holds open
  `%LOCALAPPDATA%\ADS\harness.usermode`. **Any** BR session that starts while it is held runs
  restricted, however it was started — a desktop shortcut, a `SYSTEM` command, a second copy, or a
  session the assistant started itself.
- **`--restricted` on the command line**, used by `SPAWN_RESTRICTED` and by a brlistener label whose
  `ACTION` names it.

### The AI-user-mode flag

The flag is an ordinary file, created and **held open with `FILE_SHARE_DELETE` withheld**. Everything
it does follows from that one decision:

| | |
|---|---|
| **Raised** | when a valid `HELLO` is accepted — when an assistant is actually there, not merely when a channel is open |
| **Lowered** | when the program closes the channel, `MSG("harness", 0)` |
| **Tested** | by *trying to delete it*: refused means a holder is alive, success means it was stale and is now gone |
| **Removable** | by nothing at all while an assistant is connected — not a program, not the user, not an agent holding the keyboard |

**Deletion is what enforces it.** On Windows a file's deletability is governed by the share mode on
an open handle, not by byte-range locks, so withholding `FILE_SHARE_DELETE` makes the operating
system itself refuse to unlink the file. The refusal is therefore not a rule BR is asked to honour,
and nothing that declines to consult it can get past it.

**The test is the action.** BR does not ask whether the flag is held and then act on the answer; it
attempts the delete, and the outcome *is* the answer. Nothing can change in between. Any failure
other than "not found" is treated as a live holder, because the absence of the flag is what permits
an unrestricted session and an unexplained error is not evidence of absence.

**A crash leaves a flag that the next BR start removes.** No process id and no timestamp are
recorded, and there is nothing to reason about: the open handle *is* the liveness, and the operating
system closes it however the process ends. So a stale flag cannot restrict an innocent session, and
a live one cannot be cleared — the two failure modes point in opposite directions and each is
handled by the same mechanism.

**Several sessions may hold it at once.** Every holder's handle blocks the unlink, so the file goes
when the last one lets go. Each one closes its handle and then attempts the delete; the operating
system decides which was last, and no count is kept.

**To clear it by hand, delete the file.** That is refused with a sharing violation while any
assistant is connected, and succeeds once none is. No separate tool is needed.

**In client/server the flag is on the client's machine, and the answer is carried.** The assistant
connects to a channel in the *client*, so the flag is raised in the client's own per-user
directory; the sessions that have to be restricted are the *server's*. Those are the same file in
local mode and in client/server on one machine, and two different machines' files over a link — so
the server cannot look the flag up for itself and the client reports it instead, in the
`fieldsconfig` it is asked for before the latch is taken. The server restricts the session if
either answer says an assistant is connected, and its log names which route it came by.

A **client older than this change** cannot report it. The record is read short and the field comes
back 0, which is logged as a release mismatch — so the carried route is simply unavailable and
behaviour falls back to what it was: correct on one machine, absent across two. It fails open
rather than closed, which is worth knowing when mixing releases.

**Its configuration file is not trusted, and its log is not taken from it.** The flag latches
whatever starts next, and that may be something the assistant started: from the user's own
unrestricted session, an assistant holding a keyboard grant needs no permission at all to write a
configuration file and start BR with it. (A *restricted* session is refused `SYSTEM` with an
operating system command — see below — but the attack never needed one.) So `LOGGING` stays refused
from the file, and
a flag-restricted session's audit trail goes **where BR puts it** — beside the flag, in the account's
local application directory, named for the process. The restriction would otherwise still hold while
the record of it went to `nul`.

`WBSERVER` *is* permitted from the file, and that is a judgement rather than an oversight.
`wbserver.dat` is how sessions see one another's record locks, and **BR does not let a mismatch pass
quietly**: two sessions on different `wbserver` files raise **error 4175**, *different wbserver files
detected*, as soon as one touches a file the other has in use — from the sharing layer, at the point
of access.

So the reason to permit it is that a session forced onto the default file simply *could not work*: it
would fail 4175 against the site's own open files. It is not that it would corrupt anything, which it
would not. The same error bounds what an attacker gains by naming the file — a restricted session
pointed at its own `wbserver.dat` is not a quiet lock-free playground, but one that fails the moment
it reaches for anything a live session holds. What is left to gain is a latch recorded where nothing
reads it and a session that goes uncounted, with the file rule still refusing every write to a file
the session did not create.

A session started by `SPAWN_RESTRICTED` is refused both, and handed them on its command line. The
`CONFIG` command is refused at run time in every case.

<a id="files-the-rule"></a>
## Files: the rule

> A restricted session may change only a file it created itself.

**What counts as creating.** Anything that brings a file into being under a name nothing was using:
an `OPEN` for output of a free name, whatever its disposition — `NEW`, `USE` or `REPLACE`; the index
`INDEX` builds; the output `SORT` writes; the copy `COPY` makes; the new name `RENAME` gives; the
program `SAVE` writes; the directory `MKDIR` makes. An open of a free name is always performed as
`NEW`.

**What counts as changing.** Anything that writes to, empties, renames, deletes or changes the
attributes of a file: an `OPEN` for output of an existing file, `INDEX` or `SORT` or `COPY` onto one,
`RENAME` from or onto one, `FREE`, `DROP`, `CLOSE ,FREE`, `CLOSE ,DROP`, `PROTECT`, `RMDIR`, and
`REPLACE` of a program.

**How BR knows.** The session keeps a list, in memory, of what it has created: each file's full path
and its identity — volume serial and file index on Windows, device and inode on Unix. A change is
allowed only when both match. A file the session created that someone else then deleted and
replaced with a different one, under the same name, is not the session's file. The list follows a
file through `RENAME`, and a `REPLACE` that makes a new file under the old name.

**The list belongs to the session.** It is never shared with another session, restricted or not,
and it ends when the session ends. The next disposable session cannot change what this one left;
cleaning up is the business of ordinary unrestricted sessions. The list does outlive the program that
made an entry — a later program in the same session, after `CHAIN` or a new `RUN`, may change it.

**A new program may not shadow an existing one.** Saving a file created with a program suffix — 
`.br`, `.bro`, `.brs`, `.wb`, `.wbo`, `.wbs` — is refused if a program of the same base name exists 
under any of those suffixes and the session did not create it. Otherwise `SAVE menu.bro` beside an
application's `menu.br` would change what `CHAIN "menu"` loads under `CHAINDFLT O`, without
modifying any existing file.

**Files on the client follow the same rule, enforced by the client.** The server tells the client the
session is restricted, in the session configuration it already sends it, and the client then applies
the same code to its own files: the files a program names for the client, `MSG("dump", …)` and
`MSG("shot", …)`, and a print job written to a named file such as a `PDF:` output. The client keeps
its own list of what the session created on the client side; like the server's, it is never shared
and restriction sends with the session. Nothing can switch restricted mode off once it is on.

**Where it is enforced.** At the point every file passes through, one step before the operating-system 
open call. That is what makes it hold for every route to a file: an
`OPEN`, `INDEX` and `SORT`, `COPY`, `SAVE` and `REPLACE`, and BR's own writers such as
`DEBUG LOG`, `DEBUG SCREENLOG` and `DEBUG PROFILE`. 

<a id="files-what-may-be-read"></a>
## Files: where the session may be

> A restricted session may reach what the site's file list permits, less what that list excludes.
> It governs reading, creating, changing, renaming, deleting and listing alike, and an exclusion
> is absolute — the session's own files are no exception to it. With no list installed, nothing
> is restricted by it.

**Where the list lives.** `brrestrict.sys`, in the directory of the BR executable the session is
running. It is deliberately not a configuration statement and not a command-line argument: a
session restricted by the [AI-user-mode flag](#how-a-session-becomes-restricted) reads a
configuration file that may have been written by an assistant holding a keyboard grant in the
user's own unrestricted session, which is the same reasoning that keeps `LOGGING` out of such a
file. A session cannot choose which executable it is running, so it cannot choose its list.

**And it is not read through the gate it installs.** The list is opened with the operating
system's own `fopen`, not through BR's file layer, because that layer is where this rule lives:
read the other way, a list could exclude itself, or an entry could decide whether the next entry
was legible. It is the one file in a restricted session that BR reads outside its own rules, and
it is read once, before the session can run anything.

**Each side reads its own, and a client is unrestricted until one is installed there.** The server's
list governs the server's files; the client's own list, beside the client's own executable, governs
the files on the client machine — those a program names for the client, `MSG("dump", …)`,
`MSG("shot", …)` and a print job written to a named file. Restricting a server does not restrict a
client. **All folders on a client machine are unrestricted unless a client list is installed
there.**

### What it looks like

```
# what a disposable reporting session may reach
Q:\data                            a directory: it and everything under it
Q:\rates.dat                       one file
Q:\data\*.rpt                      the .rpt files in data
Q:\data\**\*.rpt                   and in every directory under it
!Q:\data\payroll                   an exception inside a permitted tree
:C:\ADS\shared                     a native path, marked by the leading colon
```

One entry a line. A blank line is ignored, and **`#` is the comment character**.

### Whose entries they are: the `@` line

A line of its own beginning `@` qualifies every entry that **follows** it, until the next one:

```
Q:\common                          everybody: no heading yet, so @all applies
@payroll                           only when the session's login name is payroll
Q:\wages
!Q:\wages\archive
@all                               and back to everybody
Q:\reports
```

`@all` is the default. 
`@<username>` matches the session's login name **without regard to case**, as `brconfig.sys`
matches its own `@<username>` conditional and as this list matches filenames on every platform.

**Entries under a heading that does not match are not loaded at all.** They are not loaded and
then refused; they are never in the list, so nothing about them can be overridden later.

**This is a section, not a prefix** — a deliberate difference from `brconfig.sys`, where
`@WINDOWS` and `@<username>` qualify the rest of *their own line*. A file list is a run of entries
per user, so the name is written once above them rather than on each.

**A malformed `@` line switches the entries below it off** rather than leaving the previous
heading in force. The two ways to be wrong are not equal: an entry that is malformed, or that
sits under a heading that is, fails loudly — error 4165 the first time the session opens a file
it would have covered, and a line in the log when the list is read. A heading that quietly
stayed open produces no error at all, ever: it hands one user's permissions to everybody and
says nothing.

The log names the user it compared against on every heading, so a list that matched nothing
because BR knows the session by another name reads as that rather than as a broken feature. A
user actually called `all` cannot be named this way.

**Entries are BR names, resolved through the session's `DRIVE` statements — unless they begin with
a colon**, which is BR's own mark for a native path everywhere else and is the mark here too. A
site writes the list in the names its programs use. On the client they are native names whether
or not a colon is there, because client file names are not subject to `DRIVE` statements.

**The drive mapping is frozen when the list is read**, which is after the configuration file. A
mapping added later cannot move an entry — which matters, because `DRIVE` is a configuration
statement a restricted session is permitted to use. Both sides of every comparison are resolved
to a real path in any case, so a mapping could not disguise a file even if it could reach one.

**None of BR's other filename conventions apply.** In particular, **not** the
`<filename>/<parent-path>` form BR still accepts in an open string, inherited from Datamaster and
kept only for legacy support. A list entry never passes through BR's name translation in that
sense: a forward slash in an entry is an ordinary path separator and nothing else.

**`!` excludes, and is not a comment** — although `!` *is* BR's comment character in
`brconfig.sys` and in program source. The two ways of getting that wrong are not symmetrical.
Read `!` as a comment, and somebody writing `!Q:\payroll` for the negation they know from
`.gitignore` is silently left with payroll **permitted**. Read it as an exclusion, and somebody
writing `! the report data` out of BR habit gets an exclusion of a path that is not there, which
excludes nothing, appears in the log and costs nothing. Only one of those fails safe.

**An exclusion wins over every permit, whatever the order of the lines.** Last-match-wins is what
`.gitignore` does, and it depends on the order; a confidentiality list is better off unable to
re-permit something by accident. To make an exception inside an exclusion, narrow the permit
rather than adding one.

**`*` and `?` stay within one name; `**` crosses.** This is glob as POSIX defines it in XCU §2.13
and as `fnmatch` implements it under `FNM_PATHNAME`, so `data\*.rpt` is the files in `data` and not
those in `data\archive`. `**` is not POSIX — it comes from zsh and is spelled out by `.gitignore`
and by Java's `PathMatcher` — and it crosses separators; `\**\` also stands for no directory at
all, so `data\**\*.rpt` covers `data\x.rpt` as well as `data\2026\q1\x.rpt`. There are no bracket
expressions: `[` is a literal. There is no backslash escape, because backslash is the separator.
And `*` matches a leading dot, where POSIX would not — the POSIX rule would let `data\*` silently
fail to exclude `data\.hidden`, and a hole in an exclusion is the direction that matters.

**Whatever an entry names, exactly or by pattern, it takes the tree under it if it is a
directory.** One rule for both kinds, so `Q:\*\data` means each application's data directory
*and its contents*, as naming one directly would.

**It does not take what is above what it matches.** `Q:\data\**\*.rpt` permits the `.rpt`
files at any depth under `Q:\data` and nothing else — not `Q:\data`, and not
`Q:\data\2026`. So a session can open `Q:\data\2026\q1.rpt` while a `DIR` of the
directory holding it is refused with 4165. That is the intended reading: a pattern names the
files a session may have, and being able to open one is not a reason to be able to enumerate
its neighbours. A site that wants those directories listable names them on lines of their own,
which is a decision rather than a side effect.

**Names are compared without regard to case, on every platform including Linux and macOS.** A site
policy must not change meaning when the application it guards moves from the Windows machine it
was written on to the Linux server it runs on. The cost, stated plainly: on a case-sensitive file
system a permit can reach a directory the administrator did not name — `/data/rpt` also admitting
a separate `/data/RPT` — while an exclusion gains in the safe direction by the same rule, catching
casings nobody enumerated.

### What it governs

**The gate is the file operation, never the statement that asked for it** — the same choice made
for the assistant's permission questions, at the same points in the code. A list of forbidden
*commands* is the thing a single line walks around: a program can open a master file for output
and write over it without ever naming `FREE` or `COPY`. Gating what every route funnels through
means a statement added to the language in a later release is covered the day it is written, and
that "may this session touch that file?" has exactly one place that answers it.

Everything a session does with a named file, not reading alone:

| Operation | Refused outside the list with |
|---|---|
| `OPEN` for input | 4165 |
| `OPEN` for output or update, `INDEX`, `SORT`, `COPY`, `SAVE`, `REPLACE` onto a file | 4165 before the change rule's 4153 |
| `FREE`, `DROP`, `CLOSE ,FREE`, `RENAME`, `PROTECT`, a new timestamp | 4165 |
| `MKDIR`, `RMDIR` | 4165 |
| `DIR`, and every other directory listing | 4165 |
| `EXISTS` | reports nothing — see below |

So a restricted session cannot see out of the folders the list names, and cannot put anything into
a folder it cannot see. **4153 and 4165 answer different questions**: 4165 is *the site does not
let this session near that file*, and 4153 is *this session did not create that file*. The list is
the outer boundary, so it is tested first.

**BR's own working files are inside the rule, not exempt from it.** A site that installs a list has
to name the work, spool and print directories in it as it names its data. Exempting them could not
be made safe, because `WORKPATH`, `SPOOLPATH` and `PRINTDIR` are configuration statements a
restricted session is permitted to set, so an exemption would be a hole the session could aim. The
work files can be named narrowly rather than by opening their directory — `:C:\ADS\w*.wrk` permits
the work files in `C:\ADS` and nothing else there.

**`EXISTS` reports nothing about a file outside the list**, and that is a change from the first
version of this rule, which governed reading alone and let existence through. A session that may
not reach a folder may not learn what is in it either. A listing of a *permitted* folder still
shows the names of excluded things inside it; the exclusion stops them being opened or listed, not
named.

### The rest of the rule

**No list means no restriction.** Without the file, nothing is restricted by it, and the session's
log says so once. That is the behaviour a restricted session always had. It is also what makes the
list unforgeable: a restricted session *may create files*, so a list it did not find is a list it
could write — and there is nothing to gain by writing one, because the widest setting is the one
such a session already has. A list that **is** installed fails closed: if every line in it is
unusable it permits nothing.

**An entry for something that is not there yet applies straight away, by name.** The list is read
once, at startup. An entry naming a path that cannot be resolved then is **not** dormant: its
existing ancestors are resolved and the rest of the path is matched by name, which is exactly
what BR already does with the name being opened, so both sides of the comparison are formed the
same way. Nothing is given away by matching the tail by name — a path component that does not
exist cannot be a junction. Once the path does exist the entry is resolved exactly and cached.

**So an exclusion is in force from the moment the list is read, including against the create that
would bring its path into being.** `!Q:\data\export` stops that directory being made, whether or
not it is there at startup. That is the one moment an exclusion most needs to hold: an entry that
waited for its path to appear could not refuse the operation that made it appear, so a session
could create the very directory the site had excluded and then work inside it. A site excluding a
nightly export directory, an unmounted volume, or anything created while the session runs gets
the exclusion it wrote.

**The list has no ownership escape, and does not need one.** Creating goes through this same
gate, so a file the session created was, at the moment it was created, somewhere the list
permitted — reading it back therefore passes on the list alone. The list answers **where**; whether
a file is the session's own is the separate question the change rule asks, and that is where
ownership is tested. **An exclusion is absolute.**

**The comparison is on the resolved path, never on the name BR was given.** A junction, a symbolic
link, `..`, a relative path and an 8.3 short name each reach a file under a name a simple prefix
test would not recognise, and the short name needs no privilege at all. Every name is resolved to
the file it actually reaches before it is compared, and every entry in the list is resolved the
same way as it is read, so both sides are in one form. A name being *created* has nothing behind
it, so the deepest ancestor that does exist is resolved and the rest put back on — otherwise a new
file in a junctioned directory would be compared under one name and read back under another. The
consequence worth knowing: **a junction inside a permitted directory does not widen the list.** A
name that is under a permitted directory all the way along is still refused if the file it reaches
is not. The same resolution is why a permitted directory may be named by any of its paths.

**Every entry, and every refusal, is logged** as a security event, naming the resolved path. An
administrator can read back from the log exactly what the list was understood to mean.

**So the log is where a new list is checked**, and there are two lines to look for. The first
states the whole rule in one place, and its counts are the quickest confirmation that the file
was found and understood:

```
Restricted-session file list in force from <path>: N entries from M lines, X of them
exclusions.  Reading, creating, changing, renaming, deleting and listing are all refused
with error 4165 outside it, an exclusion overrides every permit, and this session's own
files stay its own whatever the list says.
```

The second is the one to be sure you do **not** see after installing a list:

```
No restricted-session file list at <path>: this session may read and create whatever the
account can.
```

That is what a misspelled filename, or a list left beside the wrong executable, looks like —
and because no list means no restriction, it is a mistake that produces no error anywhere else.
A site that installs a server list should check for this line on the client too, where one is
needed as soon as anything is written, dumped, shot or printed to a file on the client machine.

**When it comes into force.** After the session has read its configuration file, which is the
opposite of the latch — the latch must be in force *before* it, because the latch is what filters
the statements in it.

**The window that leaves open is one file and its `INCLUDE`s: the configuration.** Everything
after it is governed, including the startup command, the procedure it names, the program that
procedure loads and every `OPEN` from then on. The configuration is exempt because it was named
by whoever started the session — a parent session at `SPAWN_RESTRICTED`, or whoever launched BR —
and all of them are outside the restriction and could read those files anyway, so nothing reaches
the session that its chooser did not already have. Gating it would also fail *quietly*:
configuration reports a statement it cannot use and carries on, so a refused `INCLUDE` of
`printer.sys` would drop the printers rather than stop the session.

<a id="program-statements"></a>
## Program statements

**Program statements are not filtered individually.** There is no permitted list of statements,
because everything a program can do to a file meets the file open check.

| Statement | In a restricted session |
|---|---|
| `OPEN ... INPUT` | works, on any file, unchanged |
| `OPEN ... OUTPUT/OUTIN` of a name not in use | works, whatever the disposition — the file is the session's own |
| `OPEN ... OUTPUT/OUTIN` of a file the session created | works |
| `OPEN ... OUTPUT/OUTIN` of any other existing file | **refused, 4153** |
| `READ`, `INPUT`, `LINPUT`, `RESTORE` | work |
| `WRITE`, `REWRITE`, `PRINT #`, `DELETE #` | work — on a channel the session opened, which can only be a file it may change |
| `CLOSE`, `CLOSE ,FREE`, `CLOSE ,DROP` | work on the session's own files |
| `INDEX`, `SORT` (as statements or commands) | work; their output follows the file rule |
| `PRINT`, `PRINT FIELDS`, screen and window statements | unaffected |
| `CHAIN`, `LIBRARY`, `EXECUTE`, `PROC`, `SUBPROC` | work, and carry the restriction with them |
| `MSG(...)` | the actions that read or arrange windows work; those that put input where another program can get it are **refused, 4154** — see [`MSG` actions](#msg-actions) |
| `DLL(...)` | **refused, 4154** |
| `SPAWN_RESTRICTED(...)` | **refused, 4154** — a restricted session cannot start others |

<a id="msg-actions"></a>
### `MSG` actions

A permit list, like the command filter, so an action added to BR later is refused in a restricted
session until someone classifies it. The line is drawn between reading and acting: asking the state
of the session or of BR's own pointer is permitted, writing a file follows the file rule, and moving
the pointer or pressing a button is refused.

| Actions | In a restricted session |
|---|---|
| `state`, `getpos`, `getwpos`, `getcpos`, `getcb` | work — they only read |
| `putcb` | works — it sets the clipboard, which reaches another program only if a person pastes it |
| `restore` | works — it acts on BR's own window |
| `loop`, `sleeptime` | work |
| `harness`, `grant` | work — the assistant's keys go into BR's own keyboard buffer, not the device layer |
| `dump`, `shot` | work, under the file rule, enforced by the client: a new file or one the session made, never another |
| `send` | works, and types into this session only — in every session — see below |
| `setpos`, `setwpos`, `setcpos`, `lclick`, `mclick`, `rclick` | **refused, 4154** — they act rather than read, and the permit list is not widened on the grounds that a press can no longer leave BR's own window |
| anything else | **refused, 4154** until classified |

**`send`.** In every session, restricted or not, the client puts its keys into BR's own
key buffer, as the harness does for the assistant, so they reach this session and nothing else.
It does not need BR to be the window in front. (`MSG("kb")`, which was `send` plus a check that
BR's window was on top, was removed in 5.0 — once `send` could not leave BR there was nothing for
it to guard. A call to it gets 412 *invalid MSG action*.) Named keys (`|RET|`, `|TAB|`, `|F5|`, the arrows and
so on) become BR's own key values; `|SHIFT+|` shifts ordinary characters on the keyboard layout and
gives the shifted named keys, and `|CTRL+|` gives Ctrl+letter; keys with no meaning inside BR — Alt,
the Windows and Apps keys, PrintScreen — are dropped. The keys are queued: `MSG` returns at once and
the client feeds them in one at a time, `sleeptime` apart, as the program reads them.

### Printing

A restricted session prints to printers installed on the computer — which may themselves be shared
printers — and to preview. **It may not print to a UNC name** (error 4154): a UNC name that is not
an installed printer is opened as a file and the job written into it, and a printer share cannot be
distinguished from a file share by name. This prevents using printing to overwrite existing data. 
`br/aiaccess/p36_holes.brs` shows the route writing a scratch file
through `\\localhost\c$\…` from an unrestricted session, and the refusal from a restricted one. A
job that writes a named file, such as `PDF:` output to a file, follows the file rule on the client.

### BR libraries are not restricted from use

A `LIBRARY` call runs BR source under the interpreter, so every `OPEN`, command and configuration
statement inside it meets the same checks. This is also why the restriction is a property of the
**session** rather than of a program: a program that could hand control to un-gated code — by
chaining, by calling an existing library, by starting another program — would launder its
restrictions through it. Marking the session removes that whole class at once.

<a id="commands"></a>
## Commands

Commands are filtered internally, by a permitted list. Any commands not on the 
list are refused. 

### Permitted

| | |
|---|---|
| Reading and reporting | `LIST` `DISPLAY` `STATUS` `TYPE` `DIR` `VERIFY` `DATE` `TIME` `HELP` `ALERT` |
| Running a program | `LOAD` `RUN` `GO` `SKIP` `CLEAR` `MERGE` `RENUM` `AUTO` `LINK` `PROC` `SUBPROC` `PROCERR` `BREAK` |
| Files and programs | `INDEX` `SORT` `COPY` `RENAME` `FREE` `DROP` `PROTECT` `SAVE` `REPLACE` — each decided per file by the file rule |
| Directories | `CHDIR` `MKDIR` `RMDIR` |
| Program lines | `DEL` — it deletes lines of the program in memory, not files |
| Other | `DEBUG` `CONFIG` `SYSTEM` (see below) |

**The file commands are permitted as commands and decided per file.** `FREE` of a file the session
created works; `FREE` of anything else is refused with 4153. The same holds for each of them. A
command filter can only say yes or no to a whole command, which is why these were once refused
outright; the file rule says yes or no to the file.

**`SAVE` and `REPLACE`.** `SAVE` of a new program works, unless it would shadow an existing program
(see the file rule). `REPLACE` works only on a program the session saved. A refused `REPLACE` is
refused before it makes its `.bak` copy, so it leaves nothing behind.

### Refused

| Command | Why |
|---|---|
| `EDIT` | launches the configured editor — an operating system program |
| anything not listed as permitted | refused by default, pending classification |

### `SYSTEM` is two commands

`SYSTEM` with a string argument runs an **operating system command**, and is restricted. 
`SYSTEM` on its own, `SYSTEM <n>` and `SYSTEM LOGOFF` merely exit.

| | |
|---|---|
| `SYSTEM`, `SYSTEM <n>`, `SYSTEM LOGOFF` | work — a session can end itself, and ending it is what clears the restriction |
| `SYSTEM "<command>"` | **refused, 4154** |

### `CONFIG` is permitted, its operations are filtered

`CONFIG` itself is allowed. Refusing it would guard nothing, because a supplementary session is
started with a configuration file of the caller's choosing — anything refused at run time would
simply be written into that file instead. The operations are filtered instead, and in both places.

<a id="configuration-statements"></a>
## Configuration statements

Filtered by a permitted list, checked at the single point **both** routes pass through: the
configuration file read at startup, and the `CONFIG` command at run time. It makes no difference
which way a setting arrives.

From a `CONFIG` command a refusal returns 4154. From a configuration file it reports the line and
carries on with the rest of the file, which is BR's existing handling for a statement it will not
accept.

### Permitted

| | |
|---|---|
| Appearance and terminal | `3D_FIELDS` `ATTRIBUTE` `COLOR` `CONSOLE` `CURSOR` `DATAHILITE` `FONT` `FONTFAMILY` `GRAPHIC_LINEDRAW` `GRID_CURSOR_MOVE` `GUI` `MIN_FONTSIZE` `PICTURE` `SCREEN` `STATUSLINE` `STYLE` `WINDOWS_THEMES` |
| Language and behaviour | `APPLICATION_NAME` `BASEYEAR` `BREAK` `BTREE_VERIFY` `CHAINDFLT` `COLLATE` `DATE` `DECIMAL` `DIMONLY` `FIELDBREAK` `FIELDHELP` `FILENAMES` `FILTER_DELIMITERS` `FORCE` `HELPDFLT` `INSERT` `KEYBOARD` `LOAD-OVERLAYS` `OPTION` `PAGEOFLOW` `REM` `SEARCH_CHAR` `SUBSTITUTE` `TYPEAHEAD` `USERLEVEL` |
| Partly, from the configuration file only | `LOGGING` — the statement runs and **only its `UNATTENDED` keyword is kept**. The file name, the level, `DEBUG_LOG_LEVEL=` and `+CONSOLE` are dropped, because a contained session does not choose where the record of its containment goes; it writes `restricted-<wsid>.log` and the session logs that it did. As a `CONFIG` command at run time, `LOGGING` is refused outright (4154). |
| Sizes and limits | `FLOWSTACK` `FORSTACK` `MAXRECALL` `MAX_SORT_MEMORY` `MEMORY` `RPNSTACK` `WORKSTACK` |
| Files and printing | `DRIVE` `PRINTDIR` `PRINTER` `PRINTSCREEN` `SPOOLPATH` `SPOOLCMD` `WORKPATH` `CLIENT_CURRENT_DIR` `RD` |
| Startup | `EXECUTE` `INCLUDE` |

`EXECUTE` is permitted because the command it names is filtered like any other when it runs — it
is the ordinary way to say what a supplementary session should do. `DRIVE` is permitted because it
confers nothing: both file rules are applied after the mapping and to the file the name really
reaches, so no mapping can make an existing file look like one the session created, or a file the
read list refuses look like one it permits — and a reporting session that cannot declare its drives
cannot find its data. `USERLEVEL` is the field
help level, not a privilege. `INCLUDE` is permitted because the file it pulls in comes back through
this same filter. `SPOOLCMD` is permitted because setting it does nothing: the command it names is
what would reach outside BR, and that is refused when a print job would run it (see below).

### Refused

| Statement | Why |
|---|---|
| `SHELL` | configures where and how a shell runs |
| `EDITOR` | names the program `EDIT` launches |
| `PDF_READER` | names a program to launch |
| `LOGGING` | is the audit trail; a restricted session may not move or silence the record of what it did. Refused in every case — a session restricted by the AI-user-mode flag is given a log **BR chooses**, because its configuration file may be the assistant's: see [How a session becomes restricted](#how-a-session-becomes-restricted) |
| `DATABASE` | opens an SQL connection — a write path the file rules do not reach |
| `HTTP`, `HTTPS` | start network listeners |
| `SETENV` | sets environment variables that child processes inherit |
| `WBSERVER`, `BRSERVER` | name of the file that flags the restriction. **Permitted from the configuration file** for a session restricted by the AI-user-mode flag, because a session forced onto the default file would fail error 4175 against the site's own open files — see [How a session becomes restricted](#how-a-session-becomes-restricted) |
| `WSID`, `WSID=SESSION`, `WSID=UNIQUE`, `LOGIN_NAME` | change the identity the restriction is recorded against and the log attributes actions to |
| `OPTION 83` | lifts the shell question and the AI-user-mode flag together, so a contained session that could set it would spawn an uncontained one. Refused from the configuration file as well as from a command, and refused to **every** session as a `CONFIG` command with error 4172 |
| anything not listed as permitted | refused by default, pending classification |

**`DATABASE` is refused as a whole for now, and that has a real cost:** a restricted session cannot
report from a database at all. A narrower rule, permitting connections but not writes, wil be forthcoming.

## Two further routes, closed at the operation

Neither is a command or a configuration statement, and both are refused while a session is
restricted:

- **A spool command does not run.** `SPOOLCMD` can be defined, but if executed it will not run. 
  `SPOOLCMD` normally names an operating system command, and 
  BR runs it through the shell when a print job is spooled — any command at all. The setting is 
  permitted, because on its own it does nothing; **however running it is refused (error 4154)** 
  at the point a spooled print job would normally hand it to the shell. Printing to the 
  computer's installed printers and to preview, which does not spool through a command, is 
  unaffected.
- **Ctrl-\]**, which opens an operating system shell from the terminal, is refused. 

<a id="known-gaps"></a>
## Known gaps

- **`DATABASE`** as described above.

<a id="summary-what-each-state-restricts"></a>

## Summary: what each state restricts

Four things are independent and are often confused for one another: the **channel mode** a session
opened (user or DEVELOP), whether a **grant** is held, whether the **AI-user-mode flag** is up, and
whether a session is **restricted**. A session running the harness is not itself restricted in
either mode. These lists say what each state does and does not do.

### 1. A harness connected here, in user mode

**What it stops**

- The assistant cannot reach the command line. Granted keys are fed only where a **program** is
  waiting for input, never at the `READY` prompt, so no BR command - `SYSTEM`, `FREE`, `REPLACE`,
  `LOAD`, `RUN` - can be issued by the assistant at all.
- The assistant cannot raise or extend its own grant: a `MSG("grant", n)` on a line that came from
  the assistant is refused with **4166** unless `n` is 0.
- The assistant cannot start a turn, or end one without answering: the `AI` command on a line that
  came from the assistant is refused with **4171**, `AI NEW` included. A turn's authority is that a
  person typed `AI`; the state is single, so such a line replaced the person's turn with one of the
  assistant's own - and the `ASK` it sent would reach, in `chat` mode, the model that sent the line.
- The assistant cannot authorise its own next turn: `SETENV("AI_TURN_OK", …)` on a line that came
  from the assistant is refused with **4170**. The flag is how a running program or procedure
  consents to a turn happening over it, and a permission the restrained party can grant itself is
  not one. `CONFIG SETENV` cannot set it either - nothing is running when a configuration file is
  read, so the name has nothing to mean there.
- The AI-user-mode flag goes up on a valid `HELLO` and cannot be taken down by anything while the
  connection lasts - not a program, not the user, not an agent holding the keyboard.
- With `GUI OFF`, `HISTORY` is withheld and left out of `PING`'s request list.
- `COMMAND` is refused outside of a turn of the console conversation.
- **A turn cannot open over work in progress without its consent.** While a program or a
  procedure is active, the `AI` command itself is refused with **4169** unless
  `ENV$("AI_TURN_OK")` is `"Y"`, which only the thing that is running can set. It goes down two
  ways and neither is the `AI` command: the programmer clears it, or the turn ends. This is a rule
  about the session rather than about the assistant -
  it is the person's own `AI` line that is refused - and it exists because a turn's commands
  include the `LOAD` that would replace an interrupted program, which BR has never allowed
  `SAVE`, `REPLACE` or `RENUM` to do (2108).
- **This session does not reach the operating system unasked.** While a
  connection is greeted, `SYSTEM` with an operating-system command, a spool
  command, the editor `EDIT` launches and **Ctrl-]** all stop and **ask the
  operator**, inside `shell()`, naming the program that would run; a refusal
  is **4167**. The gated `CONFIG` operations below are refused outright with
  **4168** instead, having no program to name. The rule is about the session,
  not about who asked: **the person's own `SYSTEM` is asked about too**, and
  detaching the assistant restores all of them without a question.

**What it does not stop**

- **This session is not restricted.** It is the person's own session and reaches whatever it always
  could; the file rules in this document do not apply to it.
- The assistant may read everything the channel exposes - screen, history, controls, grids, lists,
  attributes, cursor, windows, a rendered shot - with no grant at all.
- Whatever the **application** offers through the fields it puts up. If a program will write a file
  whose name the operator supplies, or shell out from a menu, the assistant can drive that like any
  operator. No BR-level gate bears on it; that is an application review question.

### 2. A harness connected here, in DEVELOP mode

DEVELOP is chosen by the program when it opens the channel, is refused to a session that has
already opened one in user mode (**4164**), and is refused to a restricted session.

**What it changes, relative to user mode**

- Granted keys may also be fed at the `READY` prompt. Everything a programmer can type, the
  assistant can type.
- **The AI-user-mode flag is not raised**, so sessions started from here come up unrestricted. This
  is deliberate: a test session started from a development session has to be able to write its own
  application's files.

**What is the same**

- The operating-system bar. `SYSTEM`, spool commands, the gated `CONFIG`
  operations and Ctrl-] are refused in DEVELOP exactly as in user mode, for as
  long as a connection is greeted. The condition is that a harness is attached
  to this session; neither the channel mode nor the grant enters into it.

**What follows from those two together**

- A DEVELOP session is not restricted, so `SYSTEM` and an operating-system command are not refused
  to it, and nor is writing any file the account can write.
- Nothing anywhere consults whether a harness connection is live: every refusal in this document
  asks `isRestrictedSession()`. So with a grant, an assistant in DEVELOP mode can write a file and
  run it, and what it starts is unrestricted.
- Everything in list 1 under "what it stops" still holds except the command-line bar: the grant is
  still required, 4166 still applies, and reading still needs no grant.

### 3. A harness connected anywhere in the account

This is the AI-user-mode flag, and it is about **other** sessions.

- A BR session that **starts** while the flag is held comes up restricted for its whole life, with
  origin "the AI-user-mode flag was held at startup". The session is told so in the log.
- The flag is tested once, at startup, by **trying to delete it**. The latch never clears: a session
  restricted this way stays restricted even after the assistant disconnects.
- It is raised **only in user mode**, on a valid `HELLO`.
- Several sessions may hold it at once; it goes when the last one lets go.
- In client/server the flag is on the **client's** machine and the answer is carried to the server.
- It does not restrict the session that raised it.

### 4. What a grant grants, in each mode

**Without a grant** - the default, and the state a connection returns to when one ends:

- Everything readable is still readable. Reading never needs a grant.
- `KEYS` and `SCANCODE` are refused with **5**; `PACE` is refused with **3**.
- Keys already queued are discarded when a grant ends, and the pace returns to its default.

**With a grant, in user mode:** keys and scancodes are fed into a **waiting program** only, one at a
time, `PACE` milliseconds apart.

**With a grant, in DEVELOP mode:** the same, and also at the `READY` prompt.

**In either mode a grant does not:**

- let the assistant raise or extend it - only the person at the session may, with
  `MSG("grant", <seconds>)`; the assistant may only give it back, with `RELEASE` or
  `MSG("grant", 0)`;
- give any file access, shell or native code of its own: the console is the only thing it acts
  through;
- restrict the session, or raise the AI-user-mode flag. Those are separate
  states;
- buy back the operating system. `SYSTEM`, spool commands, the editor and
  Ctrl-] are asked about for as long as a harness is attached, and the gated
  `CONFIG` operations are refused outright, whether a grant is held or not.
  **A grant lends the keyboard, not the shell**, so it answers no question
  here: a refused shell call is 4167 and a refused `CONFIG` operation 4168;
- waive the question before a destructive operation. Permission mode applies
  within a turn whether a grant is held or not (list 6).

**One consequence worth stating plainly.** A grant buys **typing**, and nothing else on this list.
It used to buy more: with the keyboard lent, the console conversation's permission gate asked
nothing, on the reading that lending the keyboard is consent to whatever follows. It is not. A
person lends the keyboard so that the assistant can get on with the work, and a grant is given
once, for minutes, before anybody knows what the assistant will do with it - so it cannot stand as
consent to a particular operation. The gate keys off a line being marked as the assistant's, which
keys typed through `KEYS` and `SCANCODE` are not, so it still never applies to those.

### 5. What a restricted session restricts

The body of this document is the detail; this is the shape of it.

- **Files it may change:** only ones it created itself (**4153**), and only where the file list
  permits (**4165**). That covers an open for `OUTPUT` or `OUTIN`, `DELETE`, `RENAME`, `COPY` over a
  file, `DROP`, `FREE`, an attribute change and `REPLACE`.
- **Files it may read:** what `brrestrict.sys` permits, less what it excludes. Files the session
  created are not an exception — it created them somewhere the list already permitted.
- **No operating system:** `SYSTEM` with a command, Ctrl-], a shell from any route, and native code
  are refused (**4154**).
- **No new sessions:** `SPAWN_RESTRICTED` is refused to it - nothing in a child could be less
  restricted than its parent, and a program generated for a user has no business spending the
  workstation's sessions.
- **`MSG` is filtered to eighteen actions.** The pointer group and anything not on the list are
  refused.
- **Printing and spooling** that would reach an operating-system command are refused.
- **Configuration** is permitted as a statement and filtered by operation, including in the
  configuration file the session starts with - which is why the restriction is latched *before* that
  file is read.
- **It lasts the life of the session.** Nothing clears it; the session ending does.
- **How the operation was reached makes no difference** - `EXECUTE` of a string built at run time, a
  `PROC`, a `SUBPROC`, a `CHAIN`, a `LIBRARY` call into existing code all land on the same checks.

Every refusal is written to the log as a security event naming the file and the reason, or the
command or operation.

### 6. What permission mode restricts, and when it is active

Permission mode is the one protection that **asks** rather than refuses. It does not change what a
session may do; it puts a question to the person at the console before a destructive operation goes
ahead, and takes a refusal as error **4167**.

**It is active when both of these hold:**

- **the line running is the assistant's.** A latch is set when the console conversation hands a
  line to the command processor, and for a line read from a procedure from that block's
  `assistant` mark. Either way it covers the line the assistant submitted, the program that line
  runs, and anything either of them calls. It clears when the operator types the next line, or
  when their own procedure supplies it, because neither carries the mark.
- **and a harness is attached to this session** - `g_clientState &
  CLIENT_STATE_HARNESS_ATTACHED`, which the client reports and the server holds. In practice the
  first condition implies the second; it is tested because the rule is about the session.

**The grant is no longer one of them, and was.** `assistantNeedsPermission()` used to be
`assistantLineRunning() && s_turnGrant == AGENTCHAT_GRANT_NONE`, so a turn with the keyboard lent
asked nothing. See list 4 for why that reading does not hold. The grant state is still read as a
turn opens and still logged there, because "was the keyboard lent during this turn" belongs in the
record; it decides nothing here.

**It is therefore not active:**

- for keys sent with `KEYS` or `SCANCODE`. Those are not assistant-marked lines, so they never reach
  this gate in either channel mode, with or without a grant.
- for anything the person types themselves.
- when no harness is attached - which is also when no line can be the assistant's.

**What it asks about** - the same gates a restricted session refuses at:

| Operation | Where |
|---|---|
| opening a file for output | `file_os.cpp` |
| creating a file | `file_os.cpp` |
| deleting, renaming, dropping or freeing - each with its own verb in the question | `file_os.cpp`, `wbname.cpp`, `wbserver.cpp` |
| reaching the operating system - `SYSTEM` with a command, a spool command, the editor `EDIT` launches, the terminal's `Ctrl-]` escape | `brshell.cpp` - inside `shell()`, the one function all of them pass through. Asked for as long as a harness is **attached**, not only during turn+, and the person's own shell calls are asked about too |

**Two things it does not ask about.** A file the assistant created itself in this session is its own
and passes without a question - asking about an assistant's scratch files is noise, and noise is
what teaches a person to answer yes without reading. And an operation already settled, by an answer
that said "always", is not asked again.

**The question goes to the console, not to a dialog**, and deliberately: a message box does not
exist with `GUI OFF`, it would appear at the client while the operation is at the server, and it is
not where the person is looking - the turn they typed is printing on the console a line at a time.
The same `screen()` and key-wait path `READY` itself uses puts the question wherever the person is,
in either mode, local or over a link.

**Its practical reach.** Because it needs an assistant-marked line, permission mode covers the
console conversation - a person typing `AI <text>` and the assistant acting inside that turn -
and it covers it whether or not the keyboard has been lent. It is **not** a protection on the
harness channel's typing: keys are not lines and carry no mark, which is what the grant governs
instead. The operating-system routes it used to ask about are now refused before the question
arises; see list 7.

**And it now applies to every command the turn runs**, because the commands run one at a time as
the assistant asks for them rather than from a work file after the turn - so the question arrives
while the person is still watching the conversation that caused it, and the assistant is told the
refusal (4167) as that command's result.

### 7. What an attached harness restricts, in either mode

A rule about **the session**, not about provenance, and the only one here that
is not about a restricted session at all. For as long as a connection is
greeted - user mode or DEVELOP, grant or no grant, the assistant's line or the
person's own - this session does not reach the operating system.

| Refused | Where |
|---|---|
| `SYSTEM` with an operating-system command | `command7.cpp` |
| the spool command, where it would run | `spool.cpp` |
| `CONFIG` operations `isConfigOperationRestricted()` names, plus `SPOOLCMD` | `config.cpp` |
| **Ctrl-]**, the terminal's shell escape | `terminalcww.cpp`, `terminalcuw.cpp`, and in the harness queue so that `SCANCODE` can say why |

**`CONFIG SETENV AI_TURN_OK` is refused too, and is not in that table**, because it is not an
operating-system route and the refusal is not about the session reaching outwards. It is in list 1
with the rest of the flag's rules.

The three shell routes **ask**, and a refusal is **4167**; the `CONFIG`
operations give **4168**, *the assistant may not reach the operating system: a
grant lends the keyboard, not the shell*. Each is logged as a security event,
asked or refused.

**`SPOOLCMD` is in that `CONFIG` list although the restricted-session
classifier permits it.** That permission rests on running it being refused
elsewhere, which held only while the session was restricted; an unrestricted
session with an assistant attached could otherwise set the command and then
cause a print - a shell with nothing shell-shaped in the line that asked for
it.

**How the server knows.** The harness lives in the client and the gates are in
the interpreter, which over a link is another machine. The client reports its
own state on `SET_CLIENT_STATE`, whose flags word carries
`CLIENT_STATE_HARNESS_ATTACHED`; it is sent when a connection greets and when
it goes. It is **not** the AI-user-mode flag, which a DEVELOP session never
raises and which therefore could not answer this question. Ctrl-] needs none of
that: the terminal is the client, and asks `harnessAttached()` directly.

**What it costs.** A programmer with an assistant attached cannot use `SYSTEM`,
those `CONFIG` operations or Ctrl-] themselves. Detaching the assistant -
`MSG("harness", 0)`, or the connection closing - restores them at once.
