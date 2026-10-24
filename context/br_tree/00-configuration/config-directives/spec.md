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
keywords: [CONFIG, DRIVE, OPTION, DATABASE, SUBSTITUTE, STYLE, PRINTER, FONT, COLLATE, LOGGING, WORKPATH, PRINTDIR, SPOOLCMD, INCLUDE, SETENV, ATTRIBUTE, KEYBOARD, SCREEN, RD, STACKS]
corrections:
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
WORKPATH <path> 
```
- `DRIVE` maps a logical drive to physical paths (env variables allowed). 
   Subsequent filename references beginning with `@:` target the client, a second colon 
  (`@::C:\path` or `@::.\path`) makes the client path drive-independent (client OS paths). 
  Server filenames that begin with a colon also become drive independent (the colon is dropped). 
- `FILENAMES` controls the case of newly created files (+ case-insensitive `SEARCH` on  Linux/MAC). 
- `INCLUDE` pulls in another config file (nestable to 10 levels; relative to the *parent* file in 
  BRConfig.sys, but to the *current directory* when run as a `CONFIG` command; combine with 
  `%USER%` for per-user config).

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

<a id="spool-work"></a>**`SPOOLPATH`** sets where print spool files (and PDFs) are staged; it
defaults to a `SPOOL\` dir off the first `DRIVE`'s BR root and is auto-created. 
**`WORKPATH` and `BRSERVER`** default to the BR root. 

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
| initial current directory | first `DRIVE` location |

<a id="appearance"></a>
### Screen appearance
```bnf
APPLICATION_NAME <name>   
ATTRIBUTE [<name>] <attributes> [<defined-name>]   -- reusable attribute combos ([E],[I],[M],[W],…)
COLOR [<label>] <#hex|name>
CORNERS <top-left-char> <bottom-right-char> 
DATAHILITE {ON|OFF}
FILTER_DELIMITERS "<chars>"
FONT [ASPECT=n/d] [<fontname>] [3DFONT=<fontname>]
SCREEN OPENDFLT FONT=…, FONT.TEXT=…, FONT.LABELS=…, FONT.BUTTONS=…
FORCE VISIBILITY {ON|OFF}                           -- copy underlying labels/text into opened window
GUI {ON|OFF}
MIN_FONTSIZE <h>x<w>                                -- min console font in px; scroll bars when less
SCREEN C [<attr-name>]                              -- command-console fg/bg colors
SCREEN <type> [<attr-name>], …                      -- N/U/R/B/H base attributes
```
  SCREEN has 3 variants: 1) define standard sigle character attributes, 2) define open #0 
  (main console) default vaules, and 3) define command console attributes. 
- **`APPLICATION_NAME`** is displayed at the top of the main (#0) application window. 
- **`ATTRIBUTE`** defines named attributes/fonts referenced from
  [20-io-screen/fields-attributes](../../20-io-screen/fields-attributes/spec.md#subattributes).
  Attribute names may be up to **12 chars** (`[hilite_text]`), can carry a `font=name:slant:max`
  clause, and include help-screen colors `[HPROMPT]`/`[HTEXT]`/`[HLIGHTBAR]`/`[HMENU]`. 
- **`COLOR`** assigns a six hex digit value to a name; Color aliases may also be asigned.
- **`CORNERS`** sets two characters BR uses to build character based window/field-help borders.
- **`DATAHILITE ON`** (Windows default) reverse-videos each input field as it is entered and parks the
  cursor at the end of the data; `CONFIG DATAHILITE OFF` instead applies the user's Windows
  *selected-text* colors. `OFF` disables the Windows style highlighting. 
- `FILTER_DELIMITERS` When GRID and LIST are in use, a SEARCH or FILTER field can be specified. 
  Different types of searching can be performed, some of which are word oriented. Such searches use delimiters to identify words within text. The default delimiters are ` \"\\\t\r\n,.;:(){}[]!@#$%^&*-_=+/?|~<>`. FILTER_DELIMITERS supports specification of a replacement list of separator characters.
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

