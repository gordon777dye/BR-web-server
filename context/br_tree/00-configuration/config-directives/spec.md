---
title: BRConfig.sys directives
file: spec.md
source: §Configuration (BRConfig.sys); br_tree DRIVE folded into #paths (2b, from the environment leaf)
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: spec
status: 2b           # reference base + br_tree fold (SUBSTITUTE, CONFIG mechanism, GUI/CONSOLE/INSERT/KEYBOARD/STYLE/RD/DATABASE…); deep tables retained; no conflicts
recovered-fold: PrintDir, DATAHILITE, FIELDBREAK, FLOWSTACK, FORSTACK, HELPDFLT, Min_Fontsize, BRCONFIG.SYS (8 redirect-collision pages folded from re-fetched source; verbatim retained on the BR wiki)
related: [environment, client-server, platform, installation-tooling]
keywords: [CONFIG, DRIVE, OPTION, DATABASE, SUBSTITUTE, STYLE, PRINTER, FONT, COLLATE, LOGGING, WORKPATH, PRINTDIR, SPOOLCMD, INCLUDE, SETENV, ATTRIBUTE, KEYBOARD, SCREEN, RD, STACKS, CURSOR, DATE, DIMONLY, FIELDHELP, FONTFAMILY, GRID_CURSOR_MOVE, PAGEOFLOW, PDF_READER, PRINTSCREEN, RPNSTACK, WORKSTACK, SEARCH_CHAR, SHELL, SOFLOW-GROW, STATUSLINE, TYPEAHEAD, USERLEVEL, WINDOWS_THEMES, WSID, HTTP, HTTPS, 3D_FIELDS, GRAPHIC_LINEDRAW, CONSOLE, GUI, SPOOLCMD]
corrections:
  - "2026-11-20: Reviewed every CONFIG statement against its original wiki page and the BR 5.0 handler in config.cpp, and completed the ones that listed only part of their option set. New entries: 3D_FIELDS, GRAPHIC_LINEDRAW and SPOOLCMD with its bracketed words. Expanded: APPLICATION_NAME, ATTRIBUTE (CLEAR, ESC), BASEYEAR, BREAK (second number), CHAINDFLT, COLLATE, COLOR (exactly six hex digits; the 2007-removed Y/N form), CONSOLE (OFF_WHEN_SHELLED, HISTORY), CORNERS, DATABASE (CLEAR, MAX_COLUMN_WIDTH, USER/PASSWORD forms), DATAHILITE (WIN_ON, WIN_OFF, attributes), DECIMAL (table), EDITOR, EXECUTE, FIELDBREAK, FILENAMES (NOSEARCH), FILTER_DELIMITERS, FORCE VISIBILITY, GUI (SUPPRESS, BRVB, what GUI OFF allows), HELPDFLT (CLEAR, comma), INCLUDE, INSERT, KEYBOARD (CLEAR, scancodes), MAXRECALL, MAX_SORT_MEMORY (the source accepts up to 2000; the wiki says 512), PICTURE, SCREEN, STYLE, WORKPATH ([LOGIN_NAME]). Where wiki and source differ the source is followed."
  - "2026-11-19: 23 configuration statements that BR offers under HELP CONFIG had no entry here and answered 'br_tree has no entry for X yet'. Added each, with an anchor of its own: CURSOR, DATE, DIMONLY, FIELDHELP, FONTFAMILY, GRID_CURSOR_MOVE, STATUSLINE and WINDOWS_THEMES (Screen appearance); PAGEOFLOW, RPNSTACK, WORKSTACK, S/36-MODE, SEARCH_CHAR, SHELL, SOFLOW-GROW, TYPEAHEAD, USERLEVEL and WSID (Language & I/O behavior); PRINTSCREEN and PDF_READER (Printer & spooling); HTTP and HTTPS (Web server, pointing to HTTP=SERVER). Written from the BR 5.0 source (config.cpp and the code each setting reaches) and the original BR wiki; where they differ the source is followed, as noted at STATUSLINE and CURSOR. BTREE_VERIFY was removed from BR 5.0 and is not documented."
  - "LOGGING summary corrected: the level range runs 0-15 (logger.h), not 0-13, and +CONSOLE echoes only DEBUG_STR messages, not all logging (debug.cpp:561). Added that console PRINT output is never logged, the claim the old level table made. See LOGGING.md corrections; reported in context/ERRORS.md 2026-09-28."
  - "RD and STACKS added to the frontmatter keywords. `RD <0-15>` is in this page's directive list with a retained deep page of its own (RD.md), and `STATUS STACKS` is named where the stack settings are documented; neither was declared. Found in brls phase 13."
  - "SUBSTITUTE matching rules added (#substitute-matching): match anywhere in the name, every matching entry applied in order to the previous output, case-insensitive, name/dir form, space separator, and the protect/restore technique. Confirmed on 4.33c (context/scratch/step9/subprobe*.brs). Also restored the missing opening backtick on `STATUS SUBSTITUTE`. Reported in context/lsp/ERRORS.md 2026-10-01."
---

# BRConfig.sys directives

The start-up configuration file (`BRConfig.sys`) — holds environmental settings read by
BR at launch (800 chars/line). **Configuration, not coding.** BR loads it at start-up, 
falling back to the legacy`WBConfig.sys` if `BRConfig.sys` is absent. Lines containing
errors are **listed on screen at start-up and then ignored** (their defaults apply) so a bad
directive never halts start-up. Environment-variable handling is in 
[environment](../environment/spec.md); client-server settings in
[client-server](../client-server/spec.md). Almost every directive can also be applied at runtime via
the [`CONFIG` command](#config) (and conditioned per-user with a leading `@"login"`). A `REM` line
(or `!` after a space) is a comment.

<a id="semantics"></a>
## Directives by area

<a id="paths"></a>
### Drives, files & paths
```bnf
BRSERVER <path>
DRIVE <letter>[:], <server-path>, [<client-path>], [<subdir>]
FILENAMES {UPPER_CASE|LOWER_CASE|MIXED_CASE} [SEARCH]
INCLUDE <filename>            -- nest up to 10 deep
PRINTDIR <path> [+DATE][+TIME][+LOGIN_NAME][+CHANNEL][\LOGIN_NAME][RAW]
SPOOLPATH [@[:][:]] <directory>   
SUBSTITUTE <from-string> { ',' | ' ' } { <to-string> | CLEAR }   -- see #substitute-matching
WORKPATH [<path>] [[LOGIN_NAME]]
```
- <a id="drive"></a>`DRIVE` maps a logical drive to physical paths (env variables allowed). 
   Subsequent filename references beginning with `@:` target the client, a second colon 
  (`@::C:\path` or `@::.\path`) makes the client path drive-independent (client OS paths). 
  Server filenames that begin with a colon also become drive independent (the colon is dropped). 
- <a id="filenames"></a>**`FILENAMES {UPPER_CASE|LOWER_CASE|MIXED_CASE} [SEARCH|NOSEARCH]`** controls the case of the names
  of files BR creates. `MIXED_CASE` uses the `NAME=` string exactly as written; `UPPER_CASE` and `LOWER_CASE` fold it.
  BR defaults to **lower case on every platform** unless this statement says otherwise, so name `LOWER_CASE` when a
  Windows standard-model system and a Linux/Unix client-server system share files: the two then agree on names at full
  speed. Windows file names are case-insensitive and Unix ones are case-sensitive. The extra word is read only by the
  Unix builds: `SEARCH` makes BR look for a name in another case when the exact one is not found (as Windows does),
  `NOSEARCH` goes back to exact names; elsewhere `SEARCH` is ignored. A value that is not one of the three cases is an
  error. Also settable with `CONFIG` and `EXECUTE "CONFIG FILENAMES ..."`.
- <a id="include"></a>**`INCLUDE <filename>`** reads more configuration lines from another file, as if they stood where
  the `INCLUDE` does. `<filename>` is an ordinary BR (drive-qualified) file name; if it is a full path and the `INCLUDE`
  comes before the `DRIVE` that names the drive, put a `:` in front to say it is an operating-system name. Any number of
  `INCLUDE`s may be used, nested up to **10** deep, and included files may contain any directive. In BRConfig.sys a
  relative name is taken from the folder of the file holding the `INCLUDE` (its parent); typed as a `CONFIG` command it
  is taken from the current directory. With `%USER%` (an environment variable, see [environment](../environment/spec.md))
  each user gets a file of their own: `INCLUDE %USER%` after the common lines. Not available before BR 3.9. Typical use:
  `INCLUDE PRINTER.SYS`.

<a id="printdir"></a>**`PRINTDIR <path>`** (4.3+) drops a **copy** of every spooled print file into `<path>`,
named `<active-program>.<channel>` (channel defaults to **255**). Each keyword is separate and must be
space-separated: `+DATE`/`+TIME`/`+LOGIN_NAME` append to the output base filename; `+CHANNEL` replaces
the `.prt` suffix with the OPEN channel number; `\LOGIN_NAME` files the copy under a per-user
subdirectory of `<path>`; and `RAW` stores it **untranslated** so it can later be re-`TYPE`d to any
destination with that device's own printer translation (e.g. `TYPE file PRINTER_TYPE=NWP >disk` or
`TYPE file >DIRECT:/HP`). Also settable via `CONFIG`. (E.g. `OPEN #40: "Name=PRN:/LASER2,Recl=133"`
in program `PRREG` archives a copy as `<path>\PRREG.40`.)

