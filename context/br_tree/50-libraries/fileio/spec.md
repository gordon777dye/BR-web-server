---
title: FileIO library
file: spec.md
source: fileio.brs (shipping source) + filelay/ layout format + the FileIO_Library manual
category: 50-libraries
subcategory: 50-libraries/fileio
kind: spec
status: 2b           # source-derived reference + online-doc manual captured; ScreenIO/AuditBR build on it; no conflicts
related: [library-facility, screenio]
keywords: [FileIO, fnOpen, fnRead, LIBRARY]
corrections:
  - "2026-09-30: The 4th-column date format listed only DATE(Julian|cymd|ymd|mdy). Added what Julian means (a DAYS() value), that any DAYS() mask is accepted, and a Disk date formats section. The section covers this kit's local change to fileio.brs, which accepts days in place of serial, and ScreenIO recognizing only julian. Source: fileio.brs FNPARSEDETAILLAYOUTLINE and FNFMTSDATE$/FNFMTNDATE$, screenio.br.brs lines 39266/39508, and a CSV export test run before and after the change."
---

# FileIO library

**FileIO** is the standard **file-access abstraction** in this codebase: you describe
each data file once in an ASCII **layout file**, and FileIO OPENs it, builds the `FORM`, sizes your record
arrays, and defines `FILE_FIELD` subscript constants — so programs reference fields **by name** and never
hard-code positions. Change a layout and FileIO **migrates the data file on the fly**; no program needs
editing. [ScreenIO](../screenio/spec.md) builds on it.

<a id="syntax"></a>
## The fnOpen pattern

```business-rules
DIM color$(1)*1000, color(1)        ! string + numeric record arrays (one per file)
DIM form$(1)*255                    ! per-channel FORM cache
LIBRARY "fileio.br": fnopenfile, fnclosefile, fngetfilenumber
LET colorfile = fnOpen("color", MAT color$, MAT color, MAT form$ [, inputonly] [, keynum])
READ #colorfile, USING form$(colorfile): MAT color$, MAT color EOF done
LET name$ = color$(co_Name)         ! field accessed by FILE_FIELD subscript constant
LET fnclosefile(colorfile, "color") : LET colorfile = 0
```

Programs call a thin local `DEF FNOPEN` wrapper around the library's `FNOPENFILE` — it opens the file and
then `EXECUTE`s the subscript-constant strings the library returns. The public surface is **80
`DEF LIBRARY` exports**; the authoritative grouped list is
[FileIO_Function_Reference](FileIO_Function_Reference.md).

<a id="semantics"></a>
## Semantics

- **Layout files** (`filelay\<name>`): a header line `datafile, PREFIX_, version`; one or more key lines
  `keyfile, SUBS[/SUBS][-U]`; a `====` separator; then field lines `SUBSCRIPT[$], description, formspec`
  with an optional 4th-column disk **date format** — `DATE(Julian)` or `DATE(days)` for a stored BR day
  number (a `DAYS()` value), otherwise a `DAYS()`/`DATE$()` mask such as `DATE(cymd)`, `DATE(ymd)` or
  `DATE(mdy)` (see [Disk date formats](#disk-date-formats)). `X` specs reserve space;
  `!` and blank lines are ignored; optional `#eof#` ends it. Full format:
  [FileIO_Library](FileIO_Library.md#file-layouts).
- **Automatic versioning** — bump the layout's version number on **every** change. On open, FileIO
  compares the on-disk version to the layout version and, if higher, backs up and **rebuilds the data file
  record-by-record** (dropped fields lost, rearranged fields repositioned, new fields blank/zero). **Never
  rename an existing subscript** — that reads as drop-old + add-new and loses data.
- **Function families** (see the reference): open/close & file numbers, layout interrogation & FORM
  building, keys & key lists, single-field readers, reindex/maintenance, DataCrawler UI, CSV import/export,
  Audit BR, change/error logging, proc files, array/screen utilities, client-server, file/dir, string/time,
  email.
- **DataCrawler** — a built-in grid/listview browser **and** editor for any data file that a layout file describes.
  (`fnDataCrawler`/`fnDataEdit`/`fnShowData`); not for end-users on production data (no validation).
- **Add-ons that build on FileIO** — [ScreenIO](../screenio/spec.md) (RAD screens) and
  [AuditBR](AuditBR.md) (`fnBeginAudit`/`fnCompare` change auditing).

<a id="disk-date-formats"></a>
## Disk date formats

A layout's 4th column marks a field as a date only when it is `DATE(…)` or `DATE[…]` (case-insensitive);
the text inside becomes the field's disk date format. Anything else in column 4 is a comment.

| Inside `DATE(…)` | Meaning | How FileIO converts it |
|---|---|---|
| contains `julian` or `days` | the field holds a BR day number (a `DAYS()` value) — not an astronomical Julian day, not `YYDDD` | used as is |
| anything else | a `DAYS()`/`DATE$()` mask describing the stored form, e.g. `cymd`, `ymd`, `mdy`, `ccyymmdd` | `DAYS(value, mask)` in, `DATE$(days, mask)` out |

The match is a case-insensitive substring test (`FNFMTSDATE$`/`FNFMTNDATE$`), for string and numeric
fields alike. Dates are shown in the DataCrawler in the `dateformatdisplay` setting and exported to CSV
in `dateformatexport` (both default `m/d/cy`).

- **`days` is a local change.** The FileIO in this kit (`dev/tools/fileio.brs`) accepts `days` where
  the vendor's FileIO accepts `serial`. With this kit's FileIO, `DATE(serial)` is no longer a day
  number: it is used as a mask and the date exports as `00/00/0000`. Confirmed on 2026-09-30 by a
  CSV export before and after the change.
- **ScreenIO recognizes only `julian`.** Its screen generator, not changed, treats `DATE(days)` as a
  mask and would add a `DATE(days)` output conversion to the field. Use `DATE(Julian)` for any field a
  ScreenIO screen displays.

<a id="see-also"></a>
## See also

- [FileIO_Function_Reference](FileIO_Function_Reference.md) — all 80 `DEF LIBRARY` exports, grouped (source-derived)
- [FileIO_Library](FileIO_Library.md) — the full online-doc manual (layout format, `fnSettings`, DataCrawler, CSV, examples)
- [AuditBR](AuditBR.md) — the Audit BR add-on
- [library-facility](../library-facility/spec.md) — the BR `LIBRARY` statement that links FileIO
- [30-io-file/statements](../../30-io-file/statements/spec.md) — the underlying file I/O FileIO performs
- [screenio](../screenio/spec.md) — the ScreenIO RAD library, which builds on FileIO
