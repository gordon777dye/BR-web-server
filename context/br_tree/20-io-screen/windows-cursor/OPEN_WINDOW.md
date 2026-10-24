---
title: OPEN_WINDOW
file: OPEN_WINDOW.md
category: 20-io-screen
subcategory: 20-io-screen/windows-cursor
kind: statement
related: [Parent=None, Picture, statement, BRConfig.sys, Screen OpenDflt, NOMAXIMIZE, ROWS, SROW, COLS, SCOL]
---
See also: `Parent=None` and `Picture`

The **OPEN window** (OPE) `statement` specifies the characteristics for a window and activates the window for input/output. OPEN window can specify the following window characteristics: 
* Screen placement and dimensions
* Border type and attributes
* Attributes to be used for the text area of the window
* A caption to be displayed within the top border of the window

The ROWS= parameter may be used in place of either the SROW= or the EROW= parameter, but not both. Likewise, the COLS= parameter may be used in place of either the SCOL= or the ECOL= parameter, but not both. 

The following examples show some of the possibilities that are available using this syntax option. Each statement opens a 10 row by 10 column window in the upper left corner of the screen. (NOTE: ROWS= and COLS= parameters are shown in lowercase for emphasis; case makes no difference in actual syntax.)

 00010 OPEN #1:"rows=10,cols=10,EROW=10,ECOL=10",DISPLAY,OUTPUT
 00020 OPEN #1:"rows=10,SCOL=1,EROW=10,cols=10",DISPLAY,OUTPUT
 00030 OPEN #1:"rows=10,SCOL=1,EROW=10,ECOL=10",DISPLAY,OUTPUT
 00040 OPEN #1:"SROW=1,cols=10,rows=10,EROW=10",DISPLAY,OUTPUT
 00050 OPEN #1:"SROW=1,cols=10,EROW=10,ECOL=10",DISPLAY,OUTPUT
 00060 OPEN #1:"SROW=1,SCOL=1,rows=10,cols=10",DISPLAY,OUTPUT
 00070 OPEN #1:"SROW=1,SCOL=1,rows=10,ECOL=10",DISPLAY,OUTPUT
 00080 OPEN #1:"SROW=1,SCOL=1,EROW=10,cols=10",DISPLAY,OUTPUT

:1) All open windows other than the main BR console (window 0) are closed whenever a program ends.

:2) You can also specify window borders and captions in the OPEN WINDOW statement, for example:

 00200   open #2: "srow=2,scol=2,EROW=10,ECOL=30,border=b, caption=Happy Border",display,outin

The valid border styles are B (blank), S (single line) and D (double line). See "S Attribute" in the `BRConfig.sys` Specification section for more information. Try each of them to see their effects. 

:3) Window zero is the main BR operator console. You can also reopen it whenever desired. For example you may want to change the number or rows and columns. Since you cannot explicitly close it, reopening it implies closure of the pre-existing window 0. See `Screen OpenDflt` for the normal way to specify main window attributes.

===Comments and Examples===
OPEN #0 is reserved for reopening the BR main console. Windows 1-999 typically are sub-windows on window 0. Windows can also be opened separately from the main window. See `Parent=None` for more information.

When opening separate windows, 'NAME=window-name' indicates that BR is to save the position of the window at the time it is closed and restore it to that position when it is reopened, even across sessions. Replacement or overlaying windows can use the same window names to position and size themselves at whatever position and character size the user has changed it to. So once a window has been opened with a particular name, subsequent opens ignore ROW= and COL= and instead use the user positioned values. 

As a result window positioning and size priority is as follows:
:1. NAME= window-name
:2. (for window zero only) un-named save font size and position.
:3. SROW, SCOL, MAXIMIZE, `NOMAXIMIZE`, ABSOLUTE, RELATIVE, FONTSIZE

