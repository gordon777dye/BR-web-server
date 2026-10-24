---
title: Procedure_files
file: Procedure_files.md
category: 70-commands
subcategory: 70-commands/program-management
kind: command
related: [Proc, ASCII, RUN PROC, Subproc, Line Label (procedure), FREE, RUN, EXECUTE]
---
A **procedure file** is a text file that contains a list of commands and/or programs to run in order. It is run using the `Proc` command. 

==Creating and Editing Procedure Files==

You may create procedure files with any method used to create `ASCII` text files. Although procedures usually include only commands, they may also contain program statements to be merged into a program in memory or to be executed in immediate mode. Also, data to be used in programs may be included in procedures when a `RUN PROC` command is used.

Procedure files are useful in simplifying the execution of often-used command sequences. Once a sequence has been stored in a procedure file, only the `PROC` command and the name of the procedure (or any of the other methods discussed below in the section titled "Starting a Procedure") are necessary for executing that command sequence.

Procedure processing in Business Rules also provides a programming system including the following common elements of programming systems: a list of instructions, conditional and unconditional branching, line labels, looping capability, sub-procedures (much like subroutines), input and output capabilities, comment lines and end-of-line comments.

Here are two examples of procedures that remove deleted records. The first example is simpler because it was designed for a single-user system:

 ! Procedure to remove deleted records on single-user system
 COPY CUST.FIL TEMP.FIL -D
 FREE CUST.FIL
 RENAME TEMP.FIL CUST.FIL
 RUN MENU

The above five-line procedure consists of a comment line and four command lines to bring the system back to a menu when the procedure is done.

This next procedure accomplishes the same task, but for a multi-user system, thus, it illustrates more features of procedures. However, it could run on a single-user system without any changes:

 ! Procedure to remove deleted records on multi-user system
 PROCERR RETURN
 PROTECT CUST.FIL,RESERVE
 PROCERR STOP
 SKIP BUSY IF ERR<>0
 !
 COPY CUST.FIL TEMP[WSID].FIL -D
 FREE CUST.FIL
 RENAME TEMP[WSID].FIL CUST.FIL
 PROTECT CUST.FIL,RELEASE
 SKIP DONE
 !
 :BUSY
 ALERT File is busy, try again later -type GO for menu
 !
 :DONE
 RUN MENU

Lines beginning with an exclamation mark (!) are comment lines. Lines beginning with a colon (:) indicate the line starts with a line label. All other lines in the above procedure are commands.

===From Outside Business Rules===
:1.) Use a text editor such as Notepad, EditPad Pro, or the Unix / Linux visual editor vi.
:2.) Use a word processing program, but be sure it can read and write standard ASCII text files.

===From Inside Business Rules===
Write a Business Rules program to open a display file and print lines of text.

==Starting a Procedure==

To initiate a procedure named DAILY, you could use any of the following methods:

===The PROC Command===

===The SUBPROC Command===
From inside Business Rules, when the status line says READY, type the following command and press <CR>:

 SUBPROC DAILY

This command can also be used in a procedure to temporarily suspend the most recent procedure, start the DAILY procedure, then resume the calling procedure when DAILY completes (unless DAILY somehow cancels the procedure which started DAILY).

See `Subproc` for more information.

===The CHAIN Statement===
From any program (especially useful in menu programs), include either one of the following lines:

 900 CHAIN "proc=DAILY"
 920 CHAIN "subproc=DAILY"

Both CHAIN statements will end the current program and start the DAILY procedure. Line 900 will cancel the most recently started procedure (if any) before starting DAILY. Line 920 will suspend the most recently started procedure (if any), then resume it when the DAILY procedure completes.

See the Statements chapter for more information about CHAIN.

==The Execute Statement==

In any program, include either one of the following lines:

 04200 EXECUTE "PROC DAILY"
 04300 EXECUTE "SUBPROC DAILY"

Both EXECUTE statements will start the procedure without ending the current program. Unless the procedure loads another program, the current program will continue when the DAILY procedure completes. Line 4200 will cancel the most recently started procedure; line 4300 will not.

==The BR Command==

From the prompt for your operating system, type the following then press <CR>:

 BR "PROC DAILY"

==Sequential Processing==

Lines in a procedure are processed sequentially (from beginning to end) unless a SKIP command instructs the system to alter the order of processing.

===Procedure Closes before executing last line===

Since the procedure file is closed before executing the last line, the last line should be viewed as an independent command that is not part of the rest of the procedure. Viewing the last line as a one-line mini- procedure will help avoid some potential problems when the last line of a procedure is a command like SKIP or RUN PROC.

The last line cannot be a SKIP to branch back to an earlier part of the procedure, because the procedure is already closed before it executes this last line. Similarly, the last line cannot be a RUN PROC command because the procedure will be closed before the program even starts to look for data in the procedure. If this independence of the last line in a procedure causes problems, an easy solution is to add another line (e.g., a blank line or comment line) to keep the procedure file open longer.

===Stopping a Procedure===

