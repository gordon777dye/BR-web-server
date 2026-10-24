---
title: NWP.DOC
file: NWP.DOC.md
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: concept
related: [June 5, 2007, 4.0, 4.16, 4.17, 6245, OPTION, PCL]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
This text is origionally from NWP.DOC from ftp.brulescorp.com and was dated `June 5`, `2007`.

==Requirements==
*Must be BR `4.0` or later. Most Features are only available in `4.16`+.
Some are available in `4.17`+ only.
*Must specify WIN:/.... as the device type.  This can be done with SUBSTITUTE statements and it overrides SPOOLCMD.
::Specify CONFIG OPTION 31 to suppress NWP.
::Specify CONFIG OPTION 31 OFF to resume NWP.

Note- By specifying DIRECT:/printer-name SPOOLCMD may be overridden without having to specify WIN:/ with OPTION 31 ON. This sends reports directly to a printer without NWP or SPOOLCMD processing.

Error `6245` indicates an invalid or unsupported (by BR) escape sequence has been printed under Native Windows Printing.  Note that such escape sequences are not processed until the end of each print line.  So lines that end with a semicolon typically will not generate this error.  This error can be suppressed with `OPTION` 32.

`PCL` is case sensitive. The last control character of an escape sequence must be a capital letter, which signifies the end of the sequence.

Non-PCL keywords such as font= must be lower case.

;EPSON COMPATIBLE CODES

Notation:
2 means CHR$(2) or HEX$("02")
'2' means CHR$(50) or HEX$("32")

Codes that trigger print property changes
Code	Print property change
'\r'	Go to col 0   chr$(13) -> hex$("0D")
'\n'	Line feed      chr$(10) -> hex$("0A")
12	New page
27	Escape
15	Begin compressed print
18	End compressed print


Escape followed by code

Code	Print property change
'0'	8 lines per inch
'2'	6 lines per inch
'4'	Begin italics
'5'	End italics
'@'	Epson - reset
'&'	HP PCL code  - see below
'('	HP PCL code  - see below
'-'	Underline - 1 (on) or 0 (off) e.g. "\E-1"
'_'	Overscore - 1 (on) or 0 (off)  [BR now accepts 1 or '1' here.]
'g'	15 cpi


'k'	Select typeface family:
0 – default			4 – script
1 – roman			5 – decorative
2 – swiss			6 – default
3 – modern (fixed)
Also see the list of specific face names available below.
'x'	Letter quality (1) or utility mode (draft - 0)
'E'	Begin emphasized printing
'F'	End emphasized printing
'G'	Begin enhanced printing (letter quality)
'H'	End enhanced printing – begin draft mode
'M'	12 cpi – Elite
'P'	10 cpi – pica
'W'	Double width printing - 1 (on) or 0 (off)

;FONT SIZING AND POSITIONING

Non-Proportional (fixed width) fonts vary in height based on characters per inch (CPI). Proportional fonts ignore CPI specifications.

HP equipment chooses font sizes from among those available based on several characteristics that may be specified (mainly font height). This is true for both proportional and fixed fonts.  HP equipment does no stretching of font height or width.

Windows allows for independent specification of true type font height versus width. Under NWP the font height, width of a space character, and the vertical movement to go to the next line are all specified independently. The affect of this is dependent on whether the selected font is proportional or fixed width.

Windows stretches fixed width fonts as needed to meet specifications. Proportional fonts are not stretched, but they are scaled based on height.

NWP considers CPI and LPI when positioning and boxing with both fixed and proportional fonts.

Positioning can be done in terms of rows and columns, 720ths of an inch (decipoints), PCL units (pixels), or simply inches (with decimal fractions).  Font pitch (width) is given in CPI. Font height is given in points (72nd of an inch).  Picture sizes are given in inches.

;HP HARDWARE FONT SELECTION METHODOLOGY

HP printers select font based the following criteria in order of importance.

