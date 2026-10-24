---
title: FnSnap__Screen_Processing
file: FnSnap__Screen_Processing.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
==Buttons, messages and dialogs==
===FNBUTTON - Add button on the button bar===

Creates a button on the button bar.  Buttons are created left to right and can be removed with FNCLRBUTTON

 FNBUTTON(BUTTON_TEXT$,FK;BTN)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**BUTTON_TEXT$**||Text to display on button.  Must be less than 10 characters
|-valign="top"
|width="10%"|**FK**||Function key value to return when the button is pressed
|-valign="top"
|width="10%"|**BTN**||Button number if an existing button is to be changed.  If this parameter is omitted the next button position will be used.
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNCHECK - in connection with a radio dot or check box returns a 1 if checked===

Used to process the elements of a radio dot list or check box is to determine wether the element has been checked (true) or not (false)

  FNCHECK(L$*100)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**L$ **||The label description being processed for an element of a radio list or check b ox list
|-valign="top"
|}
<br>
;Comments:<br>
This function is intended to be used by other functions see for example FNOPTIONS and FNOPTIONS$

===FNCHECK$ - places or strips ^ from an element===

Based on the results of FNCHECK or a default parameter this function will add or remove the ^ from a description that indicates if it has been checked

Returns the label modified to either contain or be free of a leading ^.
 FNCHECK$*100(L$*100,L)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**L$ **||The label description to be modified if L is true
|-valign="top"
|width="10%"|**L **||A flag indicating whether the ^ is to be appended to the front of a label, or stripped from it
|-valign="top"
|}
<br>
;Comments:<br>
Used as a part of FNOPTIONS and FNOPTIONS$

===FNCLRBUTTON - removes a button from the button bar===

Removes a button from the button bar if it was created using FNBUTTON

 FNCLRBUTTON(;BTN)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**BTN**||The number of the button to be cleared.  If blank the last, highest number, button will be cleared. If equal to 99 all buttons will be cleared.
|-valign="top"
|}
<br>
;Comments:<br>
Use in connection with FNBUTTON to display and remove buttons left to right on the button bar.

===FNDIALOG$*40 - Display dialog box and return selected text===

Displays a dialog box with up to three options and specifiable text.  See also FNDLG

 FNDIALOG$*40(SROW$,SCOL$,DBWIDTH,TXTSTR$*900,OPT1$*40,OPT2$*40,OPT3$*40,REMOVE,DFLTOPT,DISPANYKEY,KEYWAIT) !:

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

Text does not align very well in the box when using proportional fonts.  This function can be called from FNDLG that uses an unformatted BR file to supply text and button labels.  Both functions have been updated to utilize the external utility from David Blankenship.

See also FNWAITWIN for a very useful alternative.

===FNDLG - Display a dialog box from data in a file===

Creates a dialog box from a DAT file prepared by DIALOGMN.BR

 FNDLG(DIALOG_DAT,DLNR;DISPANYKEY,KEYWAIT,SUFFIX$*300)

Functions used
{|
|-valign="top"
|width="10%"|**FNDIALOG
|-valign="top"
|}
<br>
;Variables:
{|
|-valign="top"
|width="10%"|**DIALOG_DAT**||
|-valign="top"
|width="10%"|**DLNR**||
|-valign="top"
|width="10%"|**DISPANYKEY**||
|-valign="top"
|width="10%"|**KEYWAIT**||
|-valign="top"
|width="10%"|**SUFFIX$**||
|-valign="top"
|}
<br>
;Comments:

This is a carry over from earlier versions and does not align proportional text very well. If possible use MSGBOX instead.

The function has been updated to use the message box utility from David Blankenship if RADIOCHK.exe is in the VOL002 directory

With version 4.2 the function FNWAITWIN and rel;ated functions FNWAITMSG and FNWAITBAR are much more flexible and provde a Windows look message box with custom buttons, a progress bar and optionsl message flashing across the wait window as processing progresses.

===FNHELP - open a tip box associated with a screen using a text file===

Searches a specified text file for an anchor point, then displays a record after that point specified by HFLD.  Used for displaying pop up help windows based on the input field where the cursor is located

