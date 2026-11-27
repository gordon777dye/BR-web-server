---
title: Program editing commands
file: spec.md
source: §Commands → Program Editing Commands
category: 70-commands
subcategory: 70-commands/editing
kind: spec
status: 2b           # reference base + br_tree fold (EDIT, AUTO proc-restriction/restart, DEL SOURCE, abbreviations); no conflicts
recovered-fold: RENUM (folded+pruned — LABELS_ONLY 4.18a, segment reorder, collision/99999 errors; verbatim retained on the BR wiki)
related: [program-management, information]
keywords: [EDIT, LIST, AUTO, RENUM, DEL, SOURCE, CLAUSES, NOEJECT, XREF]
corrections:
  - "2026-11-24, from BR 5.03's source (tblcmd.cpp table2k XREF -> XREF, a token value no command's qualifier switch tests) and a headless `LIST XREF` (error 1006): the `xref` note under LIST options, and XREF added to the keywords."
  - "From the BR 5.0 parsers (see br50 br/docs/FLAGS.md), 2026-10-21, source reading not yet confirmed by a run: LIST's -P (a pause after each line, and a digit there lists that many), -n / n- paging, CLAUSES and NOEJECT documented (command9.cpp LIST); EDIT's program, - and ~ forms documented (commandc.cpp editCommand()); pointer to the new `-?` command help added."
  - "SOURCE added to the frontmatter keywords. `DEL … SOURCE` is in this page's BNF and semantics, and was not declared. Found in brls phase 13."
---

# Program editing commands

Entering and editing program source in memory: auto line numbering, renumbering, deleting and
listing lines. Loading/saving the program is in
[program-management](../program-management/spec.md). Each command has a short abbreviation (shown
below).

<a id="syntax"></a>
## Syntax

```bnf
<line-range> ::= <starting-line> <ending-line>
AUTO  [<start-line>] [{','|' '} <increment>]      -- AU; default 10, 10
RENUM [-<from>] [-<to>] [<first>] [<incr>] [LABELS_ONLY]   -- RENU; updates GOTO/GOSUB references
DEL   { <line> | <start-line> <end-line> } [SOURCE]   -- DE; delete line(s)
LIST  [<line-range>]                              -- LIS; display/edit; edit a listed line + Enter
LIST  '<'<program-file> [<line> [<line>]]         -- list a saved program without loading it
LIST  [<range>] [-P] [CLAUSES] [PRINT [NOEJECT] | '>'['>'] <file>]   -- options, below
LIST  { -<line> | <line>- }                       -- the screenful ending, or starting, at <line>
EDIT  [ <program> | - | ~ ]                       -- ED; open the program in a third-party editor
```

