# BR 5.02 Release Notes

What changed in BR 5.02 that a user, an administrator or a support engineer needs to know about.
Entries that can change how an existing program behaves come first, because those are the ones worth
reading before an upgrade rather than after. For BR 5.01, see
[BR 5.01 Release Notes](old/BR501%20Release_Notes.md); for BR 5.0, see
[BR 5.0 Release Notes](old/BR50%20Release_Notes.md).

## Contents

- [1. Behaviour changes](#behaviour-changes)
  - [1.1 Searching a program ](#searching-a-program)
  - [1.2 Searching the console history ](#searching-the-console-history)
  - [1.3 The help key and HELP$ read br_tree](#the-help-key-and-help-read-br_tree)
  - [1.4 Matching brackets](#matching-brackets)
  - [1.5 Tab completion at the READY prompt](#tab-completion)
  - [1.6 The HELP command](#the-help-command)
  - [1.7 MSGBOX: the new message box, and Don't ask again](#msgbox-the-new-message-box)
  - [1.8 WORK trees in brrestrict.sys](#work-trees)
  - [1.9 brrestrict.sys limits every session](#brrestrict-every-session)
  - [1.10 SPAWN_RESTRICTED labels, and a restricted program's own notes](#restricted-label)
  - [1.11 A restarted client ends its old session](#client-restart)
  - [1.12 Longer PRINTER INIT and RESET strings](#printer-init-length)
  - [1.13 SORT control files: text files, and plain RECORD values](#sort-control-files)
  - [1.14 SORT builds an ISAM index](#sort-index-out)
  - [1.15 HTTP=SERVER: what a visitor can reach](#http-reach)
  - [1.16 Blanks after `>` and `>>`](#redirect-blanks)
  - [1.17 DISPLAY and BREAK into an array; BREAK takes a redirection](#display-break-redirect)
  - [1.18 PRINT at the command line: `| > file`](#print-redirect)
  - [1.19 A redirection into an array makes its elements longer](#redirect-array-grow)
- [2. Fixes](#fixes)
  - [2.1 Buttons are drawn plainly and centred](#buttons-are-drawn-plainly-and-centred)
  - [2.2 HTTP=SERVER reports exactly what is wrong](#http-server-reports-exactly-what-is-wrong)
  - [2.3 HTTP=SERVER fixes](#http-server-fixes)
  - [2.4 Memory-safety corrections](#memory-safety-corrections)
  - [2.5 MSGBOX fixes](#msgbox-fixes)
  - [2.6 How long a permission answer lasts](#y-this-once)
  - [2.7 One waiting assistant or debug channel per account](#token-lock)
  - [2.8 One audit log per restricted session](#restricted-log-per-session)
  - [2.9 SORT: `N` selects native order](#sort-fixes)
  - [2.10 READ PRIOR before any record is read, through a Btree2 index](#read-prior-first)
  - [2.11 ISAM: keys added after INDEX are found](#isam-new-keys)
  - [2.12 EXECUTE inside a command another EXECUTE ran](#nested-execute)

<a id="behaviour-changes"></a>
## 1. Behaviour changes

<a id="searching-a-program"></a>
### 1.1 Searching a program

**Searching the program from LIST.** While `LIST` is on the status line, **Ctrl+Shift+Up** and
**Ctrl+Shift+Down** search the loaded program's source for the word at
the cursor on, on the command line, and ignores case:

- With a listed line made the command line (the arrows put you on it), the search starts from the
  cursor's place in that line. With a word typed at the prompt, it starts from the bottom of the
  listing.
- The match is found ignoring case, in the lines as LIST shows them, going up or down and wrapping
  at both ends of the program.
- BR then lists a screenful ending with the line that matched, as `LIST -nnnnn` does, and
  highlights the match in that line. Near the start of the program, where there is not a screen's
  worth above it, the screen begins at the first line and the line is further up it; the highlight
  is still on that line.
- Pressed again on the empty prompt that leaves - or with the cursor on the highlighted match -
  the search goes on to the next occurrence of the same text, at the same length, as it does in
  the history.
- When nothing matches, BR sounds the bell and leaves the line as it was.

This is the arrows' counterpart to `LIST 'text'`, which lists every matching line at once.

<a id="searching-the-console-history"></a>
### 1.2 Searching the console history

The [console history](old/BR50%20Release_Notes.md#console-history) can be searched. The search
covers everything the history holds and the live screen below it, as one list, and ignores case.
A match is highlighted, and its line is brought into view about a third of the way down the
console, so that what led up to it shows above it.

**Ctrl+F** while you are reading the history (the status line says `HIST`) opens a **Search
History** box. It is a window of its own, so it can be moved anywhere, off the BR window included,
and it opens where you last left it.

| Key in the box | Does |
|---|---|
| **Enter** | searches up from the bottom of what is showing, then goes on to the next match up |
| **F3** | the next match up |
| **Shift+F3** | the next match down |
| **Esc** | closes the box; you are still reading the history |

Both directions wrap: past the oldest line the search goes on from the bottom of the live screen,
and past that back to the oldest. When a search wraps, the box's title says **wrapped**; when
nothing matches it says **not found**. Either one also sounds the bell.

**Ctrl+Shift+Up** and **Ctrl+Shift+Down** find the next occurrence, up or down, of the word at the
cursor, with or without the box open:

- On the live screen, the word is the one under BR's text cursor. Pressed at the live prompt, the
  keys also open the history, as Shift+Up does - except while BR is ready to draw more program
  lines (`LIST` on the status line), when they search the program instead; see
  [below](#searching-the-program-from-list).
- While the history is scrolled back, the word is the one you last clicked.
- Pressed again, they go on to the next occurrence of the same text, at the same length: searching
  for `aabb` highlights the `aabb` in `aabbcc` and then moves on, rather than searching for
  `aabbcc`.
- With the box open, the word is put into it, so F3 and Shift+F3 carry on with it.

A word is letters, digits, `_` and `$`.

All of this belongs to the history. Outside it, Ctrl+F goes to the program as any other key does,
and any key that leaves the history closes the box.

<a id="the-help-key-and-help-read-br_tree"></a>
### 1.3 The help key and HELP$ read br_tree

**The help key (F1) and `HELP$` now read the `br_tree` reference** - the BR language reference that
ships with the context kit as `context\br_tree` - instead of the `.wbh` help file. **`OPTION 85 ON`
puts back the old behaviour**, for an application that depends on it; see
[Compatibility](#help-compatibility) below.

**F1 at the READY prompt** shows the page for what the cursor is on:

- **The word under the cursor.** If the cursor is not on a word, it is the first word of the
  statement (after a line number or a label).
- **An error halt.** F1 on an empty line shows the page for the error code, for example the page
  for error 57.
- **What the word is.** A word that is several things is shown as the one it is on that line: the
  first word of the line is the statement or the command BR read it as (`DROP` typed at READY is
  the command; `OPEN` is a statement). A word written `rec=` is a clause of the statement, and
  one written `rec(` is a function. Each system function has its page row to itself, so
  `EXISTS` opens at the `EXISTS` row, not at the table of file functions.
- **On the empty prompt** with no error, the index of the commands.

**Where `br_tree` is** is found the first time it is needed and remembered until BR ends (a failure
too). BR looks in this order and takes the first folder that holds the tree:

1. `CONFIG HELPTREE <path>` - the folder, or the folder that holds `br_tree`. `CONFIG HELPTREE CLEAR`
   puts the search back.
2. `ENV$("BR_TREE")` - a `SETENV BR_TREE <path>` in the configuration file or a program, or the
   operating system's variable of that name.
3. `br_tree` or `context\br_tree` in BR's current folder, then checked in each of the two folders above it
   - then the same from the folder BR was started in, and from the folder the BR executable is in.

If it is not found F1 says so on the command line, `Help: br_tree not found [ CONFIG HELPTREE, or
ENV$(BR_TREE) ]`, and `HELP$` fails with error 9503. `STATUS` shows `HELPTREE` and `OPTION 85`.
`CONFIG HELPTREE` is refused in a restricted session.

**`HELP$(folder$[,anchor$])`** now returns where in `br_tree` a topic is, as the full path of the
file, followed by `#anchor` when one was given. It does not display anything.

- *folder$* is a folder of `br_tree` (`70-commands/program-management`), or simply (`program-management`), 
  or an error number (`57`, `ERR0057`), which gives the page for that error.
- *anchor$* names a section of that folder's `spec.md`, by its anchor or its heading, or a file in
  the folder. A name that begins two anchors is not enough: that is error 9504.
- A folder, section or file that is not there is **NOKEY**, error 4273, as `HELP$` has always
  reported a topic it could not find, and is trapped with `NOKEY`. A name that would leave the tree
  (`..`, a drive, an absolute path) is treated as not there.

```
LET PRG_MGT$ = HELP$("program-management", "go")
! C:\ADS\qsmrp\context\br_tree\70-commands\program-management\spec.md#go
```

<a id="help-compatibility"></a>
**Compatibility.** An application that calls `HELP$` with a `.wbh` keyword - `HELP$("topic", 1)` - or
depends on F1 opening `wbcmd.wbh`, or on `CONFIG HELPDFLT`, needs `OPTION 85 ON` in its
configuration; without it `HELP$` takes a string as its second parameter and a number is error 9505.
With `OPTION 85 ON` all of that works as it did, and a string second parameter is error 9505 instead.
F1 inside a running program - at an `INPUT` or a field - is not changed by this.

The error numbers 9503 to 9505 are provisional.

<a id="matching-brackets"></a>
### 1.4 Matching brackets

With the cursor on a bracket - `(` `)` `[` `]` `{` or `}` - BR shows the bracket that goes with it.
This works wherever you are typing at the console: the command line, an `INPUT` or `LINPUT`, and a
console field, whether or not the text is a program line.

- **A match** is shown in reverse.
- **No match** - the bracket is never closed, or never opened - shows the bracket under the cursor
  white on red.
- Brackets inside a string constant (`"..."` or `'...'`) are not counted, and a cursor on one shows
  nothing.
- The marks follow the cursor and come off when it moves, when the text changes and when the input
  ends. They are display only: the text is not changed.

**In the console history** the same is done for the bracket you last clicked. The match is looked for
in the rows on the screen, so a pair that reaches past them shows as unmatched until you scroll it into
view.

<a id="tab-completion"></a>
### 1.5 Tab completion at the READY prompt

Tab at the READY prompt lists the file names, or the HELP words, that fit what you have typed, and
a few keys then choose from the list. It works the same way in both places.

**Where it works.** After the file-name commands (`COPY`, `RENAME`, `MOVE`, `FREE`, `TYPE`, `LOAD`,
`DROP`, `DIR`, `RUN`, `SAVE`, `REPLACE`, `MERGE`, `PROC`, `SUBPROC`, `RMDIR` and `CHDIR`/`CD`, or an
abbreviation of one), in the file after `>` or `>>` on a command that redirects its output (and after
`<` on `LIST`), and after [`HELP`](#the-help-command). `RMDIR` and `CHDIR` offer folders only.

**The keys:**

| Key | Does |
|---|---|
| **Tab** | lists the names or words that fit what is typed, and leaves the line as it is. If only one fits it is completed (a folder gets its slash). Tab with a folder name on the line lists what is in that folder |
| **Right arrow** | puts the next name from the list on the line. With none chosen yet, the first one |
| **Left arrow** | puts the prior name on the line. With none chosen yet, the last one |
| **Space** | shows the next group of a long list. When there is no more, it is an ordinary blank |
| **Backspace** | when at the end of a word, takes away the whole word - otherwise normal backspace |
| **Enter** | accepts the line as it is |

- Right and left choose from the list, and wrap round at both ends. As soon as any other key is
  pressed they are the ordinary cursor keys again. **Up and down** always recall commands, as before.
- A letter typed after a name that was put on the line is added to it, and Tab lists again for what
  is now typed.
- **Tab straight after the command word** - even an abbreviation such as `HEL` or `LO` - puts in the
  blank for you and then lists, as if you had typed the blank and hit Tab.
- The first name of a command that takes two parameters (`COPY`, `RENAME`, `MOVE`) gets a blank after 
  it when it is completed. A name with a blank or comma in it is put in quotes. Options (`-S`) and the 
  words after the names (`TYPE`'s `PRINT`, `LOAD`'s `SOURCE`) are not completed.

**Long lists** show as many names as fit, then a line saying what can be done next:
`... 178 more - space for more | left/right to choose | type a letter, then Tab`. When the whole list
is showing it reads `left/right to choose or type a letter, then Tab`. The first list scrolls away
like any other output.

<a id="the-help-command"></a>
### 1.6 The HELP command

The new HELP command is a work in progress. Eventaully it will work with a new wiki when it is built. 
For now it works with br_tree documentation.

**`HELP` at the READY prompt** shows the `br_tree` page for a keyword, and **Tab completes what you
give it**, as it does for a file name after `DIR`; the keys are in
[1.5](#tab-completion). It reads `br_tree` like F1 does, so `OPTION 85 ON` puts back the old
behaviour; see [1.3](#the-help-key-and-help-read-br_tree).

- **`HELP word`** shows the page for that word (`HELP SORT`, `HELP OPEN`). Abbreviations work, as they do
  for any command.
- **`HELP` and Tab** lists the sets: `COMMANDS`, `CONFIG`, `STATEMENTS`, `FUNCTIONS`, `LIBRARIES`
  and `LEXI`. A set is entered only when what is typed names it alone: `HELP CO` and Tab lists
  `COMMANDS` and `CONFIG` and enters neither, and `HELP CO` with Enter says that more than one
  set starts with `CO`. `HELP CON` is enough for `CONFIG`, and `HELP COM` for `COMMANDS`.
- **A set is a folder.** Tab with a set on the line goes into it - `HELP FUN` and Tab gives
  `HELP FUNCTIONS ` and lists the functions - and so does Tab on a statement that has secondary
  keywords (`HELP STATEMENTS CLOSE` and Tab lists them, as below). `LEXI`, and a word with
  nothing inside it, stays as it is.
- **Enter on a set** lists its words, and leaves the set on the line: `HELP FUNCTIONS` lists the
  functions, and `HELP FUNCTIONS ABS` shows the page for `ABS`. A list shown this way is paged with
  Enter: `... 48 more - enter for next or [ bksp & type a letter, then ] Tab for more`.

What each set holds:

- **COMMANDS** - the commands, such as `DIR`, `MOVE` and `SORT`. `HELP COMMANDS CONFIG` shows the
  `CONFIG` command itself.
- **CONFIG** - every configuration statement BR supports: what a `brconfig.sys` line or a `CONFIG`
  command can set, such as `LOGGING`, `PRINTER` and `SPOOLCMD`. Enter on one shows where br_tree
  defines it: its own page when it has one (`LOGGING`), else the line that describes it
  (`BASEYEAR` opens at its entry among the language and I/O settings). A statement br_tree does not describe yet says so on the command
  line: `br_tree has no entry for WORKSTACK yet`.
- **STATEMENTS** - the primary statements only. Choose one and Tab offers its secondary keywords:
  `HELP STATEMENTS, CLOSE` offers `DROP`, `FREE`, `RELEASE` and `WAITEQ`. `RETRY` and `CONTINUE` are
  statements; `GROW`, `IGNORE` and `SYSTEM` are secondary keywords (`ON ERROR SYSTEM`).
- **FUNCTIONS** - the functions that are not deprecated.
- **LIBRARIES** - the library topics (`FILEIO`, `FNFM`, `SCREENIO` and so on). `BRLIBS`, `LOAD`,
  `RELEASE` and `NOFILES` are left out of the list; `HELP LOAD` and `HELP RELEASE` still show their pages.
- **LEXI** - the Lexi page.

F1 follows the same rules: F1 on `SYSTEM` in `ON ERROR SYSTEM` now shows the secondary keyword, not the
`SYSTEM` command.

<a id="msgbox-the-new-message-box"></a>
### 1.7 MSGBOX: the new message box, and Don't ask again

On Windows, `MSGBOX` now shows the Windows **task dialog**, the message box Windows itself uses,
instead of the older classic box. The question, the buttons and the answers are the same, but the
box looks different:

- **`QST` shows no icon.** The task dialog has no question-mark icon, following Microsoft's
  guidance that routine questions carry none. `INF`, `ERR` and `EXCL` show their icons as before.
- **`YNAC` reads Yes, No, All, Cancel**, with Cancel at the far right.
- **BR's own permission question** (asked while an assistant is attached) reads
  "Yes, this turn", "All this session", "While connected", "No", with the safe answer, No, at the
  far right. Escape still answers No.
- **Other dialogs may look different too.** BR now uses the current Windows common controls
  throughout, so its file, print and font dialogs take the current Windows style.

**`^` in the buttons string adds a "Don't ask again" checkbox**, anywhere in the string: `"YN^"`,
`"YNC^"`, or `"^"` alone for an OK box. A ticked checkbox **adds 10 to the answer**: OK `11`, Yes
`12`, No `13`, Cancel `14`, All `15`. A program that does not use `^` never sees a value over 5.

```business-rules
00100 LET ANSWER=MSGBOX("Print the labels now?","Labels","YN^","QST")
00110 IF ANSWER>10 THEN LET SKIPASK=1 : LET ANSWER-=10
```

What BR does with the answer is up to the program: BR does not remember it.

<a id="work-trees"></a>
### 1.8 WORK trees in brrestrict.sys

A `WORK` line in `brrestrict.sys` names a tree where a session may change files it did not
create - a site's test data, for an assistant to work on freely:

```
Q:\data
WORK Q:\data\test
!Q:\data\test\keys
```

- **In a restricted session,** a file under a `WORK` tree may be rewritten, emptied, renamed or
  deleted, and a directory under it removed, as if the session had created it. The tree's own
  root may not be removed or renamed.
- **In permission mode,** an AI turn does not ask about a change under a `WORK` tree.
- **It frees changing, not reaching.** Where the list names any area, a `WORK` tree must be inside
  one. A list of `WORK` lines alone names no area, so it does not limit where a session may be.
- **An exclusion still wins**, inside a `WORK` tree as anywhere.

Name test data only. A `WORK` tree lets an assistant overwrite what is in it without anybody being
asked. See `AI-Restricted-Operations.md`, *`WORK` trees: where changing is free*.

<a id="brrestrict-every-session"></a>
### 1.9 brrestrict.sys limits every session

The areas listed in `brrestrict.sys` bound **every** BR session, restricted or not: an ordinary
user's session, a `DEVELOP` session and a session with an assistant attached may read, create,
change, rename, delete and list only what the list permits, less what it excludes. Anything else
is refused with error **4165**, *brrestrict.sys does not permit this file*.

- **Inside the list,** a session that is not restricted may change any file, whoever created it.
  Only a restricted session is also held to the files it created (4153).
- **A file the list refuses is not asked about.** In an AI turn the list is tested before
  permission mode, so an excluded file is refused rather than put to the person.
- **Name everything BR uses.** Program and procedure directories, and the work, spool and print
  directories, have to be in the list as well as the data.
- **The configuration file and its `INCLUDE`s are read before the list applies,** in every
  session. The client reads its own list, beside the client executable, when the session starts.
- **No list, no limit.** Without `brrestrict.sys` nothing changes.
- **Operating-system commands are outside it.** What a shell command run from an unrestricted
  session does is not governed by the list.

See `AI-Restricted-Operations.md`, *Files: where the session may be*.

<a id="restricted-label"></a>
### 1.10 SPAWN_RESTRICTED labels, and a restricted program's own notes

A restricted session's audit log can now say what the session is for, in two ways: a label from
the session that started it, and notes from the program running in it.

**`SPAWN_RESTRICTED(command$ [, config$ [, wait [, label$]]])`** takes an optional fourth
argument, `label$`: a few words saying what the new session is for. It opens the child's audit log,
and is in the starting session's own record of starting it, so several children can be told apart
and each run in a reused log file found by its start:

```text
00100    LET RC = SPAWN_RESTRICTED("PROC "&REPORT$, "", 300, "month-end report")
```

```text
Restricted-session audit log for session 012, started for "month-end report": this session may ...
```

The label comes from the session doing the starting, which is not restricted, so it is the more
trustworthy of the two. Pass `""` and `0` for `config$` and `wait` to label a session without
changing either.

**`DEBUG_STR(level, str$)` in a restricted session** writes the program's own note to that log,
marked as the program's:

```text
00110    LET X = DEBUG_STR(5, "checking open orders for customer "&CUST$)
```

```text
Program note: checking open orders for customer 1042
```

- **It stays on one line.** Control characters, including carriage returns and line feeds, become
  spaces, so a note cannot start a log entry of its own.
- **It cannot claim an error's level.** A `level` below 5 is logged at 5. Levels above 8 are not in
  the audit log, whose level is 8.
- **It is cut to 200 characters.**

`label$` is cleaned the same way, and a double quote in it becomes a single one. `DEBUG_STR` in any
other session is unchanged.

See the `SPAWN_RESTRICTED` and `LOGGING` pages in br_tree, and §2.8 for the log's name.

<a id="client-restart"></a>
### 1.11 A restarted client ends its old session

When a client-server client's process ends without closing its session (a crash, End Task, a
power cut at the desk), its server keeps running and waits for that client to reconnect until the
reconnect time runs out. A new client cannot take that session over: the screens, windows and
files the old client held are gone. So **a new client now ends the old session before it logs
in**, instead of leaving it running beside the new one.

- **What the person sees.** At start-up the client shows *Ending session 021, whose client did
  not close.* for a moment, and then logs in as usual. The old session's program stops where it
  was, as if its client had been closed without saving; nothing it had not written is kept.
- **The same session number.** The old session gives back its WSID before it ends, so the new
  session can have the same WSID and `SESSION$`.
- **Which sessions.** Only a session started by a client on the same machine, under the same
  user, to the same listener address, port and label, and only when the client that started it is
  no longer running. A session that ended in order, or whose client is still open, is left alone.
  So is one whose server has given up waiting by now.
- **How long it can take.** Usually a second or two. A new client waits at most 35 seconds for the
  old server, then logs in anyway; each old session is tried once.
- **No login is needed to end the old session.** The request carries the old session's own
  reconnect id, which only its client knew.

**The listener must be the 5.02 `brlistener`.** An older listener does not know the request; the
client waits 5 seconds for an answer and then logs in, leaving the old session to time out as
before.

**For support,** `brlistener.log` records each step:

```text
A restarted client asks for its previous session 021 to be ended; holding the request for up to 35 seconds.
The server of session 021 acknowledged the abort and is ending.
Told the restarted client that its previous session 021 has ended.
```

and the old server's log says *The client was restarted and asked for this session to end.
Ending it.*

<a id="printer-init-length"></a>
### 1.12 Longer PRINTER INIT and RESET strings

The strings `PRINTER` sends to a printer can be longer. A length is counted after the string is
decoded: `\E`, a hex pair such as `1B` and each character in quotes are one byte each.

| String | Longest | Was |
|---|---|---|
| `INIT` | 3990 bytes | 255 |
| `RESET` | 800 bytes | 255 |
| A substitution (`[name]` or `2B`) | 800 bytes | 255 |

A configuration line is still at most 800 characters, so a long `INIT` or `RESET` is written over
several lines. **`INIT+`** and **`RESET+`** add to the string defined so far:

```
PRINTER LASER INIT HP,"\E&l0O\E(s1b4102T"   ! starts the string
PRINTER LASER INIT+ "\E&k2s2G\E&l66p7.6C"   ! adds to it
PRINTER LASER INIT+ 1B "*c5000Y"
```

- **A plain `INIT` or `RESET` starts the string again**; each `+` line adds to its end, in the
  order the lines are read.
- **`HP` belongs on the `INIT` line**, and its PJL prefix counts 60 bytes towards the 3990.
- **`LPP`** on a `+` line takes effect; without one, the earlier value stays.
- **These are refused** as a configuration error, leaving the string as it was: a `+` line that
  would take the string past its limit, an `INIT+` or `RESET+` with no `INIT` or `RESET` before
  it for that printer, `INIT+ CLEAR`, and `HP` on an `INIT+` line.

**`STATUS PRINTER`** shows a long string as an `INIT` (or `RESET`) line followed by `INIT+` (or
`RESET+`) lines, each short enough to be read back as configuration.

<a id="sort-control-files"></a>
### 1.13 SORT control files: text files, and plain RECORD values

**A control file can be a text file**, written with an editor, as well as an internal file
written record by record. Each line is one specification; lines may end in CR LF or LF, blank
lines are skipped, and a line may be up to 490 characters. A text file used to be refused with
error 4122.

**A `RECORD` limit can be a plain value.** `RECORD I,13,4,PD,20,60` now selects amounts from 20
to 60, the same as `"20","60"`. A position in the record, whose field is compared against, is now
written with **`@`**: `RECORD I,13,4,PD,@17,@21`.

> **Check existing control files for plain numbers in `RECORD` limits.** A plain number used to
> mean a position in the record and now means a value, so such a line selects different records.
> Put `@` in front of each one to keep its meaning.

A plain text value is read in upper case and cannot contain a comma; quote text that has lower
case letters or commas, as before.

<a id="sort-index-out"></a>
### 1.14 SORT builds an ISAM index

`SORT` can build an ISAM index of its input file: **`I`** in the `FILE` specification's file-spec
position (the tenth) makes the output file an index keyed on the `MASK` fields. It is the same
index `INDEX ... ISAM` builds, and it is used the same way:

```
FILE CUSTOMER.INT,,,CUSTNAME.IDX,,,,,I,,REPLACE
RECORD I,40,2,C,"TX","TX"
MASK 1,30,C,A
```

```business-rules
00100 OPEN #1: "NAME=CUSTOMER.INT,KFNAME=CUSTNAME.IDX", INTERNAL, OUTIN, KEYED
```

- **The key** is the `MASK` fields, in their order, as they stand in the record. Each must be
  ascending: `D`, or the `Y` of BASEYEAR order, is error 7807.
- **`RECORD`** chooses which records get an entry, so the index can cover part of the file.
- **The collating sequence** (the eleventh position: `N`, `A`, or blank for the configuration's)
  is the index's own and stays with it.
- **Records written through the index** are added to it, as with any ISAM index.
- **`REPLACE`** replaces an existing index; without it, an existing output file must be empty
  (error 7832).

<a id="http-reach"></a>
### 1.15 HTTP=SERVER: what a visitor can reach

The web server serves files only from under BR's working directory, and writes only uploads to
its `tmp` folder. These closed security holes, and some of them stop a site that relied on what
was allowed before:

- **`URL_BASE=` must be BR's working directory or a folder under it**, as written. Any other
  folder fails the OPEN with new error **758**, and `SYSERR$` gives the path and the working
  directory. A junction or link on the way to `URL_BASE=` is still allowed.
- **A junction or symbolic link inside `URL_BASE=` cannot lead out of it.** A file whose real
  location is outside `URL_BASE=` is refused with **403**, and the refusal is logged.
- **No Server Side Includes.** `.shtml` and `.shtm` files are sent as they are. Before, such a
  page could include any file on the machine and run any operating-system command, and with
  `URL_BASE=` covering the upload folder a visitor could upload one and then fetch it.
- **The upload folder is never served.** Anything in `tmp` gets **403**, so one visitor cannot
  download another's upload.
- **An upload stays in `tmp`.** The session id appended to an uploaded file's name comes from a
  cookie the visitor sends; it keeps only letters and digits now. A crafted cookie could store
  the file outside `tmp`.

`brrestrict.sys` does not govern the files the server serves or stores; these rules do.

<a id="redirect-blanks"></a>
### 1.16 Blanks after `>` and `>>`

An output redirection may have blanks or tabs between `>` or `>>` and the file or array it names:

```
LIST > L$
STATUS FILES >> status.txt
DIR *.brs >  list.txt
```

This works wherever a redirection does - `LIST`, `STATUS`, `DIR`, `TYPE`, `INDEX`, `RUN`,
`DISPLAY` and the other file commands - into a file or into a string array, at the `READY`
prompt and from `EXECUTE`. Tab completes the name after the blanks as it does straight after the
`>`.

<a id="display-break-redirect"></a>
### 1.17 DISPLAY and BREAK into an array; BREAK takes a redirection

**`DISPLAY` can fill a string array**, as `LIST > A$` does:

```
DISPLAY TOTAL > TRACE$
DISPLAY MAT CUST$ >> TRACE$
```

- The array is a one-dimensional string array of the program the command is given in, one line
  to an element. `>` empties it, `>>` keeps what it holds, and it is redimensioned as each line is
  written, so it always has exactly the lines written so far.
- A display does not watch the array it fills. `DISPLAY ALL > A$` leaves `A$` out, and
  `DISPLAY MAT A$ > A$`, or an element of it, is refused with error 1006.
- If the program is cleared, or the array is not there when a line is written, the line goes to
  the screen.

**`BREAK` takes a redirection**, `> file`, `>> file` or `> A$`. The break itself is not
redirected: the program stops as it always does. The line a variable break shows, saying what
changed, goes to the redirection instead of the screen, as a `DISPLAY`'s would:

```
BREAK STATUS$ >> TRACE$
BREAK TOTAL > watch.txt IF TOTAL>1000
```

- `IF` takes the rest of the command as its condition, so the redirection goes before it, on
  `DISPLAY` too.
- `BREAK ... OFF` with a redirection is refused with error 1006, as `DISPLAY ... OFF` is.
- With a debugger attached, the line goes to the redirection and the debugger is told as before.
- Tab completes the file name after `BREAK ... >`.

<a id="print-redirect"></a>
### 1.18 PRINT at the command line: `| > file`

A `PRINT` given as a command - typed at `READY`, in a procedure, or run by `EXECUTE` - can send
what it would show on the console to a file or a string array, written after the print list with
a `|` in front:

```
PRINT MAT CUST$ | > cust.txt
PRINT USING "form pos 3,c 10": NAME$ | >> names.txt
PRINT MAT A | > LINES$
```

- `>` creates or replaces the file, or empties the array; `>>` adds to the end. Blanks around `|`
  and after `>` are optional.
- The lines are what the console would have shown, at the console's width, and nothing goes to
  the screen. `PRINT USING` is redirected too. A `PRINT #n:` still writes to its own file, since it
  shows nothing on the console.
- An array is a one-dimensional string array of the program the command is given in, one line to
  an element. It is filled when the `PRINT` is done, so `PRINT MAT A$ | >> A$` is safe.
- A name ending in `$` is always an array. If there is none by that name it is made, as `A$(1)`
  would make it, and starts empty even with `>>`. A file whose name ends in `$` is quoted:
  `PRINT X | > "A$"`.
- The file is closed when the statement ends, normally or with an error. A missing name, or
  anything but a `!` comment after it, is error 1006.
- It is for the command line only: in a numbered program line `|` is a syntax error. A single `|`
  is not an operator anywhere (`||` is OR), so no existing line changes meaning.

<a id="redirect-array-grow"></a>
### 1.19 A redirection into an array makes its elements longer

A redirection into a string array - `LIST`, `STATUS`, `DIR`, `TYPE`, `DISPLAY`, `BREAK`,
`PRINT ... |` and the rest, with `>` or with `>>` - adds elements when there are more lines. What
happens when a line is longer than the elements depends on where the command came from:

```
PRINT RPT$("ABC",47) | >> A$
```

- **Given at the console**, the elements are always made longer to hold the line. Every element
  takes the new length, and what the array held is kept.
- **Run by `EXECUTE`**, the program's `SOFLOW` setting at the time of the `EXECUTE` decides, as
  for an assignment: the elements grow under `ON SOFLOW GROW` (or `SOFLOW-GROW`), the line is cut
  to the element length under `ON SOFLOW IGNORE`, and otherwise it is error 58.
- A `DISPLAY` or `BREAK` writes its lines later, while the program runs, and keeps the rule that
  applied when the command was given.
- Growing stops at `SOFLOW-GROW MAX=`; a longer line is error 58.

<a id="fixes"></a>
## 2. Fixes

<a id="buttons-are-drawn-plainly-and-centred"></a>
### 2.1 Buttons are drawn plainly and centred

A button field, such as a hot field shown as a button under `OPTION 40`, has a clear frame and a
label centred in the full height of its row, whether or not Windows themes are in use.

- **Label alignment.** The label is centred unless the field spec asks for right alignment, which
  is honoured.
- **`OPTION 50` applies to buttons**, as it does to text fields and combo boxes: a button is drawn
  with the classic raised 3D frame instead of the Windows theme. The same is true under
  `WINDOWS_THEMES OFF` and for a field whose attributes turn themes off. Note that this does not 
   change the functionality of OPTION 50, except to extend it.
- **With themes in use** (`OPTION 50` off), a button is drawn flat, as the Windows 11 theme draws
  it. It fills its row exactly as a classic button does, has a dark outline, and its face is a
  lighter shade of the field's colour so that it stands out from the window behind it. While the
  mouse is over it, the button takes the theme's own highlight.

<a id="http-server-reports-exactly-what-is-wrong"></a>
### 2.2 HTTP=SERVER reports exactly what is wrong

Each fault in setting up the web server has its own error, 0763 to 0797. `BRERR$` says what
is wrong and `SYSERR$` names the file, port or word concerned, so a certificate problem no longer
needs a log to diagnose:

```
ERR = 788   HTTPS private key file not found - <base>.key must sit beside <base>.crt
SYSERR$ =   C:\site\certs\server.key
```

| Codes | Cover |
|---|---|
| 0763-0768 | The `OPEN` string, and no HTTP licence. 9990 now means only a build without HTTP |
| 0770-0777 | `CONFIG HTTP` and `HTTPS`: keyword, port, range, missing value, `THREADS=`, `BIND=`, `PROXY=`, bad value. These replace 1006 |
| 0778-0781 | `LOG=` and `URL_BASE=` |
| 0782-0795 | The certificate, key and passphrase |
| 0796-0797 | The port is denied, or `BIND=` is not on this machine. 752 means only that the port is in use |

- **A wrong `URL_BASE=` now fails the `OPEN`.** No `URL_BASE=` and no `web` folder is a warning.
- **A `CONFIG HTTP` line with a fault changes nothing**, and a bad HTTP line in `brconfig.sys` is
  raised by the first `HTTP=SERVER` `OPEN`.
- **`CONFIG HTTP 0` and ports over 65535 are refused** (0771), and `PROXY=` takes only numeric
  addresses (0776).
- **`HTTP=SERVER` must be opened `DISPLAY, OUTIN`** (0764, 0765).
- **An expired certificate still starts the server**, with a warning, because renewing it needs the
  server answering on port 80.
- **The server log always records** a start-up failure, the start-up lines, and every refusal, with
  no `LOGGING` statement needed.
- **`FILE$(n,"HTTP-REFUSED")`** reports requests turned away, licence refusals first:
  `3,1,799,192.168.1.40,14:03:22`. Use it to see that clients are being refused for lack of HTTP
  licences. **`FILE$(n,"UPLOAD-ERROR")`** gives `769,<reason>` if the current request's upload could
  not be stored, otherwise `0`.
- **After error 4145, `SYSERR$`** says why the read ended: `no request in 15 seconds`, the same with
  `, 2 refused`, or `interrupted by a function key`.

<a id="http-server-fixes"></a>
### 2.3 HTTP=SERVER fixes

- **A refused second `OPEN` leaves `AUTH` as it was.** It could turn authentication mode off on the
  running server, so that static files were served without the program's login check.
- **A response contains only what the program printed.** Without `EOL=NONE`, it could also carry
  the rest of the request's body, to the same client.
- **The passphrase stays out of the BR log**, which recorded it in the `CONFIG` command.

<a id="memory-safety-corrections"></a>
### 2.4 Memory-safety corrections

- **A corrupt or over-deep index can no longer overrun memory.** Searching and inserting into an
  index kept the path from the root in a table of 12 levels, and stepped one past the end of it
  before noticing the index was too deep. That could overwrite the neighbouring field, and lock
  and read a node chosen from the overwritten value. The check is now made before the table is
  used, and such an index is refused with the bad-index error instead. An index of up to 12 levels
  behaves as before.
- **The console client no longer crashes clearing or closing the first screen.** `CLR_WINDOW`
  (clearing the current window) and closing a screen used the screen's list of linked controls
  before the screen had one, which crashed the client on Linux. Both now skip the step when there
  is no list. The wx client has the same guards, added for consistency; no crash has been seen
  there.

<a id="msgbox-fixes"></a>
### 2.5 MSGBOX fixes

- **All in a `YNAC` box works.** The fourth button showed "Help", and pressing it did nothing, so
  All could not be answered. It now reads All, closes the box, and returns `5`.
- **Ctrl-A works on a Yes/No box.** On a `YN` box, Ctrl-A did nothing. It now closes any message
  box without answering it and halts the program with ATTN at the `MSGBOX`; `GO` shows the box
  again. An `ON ATTN` handler takes the halt as usual.
- **Ctrl-A at the permission box for an assistant's `SYSTEM` command is a pause.** The box
  closes and BR halts at READY with the turn still open. `GO` asks the question again and waits
  for the person; the assistant hears nothing until the question is answered, and the commands
  it queued behind the `SYSTEM` do not run before then. Ctrl-A at any other command's question,
  such as `COPY`'s `Overwrite?`, ends that command.
- **An attached assistant keeps working while a box is up.** BR stopped answering the AI harness
  for as long as a message box was on the screen, so an assistant or a screen test went silent
  until somebody answered it. The harness now goes on answering, and a Break sent by the
  assistant interrupts the box as Ctrl-A does.

<a id="y-this-once"></a>
### 2.6 How long a permission answer lasts

When an attached assistant's turn reaches a destructive operation on a file, BR asks the person at
the console. The answers now last:

| Answer | Lasts |
|---|---|
| `N` | refused; the next operation asks again |
| `Y` | the rest of this turn |
| `H` | this connection: a new assistant, or the same one reconnecting, is asked again |
| `A` | the rest of this BR session |

each for the one file the question named, or a shell command's first keyword. The question reads
`N = no, Y = turn, H = connection, A = session`, and the message box's buttons "Yes, this turn",
"All this session", "While connected" and "No".

Fixed with it:

- **Allowing a file no longer makes it the assistant's.** An answer to a `DROP`, a `COPY` over a
  file or an open for output made the file count as the assistant's own, so nothing was asked
  about it again however the person had answered.
- **An answer of `H` ends with the connection.** It used to carry over to the next assistant to
  connect when the program reopened the channel.
- **A `COPY` over an existing file asks once**, at the target, rather than a second time about
  setting the copy's time stamp.

Files the session itself creates while an assistant is attached are not asked about, for the rest
of the BR session.

<a id="token-lock"></a>
### 2.7 One waiting assistant or debug channel per account

Every BR session under one Windows account publishes its assistant token to the same file,
`%LOCALAPPDATA%\ADS\harness.token`. A session that opened a channel while another session's
channel was still waiting for its assistant wrote over that session's token, so the waiting
channel could never be claimed, and its assistant's attempt counted as a bad handshake toward that
channel's lockout.

The token file is now locked from the moment it is written until an assistant claims it. While
it is locked, `MSG("harness", port)` in another session fails with new error **4173**, and the
waiting token is untouched. Once the first channel is claimed or closes, the second session can
open its own. A program that starts sessions which open channels of their own should have its own
channel claimed first, or handle 4173 in the child.

`br_mcp_driver` also refuses to send a token to a port other than the one the token file names,
so a mismatch never reaches a session as a bad handshake.

The debug channel's token, `%LOCALAPPDATA%\ADS\brdebug.token`, is locked the same way from
`DEBUG LISTEN` or `DEBUG CONNECT` until a debugger attaches. Another session's `DEBUG LISTEN` or
`DEBUG CONNECT` in that time fails with new error **4176**, and the waiting token is untouched.

<a id="restricted-log-per-session"></a>
### 2.8 One audit log per restricted session

A restricted session's audit log is named **`restricted-<SESSION$>.log`**: the WSID and then the
session number, for example `restricted-011.log` for WSID 01, session 1. It is in the folder
`--restricted-log=` names (a `SPAWN_RESTRICTED` child is given its parent's log folder), or
otherwise in `%LOCALAPPDATA%\ADS`. Two restricted sessions on one WSID, such as two children
running at once, each have their own file instead of interleaving their lines in one. A later
session with the same WSID and session number appends to the same file, and each run's first entry
says where it begins, with the session's label when it has one (§1.10).

<a id="sort-fixes"></a>
### 2.9 SORT: `N` selects native order

`N` in the `FILE` specification's collating position selects native order. With
`COLLATE ALTERNATE` in the configuration, the sort used the alternate sequence even when the
control file said `N`. A blank position still takes the configuration's sequence.

<a id="read-prior-first"></a>
### 2.10 READ PRIOR before any record is read, through a Btree2 index

A `READ ... PRIOR` through a Btree2 index when no record has been referenced, straight after
`OPEN` or after a `RESTORE` with no parameter, gives EOF. It read the last record, unlike an ISAM
or Btree index, which give EOF there. To read backwards from the end of the file, start with
`READ ... LAST` and continue with `PRIOR`.

<a id="isam-new-keys"></a>
### 2.11 ISAM: keys added after INDEX are found

Keys written to an ISAM index after `INDEX` built it are found by `KEY=`, `DELETE ... KEY=` and
sequential reads in both directions. Most of them were not: a
new key goes into the index's unsorted overflow area, and the key after it in the sorted area
was not always marked to send reads there, so reads passed it by. In a test, 82 of 100 records
written after an `INDEX` could not be read by key or sequentially; closing and reopening the
file did not bring them back.

**An ISAM index written to by an earlier release may already be missing keys.** The keys are
still in the index file, so `INDEX ... REORG` (which sorts them all into place) or
`INDEX ... REPLACE` (which builds the index again from the master file) makes them readable.

<a id="nested-execute"></a>
### 2.12 EXECUTE inside a command another EXECUTE ran

An `EXECUTE` can run a command that calls a function, and that function can `EXECUTE` in turn.
When the outer command fails, its error is taken at the outer `EXECUTE`: its trailing error
clause, `ON ERROR`, `ERR` and `LINE` all refer to that clause, at any depth.

Both EXECUTEs kept the place of their clause in one slot per program, so the inner one
overwrote the outer one's. An outer command that failed afterwards could crash BR, or have its
error placed at the wrong clause. If the inner command had failed and its error was trapped, a
later failure of the outer command was lost and the program carried on as though it had worked.