[PICT(PICS\SNAP0007.ptf)]

 FNHELP(HPATH$*60,HFILE$*20,HBASE$,HFLD,HROW,HCOL;HTITLE$*80)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**HPATH$ **||Path where the help file is located
|-valign="top"
|width="10%"|**HFILE$ **||File name within HPATH$ for the help file
|-valign="top"
|width="10%"|**HFLD **||Field number, usually set by CURFLD except in GRIDs it should be set by CURCOL.
|-valign="top"
|width="10%"|**HROW **||Current row position of cursor, used to help in the positioning of the help window.  Usually set by CURROW
|-valign="top"
|width="10%"|**HCOL **||Current column of cursor, used to help in the positioning of the help window.  Usually set by CURCOL
|-valign="top"
|width="10%"|**HTITLE$ '''||An optional title to appear in the bar at the top of the help window.
|-valign="top"
|}
<br>
;Comments:<br>
Very flexible and easy to implement help system.  I uses David Blankenship's HELPTIPS.exe utility.

===FNHELPTIP - uses David Blankenship utility to display a help record===

Displays a record from a text file in a pop up window.  Used in the BR system by the ERRORS routine to display the description of an error number.

 FNHELPTIP(PROGPATH$*100,TEXTFILE$*50,TITLE$*50,RECORD,HROW,HCOL;NO_WAIT)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**PROGPATH$ **||Path where text file is located.
|-valign="top"
|width="10%"|**TEXTFILE$ **||Name of text file within the specified path
|-valign="top"
|width="10%"|**TITLE$ **||Name to be displayed at the top of the pop up window
|-valign="top"
|width="10%"|**RECORD **||The record number within the text file to display as the text of the message.
|-valign="top"
|width="10%"|**HROW **||A positioning variable generally set by CURROW
|-valign="top"
|width="10%"|**HCOL **||A positioning variable generally set by CURCOL
|-valign="top"
|width="10%"|**NO_WAIT **||Ignored
|-valign="top"
|}
<br>
;Comments:<br>
If HROW and HCOL are zero then the window id positioned in the center of the screen.

===FNOK - Pop-up "OK" question===

 FNOK

Description|<br>
Displays a dialog box with OK yes or NO. If yes is returned FNOK is true else it is false

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|'''
|-valign="top"
|}
<br>
;Comments:<br>
MSGBOX is probably a better option with current programs

===FNOPTIONS - creates a radio dot selection pop up===

Displays a pop up radio dot selection window.  If David Blankenship's utility RADIOCHEK.exe is present that will be used.  If not present then a BR generated selection window will be generated.

[PICT(PICS\SNAP0005.ptf)]
 FNOPTIONS(MAT O$;DEFAULT,TITLE$*100,MESSAGE$*1000,WAITTIME,SROW,SCOL)

;Functions used:<br>
FNRADIOCHK

;Variables:
{|
|-valign="top"
|width="10%"|**Mat O$ **||Matrix containing the descriptions for each line in the list
|-valign="top"
|width="10%"|**DEFAULT **||A number indicating which radio dot item should carry the dot when the box is displayed
|-valign="top"
|width="10%"|**TITLE$ **||A title to appear across the top of the list box.
|-valign="top"
|width="10%"|**MESSAGE$ **||A message to appear in a separate part of the dialog box explaining the choices if appropriate.
|-valign="top"
|width="10%"|**WAITTIME **||Number of seconds that the list should be displayed before accepting whatever is checked and continuing.
|-valign="top"
|width="10%"|**SROW **||Positioning parameter generally set by CURROW
|-valign="top"
|width="10%"|**SCOL **||Positioning parameter generally set by CURCOL
|-valign="top"
|}
<br>
;Comments:

===FNOPTIONS$ - creates a check box selection pop up===

Similar to FNOPTIONS, but this function displays the information in the form of a multiple selection check box list.

[PICT(PICS\SNAP0006.ptf)]

 FNOPTIONS$*100(MAT O$;DEFAULT$*100,TITLE$*100,MESSAGE$*1000,WAITTIME,NONE)

;Functions used:<br>
FNRADIOCHK

