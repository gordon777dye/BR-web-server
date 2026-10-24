# Standard library function catalog

Signatures for the **standard, shipped BR libraries** documented in the `br_tree/` reference —
**FileIO**, **ScreenIO**, and the **JSON / data-store** functions. These are reusable
libraries any BR app links via the `LIBRARY` statement; their signatures are authoritative from
`br_tree/` (source-derived where noted), **not** from the corpus. Application-specific `DEF LIBRARY`
functions are *not* here — index those from the target app's own source.

Companion to [`system-functions-catalog.md`](system-functions-catalog.md) (the intrinsic
`table6k`/`table7k` built-ins). Same notation, with two library-specific additions (`;` and `&`).

## Notation

```
NAME(req1, req2; opt1, opt2) → ret
```

- **`;` separates required from optional** parameters — the BR `DEF` convention, verbatim from the
  library source. Everything before `;` is required; everything after is optional. (The
  system-function catalog uses `[x]` instead, because intrinsics have no `DEF` declaration.)
- **`&name`** = passed **by reference** — the function reads and/or **writes** it; outputs come back
  through these.
- **`MAT name`** = an array argument.
- **Type by the `$` rule:** a `$` suffix = string, no suffix = numeric. A trailing **`$*n`** is the
  string length (on a parameter) or the function's **string-return length** (on the name).
- **Return type** is the Returns column (`str$` / `num`, with the documented return length where the
  source gives one). Names preserve the source's documented casing (BR is case-insensitive).
- These are **functions** → full spelling, never abbreviated; call them only after a matching
  `LIBRARY "<file>": <fn>, …` declaration.

---

## 1. FileIO  — `LIBRARY "fileio.br": …`

The standard file-access abstraction: describe each data file once in an ASCII **layout** file and
FileIO opens it, builds the `FORM`, sizes the record arrays (`MAT F$`/`MAT F`), caches the per-channel
`FORM` (`MAT Form$`), and defines `FILE_FIELD` subscript constants so programs reference fields **by
name**. Source-verified against `fileio.brs` (80 `DEF LIBRARY` exports). Full prose:
[`../br_tree/50-libraries/fileio/`](../br_tree/50-libraries/fileio/spec.md).

### Opening, closing & file numbers
| Function | Returns | Purpose |
|---|---|---|
| `Fnopenfile(&Filename$, MAT F$, MAT F, MAT Form$; Inputonly, Keynum, Dont_Sort_Subs, &Path$, MAT Description$, MAT Fieldwidths, MAT FileIOSubs$, SupressPrompt, IgnoreErrors, CallingProgram$, SuppressLog, MAT FileIODateFmt$)` | num | **Core open** — open by layout name; sizes `F$`/`F`, loads `Form$(chan)`, returns the file number; subscript-constant EXECUTE strings come back in `FileIOSubs$`. `Inputonly=1` read-only; `Keynum` picks the index. |
| `Fnclosefile(Filenumber, Filelay$; Path$, Out)` | num | Close a FileIO-opened file (and its bookkeeping). |
| `Fngetfilenumber(; Start, Count)` | num | Find a free BR file-channel number in a range. |
| `fnUpdateFile(FileLayout$)` | num | Rewrite a data file to match its **current** layout. |
| `Fnkey$(Filenumber, Key$)` | str | Full stored key for a record on an open channel. |

