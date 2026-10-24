---
title: PCL / Native Windows Printing escape codes
file: spec.md
source: §Printing Operations → Native Windows Printing, PCL; br_tree PDF/PCL/barcode pages folded in & pruned (2b) — PCL/PDF retained
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: spec
status: 2b           # reference base + br_tree enrichment
recovered-fold: Native_Windows_Printing + NWP.DOC retained (deep NWP reference); PDFLib2.dll folded+pruned. Folded OPTION 31, DIRECT:/, justification/CHR$(6), \Estop_cursor, duplex, \Epage_number, paper tray/media, pdflib2.dll@4.20H. 3 redirect-collision pages re-fetched; verbatim retained on the BR wiki
related: [statements]
keywords: [PCL, PDF, NWP, barcode, FONT, SETFONT]
---

# PCL / Native Windows Printing escape codes

Rich printer formatting beyond plain `PRINT USING`: fonts, color, positioning, images, and
boxes/shading — emitted as escape sequences (`\E…`) or PRINTER.SYS substitution tags (`[NAME]`)
inside `PRINT #255:` output. The plain print statements are in
[statements](../statements/spec.md); the tag *definitions* live in PRINTER.SYS under
[00-configuration](../../00-configuration/config-directives/spec.md).

<a id="semantics"></a>
## Semantics

