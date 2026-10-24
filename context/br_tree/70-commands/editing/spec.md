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
keywords: [EDIT, LIST, AUTO, RENUM, DEL, SOURCE, CLAUSES, NOEJECT]
corrections:
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
  separate full copy). Deleted lines leave reclaimable space: save to source and reload to recover
  ~100 bytes of object per 7 deleted lines.
- <a id="list"></a>**LIST** shows lines with BR's canonical formatting (5-digit numbers, upper-cased
  keywords); edit directly on a listed line and press Enter on that line to store it. After a `RUN`
  you must `LIST` again before editing. (`LIST "string"` instead *searches/replaces* — see
  [information](../information/spec.md#list-search).)
- <a id="list-options"></a>**LIST options.** **`-P`** pauses after **each line**; at the pause a
  digit from 2 to 9 lists the next that many lines before pausing again, any other key lists one
  more, and Ctrl-A stops. **`-<line>`** and **`<line>-`** list the screenful ending, or starting, at
  that line — what PgUp, PgDn and F6 type for you. **`CLAUSES`** marks where each clause begins, for
  `line:clause` references in `BREAK` and `GO`. **`PRINT`** lists to the printer, ending with a
  page eject unless **`NOEJECT`** is given; `>printer-name` lists to a named printer.
- <a id="list-input"></a>**`LIST <program`** lists the program saved in a file instead of the one in
  memory, which is left as it is. The `<` is written against the name (`LIST <menu`, or quoted
  `LIST <"my prog"`); a name with no extension is tried with `.br` and then `.wb`. The file must be a BR
  program file, else error **4122**; a second `<` is error **2220**. Line numbers separated by a
  blank may limit it, but a `-` range or a label with `<` is a syntax error. At the `READY` prompt,
  Tab completes the name after the `<` — see
  [filename-patterns](../file-directory/filename-patterns.md#tab-completion).
- <a id="edit"></a>**EDIT** (`ED`) hands the current program to a configured third-party editor
  (`EDITOR` in BRConfig.sys; without one, error **9307**). `EDIT <program>` loads the program
  first. `EDIT -` opens the last edit's file again without listing the program afresh, and `EDIT ~`
  takes that file back in without opening the editor at all.
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