Another attribute (that doesn't get saved) is OVERRIDE, which indicates that the SROW and SCOL (etc) settings in the OPEN statement are to be used even if NAME= is also specified. When OVERRIDE is specified in OPENDFLT, it only applies to the first OPEN of window #0. In all other cases Name= trumps SROW etc settings.

All of the above specifications apply to Window zero except it cannot be 
opened RELATIVE.

"NOMAXIMIZE" also removes the maximize button from window #0 and parent=none windows.

"NO_TASK_BAR" suppresses the task bar icon. This feature 
is available on any window.

"MODAL" uses the same task bar icon as it's parent window. This ignores 
any clicks on its parent window.

===Input Across Multiple Windows===
As of 4.3, BR allows for input across multiple windows, as in the following example:

 00010  (R)INPUT FIELDS  #121: “10, 10, C 20, UH; 10, 12, PIC(##/##/##), UH;#124,10, 10, C 30, UH”: aaa$, bbb$, ccc$

This will input the first two fields on window #121 and the third field on window #124.  The ‘#window-number,’ prefix may appear in any row or col FIELDS specification and overrides the window number that follows the PRINT/INPUT/RINPUT keyword.

===Hot Windows===

As of 4.2, FKEY= may be specified in a window OPEN statement. This makes the  window hot, so a user can click anywhere in the window to tell the program that they want to switch focus. This characteristic is inheritable, but not to independent windows. In other words, assigning an FKEY value to a window automatically assigns the same FKEY value to it's child windows, unless another FKEY (or -1) is assigned to a child.

===Syntax===
 OPEN #<window number>: {"{`ROWS`|`SROW`} =<integer> {`COLS`|`SCOL`} =<integer> {`ROWS`|`EROW`} =<integer> {`COLS`|`ECOL`}=<integer> [, `Border Spec|BORDER`=<spec>] [, N=<`attributes`>] [ `FKEY=`<value>] [, `ABSOLUTE`|, `RELATIVE`] [, `CAPTION`=[{<|>}] <title>]"|<`string expression`>} , `DISPLAY`, {`Input Parameter|INPUT`|`OUTPUT`|`OUTIN`} [<`error condition`> <`line ref`>][,...]

ROWS and COLS can be specified with either SROW and SCOL or EROW and ECOL, but not both.
`Image:Openwindow.png|900px`

===Defaults===
:1.) No border.
:2.) N (normal).
:3.) ABSOLUTE for window zero, RELATIVE for child windows.
:4.) No caption.
:5.) Center caption.
:6.) Interrupt the program if an error occurs and ON is not active.

===Parameters===
"Wind-num" is a file number for the window being opened. It must be a numeric  expression or integer that equals a value from 1 to 999, inclusive. No other open file or open window may use the same value. Open windows do not count against the operating system limit on open files.

From this point, there are two possible paths through the OPEN window syntax. The top path will be described first.

The "SROW = row" parameter identifies the starting row for the window. The "row" portion of this parameter can be any integer within the size of the main BR window. If a border is specified for the window, it must be 1 more than the desired starting place, to account for a one row border. The value of "row" cannot exceed the value of the ending row.

The "SCOL = column" parameter identifies the starting column for the window. The "column" portion for this parameter can be any integer within the size of the main BR window. If a border is specified for the window, it must be 1 more than the desired starting place, to account for a one colomn border. The value of "column" cannot exceed the value of the ending column.

The "EROW = row" parameter identifies the ending row for the window. The "row" portion of this parameter can be any integer (unless a border is specified for the window -then the value must be one less than the desired ending row, to account for a one row border) It cannot precede the starting row value.

The "ECOL = column" parameter identifies the ending column for the window. The "column" portion of this parameter can be any integer (unless a border is specified for the window-then the value must be one less than the desired ending column, to account for a one column border) It cannot precede the starting column value.

The optional "ROWS=int" parameter can be used instead of either "SROW=row" or "EROW=row" to specify the number of rows desired (instead of a specific starting or ending row). 

The optional "COLS=int" parameter can be used instead of either "SCOL=col" or "ECOL=col" to specify the number of columns desired (instead of a specific starting or ending column).

Note that when opening a #0 window, only "ROWS=int" and "COLS=int" parameters are necessary, the others are not. See `Parent=None` for more information.

To specify a border, see the discussion on the supplemental BORDER=Spec syntax and parameters below.

Otherwise, continuing with the main syntax for OPEN window, the next available parameter is "N=attributes". This parameter identifies the attributes that are to affect the entire inner portion of the window. However, the attribute specified takes effect only after a PRINT NEWPAGE has been sent to the window. The B (blink) attribute is not available for this parameter.

"ABSOLUTE" and "RELATIVE" qualify SROW and SCOL to specify the position of a new independent window. RELATIVE (the default) indicates positioning relative to window zero (the main console), and ABSOLUTE indicates positioning relative to the screen. Using negative values    positions an independent window to the left of or above the main console. BR will attempt to honor the request keeping the new window viewable up to the maximum size of the screen. Window zero positioning is always ABSOLUTE. To position a window on a second monitor, specify a starting position to the right of the last position of the first monitor. 

The "CAPTION=" keyword is used to identify text that is to appear in the top border of the window. The default is flush left. (In earlier versions of BR, the text may have optionally been preceded by either a less-than (<) symbol for flush left text or a greater-than (>) symbol for flush right text). The "title" parameter represents the text that is to be displayed.

All of the parameters described above (excluding the wind-num parameter) comprise the file definition string. The alternative to coding these parameters directly in the OPEN window statement is to reference them with the "string expression" parameter found in the bottom path of the syntax diagram.

