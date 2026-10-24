---
title: EXIT
file: EXIT.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [statement, Error Conditions, Exit(disambiguation), error condition, line ref, CONV, DUPREC, EOF, ERROR, HELP]
---
The **Exit** (EXI) `statement` provides a short-cut method for coding several repetitions of the "error-cond line-ref" parameter into a single statement. In order for a transfer to occur, specific conditions must be referenced by an Exit error condition in the statement generating the error, and there must not be a "error-cond line-ref" parameter coded for that specific error in that statement. See `Error Conditions` for additional information about each individual error condition.

See also `Exit(disambiguation)`.

===Comments and Examples===

It is important to understand the difference between the `EXIT Error Cond|Exit error condition` and the Exit statement, which work together to provide Exit error processing.

Like other error conditions, the Exit error condition is used at the end of a program line to trap errors. Its line-ref points to a line that contains an Exit statement, which in turn contains one or more error condition/line-ref pairs.

The Exit statement allows you to group several error condition instructions together in a single statement, thus saving programming time.

When an error occurs and Business Rules! encounters the Exit error condition, it immediately checks the associated Exit statement for an error condition that will address the type of error that occurred. If the appropriate error condition has been included in the Exit statement, Business Rules transfers control to the indicated line-ref, which should contain an error-handling routine. Use of the Exit statement allows programmers to set up a general action plan for error conditions. Once this is accomplished, only the exceptions (and the Exit line-ref) need to be coded on specific lines.

There can be more than one Exit statement in a program. Exit statements are non-executable and may be placed anywhere in the program without altering program execution.

The following code handles potential errors in a read statement. 

 00290  read #1, using RECFORM: Mat Answers$,Shipping$,Mat Ordered EXIT 600
 ...
 00600  EXIT EOF DONEREADING, LOCKED L895
 ...
 00895  L895: Print fields "20,5,c 25":"File locked, retry?" : Goto RETRY2
 01000  DONEREADING: ! We're done reading, go to the next part, print them on the list

===Syntax===
 EXIT <`error condition` `line ref`>[,...]
`File:Exit.png|400px`

===Parameters===
The "error condition" parameter is one of the following error conditions: `CONV`, `DUPREC`, `EOF`, `ERROR`, `HELP`, `IOERR`, `Locked Error Cond|LOCKED`, `NOKEY`, `NOREC`, `PAGEOFLOW`, `SOFLOW`, or `ZDIV`. (See individual pages for more information about each one.)

"Line ref" is the line number or label to which Business Rules should pass execution if the specified error occurs.

===Technical Considerations===
:1.) The Exit error condition can be coded with all I/O statements, including `CLOSE`, `DELETE`, `INPUT`, `INPUT FIELDS`, `LINPUT`, `OPEN`, `PRINT`, `PRINT FIELDS`, `READ` file, `REREAD`, `RESTORE` file pointer, `REWRITE`, `RINPUT`, `RINPUT FIELDS`, and `WRITE`.
:2.) Other statements, which allow coding of Exit and other error conditions, include `FOR`, `LET`, `ON GOSUB`, `ON GOTO`, and `READ` data.
:3.) Error-handling routines often end with `RETRY` or `CONTINUE` statements.
:4.) There can be more than one Exit statement in a program.
:5.) The Exit statement must appear on its own line. Multiple-statement processing is not allowed with the Exit statement.
:6.) Exit statements are non-executable and may be placed anywhere in a program without altering program execution.
:7.) It is permissible (although confusing) to have more than one Exit error condition coded at the end of a statement line. All error conditions will be evaluated in the order they occur.
:8.) If Exit is coded with other error conditions on the same line, Exit should be coded last. This is because the error conditions at the end of a statement are evaluated in the order they occur; thus, for a specific code to override the general provisions of the Exit group, the specific must occur first.
:9.) If an error causes a transfer of control, the functions `ERR` and `LINE` will be set and may be used in the error-handling routine.
:10.) See the `ON error`, `CONTINUE`, and `RETRY` statements for additional information.
