---
title: ON_ERROR_GOSUB
file: ON_ERROR_GOSUB.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [ON ERROR, GOSUB, GOTO, SYSTEM, ON FKEY, RETRY, CONTINUE, RETURN, BREAK]
---
The `ON ERROR` statement has been augmented to support `GOSUB` in addition to `GOTO` and `SYSTEM`. This is a very important feature because it permits multiple nested error processes and `ON FKEY` GOSUB label-reference. Programmers are no longer limited to the simple `RETRY` or `CONTINUE` to return from an interrupt. 

A `RETURN` from such an interrupt will resume where `RETRY` does unless the error condition occurs at the completion of an Input/Output operation, in which case it performs a `CONTINUE`. 

====Notes==== 
*The keyboard buffer is cleared by ON error GOSUB interrupts.
*By default, BR checks for Fkey interrupts every eight statements. Use the `BREAK` configuration statement to vary this.
*If an ON FKEY GOSUB / GOTO statement catches an interrupt during a SLEEP operation the Sleep is immediately terminated. In the case of GOSUB, a RETURN resumes with the clause following the Sleep.
