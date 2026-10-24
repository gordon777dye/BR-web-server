---
title: Assertion_Failed
file: Assertion_Failed.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [br.exe, BRServer.dat, BRConfig.sys, BR.ini, BR.EXE BR!, WBServer.dat]
---
**Error:** Assertion Failed

**Description:** Assertion Failed

**Details:** **Assertion failures** and **GPF**s are usually caused by a corrupt `br.exe` or insufficient rights to something (often C:\windows\br.ini)
- BR does NOT have FULL permissions, to create the necessary files. 
- *`BRServer.dat`
- *br.ini #The `BRServer.dat` is created in the location that is pointed to in the `BRConfig.sys`, the `BR.ini` is created in the windows/system32 directory.

BR.ini used to only get created when you did a save font size position, if you don't do that it never gets created. BRServer.dat gets created every time you load `BR.EXE BR!`. In some versions of wb the previous `WBServer.dat` did not get deleted, and the new file never got made, and you would get the error too manyWBServer.dat found

Error Message:   Assertion Failed: t.sessionID, file wbs\Startup.c     

When attempting to run WB from a workstation on a network where the user had all the necessary network rights to the network WB directories but did not have rights to the WinNT directory on the local workstation which is where the   WB.ini   file resides.
