---
title: CONTINUE
file: CONTINUE.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [statement, RETURN, CONTINUE, 4273, ON error, Exit, RETRY, Error Conditions]
---
The **Continue** (CO) `statement` transfers control to the first executable statement following the one causing the most recent error. It can be used both in a program and in immediate mode (like a command).

===Comments and Examples===
Business Rules! provides two statements for transferring control at the end of an error processing routine; their function is analogous to the `RETURN` statement at the end of a subroutine. `CONTINUE` transfers control to the next statement after the one which caused the most recent error, and RETRY transfers control to the statement which caused the error.<br>
Any error condition which can cause an error transfer sets the line to be used by CONTINUE. When multiple statements are coded on a single line, execution continues with the next statement in the line.

In the example below, the PAGEOFLOW error condition is used to trigger a page break routine which moves the printer to a new page and calls a subroutine to print headings at the top of the new page. The CONTINUE statement in line 350 will transfer control back to line 180 at the end of the page break routine.

 00160 FOR I=1 TO 132
 00170 PRINT #255:I PAGEOFLOW TOPOFPAGE
 00180 NEXT I
 00190 STOP
  o
  o
 00320 TOPOFPAGE: ! routine for top of page
 00330 PRINT #255: NEWPAGE ! reset counter
 00340 GOSUB HEADINGS
 00350 CONTINUE

===Syntax===
 CONTINUE
`file:Continue.png|230px`

===Technical Considerations===
:1.) If no error has occurred (or if the only error was suppressed by an ON IGNORE statement), CONTINUE generates an error message.
:2.) If a second error occurs before CONTINUE is executed, the first return address is lost. (The exception to this rule is with error code `4273`, help topic not found.) It is the responsibility of the programmer to avoid the occurrence of subsequent errors. For this reason, some programmers use ON ERROR SYSTEM or ON error-cond SYSTEM at the start of their error-handling routines. Immediately before the CONTINUE statement, they end by calling a subroutine to reinstate the original error processing conditions.
:3.) For additional information on error processing, see the following statements: `ON error`, `Exit`, and `RETRY`. See also `Error Conditions`.
