---
title: FnSnap function packs
file: spec.md
source: §Functions → FnSnap; br_tree FnSnap__* per-area pages indexed (2b) — all retained as the API reference
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: spec
status: 2b           # reference catalog + br_tree per-area function index
recovered-fold: FnSnap TOC page folded (dll location/pdf/provenance) + pruned; the 8 FnSnap__* API pages remain retained. Redirect-collision page re-fetched; verbatim retained on the BR wiki
related: [library-facility, screenio]
keywords: [FnSnap, LIBRARY]
---

# FnSnap function packs

FnSnap is a shipped collection of ready-made `FN…` library functions (dialogs, screen helpers,
printing/PCL, bar codes, dates, files, arrays, window maintenance). Link them with the
[library facility](../library-facility/spec.md) like any library function and call `FNINIT` once at
program start. This page is a **navigational index**; each function's full signature, parameters and
notes live in the per-area `FnSnap__*` pages linked below.

<a id="semantics"></a>
## Semantics

- **Initialize** with `LET FNINIT(; SYSDIR$, SYS$)` before using FnSnap functions; `LIBRARY
  "fnsnap": FN…` lists the ones you call.
- Functions are grouped into the areas below; a few appear in more than one pack (e.g. `FNOPEN`,
  `FNPROGRESS`, `FNDIALOG`).
- **Get it**: `fnsnap.dll` ships in `fnsnap.zip` (ftp.brulescorp.com `/Brg_pub/Zip/` — names are
  case-sensitive); the zip includes `fnsnap.pdf` with the same reference. Every entry is a library
  function, linked via `LIBRARY`. (Project lead: George Tisdale.)

<a id="screen"></a>
## Screen processing — [FnSnap__Screen_Processing](FnSnap__Screen_Processing.md)
| Function(s) | Purpose |
|---|---|
| `FNBUTTON` `FNCLRBUTTON` `FNWINBUTTONS` `FNPICBUTTONS` | button-bar / window / picture buttons |
| `FNCHECK` `FNRADIOCHK` `FNRADNUM` | read radio-dot / check-box state |
| `FNDIALOG` `FNDLG` `FNTEXTBOX` `FNOPTIONS` | dialog / input / option boxes |
| `FNWAITWIN` `FNWAITMSG` `FNWAITBAR` `FNPROGRESS` `FNTIMEOUT` | wait / progress indicators |
| `FNHELP` `FNHELPTIP` | help windows & tooltips |
| `FNSCREEN` `FNWINSCRN` `FNWINSIZE` `FNWINROWCOL` | screen / window geometry info |
| `FNFKEY` `FNPFKEY` `FNPFKEYLINE` | function-key handling |
| `FNPROPER` `FNNUM` `FNZERO` `FNPHONE` `FNMOD` | value formatting helpers |
| `FNENCRYPT` `FNDECRYPT` `FNERRTRAP` `FNPRINTSCREEN` `FNEMAILFILE` | misc screen-side helpers |

<a id="printing"></a>
## Printing & PCL — [FnSnap__Printing_and_PCL](FnSnap__Printing_and_PCL.md)
(see also [40-io-printing/pcl-pdf](../../40-io-printing/pcl-pdf/spec.md))
| Function(s) | Purpose |
|---|---|
| `FNOPEN` `FNPRINT` `FNPRINT_FILE` `FNPRINTERS` `FNTYPE` | open / drive / list printers |
| `FNFONT` `FNLOADFONT` `FNMAKEPCL` | fonts & PCL generation |
| `FNBARCODEM` `FNCODE3OF9` `FNCODEUPC` `FNPOSTNET` | bar codes (3-of-9 / UPC / PostNet) |
| `FNDRAWBOX` `FNPRINTBOX` `FNSIGNBOX` `FNGREYBAR` | boxes, signature lines, grey-bar shading |
| `FNENVELOPE` `FNLABEL` `FNGETZIP` `FNPRINTFORM` | envelopes, labels, forms |
| `FNRTF` `FNRTFSTART` `FNRTFEND` `FNREPRINT` `FNCLEANLOG` | RTF output, reprint, log cleanup |

