---
title: OFLOW
file: OFLOW.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: []
---
The OFLOW error condition can be specified at the end of a program statement, with the Exit statement or in the ON error statement.

===Error Traps:===
The OFLOW error condition is a System/23 compatibility feature. On the System/23, it trapped errors that occurred when the system computed a number having an  absolute value greater than the largest numeric value of the system. This feature is hardware dependent and has no relevance to DOS, Unix or Linux systems.
