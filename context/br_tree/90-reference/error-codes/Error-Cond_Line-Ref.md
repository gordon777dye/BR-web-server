---
title: Error-Cond_Line-Ref
file: Error-Cond_Line-Ref.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [Error Conditions]
---
The "error-cond line-ref" parameter is replaced with one or more pairs of specifications. "Error-cond" is a specific error condition and "line-ref" is a line number or line label to which control should be transferred if that error occurs. See `Error Conditions` for more information.

For example:

 ...EOF donereading...

When the program runs this statement and comes to an `EOF|End of File` error, it will transfer to the line labeled "donereading".
