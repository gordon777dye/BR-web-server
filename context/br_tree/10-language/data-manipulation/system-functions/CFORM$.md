---
title: CFORM$
file: CFORM$.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [internal function, variable, FORM, READ, CFORM$, FOR]
---
CFORM$(<`form|form statement`>) 

The **CFORM$** `internal function` clears the way for programs to use a `variable` for I/O format without the performance drawbacks that are typically associated with this usage.

In the past, use of a variable for I/O formatting, as in the statement has been discouraged because the `FORM` string must be compiled on each execution of the `READ` statement. The `CFORM$` string contains the format information that would otherwise be specified in a `FORM` statement.

Example:

 00010 dim formstring$*1000, id$*5, name$*30
 00020 let formstring$ = CFORM$("FORM pos 1,C 5,C 30,2*N 5")
 00030 READ #1 USING formstring$: id$, name$, age, weight

The CFORM$ function allows programs to "compile" format variables prior to their use. In the following sample code fragment, the contents of A$ are compiled by CFORM$ and reassigned to A$. This is done prior to the execution of a loop where A$ is used as the format variable. This speeds up execution because the `FORM` statement is not compiled in every execution of the `FOR` loop:

 00900 let A$="FORM C 10, V 20, BH 3"
 01000 let A$=CFORM$(A$)
 01010 FOR X=1 TO 100
 01020    READ #1,USING A$: Variables
 01030 NEXT X

Below is a slower version of the above example. In this slower version, the `FORM` statement is hard-coded into the `FOR` loop and compiled by BR every time the loop executes. This is much slower than compiling it once using the CFORM$ function before executing the FOR loop.

 01010 FOR X=1 TO 100
 01020    READ #1,USING "FORM C 10, V 20, BH 3": Variables
 01030 NEXT X

**NOTE** that variables compiled by CFORM$ will be in an unreadable, machine-dependent internal format. Therefore, programs should never compile a format with CFORM$ and save it to a file for use by other programs. The output of CFORM$ can vary with each machine and with each release of BR.

Be aware that compiled FORM statements that reference variables do so by pointing to the relative dictionary entry, not the name of the variable. This means that when I use CFORM$ to compile a FORM statement and that FORM statement points to a variable for a length or decimal position specification, then that compiled FORM may point to an altogether different variable in a library, or could even point beyond the dictionary in the library, possibly destabilizing BR.

Consider the following example:

 1000 Let QTY_FORM$= CFORM$("FORM C 10, V 20, BH 4.QTY_DEC, BH 3")

where QTY_DEC holds the number of decimal positions in inventory quantities. Let's postulate that QTY_DEC is the fifth dictionary entry.

If QTY_FORM$ is passed to a library, the reference to QTY_DEC would point to the fifth dictionary entry in the library which typically would not correlate with QTY_DEC.

The work around to this would be to begin both the calling program and the library with DIM QTY_DEC and recompile both programs. This would compile QTY_DEC as the first dictionary entry in both programs.
