---
title: PROCIN
file: PROCIN.md
category: 70-commands
subcategory: 70-commands/information
kind: command
related: [internal function, procedure file]
corrections:
  - "Added the literal RUN … PROC forms and a link to program-management#run-proc; the page named RUN PROC without saying how to write it. A plain RUN inside a procedure leaves PROCIN at 0: confirmed on 4.33c. Reported in context/lsp/ERRORS.md 2026-09-09."
---
PROCIN

The **ProcIn** `internal function` returns 0 if input is from the screen. Returns 1 if input is from a `procedure file`.

====Comments and Examples====
When RUN PROC is used to change programs to accept input from a procedure file instead of the screen, no code changes to the program are required. PROC is an option of RUN, written in a procedure as `RUN <program> PROC` (or `LOAD <program>` then `RUN PROC`); see [RUN … PROC](../program-management/spec.md#run-proc). A plain `RUN` inside a procedure leaves ProcIn at 0. However, the input from the procedure is not echoed on the screen. The ProcIn variable can be tested in a program to provide this echo if desired.

 00010 PRINT "Enter T for totals or D for detail"
 00020 LINPUT A$
 00030 IF PROCIN=1 THEN PRINT A$