Interrupting a procedure from the keyboard is similar to interrupting any program or command. First, press the Ctrl key and hold it down, then press the A key. When ATTN appears in the status line, procedure processing has stopped. At this point, you may type GO to resume execution of the procedure, or you may type in and execute most immediate mode commands and statements. Any of the following forms of the CLEAR command will end execution of the procedure (See the Commands chapter for more information about CLEAR):

 CLEAR PROC

The above command ends all active procedures, ends the current program (if any), but leaves memory as it is.

 CLEAR ALL

The above command ends all active procedures, ends the current program (if any), and clears memory.

 CLEAR PROC ONLY

The above command ends all active procedures, but continues the current program (if any), and leaves memory as it is.

==Syntax Rules for Coding Procedures==

;Blank lines
Blank lines are allowed (they are ignored).

;Commands
Only one command per line.

;Comments
:1.) Comments may be added to the end of any command by starting the comment with an exclamation mark.
:2.) Comments may appear as separate lines by beginning that line with an exclamation mark.

;Data
:1.) When input with RUN PROC, data must be coded exactly as it would be entered at the keyboard including commas, quotation marks, etc.
:2.) Data must be coded so that each INPUT, LINPUT or RINPUT statement in the program is matched to a single line in the procedure file.
:3.) If too many lines of data are found in the procedure file, the procedure will attempt to interpret these lines as commands that may lead to unpredictable errors.
:4.) If too few lines of data are found in the procedure file, the procedure will attempt to interpret the next commands in the procedure as data; this may lead to unpredictable errors. If there are no more lines in the procedure, the procedure will expect remaining input to come from the keyboard.

;Line labels
:1.) Must begin with a colon.
:2.) Made up of letters, digits or underscores.
:3.) May be up to 800 characters long.
:4.) May be alone on a line without any command.
:5.) May be followed by a command (need one or more spaces separating label and command).

For more information, see `Line Label (procedure)`.

;Line length
Line length can be up to 800 characters.

;Number of lines in a procedure
Unlimited

;Statements
:1.) May be entered as in programs (including multiple statements per line).
:2.) May be entered without line numbers and will be executed like commands.

;Last line in a procedure
:1.) May not be a SKIP or RUN PROC.
:2.) Should not be likely to error out.
:3.) May be a comment or a blank line.

==Concepts for Coding Procedures==
===Initiating a Procedure===

Two alternatives are possible when a new procedure is initiated from inside a procedure which is already executing:

:1.) The new procedure can cancel the current one (the PROC command does this).
:2.) The new procedure can temporarily suspend the current one, execute the new procedure, then finish executing the calling procedure from where it left off (the SUBPROC command does this).

When a `PROC` command is issued from inside a procedure to start a new procedure, it cancels the most recently started procedure. When a `SUBPROC` command is used in a procedure to start a new procedure, it lets you exit the current procedure temporarily to run the new procedure, then returns to the calling procedure where it left off. Any procedure file started by a SUBPROC command, or a CHAIN statement with SUBPROC=, is called a nested procedure. There may be up to nine levels of nested procedures active at any one time. The STATUS command displays the names of all active procedures. Also, columns 58-59 of the status line display P1, P2, etc., up to P9 to reflect the level of the most currently activated procedure.

Each active procedure counts as an open file against your operating system limit on of open files per workstation. Business Rules closes a procedure before executing the last line in the procedure; this look-ahead feature allows a procedure to free itself when `FREE` is the last command in the procedure. This also eliminates procedure stacking (and thus allows one more file against the operating system limit) in cases like the following: when one procedure ends with a SUBPROC command to call another procedure, when `RUN` is the last command in a procedure, or when a procedure has only one command.

===Self Deleting Procedure===

Procedure files with names that end in a .$$$ extension will automatically delete themselves after executing. The sequence of events which occurs with self-deleting procedures is that Business Rules executes the `*.$$$` procedure file up to the last line. It then reads the last line of the procedure, closes and deletes the procedure file, and executes the last line of the procedure. As the last line is not executed until the rest of the file is deleted, it is important to avoid coding any instruction on this line that is likely to cause an error.

===Termination of Previous Procedure===

When EXECUTE "PROC XYZ" is processed, the system cancels the last procedure activated and substitutes procedure XYZ. The same occurs when Business Rules encounters any PROC command while it is processing one or more active procedure. If you don't want to cancel the last procedure, you should use EXECUTE "SUBPROC XYZ" instead to make sure that the original procedure will be resumed. Operator-initiated procedures or sub-procedures are both treated as sub-procedures; therefore, they do not cancel active procedures

===Termination of RUN PROC===

When `EXECUTE` "PROC XYZ" is processed, any existing `RUN` PROC input mode is terminated. Input statements begin reading from the keyboard. Since the original procedure is canceled, and the data is in this original procedure, taking keyboard input from the procedure would no longer be sensible or predictable.

