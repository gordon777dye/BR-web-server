---
title: Lexi
file: LEXI.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: reference
related: [brls, line numbers, Show Lexi Expansion, Compile with BR, Add Line Numbers, Strip Line Numbers, lexi.json]
corrections:
  - "2026-11-20: The dialect file section now says how to customize the preprocessor: what `lexi.json` holds, every rule and the keys it reads, and how brls finds the dialect file (the `br.lexi.dialect` setting, then `lexi.json` in the workspace folder, then the one built in), reads it again when it changes, and falls back to its own with a message when a file is refused. The extension ships a copy and a command to put it in the workspace. The example was run through brls (`-workspace`, with and without the file)."
  - "New page (owner, 2026-11-19): the Lexi built into brls (internal/lexi). Written from brls's
    source and from running sample input through its expansion; the examples below are that
    output. The original lexi.brs program is described in legacy_lexi.md."
  - "§/* ... */ (2026-11-19): added that a line ending in */ is joined to the next line, because it
    ends in the continuation operator /. Found by running both Lexis on brls's lsp/lexi-err.brs
    (outputs in lsp/legacy-out.brs and lsp/lexi-out.brs). The first draft of this page said
    only that a one-line comment does not close."
  - "Corrected §Continuation (2026-11-19), which said a !: is never taken as a comment: one after
    an earlier colon is. Added how the comment is found (quote counts), the $ and }} rules for
    {{…}}, the !: state in a translated file, and a line beginning +12 after a !: line. Each is
    confirmed by running both Lexis on lsp/lexi-err.brs and lsp/lexi-err-19.brs."
  - "Rewritten (owner, 2026-11-19): brls's Lexi no longer reproduces those defects, so the
    sections describing them now describe what it does instead — strings tracked and `!:` never a
    comment in Continuation; block comments not code, closed on the line that opens them, and
    never joined; `{{…}}` typed by its first operand and closed inside its string; a `!:`
    continuing exactly one line; a line number as one to five digits and a blank. The old
    behaviour is the dialect key `legacy`. Each confirmed against lsp/lexi-err.brs and
    lsp/lexi-err-19.brs (outputs lsp/lexi-out*.brs)."
  - "Source in error (owner's policy, 2026-11-19): brls reports it as an error and the expansion
    leaves it as written. Rewritten to match — a statement continuing at the end of the file is
    no longer dropped, a malformed #AUTONUMBER# is ignored whole instead of half applied, a
    #SELECT# without its #CASE# is left with its #END SELECT#, and directives out of order no
    longer stop the expansion. Added the errors for !_, template strings, block comments and
    #DEFINE#, that #SELECT#s nest, and that select directives in a ! comment are comment text."
  - "§#SELECT# (owner, 2026-11-19): stated outright that a #SELECT# can be part of a #CASE#, with
    an example of one nested in another. The example is brls's expansion, run 2026-11-19."
  - "§Continuation (owner, 2026-11-19): a !: after a continuation operator is now an operator
    continuation, the !: left out. The page said every line ending in !: was left to BR, and BR
    4.33c rejects an operator before !: (LOAD ... SOURCE: let X=1+ !: is error 1026, let A$=\"a\"&
    !: is 1030, print A, !: loads). Found by loading lsp/lexi-out.brs in BR, which failed at
    print #1: A+ !:."
  - "§How it runs (owner, 2026-11-19): added that brls uses the original lexi.br instead when the
    crs-dev.vslang-br extension is installed and disabled. Confirmed by brls's tests running lexi.br
    from the kit's copy of that extension's Lexi folder (internal/origlexi, internal/lsp)."
  - "References to brls's LEXI_OLD.md removed (owner, 2026-11-20): that file was deleted. The
    original Lexi's defects are listed at Dialect.Legacy in brls's internal/lexi/dialect.go."
  - "§How it runs and §The dialect file (owner, 2026-11-20): which files are Lexi is now decided by the
    dialect's own spellings, so a numbered file using a renamed #SELECT# or #DEFINE# is Lexi (before,
    only the shipped words counted, and such a file was taken for BR); a project's dialect file is
    read on top of the shipped one, so a key it leaves out keeps the shipped value; and a key no
    dialect has is refused. Deleting a project's lexi.json is now seen and its open files expanded
    again. Each confirmed by brls's tests (internal/dialect markers_test.go, internal/lexi
    apply_test.go, internal/lsp lexidialect_test.go)."
  - "§The dialect file (owner, 2026-11-20): added that the dialect also governs Add and Strip Line
    Numbers and the Lexi snippets; that a refused file is an error on the file itself, not only a
    line in the output; that the file is watched wherever it is and otherwise looked at every two
    seconds; that the first folder of a multi-folder workspace is the one used; that the file belongs
    in version control with the programs, since Compile uses it; and that with the original Lexi in
    use it is not read, with the three keys that give the original's expansion from brls's Lexi.
    Each confirmed by brls's tests (internal/lsp lexidialect_test.go, outbound_test.go,
    origlexi_test.go)."
  - "§#SELECT# (owner, 2026-11-20): the nested example's inner subject is Sub$, not Sub: it is
    compared with the string \"a\", so in BR it must be a string variable. The other examples were
    checked for the same string/number mismatch; none had one."
