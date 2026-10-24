---
title: IGNORE
file: IGNORE.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [On Error]
---
The **IGNORE** parameter causes the system to continue as if the error never happened. It is important to understand that the error-causing statement is terminated (not executed) and normal processing continues with the next statement. This means that if an error occurs while ZDIV IGNORE is used for a WRITE statement, the record would not be written. The one exception to this no-execution rule for IGNORE is with the SOFLOW error condition; in this case the assigned string is truncated to its maximum and the statement is executed.

Used in the following statements:
*`On Error`