Each of these commands lists its forms and options when given
[`-?`](../program-management/spec.md#command-help) alone (`LIST -?`, BR 5.0).

<a id="semantics"></a>
## Semantics

- <a id="auto"></a>**AUTO** supplies line numbers as you type (separate start/increment with a space
  *or* a comma). It stops when a line is left blank, you change/erase the supplied number, you move
  the cursor off the line, or the number would exceed 99999. **AUTO cannot be used in a procedure
  file.** You can stop and restart `AUTO` with a new start number to insert lines mid-program;
  regenerating an existing line number *replaces* that line (terminating `AUTO` on an existing
  number leaves it intact).
- <a id="renum"></a>**RENUM** renumbers lines and **rewrites all line references**
  (`GOTO`/`GOSUB`/etc.); it can also reorder a *segment* into place (`RENUM -245 -365 250`), and errors
  if a target number already exists or would exceed 99999. **`LABELS_ONLY`** (4.18a) instead converts
  line *references* to label references (a ref to line 1220 becomes `L01220`; the line may then be
  renumbered yet keep that label) — the basis of Lexi's number-free editing.
- <a id="del"></a>**DEL** removes a line or inclusive range (in memory only until `SAVE`/`REPLACE`;
  gaps are fine). **`DEL … SOURCE`** deletes only the *source* text, keeping the compiled object —
  used to hide source for security; the program then **cannot be reloaded from source** (keep a
  separate full copy). Deleted whole lines leave reclaimable space: save to source and reload to recover
  ~100 bytes of object per 7 deleted lines.
- <a id="list"></a>**LIST** shows lines with BR's canonical formatting (5-digit numbers, keywords 
  formatted per STYLE configuration statement); edit directly on a listed line and press Enter on 
  that line to store it. After a `RUN` and another ATTN, up and down arrows and PgUp/PgDn resume 
  listing. `LIST "string"` *searches* for matching lines — see
  [information](../information/spec.md#list-search). Several variants are available.
- <a id="list-options"></a>**LIST options.** **`-P`** pauses after **each line**. Any key lists one
  more, PgUp/PgDn work, and Ctrl-A stops. **`-<line>`** and **`<line>-`** list the screenful 
  ending, or starting, at
  that line — what F5 and F6 type for you. **`CLAUSES`** marks where each clause begins, for
  `line:clause` references in `BREAK` and `GO`. **`PRINT`** lists to the printer, ending with a
  page eject unless **`NOEJECT`** is given (the old wiki called this `SKIP`); `>printer-name` lists 
  to a named
  printer. `LIST PRINT` uses the printer's initialization escape sequences.
  <a id="xref"></a>**`XREF` is not an option.** It is still in BR's qualifier table (`table2k`), but
  no command reads it, so `LIST XREF` is error **1006** (syntax error). *Measured, 5.03 headless.*
- <a id="list-output"></a>**Where `LIST` writes.** The screen by default. **`>file`** writes the 
  listing to a file
  (created, as source: `LIST 500 1350 >B:\OUTPUT.BRS`) and **`>>file`** appends to one; **`PRINT`** goes to the
  printer. A single line number with `>file` redirects **only that line** (before, it redirected from that line to the
  end of the program: this can affect an old application). `PRINT` is different on the screen's one-line rule:
  it prints every line from the start of the program to its end, not just the one named. A listing in a file can
  be `LOAD`ed from source, which is how a change made while a program runs is kept.
- <a id="list-scroll"></a>**Scrolling the screen listing.** The up and down arrows and PgUp/PgDn scroll to lines above
  and below those shown. Pressing the period key (`.`) just before an arrow stops the scroll from going past the
  lines displayed.
- <a id="list-forms"></a>**The forms, and what each lists.** `LIST` alone scrolls the whole program; `LIST <n>` one line;
  `LIST <n> <m>` lines `n` to `m`; `LIST -<n>` a screenful ending at `n` and `LIST <n>-` one starting at it; a line
  number can be a **line label**. With `<program` (below) the lines come from a program file, and the same
  line limits and search strings work on it: `LIST <PROGNAME.BR 5000,6000`, `LIST <PROGNAME.BR "OPEN"` and
  `LIST <PROGNAME.BR >TEMP.BRS`. Because it reads the source out of the file, `LIST <PROGNAME >TEMP.BRS` converts a
  program saved by any release of BR to source, which is how programs are moved between major releases.
  `-P` works with `<program` as well: `LIST <TEMP -P`. For searching (`"string"`, `'string'`, `~`, `REPLACE`) see
  [LIST "str"](../information/spec.md#list-search).
- <a id="list-input"></a>**`LIST <program`** lists the program saved in a file instead of the one in
  memory, which is left as it is. The `<` is written against the name (`LIST <menu`, or quoted
  `LIST <"my prog"`); a name with no extension is tried with `.br` and then `.wb`. The file must be a BR
  program file, else error **4122**; a second `<` is error **2220**. Line numbers separated by a
  blank may limit it, but a `-` range or a label with `<` is a syntax error. At the `READY` prompt,
  Tab completes the name after the `<` — see
  [filename-patterns](../file-directory/filename-patterns.md#tab-completion).
- <a id="edit"></a>**EDIT** (`ED`; BR 4.15+) hands the current program to a configured third-party editor
  (the [`EDITOR`](../../00-configuration/config-directives/spec.md#editor) statement, in BRConfig.sys or as
  `CONFIG EDITOR`; without one, error **9307**; `STATUS CONFIG` shows whether one is set). `EDIT <program>` loads the
  program first. `EDIT -` opens the last edit's file again without listing the program afresh, and `EDIT ~`
  takes that file back in without opening the editor at all. What it does:
  1. **Lists** the program to a source file named `<program>.brs`, in the folder the program was loaded from
     (a program with no name gets `MySpace.brs`). With `OPTION 73` on the name is `<program>-<WSID>.brs`, so that
     two workstations editing one program do not share a file.
  2. **Starts the editor** and gives it focus.
  3. After you save in the editor, press **Enter** in the BR window, or type `EDIT ~`, and BR **merges the changed
     lines** into the program. With `EDITOR ... NOWAIT` BR does not wait for Enter, only for the editor to return
     (which suits simple editors such as Notepad; many good editors return at once, so `NOWAIT` does not apply to
     them). With `EDITOR ... REMOVE` the `.brs` file is deleted once the merge succeeds, and `EDIT -` cannot then
     recover it.
  The merged text is sorted and checked: **duplicate line numbers are error 1156**. If a merge stops on an error,
  correct the line and type `GO`: the merge carries on. If `EDIT` is issued after an unsuccessful merge instead of
  `GO`, the editor is given the most recent edited work file. **Do not use the Tab key** in the editor: BR gives an
  error on a line that holds one. Editors that handle `.brs` source are listed at
  [`EDITOR`](../../00-configuration/config-directives/spec.md#editor).
- <a id="builtin-keys"></a>**Built-in editor keys**: BR's own line editor is active at startup (just
  type). **F7** marks then copies the marked span to a scratch buffer ("*x* Bytes Saved"); **F8**
  marks/moves (cut), or pastes the buffer at the cursor when no mark is active (re-pasteable). A line
  edit isn't stored until **Enter**; removing a line still requires `DEL` (typing over it or erasing
  characters does not). **INS** toggles insert mode (reverts on arrow/Enter). **Ctrl-A** interrupts a
  running program into ATTN mode (where `LIST`, edits, `STEP`/`TRACE`, and value changes work; `GO`
  resumes). Most lines can be edited mid-run during ATTN/ERROR/STEP. *(Configure the external editor
  and `LIST`/indent style via [00-configuration/config-directives](../../00-configuration/config-directives/spec.md#config):
  `EDITOR`, `STYLE`.)*

<a id="examples"></a>
## Examples

```text
AUTO 1000 50          ! number from 1000 by 50
RENUM -330 -480 500   ! renumber lines 330-480 starting at 500
DEL 20 60             ! delete lines 20 through 60
DEL 100 200 SOURCE    ! strip source for 100-200, keep object (security)
LIST 100-200
LIST <menu 100 500    ! lines 100-500 of menu.br on disk; memory untouched
```

<a id="see-also"></a>
## See also

- [program-management](../program-management/spec.md) — `LOAD`/`SAVE`/`REPLACE`/`RUN`, `MERGE`
- [information](../information/spec.md#list-search) — `LIST "search"`/REPLACE, STEP/TRACE debugging
- [10-language/syntax](../../10-language/syntax/spec.md) — line numbers & labels being edited
- [file-directory/filename-patterns](../file-directory/filename-patterns.md#tab-completion) — Tab completion of file names at `READY`, `LIST <` and `LIST >` included

*(Backing keyword pages `Editing_Commands`, `AUTO`, and the misfiled `Delete_(command)` were folded
into this spec and pruned.)*
