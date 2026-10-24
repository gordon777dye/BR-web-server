---
title: ON_FKEY
file: ON_FKEY.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [4.20, OPTION, On Error, System Defaults]
---
As of `4.20` **On Fnkey** was renamed to **On FKey** `OPTION` 58 restores recognition of FNKEY if needed.

===Syntax===
 ON FKEY <integer> <action> 

`Image:Onfkey.png|500px`

===Parameters===
**Integer** is the value of FKEY referenced.

**Action** is GOTO <line-ref>, SYSTEM or IGNORE. 

For example:

 ON FKEY 11 GOTO MENU

See also `On Error`.

A few facts about ON FKEY.
*ON FKEY for each of 1-49 is set to ignore by default, as per `System Defaults`
*ON FKEY conditions are treated as error conditions and are checked for at the same time as Ctrl+A.
*If the system default for an FKEY (i.e. ignore) is overridden by an ON FKEY statement then when the FKEY interrupt is triggered, either by pressing the corresponding function key or some other method, then the specified ON action is performed.
*ON FKEY ## IGNORE can be specified to turn off special ON FKEY processing

Error `0001|1` can be triggered by the pressing that fkey.

===Example===
The following example demonstrates the use of ON FKEY. Keep in mind however, that when the operator presses an FKEY corresponding to ON FKEY, the program stops whatever it is doing and doesn't return, possibly losing data and other key information

 00030     print fields "2,2,c 100": "At any time you may select F8 for main menu, F9 to print the screen, or F10 for the help menu."
 00040     on fkey 8 goto MENU8 
 00050     on fkey 9 goto MENU9
 00060     on fkey 10 goto MENU10
 ...
 03120     stop
 03130  !
 03140  MENU8: chain MENU
 03150     stop
 03160  MENU9: printscreen
 03170     stop
 03180  MENU10: proc helpmenu
