---
title: FKey_Error_Cond
file: FKey_Error_Cond.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [ON FKEY, CMDKEY]
---
The FKEY error condition is available for use only with the ON error statement. It cannot be used at the end of a program line or in the Exit statement.

===Syntax===

`file:FKeyEC.png|300px`

===Parameters===
The "numeric expression" portion of the FKEY error condition is a numeric expression that evaluates to a number from 1 to 10. The value of the num-expr determines which function key, when pressed, will activate the ON statement's GOTO.

===Error Traps:===
During program processing (the status line says "RUN"), FKEY traps the pressing of a function key which is specified by the "num-expr" parameter.

Business Rules tests for the pressing of function keys before execution of each
line number. Multiple uses of the `ON FKEY` statement do not impact program
performance.

FKEY has no effect during other operation modes such as INPUT or SELECT (see the `CMDKEY` function for information about trapping function key selections during these modes). If FKEY is set to SYSTEM, the value of ERR will be set to 1. If FKEY is not set and the operator presses a function key during processing, it will be ignored. 

When FKEY is set to either SYSTEM or GOTO and the specified function key is pressed, the keyboard buffer will be cleared up to the pressing of that key in the same manner that pressing Ctrl-A clears the buffer.
