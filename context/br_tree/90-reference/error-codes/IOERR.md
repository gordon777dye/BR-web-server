---
title: IOERR
file: IOERR.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [4152, PAGEOFLOW, LOCKED]
---
The **IOErr** `Error Conditions|error condition` may be specified at the end of a program statement, in the Exit statement, and with the ON error statement.

IOErr does not trap error `4152`.

====Error Traps:====
IOERR traps all errors that occur in I/O statements, including some errors, which are more specifically trapped by other error conditions. One exception to this rule is that IOERR does not trap `PAGEOFLOW` errors.

In a list of error conditions, IOErr should be placed after `LOCKED`, as IOERR traps the same errors that LOCKED trap, plus others. Similarly, IOErr should be listed before ERROR in a program statement, as ERROR will trap all the errors that IOErr traps. When error processing is handled at the ON Error statement level, however, Business Rules automatically invokes the error action which is most specific to the error which has occurred.