### Layout interrogation & FORM building
| Function | Returns | Purpose |
|---|---|---|
| `fnReadEntireLayout(Layoutname$; &Filename$, &Prefix$, MAT Keys$, MAT KeyDescription$, MAT Ssubs$, MAT Nsubs$, MAT Sspec$, MAT Nspec$, MAT Sdescription$, MAT Ndescription$, MAT Spos, MAT Npos, MAT sdatefmt$, MAT ndatefmt$)` | num | Read **everything** about a layout. |
| `FnReadLayoutHeader(Layoutname$; &Filename$, MAT Keys$, MAT KeyDescription$, LeaveOpen, &Prefix$)` | num | Header only (filename, keys, prefix). |
| `Fnreadsubs(Filename$, MAT Ssubs$, MAT Nsubs$, &Prefix$)` | num | String/numeric subscript-name arrays + prefix. |
| `Fnreadlayoutarrays(Layoutname$, &Prefix$; MAT Ssubs$, MAT Nsubs$, MAT Sspec$, MAT Nspec$, MAT Sdescription$, MAT Ndescription$, MAT Spos, MAT Npos, AlreadyOpenFileNumber, MAT sdateformat$, MAT ndateformat$)` | num | Parallel subscript/spec/description/position arrays. |
| `fnReadKeyFiles(layout$, MAT keys$)` | num | The key-file names for a layout. |
| `fnReadForm$(Filename$)` | str*10000 | The `FORM` string for a layout/file. |
| `fnReadFormAndSubs(filename$, MAT subs$, &readform$, &stringsize, &numbersize)` | num | FORM plus subscript names and string/numeric counts. |
| `Fnreadlayouts(MAT Dirlist$; OverrideExtension$)` | num | List all layout names in the layout folder. |
| `fnDirVersionHistoryFiles(Layout$, MAT DirList$; BypassExtension$)` | num | List a layout's version-history files. |
| `Fndoeslayoutexist(Layout$)` | num | 1 if the named layout exists. |
| `FnReadLayoutPath$` | str*255 | The configured layout path (no args). |
| `FnReadLayoutExtension$` | str | The configured layout-file extension (no args). |
| `fnClearLayoutCache` | num | Clear the in-memory layout cache (no args). |
| `fnWriteLayout(Name$, filename$, Ver, Pre$, MAT kfname$, MAT kdescription$, MAT subs$, MAT descr$, MAT Form$; Recl, MAT Extra$, DisplayFile)` | num | Write/create a layout definition. |
| `fnLength(Spec$)` | num | **Internal** (stored) byte length of a FORM spec. |
| `FnDisplayLength(Spec$)` | num | **Display** width of a FORM spec. |
| `Fnmakesubproc(Filename$; MAT Subs$, MAT f$, MAT f)` | num | Build the subscript-constant proc for a layout. |

### Keys & key lists
| Function | Returns | Purpose |
|---|---|---|
| `fnBuildKey$(layout$, MAT f$, MAT f; keynum)` | str*255 | Build the key string for a record per the layout's key definition. |
| `Fnuniquekey(Fl, Key$)` | num | 1 if `Key$` is not already present on channel `Fl`. |
| `Fnmakeuniquekey$(Fl; Random, Prepend$)` | str*255 | Generate a key not already in the file. |
| `fnSortKeys(MAT Keys$, Layout$, DataFile, MAT F$, MAT F, MAT Form$; KeyNum)` | num | Sort a key array by a layout index. |
| `Fnreadallkeys(Fl, MAT F$, MAT F, MAT Fm$, Sub1, MAT Out1$; Sub2, MAT Out2$)` | num | All values of field(s) `Sub1[,Sub2]` across the file. |
| `Fnreadmatchingkeys(Fl, MAT F$, MAT F, MAT Fm$, Key$, Keyfld, Sub1, MAT Out1$; Sub2, MAT Out2$)` | num | Field values for records whose `Keyfld = Key$`. |
| `Fnreadallnewkeys(Fl, MAT F$, MAT F, MAT Fm$, Sub1, MAT Out1$; Dont_Reset, Sub2, MAT Out2$)` | num | Incremental "new since last call" variant. |
| `Fnreadfilterkeys(Fl, MAT F$, MAT F, MAT Fm$, Key$, Keyfld, Sub1, MAT Out1$; Filter$, Filter_Sub, Readlarger, Sub2, MAT Out2$)` | num | Matching keys with an extra field filter; up to four output columns. |

### Single-field readers (lookup a field by key or record #)
| Function | Returns | Purpose |
|---|---|---|
| `Fnreaddescription$(Fl, Subscript, Key$, MAT F$, MAT F, MAT Fm$; DontChangeKey)` | str*255 | String field `Subscript` of the record keyed `Key$` (file already open). |
| `fnReadUnopenedDescription$(layoutname$, key$; Field, DontChangeKey)` | str*255 | Same, but opens the layout for you. |
| `Fnreadnumber(Fl, Subscript, Key$, MAT F$, MAT F, MAT Fm$; DontChangeKey)` | num | Numeric field by key (open file). |
| `fnReadUnopenedNumber(layoutname$, key$; Field, DontChangeKey)` | num | Numeric field by key (self-opening). |
| `Fnreadrelativedescription$(Fl, Subscript, RecordNumber, MAT F$, MAT F, MAT Fm$)` | str*255 | String field by **record number**. |
| `fnReadRelUnopenedDescription$(layoutname$, RecordNumber; Field)` | str*255 | …self-opening. |
| `Fnreadrelativenumber(Fl, Subscript, RecordNumber, MAT F$, MAT F, MAT Fm$)` | num | Numeric field by record number. |
| `fnReadRelUnopenedNumber(layoutname$, RecordNumber; Field)` | num | …self-opening. |
| `fnReadRecordWhere$(layoutName$, SearchSub, SearchKey$, ReturnSub)` | str*255 | Scan for `SearchSub = SearchKey$`; return `ReturnSub`. |
| `Fnnotinfile(String$, Filename$, Sub; Path$)` | num | 1 if `String$` is **not** a value of field `Sub` in the file. |

### Reindex & maintenance · DataCrawler · CSV
| Function | Returns | Purpose |
|---|---|---|
| `fnReIndex(DataFile$; CallingProgram$, IndexNum, Path$)` | num | Rebuild a data file's index(es). |
| `fnReIndexAllFiles` | num | Reindex every layout (no args). |
| `fnRemoveDeletes(LayoutName$; Path$, CallingProgram$, DontError)` | num | Compact a file, dropping deleted records. |
| `Fndatacrawler(Filelay$; srow$, scol$, rows$, cols$)` | num | Interactive data browser/editor for any layout-described file. |
| `Fndataedit(…)` | num | Editable DataCrawler entry point. |
| `fnShowData(FileLay$; Edit, sRow, sCol, Rows, Cols, KeyNumber, Caption$, Path$, KeyMatch$, SearchMatch$, CallingProgram$, MAT Records, MAT IncludeCols$, MAT IncludeUI$, MAT ColumnDescription$, MAT ColumnWidths, MAT ColumnForms$, DisplayField$, MAT FilterFields$, MAT FilterForm$, MAT FilterCompare$, MAT FilterCaption$, MAT FilterDefaults$, MAT FilterKey, IncludeRecordNumbers, BypassDateProcessing)` | num | Show (optionally edit) a file in a grid with column/filter control. |
| `fnCsvImport(Layout$; SupressDialog, FileName$, ImportModeKey)` | num | Import a CSV into a layout's file. |
| `fnCsvExport(Layout$; DialogType, Filename$, IncludeRecNums, KeyNumber, StartKey$, KeyMatch$, Startrec, MAT Records, SearchMatch$, Launch)` | num | Export a file to CSV. Headless: pass `DialogType=1` only — see [APP-DEV-GUIDE §4](APP-DEV-GUIDE.md#inspecting-actual-data-values). |
| `fnExportListviewCSV(Window, SPEC$; GenFileName, Delim$, Filename$)` | num | Export an on-screen listview to CSV. |

### Audit BR · logging · proc files
| Function | Returns | Purpose |
|---|---|---|
| `fnBeginAudit(; BackupFolder$, Path$, MAT SelectedFiles$)` | num | Snapshot file layouts before a test run. |
| `FnCompare(; BackupFolder$, Logfile$, Printer, DontClose, Path$, MAT SelectedLayouts$)` | num | Report every change since the snapshot. |
| `fnCopyDataFiles(BackupFolder$; Path$, MAT SelectedLayouts$, SkipKeys)` | num | Copy data files into a backup folder. |
| `Fnlog(String$; CallingProgram$, ForceTextfile)` | num | Append a line to the FileIO log. |
| `Fnerrlog(String$; CallingProgram$)` | num | Append to the error log. |
| `fnSetLogChanges(MAT f$, MAT F)` | num | Capture a record's "before" image for change logging. |
| `fnLogChanges(MAT f$, MAT F; String$, CallingProgram$, Layout$)` | num | Log the field-level diff vs the captured before-image. |
| `fnLogArray(MAT F$, MAT F; String$, CallingProgram$)` | num | Log a whole record array. |
| `fnViewLogFile(; ShowQuit, ShowColumns, ShowExport)` | num | Browse the log file. |
| `fnReadLockedUsers(MAT Users$)` | num | List users currently holding locks. |
| `fnBuildProcFile(String$)` | num | Build a `proc` file from a string. |
| `fnRunProcFile(; NoWait)` | num | Run the built proc file. |

### Utilities · client/server · files · strings/time · email
| Function | Returns | Purpose |
|---|---|---|
| `fnEmpty(MAT A)` | num | 1 if a numeric array is all-empty. |
| `fnEmptyS(MAT A$)` | num | 1 if a string array is all-empty. |
| `fnAskCombo$(MAT Description$; Caption$, Default$)` | str*255 | Modal combo-box prompt; returns the choice. |
| `fnShowMessage(Message$)` | num | Pop a short message window; returns its window number. |
| `fnProgressBar(Percent; Color$, ProgressAfter, ProgressThreshhold, UpdateThreshhold, Caption$, MessageRow$)` | num | Draw/update a progress bar. |
| `fnCloseBar` | num | Close the progress bar (no args). |
| `fnReadScreenSize(&Rows, &Cols; ParentWindow)` | num | Current screen rows/cols. |
| `Fnclientserver(;)` | num | Detect/return client-server folder configuration (by ref). |
| `fnClientEnv$(EnvKey$)` | str*255 | Read a client-side environment value. |
| `fnCopyFile(FromFile$, ToFile$; NoProgressBar)` | num | Copy a file (optional progress bar). |
| `fnGetFileDateTime$(FileName$)` | str | A file's date/time stamp. |
| `fnSubstituteString(&String$, FileLayout$, MAT f$, MAT f; SubstituteChar$)` | num | Merge record fields into a template string (by subscript name). |
| `fnSubstituteStringCode(&String$, Code$; SubstituteChar$)` | num | Merge with an explicit code/value map. |
| `fnStandardTime$(MT$; Seconds)` | str | Military → standard (AM/PM) time. |
| `fnMilitaryTime$(ST$; Seconds)` | str | Standard → military time. |
| `fnBuildTime$(H, M, S, P; Military, Seconds)` | str | Build a time string from parts. |
| `fnParseTime(T$, &H, &M, &S, &P)` | num | Parse a time string into parts. |
| `fnCalculateHours(timein$, tout$, daysin, daysout)` | num | Hours between two day/time points. |
| `FnSendEmail(Emailaddress$, EmailMessage$; Subject$, Invoicefile$, noprompt, BCCEmail$, MAT CCEmails$, CCAsTo)` | num | Send an email (optional attachment / CC / BCC). |

---

## 2. ScreenIO  — `LIBRARY "screenio.br": …`

RAD screen engine built on FileIO. Its public surface is **21 `DEF LIBRARY` exports** as of
ScreenIO v2.95 (the 2020 build had 16; the ~425 internal engine/designer functions are private).
Source-verified against the shipping source. The
event/context model and `ExitMode` constants are in
[`../br_tree/50-libraries/screenio/`](../br_tree/50-libraries/screenio/ScreenIO_Function_Reference.md).
How the engine works *underneath* these exports — the Helper Library compile pipeline, the runtime
screen stack and event dispatch, the Filter return contract, and authoring/compiling a screen from
code with no Designer UI — is in [`screenio-guide.md`](screenio-guide.md#contents).

### Screen invocation
| Function | Returns | Purpose |
|---|---|---|
| `Fnfm$(Screenname$; Keyval$, Srow, Scol, Parent_Key$, Parent_Window, Display_Only, Dontredolistview, Recordval, MAT Passeddata$, Usemyf, MAT Myf$, MAT Myf, Path$, Selecting, SaveDontAsk)` | str | **Workhorse** — run/edit a screen; returns the chosen/edited record key (`""` if cancelled). Blank `Keyval$` = add a new record. |
| `Fnfm(Screenname$; …same params…)` | num | Same, returning `1` ok / `0` cancelled (or the screen's numeric return). |
| `Fndisplayscreen(Screenname$; Keyval$, Srow, Scol, Parent_Key$, Parent_Window, Recordval, Path$, Selecting)` | num | Read-only display of a screen (forces `Display_Only`). |
| `Fncallscreen$(Screen$; Keyval$, Parent_Key$, Display_Only, Parent_Window, Dontredolistview, Recordval, MAT Passeddata$, Usemyf, MAT Myf$, MAT Myf, Path$, Selecting)` | str | Programmatic form of the in-screen `[SCRNNAME]` call (wraps the name in `[ ]` if absent). |

### Designer support · helpers · wait animation
| Function | Returns | Purpose |
|---|---|---|
| `Fnselectevent$(&Current$; &Returnfkey)` | str | Open the designer's "select event function" dialog; updates `Current$`/`Returnfkey` by ref. |
| `Fnfindsubscript(MAT Subscripts$, Prefix$, String$*40)` | num | Index of a field subscript by `Prefix$`+`String$` (resolves `FILE_FIELD` constants at run time). |
| `fnGetUniqueName$(MAT ControlName$, Control)` | str | A control name guaranteed not to collide with existing names. |
| `fnIsInputSpec(type$)` | num | 1 if a control type code is an **input** control (`c`, `search`, `check`, `combo`, `filter`). |
| `fnIsOutputSpec(type$)` | num | 1 if a code is **output/static** (`caption`, `button`, `p`, `frame`, `screen`). |
| `fnDays(String$*255; DateSpec$*255)` | num | The numeric `DAYS` value of a date string; supports **relative** offsets (`-3w` = three weeks ago). |
| `fnFunctionBase` | num | Base FKEY number for the current screen nesting level (`1500 + 200×loaded-screens`) — no args. |
| `fnBR42` / `fnBR43` | num | 1 if running BR ≥ 4.2 / ≥ 4.3 (no args). |
| `fnPrepareAnimation` | num | Initialise the "please wait" animation (no args). |
| `fnAnimate(; Text$*60)` | num | Render one animation frame, optional caption — call repeatedly during a long task. |
| `fnCloseAnimation` | num | Tear down the animation window (no args). |
| `fnListSpec$(SpecIn$*255)` | str | *(v2.95)* `SpecIn$` cut before its third comma: the `row,col,LIST rows/cols` head of a listview spec. Linked into every generated helper library. |

### Designing, generating and compiling screens *(exports in v2.95)*
| Function | Returns | Purpose |
|---|---|---|
| `fnDesignScreen(; ScreenName$)` | — | Open the Designer (GUI mode required), loading `ScreenName$` if given. |
| `fnMakeScreen(; Layout$, LaunchScreen)` | — | **Interactive** Screen Generator wizard for a FileIO layout; writes `<layout>LIST` / `EDIT` / `COMBO` screens. `LaunchScreen` opens each in the Designer. |
| `fnCompileScreen(ScreenCode$*18; WaitForComplete)` | num | Headless: rebuild one screen's helper library. `1` = found and compile **launched** (it runs in a separate BR process); pass `WaitForComplete=1` to wait for it. `0` = no such screen. |
| `fnCheckScreenErrors(ScreenCode$*18, MAT ErrObject, MAT ErrField, MAT ErrMessage$, MAT ErrType)` | num | Headless: the Designer's "To Do" validation. Arrays are resized to one row per finding; `ErrType` `1` warning / `2` error. `1` = screen found (check `UDIM` for findings), `0` = not found. |

> **Event model:** ScreenIO is event-driven, but events are **not** fixed-signature callbacks — the
> designer stores a BR statement string per screen/control that the engine `EXECUTE`s. Handlers receive
> a large fixed by-reference context (`MAT F$`/`MAT F`, `Key$`, `ExitMode`, `Window`, …). See the
> reference page for the event table, the handler context, and `ExitMode` constants (0 run · 1 QuitOnly
> · 2 SaveAndQuit · 3 SelectAndQuit · …). For how the engine actually dispatches into those handlers
> at run time, see [`screenio-guide.md` §3–§6](screenio-guide.md#runtime-stack). `Fnfm$`'s
> `SaveDontAsk` (v2.95) turns a non-listview screen's "save changes?" exit prompt into a silent save,
> for callers such as `run.brs` that ask once for several screens.

---

## 3. JSON & data store  — web-service data layer (WEB_SERVER program)

In-memory named-object storage plus JSON build/parse/serve. Values are addressed by fully-qualified
path (`object.member.submember`, `object[n].member`). From
[`../br_tree/60-integration/json-datastore/`](../br_tree/60-integration/json-datastore/spec.md); object
names and `fqname` paths are strings (the spec writes them without `$`). Return codes: `1` success ·
`-10` object not found · `-21..-29` member not found · `-500` keys/values mismatch · `-520` invalid JSON.

### Object store
| Function | Returns | Purpose |
|---|---|---|
| `FNPut_Object(name$, s$)` | num | Create/replace a named object. |
| `FNInsert_Object(name$, s$)` | num | Insert ahead of an existing same-named object. |
| `FNGet_Object(name$, &s$)` | num | Retrieve an object's value (`-10` = not found). |
| `FNSend_Object(name$; suppress_header, suppress_length)` | num | Send the object to the HTTP client. |
| `FNDelete_Object(name$)` | num | Delete the named object. |

### JSON values (by path)
| Function | Returns | Purpose |
|---|---|---|
| `FNPut_Json(fqname$, v$; must_exist, as_is)` | num | Create/replace a value at a path. |
| `FNInsert_Json(fqname$, v$; as_is)` | num | Insert (turns duplicate members into an array). |
| `FNAppend_Json(fqname$, v$; as_is)` | num | Append after a location. |
| `FNDelete_Json(fqname$; null_flag)` | num | Remove (or blank) a value. |
| `FNGet_Json(fqname$, &container$; as_is)` | num | Read a value into a variable. |
| `FNCompile_Json(type$, member$, MAT keys$, MAT values$, &out$)` | num | Build JSON from arrays (`type$` = `"{"` object or `"["` array). |
| `FNParse_Json(s$, &type$, &name$, MAT keys$, MAT values$)` | num | Parse JSON into arrays; returns the element count. |
| `FNCompile_Object(…)` / `FNParse_Object(…)` | num | Same, operating directly on stored objects. |

### HTML output helpers
| Function | Returns | Purpose |
|---|---|---|
| `FNSend_string(s$; …)` | num | Send a string (≤30 KB). |
| `FNSend_Page(file; MAT args$, MAT repl$, …)` | num | Send a page file with `{{arg}}`→value substitutions. |

> Non-numeric JSON values are auto-quoted unless the `as_is` flag is set. BR sets the HTTP content type
> from the first character of the output (`<`→`text/html`; `{`/`[`/`"`→`application/json`).

---

**Scope note:** FileIO, ScreenIO, and the JSON datastore are complete (full signatures, source-verified
where the library ships consolidated source). **FnSnap is excluded for now** — when it is added, its
signatures live across eight per-area pages under
[`../br_tree/50-libraries/fnsnap/`](../br_tree/50-libraries/fnsnap/spec.md).
