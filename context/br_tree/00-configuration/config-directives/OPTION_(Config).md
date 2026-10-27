---
title: OPTION_(Config)
file: OPTION_(Config).md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [Option (disambiguation), BRConfig.sys, Config, INPUT FIELDS, 4.18, ISAM, BTREE, 4205, IOERR, CONV]
---

# OPTION (config) — numbered feature toggles

The numbered **`OPTION`** feature toggles used in the `BRConfig.sys` file. Most may also be enabled
at runtime with a **`CONFIG OPTION <n>`** statement, and most can be disabled with **`CONFIG OPTION
<n> OFF`** (the last column notes which support the `OFF` form and from which release).

From within a BR program:

```business-rules
00010 EXECUTE "CONFIG OPTION 1"
```

Or set at `BR32.exe` launch by a line in `BRConfig.sys`:

```
OPTION 37
```

See also `Option (disambiguation)`.

<a id="option-table"></a>
## Option table

| Option | Description | `CONFIG OPTION n OFF`? |
|---|---|---|
| `INVP` | Normal input of commas and periods is interchanged in `PIC`, `N`, `NZ`, `L`, `G` and `GZ` format specifications to support European-style numbers. (From `INPUT FIELDS`) | |
| `1` | **No longer used** (BR 5.01; accepted and ignored). It made a `FORM` repeat count below 1 count as 1. A count below 1 skips the item or group. | Yes (`4.18`+) |
| `2` | keyboard values less than `0x20` not ignored | Yes (4.18+) |
| `3` | set print flags | |
| `4` | **No longer used** (BR 5.01; accepted and ignored). It padded display output to the record length when `EOL=NONE`. Only what is printed is written. | Yes (4.18+) |
| `5` | default to `ISAM` (index type 4). The normal default is `BTREE` (index type 7) | |
| `6` | **BR 5.0.** `COPY` and `RENAME` onto a file that exists do not ask: `COPY` replaces it silently and `RENAME` refuses it with error `4150` unless `-F`, as before 5.0. Off (the default), the operator is asked `Overwrite <name>? (y/n/all)` - see [COPY and RENAME](../../70-commands/file-directory/spec.md#overwrite). (Before 5.0 this number was keep path on exit, long since withdrawn and accepted as a no-op, so a configuration file still carrying `OPTION 6` keeps the behaviour it always had.) | Yes |
| `7` | **No longer used** (BR 5.01; accepted and ignored). It turned off the hanging `THEN`/`ELSE` check (error 1121) in `IF` statements. The check is always made. | Yes (4.18+) |
| `8` | **BR 5.0.** `DIR` lists as it did before 5.0, as if every `DIR` were given `-O`: the 8.3 layout with two-digit years, and the pre-5.0 meanings of `-A`, `-L`, `-N`, `-O` and `-U`. Off (the default), `DIR` gives the 5.0 listing: ISO dates, sizes in full, long names only, sorted by name. (Before 5.0 this number was use old style loop counter for keyboard, long since withdrawn; 4.3 refused it as a bad `OPTION`, so no working configuration file carries it.) | Yes |
| `11` | **No longer used** (BR 5.01; accepted and ignored). It kept variables no line of the program refers to any more. Once an edit has removed a variable's last reference, the variable is removed when the program is next saved, replaced, run, chained or continued with `GO`. | Yes (4.18+) |
| `13` | sets the number of milliseconds for scancodes wait, e.g. `Option 13 200` (this number can be incremented by 20 till it reaches 400) | |
| `14` | **Ignored as of BR 5.01**, and not listed by `STATUS`. When a program has the same file open on two channels, both channels can lock the same record, always: a read through the second channel of a record the first holds succeeds at once, and the record stays locked against other sessions until the last channel holding it lets go (by moving to another record, `RELEASE`, `REWRITE`, `DELETE` or `CLOSE`). A configuration that still has `OPTION 14` loads normally. | Yes (4.18+) |
| `15` | suppress indentation of comment continuation | Yes (4.18+) |
| `16` | **No longer used** (BR 5.01; accepted and ignored). It hid the program's name on `LOAD`, `SAVE` and `REPLACE`. The name is shown. | Yes (4.18+) |
| `17` | don't consolidate `4205` error codes | Yes (4.18+) |
| `18` | **Ignored as of BR 5.01**, and not listed by `STATUS`. `DAYS` of a numeric date with more digits than a format with a year and no century takes (`DAYS(20261225,"YMD")`) always reads the extra digits as the century, as `CYMD`. A configuration that still has `OPTION 18` loads normally. | Yes (4.18+) |
| `19` | **No longer used** (BR 5.01; accepted and ignored). On SCO before version 5 it subtracted a day from the system date after February 2000. | |
| `21` | make `date$(0)` yield 12/31/1899 | Yes (4.18+) |
| `22` | **BR 5.01.** Create new indexes in BTREE (not BTREE2) format. Without it (the default, or `OPTION 22 OFF`), `INDEX`, `INDEX ... REPLACE` and an `OPEN` that creates a key file make BTREE2 indexes; with it on, they make BTREE indexes. A configuration that says `OPTION 22` therefore gets BTREE indexes. The option decides only what a new index is made as: each index records its kind and is opened as that kind whatever the option says, and one master may have indexes of both kinds open together. `INDEX ... REPLACE` remakes an index as the kind the option asks for. In releases before 5.01, `OPTION 22` makes BTREE2 indexes and its absence BTREE ones. | |
| `23` | make `IOERR`s not move file pointer forward to next record. BR will advance the record pointer when a successful read I/O operation occurs, even when a `CONV` (conversion) error takes place during the read operation. This Option lets the `IOERR` exit condition occur only when the record pointer is not advanced | Yes (4.18+) |
| `24` | disable `X` attributes during `SELECT`. Prior to BR version `3.9`, this Option had a different meaning. Originally, Option 24 specified that a file should be freed and recreated when opened `REPLACE` to avoid a NOVELL failure to truncate the file. But BR *now* automatically truncates. If it can't for some reason, THEN it will remove the file and recreate it. Effective with BR 3.9+, Option 24 suppresses the recognition of the `X` attribute during `INPUT SELECT` operations. BR versions prior to 3.9 operated this way by default — without the Option — even though the documentation indicated that `X` applies to `SELECT` operations. | Yes (4.18+) |
| `25` | make `file$(0)` be `CON:` (if in Windows) | Yes (4.18+) |
| `26` | suppresses the creation of `.BAK` files during `Replace` | Yes (4.18+) |
| `27` | Ignore Invalid Y2K Key Data (err `4120`) | Yes (4.18+) |
| `28` | **No longer used** (BR 5.01; accepted and ignored). It refused a `PRINTER` substitution statement that named no printer type. A substitution with no type goes into the default table, which every printer uses for any code its own type does not define. | Yes (4.18+) |
| `29` | Save programs as `.WB` files. (Default is `.BR`) | Yes (4.18+) |
| `30` | server side printing for client-server. | Yes (4.18+) |
| `31` | suppress `native windows printing`; treat `WIN:/` as direct printing | Yes (4.18+) |
| `32` | Suppress notification of error `6245`, which indicates an invalid or unsupported (by BR) escape sequence has been printed during `Native Windows Printing`. | Yes (4.18+) |
| `33` | `( 30  31  32  64 )` (default is 64 as of BR 5.01 on Windows, Linux and macOS, 31 elsewhere) `Record locking` for large file support. The problem addressed by this Option was that BR doesn't actually lock records, but locks a byte corresponding to each record in a zone way beyond the actual file. The filespace doesn't really have to exist to allow locking. This permits `ODBC` and other report writers to access locked records. BR also uses this zone to arbitrate the types of Open allowed. With BR 3.9, some file sizes were growing into the zone, and records were being locked inadvertently.<br>• `Option 33 30` — 1GB maximum bytes in a data file.<br>• `Option 33 31` — 2GB limit (the default before 5.01).<br>• `Option 33 32` — 4GB limit.<br>• `Option 33 64` — turns on 64-bit locking (the default). Every engine that shares files, BR and the ODBC driver alike, must use the same setting: engines that share a `wbserver.dat` refuse a mismatch (*OPTION 33 mismatch using wbserver.dat*), but engines that do not share one would lock in different places and not exclude each other. | |
| `34` | sends print screen images to `PRN:/10` instead of `PRN:/SELECT`. | Yes (4.18+) |
| `35` | Honor keepalive timeout (no longer available) | Yes (4.18+) |
| `36` | Enables the cursor during `INPUT SELECT`. This Option is needed for some hand held scanners that do not have the ability to display in reverse image. | Yes (4.18+) |
| `37` | With versions `4.14`+, BR returns an `FKEY` value of 116 when exiting a field with right arrow.<br>With OPTION 37 on, BR returns an `FKEY` value of 104 which is the same as the down arrow. This (104) is how BR worked previously. | Yes (4.18+) |
| `38` | This suppresses an error caused by specification of an `N` in the trailing attribute position. This Option is provided only for legacy purposes. | Yes (4.18+) |
| `39` | Suppresses the automatic right alignment of labels ending with a colon. | Yes (4.18+) |
| `40` | Show hot text as buttons by default. Normally hot text does not appear as a button unless the fkey value is preceded with a `B`. This Option can be selectively overridden by preceding the fkey value with an `H`. | Yes (4.18+) |
| `41` | Ignore GUI statements when they are encountered in non-GUI mode. | Yes (4.18+) |
| `42` | Suppress automatic drive mapping during Windows shell calls. | Yes (4.18+) |
| `43` | `INPUT SELECT` changes fields before returning control; use old style Input Select with respect to setting `CURFLD` to the `NXTFLD` value when a selection is made. | Yes (4.18+) |
| `44` | Make the mouse wheel produce the same result as the arrow keys when control is returned to a program via the `E`, `L` or `X` field attributes. Without this Option, the mouse wheel returns Fkey results of 124/125 (up arrow/down arrow). With this Option it returns 102/104 during `INPUT FIELDS` and 105/106 during `INPUT SELECT` operations (normal arrow key responses). Note: Option 44 is NOT needed to use the mouse wheel. It only pertains to Fkey results with `E`, `X` or `L`. | Yes (4.18+) |
| `45` | Allows the old method of extended field specification in addition to the new method. | Yes (4.18+) |
| `46` | Normalizes numpad + and − keys. This removes Field Plus / Minus special processing, which is no longer needed with Datahilite field clearing. | Yes (4.18+) |
| `47` | Enable the continued use of `PRINTER=` in `OPEN` statements. | Yes (4.18+) |
| `48` | **Note — OPTION 48 functionality was changed in version `4.2`.** If OPTION 48 is not specified, ENTER will return an `FKEY` value of zero and a double-click will return any `FKEY` value assigned to the field. Use OPTION 48 only to have the ENTER key return any `FKEY` value assigned to the field. | Yes (4.2+) |
| `49` | Omit the spool file's path: `[SPOOLFILE]` in `SPOOLCMD` is replaced by the file name only (`SPL0001.TXT`), not its full path. The command must then find the file without its directory, for example by running in the spool directory. | Yes (4.18+) |
| `50` | Suppress theme usage for text controls. This enables the Windows classical look under XP. | Yes (4.18+) |
| `51` | **BR 5.01.** Do **not** reuse deleted records. Without it (the default, or `OPTION 51 OFF`), a `WRITE` of a new record to an internal file takes a deleted record instead of adding one, the last deleted first, and that record's old contents are lost for good; with it on, new records are added at the end. A configuration that says `OPTION 51` therefore gets no reuse. The file keeps its deleted records in a chain: a file made while records are reused has it from the start, and an existing file gets one, with every deleted record in it, the first time it is opened for `OUTPUT` or `OUTIN` while records are reused. An `INPUT` open changes nothing. `VERSION(n, v)` with a negative `v` keeps the version and empties the chain, so the next such open builds it again. **Files that cannot have it** simply grow: records shorter than 4 bytes, and record lengths whose header has no 4 bytes to spare (14 to 17). **Keyed files:** a record deleted while one of its indexes was not open leaves that index's key behind. In a file that reuses records, a keyed read therefore checks the record a key leads to: a deleted record, or one whose own key (built as `WRITE` builds it) is not that key, is treated as not there, so `KEY=` answers key not found and a sequential keyed read goes on to the next key. That holds for every engine reading the file, whatever its `OPTION 51`. **Sharing:** engines with the option on, and earlier releases, can use the file at the same time. They append, and a record they delete is reused once the file is next opened for output by an engine that reuses records, which links it into the chain. `COPY -D` gives the copy an empty chain. | Yes (4.18+) |
| `52` | Enable the second click of a double click operation to produce its own interrupt with `FKey` value 201. | Yes (4.18+) |
| `53` | Allow mouse positioning inside a field other than the current field. Without this Option, clicking anywhere in a non-current active input field will process it as though the field were entered via the arrow keys. | Yes (4.18+) |
| `54` | Exit BR! at any console command prompt with a message box showing program name and `line number:clause`. Waiting for input by a program has no affect. | |
| `55` | **Retired in BR 5.0**, and refused in `BRConfig.sys`; `STATUS CONFIG` reports `OPTION 55 - no longer used`. Remove it from configuration files. (It used to position each character of a fixed-width font individually, for fonts whose characters are not all exactly the same width.) | n/a - refused |
| `56` | `Srch` return -1 instead of 0 when no match is found. | |
| `57` | Clear Fkeys of inactive `Q` combo box fields. | Yes (4.18+) |
| `58` | `On FnKey` has been disabled in 4.20+ (use `On FKey` instead), however this option restores recognition of `FnKey`. | Yes (`4.20`+) |
| `59` | Make `CurCol` (not `NxtCol`) work the old way: use cursor position instead of field start for `CURROW`/`COL` | ??? |
| `60` | **BR 5.0: a new meaning.** `SAVE` and `REPLACE` write the 4.2/4.3 object format (save level 38), so a 4.2 or 4.3 BR can load the program. Without it, 5.0 saves level 39, which an earlier BR refuses with error `2240`. The cost is that the source line positions are not saved. It affects saving only: 5.0 loads every format either way. It also sets `OPTION 74`. (Before 5.0 it saved the 4.18-and-earlier format, which 5.0 no longer writes.) | Yes |
| `61` | Do not Map a Drive if not explicitly defined by `DRIVE` statements in `BRConfig.sys` | |
| `62` | Use Draw Line Border Specification (otherwise report error!). | |
| `63` | Allow `INPUT SELECT` to input data; `INPUT SELECT` "Reads Data" — we should use `INPUT FIELDS` with `^LABEL` instead! | |
| `64` | `15` Allows max network delay for passing data to client. | |
| `65` | Ignore `ON ATTN` statements. | |
| `66` | The secret key to be used for encryption. | |
| `67` | Data Hilite on every `INPUT FIELDS` statement. | |
| `68` | Prevent stretching printed fonts. | Yes |
| `69` | ignore file closing errors during end or chain | Yes? |
| `70` | • Same as Option 54 (exits on any command console prompt) but allows a `Relaxed` parameter to allow for some debugging.<br>• `4.32`+ `ON SOFLOW IGNORE` overrides line error handlers as in previous versions | Yes and Relaxed (`4.30`+); `4.32`+ Yes? |
| `71` | Prevent `auto complete` for editable `combo boxes` (added in 4.32-ish) | Yes? |
| `72` | Prevent auto complete for `select` combo boxes (added in 4.32-ish) | Yes? |
| `73` | Adds the `WSID` to the temporary `edit` file names (added in 4.3) | Yes |
| `74` | Treat `IGNORE` as a label reference for line level error handlers | Yes? |
| `75` | `CURFLD()` reports the next input field. Normally `CURFLD()` returns the field the cursor was in when the `INPUT FIELDS` ended; with this on, the next `CURFLD()` read returns the field set by a preceding `CURFLD(n)` directive (the field the next input will start in), and then goes back to normal | Yes |
| `76` | **Takes a number, 1-500.** The size of the button bar, and the buttons in it, as a percentage of the standard size. The default is `100`. Set on the server and sent to the client | n/a - takes a number |
| `77` | In a newly opened print preview, `ENTER` closes the preview instead of printing it. Set on the server and sent to the client | Yes |
| `78` | **Takes two numbers, 0-127.** How much a grid or list selection lightens a dark background, then how much it darkens a light background, instead of drawing a blue overlay. The default is `40` for both | n/a - takes numbers |
| `79` | **Takes a number, 0-3.** Which font problems are reported to the program as errors: `0` all three (the default); `1` not 6253 (internal font resolution error); `2` also not 6251 (requested font not available); `3` also not 6249 (invalid font specification). Every condition is still written to the log whatever the level | n/a - takes a number |
| `80` | Characters per inch affects lines per inch for large fonts. Off (the default): the lines-per-inch setting is a ceiling, the type is brought down to fit it and the report keeps its line spacing. On: it is a bar - the type takes the size its pitch implies, and the line spacing opens up to follow it, at the cost of lines per page. Printing | Yes |
| `81` | 4.3.3 print compatibility. Off (the default): the type size comes from the pitch and every font is scaled to the cell. On: the type height is used as it stands and only fixed-pitch fonts are scaled, as 4.3.3 did. It implies nothing else; `OPTION 68` keeps its 4.3.3 meaning inside it and `OPTION 80` stays a separate choice. PDF printing only | Yes |
| `82` | Work off the display area: this session's windows are placed past the edge of the desktop and stay there, still live (they paint, can be captured and take posted keys, which a hidden window does not). Off unless asked for. Turning it off brings the windows back | Yes |
| `83` | The application may reach the operating system and may start BR sessions that are not restricted: `SYSTEM` calls are not asked about while an assistant is attached, and sessions started from here are not made restricted. **May be set only in the configuration file** - `CONFIG OPTION 83` while running is refused with error 4172 ("this OPTION may be set only in the configuration file, never with a CONFIG command"), and a restricted session refuses it | Yes |
| `84` | **BR 5.0.** How a `/` in a file name is read: as a System/23 name (`file/directory/drive`) or as a folder separator, and which is tried first. `OPTION 84 n`: `0` System/23 only; `1` (default) the name decides which is tried first, then the other if the file or folder is not found; `2` the same, but no second try; `3` System/23 first, then the other; `4` folder separator first, then the other; `5` folder separator only. See [file names](../../30-io-file/file-model/spec.md#slash). | Yes |
| `97` | set network retries per second (default is 5) | |
| `98` | turn OFF check for all NULL in read / writes | |
| `99` | turn ON check for all NULL in read / writes | |