- **`FORCE VISIBILITY`** makes a newly opened GUI window copy in underlying labels/text 
  Legacy console see-through emulation — not for new development; no effect on GRID/LISTVIEW; 
  `CLOSE FREE` does the reverse — copies the child window's labels/text/buttons, but not pictures, 
  back onto the parent. 
- **`GUI ON`** uses true Windows objects; `GUI OFF` ("console mode") is fixed-font legacy
  compatibility (no grids/combos, PRINT scrolls). Programs may switch mid-run (`PRINT NEWPAGE` when
  toggling). 
- **`MIN_FONTSIZE <h>x<w>`** sets the smallest GUI/command-console font in pixels; shrinking the 
  window below it shows **scroll bars** instead of further shrinking the font (default `0x0` = off; change takes effect on the next resize/restore/maximize). 
- **`SCREEN C [<attr-name>]`** colors the command console — define an attribute then apply it, 
  e.g. `CONFIG ATTRIBUTE [CMD_CONSOLE]/#HRGB:R` then `CONFIG SCREEN C [CMD_CONSOLE]`. The full 
  attribute/help-color reference is retained: [Attribute_(Config)](Attribute_(Config).md).
- **`SCREEN`** statements may reference them (`SCREEN N [normal]`). `W` in an attribute = current Windows color.

