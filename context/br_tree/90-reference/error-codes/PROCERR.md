---
title: PROCERR
file: PROCERR.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [command, procedure file]
---
The **ProcErr (PROCE)** `command` tells BR how to respond when it finds an error in an active `procedure file`.

==Comments and Examples==

The ProcErr command has two options.
# Return
# Stop

===ProcErr Return===
PROCERR RETURN overrides error halts. When an error occurs in a procedure, the function ERR is set, but the procedure continues with the next line and no error message or beep occurs. In short, PROCERR RETURN says if an error occurs, return to the procedure and quietly keep going.

===ProcErr Stop===
The second option, PROCERR STOP, is the initial system *default*. PROCERR STOP reinstates error halts. When an error occurs, the procedure is interrupted, a beep occurs, and a message appears in the status line. In short, PROCERR STOP says if an error occurs, stop the procedure.

The following procedure illustrates common techniques for removing deleted records from a file called CUST.FIL on a multi-user system (although the procedure will also run unchanged on a single-user system). The procedure starts by turning off normal system error processing with a PROCERR RETURN command. PROCERR RETURN also sets ERR to zero. In the case of an error on the PROTECT command, ERR will be set to the value of the error code. PROCERR STOP is used next so that the procedure will stop if any other errors occur. If ERR is set by an error on the PROTECT command, the SKIP command will cause execution of the next five command lines to be skipped:

 PROCERR RETURN
 PROTECT CUST.FIL RESERVE
 PROCERR STOP
 SKIP 5 IF ERR
 COPY CUST.FIL TEMP[WSID] -D
 FREE CUST.FIL
 RENAME TEMP[WSID] CUST.FIL
 INDEX CUST.FIL CUST.KEY 1 6 REPLACE
 PROTECT CUST.FIL RELEASE
 RUN MENU

==Syntax==
 PROCERR {STOP|RETURN}
`Image:ProcErr.png`

==Defaults==
# When an error occurs in a procedure file and no PROCERR command has been specified, PROCERR STOP is the default.

==Parameters==

When an error occurs in a procedure and PROCERR is set to **RETURN**, BR continues executing the procedure without sending an error message. The ERR function is automatically set to the code that identifies the error, however, and LINE remains set to -1. The values of these variables can be tested during or after the execution of the procedure.

When an error occurs and PROCERR is set to **STOP**, BR interrupts the procedure and displays the error code on the status line. An explanation of the error can be accessed through the on-line help facility or in the manual. As with the RETURN variable, the value of ERR is set to the error code and LINE is set to -1.

When PROCERR REM is used with PROCERR RETURN, BR will not stop a load source if an error occurs. Instead, BR inserts the text **REM ERROR number** (where **number** represents the error number) at the beginning of the line. This takes up the first 15 characters in a line; thus, any line longer than 785 characters will lose the last few characters. Example:

 PROCERR RETURN
 PROCERR REM
 LOAD programname,source
 SAVE