;Variables:
{|
|-valign="top"
|width="10%"|**DEFAULT **||A number indicating which radio dot item should carry the dot when the box is displayed
|-valign="top"
|width="10%"|**TITLE$ **||A title to appear across the top of the list box.
|-valign="top"
|width="10%"|**MESSAGE$ **||A message to appear in a separate part of the dialog box explaining the choices if appropriate.
|-valign="top"
|width="10%"|**WAITTIME **||Number of seconds that the list should be displayed before accepting whatever is checked and continuing.
|-valign="top"
|width="10%"|**NONE **||A flag that will allow no items to be selected, otherwise the check list may not be exited without at least one selection being made.Positioning parameter generally set by CURROW
|-valign="top"
|}
<br>
;Comments:

===FNPFKEYLINE - Creates a hot field string of function key options===

See also FNWINBUTTONS for 4.17+

Prints a function key message line in an open window or child window at the row specified. Function keys displayed are hot and return the Fkey value. Fkey references can be hot text or optionally buttons.

[PICT(PICS\SNAP0009.ptf)]

 FNPFKEYLINE(ROW,TXT$*80;FKWIN)

Functions used

;Variables:
{|
|-valign="top"
|width="10%"|**ROW**||The row number of the window on which the line should be displayed. Negative number indicate that many rows UP from the bottom of the window. Zero "0" indicates the very bottom of the window. All messages will be right justified within the window.
|-valign="top"
|width="10%"|**TXT$**||Text to be displayed. Function keys should be designated with a leading carat ^ and trailing double space such as "^Esc  End"
|-valign="top"
|width="10%"|**FKWIN**||Window number in which the line should be displayed
|-valign="top"
|}
<br>
;Comments:<br>
Valid function keys are numbers beginning with "^F" such a ^F9, or abbreviations for keys including ^PgUp ^PgDn ^Esc and ^Enter.  These are not case sensitive.
See also FNWINBUTTONS for a GUI based alternative.

===FNPFKEY - Prints a function key message===

 FNPFKEY(R,C,F$,TXT$*78) !:

Description|<br>
Prints a function key message on window zero

Functions used

;Variables:
{|
|-valign="top"
|width="10%"|**R**||Row number
|-valign="top"
|width="10%"|**C**||Column number
|-valign="top"
|width="10%"|**F$**||Function key to be displayed
|-valign="top"
|width="10%"|**TXT$**||Message to be displayed next to the function key
|-valign="top"
|}
<br>
;Comments:<br>
Displays only one function key message at the row and column of window #0 specified.  FNPFKEYLINE is more flexible and recommended.

Effective with GUI mode and release 4.17 FNWINBUTTONS and FNPICBUTTONS are much better options.

===FNRADIOCHK$ - display a radio/checkbox with a set of options===

Used by FNOPTONS and FNOPTIONS$ and FNDLG to display radio dot list, check box list, or a dialog box.  Makes use of David Blankenship's RADIOCHK.exe utility.

 FNRADIOCHK$*100(CAPTION$*80,INFILE$*60,LEFT,TOP,ALLOW,DEFAULT$*100,TYPE$,LOCATE,NOCOLS,COLWIDTH,WAITTIME;TEXTSTRING$*2400)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**CAPTION$ **||Title for the top bar
|-valign="top"
|width="10%"|**INFILE$ **||File name to be processed
|-valign="top"
|width="10%"|**LEFT **||Position form left of screen to display in pixels
|-valign="top"
|width="10%"|**TOP **||Position from the top of the screen in pixels
|-valign="top"
|width="10%"|**ALLOW **||allows no responses if true, requires at least one if false
|-valign="top"
|width="10%"|**DEFAULT$ **||A string of 0 and 1 where 0 is not checked and 1 is checked
|-valign="top"
|width="10%"|**TYPE$ **||R for Radio C for Check box
|-valign="top"
|width="10%"|**LOCATE **||Record number in file to use as data for a dialog box
|-valign="top"
|width="10%"|**NOCOLS **||Number of columns to display
|-valign="top"
|width="10%"|**COLWIDTH **||Width of columns or buttons.  If not provided the spacing will be automatic based on the length of text provided
|-valign="top"
|width="10%"|**WAITTIME$ **||Number of seconds to wait before returning the default answer.
|-valign="top"
|width="10%"|**TEXTSTRING$ **||Text to display in a dialog box if not using text from a file.
|-valign="top"
|}
<br>
;Comments:

===FNRADNUM - Return the option selected in a radio dot list===

 FNRADNUM(MAT V$)

Description|<br>
Function determines which in a group of radio buttons was selected and returns the element number

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNTIMEOUT - Display timeout message===

 FNTIMEOUT(;SECONDS)

Description|<br>
Displays a message that input has timed out and waits for a keystroke to reactivate the program.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNWINBUTTONS - print one or more buttons on a screen in a designated window===

Similar to and a replacement of FNPFKEYLINE.  Prints one or more buttons, right justified in a designated window either BROWs down from the top of the window if BROPW is positive of BROWS up from the bottom of the window if BROW is zero or negative.

[PICT(PICS\SNAP0002.ptf)]

 DEF LIBRARY FNWINBUTTONS(BROW,BTEXT$*100;BWIN,CENTER,FONT$)

;Functions used:<br>
FNWINROWCOL<br>
;Variables:
{|
|-valign="top"
|width="10%"|**BROW **||The row number within a window on which to place the buttons.  If 0 or negative the row is up from the bottom of the window, positive is down from the top.
|-valign="top"
|width="10%"|**BTEXT$ **||The text to display within the buttons. Each button is designated with a ^followed by FX: where X is the fkey value to be returned when the button is pushed.  FX can also be PGUP, PGDN or ESC.  The^FX: is followed by the text to appear within each button.  Al buttons are dimensioned to the longest string provided for any button.
|-valign="top"
|width="10%"|**BWIN **||The window number of the window within which the buttons should appear.
|-valign="top"
|width="10%"|**CENTER **||The default is zero (0) which right aligns the buttons on the right hand border of the window. To center the buttons horizontally in the window enter one (1) in this element.
|-valign="top"
|width="10%"|**FONT$ **||If this element is blank the default BUTTONS font will be used for the WINBUTTONS. Entering an alternative font can allow wingdings or directional arrows if the font allows it.  An example would be specifying TERMINAL on a Windows machine and then usinrt chr$(16) and chr$(17) next to the word Right or Left.
|-valign="top"
|}
<br>
;Comments:<br>
Can only be used in GUI ON mode

==String Manipulation==
===FNDECRYPT$ - Decrypt FNENCRYPT$===

Undoes what FNENCRYPT$ does

 FNDECRYPT$(PW$)

Functions used

;Variables:
{|
|-valign="top"
|width="10%"|**PW$**||The encrypted password from FNENCRYPT$.  This is usually a stored value to be compared with an entered value
|-valign="top"
|}
<br>
;Comments:<br>
This is a simple encryption routine only meant to hide a value from a casual observer, not a dedicated hacker. A more robust encryption routine is available with George Tisdale's WORKMENU.br menuing system.

===FNENCRYPT$ - Simple encryption===

 FNENCRYPT$(PW$) !:

Description|<br>
Simple encryption routine to ward off SNOOPS, NOT serious hackers

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:<br>
This is a simple encryption routine only meant to hide a value from a casual observer, not a dedicated hacker.

===FNFKEY - Converts an FKEY value greater than 1000===

Returns a function key value.  If the value would be greater than 1000 then only the right tree places are used to determine the number.  Useful in converting button FKEYs to hot text fkeys

 FNFKEY(AKEY)

Functions used

;Variables:
{|
|-valign="top"
|width="10%"|**AKEY**||An FKEY value to be reduced by 1000 and returned as the value of FKEY.  If AKEY is less than 1000 the value of AKEY will be returned
|-valign="top"
|}
<br>
;Comments:

Use in conjunction with FNPFKEYLINE

===FNNUM$ - Convert number to string===

 FNNUM$(NAMT,DCML,LNGTH) !:

Description|<br>
Converts a number to a character string with fixed decimal places.  CNVRT$ is a better option.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPHONE$ - Convert number to (###) ###-####===

Formats a 10 digit number into a telephone number formatted string

 FNPHONE$(X)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**X**||Numeric telephone number including a leading "1"
|-valign="top"
|}
<br>
;Comments:

===FNPROPER$*60 - Convert to Proper Case===

Converts a string into an initial capital title or name case

 FNPROPER$*60(A_IN$*60) !:

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**A_IN$**||String that is to be converted to initial capitals
|-valign="top"
|}
<br>
;Comments:<br>
The function uses a lot of SREP$ statements, consequently the string passed should be short enough to not cause a string overflow. About 500 characters is a reasonable limit.

