! BR_report - run one report program in a restricted session, and say in
! the exit code how it ended.
!
! EVERY LINE OF A PROCEDURE IS ON THE SCREEN, comments included - a
! procedure echoes itself as it runs - so these comments are the display
! as well as the notes.  The reasoning behind each choice here is in
! README.md, under the standard procedures; what follows is the contract.
!
! THE LAUNCH is the run_report TOOL, which a model calls:
!
!       run_report  program  dir  [procedure] [config] [seconds]
!
!   The driver writes loader.prc into dir, starts
!       brserver [-config] --restricted proc <procedure>
!   with dir as its working directory, and answers at once; the exit code
!   comes back from report_status.  It is a tool and not a command a
!   person types because running the report is the next thing in the
!   conversation that wrote it - and what makes that safe to hand a model
!   is this session being restricted, not any check in the driver.
!
!   --restricted is passed even though the AI-connected flag would
!   usually have done it: the originating session may have closed between
!   the report being approved and this being run.
!
!   The PROCEDURE NAME MUST BE RELATIVE to dir.  Measured: BR started
!   with `proc C:\...\BR_report.prc` sits at the Command Console and runs
!   nothing - no error and no exit - so the driver refuses an absolute
!   name rather than passing one on to hang.
!
! THE PROGRAM comes from loader.prc, one line, written per run by the
! driver, holding a literal LOAD:
!       LOAD "agent\programmer\sales-20261007-1431.brs" SOURCE
!   It is read from BR's working directory, because the SUBPROC below is
!   a literal name.  Nothing here serialises it, so the driver runs one
!   report at a time and refuses a second while one is in flight.
!
! THE PROGRAM MUST NUMBER FROM 10 UP.  Lines 1 to 3 below are added to it
! and have to sort first to be the entry point.
!
! THE EXIT CODE:
!       0      the program ran and ended normally
!       1      loader.prc is missing, or names nothing loadable
!       other  BR's error code, or whatever the program chose to STOP
!              with.  Measured: 4152, file not found, for an untrapped
!              OPEN of a missing file; 42 for a program ending STOP 42.
!
!              READ IT AS 32 BITS.  Windows carries the whole number and
!              GetExitCodeProcess returns it, so 4152 arrives as 4152; a
!              POSIX shell truncates to one byte and shows the same run
!              as 56.  Two readings of one code, not two codes.
!
! THE TIME LIMIT is the driver's, not this procedure's: run_report
! kills the session after its `seconds` (300 by default).  Not for
! errors, which report themselves now, but for a program that loops or
! waits for input with nobody there.
!
! PRINT NEWPAGE EARNS ITS PLACE HERE: everything above it has already
! been echoed and is cleared by it, so the notes for a reader stay off the
! operator's screen and only what follows is on it.  Moving it, or
! dropping it, puts this header in front of somebody who wanted a session.
PROCERR RETURN
PRINT NEWPAGE
!
! ==========================================================
!  Restricted session, running one report program
! ==========================================================
SUBPROC loader.prc
SKIP NOLOAD IF ERR<>0
!
! PROCERR STOP restores the default: the quiet continue was wanted for
! that one command and nowhere else.
PROCERR STOP
!
! The trap.  Line 1 arms it and jumps clear of line 2 into the program's
! own first line; any untrapped error lands on line 2 and ends the
! program with the error code as its value, which arrives in CODE.
! Without this an error would halt the program, interrupt this procedure,
! and leave the session at READY with nobody to answer it.
 1 ON ERROR GOTO TRAP : GOTO 3
 2 TRAP: STOP ERR
 3 !
RUN
SKIP FAILED IF CODE<>0
!
! The report finished.
SKIP DONE
!
:FAILED
PRINT "The report program stopped on error "&STR$(CODE)&"."
EXECUTE "SYSTEM "&STR$(CODE)
!
:NOLOAD
! loader.prc is missing, or names a program that will not load.  LINE is
! not reported: PROCERR RETURN leaves it at -1 for a procedure error.
PRINT "Error "&STR$(ERR)&": "&BRERR$
SYSTEM 1
!
:DONE
SYSTEM 0
!
! A comment after the last command, on purpose: a procedure file is
! closed before its last line runs, so every SKIP above wants a line
! after it that keeps the file open.
