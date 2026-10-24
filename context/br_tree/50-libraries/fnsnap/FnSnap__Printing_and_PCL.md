---
title: FnSnap__Printing_and_PCL
file: FnSnap__Printing_and_PCL.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
==Font Management==
===FNFONT$*30 - Create a PCL font string===

 FNFONT$*30(SYMBOL_SET$,PROPORTIONAL,CHR_PER_INCH,STYLE$,WEIGHT$,TYPEFACE$)

Description|<br>
Creates an HP 5 PCL font string from certain parameters

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNLOADFONT$*50 - Loads a PCL font to printer===

 FNLOADFONT$*50(NUMBER$,FONTCALL$*50;FONT$*100,OUTFILE)

Description|<br>
Moves a downloadable font into an open display file for printing and returns the font calling string to the program.  If the font file does not exist or is invalid the font string is still returned to the program.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

GENERAL

==Reprinting Reports==
===FNCLEANLOG - part of FNREPRINT used to remove out of date reports===

Reviews a log file of reports available for reprinting.  If no destroy date has been entered a default of 30 days is entered.  If a report delete date has expired FNCLEANLOG will delete the report and update the log to indicate the date of deletion. If a report is marked as deleted and the deletion occurred  more than 7 days ago then the report log entry will be removed.

 FNCLEANLOG(;REPORTLOG)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**REPORTLOG **||Optional file number for a report log to be processed.  Generally omitted
|-valign="top"
|width="10%"|**LOGNAME$ **||Not entered her, LOGNAME$ has previously been stored as a variable in the library by another function.
|-valign="top"
|}
<br>
;Comments:<br>
This function is generally run by pressing F4 in the reprint reports list box.

===FNOPEN - create a log file for saved reports===

Opens a display file in a specified directory.  The file name is determined as a sequence number with the leading characters specified in FLNM$.  The name of the open file and the number of the open file are returned to the calling program, ready for creating a RAW print file.

 FNOPEN(&FLNM$,&FLPATH$;PRINTDESC$*80,LLEN,PRINTTYPE$,SAVE_DAYS)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**FLNM$ **||The leading few characters of the file name to be opened.  The function will complete the file name with a sequence number for that type file in the specified path.
|-valign="top"
|width="10%"|**FLPATH$ **||The path, either absolute or relative, where the print file should be created
|-valign="top"
|width="10%"|**PRINTDESC$ **||A description of the file to appear in the REPORTLOG reprint dialog listing
|-valign="top"
|width="10%"|**LLEN **||The length of each line in the display file or zero (0) if EOL=NONE should be used in the open statement
|-valign="top"
|width="10%"|**PRINTTYPE$ **||If omitted "ALL" will be entered meaning the report can be printed to an NWP printer using preview.  Other options are "DIRECT" and "MATRIX" if a specific printer type is required due to character string that are not compatible with NWP.
|-valign="top"
|width="10%"|**SAVE_DAYS **||The number of days a report should be retained for reprinting. If zero (0) is entered no destruction date will be entered, but the first time that FNCLEANLOG is run after the report creation a destroy date of 30 days will be substituted.
|-valign="top"
|}
<br>
;Comments:<br>
To save a report for a long time enter a destroy date number of days significantly in the future such as 365 or 500

===FNMENUACCESS - used in connection with FNREPRINT to determine user permission to reprint a report===

If WORKMENU is being used then FNMENUACCESS checks the permission files to determine if the user has permission to create the report.  If no permission exists to create the report then it cannot be reprinted and is excluded from the detail list of reports available for reprint.

 FNMENUACCESS(MNAME$*10,MSEQ$*3,MPGM$*50)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**MNAME$ **||NAme of the menu from which a report was created
|-valign="top"
|width="10%"|**MSEQ$ **||Sequence number of the menu from which the report was created
|-valign="top"
|width="10%"|**MPGM$ **||The program call in WORKMENU that allowed the report to be created
|-valign="top"
|}
<br>
;Comments:<br>
This function is used by FNREPRINT to determine user rights for reprinting a report.  The variables are all obtained from REPROTLOG.fil and passed to this function to determine whether access should be granted for reprinting.

===FNPRINT - prints a saved report opened using FNOPEN===

Issued immediately after the CLOSE statement of a file opened using FNOPEN to send the stored print file to a specified printer.  Print specification substitutions for the specified printer are performed during this print process for the RAW print file.

 FNPRINT(FILNM$*100,PRINTER$*50)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**FILNM$ **||The name and path of the stored RAW file to be printed.
