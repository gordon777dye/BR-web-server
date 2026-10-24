---
title: CHAIN
file: CHAIN.md
category: 10-language
subcategory: 10-language/flow-control/other-flow
kind: statement
related: [LOAD, PROC, SUBPROC, EXECUTE, RUN, STOP, END]
corrections:
  - "Reclassified and relocated from 70-commands/program-management/CHAIN.md. CHAIN is a
    **statement** (it carries a line number and runs at RUN, and can itself be run
    immediate-mode like a command per note 9 below) — not a console command — so the
    `kind: command` frontmatter this page carried from the legacy wiki migration was wrong,
    and 70-commands (commands only; every other backing page there is `kind: command`) was
    the wrong physical home. Moved here alongside the other program-termination statements
    (STOP/END/PAUSE, see the parent spec's termination section). The summary of CHAIN's
    syntax and semantics remains in
    [program-management](../../../70-commands/program-management/spec.md#chain), which still
    covers it accurately; this page is retained only as the deep-reference copy of the
    technical notes."
  - "Reformatted from raw wiki markup to CommonMark: `===Heading===` → `##`, wiki `#` list
    items → numbered Markdown lists, space-indented example lines → fenced
    ```business-rules```/```bnf``` blocks, curly quotes → straight quotes, and the orphaned
    `file:Chain.png|700px` image transclusion → a plain note (no local copy of that image
    exists). One Technical Considerations item had lost its line break in an earlier
    conversion pass and read as a single note splicing two unrelated points together (file-ref
    syntax checking, and IBM Business BASIC's IF-THEN-CHAIN restriction); split back into two.
    That correction changes the true count from 10 numbered wiki items to 11 distinct notes —
    the \"13 technical notes\" figure quoted elsewhere (this page's old `related:` link and two
    spots in program-management/spec.md) was never right and has been corrected to 11
    everywhere it appeared. Also fixed plain transcription typos (differtence, specifified,
    seperated, therwise, opertor, anotherr) and one keyword typo (SUPROC → SUBPROC, the
    keyword the rest of this page uses correctly). No technical content changed."
---

The **Chain** (CH) statement ends the current program and starts execution of another program,
procedure, or sub-procedure.

## Comments and Examples

CHAIN is most often used to chain from one program to another. To do this you just type CHAIN and
indicate the name of the desired program.

The statement in the following example causes the system to end the current program and load the
program MENU.BR (or MENU.BRO) from a subdirectory called MAIN:

```business-rules
00350 CHAIN "MAIN\MENU"
```

The next example loads and runs the program GLEDIT.BR (or GLEDIT.BRO) from the subdirectory GLPROG
(a subdirectory of the root directory). All files stay open at their current positions. The
variable D$ retains its current value at the start of the new program; all other variables return
to zeros or null strings.

```business-rules
00900 CHAIN "C:\GLPROG\GLEDIT" ,FILES,D$
```

To chain from a program to a procedure or sub-procedure (rather than another program), you must
have either "PROC=" or "SUBPROC=" immediately before the name of the desired file, as in the
following two examples:

```business-rules
00900 CHAIN "PROC=GLPOST"
```

```business-rules
00080 NAME$="EDITLIST.PRC"
00090 X$="SUBPROC=GLPROG\"&NAME$
00100 CHAIN X$
```

When a program chains to a procedure (PROC or SUBPROC), the procedure acts much like the operator
stopped the program and started entering commands. A procedure is a set of commands. (However a
procedure can skip forward or backward within itself.) While it is emulating a series of commands,
the program that initiated the procedure is retained in memory even though the CHAIN statement
terminated it. Therefore its variable contents are accessible to the procedure.

The following example specifies that the string array A$ and the numeric variables B and C are to
retain their values in the chained-to program:

```business-rules
60000 CHAIN PROG$,MAT A$,B,C
```

## Syntax

```bnf
CHAIN {"<program name>" | "PROC=<name>" | "SUBPROC=<name>" | "<path>\<name>"}
      [,FILES] [,MAT <array name>][,...] [,<variable name>][,...]
```

*(The original wiki page included a diagram, `Chain.png`; no local copy of that image exists.)*

## Defaults

1. Load and run a program.
2. Close all open files (except procedure files).
3. Set all variables in the chained-to program to blanks or zeros.

## Parameters

The only required parameter of the CHAIN statement is the "file-ref", which specifies the program,
procedure, or sub-procedure to be executed. This name and subdirectory information may be
specified as a quoted literal string or as a string variable.

If the file-ref is preceded with the string "PROC=", the CHAIN initiates a procedure. If the
file-ref is preceded with the string "SUBPROC=", the CHAIN initiates a sub-procedure. If neither of
these keywords is present, the CHAIN statement attempts to load and run a program.

The difference between PROC and SUBPROC is that PROC will close the current (lowest level) PROC
file (if one is running) before starting the specified procedure, whereas SUBPROC will not affect
a currently running PROC file.

The parameters following the file-ref apply only to programs and not procedures.

Following the file-ref information, CHAIN can take three optional parameters, but these parameters
should be included only when chaining to a program.

"FILES" indicates that all files are to remain open and at their current positions. If you do not
specify "FILES", the CHAIN statement closes all files except procedure files.

The "MAT array-name" and "variables" parameters allow the specified arrays or variables to retain
their current values in the chained-to program. If several are used they are separated by commas.

## Technical Considerations

1. Array variables and string variables passed between programs by a CHAIN statement are not
   required to be dimensioned the same way in both programs. If dimensions do not match, the
   dimensions in the first program will override those in the DIM statements of the second
   program. However, it is recommended for improved readability that dimensions should match in
   both programs. Arrays may be re-dimensioned in the second program.
2. Options selected in an OPTION statement are not required to be the same in both programs.
   However, it is strongly recommended that these options be the same. For example, if the first
   program uses BASE 1 and the second program uses BASE 0, confusing results could "run rampant"
   because the last element of a 10-element array would have a subscript of 10 in the first
   program and 9 in the second program.
3. RUN command options, which are active in the initial program, will remain active in the
   chained program. These options include RUN PROC and output redirected to a file (see the RUN
   command for more information).
4. In Business Rules, there is no need for a USE statement in the program being chained. USE is
   treated as a comment and is maintained only for compatibility with IBM Business BASIC.
5. Although Business Rules checks most statements for proper syntax as they are entered, the
   file-ref parameter of the CHAIN statement is not checked until execution (this is also true in
   the OPEN statement). In this case, variables and quoted strings cannot be checked until
   execution.
6. IBM Business BASIC restricted the use of CHAIN statements within IF statements; if the THEN
   clause was a CHAIN statement, the ELSE clause was not permitted. This restriction does not
   apply to Business Rules. The following statement is allowed:

   ```business-rules
   90 IF X=0 THEN CHAIN "MENU" ELSE CHAIN "PR2"
   ```
7. The rules for the default extension of a program name, which is specified in a CHAIN
   statement, are the same as the rules for the LOAD command. In short, the system first looks
   for an extension of .BR; if that is not present, the system then looks for .BRO. You can
   change these defaults with the CHAINDFLT specification in the BRConfig.sys file. You can also
   override the defaults from within the CHAIN statement by specifying your own extension, as in
   the following example:

   ```business-rules
   900 CHAIN "C:\MAIN\MENU.OLD"
   ```
8. The ability to pass specified variables from a program to a procedure is not explicitly
   supported in Business Rules because the values of all variables are available at the end of a
   program. These variables retain their values until a SORT, INDEX, CLEAR, or LOAD command is
   encountered from the keyboard or from a procedure file. This means that any variable from the
   calling program could be tested by a SKIP command (or otherwise used) in a procedure file.
   (Notice that this also means those values of all variables are available to an operator after
   program termination for interrogation [displaying contents] and debugging.)
9. Like most Business Rules statements, CHAIN may be used in immediate mode like a command
   (except with the EXECUTE statement, where commands may not terminate a program). Within a
   procedure, the following two commands are equivalent: `PROC EOM` and `CHAIN "PROC=EOM"`. The
   next two commands would also be equivalent within a procedure: `SUBPROC EOM` and
   `CHAIN "SUBPROC=EOM"`. Although using CHAIN as a command may not seem very useful because the
   simpler PROC and SUBPROC alternatives exist, CHAIN allows a procedure to pass variables from
   its parent or itself to a program. For example, a procedure file might start a program to
   print designated messages for certain completion codes as follows: `LOAD PROG1` then `RUN`
   then `X=CODE` then `SKIP 1 IF X=0` then `CHAIN "MESSAGE", X`. This passes the variable X
   (created by PROG1 or the procedure) to the program named MESSAGE. The same is true if a
   program CHAINs to a procedure and the procedure simply forwards variables from the chaining
   program to another program.
10. `CHAIN "PROC=XYZ"` is similar to `EXECUTE "PROC XYZ"`, except EXECUTE does not end the
    program. That being said, the procedure has the authority to end the program that called it
    via EXECUTE.
11. If the FILES keyword is used to keep files open, file pointers are not moved. Thus, pointers
    which were at the end of the file in the first program will also be at the end of the file
    in the second program; you may use a RESTORE statement to reposition a file pointer.
