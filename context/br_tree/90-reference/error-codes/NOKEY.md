---
title: NOKEY
file: NOKEY.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [error condition, error code, 4272, Exit]
---
The **NoKey** `error condition` (also known as `error code` `4272`) can be used at the end of a program statement and in the `Exit` statement, but it cannot be specified in an ON error statement.

===Error Traps:===
NOKEY traps the error that occurs when a file does not contain the specified key when a KEY= or SEARCH= clause is used on a file opened for the KEYED method of access.
