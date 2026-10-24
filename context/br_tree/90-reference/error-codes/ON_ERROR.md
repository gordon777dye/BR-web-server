---
title: ON_ERROR
file: ON_ERROR.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [statement, System defaults, SOFLOW, error condition, GOTO, line ref, IGNORE, SYSTEM, ATTN, CONV]
---
The **On Error** `statement` (sometimes called "ON" or "ON error GOTO") is an executable statement which changes the system defaults for error handling. The ON error statement's specifications remain in effect until changed by another ON error condition statement or until a new program is loaded.

===Comments and Examples===
`System defaults` are in effect at the start of every program. On Error allows you to change the current program's system defaults for error-handling.

Business Rules follows a set pattern in determining the appropriate way to handle an error. First it checks the error-causing statement. If that statement ends with an "error-cond line-ref" for the particular error which occurred (for example, `SOFLOW` for string overflow), Business Rules branches to the specified line-ref.

If an applicable specification does not exist in the error-causing statement, Business Rules checks an internal error-handling table. This table keeps track of all error-handling options that are specified by active ON error statements. When a particular error condition is not addressed by an ON error statement, the table lists the system default as the appropriate error- handling routine.

Lines 10 to 30 are examples of the three options for error handling.

 00010 ON ZDIV GOTO 7700
 00020 ON ZDIV IGNORE
 00030 ON ZDIV SYSTEM

Of course, a program should not contain these three statements in a row because they would cancel each other out (line 30 would return the system to the default). But for this discussion, assume these statements are not canceled by other ON error statements executed later in the program and that "ZDIV line-ref" is not coded on the end of any statements. In a program containing only line 10, a ZDIV error (division by zero) anywhere in the program would transfer control to line 7700. A ZDIV error would be ignored if a program included only line 20. Line 30 would display an error message, beep, place the system in ERROR mode and wait for a response from the system operator. Let's look more closely at the IGNORE and SYSTEM options.

The IGNORE option should be used with caution. No error halt occurs when IGNORE is specified, and the functions ERR and LINE are not set. In the following example, line 100 instructs the system to ignore errors caused by trying to divide by zero. Line 110 instructs the system to ignore all errors:

 00100 ON ZDIV IGNORE
 00110 ON ERROR IGNORE

Exceptions to the ON ERROR IGNORE statement in line 110 can be coded on subsequent lines. In the following example, for instance, line 120 reverses the IGNORE specification for the PAGEOFLOW condition only; the system will transfer control to the operator in the event of this one error, but it will continue to ignore all other errors:

 00110 ON ERROR IGNORE
 00120 ON PAGEOFLOW SYSTEM

The SYSTEM option (for example, ON ZDIV SYSTEM) does not always result in an error message being displayed. The list of error conditions includes several keywords for particular error conditions (for example, CONV, SOFLOW, ZDIV, etc.) and one special keyword, ERROR, which traps any and all errors. The general rule is that error processing is controlled by ON ERROR (which defaults to SYSTEM) with two important and very frequent exceptions:

:1.) Error conditions coded at the end of a statement are processed first.<br>
:2.) ON error statements referring to particular error conditions are processed next. When combined with line 310 below, the SYSTEM option in line 300 would lead to an error message and ERROR mode because both the particular error condition (ZDIV) and the generalized error condition (ERROR) are set to system.

 00300 ON ZDIV SYSTEM
 00310 ON ERROR SYSTEM

However, the SYSTEM option in the following example would not display an error message because line 410 establishes branching to line 80000 when any otherwise uncontrolled error occurs.

 00400 ON ZDIV SYSTEM
 00410 ON ERROR GOTO 80000

===Syntax===
 ON <`error condition`> {`GOTO`< `line ref`>|`IGNORE`|`SYSTEM`}

`Image:OnError.png|400px`

Available Error Conditions:
*`ATTN`
*`CONV`
*`ERROR`
*`FNKey Error Cond|FNKEY` num-expr
*`HELP`
*`IOERR`
*`Locked Error Cond|LOCKED`
*`OFLOW`
*`PAGEOFLOW`
*`SOFLOW`
*`ZDIV`

===Default===
:1.) When the ON statement is not specified, IGNORE is used for the ATTN, FNKEY, and PAGEOFLOW error conditions. All others default to SYSTEM.

===Parameters===
The "error condition" parameter requires one of eleven valid error conditions: ATTN, CONV, ERROR, FNKEY num- expr, HELP, IOERR, LOCKED, OFLOW, PAGEOFLOW, SOFLOW or ZDIV. Look at each one individually for more information.

"GOTO line-ref" transfers control to an error-handling routine on another line of the program.

"SYSTEM" displays an error message and causes the system to enter ERROR mode (unless the error is handled elsewhere). See the `HELP` error condition for the exception to this rule.

"GOSUB" transfers control to an error-handling sub-routine (4.2). See `ON ERROR GOSUB` for details.

"IGNORE" causes the system to continue as if the error never happened. It is important to understand that the error-causing statement is terminated (not executed) and normal processing continues with the next statement. This means that if an error occurs while ZDIV IGNORE is used for a WRITE statement, the record would not be written. The one exception to this no-execution rule for IGNORE is with the SOFLOW error condition; in this case the assigned string is truncated to its maximum and the statement is executed.

===Technical Considerations===
:1.) Only one error condition can be coded per statement, but there is no limit to the number of ON error statements per line or in a program.
:2.) The ON error statement is an executable statement. It establishes its condition from the point at which it is executed in a program. This condition stays in effect until changed by the execution of another ON statement or until a new program is loaded.
:3.) The functions ERR and LINE are set by any error (unless an IGNORE is in effect) and may be used in the error-handling routine.
:4.) IGNORE means that processing continues despite an error. The error-causing statement is skipped and the functions ERR and LINE are not set. One exception to this rule is a statement such as the following. If B$ is too long for A$, it will be truncated:

 00010 A$=B$

:5.) Error-handling routines usually end with `Retry|RETRY` or `Continue|CONTINUE` statements.
:6.) When ON error statements are used in conjunction with other error-handling techniques, the other techniques take precedence. ON error-cond specifications are used only when the occurring error condition is not otherwise addressed in the error-causing statement or in a referenced Exit statement.
:7.) When the system is not waiting for operator input, the "FNKEY num-expr" parameter may be used to transfer control to a line when the specified key is pressed. This can be useful for allowing the operator to gracefully interrupt a report.
:8.) If one of the function keys is pressed during any input operation from the keyboard, no interrupt occurs. Instead, the CMDKEY function is set and pressing <Enter> is simulated. This situation is true even when the ATTN, FNKEY or HELP parameters are specified in an ON error condition statement. It is possible to remap function keys (using the KEYBOARD specification in BRConfig.sys) so that pressing them will simulate an <Enter> and function key combination. This sequence would cause the INPUT FIELDS to be terminated and FNKEY error processing to occur, even when the function key is pressed during a keyboard input operation.
:9.) Even if ON FNKEY IGNORE or ON HELP IGNORE is in effect the pressing of a function key or the <HELP> key causes the CMDKEY function to be set.
:10.) ON error specifications do not apply to immediate statements.
:11.) F11-F20 are not supported with the ON FNKEY statement. However, F11-F20 can be used with CMDKEY processing.
:12.) For additional information on error processing, see the `Exit`, `CONTINUE`, and `RETRY` statements and `Error Conditions`.