---
**Lexi** is a preprocessor for BR source. It lets a program be written **without line numbers**
and with a handful of constructs BR does not have, and expands it into plain, numbered BR before
BR loads it. It is built into **brls**, the BR language server: there is nothing to install beyond
brls, and it needs no copy of BR to expand a file.

```
! #AUTONUMBER# 1000,10
let Total=0
#SELECT# Mode #CASE# 1 # 2
   print "one or two"
#CASE ELSE#
   print "other"
#END SELECT#
```

becomes

```
01000 ! #AUTONUMBER# 1000,10
01010 let Total=0
01020 if Mode = 1 or Mode = 2 then  ! #SELECT# Mode #CASE# 1 # 2
01030    print "one or two"
01040 else  ! #CASE ELSE#
01050    print "other"
01060 end if  ! #END SELECT#
```

<a id="how-it-runs"></a>
## How it runs

**Which files are Lexi.** A Lexi file has the same `.brs`/`.wbs` suffix as BR source, so brls
decides from the contents: a file containing a Lexi construct, or with no numbered line at all, is
Lexi. A marker inside a string literal does not count; one inside a `!` comment does. The markers
are the select directives (`#SELECT#`, `#CASE#`, `#CASE ELSE#`, `#END SELECT#`), the `#DEFINE#`
directive, the `[[` that opens a macro reference, and a backtick at the head of a line. They are the
dialect's own spellings: with a [dialect file](#customizing) that renames `#SELECT#` or `#DEFINE#`,
the new word marks a file as Lexi and the shipped one no longer does, and a construct whose rule the
dialect does not run marks nothing. Choose words as distinctive as the shipped ones: a token that
ordinary BR also contains would make ordinary BR files Lexi.

**Numbering or not.** A file whose first non-blank line is numbered keeps its numbers and has only
its constructs expanded. Otherwise every line is numbered.

**In the editor**, brls checks a Lexi file as the BR it expands to: diagnostics, navigation,
rename, completion, hover and the rest work on the expansion, with every position mapped back to
the line and column typed. Text Lexi writes counts as part of the construct it was written for, so
an edit that would change it, such as a rename reaching into a `#DEFINE#` value, is refused.