During EXECUTE "SUBPROC XYZ", or any sub-procedures initiated by XYZ, any prior RUN PROC processing remains active. This means that if RUN PROC is active it will stay active across executed subprocs, but not across executed procs.

===Instruction set limitations===

Although most Business Rules commands and statements may be used in procedure files, a few, such as AUTO, may not. To find out whether or not a particular command or statement works in a procedure file, check its description in the Commands or Statements chapters.

Using procedures adds an extra level of power and flexibility to Business Rules. Like JCL (job control language) on mainframe computers and similar to batch files (AUTOEXEC.BAT) in DOS, procedures provide the ability to code groups of commands and statements in a file to be executed later. Procedure support allows executing a list of commands, executing a sub-procedure (sub-procedures can be nested up to 9 levels), unconditionally and conditional branching (including testing any variable from the most recently completed program), sending messages to the operator and waiting for a response, adding program lines to existing programs, and entering a single command to alter programs to accept data from the procedure file instead of the keyboard.

==Procedure Commands==

==Express Procedures==

Express procedures are procedures that are executed during the middle of running a program. When an express procedure is completed, the program can be resumed where it left off with all variables unchanged. Procedures and sub-procedures may be executed either from an EXECUTE statement in a running program or from the keyboard during an interruption of a program. Express procedures expand the power and flexibility of Business Rules support for procedures.

EXECUTE "PROC XYZ" stops processing the last activated procedure (typically the one which started the current program) and begins executing commands stored in file XYZ as an express procedure. EXECUTE "PROC XYZ" operates as if the currently activated procedure issued the PROC command; it terminates the current procedure (if any), it executes "PROC XYZ", and then the system continues program processing when the procedure is completed (unless "PROC XYZ" loads another program).

EXECUTE "SUBPROC XYZ" processes commands in file XYZ as an express sub-procedure, then resumes processing without affecting the current procedure hierarchy (no procedures are canceled).

Executed procedures and sub-procedures imply NOECHO during their execution; therefore, they can be thought of as commands which will in turn issue multiple sub- commands (none of which will appear on the screen).

Two ways to start an express procedure are:

:1.) From a program with an EXECUTE statement containing a PROC or SUBPROC command (called an executed express proc).
:2.) By the operator keying in a PROC or SUBPROC command during an interruption in the program (called an operator-initiated express proc).

The two distinctions between executed and operator- initiated and between procedures and sub-procedures allow for four logical combinations, as illustrated in the following chart. You should note that there are only three functionally different combinations because an operator-initiated PROC command is treated like an operator-initiated SUBPROC command during an interrupted program; this means an operator-initiated PROC command will not cancel any currently active characteristics of express procedures.

`Image:Procchart.jpg`<br>

==Express vs. Standard Procedures==

An express procedure is basically like any other procedure, except for a few operational differences.

===Invisible===

Commands and procedures invoked by the EXECUTE statement are not displayed (PROC NOECHO is implied as the first command of an Executed procedure). If an error occurs or an ALERT statement is encountered, the operator must press F2 or F3 to view the command causing the halt. After the express procedure is completed, commands are displayed (or not displayed) as they were before the express procedure.

===Error Processing===

Normal error processing for procedures (e.g., default of PROCERR STOP) is still in effect for express procedures; however, there are additional steps in the error processing for express procedures initiated by an EXECUTE statement. If an error occurs during an executed express procedure or sub-procedure, the procedure file is closed and the error is returned to the EXECUTE statement. Any valid error condition may be used for error trapping on an EXECUTE statement. ERROR is a general error condition which can be used to catch any kind of error including syntax errors on commands in an EXECUTE statement or commands initiated through an executed express procedure.

If an error occurs during an express procedure that was started by an operator during an ATTN or ERROR interruption, the error is returned to the operator as usual.

Entering GO after an interruption resumes execution according to the following priorities:
:1.) Any active express procedure.
:2.) Any running program.
:3.) Any active procedure.

===Subordination===

One way to view processing for express procedures is to consider executed commands and procedures to be subordinate to the current program. Normally the current program is considered subordinate to the procedure that started it. However, if an express procedure is started during an executing program, this procedure is subordinate to the program. There are several interesting implications to this.

Any command processed as the result of an EXECUTE statement, either directly or via an express procedure, which causes the program to end, removes the subordinate relationship. After the program has ended, all subsequent procedure commands and statements are displayed (or invisible) according to the PROC ECHO/NOECHO status. Commands that cause the program to end are CLEAR, LOAD file-ref and RUN file-ref, as well as CHAIN, END and STOP statements.

The command CLEAR PROC ONLY does not end a program. Therefore, line 1200 clears all procedures above a program, and continues processing:

 01200 EXECUTE "clear proc only"

EXECUTE "PROC XYZ" not only starts procedure XYZ, but it stops processing the last procedure activated. Therefore the procedure immediately above a program can be terminated by the program by issuing an EXECUTE "proc CLRPROC" where CLRPROC is an empty procedure.

The program gets control again after the EXECUTE statement with one procedure layer removed. This can be done successively.