<a id="behavior"></a>
### Language & I/O behavior
```bnf
BASEYEAR <year>                 -- 100-year window for DAYS (1900-2399; default 1900)
BREAK <lines>   
CHAINDFLT O                     -- letter O - search .BRO before .BR for CHAIN/LOAD
COLLATE {NATIVE|ALTERNATE}      
CONSOLE {ON|OFF|DATA_ONLY}
DATABASE <db-ref> { DSN=… | CONNECTSTRING="…" | ODBC-MANAGER } [,USER=…] [{,PASSWORD=… | PASSWORDD=…}]
DATAHILITE {ON|OFF}
DECIMAL {ASSUMED|REQUIRED} 
EDITOR "<path>" [REMOVE] [NOWAIT]   
EXECUTE "<command>"
FIELDBREAK MIN_SPACES <n> [, UNDERSCORE OFF]
FLOWSTACK <size>   
FORSTACK <size>   
HELPDFLT <keyword> <filename>
INSERT {ON|OFF} [MIN_LENGTH <0-99> | NON_PERSISTENT | SESSION_PERSISTENT | PERSISTENT]
INVP   -- (European comma/period swap)
KEYBOARD <scancode>,<sequence>  
LOGGING <max-level>, <logfile> [, UNATTENDED] [, DEBUG_LOG_LEVEL=<n>] [, +CONSOLE]
MAXRECALL <1-300>    
MAX_SORT_MEMORY <n> MB
PICTURE {CACHE_ON|CACHE_OFF}    
RD <0-15>                       -- numeric-comparison rounding tolerance (default 6)
SETENV <name> '<value>'         -- (CONFIG) simulate an OS env var for the session → ENV$()
STYLE [INDENT <n> <n>] {KEYWORD|LABEL|EXPRESSION [MIXED|UPPER|LOWER]} ...
```
- **`BASEYEAR`** underlies the [date functions](../../10-language/data-manipulation/system-functions/spec.md#date-functions):
  a 2-digit year ≥ its last two digits takes `BASEYEAR`'s century, else the next (dates before
  `BASEYEAR` can't be entered M/D/Y; the logical `DAYS` value is unchanged).
- **`BREAK <lines>`** sets how often (default 8 program lines) BR polls for `Ctrl-A`/`ON FKEY`.
- **`CHAINDFLT O`** flips the  `CHAIN`/`LOAD` extension search to `.BRO`-first.
- **`COLLATE NATIVE`** = ASCII order (digits<upper<lower); `COLLATE ALTERNATE` moves digits 
  *above* letters (EBCDIC-like, for legacy logic) — affects [keyed](../../30-io-file/keys-indexes/spec.md)/SORT order. 
- **`CONSOLE`** determines when the command console appears concurrently with the application window. 
  DATA_ONLY indicates diplay when not vacant.
- **`DATABASE`** defines an SQL connection by `DSN=`, `CONNECTSTRING=`, or `ODBC-MANAGER`
  (with `USER=` / `PASSWORD=`| encrypted `PASSWORDD=`).
- **`DATAHILITE`** (default ON) use Windows current field highlighting
- **`DECIMAL REQUIRED`** forces the operator to type the decimal point on fractional `N x.x` fields
  (default `ASSUMED` infers it).
- **`EDITOR`** names the external program the [`EDIT` command](../../70-commands/editing/spec.md#edit) 
  launches to edit `.brs`/`.wbs` editable source. `REMOVE` deletes the source workfile once editing completes;
  `NOWAIT` skips the Enter-to-merge wait. Source-capable editors include Notepad, Notepad++, PFE32,
  TextPad, MyEditBR, Source Edit, EditPad Pro, UltraEdit, JEdit, Crimson Editor, Epsilon, ConTEXT,
  WinHighlight, Editra, and Cursor.
- **`EXECUTE`** specifies a command to be executed upon BR initialization.
- **`FIELDBREAK`** splits an input field into sub-controls at n+ consecutive
  blanks (`, UNDERSCORE OFF` excludes underscores from whitespace count).
- **`FLOWSTACK`/`FORSTACK`** size the GOSUB/function-return and FOR/NEXT stacks (both default **100**);
  The FOR stack counts loop variables by *name* — one slot per distinct variable no matter how many 
  `FOR` loops reuse it. Both are **BRConfig.sys-only — not valid as a `CONFIG` command; `STATUS STACKS` shows current settings. (`RPNSTACK`/`WORKSTACK` similarly size the expression and work stacks.)
- **`HELPDFLT <keyword> <filename>`** sets the
  default help topic and file shown when the **HELP key (Ctrl-Y)** is pressed during `RUN`/`INPUT` mode,
  and the default file for the [`HELP$`](../../10-language/data-manipulation/system-functions/spec.md)
  function (runtime-only; overridable via `CONFIG`). With no `HELPDFLT`, the HELP key does nothing
  outside INPUT mode (`ON HELP SYSTEM` behaves as `ON HELP IGNORE`) and `HELP$` requires an explicit
  filename; help files are searched current dir → base node of the first `DRIVE` → BR start dir.
- `INSERT` sets overtype/insert persistence scope (default `ON PERSISTENT`; overridden 
  by `DATAHILITE`). Persistent means remember the last operator setting. `MIN_LENGTH` specifies a second setting for fields => specified length. NON_PESISTENT - reset upon field exit; SESSION_PERSISTENT - reset upon exiting Business Rules; PERSISTENT - keep operator setting across BR exits.
- `KEYBOARD` builds keystroke macros from BR scancodes (`CON KEYBOARD [<scancode>] CLEAR` removes them); 
- `LOGGING` filters by level 0 (major-error) … 15 (obnoxious detail); commands entered log at 8, `TRACE`/`DISPLAY` at 12, and console `PRINT` output is never logged; `UNATTENDED` runs headless and exits on input; 
  `+CONSOLE` echoes `DEBUG_STR` messages to the console (GUI ON; automatic at level ≥ 11). Full level table: [LOGGING](LOGGING.md).
- `MAXRECALL` sizes F2 command recall (default 200). 
- `MAX_SORT_MEMORY` default is 8 MB; range is 2 - 512 MB.
- `PICTURE` Default `CACHE_ON` caches images by image filename.
- `RD` sets how many decimal digits are significant in numeric `IF`/`FOR` comparisons, 
  `AIDX`/`DIDX`, `INT`/`IP`/`STR$`, SORT `RECORD`, and default `PRINT` (default 6; internal math is always 15-digits). Deep precision tables: [RD](RD.md).
- **`SETENV`** simulates an OS environment variable for the rest of the BR session 
  so [`ENV$("<name>")`](../environment/spec.md) returns it, shadowing any real variable of that name for the session's duration. **Printer-init strings** may be up to **64 bytes**.
- `STYLE` sets `LIST` formatting. The first number is indentation increment size; the second number is comment indentation position.

<a id="printer"></a>
### Printer & spooling
```bnf
PRINTER [<type>] INIT [HP] [LPP <n>], "<escape>" 
PRINTER [<type>] RESET, "<init>"
PRINTER [<type>] [<mode>], "<escape>"
PRINTER TYPE <type> SELECT <substring>
SPOOLCMD [@] [-w] <command> [SPOOLFILE] [COPIES] [PRINTQUEUE]
SPOOLPATH [@:] <directory>
<escape> ::= { <hex-value-string> | "<char-string>" }
INCLUDE PRINTER.SYS
```
Configures printer escape sequences and spooling (the `@`/`@:` forms target the client in
client-server). 
`INIT` indicates that the succeeding <escape> value should be sent whenever the specified printer is opened.
`PRINTER xxx INIT HP <hex-values>` prepends laser keywords legacy codes.
`PRINTER TYPE` assigns a printer type to a specific printer; <substring> is a case sensitive OS printer name substring.
**`PRINTER.SYS`** is a shareable BRConfig.sys of named PCL/NWP mode substitutions (`[LANDSCAPE]`, `[LETTER]`, `[BOLD]`, `[BOX]`, `[FONT]`, `[COLOR]`, `[PICTURE]`…) — the full catalog is the retained [PRINTER.SYS](PRINTER.SYS.md) reference. The printer *statements* are in [40-io-printing/statements](../../40-io-printing/statements/spec.md). 
Standard escape codes are in [40-io-printing/pcl-pdf](../../40-io-printing/pcl-pdf/spec.md).

<a id="config"></a>
## Applying & overriding — the `CONFIG` command
Most directives can be changed after launch, without editing BRConfig.sys:
```bnf
CONFIG <keyword> <spec>                 -- as a command (CON); STATUS CONFIG lists current settings
EXECUTE "CONFIG <keyword> <spec>"       -- the same, from program code
```
`CONFIG` overrides the BRConfig.sys value for the rest of the session (e.g.
`CONFIG SUBSTITUTE COM1:,/dev/ttyll`, `CONFIG OPTION 14 OFF`, `CONFIG BASEYEAR 1950`). Unlike the
file, the `CONFIG` command **accepts keyword abbreviations**; both accept `%env-var%` substitution.
Supported keywords include `APPLICATION_NAME`, `ATTRIBUTE`, `BASEYEAR`, `BREAK`, `CHAINDFLT`,
`COLLATE`, `COLOR`, `CONSOLE`, `CURSOR`, `DATABASE`, `DATAHILITE`, `DECIMAL`, `DIMONLY`, `DRIVE`
*(file only)*, `EDITOR`, `FIELDBREAK`, `FILENAMES`, `FONT`, `FORCE VISIBILITY`, `GUI`, `HELPDFLT`,
`INSERT`, `KEYBOARD`, `LOGGING`, `MAX_SORT_MEMORY`, `MAXRECALL`, `MIN_FONTSIZE`, `OPTION`, `PAGEOFLOW`,
`PICTURE`, `PRINTDIR`, `RD`, `SCREEN`, `SETENV`, `SPOOLCMD`, `STYLE`, `SUBSTITUTE`, `WORKPATH`, `WSID`,
… (`DRIVE`, `FLOWSTACK`, `FORSTACK` and `S/23-DRIVES` are **BRConfig.sys-only**). A `CONFIG` line >128 chars
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
00010 EXECUTE "CONFIG OPTION 14 OFF"   ! override a BRConfig.sys OPTION at runtime
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