<a id="substitute"></a>**`SUBSTITUTE <from>,<to>`** replaces all/part of any file or path name in
commands and `OPEN` statements before execution — the core mechanism for redirecting **printer
classes** (`PRN:/nn`) to real devices/files, mapping `COM1:`→`/dev/ttyXX`, etc.
`SUBSTITUTE <from>,CLEAR` removes one entry; `CONFIG SUBSTITUTE CLEAR` clears all (except `[WSID]`).
`STATUS SUBSTITUTE` lists active entries; `FILE$(n)` shows what a channel actually opened.

<a id="substitute-matching"></a>**How entries match** (confirmed on 4.33c with `FILE$` and the
LOGGING file):
- **The from-text matches anywhere in the name**, not only at its start or at a folder boundary.
  With `SUBSTITUTE ard\ x\ard\`, `reports\standard\inv.docx` becomes `reports\standx\ard\inv.docx`.
  It also matches the start of a longer name: `SUBSTITUTE bcp\unibarf …` redirects
  `bcp\unibarfm.br` too. (The `PRN:` → `PRN:/11/12` trap in
  [Multi-spooled printers](Multi-spooled_printers.md) is the same rule.)
- **Every matching entry is applied, in the order the entries were defined, each to the previous
  entry's output.** With entries for `cod\` and then `his\`, `cod\his\x` gets both. An identity
  entry (`SUBSTITUTE standard\ standard\`) does not protect a name from a later entry.
- **Matching ignores case**: `ARD\CUSTOMER` matches an `ard\` entry.
- The `name/dir` file form is matched like any other text: a `/ard` entry redirects `customer/ard`,
  and an `ard\` entry does not.
- `<from>` and `<to>` may be separated by a space instead of the comma (`SUBSTITUTE ard\ x\ard\`).

To keep some paths out of a broad entry, rename them first and restore them last: protect
(`SUBSTITUTE standard\ st@nd@rd\`), then the redirects, then restore
(`SUBSTITUTE st@nd@rd\ standard\`). Pick placeholder text that no real name contains. Probes:
`context/scratch/step9/subprobe*.brs`; a worked scheme is in `context/app/ONBOARDING.md` STEP 9.5.

<a id="spoolpath"></a><a id="spool-work"></a>**`SPOOLPATH`** sets where print spool files (and PDFs) are staged; it
defaults to a `SPOOL\` dir off the first `DRIVE`'s BR root and is auto-created. 
<a id="workpath"></a>**`WORKPATH [<path>] [[LOGIN_NAME]]`** is where BR puts the work files it makes for a session; it defaults to the BR root.
Adding `[LOGIN_NAME]` (before or after the path, nothing else may follow) puts the login name into the work files'
names, so two people sharing a work folder cannot collide; the name may be quoted. Also settable with `CONFIG`.
<a id="brserver"></a>**`BRSERVER <path>`** names
the folder that holds `BRServer.dat`, the file that describes the multi-user BR server; it
needs no drive letter, and without it BR looks in the first `DRIVE`'s base folder. The value is folded to lower case.
See [client-server](../client-server/spec.md#config) for what the file does.

**`DRIVE` rules** — abstracts physical/network storage so applications stay portable (and lets
Linux/MAC files be addressed with Windows-style names).
- Parameters: `<letter>` (A–Z, optional colon), `<server-path>` (OS full path; UNC `\\server\share`
  **runs faster** than a mapped letter), optional `<client-path>` (client working dir), optional
  `<subdir>` (an implied startup `CD`, preceded by `\`; case-sensitive). **Four parameters are
  required** — the 3rd may be null; a lone `\` in the 4th starts up in the 2nd-param OS directory.
- The **first `DRIVE`** sets the initial current directory; **at least one is required**; `DRIVE` is
  valid **only in BRConfig.sys**, never the `CONFIG` command.
- **Drive-relative vs drive-absolute references** — a filename that names a drive letter is resolved
  through that drive's mapping, and whether a backslash *immediately* follows the colon changes where
  it lands:
  - **`X:\path`** (leading `\`) — **absolute** from the drive's base, i.e. the 2nd parameter alone
    (the 4th-param startup `<subdir>` is *not* applied).
  - **`X:path`** (no leading `\`) — **relative** to the drive's *current directory*, which starts at
    base + the 4th-param `<subdir>` and then moves with `CD`.

  So whenever a `DRIVE` defines a startup `<subdir>` (or a `CD` has since run), `X:name` and `X:\name`
  point to **different** places — they coincide only when no subdir/CD is in effect. With
  `DRIVE M:,C:\ads,,\app`: `M:rpt\x` → `C:\ads\app\rpt\x`, but `M:\rpt\x` → `C:\ads\rpt\x`
  (a frequent source of "file not found" / error 4203 when a leading `\` is added out of habit).
- Undefined drives are assumed to be the root of that letter, but get **no record/file locking** and
  are not reported by `STATUS`; `PROTECT RESERVE` only works on DRIVE-defined drives.
- Case: the `<server-path>` is case-sensitive on Linux/Mac, insensitive on Windows; backslashes
  separate directories even on Linux, where program filenames are forced lowercase unless
  [`FILENAMES`](#paths) overrides.
- **Colon escape** — pathnames in *other* BRConfig.sys statements are translated through preceding
  `DRIVE` definitions; prefix a path with `:` to use a literal OS path instead (the `:` is stripped).

**BR file-search order at startup / `OPEN`:**

| file | found via |
|---|---|
| BR executable | OS working/current dir when BR is invoked (treated as the executable dir) |
| `BRConfig.sys` | command-line parameter, else BR executable dir |
| `WBCmd.wbh` | first `DRIVE` location |
| `BRServer.dat` | `BRSERVER` config statement, else first `DRIVE` location |
| `BRSerial.dat` / `WBTerm.out` | BR executable dir |
| `brrestrict.sys` | BR executable dir only — read after `BRConfig.sys`; see [BRRESTRICT.SYS](BRRESTRICT.SYS.md) |
| initial current directory | first `DRIVE` location |

**`brrestrict.sys`**, when installed, limits every session to the folders and files it lists — see
[BRRESTRICT.SYS](BRRESTRICT.SYS.md).

<a id="appearance"></a>
### Screen appearance
```bnf
3D_FIELDS {ON|OFF|UNDR_ON|UNDR_OFF}                -- pre-4.0 '3-D' fields; legacy
APPLICATION_NAME <name>   
ATTRIBUTE [<name>] <attributes> [<defined-name>] [FONT=<font>]   -- reusable attribute combos ([E],[I],[M],[W],…)
ATTRIBUTE CLEAR
ATTRIBUTE ESC {SPACE|NOSPACE}
COLOR [<label>]#rrggbb [...]                       -- name a 6-hex-digit colour
CONSOLE {ON|OFF|DATA_ONLY|OFF_WHEN_SHELLED [ALWAYS]}
CONSOLE HISTORY <n>
CORNERS <top-left-char> <bottom-right-char> 
CURSOR <SSEE>                                      -- console cursor: start/end scan line, 4 hex digits
DATAHILITE {ON|OFF|WIN_ON|WIN_OFF|<attributes>}
FIELDHELP [N=<attr>] [BORDER=<border>[<attr>]] [TIP_LENGTH=<n>]
FILTER_DELIMITERS "<chars>"
FONT [ASPECT=n/d] [<fontname>] [3DFONT=<fontname>]
FONTFAMILY <selector> "<face>"[, "<face>"]... [, <generic>]   -- fall-back typefaces for a printer font number
SCREEN OPENDFLT FONT=…, FONT.TEXT=…, FONT.LABELS=…, FONT.BUTTONS=…
FORCE VISIBILITY {ON|OFF}                           -- copy underlying labels/text into opened window
GRAPHIC_LINEDRAW {ON|OFF|THIN|THINSUNK|THINRAISED|RAISED|SUNKEN}   -- window borders drawn with line-draw characters
GRID_CURSOR_MOVE {DOWN|RIGHT|NONE|DEFAULT}          -- where Enter / Field+/- go in a grid
GUI {ON|OFF}
GUI SUPPRESS [ON|OFF]
GUI BRVB
MIN_FONTSIZE <h>x<w>                                -- min console font in px; scroll bars when less
SCREEN C [<attr-name>]                              -- command-console fg/bg colors
SCREEN <type> [<attr-name>], …                      -- N/U/R/B/H base attributes
STATUSLINE {ON | OFF [<message>] | ROWCOL {ON|OFF}}
WINDOWS_THEMES {ON|OFF}
```
<a id="screen"></a>**`SCREEN`** has three kinds of item, any number of which may follow it on one line:
1. **`<letter> <value>`** defines one of the standard single-letter display attributes: `N` normal, `U` underline,
   `H` highlight, `R` reverse, `B` blink, `I` invisible, `S` the status line. The value is two hex digits (background
   and foreground colour, e.g. `SCREEN N 70, R 3F`), four hex digits for the extended (3-D) form (`SCREEN U 0170`; see
   [`3D_FIELDS`](#3d_fields)), or a `[name]` defined with [`ATTRIBUTE`](#attribute). Items are separated by a comma or a
   space. An unknown letter or bad value is an error and nothing in the line is applied.
2. **`C <value>`** is the same for the command console (`SCREEN C [CMD_CONSOLE]`, below).
3. **`OPENDFLT "<spec>"`** defines the default for `OPEN #0` (the main window) — fonts, and so on — e.g.
   `SCREEN OPENDFLT "FONT=Roman"`; the quotes may be omitted when it is the last item on the line.

   A change to `N` takes effect only for windows opened afterwards; windows already open keep theirs.
- <a id="3d_fields"></a>**`3D_FIELDS {ON|OFF|UNDR_ON|UNDR_OFF}`** (legacy, from before BR 4.0; also spelled `FIELDS3D` in
  very early versions) gives the console a "3-D" look: input fields are drawn raised or sunken. `UNDR_ON` makes an
  underlined (`U`) field take its colours **only** from the `U` attribute; without it BR took `N` (or `R`) and OR-ed
  `H`, `B` and `U` into it. `UNDR_OFF` turns that off. `OFF` disables the feature, and any other word is an error.
  Turning it on in BRConfig.sys is not enough: the screen must also say `SCREEN U 0170` (or `SCREEN U 0170,N 38`), and a
  field must use a standard attribute with `01` in front (`U 0170`) or `S` as its leading attribute, e.g.
  `INPUT FIELDS "10,10,C 10,S": X$`. Set from `CONFIG`, the window must then be reopened:
  `OPEN #0: "SROW=1,SCOL=1", DISPLAY, OUTIN`. The window needs more height with 3-D fields on, so it looks better as a
  window than full screen. With `DATAHILITE` on, Ctrl-Z acts as undo. New code should use the `SCREEN` statement instead.
- <a id="application_name"></a>**`APPLICATION_NAME <name>`** (4.16+) is the name BR shows for the application in: the main
  (#0) window's title, the splash screen, the Windows print-job file name, the Ctrl-] shell, and the Unix signal handler.
  Set it in BRConfig.sys or with `EXECUTE "CONFIG APPLICATION_NAME ..."`. The text keeps its case; an unacceptable name
  is an error.
- <a id="attribute"></a>**`ATTRIBUTE`** defines named attributes/fonts referenced from
  [20-io-screen/fields-attributes](../../20-io-screen/fields-attributes/spec.md#subattributes).
  Attribute names may be up to **12 chars** (`[hilite_text]`), can carry a `font=name:slant:max`
  clause, and include help-screen colors `[HPROMPT]`/`[HTEXT]`/`[HLIGHTBAR]`/`[HMENU]`.
  Several definitions may be given on one line, and each is checked as both a colour and a monochrome attribute.
  `ATTRIBUTE CLEAR` removes every definition. `ATTRIBUTE ESC SPACE` and `ATTRIBUTE ESC NOSPACE` set whether an escape
  attribute takes a following space, a legacy switch; anything else after `ESC` is an error. `CONFIG ATTRIBUTE [X]U/RGB:B`
  makes `[X]` usable at once in any later `PRINT FIELDS`, `INPUT FIELDS` or `RINPUT FIELDS`:
  `EXECUTE "CONFIG ATTRIBUTE [D]U/RGB:B [A]R/HRGB:R"` then `INPUT FIELDS "1,1,C 10,[D]", ATTR "[A]": X$`.
  The help-file colours can be changed this way without editing any help file. Full reference:
  [Attribute_(Config)](Attribute_(Config).md).
- <a id="color"></a>**`COLOR [<label>]#rrggbb`** (4.18+) names a colour: after `COLOR [WARNING]#FFFF00`, `[WARNING]`
  stands for that colour wherever colours are written, in the `INPUT FIELDS`, `RINPUT FIELDS` and `PRINT FIELDS`
  attributes. The value is **exactly six hex digits after a `#`**; anything else is an error, and several definitions may
  share one line. `STATUS COLORS` lists the ones in effect. The older `COLOR Y`/`COLOR N` form (act on, or ignore, colour
  attributes) was removed in 2007: BR always acts on colour attributes.
- <a id="corners"></a>**`CORNERS <top-left-char> <bottom-right-char>`** sets two characters BR uses to build
  character-based window and field-help borders: the one for the top left corner and the one for the bottom right; BR fills in
  the rest. It is the *corners* form of a border specification, also accepted by `FIELDHELP BORDER=`.
- <a id="datahilite"></a>**`DATAHILITE {ON|OFF|WIN_ON|WIN_OFF|<attributes>}`** says how the contents of an input field are
  highlighted when the cursor enters it, so that typing replaces the contents. `ON` (the default) reverse-videos the field and
  parks the cursor at the end of the data; `WIN_ON` uses the user's Windows *selected-text* colours instead; `OFF` turns the
  highlighting off, and `WIN_OFF` switches to the attribute style using the attribute last set. A set of display
  [attributes](Attribute_(Config).md) (for example `/#FFFF00:#000000`) is a colour of your own. A bad attribute is an error.
  Because the field is highlighted, the first character typed clears it, and that overrides the overtype/insert choice of
  [`INSERT`](#insert).
- <a id="filter_delimiters"></a>**`FILTER_DELIMITERS "<chars>"`** (4.3+) When GRID and LIST are in use, a SEARCH or FILTER field can be specified.
  Different types of searching can be performed, some of which are word oriented. Such searches use delimiters to identify words within text. The default delimiters are ` \"\\\t\r\n,.;:(){}[]!@#$%^&*-_=+/?|~<>`. FILTER_DELIMITERS replaces that list of separator characters
  with the string given (case kept, up to 256 characters); the
  setting is sent to the client.
- **`FONT`/`SCREEN OPENDFLT FONT=…`** set the GUI fonts (default = the user's Windows default): 
  
  `FONT fontname 3DFONT=fontname` runs two fonts at once (background/captions vs input
  fields). 
  
  `SCREEN OPENDFLT FONT=, FONT.TEXT=, FONT.LABELS=, FONT.BUTTONS=` set separate
  fonts for text/labels/buttons, and these are the OPEN #0 defaults that child windows (and controls)
  inherit. 

  A font spec may carry colon separated qualifiers — **family** (Decor/Roman/Script/Swiss/Modern), 
  **boldness**  (Light/Bold), **style** (Ital/Slant), **underline** (Under), **size** 
  (Small/Medium/Large/Max, by height) — and a  width-fit qualifier (`Width`/`Width+`/`Width-`/`NoWidth`) 
  that shrinks text to fit the field, e.g. `FONT.LABELS=Terminal:bold:slant`. 
  
  Window reopen- Font *size* is **not** reset by opening a window (so user resizing  sticks); 
  typeface/family changes in an `OPEN` revert boldness/style/underline to defaults unless 
  respecified. `STATUS FONTS` lists usable installed fonts; the legacy `FONTSIZE=99x99` works 
  only with `GUI OFF`. Full reference: [Font](Font.md).

- <a id="force"></a>**`FORCE VISIBILITY [ON|OFF]`** (4.16+; no word means `ON`) makes a newly opened GUI window copy in
  underlying labels/text. In GUI mode nothing written to an underlying window shows through an overlying one until it is removed,
  unlike the old console; on `OPEN`, this copies the labels and text boxes underneath (including the parts of fields that
  cross the window's edge) into the new window, and addresses of controls that *begin* under it are converted to the
  child window's. That simulates the old console's see-through windows — not for new development; no effect on
  GRID/LISTVIEW or other controls, only labels and text. `CLOSE FREE` does the reverse — clears the parent's area and
  copies the child window's labels/text/buttons, but not pictures, back onto the parent.
- <a id="gui"></a>**`GUI {ON|OFF}`** (`ON` if no word is given). `GUI ON` (4.16+) populates the screen with true Windows
  objects instead of an 80x24 grid of characters; `GUI OFF` (4.0+; "console mode", "DOS window") is the fixed-font legacy
  mode: no grids or combo boxes, `PRINT` scrolls the screen or window, `LINPUT` works, windows bleed through, only
  non-proportional fonts are used and only those appear in `STATUS FONTS`. Old code often runs in GUI mode but may need
  changes: `PRINT` writes to the [`CONSOLE`](#console) instead of scrolling; a single `PRINT FIELDS` may not put two fields
  at one screen location; and several `PRINT FIELDS` to one location erase the whole field, not only the overlapping part.
  Programs may switch mid-run, even section by section (`EXECUTE "CONFIG GUI OFF"` ... `EXECUTE "CONFIG GUI ON"`); the
  information already shown is not converted, so `PRINT NEWPAGE` when toggling. Changing the mode at run time reopens
  window #0 so it takes effect. Two further forms serve the Visual Basic/Delphi window manager: `GUI SUPPRESS [ON|OFF]`
  stops windows being handed to that manager and ignores calls to `brvb_mgr.dll` (no word means `ON`); `GUI BRVB`
  marks windows as belonging to that manager. Either is an error if the running client cannot do it.
- <a id="console"></a>**`CONSOLE {ON|OFF|DATA_ONLY|OFF_WHEN_SHELLED [ALWAYS]}`** (4.30+) decides when the command console is
  shown beside the application window. With GUI on: `OFF` (the default) hides it in run mode until an interrupt puts the
  operator at a command line, and it stays until the program resumes; `DATA_ONLY` shows it in run mode only when it has
  something in it, and always in command mode; `ON` keeps the GUI console and the command console both always on, useful
  when debugging. `OFF_WHEN_SHELLED` hides both consoles (GUI and command) while the Visual Basic manager or a similar
  program is running, whether GUI is on or off; adding `ALWAYS` is a further variant of it. With GUI off the command
  console (window #0) is always on and `ON`, `OFF` and `DATA_ONLY` are ignored.
  `CONSOLE HISTORY <n>` sets how much scroll-back the console keeps. It is a budget, not a line count: each line costs its
  width plus 16 bytes, and the ring holds as many lines as fit. `n` is at most **10000**; a larger or non-numeric value is
  an error. It does not change the `ON`/`OFF` setting.
- <a id="graphic_linedraw"></a>**`GRAPHIC_LINEDRAW {ON|OFF|THIN|THINSUNK|THINRAISED|RAISED|SUNKEN}`** sets how line-draw
  characters (the borders BR windows and old screens are drawn with) look. `OFF` draws plain characters; `ON`, `THIN` and
  `THINSUNK` all give the default thin sunken line; `THINRAISED` is the thin raised Windows look; `RAISED` and `SUNKEN` use the
  bitmaps `DRAWLINE.BMP` and `DRAWSUNK.BMP` and are meant for **GUI OFF**, where `RAISED` is the default. (Under GUI on,
  `THIN` and `THINRAISED` apply.) Any other value is an error. It takes effect at the next `OPEN` of window #0, so use
  `CONFIG` and reopen; `EXECUTE "CONFIG GRAPHIC_LINEDRAW ..."` does the same from a program.
  A wide GUI OFF screen can draw line-draw characters as dashes; to fix that, keep GUI OFF, put `DRAWLINE.BMP` and/or
  `DRAWSUNK.BMP` (from the winutil folder of the BR distribution) in the BR executable folder (the client's folder in 4.1
  and 4.2; BR 4.3 and later read them from the server), and use `SUNKEN` or `RAISED`. Edit the bitmaps for a custom
  set. Line-draw characters are typed with Ctrl-\ (toggles line-draw mode) and the numeric keypad's 0-9 and `.`.
- <a id="min_fontsize"></a>**`MIN_FONTSIZE <h>x<w>`** sets the smallest GUI/command-console font in pixels; shrinking the 
  window below it shows **scroll bars** instead of further shrinking the font (default `0x0` = off; change takes effect on the next resize/restore/maximize).
- <a id="cursor"></a>**`CURSOR SSEE`** sets the console cursor to a block running from scan line `SS` down to
  `EE`, four hex digits with no space. `00` is the top of the character cell and `0D` the bottom, so
  `CONFIG CURSOR 010D` is a full block, `080D` the lower half and `0505` a single line. BR forces the end into
  1-13 and the start to at most one line above it, so the cursor is never less than one scan line tall. Anything
  but four hex digits is an error. The change is sent to the client and the cursor redrawn at once. Also settable
  from a program with `EXECUTE "CONFIG CURSOR ..."`.
- <a id="fieldhelp"></a>**`FIELDHELP [N=<attr>] [BORDER=<border>[<attr>]] [TIP_LENGTH=<n>]`** is the only thing that
  controls the look of the **field-help windows** that `INPUT FIELDS`, `RINPUT FIELDS`, `INPUT SELECT` and
  `RINPUT SELECT` open. The `N=` and `BORDER=` of those statements and of `OPEN` do not reach them. (Whether help
  shows at all is [`USERLEVEL`](#userlevel).)
  - `N=` the [attributes](Attribute_(Config).md) of the help text.
  - `BORDER=` `B` blank (works well with the `R` attribute), `D` double (single where the terminal has none), `S`
    single, or a custom border: two characters for the top-left and bottom-right corners, or eight for all corners
    and sides. Attributes for the border itself follow at once, with no space. As of 4.3 `BORDER=H` and the
    eight-character form are no longer supported except through [`OPTION 62`](OPTION_(Config).md), which accepts S, D, B, H
    or an eight-character string, a colon, then attributes.
  - `TIP_LENGTH=<n>` sets the length used for tip text (sent to the client).

  Start-up default: `N=N, BORDER=NN`. The settings apply together only when the whole line is valid. On the `CONFIG`
  command the keyword may be shortened to `FI`.
- <a id="fontfamily"></a>**`FONTFAMILY <selector> "<face>"[, "<face>"]... [, <generic>]`** adds fall-back typefaces for
  one of BR's printer font numbers. `<selector>` is a font number (0-5, or a PCL typeface id such as 4101), a BR
  family name, or the CSS generic that means the same:

  | BR family | number | CSS generic |
  |---|---|---|
  | `ROMAN` | 1 | `serif` |
  | `SWISS` | 2 | `sans-serif` |
  | `MODERN` | 3 | `monospace` |
  | `SCRIPT` | 4 | `cursive` |
  | `DECORATIVE` | 5 | `fantasy` |

  The built-in face for the number stays at the head of the list, so a machine that has it still uses it; the
  faces given are tried after it. Which faces exist is a property of the workstation, so the list is sent to the
  client and resolved there. An unknown selector or an empty list is an error.
- <a id="grid_cursor_move"></a>**`GRID_CURSOR_MOVE {DOWN|RIGHT|NONE|DEFAULT}`** (4.2+) sets where the cursor goes in a
  grid after **Enter** or **Field+/Field-**, in navigation and edit mode alike. `DEFAULT` changes nothing: Field+ and
  Field- act as the down arrow and Enter moves down. Any other value overrides both.
- <a id="statusline"></a>**`STATUSLINE`** controls the status line at the bottom of the screen.
  - `STATUSLINE ON` shows it.
  - `STATUSLINE OFF [<message>]` hides it and shows `<message>` in its place (one leading space is allowed; text
    after a `!` is dropped).
  - `STATUSLINE ROWCOL {ON|OFF}` shows or hides the cursor row and column on it. `ROWCOL OFF` puts the release
    number there instead.

  `ROWCOL` is **on** at start-up in BR 5.0 (the 4.31 release notes say it then defaulted to off). If a Linux console
  does not show the line, **Esc** toggles it; on Windows, use `CONFIG STATUSLINE ON`.
- <a id="windows_themes"></a>**`WINDOWS_THEMES {ON|OFF}`** (4.2+; default `ON`) `OFF` stops the GUI client drawing field
  controls with Windows themes, giving the classic Windows 2000 look. Themes can slow the display of a lot of data and
  sometimes look worse than the classic style. Two narrower methods exist: the `^NOTHEME` field attribute, and
  [`OPTION 50`](OPTION_(Config).md) (text boxes only).
- **`SCREEN C [<attr-name>]`** colors the command console — define an attribute then apply it, 
  e.g. `CONFIG ATTRIBUTE [CMD_CONSOLE]/#HRGB:R` then `CONFIG SCREEN C [CMD_CONSOLE]`. The full 
  attribute/help-color reference is retained: [Attribute_(Config)](Attribute_(Config).md).
- **`SCREEN`** statements may reference them (`SCREEN N [normal]`). `W` in an attribute = current Windows color.

<a id="behavior"></a>
### Language & I/O behavior
```bnf
BASEYEAR <year>                 -- 100-year window for DAYS (1900-2399; default 1900)
BREAK <lines> [<keyloop>]
CHAINDFLT O                     -- letter O - search .BRO before .BR for CHAIN/LOAD
COLLATE {NATIVE|ALTERNATE}      
DATABASE <db-ref> { DSN=<dsn> | CONNECTSTRING="<string>" | ODBC-MANAGER } [USER={<name>|LOGIN_NAME|?}] [{PASSWORD={<pw>|?} | PASSWORDD=<hex> | BR_PASSWORD}]
DATABASE CLEAR [<db-ref>|ALL]
DATABASE MAX_COLUMN_WIDTH <n>
DATE {INVALID|ALWAYS|NEVER}      -- when the GUI date picker opens on a D field
DECIMAL {ASSUMED|REQUIRED} 
DIMONLY [ON|OFF]                -- refuse variables no DIM defines
EDITOR "<path>" [REMOVE] [NOWAIT]   
EXECUTE "<command>"
FIELDBREAK [MIN_SPACES <n>] [UNDERSCORE {ON|OFF}]
FLOWSTACK <size>   
FORSTACK <size>   
HELPDFLT <keyword>,<filename>
HELPDFLT CLEAR
HELPTREE {<folder> | CLEAR}      -- where br_tree (the Markdown reference) is
HELPTREE2 {<folder> | CLEAR}     -- where br_tree2 (its HTML edition) is
INSERT {ON|OFF} [MIN_LENGTH <0-99> | NON_PERSISTENT | SESSION_PERSISTENT | PERSISTENT]
INVP   -- (European comma/period swap)
KEYBOARD <scancode> <sequence>  
KEYBOARD [<scancode>] CLEAR
LOGGING <max-level>, <logfile> [, UNATTENDED] [, DEBUG_LOG_LEVEL=<n>] [, +CONSOLE]
MAXRECALL <1-300>    
MAX_SORT_MEMORY <n> MB
PAGEOFLOW <lines>               -- line count at which the PAGEOFLOW condition fires (default 60)
PICTURE {CACHE_ON|CACHE_OFF}    
RD <0-15>                       -- numeric-comparison rounding tolerance (default 6)
RPNSTACK <entries>              -- expression stack size (min 50, default 1000); BRConfig.sys only
S/36-MODE [ON|OFF]              -- System/36 compatibility
SEARCH_CHAR {OFF|<hh>}          -- case-insensitive search prefix for POS/SRCH (default ^ = 5E)
SETENV <name> '<value>'         -- (CONFIG) simulate an OS env var for the session → ENV$()
SHELL DEFAULT {CLIENT|SERVER}   -- where shell calls run when not stated
SHELL LIMIT <seconds>           -- shell-call timeout (default 240; -1 = never)
SOFLOW-GROW [MAX=<n>] [ON|OFF]  -- widen strings instead of raising SOFLOW
STYLE [INDENT <n>[,<column>]] [KEYWORDS|LABELS|EXPRESSIONS|COMMENTS {UPPER|LOWER|MIXED|CLEAR}] ... | STYLE CLEAR
TYPEAHEAD {ON|OFF}
USERLEVEL {0|1|2|3}             -- field-help level (default 3)
WORKSTACK <bytes>               -- work stack size (min 500, default 500000); BRConfig.sys only
WSID <n>[+[<incr>]]             -- workstation id
WSID=SESSION
WSID=UNIQUE
```
- <a id="baseyear"></a>**`BASEYEAR <year>`** (1900-2399; default **1900**) is the start of the 100-year window BR uses for the
  century of a two-digit year, in the [date functions](../../10-language/data-manipulation/system-functions/spec.md#date-functions)
  such as `DAYS` and in date entry, when the century is not given. A year equal to or greater than `BASEYEAR`'s last two digits
  takes `BASEYEAR`'s century; a smaller one takes the next century. `CONFIG BASEYEAR 1950` then makes `DAYS(010122)` mean
  01/01/2022 and `DAYS(010193)` mean 01/01/1993. Dates before `BASEYEAR` can no longer be entered as M/D/Y (they take the
  next century), though dates already converted to days, as in a history file, are not affected; the logical `DAYS` value
  (days since January 0, 1900) never changes. If an application needs dates over more than 100 years, show the century.
  A value outside 1900-2399 is an error. `BASEYEAR 1910` in BRConfig.sys makes every date from 01/01/00 to 12/31/09 mean the
  21st century, which carried many programs past the year 2000 unchanged. May also be set with `EXECUTE "CONFIG BASEYEAR n"`.
- <a id="break"></a>**`BREAK <lines> [<keyloop>]`** sets how often BR polls the keyboard for `Ctrl-A` or an `ON FKEY`/`ON FNKEY`
  key. `<lines>` is the number of numbered program **lines** (not statements, so a line holding several statements counts once)
  run between polls, and lines that are not executed, such as `DIM`, are not counted. The start-up default is **8**;
  `BREAK 1` polls after every line, and a larger value than 8 gains very little speed. Raising it can speed programs up,
  particularly under Linux. The optional second number is read by the Unix/Linux console client: how many times it tries to read
  a key at each poll; `0` (the default) makes it wait for a fixed time instead. `STATUS CONFIG` shows both.
  `EXECUTE "CONFIG BREAK 6"` overrides the BRConfig.sys value.
- <a id="chaindflt"></a>**`CHAINDFLT O`** (the letter O; the first character is what counts) flips the `CHAIN`/`LOAD` extension search to
  `.BRO`-first. With no extension and no trailing period in the name (`PROG1`), BR tries `.BR` and then `.BRO` (an object
  file); with `CHAINDFLT O` it tries `.BRO` first. A name ending in a period has no extension at all.
- <a id="collate"></a>**`COLLATE {NATIVE|ALTERNATE}`** (default `NATIVE`) picks the collating sequence. `NATIVE` is ASCII: the
  digits (codes 048-057) sort before upper case (065-090), which sort before lower case (097-122). `ALTERNATE` is ASCII with
  the digits 0-9 moved **above** the letters, to codes 176-195 (`x'B0'`), which approximates EBCDIC for legacy logic; an
  optional file name that used to follow it was removed in 4.16 and is now an error. It affects every character
  comparison: `IF`, `AIDX`, `DIDX`, `MAX$`, `MIN$`, `ORD A`, the `RECORD` specification of the SORT facility
  and so on; [keyed](../../30-io-file/keys-indexes/spec.md) order too. Points to remember:
  - BR saves a program with the `COLLATE` in force at the time, so a program saved under `ALTERNATE` runs that way; a program
    already loaded takes the new setting at once.
  - `SORT` uses the current setting unless the control file says otherwise, and `ALTERNATE` overrides the control file's
    `FILE` specification's `N` parameter (see [SORT](../../70-commands/sort/spec.md)).
  - An index uses the `COLLATE` in force when it was created or recreated, not the one in force when a program uses it;
    `INDEX` has a parameter to override that.
  - `OPTION COLLATE ALTERNATE` in a program, and `A` on a sort control file's `FILE` line, choose the alternate sequence too.
  Be consistent, and settable with `CONFIG` or `EXECUTE "CONFIG COLLATE ..."`.
- <a id="database"></a>**`DATABASE <db-ref> <connection> [USER=...] [password]`** (4.3+) defines a named SQL connection, used by
  [`OPEN`](../../30-io-file/database/spec.md) with `DATABASE=` and the `SQL` statements. Exactly one connection method is allowed:
  - `DSN=<dsn>` — a configured ODBC data source;
  - `CONNECTSTRING="<driver and settings>"` — a DSN-less connection string, e.g.
    `"DRIVER=SQL Server;SERVER=host;Initial Catalog=sales;UID=u;PWD=p"`;
  - `ODBC-MANAGER` — the ODBC manager lets the **operator pick** the data source, and the resulting connection string can be
    read from `ENV$("STATUS.DATABASE.[<db-ref>].CONNECTSTRING")`. It does not work in client-server mode, because the dialog is
    on the server.

  `USER=` is a user name, `LOGIN_NAME` (the BR login name) or `?` (prompt). At most one password form: `PASSWORD=<password>`,
  `PASSWORD=?` (prompt), `PASSWORDD=<hex>` (a password made with `ENCRYPT$`, written as hex; BR does `UNHEX$` then `DECRYPT$`
  before sending it) or `BR_PASSWORD` (the user's Active Directory password). With a connection string, `USER=` and the password add
  `UID=` and `PWD=` to it, so do not give them in both places. `DATABASE <db-ref> ...` replaces an earlier definition of the same name.
  `DATABASE CLEAR <db-ref>` closes and forgets one connection and `DATABASE CLEAR ALL` every one.
  `DATABASE MAX_COLUMN_WIDTH <n>` sets the largest column width BR binds for SQL data (default 2000). Any bad
  piece makes the whole statement an error, with the reason in the log.
- <a id="decimal"></a>**`DECIMAL {ASSUMED|REQUIRED}`** (default `ASSUMED`) affects `INPUT FIELDS`/`RINPUT FIELDS` numeric
  fields formatted with a fraction, such as `"10,10,N 7.2,R"`. `ASSUMED` infers the decimal point when it is not typed;
  `REQUIRED` makes the operator type it, if a fractional part is wanted. With `N 7.2`:

  | typed | `REQUIRED` | `ASSUMED` |
  |---|---|---|
  | `1234.56` | 1234.56 | 1234.56 |
  | `1234 56` | error 0002 | 1234.56 |
  | `123456` | error 0002 | 1234.56 |
  | `1234` | 1234.00 | 12.34 (with a notice) |
  | `1234.` | 1234.00 | 1234.00 |

  Anything but the two words is an error.
- <a id="editor"></a>**`EDITOR "<program>" [REMOVE] [NOWAIT]`** names the external program the [`EDIT` command](../../70-commands/editing/spec.md#edit)
  launches to edit `.brs`/`.wbs` editable source (put the path in quotes if it has spaces). Typed as a command or
  `EXECUTE`d: `CONFIG EDITOR "C:\Program Files\NotePad++\NotePad++.exe"`; in BRConfig.sys for one user only:
  `@"Herbert" EDITOR "C:\Program Files\Mills Enterprise\MyEditBR\MyEditBR.exe"`. `REMOVE` deletes the source workfile once editing completes;
  `NOWAIT` skips the Enter-to-merge wait. A new `EDITOR` line resets both words to off. Restricted sessions may not change it. Source-capable editors include Notepad, Notepad++, PFE32,
  TextPad, MyEditBR, Source Edit, EditPad Pro, UltraEdit, JEdit, Crimson Editor, Epsilon, ConTEXT,
  WinHighlight, Editra, and Cursor.
- <a id="execute"></a>**`EXECUTE "<command>"`** names a command BR runs at start-up, e.g. `EXECUTE "RUN MENU"`; this lets Windows
  client-server and Mac sessions start an application automatically, as Unix/Linux/AIX always could. **It is ignored when
  the start-up icon or command line already gives a command**, and the quotes may be left off. A later `EXECUTE` line in
  the file replaces an earlier one. As with any directive it can be limited to one login: `@jsmith EXECUTE "RUN MENU"`.
  This is only the BRConfig.sys directive: the `EXECUTE` *statement* is how a program runs `CONFIG` lines
  (`EXECUTE "CONFIG ..."`).
- <a id="fieldbreak"></a>**`FIELDBREAK [MIN_SPACES <n>] [UNDERSCORE {ON|OFF}]`** (4.16+) controls the automatic division of input
  fields into separate controls: `n` or more consecutive blanks mark a new sub-field. `n` is kept in 0-255.
  `UNDERSCORE OFF` stops underscores counting as blanks for that purpose (the words may be separated by a comma). In BRConfig.sys:
  `FIELDBREAK MIN_SPACES 2`; at the console: `CONFIG FIELDBREAK MIN_SPACES 2, UNDERSCORE OFF`.
- <a id="flowstack"></a><a id="forstack"></a>**`FLOWSTACK`/`FORSTACK`** size the GOSUB/function-return and FOR/NEXT stacks (both default **100**);
  The FOR stack counts loop variables by *name* — one slot per distinct variable no matter how many 
  `FOR` loops reuse it. Both are **BRConfig.sys-only — not valid as a `CONFIG` command; `STATUS STACKS` shows current settings.
- <a id="rpnstack"></a><a id="workstack"></a>**`RPNSTACK <entries>`** and **`WORKSTACK <bytes>`** size the interpreter's two
  evaluation stacks: the RPN stack (pointers to dictionary entries; minimum **50**, default **1000**) and the work stack
  (bytes of temporary data; minimum **500**, default **500000**). Like `FLOWSTACK`/`FORSTACK` they are allocated once, at
  start-up, so they belong in BRConfig.sys. A smaller value is an error. A full stack raises error **9002** (RPN) or
  **9001** (work). `STATUS STACKS` shows the settings.
- <a id="helpdflt"></a>**`HELPDFLT <keyword>,<filename>`** (a comma, with something on each side, is required; `HELPDFLT CLEAR`
  removes the setting) sets the
  default help topic and file shown when the **HELP key (Ctrl-Y)** is pressed during `RUN`/`INPUT` mode,
  and the default file for the [`HELP$`](../../10-language/data-manipulation/system-functions/spec.md)
  function (runtime-only; overridable via `CONFIG`). With no `HELPDFLT`, the HELP key does nothing
  outside INPUT mode (`ON HELP SYSTEM` behaves as `ON HELP IGNORE`) and `HELP$` requires an explicit
  filename; help files are searched current dir → base node of the first `DRIVE` → BR start dir.
- <a id="helptree"></a>**`HELPTREE <folder>`** says where br_tree is, for the help key, the `HELP`
  command and `HELP$` with `OPTION 85` off. The folder is br_tree itself or one holding it. Without
  it, BR looks at `ENV$("BR_TREE")`, then for `br_tree` or `context\br_tree` in BR's current folder
  and the two above it, then the same around the folder BR was started in and BR's own folder.
  `CLEAR` puts back that search. Error 9503 says br_tree was not found.
- <a id="helptree2"></a>**`HELPTREE2 <folder>`** says where br_tree2, the HTML edition of br_tree,
  is. The folder is br_tree2 itself or one holding it. Without it, BR looks at `ENV$("BR_TREE2")`,
  then beside br_tree. With br_tree2 found, help opens in the person's own web browser
  ([windows-cursor §help](../../20-io-screen/windows-cursor/spec.md#help-facility)); without it, help
  is shown on the console. `CLEAR` puts back the search.
  Both are refused in a restricted session.
- <a id="insert"></a>**`INSERT {ON|OFF} [MIN_LENGTH <0-99>] [NON_PERSISTENT|SESSION_PERSISTENT|PERSISTENT]`** sets the
  overtype/insert mode a field starts in when the cursor enters it. Words may be combined in any order on one line.
  - `ON` / `OFF` — insert or overtype.
  - `MIN_LENGTH <n>` — separate settings for long and short fields: insert is on when the field's capacity is `n` or more
    (e.g. `INSERT ON MIN_LENGTH 10`).
  - Persistence: `NON_PERSISTENT` resets to the configured setting each time the cursor leaves a field; `SESSION_PERSISTENT`
    resets it at the start of each BR session; `PERSISTENT` keeps what the operator last chose across BR sessions.
  The default is **`ON PERSISTENT`**. It is overridden by [`DATAHILITE`](#datahilite), which highlights the field's contents
  so that typing clears the field before the typed value is shown. Also settable with `CONFIG` and `EXECUTE "CONFIG INSERT ..."`;
  any other word is an error.
- <a id="keyboard"></a>**`KEYBOARD <scancode> <sequence>`** builds keystroke macros from BR scancodes: each time the key
  named by `<scancode>` is pressed BR generates the key actions in `<sequence>`. Both are hex: a four-digit scancode (leading
  zeroes may be left off in a `CONFIG` command) and any number of four-digit key values. The key can be a function key,
  Tab and so on, and the ESC key may also be remapped. Example: `KEYBOARD 0700,005200450050004C004100430045` makes F7 type
  `REPLACE`; add `000D` (Enter) to run it at once, and `CON KEY 0A 6A756D70` makes `^J` type `jump`. Useful scancodes:
  Tab `09`, Shift+Tab `07`, Down `0A`, Up `0B`, Left `0E`, Right `0C`, F7 `0700`, Shift+F7 `1100`, Alt+Down `E300`,
  Ctrl-A `01` (remapping Ctrl-A, e.g. to make a program uninterruptible, is possible). To find a key's scancode run
  `00010 LET X$=KSTAT$(1) : 00020 PRINT UNHEX$(X$) : 00030 GOTO 10` (Ctrl-A itself cannot be read this way). Any number of
  `KEYBOARD` lines may be used, and they are portable because they use BR's own scancodes. `CONFIG KEYBOARD CLEAR` removes
  all earlier definitions and `CONFIG KEYBOARD <scancode> CLEAR` the one; a macro the client cannot accept makes the line an error.
  The default is no translation. Keyword abbreviations (`CON KEY`) are accepted in the command, not in BRConfig.sys.
- `LOGGING` filters by level 0 (major-error) … 15 (obnoxious detail); commands entered log at 8, `TRACE`/`DISPLAY` at 12, and console `PRINT` output is never logged; `UNATTENDED` runs headless and exits on input; 
  `+CONSOLE` echoes `DEBUG_STR` messages to the console (GUI ON; automatic at level ≥ 11). Full level table: [LOGGING](LOGGING.md).
- <a id="maxrecall"></a>**`MAXRECALL <1-300>`** sets how many commands BR remembers for **F2** recall at READY (default **200**; a value
  above 300 is an error). F2 shows the latest command, and each further F2 the one before it, until the limit, when
  the cycle starts again. **F3** always recalls the latest command and also resets the F2 pointer.
- <a id="max_sort_memory"></a>**`MAX_SORT_MEMORY <n> MB`** is the most memory, in megabytes, a `SORT` or `INDEX` may use. The default
  is **8 MB**. The `MB` suffix is required, and a value below 2 is an error. The 5.0 source accepts up to 2000, though the
  published range was 2-512. It is a balance between CPU and disk speed and available memory: bigger is not always better,
  and 64 MB can be the sweet spot for a system. `CONFIG MAX_SORT_MEMORY 512 MB`.
- <a id="picture"></a>**`PICTURE {CACHE_ON|CACHE_OFF}`** controls whether the client keeps pictures it has fetched. `CACHE_ON` (the default)
  caches each by its file name; with `CACHE_OFF` every picture reference is fetched fresh from the server, even if the client
  has a copy. Any other value, or none, is rejected. See [`PICTURE`](../../20-io-screen/controls/spec.md) for showing pictures.
- <a id="rd"></a>`RD` sets how many decimal digits are significant in numeric `IF`/`FOR` comparisons, 
  `AIDX`/`DIDX`, `INT`/`IP`/`STR$`, SORT `RECORD`, and default `PRINT` (default 6; internal math is always 15-digits). Deep precision tables: [RD](RD.md).
- <a id="setenv"></a>**`SETENV <name> <value>`** simulates an OS environment variable for the rest of the BR session 
  so [`ENV$("<name>")`](../environment/spec.md) returns it, shadowing any real variable of that name for the session's duration. **Printer-init strings** may be up to **64 bytes**.
- <a id="date"></a>**`DATE {INVALID|ALWAYS|NEVER}`** says when the GUI client opens its **date picker** on a `D` field.
  `INVALID` (default) opens it only when a typed date will not convert; `ALWAYS` opens it on every date field as it is
  entered; `NEVER` turns an unconvertible date into 0 silently. A field carrying the `^DATE_PICKER` attribute uses the
  picker whatever this says, and an all-zero date such as `00/00/00` is never an error. Only the wx GUI client has a
  picker; on the console client the setting has no visible effect.
- <a id="dimonly"></a>**`DIMONLY [ON|OFF]`** prohibits creating a new variable during program entry unless a `DIM`
  statement has defined it, so a typing slip cannot silently create one. Any value but `OFF` means on.
- <a id="pageoflow"></a>**`PAGEOFLOW <lines>`** sets the number of printed lines at which the
  [`PAGEOFLOW` error condition](../../10-language/flow-control/error-handling/spec.md) fires for a printed file, in place of the default **60**
  — for paper that is not 11 inches. A value that is not a number is an error. The statement-level `PAGEOFLOW` /
  `ON PAGEOFLOW` is a different thing: it traps the condition this setting defines (error 0701).
- <a id="s36-mode"></a>**`S/36-MODE [ON|OFF]`** turns on System/36 compatibility; anything but `OFF` means on, and
  the default is off. Among its effects: a zero byte where a sign was expected is a conversion error and `Z` / `#`
  pictures show a default minus; short floats take 5 bytes rather than 4; an `INPUT FIELDS` with no unprotected field
  gets a dummy input field on row 23, and invisible fields are always blanked; and after `PRIOR` with no record
  referenced the pointer moves to the previous record if there is one, otherwise EOF.
- <a id="search_char"></a>**`SEARCH_CHAR {OFF|<hh>}`** (4.2+) sets the character that, as the first character of the
  search text, makes [`POS`](../../10-language/data-manipulation/system-functions/spec.md) and `SRCH` ignore case; the
  character itself is not searched for. The default is `^` (`5E`), so `POS(A$,"^abc")` finds `abc`, `ABC`, ... To search
  for a real `^`, use `CONFIG SEARCH_CHAR OFF` or pick another character, e.g. `CONFIG SEARCH_CHAR 7E` (two hex
  digits). `STATUS CONFIG` shows the value.
- <a id="shell"></a>**`SHELL DEFAULT {CLIENT|SERVER}`** and **`SHELL LIMIT <seconds>`**.
  `DEFAULT` says which machine a shell call (`SYSTEM`, `EXECUTE "SYSTEM ..."`) runs on when the statement has neither
  `-@` nor `-s`; `CLIENT` is the default, and it also decides what `WBPLATFORM$` reports.
  `LIMIT` is how long BR waits for the command before raising an error: default **240**; `-1` waits indefinitely
  (4.17). A call's own `-t` timeout overrides it. After a timeout the process keeps running, at least on Windows XP
  and Mac; a `-c` (continue) call avoids the error. See [client-server](../client-server/spec.md) for the shell-call
  flags. In a session with an attached assistant a shell call is put to the person first; a restricted session
  may not change these.
- <a id="soflow-grow"></a>**`SOFLOW-GROW [MAX=<n>] [ON|OFF]`** says what happens when a string assigned to a variable is
  longer than the variable. With `ON`, BR widens the string, moving the data, instead of raising the string-overflow
  (`SOFLOW`) error. It applies to assignment, to `LINPUT`, and to the other places a string is built into a variable.
  `MAX=<n>` sets the ceiling in bytes (1 up to 268,435,456, which is also the default); a string that would pass it
  raises the error as before. `MAX=` alone implies `ON`; with neither word, `ON` is assumed. Words may be shortened
  to a part no other word starts with. `GROW` may also be given per statement as an error action beside `IGNORE`, the
  last one winning. Default: off. See [error handling](../../10-language/flow-control/error-handling/spec.md).
- <a id="typeahead"></a>**`TYPEAHEAD {ON|OFF}`** says whether keystrokes typed ahead are kept. With `OFF` the keyboard
  buffer is cleared at each input statement; anything but `OFF` turns it on, and on is the default. It applies to
  `INPUT`, `INPUT FIELDS` and `INPUT SELECT`.
- <a id="userlevel"></a>**`USERLEVEL {0|1|2|3}`** sets how much **field help** is shown (default **3**). A field's help
  string begins with a level digit, and its help window opens on entry only if that digit is no greater than
  `USERLEVEL`. `0` shows none. Any other value is an error. The look of the windows is
  [`FIELDHELP`](#fieldhelp).
- <a id="wsid"></a>**`WSID <n>[+[<incr>]]`**, **`WSID=SESSION`**, **`WSID=UNIQUE`**. The workstation id, which
  `WSID$` and the `[WSID]` file-name substitution return. `WSID <n>` asks for number `n` (1-999; a larger value or a
  non-number is an error); `n+` or `n+incr` also lets BR move on by 1, or by `incr` (up to 999), if `n` is in use. The
  priority is: a session already running on the machine, then the command line, then BRConfig.sys, then the default of
  1 with an increment of 1; of several `WSID` lines the last one wins. `WSID` 0 is not allowed (4.17). A `WSID` on the
  command line makes this statement do nothing. If the id is taken the client is told so (the "WSID in use" message).
  A restricted session may not change any of these, because they set the identity its actions are logged under.
  - **The session number.** By default the sessions one machine starts share one WSID and are told apart by a
    session number (1 to 9) after it: with WSID 01, `SESSION$` is `011` in the first session and `012` in the second,
    while `WSID$` is `01` in both (two digits, three above 99). The `[SESSION]` file-name substitution is `SESSION$`
    and `[WSID]` is `WSID$`.
  - **`WSID=SESSION`** (no value) makes `WSID$` return what `SESSION$` does, the WSID followed by the session
    number (`012`), and gives `[WSID]` the same value. Files named with `[WSID]` then get a name of their own in
    each session, where otherwise the sessions of one machine would all use the same file.
  - **`WSID=UNIQUE`** (no value) turns off the sharing. BR does not look for sessions already running on the machine
    (so a second session does not join the first's WSID as an additional session), the session number is 1, and a
    WSID that is already in use is refused as in use, not shared, nor replaced by the WSID an earlier session of the
    same machine had. The server counts each session as its own user.
  - `STATUS CONFIG` reports both on lines of their own, `WSID=SESSION is ON` or `OFF` and `WSID=UNIQUE is ON` or
    `OFF`. Like `WSID <n>`, both are read from a configuration file when BR starts: the `CONFIG` command refuses
    them as a syntax error, and a restricted session refuses them.
- <a id="style"></a>**`STYLE`** sets how `LIST` formats source. Words, any number of them on a line, shortenable to a unique prefix:
  - `INDENT <n>[,<column>]` — `n` (0-8) is how far a nested statement is indented; `column` (20-60, 0 or left off for none) is
    where comments are lined up.
  - `KEYWORDS`, `LABELS`, `EXPRESSIONS` and `COMMENTS` each followed by `UPPER`, `LOWER`, `MIXED` or `CLEAR` (leave as written)
    — the case `LIST` shows that part in; `STYLE CLEAR` resets everything.
  Example: `STYLE INDENT 3 45 KEYWORDS LOWER LABELS MIXED EXPRESSIONS UPPER`.

<a id="printer"></a>
### Printer & spooling
```bnf
PRINTER [<type>] INIT [HP] [LPP <n>], "<escape>" 
PRINTER [<type>] RESET, "<init>"
PRINTER [<type>] [<mode>], "<escape>"
PRINTER TYPE <type> SELECT <substring>
SPOOLCMD [@] [-w] [-c] <command> ...[SPOOLFILE]... [COPIES] [PRINTER]
SPOOLPATH [@:] <directory>
PRINTSCREEN [GUI [OFF]] [REPLACE|APPEND] [NEWPAGE [OFF]] [CLEAR | <printer-spec>]
PDF_READER <program>
<escape> ::= { <hex-value-string> | "<char-string>" }
INCLUDE PRINTER.SYS
```
Configures printer escape sequences and spooling (the `@`/`@:` forms target the client in
client-server). 
`INIT` indicates that the succeeding <escape> value should be sent whenever the specified printer is opened.
`PRINTER xxx INIT HP <hex-values>` prepends laser keywords legacy codes.
`PRINTER TYPE` assigns a printer type to a specific printer; <substring> is a case sensitive OS printer name substring.

<a id="spoolcmd"></a>**`SPOOLCMD [@] [-w] [-c] <command>`** names an operating-system command BR runs for each print file once
it is closed, instead of BR's own spooling (which also honours `COPIES=`). The command is a line with bracketed words that BR fills in
before running it:

| word | becomes |
|---|---|
| `[SPOOLFILE]` | the full name of the spool file (just the file name when `OPTION 49` is off); drive substitution is applied to a drive in the command, see below |
| `[COPIES]` | the number of copies, from `COPIES=` on the `OPEN` (1 if none) |
| `[PRINTER]` | the part of `PRN:/nn` after the slash, e.g. `10` or `LASER` |
| `[QUEUE]` | the queue part before the slash, if any (lower-cased on Unix) |
| `[NAME=]` | the whole `PRN:...` name |
| `[PROGRAM]` | the running program's name |
| `[WSID]` | the workstation id |

For example `SPOOLCMD prt.bat [SPOOLFILE] [COPIES] [PRINTER]`, or, with `DRIVE C:,\\SERVER2\BR_SHARED,BRULES,COMPANY2`,
`SPOOLCMD COPY [SPOOLFILE] C:\REPORTS`, which copies everything printed to the default printer into `\\SERVER2\BR_SHARED\REPORTS`
(BR substitutes the drive before the command is issued). A leading `@` runs the command on the **client**; `-w` launches the program
directly instead of through the command interpreter, `-c` lets BR carry on without waiting for it. Every `[` must have its `]`
(or the line is an error) and the finished command may be at most 200 characters. Setting `SPOOLCMD` is allowed anywhere, but
running it is refused in a restricted session and put to the person when an assistant is attached. It
applies to every print file; `Name=WIN:/nn` suppresses it for that one file and `PREVIEW:/` overrides it. Also settable with
`CONFIG`. [`SPOOLPATH`](#spoolpath) says where the spool files are made.
**`PRINTER.SYS`** is a shareable BRConfig.sys of named PCL/NWP mode substitutions (`[LANDSCAPE]`, `[LETTER]`, `[BOLD]`, `[BOX]`, `[FONT]`, `[COLOR]`, `[PICTURE]`…) — the full catalog is the retained [PRINTER.SYS](PRINTER.SYS.md) reference. The printer *statements* are in [40-io-printing/statements](../../40-io-printing/statements/spec.md). 
Standard escape codes are in [40-io-printing/pcl-pdf](../../40-io-printing/pcl-pdf/spec.md).

<a id="printscreen"></a>**`PRINTSCREEN`** says how **Ctrl-P** prints the screen. Keywords may be combined in one line.
- `GUI` prints from the GUI console — graphically when the device is a Windows printer or `PREVIEW:` (it then defaults
  to `WIN:/SELECT`). `GUI OFF` prints from the command console.
- `REPLACE` or `APPEND` matters only when `PRN:/10` is substituted to a file: replace the file at each Ctrl-P, or add
  to it. `APPEND` is the default, and was the behaviour before the setting existed.
- `NEWPAGE` sends a form feed after each Ctrl-P, with or without a file substitute; `NEWPAGE OFF` (the default) does
  not.
- A printer name directs Ctrl-P to a printer: `PRN:/`, `WIN:/`, `DIRECT/` or `PREVIEW:/` followed by a case-sensitive
  part of a Windows printer name; `SELECT` lets the operator choose. `CLEAR` returns to `PRN:/10` or `PRN:/SELECT`.

```text
SUBSTITUTE PRN:/10,PRNFILE
PRINTSCREEN APPEND NEWPAGE          ! Ctrl-P output is appended to PRNFILE, each followed by a form feed
```
`CONFIG SUBSTITUTE PRN:/10, CLEAR` then returns Ctrl-P to the printer, and `CONFIG PRINTSCREEN NEWPAGE OFF` stops the form feed.

<a id="pdf_reader"></a>**`PDF_READER <program>`** names the program that a `NAME=PDF:/READER` printer hands a finished PDF to,
in place of the Windows program associated with PDF files (typically Acrobat): BR turns `NAME=PDF:/READER` into
`NAME=PDF:/<program>`. The setting reaches the client and is honoured by the Windows printing build only. In a session
with an attached assistant the launch is put to the person; a restricted session may not set it. See
[40-io-printing/pcl-pdf](../../40-io-printing/pcl-pdf/spec.md).

<a id="webserver-config"></a>
### Web server
```bnf
HTTP  <port>[-<last>] [LOG=<file>] [URL_BASE=<dir>|NONE] [CERT=<base>] [PHRASE=<passphrase>] [PROXY=<addr>[,<addr>...]] [BIND=<addr>] [THREADS=<n>]
HTTPS <port>[-<last>] [same keywords]
```
- <a id="http"></a>**`HTTP <port>`** sets the plain-HTTP port of BR's one built-in web server (80 if never given).
- <a id="https"></a>**`HTTPS <port>`** turns HTTPS on, on that port; plain HTTP stays on the `HTTP` port. `CERT=` is required with it.

The keywords (`LOG=`, `URL_BASE=`, `CERT=`, `PHRASE=`, `PROXY=`, `BIND=`, `THREADS=`) may come in any order on either line
and apply to the one server. The line is applied whole or not at all; the server starts at the first `OPEN ... HTTP=SERVER`;
a restricted session may not use either statement. Everything about them — each keyword, port ranges, certificates, the
errors 0770-0797 and reverse-proxy use — is in [HTTP=SERVER](../../60-integration/web/HTTP_SERVER.md#setup).

<a id="config"></a>
## Applying & overriding — the `CONFIG` command
Most directives can be changed after launch, without editing BRConfig.sys:
```bnf
CONFIG <keyword> <spec>                 -- as a command (CON); STATUS CONFIG lists current settings
EXECUTE "CONFIG <keyword> <spec>"       -- the same, from program code
```
`CONFIG` overrides the BRConfig.sys value for the rest of the session (e.g.
`CONFIG SUBSTITUTE COM1:,/dev/ttyll`, `CONFIG OPTION 51 ON`, `CONFIG BASEYEAR 1950`). Unlike the
file, the `CONFIG` command **accepts keyword abbreviations**; both accept `%env-var%` substitution.
Supported keywords include `APPLICATION_NAME`, `ATTRIBUTE`, `BASEYEAR`, `BREAK`, `CHAINDFLT`,
`COLLATE`, `COLOR`, `CONSOLE`, `CURSOR`, `DATABASE`, `DATAHILITE`, `DATE`, `DECIMAL`, `DIMONLY`, `DRIVE`
*(file only)*, `EDITOR`, `FIELDBREAK`, `FIELDHELP`, `FILENAMES`, `FONT`, `FONTFAMILY`, `FORCE VISIBILITY`,
`GRID_CURSOR_MOVE`, `GUI`, `HELPDFLT`, `HTTP`, `HTTPS`, `INSERT`, `KEYBOARD`, `LOGGING`, `MAX_SORT_MEMORY`,
`MAXRECALL`, `MIN_FONTSIZE`, `OPTION`, `PAGEOFLOW`, `PDF_READER`, `PICTURE`, `PRINTDIR`, `PRINTSCREEN`, `RD`,
`S/36-MODE`, `SCREEN`, `SEARCH_CHAR`, `SETENV`, `SHELL`, `SOFLOW-GROW`, `SPOOLCMD`, `STATUSLINE`, `STYLE`,
`SUBSTITUTE`, `TYPEAHEAD`, `USERLEVEL`, `WINDOWS_THEMES`, `WORKPATH`, `WSID`,
… (`DRIVE`, `FLOWSTACK`, `FORSTACK`, `RPNSTACK`, `WORKSTACK` are **BRConfig.sys-only**). A `CONFIG` line >128 chars
raises error 1060. `EDITOR "<path>" [REMOVE][NOWAIT]` names the external editor used by the
[`EDIT` command](../../70-commands/editing/spec.md#edit) (`REMOVE` deletes the `.brs` workfile after
merge; `NOWAIT` skips the Enter-to-merge wait).

<a id="examples"></a>
## Examples

```text
DRIVE C:,F:\MYAPP,SERVER-2,\PRL
DRIVE E:,%USERPROFILE%\BR_DATA,,
SUBSTITUTE PRN:/20,COM2:           ! route the "letter-quality" class to a real port
ATTRIBUTE [ERROR]R/RGB:R
FONT Arial
BASEYEAR 1950
FILENAMES LOWER_CASE SEARCH
INSERT ON MIN_LENGTH 10
PRINTER HPLASER INIT LPP 66, "\E&k2G\E(s10H\E&l6D\E&l0O"
SPOOLPATH @::C:\BR\SPOOL
EDITOR "C:\Program Files\Notepad++\notepad++.exe" NOWAIT
LOGGING 5, debug.log
```
```business-rules
00010 EXECUTE "CONFIG OPTION 51 ON"    ! override a BRConfig.sys OPTION at runtime
```

<a id="see-also"></a>
## See also

- [environment](../environment/spec.md) — `%VAR%` substitution, `DRIVE` with env vars
- [client-server](../client-server/spec.md) — `@`/`@:` client-side directives, `OPTION 30`, module layout
- [installation-tooling](../installation-tooling/spec.md) — external editors, DLLs
- [20-io-screen/fields-attributes](../../20-io-screen/fields-attributes/spec.md) — using `[name]` attributes/fonts
- [70-commands/editing](../../70-commands/editing/spec.md#edit) — the `EDIT` command that uses `EDITOR`
- [70-commands/information](../../70-commands/information/spec.md) — `STATUS`/`CONFIG`/`LOGGING` at the console
- Backing keyword pages retained (deep reference): [OPTION_(Config)](OPTION_(Config).md) (full 0-99
  table), [PRINTER.SYS](PRINTER.SYS.md) (PCL/NWP substitutions), [Multi-spooled_printers](Multi-spooled_printers.md)
  (SUBSTITUTE/printer-class scheme), [LOGGING](LOGGING.md) (level table), [RD](RD.md) (precision tables),
  [Attribute_(Config)](Attribute_(Config).md) (attribute/help-color reference), [Font](Font.md)
  (FONT/`SCREEN OPENDFLT` fonts, qualifiers & width-fit — added from the BR wiki in 2b), [Dll](Dll.md)
  (module/adjunctive-file layout). *(The `.NET`/PEM controls page was relocated to
  [20-io-screen/controls](../../20-io-screen/controls/spec.md#see-also) — it documents GUI controls, not config.)*

*(The other ~50 backing pages were folded into this spec and pruned.
The 8 redirect-collision pages re-fetched in 2b — `PrintDir`, `DATAHILITE`, `FIELDBREAK`, `FLOWSTACK`,
`FORSTACK`, `HELPDFLT`, `Min_FontSize`, `BRConfig.sys` — were folded here and pruned; their verbatim
wikitext remains on the BR wiki.)*
