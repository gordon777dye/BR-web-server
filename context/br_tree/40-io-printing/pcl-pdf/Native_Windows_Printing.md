---
title: Native_Windows_Printing
file: Native_Windows_Printing.md
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: concept
related: [NWP.DOC, 4.15, SPOOLCMD, OPTIONS, 4.0, 4.16, 4.18, SUBSTITUTE, 6245, PCL]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
**Native Windows Printing** is commonly referred to as **NWP**, is a newer technology which allows BR! to print to any properly installed windows printer driver.

See also `NWP.DOC`.

Note that WIN: has new meaning with release `4.15`+.  It still overrides `SPOOLCMD`, but it also turns on NWP. See `OPTIONS` for instructions on how to suppress NWP.

===Requirements===

* Must be BR! `4.0` or later, several features require `4.16`+.<br>
* Must be BR! `4.18`+  for Centering.
* Must specify WIN:/.... as the device type. ( This can be done with `SUBSTITUTE` statements. )
:Specify  "CONFIG OPTION 31" to suppress NWP.<br>
:Specify  "CONFIG OPTION 31 OFF" to resume NWP.

Error `6245` indicates an invalid or unsupported (by BR) escape sequence has been printed under Native Windows Printing.  Note that such escape sequences are not processed until the end of each print line.  So lines that end with a semicolon typically will not generate this error. This error can be suppressed with OPTION 32.

`PCL` is case sensitive. The last control character of an escape sequence must be a capital letter which signifies the end of the sequence.

Non-PCL keywords such as font= must be lower case.

===Print Preview===

To activate the **Print Preview** feature:

   Substitute WIN:/  PREVIEW:/

This will cause your Native Windows Printers to generate a report preview window before the report is actually printed.

There are two ways to use the print preview feature:

:1.) by specifying the following in the `BRConfig.sys`:

 Substitute WIN:/  PREVIEW:/

:2.) by opening the printer with:

 00100 OPEN #255: "name=preview:/select",display,output

This will cause your Native Windows Printers to generate a report preview window after the print setup window, before the report is actually printed.

As of 4.2, BR saves the PREVIEW window "position" and "maximized" settings across sessions.

During PREVIEW, clicking "Print (all)" produces a standard Windows print dialog box so the user can specify copies, range and other printing options.

The PREVIEW window continues to be non-modal (permitting multiple
concurrent previews), but we suppress the raising of the initiating window in response to waiting for keyboard entry until the PREVIEW window is closed.
This avoids the eclipsing of the preview window by the initiating window.

=== PrintScreen GUI  ===

If the config statement **PrintScreen GUI** is specified in conjunction with a Windows printer (WIN:/printer or PREVIEW:/...) the printscreen will be graphical. Additionally, PrintScreen GUI implies WIN:/SELECT instead of PRN:/SELECT so it is not necessary to specify the PrintScreen device.

Test change 3<br>

===Epson Compatible Codes===

