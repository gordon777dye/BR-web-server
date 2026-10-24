---
title: CMDKEY
file: CMDKEY.md
category: 20-io-screen
subcategory: 20-io-screen/windows-cursor
kind: statement
related: [internal function, FKey, KSTAT$, CURFLD, Option, INPUT, LINPUT, RINPUT]
---
The **CMDKEY** `internal function` returns a value to identify the last command key (function key) used to terminate keyboard input, or returns 0 if <ENTER> was the last key pressed. **Note** that it is futile to try to test whether <ENTER>  was pressed, because non-command keys also return 0 when pressed. At the start of the program, CMDKEY is initialized to -1.

See also `FKey` - a newer more powerful version of CMDKEY.

The CMDKEY function now accepts a value. This is useful for `KSTAT$` processing and for setting expected CMDKEY inputs without operator intervention. In the following sample syntax, CMDKEY is assigned the value of x:

 00010 LET CMDKEY(x)

CMDKEY now returns values of 90 and 91 for the PgUp and PgDn keys during program input. See "PgUp and PgDn" in the Keys section for more information.

===Comments and Examples===

 09000 START: PRINT NEWPAGE
 09010 PRINT "The record you tried to read is"
 09020 PRINT "in use at another workstation."
 09030 PRINT "*** Press F9 to try again, or"
 09040 PRINT "*** <CR> to select another record"
 09050 LINPUT DUMMY$
 09060 IF CMDKEY = 9 THEN RETRY
 09070 GOTO START

Line 9060 tests for the operator pressing the F9 key in response to the locked record message presented in the text above.

One more example:

 00010 Start: print "Press a CMDKEY to see its value, or press 1 to quit"
 00020 linput a$
 00030 print CMDKEY
 00040 if a$ <> "1" then goto Start

For other examples, see `CURFLD`

===CMDKEY Values===

{| border="1"
!FKey value
!Cause
!Additional
|-
|1
|F1
|-
|2
|F2
|-
|3
|F3
|-
|4
|F4
|-
|5
|F5
|-
|6
|F6
|-
|7
|F7
|-
|8
|F8
|-
|9
|F9
|-
|10
|F10
|-
|11
|F11 or Shift+F1
|-
|12
|F12 or Shift+F2
|-
|13
|Shift+F3
|-
|14
|Shift+F4
|-
|15
|Shift+F5
|-
|16
|Shift+F6 or Alt+Q 
|-
|17
|Shift+F7 or Alt+W 
|-
|18
|Shift+F8 or Alt+E 
|-
|19
|Shift+F9 or Alt+R
|-
|20
|Shift+F10 or Alt+T 
|-
|21
|Ctrl+F1 or Alt+Y or SHIFT+F11
|-
|22
|Ctrl+F2 or Alt+U or SHIFT+F12 
|-
|23
|Ctrl+F3 or Alt+I 
|-
|24
|Ctrl+F4 or Alt+O
|-
|25
|Ctrl+F5 or Alt+P 
|-
|26
|Ctrl+F6
|-
|27
|Ctrl+F7
|-
|28
|Ctrl+F8
|-
|29
|Ctrl+F9
|-
|30
|Ctrl+F10 or Alt+A 
|*
|-
|31
|Ctrl+F11 or Alt+S 
|*
|-
|32
|Ctrl+F12 or Alt+D 
|*
|-
|33
|Alt+F 
|*
|-
|34
|Alt+G
|*
|-
|35
|Alt+H 
|*
|-
|36
|-
|37
|Alt+K 
|*
|-
|38
|Alt+L 
|*
|-
|39
|-
|40
|-
|41
|-
|44
|Alt+Z 
|*
|-
|45
|Alt+X 
|*
|-
|46
|Alt+C
|*
|-
|47
|Alt+V 
|*
|-
|48
|Alt+B 
|*
|-
|49
|Alt+N
|*
|-
|50
|Alt+M
|*
|-
|90
|page up
|-
|91
|page down
|-
|92
|tab change
|-
|93
|Application Exit, Alt+F4 or Big X
|An `Option` exist to reassign this to a different value
|-
|98
|Drop Down Menu
|align="right"|??
|-
|99
|Escape or Alt+J
|*
|}

===Technical Considerations===

# `INPUT`, `LINPUT` or `RINPUT` statements using the keyboard as input, or any INPUT FIELDS or INPUT SELECT statement will set the CmdKey variable.
# The Shift-F1 through Shift-F10 key combinations set CmdKey the values from 11 to 20.