|-valign="top"
|width="10%"|**PRINTER$ **||A normal BR printer designation.  Can be a substitutable printer type such as \\\\10 or a specific printer such as \\\\server01\\hplaser
|-valign="top"
|}
<br>
;Comments:<br>
FILNM$ is generally shown as filpath$&filnm$, the two variables returned to the calling program by the FNOPEN function

===FNREPRINT - displays a list of available saved reports and prints selected report===

Displays a list of report quantity by month created and allows selection of a month.  The user is then presented with a list of the reports created that month for which permission exists for reprinting.

[PICT(PICS\SNAP0003.ptf)]

[PICT(PICS\SNAP0004.ptf)]

 FNREPRINT(;ALL,LOGNAME$*100,LOGKEY$*100)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**ALL **||If true shows all entries regardless of security rights
|-valign="top"
|width="10%"|**LOGNAME$ **||Name of the log file if other than REPORTLOG.fil
|-valign="top"
|width="10%"|**LOGKEY$ **||Name of the index file if other than REPORTLOG.idx
|-valign="top"
|}
<br>
;Comments:<br>
A program can be created that includes only this function to allow menu access to reprinting

==PCL and NWP formatting==
===Bar Codes and addresses===
;FNBARCODEM - Prints postal bar code to a MATRIX printer

 FNBARCODEM(ODEV,ZIP$;INDENT)

Prints a postal bar code on a matrix printer

;Functions used:<br>
NONE

;Variables:
{|
|-valign="top"
|width="10%"|**ODEV**||File number of open print job
|-valign="top"
|width="10%"|**ZIP$**||Zip Code to be translated to Postal Net
|-valign="top"
|width="10%"|**INDENT**||Default is 10 characters. If other than the default is desired enter the character position of the start of the bar code.
|-valign="top"
|}
<br>
;Comments:

;FNCODE3OF9 - Creates 3 of 9 Bar code in PCL

Prints a bar code in 3 of 9 format

 FNCODE3OF9(PRINTFILE,V,H,TEXT$*30,PRNTXT$;HEIGHT,CHECKD) !:

;Functions used:<br>
FNPRINTBOX

;Variables:
{|
|-valign="top"
|width="10%"|**PRINTFILE**||
|-valign="top"
|width="10%"|**V**||
|-valign="top"
|width="10%"|**H**||
|-valign="top"
|width="10%"|**TEXT$**||
|-valign="top"
|width="10%"|**PRNTXT$**||
|-valign="top"
|width="10%"|**HEIGHT**||
|-valign="top"
|width="10%"|**CHECKED**||
|-valign="top"
|}
<br>
;Comments:

;FNCODEUPC - Creates UPC bar code in PCL

 FNCODEUPC(PRINTFILE,V,H,TEXT$*30;HEIGHT) !:

Description|<br>
Prints a bar code in UPC format

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

;FNENVELOPE - Prints an envelope with return address and Postal Bar Code

Prints an envelope on a laser printer with postal bar code and a return address if a specific overlay file exists (this will be changed in the future to make the return address an option

 FNENVELOPE(PRTFILE,DATAFILE,SIZE$;SUPRET,MAT INNAMES$,NOLBLS,NOCLOSE)

;Functions used:
{|
|-valign="top"
|width="10%"|**FNPOSTNET
|-valign="top"
|width="10%"|**FNPRINTBOX
|-valign="top"
|width="10%"|**FNTYPE
|-valign="top"
|}
<br>
;Variables:
{|
|-valign="top"
|width="10%"|**PRTFILE**||Number of open print file to which envelope will be printed
|-valign="top"
|width="10%"|**DATAFILE**||Number of the file that contains the graphic for the return address
|-valign="top"
|width="10%"|**SIZE$**||Code indicating the envelope size to be printed
|-valign="top"
|width="10%"|**SUPRET**||Return address is suppressed if this is TRUE, if FALSE return address and graphic are printed
|-valign="top"
|width="10%"|**MAT INNAMES$**||Matrix containing the name and address to be printed
|-valign="top"
|width="10%"|**NOLBLS**||Number of copies of the printed envelope to be printed
|-valign="top"
|width="10%"|**NOCLOSE**||If this is TRUE then the print file is to be left open.  If false the default is to close the print file after printing the envelope.
|-valign="top"
|}
<br>
;Comments:

;FNGETZIP - extracts a zip code from an address line

Searches then end of the passed string to obtain a valid zip code.  If one is found then the zip code excluding any dash is returned as the value of the function

 FNGETZIP$(ADD$*50)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**ADD$ **||A right trimmed string that carries a zip code at the right hand end.
|-valign="top"
|}
<br>
;Comments:

;FNLABEL - prints a 3 1/3 x 4 laser label on 3 x 2 stock

Prints a mailing label including postal zip bar code on a 3x4 6 to a sheet laser printed label

 FNLABEL(FILNUM,MAT FADD$,MAT TADD$;START,NUMBER)

;Functions used:<br>
FNPRINTBOX<br>
FNDRAWBOX<br>
FNGETZIP<br>
FNPOSTNET

;Variables:
{|
|-valign="top"
|width="10%"|**FILENUM **||File number of already open display or print file
|-valign="top"
|width="10%"|**MAT FADD$ **||From Address matrix. Array of three elements
|-valign="top"
|width="10%"|**MAT TADD$ **||To address matrix. Array of 3 or 4 elements
|-valign="top"
|width="10%"|**START **||Starting number on the label sheet containing 6 3 x 4 labels
|-valign="top"
|width="10%"|**NUMBER **||Quantity of labels to prepare
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

;FNPOSTNET - Prints the Postal Bar Code created by FNPOSTNET$

 FNPOSTNET(PRINTFILE,V,H,TEXT$*20) !:

Description|<br>
Print postal bar code to a laser printer in PCL format

;Functions used:
{|
|-valign="top"
|width="10%"|**FNPOSTNET
|-valign="top"
|}
<br>
;Variables:
{|
|-valign="top"
|width="10%"|**PRINTFILE**||Number of open print file to which the bar code will be printed
|-valign="top"
|width="10%"|**V**||Vertical position of the upper left corner of the bar code in inches
|-valign="top"
|width="10%"|**H**||Horizontal position of the upper left corner of the bar code in inches
|-valign="top"
|width="10%"|**TEXT$**||Postal zip code to be translated to a bar code
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:<br>
Works in PCL and NWP modes

;FNPOSTNET$*4000 - Creates a postal bar code in PCL

 FNPOSTNET$*4000(TEXT$*20) !:

Description|<br>
Creates a postal bar code in PCL format

;Functions used:<br>
FNPRINTBOX

;Variables:
{|
|-valign="top"
|width="10%"|**TEXT$**||The postal bar code in a string variable.
|-valign="top"
|}
<br>
;Comments:<br>
If the string variable cannot be converted into a valid postal zip code FNPOSTNET will return a blank.

===Forms and formatting===
;FNDRAWBOX - Prints a four sided shaded box on PCL

 FNDRAWBOX(PRINTFILE,VP,HP,VL,HL,WEIGHT;FILL)

Description|<br>
PCL5 code to print a box with outline and shading to an HP compatible laser printer

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

;FNGREYBAR - Creates the overlay used in FNGREYBAR$

 FNGREYBAR(PRINTFILE,V,H,BV,BH,SHADE,HEAD,BAR)

Description|<br>
Creates the gray bar PCL code used by FNGREYBAR$

Functions used |FNPRINTBOX

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

;FNGREYBAR$ - Overlays a printout with gray bar effect

 FNGREYBAR$(MACRO,PRINTFILE,V,H,BV,BH,SHADE,HEAD,BAR)

Description|<br>
Creates a PCL5 macro that simulates green bar paper and returns the macro call

Functions used |FNGREYBAR

;Variables:
{|
|-valign="top"
|width="10%"|**MACRO**||Macro number to assign
|-valign="top"
|width="10%"|**PRINTFILE**||Number of open print file
|-valign="top"
|width="10%"|**V**||Upper left corner of paper in inches (usually 0)
|-valign="top"
|width="10%"|**H**||Upper left corner of the paper in inches (usually 0 but could be 0.5 to allow for notebook holes).
|-valign="top"
|width="10%"|**BV**||Vertical height in inches of the area to be covered with gray bars
|-valign="top"
|width="10%"|**BH**||Horizontal width in inches of each the area to be covered by gray bars
|-valign="top"
|width="10%"|**SHADE**||Depth of shade of the bars in multiples of 10 form 0 to 100 (recommend 20 or 30)
|-valign="top"
|width="10%"|**HEAD**||Size in inches of the blank space at the top for title and other header information
|-valign="top"
|width="10%"|**BAR**||height on inches of the gray bars
|-valign="top"
|}
<br>
;Comments:

;FNMAKEPCL - converts an HP6l saved file into a file for PCL overlay

Processes a display file created by print through an HP6L print driver to a file.  FNMAKEPCL removes the characters necessary to prepare the file for being a MACRO overlay or a part of a continuous print job.

 FNMAKEPCL(INFILE$*100,OUTFILE$*100)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**INFILE$ **||The name of the saved HP6L print file to be converted
|-valign="top"
|width="10%"|**OUTFILE$ **||The name of the file to be created as a result of the conversion
|-valign="top"
|}
<br>
;Comments:

;FNPRINTBOX - Creates a PCL line and positions formatted text in PCL

 FNPRINTBOX(PRINTFILE,V,H,BV,BH,SHADE;TV,TH,TEXT$*6000,CPI,FONT$*40) !:

Description|<br>
PCL5 code to print a line and optionally formatted text to an HP compatible lase printer

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**V**||Vertical position of upper left corner of print area in inches
|-valign="top"
|width="10%"|**H**||Horizontal position of upper right corner of print area in inches
|-valign="top"
|width="10%"|**BV**||Vertical depth of the print area below V in inches
|-valign="top"
|width="10%"|**BH**||Horizontal width of the print area to the right of H
|-valign="top"
|width="10%"|**SHADE**||Index for gray shading in multiples of 10 from 0 (white) to 100 (black)
|-valign="top"
|width="10%"|**TV**||Vertical position of text to print below V in inches
|-valign="top"
|width="10%"|**TH**||Horizontal position of text to print to the right of H in inches - -1 causes the text to be centered in PCL mode. -1 is not compatible with NWP.
|-valign="top"
|width="10%"|**TEXT$**||Text string to be printed starting at TV TH
|-valign="top"
|width="10%"|**CPI**||
|-valign="top"
|width="10%"|**FONT$**||
|-valign="top"
|}
<br>
;Comments:

;FNPRINTFORM$*40

 FNPRINTFORM$*40(FILNUM,FORMFILE,SHORTNAME$)

Description|<br>
Extracts a form,page,macro or font from a library file and places it into an existing open display file for printing

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**FILNUM**||Number of existing open print file to receive form. The file should be opened with EOL=NONE.
|-valign="top"
|width="10%"|**FORMFILE**||Number of existing open file containing the form to be printed.
|-valign="top"
|width="10%"|**SHORTNAME$**||Eight character name for the storied form.  This is the key-name within the FORMFILE
|-valign="top"
|}
<br>
;Comments:<br>
The function reads through the records of the FORMFILE until a match for the SHORTNAME is found.  That record along with subsequent records containing the same SHORTNAME are added to the open print file.  Records are transferred in 32000 bit chunks so the transfer is quite rapid.

;FNSIGNBOX - Prints a signature or small graphic in PCL

 FNSIGNBOX(FILNUM,V,H,SIGFIL,SHORT$,&PASS$)

Description|<br>
Extract a small graphic such as a signature from a library file and place it at a specified location on a document

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**FILNUM**||Number of open print file to which the signature should be added
|-valign="top"
|width="10%"|**V**||Vertical position in inches of the upper left corner of the graphic to print
|-valign="top"
|width="10%"|**H**||Horizontal position in inches of the left hand edge of the graphic to print
|-valign="top"
|width="10%"|**SIGFIL**||The number of the file containing the signature graphic
|-valign="top"
|width="10%"|**SHORT$**||The eight character name of the signature to be used.  If this case sensitive name is not found in the file no signature is printed
|-valign="top"
|width="10%"|**&PASS$**||Password - case sensitive.  Must match the password saved for the signature or no signature will be printed.  The password is passed back to the application so that on a check run or similar application the operator will not have to enter the password for each check.
|-valign="top"
|}
<br>
;Comments:<br>
The signature file is built using a separate utility program names SIGPRN.br.  The signature is taken from the print file created by printing a Word document containing just the signature to an HP6L laser printer driver in print to file mode.  The utility program print a facsimile of the signature as part of the import process.  The facsimile is overlain with reference lines showing where the upper left corner of the print graphic appears.

The signature is limited to one 32000 bit record.  Consequently large or complex signatures or graphics may not be compatible and may need to be made smaller or less compiles in order to work with this particular program.

==RTF Printing==
===FNRTFSTART - opens a source file to produce an RTF file using RTFLIB.dll===

Opens a file ready to receive data for creating an RTF file using LIBRTF.dll

 FNRTFSTART(HEADER$*100,FOOTER$*100,TITLE$*500,MAT HEADER$;CELLNO)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**HEADER$ **||Text to be displayed as a header on each page of the report
|-valign="top"
|width="10%"|**FOOTER$ **||Text to be displayed as a footer on each page of the report.  To include a page number include "[ PAGE]" as a part of the line.
|-valign="top"
|width="10%"|**TITLE$ **||Text to be displayed at the top of the first page only as a report title
|-valign="top"
|width="10%"|**MAT HEADERS$ **||The matrix including the bar delimited text that should appear in the header bar at the top of each column
|-valign="top"
|width="10%"|**CELLNO **||An optional cell number for the SPC file if a header that repeats automatically on each page is to be used. If omitted the headers will appear on the first page only formatted exactly the same as the rest of the RTF table that is being created.
|-valign="top"
|}
<br>
;Comments:

===FNRTFEND - turns a source file built with FNRTFSTART into a finished document===

Converts

 FNRTFEND$*100(RTFNO,RTFNAME$*100,RTFSPEC$*100;WORD)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**RTFNO **||The file number of the display file that was opened when FNRTFSTART was called
|-valign="top"
|width="10%"|**RTFNAME$ **||The name and path of the source file to be created when RTFNO is processed by FNRTF to RTF.
|-valign="top"
|width="10%"|**RTFSPEC$ **||The name of the RF specification file that contains style formats to be used in creating the RTF file
|-valign="top"
|width="10%"|**WORD **||A flag to indicate whether WORD should be called at the end of the creation process (True) or the RTF file should not be viewed at the end of the process (false)
|-valign="top"
|}
<br>
;Comments:<br>
A sample specification file looks like the following
 LET LMARGIN=.75
 LET RMARGIN=1.0
 LET TMARGIN=.50
 LET BMARGIN=.50
 LET ORIENTATION$="PORTRAIT"
 LET PAPER$="LETTER"
 LET CHECKLIST=0
 LET LEFTTEXT$=""
 LET NUME=0
 MAT TYPES$(12)
 LET TYPES$(1)="H"
 LET TYPES$(2)="F"
 LET TYPES$(3)="D"
 LET TYPES$(4)="S"
 LET TYPES$(5)="T"
 LET TYPES$(6)="A"
 LET TYPES$(7)="B"
 LET TYPES$(8)="C"
 LET TYPES$(9)="E"
 LET TYPES$(10)="G"
 LET TYPES$(11)="N"
 LET TYPES$(12)="I"
 MAT STYLES$(12)
 LET STYLES$(1)="li0ri0fARIALfs14cfBluetc3.25Header"
 LET STYLES$(2)="li0ri0fARIALfs8cfBlacktc3.25Footer"
 LET STYLES$(3)="li0.5QJfPALATINOri0fs12tl0.5tl1.0tl1.5td5.4Data"
 LET STYLES$(4)="li0.5QCsa1ri0Bfs19fARIALtl0.5tc3.25Title Page"
 LET STYLES$(5)="li0.5QCfARIALsa1ri0Bfs18tl0.5tc3.25Heading 1"
 LET STYLES$(6)="li0.25ri0fARIALBfs17tl0.5tr5.4Heading 2"
 LET STYLES$(7)="li0.25ri0fARIALBfs15tl0.5tr5.4Heading 3"
 LET STYLES$(8)="li0.25ri0fARIALBfs13tl0.5td5.4Heading 4"
 LET STYLES$(9)="fi-0.5td0.75li1.0ri0fPALATINOfs12tl0.5tl1.0td6.0Detail steps"
 LET STYLES$(10)="fi-0.4li1.0ri0ft61fs10fCOURIERtl0.5tc4.0td5.4Program lines"
 LET STYLES$(11)="li0.5ri0BfPALATINOfs12cfDKBLUEtl0.5tl1.0tl1.5td5.4New Items"
 LET STYLES$(12)="fi-1.25li2.0ri0fPALATINOfs12tl2.0Options"
 
 MAT CELLS$(10)
 rem LET CELLS$(1)="li0.5tg0.125c1btrlb1vthlc1.5btrlb1vthc"
 rem LET CELLS$(2)="li0.5tg0.125fPALATINOfs10c3btrlb1vthlc3btrlb1vthl"
 rem LET CELLS$(3)="li0.5tg0.125fPALATINOfs10c2btrlb1vthlc2btrlb1vthlc2btrlb1vthl"
 
 rem ODD numbers are headers even numbers are the following table
 
 LET CELLS$(1)="li0.0tg0.100fPALATINOfs10trh"
 LET CELLS$(1)=CELLS$(1)&"c3.0brtlrb1vthcsh15"
 LET CELLS$(1)=CELLS$(1)&"c3.0brtlrb1vthcsh15"
 
 LET CELLS$(2)="li0.0tg0.100fPALATINOfs10"
 LET CELLS$(2)=CELLS$(2)&"c3.0brtrlb1vthl"
 LET CELLS$(2)=CELLS$(2)&"c3.0brtrb1vthl"
 
 LET CELLS$(3)="li0.0tg0.100fPALATINOfs10trh"
 LET CELLS$(3)=CELLS$(3)&"c2.0brtrlb1vthcsh15"
 LET CELLS$(3)=CELLS$(3)&"c2.0brtrlb1vthcsh15"
 LET CELLS$(3)=CELLS$(3)&"c2.0brtrlb1vthcsh15"
 
 LET CELLS$(4)="li0.0tg0.100fPALATINOfs10"
 LET CELLS$(4)=CELLS$(4)&"c2.0btrlb1vthl"
 LET CELLS$(4)=CELLS$(4)&"c2.0btrlb1vthl"
 LET CELLS$(4)=CELLS$(4)&"c2.0btrlb1vthl"
 
 LET CELLS$(5)="li0.5tg0.100fARIALfs10"
 LET CELLS$(5)=CELLS$(5)&"c3.0btrlb1fCOURIERvthl"
 LET CELLS$(5)=CELLS$(5)&"c0.5fs8btb1vthc"
 LET CELLS$(5)=CELLS$(5)&"c0.5btlb1fPALATINOvthc"
 LET CELLS$(5)=CELLS$(5)&"c1fs10btrlb1fARIALvthr"
 LET CELLS$(5)=CELLS$(5)&"c1brtrlb1vthr"
 LET CELLS$(5)=CELLS$(5)&"c1brtrlb1vthr"
 LET CELLS$(5)=CELLS$(5)&"c1brtrlb1vthr"
 LET CELLS$(5)=CELLS$(5)&"c1brtrlb1vthr"
 LET CELLS$(5)=CELLS$(5)&"c1brtrlb1vthr"
 
 LET CELLS$(7)="li0.0tg0.100fPALATINOfs10trh"
 LET CELLS$(7)=cells$(7)&"c0.5brtrlb1vthcsh15"
 LET CELLS$(7)=cells$(7)&"c0.5brtrlb1vthcsh15"
 LET CELLS$(7)=cells$(7)&"c0.5brtrlb1vthcsh15"
 LET CELLS$(7)=cells$(7)&"c0.5brtrlb1vthcsh15"
 
 LET CELLS$(8)="li0.0tg0.100fPALATINOfs10"
 LET CELLS$(8)=cells$(8)&"c0.5brtrlb1vthc"
 LET CELLS$(8)=cells$(8)&"c0.5brtrlb1vthc"
 LET CELLS$(8)=cells$(8)&"c0.5brtrlb1vthc"
 LET CELLS$(8)=cells$(8)&"c0.5brtrlb1vthc"
 

==FNREFERENCE - Prints a page reference on bottom right corner in PCL==

 FNREFERENCE(PTYPE$,REFERENCE$;PFILE,LGL)

Description|<br>
Prints a page reference in PCL in the lower right corner of a printed page

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**PTYPE$ **||Must start with "HP" in order for the reference code to be printed
|-valign="top"
|width="10%"|**REFERENCE$ **||Reference code to be printed in lower right corner of page
|-valign="top"
|width="10%"|**PFILE **||The number of the currently open print file where the reference should be inserted
|-valign="top"
|width="10%"|**LGL **||If True print for a legal sized page otherwise print for letter sized
|-valign="top"
|}
<br>
;Comments:

==FNPRINT_FILE - Prints a text file on Grey bar Paper==

 FNPRINT_FILE(FILE_NAME$*100;INDENT)

Description|<br>
Prints an ASCII file formatted at 100 character lines with a ruler at the top of the page

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**FILE_NAME$ **||Name of display file to print on greybar paper
|-valign="top"
|width="10%"|**INDENT **||Number of spaces that each line of text should be indented from the left margin
|-valign="top"
|}
<br>
;Comments:

==FNPRINTERS - Creates a printed list of printers and a printers.sys file==

 FNPRINTERS(;DRIVE_LOC$)

;Description:<br>
Not to be confused with the PRINTER.SYS PCL/NWP substitution parameters

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:
