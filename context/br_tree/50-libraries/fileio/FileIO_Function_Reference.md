---
title: FileIO Function Reference (source-derived)
file: FileIO_Function_Reference.md
source: fileio.brs (shipping library source) — signatures verified against every DEF LIBRARY export
category: 50-libraries
subcategory: 50-libraries/fileio
kind: reference
status: deep-reference          # source-of-truth export list; complements the online-doc FileIO_Library.md
related: [library-facility, screenio]
---

# FileIO Function Reference (source-derived)

FileIO's public surface is **80 `DEF LIBRARY` functions** in `fileio.brs`. Every signature below is taken
verbatim from the shipping source (not the wiki), so this page is the **authoritative export list**; the
prose/tutorial reference is [FileIO_Library.md](FileIO_Library.md). Parameters after `;` are optional; `&`
is pass-by-reference; `Mat` is an array; a trailing `$*n` is the string return length. Trailing
`___,locals…` in a signature are internal locals (BR's convention for hiding them after `___`) — callers
never pass them; they are omitted from the descriptions.

Most programs don't call `Fnopenfile` directly — they use a thin local `DEF FNOPEN` wrapper around it (see
[FileIO_Library.md → fnOpen](FileIO_Library.md#fnopen-function)). The arrays `Mat F$` / `Mat F` (record
data) and `Mat Form$` (per-channel FORM, indexed by file number) recur throughout.

<a id="open-close"></a>
## Opening, closing & file numbers

| Function | Signature (caller args) | Purpose |
|---|---|---|
| `Fnopenfile` | `(&Filename$, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, &Path$, Mat Description$, Mat Fieldwidths, Mat FileIOSubs$, SupressPrompt, IgnoreErrors, CallingProgram$, SuppressLog, Mat FileIODateFmt$)` | **The core open.** Opens a file by layout name; sizes `Mat F$`/`Mat F`, loads `Form$(chan)`, returns the **file number**. `Inputonly=1` read-only; `Keynum` picks the index; returns the subscript-constant EXECUTE strings in `Mat FileIOSubs$`. |
| `Fnclosefile` | `(Filenumber, Filelay$; Path$, Out)` | Close a FileIO-opened file (and its bookkeeping). Pair with zeroing the channel variable. |
| `Fngetfilenumber` | `(; Start, Count)` | Find a free BR file-channel number in a range. |
| `fnUpdateFile` | `(FileLayout$)` | Rewrite a data file to match its **current** layout (after a layout change). |
| `Fnkey$` | `(Filenumber, Key$)` | Return the full stored key for a record on an open channel. |

<a id="layout"></a>
## Layout interrogation & FORM building

| Function | Signature | Purpose |
|---|---|---|
| `fnReadEntireLayout` | `(Layoutname$; &Filename$, &Prefix$, Mat Keys$, Mat KeyDescription$, Mat Ssubs$, Mat Nsubs$, Mat Sspec$, Mat Nspec$, Mat Sdescription$, Mat Ndescription$, Mat Spos, Mat Npos, Mat sdatefmt$, Mat ndatefmt$)` | Read **everything** about a layout: filename, prefix, keys, string/numeric subscripts, specs, descriptions, positions, date formats. |
| `FnReadLayoutHeader` | `(Layoutname$; &Filename$, Mat Keys$, Mat KeyDescription$, LeaveOpen, &Prefix$)` | Just the header (filename, keys, prefix). |
| `Fnreadsubs` | `(Filename$, Mat Ssubs$, Mat Nsubs$, &Prefix$)` | The string/numeric subscript-name arrays + prefix. |
| `Fnreadlayoutarrays` | `(Layoutname$, &Prefix$; Mat Ssubs$, Mat Nsubs$, Mat Sspec$, Mat Nspec$, Mat Sdescription$, Mat Ndescription$, Mat Spos, Mat Npos, AlreadyOpenFileNumber, Mat sdateformat$, Mat ndateformat$)` | The parallel subscript/spec/description/position arrays. |
| `fnReadKeyFiles` | `(layout$, Mat keys$)` | The key-file names for a layout. |
| `fnReadForm$` | `(Filename$)` → `$*10000` | The FORM string for a layout/file. |
| `fnReadFormAndSubs` | `(filename$, Mat subs$, &readform$, &stringsize, &numbersize)` | FORM plus subscript names and string/numeric counts. |
| `Fnreadlayouts` | `(Mat Dirlist$; OverrideExtension$)` | List all layout names in the layout folder. |
| `fnDirVersionHistoryFiles` | `(Layout$, Mat DirList$; BypassExtension$)` | List a layout's version-history files. |
| `Fndoeslayoutexist` | `(Layout$)` | 1 if the named layout exists. |
| `FnReadLayoutPath$` | *(no args)* → `$*255` | The configured layout path (`fnSettings$("layoutpath")`). |
| `FnReadLayoutExtension$` | *(no args)* | The configured layout-file extension (`fnSettings$("layoutextension")`). |
| `fnClearLayoutCache` | *(no args)* | Clear the in-memory layout cache (alias of `fnClearCache`). |
| `fnWriteLayout` | `(Name$, filename$, Ver, Pre$, Mat kfname$, Mat kdescription$, Mat subs$, Mat descr$, Mat Form$; Recl, Mat Extra$, DisplayFile)` | Write/create a layout definition (alias of `fnWriteLay`). |
| `fnLength` | `(Spec$)` | The **internal** (stored) byte length of a FORM spec. |
| `FnDisplayLength` | `(Spec$)` | The **display** width of a FORM spec. |
| `Fnmakesubproc` | `(Filename$; Mat Subs$, Mat f$, Mat f)` | Build the subscript-constant proc for a layout. |

<a id="keys"></a>
## Keys & key lists

| Function | Signature | Purpose |
|---|---|---|
| `fnBuildKey$` | `(layout$, Mat f$, Mat f; keynum)` → `$*255` | Build the key string for a record per the layout's key definition. |
| `Fnuniquekey` | `(Fl, Key$)` | 1 if `Key$` is not already present on channel `Fl`. |
| `Fnmakeuniquekey$` | `(Fl; Random, Prepend$)` → `$*255` | Generate a key not already in the file. |
| `fnSortKeys` | `(Mat Keys$, Layout$, DataFile, Mat F$, Mat F, Mat Form$; KeyNum)` | Sort a key array by a layout index. |
| `Fnreadallkeys` | `(Fl, Mat F$, Mat F, Mat Fm$, Sub1, Mat Out1$; Sub2, Mat Out2$)` | All values of field(s) `Sub1[,Sub2]` across the file. |
| `Fnreadmatchingkeys` | `(Fl, Mat F$, Mat F, Mat Fm$, Key$, Keyfld, Sub1, Mat Out1$; Sub2, Mat Out2$)` | Field values for records whose `Keyfld = Key$`. |
| `Fnreadallnewkeys` | `(Fl, Mat F$, Mat F, Mat Fm$, Sub1, Mat Out1$; Dont_Reset, Sub2, Mat Out2$)` | Incremental "new since last call" variant. |
| `Fnreadfilterkeys` | `(Fl, Mat F$, Mat F, Mat Fm$, Key$, Keyfld, Sub1, Mat Out1$; Filter$, Filter_Sub, Readlarger, Sub2…Sub4, Mat Out2$…Out4$)` | Matching keys with an extra field filter; up to four output columns. |

<a id="field-readers"></a>
## Single-field readers (lookup a field by key or record #)

| Function | Signature | Purpose |
|---|---|---|
| `Fnreaddescription$` | `(Fl, Subscript, Key$, Mat F$, Mat F, Mat Fm$; DontChangeKey)` → `$*255` | String field `Subscript` of the record keyed `Key$` (file already open). |
| `fnReadUnopenedDescription$` | `(layoutname$, key$; Field, DontChangeKey)` → `$*255` | Same, but opens the layout for you. |
| `Fnreadnumber` | `(Fl, Subscript, Key$, Mat F$, Mat F, Mat Fm$; DontChangeKey)` | Numeric field by key (open file). |
| `fnReadUnopenedNumber` | `(layoutname$, key$; Field, DontChangeKey)` | Numeric field by key (self-opening). |
| `Fnreadrelativedescription$` | `(Fl, Subscript, RecordNumber, Mat F$, Mat F, Mat Fm$)` → `$*255` | String field by **record number**. |
| `fnReadRelUnopenedDescription$` | `(layoutname$, RecordNumber; Field)` → `$*255` | …self-opening. |
| `Fnreadrelativenumber` | `(Fl, Subscript, RecordNumber, Mat F$, Mat F, Mat Fm$)` | Numeric field by record number. |
| `fnReadRelUnopenedNumber` | `(layoutname$, RecordNumber; Field)` | …self-opening. |
| `fnReadRecordWhere$` | `(layoutName$, SearchSub, SearchKey$, ReturnSub)` → `$*255` | Scan a layout for `SearchSub = SearchKey$`; return `ReturnSub`. |
| `Fnnotinfile` | `(String$, Filename$, Sub; Path$)` | 1 if `String$` is **not** a value of field `Sub` in the file. |

<a id="maintenance"></a>
## Reindex & file maintenance

| Function | Signature | Purpose |
|---|---|---|
| `fnReIndex` | `(DataFile$; CallingProgram$, IndexNum, Path$)` | Rebuild a data file's index/indexes. |
| `fnReIndexAllFiles` | *(no args)* | Reindex every layout. |
| `fnRemoveDeletes` | `(LayoutName$; Path$, CallingProgram$, DontError)` | Compact a file, dropping deleted records. |

<a id="datacrawler"></a>
## DataCrawler & data-grid UI

| Function | Signature | Purpose |
|---|---|---|
| `Fndatacrawler` | `(Filelay$; srow$, scol$, rows$, cols$)` | The interactive data browser/editor for any data file described by a layout. |
| `Fndataedit` | `( … )` | Editable DataCrawler entry point. |
| `fnShowData` | `(FileLay$; Edit, sRow, sCol, Rows, Cols, KeyNumber, Caption$, Path$, KeyMatch$, SearchMatch$, CallingProgram$, Mat Records, Mat IncludeCols$, Mat IncludeUI$, Mat ColumnDescription$, Mat ColumnWidths, Mat ColumnForms$, DisplayField$, Mat FilterFields$, Mat FilterForm$, Mat FilterCompare$, Mat FilterCaption$, Mat FilterDefaults$, Mat FilterKey, IncludeRecordNumbers, BypassDateProcessing)` | Show (optionally edit) a file in a grid with column/filter control. |

<a id="csv"></a>
## CSV import / export

| Function | Signature | Purpose |
|---|---|---|
| `fnCsvImport` | `(Layout$; SupressDialog, FileName$, ImportModeKey)` | Import a CSV into a layout's file. |
| `fnCsvExport` | `(Layout$; DialogType, Filename$, IncludeRecNums, KeyNumber, StartKey$, KeyMatch$, Startrec, Mat Records, SearchMatch$, Launch)` | Export a file to CSV. `DialogType=1` is the only unattended value; parameters and behaviour: [FileIO_Library §fnCSVExport](FileIO_Library.md#fncsvexport). |
| `fnExportListviewCSV` | `(Window, SPEC$; GenFileName, Delim$, Filename$)` | Export an on-screen listview to CSV. |

<a id="audit"></a>
## Audit BR (snapshot / compare)

| Function | Signature | Purpose |
|---|---|---|
| `fnBeginAudit` | `(; BackupFolder$, Path$, Mat SelectedFiles$)` | Snapshot file layouts before a test run. |
| `FnCompare` | `(; BackupFolder$, Logfile$, Printer, DontClose, Path$, Mat SelectedLayouts$)` | Report every change since the snapshot. |
| `fnCopyDataFiles` | `(BackupFolder$; Path$, Mat SelectedLayouts$, SkipKeys)` | Copy data files into a backup folder. |

<a id="logging"></a>
## Change & error logging

| Function | Signature | Purpose |
|---|---|---|
| `Fnlog` | `(String$; CallingProgram$, ForceTextfile)` | Append a line to the FileIO log. |
| `Fnerrlog` | `(String$; CallingProgram$)` | Append to the error log. |
| `fnSetLogChanges` | `(Mat f$, Mat F)` | Capture a record's "before" image for change logging. |
| `fnLogChanges` | `(Mat f$, Mat F; String$, CallingProgram$, Layout$)` | Log the field-level diff vs the captured before-image. |
| `fnLogArray` | `(Mat F$, Mat F; String$, CallingProgram$)` | Log a whole record array. |
| `fnViewLogFile` | `(; ShowQuit, ShowColumns, ShowExport)` | Browse the log file. |
| `fnReadLockedUsers` | `(Mat Users$)` | List users currently holding locks. |

<a id="procfiles"></a>
## Procedure files

| Function | Signature | Purpose |
|---|---|---|
| `fnBuildProcFile` | `(String$)` | Build a `proc` file from a string (alias `fnBuildProc`). |
| `fnRunProcFile` | `(; NoWait)` | Run the built proc file (alias `fnRunProc`). |

<a id="utilities"></a>
## Array, value & screen utilities

| Function | Signature | Purpose |
|---|---|---|
| `fnEmpty` | `(Mat A)` | 1 if a numeric array is all-empty (alias `fnIsEmpty`). |
| `fnEmptyS` | `(Mat A$)` | 1 if a string array is all-empty (alias `fnIsEmptyS`). |
| `fnAskCombo$` | `(Mat Description$; Caption$, Default$)` → `$*255` | Modal combo-box prompt; returns the choice. |
| `fnShowMessage` | `(Message$)` | Pop a short message window; returns its window number. |
| `fnProgressBar` | `(Percent; Color$, ProgressAfter, ProgressThreshhold, UpdateThreshhold, Caption$, MessageRow$)` | Draw/update a progress bar (alias `fnUpdateProgressBar`). |
| `fnCloseBar` | *(no args)* | Close the progress bar (alias `fnCloseProgressBar`). |
| `fnReadScreenSize` | `(&Rows, &Cols; ParentWindow)` | Current screen rows/cols (alias `fnReadScreenS`). |

<a id="env"></a>
## Client / server & environment

| Function | Signature | Purpose |
|---|---|---|
| `Fnclientserver` | `(; )` *(returns server/client folders by ref)* | Detect/return client-server folder configuration. |
| `fnClientEnv$` | `(EnvKey$)` → `$*255` | Read a client-side environment value. |

<a id="files"></a>
## File / directory utilities

| Function | Signature | Purpose |
|---|---|---|
| `fnCopyFile` | `(FromFile$, ToFile$; NoProgressBar)` | Copy a file (with optional progress bar). |
| `fnGetFileDateTime$` | `(FileName$)` | A file's date/time stamp (alias `fnGetFileDT$`). |

<a id="strings-time"></a>
## String & time utilities

| Function | Signature | Purpose |
|---|---|---|
| `fnSubstituteString` | `(&String$, FileLayout$, Mat f$, Mat f; SubstituteChar$)` | Merge record fields into a template string (by subscript name). |
| `fnSubstituteStringCode` | `(&String$, Code$; SubstituteChar$)` | Merge with an explicit code/value map. |
| `fnStandardTime$` | `(MT$; Seconds)` | Military → standard (AM/PM) time. |
| `fnMilitaryTime$` | `(ST$; Seconds)` | Standard → military time. |
| `fnBuildTime$` | `(H, M, S, P; Military, Seconds)` | Build a time string from parts. |
| `fnParseTime` | `(T$, &H, &M, &S, &P)` | Parse a time string into parts. |
| `fnCalculateHours` | `(timein$, tout$, daysin, daysout)` | Hours between two day/time points. |

<a id="email"></a>
## Email

| Function | Signature | Purpose |
|---|---|---|
| `FnSendEmail` | `(Emailaddress$, EmailMessage$; Subject$, Invoicefile$, noprompt, BCCEmail$, Mat CCEmails$, CCAsTo)` | Send an email (optionally with an attachment / CC / BCC). |

<a id="coverage"></a>
## Coverage & drift vs FileIO_Library.md

This page documents **all 80** `DEF LIBRARY` exports of this `fileio.brs` build. Reconciling against the
online-doc capture [FileIO_Library.md](FileIO_Library.md): **79 are referenced there; one is present in source but absent from that doc** (documented here from source):

`FnReadLayoutExtension$`

## See also

- [FileIO_Library.md](FileIO_Library.md) — the online-doc manual (Method of Operation, fnOpen, File
  Layouts format, DataCrawler, CSV, fnSettings, examples)
- [AuditBR.md](AuditBR.md) — the Audit BR add-on (`fnBeginAudit` / `FnCompare`)
- [spec.md](spec.md) — the FileIO leaf overview (concepts, layout files, the fnOpen pattern)
- [../library-facility/spec.md](../library-facility/spec.md) — the BR `LIBRARY` statement that links FileIO
- [../screenio/spec.md](../screenio/spec.md) — ScreenIO, which builds on FileIO
