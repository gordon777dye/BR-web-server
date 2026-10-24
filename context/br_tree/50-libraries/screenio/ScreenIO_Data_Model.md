---
title: ScreenIO Data Model (screen & control definitions)
file: ScreenIO_Data_Model.md
source: filelay/screenio (SI_ header) + filelay/screenfld (SF_ controls) — the shipping screen-definition schema
category: 50-libraries
subcategory: 50-libraries/screenio
kind: reference
status: deep-reference
related: [screenio, library-facility]
---

# ScreenIO Data Model

A ScreenIO "Screen Function" is **data, not code**: the designer stores each screen as one record in
`screen/screenio.dat` plus one record per control in `screen/screenfld.dat`. The engine
(`screenio.brs`) reads these at run time and drives the [screen FIELDS](../../20-io-screen/input-output/spec.md)
and [file I/O](../../30-io-file/statements/spec.md) for you. Knowing this schema is what makes the
[event-callback contract](ScreenIO_Function_Reference.md#events) legible — events and validations are just
string fields here that the engine `EXECUTE`s.

Because these are ordinary **keyed BR data files** (schema below), a BR program can read or rewrite them
directly using the documented layout, and BR's own ScreenIO designer maintains them interactively — so
screens can be inspected and edited without leaving BR. Do not hand-edit the binaries outside BR.

<a id="screen"></a>
## Screen header — `screenio.dat` (prefix `SI_`, key `SCREENCODE`)

Addressed in event code as `Screenio$(SI_…)` / `Screenio(SI_…)`.

### Identity & appearance
| Field | Type | Meaning |
|---|---|---|
| `SCREENCODE$` | V 18 | Screen code (primary key). |
| `CAPTION$` | V 60 | Screen caption. |
| `VSIZE` / `HSIZE` | B 1 / BH 2 | Window size (rows / cols). |
| `ATTRIBUTES$` | V 255 | Screen-level display attributes. |
| `PICTURE$` | V 60 | Background picture file. |
| `FGCOLOR$` / `BGCOLOR$` | C 6 | Foreground / background colour. |
| `BORDER` | B 1 | Window border style. |
| `WINDCAP$` | V 80 | Window caption (title bar). |
| `FILELAY$` | V 18 | File layout the screen binds to. |

### Event functions (each holds a BR call string the engine `EXECUTE`s)
| Field | Event | Field | Event |
|---|---|---|---|
| `ENTERFN$` | Enter | `LOOPFN$` | Main Loop |
| `INITFN$` | Initialize | `NOKEYFN$` | Nokey |
| `READFN$` | Read | `PRELISTVIEWFN$` | Listview Prepopulate |
| `LOADFN$` | Load | `POSTLISTVIEWFN$` | Listview Postpopulate |
| `WRITEFN$` | Write | `MERGEFN$` | Merge |
| `WAITFN$` | Wait | `EXITFN$` | Exit |
| `LOCKEDFN$` | Record Locked | | |

### Behaviour, locking & merge
| Field | Type | Meaning |
|---|---|---|
| `WAITTIME` | BH 2 | Input wait time; `-1` disables. |
| `INPUTATTR$` | V 255 | Default input-field attributes. |
| `READINDEX` / `RETURNINDEX` | B 1 | Key index used when reading / when returning a selection. |
| `SCREENIOLOCKING` | B 1 | Use ScreenIO record locking. |
| `SCREENIOMERGE` | B 1 | Use ScreenIO AutoMerge (multi-user concurrent-edit reconcile). |
| `PROTECTEDTEXT$` / `PROTECTEDCHECK$` / `PROTECTEDBUTTON$` | V 255 | Attributes for protected text / checkboxes / buttons. |
| `OTHERCHANGES$` / `MYCHANGES$` | V 255 | Attributes highlighting others' vs my changes (merge). |
| `LOCKWINDOW$` / `ACTIVECOLOR$` | V 255 | Lock-window colour / active-window colour. |
| `USERDATA$` | V 255 | Free user-data array available to the screen's functions. |

### Audit, test harness & versioning
| Field | Type | Meaning |
|---|---|---|
| `CREATEDATE` / `MODIFYDATE` | BH 3 | Created / last-modified dates. |
| `CREATEUSER$` / `MODIFYUSER$` | V 30 | Created-by / last-modified-by user. |
| `PROJECT$`, `NOTES$` | V 255 | Designer project grouping & notes. |
| `DEBUGSCREEN$`, `DEBUGKEY$`, `DEBUGPARENTKEY$`, `DEBUGRECORD`, `DEBUGPATH$`, `DEBUGPASSED$` | V/BH | "Test call your screen" harness inputs (key, parent key, record #, path, passed data). |
| `VERSION` | BH 4 | Screen definition version. |

<a id="control"></a>
## Controls — `screenfld.dat` (prefix `SF_`, keys `SCREENCODE`, `SCREENCODE/CONTROLNAME`, recl 2500)

One record per control on a screen.

| Field | Type | Meaning |
|---|---|---|
| `SCREENCODE$` | V 18 | Owning screen. |
| `CONTROLNAME$` | V 50 | Control name (unique within the screen). |
| `FIELDNAME$` | V 50 | Bound field from the file layout. |
| `DESCRIPTION$` | V 255 | Caption text, or caption field. |
| `VPOSITION` / `HPOSITION` | B 1 / BH 2 | Row / column. |
| `FIELDTYPE$` | V 8 | Control type code — input: `c`, `search`, `check`, `combo`, `filter`; output/static: `caption`, `button`, `p` (picture), `frame`, `screen` (see [`fnIsInputSpec`/`fnIsOutputSpec`](ScreenIO_Function_Reference.md#helpers)); also listviews & list-children. |
| `SPECWIDTH` / `WIDTH` / `HEIGHT` | BH 2 / BH 2 / B 1 | Format-spec width, display width, height. |
| `TRUEVALUE$` / `FALSEVALUE$` | V 60 | Stored values for a checkbox's checked / unchecked states. |
| `FUNCTION$` | V 255 | **Control event** — Validation (input controls) or Click/action (buttons, captions, pictures); a BR call string the engine `EXECUTE`s. |
| `PICTURE$` | V 255 | Picture file for picture controls. |
| `PARENT$` | V 20 | Parent control (for a list child — `listchld`). |
| `FGCOLOR$` / `BGCOLOR$` | C 6 | Colours. |
| `JUSTIFY$` | C 1 | `L` / `R` / `C` / `U` or blank. |
| `ATTR$` | V 128 | Field attributes. |
| `PROTECTED` / `INVISIBLE` | B 1 | Protected (read-only) / hidden flags. |
| `TOOLTIP$` | V 255 | Tooltip text. |
| `CNVRTIN$` / `CNVRTOUT$` | V 255 | Incoming / outgoing value conversion (a BR expression). |
| `MULTISELECT` | B 1 | Listview allows multiple selection. |
| `GRIDLINES` | B 1 | Show gridlines (listviews). |
| `USERDATA$` | V 255 | Free custom data. |

## See also

- [ScreenIO_Function_Reference.md](ScreenIO_Function_Reference.md) — the 21 exports (v2.95) and the event contract these fields feed
- [spec.md](spec.md) — concepts and screen-function types
- [ScreenIO internals guide](../../../dev/screenio-guide.md#authoring) — *(dev kit)* writing these two files directly to author a screen without the Designer, then compiling it
- [20-io-screen/controls](../../20-io-screen/controls/spec.md) — the underlying BR controls ScreenIO renders (grid/list, picture, combo…)