| Command | Key (VS Code) | What it does |
|---|---|---|
| *BR: Show Lexi Expansion* | — | Opens the BR the file expands to. |
| *BR: Compile with BR* | `Ctrl+Shift+B` | Expands the file and has BR compile the expansion. BR's errors are reported on the source lines they came from. `br.compile.onSave` does this on every save. |
| *BR: Add Line Numbers* | `Ctrl+Alt+3` | Numbers the lines, as the expansion numbers them (with the dialect's own numbering words: see [The dialect file](#customizing)), and does nothing else: constructs stay as typed. |
| *BR: Strip Line Numbers* | `Ctrl+Alt+4` | Removes the numbers again. A file numbered and then stripped comes back as it was. Warns when the file branches to a line number. |

**From the command line**, `brls -check <file> -sema` checks a Lexi file the same way, reporting
source positions and the BR line number Lexi gives each line.

**The original Lexi instead.** In VS Code, with the `crs-dev.vslang-br` extension installed and
disabled, brls uses that extension's `lexi.br` (see [legacy_lexi.md](legacy_lexi.md)) rather than
the Lexi this page describes. *Show Lexi Expansion* and *Compile with BR* run `lexi.br` itself,
which writes no line-count markers; the checks as you type expand the file as `lexi.br` does, and
report Lexi source in error as a warning, since `lexi.br` acts on it. brls runs `lexi.br` on Windows
only. Where it cannot run it, those two commands report that, and do not fall back to brls's Lexi.

<a id="syntax"></a>
## Constructs

Each source line goes through these steps in this order, then is numbered. A construct is found
only outside `"…"` and `'…'` literals, unless the step says otherwise.

**Source in error is reported and left alone.** Anything Lexi-specific that is written wrongly —
each case is listed under its construct below — is an error in brls, on the line it is on, and
the expansion leaves it as written instead of acting on it.

### `X$&="..."` — append

`&=` becomes `(inf:0)=`, BR's append to the end of a string, every time it occurs on the line.

```
let A$&="tail"        →   let A$(inf:0)="tail"
```

### `!_` — join with the next line

The line is cut at `!_`, anything after it is dropped, and the next line, trimmed, follows after a
space. It repeats while the joined line has another `!_`. A `!_` on the last line of the file is an
error, and is left as written.

```
print "long" !_ dropped
   "part"             →   print "long" "part"
```

### Continuation — a line ending in an operator

A line whose code ends in `=`, `+`, `-`, `+=`, `-=`, `*`, `/`, `,`, `&`, `(`, ` and` or ` or`
(any case, the comment left out) goes on to the next line, which is trimmed and joined after a
space; this repeats while the joined code still ends in one. Comments taken off the joined lines
are put back at the end, after `!`.

What counts as code:
- **Strings are tracked**: a `!` inside a `"…"`, `'…'` or backtick string is not a comment, and an
  apostrophe inside a string does not hide one. `let A$="it's"& ! note` ends in `&`.
- **A `!` is a comment unless `:` or `_` follows it.** A line ending in `!:` is a BR continuation,
  not an operator one, and is left to BR — unless the code before the `!:` ends in one of the
  operators above, the comma included. BR rejects that (`let X=1+ !:` is error 1026, `let A$="a"&
  !:` is 1030), so Lexi takes it as an operator continuation: the `!:` is left out and the next
  line joined, `let X=1+ !:` and `2` becoming `let X=1+ 2`. An operator at the start of the line
  after the `!:` (`let X=1 !:` then `+2`) is BR's own continuation, and left as written.
- **Block comments are not code.** A closed `/* … */` is skipped, a line that opens one without
  closing it is not continued, and a line inside one has code only after its `*/`. So comment text
  ending in `*` or `/`, and a line ending in `*/`, are never joined to the next line.

```
let T=1+
   2 ! two            →   let T=1+ 2!  two
```

A statement still continuing when the file ends is an error, reported on its first line; its
lines are written as they are, unjoined.

### `` `...` `` — template strings

A string between backticks, outside literals and comments, becomes a `"…"` literal:

- `{{expr}}` inserts a value: `"&expr&"` for a string expression, otherwise `"&str$(expr)&"`. An
  expression is a string one when it begins with a string literal or a name ending in `$` (a
  variable, element, substring, or a function such as `fnName$`), since BR does not mix the two
  types: `{{A$(1:2)}}` and `{{"x"&B$}}` are inserted as they are, `{{len(A$)}}` and `{{N}}` with
  `str$( )`.
- The `}}` must be in the same string. A `{{` with no `}}` before the string closes is an error,
  and is left as text: ``print `Total {{N`;`, done}}` `` becomes `print "Total {{N";", done}}"`.
- A `"` inside becomes `""`, and a doubled backtick is one backtick.
- The string may run onto later lines: each line break becomes `"&hex$("0d0a")&"` (CR LF) and the
  next line is trimmed. A string never closed is an error, and its line is left as written.
- A backtick inside a block comment is comment text, not a string.

```
let M$=`Hi {{Name$}}, you are {{Age}} ``q```
   →   let M$="Hi "&Name$&", you are "&str$(Age)&" `q`"
let N$=`one
   two`               →   let N$="one"&hex$("0d0a")&"two"
```

### `/* ... */` — block comments

A `/*` in code (not in a string, not after a `!` comment) starts a comment, which ends at the next
`*/`, on the same line or a later one. The code on a line stays where it is and the comment text
follows it after `!`:
- The opening line is written as its code, then `!` and the comment text.
- Each line wholly inside the comment has ` ! ` put in front.
- The closing line is written as its code (what follows the `*/`), then ` ! `, then the comment
  text.

```
/* open                  ! open
inside            →       ! inside
close */ let Z=1          let Z=1 ! close

let A=1 /* note */        let A=1 ! note
/* one line */            ! one line
```

Comment text is never joined to the next line, whatever it ends in (see Continuation). A `/*` that
no later line closes, and a `*/` in code with no `/*` open, are errors, and are left as written.

### Indented comments

A line that is only a comment, with its `!` indented three or more columns, has its first four
columns replaced by ` ! .` (a `!` among them is kept). When BR lists a program it indents
statements and left-justifies comments unless a comment begins with a period, so the `.` keeps the
comment indented. The line straight after one ending in `!:` is left alone.

```
   ! three            →    ! .! three
      ! six           →    ! .  ! six
```

<a id="define"></a>
### `#DEFINE# [[name]] = text` — substitutions

```
! #DEFINE# [[Max]] = 10
let X=[[Max]]+[[max]] : print "[[Max]] of [[Max]]" ! up to [[MAX]]
   →   let X=10+10 : print "10 of 10" ! up to 10
```

- **The directive** is found outside string literals, so it is normally written in a comment. One
  inside quotes defines nothing.
- **The name** is everything from `[[` to `]]`, brackets included, and matches in any case.
- **The text** is the rest of the line, trimmed. A leading `=` is dropped, and so are quotes around
  the whole text: `[[Q]]="quoted"` substitutes `quoted`.
- **Every reference** on every later line is replaced: in code, in string literals and in comments.
- Names are applied in the order they were defined, so a name used inside an earlier name's text is
  replaced too. A text containing its own name is expanded once, not again.
- **Errors**, each left as written or ignored: a `#DEFINE#` with no `[[name]]`; a name defined a
  second time (the first definition stands); and a `[[name]]` that no earlier `#DEFINE#` defines.
  On a `#DEFINE#` line the name being defined is never replaced.

<a id="select"></a>
### `#SELECT#` … `#END SELECT#` — case branches

| Source | Becomes |
|---|---|
| `#SELECT# subject #CASE# value` | `if subject = value then  ! ` + the original line |
| `#CASE# value` | `else if subject = value then  ! ` + the original line |
| `#CASE ELSE#` | `else  ! ` + the original line |
| `#END SELECT#` | `end if  ! ` + the original line |

- **Several values** are separated by `#`: `#CASE# 1 # 2` tests `subject = 1 or subject = 2`.
- **A `#SELECT#` can be part of a `#CASE#`.** `#SELECT#`s nest to any depth: each `#CASE#`,
  `#CASE ELSE#` and `#END SELECT#` belongs to the innermost `#SELECT#` open, and once that one is
  closed the outer one goes on. The result is nested `if` blocks:

  ```
  #SELECT# Mode #CASE# 1               if Mode = 1 then  ! #SELECT# Mode #CASE# 1
     #SELECT# Sub$ #CASE# "a"             if Sub$ = "a" then  ! #SELECT# Sub$ #CASE# "a"
        print "1a"                           print "1a"
     #CASE ELSE#                   →      else  ! #CASE ELSE#
        print "1 other"                      print "1 other"
     #END SELECT#                         end if  ! #END SELECT#
  #CASE# 2                             else if Mode = 2 then  ! #CASE# 2
     print 2                              print 2
  #END SELECT#                         end if  ! #END SELECT#
  ```
- The tokens match in any case. Inside a `!` comment they are comment text.
- **Errors**, each left as written: a `#SELECT#` without its first `#CASE#` on its line, with
  nothing to test, or that no `#END SELECT#` closes — and with it the `#CASE#`, `#CASE ELSE#` and
  `#END SELECT#` lines that belong to it; and a `#CASE#`, `#CASE ELSE#` or `#END SELECT#` with no
  `#SELECT#` open.

<a id="numbering"></a>
## Line numbers

**Defaults.** Numbering starts at `00001` and counts by 1. Numbers are written with five digits and
a space.

**`! #AUTONUMBER# <number>,<step>`** numbers its own line `<number>` and the lines after it by
`<step>`. A number the lines before it have already reached is handled as numbers that do not fit
(below).

A directive is an error, and is ignored whole, when it is not `<number>,<step>` with nothing after
the step (`3000,5 resume here`, or `3000` with no step), when the number is not 1 to 99999 or the
step is less than 1, or when the number is not greater than the previous directive's.

**Lines that already have a number** keep it: a line that begins, after any blanks, with one to
five digits followed by a blank or the end of the line.

**`!:` lines.** The line after one ending in `!:` belongs to the same BR line, and is indented six
spaces instead of numbered, whatever it begins with: `+12` there is part of an expression, not a
line number.

**Blank lines** become a numbered blank comment, `NNNNN  !`.

**Joined lines.** A line taken in by a join (`!_`, continuation, a template string running on)
still uses up its number, so the numbers after it are those the lines would have had unjoined.

**`L#####` labels.** A line beginning `Lnnnn:` is a hint: numbering jumps to `nnnn` when it is still
ahead, and the step becomes 10 when `nnnn` is a multiple of 10. A label whose number has already
been reached is numbered on, the step is halved (never below 2) to catch up with the labels after
it, and brls notes the number it took.

**When the numbers do not fit**, between one `#AUTONUMBER#` and the next or before 99999, Lexi does
not stop:

1. That section is numbered again one step smaller, down to 2. Other sections are not disturbed.
2. If it still does not fit, its `#AUTONUMBER#` is not applied: the section is numbered on from the
   previous directive, the two as one run, starting from the larger of their steps and shrinking
   again to 2. This repeats, a directive further back each time.
3. Step 1 is used only once that has reached the top of the file. A directive that asks for step 1
   keeps it.

brls reports each section numbered differently from its directive. A file that cannot be numbered
even at step 1 cannot be expanded.

<a id="line-markers"></a>
## Line-count markers

BR counts physical lines as it loads a file, and names a line by that count in its messages. A
join makes the expanded file shorter than the source, so after each statement that took in more
than one source line, Lexi writes a marker, `!#-NN`, at the end of the statement's last line. BR
reads it, adds NN to its count from there on, and removes the marker from the stored source, so the
line BR names is the line of the Lexi source.

```
let T=1+
   2                  →   00002 let T=1+ 2 !#-01
```

*Compile with BR* always writes them. *Show Lexi Expansion* writes them unless
`br.lexi.lineMarkers` is off. BR reads two digits.

<a id="limits"></a>
## Line length

An expanded line is written whole, however long. BR 4.2 and later accept a line of up to 2000
characters ([syntax — line length](../../10-language/syntax/spec.md#line-length)), and brls reports
a longer one.

<a id="dialect"></a>
## The dialect file

Everything Lexi *recognises* and everything it *writes* comes from one JSON file, the **dialect
file**, `lexi.json`. brls carries a copy inside itself, and reads one of your own instead when a
project has it (see below). The file does two things: it spells every token, operator and inserted
keyword, and it lists which steps run and in what order. The steps themselves, what "continuation"
or "select" *does*, are code.

Besides the rules (below), a dialect may set:

| Key | Meaning |
|---|---|
| `name`, `description` | Labels. Nothing reads them. |
| `recordLength` | Write each line in records of this length, a longer line going on in the next record. `0`, the default, writes lines whole. |
| `define.firstOnly` | Replace only the first reference to each `#DEFINE#` name on a line. `false` by default. |
| `legacy` | Reproduce the original `lexi.brs` exactly: its handling of comments in continuation, block comments, `{{…}}` types and limits, `!:` lines, already-numbered lines and select directives in comments, and what it does with source in error (brls then warns instead of objecting). `false` by default. |
| `lineMarker` | `prefix` (`!#`), `digits` (`2`) and `separator` (`" "`) of BR's [line-count markers](#line-markers). Not a rule: it describes the expansion, not the source. `prefix` and `digits` must be set. |

<a id="customizing"></a>
### Customizing the preprocessor

Lexi is a convention you can change. The `#DEFINE#` words, the `&=` append, the `!_` join, the
backtick strings, the comment forms, the way a `#SELECT#` becomes `IF … ELSE IF`, even the label
that numbering reads, are all *spellings* in `lexi.json`. If your shop writes BR differently, you
do not have to write BR the way the shipped dialect does: choose your own spellings, switch off the
steps you do not want, and let the preprocessor turn what you write into the BR that BR reads. A
team can settle on its own house conventions (its own directive words, its own shorthand for
appending or continuing a statement, its own comment style) and have every program written that way
expand the same way, in the checks and in *Show Lexi Expansion* and *Compile with BR* alike.

What a dialect can change is the **spelling**, not the **behaviour**. A new token for an existing
step is a data change; a step that does something Lexi has no step for is a change to brls's
source (`internal/lexi/apply.go`).

**How to change it.** brls reads the dialect file while it runs. It uses, in this order:

1. the file named by the `br.lexi.dialect` setting (a path, relative to the workspace folder);
2. `lexi.json` in the workspace folder;
3. the dialect built into brls, when there is neither.

In a workspace of several folders, "the workspace folder" is the first of them.

The file is read again when it changes, so saving an edit to it changes what Lexi recognises and
writes for the next expansion: the Lexi files that are open are expanded and checked again, which
files count as Lexi is decided again, and *Show Lexi Expansion* and *Compile with BR* use it, without
restarting anything. Creating the file and deleting it are seen the same way. brls watches the file,
wherever it is; where the editor cannot watch it, brls still looks at it at most every two seconds.

The dialect governs everything brls does with Lexi, not only the expansion: which files are Lexi (see
*Which files are Lexi*), the numbers *Add Line Numbers* writes and the ones *Strip Line Numbers* takes
off (`autonumber`: the directive, the label, the indent of a continued line, a blank line), and the
words the Lexi snippets insert, which are not offered for a rule the dialect does not run.

**Keep the file with the source.** *Compile with BR* compiles the expansion, so a program is compiled
differently under a different `lexi.json`. Keep the file in version control beside the programs it
belongs to. Other tools, the original Lexi among them, do not read it.

**The original Lexi has no dialect file.** With the original Lexi in use (*How it runs*), a project's
`lexi.json` is not used, and brls says so once in its output. To get the original's expansion from
brls's own Lexi instead, a dialect file can set the three keys that make up the difference:
`"legacy": true`, `"recordLength": 800` and `"define": {"firstOnly": true}`.

The VS Code extension carries a copy of the shipped `lexi.json` for you to start from. Run
**BR: Create lexi.json (Lexi dialect) in the Workspace** and it puts the copy in the workspace folder
and opens it; an existing `lexi.json` there is opened and never overwritten. From the command line,
`brls -workspace <folder>` uses the `lexi.json` in that folder, or `brls -workspace <folder> -lexi
<file>` a file of your choosing, and says which it used.

**The file holds only what you change.** brls reads it on top of the shipped dialect: a key it
leaves out keeps its shipped value, so `{"concat": {"find": "<<="}}` on its own is a whole dialect,
and a file written for an earlier brls still has the keys added since. A list the file gives, such as
`rules` or `continuation.operators`, replaces the shipped list whole.

1. Start from the shipped file. Change one thing at a time.
2. Save, and look at a small source file with *Show Lexi Expansion*.
3. If the file is not a dialect, brls says why and uses its own dialect until you fix it. In the
   editor that is an error on the dialect file itself, placed at the key, rule or character it is
   about, which goes when the file is fixed (a file the setting names that does not exist is said in
   a message instead); from the command line it is an error and the report is not made.

A dialect is refused, with the reason, when a rule it lists is not one of those below (`unknown rule
"concatt"`), is listed twice (`rule "concat" is listed twice`), or blanks a token that rule needs
(`rule "continuation" needs continuation.operators`); when it names a key no dialect has, which is
almost always a misspelling (`json: unknown field "contination"`); or when it is not valid JSON.
`lineMarker` needs its `prefix` and `digits`.

**Example: your own spellings.** Changing two tokens in the file

```json
"concat": { "find": "<<=", "replace": "(inf:0)=" },
"define": { "directive": "#SET#", "open": "[[", "close": "]]", "firstOnly": false },
```

makes `<<=` the append operator and `#SET#` the substitution directive. With that `lexi.json` in the
workspace folder this source is clean:

```
! #SET# [[n]] = 5
print [[n]]
let x$<<="a"
```

and expands to `print 5` and `let x$(inf:0)="a"`. Under the shipped dialect the same source is
reported as errors (`[[n]]` is not defined, `<<` is unexpected), since `<<=` and `#SET#` mean
nothing there. Directives such as `#DEFINE#` and `#AUTONUMBER#` are written in a `!` comment, as
the sections above show; the dialect changes the word, not that.

<a id="dialect-rules"></a>
**The rules, and what each reads.** `rules` is the list of steps that run, in the order they run
(the shipped order is the one below); leave a step out and it does not run. Each step reads only the
keys under its own name:

| Rule | Keys | What they say |
|---|---|---|
| `concat` | `find`, `replace` | The append operator: every `find` on a line becomes `replace` (`&=` → `(inf:0)=`). |
| `lineWrap` | `marker` | The mark that joins a line with the next (`!_`). |
| `continuation` | `operators` | The list of endings that continue a statement on the next line (`=`, `+`, `-`, `+=`, `-=`, `*`, `/`, `,`, `&`, `(`, ` and`, ` or`). |
| `templateString` | `delimiter`, `open`, `close`, `lineBreak`, `stringOpen`, `stringClose`, `numericOpen`, `numericClose` | The backtick string. `delimiter` quotes it; `open` and `close` (`{{`, `}}`) mark an inserted expression; `stringOpen`/`stringClose` (`"&`, `&"`) are written round a string expression, `numericOpen`/`numericClose` (`"&str$(`, `)&"`) round a numeric one; `lineBreak` is what a line break inside the string becomes. |
| `blockComment` | `open`, `close`, `comment`, `inside`, `closing` | The block comment (`/*`, `*/`), the BR comment mark it is turned into (`!`), and the text put before a line inside it and before the comment text on the closing line. |
| `commentIndent` | `replace`, `width` | The first `width` columns of an indented comment line are replaced by `replace` (` ! .`). |
| `defineApply`, `define` | `directive`, `open`, `close`, `firstOnly` | The substitution directive (`#DEFINE#`) and the brackets that mark a name (`[[`, `]]`); `defineApply` is the step that replaces the names, `define` the step that reads the directive, and both read the same keys. |
| `select` | `select`, `case`, `caseElse`, `end`, `separator`, then `if`, `elseIf`, `or`, `equals`, `then`, `else`, `elseComment`, `endIf`, `endComment` | The case directives (`#SELECT#`, `#CASE#`, `#CASE ELSE#`, `#END SELECT#`, and the `#` between the values of one case), and the BR written for them (`if `, `else if `, ` or `, ` = `, ` then  ! `, `else `, ` ! `, `end if`, `  ! `). The first five are required. |
| `autonumber` | `directive`, `labelPrefix`, `labelWidth`, `labelStep`, `continued`, `blank` | The numbering directive (`#AUTONUMBER#`), the label form (`L` and a number of this width) and its step, the indent of a continued line, and what a blank line becomes (`  !`). The `directive` is required. |

The order matters because each step sees what the earlier steps wrote. Keep the shipped order
unless you have a reason: it is the one the shipped tests hold byte for byte to the original Lexi.

**Check what you changed.** The shipped dialect is held to the original `lexi.brs` by tests over
a large body of real programs. A dialect of your own is held to nothing but what you check: keep a
few source files that use each construct you changed, and look at their expansion after each edit
(`brls -workspace` over that folder reports anything that no longer expands to valid BR).

<a id="reports"></a>
## What brls reports

| Report | Severity |
|---|---|
| Lexi source in error (listed under each construct above), left as written | error |
| An expanded line over 2000 characters | error |
| A file that cannot be numbered even at step 1 | error |
| An `L#####` label numbered past its number | information |
| A section numbered at a smaller step, or on from an earlier directive | information |

<a id="see-also"></a>
## See also

- [Installation & tooling — Lexi preprocessor](spec.md#lexi-preprocessor) — the category summary.
- [Legacy Lexi](legacy_lexi.md) — the original `lexi.brs` program, its editor tools and how they
  were installed.
- [syntax — line length](../../10-language/syntax/spec.md#line-length) — BR's line-length limit.
- [MyEdit_(BR_Edition)](MyEdit_(BR_Edition).md) — the first editor Lexi was integrated with.