==Other==
===FNAUTO - 1 if last field exit was automatic===

Returns a 1 (true) if the last field was exited with an automatic exit Attribute E or X LASTFIELD is the field # that was current

 FNAUTO(LASTFLD) !:

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**NONE
|-valign="top"
|}
<br>
;Comments:

===FNCLKBUF - Clear keyboard buffer===

Clears the keyboard buffer

 FNCLKBUF ! Clear the keyboard buffer

;Functions used:<br>
None

;Variables:
{|
|-valign="top"
|width="10%"|**None
|-valign="top"
|}
<br>
;Comments:

===FNERRTRAP - Trapped Error Processing===

Red Screen error trapping routine. Displays error, program line and number to call.  Also logs the error to a log file by workstation and creates an email message

 FNERRTRAP(EPROG$*50,ELINE,EERR,ECOUNT,EVARIABLE$,&ECURFLD,EMENU$)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**EPROG$**||Program name where the error was generated
|-valign="top"
|width="10%"|**ELINE**||Line number where the error occurred
|-valign="top"
|width="10%"|**EERR**||Error number that occurred
|-valign="top"
|width="10%"|**ECOUNT**||Variable count if appropriate to the error
|-valign="top"
|width="10%"|**EVARIABLE$**||Name of the variable, if appropriate where the error occurred
|-valign="top"
|width="10%"|**ECURFLD**||Current field where the error occurred if in full screen processing
|-valign="top"
|width="10%"|**EMENU$ **||The menu to which the program should return if the error can not be resolved
|-valign="top"
|width="10%"|**EMENUSEQ$ **||The menu Sequence to which the program should return if the error can not be resolved.
|-valign="top"
|}
<br>
;Comments:

Requires FNEMAILFILE and EmailBlaster or EmailMonitor

===FNINIT - Initialize variables in FNSNAP Library===

Initiates the variables for the FNSNAP library.  Be careful not to use more than once in a program

 FNINIT(;SYSDIR$,SYS$)

Functions used

;Variables:
{|
|-valign="top"
|width="10%"|**NONE
|-valign="top"
|}
<br>
;Comments:<br>
Initializes variables for the older FNSNAP tools.  If run  in the middle of a program the variables will be reset to the initial values and may cause problems.  Most new functions being written should NOT use this function.

===FNPRINTSCREEN - stuff the keyboard to generate a print screen===

Programmatically controls the keyboard to do the equivalent of Ctrl-P to issue a print screen

 FNPRINTSCREEN

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**None
|-valign="top"
|}
<br>
;Comments:

===FNZERO - set to number if zero===

 FNZERO(V,DV) ! SET Variable equal to the Default Variable if zero !:

Description|

==Screen input and display==
===FNMOD - returns the column number of a cell in a grid===

Replaced by CURCOL in 4.17.  Returns the column number of the current cell

 FNMOD(CEL,COLS)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**CEL **||The cell number where the cursor is located
|-valign="top"
|width="10%"|**COLS **||The number of columns in the grid
|-valign="top"
|}
<br>
;Comments:

===FNPARSERES - returns screen resolution and BR window size for a session===

Converts

 FNPARSERES(W$,MAT SCRNRES,MAT WINRES,MAT CONRES)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**W$ **||The workstation ID being queried
|-valign="top"
|width="10%"|**MAT SCRNRES **||Two element array of current terminal rows and columns in pixels
|-valign="top"
|width="10%"|**MAT WINRES **||Five element matrix 1    0 is maximized ("M-") 1 is windowed ("A-")2    rows in pixels of window  3    columns in pixels of window 4    row position of upper left corner in pixels of window  5    columns position of upper left corner in pixels of window
|-valign="top"
|width="10%"|**MAT CONRES **||Five element matrix 1    0 is maximized ("M-") 1 is windowed ("A-")2    rows in pixels of window3    columns in pixels of window 4    row position of upper left corner in pixels of window5    columns position of upper left corner in pixels of window
|-valign="top"
|}
<br>
;Comments:<br>
Uses Steve Koger's RESOLUTION.exe utility