<a id="file"></a>
## FILE — [FnSnap__FILE](FnSnap__FILE.md)
| Function(s) | Purpose |
|---|---|
| `FNGETFILE` `FNGETFILENAME` `FNPUTFILE` `FNFILENAME` `FNNEXTFIL` | file pick / name helpers |
| `FNFILEOK` `FNFILESIZE` `FNSIZE` | existence / size checks |
| `FNINDEX` `FNSEQ` `FNBLDSORT` | index / sequence / sort builders |
| `FNCFORM` `FNCF` `FNUPDATE_VERSION` | compiled FORM, version update |

<a id="datetime"></a>
## Date & time — [FnSnap__Date_and_Time](FnSnap__Date_and_Time.md)
| Function(s) | Purpose |
|---|---|
| `FNDATE` `FNDATEFWD` `FNDATEREV` `FNPRIOR` `FNNEXTMONTH` | format / advance / reverse dates |
| `FNCCYYMMDD_TO_DAYS` `FNMMDDYY_TO_DAYS` `FNYYMMDD_TO_DAYS` `FNDAYS_TO_MMDDCCYY` `FNDAYS_TO_MMDDYY` | ↔ DAYS conversions |
| `FNMDY2YMD` `FNYMD2MDY` | reorder date components |
| `FNWEEKDAY` `FNDAYOFYEAR` `FNWEEKOFMONTH` `FNWEEKOFYEAR` | calendar parts |
| `FNBUSINESSDAY` `FNPRIOBUSINESSDAY` `FNTIMMILREG` | business-day / time helpers |

<a id="array"></a>
## Array functions — [FnSnap__Array_Functions](FnSnap__Array_Functions.md)
| Function(s) | Purpose |
|---|---|
| `FNSORTARRAY` `FNSRTARY` `FNSRTNARY` `FNBLDSORT` | sort arrays (string / numeric) |
| `FNLISTSPEC` `FNLISTSRCH` `FNLISTSRCHN` `FNSELECTION` `FNSRCHCRIT` | list build / search / selection |
| `FNROWSUM` `FNCOLSUM` `FNDELROW` `FNCHRMAT` `FNPARMAT` | row/col sums, delete row, parse to MAT |

<a id="window"></a>
## Window maintenance — [FnSnap__Window_Maintenance](FnSnap__Window_Maintenance.md)
`FNWIN` `FNWINDEV` `FNWINHEAD` `FNSAP` `FNLISTSPEC` — open/develop/head standard windows.

<a id="misc"></a>
## Miscellaneous — [FnSnap__Miscellaneous_Functions](FnSnap__Miscellaneous_Functions.md)
`FNCHECKAMOUNT` `FNLEADZERO` (number formatting) · `FNEMAIL` `FNEMAILFILE` (email) ·
`FNCURDRV` (current drive) · `FNMSEXE` `FNPROG` (run programs) · `FNCLKBUF` (clipboard) · `FNX`.

<a id="obsolete"></a>
## Obsolete
Deprecated FnSnap functions kept for legacy programs are catalogued in
[FnSnap__FNSNAP_Obsolete_functions](FnSnap__FNSNAP_Obsolete_functions.md) — avoid in new code.

<a id="examples"></a>
## Examples

```business-rules
00100 LIBRARY "fnsnap": FNINIT, FNDIALOG, FNCODE3OF9
00110 LET FNINIT
00120 LET RC = FNDIALOG("Save changes?")          ! dialog box
00130 PRINT #255: FNCODE3OF9(INVNR$)              ! 3-of-9 bar code
```

<a id="see-also"></a>
## See also

- [library-facility](../library-facility/spec.md) — how to `LIBRARY`-link and load these functions
- [40-io-printing/pcl-pdf](../../40-io-printing/pcl-pdf/spec.md) — the printing/PCL FnSnap functions
- [20-io-screen/controls](../../20-io-screen/controls/spec.md) — native controls the screen helpers wrap
- Backing keyword pages (the per-function API reference): [FnSnap__Screen_Processing](FnSnap__Screen_Processing.md),
  [FnSnap__Printing_and_PCL](FnSnap__Printing_and_PCL.md), [FnSnap__FILE](FnSnap__FILE.md),
  [FnSnap__Date_and_Time](FnSnap__Date_and_Time.md), [FnSnap__Array_Functions](FnSnap__Array_Functions.md),
  [FnSnap__Window_Maintenance](FnSnap__Window_Maintenance.md),
  [FnSnap__Miscellaneous_Functions](FnSnap__Miscellaneous_Functions.md),
  [FnSnap__FNSNAP_Obsolete_functions](FnSnap__FNSNAP_Obsolete_functions.md)