Notation-    2  -> chr$(2)  -> hex$("02")
{|
|-valign="top"
|width="10%"|''' '2' -> chr$(50) -> hex$("32") Codes that trigger print property changes:
|-valign="top"
|}
<br>
\\r go to col 0  chr$(13) -> hex$("0D")<br>
\\n line feed    chr$(10) -> hex$("0A")<br>
12 new page<br>
27 escape<br>
15 begin compressed print<br>
18 end compressed print

;Escape followed by:
'0' 8 lines per inch<br>
'2' 6 lines per inch<br>
'4' begin italics<br>
'5' end italics<br>
'@' Epson - reset<br>
'&' HP PCL code  - see below<br>
'(' HP PCL code  - see below<br>
'-' underline - 1 (on) or 0 (off)   {\b e.g. "\\E-1"}<br>
'_' overscore - 1 (on) or 0 (off)<br>
'g' 15 cpi<br>
'k' select typeface -

 00000 - default    1 - roman    2 - swiss    3 - modern (fixed)
 00004 - script     5 - decorative    6 - default

Also, for version 4.14, see list of specific facenames below.<br>
'x' letter quality (1) or utility mode (draft - 0)<br>
'E' begin emphasized printing<br>
'F' end emphasized printing<br>
'G' begin enhanced printing (letter quality)<br>
'H' end enhanced printing<br>
'M' 12 cpi - Elite<br>
'P' 10 cpi - pica<br>
'W' double width printing - 1 (on) or 0 (off)

===HP Compatible Codes Supported By NWP===

;Escape '&' followed by:
'l' letter L in lowercase and then a number (NWP supports fractions, HP doesn't), followed by:
'C' VMI (vertical motion index) number of 48ths of an inch<br>
'D' Line Spacing - lines per inch 1,2,3,4,6,8,12,16,24,48<br>
Both of the above codes set VMI.

'E' Top margin in lines (VMI increments) from the top of page.  The default is 1/2 inch from the top of page.

'P' Page Length in lines<br>
'F' Page Length in lines<br>
These two values are treated synonymously by BR. They both set the bottom margin in relation to the top margin based on the current VMI. The default is 1/2 inch from the bottom.

'H' set paper source  4.17+ only<br>
: 2 Manual Feed<br>
: 3 Manual Envelope Feed<br>
: 4 Paper Tray 2 (lower tray)<br>
: 5 Paper Tray 3 (optional paper source)

Other paper source codes are available.  However, because these codes are not universal and vary by printer you will need to query the printer driver to determine the proper code.  This can be done by sending a simple print job to an NWP printer as WIN:\\SELECT.  This option will allow you to select a windows printer and set the properties to the correct printer drawer or source.  Once the print job has been processed BR will set an environmental variable named env$("XXXXXXX").  Typing PRINT ENV$("XXXXX)" from a command line will return the value needed to address the selected drawer.

'O' letter O, page orientation<br>
: 0=portrait<br>
: 1=landscape<br>
Note: THIS MODE NEEDS TO BE SELECTED BEFORE ANY OTHER OPTIONS.

'A': designates the size of the paper which in turn defines the size of the logical page

: 1 - Executive (7.25 x 10.5 in.)<br>
: 2 - Letter (8.5 x 11 in.)<br>
: 3 - Legal (8.5 x 14 in.)<br>
: 6 - Ledger (11 x 17 in.)<br>
: 26 - A4 (210mm x 297mm)<br>
: 27 - A3 (297mm x 420mm)<br>

; ENVELOPES:
:80 - Monarch (Letter - 3 7/8 x 7.5 in.)<br>
: 81 - Com-10 (Business - 4 1/8 x 9.5 in.)<br>
: 90 - International DL (110mm x 220mm)<br>
: 91 - International C5 (162mm x 229mm)<br>
: 100 - International B5 (176mm x 250mm)

'a' reposition in 720ths of an inch (decipoints) BR 4.14+ only<br>
'V' number of decipoints from top of page<br>
'H' number of decipoints from left edge<br>
'C' number of columns (CPI units) from left edge<br>
'R' number of rows (VMI units) from top of page<br>

Specify plus or minus ahead of the number for relative positioning.

;Examples- :
{|
|-valign="top"
|width="10%"|**"\\E&l1O"**||Set page orientation.. must come before other sequences.
|-valign="top"
|width="10%"|**"\\E&ll6D"**||Set to 16 lines per inch.
|-valign="top"
|width="10%"|**"\\E&l40P"**||Set to 40 lines per page.
|-valign="top"
|width="10%"|**"\\E&a720h1440V"**||Set position to one inch from the left margin and two inches from the top margin. (BR 4.14+ only)
|-valign="top"
|}

'f' stack (0) or restore (1) current page position<br>
'S' terminate save or restore value
{|
|-valign="top"
|width="10%"|*'*'||The stack depth is 20.
|-valign="top"
|}
<br>
'k' <br>
'G' line termination<br>
: 0:CR=CR,    LF=LF,    FF=FF<br>
: 1:CR=CR+LF, LF=LF,    FF=FF<br>
: 2:CR=CR,    LF=CR+LF, FF=FF<br>
: 3:CR=CR+LF, LF=CR+LF, FF=CR+FF "\\E&k3G"  Set to CR=CR+LF, LF=CR+LF, FF=CR+FF

'H': set horizontal motion index (HMI)<br>
:the number of 1/120's of an inch per character<br>
:fixed fonts use CPI instead<br>
:normally the size of one blank character

'S' 0: uncompressed 10 cpi<br>
:2: compressed 16.67 cpi<br>
:4: uncompressed 12 cpi

Escape '(' followed by Symbol set selection, language, etc.  *cannot combine commands<br>
's': e.g. for Stroke Weight: Ec(s#B<br>
'B' Stroke Weight    -7  --0--  +7

'H' Pitch  in characters per inch,  e.g.  10 = 10 cpi<br>
'S' Style|0: normal<br>
:1: italics<br>
'T' TypeFace Family|0 - default<br>
:1 - roman<br>
:2 - swiss<br>
:3 - modern (fixed)<br>
:4 - script<br>
:5 - decorative<br>
:6 - default

'T' Specific TypeFace (version 4.14 only)

{| border="1" cellpadding="2"
|Value **||Family **||Name
|-
| 00000 **||MODERN**||"Line Printer"
|-
| 04099 **||MODERN**||"Courier New"
|-
| 04101 **||ROMAN**||"CG Times"
|-
| 04102 **||MODERN**||"Letter Gothic"
|-
| 04113 **||SWISS**||"CG Omega"
|-
| 04116 **||SCRIPT**||"Coronet"
|-
| 04140 **||ROMAN**||"Clarendon Condensed"
|-
| 04148 **||SWISS**||"Univers"
|-
| 04168 **||SWISS**||"Antique Olive"
|-
| 04197 **||ROMAN**||"Garamond"
|-
| 04287 **||SCRIPT**||"Marigold"
|-
| 04362 **||SWISS**||"Albertus Medium"
|-
| 16602 **||SWISS**||"Arial"
|-
| 16901 **||ROMAN**||"Times New Roman"
|-
| 16686 **||ROMAN**||"Symbol"
|-
| 31402 **||DECORATIVE**||"Wingdings"
|-
|}
[\RTFBOX]

'V' font height in points ( 72nd of an inch )  *can be fractional<br>
eg. "\\E(s17h4102t2B"  Set to 17cpi, letter gothic, bold weight<br>
Note- only the last terminator character should be capitalized.

;version 4.14+ only:

;Escape '*' followed by:
(see the HP PCL.PDF file for examples of fill chars)

p - reposition on page<br>
'X' number of PCL units(pixels) from the left edge.<br>
Specify plus or minus ahead of the number for relative positioning. *see &a#H and &a#V for decipoint positioning. -

'Y' number of PCL units from the top edge.

c - fill space<br>
:'H' horizontal fill distance in decipoints<br>
:'V' vertical fill distance in decipoints

On an HP printers you can specify patterns and and corresponding images to be applied to the bitmap workspace.  Many effects are possible.  Text may be greyed or striped like a candy cane.

**First the pattern (small bitmap - tiled) is used to fill the image, which may be a graphic image or a font character. Then the result is applied to the bitmap space.**

Both applications are performed in accordance with transparency settings (0 = logical OR, 1 = copy).

'G' set the current shading or cross hatch pattern<br>
The HP_PCL.PDF file describes the available shading and cross hatch patterns on pages 274-276.

'P' FILL the Horizontal/Vertical area using:
 00000 black (default)
 00001 white
 00002 shaded (based on *c#G value)
 00003 cross-hatch  (based on *c#G value)
 00005 use current pattern mode (*v#T value)

;v:

'T' set the current pattern mode
 00000 black (default)
 00001 white
 00002 shaded (based on *c#G value)
 00003 cross-hatch (based on *c#G value)
Note- *v#T is not supported by BR except to support *c5P.

'N' set the 'apply image' transparency mode
 00000 is transparent (ORs bits), 1 is opaque (copies bits).

The net result is that white bits are copied in opaque mode, whereas source white bits are ignored in transparent mode.<br>
Note that *v1N copies the framing whitespace of an image or font character.

'O' (letter oh) set the 'apply pattern' mode
 00000 is transparent (ORs bits), 1 is opaque (copies bits).

'p' pattern rotation

'R' this command is ignored by BR

This will apply the HP init string to the referenced printer:.<br>
printer HP-WIN  INIT "\\E(s3b17H"  ! NWP compressed<br>
printer HP-WIN  INIT "\\E(s2b3t17H"  ! NWP compressed

===HP and NWP Font Sizing and Positioning===

Non-Proportional (fixed width) fonts vary in height based on characters per inch (CPI). Proportional fonts ignore CPI specifications.

HP PCL Compatible equipment chooses font sizes from among those available based on several characteristics that may be specified (mainly font height). This is true for both proportional and fixed fonts.  HP equipment does no stretching of font height or width.

Windows, allows for independent specification of true type font height versus width. Under NWP the font height, width of a space character, and the vertical movement to go to the next line are all specified independently. The affect of this is dependent on whether the selected font is proportional or fixed width.

Fixed width fonts are stretched by Windows as needed to meet specifications. Proportional fonts are not stretched, but they are scaled based on height.

NWP considers CPI and LPI when positioning and boxing with both fixed and proportional fonts.

Positioning can be done in terms of rows and columns, 720ths of an inch (decipoints), PCL units (pixels), or simply inches (with decimal fractions).  Font pitch (width) is given in CPI. Font height is given in points (72/inch).  Picture sizes are given in inches.

The following statements will set the Printer into Proportional Spacing mode.
{|
|-valign="top"
|width="10%"|***[PS]**||Set Proportional Spacing
|-valign="top"
|width="10%"|***[/PS]**||Cancel Proportional Spacing
|-valign="top"
|}
<br>
Proportional Spacing is Character spacing based on the width of each character. The printer must be set into this mode before you may change the font size, or use any proportional fonts.

===HP Hardware Font Selection Methodology===

HP printers select font based the following criteria in order of importance.

:1.) Symbol Set - the characters this font contains
:2.) Spacing - proportional or non-proportional (fixed width)
:3.) Font width - if spacing is fixed, the width of the font is very important
:4.) Height - point size (this is regarded as less important then width)
:5.) Style - italics, outline, boldness (how dark and bold it is)
:6.) Typeface - the specific font that is specified
:7.) Resolution
:8.) Location
:9.) Orientation

On an HP printer the typeface is given the lowest priority.  In NWP typeface is given the highest priority.

Symbol set and Spacing are ignored.  On an HP printer, font can be set as condensed or expanded.  In NWP, this is reflected by changing the font width.  On an HP printer, fonts are always scaled the same in both axis.  In NWP, we scale the fonts in a manner that allows both CPI and font height to be set.

===HMI and VMI (Horizontal and Vertical Motion Indicators)===

An HP printer has a separate concept for HMI and VMI - the horizontal and vertical motion indexes.  This is how far the cursor moves for a newline or when printing a character (fixed spacing only).  In an HP printer, setting the font PITCH sets the HMI, but setting HMI does not set pitch.  VMI and font height are completely separated.

In NWP, this separation between HMI, VMI, font width, and font height is not always made.  In addition, NWP only honors HMI for the tab character.  It does not currently honor HMI for the space character or for fixed pitch fonts.

===NWP Only Codes===

;Font Selection
NWP adds support for a totally new way to implement font changes in your programs. With NWP, we have added a new Escape sequence that allows you to set your font to any of the installed fonts on your computer. The command looks like this:

 \\Efont='fontname'

e.g.
 brconfig.sys  PRINTER HP [Tahoma], "\\Efont='Tahoma'"

 00020 PRINT #255: [Tahoma]

Note- All such keywords such as "font=" must be lower case, but Tahoma is case insensitive in both instances.

Printer.sys includes a few pre-mapped font substitute statements to make this even easier.<br>
[FONT_MICR]|Sets the font to Micr<br>
[FONT_TIMES]|Sets the font to Times New Roman<br>
[FONT_ARIAL]|Sets
 the font to Arial<br>
[FONT_LINEPRINTER]|Sets the font to Line Printer<br>
[George Tisdale]|Sets Font to Blue Regular 12 pt Arial<br>
[FONT]|becomes "\\Efont=". Specify any font such as [FONT]'WingDings'

;Font Sizes
If you want to change the font size, you can even do that!

{|
|-valign="top"
|width="10%"|**[TINY]**||6 pt font
|-valign="top"
|width="10%"|**[SMALL]**||8 pt font
|-valign="top"
|width="10%"|**[LITTLE]**||10 pt font
|-valign="top"
|width="10%"|**[MEDIUM]**||12 pt font
|-valign="top"
|width="10%"|**[ESSAY]**||14 pt font
|-valign="top"
|width="10%"|**[LARGE]**||18 pt font
|-valign="top"
|width="10%"|**[155POINT]**||15.5 pt font
|-valign="top"
|}
<br>
One thing to note, printer.sys is just a brconfig.sys file, and it can easily be customized and modified. If you need a font size that I left out, or if you want easier to remember names, these changes are very easy to implement. And many of these options can be simplified by using "Parameterized Substitution Values", which is discussed later in this chapter.

;Page Position
You can specify POSITION on the page as:

 \\Eposition='horizontal,vertical'

Where 'horizontal' and 'vertical' are given as inches from the edge of the page, or may be signed to denote inches from the current position.

;Bold/Underline/Italics
These next few statements control various common font modifiers.[UNDERLINE] [/UNDERLINE][ITALICS] [/ITALICS][BOLD] [/BOLD]

;Font Color
With NWP, we have implemented an easy way to make Colors work, as well. Its actually remarkably similar to the syntax for FONTS. It looks like:

;Current font COLOR may be specified as:
:\\Ecolor=#rrggbb, eg.

;The following colors are predefined for your printing pleasure (only in NWP):

[RED]<br>
[GREEN]<br>
[BLUE]<br>
[MAGENTA]<br>
[CYAN]<br>
[YELLOW]<br>
[ORANGE]<br>
[PURPLE]<br>
[BLACK]<br>
[WHITE]

The following substitution statement is also available:

[COLOR].....Becomes "\\Ecolor=". Specify any html color such as [COLOR]'#0000FF'

;Underline/Overline
NWP has its own syntax for specifying Underline and Overline.
{|
|-valign="top"
|width="10%"|**[UNDERLINE]**||becomes "\\E-1"     Turn on Underline
|-valign="top"
|width="10%"|**[/UNDERLINE]**||becomes "\\E-0"     Turn off Underline
|-valign="top"
|width="10%"|***[OVERLINE]**||becomes "\\E_1"     Turn on Overline
|-valign="top"
|width="10%"|***[/OVERLINE]**||becomes "\\E_0"     Turn off Overline
|-valign="top"
|}

;Rotation
One of the remaining advantages to using PCL is the ability to print in different directions on the page. This can be done in PCL with the following:
{|
|-valign="top"
|width="10%"|***[ROTATE0]**||Sets the page direction normal
|-valign="top"
|width="10%"|***[ROTATE90]**||Sets the page direction to 90&deg; CC
|-valign="top"
|width="10%"|***[ROTATE180]**||Sets the page direction to 180&deg; CC
|-valign="top"
|width="10%"|***[ROTATE270]**||Sets the page direction to 270&deg; CC
|-valign="top"
|}

;Position
The following commands all set the position. You can reset the position to the top left of the page, or you can modify the commands in the text file to reset the position to any specific location on the page you want. You may also, of course, simply print the PCL codes.

{|
|-valign="top"
|width="10%"|**[TOPLEFT]**||Places the cursor at the top left of the page
|-valign="top"
|}
<br>
The PCL command for positioning allows for three ways to set the current position. You may do it based on Decipoints (1/720h of an inch). You may also set the position based rows and columns, or PCL units (pixels). If you append a +/- to the position numbers, you will set the relative position, relative to the current cursor position.

The following syntaxes work for setting the position. YYY is the vertical coordinate, and XXX is the horizontal coordinate. \\E represents the escape character.
{|
|-valign="top"
|width="10%"|**"\\E&aYYYvXXXh"**||Set Position in Decipoints
|-valign="top"
|width="10%"|**"\\E&aYYYrXXXC"**||Set Position in Rows and Columns
|-valign="top"
|width="10%"|**"\\E*pYYYyXXXx"**||Set Position in PCL units
|-valign="top"
|}
<br>
With NWP, you have one additional option for setting your cursor position. There is a new NWP only escape sequence: "\\Eposition='x,y' ". If you prefix your numbers with a +/- then BR will interpret them as a relative position, and it will simply adjust from the current position. Position must be specified in Inches for this new escape sequence.

A single substitution statement has been added to aid you with this. It is simply:

*[POSITION]|Becomes "\\Eposition=". Set the cursor to any position. An example of its usage would be:

 00200 PRINT #255: "[POSITION]'3,2'The Middle."

Position may else be specified with "Parameterized Substitution Values", discussed in this chapter.

You might make some statements like the following (which are already in printer.sys):

{|
|-valign="top"
|width="10%"|***[TOPLEFT]**||"\\Eposition='0,0'" ! Set cursor to top left
|-valign="top"
|width="10%"|***[SHIFTDOWN]**||"\\Eposition='0,+1'" ! Move cursor right one inch
|-valign="top"
|}
<br>
With NWP, you may, of course, also use the PCL style positioning statements.

;Printing Pictures
It's really nice to be able to print pictures. Hot off the press for the new NWP is the ability to print full color pictures straight from a file, using one simple escape sequence. This escape sequence is:

 \\Epicture='width,height,imagefile.jpg [: TILE|NORESIZE|ISOTROPIC ]'

Where 'width' and 'height' are given in inches, and the remainder of the image specification matches that of New GUI Console pictures.

NWP will print any file that you can display, including jpg, gif, bmp, ico, and many others. If you have a color printer, they will be printed in color.

There is again a simple substitute statement for the use of this new escape function.

{|
|-valign="top"
|width="10%"|**[PICTURE]**|| becomes "\\Epicture=".................Use like [PICTURE]'2,2,logo.jpg'
|-valign="top"
|}
<br>
I would suggest using a picture statement with a position statement. To print a logo in the top right of the page, you would say:

 00300 PRINT #255: "[POSITION]'6,0'[PICTURE]'2,2,logo.jpg'"
....or....
 00300 PRINT #255: "[PUSH][POSITION]'6,0'[PICTURE]'2,2,logo.jpg'[POP]"

....to restore the cursor to its original position. These statements will print the logo.jpg file 2 sq" in the top right corner of the page.

[E]|ESC Key (used for generating your own PCL code)

;Paper Source
A new NWP only syntax is supported for paper tray selection. When you print to WIN:/SELECT or PREVIEW:/SELECT then you are given the opportunity to select a paper source tray. Then a new ENV$ keyword can be used to obtain a number associated with the paper source:

TRAY$ = ENV$("LAST_TRAY_SELECTED")

Finally the value associated with the selection can be applied as [ \\Etray='value' ] to specify that the paper should be taken from that source. Note that paper tray selection and page orientation must be specified before printing any displayable data.

===Page Setup Options===
The following Substitute codes work in NWP. Those with a * will work only in NWP.

;Initial configuration:
The following must be done before anything is printed to the printer.
{|
|-valign="top"
|width="10%"|**[PORTRAIT]**||Sets the printer to print portrait
|-valign="top"
|width="10%"|**[LANDSCAPE]**||Sets the printer to print landscape
|-valign="top"
|}
<br>
;The next six settings change the logical page size for printing on different sized pages:
{|
|-valign="top"
|width="10%"|**[EXECUTIVE]**||Set the logical page for Executive size paper (7.25 x 10.5)
|-valign="top"
|width="10%"|**[LETTER]**||Set the logical page for Letter size paper (8.5 x 11)
|-valign="top"
|width="10%"|**[LEGAL]**||Set the logical page for Legal size paper (8.5 x 14)
|-valign="top"
|width="10%"|**[LEDGER]**||Set the logical page for Ledger size paper (11 x 17)
|-valign="top"
|width="10%"|**[A4PAPER]**||Set the logical page for A4 size paper (210mm x 297mm)
|-valign="top"
|width="10%"|**[A7PAPER]**||Set the logical page for A7 size paper (297mm x 420mm)
|-valign="top"
|}
<br>
;The next five settings change the logical page size for printing on envelopes:
{|
|-valign="top"
|width="10%"|**[MONARCH]**||(3 7/8 x 7.5)
|-valign="top"
|width="10%"|**[COM-10]**||(4 1/8 x 9.5)
|-valign="top"
|width="10%"|**[INTERNATIONAL DL]**||(110mm x 220mm)
|-valign="top"
|width="10%"|**[INTERNATIONAL C5]**||(162mm x 229mm)
|-valign="top"
|width="10%"|**[INTERNATIONAL B5]**||(176mm x 250mm)
|-valign="top"
|}
<br>
;The following six options set the paper source. By default it is set to Auto, and can be changed in printer preferences:
{|
|-valign="top"
|width="10%"|**[PAPERSOURCEAUTO]**||Feed from Printer Default
|-valign="top"
|width="10%"|**[PAPERSOURCEMANUAL]**||Feed from manual feeder
|-valign="top"
|width="10%"|**[PAPERSOURCEMANUALENVELOPE]**||Feed Envelope from manual feeder
|-valign="top"
|width="10%"|**[PAPERSOURCETRAY2]**||Feed from Lower Tray
|-valign="top"
|width="10%"|**[PAPERSOURCEOPTIONAL]**||Feed from Optional Input
|-valign="top"
|width="10%"|**[PAPERSOURCEOPTIONALENVELOPE]**||Feed from Optional Envelope Feeder (Must set to Envelope size first)
|-valign="top"
|}

;Real Time Printing
All of the following PCL commands can be executed in the middle of a printing job.

:The following commands modify the LPI settings for the printer:[4LPI] [6LPI] [8LPI] [10LPI]
:This setting controls the number of lines printed per inch vertically on the page.

:The following commands modify the CPI settings for the printer:[4CPI] [6CPI] [8CPI] [10CPI] [12CPI] [14CPI] [17CPI] (16.7)  [20CPI] This setting controls the number of characters printed per inch horizontally on the page.

===Boxing & Shading===
Perhaps the most exciting new feature of Native Windows Printing is a new NWP-only escape sequence for printing Boxes and Shading. With this command, it has never been easier to generate grids and boxes, columns and tables for all your reporting needs.

The way it works is simple. You simply turn Boxing on, and all the text you print is covered at the top and bottom with a box border. To print the sides of the box, you simply need to print a "" (pipe) character. BR will replace the pipe character with a line drawn at the correct place (according to the current CPI settings) to make a column border, or the edge of the box, except that proportional text can force the closing sidebar to the right.

You may use the escape sequence "\\Ebegin_box" to turn on boxing.

If you wish to print only the sides and the top of the box, you may do so by printing "\\Ebegin_boxtop". This will print the border on the top, and it will print a vertical border anywhere you print a "". This is in case you would like to print a box that spans multiple rows.

When you then want to print the bottom of the box, you may send the escape sequence "\\Ebegin_boxbottom". This will print a line below the text, but not above. The "" symbols will still be interpreted as vertical borders.

For all those rows in the middle of the box, you have the command "\\Ebegin_verticals". This will print nothing on the top or the bottom, but it will still print the vertical bar wherever you print a "".

Finally, to turn off boxing features, simply issue an "\\Eend_box" command.

Occasionally it is necessary to extend a field to the length it would be if it contained vertical box lines. e.g.

 ------------------------------|------------------------|-------------|
   xxxxxxxxxxxxxxxxxxx         |  xxxxxxxxxxxxx         |  xxxxxxxxxx |
 ------------------------------|------------------------|-------------|
   xxxxxxxxxx                  |   an extended field is needed here   |
 ------------------------------|--------------------------------------|

This can be done by appending a CHR$(5) character to the field contents. That will cause a fill character to be added to the printed field length. CHR$(5) is recognized only in one of the BOXING modes.

To make your reports look extra nice, we have included two commands to turn on and off shading. This will shade the background of the text using the current shade density. This is great for lightly shading every second row of a report so that they stand out, and its easy to see what goes with what. To turn shading on, issue a "\\Ebegin_shade". To turn it back off, issue an "\\Eend_shade" command.

To change the current shading density by hand, I am afraid, you will have to resort to good old PCL. The command to do this is ""\\E*c##G" where ## is the shading density, by percent.

{|
|-valign="top"
|width="10%"|**\\E*c20G**||\\Ebegin_shade  set shading density to 20 percent and begin
|-valign="top"
|}
\\Eend_shade

\\Ebegin_boxtop = enclose sides and above<br>
\\Ebegin_boxbottom - enclose sides and below<br>
\\Ebegin_verticals - enclose only sides<br>
\\Eend_box - end box mode<br>

Possible configuration statements in BRConfig.sys might include:

 PRINTER NWP [BOX], "\\Ebegin_box"
 PRINTER NWP [BOXTOP], "\\Ebegin_boxtop"
 PRINTER NWP [BOXOVER], "\\Ebegin_boxtop"
 PRINTER NWP [BOXVERTICALS], "\\Ebegin_verticals"
 PRINTER NWP [SIDES], "\\Ebegin_verticals"
 PRINTER NWP [BOXBOTTOM], "\\Ebegin_boxbottom"
 PRINTER NWP [BOXUNDER], "\\Ebegin_boxbottom"
 PRINTER NWP [NOBOX], "\\Eend_box"
 PRINTER NWP [SHADE], "\\E*c20G\\Ebegin_shade"
 PRINTER NWP [NOSHADE], "\\Eend_shade"

Luckily, {\b printer.sys} has the following shortcuts defined to help you out.

{|
|-valign="top"
|width="10%"|**[BOX]**||Begin Box Mode
|-valign="top"
|width="10%"|**[/BOX]**||End Box Mode
|-valign="top"
|width="10%"|**[BOXTOP]**||Begin Box Top Mode
|-valign="top"
|width="10%"|**[BOXOVER]**||Synonym for BOXTOP
|-valign="top"
|width="10%"|**[BOXVERTICALS]**||Begin Box Verticals
|-valign="top"
|width="10%"|**[BOXSIDES]**||Synonym for BOXVERTICALS
|-valign="top"
|width="10%"|**[BOXBOTTOM]**||Begin Box Bottom
|-valign="top"
|width="10%"|**[BOXUNDER]**||Synonym for BOXBOTTOM
|-valign="top"
|width="10%"|**[SHADE]**||Turn on Shading
|-valign="top"
|width="10%"|**[/SHADE]**||Turn off Shading
|-valign="top"
|width="10%"|**[SET_SHADE0]**||White
|-valign="top"
|width="10%"|**[SET_SHADE20]**||Light
|-valign="top"
|width="10%"|**[SET_SHADE40]**||Kinda Light
|-valign="top"
|width="10%"|**[SET_SHADE60]**||Kinda Dark
|-valign="top"
|width="10%"|**[SET_SHADE80]**||Dark
|-valign="top"
|width="10%"|**[SET_SHADE100]**||Black
|-valign="top"
|}

;Push/Pop
Next we have commands for storing the current position on the Stack. This will save the current position into printer memory and allow you to do anything you want with it. When you are done doing what you wanted to do, you may then pop the value back off the stack, and the cursor goes right back to where it was. The syntax is:

{|
|-valign="top"
|width="10%"|**[PUSH]**||Push!
|-valign="top"
|width="10%"|**[POP]**||*Pop*
|-valign="top"
|}
<br>
HP Printers have a stack in their printer memory which you can use to store the current position. Use the stack to save the current cursor position with a  [PUSH] command. You many move it wherever you like and print whatever you like, and when you are ready to continue from where you left off, you simply [POP] and the cursor goes right back where it was. A stack is like a FOR loop, you can nest your [PUSH] and [POP] statements.

One great use I can see for these commands is functions that you wish to use to place graphics on your printout. It would be a nice idea for a polite function in modern society to push the current cursor position before processing (to draw a box or whatever) and then pop the cursor position back to where it was. This way, if you are in the middle of printing a report, and you want to put lines on the report to underline something while you know where you are, you can call your function. When you are done, the function will place you right back where you were before you called it, and you may just finish printing the line as usual.

===Parameterized Substitution Values===

We have a new format for specifying printer substitute statements.  The format works as follows:

Currently, you may specify the shading density with a substitute statement such as the following:

 PRINTER NWP [SET_SHADE20], "\\E*c20G"

With this new syntax, you will be able to specify a value to pass to the substitution statement which will be placed in the actual replacement text of the statement, as follows:

 PRINTER NWP [SET_SHADE(Percent)], "\\E*cPercentG" ! Set to whatever you want

Now you may use a printing statement such as the following:

 PRINT #255: "[SET_SHADE(57)]"

And the correct codes would be generated to set the shading density to 57 percent.

With this new syntax, the following items are available (Note "*" items work ONLY with NWP:

{|border=1
|-valign="top"
|width="10%"|**[SETDPPOSITION(YYY,XXX)]**||Set Position in Decipoints
|-valign="top"
|width="10%"|**[SETRCPOSITION(YYY,XXX)]**||Set Position in Rows and Columns
|-valign="top"
|width="10%"|**[SETPCLPOSITION(YYY,XXX)]**||Set Position in PCL units
|-valign="top"
|width="10%"|***[SETPOSITION(xx,yy)**||Set Position in inches
|-valign="top"
|width="10%"|**[SET_SHADE(Percent)]**||Sets the Shading percent
|-valign="top"
|width="10%"|**[SETFONT(FontNumber)]**||Set current font by number
|-valign="top"
|width="10%"|**[SETSIZE(PointSize)]**||Set current font size
|-valign="top"
|width="10%"|**[CPI(XXX)]**||Set CPI
|-valign="top"
|width="10%"|**[SETSTYLE(StyleCode)]**||Set current font style
|-valign="top"
|width="10%"|***[SETCOLOR(CLRCODE)]**||Set the Color
|-valign="top"
|width="10%"|**[PAPERSOURCE(PSCode)]**||Set the current paper source
|-valign="top"
|width="10%"|***[SHOWPICTURE(2,2,Logo.jpg)]**||Show a picture called Logo.jpg 2" by 2"
|-valign="top"
|width="10%"|***[SHOWISOPICTURE(YY,XX,IMGNAME)]**||Show a picture Isotropically
|-valign="top"
|width="10%"|***[SHOWTILEPICTURE(YY,XX,IMGNAME)]**||Tile a picture
|-valign="top"
|}

;<br>Old:
BRconfig.sys PRINTER statements have traditionally supported:

PRINTER identifier [mode-setting], escape-sequence, e.g.
 PRINTER Laserjet [8-LPI], "\\E&l8D"

Then in the program you can activate the setting with:
 02000 Print #255: "[8-LPI]";

;<br>New:
The above method requires a separate configuration statement for each possible LPI setting. We have since added the capability of specifying in the print process values to be substituted in the actual escape sequences as in:

 02000 Print #255: "[LPI(8)]";

Then the configuration statement would read:

 PRINTER Laserjet [LPI(XXX)], "\\E&lXXXD"

Where XXX is any unique case sensitive identifier.


<noinclude>
</noinclude>

== NWP Color Shading ==

In versions 4.2 and higher NWP supports color shading via the specification "\Eshade_color='#rrggbb'".
This works in conjunction with the other NWP shade syntax. Note that if no shading is implemented the this specification has no effect.

BR now saves the PREVIEW window "position" and "maximized" settings across sessions.

During PREVIEW-  Print (all) produces a standard Windows print diaglog box so the user can specify copies, range and other printing options.

== Windows Themes Suppression ==
Sometimes themes alter the way Windows displays fields (elements within controls). For example different themes may display buttons and captions differently, including rounding corners and highlighting.  Future versions of windows may do different things when it comes to displaying controls which may affect the colors and shapes of displayed fields.

Microsoft first began using themes with XP. The 'classic look' is the Windows 2000 appearance, which is what is produced when themes are suppressed.
Vista permits users to select from among several themes as a part of the user's desktop settings. Sometimes theme processing can slow down the display of large quantities of data, and sometimes it can create an appearance that is less desirable than the classic look.

In versions 4.2 and higher BR offers three methods for suppressing the use of Windows Themes:

A new field attribute is defined that may be specified in ATTRIBUTE statements and in FIELDS leading attributes:

 ^NOTHEME    indicates prevent use of Windows Themes

OPTION 50	! suppress Windows themes for text boxes only

Config WINDOWS_THEMES OFF | ON
This entirely suppresses the use of Windows themes.


----
==Field Justification==
JUSTIFICATION can be specified as:
*	\Eleft_justify – The default positioning is left to right.
*	\Eright_justify – Printing will be aligned on the right. The right boundary is calculated based on fixed width character positions even when using proportional fonts.
*	\Ecenter -  Printing is centered within the space provided.

(As of 4.2) CHR$(6) implies right justify the previous field for printed output. This works just like \Eright_justify except \Eright_justify applies to the following text whereas CHR$(6) pertains to the preceding text.

==Page Number==
\Epage_number - is replaced with the page number.

==Duplex Printing==
NWP supports DUPLEX printing ( &l#S )where:
0 indicates simplex
1 indicates duplex long edge
2 indicates duplex short edge

==Cursor Positioning Mode==
BR NWP supports *alignment of proportional printing* by specifying a boundary and letting BR do the character positioning.

First set the cursor at the desired boundary (right, left or center) using normal NWP cursor positioning (see above). Then specify **\Estop_cursor**. This will set the mode where the cursor does not move horizontally except when tabbing. Either before or after stopping the cursor you may specify justification ( default is left justify ).

*Center uses the current position as the center
*Right justify uses the current position as the right endpoint
*The cursor does not move when printing text
*Newline positioning is honored, but carriage return positioning is ignored. A normal CRLF moves to the next line at the same boundary.
*Tab positioning is honored

\Emove_cursor - Resumes moving the cursor normally when printing ( default mode ).