Symbol Set  -  the characters this font contains
Spacing     -  proportional or non-proportional (fixed width)
font width  -  if spacing is fixed, the width of the font is very important
height      -  point size (this is regarded as less important then width)
style       -  italics, outline, ...
boldness    -  how dark and bold is it
typeface    -  the specific font that is specified
resolution, location, orientation

On an HP printer the typeface is given the lowest priority.  In NWP typeface
is given the highest priority.

Symbol set and Spacing are ignored.  On an HP printer, font can be set as
condensed or expanded.  In NWP, this is reflected by changing the font width.
On an HP printer, fonts are always scaled the same in both axis.  In NWP,
we scale the fonts in a manner that allows both CPI and font height to be set.

HMI and VMI

An HP printer has a separate concept for HMI and VMI - the horizontal and vertical motion indexes.  This is how far the cursor moves down for a newline, or horizontally when printing a character (fixed fonts only).

In an HP printer, setting the font PITCH sets the HMI, but setting HMI does not set pitch.  The pitch is the standard character width, whereas HMI is the distance between the leftmost portion of each character. In hardware PCL, the HMI can be set independently of the pitch after the pitch has been set.

For both HP printers and NWP 1) HMI is honored in proportional fonts only for the tab and space characters and in row-col positioning, and 2) VMI and font height are completely independent of each other.

In NWP, when HMI is specified after setting the pitch, BR ignores the HMI until the last character of each 'field' has been printed, and then positions the cursor as if HMI had been honored all along.


NWP ONLY CODES

You can specify any FONT NAME that Windows supports by specifying:
	\Efont='fontname'
For example:
  BRCONFIG.SYS PRINTER HP [Tahoma], "\Efont='Tahoma'"
  00020 PRINT #255: [Tahoma];

Note: All such keywords such as "font=" must be lower case, but the font name (such as Tahoma) is case insensitive in both the configuration file and the PRINT statement..

You can specify POSITION on the page as:
	\Eposition='horizontal,vertical'

Where 'horizontal' and 'vertical' are given as inches from the edge of the page, or may be signed to denote inches from the current position.

Current font COLOR may be specified as:
	\Ecolor=#rrggbb

A PICTURE may be specified as:
	\Epicture='width,height,imagefile.jpg [: TILE|NORESIZE|ISOTROPIC ]'

Where 'width' and 'height' are given in inches, and the remainder of the image specification matches that of New GUI Console pictures.


PARAMETERIZED SUBSTITUTION VALUES

BRCONFIG.SYS PRINTER statements have traditionally supported:

PRINTER identifier [mode-setting], escape-sequence
  PRINTER Laserjet [8-LPI], "\E&l8D"

Then in the program you can activate the setting with:
  02000 Print #255: "[8-LPI]";

The above method requires a separate configuration statement for each possible LPI setting. We have added the capability of specifying in the print process values to be substituted into the actual escape sequences as in:

   02000 Print #255: "[LPI(8)]";

Then the configuration statement would read:

   PRINTER Laserjet [LPI(XXX)], "\E&lXXXD"

Where XXX is any unique case sensitive identifier.

ADDITIONAL NWP CAPABILITIES

AUTOMATIC BOXING may be specified in the form of:
	\Ebegin_box

This will commence enclosing in a box any text subsequently printed. The sides of the box are printed by the program as pipe (|) characters. These are changed to lines drawn by BR. Positioning of box sides is in accordance with CPI specifications irrespective of actual font width, except that proportional text can push the closing sidebar to the right.

Occasionally it is necessary to extend a field to the length it would be if it
contained verical box lines. e.g.

This is some sample text.	Also here.	And here
Now printing proportional text!!	This is a long text field that spans two boxes.

This can be done by appending a CHR$(5) character to the field contents. That will cause a fill character to be added to the printed field length which correlates to the vertical line above or below the boxed field. CHR$(5) is recognized only in one of the BOXING modes (described next).


Additional variations may also be specified:

	\Ebegin_boxtop	enclose sides and above
	\Ebegin_boxbottom	enclose sides and below
	\Ebegin_verticals	enclose only sides
	\Eend_box		end box mode