No matter which path you choose for providing the file definition, two of the remaining parameters in the syntax diagram must be included in your OPEN window statement. "DISPLAY" identifies the window file as a display file, and one of the "INPUT", "OUTPUT" or "OUTIN" parameters must be used to indicate how the window will be used.

The "error-cond line-ref" parameter allows for error processing. See `Error Conditions` for more information.

===Supplemental Syntax ("BORDER= spec")===

===Technical Considerations===
:1.) Relevant error conditions are: `ERROR`, `EXIT` and `IOERR`.
:2.) Open window files do not count against your operating system limit on open files.
:3.) Using `CONFIG` SCREEN N xx to change the normal attribute of a window will only take affect on windows that are opened after the CONFIG SCREEN specification is executed. This applies only to the N (normal) attribute.
:4.) Unix / Linux terminals - See `Terminal Consideration` for special considerations when using windows with Unix / Linux terminals.
:5.) SROW and SCOL are based on FONTSIZE.

====Sample Program====
 00100 ! Run This Program With The Br Main Screen Unmaximized
 00120 ! Run It More Than Once With The Br Main Screen In Different Positions
 00140 ! Repositioning The Named Windows Are Be Remembered From Run To Run.
 00160    open #1: "parent=none,RELATIVE,srow=0,scol=0, rows=10,cols=50,fontsize=20x10",display,output 
 00180    print #1, fields "1,1,c,s": "This PARENT=NONE window was positioned relative to window #0.  Press any key to continue"
 00200    let KSTAT$(1)
 00220    close #1: 
 00240    open #1: "parent=none,RELATIVE,srow=-4,scol=-4, rows=10,cols=50,fontsize=20x10",display,output 
 00260    print #1, fields "1,1,c,s": "This PARENT=NONE window was also positioned relative to window #0.  It uses a negative SROW and SCOL.  Press any key to continue"
 00280    let KSTAT$(1)
 00300    close #1: 
 00320    open #1: "parent=none,ABSOLUTE,srow=0,scol=0, rows=10,cols=50,fontsize=20x10",display,output 
 00340    print #1, fields "1,1,c,s": "This PARENT=NONE window was positioned on the absolute screen coordinates.  Press any key to continue"
 00360    let KSTAT$(1)
 00380    close #1: 
 00400    open #1: "parent=none,ABSOLUTE,srow=10,scol=10, rows=10,cols=50,fontsize=20x10",display,output 
 00420    print #1, fields "1,1,c,s": "This PARENT=NONE window was positioned on the absolute screen coordinates at 10,10.  Note that SROW and SCOL are now measured in character sizes based on the specified FONTSIZE.  Press any key to continue"
 00440    let KSTAT$(1)
 00460    close #1: 
 00480    open #1: "parent=none,ABSOLUTE,srow=0,scol=0, rows=10,cols=50,fontsize=20x10,name=AbsolutePositionExample_1",display,output 
 00500    print #1, fields "1,1,c,s": "This PARENT=NONE window was positioned on the absolute screen coordinates.  This window saves its screen size and position based on name=AbsolutePositionExample_1.  You can move this window around and it will open in the new place the next time you run this example.  Press any key to continue"
 00520    let KSTAT$(1)
 00540    close #1: 
 00560    open #1: "parent=none,RELATIVE,srow=0,scol=0, rows=10,cols=50,fontsize=20x10,name=RelativePositionExample_1",display,output 
 00580    print #1, fields "1,1,c,s": "This PARENT=NONE window was positioned relative to window #0.  This window saves its screen size and position based on name=RelativePositionExample_1.  It saves this information relative to window #0.  You can move this window around and it will open in the new place relative to window #0 the next time you run this example.  Note: This saved position is relative to window #0.  This means that if window #0 is moved, the saved position will move right along with it.  Press any key to continue"
 00600    let KSTAT$(1)
 00620    close #1: 
 00640    print fields "1,1,c,,B1001": "This button cannot be clicked while there is a modal window open"
 00660    open #1: "parent=none, RELATIVE, srow=10, scol=10, rows=10, cols=50, fontsize=20x10, MODAL", display, output 
 00680    print #1, fields "1,1,c,s": "This window was opened MODAL.  Note that you cannot interact with window #0 while it is opened.  Also note that it does not have a task bar icon.  Press Ok to continue"
 00700    print #1, fields "6, 22, C,,B1001": "Ok"
 00720    do WHILE (FKEY <> 1001)
 00740       let KSTAT$(1)
 00760    loop 
 00780    close #1: 
 00800    print NEWPAGE
 00820    open #1: "parent=none,RELATIVE,srow=0,scol=0, rows=10,cols=50,fontsize=20x10, NO_TASK_BAR", display, output 
 00840    print #1, fields "1,1,c,s": "This PARENT=NONE window does not have a task bar item.  Press any key to continue"
 00860    let KSTAT$(1)
 00880    close #1:
