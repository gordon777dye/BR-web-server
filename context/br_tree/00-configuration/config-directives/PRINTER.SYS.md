---
title: PRINTER.SYS
file: PRINTER.SYS.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [NWP, PCL, Printer.CLS, Business Rules!, brconfig.sys, included]
---
**Printer.sys** is an easy way to do `NWP` and `PCL` (`Printer.CLS` adds HTML and Text).  By taking advantage of various printer substitution statements, you now have an easier way to take advantage of BR's printing features.

There are a few things you can do with PCL that you still cannot do using NWP, but the programmers of `Business Rules!` are working to give the NWP programmer access to a very comprehensive set of PCL coding and features.

There are also several NWP only features - new escape sequences which BR! will interpret to do many powerful things not easily available in PCL.

Note:  Printer.sys is just a `brconfig.sys` file, and it can easily be `included` customized and/or modified.  If you need a font size that I left out, or if you want names that are easier to remember, these changes are very simple to implement. Just include your changes after you include Printer.Sys. BR! uses the last occurrence of each matching Printer substitution statement.

Printer.Sys is a shared project in which standardized printer substitutions are shared by everyone who uses it.  Printer.sys was originally developed by `User:Gabriel|Gabriel Bakker`.

*[ftp://ftp.brulescorp.com/Dll_Distr/printing/printer.sys Download Printer.Sys from FTP.BRULESCORP.COM]

==Printer.Sys==

Welcome to printer.sys. This document is divided into two sections. The first section explains the syntax available for PCL, and the second explains the syntax available for NWP printing.

===PCL===
The following Substitute codes work in PCL. Those with a * will work only in PCL.

====Initial configuration====
=====Orientation=====
The following must be done before anything is printed to the printer.
*[PORTRAIT]                    Sets the printer to print portrait
*[LANDSCAPE]                   Sets the printer to print landscape

=====Paper Size=====
======Standard======
The next six settings change the logical page size for printing on different sized pages.
*[EXECUTIVE]                   Set the logical page for Executive size paper (7.25 x 10.5)
*[LETTER]                      Set the logical page for Letter size paper (8.5 x 11)
*[LEGAL]                       Set the logical page for Legal size paper (8.5 x 14)
*[LEDGER]                      Set the logical page for Ledger size paper (11 x 17)
*[A4PAPER]                     Set the logical page for A4 size paper (210mm x 297mm)
*[A7PAPER]                     Set the logical page for A7 size paper (297mm x 420mm)

======Envelope======
The next five settings change the logical page size for printing on envelopes.
*[MONARCH]                     (3 7/8 x 7.5)
*[COM-10]                      (4 1/8 x 9.5)
*[INTERNATIONAL DL]            (110mm x 220mm)
*[INTERNATIONAL C5]            (162mm x 229mm)
*[INTERNATIONAL B5]            (176mm x 250mm)

=====Paper Source*=====
The following six options set the paper source. By default it is set to Auto, and can be changed in printer preferences.
*[PAPERSOURCE AUTO]*             Feed from Printer Default
*[PAPERSOURCE MANUAL]*           Feed from manual feeder
*[PAPERSOURCE MANUALENVELOPE]*   Feed Envelope from manual feeder
**                                (Must set to Envelope size first)
*[PAPERSOURCE TRAY2]*            Feed from Lower Tray
*[PAPERSOURCE OPTIONAL]*         Feed from Optional Input
*[PAPERSOURCE OPTIONALENVELOPE]* Feed from Optional Envelope Feeder 
**                                (Must set to Envelope size first)
*[PAPERSOURCE(SOURCE)]*          Set the current paper source
**                                SOURCE is the PCL Paper Source Code

=====Copies*=====
The following option will set the printer to print multiple copies.

*[COPIES(##)]*                 Will generate the pcl to make any number of copies

Use it like “[COPIES(14)]” to generate the pcl to instruct the printer to make 14 copies.

=====Duplex Mode*=====
These three options set the printer to print in Duplex mode.

*[SIMPLEX]*                    Standard one sided printing
*[DUPLEX]*                     Long edge binding double sided environmental printing
*[DUPLEX SHORTEDGE]*           Short edge binding double sided printing

Long edge binding is like your standard book. Short edge binding would be used for a calendar or one of those funky long picture books.

=====Top Margin=====
The following six options set the top margin: how many rows at the top of the logical page to reserve for blank space.
*[TOP0]                        Begin printing at the top of the logical page
*[TOP1]                        Skip one line, then begin printing
*[TOP2]                        Skip two lines, then begin printing
*[TOP3]                        Skip three lines, then begin printing
*[TOP4]                        Skip seventeen lines, then begin printing
*[TOP5]                        Skip five lines, then begin printing
*[TOP(##)]                     Skip ## lines, then begin printing

====Real Time Printing====
All of the following PCL commands can be executed in the middle of a printing job.

=====LPI=====
The following commands modify the LPI settings for the printer:

  [4LPI]
  [6LPI]
  [8LPI]
  [10LPI]
  [LPI(##)]

This setting controls the number of lines printed per inch vertically on the page.

=====CPI=====
The following commands modify the CPI settings for the printer:

  [4CPI]
  [6CPI]
  [8CPI]
  [10CPI]
  [12CPI]
  [14CPI]
  [16CPI]
  [20CPI]
  [CPI(##)]

This setting controls the number of characters printed per inch horizontally on the page.

=====Font Changes=====
The next couple substitution statements are examples of the PCL syntax for setting fonts. These codes are supported under NWP, but we also have a better way to do this in NWP.
  [FONT TIMES]                  Times New Roman
  [FONT ARIAL]                  Arial
  [FONT LINEPRINTER]            Good ole fashioned Line Printer
  [SETFONT(FontNumber)]*        Set current font by number (see HpPcl.pdf)
  **NOTE: setfont works in NWP as well, but you specify your font by name instead of number.**

=====Font Size=====
If you want to change the font size, you can even do that!
  [TINY]                        6 pt font
  [SMALL]                       8 pt font
  [LITTLE]                      10 pt font
  [MEDIUM]                      12 pt font
  [ESSAY]                       14 pt font
  [LARGE]                       18 pt font
  [JUMBO]                       36 pt font
  [GARGANTUAN]                  96 pt font
  [155POINT]                    15.5 pt font
  [SETSIZE(PointSize)]          Set current font size

'''Remember: printer.sys is just a brconfig.sys file, and it can easily be customized and modified. It's easy to customize the names or font sizes available for use.'''

=====Bold/Underline/Italics=====
These next few statements control various common font modifiers.
  [UNDERLINE] [/UNDERLINE] [UL] [/UL]
  [ITALICS] [/ITALICS]
  [BOLD] [/BOLD]

=====Rotation*=====
One of the remaining advantages to using PCL is the ability to print in different directions on the page. This can be done in PCL with the following:
  [ROTATE0]*                    Sets the page direction normal
  [ROTATE90]*                   Sets the page direction to 90
  [ROTATE180]*                  Sets the page direction to 180
  [ROTATE270]*                  Sets the page direction to 270 CC

=====Position=====
The following commands all set the cursor position:
  [TOPLEFT]                     Places the cursor at the top left of the page
  [DECIPOS(XXX,YYY)]            Set Position in Decipoints
  [ROWCOL(XXX,YYY)]             Set Position in Rows and Columns
  [POS(XXX,YYY)]                Set Position in Rows and Columns
  [PCLPOS(XXX,YYY)]             Set Position in PCL units

The PCL command for positioning provides three ways to set the current position. You may do it based on Decipoints (1/720th of an inch). You may also set the position based rows and columns, or PCL units (pixels). If you append a +/- to the position numbers, you will set the relative position, relative to the current cursor position. XXX is the horizontal coordinate, and YYY is the vertical coordinate.

=====Push/Pop=====
Next we have commands for storing the current position on the Stack. This will save the current position into printer memory and allow you to do anything you want with it. When you are done doing what you wanted to do, you may then pop the value back off the stack, and the cursor goes right back to where it was. The syntax is:

  [PUSH]                        Push!
  [POP]                         *Pop*

HP Printers have a stack in their printer memory which you can use to store the current position. Use the stack to save the current cursor position with a  [PUSH] command. You many move it wherever you like and print whatever you like, and when you are ready to continue from where you left off, you simply [POP] and the cursor goes right back where it was. A stack is like a FOR loop; you can nest your [PUSH] and [POP] statements.

One great use I can see for these commands is functions that you wish to use to place graphics on your printout. It would be a nice idea for a polite function in modern society to push the current cursor position before processing (to draw a box or whatever) and then pop the cursor position back to where it was. This way, if you are in the middle of printing a report, and you want to put lines on the report to underline something while you know where you are, you can call your function. When you are done, the function will place you right back where you were before you called it, and you may just finish printing the line as usual.

===== Proportional Spacing* =====
The following statements will set the Printer into Proportional Spacing mode.

  [PS]*                         Set Proportional Spacing
  [/PS]*                        Cancel Proportional Spacing

Proportional Spacing is Character spacing based on the width of each character. The printer must be set into this mode before you may change the font size, or use any proportional fonts. The fonts that we have shortcuts for will automatically set [PS] mode accordingly, so they will work, but you will need [PS] mode anytime you wish to set your own fonts.

=====ESC Key=====

  [E]                           ESC Key (used for generating your own PCL code)

====Parameterized Substitute Statements====
We have a new format for specifying printer substitute statements.

With the old syntax, you are able to specify the number of copies with a substitute statement such as the following:
  PRINTER PCL [COPIES10], “\E&l10X”

With the new syntax, you are able to specify a value to pass to the substitution statement that will be placed in the actual replacement text of the statement! For example:
  PRINTER PCL [COPIES(YYY)], "\E&lYYYX" ! Print as many as you want

Now you may use a printing statement such as the following:
  PRINT #255: “[COPIES(57)]”
And the correct PCL would be generated to set the printer to print 57 copies.

===NWP===
The following Substitute codes work in NWP. Those with a * will work only in NWP.
In this document [E] represents chr$(27), the ESC key. You may use [E] directly in your programs, as long as you are using printer.sys.

====Initial configuration====
=====Orientation=====
The following must be done before anything is printed to the printer.
  [PORTRAIT]                    Sets the printer to print portrait
  [LANDSCAPE]                   Sets the printer to print landscape

=====Paper Size=====
======Standard======
The next six settings change the logical page size for printing on different sized pages.
  [EXECUTIVE]                   Set the logical page for Executive size paper (7.25 x 10.5)
  [LETTER]                      Set the logical page for Letter size paper (8.5 x 11)
  [LEGAL]                       Set the logical page for Legal size paper (8.5 x 14)
  [LEDGER]                      Set the logical page for Ledger size paper (11 x 17)
  [A4PAPER]                     Set the logical page for A4 size paper (210mm x 297mm)
  [A7PAPER]                     Set the logical page for A7 size paper (297mm x 420mm)

======Envelope======
The next five settings change the logical page size for printing on envelopes.
  [MONARCH]                     (3 7/8 x 7.5)
  [COM-10]                      (4 1/8 x 9.5)
  [INTERNATIONAL DL]            (110mm x 220mm)
  [INTERNATIONAL C5]            (162mm x 229mm)
  [INTERNATIONAL B5]            (176mm x 250mm)

=====Dot Matrix Compatability Settings*=====
NWP contains several formatting options for printing on older dot matrix printers:
  [LETTER QUALITY]*             Sets the printer in LQ mode
  [LQ]*                         Sets the printer in LQ mode
  [DRAFT]*                      Sets the printer in Draft mode
  [EMPHASIZED]*                 Some question the difference between this and LQ
  [EMPH]*                       Some question the difference between this and LQ
  [/EMPHASIZED]*                Exits Emphasized Mode
  [/EMPH]*                      Take a guess
  [ENHANCED]*                   I would guess Enhanced Mode
  [/ENHANCED]*                  Exits Enhanced Mode

=====Top Margin=====

The following six options set the top margin: how many rows at the top of the logical page to reserve for blank space.
  [TOP0]                        Begin printing at the top of the logical page
  [TOP1]                        Skip one line, then begin printing
  [TOP2]                        Skip two lines, then begin printing
  [TOP3]                        Skip three lines, then begin printing
  [TOP4]                        Skip seventeen lines, then begin printing
  [TOP5]                        Skip five lines, then begin printing
  [TOP(##)]                     Skip ## lines, then begin printing

====Real Time Printing====
All of the following NWP commands can be executed in the middle of a printing job.

=====LPI=====
The following commands modify the LPI settings for the printer:
  [4LPI] [6LPI] [8LPI] [10LPI] [LPI(##)]
This setting controls the number of lines printed per inch vertically on the page.

=====CPI=====
The following commands modify the CPI settings for the printer:
  [4CPI] [6CPI] [8CPI] [10CPI] [12CPI] [14CPI] [17CPI] (16.7) [20CPI] [CPI(##)]
This setting controls the number of characters printed per inch horizontally on the page.

=====Font=====
NWP adds support for a totally new way to implement font changes in your programs. With NWP, we have added a new Escape sequence that allows you to set your font to any of the installed fonts on your computer. The command looks like this:

  PRINT #255: “[E]font=‘Arial’This is Arial”

Printer.sys includes a few premapped font substitute statements to make this even easier.
  [FONT MICR]*                  Sets the font to Micr
  [FONT TIMES]                  Sets the font to Times New Roman
  [FONT ARIAL]                  Sets the font to Arial
  [FONT LINEPRINTER]            Sets the font to Line Printer
  [George Tisdale]*             Sets Font to Blue Regular 12 pt Arial

  [FONT]*                       becomes "[E]font=". Specify any font such as [FONT]'WingDings'
  [SETFONT(FontName)]*          Set current font to any installed font
  **NOTE: SetFont works in PCL as well, but you must specify your font by number instead of name.**

=====Font Sizes=====
If you want to change the font size, you can even do that!
  [TINY]                        6 pt font
  [SMALL]                       8 pt font
  [LITTLE]                      10 pt font
  [MEDIUM]                      12 pt font
  [ESSAY]                       14 pt font
  [LARGE]                       18 pt font
  [JUMBO]                       36 pt font
  [GARGANTUAN]                  96 pt font
  [155POINT]                    15.5 pt font
  [SETSIZE(PointSize)]          Set current font size

**One thing to note, printer.sys is just a brconfig.sys file, and it can easily be customized and modified. If you need a font size that I left out, or if you want easier to remember names, these changes are very easy to implement.**
 
=====Colors*=====
With NWP, we have implemented an easy way to make Colors work, as well. It’s actually remarkably similar to the syntax for FONTS. It looks like:

  PRINT #255: “[E]color=’#FF0000’This is RED”

The following colors are predefined for your printing pleasure.
  [RED]* [GREEN]* [BLUE]* [MAGENTA]* [CYAN]*
  [YELLOW]* [ORANGE]* [PURPLE]* [BLACK]* [WHITE]*

The following substitution statement is also available:
  [COLOR]*                      Becomes "[E]color=". Specify any html color such as [COLOR]'#0000FF'
  [SETCOLOR(CLRCODE)]*          Specify any html color such as [SETCOLOR(#0000FF)]

=====Underline/Overline=====
NWP has its own syntax for specifying Underline and Overline.

  [UNDERLINE]                   becomes "[E]-1" - Turn on Underline
  [/UNDERLINE]                  becomes "[E]-0" - Turn off Underline
  [UL]                          becomes "[E]-1" - Turn on Underline
  [/UL]                         becomes "[E]-0" - Turn off Underline
  [OVERLINE]*                   becomes "[E]_1" - Turn on Overline
  [/OVERLINE]*                  becomes "[E]_0" - Turn off Overline

=====Bold/Italics=====
The standard syntax for specifying Bold and Italics is still available.
  [ITALICS] [/ITALICS]
  [BOLD] [/BOLD]

=====Boxing*=====
Perhaps the most exciting new feature of Native Windows Printing is a new NWP Only escape sequence for printing Boxes and Shading. With this command, it has never been easier to generate grids and boxes, columns and tables for all your reporting needs.

The way it works is simple. You simply turn Boxing on, and all the text you print is covered at the top and bottom with a box border. To print the sides of the box, you simply need to print a “|” (pipe) character. BR will replace the pipe character with a line drawn at the correct place (according to the current CPI settings) to make a column border, or the edge of the box. If you want to cause your columns to line up, without printing anything, you can place a hex 05 instead of a “|” (pipe) character. This will not print anything but will otherwise work exactly like a “|”.

You may use the escape sequence “[E]begin_box” to turn on boxing.

If you wish to print only the sides and the top of the box, you may do so by printing “[E]begin_boxtop”. This will print the border on the top, and it will print a vertical border anywhere you print a “|”. It will also cause an invisible column separator anywhere it finds a hex 05. This is in case you would like to print a box that spans multiple rows.

When you then want to print the bottom of the box, you may send the escape sequence “[E]begin_boxbottom”. This will print a line below the text, but not above. The “|” and hex 05 symbols will still be interpreted in the usual fashion.

For all those rows in the middle of the box, you have the command “[E]begin_verticals”. This will print nothing on the top or the bottom, but it will still print the vertical bar wherever you print a “|”, and create an invisible column separator wherever you print a hex 05.

Finally, to turn off boxing features, simply issue an “[E]end_box” command.

In addition to this, to make your reports look extra nice, we have included two commands to turn on and off shading. This will shade the background of the text using the current shade density. This is great for lightly shading every second row of a report so that they stand out, and its easy to see what goes with what. To turn shading on, issue a “[E]begin_shade”. To turn it back off, issue an “[E]end_shade” command.

To change the current shading density by hand, I am afraid, you will have to resort to good ole pcl (or else use the printer.sys shortcuts listed below). The command to do this is "[E]*c##G" where ## is the shading density, by percent.

Luckily, printer.sys has the following shortcuts defined to help you out.
  [BOX]*                        Begin Box Mode
  [/BOX]*                       End Box Mode
  [BOXTOP]*                     Begin Box Top Mode
  [BOXOVER]*                    Synonym for BOXTOP
  [BOXVERTICALS]*               Begin Box Verticals
  [BOXSIDES]*                   Synonym for BOXVERTICALS
  [BOXBOTTOM]*                  Begin Box Bottom
  [BOXUNDER]*                   Synonym for BOXBOTTOM

  [SHADE]*                      Turn on Shading
  [/SHADE]*                     Turn off Shading

  [SHADE0]*                     White
  [SHADE20]*                    Light
  [SHADE40]*                    Kinda Light
  [SHADE60]*                    Kinda Dark
  [SHADE80]*                    Dark
  [SHADE100]*                   Black
  [SHADE(Percent)]*             Sets the Shading percent

  [SEPARATOR]*                  Prints a HEX 05, causing an invisible column separator
  [|]*                          Prints a HEX 05, causing an invisible column separator

Grids work best with the same number of columns on each row. If you want to use a different number of visible columns on each row, use invisible column separators to make each row have the same number of columns. Otherwise you may notice small amounts (1 or 2 pixels) of in-congruency towards the right portion of your grid. The columns do not have to be the same width, but there should be the same number of columns. Experiment, and I’m sure you will figure it out.

=====Position=====
With NWP, you have one additional option for setting your cursor position. There is a new NWP only escape sequence: “[E]position=’x,y’ ”, for your printing pleasure. If you prefix your numbers with a +/- then BR will interpret them as a relative position, and it will simply adjust from the current position. Position must be specified in Inches for this new escape sequence.

Some substitution statements have been added to aid you with this:
  [TOPLEFT]                     Set curser to top left
  [DECIPOS(XXX,YYY)]            Set Position in Decipoints
  [ROWCOL(XXX,YYY)]             Set Position in Rows and Columns
  [POS(XXX,YYY)]                Set Position in Rows and Columns
  [PCLPOS(XXX,YYY)]             Set Position in PCL units
  [POSITION(XXX,YYY)]*          Set Position in inches
  [POSITION]*                   Becomes "[E]position=" - Set Position in inches
                                  use like: PRINT #255: "[POSITION]'2,3'The Middle."

It is important to note that the NWP only position specified in inches is relative to the top left corner of the page, outside the printable area. If you were to say [POSITION(0,0)] or [POSITION]’0,0’ then you will place the cursor outside the printable area of the page, and what you print may not show up. This is so that when you say something such as [SETPOSITION(3,4)] You know with certainty that it is exactly three inches to the right and four inches down from the top left of the page. This is intended to make it easier to print NWP on preprinted forms, where you will be measuring things with a ruler, and then entering those numbers in your program.

On the other hand, when you specify [TOPLEFT], even in NWP mode, printer.sys will generate the PCL escape sequence, which will place the curser at the top left corner of the logical page, the closest to the physical edge that is still within the bounds of the printable area.

=====Pictures*=====
It’s really nice to be able to print pictures. Hot off the press for the new NWP is the ability to print full color pictures straight from a file, using one simple escape sequence. This new and powerful escape sequence is: “[E]picture=’Height,Width,filename.jpg’”

NWP will print any file that you can display, including jpg, gif, bmp, ico, and many others. If you have a color printer, they will be printed in color.

There is again a simple substitute statement for the use of this new escape function.
  [PICTURE]*                    Becomes "[E]picture=". Use like [PICTURE]'2,2,logo.jpg'

I would suggest using a picture statement with a position statement. To print a logo in the top right of the page, you would say:

  PRINT #255: "[POSITION]'1,1'[PICTURE]'2,2,logo.jpg'"

...or...

  PRINT #255: "[PUSH][POSITION]'1,1'[PICTURE]'2,2,logo.jpg'[POP]"

...to restore the cursor to its original position. These statements will print the logo.jpg file 2 sq ", near the top right corner of the page.

You may also use the following parameterized substitution statements for printing pictures.
  [PIC(2,2,Logo.jpg)]*            Show a picture called Logo.jpg 2" by 2"
  [ISO PIC(XX,YY,IMGNAME)]*       Show a picture Isotropically
  [TILE PIC(XX,YY,IMGNAME)]*      Tile a picture

=====ESC Key=====
  [E]                             ESC Key (used for generating your own PCL code)

====Parameterized Substitution Statements (BR 4.17+)====

We have a new format for specifying printer substitute statements. The format works as follows:

Currently, you may specify the shading density with a substitute statement such as the following:

  PRINTER NWP [SET_SHADE20], "\E*c20G"

With this new syntax, you are able to specify a value to pass to the substitution statement which will be placed in the actual replacement text of the statement, as follows:

  PRINTER NWP [SET_SHADE(Percent)], "\E*cPercentG" ! Set to whatever you want

Now you may use a printing statement such as the following:

  PRINT #255: “[SET_SHADE(57)]”

And the correct codes would be generated to set the shading density to 57 percent.

=== * ===
In the first half of this document, the "*" indicates PCL ONLY commands. In the second half of this document, the "*" indicates NWP ONLY commands.
