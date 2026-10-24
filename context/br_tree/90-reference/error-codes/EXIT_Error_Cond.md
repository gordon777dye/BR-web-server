---
title: EXIT_Error_Cond
file: EXIT_Error_Cond.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [Exit(disambiguation), Exit]
---
See also `Exit(disambiguation)`

The Exit error condition may be coded at the end of program statements that accept error conditions. 

 02200   -any statement-    Error-cond line-ref ...  EXIT exit-statement-reference

== Error Traps ==
Exit does not actually trap errors. Instead, it points to a separate `Exit` statement that contains a list of error conditions that may address the error that occurred.

When an error occurs and Business Rules discovers the Exit error condition at the end of the error-causing program statement, it immediately examines the associated Exit statement (which is located at the line number specified with the error condition). If it finds an error condition that addresses the error that occurred, it branches to the line number specified with that error condition. If it does not find an applicable error condition in the Exit statement, it continues looking for an applicable error condition in the original error-causing statement. 

Business Rules always examines the contents of the Exit statement when it encounters the Exit error condition, it is best (and fastest) to place the Exit error condition after any other error conditions that are listed at the end of a program statement. The Exit statement usually includes general error processing that can be used several places in the program. Error processing specific to a particular statement should be coded before the Exit error condition so that the specific items will be processed before the more general ones.