Possible configuration statements:

   PRINTER NWP [BOX], "\Ebegin_box"
   PRINTER NWP [BOXTOP], "\Ebegin_boxtop"
   PRINTER NWP [BOXOVER], "\Ebegin_boxtop"

   PRINTER NWP [BOXVERTICALS], "\Ebegin_verticals"
   PRINTER NWP [SIDES], "\Ebegin_verticals"

   PRINTER NWP [BOXBOTTOM], "\Ebegin_boxbottom"
   PRINTER NWP [BOXUNDER], "\Ebegin_boxbottom"

   PRINTER NWP [NOBOX], "\Eend_box"

AUTOMATIC SHADING can be specified in a similar manner:
	\E*c20G\Ebegin_shade	set shading density to 20 percent and begin
	\Eend_shade

   PRINTER NWP [SHADE], "\E*c20G\Ebegin_shade"
   PRINTER NWP [NOSHADE], "\Eend_shade"


;Paper Source

WIN:/SELECT or PREVIEW:/SELECT provides the opportunity to select a paper source tray. ENV$ keywords can be used to obtain a number associated with the paper source...
MEDIA$ = ENV$("LAST_MEDIA_SELECTED")
TRAY$ = ENV$("LAST_TRAY_SELECTED")
The value associated with the selection can then be applied as [\Emedia='value'] and [\Etray='value' ] to specify that the paper should be taken from that source. On some printers media type overrides and nullifies tray selection.

Note that paper tray selection and page orientation must be specified before printing any displayable data. These are not supported mid-report.

Sample Test Program For Selecting Media or Tray
00010    dim PTRAY$*20,PNAME$*100
00020    open #10: "NAME=WIN:/select",display,output
00030    print #10: "xxxxx"
00040    print fields "10,10,C 50": PTRAY$:=ENV$("LAST_TRAY_SELECTED")
00050    print fields "11,10,C 50": PMEDIA$:=ENV$("LAST_media_SELECTED")
00060    print fields "12,10,C 100": PNAME$:=FILE$(10)
00070    input fields "23,64,C 1": PAUSE$
00080    close #10:
00090    open #10: "NAME="&PNAME$,display,output
00100    print #10: CHR$(27)&"tray='"&PTRAY$&"'"
00110    print #10: CHR$(27)&"media='"&PMEDIA$&"'"
00120    print #10: "YYYYYYYYYYY"
00130    close #10:

Also see specification 'H" in the following table. Either of these methods may be used to select the paper source, but not both concurrently.
*HP COMPATIBLE CODES
*ESCAPE '&' FOLLOWED BY


;Page Specifications

Lowercase 'l', then a number followed by 'C', 'D', 'E', 'P', 'F', 'H', 'O', or 'A'.
	'C'	VMI (vertical motion index) number of 48ths of an inch per line.
	'D'	Line spacing - lines per inch 1,2,3,4,6,8,12,16,24,48
This setting also affects (sets) VMI.
NWP supports fractions, etc. HP doesn't.
Example:
"\E&l16D"	Set to 16 lines per inch.
	'E'	Set the top margin in lines (VMI increments) from the top of page.  The default is 1/2 inch from the top of page.
	'P'
'F'	Set page length in lines.
These two values (P and F) are treated synonymously by BR. They both set the bottom margin in relation to the top margin based on the current VMI. The default is 1/2 inch from the bottom.
Example:
"\E&l40P"		Set to 40 lines per page.
	'H'	Set paper source
 2 - Manual Feed
 3 - Manual Envelope Feed
 4 - Paper Tray 2 (lower tray)
 5 - Paper Tray 3 (optional paper source)
	'O'	Page orientation: 0=portrait, 1=landscape.
Example:
"\E&l0O"   	set page orientation
 (must come before other sequences).
	'A'	Designates the size of the paper which in turn defines the size of the logical page:
1     - Executive (7¼ x 10½ in).
2     - Letter (8½ x 11 in).
3     - Legal (8½ x 14 in).
6     - Ledger (11 x 17 in).
26   - A4 (210mm x 297mm).
27   - A3 (297mm x 420mm).
Envelopes:
80   - Monarch (Letter – 3 7/8 x 7½ in).
81   - Com-10 (Business - 4 1/8 x 9½ in).
90   - International DL (110mm x 220mm).
91   - International C5 (162mm x 229mm).
100 - International B5 (176mm x 250mm).


;Position Cursor or margin

Lowercase 'a' followed by a number, then by 'V', 'H', 'C', or 'R'

Specify plus or minus ahead of the number for relative positioning.	'V'	Number of decipoints from top of page.
Example:
"\E&a720h1440V" 	Set position to one inch from the left margin and two inches from the top margin.

	'H'	Number of decipoints from left edge.
	'C'	Number of columns (CPI units) from left edge.
	'R'	Number of rows (VMI units) from top of page.
	'L'	Set the left margin to the left edge of the specified column.
(Right margin defaults to the maximum setting)


;Line Termination

Lowercase 'k', followed by a number, then by 'G', 'H', or 'S'.

	'G'	Line termination:
0:CR=CR,         LF=LF,        FF=FF
1:CR=CR+LF,  LF=LF,        FF=FF
2:CR=CR,         LF=CR+LF, FF=FF
3:CR=CR+LF,  LF=CR+LF, FF=CR+FF

Example:
"\E&k3G" – set CR=CR+LF, LF=CR+LF, FF=CR+FF

	'H'	Set HMI (Horizontal Motion Index – the number of 1/120's of an inch per character).
Fixed fonts use CPI instead, normally the size of one blank character.

	'S'	0 - Uncompressed 10 cpi
2 - Compressed 16.67 cpi
4 - Uncompressed 12 cpi


;SYMBOL SET SELECTION, LANGUAGE, ETC.

Note: Cannot combine commands.

ESCAPE '(' FOLLOWED BY

'H''H'

ESCAPE '*' FOLLOWED BY

See the HP PCL.PDF file for examples of fill chars.
Lowercase 'c'
Fills space.  Follow 'c'
by a number, then by 'H', 'V', 'G', or 'P'.
	'H'	Horizontal fill distance in decipoints
	'V'	Vertical fill distance in decipoints
On HP printers you can specify patterns and corresponding images to be applied to the bitmap workspace.  Many effects are possible.  Text may be grayed or striped like a candy cane.

First the pattern (small bitmap - tiled) is used to fill the image, which may be a graphic image or a font character. Then the result is applied to the bitmap space.

Both applications are performed in accordance with transparency settings (0 = logical OR, 1 = copy).
	G	Set the current shading or cross hatch pattern.
The HP_PCL.PDF file describes the available shading and cross hatch patterns on pages 274-276.
	P	FILL the Horizontal/Vertical area using:

Lowercase 'v',
followed by a number, then by 'T', 'N', or 'O'.
	'T'
	Set the current pattern mode
0 black (default)
1 white
2 shaded (based on *c#G value)
3 cross-hatch (based on *c#G value)

Note:
*v#T is not supported by BR except to support *c5P
	N	Set the 'apply image' transparency mode.
0 is transparent (ORs bits), 1 is opaque (copies bits).

The net result is that white bits are copied in opaque mode, whereas source white bits are ignored in transparent mode. Note:*v1N copies the framing whitespace of an image or font character.
	'O'
	Set the 'apply pattern' mode
0 is transparent (ORs bits), 1 is opaque (copies bits).

Lowercase 'p'
Repositions on page.  Follow 'p' by a number, then by 'X' or Y'.
        X	Number of PCL units(pixels) from the left edge.  Specify plus or minus ahead of number for relative positioning. - Note also see &a#H and &a#V above.
	Y	Number of PCL units from the top edge.
	R	Rotate – Ignored by BR