- **Native Windows Printing (NWP)** is enabled by opening `WIN:/<printer>` (BR 4.0+; most features
  4.16+, centering 4.18+). `CONFIG OPTION 31` **suppresses NWP** (`OPTION 31 OFF` resumes it); an
  invalid escape raises **error 6245** — processed at *end of line*, so a trailing `;` usually avoids
  it — suppressible with `OPTION 32`. `SUBSTITUTE WIN:/ PREVIEW:/` routes NWP to preview, and
  **`DIRECT:/<printer>`** sends straight to a printer bypassing *both* NWP and `SPOOLCMD`. PCL escapes
  are **case-sensitive** (the sequence's final letter must be capital); non-PCL keywords like `font=`
  must be lower case.
- Formatting is sent as text: a raw escape `\E…`, or a PRINTER.SYS **substitution tag** `[NAME]`
  (and parameterized `[NAME]'value'`).

<a id="fonts"></a>
### Fonts & attributes
```business-rules
00100 PRINT #255: "\Efont='Arial'"     ! or [FONT_ARIAL] / [FONT]'Tahoma'
00220 PRINT #255: "[MEDIUM]"            ! sizes: [TINY]6 [SMALL]8 [LITTLE]10 [MEDIUM]12 [ESSAY]14 [LARGE]18
00300 PRINT #255: "[BOLD]Text[/BOLD]"  ! [ITALICS] [UNDERLINE]
```

<a id="color"></a>
### Color & shading
```business-rules
00100 PRINT #255: "[RED]Red text"            ! named
00200 PRINT #255: "\Ecolor=#FF0000"          ! HTML hex  (or [COLOR]'#0000FF')
00300 PRINT #255: "\Eshade_color='#FFCCCC'"  ! shade (4.2+)
```

<a id="positioning"></a>
### Positioning (inches / decipoints)
```business-rules
00100 PRINT #255: "\Eposition='3,2'"   ! 3" from left, 2" from top  (or [POSITION]'6,0')
00200 PRINT #255: "\Eposition='+1,0'"  ! relative move
00400 PRINT #255: "\E&a720h1440V"      ! decipoints (1/720"): 1" left, 2" top
00500 PRINT #255: "[PUSH]" : … : PRINT #255: "[POP]"   ! save/restore position stack
```

<a id="pictures"></a>
### Pictures
```business-rules
00100 PRINT #255: "\Epicture='2,2,logo.jpg'"               ! 2×2 inch image
00200 PRINT #255: "\Epicture='3,3,photo.jpg:ISOTROPIC'"    ! keep aspect ratio (:TILE also)
```

<a id="boxes"></a>
### Boxes & shading
```business-rules
00100 PRINT #255: "\Ebegin_box"            ! full box; '|' becomes vertical rules
00110 PRINT #255: "Col 1|Col 2|Col 3"
00120 PRINT #255: "\Eend_box"
! partial: \Ebegin_boxtop  \Ebegin_verticals  \Ebegin_boxbottom
00300 PRINT #255: "\E*c20G\Ebegin_shade" : PRINT #255: "Shaded" : PRINT #255: "\Eend_shade"
00400 PRINT #255: "Extended field" & CHR$(5)   ! fill to column width
```

<a id="pcl"></a>
### Raw PCL
For non-NWP printers, raw PCL/Epson escape sequences are emitted the same way (HP PCL and
Epson-compatible code sets). The `PRINTER_LIST` function returns available printers. Page setup uses
substitution tags — `[PORTRAIT]`/`[LANDSCAPE]` and logical page sizes (`[LETTER]` 8.5×11, `[LEGAL]`
8.5×14, `[LEDGER]` 11×17, `[EXECUTIVE]`, `[A4PAPER]`) — set before printing. Full PCL substitution-tag
table (those marked `*` are PCL-only): [PCL](PCL.md).

<a id="pdf"></a>
### PDF output (4.2+, 32-bit)
A separate facility from NWP (requires `PDFLIB.DLL` — and **`pdflib2.dll` as of 4.20H** —
[installation-tooling](../../00-configuration/installation-tooling/spec.md#pdf)). Open the print
file as:
```business-rules
00100 OPEN #255: "NAME=PDF:/,PrintFile=invoice.pdf", DISPLAY, OUTPUT   ! else goes to spool dir
00110 OPEN #255: "NAME=PDF:/READER", DISPLAY, OUTPUT                   ! create + open in PDF viewer
00120 OPEN #255: "NAME=PDF:/myprog", DISPLAY, OUTPUT                   ! create + hand to a program
```
PDF accepts all NWP syntax **except**: no tiling/cross-hatching (colour & shading do work),
`NORESIZE` ignored, TrueType fonts only. Overprint an existing form with
`\Epdf='<page>,<pdf-file>'` (escape is case-sensitive, filename is not). The `PDF_READER <prog>`
CONFIG statement overrides the default viewer for `PDF:/READER`. Fixed-width font stretching (for
PCL/NWP legibility) is toggled by `OPTION 68`; Courier New is the 4.3 default. Deep detail (height
ratios, MAC support): [PDF](PDF.md).

<a id="barcodes"></a>
### Barcodes
With NWP the simplest route is a **barcode font**: set it, print the value framed by the font's
start/stop char, then restore.
```business-rules
00100 PRINT #PRN, USING "FORM C,SKIP 0": "[SETFONT(Free 3 of 9 Extended)][SETSIZE(38)]"
00110 PRINT #PRN, USING "FORM POS 30,C 1,Cc 6,C 1": "*", INVNR$, "*"   ! * = start/stop
00120 PRINT #PRN: "[SETFONT(Calibri)][SETSIZE(12)]"                     ! restore
```
(Install the font via the install utility or once-only `EXECUTE "system start …\font.ttf"`.) Without
NWP, send the receipt printer's own barcode escape, e.g. `HEX$("1B6204040280") & INVNR$ & HEX$("1E")`.

<a id="more-nwp"></a>
### More NWP escapes
```business-rules
00100 PRINT #255: "\Eleft_justify" / "\Eright_justify" / "\Ecenter"   ! justification (right uses fixed-width boundary)
00110 PRINT #255: FIELD$ & CHR$(6)        ! right-justify the PRECEDING field (4.2); CHR$(5) = box fill
00200 PRINT #255: "\Estop_cursor" : … : PRINT #255: "\Emove_cursor"   ! proportional alignment: set a boundary, hold the cursor
00300 PRINT #255: "[ROTATE90]"            ! page direction 0/90/180/270 (CCW)
00400 PRINT #255: "\Epage_number"         ! replaced with the current page number
00500 PRINT #255: "\E&l1S"                ! duplex: 0 simplex / 1 long-edge / 2 short-edge
```
- **Justification** `\Eleft_justify` (default), `\Eright_justify` (boundary computed in fixed-width
  cells even for proportional fonts), `\Ecenter`. `CHR$(6)` right-justifies the *preceding* field;
  `\E…_justify` applies to the *following* text. **`\Estop_cursor`** freezes horizontal cursor motion at
  a set boundary (CRLF moves to the next line at that boundary; CR-only is ignored; tabs honored) for
  proportional alignment — `\Emove_cursor` resumes normal motion.
- **Paper source**: print to `WIN:/SELECT` (or `PREVIEW:/SELECT`), read `ENV$("LAST_TRAY_SELECTED")` /
  `ENV$("LAST_MEDIA_SELECTED")`, then apply `\Etray='<v>'` / `\Emedia='<v>'` (set **before** any
  printable data; on some printers media overrides tray). HP `\E&l<n>H` codes (2 manual … 5 tray 3) also
  select source.

<a id="pjl"></a>
### PJL
Printer Job Language (HP) switches printer languages at job level and reads back status; emit PJL
the same way as PCL for printers that support it.

<a id="see-also"></a>
## See also

- [statements](../statements/spec.md) — opening `WIN:`/`PREVIEW:` printer files; plain PRINT/USING
- PRINTER.SYS tag definitions & spooling → [00-configuration/config-directives](../../00-configuration/config-directives/spec.md)
- [50-libraries/fnsnap](../../50-libraries/fnsnap/spec.md) — FnSnap printing/PCL helper functions
- [20-io-screen/fields-attributes](../../20-io-screen/fields-attributes/spec.md) — the `PIC()` format spec; [controls](../../20-io-screen/controls/spec.md) — on-screen `P`/`PICTURE` image fields
- Backing keyword pages (deep detail retained): [PCL](PCL.md), [PDF](PDF.md),
  [Native_Windows_Printing](Native_Windows_Printing.md) and [NWP.DOC](NWP.DOC.md) (full NWP escape
  reference — re-fetched and retained in 2b). The `PDFLib2.dll` page was folded into this spec and
  pruned; verbatim wikitext remains on the BR wiki.
