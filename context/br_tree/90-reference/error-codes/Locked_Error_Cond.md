---
title: Locked_Error_Cond
file: Locked_Error_Cond.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [0061, 4148]
---
The LOCKED error condition can be used at the end of a program statement, in the Exit statement, and in the ON error statement.

===Error Traps:===
LOCKED traps two types of errors:
:1.) the record is locked at another workstation (error code `0061`)
:2.) file- sharing rules are violated (error code `4148`)
LOCKED should be listed before the IOERR or ERROR error conditions when it appears in a list of error conditions, as IOERR and ERROR will trap all the errors that LOCKED traps plus many more. When error processing is handled at the ON error statement level, however, Business Rules automatically invokes the error action which is most specific to the error which has occurred.