===FNPROGRESS - Progress bar===

 FNPROGRESS(&PCT_WINDEV,PCT_TOTAL,PCT_DONE;SR$,CAPTION$*55)

Description|<br>
Displays a progress bar that expands based on numbers passed to the function

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNSCREEN - 24 x 80 screen display for screen painter===

 FNSCREEN(SCRNO;SCREENFILE,MAT SCRATR$,MAT SCREEN$,MAT INWRK$,MAT INFLDA$,MAT INWRKH$,NOPAINT) ! Retrieve and display screen

Description|<br>
Displays a generated screen in the full screen window 0.  Screen was created using SCREENMN in a 23x80 format.

This function has been significantly changed by NEWSCREEN.dll

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNTEXTBOX - creates a text box with word wrap===

 Displays and allows input from a windows text box with text

 FNTEXTBOX$*4000(&TEXTWIN,SROW,SCOL,ROWS,COLS,TLEN,PARENT,TEXT$*4000;BORDER,TKEY$)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**TEXTWIN **||
|-valign="top"
|width="10%"|**SROW **||Starting row within the parent window where the upper left corner should appear
|-valign="top"
|width="10%"|**SCOL **||Starting column number within the parent window where the upper left corner should appear
|-valign="top"
|width="10%"|**ROWS **||Number of rows the text box should cover
|-valign="top"
|width="10%"|**COLS **||Number of Columns the text box should cover
|-valign="top"
|width="10%"|**TLEN **||Allowable length of the text
|-valign="top"
|width="10%"|**PARENT **||Parent window number
|-valign="top"
|width="10%"|**TEXT$ **||Text to display.  Modified text will be returned as the value of the function
|-valign="top"
|width="10%"|**BORDER **||Zero for no border or any other number to create a single line border
|-valign="top"
|width="10%"|**TKEY$ **||Function key to return if the window is to be marked as hot
|-valign="top"
|}
<br>
;Comments:

===FNWINSCRN - paints a screen in a window===

 FNWINSCRN(SFIL,SCRNO,WINNO,WINLIN,WINLEN,MAT SINFLDA$,MATSHELP$;DISPLAY) !:

Description|<br>
Displays a generated screen in an open child window of specified size.  The generated screen was created using SCREENMN

This function has been significantly changed by NEWSCRN.DLL

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNWINROWCOL - in GUI mode returns rows and columns of a window===

Must be in GUI ON mode to use this function.  Returns the number of rows and number of columns in the specified window.  the values returned are actually one shorter than the actual size of the window.

 FNWINROWCOL(WINNO,&WROWS,&WCOLS)

;Functions used:<br>
FNWINSIZE

;Variables:
{|
|-valign="top"
|width="10%"|**WINNO **||Window number for which information is requested
|-valign="top"
|width="10%"|**WROWS **||Number of rows less one of the requested window
|-valign="top"
|width="10%"|**WCOLS **||Number of columns less on of the requested window
|-valign="top"
|}
<br>
;Comments:

===FNWINSIZE - in GUI mode creates arrays holding all window sizes===

Returns arrays carrying dimensions for all open windows

 FNWINSIZE(MAT S_WINNO,MAT S_SROW,MAT S_SCOL,MAT S_EROW,MAT S_ECOL,MAT S_ROWS,MAT S_COLS,MAT S_PARENT)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**MAT S_WINNO **||Array is dynamically populated with window number information
|-valign="top"
|width="10%"|**MAT S_SROW **||Array is dynamically populated with starting row number
|-valign="top"
|width="10%"|**MAT S_SCOL **||Array is dynamically populated with starting column number
|-valign="top"
|width="10%"|**MAT S_EROW **||Array is dynamically populated with ending row number
|-valign="top"
|width="10%"|**MAT S_ECOL **||Array is dynamically populated with ending column number
|-valign="top"
|width="10%"|**MAT S_ROWS **||Array is dynamically populated with the number of rows in the window
|-valign="top"
|width="10%"|**MAT S_COLS **||Array is dynamically populated with the number of columns in the window
|-valign="top"
|width="10%"|**MAT S_PARENT '''||Array is dynamically populated with the number of the parent window
|-valign="top"
|}
<br>
;Comments:<br>
this is the working function for FNWINROWCOL
